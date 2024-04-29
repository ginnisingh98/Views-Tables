--------------------------------------------------------
--  DDL for Package GL_PUBLIC_SECTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_PUBLIC_SECTOR" AUTHID CURRENT_USER AS
/*  $Header: glgvutls.pls 120.1 2005/05/05 02:06:04 kvora noship $  */

  --
  -- Function
  --   GET_MESSAGE_NAME
  --
  -- Purpose
  --   Takes a message name. If the profile option 'INDUSTRY' is set to 'G'
  --   at the responsibility level and an equivalent message name appended
  --   with '_G' for the calling application exists then the public sector
  --   specific message name is returned. Otherwise the original message
  --   name is returned.
  --
  -- Arguments
  --   p_message_name     Message Name
  --   p_app_short_name   Application Short Name
  --   p_user_resp_id     Responsibility ID
  --
  -- Notes
  --   1. The profile option 'INDUSTRY' can be set only at site and responsibility
  --      levels. The site level profile value is defaulted if it is not defined at
  --      the responsibility.
  --
  --   2. p_user_resp_id is optional provided FND_GLOBAL.APPS_INITIALIZE has been
  --      invoked prior to calling this function.
  --


  FUNCTION GET_MESSAGE_NAME(P_MESSAGE_NAME     IN VARCHAR2,
			    P_APP_SHORT_NAME   IN VARCHAR2,
			    P_USER_RESP_ID     IN NUMBER  DEFAULT NULL) RETURN VARCHAR2;

END GL_PUBLIC_SECTOR;

 

/
