--------------------------------------------------------
--  DDL for Package Body PY_ZA_TX_UTL_01032000
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_TX_UTL_01032000" AS
/* $Header: pyzatu01.pkb 120.2 2005/06/28 00:12:22 kapalani noship $ */
/* Copyright (c) Oracle Corporation 2000. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation Tax Module

   NAME
      py_za_tx_utl_01032000.pkb

   DESCRIPTION
      This is the ZA Tax Module utility package.  It contains
      functions and procedures used by the main tax package.

   PUBLIC FUNCTIONS
      GlbVal
         Returns the value of a Oracle Application Global
         date effectively
      RetroInPrd
         Boolean function returns true if a retro action
         took place in the specified period
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
      A. Mahanty  14/04/2005         115.4     Bug 3491357 BRA Enhancement.
                                               Balance value retrieval modified
      L.Kloppers  31/01/2001         115.0     Changed ptp.attribute1 to
                                                       ptp.prd_information1
      J.N. Louw   13/12/2000         110.3     Updated SitPaySplit to fire for
                                                  Latepayperiod
      J.N. Louw   28/09/2000         110.2     Added SetRebates procedure
                                               Modified Abatements procedure
      J.N. Louw   28/09/2000         110.1     Fixed NpVal Bug
      J.N. Louw   27/09/2000         110.0     First Created
*/

/* PACKAGE BODY */

-- StartHrTrace
-- Wrapper for hr_utility.trace_on
PROCEDURE StartHrTrace AS
BEGIN
   IF g_HrTraceEnabled THEN
      hr_utility.trace_on(null,g_HrTracePipeName);
   END IF;
END StartHrTrace;

-- StopHrTrace
-- Wrapper for hr_utility.trace_off
PROCEDURE StopHrTrace AS
BEGIN
   IF g_HrTraceEnabled THEN
      hr_utility.trace_off;
   END IF;
END StopHrTrace;

-- WriteHrTrace
-- Wrapper for hr_utility.trace
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



-- Tax Utility Functions
--

FUNCTION GlbVal
   (p_GlbNme ff_globals_f.global_name%TYPE
   ,p_EffDte DATE
   ) RETURN ff_globals_f.global_value%TYPE
AS
-- Variables
   l_GlbVal NUMBER(15,2);
BEGIN
   hr_utility.set_location('py_za_tx_utl_01032000.GlbVal',1);
   WriteHrTrace('p_GlbNme :'||p_GlbNme);
   WriteHrTrace('p_EffDte :'||to_char(p_EffDte,'DD/MM/YYYY'));
   --
   SELECT TO_NUMBER(global_value)
     INTO l_GlbVal
     FROM ff_globals_f
    WHERE p_EffDte between effective_start_date and effective_end_date
      AND global_name = p_GlbNme;

   hr_utility.set_location('py_za_tx_utl_01032000.GlbVal',2);
   RETURN l_GlbVal;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'GlbVal: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END GlbVal;

FUNCTION RetroInPrd RETURN BOOLEAN AS
   CURSOR c_RetActs(
        p_AsgId       pay_assignment_actions.assignment_id%TYPE
      , p_AsgActSeq   pay_assignment_actions.action_sequence%TYPE
      , p_TimPrdId    pay_payroll_actions.time_period_id%TYPE
      )
   IS
      SELECT 1
        FROM pay_payroll_actions ppa
           , pay_assignment_actions paa
       WHERE paa.assignment_id = p_AsgId
         AND paa.action_sequence < p_AsgActSeq
         AND paa.payroll_action_id = ppa.payroll_action_id
         AND ppa.time_period_id = p_TimPrdId
         AND ppa.action_status = 'C'
         AND ppa.action_type IN ('O','G');

   l_AsgActSeq     pay_assignment_actions.action_sequence%TYPE;
   l_TimPrdId      pay_payroll_actions.time_period_id%TYPE;
   v_RetActs       c_RetActs%ROWTYPE;
--   l_RetroInPeriod BOOLEAN DEFAULT FALSE;

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032000.RetroInPrd',1);
-- Get Assignment_Action.Action_Sequence
   SELECT paa.action_sequence
        , ppa.time_period_id
     INTO l_AsgActSeq
        , l_TimPrdId
     FROM pay_assignment_actions paa
        , pay_payroll_actions ppa
    WHERE paa.assignment_action_id = py_za_tx_01032000.con_ASG_ACT_ID
      AND paa.payroll_action_id = ppa.payroll_action_id;

   hr_utility.set_location('py_za_tx_utl_01032000.RetroInPrd',2);
   WriteHrTrace('p_AsgId: '||to_char(py_za_tx_01032000.con_ASG_ID));
   WriteHrTrace('p_AsgActSeq: '||to_char(l_AsgActSeq));
   WriteHrTrace('p_TimPrdId: '||to_char(l_TimPrdId));

-- Was there a Retropay action in the period?
   OPEN c_RetActs(
        p_AsgId       => py_za_tx_01032000.con_ASG_ID
      , p_AsgActSeq   => l_AsgActSeq
      , p_TimPrdId    => l_TimPrdId
      );
   FETCH c_RetActs INTO v_RetActs;
      hr_utility.set_location('py_za_tx_utl_01032000.RetroInPrd',3);
      IF c_RetActs%FOUND THEN
         hr_utility.set_location('py_za_tx_utl_01032000.RetroInPrd',4);
         --l_RetroInPeriod := TRUE;
         py_za_tx_01032000.trc_RetroInPeriod := TRUE;
      END IF;
   CLOSE c_RetActs;

   hr_utility.set_location('py_za_tx_utl_01032000.RetroInPrd',5);
   RETURN py_za_tx_01032000.trc_RetroInPeriod;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'RetroInPrd: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END RetroInPrd;

FUNCTION LatePayPeriod RETURN BOOLEAN AS
-- Variables
   l_CurTxYear NUMBER(15);
BEGIN
   hr_utility.set_location('py_za_tx_utl_01032000.LatePayPeriod',1);
-- IF the employee's assignment ended before the current tax year
-- it's a Late Pay Period
   IF py_za_tx_01032000.dbi_ZA_ACT_END_DTE < py_za_tx_01032000.dbi_ZA_TX_YR_STRT THEN

      hr_utility.set_location('py_za_tx_utl_01032000.LatePayPeriod',2);

   -- Valid Late Pay Period?
   --
   -- Current Tax Year
      l_CurTxYear := to_number(to_char(py_za_tx_01032000.dbi_ZA_TX_YR_END,'YYYY'));

   -- Assignment's Tax Year
      SELECT ptp.prd_information1
        INTO py_za_tx_01032000.trc_AsgTxYear
        FROM per_time_periods ptp
       WHERE ptp.payroll_id = py_za_tx_01032000.con_PRL_ID
         AND py_za_tx_01032000.dbi_ZA_ACT_END_DTE BETWEEN ptp.start_date AND ptp.end_date;

      hr_utility.set_location('py_za_tx_utl_01032000.LatePayPeriod',3);

      IF (l_CurTxYear - py_za_tx_01032000.trc_AsgTxYear) > 1 THEN
         hr_utility.set_location('py_za_tx_utl_01032000.LatePayPeriod',4);
         hr_utility.set_message(801, 'Late Payment Across Two Tax Years!');
         hr_utility.raise_error;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032000.LatePayPeriod',5);
         RETURN TRUE;
      END IF;

   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.LatePayPeriod',6);
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'LatePayPeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END LatePayPeriod;

FUNCTION LstPeriod RETURN BOOLEAN AS
BEGIN
   -- Is this the last period for the tax year
   --
   IF py_za_tx_01032000.dbi_ZA_PAY_PRDS_LFT = 1 THEN
      hr_utility.set_location('py_za_tx_utl_01032000.LstPeriod',1);
      RETURN TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.LstPeriod',2);
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'LstPeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END LstPeriod;

FUNCTION EmpTermInPeriod RETURN BOOLEAN AS

BEGIN
   -- Was the employee terminated in the current period
   --
   IF py_za_tx_01032000.dbi_ZA_ACT_END_DTE BETWEEN py_za_tx_01032000.dbi_ZA_CUR_PRD_STRT_DTE AND py_za_tx_01032000.dbi_ZA_CUR_PRD_END_DTE THEN
      hr_utility.set_location('py_za_tx_utl_01032000.EmpTermInPeriod',1);
      RETURN TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.EmpTermInPeriod',2);
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'EmpTermInPeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END EmpTermInPeriod;

FUNCTION EmpTermPrePeriod RETURN BOOLEAN AS

BEGIN
   -- Was the employee terminated before the current period
   --
   IF py_za_tx_01032000.dbi_ZA_ACT_END_DTE <= py_za_tx_01032000.dbi_ZA_CUR_PRD_STRT_DTE THEN
      hr_utility.set_location('py_za_tx_utl_01032000.EmpTermPrePeriod',1);
      RETURN TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.EmpTermPrePeriod',2);
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'EmpTermPrePeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END EmpTermPrePeriod;

FUNCTION PreErnPeriod RETURN BOOLEAN AS

BEGIN
   -- PTD Taxable Income
   --
   py_za_tx_01032000.trc_TxbIncPtd :=
      ( py_za_tx_01032000.bal_AST_PRCHD_RVAL_NRFI_PTD
      + py_za_tx_01032000.bal_AST_PRCHD_RVAL_RFI_PTD
      + py_za_tx_01032000.bal_BP_PTD
      + py_za_tx_01032000.bal_BUR_AND_SCH_NRFI_PTD
      + py_za_tx_01032000.bal_BUR_AND_SCH_RFI_PTD
      + py_za_tx_01032000.bal_COMM_NRFI_PTD
      + py_za_tx_01032000.bal_COMM_RFI_PTD
      + py_za_tx_01032000.bal_COMP_ALL_NRFI_PTD
      + py_za_tx_01032000.bal_COMP_ALL_RFI_PTD
      + py_za_tx_01032000.bal_ENT_ALL_NRFI_PTD
      + py_za_tx_01032000.bal_ENT_ALL_RFI_PTD
      + py_za_tx_01032000.bal_FREE_ACCOM_NRFI_PTD
      + py_za_tx_01032000.bal_FREE_ACCOM_RFI_PTD
      + py_za_tx_01032000.bal_FREE_SERV_NRFI_PTD
      + py_za_tx_01032000.bal_FREE_SERV_RFI_PTD
      + py_za_tx_01032000.bal_LOW_LOANS_NRFI_PTD
      + py_za_tx_01032000.bal_LOW_LOANS_RFI_PTD
      + py_za_tx_01032000.bal_MLS_AND_VOUCH_NRFI_PTD
      + py_za_tx_01032000.bal_MLS_AND_VOUCH_RFI_PTD
      + py_za_tx_01032000.bal_MED_PAID_NRFI_PTD
      + py_za_tx_01032000.bal_MED_PAID_RFI_PTD
      + py_za_tx_01032000.bal_OTHER_TXB_ALL_NRFI_PTD
      + py_za_tx_01032000.bal_OTHER_TXB_ALL_RFI_PTD
      + py_za_tx_01032000.bal_OVTM_NRFI_PTD
      + py_za_tx_01032000.bal_OVTM_RFI_PTD
      + py_za_tx_01032000.bal_PYM_DBT_NRFI_PTD
      + py_za_tx_01032000.bal_PYM_DBT_RFI_PTD
      + py_za_tx_01032000.bal_RGT_AST_NRFI_PTD
      + py_za_tx_01032000.bal_RGT_AST_RFI_PTD
      + py_za_tx_01032000.bal_TXB_INC_NRFI_PTD
      + py_za_tx_01032000.bal_TXB_INC_RFI_PTD
      + py_za_tx_01032000.bal_TXB_PEN_NRFI_PTD
      + py_za_tx_01032000.bal_TXB_PEN_RFI_PTD
      + py_za_tx_01032000.bal_TEL_ALL_NRFI_PTD
      + py_za_tx_01032000.bal_TEL_ALL_RFI_PTD
      + py_za_tx_01032000.bal_TOOL_ALL_NRFI_PTD
      + py_za_tx_01032000.bal_TOOL_ALL_RFI_PTD
      + py_za_tx_01032000.bal_TA_NRFI_PTD
      + py_za_tx_01032000.bal_TA_RFI_PTD
      + py_za_tx_01032000.bal_USE_VEH_NRFI_PTD
      + py_za_tx_01032000.bal_USE_VEH_RFI_PTD
      );

   -- Ptd Annual Bonus
   py_za_tx_01032000.trc_AnnBonPtd :=
      ( py_za_tx_01032000.bal_AB_NRFI_RUN
      + py_za_tx_01032000.bal_AB_RFI_RUN
      );

   -- Ytd Annual Payments
   py_za_tx_01032000.trc_AnnPymPtd :=
      ( py_za_tx_01032000.bal_ANU_FRM_RET_FND_NRFI_RUN
      + py_za_tx_01032000.bal_ANU_FRM_RET_FND_RFI_RUN
      + py_za_tx_01032000.bal_PRCH_ANU_TXB_NRFI_RUN
      + py_za_tx_01032000.bal_PRCH_ANU_TXB_RFI_RUN
      + py_za_tx_01032000.bal_TXB_AP_NRFI_RUN
      + py_za_tx_01032000.bal_TXB_AP_RFI_RUN
      );

   WriteHrTrace('py_za_tx_01032000.trc_TxbIncPtd: '||to_char(py_za_tx_01032000.trc_TxbIncPtd));
   WriteHrTrace('py_za_tx_01032000.trc_AnnBonPtd: '||to_char(py_za_tx_01032000.trc_AnnBonPtd));
   WriteHrTrace('py_za_tx_01032000.trc_AnnPymPtd: '||to_char(py_za_tx_01032000.trc_AnnPymPtd));

   -- Annual Type PTD Income with no Period Type PTD Income
   IF (py_za_tx_01032000.trc_AnnBonPtd + py_za_tx_01032000.trc_AnnPymPtd) <> 0 AND py_za_tx_01032000.trc_TxbIncPtd <= 0 THEN
      hr_utility.set_location('py_za_tx_utl_01032000.PreErnPeriod',1);
      RETURN TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.PreErnPeriod',2);
      RETURN FALSE;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
       py_za_tx_01032000.xpt_Msg := 'PreErnPeriod: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE py_za_tx_01032000.xpt_E;
