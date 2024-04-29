--------------------------------------------------------
--  DDL for Package IEX_DUNNING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_DUNNING_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvduns.pls 120.7.12010000.8 2010/02/05 12:43:21 gnramasa ship $ */

  -- this will be passed back by the get_components procedure
  TYPE FULFILLMENT_BIND_REC IS RECORD(
    KEY_NAME          VARCHAR2(150),
    KEY_TYPE          VARCHAR2(25),     -- 'NUMBER' or 'VARCHAR' or 'DATE'
    KEY_VALUE         VARCHAR2(240));

  TYPE FULFILLMENT_BIND_TBL IS TABLE OF FULFILLMENT_BIND_REC INDEX BY binary_integer;

  g_included_current_invs	varchar2(1) := 'N'; -- added by gnramasa for bug 9326376 2-Feb-10
  g_included_unapplied_rec	varchar2(1) := 'N'; -- added by gnramasa for bug 9326376 2-Feb-10

Procedure Validate_Delinquency(
    P_Init_Msg_List              IN   VARCHAR2     ,
    P_Delinquency_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

Procedure Create_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_REC          IN IEX_DUNNING_PUB.AG_DN_XREF_REC_TYPE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_AG_DN_XREF_ID           OUT NOCOPY NUMBER);

Procedure Update_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_REC          IN IEX_DUNNING_PUB.AG_DN_XREF_REC_TYPE,
            p_AG_DN_XREF_ID           IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Delete_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_ID           IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Create_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_Dunning_REC             IN IEX_DUNNING_PUB.DUNNING_REC_TYPE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_Dunning_ID              OUT NOCOPY NUMBER);

Procedure Create_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
	    p_dunning_id	      IN NUMBER,
	    p_correspondence_date     IN DATE,
	    p_ag_dn_xref_id           IN NUMBER,
            p_running_level           IN VARCHAR2,
	    p_grace_days              IN NUMBER := 0,
	    p_include_dispute_items   IN VARCHAR2 DEFAULT 'N',
	    p_dunning_mode            IN VARCHAR2,
	    p_inc_inv_curr            IN IEX_UTILITIES.INC_INV_CURR_TBL,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Update_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_Dunning_REC             IN IEX_DUNNING_PUB.DUNNING_REC_TYPE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

/*=========================================================================
   clchang update 10/16/2002 -
     Send Dunning can be in Customer, Account and Transaction levels in 11.5.9;
     Send_Level_Dunning is for Customer and Account level;
     Send_Dunning keeps the same, and is for Transaction Level;
*=========================================================================*/
Procedure Send_Level_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_running_level           IN VARCHAR2,
            p_dunning_plan_id         in number,
            p_resend_flag             IN VARCHAR2 DEFAULT NULL,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_parent_request_id       IN NUMBER,
	    p_dunning_mode	      IN VARCHAR2 DEFAULT NULL,  -- added by gnramasa for bug 8489610 14-May-09
	    p_confirmation_mode	      IN VARCHAR2 DEFAULT NULL,  -- added by gnramasa for bug 8489610 14-May-09
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Send_Level_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_running_level           IN VARCHAR2,
            p_dunning_plan_id         in number,
	    p_correspondence_date     IN DATE,
            p_resend_flag             IN VARCHAR2 DEFAULT NULL,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_parent_request_id       IN NUMBER,
	    p_dunning_mode	      IN VARCHAR2 DEFAULT NULL,
	    p_single_staged_letter    IN VARCHAR2 DEFAULT 'N',
	    p_confirmation_mode	      IN VARCHAR2 DEFAULT NULL,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Send_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
            p_resend_flag             IN VARCHAR2 DEFAULT NULL,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_parent_request_id       IN NUMBER,
	    p_dunning_mode	      IN VARCHAR2 DEFAULT NULL,   -- added by gnramasa for bug 8489610 14-May-09
	    p_confirmation_mode	      IN VARCHAR2 DEFAULT NULL,   -- added by gnramasa for bug 8489610 14-May-09
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Send_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
	    p_correspondence_date     IN DATE,
            p_resend_flag             IN VARCHAR2 DEFAULT NULL,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_parent_request_id       IN NUMBER,
	    p_dunning_mode	      IN VARCHAR2 DEFAULT NULL,
	    p_single_staged_letter    IN VARCHAR2 DEFAULT 'N',
	    p_confirmation_mode	      IN VARCHAR2 DEFAULT NULL,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure stage_dunning_inv_copy
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_no_of_workers           IN NUMBER,
            p_process_err_rec_only    IN VARCHAR2,
            p_request_id	      IN NUMBER,
	    p_dunning_mode	      IN VARCHAR2,
	    p_confirmation_mode	      IN VARCHAR2,
	    p_running_level           IN VARCHAR2,
	    p_correspondence_date     IN DATE,
	    p_max_dunning_trx_id      IN NUMBER,
	    x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);


