--------------------------------------------------------
--  DDL for Package CLN_CH_EVENT_SUBSCRIPTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_CH_EVENT_SUBSCRIPTION_PKG" AUTHID CURRENT_USER AS
/* $Header: ECXCHETS.pls 120.0 2005/08/25 04:44:20 nparihar noship $ */
--  Package
--      CLN_CH_EVENT_SUBSCRIPTION_PKG
--
--  Purpose
--      Spec of package CLN_CH_EVENT_SUBSCRIPTION_PKG. This package
--      is called to create or update collaboration based on events raised./updated by calling this package.
--
--  History
--      July-05-2002    Rahul Krishan         Created



  -- Name
  --   CREATE_EVENT_SUB
  -- Purpose
  --   This is the public procedure which is attached to an event raised from a workflow item
  --   and is used to create a new collaboration
  -- Arguments
  --
  -- Notes
  --   No specific notes.

  FUNCTION CREATE_EVENT_SUB(
        p_subscription_guid     IN RAW,
        p_event                 IN OUT NOCOPY WF_EVENT_T
  ) RETURN VARCHAR2;



  -- Name
  --   UPDATE_EVENT_SUB
  -- Purpose
  --   This is the public procedure which is attached to an event raised from a workflow item
  --   and is used to update an existing collaboration
  -- Arguments
  --
  -- Notes
  --   No specific notes.


  FUNCTION UPDATE_EVENT_SUB(
        p_subscription_guid     IN RAW,
        p_event                 IN OUT NOCOPY WF_EVENT_T
  ) RETURN VARCHAR2;


  -- Name
  --   UPDATE_EVENT_SUB
  -- Purpose
  --   This is the public procedure which is attached to an event raised from a workflow item
  --   and is used to add messages to an existing detail collaboration row
  -- Arguments
  --
  -- Notes
  --   No specific notes.


  FUNCTION ADD_MESSAGES_EVENT_SUB(
        p_subscription_guid     IN RAW,
        p_event                 IN OUT NOCOPY WF_EVENT_T
  ) RETURN VARCHAR2;


   -- Name
   --    ADD_COLLABORATION_EVENT_SUB
   -- Purpose
   --    This is the public procedure which is used to get the parameters for the update/create
   --    collaboration event.This procedure in turn calls CREATE_COLLABORATION or UPDATE_COLLABORATION API .
   --    based on the parameters passed.
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION ADD_COLLABORATION_EVENT_SUB(
        p_subscription_guid             IN RAW,
        p_event                         IN OUT NOCOPY WF_EVENT_T

   ) RETURN VARCHAR2;


   -- Name
   --    NOTIFICATION_EVENT_SUB
   -- Purpose
   --    This is the public procedure which is used to raise the notification
   --    event.This procedure in turn calls CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_ACTIONS_EVT API.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION NOTIFICATION_EVENT_SUB(
        p_subscription_guid             IN RAW,
        p_event                         IN OUT NOCOPY WF_EVENT_T
   ) RETURN VARCHAR2;



END CLN_CH_EVENT_SUBSCRIPTION_PKG;

 

/
