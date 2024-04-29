--------------------------------------------------------
--  DDL for Package AS_SALES_LEADS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEADS_PUB" AUTHID CURRENT_USER as
/* $Header: asxpslms.pls 120.2 2006/06/28 21:30:19 solin noship $ */
/*#
 * This package provides methods to create, update, or delete leads, lead product
 * interests, and lead contacts for Oracle Leads Management.
 * @rep:scope public
 * @rep:product AMS
 * @rep:lifecycle active
 * @rep:displayname Oracle Leads Management Public API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY AMS_LEAD
 */

-- Start of Comments
-- Package name     : AS_SALES_LEADS_PUB
-- Purpose          : Sales Leads Management
-- NOTE             :
-- History          :
--     06/05/2000 FFANG  Created.
--                       creating opportunity
--     12/12/2000 FFANG  For bug 1529886, add one parameter P_OPP_STATUS in
--                       create_opportunity_for_lead to get opportunity status
--                       when creating opportunity
--     06/05/2001 SOLIN  Add API Build_Lead_Sales_Team and
--                       Rebuild_Lead_Sales_Team.
--     12/10/2001 SOLIN  Bug 2102901.
--                       Add salesgroup_id for current user in
--                       Build_Lead_Sales_Team and Rebuild_Lead_Sales_Team
--     03/20/2002 SOLIN  Add LEAD_ENGINES_OUT_Rec_Type.
--                       Add API Start_Partner_Matching.
--     03/26/2002 AJOY   Add Route_Lead_To_Marketing API for assigning to
--                       marketing owner for the lead that does not have owner.
--     08/06/2002 SOLIN  Comment out API Get_Potential_Opportunity because
--                       it's moved to package AS_LINK_LEAD_OPP_PUB.
--     11/04/2002 SOLIN  Add API Lead_Process_After_Create and
--                       Lead_Process_After_Update
--     12/17/2003 SOLIN  ER 3322617, extend length from 30 to 240 for the
--                       columns SOURCE_PRIMARY_REFERENCE and
--                       SOURCE_SECONDARY_REFERENCE
--
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:SALES_LEAD_Rec_Type
--   -------------------------------------------------------