/*=========================================================================
   clchang added 03/04/2003 -
     The following 2 Resend procedures are especially for resend dunnings;
     Called by FORM, not Concurrent Program;
*=========================================================================*/
Procedure Resend_Level_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
            p_running_level           IN VARCHAR2,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_org_id                  in number default null,
	    x_request_id              OUT NOCOPY NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Resend_Level_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
	    p_dunning_id              in number,
            p_running_level           IN VARCHAR2,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
	    p_org_id                  in number default null,
            x_request_id              OUT NOCOPY NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Resend_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_org_id                  in number default null,
	    x_request_id              OUT NOCOPY NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Resend_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
	    p_dunning_id              in number,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
	    p_org_id                  in number default null,
            x_request_id              OUT NOCOPY NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

/* clchang added (for 11.5.9)
   no iex aging in 11.5.9;
   in send_dunning, aging_bucket_line_id is not from iex_delinquencies;
   we need to get by ourselves;
 */
Procedure AGING_DEL(
            p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_delinquency_id          IN NUMBER,
            p_dunning_plan_id         in number,
            p_bucket                  IN VARCHAR2 DEFAULT NULL,
            p_object_code             IN VARCHAR2 DEFAULT NULL,
            p_object_id               IN NUMBER DEFAULT NULL,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_AGING_Bucket_line_ID    OUT NOCOPY NUMBER);


Procedure Call_FFM(
            p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_key_name                IN VARCHAR2,
            p_key_id                  IN NUMBER,
            p_template_id             IN NUMBER,
            p_method                  IN VARCHAR2,
            p_party_id                IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_REQUEST_ID              OUT NOCOPY NUMBER);

Procedure Get_Callback_Date(
            p_init_msg_list           IN VARCHAR2 ,
            p_callback_days              IN   NUMBER,
	    p_correspondence_date	 IN DATE default null,
            x_callback_date              OUT NOCOPY  DATE,
            X_Return_Status              OUT NOCOPY  VARCHAR2,
            X_Msg_Count                  OUT NOCOPY  NUMBER,
            X_Msg_Data                   OUT NOCOPY  VARCHAR2 );


PROCEDURE Close_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            --p_delinquencies_tbl       IN IEX_DUNNING_PUB.DelId_NumList,
            p_running_level           IN VARCHAR2,
	    --p_dunning_id              IN NUMBER default NULL,  -- added by gnramasa for bug 8489610 14-May-09
	    --p_status                  IN VARCHAR2 DEFAULT 'OPEN', -- added by gnramasa for bug 8489610 14-May-09
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

PROCEDURE Close_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
	    p_ag_dn_xref_id           IN NUMBER,
            p_running_level           IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

/*=========================================================================
   clchang update 10/02/2002 - no ReOpen Dunning in 115.9
-- clchang added 09/04/2002 for reopen delinquencies
-- added in 115.9 code line and 115.6 branch
PROCEDURE ReOpen_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
            p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
            --p_delinquencies_tbl       IN IEX_DUNNING_PUB.DelId_NumList,
            p_delinquencies_tbl       IN DBMS_SQL.NUMBER_TABLE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);
*=========================================================================*/
Procedure Daily_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            --p_dunning_tbl             IN IEX_DUNNING_PUB.DUNNING_TBL_TYPE,
            p_running_level           IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure NEW_TASK(
            p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_delinquency_id          IN NUMBER,
            p_dunning_id              IN NUMBER,
            p_dunning_object_id       IN NUMBER,
            p_dunning_level           IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_TASK_ID                 OUT NOCOPY NUMBER);

/*========================================================================
 * Clchang updated 09/19/2002 for Bug 2242346
 *   to create a callback,
 *      we got resource_id from iex_delinquencyies before;
 *      now, we get resource_id based on which agent owns the least tasks
 *           in PARTY level;
 *
 *========================================================================*/
PROCEDURE Get_Resource(p_api_version   IN  NUMBER,
                       p_commit        IN  VARCHAR2,
                       p_init_msg_list IN VARCHAR2 ,
                       p_party_id      IN  NUMBER,
                       x_resource_id   OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count     OUT NOCOPY NUMBER,
                       x_msg_data      OUT NOCOPY VARCHAR2);

