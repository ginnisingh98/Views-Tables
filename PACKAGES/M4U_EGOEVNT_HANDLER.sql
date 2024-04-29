--------------------------------------------------------
--  DDL for Package M4U_EGOEVNT_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_EGOEVNT_HANDLER" AUTHID CURRENT_USER AS
/* $Header: M4UEGOHS.pls 120.0 2005/05/24 16:18:58 appldev noship $ */

   -- Name
   --    EGO_EVENT_SUB
   -- Purpose
   --    This function is used to get the parameters from the EGO event.
   --    This procedure in turn raises event for triggering the generic M4U workflow.
   --    after setting the default parameters.
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION EGO_EVENT_SUB(
        p_subscription_guid             IN RAW,
        p_event                         IN OUT NOCOPY WF_EVENT_T
   ) RETURN VARCHAR2;

END m4u_egoevnt_handler;


 

/
