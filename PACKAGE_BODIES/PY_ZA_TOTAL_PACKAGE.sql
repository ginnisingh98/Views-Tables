--------------------------------------------------------
--  DDL for Package Body PY_ZA_TOTAL_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_TOTAL_PACKAGE" AS
/* $Header: pyzatotpkg.pkb 120.1.12000000.3 2007/07/06 05:08:48 rpahune noship $ */
/* Copyright (c) Oracle Corporation 2005. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation

   NAME
      py_za_total_package

   DESCRIPTION
      This is the ZA Total Package supporting package.

   NOTES
      .

   MODIFICATION HISTORY
      Person       Date        Version  Bug      Comments
      -----------  ----------  -------  -------  --------------------------------
      J.N. Louw    03/07/2007  115.7    6166736  + trc_RFIableTotPkgPTD_Upd
      J.N. Louw    04/04/2007  115.6    5964600
      A. Mahanty   16/05/2006  115.5    5148830  Modified ZA_Total_Package formula
                                                 with reference to the new dimension
                                                 _rtr_asg_tax_ptd.
                                                 Norcalc is done even for cases when
                                                 retro results exist
      A. Mahanty   01/03/2006  115.4    4346955  Modified ZA_Total_Package formula.
                                                 Sitcalc is done for assignments where
                                                 retro results exist
      A. Mahanty   03/11/2005  115.3    4346955  Modified ZA_Total_Package formula.
                                                 Norcalc is done even for cases when
                                                 retro results exist
      J.N. Louw    11/10/2005  115.2    4667439  Added StopHrTrace
      J.N. Louw    14/09/2005  115.1    4566053  Added annualisation to the split
      R.V. Pahune  05/08/2005  115.0    4346920  Balance feed enhancement
      J.N. Louw    17/08/2005  115.0             Initial Version
*/

-------------------------------------------------------------------------------
--                           PACKAGE BODY GLOBAL AREA                        --
-------------------------------------------------------------------------------
   -- Types
   SUBTYPE BALANCE IS NUMBER(15,2);
   -- Application Database Items
   dbi_FXD_PRC              NUMBER;
   dbi_TOT_PKG              BALANCE;
   dbi_ZA_ACT_END_DTE       DATE;
   dbi_ZA_ACT_STRT_DTE      DATE;
   dbi_ZA_ASG_TAX_RTR_RSLTS VARCHAR2(1);
   dbi_ZA_ASG_TX_RTR_PRD    VARCHAR2(1);
   dbi_ZA_ASG_TX_YR         NUMBER(4);
   dbi_ZA_CUR_PRD_END_DTE   DATE;
   dbi_ZA_CUR_PRD_STRT_DTE  DATE;
   dbi_ZA_DYS_IN_YR         NUMBER;
   dbi_ZA_PAY_PRDS_LFT      NUMBER;
   dbi_ZA_PAY_PRDS_PER_YR   NUMBER;
   dbi_ZA_TX_YR_END         DATE;
   dbi_ZA_TX_YR_STRT        DATE;
   -- Balances
   bal_ANN_TXB_PKG_CMP_NRFI_YTD BALANCE;
   bal_ANN_TXB_PKG_CMP_RFI_YTD  BALANCE;
   bal_ANN_TXB_PKG_CMP_YTD      BALANCE;
   bal_BP_PTD                   BALANCE;
   bal_BP_YTD                   BALANCE;
   bal_RFIABLE_TOT_PKG_CYTD     BALANCE;
   bal_RFIABLE_TOT_PKG_PTD      BALANCE;
   bal_RFIABLE_TOT_PKG_YTD      BALANCE;
   bal_TOT_TXB_AB_RUN           BALANCE;
   bal_TOT_TXB_AP_YTD           BALANCE;
   bal_TOT_TXB_FB_CYTD          BALANCE;
   bal_TOT_TXB_FB_PTD           BALANCE;
   bal_TOT_TXB_FB_YTD           BALANCE;
   bal_TOT_TXB_NI_CYTD          BALANCE;
   bal_TOT_TXB_NI_PTD           BALANCE;
   bal_TOT_TXB_NI_YTD           BALANCE;
   bal_TOT_TXB_TA_CYTD          BALANCE;
   bal_TOT_TXB_TA_PTD           BALANCE;
   bal_TOT_TXB_TA_YTD           BALANCE;
   bal_TXB_PKG_CMP_CYTD         BALANCE;
   bal_TXB_PKG_CMP_NRFI_YTD     BALANCE;
   bal_TXB_PKG_CMP_PTD          BALANCE;
   bal_TXB_PKG_CMP_RFI_YTD      BALANCE;
   bal_TXB_PKG_CMP_YTD          BALANCE;
   -- Trace Globals
   trc_AnnBonPtd            BALANCE DEFAULT 0;
   trc_AnnPymPtd            BALANCE DEFAULT 0;
   trc_AnnTxbPkgCmpNRFI     BALANCE DEFAULT 0;
   trc_AnnTxbPkgCmpNRFI_Upd BALANCE DEFAULT 0;
   trc_AnnTxbPkgCmpRFI      BALANCE DEFAULT 0;
   trc_AnnTxbPkgCmpRFI_Upd  BALANCE DEFAULT 0;
   trc_AnnualisationType    VARCHAR2(7) DEFAULT 'Unknown';
   trc_NegPtd               BOOLEAN DEFAULT FALSE;
   trc_PosFactor            NUMBER  DEFAULT 0;
   trc_PrdFactor            NUMBER  DEFAULT 0;
   trc_PrjRFIableTotPkg     BALANCE DEFAULT 0;
   trc_RFIableTotPkgPTD     BALANCE DEFAULT 0;
   trc_RFIableTotPkgPTD_Upd BALANCE DEFAULT 0;
   trc_SitFactor            NUMBER  DEFAULT 1;
   trc_TotTxbPkgCmp         BALANCE DEFAULT 0;
   trc_TxbIncPtd            BALANCE DEFAULT 0;
   trc_TxbIncYtd            BALANCE DEFAULT 0;
   trc_TxbPkgCmp            BALANCE DEFAULT 0;
   trc_TxbPkgCmpNRFI        BALANCE DEFAULT 0;
   trc_TxbPkgCmpNRFI_Upd    BALANCE DEFAULT 0;
   trc_TxbPkgCmpRFI         BALANCE DEFAULT 0;
   trc_TxbPkgCmpRFI_Upd     BALANCE DEFAULT 0;
   trc_TxbPrc               NUMBER  DEFAULT 0;
   -- Global Exception Message
   xpt_Msg                   VARCHAR2(100) DEFAULT 'No Error';
   -- Global Exception
   xpt_E                     EXCEPTION;

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
-- LatePayPeriod                                                             --
-------------------------------------------------------------------------------
FUNCTION LatePayPeriod RETURN BOOLEAN AS
-- Variables
   l_CurTxYear NUMBER(15);
BEGIN
   g_indent := g_indent||'   ';
   hr_utility.set_location(g_indent||'py_za_total_package.LatePayPeriod',1);
-- IF the employee's assignment ended before the current tax year
-- it's a Late Pay Period
   IF dbi_ZA_ACT_END_DTE < dbi_ZA_TX_YR_STRT THEN

      hr_utility.set_location(g_indent||'py_za_total_package.LatePayPeriod',2);

   -- Valid Late Pay Period?
   --
   -- Current Tax Year
      l_CurTxYear := to_number(to_char(dbi_ZA_TX_YR_END,'YYYY'));

      hr_utility.set_location(g_indent||'py_za_total_package.LatePayPeriod',3);

      IF (l_CurTxYear - dbi_ZA_ASG_TX_YR) > 1 THEN
         hr_utility.set_location(g_indent||'py_za_total_package.LatePayPeriod',4);
         hr_utility.set_message(801, 'Late Payment Across Two Tax Years!');
         hr_utility.raise_error;
      ELSE
         hr_utility.set_location(g_indent||'py_za_total_package.LatePayPeriod',5);
         g_indent := substr(g_indent,1,length(g_indent)-3);
         RETURN TRUE;
      END IF;

   ELSE
      hr_utility.set_location(g_indent||'py_za_total_package.LatePayPeriod',6);
      g_indent := substr(g_indent,1,length(g_indent)-3);
      RETURN FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'LatePayPeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END LatePayPeriod;
