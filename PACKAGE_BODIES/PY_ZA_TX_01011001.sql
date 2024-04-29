--------------------------------------------------------
--  DDL for Package Body PY_ZA_TX_01011001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_TX_01011001" AS
/* $Header: pyzat001.pkb 120.2 2005/06/28 00:09:32 kapalani noship $ */
/* Copyright (c) Oracle Corporation 1999. All rights reserved. */
/*
  PRODUCT
     Oracle Payroll - ZA Localisation Tax Module

  NAME
     ZaTx_01011001.pkb

  DESCRIPTION
    This is the main tax package as used in the ZA Localisation Tax Module.
    The public functions in this package are not for client use and is
    only referenced by the tax formulae in the Application.

  PUBLIC FUNCTIONS

    ZaTxGlb_01011001
      This function is called from Oracle Applications Fast Formula.
      It passes all necessary global values to the main tax package.

    ZaTxDbi_01011001
      This function is called from Oracle Applications Fast Formula.
      It passes all necessary Application Database Items to the
      main tax package.

    ZaTxBal1_01011001
      This function is called from Oracle Applications Fast Formula.
      It passes the first group of balances to the main tax package.

    ZaTxBal2_01011001
      This function is called from Oracle Applications Fast Formula.
      It passes the second group of balances to the main tax package.

    ZaTxBal3_01011001
      This function is called from Oracle Applications Fast Formula.
      It passes the third group of balances to the main tax package.

    ZaTx_01011001
      This function is called from Oracle Applications Fast Formula.
      This is the main tax function from where all necessary
      validation and calculations are done.  The function will
      calculate the tax liabilities of the employee assignment
      and pass it back to the calling formula.

  PRIVATE FUNCTIONS

    LstPeriod
      Boolean function returns true if current period is the
      last period in the current tax year.

    EmpTermInPeriod
      Boolean function returns true if the assignment was terminated
      in the current pay period.

    EmpTermPrePeiod
      Boolean function returns true if the assignment was terminated
      before the current period.

    PreErnPeriod
      Boolean function returns true if this run is deemed to be
      a Pre-Earnings Calculation Run.
      For a complete description see the tax module design document.

    SitePeriod
      Boolean function returns true if it is a tax site period.
      For a complete description see the tax module design document.

    Annualise
      Returns annualised value to the calling object.
      For a complete description see the tax module design document.

    TaxLiability
      Returns the gross tax liability on passed value.
      For a complete description see the tax module design document.

    DeAnnualise
      Returns the de-annualised value to the calling object.
      For a complete description see the tax module design document.

    DaysWorked
      Returns the number of days worked for the assignment.
      For a complete description see the tax module design document.

  PRIVATE PROCEDURES

    PeriodFactor
      Calculates the period factor for the assignment.
      For a complete description see the tax module design document.

    PossiblePeriodsFactor
      Calculates the possible period factor for the assignment.
      For a complete description see the tax module design document.

    Abatements
      Calculates all necessary abatements.
      For a complete description see the tax module design document.

    ArrearExcess
      Calculates the arrear excess figure to 'effectively' update the
      Asg_Itd dimension of the arrear excess pension and retirement
      annuity balances.  Will only fire on siteperiod.

    TrvAllYtd
      Calculates the taxable travel allowance over a period of
      time based on the effective global values at the time.
      For a complete description see the tax module design document.

    TrvAllCal
      Calculates the taxable travel allowance over a period of
      time based on the effective global values at the time.
      For a complete description see the tax module design document.

    NpVal
      Validates the calculated category liabilities.
      For a complete description see the tax module design document.

    SitPaySplit
      Calculates the site paye split of tax liabilities.
      For a complete description see the tax module design document.

    Trace
      Traces the tax calculation.
      For a complete description see the tax module design document.

    ClearGlobals
      Clears any set package globals.
      For a complete description see the tax module design document.

    SeaCalc
      A main tax calculation.
      For a complete description see the tax module design document.

    SitCalc
      A main tax calculation.
      For a complete description see the tax module design document.

    DirCalc
      A main tax calculation.
      For a complete description see the tax module design document.

    BasCalc
      A main tax calculation.
      For a complete description see the tax module design document.

    CalCalc
      A main tax calculation.
      For a complete description see the tax module design document.

    YtdCalc
      A main tax calculation.
      For a complete description see the tax module design document.

    NorCalc
      A main tax calculation.
      For a complete description see the tax module design document.

  NOTES
     .

  MODIFICATION HISTORY
     Person      Date(DD-MM-YYYY)   Version   Comments
     ---------   ----------------   -------   -----------------------------------
     J.N. Louw   06-03-2000         110.5     SitePayeSplit for 'G'
                                                Added balance:
                                                Total Seasonal Workers Days
                                                  Worked:
                                                  bal_TOT_SEA_WRK_DYS_WRK
                                              c/p_PAYE_PTD,p_SITE_PTD,
                                                  bal_PAYE_PTD,bal_SITE_PTD
                                                  /p_PAYE_YTD,p_SITE_YTD,
                                                bal_PAYE_YTD,bal_SITE_YTD
                                              Updated Exception Handling:
                                                to level of 01032000 pkg
                                              Error when no number of days
                                                worked for Tax Status 'G'
                                              New Tax Directive default:
                                                0000 instead of 0
     J.N. Louw   09-02-2000         110.4     Fixed 65 Rebate and Threshold
                                                Check
                                              Altered Threshold Validation:
                                                NorCalc, SitCalc
                                                Tax on ... Refund
                                              Altered Ytd Income Validation:
                                                DirCalc, NorCalc, SitCalc
                                                Tax on ... Refund
                                              Altered ZaTx_01011001:
                                                Tax Status Validation
                                              Altered NpVal:
                                                Override of Liability
     J.N. Louw   02-02-2000         110.3     Added PreErnPeriod Function
                                              Addded Balance Feed Functionality
                                                for the Total Taxable Income
                                                balance
                                              bal_PRCH_ANU_TXB_RFI_RUN
                                              Added bal_PAYE_PTD,bal_SITE_PTD
                                              Fixed BasCalc
                                              Added LstPeriod,EmpTermInPeriod,
                                                EmpTermPrePeriod Functions
                                              Removed TxbIncYtd check in
                                                SitCalc
                                              Fixed De-annualisation of Public
                                                Office Allowance - SitCalc,
                                                SeaCalc
     J.N. Louw   20-01-2000         110.2     Fixed bug on NpVal when Net Pay
                                                is zero
     J.N. Louw   09-12-1999         110.1     Arrear Excess Processing
     J.N. Louw   13-09-1999         110.0     First Created




*/

/* PACKAGE GLOBAL AREA */
-- Contexts
  con_ASG_ACT_ID NUMBER;
  con_ASG_ID NUMBER;
  con_PRL_ACT_ID NUMBER;
  con_PRL_ID NUMBER;
-- Global Values
  glb_ZA_ADL_TX_RBT NUMBER;
  glb_ZA_ARR_PF_AN_MX_ABT NUMBER;
  glb_ZA_ARR_RA_AN_MX_ABT NUMBER;
  glb_ZA_TRV_ALL_TX_PRC NUMBER;
  glb_ZA_CC_TX_PRC NUMBER;
  glb_ZA_PF_AN_MX_ABT NUMBER;
  glb_ZA_PF_MX_PRC NUMBER;
  glb_ZA_PRI_TX_RBT NUMBER;
  glb_ZA_PRI_TX_THRSHLD NUMBER;
  glb_ZA_PBL_TX_PRC NUMBER;
  glb_ZA_PBL_TX_RTE NUMBER;
  glb_ZA_RA_AN_MX_ABT NUMBER;
  glb_ZA_RA_MX_PRC NUMBER;
  glb_ZA_SC_TX_THRSHLD NUMBER;
  glb_ZA_SIT_LIM NUMBER;
  glb_ZA_TMP_TX_RTE NUMBER;
  glb_ZA_WRK_DYS_PR_YR NUMBER;
-- Database Items
  dbi_ARR_PF_FRQ VARCHAR2(1);
  dbi_ARR_RA_FRQ VARCHAR2(1);
  dbi_ASG_STRT_DTE DATE;
  dbi_BP_TX_RCV VARCHAR2(1);
  dbi_PER_AGE NUMBER;
  dbi_PER_DTE_OF_BRTH DATE;
  dbi_RA_FRQ VARCHAR2(1);
  dbi_SEA_WRK_DYS_WRK NUMBER;
  dbi_SES_DTE DATE;
  dbi_TX_DIR_VAL NUMBER DEFAULT 25;
  dbi_TX_STA VARCHAR2(1);
  dbi_ZA_ACT_END_DTE DATE;
  dbi_ZA_CUR_PRD_END_DTE DATE;
  dbi_ZA_CUR_PRD_STRT_DTE DATE;
  dbi_ZA_DYS_IN_YR NUMBER;
  dbi_ZA_PAY_PRDS_LFT NUMBER;
  dbi_ZA_PAY_PRDS_PER_YR NUMBER;
  dbi_ZA_TX_YR_END DATE;
  dbi_ZA_TX_YR_STRT DATE;
-- Balances
  bal_AB_NRFI_RUN NUMBER(15,2);
  bal_AB_NRFI_PTD NUMBER(15,2);
  bal_AB_NRFI_YTD NUMBER(15,2);
  bal_AB_RFI_RUN NUMBER(15,2);
  bal_AB_RFI_PTD NUMBER(15,2);
  bal_AB_RFI_YTD NUMBER(15,2);
  bal_ANN_PF_RUN NUMBER(15,2);
  bal_ANN_PF_PTD NUMBER(15,2);
  bal_ANN_PF_YTD NUMBER(15,2);
  bal_ANU_FRM_RET_FND_NRFI_RUN NUMBER(15,2);
  bal_ANU_FRM_RET_FND_NRFI_PTD NUMBER(15,2);
  bal_ANU_FRM_RET_FND_NRFI_YTD NUMBER(15,2);
  bal_ANU_FRM_RET_FND_RFI_RUN NUMBER(15,2);
  bal_ANU_FRM_RET_FND_RFI_PTD NUMBER(15,2);
  bal_ANU_FRM_RET_FND_RFI_YTD NUMBER(15,2);
  bal_ARR_PF_CYTD NUMBER(15,2);
  bal_ARR_PF_PTD NUMBER(15,2);
  bal_ARR_PF_YTD NUMBER(15,2);
  bal_ARR_RA_CYTD NUMBER(15,2);
  bal_ARR_RA_PTD NUMBER(15,2);
  bal_ARR_RA_YTD NUMBER(15,2);
  bal_AST_PRCHD_RVAL_NRFI_CYTD NUMBER(15,2);
  bal_AST_PRCHD_RVAL_NRFI_RUN NUMBER(15,2);
  bal_AST_PRCHD_RVAL_NRFI_PTD NUMBER(15,2);
  bal_AST_PRCHD_RVAL_NRFI_YTD NUMBER(15,2);
  bal_AST_PRCHD_RVAL_RFI_CYTD NUMBER(15,2);
  bal_AST_PRCHD_RVAL_RFI_RUN NUMBER(15,2);
  bal_AST_PRCHD_RVAL_RFI_PTD NUMBER(15,2);
  bal_AST_PRCHD_RVAL_RFI_YTD NUMBER(15,2);
  bal_BP_PTD NUMBER(15,2);
  bal_BP_YTD NUMBER(15,2);
  bal_BUR_AND_SCH_NRFI_CYTD NUMBER(15,2);
  bal_BUR_AND_SCH_NRFI_RUN NUMBER(15,2);
  bal_BUR_AND_SCH_NRFI_PTD NUMBER(15,2);
  bal_BUR_AND_SCH_NRFI_YTD NUMBER(15,2);
  bal_BUR_AND_SCH_RFI_CYTD NUMBER(15,2);
  bal_BUR_AND_SCH_RFI_RUN NUMBER(15,2);
  bal_BUR_AND_SCH_RFI_PTD NUMBER(15,2);
  bal_BUR_AND_SCH_RFI_YTD NUMBER(15,2);
  bal_COMM_NRFI_CYTD NUMBER(15,2);
  bal_COMM_NRFI_RUN NUMBER(15,2);
  bal_COMM_NRFI_PTD NUMBER(15,2);
  bal_COMM_NRFI_YTD NUMBER(15,2);
  bal_COMM_RFI_CYTD NUMBER(15,2);
  bal_COMM_RFI_RUN NUMBER(15,2);
  bal_COMM_RFI_PTD NUMBER(15,2);
  bal_COMM_RFI_YTD NUMBER(15,2);
  bal_COMP_ALL_NRFI_CYTD NUMBER(15,2);
  bal_COMP_ALL_NRFI_RUN NUMBER(15,2);
  bal_COMP_ALL_NRFI_PTD NUMBER(15,2);
  bal_COMP_ALL_NRFI_YTD NUMBER(15,2);
  bal_COMP_ALL_RFI_CYTD NUMBER(15,2);
  bal_COMP_ALL_RFI_RUN NUMBER(15,2);
  bal_COMP_ALL_RFI_PTD NUMBER(15,2);
  bal_COMP_ALL_RFI_YTD NUMBER(15,2);
  bal_CUR_PF_CYTD NUMBER(15,2);
  bal_CUR_PF_RUN NUMBER(15,2);
  bal_CUR_PF_PTD NUMBER(15,2);
  bal_CUR_PF_YTD NUMBER(15,2);
  bal_CUR_RA_CYTD NUMBER(15,2);
  bal_CUR_RA_RUN NUMBER(15,2);
  bal_CUR_RA_PTD NUMBER(15,2);
  bal_CUR_RA_YTD NUMBER(15,2);
  bal_ENT_ALL_NRFI_CYTD NUMBER(15,2);
  bal_ENT_ALL_NRFI_RUN NUMBER(15,2);
  bal_ENT_ALL_NRFI_PTD NUMBER(15,2);
  bal_ENT_ALL_NRFI_YTD NUMBER(15,2);
  bal_ENT_ALL_RFI_CYTD NUMBER(15,2);
  bal_ENT_ALL_RFI_RUN NUMBER(15,2);
  bal_ENT_ALL_RFI_PTD NUMBER(15,2);
  bal_ENT_ALL_RFI_YTD NUMBER(15,2);
  bal_EXC_ARR_PEN_ITD NUMBER(15,2);
  bal_EXC_ARR_PEN_PTD NUMBER(15,2);
  bal_EXC_ARR_RA_ITD NUMBER(15,2);
  bal_EXC_ARR_RA_PTD NUMBER(15,2);
  bal_FREE_ACCOM_NRFI_CYTD NUMBER(15,2);
  bal_FREE_ACCOM_NRFI_RUN NUMBER(15,2);
  bal_FREE_ACCOM_NRFI_PTD NUMBER(15,2);
  bal_FREE_ACCOM_NRFI_YTD NUMBER(15,2);
  bal_FREE_ACCOM_RFI_CYTD NUMBER(15,2);
  bal_FREE_ACCOM_RFI_RUN NUMBER(15,2);
  bal_FREE_ACCOM_RFI_PTD NUMBER(15,2);
  bal_FREE_ACCOM_RFI_YTD NUMBER(15,2);
  bal_FREE_SERV_NRFI_CYTD NUMBER(15,2);
  bal_FREE_SERV_NRFI_RUN NUMBER(15,2);
  bal_FREE_SERV_NRFI_PTD NUMBER(15,2);
  bal_FREE_SERV_NRFI_YTD NUMBER(15,2);
  bal_FREE_SERV_RFI_CYTD NUMBER(15,2);
  bal_FREE_SERV_RFI_RUN NUMBER(15,2);
  bal_FREE_SERV_RFI_PTD NUMBER(15,2);
  bal_FREE_SERV_RFI_YTD NUMBER(15,2);
  bal_LOW_LOANS_NRFI_CYTD NUMBER(15,2);
  bal_LOW_LOANS_NRFI_RUN NUMBER(15,2);
  bal_LOW_LOANS_NRFI_PTD NUMBER(15,2);
  bal_LOW_LOANS_NRFI_YTD NUMBER(15,2);
  bal_LOW_LOANS_RFI_CYTD NUMBER(15,2);
  bal_LOW_LOANS_RFI_RUN NUMBER(15,2);
  bal_LOW_LOANS_RFI_PTD NUMBER(15,2);
  bal_LOW_LOANS_RFI_YTD NUMBER(15,2);
  bal_MLS_AND_VOUCH_NRFI_CYTD NUMBER(15,2);
  bal_MLS_AND_VOUCH_NRFI_RUN NUMBER(15,2);
  bal_MLS_AND_VOUCH_NRFI_PTD NUMBER(15,2);
  bal_MLS_AND_VOUCH_NRFI_YTD NUMBER(15,2);
  bal_MLS_AND_VOUCH_RFI_CYTD NUMBER(15,2);
  bal_MLS_AND_VOUCH_RFI_RUN NUMBER(15,2);
  bal_MLS_AND_VOUCH_RFI_PTD NUMBER(15,2);
  bal_MLS_AND_VOUCH_RFI_YTD NUMBER(15,2);
  bal_MED_CONTR_CYTD NUMBER(15,2);
  bal_MED_CONTR_RUN NUMBER(15,2);
  bal_MED_CONTR_PTD NUMBER(15,2);
  bal_MED_CONTR_YTD NUMBER(15,2);
  bal_MED_PAID_NRFI_CYTD NUMBER(15,2);
  bal_MED_PAID_NRFI_RUN NUMBER(15,2);
  bal_MED_PAID_NRFI_PTD NUMBER(15,2);
  bal_MED_PAID_NRFI_YTD NUMBER(15,2);
  bal_MED_PAID_RFI_CYTD NUMBER(15,2);
  bal_MED_PAID_RFI_RUN NUMBER(15,2);
  bal_MED_PAID_RFI_PTD NUMBER(15,2);
  bal_MED_PAID_RFI_YTD NUMBER(15,2);
  bal_NET_PAY_RUN NUMBER(15,2);
  bal_OTHER_TXB_ALL_NRFI_CYTD NUMBER(15,2);
  bal_OTHER_TXB_ALL_NRFI_RUN NUMBER(15,2);
  bal_OTHER_TXB_ALL_NRFI_PTD NUMBER(15,2);
  bal_OTHER_TXB_ALL_NRFI_YTD NUMBER(15,2);
  bal_OTHER_TXB_ALL_RFI_CYTD NUMBER(15,2);
  bal_OTHER_TXB_ALL_RFI_RUN NUMBER(15,2);
  bal_OTHER_TXB_ALL_RFI_PTD NUMBER(15,2);
  bal_OTHER_TXB_ALL_RFI_YTD NUMBER(15,2);
  bal_OVTM_NRFI_CYTD NUMBER(15,2);
  bal_OVTM_NRFI_RUN NUMBER(15,2);
  bal_OVTM_NRFI_PTD NUMBER(15,2);
  bal_OVTM_NRFI_YTD NUMBER(15,2);
  bal_OVTM_RFI_CYTD NUMBER(15,2);
  bal_OVTM_RFI_RUN NUMBER(15,2);
  bal_OVTM_RFI_PTD NUMBER(15,2);
  bal_OVTM_RFI_YTD NUMBER(15,2);
  bal_PAYE_YTD NUMBER(15,2);
  bal_PYM_DBT_NRFI_CYTD NUMBER(15,2);
  bal_PYM_DBT_NRFI_RUN NUMBER(15,2);
  bal_PYM_DBT_NRFI_PTD NUMBER(15,2);
  bal_PYM_DBT_NRFI_YTD NUMBER(15,2);
  bal_PYM_DBT_RFI_CYTD NUMBER(15,2);
  bal_PYM_DBT_RFI_RUN NUMBER(15,2);
  bal_PYM_DBT_RFI_PTD NUMBER(15,2);
  bal_PYM_DBT_RFI_YTD NUMBER(15,2);
  bal_PO_NRFI_RUN NUMBER(15,2);
  bal_PO_NRFI_PTD NUMBER(15,2);
  bal_PO_NRFI_YTD NUMBER(15,2);
  bal_PO_RFI_RUN NUMBER(15,2);
  bal_PO_RFI_PTD NUMBER(15,2);
  bal_PO_RFI_YTD NUMBER(15,2);
  bal_PRCH_ANU_TXB_NRFI_RUN NUMBER(15,2);
  bal_PRCH_ANU_TXB_NRFI_PTD NUMBER(15,2);
  bal_PRCH_ANU_TXB_NRFI_YTD NUMBER(15,2);
  bal_PRCH_ANU_TXB_RFI_RUN NUMBER(15,2);
  bal_PRCH_ANU_TXB_RFI_PTD NUMBER(15,2);
  bal_PRCH_ANU_TXB_RFI_YTD NUMBER(15,2);
  bal_RGT_AST_NRFI_CYTD NUMBER(15,2);
  bal_RGT_AST_NRFI_RUN NUMBER(15,2);
  bal_RGT_AST_NRFI_PTD NUMBER(15,2);
  bal_RGT_AST_NRFI_YTD NUMBER(15,2);
  bal_RGT_AST_RFI_CYTD NUMBER(15,2);
  bal_RGT_AST_RFI_RUN NUMBER(15,2);
  bal_RGT_AST_RFI_PTD NUMBER(15,2);
  bal_RGT_AST_RFI_YTD NUMBER(15,2);
  bal_SHR_OPT_EXD_NRFI_RUN NUMBER(15,2);
  bal_SHR_OPT_EXD_NRFI_PTD NUMBER(15,2);
  bal_SHR_OPT_EXD_NRFI_YTD NUMBER(15,2);
  bal_SHR_OPT_EXD_RFI_RUN NUMBER(15,2);
  bal_SHR_OPT_EXD_RFI_PTD NUMBER(15,2);
  bal_SHR_OPT_EXD_RFI_YTD NUMBER(15,2);
  bal_SITE_YTD NUMBER(15,2);
  bal_TXB_AP_NRFI_RUN NUMBER(15,2);
  bal_TXB_AP_NRFI_PTD NUMBER(15,2);
  bal_TXB_AP_NRFI_YTD NUMBER(15,2);
  bal_TXB_AP_RFI_RUN NUMBER(15,2);
  bal_TXB_AP_RFI_PTD NUMBER(15,2);
  bal_TXB_AP_RFI_YTD NUMBER(15,2);
  bal_TXB_INC_NRFI_CYTD NUMBER(15,2);
  bal_TXB_INC_NRFI_RUN NUMBER(15,2);
  bal_TXB_INC_NRFI_PTD NUMBER(15,2);
  bal_TXB_INC_NRFI_YTD NUMBER(15,2);
  bal_TXB_INC_RFI_CYTD NUMBER(15,2);
  bal_TXB_INC_RFI_RUN NUMBER(15,2);
  bal_TXB_INC_RFI_PTD NUMBER(15,2);
  bal_TXB_INC_RFI_YTD NUMBER(15,2);
  bal_TXB_PEN_NRFI_CYTD NUMBER(15,2);
  bal_TXB_PEN_NRFI_RUN NUMBER(15,2);
  bal_TXB_PEN_NRFI_PTD NUMBER(15,2);
  bal_TXB_PEN_NRFI_YTD NUMBER(15,2);
  bal_TXB_PEN_RFI_CYTD NUMBER(15,2);
  bal_TXB_PEN_RFI_RUN NUMBER(15,2);
  bal_TXB_PEN_RFI_PTD NUMBER(15,2);
  bal_TXB_PEN_RFI_YTD NUMBER(15,2);
  bal_TXB_SUBS_NRFI_RUN NUMBER(15,2);
  bal_TXB_SUBS_NRFI_PTD NUMBER(15,2);
  bal_TXB_SUBS_NRFI_YTD NUMBER(15,2);
  bal_TXB_SUBS_RFI_RUN NUMBER(15,2);
  bal_TXB_SUBS_RFI_PTD NUMBER(15,2);
  bal_TXB_SUBS_RFI_YTD NUMBER(15,2);
  bal_TAX_YTD NUMBER(15,2);
  bal_TX_ON_AB_PTD NUMBER(15,2);
  bal_TX_ON_AB_YTD NUMBER(15,2);
  bal_TX_ON_AP_RUN NUMBER(15,2);
  bal_TX_ON_AP_PTD NUMBER(15,2);
  bal_TX_ON_AP_YTD NUMBER(15,2);
  bal_TX_ON_BP_PTD NUMBER(15,2);
  bal_TX_ON_BP_YTD NUMBER(15,2);
  bal_TX_ON_TA_PTD NUMBER(15,2);
  bal_TX_ON_TA_YTD NUMBER(15,2);
  bal_TX_ON_FB_PTD NUMBER(15,2);
  bal_TX_ON_FB_YTD NUMBER(15,2);
  bal_TX_ON_NI_PTD NUMBER(15,2);
  bal_TX_ON_NI_YTD NUMBER(15,2);
  bal_TX_ON_PO_PTD NUMBER(15,2);
  bal_TX_ON_PO_YTD NUMBER(15,2);
  bal_TEL_ALL_NRFI_CYTD NUMBER(15,2);
  bal_TEL_ALL_NRFI_RUN NUMBER(15,2);
  bal_TEL_ALL_NRFI_PTD NUMBER(15,2);
  bal_TEL_ALL_NRFI_YTD NUMBER(15,2);
  bal_TEL_ALL_RFI_CYTD NUMBER(15,2);
  bal_TEL_ALL_RFI_RUN NUMBER(15,2);
  bal_TEL_ALL_RFI_PTD NUMBER(15,2);
  bal_TEL_ALL_RFI_YTD NUMBER(15,2);
  bal_TOOL_ALL_NRFI_CYTD NUMBER(15,2);
  bal_TOOL_ALL_NRFI_RUN NUMBER(15,2);
  bal_TOOL_ALL_NRFI_PTD NUMBER(15,2);
  bal_TOOL_ALL_NRFI_YTD NUMBER(15,2);
  bal_TOOL_ALL_RFI_CYTD NUMBER(15,2);
  bal_TOOL_ALL_RFI_RUN NUMBER(15,2);
  bal_TOOL_ALL_RFI_PTD NUMBER(15,2);
  bal_TOOL_ALL_RFI_YTD NUMBER(15,2);
  bal_TOT_INC_PTD NUMBER(15,2);
  bal_TOT_INC_YTD NUMBER(15,2);
  bal_TOT_NRFI_AN_INC_CYTD NUMBER(15,2);
  bal_TOT_NRFI_AN_INC_RUN NUMBER(15,2);
  bal_TOT_NRFI_AN_INC_YTD NUMBER(15,2);
  bal_TOT_NRFI_INC_CYTD NUMBER(15,2);
  bal_TOT_NRFI_INC_RUN NUMBER(15,2);
  bal_TOT_NRFI_INC_PTD NUMBER(15,2);
  bal_TOT_NRFI_INC_YTD NUMBER(15,2);
  bal_TOT_RFI_AN_INC_CYTD NUMBER(15,2);
  bal_TOT_RFI_AN_INC_RUN NUMBER(15,2);
  bal_TOT_RFI_AN_INC_PTD NUMBER(15,2);
  bal_TOT_RFI_AN_INC_YTD NUMBER(15,2);
  bal_TOT_RFI_INC_CYTD NUMBER(15,2);
  bal_TOT_RFI_INC_RUN NUMBER(15,2);
  bal_TOT_RFI_INC_PTD NUMBER(15,2);
  bal_TOT_RFI_INC_YTD NUMBER(15,2);
  bal_TOT_SEA_WRK_DYS_WRK_YTD NUMBER (15,2);
  bal_TOT_TXB_INC_ITD NUMBER(15,2);
  bal_TA_NRFI_CYTD NUMBER(15,2);
  bal_TA_NRFI_PTD NUMBER(15,2);
  bal_TA_NRFI_YTD NUMBER(15,2);
  bal_TA_RFI_CYTD NUMBER(15,2);
  bal_TA_RFI_PTD NUMBER(15,2);
  bal_TA_RFI_YTD NUMBER(15,2);
  bal_USE_VEH_NRFI_CYTD NUMBER(15,2);
  bal_USE_VEH_NRFI_RUN NUMBER(15,2);
  bal_USE_VEH_NRFI_PTD NUMBER(15,2);
  bal_USE_VEH_NRFI_YTD NUMBER(15,2);
  bal_USE_VEH_RFI_CYTD NUMBER(15,2);
  bal_USE_VEH_RFI_RUN NUMBER(15,2);
  bal_USE_VEH_RFI_PTD NUMBER(15,2);
  bal_USE_VEH_RFI_YTD NUMBER(15,2);


