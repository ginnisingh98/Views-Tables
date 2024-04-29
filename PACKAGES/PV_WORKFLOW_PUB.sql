--------------------------------------------------------
--  DDL for Package PV_WORKFLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_WORKFLOW_PUB" AUTHID CURRENT_USER as
/* $Header: pvxwffns.pls 120.1 2006/05/31 04:13:56 dhii noship $ */
-- Start of Comments

-- Package name     : PV_WORKFLOW_PUB
-- Purpose          :
-- History          :
--
-- NOTE             :
-- End of Comments
--

-- WF itemtypes

g_wf_itemtype_pvasgnmt          CONSTANT VARCHAR2(30) := 'PVASGNMT';


-- WF process

g_wf_pcs_initiate_assignment    CONSTANT varchar2(30) := 'PV_INITIATE_ASSGNMNT_PCS';
g_wf_pcs_abandon_fyi            CONSTANT varchar2(30) := 'PV_PRTNR_ABNDN_FYI_PCS';
g_wf_pcs_withdraw_fyi           CONSTANT varchar2(30) := 'PV_CM_ACTIVE_WITHDRAW_FYI_PCS';

-- WF functions

g_wf_fn_cm_response_block    CONSTANT varchar2(30) := 'PV_CM_RESPONSE_BLOCK_FN';
g_wf_fn_pt_response_block    CONSTANT varchar2(30) := 'PV_PT_RESPONSE_BLOCK_FN';

-- WF attributes

g_wf_attr_bypass_cm_approval     CONSTANT varchar2(30) := 'PV_BYPASS_CM_APPROVAL_ATTR';
g_wf_attr_email_enabled          CONSTANT varchar2(30) := 'PV_EMAIL_ENABLED_ATTR';
g_wf_attr_assignment_type        CONSTANT varchar2(30) := 'PV_ASSIGNMENT_TYPE_ATTR';
g_wf_attr_assign_type_mean       CONSTANT varchar2(30) := 'PV_ASSIGN_TYPE_MEAN_ATTR';
g_wf_attr_customer_id            CONSTANT varchar2(30) := 'PV_CUSTOMER_ID_ATTR';
g_wf_attr_customer_name          CONSTANT varchar2(30) := 'PV_CUSTOMER_NAME_ATTR';
g_wf_attr_address_id             CONSTANT varchar2(30) := 'PV_CUST_ADDR_ID_ATTR';
g_wf_attr_matched_timeout        CONSTANT varchar2(30) := 'PV_MATCHED_TIMEOUT_ATTR';
g_wf_attr_matched_timeout_dt     CONSTANT varchar2(30) := 'PV_MATCHED_TIMEOUT_DATE_ATTR';
g_wf_attr_offered_timeout        CONSTANT varchar2(30) := 'PV_OFFERED_TIMEOUT_ATTR';
g_wf_attr_offered_timeout_dt     CONSTANT varchar2(30) := 'PV_OFFERED_TIMEOUT_DATE_ATTR';
g_wf_attr_current_serial_rank    CONSTANT varchar2(30) := 'PV_SERIAL_RANK_ATTR';
g_wf_attr_next_serial_rank       CONSTANT varchar2(30) := 'PV_NEXT_SERIAL_RANK_ATTR';
g_wf_attr_partner_org            CONSTANT varchar2(30) := 'PV_PARTNER_ORG_ATTR';
g_wf_attr_partner_id             CONSTANT varchar2(30) := 'PV_PARTNER_ID_ATTR';
g_wf_attr_opportunity_id         CONSTANT varchar2(30) := 'PV_OPP_ID_ATTR';
g_wf_attr_entity_name            CONSTANT varchar2(30) := 'PV_OPP_NAME_ATTR';
g_wf_attr_entity_amount          CONSTANT varchar2(30) := 'PV_OPP_AMOUNT_ATTR';
g_wf_attr_opp_number             CONSTANT varchar2(30) := 'PV_OPP_NUMBER_ATTR';
g_wf_attr_cm_respond_url         CONSTANT varchar2(30) := 'PV_CM_RESPOND_URL_ATTR';
g_wf_attr_offer_outcome          CONSTANT varchar2(30) := 'PV_OFFER_OUTCOME_ATTR';
g_wf_attr_pt_outcome             CONSTANT varchar2(30) := 'PV_PT_OUTCOME_ATTR';
g_wf_attr_routing_outcome        CONSTANT varchar2(30) := 'PV_ROUTING_OUTCOME_ATTR';
g_wf_attr_organization_type      CONSTANT varchar2(30) := 'PV_ORG_TYPE_ATTR';
g_wf_attr_ext_org_party_id       CONSTANT varchar2(30) := 'PV_EXT_ORG_PARTY_ID_ATTR';
g_wf_attr_vendor_org_name        CONSTANT varchar2(30) := 'PV_VENDOR_NAME_ATTR';
g_wf_attr_responding_cm          CONSTANT varchar2(30) := 'PV_RESPONDING_CM_ATTR';
g_wf_attr_action_reason          CONSTANT varchar2(30) := 'PV_ACTION_REASON_ATTR';
g_wf_attr_wf_activity_id         CONSTANT varchar2(30) := 'PV_WF_ACTIVITY_ID_ATTR';
g_wf_attr_process_rule_id        CONSTANT varchar2(30) := 'PV_PROCESS_RULE_ATTR';

