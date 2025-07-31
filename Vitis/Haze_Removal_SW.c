
#include "xaxidma.h"
#include "xparameters.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_io.h"
#include "xscugic.h"
#include "ImageData_RGB.h"
#include "xuartps.h"

#define imageSize 512*512*3

#define IMG_WIDTH        512
#define IMG_HEIGHT       512
#define NUM_PIXELS       (IMG_WIDTH * IMG_HEIGHT)
#define BYTES_PER_PIXEL  3
#define WORD_SIZE        4  // 32-bit AXI stream word

#define CHUNK_SIZE 256

u32 formattedImageData[NUM_PIXELS];


//u32 checkHalted(u32 baseAddress,u32 offset);

XScuGic IntcInstance;
static void imageProcISR(void *CallBackRef);
static void dmaReceiveISR(void *CallBackRef);
int done = 0;

int main(){

	// Format imageData into 32-bit RGB words
	for (int i = 0; i < NUM_PIXELS; i++) {
	    u8 r = imageData[3 * i];
	    u8 g = imageData[3 * i + 1];
	    u8 b = imageData[3 * i + 2];
	    formattedImageData[i] = (r << 16) | (g << 8) | b;
	}


    u32 status;
	u32 totalTransmittedBytes=0;
	u32 transmittedBytes = 0;
	XUartPs_Config *myUartConfig;
	XUartPs myUart;

	//Initialize uart
	myUartConfig = XUartPs_LookupConfig(XPAR_PS7_UART_1_DEVICE_ID);
	status = XUartPs_CfgInitialize(&myUart, myUartConfig, myUartConfig->BaseAddress);
	if(status != XST_SUCCESS)
		print("Uart initialization failed...\n\r");
	status = XUartPs_SetBaudRate(&myUart, 115200);
	if(status != XST_SUCCESS)
		print("Baudrate init failed....\n\r");

	XAxiDma_Config *myDmaConfig;
	XAxiDma myDma;
    //DMA Controller Configuration
	myDmaConfig = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
	status = XAxiDma_CfgInitialize(&myDma, myDmaConfig);
	if(status != XST_SUCCESS){
		print("DMA initialization failed\n");
		return -1;
	}

	XAxiDma_IntrEnable(&myDma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);

	//Interrupt Controller Configuration
	XScuGic_Config *IntcConfig;
	IntcConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
	status =  XScuGic_CfgInitialize(&IntcInstance, IntcConfig, IntcConfig->CpuBaseAddress);

	if(status != XST_SUCCESS){
		xil_printf("Interrupt controller initialization failed..");
		return -1;
	}

	XScuGic_SetPriorityTriggerType(&IntcInstance,XPAR_FABRIC_DCP_HAZEREMOVAL_0_O_INTR_INTR,0xA0,3);
	status = XScuGic_Connect(&IntcInstance,XPAR_FABRIC_DCP_HAZEREMOVAL_0_O_INTR_INTR,(Xil_InterruptHandler)imageProcISR,(void *)&myDma);
	if(status != XST_SUCCESS){
		xil_printf("Interrupt connection failed");
		return -1;
	}
	XScuGic_Enable(&IntcInstance,XPAR_FABRIC_DCP_HAZEREMOVAL_0_O_INTR_INTR);

	XScuGic_SetPriorityTriggerType(&IntcInstance,XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR,0xA1,3);
	status = XScuGic_Connect(&IntcInstance,XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR,(Xil_InterruptHandler)dmaReceiveISR,(void *)&myDma);
	if(status != XST_SUCCESS){
		xil_printf("Interrupt connection failed");
		return -1;
	}
	XScuGic_Enable(&IntcInstance,XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,(Xil_ExceptionHandler)XScuGic_InterruptHandler,(void *)&IntcInstance);
	Xil_ExceptionEnable();


	status = XAxiDma_SimpleTransfer(&myDma, (u32)formattedImageData, NUM_PIXELS * WORD_SIZE, XAXIDMA_DEVICE_TO_DMA);
	status = XAxiDma_SimpleTransfer(&myDma, (u32)formattedImageData, NUM_PIXELS * WORD_SIZE, XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS){
		print("DMA initialization failed\n");
		return -1;
	}


    while(!done){

    }


	u8 uartBuffer[imageSize];  // 512x512x3 = 786432 bytes

	for (int i = 0; i < NUM_PIXELS; i++) {
	    u32 pixel = formattedImageData[i];
	    uartBuffer[3 * i + 0] = (pixel >> 16) & 0xFF; // R
	    uartBuffer[3 * i + 1] = (pixel >> 8)  & 0xFF; // G
	    uartBuffer[3 * i + 2] = pixel         & 0xFF; // B
	}


	while (totalTransmittedBytes < imageSize) {
	    int remaining = imageSize - totalTransmittedBytes;
	    int chunkSize = (remaining > CHUNK_SIZE) ? CHUNK_SIZE : remaining;

	    transmittedBytes = XUartPs_Send(&myUart, &uartBuffer[totalTransmittedBytes], chunkSize);
	    totalTransmittedBytes += transmittedBytes;

	    // Optional: wait until current transmission completes
	    //while (XUartPs_IsSending(&myUart));

	    // Optional: very small delay if needed
	    usleep(1000);  // Much smaller than 1000 us
	}


}


u32 checkIdle(u32 baseAddress,u32 offset){
	u32 status;
	status = (XAxiDma_ReadReg(baseAddress,offset))&XAXIDMA_IDLE_MASK;
	return status;
}


static void imageProcISR(void *CallBackRef){

	int status;
	XScuGic_Disable(&IntcInstance,XPAR_FABRIC_DCP_HAZEREMOVAL_0_O_INTR_INTR);
	status = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
	while(status == 0)
		status = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
	status = XAxiDma_SimpleTransfer((XAxiDma *)CallBackRef, (u32)formattedImageData, NUM_PIXELS * WORD_SIZE, XAXIDMA_DMA_TO_DEVICE);
	XScuGic_Enable(&IntcInstance,XPAR_FABRIC_DCP_HAZEREMOVAL_0_O_INTR_INTR);
}


static void dmaReceiveISR(void *CallBackRef){
	XAxiDma_IntrDisable((XAxiDma *)CallBackRef, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrAckIrq((XAxiDma *)CallBackRef, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
	done = 1;
	XAxiDma_IntrEnable((XAxiDma *)CallBackRef, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
}

