--------------------------------------------------------
--  DDL for Package Body PY_ZA_TX_01032002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_TX_01032002" AS
/* $Header: pyzat004.pkb 120.0 2005/05/29 10:29:49 appldev noship $ */
/* Copyright (c) Oracle Corporation 1999. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation Tax Module

   NAME
      py_za_tx_01032002.pkb

   DESCRIPTION
      This is the main tax package as used in the ZA Localisation Tax Module.
      The public functions in this package are not for client use and is
      only referenced by the tax formulae in the Application.

   PUBLIC FUNCTIONS
      Descriptions in package header
      ZaTxOvr_01032000
      ZaTxGlb_01032000
      ZaTxDbi_01032000
      ZaTxBal1_01032000
      ZaTxBal2_01032000
      ZaTxBal3_01032000
      ZaTx_01032000

   PRIVATE FUNCTIONS
      <none>


   PRIVATE PROCEDURES
      WrtHrTrc
         Wrapper procedure for py_za_tx_utl_01032002.WriteHrTrace
      NetTxbIncCalc
         Procedure to calculate a Net Taxable Income figure used
         to properly calculate the Skills Development Levy
      LteCalc
         A main tax calculation.
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
      Person      Date               Version   Comments
      ---------   ----------------   -------   --------------------------------
      A. Mahanty  14/04/2005         115.15    Bug 3491357 : BRA Enhancement
                                               Balance Values retrieval modified.
      J.N. Louw   02/07/2003         115.14    Bug 3011568
      J.N. Louw   19/06/2003         115.13    Bug 3013638
      J.N. Louw   19/06/2003         115.12    Bug 3013801
      J.N. Louw   10/06/2003         115.11    Bug 2998778
      J.N. Louw   12/02/2003         115.10    Bug 2659613
      J.N. Louw   22/03/2002         115.8     Bug 2224332
                                               Directors Remuneration
      J.N. Louw   22/03/2002         115.7     Bug 2274662
                                               Personal Service Trusts
      J.N. Louw   12/10/2001         115.6     Fixed Abatements calculation
                                               in NetTxbIncCalc
                                               Fixed trc_TotLib[CatCode] Cascade
                                               Figure calculation
      J.N. Louw   27/09/2001         115.5     Added bal_ANN_PF_CYTD
      J.N. Louw   04/09/2001         115.4     NorCalc.TrvAll Ptd summation
                                               added
      J.N. Louw   04/09/2001         115.3     Added WrtHrTrc wrapper
      J.N. Louw   04/09/2001         115.2     Added Abatement Functionality to
                                               the BasCalc calculation
      J.N. Louw   31-08-2001         115.1     Corected Spool File
      J.N. Louw   29-08-2001         115.0     Next Version of Main ZA Tax
                                               Package.
                                               For detail history see
                                               py_za_tx_01082000
*/

-------------------------------------------------------------------------------
--                               PACKAGE BODY                                --
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- WrtHrTrc
-- Wrapper for py_za_tx_utl_01032002.WriteHrTrace
-------------------------------------------------------------------------------
PROCEDURE WrtHrTrc(
   p_Buf IN VARCHAR2
   )
AS

BEGIN
   py_za_tx_utl_01032002.WriteHrTrace(p_Buf);
END WrtHrTrc;

-------------------------------------------------------------------------------
-- NetTxbIncCalc
-- Calculates the net taxable income value for the calendar month
-------------------------------------------------------------------------------
PROCEDURE NetTxbIncCalc AS

   -- Variable Declaration
   nti_CurMthStrtDte    DATE;
   nti_CurMthEndDte     DATE;
   nti_SitFactor        NUMBER;
   nti_PerTypInc        BALANCE DEFAULT 0;
   nti_PerTypErn        BALANCE DEFAULT 0;
   nti_AnnTypErn        BALANCE DEFAULT 0;
   nti_PerPenFnd        BALANCE DEFAULT 0;
   nti_PerRfiCon        BALANCE DEFAULT 0;
   nti_PerPenFndMax     BALANCE DEFAULT 0;
   nti_PerPenFndAbm     BALANCE DEFAULT 0;
   nti_AnnPenFnd        BALANCE DEFAULT 0;
   nti_AnnRfiCon        BALANCE DEFAULT 0;
   nti_AnnPenFndMax     BALANCE DEFAULT 0;
   nti_AnnPenFndAbm     BALANCE DEFAULT 0;
   nti_PerArrPenFnd     BALANCE DEFAULT 0;
   nti_PerArrPenFndAbm  BALANCE DEFAULT 0;
   nti_PerRetAnu        BALANCE DEFAULT 0;
   nti_PerNrfiCon       BALANCE DEFAULT 0;
   nti_PerRetAnuMax     BALANCE DEFAULT 0;
   nti_PerRetAnuAbm     BALANCE DEFAULT 0;
   nti_PerArrRetAnu     BALANCE DEFAULT 0;
   nti_PerArrRetAnuAbm  BALANCE DEFAULT 0;
   nti_AnnArrPenFnd     BALANCE DEFAULT 0;
   nti_AnnArrPenFndAbm  BALANCE DEFAULT 0;
   nti_AnnRetAnu        BALANCE DEFAULT 0;
   nti_AnnNrfiCon       BALANCE DEFAULT 0;
   nti_AnnRetAnuMax     BALANCE DEFAULT 0;
   nti_AnnRetAnuAbm     BALANCE DEFAULT 0;
   nti_AnnArrRetAnu     BALANCE DEFAULT 0;
   nti_AnnArrRetAnuAbm  BALANCE DEFAULT 0;
   nti_MedAidAbm        BALANCE DEFAULT 0;
   nti_PerTotAbm        BALANCE DEFAULT 0;
   nti_AnnTotAbm        BALANCE DEFAULT 0;
   nti_TxbPerTypInc     BALANCE DEFAULT 0;
   nti_TxbAnnTypInc     BALANCE DEFAULT 0;
   nti_NetPerTxbInc     BALANCE DEFAULT 0;
   nti_NetAnnTxbInc     BALANCE DEFAULT 0;
   l_65Year             DATE;

BEGIN
   hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',1);
-- Calculate the Current Effective Calendar Month to Date Start Date
--
   SELECT trunc(dbi_SES_DTE,'Month')
     INTO nti_CurMthStrtDte
     FROM dual;

   hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',2);

-- Calculate the Current Effective Calendar Month to Date End Date
--
   SELECT last_day(dbi_SES_DTE)
     INTO nti_CurMthEndDte
     FROM dual;

   hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',3);

-- Calculate Site Factor
--
   -- Based on the number of days in the calendar year over days in the calendar month
   nti_SitFactor := dbi_ZA_DYS_IN_YR / (nti_CurMthEndDte - nti_CurMthStrtDte + 1);

   hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',4);

   WrtHrTrc('nti_CurMthEndDte:  '||to_char(nti_CurMthEndDte,'DD/MM/YYYY'));
   WrtHrTrc('nti_CurMthStrtDte: '||to_char(nti_CurMthStrtDte,'DD/MM/YYYY'));

-- Calculate the Taxable Portion of the Not-Fully Taxable Income Balances
--
   bal_TA_RFI_CMTD  := bal_TA_RFI_CMTD * glb_ZA_TRV_ALL_TX_PRC / 100;
   bal_TA_NRFI_CMTD := bal_TA_NRFI_CMTD * glb_ZA_TRV_ALL_TX_PRC / 100;

   bal_PO_RFI_CMTD  := bal_PO_RFI_CMTD * glb_ZA_PBL_TX_PRC / 100;
   bal_PO_NRFI_CMTD := bal_PO_NRFI_CMTD * glb_ZA_PBL_TX_PRC / 100;

-- Sum Period Type Income Calendar Month to Date Balances
--
   nti_PerTypInc :=
      ( bal_AST_PRCHD_RVAL_NRFI_CMTD + bal_AST_PRCHD_RVAL_RFI_CMTD
      + bal_BP_CMTD
      + bal_BUR_AND_SCH_NRFI_CMTD    + bal_BUR_AND_SCH_RFI_CMTD
      + bal_COMM_NRFI_CMTD           + bal_COMM_RFI_CMTD
      + bal_COMP_ALL_NRFI_CMTD       + bal_COMP_ALL_RFI_CMTD
      + bal_ENT_ALL_NRFI_CMTD        + bal_ENT_ALL_RFI_CMTD
      + bal_FREE_ACCOM_NRFI_CMTD     + bal_FREE_ACCOM_RFI_CMTD
      + bal_FREE_SERV_NRFI_CMTD      + bal_FREE_SERV_RFI_CMTD
      + bal_LOW_LOANS_NRFI_CMTD      + bal_LOW_LOANS_RFI_CMTD
      + bal_MED_PAID_NRFI_CMTD       + bal_MED_PAID_RFI_CMTD
      + bal_MLS_AND_VOUCH_NRFI_CMTD  + bal_MLS_AND_VOUCH_RFI_CMTD
      + bal_OTHER_TXB_ALL_NRFI_CMTD  + bal_OTHER_TXB_ALL_RFI_CMTD
      + bal_OVTM_NRFI_CMTD           + bal_OVTM_RFI_CMTD
      + bal_PO_NRFI_CMTD             + bal_PO_RFI_CMTD
      + bal_PYM_DBT_NRFI_CMTD        + bal_PYM_DBT_RFI_CMTD
      + bal_RES_TRD_NRFI_CMTD        + bal_RES_TRD_RFI_CMTD
      + bal_RGT_AST_NRFI_CMTD        + bal_RGT_AST_RFI_CMTD
      + bal_TA_NRFI_CMTD             + bal_TA_RFI_CMTD
      + bal_TEL_ALL_NRFI_CMTD        + bal_TEL_ALL_RFI_CMTD
      + bal_TOOL_ALL_NRFI_CMTD       + bal_TOOL_ALL_RFI_CMTD
      + bal_TXB_INC_NRFI_CMTD        + bal_TXB_INC_RFI_CMTD
      + bal_TXB_PEN_NRFI_CMTD        + bal_TXB_PEN_RFI_CMTD
      + bal_USE_VEH_NRFI_CMTD        + bal_USE_VEH_RFI_CMTD
      );

-- Annualise by the Site Factor the Period Type Income
--
   nti_PerTypErn := nti_PerTypInc * nti_SitFactor;

-- Sum Annual Type Income Calendar Month to Date Balances
--
   nti_AnnTypErn :=
      nti_PerTypErn
    + ( bal_AB_NRFI_CMTD              + bal_AB_RFI_CMTD
      + bal_AA_PRCHD_RVAL_NRFI_CMTD   + bal_AA_PRCHD_RVAL_RFI_CMTD
      + bal_ANN_BUR_AND_SCH_NRFI_CMTD + bal_ANN_BUR_AND_SCH_RFI_CMTD
      + bal_AC_NRFI_CMTD              + bal_AC_RFI_CMTD
      + bal_ANU_FRM_RET_FND_NRFI_CMTD + bal_ANU_FRM_RET_FND_RFI_CMTD
      + bal_ARES_TRD_NRFI_CMTD        + bal_ARES_TRD_RFI_CMTD
      + bal_PRCH_ANU_TXB_NRFI_CMTD    + bal_PRCH_ANU_TXB_RFI_CMTD
      + bal_TXB_AP_NRFI_CMTD          + bal_TXB_AP_RFI_CMTD
      );

-----------------------------
-- Calculate Abatement Values
-----------------------------
   -------------------------
   -- Pension Fund Abatement
   -------------------------
      ---------------------
      -- Period Calculation
      ---------------------
         -- Annualise Period Pension Fund Contribution
         nti_PerPenFnd := bal_PF_CMTD * nti_SitFactor;
         -- Annualise Period Rfiable Contributions
         nti_PerRfiCon := bal_TOT_RFI_INC_CMTD * nti_SitFactor;
      ---------------------
      -- Annual Calculation
      ---------------------
         -- Annual Pension Fund Contribution
         nti_AnnPenFnd := nti_PerPenFnd + bal_ANN_PF_CMTD;
         -- Annual Rfi Contribution
         nti_AnnRfiCon := nti_PerRfiCon + bal_TOT_RFI_AN_INC_CMTD;

      --------------------------------
      -- Arrear Pension Fund Abatement
      --------------------------------
         hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',4);
         -------------
         -- Excess ITD
         -------------
         nti_PerArrPenFnd := bal_EXC_ARR_PEN_ITD;
         ------------------------------------
         -- Current/Annual based on frequency
         ------------------------------------
         nti_PerArrPenFnd :=
            nti_PerArrPenFnd + ( bal_ARR_PF_CMTD * nti_SitFactor);
          ---------
          -- Annual
          ---------
          nti_AnnArrPenFnd := nti_PerArrPenFnd + bal_ANN_ARR_PF_CMTD;

      -------------------------------
      -- Retirement Annuity Abatement
      -------------------------------
         hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',7);
         -------------
         -- Current RA
         -------------
         -- Calculate RA Contribution
         nti_PerRetAnu := bal_RA_CMTD * nti_SitFactor;
         ---------------------
         -- Current NRFI Contr
         ---------------------
         IF bal_PF_CMTD + bal_ANN_PF_CMTD = 0 THEN
            hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',10);
            nti_PerNrfiCon := (
                                bal_TOT_RFI_INC_CMTD + bal_TOT_NRFI_INC_CMTD
                              )
                              * nti_SitFactor;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',11);
            nti_PerNrfiCon := bal_TOT_NRFI_INC_CMTD * nti_SitFactor;
         END IF;
         ------------
         -- Annual RA
         ------------
         nti_AnnRetAnu := nti_PerRetAnu + bal_ANN_RA_CMTD;

         IF bal_PF_CMTD + bal_ANN_PF_CMTD = 0 THEN
            hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',10);

            nti_AnnNrfiCon := nti_PerNrfiCon
                            + bal_TOT_NRFI_AN_INC_CMTD
                            + bal_TOT_RFI_AN_INC_CMTD;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',11);

            nti_AnnNrfiCon := nti_PerNrfiCon + bal_TOT_NRFI_AN_INC_CMTD;
         END IF;
      --------------------------------------
      -- Arrear Retirement Annuity Abatement
      --------------------------------------
         hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',12);
         -------------
         -- Excess ITD
         -------------
         nti_PerArrRetAnu := bal_EXC_ARR_RA_ITD;
         ------------------------------------
         -- Current/Annual based on frequency
         ------------------------------------
         nti_PerArrRetAnu :=   nti_PerArrRetAnu
                           + ( bal_ARR_RA_CMTD
                             * nti_SitFactor
                             );
         ---------
         -- Annual
         ---------
         nti_AnnArrRetAnu := nti_PerArrRetAnu
                           + nti_AnnArrRetAnu
                           + bal_ANN_ARR_RA_CMTD;

      ------------------------
      -- Medical Aid Abatement
      ------------------------
         nti_MedAidAbm := bal_MED_CONTR_CMTD * nti_SitFactor;

   ----------------------------------------------------------------------------
   --                        CALCULATE THE ABATEMENTS                        --
   ----------------------------------------------------------------------------
   -------------------------
   -- Pension Fund Abatement
   -------------------------
      ---------------------
      -- Period Calculation
      ---------------------
      -- Calculate the Pension Fund Maximum
      nti_PerPenFndMax := GREATEST( glb_ZA_PF_AN_MX_ABT
                                  , glb_ZA_PF_MX_PRC / 100 * nti_PerRfiCon
                                  );
      -- Calculate Period Pension Fund Abatement
      nti_PerPenFndAbm := LEAST(nti_PerPenFnd, nti_PerPenFndMax);
      ---------------------
      -- Annual Calculation
      ---------------------
      -- Calculate the Pension Fund Maximum
      nti_AnnPenFndMax := GREATEST( glb_ZA_PF_AN_MX_ABT
                                  , glb_ZA_PF_MX_PRC / 100 * nti_AnnRfiCon
                                  );

      -- Calculate Annual Pension Fund Abatement
      nti_AnnPenFndAbm := LEAST(nti_AnnPenFnd, nti_AnnPenFndMax);
   --------------------------------
   -- Arrear Pension Fund Abatement
   --------------------------------
      ---------------------
      -- Period Calculation
      ---------------------
      nti_PerArrPenFndAbm := LEAST(nti_PerArrPenFnd, glb_ZA_ARR_PF_AN_MX_ABT);
      ---------------------
      -- Annual Calculation
      ---------------------
      nti_AnnArrPenFndAbm := LEAST(nti_AnnArrPenFnd, glb_ZA_ARR_PF_AN_MX_ABT);
   ---------------------------------
   -- Retirement Annnnuity Abatement
   ---------------------------------
      ---------------------
      -- Period Calculation
      ---------------------
      -- Calculate the Retirement Annuity Maximum
      nti_PerRetAnuMax := GREATEST( glb_ZA_PF_AN_MX_ABT
                                  , glb_ZA_RA_AN_MX_ABT - nti_PerPenFndAbm
                                  , glb_ZA_RA_MX_PRC / 100 * nti_PerNrfiCon
                                  );

      -- Calculate Retirement Annuity Abatement
      nti_PerRetAnuAbm := LEAST(nti_PerRetAnu, nti_PerRetAnuMax);
      ---------------------
      -- Annual Calculation
      ---------------------
      nti_AnnRetAnuMax := GREATEST( glb_ZA_PF_AN_MX_ABT
                                  , glb_ZA_RA_AN_MX_ABT - nti_AnnPenFndAbm
                                  , glb_ZA_RA_MX_PRC / 100 * nti_AnnNrfiCon
                                  );

      -- Calculate Retirement Annuity Abatement
      nti_AnnRetAnuAbm := LEAST(nti_AnnRetAnu, nti_AnnRetAnuMax);
   --------------------------------------
   -- Arrear Retirement Annuity Abatement
   --------------------------------------
      ---------------------
      -- Period Calculation
      ---------------------
      nti_PerArrRetAnuAbm := LEAST(nti_PerArrRetAnu, glb_ZA_ARR_RA_AN_MX_ABT);
      ---------------------
      -- Annual Calculation
      ---------------------
      nti_AnnArrRetAnuAbm := LEAST(nti_AnnArrRetAnu, glb_ZA_ARR_RA_AN_MX_ABT);

   -----------------------------------------------------------
   -- Tax Rebates, Threshold Figure and Medical Aid Abatements
   -----------------------------------------------------------
      -- Calculate the assignments 65 Year Date
      l_65Year := add_months(py_za_tx_01032002.dbi_PER_DTE_OF_BRTH,780);

      IF l_65Year > dbi_ZA_TX_YR_END THEN
         nti_MedAidAbm := 0;
      END IF;

      hr_utility.set_location('py_za_tx_01032002.NetTxbIncCalc',62);

   -------------------
   -- Total Abatements
   -------------------
      -- Period Total Abatement
      nti_PerTotAbm := ( nti_PerPenFndAbm
                       + nti_PerArrPenFndAbm
                       + nti_PerRetAnuAbm
                       + nti_PerArrRetAnuAbm
                       + nti_MedAidAbm
                       );

      -- Annual Total Abatements
      nti_AnnTotAbm := ( nti_AnnPenFndAbm
                       + nti_AnnArrPenFndAbm
                       + nti_AnnRetAnuAbm
                       + nti_AnnArrRetAnuAbm
                       + nti_MedAidAbm
                       );

-- Calculate New O Figures
--
   nti_TxbPerTypInc := nti_PerTypErn - nti_PerTotAbm;
   nti_TxbAnnTypInc := nti_AnnTypErn - nti_AnnTotAbm;

-- Deannualise Period O Figure
--
   nti_NetPerTxbInc := nti_TxbPerTypInc / nti_SitFactor;
-- Calculate the Net Taxable Annual Type Income
--
   nti_NetAnnTxbInc := nti_TxbAnnTypInc - nti_TxbPerTypInc;

-- Calculate New Net Taxable Income Balance
--
   trc_NtiUpdFig := (nti_NetPerTxbInc + nti_NetAnnTxbInc) - bal_NET_TXB_INC_CMTD;

   WrtHrTrc('nti_SitFactor:        '||to_char(nti_SitFactor));
   WrtHrTrc('nti_PerTypErn:        '||to_char(nti_PerTypErn));
   WrtHrTrc('nti_AnnTypErn:        '||to_char(nti_AnnTypErn));
   WrtHrTrc('nti_NetPerTxbInc:     '||to_char(nti_NetPerTxbInc));
   WrtHrTrc('nti_NetAnnTxbInc:     '||to_char(nti_NetAnnTxbInc));
   WrtHrTrc('bal_NET_TXB_INC_CMTD: '||to_char(bal_NET_TXB_INC_CMTD));
   WrtHrTrc('trc_NtiUpdFig:        '||to_char(trc_NtiUpdFig));
   WrtHrTrc(' ');
   WrtHrTrc('nti_PerTotAbm:        '||to_char(nti_PerTotAbm));
   WrtHrTrc('nti_PerTotAbm consists of:');
   WrtHrTrc('nti_PerPenFndAbm:     '||to_char(nti_PerPenFndAbm));
   WrtHrTrc('nti_PerArrPenFndAbm:  '||to_char(nti_PerArrPenFndAbm));
   WrtHrTrc('nti_PerRetAnuAbm:     '||to_char(nti_PerRetAnuAbm));
   WrtHrTrc('nti_PerArrRetAnuAbm:  '||to_char(nti_PerArrRetAnuAbm));
   WrtHrTrc('nti_MedAidAbm:        '||to_char(nti_MedAidAbm));
   WrtHrTrc(' ');
   WrtHrTrc('nti_AnnTotAbm:        '||to_char(nti_AnnTotAbm));
   WrtHrTrc('nti_AnnTotAbm consists of:');
   WrtHrTrc('nti_AnnPenFndAbm:     '||to_char(nti_AnnPenFndAbm));
   WrtHrTrc('nti_AnnArrPenFndAbm:  '||to_char(nti_AnnArrPenFndAbm));
   WrtHrTrc('nti_AnnRetAnuAbm:     '||to_char(nti_AnnRetAnuAbm));
   WrtHrTrc('nti_AnnArrRetAnuAbm:  '||to_char(nti_AnnArrRetAnuAbm));
   WrtHrTrc('nti_MedAidAbm:        '||to_char(nti_MedAidAbm));


EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'NetTxbIncCalc: '||TO_CHAR(SQLCODE);
      END IF;
       RAISE xpt_E;
END NetTxbIncCalc;

-------------------------------------------------------------------------------
-- Tax Override Function
-------------------------------------------------------------------------------
FUNCTION ZaTxOvr_01032002(
    p_OvrTyp IN VARCHAR2
   ,p_TxOnNI IN NUMBER DEFAULT 0
   ,p_TxOnAP IN NUMBER DEFAULT 0
   ,p_TxPrc  IN NUMBER DEFAULT 0
   )RETURN NUMBER
AS
   l_Dum NUMBER := 1;
BEGIN
   -- Set the Override Global
   trc_OvrTxCalc := TRUE;

   -- Set Override Values
   trc_OvrTyp  := p_OvrTyp;

   IF p_OvrTyp = 'V' THEN
      trc_LibFpNI := p_TxOnNI;
      trc_LibFpAP := p_TxOnAP;
   ELSIF p_OvrTyp = 'P' THEN
      trc_OvrPrc  := p_TxPrc;
   END IF;
   RETURN l_Dum;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxOvr_01032002: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxOvr_01032002;

-------------------------------------------------------------------------------
--                    Main Tax Calculation Procedures                        --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- LteCalc
-------------------------------------------------------------------------------
PROCEDURE LteCalc AS

   -- Variables
   l_EndDate             DATE;
   l_StrtDte             DATE;
   l_65Year              DATE;
   l_ZA_TX_YR_END        DATE;
   l_ZA_ADL_TX_RBT       NUMBER;
   l_ZA_PRI_TX_RBT       NUMBER;
   l_ZA_PRI_TX_THRSHLD   NUMBER;
   l_ZA_SC_TX_THRSHLD    NUMBER;

   l_Sl                  BOOLEAN;
   l_Np                  BALANCE DEFAULT 0;


   -- Private Functions
   --
      FUNCTION getBalVal
         (p_BalNme IN pay_balance_types.balance_name%TYPE
         ,p_EffDte   IN DATE
         ) RETURN NUMBER
      AS
         -- Variables
         l_BalVal BALANCE;
         l_BalTypId pay_balance_types.balance_type_id%TYPE;
         l_dimension pay_balance_dimensions.dimension_name%TYPE ;

      BEGIN
         hr_utility.set_location('py_za_tx_01032002.LteCalc',1);
         -- Get the Balance Type ID
         SELECT pbt.balance_type_id
           INTO l_BalTypId
           FROM pay_balance_types pbt
          WHERE pbt.balance_name = p_BalNme;

         hr_utility.set_location('py_za_tx_01032002.LteCalc',2);

         -- Get the Balance Value
          -- 3491357
         /*l_BalVal := py_za_bal.calc_asg_tax_ytd_date
                        ( con_ASG_ID
                        , l_BalTypId
                        , p_EffDte
                        );*/
         l_dimension := '_ASG_TAX_YTD';
         l_BalVal := py_za_bal.get_balance_value
                                      ( con_ASG_ID
                                      , l_BalTypId
                                      , l_dimension
                                      , p_EffDte
                                      );

         RETURN l_BalVal;
      END getBalVal;

      FUNCTION getBalVal2
         (p_BalNme IN pay_balance_types.balance_name%TYPE
         ,p_EffDte   IN DATE
         ) RETURN NUMBER
      AS
         -- Variables
         l_BalVal BALANCE;
         l_BalTypId pay_balance_types.balance_type_id%TYPE;
         l_dimension pay_balance_dimensions.dimension_name%TYPE ;
      BEGIN
         hr_utility.set_location('py_za_tx_01032002.LteCalc',3);
         -- Get the Balance Type ID
         SELECT pbt.balance_type_id
           INTO l_BalTypId
           FROM pay_balance_types pbt
          WHERE pbt.balance_name = p_BalNme;

         hr_utility.set_location('py_za_tx_01032002.LteCalc',4);

         -- Get the Balance Value
         -- 3491357
         /*l_BalVal := py_za_bal.calc_asg_itd_date
                        ( con_ASG_ID
                        , l_BalTypId
                        , p_EffDte
                        );*/
         l_dimension := '_ASG_ITD';
         l_BalVal := py_za_bal.get_balance_value
                                       ( con_ASG_ID
                                       , l_BalTypId
                                       , l_dimension
                                       , p_EffDte
                                       );

         RETURN l_BalVal;
      END getBalVal2;

BEGIN
   hr_utility.set_location('py_za_tx_01032002.LteCalc',5);
   -- Does the Assignment have an OFigure?
   --
   IF bal_TOT_TXB_INC_ITD <= 0 THEN
      hr_utility.set_location('py_za_tx_01032002.LteCalc',6);
      -- Calculate the 'O' Figure
      -- Set the Global
      trc_CalTyp := 'PstCalc';
      -- Set the Site Factor to the value of the previous tax year
      l_StrtDte := dbi_ZA_ASG_TX_YR_STRT;
      l_EndDate := dbi_ZA_ASG_TX_YR_END;

      hr_utility.set_location('py_za_tx_01032002.LteCalc',8);

      trc_SitFactor := (l_EndDate - l_StrtDte + 1) / py_za_tx_utl_01032002.DaysWorked;

      hr_utility.set_location('py_za_tx_01032002.LteCalc',9);

      -- Populate Local Balance Variables
      -- The PTD Globals are used as dummy to store the previous tax year's
      -- Balance values

      bal_AB_NRFI_PTD              := getBalVal('Annual Bonus NRFI',l_EndDate);
      bal_AB_RFI_PTD               := getBalVal('Annual Bonus RFI',l_EndDate);
      bal_AA_PRCHD_RVAL_NRFI_PTD   := getBalVal('Annual Asset Purchased at Reduced Value NRFI',l_EndDate);
      bal_AA_PRCHD_RVAL_RFI_PTD    := getBalVal('Annual Asset Purchased at Reduced Value RFI',l_EndDate);
      bal_ANN_BUR_AND_SCH_NRFI_PTD := getBalVal('Annual Bursaries and Scholarships NRFI',l_EndDate);
      bal_ANN_BUR_AND_SCH_RFI_PTD  := getBalVal('Annual Bursaries and Scholarships RFI',l_EndDate);
      bal_AC_NRFI_PTD              := getBalVal('Annual Commission NRFI',l_EndDate);
      bal_AC_RFI_PTD               := getBalVal('Annual Commission RFI',l_EndDate);
      bal_ANN_ARR_PF_PTD           := getBalVal('Annual Arrear Pension Fund',l_EndDate);
      bal_ANN_ARR_RA_PTD           := getBalVal('Annual Arrear Retirement Annuity',l_EndDate);
      bal_ANN_PF_PTD               := getBalVal('Annual Pension Fund',l_EndDate);
      bal_ANN_RA_PTD               := getBalVal('Annual Retirement Annuity',l_EndDate);
      bal_ANU_FRM_RET_FND_NRFI_PTD := getBalVal('Annuity from Retirement Fund NRFI',l_EndDate);
      bal_ANU_FRM_RET_FND_RFI_PTD  := getBalVal('Annuity from Retirement Fund RFI',l_EndDate);
      bal_ARES_TRD_NRFI_PTD        := getBalVal('Annual Restraint of Trade NRFI',l_EndDate);
      bal_ARES_TRD_RFI_PTD         := getBalVal('Annual Restraint of Trade RFI',l_EndDate);
      bal_ARR_PF_PTD               := getBalVal('Arrear Pension Fund',l_EndDate);
      bal_ARR_RA_PTD               := getBalVal('Arrear Retirement Annuity',l_EndDate);
      bal_AST_PRCHD_RVAL_NRFI_PTD  := getBalVal('Asset Purchased at Reduced Value NRFI',l_EndDate);
      bal_AST_PRCHD_RVAL_RFI_PTD   := getBalVal('Asset Purchased at Reduced Value RFI',l_EndDate);
      bal_BP_PTD                   := getBalVal('Bonus Provision',l_EndDate);
      bal_BUR_AND_SCH_NRFI_PTD     := getBalVal('Bursaries and Scholarships NRFI',l_EndDate);
      bal_BUR_AND_SCH_RFI_PTD      := getBalVal('Bursaries and Scholarships RFI',l_EndDate);
      bal_COMM_NRFI_PTD            := getBalVal('Commission NRFI',l_EndDate);
      bal_COMM_RFI_PTD             := getBalVal('Commission RFI',l_EndDate);
      bal_COMP_ALL_NRFI_PTD        := getBalVal('Computer Allowance NRFI',l_EndDate);
      bal_COMP_ALL_RFI_PTD         := getBalVal('Computer Allowance RFI',l_EndDate);
      bal_PF_PTD                   := getBalVal('Current Pension Fund',l_EndDate);
      bal_RA_PTD                   := getBalVal('Current Retirement Annuity',l_EndDate);
      bal_ENT_ALL_NRFI_PTD         := getBalVal('Entertainment Allowance NRFI',l_EndDate);
      bal_ENT_ALL_RFI_PTD          := getBalVal('Entertainment Allowance RFI',l_EndDate);
      bal_EXC_ARR_PEN_PTD          := getBalVal2('Excess Arrear Pension',l_EndDate);
      bal_EXC_ARR_RA_PTD           := getBalVal2('Excess Arrear Retirement Annuity',l_EndDate);
      bal_FREE_ACCOM_NRFI_PTD      := getBalVal('Free or Cheap Accommodation NRFI',l_EndDate);
      bal_FREE_ACCOM_RFI_PTD       := getBalVal('Free or Cheap Accommodation RFI',l_EndDate);
      bal_FREE_SERV_NRFI_PTD       := getBalVal('Free or Cheap Services NRFI',l_EndDate);
      bal_FREE_SERV_RFI_PTD        := getBalVal('Free or Cheap Services RFI',l_EndDate);
      bal_LOW_LOANS_NRFI_PTD       := getBalVal('Low or Interest Free Loans NRFI',l_EndDate);
      bal_LOW_LOANS_RFI_PTD        := getBalVal('Low or Interest Free Loans RFI',l_EndDate);
      bal_MLS_AND_VOUCH_NRFI_PTD   := getBalVal('Meals Refreshments and Vouchers NRFI',l_EndDate);
      bal_MLS_AND_VOUCH_RFI_PTD    := getBalVal('Meals Refreshments and Vouchers RFI',l_EndDate);
      bal_MED_CONTR_PTD            := getBalVal('Medical Aid Contribution',l_EndDate);
      bal_MED_PAID_NRFI_PTD        := getBalVal('Medical Aid Paid on Behalf of Employee NRFI',l_EndDate);
      bal_MED_PAID_RFI_PTD         := getBalVal('Medical Aid Paid on Behalf of Employee RFI',l_EndDate);
      bal_OTHER_TXB_ALL_NRFI_PTD   := getBalVal('Other Taxable Allowance NRFI',l_EndDate);
      bal_OTHER_TXB_ALL_RFI_PTD    := getBalVal('Other Taxable Allowance RFI',l_EndDate);
      bal_OVTM_NRFI_PTD            := getBalVal('Overtime NRFI',l_EndDate);
      bal_OVTM_RFI_PTD             := getBalVal('Overtime RFI',l_EndDate);
      bal_PYM_DBT_NRFI_PTD         := getBalVal('Payment of Employee Debt NRFI',l_EndDate);
      bal_PYM_DBT_RFI_PTD          := getBalVal('Payment of Employee Debt RFI',l_EndDate);
      bal_PO_NRFI_PTD              := getBalVal('Public Office Allowance NRFI',l_EndDate);
      bal_PO_RFI_PTD               := getBalVal('Public Office Allowance RFI',l_EndDate);
      bal_PRCH_ANU_TXB_NRFI_PTD    := getBalVal('Purchased Annuity Taxable NRFI',l_EndDate);
      bal_PRCH_ANU_TXB_RFI_PTD     := getBalVal('Purchased Annuity Taxable RFI',l_EndDate);
      bal_RES_TRD_NRFI_PTD         := getBalVal('Restraint of Trade NRFI',l_EndDate);
      bal_RES_TRD_RFI_PTD          := getBalVal('Restraint of Trade RFI',l_EndDate);
      bal_RGT_AST_NRFI_PTD         := getBalVal('Right of Use of Asset NRFI',l_EndDate);
      bal_RGT_AST_RFI_PTD          := getBalVal('Right of Use of Asset RFI',l_EndDate);
      bal_TXB_AP_NRFI_PTD          := getBalVal('Taxable Annual Payment NRFI',l_EndDate);
      bal_TXB_AP_RFI_PTD           := getBalVal('Taxable Annual Payment RFI',l_EndDate);
      bal_TXB_INC_NRFI_PTD         := getBalVal('Taxable Income NRFI',l_EndDate);
      bal_TXB_INC_RFI_PTD          := getBalVal('Taxable Income RFI',l_EndDate);
      bal_TXB_PEN_NRFI_PTD         := getBalVal('Taxable Pension NRFI',l_EndDate);
      bal_TXB_PEN_RFI_PTD          := getBalVal('Taxable Pension RFI',l_EndDate);
      bal_TEL_ALL_NRFI_PTD         := getBalVal('Telephone Allowance NRFI',l_EndDate);
      bal_TEL_ALL_RFI_PTD          := getBalVal('Telephone Allowance RFI',l_EndDate);
      bal_TOOL_ALL_NRFI_PTD        := getBalVal('Tool Allowance NRFI',l_EndDate);
      bal_TOOL_ALL_RFI_PTD         := getBalVal('Tool Allowance RFI',l_EndDate);
      bal_TOT_INC_PTD              := getBalVal('Total Income',l_EndDate);
      bal_TOT_NRFI_AN_INC_PTD      := getBalVal('Total NRFIable Annual Income',l_EndDate);
      bal_TOT_NRFI_INC_PTD         := getBalVal('Total NRFIable Income',l_EndDate);
      bal_TOT_RFI_AN_INC_PTD       := getBalVal('Total RFIable Annual Income',l_EndDate);
      bal_TOT_RFI_INC_PTD          := getBalVal('Total RFIable Income',l_EndDate);
      bal_TA_NRFI_PTD              := getBalVal('Travel Allowance NRFI',l_EndDate);
      bal_TA_RFI_PTD               := getBalVal('Travel Allowance RFI',l_EndDate);
      bal_USE_VEH_NRFI_PTD         := getBalVal('Use of Motor Vehicle NRFI',l_EndDate);
      bal_USE_VEH_RFI_PTD          := getBalVal('Use of Motor Vehicle RFI',l_EndDate);

      hr_utility.set_location('py_za_tx_01032002.LteCalc',10);

      -- Update Globals with Correct Taxable Values
      py_za_tx_utl_01032002.TrvAll;

      bal_PO_NRFI_PTD := bal_PO_NRFI_PTD
                       * py_za_tx_utl_01032002.GlbVal('ZA_PUBL_TAX_PERC',l_EndDate)
                       / 100;
      bal_PO_RFI_PTD  := bal_PO_RFI_PTD
                       * py_za_tx_utl_01032002.GlbVal('ZA_PUBL_TAX_PERC',l_EndDate)
                       / 100;

      hr_utility.set_location('py_za_tx_01032002.LteCalc',11);

      -- Rebates
      py_za_tx_utl_01032002.SetRebates;
      -- Abatements
      py_za_tx_utl_01032002.Abatements;

      hr_utility.set_location('py_za_tx_01032002.LteCalc',12);

      -- Base Earnings
      --
      trc_BseErn :=
         (( bal_AST_PRCHD_RVAL_NRFI_PTD + bal_AST_PRCHD_RVAL_RFI_PTD
         + bal_BP_PTD
         + bal_BUR_AND_SCH_NRFI_PTD     + bal_BUR_AND_SCH_RFI_PTD
         + bal_COMM_NRFI_PTD            + bal_COMM_RFI_PTD
         + bal_COMP_ALL_NRFI_PTD        + bal_COMP_ALL_RFI_PTD
         + bal_ENT_ALL_NRFI_PTD         + bal_ENT_ALL_RFI_PTD
         + bal_FREE_ACCOM_NRFI_PTD      + bal_FREE_ACCOM_RFI_PTD
         + bal_FREE_SERV_NRFI_PTD       + bal_FREE_SERV_RFI_PTD
         + bal_LOW_LOANS_NRFI_PTD       + bal_LOW_LOANS_RFI_PTD
         + bal_MED_PAID_NRFI_PTD        + bal_MED_PAID_RFI_PTD
         + bal_MLS_AND_VOUCH_NRFI_PTD   + bal_MLS_AND_VOUCH_RFI_PTD
         + bal_OTHER_TXB_ALL_NRFI_PTD   + bal_OTHER_TXB_ALL_RFI_PTD
         + bal_OVTM_NRFI_PTD            + bal_OVTM_RFI_PTD
         + bal_PO_NRFI_PTD              + bal_PO_RFI_PTD
         + bal_PYM_DBT_NRFI_PTD         + bal_PYM_DBT_RFI_PTD
         + bal_RES_TRD_NRFI_PTD         + bal_RES_TRD_RFI_PTD
         + bal_RGT_AST_NRFI_PTD         + bal_RGT_AST_RFI_PTD
         + bal_TA_NRFI_PTD              + bal_TA_RFI_PTD
         + bal_TEL_ALL_NRFI_PTD         + bal_TEL_ALL_RFI_PTD
         + bal_TOOL_ALL_NRFI_PTD        + bal_TOOL_ALL_RFI_PTD
         + bal_TXB_INC_NRFI_PTD         + bal_TXB_INC_RFI_PTD
         + bal_TXB_PEN_NRFI_PTD         + bal_TXB_PEN_RFI_PTD
         + bal_USE_VEH_NRFI_PTD         + bal_USE_VEH_RFI_PTD)
         * trc_SitFactor)
         + bal_AB_NRFI_PTD              + bal_AB_RFI_PTD
         + bal_AA_PRCHD_RVAL_NRFI_PTD   + bal_AA_PRCHD_RVAL_RFI_PTD
         + bal_ANN_BUR_AND_SCH_NRFI_PTD + bal_ANN_BUR_AND_SCH_RFI_PTD
         + bal_AC_NRFI_PTD              + bal_AC_RFI_PTD
         + bal_ANU_FRM_RET_FND_NRFI_PTD + bal_ANU_FRM_RET_FND_RFI_PTD
         + bal_ARES_TRD_NRFI_PTD        + bal_ARES_TRD_RFI_PTD
         + bal_PRCH_ANU_TXB_NRFI_PTD    + bal_PRCH_ANU_TXB_RFI_PTD
         + bal_TXB_AP_NRFI_PTD          + bal_TXB_AP_RFI_PTD;

      -- Taxable Base Income
      trc_TxbBseInc := trc_BseErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbBseInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.LteCalc',13);
      -- Tax Liability
         trc_TotLibBse := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbBseInc);
      ELSE
         hr_utility.set_location('py_za_tx_01032002.LteCalc',14);
         trc_TotLibBse := 0;
      END IF;

      -- Populate the O Figure
      trc_OUpdFig := trc_TxbBseInc - bal_TOT_TXB_INC_ITD;

      -- Base Income
      WrtHrTrc('trc_BseErn:    '||to_char(trc_BseErn));
      WrtHrTrc('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
      WrtHrTrc('trc_TotLibBse: '||to_char(trc_TotLibBse));

   ELSE
      hr_utility.set_location('py_za_tx_01032002.LteCalc',15);
      -- Use the 'O' Figure as Base
      -- Set the Global
      trc_CalTyp := 'LteCalc';

      -- Get the assignment's previous tax year's
      --   threshold and rebate figures
      -- Employee Tax Year Start and End Dates
      l_EndDate  := dbi_ZA_ASG_TX_YR_END;

      hr_utility.set_location('py_za_tx_01032002.LteCalc',16);

      -- Global Values
      l_ZA_TX_YR_END        := l_EndDate;
      l_ZA_ADL_TX_RBT       := py_za_tx_utl_01032002.GlbVal('ZA_ADDITIONAL_TAX_REBATE',l_EndDate);
      l_ZA_PRI_TX_RBT       := py_za_tx_utl_01032002.GlbVal('ZA_PRIMARY_TAX_REBATE',l_EndDate);
      l_ZA_PRI_TX_THRSHLD   := py_za_tx_utl_01032002.GlbVal('ZA_PRIM_TAX_THRESHOLD',l_EndDate);
      l_ZA_SC_TX_THRSHLD    := py_za_tx_utl_01032002.GlbVal('ZA_SEC_TAX_THRESHOLD',l_EndDate);

      -- Calculate the assignments 65 Year Date
      l_65Year := add_months(dbi_PER_DTE_OF_BRTH,780);

      IF l_65Year <= l_ZA_TX_YR_END THEN
         hr_utility.set_location('py_za_tx_01032002.LteCalc',17);
         -- give the extra abatement
         trc_Rebate    := l_ZA_PRI_TX_RBT + l_ZA_ADL_TX_RBT;
         trc_Threshold := l_ZA_SC_TX_THRSHLD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.LteCalc',18);
         -- not eligable for extra abatement
         trc_Rebate    := l_ZA_PRI_TX_RBT;
         trc_Threshold := l_ZA_PRI_TX_THRSHLD;
      END IF;


   -- Base Earnings
   --
      -- Take the OFigure as Taxable Base Income
      trc_TxbBseInc := bal_TOT_TXB_INC_ITD;
      -- Threshold Check
      IF trc_TxbBseInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.LteCalc',19);
         -- Tax Liability
         trc_TotLibBse := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbBseInc);
      ELSE
         hr_utility.set_location('py_za_tx_01032002.LteCalc',20);
         trc_TotLibBse := 0;
      END IF;

      -- Base Income
      WrtHrTrc('trc_BseErn:    '||to_char(trc_BseErn));
      WrtHrTrc('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
      WrtHrTrc('trc_TotLibBse: '||to_char(trc_TotLibBse));
   END IF;

   -- Override the Global
   trc_CalTyp := 'LteCalc';
   -- Set the SitFactor back to 1
   trc_SitFactor := 1;

   hr_utility.set_location('py_za_tx_01032002.LteCalc',21);

   -- Rebates
   py_za_tx_utl_01032002.SetRebates;
   -- Abatements
   py_za_tx_utl_01032002.Abatements;

   hr_utility.set_location('py_za_tx_01032002.LteCalc',22);

   -- Update Global Balance Values with correct TAXABLE values
   py_za_tx_utl_01032002.TrvAll;

   bal_PO_RFI_YTD  := bal_PO_RFI_YTD * glb_ZA_PBL_TX_PRC / 100;
   bal_PO_NRFI_YTD := bal_PO_NRFI_YTD * glb_ZA_PBL_TX_PRC / 100;

-- Normal Income
--
   -- Ytd Normal Income
   trc_NorIncYtd :=
      ( bal_COMM_NRFI_YTD          + bal_COMM_RFI_YTD
      + bal_COMP_ALL_NRFI_YTD      + bal_COMP_ALL_RFI_YTD
      + bal_ENT_ALL_NRFI_YTD       + bal_ENT_ALL_RFI_YTD
      + bal_OTHER_TXB_ALL_NRFI_YTD + bal_OTHER_TXB_ALL_RFI_YTD
      + bal_OVTM_NRFI_YTD          + bal_OVTM_RFI_YTD
      + bal_RES_TRD_NRFI_YTD       + bal_RES_TRD_RFI_YTD
      + bal_TXB_INC_NRFI_YTD       + bal_TXB_INC_RFI_YTD
      + bal_TXB_PEN_NRFI_YTD       + bal_TXB_PEN_RFI_YTD
      + bal_TEL_ALL_NRFI_YTD       + bal_TEL_ALL_RFI_YTD
      + bal_TOOL_ALL_NRFI_YTD      + bal_TOOL_ALL_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_NorIncYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.LteCalc',23);
      -- Normal Earnings
      trc_NorErn := trc_NorIncYtd + trc_TxbBseInc;
      -- Taxable Normal Income
      trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbNorInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.LteCalc',24);
         -- Tax Liability
         trc_TotLibNI := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbNorInc);
         trc_LibFyNI  := trc_TotLibNI - least(trc_TotLibNI,trc_TotLibBse);
         trc_TotLibNI := greatest(trc_TotLibNI,trc_TotLibBse);
         trc_LibFpNI  := trc_LibFyNI - bal_TX_ON_NI_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.LteCalc',25);
         -- Set Cascade Figures and Refund
         trc_TotLibNI   := 0;
         trc_LibFpNI    := -1 * bal_TX_ON_NI_YTD;
         trc_LibFpNIOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.LteCalc',26);
      -- Set Cascade Figures and Refund
      trc_NorErn     := trc_TxbBseInc;
      trc_TxbNorInc  := 0;
      trc_TotLibNI   := trc_TotLibBse;
      trc_LibFpNI    := -1 * bal_TX_ON_NI_YTD;
      trc_LibFpNIOvr := TRUE;
   END IF;

-- Fringe Benefits
--
   -- Ytd Fringe Benefits
   trc_FrnBenYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_YTD + bal_AST_PRCHD_RVAL_RFI_YTD
      + bal_BUR_AND_SCH_NRFI_YTD    + bal_BUR_AND_SCH_RFI_YTD
      + bal_FREE_ACCOM_NRFI_YTD     + bal_FREE_ACCOM_RFI_YTD
      + bal_FREE_SERV_NRFI_YTD      + bal_FREE_SERV_RFI_YTD
      + bal_LOW_LOANS_NRFI_YTD      + bal_LOW_LOANS_RFI_YTD
      + bal_MLS_AND_VOUCH_NRFI_YTD  + bal_MLS_AND_VOUCH_RFI_YTD
      + bal_MED_PAID_NRFI_YTD       + bal_MED_PAID_RFI_YTD
      + bal_PYM_DBT_NRFI_YTD        + bal_PYM_DBT_RFI_YTD
      + bal_RGT_AST_NRFI_YTD        + bal_RGT_AST_RFI_YTD
      + bal_USE_VEH_NRFI_YTD        + bal_USE_VEH_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_FrnBenYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.LteCalc',27);
      -- Fringe Benefit Earnings
      trc_FrnBenErn := trc_FrnBenYtd + trc_NorErn;
      -- Taxable Fringe Income
      trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbFrnInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.LteCalc',28);
         -- Tax Liability
         trc_TotLibFB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbFrnInc);
         trc_LibFyFB  := trc_TotLibFB - least(trc_TotLibFB,trc_TotLibNI);
         trc_TotLibFB := greatest(trc_TotLibFB,trc_TotLibNI);
         trc_LibFpFB  := trc_LibFyFB - bal_TX_ON_FB_YTD;
      ElSE
         hr_utility.set_location('py_za_tx_01032002.LteCalc',29);
         -- Set Cascade Figures and Refund
         trc_TotLibFB   := trc_TotLibNI;
         trc_LibFpFB    := -1 * bal_TX_ON_FB_YTD;
         trc_LibFpFBOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.LteCalc',30);
      -- Set Cascade Figures and Refund
      trc_FrnBenErn  := trc_NorErn;
      trc_TxbFrnInc  := trc_TxbNorInc;
      trc_TotLibFB   := trc_TotLibNI;
      trc_LibFpFB    := -1 * bal_TX_ON_FB_YTD;
      trc_LibFpFBOvr := TRUE;
   END IF;

-- Travel Allowance
--
   -- Ytd Travel Allowance
   trc_TrvAllYtd := bal_TA_NRFI_YTD + bal_TA_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_TrvAllYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.LteCalc',31);
      -- Travel Earnings
      trc_TrvAllErn := trc_TrvAllYtd + trc_FrnBenErn;
      -- Taxable Travel Income
      trc_TxbTrvInc := trc_TrvAllErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbTrvInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.LteCalc',32);
         -- Tax Liability
         trc_TotLibTA := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbTrvInc);
         trc_LibFyTA  := trc_TotLibTA - least(trc_TotLibTA,trc_TotLibFB);
         trc_TotLibTA := greatest(trc_TotLibTA,trc_TotLibFB);
         trc_LibFpTA  := trc_LibFyTA - bal_TX_ON_TA_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.LteCalc',33);
         -- Set Cascade Figures and Refund
         trc_TotLibTA   := trc_TotLibFB;
         trc_LibFpTA    := -1 * bal_TX_ON_TA_YTD;
         trc_LibFpTAOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.LteCalc',34);
      -- Set Cascade Figures and Refund
      trc_TrvAllErn  := trc_FrnBenErn;
      trc_TxbTrvInc  := trc_TxbFrnInc;
      trc_TotLibTA   := trc_TotLibFB;
      trc_LibFpTA    := -1 * bal_TX_ON_TA_YTD;
      trc_LibFpTAOvr := TRUE;
   END IF;

-- Annual Bonus
--
   -- Ytd Annual Bonus
   trc_AnnBonYtd := bal_AB_NRFI_YTD + bal_AB_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_AnnBonYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.LteCalc',35);
      -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
      -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.LteCalc',36);
         -- Tax Liability
         trc_TotLibAB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnBonInc);
         trc_LibFyAB  := trc_TotLibAB - least(trc_TotLibAB,trc_TotLibTA);
         trc_TotLibAB := greatest(trc_TotLibAB,trc_TotLibTA);
         trc_LibFpAB  := trc_LibFyAB - bal_TX_ON_AB_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.LteCalc',39);
         -- Set Cascade Figures and Refund
         trc_TotLibAB   := trc_TotLibTA;
         trc_LibFpAB    := -1 * bal_TX_ON_AB_YTD;
         trc_LibFpABOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.LteCalc',40);
      -- Set Cascade Figures and Refund
      trc_AnnBonErn    := trc_TrvAllErn;
      trc_TxbAnnBonInc := trc_TxbTrvInc;
      trc_TotLibAB     := trc_TotLibTA;
      trc_LibFpAB      := -1 * bal_TX_ON_AB_YTD;
      trc_LibFpABOvr   := TRUE;
   END IF;

-- Annual Payments
--
   -- Ytd Annual Payments
   trc_AnnPymYtd :=
      ( bal_AA_PRCHD_RVAL_NRFI_YTD   + bal_AA_PRCHD_RVAL_RFI_YTD
      + bal_ANN_BUR_AND_SCH_NRFI_YTD + bal_ANN_BUR_AND_SCH_RFI_YTD
      + bal_AC_NRFI_YTD              + bal_AC_RFI_YTD
      + bal_ANU_FRM_RET_FND_NRFI_YTD + bal_ANU_FRM_RET_FND_RFI_YTD
      + bal_ARES_TRD_NRFI_YTD        + bal_ARES_TRD_RFI_YTD
      + bal_PRCH_ANU_TXB_NRFI_YTD    + bal_PRCH_ANU_TXB_RFI_YTD
      + bal_TXB_AP_NRFI_YTD          + bal_TXB_AP_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnPymYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.LteCalc',41);
      -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
      -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.LteCalc',42);
         -- Tax Liability
         trc_TotLibAP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnPymInc);
         trc_LibFyAP  := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibAB);
         trc_TotLibAP := greatest(trc_TotLibAP,trc_TotLibAB);
         trc_LibFpAP  := trc_LibFyAP - bal_TX_ON_AP_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.LteCalc',45);
         -- Set Cascade Figures and Refund
         trc_TotLibAP   := trc_TotLibAB;
         trc_LibFpAP    := -1 * bal_TX_ON_AP_YTD;
         trc_LibFpAPOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.LteCalc',46);
      -- Set Cascade Figures and Refund
      trc_AnnPymErn    := trc_AnnBonErn;
      trc_TxbAnnPymInc := trc_TxbAnnBonInc;
      trc_TotLibAP     := trc_TotLibAB;
      trc_LibFpAP      := -1 * bal_TX_ON_AP_YTD;
      trc_LibFpAPOvr   := TRUE;
   END IF;

-- Public Office Allowance
--
   -- Ytd Public Office Allowance
   trc_PblOffYtd := bal_PO_NRFI_YTD + bal_PO_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_PblOffYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.LteCalc',47);
      -- Public Office Earnings
      trc_PblOffErn := trc_PblOffYtd;
      -- Tax Liability
      trc_LibFyPO := trc_PblOffErn * glb_ZA_PBL_TX_RTE / 100;
      trc_LibFpPO := trc_LibFyPO -  bal_TX_ON_PO_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.LteCalc',48);
      -- Set Cascade Figures and Refund
      trc_LibFyPO    := 0;
      trc_LibFpPO    := -1 * bal_TX_ON_PO_YTD;
      trc_LibFpPOOvr := TRUE;
   END IF;

-- Net Pay Validation
--
   -- Net Pay of the Employee
   l_Np := bal_NET_PAY_RUN;
   -- Site Limit Check
   IF trc_TxbAnnPymInc + trc_PblOffErn < glb_ZA_SIT_LIM THEN
      hr_utility.set_location('py_za_tx_01032002.LteCalc',49);
      l_Sl := TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.LteCalc',50);
      l_Sl := FALSE;
   END IF;

   py_za_tx_utl_01032002.ValidateTaxOns(p_Rf => l_Sl);

-- Set IT3A Indicator
--
   IF trc_TxbAnnPymInc + trc_PblOffErn >= trc_Threshold THEN
      hr_utility.set_location('py_za_tx_01032002.LteCalc',51);
      trc_It3Ind := 0; -- Over Lim
   ELSE
      hr_utility.set_location('py_za_tx_01032002.LteCalc',52);
      trc_It3Ind := 1; -- Under Lim
   END IF;

   -- Normal Income
   WrtHrTrc('trc_NorIncYtd:    '||to_char(trc_NorIncYtd));
   WrtHrTrc('trc_NorIncPtd:    '||to_char(trc_NorIncPtd));
   WrtHrTrc('trc_NorErn:       '||to_char(trc_NorErn));
   WrtHrTrc('trc_TxbNorInc:    '||to_char(trc_TxbNorInc));
   WrtHrTrc('trc_TotLibNI:     '||to_char(trc_TotLibNI));
   WrtHrTrc('trc_LibFyNI:      '||to_char(trc_LibFyNI));
   WrtHrTrc('trc_LibFpNI:      '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   WrtHrTrc('trc_FrnBenYtd:    '||to_char(trc_FrnBenYtd));
   WrtHrTrc('trc_FrnBenPtd:    '||to_char(trc_FrnBenPtd));
   WrtHrTrc('trc_FrnBenErn:    '||to_char(trc_FrnBenErn));
   WrtHrTrc('trc_TxbFrnInc:    '||to_char(trc_TxbFrnInc));
   WrtHrTrc('trc_TotLibFB:     '||to_char(trc_TotLibFB));
   WrtHrTrc('trc_LibFyFB:      '||to_char(trc_LibFyFB));
   WrtHrTrc('trc_LibFpFB:      '||to_char(trc_LibFpFB));
   -- Travel Allowance
   WrtHrTrc('trc_TrvAllYtd:    '||to_char(trc_TrvAllYtd));
   WrtHrTrc('trc_TrvAllPtd:    '||to_char(trc_TrvAllPtd));
   WrtHrTrc('trc_TrvAllErn:    '||to_char(trc_TrvAllErn));
   WrtHrTrc('trc_TxbTrvInc:    '||to_char(trc_TxbTrvInc));
   WrtHrTrc('trc_TotLibTA:     '||to_char(trc_TotLibTA));
   WrtHrTrc('trc_LibFyTA:      '||to_char(trc_LibFyTA));
   WrtHrTrc('trc_LibFpTA:      '||to_char(trc_LibFpTA));
   -- Annual Bonus
   WrtHrTrc('trc_AnnBonYtd:    '||to_char(trc_AnnBonYtd));
   WrtHrTrc('trc_AnnBonPtd:    '||to_char(trc_AnnBonPtd));
   WrtHrTrc('trc_AnnBonErn:    '||to_char(trc_AnnBonErn));
   WrtHrTrc('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
   WrtHrTrc('trc_TotLibAB:     '||to_char(trc_TotLibAB));
   WrtHrTrc('trc_LibFyAB:      '||to_char(trc_LibFyAB));
   WrtHrTrc('trc_LibFpAB:      '||to_char(trc_LibFpAB));
   -- Annual Payments
   WrtHrTrc('trc_AnnPymYtd:    '||to_char(trc_AnnPymYtd));
   WrtHrTrc('trc_AnnPymPtd:    '||to_char(trc_AnnPymPtd));
   WrtHrTrc('trc_AnnPymErn:    '||to_char(trc_AnnPymErn));
   WrtHrTrc('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   WrtHrTrc('trc_TotLibAP:     '||to_char(trc_TotLibAP));
   WrtHrTrc('trc_LibFyAP:      '||to_char(trc_LibFyAP));
   WrtHrTrc('trc_LibFpAP:      '||to_char(trc_LibFpAP));
   -- Pubilc Office Allowance
   WrtHrTrc('trc_PblOffYtd:    '||to_char(trc_PblOffYtd));
   WrtHrTrc('trc_PblOffPtd:    '||to_char(trc_PblOffPtd));
   WrtHrTrc('trc_PblOffErn:    '||to_char(trc_PblOffErn));
   WrtHrTrc('trc_LibFyPO:      '||to_char(trc_LibFyPO));
   WrtHrTrc('trc_LibFpPO:      '||to_char(trc_LibFpPO));

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'LteCalc: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END LteCalc;
-------------------------------------------------------------------------------
-- SeaCalc                                                                   --
-- Tax Calculation for Seasonal Workers                                      --
-------------------------------------------------------------------------------
PROCEDURE SeaCalc AS
-- Variables
--
   l_Np       BALANCE DEFAULT 0;
   l_65Year   DATE;

BEGIN
   hr_utility.set_location('py_za_tx_01032002.SeaCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'SeaCalc';

-- Period Type Income
--
   trc_TxbIncPtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_RUN + bal_AST_PRCHD_RVAL_RFI_RUN
      + bal_BUR_AND_SCH_NRFI_RUN    + bal_BUR_AND_SCH_RFI_RUN
      + bal_COMM_NRFI_RUN           + bal_COMM_RFI_RUN
      + bal_COMP_ALL_NRFI_RUN       + bal_COMP_ALL_RFI_RUN
      + bal_ENT_ALL_NRFI_RUN        + bal_ENT_ALL_RFI_RUN
      + bal_FREE_ACCOM_NRFI_RUN     + bal_FREE_ACCOM_RFI_RUN
      + bal_FREE_SERV_NRFI_RUN      + bal_FREE_SERV_RFI_RUN
      + bal_LOW_LOANS_NRFI_RUN      + bal_LOW_LOANS_RFI_RUN
      + bal_MLS_AND_VOUCH_NRFI_RUN  + bal_MLS_AND_VOUCH_RFI_RUN
      + bal_MED_PAID_NRFI_RUN       + bal_MED_PAID_RFI_RUN
      + bal_OTHER_TXB_ALL_NRFI_RUN  + bal_OTHER_TXB_ALL_RFI_RUN
      + bal_OVTM_NRFI_RUN           + bal_OVTM_RFI_RUN
      + bal_PYM_DBT_NRFI_RUN        + bal_PYM_DBT_RFI_RUN
      + bal_RES_TRD_NRFI_RUN        + bal_RES_TRD_RFI_RUN
      + bal_RGT_AST_NRFI_RUN        + bal_RGT_AST_RFI_RUN
      + bal_TXB_INC_NRFI_RUN        + bal_TXB_INC_RFI_RUN
      + bal_TXB_PEN_NRFI_RUN        + bal_TXB_PEN_RFI_RUN
      + bal_TEL_ALL_NRFI_RUN        + bal_TEL_ALL_RFI_RUN
      + bal_TOOL_ALL_NRFI_RUN       + bal_TOOL_ALL_RFI_RUN
      + bal_USE_VEH_NRFI_RUN        + bal_USE_VEH_RFI_RUN
      );

-- Check if any Period Income Exists
--
   hr_utility.set_location('py_za_tx_01032002.SeaCalc',2);
   IF trc_TxbIncPtd = 0 THEN -- Pre-Earnings Calc
      hr_utility.set_location('py_za_tx_01032002.SeaCalc',3);
      -- Site Factor
      --
      trc_SitFactor := glb_ZA_WRK_DYS_PR_YR / dbi_SEA_WRK_DYS_WRK;

      -- Tax Rebates, Threshold Figure and Medical Aid
      -- Abatements
      -- Calculate the assignments 65 Year Date
      l_65Year := add_months(dbi_PER_DTE_OF_BRTH,780);

      IF l_65Year BETWEEN dbi_ZA_TX_YR_STRT AND dbi_ZA_TX_YR_END THEN
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',4);
         -- give the extra abatement
         trc_Rebate    := glb_ZA_PRI_TX_RBT + glb_ZA_ADL_TX_RBT;
         trc_Threshold := glb_ZA_SC_TX_THRSHLD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',5);
         -- not eligable for extra abatement
         trc_Rebate    := glb_ZA_PRI_TX_RBT;
         trc_Threshold := glb_ZA_PRI_TX_THRSHLD;
      END IF;

   -- Base Income
   --
      -- Base Income
      trc_BseErn :=
         ( bal_AA_PRCHD_RVAL_NRFI_RUN   + bal_AA_PRCHD_RVAL_RFI_RUN
         + bal_ANN_BUR_AND_SCH_NRFI_RUN + bal_ANN_BUR_AND_SCH_RFI_RUN
         + bal_AC_NRFI_RUN              + bal_AC_RFI_RUN
         + bal_ANU_FRM_RET_FND_NRFI_RUN + bal_ANU_FRM_RET_FND_RFI_RUN
         + bal_ARES_TRD_NRFI_RUN        + bal_ARES_TRD_RFI_RUN
         + bal_PRCH_ANU_TXB_NRFI_RUN    + bal_PRCH_ANU_TXB_RFI_RUN
         + bal_TXB_AP_NRFI_RUN          + bal_TXB_AP_RFI_RUN
         );
      -- Taxable Base Income
      trc_TxbBseInc := trc_BseErn * trc_SitFactor;
      -- Threshold Check
      IF trc_TxbBseInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',6);
         -- Tax Liability
         trc_TotLibBse := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbBseInc);
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',7);
         trc_TotLibBse := 0;
      END IF;

   -- Annual Payments
   --
      -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_BseErn + trc_TxbBseInc;-- AP was taken as base!
      -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',8);
         -- Tax Liability
         trc_TotLibAP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnPymInc);
         trc_LibFpAP  := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibBse);
      ElSE
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',9);
         trc_LibFpAP := 0;
      END IF;

      -- Base Income
      WrtHrTrc('trc_BseErn: '      ||to_char(trc_BseErn));
      WrtHrTrc('trc_TxbBseInc: '   ||to_char(trc_TxbBseInc));
      WrtHrTrc('trc_TotLibBse: '   ||to_char(trc_TotLibBse));

      -- Annual Payments
      WrtHrTrc('trc_AnnPymYtd: '   ||to_char(trc_AnnPymYtd));
      WrtHrTrc('trc_AnnPymPtd: '   ||to_char(trc_AnnPymPtd));
      WrtHrTrc('trc_AnnPymErn: '   ||to_char(trc_AnnPymErn));
      WrtHrTrc('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
      WrtHrTrc('trc_TotLibAP: '    ||to_char(trc_TotLibAP));
      WrtHrTrc('trc_LibFyAP: '     ||to_char(trc_LibFyAP));
      WrtHrTrc('trc_LibFpAP: '     ||to_char(trc_LibFpAP));


   ELSE
      hr_utility.set_location('py_za_tx_01032002.SeaCalc',10);
      -- Site Factor
      --
      trc_SitFactor := glb_ZA_WRK_DYS_PR_YR / dbi_SEA_WRK_DYS_WRK;

      -- Rebates
      py_za_tx_utl_01032002.SetRebates;

      -- Abatements
      py_za_tx_utl_01032002.Abatements;

   hr_utility.set_location('py_za_tx_01032002.SeaCalc',11);

   -- Normal Income
   --
      -- Run Normal Income
      trc_NorIncPtd :=
         (bal_COMM_NRFI_RUN           + bal_COMM_RFI_RUN
         + bal_COMP_ALL_NRFI_RUN      + bal_COMP_ALL_RFI_RUN
         + bal_ENT_ALL_NRFI_RUN       + bal_ENT_ALL_RFI_RUN
         + bal_OTHER_TXB_ALL_NRFI_RUN + bal_OTHER_TXB_ALL_RFI_RUN
         + bal_OVTM_NRFI_RUN          + bal_OVTM_RFI_RUN
         + bal_RES_TRD_NRFI_RUN       + bal_RES_TRD_RFI_RUN
         + bal_TXB_INC_NRFI_RUN       + bal_TXB_INC_RFI_RUN
         + bal_TXB_PEN_NRFI_RUN       + bal_TXB_PEN_RFI_RUN
         + bal_TEL_ALL_NRFI_RUN       + bal_TEL_ALL_RFI_RUN
         + bal_TOOL_ALL_NRFI_RUN      + bal_TOOL_ALL_RFI_RUN
         );
      -- Skip the calculation if there is No Income
      IF trc_NorIncPtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',12);
         -- Normal Earnings
         trc_NorErn := trc_NorIncPtd * trc_SitFactor;
         -- Taxable Normal Income
         trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;
         -- Threshold Check
         IF trc_TxbNorInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032002.SeaCalc',13);
            -- Tax Liability
            trc_TotLibNI := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbNorInc);
            trc_LibFyNI  := trc_TotLibNI - 0;
            trc_TotLibNI := greatest(trc_TotLibNI,0);
            trc_LibFpNI  := trc_LibFyNI / trc_SitFactor;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.SeaCalc',14);
            trc_TotLibNI := 0;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',15);
         trc_NorErn    := 0;
         trc_TxbNorInc := 0;
         trc_TotLibNI  := 0;
      END IF;

   -- Fringe Benefits
   --
      -- Run Fringe Benefits
      trc_FrnBenPtd :=
         ( bal_AST_PRCHD_RVAL_NRFI_RUN + bal_AST_PRCHD_RVAL_RFI_RUN
         + bal_BUR_AND_SCH_NRFI_RUN    + bal_BUR_AND_SCH_RFI_RUN
         + bal_FREE_ACCOM_NRFI_RUN     + bal_FREE_ACCOM_RFI_RUN
         + bal_FREE_SERV_NRFI_RUN      + bal_FREE_SERV_RFI_RUN
         + bal_LOW_LOANS_NRFI_RUN      + bal_LOW_LOANS_RFI_RUN
         + bal_MLS_AND_VOUCH_NRFI_RUN  + bal_MLS_AND_VOUCH_RFI_RUN
         + bal_MED_PAID_NRFI_RUN       + bal_MED_PAID_RFI_RUN
         + bal_PYM_DBT_NRFI_RUN        + bal_PYM_DBT_RFI_RUN
         + bal_RGT_AST_NRFI_RUN        + bal_RGT_AST_RFI_RUN
         + bal_USE_VEH_NRFI_RUN        + bal_USE_VEH_RFI_RUN
         );

      -- Skip the calculation if there is No Income
      IF trc_FrnBenPtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',16);
         -- Fringe Benefit Earnings
         trc_FrnBenErn := trc_FrnBenPtd * trc_SitFactor + trc_NorErn;
         -- Taxable Fringe Income
         trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
         -- Threshold Check
         IF trc_TxbFrnInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032002.SeaCalc',17);
            -- Tax Liability
            trc_TotLibFB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbFrnInc);
            trc_LibFyFB  := trc_TotLibFB - least(trc_TotLibFB,trc_TotLibNI);
            trc_TotLibFB := greatest(trc_TotLibFB,trc_TotLibNI);
            trc_LibFpFB  := trc_LibFyFB / trc_SitFactor;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.SeaCalc',18);
            trc_TotLibFB := trc_TotLibNI;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',19);
         trc_FrnBenErn := trc_NorErn;
         trc_TxbFrnInc := trc_TxbNorInc;
         trc_TotLibFB  := trc_TotLibNI;
      END IF;

   -- Annual Payments
   --
      -- Run Annual Payments
      trc_AnnPymPtd :=
         ( bal_AA_PRCHD_RVAL_NRFI_RUN   + bal_AA_PRCHD_RVAL_RFI_RUN
         + bal_ANN_BUR_AND_SCH_NRFI_RUN + bal_ANN_BUR_AND_SCH_RFI_RUN
         + bal_AC_NRFI_RUN              + bal_AC_RFI_RUN
         + bal_ANU_FRM_RET_FND_NRFI_RUN + bal_ANU_FRM_RET_FND_RFI_RUN
         + bal_ARES_TRD_NRFI_RUN        + bal_ARES_TRD_RFI_RUN
         + bal_PRCH_ANU_TXB_NRFI_RUN    + bal_PRCH_ANU_TXB_RFI_RUN
         + bal_TXB_AP_NRFI_RUN          + bal_TXB_AP_RFI_RUN
         );
      -- Skip the calculation if there is No Income
      IF trc_AnnPymPtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',20);
         -- Annual Payments Earnings
         trc_AnnPymErn := trc_AnnPymPtd + trc_FrnBenErn;
         -- Taxable Annual Payments Income
         trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
         -- Threshold Check
         IF trc_TxbAnnPymInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032002.SeaCalc',21);
            -- Tax Liability
            trc_TotLibAP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnPymInc);
            trc_LibFyAP  := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibFB);
            trc_TotLibAP := greatest(trc_TotLibAP,trc_TotLibFB);
            trc_LibFpAP  := trc_LibFyAP;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.SeaCalc',22);
            trc_TotLibAP := trc_TotLibFB;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',23);
         trc_AnnPymErn    := trc_FrnBenErn;
         trc_TxbAnnPymInc := trc_TxbFrnInc;
         trc_TotLibAP     := trc_TotLibFB;
      END IF;


   -- Net Pay Validation
   --
      py_za_tx_utl_01032002.ValidateTaxOns;

   hr_utility.set_location('py_za_tx_01032002.SeaCalc',24);

   -- Set IT3A Indicator
   --
      IF trc_TxbAnnPymInc + trc_PblOffErn >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',25);
         trc_It3Ind := 0; -- Over Lim
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SeaCalc',26);
         trc_It3Ind := 1; -- Under Lim
      END IF;
   END IF;

   -- Normal Income
   WrtHrTrc('trc_NorIncYtd:    '||to_char(trc_NorIncYtd));
   WrtHrTrc('trc_NorIncPtd:    '||to_char(trc_NorIncPtd));
   WrtHrTrc('trc_NorErn:       '||to_char(trc_NorErn));
   WrtHrTrc('trc_TxbNorInc:    '||to_char(trc_TxbNorInc));
   WrtHrTrc('trc_TotLibNI:     '||to_char(trc_TotLibNI));
   WrtHrTrc('trc_LibFyNI:      '||to_char(trc_LibFyNI));
   WrtHrTrc('trc_LibFpNI:      '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   WrtHrTrc('trc_FrnBenYtd:    '||to_char(trc_FrnBenYtd));
   WrtHrTrc('trc_FrnBenPtd:    '||to_char(trc_FrnBenPtd));
   WrtHrTrc('trc_FrnBenErn:    '||to_char(trc_FrnBenErn));
   WrtHrTrc('trc_TxbFrnInc:    '||to_char(trc_TxbFrnInc));
   WrtHrTrc('trc_TotLibFB:     '||to_char(trc_TotLibFB));
   WrtHrTrc('trc_LibFyFB:      '||to_char(trc_LibFyFB));
   WrtHrTrc('trc_LibFpFB:      '||to_char(trc_LibFpFB));
   -- Annual Payments
   WrtHrTrc('trc_AnnPymYtd:    '||to_char(trc_AnnPymYtd));
   WrtHrTrc('trc_AnnPymPtd:    '||to_char(trc_AnnPymPtd));
   WrtHrTrc('trc_AnnPymErn:    '||to_char(trc_AnnPymErn));
   WrtHrTrc('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   WrtHrTrc('trc_TotLibAP:     '||to_char(trc_TotLibAP));
   WrtHrTrc('trc_LibFyAP:      '||to_char(trc_LibFyAP));
   WrtHrTrc('trc_LibFpAP:      '||to_char(trc_LibFpAP));

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'SeaCalc: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END SeaCalc;

-------------------------------------------------------------------------------
-- SitCalc                                                                   --
-- End of Year Tax Calculation                                               --
-------------------------------------------------------------------------------
PROCEDURE SitCalc AS
-- Variables
--
   l_Sl       BOOLEAN;
   l_Np       BALANCE;

BEGIN
   hr_utility.set_location('py_za_tx_01032002.SitCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'SitCalc';

-- Update Global Balance Values with correct TAXABLE values
--
   py_za_tx_utl_01032002.TrvAll;

   hr_utility.set_location('py_za_tx_01032002.SitCalc',2);

   bal_PO_RFI_YTD  := bal_PO_RFI_YTD * glb_ZA_PBL_TX_PRC / 100;
   bal_PO_NRFI_YTD := bal_PO_NRFI_YTD * glb_ZA_PBL_TX_PRC / 100;

-- Ytd Taxable Income
--
   trc_TxbIncYtd :=
   ( bal_AST_PRCHD_RVAL_NRFI_YTD + bal_AST_PRCHD_RVAL_RFI_YTD
   + bal_BP_YTD
   + bal_BUR_AND_SCH_NRFI_YTD    + bal_BUR_AND_SCH_RFI_YTD
   + bal_COMM_NRFI_YTD           + bal_COMM_RFI_YTD
   + bal_COMP_ALL_NRFI_YTD       + bal_COMP_ALL_RFI_YTD
   + bal_ENT_ALL_NRFI_YTD        + bal_ENT_ALL_RFI_YTD
   + bal_FREE_ACCOM_NRFI_YTD     + bal_FREE_ACCOM_RFI_YTD
   + bal_FREE_SERV_NRFI_YTD      + bal_FREE_SERV_RFI_YTD
   + bal_LOW_LOANS_NRFI_YTD      + bal_LOW_LOANS_RFI_YTD
   + bal_MLS_AND_VOUCH_NRFI_YTD  + bal_MLS_AND_VOUCH_RFI_YTD
   + bal_MED_PAID_NRFI_YTD       + bal_MED_PAID_RFI_YTD
   + bal_OTHER_TXB_ALL_NRFI_YTD  + bal_OTHER_TXB_ALL_RFI_YTD
   + bal_OVTM_NRFI_YTD           + bal_OVTM_RFI_YTD
   + bal_PYM_DBT_NRFI_YTD        + bal_PYM_DBT_RFI_YTD
   + bal_RES_TRD_NRFI_YTD        + bal_RES_TRD_RFI_YTD
   + bal_RGT_AST_NRFI_YTD        + bal_RGT_AST_RFI_YTD
   + bal_TXB_INC_NRFI_YTD        + bal_TXB_INC_RFI_YTD
   + bal_TXB_PEN_NRFI_YTD        + bal_TXB_PEN_RFI_YTD
   + bal_TEL_ALL_NRFI_YTD        + bal_TEL_ALL_RFI_YTD
   + bal_TOOL_ALL_NRFI_YTD       + bal_TOOL_ALL_RFI_YTD
   + bal_TA_NRFI_YTD             + bal_TA_RFI_YTD
   + bal_USE_VEH_NRFI_YTD        + bal_USE_VEH_RFI_YTD
   );

   hr_utility.set_location('py_za_tx_01032002.SitCalc',3);

-- Site Factor
--
   trc_SitFactor := dbi_ZA_DYS_IN_YR / py_za_tx_utl_01032002.DaysWorked;

   hr_utility.set_location('py_za_tx_01032002.SitCalc',4);

-- Rebates
   py_za_tx_utl_01032002.SetRebates;

-- Abatements
   py_za_tx_utl_01032002.Abatements;

   hr_utility.set_location('py_za_tx_01032002.SitCalc',5);

-- Deemed Remuneration
--
   -- Run Deemed Remuneration
   trc_DmdRmnRun := bal_DIR_DMD_RMN_ITD;

   -- Skip the calculation if there is No Income
   IF trc_DmdRmnRun <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.SitCalc',6);
      -- Taxable Deemed Remuneration
      trc_TxbDmdRmn := trc_DmdRmnRun;
      -- Threshold Check
      IF trc_TxbDmdRmn >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.SitCalc',7);
         -- Tax Liability
         trc_TotLibDR := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbDmdRmn);
         trc_LibFyDR  := (trc_TotLibDR - 0) / trc_SitFactor;
         trc_TotLibDR := greatest(trc_TotLibDR,0);
         trc_LibFpDR  := trc_LibFyDR - bal_TX_ON_DR_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SitCalc',8);
         -- Set Cascade Figures and Refund
         trc_TotLibDR   := 0;
         trc_LibFpDR    := -1 * bal_TX_ON_DR_YTD;
         trc_LibFpDROvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.SitCalc',9);
      -- Set Cascade Figures and Refund
      trc_TxbDmdRmn  := 0;
      trc_TotLibDR   := 0;
      trc_LibFpDR    := -1 * bal_TX_ON_DR_YTD;
      trc_LibFpDROvr := TRUE;
   END IF;

   hr_utility.set_location('py_za_tx_01032002.SitCalc',10);

-- Normal Income
--
   -- Ytd Normal Income
   trc_NorIncYtd :=
      ( bal_COMM_NRFI_YTD          + bal_COMM_RFI_YTD
      + bal_COMP_ALL_NRFI_YTD      + bal_COMP_ALL_RFI_YTD
      + bal_ENT_ALL_NRFI_YTD       + bal_ENT_ALL_RFI_YTD
      + bal_OTHER_TXB_ALL_NRFI_YTD + bal_OTHER_TXB_ALL_RFI_YTD
      + bal_OVTM_NRFI_YTD          + bal_OVTM_RFI_YTD
      + bal_RES_TRD_NRFI_YTD       + bal_RES_TRD_RFI_YTD
      + bal_TXB_INC_NRFI_YTD       + bal_TXB_INC_RFI_YTD
      + bal_TXB_PEN_NRFI_YTD       + bal_TXB_PEN_RFI_YTD
      + bal_TEL_ALL_NRFI_YTD       + bal_TEL_ALL_RFI_YTD
      + bal_TOOL_ALL_NRFI_YTD      + bal_TOOL_ALL_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_NorIncYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.SitCalc',11);
      -- Normal Earnings
      trc_NorErn := trc_NorIncYtd * trc_SitFactor;
      -- Taxable Normal Income
      trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbNorInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.SitCalc',12);
         -- Tax Liability
         trc_TotLibNI := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbNorInc);
         trc_LibFyNI  := (trc_TotLibNI - least(trc_TotLibNI,trc_TotLibDR)) / trc_SitFactor;
         trc_TotLibNI := greatest(trc_TotLibNI,trc_TotLibDR);
         trc_LibFpNI  := trc_LibFyNI - bal_TX_ON_NI_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SitCalc',13);
         -- Set Cascade Figures and Refund
         trc_TotLibNI   := trc_TotLibDR;
         trc_LibFpNI    := -1 * bal_TX_ON_NI_YTD;
         trc_LibFpNIOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.SitCalc',14);
      -- Set Cascade Figures and Refund
      trc_NorErn     := 0;
      trc_TxbNorInc  := 0;
      trc_TotLibNI   := trc_TotLibDR;
      trc_LibFpNI    := -1 * bal_TX_ON_NI_YTD;
      trc_LibFpNIOvr := TRUE;
   END IF;

-- Fringe Benefits
--
   -- Ytd Fringe Benefits
   trc_FrnBenYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_YTD + bal_AST_PRCHD_RVAL_RFI_YTD
      + bal_BUR_AND_SCH_NRFI_YTD    + bal_BUR_AND_SCH_RFI_YTD
      + bal_FREE_ACCOM_NRFI_YTD     + bal_FREE_ACCOM_RFI_YTD
      + bal_FREE_SERV_NRFI_YTD      + bal_FREE_SERV_RFI_YTD
      + bal_LOW_LOANS_NRFI_YTD      + bal_LOW_LOANS_RFI_YTD
      + bal_MLS_AND_VOUCH_NRFI_YTD  + bal_MLS_AND_VOUCH_RFI_YTD
      + bal_MED_PAID_NRFI_YTD       + bal_MED_PAID_RFI_YTD
      + bal_PYM_DBT_NRFI_YTD        + bal_PYM_DBT_RFI_YTD
      + bal_RGT_AST_NRFI_YTD        + bal_RGT_AST_RFI_YTD
      + bal_USE_VEH_NRFI_YTD        + bal_USE_VEH_RFI_YTD
      );

   -- Skip the calculation if there is No Income
   IF trc_FrnBenYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.SitCalc',15);
      -- Fringe Benefit Earnings
      trc_FrnBenErn := trc_FrnBenYtd * trc_SitFactor + trc_NorErn;
      -- Taxable Fringe Income
      trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbFrnInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.SitCalc',16);
         -- Tax Liability
         trc_TotLibFB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbFrnInc);
         trc_LibFyFB  := (trc_TotLibFB - least(trc_TotLibFB,trc_TotLibNI)) / trc_SitFactor;
         trc_TotLibFB := greatest(trc_TotLibFB,trc_TotLibNI);
         trc_LibFpFB  := trc_LibFyFB - bal_TX_ON_FB_YTD;
      ElSE
         hr_utility.set_location('py_za_tx_01032002.SitCalc',17);
         -- Set Cascade Figures and Refund
         trc_TotLibFB   := trc_TotLibNI;
         trc_LibFpFB    := -1 * bal_TX_ON_FB_YTD;
         trc_LibFpFBOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.SitCalc',18);
      -- Set Cascade Figures and Refund
      trc_FrnBenErn  := trc_NorErn;
      trc_TxbFrnInc  := trc_TxbNorInc;
      trc_TotLibFB   := trc_TotLibNI;
      trc_LibFpFB    := -1 * bal_TX_ON_FB_YTD;
      trc_LibFpFBOvr := TRUE;
   END IF;

-- Travel Allowance
--
   -- Ytd Travel Allowance
   trc_TrvAllYtd := bal_TA_NRFI_YTD + bal_TA_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_TrvAllYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.SitCalc',19);
      -- Travel Earnings
      trc_TrvAllErn := trc_TrvAllYtd * trc_SitFactor + trc_FrnBenErn;
      -- Taxable Travel Income
      trc_TxbTrvInc := trc_TrvAllErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbTrvInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.SitCalc',20);
         -- Tax Liability
         trc_TotLibTA := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbTrvInc);
         trc_LibFyTA  := (trc_TotLibTA - least(trc_TotLibTA,trc_TotLibFB)) / trc_SitFactor;
         trc_TotLibTA := greatest(trc_TotLibTA,trc_TotLibFB);
         trc_LibFpTA  := trc_LibFyTA - bal_TX_ON_TA_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SitCalc',21);
         -- Set Cascade Figures and Refund
         trc_TotLibTA   := trc_TotLibFB;
         trc_LibFpTA    := -1 * bal_TX_ON_TA_YTD;
         trc_LibFpTAOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.SitCalc',22);
      -- Set Cascade Figures and Refund
      trc_TrvAllErn  := trc_FrnBenErn;
      trc_TxbTrvInc  := trc_TxbFrnInc;
      trc_TotLibTA   := trc_TotLibFB;
      trc_LibFpTA    := -1 * bal_TX_ON_TA_YTD;
      trc_LibFpTAOvr := TRUE;
   END IF;

-- Bonus Provision
--
   -- Ytd Bonus Prvision
   trc_BonProYtd := bal_BP_YTD;
   -- Skip the calculation if there is No Income
   IF trc_BonProYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.SitCalc',23);
      -- Bonus Provision Earnings
      trc_BonProErn := trc_BonProYtd * trc_SitFactor + trc_TrvAllErn;
      -- Taxable Bonus Provision Income
      trc_TxbBonProInc := trc_BonProErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbBonProInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.SitCalc',24);
         -- Tax Liability
         trc_TotLibBP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbBonProInc);
         trc_LibFyBP  := (trc_TotLibBP - least(trc_TotLibBP,trc_TotLibTA)) / trc_SitFactor;
         trc_TotLibBP := greatest(trc_TotLibBP,trc_TotLibTA);
         trc_LibFpBP  := trc_LibFyBP - bal_TX_ON_BP_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SitCalc',25);
         -- Set Cascade Figures and Refund
         trc_TotLibBP   := trc_TotLibTA;
         trc_LibFpBP    := -1 * bal_TX_ON_BP_YTD;
         trc_LibFpBPOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.SitCalc',26);
      -- Set Cascade Figures and Refund
      trc_BonProErn    := trc_TrvAllErn;
      trc_TxbBonProInc := trc_TxbTrvInc;
      trc_TotLibBP     := trc_TotLibTA;
      trc_LibFpBP      := -1 * bal_TX_ON_BP_YTD;
      trc_LibFpBPOvr   := TRUE;
   END IF;

-- Annual Bonus
--
   -- Ytd Annual Bonus
   trc_AnnBonYtd := bal_AB_NRFI_YTD + bal_AB_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_AnnBonYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.SitCalc',27);
      -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
      -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.SitCalc',28);
         -- Tax Liability
         trc_TotLibAB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnBonInc);
         trc_LibFyAB := trc_TotLibAB - least(trc_TotLibAB,trc_TotLibTA);
         trc_TotLibAB := greatest(trc_TotLibAB,trc_TotLibTA);
         hr_utility.set_location('py_za_tx_01032002.SitCalc',29);
         -- Check Bonus Provision
         IF trc_BonProYtd <> 0 THEN
            hr_utility.set_location('py_za_tx_01032002.SitCalc',30);
            -- Check Bonus Provision Frequency
            IF dbi_BP_TX_RCV = 'B' OR py_za_tx_utl_01032002.SitePeriod THEN
               hr_utility.set_location('py_za_tx_01032002.SitCalc',31);
               trc_LibFpAB :=
               trc_LibFyAB - (bal_TX_ON_BP_YTD
                             + trc_LibFpBP
                             + bal_TX_ON_AB_YTD);
            ELSE
               hr_utility.set_location('py_za_tx_01032002.SitCalc',32);
               trc_LibFpAB := 0;
            END IF;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.SitCalc',33);
            trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SitCalc',34);
         -- Set Cascade Figures and Refund
         trc_TotLibAB   := trc_TotLibTA;
         trc_LibFpAB    := -1 * bal_TX_ON_AB_YTD;
         trc_LibFpABOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.SitCalc',35);
      -- Set Cascade Figures and Refund
      trc_LibFpAB      := -1 * bal_TX_ON_AB_YTD;
      trc_LibFpABOvr   := TRUE;

      IF dbi_BP_TX_RCV = 'A' AND py_za_tx_utl_01032002.SitePeriod THEN
         hr_utility.set_location('py_za_tx_01032002.SitCalc',36);
         trc_LibFpBP      := -1 * bal_TX_ON_BP_YTD;
         trc_LibFpBPOvr   := TRUE;
         trc_LibFpAPOvr   := TRUE;

         trc_AnnBonErn    := trc_TrvAllErn;
         trc_TxbAnnBonInc := trc_TxbTrvInc;
         trc_TotLibAB     := trc_TotLibTA;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SitCalc',37);
         trc_AnnBonErn    := trc_BonProErn;
         trc_TxbAnnBonInc := trc_TxbBonProInc;
         trc_TotLibAB     := trc_TotLibBP;
      END IF;
   END IF;

-- Annual Payments
--
   -- Ytd Annual Payments
   trc_AnnPymYtd :=
      ( bal_AA_PRCHD_RVAL_NRFI_YTD   + bal_AA_PRCHD_RVAL_RFI_YTD
      + bal_ANN_BUR_AND_SCH_NRFI_YTD + bal_ANN_BUR_AND_SCH_RFI_YTD
      + bal_AC_NRFI_YTD              + bal_AC_RFI_YTD
      + bal_ANU_FRM_RET_FND_NRFI_YTD + bal_ANU_FRM_RET_FND_RFI_YTD
      + bal_ARES_TRD_NRFI_YTD        + bal_ARES_TRD_RFI_YTD
      + bal_PRCH_ANU_TXB_NRFI_YTD    + bal_PRCH_ANU_TXB_RFI_YTD
      + bal_TXB_AP_NRFI_YTD          + bal_TXB_AP_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnPymYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.SitCalc',38);
      -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
      -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.SitCalc',39);
         -- Tax Liability
         trc_TotLibAP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnPymInc);
         trc_LibFyAP  := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibAB);
         trc_TotLibAP := greatest(trc_TotLibAP,trc_TotLibAB);
         trc_LibFpAP  := trc_LibFyAP - bal_TX_ON_AP_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.SitCalc',40);
         -- Set Cascade Figures and Refund
         trc_TotLibAP   := trc_TotLibAB;
         trc_LibFpAP    := -1 * bal_TX_ON_AP_YTD;
         trc_LibFpAPOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.SitCalc',41);
      -- Set Cascade Figures and Refund
      trc_AnnPymErn    := trc_AnnBonErn;
      trc_TxbAnnPymInc := trc_TxbAnnBonInc;
      trc_TotLibAP     := trc_TotLibAB;
      trc_LibFpAP      := -1 * bal_TX_ON_AP_YTD;
      trc_LibFpAPOvr   := TRUE;
   END IF;

-- Public Office Allowance
--
   -- Ytd Public Office Allowance
   trc_PblOffYtd := bal_PO_NRFI_YTD + bal_PO_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_PblOffYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.SitCalc',42);
      -- Public Office Earnings
      trc_PblOffErn := trc_PblOffYtd * trc_SitFactor;
      -- Tax Liability
      trc_LibFyPO := (trc_PblOffErn * glb_ZA_PBL_TX_RTE / 100)/trc_SitFactor;
      trc_LibFpPO := trc_LibFyPO -  bal_TX_ON_PO_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.SitCalc',43);
      -- Set Cascade Figures and Refund
      trc_LibFyPO    := 0;
      trc_LibFpPO    := -1 * bal_TX_ON_PO_YTD;
      trc_LibFpPOOvr := TRUE;
   END IF;

-- Net Pay Validation
--
   -- Net Pay of the Employee
   l_Np := bal_NET_PAY_RUN;
   -- Site Limit Check
   IF trc_TxbAnnPymInc + trc_PblOffErn < glb_ZA_SIT_LIM THEN
      hr_utility.set_location('py_za_tx_01032002.SitCalc',44);
      l_Sl := TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.SitCalc',45);
      l_Sl := FALSE;
   END IF;

   py_za_tx_utl_01032002.ValidateTaxOns(p_Rf => l_Sl);

   hr_utility.set_location('py_za_tx_01032002.SitCalc',46);

-- Set IT3A Indicator
--
   IF trc_TxbAnnPymInc + trc_PblOffErn >= trc_Threshold THEN
      hr_utility.set_location('py_za_tx_01032002.SitCalc',47);
      trc_It3Ind := 0; -- Over Lim
   ELSE
      hr_utility.set_location('py_za_tx_01032002.SitCalc',48);
      trc_It3Ind := 1; -- Under Lim
   END IF;

-- Calculate Total Taxable Income and pass out
--
   trc_OUpdFig := (trc_TxbAnnPymInc + trc_PblOffErn) - bal_TOT_TXB_INC_ITD;

   hr_utility.set_location('py_za_tx_01032002.SitCalc',49);

   -- Deemed Remuneration
   WrtHrTrc('trc_TxbDmdRmn:    '||to_char(trc_TxbDmdRmn));
   WrtHrTrc('trc_TotLibDR:     '||to_char(trc_TotLibDR));
   WrtHrTrc('trc_LibFyDR:      '||to_char(trc_LibFyDR));
   WrtHrTrc('trc_LibFpDR:      '||to_char(trc_LibFpDR));
   -- Base Income
   WrtHrTrc('trc_BseErn:       '||to_char(trc_BseErn));
   WrtHrTrc('trc_TxbBseInc:    '||to_char(trc_TxbBseInc));
   WrtHrTrc('trc_TotLibBse:    '||to_char(trc_TotLibBse));
   -- Normal Income
   WrtHrTrc('trc_NorIncYtd:    '||to_char(trc_NorIncYtd));
   WrtHrTrc('trc_NorIncPtd:    '||to_char(trc_NorIncPtd));
   WrtHrTrc('trc_NorErn:       '||to_char(trc_NorErn));
   WrtHrTrc('trc_TxbNorInc:    '||to_char(trc_TxbNorInc));
   WrtHrTrc('trc_TotLibNI:     '||to_char(trc_TotLibNI));
   WrtHrTrc('trc_LibFyNI:      '||to_char(trc_LibFyNI));
   WrtHrTrc('trc_LibFpNI:      '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   WrtHrTrc('trc_FrnBenYtd:    '||to_char(trc_FrnBenYtd));
   WrtHrTrc('trc_FrnBenPtd:    '||to_char(trc_FrnBenPtd));
   WrtHrTrc('trc_FrnBenErn:    '||to_char(trc_FrnBenErn));
   WrtHrTrc('trc_TxbFrnInc:    '||to_char(trc_TxbFrnInc));
   WrtHrTrc('trc_TotLibFB:     '||to_char(trc_TotLibFB));
   WrtHrTrc('trc_LibFyFB:      '||to_char(trc_LibFyFB));
   WrtHrTrc('trc_LibFpFB:      '||to_char(trc_LibFpFB));
   -- Travel Allowance
   WrtHrTrc('trc_TrvAllYtd:    '||to_char(trc_TrvAllYtd));
   WrtHrTrc('trc_TrvAllPtd:    '||to_char(trc_TrvAllPtd));
   WrtHrTrc('trc_TrvAllErn:    '||to_char(trc_TrvAllErn));
   WrtHrTrc('trc_TxbTrvInc:    '||to_char(trc_TxbTrvInc));
   WrtHrTrc('trc_TotLibTA:     '||to_char(trc_TotLibTA));
   WrtHrTrc('trc_LibFyTA:      '||to_char(trc_LibFyTA));
   WrtHrTrc('trc_LibFpTA:      '||to_char(trc_LibFpTA));
   -- Bonus Provision
   WrtHrTrc('trc_BonProYtd:    '||to_char(trc_BonProYtd));
   WrtHrTrc('trc_BonProPtd:    '||to_char(trc_BonProPtd));
   WrtHrTrc('trc_BonProErn:    '||to_char(trc_BonProErn));
   WrtHrTrc('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
   WrtHrTrc('trc_TotLibBP:     '||to_char(trc_TotLibBP));
   WrtHrTrc('trc_LibFyBP:      '||to_char(trc_LibFyBP));
   WrtHrTrc('trc_LibFpBP:      '||to_char(trc_LibFpBP));
   -- Annual Bonus
   WrtHrTrc('trc_AnnBonYtd:    '||to_char(trc_AnnBonYtd));
   WrtHrTrc('trc_AnnBonPtd:    '||to_char(trc_AnnBonPtd));
   WrtHrTrc('trc_AnnBonErn:    '||to_char(trc_AnnBonErn));
   WrtHrTrc('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
   WrtHrTrc('trc_TotLibAB:     '||to_char(trc_TotLibAB));
   WrtHrTrc('trc_LibFyAB:      '||to_char(trc_LibFyAB));
   WrtHrTrc('trc_LibFpAB:      '||to_char(trc_LibFpAB));
   -- Annual Payments
   WrtHrTrc('trc_AnnPymYtd:    '||to_char(trc_AnnPymYtd));
   WrtHrTrc('trc_AnnPymPtd:    '||to_char(trc_AnnPymPtd));
   WrtHrTrc('trc_AnnPymErn:    '||to_char(trc_AnnPymErn));
   WrtHrTrc('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   WrtHrTrc('trc_TotLibAP:     '||to_char(trc_TotLibAP));
   WrtHrTrc('trc_LibFyAP:      '||to_char(trc_LibFyAP));
   WrtHrTrc('trc_LibFpAP:      '||to_char(trc_LibFpAP));

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'SitCalc: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END SitCalc;

-------------------------------------------------------------------------------
-- DirCalc                                                                   --
-- Tax Calculation for Directive Assignments                                 --
-------------------------------------------------------------------------------
PROCEDURE DirCalc AS
-- Variables
--
   l_Np       BALANCE DEFAULT 0;

BEGIN
   hr_utility.set_location('py_za_tx_01032002.DirCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'DirCalc';

-- Update Global Balance Values with correct TAXABLE values
--
   py_za_tx_utl_01032002.TrvAll;

   hr_utility.set_location('py_za_tx_01032002.DirCalc',2);

   bal_PO_RFI_YTD  := bal_PO_RFI_YTD * glb_ZA_PBL_TX_PRC / 100;
   bal_PO_NRFI_YTD := bal_PO_NRFI_YTD * glb_ZA_PBL_TX_PRC / 100;

-- Normal Income
--
   -- Ytd Normal Income
   trc_NorIncYtd :=
      ( bal_COMM_NRFI_YTD          + bal_COMM_RFI_YTD
      + bal_COMP_ALL_NRFI_YTD      + bal_COMP_ALL_RFI_YTD
      + bal_ENT_ALL_NRFI_YTD       + bal_ENT_ALL_RFI_YTD
      + bal_OTHER_TXB_ALL_NRFI_YTD + bal_OTHER_TXB_ALL_RFI_YTD
      + bal_OVTM_NRFI_YTD          + bal_OVTM_RFI_YTD
      + bal_RES_TRD_NRFI_YTD       + bal_RES_TRD_RFI_YTD
      + bal_TXB_INC_NRFI_YTD       + bal_TXB_INC_RFI_YTD
      + bal_TXB_PEN_NRFI_YTD       + bal_TXB_PEN_RFI_YTD
      + bal_TEL_ALL_NRFI_YTD       + bal_TEL_ALL_RFI_YTD
      + bal_TOOL_ALL_NRFI_YTD      + bal_TOOL_ALL_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_NorIncYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',3);
      -- Normal Earnings
      trc_NorErn := trc_NorIncYtd;
      -- Tax Liability
      trc_TotLibNI := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_NorErn);
      trc_LibFyNI  := trc_TotLibNI - 0;
      trc_TotLibNI := greatest(trc_TotLibNI,0);
      trc_LibFpNI  := trc_LibFyNI - bal_TX_ON_NI_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.DirCalc',4);
      -- Set Cascade Figures and Refund
      trc_NorErn     := 0;
      trc_TotLibNI   := 0;
      trc_LibFpNI    := -1 * bal_TX_ON_NI_YTD;
      trc_LibFpNIOvr := TRUE;
   END IF;

-- Fringe Benefits
--
   -- Ytd Fringe Benefits
   trc_FrnBenYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_YTD + bal_AST_PRCHD_RVAL_RFI_YTD
      + bal_BUR_AND_SCH_NRFI_YTD    + bal_BUR_AND_SCH_RFI_YTD
      + bal_FREE_ACCOM_NRFI_YTD     + bal_FREE_ACCOM_RFI_YTD
      + bal_FREE_SERV_NRFI_YTD      + bal_FREE_SERV_RFI_YTD
      + bal_LOW_LOANS_NRFI_YTD      + bal_LOW_LOANS_RFI_YTD
      + bal_MLS_AND_VOUCH_NRFI_YTD  + bal_MLS_AND_VOUCH_RFI_YTD
      + bal_MED_PAID_NRFI_YTD       + bal_MED_PAID_RFI_YTD
      + bal_PYM_DBT_NRFI_YTD        + bal_PYM_DBT_RFI_YTD
      + bal_RGT_AST_NRFI_YTD        + bal_RGT_AST_RFI_YTD
      + bal_USE_VEH_NRFI_YTD        + bal_USE_VEH_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_FrnBenYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',5);
      -- Fringe Benefit Earnings
      trc_FrnBenErn := trc_FrnBenYtd + trc_NorErn;
      -- Tax Liability
      trc_TotLibFB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_FrnBenErn);
      trc_LibFyFB  := trc_TotLibFB - least(trc_TotLibFB,trc_TotLibNI);
      trc_TotLibFB := greatest(trc_TotLibFB,trc_TotLibNI);
      trc_LibFpFB  := trc_LibFyFB - bal_TX_ON_FB_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.DirCalc',6);
      -- Set Cascade Figures and Refund
      trc_FrnBenErn  := trc_NorErn;
      trc_TotLibFB   := trc_TotLibNI;
      trc_LibFpFB    := -1 * bal_TX_ON_FB_YTD;
      trc_LibFpFBOvr := TRUE;
   END IF;

-- Travel Allowance
--
   -- Ytd Travel Allowance
   trc_TrvAllYtd := bal_TA_NRFI_YTD + bal_TA_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_TrvAllYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',7);
      -- Travel Allowance Earnings
      trc_TrvAllErn := trc_TrvAllYtd + trc_FrnBenErn;
      -- Tax Liability
      trc_TotLibTA := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TrvAllErn);
      trc_LibFyTA  := trc_TotLibTA - least(trc_TotLibTA,trc_TotLibFB);
      trc_TotLibTA := greatest(trc_TotLibTA,trc_TotLibFB);
      trc_LibFpTA  := trc_LibFyTA - bal_TX_ON_TA_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.DirCalc',8);
      -- Set Cascade Figures and Refund
      trc_TrvAllErn  := trc_FrnBenErn; --Cascade Figure
      trc_TotLibTA   := trc_TotLibFB;
      trc_LibFpTA    := -1 * bal_TX_ON_TA_YTD;
      trc_LibFpTAOvr := TRUE;
   END IF;

-- Bonus Provision
--
   -- Ytd Bonus Provision
   trc_BonProYtd := bal_BP_YTD;
   -- Skip the calculation if there is No Income
   IF trc_BonProYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',9);
      -- Bonus Provision Earnings
      trc_BonProErn := trc_BonProYtd + trc_TrvAllErn;
      -- Tax Liability
      trc_TotLibBP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_BonProErn);
      trc_LibFyBP  := trc_TotLibBP - least(trc_TotLibBP,trc_TotLibTA);
      trc_TotLibBP := greatest(trc_TotLibBP,trc_TotLibTA);
      trc_LibFpBP  := trc_LibFyBP - bal_TX_ON_BP_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.DirCalc',10);
      -- Set Cascade Figures and Refund
      trc_BonProErn  := trc_TrvAllErn;
      trc_TotLibBP   := trc_TotLibTA;
      trc_LibFpBP    := -1 * bal_TX_ON_BP_YTD;
      trc_LibFpBPOvr := TRUE;
   END IF;

-- Annual Bonus
--
   -- Ytd Annual Bonus
   trc_AnnBonYtd := bal_AB_NRFI_YTD + bal_AB_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_AnnBonYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',11);
      -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
      -- Tax Liability
      trc_TotLibAB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_AnnBonErn);
      trc_LibFyAB  := trc_TotLibAB - least(trc_TotLibAB,trc_TotLibTA);
      trc_TotLibAB := greatest(trc_TotLibAB,trc_TotLibTA);
      -- Check Bonus Provision
      IF trc_BonProYtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032002.DirCalc',12);
         -- Check Bonus Provision Frequency
         IF dbi_BP_TX_RCV = 'B' OR py_za_tx_utl_01032002.SitePeriod THEN
            hr_utility.set_location('py_za_tx_01032002.DirCalc',13);
            trc_LibFpAB :=
            trc_LibFyAB - (bal_TX_ON_BP_YTD
                          + trc_LibFpBP
                          + bal_TX_ON_AB_YTD);
         ELSE
            hr_utility.set_location('py_za_tx_01032002.DirCalc',14);
            trc_LibFpAB := 0;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.DirCalc',15);
         trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.DirCalc',16);
      -- Set Cascade Figures and Refund
      trc_LibFpAB    := -1 * bal_TX_ON_AB_YTD;
      trc_LibFpABOvr := TRUE;

      IF dbi_BP_TX_RCV = 'A' AND py_za_tx_utl_01032002.SitePeriod THEN
         hr_utility.set_location('py_za_tx_01032002.DirCalc',17);
         trc_LibFpBP    := -1 * bal_TX_ON_BP_YTD;
         trc_LibFpBPOvr := TRUE;
         trc_LibFpAPOvr := TRUE;

         trc_AnnBonErn  := trc_TrvAllErn;
         trc_TotLibAB   := trc_TotLibTA;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.DirCalc',18);
         trc_AnnBonErn  := trc_BonProErn;
         trc_TotLibAB   := trc_TotLibBP;
      END IF;
   END IF;

-- Annual Payments
--
   -- Ytd Annual Payments
   trc_AnnPymYtd :=
      ( bal_AA_PRCHD_RVAL_NRFI_YTD   + bal_AA_PRCHD_RVAL_RFI_YTD
      + bal_ANN_BUR_AND_SCH_NRFI_YTD + bal_ANN_BUR_AND_SCH_RFI_YTD
      + bal_AC_NRFI_YTD              + bal_AC_RFI_YTD
      + bal_ANU_FRM_RET_FND_NRFI_YTD + bal_ANU_FRM_RET_FND_RFI_YTD
      + bal_ARES_TRD_NRFI_YTD        + bal_ARES_TRD_RFI_YTD
      + bal_PRCH_ANU_TXB_NRFI_YTD    + bal_PRCH_ANU_TXB_RFI_YTD
      + bal_TXB_AP_NRFI_YTD          + bal_TXB_AP_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnPymYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',19);
      -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
      -- Tax Liability
      trc_TotLibAP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_AnnPymErn);
      trc_LibFyAP  := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibAB);
      trc_TotLibAP := greatest(trc_TotLibAP,trc_TotLibAB);
      trc_LibFpAP  := trc_LibFyAP - bal_TX_ON_AP_YTD;
   ElSE
      hr_utility.set_location('py_za_tx_01032002.DirCalc',20);
      -- Set Cascade Figures and Refund
      trc_AnnPymErn  := trc_AnnBonErn;
      trc_TotLibAP   := trc_TotLibAB;
      trc_LibFpAP    := -1 * bal_TX_ON_AP_YTD;
      trc_LibFpAPOvr := TRUE;
   END IF;

-- Public Office Allowance
--
   -- Ytd Public Office Allowance
   trc_PblOffYtd := bal_PO_NRFI_YTD + bal_PO_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_PblOffYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',21);
      -- Tax Liability
      trc_LibFyPO := trc_PblOffYtd * glb_ZA_PBL_TX_RTE / 100;
      trc_LibFpPO := trc_LibFyPO -  bal_TX_ON_PO_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.DirCalc',22);
      -- Set Cascade Figures and Refund
      trc_LibFyPO    := 0;
      trc_LibFpPO    := -1 * bal_TX_ON_PO_YTD;
      trc_LibFpPOOvr := TRUE;
   END IF;

-- Net Pay Validation
--
   py_za_tx_utl_01032002.ValidateTaxOns(p_Rf => TRUE);

   hr_utility.set_location('py_za_tx_01032002.DirCalc',23);

-- Tax Percentage Indicator
--
   IF dbi_TX_STA    IN ('D','P') THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',24);
      trc_TxPercVal := dbi_TX_DIR_VAL;
   ELSIF dbi_TX_STA = 'E' THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',25);
      trc_TxPercVal := glb_ZA_CC_TX_PRC;
   ELSIF dbi_TX_STA = 'F' THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',26);
      trc_TxPercVal := glb_ZA_TMP_TX_RTE;
   ELSIF dbi_TX_STA = 'J' THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',27);
      trc_TxPercVal := glb_ZA_PER_SERV_COMP_PERC;
   ELSIF dbi_TX_STA = 'K' THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',28);
      trc_TxPercVal := glb_ZA_PER_SERV_TRST_PERC;
   ELSIF dbi_TX_STA = 'L' THEN
      hr_utility.set_location('py_za_tx_01032002.DirCalc',29);
      trc_TxPercVal := glb_ZA_LABOUR_BROK_PERC;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.DirCalc',30);
      trc_TxPercVal := 0;
   END IF;

   hr_utility.set_location('py_za_tx_01032002.DirCalc',31);

   -- Base Income
   WrtHrTrc('trc_BseErn:       '||to_char(trc_BseErn));
   WrtHrTrc('trc_TxbBseInc:    '||to_char(trc_TxbBseInc));
   WrtHrTrc('trc_TotLibBse:    '||to_char(trc_TotLibBse));
   -- Normal Income
   WrtHrTrc('trc_NorIncYtd:    '||to_char(trc_NorIncYtd));
   WrtHrTrc('trc_NorIncPtd:    '||to_char(trc_NorIncPtd));
   WrtHrTrc('trc_NorErn:       '||to_char(trc_NorErn));
   WrtHrTrc('trc_TxbNorInc:    '||to_char(trc_TxbNorInc));
   WrtHrTrc('trc_TotLibNI:     '||to_char(trc_TotLibNI));
   WrtHrTrc('trc_LibFyNI:      '||to_char(trc_LibFyNI));
   WrtHrTrc('trc_LibFpNI:      '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   WrtHrTrc('trc_FrnBenYtd:    '||to_char(trc_FrnBenYtd));
   WrtHrTrc('trc_FrnBenPtd:    '||to_char(trc_FrnBenPtd));
   WrtHrTrc('trc_FrnBenErn:    '||to_char(trc_FrnBenErn));
   WrtHrTrc('trc_TxbFrnInc:    '||to_char(trc_TxbFrnInc));
   WrtHrTrc('trc_TotLibFB:     '||to_char(trc_TotLibFB));
   WrtHrTrc('trc_LibFyFB:      '||to_char(trc_LibFyFB));
   WrtHrTrc('trc_LibFpFB:      '||to_char(trc_LibFpFB));
   -- Travel Allowance
   WrtHrTrc('trc_TrvAllYtd:    '||to_char(trc_TrvAllYtd));
   WrtHrTrc('trc_TrvAllPtd:    '||to_char(trc_TrvAllPtd));
   WrtHrTrc('trc_TrvAllErn:    '||to_char(trc_TrvAllErn));
   WrtHrTrc('trc_TxbTrvInc:    '||to_char(trc_TxbTrvInc));
   WrtHrTrc('trc_TotLibTA:     '||to_char(trc_TotLibTA));
   WrtHrTrc('trc_LibFyTA:      '||to_char(trc_LibFyTA));
   WrtHrTrc('trc_LibFpTA:      '||to_char(trc_LibFpTA));
   -- Bonus Provision
   WrtHrTrc('trc_BonProYtd:    '||to_char(trc_BonProYtd));
   WrtHrTrc('trc_BonProPtd:    '||to_char(trc_BonProPtd));
   WrtHrTrc('trc_BonProErn:    '||to_char(trc_BonProErn));
   WrtHrTrc('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
   WrtHrTrc('trc_TotLibBP:     '||to_char(trc_TotLibBP));
   WrtHrTrc('trc_LibFyBP:      '||to_char(trc_LibFyBP));
   WrtHrTrc('trc_LibFpBP:      '||to_char(trc_LibFpBP));
   -- Annual Bonus
   WrtHrTrc('trc_AnnBonYtd:    '||to_char(trc_AnnBonYtd));
   WrtHrTrc('trc_AnnBonPtd:    '||to_char(trc_AnnBonPtd));
   WrtHrTrc('trc_AnnBonErn:    '||to_char(trc_AnnBonErn));
   WrtHrTrc('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
   WrtHrTrc('trc_TotLibAB:     '||to_char(trc_TotLibAB));
   WrtHrTrc('trc_LibFyAB:      '||to_char(trc_LibFyAB));
   WrtHrTrc('trc_LibFpAB:      '||to_char(trc_LibFpAB));
   -- Annual Payments
   WrtHrTrc('trc_AnnPymYtd:    '||to_char(trc_AnnPymYtd));
   WrtHrTrc('trc_AnnPymPtd:    '||to_char(trc_AnnPymPtd));
   WrtHrTrc('trc_AnnPymErn:    '||to_char(trc_AnnPymErn));
   WrtHrTrc('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   WrtHrTrc('trc_TotLibAP:     '||to_char(trc_TotLibAP));
   WrtHrTrc('trc_LibFyAP:      '||to_char(trc_LibFyAP));
   WrtHrTrc('trc_LibFpAP:      '||to_char(trc_LibFpAP));
   -- Pubilc Office Allowance
   WrtHrTrc('trc_PblOffYtd:    '||to_char(trc_PblOffYtd));
   WrtHrTrc('trc_PblOffPtd:    '||to_char(trc_PblOffPtd));
   WrtHrTrc('trc_PblOffErn:    '||to_char(trc_PblOffErn));
   WrtHrTrc('trc_LibFyPO:      '||to_char(trc_LibFyPO));
   WrtHrTrc('trc_LibFpPO:      '||to_char(trc_LibFpPO));

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'DirCalc: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END DirCalc;

-------------------------------------------------------------------------------
-- BasCalc                                                                   --
-- Pre-Earnings Tax Calculation                                              --
-------------------------------------------------------------------------------
PROCEDURE BasCalc AS
-- Variables
--
   l_Np       BALANCE;
   l_65Year   DATE;

BEGIN
   hr_utility.set_location('py_za_tx_01032002.BasCalc',1);
-- Identify the Calculation
--
   trc_CalTyp := 'BasCalc';

-- Rebates
   py_za_tx_utl_01032002.SetRebates;

-- Abatements
   py_za_tx_utl_01032002.Abatements;

-- Deemed Remuneration
--
   -- Run Deemed Remuneration
   trc_DmdRmnRun := bal_DIR_DMD_RMN_ITD;

   -- Skip the calculation if there is No Income
   IF trc_DmdRmnRun <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.BasCalc',2);
      -- Taxable Deemed Remuneration
      trc_TxbDmdRmn := trc_DmdRmnRun;
      -- Threshold Check
      IF trc_TxbDmdRmn >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.BasCalc',3);
         -- Tax Liability
         trc_TotLibDR := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbDmdRmn);
      ELSE
         hr_utility.set_location('py_za_tx_01032002.BasCalc',4);
         trc_TotLibDR := 0;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.BasCalc',5);
      trc_TotLibDR := 0;
   END IF;

   hr_utility.set_location('py_za_tx_01032002.BasCalc',6);

-- Base Earnings
--
   --Base Earnings
   trc_BseErn :=
      ( bal_AB_NRFI_PTD              + bal_AB_RFI_PTD
      + bal_AA_PRCHD_RVAL_NRFI_PTD   + bal_AA_PRCHD_RVAL_RFI_PTD
      + bal_ANN_BUR_AND_SCH_NRFI_PTD + bal_ANN_BUR_AND_SCH_RFI_PTD
      + bal_AC_NRFI_PTD              + bal_AC_RFI_PTD
      + bal_ANU_FRM_RET_FND_NRFI_PTD + bal_ANU_FRM_RET_FND_RFI_PTD
      + bal_ARES_TRD_NRFI_PTD        + bal_ARES_TRD_RFI_PTD
      + bal_PRCH_ANU_TXB_NRFI_PTD    + bal_PRCH_ANU_TXB_RFI_PTD
      + bal_TXB_AP_NRFI_PTD          + bal_TXB_AP_RFI_PTD
      );
      -- Estimate Base Taxable Income
      trc_TxbBseInc := trc_BseErn * dbi_ZA_PAY_PRDS_PER_YR;
   -- Threshold Check
   IF trc_TxbBseInc >= trc_Threshold THEN
      hr_utility.set_location('py_za_tx_01032002.BasCalc',7);
      -- Tax Liability
      trc_TotLibBse := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbBseInc);
      trc_TotLibBse := greatest(trc_TotLibBse,trc_TotLibDR);
   ELSE
      hr_utility.set_location('py_za_tx_01032002.BasCalc',8);
      trc_TotLibBse := trc_TotLibDR;
   END IF;

   hr_utility.set_location('py_za_tx_01032002.BasCalc',9);

-- Annual Bonus
--
   -- Ytd Annual Bonus
   trc_AnnBonYtd := bal_AB_NRFI_YTD + bal_AB_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_AnnBonYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.BasCalc',10);
      -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TxbBseInc;
      -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.BasCalc',11);
         -- Tax Liability
         trc_TotLibAB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnBonInc);
         trc_LibFyAB  := trc_TotLibAB - least(trc_TotLibAB,trc_TotLibBse);
         trc_TotLibAB := greatest(trc_TotLibAB,trc_TotLibBse);
         -- Check Bonus Provision
         IF bal_BP_YTD <> 0 THEN
            hr_utility.set_location('py_za_tx_01032002.BasCalc',12);
            -- Check Bonus Provision Frequency
            IF dbi_BP_TX_RCV = 'A' THEN
               hr_utility.set_location('py_za_tx_01032002.BasCalc',13);
               trc_LibFpAB := 0;
            ELSE
               hr_utility.set_location('py_za_tx_01032002.BasCalc',14);
               trc_LibFpAB := trc_LibFyAB - ( bal_TX_ON_BP_YTD
                                            + bal_TX_ON_AB_YTD);
            END IF;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.BasCalc',15);
            trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.BasCalc',16);
         trc_TotLibAB := trc_TotLibBse;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.BasCalc',17);
      trc_TotLibAB     := trc_TotLibBse;
      trc_TxbAnnBonInc := trc_TxbBseInc;
   END IF;

   hr_utility.set_location('py_za_tx_01032002.BasCalc',18);

-- Annual Payments
--
   -- Ytd Annual Payments
   trc_AnnPymYtd :=
      ( bal_AA_PRCHD_RVAL_NRFI_YTD   + bal_AA_PRCHD_RVAL_RFI_YTD
      + bal_ANN_BUR_AND_SCH_NRFI_YTD + bal_ANN_BUR_AND_SCH_RFI_YTD
      + bal_AC_NRFI_YTD              + bal_AC_RFI_YTD
      + bal_ANU_FRM_RET_FND_NRFI_YTD + bal_ANU_FRM_RET_FND_RFI_YTD
      + bal_ARES_TRD_NRFI_YTD        + bal_ARES_TRD_RFI_YTD
      + bal_PRCH_ANU_TXB_NRFI_YTD    + bal_PRCH_ANU_TXB_RFI_YTD
      + bal_TXB_AP_NRFI_YTD          + bal_TXB_AP_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnPymYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.BasCalc',19);
   -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymYtd + trc_TxbAnnBonInc;
   -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.BasCalc',20);
      -- Tax Liability
         trc_TotLibAP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnPymInc);
         trc_LibFyAP  := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibAB);
         trc_TotLibAP := greatest(trc_TotLibAP,trc_TotLibAB);
         trc_LibFpAP  := trc_LibFyAP - bal_TX_ON_AP_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.BasCalc',21);
         NULL;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.BasCalc',22);
      NULL;
   END IF;

-- Net Pay Validation
--
   py_za_tx_utl_01032002.ValidateTaxOns;

   -- Deemed Remuneration
   WrtHrTrc('trc_TxbDmdRmn:    '||to_char(trc_TxbDmdRmn));
   WrtHrTrc('trc_TotLibDR:     '||to_char(trc_TotLibDR));
   WrtHrTrc('trc_LibFyDR:      '||to_char(trc_LibFyDR));
   WrtHrTrc('trc_LibFpDR:      '||to_char(trc_LibFpDR));
   -- Base Income
   WrtHrTrc('trc_BseErn:       '||to_char(trc_BseErn));
   WrtHrTrc('trc_TxbBseInc:    '||to_char(trc_TxbBseInc));
   WrtHrTrc('trc_TotLibBse:    '||to_char(trc_TotLibBse));
   -- Normal Income
   WrtHrTrc('trc_NorIncYtd:    '||to_char(trc_NorIncYtd));
   WrtHrTrc('trc_NorIncPtd:    '||to_char(trc_NorIncPtd));
   WrtHrTrc('trc_NorErn:       '||to_char(trc_NorErn));
   WrtHrTrc('trc_TxbNorInc:    '||to_char(trc_TxbNorInc));
   WrtHrTrc('trc_TotLibNI:     '||to_char(trc_TotLibNI));
   WrtHrTrc('trc_LibFyNI:      '||to_char(trc_LibFyNI));
   WrtHrTrc('trc_LibFpNI:      '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   WrtHrTrc('trc_FrnBenYtd:    '||to_char(trc_FrnBenYtd));
   WrtHrTrc('trc_FrnBenPtd:    '||to_char(trc_FrnBenPtd));
   WrtHrTrc('trc_FrnBenErn:    '||to_char(trc_FrnBenErn));
   WrtHrTrc('trc_TxbFrnInc:    '||to_char(trc_TxbFrnInc));
   WrtHrTrc('trc_TotLibFB:     '||to_char(trc_TotLibFB));
   WrtHrTrc('trc_LibFyFB:      '||to_char(trc_LibFyFB));
   WrtHrTrc('trc_LibFpFB:      '||to_char(trc_LibFpFB));
   -- Travel Allowance
   WrtHrTrc('trc_TrvAllYtd:    '||to_char(trc_TrvAllYtd));
   WrtHrTrc('trc_TrvAllPtd:    '||to_char(trc_TrvAllPtd));
   WrtHrTrc('trc_TrvAllErn:    '||to_char(trc_TrvAllErn));
   WrtHrTrc('trc_TxbTrvInc:    '||to_char(trc_TxbTrvInc));
   WrtHrTrc('trc_TotLibTA:     '||to_char(trc_TotLibTA));
   WrtHrTrc('trc_LibFyTA:      '||to_char(trc_LibFyTA));
   WrtHrTrc('trc_LibFpTA:      '||to_char(trc_LibFpTA));
   -- Bonus Provision
   WrtHrTrc('trc_BonProYtd:    '||to_char(trc_BonProYtd));
   WrtHrTrc('trc_BonProPtd:    '||to_char(trc_BonProPtd));
   WrtHrTrc('trc_BonProErn:    '||to_char(trc_BonProErn));
   WrtHrTrc('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
   WrtHrTrc('trc_TotLibBP:     '||to_char(trc_TotLibBP));
   WrtHrTrc('trc_LibFyBP:      '||to_char(trc_LibFyBP));
   WrtHrTrc('trc_LibFpBP:      '||to_char(trc_LibFpBP));
   -- Annual Bonus
   WrtHrTrc('trc_AnnBonYtd:    '||to_char(trc_AnnBonYtd));
   WrtHrTrc('trc_AnnBonPtd:    '||to_char(trc_AnnBonPtd));
   WrtHrTrc('trc_AnnBonErn:    '||to_char(trc_AnnBonErn));
   WrtHrTrc('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
   WrtHrTrc('trc_TotLibAB:     '||to_char(trc_TotLibAB));
   WrtHrTrc('trc_LibFyAB:      '||to_char(trc_LibFyAB));
   WrtHrTrc('trc_LibFpAB:      '||to_char(trc_LibFpAB));
   -- Annual Payments
   WrtHrTrc('trc_AnnPymYtd:    '||to_char(trc_AnnPymYtd));
   WrtHrTrc('trc_AnnPymPtd:    '||to_char(trc_AnnPymPtd));
   WrtHrTrc('trc_AnnPymErn:    '||to_char(trc_AnnPymErn));
   WrtHrTrc('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   WrtHrTrc('trc_TotLibAP:     '||to_char(trc_TotLibAP));
   WrtHrTrc('trc_LibFyAP:      '||to_char(trc_LibFyAP));
   WrtHrTrc('trc_LibFpAP:      '||to_char(trc_LibFpAP));
   -- Pubilc Office Allowance
   WrtHrTrc('trc_PblOffYtd:    '||to_char(trc_PblOffYtd));
   WrtHrTrc('trc_PblOffPtd:    '||to_char(trc_PblOffPtd));
   WrtHrTrc('trc_PblOffErn:    '||to_char(trc_PblOffErn));
   WrtHrTrc('trc_LibFyPO:      '||to_char(trc_LibFyPO));
   WrtHrTrc('trc_LibFpPO:      '||to_char(trc_LibFpPO));

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'BasCalc: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END BasCalc;

-------------------------------------------------------------------------------
-- CalCalc                                                                   --
-- Pre-Earnings Tax Calculation                                              --
-------------------------------------------------------------------------------
PROCEDURE CalCalc AS
-- Variables
--
   l_Np       BALANCE;

BEGIN
   hr_utility.set_location('py_za_tx_01032002.CalCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'CalCalc';

-- Update Global Balance Values with correct TAXABLE values
--
   py_za_tx_utl_01032002.TrvAll;

   hr_utility.set_location('py_za_tx_01032002.CalCalc',2);

-- Calendar Ytd Taxable Income
--
   trc_TxbIncYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_CYTD + bal_AST_PRCHD_RVAL_RFI_CYTD
      + bal_BUR_AND_SCH_NRFI_CYTD    + bal_BUR_AND_SCH_RFI_CYTD
      + bal_COMM_NRFI_CYTD           + bal_COMM_RFI_CYTD
      + bal_COMP_ALL_NRFI_CYTD       + bal_COMP_ALL_RFI_CYTD
      + bal_ENT_ALL_NRFI_CYTD        + bal_ENT_ALL_RFI_CYTD
      + bal_FREE_ACCOM_NRFI_CYTD     + bal_FREE_ACCOM_RFI_CYTD
      + bal_FREE_SERV_NRFI_CYTD      + bal_FREE_SERV_RFI_CYTD
      + bal_LOW_LOANS_NRFI_CYTD      + bal_LOW_LOANS_RFI_CYTD
      + bal_MLS_AND_VOUCH_NRFI_CYTD  + bal_MLS_AND_VOUCH_RFI_CYTD
      + bal_MED_PAID_NRFI_CYTD       + bal_MED_PAID_RFI_CYTD
      + bal_OTHER_TXB_ALL_NRFI_CYTD  + bal_OTHER_TXB_ALL_RFI_CYTD
      + bal_OVTM_NRFI_CYTD           + bal_OVTM_RFI_CYTD
      + bal_PYM_DBT_NRFI_CYTD        + bal_PYM_DBT_RFI_CYTD
      + bal_RES_TRD_NRFI_CYTD        + bal_RES_TRD_RFI_CYTD
      + bal_RGT_AST_NRFI_CYTD        + bal_RGT_AST_RFI_CYTD
      + bal_TXB_INC_NRFI_CYTD        + bal_TXB_INC_RFI_CYTD
      + bal_TXB_PEN_NRFI_CYTD        + bal_TXB_PEN_RFI_CYTD
      + bal_TEL_ALL_NRFI_CYTD        + bal_TEL_ALL_RFI_CYTD
      + bal_TOOL_ALL_NRFI_CYTD       + bal_TOOL_ALL_RFI_CYTD
      + bal_TA_NRFI_CYTD             + bal_TA_RFI_CYTD
      + bal_USE_VEH_NRFI_CYTD        + bal_USE_VEH_RFI_CYTD
      );

-- If there is no Income Execute the Base calculation
--
   IF trc_TxbIncYtd = 0 THEN
      hr_utility.set_location('py_za_tx_01032002.CalCalc',3);
      BasCalc;
   ELSE -- continue CalCalc
      hr_utility.set_location('py_za_tx_01032002.CalCalc',4);
   -- Site Factor
   --
      trc_SitFactor := dbi_ZA_DYS_IN_YR / py_za_tx_utl_01032002.DaysWorked;

   -- Rebates
      py_za_tx_utl_01032002.SetRebates;

   -- Abatements
      py_za_tx_utl_01032002.Abatements;

      hr_utility.set_location('py_za_tx_01032002.CalCalc',5);

   -- Deemed Remuneration
   --
      -- Run Deemed Remuneration
      trc_DmdRmnRun := bal_DIR_DMD_RMN_ITD;

      -- Skip the calculation if there is No Income
      IF trc_DmdRmnRun <> 0 THEN
         hr_utility.set_location('py_za_tx_01032002.CalCalc',6);
         -- Taxable Deemed Remuneration
         trc_TxbDmdRmn := trc_DmdRmnRun;
         -- Threshold Check
         IF trc_TxbDmdRmn >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032002.CalCalc',7);
         -- Tax Liability
            trc_TotLibDR := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbDmdRmn);
         ELSE
            hr_utility.set_location('py_za_tx_01032002.CalCalc',8);
            trc_TotLibDR := 0;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.CalCalc',9);
         trc_TotLibDR := 0;
      END IF;

      hr_utility.set_location('py_za_tx_01032002.CalCalc',10);

   -- Base Earnings
   --
      -- Base Earnings
      trc_BseErn := trc_TxbIncYtd * trc_SitFactor;
      -- Taxable Base Income
      trc_TxbBseInc := trc_BseErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbBseInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.CalCalc',11);
         -- Tax Liability
         trc_TotLibBse := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbBseInc);
         trc_TotLibBse := greatest(trc_TotLibBse,trc_TotLibDR);
      ELSE
         hr_utility.set_location('py_za_tx_01032002.CalCalc',12);
         trc_TotLibBse := trc_TotLibDR;
      END IF;

      hr_utility.set_location('py_za_tx_01032002.CalCalc',13);

   -- Annual Bonus
   --
      -- Ytd Annual Bonus
      trc_AnnBonYtd := bal_AB_NRFI_YTD + bal_AB_RFI_YTD;
      -- Skip the calculation if there is No Income
      IF trc_AnnBonYtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032002.CalCalc',14);
         -- Annual Bonus Earnings
         trc_AnnBonErn := trc_AnnBonYtd + trc_BseErn;
         -- Taxable Annual Bonus Income
         trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
         -- Threshold Check
         IF trc_TxbAnnBonInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032002.CalCalc',15);
            -- Tax Liability
            trc_TotLibAB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnBonInc);
            trc_LibFyAB := trc_TotLibAB - least(trc_TotLibAB,trc_TotLibBse);
            trc_TotLibAB := greatest(trc_TotLibAB,trc_TotLibBse);
            -- Check Bonus Provision
            IF bal_BP_YTD <> 0 THEN
               hr_utility.set_location('py_za_tx_01032002.CalCalc',16);
               -- Check Bonus Provision Frequency
               IF dbi_BP_TX_RCV = 'A' THEN
                  hr_utility.set_location('py_za_tx_01032002.CalCalc',17);
                  trc_LibFpAB := 0;
               ELSE
                  hr_utility.set_location('py_za_tx_01032002.CalCalc',18);
                  trc_LibFpAB := trc_LibFyAB - ( bal_TX_ON_BP_YTD
                                               + bal_TX_ON_AB_YTD);
               END IF;
            ELSE
               hr_utility.set_location('py_za_tx_01032002.CalCalc',19);
               trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
            END IF;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.CalCalc',20);
            trc_TotLibAB := trc_TotLibBse;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.CalCalc',21);
         trc_AnnBonErn    := trc_BseErn;
         trc_TxbAnnBonInc := trc_TxbBseInc;
         trc_TotLibAB     := trc_TotLibBse;
      END IF;

      hr_utility.set_location('py_za_tx_01032002.CalCalc',22);

   -- Annual Payments
   --
      -- Ytd Annual Payments
      trc_AnnPymYtd :=
         ( bal_AA_PRCHD_RVAL_NRFI_YTD   + bal_AA_PRCHD_RVAL_RFI_YTD
         + bal_ANN_BUR_AND_SCH_NRFI_YTD + bal_ANN_BUR_AND_SCH_RFI_YTD
         + bal_AC_NRFI_YTD              + bal_AC_RFI_YTD
         + bal_ANU_FRM_RET_FND_NRFI_YTD + bal_ANU_FRM_RET_FND_RFI_YTD
         + bal_ARES_TRD_NRFI_YTD        + bal_ARES_TRD_RFI_YTD
         + bal_PRCH_ANU_TXB_NRFI_YTD    + bal_PRCH_ANU_TXB_RFI_YTD
         + bal_TXB_AP_NRFI_YTD          + bal_TXB_AP_RFI_YTD
         );
      -- Skip the calculation if there is No Income
      IF trc_AnnPymYtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032002.CalCalc',23);
         -- Annual Payments Earnings
         trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
         -- Taxable Annual Payments Income
         trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
         -- Threshold Check
         IF trc_TxbAnnPymInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032002.CalCalc',24);
            -- Tax Liability
            trc_TotLibAP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnPymInc);
            trc_LibFyAP  := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibAB);
            trc_TotLibAP := greatest(trc_TotLibAP,trc_TotLibAB);
            trc_LibFpAP  := trc_LibFyAP - bal_TX_ON_AP_YTD;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.CalCalc',25);
            trc_TotLibAP := trc_TotLibAB;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.CalCalc',26);
         trc_AnnPymErn    := trc_AnnBonErn;
         trc_TxbAnnPymInc := trc_TxbAnnBonInc;
         trc_TotLibAP     := trc_TotLibAB;
      END IF;

   -- Net pay Validation
   --
      py_za_tx_utl_01032002.ValidateTaxOns;

      -- Deemed Remuneration
      WrtHrTrc('trc_TxbDmdRmn:    '||to_char(trc_TxbDmdRmn));
      WrtHrTrc('trc_TotLibDR:     '||to_char(trc_TotLibDR));
      WrtHrTrc('trc_LibFyDR:      '||to_char(trc_LibFyDR));
      WrtHrTrc('trc_LibFpDR:      '||to_char(trc_LibFpDR));
      -- Base Income
      WrtHrTrc('trc_BseErn:       '||to_char(trc_BseErn));
      WrtHrTrc('trc_TxbBseInc:    '||to_char(trc_TxbBseInc));
      WrtHrTrc('trc_TotLibBse:    '||to_char(trc_TotLibBse));
      -- Normal Income
      WrtHrTrc('trc_NorIncYtd:    '||to_char(trc_NorIncYtd));
      WrtHrTrc('trc_NorIncPtd:    '||to_char(trc_NorIncPtd));
      WrtHrTrc('trc_NorErn:       '||to_char(trc_NorErn));
      WrtHrTrc('trc_TxbNorInc:    '||to_char(trc_TxbNorInc));
      WrtHrTrc('trc_TotLibNI:     '||to_char(trc_TotLibNI));
      WrtHrTrc('trc_LibFyNI:      '||to_char(trc_LibFyNI));
      WrtHrTrc('trc_LibFpNI:      '||to_char(trc_LibFpNI));
      -- Fringe Benefits
      WrtHrTrc('trc_FrnBenYtd:    '||to_char(trc_FrnBenYtd));
      WrtHrTrc('trc_FrnBenPtd:    '||to_char(trc_FrnBenPtd));
      WrtHrTrc('trc_FrnBenErn:    '||to_char(trc_FrnBenErn));
      WrtHrTrc('trc_TxbFrnInc:    '||to_char(trc_TxbFrnInc));
      WrtHrTrc('trc_TotLibFB:     '||to_char(trc_TotLibFB));
      WrtHrTrc('trc_LibFyFB:      '||to_char(trc_LibFyFB));
      WrtHrTrc('trc_LibFpFB:      '||to_char(trc_LibFpFB));
      -- Travel Allowance
      WrtHrTrc('trc_TrvAllYtd:    '||to_char(trc_TrvAllYtd));
      WrtHrTrc('trc_TrvAllPtd:    '||to_char(trc_TrvAllPtd));
      WrtHrTrc('trc_TrvAllErn:    '||to_char(trc_TrvAllErn));
      WrtHrTrc('trc_TxbTrvInc:    '||to_char(trc_TxbTrvInc));
      WrtHrTrc('trc_TotLibTA:     '||to_char(trc_TotLibTA));
      WrtHrTrc('trc_LibFyTA:      '||to_char(trc_LibFyTA));
      WrtHrTrc('trc_LibFpTA:      '||to_char(trc_LibFpTA));
      -- Bonus Provision
      WrtHrTrc('trc_BonProYtd:    '||to_char(trc_BonProYtd));
      WrtHrTrc('trc_BonProPtd:    '||to_char(trc_BonProPtd));
      WrtHrTrc('trc_BonProErn:    '||to_char(trc_BonProErn));
      WrtHrTrc('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
      WrtHrTrc('trc_TotLibBP:     '||to_char(trc_TotLibBP));
      WrtHrTrc('trc_LibFyBP:      '||to_char(trc_LibFyBP));
      WrtHrTrc('trc_LibFpBP:      '||to_char(trc_LibFpBP));
      -- Annual Bonus
      WrtHrTrc('trc_AnnBonYtd:    '||to_char(trc_AnnBonYtd));
      WrtHrTrc('trc_AnnBonPtd:    '||to_char(trc_AnnBonPtd));
      WrtHrTrc('trc_AnnBonErn:    '||to_char(trc_AnnBonErn));
      WrtHrTrc('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
      WrtHrTrc('trc_TotLibAB:     '||to_char(trc_TotLibAB));
      WrtHrTrc('trc_LibFyAB:      '||to_char(trc_LibFyAB));
      WrtHrTrc('trc_LibFpAB:      '||to_char(trc_LibFpAB));
      -- Annual Payments
      WrtHrTrc('trc_AnnPymYtd:    '||to_char(trc_AnnPymYtd));
      WrtHrTrc('trc_AnnPymPtd:    '||to_char(trc_AnnPymPtd));
      WrtHrTrc('trc_AnnPymErn:    '||to_char(trc_AnnPymErn));
      WrtHrTrc('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
      WrtHrTrc('trc_TotLibAP:     '||to_char(trc_TotLibAP));
      WrtHrTrc('trc_LibFyAP:      '||to_char(trc_LibFyAP));
      WrtHrTrc('trc_LibFpAP:      '||to_char(trc_LibFpAP));
      -- Pubilc Office Allowance
      WrtHrTrc('trc_PblOffYtd:    '||to_char(trc_PblOffYtd));
      WrtHrTrc('trc_PblOffPtd:    '||to_char(trc_PblOffPtd));
      WrtHrTrc('trc_PblOffErn:    '||to_char(trc_PblOffErn));
      WrtHrTrc('trc_LibFyPO:      '||to_char(trc_LibFyPO));
      WrtHrTrc('trc_LibFpPO:      '||to_char(trc_LibFpPO));

   END IF;

   hr_utility.set_location('py_za_tx_01032002.CalCalc',27);

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'CalCalc: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END CalCalc;
-------------------------------------------------------------------------------
-- YtdCalc                                                                   --
-- Pre-Earnings Tax Calculation                                              --
-------------------------------------------------------------------------------
PROCEDURE YtdCalc AS
-- Variables
--
   l_Np       BALANCE;

BEGIN
   hr_utility.set_location('py_za_tx_01032002.YtdCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'YtdCalc';

-- Update Global Balance Values with correct TAXABLE values
   py_za_tx_utl_01032002.TrvAll;

   hr_utility.set_location('py_za_tx_01032002.YtdCalc',2);

-- Ytd Taxable Income
   trc_TxbIncYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_YTD + bal_AST_PRCHD_RVAL_RFI_YTD
      + bal_BP_YTD
      + bal_BUR_AND_SCH_NRFI_YTD    + bal_BUR_AND_SCH_RFI_YTD
      + bal_COMM_NRFI_YTD           + bal_COMM_RFI_YTD
      + bal_COMP_ALL_NRFI_YTD       + bal_COMP_ALL_RFI_YTD
      + bal_ENT_ALL_NRFI_YTD        + bal_ENT_ALL_RFI_YTD
      + bal_FREE_ACCOM_NRFI_YTD     + bal_FREE_ACCOM_RFI_YTD
      + bal_FREE_SERV_NRFI_YTD      + bal_FREE_SERV_RFI_YTD
      + bal_LOW_LOANS_NRFI_YTD      + bal_LOW_LOANS_RFI_YTD
      + bal_MLS_AND_VOUCH_NRFI_YTD  + bal_MLS_AND_VOUCH_RFI_YTD
      + bal_MED_PAID_NRFI_YTD       + bal_MED_PAID_RFI_YTD
      + bal_OTHER_TXB_ALL_NRFI_YTD  + bal_OTHER_TXB_ALL_RFI_YTD
      + bal_OVTM_NRFI_YTD           + bal_OVTM_RFI_YTD
      + bal_PYM_DBT_NRFI_YTD        + bal_PYM_DBT_RFI_YTD
      + bal_RES_TRD_NRFI_YTD        + bal_RES_TRD_RFI_YTD
      + bal_RGT_AST_NRFI_YTD        + bal_RGT_AST_RFI_YTD
      + bal_TXB_INC_NRFI_YTD        + bal_TXB_INC_RFI_YTD
      + bal_TXB_PEN_NRFI_YTD        + bal_TXB_PEN_RFI_YTD
      + bal_TEL_ALL_NRFI_YTD        + bal_TEL_ALL_RFI_YTD
      + bal_TOOL_ALL_NRFI_YTD       + bal_TOOL_ALL_RFI_YTD
      + bal_TA_NRFI_YTD             + bal_TA_RFI_YTD
      + bal_USE_VEH_NRFI_YTD        + bal_USE_VEH_RFI_YTD
      );

-- If the Ytd Taxable Income = 0, execute the CalCalc
   IF trc_TxbIncYtd = 0 THEN
      hr_utility.set_location('py_za_tx_01032002.YtdCalc',3);
      CalCalc;
   ELSE --Continue YtdCalc
      hr_utility.set_location('py_za_tx_01032002.YtdCalc',4);
   -- Site Factor
      trc_SitFactor := dbi_ZA_DYS_IN_YR / py_za_tx_utl_01032002.DaysWorked;

   -- Rebates
      py_za_tx_utl_01032002.SetRebates;

   -- Abatements
      py_za_tx_utl_01032002.Abatements;

      hr_utility.set_location('py_za_tx_01032002.YtdCalc',5);

   -- Deemed Remuneration
   --
      -- Run Deemed Remuneration
      trc_DmdRmnRun := bal_DIR_DMD_RMN_ITD;

      -- Skip the calculation if there is No Income
      IF trc_DmdRmnRun <> 0 THEN
         hr_utility.set_location('py_za_tx_01032002.YtdCalc',6);
         -- Taxable Deemed Remuneration
         trc_TxbDmdRmn := trc_DmdRmnRun;
         -- Threshold Check
         IF trc_TxbDmdRmn >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032002.YtdCalc',7);
            -- Tax Liability
            trc_TotLibDR := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbDmdRmn);
         ELSE
            hr_utility.set_location('py_za_tx_01032002.YtdCalc',8);
            trc_TotLibDR := 0;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.YtdCalc',9);
         trc_TotLibDR := 0;
      END IF;

      hr_utility.set_location('py_za_tx_01032002.YtdCalc',10);

   -- Base Earnings
   --
      -- Base Earnings
      trc_BseErn := trc_TxbIncYtd * trc_SitFactor;
      -- Taxable Base Income
      trc_TxbBseInc := trc_BseErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbBseInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.YtdCalc',11);
         -- Tax Liability
         trc_TotLibBse := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbBseInc);
         trc_TotLibBse := greatest(trc_TotLibBse,trc_TotLibDR);
      ELSE
         hr_utility.set_location('py_za_tx_01032002.YtdCalc',12);
         trc_TotLibBse := trc_TotLibDR;
      END IF;

      hr_utility.set_location('py_za_tx_01032002.YtdCalc',13);

   -- Annual Bonus
   --
      -- Ytd Annual Bonus
      trc_AnnBonYtd := bal_AB_NRFI_YTD + bal_AB_RFI_YTD;
      -- Skip the calculation if there is No Income
      IF trc_AnnBonYtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032002.YtdCalc',14);
         -- Annual Bonus Earnings
         trc_AnnBonErn := trc_AnnBonYtd + trc_BseErn;
         -- Taxable Annual Bonus Income
         trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
         -- Threshold Check
         IF trc_TxbAnnBonInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032002.YtdCalc',15);
            -- Tax Liability
            trc_TotLibAB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnBonInc);
            trc_LibFyAB  := trc_TotLibAB - least(trc_TotLibAB,trc_TotLibBse);
            trc_TotLibAB := greatest(trc_TotLibAB,trc_TotLibBse);
            -- Check Bonus Provision
            IF bal_BP_YTD <> 0 THEN
               hr_utility.set_location('py_za_tx_01032002.YtdCalc',16);
               -- Check Bonus Provision Frequency
               IF dbi_BP_TX_RCV = 'A' THEN
                  hr_utility.set_location('py_za_tx_01032002.YtdCalc',17);
                  trc_LibFpAB := 0;
               ELSE
                  hr_utility.set_location('py_za_tx_01032002.YtdCalc',18);
                  trc_LibFpAB := trc_LibFyAB - ( bal_TX_ON_BP_YTD
                                               + bal_TX_ON_AB_YTD);
               END IF;
            ELSE
               hr_utility.set_location('py_za_tx_01032002.YtdCalc',19);
               trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
            END IF;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.YtdCalc',20);
            trc_TotLibAB := trc_TotLibBse;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.YtdCalc',21);
         trc_AnnBonErn    := trc_BseErn;
         trc_TxbAnnBonInc := trc_TxbBseInc;
         trc_TotLibAB     := trc_TotLibBse;
      END IF;

      hr_utility.set_location('py_za_tx_01032002.YtdCalc',22);

   -- Annual Payments
   --
      -- Ytd Annual Payments
      trc_AnnPymYtd :=
         ( bal_AA_PRCHD_RVAL_NRFI_YTD   + bal_AA_PRCHD_RVAL_RFI_YTD
         + bal_ANN_BUR_AND_SCH_NRFI_YTD + bal_ANN_BUR_AND_SCH_RFI_YTD
         + bal_AC_NRFI_YTD              + bal_AC_RFI_YTD
         + bal_ANU_FRM_RET_FND_NRFI_YTD + bal_ANU_FRM_RET_FND_RFI_YTD
         + bal_ARES_TRD_NRFI_YTD        + bal_ARES_TRD_RFI_YTD
         + bal_PRCH_ANU_TXB_NRFI_YTD    + bal_PRCH_ANU_TXB_RFI_YTD
         + bal_TXB_AP_NRFI_YTD          + bal_TXB_AP_RFI_YTD
         );
      -- Skip the calculation if there is No Income
      IF trc_AnnPymYtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032002.YtdCalc',23);
         -- Annual Payments Earnings
         trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
         -- Taxable Annual Payments Income
         trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
         -- Threshold Check
         IF trc_TxbAnnPymInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032002.YtdCalc',24);
            -- Tax Liability
            trc_TotLibAP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnPymInc);
            trc_LibFyAP  := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibAB);
            trc_TotLibAP := greatest(trc_TotLibAP,trc_TotLibAB);
            trc_LibFpAP  := trc_LibFyAP - bal_TX_ON_AP_YTD;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.YtdCalc',25);
            trc_TotLibAP := trc_TotLibAB;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.YtdCalc',26);
         trc_AnnPymErn    := trc_AnnBonErn;
         trc_TxbAnnPymInc := trc_TxbAnnBonInc;
         trc_TotLibAP     := trc_TotLibAB;
      END IF;

   -- Net Pay validation
   --
      py_za_tx_utl_01032002.ValidateTaxOns;

      hr_utility.set_location('py_za_tx_01032002.YtdCalc',27);

      -- Deemed Remuneration
      WrtHrTrc('trc_TxbDmdRmn:    '||to_char(trc_TxbDmdRmn));
      WrtHrTrc('trc_TotLibDR:     '||to_char(trc_TotLibDR));
      WrtHrTrc('trc_LibFyDR:      '||to_char(trc_LibFyDR));
      WrtHrTrc('trc_LibFpDR:      '||to_char(trc_LibFpDR));
      -- Base Income
      WrtHrTrc('trc_BseErn:       '||to_char(trc_BseErn));
      WrtHrTrc('trc_TxbBseInc:    '||to_char(trc_TxbBseInc));
      WrtHrTrc('trc_TotLibBse:    '||to_char(trc_TotLibBse));
      -- Normal Income
      WrtHrTrc('trc_NorIncYtd:    '||to_char(trc_NorIncYtd));
      WrtHrTrc('trc_NorIncPtd:    '||to_char(trc_NorIncPtd));
      WrtHrTrc('trc_NorErn:       '||to_char(trc_NorErn));
      WrtHrTrc('trc_TxbNorInc:    '||to_char(trc_TxbNorInc));
      WrtHrTrc('trc_TotLibNI:     '||to_char(trc_TotLibNI));
      WrtHrTrc('trc_LibFyNI:      '||to_char(trc_LibFyNI));
      WrtHrTrc('trc_LibFpNI:      '||to_char(trc_LibFpNI));
      -- Fringe Benefits
      WrtHrTrc('trc_FrnBenYtd:    '||to_char(trc_FrnBenYtd));
      WrtHrTrc('trc_FrnBenPtd:    '||to_char(trc_FrnBenPtd));
      WrtHrTrc('trc_FrnBenErn:    '||to_char(trc_FrnBenErn));
      WrtHrTrc('trc_TxbFrnInc:    '||to_char(trc_TxbFrnInc));
      WrtHrTrc('trc_TotLibFB:     '||to_char(trc_TotLibFB));
      WrtHrTrc('trc_LibFyFB:      '||to_char(trc_LibFyFB));
      WrtHrTrc('trc_LibFpFB:      '||to_char(trc_LibFpFB));
      -- Travel Allowance
      WrtHrTrc('trc_TrvAllYtd:    '||to_char(trc_TrvAllYtd));
      WrtHrTrc('trc_TrvAllPtd:    '||to_char(trc_TrvAllPtd));
      WrtHrTrc('trc_TrvAllErn:    '||to_char(trc_TrvAllErn));
      WrtHrTrc('trc_TxbTrvInc:    '||to_char(trc_TxbTrvInc));
      WrtHrTrc('trc_TotLibTA:     '||to_char(trc_TotLibTA));
      WrtHrTrc('trc_LibFyTA:      '||to_char(trc_LibFyTA));
      WrtHrTrc('trc_LibFpTA:      '||to_char(trc_LibFpTA));
      -- Bonus Provision
      WrtHrTrc('trc_BonProYtd:    '||to_char(trc_BonProYtd));
      WrtHrTrc('trc_BonProPtd:    '||to_char(trc_BonProPtd));
      WrtHrTrc('trc_BonProErn:    '||to_char(trc_BonProErn));
      WrtHrTrc('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
      WrtHrTrc('trc_TotLibBP:     '||to_char(trc_TotLibBP));
      WrtHrTrc('trc_LibFyBP:      '||to_char(trc_LibFyBP));
      WrtHrTrc('trc_LibFpBP:      '||to_char(trc_LibFpBP));
      -- Annual Bonus
      WrtHrTrc('trc_AnnBonYtd:    '||to_char(trc_AnnBonYtd));
      WrtHrTrc('trc_AnnBonPtd:    '||to_char(trc_AnnBonPtd));
      WrtHrTrc('trc_AnnBonErn:    '||to_char(trc_AnnBonErn));
      WrtHrTrc('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
      WrtHrTrc('trc_TotLibAB:     '||to_char(trc_TotLibAB));
      WrtHrTrc('trc_LibFyAB:      '||to_char(trc_LibFyAB));
      WrtHrTrc('trc_LibFpAB:      '||to_char(trc_LibFpAB));
      -- Annual Payments
      WrtHrTrc('trc_AnnPymYtd:    '||to_char(trc_AnnPymYtd));
      WrtHrTrc('trc_AnnPymPtd:    '||to_char(trc_AnnPymPtd));
      WrtHrTrc('trc_AnnPymErn:    '||to_char(trc_AnnPymErn));
      WrtHrTrc('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
      WrtHrTrc('trc_TotLibAP:     '||to_char(trc_TotLibAP));
      WrtHrTrc('trc_LibFyAP:      '||to_char(trc_LibFyAP));
      WrtHrTrc('trc_LibFpAP:      '||to_char(trc_LibFpAP));
      -- Pubilc Office Allowance
      WrtHrTrc('trc_PblOffYtd:    '||to_char(trc_PblOffYtd));
      WrtHrTrc('trc_PblOffPtd:    '||to_char(trc_PblOffPtd));
      WrtHrTrc('trc_PblOffErn:    '||to_char(trc_PblOffErn));
      WrtHrTrc('trc_LibFyPO:      '||to_char(trc_LibFyPO));
      WrtHrTrc('trc_LibFpPO:      '||to_char(trc_LibFpPO));

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'YtdCalc: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END YtdCalc;
-------------------------------------------------------------------------------
-- NorCalc                                                                   --
-- Main Tax Calculation for Periodic Income                                  --
-------------------------------------------------------------------------------
PROCEDURE NorCalc AS
-- Variables
--
   l_Np       BALANCE DEFAULT 0;

BEGIN
   hr_utility.set_location('py_za_tx_01032002.NorCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'NorCalc';

-- Update Global Balance Values with correct TAXABLE values
--
   bal_TA_RFI_PTD  := bal_TA_RFI_PTD * glb_ZA_TRV_ALL_TX_PRC / 100;
   bal_TA_NRFI_PTD := bal_TA_NRFI_PTD * glb_ZA_TRV_ALL_TX_PRC / 100;

   py_za_tx_utl_01032002.TrvAll;

   hr_utility.set_location('py_za_tx_01032002.NorCalc',2);

   bal_PO_RFI_PTD  := bal_PO_RFI_PTD  * glb_ZA_PBL_TX_PRC / 100;
   bal_PO_NRFI_PTD := bal_PO_NRFI_PTD * glb_ZA_PBL_TX_PRC / 100;
   bal_PO_RFI_YTD  := bal_PO_RFI_YTD  * glb_ZA_PBL_TX_PRC / 100;
   bal_PO_NRFI_YTD := bal_PO_NRFI_YTD * glb_ZA_PBL_TX_PRC / 100;



-- PTD Taxable Income
--
   trc_TxbIncPtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_PTD + bal_AST_PRCHD_RVAL_RFI_PTD
      + bal_BP_PTD
      + bal_BUR_AND_SCH_NRFI_PTD    + bal_BUR_AND_SCH_RFI_PTD
      + bal_COMM_NRFI_PTD           + bal_COMM_RFI_PTD
      + bal_COMP_ALL_NRFI_PTD       + bal_COMP_ALL_RFI_PTD
      + bal_ENT_ALL_NRFI_PTD        + bal_ENT_ALL_RFI_PTD
      + bal_FREE_ACCOM_NRFI_PTD     + bal_FREE_ACCOM_RFI_PTD
      + bal_FREE_SERV_NRFI_PTD      + bal_FREE_SERV_RFI_PTD
      + bal_LOW_LOANS_NRFI_PTD      + bal_LOW_LOANS_RFI_PTD
      + bal_MLS_AND_VOUCH_NRFI_PTD  + bal_MLS_AND_VOUCH_RFI_PTD
      + bal_MED_PAID_NRFI_PTD       + bal_MED_PAID_RFI_PTD
      + bal_OTHER_TXB_ALL_NRFI_PTD  + bal_OTHER_TXB_ALL_RFI_PTD
      + bal_OVTM_NRFI_PTD           + bal_OVTM_RFI_PTD
      + bal_PYM_DBT_NRFI_PTD        + bal_PYM_DBT_RFI_PTD
      + bal_RES_TRD_NRFI_PTD        + bal_RES_TRD_RFI_PTD
      + bal_RGT_AST_NRFI_PTD        + bal_RGT_AST_RFI_PTD
      + bal_TXB_INC_NRFI_PTD        + bal_TXB_INC_RFI_PTD
      + bal_TXB_PEN_NRFI_PTD        + bal_TXB_PEN_RFI_PTD
      + bal_TEL_ALL_NRFI_PTD        + bal_TEL_ALL_RFI_PTD
      + bal_TOOL_ALL_NRFI_PTD       + bal_TOOL_ALL_RFI_PTD
      + bal_TA_NRFI_PTD             + bal_TA_RFI_PTD
      + bal_USE_VEH_NRFI_PTD        + bal_USE_VEH_RFI_PTD
      );

-- Period Factor
   py_za_tx_utl_01032002.PeriodFactor;

-- Possible Periods Factor
   py_za_tx_utl_01032002.PossiblePeriodsFactor;

-- Rebates
   py_za_tx_utl_01032002.SetRebates;

-- Abatements
   py_za_tx_utl_01032002.Abatements;

   hr_utility.set_location('py_za_tx_01032002.NorCalc',3);

-- Deemed Remuneration
--
   -- Run Deemed Remuneration
   trc_DmdRmnRun := bal_DIR_DMD_RMN_ITD;
   -- Skip the calculation if there is No Income
   IF trc_DmdRmnRun <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.NorCalc',4);
      -- Taxable Deemed Remuneration
      trc_TxbDmdRmn := trc_DmdRmnRun;
      -- Threshold Check
      IF trc_TxbDmdRmn >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.NorCalc',5);
         -- Tax Liability
         trc_TotLibDR := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbDmdRmn);
         trc_LibFyDR  := trc_TotLibDR - 0;
         trc_TotLibDR := greatest(trc_TotLibDR,0);
         -- DeAnnualise
         trc_LibFpDR := py_za_tx_utl_01032002.DeAnnualise
                           ( p_Liab    => trc_LibFyDR
                           , p_TxOnYtd => bal_TX_ON_DR_YTD
                           , p_TxOnPtd => bal_TX_ON_DR_PTD
                           );
      ELSE
         hr_utility.set_location('py_za_tx_01032002.NorCalc',6);
         -- Set Cascade Figures and Refund
         trc_TotLibDR   := 0;
         trc_LibFpDR    := -1 * bal_TX_ON_DR_YTD;
         trc_LibFpDROvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.NorCalc',7);
      -- Set Cascade Figures and Refund
      trc_TxbDmdRmn  := 0;
      trc_TotLibDR   := 0;
      trc_LibFpDR    := -1 * bal_TX_ON_DR_YTD;
      trc_LibFpDROvr := TRUE;
   END IF;

-- Normal Income
--
   -- Ytd Normal Income
   trc_NorIncYtd :=
      ( bal_COMM_NRFI_YTD          + bal_COMM_RFI_YTD
      + bal_COMP_ALL_NRFI_YTD      + bal_COMP_ALL_RFI_YTD
      + bal_ENT_ALL_NRFI_YTD       + bal_ENT_ALL_RFI_YTD
      + bal_OTHER_TXB_ALL_NRFI_YTD + bal_OTHER_TXB_ALL_RFI_YTD
      + bal_OVTM_NRFI_YTD          + bal_OVTM_RFI_YTD
      + bal_RES_TRD_NRFI_YTD       + bal_RES_TRD_RFI_YTD
      + bal_TXB_INC_NRFI_YTD       + bal_TXB_INC_RFI_YTD
      + bal_TXB_PEN_NRFI_YTD       + bal_TXB_PEN_RFI_YTD
      + bal_TEL_ALL_NRFI_YTD       + bal_TEL_ALL_RFI_YTD
      + bal_TOOL_ALL_NRFI_YTD      + bal_TOOL_ALL_RFI_YTD
      );

   -- Skip the calculation if there is No Income
   IF trc_NorIncYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.NorCalc',8);

      -- Annualise Normal Income
      trc_NorErn := py_za_tx_utl_01032002.Annualise
         (p_YtdInc => trc_NorIncYtd
         ,p_PtdInc => trc_NorIncPtd
         );

      -- Taxable Normal Income
      trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;

      -- Threshold Check
      IF trc_TxbNorInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.NorCalc',9);
         -- Tax Liability
         trc_TotLibNI := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbNorInc);
         trc_LibFyNI  := trc_TotLibNI - least(trc_TotLibNI,trc_TotLibDR);
         trc_TotLibNI := greatest(trc_TotLibNI,trc_TotLibDR);
         -- DeAnnualise
         trc_LibFpNI := py_za_tx_utl_01032002.DeAnnualise
                           ( p_Liab    => trc_LibFyNI
                           , p_TxOnYtd => bal_TX_ON_NI_YTD
                           , p_TxOnPtd => bal_TX_ON_NI_PTD
                           );
      ELSE
         hr_utility.set_location('py_za_tx_01032002.NorCalc',10);
         -- Set Cascade Figures and Refund
         trc_TotLibNI   := trc_TotLibDR;
         trc_LibFpNI    := -1 * bal_TX_ON_NI_YTD;
         trc_LibFpNIOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.NorCalc',11);
      -- Set Cascade Figures and Refund
      trc_NorErn     := 0;
      trc_TxbNorInc  := 0;
      trc_TotLibNI   := trc_TotLibDR;
      trc_LibFpNI    := -1 * bal_TX_ON_NI_YTD;
      trc_LibFpNIOvr := TRUE;
   END IF;

-- Fringe Benefits
--
   -- Ytd Fringe Benefits
   trc_FrnBenYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_YTD + bal_AST_PRCHD_RVAL_RFI_YTD
      + bal_BUR_AND_SCH_NRFI_YTD    + bal_BUR_AND_SCH_RFI_YTD
      + bal_FREE_ACCOM_NRFI_YTD     + bal_FREE_ACCOM_RFI_YTD
      + bal_FREE_SERV_NRFI_YTD      + bal_FREE_SERV_RFI_YTD
      + bal_LOW_LOANS_NRFI_YTD      + bal_LOW_LOANS_RFI_YTD
      + bal_MLS_AND_VOUCH_NRFI_YTD  + bal_MLS_AND_VOUCH_RFI_YTD
      + bal_MED_PAID_NRFI_YTD       + bal_MED_PAID_RFI_YTD
      + bal_PYM_DBT_NRFI_YTD        + bal_PYM_DBT_RFI_YTD
      + bal_RGT_AST_NRFI_YTD        + bal_RGT_AST_RFI_YTD
      + bal_USE_VEH_NRFI_YTD        + bal_USE_VEH_RFI_YTD
      );

   -- Skip the calculation if there is No Income
   IF trc_FrnBenYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.NorCalc',12);

      -- Annualise Fringe Benefits
      trc_FrnBenErn := py_za_tx_utl_01032002.Annualise
                          ( p_YtdInc => trc_FrnBenYtd
                          , p_PtdInc => trc_FrnBenPtd
                          ) + trc_NorErn;
      -- Taxable Fringe Income
      trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbFrnInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.NorCalc',13);
         -- Tax Liability
         trc_TotLibFB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbFrnInc);
         trc_LibFyFB  := trc_TotLibFB - least(trc_TotLibFB,trc_TotLibNI);
         trc_TotLibFB := greatest(trc_TotLibFB,trc_TotLibNI);
         -- DeAnnualise
         trc_LibFpFB := py_za_tx_utl_01032002.DeAnnualise
                           ( trc_LibFyFB
                           , bal_TX_ON_FB_YTD
                           , bal_TX_ON_FB_PTD
                           );
      ELSE
         hr_utility.set_location('py_za_tx_01032002.NorCalc',14);
         -- Set Cascade Figures and Refund
         trc_TotLibFB   := trc_TotLibNI;
         trc_LibFpFB    := -1 * bal_TX_ON_FB_YTD;
         trc_LibFpFBOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.NorCalc',15);
      -- Set Cascade Figures and Refund
      trc_FrnBenErn  := trc_NorErn;
      trc_TxbFrnInc  := trc_TxbNorInc;
      trc_TotLibFB   := trc_TotLibNI;
      trc_LibFpFB    := -1 * bal_TX_ON_FB_YTD;
      trc_LibFpFBOvr := TRUE;
   END IF;

-- Travel Allowance
--
   -- Ytd Travel Allowance
   trc_TrvAllYtd := bal_TA_NRFI_YTD + bal_TA_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_TrvAllYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.NorCalc',16);
      -- Ptd Travel Allowance
      trc_TrvAllPtd := bal_TA_NRFI_PTD + bal_TA_RFI_PTD;
      -- Annualise Travel Allowance
      trc_TrvAllErn := py_za_tx_utl_01032002.Annualise
                          ( p_YtdInc => trc_TrvAllYtd
                          , p_PtdInc => trc_TrvAllPtd
                          ) + trc_FrnBenErn;
      -- Taxable Travel Income
      trc_TxbTrvInc := trc_TrvAllErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbTrvInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.NorCalc',17);
         -- Tax Liability
         trc_TotLibTA := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbTrvInc);
         trc_LibFyTA  := trc_TotLibTA - least(trc_TotLibTA,trc_TotLibFB);
         trc_TotLibTA := greatest(trc_TotLibTA,trc_TotLibFB);
         -- DeAnnualise
         trc_LibFpTA := py_za_tx_utl_01032002.DeAnnualise
                           ( trc_LibFyTA
                           , bal_TX_ON_TA_YTD
                           , bal_TX_ON_TA_PTD
                           );
      ELSE
         hr_utility.set_location('py_za_tx_01032002.NorCalc',18);
         -- Set Cascade Figures and Refund
         trc_TotLibTA   := trc_TotLibFB;
         trc_LibFpTA    := -1 * bal_TX_ON_TA_YTD;
         trc_LibFpTAOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.NorCalc',19);
      -- Set Cascade Figures and Refund
      trc_TrvAllErn  := trc_FrnBenErn;
      trc_TxbTrvInc  := trc_TxbFrnInc;
      trc_TotLibTA   := trc_TotLibFB;
      trc_LibFpTA    := -1 * bal_TX_ON_TA_YTD;
      trc_LibFpTAOvr := TRUE;
   END IF;

-- Bonus Provision
--
   -- Ytd Bonus Prvision
   trc_BonProYtd := bal_BP_YTD;
   -- Skip the calculation if there is No Income
   IF trc_BonProYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.NorCalc',20);
      -- Annualise Bonus Provision
      trc_BonProErn := py_za_tx_utl_01032002.Annualise
                          ( p_YtdInc => trc_BonProYtd
                          , p_PtdInc => trc_BonProPtd
                          ) + trc_TrvAllErn;
      -- Taxable Bonus Provision Income
      trc_TxbBonProInc := trc_BonProErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbBonProInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.NorCalc',21);
         -- Tax Liability
         trc_TotLibBP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbBonProInc);
         trc_LibFyBP  := trc_TotLibBP - least(trc_TotLibBP,trc_TotLibTA);
         trc_TotLibBP := greatest(trc_TotLibBP,trc_TotLibTA);
         -- DeAnnualise
         trc_LibFpBP := py_za_tx_utl_01032002.DeAnnualise
                           ( trc_LibFyBP
                           , bal_TX_ON_BP_YTD
                           , bal_TX_ON_BP_PTD
                           );
      ELSE
         hr_utility.set_location('py_za_tx_01032002.NorCalc',22);
         -- Set Cascade Figures and Refund
         trc_TotLibBP   := trc_TotLibTA;
         trc_LibFpBP    := -1 * bal_TX_ON_BP_YTD;
         trc_LibFpBPOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.NorCalc',23);
      -- Set Cascade Figures and Refund
      trc_BonProErn    := trc_TrvAllErn;
      trc_TxbBonProInc := trc_TxbTrvInc;
      trc_TotLibBP     := trc_TotLibTA;
      trc_LibFpBP      := -1 * bal_TX_ON_BP_YTD;
      trc_LibFpBPOvr   := TRUE;
   END IF;

-- Annual Bonus
--
   -- Ytd Annual Bonus
   trc_AnnBonYtd := bal_AB_NRFI_YTD + bal_AB_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_AnnBonYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.NorCalc',24);
      -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
      -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.NorCalc',25);
         -- Tax Liability
         trc_TotLibAB := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnBonInc);
         trc_LibFyAB  := trc_TotLibAB - least(trc_TotLibAB,trc_TotLibTA);
         trc_TotLibAB := greatest(trc_TotLibAB,trc_TotLibTA);
         -- Check Bonus Provision
         IF trc_BonProYtd <> 0 THEN
            hr_utility.set_location('py_za_tx_01032002.NorCalc',26);
            -- Check Bonus Provision Frequency
            IF dbi_BP_TX_RCV = 'A' THEN
               hr_utility.set_location('py_za_tx_01032002.NorCalc',27);
               trc_LibFpAB := 0;
            ELSE
               hr_utility.set_location('py_za_tx_01032002.NorCalc',28);
               trc_LibFpAB := trc_LibFyAB - ( bal_TX_ON_BP_YTD
                                            + trc_LibFpBP
                                            + bal_TX_ON_AB_YTD);
            END IF;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.NorCalc',29);
            trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.NorCalc',30);
         -- Set Cascade Figures and Refund
         trc_TotLibAB   := trc_TotLibTA;
         trc_LibFpAB    := -1 * bal_TX_ON_AB_YTD;
         trc_LibFpABOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.NorCalc',31);
      -- Set Cascade Figures and Refund
      trc_AnnBonErn    := trc_BonProErn;
      trc_TxbAnnBonInc := trc_TxbBonProInc;
      trc_TotLibAB     := trc_TotLibBP;
      trc_LibFpAB      := -1 * bal_TX_ON_AB_YTD;
      trc_LibFpABOvr   := TRUE;
   END IF;

-- Annual Payments
--
   -- Ytd Annual Payments
   trc_AnnPymYtd :=
      ( bal_AA_PRCHD_RVAL_NRFI_YTD   + bal_AA_PRCHD_RVAL_RFI_YTD
      + bal_ANN_BUR_AND_SCH_NRFI_YTD + bal_ANN_BUR_AND_SCH_RFI_YTD
      + bal_AC_NRFI_YTD              + bal_AC_RFI_YTD
      + bal_ANU_FRM_RET_FND_NRFI_YTD + bal_ANU_FRM_RET_FND_RFI_YTD
      + bal_ARES_TRD_NRFI_YTD        + bal_ARES_TRD_RFI_YTD
      + bal_PRCH_ANU_TXB_NRFI_YTD    + bal_PRCH_ANU_TXB_RFI_YTD
      + bal_TXB_AP_NRFI_YTD          + bal_TXB_AP_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnPymYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.NorCalc',32);
      -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
      -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032002.NorCalc',33);
         -- Tax Liability
         trc_TotLibAP := py_za_tx_utl_01032002.TaxLiability(p_Amt => trc_TxbAnnPymInc);
         trc_LibFyAP  := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibAB);
         trc_TotLibAP := greatest(trc_TotLibAP,trc_TotLibAB);
         hr_utility.set_location('py_za_tx_01032002.NorCalc',34);
         trc_LibFpAP  := trc_LibFyAP - bal_TX_ON_AP_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.NorCalc',35);
         -- Set Cascade Figures and Refund
         trc_TotLibAP   := trc_TotLibAB;
         trc_LibFpAP    := -1 * bal_TX_ON_AP_YTD;
         trc_LibFpAPOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.NorCalc',36);
      -- Set Cascade Figures and Refund
      trc_AnnPymErn    := trc_AnnBonErn;
      trc_TxbAnnPymInc := trc_TxbAnnBonInc;
      trc_TotLibAP     := trc_TotLibAB;
      trc_LibFpAP      := -1 * bal_TX_ON_AP_YTD;
      trc_LibFpAPOvr   := TRUE;
   END IF;

-- Public Office Allowance
--
   -- Ytd Public Office Allowance
   trc_PblOffYtd := bal_PO_NRFI_YTD + bal_PO_RFI_YTD;
   -- Skip the calculation if there is No Income
   IF trc_PblOffYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032002.NorCalc',37);
      -- Ptd Public Office Allowance
      trc_PblOffPtd :=bal_PO_NRFI_PTD + bal_PO_RFI_PTD;
      -- Annualise Public Office Allowance
      trc_PblOffErn := py_za_tx_utl_01032002.Annualise
                          ( p_YtdInc => trc_PblOffYtd
                          , p_PtdInc => trc_PblOffPtd
                          );
      -- Tax Liability
      trc_LibFyPO := trc_PblOffErn * glb_ZA_PBL_TX_RTE / 100;
      trc_LibFpPO := py_za_tx_utl_01032002.DeAnnualise
                        ( trc_LibFyPO
                        , bal_TX_ON_PO_YTD
                        , bal_TX_ON_PO_PTD
                        );
   ELSE
      hr_utility.set_location('py_za_tx_01032002.NorCalc',38);
      -- Set Cascade Figures and Refund
      trc_LibFpPO    := -1 * bal_TX_ON_PO_YTD;
      trc_LibFpPOOvr := TRUE;
   END IF;

-- Net Pay Validation
--
   py_za_tx_utl_01032002.ValidateTaxOns;

   hr_utility.set_location('py_za_tx_01032002.NorCalc',39);

   -- Deemed Remuneration
   WrtHrTrc('trc_TxbDmdRmn:    '||to_char(trc_TxbDmdRmn));
   WrtHrTrc('trc_TotLibDR:     '||to_char(trc_TotLibDR ));
   WrtHrTrc('trc_LibFyDR:      '||to_char(trc_LibFyDR  ));
   WrtHrTrc('trc_LibFpDR:      '||to_char(trc_LibFpDR  ));
   -- Base Income
   WrtHrTrc('trc_BseErn:       '||to_char(trc_BseErn   ));
   WrtHrTrc('trc_TxbBseInc:    '||to_char(trc_TxbBseInc));
   WrtHrTrc('trc_TotLibBse:    '||to_char(trc_TotLibBse));
   -- Normal Income
   WrtHrTrc('trc_NorIncYtd:    '||to_char(trc_NorIncYtd));
   WrtHrTrc('trc_NorIncPtd:    '||to_char(trc_NorIncPtd));
   WrtHrTrc('trc_NorErn:       '||to_char(trc_NorErn   ));
   WrtHrTrc('trc_TxbNorInc:    '||to_char(trc_TxbNorInc));
   WrtHrTrc('trc_TotLibNI:     '||to_char(trc_TotLibNI ));
   WrtHrTrc('trc_LibFyNI:      '||to_char(trc_LibFyNI  ));
   WrtHrTrc('trc_LibFpNI:      '||to_char(trc_LibFpNI  ));
   -- Fringe Benefits
   WrtHrTrc('trc_FrnBenYtd:    '||to_char(trc_FrnBenYtd));
   WrtHrTrc('trc_FrnBenPtd:    '||to_char(trc_FrnBenPtd));
   WrtHrTrc('trc_FrnBenErn:    '||to_char(trc_FrnBenErn));
   WrtHrTrc('trc_TxbFrnInc:    '||to_char(trc_TxbFrnInc));
   WrtHrTrc('trc_TotLibFB:     '||to_char(trc_TotLibFB ));
   WrtHrTrc('trc_LibFyFB:      '||to_char(trc_LibFyFB  ));
   WrtHrTrc('trc_LibFpFB:      '||to_char(trc_LibFpFB  ));
   -- Travel Allowance
   WrtHrTrc('trc_TrvAllYtd:    '||to_char(trc_TrvAllYtd));
   WrtHrTrc('trc_TrvAllPtd:    '||to_char(trc_TrvAllPtd));
   WrtHrTrc('trc_TrvAllErn:    '||to_char(trc_TrvAllErn));
   WrtHrTrc('trc_TxbTrvInc:    '||to_char(trc_TxbTrvInc));
   WrtHrTrc('trc_TotLibTA:     '||to_char(trc_TotLibTA ));
   WrtHrTrc('trc_LibFyTA:      '||to_char(trc_LibFyTA  ));
   WrtHrTrc('trc_LibFpTA:      '||to_char(trc_LibFpTA  ));
   -- Bonus Provision
   WrtHrTrc('trc_BonProYtd:    '||to_char(trc_BonProYtd));
   WrtHrTrc('trc_BonProPtd:    '||to_char(trc_BonProPtd));
   WrtHrTrc('trc_BonProErn:    '||to_char(trc_BonProErn));
   WrtHrTrc('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
   WrtHrTrc('trc_TotLibBP:     '||to_char(trc_TotLibBP ));
   WrtHrTrc('trc_LibFyBP:      '||to_char(trc_LibFyBP  ));
   WrtHrTrc('trc_LibFpBP:      '||to_char(trc_LibFpBP  ));
   -- Annual Bonus
   WrtHrTrc('trc_AnnBonYtd:    '||to_char(trc_AnnBonYtd));
   WrtHrTrc('trc_AnnBonPtd:    '||to_char(trc_AnnBonPtd));
   WrtHrTrc('trc_AnnBonErn:    '||to_char(trc_AnnBonErn));
   WrtHrTrc('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
   WrtHrTrc('trc_TotLibAB:     '||to_char(trc_TotLibAB ));
   WrtHrTrc('trc_LibFyAB:      '||to_char(trc_LibFyAB  ));
   WrtHrTrc('trc_LibFpAB:      '||to_char(trc_LibFpAB  ));
   -- Annual Payments
   WrtHrTrc('trc_AnnPymYtd:    '||to_char(trc_AnnPymYtd));
   WrtHrTrc('trc_AnnPymPtd:    '||to_char(trc_AnnPymPtd));
   WrtHrTrc('trc_AnnPymErn:    '||to_char(trc_AnnPymErn));
   WrtHrTrc('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   WrtHrTrc('trc_TotLibAP:     '||to_char(trc_TotLibAP ));
   WrtHrTrc('trc_LibFyAP:      '||to_char(trc_LibFyAP  ));
   WrtHrTrc('trc_LibFpAP:      '||to_char(trc_LibFpAP  ));
   -- Pubilc Office Allowance
   WrtHrTrc('trc_PblOffYtd:    '||to_char(trc_PblOffYtd));
   WrtHrTrc('trc_PblOffPtd:    '||to_char(trc_PblOffPtd));
   WrtHrTrc('trc_PblOffErn:    '||to_char(trc_PblOffErn));
   WrtHrTrc('trc_LibFyPO:      '||to_char(trc_LibFyPO  ));
   WrtHrTrc('trc_LibFpPO:      '||to_char(trc_LibFpPO  ));

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'NorCalc: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END NorCalc;
-------------------------------------------------------------------------------
-- ZaTxGlb_01032002                                                          --
-- Tax module supporting function                                            --
-------------------------------------------------------------------------------
FUNCTION ZaTxGlb_01032002(
-- Global Values
    p_ZA_ADL_TX_RBT         IN NUMBER DEFAULT 0
   ,p_ZA_ARR_PF_AN_MX_ABT   IN NUMBER DEFAULT 0
   ,p_ZA_ARR_RA_AN_MX_ABT   IN NUMBER DEFAULT 0
   ,p_ZA_TRV_ALL_TX_PRC     IN NUMBER DEFAULT 0
   ,p_ZA_CC_TX_PRC          IN NUMBER DEFAULT 0
   ,p_ZA_LABOUR_BROK_PERC   IN NUMBER DEFAULT 0
   ,p_ZA_PF_AN_MX_ABT       IN NUMBER DEFAULT 0
   ,p_ZA_PF_MX_PRC          IN NUMBER DEFAULT 0
   ,p_ZA_PER_SERV_COMP_PERC IN NUMBER DEFAULT 0
   ,p_ZA_PER_SERV_TRST_PERC IN NUMBER DEFAULT 0
   ,p_ZA_PRI_TX_RBT         IN NUMBER DEFAULT 0
   ,p_ZA_PRI_TX_THRSHLD     IN NUMBER DEFAULT 0
   ,p_ZA_PBL_TX_PRC         IN NUMBER DEFAULT 0
   ,p_ZA_PBL_TX_RTE         IN NUMBER DEFAULT 0
   ,p_ZA_RA_AN_MX_ABT       IN NUMBER DEFAULT 0
   ,p_ZA_RA_MX_PRC          IN NUMBER DEFAULT 0
   ,p_ZA_SC_TX_THRSHLD      IN NUMBER DEFAULT 0
   ,p_ZA_SIT_LIM            IN NUMBER DEFAULT 0
   ,p_ZA_TMP_TX_RTE         IN NUMBER DEFAULT 0
   ,p_ZA_WRK_DYS_PR_YR      IN NUMBER DEFAULT 0
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;
   --id VARCHAR2(30);

BEGIN
   --id := dbms_debug.initialize('JLTX');
   --dbms_debug.debug_on;

-- Initialise Package Globals
-- Global Values
   glb_ZA_ADL_TX_RBT         := p_ZA_ADL_TX_RBT;
   glb_ZA_ARR_PF_AN_MX_ABT   := p_ZA_ARR_PF_AN_MX_ABT;
   glb_ZA_ARR_RA_AN_MX_ABT   := p_ZA_ARR_RA_AN_MX_ABT;
   glb_ZA_TRV_ALL_TX_PRC     := p_ZA_TRV_ALL_TX_PRC;
   glb_ZA_CC_TX_PRC          := p_ZA_CC_TX_PRC;
   glb_ZA_LABOUR_BROK_PERC   := p_ZA_LABOUR_BROK_PERC;
   glb_ZA_PF_AN_MX_ABT       := p_ZA_PF_AN_MX_ABT;
   glb_ZA_PF_MX_PRC          := p_ZA_PF_MX_PRC;
   glb_ZA_PER_SERV_COMP_PERC := p_ZA_PER_SERV_COMP_PERC;
   glb_ZA_PER_SERV_TRST_PERC := p_ZA_PER_SERV_TRST_PERC;
   glb_ZA_PRI_TX_RBT         := p_ZA_PRI_TX_RBT;
   glb_ZA_PRI_TX_THRSHLD     := p_ZA_PRI_TX_THRSHLD;
   glb_ZA_PBL_TX_PRC         := p_ZA_PBL_TX_PRC;
   glb_ZA_PBL_TX_RTE         := p_ZA_PBL_TX_RTE;
   glb_ZA_RA_AN_MX_ABT       := p_ZA_RA_AN_MX_ABT;
   glb_ZA_RA_MX_PRC          := p_ZA_RA_MX_PRC;
   glb_ZA_SC_TX_THRSHLD      := p_ZA_SC_TX_THRSHLD;
   glb_ZA_SIT_LIM            := p_ZA_SIT_LIM;
   glb_ZA_TMP_TX_RTE         := p_ZA_TMP_TX_RTE;
   glb_ZA_WRK_DYS_PR_YR      := p_ZA_WRK_DYS_PR_YR;

   RETURN l_Dum;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxGlb_01032002: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxGlb_01032002;
-------------------------------------------------------------------------------
-- ZaTxDbi_01032002                                                          --
-- Tax module supporting function                                            --
-------------------------------------------------------------------------------
FUNCTION ZaTxDbi_01032002(
-- Database Items
    p_BP_TX_RCV             IN VARCHAR2 DEFAULT 'B'
   ,p_PAY_PROC_PRD_DTE_PD   IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_PER_AGE               IN NUMBER   DEFAULT 0
   ,p_PER_DTE_OF_BRTH       IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_SEA_WRK_DYS_WRK       IN NUMBER   DEFAULT 0
   ,p_SES_DTE               IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_TX_DIR_NUM            IN VARCHAR2 DEFAULT 'NULL'
   ,p_TX_DIR_VAL            IN NUMBER   DEFAULT 0
   ,p_TX_STA                IN VARCHAR2 DEFAULT 'X'
   ,p_ZA_ACT_END_DTE        IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_ZA_ACT_STRT_DTE       IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_ZA_ASG_TX_RTR_PRD     IN VARCHAR2 DEFAULT 'N'
   ,p_ZA_ASG_TX_YR          IN NUMBER   DEFAULT 4712
   ,p_ZA_ASG_TX_YR_END      IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_ZA_ASG_TX_YR_STRT     IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_ZA_CUR_PRD_END_DTE    IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_ZA_CUR_PRD_STRT_DTE   IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_ZA_DYS_IN_YR          IN NUMBER   DEFAULT 0
   ,p_ZA_PAY_PRDS_LFT       IN NUMBER   DEFAULT 0
   ,p_ZA_PAY_PRDS_PER_YR    IN NUMBER   DEFAULT 0
   ,p_ZA_TX_YR_END          IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_ZA_TX_YR_STRT         IN DATE     DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;

BEGIN
-- Initialise Package Globals
-- Database Items
   dbi_BP_TX_RCV           := p_BP_TX_RCV;
   dbi_PAY_PROC_PRD_DTE_PD := p_PAY_PROC_PRD_DTE_PD;
   dbi_PER_AGE             := p_PER_AGE;
   dbi_PER_DTE_OF_BRTH     := p_PER_DTE_OF_BRTH;
   dbi_SEA_WRK_DYS_WRK     := p_SEA_WRK_DYS_WRK;
   dbi_SES_DTE             := p_SES_DTE;
   dbi_TX_DIR_NUM          := p_TX_DIR_NUM;
   dbi_TX_DIR_VAL          := p_TX_DIR_VAL;
   dbi_TX_STA              := p_TX_STA;
   dbi_ZA_ACT_END_DTE      := p_ZA_ACT_END_DTE;
   dbi_ZA_ACT_STRT_DTE     := p_ZA_ACT_STRT_DTE;
   dbi_ZA_ASG_TX_RTR_PRD   := p_ZA_ASG_TX_RTR_PRD;
   dbi_ZA_ASG_TX_YR        := p_ZA_ASG_TX_YR;
   dbi_ZA_ASG_TX_YR_END    := p_ZA_ASG_TX_YR_END;
   dbi_ZA_ASG_TX_YR_STRT   := p_ZA_ASG_TX_YR_STRT;
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
      hr_utility.set_message(801, 'ZaTxDbi_01032002: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxDbi_01032002;
-------------------------------------------------------------------------------
-- ZaTxBal1_01032002                                                         --
-- Tax module supporting function                                            --
-------------------------------------------------------------------------------
FUNCTION ZaTxBal1_01032002(
-- Balances
     p_ANN_ARR_PF_CMTD                     IN NUMBER DEFAULT 0
   , p_ANN_ARR_PF_CYTD                     IN NUMBER DEFAULT 0
   , p_ANN_ARR_PF_RUN                      IN NUMBER DEFAULT 0
   , p_ANN_ARR_PF_PTD                      IN NUMBER DEFAULT 0
   , p_ANN_ARR_PF_YTD                      IN NUMBER DEFAULT 0
   , p_ANN_ARR_RA_CMTD                     IN NUMBER DEFAULT 0
   , p_ANN_ARR_RA_CYTD                     IN NUMBER DEFAULT 0
   , p_ANN_ARR_RA_RUN                      IN NUMBER DEFAULT 0
   , p_ANN_ARR_RA_PTD                      IN NUMBER DEFAULT 0
   , p_ANN_ARR_RA_YTD                      IN NUMBER DEFAULT 0
   , p_AA_PRCHD_RVAL_NRFI_CMTD             IN NUMBER DEFAULT 0
   , p_AA_PRCHD_RVAL_NRFI_RUN              IN NUMBER DEFAULT 0
   , p_AA_PRCHD_RVAL_NRFI_PTD              IN NUMBER DEFAULT 0
   , p_AA_PRCHD_RVAL_NRFI_YTD              IN NUMBER DEFAULT 0
   , p_AA_PRCHD_RVAL_RFI_CMTD              IN NUMBER DEFAULT 0
   , p_AA_PRCHD_RVAL_RFI_RUN               IN NUMBER DEFAULT 0
   , p_AA_PRCHD_RVAL_RFI_PTD               IN NUMBER DEFAULT 0
   , p_AA_PRCHD_RVAL_RFI_YTD               IN NUMBER DEFAULT 0
   , p_AB_NRFI_CMTD                        IN NUMBER DEFAULT 0
   , p_AB_NRFI_RUN                         IN NUMBER DEFAULT 0
   , p_AB_NRFI_PTD                         IN NUMBER DEFAULT 0
   , p_AB_NRFI_YTD                         IN NUMBER DEFAULT 0
   , p_AB_RFI_CMTD                         IN NUMBER DEFAULT 0
   , p_AB_RFI_RUN                          IN NUMBER DEFAULT 0
   , p_AB_RFI_PTD                          IN NUMBER DEFAULT 0
   , p_AB_RFI_YTD                          IN NUMBER DEFAULT 0
   , p_ANN_BUR_AND_SCH_NRFI_CMTD           IN NUMBER DEFAULT 0
   , p_ANN_BUR_AND_SCH_NRFI_RUN            IN NUMBER DEFAULT 0
   , p_ANN_BUR_AND_SCH_NRFI_PTD            IN NUMBER DEFAULT 0
   , p_ANN_BUR_AND_SCH_NRFI_YTD            IN NUMBER DEFAULT 0
   , p_ANN_BUR_AND_SCH_RFI_CMTD            IN NUMBER DEFAULT 0
   , p_ANN_BUR_AND_SCH_RFI_RUN             IN NUMBER DEFAULT 0
   , p_ANN_BUR_AND_SCH_RFI_PTD             IN NUMBER DEFAULT 0
   , p_ANN_BUR_AND_SCH_RFI_YTD             IN NUMBER DEFAULT 0
   , p_AC_NRFI_CMTD                        IN NUMBER DEFAULT 0
   , p_AC_NRFI_RUN                         IN NUMBER DEFAULT 0
   , p_AC_NRFI_PTD                         IN NUMBER DEFAULT 0
   , p_AC_NRFI_YTD                         IN NUMBER DEFAULT 0
   , p_AC_RFI_CMTD                         IN NUMBER DEFAULT 0
   , p_AC_RFI_RUN                          IN NUMBER DEFAULT 0
   , p_AC_RFI_PTD                          IN NUMBER DEFAULT 0
   , p_AC_RFI_YTD                          IN NUMBER DEFAULT 0
   , p_ANN_PF_CMTD                         IN NUMBER DEFAULT 0
   , p_ANN_PF_CYTD                         IN NUMBER DEFAULT 0
   , p_ANN_PF_RUN                          IN NUMBER DEFAULT 0
   , p_ANN_PF_PTD                          IN NUMBER DEFAULT 0
   , p_ANN_PF_YTD                          IN NUMBER DEFAULT 0
   , p_ARES_TRD_NRFI_CMTD                  IN NUMBER DEFAULT 0
   , p_ARES_TRD_NRFI_RUN                   IN NUMBER DEFAULT 0
   , p_ARES_TRD_NRFI_PTD                   IN NUMBER DEFAULT 0
   , p_ARES_TRD_NRFI_YTD                   IN NUMBER DEFAULT 0
   , p_ARES_TRD_RFI_CMTD                   IN NUMBER DEFAULT 0
   , p_ARES_TRD_RFI_RUN                    IN NUMBER DEFAULT 0
   , p_ARES_TRD_RFI_PTD                    IN NUMBER DEFAULT 0
   , p_ARES_TRD_RFI_YTD                    IN NUMBER DEFAULT 0
   , p_ANN_RA_CMTD                         IN NUMBER DEFAULT 0
   , p_ANN_RA_CYTD                         IN NUMBER DEFAULT 0
   , p_ANN_RA_RUN                          IN NUMBER DEFAULT 0
   , p_ANN_RA_PTD                          IN NUMBER DEFAULT 0
   , p_ANN_RA_YTD                          IN NUMBER DEFAULT 0
   , p_ANU_FRM_RET_FND_NRFI_CMTD           IN NUMBER DEFAULT 0
   , p_ANU_FRM_RET_FND_NRFI_RUN            IN NUMBER DEFAULT 0
   , p_ANU_FRM_RET_FND_NRFI_PTD            IN NUMBER DEFAULT 0
   , p_ANU_FRM_RET_FND_NRFI_YTD            IN NUMBER DEFAULT 0
   , p_ANU_FRM_RET_FND_RFI_CMTD            IN NUMBER DEFAULT 0
   , p_ANU_FRM_RET_FND_RFI_RUN             IN NUMBER DEFAULT 0
   , p_ANU_FRM_RET_FND_RFI_PTD             IN NUMBER DEFAULT 0
   , p_ANU_FRM_RET_FND_RFI_YTD             IN NUMBER DEFAULT 0
   , p_ARR_PF_CMTD                         IN NUMBER DEFAULT 0
   , p_ARR_PF_CYTD                         IN NUMBER DEFAULT 0
   , p_ARR_PF_PTD                          IN NUMBER DEFAULT 0
   , p_ARR_PF_YTD                          IN NUMBER DEFAULT 0
   , p_ARR_RA_CMTD                         IN NUMBER DEFAULT 0
   , p_ARR_RA_CYTD                         IN NUMBER DEFAULT 0
   , p_ARR_RA_PTD                          IN NUMBER DEFAULT 0
   , p_ARR_RA_YTD                          IN NUMBER DEFAULT 0
   , p_AST_PRCHD_RVAL_NRFI_CMTD            IN NUMBER DEFAULT 0
   , p_AST_PRCHD_RVAL_NRFI_CYTD            IN NUMBER DEFAULT 0
   , p_AST_PRCHD_RVAL_NRFI_RUN             IN NUMBER DEFAULT 0
   , p_AST_PRCHD_RVAL_NRFI_PTD             IN NUMBER DEFAULT 0
   , p_AST_PRCHD_RVAL_NRFI_YTD             IN NUMBER DEFAULT 0
   , p_AST_PRCHD_RVAL_RFI_CMTD             IN NUMBER DEFAULT 0
   , p_AST_PRCHD_RVAL_RFI_CYTD             IN NUMBER DEFAULT 0
   , p_AST_PRCHD_RVAL_RFI_RUN              IN NUMBER DEFAULT 0
   , p_AST_PRCHD_RVAL_RFI_PTD              IN NUMBER DEFAULT 0
   , p_AST_PRCHD_RVAL_RFI_YTD              IN NUMBER DEFAULT 0
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;

BEGIN
-- Balances
   bal_ANN_ARR_PF_CMTD            := p_ANN_ARR_PF_CMTD;
   bal_ANN_ARR_PF_CYTD            := p_ANN_ARR_PF_CYTD;
   bal_ANN_ARR_PF_RUN             := p_ANN_ARR_PF_RUN;
   bal_ANN_ARR_PF_PTD             := p_ANN_ARR_PF_PTD;
   bal_ANN_ARR_PF_YTD             := p_ANN_ARR_PF_YTD;
   bal_ANN_ARR_RA_CMTD            := p_ANN_ARR_RA_CMTD;
   bal_ANN_ARR_RA_CYTD            := p_ANN_ARR_RA_CYTD;
   bal_ANN_ARR_RA_RUN             := p_ANN_ARR_RA_RUN;
   bal_ANN_ARR_RA_PTD             := p_ANN_ARR_RA_PTD;
   bal_ANN_ARR_RA_YTD             := p_ANN_ARR_RA_YTD;
   bal_AA_PRCHD_RVAL_NRFI_CMTD    := p_AA_PRCHD_RVAL_NRFI_CMTD;
   bal_AA_PRCHD_RVAL_NRFI_RUN     := p_AA_PRCHD_RVAL_NRFI_RUN;
   bal_AA_PRCHD_RVAL_NRFI_PTD     := p_AA_PRCHD_RVAL_NRFI_PTD;
   bal_AA_PRCHD_RVAL_NRFI_YTD     := p_AA_PRCHD_RVAL_NRFI_YTD;
   bal_AA_PRCHD_RVAL_RFI_CMTD     := p_AA_PRCHD_RVAL_RFI_CMTD;
   bal_AA_PRCHD_RVAL_RFI_RUN      := p_AA_PRCHD_RVAL_RFI_RUN;
   bal_AA_PRCHD_RVAL_RFI_PTD      := p_AA_PRCHD_RVAL_RFI_PTD;
   bal_AA_PRCHD_RVAL_RFI_YTD      := p_AA_PRCHD_RVAL_RFI_YTD;
   bal_AB_NRFI_CMTD               := p_AB_NRFI_CMTD;
   bal_AB_NRFI_RUN                := p_AB_NRFI_RUN;
   bal_AB_NRFI_PTD                := p_AB_NRFI_PTD;
   bal_AB_NRFI_YTD                := p_AB_NRFI_YTD;
   bal_AB_RFI_CMTD                := p_AB_RFI_CMTD;
   bal_AB_RFI_RUN                 := p_AB_RFI_RUN;
   bal_AB_RFI_PTD                 := p_AB_RFI_PTD;
   bal_AB_RFI_YTD                 := p_AB_RFI_YTD;
   bal_ANN_BUR_AND_SCH_NRFI_CMTD  := p_ANN_BUR_AND_SCH_NRFI_CMTD;
   bal_ANN_BUR_AND_SCH_NRFI_RUN   := p_ANN_BUR_AND_SCH_NRFI_RUN;
   bal_ANN_BUR_AND_SCH_NRFI_PTD   := p_ANN_BUR_AND_SCH_NRFI_PTD;
   bal_ANN_BUR_AND_SCH_NRFI_YTD   := p_ANN_BUR_AND_SCH_NRFI_YTD;
   bal_ANN_BUR_AND_SCH_RFI_CMTD   := p_ANN_BUR_AND_SCH_RFI_CMTD;
   bal_ANN_BUR_AND_SCH_RFI_RUN    := p_ANN_BUR_AND_SCH_RFI_RUN;
   bal_ANN_BUR_AND_SCH_RFI_PTD    := p_ANN_BUR_AND_SCH_RFI_PTD;
   bal_ANN_BUR_AND_SCH_RFI_YTD    := p_ANN_BUR_AND_SCH_RFI_YTD;
   bal_AC_NRFI_CMTD               := p_AC_NRFI_CMTD;
   bal_AC_NRFI_RUN                := p_AC_NRFI_RUN;
   bal_AC_NRFI_PTD                := p_AC_NRFI_PTD;
   bal_AC_NRFI_YTD                := p_AC_NRFI_YTD;
   bal_AC_RFI_CMTD                := p_AC_RFI_CMTD;
   bal_AC_RFI_RUN                 := p_AC_RFI_RUN;
   bal_AC_RFI_PTD                 := p_AC_RFI_PTD;
   bal_AC_RFI_YTD                 := p_AC_RFI_YTD;
   bal_ANN_PF_CMTD                := p_ANN_PF_CMTD;
   bal_ANN_PF_CYTD                := p_ANN_PF_CYTD;
   bal_ANN_PF_RUN                 := p_ANN_PF_RUN;
   bal_ANN_PF_PTD                 := p_ANN_PF_PTD;
   bal_ANN_PF_YTD                 := p_ANN_PF_YTD;
   bal_ARES_TRD_NRFI_CMTD         := p_ARES_TRD_NRFI_CMTD;
   bal_ARES_TRD_NRFI_RUN          := p_ARES_TRD_NRFI_RUN;
   bal_ARES_TRD_NRFI_PTD          := p_ARES_TRD_NRFI_PTD;
   bal_ARES_TRD_NRFI_YTD          := p_ARES_TRD_NRFI_YTD;
   bal_ARES_TRD_RFI_CMTD          := p_ARES_TRD_RFI_CMTD;
   bal_ARES_TRD_RFI_RUN           := p_ARES_TRD_RFI_RUN;
   bal_ARES_TRD_RFI_PTD           := p_ARES_TRD_RFI_PTD;
   bal_ARES_TRD_RFI_YTD           := p_ARES_TRD_RFI_YTD;
   bal_ANN_RA_CMTD                := p_ANN_RA_CMTD;
   bal_ANN_RA_CYTD                := p_ANN_RA_CYTD;
   bal_ANN_RA_RUN                 := p_ANN_RA_RUN;
   bal_ANN_RA_PTD                 := p_ANN_RA_PTD;
   bal_ANN_RA_YTD                 := p_ANN_RA_YTD;
   bal_ANU_FRM_RET_FND_NRFI_CMTD  := p_ANU_FRM_RET_FND_NRFI_CMTD;
   bal_ANU_FRM_RET_FND_NRFI_RUN   := p_ANU_FRM_RET_FND_NRFI_RUN;
   bal_ANU_FRM_RET_FND_NRFI_PTD   := p_ANU_FRM_RET_FND_NRFI_PTD;
   bal_ANU_FRM_RET_FND_NRFI_YTD   := p_ANU_FRM_RET_FND_NRFI_YTD;
   bal_ANU_FRM_RET_FND_RFI_CMTD   := p_ANU_FRM_RET_FND_RFI_CMTD;
   bal_ANU_FRM_RET_FND_RFI_RUN    := p_ANU_FRM_RET_FND_RFI_RUN;
   bal_ANU_FRM_RET_FND_RFI_PTD    := p_ANU_FRM_RET_FND_RFI_PTD;
   bal_ANU_FRM_RET_FND_RFI_YTD    := p_ANU_FRM_RET_FND_RFI_YTD;
   bal_ARR_PF_CMTD                := p_ARR_PF_CMTD;
   bal_ARR_PF_CYTD                := p_ARR_PF_CYTD;
   bal_ARR_PF_PTD                 := p_ARR_PF_PTD;
   bal_ARR_PF_YTD                 := p_ARR_PF_YTD;
   bal_ARR_RA_CMTD                := p_ARR_RA_CMTD;
   bal_ARR_RA_CYTD                := p_ARR_RA_CYTD;
   bal_ARR_RA_PTD                 := p_ARR_RA_PTD;
   bal_ARR_RA_YTD                 := p_ARR_RA_YTD;
   bal_AST_PRCHD_RVAL_NRFI_CMTD   := p_AST_PRCHD_RVAL_NRFI_CMTD;
   bal_AST_PRCHD_RVAL_NRFI_CYTD   := p_AST_PRCHD_RVAL_NRFI_CYTD;
   bal_AST_PRCHD_RVAL_NRFI_RUN    := p_AST_PRCHD_RVAL_NRFI_RUN;
   bal_AST_PRCHD_RVAL_NRFI_PTD    := p_AST_PRCHD_RVAL_NRFI_PTD;
   bal_AST_PRCHD_RVAL_NRFI_YTD    := p_AST_PRCHD_RVAL_NRFI_YTD;
   bal_AST_PRCHD_RVAL_RFI_CMTD    := p_AST_PRCHD_RVAL_RFI_CMTD;
   bal_AST_PRCHD_RVAL_RFI_CYTD    := p_AST_PRCHD_RVAL_RFI_CYTD;
   bal_AST_PRCHD_RVAL_RFI_RUN     := p_AST_PRCHD_RVAL_RFI_RUN;
   bal_AST_PRCHD_RVAL_RFI_PTD     := p_AST_PRCHD_RVAL_RFI_PTD;
   bal_AST_PRCHD_RVAL_RFI_YTD     := p_AST_PRCHD_RVAL_RFI_YTD;

   RETURN l_Dum;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal1_01032002: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal1_01032002;
-------------------------------------------------------------------------------
-- ZaTxBal2_01032002                                                         --
-- Tax module supporting function                                            --
-------------------------------------------------------------------------------
FUNCTION ZaTxBal2_01032002(
-- Balances
     p_BP_CMTD                             IN NUMBER DEFAULT 0
   , p_BP_PTD                              IN NUMBER DEFAULT 0
   , p_BP_YTD                              IN NUMBER DEFAULT 0
   , p_BUR_AND_SCH_NRFI_CMTD               IN NUMBER DEFAULT 0
   , p_BUR_AND_SCH_NRFI_CYTD               IN NUMBER DEFAULT 0
   , p_BUR_AND_SCH_NRFI_RUN                IN NUMBER DEFAULT 0
   , p_BUR_AND_SCH_NRFI_PTD                IN NUMBER DEFAULT 0
   , p_BUR_AND_SCH_NRFI_YTD                IN NUMBER DEFAULT 0
   , p_BUR_AND_SCH_RFI_CMTD                IN NUMBER DEFAULT 0
   , p_BUR_AND_SCH_RFI_CYTD                IN NUMBER DEFAULT 0
   , p_BUR_AND_SCH_RFI_RUN                 IN NUMBER DEFAULT 0
   , p_BUR_AND_SCH_RFI_PTD                 IN NUMBER DEFAULT 0
   , p_BUR_AND_SCH_RFI_YTD                 IN NUMBER DEFAULT 0
   , p_COMM_NRFI_CMTD                      IN NUMBER DEFAULT 0
   , p_COMM_NRFI_CYTD                      IN NUMBER DEFAULT 0
   , p_COMM_NRFI_RUN                       IN NUMBER DEFAULT 0
   , p_COMM_NRFI_PTD                       IN NUMBER DEFAULT 0
   , p_COMM_NRFI_YTD                       IN NUMBER DEFAULT 0
   , p_COMM_RFI_CMTD                       IN NUMBER DEFAULT 0
   , p_COMM_RFI_CYTD                       IN NUMBER DEFAULT 0
   , p_COMM_RFI_RUN                        IN NUMBER DEFAULT 0
   , p_COMM_RFI_PTD                        IN NUMBER DEFAULT 0
   , p_COMM_RFI_YTD                        IN NUMBER DEFAULT 0
   , p_COMP_ALL_NRFI_CMTD                  IN NUMBER DEFAULT 0
   , p_COMP_ALL_NRFI_CYTD                  IN NUMBER DEFAULT 0
   , p_COMP_ALL_NRFI_RUN                   IN NUMBER DEFAULT 0
   , p_COMP_ALL_NRFI_PTD                   IN NUMBER DEFAULT 0
   , p_COMP_ALL_NRFI_YTD                   IN NUMBER DEFAULT 0
   , p_COMP_ALL_RFI_CMTD                   IN NUMBER DEFAULT 0
   , p_COMP_ALL_RFI_CYTD                   IN NUMBER DEFAULT 0
   , p_COMP_ALL_RFI_RUN                    IN NUMBER DEFAULT 0
   , p_COMP_ALL_RFI_PTD                    IN NUMBER DEFAULT 0
   , p_COMP_ALL_RFI_YTD                    IN NUMBER DEFAULT 0
   , p_CUR_PF_CMTD                         IN NUMBER DEFAULT 0
   , p_CUR_PF_CYTD                         IN NUMBER DEFAULT 0
   , p_CUR_PF_RUN                          IN NUMBER DEFAULT 0
   , p_CUR_PF_PTD                          IN NUMBER DEFAULT 0
   , p_CUR_PF_YTD                          IN NUMBER DEFAULT 0
   , p_CUR_RA_CMTD                         IN NUMBER DEFAULT 0
   , p_CUR_RA_CYTD                         IN NUMBER DEFAULT 0
   , p_CUR_RA_RUN                          IN NUMBER DEFAULT 0
   , p_CUR_RA_PTD                          IN NUMBER DEFAULT 0
   , p_CUR_RA_YTD                          IN NUMBER DEFAULT 0
   , p_DIR_DMD_RMN_ITD                     IN NUMBER DEFAULT 0
   , p_ENT_ALL_NRFI_CMTD                   IN NUMBER DEFAULT 0
   , p_ENT_ALL_NRFI_CYTD                   IN NUMBER DEFAULT 0
   , p_ENT_ALL_NRFI_RUN                    IN NUMBER DEFAULT 0
   , p_ENT_ALL_NRFI_PTD                    IN NUMBER DEFAULT 0
   , p_ENT_ALL_NRFI_YTD                    IN NUMBER DEFAULT 0
   , p_ENT_ALL_RFI_CMTD                    IN NUMBER DEFAULT 0
   , p_ENT_ALL_RFI_CYTD                    IN NUMBER DEFAULT 0
   , p_ENT_ALL_RFI_RUN                     IN NUMBER DEFAULT 0
   , p_ENT_ALL_RFI_PTD                     IN NUMBER DEFAULT 0
   , p_ENT_ALL_RFI_YTD                     IN NUMBER DEFAULT 0
   , p_EXC_ARR_PEN_ITD                     IN NUMBER DEFAULT 0
   , p_EXC_ARR_PEN_PTD                     IN NUMBER DEFAULT 0
   , p_EXC_ARR_PEN_YTD                     IN NUMBER DEFAULT 0
   , p_EXC_ARR_RA_ITD                      IN NUMBER DEFAULT 0
   , p_EXC_ARR_RA_PTD                      IN NUMBER DEFAULT 0
   , p_EXC_ARR_RA_YTD                      IN NUMBER DEFAULT 0
   , p_FREE_ACCOM_NRFI_CMTD                IN NUMBER DEFAULT 0
   , p_FREE_ACCOM_NRFI_CYTD                IN NUMBER DEFAULT 0
   , p_FREE_ACCOM_NRFI_RUN                 IN NUMBER DEFAULT 0
   , p_FREE_ACCOM_NRFI_PTD                 IN NUMBER DEFAULT 0
   , p_FREE_ACCOM_NRFI_YTD                 IN NUMBER DEFAULT 0
   , p_FREE_ACCOM_RFI_CMTD                 IN NUMBER DEFAULT 0
   , p_FREE_ACCOM_RFI_CYTD                 IN NUMBER DEFAULT 0
   , p_FREE_ACCOM_RFI_RUN                  IN NUMBER DEFAULT 0
   , p_FREE_ACCOM_RFI_PTD                  IN NUMBER DEFAULT 0
   , p_FREE_ACCOM_RFI_YTD                  IN NUMBER DEFAULT 0
   , p_FREE_SERV_NRFI_CMTD                 IN NUMBER DEFAULT 0
   , p_FREE_SERV_NRFI_CYTD                 IN NUMBER DEFAULT 0
   , p_FREE_SERV_NRFI_RUN                  IN NUMBER DEFAULT 0
   , p_FREE_SERV_NRFI_PTD                  IN NUMBER DEFAULT 0
   , p_FREE_SERV_NRFI_YTD                  IN NUMBER DEFAULT 0
   , p_FREE_SERV_RFI_CMTD                  IN NUMBER DEFAULT 0
   , p_FREE_SERV_RFI_CYTD                  IN NUMBER DEFAULT 0
   , p_FREE_SERV_RFI_RUN                   IN NUMBER DEFAULT 0
   , p_FREE_SERV_RFI_PTD                   IN NUMBER DEFAULT 0
   , p_FREE_SERV_RFI_YTD                   IN NUMBER DEFAULT 0
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;

BEGIN
-- Balances
   bal_BP_CMTD                    := p_BP_CMTD;
   bal_BP_PTD                     := p_BP_PTD;
   bal_BP_YTD                     := p_BP_YTD;
   bal_BUR_AND_SCH_NRFI_CMTD      := p_BUR_AND_SCH_NRFI_CMTD;
   bal_BUR_AND_SCH_NRFI_CYTD      := p_BUR_AND_SCH_NRFI_CYTD;
   bal_BUR_AND_SCH_NRFI_RUN       := p_BUR_AND_SCH_NRFI_RUN;
   bal_BUR_AND_SCH_NRFI_PTD       := p_BUR_AND_SCH_NRFI_PTD;
   bal_BUR_AND_SCH_NRFI_YTD       := p_BUR_AND_SCH_NRFI_YTD;
   bal_BUR_AND_SCH_RFI_CMTD       := p_BUR_AND_SCH_RFI_CMTD;
   bal_BUR_AND_SCH_RFI_CYTD       := p_BUR_AND_SCH_RFI_CYTD;
   bal_BUR_AND_SCH_RFI_RUN        := p_BUR_AND_SCH_RFI_RUN;
   bal_BUR_AND_SCH_RFI_PTD        := p_BUR_AND_SCH_RFI_PTD;
   bal_BUR_AND_SCH_RFI_YTD        := p_BUR_AND_SCH_RFI_YTD;
   bal_COMM_NRFI_CMTD             := p_COMM_NRFI_CMTD;
   bal_COMM_NRFI_CYTD             := p_COMM_NRFI_CYTD;
   bal_COMM_NRFI_RUN              := p_COMM_NRFI_RUN;
   bal_COMM_NRFI_PTD              := p_COMM_NRFI_PTD;
   bal_COMM_NRFI_YTD              := p_COMM_NRFI_YTD;
   bal_COMM_RFI_CMTD              := p_COMM_RFI_CMTD;
   bal_COMM_RFI_CYTD              := p_COMM_RFI_CYTD;
   bal_COMM_RFI_RUN               := p_COMM_RFI_RUN;
   bal_COMM_RFI_PTD               := p_COMM_RFI_PTD;
   bal_COMM_RFI_YTD               := p_COMM_RFI_YTD;
   bal_COMP_ALL_NRFI_CMTD         := p_COMP_ALL_NRFI_CMTD;
   bal_COMP_ALL_NRFI_CYTD         := p_COMP_ALL_NRFI_CYTD;
   bal_COMP_ALL_NRFI_RUN          := p_COMP_ALL_NRFI_RUN;
   bal_COMP_ALL_NRFI_PTD          := p_COMP_ALL_NRFI_PTD;
   bal_COMP_ALL_NRFI_YTD          := p_COMP_ALL_NRFI_YTD;
   bal_COMP_ALL_RFI_CMTD          := p_COMP_ALL_RFI_CMTD;
   bal_COMP_ALL_RFI_CYTD          := p_COMP_ALL_RFI_CYTD;
   bal_COMP_ALL_RFI_RUN           := p_COMP_ALL_RFI_RUN;
   bal_COMP_ALL_RFI_PTD           := p_COMP_ALL_RFI_PTD;
   bal_COMP_ALL_RFI_YTD           := p_COMP_ALL_RFI_YTD;
   bal_PF_CMTD                    := p_CUR_PF_CMTD;
   bal_PF_CYTD                    := p_CUR_PF_CYTD;
   bal_PF_RUN                     := p_CUR_PF_RUN;
   bal_PF_PTD                     := p_CUR_PF_PTD;
   bal_PF_YTD                     := p_CUR_PF_YTD;
   bal_RA_CMTD                    := p_CUR_RA_CMTD;
   bal_RA_CYTD                    := p_CUR_RA_CYTD;
   bal_RA_RUN                     := p_CUR_RA_RUN;
   bal_RA_PTD                     := p_CUR_RA_PTD;
   bal_RA_YTD                     := p_CUR_RA_YTD;
   bal_DIR_DMD_RMN_ITD            := p_DIR_DMD_RMN_ITD;
   bal_ENT_ALL_NRFI_CMTD          := p_ENT_ALL_NRFI_CMTD;
   bal_ENT_ALL_NRFI_CYTD          := p_ENT_ALL_NRFI_CYTD;
   bal_ENT_ALL_NRFI_RUN           := p_ENT_ALL_NRFI_RUN;
   bal_ENT_ALL_NRFI_PTD           := p_ENT_ALL_NRFI_PTD;
   bal_ENT_ALL_NRFI_YTD           := p_ENT_ALL_NRFI_YTD;
   bal_ENT_ALL_RFI_CMTD           := p_ENT_ALL_RFI_CMTD;
   bal_ENT_ALL_RFI_CYTD           := p_ENT_ALL_RFI_CYTD;
   bal_ENT_ALL_RFI_RUN            := p_ENT_ALL_RFI_RUN;
   bal_ENT_ALL_RFI_PTD            := p_ENT_ALL_RFI_PTD;
   bal_ENT_ALL_RFI_YTD            := p_ENT_ALL_RFI_YTD;
   bal_EXC_ARR_PEN_ITD            := p_EXC_ARR_PEN_ITD;
   bal_EXC_ARR_PEN_PTD            := p_EXC_ARR_PEN_PTD;
   bal_EXC_ARR_PEN_YTD            := p_EXC_ARR_PEN_YTD;
   bal_EXC_ARR_RA_ITD             := p_EXC_ARR_RA_ITD;
   bal_EXC_ARR_RA_PTD             := p_EXC_ARR_RA_PTD;
   bal_EXC_ARR_RA_YTD             := p_EXC_ARR_RA_YTD;
   bal_FREE_ACCOM_NRFI_CMTD       := p_FREE_ACCOM_NRFI_CMTD;
   bal_FREE_ACCOM_NRFI_CYTD       := p_FREE_ACCOM_NRFI_CYTD;
   bal_FREE_ACCOM_NRFI_RUN        := p_FREE_ACCOM_NRFI_RUN;
   bal_FREE_ACCOM_NRFI_PTD        := p_FREE_ACCOM_NRFI_PTD;
   bal_FREE_ACCOM_NRFI_YTD        := p_FREE_ACCOM_NRFI_YTD;
   bal_FREE_ACCOM_RFI_CMTD        := p_FREE_ACCOM_RFI_CMTD;
   bal_FREE_ACCOM_RFI_CYTD        := p_FREE_ACCOM_RFI_CYTD;
   bal_FREE_ACCOM_RFI_RUN         := p_FREE_ACCOM_RFI_RUN;
   bal_FREE_ACCOM_RFI_PTD         := p_FREE_ACCOM_RFI_PTD;
   bal_FREE_ACCOM_RFI_YTD         := p_FREE_ACCOM_RFI_YTD;
   bal_FREE_SERV_NRFI_CMTD        := p_FREE_SERV_NRFI_CMTD;
   bal_FREE_SERV_NRFI_CYTD        := p_FREE_SERV_NRFI_CYTD;
   bal_FREE_SERV_NRFI_RUN         := p_FREE_SERV_NRFI_RUN;
   bal_FREE_SERV_NRFI_PTD         := p_FREE_SERV_NRFI_PTD;
   bal_FREE_SERV_NRFI_YTD         := p_FREE_SERV_NRFI_YTD;
   bal_FREE_SERV_RFI_CMTD         := p_FREE_SERV_RFI_CMTD;
   bal_FREE_SERV_RFI_CYTD         := p_FREE_SERV_RFI_CYTD;
   bal_FREE_SERV_RFI_RUN          := p_FREE_SERV_RFI_RUN;
   bal_FREE_SERV_RFI_PTD          := p_FREE_SERV_RFI_PTD;
   bal_FREE_SERV_RFI_YTD          := p_FREE_SERV_RFI_YTD;

   RETURN l_Dum;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal2_01032002: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal2_01032002;
-------------------------------------------------------------------------------
-- ZaTxBal3_01032002                                                         --
-- Tax module supporting function                                            --
-------------------------------------------------------------------------------
FUNCTION ZaTxBal3_01032002(
-- Balances
     p_LOW_LOANS_NRFI_CMTD                 IN NUMBER DEFAULT 0
   , p_LOW_LOANS_NRFI_CYTD                 IN NUMBER DEFAULT 0
   , p_LOW_LOANS_NRFI_RUN                  IN NUMBER DEFAULT 0
   , p_LOW_LOANS_NRFI_PTD                  IN NUMBER DEFAULT 0
   , p_LOW_LOANS_NRFI_YTD                  IN NUMBER DEFAULT 0
   , p_LOW_LOANS_RFI_CMTD                  IN NUMBER DEFAULT 0
   , p_LOW_LOANS_RFI_CYTD                  IN NUMBER DEFAULT 0
   , p_LOW_LOANS_RFI_RUN                   IN NUMBER DEFAULT 0
   , p_LOW_LOANS_RFI_PTD                   IN NUMBER DEFAULT 0
   , p_LOW_LOANS_RFI_YTD                   IN NUMBER DEFAULT 0
   , p_MLS_AND_VOUCH_NRFI_CMTD             IN NUMBER DEFAULT 0
   , p_MLS_AND_VOUCH_NRFI_CYTD             IN NUMBER DEFAULT 0
   , p_MLS_AND_VOUCH_NRFI_RUN              IN NUMBER DEFAULT 0
   , p_MLS_AND_VOUCH_NRFI_PTD              IN NUMBER DEFAULT 0
   , p_MLS_AND_VOUCH_NRFI_YTD              IN NUMBER DEFAULT 0
   , p_MLS_AND_VOUCH_RFI_CMTD              IN NUMBER DEFAULT 0
   , p_MLS_AND_VOUCH_RFI_CYTD              IN NUMBER DEFAULT 0
   , p_MLS_AND_VOUCH_RFI_RUN               IN NUMBER DEFAULT 0
   , p_MLS_AND_VOUCH_RFI_PTD               IN NUMBER DEFAULT 0
   , p_MLS_AND_VOUCH_RFI_YTD               IN NUMBER DEFAULT 0
   , p_MED_CONTR_CMTD                      IN NUMBER DEFAULT 0
   , p_MED_CONTR_CYTD                      IN NUMBER DEFAULT 0
   , p_MED_CONTR_RUN                       IN NUMBER DEFAULT 0
   , p_MED_CONTR_PTD                       IN NUMBER DEFAULT 0
   , p_MED_CONTR_YTD                       IN NUMBER DEFAULT 0
   , p_MED_PAID_NRFI_CMTD                  IN NUMBER DEFAULT 0
   , p_MED_PAID_NRFI_CYTD                  IN NUMBER DEFAULT 0
   , p_MED_PAID_NRFI_RUN                   IN NUMBER DEFAULT 0
   , p_MED_PAID_NRFI_PTD                   IN NUMBER DEFAULT 0
   , p_MED_PAID_NRFI_YTD                   IN NUMBER DEFAULT 0
   , p_MED_PAID_RFI_CMTD                   IN NUMBER DEFAULT 0
   , p_MED_PAID_RFI_CYTD                   IN NUMBER DEFAULT 0
   , p_MED_PAID_RFI_RUN                    IN NUMBER DEFAULT 0
   , p_MED_PAID_RFI_PTD                    IN NUMBER DEFAULT 0
   , p_MED_PAID_RFI_YTD                    IN NUMBER DEFAULT 0
   , p_NET_PAY_RUN                         IN NUMBER DEFAULT 0
   , p_NET_TXB_INC_CMTD                    IN NUMBER DEFAULT 0
   , p_OTHER_TXB_ALL_NRFI_CMTD             IN NUMBER DEFAULT 0
   , p_OTHER_TXB_ALL_NRFI_CYTD             IN NUMBER DEFAULT 0
   , p_OTHER_TXB_ALL_NRFI_RUN              IN NUMBER DEFAULT 0
   , p_OTHER_TXB_ALL_NRFI_PTD              IN NUMBER DEFAULT 0
   , p_OTHER_TXB_ALL_NRFI_YTD              IN NUMBER DEFAULT 0
   , p_OTHER_TXB_ALL_RFI_CMTD              IN NUMBER DEFAULT 0
   , p_OTHER_TXB_ALL_RFI_CYTD              IN NUMBER DEFAULT 0
   , p_OTHER_TXB_ALL_RFI_RUN               IN NUMBER DEFAULT 0
   , p_OTHER_TXB_ALL_RFI_PTD               IN NUMBER DEFAULT 0
   , p_OTHER_TXB_ALL_RFI_YTD               IN NUMBER DEFAULT 0
   , p_OVTM_NRFI_CMTD                      IN NUMBER DEFAULT 0
   , p_OVTM_NRFI_CYTD                      IN NUMBER DEFAULT 0
   , p_OVTM_NRFI_RUN                       IN NUMBER DEFAULT 0
   , p_OVTM_NRFI_PTD                       IN NUMBER DEFAULT 0
   , p_OVTM_NRFI_YTD                       IN NUMBER DEFAULT 0
   , p_OVTM_RFI_CMTD                       IN NUMBER DEFAULT 0
   , p_OVTM_RFI_CYTD                       IN NUMBER DEFAULT 0
   , p_OVTM_RFI_RUN                        IN NUMBER DEFAULT 0
   , p_OVTM_RFI_PTD                        IN NUMBER DEFAULT 0
   , p_OVTM_RFI_YTD                        IN NUMBER DEFAULT 0
   , p_PAYE_YTD                            IN NUMBER DEFAULT 0
   , p_PYM_DBT_NRFI_CMTD                   IN NUMBER DEFAULT 0
   , p_PYM_DBT_NRFI_CYTD                   IN NUMBER DEFAULT 0
   , p_PYM_DBT_NRFI_RUN                    IN NUMBER DEFAULT 0
   , p_PYM_DBT_NRFI_PTD                    IN NUMBER DEFAULT 0
   , p_PYM_DBT_NRFI_YTD                    IN NUMBER DEFAULT 0
   , p_PYM_DBT_RFI_CMTD                    IN NUMBER DEFAULT 0
   , p_PYM_DBT_RFI_CYTD                    IN NUMBER DEFAULT 0
   , p_PYM_DBT_RFI_RUN                     IN NUMBER DEFAULT 0
   , p_PYM_DBT_RFI_PTD                     IN NUMBER DEFAULT 0
   , p_PYM_DBT_RFI_YTD                     IN NUMBER DEFAULT 0
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;

BEGIN
-- Balances
   bal_LOW_LOANS_NRFI_CMTD        := p_LOW_LOANS_NRFI_CMTD;
   bal_LOW_LOANS_NRFI_CYTD        := p_LOW_LOANS_NRFI_CYTD;
   bal_LOW_LOANS_NRFI_RUN         := p_LOW_LOANS_NRFI_RUN;
   bal_LOW_LOANS_NRFI_PTD         := p_LOW_LOANS_NRFI_PTD;
   bal_LOW_LOANS_NRFI_YTD         := p_LOW_LOANS_NRFI_YTD;
   bal_LOW_LOANS_RFI_CMTD         := p_LOW_LOANS_RFI_CMTD;
   bal_LOW_LOANS_RFI_CYTD         := p_LOW_LOANS_RFI_CYTD;
   bal_LOW_LOANS_RFI_RUN          := p_LOW_LOANS_RFI_RUN;
   bal_LOW_LOANS_RFI_PTD          := p_LOW_LOANS_RFI_PTD;
   bal_LOW_LOANS_RFI_YTD          := p_LOW_LOANS_RFI_YTD;
   bal_MLS_AND_VOUCH_NRFI_CMTD    := p_MLS_AND_VOUCH_NRFI_CMTD;
   bal_MLS_AND_VOUCH_NRFI_CYTD    := p_MLS_AND_VOUCH_NRFI_CYTD;
   bal_MLS_AND_VOUCH_NRFI_RUN     := p_MLS_AND_VOUCH_NRFI_RUN;
   bal_MLS_AND_VOUCH_NRFI_PTD     := p_MLS_AND_VOUCH_NRFI_PTD;
   bal_MLS_AND_VOUCH_NRFI_YTD     := p_MLS_AND_VOUCH_NRFI_YTD;
   bal_MLS_AND_VOUCH_RFI_CMTD     := p_MLS_AND_VOUCH_RFI_CMTD;
   bal_MLS_AND_VOUCH_RFI_CYTD     := p_MLS_AND_VOUCH_RFI_CYTD;
   bal_MLS_AND_VOUCH_RFI_RUN      := p_MLS_AND_VOUCH_RFI_RUN;
   bal_MLS_AND_VOUCH_RFI_PTD      := p_MLS_AND_VOUCH_RFI_PTD;
   bal_MLS_AND_VOUCH_RFI_YTD      := p_MLS_AND_VOUCH_RFI_YTD;
   bal_MED_CONTR_CMTD             := p_MED_CONTR_CMTD;
   bal_MED_CONTR_CYTD             := p_MED_CONTR_CYTD;
   bal_MED_CONTR_RUN              := p_MED_CONTR_RUN;
   bal_MED_CONTR_PTD              := p_MED_CONTR_PTD;
   bal_MED_CONTR_YTD              := p_MED_CONTR_YTD;
   bal_MED_PAID_NRFI_CMTD         := p_MED_PAID_NRFI_CMTD;
   bal_MED_PAID_NRFI_CYTD         := p_MED_PAID_NRFI_CYTD;
   bal_MED_PAID_NRFI_RUN          := p_MED_PAID_NRFI_RUN;
   bal_MED_PAID_NRFI_PTD          := p_MED_PAID_NRFI_PTD;
   bal_MED_PAID_NRFI_YTD          := p_MED_PAID_NRFI_YTD;
   bal_MED_PAID_RFI_CMTD          := p_MED_PAID_RFI_CMTD;
   bal_MED_PAID_RFI_CYTD          := p_MED_PAID_RFI_CYTD;
   bal_MED_PAID_RFI_RUN           := p_MED_PAID_RFI_RUN;
   bal_MED_PAID_RFI_PTD           := p_MED_PAID_RFI_PTD;
   bal_MED_PAID_RFI_YTD           := p_MED_PAID_RFI_YTD;
   bal_NET_PAY_RUN                := p_NET_PAY_RUN;
   bal_NET_TXB_INC_CMTD           := p_NET_TXB_INC_CMTD;
   bal_OTHER_TXB_ALL_NRFI_CMTD    := p_OTHER_TXB_ALL_NRFI_CMTD;
   bal_OTHER_TXB_ALL_NRFI_CYTD    := p_OTHER_TXB_ALL_NRFI_CYTD;
   bal_OTHER_TXB_ALL_NRFI_RUN     := p_OTHER_TXB_ALL_NRFI_RUN;
   bal_OTHER_TXB_ALL_NRFI_PTD     := p_OTHER_TXB_ALL_NRFI_PTD;
   bal_OTHER_TXB_ALL_NRFI_YTD     := p_OTHER_TXB_ALL_NRFI_YTD;
   bal_OTHER_TXB_ALL_RFI_CMTD     := p_OTHER_TXB_ALL_RFI_CMTD;
   bal_OTHER_TXB_ALL_RFI_CYTD     := p_OTHER_TXB_ALL_RFI_CYTD;
   bal_OTHER_TXB_ALL_RFI_RUN      := p_OTHER_TXB_ALL_RFI_RUN;
   bal_OTHER_TXB_ALL_RFI_PTD      := p_OTHER_TXB_ALL_RFI_PTD;
   bal_OTHER_TXB_ALL_RFI_YTD      := p_OTHER_TXB_ALL_RFI_YTD;
   bal_OVTM_NRFI_CMTD             := p_OVTM_NRFI_CMTD;
   bal_OVTM_NRFI_CYTD             := p_OVTM_NRFI_CYTD;
   bal_OVTM_NRFI_RUN              := p_OVTM_NRFI_RUN;
   bal_OVTM_NRFI_PTD              := p_OVTM_NRFI_PTD;
   bal_OVTM_NRFI_YTD              := p_OVTM_NRFI_YTD;
   bal_OVTM_RFI_CMTD              := p_OVTM_RFI_CMTD;
   bal_OVTM_RFI_CYTD              := p_OVTM_RFI_CYTD;
   bal_OVTM_RFI_RUN               := p_OVTM_RFI_RUN;
   bal_OVTM_RFI_PTD               := p_OVTM_RFI_PTD;
   bal_OVTM_RFI_YTD               := p_OVTM_RFI_YTD;
   bal_PAYE_YTD                   := p_PAYE_YTD;
   bal_PYM_DBT_NRFI_CMTD          := p_PYM_DBT_NRFI_CMTD;
   bal_PYM_DBT_NRFI_CYTD          := p_PYM_DBT_NRFI_CYTD;
   bal_PYM_DBT_NRFI_RUN           := p_PYM_DBT_NRFI_RUN;
   bal_PYM_DBT_NRFI_PTD           := p_PYM_DBT_NRFI_PTD;
   bal_PYM_DBT_NRFI_YTD           := p_PYM_DBT_NRFI_YTD;
   bal_PYM_DBT_RFI_CMTD           := p_PYM_DBT_RFI_CMTD;
   bal_PYM_DBT_RFI_CYTD           := p_PYM_DBT_RFI_CYTD;
   bal_PYM_DBT_RFI_RUN            := p_PYM_DBT_RFI_RUN;
   bal_PYM_DBT_RFI_PTD            := p_PYM_DBT_RFI_PTD;
   bal_PYM_DBT_RFI_YTD            := p_PYM_DBT_RFI_YTD;

   RETURN l_Dum;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal3_01032002: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal3_01032002;
-------------------------------------------------------------------------------
-- ZaTxBal4_01032002                                                         --
-- Tax module supporting function                                            --
-------------------------------------------------------------------------------
FUNCTION ZaTxBal4_01032002(
-- Balances
     p_PO_NRFI_CMTD                        IN NUMBER DEFAULT 0
   , p_PO_NRFI_RUN                         IN NUMBER DEFAULT 0
   , p_PO_NRFI_PTD                         IN NUMBER DEFAULT 0
   , p_PO_NRFI_YTD                         IN NUMBER DEFAULT 0
   , p_PO_RFI_CMTD                         IN NUMBER DEFAULT 0
   , p_PO_RFI_RUN                          IN NUMBER DEFAULT 0
   , p_PO_RFI_PTD                          IN NUMBER DEFAULT 0
   , p_PO_RFI_YTD                          IN NUMBER DEFAULT 0
   , p_PRCH_ANU_TXB_NRFI_CMTD              IN NUMBER DEFAULT 0
   , p_PRCH_ANU_TXB_NRFI_RUN               IN NUMBER DEFAULT 0
   , p_PRCH_ANU_TXB_NRFI_PTD               IN NUMBER DEFAULT 0
   , p_PRCH_ANU_TXB_NRFI_YTD               IN NUMBER DEFAULT 0
   , p_PRCH_ANU_TXB_RFI_CMTD               IN NUMBER DEFAULT 0
   , p_PRCH_ANU_TXB_RFI_RUN                IN NUMBER DEFAULT 0
   , p_PRCH_ANU_TXB_RFI_PTD                IN NUMBER DEFAULT 0
   , p_PRCH_ANU_TXB_RFI_YTD                IN NUMBER DEFAULT 0
   , p_RES_TRD_NRFI_CMTD                   IN NUMBER DEFAULT 0
   , p_RES_TRD_NRFI_CYTD                   IN NUMBER DEFAULT 0
   , p_RES_TRD_NRFI_RUN                    IN NUMBER DEFAULT 0
   , p_RES_TRD_NRFI_PTD                    IN NUMBER DEFAULT 0
   , p_RES_TRD_NRFI_YTD                    IN NUMBER DEFAULT 0
   , p_RES_TRD_RFI_CMTD                    IN NUMBER DEFAULT 0
   , p_RES_TRD_RFI_CYTD                    IN NUMBER DEFAULT 0
   , p_RES_TRD_RFI_RUN                     IN NUMBER DEFAULT 0
   , p_RES_TRD_RFI_PTD                     IN NUMBER DEFAULT 0
   , p_RES_TRD_RFI_YTD                     IN NUMBER DEFAULT 0
   , p_RGT_AST_NRFI_CMTD                   IN NUMBER DEFAULT 0
   , p_RGT_AST_NRFI_CYTD                   IN NUMBER DEFAULT 0
   , p_RGT_AST_NRFI_RUN                    IN NUMBER DEFAULT 0
   , p_RGT_AST_NRFI_PTD                    IN NUMBER DEFAULT 0
   , p_RGT_AST_NRFI_YTD                    IN NUMBER DEFAULT 0
   , p_RGT_AST_RFI_CMTD                    IN NUMBER DEFAULT 0
   , p_RGT_AST_RFI_CYTD                    IN NUMBER DEFAULT 0
   , p_RGT_AST_RFI_RUN                     IN NUMBER DEFAULT 0
   , p_RGT_AST_RFI_PTD                     IN NUMBER DEFAULT 0
   , p_RGT_AST_RFI_YTD                     IN NUMBER DEFAULT 0
   , p_SITE_YTD                            IN NUMBER DEFAULT 0
   , p_TAX_YTD                             IN NUMBER DEFAULT 0
   , p_TX_ON_AB_PTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_AB_YTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_AP_RUN                        IN NUMBER DEFAULT 0
   , p_TX_ON_AP_PTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_AP_YTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_BP_PTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_BP_YTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_TA_PTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_TA_YTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_DR_PTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_DR_YTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_FB_PTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_FB_YTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_NI_PTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_NI_YTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_PO_PTD                        IN NUMBER DEFAULT 0
   , p_TX_ON_PO_YTD                        IN NUMBER DEFAULT 0
   , p_TXB_AP_NRFI_CMTD                    IN NUMBER DEFAULT 0
   , p_TXB_AP_NRFI_RUN                     IN NUMBER DEFAULT 0
   , p_TXB_AP_NRFI_PTD                     IN NUMBER DEFAULT 0
   , p_TXB_AP_NRFI_YTD                     IN NUMBER DEFAULT 0
   , p_TXB_AP_RFI_CMTD                     IN NUMBER DEFAULT 0
   , p_TXB_AP_RFI_RUN                      IN NUMBER DEFAULT 0
   , p_TXB_AP_RFI_PTD                      IN NUMBER DEFAULT 0
   , p_TXB_AP_RFI_YTD                      IN NUMBER DEFAULT 0
   , p_TXB_INC_NRFI_CMTD                   IN NUMBER DEFAULT 0
   , p_TXB_INC_NRFI_CYTD                   IN NUMBER DEFAULT 0
   , p_TXB_INC_NRFI_RUN                    IN NUMBER DEFAULT 0
   , p_TXB_INC_NRFI_PTD                    IN NUMBER DEFAULT 0
   , p_TXB_INC_NRFI_YTD                    IN NUMBER DEFAULT 0
   , p_TXB_INC_RFI_CMTD                    IN NUMBER DEFAULT 0
   , p_TXB_INC_RFI_CYTD                    IN NUMBER DEFAULT 0
   , p_TXB_INC_RFI_RUN                     IN NUMBER DEFAULT 0
   , p_TXB_INC_RFI_PTD                     IN NUMBER DEFAULT 0
   , p_TXB_INC_RFI_YTD                     IN NUMBER DEFAULT 0
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;

BEGIN
-- Balances
   bal_PO_NRFI_CMTD               := p_PO_NRFI_CMTD;
   bal_PO_NRFI_RUN                := p_PO_NRFI_RUN;
   bal_PO_NRFI_PTD                := p_PO_NRFI_PTD;
   bal_PO_NRFI_YTD                := p_PO_NRFI_YTD;
   bal_PO_RFI_CMTD                := p_PO_RFI_CMTD;
   bal_PO_RFI_RUN                 := p_PO_RFI_RUN;
   bal_PO_RFI_PTD                 := p_PO_RFI_PTD;
   bal_PO_RFI_YTD                 := p_PO_RFI_YTD;
   bal_PRCH_ANU_TXB_NRFI_CMTD     := p_PRCH_ANU_TXB_NRFI_CMTD;
   bal_PRCH_ANU_TXB_NRFI_RUN      := p_PRCH_ANU_TXB_NRFI_RUN;
   bal_PRCH_ANU_TXB_NRFI_PTD      := p_PRCH_ANU_TXB_NRFI_PTD;
   bal_PRCH_ANU_TXB_NRFI_YTD      := p_PRCH_ANU_TXB_NRFI_YTD;
   bal_PRCH_ANU_TXB_RFI_CMTD      := p_PRCH_ANU_TXB_RFI_CMTD;
   bal_PRCH_ANU_TXB_RFI_RUN       := p_PRCH_ANU_TXB_RFI_RUN;
   bal_PRCH_ANU_TXB_RFI_PTD       := p_PRCH_ANU_TXB_RFI_PTD;
   bal_PRCH_ANU_TXB_RFI_YTD       := p_PRCH_ANU_TXB_RFI_YTD;
   bal_RES_TRD_NRFI_CMTD          := p_RES_TRD_NRFI_CMTD;
   bal_RES_TRD_NRFI_CYTD          := p_RES_TRD_NRFI_CYTD;
   bal_RES_TRD_NRFI_RUN           := p_RES_TRD_NRFI_RUN;
   bal_RES_TRD_NRFI_PTD           := p_RES_TRD_NRFI_PTD;
   bal_RES_TRD_NRFI_YTD           := p_RES_TRD_NRFI_YTD;
   bal_RES_TRD_RFI_CMTD           := p_RES_TRD_RFI_CMTD;
   bal_RES_TRD_RFI_CYTD           := p_RES_TRD_RFI_CYTD;
   bal_RES_TRD_RFI_RUN            := p_RES_TRD_RFI_RUN;
   bal_RES_TRD_RFI_PTD            := p_RES_TRD_RFI_PTD;
   bal_RES_TRD_RFI_YTD            := p_RES_TRD_RFI_YTD;
   bal_RGT_AST_NRFI_CMTD          := p_RGT_AST_NRFI_CMTD;
   bal_RGT_AST_NRFI_CYTD          := p_RGT_AST_NRFI_CYTD;
   bal_RGT_AST_NRFI_RUN           := p_RGT_AST_NRFI_RUN;
   bal_RGT_AST_NRFI_PTD           := p_RGT_AST_NRFI_PTD;
   bal_RGT_AST_NRFI_YTD           := p_RGT_AST_NRFI_YTD;
   bal_RGT_AST_RFI_CMTD           := p_RGT_AST_RFI_CMTD;
   bal_RGT_AST_RFI_CYTD           := p_RGT_AST_RFI_CYTD;
   bal_RGT_AST_RFI_RUN            := p_RGT_AST_RFI_RUN;
   bal_RGT_AST_RFI_PTD            := p_RGT_AST_RFI_PTD;
   bal_RGT_AST_RFI_YTD            := p_RGT_AST_RFI_YTD;
   bal_SITE_YTD                   := p_SITE_YTD;
   bal_TAX_YTD                    := p_TAX_YTD;
   bal_TX_ON_AB_PTD               := p_TX_ON_AB_PTD;
   bal_TX_ON_AB_YTD               := p_TX_ON_AB_YTD;
   bal_TX_ON_AP_RUN               := p_TX_ON_AP_RUN;
   bal_TX_ON_AP_PTD               := p_TX_ON_AP_PTD;
   bal_TX_ON_AP_YTD               := p_TX_ON_AP_YTD;
   bal_TX_ON_BP_PTD               := p_TX_ON_BP_PTD;
   bal_TX_ON_BP_YTD               := p_TX_ON_BP_YTD;
   bal_TX_ON_TA_PTD               := p_TX_ON_TA_PTD;
   bal_TX_ON_TA_YTD               := p_TX_ON_TA_YTD;
   bal_TX_ON_DR_PTD               := p_TX_ON_DR_PTD;
   bal_TX_ON_DR_YTD               := p_TX_ON_DR_YTD;
   bal_TX_ON_FB_PTD               := p_TX_ON_FB_PTD;
   bal_TX_ON_FB_YTD               := p_TX_ON_FB_YTD;
   bal_TX_ON_NI_PTD               := p_TX_ON_NI_PTD;
   bal_TX_ON_NI_YTD               := p_TX_ON_NI_YTD;
   bal_TX_ON_PO_PTD               := p_TX_ON_PO_PTD;
   bal_TX_ON_PO_YTD               := p_TX_ON_PO_YTD;
   bal_TXB_AP_NRFI_CMTD           := p_TXB_AP_NRFI_CMTD;
   bal_TXB_AP_NRFI_RUN            := p_TXB_AP_NRFI_RUN;
   bal_TXB_AP_NRFI_PTD            := p_TXB_AP_NRFI_PTD;
   bal_TXB_AP_NRFI_YTD            := p_TXB_AP_NRFI_YTD;
   bal_TXB_AP_RFI_CMTD            := p_TXB_AP_RFI_CMTD;
   bal_TXB_AP_RFI_RUN             := p_TXB_AP_RFI_RUN;
   bal_TXB_AP_RFI_PTD             := p_TXB_AP_RFI_PTD;
   bal_TXB_AP_RFI_YTD             := p_TXB_AP_RFI_YTD;
   bal_TXB_INC_NRFI_CMTD          := p_TXB_INC_NRFI_CMTD;
   bal_TXB_INC_NRFI_CYTD          := p_TXB_INC_NRFI_CYTD;
   bal_TXB_INC_NRFI_RUN           := p_TXB_INC_NRFI_RUN;
   bal_TXB_INC_NRFI_PTD           := p_TXB_INC_NRFI_PTD;
   bal_TXB_INC_NRFI_YTD           := p_TXB_INC_NRFI_YTD;
   bal_TXB_INC_RFI_CMTD           := p_TXB_INC_RFI_CMTD;
   bal_TXB_INC_RFI_CYTD           := p_TXB_INC_RFI_CYTD;
   bal_TXB_INC_RFI_RUN            := p_TXB_INC_RFI_RUN;
   bal_TXB_INC_RFI_PTD            := p_TXB_INC_RFI_PTD;
   bal_TXB_INC_RFI_YTD            := p_TXB_INC_RFI_YTD;

   RETURN l_Dum;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal4_01032002: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal4_01032002;
-------------------------------------------------------------------------------
-- ZaTxBal5_01032002                                                         --
-- Tax module supporting function                                            --
-------------------------------------------------------------------------------
FUNCTION ZaTxBal5_01032002(
-- Balances
     p_TXB_PEN_NRFI_CMTD                   IN NUMBER DEFAULT 0
   , p_TXB_PEN_NRFI_CYTD                   IN NUMBER DEFAULT 0
   , p_TXB_PEN_NRFI_RUN                    IN NUMBER DEFAULT 0
   , p_TXB_PEN_NRFI_PTD                    IN NUMBER DEFAULT 0
   , p_TXB_PEN_NRFI_YTD                    IN NUMBER DEFAULT 0
   , p_TXB_PEN_RFI_CMTD                    IN NUMBER DEFAULT 0
   , p_TXB_PEN_RFI_CYTD                    IN NUMBER DEFAULT 0
   , p_TXB_PEN_RFI_RUN                     IN NUMBER DEFAULT 0
   , p_TXB_PEN_RFI_PTD                     IN NUMBER DEFAULT 0
   , p_TXB_PEN_RFI_YTD                     IN NUMBER DEFAULT 0
   , p_TEL_ALL_NRFI_CMTD                   IN NUMBER DEFAULT 0
   , p_TEL_ALL_NRFI_CYTD                   IN NUMBER DEFAULT 0
   , p_TEL_ALL_NRFI_RUN                    IN NUMBER DEFAULT 0
   , p_TEL_ALL_NRFI_PTD                    IN NUMBER DEFAULT 0
   , p_TEL_ALL_NRFI_YTD                    IN NUMBER DEFAULT 0
   , p_TEL_ALL_RFI_CMTD                    IN NUMBER DEFAULT 0
   , p_TEL_ALL_RFI_CYTD                    IN NUMBER DEFAULT 0
   , p_TEL_ALL_RFI_RUN                     IN NUMBER DEFAULT 0
   , p_TEL_ALL_RFI_PTD                     IN NUMBER DEFAULT 0
   , p_TEL_ALL_RFI_YTD                     IN NUMBER DEFAULT 0
   , p_TOOL_ALL_NRFI_CMTD                  IN NUMBER DEFAULT 0
   , p_TOOL_ALL_NRFI_CYTD                  IN NUMBER DEFAULT 0
   , p_TOOL_ALL_NRFI_RUN                   IN NUMBER DEFAULT 0
   , p_TOOL_ALL_NRFI_PTD                   IN NUMBER DEFAULT 0
   , p_TOOL_ALL_NRFI_YTD                   IN NUMBER DEFAULT 0
   , p_TOOL_ALL_RFI_CMTD                   IN NUMBER DEFAULT 0
   , p_TOOL_ALL_RFI_CYTD                   IN NUMBER DEFAULT 0
   , p_TOOL_ALL_RFI_RUN                    IN NUMBER DEFAULT 0
   , p_TOOL_ALL_RFI_PTD                    IN NUMBER DEFAULT 0
   , p_TOOL_ALL_RFI_YTD                    IN NUMBER DEFAULT 0
   , p_TOT_INC_PTD                         IN NUMBER DEFAULT 0
   , p_TOT_INC_YTD                         IN NUMBER DEFAULT 0
   , p_TOT_NRFI_AN_INC_CMTD                IN NUMBER DEFAULT 0
   , p_TOT_NRFI_AN_INC_CYTD                IN NUMBER DEFAULT 0
   , p_TOT_NRFI_AN_INC_RUN                 IN NUMBER DEFAULT 0
   , p_TOT_NRFI_AN_INC_PTD                 IN NUMBER DEFAULT 0
   , p_TOT_NRFI_AN_INC_YTD                 IN NUMBER DEFAULT 0
   , p_TOT_NRFI_INC_CMTD                   IN NUMBER DEFAULT 0
   , p_TOT_NRFI_INC_CYTD                   IN NUMBER DEFAULT 0
   , p_TOT_NRFI_INC_RUN                    IN NUMBER DEFAULT 0
   , p_TOT_NRFI_INC_PTD                    IN NUMBER DEFAULT 0
   , p_TOT_NRFI_INC_YTD                    IN NUMBER DEFAULT 0
   , p_TOT_RFI_AN_INC_CMTD                 IN NUMBER DEFAULT 0
   , p_TOT_RFI_AN_INC_CYTD                 IN NUMBER DEFAULT 0
   , p_TOT_RFI_AN_INC_RUN                  IN NUMBER DEFAULT 0
   , p_TOT_RFI_AN_INC_PTD                  IN NUMBER DEFAULT 0
   , p_TOT_RFI_AN_INC_YTD                  IN NUMBER DEFAULT 0
   , p_TOT_RFI_INC_CMTD                    IN NUMBER DEFAULT 0
   , p_TOT_RFI_INC_CYTD                    IN NUMBER DEFAULT 0
   , p_TOT_RFI_INC_RUN                     IN NUMBER DEFAULT 0
   , p_TOT_RFI_INC_PTD                     IN NUMBER DEFAULT 0
   , p_TOT_RFI_INC_YTD                     IN NUMBER DEFAULT 0
   , p_TOT_SEA_WRK_DYS_WRK_YTD             IN NUMBER DEFAULT 0
   , p_TOT_TXB_INC_ITD                     IN NUMBER DEFAULT 0
   , p_TA_NRFI_CMTD                        IN NUMBER DEFAULT 0
   , p_TA_NRFI_CYTD                        IN NUMBER DEFAULT 0
   , p_TA_NRFI_PTD                         IN NUMBER DEFAULT 0
   , p_TA_NRFI_YTD                         IN NUMBER DEFAULT 0
   , p_TA_RFI_CMTD                         IN NUMBER DEFAULT 0
   , p_TA_RFI_CYTD                         IN NUMBER DEFAULT 0
   , p_TA_RFI_PTD                          IN NUMBER DEFAULT 0
   , p_TA_RFI_YTD                          IN NUMBER DEFAULT 0
   , p_USE_VEH_NRFI_CMTD                   IN NUMBER DEFAULT 0
   , p_USE_VEH_NRFI_CYTD                   IN NUMBER DEFAULT 0
   , p_USE_VEH_NRFI_RUN                    IN NUMBER DEFAULT 0
   , p_USE_VEH_NRFI_PTD                    IN NUMBER DEFAULT 0
   , p_USE_VEH_NRFI_YTD                    IN NUMBER DEFAULT 0
   , p_USE_VEH_RFI_CMTD                    IN NUMBER DEFAULT 0
   , p_USE_VEH_RFI_CYTD                    IN NUMBER DEFAULT 0
   , p_USE_VEH_RFI_RUN                     IN NUMBER DEFAULT 0
   , p_USE_VEH_RFI_PTD                     IN NUMBER DEFAULT 0
   , p_USE_VEH_RFI_YTD                     IN NUMBER DEFAULT 0
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;

BEGIN
-- Balances
   bal_TXB_PEN_NRFI_CMTD          := p_TXB_PEN_NRFI_CMTD;
   bal_TXB_PEN_NRFI_CYTD          := p_TXB_PEN_NRFI_CYTD;
   bal_TXB_PEN_NRFI_RUN           := p_TXB_PEN_NRFI_RUN;
   bal_TXB_PEN_NRFI_PTD           := p_TXB_PEN_NRFI_PTD;
   bal_TXB_PEN_NRFI_YTD           := p_TXB_PEN_NRFI_YTD;
   bal_TXB_PEN_RFI_CMTD           := p_TXB_PEN_RFI_CMTD;
   bal_TXB_PEN_RFI_CYTD           := p_TXB_PEN_RFI_CYTD;
   bal_TXB_PEN_RFI_RUN            := p_TXB_PEN_RFI_RUN;
   bal_TXB_PEN_RFI_PTD            := p_TXB_PEN_RFI_PTD;
   bal_TXB_PEN_RFI_YTD            := p_TXB_PEN_RFI_YTD;
   bal_TEL_ALL_NRFI_CMTD          := p_TEL_ALL_NRFI_CMTD;
   bal_TEL_ALL_NRFI_CYTD          := p_TEL_ALL_NRFI_CYTD;
   bal_TEL_ALL_NRFI_RUN           := p_TEL_ALL_NRFI_RUN;
   bal_TEL_ALL_NRFI_PTD           := p_TEL_ALL_NRFI_PTD;
   bal_TEL_ALL_NRFI_YTD           := p_TEL_ALL_NRFI_YTD;
   bal_TEL_ALL_RFI_CMTD           := p_TEL_ALL_RFI_CMTD;
   bal_TEL_ALL_RFI_CYTD           := p_TEL_ALL_RFI_CYTD;
   bal_TEL_ALL_RFI_RUN            := p_TEL_ALL_RFI_RUN;
   bal_TEL_ALL_RFI_PTD            := p_TEL_ALL_RFI_PTD;
   bal_TEL_ALL_RFI_YTD            := p_TEL_ALL_RFI_YTD;
   bal_TOOL_ALL_NRFI_CMTD         := p_TOOL_ALL_NRFI_CMTD;
   bal_TOOL_ALL_NRFI_CYTD         := p_TOOL_ALL_NRFI_CYTD;
   bal_TOOL_ALL_NRFI_RUN          := p_TOOL_ALL_NRFI_RUN;
   bal_TOOL_ALL_NRFI_PTD          := p_TOOL_ALL_NRFI_PTD;
   bal_TOOL_ALL_NRFI_YTD          := p_TOOL_ALL_NRFI_YTD;
   bal_TOOL_ALL_RFI_CMTD          := p_TOOL_ALL_RFI_CMTD;
   bal_TOOL_ALL_RFI_CYTD          := p_TOOL_ALL_RFI_CYTD;
   bal_TOOL_ALL_RFI_RUN           := p_TOOL_ALL_RFI_RUN;
   bal_TOOL_ALL_RFI_PTD           := p_TOOL_ALL_RFI_PTD;
   bal_TOOL_ALL_RFI_YTD           := p_TOOL_ALL_RFI_YTD;
   bal_TOT_INC_PTD                := p_TOT_INC_PTD;
   bal_TOT_INC_YTD                := p_TOT_INC_YTD;
   bal_TOT_NRFI_AN_INC_CMTD       := p_TOT_NRFI_AN_INC_CMTD;
   bal_TOT_NRFI_AN_INC_CYTD       := p_TOT_NRFI_AN_INC_CYTD;
   bal_TOT_NRFI_AN_INC_RUN        := p_TOT_NRFI_AN_INC_RUN;
   bal_TOT_NRFI_AN_INC_PTD        := p_TOT_NRFI_AN_INC_PTD;
   bal_TOT_NRFI_AN_INC_YTD        := p_TOT_NRFI_AN_INC_YTD;
   bal_TOT_NRFI_INC_CMTD          := p_TOT_NRFI_INC_CMTD;
   bal_TOT_NRFI_INC_CYTD          := p_TOT_NRFI_INC_CYTD;
   bal_TOT_NRFI_INC_RUN           := p_TOT_NRFI_INC_RUN;
   bal_TOT_NRFI_INC_PTD           := p_TOT_NRFI_INC_PTD;
   bal_TOT_NRFI_INC_YTD           := p_TOT_NRFI_INC_YTD;
   bal_TOT_RFI_AN_INC_CMTD        := p_TOT_RFI_AN_INC_CMTD;
   bal_TOT_RFI_AN_INC_CYTD        := p_TOT_RFI_AN_INC_CYTD;
   bal_TOT_RFI_AN_INC_RUN         := p_TOT_RFI_AN_INC_RUN;
   bal_TOT_RFI_AN_INC_PTD         := p_TOT_RFI_AN_INC_PTD;
   bal_TOT_RFI_AN_INC_YTD         := p_TOT_RFI_AN_INC_YTD;
   bal_TOT_RFI_INC_CMTD           := p_TOT_RFI_INC_CMTD;
   bal_TOT_RFI_INC_CYTD           := p_TOT_RFI_INC_CYTD;
   bal_TOT_RFI_INC_RUN            := p_TOT_RFI_INC_RUN;
   bal_TOT_RFI_INC_PTD            := p_TOT_RFI_INC_PTD;
   bal_TOT_RFI_INC_YTD            := p_TOT_RFI_INC_YTD;
   bal_TOT_SEA_WRK_DYS_WRK_YTD    := p_TOT_SEA_WRK_DYS_WRK_YTD;
   bal_TOT_TXB_INC_ITD            := p_TOT_TXB_INC_ITD;
   bal_TA_NRFI_CMTD               := p_TA_NRFI_CMTD;
   bal_TA_NRFI_CYTD               := p_TA_NRFI_CYTD;
   bal_TA_NRFI_PTD                := p_TA_NRFI_PTD;
   bal_TA_NRFI_YTD                := p_TA_NRFI_YTD;
   bal_TA_RFI_CMTD                := p_TA_RFI_CMTD;
   bal_TA_RFI_CYTD                := p_TA_RFI_CYTD;
   bal_TA_RFI_PTD                 := p_TA_RFI_PTD;
   bal_TA_RFI_YTD                 := p_TA_RFI_YTD;
   bal_USE_VEH_NRFI_CMTD          := p_USE_VEH_NRFI_CMTD;
   bal_USE_VEH_NRFI_CYTD          := p_USE_VEH_NRFI_CYTD;
   bal_USE_VEH_NRFI_RUN           := p_USE_VEH_NRFI_RUN;
   bal_USE_VEH_NRFI_PTD           := p_USE_VEH_NRFI_PTD;
   bal_USE_VEH_NRFI_YTD           := p_USE_VEH_NRFI_YTD;
   bal_USE_VEH_RFI_CMTD           := p_USE_VEH_RFI_CMTD;
   bal_USE_VEH_RFI_CYTD           := p_USE_VEH_RFI_CYTD;
   bal_USE_VEH_RFI_RUN            := p_USE_VEH_RFI_RUN;
   bal_USE_VEH_RFI_PTD            := p_USE_VEH_RFI_PTD;
   bal_USE_VEH_RFI_YTD            := p_USE_VEH_RFI_YTD;

   RETURN l_Dum;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal4_01032002: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal5_01032002;
-------------------------------------------------------------------------------
-- ZaTx_01032002                                                             --
-- Main Tax module function                                                  --
-------------------------------------------------------------------------------
FUNCTION ZaTx_01032002(
/*  PARAMETERS */
   -- Contexts
     ASSIGNMENT_ACTION_ID IN NUMBER
   , ASSIGNMENT_ID        IN NUMBER
   , PAYROLL_ACTION_ID    IN NUMBER
   , PAYROLL_ID           IN NUMBER
   -- Out Parameters
   , p_LibWrn            OUT NOCOPY VARCHAR2
   , p_LibFpDR           OUT NOCOPY NUMBER
   , p_LibFpNI           OUT NOCOPY NUMBER
   , p_LibFpFB           OUT NOCOPY NUMBER
   , p_LibFpTA           OUT NOCOPY NUMBER
   , p_LibFpBP           OUT NOCOPY NUMBER
   , p_LibFpAB           OUT NOCOPY NUMBER
   , p_LibFpAP           OUT NOCOPY NUMBER
   , p_LibFpPO           OUT NOCOPY NUMBER
   , p_PayValSD          OUT NOCOPY NUMBER
   , p_PayValEC          OUT NOCOPY NUMBER
   , p_PayeVal           OUT NOCOPY NUMBER
   , p_SiteVal           OUT NOCOPY NUMBER
   , p_It3Ind            OUT NOCOPY NUMBER
   , p_PfUpdFig          OUT NOCOPY NUMBER
   , p_RaUpdFig          OUT NOCOPY NUMBER
   , p_OUpdFig           OUT NOCOPY NUMBER
   , p_NtiUpdFig         OUT NOCOPY NUMBER
   , p_OvrWrn            OUT NOCOPY VARCHAR2
   )RETURN NUMBER
AS
-- Variables
--
   l_Dum NUMBER := 1;

-------------------------------------------------------------------------------
BEGIN--                           MAIN                                       --
-------------------------------------------------------------------------------
-- Set hr_utility globals if debugging
--
--   py_za_tx_utl_01032002.g_HrTraceEnabled  := TRUE;
--   py_za_tx_utl_01032002.g_HrTracePipeName := 'ZATAX';

-- Call hr_utility start procedure
   py_za_tx_utl_01032002.StartHrTrace;

-- Setup Trace Header Info
   WrtHrTrc(' ');
   WrtHrTrc(' ');
   WrtHrTrc(' ');
   WrtHrTrc('------------------------------------------------------------');
   WrtHrTrc('-- Start of Tax Trace File');
   WrtHrTrc('------------------------------------------------------------');
   WrtHrTrc(' ');
   WrtHrTrc('Processing Assignment ID :        '||to_char(ASSIGNMENT_ID       ));
   WrtHrTrc('Assignment Action ID     :        '||to_char(ASSIGNMENT_ACTION_ID));
   WrtHrTrc('Payroll Action ID        :        '||to_char(PAYROLL_ACTION_ID   ));
   WrtHrTrc('Payroll ID               :        '||to_char(PAYROLL_ID          ));
   WrtHrTrc(' ');
   WrtHrTrc('------------------------------------------------------------');
   WrtHrTrc(' ');
   WrtHrTrc('-------------------------------------------------------------------------------');
   WrtHrTrc('-- Application Global Values');
   WrtHrTrc('-------------------------------------------------------------------------------');
   WrtHrTrc('   glb_ZA_ADL_TX_RBT:             '||to_char(glb_ZA_ADL_TX_RBT        ));
   WrtHrTrc('   glb_ZA_ARR_PF_AN_MX_ABT:       '||to_char(glb_ZA_ARR_PF_AN_MX_ABT  ));
   WrtHrTrc('   glb_ZA_ARR_RA_AN_MX_ABT:       '||to_char(glb_ZA_ARR_RA_AN_MX_ABT  ));
   WrtHrTrc('   glb_ZA_TRV_ALL_TX_PRC:         '||to_char(glb_ZA_TRV_ALL_TX_PRC    ));
   WrtHrTrc('   glb_ZA_CC_TX_PRC:              '||to_char(glb_ZA_CC_TX_PRC         ));
   WrtHrTrc('   glb_ZA_LABOUR_BROK_PERC:       '||to_char(glb_ZA_LABOUR_BROK_PERC  ));
   WrtHrTrc('   glb_ZA_PF_AN_MX_ABT:           '||to_char(glb_ZA_PF_AN_MX_ABT      ));
   WrtHrTrc('   glb_ZA_PF_MX_PRC:              '||to_char(glb_ZA_PF_MX_PRC         ));
   WrtHrTrc('   glb_ZA_PER_SERV_COMP_PERC:     '||to_char(glb_ZA_PER_SERV_COMP_PERC));
   WrtHrTrc('   glb_ZA_PER_SERV_TRST_PERC:     '||to_char(glb_ZA_PER_SERV_TRST_PERC));
   WrtHrTrc('   glb_ZA_PRI_TX_RBT:             '||to_char(glb_ZA_PRI_TX_RBT        ));
   WrtHrTrc('   glb_ZA_PRI_TX_THRSHLD:         '||to_char(glb_ZA_PRI_TX_THRSHLD    ));
   WrtHrTrc('   glb_ZA_PBL_TX_PRC:             '||to_char(glb_ZA_PBL_TX_PRC        ));
   WrtHrTrc('   glb_ZA_PBL_TX_RTE:             '||to_char(glb_ZA_PBL_TX_RTE        ));
   WrtHrTrc('   glb_ZA_RA_AN_MX_ABT:           '||to_char(glb_ZA_RA_AN_MX_ABT      ));
   WrtHrTrc('   glb_ZA_RA_MX_PRC:              '||to_char(glb_ZA_RA_MX_PRC         ));
   WrtHrTrc('   glb_ZA_SC_TX_THRSHLD:          '||to_char(glb_ZA_SC_TX_THRSHLD     ));
   WrtHrTrc('   glb_ZA_SIT_LIM:                '||to_char(glb_ZA_SIT_LIM           ));
   WrtHrTrc('   glb_ZA_TMP_TX_RTE:             '||to_char(glb_ZA_TMP_TX_RTE        ));
   WrtHrTrc('   glb_ZA_WRK_DYS_PR_YR:          '||to_char(glb_ZA_WRK_DYS_PR_YR     ));
   WrtHrTrc('-------------------------------------------------------------------------------');
   WrtHrTrc('-- Application Database Items');
   WrtHrTrc('-------------------------------------------------------------------------------');
   WrtHrTrc('   dbi_BP_TX_RCV:                 '||        dbi_BP_TX_RCV                        );
   WrtHrTrc('   dbi_PAY_PROC_PRD_DTE_PD:       '||to_char(dbi_PAY_PROC_PRD_DTE_PD,'DD/MM/YYYY'));
   WrtHrTrc('   dbi_PER_AGE:                   '||to_char(dbi_PER_AGE                         ));
   WrtHrTrc('   dbi_PER_DTE_OF_BRTH:           '||to_char(dbi_PER_DTE_OF_BRTH    ,'DD/MM/YYYY'));
   WrtHrTrc('   dbi_SEA_WRK_DYS_WRK:           '||to_char(dbi_SEA_WRK_DYS_WRK                 ));
   WrtHrTrc('   dbi_SES_DTE:                   '||to_char(dbi_SES_DTE            ,'DD/MM/YYYY'));
   WrtHrTrc('   dbi_TX_DIR_NUM:                '||        dbi_TX_DIR_NUM                       );
   WrtHrTrc('   dbi_TX_DIR_VAL:                '||to_char(dbi_TX_DIR_VAL                      ));
   WrtHrTrc('   dbi_TX_STA:                    '||        dbi_TX_STA                           );
   WrtHrTrc('   dbi_ZA_ACT_END_DTE:            '||to_char(dbi_ZA_ACT_END_DTE     ,'DD/MM/YYYY'));
   WrtHrTrc('   dbi_ZA_ACT_STRT_DTE:           '||to_char(dbi_ZA_ACT_STRT_DTE    ,'DD/MM/YYYY'));
   WrtHrTrc('   dbi_ZA_ASG_TX_RTR_PRD:         '||        dbi_ZA_ASG_TX_RTR_PRD                );
   WrtHrTrc('   dbi_ZA_ASG_TX_YR:              '||to_char(dbi_ZA_ASG_TX_YR                    ));
   WrtHrTrc('   dbi_ZA_ASG_TX_YR_END:          '||to_char(dbi_ZA_ASG_TX_YR_END   ,'DD/MM/YYYY'));
   WrtHrTrc('   dbi_ZA_ASG_TX_YR_STRT:         '||to_char(dbi_ZA_ASG_TX_YR_STRT  ,'DD/MM/YYYY'));
   WrtHrTrc('   dbi_ZA_CUR_PRD_END_DTE:        '||to_char(dbi_ZA_CUR_PRD_END_DTE ,'DD/MM/YYYY'));
   WrtHrTrc('   dbi_ZA_CUR_PRD_STRT_DTE:       '||to_char(dbi_ZA_CUR_PRD_STRT_DTE,'DD/MM/YYYY'));
   WrtHrTrc('   dbi_ZA_DYS_IN_YR:              '||to_char(dbi_ZA_DYS_IN_YR                    ));
   WrtHrTrc('   dbi_ZA_PAY_PRDS_LFT:           '||to_char(dbi_ZA_PAY_PRDS_LFT                 ));
   WrtHrTrc('   dbi_ZA_PAY_PRDS_PER_YR:        '||to_char(dbi_ZA_PAY_PRDS_PER_YR              ));
   WrtHrTrc('   dbi_ZA_TX_YR_END:              '||to_char(dbi_ZA_TX_YR_END       ,'DD/MM/YYYY'));
   WrtHrTrc('   dbi_ZA_TX_YR_STRT:             '||to_char(dbi_ZA_TX_YR_STRT      ,'DD/MM/YYYY'));
   WrtHrTrc('-------------------------------------------------------------------------------');
   WrtHrTrc('-- Balances');
   WrtHrTrc('-------------------------------------------------------------------------------');
   WrtHrTrc('   bal_ANN_ARR_PF_CMTD:           '||to_char(bal_ANN_ARR_PF_CMTD          ));
   WrtHrTrc('   bal_ANN_ARR_PF_CYTD:           '||to_char(bal_ANN_ARR_PF_CYTD          ));
   WrtHrTrc('   bal_ANN_ARR_PF_RUN:            '||to_char(bal_ANN_ARR_PF_RUN           ));
   WrtHrTrc('   bal_ANN_ARR_PF_PTD:            '||to_char(bal_ANN_ARR_PF_PTD           ));
   WrtHrTrc('   bal_ANN_ARR_PF_YTD:            '||to_char(bal_ANN_ARR_PF_YTD           ));
   WrtHrTrc('   bal_ANN_ARR_RA_CMTD:           '||to_char(bal_ANN_ARR_RA_CMTD          ));
   WrtHrTrc('   bal_ANN_ARR_RA_CYTD:           '||to_char(bal_ANN_ARR_RA_CYTD          ));
   WrtHrTrc('   bal_ANN_ARR_RA_RUN:            '||to_char(bal_ANN_ARR_RA_RUN           ));
   WrtHrTrc('   bal_ANN_ARR_RA_PTD:            '||to_char(bal_ANN_ARR_RA_PTD           ));
   WrtHrTrc('   bal_ANN_ARR_RA_YTD:            '||to_char(bal_ANN_ARR_RA_YTD           ));
   WrtHrTrc('   bal_AA_PRCHD_RVAL_NRFI_CMTD:   '||to_char(bal_AA_PRCHD_RVAL_NRFI_CMTD  ));
   WrtHrTrc('   bal_AA_PRCHD_RVAL_NRFI_RUN:    '||to_char(bal_AA_PRCHD_RVAL_NRFI_RUN   ));
   WrtHrTrc('   bal_AA_PRCHD_RVAL_NRFI_PTD:    '||to_char(bal_AA_PRCHD_RVAL_NRFI_PTD   ));
   WrtHrTrc('   bal_AA_PRCHD_RVAL_NRFI_YTD:    '||to_char(bal_AA_PRCHD_RVAL_NRFI_YTD   ));
   WrtHrTrc('   bal_AA_PRCHD_RVAL_RFI_CMTD:    '||to_char(bal_AA_PRCHD_RVAL_RFI_CMTD   ));
   WrtHrTrc('   bal_AA_PRCHD_RVAL_RFI_RUN:     '||to_char(bal_AA_PRCHD_RVAL_RFI_RUN    ));
   WrtHrTrc('   bal_AA_PRCHD_RVAL_RFI_PTD:     '||to_char(bal_AA_PRCHD_RVAL_RFI_PTD    ));
   WrtHrTrc('   bal_AA_PRCHD_RVAL_RFI_YTD:     '||to_char(bal_AA_PRCHD_RVAL_RFI_YTD    ));
   WrtHrTrc('   bal_AB_NRFI_CMTD:              '||to_char(bal_AB_NRFI_CMTD             ));
   WrtHrTrc('   bal_AB_NRFI_RUN:               '||to_char(bal_AB_NRFI_RUN              ));
   WrtHrTrc('   bal_AB_NRFI_PTD:               '||to_char(bal_AB_NRFI_PTD              ));
   WrtHrTrc('   bal_AB_NRFI_YTD:               '||to_char(bal_AB_NRFI_YTD              ));
   WrtHrTrc('   bal_AB_RFI_CMTD:               '||to_char(bal_AB_RFI_CMTD              ));
   WrtHrTrc('   bal_AB_RFI_RUN:                '||to_char(bal_AB_RFI_RUN               ));
   WrtHrTrc('   bal_AB_RFI_PTD:                '||to_char(bal_AB_RFI_PTD               ));
   WrtHrTrc('   bal_AB_RFI_YTD:                '||to_char(bal_AB_RFI_YTD               ));
   WrtHrTrc('   bal_ANN_BUR_AND_SCH_NRFI_CMTD  '||to_char(bal_ANN_BUR_AND_SCH_NRFI_CMTD));
   WrtHrTrc('   bal_ANN_BUR_AND_SCH_NRFI_RUN   '||to_char(bal_ANN_BUR_AND_SCH_NRFI_RUN ));
   WrtHrTrc('   bal_ANN_BUR_AND_SCH_NRFI_PTD   '||to_char(bal_ANN_BUR_AND_SCH_NRFI_PTD ));
   WrtHrTrc('   bal_ANN_BUR_AND_SCH_NRFI_YTD   '||to_char(bal_ANN_BUR_AND_SCH_NRFI_YTD ));
   WrtHrTrc('   bal_ANN_BUR_AND_SCH_RFI_CMTD   '||to_char(bal_ANN_BUR_AND_SCH_RFI_CMTD ));
   WrtHrTrc('   bal_ANN_BUR_AND_SCH_RFI_RUN    '||to_char(bal_ANN_BUR_AND_SCH_RFI_RUN  ));
   WrtHrTrc('   bal_ANN_BUR_AND_SCH_RFI_PTD    '||to_char(bal_ANN_BUR_AND_SCH_RFI_PTD  ));
   WrtHrTrc('   bal_ANN_BUR_AND_SCH_RFI_YTD    '||to_char(bal_ANN_BUR_AND_SCH_RFI_YTD  ));
   WrtHrTrc('   bal_AC_NRFI_CMTD:              '||to_char(bal_AC_NRFI_CMTD             ));
   WrtHrTrc('   bal_AC_NRFI_RUN:               '||to_char(bal_AC_NRFI_RUN              ));
   WrtHrTrc('   bal_AC_NRFI_PTD:               '||to_char(bal_AC_NRFI_PTD              ));
   WrtHrTrc('   bal_AC_NRFI_YTD:               '||to_char(bal_AC_NRFI_YTD              ));
   WrtHrTrc('   bal_AC_RFI_CMTD:               '||to_char(bal_AC_RFI_CMTD              ));
   WrtHrTrc('   bal_AC_RFI_RUN:                '||to_char(bal_AC_RFI_RUN               ));
   WrtHrTrc('   bal_AC_RFI_PTD:                '||to_char(bal_AC_RFI_PTD               ));
   WrtHrTrc('   bal_AC_RFI_YTD:                '||to_char(bal_AC_RFI_YTD               ));
   WrtHrTrc('   bal_ANN_PF_CMTD:               '||to_char(bal_ANN_PF_CMTD              ));
   WrtHrTrc('   bal_ANN_PF_RUN:                '||to_char(bal_ANN_PF_RUN               ));
   WrtHrTrc('   bal_ANN_PF_PTD:                '||to_char(bal_ANN_PF_PTD               ));
   WrtHrTrc('   bal_ANN_PF_YTD:                '||to_char(bal_ANN_PF_YTD               ));
   WrtHrTrc('   bal_ARES_TRD_NRFI_CMTD:        '||to_char(bal_ARES_TRD_NRFI_CMTD       ));
   WrtHrTrc('   bal_ARES_TRD_NRFI_RUN:         '||to_char(bal_ARES_TRD_NRFI_RUN        ));
   WrtHrTrc('   bal_ARES_TRD_NRFI_PTD:         '||to_char(bal_ARES_TRD_NRFI_PTD        ));
   WrtHrTrc('   bal_ARES_TRD_NRFI_YTD:         '||to_char(bal_ARES_TRD_NRFI_YTD        ));
   WrtHrTrc('   bal_ARES_TRD_RFI_CMTD:         '||to_char(bal_ARES_TRD_RFI_CMTD        ));
   WrtHrTrc('   bal_ARES_TRD_RFI_RUN:          '||to_char(bal_ARES_TRD_RFI_RUN         ));
   WrtHrTrc('   bal_ARES_TRD_RFI_PTD:          '||to_char(bal_ARES_TRD_RFI_PTD         ));
   WrtHrTrc('   bal_ARES_TRD_RFI_YTD:          '||to_char(bal_ARES_TRD_RFI_YTD         ));
   WrtHrTrc('   bal_ANN_RA_CMTD:               '||to_char(bal_ANN_RA_CMTD              ));
   WrtHrTrc('   bal_ANN_RA_CYTD:               '||to_char(bal_ANN_RA_CYTD              ));
   WrtHrTrc('   bal_ANN_RA_RUN:                '||to_char(bal_ANN_RA_RUN               ));
   WrtHrTrc('   bal_ANN_RA_PTD:                '||to_char(bal_ANN_RA_PTD               ));
   WrtHrTrc('   bal_ANN_RA_YTD:                '||to_char(bal_ANN_RA_YTD               ));
   WrtHrTrc('   bal_ANU_FRM_RET_FND_NRFI_CMTD: '||to_char(bal_ANU_FRM_RET_FND_NRFI_CMTD));
   WrtHrTrc('   bal_ANU_FRM_RET_FND_NRFI_RUN:  '||to_char(bal_ANU_FRM_RET_FND_NRFI_RUN ));
   WrtHrTrc('   bal_ANU_FRM_RET_FND_NRFI_PTD:  '||to_char(bal_ANU_FRM_RET_FND_NRFI_PTD ));
   WrtHrTrc('   bal_ANU_FRM_RET_FND_NRFI_YTD:  '||to_char(bal_ANU_FRM_RET_FND_NRFI_YTD ));
   WrtHrTrc('   bal_ANU_FRM_RET_FND_RFI_CMTD:  '||to_char(bal_ANU_FRM_RET_FND_RFI_CMTD ));
   WrtHrTrc('   bal_ANU_FRM_RET_FND_RFI_RUN:   '||to_char(bal_ANU_FRM_RET_FND_RFI_RUN  ));
   WrtHrTrc('   bal_ANU_FRM_RET_FND_RFI_PTD:   '||to_char(bal_ANU_FRM_RET_FND_RFI_PTD  ));
   WrtHrTrc('   bal_ANU_FRM_RET_FND_RFI_YTD:   '||to_char(bal_ANU_FRM_RET_FND_RFI_YTD  ));
   WrtHrTrc('   bal_ARR_PF_CMTD:               '||to_char(bal_ARR_PF_CMTD              ));
   WrtHrTrc('   bal_ARR_PF_CYTD:               '||to_char(bal_ARR_PF_CYTD              ));
   WrtHrTrc('   bal_ARR_PF_PTD:                '||to_char(bal_ARR_PF_PTD               ));
   WrtHrTrc('   bal_ARR_PF_YTD:                '||to_char(bal_ARR_PF_YTD               ));
   WrtHrTrc('   bal_ARR_RA_CMTD:               '||to_char(bal_ARR_RA_CMTD              ));
   WrtHrTrc('   bal_ARR_RA_CYTD:               '||to_char(bal_ARR_RA_CYTD              ));
   WrtHrTrc('   bal_ARR_RA_PTD:                '||to_char(bal_ARR_RA_PTD               ));
   WrtHrTrc('   bal_ARR_RA_YTD:                '||to_char(bal_ARR_RA_YTD               ));
   WrtHrTrc('   bal_AST_PRCHD_RVAL_NRFI_CMTD:  '||to_char(bal_AST_PRCHD_RVAL_NRFI_CMTD ));
   WrtHrTrc('   bal_AST_PRCHD_RVAL_NRFI_CYTD:  '||to_char(bal_AST_PRCHD_RVAL_NRFI_CYTD ));
   WrtHrTrc('   bal_AST_PRCHD_RVAL_NRFI_RUN:   '||to_char(bal_AST_PRCHD_RVAL_NRFI_RUN  ));
   WrtHrTrc('   bal_AST_PRCHD_RVAL_NRFI_PTD:   '||to_char(bal_AST_PRCHD_RVAL_NRFI_PTD  ));
   WrtHrTrc('   bal_AST_PRCHD_RVAL_NRFI_YTD:   '||to_char(bal_AST_PRCHD_RVAL_NRFI_YTD  ));
   WrtHrTrc('   bal_AST_PRCHD_RVAL_RFI_CMTD:   '||to_char(bal_AST_PRCHD_RVAL_RFI_CMTD  ));
   WrtHrTrc('   bal_AST_PRCHD_RVAL_RFI_CYTD:   '||to_char(bal_AST_PRCHD_RVAL_RFI_CYTD  ));
   WrtHrTrc('   bal_AST_PRCHD_RVAL_RFI_RUN:    '||to_char(bal_AST_PRCHD_RVAL_RFI_RUN   ));
   WrtHrTrc('   bal_AST_PRCHD_RVAL_RFI_PTD:    '||to_char(bal_AST_PRCHD_RVAL_RFI_PTD   ));
   WrtHrTrc('   bal_AST_PRCHD_RVAL_RFI_YTD:    '||to_char(bal_AST_PRCHD_RVAL_RFI_YTD   ));
   WrtHrTrc('   bal_BP_CMTD:                   '||to_char(bal_BP_CMTD                  ));
   WrtHrTrc('   bal_BP_PTD:                    '||to_char(bal_BP_PTD                   ));
   WrtHrTrc('   bal_BP_YTD:                    '||to_char(bal_BP_YTD                   ));
   WrtHrTrc('   bal_BUR_AND_SCH_NRFI_CMTD:     '||to_char(bal_BUR_AND_SCH_NRFI_CMTD    ));
   WrtHrTrc('   bal_BUR_AND_SCH_NRFI_CYTD:     '||to_char(bal_BUR_AND_SCH_NRFI_CYTD    ));
   WrtHrTrc('   bal_BUR_AND_SCH_NRFI_RUN:      '||to_char(bal_BUR_AND_SCH_NRFI_RUN     ));
   WrtHrTrc('   bal_BUR_AND_SCH_NRFI_PTD:      '||to_char(bal_BUR_AND_SCH_NRFI_PTD     ));
   WrtHrTrc('   bal_BUR_AND_SCH_NRFI_YTD:      '||to_char(bal_BUR_AND_SCH_NRFI_YTD     ));
   WrtHrTrc('   bal_BUR_AND_SCH_RFI_CMTD:      '||to_char(bal_BUR_AND_SCH_RFI_CMTD     ));
   WrtHrTrc('   bal_BUR_AND_SCH_RFI_CYTD:      '||to_char(bal_BUR_AND_SCH_RFI_CYTD     ));
   WrtHrTrc('   bal_BUR_AND_SCH_RFI_RUN:       '||to_char(bal_BUR_AND_SCH_RFI_RUN      ));
   WrtHrTrc('   bal_BUR_AND_SCH_RFI_PTD:       '||to_char(bal_BUR_AND_SCH_RFI_PTD      ));
   WrtHrTrc('   bal_BUR_AND_SCH_RFI_YTD:       '||to_char(bal_BUR_AND_SCH_RFI_YTD      ));
   WrtHrTrc('   bal_COMM_NRFI_CMTD:            '||to_char(bal_COMM_NRFI_CMTD           ));
   WrtHrTrc('   bal_COMM_NRFI_CYTD:            '||to_char(bal_COMM_NRFI_CYTD           ));
   WrtHrTrc('   bal_COMM_NRFI_RUN:             '||to_char(bal_COMM_NRFI_RUN            ));
   WrtHrTrc('   bal_COMM_NRFI_PTD:             '||to_char(bal_COMM_NRFI_PTD            ));
   WrtHrTrc('   bal_COMM_NRFI_YTD:             '||to_char(bal_COMM_NRFI_YTD            ));
   WrtHrTrc('   bal_COMM_RFI_CMTD:             '||to_char(bal_COMM_RFI_CMTD            ));
   WrtHrTrc('   bal_COMM_RFI_CYTD:             '||to_char(bal_COMM_RFI_CYTD            ));
   WrtHrTrc('   bal_COMM_RFI_RUN:              '||to_char(bal_COMM_RFI_RUN             ));
   WrtHrTrc('   bal_COMM_RFI_PTD:              '||to_char(bal_COMM_RFI_PTD             ));
   WrtHrTrc('   bal_COMM_RFI_YTD:              '||to_char(bal_COMM_RFI_YTD             ));
   WrtHrTrc('   bal_COMP_ALL_NRFI_CMTD:        '||to_char(bal_COMP_ALL_NRFI_CMTD       ));
   WrtHrTrc('   bal_COMP_ALL_NRFI_CYTD:        '||to_char(bal_COMP_ALL_NRFI_CYTD       ));
   WrtHrTrc('   bal_COMP_ALL_NRFI_RUN:         '||to_char(bal_COMP_ALL_NRFI_RUN        ));
   WrtHrTrc('   bal_COMP_ALL_NRFI_PTD:         '||to_char(bal_COMP_ALL_NRFI_PTD        ));
   WrtHrTrc('   bal_COMP_ALL_NRFI_YTD:         '||to_char(bal_COMP_ALL_NRFI_YTD        ));
   WrtHrTrc('   bal_COMP_ALL_RFI_CMTD:         '||to_char(bal_COMP_ALL_RFI_CMTD        ));
   WrtHrTrc('   bal_COMP_ALL_RFI_CYTD:         '||to_char(bal_COMP_ALL_RFI_CYTD        ));
   WrtHrTrc('   bal_COMP_ALL_RFI_RUN:          '||to_char(bal_COMP_ALL_RFI_RUN         ));
   WrtHrTrc('   bal_COMP_ALL_RFI_PTD:          '||to_char(bal_COMP_ALL_RFI_PTD         ));
   WrtHrTrc('   bal_COMP_ALL_RFI_YTD:          '||to_char(bal_COMP_ALL_RFI_YTD         ));
   WrtHrTrc('   bal_PF_CMTD:                   '||to_char(bal_PF_CMTD                  ));
   WrtHrTrc('   bal_PF_CYTD:                   '||to_char(bal_PF_CYTD                  ));
   WrtHrTrc('   bal_PF_RUN:                    '||to_char(bal_PF_RUN                   ));
   WrtHrTrc('   bal_PF_PTD:                    '||to_char(bal_PF_PTD                   ));
   WrtHrTrc('   bal_PF_YTD:                    '||to_char(bal_PF_YTD                   ));
   WrtHrTrc('   bal_RA_CMTD:                   '||to_char(bal_RA_CMTD                  ));
   WrtHrTrc('   bal_RA_CYTD:                   '||to_char(bal_RA_CYTD                  ));
   WrtHrTrc('   bal_RA_RUN:                    '||to_char(bal_RA_RUN                   ));
   WrtHrTrc('   bal_RA_PTD:                    '||to_char(bal_RA_PTD                   ));
   WrtHrTrc('   bal_RA_YTD:                    '||to_char(bal_RA_YTD                   ));
   WrtHrTrc('   bal_DIR_DMD_RMN_ITD            '||to_char(bal_DIR_DMD_RMN_ITD          ));
   WrtHrTrc('   bal_ENT_ALL_NRFI_CMTD:         '||to_char(bal_ENT_ALL_NRFI_CMTD        ));
   WrtHrTrc('   bal_ENT_ALL_NRFI_CYTD:         '||to_char(bal_ENT_ALL_NRFI_CYTD        ));
   WrtHrTrc('   bal_ENT_ALL_NRFI_RUN:          '||to_char(bal_ENT_ALL_NRFI_RUN         ));
   WrtHrTrc('   bal_ENT_ALL_NRFI_PTD:          '||to_char(bal_ENT_ALL_NRFI_PTD         ));
   WrtHrTrc('   bal_ENT_ALL_NRFI_YTD:          '||to_char(bal_ENT_ALL_NRFI_YTD         ));
   WrtHrTrc('   bal_ENT_ALL_RFI_CMTD:          '||to_char(bal_ENT_ALL_RFI_CMTD         ));
   WrtHrTrc('   bal_ENT_ALL_RFI_CYTD:          '||to_char(bal_ENT_ALL_RFI_CYTD         ));
   WrtHrTrc('   bal_ENT_ALL_RFI_RUN:           '||to_char(bal_ENT_ALL_RFI_RUN          ));
   WrtHrTrc('   bal_ENT_ALL_RFI_PTD:           '||to_char(bal_ENT_ALL_RFI_PTD          ));
   WrtHrTrc('   bal_ENT_ALL_RFI_YTD:           '||to_char(bal_ENT_ALL_RFI_YTD          ));
   WrtHrTrc('   bal_EXC_ARR_PEN_ITD:           '||to_char(bal_EXC_ARR_PEN_ITD          ));
   WrtHrTrc('   bal_EXC_ARR_PEN_PTD:           '||to_char(bal_EXC_ARR_PEN_PTD          ));
   WrtHrTrc('   bal_EXC_ARR_PEN_YTD:           '||to_char(bal_EXC_ARR_PEN_YTD          ));
   WrtHrTrc('   bal_EXC_ARR_RA_ITD:            '||to_char(bal_EXC_ARR_RA_ITD           ));
   WrtHrTrc('   bal_EXC_ARR_RA_PTD:            '||to_char(bal_EXC_ARR_RA_PTD           ));
   WrtHrTrc('   bal_EXC_ARR_RA_YTD:            '||to_char(bal_EXC_ARR_RA_YTD           ));
   WrtHrTrc('   bal_FREE_ACCOM_NRFI_CMTD:      '||to_char(bal_FREE_ACCOM_NRFI_CMTD     ));
   WrtHrTrc('   bal_FREE_ACCOM_NRFI_CYTD:      '||to_char(bal_FREE_ACCOM_NRFI_CYTD     ));
   WrtHrTrc('   bal_FREE_ACCOM_NRFI_RUN:       '||to_char(bal_FREE_ACCOM_NRFI_RUN      ));
   WrtHrTrc('   bal_FREE_ACCOM_NRFI_PTD:       '||to_char(bal_FREE_ACCOM_NRFI_PTD      ));
   WrtHrTrc('   bal_FREE_ACCOM_NRFI_YTD:       '||to_char(bal_FREE_ACCOM_NRFI_YTD      ));
   WrtHrTrc('   bal_FREE_ACCOM_RFI_CMTD:       '||to_char(bal_FREE_ACCOM_RFI_CMTD      ));
   WrtHrTrc('   bal_FREE_ACCOM_RFI_CYTD:       '||to_char(bal_FREE_ACCOM_RFI_CYTD      ));
   WrtHrTrc('   bal_FREE_ACCOM_RFI_RUN:        '||to_char(bal_FREE_ACCOM_RFI_RUN       ));
   WrtHrTrc('   bal_FREE_ACCOM_RFI_PTD:        '||to_char(bal_FREE_ACCOM_RFI_PTD       ));
   WrtHrTrc('   bal_FREE_ACCOM_RFI_YTD:        '||to_char(bal_FREE_ACCOM_RFI_YTD       ));
   WrtHrTrc('   bal_FREE_SERV_NRFI_CMTD:       '||to_char(bal_FREE_SERV_NRFI_CMTD      ));
   WrtHrTrc('   bal_FREE_SERV_NRFI_CYTD:       '||to_char(bal_FREE_SERV_NRFI_CYTD      ));
   WrtHrTrc('   bal_FREE_SERV_NRFI_RUN:        '||to_char(bal_FREE_SERV_NRFI_RUN       ));
   WrtHrTrc('   bal_FREE_SERV_NRFI_PTD:        '||to_char(bal_FREE_SERV_NRFI_PTD       ));
   WrtHrTrc('   bal_FREE_SERV_NRFI_YTD:        '||to_char(bal_FREE_SERV_NRFI_YTD       ));
   WrtHrTrc('   bal_FREE_SERV_RFI_CMTD:        '||to_char(bal_FREE_SERV_RFI_CMTD       ));
   WrtHrTrc('   bal_FREE_SERV_RFI_CYTD:        '||to_char(bal_FREE_SERV_RFI_CYTD       ));
   WrtHrTrc('   bal_FREE_SERV_RFI_RUN:         '||to_char(bal_FREE_SERV_RFI_RUN        ));
   WrtHrTrc('   bal_FREE_SERV_RFI_PTD:         '||to_char(bal_FREE_SERV_RFI_PTD        ));
   WrtHrTrc('   bal_FREE_SERV_RFI_YTD:         '||to_char(bal_FREE_SERV_RFI_YTD        ));
   WrtHrTrc('   bal_LOW_LOANS_NRFI_CMTD:       '||to_char(bal_LOW_LOANS_NRFI_CMTD      ));
   WrtHrTrc('   bal_LOW_LOANS_NRFI_CYTD:       '||to_char(bal_LOW_LOANS_NRFI_CYTD      ));
   WrtHrTrc('   bal_LOW_LOANS_NRFI_RUN:        '||to_char(bal_LOW_LOANS_NRFI_RUN       ));
   WrtHrTrc('   bal_LOW_LOANS_NRFI_PTD:        '||to_char(bal_LOW_LOANS_NRFI_PTD       ));
   WrtHrTrc('   bal_LOW_LOANS_NRFI_YTD:        '||to_char(bal_LOW_LOANS_NRFI_YTD       ));
   WrtHrTrc('   bal_LOW_LOANS_RFI_CMTD:        '||to_char(bal_LOW_LOANS_RFI_CMTD       ));
   WrtHrTrc('   bal_LOW_LOANS_RFI_CYTD:        '||to_char(bal_LOW_LOANS_RFI_CYTD       ));
   WrtHrTrc('   bal_LOW_LOANS_RFI_RUN:         '||to_char(bal_LOW_LOANS_RFI_RUN        ));
   WrtHrTrc('   bal_LOW_LOANS_RFI_PTD:         '||to_char(bal_LOW_LOANS_RFI_PTD        ));
   WrtHrTrc('   bal_LOW_LOANS_RFI_YTD:         '||to_char(bal_LOW_LOANS_RFI_YTD        ));
   WrtHrTrc('   bal_MLS_AND_VOUCH_NRFI_CMTD:   '||to_char(bal_MLS_AND_VOUCH_NRFI_CMTD  ));
   WrtHrTrc('   bal_MLS_AND_VOUCH_NRFI_CYTD:   '||to_char(bal_MLS_AND_VOUCH_NRFI_CYTD  ));
   WrtHrTrc('   bal_MLS_AND_VOUCH_NRFI_RUN:    '||to_char(bal_MLS_AND_VOUCH_NRFI_RUN   ));
   WrtHrTrc('   bal_MLS_AND_VOUCH_NRFI_PTD:    '||to_char(bal_MLS_AND_VOUCH_NRFI_PTD   ));
   WrtHrTrc('   bal_MLS_AND_VOUCH_NRFI_YTD:    '||to_char(bal_MLS_AND_VOUCH_NRFI_YTD   ));
   WrtHrTrc('   bal_MLS_AND_VOUCH_RFI_CMTD:    '||to_char(bal_MLS_AND_VOUCH_RFI_CMTD   ));
   WrtHrTrc('   bal_MLS_AND_VOUCH_RFI_CYTD:    '||to_char(bal_MLS_AND_VOUCH_RFI_CYTD   ));
   WrtHrTrc('   bal_MLS_AND_VOUCH_RFI_RUN:     '||to_char(bal_MLS_AND_VOUCH_RFI_RUN    ));
   WrtHrTrc('   bal_MLS_AND_VOUCH_RFI_PTD:     '||to_char(bal_MLS_AND_VOUCH_RFI_PTD    ));
   WrtHrTrc('   bal_MLS_AND_VOUCH_RFI_YTD:     '||to_char(bal_MLS_AND_VOUCH_RFI_YTD    ));
   WrtHrTrc('   bal_MED_CONTR_CMTD:            '||to_char(bal_MED_CONTR_CMTD           ));
   WrtHrTrc('   bal_MED_CONTR_CYTD:            '||to_char(bal_MED_CONTR_CYTD           ));
   WrtHrTrc('   bal_MED_CONTR_RUN:             '||to_char(bal_MED_CONTR_RUN            ));
   WrtHrTrc('   bal_MED_CONTR_PTD:             '||to_char(bal_MED_CONTR_PTD            ));
   WrtHrTrc('   bal_MED_CONTR_YTD:             '||to_char(bal_MED_CONTR_YTD            ));
   WrtHrTrc('   bal_MED_PAID_NRFI_CMTD:        '||to_char(bal_MED_PAID_NRFI_CMTD       ));
   WrtHrTrc('   bal_MED_PAID_NRFI_CYTD:        '||to_char(bal_MED_PAID_NRFI_CYTD       ));
   WrtHrTrc('   bal_MED_PAID_NRFI_RUN:         '||to_char(bal_MED_PAID_NRFI_RUN        ));
   WrtHrTrc('   bal_MED_PAID_NRFI_PTD:         '||to_char(bal_MED_PAID_NRFI_PTD        ));
   WrtHrTrc('   bal_MED_PAID_NRFI_YTD:         '||to_char(bal_MED_PAID_NRFI_YTD        ));
   WrtHrTrc('   bal_MED_PAID_RFI_CMTD:         '||to_char(bal_MED_PAID_RFI_CMTD        ));
   WrtHrTrc('   bal_MED_PAID_RFI_CYTD:         '||to_char(bal_MED_PAID_RFI_CYTD        ));
   WrtHrTrc('   bal_MED_PAID_RFI_RUN:          '||to_char(bal_MED_PAID_RFI_RUN         ));
   WrtHrTrc('   bal_MED_PAID_RFI_PTD:          '||to_char(bal_MED_PAID_RFI_PTD         ));
   WrtHrTrc('   bal_MED_PAID_RFI_YTD:          '||to_char(bal_MED_PAID_RFI_YTD         ));
   WrtHrTrc('   bal_NET_PAY_RUN:               '||to_char(bal_NET_PAY_RUN              ));
   WrtHrTrc('   bal_NET_TXB_INC_CMTD:          '||to_char(bal_NET_TXB_INC_CMTD         ));
   WrtHrTrc('   bal_OTHER_TXB_ALL_NRFI_CMTD:   '||to_char(bal_OTHER_TXB_ALL_NRFI_CMTD  ));
   WrtHrTrc('   bal_OTHER_TXB_ALL_NRFI_CYTD:   '||to_char(bal_OTHER_TXB_ALL_NRFI_CYTD  ));
   WrtHrTrc('   bal_OTHER_TXB_ALL_NRFI_RUN:    '||to_char(bal_OTHER_TXB_ALL_NRFI_RUN   ));
   WrtHrTrc('   bal_OTHER_TXB_ALL_NRFI_PTD:    '||to_char(bal_OTHER_TXB_ALL_NRFI_PTD   ));
   WrtHrTrc('   bal_OTHER_TXB_ALL_NRFI_YTD:    '||to_char(bal_OTHER_TXB_ALL_NRFI_YTD   ));
   WrtHrTrc('   bal_OTHER_TXB_ALL_RFI_CMTD:    '||to_char(bal_OTHER_TXB_ALL_RFI_CMTD   ));
   WrtHrTrc('   bal_OTHER_TXB_ALL_RFI_CYTD:    '||to_char(bal_OTHER_TXB_ALL_RFI_CYTD   ));
   WrtHrTrc('   bal_OTHER_TXB_ALL_RFI_RUN:     '||to_char(bal_OTHER_TXB_ALL_RFI_RUN    ));
   WrtHrTrc('   bal_OTHER_TXB_ALL_RFI_PTD:     '||to_char(bal_OTHER_TXB_ALL_RFI_PTD    ));
   WrtHrTrc('   bal_OTHER_TXB_ALL_RFI_YTD:     '||to_char(bal_OTHER_TXB_ALL_RFI_YTD    ));
   WrtHrTrc('   bal_OVTM_NRFI_CMTD:            '||to_char(bal_OVTM_NRFI_CMTD           ));
   WrtHrTrc('   bal_OVTM_NRFI_CYTD:            '||to_char(bal_OVTM_NRFI_CYTD           ));
   WrtHrTrc('   bal_OVTM_NRFI_RUN:             '||to_char(bal_OVTM_NRFI_RUN            ));
   WrtHrTrc('   bal_OVTM_NRFI_PTD:             '||to_char(bal_OVTM_NRFI_PTD            ));
   WrtHrTrc('   bal_OVTM_NRFI_YTD:             '||to_char(bal_OVTM_NRFI_YTD            ));
   WrtHrTrc('   bal_OVTM_RFI_CMTD:             '||to_char(bal_OVTM_RFI_CMTD            ));
   WrtHrTrc('   bal_OVTM_RFI_CYTD:             '||to_char(bal_OVTM_RFI_CYTD            ));
   WrtHrTrc('   bal_OVTM_RFI_RUN:              '||to_char(bal_OVTM_RFI_RUN             ));
   WrtHrTrc('   bal_OVTM_RFI_PTD:              '||to_char(bal_OVTM_RFI_PTD             ));
   WrtHrTrc('   bal_OVTM_RFI_YTD:              '||to_char(bal_OVTM_RFI_YTD             ));
   WrtHrTrc('   bal_PAYE_YTD:                  '||to_char(bal_PAYE_YTD                 ));
   WrtHrTrc('   bal_PYM_DBT_NRFI_CMTD:         '||to_char(bal_PYM_DBT_NRFI_CMTD        ));
   WrtHrTrc('   bal_PYM_DBT_NRFI_CYTD:         '||to_char(bal_PYM_DBT_NRFI_CYTD        ));
   WrtHrTrc('   bal_PYM_DBT_NRFI_RUN:          '||to_char(bal_PYM_DBT_NRFI_RUN         ));
   WrtHrTrc('   bal_PYM_DBT_NRFI_PTD:          '||to_char(bal_PYM_DBT_NRFI_PTD         ));
   WrtHrTrc('   bal_PYM_DBT_NRFI_YTD:          '||to_char(bal_PYM_DBT_NRFI_YTD         ));
   WrtHrTrc('   bal_PYM_DBT_RFI_CMTD:          '||to_char(bal_PYM_DBT_RFI_CMTD         ));
   WrtHrTrc('   bal_PYM_DBT_RFI_CYTD:          '||to_char(bal_PYM_DBT_RFI_CYTD         ));
   WrtHrTrc('   bal_PYM_DBT_RFI_RUN:           '||to_char(bal_PYM_DBT_RFI_RUN          ));
   WrtHrTrc('   bal_PYM_DBT_RFI_PTD:           '||to_char(bal_PYM_DBT_RFI_PTD          ));
   WrtHrTrc('   bal_PYM_DBT_RFI_YTD:           '||to_char(bal_PYM_DBT_RFI_YTD          ));
   WrtHrTrc('   bal_PO_NRFI_CMTD:              '||to_char(bal_PO_NRFI_CMTD             ));
   WrtHrTrc('   bal_PO_NRFI_RUN:               '||to_char(bal_PO_NRFI_RUN              ));
   WrtHrTrc('   bal_PO_NRFI_PTD:               '||to_char(bal_PO_NRFI_PTD              ));
   WrtHrTrc('   bal_PO_NRFI_YTD:               '||to_char(bal_PO_NRFI_YTD              ));
   WrtHrTrc('   bal_PO_RFI_CMTD:               '||to_char(bal_PO_RFI_CMTD              ));
   WrtHrTrc('   bal_PO_RFI_RUN:                '||to_char(bal_PO_RFI_RUN               ));
   WrtHrTrc('   bal_PO_RFI_PTD:                '||to_char(bal_PO_RFI_PTD               ));
   WrtHrTrc('   bal_PO_RFI_YTD:                '||to_char(bal_PO_RFI_YTD               ));
   WrtHrTrc('   bal_PRCH_ANU_TXB_NRFI_CMTD:    '||to_char(bal_PRCH_ANU_TXB_NRFI_CMTD   ));
   WrtHrTrc('   bal_PRCH_ANU_TXB_NRFI_RUN:     '||to_char(bal_PRCH_ANU_TXB_NRFI_RUN    ));
   WrtHrTrc('   bal_PRCH_ANU_TXB_NRFI_PTD:     '||to_char(bal_PRCH_ANU_TXB_NRFI_PTD    ));
   WrtHrTrc('   bal_PRCH_ANU_TXB_NRFI_YTD:     '||to_char(bal_PRCH_ANU_TXB_NRFI_YTD    ));
   WrtHrTrc('   bal_PRCH_ANU_TXB_RFI_CMTD:     '||to_char(bal_PRCH_ANU_TXB_RFI_CMTD    ));
   WrtHrTrc('   bal_PRCH_ANU_TXB_RFI_RUN:      '||to_char(bal_PRCH_ANU_TXB_RFI_RUN     ));
   WrtHrTrc('   bal_PRCH_ANU_TXB_RFI_PTD:      '||to_char(bal_PRCH_ANU_TXB_RFI_PTD     ));
   WrtHrTrc('   bal_PRCH_ANU_TXB_RFI_YTD:      '||to_char(bal_PRCH_ANU_TXB_RFI_YTD     ));
   WrtHrTrc('   bal_RES_TRD_NRFI_CMTD:         '||to_char(bal_RES_TRD_NRFI_CMTD        ));
   WrtHrTrc('   bal_RES_TRD_NRFI_CYTD:         '||to_char(bal_RES_TRD_NRFI_CYTD        ));
   WrtHrTrc('   bal_RES_TRD_NRFI_RUN:          '||to_char(bal_RES_TRD_NRFI_RUN         ));
   WrtHrTrc('   bal_RES_TRD_NRFI_PTD:          '||to_char(bal_RES_TRD_NRFI_PTD         ));
   WrtHrTrc('   bal_RES_TRD_NRFI_YTD:          '||to_char(bal_RES_TRD_NRFI_YTD         ));
   WrtHrTrc('   bal_RES_TRD_RFI_CMTD:          '||to_char(bal_RES_TRD_RFI_CMTD         ));
   WrtHrTrc('   bal_RES_TRD_RFI_CYTD:          '||to_char(bal_RES_TRD_RFI_CYTD         ));
   WrtHrTrc('   bal_RES_TRD_RFI_RUN:           '||to_char(bal_RES_TRD_RFI_RUN          ));
   WrtHrTrc('   bal_RES_TRD_RFI_PTD:           '||to_char(bal_RES_TRD_RFI_PTD          ));
   WrtHrTrc('   bal_RES_TRD_RFI_YTD:           '||to_char(bal_RES_TRD_RFI_YTD          ));
   WrtHrTrc('   bal_RGT_AST_NRFI_CMTD:         '||to_char(bal_RGT_AST_NRFI_CMTD        ));
   WrtHrTrc('   bal_RGT_AST_NRFI_CYTD:         '||to_char(bal_RGT_AST_NRFI_CYTD        ));
   WrtHrTrc('   bal_RGT_AST_NRFI_RUN:          '||to_char(bal_RGT_AST_NRFI_RUN         ));
   WrtHrTrc('   bal_RGT_AST_NRFI_PTD:          '||to_char(bal_RGT_AST_NRFI_PTD         ));
   WrtHrTrc('   bal_RGT_AST_NRFI_YTD:          '||to_char(bal_RGT_AST_NRFI_YTD         ));
   WrtHrTrc('   bal_RGT_AST_RFI_CMTD:          '||to_char(bal_RGT_AST_RFI_CMTD         ));
   WrtHrTrc('   bal_RGT_AST_RFI_CYTD:          '||to_char(bal_RGT_AST_RFI_CYTD         ));
   WrtHrTrc('   bal_RGT_AST_RFI_RUN:           '||to_char(bal_RGT_AST_RFI_RUN          ));
   WrtHrTrc('   bal_RGT_AST_RFI_PTD:           '||to_char(bal_RGT_AST_RFI_PTD          ));
   WrtHrTrc('   bal_RGT_AST_RFI_YTD:           '||to_char(bal_RGT_AST_RFI_YTD          ));
   WrtHrTrc('   bal_SITE_YTD:                  '||to_char(bal_SITE_YTD                 ));
   WrtHrTrc('   bal_TAX_YTD:                   '||to_char(bal_TAX_YTD                  ));
   WrtHrTrc('   bal_TX_ON_AB_PTD:              '||to_char(bal_TX_ON_AB_PTD             ));
   WrtHrTrc('   bal_TX_ON_AB_YTD:              '||to_char(bal_TX_ON_AB_YTD             ));
   WrtHrTrc('   bal_TX_ON_AP_RUN:              '||to_char(bal_TX_ON_AP_RUN             ));
   WrtHrTrc('   bal_TX_ON_AP_PTD:              '||to_char(bal_TX_ON_AP_PTD             ));
   WrtHrTrc('   bal_TX_ON_AP_YTD:              '||to_char(bal_TX_ON_AP_YTD             ));
   WrtHrTrc('   bal_TX_ON_BP_PTD:              '||to_char(bal_TX_ON_BP_PTD             ));
   WrtHrTrc('   bal_TX_ON_BP_YTD:              '||to_char(bal_TX_ON_BP_YTD             ));
   WrtHrTrc('   bal_TX_ON_TA_PTD:              '||to_char(bal_TX_ON_TA_PTD             ));
   WrtHrTrc('   bal_TX_ON_TA_YTD:              '||to_char(bal_TX_ON_TA_YTD             ));
   WrtHrTrc('   bal_TX_ON_DR_PTD:              '||to_char(bal_TX_ON_DR_PTD             ));
   WrtHrTrc('   bal_TX_ON_DR_YTD:              '||to_char(bal_TX_ON_DR_YTD             ));
   WrtHrTrc('   bal_TX_ON_FB_PTD:              '||to_char(bal_TX_ON_FB_PTD             ));
   WrtHrTrc('   bal_TX_ON_FB_YTD:              '||to_char(bal_TX_ON_FB_YTD             ));
   WrtHrTrc('   bal_TX_ON_NI_PTD:              '||to_char(bal_TX_ON_NI_PTD             ));
   WrtHrTrc('   bal_TX_ON_NI_YTD:              '||to_char(bal_TX_ON_NI_YTD             ));
   WrtHrTrc('   bal_TX_ON_PO_PTD:              '||to_char(bal_TX_ON_PO_PTD             ));
   WrtHrTrc('   bal_TX_ON_PO_YTD:              '||to_char(bal_TX_ON_PO_YTD             ));
   WrtHrTrc('   bal_TXB_AP_NRFI_CMTD:          '||to_char(bal_TXB_AP_NRFI_CMTD         ));
   WrtHrTrc('   bal_TXB_AP_NRFI_RUN:           '||to_char(bal_TXB_AP_NRFI_RUN          ));
   WrtHrTrc('   bal_TXB_AP_NRFI_PTD:           '||to_char(bal_TXB_AP_NRFI_PTD          ));
   WrtHrTrc('   bal_TXB_AP_NRFI_YTD:           '||to_char(bal_TXB_AP_NRFI_YTD          ));
   WrtHrTrc('   bal_TXB_AP_RFI_CMTD:           '||to_char(bal_TXB_AP_RFI_CMTD          ));
   WrtHrTrc('   bal_TXB_AP_RFI_RUN:            '||to_char(bal_TXB_AP_RFI_RUN           ));
   WrtHrTrc('   bal_TXB_AP_RFI_PTD:            '||to_char(bal_TXB_AP_RFI_PTD           ));
   WrtHrTrc('   bal_TXB_AP_RFI_YTD:            '||to_char(bal_TXB_AP_RFI_YTD           ));
   WrtHrTrc('   bal_TXB_INC_NRFI_CMTD:         '||to_char(bal_TXB_INC_NRFI_CMTD        ));
   WrtHrTrc('   bal_TXB_INC_NRFI_CYTD:         '||to_char(bal_TXB_INC_NRFI_CYTD        ));
   WrtHrTrc('   bal_TXB_INC_NRFI_RUN:          '||to_char(bal_TXB_INC_NRFI_RUN         ));
   WrtHrTrc('   bal_TXB_INC_NRFI_PTD:          '||to_char(bal_TXB_INC_NRFI_PTD         ));
   WrtHrTrc('   bal_TXB_INC_NRFI_YTD:          '||to_char(bal_TXB_INC_NRFI_YTD         ));
   WrtHrTrc('   bal_TXB_INC_RFI_CMTD:          '||to_char(bal_TXB_INC_RFI_CMTD         ));
   WrtHrTrc('   bal_TXB_INC_RFI_CYTD:          '||to_char(bal_TXB_INC_RFI_CYTD         ));
   WrtHrTrc('   bal_TXB_INC_RFI_RUN:           '||to_char(bal_TXB_INC_RFI_RUN          ));
   WrtHrTrc('   bal_TXB_INC_RFI_PTD:           '||to_char(bal_TXB_INC_RFI_PTD          ));
   WrtHrTrc('   bal_TXB_INC_RFI_YTD:           '||to_char(bal_TXB_INC_RFI_YTD          ));
   WrtHrTrc('   bal_TXB_PEN_NRFI_CMTD:         '||to_char(bal_TXB_PEN_NRFI_CMTD        ));
   WrtHrTrc('   bal_TXB_PEN_NRFI_CYTD:         '||to_char(bal_TXB_PEN_NRFI_CYTD        ));
   WrtHrTrc('   bal_TXB_PEN_NRFI_RUN:          '||to_char(bal_TXB_PEN_NRFI_RUN         ));
   WrtHrTrc('   bal_TXB_PEN_NRFI_PTD:          '||to_char(bal_TXB_PEN_NRFI_PTD         ));
   WrtHrTrc('   bal_TXB_PEN_NRFI_YTD:          '||to_char(bal_TXB_PEN_NRFI_YTD         ));
   WrtHrTrc('   bal_TXB_PEN_RFI_CMTD:          '||to_char(bal_TXB_PEN_RFI_CMTD         ));
   WrtHrTrc('   bal_TXB_PEN_RFI_CYTD:          '||to_char(bal_TXB_PEN_RFI_CYTD         ));
   WrtHrTrc('   bal_TXB_PEN_RFI_RUN:           '||to_char(bal_TXB_PEN_RFI_RUN          ));
   WrtHrTrc('   bal_TXB_PEN_RFI_PTD:           '||to_char(bal_TXB_PEN_RFI_PTD          ));
   WrtHrTrc('   bal_TXB_PEN_RFI_YTD:           '||to_char(bal_TXB_PEN_RFI_YTD          ));
   WrtHrTrc('   bal_TEL_ALL_NRFI_CMTD:         '||to_char(bal_TEL_ALL_NRFI_CMTD        ));
   WrtHrTrc('   bal_TEL_ALL_NRFI_CYTD:         '||to_char(bal_TEL_ALL_NRFI_CYTD        ));
   WrtHrTrc('   bal_TEL_ALL_NRFI_RUN:          '||to_char(bal_TEL_ALL_NRFI_RUN         ));
   WrtHrTrc('   bal_TEL_ALL_NRFI_PTD:          '||to_char(bal_TEL_ALL_NRFI_PTD         ));
   WrtHrTrc('   bal_TEL_ALL_NRFI_YTD:          '||to_char(bal_TEL_ALL_NRFI_YTD         ));
   WrtHrTrc('   bal_TEL_ALL_RFI_CMTD:          '||to_char(bal_TEL_ALL_RFI_CMTD         ));
   WrtHrTrc('   bal_TEL_ALL_RFI_CYTD:          '||to_char(bal_TEL_ALL_RFI_CYTD         ));
   WrtHrTrc('   bal_TEL_ALL_RFI_RUN:           '||to_char(bal_TEL_ALL_RFI_RUN          ));
   WrtHrTrc('   bal_TEL_ALL_RFI_PTD:           '||to_char(bal_TEL_ALL_RFI_PTD          ));
   WrtHrTrc('   bal_TEL_ALL_RFI_YTD:           '||to_char(bal_TEL_ALL_RFI_YTD          ));
   WrtHrTrc('   bal_TOOL_ALL_NRFI_CMTD:        '||to_char(bal_TOOL_ALL_NRFI_CMTD       ));
   WrtHrTrc('   bal_TOOL_ALL_NRFI_CYTD:        '||to_char(bal_TOOL_ALL_NRFI_CYTD       ));
   WrtHrTrc('   bal_TOOL_ALL_NRFI_RUN:         '||to_char(bal_TOOL_ALL_NRFI_RUN        ));
   WrtHrTrc('   bal_TOOL_ALL_NRFI_PTD:         '||to_char(bal_TOOL_ALL_NRFI_PTD        ));
   WrtHrTrc('   bal_TOOL_ALL_NRFI_YTD:         '||to_char(bal_TOOL_ALL_NRFI_YTD        ));
   WrtHrTrc('   bal_TOOL_ALL_RFI_CMTD:         '||to_char(bal_TOOL_ALL_RFI_CMTD        ));
   WrtHrTrc('   bal_TOOL_ALL_RFI_CYTD:         '||to_char(bal_TOOL_ALL_RFI_CYTD        ));
   WrtHrTrc('   bal_TOOL_ALL_RFI_RUN:          '||to_char(bal_TOOL_ALL_RFI_RUN         ));
   WrtHrTrc('   bal_TOOL_ALL_RFI_PTD:          '||to_char(bal_TOOL_ALL_RFI_PTD         ));
   WrtHrTrc('   bal_TOOL_ALL_RFI_YTD:          '||to_char(bal_TOOL_ALL_RFI_YTD         ));
   WrtHrTrc('   bal_TOT_INC_PTD:               '||to_char(bal_TOT_INC_PTD              ));
   WrtHrTrc('   bal_TOT_INC_YTD:               '||to_char(bal_TOT_INC_YTD              ));
   WrtHrTrc('   bal_TOT_NRFI_AN_INC_CMTD:      '||to_char(bal_TOT_NRFI_AN_INC_CMTD     ));
   WrtHrTrc('   bal_TOT_NRFI_AN_INC_CYTD:      '||to_char(bal_TOT_NRFI_AN_INC_CYTD     ));
   WrtHrTrc('   bal_TOT_NRFI_AN_INC_RUN:       '||to_char(bal_TOT_NRFI_AN_INC_RUN      ));
   WrtHrTrc('   bal_TOT_NRFI_AN_INC_PTD:       '||to_char(bal_TOT_NRFI_AN_INC_PTD      ));
   WrtHrTrc('   bal_TOT_NRFI_AN_INC_YTD:       '||to_char(bal_TOT_NRFI_AN_INC_YTD      ));
   WrtHrTrc('   bal_TOT_NRFI_INC_CMTD:         '||to_char(bal_TOT_NRFI_INC_CMTD        ));
   WrtHrTrc('   bal_TOT_NRFI_INC_CYTD:         '||to_char(bal_TOT_NRFI_INC_CYTD        ));
   WrtHrTrc('   bal_TOT_NRFI_INC_RUN:          '||to_char(bal_TOT_NRFI_INC_RUN         ));
   WrtHrTrc('   bal_TOT_NRFI_INC_PTD:          '||to_char(bal_TOT_NRFI_INC_PTD         ));
   WrtHrTrc('   bal_TOT_NRFI_INC_YTD:          '||to_char(bal_TOT_NRFI_INC_YTD         ));
   WrtHrTrc('   bal_TOT_RFI_AN_INC_CMTD:       '||to_char(bal_TOT_RFI_AN_INC_CMTD      ));
   WrtHrTrc('   bal_TOT_RFI_AN_INC_CYTD:       '||to_char(bal_TOT_RFI_AN_INC_CYTD      ));
   WrtHrTrc('   bal_TOT_RFI_AN_INC_RUN:        '||to_char(bal_TOT_RFI_AN_INC_RUN       ));
   WrtHrTrc('   bal_TOT_RFI_AN_INC_PTD:        '||to_char(bal_TOT_RFI_AN_INC_PTD       ));
   WrtHrTrc('   bal_TOT_RFI_AN_INC_YTD:        '||to_char(bal_TOT_RFI_AN_INC_YTD       ));
   WrtHrTrc('   bal_TOT_RFI_INC_CMTD:          '||to_char(bal_TOT_RFI_INC_CMTD         ));
   WrtHrTrc('   bal_TOT_RFI_INC_CYTD:          '||to_char(bal_TOT_RFI_INC_CYTD         ));
   WrtHrTrc('   bal_TOT_RFI_INC_RUN:           '||to_char(bal_TOT_RFI_INC_RUN          ));
   WrtHrTrc('   bal_TOT_RFI_INC_PTD:           '||to_char(bal_TOT_RFI_INC_PTD          ));
   WrtHrTrc('   bal_TOT_RFI_INC_YTD:           '||to_char(bal_TOT_RFI_INC_YTD          ));
   WrtHrTrc('   bal_TOT_SEA_WRK_DYS_WRK_YTD:   '||to_char(bal_TOT_SEA_WRK_DYS_WRK_YTD  ));
   WrtHrTrc('   bal_TOT_TXB_INC_ITD:           '||to_char(bal_TOT_TXB_INC_ITD          ));
   WrtHrTrc('   bal_TA_NRFI_CMTD:              '||to_char(bal_TA_NRFI_CMTD             ));
   WrtHrTrc('   bal_TA_NRFI_CYTD:              '||to_char(bal_TA_NRFI_CYTD             ));
   WrtHrTrc('   bal_TA_NRFI_PTD:               '||to_char(bal_TA_NRFI_PTD              ));
   WrtHrTrc('   bal_TA_NRFI_YTD:               '||to_char(bal_TA_NRFI_YTD              ));
   WrtHrTrc('   bal_TA_RFI_CMTD:               '||to_char(bal_TA_RFI_CMTD              ));
   WrtHrTrc('   bal_TA_RFI_CYTD:               '||to_char(bal_TA_RFI_CYTD              ));
   WrtHrTrc('   bal_TA_RFI_PTD:                '||to_char(bal_TA_RFI_PTD               ));
   WrtHrTrc('   bal_TA_RFI_YTD:                '||to_char(bal_TA_RFI_YTD               ));
   WrtHrTrc('   bal_USE_VEH_NRFI_CMTD:         '||to_char(bal_USE_VEH_NRFI_CMTD        ));
   WrtHrTrc('   bal_USE_VEH_NRFI_CYTD:         '||to_char(bal_USE_VEH_NRFI_CYTD        ));
   WrtHrTrc('   bal_USE_VEH_NRFI_RUN:          '||to_char(bal_USE_VEH_NRFI_RUN         ));
   WrtHrTrc('   bal_USE_VEH_NRFI_PTD:          '||to_char(bal_USE_VEH_NRFI_PTD         ));
   WrtHrTrc('   bal_USE_VEH_NRFI_YTD:          '||to_char(bal_USE_VEH_NRFI_YTD         ));
   WrtHrTrc('   bal_USE_VEH_RFI_CMTD:          '||to_char(bal_USE_VEH_RFI_CMTD         ));
   WrtHrTrc('   bal_USE_VEH_RFI_CYTD:          '||to_char(bal_USE_VEH_RFI_CYTD         ));
   WrtHrTrc('   bal_USE_VEH_RFI_RUN:           '||to_char(bal_USE_VEH_RFI_RUN          ));
   WrtHrTrc('   bal_USE_VEH_RFI_PTD:           '||to_char(bal_USE_VEH_RFI_PTD          ));
   WrtHrTrc('   bal_USE_VEH_RFI_YTD:           '||to_char(bal_USE_VEH_RFI_YTD          ));

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',1);

-- Initialise Package Globals
-- Contexts
   con_ASG_ACT_ID := ASSIGNMENT_ACTION_ID;
   con_ASG_ID     := ASSIGNMENT_ID;
   con_PRL_ACT_ID := PAYROLL_ACTION_ID;
   con_PRL_ID     := PAYROLL_ID;

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',2);

-- Date Effective Tax Status Validation
--
/*   IF dbi_TX_STA IN ('J','K','L') THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'PY_ZA_TX_STATE_AUG';
      END IF;
      RAISE xpt_E;
   END IF;
*/
-- Tax Override Validation
--
   /*
   V = Amount
   P = Percentage
   S = Force Site Calculation
   */

--  Tax Status Validation
--
   /*
   A = Normal
   B = Provisional
   C = Directive Amount
   D = Directive Percentage
   E = Close Corporation
   F = Temporary Worker/Student
   G = Seasonal Worker
   H = Zero Tax
   J = Personal Service Company
   K = Personal Service Trust
   L = Labour Broker
   M = Private Director
   N = Private Director with Directive Amount
   P = Private Director with Directive Percentage
   Q = Private Director Zero Tax
   */
   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',3);

-- C = Directive Amount
-- N = Private Director with Directive Amount
--
   IF dbi_TX_STA IN ('C','N') THEN
      IF trc_OvrTxCalc AND (trc_OvrTyp = 'S' OR trc_OvrTyp = 'P') THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',4);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',5);
            xpt_Msg := 'PY_ZA_TX_OVR_TX_STATE_C';
         END IF;
         RAISE xpt_E;
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',6);
      ELSIF trc_OvrTxCalc AND trc_OvrTyp = 'V' THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',7);
         trc_CalTyp := 'OvrCalc';
         trc_OvrWrn := 'WARNING: Tax Override - Total Tax Value: '||to_char(trc_LibFpNI + trc_LibFpAP);
      -- Check Directive Number First
      ELSIF dbi_TX_DIR_NUM = 'NULL' THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',8);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',9);
            xpt_Msg := 'PY_ZA_TX_DIR_NUM';
         END IF;
         RAISE xpt_E;
      -- Check that directive value is filled in
      ELSIF dbi_TX_DIR_VAL = -1 THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',10);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',11);
            xpt_Msg := 'PY_ZA_TX_DIR_MONT';
         END IF;
         RAISE xpt_E;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',12);
         trc_CalTyp := 'NoCalc';
         -- Liability = entered value
         trc_LibFpNI := dbi_TX_DIR_VAL;
         -- Standard NetPay Validation
         py_za_tx_utl_01032002.ValidateTaxOns;
      END IF;
-- D = Directive Percentage
-- P = Private Director wth Directive Percentage
--
   ELSIF dbi_TX_STA IN ('D','P') THEN
      IF trc_OvrTxCalc AND trc_OvrTyp = 'S' THEN
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',13);
            xpt_Msg := 'PY_ZA_TX_OVR_TX_STATE_DEF';
         END IF;
         RAISE xpt_E;
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',14);
      ELSIF trc_OvrTxCalc AND trc_OvrTyp = 'V' THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',15);
         trc_CalTyp := 'OvrCalc';
         trc_OvrWrn := 'WARNING: Tax Override - Total Tax Value: '||to_char(trc_LibFpNI + trc_LibFpAP);
      ELSE
         IF trc_OvrTxCalc AND trc_OvrTyp = 'P' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',16);
            trc_OvrWrn := 'WARNING: Tax Override - '||to_char(trc_OvrPrc)||' Percent';
            -- Percentage taken into account in py_za_tx_utl_01032002.TaxLiability
         END IF;
         -- Check Directive Number First
         IF dbi_TX_DIR_NUM = 'NULL' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',17);
            IF xpt_Msg = 'No Error' THEN
               hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',18);
               xpt_Msg := 'PY_ZA_TX_DIR_NUM';
            END IF;
            RAISE xpt_E;
         -- Check that directive value is filled in
         ELSIF dbi_TX_DIR_VAL = -1 THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',19);
            IF xpt_Msg = 'No Error' THEN
               hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',20);
               xpt_Msg := 'PY_ZA_TX_DIR_PERC';
            END IF;
            RAISE xpt_E;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',21);
            DirCalc;
         END IF;
      END IF;
-- E = Close Corporation
-- F = Temporary Worker/Student
-- J = Personal Service Company
-- K = Personal Service Trust
-- L = Labour Broker
--
   ELSIF dbi_TX_STA IN ('E','F','J','K','L') THEN
      IF trc_OvrTxCalc AND trc_OvrTyp = 'S' THEN
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',22);
            xpt_Msg := 'PY_ZA_TX_OVR_TX_STATE_DEF';
         END IF;
         RAISE xpt_E;
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',23);
      ELSIF trc_OvrTxCalc AND trc_OvrTyp = 'V' THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',24);
         trc_CalTyp := 'OvrCalc';
         trc_OvrWrn := 'WARNING: Tax Override - Total Tax Value: '||to_char(trc_LibFpNI + trc_LibFpAP);
      ELSE
         IF trc_OvrTxCalc AND trc_OvrTyp = 'P' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',25);
            trc_OvrWrn := 'WARNING: Tax Override - '||to_char(trc_OvrPrc)||' Percent';
            -- Percentage taken into account in py_za_tx_utl_01032002.TaxLiability
         END IF;
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',26);
         -- Simply Execute the Directive Calculation
         DirCalc;
      END IF;
-- G = Seasonal Worker
--
   ELSIF dbi_TX_STA = 'G' THEN
      IF trc_OvrTxCalc AND (trc_OvrTyp = 'S' OR trc_OvrTyp = 'P') THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',27);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',28);
            xpt_Msg := 'PY_ZA_TX_OVR_TX_STATE_G';
         END IF;
         RAISE xpt_E;
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',29);
      -- Check that seasonal worker days worked is filled in
      ELSIF dbi_SEA_WRK_DYS_WRK = 0 THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',30);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',31);
            xpt_Msg := 'PY_ZA_TX_SEA_WRK_DYS';
         END IF;
         RAISE xpt_E;
      ELSE
         IF trc_OvrTxCalc AND trc_OvrTyp = 'V' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',32);
            trc_CalTyp := 'OvrCalc';
            trc_OvrWrn := 'WARNING: Tax Override - Total Tax Value: '||to_char(trc_LibFpNI + trc_LibFpAP);
            py_za_tx_utl_01032002.SetRebates;
         ELSE
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',33);
            SeaCalc;
         END IF;
      END IF;
-- A = Normal
-- B = Provisional
-- M = Private Director
--
   ELSIF dbi_TX_STA IN ('A','B','M') THEN
      IF dbi_TX_STA <> 'M' THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',34);
         -- Deemed Remuneration only applicable to 'M'
         bal_DIR_DMD_RMN_ITD := 0;
      END IF;

      IF trc_OvrTxCalc AND trc_OvrTyp = 'V' THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',35);
         trc_CalTyp := 'OvrCalc';
         trc_OvrWrn := 'WARNING: Tax Override - Total Tax Value: '||to_char(trc_LibFpNI + trc_LibFpAP);
         py_za_tx_utl_01032002.SetRebates;
         trc_SitFactor := dbi_ZA_DYS_IN_YR / py_za_tx_utl_01032002.DaysWorked;
      ELSIF trc_OvrTxCalc AND trc_OvrTyp = 'S' THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',36);
         trc_CalTyp := 'OvrCalc';
         trc_OvrWrn := 'WARNING: Tax Override - Forced Site Calculation';
         -- Force the Site Calculation
         SitCalc;
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',37);
      ELSE
         IF trc_OvrTxCalc AND trc_OvrTyp = 'P' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',38);
            trc_OvrWrn := 'WARNING: Tax Override - '||to_char(trc_OvrPrc)||' Percent';
            -- Percentage taken into account in py_za_tx_utl_01032002.TaxLiability
         END IF;

         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',39);
         IF py_za_tx_utl_01032002.LatePayPeriod THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',40);
            LteCalc;
         -- Is this a SITE Period?
         ELSIF py_za_tx_utl_01032002.EmpTermPrePeriod THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',41);
            SitCalc;
         ELSIF py_za_tx_utl_01032002.LstPeriod OR py_za_tx_utl_01032002.EmpTermInPeriod THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',42);
            IF py_za_tx_utl_01032002.PreErnPeriod THEN
               hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',43);
               YtdCalc;
            ELSE
               hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',44);
               SitCalc;
            END IF;
         ElSE
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',45);
            -- The employee has NOT been terminated!
            IF py_za_tx_utl_01032002.PreErnPeriod THEN
               hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',46);
               YtdCalc;
            ELSIF dbi_ZA_ASG_TX_RTR_PRD = 'Y' THEN
               hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',47);
               SitCalc;
            ELSIF py_za_tx_utl_01032002.NegPtd THEN
               hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',48);
               SitCalc;
            ELSE
               hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',49);
               NorCalc;
            END IF;
         END IF;
      END IF;
-- H = Zero Tax
-- Q = Private Director Zero Tax
--
   ELSIF dbi_TX_STA IN ('H','Q') THEN
      IF trc_OvrTxCalc THEN
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',50);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',51);
            xpt_Msg := 'PY_ZA_TX_OVR_TX_STATE_H';
         END IF;
         RAISE xpt_E;
      ELSE
         hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',52);
         trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
         trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
         trc_LibFpTA := -1 * bal_TX_ON_TA_YTD;
         trc_LibFpBP := -1 * bal_TX_ON_BP_YTD;
         trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
         trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
         trc_LibFpPO := -1 * bal_TX_ON_PO_YTD;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',53);
      hr_utility.set_message(801, 'ERROR: Invalid Tax Status');
      hr_utility.raise_error;
   END IF;

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',54);

-- Post Calculation Steps
--
   py_za_tx_utl_01032002.SitPaySplit;

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',55);

-- Execute the Arrear Processing
--
   IF py_za_tx_utl_01032002.SitePeriod THEN
      hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',56);
      py_za_tx_utl_01032002.ArrearExcess;
   END IF;

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',57);

-- Calculate Net Taxable Income
--
   NetTxbIncCalc;

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',58);

-- Setup the Out Parameters
--
   -- Messages
   p_LibWrn := trc_LibWrn;   -- Liability Warning
   p_OvrWrn := trc_OvrWrn;   -- Override Warning

   -- Pay Values
   trc_PayValSD := ( trc_LibFpNI
                   + trc_LibFpFB
                   + trc_LibFpTA
                   + trc_LibFpBP
                   + trc_LibFpAB
                   + trc_LibFpAP
                   + trc_LibFpPO
                   );
   trc_PayValEC := trc_LibFpDR;

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',59);

   -- Tax On's
   p_LibFpDR  := trc_LibFpDR;
   p_LibFpNI  := trc_LibFpNI;
   p_LibFpFB  := trc_LibFpFB;
   p_LibFpTA  := trc_LibFpTA;
   p_LibFpBP  := trc_LibFpBP;
   p_LibFpAB  := trc_LibFpAB;
   p_LibFpAP  := trc_LibFpAP;
   p_LibFpPO  := trc_LibFpPO;
   p_PayValSD := trc_PayValSD;
   p_PayValEC := trc_PayValEC;

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',60);

   -- Indicators, Splits and Updates
   p_PayeVal   := trc_PayeVal;
   p_SiteVal   := trc_SiteVal;
   p_It3Ind    := trc_It3Ind;
   p_PfUpdFig  := trc_PfUpdFig;
   p_RaUpdFig  := trc_RaUpdFig;
   p_OUpdFig   := trc_OUpdFig;
   p_NtiUpdFig := trc_NtiUpdFig;

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',61);

-- Execute The Tax Trace
--
   py_za_tx_utl_01032002.Trace;

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',62);

-- Clear Globals
--
   py_za_tx_utl_01032002.ClearGlobals;

   hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',63);

-- End off Trace File
   WrtHrTrc('------------------------------------------------------------');
   WrtHrTrc('--                End of Tax Trace File                   --');
   WrtHrTrc('------------------------------------------------------------');
   WrtHrTrc('                             --                             ');

-- Call hr_utility stop procedure
   py_za_tx_utl_01032002.StopHrTrace;

  --dbms_debug.debug_off;

   RETURN l_Dum;

EXCEPTION
   WHEN xpt_E  THEN
      hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',64);
      WrtHrTrc('xpt_Msg: '||xpt_Msg);
      py_za_tx_utl_01032002.StopHrTrace;
      hr_utility.set_message(801, xpt_Msg);
      py_za_tx_utl_01032002.ClearGlobals;
      hr_utility.raise_error;
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tx_01032002.ZaTx_01032002',65);
      WrtHrTrc('Sql error code: '||TO_CHAR(SQLCODE));
      WrtHrTrc('Sql error msg: '||SUBSTR(SQLERRM(SQLCODE), 1, 100));
      py_za_tx_utl_01032002.StopHrTrace;
      hr_utility.set_message(801, 'ZaTx_01032002: '||TO_CHAR(SQLCODE));
      py_za_tx_utl_01032002.ClearGlobals;
      hr_utility.raise_error;
END ZaTx_01032002;

END py_za_tx_01032002;


/
