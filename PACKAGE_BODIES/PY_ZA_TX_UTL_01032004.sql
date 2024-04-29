--------------------------------------------------------
--  DDL for Package Body PY_ZA_TX_UTL_01032004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_TX_UTL_01032004" AS
/* $Header: pyzatu05.pkb 120.0 2005/05/29 10:32:56 appldev noship $ */
/* Copyright (c) Oracle Corporation 2000. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation Tax Module

   NAME
      py_za_tx_utl_01032004.pkb

   DESCRIPTION
      This is the ZA Tax Module utility package.  It contains
      functions and procedures used by the main tax package.

   PUBLIC FUNCTIONS
      GlbVal
         Returns the value of a Oracle Application Global
         date effectively
      NegPtd
         Boolean function returns true if any current PTD
         total balance value is negative
      LatePayPeriod
         Boolean function returns true if the current period
         is a Late Payment Period, i.e. a payment over the
         tax year boundary.
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

   PUBLIC PROCEDURES
      StartHrTrace
         Sets package global that determines if extra trace information
         will be written to file - hr_utility
      StopHrTrace
         Stops trace information from being written to file
      WriteHrTrace
         Writes extra trace information to file if global
         has been set
      PeriodFactor
         Calculates the period factor for the assignment.
         For a complete description see the tax module design document.
      PossiblePeriodsFactor
         Calculates the possible period factor for the assignment.
         For a complete description see the tax module design document.
      SetRebates
         Calculate tax Rebate and Threshold values.
         For a complete description see the tax module design document.
      Abatements
         Calculates all necessary abatements.
         For a complete description see the tax module design document.
      ArrearExcess
         Calculates the arrear excess figure to 'effectively' update the
         Asg_Itd dimension of the arrear excess pension and retirement
         annuity balances.  Will only fire on siteperiod.
      TrvAll
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

   PRIVATE FUNCTIONS
      GetTableValue
         Returns the value from a user table date effectively

   PRIVATE PROCEDURES
      <none>

   NOTES
      .

   MODIFICATION HISTORY
   Person      Date               Version   Comments
   ---------   ----------------   -------   -----------------------------------
   A. Mahanty  14/04/2005         115.5     Bug 3491357 BRA Enhancement.
                                            Balance value retrieval modified.
   J.N. Louw   07/01/2005         115.4     Bugs 4106203
                                                 4110940
   J.N. Louw   18/12/2004         115.3     Bug 3931259
   J.N. Louw   27/10/2004         115.2     Bug 3931277
   J.N. Louw   13/02/2004         115.0     Next Version of Main ZA Tax
                                             Package.
                                             For detail history see
                                             py_za_tx_utl_01032002

*/
-------------------------------------------------------------------------------
--                               PACKAGE BODY                                --
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- StartHrTrace                                                              --
-- Wrapper for hr_utility.trace_on                                           --
-------------------------------------------------------------------------------
PROCEDURE StartHrTrace AS
BEGIN
   IF g_HrTraceEnabled THEN
      hr_utility.trace_on(null,g_HrTracePipeName);
   END IF;
END StartHrTrace;
-------------------------------------------------------------------------------
-- StartHrTrace                                                              --
-- Function wrapper for hr_utility.trace_on                                  --
-------------------------------------------------------------------------------
FUNCTION StartHrTrace(
   p_HrTracePipeName VARCHAR2
   ) RETURN VARCHAR2
AS
BEGIN
   hr_utility.trace_on(null,p_HrTracePipeName);
   RETURN p_HrTracePipeName;
END StartHrTrace;
-------------------------------------------------------------------------------
-- StopHrTrace                                                               --
-- Wrapper for hr_utility.trace_off                                          --
-------------------------------------------------------------------------------
PROCEDURE StopHrTrace AS
BEGIN
   IF g_HrTraceEnabled THEN
      hr_utility.trace_off;
   END IF;
END StopHrTrace;
-------------------------------------------------------------------------------
-- StopHrTrace                                                               --
-- Function wrapper for hr_utility.trace_off                                 --
-------------------------------------------------------------------------------
FUNCTION StopHrTrace RETURN VARCHAR2 AS
BEGIN
   hr_utility.trace_off;
   RETURN 'TRACE_OFF';
END StopHrTrace;
-------------------------------------------------------------------------------
-- WriteHrTrace                                                              --
-- Wrapper for hr_utility.trace                                              --
-------------------------------------------------------------------------------
PROCEDURE WriteHrTrace(
   p_Buffer VARCHAR2
   )
AS
BEGIN
   IF g_HrTraceEnabled THEN
      -- Write the Line
      hr_utility.trace(p_Buffer);
   END IF;
END WriteHrTrace;


-------------------------------------------------------------------------------
--                           Tax Utility Functions                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- GlbVal                                                                    --
-------------------------------------------------------------------------------
FUNCTION GlbVal
   (p_GlbNme ff_globals_f.global_name%TYPE
   ,p_EffDte DATE
   ) RETURN ff_globals_f.global_value%TYPE
AS
-- Variables
   l_GlbVal t_balance;
BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.GlbVal',1);
   WriteHrTrace('p_GlbNme :'||p_GlbNme);
   WriteHrTrace('p_EffDte :'||to_char(p_EffDte,'DD/MM/YYYY'));
   --
   SELECT TO_NUMBER(global_value)
     INTO l_GlbVal
     FROM ff_globals_f
    WHERE p_EffDte between effective_start_date and effective_end_date
      AND global_name = p_GlbNme;

   hr_utility.set_location('py_za_tx_utl_01032004.GlbVal',2);
   RETURN l_GlbVal;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'GlbVal: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END GlbVal;


-------------------------------------------------------------------------------
-- TotPrdTxbIncYtd
-------------------------------------------------------------------------------
FUNCTION TotPrdTxbIncYtd RETURN t_balance AS
   ------------
   -- Variables
   ------------
   l_tot_txb_prd_inc_ytd t_balance;

-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tx_utl_01032004.TotPrdTxbIncYtd',1);
   l_tot_txb_prd_inc_ytd :=
      ( py_za_tx_01032004.bal_AST_PRCHD_RVAL_NRFI_YTD + py_za_tx_01032004.bal_AST_PRCHD_RVAL_RFI_YTD
      + py_za_tx_01032004.bal_BUR_AND_SCH_NRFI_YTD    + py_za_tx_01032004.bal_BUR_AND_SCH_RFI_YTD
      + py_za_tx_01032004.bal_COMM_NRFI_YTD           + py_za_tx_01032004.bal_COMM_RFI_YTD
      + py_za_tx_01032004.bal_COMP_ALL_NRFI_YTD       + py_za_tx_01032004.bal_COMP_ALL_RFI_YTD
      + py_za_tx_01032004.bal_ENT_ALL_NRFI_YTD        + py_za_tx_01032004.bal_ENT_ALL_RFI_YTD
      + py_za_tx_01032004.bal_FREE_ACCOM_NRFI_YTD     + py_za_tx_01032004.bal_FREE_ACCOM_RFI_YTD
      + py_za_tx_01032004.bal_FREE_SERV_NRFI_YTD      + py_za_tx_01032004.bal_FREE_SERV_RFI_YTD
      + py_za_tx_01032004.bal_IC_PYMNTS_NRFI_YTD      + py_za_tx_01032004.bal_IC_PYMNTS_RFI_YTD
      + py_za_tx_01032004.bal_LB_PYMNTS_NRFI_YTD      + py_za_tx_01032004.bal_LB_PYMNTS_RFI_YTD
      + py_za_tx_01032004.bal_LOW_LOANS_NRFI_YTD      + py_za_tx_01032004.bal_LOW_LOANS_RFI_YTD
      + py_za_tx_01032004.bal_MED_PAID_NRFI_YTD       + py_za_tx_01032004.bal_MED_PAID_RFI_YTD
      + py_za_tx_01032004.bal_MLS_AND_VOUCH_NRFI_YTD  + py_za_tx_01032004.bal_MLS_AND_VOUCH_RFI_YTD
      + py_za_tx_01032004.bal_OTHER_TXB_ALL_NRFI_YTD  + py_za_tx_01032004.bal_OTHER_TXB_ALL_RFI_YTD
      + py_za_tx_01032004.bal_OVTM_NRFI_YTD           + py_za_tx_01032004.bal_OVTM_RFI_YTD
      + py_za_tx_01032004.bal_PYM_DBT_NRFI_YTD        + py_za_tx_01032004.bal_PYM_DBT_RFI_YTD
      + py_za_tx_01032004.bal_RES_TRD_NRFI_YTD        + py_za_tx_01032004.bal_RES_TRD_RFI_YTD
      + py_za_tx_01032004.bal_RGT_AST_NRFI_YTD        + py_za_tx_01032004.bal_RGT_AST_RFI_YTD
      + py_za_tx_01032004.bal_TA_NRFI_YTD             + py_za_tx_01032004.bal_TA_RFI_YTD
      + py_za_tx_01032004.bal_TEL_ALL_NRFI_YTD        + py_za_tx_01032004.bal_TEL_ALL_RFI_YTD
      + py_za_tx_01032004.bal_TOOL_ALL_NRFI_YTD       + py_za_tx_01032004.bal_TOOL_ALL_RFI_YTD
      + py_za_tx_01032004.bal_TXB_INC_NRFI_YTD        + py_za_tx_01032004.bal_TXB_INC_RFI_YTD
      + py_za_tx_01032004.bal_TXB_PEN_NRFI_YTD        + py_za_tx_01032004.bal_TXB_PEN_RFI_YTD
      + py_za_tx_01032004.bal_USE_VEH_NRFI_YTD        + py_za_tx_01032004.bal_USE_VEH_RFI_YTD
      );

   hr_utility.set_location('py_za_tx_utl_01032004.TotPrdTxbIncYtd',2);
   RETURN l_tot_txb_prd_inc_ytd;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TotPrdTxbIncYtd',3);
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'TotPrdTxbIncYtd: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
-------------------------------------------------------------------------------
END TotPrdTxbIncYtd;


-------------------------------------------------------------------------------
-- TotPrdTxbIncPtd
-------------------------------------------------------------------------------
FUNCTION TotPrdTxbIncPtd RETURN t_balance AS
   ------------
   -- Variables
   ------------
   l_tot_txb_prd_inc_ptd t_balance;

-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tx_utl_01032004.TotPrdTxbIncPtd',1);
   l_tot_txb_prd_inc_ptd :=
      ( py_za_tx_01032004.bal_AST_PRCHD_RVAL_NRFI_PTD + py_za_tx_01032004.bal_AST_PRCHD_RVAL_RFI_PTD
      + py_za_tx_01032004.bal_BUR_AND_SCH_NRFI_PTD    + py_za_tx_01032004.bal_BUR_AND_SCH_RFI_PTD
      + py_za_tx_01032004.bal_COMM_NRFI_PTD           + py_za_tx_01032004.bal_COMM_RFI_PTD
      + py_za_tx_01032004.bal_COMP_ALL_NRFI_PTD       + py_za_tx_01032004.bal_COMP_ALL_RFI_PTD
      + py_za_tx_01032004.bal_ENT_ALL_NRFI_PTD        + py_za_tx_01032004.bal_ENT_ALL_RFI_PTD
      + py_za_tx_01032004.bal_FREE_ACCOM_NRFI_PTD     + py_za_tx_01032004.bal_FREE_ACCOM_RFI_PTD
      + py_za_tx_01032004.bal_FREE_SERV_NRFI_PTD      + py_za_tx_01032004.bal_FREE_SERV_RFI_PTD
      + py_za_tx_01032004.bal_IC_PYMNTS_NRFI_PTD      + py_za_tx_01032004.bal_IC_PYMNTS_RFI_PTD
      + py_za_tx_01032004.bal_LB_PYMNTS_NRFI_PTD      + py_za_tx_01032004.bal_LB_PYMNTS_RFI_PTD
      + py_za_tx_01032004.bal_LOW_LOANS_NRFI_PTD      + py_za_tx_01032004.bal_LOW_LOANS_RFI_PTD
      + py_za_tx_01032004.bal_MED_PAID_NRFI_PTD       + py_za_tx_01032004.bal_MED_PAID_RFI_PTD
      + py_za_tx_01032004.bal_MLS_AND_VOUCH_NRFI_PTD  + py_za_tx_01032004.bal_MLS_AND_VOUCH_RFI_PTD
      + py_za_tx_01032004.bal_OTHER_TXB_ALL_NRFI_PTD  + py_za_tx_01032004.bal_OTHER_TXB_ALL_RFI_PTD
      + py_za_tx_01032004.bal_OVTM_NRFI_PTD           + py_za_tx_01032004.bal_OVTM_RFI_PTD
      + py_za_tx_01032004.bal_PYM_DBT_NRFI_PTD        + py_za_tx_01032004.bal_PYM_DBT_RFI_PTD
      + py_za_tx_01032004.bal_RES_TRD_NRFI_PTD        + py_za_tx_01032004.bal_RES_TRD_RFI_PTD
      + py_za_tx_01032004.bal_RGT_AST_NRFI_PTD        + py_za_tx_01032004.bal_RGT_AST_RFI_PTD
      + py_za_tx_01032004.bal_TA_NRFI_PTD             + py_za_tx_01032004.bal_TA_RFI_PTD
      + py_za_tx_01032004.bal_TEL_ALL_NRFI_PTD        + py_za_tx_01032004.bal_TEL_ALL_RFI_PTD
      + py_za_tx_01032004.bal_TOOL_ALL_NRFI_PTD       + py_za_tx_01032004.bal_TOOL_ALL_RFI_PTD
      + py_za_tx_01032004.bal_TXB_INC_NRFI_PTD        + py_za_tx_01032004.bal_TXB_INC_RFI_PTD
      + py_za_tx_01032004.bal_TXB_PEN_NRFI_PTD        + py_za_tx_01032004.bal_TXB_PEN_RFI_PTD
      + py_za_tx_01032004.bal_USE_VEH_NRFI_PTD        + py_za_tx_01032004.bal_USE_VEH_RFI_PTD
      );

   hr_utility.set_location('py_za_tx_utl_01032004.TotPrdTxbIncPtd',2);
   RETURN l_tot_txb_prd_inc_ptd;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TotPrdTxbIncPtd',3);
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'TotPrdTxbIncPtd: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
-------------------------------------------------------------------------------
END TotPrdTxbIncPtd;


-------------------------------------------------------------------
-- NegPtd
-------------------------------------------------------------------
FUNCTION NegPtd RETURN BOOLEAN AS
   ------------
   -- Variables
   ------------
   l_Retval BOOLEAN DEFAULT FALSE;

-------------------------------------------------------------------
BEGIN --                   NegPtd - MAIN                         --
-------------------------------------------------------------------
   hr_utility.set_location('py_za_tx_utl_01032004.NegPtd',1);
   -- If any period ptd income value is negative
   -- a site calc has to be done
   py_za_tx_01032004.trc_NorIncPtd :=
     ( py_za_tx_01032004.bal_COMM_NRFI_PTD          + py_za_tx_01032004.bal_COMM_RFI_PTD
     + py_za_tx_01032004.bal_COMP_ALL_NRFI_PTD      + py_za_tx_01032004.bal_COMP_ALL_RFI_PTD
     + py_za_tx_01032004.bal_ENT_ALL_NRFI_PTD       + py_za_tx_01032004.bal_ENT_ALL_RFI_PTD
     + py_za_tx_01032004.bal_IC_PYMNTS_NRFI_PTD     + py_za_tx_01032004.bal_IC_PYMNTS_RFI_PTD
     + py_za_tx_01032004.bal_LB_PYMNTS_NRFI_PTD     + py_za_tx_01032004.bal_LB_PYMNTS_RFI_PTD
     + py_za_tx_01032004.bal_OTHER_TXB_ALL_NRFI_PTD + py_za_tx_01032004.bal_OTHER_TXB_ALL_RFI_PTD
     + py_za_tx_01032004.bal_OVTM_NRFI_PTD          + py_za_tx_01032004.bal_OVTM_RFI_PTD
     + py_za_tx_01032004.bal_RES_TRD_NRFI_PTD       + py_za_tx_01032004.bal_RES_TRD_RFI_PTD
     + py_za_tx_01032004.bal_TXB_INC_NRFI_PTD       + py_za_tx_01032004.bal_TXB_INC_RFI_PTD
     + py_za_tx_01032004.bal_TXB_PEN_NRFI_PTD       + py_za_tx_01032004.bal_TXB_PEN_RFI_PTD
     + py_za_tx_01032004.bal_TEL_ALL_NRFI_PTD       + py_za_tx_01032004.bal_TEL_ALL_RFI_PTD
     + py_za_tx_01032004.bal_TOOL_ALL_NRFI_PTD      + py_za_tx_01032004.bal_TOOL_ALL_RFI_PTD
     );

   py_za_tx_01032004.trc_FrnBenPtd :=
     ( py_za_tx_01032004.bal_AST_PRCHD_RVAL_NRFI_PTD + py_za_tx_01032004.bal_AST_PRCHD_RVAL_RFI_PTD
     + py_za_tx_01032004.bal_BUR_AND_SCH_NRFI_PTD    + py_za_tx_01032004.bal_BUR_AND_SCH_RFI_PTD
     + py_za_tx_01032004.bal_FREE_ACCOM_NRFI_PTD     + py_za_tx_01032004.bal_FREE_ACCOM_RFI_PTD
     + py_za_tx_01032004.bal_FREE_SERV_NRFI_PTD      + py_za_tx_01032004.bal_FREE_SERV_RFI_PTD
     + py_za_tx_01032004.bal_LOW_LOANS_NRFI_PTD      + py_za_tx_01032004.bal_LOW_LOANS_RFI_PTD
     + py_za_tx_01032004.bal_MLS_AND_VOUCH_NRFI_PTD  + py_za_tx_01032004.bal_MLS_AND_VOUCH_RFI_PTD
     + py_za_tx_01032004.bal_MED_PAID_NRFI_PTD       + py_za_tx_01032004.bal_MED_PAID_RFI_PTD
     + py_za_tx_01032004.bal_PYM_DBT_NRFI_PTD        + py_za_tx_01032004.bal_PYM_DBT_RFI_PTD
     + py_za_tx_01032004.bal_RGT_AST_NRFI_PTD        + py_za_tx_01032004.bal_RGT_AST_RFI_PTD
     + py_za_tx_01032004.bal_USE_VEH_NRFI_PTD        + py_za_tx_01032004.bal_USE_VEH_RFI_PTD
     );

   py_za_tx_01032004.trc_TrvAllPtd :=
     ( py_za_tx_01032004.bal_TA_NRFI_PTD + py_za_tx_01032004.bal_TA_RFI_PTD
     );

   py_za_tx_01032004.trc_BonProPtd := py_za_tx_01032004.bal_BP_PTD;

   IF LEAST( py_za_tx_01032004.trc_NorIncPtd
           , py_za_tx_01032004.trc_FrnBenPtd
           , py_za_tx_01032004.trc_TrvAllPtd
           , py_za_tx_01032004.trc_BonProPtd
           ) < 0
   THEN
      hr_utility.set_location('py_za_tx_utl_01032004.NegPtd',2);
      py_za_tx_01032004.trc_NegPtd := TRUE;
   END IF;

   hr_utility.set_location('py_za_tx_utl_01032004.NegPtd',3);
   RETURN py_za_tx_01032004.trc_NegPtd;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'NegPtd: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END NegPtd;

-------------------------------------------------------------------------------
-- LatePayPeriod                                                             --
-------------------------------------------------------------------------------
FUNCTION LatePayPeriod RETURN BOOLEAN AS
-- Variables
   l_CurTxYear NUMBER(15);
BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.LatePayPeriod',1);
-- IF the employee's assignment ended before the current tax year
-- it's a Late Pay Period
   IF py_za_tx_01032004.dbi_ZA_ACT_END_DTE < py_za_tx_01032004.dbi_ZA_TX_YR_STRT THEN

      hr_utility.set_location('py_za_tx_utl_01032004.LatePayPeriod',2);

   -- Valid Late Pay Period?
   --
   -- Current Tax Year
      l_CurTxYear := to_number(to_char(py_za_tx_01032004.dbi_ZA_TX_YR_END,'YYYY'));

      hr_utility.set_location('py_za_tx_utl_01032004.LatePayPeriod',3);

      IF (l_CurTxYear - py_za_tx_01032004.dbi_ZA_ASG_TX_YR) > 1 THEN
         hr_utility.set_location('py_za_tx_utl_01032004.LatePayPeriod',4);
         hr_utility.set_message(801, 'Late Payment Across Two Tax Years!');
         hr_utility.raise_error;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032004.LatePayPeriod',5);
         RETURN TRUE;
      END IF;

   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.LatePayPeriod',6);
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'LatePayPeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END LatePayPeriod;
-------------------------------------------------------------------------------
-- LstPeriod                                                                 --
-------------------------------------------------------------------------------
FUNCTION LstPeriod RETURN BOOLEAN AS
BEGIN
   -- Is this the last period for the tax year
   --
   IF py_za_tx_01032004.dbi_ZA_PAY_PRDS_LFT = 1 THEN
      hr_utility.set_location('py_za_tx_utl_01032004.LstPeriod',1);
      RETURN TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.LstPeriod',2);
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'LstPeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END LstPeriod;
-------------------------------------------------------------------------------
-- EmpTermInPeriod                                                           --
-------------------------------------------------------------------------------
FUNCTION EmpTermInPeriod RETURN BOOLEAN AS

