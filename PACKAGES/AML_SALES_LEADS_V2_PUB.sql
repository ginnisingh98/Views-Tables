--------------------------------------------------------
--  DDL for Package AML_SALES_LEADS_V2_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_SALES_LEADS_V2_PUB" AUTHID CURRENT_USER as
/* $Header: amlpasls.pls 120.1 2005/11/07 16:09:32 solin noship $*/
/*#
 * This package provides consolidated methods to create leads and supported
 * entities for Oracle Leads Management.
 * @rep:scope public
 * @rep:product AMS
 * @rep:lifecycle active
 * @rep:displayname Oracle Leads Management Public Wrapper API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY AMS_LEAD
 */


-- Start of Comments
-- Package name     : AML_SALES_LEADS_V2_PUB
-- Purpose          : Sales Leads Management
-- NOTE             :
-- History          :
--     08/27/2003 AANJARIA  Created.
-- End of Comments


-- Main procedure to create lead, process it and create other related
-- entities like interest and notes

/*#
 * This procedure creates a lead and supported entities. The details of lead,
 * product interest, and contact will be passed in p_sales_lead_rec, p_sales_lead_line_tbl,
 * and p_sales_lead_contact_tbl, respectively. Check x_return_status output to see if creation
 * was successful. If successful, a unique identifier for the lead object will be passed back
 * to the x_sales_lead_id output parameter.
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
 * @param p_sales_lead_line_tbl Table containing lead lines records
 * @param p_sales_lead_contact_tbl Table containing contacts for the lead
 * @param p_lead_note Lead note
 * @param p_note_type Lead note type
 * @param x_sales_lead_id Generated Sales Lead Id
 * @param x_sales_lead_line_out_tbl Generated Sales Lead Line Id
 * @param x_sales_lead_cnt_out_tbl Generated Sales Lead Contact Id
 * @param x_note_id Generate lead note id
 * @param x_return_status Status of the create operation
 * @param x_msg_count Number of the error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Sales Lead
 */
PROCEDURE Create_sales_lead (
    P_Api_Version_Number     IN  NUMBER,
    P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag      IN  VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag             IN  VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id         IN  NUMBER       := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id IN  NUMBER       := FND_API.G_MISS_NUM,
    P_Salesgroup_Id          IN  NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl IN  AS_UTILITY_PUB.Profile_Tbl_Type
                                 := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec         IN  AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                                 := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC,
    P_SALES_LEAD_LINE_Tbl    IN  AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Tbl_type
                                 := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_LINE_Tbl,
    P_SALES_LEAD_CONTACT_Tbl IN  AS_SALES_LEADS_PUB.SALES_LEAD_CONTACT_Tbl_Type
                                 := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_CONTACT_Tbl,
    P_Lead_note              IN  VARCHAR2 DEFAULT NULL,
    P_Note_type              IN  VARCHAR2 DEFAULT NULL,
    X_SALES_LEAD_ID           OUT NOCOPY NUMBER,
    X_SALES_LEAD_LINE_OUT_Tbl OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_type,
    X_SALES_LEAD_CNT_OUT_Tbl  OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_CNT_OUT_Tbl_Type,
    X_note_id                 OUT NOCOPY NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

END AML_SALES_LEADS_V2_PUB;

 

/
