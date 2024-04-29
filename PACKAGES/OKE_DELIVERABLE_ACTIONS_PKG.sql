--------------------------------------------------------
--  DDL for Package OKE_DELIVERABLE_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DELIVERABLE_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEVDACS.pls 120.0 2005/05/25 17:31:05 appldev noship $ */

  PROCEDURE Create_Demand ( P_Action_ID 	NUMBER
			, P_Init_Msg_List       VARCHAR2
			, X_ID			OUT NOCOPY NUMBER
			, X_Return_Status 	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 );

  PROCEDURE Create_Shipment ( P_Action_ID 	NUMBER
			, P_Init_Msg_List       VARCHAR2
			, X_ID			OUT NOCOPY NUMBER
			, X_Return_Status 	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 );

  PROCEDURE Create_Requisition ( P_Action_ID 	NUMBER
			, P_Init_Msg_List       VARCHAR2
			, X_ID			OUT NOCOPY NUMBER
			, X_Return_Status 	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 );

  PROCEDURE Delete_Row ( P_Action_ID NUMBER );

  PROCEDURE Delete_Action ( P_Action_ID NUMBER );

  PROCEDURE Delete_Deliverable ( P_Deliverable_ID NUMBER );



END ;


 

/
