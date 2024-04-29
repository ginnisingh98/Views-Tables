--------------------------------------------------------
--  DDL for Package HR_SECURITY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_UTILS" AUTHID CURRENT_USER AS
/* $Header: hrscutl.pkh 115.0 99/07/17 16:59:41 porting ship $ */

  --
  -- Name
  --   check_profile_options
  -- Purpose
  --
  --   Verifies that the Business Group and Security Profile profile
  --   options are set correctly. Please see package body for details
  --
  -- Arguments
  --   *none*
  --
  PROCEDURE check_profile_options ;

  PROCEDURE debug_on ;
  PROCEDURE debug_off ;

  FUNCTION  IS_CUSTOM_SCHEMA return boolean ;
  pragma restrict_references ( is_custom_schema , WNPS , WNDS ) ;

  -- Name
  --   set_custom_schema
  -- Purpose
  --   Sets a flag which treats a non-APPS schema as if it has
  --   full access to secured objects. This takes effect for the
  --   duration of the package state.
  --
  --   This is to be used by teams like Oracle Projects which
  --   interface to 3rd party products via schemas other than APPS
  --
  --   This function should be in hr_security however due to 566823
  --   and 519783.
  --
  -- Arguments
  --   *none*

 PROCEDURE SET_CUSTOM_SCHEMA ;

end HR_SECURITY_UTILS;

 

/
