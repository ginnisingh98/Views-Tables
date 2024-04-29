--------------------------------------------------------
--  DDL for Package PV_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ASSIGNMENT_PVT" AUTHID CURRENT_USER as
/* $Header: pvasgnps.pls 120.0 2005/05/27 16:09:41 appldev noship $ */

type oppty_routing_log_rec_type  is RECORD
(
   oppty_routing_log_id     NUMBER,
   event                    VARCHAR2(15),
   lead_id                  NUMBER,
   lead_workflow_id         NUMBER,
   routing_type             VARCHAR2(30),
   latest_routing_flag      VARCHAR2(1),
   bypass_cm_flag           VARCHAR2(1),
   lead_assignment_id       NUMBER,
   event_date               DATE,
   vendor_user_id           NUMBER,
   pt_contact_user_id       NUMBER,
   user_response            VARCHAR2(30),
   reason_code              VARCHAR2(30),
   user_type                VARCHAR2(6),
   vendor_business_unit_id  NUMBER
);

type attrib_values_rec_type is RECORD
(
   org_type                VARCHAR2(30),
   am_org_name             varchar2(100),
   pt_org_party_id         NUMBER,
   lead_id                 NUMBER,
   lead_number             NUMBER,
   entity_name             VARCHAR2(240),
   entity_amount           VARCHAR2(300),
   customer_id             NUMBER,
   address_id              NUMBER,
   customer_name           VARCHAR2(360),
   assignment_type         VARCHAR2(30),
   assignment_type_mean    VARCHAR2(100),
   bypass_cm_ok_flag       VARCHAR2(1),
   process_rule_id         NUMBER,
   process_name            VARCHAR2(100)
);


type assignment_log_rec_type   is RECORD
(
   ASSIGNMENT_ID           NUMBER,
   LAST_UPDATE_DATE        DATE,
   LAST_UPDATED_BY         NUMBER,
   CREATION_DATE           DATE,
   CREATED_BY              NUMBER,
   LAST_UPDATE_LOGIN       NUMBER,
   OBJECT_VERSION_NUMBER   NUMBER,
   LEAD_ASSIGNMENT_ID      NUMBER,
   PARTNER_ID              NUMBER,
   ASSIGN_SEQUENCE         NUMBER,
   CM_ID                   NUMBER,
   LEAD_ID                 NUMBER,
   DURATION                NUMBER,
   FROM_LEAD_STATUS        VARCHAR2(30),
   TO_LEAD_STATUS          VARCHAR2(30),
   STATUS                  VARCHAR2(30),
   STATUS_DATE             DATE,
   WF_ITEM_TYPE            VARCHAR2(30),
   WF_ITEM_KEY             VARCHAR2(30),
   WF_PT_USER              VARCHAR2(30),
   WF_CM_USER              VARCHAR2(30),
   WORKFLOW_ID             NUMBER,
   ERROR_TXT               VARCHAR2(255),
   TRANS_TYPE              NUMBER(15),
   STATUS_CHANGE_COMMENTS  VARCHAR2(60)
);

   -- ---------------------------------------------------------------------------------
   -- Initialize record of table. This is not necessary prior to Oracle 10g.
   -- ---------------------------------------------------------------------------------

type party_notify_rec_tbl_type is RECORD
(
   WF_ITEM_TYPE                   pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type(),
   WF_ITEM_KEY                    pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type(),
   LEAD_ASSIGNMENT_ID             pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type(),
   NOTIFICATION_TYPE              pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type(),
   USER_ID                        pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type(),
   USER_NAME                      pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type(),
   RESOURCE_ID                    pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type(),
   RESPONSE_DATE                  pv_assignment_pub.g_date_table_type    := pv_assignment_pub.g_date_table_type(),
   RESOURCE_RESPONSE              pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type(),
   DECISION_MAKER_FLAG            pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type()
);


PROCEDURE bulk_cr_party_notification(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_party_notify_rec_tbl   IN   party_notify_rec_tbl_type,
    X_Return_Status          OUT NOCOPY   VARCHAR2,
    X_Msg_Count              OUT NOCOPY   NUMBER,
    X_Msg_Data               OUT NOCOPY   VARCHAR2
);


PROCEDURE Create_assignment_log_row(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_assignment_log_rec     IN   assignment_log_rec_type,
    X_assignment_id          OUT  NOCOPY   NUMBER,
    X_Return_Status          OUT  NOCOPY   VARCHAR2,
    X_Msg_Count              OUT  NOCOPY   NUMBER,
    X_Msg_Data               OUT  NOCOPY   VARCHAR2
    );


