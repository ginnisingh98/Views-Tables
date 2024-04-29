--------------------------------------------------------
--  DDL for Package Body PAY_LEGISLATION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_LEGISLATION_RULES_PKG" as
/* $Header: pylegrul.pkb 120.9.12010000.1 2008/07/27 23:08:20 appldev ship $*/
--
/*
 Copyright (c) Oracle Corporation 1993,1994,1995.  All rights reserved

/*

 Name          : pylegrul.pkb
 Description   : procedures required to check for pay_legislation_rules

 Change List
 -----------
 Date        Name           Vers     Bug No    Description
 +-----------+--------------+--------+---------+-----------------------+
 14-MAR-2001 T.Battoo        115.0              created
 21-DEC-2001 RThirlby        115.2              Added new rule SEED_FEEDS
                                                and dbdrv lines.
 27-DEC-2001 KKawol          115.3              Added ENABLE_QP_OFFSET and
                                                removed PDO. This is to enable
                                                positive offset processing.
 07-JAN-2002 NBristow        115.4              Added RUN_RETRO_FORMULA for
                                                the control of retropay
                                                elements.
 14-JAN-2002 KKawol          115.7              Put PDO back in. Bug 2182484.
 12-FEB-2002 KKawol                             Added  FREQ_RULE_DATE to allow
                                                freq rule calculation as of check date.
 09-APR-2002 NBristow        115.9              Added rule DEFAULT_RUN_TYPE.
 26-JUL-2002 nbristow        115.10             Added rule SAVE_RUN_BAL.
 30-AUG-2002 nbristow        115.11             Added rule DYNAMIC_TAX_UNIT.
 13-SEP-2002 RThirlby        115.12             Added rule BAL_CATEGORY_MANDATORY.
 09-OCT-2002 JHobbs          115.13             Added rule BAL_INIT_VALIDATION
 10-OCT-2002 ALogue          115.14             Added rule PAY_ACTION_PARAMETER_GROUPS
 16-OCT-2002 NBristow        115.15             Added SAVE_ASG_RUN_BAL.
 20_NOV-2002 NBristow        115.16             Added MULTI_TAX_UNIT_PAYMENT
 16-JAN-2003 NBristow        115.17             Added JURISDICTION_IV
 28-FEB-2003 ALogue          115.18             Added RETRO_STD_CONTEXTS
 05-MAR-2003 ALogue          115.19             Added SUPPRESS_INSIG_INDIRECTS
 20-MAR-2003 ALogue          115.20             Added RETRO_CONTEXT_OVERRIDE
 20-MAR-2003 NBristow        115.21             Added RETRO_DELETE
 05-SEP-2003 KKawol          115.22             Added ADVANCED_RETRO,
                                                RETRO_TU_CONTEXT,CWK_S,CWK_SDL
 17-OCT-2003 NBristow        115.23             Added RR_SPARSE.
 14-Nov-2003 SuSivasu        115.24             Added ADV_EE_SUBPRIORITY.
 14-JAN-2004 jford           115.26             Added RETRO_COMP_DFLT_OVERRIDE
 02-MAR-2004 nbristow        115.27             Added ITERATE_DYN_GRS_FACTOR_FLAG.
 02-MAR-2004 nbristow        115.28             Renamed ITERATE_DYN_GRS_FACTOR_FLAG
                                                to ITERATE_DYN_HI_GRS_FACTOR.
 20-APR-2004 thabara         115.29             Added BAL_INIT_INCLUDE_ADJ.
 06-AUG-2004 tbattoo         115.30             Added PRENOTE_DEFAULT.
 25-AUG-2004 jford           115.31             Added RETRO_STATUS_USER_UPD
 06-SEP-2004 nbristow        115.32             Added MULTITHREAD_MAGPAY
                                                and MAGTAPE_FILE_SAVE
 10-Dec-2004 SuSivasu        115.33             Added OVERRIDE_CHEQUE_DATE
 08-Apr-2005 M.Reid          115.34             Added PAYSLIP_MODE
 22-APR-2005 NBristow        115.35             Added LOCAL_UNIT_CONTEXT
 11-MAY-2005 NBristow        115.36             Added NON_ORACLE_LOC
 31-AUG-2005 ARashid         115.36             Added FF_TRANSLATE_DATABASE_ITEMS
 02-MAR-2006 NBristow        115.38             Added REHIRE_BEFORE_FPD and
                                                AMEND_HIRE_WITH_PAYACT for
                                                Core HR.
 22-MAR-2006 TBattoo         115.39             Added RETRO_LABEL_ENTRY
 27-JUN-2006 TBattoo         115.40             Added ADDITIONAL_CHQ_DATA
						and XML_FILE_CREATION_NO
 16-OCT-2006 NBristow        115.41             Added PRINT_FILES
 24-OCT-2006 ALogue          115.42             Remove PRINT_FILES
 05-JAN-2007 NBristow        115.43             Added RETRO_OVERLAP.
 14-FEB-2007 SuSivasu        115.44             Added TIME_PERIOD_ID.
 10-SEP-2007 KKawol          115.45             Added ADJUST_RETRO_INDIRECT.
*/

