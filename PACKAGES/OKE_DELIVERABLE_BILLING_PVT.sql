--------------------------------------------------------
--  DDL for Package OKE_DELIVERABLE_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DELIVERABLE_BILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKEVDVBS.pls 120.1 2005/10/14 16:55:51 ifilimon noship $ */
--
--  Name          : Create_Billing_Event
--  Pre-reqs      : None
--  Function      : This procedure creates a billing event in PA
--
--
--  Parameters    :
--  IN            : P_Commit
--                  P_Deliverable_ID
--  OUT           : X_Event_ID
--                  X_Event_Num
--                  X_Return_Status
--                  X_Msg_Count
--                  X_Msg_Data
--
--  Returns       : None
--
PROCEDURE Create_Billing_Event
( P_Commit                     IN      VARCHAR2
, P_Event_ID             IN      NUMBER
, X_Event_ID                   OUT     NOCOPY     NUMBER
, X_Event_Num                  OUT     NOCOPY     NUMBER
, X_Return_Status              OUT     NOCOPY     VARCHAR2
, X_Msg_Count                  OUT     NOCOPY     NUMBER
, X_Msg_Data                   OUT     NOCOPY     VARCHAR2
);

PROCEDURE Create_Billing_Event
( P_Commit                     IN      VARCHAR2
, P_Event_Type                 IN      VARCHAR2
, P_Event_Date                 IN      DATE
, P_Project_ID                 IN      NUMBER
, P_Task_ID                    IN      NUMBER
, P_Organization_ID            IN      NUMBER
, P_Description                IN      VARCHAR2
, P_Unit_Price                 IN      NUMBER
, P_Bill_Quantity              IN      NUMBER
, P_UOM_Code                   IN      VARCHAR2
, P_Bill_Amount                IN      NUMBER
, P_Revenue_Amount             IN      NUMBER
, P_Item_ID                    IN      NUMBER
, P_Inventory_Org_ID           IN      NUMBER
, P_Contract_Num               IN      VARCHAR2
, P_Order_Num                  IN      VARCHAR2
, P_Line_Num                   IN      VARCHAR2
, P_Chg_Request_Num            IN      VARCHAR2
, P_Bill_Of_Lading             IN      VARCHAR2
, P_Serial_Num                 IN      VARCHAR2
, P_Fund_Ref1                  IN      VARCHAR2
, P_Fund_Ref2                  IN      VARCHAR2
, P_Fund_Ref3                  IN      VARCHAR2
, P_Event_Num_Reversed         IN      NUMBER
, P_Bill_Trans_Currency_Code   IN      VARCHAR2 DEFAULT NULL
, P_Bill_Trans_Bill_Amount     IN      NUMBER DEFAULT NULL
, P_Bill_Trans_rev_Amount      IN      NUMBER DEFAULT NULL
, P_Project_Currency_Code      IN      VARCHAR2 DEFAULT NULL
, P_Project_Rate_Type	       IN      VARCHAR2 DEFAULT NULL
, P_Project_Rate_Date	       IN      DATE DEFAULT NULL
, P_Project_Exchange_Rate      IN      NUMBER DEFAULT NULL
, P_Project_Inv_Rate_Date      IN      DATE DEFAULT NULL
, P_Project_Inv_Exchange_Rate  IN      NUMBER DEFAULT NULL
, P_Project_Bill_Amount	       IN      NUMBER DEFAULT NULL
, P_Project_Rev_Rate_Date      IN      DATE DEFAULT NULL
, P_Project_Rev_Exchange_Rate  IN      NUMBER DEFAULT NULL
, P_Project_Revenue_Amount     IN	NUMBER DEFAULT NULL
, P_ProjFunc_Currency_Code 	IN	VARCHAR2 DEFAULT NULL
, P_ProjFunc_Rate_Type		IN 	VARCHAR2 DEFAULT NULL
, P_ProjFunc_Rate_Date		IN	DATE DEFAULT NULL
, P_ProjFunc_Exchange_Rate 	IN	NUMBER DEFAULT NULL
, P_ProjFunc_Inv_Rate_Date 	IN	DATE DEFAULT NULL
, P_ProjFunc_Inv_Exchange_Rate	IN	NUMBER DEFAULT NULL
, P_ProjFunc_Bill_Amount	IN	NUMBER DEFAULT NULL
, P_ProjFunc_Rev_Rate_Date 	IN	DATE DEFAULT NULL
, P_Projfunc_Rev_Exchange_Rate	IN	NUMBER DEFAULT NULL
, P_ProjFunc_Revenue_Amount	IN	NUMBER DEFAULT NULL
, P_Funding_Rate_Type		IN	VARCHAR2 DEFAULT NULL
, P_Funding_Rate_Date		IN	DATE DEFAULT NULL
, P_Funding_Exchange_Rate	IN	NUMBER DEFAULT NULL
, P_Invproc_Currency_Code	IN	VARCHAR2 DEFAULT NULL
, P_Invproc_Rate_Type		IN	VARCHAR2 DEFAULT NULL
, P_Invproc_Rate_Date		IN	DATE DEFAULT NULL
, P_Invproc_Exchange_Rate	IN	NUMBER DEFAULT NULL
, P_Revproc_Currency_Code	IN	VARCHAR2 DEFAULT NULL
, P_Revproc_Rate_Type		IN	VARCHAR2 DEFAULT NULL
, P_Revproc_Rate_Date		IN	DATE DEFAULT NULL
, P_Revproc_Exchange_Rate	IN	NUMBER DEFAULT NULL
, P_Inv_Gen_Rejection_Code 	IN	VARCHAR2 DEFAULT NULL
, X_Event_ID                   OUT     NOCOPY   NUMBER
, X_Event_Num                  OUT     NOCOPY   NUMBER
, X_Return_Status              OUT     NOCOPY   VARCHAR2
, X_Msg_Count                  OUT     NOCOPY   NUMBER
, X_Msg_Data                   OUT     NOCOPY   VARCHAR2
);