-- Trace Globals
--   These are set within the procedures and function calls!!
--   Values can be output by the main function call from formula
--
  -- Calculation Type
  trc_CalTyp VARCHAR2(7) DEFAULT 'Unknown';
  -- Factors
  trc_TxbIncPtd NUMBER(15,2) DEFAULT 0;
  trc_PrdFactor NUMBER DEFAULT 0;
  trc_PosFactor NUMBER DEFAULT 0;
  trc_SitFactor NUMBER := 1;
  -- Base Income
  trc_BseErn NUMBER(15,2) DEFAULT 0;
  trc_TxbBseInc NUMBER(15,2) DEFAULT 0;
  trc_TotLibBse NUMBER(15,2) DEFAULT 0;
  -- Period Pension Fund
  trc_TxbIncYtd NUMBER(15,2) DEFAULT 0;
  trc_PerTxbInc NUMBER(15,2) DEFAULT 0;
  trc_PerPenFnd NUMBER(15,2) DEFAULT 0;
  trc_PerRfiCon NUMBER(15,2) DEFAULT 0;
  trc_PerRfiTxb NUMBER(15,2) DEFAULT 0;
  trc_PerPenFndMax NUMBER(15,2) DEFAULT 0;
  trc_PerPenFndAbm NUMBER(15,2) DEFAULT 0;
  -- Annual Pension Fund
  trc_AnnTxbInc NUMBER(15,2) DEFAULT 0;
  trc_AnnPenFnd NUMBER(15,2) DEFAULT 0;
  trc_AnnRfiCon NUMBER(15,2) DEFAULT 0;
  trc_AnnRfiTxb NUMBER(15,2) DEFAULT 0;
  trc_AnnPenFndMax NUMBER(15,2) DEFAULT 0;
  trc_AnnPenFndAbm NUMBER(15,2) DEFAULT 0;
  -- Arrear Pension
  trc_ArrPenFnd NUMBER(15,2) DEFAULT 0;
  trc_ArrPenFndAbm NUMBER(15,2) DEFAULT 0;
  trc_PfUpdFig NUMBER(15,2) DEFAULT 0;
  -- Retirement Annuity
  trc_RetAnu NUMBER(15,2) DEFAULT 0;
  trc_NrfiCon NUMBER(15,2) DEFAULT 0;
  trc_RetAnuMax NUMBER(15,2) DEFAULT 0;
  trc_RetAnuAbm NUMBER(15,2) DEFAULT 0;
  -- Arrear Retirement Annuity
  trc_ArrRetAnu NUMBER(15,2) DEFAULT 0;
  trc_ArrRetAnuAbm NUMBER(15,2) DEFAULT 0;
  trc_RaUpdFig NUMBER(15,2) DEFAULT 0;
  -- Rebates Thresholds and Med Aid
  trc_Rebate NUMBER(15,2) DEFAULT 0;
  trc_Threshold NUMBER(15,2) DEFAULT 0;
  trc_MedAidAbm NUMBER(15,2) DEFAULT 0;
  -- Abatement Totals
  trc_PerTotAbm NUMBER(15,2) DEFAULT 0;
  trc_AnnTotAbm NUMBER(15,2) DEFAULT 0;
  -- Normal Income
  trc_NorIncYtd NUMBER(15,2) DEFAULT 0;
  trc_NorIncPtd NUMBER(15,2) DEFAULT 0;
  trc_NorErn NUMBER(15,2) DEFAULT 0;
  trc_TxbNorInc NUMBER(15,2) DEFAULT 0;
  trc_LibFyNI NUMBER(15,2) DEFAULT 0;
  trc_LibFpNI NUMBER(15,2) DEFAULT 0;
  -- Fringe Benefits
  trc_FrnBenYtd NUMBER(15,2) DEFAULT 0;
  trc_FrnBenPtd NUMBER(15,2) DEFAULT 0;
  trc_FrnBenErn NUMBER(15,2) DEFAULT 0;
  trc_TxbFrnInc NUMBER(15,2) DEFAULT 0;
  trc_LibFyFB NUMBER(15,2) DEFAULT 0;
  trc_LibFpFB NUMBER(15,2) DEFAULT 0;
  -- Travel Allowance
  trc_TrvAllYtd NUMBER(15,2) DEFAULT 0;
  trc_TrvAllPtd NUMBER(15,2) DEFAULT 0;
  trc_TrvAllErn NUMBER(15,2) DEFAULT 0;
  trc_TxbTrvInc NUMBER(15,2) DEFAULT 0;
  trc_LibFyTA NUMBER(15,2) DEFAULT 0;
  trc_LibFpTA NUMBER(15,2) DEFAULT 0;
  -- Bonus Provision
  trc_BonProYtd NUMBER(15,2) DEFAULT 0;
  trc_BonProPtd NUMBER(15,2) DEFAULT 0;
  trc_BonProErn NUMBER(15,2) DEFAULT 0;
  trc_TxbBonProInc NUMBER(15,2) DEFAULT 0;
  trc_LibFyBP NUMBER(15,2) DEFAULT 0;
  trc_LibFpBP NUMBER(15,2) DEFAULT 0;
  -- Annual Bonus
  trc_AnnBonYtd NUMBER(15,2) DEFAULT 0;
  trc_AnnBonPtd NUMBER(15,2) DEFAULT 0;
  trc_AnnBonErn NUMBER(15,2) DEFAULT 0;
  trc_TxbAnnBonInc NUMBER(15,2) DEFAULT 0;
  trc_LibFyAB NUMBER(15,2) DEFAULT 0;
  trc_LibFpAB NUMBER(15,2) DEFAULT 0;
  -- Annual Payments
  trc_AnnPymYtd NUMBER(15,2) DEFAULT 0;
  trc_AnnPymPtd NUMBER(15,2) DEFAULT 0;
  trc_AnnPymErn NUMBER(15,2) DEFAULT 0;
  trc_TxbAnnPymInc NUMBER(15,2) DEFAULT 0;
  trc_LibFyAP NUMBER(15,2) DEFAULT 0;
  trc_LibFpAP NUMBER(15,2) DEFAULT 0;
  -- Pubilc Office Allowance
  trc_PblOffYtd NUMBER(15,2) DEFAULT 0;
  trc_PblOffPtd NUMBER(15,2) DEFAULT 0;
  trc_PblOffErn NUMBER(15,2) DEFAULT 0;
  trc_LibFyPO NUMBER(15,2) DEFAULT 0;
  trc_LibFpPO NUMBER(15,2) DEFAULT 0;
  -- Messages
  trc_MsgTxStatus VARCHAR2(100) DEFAULT ' ';
  trc_LibWrn VARCHAR2(100) DEFAULT ' ';
-- trc_WrnNI
--  trc_WrnFB VARCHAR2(100) DEFAULT ' ';
--  trc_WrnTA VARCHAR2(100) DEFAULT ' ';
--  trc_WrnBP VARCHAR2(100) DEFAULT ' ';
--  trc_WrnAB VARCHAR2(100) DEFAULT ' ';
--  trc_WrnAP VARCHAR2(100) DEFAULT ' ';
--  trc_WrnPO VARCHAR2(100) DEFAULT ' ';
  -- Pay Value of This Calculation
  trc_PayValue NUMBER(15,2) DEFAULT 0;
  -- PAYE and SITE Values
  trc_PayeVal NUMBER(15,2) DEFAULT 0;
  trc_SiteVal NUMBER(15,2) DEFAULT 0;
  -- IT3A Threshold Indicator
  trc_It3Ind NUMBER DEFAULT 0;
  -- Tax Percentage Value On trace
  trc_TxPercVal NUMBER DEFAULT 0;
  -- Total Taxable Income Update Figure
  trc_OUpdFig NUMBER(15,2) DEFAULT 0;

  -- NpVal Override Globals
  trc_NpValNIOvr BOOLEAN DEFAULT FALSE;
  trc_NpValFBOvr BOOLEAN DEFAULT FALSE;
  trc_NpValTAOvr BOOLEAN DEFAULT FALSE;
  trc_NpValBPOvr BOOLEAN DEFAULT FALSE;
  trc_NpValABOvr BOOLEAN DEFAULT FALSE;
  trc_NpValAPOvr BOOLEAN DEFAULT FALSE;
  trc_NpValPOOvr BOOLEAN DEFAULT FALSE;

  -- Global Exception Message
  xpt_Msg VARCHAR2(30) DEFAULT 'No Error';
  -- Global Exception
  xpt_E EXCEPTION;




/* PACKAGE BODY */
-- Utility Functions
--

FUNCTION LstPeriod RETURN BOOLEAN AS

BEGIN
  -- Is this the last period for the tax year
  --
  IF dbi_ZA_PAY_PRDS_LFT = 1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
           xpt_Msg := 'LstPeriod: '||TO_CHAR(SQLCODE);
    END IF;
    RAISE xpt_E;

END LstPeriod;

FUNCTION EmpTermInPeriod RETURN BOOLEAN AS

BEGIN
  -- Was the employee terminated in the current period
  --
  IF dbi_ZA_ACT_END_DTE BETWEEN dbi_ZA_CUR_PRD_STRT_DTE AND dbi_ZA_CUR_PRD_END_DTE THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
      xpt_Msg := 'EmpTermInPeriod: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END EmpTermInPeriod;

FUNCTION EmpTermPrePeriod RETURN BOOLEAN AS

BEGIN
  -- Was the employee terminated before the current period
  --
  IF dbi_ZA_ACT_END_DTE <= dbi_ZA_CUR_PRD_STRT_DTE THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
      xpt_Msg := 'EmpTermPrePeriod: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END EmpTermPrePeriod;

FUNCTION PreErnPeriod RETURN BOOLEAN AS

BEGIN

  -- PTD Taxable Income
  --
  trc_TxbIncPtd :=
    (bal_AST_PRCHD_RVAL_NRFI_PTD
    +bal_AST_PRCHD_RVAL_RFI_PTD
    +bal_BP_PTD
    +bal_BUR_AND_SCH_NRFI_PTD
    +bal_BUR_AND_SCH_RFI_PTD
    +bal_COMM_NRFI_PTD
    +bal_COMM_RFI_PTD
    +bal_COMP_ALL_NRFI_PTD
    +bal_COMP_ALL_RFI_PTD
    +bal_ENT_ALL_NRFI_PTD
    +bal_ENT_ALL_RFI_PTD
    +bal_FREE_ACCOM_NRFI_PTD
    +bal_FREE_ACCOM_RFI_PTD
    +bal_FREE_SERV_NRFI_PTD
    +bal_FREE_SERV_RFI_PTD
    +bal_LOW_LOANS_NRFI_PTD
    +bal_LOW_LOANS_RFI_PTD
    +bal_MLS_AND_VOUCH_NRFI_PTD
    +bal_MLS_AND_VOUCH_RFI_PTD
    +bal_MED_PAID_NRFI_PTD
    +bal_MED_PAID_RFI_PTD
    +bal_OTHER_TXB_ALL_NRFI_PTD
    +bal_OTHER_TXB_ALL_RFI_PTD
    +bal_OVTM_NRFI_PTD
    +bal_OVTM_RFI_PTD
    +bal_PYM_DBT_NRFI_PTD
    +bal_PYM_DBT_RFI_PTD
    +bal_RGT_AST_NRFI_PTD
    +bal_RGT_AST_RFI_PTD
    +bal_TXB_INC_NRFI_PTD
    +bal_TXB_INC_RFI_PTD
    +bal_TXB_PEN_NRFI_PTD
    +bal_TXB_PEN_RFI_PTD
    +bal_TEL_ALL_NRFI_PTD
    +bal_TEL_ALL_RFI_PTD
    +bal_TOOL_ALL_NRFI_PTD
    +bal_TOOL_ALL_RFI_PTD
    +bal_TA_NRFI_PTD
    +bal_TA_RFI_PTD
    +bal_USE_VEH_NRFI_PTD
    +bal_USE_VEH_RFI_PTD
    );

  -- Ptd Annual Bonus
  trc_AnnBonPtd :=
    (bal_AB_NRFI_RUN
    +bal_AB_RFI_RUN
    );

  -- Ytd Annual Payments
  trc_AnnPymPtd :=
    (bal_ANU_FRM_RET_FND_NRFI_RUN
    +bal_ANU_FRM_RET_FND_RFI_RUN
    +bal_PRCH_ANU_TXB_NRFI_RUN
    +bal_PRCH_ANU_TXB_RFI_RUN
    +bal_SHR_OPT_EXD_NRFI_RUN
    +bal_SHR_OPT_EXD_RFI_RUN
    +bal_TXB_AP_NRFI_RUN
    +bal_TXB_AP_RFI_RUN
    +bal_TXB_SUBS_NRFI_RUN
    +bal_TXB_SUBS_RFI_RUN
    );

  -- Annual Type PTD Income with no Period Type PTD Income
  IF (trc_AnnBonPtd + trc_AnnPymPtd) > 0 AND trc_TxbIncPtd <= 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;



EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
      xpt_Msg := 'PreErnPeriod: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END PreErnPeriod;


FUNCTION SitePeriod RETURN BOOLEAN AS

BEGIN

  IF LstPeriod OR EmpTermInPeriod OR EmpTermPrePeriod THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
      xpt_Msg := 'SitePeriod: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END SitePeriod;

PROCEDURE PeriodFactor AS

BEGIN
  IF dbi_ZA_TX_YR_STRT < dbi_ASG_STRT_DTE
  THEN

    IF bal_TOT_INC_YTD = bal_TOT_INC_PTD  /* i.e. first pay period for the person */
    THEN
      trc_PrdFactor := (dbi_ZA_CUR_PRD_END_DTE - dbi_ASG_STRT_DTE + 1) /
                          (dbi_ZA_CUR_PRD_END_DTE - dbi_ZA_CUR_PRD_STRT_DTE + 1);
    ELSE
      trc_PrdFactor := 1;
    END IF;

  ELSE
    trc_PrdFactor := 1;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
      xpt_Msg := 'PeriodFactor: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END PeriodFactor;


PROCEDURE PossiblePeriodsFactor AS

BEGIN
  IF dbi_ZA_TX_YR_STRT >= dbi_ASG_STRT_DTE
  THEN
    trc_PosFactor := 1;
  ELSE
    trc_PosFactor := dbi_ZA_DYS_IN_YR / (dbi_ZA_TX_YR_END - dbi_ASG_STRT_DTE + 1);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
      xpt_Msg := 'PossiblePeriodsFactor: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END PossiblePeriodsFactor;


FUNCTION Annualise
  (p_YtdInc IN NUMBER
  ,p_PtdInc IN NUMBER
  ) RETURN NUMBER
AS
  l_AnnFig  NUMBER(15,2);
  l_PtdFact  NUMBER(15,2);

BEGIN

  l_PtdFact := p_PtdInc / trc_PrdFactor;

  -- Payment over less than one period?
  IF trc_PrdFactor < 1 THEN
    l_AnnFig := ((l_PtdFact * dbi_ZA_PAY_PRDS_LFT)
                    +(p_YtdInc - p_PtdInc)
                    ) * trc_PosFactor;
  ELSE
    l_AnnFig := ((l_PtdFact * dbi_ZA_PAY_PRDS_LFT)
                    +(p_YtdInc - l_PtdFact)
                    ) * trc_PosFactor;
  END IF;
RETURN l_AnnFig;
EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
      xpt_Msg := 'Annualise: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END Annualise;


PROCEDURE Abatements AS

-- Variables
  l_65Year DATE;

BEGIN
-- Initialise the figures needed for the calculation
-- of tax abatements and rebates, based on the
-- calculation type
--
-- NorCalc
IF trc_CalTyp = 'NorCalc' THEN

-- Pension Fund Abatement
--
  -- Period Calculation
  --
  trc_TxbIncYtd :=
  (bal_AST_PRCHD_RVAL_NRFI_YTD
  +bal_AST_PRCHD_RVAL_RFI_YTD
  +bal_BP_YTD
  +bal_BUR_AND_SCH_NRFI_YTD
  +bal_BUR_AND_SCH_RFI_YTD
  +bal_COMM_NRFI_YTD
  +bal_COMM_RFI_YTD
  +bal_COMP_ALL_NRFI_YTD
  +bal_COMP_ALL_RFI_YTD
  +bal_ENT_ALL_NRFI_YTD
  +bal_ENT_ALL_RFI_YTD
  +bal_FREE_ACCOM_NRFI_YTD
  +bal_FREE_ACCOM_RFI_YTD
  +bal_FREE_SERV_NRFI_YTD
  +bal_FREE_SERV_RFI_YTD
  +bal_LOW_LOANS_NRFI_YTD
  +bal_LOW_LOANS_RFI_YTD
  +bal_MLS_AND_VOUCH_NRFI_YTD
  +bal_MLS_AND_VOUCH_RFI_YTD
  +bal_MED_PAID_NRFI_YTD
  +bal_MED_PAID_RFI_YTD
  +bal_OTHER_TXB_ALL_NRFI_YTD
  +bal_OTHER_TXB_ALL_RFI_YTD
  +bal_OVTM_NRFI_YTD
  +bal_OVTM_RFI_YTD
  +bal_PYM_DBT_NRFI_YTD
  +bal_PYM_DBT_RFI_YTD
  +bal_RGT_AST_NRFI_YTD
  +bal_RGT_AST_RFI_YTD
  +bal_TXB_INC_NRFI_YTD
  +bal_TXB_INC_RFI_YTD
  +bal_TXB_PEN_NRFI_YTD
  +bal_TXB_PEN_RFI_YTD
  +bal_TEL_ALL_NRFI_YTD
  +bal_TEL_ALL_RFI_YTD
  +bal_TOOL_ALL_NRFI_YTD
  +bal_TOOL_ALL_RFI_YTD
  +bal_TA_NRFI_YTD
  +bal_TA_RFI_YTD
  +bal_USE_VEH_NRFI_YTD
  +bal_USE_VEH_RFI_YTD
  );
  -- Annualise Period Taxable Income
  trc_PerTxbInc := Annualise
                 (p_YtdInc => trc_TxbIncYtd
                 ,p_PtdInc => trc_TxbIncPtd
                 );
  -- Annualise Period Pension Fund Contributions
  trc_PerPenFnd := Annualise
                 (p_YtdInc => bal_CUR_PF_YTD
                 ,p_PtdInc => bal_CUR_PF_PTD
                 );
  -- Annualise Period RFIable Contributions
  trc_PerRfiCon := Annualise
                 (p_ytdInc => bal_TOT_RFI_INC_YTD
                 ,p_PtdInc => bal_TOT_RFI_INC_PTD
                 );
  -- Annual Calculation
  --
  -- Calculate Annual Taxable Income
  trc_AnnTxbInc :=
  (trc_PerTxbInc
  +bal_AB_NRFI_YTD
  +bal_AB_RFI_YTD
  +bal_ANU_FRM_RET_FND_NRFI_YTD
  +bal_ANU_FRM_RET_FND_RFI_YTD
  +bal_PRCH_ANU_TXB_NRFI_YTD
  +bal_PRCH_ANU_TXB_RFI_YTD
  +bal_SHR_OPT_EXD_NRFI_YTD
  +bal_SHR_OPT_EXD_RFI_YTD
  +bal_TXB_AP_NRFI_YTD
  +bal_TXB_AP_RFI_YTD
  +bal_TXB_SUBS_NRFI_YTD
  +bal_TXB_SUBS_RFI_YTD
  );
  -- Annual Pension Fund Contribution
  trc_AnnPenFnd := trc_PerPenFnd + bal_ANN_PF_YTD;
  -- Annual Rfi Contribution
  trc_AnnRfiCon := trc_PerRfiCon + bal_TOT_RFI_AN_INC_YTD;

-- Arrear Pension Fund Abatement
--
  -- Check Arrear Pension Fund Frequency
  IF dbi_ARR_PF_FRQ = 'M' THEN
    trc_ArrPenFnd := Annualise
                   (p_YtdInc => bal_ARR_PF_YTD
                   ,p_PtdInc => bal_ARR_PF_PTD
                   )
                   +bal_EXC_ARR_PEN_ITD;
  ELSE
    trc_ArrPenFnd := bal_ARR_PF_YTD
                 + bal_EXC_ARR_PEN_ITD;
  END IF;

-- Retirement Annuity Abatement
--

  -- Calculate RA Contribution
  IF dbi_RA_FRQ = 'M' THEN
    trc_RetAnu := Annualise
                (p_YtdInc => bal_CUR_RA_YTD
                ,p_PtdINc => bal_CUR_RA_PTD
                );
  ELSE
    trc_RetAnu := bal_CUR_RA_YTD;
  END IF;

  -- Calculate Nrfi Contribution based on Pension Fund
  -- Contributions
  IF bal_CUR_PF_YTD = 0 THEN
    trc_NrfiCon := Annualise
                 (p_YtdInc => bal_TOT_RFI_INC_YTD + bal_TOT_NRFI_INC_YTD
                 ,p_PtdInc => bal_TOT_RFI_INC_PTD + bal_TOT_NRFI_INC_PTD
                 )
                 +bal_TOT_NRFI_AN_INC_YTD
                 +bal_TOT_RFI_AN_INC_YTD;
  ELSE
    trc_NrfiCon := Annualise
                 (p_YtdInc => bal_TOT_NRFI_INC_YTD
                 ,p_PtdInc => bal_TOT_NRFI_INC_PTD
                 )
                 +bal_TOT_NRFI_AN_INC_YTD;
  END IF;


-- Arrear Retirement Annuity Abatement
--
  -- Check Arrear Retirement Annuity Frequency
  IF dbi_ARR_RA_FRQ = 'M' THEN
    trc_ArrRetAnu := Annualise
                   (p_YtdInc => bal_ARR_RA_YTD
                   ,p_PtdInc => bal_ARR_RA_PTD
                   )
                   +bal_EXC_ARR_RA_ITD;
  ELSE
    trc_ArrRetAnu := bal_ARR_RA_YTD
                 + bal_EXC_ARR_RA_ITD;
  END IF;


-- Medical Aid Abatement
--
  trc_MedAidAbm := Annualise
                 (p_YtdInc => bal_MED_CONTR_YTD
                 ,p_PtdInc => bal_MED_CONTR_PTD
                 );

ELSIF trc_CalTyp IN ('YtdCalc','SitCalc') THEN

-- Pension Fund Abatement
--

  -- Period Calculation
  --

  -- Annualise Period Taxable Income
  trc_PerTxbInc := trc_TxbIncYtd * trc_SitFactor;
  -- Annualise Period Pension Fund Contribution
  trc_PerPenFnd := bal_CUR_PF_YTD * trc_SitFactor;
  -- Annualise Period Rfiable Contributions
  trc_PerRfiCon := bal_TOT_RFI_INC_YTD * trc_SitFactor;

  -- Annual Calculation
  --

  -- Calculate Annual Taxable Income
  trc_AnnTxbInc :=
  ( trc_PerTxbInc
  + bal_AB_NRFI_YTD
  + bal_AB_RFI_YTD
  + bal_ANU_FRM_RET_FND_NRFI_YTD
  + bal_ANU_FRM_RET_FND_RFI_YTD
  + bal_PRCH_ANU_TXB_NRFI_YTD
  + bal_PRCH_ANU_TXB_RFI_YTD
  + bal_SHR_OPT_EXD_NRFI_YTD
  + bal_SHR_OPT_EXD_RFI_YTD
  + bal_TXB_AP_NRFI_YTD
  + bal_TXB_AP_RFI_YTD
  + bal_TXB_SUBS_NRFI_YTD
  + bal_TXB_SUBS_RFI_YTD
  );

  -- Annual Pension Fund Contribution
  trc_AnnPenFnd := trc_PerPenFnd + bal_ANN_PF_YTD;
  -- Annual Rfi Contribution
  trc_AnnRfiCon := trc_PerRfiCon + bal_TOT_RFI_AN_INC_YTD;

-- Arrear Pension Fund Abatement
--

  -- Check Arrear Pension Fund Frequency
  IF dbi_ARR_PF_FRQ = 'M' THEN
    trc_ArrPenFnd := (bal_ARR_PF_YTD * trc_SitFactor)
                   +bal_EXC_ARR_PEN_ITD;
  ELSE
    trc_ArrPenFnd := bal_ARR_PF_YTD
                 + bal_EXC_ARR_PEN_ITD;
  END IF;

-- Retirement Annuity Abatement
--

  -- Calculate RA Contribution
  IF dbi_RA_FRQ = 'M' THEN
    trc_RetAnu := bal_CUR_RA_YTD * trc_SitFactor;
  ELSE
    trc_RetAnu := bal_CUR_RA_YTD;
  END IF;

  -- Calculate Nrfi Contribution based on Pension Fund
  -- Contributions
  IF bal_CUR_PF_YTD = 0 THEN
    trc_NrfiCon :=
    ((bal_TOT_RFI_INC_YTD
     + bal_TOT_NRFI_INC_YTD)* trc_SitFactor)
     +bal_TOT_NRFI_AN_INC_YTD
     +bal_TOT_RFI_AN_INC_YTD;
   ELSE
     trc_NrfiCon := (bal_TOT_NRFI_INC_YTD * trc_SitFactor)
                  +bal_TOT_NRFI_AN_INC_YTD;
   END IF;


-- Arrear Retirement Annuity Abatement
--
  -- Check Arrear Retirement Annuity Frequency
  IF dbi_ARR_RA_FRQ = 'M' THEN
    trc_ArrRetAnu := (bal_ARR_RA_YTD * trc_SitFactor)
                   +bal_EXC_ARR_RA_ITD;
  ELSE
    trc_ArrRetAnu := bal_ARR_RA_YTD
                 + bal_EXC_ARR_RA_ITD;
  END IF;


-- Medical Aid Abatement
  trc_MedAidAbm := bal_MED_CONTR_YTD * trc_SitFactor;



ELSIF trc_CalTyp = 'CalCalc' THEN
-- Pension Fund Abatement
--
  -- Period Calculation
  --

  -- Annualise Period Taxable Income
  trc_PerTxbInc := trc_TxbIncYtd * trc_SitFactor;
  -- Annualise Period Pension Fund Contribution
  trc_PerPenFnd := bal_CUR_PF_CYTD * trc_SitFactor;
  -- Annualise Period Rfiable Contributions
  trc_PerRfiCon := bal_TOT_RFI_INC_CYTD * trc_SitFactor;


  -- Annual Calculation
  --

  -- Calculate Annual Taxable Income
  trc_AnnTxbInc :=
  ( trc_PerTxbInc
  + bal_AB_NRFI_YTD
  + bal_AB_RFI_YTD
  + bal_ANU_FRM_RET_FND_NRFI_YTD
  + bal_ANU_FRM_RET_FND_RFI_YTD
  + bal_PRCH_ANU_TXB_NRFI_YTD
  + bal_PRCH_ANU_TXB_RFI_YTD
  + bal_SHR_OPT_EXD_NRFI_YTD
  + bal_SHR_OPT_EXD_RFI_YTD
  + bal_TXB_AP_NRFI_YTD
  + bal_TXB_AP_RFI_YTD
  + bal_TXB_SUBS_NRFI_YTD
  + bal_TXB_SUBS_RFI_YTD
  );

  -- Annual Pension Fund Contribution
  trc_AnnPenFnd := trc_PerPenFnd + bal_ANN_PF_YTD;
  -- Annual Rfi Contribution
  trc_AnnRfiCon := trc_PerRfiCon + bal_TOT_RFI_AN_INC_YTD;


-- Arrear Pension Fund Abatement
--

  -- Check Arrear Pension Fund Frequency
  IF dbi_ARR_PF_FRQ = 'M' THEN
    trc_ArrPenFnd := (bal_ARR_PF_CYTD * trc_SitFactor)
                   +bal_EXC_ARR_PEN_ITD;
  ELSE
    trc_ArrPenFnd := bal_ARR_PF_CYTD
                 + bal_EXC_ARR_PEN_ITD;
  END IF;

-- Retirement Annuity Abatement
--

  -- Calculate RA Contribution
  IF dbi_RA_FRQ = 'M' THEN
    trc_RetAnu := bal_CUR_RA_CYTD * trc_SitFactor;
  ELSE
    trc_RetAnu := bal_CUR_RA_CYTD;
  END IF;

  -- Calculate Nrfi Contribution based on Pension Fund
  -- Contributions
  IF bal_CUR_PF_CYTD = 0 THEN
    trc_NrfiCon :=
    ((bal_TOT_RFI_INC_CYTD
     + bal_TOT_NRFI_INC_CYTD)* trc_SitFactor)
     +bal_TOT_NRFI_AN_INC_CYTD
     +bal_TOT_RFI_AN_INC_CYTD;
   ELSE
     trc_NrfiCon := (bal_TOT_NRFI_INC_CYTD * trc_SitFactor)
                  +bal_TOT_NRFI_AN_INC_CYTD;
   END IF;

-- Arrear Retirement Annuity Abatement
--
  -- Check Arrear Retirement Annuity Frequency
  IF dbi_ARR_RA_FRQ = 'M' THEN
    trc_ArrRetAnu := (bal_ARR_RA_CYTD * trc_SitFactor)
                     +bal_EXC_ARR_RA_ITD;
  ELSE
    trc_ArrRetAnu := bal_ARR_RA_CYTD
                   + bal_EXC_ARR_RA_ITD;
  END IF;

-- Medical Aid Abatement
--
  trc_MedAidAbm := bal_MED_CONTR_CYTD * trc_SitFactor;

ELSIF trc_CalTyp = 'SeaCalc' THEN

