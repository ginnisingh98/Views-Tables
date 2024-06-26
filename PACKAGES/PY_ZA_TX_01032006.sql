--------------------------------------------------------
--  DDL for Package PY_ZA_TX_01032006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_TX_01032006" AUTHID CURRENT_USER AS
/* $Header: pyzat007.pkh 120.0.12000000.2 2007/06/29 06:37:08 rpahune noship $ */
/* Copyright (c) Oracle Corporation 2005. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation Tax Module
   NAME
      py_za_tx_01032006.pkh

   DESCRIPTION
      This is the main tax package as used in the ZA Localisation Tax Module.
      The public functions in this package are not for client use and is
      only referenced by the tax formulae in the Application.

  PUBLIC FUNCTIONS
   ZaTxGlb_01032006
      This function is called from Oracle Applications Fast Formula.
      It passes all necessary global values to the main tax package.
   ZaTxDbi_01032006
      This function is called from Oracle Applications Fast Formula.
      It passes all necessary Application Database Items to the
      main tax package.
   ZaTxBal1_01032006
      This function is called from Oracle Applications Fast Formula.
      It passes the first group of balances to the main tax package.
   ZaTxBal2_01032006
      This function is called from Oracle Applications Fast Formula.
      It passes the second group of balances to the main tax package.
   ZaTxBal3_01032006
      This function is called from Oracle Applications Fast Formula.
      It passes the third group of balances to the main tax package.
   ZaTx_01032006
      This function is called from Oracle Applications Fast Formula.
      This is the main tax function from where all necessary
      validation and calculations are done.  The function will
      calculate the tax liabilities of the employee assignment
      and pass it back to the calling formula.

   PRIVATE FUNCTIONS
      <none>
   NOTES
      .

   MODIFICATION HISTORY
   Person     Date       Version        Bug     Comments
   ---------- ---------- -------------- ------- --------------------------------
   J.N. Louw  20/04/2007 115.3          5965050 TX_ON_LS_PTD
   R V Pahune 28/02/2006 115.2          5059281 for public off allw taxation
                                                according to tax table.
   J.N. Louw  06/12/2005 115.1          4861242 For detail history see
                                                py_za_tx_utl_01032005
*/
-------------------------------------------------------------------------------
--                           PACKAGE GLOBAL AREA                             --
-------------------------------------------------------------------------------
-- Types
-------------------------------------------------------------------------------
   SUBTYPE BALANCE IS py_za_tx_utl_01032006.t_balance;
-------------------------------------------------------------------------------
-- Application Contexts
-------------------------------------------------------------------------------
   con_ASG_ACT_ID                 NUMBER;
   con_ASG_ID                     NUMBER;
   con_PRL_ACT_ID                 NUMBER;
   con_PRL_ID                     NUMBER;
-------------------------------------------------------------------------------
-- Application Global Values
-------------------------------------------------------------------------------
   glb_ZA_ADL_TX_RBT              NUMBER;
   glb_ZA_ARR_PF_AN_MX_ABT        NUMBER;
   glb_ZA_ARR_RA_AN_MX_ABT        NUMBER;
   glb_ZA_TRV_ALL_TX_PRC          NUMBER;
   glb_ZA_CC_TX_PRC               NUMBER;
   glb_ZA_PF_AN_MX_ABT            NUMBER;
   glb_ZA_PF_MX_PRC               NUMBER;
   glb_ZA_PER_SERV_COMP_PERC      NUMBER;
   glb_ZA_PER_SERV_TRST_PERC      NUMBER;
   glb_ZA_PRI_TX_RBT              NUMBER;
   glb_ZA_PRI_TX_THRSHLD          NUMBER;
   glb_ZA_PBL_TX_PRC              NUMBER;
   glb_ZA_PBL_TX_RTE              NUMBER;
   glb_ZA_RA_AN_MX_ABT            NUMBER;
   glb_ZA_RA_MX_PRC               NUMBER;
   glb_ZA_SC_TX_THRSHLD           NUMBER;
   glb_ZA_SIT_LIM                 NUMBER;
   glb_ZA_TMP_TX_RTE              NUMBER;
   glb_ZA_WRK_DYS_PR_YR           NUMBER;
-------------------------------------------------------------------------------
-- Application Database Items
-------------------------------------------------------------------------------
   dbi_BP_TX_RCV                  VARCHAR2(1);
   dbi_PAY_PROC_PRD_DTE_PD        DATE;
   dbi_PER_AGE                    NUMBER;
   dbi_PER_DTE_OF_BRTH            DATE;
   dbi_SEA_WRK_DYS_WRK            NUMBER;
   dbi_SES_DTE                    DATE;
   dbi_TX_DIR_NUM                 VARCHAR2(60);
   dbi_TX_DIR_VAL                 NUMBER DEFAULT 25;
   dbi_TX_STA                     VARCHAR2(1);
   dbi_ZA_ACT_END_DTE             DATE;
   dbi_ZA_ACT_STRT_DTE            DATE;
   dbi_ZA_ASG_TX_RTR_PRD          VARCHAR2(1);
   dbi_ZA_ASG_TAX_RTR_RSLTS       VARCHAR2(1);
   dbi_ZA_ASG_TX_YR               NUMBER(4);
   dbi_ZA_ASG_TX_YR_END           DATE;
   dbi_ZA_ASG_TX_YR_STRT          DATE;
   dbi_ZA_CUR_PRD_END_DTE         DATE;
   dbi_ZA_CUR_PRD_STRT_DTE        DATE;
   dbi_ZA_DYS_IN_YR               NUMBER;
   dbi_ZA_PAY_PRDS_LFT            NUMBER;
   dbi_ZA_PAY_PRDS_PER_YR         NUMBER;
   dbi_ZA_TX_YR_END               DATE;
   dbi_ZA_TX_YR_STRT              DATE;
   dbi_ZA_LS_DIR_NUM              VARCHAR2(13);
   dbi_ZA_LS_DIR_VAL              NUMBER;
