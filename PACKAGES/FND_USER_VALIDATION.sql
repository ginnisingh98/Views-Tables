--------------------------------------------------------
--  DDL for Package FND_USER_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_USER_VALIDATION" AUTHID CURRENT_USER as
/* $Header: AFSCUVAS.pls 120.0 2005/07/26 23:45:19 appldev noship $ */
-- Start of Comments
-- Package name     : FND_USER_VALIDATION
-- Purpose          :
--   This package contains specification individual user registration

  --
  --  Function
  --  Custom_validation
  --
  -- Description
  -- This method is a subscriber to the event oracle.apps.fnd.user.name.validate
  -- This method will validate a Email as username policy
  -- This method will return Success if Email is in proper format
  -- Else It will raise an application Error
  -- IN
  -- the signature follows Workflow business events standards
  --  p_subscription_guid  -
  -- IN/OUT
  -- p_event - WF_EVENT_T which holds the data that needs to passed from/to
  --           subscriber of the event
  --


function Custom_Validation(p_subscription_guid in raw,
                             p_event in out NOCOPY WF_EVENT_T
                            ) return varchar2;


end FND_USER_VALIDATION;

 

/