TYPE SALES_LEAD_Rec_Type IS RECORD
(
       SALES_LEAD_ID                   NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       LEAD_NUMBER                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       STATUS_CODE                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CUSTOMER_ID                     NUMBER := FND_API.G_MISS_NUM,
       ADDRESS_ID                      NUMBER := FND_API.G_MISS_NUM,
       SOURCE_PROMOTION_ID             NUMBER := FND_API.G_MISS_NUM,
       INITIATING_CONTACT_ID           NUMBER := FND_API.G_MISS_NUM,
       ORIG_SYSTEM_REFERENCE           VARCHAR2(240) := FND_API.G_MISS_CHAR,
       CONTACT_ROLE_CODE               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CHANNEL_CODE                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       BUDGET_AMOUNT                   NUMBER := FND_API.G_MISS_NUM,
       CURRENCY_CODE                   VARCHAR2(15) := FND_API.G_MISS_CHAR,
       DECISION_TIMEFRAME_CODE         VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CLOSE_REASON                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       LEAD_RANK_ID                    NUMBER := FND_API.G_MISS_NUM,
       LEAD_RANK_CODE                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PARENT_PROJECT                  VARCHAR2(80) := FND_API.G_MISS_CHAR,
       DESCRIPTION                     VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ASSIGN_TO_PERSON_ID             NUMBER := FND_API.G_MISS_NUM,
	  ASSIGN_TO_SALESFORCE_ID         NUMBER := FND_API.G_MISS_NUM,
       ASSIGN_SALES_GROUP_ID           NUMBER := FND_API.G_MISS_NUM,
       ASSIGN_DATE                     DATE := FND_API.G_MISS_DATE,
       BUDGET_STATUS_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ACCEPT_FLAG                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       VEHICLE_RESPONSE_CODE           VARCHAR2(30) := FND_API.G_MISS_CHAR,
       TOTAL_SCORE                     NUMBER := FND_API.G_MISS_NUM,
       SCORECARD_ID                    NUMBER := FND_API.G_MISS_NUM,
       KEEP_FLAG                       VARCHAR2(1) := FND_API.G_MISS_CHAR,
       URGENT_FLAG                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       IMPORT_FLAG                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       REJECT_REASON_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       DELETED_FLAG                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       OFFER_ID                        NUMBER := FND_API.G_MISS_NUM,
--     SECURITY_GROUP_ID               NUMBER := FND_API.G_MISS_NUM,
       INCUMBENT_PARTNER_PARTY_ID      NUMBER := FND_API.G_MISS_NUM,
       INCUMBENT_PARTNER_RESOURCE_ID   NUMBER := FND_API.G_MISS_NUM,
       PRM_EXEC_SPONSOR_FLAG           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       PRM_PRJ_LEAD_IN_PLACE_FLAG      VARCHAR2(1) := FND_API.G_MISS_CHAR,
       PRM_SALES_LEAD_TYPE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PRM_IND_CLASSIFICATION_CODE     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QUALIFIED_FLAG                  VARCHAR2(1) := FND_API.G_MISS_CHAR,
       ORIG_SYSTEM_CODE                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PRM_ASSIGNMENT_TYPE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       AUTO_ASSIGNMENT_TYPE            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PRIMARY_CONTACT_PARTY_ID      NUMBER := FND_API.G_MISS_NUM,

-- new columns added for bug 2098158
       PRIMARY_CNT_PERSON_PARTY_ID	     NUMBER := FND_API.G_MISS_NUM,
       PRIMARY_CONTACT_PHONE_ID	     NUMBER := FND_API.G_MISS_NUM,

-- new columns added for CAPRI lead referral

       REFERRED_BY    		     NUMBER := FND_API.G_MISS_NUM,
       REFERRAL_TYPE    	     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       REFERRAL_STATUS    	     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       REF_DECLINE_REASON    	     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       REF_COMM_LTR_STATUS           VARCHAR2(30) := FND_API.G_MISS_CHAR,
       REF_ORDER_NUMBER    	     NUMBER := FND_API.G_MISS_NUM,
       REF_ORDER_AMT    	     NUMBER := FND_API.G_MISS_NUM,
       REF_COMM_AMT    		     NUMBER := FND_API.G_MISS_NUM,
-- bug No.2341515, 2368075
       LEAD_DATE		     DATE := FND_API.G_MISS_DATE,
       SOURCE_SYSTEM		     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       COUNTRY			     VARCHAR2(30) := FND_API.G_MISS_CHAR,


-- 11.5.9
	TOTAL_AMOUNT    	     NUMBER := FND_API.G_MISS_NUM,
	EXPIRATION_DATE			DATE := FND_API.G_MISS_DATE,
	LEAD_ENGINE_RUN_DATE		DATE := FND_API.G_MISS_DATE,
	LEAD_RANK_IND    	     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       	CURRENT_REROUTES             NUMBER := FND_API.G_MISS_NUM
	  -- 11.5.10 new columns ckapoor
	, MARKETING_SCORE	NUMBER := FND_API.G_MISS_NUM
	, INTERACTION_SCORE	NUMBER  := FND_API.G_MISS_NUM
          -- ER 3322617, extend length from 30 to 240 for the following two
          -- columns
	, SOURCE_PRIMARY_REFERENCE	VARCHAR2(240)  := FND_API.G_MISS_CHAR
	, SOURCE_SECONDARY_REFERENCE	VARCHAR2(240)  := FND_API.G_MISS_CHAR

	, SALES_METHODOLOGY_ID		NUMBER  := FND_API.G_MISS_NUM
	, SALES_STAGE_ID		NUMBER  := FND_API.G_MISS_NUM
       );

G_MISS_SALES_LEAD_REC          SALES_LEAD_Rec_Type;

TYPE  SALES_LEAD_Tbl_Type      IS TABLE OF SALES_LEAD_Rec_Type
                                    INDEX BY BINARY_INTEGER;

G_MISS_SALES_LEAD_TBL          SALES_LEAD_Tbl_Type;


--   -------------------------------------------------------
--    Record name:SALES_LEAD_LINE_Rec_Type
--   -------------------------------------------------------