END PreErnPeriod;

FUNCTION SitePeriod RETURN BOOLEAN AS
BEGIN
   IF LstPeriod OR EmpTermInPeriod OR EmpTermPrePeriod THEN
      hr_utility.set_location('py_za_tx_utl_01032000.SitePeriod',1);
      RETURN TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.SitePeriod',2);
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'SitePeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END SitePeriod;

PROCEDURE PeriodFactor AS

BEGIN
   IF py_za_tx_01032000.dbi_ZA_TX_YR_STRT < py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE THEN
      hr_utility.set_location('py_za_tx_utl_01032000.PeriodFactor',1);

      IF py_za_tx_01032000.bal_TOT_INC_YTD = py_za_tx_01032000.bal_TOT_INC_PTD THEN
         hr_utility.set_location('py_za_tx_utl_01032000.PeriodFactor',2);
      /* i.e. first pay period for the person */
         py_za_tx_01032000.trc_PrdFactor := (py_za_tx_01032000.dbi_ZA_CUR_PRD_END_DTE - py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE + 1) /
                          (py_za_tx_01032000.dbi_ZA_CUR_PRD_END_DTE - py_za_tx_01032000.dbi_ZA_CUR_PRD_STRT_DTE + 1);
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032000.PeriodFactor',3);
         py_za_tx_01032000.trc_PrdFactor := 1;
      END IF;

   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.PeriodFactor',4);
      py_za_tx_01032000.trc_PrdFactor := 1;
   END IF;

   WriteHrTrace('py_za_tx_01032000.dbi_ZA_TX_YR_STRT: '||to_char(py_za_tx_01032000.dbi_ZA_TX_YR_STRT,'DD/MM/YYYY'));
   WriteHrTrace('py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE: '||to_char(py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE,'DD/MM/YYYY'));
   WriteHrTrace('py_za_tx_01032000.dbi_ZA_CUR_PRD_END_DTE: '||to_char(py_za_tx_01032000.dbi_ZA_CUR_PRD_END_DTE,'DD/MM/YYYY'));
   WriteHrTrace('py_za_tx_01032000.dbi_ZA_CUR_PRD_STRT_DTE: '||to_char(py_za_tx_01032000.dbi_ZA_CUR_PRD_STRT_DTE,'DD/MM/YYYY'));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'PeriodFactor: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END PeriodFactor;


PROCEDURE PossiblePeriodsFactor AS
BEGIN
   IF py_za_tx_01032000.dbi_ZA_TX_YR_STRT >= py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE THEN
      hr_utility.set_location('py_za_tx_utl_01032000.PossiblePeriodsFactor',1);
      py_za_tx_01032000.trc_PosFactor := 1;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.PossiblePeriodsFactor',2);
      py_za_tx_01032000.trc_PosFactor := py_za_tx_01032000.dbi_ZA_DYS_IN_YR / (py_za_tx_01032000.dbi_ZA_TX_YR_END - py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE + 1);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'PossiblePeriodsFactor: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END PossiblePeriodsFactor;


FUNCTION Annualise
   (p_YtdInc IN NUMBER
   ,p_PtdInc IN NUMBER
   ) RETURN NUMBER
AS
   l_AnnFig  NUMBER(15,2);
   l_PtdFact  NUMBER(15,2);

BEGIN
   l_PtdFact := p_PtdInc / py_za_tx_01032000.trc_PrdFactor;

  -- Payment over less than one period?
   IF py_za_tx_01032000.trc_PrdFactor < 1 THEN
      hr_utility.set_location('py_za_tx_utl_01032000.Annualise',1);
      l_AnnFig := ((l_PtdFact * py_za_tx_01032000.dbi_ZA_PAY_PRDS_LFT)
                    +(p_YtdInc - p_PtdInc)
                    ) * py_za_tx_01032000.trc_PosFactor;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.Annualise',2);
      l_AnnFig := ((l_PtdFact * py_za_tx_01032000.dbi_ZA_PAY_PRDS_LFT)
                    +(p_YtdInc - l_PtdFact)
                    ) * py_za_tx_01032000.trc_PosFactor;
   END IF;

   WriteHrTrace('p_YtdInc: '||to_char(p_YtdInc));
   WriteHrTrace('p_PtdInc: '||to_char(p_PtdInc));
   WriteHrTrace('l_PtdFact: '||to_char(l_PtdFact));
   WriteHrTrace('py_za_tx_01032000.trc_PrdFactor: '||to_char(py_za_tx_01032000.trc_PrdFactor));
   WriteHrTrace('py_za_tx_01032000.trc_PosFactor: '||to_char(py_za_tx_01032000.trc_PosFactor));
   WriteHrTrace('py_za_tx_01032000.dbi_ZA_PAY_PRDS_LFT: '||to_char(py_za_tx_01032000.dbi_ZA_PAY_PRDS_LFT));

   RETURN l_AnnFig;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'Annualise: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END Annualise;

PROCEDURE SetRebates AS

-- Variables
   l_65Year DATE;
   l_EndDate per_time_periods.end_date%TYPE;

   l_ZA_TX_YR_END        DATE;
   l_ZA_ADL_TX_RBT       NUMBER(15,2);
   l_ZA_PRI_TX_RBT       NUMBER(15,2);
   l_ZA_PRI_TX_THRSHLD   NUMBER(15,2);
   l_ZA_SC_TX_THRSHLD    NUMBER(15,2);

BEGIN
   -- Setup the Globals
   IF py_za_tx_01032000.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.SetRebates',1);
   -- Employee Tax Year Start and End Dates
   --
      SELECT MAX(ptp.end_date) "EndDate"
        INTO l_EndDate
        FROM per_time_periods ptp
       WHERE ptp.payroll_id = py_za_tx_01032000.con_PRL_ID
         AND ptp.prd_information1 = py_za_tx_01032000.trc_AsgTxYear
       GROUP BY ptp.prd_information1;

      hr_utility.set_location('py_za_tx_utl_01032000.SetRebates',2);

   -- Global Values
      l_ZA_TX_YR_END        := l_EndDate;
      l_ZA_ADL_TX_RBT       := GlbVal('ZA_ADDITIONAL_TAX_REBATE',l_EndDate);
      l_ZA_PRI_TX_RBT       := GlbVal('ZA_PRIMARY_TAX_REBATE',l_EndDate);
      l_ZA_PRI_TX_THRSHLD   := GlbVal('ZA_PRIM_TAX_THRESHOLD',l_EndDate);
      l_ZA_SC_TX_THRSHLD    := GlbVal('ZA_SEC_TAX_THRESHOLD',l_EndDate);
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.SetRebates',3);
   -- Set locals to current values
      l_ZA_TX_YR_END         := py_za_tx_01032000.dbi_ZA_TX_YR_END;
      l_ZA_ADL_TX_RBT        := py_za_tx_01032000.glb_ZA_ADL_TX_RBT;
      l_ZA_PRI_TX_RBT        := py_za_tx_01032000.glb_ZA_PRI_TX_RBT;
      l_ZA_PRI_TX_THRSHLD    := py_za_tx_01032000.glb_ZA_PRI_TX_THRSHLD;
      l_ZA_SC_TX_THRSHLD     := py_za_tx_01032000.glb_ZA_SC_TX_THRSHLD;
   END IF;

   hr_utility.set_location('py_za_tx_utl_01032000.SetRebates',4);

-- Calculate the Rebate and Threshold Values
   IF py_za_tx_01032000.dbi_TX_STA = 'K' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.SetRebates',5);
   -- Personal Service Trusts receives no Abatements
      py_za_tx_01032000.trc_Rebate    := 0;
      py_za_tx_01032000.trc_Threshold := 0;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.SetRebates',6);
      -- Calculate the assignments 65 Year Date
      l_65Year := add_months(py_za_tx_01032000.dbi_PER_DTE_OF_BRTH,780);

      IF l_65Year <= l_ZA_TX_YR_END THEN
         hr_utility.set_location('py_za_tx_utl_01032000.SetRebates',7);
      -- give the extra abatement
         py_za_tx_01032000.trc_Rebate := l_ZA_PRI_TX_RBT + l_ZA_ADL_TX_RBT;
         py_za_tx_01032000.trc_Threshold := l_ZA_SC_TX_THRSHLD;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032000.SetRebates',8);
      -- not eligable for extra abatement
         py_za_tx_01032000.trc_Rebate := l_ZA_PRI_TX_RBT;
         py_za_tx_01032000.trc_Threshold := l_ZA_PRI_TX_THRSHLD;
      END IF;
   END IF;

   WriteHrTrace('l_ZA_TX_YR_END: '||to_char(l_ZA_TX_YR_END,'DD/MM/YYYY'));
   WriteHrTrace('l_ZA_ADL_TX_RBT: '||to_char(l_ZA_ADL_TX_RBT));
   WriteHrTrace('l_ZA_PRI_TX_RBT: '||to_char(l_ZA_PRI_TX_RBT));
   WriteHrTrace('l_ZA_PRI_TX_THRSHLD: '||to_char(l_ZA_PRI_TX_THRSHLD));
   WriteHrTrace('l_ZA_SC_TX_THRSHLD: '||to_char(l_ZA_SC_TX_THRSHLD));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'SetRebates: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END SetRebates;

PROCEDURE Abatements AS

-- Variables
   l_65Year DATE;
   l_EndDate per_time_periods.end_date%TYPE;

   l_ZA_TX_YR_END        DATE;
   l_ZA_ARR_PF_AN_MX_ABT NUMBER(15,2);
   l_ZA_ARR_RA_AN_MX_ABT NUMBER(15,2);
   l_ZA_PF_AN_MX_ABT     NUMBER(15,2);
   l_ZA_PF_MX_PRC        NUMBER(15,2);
   l_ZA_RA_AN_MX_ABT     NUMBER(15,2);
   l_ZA_RA_MX_PRC        NUMBER(15,2);