-------------------------------------------------------------------------------
-- LstPeriod                                                                 --
-------------------------------------------------------------------------------
FUNCTION LstPeriod RETURN BOOLEAN AS
BEGIN
   g_indent := g_indent||'   ';
   -- Is this the last period for the tax year
   --
   IF dbi_ZA_PAY_PRDS_LFT = 1 THEN
      hr_utility.set_location(g_indent||'py_za_total_package.LstPeriod',1);
      g_indent := substr(g_indent,1,length(g_indent)-3);
      RETURN TRUE;
   ELSE
      hr_utility.set_location(g_indent||'py_za_total_package.LstPeriod',2);
      g_indent := substr(g_indent,1,length(g_indent)-3);
      RETURN FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'LstPeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END LstPeriod;
-------------------------------------------------------------------------------
-- EmpTermInPeriod                                                           --
-------------------------------------------------------------------------------
FUNCTION EmpTermInPeriod RETURN BOOLEAN AS

BEGIN
   g_indent := g_indent||'   ';
   -- Was the employee terminated in the current period
   --
   IF dbi_ZA_ACT_END_DTE BETWEEN dbi_ZA_CUR_PRD_STRT_DTE
                             AND dbi_ZA_CUR_PRD_END_DTE
   THEN
      hr_utility.set_location(g_indent||'py_za_total_package.EmpTermInPeriod',1);
      g_indent := substr(g_indent,1,length(g_indent)-3);
      RETURN TRUE;
   ELSE
      hr_utility.set_location(g_indent||'py_za_total_package.EmpTermInPeriod',2);
      g_indent := substr(g_indent,1,length(g_indent)-3);
      RETURN FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'EmpTermInPeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END EmpTermInPeriod;
-------------------------------------------------------------------------------
-- EmpTermPrePeriod                                                          --
-------------------------------------------------------------------------------
FUNCTION EmpTermPrePeriod RETURN BOOLEAN AS

BEGIN
   g_indent := g_indent||'   ';
   -- Was the employee terminated before the current period
   --
   IF dbi_ZA_ACT_END_DTE <= dbi_ZA_CUR_PRD_STRT_DTE THEN
      hr_utility.set_location(g_indent||'py_za_total_package.EmpTermPrePeriod',1);
      g_indent := substr(g_indent,1,length(g_indent)-3);
      RETURN TRUE;
   ELSE
      hr_utility.set_location(g_indent||'py_za_total_package.EmpTermPrePeriod',2);
      g_indent := substr(g_indent,1,length(g_indent)-3);
      RETURN FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'EmpTermPrePeriod: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END EmpTermPrePeriod;
-------------------------------------------------------------------------------
-- PreErnPeriod                                                              --
-------------------------------------------------------------------------------
FUNCTION PreErnPeriod RETURN BOOLEAN AS

BEGIN
   g_indent := g_indent||'   ';
   -- PTD Taxable Income
   --

   trc_TxbIncPtd :=
      ( bal_TOT_TXB_NI_PTD
      + bal_TOT_TXB_FB_PTD
      + bal_TOT_TXB_TA_PTD
      + bal_BP_PTD
      );
   -- Ptd Annual Bonus
   trc_AnnBonPtd := bal_TOT_TXB_AB_RUN;
   -- Ytd Annual Payments
   trc_AnnPymPtd := bal_TOT_TXB_AP_YTD;

   WriteHrTrace(g_indent||'trc_TxbIncPtd: '||to_char(trc_TxbIncPtd));
   WriteHrTrace(g_indent||'trc_AnnBonPtd: '||to_char(trc_AnnBonPtd));
   WriteHrTrace(g_indent||'trc_AnnPymPtd: '||to_char(trc_AnnPymPtd));

   -- Annual Type PTD Income with no Period Type PTD Income
   IF (trc_AnnBonPtd + trc_AnnPymPtd) <> 0 AND trc_TxbIncPtd <= 0 THEN
      hr_utility.set_location(g_indent||'py_za_total_package.PreErnPeriod',1);
      g_indent := substr(g_indent,1,length(g_indent)-3);
      RETURN TRUE;
   ELSE
      hr_utility.set_location(g_indent||'py_za_total_package.PreErnPeriod',2);
      g_indent := substr(g_indent,1,length(g_indent)-3);
      RETURN FALSE;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF xpt_Msg = 'No Error' THEN
       xpt_Msg := 'PreErnPeriod: '||TO_CHAR(SQLCODE);
    END IF;
       RAISE xpt_E;
END PreErnPeriod;
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
   g_indent := g_indent||'   ';
   hr_utility.set_location(g_indent||'py_za_total_package.NegPtd',1);
   -- If any period ptd income value is negative
   -- a site calc has to be done

   IF LEAST( bal_TOT_TXB_NI_PTD
           , bal_TOT_TXB_FB_PTD
           , bal_TOT_TXB_TA_PTD
           , bal_BP_PTD
           ) < 0
   THEN
      hr_utility.set_location(g_indent||'py_za_total_package.NegPtd',2);
      trc_NegPtd := TRUE;
   END IF;

   hr_utility.set_location(g_indent||'py_za_total_package.NegPtd',3);
   g_indent := substr(g_indent,1,length(g_indent)-3);
   RETURN trc_NegPtd;
EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'NegPtd: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END NegPtd;
-------------------------------------------------------------------------------
-- PeriodFactor                                                              --
-------------------------------------------------------------------------------
PROCEDURE PeriodFactor AS
   ------------
   -- Variables
   ------------
   l_tot_inc_ytd BALANCE;
   l_tot_inc_ptd BALANCE;
BEGIN
   g_indent := g_indent||'   ';
   hr_utility.set_location(g_indent||'py_za_total_package.PeriodFactor',1);

   l_tot_inc_ytd := bal_TOT_TXB_NI_YTD
                  + bal_TOT_TXB_FB_YTD
                  + bal_TOT_TXB_TA_YTD;
   l_tot_inc_ptd := bal_TOT_TXB_NI_PTD
                  + bal_TOT_TXB_FB_PTD
                  + bal_TOT_TXB_TA_PTD;

   hr_utility.set_location(g_indent||'py_za_total_package.PeriodFactor',2);

   IF dbi_ZA_TX_YR_STRT < dbi_ZA_ACT_STRT_DTE THEN
      hr_utility.set_location(g_indent||'py_za_total_package.PeriodFactor',3);

      IF l_tot_inc_ytd = l_tot_inc_ptd THEN
         hr_utility.set_location(g_indent||'py_za_total_package.PeriodFactor',4);
         -- i.e. first pay period for the person
         trc_PrdFactor :=
         ( dbi_ZA_CUR_PRD_END_DTE
         - dbi_ZA_ACT_STRT_DTE
         + 1
         )
         /
         ( dbi_ZA_CUR_PRD_END_DTE
         - dbi_ZA_CUR_PRD_STRT_DTE
         + 1
         );
      ELSE
         hr_utility.set_location(g_indent||'py_za_total_package.PeriodFactor',5);
         trc_PrdFactor := 1;
      END IF;

   ELSE
      hr_utility.set_location(g_indent||'py_za_total_package.PeriodFactor',6);
      trc_PrdFactor := 1;
   END IF;

   WriteHrTrace(g_indent||'dbi_ZA_TX_YR_STRT:       '
      ||to_char(dbi_ZA_TX_YR_STRT,'DD/MM/YYYY'));
   WriteHrTrace(g_indent||'dbi_ZA_ACT_STRT_DTE:     '
      ||to_char(dbi_ZA_ACT_STRT_DTE,'DD/MM/YYYY'));
   WriteHrTrace(g_indent||'dbi_ZA_CUR_PRD_END_DTE:  '
      ||to_char(dbi_ZA_CUR_PRD_END_DTE,'DD/MM/YYYY'));
   WriteHrTrace(g_indent||'dbi_ZA_CUR_PRD_STRT_DTE: '
      ||to_char(dbi_ZA_CUR_PRD_STRT_DTE,'DD/MM/YYYY'));
   WriteHrTrace(g_indent||'l_tot_inc_ytd:           '
      ||to_char(l_tot_inc_ytd));
   WriteHrTrace(g_indent||'l_tot_inc_ptd:           '
      ||to_char(l_tot_inc_ptd));
   g_indent := substr(g_indent,1,length(g_indent)-3);
EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'PeriodFactor: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END PeriodFactor;
-------------------------------------------------------------------------------
-- PossiblePeriodsFactor                                                     --
-------------------------------------------------------------------------------
PROCEDURE PossiblePeriodsFactor AS
BEGIN
   g_indent := g_indent||'   ';
   IF dbi_ZA_TX_YR_STRT >= dbi_ZA_ACT_STRT_DTE THEN
      hr_utility.set_location(g_indent||'py_za_total_package.PPF',1);
      trc_PosFactor := 1;
   ELSE
      IF trc_PrdFactor <> 1 THEN
         hr_utility.set_location(g_indent||'py_za_total_package.PPF',2);
         --
         trc_PosFactor :=
            dbi_ZA_DYS_IN_YR
          / ( dbi_ZA_TX_YR_END
            - dbi_ZA_CUR_PRD_STRT_DTE
            + 1
            );
      ELSE
         hr_utility.set_location(g_indent||'py_za_total_package.PPF',3);
         --
         trc_PosFactor :=
            dbi_ZA_DYS_IN_YR
          / ( dbi_ZA_TX_YR_END
            - dbi_ZA_ACT_STRT_DTE
            + 1
            );
      END IF;
   END IF;
   g_indent := substr(g_indent,1,length(g_indent)-3);
EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'PossiblePeriodsFactor: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END PossiblePeriodsFactor;
-------------------------------------------------------------------------------
-- Annualise                                                                 --
-------------------------------------------------------------------------------
FUNCTION Annualise
   (p_YtdInc IN NUMBER
   ,p_PtdInc IN NUMBER
   ) RETURN NUMBER
AS
   l_AnnFig1  BALANCE;
   l_AnnFig2  BALANCE;
   l_AnnFig3  BALANCE;
   l_AnnFig4  BALANCE;

BEGIN
   g_indent := g_indent||'   ';
   hr_utility.set_location(g_indent||'py_za_total_package.Annualise',1);
   -- 1
   l_AnnFig1 := p_PtdInc / trc_PrdFactor;
   hr_utility.set_location(g_indent||'py_za_total_package.Annualise',2);
   -- 2
   l_AnnFig2 := l_AnnFig1 * dbi_ZA_PAY_PRDS_LFT;
   hr_utility.set_location(g_indent||'py_za_total_package.Annualise',3);
   -- 3
   l_AnnFig3 := l_AnnFig2 + p_YtdInc - p_PtdInc;
   hr_utility.set_location(g_indent||'py_za_total_package.Annualise',4);
   -- 4
   l_AnnFig4 := l_AnnFig3 * trc_PosFactor;
   hr_utility.set_location(g_indent||'py_za_total_package.Annualise',5);
   --
   hr_utility.set_location(g_indent||'py_za_total_package.Annualise',6);
   --
   WriteHrTrace(g_indent||'p_PtdInc:              '||to_char(p_PtdInc           ));
   WriteHrTrace(g_indent||'trc_PrdFactor:         '||to_char(trc_PrdFactor      ));
   WriteHrTrace(g_indent||'l_AnnFig1:             '||to_char(l_AnnFig1          ));
   WriteHrTrace(g_indent||'dbi_ZA_PAY_PRDS_LFT:   '||to_char(dbi_ZA_PAY_PRDS_LFT));
   WriteHrTrace(g_indent||'l_AnnFig2:             '||to_char(l_AnnFig2          ));
   WriteHrTrace(g_indent||'p_YtdInc:              '||to_char(p_YtdInc           ));
   WriteHrTrace(g_indent||'p_PtdInc:              '||to_char(p_PtdInc           ));
   WriteHrTrace(g_indent||'l_AnnFig3:             '||to_char(l_AnnFig3          ));
   WriteHrTrace(g_indent||'trc_PosFactor:         '||to_char(trc_PosFactor      ));
   WriteHrTrace(g_indent||'l_AnnFig4:             '||to_char(l_AnnFig4          ));
   --
   g_indent := substr(g_indent,1,length(g_indent)-3);
   RETURN l_AnnFig4;
   --
EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'Annualise: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END Annualise;
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
   g_indent := g_indent||'   ';
   IF trc_AnnualisationType = 'YtdCalc' THEN
      hr_utility.set_location(g_indent||'py_za_total_package.DaysWorked',1);
      l_EndDte  := dbi_ZA_CUR_PRD_STRT_DTE - 1;
      l_StrtDte := GREATEST(dbi_ZA_ACT_STRT_DTE, dbi_ZA_TX_YR_STRT);

   ELSIF trc_AnnualisationType = 'CalCalc' THEN
      hr_utility.set_location(g_indent||'py_za_total_package.DaysWorked',2);
      l_EndDte  := dbi_ZA_TX_YR_STRT - 1;
      l_StrtDte := GREATEST(dbi_ZA_ACT_STRT_DTE,
      to_date('01/01/'||to_char(to_number(to_char(dbi_ZA_TX_YR_END,'YYYY'))-1),'DD/MM/YYYY'));

   ELSIF trc_AnnualisationType = 'SitCalc' AND trc_NegPtd THEN
      hr_utility.set_location(g_indent||'py_za_total_package.DaysWorked',3);
      l_EndDte  := LEAST(dbi_ZA_ACT_END_DTE, dbi_ZA_CUR_PRD_END_DTE);
      l_StrtDte := GREATEST(dbi_ZA_ACT_STRT_DTE, dbi_ZA_TX_YR_STRT);

   ELSIF trc_AnnualisationType = 'SitCalc' THEN
      hr_utility.set_location(g_indent||'py_za_total_package.DaysWorked',4);
      l_EndDte  := LEAST(dbi_ZA_ACT_END_DTE, dbi_ZA_TX_YR_END);
      l_StrtDte := GREATEST(dbi_ZA_ACT_STRT_DTE, dbi_ZA_TX_YR_STRT);
   END IF;

   l_DaysWorked := l_EndDte - l_StrtDte + 1;

   WriteHrTrace(g_indent||'l_EndDte:     '||to_char(l_EndDte,'DD/MM/YYYY'));
   WriteHrTrace(g_indent||'l_StrtDte:    '||to_char(l_StrtDte,'DD/MM/YYYY'));
   WriteHrTrace(g_indent||'l_DaysWorked: '||to_char(l_DaysWorked));
   g_indent := substr(g_indent,1,length(g_indent)-3);

   RETURN l_DaysWorked;

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'DaysWorked: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END DaysWorked;
-------------------------------------------------------------------------------
-- ClearGlobals                                                              --
-------------------------------------------------------------------------------
PROCEDURE ClearGlobals AS

