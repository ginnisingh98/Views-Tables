--------------------------------------------------------
--  DDL for Package PV_OPPORTUNITY_VHUK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_OPPORTUNITY_VHUK" AUTHID CURRENT_USER as
/* $Header: pvxvopts.pls 120.0 2005/05/27 16:10:01 appldev noship $ */

-- Start of Comments

-- Package name     : PV_OPPORTUNITY_VHUK
-- Purpose          : 1. Send out email notification to CM when an opportunity is created by Partner / VAD
--                    2. When an Opportunity is created or updated retrieve the partner related information
--                       associated with the campaign from AMS table and copy into
--                       AS_LEAD_ASSIGNMENTS table to keep track of the associated partner with the Campaign.
-- History          :
--
-- NOTE             :
-- End of Comments
--

g_wf_itemtype_notify        CONSTANT VARCHAR2(30) := 'PVOPTYHK';
g_wf_pcs_notify_cm          CONSTANT varchar2(30) := 'PV_NOTIFY_CM_DEF_PCS';
g_wf_pcs_notify_party       CONSTANT VARCHAR2(30) := 'PV_NOTIFY_PARTY_PCS';

g_wf_status_open	    CONSTANT VARCHAR2(20) := 'OPEN';
g_wf_status_closed	    CONSTANT VARCHAR2(20) := 'CLOSED';

g_r_status_active	    CONSTANT VARCHAR2(20) := 'ACTIVE';
g_r_status_unassigned       CONSTANT VARCHAR2(20) := 'UNASSIGNED';

g_r_notify_cm_type          CONSTANT VARCHAR2(20) := 'PTCR_FYI';
g_r_notify_all_type         CONSTANT VARCHAR2(20) := 'STCHG_FYI';

g_la_status_pt_created      CONSTANT varchar2(20) := 'PT_CREATED';

g_wf_attr_notify_role       CONSTANT VARCHAR2(40) := 'PV_NOTIFY_CM_NEW_OPPTY_ROLE';
g_wf_attr_opp_number        CONSTANT varchar2(30) := 'PV_OPP_NUMBER_ATTR';
g_wf_attr_opp_name          CONSTANT varchar2(30) := 'PV_OPP_NAME_ATTR';
g_wf_attr_opp_amt           CONSTANT varchar2(30) := 'PV_OPP_AMT_ATTR';
g_wf_attr_vendor_org_name   CONSTANT varchar2(30) := 'PV_VENDOR_ORG_NAME_ATTR';
g_wf_attr_customer_name     CONSTANT varchar2(30) := 'PV_CUSTOMER_NAME_ATTR';
g_wf_attr_partner_id        CONSTANT varchar2(30) := 'PV_PARTNER_ID_ATTR';
g_wf_attr_partner_name      CONSTANT varchar2(30) := 'PV_PARTNER_NAME_ATTR';
g_wf_attr_lead_id           CONSTANT varchar2(30) := 'PV_LEAD_ID_ATTR';

g_wf_attr_cm_notify_role    CONSTANT VARCHAR2(20) := 'PV_NOTIFY_CM_ROLE';
g_wf_attr_am_notify_role    CONSTANT VARCHAR2(20) := 'PV_NOTIFY_AM_ROLE';
g_wf_attr_pt_notify_role    CONSTANT VARCHAR2(20) := 'PV_NOTIFY_PT_ROLE';
g_wf_attr_ot_notify_role    CONSTANT VARCHAR2(20) := 'PV_NOTIFY_OTHER_ROLE';


g_wf_attr_from_status       CONSTANT varchar2(30) := 'PV_FROM_STATUS_ATTR';
g_wf_attr_to_status         CONSTANT varchar2(30) := 'PV_TO_STATUS_ATTR';
g_wf_attr_send_url          CONSTANT varchar2(30) := 'PV_CM_RESPOND_URL_ATTR';



g_entity			  VARCHAR2(20)  := 'OPPORTUNITY';

