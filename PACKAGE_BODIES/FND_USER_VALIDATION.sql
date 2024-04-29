--------------------------------------------------------
--  DDL for Package Body FND_USER_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_USER_VALIDATION" as
/* $Header: AFSCUVAB.pls 120.0 2005/07/26 23:45:14 appldev noship $ */
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
                            ) return varchar2 is

 l_dot_pos number;
 l_at_pos number;
 l_str_length number;
 l_user_name FND_USER.USER_NAME%TYPE;

 begin

 l_user_name := p_event.getEventKey();
 l_dot_pos := instr( l_user_name, '.');
 l_at_pos := instr( l_user_name, '@');
 l_str_length := length(l_user_name);

 if (
     (l_dot_pos = 0) or
     (l_at_pos = 0)  or
     (l_dot_pos = l_at_pos +1 ) or
     (l_at_pos = 1) or
     (l_at_pos = l_str_length) or
     (l_dot_pos = l_str_length)
     )then
   WF_EVENT.setErrorInfo(p_event,'ERROR');
   FND_MESSAGE.SET_NAME('FND','FND_INVLD_EMAIL_FRMT');
   -- we are raising an app exception since Fnd_user_pkg.validate
   -- expects an exception. Typically Wf_event.GetErrorInfo should be handled
   -- by fnd_user_pkg
   app_exception.RAISE_EXCEPTION;
 end if;
 return 'SUCCESS';
 end Custom_Validation;

 end FND_USER_VALIDATION;

/