BEGIN
   g_indent := g_indent||'   ';
   hr_utility.set_location(g_indent||'py_za_total_package.ClearGlobals',1);

   -- Trace Globals
   trc_AnnBonPtd            := 0;
   trc_AnnPymPtd            := 0;
   trc_AnnTxbPkgCmpNRFI     := 0;
   trc_AnnTxbPkgCmpNRFI_Upd := 0;
   trc_AnnTxbPkgCmpRFI      := 0;
   trc_AnnTxbPkgCmpRFI_Upd  := 0;
   trc_AnnualisationType    := 'Unknown';
   trc_NegPtd               := FALSE;
   trc_PosFactor            :=0;
   trc_PrdFactor            := 0;
   trc_PrjRFIableTotPkg     := 0;
   trc_RFIableTotPkgPTD     := 0;
   trc_RFIableTotPkgPTD_Upd := 0;
   trc_SitFactor            := 1;
   trc_TotTxbPkgCmp         := 0;
   trc_TxbIncPtd            := 0;
   trc_TxbIncYtd            := 0;
   trc_TxbPkgCmp            := 0;
   trc_TxbPkgCmpNRFI        := 0;
   trc_TxbPkgCmpNRFI_Upd    := 0;
   trc_TxbPkgCmpRFI         := 0;
   trc_TxbPkgCmpRFI_Upd     := 0;
   trc_TxbPrc               := 0;
   -- Global Exception Message
   xpt_Msg                  := 'No Error';
   g_indent := substr(g_indent,1,length(g_indent)-3);

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'ClearGlobals: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END ClearGlobals;
-------------------------------------------------------------------------------
-- split_totpkg                                                              --
--                                                                           --
-------------------------------------------------------------------------------
FUNCTION split_totpkg(
   -- Database Items
   p_FXD_PRC                  IN NUMBER
  ,p_TOT_PKG                  IN NUMBER
  ,p_ZA_ACT_END_DTE           IN DATE
  ,p_ZA_ACT_STRT_DTE          IN DATE
  ,p_ZA_ASG_TAX_RTR_RSLTS     IN VARCHAR2
  ,p_ZA_ASG_TX_RTR_PRD        IN VARCHAR2
  ,p_ZA_ASG_TX_YR             IN NUMBER
  ,p_ZA_CUR_PRD_END_DTE       IN DATE
  ,p_ZA_CUR_PRD_STRT_DTE      IN DATE
  ,p_ZA_DYS_IN_YR             IN NUMBER
  ,p_ZA_PAY_PRDS_LFT          IN NUMBER
  ,p_ZA_PAY_PRDS_PER_YR       IN NUMBER
  ,p_ZA_TX_YR_END             IN DATE
  ,p_ZA_TX_YR_STRT            IN DATE
   -- Balances
  ,p_ANN_TXB_PKG_CMP_NRFI_YTD IN NUMBER
  ,p_ANN_TXB_PKG_CMP_RFI_YTD  IN NUMBER
  ,p_ANN_TXB_PKG_CMP_YTD      IN NUMBER
  ,p_BP_PTD                   IN NUMBER
  ,p_BP_YTD                   IN NUMBER
  ,p_RFIABLE_TOT_PKG_CYTD     IN NUMBER
  ,p_RFIABLE_TOT_PKG_PTD      IN NUMBER
  ,p_RFIABLE_TOT_PKG_YTD      IN NUMBER
  ,p_TOT_TXB_AB_RUN           IN NUMBER
  ,p_TOT_TXB_AP_YTD           IN NUMBER
  ,p_TOT_TXB_FB_CYTD          IN NUMBER
  ,p_TOT_TXB_FB_PTD           IN NUMBER
  ,p_TOT_TXB_FB_YTD           IN NUMBER
  ,p_TOT_TXB_NI_CYTD          IN NUMBER
  ,p_TOT_TXB_NI_PTD           IN NUMBER
  ,p_TOT_TXB_NI_YTD           IN NUMBER
  ,p_TOT_TXB_TA_CYTD          IN NUMBER
  ,p_TOT_TXB_TA_PTD           IN NUMBER
  ,p_TOT_TXB_TA_YTD           IN NUMBER
  ,p_TXB_PKG_CMP_CYTD         IN NUMBER
  ,p_TXB_PKG_CMP_NRFI_YTD     IN NUMBER
  ,p_TXB_PKG_CMP_PTD          IN NUMBER
  ,p_TXB_PKG_CMP_RFI_YTD      IN NUMBER
  ,p_TXB_PKG_CMP_YTD          IN NUMBER
   -- Out Parameters
  ,p_RFIableTotPkgPTD_Upd     OUT NOCOPY NUMBER
  ,p_AnnTxbPkgCmpRFI_Upd      OUT NOCOPY NUMBER
  ,p_AnnTxbPkgCmpNRFI_Upd     OUT NOCOPY NUMBER
  ,p_TxbPkgCmpRFI_Upd         OUT NOCOPY NUMBER
  ,p_TxbPkgCmpNRFI_Upd        OUT NOCOPY NUMBER
  ) RETURN NUMBER
AS
-- Variables
--
   l_Dum NUMBER := 1;

-------------------------------------------------------------------------------
BEGIN--                           MAIN                                       --
-------------------------------------------------------------------------------
-- Set hr_utility globals if debugging
--
   --g_HrTraceEnabled  := TRUE;
   --g_HrTracePipeName := 'ZATOTPKG';