--
--  Name          : Update_Billing_Event
--  Pre-reqs      : None
--  Function      : This procedure updates a previously created
--                  billing event in PA
--
--
--  Parameters    :
--  IN            : P_Commit
--                  P_Deliverable_ID
--  OUT           : X_Event_ID
--                  X_Event_Num
--                  X_Return_Status
--                  X_Msg_Count
--                  X_Msg_Data
--
--  Returns       : None
--

PROCEDURE Update_Billing_Event
( P_Commit                     IN      VARCHAR2
, P_Deliverable_ID             IN      NUMBER
, P_Event_ID                   IN      NUMBER
, P_Event_Type                 IN      VARCHAR2
, P_Event_Date                 IN      DATE
, P_Project_ID                 IN      NUMBER
, P_Task_ID                    IN      NUMBER
, P_Organization_ID            IN      NUMBER
, P_Description                IN      VARCHAR2
, P_Unit_Price                 IN      NUMBER
, P_Bill_Quantity              IN      NUMBER
, P_UOM_Code                   IN      VARCHAR2
, P_Bill_Amount                IN      NUMBER
, P_Revenue_Amount             IN      NUMBER
, P_Item_ID                    IN      NUMBER
, P_Inventory_Org_ID           IN      NUMBER
, P_Contract_Num               IN      VARCHAR2
, P_Order_Num                  IN      VARCHAR2
, P_Line_Num                   IN      VARCHAR2
, P_Chg_Request_Num            IN      VARCHAR2
, P_Bill_Of_Lading             IN      VARCHAR2
, P_Serial_Num                 IN      VARCHAR2
, P_Fund_Ref1                  IN      VARCHAR2
, P_Fund_Ref2                  IN      VARCHAR2
, P_Fund_Ref3                  IN      VARCHAR2
, P_Bill_Trans_Currency_Code   IN      VARCHAR2 DEFAULT NULL
, P_Bill_Trans_Bill_Amount     IN      NUMBER DEFAULT NULL
, P_Bill_Trans_rev_Amount      IN      NUMBER DEFAULT NULL
, P_Project_Currency_Code      IN      VARCHAR2 DEFAULT NULL
, P_Project_Rate_Type	       IN      VARCHAR2 DEFAULT NULL
, P_Project_Rate_Date	       IN      DATE DEFAULT NULL
, P_Project_Exchange_Rate      IN      NUMBER DEFAULT NULL
, P_Project_Inv_Rate_Date      IN      DATE DEFAULT NULL
, P_Project_Inv_Exchange_Rate  IN      NUMBER DEFAULT NULL
, P_Project_Bill_Amount	       IN      NUMBER DEFAULT NULL
, P_Project_Rev_Rate_Date      IN      DATE DEFAULT NULL
, P_Project_Rev_Exchange_Rate  IN      NUMBER DEFAULT NULL
, P_Project_Revenue_Amount     IN	NUMBER DEFAULT NULL
, P_ProjFunc_Currency_Code 	IN	VARCHAR2 DEFAULT NULL
, P_ProjFunc_Rate_Type		IN 	VARCHAR2 DEFAULT NULL
, P_ProjFunc_Rate_Date		IN	DATE DEFAULT NULL
, P_ProjFunc_Exchange_Rate 	IN	NUMBER DEFAULT NULL
, P_ProjFunc_Inv_Rate_Date 	IN	DATE DEFAULT NULL
, P_ProjFunc_Inv_Exchange_Rate	IN	NUMBER DEFAULT NULL
, P_ProjFunc_Bill_Amount	IN	NUMBER DEFAULT NULL
, P_ProjFunc_Rev_Rate_Date 	IN	DATE DEFAULT NULL
, P_Projfunc_Rev_Exchange_Rate	IN	NUMBER DEFAULT NULL
, P_ProjFunc_Revenue_Amount	IN	NUMBER DEFAULT NULL
, P_Funding_Rate_Type		IN	VARCHAR2 DEFAULT NULL
, P_Funding_Rate_Date		IN	DATE DEFAULT NULL
, P_Funding_Exchange_Rate	IN	NUMBER DEFAULT NULL
, P_Invproc_Currency_Code	IN	VARCHAR2 DEFAULT NULL
, P_Invproc_Rate_Type		IN	VARCHAR2 DEFAULT NULL
, P_Invproc_Rate_Date		IN	DATE DEFAULT NULL
, P_Invproc_Exchange_Rate	IN	NUMBER DEFAULT NULL
, P_Revproc_Currency_Code	IN	VARCHAR2 DEFAULT NULL
, P_Revproc_Rate_Type		IN	VARCHAR2 DEFAULT NULL
, P_Revproc_Rate_Date		IN	DATE DEFAULT NULL
, P_Revproc_Exchange_Rate	IN	NUMBER DEFAULT NULL
, P_Inv_Gen_Rejection_Code 	IN	VARCHAR2 DEFAULT NULL
, X_Return_Status              OUT      NOCOPY   VARCHAR2
, X_Msg_Count                  OUT      NOCOPY  NUMBER
, X_Msg_Data                   OUT      NOCOPY  VARCHAR2
);