-- Pension Fund Abatement
--
  -- Period Calculation
  --
  -- Annualise Period Taxable Income
  trc_PerTxbInc := trc_TxbIncPtd * trc_SitFactor;
  -- Annualise Period Pension Fund Contribution
  trc_PerPenFnd := bal_CUR_PF_RUN * trc_SitFactor;
  -- Annualise Period Rfiable Contributions
  trc_PerRfiCon := bal_TOT_RFI_INC_RUN * trc_SitFactor;

  -- Annual Calculation
  --

  -- Calculate Annual Taxable Income
  trc_AnnTxbInc :=
  ( trc_PerTxbInc
  + bal_AB_NRFI_RUN
  + bal_AB_RFI_RUN
  + bal_ANU_FRM_RET_FND_NRFI_RUN
  + bal_ANU_FRM_RET_FND_RFI_RUN
  + bal_PRCH_ANU_TXB_NRFI_RUN
  + bal_PRCH_ANU_TXB_RFI_RUN
  + bal_SHR_OPT_EXD_NRFI_RUN
  + bal_SHR_OPT_EXD_RFI_RUN
  + bal_TXB_AP_NRFI_RUN
  + bal_TXB_AP_RFI_RUN
  + bal_TXB_SUBS_NRFI_RUN
  + bal_TXB_SUBS_RFI_RUN
  );

  -- Annual Pension Fund Contribution
  trc_AnnPenFnd := trc_PerPenFnd + bal_ANN_PF_RUN;
  -- Annual Rfi Contribution
  trc_AnnRfiCon := trc_PerRfiCon + bal_TOT_RFI_AN_INC_RUN;

-- Arrear pension Fund Abatement
--
  trc_ArrPenFndAbm := 0;
-- Retirement Annuity Abatement
--

  -- Calculate RA Contribution
  IF dbi_RA_FRQ = 'M' THEN
    trc_RetAnu := bal_CUR_RA_RUN * trc_SitFactor;
  ELSE
    trc_RetAnu := bal_CUR_RA_RUN;
  END IF;

  -- Calculate Nrfi Contribution based on Pension Fund
  -- Contributions
  IF bal_CUR_PF_RUN = 0 THEN
    trc_NrfiCon :=
    ((bal_TOT_RFI_INC_RUN
     + bal_TOT_NRFI_INC_RUN)* trc_SitFactor)
     +bal_TOT_NRFI_AN_INC_RUN
     +bal_TOT_RFI_AN_INC_RUN;
   ELSE
     trc_NrfiCon := (bal_TOT_NRFI_INC_RUN * trc_SitFactor)
                  +bal_TOT_NRFI_AN_INC_RUN;
   END IF;

-- Arrear Retirement Annuity
--
  trc_ArrRetAnuAbm := 0;
-- Medical Aid Abatement
--
  trc_MedAidAbm := bal_MED_CONTR_RUN * trc_SitFactor;


ELSE
  NULL;
END IF;


-- CALCULATE THE ABATEMENTS
--
-- Pension Fund Abatement
--
  -- Period Calculation
  -- Rfi contributions may not be more than Taxable income
  trc_PerRfiTxb := LEAST(trc_PerTxbInc, trc_PerRfiCon);

  -- Calculate the Pension Fund Maximum
  trc_PerPenFndMax := GREATEST( glb_ZA_PF_AN_MX_ABT
                            ,(glb_ZA_PF_MX_PRC / 100 * trc_PerRfiTxb)
                            );
  -- Calculate Period Pension Fund Abatement
  trc_PerPenFndAbm := LEAST(trc_PerPenFnd, trc_PerPenFndMax);

  -- Annual Calculation
  -- Taxable Rfi (least of Annual Taxable Income and Annual RFI)
  trc_AnnRfiTxb := LEAST(trc_AnnTxbInc, trc_AnnRfiCon);

  -- Calculate the Pension Fund Maximum
  trc_AnnPenFndMax := GREATEST(glb_ZA_PF_AN_MX_ABT
                            ,glb_ZA_PF_MX_PRC / 100 * trc_AnnRfiTxb
                            );

  -- Calculate Annual Pension Fund Abatement
  trc_AnnPenFndAbm := LEAST(trc_AnnPenFnd,trc_AnnPenFndMax);

-- Arrear Pension Fund Abatement
--
  trc_ArrPenFndAbm := LEAST(trc_ArrPenFnd, glb_ZA_ARR_PF_AN_MX_ABT);

-- Retirement Annnnuity Abatement
--
  -- Calculate the Retirement Annuity Maximum
  trc_RetAnuMax := GREATEST(glb_ZA_PF_AN_MX_ABT
                         ,glb_ZA_RA_AN_MX_ABT - trc_AnnPenFndAbm
                         ,glb_ZA_RA_MX_PRC / 100 * trc_NrfiCon
                         );

  -- Calculate Retirement Annuity Abatement
  trc_RetAnuAbm := LEAST(trc_RetAnu, trc_RetAnuMax);

-- Arrear Retirement Annuity Abatement
--
  trc_ArrRetAnuAbm := LEAST(trc_ArrRetAnu, glb_ZA_ARR_RA_AN_MX_ABT);

-- Tax Rebates, Threshold Figure and Medical Aid
--   Abatements
  -- Calculate the assignments 65 Year Date
  l_65Year := add_months(dbi_PER_DTE_OF_BRTH,780);

  IF l_65Year <= dbi_ZA_TX_YR_END THEN
    -- give the extra abatement
    trc_Rebate := glb_ZA_PRI_TX_RBT + glb_ZA_ADL_TX_RBT;
    trc_Threshold := glb_ZA_SC_TX_THRSHLD;

  ELSE
    -- not eligable for extra abatement
    trc_Rebate := glb_ZA_PRI_TX_RBT;
    trc_Threshold := glb_ZA_PRI_TX_THRSHLD;
    trc_MedAidAbm := 0;

  END IF;

-- Total Abatements
--
-- Period Total Abatement
  trc_PerTotAbm := (trc_PerPenFndAbm
                   +trc_ArrPenFndAbm
                   +trc_RetAnuAbm
                   +trc_ArrRetAnuAbm
                   +trc_MedAidAbm
                   );

-- Annual Total Abatements
  trc_AnnTotAbm := (trc_AnnPenFndAbm
                   +trc_ArrPenFndAbm
                   +trc_RetAnuAbm
                   +trc_ArrRetAnuAbm
                   +trc_MedAidAbm
                   );

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'Abatements: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END Abatements;

PROCEDURE ArrearExcess AS
-- Variables
  l_PfExcessAmt NUMBER;
  l_RaExcessAmt NUMBER;

BEGIN
-- Pension Excess
  l_PfExcessAmt := (bal_ARR_PF_YTD + (bal_EXC_ARR_PEN_ITD - bal_EXC_ARR_PEN_PTD)) - glb_ZA_ARR_PF_AN_MX_ABT;

  IF l_PfExcessAmt > 0 THEN
    trc_PfUpdFig := -1*(bal_EXC_ARR_PEN_ITD) + l_PfExcessAmt;
  ELSE
    trc_PfUpdFig := -1*(bal_EXC_ARR_PEN_ITD);
  END IF;
-- Retirement Annuity
  l_RaExcessAmt := (bal_ARR_RA_YTD + (bal_EXC_ARR_RA_ITD - bal_EXC_ARR_RA_PTD)) - glb_ZA_ARR_RA_AN_MX_ABT;

  IF l_RaExcessAmt > 0 THEN
    trc_RaUpdFig := -1*(bal_EXC_ARR_RA_ITD) + l_RaExcessAmt;
  ELSE
    trc_RaUpdFig := -1*(bal_EXC_ARR_RA_ITD);
  END IF;



EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'ArrearExcess: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END ArrearExcess;

FUNCTION TaxLiability
  (p_Amt  IN NUMBER
  )RETURN  NUMBER
AS

-- Variables
--
  l_user_table_id pay_user_tables.user_table_id%TYPE;
  l_fixed_column_id pay_user_columns.user_column_id%TYPE;
  l_limit_column_id pay_user_columns.user_column_id%TYPE;
  l_percentage_column_id pay_user_columns.user_column_id%TYPE;
  l_bracket_row pay_user_rows_f.user_row_id%TYPE;
  l_fixed pay_user_column_instances_f.value%TYPE;
  l_limit pay_user_column_instances_f.value%TYPE;
  l_percentage pay_user_column_instances_f.value%TYPE;
  l_effective_date pay_payroll_actions.effective_date%TYPE;
  tax_liability NUMBER(15,2);
  l_TxbAmt NUMBER(15,2);

BEGIN
  IF dbi_TX_STA = 'C' THEN
    tax_liability := (p_Amt * dbi_TX_DIR_VAL) / 100;
  ELSIF dbi_TX_STA = 'D' THEN
    tax_liability := (p_Amt * dbi_TX_DIR_VAL) / 100;
  ELSIF dbi_TX_STA = 'E' THEN
    tax_liability := (p_Amt * glb_ZA_CC_TX_PRC) / 100;
  ELSIF dbi_TX_STA = 'F' THEN
    tax_liability := (p_Amt * glb_ZA_TMP_TX_RTE) / 100;
  ELSE

    /* Taxable Amount must be rounded off to two decimal places */
    l_TxbAmt := round(p_Amt,2);

    /* this selects the effective date for the payroll_run*/
    SELECT ppa.effective_date
      INTO l_effective_date
      FROM pay_payroll_actions ppa
     WHERE ppa.payroll_action_id = con_PRL_ACT_ID;


    /* Selects to get the relevant id's */
      SELECT user_table_id
        INTO l_user_table_id
        FROM pay_user_tables
       WHERE user_table_name = 'ZA_TAX_TABLE';

      select user_column_id
        into l_fixed_column_id
        from pay_user_columns
        where user_table_id = l_user_table_id
        and user_column_name = 'Fixed';

      select user_column_id
        into l_limit_column_id
        from pay_user_columns
        where user_table_id = l_user_table_id
        and user_column_name = 'Limit';

      select user_column_id
        into l_percentage_column_id
        from pay_user_columns
        where user_table_id = l_user_table_id
        and user_column_name = 'Percentage';

      select purf.user_row_id
        into l_bracket_row
        from pay_user_rows_f purf
        where purf.user_table_id = l_user_table_id
        and (l_effective_date >= purf.effective_start_date
        and l_effective_date <= purf.effective_end_date)
        and (l_TxbAmt >= purf.row_low_range_or_name
        and l_TxbAmt <= purf.row_high_range);

    /* Selects to get the actual values */
      select pucif.value
        into l_fixed
        from pay_user_column_instances_f pucif
        where pucif.user_row_id = l_bracket_row
        and (l_effective_date >= pucif.effective_start_date
        and l_effective_date <= pucif.effective_end_date)
        and pucif.user_column_id = l_fixed_column_id;

      select pucif.value
        into l_limit
        from pay_user_column_instances_f pucif
        where pucif.user_row_id = l_bracket_row
        and (l_effective_date >= pucif.effective_start_date
        and l_effective_date <= pucif.effective_end_date)
        and pucif.user_column_id = l_limit_column_id;

      select pucif.value
        into l_percentage
        from pay_user_column_instances_f pucif
        where pucif.user_row_id = l_bracket_row
        and (l_effective_date >= pucif.effective_start_date
        and l_effective_date <= pucif.effective_end_date)
        and pucif.user_column_id = l_percentage_column_id;


      tax_liability := (l_fixed + ((l_TxbAmt - l_limit) * (l_percentage / 100))) -  trc_Rebate;
  END IF;

  RETURN tax_liability ;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'TaxLiability: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END TaxLiability;


FUNCTION DeAnnualise
  (p_Liab IN NUMBER
  ,p_TxOnYtd IN NUMBER
  ,p_TxOnPtd IN NUMBER
  ) RETURN NUMBER
AS
  l_LiabRoy NUMBER(15,2);
  l_LiabFp  NUMBER(15,2);
BEGIN
  l_LiabRoy := (p_liab/trc_PosFactor - (p_TxOnYtd - p_TxOnPtd))
           /dbi_ZA_PAY_PRDS_LFT * trc_PrdFactor;

  l_LiabFp := l_LiabRoy - p_TxOnPtd;
  RETURN l_LiabFp;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'DeAnnualise: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END DeAnnualise;


PROCEDURE TrvAllYtd AS
-- Cursors
--
  -- Global Effective End Dates
  CURSOR c_GlbEffDte
    (p_ty_sd DATE       -- tax year start date
    ,p_ty_ed DATE       -- tax year end date
    )
  IS
  SELECT effective_end_date,
         to_number(global_value) global_value
    FROM ff_globals_f
    WHERE effective_end_date < p_ty_ed
      AND effective_end_date > p_ty_sd
      AND effective_end_date < dbi_ZA_CUR_PRD_END_DTE
      AND global_name = 'ZA_CAR_ALLOW_TAX_PERC';

-- Variables
--
  l_NrfiBalID  pay_balance_types.balance_type_id%TYPE;
  l_RfiBalID   pay_balance_types.balance_type_id%TYPE;
  l_StrtDate   DATE;
  l_EndDate    DATE;
  l_NrfiYtd    NUMBER(15,2) DEFAULT 0;
  l_CurNrfiYtd NUMBER(15,2) DEFAULT 0;
  l_TotNrfiYtd NUMBER(15,2) DEFAULT 0;
  l_CurTxbNrfi NUMBER(15,2) DEFAULT 0;
  l_TotTxbNrfi NUMBER(15,2) DEFAULT 0;
  l_RfiYtd     NUMBER(15,2) DEFAULT 0;
  l_CurRfiYtd  NUMBER(15,2) DEFAULT 0;
  l_TotRfiYtd  NUMBER(15,2) DEFAULT 0;
  l_CurTxbRfi  NUMBER(15,2) DEFAULT 0;
  l_TotTxbRfi  NUMBER(15,2) DEFAULT 0;

BEGIN
-- Retrieve Balance Type ID's
  SELECT balance_type_id
    INTO l_NrfiBalID
    FROM pay_balance_types
    WHERE legislation_code = 'ZA'
      AND balance_name = 'Travel Allowance NRFI';

  SELECT balance_type_id
    INTO l_RfiBalID
    FROM pay_balance_types
    WHERE legislation_code = 'ZA'
      AND balance_name = 'Travel Allowance RFI';
-- Employee Tax Year Start and End Dates
--
  l_StrtDate := GREATEST(dbi_ASG_STRT_DTE, dbi_ZA_TX_YR_STRT);
  l_EndDate := LEAST(dbi_ZA_ACT_END_DTE, dbi_ZA_TX_YR_END);

-- Loop through cursor and for every end date caluclate the balance
  FOR v_Date IN c_GlbEffDte
                (l_StrtDate
                ,l_EndDate
                )
  LOOP
  -- Nrfi Travel Allowance
  --
    -- Nrfi Balance At That Date
    -- 3491357
      /*l_NrfiYtd := py_za_bal.calc_asg_tax_ytd_date
                   (con_ASG_ID
                   ,l_NrfiBalID
                   ,v_Date.effective_end_date
                   );*/
      l_NrfiYtd := py_za_bal.get_balance_value
                   (con_ASG_ID
                   ,l_NrfiBalID
                   ,'_ASG_TAX_YTD'
                   ,v_Date.effective_end_date
                   );
    -- Take Off the Ytd value used already
      l_CurNrfiYtd := l_NrfiYtd - l_TotNrfiYtd;
    -- Update TotYtd value
      l_TotNrfiYtd := l_NrfiYtd;
    -- Get the Taxable Travel Allowance at that date
      l_CurTxbNrfi := l_CurNrfiYtd * v_Date.global_value/100;
    -- Add this to the total
      l_TotTxbNrfi := l_TotTxbNrfi + l_CurTxbNrfi;

  -- Rfi Travel Allowance
  --
    -- Rfi Balance At That Date
    -- 3491357
      /*l_RfiYtd := py_za_bal.calc_asg_tax_ytd_date
                  (con_ASG_ID
                  ,l_RfiBalID
                  ,v_Date.effective_end_date
                  );*/
        l_RfiYtd := py_za_bal.get_balance_value
                  (con_ASG_ID
                  ,l_RfiBalID
                  ,'_ASG_TAX_YTD'
                  ,v_Date.effective_end_date
                  );
     -- Take Off the Ytd value used already
       l_CurRfiYtd := l_RfiYtd - l_TotRfiYtd;
     -- Update TotYtd value
       l_TotRfiYtd := l_RfiYtd;
     -- Get the Taxable Travel Allowance at that date
       l_CurTxbRfi := l_CurRfiYtd * v_Date.global_value/100;
     -- Add this to the total
       l_TotTxbRfi := l_TotTxbRfi + l_CurTxbRfi;

  END LOOP;

-- Calculate the current Taxable Travel Allowance Value
-- add this to any calculated in the loop
--
-- Nrfi Travel Allowance
--
  -- The Balance at present
    l_NrfiYtd := bal_TA_NRFI_YTD;
  -- Take Off the Ytd value used already
    l_CurNrfiYtd := l_NrfiYtd - l_TotNrfiYtd;
  -- Update TotYtd value
    l_TotNrfiYtd := l_NrfiYtd;
  -- Get the Taxable Travel Allowance at that date
    l_CurTxbNrfi := l_CurNrfiYtd * glb_ZA_TRV_ALL_TX_PRC/100;
  -- Add this to the total
    l_TotTxbNrfi := l_TotTxbNrfi + l_CurTxbNrfi;

-- Rfi Travel Allowance
--
  -- Rfi Balance At
    l_RfiYtd := bal_TA_RFI_YTD;
  -- Take Off the Ytd value used already
    l_CurRfiYtd := l_RfiYtd - l_TotRfiYtd;
  -- Update TotYtd value
    l_TotRfiYtd := l_RfiYtd;
  -- Get the Taxable Travel Allowance at that date
    l_CurTxbRfi := l_CurRfiYtd * glb_ZA_TRV_ALL_TX_PRC/100;
  -- Add this to the total
    l_TotTxbRfi := l_TotTxbRfi + l_CurTxbRfi;

-- Update Globals
  bal_TA_NRFI_YTD := l_TotTxbNrfi;
  bal_TA_RFI_YTD := l_TotTxbRfi;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'TrvAllYtd: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END TrvAllYtd;

PROCEDURE TrvAllCal AS
-- Cursors
--
  -- Global Effective End Dates
  CURSOR c_GlbEffDte
    (p_StrtDte DATE -- max(assignment start date ,Calendar year start)
    ,p_EndDte DATE -- tax year start date
    )
  IS
  SELECT effective_end_date,
         global_value
    FROM ff_globals_f
    WHERE effective_end_date > p_StrtDte
      AND effective_end_date < p_EndDte
      AND global_name = 'ZA_CAR_ALLOW_TAX_PERC';

-- Variables
--
  l_NrfiBalID  pay_balance_types.balance_type_id%TYPE;
  l_RfiBalID   pay_balance_types.balance_type_id%TYPE;
  l_StrtDate   DATE;
  l_EndDate    DATE;
  l_NrfiYtd    NUMBER(15,2) DEFAULT 0;
  l_CurNrfiYtd NUMBER(15,2) DEFAULT 0;
  l_TotNrfiYtd NUMBER(15,2) DEFAULT 0;
  l_CurTxbNrfi NUMBER(15,2) DEFAULT 0;
  l_TotTxbNrfi NUMBER(15,2) DEFAULT 0;
  l_RfiYtd     NUMBER(15,2) DEFAULT 0;
  l_CurRfiYtd  NUMBER(15,2) DEFAULT 0;
  l_TotRfiYtd  NUMBER(15,2) DEFAULT 0;
  l_CurTxbRfi  NUMBER(15,2) DEFAULT 0;
  l_TotTxbRfi  NUMBER(15,2) DEFAULT 0;
  l_GlbVal     NUMBER(15,2) DEFAULT 0;
BEGIN
-- Retrieve Balance Type ID's
  SELECT balance_type_id
    INTO l_NrfiBalID
    FROM pay_balance_types
    WHERE legislation_code = 'ZA'
      AND balance_name = 'Travel Allowance NRFI';

  SELECT balance_type_id
    INTO l_RfiBalID
    FROM pay_balance_types
    WHERE legislation_code = 'ZA'
      AND balance_name = 'Travel Allowance RFI';

-- Employee Tax Year Start and End Dates
--
  l_StrtDate := to_date('01-01-'||to_char(dbi_ZA_TX_YR_STRT,'YYYY')||''||'','DD-MM-YYYY');
  l_EndDate := dbi_ZA_TX_YR_STRT -1;

-- Loop through cursor and for every end date caluclate the balance
  FOR v_Date IN c_GlbEffDte
                (l_StrtDate
                ,l_EndDate
                )
  LOOP
  -- Nrfi Travel Allowance
  --
    -- Nrfi Balance At That Date
    -- 3491357
      /*l_NrfiYtd := py_za_bal.calc_asg_cal_ytd_date
                   (con_ASG_ID
                   ,l_NrfiBalID
                   ,v_Date.effective_end_date
                   );*/
        l_NrfiYtd := py_za_bal.get_balance_value
                   (con_ASG_ID
                   ,l_NrfiBalID
                   ,'_ASG_CAL_YTD'
                   ,v_Date.effective_end_date
                   );
    -- Take Off the Ytd value used already
      l_CurNrfiYtd := l_NrfiYtd - l_TotNrfiYtd;
    -- Update TotYtd value
      l_TotNrfiYtd := l_NrfiYtd;
    -- Get the Taxable Travel Allowance at that date
      l_CurTxbNrfi := l_CurNrfiYtd * v_Date.global_value/100;
    -- Add this to the total
      l_TotTxbNrfi := l_TotTxbNrfi + l_CurTxbNrfi;

  -- Rfi Travel Allowance
  --
    -- Rfi Balance At That Date
    -- 3491357
      /*l_RfiYtd := py_za_bal.calc_asg_cal_ytd_date
                  (con_ASG_ID
                  ,l_RfiBalID
                  ,v_Date.effective_end_date
                  );*/
        l_RfiYtd := py_za_bal.get_balance_value
                  (con_ASG_ID
                  ,l_RfiBalID
                  ,'_ASG_CAL_YTD'
                  ,v_Date.effective_end_date
                  );
     -- Take Off the Ytd value used already
       l_CurRfiYtd := l_RfiYtd - l_TotRfiYtd;
     -- Update TotYtd value
       l_TotRfiYtd := l_RfiYtd;
     -- Get the Taxable Travel Allowance at that date
       l_CurTxbRfi := l_CurRfiYtd * v_Date.global_value/100;
     -- Add this to the total
       l_TotTxbRfi := l_TotTxbRfi + l_CurTxbRfi;

  END LOOP;

-- Calculate the current Taxable Travel Allowance Value
-- add this to any calculated in the loop
--

-- Retrieve the Global value effective on l_EndDate
--
  SELECT TO_NUMBER(global_value)
    INTO l_GlbVal
    FROM ff_globals_f
   WHERE l_EndDate between effective_start_date and effective_end_date
     AND global_name = 'ZA_CAR_ALLOW_TAX_PERC';
-- Nrfi Travel Allowance
--
  -- The Balance at present
    l_NrfiYtd := bal_TA_NRFI_CYTD;
  -- Take Off the Ytd value used already
    l_CurNrfiYtd := l_NrfiYtd - l_TotNrfiYtd;
  -- Update TotYtd value
    l_TotNrfiYtd := l_NrfiYtd;
  -- Get the Taxable Travel Allowance at that date
    l_CurTxbNrfi := l_CurNrfiYtd * l_GlbVal/100;
  -- Add this to the total
    l_TotTxbNrfi := l_TotTxbNrfi + l_CurTxbNrfi;

-- Rfi Travel Allowance
--
  -- Rfi Balance At
    l_RfiYtd := bal_TA_RFI_CYTD;
  -- Take Off the Ytd value used already
    l_CurRfiYtd := l_RfiYtd - l_TotRfiYtd;
  -- Update TotYtd value
    l_TotRfiYtd := l_RfiYtd;
  -- Get the Taxable Travel Allowance at that date
    l_CurTxbRfi := l_CurRfiYtd * l_GlbVal/100;
  -- Add this to the total
    l_TotTxbRfi := l_TotTxbRfi + l_CurTxbRfi;

-- Update Out Parameters
  bal_TA_NRFI_CYTD := l_TotTxbNrfi;
  bal_TA_RFI_CYTD := l_TotTxbRfi;


EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'TrvAllCal: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END TrvAllCal;


PROCEDURE NpVal(
  p_Rf IN BOOLEAN DEFAULT FALSE -- Refund Allowed Regardless
  )
AS

-- Type Declaration
--
  TYPE r_Row IS RECORD(
    Ovrrde BOOLEAN
   ,Lib    NUMBER
   );

  TYPE t_Table IS TABLE OF r_Row
    INDEX BY BINARY_INTEGER;
-- Variable Declaration
--
  t_Liabilities t_Table;

  l_TotLib NUMBER(15,2); -- Total Liability
  l_TotNp NUMBER(15,2); -- Total Net Pay
  l_RecVal NUMBER(15,2); -- Recovery Value
  l_NewLib NUMBER(15,2); -- New Liability
  i NUMBER; -- Counter

BEGIN
-- Set up the Table
  t_Liabilities(1).Ovrrde := trc_NpValNIOvr;
  t_Liabilities(1).Lib := trc_LibFpNI;

  t_Liabilities(2).Ovrrde := trc_NpValFBOvr;
  t_Liabilities(2).Lib := trc_LibFpFB;

  t_Liabilities(3).Ovrrde := trc_NpValTAOvr;
  t_Liabilities(3).Lib := trc_LibFpTA;

  t_Liabilities(4).Ovrrde := trc_NpValBPOvr;
  t_Liabilities(4).Lib := trc_LibFpBP;

  t_Liabilities(5).Ovrrde := trc_NpValABOvr;
  t_Liabilities(5).Lib := trc_LibFpAB;

  t_Liabilities(6).Ovrrde := trc_NpValAPOvr;
  t_Liabilities(6).Lib := trc_LibFpAP;

  t_Liabilities(7).Ovrrde := trc_NpValPOOvr;
  t_Liabilities(7).Lib := trc_LibFpPO;


-- Sum the Liabilities
  l_TotLib :=
  (trc_LibFpNI
  +trc_LibFpFB
  +trc_LibFpTA
  +trc_LibFpBP
  +trc_LibFpAB
  +trc_LibFpAP
  +trc_LibFpPO
  );

-- Set Net Pay
  l_TotNp := bal_NET_PAY_RUN;

-- Start Validation
--
  IF l_TotLib = 0 THEN
    NULL;
  ELSIF l_TotLib > 0 THEN

    IF l_TotNp > 0 THEN

      IF l_TotLib = l_TotNp THEN
        NULL;
      ELSIF l_TotLib > l_TotNp THEN
        l_RecVal := l_TotLib - l_TotNp;
        i:= 1;

        FOR i IN 1..7 LOOP

          IF t_Liabilities(i).Lib = 0 THEN
            NULL;
          ELSIF t_Liabilities(i).Lib > 0 THEN
            l_NewLib := t_Liabilities(i).Lib - LEAST(t_Liabilities(i).Lib,l_RecVal);
            l_RecVal := l_RecVal - (t_Liabilities(i).Lib - l_NewLib);
            t_Liabilities(i).Lib := l_NewLib;
            trc_LibWrn := 'Warning: Net Pay Balance not enough for Tax Recovery';
          ELSE -- lib < 0
            NULL;
          END IF;

        END LOOP;

      ELSE -- l_TotLib > 0,l_TotNp > 0,l_TotLib < l_TotNp
       NULL;
      END IF;

    ELSE -- l_TotLib > 0,l_TotNp <= 0
      l_RecVal := l_TotLib;
      i := 1;

      FOR i IN 1..7 LOOP

        IF t_Liabilities(i).Lib = 0 THEN
          NULL;
        ELSIF t_Liabilities(i).Lib > 0 THEN
          l_NewLib := t_Liabilities(i).Lib - LEAST(t_Liabilities(i).Lib,l_RecVal);
          l_RecVal := l_RecVal - (t_Liabilities(i).Lib - l_NewLib);
          t_Liabilities(i).Lib := l_NewLib;
          trc_LibWrn := 'Warning: Net Pay Balance not enough for Tax Recovery';
        ELSE -- lib < 0
          -- Has the liability been Overridden?
          IF t_Liabilities(i).Ovrrde THEN
            NULL;
          -- Is the assignment under SITE
          ELSIF p_Rf THEN
            NULL;
          ELSE
            t_Liabilities(i).Lib := 0;
          END IF;

        END IF;

      END LOOP;

    END IF;

  ELSE -- l_TotLib < 0
    IF p_Rf THEN
      NULL;
    ELSE
      l_RecVal := l_TotLib;
      i := 1;

      FOR i IN 1..7 LOOP

        IF t_Liabilities(i).Lib = 0 THEN
          NULL;
        ELSIF t_Liabilities(i).Lib > 0 THEN
          NULL;
        ELSE -- l_lib < 0
          -- Has the liability been Overridden?
          IF t_Liabilities(i).Ovrrde THEN
            NULL;
          ELSE
            l_NewLib := t_Liabilities(i).Lib - GREATEST(t_Liabilities(i).Lib,l_RecVal);
            l_RecVal := l_RecVal - (t_Liabilities(i).Lib - l_NewLib);
            t_Liabilities(i).Lib := l_NewLib;
          END IF;

        END IF;

      END LOOP;

    END IF;

  END IF;

  trc_LibFpNI := t_Liabilities(1).Lib;
  trc_LibFpFB := t_Liabilities(2).Lib;
  trc_LibFpTA := t_Liabilities(3).Lib;
  trc_LibFpBP := t_Liabilities(4).Lib;
  trc_LibFpAB := t_Liabilities(5).Lib;
  trc_LibFpAP := t_Liabilities(6).Lib;
  trc_LibFpPO := t_Liabilities(7).Lib;