-- Call hr_utility start procedure
   StartHrTrace;

   WriteHrTrace(' ');
   WriteHrTrace(' ');
   WriteHrTrace(' ');
   WriteHrTrace('------------------------------------------------------------');
   WriteHrTrace('-- Start of Total Package Trace File');
   WriteHrTrace('------------------------------------------------------------');
   WriteHrTrace(' ');
   WriteHrTrace('-- Values passed in');
   WriteHrTrace('-- Database Items');
   WriteHrTrace('p_FXD_PRC                  '||to_char(p_FXD_PRC                         ));
   WriteHrTrace('p_TOT_PKG                  '||to_char(p_TOT_PKG                         ));
   WriteHrTrace('p_ZA_ACT_END_DTE           '||to_char(p_ZA_ACT_END_DTE     ,'DD/MM/YYYY'));
   WriteHrTrace('p_ZA_ACT_STRT_DTE          '||to_char(p_ZA_ACT_STRT_DTE    ,'DD/MM/YYYY'));
   WriteHrTrace('p_ZA_ASG_TAX_RTR_RSLTS     '||        p_ZA_ASG_TAX_RTR_RSLTS             );
   WriteHrTrace('p_ZA_ASG_TX_RTR_PRD        '||        p_ZA_ASG_TX_RTR_PRD                );
   WriteHrTrace('p_ZA_ASG_TX_YR             '||to_char(p_ZA_ASG_TX_YR                    ));
   WriteHrTrace('p_ZA_CUR_PRD_END_DTE       '||to_char(p_ZA_CUR_PRD_END_DTE ,'DD/MM/YYYY'));
   WriteHrTrace('p_ZA_CUR_PRD_STRT_DTE      '||to_char(p_ZA_CUR_PRD_STRT_DTE,'DD/MM/YYYY'));
   WriteHrTrace('p_ZA_DYS_IN_YR             '||to_char(p_ZA_DYS_IN_YR                    ));
   WriteHrTrace('p_ZA_PAY_PRDS_LFT          '||to_char(p_ZA_PAY_PRDS_LFT                 ));
   WriteHrTrace('p_ZA_PAY_PRDS_PER_YR       '||to_char(p_ZA_PAY_PRDS_PER_YR              ));
   WriteHrTrace('p_ZA_TX_YR_END             '||to_char(p_ZA_TX_YR_END       ,'DD/MM/YYYY'));
   WriteHrTrace('p_ZA_TX_YR_STRT            '||to_char(p_ZA_TX_YR_STRT      ,'DD/MM/YYYY'));
   WriteHrTrace('-- Balances');
   WriteHrTrace('p_ANN_TXB_PKG_CMP_NRFI_YTD '||to_char(p_ANN_TXB_PKG_CMP_NRFI_YTD        ));
   WriteHrTrace('p_ANN_TXB_PKG_CMP_RFI_YTD  '||to_char(p_ANN_TXB_PKG_CMP_RFI_YTD         ));
   WriteHrTrace('p_ANN_TXB_PKG_CMP_YTD      '||to_char(p_ANN_TXB_PKG_CMP_YTD             ));
   WriteHrTrace('p_BP_PTD                   '||to_char(p_BP_PTD                          ));
   WriteHrTrace('p_BP_YTD                   '||to_char(p_BP_YTD                          ));
   WriteHrTrace('p_RFIABLE_TOT_PKG_CYTD     '||to_char(p_RFIABLE_TOT_PKG_CYTD            ));
   WriteHrTrace('p_RFIABLE_TOT_PKG_PTD      '||to_char(p_RFIABLE_TOT_PKG_PTD             ));
   WriteHrTrace('p_RFIABLE_TOT_PKG_YTD      '||to_char(p_RFIABLE_TOT_PKG_YTD             ));
   WriteHrTrace('p_TOT_TXB_AB_RUN           '||to_char(p_TOT_TXB_AB_RUN                  ));
   WriteHrTrace('p_TOT_TXB_AP_YTD           '||to_char(p_TOT_TXB_AP_YTD                  ));
   WriteHrTrace('p_TOT_TXB_FB_CYTD          '||to_char(p_TOT_TXB_FB_CYTD                 ));
   WriteHrTrace('p_TOT_TXB_FB_PTD           '||to_char(p_TOT_TXB_FB_PTD                  ));
   WriteHrTrace('p_TOT_TXB_FB_YTD           '||to_char(p_TOT_TXB_FB_YTD                  ));
   WriteHrTrace('p_TOT_TXB_NI_CYTD          '||to_char(p_TOT_TXB_NI_CYTD                 ));
   WriteHrTrace('p_TOT_TXB_NI_PTD           '||to_char(p_TOT_TXB_NI_PTD                  ));
   WriteHrTrace('p_TOT_TXB_NI_YTD           '||to_char(p_TOT_TXB_NI_YTD                  ));
   WriteHrTrace('p_TOT_TXB_TA_CYTD          '||to_char(p_TOT_TXB_TA_CYTD                 ));
   WriteHrTrace('p_TOT_TXB_TA_PTD           '||to_char(p_TOT_TXB_TA_PTD                  ));
   WriteHrTrace('p_TOT_TXB_TA_YTD           '||to_char(p_TOT_TXB_TA_YTD                  ));
   WriteHrTrace('p_TXB_PKG_CMP_CYTD         '||to_char(p_TXB_PKG_CMP_CYTD                ));
   WriteHrTrace('p_TXB_PKG_CMP_NRFI_YTD     '||to_char(p_TXB_PKG_CMP_NRFI_YTD            ));
   WriteHrTrace('p_TXB_PKG_CMP_PTD          '||to_char(p_TXB_PKG_CMP_PTD                 ));
   WriteHrTrace('p_TXB_PKG_CMP_RFI_YTD      '||to_char(p_TXB_PKG_CMP_RFI_YTD             ));
   WriteHrTrace('p_TXB_PKG_CMP_YTD          '||to_char(p_TXB_PKG_CMP_YTD                 ));
   WriteHrTrace('-- Out Parameters');
   --
   hr_utility.set_location('py_za_total_package.split_totpkg',1);
-------------------------------------------------------------------------------
-- Set variables
-------------------------------------------------------------------------------
   -- Database Items
   dbi_FXD_PRC                  := p_FXD_PRC;
   dbi_TOT_PKG                  := p_TOT_PKG;
   dbi_ZA_ACT_END_DTE           := p_ZA_ACT_END_DTE;
   dbi_ZA_ACT_STRT_DTE          := p_ZA_ACT_STRT_DTE;
   dbi_ZA_ASG_TAX_RTR_RSLTS     := p_ZA_ASG_TAX_RTR_RSLTS;
   dbi_ZA_ASG_TX_RTR_PRD        := p_ZA_ASG_TX_RTR_PRD;
   dbi_ZA_ASG_TX_YR             := p_ZA_ASG_TX_YR;
   dbi_ZA_CUR_PRD_END_DTE       := p_ZA_CUR_PRD_END_DTE;
   dbi_ZA_CUR_PRD_STRT_DTE      := p_ZA_CUR_PRD_STRT_DTE;
   dbi_ZA_DYS_IN_YR             := p_ZA_DYS_IN_YR;
   dbi_ZA_PAY_PRDS_LFT          := p_ZA_PAY_PRDS_LFT;
   dbi_ZA_PAY_PRDS_PER_YR       := p_ZA_PAY_PRDS_PER_YR;
   dbi_ZA_TX_YR_END             := p_ZA_TX_YR_END;
   dbi_ZA_TX_YR_STRT            := p_ZA_TX_YR_STRT;
   -------------------------------------------------------------------------------
   -- Balances
   -------------------------------------------------------------------------------
   bal_ANN_TXB_PKG_CMP_NRFI_YTD := p_ANN_TXB_PKG_CMP_NRFI_YTD;
   bal_ANN_TXB_PKG_CMP_RFI_YTD  := p_ANN_TXB_PKG_CMP_RFI_YTD;
   bal_ANN_TXB_PKG_CMP_YTD      := p_ANN_TXB_PKG_CMP_YTD;
   bal_BP_PTD                   := p_BP_PTD;
   bal_BP_YTD                   := p_BP_YTD;
   bal_RFIABLE_TOT_PKG_CYTD     := p_RFIABLE_TOT_PKG_CYTD;
   bal_RFIABLE_TOT_PKG_PTD      := p_RFIABLE_TOT_PKG_PTD;
   bal_RFIABLE_TOT_PKG_YTD      := p_RFIABLE_TOT_PKG_YTD;
   bal_TOT_TXB_AB_RUN           := p_TOT_TXB_AB_RUN;
   bal_TOT_TXB_AP_YTD           := p_TOT_TXB_AP_YTD;
   bal_TOT_TXB_FB_CYTD          := p_TOT_TXB_FB_CYTD;
   bal_TOT_TXB_FB_PTD           := p_TOT_TXB_FB_PTD;
   bal_TOT_TXB_FB_YTD           := p_TOT_TXB_FB_YTD;
   bal_TOT_TXB_NI_CYTD          := p_TOT_TXB_NI_CYTD;
   bal_TOT_TXB_NI_PTD           := p_TOT_TXB_NI_PTD;
   bal_TOT_TXB_NI_YTD           := p_TOT_TXB_NI_YTD;
   bal_TOT_TXB_TA_CYTD          := p_TOT_TXB_TA_CYTD;
   bal_TOT_TXB_TA_PTD           := p_TOT_TXB_TA_PTD;
   bal_TOT_TXB_TA_YTD           := p_TOT_TXB_TA_YTD;
   bal_TXB_PKG_CMP_CYTD         := p_TXB_PKG_CMP_CYTD;
   bal_TXB_PKG_CMP_NRFI_YTD     := p_TXB_PKG_CMP_NRFI_YTD;
   bal_TXB_PKG_CMP_PTD          := p_TXB_PKG_CMP_PTD;
   bal_TXB_PKG_CMP_RFI_YTD      := p_TXB_PKG_CMP_RFI_YTD;
   bal_TXB_PKG_CMP_YTD          := p_TXB_PKG_CMP_YTD;


   hr_utility.set_location('py_za_total_package.split_totpkg',2);

