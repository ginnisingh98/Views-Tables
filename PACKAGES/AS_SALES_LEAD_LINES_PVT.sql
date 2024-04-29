--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_LINES_PVT" AUTHID CURRENT_USER as
/* $Header: asxvslls.pls 115.6 2004/03/29 23:01:32 chchandr ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_LINES_PVT
-- Purpose          : Sales Leads Lines
-- NOTE             :
-- History          :
--     03/29/2001 FFANG  Created.
--
-- End of Comments


-- *************************
--   Validation Procedures
-- *************************

-- Item level validation procedures

/*
PROCEDURE Validate_INTEREST_TYPE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID           IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_PRIM_INT_CODE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID           IN   NUMBER,
    P_PRIMARY_INTEREST_CODE_ID   IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_SEC_INT_CODE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID           IN   NUMBER,
    P_PRIMARY_INTEREST_CODE_ID   IN   NUMBER,
    P_SECONDARY_INTEREST_CODE_ID IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
*/

PROCEDURE Validate_INV_ORG_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INVENTORY_ITEM_ID          IN   NUMBER,
    P_ORGANIZATION_ID            IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_UOM_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_UOM_CODE                   IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );




PROCEDURE Validate_Category_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Category_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE Validate_Category_Set_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Category_Set_ID            IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );



-- Record level validation procedures

PROCEDURE Validate_Intrst_Type_Sec_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID           IN   NUMBER,
    P_PRIMARY_INTEREST_CODE_ID   IN   NUMBER,
    P_SECONDARY_INTEREST_CODE_ID IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_INVENT_INTRST(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID           IN   NUMBER,
    P_INVENTORY_ITEM_ID          IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


--  Inter-record level validation
/*
PROCEDURE Validate_Budget_Amounts(
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_SALES_LEAD_ID              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
*/

--  validation procedures

PROCEDURE Validate_sales_lead_line(
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode          IN   VARCHAR2,
    P_SALES_LEAD_LINE_Rec      IN   AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Rec_Type,
    X_Return_Status            OUT NOCOPY  VARCHAR2,
    X_Msg_Count                OUT NOCOPY  NUMBER,
    X_Msg_Data                 OUT NOCOPY  VARCHAR2
    );



-- ************************
--   Sales Lead Line APIs
-- ************************

--   API Name:  Create_sales_lead_lines

PROCEDURE Create_sales_lead_lines(
    P_Api_Version_Number        IN   NUMBER,
    P_Init_Msg_List             IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                    IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag         IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id            IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id    IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl    IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                       := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl       IN   AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Tbl_Type
                               := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_LINE_Tbl,
    P_SALES_LEAD_ID             IN   NUMBER,
    X_SALES_LEAD_LINE_OUT_Tbl   OUT NOCOPY
                               AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status             OUT NOCOPY  VARCHAR2,
    X_Msg_Count                 OUT NOCOPY  NUMBER,
    X_Msg_Data                  OUT NOCOPY  VARCHAR2
    );


--   API Name:  Update_sales_lead_lines

PROCEDURE Update_sales_lead_lines(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag        IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag               IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id           IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id   IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl   IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                       := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl      IN   AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Tbl_Type,
    X_SALES_LEAD_LINE_OUT_Tbl  OUT NOCOPY
                                AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status            OUT NOCOPY  VARCHAR2,
    X_Msg_Count                OUT NOCOPY  NUMBER,
    X_Msg_Data                 OUT NOCOPY  VARCHAR2
    );


--   API Name:  Delete_sales_lead_lines

PROCEDURE Delete_sales_lead_lines(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag        IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag               IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id           IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id   IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl   IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                     := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl      IN   AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Tbl_Type,
    X_SALES_LEAD_LINE_OUT_Tbl  OUT NOCOPY
                                AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status            OUT NOCOPY  VARCHAR2,
    X_Msg_Count                OUT NOCOPY  NUMBER,
    X_Msg_Data                 OUT NOCOPY  VARCHAR2
    );


End AS_SALES_LEAD_LINES_PVT;

 

/