function check_leg_rule(rule_type varchar2) return boolean is
begin
 if (rule_type in  ('L', 'ADA_DIS', 'ADA_DIS_ACC', 'S', 'A',
'D', 'P', 'C', 'I', 'DC', 'SDL', 'ENABLE_QP_OFFSET', 'E', 'OSHA', 'SSP',
'PAY_ADVANCE_INDICATOR', 'ADVANCE_INDICATOR', 'ADVANCE','PAI_START_DATE',
'PAI_END_DATE','AI_DEFER_PAY_FLAG', 'AI_ADVANCE_FLAG','ADV_CLEARUP',
'ADVOUTS_BAL','DEFERPAY_BAL', 'ADVSRC_BAL','DEFER_PAY',
'ADV_CLEARUP_OFFSET', 'ADV_DEDUCTION_DEDUCTION',
'ADV_DEDUCTION','PDR', 'PAYWSACT_SOE', 'PAYWSDPM_TPP',
'PAYWSDET_TPB', 'PAYWSDET_BEN', 'PAYWSRQP_DS', 'PERWSMMV_GRE',
'PERWSDCL_OSHA', 'PERWSDCL_ADA', 'ACTION_CONTEXTS',
'LEGISLATION_CHECK_FORMULA', 'SOE','SOURCE_IV',
'DEFAULT_JURISDICTION','TAX_UNIT', 'RETROELEMENT_CHECK',
'PAYWSDPG_OFFSET1', 'PAYWSDPG_OFFSET2', 'PAYWSDPG_OFFSET3',
'PAYWSDPG_OFFSET4', 'RUN_TYPE_FLAG', 'PROC_SEPARATE_IV',
'PROC_RUN_METH_IV', 'PROC_RUN_METH_VALUE', 'SEP_CHEQUE_IV',
'BALANCE_DBITEM_TYPE', 'PTO_BALANCE_TYPE', 'ADJUSTMENT_EE_SOURCE',
'SOURCE_TEXT_IV', 'BAL_ADJ_LAT_BAL','SKIP_TERMINATED_ASG', 'SEED_FEEDS',
'RUN_RETRO_FORMULA','PDO', 'FREQ_RULE_DATE', 'DEFAULT_RUN_TYPE',
'DYNAMIC_TAX_UNIT', 'SAVE_RUN_BAL', 'BAL_CATEGORY_MANDATORY',
'BAL_INIT_VALIDATION','PAY_ACTION_PARAMETER_GROUPS', 'SAVE_ASG_RUN_BAL',
'MULTI_TAX_UNIT_PAYMENT', 'JURISDICTION_IV', 'RETRO_STD_CONTEXTS',
'SUPPRESS_INSIG_INDIRECTS','RETRO_CONTEXT_OVERRIDE', 'RETRO_DELETE',
'ADVANCED_RETRO','RETRO_TU_CONTEXT','CWK_S','CWK_SDL', 'RR_SPARSE',
'ADV_EE_SUBPRIORITY','RETRO_COMP_DFLT_OVERRIDE',
'ITERATE_DYN_HI_GRS_FACTOR', 'BAL_INIT_INCLUDE_ADJ','PRENOTE_DEFAULT',
'RETRO_STATUS_USER_UPD', 'MULTITHREAD_MAGPAY', 'MAGTAPE_FILE_SAVE',
'OVERRIDE_CHEQUE_DATE', 'PAYSLIP_MODE', 'LOCAL_UNIT_CONTEXT',
'NON_ORACLE_LOC', 'FF_TRANSLATE_DATABASE_ITEMS',
'REHIRE_BEFORE_FPD',     -- Core HR Legislation Rule
'AMEND_HIRE_WITH_PAYACT',-- Core HR Legislation Rule
'RETRO_ENTRY_LABEL','ADE_ENTRY_LABEL','ADDITIONAL_CHQ_DATA','XML_FILE_CREATION_NO',
'RETRO_OVERLAP','TIME_PERIOD_ID', 'ADJUST_RETRO_INDIRECT'
))
 then
   return true;
 else
  return false;
 end if;
end;

begin
 null;
end;

/
