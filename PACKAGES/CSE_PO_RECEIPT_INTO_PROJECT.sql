--------------------------------------------------------
--  DDL for Package CSE_PO_RECEIPT_INTO_PROJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_PO_RECEIPT_INTO_PROJECT" AUTHID CURRENT_USER AS
--$Header: CSEPORCS.pls 120.1.12000000.1 2007/01/18 05:17:03 appldev ship $
  SUBTYPE Rcv_Attributes_Rec_Type IS CSE_DATASTRUCTURES_PUB.RCV_ATTRIBUTES_REC_TYPE;
  G_MISS_CHAR               CONSTANT    VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_NUM                CONSTANT    NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_DATE               CONSTANT    DATE        := FND_API.G_MISS_DATE;
  G_RET_STS_SUCCESS   	    CONSTANT    VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR	      	CONSTANT    VARCHAR2(1)	:= FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR  	CONSTANT    VARCHAR2(1)	:= FND_API.G_RET_STS_UNEXP_ERROR ;
  G_API_NAME                CONSTANT    VARCHAR2(30):= 'CSE_PO_RECEIPT_INTO_PROJECT';
  SUBTYPE PA_Interface_Tbl_Type IS CSE_IPA_TRANS_PKG.NL_PA_Interface_Tbl_Type;
PROCEDURE Decode_Message(
	P_Msg_Header	       IN 	        XNP_MESSAGE.Msg_Header_Rec_Type,
	P_Msg_Text	           IN	        VARCHAR2,
	X_Return_Status	       OUT 	NOCOPY	VARCHAR2,
	X_Error_Message	       OUT	NOCOPY	VARCHAR2,
   	X_Rcv_Attributes_Rec   OUT 	NOCOPY 	cse_datastructures_pub.Rcv_Attributes_Rec_Type);
PROCEDURE UPDATE_CSI_DATA(
    P_Rcv_Attributes_Rec   IN           cse_datastructures_pub.Rcv_Attributes_Rec_Type,
    X_Rcv_Txn_Tbl          OUT 	NOCOPY	cse_datastructures_pub.Rcv_Txn_Tbl_Type,
	X_Return_Status	       OUT 	NOCOPY	VARCHAR2,
	X_Error_Message	       OUT	NOCOPY	VARCHAR2);
PROCEDURE Get_Rcv_Transaction_Details(
	P_Rcv_Transaction_Id   IN 	        NUMBER,
	X_Rcv_Txn_Tbl		   OUT  NOCOPY	cse_datastructures_pub.Rcv_Txn_Tbl_Type,
	X_Return_Status		   OUT	NOCOPY	VARCHAR2,
	X_Error_Message		   OUT	NOCOPY	VARCHAR2);
PROCEDURE INTERFACE_NL_TO_PA(
	P_RCV_TXN_Tbl	       IN 	        cse_datastructures_pub.RCV_TXN_Tbl_Type,
	X_Return_Status	       OUT 	NOCOPY	VARCHAR2,
	X_Error_Message	       OUT	NOCOPY	VARCHAR2);
  PROCEDURE cleanup_transaction_temps(
    p_rcv_transaction_id IN number);
END CSE_PO_RECEIPT_INTO_PROJECT;

 

/