BEGIN
   -- Was the employee terminated in the current period
   --
   IF py_za_tx_01032004.dbi_ZA_ACT_END_DTE BETWEEN py_za_tx_01032004.dbi_ZA_CUR_PRD_STRT_DTE
                                               AND py_za_tx_01032004.dbi_ZA_CUR_PRD_END_DTE
   THEN
      hr_utility.set_location('py_za_tx_utl_01032004.EmpTermInPeriod',1);
      RETURN TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.EmpTermInPeriod',2);
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'EmpTermInPeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END EmpTermInPeriod;
-------------------------------------------------------------------------------
-- EmpTermPrePeriod                                                          --
-------------------------------------------------------------------------------
FUNCTION EmpTermPrePeriod RETURN BOOLEAN AS

BEGIN
   -- Was the employee terminated before the current period
   --
   IF py_za_tx_01032004.dbi_ZA_ACT_END_DTE <= py_za_tx_01032004.dbi_ZA_CUR_PRD_STRT_DTE THEN
      hr_utility.set_location('py_za_tx_utl_01032004.EmpTermPrePeriod',1);
      RETURN TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.EmpTermPrePeriod',2);
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'EmpTermPrePeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END EmpTermPrePeriod;
-------------------------------------------------------------------------------
-- PreErnPeriod                                                              --
-------------------------------------------------------------------------------
FUNCTION PreErnPeriod RETURN BOOLEAN AS

BEGIN
   -- PTD Taxable Income
   --
   py_za_tx_01032004.trc_TxbIncPtd :=
      ( py_za_tx_01032004.bal_AST_PRCHD_RVAL_NRFI_PTD + py_za_tx_01032004.bal_AST_PRCHD_RVAL_RFI_PTD
      + py_za_tx_01032004.bal_BP_PTD
      + py_za_tx_01032004.bal_BUR_AND_SCH_NRFI_PTD    + py_za_tx_01032004.bal_BUR_AND_SCH_RFI_PTD
      + py_za_tx_01032004.bal_COMM_NRFI_PTD           + py_za_tx_01032004.bal_COMM_RFI_PTD
      + py_za_tx_01032004.bal_COMP_ALL_NRFI_PTD       + py_za_tx_01032004.bal_COMP_ALL_RFI_PTD
      + py_za_tx_01032004.bal_ENT_ALL_NRFI_PTD        + py_za_tx_01032004.bal_ENT_ALL_RFI_PTD
      + py_za_tx_01032004.bal_FREE_ACCOM_NRFI_PTD     + py_za_tx_01032004.bal_FREE_ACCOM_RFI_PTD
      + py_za_tx_01032004.bal_FREE_SERV_NRFI_PTD      + py_za_tx_01032004.bal_FREE_SERV_RFI_PTD
      + py_za_tx_01032004.bal_IC_PYMNTS_NRFI_PTD      + py_za_tx_01032004.bal_IC_PYMNTS_RFI_PTD
      + py_za_tx_01032004.bal_LB_PYMNTS_NRFI_PTD      + py_za_tx_01032004.bal_LB_PYMNTS_RFI_PTD
      + py_za_tx_01032004.bal_LOW_LOANS_NRFI_PTD      + py_za_tx_01032004.bal_LOW_LOANS_RFI_PTD
      + py_za_tx_01032004.bal_MLS_AND_VOUCH_NRFI_PTD  + py_za_tx_01032004.bal_MLS_AND_VOUCH_RFI_PTD
      + py_za_tx_01032004.bal_MED_PAID_NRFI_PTD       + py_za_tx_01032004.bal_MED_PAID_RFI_PTD
      + py_za_tx_01032004.bal_OTHER_TXB_ALL_NRFI_PTD  + py_za_tx_01032004.bal_OTHER_TXB_ALL_RFI_PTD
      + py_za_tx_01032004.bal_OVTM_NRFI_PTD           + py_za_tx_01032004.bal_OVTM_RFI_PTD
      + py_za_tx_01032004.bal_PYM_DBT_NRFI_PTD        + py_za_tx_01032004.bal_PYM_DBT_RFI_PTD
      + py_za_tx_01032004.bal_RES_TRD_NRFI_PTD        + py_za_tx_01032004.bal_RES_TRD_RFI_PTD
      + py_za_tx_01032004.bal_RGT_AST_NRFI_PTD        + py_za_tx_01032004.bal_RGT_AST_RFI_PTD
      + py_za_tx_01032004.bal_TXB_INC_NRFI_PTD        + py_za_tx_01032004.bal_TXB_INC_RFI_PTD
      + py_za_tx_01032004.bal_TXB_PEN_NRFI_PTD        + py_za_tx_01032004.bal_TXB_PEN_RFI_PTD
      + py_za_tx_01032004.bal_TEL_ALL_NRFI_PTD        + py_za_tx_01032004.bal_TEL_ALL_RFI_PTD
      + py_za_tx_01032004.bal_TOOL_ALL_NRFI_PTD       + py_za_tx_01032004.bal_TOOL_ALL_RFI_PTD
      + py_za_tx_01032004.bal_TA_NRFI_PTD             + py_za_tx_01032004.bal_TA_RFI_PTD
      + py_za_tx_01032004.bal_USE_VEH_NRFI_PTD        + py_za_tx_01032004.bal_USE_VEH_RFI_PTD
      );

   -- Ptd Annual Bonus
   py_za_tx_01032004.trc_AnnBonPtd := py_za_tx_01032004.bal_AB_NRFI_RUN
                                    + py_za_tx_01032004.bal_AB_RFI_RUN;

   -- Ytd Annual Payments
   py_za_tx_01032004.trc_AnnPymPtd :=
    ( py_za_tx_01032004.bal_AA_PRCHD_RVAL_NRFI_RUN   + py_za_tx_01032004.bal_AA_PRCHD_RVAL_RFI_RUN
    + py_za_tx_01032004.bal_ANN_BUR_AND_SCH_NRFI_RUN + py_za_tx_01032004.bal_ANN_BUR_AND_SCH_RFI_RUN
    + py_za_tx_01032004.bal_ANN_IC_PYMNTS_NRFI_PTD   + py_za_tx_01032004.bal_ANN_IC_PYMNTS_RFI_PTD
    + py_za_tx_01032004.bal_ANN_LB_PYMNTS_NRFI_PTD   + py_za_tx_01032004.bal_ANN_LB_PYMNTS_RFI_PTD
    + py_za_tx_01032004.bal_ANN_PYM_DBT_NRFI_PTD   + py_za_tx_01032004.bal_ANN_PYM_DBT_RFI_PTD
    + py_za_tx_01032004.bal_AC_NRFI_RUN              + py_za_tx_01032004.bal_AC_RFI_RUN
    + py_za_tx_01032004.bal_ANU_FRM_RET_FND_NRFI_RUN + py_za_tx_01032004.bal_ANU_FRM_RET_FND_RFI_RUN
    + py_za_tx_01032004.bal_ARES_TRD_NRFI_RUN        + py_za_tx_01032004.bal_ARES_TRD_RFI_RUN
    + py_za_tx_01032004.bal_PRCH_ANU_TXB_NRFI_RUN    + py_za_tx_01032004.bal_PRCH_ANU_TXB_RFI_RUN
    + py_za_tx_01032004.bal_TXB_AP_NRFI_RUN          + py_za_tx_01032004.bal_TXB_AP_RFI_RUN
    );

   WriteHrTrace('py_za_tx_01032004.trc_TxbIncPtd: '||to_char(py_za_tx_01032004.trc_TxbIncPtd));
   WriteHrTrace('py_za_tx_01032004.trc_AnnBonPtd: '||to_char(py_za_tx_01032004.trc_AnnBonPtd));
   WriteHrTrace('py_za_tx_01032004.trc_AnnPymPtd: '||to_char(py_za_tx_01032004.trc_AnnPymPtd));

   -- Annual Type PTD Income with no Period Type PTD Income
   IF (py_za_tx_01032004.trc_AnnBonPtd + py_za_tx_01032004.trc_AnnPymPtd) <> 0 AND py_za_tx_01032004.trc_TxbIncPtd <= 0 THEN
      hr_utility.set_location('py_za_tx_utl_01032004.PreErnPeriod',1);
      RETURN TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.PreErnPeriod',2);
      RETURN FALSE;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
       py_za_tx_01032004.xpt_Msg := 'PreErnPeriod: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE py_za_tx_01032004.xpt_E;
END PreErnPeriod;
-------------------------------------------------------------------------------
-- SitePeriod                                                                --
-------------------------------------------------------------------------------
FUNCTION SitePeriod RETURN BOOLEAN AS
BEGIN
   IF LstPeriod OR EmpTermInPeriod OR EmpTermPrePeriod THEN
      hr_utility.set_location('py_za_tx_utl_01032004.SitePeriod',1);
      RETURN TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.SitePeriod',2);
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'SitePeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END SitePeriod;
-------------------------------------------------------------------------------
-- PeriodFactor                                                              --
-------------------------------------------------------------------------------
PROCEDURE PeriodFactor AS
   ------------
   -- Variables
   ------------
   l_tot_inc_ytd t_balance;
   l_tot_inc_ptd t_balance;
BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.PeriodFactor',1);

   l_tot_inc_ytd := TotPrdTxbIncYtd;
   l_tot_inc_ptd := TotPrdTxbIncPtd;

   hr_utility.set_location('py_za_tx_utl_01032004.PeriodFactor',2);

   IF py_za_tx_01032004.dbi_ZA_TX_YR_STRT < py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE THEN
      hr_utility.set_location('py_za_tx_utl_01032004.PeriodFactor',3);

      IF l_tot_inc_ytd = l_tot_inc_ptd THEN
         hr_utility.set_location('py_za_tx_utl_01032004.PeriodFactor',3);
         -- i.e. first pay period for the person
         py_za_tx_01032004.trc_PrdFactor :=
         ( py_za_tx_01032004.dbi_ZA_CUR_PRD_END_DTE
         - py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE
         + 1
         )
         /
         ( py_za_tx_01032004.dbi_ZA_CUR_PRD_END_DTE
         - py_za_tx_01032004.dbi_ZA_CUR_PRD_STRT_DTE
         + 1
         );
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032004.PeriodFactor',5);
         py_za_tx_01032004.trc_PrdFactor := 1;
      END IF;

   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.PeriodFactor',6);
      py_za_tx_01032004.trc_PrdFactor := 1;
   END IF;

   WriteHrTrace('dbi_ZA_TX_YR_STRT:       '
      ||to_char(py_za_tx_01032004.dbi_ZA_TX_YR_STRT,'DD/MM/YYYY'));
   WriteHrTrace('dbi_ZA_ACT_STRT_DTE:     '
      ||to_char(py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE,'DD/MM/YYYY'));
   WriteHrTrace('dbi_ZA_CUR_PRD_END_DTE:  '
      ||to_char(py_za_tx_01032004.dbi_ZA_CUR_PRD_END_DTE,'DD/MM/YYYY'));
   WriteHrTrace('dbi_ZA_CUR_PRD_STRT_DTE: '
      ||to_char(py_za_tx_01032004.dbi_ZA_CUR_PRD_STRT_DTE,'DD/MM/YYYY'));
   WriteHrTrace('l_tot_inc_ytd:           '
      ||to_char(l_tot_inc_ytd));
   WriteHrTrace('l_tot_inc_ptd:           '
      ||to_char(l_tot_inc_ptd));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'PeriodFactor: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END PeriodFactor;
-------------------------------------------------------------------------------
-- PossiblePeriodsFactor                                                     --
-------------------------------------------------------------------------------
PROCEDURE PossiblePeriodsFactor AS
BEGIN
   IF py_za_tx_01032004.dbi_ZA_TX_YR_STRT >= py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE THEN
      hr_utility.set_location('py_za_tx_utl_01032004.PossiblePeriodsFactor',1);
      py_za_tx_01032004.trc_PosFactor := 1;
   ELSE
      IF py_za_tx_01032004.trc_PrdFactor <> 1 THEN
         hr_utility.set_location('py_za_tx_utl_01032004.PossiblePeriodsFactor',2);
         --
         py_za_tx_01032004.trc_PosFactor :=
            py_za_tx_01032004.dbi_ZA_DYS_IN_YR
          / ( py_za_tx_01032004.dbi_ZA_TX_YR_END
            - py_za_tx_01032004.dbi_ZA_CUR_PRD_STRT_DTE
            + 1
            );
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032004.PossiblePeriodsFactor',3);
         --
         py_za_tx_01032004.trc_PosFactor :=
            py_za_tx_01032004.dbi_ZA_DYS_IN_YR
          / ( py_za_tx_01032004.dbi_ZA_TX_YR_END
            - py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE
            + 1
            );
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'PossiblePeriodsFactor: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END PossiblePeriodsFactor;
-------------------------------------------------------------------------------
-- Annualise                                                                 --
-------------------------------------------------------------------------------
FUNCTION Annualise
   (p_YtdInc IN NUMBER
   ,p_PtdInc IN NUMBER
   ) RETURN NUMBER
AS
   l_AnnFig1  t_balance;
   l_AnnFig2  t_balance;
   l_AnnFig3  t_balance;
   l_AnnFig4  t_balance;

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.Annualise',1);
   -- 1
   l_AnnFig1 := p_PtdInc / py_za_tx_01032004.trc_PrdFactor;
   -- 2
   l_AnnFig2 := l_AnnFig1 * py_za_tx_01032004.dbi_ZA_PAY_PRDS_LFT;
   -- 3
   l_AnnFig3 := l_AnnFig2 + p_YtdInc - p_PtdInc;
   -- 4
   l_AnnFig4 := l_AnnFig3 * py_za_tx_01032004.trc_PosFactor;
   --
   hr_utility.set_location('py_za_tx_utl_01032004.Annualise',2);
   --
   WriteHrTrace('p_PtdInc:                             '||to_char(p_PtdInc));
   WriteHrTrace('py_za_tx_01032004.trc_PrdFactor:      '||to_char(py_za_tx_01032004.trc_PrdFactor));
   WriteHrTrace('l_AnnFig1:                            '||to_char(l_AnnFig1));
   WriteHrTrace('py_za_tx_01032004.dbi_ZA_PAY_PRDS_LFT:'||to_char(py_za_tx_01032004.dbi_ZA_PAY_PRDS_LFT));
   WriteHrTrace('l_AnnFig2:                            '||to_char(l_AnnFig2));
   WriteHrTrace('p_YtdInc:                             '||to_char(p_YtdInc));
   WriteHrTrace('p_PtdInc:                             '||to_char(p_PtdInc));
   WriteHrTrace('l_AnnFig3:                            '||to_char(l_AnnFig3));
   WriteHrTrace('py_za_tx_01032004.trc_PosFactor:      '||to_char(py_za_tx_01032004.trc_PosFactor));
   WriteHrTrace('l_AnnFig4:                            '||to_char(l_AnnFig4));
   --
   RETURN l_AnnFig4;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'Annualise: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END Annualise;
-------------------------------------------------------------------------------
-- SetRebates                                                                --
-------------------------------------------------------------------------------
PROCEDURE SetRebates AS

-- Variables
   l_65Year DATE;
   l_EndDate per_time_periods.end_date%TYPE;

   l_ZA_TX_YR_END        DATE;
   l_ZA_ADL_TX_RBT       t_balance;
   l_ZA_PRI_TX_RBT       t_balance;
   l_ZA_PRI_TX_THRSHLD   t_balance;
   l_ZA_SC_TX_THRSHLD    t_balance;

BEGIN
   -- Setup the Globals
   IF py_za_tx_01032004.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.SetRebates',1);
      -- Employee Tax Year Start and End Dates
      --
      l_EndDate  := py_za_tx_01032004.dbi_ZA_ASG_TX_YR_END;

      hr_utility.set_location('py_za_tx_utl_01032004.SetRebates',2);

      -- Global Values
      l_ZA_TX_YR_END        := l_EndDate;
      l_ZA_ADL_TX_RBT       := GlbVal('ZA_ADDITIONAL_TAX_REBATE',l_EndDate);
      l_ZA_PRI_TX_RBT       := GlbVal('ZA_PRIMARY_TAX_REBATE',l_EndDate);
      l_ZA_PRI_TX_THRSHLD   := GlbVal('ZA_PRIM_TAX_THRESHOLD',l_EndDate);
      l_ZA_SC_TX_THRSHLD    := GlbVal('ZA_SEC_TAX_THRESHOLD',l_EndDate);
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.SetRebates',3);
      -- Set locals to current values
      l_ZA_TX_YR_END         := py_za_tx_01032004.dbi_ZA_TX_YR_END;
      l_ZA_ADL_TX_RBT        := py_za_tx_01032004.glb_ZA_ADL_TX_RBT;
      l_ZA_PRI_TX_RBT        := py_za_tx_01032004.glb_ZA_PRI_TX_RBT;
      l_ZA_PRI_TX_THRSHLD    := py_za_tx_01032004.glb_ZA_PRI_TX_THRSHLD;
      l_ZA_SC_TX_THRSHLD     := py_za_tx_01032004.glb_ZA_SC_TX_THRSHLD;
   END IF;

   hr_utility.set_location('py_za_tx_utl_01032004.SetRebates',4);

-- Calculate the Rebate and Threshold Values
   hr_utility.set_location('py_za_tx_utl_01032004.SetRebates',5);
   -- Calculate the assignments 65 Year Date
   l_65Year := add_months(py_za_tx_01032004.dbi_PER_DTE_OF_BRTH,780);

   IF l_65Year <= l_ZA_TX_YR_END THEN
      hr_utility.set_location('py_za_tx_utl_01032004.SetRebates',6);
      -- give the extra abatement
      py_za_tx_01032004.trc_Rebate    := l_ZA_PRI_TX_RBT + l_ZA_ADL_TX_RBT;
      py_za_tx_01032004.trc_Threshold := l_ZA_SC_TX_THRSHLD;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.SetRebates',7);
      -- not eligable for extra abatement
      py_za_tx_01032004.trc_Rebate    := l_ZA_PRI_TX_RBT;
      py_za_tx_01032004.trc_Threshold := l_ZA_PRI_TX_THRSHLD;
   END IF;

   WriteHrTrace('l_ZA_TX_YR_END:      '||to_char(l_ZA_TX_YR_END,'DD/MM/YYYY'));
   WriteHrTrace('l_ZA_ADL_TX_RBT:     '||to_char(l_ZA_ADL_TX_RBT));
   WriteHrTrace('l_ZA_PRI_TX_RBT:     '||to_char(l_ZA_PRI_TX_RBT));
   WriteHrTrace('l_ZA_PRI_TX_THRSHLD: '||to_char(l_ZA_PRI_TX_THRSHLD));
   WriteHrTrace('l_ZA_SC_TX_THRSHLD:  '||to_char(l_ZA_SC_TX_THRSHLD));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'SetRebates: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END SetRebates;
-------------------------------------------------------------------------------
-- Abatements
-------------------------------------------------------------------------------
PROCEDURE Abatements AS

-- Variables
   l_65Year DATE;
   l_EndDate per_time_periods.end_date%TYPE;

   l_ZA_TX_YR_END        DATE;
   l_ZA_ARR_PF_AN_MX_ABT t_balance;
   l_ZA_ARR_RA_AN_MX_ABT t_balance;
   l_ZA_PF_AN_MX_ABT     t_balance;
   l_ZA_PF_MX_PRC        t_balance;
   l_ZA_RA_AN_MX_ABT     t_balance;
   l_ZA_RA_MX_PRC        t_balance;