BEGIN
-- Initialise the figures needed for the calculation
-- of tax abatements and rebates, based on the
-- calculation type
--
   IF py_za_tx_01032000.dbi_TX_STA = 'K' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.Abatements',1);
      -- Personal Service Trusts receives no Abatements
      py_za_tx_01032000.trc_PerTotAbm := 0;
      py_za_tx_01032000.trc_AnnTotAbm := 0;
   ELSE
      IF py_za_tx_01032000.trc_CalTyp = 'NorCalc' THEN
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',2);

      -- Pension Fund Abatement
      --
         -- Period Calculation
         --
         -- Annualise Period Pension Fund Contributions
         py_za_tx_01032000.trc_PerPenFnd := Annualise
                    (p_YtdInc => py_za_tx_01032000.bal_CUR_PF_YTD
                    ,p_PtdInc => py_za_tx_01032000.bal_CUR_PF_PTD
                    );
         -- Annualise Period RFIable Contributions
         py_za_tx_01032000.trc_PerRfiCon := Annualise
                    (p_ytdInc => py_za_tx_01032000.bal_TOT_RFI_INC_YTD
                    ,p_PtdInc => py_za_tx_01032000.bal_TOT_RFI_INC_PTD
                    );

         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',3);

         -- Annual Calculation
         --
         -- Annual Pension Fund Contribution
         py_za_tx_01032000.trc_AnnPenFnd := py_za_tx_01032000.trc_PerPenFnd + py_za_tx_01032000.bal_ANN_PF_YTD;
         -- Annual Rfi Contribution
         py_za_tx_01032000.trc_AnnRfiCon := py_za_tx_01032000.trc_PerRfiCon + py_za_tx_01032000.bal_TOT_RFI_AN_INC_YTD;

      -- Arrear Pension Fund Abatement
      --
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',4);
         -- Check Arrear Pension Fund Frequency
         IF py_za_tx_01032000.dbi_ARR_PF_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',5);

            py_za_tx_01032000.trc_ArrPenFnd := Annualise
                      (p_YtdInc => py_za_tx_01032000.bal_ARR_PF_YTD
                      ,p_PtdInc => py_za_tx_01032000.bal_ARR_PF_PTD
                      )
                      +py_za_tx_01032000.bal_EXC_ARR_PEN_ITD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',6);

            py_za_tx_01032000.trc_ArrPenFnd := py_za_tx_01032000.bal_ARR_PF_YTD
                      + py_za_tx_01032000.bal_EXC_ARR_PEN_ITD;
         END IF;

      -- Retirement Annuity Abatement
      --
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',7);
         -- Calculate RA Contribution
         IF py_za_tx_01032000.dbi_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',8);
            py_za_tx_01032000.trc_RetAnu := Annualise
                   (p_YtdInc => py_za_tx_01032000.bal_CUR_RA_YTD
                   ,p_PtdINc => py_za_tx_01032000.bal_CUR_RA_PTD
                   );
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',9);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_YTD;
         END IF;

         -- Calculate Nrfi Contribution based on Pension Fund
         -- Contributions
         IF py_za_tx_01032000.bal_CUR_PF_YTD = 0 THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',10);
            py_za_tx_01032000.trc_NrfiCon := Annualise
                    (p_YtdInc => py_za_tx_01032000.bal_TOT_RFI_INC_YTD + py_za_tx_01032000.bal_TOT_NRFI_INC_YTD
                    ,p_PtdInc => py_za_tx_01032000.bal_TOT_RFI_INC_PTD + py_za_tx_01032000.bal_TOT_NRFI_INC_PTD
                    )
                    +py_za_tx_01032000.bal_TOT_NRFI_AN_INC_YTD
                    +py_za_tx_01032000.bal_TOT_RFI_AN_INC_YTD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',11);
            py_za_tx_01032000.trc_NrfiCon := Annualise
                    (p_YtdInc => py_za_tx_01032000.bal_TOT_NRFI_INC_YTD
                    ,p_PtdInc => py_za_tx_01032000.bal_TOT_NRFI_INC_PTD
                    )
                    +py_za_tx_01032000.bal_TOT_NRFI_AN_INC_YTD;
         END IF;


      -- Arrear Retirement Annuity Abatement
      --
         -- Check Arrear Retirement Annuity Frequency
         IF py_za_tx_01032000.dbi_ARR_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',12);
            py_za_tx_01032000.trc_ArrRetAnu := Annualise
                      (p_YtdInc => py_za_tx_01032000.bal_ARR_RA_YTD
                      ,p_PtdInc => py_za_tx_01032000.bal_ARR_RA_PTD
                      )
                      +py_za_tx_01032000.bal_EXC_ARR_RA_ITD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',13);
            py_za_tx_01032000.trc_ArrRetAnu := py_za_tx_01032000.bal_ARR_RA_YTD
                      + py_za_tx_01032000.bal_EXC_ARR_RA_ITD;
         END IF;


      -- Medical Aid Abatement
      --
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',14);
         py_za_tx_01032000.trc_MedAidAbm := Annualise
                    (p_YtdInc => py_za_tx_01032000.bal_MED_CONTR_YTD
                    ,p_PtdInc => py_za_tx_01032000.bal_MED_CONTR_PTD
                    );

      ELSIF py_za_tx_01032000.trc_CalTyp IN ('YtdCalc','SitCalc') THEN
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',15);
      -- Pension Fund Abatement
      --
         -- Period Calculation
         --
         -- Annualise Period Pension Fund Contribution
         py_za_tx_01032000.trc_PerPenFnd := py_za_tx_01032000.bal_CUR_PF_YTD * py_za_tx_01032000.trc_SitFactor;
         -- Annualise Period Rfiable Contributions
         py_za_tx_01032000.trc_PerRfiCon := py_za_tx_01032000.bal_TOT_RFI_INC_YTD * py_za_tx_01032000.trc_SitFactor;

         -- Annual Calculation
         --
         -- Annual Pension Fund Contribution
         py_za_tx_01032000.trc_AnnPenFnd := py_za_tx_01032000.trc_PerPenFnd + py_za_tx_01032000.bal_ANN_PF_YTD;
         -- Annual Rfi Contribution
         py_za_tx_01032000.trc_AnnRfiCon := py_za_tx_01032000.trc_PerRfiCon + py_za_tx_01032000.bal_TOT_RFI_AN_INC_YTD;

         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',16);

      -- Arrear Pension Fund Abatement
      --
         -- Check Arrear Pension Fund Frequency
         IF py_za_tx_01032000.dbi_ARR_PF_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',17);
            py_za_tx_01032000.trc_ArrPenFnd := ( py_za_tx_01032000.bal_ARR_PF_YTD * py_za_tx_01032000.trc_SitFactor)
                             + py_za_tx_01032000.bal_EXC_ARR_PEN_ITD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',18);
            py_za_tx_01032000.trc_ArrPenFnd := py_za_tx_01032000.bal_ARR_PF_YTD + py_za_tx_01032000.bal_EXC_ARR_PEN_ITD;
         END IF;

      -- Retirement Annuity Abatement
      --
         -- Calculate RA Contribution
         IF py_za_tx_01032000.dbi_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',19);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_YTD * py_za_tx_01032000.trc_SitFactor;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',20);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_YTD;
         END IF;

         -- Calculate Nrfi Contribution based on Pension Fund
         -- Contributions
         IF py_za_tx_01032000.bal_CUR_PF_YTD = 0 THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',21);
            py_za_tx_01032000.trc_NrfiCon :=
            (( py_za_tx_01032000.bal_TOT_RFI_INC_YTD
             + py_za_tx_01032000.bal_TOT_NRFI_INC_YTD
             )* py_za_tx_01032000.trc_SitFactor)
            + py_za_tx_01032000.bal_TOT_NRFI_AN_INC_YTD
            + py_za_tx_01032000.bal_TOT_RFI_AN_INC_YTD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',22);
            py_za_tx_01032000.trc_NrfiCon := ( py_za_tx_01032000.bal_TOT_NRFI_INC_YTD * py_za_tx_01032000.trc_SitFactor)
                           + py_za_tx_01032000.bal_TOT_NRFI_AN_INC_YTD;
         END IF;


      -- Arrear Retirement Annuity Abatement
      --
         -- Check Arrear Retirement Annuity Frequency
         IF py_za_tx_01032000.dbi_ARR_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',23);
            py_za_tx_01032000.trc_ArrRetAnu := (py_za_tx_01032000.bal_ARR_RA_YTD * py_za_tx_01032000.trc_SitFactor)
                             +py_za_tx_01032000.bal_EXC_ARR_RA_ITD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',24);
            py_za_tx_01032000.trc_ArrRetAnu := py_za_tx_01032000.bal_ARR_RA_YTD
                         + py_za_tx_01032000.bal_EXC_ARR_RA_ITD;
         END IF;

      -- Medical Aid Abatement
         py_za_tx_01032000.trc_MedAidAbm := py_za_tx_01032000.bal_MED_CONTR_YTD * py_za_tx_01032000.trc_SitFactor;

      hr_utility.set_location('py_za_tx_utl_01032000.Abatements',25);

      ELSIF py_za_tx_01032000.trc_CalTyp = 'CalCalc' THEN
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',26);
      -- Pension Fund Abatement
      --
         -- Period Calculation
         --
         -- Annualise Period Pension Fund Contribution
         py_za_tx_01032000.trc_PerPenFnd := py_za_tx_01032000.bal_CUR_PF_CYTD * py_za_tx_01032000.trc_SitFactor;
         -- Annualise Period Rfiable Contributions
         py_za_tx_01032000.trc_PerRfiCon := py_za_tx_01032000.bal_TOT_RFI_INC_CYTD * py_za_tx_01032000.trc_SitFactor;

         -- Annual Calculation
         --
         -- Annual Pension Fund Contribution
         py_za_tx_01032000.trc_AnnPenFnd := py_za_tx_01032000.trc_PerPenFnd + py_za_tx_01032000.bal_ANN_PF_YTD;
         -- Annual Rfi Contribution
         py_za_tx_01032000.trc_AnnRfiCon := py_za_tx_01032000.trc_PerRfiCon + py_za_tx_01032000.bal_TOT_RFI_AN_INC_YTD;

      -- Arrear Pension Fund Abatement
      --
         -- Check Arrear Pension Fund Frequency
         IF py_za_tx_01032000.dbi_ARR_PF_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',27);
            py_za_tx_01032000.trc_ArrPenFnd := (py_za_tx_01032000.bal_ARR_PF_CYTD * py_za_tx_01032000.trc_SitFactor)
                             +py_za_tx_01032000.bal_EXC_ARR_PEN_ITD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',28);
            py_za_tx_01032000.trc_ArrPenFnd := py_za_tx_01032000.bal_ARR_PF_CYTD
                           + py_za_tx_01032000.bal_EXC_ARR_PEN_ITD;
         END IF;

      -- Retirement Annuity Abatement
      --
         -- Calculate RA Contribution
         IF py_za_tx_01032000.dbi_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',29);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_CYTD * py_za_tx_01032000.trc_SitFactor;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',30);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_CYTD;
         END IF;

         -- Calculate Nrfi Contribution based on Pension Fund
         -- Contributions
         IF py_za_tx_01032000.bal_CUR_PF_CYTD = 0 THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',31);
            py_za_tx_01032000.trc_NrfiCon :=
               (( py_za_tx_01032000.bal_TOT_RFI_INC_CYTD
                + py_za_tx_01032000.bal_TOT_NRFI_INC_CYTD
                )* py_za_tx_01032000.trc_SitFactor)
               + py_za_tx_01032000.bal_TOT_NRFI_AN_INC_CYTD
               + py_za_tx_01032000.bal_TOT_RFI_AN_INC_CYTD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',32);
            py_za_tx_01032000.trc_NrfiCon := (py_za_tx_01032000.bal_TOT_NRFI_INC_CYTD * py_za_tx_01032000.trc_SitFactor)
                           +py_za_tx_01032000.bal_TOT_NRFI_AN_INC_CYTD;
         END IF;

      -- Arrear Retirement Annuity Abatement
      --
         -- Check Arrear Retirement Annuity Frequency
         IF py_za_tx_01032000.dbi_ARR_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',33);
            py_za_tx_01032000.trc_ArrRetAnu := (py_za_tx_01032000.bal_ARR_RA_CYTD * py_za_tx_01032000.trc_SitFactor)
                             +py_za_tx_01032000.bal_EXC_ARR_RA_ITD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',34);
            py_za_tx_01032000.trc_ArrRetAnu := py_za_tx_01032000.bal_ARR_RA_CYTD
                           + py_za_tx_01032000.bal_EXC_ARR_RA_ITD;
         END IF;

      -- Medical Aid Abatement
      --
         py_za_tx_01032000.trc_MedAidAbm := py_za_tx_01032000.bal_MED_CONTR_CYTD * py_za_tx_01032000.trc_SitFactor;

      ELSIF py_za_tx_01032000.trc_CalTyp = 'SeaCalc' THEN
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',35);
      -- Pension Fund Abatement
      --
         -- Period Calculation
         --
         -- Annualise Period Pension Fund Contribution
         py_za_tx_01032000.trc_PerPenFnd := py_za_tx_01032000.bal_CUR_PF_RUN * py_za_tx_01032000.trc_SitFactor;
         -- Annualise Period Rfiable Contributions
         py_za_tx_01032000.trc_PerRfiCon := py_za_tx_01032000.bal_TOT_RFI_INC_RUN * py_za_tx_01032000.trc_SitFactor;

         -- Annual Calculation
         --
         -- Annual Pension Fund Contribution
         py_za_tx_01032000.trc_AnnPenFnd := py_za_tx_01032000.trc_PerPenFnd + py_za_tx_01032000.bal_ANN_PF_RUN;
         -- Annual Rfi Contribution
         py_za_tx_01032000.trc_AnnRfiCon := py_za_tx_01032000.trc_PerRfiCon + py_za_tx_01032000.bal_TOT_RFI_AN_INC_RUN;

      -- Arrear pension Fund Abatement
      --
         py_za_tx_01032000.trc_ArrPenFndAbm := 0;

      -- Retirement Annuity Abatement
      --
         -- Calculate RA Contribution
         IF py_za_tx_01032000.dbi_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',36);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_RUN * py_za_tx_01032000.trc_SitFactor;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',37);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_RUN;
         END IF;

         -- Calculate Nrfi Contribution based on Pension Fund
         -- Contributions
         IF py_za_tx_01032000.bal_CUR_PF_RUN = 0 THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',38);
            py_za_tx_01032000.trc_NrfiCon :=
               (( py_za_tx_01032000.bal_TOT_RFI_INC_RUN
                + py_za_tx_01032000.bal_TOT_NRFI_INC_RUN
                )* py_za_tx_01032000.trc_SitFactor)
               + py_za_tx_01032000.bal_TOT_NRFI_AN_INC_RUN
               + py_za_tx_01032000.bal_TOT_RFI_AN_INC_RUN;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',39);
            py_za_tx_01032000.trc_NrfiCon := (py_za_tx_01032000.bal_TOT_NRFI_INC_RUN * py_za_tx_01032000.trc_SitFactor)
                           + py_za_tx_01032000.bal_TOT_NRFI_AN_INC_RUN;
         END IF;

      -- Arrear Retirement Annuity
      --
         py_za_tx_01032000.trc_ArrRetAnuAbm := 0;

      -- Medical Aid Abatement
      --
         py_za_tx_01032000.trc_MedAidAbm := py_za_tx_01032000.bal_MED_CONTR_RUN * py_za_tx_01032000.trc_SitFactor;

      ELSIF py_za_tx_01032000.trc_CalTyp = 'LteCalc' THEN
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',40);
      -- Pension Fund Abatement
      --

         -- Period Calculation
         --
         -- Annualise Period Pension Fund Contribution
         py_za_tx_01032000.trc_PerPenFnd := py_za_tx_01032000.bal_CUR_PF_YTD;
         -- Annualise Period Rfiable Contributions
         py_za_tx_01032000.trc_PerRfiCon := py_za_tx_01032000.bal_TOT_RFI_INC_YTD;

         -- Annual Calculation
         --
         -- Annual Pension Fund Contribution
         py_za_tx_01032000.trc_AnnPenFnd := py_za_tx_01032000.trc_PerPenFnd + py_za_tx_01032000.bal_ANN_PF_YTD;
         -- Annual Rfi Contribution
         py_za_tx_01032000.trc_AnnRfiCon := py_za_tx_01032000.trc_PerRfiCon + py_za_tx_01032000.bal_TOT_RFI_AN_INC_YTD;

      -- Arrear Pension Fund Abatement
      --
         -- Check Arrear Pension Fund Frequency
         IF py_za_tx_01032000.dbi_ARR_PF_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',41);
            py_za_tx_01032000.trc_ArrPenFnd := py_za_tx_01032000.bal_ARR_PF_YTD + py_za_tx_01032000.bal_EXC_ARR_PEN_ITD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',42);
            py_za_tx_01032000.trc_ArrPenFnd := py_za_tx_01032000.bal_ARR_PF_YTD + py_za_tx_01032000.bal_EXC_ARR_PEN_ITD;
         END IF;

      -- Retirement Annuity Abatement
      --
         -- Calculate RA Contribution
         IF py_za_tx_01032000.dbi_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',43);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_YTD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',44);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_YTD;
         END IF;

         -- Calculate Nrfi Contribution based on Pension Fund
         -- Contributions
         IF py_za_tx_01032000.bal_CUR_PF_YTD = 0 THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',45);
            py_za_tx_01032000.trc_NrfiCon :=
               (py_za_tx_01032000.bal_TOT_RFI_INC_YTD
               +py_za_tx_01032000.bal_TOT_NRFI_INC_YTD
               +py_za_tx_01032000.bal_TOT_NRFI_AN_INC_YTD
               +py_za_tx_01032000.bal_TOT_RFI_AN_INC_YTD
               );
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',46);
            py_za_tx_01032000.trc_NrfiCon := py_za_tx_01032000.bal_TOT_NRFI_INC_YTD +py_za_tx_01032000.bal_TOT_NRFI_AN_INC_YTD;
         END IF;

      -- Arrear Retirement Annuity Abatement
      --
         -- Check Arrear Retirement Annuity Frequency
         IF py_za_tx_01032000.dbi_ARR_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',47);
            py_za_tx_01032000.trc_ArrRetAnu := py_za_tx_01032000.bal_ARR_RA_YTD +py_za_tx_01032000.bal_EXC_ARR_RA_ITD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',48);
            py_za_tx_01032000.trc_ArrRetAnu := py_za_tx_01032000.bal_ARR_RA_YTD + py_za_tx_01032000.bal_EXC_ARR_RA_ITD;
         END IF;

      -- Medical Aid Abatement
         py_za_tx_01032000.trc_MedAidAbm := py_za_tx_01032000.bal_MED_CONTR_YTD;


      ELSIF py_za_tx_01032000.trc_CalTyp = 'PstCalc' THEN
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',49);
      -- Pension Fund Abatement
      --
         -- Period Calculation
         --
         -- Annualise Period Pension Fund Contribution
         py_za_tx_01032000.trc_PerPenFnd := py_za_tx_01032000.bal_CUR_PF_PTD * py_za_tx_01032000.trc_SitFactor;
         -- Annualise Period Rfiable Contributions
         py_za_tx_01032000.trc_PerRfiCon := py_za_tx_01032000.bal_TOT_RFI_INC_PTD * py_za_tx_01032000.trc_SitFactor;

         -- Annual Calculation
         --
         -- Annual Pension Fund Contribution
         py_za_tx_01032000.trc_AnnPenFnd := py_za_tx_01032000.trc_PerPenFnd + py_za_tx_01032000.bal_ANN_PF_PTD;
         -- Annual Rfi Contribution
         py_za_tx_01032000.trc_AnnRfiCon := py_za_tx_01032000.trc_PerRfiCon + py_za_tx_01032000.bal_TOT_RFI_AN_INC_PTD;

      -- Arrear Pension Fund Abatement
      --
         -- Check Arrear Pension Fund Frequency
         IF py_za_tx_01032000.dbi_ARR_PF_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',50);
            py_za_tx_01032000.trc_ArrPenFnd := (py_za_tx_01032000.bal_ARR_PF_PTD * py_za_tx_01032000.trc_SitFactor) + py_za_tx_01032000.bal_EXC_ARR_PEN_PTD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',51);
            py_za_tx_01032000.trc_ArrPenFnd := py_za_tx_01032000.bal_ARR_PF_PTD + py_za_tx_01032000.bal_EXC_ARR_PEN_PTD;
         END IF;

      -- Retirement Annuity Abatement
      --
         -- Calculate RA Contribution
         IF py_za_tx_01032000.dbi_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',52);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_PTD * py_za_tx_01032000.trc_SitFactor;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',53);
            py_za_tx_01032000.trc_RetAnu := py_za_tx_01032000.bal_CUR_RA_PTD;
         END IF;

         -- Calculate Nrfi Contribution based on Pension Fund
         -- Contributions
         IF py_za_tx_01032000.bal_CUR_PF_PTD = 0 THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',54);
            py_za_tx_01032000.trc_NrfiCon :=
             (((py_za_tx_01032000.bal_TOT_RFI_INC_PTD+py_za_tx_01032000.bal_TOT_NRFI_INC_PTD) * py_za_tx_01032000.trc_SitFactor)
             +py_za_tx_01032000.bal_TOT_NRFI_AN_INC_PTD
             +py_za_tx_01032000.bal_TOT_RFI_AN_INC_PTD
             );
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',55);
            py_za_tx_01032000.trc_NrfiCon := py_za_tx_01032000.bal_TOT_NRFI_INC_PTD +py_za_tx_01032000.bal_TOT_NRFI_AN_INC_PTD;
         END IF;


      -- Arrear Retirement Annuity Abatement
      --
         -- Check Arrear Retirement Annuity Frequency
         IF py_za_tx_01032000.dbi_ARR_RA_FRQ = 'M' THEN
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',56);
            py_za_tx_01032000.trc_ArrRetAnu := (py_za_tx_01032000.bal_ARR_RA_PTD * py_za_tx_01032000.trc_SitFactor) +py_za_tx_01032000.bal_EXC_ARR_RA_PTD;
         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.Abatements',57);
            py_za_tx_01032000.trc_ArrRetAnu := py_za_tx_01032000.bal_ARR_RA_PTD + py_za_tx_01032000.bal_EXC_ARR_RA_PTD;
         END IF;

      -- Medical Aid Abatement
         py_za_tx_01032000.trc_MedAidAbm := py_za_tx_01032000.bal_MED_CONTR_PTD * py_za_tx_01032000.trc_SitFactor;

      END IF;


   -- CALCULATE THE ABATEMENTS
   --
      hr_utility.set_location('py_za_tx_utl_01032000.Abatements',58);
      -- Check the Calculation Type
      IF py_za_tx_01032000.trc_CalTyp = 'PstCalc' THEN
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',59);
      -- Employee Tax Year Start and End Dates
      --
         SELECT MAX(ptp.end_date) "EndDate"
           INTO l_EndDate
           FROM per_time_periods ptp
          WHERE ptp.payroll_id = py_za_tx_01032000.con_PRL_ID
            AND ptp.prd_information1 = py_za_tx_01032000.trc_AsgTxYear
          GROUP BY ptp.prd_information1;

         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',60);

      -- Global Values
         l_ZA_TX_YR_END        := l_EndDate;
         l_ZA_ARR_PF_AN_MX_ABT := GlbVal('ZA_ARREAR_PEN_AN_MAX_ABATE',l_EndDate);
         l_ZA_ARR_RA_AN_MX_ABT := GlbVal('ZA_ARREAR_RA_AN_MAX_ABATE',l_EndDate);
         l_ZA_PF_AN_MX_ABT     := GlbVal('ZA_PEN_AN_MAX_ABATE',l_EndDate);
         l_ZA_PF_MX_PRC        := GlbVal('ZA_PEN_MAX_PERC',l_EndDate);
         l_ZA_RA_AN_MX_ABT     := GlbVal('ZA_RA_AN_MAX_ABATE',l_EndDate);
         l_ZA_RA_MX_PRC        := GlbVal('ZA_RA_MAX_PERC',l_EndDate);

      ELSE
         hr_utility.set_location('py_za_tx_utl_01032000.Abatements',61);
      -- Set locals to current values
         l_ZA_TX_YR_END         := py_za_tx_01032000.dbi_ZA_TX_YR_END;
         l_ZA_ARR_PF_AN_MX_ABT  := py_za_tx_01032000.glb_ZA_ARR_PF_AN_MX_ABT;
         l_ZA_ARR_RA_AN_MX_ABT  := py_za_tx_01032000.glb_ZA_ARR_RA_AN_MX_ABT;
         l_ZA_PF_AN_MX_ABT      := py_za_tx_01032000.glb_ZA_PF_AN_MX_ABT;
         l_ZA_PF_MX_PRC         := py_za_tx_01032000.glb_ZA_PF_MX_PRC;
         l_ZA_RA_AN_MX_ABT      := py_za_tx_01032000.glb_ZA_RA_AN_MX_ABT;
         l_ZA_RA_MX_PRC         := py_za_tx_01032000.glb_ZA_RA_MX_PRC;

      END IF;

      WriteHrTrace('l_ZA_TX_YR_END: '||to_char(l_ZA_TX_YR_END,'DD/MM/YYYY'));
      WriteHrTrace('l_ZA_ARR_PF_AN_MX_ABT: '||to_char(l_ZA_ARR_PF_AN_MX_ABT));
      WriteHrTrace('l_ZA_ARR_RA_AN_MX_ABT: '||to_char(l_ZA_ARR_RA_AN_MX_ABT));
      WriteHrTrace('l_ZA_PF_AN_MX_ABT: '||to_char(l_ZA_PF_AN_MX_ABT));
      WriteHrTrace('l_ZA_PF_MX_PRC: '||to_char(l_ZA_PF_MX_PRC));
      WriteHrTrace('l_ZA_RA_AN_MX_ABT: '||to_char(l_ZA_RA_AN_MX_ABT));
      WriteHrTrace('l_ZA_RA_MX_PRC: '||to_char(l_ZA_RA_MX_PRC));

   -- Pension Fund Abatement
   --
      -- Period Calculation
      -- Calculate the Pension Fund Maximum
      py_za_tx_01032000.trc_PerPenFndMax := GREATEST( l_ZA_PF_AN_MX_ABT
                                 ,(l_ZA_PF_MX_PRC / 100 * py_za_tx_01032000.trc_PerRfiCon)
                                  );
      -- Calculate Period Pension Fund Abatement
      py_za_tx_01032000.trc_PerPenFndAbm := LEAST(py_za_tx_01032000.trc_PerPenFnd, py_za_tx_01032000.trc_PerPenFndMax);

      -- Annual Calculation
      -- Calculate the Pension Fund Maximum
      py_za_tx_01032000.trc_AnnPenFndMax := GREATEST(l_ZA_PF_AN_MX_ABT
                                  ,l_ZA_PF_MX_PRC / 100 * py_za_tx_01032000.trc_AnnRfiCon
                                  );

      -- Calculate Annual Pension Fund Abatement
      py_za_tx_01032000.trc_AnnPenFndAbm := LEAST(py_za_tx_01032000.trc_AnnPenFnd,py_za_tx_01032000.trc_AnnPenFndMax);

   -- Arrear Pension Fund Abatement
   --
      py_za_tx_01032000.trc_ArrPenFndAbm := LEAST(py_za_tx_01032000.trc_ArrPenFnd, l_ZA_ARR_PF_AN_MX_ABT);

   -- Retirement Annnnuity Abatement
   --
      -- Calculate the Retirement Annuity Maximum
      py_za_tx_01032000.trc_RetAnuMax := GREATEST(l_ZA_PF_AN_MX_ABT
                               ,l_ZA_RA_AN_MX_ABT - py_za_tx_01032000.trc_AnnPenFndAbm
                               ,l_ZA_RA_MX_PRC / 100 * py_za_tx_01032000.trc_NrfiCon
                               );

      -- Calculate Retirement Annuity Abatement
      py_za_tx_01032000.trc_RetAnuAbm := LEAST(py_za_tx_01032000.trc_RetAnu, py_za_tx_01032000.trc_RetAnuMax);

   -- Arrear Retirement Annuity Abatement
   --
      py_za_tx_01032000.trc_ArrRetAnuAbm := LEAST(py_za_tx_01032000.trc_ArrRetAnu, l_ZA_ARR_RA_AN_MX_ABT);

   -- Tax Rebates, Threshold Figure and Medical Aid
   -- Abatements
      -- Calculate the assignments 65 Year Date
      l_65Year := add_months(py_za_tx_01032000.dbi_PER_DTE_OF_BRTH,780);

      IF l_65Year > l_ZA_TX_YR_END THEN
         py_za_tx_01032000.trc_MedAidAbm := 0;
      END IF;

      hr_utility.set_location('py_za_tx_utl_01032000.Abatements',62);

   -- Total Abatements
   --
      -- Period Total Abatement
      py_za_tx_01032000.trc_PerTotAbm :=
                       ( py_za_tx_01032000.trc_PerPenFndAbm
                       + py_za_tx_01032000.trc_ArrPenFndAbm
                       + py_za_tx_01032000.trc_RetAnuAbm
                       + py_za_tx_01032000.trc_ArrRetAnuAbm
                       + py_za_tx_01032000.trc_MedAidAbm
                       );

      -- Annual Total Abatements
      py_za_tx_01032000.trc_AnnTotAbm :=
                       ( py_za_tx_01032000.trc_AnnPenFndAbm
                       + py_za_tx_01032000.trc_ArrPenFndAbm
                       + py_za_tx_01032000.trc_RetAnuAbm
                       + py_za_tx_01032000.trc_ArrRetAnuAbm
                       + py_za_tx_01032000.trc_MedAidAbm
                       );

      WriteHrTrace('py_za_tx_01032000.trc_PerPenFndAbm: '||to_char(py_za_tx_01032000.trc_PerPenFndAbm));
      WriteHrTrace('py_za_tx_01032000.trc_AnnPenFndAbm: '||to_char(py_za_tx_01032000.trc_AnnPenFndAbm));
      WriteHrTrace('py_za_tx_01032000.trc_ArrPenFndAbm: '||to_char(py_za_tx_01032000.trc_ArrPenFndAbm));
      WriteHrTrace('py_za_tx_01032000.trc_RetAnuAbm: '||to_char(py_za_tx_01032000.trc_RetAnuAbm));
      WriteHrTrace('py_za_tx_01032000.trc_ArrRetAnuAbm: '||to_char(py_za_tx_01032000.trc_ArrRetAnuAbm));
      WriteHrTrace('py_za_tx_01032000.trc_MedAidAbm: '||to_char(py_za_tx_01032000.trc_MedAidAbm));
      WriteHrTrace('py_za_tx_01032000.trc_PerTotAbm: '||to_char(py_za_tx_01032000.trc_PerTotAbm));
      WriteHrTrace('py_za_tx_01032000.trc_AnnTotAbm: '||to_char(py_za_tx_01032000.trc_AnnTotAbm));
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'Abatements: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END Abatements;

