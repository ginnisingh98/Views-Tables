--------------------------------------------------------
--  DDL for Package ASL_EXCEL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASL_EXCEL_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: aslvxlus.pls 120.1 2005/11/11 02:11:50 vjayamoh noship $ */

/*
** Server Side Primary Key ID MAX. Any number larger than this,
** is considered as records created by mobile sales/laptop.
** Temporary consider them to be NEW always.
*/
M_SERVER_PK_ID_MAX NUMBER := 2147483647;
/*
** Define the NEW_RECORD caches
** Because it might contain parties that not qualified with download preference
** default it is 'N'.
*/
/* BLAM */
TYPE ASL_NEW_CUST_REC_TYPE IS RECORD
(CUSTOMER_ID   NUMBER
,DOWNLOAD_FLAG VARCHAR2(1)
);
/* BLAM */

TYPE ASL_NEW_LEAD_REC_TYPE IS RECORD
(SALES_LEAD_ID     NUMBER
,CUSTOMER_ID NUMBER
,DOWNLOAD_FLAG VARCHAR2(1)
);

TYPE ASL_NEW_OPPORTUNITY_REC_TYPE IS RECORD
(OPPORTUNITY_ID     NUMBER
,CUSTOMER_ID NUMBER
,DOWNLOAD_FLAG VARCHAR2(1)
);

TYPE ASL_NEW_OPP_LINE_REC_TYPE IS RECORD
(OPPORTUNITY_ID  NUMBER
,OPPORTUNITY_LINE_ID NUMBER
);

/* agmoore - changes for opportunity classifications 2744023 */
TYPE ASL_NEW_OPP_CLASS_REC_TYPE IS RECORD
(OPPORTUNITY_ID  NUMBER
,OPPORTUNITY_CLASS_ID NUMBER
);

/* lcooper - record type for opportunity issues 2675493 */
TYPE ASL_NEW_OPP_ISSUES_REC_TYPE IS RECORD
(OPPORTUNITY_ID         NUMBER,
 OPPORTUNITY_ISSUE_ID   NUMBER
);

TYPE ASL_NEW_CONTACT_REC_TYPE IS RECORD
(CONTACT_PARTY_ID NUMBER
,CONTACT_PERSON_ID NUMBER
,CUSTOMER_ID NUMBER
);

/*
** QUOTE RECORD TYPES
*/
TYPE ASL_NEW_QUOTE_REC_TYPE IS RECORD
(QUOTE_HEADER_ID NUMBER
,DOWNLOAD_FLAG VARCHAR2(1)
);

TYPE ASL_NEW_QUOTE_DET_REC_TYPE IS RECORD
(QUOTE_HEADER_ID NUMBER
,QUOTE_LINE_ID NUMBER
,QUOTE_LINE_DETAIL_ID NUMBER
);

TYPE ASL_OLD_INV_CATEGORY_REC_TYPE IS RECORD
(CATEGORY_ID NUMBER
);

TYPE ASL_OLD_PRICE_LIST_REC_TYPE IS RECORD
(LIST_HEADER_ID NUMBER
);

TYPE ASL_NEW_QUOTE_TBL_TYPE IS TABLE OF ASL_NEW_QUOTE_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE ASL_NEW_QUOTE_DET_TBL_TYPE IS TABLE OF ASL_NEW_QUOTE_DET_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE ASL_OLD_INV_CATEGORY_TBL_TYPE IS TABLE OF ASL_OLD_INV_CATEGORY_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE ASL_OLD_PRICE_LIST_TBL_TYPE IS TABLE OF ASL_OLD_PRICE_LIST_REC_TYPE INDEX BY BINARY_INTEGER;

M_NEW_QOT_TBL ASL_NEW_QUOTE_TBL_TYPE;
M_NEW_QOT_DET_TBL ASL_NEW_QUOTE_DET_TBL_TYPE;
M_OLD_INV_TBL ASL_OLD_INV_CATEGORY_TBL_TYPE;
M_OLD_PRICE_LIST_TBL ASL_OLD_PRICE_LIST_TBL_TYPE;

