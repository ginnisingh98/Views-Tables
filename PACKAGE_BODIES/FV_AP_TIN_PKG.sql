--------------------------------------------------------
--  DDL for Package Body FV_AP_TIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_AP_TIN_PKG" AS
-- $Header: FVAPTNCB.pls 120.4 2003/12/17 21:19:40 ksriniva noship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_AP_TIN_PKG.';

PROCEDURE TIN_VALIDATE(FIELD_NAME     IN varchar2,
                       PROC_RESULT    OUT NOCOPY varchar2,
                       RESULT_MESSAGE OUT NOCOPY varchar2) AS

 org_id NUMBER := to_number(fnd_profile.value('ORG_ID'));
 l_module_name VARCHAR2(200) := g_module_name || 'TIN_VALIDATE';
 l_errbuf VARCHAR2(1024);

BEGIN

	-- --------------------------------------
	-- Created to be used to implement
	-- TIN Validation.  The code hook call will reside in the package
	-- po_validate_nifvat.po_coordinate_validation in povlnifb.pls
	-- ------------------------------------------

     IF fv_install.enabled(org_id) THEN

        -- FV is enabled to call TIN Validation routine
        fv_ap_tin_pkg_pvt.tin_validate(FIELD_NAME,PROC_RESULT,RESULT_MESSAGE);

     END IF;

EXCEPTION
  WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
      RAISE;
END TIN_VALIDATE;

END FV_AP_TIN_PKG;

/