------------------------------------------------------------------------------
BEGIN --                      Abatements - Main                             --
------------------------------------------------------------------------------
-- Initialise the figures needed for the calculation
-- of tax abatements and rebates, based on the
-- calculation type
--
   -------------------------------------------------------------------------
   IF py_za_tx_01032004.trc_CalTyp = 'NorCalc' THEN                       --
   -------------------------------------------------------------------------
   hr_utility.set_location('py_za_tx_utl_01032004.Abatements',1);

   ----------------------
   -- Fixed Pension Basis
   ----------------------
   IF py_za_tx_01032004.dbi_ASG_PEN_BAS = '1' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',2);
   -- Annualise Txb Pkg Cmp
      py_za_tx_01032004.trc_PerTxbPkg := Annualise
        (p_YtdInc => py_za_tx_01032004.bal_TXB_PKG_COMP_YTD
        ,p_PtdInc => py_za_tx_01032004.bal_TXB_PKG_COMP_PTD
        );

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',3);

      py_za_tx_01032004.trc_AnnTxbPkg :=
         py_za_tx_01032004.trc_PerTxbPkg
       + py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_YTD;

   -- Check if there is taxable income in the package
      IF py_za_tx_01032004.trc_AnnTxbPkg <> 0 THEN
      -- Check ASG_SALARY
         IF py_za_tx_01032004.dbi_TOT_PKG = -1 THEN
            hr_utility.set_location('py_za_tx_utl_01032004.Abatements',4);
            py_za_tx_01032004.trc_TotPkg := py_za_tx_01032004.dbi_ASG_SAL
                                          * py_za_tx_01032004.dbi_ASG_SAL_FCTR;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032004.Abatements',5);
            py_za_tx_01032004.trc_TotPkg := py_za_tx_01032004.dbi_TOT_PKG;
         END IF;

      -- Calculate the Taxable Fixed Percentage
         py_za_tx_01032004.trc_TxbFxdPrc :=
          least(py_za_tx_01032004.dbi_FXD_PRC
               * (py_za_tx_01032004.trc_TotPkg
                 /py_za_tx_01032004.trc_AnnTxbPkg
                 )
               ,100)/ 100;

         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',6);

      -- Calculate RFI and NRFI portions
         -- Periodic
         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',7);
         py_za_tx_01032004.trc_PerRFITotPkgPTD := py_za_tx_01032004.bal_TXB_PKG_COMP_PTD
                                                * py_za_tx_01032004.trc_TxbFxdPrc;

         py_za_tx_01032004.trc_PerNRFITotPkgPTD := py_za_tx_01032004.bal_TXB_PKG_COMP_PTD
                                                 - py_za_tx_01032004.trc_PerRFITotPkgPTD;
         -- Annual
         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',8);
         py_za_tx_01032004.trc_AnnRFITotPkgPTD := py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_PTD
                                                * py_za_tx_01032004.trc_TxbFxdPrc;

         py_za_tx_01032004.trc_AnnNRFITotPkgPTD := py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_PTD
                                                 - py_za_tx_01032004.trc_AnnRFITotPkgPTD;
      END IF;

   -- Calculate the Update values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',9);
      py_za_tx_01032004.trc_PerRFITotPkgPTD_Upd := py_za_tx_01032004.trc_PerRFITotPkgPTD
                                                 - py_za_tx_01032004.bal_RFI_TOT_PKG_PTD;

      py_za_tx_01032004.trc_PerNRFITotPkgPTD_Upd := py_za_tx_01032004.trc_PerNRFITotPkgPTD
                                                  - py_za_tx_01032004.bal_NRFI_TOT_PKG_PTD;

      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',10);
      py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd := py_za_tx_01032004.trc_AnnRFITotPkgPTD
                                                 - py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_PTD;

      py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd := py_za_tx_01032004.trc_AnnNRFITotPkgPTD
                                                  - py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_PTD;

   -- Add RFI upd values to RFI balance values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',11);
      py_za_tx_01032004.bal_TOT_RFI_INC_YTD := py_za_tx_01032004.bal_TOT_RFI_INC_YTD
                                             + py_za_tx_01032004.bal_RFI_TOT_PKG_YTD
                                             + py_za_tx_01032004.trc_PerRFITotPkgPTD_Upd;

      py_za_tx_01032004.bal_TOT_RFI_INC_PTD := py_za_tx_01032004.bal_TOT_RFI_INC_PTD
                                             + py_za_tx_01032004.bal_RFI_TOT_PKG_PTD
                                             + py_za_tx_01032004.trc_PerRFITotPkgPTD_Upd;
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',12);
      py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD := py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD
                                                + py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_YTD
                                                + py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd;
   -- Add NRFI upd values to NRFI balance values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',13);
      py_za_tx_01032004.bal_TOT_NRFI_INC_YTD := py_za_tx_01032004.bal_TOT_NRFI_INC_YTD
                                              + py_za_tx_01032004.bal_NRFI_TOT_PKG_YTD
                                              + py_za_tx_01032004.trc_PerNRFITotPkgPTD_Upd;

      py_za_tx_01032004.bal_TOT_NRFI_INC_PTD := py_za_tx_01032004.bal_TOT_NRFI_INC_PTD
                                              + py_za_tx_01032004.bal_NRFI_TOT_PKG_PTD
                                              + py_za_tx_01032004.trc_PerNRFITotPkgPTD_Upd;
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',14);
      py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD := py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD
                                                 + py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_YTD
                                                 + py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',15);
   END IF;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',16);
   -------------------------
   -- Pension Fund Abatement
   -------------------------
      ---------------------
      -- Period Calculation
      ---------------------
      -- Annualise Period Pension Fund Contributions
      py_za_tx_01032004.trc_PerPenFnd := Annualise
                 (p_YtdInc => py_za_tx_01032004.bal_CUR_PF_YTD
                 ,p_PtdInc => py_za_tx_01032004.bal_CUR_PF_PTD
                 );
      -- Annualise Period RFIable Contributions
      py_za_tx_01032004.trc_PerRfiCon := Annualise
                 (p_ytdInc => py_za_tx_01032004.bal_TOT_RFI_INC_YTD
                 ,p_PtdInc => py_za_tx_01032004.bal_TOT_RFI_INC_PTD
                 );

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',17);

      ---------------------
      -- Annual Calculation
      ---------------------
      -- Annual Pension Fund Contribution
      py_za_tx_01032004.trc_AnnPenFnd :=
         py_za_tx_01032004.trc_PerPenFnd
       + py_za_tx_01032004.bal_ANN_PF_YTD;
      -- Annual Rfi Contribution
      py_za_tx_01032004.trc_AnnRfiCon :=
         py_za_tx_01032004.trc_PerRfiCon
       + py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD;

   --------------------------------
   -- Arrear Pension Fund Abatement
   --------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',18);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrPenFnd :=
         py_za_tx_01032004.bal_EXC_ARR_PEN_ITD;

      ----------
      -- Current
      ----------
      py_za_tx_01032004.trc_PerArrPenFnd :=
         py_za_tx_01032004.trc_PerArrPenFnd
       + Annualise
         ( p_YtdInc => py_za_tx_01032004.bal_ARR_PF_YTD
         , p_PtdInc => py_za_tx_01032004.bal_ARR_PF_PTD
         );
      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrPenFnd :=
           py_za_tx_01032004.trc_PerArrPenFnd
         + py_za_tx_01032004.bal_ANN_ARR_PF_YTD;

   -------------------------------
   -- Retirement Annuity Abatement
   -------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',19);

      -------------
      -- Current RA
      -------------
      py_za_tx_01032004.trc_PerRetAnu :=
         Annualise
            ( p_YtdInc => py_za_tx_01032004.bal_CUR_RA_YTD
            , p_PtdInc => py_za_tx_01032004.bal_CUR_RA_PTD
            );
      ---------------------
      -- Current NRFI Contr
      ---------------------

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',20);
      py_za_tx_01032004.trc_PerNrfiCon :=
            Annualise
               ( p_YtdInc => py_za_tx_01032004.bal_TOT_NRFI_INC_YTD
               , p_PtdInc => py_za_tx_01032004.bal_TOT_NRFI_INC_PTD
               );


      ------------
      -- Annual RA
      ------------
      py_za_tx_01032004.trc_AnnRetAnu :=
         py_za_tx_01032004.trc_PerRetAnu
       + py_za_tx_01032004.bal_ANN_RA_YTD;


      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',21);
      py_za_tx_01032004.trc_AnnNrfiCon :=
            py_za_tx_01032004.trc_PerNrfiCon
          + py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD;


   --------------------------------------
   -- Arrear Retirement Annuity Abatement
   --------------------------------------
         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',22);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrRetAnu :=
         py_za_tx_01032004.bal_EXC_ARR_RA_ITD;
      ----------
      -- Current
      ----------
      py_za_tx_01032004.trc_PerArrRetAnu :=
         py_za_tx_01032004.trc_PerArrRetAnu
       + Annualise
            ( p_YtdInc => py_za_tx_01032004.bal_ARR_RA_YTD
            , p_PtdInc => py_za_tx_01032004.bal_ARR_RA_PTD
            );
      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrRetAnu :=
         py_za_tx_01032004.trc_PerArrRetAnu
       + py_za_tx_01032004.bal_ANN_ARR_RA_YTD;

   ------------------------
   -- Medical Aid Abatement
   ------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',23);
      py_za_tx_01032004.trc_MedAidAbm :=
         Annualise
            ( p_YtdInc => py_za_tx_01032004.bal_MED_CONTR_YTD
            , p_PtdInc => py_za_tx_01032004.bal_MED_CONTR_PTD
            );

   -------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.trc_CalTyp IN ('YtdCalc','SitCalc') THEN       --
   -------------------------------------------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',24);

   ----------------------
   -- Fixed Pension Basis
   ----------------------
   IF py_za_tx_01032004.dbi_ASG_PEN_BAS = '1' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',25);
   -- Annualise Txb Pkg Cmp
      py_za_tx_01032004.trc_PerTxbPkg :=
         py_za_tx_01032004.bal_TXB_PKG_COMP_YTD
       * py_za_tx_01032004.trc_SitFactor;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',26);

      py_za_tx_01032004.trc_AnnTxbPkg :=
         py_za_tx_01032004.trc_PerTxbPkg
       + py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_YTD;

   -- Check if there is taxable income in the package
      IF py_za_tx_01032004.trc_AnnTxbPkg <> 0 THEN
      -- Check ASG_SALARY
         IF py_za_tx_01032004.dbi_TOT_PKG = -1 THEN
            hr_utility.set_location('py_za_tx_utl_01032004.Abatements',27);
            py_za_tx_01032004.trc_TotPkg := py_za_tx_01032004.dbi_ASG_SAL
                                          * py_za_tx_01032004.dbi_ASG_SAL_FCTR;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032004.Abatements',28);
            py_za_tx_01032004.trc_TotPkg := py_za_tx_01032004.dbi_TOT_PKG;
         END IF;

      -- Calculate the Taxable Fixed Percentage
         py_za_tx_01032004.trc_TxbFxdPrc :=
          least(py_za_tx_01032004.dbi_FXD_PRC
               * (py_za_tx_01032004.trc_TotPkg
                 /py_za_tx_01032004.trc_AnnTxbPkg
                 )
               ,100)/ 100;

         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',29);

      -- Calculate RFI and NRFI portions
         -- Periodic
         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',30);
         py_za_tx_01032004.trc_PerRFITotPkgPTD := py_za_tx_01032004.bal_TXB_PKG_COMP_PTD
                                                * py_za_tx_01032004.trc_TxbFxdPrc;

         py_za_tx_01032004.trc_PerNRFITotPkgPTD := py_za_tx_01032004.bal_TXB_PKG_COMP_PTD
                                                 - py_za_tx_01032004.trc_PerRFITotPkgPTD;
         -- Annual
         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',31);
         py_za_tx_01032004.trc_AnnRFITotPkgPTD := py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_PTD
                                                * py_za_tx_01032004.trc_TxbFxdPrc;

         py_za_tx_01032004.trc_AnnNRFITotPkgPTD := py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_PTD
                                                 - py_za_tx_01032004.trc_AnnRFITotPkgPTD;
      END IF;

   -- Calculate the Update values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',32);
      py_za_tx_01032004.trc_PerRFITotPkgPTD_Upd := py_za_tx_01032004.trc_PerRFITotPkgPTD
                                                 - py_za_tx_01032004.bal_RFI_TOT_PKG_PTD;

      py_za_tx_01032004.trc_PerNRFITotPkgPTD_Upd := py_za_tx_01032004.trc_PerNRFITotPkgPTD
                                                  - py_za_tx_01032004.bal_NRFI_TOT_PKG_PTD;

      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',33);
      py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd := py_za_tx_01032004.trc_AnnRFITotPkgPTD
                                                 - py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_PTD;

      py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd := py_za_tx_01032004.trc_AnnNRFITotPkgPTD
                                                  - py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_PTD;

   -- Add RFI upd values to RFI balance values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',34);
      py_za_tx_01032004.bal_TOT_RFI_INC_YTD := py_za_tx_01032004.bal_TOT_RFI_INC_YTD
                                             + py_za_tx_01032004.bal_RFI_TOT_PKG_YTD
                                             + py_za_tx_01032004.trc_PerRFITotPkgPTD_Upd;
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',35);
      py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD := py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD
                                                + py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_YTD
                                                + py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd;
   -- Add NRFI upd values to NRFI balance values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',36);
      py_za_tx_01032004.bal_TOT_NRFI_INC_YTD := py_za_tx_01032004.bal_TOT_NRFI_INC_YTD
                                              + py_za_tx_01032004.bal_NRFI_TOT_PKG_YTD
                                              + py_za_tx_01032004.trc_PerNRFITotPkgPTD_Upd;
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',37);
      py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD := py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD
                                                 + py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_YTD
                                                 + py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',38);
   END IF;

   -------------------------
   -- Pension Fund Abatement
   -------------------------
      ---------------------
      -- Period Calculation
      ---------------------
      -- Annualise Period Pension Fund Contribution
      py_za_tx_01032004.trc_PerPenFnd :=
         py_za_tx_01032004.bal_CUR_PF_YTD
       * py_za_tx_01032004.trc_SitFactor;
      -- Annualise Period Rfiable Contributions
      py_za_tx_01032004.trc_PerRfiCon :=
         py_za_tx_01032004.bal_TOT_RFI_INC_YTD
       * py_za_tx_01032004.trc_SitFactor;
      ---------------------
      -- Annual Calculation
      ---------------------
      -- Annual Pension Fund Contribution
      py_za_tx_01032004.trc_AnnPenFnd :=
         py_za_tx_01032004.trc_PerPenFnd
       + py_za_tx_01032004.bal_ANN_PF_YTD;
      -- Annual Rfi Contribution
      py_za_tx_01032004.trc_AnnRfiCon :=
         py_za_tx_01032004.trc_PerRfiCon
       + py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',39);

   --------------------------------
   -- Arrear Pension Fund Abatement
   --------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',40);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrPenFnd :=
         py_za_tx_01032004.bal_EXC_ARR_PEN_ITD;

      ----------
      -- Current
      ----------
      py_za_tx_01032004.trc_PerArrPenFnd :=
          py_za_tx_01032004.trc_PerArrPenFnd
      + ( py_za_tx_01032004.bal_ARR_PF_YTD
        * py_za_tx_01032004.trc_SitFactor
        );
      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrPenFnd :=
           py_za_tx_01032004.trc_PerArrPenFnd
         + py_za_tx_01032004.bal_ANN_ARR_PF_YTD;


   -------------------------------
   -- Retirement Annuity Abatement
   -------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',41);

      -------------
      -- Current RA
      -------------
      -- Calculate RA Contribution
      py_za_tx_01032004.trc_PerRetAnu :=
         py_za_tx_01032004.bal_CUR_RA_YTD
       * py_za_tx_01032004.trc_SitFactor;
      ---------------------
      -- Current NRFI Contr
      ---------------------

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',42);
      py_za_tx_01032004.trc_PerNrfiCon :=
            py_za_tx_01032004.bal_TOT_NRFI_INC_YTD
          * py_za_tx_01032004.trc_SitFactor;

      ------------
      -- Annual RA
      ------------
      py_za_tx_01032004.trc_AnnRetAnu :=
         py_za_tx_01032004.trc_PerRetAnu
       + py_za_tx_01032004.bal_ANN_RA_YTD;


      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',43);
      py_za_tx_01032004.trc_AnnNrfiCon :=
            py_za_tx_01032004.trc_PerNrfiCon
          + py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD;


   --------------------------------------
   -- Arrear Retirement Annuity Abatement
   --------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',44);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrRetAnu :=
         py_za_tx_01032004.bal_EXC_ARR_RA_ITD;
      ----------
      -- Current
      ----------
      py_za_tx_01032004.trc_PerArrRetAnu :=
         py_za_tx_01032004.trc_PerArrRetAnu
       + ( py_za_tx_01032004.bal_ARR_RA_YTD
         * py_za_tx_01032004.trc_SitFactor
         );
      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrRetAnu :=
         py_za_tx_01032004.trc_PerArrRetAnu
       + py_za_tx_01032004.bal_ANN_ARR_RA_YTD;

   ------------------------
   -- Medical Aid Abatement
   ------------------------
      py_za_tx_01032004.trc_MedAidAbm :=
         py_za_tx_01032004.bal_MED_CONTR_YTD
       * py_za_tx_01032004.trc_SitFactor;

   hr_utility.set_location('py_za_tx_utl_01032004.Abatements',45);

   -------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.trc_CalTyp = 'CalCalc' THEN                    --
   -------------------------------------------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',46);

   ----------------------
   -- Fixed Pension Basis
   ----------------------
   IF py_za_tx_01032004.dbi_ASG_PEN_BAS = '1' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',47);
   -- Annualise Txb Pkg Cmp
      py_za_tx_01032004.trc_PerTxbPkg :=
         py_za_tx_01032004.bal_TXB_PKG_COMP_CYTD
       * py_za_tx_01032004.trc_SitFactor;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',48);

      py_za_tx_01032004.trc_AnnTxbPkg :=
         py_za_tx_01032004.trc_PerTxbPkg
       + py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_YTD;

   -- Check if there is taxable income in the package
      IF py_za_tx_01032004.trc_AnnTxbPkg <> 0 THEN
      -- Check ASG_SALARY
         IF py_za_tx_01032004.dbi_TOT_PKG = -1 THEN
            hr_utility.set_location('py_za_tx_utl_01032004.Abatements',49);
            py_za_tx_01032004.trc_TotPkg := py_za_tx_01032004.dbi_ASG_SAL
                                          * py_za_tx_01032004.dbi_ASG_SAL_FCTR;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032004.Abatements',50);
            py_za_tx_01032004.trc_TotPkg := py_za_tx_01032004.dbi_TOT_PKG;
         END IF;

      -- Calculate the Taxable Fixed Percentage
         py_za_tx_01032004.trc_TxbFxdPrc :=
          least(py_za_tx_01032004.dbi_FXD_PRC
               * (py_za_tx_01032004.trc_TotPkg
                 /py_za_tx_01032004.trc_AnnTxbPkg
                 )
               ,100)/ 100;

         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',51);

      -- Calculate RFI and NRFI portions
         -- Annual
         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',52);
         py_za_tx_01032004.trc_AnnRFITotPkgPTD := py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_PTD
                                                * py_za_tx_01032004.trc_TxbFxdPrc;

         py_za_tx_01032004.trc_AnnNRFITotPkgPTD := py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_PTD
                                                 - py_za_tx_01032004.trc_AnnRFITotPkgPTD;
      END IF;

   -- Calculate the Update values
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',53);
      py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd := py_za_tx_01032004.trc_AnnRFITotPkgPTD
                                                 - py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_PTD;

      py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd := py_za_tx_01032004.trc_AnnNRFITotPkgPTD
                                                  - py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_PTD;

   -- Add RFI upd values to RFI balance values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',54);
      py_za_tx_01032004.bal_TOT_RFI_INC_CYTD := py_za_tx_01032004.bal_TOT_RFI_INC_CYTD
                                              + py_za_tx_01032004.bal_RFI_TOT_PKG_CYTD;
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',55);
      py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD := py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD
                                                + py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_YTD
                                                + py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd;
   -- Add NRFI upd values to NRFI balance values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',56);
      py_za_tx_01032004.bal_TOT_NRFI_INC_CYTD := py_za_tx_01032004.bal_TOT_NRFI_INC_CYTD
                                               + py_za_tx_01032004.bal_NRFI_TOT_PKG_CYTD;
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',57);
      py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD := py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD
                                                 + py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_YTD
                                                 + py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',58);
   END IF;

   -------------------------
   -- Pension Fund Abatement
   -------------------------
      ---------------------
      -- Period Calculation
      ---------------------
      -- Annualise Period Pension Fund Contribution
      py_za_tx_01032004.trc_PerPenFnd :=
         py_za_tx_01032004.bal_CUR_PF_CYTD
       * py_za_tx_01032004.trc_SitFactor;
      -- Annualise Period Rfiable Contributions
      py_za_tx_01032004.trc_PerRfiCon :=
         py_za_tx_01032004.bal_TOT_RFI_INC_CYTD
       * py_za_tx_01032004.trc_SitFactor;
      ---------------------
      -- Annual Calculation
      ---------------------
      -- Annual Pension Fund Contribution
      py_za_tx_01032004.trc_AnnPenFnd :=
         py_za_tx_01032004.trc_PerPenFnd
       + py_za_tx_01032004.bal_ANN_PF_YTD;
      -- Annual Rfi Contribution
      py_za_tx_01032004.trc_AnnRfiCon :=
         py_za_tx_01032004.trc_PerRfiCon
       + py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD;

   --------------------------------
   -- Arrear Pension Fund Abatement
   --------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',59);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrPenFnd :=
         py_za_tx_01032004.bal_EXC_ARR_PEN_ITD;
      ------------------------------------
      -- Current/Annual based on frequency
      ------------------------------------
      py_za_tx_01032004.trc_PerArrPenFnd :=
          py_za_tx_01032004.trc_PerArrPenFnd
      + ( py_za_tx_01032004.bal_ARR_PF_CYTD
        * py_za_tx_01032004.trc_SitFactor
        );
      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrPenFnd :=
           py_za_tx_01032004.trc_PerArrPenFnd
         + py_za_tx_01032004.bal_ANN_ARR_PF_YTD;

   -------------------------------
   -- Retirement Annuity Abatement
   -------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',60);

      -------------
      -- Current RA
      -------------
      -- Calculate RA Contribution
      py_za_tx_01032004.trc_PerRetAnu :=
         py_za_tx_01032004.bal_CUR_RA_CYTD
       * py_za_tx_01032004.trc_SitFactor;
      ---------------------
      -- Current NRFI Contr
      ---------------------

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',61);
      py_za_tx_01032004.trc_PerNrfiCon :=
            py_za_tx_01032004.bal_TOT_NRFI_INC_CYTD
          * py_za_tx_01032004.trc_SitFactor;

      ------------
      -- Annual RA
      ------------
      py_za_tx_01032004.trc_AnnRetAnu :=
         py_za_tx_01032004.trc_PerRetAnu
       + py_za_tx_01032004.bal_ANN_RA_YTD;


      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',62);
      py_za_tx_01032004.trc_AnnNrfiCon :=
            py_za_tx_01032004.trc_PerNrfiCon
          + py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD;


   --------------------------------------
   -- Arrear Retirement Annuity Abatement
   --------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',63);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrRetAnu := py_za_tx_01032004.bal_EXC_ARR_RA_ITD;
      ----------
      -- Current
      ----------
      py_za_tx_01032004.trc_PerArrRetAnu :=
         py_za_tx_01032004.trc_PerArrRetAnu
       + ( py_za_tx_01032004.bal_ARR_RA_CYTD
         * py_za_tx_01032004.trc_SitFactor
         );
      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrRetAnu :=
         py_za_tx_01032004.trc_PerArrRetAnu
       + py_za_tx_01032004.bal_ANN_ARR_RA_YTD;

   ------------------------
   -- Medical Aid Abatement
   ------------------------
      py_za_tx_01032004.trc_MedAidAbm :=
         py_za_tx_01032004.bal_MED_CONTR_CYTD
       * py_za_tx_01032004.trc_SitFactor;

   -------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.trc_CalTyp IN ('BasCalc') THEN       --
   -------------------------------------------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',64);

   ----------------------
   -- Fixed Pension Basis
   ----------------------
   IF py_za_tx_01032004.dbi_ASG_PEN_BAS = '1' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',65);
   -- Annualise Txb Pkg Cmp
      py_za_tx_01032004.trc_PerTxbPkg :=
         py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_YTD
       * py_za_tx_01032004.dbi_ZA_PAY_PRDS_PER_YR;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',66);

      py_za_tx_01032004.trc_AnnTxbPkg :=
         py_za_tx_01032004.trc_PerTxbPkg
       + py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_YTD;

   -- Check if there is taxable income in the package
      IF py_za_tx_01032004.trc_AnnTxbPkg <> 0 THEN
      -- Check ASG_SALARY
         IF py_za_tx_01032004.dbi_TOT_PKG = -1 THEN
            hr_utility.set_location('py_za_tx_utl_01032004.Abatements',67);
            py_za_tx_01032004.trc_TotPkg := py_za_tx_01032004.dbi_ASG_SAL
                                          * py_za_tx_01032004.dbi_ASG_SAL_FCTR;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032004.Abatements',68);
            py_za_tx_01032004.trc_TotPkg := py_za_tx_01032004.dbi_TOT_PKG;
         END IF;

      -- Calculate the Taxable Fixed Percentage
         py_za_tx_01032004.trc_TxbFxdPrc :=
          least(py_za_tx_01032004.dbi_FXD_PRC
               * (py_za_tx_01032004.trc_TotPkg
                 /py_za_tx_01032004.trc_AnnTxbPkg
                 )
               ,100)/ 100;

         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',69);

      -- Calculate RFI and NRFI portions
         -- Annual
         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',70);
         py_za_tx_01032004.trc_AnnRFITotPkgPTD := py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_PTD
                                                * py_za_tx_01032004.trc_TxbFxdPrc;

         py_za_tx_01032004.trc_AnnNRFITotPkgPTD := py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_PTD
                                                 - py_za_tx_01032004.trc_AnnRFITotPkgPTD;
      END IF;

   -- Calculate the Update values
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',71);
      py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd := py_za_tx_01032004.trc_AnnRFITotPkgPTD
                                                 - py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_PTD;

      py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd := py_za_tx_01032004.trc_AnnNRFITotPkgPTD
                                                  - py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_PTD;
   -- Add RFI upd values to RFI balance values
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',72);
      py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD := py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD
                                                + py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_YTD
                                                + py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd;
   -- Add NRFI upd values to NRFI balance values
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',73);
      py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD := py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD
                                                 + py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_YTD
                                                 + py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',74);
   END IF;

   -------------------------
   -- Pension Fund Abatement
   -------------------------
      ---------------------
      -- Annual Calculation
      ---------------------
      -- Annual Pension Fund Contribution
      py_za_tx_01032004.trc_AnnPenFnd := py_za_tx_01032004.bal_ANN_PF_YTD;
      -- Annual Rfi Contribution
      py_za_tx_01032004.trc_AnnRfiCon := py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',75);

   --------------------------------
   -- Arrear Pension Fund Abatement
   --------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',76);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrPenFnd := py_za_tx_01032004.bal_EXC_ARR_PEN_ITD;

      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrPenFnd := py_za_tx_01032004.trc_PerArrPenFnd
                                          + py_za_tx_01032004.bal_ANN_ARR_PF_YTD;


   -------------------------------
   -- Retirement Annuity Abatement
   -------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',77);

      ------------
      -- Annual RA
      ------------
      py_za_tx_01032004.trc_AnnRetAnu := py_za_tx_01032004.bal_ANN_RA_YTD;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',78);
      py_za_tx_01032004.trc_AnnNrfiCon := py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD;


   --------------------------------------
   -- Arrear Retirement Annuity Abatement
   --------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',79);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrRetAnu := py_za_tx_01032004.bal_EXC_ARR_RA_ITD;

      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrRetAnu := py_za_tx_01032004.trc_PerArrRetAnu
                                          + py_za_tx_01032004.bal_ANN_ARR_RA_YTD;

   ------------------------
   -- Medical Aid Abatement
   ------------------------
      py_za_tx_01032004.trc_MedAidAbm := 0;

   hr_utility.set_location('py_za_tx_utl_01032004.Abatements',80);


   -------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.trc_CalTyp = 'SeaCalc' THEN                    --
   -------------------------------------------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',81);
   -------------------------
   -- Pension Fund Abatement
   -------------------------
      ---------------------
      -- Period Calculation
      ---------------------
      -- Annualise Period Pension Fund Contribution
      py_za_tx_01032004.trc_PerPenFnd :=
         py_za_tx_01032004.bal_CUR_PF_RUN
       * py_za_tx_01032004.trc_SitFactor;
      -- Annualise Period Rfiable Contributions
      py_za_tx_01032004.trc_PerRfiCon :=
         py_za_tx_01032004.bal_TOT_RFI_INC_RUN
       * py_za_tx_01032004.trc_SitFactor;
      ---------------------
      -- Annual Calculation
      ---------------------
      -- Annual Pension Fund Contribution
      py_za_tx_01032004.trc_AnnPenFnd :=
         py_za_tx_01032004.trc_PerPenFnd
       + py_za_tx_01032004.bal_ANN_PF_RUN;
      -- Annual Rfi Contribution
      py_za_tx_01032004.trc_AnnRfiCon :=
         py_za_tx_01032004.trc_PerRfiCon
       + py_za_tx_01032004.bal_TOT_RFI_AN_INC_RUN;

   --------------------------------
   -- Arrear Pension Fund Abatement
   --------------------------------
      py_za_tx_01032004.trc_PerArrPenFnd := 0;
      py_za_tx_01032004.trc_AnnArrPenFnd := 0;

   -------------------------------
   -- Retirement Annuity Abatement
   -------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',82);

      -------------
      -- Current RA
      -------------
      -- Calculate RA Contribution
      py_za_tx_01032004.trc_PerRetAnu :=
         py_za_tx_01032004.bal_CUR_RA_RUN
       * py_za_tx_01032004.trc_SitFactor;
      ---------------------
      -- Current NRFI Contr
      ---------------------

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',83);
      py_za_tx_01032004.trc_PerNrfiCon :=
            py_za_tx_01032004.bal_TOT_NRFI_INC_RUN
          * py_za_tx_01032004.trc_SitFactor;


      ------------
      -- Annual RA
      ------------
      py_za_tx_01032004.trc_AnnRetAnu :=
         py_za_tx_01032004.trc_PerRetAnu
       + py_za_tx_01032004.bal_ANN_RA_RUN;


      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',84);
      py_za_tx_01032004.trc_AnnNrfiCon :=
            py_za_tx_01032004.trc_PerNrfiCon
          + py_za_tx_01032004.bal_TOT_NRFI_AN_INC_RUN;


   ----------------------------
   -- Arrear Retirement Annuity
   ----------------------------
      py_za_tx_01032004.trc_PerArrRetAnu := 0;
      py_za_tx_01032004.trc_AnnArrRetAnu := 0;

   ------------------------
   -- Medical Aid Abatement
   ------------------------
      py_za_tx_01032004.trc_MedAidAbm :=
         py_za_tx_01032004.bal_MED_CONTR_RUN
       * py_za_tx_01032004.trc_SitFactor;

   -------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.trc_CalTyp = 'LteCalc' THEN                    --
   -------------------------------------------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',85);

   ----------------------
   -- Fixed Pension Basis
   ----------------------
   IF py_za_tx_01032004.dbi_ASG_PEN_BAS = '1' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',86);
   -- Annualise Txb Pkg Cmp
      py_za_tx_01032004.trc_PerTxbPkg := py_za_tx_01032004.bal_TXB_PKG_COMP_YTD;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',87);

      py_za_tx_01032004.trc_AnnTxbPkg :=
         py_za_tx_01032004.trc_PerTxbPkg
       + py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_YTD;

   -- Check if there is taxable income in the package
      IF py_za_tx_01032004.trc_AnnTxbPkg <> 0 THEN
      -- Check ASG_SALARY
         IF py_za_tx_01032004.dbi_TOT_PKG = -1 THEN
            hr_utility.set_location('py_za_tx_utl_01032004.Abatements',88);
            py_za_tx_01032004.trc_TotPkg := py_za_tx_01032004.dbi_ASG_SAL
                                          * py_za_tx_01032004.dbi_ASG_SAL_FCTR;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032004.Abatements',89);
            py_za_tx_01032004.trc_TotPkg := py_za_tx_01032004.dbi_TOT_PKG;
         END IF;

      -- Calculate the Taxable Fixed Percentage
         py_za_tx_01032004.trc_TxbFxdPrc :=
          least(py_za_tx_01032004.dbi_FXD_PRC
               * (py_za_tx_01032004.trc_TotPkg
                 /py_za_tx_01032004.trc_AnnTxbPkg
                 )
               ,100)/ 100;

         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',90);

      -- Calculate RFI and NRFI portions
         -- Periodic
         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',91);
         py_za_tx_01032004.trc_PerRFITotPkgPTD := py_za_tx_01032004.bal_TXB_PKG_COMP_PTD
                                                * py_za_tx_01032004.trc_TxbFxdPrc;

         py_za_tx_01032004.trc_PerNRFITotPkgPTD := py_za_tx_01032004.bal_TXB_PKG_COMP_PTD
                                                 - py_za_tx_01032004.trc_PerRFITotPkgPTD;
         -- Annual
         hr_utility.set_location('py_za_tx_utl_01032004.Abatements',92);
         py_za_tx_01032004.trc_AnnRFITotPkgPTD := py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_PTD
                                                * py_za_tx_01032004.trc_TxbFxdPrc;

         py_za_tx_01032004.trc_AnnNRFITotPkgPTD := py_za_tx_01032004.bal_ANN_TXB_PKG_COMP_PTD
                                                 - py_za_tx_01032004.trc_AnnRFITotPkgPTD;
      END IF;

   -- Calculate the Update values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',93);
      py_za_tx_01032004.trc_PerRFITotPkgPTD_Upd := py_za_tx_01032004.trc_PerRFITotPkgPTD
                                                 - py_za_tx_01032004.bal_RFI_TOT_PKG_PTD;

      py_za_tx_01032004.trc_PerNRFITotPkgPTD_Upd := py_za_tx_01032004.trc_PerNRFITotPkgPTD
                                                  - py_za_tx_01032004.bal_NRFI_TOT_PKG_PTD;

      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',94);
      py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd := py_za_tx_01032004.trc_AnnRFITotPkgPTD
                                                 - py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_PTD;

      py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd := py_za_tx_01032004.trc_AnnNRFITotPkgPTD
                                                  - py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_PTD;

   -- Add RFI upd values to RFI balance values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',95);
      py_za_tx_01032004.bal_TOT_RFI_INC_YTD := py_za_tx_01032004.bal_TOT_RFI_INC_YTD
                                             + py_za_tx_01032004.bal_RFI_TOT_PKG_YTD
                                             + py_za_tx_01032004.trc_PerRFITotPkgPTD_Upd;
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',96);
      py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD := py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD
                                                + py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_YTD
                                                + py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd;
   -- Add NRFI upd values to NRFI balance values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',97);
      py_za_tx_01032004.bal_TOT_NRFI_INC_YTD := py_za_tx_01032004.bal_TOT_NRFI_INC_YTD
                                              + py_za_tx_01032004.bal_NRFI_TOT_PKG_YTD
                                              + py_za_tx_01032004.trc_PerNRFITotPkgPTD_Upd;
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',98);
      py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD := py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD
                                                 + py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_YTD
                                                 + py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',99);
   END IF;

   -------------------------
   -- Pension Fund Abatement
   -------------------------
      ---------------------
      -- Period Calculation
      ---------------------
      -- Annualise Period Pension Fund Contribution
      py_za_tx_01032004.trc_PerPenFnd :=
         py_za_tx_01032004.bal_CUR_PF_YTD;
      -- Annualise Period Rfiable Contributions
      py_za_tx_01032004.trc_PerRfiCon :=
         py_za_tx_01032004.bal_TOT_RFI_INC_YTD;
      ---------------------
      -- Annual Calculation
      ---------------------
      -- Annual Pension Fund Contribution
      py_za_tx_01032004.trc_AnnPenFnd :=
         py_za_tx_01032004.trc_PerPenFnd
       + py_za_tx_01032004.bal_ANN_PF_YTD;
      -- Annual Rfi Contribution
      py_za_tx_01032004.trc_AnnRfiCon :=
         py_za_tx_01032004.trc_PerRfiCon
       + py_za_tx_01032004.bal_TOT_RFI_AN_INC_YTD;

   --------------------------------
   -- Arrear Pension Fund Abatement
   --------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',100);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrPenFnd :=
         py_za_tx_01032004.bal_EXC_ARR_PEN_ITD;
      ----------
      -- Current
      ----------
      py_za_tx_01032004.trc_PerArrPenFnd :=
         py_za_tx_01032004.trc_PerArrPenFnd
       + py_za_tx_01032004.bal_ARR_PF_YTD;
       ---------
       -- Annual
       ---------
       py_za_tx_01032004.trc_AnnArrPenFnd :=
          py_za_tx_01032004.trc_PerArrPenFnd
        + py_za_tx_01032004.bal_ANN_ARR_PF_YTD;

   -------------------------------
   -- Retirement Annuity Abatement
   -------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',101);
      -------------
      -- Current RA
      -------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',102);
      -- Calculate RA Contribution
      py_za_tx_01032004.trc_PerRetAnu :=
         py_za_tx_01032004.bal_CUR_RA_YTD;
      ---------------------
      -- Current NRFI Contr
      ---------------------

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',103);
      py_za_tx_01032004.trc_PerNrfiCon :=
            py_za_tx_01032004.bal_TOT_NRFI_INC_YTD;


      ------------
      -- Annual RA
      ------------
      py_za_tx_01032004.trc_AnnRetAnu :=
         py_za_tx_01032004.trc_PerRetAnu
       + py_za_tx_01032004.bal_ANN_RA_YTD;


      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',104);
      py_za_tx_01032004.trc_AnnNrfiCon :=
            py_za_tx_01032004.trc_PerNrfiCon
          + py_za_tx_01032004.bal_TOT_NRFI_AN_INC_YTD;


   --------------------------------------
   -- Arrear Retirement Annuity Abatement
   --------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',105);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrRetAnu :=
         py_za_tx_01032004.bal_EXC_ARR_RA_ITD;
      ----------
      -- Current
      ----------
      py_za_tx_01032004.trc_PerArrRetAnu :=
         py_za_tx_01032004.trc_PerArrRetAnu
       + py_za_tx_01032004.bal_ARR_RA_YTD;
      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrRetAnu :=
         py_za_tx_01032004.trc_PerArrRetAnu
       + py_za_tx_01032004.bal_ANN_ARR_RA_YTD;

   ------------------------
   -- Medical Aid Abatement
   ------------------------
      py_za_tx_01032004.trc_MedAidAbm :=
         py_za_tx_01032004.bal_MED_CONTR_YTD;

   -------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.trc_CalTyp = 'PstCalc' THEN                    --
   -------------------------------------------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',106);

   ----------------------
   -- Fixed Pension Basis
   ----------------------
   IF py_za_tx_01032004.dbi_ASG_PEN_BAS = '1' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',107);

   -- Add RFI upd values to RFI balance values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',108);
      py_za_tx_01032004.bal_TOT_RFI_INC_PTD := py_za_tx_01032004.bal_TOT_RFI_INC_PTD
                                             + py_za_tx_01032004.bal_RFI_TOT_PKG_PTD;
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',109);
      py_za_tx_01032004.bal_TOT_RFI_AN_INC_PTD := py_za_tx_01032004.bal_TOT_RFI_AN_INC_PTD
                                                + py_za_tx_01032004.bal_ANN_RFI_TOT_PKG_PTD;
   -- Add NRFI upd values to NRFI balance values
      -- Periodic
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',110);
      py_za_tx_01032004.bal_TOT_NRFI_INC_PTD := py_za_tx_01032004.bal_TOT_NRFI_INC_PTD
                                              + py_za_tx_01032004.bal_NRFI_TOT_PKG_PTD;
      -- Annual
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',111);
      py_za_tx_01032004.bal_TOT_NRFI_AN_INC_PTD := py_za_tx_01032004.bal_TOT_NRFI_AN_INC_PTD
                                                 + py_za_tx_01032004.bal_ANN_NRFI_TOT_PKG_PTD;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',112);
   END IF;

   -------------------------
   -- Pension Fund Abatement
   -------------------------
      ---------------------
      -- Period Calculation
      ---------------------
      -- Annualise Period Pension Fund Contribution
      py_za_tx_01032004.trc_PerPenFnd :=
         py_za_tx_01032004.bal_CUR_PF_PTD
       * py_za_tx_01032004.trc_SitFactor;
      -- Annualise Period Rfiable Contributions
      py_za_tx_01032004.trc_PerRfiCon :=
         py_za_tx_01032004.bal_TOT_RFI_INC_PTD
       * py_za_tx_01032004.trc_SitFactor;
      ---------------------
      -- Annual Calculation
      ---------------------
      -- Annual Pension Fund Contribution
      py_za_tx_01032004.trc_AnnPenFnd :=
         py_za_tx_01032004.trc_PerPenFnd
       + py_za_tx_01032004.bal_ANN_PF_PTD;
      -- Annual Rfi Contribution
      py_za_tx_01032004.trc_AnnRfiCon :=
         py_za_tx_01032004.trc_PerRfiCon
       + py_za_tx_01032004.bal_TOT_RFI_AN_INC_PTD;

   --------------------------------
   -- Arrear Pension Fund Abatement
   --------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',113);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrPenFnd :=
         py_za_tx_01032004.bal_EXC_ARR_PEN_PTD;
      ----------
      -- Current
      ----------
      py_za_tx_01032004.trc_PerArrPenFnd :=
          py_za_tx_01032004.trc_PerArrPenFnd
      + ( py_za_tx_01032004.bal_ARR_PF_PTD
        * py_za_tx_01032004.trc_SitFactor
        );
      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrPenFnd :=
         py_za_tx_01032004.trc_PerArrPenFnd
       + py_za_tx_01032004.bal_ANN_ARR_PF_PTD;

   -------------------------------
   -- Retirement Annuity Abatement
   -------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',114);

      -------------
      -- Current RA
      -------------
      -- Calculate RA Contribution
      py_za_tx_01032004.trc_PerRetAnu :=
         py_za_tx_01032004.bal_CUR_RA_PTD
       * py_za_tx_01032004.trc_SitFactor;
      ---------------------
      -- Current NRFI Contr
      ---------------------

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',115);
      py_za_tx_01032004.trc_PerNrfiCon :=
            py_za_tx_01032004.bal_TOT_NRFI_INC_PTD
          * py_za_tx_01032004.trc_SitFactor;


      ------------
      -- Annual RA
      ------------
      py_za_tx_01032004.trc_AnnRetAnu :=
         py_za_tx_01032004.trc_PerRetAnu
       + py_za_tx_01032004.bal_ANN_RA_PTD;


      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',116);
      py_za_tx_01032004.trc_AnnNrfiCon :=
            py_za_tx_01032004.trc_PerNrfiCon
          + py_za_tx_01032004.bal_TOT_NRFI_AN_INC_PTD;


   --------------------------------------
   -- Arrear Retirement Annuity Abatement
   --------------------------------------
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',117);
      -------------
      -- Excess ITD
      -------------
      py_za_tx_01032004.trc_PerArrRetAnu :=
         py_za_tx_01032004.bal_EXC_ARR_RA_PTD;
      ----------
      -- Current
      ----------
      py_za_tx_01032004.trc_PerArrRetAnu :=
         py_za_tx_01032004.trc_PerArrRetAnu
       + ( py_za_tx_01032004.bal_ARR_RA_PTD
         * py_za_tx_01032004.trc_SitFactor
         );
      ---------
      -- Annual
      ---------
      py_za_tx_01032004.trc_AnnArrRetAnu :=
         py_za_tx_01032004.trc_PerArrRetAnu
       + py_za_tx_01032004.trc_AnnArrRetAnu
       + py_za_tx_01032004.bal_ANN_ARR_RA_PTD;

   ------------------------
   -- Medical Aid Abatement
   ------------------------
      py_za_tx_01032004.trc_MedAidAbm :=
         py_za_tx_01032004.bal_MED_CONTR_PTD
       * py_za_tx_01032004.trc_SitFactor;
   -------------------------------------------------------------------------
   END IF;--                End CalcTyp Check
   -------------------------------------------------------------------------