/*
**END OF QUOTE RECORD TYPES
*/
/* BLAM */
TYPE ASL_NEW_CUST_TBL_TYPE IS TABLE OF ASL_NEW_CUST_REC_TYPE INDEX BY BINARY_INTEGER;
/* BLAM */
TYPE ASL_NEW_CNT_TBL_TYPE IS TABLE OF ASL_NEW_CONTACT_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE ASL_NEW_OPP_TBL_TYPE IS TABLE OF ASL_NEW_OPPORTUNITY_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE ASL_NEW_OPP_LINE_TBL_TYPE IS TABLE OF ASL_NEW_OPP_LINE_REC_TYPE INDEX BY BINARY_INTEGER;
/* agmoore - changes for opportunity classifications  2744023 */
TYPE ASL_NEW_OPP_CLASS_TBL_TYPE IS TABLE OF ASL_NEW_OPP_CLASS_REC_TYPE INDEX BY BINARY_INTEGER;
/* lcooper - table type for opportunity issues 2675493 */
TYPE ASL_NEW_OPP_ISSUES_TBL_TYPE IS TABLE OF ASL_NEW_OPP_ISSUES_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE ASL_NEW_LEAD_TBL_TYPE IS TABLE OF ASL_NEW_LEAD_REC_TYPE INDEX BY BINARY_INTEGER;

/* BLAM */
M_NEW_CUST_TBL ASL_NEW_CUST_TBL_TYPE;
/* BLAM */
M_NEW_CNT_TBL ASL_NEW_CNT_TBL_TYPE;
M_NEW_OPP_TBL ASL_NEW_OPP_TBL_TYPE;
M_NEW_OPP_LINE_TBL ASL_NEW_OPP_LINE_TBL_TYPE;
/* agmoore - changes for opportunity classifications 2744023 */
M_NEW_OPP_CLASS_TBL ASL_NEW_OPP_CLASS_TBL_TYPE;
/* lcooper - table variable for opportunity issues 2675493 */
M_NEW_OPP_ISSUES_TBL ASL_NEW_OPP_ISSUES_TBL_TYPE;
M_NEW_LEAD_TBL ASL_NEW_LEAD_TBL_TYPE;

/*
** Customer Account Record Types
** No longer defaulting any values in PL/SQL Record
*/
TYPE ASL_CUSTOMER_ACCOUNT_REC_TYPE IS RECORD
(CUST_ACCOUNT_ID NUMBER
);



TYPE ASL_NEW_CUST_ACCOUNT_TBL_TYPE IS TABLE OF ASL_CUSTOMER_ACCOUNT_REC_TYPE INDEX BY BINARY_INTEGER;

M_NEW_CUST_ACCOUNT_TBL ASL_NEW_CUST_ACCOUNT_TBL_TYPE;

/*
** The flag to indicate whether a full sync will be operated.
*/
M_FULL_SYNC BOOLEAN := TRUE;

/*
** Hard code the Date to VARCHAR2 conversion Format. Precision is to seconds.
*/
M_CONVERSION_DATE_FORMAT VARCHAR2(60) := 'YYYY-MM-DD:HH24:MI:SS';
/*
** Save Sync Context for a particular sales rep.
** It doesn't do any validation on the passed in values. Assumeably ASF_PAGE
** Already done that.
*/
PROCEDURE SAVE_SYNC_CONTEXT
(  p_salesforce_id IN NUMBER,
   p_salesgroup_id IN NUMBER,
   p_person_id     IN NUMBER,
   p_user_id       IN NUMBER,
   p_full_sync     IN NUMBER,
   x_curr_sync_time_str OUT NOCOPY VARCHAR2
);