PROCEDURE Insert_Billing_Info
( P_Deliverable_Id		IN 	NUMBER
, P_Billing_Event_Id		IN	NUMBER
, P_Pa_Event_Id			IN	NUMBER
, P_K_Header_Id			IN	NUMBER
, P_K_Line_Id			IN	NUMBER
, P_Bill_Event_Type		IN	VARCHAR2
, P_Bill_Event_Date		IN	DATE
, P_Bill_Item_Id		IN	NUMBER
, P_Bill_Line_Id		IN	NUMBER
, P_Bill_Chg_Req_Id		IN	NUMBER
, P_Bill_Project_Id		IN	NUMBER
, P_Bill_Task_Id		IN	NUMBER
, P_Bill_Organization_Id	IN	NUMBER
, P_Bill_Fund_Ref1		IN	VARCHAR2
, P_Bill_Fund_Ref2		IN	VARCHAR2
, P_Bill_Fund_Ref3		IN	VARCHAR2
, P_Bill_Bill_Of_Lading		IN	VARCHAR2
, P_Bill_Serial_Num		IN	VARCHAR2
, P_Bill_Currency_Code		IN	VARCHAR2
, P_Bill_Rate_Type		IN	VARCHAR2
, P_Bill_Rate_Date		IN	DATE
, P_Bill_Exchange_Rate		IN	NUMBER
, P_Bill_Description		IN	VARCHAR2
, P_Bill_Quantity		IN	NUMBER
, P_Bill_Unit_Price 		IN	NUMBER
, P_Revenue_Amount		IN	NUMBER
, P_Created_By			IN	NUMBER
, P_Creation_Date		IN	DATE
, P_LAST_UPDATED_BY		IN	NUMBER
, P_LAST_UPDATE_LOGIN		IN	NUMBER
, P_LAST_UPDATE_DATE		IN	DATE
);


