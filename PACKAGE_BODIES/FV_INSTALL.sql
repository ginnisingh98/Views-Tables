--------------------------------------------------------
--  DDL for Package Body FV_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_INSTALL" AS
--   $Header: FVXINSTB.pls 120.6.12000000.1 2007/01/18 13:48:12 appldev ship $

  g_module_name            VARCHAR2(100);


  FUNCTION enabled RETURN BOOLEAN
  IS
    l_error_desc  VARCHAR2(1024);
    l_location    VARCHAR2(400);
    l_module_name VARCHAR2(200);
    l_fv_enabled  VARCHAR2(1);
  BEGIN
    l_module_name := g_module_name || 'enabled';

    -- Fetch the profile value
    l_fv_enabled := NVL(fnd_profile.value('FV_ENABLED'), 'N');

    IF (l_fv_enabled = 'N') THEN
       RETURN FALSE;
    ELSE
       RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_error_desc) ;
  END;

  FUNCTION enabled
  (
    x_org_id NUMBER
  ) RETURN BOOLEAN
  IS
  BEGIN
    RETURN enabled;
  END enabled;

  FUNCTION enabled_yn return varchar2 is
	  begin
	     	if (fv_install.enabled) then
	        		return 'Y';
	     	else
	        		return 'N';
	     	end if;
	  end enabled_yn;

BEGIN
  g_module_name            := 'fv.plsql.FV_INSTALL.';
END fv_install;

/
