--------------------------------------------------------
--  DDL for Package Body PY_ZA_TX_01032000
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_TX_01032000" AS
/* $Header: pyzat002.pkb 120.2 2005/06/28 00:10:09 kapalani noship $ */
/* Copyright (c) Oracle Corporation 1999. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation Tax Module

   NAME
      py_za_tx_01032000.pkb

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
      Person      Date(DD-MM-YYYY)   Version   Comments
      ---------   ----------------   -------   ---------------------------------------------
      A. Mahanty  14/04/2005         115.4     Bug 3491357 :BRA Enhancement
                                               Balance Value retrieval modified.
      J.N. Louw   17/01/2001         110.13    Added Negative Check Category
                                                  Calculation Logic - AB/AP
      J.N. Louw   13/12/2000         110.12    Upped Header Ver for Patch
      J.N. Louw   06/12/2000         110.11    Added SetRebates procedure call
                                               Modified ZaTx_01032000 with new
                                                  logic
      L.J. Kloppers  22-11-2000      115.1     Changed per_time_periods.attribute1
                                               to per_time_periods.prd_information1
      J.N. Louw   28/09/2000         110.10    Check for negative dbi_TX_DIR_VAL
                                                  dbi_ZA_TX_YR_STRT - 1 for CalCalc
                                               Updated SeaCalc
                                                  Removed Tax on Public Office
                                                  Fixed Cascading Bug
                                               Override Functionality
                                               Added hr_utility trace
                                               Moved private functions and
                                                procedures to utility package
      J.N. Louw   12/04/2000         110.9     Added Calendar Month to Date
                                                Balances to cater for the
                                                calculation of Net Taxable Income
                                                Used in the calculation of the
                                                Skills Development Levy
      J.N. Louw   16-03-2000         110.8     bal_TXB_SUBS* deleted:
                                                Subsistence Allowance change
      J.N. Louw   06-03-2000         110.7     SitePayeSplit for 'G'
                                                Added balance:
                                                Total Seasonal Workers Days
                                                  Worked:
                                                  bal_TOT_SEA_WRK_DYS_WRK
                                              trc_MsgTxStatus Now Error State:
                                                FATAL error level
                                              trc_MsgTxStatus removed -
                                                replaced by utility msg
                                                in FND_NEW_MESSAGES -
                                                Fatal message - error state
      J.N. Louw   17-02-2000         110.6     Added LteCalc - Late Payments
                                              Merged and Expanded
                                              py_za_tx_utl_01032000.TrvAllYtd
                                                and py_za_tx_utl_01032000.TrvAllCal into
                                                py_za_tx_utl_01032000.TrvAll
                                              Created py_za_tx_utl_01032000.GlbVal function
                                              Created py_za_tx_utl_01032000.LatePayPeriod function
                                              Updated ZaTx_01032000 with
                                                Late Payments checks
                                              Updated py_za_tx_utl_01032000.Abatements with
                                                Late Payments checks
                                              trc_SitFactor now defaults
                                                to 1(One)
                                              Updated Balance Functions
                                                with new balances and
                                                re-ordered
                                              Fixed Excess Arrear Carryover
                                              Fixed 'G' py_za_tx_utl_01032000.SitPaySplit
                                              c/p_PAYE_PTD,p_SITE_PTD,
                                                bal_PAYE_PTD,bal_SITE_PTD
                                               /p_PAYE_YTD,p_SITE_YTD,
                                                bal_PAYE_YTD,bal_SITE_YTD
                                              Updated py_za_tx_utl_01032000.SitPaySplit:
                                                Reset SITE in case of
                                                directive status(C,D,E,F)
      J.N. Louw   09-02-2000         110.5     Fixed 65 Rebate and Threshold
                                                Check
                                              Altered Threshold Validation:
                                                NorCalc, SitCalc
                                                Tax on ... Refund
                                              Altered Ytd Income Validation:
                                                DirCalc, NorCalc, SitCalc
                                                Tax on ... Refund
                                              Altered ZaTx_01032000:
                                                Tax Status Validation
                                              Altered py_za_tx_utl_01032000.NpVal:
                                                Override of Liability
      J.N. Louw   02-02-2000         110.4     Added
                                               py_za_tx_utl_01032000.PreErnPeriod Function
                                              Addded Balance Feed Functionality
                                                for the Total Taxable Income
                                                balance
                                              bal_PRCH_ANU_TXB_RFI_RUN
                                              Added bal_PAYE_PTD,bal_SITE_PTD
                                              Fixed BasCalc
                                              Added py_za_tx_utl_01032000.LstPeriod
                                              ,py_za_tx_utl_01032000.EmpTermInPeriod,
                                              py_za_tx_utl_01032000.EmpTermPrePeriod Functions
                                              Removed TxbIncYtd check in
                                                SitCalc
                                              Fixed De-annualisation of Public
                                                Office Allowance - SitCalc,
                                                SeaCalc
      J.N. Louw   20-01-2000         110.3     Fixed bug on py_za_tx_utl_01032000.NpVal
                                               when Net Pay
                                                is zero
      J.N. Louw   14-01-2000         110.2     Removed Tot RFI vs
                                                Taxable Income Check from
                                                abatements calculation
      J.N. Louw   09-12-1999         110.1     Arrear Excess Processing
      J.N. Louw   13-09-1999         110.0     First Created
*/




/* PACKAGE BODY */

PROCEDURE NetTxbIncCalc AS

   -- Variable Declaration
   nti_CurMthStrtDte DATE;
   nti_CurMthEndDte  DATE;
   nti_SitFactor     NUMBER;
   nti_PerTypInc     NUMBER(15,2) DEFAULT 0;
   nti_PerTypErn     NUMBER(15,2) DEFAULT 0;
   nti_AnnTypErn     NUMBER(15,2) DEFAULT 0;
   nti_PerPenFnd     NUMBER(15,2) DEFAULT 0;
   nti_PerRfiCon     NUMBER(15,2) DEFAULT 0;
   nti_PerPenFndMax  NUMBER(15,2) DEFAULT 0;
   nti_PerPenFndAbm  NUMBER(15,2) DEFAULT 0;
   nti_AnnPenFnd     NUMBER(15,2) DEFAULT 0;
   nti_AnnRfiCon     NUMBER(15,2) DEFAULT 0;
   nti_AnnPenFndMax  NUMBER(15,2) DEFAULT 0;
   nti_AnnPenFndAbm  NUMBER(15,2) DEFAULT 0;
   nti_ArrPenFnd     NUMBER(15,2) DEFAULT 0;
   nti_ArrPenFndAbm  NUMBER(15,2) DEFAULT 0;
   nti_RetAnu        NUMBER(15,2) DEFAULT 0;
   nti_NrfiCon       NUMBER(15,2) DEFAULT 0;
   nti_RetAnuMax     NUMBER(15,2) DEFAULT 0;
   nti_RetAnuAbm     NUMBER(15,2) DEFAULT 0;
   nti_ArrRetAnu     NUMBER(15,2) DEFAULT 0;
   nti_ArrRetAnuAbm  NUMBER(15,2) DEFAULT 0;
   nti_MedAidAbm     NUMBER(15,2) DEFAULT 0;
   nti_PerTotAbm     NUMBER(15,2) DEFAULT 0;
   nti_AnnTotAbm     NUMBER(15,2) DEFAULT 0;
   nti_TxbPerTypInc  NUMBER(15,2) DEFAULT 0;
   nti_TxbAnnTypInc  NUMBER(15,2) DEFAULT 0;
   nti_NetPerTxbInc  NUMBER(15,2) DEFAULT 0;
   nti_NetAnnTxbInc  NUMBER(15,2) DEFAULT 0;
   l_65Year          DATE;

BEGIN
   hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',1);
-- Calculate the Current Effective Calendar Month to Date Start Date
--
   SELECT trunc(dbi_SES_DTE,'Month')
     INTO nti_CurMthStrtDte
     FROM dual;

   hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',2);

-- Calculate the Current Effective Calendar Month to Date End Date
--
   SELECT last_day(dbi_SES_DTE)
     INTO nti_CurMthEndDte
     FROM dual;

   hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',3);

-- Calculate Site Factor
--
   -- Based on the number of days in the calendar year over days in the calendar month
   nti_SitFactor := dbi_ZA_DYS_IN_YR / (nti_CurMthEndDte - nti_CurMthStrtDte + 1);
   hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',4);
   py_za_tx_utl_01032000.WriteHrTrace('nti_CurMthEndDte: '||to_char(nti_CurMthEndDte,'DD/MM/YYYY'));
   py_za_tx_utl_01032000.WriteHrTrace('nti_CurMthStrtDte: '||to_char(nti_CurMthStrtDte,'DD/MM/YYYY'));

-- Calculate the Taxable Portion of the Not-Fully Taxable Income Balances
--
   bal_TA_RFI_CMTD := bal_TA_RFI_CMTD * glb_ZA_TRV_ALL_TX_PRC / 100;
   bal_TA_NRFI_CMTD := bal_TA_NRFI_CMTD * glb_ZA_TRV_ALL_TX_PRC / 100;

   bal_PO_RFI_CMTD := bal_PO_RFI_CMTD * glb_ZA_PBL_TX_PRC / 100;
   bal_PO_NRFI_CMTD := bal_PO_NRFI_CMTD * glb_ZA_PBL_TX_PRC / 100;

-- Sum Period Type Income Calendar Month to Date Balances
--
   nti_PerTypInc :=
      ( bal_AST_PRCHD_RVAL_NRFI_CMTD
      + bal_AST_PRCHD_RVAL_RFI_CMTD
      + bal_BP_CMTD
      + bal_BUR_AND_SCH_NRFI_CMTD
      + bal_BUR_AND_SCH_RFI_CMTD
      + bal_COMM_NRFI_CMTD
      + bal_COMM_RFI_CMTD
      + bal_COMP_ALL_NRFI_CMTD
      + bal_COMP_ALL_RFI_CMTD
      + bal_ENT_ALL_NRFI_CMTD
      + bal_ENT_ALL_RFI_CMTD
      + bal_FREE_ACCOM_NRFI_CMTD
      + bal_FREE_ACCOM_RFI_CMTD
      + bal_FREE_SERV_NRFI_CMTD
      + bal_FREE_SERV_RFI_CMTD
      + bal_LOW_LOANS_NRFI_CMTD
      + bal_LOW_LOANS_RFI_CMTD
      + bal_MED_PAID_NRFI_CMTD
      + bal_MED_PAID_RFI_CMTD
      + bal_MLS_AND_VOUCH_NRFI_CMTD
      + bal_MLS_AND_VOUCH_RFI_CMTD
      + bal_OTHER_TXB_ALL_NRFI_CMTD
      + bal_OTHER_TXB_ALL_RFI_CMTD
      + bal_OVTM_NRFI_CMTD
      + bal_OVTM_RFI_CMTD
      + bal_PO_NRFI_CMTD
      + bal_PO_RFI_CMTD
      + bal_PYM_DBT_NRFI_CMTD
      + bal_PYM_DBT_RFI_CMTD
      + bal_RGT_AST_NRFI_CMTD
      + bal_RGT_AST_RFI_CMTD
      + bal_TA_NRFI_CMTD
      + bal_TA_RFI_CMTD
      + bal_TEL_ALL_NRFI_CMTD
      + bal_TEL_ALL_RFI_CMTD
      + bal_TOOL_ALL_NRFI_CMTD
      + bal_TOOL_ALL_RFI_CMTD
      + bal_TXB_INC_NRFI_CMTD
      + bal_TXB_INC_RFI_CMTD
      + bal_TXB_PEN_NRFI_CMTD
      + bal_TXB_PEN_RFI_CMTD
      + bal_USE_VEH_NRFI_CMTD
      + bal_USE_VEH_RFI_CMTD
      );

-- Annualise by the Site Factor the Period Type Income
--
   nti_PerTypErn := nti_PerTypInc * nti_SitFactor;

-- Sum Annual Type Income Calendar Month to Date Balances
--
   nti_AnnTypErn :=
      nti_PerTypErn + ( bal_AB_NRFI_CMTD
                      + bal_AB_RFI_CMTD
                      + bal_ANU_FRM_RET_FND_NRFI_CMTD
                      + bal_ANU_FRM_RET_FND_RFI_CMTD
                      + bal_PRCH_ANU_TXB_NRFI_CMTD
                      + bal_PRCH_ANU_TXB_RFI_CMTD
                      + bal_TXB_AP_NRFI_CMTD
                      + bal_TXB_AP_RFI_CMTD
                      );

