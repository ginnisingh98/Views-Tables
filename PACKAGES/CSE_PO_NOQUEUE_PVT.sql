--------------------------------------------------------
--  DDL for Package CSE_PO_NOQUEUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_PO_NOQUEUE_PVT" AUTHID CURRENT_USER AS
-- $Header: CSEPONQS.pls 115.8 2002/11/11 22:06:09 jpwilson noship $
PROCEDURE Process_NoQueue_Txn
(P_Ref_Id IN NUMBER,
 P_Txn_Type IN VARCHAR2,
 x_Return_Status OUT NOCOPY VARCHAR2,
 x_msg_Count OUT NOCOPY NUMBER,
 x_Msg_data OUT NOCOPY VARCHAR2);
PROCEDURE Pa_Interface
 (P_Rcv_Txn_Id IN NUMBER,
  x_Return_status OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2);
END CSE_PO_NOQUEUE_PVT;

 

/