/*
|| Overview:  This procedure is an extension of Call_FFM. Call_FFM only allows one bind variable/value
||            This will allow you to pass in unlimited bind variables in a name/value pair structure
||
|| Parameter: p_FULFILLMENT_BIND_TBL = name/value pairs for bind variables
||            p_template_id   = fulfillment template
||            p_method = Fulfillment Type, currently only 'EMAIL' is supported
||            p_party_id  = pk to hz_parties
||
|| Source Tables:  JTF_FM_TEMPLATE_CONTENTS, HZ_PARTIES, HZ_CONTACT_POINTS,
||                 jtf_FM_query_mes
||                 jtf_FM_query
||
|| Target Tables:
||
|| Creation date:       03/07/02 11:36:AM
||
|| Major Modifications: when               who                   what
||                      03/07/02 11:36:AM  raverma               created
||                      08/06/02 10:00:AM  pjgomes               Added parameter p_email to Send_Fulfillment api
||                      08/19/02 02:00:PM  pjgomes               Changed default value of p_email to NULL
*/
Procedure Send_Fulfillment(p_api_version             IN NUMBER := 1.0,
                           p_init_msg_list           IN VARCHAR2 ,
                           p_commit                  IN VARCHAR2 ,
                           p_FULFILLMENT_BIND_TBL    IN IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
                           p_template_id             IN NUMBER,
                           p_method                  IN VARCHAR2,
                           p_party_id                IN NUMBER,
                           p_user_id                 IN NUMBER DEFAULT NULL,
                           p_email                   IN VARCHAR2 DEFAULT NULL,
                           p_level                   IN VARCHAR2 DEFAULT NULL,
                           p_source_id               IN NUMBER DEFAULT NULL,
                           p_object_code             IN VARCHAR2 DEFAULT NULL,
                           p_object_id               IN NUMBER DEFAULT NULL,
                           x_return_status           OUT NOCOPY VARCHAR2,
                           x_msg_count               OUT NOCOPY NUMBER,
                           x_msg_data                OUT NOCOPY VARCHAR2,
                           x_REQUEST_ID              OUT NOCOPY NUMBER,
                           x_contact_destination     OUT NOCOPY varchar2,
                           x_contact_party_id        OUT NOCOPY NUMBER);


/*  This is a new procedure for 11.5.11.
 *  To replace FULFILLMENT by XML Publisher.
 *  Copied from Send_Fulfillemtn.
 */
Procedure Send_XML (       p_api_version             IN NUMBER := 1.0,
                           p_init_msg_list           IN VARCHAR2 ,
                           p_commit                  IN VARCHAR2 ,
                           p_resend                  IN VARCHAR2 ,
                           p_request_id              IN NUMBER DEFAULT NULL,
                           p_FULFILLMENT_BIND_TBL    IN IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
                           p_template_id             IN NUMBER,
                           p_method                  IN VARCHAR2,
                           p_party_id                IN NUMBER,
                           p_user_id                 IN NUMBER DEFAULT NULL,
                           p_email                   IN VARCHAR2 DEFAULT NULL,
                           p_level                   IN VARCHAR2 DEFAULT NULL,
                           p_source_id               IN NUMBER DEFAULT NULL,
                           p_object_code             IN VARCHAR2 DEFAULT NULL,
                           p_object_id               IN NUMBER DEFAULT NULL,
                           p_resource_id             IN NUMBER DEFAULT NULL,
			   p_dunning_mode            IN VARCHAR2 DEFAULT NULL,  -- added by gnramasa for bug 8489610 14-May-09
			   p_parent_request_id       IN NUMBER DEFAULT NULL,
                           p_org_id                  in number default null, -- added for bug 9151851
			   p_correspondence_date     IN DATE DEFAULT NULL,
			   x_return_status           OUT NOCOPY VARCHAR2,
                           x_msg_count               OUT NOCOPY NUMBER,
                           x_msg_data                OUT NOCOPY VARCHAR2,
                           x_REQUEST_ID              OUT NOCOPY NUMBER,
                           x_contact_destination     OUT NOCOPY varchar2,
                           x_contact_party_id        OUT NOCOPY NUMBER);

Procedure GetContactInfo(  p_api_version             IN NUMBER := 1.0,
                           p_init_msg_list           IN VARCHAR2 ,
                           p_commit                  IN VARCHAR2 ,
                           p_method                  IN VARCHAR2,
                           p_party_id                IN NUMBER,
                           p_dunning_level           IN VARCHAR2,
                           p_cust_site_use_id        IN VARCHAR2,
                           x_return_status           OUT NOCOPY VARCHAR2,
                           x_msg_count               OUT NOCOPY NUMBER,
                           x_msg_data                OUT NOCOPY VARCHAR2,
                           x_contact                 OUT NOCOPY VARCHAR2,
                           x_contact_party_id        OUT NOCOPY number);