-------------------------------------------------------------------------------
-- Balances
-------------------------------------------------------------------------------
   bal_ANN_ARR_PF_CMTD            BALANCE;
   bal_ANN_ARR_PF_CYTD            BALANCE;
   bal_ANN_ARR_PF_RUN             BALANCE;
   bal_ANN_ARR_PF_PTD             BALANCE;
   bal_ANN_ARR_PF_YTD             BALANCE;
   bal_ANN_ARR_RA_CMTD            BALANCE;
   bal_ANN_ARR_RA_CYTD            BALANCE;
   bal_ANN_ARR_RA_RUN             BALANCE;
   bal_ANN_ARR_RA_PTD             BALANCE;
   bal_ANN_ARR_RA_YTD             BALANCE;
   bal_ANN_EE_INC_PRO_POL_CMTD    BALANCE;
   bal_ANN_EE_INC_PRO_POL_CYTD    BALANCE;
   bal_ANN_EE_INC_PRO_POL_RUN     BALANCE;
   bal_ANN_EE_INC_PRO_POL_PTD     BALANCE;
   bal_ANN_EE_INC_PRO_POL_YTD     BALANCE;
   bal_ANN_MED_CNTRB_ABM_CMTD     BALANCE;
   bal_ANN_MED_CNTRB_ABM_CYTD     BALANCE;
   bal_ANN_MED_CNTRB_ABM_RUN      BALANCE;
   bal_ANN_MED_CNTRB_ABM_PTD      BALANCE;
   bal_ANN_MED_CNTRB_ABM_YTD      BALANCE;
   bal_ANN_PF_CMTD                BALANCE;
   bal_ANN_PF_CYTD                BALANCE;
   bal_ANN_PF_RUN                 BALANCE;
   bal_ANN_PF_PTD                 BALANCE;
   bal_ANN_PF_YTD                 BALANCE;
   bal_ANN_RA_CMTD                BALANCE;
   bal_ANN_RA_CYTD                BALANCE;
   bal_ANN_RA_RUN                 BALANCE;
   bal_ANN_RA_PTD                 BALANCE;
   bal_ANN_RA_YTD                 BALANCE;
   bal_ARR_PF_CMTD                BALANCE;
   bal_ARR_PF_CYTD                BALANCE;
   bal_ARR_PF_PTD                 BALANCE;
   bal_ARR_PF_YTD                 BALANCE;
   bal_ARR_RA_CMTD                BALANCE;
   bal_ARR_RA_CYTD                BALANCE;
   bal_ARR_RA_PTD                 BALANCE;
   bal_ARR_RA_YTD                 BALANCE;
   bal_BP_CMTD                    BALANCE;
   bal_BP_PTD                     BALANCE;
   bal_BP_YTD                     BALANCE;
   bal_CUR_PF_CMTD                BALANCE;
   bal_CUR_PF_CYTD                BALANCE;
   bal_CUR_PF_RUN                 BALANCE;
   bal_CUR_PF_PTD                 BALANCE;
   bal_CUR_PF_YTD                 BALANCE;
   bal_CUR_RA_CMTD                BALANCE;
   bal_CUR_RA_CYTD                BALANCE;
   bal_CUR_RA_RUN                 BALANCE;
   bal_CUR_RA_PTD                 BALANCE;
   bal_CUR_RA_YTD                 BALANCE;
   bal_DIR_DMD_RMN_ITD            BALANCE;
   bal_EE_INC_PRO_POL_CMTD        BALANCE;
   bal_EE_INC_PRO_POL_CYTD        BALANCE;
   bal_EE_INC_PRO_POL_RUN         BALANCE;
   bal_EE_INC_PRO_POL_PTD         BALANCE;
   bal_EE_INC_PRO_POL_YTD         BALANCE;
   bal_EXC_ARR_PEN_ITD            BALANCE;
   bal_EXC_ARR_PEN_PTD            BALANCE;
   bal_EXC_ARR_PEN_YTD            BALANCE;
   bal_EXC_ARR_RA_ITD             BALANCE;
   bal_EXC_ARR_RA_PTD             BALANCE;
   bal_EXC_ARR_RA_YTD             BALANCE;
   bal_MED_CONTR_CMTD             BALANCE;
   bal_MED_CONTR_CYTD             BALANCE;
   bal_MED_CONTR_RUN              BALANCE;
   bal_MED_CONTR_PTD              BALANCE;
   bal_MED_CONTR_YTD              BALANCE;
   bal_MED_CNTRB_ABM_CMTD         BALANCE;
   bal_MED_CNTRB_ABM_CYTD         BALANCE;
   bal_MED_CNTRB_ABM_RUN          BALANCE;
   bal_MED_CNTRB_ABM_PTD          BALANCE;
   bal_MED_CNTRB_ABM_YTD          BALANCE;
   bal_NET_PAY_RUN                BALANCE;
   bal_NET_TXB_INC_CMTD           BALANCE;
   bal_PAYE_YTD                   BALANCE;
   bal_SITE_YTD                   BALANCE;
   bal_TAX_YTD                    BALANCE;
   bal_TX_ON_AB_PTD               BALANCE;
   bal_TX_ON_AB_YTD               BALANCE;
   bal_TX_ON_AP_PTD               BALANCE;
   bal_TX_ON_AP_YTD               BALANCE;
   bal_TX_ON_BP_PTD               BALANCE;
   bal_TX_ON_BP_YTD               BALANCE;
   bal_TX_ON_TA_PTD               BALANCE;
   bal_TX_ON_TA_YTD               BALANCE;
   bal_TX_ON_DR_PTD               BALANCE;
   bal_TX_ON_DR_YTD               BALANCE;
   bal_TX_ON_FB_PTD               BALANCE;
   bal_TX_ON_FB_YTD               BALANCE;
   bal_TX_ON_NI_PTD               BALANCE;
   bal_TX_ON_NI_YTD               BALANCE;
   bal_TX_ON_PO_PTD               BALANCE;
   bal_TX_ON_PO_YTD               BALANCE;
   bal_TX_ON_LS_PTD               BALANCE;
   bal_TOT_INC_PTD                BALANCE;
   bal_TOT_INC_YTD                BALANCE;
   bal_TOT_NRFI_AN_INC_CMTD       BALANCE;
   bal_TOT_NRFI_AN_INC_CYTD       BALANCE;
   bal_TOT_NRFI_AN_INC_RUN        BALANCE;
   bal_TOT_NRFI_AN_INC_PTD        BALANCE;
   bal_TOT_NRFI_AN_INC_YTD        BALANCE;
   bal_TOT_NRFI_INC_CMTD          BALANCE;
   bal_TOT_NRFI_INC_CYTD          BALANCE;
   bal_TOT_NRFI_INC_RUN           BALANCE;
   bal_TOT_NRFI_INC_PTD           BALANCE;
   bal_TOT_NRFI_INC_YTD           BALANCE;
   bal_TOT_RFI_AN_INC_CMTD        BALANCE;
   bal_TOT_RFI_AN_INC_CYTD        BALANCE;
   bal_TOT_RFI_AN_INC_RUN         BALANCE;
   bal_TOT_RFI_AN_INC_PTD         BALANCE;
   bal_TOT_RFI_AN_INC_YTD         BALANCE;
   bal_TOT_RFI_INC_CMTD           BALANCE;
   bal_TOT_RFI_INC_CYTD           BALANCE;
   bal_TOT_RFI_INC_RUN            BALANCE;
   bal_TOT_RFI_INC_PTD            BALANCE;
   bal_TOT_RFI_INC_YTD            BALANCE;
   bal_TOT_SEA_WRK_DYS_WRK_YTD    BALANCE;
   bal_TOT_SKL_ANN_INC_CMTD       BALANCE;
   bal_TOT_SKL_INC_CMTD           BALANCE;
   bal_TOT_TXB_INC_ITD            BALANCE;
   bal_TOT_TXB_AB_CMTD            BALANCE;
   bal_TOT_TXB_AB_RUN             BALANCE;
   bal_TOT_TXB_AB_PTD             BALANCE;
   bal_TOT_TXB_AB_YTD             BALANCE;
   bal_TOT_TXB_AP_CMTD            BALANCE;
   bal_TOT_TXB_AP_RUN             BALANCE;
   bal_TOT_TXB_AP_PTD             BALANCE;
   bal_TOT_TXB_AP_YTD             BALANCE;
   bal_TOT_TXB_FB_CMTD            BALANCE;
   bal_TOT_TXB_FB_CYTD            BALANCE;
   bal_TOT_TXB_FB_RUN             BALANCE;
   bal_TOT_TXB_FB_PTD             BALANCE;
   bal_TOT_TXB_FB_YTD             BALANCE;
   bal_TOT_TXB_NI_CMTD            BALANCE;
   bal_TOT_TXB_NI_CYTD            BALANCE;
   bal_TOT_TXB_NI_RUN             BALANCE;
   bal_TOT_TXB_NI_PTD             BALANCE;
   bal_TOT_TXB_NI_YTD             BALANCE;
   bal_TOT_TXB_PO_CMTD            BALANCE;
   bal_TOT_TXB_PO_PTD             BALANCE;
   bal_TOT_TXB_PO_YTD             BALANCE;
   bal_TOT_TXB_TA_CMTD            BALANCE;
   bal_TOT_TXB_TA_CYTD            BALANCE;
   bal_TOT_TXB_TA_PTD             BALANCE;
   bal_TOT_TXB_TA_YTD             BALANCE;