EXCEPTION
  WHEN OTHERS THEN
  IF xpt_Msg = 'No Error' THEN
     xpt_Msg := 'NpVal: '||TO_CHAR(SQLCODE);
  END IF;
     RAISE xpt_E;

END NpVal;


-- DaysWorked
/*  Returns the number of days that the person has worked
    This could be a negative number that would indicate
    a LatePayePeriod
*/
FUNCTION DaysWorked RETURN NUMBER
AS
  l_DaysWorked NUMBER;
  l_EndDte DATE;
  l_StrtDte DATE;

BEGIN
  IF trc_CalTyp = 'YtdCalc' THEN
    l_EndDte := dbi_ZA_CUR_PRD_STRT_DTE;
    l_StrtDte := GREATEST(dbi_ASG_STRT_DTE, dbi_ZA_TX_YR_STRT);
  ELSIF trc_CalTyp = 'CalCalc' THEN
    l_EndDte := dbi_ZA_TX_YR_STRT;
    l_StrtDte := GREATEST(dbi_ASG_STRT_DTE,
     to_date('01-JAN-'||to_char(to_number(to_char(dbi_ZA_TX_YR_END,'YYYY'))-1),'DD/MM/YYYY'));
  ELSIF trc_CalTyp = 'SitCalc' THEN
    l_EndDte := LEAST(dbi_ZA_ACT_END_DTE, dbi_ZA_TX_YR_END);
    l_StrtDte := GREATEST(dbi_ASG_STRT_DTE, dbi_ZA_TX_YR_STRT);
  END IF;

  l_DaysWorked := l_EndDte - l_StrtDte + 1;

  RETURN l_DaysWorked;
  EXCEPTION
    WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'DaysWorked: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END DaysWorked;


PROCEDURE SitPaySplit
AS
  l_TxOnSitLim NUMBER(15,2);
  l_SitAblTx NUMBER(15,2);
BEGIN
-- Check the Tax Status of the Employee
--
  IF dbi_TX_STA in ('C','D','E','F') THEN
    -- Check for SitePeriod
    IF SitePeriod THEN
      trc_PayeVal :=
      (bal_TAX_YTD
      +trc_LibFpNI
      +trc_LibFpFB
      +trc_LibFpTA
      +trc_LibFpBP
      +trc_LibFpAB
      +trc_LibFpAP
      +trc_LibFpPO
      ) - bal_PAYE_YTD;

      trc_SiteVal := -1*bal_SITE_YTD;

    ELSE
      trc_PayeVal := 0 - bal_PAYE_YTD;
      trc_SiteVal := 0 - bal_SITE_YTD;
    END IF;
  ELSIF dbi_TX_STA in ('A','B') THEN
    -- Get the Tax Liability on the Site Limit
    l_TxOnSitLim := TaxLiability(p_Amt => glb_ZA_SIT_LIM)/trc_SitFactor;
    -- Get the Tax Amount Liable for SITE
    l_SitAblTx :=
    (bal_TX_ON_NI_YTD
    +bal_TX_ON_FB_YTD
    +bal_TX_ON_BP_YTD
    +bal_TX_ON_AB_YTD
    +bal_TX_ON_AP_YTD
    +trc_LibFpNI
    +trc_LibFpFB
    +trc_LibFpBP
    +trc_LibFpAB
    +trc_LibFpAP
    );
    -- Check the Limit
    IF l_SitAblTx > l_TxOnSitLim THEN
      trc_SiteVal := l_TxOnSitLim - bal_SITE_YTD;

      trc_PayeVal := (
        (bal_TAX_YTD
        +trc_LibFpNI
        +trc_LibFpFB
        +trc_LibFpBP
        +trc_LibFpAB
        +trc_LibFpAP
        +trc_LibFpTA
        +trc_LibFpPO
        ) - l_TxOnSitLim) - bal_PAYE_YTD;

    ELSE
      IF (bal_TX_ON_TA_YTD
         +trc_LibFpTA
         +bal_TX_ON_PO_YTD
         +trc_LibFpPO
         ) <= 0 THEN
        trc_SiteVal := (bal_TAX_YTD
                       +trc_LibFpNI
                       +trc_LibFpFB
                       +trc_LibFpBP
                       +trc_LibFpAB
                       +trc_LibFpAP
                       +trc_LibFpTA
                       +trc_LibFpPO) - bal_SITE_YTD;

        trc_PayeVal := 0 - bal_PAYE_YTD;
      ELSE
        trc_SiteVal := l_SitAblTx - bal_SITE_YTD;

        trc_PayeVal := (
          (bal_TAX_YTD
          +trc_LibFpNI
          +trc_LibFpFB
          +trc_LibFpBP
          +trc_LibFpAB
          +trc_LibFpAP
          +trc_LibFpTA
          +trc_LibFpPO
          ) - l_SitAblTx) - bal_PAYE_YTD;
      END IF;

    END IF;

  ELSIF dbi_TX_STA = 'G' THEN
     -- Get the SitFactor YTD
     trc_SitFactor := glb_ZA_WRK_DYS_PR_YR / bal_TOT_SEA_WRK_DYS_WRK_YTD;
    -- Get the Tax Liability on the Site Limit
    l_TxOnSitLim := TaxLiability(p_Amt => glb_ZA_SIT_LIM)/trc_SitFactor;
    -- Get the Tax Amount Liable for SITE
    l_SitAblTx :=
    (bal_TX_ON_NI_YTD
    +bal_TX_ON_FB_YTD
    +bal_TX_ON_AP_YTD
    +trc_LibFpNI
    +trc_LibFpFB
    +trc_LibFpAP
    );
    -- Check the Limit
    IF l_SitAblTx > l_TxOnSitLim THEN
      trc_SiteVal := l_TxOnSitLim - bal_SITE_YTD;
      trc_PayeVal := ((bal_TX_ON_PO_YTD+trc_LibFpPO) +(l_SitAblTx - l_TxOnSitLim)) - bal_PAYE_YTD;
    ELSE
      trc_SiteVal := l_SitAblTx - bal_SITE_YTD;
      trc_PayeVal := bal_TX_ON_PO_YTD + trc_LibFpPO  - bal_PAYE_YTD;
    END IF;

  ELSE -- set the globals to zero
    trc_PayeVal := 0 - bal_PAYE_YTD;
    trc_SiteVal := 0 - bal_SITE_YTD;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'SitPaySplit: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END SitPaySplit;


-- Trace Function
--
PROCEDURE Trace AS

BEGIN

/*DELETE FROM pay_za_tax_traces pztt
   WHERE pztt.prl_act_id not in (
   SELECT payroll_action_id
     from pay_payroll_actions)
*/
INSERT INTO pay_za_tax_traces(
 ASG_ACT_ID
,ASG_ID
,PRL_ACT_ID
,PRL_ID
,TX_STA
,PER_AGE
,CalTyp
,TX_DIR_VAL
,It3Ind
,TxPercVal
,ASG_STRT_DTE
,ZA_ACT_END_DTE
,ZA_CUR_PRD_STRT_DTE
,ZA_CUR_PRD_END_DTE
,ZA_TX_YR_STRT
,ZA_TX_YR_END
,SES_DTE
,PrdFactor
,PosFactor
,SitFactor
,ZA_PAY_PRDS_LFT
,ZA_PAY_PRDS_PER_YR
,ZA_DYS_IN_YR
,SEA_WRK_DYS_WRK
,ARR_PF_FRQ
,ARR_RA_FRQ
,BP_TX_RCV
,RA_FRQ
,TxbIncPtd
,BseErn
,TxbBseInc
,TotLibBse
,TxbIncYtd
,PerTxbInc
,PerPenFnd
,PerRfiCon
,PerRfiTxb
,PerPenFndMax
,PerPenFndAbm
,AnnTxbInc
,AnnPenFnd
,AnnRfiCon
,AnnRfiTxb
,AnnPenFndMax
,AnnPenFndAbm
,ArrPenFnd
,ArrPenFndAbm
,RetAnu
,NrfiCon
,RetAnuMax
,RetAnuAbm
,ArrRetAnu
,ArrRetAnuAbm
,Rebate
,Threshold
,MedAidAbm
,PerTotAbm
,AnnTotAbm
,NorIncYtd
,NorIncPtd
,NorErn
,TxbNorInc
,LibFyNI
,TX_ON_NI_YTD
,TX_ON_NI_PTD
,LibFpNI
,FrnBenYtd
,FrnBenPtd
,FrnBenErn
,TxbFrnInc
,LibFyFB
,TX_ON_FB_YTD
,TX_ON_FB_PTD
,LibFpFB
,TrvAllYtd
,TrvAllPtd
,TrvAllErn
,TxbTrvInc
,LibFyTA
,TX_ON_TA_YTD
,TX_ON_TA_PTD
,LibFpTA
,BonProYtd
,BonProPtd
,BonProErn
,TxbBonProInc
,LibFyBP
,TX_ON_BP_YTD
,TX_ON_BP_PTD
,LibFpBP
,AnnBonYtd
,AnnBonErn
,TxbAnnBonInc
,LibFyAB
,TX_ON_AB_YTD
,TX_ON_AB_PTD
,LibFpAB
,AnnPymYtd
,AnnPymPtd
,AnnPymErn
,TxbAnnPymInc
,LibFyAP
,TX_ON_AP_YTD
,TX_ON_AP_PTD
,LibFpAP
,PblOffYtd
,PblOffPtd
,PblOffErn
,LibFyPO
,TX_ON_PO_YTD
,TX_ON_PO_PTD
,LibFpPO
,MsgTxStatus
,LibWrn
,PayValue
,PayeVal
,SiteVal
)
VALUES(
 con_ASG_ACT_ID
,con_ASG_ID
,con_PRL_ACT_ID
,con_PRL_ID
,dbi_TX_STA
,dbi_PER_AGE
,trc_CalTyp
,dbi_TX_DIR_VAL
,trc_It3Ind
,trc_TxPercVal
,dbi_ASG_STRT_DTE
,dbi_ZA_ACT_END_DTE
,dbi_ZA_CUR_PRD_STRT_DTE
,dbi_ZA_CUR_PRD_END_DTE
,dbi_ZA_TX_YR_STRT
,dbi_ZA_TX_YR_END
,dbi_SES_DTE
,trc_PrdFactor
,trc_PosFactor
,trc_SitFactor
,dbi_ZA_PAY_PRDS_LFT
,dbi_ZA_PAY_PRDS_PER_YR
,dbi_ZA_DYS_IN_YR
,dbi_SEA_WRK_DYS_WRK
,dbi_ARR_PF_FRQ
,dbi_ARR_RA_FRQ
,dbi_BP_TX_RCV
,dbi_RA_FRQ
,trc_TxbIncPtd
,trc_BseErn
,trc_TxbBseInc
,trc_TotLibBse
,trc_TxbIncYtd
,trc_PerTxbInc
,trc_PerPenFnd
,trc_PerRfiCon
,trc_PerRfiTxb
,trc_PerPenFndMax
,trc_PerPenFndAbm
,trc_AnnTxbInc
,trc_AnnPenFnd
,trc_AnnRfiCon
,trc_AnnRfiTxb
,trc_AnnPenFndMax
,trc_AnnPenFndAbm
,trc_ArrPenFnd
,trc_ArrPenFndAbm
,trc_RetAnu
,trc_NrfiCon
,trc_RetAnuMax
,trc_RetAnuAbm
,trc_ArrRetAnu
,trc_ArrRetAnuAbm
,trc_Rebate
,trc_Threshold
,trc_MedAidAbm
,trc_PerTotAbm
,trc_AnnTotAbm
,trc_NorIncYtd
,trc_NorIncPtd
,trc_NorErn
,trc_TxbNorInc
,trc_LibFyNI
,bal_TX_ON_NI_YTD
,bal_TX_ON_NI_PTD
,trc_LibFpNI
,trc_FrnBenYtd
,trc_FrnBenPtd
,trc_FrnBenErn
,trc_TxbFrnInc
,trc_LibFyFB
,bal_TX_ON_FB_YTD
,bal_TX_ON_FB_PTD
,trc_LibFpFB
,trc_TrvAllYtd
,trc_TrvAllPtd
,trc_TrvAllErn
,trc_TxbTrvInc
,trc_LibFyTA
,bal_TX_ON_TA_YTD
,bal_TX_ON_TA_PTD
,trc_LibFpTA
,trc_BonProYtd
,trc_BonProPtd
,trc_BonProErn
,trc_TxbBonProInc
,trc_LibFyBP
,bal_TX_ON_BP_YTD
,bal_TX_ON_BP_PTD
,trc_LibFpBP
,trc_AnnBonYtd
,trc_AnnBonErn
,trc_TxbAnnBonInc
,trc_LibFyAB
,bal_TX_ON_AB_YTD
,bal_TX_ON_AB_PTD
,trc_LibFpAB
,trc_AnnPymYtd
,trc_AnnPymPtd
,trc_AnnPymErn
,trc_TxbAnnPymInc
,trc_LibFyAP
,bal_TX_ON_AP_YTD
,bal_TX_ON_AP_PTD
,trc_LibFpAP
,trc_PblOffYtd
,trc_PblOffPtd
,trc_PblOffErn
,trc_LibFyPO
,bal_TX_ON_PO_YTD
,bal_TX_ON_PO_PTD
,trc_LibFpPO
,trc_MsgTxStatus
,trc_LibWrn
,trc_PayValue
,trc_PayeVal
,trc_SiteVal);

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'Trace: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END Trace;

PROCEDURE ClearGlobals AS

BEGIN
  -- Calculation Type
  trc_CalTyp := 'Unknown';
  -- Factors
  trc_TxbIncPtd := 0;
  trc_PrdFactor := 0;
  trc_PosFactor := 0;
  trc_SitFactor := 0;
  -- Base Income
  trc_BseErn := 0;
  trc_TxbBseInc := 0;
  trc_TotLibBse := 0;
  -- Period Pension Fund
  trc_TxbIncYtd := 0;
  trc_PerTxbInc := 0;
  trc_PerPenFnd := 0;
  trc_PerRfiCon := 0;
  trc_PerRfiTxb := 0;
  trc_PerPenFndMax := 0;
  trc_PerPenFndAbm := 0;
  -- Annual Pension Fund
  trc_AnnTxbInc := 0;
  trc_AnnPenFnd := 0;
  trc_AnnRfiCon := 0;
  trc_AnnRfiTxb := 0;
  trc_AnnPenFndMax := 0;
  trc_AnnPenFndAbm := 0;
  -- Arrear Pension
  trc_ArrPenFnd := 0;
  trc_ArrPenFndAbm := 0;
  trc_PfUpdFig := 0;
  -- Retirement Annuity
  trc_RetAnu := 0;
  trc_NrfiCon := 0;
  trc_RetAnuMax := 0;
  trc_RetAnuAbm := 0;
  -- Arrear Retirement Annuity
  trc_ArrRetAnu := 0;
  trc_ArrRetAnuAbm := 0;
  trc_RaUpdFig := 0;
  -- Rebates Thresholds and Med Aid
  trc_Rebate := 0;
  trc_Threshold := 0;
  trc_MedAidAbm := 0;
  -- Abatement Totals
  trc_PerTotAbm := 0;
  trc_AnnTotAbm := 0;
  -- Normal Income
  trc_NorIncYtd := 0;
  trc_NorIncPtd := 0;
  trc_NorErn := 0;
  trc_TxbNorInc := 0;
  trc_LibFyNI := 0;
  trc_LibFpNI := 0;
  -- Fringe Benefits
  trc_FrnBenYtd := 0;
  trc_FrnBenPtd := 0;
  trc_FrnBenErn := 0;
  trc_TxbFrnInc := 0;
  trc_LibFyFB := 0;
  trc_LibFpFB := 0;
  -- Travel Allowance
  trc_TrvAllYtd := 0;
  trc_TrvAllPtd := 0;
  trc_TrvAllErn := 0;
  trc_TxbTrvInc := 0;
  trc_LibFyTA := 0;
  trc_LibFpTA := 0;
  -- Bonus Provision
  trc_BonProYtd := 0;
  trc_BonProPtd := 0;
  trc_BonProErn := 0;
  trc_TxbBonProInc := 0;
  trc_LibFyBP := 0;
  trc_LibFpBP := 0;
  -- Annual Bonus
  trc_AnnBonYtd := 0;
  trc_AnnBonPtd := 0;
  trc_AnnBonErn := 0;
  trc_TxbAnnBonInc := 0;
  trc_LibFyAB := 0;
  trc_LibFpAB := 0;
  -- Annual Payments
  trc_AnnPymYtd := 0;
  trc_AnnPymPtd := 0;
  trc_AnnPymErn := 0;
  trc_TxbAnnPymInc := 0;
  trc_LibFyAP := 0;
  trc_LibFpAP := 0;
  -- Pubilc Office Allowance
  trc_PblOffYtd := 0;
  trc_PblOffPtd := 0;
  trc_PblOffErn := 0;
  trc_LibFyPO := 0;
  trc_LibFpPO := 0;
  -- Messages
  trc_MsgTxStatus := ' ';
  trc_LibWrn := ' ';
  -- Pay Value of This Calculation
  trc_PayValue := 0;
  -- PAYE and SITE Values
  trc_PayeVal := 0;
  trc_SiteVal := 0;
  -- IT3A Threshold Indicator
  trc_It3Ind := 0;
  -- Tax Percentage Value On trace
  trc_TxPercVal := 0;

  -- Total Taxable Income Update Figure
  trc_OUpdFig := 0;

  -- NpVal Override Globals
  trc_NpValNIOvr := FALSE;
  trc_NpValFBOvr := FALSE;
  trc_NpValTAOvr := FALSE;
  trc_NpValBPOvr := FALSE;
  trc_NpValABOvr := FALSE;
  trc_NpValAPOvr := FALSE;
  trc_NpValPOOvr := FALSE;



EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'ClearGlobals: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END ClearGlobals;

-- Main Tax Calculations
--
--
--
--
--
--


PROCEDURE SeaCalc AS
-- Variables
--
  l_TotLibNI NUMBER(15,2) DEFAULT 0;
  l_TotLibFB NUMBER(15,2) DEFAULT 0;
  l_TotLibAB NUMBER(15,2) DEFAULT 0;
  l_TotLibAP NUMBER(15,2) DEFAULT 0;
  l_Np       NUMBER(15,2) DEFAULT 0;
  l_65Year   DATE;

BEGIN
-- Identify the calculation
--
  trc_CalTyp := 'SeaCalc';

-- Update Global Balance Values with correct TAXABLE values
--
  bal_PO_RFI_RUN :=
    bal_PO_RFI_RUN * glb_ZA_PBL_TX_PRC / 100;

  bal_PO_NRFI_RUN :=
    bal_PO_NRFI_RUN * glb_ZA_PBL_TX_PRC / 100;

-- Period Type Income
--
  trc_TxbIncPtd :=
  (bal_AST_PRCHD_RVAL_NRFI_RUN
  +bal_AST_PRCHD_RVAL_RFI_RUN
  +bal_BUR_AND_SCH_NRFI_RUN
  +bal_BUR_AND_SCH_RFI_RUN
  +bal_COMM_NRFI_RUN
  +bal_COMM_RFI_RUN
  +bal_COMP_ALL_NRFI_RUN
  +bal_COMP_ALL_RFI_RUN
  +bal_ENT_ALL_NRFI_RUN
  +bal_ENT_ALL_RFI_RUN
  +bal_FREE_ACCOM_NRFI_RUN
  +bal_FREE_ACCOM_RFI_RUN
  +bal_FREE_SERV_NRFI_RUN
  +bal_FREE_SERV_RFI_RUN
  +bal_LOW_LOANS_NRFI_RUN
  +bal_LOW_LOANS_RFI_RUN
  +bal_MLS_AND_VOUCH_NRFI_RUN
  +bal_MLS_AND_VOUCH_RFI_RUN
  +bal_MED_PAID_NRFI_RUN
  +bal_MED_PAID_RFI_RUN
  +bal_OTHER_TXB_ALL_NRFI_RUN
  +bal_OTHER_TXB_ALL_RFI_RUN
  +bal_OVTM_NRFI_RUN
  +bal_OVTM_RFI_RUN
  +bal_PYM_DBT_NRFI_RUN
  +bal_PYM_DBT_RFI_RUN
  +bal_RGT_AST_NRFI_RUN
  +bal_RGT_AST_RFI_RUN
  +bal_TXB_INC_NRFI_RUN
  +bal_TXB_INC_RFI_RUN
  +bal_TXB_PEN_NRFI_RUN
  +bal_TXB_PEN_RFI_RUN
  +bal_TEL_ALL_NRFI_RUN
  +bal_TEL_ALL_RFI_RUN
  +bal_TOOL_ALL_NRFI_RUN
  +bal_TOOL_ALL_RFI_RUN
  +bal_USE_VEH_NRFI_RUN
  +bal_USE_VEH_RFI_RUN
  );

-- Check if any Period Income Exists
--
  IF trc_TxbIncPtd = 0 THEN -- Pre-Earnings Calc
  -- Site Factor
  --
    trc_SitFactor := glb_ZA_WRK_DYS_PR_YR / dbi_SEA_WRK_DYS_WRK;

  -- Tax Rebates, Threshold Figure and Medical Aid
  --   Abatements
    -- Calculate the assignments 65 Year Date
    l_65Year := add_months(dbi_PER_DTE_OF_BRTH,780);

    IF l_65Year BETWEEN dbi_ZA_TX_YR_STRT AND dbi_ZA_TX_YR_END THEN
      -- give the extra abatement
      trc_Rebate := glb_ZA_PRI_TX_RBT + glb_ZA_ADL_TX_RBT;
      trc_Threshold := glb_ZA_SC_TX_THRSHLD;

    ELSE
      -- not eligable for extra abatement
      trc_Rebate := glb_ZA_PRI_TX_RBT;
      trc_Threshold := glb_ZA_PRI_TX_THRSHLD;

  END IF;

  -- Base Income
  --
    -- Base Income
    trc_BseErn :=
    (bal_ANU_FRM_RET_FND_NRFI_RUN
    +bal_ANU_FRM_RET_FND_RFI_RUN
    +bal_PRCH_ANU_TXB_NRFI_RUN
    +bal_PRCH_ANU_TXB_RFI_RUN
    +bal_SHR_OPT_EXD_NRFI_RUN
    +bal_SHR_OPT_EXD_RFI_RUN
    +bal_TXB_AP_NRFI_RUN
    +bal_TXB_AP_RFI_RUN
    +bal_TXB_SUBS_NRFI_RUN
    +bal_TXB_SUBS_RFI_RUN
    );
    -- Taxable Base Income
    trc_TxbBseInc := trc_BseErn * trc_SitFactor;
    -- Threshold Check
    IF trc_TxbBseInc >= trc_Threshold THEN
      -- Tax Liability
      trc_TotLibBse := TaxLiability(p_Amt => trc_TxbBseInc);
    ELSE
      trc_TotLibBse := 0;
    END IF;

  -- Annual Payments
  --
    -- Taxable Annual Payments Income
    trc_TxbAnnPymInc := trc_BseErn + trc_TxbBseInc;-- AP was taken as base!
    -- Threshold Check
    IF trc_TxbAnnPymInc >= trc_Threshold THEN
      -- Tax Liability
      l_TotLibAP := TaxLiability(p_Amt => trc_TxbAnnPymInc);
      trc_LibFpAP := l_TotLibAP - trc_TotLibBse;
    ElSE
      trc_LibFpAP := 0;
    END IF;

  ELSE
  -- Site Factor
  --
    trc_SitFactor := glb_ZA_WRK_DYS_PR_YR / dbi_SEA_WRK_DYS_WRK;

  -- Abatements
    Abatements;

  -- Normal Income
  --
    -- Run Normal Income
    trc_NorIncPtd :=
    (bal_COMM_NRFI_RUN
    +bal_COMM_RFI_RUN
    +bal_COMP_ALL_NRFI_RUN
    +bal_COMP_ALL_RFI_RUN
    +bal_ENT_ALL_NRFI_RUN
    +bal_ENT_ALL_RFI_RUN
    +bal_OTHER_TXB_ALL_NRFI_RUN
    +bal_OTHER_TXB_ALL_RFI_RUN
    +bal_OVTM_NRFI_RUN
    +bal_OVTM_RFI_RUN
    +bal_TXB_INC_NRFI_RUN
    +bal_TXB_INC_RFI_RUN
    +bal_TXB_PEN_NRFI_RUN
    +bal_TXB_PEN_RFI_RUN
    +bal_TEL_ALL_NRFI_RUN
    +bal_TEL_ALL_RFI_RUN
    +bal_TOOL_ALL_NRFI_RUN
    +bal_TOOL_ALL_RFI_RUN
    );
    -- Skip the calculation if there is No Income
    IF trc_NorIncPtd <> 0 THEN
      -- Normal Earnings
      trc_NorErn := trc_NorIncPtd * trc_SitFactor;
      -- Taxable Normal Income
      trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbNorInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibNI := TaxLiability(p_Amt => trc_TxbNorInc) - 0;
        trc_LibFpNI := l_TotLibNI / trc_SitFactor;
      ELSE
        l_TotLibNI := 0;
      END IF;
    ELSE
      trc_NorErn := 0;
      trc_TxbNorInc := 0;
      l_TotLibNI := 0;
    END IF;

  -- Fringe Benefits
  --
    -- Run Fringe Benefits
    trc_FrnBenPtd :=
    (bal_AST_PRCHD_RVAL_NRFI_RUN
    +bal_AST_PRCHD_RVAL_RFI_RUN
    +bal_BUR_AND_SCH_NRFI_RUN
    +bal_BUR_AND_SCH_RFI_RUN
    +bal_FREE_ACCOM_NRFI_RUN
    +bal_FREE_ACCOM_RFI_RUN
    +bal_FREE_SERV_NRFI_RUN
    +bal_FREE_SERV_RFI_RUN
    +bal_LOW_LOANS_NRFI_RUN
    +bal_LOW_LOANS_RFI_RUN
    +bal_MLS_AND_VOUCH_NRFI_RUN
    +bal_MLS_AND_VOUCH_RFI_RUN
    +bal_MED_PAID_NRFI_RUN
    +bal_MED_PAID_RFI_RUN
    +bal_PYM_DBT_NRFI_RUN
    +bal_PYM_DBT_RFI_RUN
    +bal_RGT_AST_NRFI_RUN
    +bal_RGT_AST_RFI_RUN
    +bal_USE_VEH_NRFI_RUN
    +bal_USE_VEH_RFI_RUN
    );

    -- Skip the calculation if there is No Income
    IF trc_FrnBenPtd <> 0 THEN
      -- Fringe Benefit Earnings
      trc_FrnBenErn := trc_FrnBenPtd * trc_SitFactor + trc_NorErn;
      -- Taxable Fringe Income
      trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbFrnInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibFB := TaxLiability(p_Amt => trc_TxbFrnInc) - l_TotLibNI;
        trc_LibFpFB := l_TotLibFB / trc_SitFactor;
      ElSE
        l_TotLibFB := l_TotLibNI;
      END IF;
    ELSE
      trc_FrnBenErn := trc_NorErn;
      trc_TxbFrnInc := trc_TxbNorInc;
      l_TotLibFB := l_TotLibNI;
    END IF;

  -- Annual Payments
  --
    -- Run Annual Payments
    trc_AnnPymPtd :=
    (bal_ANU_FRM_RET_FND_NRFI_RUN
    +bal_ANU_FRM_RET_FND_RFI_RUN
    +bal_PRCH_ANU_TXB_NRFI_RUN
    +bal_PRCH_ANU_TXB_RFI_RUN
    +bal_SHR_OPT_EXD_NRFI_RUN
    +bal_SHR_OPT_EXD_RFI_RUN
    +bal_TXB_AP_NRFI_RUN
    +bal_TXB_AP_RFI_RUN
    +bal_TXB_SUBS_NRFI_RUN
    +bal_TXB_SUBS_RFI_RUN
    );
    -- Skip the calculation if there is No Income
    IF trc_AnnPymPtd <> 0 THEN
      -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymPtd + trc_FrnBenErn;
      -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibAP := TaxLiability(p_Amt => trc_TxbAnnPymInc) - l_TotLibFB;
        trc_LibFpAP := l_TotLibAP / trc_SitFactor;
      ELSE
        l_TotLibAP := l_TotLibFB;
      END IF;
    ELSE
      trc_AnnPymErn := trc_FrnBenErn;
      trc_TxbAnnPymInc := trc_TxbFrnInc;
      l_TotLibAP := l_TotLibFB;
    END IF;

  -- Public Office Allowance
  --
    -- Run Public Office Allowance
    trc_PblOffPtd :=
    (bal_PO_NRFI_RUN
    +bal_PO_RFI_RUN
    );
    -- Skip the calculation if there is No Income
    IF trc_PblOffPtd <> 0 THEN
      -- Public Office Earnings
      trc_PblOffErn := trc_PblOffPtd * trc_SitFactor;
      -- Tax Liability
      trc_LibFpPO := (trc_PblOffErn * glb_ZA_PBL_TX_RTE / 100)/trc_SitFactor;
    ELSE
      trc_LibFpPO := 0;
    END IF;

  -- Net Pay Validation
  --
    NpVal;

  -- Execute the SitPaySplit Procedure
  --
    SitPaySplit;

  -- Set IT3A Indicator
  --
    IF trc_TxbAnnPymInc + trc_PblOffErn >= trc_Threshold THEN
      trc_It3Ind := 0; -- Over Lim
    ELSE
      trc_It3Ind := 1; -- Under Lim
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'SeaCalc: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END SeaCalc;