PROCEDURE SET_ACCESS_PROFILE_VALUES
(p_cust_access       IN VARCHAR2
,p_lead_access     IN VARCHAR2
,p_opp_access IN VARCHAR2
,p_mgr_update IN VARCHAR2
,p_admin_update IN VARCHAR2
);

PROCEDURE SET_DEFAUL_ORG_ID
(p_default_org_id IN NUMBER
);

PROCEDURE SET_ENABLED_MODULES
(p_module_name VARCHAR2
);

/*
** Given the de-normalized customer information, figure out
** whether this record is newer than last update, and meanwhile,
** do the security check
*/
FUNCTION Check_Organization_Download
(p_customer_id IN NUMBER
,p_org_creation_date IN DATE
,p_org_update_date   IN DATE
,p_profile_creation_date IN DATE
,p_ploc_update_date  IN DATE
,p_sloc_update_date  IN DATE
,p_bloc_update_date  IN DATE
,p_phone_update_date IN DATE
,p_email_update_date IN DATE
) RETURN VARCHAR2;

/* BLAM -- Remain separate functions just in case any client schema change */
FUNCTION Check_Person_Download
(p_customer_id IN NUMBER
,p_per_creation_date IN DATE
,p_per_update_date   IN DATE
,p_profile_creation_date IN DATE
,p_phone_update_date IN DATE
,p_email_update_date IN DATE
) RETURN VARCHAR2;
/* BLAM */

FUNCTION Check_Opp_Download
(p_opp_creation_date IN DATE
,p_opp_update_date IN DATE
,p_opportunity_id  IN NUMBER
,p_customer_id     IN NUMBER
,p_customer_update_date IN DATE
,p_contact_party_update_date  IN DATE
,p_contact_person_update_date  IN DATE
,p_rel_update_date IN DATE
) RETURN VARCHAR2;

FUNCTION Check_Opp_Det_Download
(p_line_creation_date IN DATE
,p_line_update_date IN DATE
,p_opportunity_id IN NUMBER
,p_opp_line_id    IN NUMBER
) RETURN VARCHAR2;

/* created by agmoore for opportunity classifications 2744023 */
FUNCTION Check_Opp_Class_Download
(p_class_creation_date IN DATE
,p_class_update_date IN DATE
,p_opportunity_id IN NUMBER
,p_opp_class_id    IN NUMBER
) RETURN VARCHAR2;

/* lcooper - created for opportunity win/loss other issues 2744023 */
FUNCTION Check_Opp_Issues_Download
(p_issue_creation_date  IN DATE,
 p_issue_update_date    IN DATE,
 p_opportunity_id       IN NUMBER,
 p_opp_issue_id         IN NUMBER
) RETURN VARCHAR2;

FUNCTION Check_Opp_Credit_Download
(p_credit_creation_date  IN DATE
,p_credit_last_update_date     IN DATE
,p_lead_line_id             IN NUMBER
,p_group_last_update_date     IN DATE
,p_resource_last_update_date  IN DATE
) RETURN VARCHAR2;

FUNCTION Check_Contact_Download
(p_contact_creation_date IN DATE
,p_contact_party_id      IN NUMBER
,p_contact_person_id     IN NUMBER
,p_customer_id           IN NUMBER
,p_person_update_date    IN DATE
,p_contact_update_date   IN DATE
,p_loc_update_date       IN DATE
,p_phone_update_date     IN DATE
,p_email_update_date     IN DATE
) RETURN VARCHAR2;

FUNCTION Check_Notes_Download
(p_note_creation_date  IN DATE
,p_note_source_object_code IN VARCHAR2
,p_note_source_object_id    IN NUMBER
,p_tl_update_date  IN DATE
) RETURN VARCHAR2;

