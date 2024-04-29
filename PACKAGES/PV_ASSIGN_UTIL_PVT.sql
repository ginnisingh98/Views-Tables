--------------------------------------------------------
--  DDL for Package PV_ASSIGN_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ASSIGN_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: pvvautls.pls 120.1 2006/01/10 12:17:09 amaram noship $ */
-- Start of Comments

-- Package name     : PV_ASSIGN_UTIL_PVT
-- Purpose          :
-- History          :
--
-- NOTE             :
-- End of Comments
--

-- TYPE my_number_table IS TABLE OF NUMBER;

TYPE party_notify_rec_type is RECORD
(
   PARTY_NOTIFICATION_ID          NUMBER,
   LAST_UPDATE_DATE                DATE,
   LAST_UPDATED_BY                 NUMBER,
   CREATION_DATE                   DATE,
   CREATED_BY                      NUMBER,
   LAST_UPDATE_LOGIN               NUMBER,
   OBJECT_VERSION_NUMBER           NUMBER,
   REQUEST_ID                      NUMBER,
   PROGRAM_APPLICATION_ID          NUMBER,
   PROGRAM_ID                      NUMBER,
   PROGRAM_UPDATE_DATE             DATE,
   NOTIFICATION_ID                 NUMBER,
   NOTIFICATION_TYPE               VARCHAR2(30),
   LEAD_ASSIGNMENT_ID              NUMBER,
   WF_ITEM_TYPE                    VARCHAR2(30),
   WF_ITEM_KEY                     VARCHAR2(30),
   USER_ID                         NUMBER,
   USER_NAME                       VARCHAR2(30),
   RESOURCE_ID                     NUMBER,
   DECISION_MAKER_FLAG             VARCHAR2(1),
   RESOURCE_RESPONSE               VARCHAR2(30),
   RESPONSE_DATE                   DATE,
   ATTRIBUTE_CATEGORY              VARCHAR2(30),
   ATTRIBUTE1                      VARCHAR2(150),
   ATTRIBUTE2                      VARCHAR2(150),
   ATTRIBUTE3                      VARCHAR2(150),
   ATTRIBUTE4                      VARCHAR2(150),
   ATTRIBUTE5                      VARCHAR2(150),
   ATTRIBUTE6                      VARCHAR2(150),
   ATTRIBUTE7                      VARCHAR2(150),
   ATTRIBUTE8                      VARCHAR2(150),
   ATTRIBUTE9                      VARCHAR2(150),
   ATTRIBUTE10                     VARCHAR2(150),
   ATTRIBUTE11                     VARCHAR2(150),
   ATTRIBUTE12                     VARCHAR2(150),
   ATTRIBUTE13                     VARCHAR2(150),
   ATTRIBUTE14                     VARCHAR2(150),
   ATTRIBUTE15                     VARCHAR2(150)
);


TYPE assignment_rec_type   is RECORD
(
   LEAD_ASSIGNMENT_ID              NUMBER,
   LAST_UPDATE_DATE                DATE,
   LAST_UPDATED_BY                 NUMBER,
   CREATION_DATE                   DATE,
   CREATED_BY                      NUMBER,
   LAST_UPDATE_LOGIN               NUMBER,
   OBJECT_VERSION_NUMBER           NUMBER,
   LEAD_ID                         NUMBER,
   PARTNER_ID                      NUMBER,
   PARTNER_ACCESS_CODE             VARCHAR2 (30),
   RELATED_PARTY_ID                NUMBER,
   RELATED_PARTY_ACCESS_CODE       VARCHAR2 (30),
   ASSIGN_SEQUENCE                 NUMBER,
   STATUS_DATE                     DATE,
   STATUS                          VARCHAR2 (20),
   REASON_CODE                     VARCHAR2 (30),
   SOURCE_TYPE                     VARCHAR2 (30),
   WF_ITEM_TYPE                    VARCHAR2 (20),
   WF_ITEM_KEY                     VARCHAR2 (20),
   ERROR_TXT                       VARCHAR2 (200)
);


TYPE lead_workflow_rec_type   is RECORD
(
   LEAD_WORKFLOW_ID                NUMBER(15),
   LAST_UPDATE_DATE                DATE,
   LAST_UPDATED_BY                 NUMBER(15),
   CREATION_DATE                   DATE,
   CREATED_BY                      NUMBER(15),
   LAST_UPDATE_LOGIN               NUMBER(15),
   OBJECT_VERSION_NUMBER           NUMBER,
   ENTITY                          VARCHAR2(30),
   LEAD_ID                         NUMBER(15),
   WF_ITEM_TYPE                    VARCHAR2(30),
   WF_ITEM_KEY                     VARCHAR2(30),
   WF_STATUS                       VARCHAR2(30),
   MATCHED_DUE_DATE                DATE,
   OFFERED_DUE_DATE                DATE,
   BYPASS_CM_OK_FLAG               VARCHAR2(30),
   LATEST_ROUTING_FLAG             VARCHAR2(1),
   ROUTING_STATUS                  VARCHAR2(30),
   ROUTING_TYPE                    VARCHAR2(30),
   FAILURE_CODE                    VARCHAR2(30),
   FAILURE_MESSAGE                 VARCHAR2(500)
);