TYPE SALES_LEAD_LINE_Rec_Type IS RECORD
(
       SALES_LEAD_LINE_ID              NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       SALES_LEAD_ID                   NUMBER := FND_API.G_MISS_NUM,
       STATUS_CODE                     VARCHAR2(30) := FND_API.G_MISS_CHAR,

       -- 11.5.10 Rivendell product category changes

       --INTEREST_TYPE_ID                NUMBER := FND_API.G_MISS_NUM,
       --PRIMARY_INTEREST_CODE_ID        NUMBER := FND_API.G_MISS_NUM,
       --SECONDARY_INTEREST_CODE_ID      NUMBER := FND_API.G_MISS_NUM,

       CATEGORY_ID		       NUMBER := FND_API.G_MISS_NUM,
       CATEGORY_SET_ID		       NUMBER := FND_API.G_MISS_NUM,


       INVENTORY_ITEM_ID               NUMBER := FND_API.G_MISS_NUM,
       ORGANIZATION_ID                 NUMBER := FND_API.G_MISS_NUM,
       UOM_CODE                        VARCHAR2(3) := FND_API.G_MISS_CHAR,
       QUANTITY                        NUMBER := FND_API.G_MISS_NUM,
       BUDGET_AMOUNT                   NUMBER := FND_API.G_MISS_NUM,
       SOURCE_PROMOTION_ID             NUMBER := FND_API.G_MISS_NUM,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       OFFER_ID                        NUMBER        := FND_API.G_MISS_NUM
--     SECURITY_GROUP_ID               NUMBER        := FND_API.G_MISS_NUM
       );

G_MISS_SALES_LEAD_LINE_REC          SALES_LEAD_LINE_Rec_Type;

TYPE  SALES_LEAD_LINE_Tbl_Type      IS TABLE OF SALES_LEAD_LINE_Rec_Type
                                    INDEX BY BINARY_INTEGER;

G_MISS_SALES_LEAD_LINE_TBL          SALES_LEAD_LINE_Tbl_Type;

--   -------------------------------------------------------
--    Record name:SALES_LEAD_LINE_OUT_Rec_Type
--   -------------------------------------------------------

TYPE SALES_LEAD_LINE_OUT_Rec_Type   IS RECORD
(
        SALES_LEAD_LINE_ID             NUMBER,
        RETURN_STATUS                  VARCHAR2(1)
);

TYPE SALES_LEAD_LINE_OUT_Tbl_Type   IS TABLE OF SALES_LEAD_LINE_OUT_Rec_Type
                    		    INDEX BY BINARY_INTEGER;

--   -------------------------------------------------------
--    Record name:SALES_LEAD_CONTACT_Rec_Type
--   -------------------------------------------------------

TYPE SALES_LEAD_CONTACT_Rec_Type IS RECORD
(
       LEAD_CONTACT_ID                 NUMBER := FND_API.G_MISS_NUM,
       SALES_LEAD_ID                   NUMBER := FND_API.G_MISS_NUM,
       CONTACT_ID                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       ENABLED_FLAG                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       RANK                            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CUSTOMER_ID                     NUMBER := FND_API.G_MISS_NUM,
       ADDRESS_ID                      NUMBER := FND_API.G_MISS_NUM,
       PHONE_ID                        NUMBER := FND_API.G_MISS_NUM,
       CONTACT_ROLE_CODE               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PRIMARY_CONTACT_FLAG            VARCHAR2(1) := FND_API.G_MISS_CHAR,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
--     SECURITY_GROUP_ID               NUMBER := FND_API.G_MISS_NUM,
       CONTACT_PARTY_ID                NUMBER := FND_API.G_MISS_NUM
       );

G_MISS_SALES_LEAD_CONTACT_REC          SALES_LEAD_CONTACT_Rec_Type;

TYPE  SALES_LEAD_CONTACT_Tbl_Type      IS TABLE OF SALES_LEAD_CONTACT_Rec_Type
                                       INDEX BY BINARY_INTEGER;

G_MISS_SALES_LEAD_CONTACT_TBL          SALES_LEAD_CONTACT_Tbl_Type;

--   -------------------------------------------------------
--    Record name:SALES_LEAD_CNT_OUT_Rec_Type
--   -------------------------------------------------------