-------------------------------------------------------------------------------
-- Trace Globals
-------------------------------------------------------------------------------

--   These are set within the procedures and function calls!!
--   Values can be output by the main function call from formula
--
  -- Calculation Type
  trc_CalTyp                VARCHAR2(7) DEFAULT 'Unknown';
  -- Factors
  trc_TxbIncPtd             BALANCE DEFAULT 0;
  trc_PrdFactor             NUMBER  DEFAULT 0;
  trc_PosFactor             NUMBER  DEFAULT 0;
  trc_SitFactor             NUMBER  DEFAULT 1;
  -- Deemed Remuneration
  trc_DmdRmnRun             BALANCE DEFAULT 0;
  trc_TxbDmdRmn             BALANCE DEFAULT 0;
  trc_TotLibDR              BALANCE DEFAULT 0;
  trc_LibFyDR               BALANCE DEFAULT 0;
  trc_LibFpDR               BALANCE DEFAULT 0;
  -- Base Income
  trc_BseErn                BALANCE DEFAULT 0;
  trc_TxbBseInc             BALANCE DEFAULT 0;
  trc_TotLibBse             BALANCE DEFAULT 0;
  -- Period Pension Fund
  trc_TxbIncYtd             BALANCE DEFAULT 0;
  trc_PerTxbInc             BALANCE DEFAULT 0;
  trc_PerPenFnd             BALANCE DEFAULT 0;
  trc_PerRfiCon             BALANCE DEFAULT 0;
  trc_PerRfiTxb             BALANCE DEFAULT 0;
  trc_PerPenFndMax          BALANCE DEFAULT 0;
  trc_PerPenFndAbm          BALANCE DEFAULT 0;
  -- Annual Pension Fund
  trc_AnnTxbInc             BALANCE DEFAULT 0;
  trc_AnnPenFnd             BALANCE DEFAULT 0;
  trc_AnnRfiCon             BALANCE DEFAULT 0;
  trc_AnnRfiTxb             BALANCE DEFAULT 0;
  trc_AnnPenFndMax          BALANCE DEFAULT 0;
  trc_AnnPenFndAbm          BALANCE DEFAULT 0;
  -- Period Arrear Pension
  trc_PerArrPenFnd          BALANCE DEFAULT 0;
  trc_PerArrPenFndAbm       BALANCE DEFAULT 0;
  -- Annual Arrear Pension
  trc_AnnArrPenFnd          BALANCE DEFAULT 0;
  trc_AnnArrPenFndAbm       BALANCE DEFAULT 0;
  -- Arrear Excess Update Value
  trc_PfUpdFig              BALANCE DEFAULT 0;
  -- Period Retirement Annuity
  trc_PerRetAnu             BALANCE DEFAULT 0;
  trc_PerNrfiCon            BALANCE DEFAULT 0;
  trc_PerRetAnuMax          BALANCE DEFAULT 0;
  trc_PerRetAnuAbm          BALANCE DEFAULT 0;
  -- Annual Retirement Annuity
  trc_AnnRetAnu             BALANCE DEFAULT 0;
  trc_AnnNrfiCon            BALANCE DEFAULT 0;
  trc_AnnRetAnuMax          BALANCE DEFAULT 0;
  trc_AnnRetAnuAbm          BALANCE DEFAULT 0;
  -- Period Arrear Retirement Annuity
  trc_PerArrRetAnu          BALANCE DEFAULT 0;
  trc_PerArrRetAnuAbm       BALANCE DEFAULT 0;
  -- Annual Arrear Retirement Annuity
  trc_AnnArrRetAnu          BALANCE DEFAULT 0;
  trc_AnnArrRetAnuAbm       BALANCE DEFAULT 0;
  -- Arrear Excess Update Value
  trc_RaUpdFig              BALANCE DEFAULT 0;
  -- Medical Aid Abatement
  trc_PerMedAidAbm          BALANCE DEFAULT 0;
  trc_AnnMedAidAbm          BALANCE DEFAULT 0;
  -- Rebates Thresholds
  trc_Rebate                BALANCE DEFAULT 0;
  trc_Threshold             BALANCE DEFAULT 0;
  -- Income Protection Policy
  trc_PerIncProPolAbm       BALANCE DEFAULT 0;
  trc_AnnIncProPolAbm       BALANCE DEFAULT 0;
  -- Abatement Totals
  trc_PerTotAbm             BALANCE DEFAULT 0;
  trc_AnnTotAbm             BALANCE DEFAULT 0;
  -- Normal Income
  trc_NorIncYtd             BALANCE DEFAULT 0;
  trc_NorIncPtd             BALANCE DEFAULT 0;
  trc_NorErn                BALANCE DEFAULT 0;
  trc_TxbNorInc             BALANCE DEFAULT 0;
  trc_TotLibNI              BALANCE DEFAULT 0;
  trc_LibFyNI               BALANCE DEFAULT 0;
  trc_LibFpNI               BALANCE DEFAULT 0;
  -- Fringe Benefits
  trc_FrnBenYtd             BALANCE DEFAULT 0;
  trc_FrnBenPtd             BALANCE DEFAULT 0;
  trc_FrnBenErn             BALANCE DEFAULT 0;
  trc_TxbFrnInc             BALANCE DEFAULT 0;
  trc_TotLibFB              BALANCE DEFAULT 0;
  trc_LibFyFB               BALANCE DEFAULT 0;
  trc_LibFpFB               BALANCE DEFAULT 0;
  -- Travel Allowance
  trc_TrvAllYtd             BALANCE DEFAULT 0;
  trc_TrvAllPtd             BALANCE DEFAULT 0;
  trc_TrvAllErn             BALANCE DEFAULT 0;
  trc_TxbTrvInc             BALANCE DEFAULT 0;
  trc_TotLibTA              BALANCE DEFAULT 0;
  trc_LibFyTA               BALANCE DEFAULT 0;
  trc_LibFpTA               BALANCE DEFAULT 0;
  -- Bonus Provision
  trc_BonProYtd             BALANCE DEFAULT 0;
  trc_BonProPtd             BALANCE DEFAULT 0;
  trc_BonProErn             BALANCE DEFAULT 0;
  trc_TxbBonProInc          BALANCE DEFAULT 0;
  trc_TotLibBP              BALANCE DEFAULT 0;
  trc_LibFyBP               BALANCE DEFAULT 0;
  trc_LibFpBP               BALANCE DEFAULT 0;
  -- Annual Bonus
  trc_AnnBonYtd             BALANCE DEFAULT 0;
  trc_AnnBonPtd             BALANCE DEFAULT 0;
  trc_AnnBonErn             BALANCE DEFAULT 0;
  trc_TxbAnnBonInc          BALANCE DEFAULT 0;
  trc_TotLibAB              BALANCE DEFAULT 0;
  trc_LibFyAB               BALANCE DEFAULT 0;
  trc_LibFpAB               BALANCE DEFAULT 0;
  -- Annual Payments
  trc_AnnPymYtd             BALANCE DEFAULT 0;
  trc_AnnPymPtd             BALANCE DEFAULT 0;
  trc_AnnPymErn             BALANCE DEFAULT 0;
  trc_TxbAnnPymInc          BALANCE DEFAULT 0;
  trc_TotLibAP              BALANCE DEFAULT 0;
  trc_LibFyAP               BALANCE DEFAULT 0;
  trc_LibFpAP               BALANCE DEFAULT 0;
  -- Pubilc Office Allowance
  trc_PblOffYtd             BALANCE DEFAULT 0;
  trc_PblOffPtd             BALANCE DEFAULT 0;
  trc_PblOffErn             BALANCE DEFAULT 0;
  trc_TxbPblOffInc          BALANCE DEFAULT 0;
  trc_TotLibPO              BALANCE DEFAULT 0;
  trc_LibFyPO               BALANCE DEFAULT 0;
  trc_LibFpPO               BALANCE DEFAULT 0;



  -- Messages
  trc_LibWrn                VARCHAR2(100) DEFAULT ' ';

  -- Statutory Deduction Value
  trc_PayValSD              BALANCE DEFAULT 0;
  -- Employer Contribution Value
  trc_PayValEC              BALANCE DEFAULT 0;
  -- PAYE and SITE Values
  trc_PayeVal               BALANCE DEFAULT 0;
  trc_SiteVal               BALANCE DEFAULT 0;
  -- IT3A Threshold Indicator
  trc_It3Ind                NUMBER DEFAULT 0;
  -- Tax Percentage Value On trace
  trc_TxPercVal             NUMBER DEFAULT 0;
  -- Total Taxable Income Update Figure
  trc_OUpdFig               BALANCE DEFAULT 0;
  -- Net Taxable Income Update Figure
  trc_NtiUpdFig             BALANCE DEFAULT 0;

  -- ValidateTaxOns Override Globals
  trc_LibFpDROvr            BOOLEAN DEFAULT FALSE;
  trc_LibFpNIOvr            BOOLEAN DEFAULT FALSE;
  trc_LibFpFBOvr            BOOLEAN DEFAULT FALSE;
  trc_LibFpTAOvr            BOOLEAN DEFAULT FALSE;
  trc_LibFpBPOvr            BOOLEAN DEFAULT FALSE;
  trc_LibFpABOvr            BOOLEAN DEFAULT FALSE;
  trc_LibFpAPOvr            BOOLEAN DEFAULT FALSE;
  trc_LibFpPOOvr            BOOLEAN DEFAULT FALSE;

  -- Global Exception Message
  xpt_Msg                   VARCHAR2(100) DEFAULT 'No Error';
  -- Global Exception
  xpt_E                     EXCEPTION;

  -- Override Globals
  trc_OvrTxCalc             BOOLEAN       DEFAULT FALSE;
  trc_OvrTyp                VARCHAR2(1)   DEFAULT 'V';
  trc_OvrPrc                NUMBER(3)     DEFAULT 0;
  trc_OvrWrn                VARCHAR2(150) DEFAULT ' ';

  -- Negative Ptd Global
  trc_NegPtd                BOOLEAN DEFAULT FALSE;

