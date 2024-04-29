--------------------------------------------------------
--  DDL for Package IGI_EXP_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_CUSTOM" AUTHID CURRENT_USER AS
-- $Header: igicusts.pls 115.4 2002/09/05 12:10:16 dmahajan ship $
  --
  -- Procedure
  --   Check For Dialogue Units with On Hold status
  -- Purpose
  --   Calls the required runnable process.
  -- History
  --   07-JAN-2000  Glenn Celand Initial Revision
  -- Notes
  --   Called by custom library attached to the FNDWFNOT form to determine if
  --   access should be given to the response window in the notification. A
  --   transmission unit with On-Hold dialog units or dialog units that have
  --   not been validated by the user must not access the response window.

     FUNCTION check_dus_validated(p_notification_id NUMBER) RETURN BOOLEAN ;

END igi_exp_custom ;

 

/