-- Calculate Abatement Values
--
   -- Pension Fund Abatement
   --
      -- Period Calculation
      --
         -- Annualise Period Pension Fund Contribution
         nti_PerPenFnd := bal_CUR_PF_CMTD * nti_SitFactor;
         -- Annualise Period Rfiable Contributions
         nti_PerRfiCon := bal_TOT_RFI_INC_CMTD * nti_SitFactor;
         -- Calculate the Pension Fund Maximum
         nti_PerPenFndMax := GREATEST(glb_ZA_PF_AN_MX_ABT
                                    ,(glb_ZA_PF_MX_PRC / 100 * nti_PerRfiCon)
                                     );
         -- Calculate Period Pension Fund Abatement
         nti_PerPenFndAbm := LEAST(nti_PerPenFnd, nti_PerPenFndMax);

      -- Annual Calculation
      --
         -- Annual Pension Fund Contribution
         nti_AnnPenFnd := nti_PerPenFnd + bal_ANN_PF_CMTD;
         -- Annual Rfi Contribution
         nti_AnnRfiCon := nti_PerRfiCon + bal_TOT_RFI_AN_INC_CMTD;
         -- Calculate the Pension Fund Maximum
         nti_AnnPenFndMax := GREATEST(glb_ZA_PF_AN_MX_ABT
                                     ,glb_ZA_PF_MX_PRC / 100 * nti_AnnRfiCon
                                     );
         -- Calculate Annual Pension Fund Abatement
         nti_AnnPenFndAbm := LEAST(nti_AnnPenFnd,nti_AnnPenFndMax);

   -- Arrear Pension Fund Abatement
   --
      -- Check Arrear Pension Fund Frequency
      IF dbi_ARR_PF_FRQ = 'M' THEN
         hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',5);
         nti_ArrPenFnd := (bal_ARR_PF_CMTD * nti_SitFactor) + bal_EXC_ARR_PEN_ITD;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',6);
         nti_ArrPenFnd := bal_ARR_PF_CMTD + bal_EXC_ARR_PEN_ITD;
      END IF;
      -- Calculate the Abatement
      nti_ArrPenFndAbm := LEAST(nti_ArrPenFnd, glb_ZA_ARR_PF_AN_MX_ABT);

   -- Retirement Annuity Abatement
   --
      -- Calculate RA Contribution
      IF dbi_RA_FRQ = 'M' THEN
         hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',7);
         nti_RetAnu := bal_CUR_RA_CMTD * nti_SitFactor;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',8);
         nti_RetAnu := bal_CUR_RA_CMTD;
      END IF;
      -- Calculate Nrfi Contribution based on Pension Fund
      -- Contributions
      IF bal_CUR_PF_CMTD = 0 THEN
         hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',9);
         nti_NrfiCon :=
         (( bal_TOT_RFI_INC_CMTD
          + bal_TOT_NRFI_INC_CMTD)* nti_SitFactor)
          + bal_TOT_NRFI_AN_INC_CMTD
          + bal_TOT_RFI_AN_INC_CMTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',10);
         nti_NrfiCon := (bal_TOT_NRFI_INC_CMTD * nti_SitFactor) + bal_TOT_NRFI_AN_INC_CMTD;
      END IF;
      -- Calculate the Retirement Annuity Maximum
      nti_RetAnuMax := GREATEST(glb_ZA_PF_AN_MX_ABT
                               ,glb_ZA_RA_AN_MX_ABT - nti_AnnPenFndAbm
                               ,glb_ZA_RA_MX_PRC / 100 * nti_NrfiCon
                               );
      -- Calculate Retirement Annuity Abatement
      nti_RetAnuAbm := LEAST(nti_RetAnu, nti_RetAnuMax);

   -- Arrear Retirement Annuity Abatement
   --
      -- Check Arrear Retirement Annuity Frequency
      IF dbi_ARR_RA_FRQ = 'M' THEN
         hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',11);
         nti_ArrRetAnu := (bal_ARR_RA_CMTD * nti_SitFactor) + bal_EXC_ARR_RA_ITD;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',12);
         nti_ArrRetAnu := bal_ARR_RA_CMTD + bal_EXC_ARR_RA_ITD;
      END IF;
      -- Calculate the Abatement
      nti_ArrRetAnuAbm := LEAST(nti_ArrRetAnu, glb_ZA_ARR_RA_AN_MX_ABT);

   -- Medical Aid Abatement
   --
     -- Calculate the assignments 65 Year Date
     l_65Year := add_months(dbi_PER_DTE_OF_BRTH,780);
     -- Calculate the Abatement
     IF l_65Year <= dbi_ZA_TX_YR_END THEN
        hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',13);
        nti_MedAidAbm := bal_MED_CONTR_CMTD * nti_SitFactor;
     ELSE
        hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',14);
        nti_MedAidAbm := 0;
     END IF;

   hr_utility.set_location('py_za_tx_01032000.NetTxbIncCalc',15);

   -- Total Abatements
   --
      -- Period Total Abatement
      nti_PerTotAbm := ( nti_PerPenFndAbm
                       + nti_ArrPenFndAbm
                       + nti_RetAnuAbm
                       + nti_ArrRetAnuAbm
                       + nti_MedAidAbm
                       );
      -- Annual Total Abatements
      nti_AnnTotAbm := ( nti_AnnPenFndAbm
                       + nti_ArrPenFndAbm
                       + nti_RetAnuAbm
                       + nti_ArrRetAnuAbm
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

   py_za_tx_utl_01032000.WriteHrTrace('nti_SitFactor: '||to_char(nti_SitFactor));
   py_za_tx_utl_01032000.WriteHrTrace('nti_PerPenFndAbm: '||to_char(nti_PerPenFndAbm));
   py_za_tx_utl_01032000.WriteHrTrace('nti_AnnPenFndAbm: '||to_char(nti_AnnPenFndAbm));
   py_za_tx_utl_01032000.WriteHrTrace('nti_ArrPenFndAbm: '||to_char(nti_ArrPenFndAbm));
   py_za_tx_utl_01032000.WriteHrTrace('nti_RetAnuAbm: '||to_char(nti_RetAnuAbm));
   py_za_tx_utl_01032000.WriteHrTrace('nti_ArrRetAnuAbm: '||to_char(nti_ArrRetAnuAbm));
   py_za_tx_utl_01032000.WriteHrTrace('nti_MedAidAbm: '||to_char(nti_MedAidAbm));
   py_za_tx_utl_01032000.WriteHrTrace('nti_PerTotAbm: '||to_char(nti_PerTotAbm));
   py_za_tx_utl_01032000.WriteHrTrace('nti_AnnTotAbm: '||to_char(nti_AnnTotAbm));
   py_za_tx_utl_01032000.WriteHrTrace('nti_PerTypErn: '||to_char(nti_PerTypErn));
   py_za_tx_utl_01032000.WriteHrTrace('nti_AnnTypErn: '||to_char(nti_AnnTypErn));
   py_za_tx_utl_01032000.WriteHrTrace('nti_NetPerTxbInc: '||to_char(nti_NetPerTxbInc));
   py_za_tx_utl_01032000.WriteHrTrace('nti_NetAnnTxbInc: '||to_char(nti_NetAnnTxbInc));
   py_za_tx_utl_01032000.WriteHrTrace('bal_NET_TXB_INC_CMTD: '||to_char(bal_NET_TXB_INC_CMTD));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NtiUpdFig: '||to_char(trc_NtiUpdFig));

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'NetTxbIncCalc: '||TO_CHAR(SQLCODE);
      END IF;
       RAISE xpt_E;
END NetTxbIncCalc;


FUNCTION ZaTxOvr_01032000(
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
      hr_utility.set_message(801, 'ZaTxOvr_01032000: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxOvr_01032000;

-- Main Tax Calculations
--
--
--
--
--
--

PROCEDURE LteCalc AS

   -- Variables
   l_EndDate DATE;
   l_StrtDte DATE;
   l_65Year DATE;
   l_ZA_TX_YR_END        DATE;
   l_ZA_ADL_TX_RBT       NUMBER;
   l_ZA_PRI_TX_RBT       NUMBER;
   l_ZA_PRI_TX_THRSHLD   NUMBER;
   l_ZA_SC_TX_THRSHLD    NUMBER;

   l_Sl       BOOLEAN;
   l_Np       NUMBER(15,2) DEFAULT 0;


   -- Private Functions
   --
      FUNCTION getBalVal
         (p_BalNme IN pay_balance_types.balance_name%TYPE
         ,p_EffDte   IN DATE
         ) RETURN NUMBER
      AS
      -- Variables
         l_BalVal NUMBER(15,2);
         l_BalTypId pay_balance_types.balance_type_id%TYPE;
         l_dimension pay_balance_dimensions.dimension_name%TYPE ;

      BEGIN
         hr_utility.set_location('py_za_tx_01032000.LteCalc',1);
      -- Get the Balance Type ID
         SELECT pbt.balance_type_id
           INTO l_BalTypId
           FROM pay_balance_types pbt
          WHERE pbt.balance_name = p_BalNme;

         hr_utility.set_location('py_za_tx_01032000.LteCalc',2);

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
         l_BalVal NUMBER(15,2);
         l_BalTypId pay_balance_types.balance_type_id%TYPE;
         l_dimension pay_balance_dimensions.dimension_name%TYPE ;
      BEGIN
         hr_utility.set_location('py_za_tx_01032000.LteCalc',3);
      -- Get the Balance Type ID
         SELECT pbt.balance_type_id
           INTO l_BalTypId
           FROM pay_balance_types pbt
          WHERE pbt.balance_name = p_BalNme;

         hr_utility.set_location('py_za_tx_01032000.LteCalc',4);

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
   hr_utility.set_location('py_za_tx_01032000.LteCalc',5);
-- Does the Assignment have an OFigure?
--
   IF bal_TOT_TXB_INC_ITD <= 0 THEN
      hr_utility.set_location('py_za_tx_01032000.LteCalc',6);
   -- Calculate the 'O' Figure
   -- Set the Global
      trc_CalTyp := 'PstCalc';
   -- Set the Site Factor to the value of the previous tax year
      -- Get the tax year start date
      SELECT min(ptp.start_date)
        INTO l_StrtDte
        FROM per_time_periods ptp
       WHERE ptp.prd_information1 = trc_AsgTxYear
         AND ptp.payroll_id = con_PRL_ID;

      hr_utility.set_location('py_za_tx_01032000.LteCalc',7);

      -- Get the tax year end date
      SELECT max(ptp.end_date)
        INTO l_EndDate
        FROM per_time_periods ptp
       WHERE ptp.prd_information1 = trc_AsgTxYear
         AND ptp.payroll_id = con_PRL_ID;

      hr_utility.set_location('py_za_tx_01032000.LteCalc',8);

      trc_SitFactor := (l_EndDate - l_StrtDte + 1) / py_za_tx_utl_01032000.DaysWorked;

   -- Get the assignment's previous tax year end date
      SELECT MAX(ptp.end_date) "EndDate"
        INTO l_EndDate
        FROM per_time_periods ptp
       WHERE ptp.payroll_id = con_PRL_ID
         AND ptp.prd_information1 = trc_AsgTxYear
       GROUP BY ptp.prd_information1;

      hr_utility.set_location('py_za_tx_01032000.LteCalc',9);

   -- Populate Local Balance Variables
   -- The PTD Globals are used as dummy to store the previous tax year's
   -- Balance values

      bal_AB_NRFI_PTD              := getBalVal('Annual Bonus NRFI',l_EndDate);
      bal_AB_RFI_PTD               := getBalVal('Annual Bonus RFI',l_EndDate);
      bal_AC_NRFI_PTD              := getBalVal('Annual Commission NRFI',l_EndDate);
      bal_AC_RFI_PTD               := getBalVal('Annual Commission RFI',l_EndDate);
      bal_ANN_PF_PTD               := getBalVal('Annual Pension Fund',l_EndDate);
      bal_ANU_FRM_RET_FND_NRFI_PTD := getBalVal('Annuity from Retirement Fund NRFI',l_EndDate);
      bal_ANU_FRM_RET_FND_RFI_PTD  := getBalVal('Annuity from Retirement Fund RFI',l_EndDate);
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
      bal_CUR_PF_PTD               := getBalVal('Current Pension Fund',l_EndDate);
      bal_CUR_RA_PTD               := getBalVal('Current Retirement Annuity',l_EndDate);
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

   hr_utility.set_location('py_za_tx_01032000.LteCalc',10);

   -- Update Globals with Correct Taxable Values
      py_za_tx_utl_01032000.TrvAll;

      bal_PO_NRFI_PTD := bal_PO_NRFI_PTD * py_za_tx_utl_01032000.GlbVal('ZA_PUBL_TAX_PERC',l_EndDate) / 100;
      bal_PO_RFI_PTD := bal_PO_RFI_PTD * py_za_tx_utl_01032000.GlbVal('ZA_PUBL_TAX_PERC',l_EndDate) / 100;

   hr_utility.set_location('py_za_tx_01032000.LteCalc',11);

   -- Rebates
      py_za_tx_utl_01032000.SetRebates;
   -- Abatements
      py_za_tx_utl_01032000.Abatements;

   hr_utility.set_location('py_za_tx_01032000.LteCalc',12);

   -- Base Earnings
   --
      trc_BseErn :=
         (( bal_AST_PRCHD_RVAL_NRFI_PTD
         + bal_AST_PRCHD_RVAL_RFI_PTD
         + bal_BP_PTD
         + bal_BUR_AND_SCH_NRFI_PTD
         + bal_BUR_AND_SCH_RFI_PTD
         + bal_COMM_NRFI_PTD
         + bal_COMM_RFI_PTD
         + bal_COMP_ALL_NRFI_PTD
         + bal_COMP_ALL_RFI_PTD
         + bal_ENT_ALL_NRFI_PTD
         + bal_ENT_ALL_RFI_PTD
         + bal_FREE_ACCOM_NRFI_PTD
         + bal_FREE_ACCOM_RFI_PTD
         + bal_FREE_SERV_NRFI_PTD
         + bal_FREE_SERV_RFI_PTD
         + bal_LOW_LOANS_NRFI_PTD
         + bal_LOW_LOANS_RFI_PTD
         + bal_MED_PAID_NRFI_PTD
         + bal_MED_PAID_RFI_PTD
         + bal_MLS_AND_VOUCH_NRFI_PTD
         + bal_MLS_AND_VOUCH_RFI_PTD
         + bal_OTHER_TXB_ALL_NRFI_PTD
         + bal_OTHER_TXB_ALL_RFI_PTD
         + bal_OVTM_NRFI_PTD
         + bal_OVTM_RFI_PTD
         + bal_PO_NRFI_PTD
         + bal_PO_RFI_PTD
         + bal_PYM_DBT_NRFI_PTD
         + bal_PYM_DBT_RFI_PTD
         + bal_RGT_AST_NRFI_PTD
         + bal_RGT_AST_RFI_PTD
         + bal_TA_NRFI_PTD
         + bal_TA_RFI_PTD
         + bal_TEL_ALL_NRFI_PTD
         + bal_TEL_ALL_RFI_PTD
         + bal_TOOL_ALL_NRFI_PTD
         + bal_TOOL_ALL_RFI_PTD
         + bal_TXB_INC_NRFI_PTD
         + bal_TXB_INC_RFI_PTD
         + bal_TXB_PEN_NRFI_PTD
         + bal_TXB_PEN_RFI_PTD
         + bal_USE_VEH_NRFI_PTD
         + bal_USE_VEH_RFI_PTD)* trc_SitFactor)
         + bal_AB_NRFI_PTD
         + bal_AB_RFI_PTD
         + bal_AC_NRFI_PTD
         + bal_AC_RFI_PTD
         + bal_ANU_FRM_RET_FND_NRFI_PTD
         + bal_ANU_FRM_RET_FND_RFI_PTD
         + bal_PRCH_ANU_TXB_NRFI_PTD
         + bal_PRCH_ANU_TXB_RFI_PTD
         + bal_TXB_AP_NRFI_PTD
         + bal_TXB_AP_RFI_PTD;

   -- Taxable Base Income
      trc_TxbBseInc := trc_BseErn - trc_AnnTotAbm;
   -- Threshold Check
      IF trc_TxbBseInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.LteCalc',13);
      -- Tax Liability
         trc_TotLibBse := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbBseInc);
      ELSE
         hr_utility.set_location('py_za_tx_01032000.LteCalc',14);
         trc_TotLibBse := 0;
      END IF;

   -- Populate the O Figure
      trc_OUpdFig := trc_TxbBseInc - bal_TOT_TXB_INC_ITD;

      -- Base Income
      py_za_tx_utl_01032000.WriteHrTrace('trc_BseErn: '||to_char(trc_BseErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBse: '||to_char(trc_TotLibBse));

   ELSE
      hr_utility.set_location('py_za_tx_01032000.LteCalc',15);
   -- Use the 'O' Figure as Base
   -- Set the Global
      trc_CalTyp := 'LteCalc';

   -- Get the assignment's previous tax year's
   --   threshold and rebate figures
      -- Employee Tax Year Start and End Dates
     SELECT MAX(ptp.end_date) "EndDate"
       INTO l_EndDate
       FROM per_time_periods ptp
      WHERE ptp.payroll_id = con_PRL_ID
        AND ptp.prd_information1 = trc_AsgTxYear
      GROUP BY ptp.prd_information1;

      hr_utility.set_location('py_za_tx_01032000.LteCalc',16);

   -- Global Values
      l_ZA_TX_YR_END        := l_EndDate;
      l_ZA_ADL_TX_RBT       := py_za_tx_utl_01032000.GlbVal('ZA_ADDITIONAL_TAX_REBATE',l_EndDate);
      l_ZA_PRI_TX_RBT       := py_za_tx_utl_01032000.GlbVal('ZA_PRIMARY_TAX_REBATE',l_EndDate);
      l_ZA_PRI_TX_THRSHLD   := py_za_tx_utl_01032000.GlbVal('ZA_PRIM_TAX_THRESHOLD',l_EndDate);
      l_ZA_SC_TX_THRSHLD    := py_za_tx_utl_01032000.GlbVal('ZA_SEC_TAX_THRESHOLD',l_EndDate);

   -- Calculate the assignments 65 Year Date
      l_65Year := add_months(dbi_PER_DTE_OF_BRTH,780);

      IF l_65Year <= l_ZA_TX_YR_END THEN
         hr_utility.set_location('py_za_tx_01032000.LteCalc',17);
      -- give the extra abatement
         trc_Rebate := l_ZA_PRI_TX_RBT + l_ZA_ADL_TX_RBT;
         trc_Threshold := l_ZA_SC_TX_THRSHLD;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.LteCalc',18);
      -- not eligable for extra abatement
         trc_Rebate := l_ZA_PRI_TX_RBT;
         trc_Threshold := l_ZA_PRI_TX_THRSHLD;
      END IF;


   -- Base Earnings
   --
      -- Take the OFigure as Taxable Base Income
      trc_TxbBseInc := bal_TOT_TXB_INC_ITD;
      -- Threshold Check
      IF trc_TxbBseInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.LteCalc',19);
      -- Tax Liability
         trc_TotLibBse := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbBseInc);
      ELSE
         hr_utility.set_location('py_za_tx_01032000.LteCalc',20);
         trc_TotLibBse := 0;
      END IF;

      -- Base Income
      py_za_tx_utl_01032000.WriteHrTrace('trc_BseErn: '||to_char(trc_BseErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBse: '||to_char(trc_TotLibBse));
   END IF;

-- Override the Global
   trc_CalTyp := 'LteCalc';
-- Set the SitFactor back to 1
   trc_SitFactor := 1;

   hr_utility.set_location('py_za_tx_01032000.LteCalc',21);

-- Rebates
   py_za_tx_utl_01032000.SetRebates;
-- Abatements
   py_za_tx_utl_01032000.Abatements;

   hr_utility.set_location('py_za_tx_01032000.LteCalc',22);

-- Update Global Balance Values with correct TAXABLE values
   py_za_tx_utl_01032000.TrvAll;

   bal_PO_RFI_YTD := bal_PO_RFI_YTD * glb_ZA_PBL_TX_PRC / 100;
   bal_PO_NRFI_YTD := bal_PO_NRFI_YTD * glb_ZA_PBL_TX_PRC / 100;

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
      hr_utility.set_location('py_za_tx_01032000.LteCalc',23);
   -- Normal Earnings
      trc_NorErn := trc_NorIncYtd + trc_TxbBseInc;
   -- Taxable Normal Income
      trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;
   -- Threshold Check
      IF trc_TxbNorInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.LteCalc',24);
      -- Tax Liability
         trc_TotLibNI := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbNorInc);
         trc_LibFyNI := trc_TotLibNI - least(trc_TotLibNI,trc_TotLibBse);
         trc_LibFpNI := trc_LibFyNI - bal_TX_ON_NI_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.LteCalc',25);
         trc_TotLibNI := 0;
      -- Refund any tax paid
         trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
         trc_NpValNIOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.LteCalc',26);
      trc_NorErn := trc_TxbBseInc;
      trc_TxbNorInc := 0;
      trc_TotLibNI := trc_TotLibBse;
   -- Refund any tax paid
      trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
      trc_NpValNIOvr := TRUE;
   END IF;

-- Fringe Benefits
--
   -- Ytd Fringe Benefits
   trc_FrnBenYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_YTD
      + bal_AST_PRCHD_RVAL_RFI_YTD
      + bal_BUR_AND_SCH_NRFI_YTD
      + bal_BUR_AND_SCH_RFI_YTD
      + bal_FREE_ACCOM_NRFI_YTD
      + bal_FREE_ACCOM_RFI_YTD
      + bal_FREE_SERV_NRFI_YTD
      + bal_FREE_SERV_RFI_YTD
      + bal_LOW_LOANS_NRFI_YTD
      + bal_LOW_LOANS_RFI_YTD
      + bal_MLS_AND_VOUCH_NRFI_YTD
      + bal_MLS_AND_VOUCH_RFI_YTD
      + bal_MED_PAID_NRFI_YTD
      + bal_MED_PAID_RFI_YTD
      + bal_PYM_DBT_NRFI_YTD
      + bal_PYM_DBT_RFI_YTD
      + bal_RGT_AST_NRFI_YTD
      + bal_RGT_AST_RFI_YTD
      + bal_USE_VEH_NRFI_YTD
      + bal_USE_VEH_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_FrnBenYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.LteCalc',27);
   -- Fringe Benefit Earnings
      trc_FrnBenErn := trc_FrnBenYtd + trc_NorErn;
   -- Taxable Fringe Income
      trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
   -- Threshold Check
      IF trc_TxbFrnInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.LteCalc',28);
      -- Tax Liability
         trc_TotLibFB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbFrnInc);
         trc_LibFyFB := trc_TotLibFB - least(trc_TotLibFB,trc_TotLibNI);
         trc_LibFpFB := trc_LibFyFB - bal_TX_ON_FB_YTD;
      ElSE
         hr_utility.set_location('py_za_tx_01032000.LteCalc',29);
         trc_TotLibFB := trc_TotLibNI;
      -- Refund any tax paid
         trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
         trc_NpValFBOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.LteCalc',30);
      trc_FrnBenErn := trc_NorErn;
      trc_TxbFrnInc := trc_TxbNorInc;
      trc_TotLibFB := trc_TotLibNI;
   -- Refund any tax paid
      trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
      trc_NpValFBOvr := TRUE;
   END IF;

-- Travel allowance
--
   -- Ytd Travel Allowance
   trc_TrvAllYtd :=
   ( bal_TA_NRFI_YTD
   + bal_TA_RFI_YTD
   );
   -- Skip the calculation if there is No Income
   IF trc_TrvAllYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.LteCalc',31);
   -- Travel Earnings
      trc_TrvAllErn := trc_TrvAllYtd + trc_FrnBenErn;
   -- Taxable Travel Income
      trc_TxbTrvInc := trc_TrvAllErn - trc_PerTotAbm;
   -- Threshold Check
      IF trc_TxbTrvInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.LteCalc',32);
      -- Tax Liability
         trc_TotLibTA := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbTrvInc);
         trc_LibFyTA := trc_TotLibTA - least(trc_TotLibTA,trc_TotLibFB);
         trc_LibFpTA := trc_LibFyTA - bal_TX_ON_TA_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.LteCalc',33);
         trc_TotLibTA := trc_TotLibFB;
      -- Refund any tax paid
         trc_LibFpTA := -1 * bal_TX_ON_TA_YTD;
         trc_NpValTAOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.LteCalc',34);
      trc_TrvAllErn := trc_FrnBenErn;
      trc_TxbTrvInc := trc_TxbFrnInc;
      trc_TotLibTA := trc_TotLibFB;
   -- Refund any tax paid
      trc_LibFpTA := -1 * bal_TX_ON_TA_YTD;
      trc_NpValTAOvr := TRUE;
   END IF;

-- Annual Bonus
--
   -- Ytd Annual Bonus
   trc_AnnBonYtd :=
   ( bal_AB_NRFI_YTD
   + bal_AB_RFI_YTD
   );
   -- Skip the calculation if there is No Income
   IF trc_AnnBonYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.LteCalc',35);
   -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
   -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
   -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.LteCalc',36);
      -- Tax Liability
         trc_TotLibAB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnBonInc);
         trc_LibFyAB := trc_TotLibAB - trc_TotLibTA;
      -- Negative Check
         IF trc_LibFyAB < 0 THEN
            hr_utility.set_location('py_za_tx_01032000.LteCalc',37);
            trc_TotLibAB := trc_TotLibTA;
         -- Refund any tax paid
            trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
            trc_NpValABOvr := TRUE;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.LteCalc',38);
            trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.LteCalc',39);
         trc_TotLibAB := trc_TotLibTA;
      -- Refund any tax paid
         trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
         trc_NpValABOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.LteCalc',40);
      trc_AnnBonErn := trc_TrvAllErn;
      trc_TxbAnnBonInc := trc_TxbTrvInc;
      trc_TotLibAB := trc_TotLibTA;
   -- Refund any tax paid
      trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
      trc_NpValABOvr := TRUE;
   END IF;

-- Annual Payments
--
   -- Ytd Annual Payments
   trc_AnnPymYtd :=
      ( bal_AC_NRFI_YTD
      + bal_AC_RFI_YTD
      + bal_ANU_FRM_RET_FND_NRFI_YTD
      + bal_ANU_FRM_RET_FND_RFI_YTD
      + bal_PRCH_ANU_TXB_NRFI_YTD
      + bal_PRCH_ANU_TXB_RFI_YTD
      + bal_TXB_AP_NRFI_YTD
      + bal_TXB_AP_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnPymYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.LteCalc',41);
   -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
   -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
   -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.LteCalc',42);
      -- Tax Liability
         trc_TotLibAP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnPymInc);
         trc_LibFyAP := trc_TotLibAP - trc_TotLibAB;
      -- Negative Check
         IF trc_LibFyAP < 0 THEN
            hr_utility.set_location('py_za_tx_01032000.LteCalc',43);
            trc_TotLibAP := trc_TotLibAB;
         -- Refund any tax paid
            trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
            trc_NpValAPOvr := TRUE;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.LteCalc',44);
            trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.LteCalc',45);
         trc_TotLibAP := trc_TotLibAB;
      -- Refund any tax paid
         trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
         trc_NpValAPOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.LteCalc',46);
      trc_AnnPymErn := trc_AnnBonErn;
      trc_TxbAnnPymInc := trc_TxbAnnBonInc;
      trc_TotLibAP := trc_TotLibAB;
   -- Refund any tax paid
      trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
      trc_NpValAPOvr := TRUE;
   END IF;

-- Public Office Allowance
--
   -- Ytd Public Office Allowance
   trc_PblOffYtd :=
      ( bal_PO_NRFI_YTD
      + bal_PO_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_PblOffYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.LteCalc',47);
   -- Public Office Earnings
      trc_PblOffErn := trc_PblOffYtd;
   -- Tax Liability
      trc_LibFyPO := trc_PblOffErn * glb_ZA_PBL_TX_RTE / 100;
      trc_LibFpPO := trc_LibFyPO -  bal_TX_ON_PO_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.LteCalc',48);
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
      hr_utility.set_location('py_za_tx_01032000.LteCalc',49);
      l_Sl := TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.LteCalc',50);
      l_Sl := FALSE;
   END IF;

   py_za_tx_utl_01032000.NpVal(p_Rf => l_Sl);

-- Set IT3A Indicator
--
   IF trc_TxbAnnPymInc + trc_PblOffErn >= trc_Threshold THEN
      hr_utility.set_location('py_za_tx_01032000.LteCalc',51);
      trc_It3Ind := 0; -- Over Lim
   ELSE
      hr_utility.set_location('py_za_tx_01032000.LteCalc',52);
      trc_It3Ind := 1; -- Under Lim
   END IF;

   -- Normal Income
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncYtd: '||to_char(trc_NorIncYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncPtd: '||to_char(trc_NorIncPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorErn: '||to_char(trc_NorErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbNorInc: '||to_char(trc_TxbNorInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibNI: '||to_char(trc_TotLibNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyNI: '||to_char(trc_LibFyNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpNI: '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenYtd: '||to_char(trc_FrnBenYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenPtd: '||to_char(trc_FrnBenPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenErn: '||to_char(trc_FrnBenErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbFrnInc: '||to_char(trc_TxbFrnInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibFB: '||to_char(trc_TotLibFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyFB: '||to_char(trc_LibFyFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpFB: '||to_char(trc_LibFpFB));
   -- Travel Allowance
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllYtd: '||to_char(trc_TrvAllYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllPtd: '||to_char(trc_TrvAllPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllErn: '||to_char(trc_TrvAllErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbTrvInc: '||to_char(trc_TxbTrvInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibTA: '||to_char(trc_TotLibTA));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyTA: '||to_char(trc_LibFyTA));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpTA: '||to_char(trc_LibFpTA));
   -- Annual Bonus
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonYtd: '||to_char(trc_AnnBonYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonPtd: '||to_char(trc_AnnBonPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonErn: '||to_char(trc_AnnBonErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAB: '||to_char(trc_TotLibAB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAB: '||to_char(trc_LibFyAB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAB: '||to_char(trc_LibFpAB));
   -- Annual Payments
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymYtd: '||to_char(trc_AnnPymYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymPtd: '||to_char(trc_AnnPymPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymErn: '||to_char(trc_AnnPymErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAP: '||to_char(trc_TotLibAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAP: '||to_char(trc_LibFyAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAP: '||to_char(trc_LibFpAP));
   -- Pubilc Office Allowance
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffYtd: '||to_char(trc_PblOffYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffPtd: '||to_char(trc_PblOffPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffErn: '||to_char(trc_PblOffErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyPO: '||to_char(trc_LibFyPO));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpPO: '||to_char(trc_LibFpPO));

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'LteCalc: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END LteCalc;


PROCEDURE SeaCalc AS
-- Variables
--
   l_Np       NUMBER(15,2) DEFAULT 0;
   l_65Year   DATE;

BEGIN
   hr_utility.set_location('py_za_tx_01032000.SeaCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'SeaCalc';

-- Period Type Income
--
   trc_TxbIncPtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_RUN
      + bal_AST_PRCHD_RVAL_RFI_RUN
      + bal_BUR_AND_SCH_NRFI_RUN
      + bal_BUR_AND_SCH_RFI_RUN
      + bal_COMM_NRFI_RUN
      + bal_COMM_RFI_RUN
      + bal_COMP_ALL_NRFI_RUN
      + bal_COMP_ALL_RFI_RUN
      + bal_ENT_ALL_NRFI_RUN
      + bal_ENT_ALL_RFI_RUN
      + bal_FREE_ACCOM_NRFI_RUN
      + bal_FREE_ACCOM_RFI_RUN
      + bal_FREE_SERV_NRFI_RUN
      + bal_FREE_SERV_RFI_RUN
      + bal_LOW_LOANS_NRFI_RUN
      + bal_LOW_LOANS_RFI_RUN
      + bal_MLS_AND_VOUCH_NRFI_RUN
      + bal_MLS_AND_VOUCH_RFI_RUN
      + bal_MED_PAID_NRFI_RUN
      + bal_MED_PAID_RFI_RUN
      + bal_OTHER_TXB_ALL_NRFI_RUN
      + bal_OTHER_TXB_ALL_RFI_RUN
      + bal_OVTM_NRFI_RUN
      + bal_OVTM_RFI_RUN
      + bal_PYM_DBT_NRFI_RUN
      + bal_PYM_DBT_RFI_RUN
      + bal_RGT_AST_NRFI_RUN
      + bal_RGT_AST_RFI_RUN
      + bal_TXB_INC_NRFI_RUN
      + bal_TXB_INC_RFI_RUN
      + bal_TXB_PEN_NRFI_RUN
      + bal_TXB_PEN_RFI_RUN
      + bal_TEL_ALL_NRFI_RUN
      + bal_TEL_ALL_RFI_RUN
      + bal_TOOL_ALL_NRFI_RUN
      + bal_TOOL_ALL_RFI_RUN
      + bal_USE_VEH_NRFI_RUN
      + bal_USE_VEH_RFI_RUN
      );

-- Check if any Period Income Exists
--
   hr_utility.set_location('py_za_tx_01032000.SeaCalc',2);
   IF trc_TxbIncPtd = 0 THEN -- Pre-Earnings Calc
      hr_utility.set_location('py_za_tx_01032000.SeaCalc',3);
   -- Site Factor
   --
      trc_SitFactor := glb_ZA_WRK_DYS_PR_YR / dbi_SEA_WRK_DYS_WRK;

   -- Tax Rebates, Threshold Figure and Medical Aid
   -- Abatements
      -- Calculate the assignments 65 Year Date
      l_65Year := add_months(dbi_PER_DTE_OF_BRTH,780);

      IF l_65Year BETWEEN dbi_ZA_TX_YR_STRT AND dbi_ZA_TX_YR_END THEN
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',4);
      -- give the extra abatement
         trc_Rebate := glb_ZA_PRI_TX_RBT + glb_ZA_ADL_TX_RBT;
         trc_Threshold := glb_ZA_SC_TX_THRSHLD;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',5);
      -- not eligable for extra abatement
         trc_Rebate := glb_ZA_PRI_TX_RBT;
         trc_Threshold := glb_ZA_PRI_TX_THRSHLD;
      END IF;

   -- Base Income
   --
      -- Base Income
      trc_BseErn :=
         ( bal_AC_NRFI_RUN
         + bal_AC_RFI_RUN
         + bal_ANU_FRM_RET_FND_NRFI_RUN
         + bal_ANU_FRM_RET_FND_RFI_RUN
         + bal_PRCH_ANU_TXB_NRFI_RUN
         + bal_PRCH_ANU_TXB_RFI_RUN
         + bal_TXB_AP_NRFI_RUN
         + bal_TXB_AP_RFI_RUN
         );
      -- Taxable Base Income
      trc_TxbBseInc := trc_BseErn * trc_SitFactor;
      -- Threshold Check
      IF trc_TxbBseInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',6);
      -- Tax Liability
         trc_TotLibBse := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbBseInc);
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',7);
         trc_TotLibBse := 0;
      END IF;

   -- Annual Payments
   --
      -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_BseErn + trc_TxbBseInc;-- AP was taken as base!
      -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',8);
      -- Tax Liability
         trc_TotLibAP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnPymInc);
         trc_LibFpAP := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibBse);
      ElSE
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',9);
         trc_LibFpAP := 0;
      END IF;

      -- Base Income
      py_za_tx_utl_01032000.WriteHrTrace('trc_BseErn: '||to_char(trc_BseErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBse: '||to_char(trc_TotLibBse));

      -- Annual Payments
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymYtd: '||to_char(trc_AnnPymYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymPtd: '||to_char(trc_AnnPymPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymErn: '||to_char(trc_AnnPymErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAP: '||to_char(trc_TotLibAP));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAP: '||to_char(trc_LibFyAP));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAP: '||to_char(trc_LibFpAP));


   ELSE
      hr_utility.set_location('py_za_tx_01032000.SeaCalc',10);
   -- Site Factor
   --
      trc_SitFactor := glb_ZA_WRK_DYS_PR_YR / dbi_SEA_WRK_DYS_WRK;

   -- Rebates
      py_za_tx_utl_01032000.SetRebates;

   -- Abatements
      py_za_tx_utl_01032000.Abatements;

   hr_utility.set_location('py_za_tx_01032000.SeaCalc',11);

   -- Normal Income
   --
      -- Run Normal Income
      trc_NorIncPtd :=
         (bal_COMM_NRFI_RUN
         + bal_COMM_RFI_RUN
         + bal_COMP_ALL_NRFI_RUN
         + bal_COMP_ALL_RFI_RUN
         + bal_ENT_ALL_NRFI_RUN
         + bal_ENT_ALL_RFI_RUN
         + bal_OTHER_TXB_ALL_NRFI_RUN
         + bal_OTHER_TXB_ALL_RFI_RUN
         + bal_OVTM_NRFI_RUN
         + bal_OVTM_RFI_RUN
         + bal_TXB_INC_NRFI_RUN
         + bal_TXB_INC_RFI_RUN
         + bal_TXB_PEN_NRFI_RUN
         + bal_TXB_PEN_RFI_RUN
         + bal_TEL_ALL_NRFI_RUN
         + bal_TEL_ALL_RFI_RUN
         + bal_TOOL_ALL_NRFI_RUN
         + bal_TOOL_ALL_RFI_RUN
         );
      -- Skip the calculation if there is No Income
      IF trc_NorIncPtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',12);
      -- Normal Earnings
         trc_NorErn := trc_NorIncPtd * trc_SitFactor;
      -- Taxable Normal Income
         trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;
      -- Threshold Check
         IF trc_TxbNorInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032000.SeaCalc',13);
         -- Tax Liability
            trc_TotLibNI := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbNorInc);
            trc_LibFyNI := trc_TotLibNI - 0;
            trc_LibFpNI := trc_LibFyNI / trc_SitFactor;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.SeaCalc',14);
            trc_TotLibNI := 0;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',15);
         trc_NorErn := 0;
         trc_TxbNorInc := 0;
         trc_TotLibNI := 0;
      END IF;

   -- Fringe Benefits
   --
      -- Run Fringe Benefits
      trc_FrnBenPtd :=
         ( bal_AST_PRCHD_RVAL_NRFI_RUN
         + bal_AST_PRCHD_RVAL_RFI_RUN
         + bal_BUR_AND_SCH_NRFI_RUN
         + bal_BUR_AND_SCH_RFI_RUN
         + bal_FREE_ACCOM_NRFI_RUN
         + bal_FREE_ACCOM_RFI_RUN
         + bal_FREE_SERV_NRFI_RUN
         + bal_FREE_SERV_RFI_RUN
         + bal_LOW_LOANS_NRFI_RUN
         + bal_LOW_LOANS_RFI_RUN
         + bal_MLS_AND_VOUCH_NRFI_RUN
         + bal_MLS_AND_VOUCH_RFI_RUN
         + bal_MED_PAID_NRFI_RUN
         + bal_MED_PAID_RFI_RUN
         + bal_PYM_DBT_NRFI_RUN
         + bal_PYM_DBT_RFI_RUN
         + bal_RGT_AST_NRFI_RUN
         + bal_RGT_AST_RFI_RUN
         + bal_USE_VEH_NRFI_RUN
         + bal_USE_VEH_RFI_RUN
         );

      -- Skip the calculation if there is No Income
      IF trc_FrnBenPtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',16);
      -- Fringe Benefit Earnings
         trc_FrnBenErn := trc_FrnBenPtd * trc_SitFactor + trc_NorErn;
      -- Taxable Fringe Income
         trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
      -- Threshold Check
         IF trc_TxbFrnInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032000.SeaCalc',17);
         -- Tax Liability
            trc_TotLibFB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbFrnInc);
            trc_LibFyFB := trc_TotLibFB - least(trc_TotLibFB,trc_TotLibNI);
            trc_LibFpFB := trc_LibFyFB / trc_SitFactor;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.SeaCalc',18);
            trc_TotLibFB := trc_TotLibNI;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',19);
         trc_FrnBenErn := trc_NorErn;
         trc_TxbFrnInc := trc_TxbNorInc;
         trc_TotLibFB := trc_TotLibNI;
      END IF;

   -- Annual Payments
   --
      -- Run Annual Payments
      trc_AnnPymPtd :=
         ( bal_AC_NRFI_RUN
         + bal_AC_RFI_RUN
         + bal_ANU_FRM_RET_FND_NRFI_RUN
         + bal_ANU_FRM_RET_FND_RFI_RUN
         + bal_PRCH_ANU_TXB_NRFI_RUN
         + bal_PRCH_ANU_TXB_RFI_RUN
         + bal_TXB_AP_NRFI_RUN
         + bal_TXB_AP_RFI_RUN
         );
      -- Skip the calculation if there is No Income
      IF trc_AnnPymPtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',20);
      -- Annual Payments Earnings
         trc_AnnPymErn := trc_AnnPymPtd + trc_FrnBenErn;
      -- Taxable Annual Payments Income
         trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
         IF trc_TxbAnnPymInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032000.SeaCalc',21);
         -- Tax Liability
            trc_TotLibAP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnPymInc);
            trc_LibFyAP := trc_TotLibAP - trc_TotLibFB;
         -- Negative Check
            IF trc_LibFyAP < 0 THEN
               hr_utility.set_location('py_za_tx_01032000.SeaCalc',22);
               trc_TotLibAP := trc_TotLibFB;
            -- Refund any tax paid
               trc_LibFpAP := 0;
            ELSE
               hr_utility.set_location('py_za_tx_01032000.SeaCalc',23);
               trc_LibFpAP := trc_LibFyAP;
            END IF;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.SeaCalc',24);
            trc_TotLibAP := trc_TotLibFB;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',25);
         trc_AnnPymErn := trc_FrnBenErn;
         trc_TxbAnnPymInc := trc_TxbFrnInc;
         trc_TotLibAP := trc_TotLibFB;
      END IF;


   -- Net Pay Validation
   --
      py_za_tx_utl_01032000.NpVal;

   hr_utility.set_location('py_za_tx_01032000.SeaCalc',26);

   -- Set IT3A Indicator
   --
      IF trc_TxbAnnPymInc + trc_PblOffErn >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',27);
         trc_It3Ind := 0; -- Over Lim
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SeaCalc',28);
         trc_It3Ind := 1; -- Under Lim
      END IF;
   END IF;

   -- Normal Income
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncYtd: '||to_char(trc_NorIncYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncPtd: '||to_char(trc_NorIncPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorErn: '||to_char(trc_NorErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbNorInc: '||to_char(trc_TxbNorInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibNI: '||to_char(trc_TotLibNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyNI: '||to_char(trc_LibFyNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpNI: '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenYtd: '||to_char(trc_FrnBenYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenPtd: '||to_char(trc_FrnBenPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenErn: '||to_char(trc_FrnBenErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbFrnInc: '||to_char(trc_TxbFrnInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibFB: '||to_char(trc_TotLibFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyFB: '||to_char(trc_LibFyFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpFB: '||to_char(trc_LibFpFB));
   -- Annual Payments
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymYtd: '||to_char(trc_AnnPymYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymPtd: '||to_char(trc_AnnPymPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymErn: '||to_char(trc_AnnPymErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAP: '||to_char(trc_TotLibAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAP: '||to_char(trc_LibFyAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAP: '||to_char(trc_LibFpAP));

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
   l_Sl       BOOLEAN;
   l_Np       NUMBER(15,2);

BEGIN
   hr_utility.set_location('py_za_tx_01032000.SitCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'SitCalc';

-- Update Global Balance Values with correct TAXABLE values
--
   py_za_tx_utl_01032000.TrvAll;

   hr_utility.set_location('py_za_tx_01032000.SitCalc',2);

   bal_PO_RFI_YTD :=
   bal_PO_RFI_YTD * glb_ZA_PBL_TX_PRC / 100;

   bal_PO_NRFI_YTD :=
   bal_PO_NRFI_YTD * glb_ZA_PBL_TX_PRC / 100;

-- Ytd Taxable Income
--
   trc_TxbIncYtd :=
   ( bal_AST_PRCHD_RVAL_NRFI_YTD
   + bal_AST_PRCHD_RVAL_RFI_YTD
   + bal_BP_YTD
   + bal_BUR_AND_SCH_NRFI_YTD
   + bal_BUR_AND_SCH_RFI_YTD
   + bal_COMM_NRFI_YTD
   + bal_COMM_RFI_YTD
   + bal_COMP_ALL_NRFI_YTD
   + bal_COMP_ALL_RFI_YTD
   + bal_ENT_ALL_NRFI_YTD
   + bal_ENT_ALL_RFI_YTD
   + bal_FREE_ACCOM_NRFI_YTD
   + bal_FREE_ACCOM_RFI_YTD
   + bal_FREE_SERV_NRFI_YTD
   + bal_FREE_SERV_RFI_YTD
   + bal_LOW_LOANS_NRFI_YTD
   + bal_LOW_LOANS_RFI_YTD
   + bal_MLS_AND_VOUCH_NRFI_YTD
   + bal_MLS_AND_VOUCH_RFI_YTD
   + bal_MED_PAID_NRFI_YTD
   + bal_MED_PAID_RFI_YTD
   + bal_OTHER_TXB_ALL_NRFI_YTD
   + bal_OTHER_TXB_ALL_RFI_YTD
   + bal_OVTM_NRFI_YTD
   + bal_OVTM_RFI_YTD
   + bal_PYM_DBT_NRFI_YTD
   + bal_PYM_DBT_RFI_YTD
   + bal_RGT_AST_NRFI_YTD
   + bal_RGT_AST_RFI_YTD
   + bal_TXB_INC_NRFI_YTD
   + bal_TXB_INC_RFI_YTD
   + bal_TXB_PEN_NRFI_YTD
   + bal_TXB_PEN_RFI_YTD
   + bal_TEL_ALL_NRFI_YTD
   + bal_TEL_ALL_RFI_YTD
   + bal_TOOL_ALL_NRFI_YTD
   + bal_TOOL_ALL_RFI_YTD
   + bal_TA_NRFI_YTD
   + bal_TA_RFI_YTD
   + bal_USE_VEH_NRFI_YTD
   + bal_USE_VEH_RFI_YTD
   );

   hr_utility.set_location('py_za_tx_01032000.SitCalc',3);

-- Site Factor
--
   trc_SitFactor := dbi_ZA_DYS_IN_YR / py_za_tx_utl_01032000.DaysWorked;

   hr_utility.set_location('py_za_tx_01032000.SitCalc',4);

-- Rebates
   py_za_tx_utl_01032000.SetRebates;

-- Abatements
   py_za_tx_utl_01032000.Abatements;

   hr_utility.set_location('py_za_tx_01032000.SitCalc',5);

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
      hr_utility.set_location('py_za_tx_01032000.SitCalc',6);
   -- Normal Earnings
      trc_NorErn := trc_NorIncYtd * trc_SitFactor;
   -- Taxable Normal Income
      trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;
   -- Threshold Check
      IF trc_TxbNorInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.SitCalc',7);
      -- Tax Liability
         trc_TotLibNI := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbNorInc);
         trc_LibFyNI := (trc_TotLibNI - 0) / trc_SitFactor;
         trc_LibFpNI := trc_LibFyNI - bal_TX_ON_NI_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SitCalc',8);
         trc_TotLibNI := 0;
      -- Refund any tax paid
         trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
         trc_NpValNIOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.SitCalc',9);
      trc_NorErn := 0;
      trc_TxbNorInc := 0;
      trc_TotLibNI := 0;
   -- Refund any tax paid
      trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
      trc_NpValNIOvr := TRUE;
   END IF;

-- Fringe Benefits
--
   -- Ytd Fringe Benefits
   trc_FrnBenYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_YTD
      + bal_AST_PRCHD_RVAL_RFI_YTD
      + bal_BUR_AND_SCH_NRFI_YTD
      + bal_BUR_AND_SCH_RFI_YTD
      + bal_FREE_ACCOM_NRFI_YTD
      + bal_FREE_ACCOM_RFI_YTD
      + bal_FREE_SERV_NRFI_YTD
      + bal_FREE_SERV_RFI_YTD
      + bal_LOW_LOANS_NRFI_YTD
      + bal_LOW_LOANS_RFI_YTD
      + bal_MLS_AND_VOUCH_NRFI_YTD
      + bal_MLS_AND_VOUCH_RFI_YTD
      + bal_MED_PAID_NRFI_YTD
      + bal_MED_PAID_RFI_YTD
      + bal_PYM_DBT_NRFI_YTD
      + bal_PYM_DBT_RFI_YTD
      + bal_RGT_AST_NRFI_YTD
      + bal_RGT_AST_RFI_YTD
      + bal_USE_VEH_NRFI_YTD
      + bal_USE_VEH_RFI_YTD
      );

   -- Skip the calculation if there is No Income
   IF trc_FrnBenYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.SitCalc',10);
   -- Fringe Benefit Earnings
      trc_FrnBenErn := trc_FrnBenYtd * trc_SitFactor + trc_NorErn;
   -- Taxable Fringe Income
      trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
   -- Threshold Check
      IF trc_TxbFrnInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.SitCalc',11);
      -- Tax Liability
         trc_TotLibFB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbFrnInc);
         trc_LibFyFB := (trc_TotLibFB - least(trc_TotLibFB,trc_TotLibNI)) / trc_SitFactor;
         trc_LibFpFB := trc_LibFyFB - bal_TX_ON_FB_YTD;
      ElSE
         hr_utility.set_location('py_za_tx_01032000.SitCalc',12);
         trc_TotLibFB := trc_TotLibNI;
      -- Refund any tax paid
         trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
         trc_NpValFBOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.SitCalc',13);
      trc_FrnBenErn := trc_NorErn;
      trc_TxbFrnInc := trc_TxbNorInc;
      trc_TotLibFB := trc_TotLibNI;
   -- Refund any tax paid
      trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
      trc_NpValFBOvr := TRUE;
   END IF;

-- Travel allowance
--
   -- Ytd Travel Allowance
   trc_TrvAllYtd :=
      ( bal_TA_NRFI_YTD
      + bal_TA_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_TrvAllYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.SitCalc',14);
   -- Travel Earnings
      trc_TrvAllErn := trc_TrvAllYtd * trc_SitFactor + trc_FrnBenErn;
   -- Taxable Travel Income
      trc_TxbTrvInc := trc_TrvAllErn - trc_PerTotAbm;
   -- Threshold Check
      IF trc_TxbTrvInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.SitCalc',15);
      -- Tax Liability
         trc_TotLibTA := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbTrvInc);
         trc_LibFyTA := (trc_TotLibTA - least(trc_TotLibTA,trc_TotLibFB)) / trc_SitFactor;
         trc_LibFpTA := trc_LibFyTA - bal_TX_ON_TA_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SitCalc',16);
         trc_TotLibTA := trc_TotLibFB;
      -- Refund any tax paid
         trc_LibFpTA := -1 * bal_TX_ON_TA_YTD;
         trc_NpValTAOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.SitCalc',17);
      trc_TrvAllErn := trc_FrnBenErn;
      trc_TxbTrvInc := trc_TxbFrnInc;
      trc_TotLibTA := trc_TotLibFB;
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
      hr_utility.set_location('py_za_tx_01032000.SitCalc',18);
   -- Bonus Provision Earnings
      trc_BonProErn := trc_BonProYtd * trc_SitFactor + trc_TrvAllErn;
   -- Taxable Bonus Provision Income
      trc_TxbBonProInc := trc_BonProErn - trc_PerTotAbm;
   -- Threshold Check
      IF trc_TxbBonProInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.SitCalc',19);
      -- Tax Liability
         trc_TotLibBP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbBonProInc);
         trc_LibFyBP := (trc_TotLibBP - least(trc_TotLibBP,trc_TotLibTA)) / trc_SitFactor;
         trc_LibFpBP := trc_LibFyBP - bal_TX_ON_BP_YTD;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SitCalc',20);
         trc_TotLibBP := trc_TotLibTA;
      -- Refund any tax paid
         trc_LibFpBP := -1 * bal_TX_ON_BP_YTD;
         trc_NpValBPOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.SitCalc',21);
      trc_BonProErn := trc_TrvAllErn;
      trc_TxbBonProInc := trc_TxbTrvInc;
      trc_TotLibBP := trc_TotLibTA;
   -- Refund any tax paid
      trc_LibFpBP := -1 * bal_TX_ON_BP_YTD;
      trc_NpValBPOvr := TRUE;
   END IF;

-- Annual Bonus
--
   -- Ytd Annual Bonus
   trc_AnnBonYtd :=
      ( bal_AB_NRFI_YTD
      + bal_AB_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnBonYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.SitCalc',22);
   -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
   -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
   -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.SitCalc',23);
      -- Tax Liability
         trc_TotLibAB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnBonInc);
         trc_LibFyAB := trc_TotLibAB - trc_TotLibTA;
      -- Negative Check
         IF trc_LibFyAB < 0 THEN
            hr_utility.set_location('py_za_tx_01032000.SitCalc',24);
            trc_TotLibAB := trc_TotLibTA;
         -- Refund any tax paid
            trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
            trc_NpValABOvr := TRUE;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.SitCalc',25);
         -- Check Bonus Provision
            IF trc_BonProYtd <> 0 THEN
               hr_utility.set_location('py_za_tx_01032000.SitCalc',26);
               trc_LibFpAB := trc_LibFyAB - (bal_TX_ON_BP_YTD
                                            + trc_LibFpBP
                                            + bal_TX_ON_AB_YTD
                                            );
            ELSE
               hr_utility.set_location('py_za_tx_01032000.SitCalc',27);
               trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
            END IF;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SitCalc',28);
         trc_TotLibAB := trc_TotLibTA;
      -- Refund any tax paid
         trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
         trc_NpValABOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.SitCalc',29);
      trc_AnnBonErn := trc_TrvAllErn;
      trc_TxbAnnBonInc := trc_TxbTrvInc;
      trc_TotLibAB := trc_TotLibTA;
   -- Refund any tax paid
      trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
      trc_NpValABOvr := TRUE;
   END IF;

-- Annual Payments
--
   -- Ytd Annual Payments
   trc_AnnPymYtd :=
      ( bal_AC_NRFI_YTD
      + bal_AC_RFI_YTD
      + bal_ANU_FRM_RET_FND_NRFI_YTD
      + bal_ANU_FRM_RET_FND_RFI_YTD
      + bal_PRCH_ANU_TXB_NRFI_YTD
      + bal_PRCH_ANU_TXB_RFI_YTD
      + bal_TXB_AP_NRFI_YTD
      + bal_TXB_AP_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnPymYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.SitCalc',30);
   -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
   -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
   -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.SitCalc',31);
      -- Tax Liability
         trc_TotLibAP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnPymInc);
         trc_LibFyAP := trc_TotLibAP - trc_TotLibAB;
      -- Negative Check
         IF trc_LibFyAP < 0 THEN
            hr_utility.set_location('py_za_tx_01032000.SitCalc',32);
            trc_TotLibAP := trc_TotLibAB;
         -- Refund any tax paid
            trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
            trc_NpValAPOvr := TRUE;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.SitCalc',33);
            trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.SitCalc',34);
         trc_TotLibAP := trc_TotLibAB;
      -- Refund any tax paid
         trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
         trc_NpValAPOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.SitCalc',35);
      trc_AnnPymErn := trc_AnnBonErn;
      trc_TxbAnnPymInc := trc_TxbAnnBonInc;
      trc_TotLibAP := trc_TotLibAB;
   -- Refund any tax paid
      trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
      trc_NpValAPOvr := TRUE;
   END IF;

-- Public Office Allowance
--
   -- Ytd Public Office Allowance
   trc_PblOffYtd :=
      ( bal_PO_NRFI_YTD
      + bal_PO_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_PblOffYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.SitCalc',36);
   -- Public Office Earnings
      trc_PblOffErn := trc_PblOffYtd * trc_SitFactor;
   -- Tax Liability
      trc_LibFyPO := (trc_PblOffErn * glb_ZA_PBL_TX_RTE / 100)/trc_SitFactor;
      trc_LibFpPO := trc_LibFyPO -  bal_TX_ON_PO_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.SitCalc',37);
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
      hr_utility.set_location('py_za_tx_01032000.SitCalc',38);
      l_Sl := TRUE;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.SitCalc',39);
      l_Sl := FALSE;
   END IF;

   py_za_tx_utl_01032000.NpVal(p_Rf => l_Sl);

   hr_utility.set_location('py_za_tx_01032000.SitCalc',40);

-- Set IT3A Indicator
--
   IF trc_TxbAnnPymInc + trc_PblOffErn >= trc_Threshold THEN
      hr_utility.set_location('py_za_tx_01032000.SitCalc',41);
      trc_It3Ind := 0; -- Over Lim
   ELSE
      hr_utility.set_location('py_za_tx_01032000.SitCalc',42);
      trc_It3Ind := 1; -- Under Lim
   END IF;

-- Calculate Total Taxable Income and pass out
--
   trc_OUpdFig := (trc_TxbAnnPymInc + trc_PblOffErn) - bal_TOT_TXB_INC_ITD;

   hr_utility.set_location('py_za_tx_01032000.SitCalc',43);

   -- Base Income
   py_za_tx_utl_01032000.WriteHrTrace('trc_BseErn: '||to_char(trc_BseErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBse: '||to_char(trc_TotLibBse));
   -- Normal Income
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncYtd: '||to_char(trc_NorIncYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncPtd: '||to_char(trc_NorIncPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorErn: '||to_char(trc_NorErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbNorInc: '||to_char(trc_TxbNorInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibNI: '||to_char(trc_TotLibNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyNI: '||to_char(trc_LibFyNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpNI: '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenYtd: '||to_char(trc_FrnBenYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenPtd: '||to_char(trc_FrnBenPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenErn: '||to_char(trc_FrnBenErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbFrnInc: '||to_char(trc_TxbFrnInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibFB: '||to_char(trc_TotLibFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyFB: '||to_char(trc_LibFyFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpFB: '||to_char(trc_LibFpFB));
   -- Travel Allowance
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllYtd: '||to_char(trc_TrvAllYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllPtd: '||to_char(trc_TrvAllPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllErn: '||to_char(trc_TrvAllErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbTrvInc: '||to_char(trc_TxbTrvInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibTA: '||to_char(trc_TotLibTA));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyTA: '||to_char(trc_LibFyTA));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpTA: '||to_char(trc_LibFpTA));
   -- Bonus Provision
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProYtd: '||to_char(trc_BonProYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProPtd: '||to_char(trc_BonProPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProErn: '||to_char(trc_BonProErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBP: '||to_char(trc_TotLibBP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyBP: '||to_char(trc_LibFyBP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpBP: '||to_char(trc_LibFpBP));
   -- Annual Bonus
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonYtd: '||to_char(trc_AnnBonYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonPtd: '||to_char(trc_AnnBonPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonErn: '||to_char(trc_AnnBonErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAB: '||to_char(trc_TotLibAB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAB: '||to_char(trc_LibFyAB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAB: '||to_char(trc_LibFpAB));
   -- Annual Payments
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymYtd: '||to_char(trc_AnnPymYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymPtd: '||to_char(trc_AnnPymPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymErn: '||to_char(trc_AnnPymErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAP: '||to_char(trc_TotLibAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAP: '||to_char(trc_LibFyAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAP: '||to_char(trc_LibFpAP));

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
   l_Np       NUMBER(15,2) DEFAULT 0;

BEGIN
   hr_utility.set_location('py_za_tx_01032000.DirCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'DirCalc';

-- Update Global Balance Values with correct TAXABLE values
--
   py_za_tx_utl_01032000.TrvAll;

   hr_utility.set_location('py_za_tx_01032000.DirCalc',2);

   bal_PO_RFI_YTD :=
   bal_PO_RFI_YTD * glb_ZA_PBL_TX_PRC / 100;

   bal_PO_NRFI_YTD :=
   bal_PO_NRFI_YTD * glb_ZA_PBL_TX_PRC / 100;

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
      hr_utility.set_location('py_za_tx_01032000.DirCalc',3);
   -- Normal Earnings
      trc_NorErn := trc_NorIncYtd;
   -- Tax Liability
      trc_TotLibNI := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_NorErn);
      trc_LibFyNI := trc_TotLibNI - 0;
      trc_LibFpNI := trc_LibFyNI - bal_TX_ON_NI_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.DirCalc',4);
      trc_NorErn := 0;
      trc_TotLibNI := 0;
   -- Refund any tax paid
      trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
      trc_NpValNIOvr := TRUE;
   END IF;

-- Fringe Benefits
--
   -- Ytd Fringe Benefits
   trc_FrnBenYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_YTD
      + bal_AST_PRCHD_RVAL_RFI_YTD
      + bal_BUR_AND_SCH_NRFI_YTD
      + bal_BUR_AND_SCH_RFI_YTD
      + bal_FREE_ACCOM_NRFI_YTD
      + bal_FREE_ACCOM_RFI_YTD
      + bal_FREE_SERV_NRFI_YTD
      + bal_FREE_SERV_RFI_YTD
      + bal_LOW_LOANS_NRFI_YTD
      + bal_LOW_LOANS_RFI_YTD
      + bal_MLS_AND_VOUCH_NRFI_YTD
      + bal_MLS_AND_VOUCH_RFI_YTD
      + bal_MED_PAID_NRFI_YTD
      + bal_MED_PAID_RFI_YTD
      + bal_PYM_DBT_NRFI_YTD
      + bal_PYM_DBT_RFI_YTD
      + bal_RGT_AST_NRFI_YTD
      + bal_RGT_AST_RFI_YTD
      + bal_USE_VEH_NRFI_YTD
      + bal_USE_VEH_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_FrnBenYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.DirCalc',5);
   -- Fringe Benefit Earnings
      trc_FrnBenErn := trc_FrnBenYtd + trc_NorErn;
   -- Tax Liability
      trc_TotLibFB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_FrnBenErn);
      trc_LibFyFB := trc_TotLibFB - least(trc_TotLibFB,trc_TotLibNI);
      trc_LibFpFB := trc_LibFyFB - bal_TX_ON_FB_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.DirCalc',6);
      trc_FrnBenErn := trc_NorErn;
      trc_TotLibFB := trc_TotLibNI;
   -- Refund any tax paid
      trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
      trc_NpValFBOvr := TRUE;
   END IF;

-- Travel Allowance
--
   -- Ytd Travel Allowance
   trc_TrvAllYtd :=
      ( bal_TA_NRFI_YTD
      + bal_TA_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_TrvAllYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.DirCalc',7);
   -- Travel Allowance Earnings
      trc_TrvAllErn := trc_TrvAllYtd + trc_FrnBenErn;
   -- Tax Liability
      trc_TotLibTA := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TrvAllErn);
      trc_LibFyTA := trc_TotLibTA - least(trc_TotLibTA,trc_TotLibFB);
      trc_LibFpTA := trc_LibFyTA - bal_TX_ON_TA_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.DirCalc',8);
      trc_TrvAllErn := trc_FrnBenErn; --Cascade Figure
      trc_TotLibTA := trc_TotLibFB;
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
      hr_utility.set_location('py_za_tx_01032000.DirCalc',9);
   -- Bonus Provision Earnings
      trc_BonProErn := trc_BonProYtd + trc_TrvAllErn;
   -- Tax Liability
      trc_TotLibBP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_BonProErn);
      trc_LibFyBP := trc_TotLibBP - least(trc_TotLibBP,trc_TotLibTA);
      trc_LibFpBP := trc_LibFyBP - bal_TX_ON_BP_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.DirCalc',10);
      trc_BonProErn := trc_TrvAllErn;
      trc_TotLibBP := trc_TotLibTA;
   -- Refund any tax paid
      trc_LibFpBP := -1 * bal_TX_ON_BP_YTD;
      trc_NpValBPOvr := TRUE;
   END IF;

-- Annual Bonus
--
   -- Ytd Annual Bonus
   trc_AnnBonYtd :=
      ( bal_AB_NRFI_YTD
      + bal_AB_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnBonYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.DirCalc',11);
   -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
   -- Tax Liability
      trc_TotLibAB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_AnnBonErn);
      trc_LibFyAB := trc_TotLibAB - least(trc_TotLibAB,trc_TotLibTA);
   -- Check Bonus Provision
      IF trc_BonProYtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032000.DirCalc',12);
      -- Check Bonus Provision Frequency
         IF dbi_BP_TX_RCV = 'A' THEN
            hr_utility.set_location('py_za_tx_01032000.DirCalc',13);
            trc_LibFpAB := 0;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.DirCalc',14);
            trc_LibFpAB :=
            trc_LibFyAB - (bal_TX_ON_BP_YTD
                          + trc_LibFpBP
                          + bal_TX_ON_AB_YTD);
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.DirCalc',15);
         trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.DirCalc',16);
      trc_AnnBonErn := trc_TrvAllErn;
      trc_TotLibAB := trc_TotLibTA;
   -- Refund any tax paid
      trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
      trc_NpValABOvr := TRUE;
   END IF;

-- Annual Payments
--
   -- Ytd Annual Payments
   trc_AnnPymYtd :=
      ( bal_AC_NRFI_YTD
      + bal_AC_RFI_YTD
      + bal_ANU_FRM_RET_FND_NRFI_YTD
      + bal_ANU_FRM_RET_FND_RFI_YTD
      + bal_PRCH_ANU_TXB_NRFI_YTD
      + bal_PRCH_ANU_TXB_RFI_YTD
      + bal_TXB_AP_NRFI_YTD
      + bal_TXB_AP_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnPymYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.DirCalc',17);
   -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
   -- Tax Liability
      trc_TotLibAP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_AnnPymErn);
      trc_LibFyAP := trc_TotLibAP - least(trc_TotLibAP,trc_TotLibAB);
      trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
   ElSE
      hr_utility.set_location('py_za_tx_01032000.DirCalc',18);
      trc_AnnPymErn := trc_AnnBonErn;
      trc_TotLibAP := trc_TotLibAB;
   -- Refund any tax paid
      trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
      trc_NpValAPOvr := TRUE;
   END IF;

-- Public Office Allowance
--
   -- Ytd Public Office Allowance
   trc_PblOffYtd :=
      ( bal_PO_NRFI_YTD
      + bal_PO_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_PblOffYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.DirCalc',19);
   -- Tax Liability
      trc_LibFyPO := trc_PblOffYtd * glb_ZA_PBL_TX_RTE / 100;
      trc_LibFpPO := trc_LibFyPO -  bal_TX_ON_PO_YTD;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.DirCalc',20);
      trc_LibFyPO := 0;
   -- Refund any tax paid
      trc_LibFpPO := -1 * bal_TX_ON_PO_YTD;
      trc_NpValPOOvr := TRUE;
   END IF;

-- Net Pay Validation
--
   py_za_tx_utl_01032000.NpVal(p_Rf => TRUE);

   hr_utility.set_location('py_za_tx_01032000.DirCalc',21);

-- Tax Percentage Indicator
--
   IF dbi_TX_STA = 'D' THEN
      hr_utility.set_location('py_za_tx_01032000.DirCalc',22);
      trc_TxPercVal := dbi_TX_DIR_VAL;
   ELSIF dbi_TX_STA = 'E' THEN
      hr_utility.set_location('py_za_tx_01032000.DirCalc',23);
      trc_TxPercVal := glb_ZA_CC_TX_PRC;
   ELSIF dbi_TX_STA = 'F' THEN
      hr_utility.set_location('py_za_tx_01032000.DirCalc',24);
      trc_TxPercVal := glb_ZA_TMP_TX_RTE;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.DirCalc',25);
      trc_TxPercVal := 0;
   END IF;

   hr_utility.set_location('py_za_tx_01032000.DirCalc',26);

   -- Base Income
   py_za_tx_utl_01032000.WriteHrTrace('trc_BseErn: '||to_char(trc_BseErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBse: '||to_char(trc_TotLibBse));
   -- Normal Income
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncYtd: '||to_char(trc_NorIncYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncPtd: '||to_char(trc_NorIncPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorErn: '||to_char(trc_NorErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbNorInc: '||to_char(trc_TxbNorInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibNI: '||to_char(trc_TotLibNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyNI: '||to_char(trc_LibFyNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpNI: '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenYtd: '||to_char(trc_FrnBenYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenPtd: '||to_char(trc_FrnBenPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenErn: '||to_char(trc_FrnBenErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbFrnInc: '||to_char(trc_TxbFrnInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibFB: '||to_char(trc_TotLibFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyFB: '||to_char(trc_LibFyFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpFB: '||to_char(trc_LibFpFB));
   -- Travel Allowance
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllYtd: '||to_char(trc_TrvAllYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllPtd: '||to_char(trc_TrvAllPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllErn: '||to_char(trc_TrvAllErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbTrvInc: '||to_char(trc_TxbTrvInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibTA: '||to_char(trc_TotLibTA));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyTA: '||to_char(trc_LibFyTA));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpTA: '||to_char(trc_LibFpTA));
   -- Bonus Provision
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProYtd: '||to_char(trc_BonProYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProPtd: '||to_char(trc_BonProPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProErn: '||to_char(trc_BonProErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBP: '||to_char(trc_TotLibBP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyBP: '||to_char(trc_LibFyBP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpBP: '||to_char(trc_LibFpBP));
   -- Annual Bonus
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonYtd: '||to_char(trc_AnnBonYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonPtd: '||to_char(trc_AnnBonPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonErn: '||to_char(trc_AnnBonErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAB: '||to_char(trc_TotLibAB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAB: '||to_char(trc_LibFyAB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAB: '||to_char(trc_LibFpAB));
   -- Annual Payments
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymYtd: '||to_char(trc_AnnPymYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymPtd: '||to_char(trc_AnnPymPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymErn: '||to_char(trc_AnnPymErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAP: '||to_char(trc_TotLibAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAP: '||to_char(trc_LibFyAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAP: '||to_char(trc_LibFpAP));
   -- Pubilc Office Allowance
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffYtd: '||to_char(trc_PblOffYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffPtd: '||to_char(trc_PblOffPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffErn: '||to_char(trc_PblOffErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyPO: '||to_char(trc_LibFyPO));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpPO: '||to_char(trc_LibFpPO));

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
   l_Np       NUMBER(15,2);
   l_65Year   DATE;

BEGIN
   hr_utility.set_location('py_za_tx_01032000.BasCalc',1);
-- Identify the Calculation
--
   trc_CalTyp := 'BasCalc';

-- Tax Rebates, Threshold Figure and Medical Aid
-- Abatements
   -- Calculate the assignments 65 Year Date
   l_65Year := add_months(dbi_PER_DTE_OF_BRTH,780);

   hr_utility.set_location('py_za_tx_01032000.BasCalc',2);

   IF l_65Year BETWEEN dbi_ZA_TX_YR_STRT AND dbi_ZA_TX_YR_END THEN
      hr_utility.set_location('py_za_tx_01032000.BasCalc',3);
   -- give the extra abatement
      trc_Rebate := glb_ZA_PRI_TX_RBT + glb_ZA_ADL_TX_RBT;
      trc_Threshold := glb_ZA_SC_TX_THRSHLD;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.BasCalc',4);
   -- not eligable for extra abatement
      trc_Rebate := glb_ZA_PRI_TX_RBT;
      trc_Threshold := glb_ZA_PRI_TX_THRSHLD;
   END IF;

-- Base Earnings
--
   --Base Earnings
   trc_BseErn :=
      ( bal_AB_NRFI_PTD
      + bal_AB_RFI_PTD
      + bal_AC_NRFI_PTD
      + bal_AC_RFI_PTD
      + bal_ANU_FRM_RET_FND_NRFI_PTD
      + bal_ANU_FRM_RET_FND_RFI_PTD
      + bal_PRCH_ANU_TXB_NRFI_PTD
      + bal_PRCH_ANU_TXB_RFI_PTD
      + bal_TXB_AP_NRFI_PTD
      + bal_TXB_AP_RFI_PTD
      );
   -- Estimate Base Taxable Income
      trc_TxbBseInc := trc_BseErn * dbi_ZA_PAY_PRDS_PER_YR;
   -- Threshold Check
   IF trc_TxbBseInc >= trc_Threshold THEN
      hr_utility.set_location('py_za_tx_01032000.BasCalc',5);
   -- Tax Liability
      trc_TotLibBse := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbBseInc);
   ELSE
      hr_utility.set_location('py_za_tx_01032000.BasCalc',6);
      trc_TotLibBse := 0;
   END IF;

-- Annual Bonus
--
   -- Ytd Annual Bonus
   trc_AnnBonYtd :=
      ( bal_AB_NRFI_YTD
      + bal_AB_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnBonYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.BasCalc',7);
   -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonYtd + trc_TxbBseInc;
   -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.BasCalc',8);
      -- Tax Liability
         trc_TotLibAB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnBonInc);
         trc_LibFyAB := trc_TotLibAB - trc_TotLibBse;
      -- Negative Check
         IF trc_LibFyAB < 0 THEN
            hr_utility.set_location('py_za_tx_01032000.BasCalc',9);
            trc_TotLibAB := trc_TotLibBse;
         -- Refund any tax paid
            trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
            trc_NpValABOvr := TRUE;
         ELSE
         -- Check Bonus Provision
            IF bal_BP_YTD <> 0 THEN
               hr_utility.set_location('py_za_tx_01032000.BasCalc',10);
            -- Check Bonus Provision Frequency
               IF dbi_BP_TX_RCV = 'A' THEN
                  hr_utility.set_location('py_za_tx_01032000.BasCalc',11);
                  trc_LibFpAB := 0;
               ELSE
                  hr_utility.set_location('py_za_tx_01032000.BasCalc',12);
                  trc_LibFpAB :=
                  trc_LibFyAB - ( bal_TX_ON_BP_YTD
                                + bal_TX_ON_AB_YTD);
               END IF;
            ELSE
               hr_utility.set_location('py_za_tx_01032000.BasCalc',13);
               trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
            END IF;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.BasCalc',14);
         trc_TotLibAB := trc_TotLibBse;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.BasCalc',15);
      trc_TotLibAB := trc_TotLibBse;
      trc_TxbAnnBonInc := trc_TxbBseInc;
   END IF;

-- Annual Payments
--
   -- Ytd Annual Payments
   trc_AnnPymYtd :=
      ( bal_AC_NRFI_YTD
      + bal_AC_RFI_YTD
      + bal_ANU_FRM_RET_FND_NRFI_YTD
      + bal_ANU_FRM_RET_FND_RFI_YTD
      + bal_PRCH_ANU_TXB_NRFI_YTD
      + bal_PRCH_ANU_TXB_RFI_YTD
      + bal_TXB_AP_NRFI_YTD
      + bal_TXB_AP_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnPymYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.BasCalc',16);
   -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymYtd + trc_TxbAnnBonInc;
   -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.BasCalc',17);
      -- Tax Liability
         trc_TotLibAP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnPymInc);
         trc_LibFyAP := trc_TotLibAP - trc_TotLibAB;
      -- Negative Check
         IF trc_LibFyAP < 0 THEN
            hr_utility.set_location('py_za_tx_01032000.BasCalc',18);
            trc_TotLibAP := trc_TotLibAB;
         -- Refund any tax paid
            trc_LibFpAP := -1 * bal_TX_ON_AB_YTD;
            trc_NpValAPOvr := TRUE;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.BasCalc',19);
            trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.BasCalc',20);
         NULL;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.BasCalc',21);
      NULL;
   END IF;

-- Net Pay Validation
--
   py_za_tx_utl_01032000.NpVal;

   -- Base Income
   py_za_tx_utl_01032000.WriteHrTrace('trc_BseErn: '||to_char(trc_BseErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBse: '||to_char(trc_TotLibBse));
   -- Normal Income
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncYtd: '||to_char(trc_NorIncYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncPtd: '||to_char(trc_NorIncPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorErn: '||to_char(trc_NorErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbNorInc: '||to_char(trc_TxbNorInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibNI: '||to_char(trc_TotLibNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyNI: '||to_char(trc_LibFyNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpNI: '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenYtd: '||to_char(trc_FrnBenYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenPtd: '||to_char(trc_FrnBenPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenErn: '||to_char(trc_FrnBenErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbFrnInc: '||to_char(trc_TxbFrnInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibFB: '||to_char(trc_TotLibFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyFB: '||to_char(trc_LibFyFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpFB: '||to_char(trc_LibFpFB));
   -- Travel Allowance
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllYtd: '||to_char(trc_TrvAllYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllPtd: '||to_char(trc_TrvAllPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllErn: '||to_char(trc_TrvAllErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbTrvInc: '||to_char(trc_TxbTrvInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibTA: '||to_char(trc_TotLibTA));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyTA: '||to_char(trc_LibFyTA));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpTA: '||to_char(trc_LibFpTA));
   -- Bonus Provision
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProYtd: '||to_char(trc_BonProYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProPtd: '||to_char(trc_BonProPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProErn: '||to_char(trc_BonProErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBP: '||to_char(trc_TotLibBP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyBP: '||to_char(trc_LibFyBP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpBP: '||to_char(trc_LibFpBP));
   -- Annual Bonus
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonYtd: '||to_char(trc_AnnBonYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonPtd: '||to_char(trc_AnnBonPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonErn: '||to_char(trc_AnnBonErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAB: '||to_char(trc_TotLibAB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAB: '||to_char(trc_LibFyAB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAB: '||to_char(trc_LibFpAB));
   -- Annual Payments
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymYtd: '||to_char(trc_AnnPymYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymPtd: '||to_char(trc_AnnPymPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymErn: '||to_char(trc_AnnPymErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAP: '||to_char(trc_TotLibAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAP: '||to_char(trc_LibFyAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAP: '||to_char(trc_LibFpAP));
   -- Pubilc Office Allowance
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffYtd: '||to_char(trc_PblOffYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffPtd: '||to_char(trc_PblOffPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffErn: '||to_char(trc_PblOffErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyPO: '||to_char(trc_LibFyPO));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpPO: '||to_char(trc_LibFpPO));

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
   l_Np       NUMBER(15,2);

BEGIN
   hr_utility.set_location('py_za_tx_01032000.CalCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'CalCalc';

-- Update Global Balance Values with correct TAXABLE values
--
   py_za_tx_utl_01032000.TrvAll;

   hr_utility.set_location('py_za_tx_01032000.CalCalc',2);

-- Calendar Ytd Taxable Income
--
   trc_TxbIncYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_CYTD
      + bal_AST_PRCHD_RVAL_RFI_CYTD
      + bal_BUR_AND_SCH_NRFI_CYTD
      + bal_BUR_AND_SCH_RFI_CYTD
      + bal_COMM_NRFI_CYTD
      + bal_COMM_RFI_CYTD
      + bal_COMP_ALL_NRFI_CYTD
      + bal_COMP_ALL_RFI_CYTD
      + bal_ENT_ALL_NRFI_CYTD
      + bal_ENT_ALL_RFI_CYTD
      + bal_FREE_ACCOM_NRFI_CYTD
      + bal_FREE_ACCOM_RFI_CYTD
      + bal_FREE_SERV_NRFI_CYTD
      + bal_FREE_SERV_RFI_CYTD
      + bal_LOW_LOANS_NRFI_CYTD
      + bal_LOW_LOANS_RFI_CYTD
      + bal_MLS_AND_VOUCH_NRFI_CYTD
      + bal_MLS_AND_VOUCH_RFI_CYTD
      + bal_MED_PAID_NRFI_CYTD
      + bal_MED_PAID_RFI_CYTD
      + bal_OTHER_TXB_ALL_NRFI_CYTD
      + bal_OTHER_TXB_ALL_RFI_CYTD
      + bal_OVTM_NRFI_CYTD
      + bal_OVTM_RFI_CYTD
      + bal_PYM_DBT_NRFI_CYTD
      + bal_PYM_DBT_RFI_CYTD
      + bal_RGT_AST_NRFI_CYTD
      + bal_RGT_AST_RFI_CYTD
      + bal_TXB_INC_NRFI_CYTD
      + bal_TXB_INC_RFI_CYTD
      + bal_TXB_PEN_NRFI_CYTD
      + bal_TXB_PEN_RFI_CYTD
      + bal_TEL_ALL_NRFI_CYTD
      + bal_TEL_ALL_RFI_CYTD
      + bal_TOOL_ALL_NRFI_CYTD
      + bal_TOOL_ALL_RFI_CYTD
      + bal_TA_NRFI_CYTD
      + bal_TA_RFI_CYTD
      + bal_USE_VEH_NRFI_CYTD
      + bal_USE_VEH_RFI_CYTD
      );

-- If there is no Income Execute the Base calculation
--
   IF trc_TxbIncYtd = 0 THEN
      hr_utility.set_location('py_za_tx_01032000.CalCalc',3);
      BasCalc;
   ELSE -- continue CalCalc
      hr_utility.set_location('py_za_tx_01032000.CalCalc',4);
   -- Site Factor
   --
      trc_SitFactor := dbi_ZA_DYS_IN_YR / py_za_tx_utl_01032000.DaysWorked;

   -- Rebates
      py_za_tx_utl_01032000.SetRebates;

   -- Abatements
      py_za_tx_utl_01032000.Abatements;

      hr_utility.set_location('py_za_tx_01032000.CalCalc',5);

   -- Base Earnings
   --
      -- Base Earnings
      trc_BseErn := trc_TxbIncYtd * trc_SitFactor;
      -- Taxable Base Income
      trc_TxbBseInc := trc_BseErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbBseInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.CalCalc',6);
      -- Tax Liability
         trc_TotLibBse := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbBseInc);
      ELSE
         hr_utility.set_location('py_za_tx_01032000.CalCalc',7);
         trc_TotLibBse := 0;
      END IF;

   -- Annual Bonus
   --
      -- Ytd Annual Bonus
      trc_AnnBonYtd :=
         ( bal_AB_NRFI_YTD
         + bal_AB_RFI_YTD
         );
      -- Skip the calculation if there is No Income
      IF trc_AnnBonYtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032000.CalCalc',8);
      -- Annual Bonus Earnings
         trc_AnnBonErn := trc_AnnBonYtd + trc_BseErn;
      -- Taxable Annual Bonus Income
         trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
      -- Threshold Check
         IF trc_TxbAnnBonInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032000.CalCalc',9);
         -- Tax Liability
            trc_TotLibAB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnBonInc);
            trc_LibFyAB := trc_TotLibAB - trc_TotLibBse;
         -- Negative Check
            IF trc_LibFyAB < 0 THEN
               hr_utility.set_location('py_za_tx_01032000.CalCalc',10);
               trc_TotLibAB := trc_TotLibBse;
            -- Refund any tax paid
               trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
               trc_NpValABOvr := TRUE;
            ELSE
            -- Check Bonus Provision
               IF bal_BP_YTD <> 0 THEN
                  hr_utility.set_location('py_za_tx_01032000.CalCalc',11);
               -- Check Bonus Provision Frequency
                  IF dbi_BP_TX_RCV = 'A' THEN
                     hr_utility.set_location('py_za_tx_01032000.CalCalc',12);
                     trc_LibFpAB := 0;
                  ELSE
                     hr_utility.set_location('py_za_tx_01032000.CalCalc',13);
                     trc_LibFpAB :=
                     trc_LibFyAB - ( bal_TX_ON_BP_YTD
                                   + bal_TX_ON_AB_YTD);
                  END IF;
               ELSE
                  hr_utility.set_location('py_za_tx_01032000.CalCalc',14);
                  trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
               END IF;
            END IF;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.CalCalc',15);
            trc_TotLibAB := trc_TotLibBse;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.CalCalc',16);
         trc_AnnBonErn := trc_BseErn;-- Cascade Figure
         trc_TxbAnnBonInc := trc_TxbBseInc;
         trc_TotLibAB := trc_TotLibBse;
      END IF;

   -- Annual Payments
   --
      -- Ytd Annual Payments
      trc_AnnPymYtd :=
         ( bal_AC_NRFI_YTD
         + bal_AC_RFI_YTD
         + bal_ANU_FRM_RET_FND_NRFI_YTD
         + bal_ANU_FRM_RET_FND_RFI_YTD
         + bal_PRCH_ANU_TXB_NRFI_YTD
         + bal_PRCH_ANU_TXB_RFI_YTD
         + bal_TXB_AP_NRFI_YTD
         + bal_TXB_AP_RFI_YTD
         );
      -- Skip the calculation if there is No Income
      IF trc_AnnPymYtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032000.CalCalc',17);
      -- Annual Payments Earnings
         trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
      -- Taxable Annual Payments Income
         trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
         IF trc_TxbAnnPymInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032000.CalCalc',18);
         -- Tax Liability
            trc_TotLibAP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnPymInc);
            trc_LibFyAP := trc_TotLibAP - trc_TotLibAB;
         -- Negative Check
            IF trc_LibFyAP < 0 THEN
               hr_utility.set_location('py_za_tx_01032000.CalCalc',19);
               trc_TotLibAP := trc_TotLibAB;
            -- Refund any tax paid
               trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
               trc_NpValAPOvr := TRUE;
            ELSE
               hr_utility.set_location('py_za_tx_01032000.CalCalc',20);
               trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
            END IF;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.CalCalc',21);
            trc_TotLibAP := trc_TotLibAB;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.CalCalc',22);
         trc_AnnPymErn := trc_AnnBonErn;
         trc_TxbAnnPymInc := trc_TxbAnnBonInc;
         trc_TotLibAP := trc_TotLibAB;
      END IF;

   -- Net pay Validation
   --
      py_za_tx_utl_01032000.NpVal;

      -- Base Income
      py_za_tx_utl_01032000.WriteHrTrace('trc_BseErn: '||to_char(trc_BseErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBse: '||to_char(trc_TotLibBse));
      -- Normal Income
      py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncYtd: '||to_char(trc_NorIncYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncPtd: '||to_char(trc_NorIncPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_NorErn: '||to_char(trc_NorErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbNorInc: '||to_char(trc_TxbNorInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibNI: '||to_char(trc_TotLibNI));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyNI: '||to_char(trc_LibFyNI));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpNI: '||to_char(trc_LibFpNI));
      -- Fringe Benefits
      py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenYtd: '||to_char(trc_FrnBenYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenPtd: '||to_char(trc_FrnBenPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenErn: '||to_char(trc_FrnBenErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbFrnInc: '||to_char(trc_TxbFrnInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibFB: '||to_char(trc_TotLibFB));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyFB: '||to_char(trc_LibFyFB));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpFB: '||to_char(trc_LibFpFB));
      -- Travel Allowance
      py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllYtd: '||to_char(trc_TrvAllYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllPtd: '||to_char(trc_TrvAllPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllErn: '||to_char(trc_TrvAllErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbTrvInc: '||to_char(trc_TxbTrvInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibTA: '||to_char(trc_TotLibTA));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyTA: '||to_char(trc_LibFyTA));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpTA: '||to_char(trc_LibFpTA));
      -- Bonus Provision
      py_za_tx_utl_01032000.WriteHrTrace('trc_BonProYtd: '||to_char(trc_BonProYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_BonProPtd: '||to_char(trc_BonProPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_BonProErn: '||to_char(trc_BonProErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBP: '||to_char(trc_TotLibBP));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyBP: '||to_char(trc_LibFyBP));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpBP: '||to_char(trc_LibFpBP));
      -- Annual Bonus
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonYtd: '||to_char(trc_AnnBonYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonPtd: '||to_char(trc_AnnBonPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonErn: '||to_char(trc_AnnBonErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAB: '||to_char(trc_TotLibAB));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAB: '||to_char(trc_LibFyAB));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAB: '||to_char(trc_LibFpAB));
      -- Annual Payments
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymYtd: '||to_char(trc_AnnPymYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymPtd: '||to_char(trc_AnnPymPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymErn: '||to_char(trc_AnnPymErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAP: '||to_char(trc_TotLibAP));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAP: '||to_char(trc_LibFyAP));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAP: '||to_char(trc_LibFpAP));
      -- Pubilc Office Allowance
      py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffYtd: '||to_char(trc_PblOffYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffPtd: '||to_char(trc_PblOffPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffErn: '||to_char(trc_PblOffErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyPO: '||to_char(trc_LibFyPO));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpPO: '||to_char(trc_LibFpPO));

   END IF;

   hr_utility.set_location('py_za_tx_01032000.CalCalc',23);

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
   l_Np       NUMBER(15,2);

BEGIN
   hr_utility.set_location('py_za_tx_01032000.YtdCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'YtdCalc';

-- Update Global Balance Values with correct TAXABLE values
   py_za_tx_utl_01032000.TrvAll;

   hr_utility.set_location('py_za_tx_01032000.YtdCalc',2);

-- Ytd Taxable Income
   trc_TxbIncYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_YTD
      + bal_AST_PRCHD_RVAL_RFI_YTD
      + bal_BP_YTD
      + bal_BUR_AND_SCH_NRFI_YTD
      + bal_BUR_AND_SCH_RFI_YTD
      + bal_COMM_NRFI_YTD
      + bal_COMM_RFI_YTD
      + bal_COMP_ALL_NRFI_YTD
      + bal_COMP_ALL_RFI_YTD
      + bal_ENT_ALL_NRFI_YTD
      + bal_ENT_ALL_RFI_YTD
      + bal_FREE_ACCOM_NRFI_YTD
      + bal_FREE_ACCOM_RFI_YTD
      + bal_FREE_SERV_NRFI_YTD
      + bal_FREE_SERV_RFI_YTD
      + bal_LOW_LOANS_NRFI_YTD
      + bal_LOW_LOANS_RFI_YTD
      + bal_MLS_AND_VOUCH_NRFI_YTD
      + bal_MLS_AND_VOUCH_RFI_YTD
      + bal_MED_PAID_NRFI_YTD
      + bal_MED_PAID_RFI_YTD
      + bal_OTHER_TXB_ALL_NRFI_YTD
      + bal_OTHER_TXB_ALL_RFI_YTD
      + bal_OVTM_NRFI_YTD
      + bal_OVTM_RFI_YTD
      + bal_PYM_DBT_NRFI_YTD
      + bal_PYM_DBT_RFI_YTD
      + bal_RGT_AST_NRFI_YTD
      + bal_RGT_AST_RFI_YTD
      + bal_TXB_INC_NRFI_YTD
      + bal_TXB_INC_RFI_YTD
      + bal_TXB_PEN_NRFI_YTD
      + bal_TXB_PEN_RFI_YTD
      + bal_TEL_ALL_NRFI_YTD
      + bal_TEL_ALL_RFI_YTD
      + bal_TOOL_ALL_NRFI_YTD
      + bal_TOOL_ALL_RFI_YTD
      + bal_TA_NRFI_YTD
      + bal_TA_RFI_YTD
      + bal_USE_VEH_NRFI_YTD
      + bal_USE_VEH_RFI_YTD
      );

-- If the Ytd Taxable Income = 0, execute the CalCalc
   IF trc_TxbIncYtd = 0 THEN
      hr_utility.set_location('py_za_tx_01032000.YtdCalc',3);
      CalCalc;
   ELSE --Continue YtdCalc
      hr_utility.set_location('py_za_tx_01032000.YtdCalc',4);
   -- Site Factor
      trc_SitFactor := dbi_ZA_DYS_IN_YR / py_za_tx_utl_01032000.DaysWorked;

   -- Rebates
      py_za_tx_utl_01032000.SetRebates;

   -- Abatements
      py_za_tx_utl_01032000.Abatements;

      hr_utility.set_location('py_za_tx_01032000.YtdCalc',5);

   -- Base Earnings
   --
      -- Base Earnings
      trc_BseErn := trc_TxbIncYtd * trc_SitFactor;
      -- Taxable Base Income
      trc_TxbBseInc := trc_BseErn - trc_PerTotAbm;
      -- Threshold Check
      IF trc_TxbBseInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.YtdCalc',6);
      -- Tax Liability
         trc_TotLibBse := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbBseInc);
      ELSE
         hr_utility.set_location('py_za_tx_01032000.YtdCalc',7);
         trc_TotLibBse := 0;
      END IF;

   -- Annual Bonus
   --
      -- Ytd Annual Bonus
      trc_AnnBonYtd :=
         ( bal_AB_NRFI_YTD
         + bal_AB_RFI_YTD
         );
      -- Skip the calculation if there is No Income
      IF trc_AnnBonYtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032000.YtdCalc',8);
      -- Annual Bonus Earnings
         trc_AnnBonErn := trc_AnnBonYtd + trc_BseErn;
      -- Taxable Annual Bonus Income
         trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
      -- Threshold Check
         IF trc_TxbAnnBonInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032000.YtdCalc',9);
         -- Tax Liability
            trc_TotLibAB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnBonInc);
            trc_LibFyAB := trc_TotLibAB - trc_TotLibBse;
         -- Negative Check
            IF trc_LibFyAB < 0 THEN
               hr_utility.set_location('py_za_tx_01032000.YtdCalc',10);
               trc_TotLibAB := trc_TotLibBse;
            -- Refund any tax paid
               trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
               trc_NpValABOvr := TRUE;
            ELSE
            -- Check Bonus Provision
               IF bal_BP_YTD <> 0 THEN
                  hr_utility.set_location('py_za_tx_01032000.YtdCalc',11);
               -- Check Bonus Provision Frequency
                  IF dbi_BP_TX_RCV = 'A' THEN
                     hr_utility.set_location('py_za_tx_01032000.YtdCalc',12);
                     trc_LibFpAB := 0;
                  ELSE
                     hr_utility.set_location('py_za_tx_01032000.YtdCalc',13);
                     trc_LibFpAB :=
                     trc_LibFyAB - ( bal_TX_ON_BP_YTD
                                   + bal_TX_ON_AB_YTD);
                  END IF;
               ELSE
                  hr_utility.set_location('py_za_tx_01032000.YtdCalc',14);
                  trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
               END IF;
            END IF;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.YtdCalc',15);
            trc_TotLibAB := trc_TotLibBse;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.YtdCalc',16);
         trc_AnnBonErn := trc_BseErn;-- Cascade Figure
         trc_TxbAnnBonInc := trc_TxbBseInc;
         trc_TotLibAB := trc_TotLibBse;
      END IF;

   -- Annual Payments
   --
      -- Ytd Annual Payments
      trc_AnnPymYtd :=
         ( bal_AC_NRFI_YTD
         + bal_AC_RFI_YTD
         + bal_ANU_FRM_RET_FND_NRFI_YTD
         + bal_ANU_FRM_RET_FND_RFI_YTD
         + bal_PRCH_ANU_TXB_NRFI_YTD
         + bal_PRCH_ANU_TXB_RFI_YTD
         + bal_TXB_AP_NRFI_YTD
         + bal_TXB_AP_RFI_YTD
         );
      -- Skip the calculation if there is No Income
      IF trc_AnnPymYtd <> 0 THEN
         hr_utility.set_location('py_za_tx_01032000.YtdCalc',17);
      -- Annual Payments Earnings
         trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
      -- Taxable Annual Payments Income
         trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
      -- Threshold Check
         IF trc_TxbAnnPymInc >= trc_Threshold THEN
            hr_utility.set_location('py_za_tx_01032000.YtdCalc',18);
         -- Tax Liability
            trc_TotLibAP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnPymInc);
            trc_LibFyAP := trc_TotLibAP - trc_TotLibAB;
         -- Negative Check
            IF trc_LibFyAP < 0 THEN
               hr_utility.set_location('py_za_tx_01032000.YtdCalc',19);
               trc_TotLibAP := trc_TotLibAB;
            -- Refund any tax paid
               trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
               trc_NpValAPOvr := TRUE;
            ELSE
               hr_utility.set_location('py_za_tx_01032000.YtdCalc',20);
               trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
            END IF;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.YtdCalc',21);
            trc_TotLibAP := trc_TotLibAB;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.YtdCalc',22);
         trc_AnnPymErn := trc_AnnBonErn;-- Cascade Figure
         trc_TxbAnnPymInc := trc_TxbAnnBonInc;
         trc_TotLibAP := trc_TotLibAB;
      END IF;

   -- Net Pay validation
   --
      py_za_tx_utl_01032000.NpVal;

      hr_utility.set_location('py_za_tx_01032000.YtdCalc',23);

      -- Base Income
      py_za_tx_utl_01032000.WriteHrTrace('trc_BseErn: '||to_char(trc_BseErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBse: '||to_char(trc_TotLibBse));
      -- Normal Income
      py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncYtd: '||to_char(trc_NorIncYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncPtd: '||to_char(trc_NorIncPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_NorErn: '||to_char(trc_NorErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbNorInc: '||to_char(trc_TxbNorInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibNI: '||to_char(trc_TotLibNI));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyNI: '||to_char(trc_LibFyNI));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpNI: '||to_char(trc_LibFpNI));
      -- Fringe Benefits
      py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenYtd: '||to_char(trc_FrnBenYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenPtd: '||to_char(trc_FrnBenPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenErn: '||to_char(trc_FrnBenErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbFrnInc: '||to_char(trc_TxbFrnInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibFB: '||to_char(trc_TotLibFB));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyFB: '||to_char(trc_LibFyFB));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpFB: '||to_char(trc_LibFpFB));
      -- Travel Allowance
      py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllYtd: '||to_char(trc_TrvAllYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllPtd: '||to_char(trc_TrvAllPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllErn: '||to_char(trc_TrvAllErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbTrvInc: '||to_char(trc_TxbTrvInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibTA: '||to_char(trc_TotLibTA));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyTA: '||to_char(trc_LibFyTA));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpTA: '||to_char(trc_LibFpTA));
      -- Bonus Provision
      py_za_tx_utl_01032000.WriteHrTrace('trc_BonProYtd: '||to_char(trc_BonProYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_BonProPtd: '||to_char(trc_BonProPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_BonProErn: '||to_char(trc_BonProErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBP: '||to_char(trc_TotLibBP));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyBP: '||to_char(trc_LibFyBP));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpBP: '||to_char(trc_LibFpBP));
      -- Annual Bonus
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonYtd: '||to_char(trc_AnnBonYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonPtd: '||to_char(trc_AnnBonPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonErn: '||to_char(trc_AnnBonErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAB: '||to_char(trc_TotLibAB));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAB: '||to_char(trc_LibFyAB));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAB: '||to_char(trc_LibFpAB));
      -- Annual Payments
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymYtd: '||to_char(trc_AnnPymYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymPtd: '||to_char(trc_AnnPymPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymErn: '||to_char(trc_AnnPymErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
      py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAP: '||to_char(trc_TotLibAP));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAP: '||to_char(trc_LibFyAP));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAP: '||to_char(trc_LibFpAP));
      -- Pubilc Office Allowance
      py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffYtd: '||to_char(trc_PblOffYtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffPtd: '||to_char(trc_PblOffPtd));
      py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffErn: '||to_char(trc_PblOffErn));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyPO: '||to_char(trc_LibFyPO));
      py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpPO: '||to_char(trc_LibFpPO));

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
   l_Np       NUMBER(15,2) DEFAULT 0;

BEGIN
   hr_utility.set_location('py_za_tx_01032000.NorCalc',1);
-- Identify the calculation
--
   trc_CalTyp := 'NorCalc';

-- Update Global Balance Values with correct TAXABLE values
--
   bal_TA_RFI_PTD :=
   bal_TA_RFI_PTD * glb_ZA_TRV_ALL_TX_PRC / 100;

   bal_TA_NRFI_PTD :=
   bal_TA_NRFI_PTD * glb_ZA_TRV_ALL_TX_PRC / 100;

   py_za_tx_utl_01032000.TrvAll;

   hr_utility.set_location('py_za_tx_01032000.NorCalc',2);

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
      ( bal_AST_PRCHD_RVAL_NRFI_PTD
      + bal_AST_PRCHD_RVAL_RFI_PTD
      + bal_BP_PTD
      + bal_BUR_AND_SCH_NRFI_PTD
      + bal_BUR_AND_SCH_RFI_PTD
      + bal_COMM_NRFI_PTD
      + bal_COMM_RFI_PTD
      + bal_COMP_ALL_NRFI_PTD
      + bal_COMP_ALL_RFI_PTD
      + bal_ENT_ALL_NRFI_PTD
      + bal_ENT_ALL_RFI_PTD
      + bal_FREE_ACCOM_NRFI_PTD
      + bal_FREE_ACCOM_RFI_PTD
      + bal_FREE_SERV_NRFI_PTD
      + bal_FREE_SERV_RFI_PTD
      + bal_LOW_LOANS_NRFI_PTD
      + bal_LOW_LOANS_RFI_PTD
      + bal_MLS_AND_VOUCH_NRFI_PTD
      + bal_MLS_AND_VOUCH_RFI_PTD
      + bal_MED_PAID_NRFI_PTD
      + bal_MED_PAID_RFI_PTD
      + bal_OTHER_TXB_ALL_NRFI_PTD
      + bal_OTHER_TXB_ALL_RFI_PTD
      + bal_OVTM_NRFI_PTD
      + bal_OVTM_RFI_PTD
      + bal_PYM_DBT_NRFI_PTD
      + bal_PYM_DBT_RFI_PTD
      + bal_RGT_AST_NRFI_PTD
      + bal_RGT_AST_RFI_PTD
      + bal_TXB_INC_NRFI_PTD
      + bal_TXB_INC_RFI_PTD
      + bal_TXB_PEN_NRFI_PTD
      + bal_TXB_PEN_RFI_PTD
      + bal_TEL_ALL_NRFI_PTD
      + bal_TEL_ALL_RFI_PTD
      + bal_TOOL_ALL_NRFI_PTD
      + bal_TOOL_ALL_RFI_PTD
      + bal_TA_NRFI_PTD
      + bal_TA_RFI_PTD
      + bal_USE_VEH_NRFI_PTD
      + bal_USE_VEH_RFI_PTD
      );

-- Period Factor
   py_za_tx_utl_01032000.PeriodFactor;

-- Possible Periods Factor
   py_za_tx_utl_01032000.PossiblePeriodsFactor;

-- Rebates
   py_za_tx_utl_01032000.SetRebates;

-- Abatements
   py_za_tx_utl_01032000.Abatements;

   hr_utility.set_location('py_za_tx_01032000.NorCalc',3);

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
      hr_utility.set_location('py_za_tx_01032000.NorCalc',4);
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
      trc_NorErn := py_za_tx_utl_01032000.Annualise
         (p_YtdInc => trc_NorIncYtd
         ,p_PtdInc => trc_NorIncPtd
         );

   -- Taxable Normal Income
      trc_TxbNorInc := trc_NorErn - trc_PerTotAbm;

   -- Threshold Check
      IF trc_TxbNorInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.NorCalc',5);
      -- Tax Liability
         trc_TotLibNI := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbNorInc);
         trc_LibFyNI := trc_TotLibNI - 0;
      -- DeAnnualise
         trc_LibFpNI := py_za_tx_utl_01032000.DeAnnualise
            (p_Liab    => trc_LibFyNI
            ,p_TxOnYtd => bal_TX_ON_NI_YTD
            ,p_TxOnPtd => bal_TX_ON_NI_PTD
            );
      ELSE
         hr_utility.set_location('py_za_tx_01032000.NorCalc',6);
         trc_TotLibNI := 0;
      -- Refund any tax paid
         trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
         trc_NpValNIOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.NorCalc',7);
      trc_NorErn := 0;
      trc_TxbNorInc := 0;
      trc_TotLibNI := 0;
   -- Refund any tax paid
      trc_LibFpNI := -1 * bal_TX_ON_NI_YTD;
      trc_NpValNIOvr := TRUE;
   END IF;

-- Fringe Benefits
--
   -- Ytd Fringe Benefits
   trc_FrnBenYtd :=
      ( bal_AST_PRCHD_RVAL_NRFI_YTD
      + bal_AST_PRCHD_RVAL_RFI_YTD
      + bal_BUR_AND_SCH_NRFI_YTD
      + bal_BUR_AND_SCH_RFI_YTD
      + bal_FREE_ACCOM_NRFI_YTD
      + bal_FREE_ACCOM_RFI_YTD
      + bal_FREE_SERV_NRFI_YTD
      + bal_FREE_SERV_RFI_YTD
      + bal_LOW_LOANS_NRFI_YTD
      + bal_LOW_LOANS_RFI_YTD
      + bal_MLS_AND_VOUCH_NRFI_YTD
      + bal_MLS_AND_VOUCH_RFI_YTD
      + bal_MED_PAID_NRFI_YTD
      + bal_MED_PAID_RFI_YTD
      + bal_PYM_DBT_NRFI_YTD
      + bal_PYM_DBT_RFI_YTD
      + bal_RGT_AST_NRFI_YTD
      + bal_RGT_AST_RFI_YTD
      + bal_USE_VEH_NRFI_YTD
      + bal_USE_VEH_RFI_YTD
      );

   -- Skip the calculation if there is No Income
   IF trc_FrnBenYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.NorCalc',8);
   -- Ptd Fringe Benefits
      trc_FrnBenPtd :=
         ( bal_AST_PRCHD_RVAL_NRFI_PTD
         + bal_AST_PRCHD_RVAL_RFI_PTD
         + bal_BUR_AND_SCH_NRFI_PTD
         + bal_BUR_AND_SCH_RFI_PTD
         + bal_FREE_ACCOM_NRFI_PTD
         + bal_FREE_ACCOM_RFI_PTD
         + bal_FREE_SERV_NRFI_PTD
         + bal_FREE_SERV_RFI_PTD
         + bal_LOW_LOANS_NRFI_PTD
         + bal_LOW_LOANS_RFI_PTD
         + bal_MLS_AND_VOUCH_NRFI_PTD
         + bal_MLS_AND_VOUCH_RFI_PTD
         + bal_MED_PAID_NRFI_PTD
         + bal_MED_PAID_RFI_PTD
         + bal_PYM_DBT_NRFI_PTD
         + bal_PYM_DBT_RFI_PTD
         + bal_RGT_AST_NRFI_PTD
         + bal_RGT_AST_RFI_PTD
         + bal_USE_VEH_NRFI_PTD
         + bal_USE_VEH_RFI_PTD
         );
   -- Annualise Fringe Benefits
      trc_FrnBenErn := py_za_tx_utl_01032000.Annualise
         (p_YtdInc => trc_FrnBenYtd
         ,p_PtdInc => trc_FrnBenPtd
         ) + trc_NorErn;
   -- Taxable Fringe Income
      trc_TxbFrnInc := trc_FrnBenErn - trc_PerTotAbm;
   -- Threshold Check
      IF trc_TxbFrnInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.NorCalc',9);
      -- Tax Liability
         trc_TotLibFB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbFrnInc);
         trc_LibFyFB := trc_TotLibFB - least(trc_TotLibFB,trc_TotLibNI);
      -- DeAnnualise
         trc_LibFpFB := py_za_tx_utl_01032000.DeAnnualise
            (trc_LibFyFB
            ,bal_TX_ON_FB_YTD
            ,bal_TX_ON_FB_PTD
            );
      ELSE
         hr_utility.set_location('py_za_tx_01032000.NorCalc',10);
         trc_TotLibFB := trc_TotLibNI;
      -- Refund any tax paid
         trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
         trc_NpValFBOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.NorCalc',11);
      trc_FrnBenErn := trc_NorErn;
      trc_TxbFrnInc := trc_TxbNorInc;
      trc_TotLibFB := trc_TotLibNI;
   -- Refund any tax paid
      trc_LibFpFB := -1 * bal_TX_ON_FB_YTD;
      trc_NpValFBOvr := TRUE;
   END IF;

-- Travel Allowance
--
   -- Ytd Travel Allowance
   trc_TrvAllYtd :=
      ( bal_TA_NRFI_YTD
      + bal_TA_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_TrvAllYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.NorCalc',12);
   -- Ptd Travel Allowance
      trc_TrvAllPtd :=
         ( bal_TA_NRFI_PTD
         + bal_TA_RFI_PTD
         );
   -- Annualise Travel Allowance
      trc_TrvAllErn := py_za_tx_utl_01032000.Annualise
         (p_YtdInc => trc_TrvAllYtd
         ,p_PtdInc => trc_TrvAllPtd
         ) + trc_FrnBenErn;
   -- Taxable Travel Income
      trc_TxbTrvInc := trc_TrvAllErn - trc_PerTotAbm;
   -- Threshold Check
      IF trc_TxbTrvInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.NorCalc',13);
      -- Tax Liability
         trc_TotLibTA := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbTrvInc);
         trc_LibFyTA := trc_TotLibTA - least(trc_TotLibTA,trc_TotLibFB);
      -- DeAnnualise
         trc_LibFpTA := py_za_tx_utl_01032000.DeAnnualise
            (trc_LibFyTA
            ,bal_TX_ON_TA_YTD
            ,bal_TX_ON_TA_PTD
            );
      ELSE
         hr_utility.set_location('py_za_tx_01032000.NorCalc',14);
         trc_TotLibTA := trc_TotLibFB;
      -- Refund any tax paid
         trc_LibFpTA := -1 * bal_TX_ON_TA_YTD;
         trc_NpValTAOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.NorCalc',15);
      trc_TrvAllErn := trc_FrnBenErn;-- Cascade Figure
      trc_TxbTrvInc := trc_TxbFrnInc;
      trc_TotLibTA := trc_TotLibFB;
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
      hr_utility.set_location('py_za_tx_01032000.NorCalc',16);
   -- Ptd Bonus Provision
      trc_BonProPtd := bal_BP_PTD;
   -- Annualise Bonus Provision
      trc_BonProErn := py_za_tx_utl_01032000.Annualise
         (p_YtdInc => trc_BonProYtd
         ,p_PtdInc => trc_BonProPtd
         ) + trc_TrvAllErn;
   -- Taxable Bonus Provision Income
      trc_TxbBonProInc := trc_BonProErn - trc_PerTotAbm;
   -- Threshold Check
      IF trc_TxbBonProInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.NorCalc',17);
      -- Tax Liability
         trc_TotLibBP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbBonProInc);
         trc_LibFyBP := trc_TotLibBP - least(trc_TotLibBP,trc_TotLibTA);
      -- DeAnnualise
         trc_LibFpBP := py_za_tx_utl_01032000.DeAnnualise
            (trc_LibFyBP
            ,bal_TX_ON_BP_YTD
            ,bal_TX_ON_BP_PTD
           );
      ELSE
         hr_utility.set_location('py_za_tx_01032000.NorCalc',18);
         trc_TotLibBP := trc_TotLibTA;
      -- Refund any tax paid
         trc_LibFpBP := -1 * bal_TX_ON_BP_YTD;
         trc_NpValBPOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.NorCalc',19);
      trc_BonProErn := trc_TrvAllErn;
      trc_TxbBonProInc := trc_TxbTrvInc;
      trc_TotLibBP := trc_TotLibTA;
   -- Refund any tax paid
      trc_LibFpBP := -1 * bal_TX_ON_BP_YTD;
      trc_NpValBPOvr := TRUE;
   END IF;

-- Annual Bonus
--
   -- Ytd Annual Bonus
   trc_AnnBonYtd :=
      ( bal_AB_NRFI_YTD
      + bal_AB_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnBonYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.NorCalc',20);
   -- Annual Bonus Earnings
      trc_AnnBonErn := trc_AnnBonYtd + trc_TrvAllErn;
   -- Taxable Annual Bonus Income
      trc_TxbAnnBonInc := trc_AnnBonErn - trc_AnnTotAbm;
   -- Threshold Check
      IF trc_TxbAnnBonInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.NorCalc',21);
      -- Tax Liability
         trc_TotLibAB := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnBonInc);
         trc_LibFyAB := trc_TotLibAB - trc_TotLibTA;
      -- Negative Check
         IF trc_LibFyAB < 0 THEN
            hr_utility.set_location('py_za_tx_01032000.NorCalc',22);
            trc_TotLibAB := trc_TotLibTA;
         -- Refund any tax paid
            trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
            trc_NpValABOvr := TRUE;
         ELSE
         -- Check Bonus Provision
            IF trc_BonProYtd <> 0 THEN
               hr_utility.set_location('py_za_tx_01032000.NorCalc',23);
            -- Check Bonus Provision Frequency
               IF dbi_BP_TX_RCV = 'A' THEN
                  hr_utility.set_location('py_za_tx_01032000.NorCalc',24);
                  trc_LibFpAB := 0;
               ELSE
                  hr_utility.set_location('py_za_tx_01032000.NorCalc',25);
                  trc_LibFpAB :=
                  trc_LibFyAB - ( bal_TX_ON_BP_YTD
                                + trc_LibFpBP
                                + bal_TX_ON_AB_YTD);
               END IF;
            ELSE
               hr_utility.set_location('py_za_tx_01032000.NorCalc',26);
               trc_LibFpAB := trc_LibFyAB - bal_TX_ON_AB_YTD;
            END IF;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.NorCalc',27);
         trc_TotLibAB := trc_TotLibTA;
      -- Refund any tax paid
         trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
         trc_NpValABOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.NorCalc',28);
      trc_AnnBonErn := trc_TrvAllErn;
      trc_TxbAnnBonInc := trc_TxbTrvInc;
      trc_TotLibAB := trc_TotLibTA;
   -- Refund any tax paid
      trc_LibFpAB := -1 * bal_TX_ON_AB_YTD;
      trc_NpValABOvr := TRUE;
   END IF;

-- Annual Payments
--
   -- Ytd Annual Payments
   trc_AnnPymYtd :=
      ( bal_AC_NRFI_YTD
      + bal_AC_RFI_YTD
      + bal_ANU_FRM_RET_FND_NRFI_YTD
      + bal_ANU_FRM_RET_FND_RFI_YTD
      + bal_PRCH_ANU_TXB_NRFI_YTD
      + bal_PRCH_ANU_TXB_RFI_YTD
      + bal_TXB_AP_NRFI_YTD
      + bal_TXB_AP_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_AnnPymYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.NorCalc',29);
   -- Annual Payments Earnings
      trc_AnnPymErn := trc_AnnPymYtd + trc_AnnBonErn;
   -- Taxable Annual Payments Income
      trc_TxbAnnPymInc := trc_AnnPymErn - trc_AnnTotAbm;
   -- Threshold Check
      IF trc_TxbAnnPymInc >= trc_Threshold THEN
         hr_utility.set_location('py_za_tx_01032000.NorCalc',30);
      -- Tax Liability
         trc_TotLibAP := py_za_tx_utl_01032000.TaxLiability(p_Amt => trc_TxbAnnPymInc);
         trc_LibFyAP := trc_TotLibAP - trc_TotLibAB;
      -- Negative Check
         IF trc_LibFyAP < 0 THEN
            hr_utility.set_location('py_za_tx_01032000.NorCalc',31);
            trc_TotLibAP := trc_TotLibAB;
         -- Refund any tax paid
            trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
            trc_NpValAPOvr := TRUE;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.NorCalc',32);
            trc_LibFpAP := trc_LibFyAP - bal_TX_ON_AP_YTD;
         END IF;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.NorCalc',33);
         trc_TotLibAP := trc_TotLibAB;
      -- Refund any tax paid
         trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
         trc_NpValAPOvr := TRUE;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.NorCalc',34);
      trc_AnnPymErn := trc_AnnBonErn;
      trc_TxbAnnPymInc := trc_TxbAnnBonInc;
      trc_TotLibAP := trc_TotLibAB;
   -- Refund any tax paid
      trc_LibFpAP := -1 * bal_TX_ON_AP_YTD;
      trc_NpValAPOvr := TRUE;
   END IF;

-- Public Office Allowance
--
   -- Ytd Public Office Allowance
   trc_PblOffYtd :=
      ( bal_PO_NRFI_YTD
      + bal_PO_RFI_YTD
      );
   -- Skip the calculation if there is No Income
   IF trc_PblOffYtd <> 0 THEN
      hr_utility.set_location('py_za_tx_01032000.NorCalc',35);
   -- Ptd Public Office Allowance
      trc_PblOffPtd :=
         ( bal_PO_NRFI_PTD
         + bal_PO_RFI_PTD
         );
   -- Annualise Public Office Allowance
      trc_PblOffErn := py_za_tx_utl_01032000.Annualise
         (p_YtdInc => trc_PblOffYtd
         ,p_PtdInc => trc_PblOffPtd
         );
   -- Tax Liability
      trc_LibFyPO := trc_PblOffErn * glb_ZA_PBL_TX_RTE / 100;
      trc_LibFpPO := py_za_tx_utl_01032000.DeAnnualise
         (trc_LibFyPO
         ,bal_TX_ON_PO_YTD
         ,bal_TX_ON_PO_PTD
         );
   ELSE
      hr_utility.set_location('py_za_tx_01032000.NorCalc',36);
   -- Refund any tax paid
      trc_LibFpPO := -1 * bal_TX_ON_PO_YTD;
      trc_NpValPOOvr := TRUE;
   END IF;

-- Net Pay Validation
--
   py_za_tx_utl_01032000.NpVal;

   hr_utility.set_location('py_za_tx_01032000.NorCalc',37);

   -- Base Income
   py_za_tx_utl_01032000.WriteHrTrace('trc_BseErn: '||to_char(trc_BseErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBseInc: '||to_char(trc_TxbBseInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBse: '||to_char(trc_TotLibBse));
   -- Normal Income
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncYtd: '||to_char(trc_NorIncYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorIncPtd: '||to_char(trc_NorIncPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_NorErn: '||to_char(trc_NorErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbNorInc: '||to_char(trc_TxbNorInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibNI: '||to_char(trc_TotLibNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyNI: '||to_char(trc_LibFyNI));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpNI: '||to_char(trc_LibFpNI));
   -- Fringe Benefits
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenYtd: '||to_char(trc_FrnBenYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenPtd: '||to_char(trc_FrnBenPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_FrnBenErn: '||to_char(trc_FrnBenErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbFrnInc: '||to_char(trc_TxbFrnInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibFB: '||to_char(trc_TotLibFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyFB: '||to_char(trc_LibFyFB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpFB: '||to_char(trc_LibFpFB));
   -- Travel Allowance
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllYtd: '||to_char(trc_TrvAllYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllPtd: '||to_char(trc_TrvAllPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TrvAllErn: '||to_char(trc_TrvAllErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbTrvInc: '||to_char(trc_TxbTrvInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibTA: '||to_char(trc_TotLibTA));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyTA: '||to_char(trc_LibFyTA));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpTA: '||to_char(trc_LibFpTA));
   -- Bonus Provision
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProYtd: '||to_char(trc_BonProYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProPtd: '||to_char(trc_BonProPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_BonProErn: '||to_char(trc_BonProErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbBonProInc: '||to_char(trc_TxbBonProInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibBP: '||to_char(trc_TotLibBP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyBP: '||to_char(trc_LibFyBP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpBP: '||to_char(trc_LibFpBP));
   -- Annual Bonus
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonYtd: '||to_char(trc_AnnBonYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonPtd: '||to_char(trc_AnnBonPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnBonErn: '||to_char(trc_AnnBonErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnBonInc: '||to_char(trc_TxbAnnBonInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAB: '||to_char(trc_TotLibAB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAB: '||to_char(trc_LibFyAB));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAB: '||to_char(trc_LibFpAB));
   -- Annual Payments
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymYtd: '||to_char(trc_AnnPymYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymPtd: '||to_char(trc_AnnPymPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_AnnPymErn: '||to_char(trc_AnnPymErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TxbAnnPymInc: '||to_char(trc_TxbAnnPymInc));
   py_za_tx_utl_01032000.WriteHrTrace('trc_TotLibAP: '||to_char(trc_TotLibAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyAP: '||to_char(trc_LibFyAP));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpAP: '||to_char(trc_LibFpAP));
   -- Pubilc Office Allowance
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffYtd: '||to_char(trc_PblOffYtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffPtd: '||to_char(trc_PblOffPtd));
   py_za_tx_utl_01032000.WriteHrTrace('trc_PblOffErn: '||to_char(trc_PblOffErn));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFyPO: '||to_char(trc_LibFyPO));
   py_za_tx_utl_01032000.WriteHrTrace('trc_LibFpPO: '||to_char(trc_LibFpPO));

EXCEPTION
   WHEN OTHERS THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'NorCalc: '||TO_CHAR(SQLCODE);
      END IF;
      RAISE xpt_E;
END NorCalc;


-- Function to Initialise Globals
--
FUNCTION ZaTxGlb_01032000(
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
      hr_utility.set_message(801, 'ZaTxGlb_01032000: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxGlb_01032000;

-- Function to Initialise Globals - Database Item Values
--
FUNCTION ZaTxDbi_01032000(
-- Database Items
    p_ARR_PF_FRQ IN VARCHAR2 DEFAULT 'M'
   ,p_ARR_RA_FRQ IN VARCHAR2 DEFAULT 'M'
   ,p_BP_TX_RCV IN VARCHAR2 DEFAULT 'B'
   ,p_PER_AGE IN NUMBER DEFAULT 0
   ,p_PER_DTE_OF_BRTH IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_RA_FRQ IN VARCHAR2 DEFAULT 'M'
   ,p_SEA_WRK_DYS_WRK IN NUMBER DEFAULT 0
   ,p_SES_DTE IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_TX_DIR_NUM IN VARCHAR2 DEFAULT 'NULL'
   ,p_TX_DIR_VAL IN NUMBER DEFAULT 0
   ,p_TX_STA IN VARCHAR2 DEFAULT 'X'
   ,p_ZA_ACT_END_DTE IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
   ,p_ZA_ACT_STRT_DTE IN DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
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
   dbi_BP_TX_RCV           := p_BP_TX_RCV;
   dbi_PER_AGE             := p_PER_AGE;
   dbi_PER_DTE_OF_BRTH     := p_PER_DTE_OF_BRTH;
   dbi_RA_FRQ              := p_RA_FRQ;
   dbi_SEA_WRK_DYS_WRK     := p_SEA_WRK_DYS_WRK;
   dbi_SES_DTE             := p_SES_DTE;
   dbi_TX_DIR_NUM          := p_TX_DIR_NUM;
   dbi_TX_DIR_VAL          := p_TX_DIR_VAL;
   dbi_TX_STA              := p_TX_STA;
   dbi_ZA_ACT_END_DTE      := p_ZA_ACT_END_DTE;
   dbi_ZA_ACT_STRT_DTE     := p_ZA_ACT_STRT_DTE;
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
      hr_utility.set_message(801, 'ZaTxDbi_01032000: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxDbi_01032000;


-- Function to Initialise Globals - Balance Values
-- First Section
FUNCTION ZaTxBal1_01032000(
-- Balances
    p_AB_NRFI_CMTD               IN NUMBER DEFAULT 0
   ,p_AB_NRFI_RUN                IN NUMBER DEFAULT 0
   ,p_AB_NRFI_PTD                IN NUMBER DEFAULT 0
   ,p_AB_NRFI_YTD                IN NUMBER DEFAULT 0
   ,p_AB_RFI_CMTD                IN NUMBER DEFAULT 0
   ,p_AB_RFI_RUN                 IN NUMBER DEFAULT 0
   ,p_AB_RFI_PTD                 IN NUMBER DEFAULT 0
   ,p_AB_RFI_YTD                 IN NUMBER DEFAULT 0
   ,p_AC_NRFI_RUN                IN NUMBER DEFAULT 0
   ,p_AC_NRFI_PTD                IN NUMBER DEFAULT 0
   ,p_AC_NRFI_YTD                IN NUMBER DEFAULT 0
   ,p_AC_RFI_RUN                 IN NUMBER DEFAULT 0
   ,p_AC_RFI_PTD                 IN NUMBER DEFAULT 0
   ,p_AC_RFI_YTD                 IN NUMBER DEFAULT 0
   ,p_ANN_PF_CMTD                IN NUMBER DEFAULT 0
   ,p_ANN_PF_RUN                 IN NUMBER DEFAULT 0
   ,p_ANN_PF_PTD                 IN NUMBER DEFAULT 0
   ,p_ANN_PF_YTD                 IN NUMBER DEFAULT 0
   ,p_ANU_FRM_RET_FND_NRFI_CMTD  IN NUMBER DEFAULT 0
   ,p_ANU_FRM_RET_FND_NRFI_RUN   IN NUMBER DEFAULT 0
   ,p_ANU_FRM_RET_FND_NRFI_PTD   IN NUMBER DEFAULT 0
   ,p_ANU_FRM_RET_FND_NRFI_YTD   IN NUMBER DEFAULT 0
   ,p_ANU_FRM_RET_FND_RFI_CMTD   IN NUMBER DEFAULT 0
   ,p_ANU_FRM_RET_FND_RFI_RUN    IN NUMBER DEFAULT 0
   ,p_ANU_FRM_RET_FND_RFI_PTD    IN NUMBER DEFAULT 0
   ,p_ANU_FRM_RET_FND_RFI_YTD    IN NUMBER DEFAULT 0
   ,p_ARR_PF_CMTD                IN NUMBER DEFAULT 0
   ,p_ARR_PF_CYTD                IN NUMBER DEFAULT 0
   ,p_ARR_PF_PTD                 IN NUMBER DEFAULT 0
   ,p_ARR_PF_YTD                 IN NUMBER DEFAULT 0
   ,p_ARR_RA_CMTD                IN NUMBER DEFAULT 0
   ,p_ARR_RA_CYTD                IN NUMBER DEFAULT 0
   ,p_ARR_RA_PTD                 IN NUMBER DEFAULT 0
   ,p_ARR_RA_YTD                 IN NUMBER DEFAULT 0
   ,p_AST_PRCHD_RVAL_NRFI_CMTD   IN NUMBER DEFAULT 0
   ,p_AST_PRCHD_RVAL_NRFI_CYTD   IN NUMBER DEFAULT 0
   ,p_AST_PRCHD_RVAL_NRFI_RUN    IN NUMBER DEFAULT 0
   ,p_AST_PRCHD_RVAL_NRFI_PTD    IN NUMBER DEFAULT 0
   ,p_AST_PRCHD_RVAL_NRFI_YTD    IN NUMBER DEFAULT 0
   ,p_AST_PRCHD_RVAL_RFI_CMTD    IN NUMBER DEFAULT 0
   ,p_AST_PRCHD_RVAL_RFI_CYTD    IN NUMBER DEFAULT 0
   ,p_AST_PRCHD_RVAL_RFI_RUN     IN NUMBER DEFAULT 0
   ,p_AST_PRCHD_RVAL_RFI_PTD     IN NUMBER DEFAULT 0
   ,p_AST_PRCHD_RVAL_RFI_YTD     IN NUMBER DEFAULT 0
   ,p_BP_CMTD                    IN NUMBER DEFAULT 0
   ,p_BP_PTD                     IN NUMBER DEFAULT 0
   ,p_BP_YTD                     IN NUMBER DEFAULT 0
   ,p_BUR_AND_SCH_NRFI_CMTD      IN NUMBER DEFAULT 0
   ,p_BUR_AND_SCH_NRFI_CYTD      IN NUMBER DEFAULT 0
   ,p_BUR_AND_SCH_NRFI_RUN       IN NUMBER DEFAULT 0
   ,p_BUR_AND_SCH_NRFI_PTD       IN NUMBER DEFAULT 0
   ,p_BUR_AND_SCH_NRFI_YTD       IN NUMBER DEFAULT 0
   ,p_BUR_AND_SCH_RFI_CMTD       IN NUMBER DEFAULT 0
   ,p_BUR_AND_SCH_RFI_CYTD       IN NUMBER DEFAULT 0
   ,p_BUR_AND_SCH_RFI_RUN        IN NUMBER DEFAULT 0
   ,p_BUR_AND_SCH_RFI_PTD        IN NUMBER DEFAULT 0
   ,p_BUR_AND_SCH_RFI_YTD        IN NUMBER DEFAULT 0
   ,p_COMM_NRFI_CMTD             IN NUMBER DEFAULT 0
   ,p_COMM_NRFI_CYTD             IN NUMBER DEFAULT 0
   ,p_COMM_NRFI_RUN              IN NUMBER DEFAULT 0
   ,p_COMM_NRFI_PTD              IN NUMBER DEFAULT 0
   ,p_COMM_NRFI_YTD              IN NUMBER DEFAULT 0
   ,p_COMM_RFI_CMTD              IN NUMBER DEFAULT 0
   ,p_COMM_RFI_CYTD              IN NUMBER DEFAULT 0
   ,p_COMM_RFI_RUN               IN NUMBER DEFAULT 0
   ,p_COMM_RFI_PTD               IN NUMBER DEFAULT 0
   ,p_COMM_RFI_YTD               IN NUMBER DEFAULT 0
   ,p_COMP_ALL_NRFI_CMTD         IN NUMBER DEFAULT 0
   ,p_COMP_ALL_NRFI_CYTD         IN NUMBER DEFAULT 0
   ,p_COMP_ALL_NRFI_RUN          IN NUMBER DEFAULT 0
   ,p_COMP_ALL_NRFI_PTD          IN NUMBER DEFAULT 0
   ,p_COMP_ALL_NRFI_YTD          IN NUMBER DEFAULT 0
   ,p_COMP_ALL_RFI_CMTD          IN NUMBER DEFAULT 0
   ,p_COMP_ALL_RFI_CYTD          IN NUMBER DEFAULT 0
   ,p_COMP_ALL_RFI_RUN           IN NUMBER DEFAULT 0
   ,p_COMP_ALL_RFI_PTD           IN NUMBER DEFAULT 0
   ,p_COMP_ALL_RFI_YTD           IN NUMBER DEFAULT 0
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;

BEGIN
-- Balances
   bal_AB_NRFI_CMTD               := p_AB_NRFI_CMTD;
   bal_AB_NRFI_RUN                := p_AB_NRFI_RUN;
   bal_AB_NRFI_PTD                := p_AB_NRFI_PTD;
   bal_AB_NRFI_YTD                := p_AB_NRFI_YTD;
   bal_AB_RFI_CMTD                := p_AB_RFI_CMTD;
   bal_AB_RFI_RUN                 := p_AB_RFI_RUN;
   bal_AB_RFI_PTD                 := p_AB_RFI_PTD;
   bal_AB_RFI_YTD                 := p_AB_RFI_YTD;
   bal_AC_NRFI_RUN                := p_AC_NRFI_RUN;
   bal_AC_NRFI_PTD                := p_AC_NRFI_PTD;
   bal_AC_NRFI_YTD                := p_AC_NRFI_YTD;
   bal_AC_RFI_RUN                 := p_AC_RFI_RUN;
   bal_AC_RFI_PTD                 := p_AC_RFI_PTD;
   bal_AC_RFI_YTD                 := p_AC_RFI_YTD;
   bal_ANN_PF_CMTD                := p_ANN_PF_CMTD;
   bal_ANN_PF_RUN                 := p_ANN_PF_RUN;
   bal_ANN_PF_PTD                 := p_ANN_PF_PTD;
   bal_ANN_PF_YTD                 := p_ANN_PF_YTD;
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

   RETURN l_Dum;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal1_01032000: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal1_01032000;


-- Function to Initialise Globals - Balance Values
-- Second Section
FUNCTION ZaTxBal2_01032000(
-- Balances
    p_CUR_PF_CMTD                 IN NUMBER DEFAULT 0
   ,p_CUR_PF_CYTD                 IN NUMBER DEFAULT 0
   ,p_CUR_PF_RUN                  IN NUMBER DEFAULT 0
   ,p_CUR_PF_PTD                  IN NUMBER DEFAULT 0
   ,p_CUR_PF_YTD                  IN NUMBER DEFAULT 0
   ,p_CUR_RA_CMTD                 IN NUMBER DEFAULT 0
   ,p_CUR_RA_CYTD                 IN NUMBER DEFAULT 0
   ,p_CUR_RA_RUN                  IN NUMBER DEFAULT 0
   ,p_CUR_RA_PTD                  IN NUMBER DEFAULT 0
   ,p_CUR_RA_YTD                  IN NUMBER DEFAULT 0
   ,p_ENT_ALL_NRFI_CMTD           IN NUMBER DEFAULT 0
   ,p_ENT_ALL_NRFI_CYTD           IN NUMBER DEFAULT 0
   ,p_ENT_ALL_NRFI_RUN            IN NUMBER DEFAULT 0
   ,p_ENT_ALL_NRFI_PTD            IN NUMBER DEFAULT 0
   ,p_ENT_ALL_NRFI_YTD            IN NUMBER DEFAULT 0
   ,p_ENT_ALL_RFI_CMTD            IN NUMBER DEFAULT 0
   ,p_ENT_ALL_RFI_CYTD            IN NUMBER DEFAULT 0
   ,p_ENT_ALL_RFI_RUN             IN NUMBER DEFAULT 0
   ,p_ENT_ALL_RFI_PTD             IN NUMBER DEFAULT 0
   ,p_ENT_ALL_RFI_YTD             IN NUMBER DEFAULT 0
   ,p_EXC_ARR_PEN_ITD             IN NUMBER DEFAULT 0
   ,p_EXC_ARR_PEN_PTD             IN NUMBER DEFAULT 0
   ,p_EXC_ARR_PEN_YTD             IN NUMBER DEFAULT 0
   ,p_EXC_ARR_RA_ITD              IN NUMBER DEFAULT 0
   ,p_EXC_ARR_RA_PTD              IN NUMBER DEFAULT 0
   ,p_EXC_ARR_RA_YTD              IN NUMBER DEFAULT 0
   ,p_FREE_ACCOM_NRFI_CMTD        IN NUMBER DEFAULT 0
   ,p_FREE_ACCOM_NRFI_CYTD        IN NUMBER DEFAULT 0
   ,p_FREE_ACCOM_NRFI_RUN         IN NUMBER DEFAULT 0
   ,p_FREE_ACCOM_NRFI_PTD         IN NUMBER DEFAULT 0
   ,p_FREE_ACCOM_NRFI_YTD         IN NUMBER DEFAULT 0
   ,p_FREE_ACCOM_RFI_CMTD         IN NUMBER DEFAULT 0
   ,p_FREE_ACCOM_RFI_CYTD         IN NUMBER DEFAULT 0
   ,p_FREE_ACCOM_RFI_RUN          IN NUMBER DEFAULT 0
   ,p_FREE_ACCOM_RFI_PTD          IN NUMBER DEFAULT 0
   ,p_FREE_ACCOM_RFI_YTD          IN NUMBER DEFAULT 0
   ,p_FREE_SERV_NRFI_CMTD         IN NUMBER DEFAULT 0
   ,p_FREE_SERV_NRFI_CYTD         IN NUMBER DEFAULT 0
   ,p_FREE_SERV_NRFI_RUN          IN NUMBER DEFAULT 0
   ,p_FREE_SERV_NRFI_PTD          IN NUMBER DEFAULT 0
   ,p_FREE_SERV_NRFI_YTD          IN NUMBER DEFAULT 0
   ,p_FREE_SERV_RFI_CMTD          IN NUMBER DEFAULT 0
   ,p_FREE_SERV_RFI_CYTD          IN NUMBER DEFAULT 0
   ,p_FREE_SERV_RFI_RUN           IN NUMBER DEFAULT 0
   ,p_FREE_SERV_RFI_PTD           IN NUMBER DEFAULT 0
   ,p_FREE_SERV_RFI_YTD           IN NUMBER DEFAULT 0
   ,p_LOW_LOANS_NRFI_CMTD         IN NUMBER DEFAULT 0
   ,p_LOW_LOANS_NRFI_CYTD         IN NUMBER DEFAULT 0
   ,p_LOW_LOANS_NRFI_RUN          IN NUMBER DEFAULT 0
   ,p_LOW_LOANS_NRFI_PTD          IN NUMBER DEFAULT 0
   ,p_LOW_LOANS_NRFI_YTD          IN NUMBER DEFAULT 0
   ,p_LOW_LOANS_RFI_CMTD          IN NUMBER DEFAULT 0
   ,p_LOW_LOANS_RFI_CYTD          IN NUMBER DEFAULT 0
   ,p_LOW_LOANS_RFI_RUN           IN NUMBER DEFAULT 0
   ,p_LOW_LOANS_RFI_PTD           IN NUMBER DEFAULT 0
   ,p_LOW_LOANS_RFI_YTD           IN NUMBER DEFAULT 0
   ,p_MLS_AND_VOUCH_NRFI_CMTD     IN NUMBER DEFAULT 0
   ,p_MLS_AND_VOUCH_NRFI_CYTD     IN NUMBER DEFAULT 0
   ,p_MLS_AND_VOUCH_NRFI_RUN      IN NUMBER DEFAULT 0
   ,p_MLS_AND_VOUCH_NRFI_PTD      IN NUMBER DEFAULT 0
   ,p_MLS_AND_VOUCH_NRFI_YTD      IN NUMBER DEFAULT 0
   ,p_MLS_AND_VOUCH_RFI_CMTD      IN NUMBER DEFAULT 0
   ,p_MLS_AND_VOUCH_RFI_CYTD      IN NUMBER DEFAULT 0
   ,p_MLS_AND_VOUCH_RFI_RUN       IN NUMBER DEFAULT 0
   ,p_MLS_AND_VOUCH_RFI_PTD       IN NUMBER DEFAULT 0
   ,p_MLS_AND_VOUCH_RFI_YTD       IN NUMBER DEFAULT 0
   ,p_MED_CONTR_CMTD              IN NUMBER DEFAULT 0
   ,p_MED_CONTR_CYTD              IN NUMBER DEFAULT 0
   ,p_MED_CONTR_RUN               IN NUMBER DEFAULT 0
   ,p_MED_CONTR_PTD               IN NUMBER DEFAULT 0
   ,p_MED_CONTR_YTD               IN NUMBER DEFAULT 0
   ,p_MED_PAID_NRFI_CMTD          IN NUMBER DEFAULT 0
   ,p_MED_PAID_NRFI_CYTD          IN NUMBER DEFAULT 0
   ,p_MED_PAID_NRFI_RUN           IN NUMBER DEFAULT 0
   ,p_MED_PAID_NRFI_PTD           IN NUMBER DEFAULT 0
   ,p_MED_PAID_NRFI_YTD           IN NUMBER DEFAULT 0
   ,p_MED_PAID_RFI_CMTD           IN NUMBER DEFAULT 0
   ,p_MED_PAID_RFI_CYTD           IN NUMBER DEFAULT 0
   ,p_MED_PAID_RFI_RUN            IN NUMBER DEFAULT 0
   ,p_MED_PAID_RFI_PTD            IN NUMBER DEFAULT 0
   ,p_MED_PAID_RFI_YTD            IN NUMBER DEFAULT 0
   ,p_NET_PAY_RUN                 IN NUMBER DEFAULT 0
   ,p_NET_TXB_INC_CMTD            IN NUMBER DEFAULT 0
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;

BEGIN
-- Balances
   bal_CUR_PF_CMTD                := p_CUR_PF_CMTD;
   bal_CUR_PF_CYTD                := p_CUR_PF_CYTD;
   bal_CUR_PF_RUN                 := p_CUR_PF_RUN;
   bal_CUR_PF_PTD                 := p_CUR_PF_PTD;
   bal_CUR_PF_YTD                 := p_CUR_PF_YTD;
   bal_CUR_RA_CMTD                := p_CUR_RA_CMTD;
   bal_CUR_RA_CYTD                := p_CUR_RA_CYTD;
   bal_CUR_RA_RUN                 := p_CUR_RA_RUN;
   bal_CUR_RA_PTD                 := p_CUR_RA_PTD;
   bal_CUR_RA_YTD                 := p_CUR_RA_YTD;
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

   RETURN l_Dum;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal2_01032000: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal2_01032000;

-- Function to Initialise Globals - Balance Values
-- Third Section
FUNCTION ZaTxBal3_01032000(
-- Balances
    p_OTHER_TXB_ALL_NRFI_CMTD     IN NUMBER DEFAULT 0
   ,p_OTHER_TXB_ALL_NRFI_CYTD     IN NUMBER DEFAULT 0
   ,p_OTHER_TXB_ALL_NRFI_RUN      IN NUMBER DEFAULT 0
   ,p_OTHER_TXB_ALL_NRFI_PTD      IN NUMBER DEFAULT 0
   ,p_OTHER_TXB_ALL_NRFI_YTD      IN NUMBER DEFAULT 0
   ,p_OTHER_TXB_ALL_RFI_CMTD      IN NUMBER DEFAULT 0
   ,p_OTHER_TXB_ALL_RFI_CYTD      IN NUMBER DEFAULT 0
   ,p_OTHER_TXB_ALL_RFI_RUN       IN NUMBER DEFAULT 0
   ,p_OTHER_TXB_ALL_RFI_PTD       IN NUMBER DEFAULT 0
   ,p_OTHER_TXB_ALL_RFI_YTD       IN NUMBER DEFAULT 0
   ,p_OVTM_NRFI_CMTD              IN NUMBER DEFAULT 0
   ,p_OVTM_NRFI_CYTD              IN NUMBER DEFAULT 0
   ,p_OVTM_NRFI_RUN               IN NUMBER DEFAULT 0
   ,p_OVTM_NRFI_PTD               IN NUMBER DEFAULT 0
   ,p_OVTM_NRFI_YTD               IN NUMBER DEFAULT 0
   ,p_OVTM_RFI_CMTD               IN NUMBER DEFAULT 0
   ,p_OVTM_RFI_CYTD               IN NUMBER DEFAULT 0
   ,p_OVTM_RFI_RUN                IN NUMBER DEFAULT 0
   ,p_OVTM_RFI_PTD                IN NUMBER DEFAULT 0
   ,p_OVTM_RFI_YTD                IN NUMBER DEFAULT 0
   ,p_PAYE_YTD                    IN NUMBER DEFAULT 0
   ,p_PYM_DBT_NRFI_CMTD           IN NUMBER DEFAULT 0
   ,p_PYM_DBT_NRFI_CYTD           IN NUMBER DEFAULT 0
   ,p_PYM_DBT_NRFI_RUN            IN NUMBER DEFAULT 0
   ,p_PYM_DBT_NRFI_PTD            IN NUMBER DEFAULT 0
   ,p_PYM_DBT_NRFI_YTD            IN NUMBER DEFAULT 0
   ,p_PYM_DBT_RFI_CMTD            IN NUMBER DEFAULT 0
   ,p_PYM_DBT_RFI_CYTD            IN NUMBER DEFAULT 0
   ,p_PYM_DBT_RFI_RUN             IN NUMBER DEFAULT 0
   ,p_PYM_DBT_RFI_PTD             IN NUMBER DEFAULT 0
   ,p_PYM_DBT_RFI_YTD             IN NUMBER DEFAULT 0
   ,p_PO_NRFI_CMTD                IN NUMBER DEFAULT 0
   ,p_PO_NRFI_RUN                 IN NUMBER DEFAULT 0
   ,p_PO_NRFI_PTD                 IN NUMBER DEFAULT 0
   ,p_PO_NRFI_YTD                 IN NUMBER DEFAULT 0
   ,p_PO_RFI_CMTD                 IN NUMBER DEFAULT 0
   ,p_PO_RFI_RUN                  IN NUMBER DEFAULT 0
   ,p_PO_RFI_PTD                  IN NUMBER DEFAULT 0
   ,p_PO_RFI_YTD                  IN NUMBER DEFAULT 0
   ,p_PRCH_ANU_TXB_NRFI_CMTD      IN NUMBER DEFAULT 0
   ,p_PRCH_ANU_TXB_NRFI_RUN       IN NUMBER DEFAULT 0
   ,p_PRCH_ANU_TXB_NRFI_PTD       IN NUMBER DEFAULT 0
   ,p_PRCH_ANU_TXB_NRFI_YTD       IN NUMBER DEFAULT 0
   ,p_PRCH_ANU_TXB_RFI_CMTD       IN NUMBER DEFAULT 0
   ,p_PRCH_ANU_TXB_RFI_RUN        IN NUMBER DEFAULT 0
   ,p_PRCH_ANU_TXB_RFI_PTD        IN NUMBER DEFAULT 0
   ,p_PRCH_ANU_TXB_RFI_YTD        IN NUMBER DEFAULT 0
   ,p_RGT_AST_NRFI_CMTD           IN NUMBER DEFAULT 0
   ,p_RGT_AST_NRFI_CYTD           IN NUMBER DEFAULT 0
   ,p_RGT_AST_NRFI_RUN            IN NUMBER DEFAULT 0
   ,p_RGT_AST_NRFI_PTD            IN NUMBER DEFAULT 0
   ,p_RGT_AST_NRFI_YTD            IN NUMBER DEFAULT 0
   ,p_RGT_AST_RFI_CMTD            IN NUMBER DEFAULT 0
   ,p_RGT_AST_RFI_CYTD            IN NUMBER DEFAULT 0
   ,p_RGT_AST_RFI_RUN             IN NUMBER DEFAULT 0
   ,p_RGT_AST_RFI_PTD             IN NUMBER DEFAULT 0
   ,p_RGT_AST_RFI_YTD             IN NUMBER DEFAULT 0
   ,p_SITE_YTD                    IN NUMBER DEFAULT 0
   ,p_TAX_YTD                     IN NUMBER DEFAULT 0
   ,p_TX_ON_AB_PTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_AB_YTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_AP_RUN                IN NUMBER DEFAULT 0
   ,p_TX_ON_AP_PTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_AP_YTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_BP_PTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_BP_YTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_TA_PTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_TA_YTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_FB_PTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_FB_YTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_NI_PTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_NI_YTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_PO_PTD                IN NUMBER DEFAULT 0
   ,p_TX_ON_PO_YTD                IN NUMBER DEFAULT 0
   ,p_TXB_AP_NRFI_CMTD            IN NUMBER DEFAULT 0
   ,p_TXB_AP_NRFI_RUN             IN NUMBER DEFAULT 0
   ,p_TXB_AP_NRFI_PTD             IN NUMBER DEFAULT 0
   ,p_TXB_AP_NRFI_YTD             IN NUMBER DEFAULT 0
   ,p_TXB_AP_RFI_CMTD             IN NUMBER DEFAULT 0
   ,p_TXB_AP_RFI_RUN              IN NUMBER DEFAULT 0
   ,p_TXB_AP_RFI_PTD              IN NUMBER DEFAULT 0
   ,p_TXB_AP_RFI_YTD              IN NUMBER DEFAULT 0
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;

BEGIN
-- Balances
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

   RETURN l_Dum;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(801, 'ZaTxBal3_01032000: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal3_01032000;

-- Function to Initialise Globals - Balance Values
-- Fourth Section
FUNCTION ZaTxBal4_01032000(
-- Balances
    p_TXB_INC_NRFI_CMTD           IN NUMBER DEFAULT 0
   ,p_TXB_INC_NRFI_CYTD           IN NUMBER DEFAULT 0
   ,p_TXB_INC_NRFI_RUN            IN NUMBER DEFAULT 0
   ,p_TXB_INC_NRFI_PTD            IN NUMBER DEFAULT 0
   ,p_TXB_INC_NRFI_YTD            IN NUMBER DEFAULT 0
   ,p_TXB_INC_RFI_CMTD            IN NUMBER DEFAULT 0
   ,p_TXB_INC_RFI_CYTD            IN NUMBER DEFAULT 0
   ,p_TXB_INC_RFI_RUN             IN NUMBER DEFAULT 0
   ,p_TXB_INC_RFI_PTD             IN NUMBER DEFAULT 0
   ,p_TXB_INC_RFI_YTD             IN NUMBER DEFAULT 0
   ,p_TXB_PEN_NRFI_CMTD           IN NUMBER DEFAULT 0
   ,p_TXB_PEN_NRFI_CYTD           IN NUMBER DEFAULT 0
   ,p_TXB_PEN_NRFI_RUN            IN NUMBER DEFAULT 0
   ,p_TXB_PEN_NRFI_PTD            IN NUMBER DEFAULT 0
   ,p_TXB_PEN_NRFI_YTD            IN NUMBER DEFAULT 0
   ,p_TXB_PEN_RFI_CMTD            IN NUMBER DEFAULT 0
   ,p_TXB_PEN_RFI_CYTD            IN NUMBER DEFAULT 0
   ,p_TXB_PEN_RFI_RUN             IN NUMBER DEFAULT 0
   ,p_TXB_PEN_RFI_PTD             IN NUMBER DEFAULT 0
   ,p_TXB_PEN_RFI_YTD             IN NUMBER DEFAULT 0
   ,p_TEL_ALL_NRFI_CMTD           IN NUMBER DEFAULT 0
   ,p_TEL_ALL_NRFI_CYTD           IN NUMBER DEFAULT 0
   ,p_TEL_ALL_NRFI_RUN            IN NUMBER DEFAULT 0
   ,p_TEL_ALL_NRFI_PTD            IN NUMBER DEFAULT 0
   ,p_TEL_ALL_NRFI_YTD            IN NUMBER DEFAULT 0
   ,p_TEL_ALL_RFI_CMTD            IN NUMBER DEFAULT 0
   ,p_TEL_ALL_RFI_CYTD            IN NUMBER DEFAULT 0
   ,p_TEL_ALL_RFI_RUN             IN NUMBER DEFAULT 0
   ,p_TEL_ALL_RFI_PTD             IN NUMBER DEFAULT 0
   ,p_TEL_ALL_RFI_YTD             IN NUMBER DEFAULT 0
   ,p_TOOL_ALL_NRFI_CMTD          IN NUMBER DEFAULT 0
   ,p_TOOL_ALL_NRFI_CYTD          IN NUMBER DEFAULT 0
   ,p_TOOL_ALL_NRFI_RUN           IN NUMBER DEFAULT 0
   ,p_TOOL_ALL_NRFI_PTD           IN NUMBER DEFAULT 0
   ,p_TOOL_ALL_NRFI_YTD           IN NUMBER DEFAULT 0
   ,p_TOOL_ALL_RFI_CMTD           IN NUMBER DEFAULT 0
   ,p_TOOL_ALL_RFI_CYTD           IN NUMBER DEFAULT 0
   ,p_TOOL_ALL_RFI_RUN            IN NUMBER DEFAULT 0
   ,p_TOOL_ALL_RFI_PTD            IN NUMBER DEFAULT 0
   ,p_TOOL_ALL_RFI_YTD            IN NUMBER DEFAULT 0
   ,p_TOT_INC_PTD                 IN NUMBER DEFAULT 0
   ,p_TOT_INC_YTD                 IN NUMBER DEFAULT 0
   ,p_TOT_NRFI_AN_INC_CMTD        IN NUMBER DEFAULT 0
   ,p_TOT_NRFI_AN_INC_CYTD        IN NUMBER DEFAULT 0
   ,p_TOT_NRFI_AN_INC_RUN         IN NUMBER DEFAULT 0
   ,p_TOT_NRFI_AN_INC_PTD         IN NUMBER DEFAULT 0
   ,p_TOT_NRFI_AN_INC_YTD         IN NUMBER DEFAULT 0
   ,p_TOT_NRFI_INC_CMTD           IN NUMBER DEFAULT 0
   ,p_TOT_NRFI_INC_CYTD           IN NUMBER DEFAULT 0
   ,p_TOT_NRFI_INC_RUN            IN NUMBER DEFAULT 0
   ,p_TOT_NRFI_INC_PTD            IN NUMBER DEFAULT 0
   ,p_TOT_NRFI_INC_YTD            IN NUMBER DEFAULT 0
   ,p_TOT_RFI_AN_INC_CMTD         IN NUMBER DEFAULT 0
   ,p_TOT_RFI_AN_INC_CYTD         IN NUMBER DEFAULT 0
   ,p_TOT_RFI_AN_INC_RUN          IN NUMBER DEFAULT 0
   ,p_TOT_RFI_AN_INC_PTD          IN NUMBER DEFAULT 0
   ,p_TOT_RFI_AN_INC_YTD          IN NUMBER DEFAULT 0
   ,p_TOT_RFI_INC_CMTD            IN NUMBER DEFAULT 0
   ,p_TOT_RFI_INC_CYTD            IN NUMBER DEFAULT 0
   ,p_TOT_RFI_INC_RUN             IN NUMBER DEFAULT 0
   ,p_TOT_RFI_INC_PTD             IN NUMBER DEFAULT 0
   ,p_TOT_RFI_INC_YTD             IN NUMBER DEFAULT 0
   ,p_TOT_SEA_WRK_DYS_WRK_YTD     IN NUMBER DEFAULT 0
   ,p_TOT_TXB_INC_ITD             IN NUMBER DEFAULT 0
   ,p_TA_NRFI_CMTD                IN NUMBER DEFAULT 0
   ,p_TA_NRFI_CYTD                IN NUMBER DEFAULT 0
   ,p_TA_NRFI_PTD                 IN NUMBER DEFAULT 0
   ,p_TA_NRFI_YTD                 IN NUMBER DEFAULT 0
   ,p_TA_RFI_CMTD                 IN NUMBER DEFAULT 0
   ,p_TA_RFI_CYTD                 IN NUMBER DEFAULT 0
   ,p_TA_RFI_PTD                  IN NUMBER DEFAULT 0
   ,p_TA_RFI_YTD                  IN NUMBER DEFAULT 0
   ,p_USE_VEH_NRFI_CMTD           IN NUMBER DEFAULT 0
   ,p_USE_VEH_NRFI_CYTD           IN NUMBER DEFAULT 0
   ,p_USE_VEH_NRFI_RUN            IN NUMBER DEFAULT 0
   ,p_USE_VEH_NRFI_PTD            IN NUMBER DEFAULT 0
   ,p_USE_VEH_NRFI_YTD            IN NUMBER DEFAULT 0
   ,p_USE_VEH_RFI_CMTD            IN NUMBER DEFAULT 0
   ,p_USE_VEH_RFI_CYTD            IN NUMBER DEFAULT 0
   ,p_USE_VEH_RFI_RUN             IN NUMBER DEFAULT 0
   ,p_USE_VEH_RFI_PTD             IN NUMBER DEFAULT 0
   ,p_USE_VEH_RFI_YTD             IN NUMBER DEFAULT 0
   ) RETURN NUMBER
AS
   l_Dum NUMBER := 1;

BEGIN
-- Balances
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
      hr_utility.set_message(801, 'ZaTxBal4_01032000: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
END ZaTxBal4_01032000;

-- Main Tax Function
-- Called from Fast Formula
FUNCTION ZaTx_01032000(
/*  PARAMETERS */
-- Contexts
    ASSIGNMENT_ACTION_ID IN NUMBER
   ,ASSIGNMENT_ID IN NUMBER
   ,PAYROLL_ACTION_ID IN NUMBER
   ,PAYROLL_ID IN NUMBER
   -- Out Parameters
   , p_LibWrn OUT NOCOPY VARCHAR2
   , p_LibFpNI OUT NOCOPY NUMBER
   , p_LibFpFB OUT NOCOPY NUMBER
   , p_LibFpTA OUT NOCOPY NUMBER
   , p_LibFpBP OUT NOCOPY NUMBER
   , p_LibFpAB OUT NOCOPY NUMBER
   , p_LibFpAP OUT NOCOPY NUMBER
   , p_LibFpPO OUT NOCOPY NUMBER
   , p_PayValue OUT NOCOPY NUMBER
   , p_PayeVal OUT NOCOPY NUMBER
   , p_SiteVal OUT NOCOPY NUMBER
   , p_It3Ind  OUT NOCOPY NUMBER
   , p_PfUpdFig OUT NOCOPY NUMBER
   , p_RaUpdFig OUT NOCOPY NUMBER
   , p_OUpdFig OUT NOCOPY NUMBER
   , p_NtiUpdFig OUT NOCOPY NUMBER
   , p_OvrWrn OUT NOCOPY VARCHAR2
   )RETURN NUMBER
AS
-- Variables
--
   l_Dum NUMBER := 1;


BEGIN
-- Set hr_utility globals if debugging
--
--   py_za_tx_utl_01032000.g_HrTraceEnabled  := TRUE;
--   py_za_tx_utl_01032000.g_HrTracePipeName := 'ZATAX';

-- Call hr_utility start procedure
   py_za_tx_utl_01032000.StartHrTrace;

-- Setup Trace Header Info
   py_za_tx_utl_01032000.WriteHrTrace(' ');
   py_za_tx_utl_01032000.WriteHrTrace(' ');
   py_za_tx_utl_01032000.WriteHrTrace(' ');
   py_za_tx_utl_01032000.WriteHrTrace('------------------------------------------------------------');
   py_za_tx_utl_01032000.WriteHrTrace('-- Start of Trace File');
   py_za_tx_utl_01032000.WriteHrTrace('------------------------------------------------------------');
   py_za_tx_utl_01032000.WriteHrTrace(' ');
   py_za_tx_utl_01032000.WriteHrTrace('Processing Assignment ID :'||to_char(ASSIGNMENT_ID));
   py_za_tx_utl_01032000.WriteHrTrace('Assignment Action ID     :'||to_char(ASSIGNMENT_ACTION_ID));
   py_za_tx_utl_01032000.WriteHrTrace('Payroll Action ID        :'||to_char(PAYROLL_ACTION_ID));
   py_za_tx_utl_01032000.WriteHrTrace('Payroll ID               :'||to_char(PAYROLL_ID));
   py_za_tx_utl_01032000.WriteHrTrace(' ');
   py_za_tx_utl_01032000.WriteHrTrace('------------------------------------------------------------');
   py_za_tx_utl_01032000.WriteHrTrace(' ');

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',1);

-- Initialise Package Globals
-- Contexts
   con_ASG_ACT_ID := ASSIGNMENT_ACTION_ID;
   con_ASG_ID     := ASSIGNMENT_ID;
   con_PRL_ACT_ID := PAYROLL_ACTION_ID;
   con_PRL_ID     := PAYROLL_ID;

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',2);

-- Date Effective Tax Status Validation
--
   IF dbi_TX_STA IN ('J','K','L') THEN
      IF xpt_Msg = 'No Error' THEN
         xpt_Msg := 'PY_ZA_TX_STATE_AUG';
      END IF;
      RAISE xpt_E;
   END IF;

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
   */
   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',3);

-- C = Directive Amount
--
   IF dbi_TX_STA = 'C' THEN
      IF trc_OvrTxCalc AND (trc_OvrTyp = 'S' OR trc_OvrTyp = 'P') THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',4);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',5);
            xpt_Msg := 'PY_ZA_TX_OVR_TX_STATE_C';
         END IF;
         RAISE xpt_E;
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',6);
      ELSIF trc_OvrTxCalc AND trc_OvrTyp = 'V' THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',7);
         trc_CalTyp := 'OvrCalc';
         trc_OvrWrn := 'WARNING: Tax Override - Total Tax Value: '||to_char(trc_LibFpNI + trc_LibFpAP);
      -- Check Directive Number First
      ELSIF dbi_TX_DIR_NUM = 'NULL' THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',8);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',9);
            xpt_Msg := 'PY_ZA_TX_DIR_NUM';
         END IF;
         RAISE xpt_E;
      -- Check that directive value is filled in
      ELSIF dbi_TX_DIR_VAL = -1 THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',10);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',11);
            xpt_Msg := 'PY_ZA_TX_DIR_MONT';
         END IF;
         RAISE xpt_E;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',12);
         trc_CalTyp := 'NoCalc';
         -- Liability = entered value
         trc_LibFpNI := dbi_TX_DIR_VAL;
         -- Standard NetPay Validation
         py_za_tx_utl_01032000.NpVal;
      END IF;
-- D = Directive Percentage
--
   ELSIF dbi_TX_STA = 'D' THEN
      IF trc_OvrTxCalc AND trc_OvrTyp = 'S' THEN
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',13);
            xpt_Msg := 'PY_ZA_TX_OVR_TX_STATE_DEF';
         END IF;
         RAISE xpt_E;
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',14);
      ELSIF trc_OvrTxCalc AND trc_OvrTyp = 'V' THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',15);
         trc_CalTyp := 'OvrCalc';
         trc_OvrWrn := 'WARNING: Tax Override - Total Tax Value: '||to_char(trc_LibFpNI + trc_LibFpAP);
      ELSE
         IF trc_OvrTxCalc AND trc_OvrTyp = 'P' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',16);
            trc_OvrWrn := 'WARNING: Tax Override - '||to_char(trc_OvrPrc)||' Percent';
            -- Percentage taken into account in py_za_tx_utl_01032000.TaxLiability
         END IF;
      -- Check Directive Number First
         IF dbi_TX_DIR_NUM = 'NULL' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',17);
            IF xpt_Msg = 'No Error' THEN
               hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',18);
               xpt_Msg := 'PY_ZA_TX_DIR_NUM';
            END IF;
            RAISE xpt_E;
         -- Check that directive value is filled in
         ELSIF dbi_TX_DIR_VAL = -1 THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',19);
            IF xpt_Msg = 'No Error' THEN
               hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',20);
               xpt_Msg := 'PY_ZA_TX_DIR_PERC';
            END IF;
            RAISE xpt_E;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',21);
            DirCalc;
         END IF;
      END IF;
-- E = Close Corporation
-- F = Temporary Worker/Student
-- J = Personal Service Company
-- L = Labour Broker
--
   ELSIF dbi_TX_STA IN ('E','F','J','L') THEN
      IF trc_OvrTxCalc AND trc_OvrTyp = 'S' THEN
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',22);
            xpt_Msg := 'PY_ZA_TX_OVR_TX_STATE_DEF';
         END IF;
         RAISE xpt_E;
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',23);
      ELSIF trc_OvrTxCalc AND trc_OvrTyp = 'V' THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',24);
         trc_CalTyp := 'OvrCalc';
         trc_OvrWrn := 'WARNING: Tax Override - Total Tax Value: '||to_char(trc_LibFpNI + trc_LibFpAP);
      ELSE
         IF trc_OvrTxCalc AND trc_OvrTyp = 'P' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',25);
            trc_OvrWrn := 'WARNING: Tax Override - '||to_char(trc_OvrPrc)||' Percent';
            -- Percentage taken into account in py_za_tx_utl_01032000.TaxLiability
         END IF;
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',26);
      -- Simply Execute the Directive Calculation
         DirCalc;
      END IF;
-- G = Seasonal Worker
--
   ELSIF dbi_TX_STA = 'G' THEN
      IF trc_OvrTxCalc AND (trc_OvrTyp = 'S' OR trc_OvrTyp = 'P') THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',27);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',28);
            xpt_Msg := 'PY_ZA_TX_OVR_TX_STATE_G';
         END IF;
         RAISE xpt_E;
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',29);
   -- Check that seasonal worker days worked is filled in
      ELSIF dbi_SEA_WRK_DYS_WRK = 0 THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',30);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',31);
            xpt_Msg := 'PY_ZA_TX_SEA_WRK_DYS';
         END IF;
         RAISE xpt_E;
      ELSE
         IF trc_OvrTxCalc AND trc_OvrTyp = 'V' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',32);
            trc_CalTyp := 'OvrCalc';
            trc_OvrWrn := 'WARNING: Tax Override - Total Tax Value: '||to_char(trc_LibFpNI + trc_LibFpAP);
            py_za_tx_utl_01032000.SetRebates;
         ELSE
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',33);
            SeaCalc;
         END IF;
      END IF;
-- A = Normal
-- B = Provisional
-- K = Personal Service Trust
--
   ELSIF dbi_TX_STA IN ('A','B','K') THEN
      IF trc_OvrTxCalc AND trc_OvrTyp = 'V' THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',34);
         trc_CalTyp := 'OvrCalc';
         trc_OvrWrn := 'WARNING: Tax Override - Total Tax Value: '||to_char(trc_LibFpNI + trc_LibFpAP);
         py_za_tx_utl_01032000.SetRebates;
      ELSIF trc_OvrTxCalc AND trc_OvrTyp = 'S' THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',35);
         trc_CalTyp := 'OvrCalc';
         trc_OvrWrn := 'WARNING: Tax Override - Forced Site Calculation';
         -- Force the Site Calculation
         SitCalc;
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',36);
      ELSE
         IF trc_OvrTxCalc AND trc_OvrTyp = 'P' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',37);
            trc_OvrWrn := 'WARNING: Tax Override - '||to_char(trc_OvrPrc)||' Percent';
            -- Percentage taken into account in py_za_tx_utl_01032000.TaxLiability
         END IF;

         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',38);
         IF py_za_tx_utl_01032000.LatePayPeriod THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',39);
            LteCalc;
         -- Is this a SITE Period?
         ELSIF py_za_tx_utl_01032000.EmpTermPrePeriod THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',40);
            SitCalc;
         ELSIF py_za_tx_utl_01032000.LstPeriod OR py_za_tx_utl_01032000.EmpTermInPeriod THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',41);
            IF py_za_tx_utl_01032000.PreErnPeriod THEN
               hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',42);
               YtdCalc;
            ELSE
               hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',43);
               SitCalc;
            END IF;
         ElSE
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',44);
         -- The employee has NOT been terminated!
            IF py_za_tx_utl_01032000.PreErnPeriod THEN
               hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',45);
               YtdCalc;
            ELSIF py_za_tx_utl_01032000.RetroInPrd THEN
               hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',46);
               SitCalc;
            ELSE
               hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',47);
               NorCalc;
            END IF;
         END IF;
      END IF;
-- H = Zero Tax
--
   ELSIF dbi_TX_STA = 'H' THEN
      IF trc_OvrTxCalc THEN
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',48);
         IF xpt_Msg = 'No Error' THEN
            hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',49);
            xpt_Msg := 'PY_ZA_TX_OVR_TX_STATE_H';
         END IF;
         RAISE xpt_E;
      ELSE
         hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',50);
         trc_LibFpNI := 0;
         trc_LibFpFB := 0;
         trc_LibFpTA := 0;
         trc_LibFpBP := 0;
         trc_LibFpAB := 0;
         trc_LibFpAP := 0;
         trc_LibFpPO := 0;
      END IF;
   ELSE
      hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',51);
      hr_utility.set_message(801, 'ERROR: Invalid Tax Status');
      hr_utility.raise_error;
   END IF;

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',52);

-- Post Calculation Steps
--
   py_za_tx_utl_01032000.SitPaySplit;

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',53);

-- Execute the Arrear Processing
--
   IF py_za_tx_utl_01032000.SitePeriod THEN
      hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',54);
      py_za_tx_utl_01032000.ArrearExcess;
   END IF;

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',55);

-- Calculate Net Taxable Income
--
   NetTxbIncCalc;

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',56);

-- Setup the Out Parameters
--
   -- Messages
   p_LibWrn := trc_LibWrn;

   -- Pay Values
   trc_PayValue :=
      ( trc_LibFpNI
      + trc_LibFpFB
      + trc_LibFpTA
      + trc_LibFpBP
      + trc_LibFpAB
      + trc_LibFpAP
      + trc_LibFpPO
      );

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',57);

   -- Tax On's
   p_LibFpNI  := trc_LibFpNI;
   p_LibFpFB  := trc_LibFpFB;
   p_LibFpTA  := trc_LibFpTA;
   p_LibFpBP  := trc_LibFpBP;
   p_LibFpAB  := trc_LibFpAB;
   p_LibFpAP  := trc_LibFpAP;
   p_LibFpPO  := trc_LibFpPO;
   p_PayValue := trc_PayValue;

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',58);

   -- Indicators, Splits and Updates
   --
   -- Override Indicator
   IF trc_OvrTxCalc THEN
      hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',59);
      -- Set Override Tax Value
      p_OvrWrn   := trc_OvrWrn;
   END IF;

   p_PayeVal   := trc_PayeVal;
   p_SiteVal   := trc_SiteVal;
   p_It3Ind    := trc_It3Ind;
   p_PfUpdFig  := trc_PfUpdFig;
   p_RaUpdFig  := trc_RaUpdFig;
   p_OUpdFig   := trc_OUpdFig;
   p_NtiUpdFig := trc_NtiUpdFig;

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',60);

-- Execute The Tax Trace
--
   py_za_tx_utl_01032000.Trace;

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',61);

-- Clear Globals
--
   py_za_tx_utl_01032000.ClearGlobals;

   hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',62);

-- End off Trace File
   py_za_tx_utl_01032000.WriteHrTrace('------------------------------------------------------------');
   py_za_tx_utl_01032000.WriteHrTrace('-- End of Trace File ');
   py_za_tx_utl_01032000.WriteHrTrace(' ');

-- Call hr_utility stop procedure
   py_za_tx_utl_01032000.StopHrTrace;

  --dbms_debug.debug_off;

   RETURN l_Dum;

EXCEPTION
   WHEN xpt_E  THEN
      hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',63);
      py_za_tx_utl_01032000.WriteHrTrace('xpt_Msg: '||xpt_Msg);
      py_za_tx_utl_01032000.StopHrTrace;
      hr_utility.set_message(801, xpt_Msg);
      py_za_tx_utl_01032000.ClearGlobals;
      hr_utility.raise_error;
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tx_01032000.ZaTx_01032000',64);
      py_za_tx_utl_01032000.WriteHrTrace('Sql error code: '||TO_CHAR(SQLCODE));
      py_za_tx_utl_01032000.WriteHrTrace('Sql error msg: '||SUBSTR(SQLERRM(SQLCODE), 1, 100));
      py_za_tx_utl_01032000.StopHrTrace;
      hr_utility.set_message(801, 'ZaTx_01032000: '||TO_CHAR(SQLCODE));
      py_za_tx_utl_01032000.ClearGlobals;
      hr_utility.raise_error;
END ZaTx_01032000;

END py_za_tx_01032000;


/