-- Function to Override Tax Calculation
--
FUNCTION ZaTxOvr_01032006(
    p_OvrTyp IN VARCHAR2
   ,p_TxOnNI IN NUMBER
   ,p_TxOnAP IN NUMBER
   ,p_TxPrc  IN NUMBER
   )RETURN NUMBER;


-- Function to Initialise Globals
--
FUNCTION ZaTxGlb_01032006(
-- Global Values
    p_ZA_ADL_TX_RBT         IN NUMBER
   ,p_ZA_ARR_PF_AN_MX_ABT   IN NUMBER
   ,p_ZA_ARR_RA_AN_MX_ABT   IN NUMBER
   ,p_ZA_TRV_ALL_TX_PRC     IN NUMBER
   ,p_ZA_CC_TX_PRC          IN NUMBER
   ,p_ZA_PF_AN_MX_ABT       IN NUMBER
   ,p_ZA_PF_MX_PRC          IN NUMBER
   ,p_ZA_PER_SERV_COMP_PERC IN NUMBER
   ,p_ZA_PER_SERV_TRST_PERC IN NUMBER
   ,p_ZA_PRI_TX_RBT         IN NUMBER
   ,p_ZA_PRI_TX_THRSHLD     IN NUMBER
   ,p_ZA_PBL_TX_PRC         IN NUMBER
   ,p_ZA_PBL_TX_RTE         IN NUMBER
   ,p_ZA_RA_AN_MX_ABT       IN NUMBER
   ,p_ZA_RA_MX_PRC          IN NUMBER
   ,p_ZA_SC_TX_THRSHLD      IN NUMBER
   ,p_ZA_SIT_LIM            IN NUMBER
   ,p_ZA_TMP_TX_RTE         IN NUMBER
   ,p_ZA_WRK_DYS_PR_YR      IN NUMBER
   ) RETURN NUMBER;