FUNCTION Check_Lead_Download
(p_lead_CREATION_DATE  IN DATE
,p_lead_last_update_date   IN DATE
,p_sales_lead_id           IN NUMBER
,p_customer_id             IN NUMBER
,p_customer_update_date IN DATE
,p_cnt_party_update_date    IN DATE
,p_rel_last_update_date  IN DATE
,p_cnt_person_update_date   IN  DATE
) RETURN VARCHAR2;

FUNCTION Check_Lead_Det_Download
(p_line_creation_date  IN DATE
,p_line_last_update_date   IN DATE
,p_sales_lead_id  IN NUMBER
) RETURN VARCHAR2;

FUNCTION Check_CST_SalesTeam_Download
(p_team_creation_date  IN DATE
,p_team_last_update_date  IN DATE
,p_customer_id     IN NUMBER
,p_group_last_update_date IN DATE
,p_resource_last_update_date IN DATE
) RETURN VARCHAR2;

FUNCTION Check_Opp_SalesTeam_Download
(p_team_creation_date  IN DATE
,p_team_last_update_date  IN DATE
,p_opportunity_id     IN NUMBER
,p_group_last_update_date IN DATE
,p_resource_last_update_date IN DATE
) RETURN VARCHAR2;


FUNCTION Check_Lead_SalesTeam_Download
(p_team_creation_date  IN DATE
,p_team_last_update_date  IN DATE
,p_lead_id     IN NUMBER
,p_group_last_update_date IN DATE
,p_resource_last_update_date IN DATE
) RETURN VARCHAR2;


FUNCTION Check_Address_Download
(p_customer_id IN NUMBER
,p_add_creation_date IN DATE
,p_add_update_date   IN DATE
) RETURN VARCHAR2;

/*
** Quote Incremental Sync Functions
*/
FUNCTION Check_Quote_Download
(p_qot_creation_date       IN DATE
,p_qot_update_date         IN DATE
,p_qot_header_id           IN NUMBER
,p_cust_accnt_update_date  IN DATE
,p_customer_update_date    IN DATE
,p_org_contact_update_date IN DATE
,p_rel_update_date         IN DATE
,p_contact_party_update_date IN DATE
,p_sold_to_party_update_date IN DATE
,p_related_obj_update_date IN DATE
,p_related_opp_update_date IN DATE
) RETURN VARCHAR2;

FUNCTION Check_Quote_Det_Download
(p_quote_line_creation_date IN DATE
,p_quote_line_update_date   IN DATE
,p_quote_line_det_update_date IN DATE
,p_quote_header_id IN NUMBER
,p_quote_line_id   IN NUMBER
,p_quote_line_detail_id       IN NUMBER
) RETURN VARCHAR2;

FUNCTION Check_Quote_Shipment_Download
(p_quote_shipment_creation_date IN DATE
,p_quote_shipment_update_date   IN DATE
,p_quote_header_id   IN NUMBER
,p_quote_shipment_id IN NUMBER
,p_ship_to_site_update_date     IN DATE
,p_ship_to_relation_update_date IN DATE
,p_ship_to_contact_update_date  IN DATE
) RETURN VARCHAR2;

FUNCTION Check_Quote_Payment_Download
(p_quote_payment_creation_date IN DATE
,p_quote_payment_update_date   IN DATE
,p_quote_header_id   IN NUMBER
,p_quote_payment_id IN NUMBER

) RETURN VARCHAR2;

