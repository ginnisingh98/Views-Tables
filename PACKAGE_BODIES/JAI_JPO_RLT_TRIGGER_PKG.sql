--------------------------------------------------------
--  DDL for Package Body JAI_JPO_RLT_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_JPO_RLT_TRIGGER_PKG" AS
/* $Header: jai_jpo_rlt_t.plb 120.0 2005/09/01 12:36:02 rallamse noship $ */

/*
  REM +======================================================================+
  REM NAME          BRU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_JPO_RLT_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_JPO_RLT_BRU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE BRU_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*--------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME - ja_in_pllt_bu_trg.sql
S.No  Date  Author and Details
-------------------------------------------------
1.  30/12/2002  cbabu for Enhancement Porting from 11.0.3 Bug# 2427465, FileVersion# 615.1
         Created for the enhancement. When user changes the tax name of the defaulated tax, then defaulted tax should
        be treated as manual tax. If tax_category_id is NULL then the tax is identified as Manual tax.
        This trigger makes defaulted tax to be converted into a manual tax if user changed the tax name attached
        to the tax line.

2.  08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                  DB Entity as required for CASE COMPLAINCE.  Version 116.1
--------------------------------------------------------------------------------------------------------------------------*/

  pr_new.tax_category_id := null;
  END BRU_T1 ;

END JAI_JPO_RLT_TRIGGER_PKG ;

/