-- Function to Initialise Globals - Database Item Values
--
FUNCTION ZaTxDbi_01032006(
-- Database Items
   p_PAY_PROC_PRD_DTE_PD   IN DATE
  ,p_PER_AGE               IN NUMBER
  ,p_PER_DTE_OF_BRTH       IN DATE
  ,p_SES_DTE               IN DATE
  ,p_ZA_ACT_END_DTE        IN DATE
  ,p_ZA_ACT_STRT_DTE       IN DATE
  ,p_ZA_ASG_TX_RTR_PRD     IN VARCHAR2
  ,p_ZA_ASG_TAX_RTR_RSLTS  IN VARCHAR2
  ,p_ZA_ASG_TX_YR          IN NUMBER
  ,p_ZA_ASG_TX_YR_END      IN DATE
  ,p_ZA_ASG_TX_YR_STRT     IN DATE
  ,p_ZA_CUR_PRD_END_DTE    IN DATE
  ,p_ZA_CUR_PRD_STRT_DTE   IN DATE
  ,p_ZA_DYS_IN_YR          IN NUMBER
  ,p_ZA_PAY_PRDS_LFT       IN NUMBER
  ,p_ZA_PAY_PRDS_PER_YR    IN NUMBER
  ,p_ZA_TX_YR_END          IN DATE
  ,p_ZA_TX_YR_STRT         IN DATE
  ,p_BP_TX_RCV             IN VARCHAR2
  ,p_SEA_WRK_DYS_WRK       IN NUMBER
  ,p_TX_DIR_NUM            IN VARCHAR2
  ,p_TX_DIR_VAL            IN NUMBER
  ,p_TX_STA                IN VARCHAR2
  ,p_ZA_LS_DIR_NUM         IN VARCHAR2
  ,p_ZA_LS_DIR_VAL         IN NUMBER
  ) RETURN NUMBER;


