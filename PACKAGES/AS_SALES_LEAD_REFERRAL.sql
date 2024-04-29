--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_REFERRAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_REFERRAL" AUTHID CURRENT_USER AS
/* $Header: asxvlrps.pls 120.1 2005/06/24 17:10:32 appldev ship $ */


g_pkg_name			CONSTANT VARCHAR2(30):='AS_SALES_LEAD_REFERRAL';

g_wf_itemtype_notify		CONSTANT VARCHAR2(30) := 'ASLEADNT';
g_wf_pcs_notify_ptnr		CONSTANT VARCHAR2(30) := 'AS_LEAD_NOTIFY_PTNR_PCR';
g_wf_attr_create_notify_role	CONSTANT VARCHAR2(30) := 'AS_LEAD_NOTIFY_CREATE_ROLE_ATR';
g_wf_attr_accept_notify_role	CONSTANT VARCHAR2(30) := 'AS_LEAD_NOTIFY_ACCEPT_ROLE_ATR';
g_wf_attr_reject_notify_role	CONSTANT VARCHAR2(30) := 'AS_LEAD_NOTIFY_REJECT_ROLE_ATR';
g_wf_attr_referral_notify_role	CONSTANT VARCHAR2(30) := 'AS_LEAD_NOTIFY_REF_ROLE_ATR';
g_wf_attr_new_notify_role_ptnr	CONSTANT VARCHAR2(30) := 'AS_LEAD_NEW_ROLE_PTNR_ATR';
g_wf_attr_new_notify_role_vndr	CONSTANT VARCHAR2(30) := 'AS_LEAD_NEW_ROLE_VNDR_ATR';
g_wf_attr_referral_type		CONSTANT VARCHAR2(30) := 'AS_LEAD_REFERRAL_TYPE_ATR';
g_wf_attr_ptnr_user_name	CONSTANT VARCHAR2(30) := 'AS_LEAD_PTNR_USER_NAME_ATR';
g_wf_attr_cust_name		CONSTANT VARCHAR2(30) := 'AS_LEAD_CUST_NAME_ATR';
g_wf_attr_cust_state		CONSTANT VARCHAR2(30) := 'AS_LEAD_CUST_STATE_ATR';
g_wf_attr_cust_country		CONSTANT VARCHAR2(30) := 'AS_LEAD_CUST_COUNTRY_ATR';
g_wf_attr_reviewer_comments	CONSTANT VARCHAR2(30) := 'AS_LEAD_REVWR_CMNTS_ATR';
g_wf_attr_declined_reason	CONSTANT VARCHAR2(30) := 'AS_LEAD_DECLINED_REASON_ATR';
g_wf_attr_ptnr_org_name		CONSTANT VARCHAR2(30) := 'AS_LEAD_PTNR_ORG_NAME_ATR';
g_wf_attr_referral_closedate	CONSTANT VARCHAR2(30) := 'AS_LEAD_REF_CLOSEDATE_ATR';
g_wf_attr_referral_commission	CONSTANT VARCHAR2(30) := 'AS_LEAD_REF_COMMISSION_ATR';
g_wf_attr_lead_name		CONSTANT VARCHAR2(30) := 'AS_LEAD_NAME_ATR';
g_wf_attr_lead_status		CONSTANT VARCHAR2(30) := 'AS_LEAD_STATUS_ATR';
g_wf_attr_respond_url		CONSTANT VARCHAR2(30) := 'AS_LEAD_WORKFLOW_RESPOND_URL';
g_wf_lkup_lead_status		CONSTANT VARCHAR2(30) := 'AS_LEAD_STATUS_LKP';

g_wf_attr_sales_lead_id         CONSTANT VARCHAR2(50) := 'AS_LEAD_ID_ATR';
g_wf_attr_referred_by         CONSTANT VARCHAR2(50) := 'AS_LEAD_REFERRED_BY_ATR';
g_wf_attr_referral_type_mean       CONSTANT VARCHAR2(50) := 'AS_LEAD_REF_TYPE_MEAN_ATR';
g_wf_attr_lead_status_mean         CONSTANT VARCHAR2(50) := 'AS_LEAD_STATUS_MEAN_ATR';
g_wf_attr_dec_reason_mean     CONSTANT VARCHAR2(50) := 'AS_LEAD_DEC_REASON_MEAN_ATR';
g_wf_attr_created_by     CONSTANT VARCHAR2(50) := 'AS_LEAD_CREATED_BY_ATR';
g_wf_attr_category  CONSTANT VARCHAR2(50) := 'AS_LEAD_CATEGORY_ATR';
g_wf_attr_ptnr_full_name      CONSTANT VARCHAR2(50) := 'AS_LEAD_PTNR_FULL_NAME_ATR';
g_wf_attr_create_ptnr_role    CONSTANT VARCHAR2(50) := 'AS_CREATE_PTNR_ROLE_ATR';