-- used only by the PV_WORKFLOW_PUB.SET_NOTIFIED_PARTY_NOTIFY_ID api
g_wf_attr_pvt_notify_type        CONSTANT varchar2(30) := 'PV_NOTIFY_TYPE_ATTR_PVT';

-- used only by the PV_WORKFLOW_PUB.SET_TIMEOUT api
g_wf_attr_pvt_timeout_type        CONSTANT varchar2(30) := 'PV_TIMEOUT_TYPE_ATTR_PVT';


-- start WF lookup codes -------------------------------------------------------------------

-- timeout code

g_wf_timeout                CONSTANT  varchar2(30) := '#TIMEOUT';
g_wf_complete               CONSTANT  varchar2(30) := 'COMPLETE';

-- CM response lookup

g_wf_lkup_cm_approved       CONSTANT varchar2(30) := 'CM_APPROVED';
g_wf_lkup_cm_rejected       CONSTANT varchar2(30) := 'CM_REJECTED';
g_wf_lkup_cm_timeout        CONSTANT varchar2(30) := 'CM_TIMEOUT';

-- matched outcome lookup

g_wf_lkup_match_approved       CONSTANT varchar2(30) := 'MATCH_APPROVED';
g_wf_lkup_match_rejected       CONSTANT varchar2(30) := 'MATCH_REJECTED';
g_wf_lkup_match_timedout       CONSTANT varchar2(30) := 'MATCH_TIMEDOUT';
g_wf_lkup_match_withdrawn      CONSTANT varchar2(30) := 'MATCH_WITHDRAWN';

-- offered outcome lookup

g_wf_lkup_offer_approved       CONSTANT varchar2(30) := 'PT_APPROVED';
g_wf_lkup_offer_rejected       CONSTANT varchar2(30) := 'PT_REJECTED';
g_wf_lkup_offer_timedout       CONSTANT varchar2(30) := 'PT_TIMEOUT';
g_wf_lkup_offer_withdrawn      CONSTANT varchar2(30) := 'OFFER_WITHDRAWN';
g_wf_lkup_offer_lost_chance    CONSTANT varchar2(30) := 'LOST_CHANCE';
g_wf_lkup_offer_cm_app_for_pt  CONSTANT varchar2(30) := 'CM_APP_FOR_PT';

-- assignment type lookup

g_wf_lkup_single               CONSTANT varchar2(30) := 'SINGLE';
g_wf_lkup_serial               CONSTANT varchar2(30) := 'SERIAL';
g_wf_lkup_broadcast            CONSTANT varchar2(30) := 'BROADCAST';
g_wf_lkup_joint                CONSTANT varchar2(30) := 'JOINT';

-- standard boolean type lookup

g_wf_lkup_true                 CONSTANT varchar2(1)  := 'T';
g_wf_lkup_false                CONSTANT varchar2(1)  := 'F';

-- standard yes/no type lookup

g_wf_lkup_yes                  CONSTANT varchar2(1)  := 'Y';
g_wf_lkup_no                   CONSTANT varchar2(1)  := 'N';


-- end WF lookup codes -------------------------------------------------------------------

procedure BYPASS_CM_APPROVAL_CHK (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure SET_TIMEOUT (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure WAIT_ON_MATCH (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure GET_ASSIGNMENT_TYPE (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure SERIAL_NEXT_PARTNER (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure WAIT_ON_OFFER (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure PROCESS_MATCH_OUTCOME (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure PROCESS_OFFER_OUTCOME (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure BYPASS_PT_APPROVAL_CHK (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure NEED_PT_OK_CHK (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure WRAPUP_PROCESSING (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure ABANDON_FYI (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY  varchar2);

procedure WITHDRAW_FYI (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2);


procedure GET_PRODUCTS (document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2);

procedure GET_OPPTY_CONTACTS (document_id in varchar2,
                              display_type in varchar2,
                              document in out nocopy varchar2,
                              document_type in out nocopy varchar2);

procedure GET_PUBLISH_NOTES (document_id in varchar2,
                              display_type in varchar2,
                              document in out nocopy varchar2,
                              document_type in out nocopy varchar2);
procedure get_assign_type_mean (
                        document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2);

procedure get_vendor_org_name (
                        document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2);

procedure get_accept_user_name (
                        document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2);

procedure get_accept_user_org (
                        document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2);

End PV_WORKFLOW_PUB;

 

/
