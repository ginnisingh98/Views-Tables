--------------------------------------------------------
--  DDL for Package PV_ATTR_VALIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ATTR_VALIDATION_PUB" AUTHID CURRENT_USER as
/* $Header: pvvatvts.pls 115.2 2002/12/10 22:36:02 vansub ship $*/

g_pkg_name                  CONSTANT VARCHAR2(30) := 'PV_ATTR_VALIDATION_PUB';


g_wf_itemtype_notify        CONSTANT VARCHAR2(30) := 'PVOPTYHK';
g_wf_pcs_notify_cm          CONSTANT varchar2(30) := 'PV_ATTR_CHG_CM_NOTIFY_PCS';

g_wf_status_open	    CONSTANT VARCHAR2(20) := 'OPEN';
g_wf_status_closed	    CONSTANT VARCHAR2(20) := 'CLOSED';


g_wf_attr_partner_name      CONSTANT varchar2(30) := 'PV_PARTNER_NAME_ATTR';
g_wf_attr_attribute_name    CONSTANT varchar2(30) := 'PV_ATTRIBUTE_NAME_ATTR';
g_wf_attr_prtnr_cont_name   CONSTANT varchar2(30) := 'PV_PARTNER_CONTACT_NAME_ATTR';

g_wf_attr_cm_notify_role    CONSTANT VARCHAR2(30) := 'PV_NOTIFY_CM_NEW_OPPTY_ROLE';


g_wf_attr_send_url          CONSTANT varchar2(30) := 'PV_CM_RESPOND_URL_ATTR';

g_partner_entity	    CONSTANT varchar2(30) := 'PARTNER';

PROCEDURE attribute_validate(
   p_api_version_number         IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2  := FND_API.g_false,
   p_commit                     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
   p_attribute_id               IN  NUMBER,
   p_entity			IN  VARCHAR2,
   p_entity_id			IN  VARCHAR2,
   p_user_id			IN  VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);


procedure StartWorkflow
(
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_user_name_tbl	 IN  JTF_VARCHAR2_TABLE_1000,
   p_attribute_id	 IN  VARCHAR2,
   p_attribute_name	 IN  VARCHAR2,
   p_partner_name	 IN  VARCHAR2,
   p_pt_contact_name     IN  VARCHAR2,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2
 );








END PV_ATTR_VALIDATION_PUB;

 

/