----------------------------------------------------------------------------
--                        CALCULATE THE ABATEMENTS                        --
----------------------------------------------------------------------------
   hr_utility.set_location('py_za_tx_utl_01032004.Abatements',118);
   -- Check the Calculation Type
   IF py_za_tx_01032004.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',119);
      -- Employee Tax Year Start and End Dates
      --
      l_EndDate  := py_za_tx_01032004.dbi_ZA_ASG_TX_YR_END;

      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',120);

      -- Global Values
      l_ZA_TX_YR_END        := l_EndDate;
      l_ZA_ARR_PF_AN_MX_ABT := GlbVal('ZA_ARREAR_PEN_AN_MAX_ABATE',l_EndDate);
      l_ZA_ARR_RA_AN_MX_ABT := GlbVal('ZA_ARREAR_RA_AN_MAX_ABATE' ,l_EndDate);
      l_ZA_PF_AN_MX_ABT     := GlbVal('ZA_PEN_AN_MAX_ABATE'       ,l_EndDate);
      l_ZA_PF_MX_PRC        := GlbVal('ZA_PEN_MAX_PERC'           ,l_EndDate);
      l_ZA_RA_AN_MX_ABT     := GlbVal('ZA_RA_AN_MAX_ABATE'        ,l_EndDate);
      l_ZA_RA_MX_PRC        := GlbVal('ZA_RA_MAX_PERC'            ,l_EndDate);

   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.Abatements',121);
      -- Set locals to current values
      l_ZA_TX_YR_END         := py_za_tx_01032004.dbi_ZA_TX_YR_END;
      l_ZA_ARR_PF_AN_MX_ABT  := py_za_tx_01032004.glb_ZA_ARR_PF_AN_MX_ABT;
      l_ZA_ARR_RA_AN_MX_ABT  := py_za_tx_01032004.glb_ZA_ARR_RA_AN_MX_ABT;
      l_ZA_PF_AN_MX_ABT      := py_za_tx_01032004.glb_ZA_PF_AN_MX_ABT;
      l_ZA_PF_MX_PRC         := py_za_tx_01032004.glb_ZA_PF_MX_PRC;
      l_ZA_RA_AN_MX_ABT      := py_za_tx_01032004.glb_ZA_RA_AN_MX_ABT;
      l_ZA_RA_MX_PRC         := py_za_tx_01032004.glb_ZA_RA_MX_PRC;

   END IF;

   WriteHrTrace('l_ZA_TX_YR_END:        '||to_char(l_ZA_TX_YR_END,'DD/MM/YYYY'));
   WriteHrTrace('l_ZA_ARR_PF_AN_MX_ABT: '||to_char(l_ZA_ARR_PF_AN_MX_ABT      ));
   WriteHrTrace('l_ZA_ARR_RA_AN_MX_ABT: '||to_char(l_ZA_ARR_RA_AN_MX_ABT      ));
   WriteHrTrace('l_ZA_PF_AN_MX_ABT:     '||to_char(l_ZA_PF_AN_MX_ABT          ));
   WriteHrTrace('l_ZA_PF_MX_PRC:        '||to_char(l_ZA_PF_MX_PRC             ));
   WriteHrTrace('l_ZA_RA_AN_MX_ABT:     '||to_char(l_ZA_RA_AN_MX_ABT          ));
   WriteHrTrace('l_ZA_RA_MX_PRC:        '||to_char(l_ZA_RA_MX_PRC             ));