-- Function to Initialise Globals - Balance Values
-- First Section
FUNCTION ZaTxBal1_01032006(
-- Balances
    p_ANN_ARR_PF_CMTD           IN NUMBER
   ,p_ANN_ARR_PF_CYTD           IN NUMBER
   ,p_ANN_ARR_PF_RUN            IN NUMBER
   ,p_ANN_ARR_PF_PTD            IN NUMBER
   ,p_ANN_ARR_PF_YTD            IN NUMBER
   ,p_ANN_ARR_RA_CMTD           IN NUMBER
   ,p_ANN_ARR_RA_CYTD           IN NUMBER
   ,p_ANN_ARR_RA_RUN            IN NUMBER
   ,p_ANN_ARR_RA_PTD            IN NUMBER
   ,p_ANN_ARR_RA_YTD            IN NUMBER
   ,p_ANN_EE_INC_PRO_POL_CMTD   IN NUMBER
   ,p_ANN_EE_INC_PRO_POL_CYTD   IN NUMBER
   ,p_ANN_EE_INC_PRO_POL_RUN    IN NUMBER
   ,p_ANN_EE_INC_PRO_POL_PTD    IN NUMBER
   ,p_ANN_EE_INC_PRO_POL_YTD    IN NUMBER
   ,p_ANN_MED_CNTRB_ABM_CMTD    IN NUMBER
   ,p_ANN_MED_CNTRB_ABM_CYTD    IN NUMBER
   ,p_ANN_MED_CNTRB_ABM_RUN     IN NUMBER
   ,p_ANN_MED_CNTRB_ABM_PTD     IN NUMBER
   ,p_ANN_MED_CNTRB_ABM_YTD     IN NUMBER
   ,p_ANN_PF_CMTD               IN NUMBER
   ,p_ANN_PF_CYTD               IN NUMBER
   ,p_ANN_PF_RUN                IN NUMBER
   ,p_ANN_PF_PTD                IN NUMBER
   ,p_ANN_PF_YTD                IN NUMBER
   ,p_ANN_RA_CMTD               IN NUMBER
   ,p_ANN_RA_CYTD               IN NUMBER
   ,p_ANN_RA_RUN                IN NUMBER
   ,p_ANN_RA_PTD                IN NUMBER
   ,p_ANN_RA_YTD                IN NUMBER
   ) RETURN NUMBER;