Procedure GetContactPoint( p_api_version             IN NUMBER := 1.0,
                           p_init_msg_list           IN VARCHAR2 ,
                           p_commit                  IN VARCHAR2 ,
                           p_method                  IN VARCHAR2,
                           p_party_id                IN NUMBER,
                           x_return_status           OUT NOCOPY VARCHAR2,
                           x_msg_count               OUT NOCOPY NUMBER,
                           x_msg_data                OUT NOCOPY VARCHAR2,
                           x_contact                 OUT NOCOPY VARCHAR2);


Procedure CHK_QUERY_DATA(  p_query_id                IN NUMBER,
                           p_FULFILLMENT_BIND_TBL    IN IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
                           x_keep_flag               OUT NOCOPY NUMBER);

Procedure WriteLog      (  p_msg                     IN VARCHAR2 DEFAULT NULL,
                           p_flag                    IN NUMBER DEFAULT NULL);

procedure GET_DEFAULT_DUN_DEST(p_api_version              IN NUMBER := 1.0,
                             p_init_msg_list            IN VARCHAR2,
                             p_commit                   IN VARCHAR2,
                             p_level                    in varchar2,
                             p_source_id                in number,
                             p_send_method              in varchar2,
                             X_LOCATION_ID              OUT NOCOPY NUMBER,
                             X_CONTACT_ID               OUT NOCOPY NUMBER,
                             X_CONTACT_POINT_ID         OUT NOCOPY NUMBER,
                             x_return_status            OUT NOCOPY VARCHAR2,
                             x_msg_count                OUT NOCOPY NUMBER,
                             x_msg_data                 OUT NOCOPY VARCHAR2);

procedure GET_DEFAULT_DUN_DATA(p_api_version              IN NUMBER := 1.0,
                             p_init_msg_list            IN VARCHAR2,
                             p_commit                   IN VARCHAR2,
                             p_level                    in varchar2,
                             p_source_id                in number,
                             p_send_method              in varchar2,
                             p_resend                   IN VARCHAR2 ,
                             p_object_code              IN VARCHAR2 ,
                             p_object_id                IN NUMBER,
                             p_fulfillment_bind_tbl     in out nocopy IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
                             x_return_status            OUT NOCOPY VARCHAR2,
                             x_msg_count                OUT NOCOPY NUMBER,
                             x_msg_data                 OUT NOCOPY VARCHAR2);

--Start adding for bug 8489610 by gnramasa 14-May-09
Procedure gen_xml_data_dunning (p_request_id			IN  NUMBER ,
                                p_running_level			IN  VARCHAR2,
				p_dunning_plan_id		IN  NUMBER,
				p_dunning_mode			IN  VARCHAR2,     -- added by gnramasa for bug 8489610 28-May-09
	                        p_confirmation_mode		IN  VARCHAR2,     -- added by gnramasa for bug 8489610 28-May-09
				p_process_err_rec_only          IN  VARCHAR2,
				p_no_of_rec_prc_bylastrun	IN  NUMBER,
				p_no_of_succ_rec_bylastrun	IN  NUMBER,
				p_no_of_fail_rec_bylastrun	IN  NUMBER,
				x_no_of_rec_prc			OUT NOCOPY NUMBER,
				x_no_of_succ_rec		OUT NOCOPY NUMBER,
				x_no_of_fail_rec		OUT NOCOPY NUMBER);
--End adding for bug 8489610 by gnramasa 14-May-09

FUNCTION party_currency_code (p_party_id NUMBER) RETURN VARCHAR2;

FUNCTION acct_currency_code (p_account_id NUMBER) RETURN VARCHAR2;

FUNCTION site_currency_code (p_customer_site_use_id NUMBER) RETURN VARCHAR2;

FUNCTION party_amount_due_remaining(p_party_id NUMBER) RETURN NUMBER;

FUNCTION acct_amount_due_remaining(p_account_id NUMBER) RETURN NUMBER;

FUNCTION site_amount_due_remaining(p_customer_site_use_id NUMBER) RETURN NUMBER;

FUNCTION get_party_id(p_account_id NUMBER) RETURN NUMBER;

FUNCTION GET_DUNNING_LOCATION(P_SITE_USE_ID NUMBER) RETURN NUMBER;

END IEX_DUNNING_PVT;

/