TYPE SALES_LEAD_CNT_OUT_Rec_Type   IS RECORD
(
        LEAD_CONTACT_ID                NUMBER,
        RETURN_STATUS                  VARCHAR2(1)
);

TYPE SALES_LEAD_CNT_OUT_Tbl_Type   IS TABLE OF SALES_LEAD_CNT_OUT_Rec_Type
                    		   INDEX BY BINARY_INTEGER;

--   -------------------------------------------------------
--    Record name:Assign_Id_Rec_Type
--   -------------------------------------------------------

Type Assign_Id_Rec_Type  Is Record (
     Resource_Id    NUMBER,
     Sales_Group_Id NUMBER);

Assign_Id_Rec       Assign_Id_Rec_Type;

Type Assign_Id_Tbl_Type  Is TABLE OF Assign_Id_Rec_Type
                                    INDEX BY BINARY_INTEGER;

--   -------------------------------------------------------
--    Record name:LEAD_ENGINES_OUT_Rec_Type
--   -------------------------------------------------------

TYPE LEAD_ENGINES_OUT_Rec_Type   IS RECORD
(
       qualified_flag                 VARCHAR2(1),
       lead_rank_id                   NUMBER,
       channel_code                   VARCHAR2(30),
       indirect_channel_flag          VARCHAR2(1),
       sales_team_flag                VARCHAR2(1)
);

--   -------------------------------------------------------
--    Record name:AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL
--   -------------------------------------------------------

--
--   API Name:  Create_sales_leads
--
PROCEDURE Create_sales_lead(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag      IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag             IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id         IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec         IN   SALES_LEAD_Rec_Type  := G_MISS_SALES_LEAD_REC,
    P_SALES_LEAD_LINE_tbl    IN   SALES_LEAD_LINE_tbl_type
                                     DEFAULT G_MISS_SALES_LEAD_LINE_tbl,
    P_SALES_LEAD_CONTACT_tbl IN   SALES_LEAD_CONTACT_tbl_type
                                     DEFAULT G_MISS_SALES_LEAD_CONTACT_tbl,
    X_SALES_LEAD_ID          OUT NOCOPY  NUMBER,
    X_SALES_LEAD_LINE_OUT_Tbl OUT NOCOPY SALES_LEAD_LINE_OUT_Tbl_Type,
    X_SALES_LEAD_CNT_OUT_Tbl OUT NOCOPY  SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );

--
--   API Name:  Update_sales_leads
--

/*#
 * This procedure updates a lead. The details of lead will be passed in p_sales_lead_rec.
 * Check x_return_status output to see if creation was successful.
 * @param p_api_version_number API version
 * @param p_init_msg_list Initialize message list
 * @param p_commit Commit after update
 * @param p_validation_level Validation level for the record details
 * @param p_check_access_flag Check access flag
 * @param p_admin_flag Admin flag to denote admin responsibility
 * @param p_admin_group_id Admin group id
 * @param p_identity_salesforce_id Salesforce_id of the lead creator
 * @param p_sales_lead_profile_tbl Table containing profile values for sales lead
 * @param p_sales_lead_rec Record containing leads attributes
 * @param x_return_status Return status of the create operation
 * @param x_msg_count Number of the error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Sales Lead
 */
PROCEDURE Update_sales_lead(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag      IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag             IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id         IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec         IN   SALES_LEAD_Rec_Type
                                      DEFAULT G_MISS_SALES_LEAD_REC,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );

/*
--
--   API Name:  Delete_sales_leads
--
PROCEDURE Delete_sales_lead(
    P_Api_Version_Number IN   NUMBER,
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit             IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level   IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag  IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag         IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id     IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID      IN   NUMBER,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    );
*/

-- Start Sales_Lead_Line part
--
--   API Name:  Create_sales_lead_lines
--

/*#
 * This procedure creates lead product interests. The details of lead product interests
 * will be passed in p_sales_lead_line_tbl. Check x_return_status output to see if creation
 * was successful.
 * @param p_api_version_number API version
 * @param p_init_msg_list Initialize message list
 * @param p_commit Commit after update
 * @param p_validation_level Validation level for the record details
 * @param p_check_access_flag Check access flag
 * @param p_admin_flag Admin flag to denote admin responsibility
 * @param p_admin_group_id Admin group id
 * @param p_identity_salesforce_id Salesforce_id of the lead creator
 * @param p_sales_lead_profile_tbl Table containing profile values for sales lead
 * @param p_sales_lead_line_tbl Table containing lead lines records
 * @param p_sales_lead_id Sales Lead Id in which lead lines to be created
 * @param x_sales_lead_line_out_tbl Generated Sales Lead Line Id
 * @param x_return_status Return status of the create operation
 * @param x_msg_count Number of the error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Sales Lead Lines
 */
