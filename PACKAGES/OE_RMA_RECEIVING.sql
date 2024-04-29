--------------------------------------------------------
--  DDL for Package OE_RMA_RECEIVING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RMA_RECEIVING" AUTHID CURRENT_USER As
/* $Header: OEXRMARS.pls 120.0.12010000.1 2008/07/25 07:54:03 appldev ship $ */

-- Push_Receiving_Info is an OM procedure that is called by Oracle Purchasing
-- to push receiving information to Oracle Order Management.
-- This procedure is called in the Receiving, Inspection, and delivery
-- process of Oracle Purchasing.
-- For complete list of transaction types, pls see the HLD.

-- Constant variables for transaction types
-- the values are from po_lookup_code table, where lookup_type is
-- 'RCV TRANSACTION_TYPE'.

G_RMA_NO_PARENT         CONSTANT        VARCHAR2(30) := 'NO PARENT';
G_RMA_RECEIVE		CONSTANT	VARCHAR2(30) := 'RECEIVE';
G_RMA_CORRECT		CONSTANT	VARCHAR2(30) := 'CORRECT';
G_RMA_ACCEPT		CONSTANT	VARCHAR2(30) := 'ACCEPT';
G_RMA_REJECT		CONSTANT	VARCHAR2(30) := 'REJECT';
G_RMA_DELIVER		CONSTANT	VARCHAR2(30) := 'DELIVER';
G_RMA_MATCH 		CONSTANT 	VARCHAR2(30) := 'MATCH';
G_RMA_UNMATCHED_ORDER 	CONSTANT 	VARCHAR2(30) := 'UNORDERED';
G_RMA_RETURN_TO_CUSTOMER	CONSTANT	VARCHAR2(30) := 'RETURN TO CUSTOMER';
G_RMA_RETURN_TO_RECEIVING CONSTANT VARCHAR2(30) := 'RETURN TO RECEIVING';


Procedure Push_Receiving_Info(
p_RMA_Line_ID               IN  NUMBER,
p_Quantity                  IN  NUMBER,
p_Parent_Transaction_Type   IN  VARCHAR2,
p_Transaction_Type          IN  VARCHAR2,
p_Mismatch_Flag             IN  VARCHAR2,
x_Return_Status             OUT NOCOPY VARCHAR2,
x_Msg_Count                 OUT NOCOPY NUMBER,
x_MSG_Data                  OUT NOCOPY VARCHAR2,
p_Quantity2                 IN  NUMBER DEFAULT NULL,
p_R2Cust_Parent_Trn_Type    IN  VARCHAR2 DEFAULT NULL
);

Function Get_Open_Line_Id (p_line_rec OE_ORDER_PUB.Line_Rec_Type)
RETURN NUMBER;

Procedure Get_RMA_Available_Quantity(
		p_RMA_Line_ID   	In Number,
x_Quantity out nocopy Number,

x_Return_Status out nocopy Varchar2,

x_Msg_Count out nocopy Number,

x_MSG_Data out nocopy Varchar2);


Procedure Get_RMA_Tolerances(
		p_RMA_Line_ID   		In Number,
x_Under_Return_Tolerance out nocopy Number,

x_Over_Return_Tolerance out nocopy Number,

x_Return_Status out nocopy Varchar2,

x_Msg_Count out nocopy Number,

x_MSG_Data out nocopy Varchar2

		);
End;

/