type resource_details_rec_type is RECORD
(
   NOTIFICATION_TYPE              VARCHAR2(30),
   DECISION_MAKER_FLAG            VARCHAR2(1),
   USER_ID                        NUMBER,
   PERSON_ID                      NUMBER,  -- per_people_x.person_id for EMPLOYEE, partner_cont_party_id for PARTY
   PERSON_TYPE                    VARCHAR2(30),  -- PARTY or EMPLOYEE
   USER_NAME                      VARCHAR2(1000),
   RESOURCE_ID                    NUMBER
);

type resource_details_tbl_type is TABLE OF RESOURCE_DETAILS_REC_TYPE;

PROCEDURE Create_party_notification(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_party_notify_Rec       IN   PV_ASSIGN_UTIL_Pvt.party_notify_rec_type,
    X_PARTY_NOTIFICATION_ID  OUT  NOCOPY   NUMBER,
    X_Return_Status          OUT  NOCOPY   VARCHAR2,
    X_Msg_Count              OUT  NOCOPY   NUMBER,
    X_Msg_Data               OUT  NOCOPY   VARCHAR2
    );


procedure create_lead_workflow_row (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_workflow_rec        IN  LEAD_WORKFLOW_REC_TYPE
   ,x_itemkey             OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2);


procedure create_lead_assignment_row (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_assignment_rec      IN  ASSIGNMENT_REC_TYPE
   ,x_lead_assignment_id  OUT NOCOPY  NUMBER
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2);


procedure delete_lead_assignment_row (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_lead_assignment_id  IN  NUMBER
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2);


procedure get_partner_info (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_mode                IN  VARCHAR2,                                  -- VENDOR or EXTERNAL
   p_partner_id          IN  NUMBER,
   p_entity              IN  VARCHAR2,
   p_entity_id           IN  NUMBER,
   p_retrieve_mode       IN  VARCHAR2,
   x_rs_details_tbl      IN  OUT NOCOPY  resource_details_tbl_type,
   x_vad_id              IN OUT NOCOPY  NUMBER,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2);

procedure GetWorkflowID   (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_lead_id             IN  NUMBER
   ,p_entity              IN  VARCHAR2
   ,x_itemType            OUT NOCOPY  VARCHAR2
   ,x_itemKey             OUT NOCOPY  VARCHAR2
   ,x_routing_status      OUT NOCOPY  VARCHAR2
   ,x_wf_status           OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2);

procedure UpdateAccess
    ( p_api_version_number  IN   NUMBER,
      p_init_msg_list       IN   VARCHAR2     := FND_API.G_FALSE,
      p_commit              IN   VARCHAR2     := FND_API.G_FALSE,
      p_validation_level    IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_itemtype            IN   VARCHAR2,
      p_itemkey             IN   VARCHAR2,
      p_current_username    IN   VARCHAR2,
      p_lead_id             IN   NUMBER,
      p_customer_id         IN   NUMBER,
      p_address_id          IN   NUMBER,
      p_resource_id         IN   NUMBER,
      p_access_type         IN   NUMBER,
      p_access_action       IN   NUMBER,
      x_access_id           OUT  NOCOPY   NUMBER,
      x_return_status       OUT  NOCOPY   VARCHAR2,
      x_msg_count           OUT  NOCOPY   NUMBER,
      x_msg_data            OUT  NOCOPY   VARCHAR2);

procedure Log_assignment_status (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_assignment_rec      IN  ASSIGNMENT_REC_TYPE
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2);

PROCEDURE removePreferedPartner (
      p_api_version_number  IN  NUMBER
   ,  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,  p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,  p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,  p_lead_id             IN  NUMBER
   ,  p_item_type           IN  VARCHAR2
   ,  p_item_key            IN  VARCHAR2
   ,  p_partner_id          IN  NUMBER
   ,  x_return_status       OUT NOCOPY  VARCHAR2
   ,  x_msg_count           OUT NOCOPY  NUMBER
   ,  x_msg_data            OUT NOCOPY  VARCHAR2) ;


procedure checkforErrors (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemtype            IN  VARCHAR2
   ,p_itemkey             IN  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2);



End PV_ASSIGN_UTIL_PVT;

 

/
