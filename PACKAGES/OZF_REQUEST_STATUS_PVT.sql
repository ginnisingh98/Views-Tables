--------------------------------------------------------
--  DDL for Package OZF_REQUEST_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_REQUEST_STATUS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvrsts.pls 120.1 2007/12/24 06:44:09 ateotia ship $ */

---------------------------------------------------------------------
-- PROCEDURE
--    Event_Subscription
--
-- PURPOSE
--    Subscription for the event raised during status change
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Event_Subscription(
   p_subscription_guid in     raw,
   p_event             in out nocopy wf_event_t)
RETURN varchar2;
---------------------------------------------------------------------
-- PROCEDURE
--    Set_Request_Message
--
-- PURPOSE
--    Handles the approvals and rejections of objects
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Set_Request_Message (
   p_itemtype            IN VARCHAR2,
   p_itemkey             IN VARCHAR2,
   P_ENTITY_ID           IN  NUMBER,
   P_USER_TYPE           IN  VARCHAR2,

   P_STATUS              IN  VARCHAR2);
---------------------------------------------------------------------
-- PROCEDURE
--    Return_Request_Userlist
--
-- PURPOSE
--    Handles the approvals and rejections of objects
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Return_Request_Userlist (
   p_benefit_type        IN VARCHAR2,
   p_entity_id           IN  NUMBER,
   p_user_role           IN  VARCHAR2,
   p_status              IN  VARCHAR2) RETURN VARCHAR2;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Interaction
--
-- PURPOSE
--    Created Interaction History
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Create_Interaction (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_approval_rec           IN  OZF_APPROVAL_PVT.approval_rec_type
);

-- 'R12.1 Enhancement: Ship & Debit Request' by ateotia(+)

---------------------------------------------------------------------
-- PROCEDURE
--    Event_SD_Subscription
--
-- PURPOSE
--    Subscription for the event raised for Ship & Debit Request
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Event_SD_Subscription(
   p_subscription_guid IN     raw,
   p_event             IN OUT NOCOPY wf_event_t)
RETURN varchar2;

-- 'R12.1 Enhancement: Ship & Debit Request' by ateotia(-)


END OZF_REQUEST_STATUS_PVT;

/
