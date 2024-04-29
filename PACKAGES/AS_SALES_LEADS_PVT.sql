--------------------------------------------------------
--  DDL for Package AS_SALES_LEADS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEADS_PVT" AUTHID CURRENT_USER as
/* $Header: asxvslms.pls 115.34 2003/01/23 02:38:36 chchandr ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEADS_PVT
-- Purpose          : Sales Leads Management
-- NOTE             :
-- History          :
--     06/05/2000 FFANG  Created.
--     06/06/2000 FFANG  Modified according data schema changes.
--     11/06/2000 FFANG  For bug 1423478, add procedure CALL_WF_TO_ASSIGN
--     12/12/2000 FFANG  For bug 1529886, add one parameter P_OPP_STATUS in
--                       create_opportunity_for_lead to get opportunity status
--                       when creating opportunity
-- End of Comments

-- Default number of records fetch per call

-- *************************
--   Validation Procedures
-- *************************

-- Item level validation procedures

/* Since this column is not required, this validation procedure
is not needed any more. ffang 05/15/00
PROCEDURE Validate_LEAD_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_NUMBER                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
*/

PROCEDURE Validate_SALES_LEAD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Sales_Lead_Id              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_CUSTOMER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );



PROCEDURE Validate_ADDRESS_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_ID		 IN   NUMBER,
    P_ADDRESS_ID                 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );




PROCEDURE Validate_STATUS_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_STATUS_CODE                IN   VARCHAR2,
    P_Sales_lead_id		 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_SOURCE_PROMOTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_PROMOTION_ID        IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_CHANNEL_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHANNEL_CODE               IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_CURRENCY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CURRENCY_CODE              IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_DECN_TIMEFRAME_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_TIMEFRAME_CODE    IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_CLOSE_REASON (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CLOSE_REASON               IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_LEAD_RANK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_RANK_ID               IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_ASSIGN_TO_PERSON_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ASSIGN_TO_PERSON_ID        IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_ASSIGN_TO_SF_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ASSIGN_TO_SALESFORCE_ID    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_BUDGET_STATUS_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_BUDGET_STATUS_CODE         IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_VEHICLE_RESPONSE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_VEHICLE_RESPONSE_CODE      IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_REJECT_REASON_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REJECT_REASON_CODE         IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_Flags (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Flag_Value                 IN   VARCHAR2,
    P_Flag_Type                  IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE Validate_STATUS_CLOSE_REASON (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_STATUS_CODE                IN   VARCHAR2,
    P_CLOSE_REASON_CODE          IN OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
/*
PROCEDURE Validate_REF_BY_REF_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REF_TYPE_CODE              IN   VARCHAR2,
    P_REF_BY_ID                  IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
*/


PROCEDURE Validate_OFFER_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_SOURCE_PROMOTION_ID    IN   NUMBER,
    P_OFFER_ID               IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );


PROCEDURE Validate_INC_PARTNER_PARTY_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_INC_PARTNER_PARTY_ID   IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_INC_PRTNR_RESOURCE_ID (
    P_Init_Msg_List           IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode         IN   VARCHAR2,
    P_INC_PARTNER_RESOURCE_ID IN   NUMBER,
    X_Item_Property_Rec       OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_PRM_EXEC_SPONSOR_FLAG (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_PRM_EXEC_SPONSOR_FLAG  IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_PRM_PRJ_LDINPLE_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRM_PRJ_LEAD_IN_PLACE_FLAG IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_PRM_LEAD_TYPE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_PRM_LEAD_TYPE          IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_PRM_IND_CLS_CODE (
    P_Init_Msg_List               IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode             IN   VARCHAR2,
    P_PRM_IND_CLASSIFICATION_CODE IN   VARCHAR2,
    X_Item_Property_Rec           OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status               OUT NOCOPY  VARCHAR2,
    X_Msg_Count                   OUT NOCOPY  NUMBER,
    X_Msg_Data                    OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_PRM_ASSIGNMENT_TYPE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_PRM_ASSIGNMENT_TYPE    IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_AUTO_ASSIGNMENT_TYPE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_AUTO_ASSIGNMENT_TYPE   IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );





-- Record level validation procedures


--  Inter-record level validation

PROCEDURE Validate_Budget_Amounts(
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_SALES_LEAD_ID              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


--  validation procedures

PROCEDURE Validate_sales_lead(
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_SALES_LEAD_Rec             IN OUT NOCOPY  AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type,
    P_Referral_type		 IN   VARCHAR2,
    P_Referred_By		 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


-- **************************
--   Sales Lead Header APIs
-- **************************

--   API Name:  Create_sales_lead

PROCEDURE Create_sales_lead(
    P_Api_Version_Number     IN  NUMBER,
    P_Init_Msg_List          IN  VARCHAR2   := FND_API.G_FALSE,
    P_Commit                 IN  VARCHAR2   := FND_API.G_FALSE,
    P_Validation_Level       IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag      IN  VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Flag             IN  VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id         IN  NUMBER     := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN  NUMBER     := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl IN  AS_UTILITY_PUB.Profile_Tbl_Type
                                  := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec         IN  AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                                  := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC,
    P_SALES_LEAD_LINE_tbl    IN  AS_SALES_LEADS_PUB.SALES_LEAD_LINE_tbl_type
                           := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_LINE_tbl,
    P_SALES_LEAD_CONTACT_Tbl IN  AS_SALES_LEADS_PUB.SALES_LEAD_CONTACT_Tbl_Type
                           := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_CONTACT_Tbl,
    X_SALES_LEAD_ID          OUT NOCOPY NUMBER,
    X_SALES_LEAD_LINE_OUT_Tbl OUT
                           AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_Type,
    X_SALES_LEAD_CNT_OUT_tbl OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_CNT_OUT_tbl_Type,
    X_Return_Status          OUT NOCOPY VARCHAR2,
    X_Msg_Count              OUT NOCOPY NUMBER,
    X_Msg_Data               OUT NOCOPY VARCHAR2
    );


--   API Name:  Update_sales_lead

PROCEDURE Update_sales_lead(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    P_Validation_Level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                       := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec             IN   AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type,
    -- P_Calling_From_WF_Flag	 IN   VARCHAR2 := 'N',
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

/*
--   API Name:  Delete_sales_lead

PROCEDURE Delete_sales_lead(
    P_Api_Version_Number IN   NUMBER,
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit             IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level   IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag  IN  VARCHAR2      := FND_API.G_MISS_CHAR,
    P_Admin_Flag         IN  VARCHAR2      := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id     IN  NUMBER        := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl  IN  AS_UTILITY_PUB.Profile_Tbl_Type
                                   := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID      IN   NUMBER,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    );
*/

/*
This function is decomissioned

FUNCTION IS_LEAD_QUALIFIED(
    P_Sales_lead_rec     IN AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                             := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC,
    P_phone_id           IN NUMBER := FND_API.G_MISS_NUM,
    P_contact_role_code  IN VARCHAR2 := FND_API.G_MISS_CHAR
    ) RETURN VARCHAR;
*/

End AS_SALES_LEADS_PVT;

 

/