PROCEDURE Create_sales_lead_lines(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag              IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id          IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl  IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl     IN   SALES_LEAD_LINE_Tbl_Type
                                                := G_MISS_SALES_LEAD_LINE_Tbl,
    P_SALES_LEAD_ID           IN   NUMBER,
    X_SALES_LEAD_LINE_OUT_Tbl OUT NOCOPY  SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    );

--
--   API Name:  Update_sales_lead_lines
--

/*#
 * This procedure updates lead product interests. The details of lead product interests
 * will be passed in p_sales_lead_line_tbl. Check x_return_status output to see if the update
 * was successful.
 * @param p_api_version_number API version
 * @param p_init_msg_list Initialize message list
 * @param p_commit Commit after update
 * @param p_validation_level Validation level for the record details
 * @param p_check_access_flag Check access flag
 * @param p_admin_flag Admin flag to denote admin responsibility
 * @param p_admin_group_id Admin group id
 * @param p_identity_salesforce_id Salesforce_id of the lead creator
 * @param p_sales_lead_profile_tbl Table containing profile values for sales lead
 * @param p_sales_lead_line_tbl Table containing lead lines records
 * @param x_sales_lead_line_out_tbl Generated Sales Lead Line Id
 * @param x_return_status Return status of the update operation
 * @param x_msg_count Number of the error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Sales Lead Lines
 */
PROCEDURE Update_sales_lead_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER     := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER     := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl        IN   SALES_LEAD_LINE_Tbl_Type,
    X_SALES_LEAD_LINE_OUT_Tbl    OUT NOCOPY  SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--
--   API Name:  Delete_sales_lead_lines
--

/*#
 * This procedure deletes lead product interests. The details of lead product interests
 * will be passed in p_sales_lead_line_tbl. Check x_return_status output to see if deletion
 * was successful.
 * @param p_api_version_number API version
 * @param p_init_msg_list Initialize message list
 * @param p_commit Commit after update
 * @param p_validation_level Validation level for the record details
 * @param p_check_access_flag Check access flag
 * @param p_admin_flag Admin flag to denote admin responsibility
 * @param p_admin_group_id Admin group id
 * @param p_identity_salesforce_id Salesforce_id of the lead creator
 * @param p_sales_lead_profile_tbl Table containing profile values for sales lead
 * @param p_sales_lead_line_tbl Table containing lead lines records
 * @param x_sales_lead_line_out_tbl Generated Sales Lead Line Id
 * @param x_return_status Return status of the delete operation
 * @param x_msg_count Number of the error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Sales Lead Lines
 */
PROCEDURE Delete_sales_lead_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER     := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER     := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl        IN   SALES_LEAD_LINE_Tbl_type,
    X_SALES_LEAD_LINE_OUT_Tbl    OUT NOCOPY  SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


-- Start Sales_Lead_Contact part
--
--   API Name:  Create_sales_lead_contact
--

/*#
 * This procedure creates lead contacts. The details of lead contacts will be passed in
 * p_sales_lead_contact_tbl. Check x_return_status output to see if creation was successful.
 * @param p_api_version_number API version
 * @param p_init_msg_list Initialize message list
 * @param p_commit Commit after update
 * @param p_validation_level Validation level for the record details
 * @param p_check_access_flag Check access flag
 * @param p_admin_flag Admin flag to denote admin responsibility
 * @param p_admin_group_id Admin group id
 * @param p_identity_salesforce_id Salesforce_id of the lead creator
 * @param p_sales_lead_profile_tbl Table containing profile values for sales lead
 * @param p_sales_lead_contact_tbl Table containing lead contacts records
 * @param p_sales_lead_id Sales Lead Id
 * @param x_sales_lead_cnt_out_tbl Generated Sales Lead Contacts Id
 * @param x_return_status Return status of the create operation
 * @param x_msg_count Number of the error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Sales Lead Contacts
 */
