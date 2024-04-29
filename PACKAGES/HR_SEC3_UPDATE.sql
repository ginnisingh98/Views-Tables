--------------------------------------------------------
--  DDL for Package HR_SEC3_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SEC3_UPDATE" AUTHID CURRENT_USER AS
/* $Header: hrsec3.pkh 115.1 2002/12/05 17:55:53 apholt ship $ */

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
  PROCEDURE set_profile_options ;

  PROCEDURE debug_on ;
  PROCEDURE debug_off ;

end HR_SEC3_UPDATE;

 

/