PROCEDURE Update_Billing_Info
( P_Deliverable_ID             IN      NUMBER
, P_Billing_Event_ID           IN      NUMBER
, P_Bill_Event_Type            IN      VARCHAR2
, P_Bill_Event_Date            IN      DATE
, P_Bill_Project_ID            IN      NUMBER
, P_Bill_Task_ID               IN      NUMBER
, P_Bill_Org_ID                IN      NUMBER
, P_Bill_Line_ID               IN      NUMBER
, P_Bill_Chg_Req_ID            IN      NUMBER
, P_Bill_Item_ID               IN      NUMBER
, P_Bill_Description           IN      VARCHAR2
, P_Bill_Unit_Price            IN      NUMBER
, P_Bill_Quantity              IN      NUMBER
, P_Bill_Currency_Code         IN      VARCHAR2
, P_Bill_Rate_Type             IN      VARCHAR2
, P_Bill_Rate_Date             IN      DATE
, P_Bill_Exchange_Rate         IN      NUMBER
, P_Revenue_Amount             IN      NUMBER
, P_Bill_Of_Lading             IN      VARCHAR2
, P_Bill_Serial_Num            IN      VARCHAR2
, P_Bill_Fund_Ref1             IN      VARCHAR2
, P_Bill_Fund_Ref2             IN      VARCHAR2
, P_Bill_Fund_Ref3             IN      VARCHAR2
, P_LAST_UPDATED_BY	       IN      NUMBER
, P_LAST_UPDATE_LOGIN	       IN      NUMBER
, P_LAST_UPDATE_DATE           IN      DATE
);

PROCEDURE Delete_Billing_Info (
  P_Billing_Event_ID           IN      NUMBER
);

