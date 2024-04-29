--------------------------------------------------------
--  DDL for Package HR_SIGNON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SIGNON" AUTHID CURRENT_USER AS
/* $Header: hrsignon.pkh 120.0.12010000.1 2008/07/28 03:47:55 appldev ship $ */
   --
   pragma restrict_references (hr_signon, WNPS, WNDS);
   --
   -- package-level global varable for use with HR Secure User functionality
   --
   g_hr_security_profile  per_security_profiles%ROWTYPE;
   --
   -- Name
   --   Initialize_HR_Security
   --
   -- Purpose
   --    This procedure is called during the initialization of APPS whenever
   --    a user logs in or switches responsibility.
   --
   --    The call was previously hard-coded in the fnd_client_info package.....
   --
   -- Arguments
   --   None.
   --
   PROCEDURE Initialize_HR_Security;
   --
   -- Name
   -- Security_Groups_Enabled
   --
   -- Purpose
   --    This function checks whether or not security groups are enabled.
   --
   FUNCTION Security_Groups_Enabled
   RETURN VARCHAR2;


   -- 2876315 - mirrors the value of fnd_global.session_context
   session_context NUMBER := 0 ;

END HR_SIGNON;

/
