--------------------------------------------------------
--  DDL for Package OZF_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvapps.pls 120.1 2007/12/24 06:46:00 ateotia ship $ */

TYPE approval_rec_type IS RECORD (
    OBJECT_TYPE           VARCHAR2(30)
   ,OBJECT_ID             NUMBER
   ,STATUS_CODE           VARCHAR2(30)
   ,ACTION_CODE           VARCHAR2(30)
   ,ACTION_PERFORMED_BY   NUMBER    -- fnd user_id
);

TYPE action_tbl_type is TABLE OF approval_rec_type;

TYPE approvers_rec_type IS RECORD (
    APPROVER_TYPE  VARCHAR2(30)     -- USER
   ,APPROVER_ID    NUMBER           -- fnd user_id
   ,APPROVER_LEVEL NUMBER
);

TYPE approvers_tbl_type is TABLE OF approvers_rec_type;

-- 'R12.1 Enhancement: Ship & Debit Request' by ateotia(+)
TYPE sd_access_rec_type IS RECORD (
    REQUEST_HEADER_ID   NUMBER,
    USER_ID             NUMBER,
    RESOURCE_ID         NUMBER,
    PERSON_ID           NUMBER,
    OWNER_FLAG          VARCHAR2(1),
    APPROVER_FLAG       VARCHAR2(1),
    ENABLED_FLAG        VARCHAR2(1)
);
-- 'R12.1 Enhancement: Ship & Debit Request' by ateotia(-)

---------------------------------------------------------------------
-- PROCEDURE
--    Update_User_Action
--
-- PURPOSE
-- PARAMETERS
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_User_Action(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER

   ,p_approval_rec      IN  approval_rec_type
);
---------------------------------------------------------------------
-- PROCEDURE
--    Get_Approvers
--
-- PURPOSE
-- PARAMETERS
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Approvers(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER

   ,p_approval_rec        IN  approval_rec_type
   ,x_approvers           OUT NOCOPY approvers_tbl_type
   ,x_final_approval_flag OUT NOCOPY VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    Add_Access
--
-- PURPOSE
--    adds approvers access to table
--
-- PARAMETERS
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Add_Access(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_return_status     OUT NOCOPY VARCHAR2

   ,p_approval_rec      IN  approval_rec_type
   ,p_approvers         IN  approvers_tbl_type );
---------------------------------------------------------------------
-- PROCEDURE
--    Revoke_Access
--
-- PURPOSE
--    Revokes access to current approvers
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Revoke_Access (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_object_type            IN  VARCHAR2
   ,p_object_id              IN  NUMBER
);
---------------------------------------------------------------------
-- PROCEDURE
--    Raise_Event
--
-- PURPOSE
--    Raise business event
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Raise_Event (
    x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_event_name             IN  VARCHAR2
   ,p_event_key              IN  VARCHAR2
   --,p_data                   IN  CLOB DEFAULT NULL
   ,p_approval_rec           IN  approval_rec_type);
---------------------------------------------------------------------
-- PROCEDURE
--    Send_Notification
--
-- PURPOSE
--    Sends notifications to approvers
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Send_Notification (
    p_api_version        IN  NUMBER
   ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status      OUT NOCOPY   VARCHAR2
   ,x_msg_data           OUT NOCOPY   VARCHAR2
   ,x_msg_count          OUT NOCOPY   NUMBER

   ,p_benefit_id         IN NUMBER
   ,p_partner_id         IN NUMBER
   ,p_msg_callback_api   IN VARCHAR2
   ,p_user_callback_api  IN VARCHAR2
   ,p_approval_rec       IN  approval_rec_type
);
---------------------------------------------------------------------
-- PROCEDURE
--    Process_User_Action

--
-- PURPOSE
--    Handles the approvals and rejections of objects
--
-- PARAMETERS
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE  Process_User_Action (
   p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

  ,x_return_status          OUT NOCOPY   VARCHAR2
  ,x_msg_data               OUT NOCOPY   VARCHAR2
  ,x_msg_count              OUT NOCOPY   NUMBER

  ,p_approval_rec           IN  approval_rec_type
  ,p_approver_id            IN  NUMBER
  ,x_final_approval_flag    OUT NOCOPY VARCHAR2
);

-- 'R12.1 Enhancement: Ship & Debit Request' by ateotia(+)
---------------------------------------------------------------------
-- PROCEDURE
--    Process_SD_Approval
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure Handles the approval of Ship & Debit Objects.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Process_SD_Approval (
   p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,p_object_id              IN  NUMBER
  ,p_action_code            IN  VARCHAR2
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_All_Approvers
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure calls ame_api2.getAllApprovers7 to get
--    Approver list from AME Setup.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_All_Approvers(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_transaction_id        IN  VARCHAR2
   ,p_transaction_type_key  IN  VARCHAR2
   ,x_approvers             OUT NOCOPY ame_util.approversTable2
   ,x_approval_flag         OUT NOCOPY VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER);

---------------------------------------------------------------------
-- PROCEDURE
--    Add_SD_Access
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure performs the required validation and invokes the
--    overloaded procedure which finally adds the record into
--    OZF_SD_REQUEST_ACCESS table.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Add_SD_Access(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_request_header_id IN  NUMBER
   ,p_user_id           IN  NUMBER
   ,p_resource_id       IN  NUMBER
   ,p_person_id         IN  NUMBER DEFAULT NULL
   ,p_owner_flag        IN  VARCHAR2
   ,p_approver_flag     IN  VARCHAR2
   ,p_enabled_flag      IN  VARCHAR2 DEFAULT 'Y'
   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_msg_data          OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------
-- PROCEDURE
--    Add_SD_Access
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure performs the required business logic and adds
--    the record into OZF_SD_REQUEST_ACCESS table.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Add_SD_Access(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_access_rec        IN  sd_access_rec_type
   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_msg_data          OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------
-- PROCEDURE
--    Raise_SD_Event
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure raises a business event to send different
--    notifications for Ship & Debit request.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Raise_SD_Event (
    p_event_key              IN  VARCHAR2
   ,p_object_id              IN  NUMBER
   ,p_action_code            IN  VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER);

---------------------------------------------------------------------
-- PROCEDURE
--    Send_Notification
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure sends the notifications based on p_action_code.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Send_SD_Notification (
    p_api_version        IN  NUMBER
   ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_object_id          IN  NUMBER
   ,p_action_code        IN  VARCHAR2
   ,x_return_status      OUT NOCOPY   VARCHAR2
   ,x_msg_data           OUT NOCOPY   VARCHAR2
   ,x_msg_count          OUT NOCOPY   NUMBER);

-- 'R12.1 Enhancement: Ship & Debit Request' by ateotia(-)


END OZF_APPROVAL_PVT;

/