g_wf_lkup_lead_status         CONSTANT VARCHAR2(50) := 'AS_LEAD_STATUS_LKP';

g_wf_lkup_lead_status_acc	CONSTANT VARCHAR2(30) := 'LEAD_ACCEPTED';
g_wf_lkup_lead_status_dec	CONSTANT VARCHAR2(30) := 'LEAD_DECLINED';
g_wf_lkup_lead_status_sub	CONSTANT VARCHAR2(30) := 'LEAD_SUBMITTED';
g_wf_lkup_lead_status_comm_ltr	CONSTANT VARCHAR2(30) := 'COMM_LTR_SENT';
g_wf_lkup_lead_status_comm_acc	CONSTANT VARCHAR2(30) := 'COMM_ACCEPTED';
g_wf_lkup_lead_status_comm_rej	CONSTANT VARCHAR2(30) := 'COMM_REJECTED';


g_wf_lkup_lead_status_ref	CONSTANT VARCHAR2(30) := 'REFERRAL';

g_entity			VARCHAR2(20)  := 'LEAD';
g_wf_status_closed	        CONSTANT VARCHAR2(20) := 'CLOSED';
g_source_type			VARCHAR2(20) := 'SALESTEAM';


g_referral_status_sub      CONSTANT VARCHAR2(20) := fnd_profile.value('REF_STATUS_FOR_NEW_LEAD');
g_referral_status_acc      CONSTANT VARCHAR2(20) := fnd_profile.value('REF_STATUS_FOR_CONV_LEAD');
g_referral_status_dec      CONSTANT VARCHAR2(20) := fnd_profile.value('REF_STATUS_FOR_LINK_LEAD');
g_referral_status_comm_ltr CONSTANT VARCHAR2(20) := fnd_profile.value('REF_STATUS_FOR_COMM_LTR');
g_referral_status_comm_acc CONSTANT VARCHAR2(20) := 'ACCEPTCOMM';
g_referral_status_comm_rej CONSTANT VARCHAR2(20) := 'REJECTCOMM';
g_referral_status_cust_pmt CONSTANT VARCHAR2(20) := 'CUSTPMTRCVD';
g_referral_status_pmt_proc CONSTANT VARCHAR2(20) := 'PMTPROCSD';
g_referral_status_comm_pd  CONSTANT VARCHAR2(20) := 'COMMPAID';


g_log_lead_referral_category CONSTANT VARCHAR2(20) := 'REFERRAL';

TYPE t_overriding_usernames IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

G_MISS_OVER_USERNAMES_TBL          t_overriding_usernames;

-- PROCEDURE
--    NotifyParty
--
-- PURPOSE
--    Notify the partner based on the lead status.
--
-- PARAMETERS
--    p_lead_id: the record with new items.
--    p_salesforce_id:  sales force id
--    p_overriding_user : list of usernames who should be sent the
--                        notifications
--
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------

PROCEDURE  Notify_Party (
		p_api_version        IN  NUMBER := 1.0
		,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
		,p_commit            IN  VARCHAR2  := FND_API.g_false
		,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
		,p_lead_id	     IN  NUMBER
		,p_lead_status	     IN  VARCHAR2
		,p_salesforce_id     IN  NUMBER
		,p_overriding_usernames IN t_overriding_usernames default G_MISS_OVER_USERNAMES_TBL
		,x_msg_count	     OUT NOCOPY  NUMBER
		,x_msg_data          OUT NOCOPY  VARCHAR2
		,x_return_status     OUT NOCOPY  VARCHAR2
	);


-- PROCEDURE
--    Update_sales_referral_lead
--
-- PURPOSE
--    Update sales lead from referral screen.
--
-- PARAMETERS

--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE Update_sales_referral_lead(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag      IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag             IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id         IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec         IN   AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                                      DEFAULT AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC,
    p_overriding_usernames   IN t_overriding_usernames,
    X_Return_Status          OUT NOCOPY   VARCHAR2,
    X_Msg_Count              OUT NOCOPY   NUMBER,
    X_Msg_Data               OUT NOCOPY   VARCHAR2
    );



PROCEDURE AS_LEAD_NOTIFY(
	itemtype		in varchar2,
	itemkey			in varchar2,
	actid			in number,
	funcmode		in varchar2,
	resultout	 IN OUT NOCOPY  varchar2
);


/* This procedure is called from the workflow process to decide whether to send notification to partner*/
PROCEDURE SEND_PTNR_NTF(
     itemtype       in varchar2,
     itemkey             in varchar2,
     actid               in number,
     funcmode       in varchar2,
     resultout      IN OUT NOCOPY  varchar2
);


END AS_SALES_LEAD_REFERRAL;


 

/