PROCEDURE ArrearExcess AS
-- Variables
   l_PfExcessAmt NUMBER;
   l_RaExcessAmt NUMBER;

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032000.ArrearExcess',1);
-- Pension Excess
   l_PfExcessAmt := (py_za_tx_01032000.bal_ARR_PF_YTD + (py_za_tx_01032000.bal_EXC_ARR_PEN_ITD - py_za_tx_01032000.bal_EXC_ARR_PEN_YTD)) - py_za_tx_01032000.glb_ZA_ARR_PF_AN_MX_ABT;

   IF l_PfExcessAmt > 0 THEN
      hr_utility.set_location('py_za_tx_utl_01032000.ArrearExcess',2);
      py_za_tx_01032000.trc_PfUpdFig := l_PfExcessAmt - py_za_tx_01032000.bal_EXC_ARR_PEN_ITD;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.ArrearExcess',3);
      py_za_tx_01032000.trc_PfUpdFig := -1*(py_za_tx_01032000.bal_EXC_ARR_PEN_ITD);
   END IF;

-- Retirement Annuity
   l_RaExcessAmt := (py_za_tx_01032000.bal_ARR_RA_YTD + (py_za_tx_01032000.bal_EXC_ARR_RA_ITD - py_za_tx_01032000.bal_EXC_ARR_RA_YTD)) - py_za_tx_01032000.glb_ZA_ARR_RA_AN_MX_ABT;

   IF l_RaExcessAmt > 0 THEN
      hr_utility.set_location('py_za_tx_utl_01032000.ArrearExcess',4);
      py_za_tx_01032000.trc_RaUpdFig := l_RaExcessAmt - py_za_tx_01032000.bal_EXC_ARR_RA_ITD;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.ArrearExcess',5);
      py_za_tx_01032000.trc_RaUpdFig := -1*(py_za_tx_01032000.bal_EXC_ARR_RA_ITD);
   END IF;

   hr_utility.set_location('py_za_tx_utl_01032000.ArrearExcess',6);
   WriteHrTrace('l_PfExcessAmt: '||to_char(l_PfExcessAmt));
   WriteHrTrace('l_RaExcessAmt: '||to_char(l_RaExcessAmt));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'ArrearExcess: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END ArrearExcess;

