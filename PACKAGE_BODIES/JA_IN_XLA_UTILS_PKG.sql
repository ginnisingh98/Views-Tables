--------------------------------------------------------
--  DDL for Package Body JA_IN_XLA_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_IN_XLA_UTILS_PKG" AS
/* $Header: ja_in_xla_utils.plb 120.0.12010000.4 2010/06/08 09:23:18 xlv noship $ */

/********************************************************************************************************
 FILENAME      :  ja_in_xla_utils.plb

 Created By    : Walton

 Created Date  : 07-Apr-2010

 Bug           : 9311844

 Purpose       :  Check whether OFI source and category be used or not.

 Called from   : XLACORE.pll

 --------------------------------------------------------------------------------------------------------
 CHANGE HISTORY:
 --------------------------------------------------------------------------------------------------------
 S.No      Date          Author and Details
 --------------------------------------------------------------------------------------------------------
 1.        2010/04/07   Walton Liu
                        Bug No : 9311844
                        Description : The file is changed for ER GL drilldown
                        Fix Details : http://files.oraclecorp.com/content/MySharedFolders/R12.1.3/TDD/TDD_1213_FIN_JAI_GL_Drilldown.doc
                        Doc Impact  : YES
                        Dependencies: YES, refer to Technical Design
2.         2010/06/08   Xiao Lv for bug#9771635
                        Issue - DRILL DOWN FUNCTIONALITY DOESN'T WORK FOR TCS JOURNAL
                        Fixed - Reversed source and category for TCS accountings.
                                Source should be 'Receivables India,'
                                Category should be 'India Tax Collected'

***************************************************************************************************************/

--==========================================================================
--  FUNCTION NAME:
--
--    if_OFI_drilldown                      Public
--
--  DESCRIPTION:
--
--    This function is used to Enable/Disable drilldown buttion
--    according OFI journal source and journal categories.
--
--  PARAMETERS:
--      In:  pn_je_source           Identifier of journal source
--           pn_je_category         Identifier of journal category
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_4_GL_Drilldown_V0.4.docx
--
--  CHANGE HISTORY:
--
--           09-Mar-2010   Jia Li   created
--==========================================================================
FUNCTION if_OFI_drilldown (
   pn_je_source           VARCHAR2
 , pn_je_category         VARCHAR2
 ) RETURN BOOLEAN
IS
  lb_drilldown_flag   BOOLEAN := FALSE;
  lv_je_source  varchar2(100);
  lv_je_category varchar2(100);

  CURSOR get_user_source IS
  select user_je_source_name
  from gl_je_sources gjs
  where gjs.je_source_name = pn_je_source;

  CURSOR get_user_category IS
  select user_je_category_name
  from gl_je_categories gjc
  where gjc.je_category_name = pn_je_category;

BEGIN

  OPEN get_user_source;
  FETCH get_user_source INTO lv_je_source;
  CLOSE get_user_source;

  OPEN get_user_category;
  FETCH get_user_category INTO lv_je_category;
  CLOSE get_user_category;
  --Add category 'India Tax Collected' by Xiao for bug#9771635 on 08-Jun-10
  IF ((lv_je_source = 'Receivables India') AND (lv_je_category IN( 'Register India','India Tax Collected')))
       OR
      ((lv_je_source = 'Projects India') AND (lv_je_category = 'Register India'))
       OR
      ((lv_je_source = 'Inventory India') AND (lv_je_category = 'MTL'))
       OR
      ((lv_je_source = 'Payables India') AND (lv_je_category IN ('Bill of Entry India','Payments')))
       OR
      ((lv_je_source = 'Payables') AND (lv_je_category = 'BOE'))
       OR
      ((lv_je_source = 'Purchasing India') AND (lv_je_category IN ('Receiving India','OSP Issue India','OSP Receipt India', 'MMT')))
       OR
      ((lv_je_source = 'Register India') AND (lv_je_category IN ('Inventory India','VAT India','Register India')))
       OR
      ((lv_je_source IN ('VAT India','Service Tax India')) AND (lv_je_category = 'Register India'))
--Commented by Xiao for bug#9771635 on 08-Jun-10
       --OR
      --((lv_je_source = 'India Tax Collected') AND (lv_je_category = 'Receivalbes India'))
  THEN
     lb_drilldown_flag := TRUE;
  END IF;

  RETURN ( lb_drilldown_flag );

END if_OFI_drilldown;


END ja_in_xla_utils_pkg;

/