-------------------------
-- Pension Fund Abatement
-------------------------
   ---------------------
   -- Period Calculation
   ---------------------
   -- Calculate the Pension Fund Maximum
   py_za_tx_01032004.trc_PerPenFndMax :=
      GREATEST( l_ZA_PF_AN_MX_ABT
              , l_ZA_PF_MX_PRC / 100 * py_za_tx_01032004.trc_PerRfiCon
              );
   -- Calculate Period Pension Fund Abatement
   py_za_tx_01032004.trc_PerPenFndAbm :=
      LEAST( py_za_tx_01032004.trc_PerPenFnd
           , py_za_tx_01032004.trc_PerPenFndMax);
   ---------------------
   -- Annual Calculation
   ---------------------
   -- Calculate the Pension Fund Maximum
   py_za_tx_01032004.trc_AnnPenFndMax :=
      GREATEST( l_ZA_PF_AN_MX_ABT
              , l_ZA_PF_MX_PRC / 100 * py_za_tx_01032004.trc_AnnRfiCon
              );

   -- Calculate Annual Pension Fund Abatement
   py_za_tx_01032004.trc_AnnPenFndAbm :=
      LEAST( py_za_tx_01032004.trc_AnnPenFnd
           , py_za_tx_01032004.trc_AnnPenFndMax);
--------------------------------
-- Arrear Pension Fund Abatement
--------------------------------
   ---------------------
   -- Period Calculation
   ---------------------
   py_za_tx_01032004.trc_PerArrPenFndAbm :=
      LEAST( py_za_tx_01032004.trc_PerArrPenFnd
           , l_ZA_ARR_PF_AN_MX_ABT
           );
   ---------------------
   -- Annual Calculation
   ---------------------
   py_za_tx_01032004.trc_AnnArrPenFndAbm :=
      LEAST( py_za_tx_01032004.trc_AnnArrPenFnd
           , l_ZA_ARR_PF_AN_MX_ABT
           );
---------------------------------
-- Retirement Annnnuity Abatement
---------------------------------
   ---------------------
   -- Period Calculation
   ---------------------
   -- Calculate the Retirement Annuity Maximum
   py_za_tx_01032004.trc_PerRetAnuMax :=
      GREATEST( l_ZA_PF_AN_MX_ABT
              , l_ZA_RA_AN_MX_ABT - py_za_tx_01032004.trc_PerPenFndAbm
              , l_ZA_RA_MX_PRC / 100 * py_za_tx_01032004.trc_PerNrfiCon
              );

   -- Calculate Retirement Annuity Abatement
   py_za_tx_01032004.trc_PerRetAnuAbm :=
      LEAST( py_za_tx_01032004.trc_PerRetAnu
           , py_za_tx_01032004.trc_PerRetAnuMax);
   ---------------------
   -- Annual Calculation
   ---------------------
   py_za_tx_01032004.trc_AnnRetAnuMax :=
      GREATEST( l_ZA_PF_AN_MX_ABT
              , l_ZA_RA_AN_MX_ABT - py_za_tx_01032004.trc_AnnPenFndAbm
              , l_ZA_RA_MX_PRC / 100 * py_za_tx_01032004.trc_AnnNrfiCon
              );

   -- Calculate Retirement Annuity Abatement
   py_za_tx_01032004.trc_AnnRetAnuAbm :=
      LEAST( py_za_tx_01032004.trc_AnnRetAnu
           , py_za_tx_01032004.trc_AnnRetAnuMax);
--------------------------------------
-- Arrear Retirement Annuity Abatement
--------------------------------------
   ---------------------
   -- Period Calculation
   ---------------------
   py_za_tx_01032004.trc_PerArrRetAnuAbm :=
      LEAST( py_za_tx_01032004.trc_PerArrRetAnu
           , l_ZA_ARR_RA_AN_MX_ABT);
   ---------------------
   -- Annual Calculation
   ---------------------
   py_za_tx_01032004.trc_AnnArrRetAnuAbm :=
      LEAST( py_za_tx_01032004.trc_AnnArrRetAnu
           , l_ZA_ARR_RA_AN_MX_ABT);

-----------------------------------------------------------
-- Tax Rebates, Threshold Figure and Medical Aid Abatements
-----------------------------------------------------------
   -- Calculate the assignments 65 Year Date
   l_65Year := add_months(py_za_tx_01032004.dbi_PER_DTE_OF_BRTH,780);

   IF l_65Year > l_ZA_TX_YR_END THEN
      py_za_tx_01032004.trc_MedAidAbm := 0;
   END IF;

   hr_utility.set_location('py_za_tx_utl_01032004.Abatements',122);

-------------------
-- Total Abatements
-------------------
   -- Period Total Abatement
   py_za_tx_01032004.trc_PerTotAbm := ( py_za_tx_01032004.trc_PerPenFndAbm
                                      + py_za_tx_01032004.trc_PerArrPenFndAbm
                                      + py_za_tx_01032004.trc_PerRetAnuAbm
                                      + py_za_tx_01032004.trc_PerArrRetAnuAbm
                                      + py_za_tx_01032004.trc_MedAidAbm
                                      );

   -- Annual Total Abatements
   py_za_tx_01032004.trc_AnnTotAbm := ( py_za_tx_01032004.trc_AnnPenFndAbm
                                      + py_za_tx_01032004.trc_AnnArrPenFndAbm
                                      + py_za_tx_01032004.trc_AnnRetAnuAbm
                                      + py_za_tx_01032004.trc_AnnArrRetAnuAbm
                                      + py_za_tx_01032004.trc_MedAidAbm
                                      );


   WriteHrTrace('-- Fixed Pension Basis');
   WriteHrTrace('py_za_tx_01032004.trc_PerTxbPkg:            '||to_char(py_za_tx_01032004.trc_PerTxbPkg           ));
   WriteHrTrace('py_za_tx_01032004.trc_AnnTxbPkg:            '||to_char(py_za_tx_01032004.trc_AnnTxbPkg           ));
   WriteHrTrace('py_za_tx_01032004.trc_TotPkg:               '||to_char(py_za_tx_01032004.trc_TotPkg              ));
   WriteHrTrace('py_za_tx_01032004.trc_TxbFxdPrc:            '||to_char(py_za_tx_01032004.trc_TxbFxdPrc           ));
   WriteHrTrace('py_za_tx_01032004.trc_PerRFITotPkgPTD:      '||to_char(py_za_tx_01032004.trc_PerRFITotPkgPTD     ));
   WriteHrTrace('py_za_tx_01032004.trc_PerNRFITotPkgPTD:     '||to_char(py_za_tx_01032004.trc_PerNRFITotPkgPTD    ));
   WriteHrTrace('py_za_tx_01032004.trc_AnnRFITotPkgPTD:      '||to_char(py_za_tx_01032004.trc_AnnRFITotPkgPTD     ));
   WriteHrTrace('py_za_tx_01032004.trc_AnnNRFITotPkgPTD:     '||to_char(py_za_tx_01032004.trc_AnnNRFITotPkgPTD    ));
   WriteHrTrace('py_za_tx_01032004.trc_PerRFITotPkgPTD_Upd:  '||to_char(py_za_tx_01032004.trc_PerRFITotPkgPTD_Upd ));
   WriteHrTrace('py_za_tx_01032004.trc_PerNRFITotPkgPTD_Upd: '||to_char(py_za_tx_01032004.trc_PerNRFITotPkgPTD_Upd));
   WriteHrTrace('py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd:  '||to_char(py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd ));
   WriteHrTrace('py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd: '||to_char(py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd));
   WriteHrTrace(' ');
   WriteHrTrace('py_za_tx_01032004.trc_PerTotAbm:            '||to_char(py_za_tx_01032004.trc_PerTotAbm      ));
   WriteHrTrace('trc_PerTotAbm consists of:');
   WriteHrTrace('py_za_tx_01032004.trc_PerPenFndAbm:         '||to_char(py_za_tx_01032004.trc_PerPenFndAbm   ));
   WriteHrTrace('py_za_tx_01032004.trc_PerArrPenFndAbm:      '||to_char(py_za_tx_01032004.trc_PerArrPenFndAbm));
   WriteHrTrace('py_za_tx_01032004.trc_PerRetAnuAbm:         '||to_char(py_za_tx_01032004.trc_PerRetAnuAbm   ));
   WriteHrTrace('py_za_tx_01032004.trc_PerArrRetAnuAbm:      '||to_char(py_za_tx_01032004.trc_PerArrRetAnuAbm));
   WriteHrTrace('py_za_tx_01032004.trc_MedAidAbm:            '||to_char(py_za_tx_01032004.trc_MedAidAbm      ));
   WriteHrTrace(' ');
   WriteHrTrace('py_za_tx_01032004.trc_AnnTotAbm:            '||to_char(py_za_tx_01032004.trc_AnnTotAbm      ));
   WriteHrTrace('trc_AnnTotAbm consists of:');
   WriteHrTrace('py_za_tx_01032004.trc_AnnPenFndAbm:         '||to_char(py_za_tx_01032004.trc_AnnPenFndAbm   ));
   WriteHrTrace('py_za_tx_01032004.trc_AnnArrPenFndAbm:      '||to_char(py_za_tx_01032004.trc_AnnArrPenFndAbm));
   WriteHrTrace('py_za_tx_01032004.trc_AnnRetAnuAbm:         '||to_char(py_za_tx_01032004.trc_AnnRetAnuAbm   ));
   WriteHrTrace('py_za_tx_01032004.trc_AnnArrRetAnuAbm:      '||to_char(py_za_tx_01032004.trc_AnnArrRetAnuAbm));
   WriteHrTrace('py_za_tx_01032004.trc_MedAidAbm:            '||to_char(py_za_tx_01032004.trc_MedAidAbm      ));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'Abatements: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END Abatements;
-------------------------------------------------------------------------------
-- ArrearExcess                                                              --
-------------------------------------------------------------------------------
PROCEDURE ArrearExcess AS
-- Variables
   l_PfExcessAmt NUMBER;
   l_RaExcessAmt NUMBER;

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.ArrearExcess',1);
-- Pension Excess
   l_PfExcessAmt := ( py_za_tx_01032004.bal_ARR_PF_YTD
                    + ( py_za_tx_01032004.bal_EXC_ARR_PEN_ITD
                      - py_za_tx_01032004.bal_EXC_ARR_PEN_YTD
                      )
                    ) - py_za_tx_01032004.glb_ZA_ARR_PF_AN_MX_ABT;

   IF l_PfExcessAmt > 0 THEN
      hr_utility.set_location('py_za_tx_utl_01032004.ArrearExcess',2);
      py_za_tx_01032004.trc_PfUpdFig := l_PfExcessAmt - py_za_tx_01032004.bal_EXC_ARR_PEN_ITD;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.ArrearExcess',3);
      py_za_tx_01032004.trc_PfUpdFig := -1*(py_za_tx_01032004.bal_EXC_ARR_PEN_ITD);
   END IF;

-- Retirement Annuity
   l_RaExcessAmt := ( py_za_tx_01032004.bal_ARR_RA_YTD
                    + ( py_za_tx_01032004.bal_EXC_ARR_RA_ITD
                      - py_za_tx_01032004.bal_EXC_ARR_RA_YTD
                      )
                    ) - py_za_tx_01032004.glb_ZA_ARR_RA_AN_MX_ABT;

   IF l_RaExcessAmt > 0 THEN
      hr_utility.set_location('py_za_tx_utl_01032004.ArrearExcess',4);
      py_za_tx_01032004.trc_RaUpdFig := l_RaExcessAmt - py_za_tx_01032004.bal_EXC_ARR_RA_ITD;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.ArrearExcess',5);
      py_za_tx_01032004.trc_RaUpdFig := -1*(py_za_tx_01032004.bal_EXC_ARR_RA_ITD);
   END IF;

   hr_utility.set_location('py_za_tx_utl_01032004.ArrearExcess',6);
   WriteHrTrace('l_PfExcessAmt: '||to_char(l_PfExcessAmt));
   WriteHrTrace('l_RaExcessAmt: '||to_char(l_RaExcessAmt));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'ArrearExcess: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END ArrearExcess;
-------------------------------------------------------------------------------
-- GetTableValue                                                             --
-------------------------------------------------------------------------------
FUNCTION GetTableValue
   ( p_TableName     IN pay_user_tables.user_table_name%TYPE
   , p_ColumnName    IN pay_user_columns.user_column_name%TYPE
   , p_RowValue      IN NUMBER
   , p_EffectiveDate IN DATE
   ) RETURN VARCHAR2
AS
-- Variables
--
   l_UserTableID pay_user_tables.user_table_id%TYPE;
   l_ColumnID    pay_user_columns.user_column_id%TYPE;
   l_RowID       pay_user_rows_f.user_row_id%TYPE;
   l_TableValue  pay_user_column_instances_f.value%TYPE;
BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.GetTableValue',1);
   -- Get the user_table_id
   --
   select put.user_table_id
     INTO l_UserTableID
     from pay_user_tables put
    where upper(put.user_table_name) = upper(p_TableName)
      AND put.legislation_code       = 'ZA';

   hr_utility.set_location('py_za_tx_utl_01032004.GetTableValue',2);
   -- Get the user_column_id
   --
   select puc.user_column_id
     INTO l_ColumnID
     from pay_user_columns            puc
    where puc.user_table_id           = l_UserTableID
      AND puc.legislation_code        = 'ZA'
      and puc.business_group_id       is null
      AND upper(puc.user_column_name) = upper(p_ColumnName);

   hr_utility.set_location('py_za_tx_utl_01032004.GetTableValue',3);
   -- Get the user_row_id
   --
   select pur.user_row_id
     INTO l_RowID
     from pay_user_tables      put
        , pay_user_rows_f      pur
    where put.user_table_id    = l_UserTableID
      and pur.user_table_id    = put.user_table_id
      AND pur.row_high_range   IS NOT NULL
      AND p_EffectiveDate      BETWEEN pur.effective_start_date
                                   AND pur.effective_end_date
      AND pur.legislation_code = 'ZA'
      AND p_RowValue           BETWEEN decode ( put.user_key_units
                                              , 'N', pur.row_low_range_or_name
                                              , p_RowValue+1
                                              )
                                   AND decode ( put.user_key_units
                                              , 'N', pur.row_high_range
                                              , p_RowValue-1
                                              );

   hr_utility.set_location('py_za_tx_utl_01032004.GetTableValue',4);
   -- Get the value
   --
   SELECT pucif.value
     INTO l_TableValue
     FROM pay_user_column_instances_f pucif
    where pucif.user_column_id        = l_ColumnID
      and pucif.user_row_id           = l_RowID
      AND pucif.legislation_code      = 'ZA'
      and p_EffectiveDate             BETWEEN pucif.effective_start_date
                                          AND pucif.effective_end_date;

   hr_utility.set_location('py_za_tx_utl_01032004.GetTableValue',5);
   RETURN l_TableValue;
EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'GetTableValue: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END GetTableValue;
-------------------------------------------------------------------------------
-- TaxLiability                                                              --
-------------------------------------------------------------------------------
FUNCTION TaxLiability
   (p_Amt  IN NUMBER
   )RETURN  NUMBER
AS

-- Variables
--
   l_fixed          pay_user_column_instances_f.value%TYPE;
   l_limit          pay_user_column_instances_f.value%TYPE;
   l_percentage     pay_user_column_instances_f.value%TYPE;
   l_effective_date pay_payroll_actions.effective_date%TYPE;
   tax_liability    t_Balance;
   l_TxbAmt         t_Balance;

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',1);
   -------------------------------------------------------------------------------
   -- First Check for a Tax Override
   -------------------------------------------------------------------------------
   IF py_za_tx_01032004.trc_OvrTxCalc AND py_za_tx_01032004.trc_OvrTyp = 'P' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',2);
      tax_liability := (p_Amt * py_za_tx_01032004.trc_OvrPrc) / 100;
   -------------------------------------------------------------------------------
   -- D = Directive Percentage
   -- P = Private Director wth Directive Percentage
   -------------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.dbi_TX_STA IN ('D','P') THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',3);
      tax_liability := (p_Amt * py_za_tx_01032004.dbi_TX_DIR_VAL) / 100;
   -------------------------------------------------------------------------------
   -- E = Close Corporation
   -------------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.dbi_TX_STA = 'E' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',4);
      tax_liability := (p_Amt * py_za_tx_01032004.glb_ZA_CC_TX_PRC) / 100;
   -------------------------------------------------------------------------------
   -- F = Temporary Worker/Student
   -------------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.dbi_TX_STA = 'F' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',5);
      tax_liability := (p_Amt * py_za_tx_01032004.glb_ZA_TMP_TX_RTE) / 100;
   -------------------------------------------------------------------------------
   -- J = Personal Service Company
   -------------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.dbi_TX_STA = 'J' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',6);
      tax_liability := (p_Amt * py_za_tx_01032004.glb_ZA_PER_SERV_COMP_PERC) / 100;
   -------------------------------------------------------------------------------
   -- K = Personal Service Trust
   -------------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.dbi_TX_STA = 'K' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',7);
      tax_liability := (p_Amt * py_za_tx_01032004.glb_ZA_PER_SERV_TRST_PERC) / 100;
   -------------------------------------------------------------------------------
   -- L = Labour Broker
   -------------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.dbi_TX_STA = 'L' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',8);
      tax_liability := (p_Amt * py_za_tx_01032004.glb_ZA_PER_SERV_COMP_PERC) / 100;
   -------------------------------------------------------------------------------
   -- A = Normal
   -- B = Provisional
   -- G = Seasonal Worker
   -- M = Private Director
   -------------------------------------------------------------------------------
   ELSIF py_za_tx_01032004.dbi_TX_STA IN ('A','B','G','M') THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',9);
      -- Taxable Amount must be rounded off to two decimal places
      l_TxbAmt := round(p_Amt,2);

      -- effective date for the payroll_run
      l_effective_date := py_za_tx_01032004.dbi_PAY_PROC_PRD_DTE_PD;

      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',10);
      l_fixed       := GetTableValue('ZA_TAX_TABLE','Fixed',l_TxbAmt,l_effective_date);
      l_limit       := GetTableValue('ZA_TAX_TABLE','Limit',l_TxbAmt,l_effective_date);
      l_percentage  := GetTableValue('ZA_TAX_TABLE','Percentage',l_TxbAmt,l_effective_date);
      tax_liability := (l_fixed + ((l_TxbAmt - l_limit) * (l_percentage / 100))) -  py_za_tx_01032004.trc_Rebate;
      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',11);
   -------------------------------------------------------------------------------
   -- Tax Status invalid for the call to TaxLiability
   -------------------------------------------------------------------------------
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032004.TaxLiability',12);
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'TaxLiability: Invalid Tax Status';
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
   END IF;

   WriteHrTrace('l_fixed:       '||        l_fixed                      );
   WriteHrTrace('l_TxbAmt:      '||to_char(l_TxbAmt                    ));
   WriteHrTrace('l_limit:       '||        l_limit                      );
   WriteHrTrace('l_percentage:  '||        l_percentage                 );
   WriteHrTrace('trc_Rebate:    '||to_char(py_za_tx_01032004.trc_Rebate));
   WriteHrTrace('tax_liability: '||to_char(tax_liability               ));

   RETURN tax_liability;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'TaxLiability: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END TaxLiability;
-------------------------------------------------------------------------------
-- DeAnnualise                                                               --
-------------------------------------------------------------------------------
FUNCTION DeAnnualise
   (p_Liab IN NUMBER
   ,p_TxOnYtd IN NUMBER
   ,p_TxOnPtd IN NUMBER
   ) RETURN NUMBER
AS
   l_LiabRoy1 t_balance;
   l_LiabRoy2 t_balance;
   l_LiabRoy3 t_balance;
   l_LiabRoy4 t_balance;
   l_LiabFp   t_balance;
BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.DeAnnualise',1);
   -- 1
   l_LiabRoy1 := p_liab / py_za_tx_01032004.trc_PosFactor;
   -- 2
   l_LiabRoy2 := l_LiabRoy1 - p_TxOnYtd + p_TxOnPtd;
   -- 3
   l_LiabRoy3 := l_LiabRoy2 / py_za_tx_01032004.dbi_ZA_PAY_PRDS_LFT;
   -- 4
   l_LiabRoy4 := l_LiabRoy3 * py_za_tx_01032004.trc_PrdFactor;
   -- 5
   l_LiabFp   := l_LiabRoy4 - p_TxOnPtd;
   --
   hr_utility.set_location('py_za_tx_utl_01032004.DeAnnualise',2);
   --
   WriteHrTrace('p_liab:                               '||to_char(p_liab));
   WriteHrTrace('py_za_tx_01032004.trc_PosFactor:      '||to_char(py_za_tx_01032004.trc_PosFactor));
   WriteHrTrace('l_LiabRoy1:                           '||to_char(l_LiabRoy1));
   WriteHrTrace('p_TxOnYtd:                            '||to_char(p_TxOnYtd));
   WriteHrTrace('p_TxOnPtd:                            '||to_char(p_TxOnPtd));
   WriteHrTrace('l_LiabRoy2:                           '||to_char(l_LiabRoy2));
   WriteHrTrace('py_za_tx_01032004.dbi_ZA_PAY_PRDS_LFT:'||to_char(py_za_tx_01032004.dbi_ZA_PAY_PRDS_LFT));
   WriteHrTrace('l_LiabRoy3:                           '||to_char(l_LiabRoy3));
   WriteHrTrace('py_za_tx_01032004.trc_PrdFactor:      '||to_char(py_za_tx_01032004.trc_PrdFactor));
   WriteHrTrace('l_LiabRoy4:                           '||to_char(l_LiabRoy4));
   WriteHrTrace('l_LiabFp:                             '||to_char(l_LiabFp));
   --
   RETURN l_LiabFp;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'DeAnnualise: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END DeAnnualise;
-------------------------------------------------------------------------------
-- TrvAll                                                                    --
-------------------------------------------------------------------------------
PROCEDURE TrvAll AS
-- Cursors
--
  -- Global Effective End Dates
  CURSOR c_GlbEffDte
    (p_ty_sd DATE       -- start date
    ,p_ty_ed DATE       -- end date
    )
  IS
  SELECT effective_end_date
       , to_number(global_value) global_value
    FROM ff_globals_f
   WHERE effective_end_date < p_ty_ed
     AND effective_end_date > p_ty_sd
     AND global_name        = 'ZA_CAR_ALLOW_TAX_PERC';

-- Variables
--
  l_NrfiBalID  pay_balance_types.balance_type_id%TYPE;
  l_RfiBalID   pay_balance_types.balance_type_id%TYPE;
  l_StrtDate   DATE;
  l_EndDate    DATE;
  l_NrfiYtd    t_balance DEFAULT 0;
  l_CurNrfiYtd t_balance DEFAULT 0;
  l_TotNrfiYtd t_balance DEFAULT 0;
  l_CurTxbNrfi t_balance DEFAULT 0;
  l_TotTxbNrfi t_balance DEFAULT 0;
  l_RfiYtd     t_balance DEFAULT 0;
  l_CurRfiYtd  t_balance DEFAULT 0;
  l_TotRfiYtd  t_balance DEFAULT 0;
  l_CurTxbRfi  t_balance DEFAULT 0;
  l_TotTxbRfi  t_balance DEFAULT 0;
  l_GlbVal     ff_globals_f.global_value%TYPE DEFAULT '0';

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',1);
-- Retrieve Balance Type ID's
   SELECT balance_type_id
     INTO l_NrfiBalID
     FROM pay_balance_types
    WHERE legislation_code = 'ZA'
      AND balance_name     = 'Travel Allowance NRFI';

   hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',2);

   SELECT balance_type_id
     INTO l_RfiBalID
     FROM pay_balance_types
    WHERE legislation_code = 'ZA'
      AND balance_name     = 'Travel Allowance RFI';

-- Check Calc and setup correct values
--
   IF py_za_tx_01032004.trc_CalTyp in ('DirCalc','NorCalc','SitCalc','YtdCalc') THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',3);
      -- Employee Tax Year Start and End Dates
      --
      l_StrtDate := GREATEST( py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE
                            , py_za_tx_01032004.dbi_ZA_TX_YR_STRT
                            );
      l_EndDate  := LEAST( py_za_tx_01032004.dbi_ZA_ACT_END_DTE
                         , py_za_tx_01032004.dbi_ZA_TX_YR_END
                         , py_za_tx_01032004.dbi_ZA_CUR_PRD_END_DTE
                         );

   ELSIF py_za_tx_01032004.trc_CalTyp = 'CalCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',4);
      -- Employee Tax Year Start and End Dates
      --
      l_StrtDate := to_date('01-01-'||to_char(py_za_tx_01032004.dbi_ZA_TX_YR_STRT,'YYYY')||''||'','DD-MM-YYYY');
      l_EndDate  := py_za_tx_01032004.dbi_ZA_TX_YR_STRT -1;

   ELSIF py_za_tx_01032004.trc_CalTyp = 'LteCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',5);
      -- Employee Tax Year Start and End Dates
      --
      l_StrtDate := py_za_tx_01032004.dbi_ZA_TX_YR_STRT;
      l_EndDate  := py_za_tx_01032004.dbi_ZA_CUR_PRD_END_DTE;

   ELSIF py_za_tx_01032004.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',6);
      -- Employee Tax Year Start and End Dates
      --
      l_StrtDate := py_za_tx_01032004.dbi_ZA_ASG_TX_YR_STRT;
      l_EndDate := py_za_tx_01032004.dbi_ZA_ASG_TX_YR_END;
   END IF;

   hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',7);

-- Loop through cursor and for every end date calculate the balance
   FOR v_Date IN c_GlbEffDte
                 (l_StrtDate
                 ,l_EndDate
                 )
   LOOP
   -- Nrfi Travel Allowance
   --
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',8);
      -- Check Calc Type
      IF py_za_tx_01032004.trc_CalTyp IN ('DirCalc','NorCalc','SitCalc','YtdCalc','LteCalc','PstCalc') THEN
         hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',9);
         -- Nrfi Balance At That Date
         -- 3491357
         /*l_NrfiYtd := py_za_bal.calc_asg_tax_ytd_date
                         ( py_za_tx_01032004.con_ASG_ID
                         , l_NrfiBalID
                         , v_Date.effective_end_date
                      );*/
        l_NrfiYtd := py_za_bal.get_balance_value
                         ( py_za_tx_01032004.con_ASG_ID
                         , l_NrfiBalID
                         , '_ASG_TAX_YTD'
                         , v_Date.effective_end_date
                      );
      ELSIF  py_za_tx_01032004.trc_CalTyp = 'CalCalc' THEN
         hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',10);
         -- Nrfi Balance At That Date
         -- 3491357
         /*l_NrfiYtd := py_za_bal.calc_asg_cal_ytd_date
                         ( py_za_tx_01032004.con_ASG_ID
                         , l_NrfiBalID
                         , v_Date.effective_end_date
                         );*/
         l_NrfiYtd := py_za_bal.get_balance_value
                         ( py_za_tx_01032004.con_ASG_ID
                         , l_NrfiBalID
                         , '_ASG_CAL_YTD'
                         , v_Date.effective_end_date
                         );
      END IF;

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
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',11);
      -- Check Calc Type
      IF py_za_tx_01032004.trc_CalTyp in ('DirCalc','NorCalc','SitCalc','YtdCalc','LteCalc','PstCalc') THEN
         hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',12);
         -- Rfi Balance At That Date
         -- 3491357
         /*l_RfiYtd := py_za_bal.calc_asg_tax_ytd_date
                        ( py_za_tx_01032004.con_ASG_ID
                        , l_RfiBalID
                        , v_Date.effective_end_date
                        );*/
         l_RfiYtd := py_za_bal.get_balance_value
                        ( py_za_tx_01032004.con_ASG_ID
                        , l_RfiBalID
                        , '_ASG_TAX_YTD'
                        , v_Date.effective_end_date
                        );
      ELSIF py_za_tx_01032004.trc_CalTyp = 'CalCalc' THEN
         hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',13);
         -- Rfi Balance At That Date
         -- 3491357
         /*l_RfiYtd := py_za_bal.calc_asg_cal_ytd_date
                        ( py_za_tx_01032004.con_ASG_ID
                        , l_RfiBalID
                        , v_Date.effective_end_date
                        );*/
         l_RfiYtd := py_za_bal.get_balance_value
                        ( py_za_tx_01032004.con_ASG_ID
                        , l_RfiBalID
                        , '_ASG_CAL_YTD'
                        , v_Date.effective_end_date
                        );
      END IF;

      -- Take Off the Ytd value used already
      l_CurRfiYtd := l_RfiYtd - l_TotRfiYtd;
      -- Update TotYtd value
      l_TotRfiYtd := l_RfiYtd;
      -- Get the Taxable Travel Allowance at that date
      l_CurTxbRfi := l_CurRfiYtd * v_Date.global_value/100;
      -- Add this to the total
      l_TotTxbRfi := l_TotTxbRfi + l_CurTxbRfi;

   END LOOP;

   WriteHrTrace('l_CurNrfiYtd: '||to_char(l_CurNrfiYtd));
   WriteHrTrace('l_TotNrfiYtd: '||to_char(l_TotNrfiYtd));
   WriteHrTrace('l_CurTxbNrfi: '||to_char(l_CurTxbNrfi));
   WriteHrTrace('l_TotTxbNrfi: '||to_char(l_TotTxbNrfi));
   WriteHrTrace('l_CurRfiYtd:  '||to_char(l_CurRfiYtd));
   WriteHrTrace('l_TotRfiYtd:  '||to_char(l_TotRfiYtd));
   WriteHrTrace('l_CurTxbRfi:  '||to_char(l_CurTxbRfi));
   WriteHrTrace('l_TotTxbRfi:  '||to_char(l_TotTxbRfi));

-- Calculate the current Taxable Travel Allowance Value
-- add this to any calculated in the loop
--
   hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',14);
   -- Check Calc TYPE
   IF py_za_tx_01032004.trc_CalTyp IN ('DirCalc','NorCalc','SitCalc','YtdCalc', 'LteCalc') THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',15);
      -- Balance Values
      l_NrfiYtd := py_za_tx_01032004.bal_TA_NRFI_YTD;
      l_RfiYtd  := py_za_tx_01032004.bal_TA_RFI_YTD;
      -- Global Value
      l_GlbVal  := py_za_tx_01032004.glb_ZA_TRV_ALL_TX_PRC;

   ELSIF py_za_tx_01032004.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',16);
      -- Balance Values
      l_NrfiYtd := py_za_tx_01032004.bal_TA_NRFI_PTD;
      l_RfiYtd := py_za_tx_01032004.bal_TA_RFI_PTD;
      -- Global Value
      SELECT TO_NUMBER(global_value)
        INTO l_GlbVal
        FROM ff_globals_f
       WHERE l_EndDate between effective_start_date
                           and effective_end_date
         AND global_name     = 'ZA_CAR_ALLOW_TAX_PERC';

      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',17);

   ELSIF py_za_tx_01032004.trc_CalTyp = 'CalCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',18);
      -- Balance Values
      l_NrfiYtd := py_za_tx_01032004.bal_TA_NRFI_CYTD;
      l_RfiYtd  := py_za_tx_01032004.bal_TA_RFI_CYTD;

      -- Global Value
      SELECT TO_NUMBER(global_value)
        INTO l_GlbVal
        FROM ff_globals_f
       WHERE l_EndDate between effective_start_date
                           and effective_end_date
         AND global_name     = 'ZA_CAR_ALLOW_TAX_PERC';

      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',19);

   END IF;

   WriteHrTrace('l_NrfiYtd: '||to_char(l_NrfiYtd));
   WriteHrTrace('l_RfiYtd:  '||to_char(l_RfiYtd));
   WriteHrTrace('l_GlbVal:  '||l_GlbVal);

-- Nrfi Travel Allowance
--
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
   -- Take Off the Ytd value used already
   l_CurRfiYtd := l_RfiYtd - l_TotRfiYtd;
   -- Update TotYtd value
   l_TotRfiYtd := l_RfiYtd;
   -- Get the Taxable Travel Allowance at that date
   l_CurTxbRfi := l_CurRfiYtd * l_GlbVal/100;
   -- Add this to the total
   l_TotTxbRfi := l_TotTxbRfi + l_CurTxbRfi;

-- Update Globals
--
   -- Check Calc Type
   IF py_za_tx_01032004.trc_CalTyp IN ('DirCalc','NorCalc','SitCalc','YtdCalc', 'LteCalc') THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',20);
      py_za_tx_01032004.bal_TA_NRFI_YTD := l_TotTxbNrfi;
      py_za_tx_01032004.bal_TA_RFI_YTD  := l_TotTxbRfi;
   ELSIF py_za_tx_01032004.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',21);
      py_za_tx_01032004.bal_TA_NRFI_PTD := l_TotTxbNrfi;
      py_za_tx_01032004.bal_TA_RFI_PTD  := l_TotTxbRfi;
   ELSIF py_za_tx_01032004.trc_CalTyp = 'CalCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.TrvAll',22);
      py_za_tx_01032004.bal_TA_NRFI_CYTD := l_TotTxbNrfi;
      py_za_tx_01032004.bal_TA_RFI_CYTD  := l_TotTxbRfi;
   END IF;

   WriteHrTrace('l_TotTxbNrfi: '||to_char(l_TotTxbNrfi));
   WriteHrTrace('l_TotTxbRfi:  '||to_char(l_TotTxbRfi));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'TrvAll: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END TrvAll;