-- Function to Initialise Globals - Balance Values
-- Second Section
FUNCTION ZaTxBal2_01032006(
-- Balances
    p_ARR_PF_CMTD                IN NUMBER
   ,p_ARR_PF_CYTD                IN NUMBER
   ,p_ARR_PF_PTD                 IN NUMBER
   ,p_ARR_PF_YTD                 IN NUMBER
   ,p_ARR_RA_CMTD                IN NUMBER
   ,p_ARR_RA_CYTD                IN NUMBER
   ,p_ARR_RA_PTD                 IN NUMBER
   ,p_ARR_RA_YTD                 IN NUMBER
   ,p_BP_CMTD                    IN NUMBER
   ,p_BP_PTD                     IN NUMBER
   ,p_BP_YTD                     IN NUMBER
   ,p_CUR_PF_CMTD                IN NUMBER
   ,p_CUR_PF_CYTD                IN NUMBER
   ,p_CUR_PF_RUN                 IN NUMBER
   ,p_CUR_PF_PTD                 IN NUMBER
   ,p_CUR_PF_YTD                 IN NUMBER
   ,p_CUR_RA_CMTD                IN NUMBER
   ,p_CUR_RA_CYTD                IN NUMBER
   ,p_CUR_RA_RUN                 IN NUMBER
   ,p_CUR_RA_PTD                 IN NUMBER
   ,p_CUR_RA_YTD                 IN NUMBER
   ,p_DIR_DMD_RMN_ITD            IN NUMBER
   ) RETURN NUMBER;

-- Function to Initialise Globals - Balance Values
-- Third Section
FUNCTION ZaTxBal3_01032006(
-- Balances
    p_EE_INC_PRO_POL_CMTD        IN NUMBER
   ,p_EE_INC_PRO_POL_CYTD        IN NUMBER
   ,p_EE_INC_PRO_POL_RUN         IN NUMBER
   ,p_EE_INC_PRO_POL_PTD         IN NUMBER
   ,p_EE_INC_PRO_POL_YTD         IN NUMBER
   ,p_EXC_ARR_PEN_ITD            IN NUMBER
   ,p_EXC_ARR_PEN_PTD            IN NUMBER
   ,p_EXC_ARR_PEN_YTD            IN NUMBER
   ,p_EXC_ARR_RA_ITD             IN NUMBER
   ,p_EXC_ARR_RA_PTD             IN NUMBER
   ,p_EXC_ARR_RA_YTD             IN NUMBER
   ,p_MED_CONTR_CMTD             IN NUMBER
   ,p_MED_CONTR_CYTD             IN NUMBER
   ,p_MED_CONTR_RUN              IN NUMBER
   ,p_MED_CONTR_PTD              IN NUMBER
   ,p_MED_CONTR_YTD              IN NUMBER
   ,p_MED_CNTRB_ABM_CMTD         IN NUMBER
   ,p_MED_CNTRB_ABM_CYTD         IN NUMBER
   ,p_MED_CNTRB_ABM_RUN          IN NUMBER
   ,p_MED_CNTRB_ABM_PTD          IN NUMBER
   ,p_MED_CNTRB_ABM_YTD          IN NUMBER
   ,p_NET_PAY_RUN                IN NUMBER
   ,p_NET_TXB_INC_CMTD           IN NUMBER
   ) RETURN NUMBER;

-- Function to Initialise Globals - Balance Values
-- Fourth Section
FUNCTION ZaTxBal4_01032006(
-- Balances
    p_PAYE_YTD                   IN NUMBER
   ,p_SITE_YTD                   IN NUMBER
   ,p_TAX_YTD                    IN NUMBER
   ,p_TX_ON_AB_PTD               IN NUMBER
   ,p_TX_ON_AB_YTD               IN NUMBER
   ,p_TX_ON_AP_PTD               IN NUMBER
   ,p_TX_ON_AP_YTD               IN NUMBER
   ,p_TX_ON_BP_PTD               IN NUMBER
   ,p_TX_ON_BP_YTD               IN NUMBER
   ,p_TX_ON_TA_PTD               IN NUMBER
   ,p_TX_ON_TA_YTD               IN NUMBER
   ,p_TX_ON_DR_PTD               IN NUMBER
   ,p_TX_ON_DR_YTD               IN NUMBER
   ,p_TX_ON_FB_PTD               IN NUMBER
   ,p_TX_ON_FB_YTD               IN NUMBER
   ,p_TX_ON_NI_PTD               IN NUMBER
   ,p_TX_ON_NI_YTD               IN NUMBER
   ,p_TX_ON_PO_PTD               IN NUMBER
   ,p_TX_ON_PO_YTD               IN NUMBER
   ,p_TX_ON_LS_PTD               IN NUMBER
   ) RETURN NUMBER;