procedure Create_Opportunity_Post (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_oppty_header_rec    IN  AS_OPPORTUNITY_PUB.header_rec_type,
    p_salesforce_id       IN  NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2);

procedure Update_Opportunity_Pre (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_oppty_header_rec    IN  AS_OPPORTUNITY_PUB.header_rec_type,
    p_salesforce_id       IN  NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2);

procedure Notify_CM_On_Create_Oppty (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_oppty_header_rec    IN  AS_OPPORTUNITY_PUB.header_rec_type,
    p_salesforce_id       IN  NUMBER,
    p_relationship_type   IN  VARCHAR2,
    p_party_relation_id   IN  NUMBER,
    p_user_name		  IN  VARCHAR2,
    p_party_name	  IN  VARCHAR2,
    p_partner_type	  IN  VARCHAR2,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2);

procedure Send_Email_By_Workflow (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_user_name_tbl       IN  JTF_VARCHAR2_TABLE_100,
    p_user_type_tbl       IN  JTF_VARCHAR2_TABLE_100,
    p_username            IN  VARCHAR2,
    p_opp_amt             IN  VARCHAR2,
    p_opp_name            IN  VARCHAR2,
    p_customer_name       IN  VARCHAR2,
    p_lead_number         IN  NUMBER,
    p_from_status         IN  VARCHAR2,
    p_to_status           IN  VARCHAR2,
    p_vendor_org_name     IN  VARCHAR2,
    p_partner_names       IN  VARCHAR2,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2);

procedure StartWorkflow
(
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_itemKey             IN  VARCHAR2,
   p_itemType            IN  VARCHAR2,
   p_partner_id          IN  NUMBER,
   p_partner_name        IN  VARCHAR2,
   p_lead_id             IN  NUMBER,
   p_opp_name            IN  VARCHAR2,
   p_lead_number         IN  NUMBER,
   p_customer_id         IN  NUMBER,
   p_address_id          IN  NUMBER,
   p_customer_name       IN  VARCHAR2,
   p_creating_username   IN  VARCHAR2,
   p_bypass_cm_ok_flag   IN  VARCHAR2,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2
 );

PROCEDURE Notify_Party_On_Update_Oppty
(
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_oppty_header_rec    IN  AS_OPPORTUNITY_PUB.header_rec_type,
   p_salesforce_id       IN  NUMBER,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2
);



PROCEDURE Party_Msg_Send_Wf
(  itemtype    in varchar2,
   itemkey     in varchar2,
   actid       in number,
   funcmode    in varchar2,
   resultout   in OUT NOCOPY varchar2
);

Procedure Set_Oppty_Amt_Wf
(  itemtype    in varchar2,
   itemkey     in varchar2,
   actid       in number,
   funcmode    in varchar2,
   resultout   in OUT NOCOPY varchar2
);


procedure get_user_info
(  p_salesforce_id      IN  VARCHAR2,
   p_channel_code       IN  VARCHAR2,
   x_party_rel_id       OUT NOCOPY  NUMBER,
   x_relationship_type  OUT NOCOPY  VARCHAR2,
   x_user_name		OUT NOCOPY  VARCHAR2,
   x_party_name		OUT NOCOPY  VARCHAR2,
   x_party_type		OUT NOCOPY  VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2
);

procedure NOTIFY_ON_UPDATE_OPPTY_JBES (
          p_api_version_number  IN  NUMBER,
          p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
          p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          p_lead_id             IN  NUMBER,
          p_status              IN  VARCHAR2,
          p_lead_name           IN  VARCHAR2,
          p_customer_id         IN  NUMBER,
          p_total_amount        IN  NUMBER,
          p_salesforce_id       IN  NUMBER,
          x_return_status       OUT NOCOPY  VARCHAR2,
          x_msg_count           OUT NOCOPY  NUMBER,
          x_msg_data            OUT NOCOPY  VARCHAR2);

End PV_OPPORTUNITY_VHUK;

 

/
