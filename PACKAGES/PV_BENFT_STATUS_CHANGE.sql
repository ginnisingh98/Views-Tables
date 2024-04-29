--------------------------------------------------------
--  DDL for Package PV_BENFT_STATUS_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_BENFT_STATUS_CHANGE" AUTHID CURRENT_USER AS
/* $Header: pvstchgs.pls 115.3 2003/12/04 01:42:54 pklin noship $ */

PROCEDURE STATUS_CHANGE_NOTIFICATION(
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   P_BENEFIT_ID          IN  NUMBER,
   P_STATUS              IN  VARCHAR2,
   P_ENTITY_ID           IN  NUMBER,
   P_PARTNER_ID          IN  NUMBER,
   p_msg_callback_api    IN  VARCHAR2,
   p_user_callback_api   IN  VARCHAR2,
   p_user_role           IN  VARCHAR2 DEFAULT NULL,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2);

PROCEDURE STATUS_CHANGE_LOGGING(
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   P_BENEFIT_ID          IN  NUMBER,
   P_STATUS              IN  VARCHAR2,
   P_ENTITY_ID           IN  NUMBER,
   P_PARTNER_ID          IN  NUMBER,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2);

PROCEDURE REFERRAL_SET_MSG_ATTRS(
   p_itemtype            IN VARCHAR2,
   p_itemkey             IN VARCHAR2,
   P_ENTITY_ID           IN  NUMBER,
   P_USER_TYPE           IN  VARCHAR2,
   P_STATUS              IN  VARCHAR2);

FUNCTION REFERRAL_RETURN_USERLIST(
   p_benefit_type        IN VARCHAR2,
   P_ENTITY_ID           IN  NUMBER,
   P_USER_ROLE           IN  VARCHAR2,
   P_STATUS              IN  VARCHAR2) RETURN VARCHAR2;

FUNCTION STATUS_CHANGE_SUB(
   p_subscription_guid in     raw,
   p_event             in out nocopy wf_event_t) return varchar2;

FUNCTION CLAIM_REF_STATUS_CHANGE_SUB(
   p_subscription_guid in     raw,
   p_event             in out nocopy wf_event_t) return varchar2;

PROCEDURE STATUS_CHANGE_RAISE (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_event_name       IN VARCHAR2,
    p_benefit_id       IN NUMBER,
    p_entity_id        IN NUMBER,
    p_status_code      IN VARCHAR2,
    p_partner_id       IN NUMBER,
    p_msg_callback_api	IN VARCHAR2,
    p_user_callback_api	IN VARCHAR2,
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_count        OUT NOCOPY  NUMBER,
    x_msg_data         OUT NOCOPY  VARCHAR2);



procedure GET_DECLINE_REASON (document_id in varchar2,
                              display_type in varchar2,
                              document in out nocopy varchar2,
                              document_type in out nocopy varchar2);

procedure GET_PRODUCTS (document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2);


END;

 

/