FUNCTION GetTableValue
   ( p_TableName     IN pay_user_tables.user_table_name%TYPE
   , p_ColumnName    IN pay_user_columns.user_column_name%TYPE
   , p_RowValue      IN NUMBER
   , p_EffectiveDate IN DATE
   ) RETURN VARCHAR2
AS
   l_TableValue pay_user_column_instances_f.value%TYPE;
BEGIN

   SELECT pucif.value
     INTO l_TableValue
     FROM pay_user_column_instances_f pucif
        , pay_user_columns            puc
        , pay_user_rows_f             pur
        , pay_user_tables             put
    WHERE upper(put.user_table_name) = upper(p_TableName)
      AND put.legislation_code = 'ZA'
      AND puc.user_table_id = put.user_table_id
      AND puc.legislation_code = 'ZA'
      AND upper(puc.user_column_name) = upper(p_ColumnName)
      AND pucif.user_column_id = puc.user_column_id
      AND pur.user_table_id = put.user_table_id
      AND p_EffectiveDate BETWEEN pur.effective_start_date AND pur.effective_end_date
      AND pur.legislation_code = 'ZA'
      AND p_RowValue BETWEEN pur.row_low_range_or_name AND pur.row_high_range
      AND put.user_key_units = 'N'
      AND pucif.user_row_id = pur.user_row_id
      AND p_EffectiveDate BETWEEN pucif.effective_start_date AND pucif.effective_end_date
      AND pucif.legislation_code = 'ZA';

   RETURN l_TableValue;
EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'GetTableValue: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END GetTableValue;

FUNCTION TaxLiability
   (p_Amt  IN NUMBER
   )RETURN  NUMBER
AS

-- Variables
--
   l_fixed pay_user_column_instances_f.value%TYPE;
   l_limit pay_user_column_instances_f.value%TYPE;
   l_percentage pay_user_column_instances_f.value%TYPE;
   l_effective_date pay_payroll_actions.effective_date%TYPE;
   tax_liability NUMBER(15,2);
   l_TxbAmt NUMBER(15,2);

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',1);
  -- First Check for a Tax Override
   IF py_za_tx_01032000.trc_OvrTxCalc AND py_za_tx_01032000.trc_OvrTyp = 'P' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',2);
      tax_liability := (p_Amt * py_za_tx_01032000.trc_OvrPrc) / 100;
   ELSIF py_za_tx_01032000.dbi_TX_STA = 'C' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',3);
      tax_liability := (p_Amt * py_za_tx_01032000.dbi_TX_DIR_VAL) / 100;
   ELSIF py_za_tx_01032000.dbi_TX_STA = 'D' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',4);
      tax_liability := (p_Amt * py_za_tx_01032000.dbi_TX_DIR_VAL) / 100;
   ELSIF py_za_tx_01032000.dbi_TX_STA = 'E' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',5);
      tax_liability := (p_Amt * py_za_tx_01032000.glb_ZA_CC_TX_PRC) / 100;
   ELSIF py_za_tx_01032000.dbi_TX_STA = 'F' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',6);
      tax_liability := (p_Amt * py_za_tx_01032000.glb_ZA_TMP_TX_RTE) / 100;
   ELSIF py_za_tx_01032000.dbi_TX_STA = 'J' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',7);
      tax_liability := (p_Amt * py_za_tx_01032000.glb_ZA_PER_SERV_COMP_PERC) / 100;
   ELSIF py_za_tx_01032000.dbi_TX_STA = 'L' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',8);
      tax_liability := (p_Amt * py_za_tx_01032000.glb_ZA_LABOUR_BROK_PERC) / 100;
   ELSE
      hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',9);
      /* Taxable Amount must be rounded off to two decimal places */
      l_TxbAmt := round(p_Amt,2);

      /* this selects the effective date for the payroll_run*/
      SELECT ppa.effective_date
        INTO l_effective_date
        FROM pay_payroll_actions ppa
       WHERE ppa.payroll_action_id = py_za_tx_01032000.con_PRL_ACT_ID;

      IF py_za_tx_01032000.dbi_TX_STA = 'K' THEN
         hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',10);
         l_fixed      := GetTableValue('ZA_TAX_PERSONAL_SERVICE_TRUST','Fixed',l_TxbAmt,l_effective_date);
         l_limit      := GetTableValue('ZA_TAX_PERSONAL_SERVICE_TRUST','Limit',l_TxbAmt,l_effective_date);
         l_percentage := GetTableValue('ZA_TAX_PERSONAL_SERVICE_TRUST','Percentage',l_TxbAmt,l_effective_date);
         tax_liability := (l_fixed + ((l_TxbAmt - l_limit) * (l_percentage / 100)));
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',11);
         l_fixed      := GetTableValue('ZA_TAX_TABLE','Fixed',l_TxbAmt,l_effective_date);
         l_limit      := GetTableValue('ZA_TAX_TABLE','Limit',l_TxbAmt,l_effective_date);
         l_percentage := GetTableValue('ZA_TAX_TABLE','Percentage',l_TxbAmt,l_effective_date);
         tax_liability := (l_fixed + ((l_TxbAmt - l_limit) * (l_percentage / 100))) -  py_za_tx_01032000.trc_Rebate;
      END IF;
      hr_utility.set_location('py_za_tx_utl_01032000.TaxLiability',12);
   END IF;

   WriteHrTrace('l_fixed: '||l_fixed);
   WriteHrTrace('l_TxbAmt: '||to_char(l_TxbAmt));
   WriteHrTrace('l_limit: '||l_limit);
   WriteHrTrace('l_percentage: '||l_percentage);
   WriteHrTrace('py_za_tx_01032000.trc_Rebate: '||to_char(py_za_tx_01032000.trc_Rebate));
   WriteHrTrace('tax_liability: '||to_char(tax_liability));

   RETURN tax_liability ;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'TaxLiability: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
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
   hr_utility.set_location('py_za_tx_utl_01032000.DeAnnualise',1);
   l_LiabRoy := (p_liab/py_za_tx_01032000.trc_PosFactor - (p_TxOnYtd - p_TxOnPtd))
           /py_za_tx_01032000.dbi_ZA_PAY_PRDS_LFT * py_za_tx_01032000.trc_PrdFactor;

   l_LiabFp := l_LiabRoy - p_TxOnPtd;

   hr_utility.set_location('py_za_tx_utl_01032000.DeAnnualise',2);
   WriteHrTrace('p_Liab: '||to_char(p_Liab));
   WriteHrTrace('p_TxOnYtd: '||to_char(p_TxOnYtd));
   WriteHrTrace('p_TxOnPtd: '||to_char(p_TxOnPtd));
   WriteHrTrace('l_LiabRoy: '||to_char(l_LiabRoy));
   WriteHrTrace('l_LiabFp: '||to_char(l_LiabFp));

   RETURN l_LiabFp;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'DeAnnualise: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END DeAnnualise;


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
  l_GlbVal     ff_globals_f.global_value%TYPE DEFAULT '0';

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',1);
-- Retrieve Balance Type ID's
   SELECT balance_type_id
     INTO l_NrfiBalID
     FROM pay_balance_types
    WHERE legislation_code = 'ZA'
      AND balance_name = 'Travel Allowance NRFI';

   hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',2);

   SELECT balance_type_id
     INTO l_RfiBalID
     FROM pay_balance_types
    WHERE legislation_code = 'ZA'
      AND balance_name = 'Travel Allowance RFI';

-- Check Calc and setup correct values
--
   IF py_za_tx_01032000.trc_CalTyp in ('DirCalc','NorCalc','SitCalc','YtdCalc') THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',3);
   -- Employee Tax Year Start and End Dates
   --
      l_StrtDate := GREATEST(py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE, py_za_tx_01032000.dbi_ZA_TX_YR_STRT);
      l_EndDate := LEAST(py_za_tx_01032000.dbi_ZA_ACT_END_DTE, py_za_tx_01032000.dbi_ZA_TX_YR_END,py_za_tx_01032000.dbi_ZA_CUR_PRD_END_DTE);

   ELSIF py_za_tx_01032000.trc_CalTyp = 'CalCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',4);
   -- Employee Tax Year Start and End Dates
   --
      l_StrtDate := to_date('01-01-'||to_char(py_za_tx_01032000.dbi_ZA_TX_YR_STRT,'YYYY')||''||'','DD-MM-YYYY');
      l_EndDate := py_za_tx_01032000.dbi_ZA_TX_YR_STRT -1;

   ELSIF py_za_tx_01032000.trc_CalTyp = 'LteCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',5);
   -- Employee Tax Year Start and End Dates
   --
      l_StrtDate := py_za_tx_01032000.dbi_ZA_TX_YR_STRT;
      l_EndDate := py_za_tx_01032000.dbi_ZA_CUR_PRD_END_DTE;

   ELSIF py_za_tx_01032000.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',6);
   -- Employee Tax Year Start and End Dates
   --
      SELECT MIN(ptp.start_date) "StartDate"
           , MAX(ptp.end_date) "EndDate"
        INTO l_StrtDate
           , l_EndDate
        FROM per_time_periods ptp
       WHERE ptp.payroll_id = py_za_tx_01032000.con_PRL_ID
         AND ptp.prd_information1 = py_za_tx_01032000.trc_AsgTxYear
       GROUP BY ptp.prd_information1;
   END IF;

   hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',7);

