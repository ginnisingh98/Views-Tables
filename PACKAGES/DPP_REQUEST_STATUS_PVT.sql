--------------------------------------------------------
--  DDL for Package DPP_REQUEST_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_REQUEST_STATUS_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvrsts.pls 120.1 2007/12/01 08:46:29 sdasan noship $ */

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
   P_transaction_header_id           IN  NUMBER,
   P_STATUS              IN  VARCHAR2);

END DPP_REQUEST_STATUS_PVT;

/
