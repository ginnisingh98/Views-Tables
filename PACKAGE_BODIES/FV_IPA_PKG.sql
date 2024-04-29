--------------------------------------------------------
--  DDL for Package Body FV_IPA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_IPA_PKG" AS
-- $Header: FVXARCHB.pls 120.3 2003/12/17 21:21:32 ksriniva noship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_IPA_PKG.';

PROCEDURE IPA_TRX(x_transmission_id IN NUMBER) AS
  l_module_name VARCHAR2(200) := g_module_name || 'IPA_TRX';
  l_errbuf      VARCHAR2(1024);
 v_org_id number :=  to_number(fnd_profile.value('ORG_ID'));
 v_lockbox varchar2(10) := fnd_profile.value('FV_LOCKBOX_FC');

BEGIN

	-- --------------------------------------
        -- This package is invoked from the code hook placed by AR in the
        -- Lockbox Execution Report (ARXLPLB.rdf). The code hook resides
        -- in ARXLPLB.rdf in the after report trigger.  This package
        -- calls the Federal private package which will submit the
        -- Lockbox Finance Charge Application process.
	-- ------------------------------------------

        IF (fv_install.enabled(v_org_id)) and (v_lockbox = 'Y') THEN
           -- Federal is enabled and client wants to use Lockbox Finance
           -- Charge Application process.

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FEDERAL IS ENABLED AND LOCKBOX PROFILE ON');
 END IF;
           FV_IPA_PKG_PVT.IPA_TRX(x_transmission_id);

        END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
      --app_exception.raise_exception;
      raise;

END IPA_TRX;

END FV_IPA_PKG;

/