-------------------------------------------------------------------------------
-- ValidateTaxOns                                                            --
-------------------------------------------------------------------------------
PROCEDURE ValidateTaxOns(
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

   l_TotLib t_Balance; -- Total Liability
   l_TotNp  t_Balance; -- Total Net Pay
   l_RecVal t_Balance; -- Recovery Value
   l_NewLib t_Balance; -- New Liability
   i NUMBER; -- Counter

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',1);
-- Set up the Table
   t_Liabilities(1).Ovrrde := py_za_tx_01032004.trc_LibFpNIOvr;
   t_Liabilities(1).Lib    := py_za_tx_01032004.trc_LibFpNI;

   t_Liabilities(2).Ovrrde := py_za_tx_01032004.trc_LibFpFBOvr;
   t_Liabilities(2).Lib    := py_za_tx_01032004.trc_LibFpFB;

   t_Liabilities(3).Ovrrde := py_za_tx_01032004.trc_LibFpTAOvr;
   t_Liabilities(3).Lib    := py_za_tx_01032004.trc_LibFpTA;

   t_Liabilities(4).Ovrrde := py_za_tx_01032004.trc_LibFpBPOvr;
   t_Liabilities(4).Lib    := py_za_tx_01032004.trc_LibFpBP;

   t_Liabilities(5).Ovrrde := py_za_tx_01032004.trc_LibFpABOvr;
   t_Liabilities(5).Lib    := py_za_tx_01032004.trc_LibFpAB;

   t_Liabilities(6).Ovrrde := py_za_tx_01032004.trc_LibFpAPOvr;
   t_Liabilities(6).Lib    := py_za_tx_01032004.trc_LibFpAP;

   t_Liabilities(7).Ovrrde := py_za_tx_01032004.trc_LibFpPOOvr;
   t_Liabilities(7).Lib    := py_za_tx_01032004.trc_LibFpPO;

   IF py_za_tx_01032004.trc_LibFpNIOvr THEN
      WriteHrTrace('py_za_tx_01032004.trc_LibFpNIOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032004.trc_LibFpNIOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032004.trc_LibFpNI: '||to_char(py_za_tx_01032004.trc_LibFpNI));
   IF py_za_tx_01032004.trc_LibFpFBOvr THEN
      WriteHrTrace('py_za_tx_01032004.trc_LibFpFBOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032004.trc_LibFpFBOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032004.trc_LibFpFB: '||to_char(py_za_tx_01032004.trc_LibFpFB));
   IF py_za_tx_01032004.trc_LibFpTAOvr THEN
      WriteHrTrace('py_za_tx_01032004.trc_LibFpTAOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032004.trc_LibFpTAOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032004.trc_LibFpTA: '||to_char(py_za_tx_01032004.trc_LibFpTA));
   IF py_za_tx_01032004.trc_LibFpBPOvr THEN
      WriteHrTrace('py_za_tx_01032004.trc_LibFpBPOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032004.trc_LibFpBPOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032004.trc_LibFpBP: '||to_char(py_za_tx_01032004.trc_LibFpBP));
   IF py_za_tx_01032004.trc_LibFpABOvr THEN
      WriteHrTrace('py_za_tx_01032004.trc_LibFpABOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032004.trc_LibFpABOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032004.trc_LibFpAB: '||to_char(py_za_tx_01032004.trc_LibFpAB));
   IF py_za_tx_01032004.trc_LibFpAPOvr THEN
      WriteHrTrace('py_za_tx_01032004.trc_LibFpAPOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032004.trc_LibFpAPOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032004.trc_LibFpAP: '||to_char(py_za_tx_01032004.trc_LibFpAP));
   IF py_za_tx_01032004.trc_LibFpPOOvr THEN
      WriteHrTrace('py_za_tx_01032004.trc_LibFpPOOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032004.trc_LibFpPOOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032004.trc_LibFpPO: '||to_char(py_za_tx_01032004.trc_LibFpPO));

-- Sum the Liabilities
   l_TotLib :=
   ( py_za_tx_01032004.trc_LibFpNI
   + py_za_tx_01032004.trc_LibFpFB
   + py_za_tx_01032004.trc_LibFpTA
   + py_za_tx_01032004.trc_LibFpBP
   + py_za_tx_01032004.trc_LibFpAB
   + py_za_tx_01032004.trc_LibFpAP
   + py_za_tx_01032004.trc_LibFpPO
   );

-- Set Net Pay
   l_TotNp := py_za_tx_01032004.bal_NET_PAY_RUN;
   WriteHrTrace('l_TotNp: '||to_char(l_TotNp));
-- Start Validation
--
   IF l_TotLib = 0 THEN
      hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',2);
      NULL;
   ELSIF l_TotLib > 0 THEN
      hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',3);
      IF l_TotNp > 0 THEN
         hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',4);
         IF l_TotLib = l_TotNp THEN
            hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',5);
            NULL;
         ELSIF l_TotLib > l_TotNp THEN
            hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',6);
            l_RecVal := l_TotLib - l_TotNp;
            i:= 1;

            FOR i IN 1..7 LOOP
               IF t_Liabilities(i).Lib = 0 THEN
                  hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',7);
                  NULL;
               ELSIF t_Liabilities(i).Lib > 0 THEN
                  hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',8);
                  l_NewLib := t_Liabilities(i).Lib - LEAST(t_Liabilities(i).Lib,l_RecVal);
                  l_RecVal := l_RecVal - (t_Liabilities(i).Lib - l_NewLib);
                  t_Liabilities(i).Lib := l_NewLib;
                  py_za_tx_01032004.trc_LibWrn := 'Warning: Net Pay Balance not enough for Tax Recovery';
               ELSE -- lib < 0
                  hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',9);
                  NULL;
               END IF;
           END LOOP;

         ELSE -- l_TotLib > 0,l_TotNp > 0,l_TotLib < l_TotNp
            hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',10);
            NULL;
         END IF;

      ELSE -- l_TotLib > 0,l_TotNp <= 0
         hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',11);
         l_RecVal := l_TotLib;
         i := 1;

         FOR i IN 1..7 LOOP
            IF t_Liabilities(i).Lib > 0 THEN
               hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',12);
               l_NewLib := t_Liabilities(i).Lib - LEAST(t_Liabilities(i).Lib,l_RecVal);
               l_RecVal := l_RecVal - (t_Liabilities(i).Lib - l_NewLib);
               t_Liabilities(i).Lib := l_NewLib;
               py_za_tx_01032004.trc_LibWrn := 'Warning: Net Pay Balance not enough for Tax Recovery';
            END IF;
         END LOOP;
      END IF;

   ELSE -- l_TotLib < 0
      hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',13);
      IF p_Rf THEN
         hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',14);
         NULL;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',15);
         l_RecVal := l_TotLib;
         i := 1;
         FOR i IN 1..7 LOOP
            IF t_Liabilities(i).Lib >= 0 THEN
               hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',16);
               NULL;
            ELSE -- l_lib < 0
               hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',17);
               -- Has the liability been Overridden?
               IF t_Liabilities(i).Ovrrde THEN
                  hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',18);
                  NULL;
               ELSE
                  hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',19);
                  l_NewLib := t_Liabilities(i).Lib - GREATEST(t_Liabilities(i).Lib,l_RecVal);
                  l_RecVal := l_RecVal - (t_Liabilities(i).Lib - l_NewLib);
                  t_Liabilities(i).Lib := l_NewLib;
               END IF;
           END IF;
         END LOOP;
      END IF;
   END IF;

   hr_utility.set_location('py_za_tx_utl_01032004.ValidateTaxOns',20);

   py_za_tx_01032004.trc_LibFpNI := t_Liabilities(1).Lib;
   py_za_tx_01032004.trc_LibFpFB := t_Liabilities(2).Lib;
   py_za_tx_01032004.trc_LibFpTA := t_Liabilities(3).Lib;
   py_za_tx_01032004.trc_LibFpBP := t_Liabilities(4).Lib;
   py_za_tx_01032004.trc_LibFpAB := t_Liabilities(5).Lib;
   py_za_tx_01032004.trc_LibFpAP := t_Liabilities(6).Lib;
   py_za_tx_01032004.trc_LibFpPO := t_Liabilities(7).Lib;

   WriteHrTrace('py_za_tx_01032004.trc_LibFpNI: '||to_char(py_za_tx_01032004.trc_LibFpNI));
   WriteHrTrace('py_za_tx_01032004.trc_LibFpFB: '||to_char(py_za_tx_01032004.trc_LibFpFB));
   WriteHrTrace('py_za_tx_01032004.trc_LibFpTA: '||to_char(py_za_tx_01032004.trc_LibFpTA));
   WriteHrTrace('py_za_tx_01032004.trc_LibFpBP: '||to_char(py_za_tx_01032004.trc_LibFpBP));
   WriteHrTrace('py_za_tx_01032004.trc_LibFpAB: '||to_char(py_za_tx_01032004.trc_LibFpAB));
   WriteHrTrace('py_za_tx_01032004.trc_LibFpAP: '||to_char(py_za_tx_01032004.trc_LibFpAP));
   WriteHrTrace('py_za_tx_01032004.trc_LibFpPO: '||to_char(py_za_tx_01032004.trc_LibFpPO));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'ValidateTaxOns: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END ValidateTaxOns;
-------------------------------------------------------------------------------
-- DaysWorked                                                                --
--  Returns the number of days that the person has worked                    --
--    This could be a negative number that would indicate                    --
--    a LatePayePeriod                                                       --
-------------------------------------------------------------------------------
FUNCTION DaysWorked RETURN NUMBER
AS
   l_DaysWorked NUMBER;
   l_EndDte     DATE;
   l_StrtDte    DATE;

BEGIN
   IF py_za_tx_01032004.trc_OvrTxCalc AND py_za_tx_01032004.trc_OvrTyp = 'V' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.DaysWorked',1);
      IF LatePayPeriod THEN
         hr_utility.set_location('py_za_tx_utl_01032004.DaysWorked',2);
         -- This will set the sitfactor = 1
         l_EndDte  := py_za_tx_01032004.dbi_ZA_TX_YR_END;
         l_StrtDte := py_za_tx_01032004.dbi_ZA_TX_YR_STRT;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032004.DaysWorked',3);
         l_EndDte  := LEAST(py_za_tx_01032004.dbi_ZA_ACT_END_DTE, py_za_tx_01032004.dbi_ZA_CUR_PRD_END_DTE);
         l_StrtDte := GREATEST(py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE, py_za_tx_01032004.dbi_ZA_TX_YR_STRT);
      END IF;

   ELSIF py_za_tx_01032004.trc_CalTyp = 'YtdCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.DaysWorked',4);
      l_EndDte  := py_za_tx_01032004.dbi_ZA_CUR_PRD_STRT_DTE - 1;
      l_StrtDte := GREATEST(py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE, py_za_tx_01032004.dbi_ZA_TX_YR_STRT);

   ELSIF py_za_tx_01032004.trc_CalTyp = 'CalCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.DaysWorked',5);
      l_EndDte  := py_za_tx_01032004.dbi_ZA_TX_YR_STRT - 1;
      l_StrtDte := GREATEST(py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE,
      to_date('01/01/'||to_char(to_number(to_char(py_za_tx_01032004.dbi_ZA_TX_YR_END,'YYYY'))-1),'DD/MM/YYYY'));

   ELSIF py_za_tx_01032004.trc_CalTyp = 'SitCalc' AND
       ( py_za_tx_01032004.dbi_ZA_ASG_TX_RTR_PRD = 'Y'
      OR py_za_tx_01032004.trc_OvrTxCalc
      OR py_za_tx_01032004.trc_NegPtd
       )THEN
      hr_utility.set_location('py_za_tx_utl_01032004.DaysWorked',6);
      l_EndDte  := LEAST(py_za_tx_01032004.dbi_ZA_ACT_END_DTE, py_za_tx_01032004.dbi_ZA_CUR_PRD_END_DTE);
      l_StrtDte := GREATEST(py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE, py_za_tx_01032004.dbi_ZA_TX_YR_STRT);

   ELSIF py_za_tx_01032004.trc_CalTyp = 'SitCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.DaysWorked',7);
      l_EndDte  := LEAST(py_za_tx_01032004.dbi_ZA_ACT_END_DTE, py_za_tx_01032004.dbi_ZA_TX_YR_END);
      l_StrtDte := GREATEST(py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE, py_za_tx_01032004.dbi_ZA_TX_YR_STRT);

   ELSIF py_za_tx_01032004.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.DaysWorked',8);
      l_EndDte := py_za_tx_01032004.dbi_ZA_ACT_END_DTE;
      l_StrtDte := py_za_tx_01032004.dbi_ZA_ASG_TX_YR_STRT;

      hr_utility.set_location('py_za_tx_utl_01032004.DaysWorked',9);

      l_StrtDte := GREATEST(py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE, l_StrtDte);
   END IF;

   l_DaysWorked := l_EndDte - l_StrtDte + 1;

   WriteHrTrace('l_EndDte:     '||to_char(l_EndDte,'DD/MM/YYYY'));
   WriteHrTrace('l_StrtDte:    '||to_char(l_StrtDte,'DD/MM/YYYY'));
   WriteHrTrace('l_DaysWorked: '||to_char(l_DaysWorked));

   RETURN l_DaysWorked;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'DaysWorked: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END DaysWorked;
-------------------------------------------------------------------------------
-- SitPaySplit                                                               --
-------------------------------------------------------------------------------
PROCEDURE SitPaySplit
AS
   l_TxOnSitLim t_Balance;
   l_SitAblTx t_Balance;
BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',1);
-- Directive Type Statuses
--
   IF py_za_tx_01032004.dbi_TX_STA IN ('C','D','E','F','J','K','L','N','P') THEN
      hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',2);
   -- Check for SitePeriod
      IF SitePeriod THEN
         hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',3);
         py_za_tx_01032004.trc_PayeVal :=
            ( py_za_tx_01032004.bal_TAX_YTD
            + py_za_tx_01032004.trc_LibFpNI
            + py_za_tx_01032004.trc_LibFpFB
            + py_za_tx_01032004.trc_LibFpTA
            + py_za_tx_01032004.trc_LibFpBP
            + py_za_tx_01032004.trc_LibFpAB
            + py_za_tx_01032004.trc_LibFpAP
            + py_za_tx_01032004.trc_LibFpPO
            ) - py_za_tx_01032004.bal_PAYE_YTD;
         py_za_tx_01032004.trc_SiteVal := -1*py_za_tx_01032004.bal_SITE_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',4);
         py_za_tx_01032004.trc_PayeVal := -1*py_za_tx_01032004.bal_PAYE_YTD;
         py_za_tx_01032004.trc_SiteVal := -1*py_za_tx_01032004.bal_SITE_YTD;
      END IF;
-- Normal Type Statuses
--
   ELSIF py_za_tx_01032004.dbi_TX_STA IN ('A','B') THEN
      IF (SitePeriod AND NOT PreErnPeriod) OR EmpTermPrePeriod THEN
         hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',5);
      -- Get the Tax Liability on the Site Limit
         l_TxOnSitLim := TaxLiability(p_Amt => py_za_tx_01032004.glb_ZA_SIT_LIM)/py_za_tx_01032004.trc_SitFactor;
      -- Get the Tax Amount Liable for SITE
         l_SitAblTx :=
         ( py_za_tx_01032004.bal_TX_ON_NI_YTD
         + py_za_tx_01032004.bal_TX_ON_FB_YTD
         + py_za_tx_01032004.bal_TX_ON_BP_YTD
         + py_za_tx_01032004.bal_TX_ON_AB_YTD
         + py_za_tx_01032004.bal_TX_ON_AP_YTD
         + py_za_tx_01032004.trc_LibFpNI
         + py_za_tx_01032004.trc_LibFpFB
         + py_za_tx_01032004.trc_LibFpBP
         + py_za_tx_01032004.trc_LibFpAB
         + py_za_tx_01032004.trc_LibFpAP
         );
      -- Check the Limit
         IF l_SitAblTx > l_TxOnSitLim THEN
            hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',6);
            py_za_tx_01032004.trc_SiteVal := l_TxOnSitLim - py_za_tx_01032004.bal_SITE_YTD;
            py_za_tx_01032004.trc_PayeVal := (
              ( py_za_tx_01032004.bal_TAX_YTD
              + py_za_tx_01032004.trc_LibFpNI
              + py_za_tx_01032004.trc_LibFpFB
              + py_za_tx_01032004.trc_LibFpBP
              + py_za_tx_01032004.trc_LibFpAB
              + py_za_tx_01032004.trc_LibFpAP
              + py_za_tx_01032004.trc_LibFpTA
              + py_za_tx_01032004.trc_LibFpPO
              ) - l_TxOnSitLim) - py_za_tx_01032004.bal_PAYE_YTD;

         ELSE
            hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',7);
            IF ( py_za_tx_01032004.bal_TX_ON_TA_YTD
               + py_za_tx_01032004.trc_LibFpTA
               + py_za_tx_01032004.bal_TX_ON_PO_YTD
               + py_za_tx_01032004.trc_LibFpPO
               ) <= 0 THEN
               hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',8);
               py_za_tx_01032004.trc_SiteVal := ( py_za_tx_01032004.bal_TAX_YTD
                              + py_za_tx_01032004.trc_LibFpNI
                              + py_za_tx_01032004.trc_LibFpFB
                              + py_za_tx_01032004.trc_LibFpBP
                              + py_za_tx_01032004.trc_LibFpAB
                              + py_za_tx_01032004.trc_LibFpAP
                              + py_za_tx_01032004.trc_LibFpTA
                              + py_za_tx_01032004.trc_LibFpPO) - py_za_tx_01032004.bal_SITE_YTD;

               py_za_tx_01032004.trc_PayeVal := -1*py_za_tx_01032004.bal_PAYE_YTD;
            ELSE
               hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',9);
               py_za_tx_01032004.trc_SiteVal := l_SitAblTx - py_za_tx_01032004.bal_SITE_YTD;

               py_za_tx_01032004.trc_PayeVal := (
                 ( py_za_tx_01032004.bal_TAX_YTD
                 + py_za_tx_01032004.trc_LibFpNI
                 + py_za_tx_01032004.trc_LibFpFB
                 + py_za_tx_01032004.trc_LibFpBP
                 + py_za_tx_01032004.trc_LibFpAB
                 + py_za_tx_01032004.trc_LibFpAP
                 + py_za_tx_01032004.trc_LibFpTA
                 + py_za_tx_01032004.trc_LibFpPO
                 ) - l_SitAblTx) - py_za_tx_01032004.bal_PAYE_YTD;
            END IF;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',10);
         py_za_tx_01032004.trc_PayeVal := -1*py_za_tx_01032004.bal_PAYE_YTD;
         py_za_tx_01032004.trc_SiteVal := -1*py_za_tx_01032004.bal_SITE_YTD;
      END IF;
-- Seasonal Worker Status
--
   ELSIF py_za_tx_01032004.dbi_TX_STA = 'G' THEN
      hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',11);
   -- Get the SitFactor YTD
      py_za_tx_01032004.trc_SitFactor := py_za_tx_01032004.glb_ZA_WRK_DYS_PR_YR / py_za_tx_01032004.bal_TOT_SEA_WRK_DYS_WRK_YTD;
   -- Get the Tax Liability on the Site Limit
      l_TxOnSitLim := TaxLiability(p_Amt => py_za_tx_01032004.glb_ZA_SIT_LIM)/py_za_tx_01032004.trc_SitFactor;
   -- Get the Tax Amount Liable for SITE
      l_SitAblTx := ( py_za_tx_01032004.bal_TX_ON_NI_YTD
                    + py_za_tx_01032004.bal_TX_ON_FB_YTD
                    + py_za_tx_01032004.bal_TX_ON_AP_YTD
                    + py_za_tx_01032004.trc_LibFpNI
                    + py_za_tx_01032004.trc_LibFpFB
                    + py_za_tx_01032004.trc_LibFpAP
                    );
   -- Check the Limit
      IF l_SitAblTx > l_TxOnSitLim THEN
         hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',12);
         py_za_tx_01032004.trc_SiteVal := l_TxOnSitLim - py_za_tx_01032004.bal_SITE_YTD;
         py_za_tx_01032004.trc_PayeVal := ( (py_za_tx_01032004.bal_TX_ON_PO_YTD + py_za_tx_01032004.trc_LibFpPO)
                                          + (l_SitAblTx - l_TxOnSitLim)
                                          ) - py_za_tx_01032004.bal_PAYE_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',13);
         py_za_tx_01032004.trc_SiteVal := l_SitAblTx - py_za_tx_01032004.bal_SITE_YTD;
         py_za_tx_01032004.trc_PayeVal := py_za_tx_01032004.bal_TX_ON_PO_YTD
                                        + py_za_tx_01032004.trc_LibFpPO
                                        - py_za_tx_01032004.bal_PAYE_YTD;
      END IF;