PROCEDURE Create_sales_lead_contacts(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag        IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag               IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id           IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id   IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl   IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_CONTACT_Tbl   IN   SALES_LEAD_CONTACT_Tbl_Type
                                         := G_MISS_SALES_LEAD_CONTACT_Tbl,
    p_SALES_LEAD_ID            IN   NUMBER,
    X_SALES_LEAD_CNT_OUT_Tbl   OUT NOCOPY  SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status            OUT NOCOPY  VARCHAR2,
    X_Msg_Count                OUT NOCOPY  NUMBER,
    X_Msg_Data                 OUT NOCOPY  VARCHAR2
    );

--
--   API Name:  Update_sales_lead_contact
--

/*#
 * This procedure updates lead contacts. The details of lead contacts will be passed in
 * p_sales_lead_contact_tbl. Check x_return_status output to see if the update was successful.
 * @param p_api_version_number API version
 * @param p_init_msg_list Initialize message list
 * @param p_commit Commit after update
 * @param p_validation_level Validation level for the record details
 * @param p_check_access_flag Check access flag
 * @param p_admin_flag Admin flag to denote admin responsibility
 * @param p_admin_group_id Admin group id
 * @param p_identity_salesforce_id Salesforce_id of the lead creator
 * @param p_sales_lead_profile_tbl Table containing profile values for sales lead
 * @param p_sales_lead_contact_tbl Table containing lead contact records
 * @param x_sales_lead_cnt_out_tbl Generated Sales Lead Contacts Id
 * @param x_return_status Return status of the update operation
 * @param x_msg_count Number of the error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Sales Lead Contacts
 */
