--------------------------------------------------------
--  DDL for Package CSP_AUTO_ASLMSL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_AUTO_ASLMSL_PVT" AUTHID CURRENT_USER as
/* $Header: cspvasls.pls 120.0 2005/05/24 19:13:53 appldev noship $ */
-- Start of Comments
-- Package name     : CSP_AUTO_ASLMSL_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:CSP_ASLMSL_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    USAGE_DETAILS_ID
--    USAGE_HEADER_ID
--    USAGE_FORECAST_PERIOD
--    DETAILS_DATA_TYPE
--    USAGE_FORECAST_QUANTITY
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE CSP_Date_Rec_Type IS RECORD
(
       TRANSACTION_DATE_START          DATE ,
       TRANSACTION_DATE_END            DATE
);

G_MISS_CSP_DATE_REC      CSP_Date_Rec_Type;

TYPE CSP_Supply_Chain_Rec_Type IS RECORD
(
       INVENTORY_ITEM_ID           NUMBER      ,
       SOURCE_TYPE                 NUMBER     ,
       SOURCE_ORGANIZATION 		NUMBER,
       SOURCE_SUBINVENTORY         VARCHAR2(10),
	  PARENT_SUPPLY_CHAIN_ID	NUMBER
);

G_MISS_SUPPLY_CHAIN_REC CSP_Supply_Chain_Rec_Type;

TYPE CSP_Usage_Key_Rec_Type IS RECORD
(
	INVENTORY_ITEM_ID			NUMBER,
	ORGANIZATION_ID			NUMBER,
	SUBINVENTORY 			     VARCHAR2(10)
);

G_MISS_USAGE_KEY_REC CSP_Supply_Chain_Rec_Type;

TYPE CSP_Forecast_Rec_Type IS RECORD
(
	PLANNING_PARAMETERS_ID		NUMBER		,
	ORGANIZATION_TYPE		VARCHAR2(1) ,
   	FORECAST_RULE_ID 		NUMBER	,
	FORECAST_METHOD			VARCHAR2(30),
	FORECAST_PERIODS		NUMBER	,
	HISTORY_PERIODS			NUMBER,
	ACTUAL_HISTORY_PERIODS		NUMBER	,
	PERIOD_TYPE			VARCHAR2(30)	,
	PERIOD_SIZE			NUMBER,
	ALPHA				NUMBER,
	BETA				NUMBER		,
	WEIGHTED_AVG_PERIOD1		NUMBER	,
	WEIGHTED_AVG_PERIOD2		NUMBER,
	WEIGHTED_AVG_PERIOD3		NUMBER,
	WEIGHTED_AVG_PERIOD4		NUMBER,
	WEIGHTED_AVG_PERIOD5		NUMBER,
	WEIGHTED_AVG_PERIOD6		NUMBER,
	WEIGHTED_AVG_PERIOD7		NUMBER,
	WEIGHTED_AVG_PERIOD8		NUMBER,
	WEIGHTED_AVG_PERIOD9		NUMBER,
	WEIGHTED_AVG_PERIOD10		NUMBER,
	WEIGHTED_AVG_PERIOD11		NUMBER,
	WEIGHTED_AVG_PERIOD12		NUMBER
);


TYPE  CSP_Date_Tbl_Type IS TABLE OF CSP_Date_Rec_Type
                                    INDEX BY BINARY_INTEGER;

TYPE  CSP_Supply_Chain_Tbl_Type IS TABLE OF CSP_Supply_Chain_Rec_Type
							 INDEX BY BINARY_INTEGER;

TYPE  CSP_Usage_Key_Tbl_Type IS TABLE OF CSP_Usage_Key_Rec_Type;

TYPE  CSP_Qty_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


G_HISTORY_REQUEST_TYPE   VARCHAR2(10) := 'HISTORY';
G_FORECAST_REQUEST_TYPE  VARCHAR2(10) := 'FORECAST';
G_USAGE_HISTORIES		VARCHAR2(100) := 'CSP_USAGE_HISTORIES';
G_USAGE_HEADER			VARCHAR2(100) := 'CSP_USAGE_HEADERS';
G_SUPPLY_CHAIN			VARCHAR2(100) := 'CSP_SUPPLY_CHAIN';


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Generate_Recommendations
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number         IN NUMBER
--   P_level_id	  		  IN VARCHAR2 DEFAULT NULL
--
--   OUT:
--    retcode				   OUT NOCOPY NUMBER
--    errbuf				   OUT NOCOPY VARCHAR2
--    Version : Current version 1.0
---
---- End of Comments

PROCEDURE Generate_Recommendations (
    retcode				   OUT NOCOPY NUMBER,
    errbuf				   OUT NOCOPY VARCHAR2,
    P_Api_Version_Number         	   IN  NUMBER,
    p_level_id		   		   IN VARCHAR2 DEFAULT NULL);


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Purge_Planning_Data
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number         IN   NUMBER,
--   P_Init_Msg_List              IN   VARCHAR2
--   P_Commit                     IN   VARCHAR2
--   p_validation_level           IN   NUMBER
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
---
---- End of Comments

