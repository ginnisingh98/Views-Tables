--------------------------------------------------------
--  DDL for Package CSI_HANDLE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_HANDLE_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csitbess.pls 120.1 2007/10/21 06:31:45 fli noship $ */

   FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2;
   -----------------------------------------------------------------------
   -- Return 'Y' if there are some active subscription for the given event
   -- Otherwise it returns 'N'
   -----------------------------------------------------------------------

   FUNCTION item_key(p_event_name  IN VARCHAR2) RETURN VARCHAR2;
   -----------------------------------------------------
   -- Return Item_Key according to CSI Event to be raised
   -- Item_Key is <Event_Name>-CSI_WF_ITEM_KEY_NUMBER_S.nextval
   -----------------------------------------------------

   FUNCTION event(p_event_name IN VARCHAR2) RETURN VARCHAR2;
   -----------------------------------------------
   -- Return event name if the entered event exist
   -- Otherwise return NOTFOUND
   -----------------------------------------------

   PROCEDURE raise_event
   ----------------------------------------------
   -- Check if Event exist
   -- Check if Event is like 'oracle.apps.csi%'
   -- Get the item_key
   -- Raise event
   ----------------------------------------------
   (p_api_version          IN   NUMBER
    ,p_commit              IN   VARCHAR2
    ,p_init_msg_list       IN   VARCHAR2
    ,p_validation_level    IN   NUMBER
    ,p_event_name          IN   VARCHAR2
    ,p_event_key           IN   VARCHAR2
    ,p_instance_id         IN   NUMBER
    ,p_subject_instance_Id IN   NUMBER
    ,p_correlation_value   IN   VARCHAR2);

END;

/