-- Loop through cursor and for every end date calculate the balance
   FOR v_Date IN c_GlbEffDte
                 (l_StrtDate
                 ,l_EndDate
                 )
   LOOP
   -- Nrfi Travel Allowance
   --
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',8);
      -- Check Calc Type
      IF py_za_tx_01032000.trc_CalTyp IN ('DirCalc','NorCalc','SitCalc','YtdCalc','LteCalc','PstCalc') THEN
         hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',9);
      -- Nrfi Balance At That Date
      -- 3491357
         /*l_NrfiYtd := py_za_bal.calc_asg_tax_ytd_date
                      (py_za_tx_01032000.con_ASG_ID
                      ,l_NrfiBalID
                      ,v_Date.effective_end_date
                      );*/
         l_NrfiYtd := py_za_bal.get_balance_value
                      (py_za_tx_01032000.con_ASG_ID
                      ,l_NrfiBalID
                      , '_ASG_TAX_YTD'
                      ,v_Date.effective_end_date
                      );
      ELSIF  py_za_tx_01032000.trc_CalTyp = 'CalCalc' THEN
         hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',10);
      -- Nrfi Balance At That Date
      -- 3491357
         /*l_NrfiYtd := py_za_bal.calc_asg_cal_ytd_date
                      (py_za_tx_01032000.con_ASG_ID
                      ,l_NrfiBalID
                      ,v_Date.effective_end_date
                      );*/
         l_NrfiYtd := py_za_bal.get_balance_value
                      (py_za_tx_01032000.con_ASG_ID
                      ,l_NrfiBalID
                      , '_ASG_CAL_YTD'
                      ,v_Date.effective_end_date
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
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',11);
      -- Check Calc Type
      IF py_za_tx_01032000.trc_CalTyp in ('DirCalc','NorCalc','SitCalc','YtdCalc','LteCalc','PstCalc') THEN
         hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',12);
      -- Rfi Balance At That Date
      -- 3491357
         /*l_RfiYtd := py_za_bal.calc_asg_tax_ytd_date
                     (py_za_tx_01032000.con_ASG_ID
                     ,l_RfiBalID
                     ,v_Date.effective_end_date
                     );*/
         l_RfiYtd := py_za_bal.get_balance_value
                     (py_za_tx_01032000.con_ASG_ID
                     ,l_RfiBalID
                     ,'_ASG_TAX_YTD'
                     ,v_Date.effective_end_date
                     );
      ELSIF py_za_tx_01032000.trc_CalTyp = 'CalCalc' THEN
         hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',13);
      -- Rfi Balance At That Date
      -- 3491357
         /*l_RfiYtd := py_za_bal.calc_asg_cal_ytd_date
                     (py_za_tx_01032000.con_ASG_ID
                     ,l_RfiBalID
                     ,v_Date.effective_end_date
                     );*/
         l_RfiYtd := py_za_bal.get_balance_value
                     (py_za_tx_01032000.con_ASG_ID
                     ,l_RfiBalID
                     , '_ASG_CAL_YTD'
                     ,v_Date.effective_end_date
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
   WriteHrTrace('l_CurRfiYtd: '||to_char(l_CurRfiYtd));
   WriteHrTrace('l_TotRfiYtd: '||to_char(l_TotRfiYtd));
   WriteHrTrace('l_CurTxbRfi: '||to_char(l_CurTxbRfi));
   WriteHrTrace('l_TotTxbRfi: '||to_char(l_TotTxbRfi));

-- Calculate the current Taxable Travel Allowance Value
-- add this to any calculated in the loop
--
   hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',14);
   -- Check Calc TYPE
   IF py_za_tx_01032000.trc_CalTyp IN ('DirCalc','NorCalc','SitCalc','YtdCalc', 'LteCalc') THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',15);
   -- Balance Values
      l_NrfiYtd := py_za_tx_01032000.bal_TA_NRFI_YTD;
      l_RfiYtd := py_za_tx_01032000.bal_TA_RFI_YTD;
   -- Global Value
      l_GlbVal := py_za_tx_01032000.glb_ZA_TRV_ALL_TX_PRC;

   ELSIF py_za_tx_01032000.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',16);
   -- Balance Values
      l_NrfiYtd := py_za_tx_01032000.bal_TA_NRFI_PTD;
      l_RfiYtd := py_za_tx_01032000.bal_TA_RFI_PTD;
   -- Global Value
      SELECT TO_NUMBER(global_value)
        INTO l_GlbVal
        FROM ff_globals_f
       WHERE l_EndDate between effective_start_date and effective_end_date
         AND global_name = 'ZA_CAR_ALLOW_TAX_PERC';

      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',17);

   ELSIF py_za_tx_01032000.trc_CalTyp = 'CalCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',18);
   -- Balance Values
      l_NrfiYtd := py_za_tx_01032000.bal_TA_NRFI_CYTD;
      l_RfiYtd := py_za_tx_01032000.bal_TA_RFI_CYTD;

   -- Global Value
      SELECT TO_NUMBER(global_value)
      INTO l_GlbVal
      FROM ff_globals_f
      WHERE l_EndDate between effective_start_date and effective_end_date
      AND global_name = 'ZA_CAR_ALLOW_TAX_PERC';

      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',19);

   END IF;

   WriteHrTrace('l_NrfiYtd: '||to_char(l_NrfiYtd));
   WriteHrTrace('l_RfiYtd: '||to_char(l_RfiYtd));
   WriteHrTrace('l_GlbVal: '||l_GlbVal);

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
   -- Check Calc Type
   IF py_za_tx_01032000.trc_CalTyp IN ('DirCalc','NorCalc','SitCalc','YtdCalc', 'LteCalc') THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',20);
      py_za_tx_01032000.bal_TA_NRFI_YTD := l_TotTxbNrfi;
      py_za_tx_01032000.bal_TA_RFI_YTD := l_TotTxbRfi;
   ELSIF py_za_tx_01032000.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',21);
      py_za_tx_01032000.bal_TA_NRFI_PTD := l_TotTxbNrfi;
      py_za_tx_01032000.bal_TA_RFI_PTD := l_TotTxbRfi;
   ELSIF py_za_tx_01032000.trc_CalTyp = 'CalCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.TrvAll',22);
      py_za_tx_01032000.bal_TA_NRFI_CYTD := l_TotTxbNrfi;
      py_za_tx_01032000.bal_TA_RFI_CYTD := l_TotTxbRfi;
   END IF;

   WriteHrTrace('l_TotTxbNrfi: '||to_char(l_TotTxbNrfi));
   WriteHrTrace('l_TotTxbRfi: '||to_char(l_TotTxbRfi));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'TrvAll: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END TrvAll;



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
   hr_utility.set_location('py_za_tx_utl_01032000.NpVal',1);
-- Set up the Table
   t_Liabilities(1).Ovrrde := py_za_tx_01032000.trc_NpValNIOvr;
   t_Liabilities(1).Lib := py_za_tx_01032000.trc_LibFpNI;

   t_Liabilities(2).Ovrrde := py_za_tx_01032000.trc_NpValFBOvr;
   t_Liabilities(2).Lib := py_za_tx_01032000.trc_LibFpFB;

   t_Liabilities(3).Ovrrde := py_za_tx_01032000.trc_NpValTAOvr;
   t_Liabilities(3).Lib := py_za_tx_01032000.trc_LibFpTA;

   t_Liabilities(4).Ovrrde := py_za_tx_01032000.trc_NpValBPOvr;
   t_Liabilities(4).Lib := py_za_tx_01032000.trc_LibFpBP;

   t_Liabilities(5).Ovrrde := py_za_tx_01032000.trc_NpValABOvr;
   t_Liabilities(5).Lib := py_za_tx_01032000.trc_LibFpAB;

   t_Liabilities(6).Ovrrde := py_za_tx_01032000.trc_NpValAPOvr;
   t_Liabilities(6).Lib := py_za_tx_01032000.trc_LibFpAP;

   t_Liabilities(7).Ovrrde := py_za_tx_01032000.trc_NpValPOOvr;
   t_Liabilities(7).Lib := py_za_tx_01032000.trc_LibFpPO;

   IF py_za_tx_01032000.trc_NpValNIOvr THEN
      WriteHrTrace('py_za_tx_01032000.trc_NpValNIOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032000.trc_NpValNIOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032000.trc_LibFpNI: '||to_char(py_za_tx_01032000.trc_LibFpNI));
   IF py_za_tx_01032000.trc_NpValFBOvr THEN
      WriteHrTrace('py_za_tx_01032000.trc_NpValFBOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032000.trc_NpValFBOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032000.trc_LibFpFB: '||to_char(py_za_tx_01032000.trc_LibFpFB));
   IF py_za_tx_01032000.trc_NpValTAOvr THEN
      WriteHrTrace('py_za_tx_01032000.trc_NpValTAOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032000.trc_NpValTAOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032000.trc_LibFpTA: '||to_char(py_za_tx_01032000.trc_LibFpTA));
   IF py_za_tx_01032000.trc_NpValBPOvr THEN
      WriteHrTrace('py_za_tx_01032000.trc_NpValBPOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032000.trc_NpValBPOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032000.trc_LibFpBP: '||to_char(py_za_tx_01032000.trc_LibFpBP));
   IF py_za_tx_01032000.trc_NpValABOvr THEN
      WriteHrTrace('py_za_tx_01032000.trc_NpValABOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032000.trc_NpValABOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032000.trc_LibFpAB: '||to_char(py_za_tx_01032000.trc_LibFpAB));
   IF py_za_tx_01032000.trc_NpValAPOvr THEN
      WriteHrTrace('py_za_tx_01032000.trc_NpValAPOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032000.trc_NpValAPOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032000.trc_LibFpAP: '||to_char(py_za_tx_01032000.trc_LibFpAP));
   IF py_za_tx_01032000.trc_NpValPOOvr THEN
      WriteHrTrace('py_za_tx_01032000.trc_NpValPOOvr: TRUE');
   ELSE
      WriteHrTrace('py_za_tx_01032000.trc_NpValPOOvr: FALSE');
   END IF;
   WriteHrTrace('py_za_tx_01032000.trc_LibFpPO: '||to_char(py_za_tx_01032000.trc_LibFpPO));

-- Sum the Liabilities
   l_TotLib :=
   ( py_za_tx_01032000.trc_LibFpNI
   + py_za_tx_01032000.trc_LibFpFB
   + py_za_tx_01032000.trc_LibFpTA
   + py_za_tx_01032000.trc_LibFpBP
   + py_za_tx_01032000.trc_LibFpAB
   + py_za_tx_01032000.trc_LibFpAP
   + py_za_tx_01032000.trc_LibFpPO
   );

-- Set Net Pay
   l_TotNp := py_za_tx_01032000.bal_NET_PAY_RUN;
   WriteHrTrace('l_TotNp: '||to_char(l_TotNp));
-- Start Validation
--
   IF l_TotLib = 0 THEN
      hr_utility.set_location('py_za_tx_utl_01032000.NpVal',2);
      NULL;
   ELSIF l_TotLib > 0 THEN
      hr_utility.set_location('py_za_tx_utl_01032000.NpVal',3);
      IF l_TotNp > 0 THEN
         hr_utility.set_location('py_za_tx_utl_01032000.NpVal',4);
         IF l_TotLib = l_TotNp THEN
            hr_utility.set_location('py_za_tx_utl_01032000.NpVal',5);
            NULL;
         ELSIF l_TotLib > l_TotNp THEN
            hr_utility.set_location('py_za_tx_utl_01032000.NpVal',6);
            l_RecVal := l_TotLib - l_TotNp;
            i:= 1;

            FOR i IN 1..7 LOOP
               IF t_Liabilities(i).Lib = 0 THEN
                  hr_utility.set_location('py_za_tx_utl_01032000.NpVal',7);
                  NULL;
               ELSIF t_Liabilities(i).Lib > 0 THEN
                  hr_utility.set_location('py_za_tx_utl_01032000.NpVal',8);
                  l_NewLib := t_Liabilities(i).Lib - LEAST(t_Liabilities(i).Lib,l_RecVal);
                  l_RecVal := l_RecVal - (t_Liabilities(i).Lib - l_NewLib);
                  t_Liabilities(i).Lib := l_NewLib;
                  py_za_tx_01032000.trc_LibWrn := 'Warning: Net Pay Balance not enough for Tax Recovery';
               ELSE -- lib < 0
                  hr_utility.set_location('py_za_tx_utl_01032000.NpVal',9);
                  NULL;
               END IF;
           END LOOP;

         ELSE -- l_TotLib > 0,l_TotNp > 0,l_TotLib < l_TotNp
            hr_utility.set_location('py_za_tx_utl_01032000.NpVal',10);
            NULL;
         END IF;

      ELSE -- l_TotLib > 0,l_TotNp <= 0
         hr_utility.set_location('py_za_tx_utl_01032000.NpVal',11);
         l_RecVal := l_TotLib;
         i := 1;

         FOR i IN 1..7 LOOP
            IF t_Liabilities(i).Lib > 0 THEN
               hr_utility.set_location('py_za_tx_utl_01032000.NpVal',12);
               l_NewLib := t_Liabilities(i).Lib - LEAST(t_Liabilities(i).Lib,l_RecVal);
               l_RecVal := l_RecVal - (t_Liabilities(i).Lib - l_NewLib);
               t_Liabilities(i).Lib := l_NewLib;
               py_za_tx_01032000.trc_LibWrn := 'Warning: Net Pay Balance not enough for Tax Recovery';
            END IF;
         END LOOP;
      END IF;

   ELSE -- l_TotLib < 0
      hr_utility.set_location('py_za_tx_utl_01032000.NpVal',13);
      IF p_Rf THEN
         hr_utility.set_location('py_za_tx_utl_01032000.NpVal',14);
         NULL;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032000.NpVal',15);
         l_RecVal := l_TotLib;
         i := 1;
         FOR i IN 1..7 LOOP
            IF t_Liabilities(i).Lib >= 0 THEN
               hr_utility.set_location('py_za_tx_utl_01032000.NpVal',16);
               NULL;
            ELSE -- l_lib < 0
               hr_utility.set_location('py_za_tx_utl_01032000.NpVal',17);
            -- Has the liability been Overridden?
               IF t_Liabilities(i).Ovrrde THEN
                  hr_utility.set_location('py_za_tx_utl_01032000.NpVal',18);
                  NULL;
               ELSE
                  hr_utility.set_location('py_za_tx_utl_01032000.NpVal',19);
                  l_NewLib := t_Liabilities(i).Lib - GREATEST(t_Liabilities(i).Lib,l_RecVal);
                  l_RecVal := l_RecVal - (t_Liabilities(i).Lib - l_NewLib);
                  t_Liabilities(i).Lib := l_NewLib;
               END IF;
           END IF;
         END LOOP;
      END IF;
   END IF;

   hr_utility.set_location('py_za_tx_utl_01032000.NpVal',20);

   py_za_tx_01032000.trc_LibFpNI := t_Liabilities(1).Lib;
   py_za_tx_01032000.trc_LibFpFB := t_Liabilities(2).Lib;
   py_za_tx_01032000.trc_LibFpTA := t_Liabilities(3).Lib;
   py_za_tx_01032000.trc_LibFpBP := t_Liabilities(4).Lib;
   py_za_tx_01032000.trc_LibFpAB := t_Liabilities(5).Lib;
   py_za_tx_01032000.trc_LibFpAP := t_Liabilities(6).Lib;
   py_za_tx_01032000.trc_LibFpPO := t_Liabilities(7).Lib;

   WriteHrTrace('py_za_tx_01032000.trc_LibFpNI: '||to_char(py_za_tx_01032000.trc_LibFpNI));
   WriteHrTrace('py_za_tx_01032000.trc_LibFpFB: '||to_char(py_za_tx_01032000.trc_LibFpFB));
   WriteHrTrace('py_za_tx_01032000.trc_LibFpTA: '||to_char(py_za_tx_01032000.trc_LibFpTA));
   WriteHrTrace('py_za_tx_01032000.trc_LibFpBP: '||to_char(py_za_tx_01032000.trc_LibFpBP));
   WriteHrTrace('py_za_tx_01032000.trc_LibFpAB: '||to_char(py_za_tx_01032000.trc_LibFpAB));
   WriteHrTrace('py_za_tx_01032000.trc_LibFpAP: '||to_char(py_za_tx_01032000.trc_LibFpAP));
   WriteHrTrace('py_za_tx_01032000.trc_LibFpPO: '||to_char(py_za_tx_01032000.trc_LibFpPO));

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'NpVal: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
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
   IF py_za_tx_01032000.trc_CalTyp = 'YtdCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.DaysWorked',1);
      l_EndDte := py_za_tx_01032000.dbi_ZA_CUR_PRD_STRT_DTE - 1;
      l_StrtDte := GREATEST(py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE, py_za_tx_01032000.dbi_ZA_TX_YR_STRT);

   ELSIF py_za_tx_01032000.trc_CalTyp = 'CalCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.DaysWorked',2);
      l_EndDte := py_za_tx_01032000.dbi_ZA_TX_YR_STRT - 1;
      l_StrtDte := GREATEST(py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE,
      to_date('01-JAN-'||to_char(to_number(to_char(py_za_tx_01032000.dbi_ZA_TX_YR_END,'YYYY'))-1),'DD/MM/YYYY'));

   ELSIF py_za_tx_01032000.trc_CalTyp = 'SitCalc' AND
       ( py_za_tx_01032000.trc_RetroInPeriod
      OR py_za_tx_01032000.trc_OvrTxCalc
       )THEN
      hr_utility.set_location('py_za_tx_utl_01032000.DaysWorked',3);
      l_EndDte := LEAST(py_za_tx_01032000.dbi_ZA_ACT_END_DTE, py_za_tx_01032000.dbi_ZA_CUR_PRD_END_DTE);
      l_StrtDte := GREATEST(py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE, py_za_tx_01032000.dbi_ZA_TX_YR_STRT);

   ELSIF py_za_tx_01032000.trc_CalTyp = 'SitCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.DaysWorked',4);
      l_EndDte := LEAST(py_za_tx_01032000.dbi_ZA_ACT_END_DTE, py_za_tx_01032000.dbi_ZA_TX_YR_END);
      l_StrtDte := GREATEST(py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE, py_za_tx_01032000.dbi_ZA_TX_YR_STRT);

   ELSIF py_za_tx_01032000.trc_CalTyp = 'PstCalc' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.DaysWorked',5);
      l_EndDte := py_za_tx_01032000.dbi_ZA_ACT_END_DTE;
   -- Get Asg Start Date
      SELECT MIN(ptp.start_date)
        INTO l_StrtDte
        FROM per_time_periods ptp
       WHERE ptp.prd_information1 = py_za_tx_01032000.trc_AsgTxYear
         AND ptp.payroll_id = py_za_tx_01032000.con_PRL_ID;

      hr_utility.set_location('py_za_tx_utl_01032000.DaysWorked',6);

      l_StrtDte := GREATEST(py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE, l_StrtDte);
   END IF;

   l_DaysWorked := l_EndDte - l_StrtDte + 1; -- remember about the zero!!!!!

   WriteHrTrace('l_EndDte: '||to_char(l_EndDte,'DD/MM/YYYY'));
   WriteHrTrace('l_StrtDte: '||to_char(l_StrtDte,'DD/MM/YYYY'));
   WriteHrTrace('l_DaysWorked: '||to_char(l_DaysWorked));

   RETURN l_DaysWorked;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'DaysWorked: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END DaysWorked;