PROCEDURE Update_sales_lead_contacts(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_CONTACT_Tbl     IN   SALES_LEAD_CONTACT_Tbl_Type,
    X_SALES_LEAD_CNT_OUT_Tbl     OUT NOCOPY  SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--
--   API Name:  Delete_sales_lead_contact
--

/*#
 * This procedure deletes lead contacts. The details of lead contacts will be passed in
 * p_sales_lead_contact_tbl. Check x_return_status output to see if deletion was successful.
 * @param p_api_version_number API version
 * @param p_init_msg_list Initialize message list
 * @param p_commit Commit after update
 * @param p_validation_level Validation level for the record details
 * @param p_check_access_flag Check access flag
 * @param p_admin_flag Admin flag to denote admin responsibility
 * @param p_admin_group_id Admin group id
 * @param p_identity_salesforce_id Salesforce_id of the lead creator
 * @param p_sales_lead_profile_tbl Table containing profile values for sales lead
 * @param p_sales_lead_contact_tbl Table containing lead contact records
 * @param x_sales_lead_cnt_out_tbl Generated Sales Lead Contacts Id
 * @param x_return_status Return status of the delete operation
 * @param x_msg_count Number of the error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Sales Lead Contacts
 */
PROCEDURE Delete_sales_lead_contacts(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_CONTACT_Tbl     IN   SALES_LEAD_CONTACT_Tbl_type,
    X_SALES_LEAD_CNT_OUT_Tbl     OUT NOCOPY  SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

-- Start Linking Sales Lead and Opportunity part
--
--   API Name:  Get_Potential_Opportunity
--
--     08/06/2002 SOLIN  Comment out API Get_Potential_Opportunity because
--                       it's moved to package AS_LINK_LEAD_OPP_PUB.
/*
PROCEDURE Get_Potential_Opportunity(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_rec             IN   SALES_LEAD_rec_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    X_OPPORTUNITY_TBL            OUT NOCOPY  AS_OPPORTUNITY_PUB.HEADER_TBL_TYPE,
    X_OPP_LINES_tbl              OUT NOCOPY  AS_OPPORTUNITY_PUB.LINE_TBL_TYPE
    );
*/
--
--   API Name:  Copy_Lead_To_Opportunity
--
/* API renamed by Francis on 06/26/2001 from Link_Lead_To_Opportunity to Copy_Lead_To_Opportunity */

PROCEDURE Copy_Lead_To_Opportunity(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesgroup_id	 IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_SALES_LEAD_LINE_TBL        IN   SALES_LEAD_LINE_TBL_TYPE
                                                  := G_MISS_SALES_LEAD_LINE_TBL,
    P_OPPORTUNITY_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--
--   API Name:  Link_Lead_To_Opportunity
--
/* API added by Francis on 06/26/2001 */

PROCEDURE Link_Lead_To_Opportunity(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesgroup_id	 IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_OPPORTUNITY_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


--
--   API Name:  Create_Opportunity_For_Lead
--
PROCEDURE Create_Opportunity_For_Lead(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesgroup_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
								:= AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_OPP_STATUS                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    X_OPPORTUNITY_ID             OUT NOCOPY  NUMBER
    );

PROCEDURE Assign_Sales_Lead(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_Sales_Lead_Id              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    X_Assign_Id_Tbl              OUT NOCOPY  Assign_Id_Tbl_Type
    );

--
-- Get Access Profiles
--
-- This procedure gets profile values from profile table type
-- and output access profile record type.
--
-- This procedure is used by internal private APIs where input
-- parameter is profile table type and need to call check access
-- APIs.
--

PROCEDURE Get_Access_Profiles(
	p_profile_tbl			IN	AS_UTILITY_PUB.Profile_Tbl_Type,
	x_access_profile_rec OUT NOCOPY AS_ACCESS_PUB.Access_Profile_Rec_Type
);

--
-- Get Profile
--
-- This function gets profile values from the profile table type
-- and return the value for the input profile name.
--
-- If the profile name is not found in the profile table or
-- the profile value is NULL or FND_API.G_MISS_CHAR,
-- the function will return NULL
--
FUNCTION Get_Profile(
	p_profile_tbl			IN	AS_UTILITY_PUB.Profile_Tbl_Type,
	p_profile_name			IN 	VARCHAR2 )
RETURN VARCHAR2;

PROCEDURE CALL_WF_TO_ASSIGN (
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    P_Sales_Lead_Id              IN  NUMBER,
    P_assigned_resource_id       IN  NUMBER DEFAULT NULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--
--   API Name:  Build_Lead_Sales_Team
--
PROCEDURE Build_Lead_Sales_Team (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

--
--   API Name:  Rebuild_Lead_Sales_Team
--
PROCEDURE Rebuild_Lead_Sales_Team (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );


--
--   API Name:  Run_Lead_Engines
--
PROCEDURE Run_Lead_Engines (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Sales_Team_Flag         OUT NOCOPY VARCHAR2,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

--
--   API Name:  Run_Lead_Engines
--

/*#
 * This procedure runs lead engines. The engine will qualify, rate, and select a channel
 * for the lead. Qualification, rating, and channel selection rules should be created prior
 * to running lead engines.
 * @param p_api_version_number API version
 * @param p_init_msg_list Initialize message list
 * @param p_commit Commit after update
 * @param p_validation_level Validation level for the record details
 * @param p_admin_group_id Admin group id
 * @param p_identity_salesforce_id Salesforce_id of the lead creator
 * @param p_salesgroup_id Sales Group Id of the lead creator
 * @param p_sales_lead_id Sales Lead Id
 * @param x_lead_engines_out_rec Outcome of the rules engine
 * @param x_return_status Return status
 * @param x_msg_count Number of the error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Run Lead Rules Engine
 */
PROCEDURE Run_Lead_Engines (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Lead_Engines_Out_Rec    OUT NOCOPY LEAD_ENGINES_OUT_Rec_Type,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

--
--   API Name:  Start_Partner_Matching
--
PROCEDURE Start_Partner_Matching(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    P_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id  IN  NUMBER,
    P_Salesgroup_Id           IN  NUMBER,
    P_Lead_id                 IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

--
--   API Name:  Route_Lead_To_Marketing
--
PROCEDURE Route_Lead_To_Marketing(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    P_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id  IN  NUMBER,
    P_Sales_Lead_id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

PROCEDURE Lead_Process_After_Create (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    p_Admin_Flag              IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

PROCEDURE Lead_Process_After_Update (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    p_Admin_Flag              IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );


Filter_Exception EXCEPTION;

End AS_SALES_LEADS_PUB;

 

/