PROCEDURE Populate_MC_Columns ( P_Event_ID IN NUMBER
, x_Bill_Trans_Currency_Code   OUT      NOCOPY		 VARCHAR2
, x_Bill_Trans_Bill_Amount     OUT      NOCOPY           NUMBER
, x_Bill_Trans_rev_Amount      OUT      NOCOPY           NUMBER
, x_Project_Currency_Code      OUT      NOCOPY           VARCHAR2
, x_Project_Rate_Type	       OUT      NOCOPY           VARCHAR2
, x_Project_Rate_Date	       OUT      NOCOPY           DATE
, x_Project_Exchange_Rate      OUT      NOCOPY           NUMBER
, x_Project_inv_Rate_Date      OUT      NOCOPY           DATE
, x_Project_Inv_Exchange_Rate  OUT      NOCOPY           NUMBER
, x_Project_Bill_Amount	       OUT      NOCOPY           NUMBER
, x_Project_Rev_Rate_Date      OUT      NOCOPY           DATE
, x_Project_Rev_Exchange_Rate  OUT      NOCOPY           NUMBER
, x_Project_Revenue_Amount     OUT	NOCOPY           NUMBER
, x_ProjFunc_Currency_Code 	OUT	NOCOPY           VARCHAR2
, x_ProjFunc_Rate_Type		OUT 	NOCOPY           VARCHAR2
, x_ProjFunc_Rate_Date		OUT	NOCOPY           DATE
, x_ProjFunc_Exchange_Rate 	OUT	NOCOPY           NUMBER
, x_ProjFunc_Inv_Rate_Date 	OUT	NOCOPY           DATE
, x_ProjFunc_Inv_Exchange_Rate	OUT	NOCOPY           NUMBER
, x_ProjFunc_Bill_Amount	OUT	NOCOPY           NUMBER
, x_ProjFunc_Rev_Rate_Date 	OUT	NOCOPY           DATE
, x_Projfunc_Rev_Exchange_Rate	OUT	NOCOPY           NUMBER
, x_ProjFunc_Revenue_Amount	OUT	NOCOPY           NUMBER
, x_Funding_Rate_Type		OUT	NOCOPY           VARCHAR2
, x_Funding_Rate_Date		OUT	NOCOPY           DATE
, x_Funding_Exchange_Rate	OUT	NOCOPY           NUMBER
, x_Invproc_Currency_Code	OUT	NOCOPY           VARCHAR2
, x_Invproc_Rate_Type		OUT	NOCOPY           VARCHAR2
, x_Invproc_Rate_Date		OUT	NOCOPY           DATE
, x_Invproc_Exchange_Rate	OUT	NOCOPY           NUMBER
, x_Revproc_Currency_Code	OUT	NOCOPY           VARCHAR2
, x_Revproc_Rate_Type		OUT	NOCOPY           VARCHAR2
, x_Revproc_Rate_Date		OUT	NOCOPY           DATE
, x_Revproc_Exchange_Rate	OUT	NOCOPY           NUMBER
, x_Inv_Gen_Rejection_Code 	OUT	NOCOPY           VARCHAR2  );


PROCEDURE Lock_Billing_Info
( P_Deliverable_ID             IN      NUMBER
, P_Billing_Event_ID           IN      NUMBER
, P_Bill_Event_Type            IN      VARCHAR2
, P_Bill_Event_Date            IN      DATE
, P_Bill_Project_ID            IN      NUMBER
, P_Bill_Task_ID               IN      NUMBER
, P_Bill_Org_ID                IN      NUMBER
, P_Bill_Line_ID               IN      NUMBER
, P_Bill_Chg_Req_ID            IN      NUMBER
, P_Bill_Item_ID               IN      NUMBER
, P_Bill_Description           IN      VARCHAR2
, P_Bill_Unit_Price            IN      NUMBER
, P_Bill_Quantity              IN      NUMBER
, P_Bill_Currency_Code         IN      VARCHAR2
, P_Bill_Rate_Type             IN      VARCHAR2
, P_Bill_Rate_Date             IN      DATE
, P_Bill_Exchange_Rate         IN      NUMBER
, P_Revenue_Amount             IN      NUMBER
, P_Bill_Of_Lading             IN      VARCHAR2
, P_Bill_Serial_Num            IN      VARCHAR2
, P_Bill_Fund_Ref1             IN      VARCHAR2
, P_Bill_Fund_Ref2             IN      VARCHAR2
, P_Bill_Fund_Ref3             IN      VARCHAR2
);

FUNCTION Event_Level
( P_Project_ID     IN     NUMBER
, P_Event_ID       IN     NUMBER
) RETURN VARCHAR2;

END OKE_DELIVERABLE_BILLING_PVT;

 

/
