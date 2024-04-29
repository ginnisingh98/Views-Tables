--------------------------------------------------------
--  DDL for Package DPP_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvapps.pls 120.4.12010000.2 2009/10/27 11:22:49 rvkondur ship $ */

TYPE approval_rec_type IS RECORD (
    OBJECT_TYPE           VARCHAR2(30)
   ,OBJECT_ID             NUMBER
   ,STATUS_CODE           VARCHAR2(30)
   ,ACTION_CODE           VARCHAR2(30)
   ,ACTION_PERFORMED_BY   NUMBER    -- fnd user_id
);

TYPE approvers_rec_type IS RECORD (
    APPROVER_TYPE  VARCHAR2(30)     -- USER
   ,APPROVER_ID    NUMBER           -- fnd user_id
   ,APPROVER_LEVEL NUMBER
);

TYPE approvers_tbl_type is TABLE OF approvers_rec_type;

  TYPE approverRecord is record(
    user_id number,
    person_id number,
    first_name varchar2(150),
    last_name varchar2(150),
    api_insertion varchar2(1),
    authority varchar2(1),
    approval_status varchar2(50),
    approval_type_id number,
    group_or_chain_id number,
    occurrence number,
    source varchar2(500),
    approver_sequence number,
    approver_email varchar2(240),
    approver_group_name varchar2(50)
    );

    TYPE approversTable is table of approverRecord index by binary_integer;
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
--    Get_AllApprovers
--
-- PURPOSE
-- PARAMETERS
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_AllApprovers(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER

   ,p_approval_rec        IN  approval_rec_type
   ,p_approversOut        OUT NOCOPY approversTable
);

---------------------------------------------------------------------
-- PROCEDURE
--    Clear_All_Approvals
--
-- PURPOSE
--    Clears all the approvals
--
-- PARAMETERS
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Clear_All_Approvals (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,x_msg_data               OUT NOCOPY   VARCHAR2

   ,p_txn_hdr_id             IN  NUMBER
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

   ,p_transaction_header_id   IN NUMBER
   ,p_msg_callback_api   IN VARCHAR2
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
---------------------------------------------------------------------
END DPP_APPROVAL_PVT;

/