PROCEDURE Purge_Planning_Data (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    ,
    P_Commit                     IN   VARCHAR2   ,
    P_validation_level           IN   NUMBER    ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Usage
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number         IN   NUMBER,
--
--   OUT:
--       retcode               OUT NOCOPY  NUMBER
--       errbuf                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
---
---- End of Comments

PROCEDURE Create_Usage (
    retcode                  	 OUT NOCOPY  NUMBER,
    errbuf                   	 OUT NOCOPY  VARCHAR2,
    P_Api_Version_Number         IN   NUMBER);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Supply_Chain
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number         IN   NUMBER,
--   P_Init_Msg_List              IN   VARCHAR2
--   P_Commit                     IN   VARCHAR2
--   p_validation_level           IN   NUMBER
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
---
---- End of Comments
PROCEDURE Create_Supply_Chain (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2 ,
    P_Commit                     IN   VARCHAR2   ,
    P_validation_level           IN   NUMBER    ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Create_Supply_Chain (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   ,
    P_Commit                     IN   VARCHAR2  ,
    P_validation_level           IN   NUMBER   ,
    P_Level_id			 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Usage_History
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   p_Api_Version_Number         IN   NUMBER,
--   p_Init_Msg_List              IN   VARCHAR2
--   P_Commit                     IN   VARCHAR2
--   p_validation_level           IN   NUMBER
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
---
---- End of Comments

PROCEDURE Create_Usage_History (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2  ,
    P_Commit                     IN   VARCHAR2 ,
    p_validation_level           IN   NUMBER  ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Usage_rollup
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number         IN   NUMBER,
--
--   OUT:
--       retcode              OUT NOCOPY  NUMBER
--       errbuf               OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments

PROCEDURE Create_Usage_Rollup (
    retcode				   OUT NOCOPY NUMBER,
    errbuf				   OUT NOCOPY VARCHAR2,
    P_Api_Version_Number         	   IN  NUMBER);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Calculate_Forecast
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number         IN   NUMBER,
--   P_Init_Msg_List              IN   VARCHAR2
--   P_Commit                     IN   VARCHAR2
--   p_validation_level           IN   NUMBER
--   p_Level_Id	 		 IN   VARCHAR2
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments

PROCEDURE Calculate_Forecast (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2 ,
    P_validation_level           IN   NUMBER,
    P_Level_Id	 		 IN   VARCHAR2,
    P_Reason_Code		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Calculate_Product_norm
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number         IN   NUMBER,
--   P_Init_Msg_List              IN   VARCHAR2
--   P_Commit                     IN   VARCHAR2
--   p_validation_level           IN   NUMBER
--   p_Level_Id	 		 IN   VARCHAR2
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments

PROCEDURE Calculate_product_norm (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2  ,
    P_Commit                     IN   VARCHAR2 ,
    P_validation_level           IN   NUMBER  ,
    P_Level_Id	 		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Calculate_Territory_Norm
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number         IN   NUMBER,
--   P_Init_Msg_List              IN   VARCHAR2
--   P_Commit                     IN   VARCHAR2
--   p_validation_level           IN   NUMBER
--   p_Level_Id	 		 IN   VARCHAR2
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments

PROCEDURE Calculate_Territory_Norm (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2 ,
    P_Commit                     IN   VARCHAR2,
    P_validation_level           IN   NUMBER ,
    P_Level_Id	 		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Calculate_New_Product_Planning
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number         IN   NUMBER,
--   P_Init_Msg_List              IN   VARCHAR2
--   P_Commit                     IN   VARCHAR2
--   p_validation_level           IN   NUMBER
--   p_Level_Id	 		 IN   VARCHAR2
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments

PROCEDURE Calculate_New_Product_Planning (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    ,
    P_Commit                     IN   VARCHAR2   ,
    P_validation_level           IN   NUMBER    ,
    P_Level_Id	 		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Calculate_Needby_date
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number         IN   NUMBER,
--   P_Init_Msg_List              IN   VARCHAR2
--   P_Commit                     IN   VARCHAR2
--   p_validation_level           IN   NUMBER
--   p_Level_Id	 		 IN   VARCHAR2
--
--   OUT:
--	 x_needby_date		   OUT NOCOPY  DATE
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments

PROCEDURE Calculate_Needby_date (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_validation_level           IN   NUMBER  ,
    P_inventory_item_id	 	 IN   NUMBER,
    P_Organization_id	 	 IN   NUMBER,
    P_Onhand_Quantity		 IN   NUMBER,
    X_Needby_date		 OUT NOCOPY  DATE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Apply_Business_Rules (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End CSP_AUTO_ASLMSL_PVT;

 

/
