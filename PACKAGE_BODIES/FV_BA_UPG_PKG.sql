--------------------------------------------------------
--  DDL for Package Body FV_BA_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_BA_UPG_PKG" AS
/* $Header: FVBAUPGB.pls 115.4 2003/12/17 21:19:44 ksriniva noship $ */
  g_module_name VARCHAR2(200) := 'fv.plsql.FV_BA_UPG_PKG.';


PROCEDURE ap_acct_in_use  IS

  l_module_name VARCHAR2(200) := g_module_name || 'ap_acct_in_use';
  l_errbuf      VARCHAR2(1024);

BEGIN

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'fv_ba_upg_pkg.ap_acct_in_use()+');
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'updating ce_upg_bank_accts_gt for fv_ar_batches');
    END IF;

   update ce_upg_bank_accts_gt ce
        set    acct_in_use_flag = 'Y'
        where  exists
          (SELECT null FROM fv_ar_batches_all fab
            WHERE fab.bank_account_id = ce.bank_account_id)
        and    acct_in_use_flag = 'N';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'updating ce_upg_bank_accts_gt for fv_interim_cash_receipts');
    END IF;

     update ce_upg_bank_accts_gt ce
        set    acct_in_use_flag = 'Y'
        where  exists
          (SELECT null FROM fv_interim_cash_receipts_all ficr
            WHERE ficr.bank_account_id = ce.bank_account_id)
        and    acct_in_use_flag = 'N';

EXCEPTION

  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
    RAISE;

END ap_acct_in_use;

END fv_ba_upg_pkg;

/