FUNCTION Check_Quote_Price_Adj_Download
(p_price_Adj_creation_date IN DATE
,p_price_Adj_update_date   IN DATE
,p_quote_header_id   IN NUMBER
,p_quote_line_id   IN NUMBER
,p_price_adjustment_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION Check_Quote_Salesteam_Download
(p_qot_Salesteam_creation_date IN DATE
,p_qot_Salesteam_update_date   IN DATE
,p_quote_header_id   IN NUMBER
,p_quote_access_id   IN NUMBER
) RETURN VARCHAR2;

FUNCTION Check_Qot_Salescredit_Download
(p_qot_scredit_creation_date IN DATE
,p_qot_scredit_update_date   IN DATE
,p_quote_header_id   IN NUMBER
,p_quote_sales_credit_id   IN NUMBER
) RETURN VARCHAR2;

FUNCTION Check_Inv_Item_Download
(p_inv_item_creation_date  IN DATE
,p_inv_item_b_update_date  IN DATE
,p_inv_item_tl_update_date IN DATE
,p_inv_catgry_update_date  IN DATE
,p_inv_uom_update_date     IN DATE
,p_inv_category_id   IN NUMBER
,p_inv_item_id       IN NUMBER
) RETURN VARCHAR2;

FUNCTION Check_Price_List_Download
(p_list_line_creation_date IN DATE
,p_list_line_update_date   IN DATE
,p_line_attr_update_date   IN DATE
,p_list_header_id   IN NUMBER
,p_inv_category_id  IN NUMBER
) RETURN VARCHAR2;

FUNCTION Check_Cust_Account_Download
(p_customer_id IN NUMBER
,p_cust_accnt_id IN NUMBER
,p_cust_accnt_creation_date IN DATE
,p_cust_update_date   IN DATE
,p_cust_accnt_update_date   IN DATE
,p_loc_update_date      IN DATE
,p_site_update_date     IN DATE
,p_site_use_update_date IN DATE
) RETURN VARCHAR2;

FUNCTION Check_Rel_Cust_Addr_Download
(p_cust_accnt_id IN NUMBER
,p_cust_rel_creation_date IN DATE
,p_cust_update_date   IN DATE
,p_loc_update_date      IN DATE
,p_site_update_date     IN DATE
) RETURN VARCHAR2;

FUNCTION Check_Rel_Cust_Cont_Download
(p_cust_accnt_id IN NUMBER
,p_cust_rel_creation_date IN DATE
,p_cust_update_date   IN DATE
,p_contact_update_date   IN DATE
) RETURN VARCHAR2;

/*
** Passing in a customer, check if it is updateable by this particular
** resource
** For contact access priv, the sql will pass in the object_id to check.
** because contact's updateable belongs to its object that it relates to.
*/
FUNCTION CHECK_CUSTOMER_UPDATEBLE
(p_api_version_number IN NUMBER
,p_init_msg_list      IN VARCHAR2
,p_validation_level IN NUMBER
,p_customer_id IN NUMBER
,p_party_type IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 ;

FUNCTION CHECK_OPPORTUNITY_UPDATEBLE
(p_api_version_number IN NUMBER
,p_init_msg_list      IN VARCHAR2
,p_validation_level IN NUMBER
,p_opportunity_id IN NUMBER
) RETURN VARCHAR2 ;

FUNCTION CHECK_LEAD_UPDATEBLE
(p_api_version_number IN NUMBER
,p_init_msg_list      IN VARCHAR2
,p_validation_level IN NUMBER
,p_sales_lead_id IN NUMBER
) RETURN VARCHAR2 ;

/*FUNCTION CHECK_CUSTOMER_UPDATEBLE(p_customer_id IN NUMBER) RETURN VARCHAR2;
*/
FUNCTION CHECK_MANAGER_FLAG(p_group_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_SOURCE_NAME(p_source_code_id IN NUMBER) RETURN VARCHAR2;

/*
*Overload lead/opp dirty flag for incremental sync home page
*display problem caused by a change in the related org.
*/
FUNCTION GET_LEAD_DIRTY
(p_lead_creation_date IN DATE
,p_lead_last_update_date IN DATE
,p_customer_update_date    IN DATE
) RETURN VARCHAR2;

FUNCTION GET_OPPORTUNITY_DIRTY
(p_opp_creation_date IN DATE
,p_opp_update_date IN DATE
,p_customer_update_date IN DATE
) RETURN VARCHAR2;

END ASL_EXCEL_UTIL_PVT;


 

/