-------------------------------------------------------------------------------
-- Calculate PTD RFIable Total Package value
-------------------------------------------------------------------------------
   trc_RFIableTotPkgPTD := dbi_TOT_PKG * (dbi_FXD_PRC / 100) / dbi_ZA_PAY_PRDS_PER_YR;
   hr_utility.set_location('py_za_total_package.split_totpkg',3);
-- Calculate the update value
--
   trc_RFIableTotPkgPTD_Upd := trc_RFIableTotPkgPTD - bal_RFIABLE_TOT_PKG_PTD;

-------------------------------------------------------------------------------
-- Split Taxable Package Components
-------------------------------------------------------------------------------
-- Check if there is taxable income in the package
--
   trc_TotTxbPkgCmp := bal_TXB_PKG_CMP_YTD + bal_ANN_TXB_PKG_CMP_YTD;

   IF trc_TotTxbPkgCmp <> 0 THEN
      hr_utility.set_location('py_za_total_package.split_totpkg',4);
      -- Annualisation Check
      --
      IF LatePayPeriod THEN
         hr_utility.set_location('py_za_total_package.split_totpkg',5);
         trc_AnnualisationType := 'LteCalc';
      -- Is this a SITE Period?
      ELSIF EmpTermPrePeriod THEN
         hr_utility.set_location('py_za_total_package.split_totpkg',6);
         trc_AnnualisationType := 'SitCalc';
      ELSIF LstPeriod OR EmpTermInPeriod THEN
         hr_utility.set_location('py_za_total_package.split_totpkg',7);
         IF PreErnPeriod THEN
            hr_utility.set_location('py_za_total_package.split_totpkg',8);
            trc_AnnualisationType := 'YtdCalc';
         ELSE
            hr_utility.set_location('py_za_total_package.split_totpkg',9);
            trc_AnnualisationType := 'SitCalc';
         END IF;
      ElSE
         hr_utility.set_location('py_za_total_package.split_totpkg',10);
         -- The employee has NOT been terminated!
         IF PreErnPeriod THEN
            hr_utility.set_location('py_za_total_package.split_totpkg',11);
            trc_AnnualisationType := 'YtdCalc';
       --Bug 4346955 bug 5148830
      /*   ELSIF dbi_ZA_ASG_TX_RTR_PRD = 'Y' THEN
            hr_utility.set_location('py_za_total_package.split_totpkg',12);
            IF dbi_ZA_ASG_TAX_RTR_RSLTS = 'Y' THEN
               hr_utility.set_location('py_za_total_package.split_totpkg',13);
               trc_AnnualisationType := 'SitCalc';
            ELSIF NegPtd THEN
               hr_utility.set_location('py_za_total_package.split_totpkg',14);
               trc_AnnualisationType := 'SitCalc';
            ELSE
               hr_utility.set_location('py_za_total_package.split_totpkg',15);
               trc_AnnualisationType := 'NorCalc';
            END IF; */
         ELSIF NegPtd THEN
            hr_utility.set_location('py_za_total_package.split_totpkg',16);
            trc_AnnualisationType := 'SitCalc';
         ELSE
            hr_utility.set_location('py_za_total_package.split_totpkg',17);
            trc_AnnualisationType := 'NorCalc';
         END IF;
      END IF;
   --
   -- Pre-Earnings Check
   --
      IF trc_AnnualisationType = 'YtdCalc' THEN
         hr_utility.set_location('py_za_total_package.split_totpkg',18);
         -- Ytd Taxable Income
         --
         trc_TxbIncYtd := ( bal_TOT_TXB_NI_YTD
                          + bal_TOT_TXB_FB_YTD
                          + bal_TOT_TXB_TA_YTD
                          + bal_BP_YTD
                          );
         -- If the Ytd Taxable Income = 0, execute the CalCalc
         --
         IF trc_TxbIncYtd = 0 THEN
            hr_utility.set_location('py_za_total_package.split_totpkg',19);
            -- Calendar Ytd Taxable Income
            --
            trc_TxbIncYtd := ( bal_TOT_TXB_NI_CYTD
                             + bal_TOT_TXB_FB_CYTD
                             + bal_TOT_TXB_TA_CYTD );
            -- If there is no Income Execute the Base calculation
            --
            IF trc_TxbIncYtd = 0 THEN
               hr_utility.set_location('py_za_total_package.split_totpkg',20);
               trc_AnnualisationType := 'BasCalc';
            ELSE
               hr_utility.set_location('py_za_total_package.split_totpkg',21);
               trc_AnnualisationType := 'CalCalc';
            END IF;
         END IF;

      END IF;

   -- Set Factors
   --
      IF trc_AnnualisationType IN ('SitCalc','YtdCalc','CalCalc') THEN
         hr_utility.set_location('py_za_total_package.split_totpkg',22);
         trc_SitFactor := dbi_ZA_DYS_IN_YR / DaysWorked;
      END IF;

      IF trc_AnnualisationType = 'NorCalc' THEN
         hr_utility.set_location('py_za_total_package.split_totpkg',23);
         PeriodFactor;
         PossiblePeriodsFactor;
      END IF;

   -- Annualise RFIable Total Package