PROCEDURE SitPaySplit
AS
   l_TxOnSitLim NUMBER(15,2);
   l_SitAblTx NUMBER(15,2);
BEGIN
   hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',1);
-- Directive Type Statuses
--
   IF py_za_tx_01032000.dbi_TX_STA IN ('C','D','E','F','J','K','L') THEN
      hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',2);
   -- Check for SitePeriod
      IF SitePeriod THEN
         hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',3);
         py_za_tx_01032000.trc_PayeVal :=
            ( py_za_tx_01032000.bal_TAX_YTD
            + py_za_tx_01032000.trc_LibFpNI
            + py_za_tx_01032000.trc_LibFpFB
            + py_za_tx_01032000.trc_LibFpTA
            + py_za_tx_01032000.trc_LibFpBP
            + py_za_tx_01032000.trc_LibFpAB
            + py_za_tx_01032000.trc_LibFpAP
            + py_za_tx_01032000.trc_LibFpPO
            ) - py_za_tx_01032000.bal_PAYE_YTD;
         py_za_tx_01032000.trc_SiteVal := -1*py_za_tx_01032000.bal_SITE_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',4);
         py_za_tx_01032000.trc_PayeVal := -1*py_za_tx_01032000.bal_PAYE_YTD;
         py_za_tx_01032000.trc_SiteVal := -1*py_za_tx_01032000.bal_SITE_YTD;
      END IF;
-- Normal Type Statuses
--
   ELSIF py_za_tx_01032000.dbi_TX_STA IN ('A','B') THEN
      IF (SitePeriod AND NOT PreErnPeriod) OR LatePayPeriod THEN
         hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',5);
      -- Get the Tax Liability on the Site Limit
         l_TxOnSitLim := TaxLiability(p_Amt => py_za_tx_01032000.glb_ZA_SIT_LIM)/py_za_tx_01032000.trc_SitFactor;
      -- Get the Tax Amount Liable for SITE
         l_SitAblTx :=
         ( py_za_tx_01032000.bal_TX_ON_NI_YTD
         + py_za_tx_01032000.bal_TX_ON_FB_YTD
         + py_za_tx_01032000.bal_TX_ON_BP_YTD
         + py_za_tx_01032000.bal_TX_ON_AB_YTD
         + py_za_tx_01032000.bal_TX_ON_AP_YTD
         + py_za_tx_01032000.trc_LibFpNI
         + py_za_tx_01032000.trc_LibFpFB
         + py_za_tx_01032000.trc_LibFpBP
         + py_za_tx_01032000.trc_LibFpAB
         + py_za_tx_01032000.trc_LibFpAP
         );
      -- Check the Limit
         IF l_SitAblTx > l_TxOnSitLim THEN
            hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',6);
            py_za_tx_01032000.trc_SiteVal := l_TxOnSitLim - py_za_tx_01032000.bal_SITE_YTD;
            py_za_tx_01032000.trc_PayeVal := (
              ( py_za_tx_01032000.bal_TAX_YTD
              + py_za_tx_01032000.trc_LibFpNI
              + py_za_tx_01032000.trc_LibFpFB
              + py_za_tx_01032000.trc_LibFpBP
              + py_za_tx_01032000.trc_LibFpAB
              + py_za_tx_01032000.trc_LibFpAP
              + py_za_tx_01032000.trc_LibFpTA
              + py_za_tx_01032000.trc_LibFpPO
              ) - l_TxOnSitLim) - py_za_tx_01032000.bal_PAYE_YTD;

         ELSE
            hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',7);
            IF ( py_za_tx_01032000.bal_TX_ON_TA_YTD
               + py_za_tx_01032000.trc_LibFpTA
               + py_za_tx_01032000.bal_TX_ON_PO_YTD
               + py_za_tx_01032000.trc_LibFpPO
               ) <= 0 THEN
               hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',8);
               py_za_tx_01032000.trc_SiteVal := ( py_za_tx_01032000.bal_TAX_YTD
                              + py_za_tx_01032000.trc_LibFpNI
                              + py_za_tx_01032000.trc_LibFpFB
                              + py_za_tx_01032000.trc_LibFpBP
                              + py_za_tx_01032000.trc_LibFpAB
                              + py_za_tx_01032000.trc_LibFpAP
                              + py_za_tx_01032000.trc_LibFpTA
                              + py_za_tx_01032000.trc_LibFpPO) - py_za_tx_01032000.bal_SITE_YTD;

               py_za_tx_01032000.trc_PayeVal := -1*py_za_tx_01032000.bal_PAYE_YTD;
            ELSE
               hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',9);
               py_za_tx_01032000.trc_SiteVal := l_SitAblTx - py_za_tx_01032000.bal_SITE_YTD;

               py_za_tx_01032000.trc_PayeVal := (
                 ( py_za_tx_01032000.bal_TAX_YTD
                 + py_za_tx_01032000.trc_LibFpNI
                 + py_za_tx_01032000.trc_LibFpFB
                 + py_za_tx_01032000.trc_LibFpBP
                 + py_za_tx_01032000.trc_LibFpAB
                 + py_za_tx_01032000.trc_LibFpAP
                 + py_za_tx_01032000.trc_LibFpTA
                 + py_za_tx_01032000.trc_LibFpPO
                 ) - l_SitAblTx) - py_za_tx_01032000.bal_PAYE_YTD;
            END IF;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',10);
         py_za_tx_01032000.trc_PayeVal := -1*py_za_tx_01032000.bal_PAYE_YTD;
         py_za_tx_01032000.trc_SiteVal := -1*py_za_tx_01032000.bal_SITE_YTD;
      END IF;
-- Seasonal Worker Status
--
   ELSIF py_za_tx_01032000.dbi_TX_STA = 'G' THEN
      hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',11);
   -- Get the SitFactor YTD
      py_za_tx_01032000.trc_SitFactor := py_za_tx_01032000.glb_ZA_WRK_DYS_PR_YR / py_za_tx_01032000.bal_TOT_SEA_WRK_DYS_WRK_YTD;
   -- Get the Tax Liability on the Site Limit
      l_TxOnSitLim := TaxLiability(p_Amt => py_za_tx_01032000.glb_ZA_SIT_LIM)/py_za_tx_01032000.trc_SitFactor;
   -- Get the Tax Amount Liable for SITE
      l_SitAblTx :=
      ( py_za_tx_01032000.bal_TX_ON_NI_YTD
      + py_za_tx_01032000.bal_TX_ON_FB_YTD
      + py_za_tx_01032000.bal_TX_ON_AP_YTD
      + py_za_tx_01032000.trc_LibFpNI
      + py_za_tx_01032000.trc_LibFpFB
      + py_za_tx_01032000.trc_LibFpAP
      );
   -- Check the Limit
      IF l_SitAblTx > l_TxOnSitLim THEN
         hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',12);
         py_za_tx_01032000.trc_SiteVal := l_TxOnSitLim - py_za_tx_01032000.bal_SITE_YTD;
         py_za_tx_01032000.trc_PayeVal := ((py_za_tx_01032000.bal_TX_ON_PO_YTD+py_za_tx_01032000.trc_LibFpPO) +(l_SitAblTx - l_TxOnSitLim)) - py_za_tx_01032000.bal_PAYE_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',13);
         py_za_tx_01032000.trc_SiteVal := l_SitAblTx - py_za_tx_01032000.bal_SITE_YTD;
         py_za_tx_01032000.trc_PayeVal := py_za_tx_01032000.bal_TX_ON_PO_YTD + py_za_tx_01032000.trc_LibFpPO  - py_za_tx_01032000.bal_PAYE_YTD;
      END IF;