FUNCTION ZaTxBal5_01032006(
-- Balances
    p_TOT_INC_PTD                IN NUMBER
   ,p_TOT_INC_YTD                IN NUMBER
   ,p_TOT_NRFI_AN_INC_CMTD       IN NUMBER
   ,p_TOT_NRFI_AN_INC_CYTD       IN NUMBER
   ,p_TOT_NRFI_AN_INC_RUN        IN NUMBER
   ,p_TOT_NRFI_AN_INC_PTD        IN NUMBER
   ,p_TOT_NRFI_AN_INC_YTD        IN NUMBER
   ,p_TOT_NRFI_INC_CMTD          IN NUMBER
   ,p_TOT_NRFI_INC_CYTD          IN NUMBER
   ,p_TOT_NRFI_INC_RUN           IN NUMBER
   ,p_TOT_NRFI_INC_PTD           IN NUMBER
   ,p_TOT_NRFI_INC_YTD           IN NUMBER
   ,p_TOT_RFI_AN_INC_CMTD        IN NUMBER
   ,p_TOT_RFI_AN_INC_CYTD        IN NUMBER
   ,p_TOT_RFI_AN_INC_RUN         IN NUMBER
   ,p_TOT_RFI_AN_INC_PTD         IN NUMBER
   ,p_TOT_RFI_AN_INC_YTD         IN NUMBER
   ,p_TOT_RFI_INC_CMTD           IN NUMBER
   ,p_TOT_RFI_INC_CYTD           IN NUMBER
   ,p_TOT_RFI_INC_RUN            IN NUMBER
   ,p_TOT_RFI_INC_PTD            IN NUMBER
   ,p_TOT_RFI_INC_YTD            IN NUMBER
   ,p_TOT_SEA_WRK_DYS_WRK_YTD    IN NUMBER
   ,p_TOT_SKL_ANN_INC_CMTD       IN NUMBER
   ,p_TOT_SKL_INC_CMTD           IN NUMBER
   ,p_TOT_TXB_INC_ITD            IN NUMBER
   ) RETURN NUMBER;

FUNCTION ZaTxBal6_01032006(
-- Balances
    p_TOT_TXB_AB_CMTD            IN NUMBER
   ,p_TOT_TXB_AB_RUN             IN NUMBER
   ,p_TOT_TXB_AB_PTD             IN NUMBER
   ,p_TOT_TXB_AB_YTD             IN NUMBER
   ,p_TOT_TXB_AP_CMTD            IN NUMBER
   ,p_TOT_TXB_AP_RUN             IN NUMBER
   ,p_TOT_TXB_AP_PTD             IN NUMBER
   ,p_TOT_TXB_AP_YTD             IN NUMBER
   ,p_TOT_TXB_FB_CMTD            IN NUMBER
   ,p_TOT_TXB_FB_CYTD            IN NUMBER
   ,p_TOT_TXB_FB_RUN             IN NUMBER
   ,p_TOT_TXB_FB_PTD             IN NUMBER
   ,p_TOT_TXB_FB_YTD             IN NUMBER
   ,p_TOT_TXB_NI_CMTD            IN NUMBER
   ,p_TOT_TXB_NI_CYTD            IN NUMBER
   ,p_TOT_TXB_NI_RUN             IN NUMBER
   ,p_TOT_TXB_NI_PTD             IN NUMBER
   ,p_TOT_TXB_NI_YTD             IN NUMBER
   ,p_TOT_TXB_PO_CMTD            IN NUMBER
   ,p_TOT_TXB_PO_PTD             IN NUMBER
   ,p_TOT_TXB_PO_YTD             IN NUMBER
   ,p_TOT_TXB_TA_CMTD            IN NUMBER
   ,p_TOT_TXB_TA_CYTD            IN NUMBER
   ,p_TOT_TXB_TA_PTD             IN NUMBER
   ,p_TOT_TXB_TA_YTD             IN NUMBER
   ) RETURN NUMBER;

-- Main Tax Function
-- Called from Fast Formula
FUNCTION ZaTx_01032006(
/*  PARAMETERS */
-- Contexts
   ASSIGNMENT_ACTION_ID    IN NUMBER
  ,ASSIGNMENT_ID           IN NUMBER
  ,PAYROLL_ACTION_ID       IN NUMBER
  ,PAYROLL_ID              IN NUMBER
-- Out Parameters
  , p_LibWrn               OUT NOCOPY VARCHAR2
  , p_LibFpDR              OUT NOCOPY NUMBER
  , p_LibFpNI              OUT NOCOPY NUMBER
  , p_LibFpFB              OUT NOCOPY NUMBER
  , p_LibFpTA              OUT NOCOPY NUMBER
  , p_LibFpBP              OUT NOCOPY NUMBER
  , p_LibFpAB              OUT NOCOPY NUMBER
  , p_LibFpAP              OUT NOCOPY NUMBER
  , p_LibFpPO              OUT NOCOPY NUMBER
  , p_PayValSD             OUT NOCOPY NUMBER
  , p_PayValEC             OUT NOCOPY NUMBER
  , p_PayeVal              OUT NOCOPY NUMBER
  , p_SiteVal              OUT NOCOPY NUMBER
  , p_It3Ind               OUT NOCOPY NUMBER
  , p_PfUpdFig             OUT NOCOPY NUMBER
  , p_RaUpdFig             OUT NOCOPY NUMBER
  , p_OUpdFig              OUT NOCOPY NUMBER
  , p_NtiUpdFig            OUT NOCOPY NUMBER
  , p_OvrWrn               OUT NOCOPY VARCHAR2
  , p_LSDirNum             OUT NOCOPY VARCHAR2
  , p_LSDirVal             OUT NOCOPY NUMBER
  )RETURN NUMBER;


END py_za_tx_01032006;


 

/