-- Private Director
--
   ELSIF py_za_tx_01032004.dbi_TX_STA = 'M' THEN
      IF (SitePeriod AND NOT PreErnPeriod) OR EmpTermPrePeriod THEN
         hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',14);
         py_za_tx_01032004.trc_PayeVal :=
            ( py_za_tx_01032004.bal_TAX_YTD
            + py_za_tx_01032004.trc_LibFpDR
            + py_za_tx_01032004.trc_LibFpNI
            + py_za_tx_01032004.trc_LibFpFB
            + py_za_tx_01032004.trc_LibFpTA
            + py_za_tx_01032004.trc_LibFpBP
            + py_za_tx_01032004.trc_LibFpAB
            + py_za_tx_01032004.trc_LibFpAP
            + py_za_tx_01032004.trc_LibFpPO
            ) - py_za_tx_01032004.bal_PAYE_YTD;
         py_za_tx_01032004.trc_SiteVal := -1*py_za_tx_01032004.bal_SITE_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',15);
         py_za_tx_01032004.trc_PayeVal := -1*py_za_tx_01032004.bal_PAYE_YTD;
         py_za_tx_01032004.trc_SiteVal := -1*py_za_tx_01032004.bal_SITE_YTD;
      END IF;
-- All Other Statuses
--
   ELSE -- set the globals to zero
      hr_utility.set_location('py_za_tx_utl_01032004.SitPaySplit',16);
      py_za_tx_01032004.trc_PayeVal := 0 - py_za_tx_01032004.bal_PAYE_YTD;
      py_za_tx_01032004.trc_SiteVal := 0 - py_za_tx_01032004.bal_SITE_YTD;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'SitPaySplit: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END SitPaySplit;
-------------------------------------------------------------------------------
-- Trace Function                                                            --
-------------------------------------------------------------------------------
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
   ,BP_TX_RCV
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
   ,AnnArrPenFnd
   ,AnnArrPenFndAbm
   ,RetAnu
   ,NrfiCon
   ,RetAnuMax
   ,RetAnuAbm
   ,AnnRetAnu
   ,AnnNrfiCon
   ,AnnRetAnuMax
   ,AnnRetAnuAbm
   ,ArrRetAnu
   ,ArrRetAnuAbm
   ,AnnArrRetAnu
   ,AnnArrRetAnuAbm
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
   ,LibWrn
   ,PayValue
   ,PayeVal
   ,SiteVal
   )
   VALUES(
    py_za_tx_01032004.con_ASG_ACT_ID
   ,py_za_tx_01032004.con_ASG_ID
   ,py_za_tx_01032004.con_PRL_ACT_ID
   ,py_za_tx_01032004.con_PRL_ID
   ,py_za_tx_01032004.dbi_TX_STA
   ,py_za_tx_01032004.dbi_PER_AGE
   ,py_za_tx_01032004.trc_CalTyp
   ,py_za_tx_01032004.dbi_TX_DIR_VAL
   ,py_za_tx_01032004.trc_It3Ind
   ,py_za_tx_01032004.trc_TxPercVal
   ,py_za_tx_01032004.dbi_ZA_ACT_STRT_DTE
   ,py_za_tx_01032004.dbi_ZA_ACT_END_DTE
   ,py_za_tx_01032004.dbi_ZA_CUR_PRD_STRT_DTE
   ,py_za_tx_01032004.dbi_ZA_CUR_PRD_END_DTE
   ,py_za_tx_01032004.dbi_ZA_TX_YR_STRT
   ,py_za_tx_01032004.dbi_ZA_TX_YR_END
   ,py_za_tx_01032004.dbi_SES_DTE
   ,py_za_tx_01032004.trc_PrdFactor
   ,py_za_tx_01032004.trc_PosFactor
   ,py_za_tx_01032004.trc_SitFactor
   ,py_za_tx_01032004.dbi_ZA_PAY_PRDS_LFT
   ,py_za_tx_01032004.dbi_ZA_PAY_PRDS_PER_YR
   ,py_za_tx_01032004.dbi_ZA_DYS_IN_YR
   ,py_za_tx_01032004.dbi_SEA_WRK_DYS_WRK
   ,py_za_tx_01032004.dbi_BP_TX_RCV
   ,py_za_tx_01032004.trc_TxbIncPtd
   ,py_za_tx_01032004.trc_BseErn
   ,py_za_tx_01032004.trc_TxbBseInc
   ,py_za_tx_01032004.trc_TotLibBse
   ,py_za_tx_01032004.trc_TxbIncYtd
   ,py_za_tx_01032004.trc_PerTxbInc
   ,py_za_tx_01032004.trc_PerPenFnd
   ,py_za_tx_01032004.trc_PerRfiCon
   ,py_za_tx_01032004.trc_PerRfiTxb
   ,py_za_tx_01032004.trc_PerPenFndMax
   ,py_za_tx_01032004.trc_PerPenFndAbm
   ,py_za_tx_01032004.trc_AnnTxbInc
   ,py_za_tx_01032004.trc_AnnPenFnd
   ,py_za_tx_01032004.trc_AnnRfiCon
   ,py_za_tx_01032004.trc_AnnRfiTxb
   ,py_za_tx_01032004.trc_AnnPenFndMax
   ,py_za_tx_01032004.trc_AnnPenFndAbm
   ,py_za_tx_01032004.trc_PerArrPenFnd
   ,py_za_tx_01032004.trc_PerArrPenFndAbm
   ,py_za_tx_01032004.trc_AnnArrPenFnd
   ,py_za_tx_01032004.trc_AnnArrPenFndAbm
   ,py_za_tx_01032004.trc_PerRetAnu
   ,py_za_tx_01032004.trc_PerNrfiCon
   ,py_za_tx_01032004.trc_PerRetAnuMax
   ,py_za_tx_01032004.trc_PerRetAnuAbm
   ,py_za_tx_01032004.trc_AnnRetAnu
   ,py_za_tx_01032004.trc_AnnNrfiCon
   ,py_za_tx_01032004.trc_AnnRetAnuMax
   ,py_za_tx_01032004.trc_AnnRetAnuAbm
   ,py_za_tx_01032004.trc_PerArrRetAnu
   ,py_za_tx_01032004.trc_PerArrRetAnuAbm
   ,py_za_tx_01032004.trc_AnnArrRetAnu
   ,py_za_tx_01032004.trc_AnnArrRetAnuAbm
   ,py_za_tx_01032004.trc_Rebate
   ,py_za_tx_01032004.trc_Threshold
   ,py_za_tx_01032004.trc_MedAidAbm
   ,py_za_tx_01032004.trc_PerTotAbm
   ,py_za_tx_01032004.trc_AnnTotAbm
   ,py_za_tx_01032004.trc_NorIncYtd
   ,py_za_tx_01032004.trc_NorIncPtd
   ,py_za_tx_01032004.trc_NorErn
   ,py_za_tx_01032004.trc_TxbNorInc
   ,py_za_tx_01032004.trc_LibFyNI
   ,py_za_tx_01032004.bal_TX_ON_NI_YTD
   ,py_za_tx_01032004.bal_TX_ON_NI_PTD
   ,py_za_tx_01032004.trc_LibFpNI
   ,py_za_tx_01032004.trc_FrnBenYtd
   ,py_za_tx_01032004.trc_FrnBenPtd
   ,py_za_tx_01032004.trc_FrnBenErn
   ,py_za_tx_01032004.trc_TxbFrnInc
   ,py_za_tx_01032004.trc_LibFyFB
   ,py_za_tx_01032004.bal_TX_ON_FB_YTD
   ,py_za_tx_01032004.bal_TX_ON_FB_PTD
   ,py_za_tx_01032004.trc_LibFpFB
   ,py_za_tx_01032004.trc_TrvAllYtd
   ,py_za_tx_01032004.trc_TrvAllPtd
   ,py_za_tx_01032004.trc_TrvAllErn
   ,py_za_tx_01032004.trc_TxbTrvInc
   ,py_za_tx_01032004.trc_LibFyTA
   ,py_za_tx_01032004.bal_TX_ON_TA_YTD
   ,py_za_tx_01032004.bal_TX_ON_TA_PTD
   ,py_za_tx_01032004.trc_LibFpTA
   ,py_za_tx_01032004.trc_BonProYtd
   ,py_za_tx_01032004.trc_BonProPtd
   ,py_za_tx_01032004.trc_BonProErn
   ,py_za_tx_01032004.trc_TxbBonProInc
   ,py_za_tx_01032004.trc_LibFyBP
   ,py_za_tx_01032004.bal_TX_ON_BP_YTD
   ,py_za_tx_01032004.bal_TX_ON_BP_PTD
   ,py_za_tx_01032004.trc_LibFpBP
   ,py_za_tx_01032004.trc_AnnBonYtd
   ,py_za_tx_01032004.trc_AnnBonErn
   ,py_za_tx_01032004.trc_TxbAnnBonInc
   ,py_za_tx_01032004.trc_LibFyAB
   ,py_za_tx_01032004.bal_TX_ON_AB_YTD
   ,py_za_tx_01032004.bal_TX_ON_AB_PTD
   ,py_za_tx_01032004.trc_LibFpAB
   ,py_za_tx_01032004.trc_AnnPymYtd
   ,py_za_tx_01032004.trc_AnnPymPtd
   ,py_za_tx_01032004.trc_AnnPymErn
   ,py_za_tx_01032004.trc_TxbAnnPymInc
   ,py_za_tx_01032004.trc_LibFyAP
   ,py_za_tx_01032004.bal_TX_ON_AP_YTD
   ,py_za_tx_01032004.bal_TX_ON_AP_PTD
   ,py_za_tx_01032004.trc_LibFpAP
   ,py_za_tx_01032004.trc_PblOffYtd
   ,py_za_tx_01032004.trc_PblOffPtd
   ,py_za_tx_01032004.trc_PblOffErn
   ,py_za_tx_01032004.trc_LibFyPO
   ,py_za_tx_01032004.bal_TX_ON_PO_YTD
   ,py_za_tx_01032004.bal_TX_ON_PO_PTD
   ,py_za_tx_01032004.trc_LibFpPO
   ,py_za_tx_01032004.trc_LibWrn
   ,py_za_tx_01032004.trc_PayValSD
   ,py_za_tx_01032004.trc_PayeVal
   ,py_za_tx_01032004.trc_SiteVal);

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'Trace: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END Trace;
-------------------------------------------------------------------------------
-- ClearGlobals                                                              --
-------------------------------------------------------------------------------
PROCEDURE ClearGlobals AS

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032004.ClearGlobals',1);
   -- Calculation Type
   py_za_tx_01032004.trc_CalTyp               := 'Unknown';
   -- Factors
   py_za_tx_01032004.trc_TxbIncPtd            := 0;
   py_za_tx_01032004.trc_PrdFactor            := 0;
   py_za_tx_01032004.trc_PosFactor            := 0;
   py_za_tx_01032004.trc_SitFactor            := 1;
   -- Deemed Remuneration
   py_za_tx_01032004.trc_DmdRmnRun            := 0;
   py_za_tx_01032004.trc_TxbDmdRmn            := 0;
   py_za_tx_01032004.trc_TotLibDR             := 0;
   py_za_tx_01032004.trc_LibFyDR              := 0;
   py_za_tx_01032004.trc_LibFpDR              := 0;
   -- Base Income
   py_za_tx_01032004.trc_BseErn               := 0;
   py_za_tx_01032004.trc_TxbBseInc            := 0;
   py_za_tx_01032004.trc_TotLibBse            := 0;
   -- Fixed Pension Basis
   py_za_tx_01032004.trc_PerTxbPkg            := 0;
   py_za_tx_01032004.trc_AnnTxbPkg            := 0;
   py_za_tx_01032004.trc_TotPkg               := 0;
   py_za_tx_01032004.trc_TxbFxdPrc            := 0;
   py_za_tx_01032004.trc_PerRFITotPkgPTD      := 0;
   py_za_tx_01032004.trc_PerNRFITotPkgPTD     := 0;
   py_za_tx_01032004.trc_AnnRFITotPkgPTD      := 0;
   py_za_tx_01032004.trc_AnnNRFITotPkgPTD     := 0;
   py_za_tx_01032004.trc_PerRFITotPkgPTD_Upd  := 0;
   py_za_tx_01032004.trc_PerNRFITotPkgPTD_Upd := 0;
   py_za_tx_01032004.trc_AnnRFITotPkgPTD_Upd  := 0;
   py_za_tx_01032004.trc_AnnNRFITotPkgPTD_Upd := 0;
   -- Period Pension Fund
   py_za_tx_01032004.trc_TxbIncYtd            := 0;
   py_za_tx_01032004.trc_PerTxbInc            := 0;
   py_za_tx_01032004.trc_PerPenFnd            := 0;
   py_za_tx_01032004.trc_PerRfiCon            := 0;
   py_za_tx_01032004.trc_PerRfiTxb            := 0;
   py_za_tx_01032004.trc_PerPenFndMax         := 0;
   py_za_tx_01032004.trc_PerPenFndAbm         := 0;
   -- Annual Pension Fund
   py_za_tx_01032004.trc_AnnTxbInc            := 0;
   py_za_tx_01032004.trc_AnnPenFnd            := 0;
   py_za_tx_01032004.trc_AnnRfiCon            := 0;
   py_za_tx_01032004.trc_AnnRfiTxb            := 0;
   py_za_tx_01032004.trc_AnnPenFndMax         := 0;
   py_za_tx_01032004.trc_AnnPenFndAbm         := 0;
   -- Period Arrear Pension
   py_za_tx_01032004.trc_PerArrPenFnd         := 0;
   py_za_tx_01032004.trc_PerArrPenFndAbm      := 0;
   -- Annual Arrear Pension
   py_za_tx_01032004.trc_AnnArrPenFnd         := 0;
   py_za_tx_01032004.trc_AnnArrPenFndAbm      := 0;
   -- Arrear Excess Update Value
   py_za_tx_01032004.trc_PfUpdFig             := 0;
   -- Period Retirement Annuity
   py_za_tx_01032004.trc_PerRetAnu            := 0;
   py_za_tx_01032004.trc_PerNrfiCon           := 0;
   py_za_tx_01032004.trc_PerRetAnuMax         := 0;
   py_za_tx_01032004.trc_PerRetAnuAbm         := 0;
   -- Annual Retirement Annuity
   py_za_tx_01032004.trc_AnnRetAnu            := 0;
   py_za_tx_01032004.trc_AnnNrfiCon           := 0;
   py_za_tx_01032004.trc_AnnRetAnuMax         := 0;
   py_za_tx_01032004.trc_AnnRetAnuAbm         := 0;
   -- Period Arrear Retirement Annuity
   py_za_tx_01032004.trc_PerArrRetAnu         := 0;
   py_za_tx_01032004.trc_PerArrRetAnuAbm      := 0;
   -- Annual Arrear Retirement Annuity
   py_za_tx_01032004.trc_AnnArrRetAnu         := 0;
   py_za_tx_01032004.trc_AnnArrRetAnuAbm      := 0;
   -- Arrear Excess Update Value
   py_za_tx_01032004.trc_RaUpdFig             := 0;
   -- Rebates Thresholds and Med Aid
   py_za_tx_01032004.trc_Rebate               := 0;
   py_za_tx_01032004.trc_Threshold            := 0;
   py_za_tx_01032004.trc_MedAidAbm            := 0;
   -- Abatement Totals
   py_za_tx_01032004.trc_PerTotAbm            := 0;
   py_za_tx_01032004.trc_AnnTotAbm            := 0;
   -- Normal Income
   py_za_tx_01032004.trc_NorIncYtd            := 0;
   py_za_tx_01032004.trc_NorIncPtd            := 0;
   py_za_tx_01032004.trc_NorErn               := 0;
   py_za_tx_01032004.trc_TxbNorInc            := 0;
   py_za_tx_01032004.trc_TotLibNI             := 0;
   py_za_tx_01032004.trc_LibFyNI              := 0;
   py_za_tx_01032004.trc_LibFpNI              := 0;
   -- Fringe Benefits
   py_za_tx_01032004.trc_FrnBenYtd            := 0;
   py_za_tx_01032004.trc_FrnBenPtd            := 0;
   py_za_tx_01032004.trc_FrnBenErn            := 0;
   py_za_tx_01032004.trc_TxbFrnInc            := 0;
   py_za_tx_01032004.trc_TotLibFB             := 0;
   py_za_tx_01032004.trc_LibFyFB              := 0;
   py_za_tx_01032004.trc_LibFpFB              := 0;
   -- Travel Allowance
   py_za_tx_01032004.trc_TrvAllYtd            := 0;
   py_za_tx_01032004.trc_TrvAllPtd            := 0;
   py_za_tx_01032004.trc_TrvAllErn            := 0;
   py_za_tx_01032004.trc_TxbTrvInc            := 0;
   py_za_tx_01032004.trc_TotLibTA             := 0;
   py_za_tx_01032004.trc_LibFyTA              := 0;
   py_za_tx_01032004.trc_LibFpTA              := 0;
   -- Bonus Provision
   py_za_tx_01032004.trc_BonProYtd            := 0;
   py_za_tx_01032004.trc_BonProPtd            := 0;
   py_za_tx_01032004.trc_BonProErn            := 0;
   py_za_tx_01032004.trc_TxbBonProInc         := 0;
   py_za_tx_01032004.trc_TotLibBP             := 0;
   py_za_tx_01032004.trc_LibFyBP              := 0;
   py_za_tx_01032004.trc_LibFpBP              := 0;
   -- Annual Bonus
   py_za_tx_01032004.trc_AnnBonYtd            := 0;
   py_za_tx_01032004.trc_AnnBonPtd            := 0;
   py_za_tx_01032004.trc_AnnBonErn            := 0;
   py_za_tx_01032004.trc_TxbAnnBonInc         := 0;
   py_za_tx_01032004.trc_TotLibAB             := 0;
   py_za_tx_01032004.trc_LibFyAB              := 0;
   py_za_tx_01032004.trc_LibFpAB              := 0;
   -- Annual Payments
   py_za_tx_01032004.trc_AnnPymYtd            := 0;
   py_za_tx_01032004.trc_AnnPymPtd            := 0;
   py_za_tx_01032004.trc_AnnPymErn            := 0;
   py_za_tx_01032004.trc_TxbAnnPymInc         := 0;
   py_za_tx_01032004.trc_TotLibAP             := 0;
   py_za_tx_01032004.trc_LibFyAP              := 0;
   py_za_tx_01032004.trc_LibFpAP              := 0;
   -- Pubilc Office Allowance
   py_za_tx_01032004.trc_PblOffYtd            := 0;
   py_za_tx_01032004.trc_PblOffPtd            := 0;
   py_za_tx_01032004.trc_PblOffErn            := 0;
   py_za_tx_01032004.trc_LibFyPO              := 0;
   py_za_tx_01032004.trc_LibFpPO              := 0;
   -- Messages
   py_za_tx_01032004.trc_LibWrn               := ' ';

   -- Statutory Deduction Value
   py_za_tx_01032004.trc_PayValSD             := 0;
   -- Employer Contribution Value
   py_za_tx_01032004.trc_PayValEC             := 0;
   -- PAYE and SITE Values
   py_za_tx_01032004.trc_PayeVal              := 0;
   py_za_tx_01032004.trc_SiteVal              := 0;
   -- IT3A Threshold Indicator
   py_za_tx_01032004.trc_It3Ind               := 0;
   -- Tax Percentage Value On trace
   py_za_tx_01032004.trc_TxPercVal            := 0;
   -- Total Taxable Income Update Figure
   py_za_tx_01032004.trc_OUpdFig              := 0;

   -- Net Taxable Income Update Figure
   py_za_tx_01032004.trc_NtiUpdFig            := 0;

   -- ValidateTaxOns Override Globals
   py_za_tx_01032004.trc_LibFpDROvr           := FALSE;
   py_za_tx_01032004.trc_LibFpNIOvr           := FALSE;
   py_za_tx_01032004.trc_LibFpFBOvr           := FALSE;
   py_za_tx_01032004.trc_LibFpTAOvr           := FALSE;
   py_za_tx_01032004.trc_LibFpBPOvr           := FALSE;
   py_za_tx_01032004.trc_LibFpABOvr           := FALSE;
   py_za_tx_01032004.trc_LibFpAPOvr           := FALSE;
   py_za_tx_01032004.trc_LibFpPOOvr           := FALSE;

   -- Global Exception Message
   py_za_tx_01032004.xpt_Msg                  := 'No Error';

   -- Override Globals
   py_za_tx_01032004.trc_OvrTxCalc            := FALSE;
   py_za_tx_01032004.trc_OvrTyp               := 'V';
   py_za_tx_01032004.trc_OvrPrc               := 0;
   py_za_tx_01032004.trc_OvrWrn               := ' ';

   -- Negative Ptd Global
   py_za_tx_01032004.trc_NegPtd               := FALSE;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032004.xpt_Msg = 'No Error' THEN
         py_za_tx_01032004.xpt_Msg := 'ClearGlobals: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032004.xpt_E;
END ClearGlobals;



END py_za_tx_utl_01032004;


/