-- All Other Statuses
--
   ELSE -- set the globals to zero
      hr_utility.set_location('py_za_tx_utl_01032000.SitPaySplit',14);
      py_za_tx_01032000.trc_PayeVal := 0 - py_za_tx_01032000.bal_PAYE_YTD;
      py_za_tx_01032000.trc_SiteVal := 0 - py_za_tx_01032000.bal_SITE_YTD;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'SitPaySplit: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
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
    py_za_tx_01032000.con_ASG_ACT_ID
   ,py_za_tx_01032000.con_ASG_ID
   ,py_za_tx_01032000.con_PRL_ACT_ID
   ,py_za_tx_01032000.con_PRL_ID
   ,py_za_tx_01032000.dbi_TX_STA
   ,py_za_tx_01032000.dbi_PER_AGE
   ,py_za_tx_01032000.trc_CalTyp
   ,py_za_tx_01032000.dbi_TX_DIR_VAL
   ,py_za_tx_01032000.trc_It3Ind
   ,py_za_tx_01032000.trc_TxPercVal
   ,py_za_tx_01032000.dbi_ZA_ACT_STRT_DTE
   ,py_za_tx_01032000.dbi_ZA_ACT_END_DTE
   ,py_za_tx_01032000.dbi_ZA_CUR_PRD_STRT_DTE
   ,py_za_tx_01032000.dbi_ZA_CUR_PRD_END_DTE
   ,py_za_tx_01032000.dbi_ZA_TX_YR_STRT
   ,py_za_tx_01032000.dbi_ZA_TX_YR_END
   ,py_za_tx_01032000.dbi_SES_DTE
   ,py_za_tx_01032000.trc_PrdFactor
   ,py_za_tx_01032000.trc_PosFactor
   ,py_za_tx_01032000.trc_SitFactor
   ,py_za_tx_01032000.dbi_ZA_PAY_PRDS_LFT
   ,py_za_tx_01032000.dbi_ZA_PAY_PRDS_PER_YR
   ,py_za_tx_01032000.dbi_ZA_DYS_IN_YR
   ,py_za_tx_01032000.dbi_SEA_WRK_DYS_WRK
   ,py_za_tx_01032000.dbi_ARR_PF_FRQ
   ,py_za_tx_01032000.dbi_ARR_RA_FRQ
   ,py_za_tx_01032000.dbi_BP_TX_RCV
   ,py_za_tx_01032000.dbi_RA_FRQ
   ,py_za_tx_01032000.trc_TxbIncPtd
   ,py_za_tx_01032000.trc_BseErn
   ,py_za_tx_01032000.trc_TxbBseInc
   ,py_za_tx_01032000.trc_TotLibBse
   ,py_za_tx_01032000.trc_TxbIncYtd
   ,py_za_tx_01032000.trc_PerTxbInc
   ,py_za_tx_01032000.trc_PerPenFnd
   ,py_za_tx_01032000.trc_PerRfiCon
   ,py_za_tx_01032000.trc_PerRfiTxb
   ,py_za_tx_01032000.trc_PerPenFndMax
   ,py_za_tx_01032000.trc_PerPenFndAbm
   ,py_za_tx_01032000.trc_AnnTxbInc
   ,py_za_tx_01032000.trc_AnnPenFnd
   ,py_za_tx_01032000.trc_AnnRfiCon
   ,py_za_tx_01032000.trc_AnnRfiTxb
   ,py_za_tx_01032000.trc_AnnPenFndMax
   ,py_za_tx_01032000.trc_AnnPenFndAbm
   ,py_za_tx_01032000.trc_ArrPenFnd
   ,py_za_tx_01032000.trc_ArrPenFndAbm
   ,py_za_tx_01032000.trc_RetAnu
   ,py_za_tx_01032000.trc_NrfiCon
   ,py_za_tx_01032000.trc_RetAnuMax
   ,py_za_tx_01032000.trc_RetAnuAbm
   ,py_za_tx_01032000.trc_ArrRetAnu
   ,py_za_tx_01032000.trc_ArrRetAnuAbm
   ,py_za_tx_01032000.trc_Rebate
   ,py_za_tx_01032000.trc_Threshold
   ,py_za_tx_01032000.trc_MedAidAbm
   ,py_za_tx_01032000.trc_PerTotAbm
   ,py_za_tx_01032000.trc_AnnTotAbm
   ,py_za_tx_01032000.trc_NorIncYtd
   ,py_za_tx_01032000.trc_NorIncPtd
   ,py_za_tx_01032000.trc_NorErn
   ,py_za_tx_01032000.trc_TxbNorInc
   ,py_za_tx_01032000.trc_LibFyNI
   ,py_za_tx_01032000.bal_TX_ON_NI_YTD
   ,py_za_tx_01032000.bal_TX_ON_NI_PTD
   ,py_za_tx_01032000.trc_LibFpNI
   ,py_za_tx_01032000.trc_FrnBenYtd
   ,py_za_tx_01032000.trc_FrnBenPtd
   ,py_za_tx_01032000.trc_FrnBenErn
   ,py_za_tx_01032000.trc_TxbFrnInc
   ,py_za_tx_01032000.trc_LibFyFB
   ,py_za_tx_01032000.bal_TX_ON_FB_YTD
   ,py_za_tx_01032000.bal_TX_ON_FB_PTD
   ,py_za_tx_01032000.trc_LibFpFB
   ,py_za_tx_01032000.trc_TrvAllYtd
   ,py_za_tx_01032000.trc_TrvAllPtd
   ,py_za_tx_01032000.trc_TrvAllErn
   ,py_za_tx_01032000.trc_TxbTrvInc
   ,py_za_tx_01032000.trc_LibFyTA
   ,py_za_tx_01032000.bal_TX_ON_TA_YTD
   ,py_za_tx_01032000.bal_TX_ON_TA_PTD
   ,py_za_tx_01032000.trc_LibFpTA
   ,py_za_tx_01032000.trc_BonProYtd
   ,py_za_tx_01032000.trc_BonProPtd
   ,py_za_tx_01032000.trc_BonProErn
   ,py_za_tx_01032000.trc_TxbBonProInc
   ,py_za_tx_01032000.trc_LibFyBP
   ,py_za_tx_01032000.bal_TX_ON_BP_YTD
   ,py_za_tx_01032000.bal_TX_ON_BP_PTD
   ,py_za_tx_01032000.trc_LibFpBP
   ,py_za_tx_01032000.trc_AnnBonYtd
   ,py_za_tx_01032000.trc_AnnBonErn
   ,py_za_tx_01032000.trc_TxbAnnBonInc
   ,py_za_tx_01032000.trc_LibFyAB
   ,py_za_tx_01032000.bal_TX_ON_AB_YTD
   ,py_za_tx_01032000.bal_TX_ON_AB_PTD
   ,py_za_tx_01032000.trc_LibFpAB
   ,py_za_tx_01032000.trc_AnnPymYtd
   ,py_za_tx_01032000.trc_AnnPymPtd
   ,py_za_tx_01032000.trc_AnnPymErn
   ,py_za_tx_01032000.trc_TxbAnnPymInc
   ,py_za_tx_01032000.trc_LibFyAP
   ,py_za_tx_01032000.bal_TX_ON_AP_YTD
   ,py_za_tx_01032000.bal_TX_ON_AP_PTD
   ,py_za_tx_01032000.trc_LibFpAP
   ,py_za_tx_01032000.trc_PblOffYtd
   ,py_za_tx_01032000.trc_PblOffPtd
   ,py_za_tx_01032000.trc_PblOffErn
   ,py_za_tx_01032000.trc_LibFyPO
   ,py_za_tx_01032000.bal_TX_ON_PO_YTD
   ,py_za_tx_01032000.bal_TX_ON_PO_PTD
   ,py_za_tx_01032000.trc_LibFpPO
   ,''
   ,py_za_tx_01032000.trc_LibWrn
   ,py_za_tx_01032000.trc_PayValue
   ,py_za_tx_01032000.trc_PayeVal
   ,py_za_tx_01032000.trc_SiteVal);

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'Trace: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END Trace;

PROCEDURE ClearGlobals AS

BEGIN
   hr_utility.set_location('py_za_tx_utl_01032000.ClearGlobals',1);
-- Calculation Type
   py_za_tx_01032000.trc_CalTyp := 'Unknown';
-- Factors
   py_za_tx_01032000.trc_TxbIncPtd := 0;
   py_za_tx_01032000.trc_PrdFactor := 0;
   py_za_tx_01032000.trc_PosFactor := 0;
   py_za_tx_01032000.trc_SitFactor := 1;
-- Base Income
   py_za_tx_01032000.trc_BseErn := 0;
   py_za_tx_01032000.trc_TxbBseInc := 0;
   py_za_tx_01032000.trc_TotLibBse := 0;
-- Period Pension Fund
   py_za_tx_01032000.trc_TxbIncYtd := 0;
   py_za_tx_01032000.trc_PerTxbInc := 0;
   py_za_tx_01032000.trc_PerPenFnd := 0;
   py_za_tx_01032000.trc_PerRfiCon := 0;
   py_za_tx_01032000.trc_PerRfiTxb := 0;
   py_za_tx_01032000.trc_PerPenFndMax := 0;
   py_za_tx_01032000.trc_PerPenFndAbm := 0;
-- Annual Pension Fund
   py_za_tx_01032000.trc_AnnTxbInc := 0;
   py_za_tx_01032000.trc_AnnPenFnd := 0;
   py_za_tx_01032000.trc_AnnRfiCon := 0;
   py_za_tx_01032000.trc_AnnRfiTxb := 0;
   py_za_tx_01032000.trc_AnnPenFndMax := 0;
   py_za_tx_01032000.trc_AnnPenFndAbm := 0;
-- Arrear Pension
   py_za_tx_01032000.trc_ArrPenFnd := 0;
   py_za_tx_01032000.trc_ArrPenFndAbm := 0;
   py_za_tx_01032000.trc_PfUpdFig := 0;
-- Retirement Annuity
   py_za_tx_01032000.trc_RetAnu := 0;
   py_za_tx_01032000.trc_NrfiCon := 0;
   py_za_tx_01032000.trc_RetAnuMax := 0;
   py_za_tx_01032000.trc_RetAnuAbm := 0;
-- Arrear Retirement Annuity
   py_za_tx_01032000.trc_ArrRetAnu := 0;
   py_za_tx_01032000.trc_ArrRetAnuAbm := 0;
   py_za_tx_01032000.trc_RaUpdFig := 0;
-- Rebates Thresholds and Med Aid
   py_za_tx_01032000.trc_Rebate := 0;
   py_za_tx_01032000.trc_Threshold := 0;
   py_za_tx_01032000.trc_MedAidAbm := 0;
-- Abatement Totals
   py_za_tx_01032000.trc_PerTotAbm := 0;
   py_za_tx_01032000.trc_AnnTotAbm := 0;
-- Normal Income
   py_za_tx_01032000.trc_NorIncYtd := 0;
   py_za_tx_01032000.trc_NorIncPtd := 0;
   py_za_tx_01032000.trc_NorErn := 0;
   py_za_tx_01032000.trc_TxbNorInc := 0;
   py_za_tx_01032000.trc_TotLibNI  := 0;
   py_za_tx_01032000.trc_LibFyNI := 0;
   py_za_tx_01032000.trc_LibFpNI := 0;
-- Fringe Benefits
   py_za_tx_01032000.trc_FrnBenYtd := 0;
   py_za_tx_01032000.trc_FrnBenPtd := 0;
   py_za_tx_01032000.trc_FrnBenErn := 0;
   py_za_tx_01032000.trc_TxbFrnInc := 0;
   py_za_tx_01032000.trc_TotLibFB := 0;
   py_za_tx_01032000.trc_LibFyFB := 0;
   py_za_tx_01032000.trc_LibFpFB := 0;
-- Travel Allowance
   py_za_tx_01032000.trc_TrvAllYtd := 0;
   py_za_tx_01032000.trc_TrvAllPtd := 0;
   py_za_tx_01032000.trc_TrvAllErn := 0;
   py_za_tx_01032000.trc_TxbTrvInc := 0;
   py_za_tx_01032000.trc_TotLibTA := 0;
   py_za_tx_01032000.trc_LibFyTA := 0;
   py_za_tx_01032000.trc_LibFpTA := 0;
-- Bonus Provision
   py_za_tx_01032000.trc_BonProYtd := 0;
   py_za_tx_01032000.trc_BonProPtd := 0;
   py_za_tx_01032000.trc_BonProErn := 0;
   py_za_tx_01032000.trc_TxbBonProInc := 0;
   py_za_tx_01032000.trc_TotLibBP := 0;
   py_za_tx_01032000.trc_LibFyBP := 0;
   py_za_tx_01032000.trc_LibFpBP := 0;
-- Annual Bonus
   py_za_tx_01032000.trc_AnnBonYtd := 0;
   py_za_tx_01032000.trc_AnnBonPtd := 0;
   py_za_tx_01032000.trc_AnnBonErn := 0;
   py_za_tx_01032000.trc_TxbAnnBonInc := 0;
   py_za_tx_01032000.trc_TotLibAB := 0;
   py_za_tx_01032000.trc_LibFyAB := 0;
   py_za_tx_01032000.trc_LibFpAB := 0;
-- Annual Payments
   py_za_tx_01032000.trc_AnnPymYtd := 0;
   py_za_tx_01032000.trc_AnnPymPtd := 0;
   py_za_tx_01032000.trc_AnnPymErn := 0;
   py_za_tx_01032000.trc_TxbAnnPymInc := 0;
   py_za_tx_01032000.trc_TotLibAP := 0;
   py_za_tx_01032000.trc_LibFyAP := 0;
   py_za_tx_01032000.trc_LibFpAP := 0;
-- Pubilc Office Allowance
   py_za_tx_01032000.trc_PblOffYtd := 0;
   py_za_tx_01032000.trc_PblOffPtd := 0;
   py_za_tx_01032000.trc_PblOffErn := 0;
   py_za_tx_01032000.trc_LibFyPO := 0;
   py_za_tx_01032000.trc_LibFpPO := 0;
-- Messages
   py_za_tx_01032000.trc_LibWrn := ' ';
-- Pay Value of This Calculation
   py_za_tx_01032000.trc_PayValue := 0;
-- PAYE and SITE Values
   py_za_tx_01032000.trc_PayeVal := 0;
   py_za_tx_01032000.trc_SiteVal := 0;
-- IT3A Threshold Indicator
   py_za_tx_01032000.trc_It3Ind := 0;
-- Tax Percentage Value On trace
   py_za_tx_01032000.trc_TxPercVal := 0;

-- Total Taxable Income Update Figure
   py_za_tx_01032000.trc_OUpdFig := 0;

-- Net Taxable Income Update Figure
   py_za_tx_01032000.trc_NtiUpdFig := 0;

-- NpVal Override Globals
   py_za_tx_01032000.trc_NpValNIOvr := FALSE;
   py_za_tx_01032000.trc_NpValFBOvr := FALSE;
   py_za_tx_01032000.trc_NpValTAOvr := FALSE;
   py_za_tx_01032000.trc_NpValBPOvr := FALSE;
   py_za_tx_01032000.trc_NpValABOvr := FALSE;
   py_za_tx_01032000.trc_NpValAPOvr := FALSE;
   py_za_tx_01032000.trc_NpValPOOvr := FALSE;

-- Assignment Tax Year
   py_za_tx_01032000.trc_AsgTxYear := 0;

-- Global Exception Message
   py_za_tx_01032000.xpt_Msg := 'No Error';

-- Override Globals
   py_za_tx_01032000.trc_OvrTxCalc   := FALSE;
   py_za_tx_01032000.trc_OvrTyp      := 'V';
   py_za_tx_01032000.trc_OvrPrc      := 0;
   py_za_tx_01032000.trc_OvrWrn      := ' ';

-- Retro Global
   py_za_tx_01032000.trc_RetroInPeriod := FALSE;

EXCEPTION
   WHEN OTHERS THEN
      IF py_za_tx_01032000.xpt_Msg = 'No Error' THEN
         py_za_tx_01032000.xpt_Msg := 'ClearGlobals: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE py_za_tx_01032000.xpt_E;
END ClearGlobals;

END py_za_tx_utl_01032000;


/