PROCEDURE update_party_response(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_rowid                  IN   ROWID,
    p_lead_assignment_id     IN   NUMBER,
    p_party_resource_id      IN   NUMBER,
    p_response               IN   VARCHAR2,
    p_reason_code            IN   VARCHAR2,
    p_rank                   IN   NUMBER,
    X_Return_Status          OUT  NOCOPY   VARCHAR2,
    X_Msg_Count              OUT  NOCOPY   NUMBER,
    X_Msg_Data               OUT  NOCOPY   VARCHAR2
    );


PROCEDURE bulk_set_party_notify_id(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_itemtype               IN   VARCHAR2,
    p_itemkey                IN   VARCHAR2,
    p_notify_type            IN   VARCHAR2,
    X_Return_Status          OUT NOCOPY   VARCHAR2,
    X_Msg_Count              OUT NOCOPY   NUMBER,
    X_Msg_Data               OUT NOCOPY   VARCHAR2
    );


procedure UpdateAssignment (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_action              IN  VARCHAR2
   ,p_lead_assignment_id  IN  number
   ,p_status_date         IN  DATE
   ,p_status              IN  VARCHAR2
   ,p_reason_code         IN  VARCHAR2
   ,p_rank                IN  NUMBER
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2);


procedure removeRejectedFromAccess (
      p_api_version_number   IN  NUMBER
      ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
      ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
      ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
      ,p_itemtype            IN  VARCHAR2
      ,p_itemkey             IN  VARCHAR2
      ,p_partner_id          IN  VARCHAR2
      ,x_msg_count           OUT NOCOPY  NUMBER
      ,x_msg_data            OUT NOCOPY  VARCHAR2
      ,x_return_status       OUT NOCOPY  VARCHAR2);

procedure SetPartnerAttributes  (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemType            IN  VARCHAR2
   ,p_itemKey             IN  VARCHAR2
   ,p_partner_id          IN  NUMBER
   ,p_partner_org         IN  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2);

procedure setTimeout  (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemtype            IN  VARCHAR2
   ,p_itemkey             IN  VARCHAR2
   ,p_partner_id          IN  NUMBER
   ,p_timeoutType         IN  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2);

procedure set_offered_attributes (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemType            IN  VARCHAR2
   ,p_itemKey             IN  VARCHAR2
   ,p_partner_id          IN  NUMBER
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2);

procedure update_routing_stage (
   p_api_version_number    IN  NUMBER
   ,p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemtype             IN  VARCHAR2
   ,p_itemkey              IN  VARCHAR2
   ,p_routing_stage        IN  VARCHAR2
   ,p_active_but_open_flag IN  VARCHAR2
   ,x_msg_count            OUT NOCOPY  NUMBER
   ,x_msg_data             OUT NOCOPY  VARCHAR2
   ,x_return_status        OUT NOCOPY  VARCHAR2);

procedure StartWorkflow (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_itemKey             IN  VARCHAR2,
   p_itemType            IN  VARCHAR2,
   p_creating_username   IN  VARCHAR2,
   p_attrib_values_rec   IN  ATTRIB_VALUES_REC_TYPE,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2);


procedure validateResponse (
      p_api_version_number   IN  NUMBER
      ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
      ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
      ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
      ,p_response_code       IN  VARCHAR2
      ,p_routing_status      IN  VARCHAR2
      ,p_decision_maker_flag IN  VARCHAR2
      ,p_notify_type         IN  VARCHAR2
      ,x_msg_count           OUT NOCOPY  NUMBER
      ,x_msg_data            OUT NOCOPY  VARCHAR2
      ,x_return_status       OUT NOCOPY  VARCHAR2);

procedure set_current_routing_flag (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_itemKey             in  varchar2,
   p_entity              IN  VARCHAR2,
   p_entity_id           IN  NUMBER,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2);

PROCEDURE send_notification(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_itemtype               IN   VARCHAR2,
    p_itemkey                IN   VARCHAR2,
    p_activity_id            IN   NUMBER,
    p_route_stage            IN   VARCHAR2,
    p_partner_id             IN   NUMBER,
    X_Return_Status          OUT  NOCOPY   VARCHAR2,
    X_Msg_Count              OUT  NOCOPY   NUMBER,
    X_Msg_Data               OUT  NOCOPY   VARCHAR2);

procedure AbandonWorkflow (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_creating_username   IN  VARCHAR2,
   p_attrib_values_rec   IN  attrib_values_rec_type,
   p_partner_org_name    IN  VARCHAR2,
   p_action_reason       IN  VARCHAR2,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2);

PROCEDURE Create_Oppty_Routing_Log_Row
(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_oppty_routing_log_rec  IN   oppty_routing_log_rec_type,
    X_Return_Status          OUT  NOCOPY VARCHAR2,
    X_Msg_Count              OUT  NOCOPY NUMBER,
    X_Msg_Data               OUT  NOCOPY VARCHAR2
);

End PV_ASSIGNMENT_PVT;

 

/