PROCEDURE SitCalc AS
-- Variables
--
  l_TotLibNI NUMBER(15,2) DEFAULT 0;
  l_TotLibFB NUMBER(15,2) DEFAULT 0;
  l_TotLibTA NUMBER(15,2) DEFAULT 0;
  l_TotLibBP NUMBER(15,2) DEFAULT 0;
  l_TotLibAB NUMBER(15,2) DEFAULT 0;
  l_TotLibAP NUMBER(15,2) DEFAULT 0;
  l_Sl       BOOLEAN;
  l_Np       NUMBER(15,2);

BEGIN
-- Identify the calculation
--
  trc_CalTyp := 'SitCalc';

-- Update Global Balance Values with correct TAXABLE values
--
  TrvAllYtd;

  bal_PO_RFI_YTD :=
    bal_PO_RFI_YTD * glb_ZA_PBL_TX_PRC / 100;

  bal_PO_NRFI_YTD :=
    bal_PO_NRFI_YTD * glb_ZA_PBL_TX_PRC / 100;

-- Ytd Taxable Income
--
  trc_TxbIncYtd :=
  (bal_AST_PRCHD_RVAL_NRFI_YTD
  +bal_AST_PRCHD_RVAL_RFI_YTD
  +bal_BP_YTD
  +bal_BUR_AND_SCH_NRFI_YTD
  +bal_BUR_AND_SCH_RFI_YTD
  +bal_COMM_NRFI_YTD
  +bal_COMM_RFI_YTD
  +bal_COMP_ALL_NRFI_YTD
  +bal_COMP_ALL_RFI_YTD
  +bal_ENT_ALL_NRFI_YTD
  +bal_ENT_ALL_RFI_YTD
  +bal_FREE_ACCOM_NRFI_YTD
  +bal_FREE_ACCOM_RFI_YTD
  +bal_FREE_SERV_NRFI_YTD
  +bal_FREE_SERV_RFI_YTD
  +bal_LOW_LOANS_NRFI_YTD
  +bal_LOW_LOANS_RFI_YTD
  +bal_MLS_AND_VOUCH_NRFI_YTD
  +bal_MLS_AND_VOUCH_RFI_YTD
  +bal_MED_PAID_NRFI_YTD
  +bal_MED_PAID_RFI_YTD
  +bal_OTHER_TXB_ALL_NRFI_YTD
  +bal_OTHER_TXB_ALL_RFI_YTD
  +bal_OVTM_NRFI_YTD
  +bal_OVTM_RFI_YTD
  +bal_PYM_DBT_NRFI_YTD
  +bal_PYM_DBT_RFI_YTD
  +bal_RGT_AST_NRFI_YTD
  +bal_RGT_AST_RFI_YTD
  +bal_TXB_INC_NRFI_YTD
  +bal_TXB_INC_RFI_YTD
  +bal_TXB_PEN_NRFI_YTD
  +bal_TXB_PEN_RFI_YTD
  +bal_TEL_ALL_NRFI_YTD
  +bal_TEL_ALL_RFI_YTD
  +bal_TOOL_ALL_NRFI_YTD
  +bal_TOOL_ALL_RFI_YTD
  +bal_TA_NRFI_YTD
  +bal_TA_RFI_YTD
  +bal_USE_VEH_NRFI_YTD
  +bal_USE_VEH_RFI_YTD
  );

  -- Site Factor
  --
    trc_SitFactor := dbi_ZA_DYS_IN_YR / DaysWorked;

  -- Abatements
    Abatements;

  -- Normal Income
  --
    -- Ytd Normal Income
    trc_NorIncYtd :=
    (bal_COMM_NRFI_YTD
    +bal_COMM_RFI_YTD
    +bal_COMP_ALL_NRFI_YTD
    +bal_COMP_ALL_RFI_YTD
    +bal_ENT_ALL_NRFI_YTD
    +bal_ENT_ALL_RFI_YTD
    +bal_OTHER_TXB_ALL_NRFI_YTD
    +bal_OTHER_TXB_ALL_RFI_YTD
    +bal_OVTM_NRFI_YTD
    +bal_OVTM_RFI_YTD
    +bal_TXB_INC_NRFI_YTD
    +bal_TXB_INC_RFI_YTD
    +bal_TXB_PEN_NRFI_YTD
    +bal_TXB_PEN_RFI_YTD
    +bal_TEL_ALL_NRFI_YTD
    +bal_TEL_ALL_RFI_YTD
    +bal_TOOL_ALL_NRFI_YTD
    +bal_TOOL_ALL_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_NorIncYtd <> 0 THEN
      -- Normal Earnings
      trc_NorErn := trc_NorIncYtd * trc_SitFactor;
      -- Taxable Normal Income
      trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbNorInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibNI := TaxLiability(p_Amt => trc_TxbNorInc);
        trc_LibFyNI := (l_TotLibNI - 0) / trc_SitFactor;
        trc_LibFpNI := trc_LibFyNI - bal_TX_ON_NI_YTD;
      ELSE
        l_TotLibNI := 0;
        -- Refund any tax paid
        trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
        trc_NpValNIOvr := TRUE;
      END IF;
    ELSE
      trc_NorErn := 0;
      trc_TxbNorInc := 0;
      l_TotLibNI := 0;
      -- Refund any tax paid
      trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
      trc_NpValNIOvr := TRUE;
    END IF;

  -- Fringe Benefits
  --
    -- Ytd Fringe Benefits
    trc_FrnBenYtd :=
    (bal_AST_PRCHD_RVAL_NRFI_YTD
    +bal_AST_PRCHD_RVAL_RFI_YTD
    +bal_BUR_AND_SCH_NRFI_YTD
    +bal_BUR_AND_SCH_RFI_YTD
    +bal_FREE_ACCOM_NRFI_YTD
    +bal_FREE_ACCOM_RFI_YTD
    +bal_FREE_SERV_NRFI_YTD
    +bal_FREE_SERV_RFI_YTD
    +bal_LOW_LOANS_NRFI_YTD
    +bal_LOW_LOANS_RFI_YTD
    +bal_MLS_AND_VOUCH_NRFI_YTD
    +bal_MLS_AND_VOUCH_RFI_YTD
    +bal_MED_PAID_NRFI_YTD
    +bal_MED_PAID_RFI_YTD
    +bal_PYM_DBT_NRFI_YTD
    +bal_PYM_DBT_RFI_YTD
    +bal_RGT_AST_NRFI_YTD
    +bal_RGT_AST_RFI_YTD
    +bal_USE_VEH_NRFI_YTD
    +bal_USE_VEH_RFI_YTD
    );

    -- Skip the calculation if there is No Income
    IF trc_FrnBenYtd <> 0 THEN
      -- Fringe Benefit Earnings
      trc_FrnBenErn := trc_FrnBenYtd * trc_SitFactor + trc_NorErn;
      -- Taxable Fringe Income
      trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbFrnInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibFB := TaxLiability(p_Amt => trc_TxbFrnInc);
        trc_LibFyFB := (l_TotLibFB - l_TotLibNI) / trc_SitFactor;
        trc_LibFpFB := trc_LibFyFB - bal_TX_ON_FB_YTD;
      ElSE
        l_TotLibFB := l_TotLibNI;
        -- Refund any tax paid
        trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
        trc_NpValFBOvr := TRUE;
      END IF;
    ELSE
      trc_FrnBenErn := trc_NorErn;
      trc_TxbFrnInc := trc_TxbNorInc;
      l_TotLibFB := l_TotLibNI;
      -- Refund any tax paid
      trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
      trc_NpValFBOvr := TRUE;
    END IF;

  -- Travel allowance
  --
    -- Ytd Travel Allowance
    trc_TrvAllYtd :=
    (bal_TA_NRFI_YTD
    +bal_TA_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_TrvAllYtd <> 0 THEN
      -- Travel Earnings
      trc_TrvAllErn := trc_TrvAllYtd * trc_SitFactor + trc_FrnBenErn;
      -- Taxable Travel Income
      trc_TxbTrvInc := trc_TrvAllErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbTrvInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibTA := TaxLiability(p_Amt => trc_TxbTrvInc);
        trc_LibFyTA := (l_TotLibTA - l_TotLibFB) / trc_SitFactor;
        trc_LibFpTA := trc_LibFyTA - bal_TX_ON_TA_YTD;
      ELSE
        l_TotLibTA := l_TotLibFB;
        -- Refund any tax paid
        trc_LibFpTA := -1 * bal_TX_ON_TA_YTD;
        trc_NpValTAOvr := TRUE;
      END IF;
    ELSE
      trc_TrvAllErn := trc_FrnBenErn;
      trc_TxbTrvInc := trc_TxbFrnInc;
      l_TotLibTA := l_TotLibFB;
      -- Refund any tax paid
      trc_LibFpTA := -1 * bal_TX_ON_TA_YTD;
      trc_NpValTAOvr := TRUE;
    END IF;

  -- Bonus Provision
  --
    -- Ytd Bonus Prvision
    trc_BonProYtd := bal_BP_YTD;
    -- Skip the calculation if there is No Income
    IF trc_BonProYtd <> 0 THEN
      -- Bonus Provision Earnings
      trc_BonProErn := trc_BonProYtd * trc_SitFactor + trc_TrvAllErn;
      -- Taxable Bonus Provision Income
      trc_TxbBonProInc := trc_BonProErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbBonProInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibBP := TaxLiability(p_Amt => trc_TxbBonProInc);
        trc_LibFyBP := (l_TotLibBP - l_TotLibTA) / trc_SitFactor;
        trc_LibFpBP := trc_LibFyBP - bal_TX_ON_BP_YTD;
      ELSE
        l_TotLibBP := l_TotLibTA;
        -- Refund any tax paid
        trc_LibFpBP := -1 * bal_TX_ON_BP_YTD;
        trc_NpValBPOvr := TRUE;
      END IF;
    ELSE
      trc_BonProErn := trc_TrvAllErn;
      trc_TxbBonProInc := trc_TxbTrvInc;
      l_TotLibBP := l_TotLibTA;
      -- Refund any tax paid
      trc_LibFpBP := -1 * bal_TX_ON_BP_YTD;
      trc_NpValBPOvr := TRUE;
    END IF;

  -- Annual Bonus
  --
    -- Ytd Annual Bonus
    trc_AnnBonYtd :=
    (bal_AB_NRFI_YTD
    +bal_AB_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_AnnBonYtd <> 0 THEN
      -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
      -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibAB := TaxLiability(p_Amt => trc_TxbAnnBonInc);
        trc_LibFyAB := l_TotLibAB - l_TotLibTA;
        -- Check Bonus Provision
        IF trc_BonProYtd <> 0 THEN
          trc_LibFpAB := trc_LibFyAB - (bal_TX_ON_BP_YTD
                                   +trc_LibFpBP
                                   +bal_TX_ON_AB_YTD
                                   );
        ELSE
          trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
        END IF;
      ELSE
        l_TotLibAB := l_TotLibTA;
        -- Refund any tax paid
        trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
        trc_NpValABOvr := TRUE;
      END IF;
    ELSE
      trc_AnnBonErn := trc_TrvAllErn;
      trc_TxbAnnBonInc := trc_TxbTrvInc;
      l_TotLibAB := l_TotLibTA;
      -- Refund any tax paid
      trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
      trc_NpValABOvr := TRUE;
    END IF;

  -- Annual Payments
  --
    -- Ytd Annual Payments
    trc_AnnPymYtd :=
    (bal_ANU_FRM_RET_FND_NRFI_YTD
    +bal_ANU_FRM_RET_FND_RFI_YTD
    +bal_PRCH_ANU_TXB_NRFI_YTD
    +bal_PRCH_ANU_TXB_RFI_YTD
    +bal_SHR_OPT_EXD_NRFI_YTD
    +bal_SHR_OPT_EXD_RFI_YTD
    +bal_TXB_AP_NRFI_YTD
    +bal_TXB_AP_RFI_YTD
    +bal_TXB_SUBS_NRFI_YTD
    +bal_TXB_SUBS_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_AnnPymYtd <> 0 THEN
      -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
      -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibAP := TaxLiability(p_Amt => trc_TxbAnnPymInc);
        trc_LibFyAP := l_TotLibAP - l_TotLibAB;
        trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
      ELSE
        l_TotLibAP := l_TotLibAB;
        -- Refund any tax paid
        trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
        trc_NpValAPOvr := TRUE;
      END IF;
    ELSE
      trc_AnnPymErn := trc_AnnBonErn;
      trc_TxbAnnPymInc := trc_TxbAnnBonInc;
      l_TotLibAP := l_TotLibAB;
      -- Refund any tax paid
      trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
      trc_NpValAPOvr := TRUE;
    END IF;

  -- Public Office Allowance
  --
    -- Ytd Public Office Allowance
    trc_PblOffYtd :=
    (bal_PO_NRFI_YTD
    +bal_PO_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_PblOffYtd <> 0 THEN
      -- Public Office Earnings
      trc_PblOffErn := trc_PblOffYtd * trc_SitFactor;
      -- Tax Liability
      trc_LibFyPO := (trc_PblOffErn * glb_ZA_PBL_TX_RTE / 100)/trc_SitFactor;
      trc_LibFpPO := trc_LibFyPO -  bal_TX_ON_PO_YTD;
    ELSE
      trc_LibFyPO := 0;
      -- Refund any tax paid
      trc_LibFpPO := -1 * bal_TX_ON_PO_YTD;
      trc_NpValPOOvr := TRUE;
    END IF;

  -- Net Pay Validation
  --
    -- Net Pay of the Employee
    l_Np := bal_NET_PAY_RUN;
    -- Site Limit Check
    IF trc_TxbAnnPymInc + trc_PblOffErn < glb_ZA_SIT_LIM THEN
      l_Sl := TRUE;
    ELSE
      l_Sl := FALSE;
    END IF;

    NpVal(p_Rf => l_Sl);

  -- Execute the SitPaySplit Procedure
  --
    SitPaySplit;

  -- Set IT3A Indicator
  --
    IF trc_TxbAnnPymInc + trc_PblOffErn >= trc_Threshold THEN
      trc_It3Ind := 0; -- Over Lim
    ELSE
      trc_It3Ind := 1; -- Under Lim
    END IF;

  -- Calculate Total Taxable Income and pass out
  --
    trc_OUpdFig := (trc_TxbAnnPymInc + trc_PblOffErn) - bal_TOT_TXB_INC_ITD;


EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'SitCalc: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END SitCalc;


PROCEDURE DirCalc AS
-- Variables
--
  l_TotLibNI NUMBER(15,2) DEFAULT 0;
  l_TotLibFB NUMBER(15,2) DEFAULT 0;
  l_TotLibTA NUMBER(15,2) DEFAULT 0;
  l_TotLibBP NUMBER(15,2) DEFAULT 0;
  l_TotLibAB NUMBER(15,2) DEFAULT 0;
  l_TotLibAP NUMBER(15,2) DEFAULT 0;
  l_Np       NUMBER(15,2) DEFAULT 0;

BEGIN
-- Identify the calculation
--
  trc_CalTyp := 'DirCalc';

-- Update Global Balance Values with correct TAXABLE values
--
  TrvAllYtd;

  bal_PO_RFI_YTD :=
    bal_PO_RFI_YTD * glb_ZA_PBL_TX_PRC / 100;

  bal_PO_NRFI_YTD :=
    bal_PO_NRFI_YTD * glb_ZA_PBL_TX_PRC / 100;

-- Normal Income
--
  -- Ytd Normal Income
  trc_NorIncYtd :=
  (bal_COMM_NRFI_YTD
  +bal_COMM_RFI_YTD
  +bal_COMP_ALL_NRFI_YTD
  +bal_COMP_ALL_RFI_YTD
  +bal_ENT_ALL_NRFI_YTD
  +bal_ENT_ALL_RFI_YTD
  +bal_OTHER_TXB_ALL_NRFI_YTD
  +bal_OTHER_TXB_ALL_RFI_YTD
  +bal_OVTM_NRFI_YTD
  +bal_OVTM_RFI_YTD
  +bal_TXB_INC_NRFI_YTD
  +bal_TXB_INC_RFI_YTD
  +bal_TXB_PEN_NRFI_YTD
  +bal_TXB_PEN_RFI_YTD
  +bal_TEL_ALL_NRFI_YTD
  +bal_TEL_ALL_RFI_YTD
  +bal_TOOL_ALL_NRFI_YTD
  +bal_TOOL_ALL_RFI_YTD
  );
  -- Skip the calculation if there is No Income
  IF trc_NorIncYtd <> 0 THEN
    -- Normal Earnings
    trc_NorErn := trc_NorIncYtd;
    -- Tax Liability
    l_TotLibNI := TaxLiability(p_Amt => trc_NorErn);
    trc_LibFyNI := l_TotLibNI - 0;
    trc_LibFpNI := trc_LibFyNI - bal_TX_ON_NI_YTD;
  ELSE
    trc_NorErn := 0;
    l_TotLibNI := 0;
    -- Refund any tax paid
    trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
    trc_NpValNIOvr := TRUE;
  END IF;

-- Fringe Benefits
--
  -- Ytd Fringe Benefits
  trc_FrnBenYtd :=
  (bal_AST_PRCHD_RVAL_NRFI_YTD
  +bal_AST_PRCHD_RVAL_RFI_YTD
  +bal_BUR_AND_SCH_NRFI_YTD
  +bal_BUR_AND_SCH_RFI_YTD
  +bal_FREE_ACCOM_NRFI_YTD
  +bal_FREE_ACCOM_RFI_YTD
  +bal_FREE_SERV_NRFI_YTD
  +bal_FREE_SERV_RFI_YTD
  +bal_LOW_LOANS_NRFI_YTD
  +bal_LOW_LOANS_RFI_YTD
  +bal_MLS_AND_VOUCH_NRFI_YTD
  +bal_MLS_AND_VOUCH_RFI_YTD
  +bal_MED_PAID_NRFI_YTD
  +bal_MED_PAID_RFI_YTD
  +bal_PYM_DBT_NRFI_YTD
  +bal_PYM_DBT_RFI_YTD
  +bal_RGT_AST_NRFI_YTD
  +bal_RGT_AST_RFI_YTD
  +bal_USE_VEH_NRFI_YTD
  +bal_USE_VEH_RFI_YTD
  );
  -- Skip the calculation if there is No Income
  IF trc_FrnBenYtd <> 0 THEN
    -- Fringe Benefit Earnings
    trc_FrnBenErn := trc_FrnBenYtd + trc_NorErn;
    -- Tax Liability
    l_TotLibFB := TaxLiability(p_Amt => trc_FrnBenErn);
    trc_LibFyFB := l_TotLibFB - l_TotLibNI;
    trc_LibFpFB := trc_LibFyFB - bal_TX_ON_FB_YTD;
  ELSE
    trc_FrnBenErn := trc_NorErn;
    l_TotLibFB := l_TotLibNI;
    -- Refund any tax paid
    trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
    trc_NpValFBOvr := TRUE;
  END IF;

-- Travel Allowance
--
  -- Ytd Travel Allowance
  trc_TrvAllYtd :=
  (bal_TA_NRFI_YTD
  +bal_TA_RFI_YTD
  );
  -- Skip the calculation if there is No Income
  IF trc_TrvAllYtd <> 0 THEN
    -- Travel Allowance Earnings
    trc_TrvAllErn := trc_TrvAllYtd + trc_FrnBenErn;
    -- Tax Liability
    l_TotLibTA := TaxLiability(p_Amt => trc_TrvAllErn);
    trc_LibFyTA := l_TotLibTA - l_TotLibFB;
    trc_LibFpTA := trc_LibFyTA - bal_TX_ON_TA_YTD;
  ELSE
    trc_TrvAllErn := trc_FrnBenErn; --Cascade Figure
    l_TotLibTA := l_TotLibFB;
    -- Refund any tax paid
    trc_LibFpTA := -1 * bal_TX_ON_TA_YTD;
    trc_NpValTAOvr := TRUE;
  END IF;

-- Bonus Provision
--
  -- Ytd Bonus Provision
  trc_BonProYtd := bal_BP_YTD;
  -- Skip the calculation if there is No Income
  IF trc_BonProYtd <> 0 THEN
    -- Bonus Provision Earnings
    trc_BonProErn := trc_BonProYtd + trc_TrvAllErn;
    -- Tax Liability
    l_TotLibBP := TaxLiability(p_Amt => trc_BonProErn);
    trc_LibFyBP := l_TotLibBP - l_TotLibTA;
    trc_LibFpBP := trc_LibFyBP - bal_TX_ON_BP_YTD;
  ELSE
    trc_BonProErn := trc_TrvAllErn;
    l_TotLibBP := l_TotLibTA;
    -- Refund any tax paid
    trc_LibFpBP := -1 * bal_TX_ON_BP_YTD;
    trc_NpValBPOvr := TRUE;
  END IF;

-- Annual Bonus
--
  -- Ytd Annual Bonus
  trc_AnnBonYtd :=
  (bal_AB_NRFI_YTD
  +bal_AB_RFI_YTD
  );
  -- Skip the calculation if there is No Income
  IF trc_AnnBonYtd <> 0 THEN
    -- Annual Bonus Earnings
    trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
    -- Tax Liability
    l_TotLibAB := TaxLiability(p_Amt => trc_AnnBonErn);
    trc_LibFyAB := l_TotLibAB - l_TotLibTA;

    -- Check Bonus Provision
    IF trc_BonProYtd <> 0 THEN
      -- Check Bonus Provision Frequency
      IF dbi_BP_TX_RCV = 'A' THEN
        trc_LibFpAB := 0;
      ELSE
        trc_LibFpAB :=
        trc_LibFyAB - (bal_TX_ON_BP_YTD
                      +trc_LibFpBP
                      +bal_TX_ON_AB_YTD);
      END IF;
    ELSE
      trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
    END IF;
  ELSE
    trc_AnnBonErn := trc_TrvAllErn;
    l_TotLibAB := l_TotLibTA;
    -- Refund any tax paid
    trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
    trc_NpValABOvr := TRUE;
  END IF;

-- Annual Payments
--
  -- Ytd Annual Payments
  trc_AnnPymYtd :=
  (bal_ANU_FRM_RET_FND_NRFI_YTD
  +bal_ANU_FRM_RET_FND_RFI_YTD
  +bal_PRCH_ANU_TXB_NRFI_YTD
  +bal_PRCH_ANU_TXB_RFI_YTD
  +bal_SHR_OPT_EXD_NRFI_YTD
  +bal_SHR_OPT_EXD_RFI_YTD
  +bal_TXB_AP_NRFI_YTD
  +bal_TXB_AP_RFI_YTD
  +bal_TXB_SUBS_NRFI_YTD
  +bal_TXB_SUBS_RFI_YTD
  );
  -- Skip the calculation if there is No Income
  IF trc_AnnPymYtd <> 0 THEN
    -- Annual Payments Earnings
    trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
    -- Tax Liability
    l_TotLibAP := TaxLiability(p_Amt => trc_AnnPymErn);
    trc_LibFyAP := l_TotLibAP - l_TotLibAB;
    trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
  ElSE
    trc_AnnPymErn := trc_AnnBonErn;
    l_TotLibAP := l_TotLibAB;
    -- Refund any tax paid
    trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
    trc_NpValAPOvr := TRUE;
  END IF;

-- Public Office Allowance
--
  -- Ytd Public Office Allowance
  trc_PblOffYtd :=
  (bal_PO_NRFI_YTD
  +bal_PO_RFI_YTD
  );
  -- Skip the calculation if there is No Income
  IF trc_PblOffYtd <> 0 THEN
    -- Tax Liability
    trc_LibFyPO := trc_PblOffYtd * glb_ZA_PBL_TX_RTE / 100;
    trc_LibFpPO := trc_LibFyPO -  bal_TX_ON_PO_YTD;
  ELSE
    trc_LibFyPO := 0;
    -- Refund any tax paid
    trc_LibFpPO := -1 * bal_TX_ON_PO_YTD;
    trc_NpValPOOvr := TRUE;
  END IF;

-- Net Pay Validation
--
  NpVal(p_Rf => TRUE);

-- Execute the SitPaySplit Procedure
--
  SitPaySplit;

-- Tax Percentage Indicator
--
  IF dbi_TX_STA = 'D' THEN
    trc_TxPercVal := dbi_TX_DIR_VAL;
  ELSIF dbi_TX_STA = 'E' THEN
    trc_TxPercVal := glb_ZA_CC_TX_PRC;
  ELSIF dbi_TX_STA = 'F' THEN
    trc_TxPercVal := glb_ZA_TMP_TX_RTE;
  ELSE
    trc_TxPercVal := 0;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'DirCalc: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END DirCalc;


PROCEDURE BasCalc AS
-- Variables
--
  l_TotLibAB NUMBER(15,2);
  l_TotLibAP NUMBER(15,2);
  l_Np       NUMBER(15,2);
  l_65Year   DATE;

BEGIN
-- Identify the Calculation
--
  trc_CalTyp := 'BasCalc';

-- Tax Rebates, Threshold Figure and Medical Aid
--   Abatements
  -- Calculate the assignments 65 Year Date
  l_65Year := add_months(dbi_PER_DTE_OF_BRTH,780);

  IF l_65Year BETWEEN dbi_ZA_TX_YR_STRT AND dbi_ZA_TX_YR_END THEN
    -- give the extra abatement
    trc_Rebate := glb_ZA_PRI_TX_RBT + glb_ZA_ADL_TX_RBT;
    trc_Threshold := glb_ZA_SC_TX_THRSHLD;

  ELSE
    -- not eligable for extra abatement
    trc_Rebate := glb_ZA_PRI_TX_RBT;
    trc_Threshold := glb_ZA_PRI_TX_THRSHLD;

  END IF;

-- Base Earnings
--
  --Base Earnings
  trc_BseErn :=
  (bal_AB_NRFI_PTD
  +bal_AB_RFI_PTD
  +bal_ANU_FRM_RET_FND_NRFI_PTD
  +bal_ANU_FRM_RET_FND_RFI_PTD
  +bal_PRCH_ANU_TXB_NRFI_PTD
  +bal_PRCH_ANU_TXB_RFI_PTD
  +bal_SHR_OPT_EXD_NRFI_PTD
  +bal_SHR_OPT_EXD_RFI_PTD
  +bal_TXB_AP_NRFI_PTD
  +bal_TXB_AP_RFI_PTD
  +bal_TXB_SUBS_NRFI_PTD
  +bal_TXB_SUBS_RFI_PTD
  );
  -- Estimate Base Taxable Income
  trc_TxbBseInc := trc_BseErn * dbi_ZA_PAY_PRDS_PER_YR;
  -- Threshold Check
  IF trc_TxbBseInc >= trc_Threshold THEN
    -- Tax Liability
    trc_TotLibBse := TaxLiability(p_Amt => trc_TxbBseInc);
  ELSE
    trc_TotLibBse := 0;
  END IF;

-- Annual Bonus
--
  -- Ytd Annual Bonus
  trc_AnnBonYtd :=
  (bal_AB_NRFI_YTD
  +bal_AB_RFI_YTD
  );
  -- Skip the calculation if there is No Income
  IF trc_AnnBonYtd <> 0 THEN
    -- Taxable Annual Bonus Income
    trc_TxbAnnBonInc := trc_AnnBonYtd + trc_TxbBseInc;
    -- Threshold Check
    IF trc_TxbAnnBonInc >= trc_Threshold THEN
      -- Tax Liability
      l_TotLibAB := TaxLiability(p_Amt => trc_TxbAnnBonInc);
      trc_LibFyAB := l_TotLibAB - trc_TotLibBse;

      -- Check Bonus Provision
      IF bal_BP_YTD <> 0 THEN
        -- Check Bonus Provision Frequency
        IF dbi_BP_TX_RCV = 'A' THEN
          trc_LibFpAB := 0;
        ELSE
          trc_LibFpAB :=
          trc_LibFyAB - (bal_TX_ON_BP_YTD
                      +bal_TX_ON_AB_YTD);
        END IF;
      ELSE
        trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
      END IF;
    ELSE
      l_TotLibAB := trc_TotLibBse;
    END IF;
  ELSE
    l_TotLibAB := trc_TotLibBse;
    trc_TxbAnnBonInc := trc_TxbBseInc;
  END IF;

-- Annual Payments
--
  -- Ytd Annual Payments
  trc_AnnPymYtd :=
  (bal_ANU_FRM_RET_FND_NRFI_YTD
  +bal_ANU_FRM_RET_FND_RFI_YTD
  +bal_PRCH_ANU_TXB_NRFI_YTD
  +bal_PRCH_ANU_TXB_RFI_YTD
  +bal_SHR_OPT_EXD_NRFI_YTD
  +bal_SHR_OPT_EXD_RFI_YTD
  +bal_TXB_AP_NRFI_YTD
  +bal_TXB_AP_RFI_YTD
  +bal_TXB_SUBS_NRFI_YTD
  +bal_TXB_SUBS_RFI_YTD
  );
  -- Skip the calculation if there is No Income
  IF trc_AnnPymYtd <> 0 THEN
    -- Taxable Annual Payments Income
    trc_TxbAnnPymInc := trc_AnnPymYtd + trc_TxbAnnBonInc;
    -- Threshold Check
    IF trc_TxbAnnPymInc >= trc_Threshold THEN
      -- Tax Liability
      l_TotLibAP := TaxLiability(p_Amt => trc_TxbAnnPymInc);
      trc_LibFyAP := l_TotLibAP - l_TotLibAB;
      trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
    ELSE
      NULL;
    END IF;
  ELSE
    NUll;
  END IF;

-- Net Pay Validation
--
  NpVal;


EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'BasCalc: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END BasCalc;


PROCEDURE CalCalc AS
-- Variables
--
  l_TotLibAB NUMBER(15,2);
  l_TotLibAP NUMBER(15,2);
  l_Np       NUMBER(15,2);

BEGIN
-- Identify the calculation
--
  trc_CalTyp := 'CalCalc';

-- Update Global Balance Values with correct TAXABLE values
--
  TrvAllCal;

-- Calendar Ytd Taxable Income
--
  trc_TxbIncYtd :=
  (bal_AST_PRCHD_RVAL_NRFI_CYTD
  +bal_AST_PRCHD_RVAL_RFI_CYTD
  +bal_BUR_AND_SCH_NRFI_CYTD
  +bal_BUR_AND_SCH_RFI_CYTD
  +bal_COMM_NRFI_CYTD
  +bal_COMM_RFI_CYTD
  +bal_COMP_ALL_NRFI_CYTD
  +bal_COMP_ALL_RFI_CYTD
  +bal_ENT_ALL_NRFI_CYTD
  +bal_ENT_ALL_RFI_CYTD
  +bal_FREE_ACCOM_NRFI_CYTD
  +bal_FREE_ACCOM_RFI_CYTD
  +bal_FREE_SERV_NRFI_CYTD
  +bal_FREE_SERV_RFI_CYTD
  +bal_LOW_LOANS_NRFI_CYTD
  +bal_LOW_LOANS_RFI_CYTD
  +bal_MLS_AND_VOUCH_NRFI_CYTD
  +bal_MLS_AND_VOUCH_RFI_CYTD
  +bal_MED_PAID_NRFI_CYTD
  +bal_MED_PAID_RFI_CYTD
  +bal_OTHER_TXB_ALL_NRFI_CYTD
  +bal_OTHER_TXB_ALL_RFI_CYTD
  +bal_OVTM_NRFI_CYTD
  +bal_OVTM_RFI_CYTD
  +bal_PYM_DBT_NRFI_CYTD
  +bal_PYM_DBT_RFI_CYTD
  +bal_RGT_AST_NRFI_CYTD
  +bal_RGT_AST_RFI_CYTD
  +bal_TXB_INC_NRFI_CYTD
  +bal_TXB_INC_RFI_CYTD
  +bal_TXB_PEN_NRFI_CYTD
  +bal_TXB_PEN_RFI_CYTD
  +bal_TEL_ALL_NRFI_CYTD
  +bal_TEL_ALL_RFI_CYTD
  +bal_TOOL_ALL_NRFI_CYTD
  +bal_TOOL_ALL_RFI_CYTD
  +bal_TA_NRFI_CYTD
  +bal_TA_RFI_CYTD
  +bal_USE_VEH_NRFI_CYTD
  +bal_USE_VEH_RFI_CYTD
  );

-- If there is no Income Execute the Base calculation
--
  IF trc_TxbIncYtd = 0 THEN
    BasCalc;
  ELSE -- continue CalCalc

  -- Site Factor
  --
    trc_SitFactor := dbi_ZA_DYS_IN_YR / DaysWorked;

  -- Abatements
    Abatements;

  -- Base Earnings
  --
    -- Base Earnings
    trc_BseErn := trc_TxbIncYtd * trc_SitFactor;
    -- Taxable Base Income
    trc_TxbBseInc := trc_BseErn - trc_PerTotAbm;
    -- Threshold Check
    IF trc_TxbBseInc >= trc_Threshold THEN
      -- Tax Liability
      trc_TotLibBse := TaxLiability(p_Amt => trc_TxbBseInc);
    ELSE
      trc_TotLibBse := 0;
    END IF;

  -- Annual Bonus
  --
    -- Ytd Annual Bonus
    trc_AnnBonYtd :=
    (bal_AB_NRFI_YTD
    +bal_AB_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_AnnBonYtd <> 0 THEN
      -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_BseErn;
      -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibAB := TaxLiability(p_Amt => trc_TxbAnnBonInc);
        trc_LibFyAB := l_TotLibAB - trc_TotLibBse;

        -- Check Bonus Provision
        IF bal_BP_YTD <> 0 THEN
          -- Check Bonus Provision Frequency
          IF dbi_BP_TX_RCV = 'A' THEN
            trc_LibFpAB := 0;
          ELSE
            trc_LibFpAB :=
              trc_LibFyAB - (bal_TX_ON_BP_YTD
                          +bal_TX_ON_AB_YTD);
          END IF;
        ELSE
          trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
        END IF;
      ELSE
        l_TotLibAB := trc_TotLibBse;
      END IF;
    ELSE
      trc_AnnBonErn := trc_BseErn;-- Cascade Figure
      trc_TxbAnnBonInc := trc_TxbBseInc;
      l_TotLibAB := trc_TotLibBse;
    END IF;

  -- Annual Payments
  --
    -- Ytd Annual Payments
    trc_AnnPymYtd :=
    (bal_ANU_FRM_RET_FND_NRFI_YTD
    +bal_ANU_FRM_RET_FND_RFI_YTD
    +bal_PRCH_ANU_TXB_NRFI_YTD
    +bal_PRCH_ANU_TXB_RFI_YTD
    +bal_SHR_OPT_EXD_NRFI_YTD
    +bal_SHR_OPT_EXD_RFI_YTD
    +bal_TXB_AP_NRFI_YTD
    +bal_TXB_AP_RFI_YTD
    +bal_TXB_SUBS_NRFI_YTD
    +bal_TXB_SUBS_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_AnnPymYtd <> 0 THEN
      -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
      -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibAP := TaxLiability(p_Amt => trc_TxbAnnPymInc);
        trc_LibFyAP := l_TotLibAP - l_TotLibAB;
        trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
      ELSE
        l_TotLibAP := l_TotLibAB;
      END IF;
    ELSE
      trc_AnnPymErn := trc_AnnBonErn;
      trc_TxbAnnPymInc := trc_TxbAnnBonInc;
      l_TotLibAP := l_TotLibAB;
    END IF;

  -- Net pay Validation
  --
    NpVal;



  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'CalCalc: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END CalCalc;


PROCEDURE YtdCalc AS
-- Variables
--
  l_TotLibAB NUMBER(15,2);
  l_TotLibAP NUMBER(15,2);
  l_Np       NUMBER(15,2);

BEGIN
-- Identify the calculation
--
  trc_CalTyp := 'YtdCalc';

-- Update Global Balance Values with correct TAXABLE values
  TrvAllYtd;

-- Ytd Taxable Income
  trc_TxbIncYtd :=
  (bal_AST_PRCHD_RVAL_NRFI_YTD
  +bal_AST_PRCHD_RVAL_RFI_YTD
  +bal_BP_YTD
  +bal_BUR_AND_SCH_NRFI_YTD
  +bal_BUR_AND_SCH_RFI_YTD
  +bal_COMM_NRFI_YTD
  +bal_COMM_RFI_YTD
  +bal_COMP_ALL_NRFI_YTD
  +bal_COMP_ALL_RFI_YTD
  +bal_ENT_ALL_NRFI_YTD
  +bal_ENT_ALL_RFI_YTD
  +bal_FREE_ACCOM_NRFI_YTD
  +bal_FREE_ACCOM_RFI_YTD
  +bal_FREE_SERV_NRFI_YTD
  +bal_FREE_SERV_RFI_YTD
  +bal_LOW_LOANS_NRFI_YTD
  +bal_LOW_LOANS_RFI_YTD
  +bal_MLS_AND_VOUCH_NRFI_YTD
  +bal_MLS_AND_VOUCH_RFI_YTD
  +bal_MED_PAID_NRFI_YTD
  +bal_MED_PAID_RFI_YTD
  +bal_OTHER_TXB_ALL_NRFI_YTD
  +bal_OTHER_TXB_ALL_RFI_YTD
  +bal_OVTM_NRFI_YTD
  +bal_OVTM_RFI_YTD
  +bal_PYM_DBT_NRFI_YTD
  +bal_PYM_DBT_RFI_YTD
  +bal_RGT_AST_NRFI_YTD
  +bal_RGT_AST_RFI_YTD
  +bal_TXB_INC_NRFI_YTD
  +bal_TXB_INC_RFI_YTD
  +bal_TXB_PEN_NRFI_YTD
  +bal_TXB_PEN_RFI_YTD
  +bal_TEL_ALL_NRFI_YTD
  +bal_TEL_ALL_RFI_YTD
  +bal_TOOL_ALL_NRFI_YTD
  +bal_TOOL_ALL_RFI_YTD
  +bal_TA_NRFI_YTD
  +bal_TA_RFI_YTD
  +bal_USE_VEH_NRFI_YTD
  +bal_USE_VEH_RFI_YTD
  );

-- If the Ytd Taxable Income = 0, execute the CalCalc
  IF trc_TxbIncYtd = 0 THEN
    CalCalc;
  ELSE --Continue YtdCalc

  -- Site Factor
    trc_SitFactor := dbi_ZA_DYS_IN_YR / DaysWorked;

  -- Abatements
    Abatements;

  -- Base Earnings
  --
    -- Base Earnings
    trc_BseErn := trc_TxbIncYtd * trc_SitFactor;
    -- Taxable Base Income
    trc_TxbBseInc := trc_BseErn - trc_PerTotAbm;
    -- Threshold Check
    IF trc_TxbBseInc >= trc_Threshold THEN
      -- Tax Liability
      trc_TotLibBse := TaxLiability(p_Amt => trc_TxbBseInc);
    ELSE
      trc_TotLibBse := 0;
    END IF;

  -- Annual Bonus
  --
    -- Ytd Annual Bonus
    trc_AnnBonYtd :=
    (bal_AB_NRFI_YTD
    +bal_AB_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_AnnBonYtd <> 0 THEN
      -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_BseErn;
      -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibAB := TaxLiability(p_Amt => trc_TxbAnnBonInc);
        trc_LibFyAB := l_TotLibAB - trc_TotLibBse;

        -- Check Bonus Provision
        IF bal_BP_YTD <> 0 THEN
          -- Check Bonus Provision Frequency
          IF dbi_BP_TX_RCV = 'A' THEN
            trc_LibFpAB := 0;
          ELSE
            trc_LibFpAB :=
              trc_LibFyAB - (bal_TX_ON_BP_YTD
                          +bal_TX_ON_AB_YTD);
          END IF;
        ELSE
          trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
        END IF;
      ELSE
        l_TotLibAB := trc_TotLibBse;
      END IF;
    ELSE
      trc_AnnBonErn := trc_BseErn;-- Cascade Figure
      trc_TxbAnnBonInc := trc_TxbBseInc;
      l_TotLibAB := trc_TotLibBse;
    END IF;

  -- Annual Payment
  --
    -- Ytd Annual Payments
    trc_AnnPymYtd :=
    (bal_ANU_FRM_RET_FND_NRFI_YTD
    +bal_ANU_FRM_RET_FND_RFI_YTD
    +bal_PRCH_ANU_TXB_NRFI_YTD
    +bal_PRCH_ANU_TXB_RFI_YTD
    +bal_SHR_OPT_EXD_NRFI_YTD
    +bal_SHR_OPT_EXD_RFI_YTD
    +bal_TXB_AP_NRFI_YTD
    +bal_TXB_AP_RFI_YTD
    +bal_TXB_SUBS_NRFI_YTD
    +bal_TXB_SUBS_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_AnnPymYtd <> 0 THEN
      -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
      -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibAP := TaxLiability(p_Amt => trc_TxbAnnPymInc);
        trc_LibFyAP := l_TotLibAP - l_TotLibAB;
        trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
      ELSE
        l_TotLibAP := l_TotLibAB;
      END IF;
    ELSE
      trc_AnnPymErn := trc_AnnBonErn;-- Cascade Figure
      trc_TxbAnnPymInc := trc_TxbAnnBonInc;
      l_TotLibAP := l_TotLibAB;
    END IF;

  -- Net Pay validation
  --
    NpVal;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'YtdCalc: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END YtdCalc;


PROCEDURE NorCalc AS
-- Variables
--
  l_TotLibNI NUMBER(15,2) DEFAULT 0;
  l_TotLibFB NUMBER(15,2) DEFAULT 0;
  l_TotLibTA NUMBER(15,2) DEFAULT 0;
  l_TotLibBP NUMBER(15,2) DEFAULT 0;
  l_TotLibAB NUMBER(15,2) DEFAULT 0;
  l_TotLibAP NUMBER(15,2) DEFAULT 0;
  l_Np       NUMBER(15,2) DEFAULT 0;

BEGIN

-- Identify the calculation
--
  trc_CalTyp := 'NorCalc';



-- Update Global Balance Values with correct TAXABLE values
--
  bal_TA_RFI_PTD :=
    bal_TA_RFI_PTD * glb_ZA_TRV_ALL_TX_PRC / 100;

  bal_TA_NRFI_PTD :=
    bal_TA_NRFI_PTD * glb_ZA_TRV_ALL_TX_PRC / 100;

  TrvAllYtd;

  bal_PO_RFI_PTD :=
    bal_PO_RFI_PTD * glb_ZA_PBL_TX_PRC / 100;

  bal_PO_NRFI_PTD :=
    bal_PO_NRFI_PTD * glb_ZA_PBL_TX_PRC / 100;

  bal_PO_RFI_YTD :=
    bal_PO_RFI_YTD * glb_ZA_PBL_TX_PRC / 100;

  bal_PO_NRFI_YTD :=
    bal_PO_NRFI_YTD * glb_ZA_PBL_TX_PRC / 100;



-- PTD Taxable Income
--
  trc_TxbIncPtd :=
    (bal_AST_PRCHD_RVAL_NRFI_PTD
    +bal_AST_PRCHD_RVAL_RFI_PTD
    +bal_BP_PTD
    +bal_BUR_AND_SCH_NRFI_PTD
    +bal_BUR_AND_SCH_RFI_PTD
    +bal_COMM_NRFI_PTD
    +bal_COMM_RFI_PTD
    +bal_COMP_ALL_NRFI_PTD
    +bal_COMP_ALL_RFI_PTD
    +bal_ENT_ALL_NRFI_PTD
    +bal_ENT_ALL_RFI_PTD
    +bal_FREE_ACCOM_NRFI_PTD
    +bal_FREE_ACCOM_RFI_PTD
    +bal_FREE_SERV_NRFI_PTD
    +bal_FREE_SERV_RFI_PTD
    +bal_LOW_LOANS_NRFI_PTD
    +bal_LOW_LOANS_RFI_PTD
    +bal_MLS_AND_VOUCH_NRFI_PTD
    +bal_MLS_AND_VOUCH_RFI_PTD
    +bal_MED_PAID_NRFI_PTD
    +bal_MED_PAID_RFI_PTD
    +bal_OTHER_TXB_ALL_NRFI_PTD
    +bal_OTHER_TXB_ALL_RFI_PTD
    +bal_OVTM_NRFI_PTD
    +bal_OVTM_RFI_PTD
    +bal_PYM_DBT_NRFI_PTD
    +bal_PYM_DBT_RFI_PTD
    +bal_RGT_AST_NRFI_PTD
    +bal_RGT_AST_RFI_PTD
    +bal_TXB_INC_NRFI_PTD
    +bal_TXB_INC_RFI_PTD
    +bal_TXB_PEN_NRFI_PTD
    +bal_TXB_PEN_RFI_PTD
    +bal_TEL_ALL_NRFI_PTD
    +bal_TEL_ALL_RFI_PTD
    +bal_TOOL_ALL_NRFI_PTD
    +bal_TOOL_ALL_RFI_PTD
    +bal_TA_NRFI_PTD
    +bal_TA_RFI_PTD
    +bal_USE_VEH_NRFI_PTD
    +bal_USE_VEH_RFI_PTD
    );


  -- Period Factor
    PeriodFactor;

  -- Possible Periods Factor
    PossiblePeriodsFactor;

  -- Abatements
    Abatements;

  -- Normal Income
  --
    -- Ytd Normal Income
    trc_NorIncYtd :=
    ( bal_COMM_NRFI_YTD
    + bal_COMM_RFI_YTD
    + bal_COMP_ALL_NRFI_YTD
    + bal_COMP_ALL_RFI_YTD
    + bal_ENT_ALL_NRFI_YTD
    + bal_ENT_ALL_RFI_YTD
    + bal_OTHER_TXB_ALL_NRFI_YTD
    + bal_OTHER_TXB_ALL_RFI_YTD
    + bal_OVTM_NRFI_YTD
    + bal_OVTM_RFI_YTD
    + bal_TXB_INC_NRFI_YTD
    + bal_TXB_INC_RFI_YTD
    + bal_TXB_PEN_NRFI_YTD
    + bal_TXB_PEN_RFI_YTD
    + bal_TEL_ALL_NRFI_YTD
    + bal_TEL_ALL_RFI_YTD
    + bal_TOOL_ALL_NRFI_YTD
    + bal_TOOL_ALL_RFI_YTD
    );

    -- Skip the calculation if there is No Income
    IF trc_NorIncYtd <> 0 THEN
      -- Ptd Normal Income
      trc_NorIncPtd :=
      ( bal_COMM_NRFI_PTD
      + bal_COMM_RFI_PTD
      + bal_COMP_ALL_NRFI_PTD
      + bal_COMP_ALL_RFI_PTD
      + bal_ENT_ALL_NRFI_PTD
      + bal_ENT_ALL_RFI_PTD
      + bal_OTHER_TXB_ALL_NRFI_PTD
      + bal_OTHER_TXB_ALL_RFI_PTD
      + bal_OVTM_NRFI_PTD
      + bal_OVTM_RFI_PTD
      + bal_TXB_INC_NRFI_PTD
      + bal_TXB_INC_RFI_PTD
      + bal_TXB_PEN_NRFI_PTD
      + bal_TXB_PEN_RFI_PTD
      + bal_TEL_ALL_NRFI_PTD
      + bal_TEL_ALL_RFI_PTD
      + bal_TOOL_ALL_NRFI_PTD
      + bal_TOOL_ALL_RFI_PTD
      );

      -- Annualise Normal Income
      trc_NorErn := Annualise
                    (p_YtdInc => trc_NorIncYtd
                    ,p_PtdInc => trc_NorIncPtd
                    );

      -- Taxable Normal Income
      trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;

      -- Threshold Check
      IF trc_TxbNorInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibNI := TaxLiability(p_Amt => trc_TxbNorInc);
        trc_LibFyNI := l_TotLibNI - 0;

        -- DeAnnualise
        trc_LibFpNI := DeAnnualise
                       (p_Liab    => trc_LibFyNI
                       ,p_TxOnYtd => bal_TX_ON_NI_YTD
                       ,p_TxOnPtd => bal_TX_ON_NI_PTD
                       );
      ELSE
        l_TotLibNI := 0;
        -- Refund any tax paid
        trc_LibFpNI := DeAnnualise
                       (p_Liab    => trc_LibFyNI
                       ,p_TxOnYtd => bal_TX_ON_NI_YTD
                       ,p_TxOnPtd => bal_TX_ON_NI_PTD
                       );
        trc_NpValNIOvr := TRUE;
      END IF;
    ELSE
      trc_NorErn := 0;
      trc_TxbNorInc := 0;
      l_TotLibNI := 0;
      -- Refund any tax paid
      trc_LibFpNI := DeAnnualise
                     (p_Liab    => trc_LibFyNI
                     ,p_TxOnYtd => bal_TX_ON_NI_YTD
                     ,p_TxOnPtd => bal_TX_ON_NI_PTD
                     );
      trc_NpValNIOvr := TRUE;
    END IF;

  -- Fringe Benefits
  --
    -- Ytd Fringe Benefits
    trc_FrnBenYtd :=
    (bal_AST_PRCHD_RVAL_NRFI_YTD
    +bal_AST_PRCHD_RVAL_RFI_YTD
    +bal_BUR_AND_SCH_NRFI_YTD
    +bal_BUR_AND_SCH_RFI_YTD
    +bal_FREE_ACCOM_NRFI_YTD
    +bal_FREE_ACCOM_RFI_YTD
    +bal_FREE_SERV_NRFI_YTD
    +bal_FREE_SERV_RFI_YTD
    +bal_LOW_LOANS_NRFI_YTD
    +bal_LOW_LOANS_RFI_YTD
    +bal_MLS_AND_VOUCH_NRFI_YTD
    +bal_MLS_AND_VOUCH_RFI_YTD
    +bal_MED_PAID_NRFI_YTD
    +bal_MED_PAID_RFI_YTD
    +bal_PYM_DBT_NRFI_YTD
    +bal_PYM_DBT_RFI_YTD
    +bal_RGT_AST_NRFI_YTD
    +bal_RGT_AST_RFI_YTD
    +bal_USE_VEH_NRFI_YTD
    +bal_USE_VEH_RFI_YTD
    );

    -- Skip the calculation if there is No Income
    IF trc_FrnBenYtd <> 0 THEN
      -- Ptd Fringe Benefits
      trc_FrnBenPtd :=
      (bal_AST_PRCHD_RVAL_NRFI_PTD
      +bal_AST_PRCHD_RVAL_RFI_PTD
      +bal_BUR_AND_SCH_NRFI_PTD
      +bal_BUR_AND_SCH_RFI_PTD
      +bal_FREE_ACCOM_NRFI_PTD
      +bal_FREE_ACCOM_RFI_PTD
      +bal_FREE_SERV_NRFI_PTD
      +bal_FREE_SERV_RFI_PTD
      +bal_LOW_LOANS_NRFI_PTD
      +bal_LOW_LOANS_RFI_PTD
      +bal_MLS_AND_VOUCH_NRFI_PTD
      +bal_MLS_AND_VOUCH_RFI_PTD
      +bal_MED_PAID_NRFI_PTD
      +bal_MED_PAID_RFI_PTD
      +bal_PYM_DBT_NRFI_PTD
      +bal_PYM_DBT_RFI_PTD
      +bal_RGT_AST_NRFI_PTD
      +bal_RGT_AST_RFI_PTD
      +bal_USE_VEH_NRFI_PTD
      +bal_USE_VEH_RFI_PTD
      );

      -- Annualise Fringe Benefits
      trc_FrnBenErn := Annualise
                     (p_YtdInc => trc_FrnBenYtd
                     ,p_PtdInc => trc_FrnBenPtd
                     ) + trc_NorErn;
      -- Taxable Fringe Income
      trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbFrnInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibFB := TaxLiability(p_Amt => trc_TxbFrnInc);
        trc_LibFyFB := l_TotLibFB - l_TotLibNI;

        -- DeAnnualise
        trc_LibFpFB := DeAnnualise
                     (trc_LibFyFB
                     ,bal_TX_ON_FB_YTD
                     ,bal_TX_ON_FB_PTD
                     );
      ELSE
        l_TotLibFB := l_TotLibNI;
        -- Refund any tax paid
        trc_LibFpFB := DeAnnualise
                       (trc_LibFyFB
                       ,bal_TX_ON_FB_YTD
                       ,bal_TX_ON_FB_PTD
                       );
        trc_NpValFBOvr := TRUE;
      END IF;
    ELSE
      trc_FrnBenErn := trc_NorErn;
      trc_TxbFrnInc := trc_TxbNorInc;
      l_TotLibFB := l_TotLibNI;
      -- Refund any tax paid
      trc_LibFpFB := DeAnnualise
                     (trc_LibFyFB
                     ,bal_TX_ON_FB_YTD
                     ,bal_TX_ON_FB_PTD
                     );
      trc_NpValFBOvr := TRUE;
    END IF;

  -- Travel Allowance
  --
    -- Ytd Travel Allowance
    trc_TrvAllYtd :=
    (bal_TA_NRFI_YTD
    +bal_TA_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_TrvAllYtd <> 0 THEN
      -- Ptd Travel Allowance
      trc_TrvAllPtd :=
      (bal_TA_NRFI_PTD
      +bal_TA_RFI_PTD
      );
      -- Annualise Travel Allowance
      trc_TrvAllErn := Annualise
                     (p_YtdInc => trc_TrvAllYtd
                     ,p_PtdInc => trc_TrvAllPtd
                     ) + trc_FrnBenErn;
      -- Taxable Travel Income
      trc_TxbTrvInc := trc_TrvAllErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbTrvInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibTA := TaxLiability(p_Amt => trc_TxbTrvInc);
        trc_LibFyTA := l_TotLibTA - l_TotLibFB;

      -- DeAnnualise
      trc_LibFpTA := DeAnnualise
                   (trc_LibFyTA
                   ,bal_TX_ON_TA_YTD
                   ,bal_TX_ON_TA_PTD
                   );
      ELSE
        l_TotLibTA := l_TotLibFB;
        -- Refund any tax paid
        trc_LibFpTA := DeAnnualise
                       (trc_LibFyTA
                       ,bal_TX_ON_TA_YTD
                       ,bal_TX_ON_TA_PTD
                       );
        trc_NpValTAOvr := TRUE;
      END IF;
    ELSE
      trc_TrvAllErn := trc_FrnBenErn;-- Cascade Figure
      trc_TxbTrvInc := trc_TxbFrnInc;
      l_TotLibTA := l_TotLibFB;
      -- Refund any tax paid
      trc_LibFpTA := DeAnnualise
                     (trc_LibFyTA
                     ,bal_TX_ON_TA_YTD
                     ,bal_TX_ON_TA_PTD
                     );
      trc_NpValTAOvr := TRUE;
    END IF;

  -- Bonus Provision
  --
    -- Ytd Bonus Prvision
    trc_BonProYtd := bal_BP_YTD;
    -- Skip the calculation if there is No Income
    IF trc_BonProYtd <> 0 THEN
      -- Ptd Bonus Provision
      trc_BonProPtd := bal_BP_PTD;
      -- Annualise Bonus Provision
      trc_BonProErn := Annualise
                     (p_YtdInc => trc_BonProYtd
                     ,p_PtdInc => trc_BonProPtd
                     ) + trc_TrvAllErn;
      -- Taxable Bonus Provision Income
      trc_TxbBonProInc := trc_BonProErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbBonProInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibBP := TaxLiability(p_Amt => trc_TxbBonProInc);
        trc_LibFyBP := l_TotLibBP - l_TotLibTA;

        -- DeAnnualise
        trc_LibFpBP := DeAnnualise
                     (trc_LibFyBP
                     ,bal_TX_ON_BP_YTD
                     ,bal_TX_ON_BP_PTD
                     );
      ELSE
        l_TotLibBP := l_TotLibTA;
        -- Refund any tax paid
        trc_LibFpBP := DeAnnualise
                       (trc_LibFyBP
                       ,bal_TX_ON_BP_YTD
                       ,bal_TX_ON_BP_PTD
                       );
        trc_NpValBPOvr := TRUE;
      END IF;
    ELSE
      trc_BonProErn := trc_TrvAllErn;
      trc_TxbBonProInc := trc_TxbTrvInc;
      l_TotLibBP := l_TotLibTA;
      -- Refund any tax paid
      trc_LibFpBP := DeAnnualise
                     (trc_LibFyBP
                     ,bal_TX_ON_BP_YTD
                     ,bal_TX_ON_BP_PTD
                     );
      trc_NpValBPOvr := TRUE;
    END IF;

  -- Annual Bonus
  --
    -- Ytd Annual Bonus
    trc_AnnBonYtd :=
    (bal_AB_NRFI_YTD
    +bal_AB_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_AnnBonYtd <> 0 THEN
      -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
      -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn -trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibAB := TaxLiability(p_Amt => trc_TxbAnnBonInc);
        trc_LibFyAB := l_TotLibAB - l_TotLibTA;

        -- Check Bonus Provision
        IF trc_BonProYtd <> 0 THEN
          -- Check Bonus Provision Frequency
          IF dbi_BP_TX_RCV = 'A' THEN
            trc_LibFpAB := 0;
          ELSE
            trc_LibFpAB :=
              trc_LibFyAB - (bal_TX_ON_BP_YTD
                           +trc_LibFpBP
                           +bal_TX_ON_AB_YTD);
          END IF;
        ELSE
          trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
        END IF;
      ELSE
        l_TotLibAB := l_TotLibTA;
        -- Refund any tax paid
        trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
        trc_NpValABOvr := TRUE;
      END IF;
    ELSE
      trc_AnnBonErn := trc_TrvAllErn;
      trc_TxbAnnBonInc := trc_TxbTrvInc;
      l_TotLibAB := l_TotLibTA;
      -- Refund any tax paid
      trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
      trc_NpValABOvr := TRUE;
    END IF;

  -- Annual Payments
  --
    -- Ytd Annual Payments
    trc_AnnPymYtd :=
    (bal_ANU_FRM_RET_FND_NRFI_YTD
    +bal_ANU_FRM_RET_FND_RFI_YTD
    +bal_PRCH_ANU_TXB_NRFI_YTD
    +bal_PRCH_ANU_TXB_RFI_YTD
    +bal_SHR_OPT_EXD_NRFI_YTD
    +bal_SHR_OPT_EXD_RFI_YTD
    +bal_TXB_AP_NRFI_YTD
    +bal_TXB_AP_RFI_YTD
    +bal_TXB_SUBS_NRFI_YTD
    +bal_TXB_SUBS_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_AnnPymYtd <> 0 THEN
      -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
      -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
        -- Tax Liability
        l_TotLibAP := TaxLiability(p_Amt => trc_TxbAnnPymInc);
        trc_LibFyAP := l_TotLibAP - l_TotLibAB;
        trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
      ELSE
        l_TotLibAP := l_TotLibAB;
        -- Refund any tax paid
        trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
        trc_NpValAPOvr := TRUE;
      END IF;
    ELSE
      trc_AnnPymErn := trc_AnnBonErn;
      trc_TxbAnnPymInc := trc_TxbAnnBonInc;
      l_TotLibAP := l_TotLibAB;
      -- Refund any tax paid
      trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
      trc_NpValAPOvr := TRUE;
    END IF;

  -- Public Office Allowance
  --
    -- Ytd Public Office Allowance
    trc_PblOffYtd :=
    (bal_PO_NRFI_YTD
    +bal_PO_RFI_YTD
    );
    -- Skip the calculation if there is No Income
    IF trc_PblOffYtd <> 0 THEN
      -- Ptd Public Office Allowance
      trc_PblOffPtd :=
      (bal_PO_NRFI_PTD
      +bal_PO_RFI_PTD
      );
      -- Annualise Public Office Allowance
      trc_PblOffErn := Annualise
                     (p_YtdInc => trc_PblOffYtd
                     ,p_PtdInc => trc_PblOffPtd
                     );
      -- Tax Liability
      trc_LibFyPO := trc_PblOffErn * glb_ZA_PBL_TX_RTE / 100;
      trc_LibFpPO := DeAnnualise
                   (trc_LibFyPO
                   ,bal_TX_ON_PO_YTD
                   ,bal_TX_ON_PO_PTD
                   );
    ELSE
      -- Refund any tax paid
      trc_LibFpPO := DeAnnualise
                     (trc_LibFyPO
                     ,bal_TX_ON_PO_YTD
                     ,bal_TX_ON_PO_PTD
                     );
      trc_NpValPOOvr := TRUE;
    END IF;

  -- Net Pay Validation
  --
    NpVal;


  EXCEPTION
    WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'NorCalc: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;

END NorCalc;


-- Function to Initialise Globals
--
FUNCTION ZaTxGlb_01011001(
-- Global Values
   p_ZA_ADL_TX_RBT IN NUMBER DEFAULT 0
  ,p_ZA_ARR_PF_AN_MX_ABT IN NUMBER DEFAULT 0
  ,p_ZA_ARR_RA_AN_MX_ABT IN NUMBER DEFAULT 0
  ,p_ZA_TRV_ALL_TX_PRC IN NUMBER DEFAULT 0
  ,p_ZA_CC_TX_PRC IN NUMBER DEFAULT 0
  ,p_ZA_PF_AN_MX_ABT IN NUMBER DEFAULT 0
  ,p_ZA_PF_MX_PRC IN NUMBER DEFAULT 0
  ,p_ZA_PRI_TX_RBT IN NUMBER DEFAULT 0
  ,p_ZA_PRI_TX_THRSHLD IN NUMBER DEFAULT 0
  ,p_ZA_PBL_TX_PRC IN NUMBER DEFAULT 0
  ,p_ZA_PBL_TX_RTE IN NUMBER DEFAULT 0
  ,p_ZA_RA_AN_MX_ABT IN NUMBER DEFAULT 0
  ,p_ZA_RA_MX_PRC IN NUMBER DEFAULT 0
  ,p_ZA_SC_TX_THRSHLD IN NUMBER DEFAULT 0
  ,p_ZA_SIT_LIM IN NUMBER DEFAULT 0
  ,p_ZA_TMP_TX_RTE IN NUMBER DEFAULT 0
  ,p_ZA_WRK_DYS_PR_YR IN NUMBER DEFAULT 0
  ) RETURN NUMBER
AS
  l_Dum NUMBER := 1;
  --id VARCHAR2(30);

BEGIN
  --id := dbms_debug.initialize('JLTX');
  --dbms_debug.debug_on;

-- Initialise Package Globals
-- Global Values
  glb_ZA_ADL_TX_RBT       := p_ZA_ADL_TX_RBT;
  glb_ZA_ARR_PF_AN_MX_ABT := p_ZA_ARR_PF_AN_MX_ABT;
  glb_ZA_ARR_RA_AN_MX_ABT := p_ZA_ARR_RA_AN_MX_ABT;
  glb_ZA_TRV_ALL_TX_PRC   := p_ZA_TRV_ALL_TX_PRC;
  glb_ZA_CC_TX_PRC        := p_ZA_CC_TX_PRC;
  glb_ZA_PF_AN_MX_ABT     := p_ZA_PF_AN_MX_ABT;
  glb_ZA_PF_MX_PRC        := p_ZA_PF_MX_PRC;
  glb_ZA_PRI_TX_RBT       := p_ZA_PRI_TX_RBT;
  glb_ZA_PRI_TX_THRSHLD   := p_ZA_PRI_TX_THRSHLD;
  glb_ZA_PBL_TX_PRC       := p_ZA_PBL_TX_PRC;
  glb_ZA_PBL_TX_RTE       := p_ZA_PBL_TX_RTE;
  glb_ZA_RA_AN_MX_ABT     := p_ZA_RA_AN_MX_ABT;
  glb_ZA_RA_MX_PRC        := p_ZA_RA_MX_PRC;
  glb_ZA_SC_TX_THRSHLD    := p_ZA_SC_TX_THRSHLD;
  glb_ZA_SIT_LIM          := p_ZA_SIT_LIM;
  glb_ZA_TMP_TX_RTE       := p_ZA_TMP_TX_RTE;
  glb_ZA_WRK_DYS_PR_YR    := p_ZA_WRK_DYS_PR_YR;

  RETURN l_Dum;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxGlb_01011001: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxGlb_01011001;

-- Function to Initialise Globals - Database Item Values
--
FUNCTION ZaTxDbi_01011001(
-- Database Items
   p_ARR_PF_FRQ IN VARCHAR2 DEFAULT 'M'
  ,p_ARR_RA_FRQ IN VARCHAR2 DEFAULT 'M'
  ,p_ASG_STRT_DTE IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
  ,p_BP_TX_RCV IN VARCHAR2 DEFAULT 'B'
  ,p_PER_AGE IN NUMBER DEFAULT 0
  ,p_PER_DTE_OF_BRTH IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
  ,p_RA_FRQ IN VARCHAR2 DEFAULT 'M'
  ,p_SEA_WRK_DYS_WRK IN NUMBER DEFAULT 0
  ,p_SES_DTE IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
  ,p_TX_DIR_VAL IN NUMBER DEFAULT 0
  ,p_TX_STA IN VARCHAR2 DEFAULT 'X'
  ,p_ZA_ACT_END_DTE IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
  ,p_ZA_CUR_PRD_END_DTE IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
  ,p_ZA_CUR_PRD_STRT_DTE IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
  ,p_ZA_DYS_IN_YR IN NUMBER DEFAULT 0
  ,p_ZA_PAY_PRDS_LFT IN NUMBER DEFAULT 0
  ,p_ZA_PAY_PRDS_PER_YR IN NUMBER DEFAULT 0
  ,p_ZA_TX_YR_END IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
  ,p_ZA_TX_YR_STRT IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
  ) RETURN NUMBER
AS
  l_Dum NUMBER := 1;

BEGIN
-- Initialise Package Globals
-- Database Items
  dbi_ARR_PF_FRQ          := p_ARR_PF_FRQ;
  dbi_ARR_RA_FRQ          := p_ARR_RA_FRQ;
  dbi_ASG_STRT_DTE        := p_ASG_STRT_DTE;
  dbi_BP_TX_RCV           := p_BP_TX_RCV;
  dbi_PER_AGE             := p_PER_AGE;
  dbi_PER_DTE_OF_BRTH     := p_PER_DTE_OF_BRTH;
  dbi_RA_FRQ              := p_RA_FRQ;
  dbi_SEA_WRK_DYS_WRK     := p_SEA_WRK_DYS_WRK;
  dbi_SES_DTE             := p_SES_DTE;
  dbi_TX_DIR_VAL          := p_TX_DIR_VAL;
  dbi_TX_STA              := p_TX_STA;
  dbi_ZA_ACT_END_DTE      := p_ZA_ACT_END_DTE;
  dbi_ZA_CUR_PRD_END_DTE  := p_ZA_CUR_PRD_END_DTE;
  dbi_ZA_CUR_PRD_STRT_DTE := p_ZA_CUR_PRD_STRT_DTE;
  dbi_ZA_DYS_IN_YR        := p_ZA_DYS_IN_YR;
  dbi_ZA_PAY_PRDS_LFT     := p_ZA_PAY_PRDS_LFT;
  dbi_ZA_PAY_PRDS_PER_YR  := p_ZA_PAY_PRDS_PER_YR;
  dbi_ZA_TX_YR_END        := p_ZA_TX_YR_END;
  dbi_ZA_TX_YR_STRT       := p_ZA_TX_YR_STRT;

  RETURN l_Dum;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxDbi_01011001: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;

END ZaTxDbi_01011001;


-- Function to Initialise Globals - Balance Values
-- First Section
FUNCTION ZaTxBal1_01011001(
-- Balances
   p_AB_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_AB_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_AB_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_AB_RFI_RUN IN NUMBER DEFAULT 0
  ,p_AB_RFI_PTD IN NUMBER DEFAULT 0
  ,p_AB_RFI_YTD IN NUMBER DEFAULT 0
  ,p_ANN_PF_RUN IN NUMBER DEFAULT 0
  ,p_ANN_PF_PTD IN NUMBER DEFAULT 0
  ,p_ANN_PF_YTD IN NUMBER DEFAULT 0
  ,p_ANU_FRM_RET_FND_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_ANU_FRM_RET_FND_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_ANU_FRM_RET_FND_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_ANU_FRM_RET_FND_RFI_RUN IN NUMBER DEFAULT 0
  ,p_ANU_FRM_RET_FND_RFI_PTD IN NUMBER DEFAULT 0
  ,p_ANU_FRM_RET_FND_RFI_YTD IN NUMBER DEFAULT 0
  ,p_ARR_PF_CYTD IN NUMBER DEFAULT 0
  ,p_ARR_PF_PTD IN NUMBER DEFAULT 0
  ,p_ARR_PF_YTD IN NUMBER DEFAULT 0
  ,p_ARR_RA_CYTD IN NUMBER DEFAULT 0
  ,p_ARR_RA_PTD IN NUMBER DEFAULT 0
  ,p_ARR_RA_YTD IN NUMBER DEFAULT 0
  ,p_AST_PRCHD_RVAL_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_AST_PRCHD_RVAL_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_AST_PRCHD_RVAL_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_AST_PRCHD_RVAL_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_AST_PRCHD_RVAL_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_AST_PRCHD_RVAL_RFI_RUN IN NUMBER DEFAULT 0
  ,p_AST_PRCHD_RVAL_RFI_PTD IN NUMBER DEFAULT 0
  ,p_AST_PRCHD_RVAL_RFI_YTD IN NUMBER DEFAULT 0
  ,p_BP_PTD IN NUMBER DEFAULT 0
  ,p_BP_YTD IN NUMBER DEFAULT 0
  ,p_BUR_AND_SCH_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_BUR_AND_SCH_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_BUR_AND_SCH_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_BUR_AND_SCH_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_BUR_AND_SCH_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_BUR_AND_SCH_RFI_RUN IN NUMBER DEFAULT 0
  ,p_BUR_AND_SCH_RFI_PTD IN NUMBER DEFAULT 0
  ,p_BUR_AND_SCH_RFI_YTD IN NUMBER DEFAULT 0
  ,p_COMM_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_COMM_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_COMM_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_COMM_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_COMM_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_COMM_RFI_RUN IN NUMBER DEFAULT 0
  ,p_COMM_RFI_PTD IN NUMBER DEFAULT 0
  ,p_COMM_RFI_YTD IN NUMBER DEFAULT 0
  ,p_COMP_ALL_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_COMP_ALL_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_COMP_ALL_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_COMP_ALL_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_COMP_ALL_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_COMP_ALL_RFI_RUN IN NUMBER DEFAULT 0
  ,p_COMP_ALL_RFI_PTD IN NUMBER DEFAULT 0
  ,p_COMP_ALL_RFI_YTD IN NUMBER DEFAULT 0
  ,p_CUR_PF_CYTD IN NUMBER DEFAULT 0
  ,p_CUR_PF_RUN IN NUMBER DEFAULT 0
  ,p_CUR_PF_PTD IN NUMBER DEFAULT 0
  ,p_CUR_PF_YTD IN NUMBER DEFAULT 0
  ,p_CUR_RA_CYTD IN NUMBER DEFAULT 0
  ,p_CUR_RA_RUN IN NUMBER DEFAULT 0
  ,p_CUR_RA_PTD IN NUMBER DEFAULT 0
  ,p_CUR_RA_YTD IN NUMBER DEFAULT 0
  ,p_ENT_ALL_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_ENT_ALL_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_ENT_ALL_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_ENT_ALL_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_ENT_ALL_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_ENT_ALL_RFI_RUN IN NUMBER DEFAULT 0
  ,p_ENT_ALL_RFI_PTD IN NUMBER DEFAULT 0
  ,p_ENT_ALL_RFI_YTD IN NUMBER DEFAULT 0
  ,p_EXC_ARR_PEN_ITD IN NUMBER DEFAULT 0
  ,p_EXC_ARR_PEN_PTD IN NUMBER DEFAULT 0
  ,p_EXC_ARR_RA_ITD IN NUMBER DEFAULT 0
  ,p_EXC_ARR_RA_PTD IN NUMBER DEFAULT 0
  ,p_FREE_ACCOM_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_FREE_ACCOM_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_FREE_ACCOM_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_FREE_ACCOM_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_FREE_ACCOM_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_FREE_ACCOM_RFI_RUN IN NUMBER DEFAULT 0
  ,p_FREE_ACCOM_RFI_PTD IN NUMBER DEFAULT 0
  ,p_FREE_ACCOM_RFI_YTD IN NUMBER DEFAULT 0
  ,p_FREE_SERV_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_FREE_SERV_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_FREE_SERV_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_FREE_SERV_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_FREE_SERV_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_FREE_SERV_RFI_RUN IN NUMBER DEFAULT 0
  ,p_FREE_SERV_RFI_PTD IN NUMBER DEFAULT 0
  ,p_FREE_SERV_RFI_YTD IN NUMBER DEFAULT 0
  ,p_LOW_LOANS_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_LOW_LOANS_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_LOW_LOANS_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_LOW_LOANS_NRFI_YTD IN NUMBER DEFAULT 0
  ) RETURN NUMBER
AS
  l_Dum NUMBER := 1;

BEGIN
-- Balances
  bal_AB_NRFI_RUN              := p_AB_NRFI_RUN;
  bal_AB_NRFI_PTD              := p_AB_NRFI_PTD;
  bal_AB_NRFI_YTD              := p_AB_NRFI_YTD;
  bal_AB_RFI_RUN               := p_AB_RFI_RUN;
  bal_AB_RFI_PTD               := p_AB_RFI_PTD;
  bal_AB_RFI_YTD               := p_AB_RFI_YTD;
  bal_ANN_PF_RUN               := p_ANN_PF_RUN;
  bal_ANN_PF_PTD               := p_ANN_PF_PTD;
  bal_ANN_PF_YTD               := p_ANN_PF_YTD;
  bal_ANU_FRM_RET_FND_NRFI_RUN := p_ANU_FRM_RET_FND_NRFI_RUN;
  bal_ANU_FRM_RET_FND_NRFI_PTD := p_ANU_FRM_RET_FND_NRFI_PTD;
  bal_ANU_FRM_RET_FND_NRFI_YTD := p_ANU_FRM_RET_FND_NRFI_YTD;
  bal_ANU_FRM_RET_FND_RFI_RUN  := p_ANU_FRM_RET_FND_RFI_RUN;
  bal_ANU_FRM_RET_FND_RFI_PTD  := p_ANU_FRM_RET_FND_RFI_PTD;
  bal_ANU_FRM_RET_FND_RFI_YTD  := p_ANU_FRM_RET_FND_RFI_YTD;
  bal_ARR_PF_CYTD              := p_ARR_PF_CYTD;
  bal_ARR_PF_PTD               := p_ARR_PF_PTD;
  bal_ARR_PF_YTD               := p_ARR_PF_YTD;
  bal_ARR_RA_CYTD              := p_ARR_RA_CYTD;
  bal_ARR_RA_PTD               := p_ARR_RA_PTD;
  bal_ARR_RA_YTD               := p_ARR_RA_YTD;
  bal_AST_PRCHD_RVAL_NRFI_CYTD := p_AST_PRCHD_RVAL_NRFI_CYTD;
  bal_AST_PRCHD_RVAL_NRFI_RUN  := p_AST_PRCHD_RVAL_NRFI_RUN;
  bal_AST_PRCHD_RVAL_NRFI_PTD  := p_AST_PRCHD_RVAL_NRFI_PTD;
  bal_AST_PRCHD_RVAL_NRFI_YTD  := p_AST_PRCHD_RVAL_NRFI_YTD;
  bal_AST_PRCHD_RVAL_RFI_CYTD  := p_AST_PRCHD_RVAL_RFI_CYTD;
  bal_AST_PRCHD_RVAL_RFI_RUN   := p_AST_PRCHD_RVAL_RFI_RUN;
  bal_AST_PRCHD_RVAL_RFI_PTD   := p_AST_PRCHD_RVAL_RFI_PTD;
  bal_AST_PRCHD_RVAL_RFI_YTD   := p_AST_PRCHD_RVAL_RFI_YTD;
  bal_BP_PTD                   := p_BP_PTD;
  bal_BP_YTD                   := p_BP_YTD;
  bal_BUR_AND_SCH_NRFI_CYTD    := p_BUR_AND_SCH_NRFI_CYTD;
  bal_BUR_AND_SCH_NRFI_RUN     := p_BUR_AND_SCH_NRFI_RUN;
  bal_BUR_AND_SCH_NRFI_PTD     := p_BUR_AND_SCH_NRFI_PTD;
  bal_BUR_AND_SCH_NRFI_YTD     := p_BUR_AND_SCH_NRFI_YTD;
  bal_BUR_AND_SCH_RFI_CYTD     := p_BUR_AND_SCH_RFI_CYTD;
  bal_BUR_AND_SCH_RFI_RUN      := p_BUR_AND_SCH_RFI_RUN;
  bal_BUR_AND_SCH_RFI_PTD      := p_BUR_AND_SCH_RFI_PTD;
  bal_BUR_AND_SCH_RFI_YTD      := p_BUR_AND_SCH_RFI_YTD;
  bal_COMM_NRFI_CYTD           := p_COMM_NRFI_CYTD;
  bal_COMM_NRFI_RUN            := p_COMM_NRFI_RUN;
  bal_COMM_NRFI_PTD            := p_COMM_NRFI_PTD;
  bal_COMM_NRFI_YTD            := p_COMM_NRFI_YTD;
  bal_COMM_RFI_CYTD            := p_COMM_RFI_CYTD;
  bal_COMM_RFI_RUN             := p_COMM_RFI_RUN;
  bal_COMM_RFI_PTD             := p_COMM_RFI_PTD;
  bal_COMM_RFI_YTD             := p_COMM_RFI_YTD;
  bal_COMP_ALL_NRFI_CYTD       := p_COMP_ALL_NRFI_CYTD;
  bal_COMP_ALL_NRFI_RUN        := p_COMP_ALL_NRFI_RUN;
  bal_COMP_ALL_NRFI_PTD        := p_COMP_ALL_NRFI_PTD;
  bal_COMP_ALL_NRFI_YTD        := p_COMP_ALL_NRFI_YTD;
  bal_COMP_ALL_RFI_CYTD        := p_COMP_ALL_RFI_CYTD;
  bal_COMP_ALL_RFI_RUN         := p_COMP_ALL_RFI_RUN;
  bal_COMP_ALL_RFI_PTD         := p_COMP_ALL_RFI_PTD;
  bal_COMP_ALL_RFI_YTD         := p_COMP_ALL_RFI_YTD;
  bal_CUR_PF_CYTD              := p_CUR_PF_CYTD;
  bal_CUR_PF_RUN               := p_CUR_PF_RUN;
  bal_CUR_PF_PTD               := p_CUR_PF_PTD;
  bal_CUR_PF_YTD               := p_CUR_PF_YTD;
  bal_CUR_RA_CYTD              := p_CUR_RA_CYTD;
  bal_CUR_RA_RUN               := p_CUR_RA_RUN;
  bal_CUR_RA_PTD               := p_CUR_RA_PTD;
  bal_CUR_RA_YTD               := p_CUR_RA_YTD;
  bal_ENT_ALL_NRFI_CYTD        := p_ENT_ALL_NRFI_CYTD;
  bal_ENT_ALL_NRFI_RUN         := p_ENT_ALL_NRFI_RUN;
  bal_ENT_ALL_NRFI_PTD         := p_ENT_ALL_NRFI_PTD;
  bal_ENT_ALL_NRFI_YTD         := p_ENT_ALL_NRFI_YTD;
  bal_ENT_ALL_RFI_CYTD         := p_ENT_ALL_RFI_CYTD;
  bal_ENT_ALL_RFI_RUN          := p_ENT_ALL_RFI_RUN;
  bal_ENT_ALL_RFI_PTD          := p_ENT_ALL_RFI_PTD;
  bal_ENT_ALL_RFI_YTD          := p_ENT_ALL_RFI_YTD;
  bal_EXC_ARR_PEN_ITD          := p_EXC_ARR_PEN_ITD;
  bal_EXC_ARR_PEN_PTD          := p_EXC_ARR_PEN_PTD;
  bal_EXC_ARR_RA_ITD           := p_EXC_ARR_RA_ITD;
  bal_EXC_ARR_RA_PTD           := p_EXC_ARR_RA_PTD;
  bal_FREE_ACCOM_NRFI_CYTD     := p_FREE_ACCOM_NRFI_CYTD;
  bal_FREE_ACCOM_NRFI_RUN      := p_FREE_ACCOM_NRFI_RUN;
  bal_FREE_ACCOM_NRFI_PTD      := p_FREE_ACCOM_NRFI_PTD;
  bal_FREE_ACCOM_NRFI_YTD      := p_FREE_ACCOM_NRFI_YTD;
  bal_FREE_ACCOM_RFI_CYTD      := p_FREE_ACCOM_RFI_CYTD;
  bal_FREE_ACCOM_RFI_RUN       := p_FREE_ACCOM_RFI_RUN;
  bal_FREE_ACCOM_RFI_PTD       := p_FREE_ACCOM_RFI_PTD;
  bal_FREE_ACCOM_RFI_YTD       := p_FREE_ACCOM_RFI_YTD;
  bal_FREE_SERV_NRFI_CYTD      := p_FREE_SERV_NRFI_CYTD;
  bal_FREE_SERV_NRFI_RUN       := p_FREE_SERV_NRFI_RUN;
  bal_FREE_SERV_NRFI_PTD       := p_FREE_SERV_NRFI_PTD;
  bal_FREE_SERV_NRFI_YTD       := p_FREE_SERV_NRFI_YTD;
  bal_FREE_SERV_RFI_CYTD       := p_FREE_SERV_RFI_CYTD;
  bal_FREE_SERV_RFI_RUN        := p_FREE_SERV_RFI_RUN;
  bal_FREE_SERV_RFI_PTD        := p_FREE_SERV_RFI_PTD;
  bal_FREE_SERV_RFI_YTD        := p_FREE_SERV_RFI_YTD;
  bal_LOW_LOANS_NRFI_CYTD      := p_LOW_LOANS_NRFI_CYTD;
  bal_LOW_LOANS_NRFI_RUN       := p_LOW_LOANS_NRFI_RUN;
  bal_LOW_LOANS_NRFI_PTD       := p_LOW_LOANS_NRFI_PTD;
  bal_LOW_LOANS_NRFI_YTD       := p_LOW_LOANS_NRFI_YTD;

  RETURN l_Dum;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal1_01011001: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal1_01011001;


-- Function to Initialise Globals - Balance Values
-- Second Section
FUNCTION ZaTxBal2_01011001(
-- Balances
   p_LOW_LOANS_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_LOW_LOANS_RFI_RUN IN NUMBER DEFAULT 0
  ,p_LOW_LOANS_RFI_PTD IN NUMBER DEFAULT 0
  ,p_LOW_LOANS_RFI_YTD IN NUMBER DEFAULT 0
  ,p_MLS_AND_VOUCH_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_MLS_AND_VOUCH_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_MLS_AND_VOUCH_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_MLS_AND_VOUCH_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_MLS_AND_VOUCH_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_MLS_AND_VOUCH_RFI_RUN IN NUMBER DEFAULT 0
  ,p_MLS_AND_VOUCH_RFI_PTD IN NUMBER DEFAULT 0
  ,p_MLS_AND_VOUCH_RFI_YTD IN NUMBER DEFAULT 0
  ,p_MED_CONTR_CYTD IN NUMBER DEFAULT 0
  ,p_MED_CONTR_RUN IN NUMBER DEFAULT 0
  ,p_MED_CONTR_PTD IN NUMBER DEFAULT 0
  ,p_MED_CONTR_YTD IN NUMBER DEFAULT 0
  ,p_MED_PAID_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_MED_PAID_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_MED_PAID_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_MED_PAID_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_MED_PAID_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_MED_PAID_RFI_RUN IN NUMBER DEFAULT 0
  ,p_MED_PAID_RFI_PTD IN NUMBER DEFAULT 0
  ,p_MED_PAID_RFI_YTD IN NUMBER DEFAULT 0
  ,p_NET_PAY_RUN IN NUMBER DEFAULT 0
  ,p_OTHER_TXB_ALL_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_OTHER_TXB_ALL_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_OTHER_TXB_ALL_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_OTHER_TXB_ALL_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_OTHER_TXB_ALL_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_OTHER_TXB_ALL_RFI_RUN IN NUMBER DEFAULT 0
  ,p_OTHER_TXB_ALL_RFI_PTD IN NUMBER DEFAULT 0
  ,p_OTHER_TXB_ALL_RFI_YTD IN NUMBER DEFAULT 0
  ,p_OVTM_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_OVTM_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_OVTM_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_OVTM_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_OVTM_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_OVTM_RFI_RUN IN NUMBER DEFAULT 0
  ,p_OVTM_RFI_PTD IN NUMBER DEFAULT 0
  ,p_OVTM_RFI_YTD IN NUMBER DEFAULT 0
  ,p_PAYE_YTD IN NUMBER DEFAULT 0
  ,p_PYM_DBT_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_PYM_DBT_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_PYM_DBT_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_PYM_DBT_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_PYM_DBT_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_PYM_DBT_RFI_RUN IN NUMBER DEFAULT 0
  ,p_PYM_DBT_RFI_PTD IN NUMBER DEFAULT 0
  ,p_PYM_DBT_RFI_YTD IN NUMBER DEFAULT 0
  ,p_PO_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_PO_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_PO_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_PO_RFI_RUN IN NUMBER DEFAULT 0
  ,p_PO_RFI_PTD IN NUMBER DEFAULT 0
  ,p_PO_RFI_YTD IN NUMBER DEFAULT 0
  ,p_PRCH_ANU_TXB_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_PRCH_ANU_TXB_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_PRCH_ANU_TXB_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_PRCH_ANU_TXB_RFI_RUN IN NUMBER DEFAULT 0
  ,p_PRCH_ANU_TXB_RFI_PTD IN NUMBER DEFAULT 0
  ,p_PRCH_ANU_TXB_RFI_YTD IN NUMBER DEFAULT 0
  ,p_RGT_AST_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_RGT_AST_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_RGT_AST_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_RGT_AST_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_RGT_AST_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_RGT_AST_RFI_RUN IN NUMBER DEFAULT 0
  ,p_RGT_AST_RFI_PTD IN NUMBER DEFAULT 0
  ,p_RGT_AST_RFI_YTD IN NUMBER DEFAULT 0
  ,p_SHR_OPT_EXD_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_SHR_OPT_EXD_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_SHR_OPT_EXD_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_SHR_OPT_EXD_RFI_RUN IN NUMBER DEFAULT 0
  ,p_SHR_OPT_EXD_RFI_PTD IN NUMBER DEFAULT 0
  ,p_SHR_OPT_EXD_RFI_YTD IN NUMBER DEFAULT 0
  ,p_SITE_YTD IN NUMBER DEFAULT 0
  ,p_TXB_AP_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_TXB_AP_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_TXB_AP_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_TXB_AP_RFI_RUN IN NUMBER DEFAULT 0
  ,p_TXB_AP_RFI_PTD IN NUMBER DEFAULT 0
  ,p_TXB_AP_RFI_YTD IN NUMBER DEFAULT 0
  ,p_TXB_INC_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_TXB_INC_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_TXB_INC_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_TXB_INC_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_TXB_INC_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_TXB_INC_RFI_RUN IN NUMBER DEFAULT 0
  ) RETURN NUMBER
AS
  l_Dum NUMBER := 1;

BEGIN
-- Balances
  bal_LOW_LOANS_RFI_CYTD       := p_LOW_LOANS_RFI_CYTD;
  bal_LOW_LOANS_RFI_RUN        := p_LOW_LOANS_RFI_RUN;
  bal_LOW_LOANS_RFI_PTD        := p_LOW_LOANS_RFI_PTD;
  bal_LOW_LOANS_RFI_YTD        := p_LOW_LOANS_RFI_YTD;
  bal_MLS_AND_VOUCH_NRFI_CYTD  := p_MLS_AND_VOUCH_NRFI_CYTD;
  bal_MLS_AND_VOUCH_NRFI_RUN   := p_MLS_AND_VOUCH_NRFI_RUN;
  bal_MLS_AND_VOUCH_NRFI_PTD   := p_MLS_AND_VOUCH_NRFI_PTD;
  bal_MLS_AND_VOUCH_NRFI_YTD   := p_MLS_AND_VOUCH_NRFI_YTD;
  bal_MLS_AND_VOUCH_RFI_CYTD   := p_MLS_AND_VOUCH_RFI_CYTD;
  bal_MLS_AND_VOUCH_RFI_RUN    := p_MLS_AND_VOUCH_RFI_RUN;
  bal_MLS_AND_VOUCH_RFI_PTD    := p_MLS_AND_VOUCH_RFI_PTD;
  bal_MLS_AND_VOUCH_RFI_YTD    := p_MLS_AND_VOUCH_RFI_YTD;
  bal_MED_CONTR_CYTD           := p_MED_CONTR_CYTD;
  bal_MED_CONTR_RUN            := p_MED_CONTR_RUN;
  bal_MED_CONTR_PTD            := p_MED_CONTR_PTD;
  bal_MED_CONTR_YTD            := p_MED_CONTR_YTD;
  bal_MED_PAID_NRFI_CYTD       := p_MED_PAID_NRFI_CYTD;
  bal_MED_PAID_NRFI_RUN        := p_MED_PAID_NRFI_RUN;
  bal_MED_PAID_NRFI_PTD        := p_MED_PAID_NRFI_PTD;
  bal_MED_PAID_NRFI_YTD        := p_MED_PAID_NRFI_YTD;
  bal_MED_PAID_RFI_CYTD        := p_MED_PAID_RFI_CYTD;
  bal_MED_PAID_RFI_RUN         := p_MED_PAID_RFI_RUN;
  bal_MED_PAID_RFI_PTD         := p_MED_PAID_RFI_PTD;
  bal_MED_PAID_RFI_YTD         := p_MED_PAID_RFI_YTD;
  bal_NET_PAY_RUN              := p_NET_PAY_RUN;
  bal_OTHER_TXB_ALL_NRFI_CYTD  := p_OTHER_TXB_ALL_NRFI_CYTD;
  bal_OTHER_TXB_ALL_NRFI_RUN   := p_OTHER_TXB_ALL_NRFI_RUN;
  bal_OTHER_TXB_ALL_NRFI_PTD   := p_OTHER_TXB_ALL_NRFI_PTD;
  bal_OTHER_TXB_ALL_NRFI_YTD   := p_OTHER_TXB_ALL_NRFI_YTD;
  bal_OTHER_TXB_ALL_RFI_CYTD   := p_OTHER_TXB_ALL_RFI_CYTD;
  bal_OTHER_TXB_ALL_RFI_RUN    := p_OTHER_TXB_ALL_RFI_RUN;
  bal_OTHER_TXB_ALL_RFI_PTD    := p_OTHER_TXB_ALL_RFI_PTD;
  bal_OTHER_TXB_ALL_RFI_YTD    := p_OTHER_TXB_ALL_RFI_YTD;
  bal_OVTM_NRFI_CYTD           := p_OVTM_NRFI_CYTD;
  bal_OVTM_NRFI_RUN            := p_OVTM_NRFI_RUN;
  bal_OVTM_NRFI_PTD            := p_OVTM_NRFI_PTD;
  bal_OVTM_NRFI_YTD            := p_OVTM_NRFI_YTD;
  bal_OVTM_RFI_CYTD            := p_OVTM_RFI_CYTD;
  bal_OVTM_RFI_RUN             := p_OVTM_RFI_RUN;
  bal_OVTM_RFI_PTD             := p_OVTM_RFI_PTD;
  bal_OVTM_RFI_YTD             := p_OVTM_RFI_YTD;
  bal_PAYE_YTD                 := p_PAYE_YTD;
  bal_PYM_DBT_NRFI_CYTD        := p_PYM_DBT_NRFI_CYTD;
  bal_PYM_DBT_NRFI_RUN         := p_PYM_DBT_NRFI_RUN;
  bal_PYM_DBT_NRFI_PTD         := p_PYM_DBT_NRFI_PTD;
  bal_PYM_DBT_NRFI_YTD         := p_PYM_DBT_NRFI_YTD;
  bal_PYM_DBT_RFI_CYTD         := p_PYM_DBT_RFI_CYTD;
  bal_PYM_DBT_RFI_RUN          := p_PYM_DBT_RFI_RUN;
  bal_PYM_DBT_RFI_PTD          := p_PYM_DBT_RFI_PTD;
  bal_PYM_DBT_RFI_YTD          := p_PYM_DBT_RFI_YTD;
  bal_PO_NRFI_RUN              := p_PO_NRFI_RUN;
  bal_PO_NRFI_PTD              := p_PO_NRFI_PTD;
  bal_PO_NRFI_YTD              := p_PO_NRFI_YTD;
  bal_PO_RFI_RUN               := p_PO_RFI_RUN;
  bal_PO_RFI_PTD               := p_PO_RFI_PTD;
  bal_PO_RFI_YTD               := p_PO_RFI_YTD;
  bal_PRCH_ANU_TXB_NRFI_RUN    := p_PRCH_ANU_TXB_NRFI_RUN;
  bal_PRCH_ANU_TXB_NRFI_PTD    := p_PRCH_ANU_TXB_NRFI_PTD;
  bal_PRCH_ANU_TXB_NRFI_YTD    := p_PRCH_ANU_TXB_NRFI_YTD;
  bal_PRCH_ANU_TXB_RFI_RUN     := p_PRCH_ANU_TXB_RFI_RUN;
  bal_PRCH_ANU_TXB_RFI_PTD     := p_PRCH_ANU_TXB_RFI_PTD;
  bal_PRCH_ANU_TXB_RFI_YTD     := p_PRCH_ANU_TXB_RFI_YTD;
  bal_RGT_AST_NRFI_CYTD        := p_RGT_AST_NRFI_CYTD;
  bal_RGT_AST_NRFI_RUN         := p_RGT_AST_NRFI_RUN;
  bal_RGT_AST_NRFI_PTD         := p_RGT_AST_NRFI_PTD;
  bal_RGT_AST_NRFI_YTD         := p_RGT_AST_NRFI_YTD;
  bal_RGT_AST_RFI_CYTD         := p_RGT_AST_RFI_CYTD;
  bal_RGT_AST_RFI_RUN          := p_RGT_AST_RFI_RUN;
  bal_RGT_AST_RFI_PTD          := p_RGT_AST_RFI_PTD;
  bal_RGT_AST_RFI_YTD          := p_RGT_AST_RFI_YTD;
  bal_SHR_OPT_EXD_NRFI_RUN     := p_SHR_OPT_EXD_NRFI_RUN;
  bal_SHR_OPT_EXD_NRFI_PTD     := p_SHR_OPT_EXD_NRFI_PTD;
  bal_SHR_OPT_EXD_NRFI_YTD     := p_SHR_OPT_EXD_NRFI_YTD;
  bal_SHR_OPT_EXD_RFI_RUN      := p_SHR_OPT_EXD_RFI_RUN;
  bal_SHR_OPT_EXD_RFI_PTD      := p_SHR_OPT_EXD_RFI_PTD;
  bal_SHR_OPT_EXD_RFI_YTD      := p_SHR_OPT_EXD_RFI_YTD;
  bal_SITE_YTD                 := p_SITE_YTD;
  bal_TXB_AP_NRFI_RUN          := p_TXB_AP_NRFI_RUN;
  bal_TXB_AP_NRFI_PTD          := p_TXB_AP_NRFI_PTD;
  bal_TXB_AP_NRFI_YTD          := p_TXB_AP_NRFI_YTD;
  bal_TXB_AP_RFI_RUN           := p_TXB_AP_RFI_RUN;
  bal_TXB_AP_RFI_PTD           := p_TXB_AP_RFI_PTD;
  bal_TXB_AP_RFI_YTD           := p_TXB_AP_RFI_YTD;
  bal_TXB_INC_NRFI_CYTD        := p_TXB_INC_NRFI_CYTD;
  bal_TXB_INC_NRFI_RUN         := p_TXB_INC_NRFI_RUN;
  bal_TXB_INC_NRFI_PTD         := p_TXB_INC_NRFI_PTD;
  bal_TXB_INC_NRFI_YTD         := p_TXB_INC_NRFI_YTD;
  bal_TXB_INC_RFI_CYTD         := p_TXB_INC_RFI_CYTD;
  bal_TXB_INC_RFI_RUN          := p_TXB_INC_RFI_RUN;

  RETURN l_Dum;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal2_01011001: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal2_01011001;


-- Function to Initialise Globals - Balance Values
-- Third Section
FUNCTION ZaTxBal3_01011001(
-- Balances
   p_TXB_INC_RFI_PTD IN NUMBER DEFAULT 0
  ,p_TXB_INC_RFI_YTD IN NUMBER DEFAULT 0
  ,p_TXB_PEN_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_TXB_PEN_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_TXB_PEN_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_TXB_PEN_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_TXB_PEN_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_TXB_PEN_RFI_RUN IN NUMBER DEFAULT 0
  ,p_TXB_PEN_RFI_PTD IN NUMBER DEFAULT 0
  ,p_TXB_PEN_RFI_YTD IN NUMBER DEFAULT 0
  ,p_TXB_SUBS_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_TXB_SUBS_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_TXB_SUBS_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_TXB_SUBS_RFI_RUN IN NUMBER DEFAULT 0
  ,p_TXB_SUBS_RFI_PTD IN NUMBER DEFAULT 0
  ,p_TXB_SUBS_RFI_YTD IN NUMBER DEFAULT 0
  ,p_TAX_YTD IN NUMBER DEFAULT 0
  ,p_TX_ON_AB_PTD IN NUMBER DEFAULT 0
  ,p_TX_ON_AB_YTD IN NUMBER DEFAULT 0
  ,p_TX_ON_AP_RUN IN NUMBER DEFAULT 0
  ,p_TX_ON_AP_PTD IN NUMBER DEFAULT 0
  ,p_TX_ON_AP_YTD IN NUMBER DEFAULT 0
  ,p_TX_ON_BP_PTD IN NUMBER DEFAULT 0
  ,p_TX_ON_BP_YTD IN NUMBER DEFAULT 0
  ,p_TX_ON_TA_PTD IN NUMBER DEFAULT 0
  ,p_TX_ON_TA_YTD IN NUMBER DEFAULT 0
  ,p_TX_ON_FB_PTD IN NUMBER DEFAULT 0
  ,p_TX_ON_FB_YTD IN NUMBER DEFAULT 0
  ,p_TX_ON_NI_PTD IN NUMBER DEFAULT 0
  ,p_TX_ON_NI_YTD IN NUMBER DEFAULT 0
  ,p_TX_ON_PO_PTD IN NUMBER DEFAULT 0
  ,p_TX_ON_PO_YTD IN NUMBER DEFAULT 0
  ,p_TEL_ALL_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_TEL_ALL_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_TEL_ALL_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_TEL_ALL_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_TEL_ALL_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_TEL_ALL_RFI_RUN IN NUMBER DEFAULT 0
  ,p_TEL_ALL_RFI_PTD IN NUMBER DEFAULT 0
  ,p_TEL_ALL_RFI_YTD IN NUMBER DEFAULT 0
  ,p_TOOL_ALL_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_TOOL_ALL_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_TOOL_ALL_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_TOOL_ALL_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_TOOL_ALL_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_TOOL_ALL_RFI_RUN IN NUMBER DEFAULT 0
  ,p_TOOL_ALL_RFI_PTD IN NUMBER DEFAULT 0
  ,p_TOOL_ALL_RFI_YTD IN NUMBER DEFAULT 0
  ,p_TOT_INC_PTD IN NUMBER DEFAULT 0
  ,p_TOT_INC_YTD IN NUMBER DEFAULT 0
  ,p_TOT_NRFI_AN_INC_CYTD IN NUMBER DEFAULT 0
  ,p_TOT_NRFI_AN_INC_RUN IN NUMBER DEFAULT 0
  ,p_TOT_NRFI_AN_INC_YTD IN NUMBER DEFAULT 0
  ,p_TOT_NRFI_INC_CYTD IN NUMBER DEFAULT 0
  ,p_TOT_NRFI_INC_RUN IN NUMBER DEFAULT 0
  ,p_TOT_NRFI_INC_PTD IN NUMBER DEFAULT 0
  ,p_TOT_NRFI_INC_YTD IN NUMBER DEFAULT 0
  ,p_TOT_RFI_AN_INC_CYTD IN NUMBER DEFAULT 0
  ,p_TOT_RFI_AN_INC_RUN IN NUMBER DEFAULT 0
  ,p_TOT_RFI_AN_INC_PTD IN NUMBER DEFAULT 0
  ,p_TOT_RFI_AN_INC_YTD IN NUMBER DEFAULT 0
  ,p_TOT_RFI_INC_CYTD IN NUMBER DEFAULT 0
  ,p_TOT_RFI_INC_RUN IN NUMBER DEFAULT 0
  ,p_TOT_RFI_INC_PTD IN NUMBER DEFAULT 0
  ,p_TOT_RFI_INC_YTD IN NUMBER DEFAULT 0
  ,p_TOT_SEA_WRK_DYS_WRK_YTD IN NUMBER DEFAULT 0
  ,p_TOT_TXB_INC_ITD IN NUMBER DEFAULT 0
  ,p_TA_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_TA_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_TA_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_TA_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_TA_RFI_PTD IN NUMBER DEFAULT 0
  ,p_TA_RFI_YTD IN NUMBER DEFAULT 0
  ,p_USE_VEH_NRFI_CYTD IN NUMBER DEFAULT 0
  ,p_USE_VEH_NRFI_RUN IN NUMBER DEFAULT 0
  ,p_USE_VEH_NRFI_PTD IN NUMBER DEFAULT 0
  ,p_USE_VEH_NRFI_YTD IN NUMBER DEFAULT 0
  ,p_USE_VEH_RFI_CYTD IN NUMBER DEFAULT 0
  ,p_USE_VEH_RFI_RUN IN NUMBER DEFAULT 0
  ,p_USE_VEH_RFI_PTD IN NUMBER DEFAULT 0
  ,p_USE_VEH_RFI_YTD IN NUMBER DEFAULT 0
  ) RETURN NUMBER
AS
  l_Dum NUMBER := 1;

BEGIN
-- Balances
  bal_TXB_INC_RFI_PTD          := p_TXB_INC_RFI_PTD;
  bal_TXB_INC_RFI_YTD          := p_TXB_INC_RFI_YTD;
  bal_TXB_PEN_NRFI_CYTD        := p_TXB_PEN_NRFI_CYTD;
  bal_TXB_PEN_NRFI_RUN         := p_TXB_PEN_NRFI_RUN;
  bal_TXB_PEN_NRFI_PTD         := p_TXB_PEN_NRFI_PTD;
  bal_TXB_PEN_NRFI_YTD         := p_TXB_PEN_NRFI_YTD;
  bal_TXB_PEN_RFI_CYTD         := p_TXB_PEN_RFI_CYTD;
  bal_TXB_PEN_RFI_RUN          := p_TXB_PEN_RFI_RUN;
  bal_TXB_PEN_RFI_PTD          := p_TXB_PEN_RFI_PTD;
  bal_TXB_PEN_RFI_YTD          := p_TXB_PEN_RFI_YTD;
  bal_TXB_SUBS_NRFI_RUN        := p_TXB_SUBS_NRFI_RUN;
  bal_TXB_SUBS_NRFI_PTD        := p_TXB_SUBS_NRFI_PTD;
  bal_TXB_SUBS_NRFI_YTD        := p_TXB_SUBS_NRFI_YTD;
  bal_TXB_SUBS_RFI_RUN         := p_TXB_SUBS_RFI_RUN;
  bal_TXB_SUBS_RFI_PTD         := p_TXB_SUBS_RFI_PTD;
  bal_TXB_SUBS_RFI_YTD         := p_TXB_SUBS_RFI_YTD;
  bal_TAX_YTD                  := p_TAX_YTD;
  bal_TX_ON_AB_PTD             := p_TX_ON_AB_PTD;
  bal_TX_ON_AB_YTD             := p_TX_ON_AB_YTD;
  bal_TX_ON_AP_RUN             := p_TX_ON_AP_RUN;
  bal_TX_ON_AP_PTD             := p_TX_ON_AP_PTD;
  bal_TX_ON_AP_YTD             := p_TX_ON_AP_YTD;
  bal_TX_ON_BP_PTD             := p_TX_ON_BP_PTD;
  bal_TX_ON_BP_YTD             := p_TX_ON_BP_YTD;
  bal_TX_ON_TA_PTD             := p_TX_ON_TA_PTD;
  bal_TX_ON_TA_YTD             := p_TX_ON_TA_YTD;
  bal_TX_ON_FB_PTD             := p_TX_ON_FB_PTD;
  bal_TX_ON_FB_YTD             := p_TX_ON_FB_YTD;
  bal_TX_ON_NI_PTD             := p_TX_ON_NI_PTD;
  bal_TX_ON_NI_YTD             := p_TX_ON_NI_YTD;
  bal_TX_ON_PO_PTD             := p_TX_ON_PO_PTD;
  bal_TX_ON_PO_YTD             := p_TX_ON_PO_YTD;
  bal_TEL_ALL_NRFI_CYTD        := p_TEL_ALL_NRFI_CYTD;
  bal_TEL_ALL_NRFI_RUN         := p_TEL_ALL_NRFI_RUN;
  bal_TEL_ALL_NRFI_PTD         := p_TEL_ALL_NRFI_PTD;
  bal_TEL_ALL_NRFI_YTD         := p_TEL_ALL_NRFI_YTD;
  bal_TEL_ALL_RFI_CYTD         := p_TEL_ALL_RFI_CYTD;
  bal_TEL_ALL_RFI_RUN          := p_TEL_ALL_RFI_RUN;
  bal_TEL_ALL_RFI_PTD          := p_TEL_ALL_RFI_PTD;
  bal_TEL_ALL_RFI_YTD          := p_TEL_ALL_RFI_YTD;
  bal_TOOL_ALL_NRFI_CYTD       := p_TOOL_ALL_NRFI_CYTD;
  bal_TOOL_ALL_NRFI_RUN        := p_TOOL_ALL_NRFI_RUN;
  bal_TOOL_ALL_NRFI_PTD        := p_TOOL_ALL_NRFI_PTD;
  bal_TOOL_ALL_NRFI_YTD        := p_TOOL_ALL_NRFI_YTD;
  bal_TOOL_ALL_RFI_CYTD        := p_TOOL_ALL_RFI_CYTD;
  bal_TOOL_ALL_RFI_RUN         := p_TOOL_ALL_RFI_RUN;
  bal_TOOL_ALL_RFI_PTD         := p_TOOL_ALL_RFI_PTD;
  bal_TOOL_ALL_RFI_YTD         := p_TOOL_ALL_RFI_YTD;
  bal_TOT_INC_PTD              := p_TOT_INC_PTD;
  bal_TOT_INC_YTD              := p_TOT_INC_YTD;
  bal_TOT_NRFI_AN_INC_CYTD     := p_TOT_NRFI_AN_INC_CYTD;
  bal_TOT_NRFI_AN_INC_RUN      := p_TOT_NRFI_AN_INC_RUN;
  bal_TOT_NRFI_AN_INC_YTD      := p_TOT_NRFI_AN_INC_YTD;
  bal_TOT_NRFI_INC_CYTD        := p_TOT_NRFI_INC_CYTD;
  bal_TOT_NRFI_INC_RUN         := p_TOT_NRFI_INC_RUN;
  bal_TOT_NRFI_INC_PTD         := p_TOT_NRFI_INC_PTD;
  bal_TOT_NRFI_INC_YTD         := p_TOT_NRFI_INC_YTD;
  bal_TOT_RFI_AN_INC_CYTD      := p_TOT_RFI_AN_INC_CYTD;
  bal_TOT_RFI_AN_INC_RUN       := p_TOT_RFI_AN_INC_RUN;
  bal_TOT_RFI_AN_INC_PTD       := p_TOT_RFI_AN_INC_PTD;
  bal_TOT_RFI_AN_INC_YTD       := p_TOT_RFI_AN_INC_YTD;
  bal_TOT_RFI_INC_CYTD         := p_TOT_RFI_INC_CYTD;
  bal_TOT_RFI_INC_RUN          := p_TOT_RFI_INC_RUN;
  bal_TOT_RFI_INC_PTD          := p_TOT_RFI_INC_PTD;
  bal_TOT_RFI_INC_YTD          := p_TOT_RFI_INC_YTD;
  bal_TOT_SEA_WRK_DYS_WRK_YTD  := p_TOT_SEA_WRK_DYS_WRK_YTD;
  bal_TOT_TXB_INC_ITD          := p_TOT_TXB_INC_ITD;
  bal_TA_NRFI_CYTD             := p_TA_NRFI_CYTD;
  bal_TA_NRFI_PTD              := p_TA_NRFI_PTD;
  bal_TA_NRFI_YTD              := p_TA_NRFI_YTD;
  bal_TA_RFI_CYTD              := p_TA_RFI_CYTD;
  bal_TA_RFI_PTD               := p_TA_RFI_PTD;
  bal_TA_RFI_YTD               := p_TA_RFI_YTD;
  bal_USE_VEH_NRFI_CYTD        := p_USE_VEH_NRFI_CYTD;
  bal_USE_VEH_NRFI_RUN         := p_USE_VEH_NRFI_RUN;
  bal_USE_VEH_NRFI_PTD         := p_USE_VEH_NRFI_PTD;
  bal_USE_VEH_NRFI_YTD         := p_USE_VEH_NRFI_YTD;
  bal_USE_VEH_RFI_CYTD         := p_USE_VEH_RFI_CYTD;
  bal_USE_VEH_RFI_RUN          := p_USE_VEH_RFI_RUN;
  bal_USE_VEH_RFI_PTD          := p_USE_VEH_RFI_PTD;
  bal_USE_VEH_RFI_YTD          := p_USE_VEH_RFI_YTD;

  RETURN l_Dum;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal3_01011001: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal3_01011001;


-- Main Tax Function
-- Called from Fast Formula
FUNCTION ZaTx_01011001(
/*  PARAMETERS */
-- Contexts
   ASSIGNMENT_ACTION_ID IN NUMBER
  ,ASSIGNMENT_ID IN NUMBER
  ,PAYROLL_ACTION_ID IN NUMBER
  ,PAYROLL_ID IN NUMBER
-- Out Parameters
  ,p_MsgTxStatus OUT NOCOPY VARCHAR2
  ,p_LibWrn OUT NOCOPY VARCHAR2
  --,p_SeaWrkDysErr OUT VARCHAR2
  ,p_LibFpNI OUT NOCOPY NUMBER
  ,p_LibFpFB OUT NOCOPY NUMBER
  ,p_LibFpTA OUT NOCOPY NUMBER
  ,p_LibFpBP OUT NOCOPY NUMBER
  ,p_LibFpAB OUT NOCOPY NUMBER
  ,p_LibFpAP OUT NOCOPY NUMBER
  ,p_LibFpPO OUT NOCOPY NUMBER
  ,p_PayValue OUT NOCOPY NUMBER
  ,p_PayeVal OUT NOCOPY NUMBER
  ,p_SiteVal OUT NOCOPY NUMBER
  ,p_It3Ind  OUT NOCOPY NUMBER
  ,p_PfUpdFig OUT NOCOPY NUMBER
  ,p_RaUpdFig OUT NOCOPY NUMBER
  ,p_OUpdFig OUT NOCOPY NUMBER
  )RETURN NUMBER
AS
-- Variables
--
  l_Dum NUMBER := 1;


BEGIN
/* BODY */
-- Initialise Package Globals
-- Contexts
  con_ASG_ACT_ID := ASSIGNMENT_ACTION_ID;
  con_ASG_ID     := ASSIGNMENT_ID;
  con_PRL_ACT_ID := PAYROLL_ACTION_ID;
  con_PRL_ID     := PAYROLL_ID;

  --  Tax Status Validation --
  --
    /*
    C = Directive Amount
    D = Directive Percentage
    E = Close Corporation
    F = Temporary Worker/Student
    G = Seasonal Worker
    A = Normal
    B = Provisional
    H = Zero Tax
    */
    IF dbi_TX_STA = 'C' THEN
      -- Check that directive value is filled in
      IF dbi_TX_DIR_VAL = 0000 THEN
        trc_MsgTxStatus := 'WARNING: Tax Directive Value was defaulted to 25 Percent(%)';
        dbi_TX_DIR_VAL := 25;
        DirCalc;
      ELSE
        trc_CalTyp := 'NoCalc';
        trc_LibFpNI := dbi_TX_DIR_VAL;
        SitPaySplit;
      END IF;
    ELSIF dbi_TX_STA in ('D','E','F') THEN
      -- Check that directive value is filled in
      IF dbi_TX_DIR_VAL = 0000 THEN
        trc_MsgTxStatus := 'WARNING: Tax Directive Value was defaulted to 25 Percent(%)';
        dbi_TX_DIR_VAL := 25;
        DirCalc;
      ELSE
        DirCalc;
      END IF;
    ELSIF dbi_TX_STA = 'G' THEN
      -- Check that seasonal worker days worked is filled in
      IF dbi_SEA_WRK_DYS_WRK = 0 THEN
         IF xpt_Msg = 'No Error' THEN
            xpt_Msg := 'PY_ZA_TX_SEA_WRK_DYS';
         END IF;
         RAISE xpt_E;
      ELSE
        SeaCalc;
      END IF;
    ELSIF dbi_TX_STA IN ('A','B') THEN
      -- Is this a SITE Period in anyway?
      IF EmpTermPrePeriod THEN
        SitCalc;
      ELSIF LstPeriod OR EmpTermInPeriod THEN
        IF PreErnPeriod THEN
          YtdCalc;
        ELSE
          SitCalc;
        END IF;
      ElSE
      -- The employee has not been terminated!
        IF PreErnPeriod THEN
          YtdCalc;
        ELSE
          NorCalc;
        END IF;
      END IF;
    ELSIF dbi_TX_STA = 'H' THEN
      trc_LibFpNI := 0;
      trc_LibFpFB := 0;
      trc_LibFpTA := 0;
      trc_LibFpBP := 0;
      trc_LibFpAB := 0;
      trc_LibFpAP := 0;
      trc_LibFpPO := 0;
    ELSE
      hr_utility.set_message(801, 'ERROR: Invalid Tax Status');
      hr_utility.raise_error;
    END IF;

-- Execute the Arrear Processing
--
  IF SitePeriod THEN
    ArrearExcess;
  END IF;

  -- Setup the Out Parameters
  --
    -- Messages
    p_MsgTxStatus := trc_MsgTxStatus;
    p_LibWrn       := trc_LibWrn;

    -- Pay Values
    trc_PayValue :=
    (trc_LibFpNI
    +trc_LibFpFB
    +trc_LibFpTA
    +trc_LibFpBP
    +trc_LibFpAB
    +trc_LibFpAP
    +trc_LibFpPO
    );

    -- Tax On's
    p_LibFpNI := trc_LibFpNI;
    p_LibFpFB := trc_LibFpFB;
    p_LibFpTA := trc_LibFpTA;
    p_LibFpBP := trc_LibFpBP;
    p_LibFpAB := trc_LibFpAB;
    p_LibFpAP := trc_LibFpAP;
    p_LibFpPO := trc_LibFpPO;
    p_PayValue := trc_PayValue;

    -- Indicators, Splits and Updates
    p_PayeVal := trc_PayeVal;
    p_SiteVal := trc_SiteVal;
    p_It3Ind  := trc_It3Ind;
    p_PfUpdFig := trc_PfUpdFig;
    p_RaUpdFig := trc_RaUpdFig;
    p_OUpdFig := trc_OUpdFig;

-- Execute The Tax Trace
--
  Trace;
-- Clear Globals
--
  ClearGlobals;

  --dbms_debug.debug_off;

  RETURN l_Dum;

  EXCEPTION
    WHEN xpt_E  THEN
       hr_utility.set_message(801, xpt_Msg);
       hr_utility.raise_error;
    WHEN OTHERS THEN
       hr_utility.set_message(801, 'ZaTx_01011001: '||TO_CHAR(SQLCODE));
       hr_utility.raise_error;


END ZaTx_01011001;

END PY_ZA_TX_01011001;


/