--      trc_PrjRFIableTotPkg := ( trc_RFIableTotPkgPTD
--                              * dbi_ZA_PAY_PRDS_LFT )
--                              + bal_RFIABLE_TOT_PKG_YTD
--                              - bal_RFIABLE_TOT_PKG_PTD;
      -------------------------------------------------------------------------
      IF trc_AnnualisationType = 'NorCalc' THEN                       --
      -------------------------------------------------------------------------
      -- Annualise RFIable Total Package
         trc_PrjRFIableTotPkg := Annualise(p_YtdInc => bal_RFIABLE_TOT_PKG_YTD
                                                     + trc_RFIableTotPkgPTD_Upd
                                          ,p_PtdInc => bal_RFIABLE_TOT_PKG_PTD
                                                     + trc_RFIableTotPkgPTD_Upd
                                          );
      -- Annualise TxbPkgCmps
         trc_TxbPkgCmp := Annualise(p_YtdInc => bal_TXB_PKG_CMP_YTD
                                   ,p_PtdInc => bal_TXB_PKG_CMP_PTD
                                   );
         hr_utility.set_location('py_za_total_package.split_totpkg',24);
         --
         trc_TotTxbPkgCmp := trc_TxbPkgCmp + bal_ANN_TXB_PKG_CMP_YTD;
         -- Calculate Split %
         --
         trc_TxbPrc := least((trc_PrjRFIableTotPkg / trc_TotTxbPkgCmp),1);

      -- Calculate Split Values
         -- Periodic
         hr_utility.set_location('py_za_total_package.split_totpkg',25);
         trc_TxbPkgCmpRFI  := bal_TXB_PKG_CMP_YTD * trc_TxbPrc;
         trc_TxbPkgCmpNRFI := bal_TXB_PKG_CMP_YTD - trc_TxbPkgCmpRFI;
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',26);
         trc_AnnTxbPkgCmpRFI  := bal_ANN_TXB_PKG_CMP_YTD * trc_TxbPrc;
         trc_AnnTxbPkgCmpNRFI := bal_ANN_TXB_PKG_CMP_YTD - trc_AnnTxbPkgCmpRFI;

      -- Calculate Update Values
         -- Periodic
         hr_utility.set_location('py_za_total_package.split_totpkg',27);
         trc_TxbPkgCmpRFI_Upd  := trc_TxbPkgCmpRFI - bal_TXB_PKG_CMP_RFI_YTD;
         trc_TxbPkgCmpNRFI_Upd := trc_TxbPkgCmpNRFI - bal_TXB_PKG_CMP_NRFI_YTD;
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',28);
         trc_AnnTxbPkgCmpRFI_Upd  := trc_AnnTxbPkgCmpRFI - bal_ANN_TXB_PKG_CMP_RFI_YTD;
         trc_AnnTxbPkgCmpNRFI_Upd := trc_AnnTxbPkgCmpNRFI - bal_ANN_TXB_PKG_CMP_NRFI_YTD;

         hr_utility.set_location('py_za_total_package.split_totpkg',29);

      -------------------------------------------------------------------------
      ELSIF trc_AnnualisationType = 'SitCalc' THEN                    --
      -------------------------------------------------------------------------
      -- Annualise RFIable Total Package
      --
         trc_PrjRFIableTotPkg :=
           ( bal_RFIABLE_TOT_PKG_YTD + trc_RFIableTotPkgPTD_Upd ) * trc_SitFactor;
      --
      -- Annualise TxbPkgCmps
      --
         trc_TxbPkgCmp    := bal_TXB_PKG_CMP_YTD * trc_SitFactor;
         trc_TotTxbPkgCmp := trc_TxbPkgCmp + bal_ANN_TXB_PKG_CMP_YTD;
      --
      -- Calculate Split %
      --
         trc_TxbPrc := least((trc_PrjRFIableTotPkg / trc_TotTxbPkgCmp),1);
      -- Calculate Split Values
      --
         --
         -- Periodic
         --
         hr_utility.set_location('py_za_total_package.split_totpkg',30);
         trc_TxbPkgCmpRFI  := bal_TXB_PKG_CMP_YTD * trc_TxbPrc;
         trc_TxbPkgCmpNRFI := bal_TXB_PKG_CMP_YTD - trc_TxbPkgCmpRFI;
         --
         -- Annual
         --
         hr_utility.set_location('py_za_total_package.split_totpkg',31);
         trc_AnnTxbPkgCmpRFI  := bal_ANN_TXB_PKG_CMP_YTD * trc_TxbPrc;
         trc_AnnTxbPkgCmpNRFI := bal_ANN_TXB_PKG_CMP_YTD - trc_AnnTxbPkgCmpRFI;
      --
      -- Calculate Update Values
      --
         --
         -- Periodic
         --
         hr_utility.set_location('py_za_total_package.split_totpkg',32);
         trc_TxbPkgCmpRFI_Upd  := trc_TxbPkgCmpRFI - bal_TXB_PKG_CMP_RFI_YTD;
         trc_TxbPkgCmpNRFI_Upd := trc_TxbPkgCmpNRFI - bal_TXB_PKG_CMP_NRFI_YTD;
         --
         -- Annual
         --
         hr_utility.set_location('py_za_total_package.split_totpkg',33);
         trc_AnnTxbPkgCmpRFI_Upd  := trc_AnnTxbPkgCmpRFI - bal_ANN_TXB_PKG_CMP_RFI_YTD;
         trc_AnnTxbPkgCmpNRFI_Upd := trc_AnnTxbPkgCmpNRFI - bal_ANN_TXB_PKG_CMP_NRFI_YTD;
         --
         hr_utility.set_location('py_za_total_package.split_totpkg',34);
         --
      -------------------------------------------------------------------------
      ELSIF trc_AnnualisationType = 'YtdCalc' THEN                    --
      -------------------------------------------------------------------------
      -- Annualise RFIable Total Package
      --
         trc_PrjRFIableTotPkg := bal_RFIABLE_TOT_PKG_YTD * trc_SitFactor;
      -- Annualise TxbPkgCmps
         trc_TxbPkgCmp    := bal_TXB_PKG_CMP_YTD * trc_SitFactor;
         trc_TotTxbPkgCmp := trc_TxbPkgCmp + bal_ANN_TXB_PKG_CMP_YTD;

      -- Calculate Split %
         trc_TxbPrc := least((trc_PrjRFIableTotPkg / trc_TotTxbPkgCmp),1);

      -- Calculate Split Values
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',35);
         trc_AnnTxbPkgCmpRFI  := bal_ANN_TXB_PKG_CMP_YTD * trc_TxbPrc;
         trc_AnnTxbPkgCmpNRFI := bal_ANN_TXB_PKG_CMP_YTD - trc_AnnTxbPkgCmpRFI;

      -- Calculate Update Values
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',36);
         trc_AnnTxbPkgCmpRFI_Upd  := trc_AnnTxbPkgCmpRFI - bal_ANN_TXB_PKG_CMP_RFI_YTD;
         trc_AnnTxbPkgCmpNRFI_Upd := trc_AnnTxbPkgCmpNRFI - bal_ANN_TXB_PKG_CMP_NRFI_YTD;

         hr_utility.set_location('py_za_total_package.split_totpkg',37);

      -------------------------------------------------------------------------
      ELSIF trc_AnnualisationType = 'CalCalc' THEN                    --
      -------------------------------------------------------------------------
      -- Annualise RFIable Total Package
      --
         trc_PrjRFIableTotPkg := bal_RFIABLE_TOT_PKG_CYTD * trc_SitFactor;
      -- Annualise TxbPkgCmps
         trc_TxbPkgCmp    := bal_TXB_PKG_CMP_CYTD * trc_SitFactor;
         trc_TotTxbPkgCmp := trc_TxbPkgCmp + bal_ANN_TXB_PKG_CMP_YTD;

      -- Calculate Split %
         trc_TxbPrc := least((trc_PrjRFIableTotPkg / trc_TotTxbPkgCmp),1);

      -- Calculate Split Values
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',38);
         trc_AnnTxbPkgCmpRFI  := bal_ANN_TXB_PKG_CMP_YTD * trc_TxbPrc;
         trc_AnnTxbPkgCmpNRFI := bal_ANN_TXB_PKG_CMP_YTD - trc_AnnTxbPkgCmpRFI;

      -- Calculate Update Values
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',39);
         trc_AnnTxbPkgCmpRFI_Upd  := trc_AnnTxbPkgCmpRFI - bal_ANN_TXB_PKG_CMP_RFI_YTD;
         trc_AnnTxbPkgCmpNRFI_Upd := trc_AnnTxbPkgCmpNRFI - bal_ANN_TXB_PKG_CMP_NRFI_YTD;

         hr_utility.set_location('py_za_total_package.split_totpkg',40);

      -------------------------------------------------------------------------
      ELSIF trc_AnnualisationType = 'BasCalc' THEN                    --
      -------------------------------------------------------------------------
      -- Annualise RFIable Total Package
      --
         trc_PrjRFIableTotPkg := trc_RFIableTotPkgPTD * dbi_ZA_PAY_PRDS_PER_YR;
      -- Annualise TxbPkgCmps
         trc_TxbPkgCmp    := bal_ANN_TXB_PKG_CMP_YTD * dbi_ZA_PAY_PRDS_PER_YR;
         trc_TotTxbPkgCmp := trc_TxbPkgCmp + bal_ANN_TXB_PKG_CMP_YTD;

      -- Calculate Split %
         trc_TxbPrc := least((trc_PrjRFIableTotPkg / trc_TotTxbPkgCmp),1);

      -- Calculate Split Values
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',41);
         trc_AnnTxbPkgCmpRFI  := bal_ANN_TXB_PKG_CMP_YTD * trc_TxbPrc;
         trc_AnnTxbPkgCmpNRFI := bal_ANN_TXB_PKG_CMP_YTD - trc_AnnTxbPkgCmpRFI;

      -- Calculate Update Values
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',42);
         trc_AnnTxbPkgCmpRFI_Upd  := trc_AnnTxbPkgCmpRFI - bal_ANN_TXB_PKG_CMP_RFI_YTD;
         trc_AnnTxbPkgCmpNRFI_Upd := trc_AnnTxbPkgCmpNRFI - bal_ANN_TXB_PKG_CMP_NRFI_YTD;

         hr_utility.set_location('py_za_total_package.split_totpkg',43);

      -------------------------------------------------------------------------
      ELSIF trc_AnnualisationType = 'LteCalc' THEN                    --
      -------------------------------------------------------------------------
      -- DO NOT Annualise RFIable Total Package
      -- Override trc_PrjRFIableTotPkg
         trc_PrjRFIableTotPkg := bal_RFIABLE_TOT_PKG_YTD;

      -- Annualise TxbPkgCmps
         trc_TxbPkgCmp := bal_TXB_PKG_CMP_YTD;
         trc_TotTxbPkgCmp := trc_TxbPkgCmp + bal_ANN_TXB_PKG_CMP_YTD;

      -- Calculate Split %
         trc_TxbPrc := least((trc_PrjRFIableTotPkg / trc_TotTxbPkgCmp),1);

      -- Calculate Split Values
         -- Periodic
         hr_utility.set_location('py_za_total_package.split_totpkg',44);
         trc_TxbPkgCmpRFI  := bal_TXB_PKG_CMP_YTD * trc_TxbPrc;
         trc_TxbPkgCmpNRFI := bal_TXB_PKG_CMP_YTD - trc_TxbPkgCmpRFI;
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',45);
         trc_AnnTxbPkgCmpRFI  := bal_ANN_TXB_PKG_CMP_YTD * trc_TxbPrc;
         trc_AnnTxbPkgCmpNRFI := bal_ANN_TXB_PKG_CMP_YTD - trc_AnnTxbPkgCmpRFI;

      -- Calculate Update Values
         -- Periodic
         hr_utility.set_location('py_za_total_package.split_totpkg',46);
         trc_TxbPkgCmpRFI_Upd  := trc_TxbPkgCmpRFI - bal_TXB_PKG_CMP_RFI_YTD;
         trc_TxbPkgCmpNRFI_Upd := trc_TxbPkgCmpNRFI - bal_TXB_PKG_CMP_NRFI_YTD;
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',47);
         trc_AnnTxbPkgCmpRFI_Upd  := trc_AnnTxbPkgCmpRFI - bal_ANN_TXB_PKG_CMP_RFI_YTD;
         trc_AnnTxbPkgCmpNRFI_Upd := trc_AnnTxbPkgCmpNRFI - bal_ANN_TXB_PKG_CMP_NRFI_YTD;

         hr_utility.set_location('py_za_total_package.split_totpkg',48);

      -------------------------------------------------------------------------
      END IF;--                End CalcTyp Check
      -------------------------------------------------------------------------
   ELSE
      -- There exist no taxable package component values
      -- Calculate PTD update values
      --
         -- Periodic
         hr_utility.set_location('py_za_total_package.split_totpkg',49);
         trc_TxbPkgCmpRFI_Upd  := trc_TxbPkgCmpRFI - bal_TXB_PKG_CMP_RFI_YTD;
         trc_TxbPkgCmpNRFI_Upd := trc_TxbPkgCmpNRFI - bal_TXB_PKG_CMP_NRFI_YTD;
         -- Annual
         hr_utility.set_location('py_za_total_package.split_totpkg',50);
         trc_AnnTxbPkgCmpRFI_Upd  := trc_AnnTxbPkgCmpRFI - bal_ANN_TXB_PKG_CMP_RFI_YTD;
         trc_AnnTxbPkgCmpNRFI_Upd := trc_AnnTxbPkgCmpNRFI - bal_ANN_TXB_PKG_CMP_NRFI_YTD;

         hr_utility.set_location('py_za_total_package.split_totpkg',51);

   END IF;

   -- Set output parameters
   --
      p_RFIableTotPkgPTD_Upd := trc_RFIableTotPkgPTD_Upd;
      p_AnnTxbPkgCmpRFI_Upd  := trc_AnnTxbPkgCmpRFI_Upd;
      p_AnnTxbPkgCmpNRFI_Upd := trc_AnnTxbPkgCmpNRFI_Upd;
      p_TxbPkgCmpRFI_Upd     := trc_TxbPkgCmpRFI_Upd;
      p_TxbPkgCmpNRFI_Upd    := trc_TxbPkgCmpNRFI_Upd;

   hr_utility.set_location('py_za_total_package.split_totpkg',52);

   WriteHrTrace('-- Trace Variables');
   WriteHrTrace('trc_AnnBonPtd              '||to_char(trc_AnnBonPtd            ));
   WriteHrTrace('trc_AnnPymPtd              '||to_char(trc_AnnPymPtd            ));
   WriteHrTrace('trc_AnnTxbPkgCmpNRFI       '||to_char(trc_AnnTxbPkgCmpNRFI     ));
   WriteHrTrace('trc_AnnTxbPkgCmpNRFI_Upd   '||to_char(trc_AnnTxbPkgCmpNRFI_Upd ));
   WriteHrTrace('trc_AnnTxbPkgCmpRFI        '||to_char(trc_AnnTxbPkgCmpRFI      ));
   WriteHrTrace('trc_AnnTxbPkgCmpRFI_Upd    '||to_char(trc_AnnTxbPkgCmpRFI_Upd  ));
   WriteHrTrace('trc_AnnualisationType      '||to_char(trc_AnnualisationType    ));
   WriteHrTrace('trc_PosFactor              '||to_char(trc_PosFactor            ));
   WriteHrTrace('trc_PrdFactor              '||to_char(trc_PrdFactor            ));
   WriteHrTrace('trc_PrjRFIableTotPkg       '||to_char(trc_PrjRFIableTotPkg     ));
   WriteHrTrace('trc_RFIableTotPkgPTD       '||to_char(trc_RFIableTotPkgPTD     ));
   WriteHrTrace('trc_RFIableTotPkgPTD_Upd   '||to_char(trc_RFIableTotPkgPTD_Upd ));
   WriteHrTrace('trc_SitFactor              '||to_char(trc_SitFactor            ));
   WriteHrTrace('trc_TotTxbPkgCmp           '||to_char(trc_TotTxbPkgCmp         ));
   WriteHrTrace('trc_TxbIncPtd              '||to_char(trc_TxbIncPtd            ));
   WriteHrTrace('trc_TxbIncYtd              '||to_char(trc_TxbIncYtd            ));
   WriteHrTrace('trc_TxbPkgCmp              '||to_char(trc_TxbPkgCmp            ));
   WriteHrTrace('trc_TxbPkgCmpNRFI          '||to_char(trc_TxbPkgCmpNRFI        ));
   WriteHrTrace('trc_TxbPkgCmpNRFI_Upd      '||to_char(trc_TxbPkgCmpNRFI_Upd    ));
   WriteHrTrace('trc_TxbPkgCmpRFI           '||to_char(trc_TxbPkgCmpRFI         ));
   WriteHrTrace('trc_TxbPkgCmpRFI_Upd       '||to_char(trc_TxbPkgCmpRFI_Upd     ));
   WriteHrTrace('trc_TxbPrc                 '||to_char(trc_TxbPrc               ));

   hr_utility.set_location('py_za_total_package.split_totpkg',53);

   ClearGlobals;

-- End off Trace File
--
   WriteHrTrace('   ');
   WriteHrTrace('------------------------------------------------------------');
   WriteHrTrace('--             End of Total Package Trace File            --');
   WriteHrTrace('------------------------------------------------------------');
   WriteHrTrace('                             --                             ');

-- Stop Trace File
--
   StopHrTrace;

  RETURN l_Dum;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_total_package.split_totpkg',54);
      WriteHrTrace('Sql error code: '||TO_CHAR(SQLCODE));
      WriteHrTrace('Sql error msg: '||SUBSTR(SQLERRM(SQLCODE), 1, 100));
      StopHrTrace;
      hr_utility.set_message(801, 'py_za_total_package: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;

  END split_totpkg;

END py_za_total_package;


/
