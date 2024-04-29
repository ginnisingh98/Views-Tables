--------------------------------------------------------
--  DDL for Package PY_ZA_TX_01032000
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_TX_01032000" AUTHID CURRENT_USER AS
/* $Header: pyzat002.pkh 120.2 2005/06/28 00:10:28 kapalani noship $ */
/* Copyright (c) Oracle Corporation 1999. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation Tax Module
   NAME
      PY_ZA_TX_01032000.pkh

   DESCRIPTION
      This is the main tax package as used in the ZA Localisation Tax Module.
      The public functions in this package are not for client use and is
      only referenced by the tax formulae in the Application.

   PUBLIC FUNCTIONS

      ZaTxOvr_01032000
         This function is called from Oracle Applications Fast Formula.
         It facilitates the override functionality and sets relevant
         package globals.
      ZaTxGlb_01032000
         This function is called from Oracle Applications Fast Formula.
         It passes all necessary global values to the main tax package.
      ZaTxDbi_01032000
         This function is called from Oracle Applications Fast Formula.
         It passes all necessary Application Database Items to the
         main tax package.
      ZaTxBal1_01032000
         This function is called from Oracle Applications Fast Formula.
         It passes the first group of balances to the main tax package.
      ZaTxBal2_01032000
         This function is called from Oracle Applications Fast Formula.
         It passes the second group of balances to the main tax package.
      ZaTxBal3_01032000
         This function is called from Oracle Applications Fast Formula.
         It passes the third group of balances to the main tax package.
      ZaTx_01032000
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
   Person      Date(DD/MM/YYYY)  Version  Comments
   ---------   ----------------  -------  --------------------------------
   J.N. Louw   13/12/2000        110.9    Upped Header Ver for Patch
   J.N. Louw   06/12/2000        110.8    ZaTxDbi_01032000 spec cleaned
   J.N. Louw   02/10/2000        110.7    Tax Overrides:
                                             Function ZaTxOvr_01032000
                                             Override Globals
                                             Output Message
                                             Calculation Logic
                                          General Update to Balance
                                          Functions, updated list
                                          Removed redundents
   J.N. Louw   19/06/2000        110.6    ZA_ACTUAL_START_DATE Dbi Added
                                             Removed ASG_START_DATE Dbi
   J.N. Louw   12/04/2000        110.5    Added Calendar Month to Date
                                           Balances to cater for the
                                           calculation of Net Taxable Income
                                           Used in the calculation of the
                                           Skills Development Levy
   J.N. Louw   14-03-2000        110.4    Subsistence Change:
                                            CYTD Added
   J.N. Louw   06-03-2000        110.3    new:p_TOT_SEA_WRK_DYS_WRK
                                              p_SeaWrkDysErr
   J.N. Louw   25-02-2000        110.2    c/p_PAYE_PTD/p_PAYE_YTD
                                          c/p_SITE_PTD/p_SITE_YTD
   J.N. Louw   18-02-2000        110.1    Updated Balance Functions
                                             with new balances and
                                             re-ordered
   J.N. Louw   13-09-1999        110.0    First Created
*/
/* PACKAGE GLOBAL AREA */
-- Contexts
   con_ASG_ACT_ID NUMBER;
   con_ASG_ID     NUMBER;
   con_PRL_ACT_ID NUMBER;
   con_PRL_ID     NUMBER;
-- Global Values
   glb_ZA_ADL_TX_RBT       NUMBER;
   glb_ZA_ARR_PF_AN_MX_ABT NUMBER;
   glb_ZA_ARR_RA_AN_MX_ABT NUMBER;
   glb_ZA_TRV_ALL_TX_PRC   NUMBER;
   glb_ZA_CC_TX_PRC        NUMBER;
   glb_ZA_LABOUR_BROK_PERC NUMBER;
   glb_ZA_PF_AN_MX_ABT     NUMBER;
   glb_ZA_PF_MX_PRC        NUMBER;
   glb_ZA_PER_SERV_COMP_PERC NUMBER;
   glb_ZA_PRI_TX_RBT       NUMBER;
   glb_ZA_PRI_TX_THRSHLD   NUMBER;
   glb_ZA_PBL_TX_PRC       NUMBER;
   glb_ZA_PBL_TX_RTE       NUMBER;
   glb_ZA_RA_AN_MX_ABT     NUMBER;
   glb_ZA_RA_MX_PRC        NUMBER;
   glb_ZA_SC_TX_THRSHLD    NUMBER;
   glb_ZA_SIT_LIM          NUMBER;
   glb_ZA_TMP_TX_RTE       NUMBER;
   glb_ZA_WRK_DYS_PR_YR    NUMBER;
-- Database Items
   dbi_ARR_PF_FRQ          VARCHAR2(1);
   dbi_ARR_RA_FRQ          VARCHAR2(1);
   dbi_BP_TX_RCV           VARCHAR2(1);
   dbi_PER_AGE             NUMBER;
   dbi_PER_DTE_OF_BRTH     DATE;
   dbi_RA_FRQ              VARCHAR2(1);
   dbi_SEA_WRK_DYS_WRK     NUMBER;
   dbi_SES_DTE             DATE;
   dbi_TX_DIR_NUM          VARCHAR2(60);
   dbi_TX_DIR_VAL          NUMBER DEFAULT 25;
   dbi_TX_STA              VARCHAR2(1);
   dbi_ZA_ACT_END_DTE      DATE;
   dbi_ZA_ACT_STRT_DTE      DATE;
   dbi_ZA_CUR_PRD_END_DTE  DATE;
   dbi_ZA_CUR_PRD_STRT_DTE DATE;
   dbi_ZA_DYS_IN_YR        NUMBER;
   dbi_ZA_PAY_PRDS_LFT     NUMBER;
   dbi_ZA_PAY_PRDS_PER_YR  NUMBER;
   dbi_ZA_TX_YR_END        DATE;
   dbi_ZA_TX_YR_STRT       DATE;
-- Balances
   bal_AB_NRFI_CMTD               NUMBER(15,2);
   bal_AB_NRFI_RUN                NUMBER(15,2);
   bal_AB_NRFI_PTD                NUMBER(15,2);
   bal_AB_NRFI_YTD                NUMBER(15,2);
   bal_AB_RFI_CMTD                NUMBER(15,2);
   bal_AB_RFI_RUN                 NUMBER(15,2);
   bal_AB_RFI_PTD                 NUMBER(15,2);
   bal_AB_RFI_YTD                 NUMBER(15,2);
   bal_AC_NRFI_RUN                NUMBER(15,2);
   bal_AC_NRFI_PTD                NUMBER(15,2);
   bal_AC_NRFI_YTD                NUMBER(15,2);
   bal_AC_RFI_RUN                 NUMBER(15,2);
   bal_AC_RFI_PTD                 NUMBER(15,2);
   bal_AC_RFI_YTD                 NUMBER(15,2);
   bal_ANN_PF_CMTD                NUMBER(15,2);
   bal_ANN_PF_RUN                 NUMBER(15,2);
   bal_ANN_PF_PTD                 NUMBER(15,2);
   bal_ANN_PF_YTD                 NUMBER(15,2);
   bal_ANU_FRM_RET_FND_NRFI_CMTD  NUMBER(15,2);
   bal_ANU_FRM_RET_FND_NRFI_RUN   NUMBER(15,2);
   bal_ANU_FRM_RET_FND_NRFI_PTD   NUMBER(15,2);
   bal_ANU_FRM_RET_FND_NRFI_YTD   NUMBER(15,2);
   bal_ANU_FRM_RET_FND_RFI_CMTD   NUMBER(15,2);
   bal_ANU_FRM_RET_FND_RFI_RUN    NUMBER(15,2);
   bal_ANU_FRM_RET_FND_RFI_PTD    NUMBER(15,2);
   bal_ANU_FRM_RET_FND_RFI_YTD    NUMBER(15,2);
   bal_ARR_PF_CMTD                NUMBER(15,2);
   bal_ARR_PF_CYTD                NUMBER(15,2);
   bal_ARR_PF_PTD                 NUMBER(15,2);
   bal_ARR_PF_YTD                 NUMBER(15,2);
   bal_ARR_RA_CMTD                NUMBER(15,2);
   bal_ARR_RA_CYTD                NUMBER(15,2);
   bal_ARR_RA_PTD                 NUMBER(15,2);
   bal_ARR_RA_YTD                 NUMBER(15,2);
   bal_AST_PRCHD_RVAL_NRFI_CMTD   NUMBER(15,2);
   bal_AST_PRCHD_RVAL_NRFI_CYTD   NUMBER(15,2);
   bal_AST_PRCHD_RVAL_NRFI_RUN    NUMBER(15,2);
   bal_AST_PRCHD_RVAL_NRFI_PTD    NUMBER(15,2);
   bal_AST_PRCHD_RVAL_NRFI_YTD    NUMBER(15,2);
   bal_AST_PRCHD_RVAL_RFI_CMTD    NUMBER(15,2);
   bal_AST_PRCHD_RVAL_RFI_CYTD    NUMBER(15,2);
   bal_AST_PRCHD_RVAL_RFI_RUN     NUMBER(15,2);
   bal_AST_PRCHD_RVAL_RFI_PTD     NUMBER(15,2);
   bal_AST_PRCHD_RVAL_RFI_YTD     NUMBER(15,2);
   bal_BP_CMTD                    NUMBER(15,2);
   bal_BP_PTD                     NUMBER(15,2);
   bal_BP_YTD                     NUMBER(15,2);
   bal_BUR_AND_SCH_NRFI_CMTD      NUMBER(15,2);
   bal_BUR_AND_SCH_NRFI_CYTD      NUMBER(15,2);
   bal_BUR_AND_SCH_NRFI_RUN       NUMBER(15,2);
   bal_BUR_AND_SCH_NRFI_PTD       NUMBER(15,2);
   bal_BUR_AND_SCH_NRFI_YTD       NUMBER(15,2);
   bal_BUR_AND_SCH_RFI_CMTD       NUMBER(15,2);
   bal_BUR_AND_SCH_RFI_CYTD       NUMBER(15,2);
   bal_BUR_AND_SCH_RFI_RUN        NUMBER(15,2);
   bal_BUR_AND_SCH_RFI_PTD        NUMBER(15,2);
   bal_BUR_AND_SCH_RFI_YTD        NUMBER(15,2);
   bal_COMM_NRFI_CMTD             NUMBER(15,2);
   bal_COMM_NRFI_CYTD             NUMBER(15,2);
   bal_COMM_NRFI_RUN              NUMBER(15,2);
   bal_COMM_NRFI_PTD              NUMBER(15,2);
   bal_COMM_NRFI_YTD              NUMBER(15,2);
   bal_COMM_RFI_CMTD              NUMBER(15,2);
   bal_COMM_RFI_CYTD              NUMBER(15,2);
   bal_COMM_RFI_RUN               NUMBER(15,2);
   bal_COMM_RFI_PTD               NUMBER(15,2);
   bal_COMM_RFI_YTD               NUMBER(15,2);
   bal_COMP_ALL_NRFI_CMTD         NUMBER(15,2);
   bal_COMP_ALL_NRFI_CYTD         NUMBER(15,2);
   bal_COMP_ALL_NRFI_RUN          NUMBER(15,2);
   bal_COMP_ALL_NRFI_PTD          NUMBER(15,2);
   bal_COMP_ALL_NRFI_YTD          NUMBER(15,2);
   bal_COMP_ALL_RFI_CMTD          NUMBER(15,2);
   bal_COMP_ALL_RFI_CYTD          NUMBER(15,2);
   bal_COMP_ALL_RFI_RUN           NUMBER(15,2);
   bal_COMP_ALL_RFI_PTD           NUMBER(15,2);
   bal_COMP_ALL_RFI_YTD           NUMBER(15,2);
   bal_CUR_PF_CMTD                NUMBER(15,2);
   bal_CUR_PF_CYTD                NUMBER(15,2);
   bal_CUR_PF_RUN                 NUMBER(15,2);
   bal_CUR_PF_PTD                 NUMBER(15,2);
   bal_CUR_PF_YTD                 NUMBER(15,2);
   bal_CUR_RA_CMTD                NUMBER(15,2);
   bal_CUR_RA_CYTD                NUMBER(15,2);
   bal_CUR_RA_RUN                 NUMBER(15,2);
   bal_CUR_RA_PTD                 NUMBER(15,2);
   bal_CUR_RA_YTD                 NUMBER(15,2);
   bal_ENT_ALL_NRFI_CMTD          NUMBER(15,2);
   bal_ENT_ALL_NRFI_CYTD          NUMBER(15,2);
   bal_ENT_ALL_NRFI_RUN           NUMBER(15,2);
   bal_ENT_ALL_NRFI_PTD           NUMBER(15,2);
   bal_ENT_ALL_NRFI_YTD           NUMBER(15,2);
   bal_ENT_ALL_RFI_CMTD           NUMBER(15,2);
   bal_ENT_ALL_RFI_CYTD           NUMBER(15,2);
   bal_ENT_ALL_RFI_RUN            NUMBER(15,2);
   bal_ENT_ALL_RFI_PTD            NUMBER(15,2);
   bal_ENT_ALL_RFI_YTD            NUMBER(15,2);
   bal_EXC_ARR_PEN_ITD            NUMBER(15,2);
   bal_EXC_ARR_PEN_PTD            NUMBER(15,2);
   bal_EXC_ARR_PEN_YTD            NUMBER(15,2);
   bal_EXC_ARR_RA_ITD             NUMBER(15,2);
   bal_EXC_ARR_RA_PTD             NUMBER(15,2);
   bal_EXC_ARR_RA_YTD             NUMBER(15,2);
   bal_FREE_ACCOM_NRFI_CMTD       NUMBER(15,2);
   bal_FREE_ACCOM_NRFI_CYTD       NUMBER(15,2);
   bal_FREE_ACCOM_NRFI_RUN        NUMBER(15,2);
   bal_FREE_ACCOM_NRFI_PTD        NUMBER(15,2);
   bal_FREE_ACCOM_NRFI_YTD        NUMBER(15,2);
   bal_FREE_ACCOM_RFI_CMTD        NUMBER(15,2);
   bal_FREE_ACCOM_RFI_CYTD        NUMBER(15,2);
   bal_FREE_ACCOM_RFI_RUN         NUMBER(15,2);
   bal_FREE_ACCOM_RFI_PTD         NUMBER(15,2);
   bal_FREE_ACCOM_RFI_YTD         NUMBER(15,2);
   bal_FREE_SERV_NRFI_CMTD        NUMBER(15,2);
   bal_FREE_SERV_NRFI_CYTD        NUMBER(15,2);
   bal_FREE_SERV_NRFI_RUN         NUMBER(15,2);
   bal_FREE_SERV_NRFI_PTD         NUMBER(15,2);
   bal_FREE_SERV_NRFI_YTD         NUMBER(15,2);
   bal_FREE_SERV_RFI_CMTD         NUMBER(15,2);
   bal_FREE_SERV_RFI_CYTD         NUMBER(15,2);
   bal_FREE_SERV_RFI_RUN          NUMBER(15,2);
   bal_FREE_SERV_RFI_PTD          NUMBER(15,2);
   bal_FREE_SERV_RFI_YTD          NUMBER(15,2);
   bal_LOW_LOANS_NRFI_CMTD        NUMBER(15,2);
   bal_LOW_LOANS_NRFI_CYTD        NUMBER(15,2);
   bal_LOW_LOANS_NRFI_RUN         NUMBER(15,2);
   bal_LOW_LOANS_NRFI_PTD         NUMBER(15,2);
   bal_LOW_LOANS_NRFI_YTD         NUMBER(15,2);
   bal_LOW_LOANS_RFI_CMTD         NUMBER(15,2);
   bal_LOW_LOANS_RFI_CYTD         NUMBER(15,2);
   bal_LOW_LOANS_RFI_RUN          NUMBER(15,2);
   bal_LOW_LOANS_RFI_PTD          NUMBER(15,2);
   bal_LOW_LOANS_RFI_YTD          NUMBER(15,2);
   bal_MLS_AND_VOUCH_NRFI_CMTD    NUMBER(15,2);
   bal_MLS_AND_VOUCH_NRFI_CYTD    NUMBER(15,2);
   bal_MLS_AND_VOUCH_NRFI_RUN     NUMBER(15,2);
   bal_MLS_AND_VOUCH_NRFI_PTD     NUMBER(15,2);
   bal_MLS_AND_VOUCH_NRFI_YTD     NUMBER(15,2);
   bal_MLS_AND_VOUCH_RFI_CMTD     NUMBER(15,2);
   bal_MLS_AND_VOUCH_RFI_CYTD     NUMBER(15,2);
   bal_MLS_AND_VOUCH_RFI_RUN      NUMBER(15,2);
   bal_MLS_AND_VOUCH_RFI_PTD      NUMBER(15,2);
   bal_MLS_AND_VOUCH_RFI_YTD      NUMBER(15,2);
   bal_MED_CONTR_CMTD             NUMBER(15,2);
   bal_MED_CONTR_CYTD             NUMBER(15,2);
   bal_MED_CONTR_RUN              NUMBER(15,2);
   bal_MED_CONTR_PTD              NUMBER(15,2);
   bal_MED_CONTR_YTD              NUMBER(15,2);
   bal_MED_PAID_NRFI_CMTD         NUMBER(15,2);
   bal_MED_PAID_NRFI_CYTD         NUMBER(15,2);
   bal_MED_PAID_NRFI_RUN          NUMBER(15,2);
   bal_MED_PAID_NRFI_PTD          NUMBER(15,2);
   bal_MED_PAID_NRFI_YTD          NUMBER(15,2);
   bal_MED_PAID_RFI_CMTD          NUMBER(15,2);
   bal_MED_PAID_RFI_CYTD          NUMBER(15,2);
   bal_MED_PAID_RFI_RUN           NUMBER(15,2);
   bal_MED_PAID_RFI_PTD           NUMBER(15,2);
   bal_MED_PAID_RFI_YTD           NUMBER(15,2);
   bal_NET_PAY_RUN                NUMBER(15,2);
   bal_NET_TXB_INC_CMTD           NUMBER(15,2);
   bal_OTHER_TXB_ALL_NRFI_CMTD    NUMBER(15,2);
   bal_OTHER_TXB_ALL_NRFI_CYTD    NUMBER(15,2);
   bal_OTHER_TXB_ALL_NRFI_RUN     NUMBER(15,2);
   bal_OTHER_TXB_ALL_NRFI_PTD     NUMBER(15,2);
   bal_OTHER_TXB_ALL_NRFI_YTD     NUMBER(15,2);
   bal_OTHER_TXB_ALL_RFI_CMTD     NUMBER(15,2);
   bal_OTHER_TXB_ALL_RFI_CYTD     NUMBER(15,2);
   bal_OTHER_TXB_ALL_RFI_RUN      NUMBER(15,2);
   bal_OTHER_TXB_ALL_RFI_PTD      NUMBER(15,2);
   bal_OTHER_TXB_ALL_RFI_YTD      NUMBER(15,2);
   bal_OVTM_NRFI_CMTD             NUMBER(15,2);
   bal_OVTM_NRFI_CYTD             NUMBER(15,2);
   bal_OVTM_NRFI_RUN              NUMBER(15,2);
   bal_OVTM_NRFI_PTD              NUMBER(15,2);
   bal_OVTM_NRFI_YTD              NUMBER(15,2);
   bal_OVTM_RFI_CMTD              NUMBER(15,2);
   bal_OVTM_RFI_CYTD              NUMBER(15,2);
   bal_OVTM_RFI_RUN               NUMBER(15,2);
   bal_OVTM_RFI_PTD               NUMBER(15,2);
   bal_OVTM_RFI_YTD               NUMBER(15,2);
   bal_PAYE_YTD                   NUMBER(15,2);
   bal_PYM_DBT_NRFI_CMTD          NUMBER(15,2);
   bal_PYM_DBT_NRFI_CYTD          NUMBER(15,2);
   bal_PYM_DBT_NRFI_RUN           NUMBER(15,2);
   bal_PYM_DBT_NRFI_PTD           NUMBER(15,2);
   bal_PYM_DBT_NRFI_YTD           NUMBER(15,2);
   bal_PYM_DBT_RFI_CMTD           NUMBER(15,2);
   bal_PYM_DBT_RFI_CYTD           NUMBER(15,2);
   bal_PYM_DBT_RFI_RUN            NUMBER(15,2);
   bal_PYM_DBT_RFI_PTD            NUMBER(15,2);
   bal_PYM_DBT_RFI_YTD            NUMBER(15,2);
   bal_PO_NRFI_CMTD               NUMBER(15,2);
   bal_PO_NRFI_RUN                NUMBER(15,2);
   bal_PO_NRFI_PTD                NUMBER(15,2);
   bal_PO_NRFI_YTD                NUMBER(15,2);
   bal_PO_RFI_CMTD                NUMBER(15,2);
   bal_PO_RFI_RUN                 NUMBER(15,2);
   bal_PO_RFI_PTD                 NUMBER(15,2);
   bal_PO_RFI_YTD                 NUMBER(15,2);
   bal_PRCH_ANU_TXB_NRFI_CMTD     NUMBER(15,2);
   bal_PRCH_ANU_TXB_NRFI_RUN      NUMBER(15,2);
   bal_PRCH_ANU_TXB_NRFI_PTD      NUMBER(15,2);
   bal_PRCH_ANU_TXB_NRFI_YTD      NUMBER(15,2);
   bal_PRCH_ANU_TXB_RFI_CMTD      NUMBER(15,2);
   bal_PRCH_ANU_TXB_RFI_RUN       NUMBER(15,2);
   bal_PRCH_ANU_TXB_RFI_PTD       NUMBER(15,2);
   bal_PRCH_ANU_TXB_RFI_YTD       NUMBER(15,2);
   bal_RGT_AST_NRFI_CMTD          NUMBER(15,2);
   bal_RGT_AST_NRFI_CYTD          NUMBER(15,2);
   bal_RGT_AST_NRFI_RUN           NUMBER(15,2);
   bal_RGT_AST_NRFI_PTD           NUMBER(15,2);
   bal_RGT_AST_NRFI_YTD           NUMBER(15,2);
   bal_RGT_AST_RFI_CMTD           NUMBER(15,2);
   bal_RGT_AST_RFI_CYTD           NUMBER(15,2);
   bal_RGT_AST_RFI_RUN            NUMBER(15,2);
   bal_RGT_AST_RFI_PTD            NUMBER(15,2);
   bal_RGT_AST_RFI_YTD            NUMBER(15,2);
   bal_SITE_YTD                   NUMBER(15,2);
   bal_TAX_YTD                    NUMBER(15,2);
   bal_TX_ON_AB_PTD               NUMBER(15,2);
   bal_TX_ON_AB_YTD               NUMBER(15,2);
   bal_TX_ON_AP_RUN               NUMBER(15,2);
   bal_TX_ON_AP_PTD               NUMBER(15,2);
   bal_TX_ON_AP_YTD               NUMBER(15,2);
   bal_TX_ON_BP_PTD               NUMBER(15,2);
   bal_TX_ON_BP_YTD               NUMBER(15,2);
   bal_TX_ON_TA_PTD               NUMBER(15,2);
   bal_TX_ON_TA_YTD               NUMBER(15,2);
   bal_TX_ON_FB_PTD               NUMBER(15,2);
   bal_TX_ON_FB_YTD               NUMBER(15,2);
   bal_TX_ON_NI_PTD               NUMBER(15,2);
   bal_TX_ON_NI_YTD               NUMBER(15,2);
   bal_TX_ON_PO_PTD               NUMBER(15,2);
   bal_TX_ON_PO_YTD               NUMBER(15,2);
   bal_TXB_AP_NRFI_CMTD           NUMBER(15,2);
   bal_TXB_AP_NRFI_RUN            NUMBER(15,2);
   bal_TXB_AP_NRFI_PTD            NUMBER(15,2);
   bal_TXB_AP_NRFI_YTD            NUMBER(15,2);
   bal_TXB_AP_RFI_CMTD            NUMBER(15,2);
   bal_TXB_AP_RFI_RUN             NUMBER(15,2);
   bal_TXB_AP_RFI_PTD             NUMBER(15,2);
   bal_TXB_AP_RFI_YTD             NUMBER(15,2);
   bal_TXB_INC_NRFI_CMTD          NUMBER(15,2);
   bal_TXB_INC_NRFI_CYTD          NUMBER(15,2);
   bal_TXB_INC_NRFI_RUN           NUMBER(15,2);
   bal_TXB_INC_NRFI_PTD           NUMBER(15,2);
   bal_TXB_INC_NRFI_YTD           NUMBER(15,2);
   bal_TXB_INC_RFI_CMTD           NUMBER(15,2);
   bal_TXB_INC_RFI_CYTD           NUMBER(15,2);
   bal_TXB_INC_RFI_RUN            NUMBER(15,2);
   bal_TXB_INC_RFI_PTD            NUMBER(15,2);
   bal_TXB_INC_RFI_YTD            NUMBER(15,2);
   bal_TXB_PEN_NRFI_CMTD          NUMBER(15,2);
   bal_TXB_PEN_NRFI_CYTD          NUMBER(15,2);
   bal_TXB_PEN_NRFI_RUN           NUMBER(15,2);
   bal_TXB_PEN_NRFI_PTD           NUMBER(15,2);
   bal_TXB_PEN_NRFI_YTD           NUMBER(15,2);
   bal_TXB_PEN_RFI_CMTD           NUMBER(15,2);
   bal_TXB_PEN_RFI_CYTD           NUMBER(15,2);
   bal_TXB_PEN_RFI_RUN            NUMBER(15,2);
   bal_TXB_PEN_RFI_PTD            NUMBER(15,2);
   bal_TXB_PEN_RFI_YTD            NUMBER(15,2);
   bal_TEL_ALL_NRFI_CMTD          NUMBER(15,2);
   bal_TEL_ALL_NRFI_CYTD          NUMBER(15,2);
   bal_TEL_ALL_NRFI_RUN           NUMBER(15,2);
   bal_TEL_ALL_NRFI_PTD           NUMBER(15,2);
   bal_TEL_ALL_NRFI_YTD           NUMBER(15,2);
   bal_TEL_ALL_RFI_CMTD           NUMBER(15,2);
   bal_TEL_ALL_RFI_CYTD           NUMBER(15,2);
   bal_TEL_ALL_RFI_RUN            NUMBER(15,2);
   bal_TEL_ALL_RFI_PTD            NUMBER(15,2);
   bal_TEL_ALL_RFI_YTD            NUMBER(15,2);
   bal_TOOL_ALL_NRFI_CMTD         NUMBER(15,2);
   bal_TOOL_ALL_NRFI_CYTD         NUMBER(15,2);
   bal_TOOL_ALL_NRFI_RUN          NUMBER(15,2);
   bal_TOOL_ALL_NRFI_PTD          NUMBER(15,2);
   bal_TOOL_ALL_NRFI_YTD          NUMBER(15,2);
   bal_TOOL_ALL_RFI_CMTD          NUMBER(15,2);
   bal_TOOL_ALL_RFI_CYTD          NUMBER(15,2);
   bal_TOOL_ALL_RFI_RUN           NUMBER(15,2);
   bal_TOOL_ALL_RFI_PTD           NUMBER(15,2);
   bal_TOOL_ALL_RFI_YTD           NUMBER(15,2);
   bal_TOT_INC_PTD                NUMBER(15,2);
   bal_TOT_INC_YTD                NUMBER(15,2);
   bal_TOT_NRFI_AN_INC_CMTD       NUMBER(15,2);
   bal_TOT_NRFI_AN_INC_CYTD       NUMBER(15,2);
   bal_TOT_NRFI_AN_INC_RUN        NUMBER(15,2);
   bal_TOT_NRFI_AN_INC_PTD        NUMBER(15,2);
   bal_TOT_NRFI_AN_INC_YTD        NUMBER(15,2);
   bal_TOT_NRFI_INC_CMTD          NUMBER(15,2);
   bal_TOT_NRFI_INC_CYTD          NUMBER(15,2);
   bal_TOT_NRFI_INC_RUN           NUMBER(15,2);
   bal_TOT_NRFI_INC_PTD           NUMBER(15,2);
   bal_TOT_NRFI_INC_YTD           NUMBER(15,2);
   bal_TOT_RFI_AN_INC_CMTD        NUMBER(15,2);
   bal_TOT_RFI_AN_INC_CYTD        NUMBER(15,2);
   bal_TOT_RFI_AN_INC_RUN         NUMBER(15,2);
   bal_TOT_RFI_AN_INC_PTD         NUMBER(15,2);
   bal_TOT_RFI_AN_INC_YTD         NUMBER(15,2);
   bal_TOT_RFI_INC_CMTD           NUMBER(15,2);
   bal_TOT_RFI_INC_CYTD           NUMBER(15,2);
   bal_TOT_RFI_INC_RUN            NUMBER(15,2);
   bal_TOT_RFI_INC_PTD            NUMBER(15,2);
   bal_TOT_RFI_INC_YTD            NUMBER(15,2);
   bal_TOT_SEA_WRK_DYS_WRK_YTD    NUMBER(15,2);
   bal_TOT_TXB_INC_ITD            NUMBER(15,2);
   bal_TA_NRFI_CMTD               NUMBER(15,2);
   bal_TA_NRFI_CYTD               NUMBER(15,2);
   bal_TA_NRFI_PTD                NUMBER(15,2);
   bal_TA_NRFI_YTD                NUMBER(15,2);
   bal_TA_RFI_CMTD                NUMBER(15,2);
   bal_TA_RFI_CYTD                NUMBER(15,2);
   bal_TA_RFI_PTD                 NUMBER(15,2);
   bal_TA_RFI_YTD                 NUMBER(15,2);
   bal_USE_VEH_NRFI_CMTD          NUMBER(15,2);
   bal_USE_VEH_NRFI_CYTD          NUMBER(15,2);
   bal_USE_VEH_NRFI_RUN           NUMBER(15,2);
   bal_USE_VEH_NRFI_PTD           NUMBER(15,2);
   bal_USE_VEH_NRFI_YTD           NUMBER(15,2);
   bal_USE_VEH_RFI_CMTD           NUMBER(15,2);
   bal_USE_VEH_RFI_CYTD           NUMBER(15,2);
   bal_USE_VEH_RFI_RUN            NUMBER(15,2);
   bal_USE_VEH_RFI_PTD            NUMBER(15,2);
   bal_USE_VEH_RFI_YTD            NUMBER(15,2);



-- Trace Globals
--   These are set within the procedures and function calls!!
--   Values can be output by the main function call from formula
--
  -- Calculation Type
  trc_CalTyp       VARCHAR2(7) DEFAULT 'Unknown';
  -- Factors
  trc_TxbIncPtd    NUMBER(15,2) DEFAULT 0;
  trc_PrdFactor    NUMBER DEFAULT 0;
  trc_PosFactor    NUMBER DEFAULT 0;
  trc_SitFactor    NUMBER DEFAULT 1;
  -- Base Income
  trc_BseErn       NUMBER(15,2) DEFAULT 0;
  trc_TxbBseInc    NUMBER(15,2) DEFAULT 0;
  trc_TotLibBse    NUMBER(15,2) DEFAULT 0;
  -- Period Pension Fund
  trc_TxbIncYtd    NUMBER(15,2) DEFAULT 0;
  trc_PerTxbInc    NUMBER(15,2) DEFAULT 0;
  trc_PerPenFnd    NUMBER(15,2) DEFAULT 0;
  trc_PerRfiCon    NUMBER(15,2) DEFAULT 0;
  trc_PerRfiTxb    NUMBER(15,2) DEFAULT 0;
  trc_PerPenFndMax NUMBER(15,2) DEFAULT 0;
  trc_PerPenFndAbm NUMBER(15,2) DEFAULT 0;
  -- Annual Pension Fund
  trc_AnnTxbInc    NUMBER(15,2) DEFAULT 0;
  trc_AnnPenFnd    NUMBER(15,2) DEFAULT 0;
  trc_AnnRfiCon    NUMBER(15,2) DEFAULT 0;
  trc_AnnRfiTxb    NUMBER(15,2) DEFAULT 0;
  trc_AnnPenFndMax NUMBER(15,2) DEFAULT 0;
  trc_AnnPenFndAbm NUMBER(15,2) DEFAULT 0;
  -- Arrear Pension
  trc_ArrPenFnd    NUMBER(15,2) DEFAULT 0;
  trc_ArrPenFndAbm NUMBER(15,2) DEFAULT 0;
  trc_PfUpdFig     NUMBER(15,2) DEFAULT 0;
  -- Retirement Annuity
  trc_RetAnu       NUMBER(15,2) DEFAULT 0;
  trc_NrfiCon      NUMBER(15,2) DEFAULT 0;
  trc_RetAnuMax    NUMBER(15,2) DEFAULT 0;
  trc_RetAnuAbm    NUMBER(15,2) DEFAULT 0;
  -- Arrear Retirement Annuity
  trc_ArrRetAnu    NUMBER(15,2) DEFAULT 0;
  trc_ArrRetAnuAbm NUMBER(15,2) DEFAULT 0;
  trc_RaUpdFig     NUMBER(15,2) DEFAULT 0;
  -- Rebates Thresholds and Med Aid
  trc_Rebate       NUMBER(15,2) DEFAULT 0;
  trc_Threshold    NUMBER(15,2) DEFAULT 0;
  trc_MedAidAbm    NUMBER(15,2) DEFAULT 0;
  -- Abatement Totals
  trc_PerTotAbm    NUMBER(15,2) DEFAULT 0;
  trc_AnnTotAbm    NUMBER(15,2) DEFAULT 0;
  -- Normal Income
  trc_NorIncYtd    NUMBER(15,2) DEFAULT 0;
  trc_NorIncPtd    NUMBER(15,2) DEFAULT 0;
  trc_NorErn       NUMBER(15,2) DEFAULT 0;
  trc_TxbNorInc    NUMBER(15,2) DEFAULT 0;
  trc_TotLibNI     NUMBER(15,2) DEFAULT 0;
  trc_LibFyNI      NUMBER(15,2) DEFAULT 0;
  trc_LibFpNI      NUMBER(15,2) DEFAULT 0;
  -- Fringe Benefits
  trc_FrnBenYtd    NUMBER(15,2) DEFAULT 0;
  trc_FrnBenPtd    NUMBER(15,2) DEFAULT 0;
  trc_FrnBenErn    NUMBER(15,2) DEFAULT 0;
  trc_TxbFrnInc    NUMBER(15,2) DEFAULT 0;
  trc_TotLibFB     NUMBER(15,2) DEFAULT 0;
  trc_LibFyFB      NUMBER(15,2) DEFAULT 0;
  trc_LibFpFB      NUMBER(15,2) DEFAULT 0;
  -- Travel Allowance
  trc_TrvAllYtd    NUMBER(15,2) DEFAULT 0;
  trc_TrvAllPtd    NUMBER(15,2) DEFAULT 0;
  trc_TrvAllErn    NUMBER(15,2) DEFAULT 0;
  trc_TxbTrvInc    NUMBER(15,2) DEFAULT 0;
  trc_TotLibTA     NUMBER(15,2) DEFAULT 0;
  trc_LibFyTA      NUMBER(15,2) DEFAULT 0;
  trc_LibFpTA      NUMBER(15,2) DEFAULT 0;
  -- Bonus Provision
  trc_BonProYtd    NUMBER(15,2) DEFAULT 0;
  trc_BonProPtd    NUMBER(15,2) DEFAULT 0;
  trc_BonProErn    NUMBER(15,2) DEFAULT 0;
  trc_TxbBonProInc NUMBER(15,2) DEFAULT 0;
  trc_TotLibBP     NUMBER(15,2) DEFAULT 0;
  trc_LibFyBP      NUMBER(15,2) DEFAULT 0;
  trc_LibFpBP      NUMBER(15,2) DEFAULT 0;
  -- Annual Bonus
  trc_AnnBonYtd    NUMBER(15,2) DEFAULT 0;
  trc_AnnBonPtd    NUMBER(15,2) DEFAULT 0;
  trc_AnnBonErn    NUMBER(15,2) DEFAULT 0;
  trc_TxbAnnBonInc NUMBER(15,2) DEFAULT 0;
  trc_TotLibAB     NUMBER(15,2) DEFAULT 0;
  trc_LibFyAB      NUMBER(15,2) DEFAULT 0;
  trc_LibFpAB      NUMBER(15,2) DEFAULT 0;
  -- Annual Payments
  trc_AnnPymYtd    NUMBER(15,2) DEFAULT 0;
  trc_AnnPymPtd    NUMBER(15,2) DEFAULT 0;
  trc_AnnPymErn    NUMBER(15,2) DEFAULT 0;
  trc_TxbAnnPymInc NUMBER(15,2) DEFAULT 0;
  trc_TotLibAP     NUMBER(15,2) DEFAULT 0;
  trc_LibFyAP      NUMBER(15,2) DEFAULT 0;
  trc_LibFpAP      NUMBER(15,2) DEFAULT 0;
  -- Pubilc Office Allowance
  trc_PblOffYtd    NUMBER(15,2) DEFAULT 0;
  trc_PblOffPtd    NUMBER(15,2) DEFAULT 0;
  trc_PblOffErn    NUMBER(15,2) DEFAULT 0;
  trc_LibFyPO      NUMBER(15,2) DEFAULT 0;
  trc_LibFpPO      NUMBER(15,2) DEFAULT 0;
  -- Messages
  trc_LibWrn       VARCHAR2(100) DEFAULT ' ';

  -- Pay Value of This Calculation
  trc_PayValue     NUMBER(15,2) DEFAULT 0;
  -- PAYE and SITE Values
  trc_PayeVal      NUMBER(15,2) DEFAULT 0;
  trc_SiteVal      NUMBER(15,2) DEFAULT 0;
  -- IT3A Threshold Indicator
  trc_It3Ind       NUMBER DEFAULT 0;
  -- Tax Percentage Value On trace
  trc_TxPercVal    NUMBER DEFAULT 0;
  -- Total Taxable Income Update Figure
  trc_OUpdFig      NUMBER(15,2) DEFAULT 0;

  -- Net Taxable Income Update Figure
  trc_NtiUpdFig    NUMBER(15,2) DEFAULT 0;

  -- NpVal Override Globals
  trc_NpValNIOvr   BOOLEAN DEFAULT FALSE;
  trc_NpValFBOvr   BOOLEAN DEFAULT FALSE;
  trc_NpValTAOvr   BOOLEAN DEFAULT FALSE;
  trc_NpValBPOvr   BOOLEAN DEFAULT FALSE;
  trc_NpValABOvr   BOOLEAN DEFAULT FALSE;
  trc_NpValAPOvr   BOOLEAN DEFAULT FALSE;
  trc_NpValPOOvr   BOOLEAN DEFAULT FALSE;

  -- Assignment Tax Year
  trc_AsgTxYear    NUMBER(15) DEFAULT 0;

  -- Global Exception Message
  xpt_Msg VARCHAR2(100) DEFAULT 'No Error';
  -- Global Exception
  xpt_E EXCEPTION;

  -- Override Globals
  trc_OvrTxCalc   BOOLEAN DEFAULT FALSE;
  trc_OvrTyp      VARCHAR2(1) DEFAULT 'V';
  trc_OvrPrc      NUMBER(3) DEFAULT 0;
  trc_OvrWrn      VARCHAR2(150) DEFAULT ' ';

  -- Retro Global
  trc_RetroInPeriod BOOLEAN DEFAULT FALSE;
-- Function to Override Tax Calculation
--
FUNCTION ZaTxOvr_01032000(
    p_OvrTyp IN VARCHAR2
   ,p_TxOnNI IN NUMBER DEFAULT 0
   ,p_TxOnAP IN NUMBER DEFAULT 0
   ,p_TxPrc  IN NUMBER DEFAULT 0
   )RETURN NUMBER;


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
   ) RETURN NUMBER;

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
  ) RETURN NUMBER;


-- Function to Initialise Globals - Balance Values
-- First Section
FUNCTION ZaTxBal1_01032000(
-- Balances
    p_AB_NRFI_CMTD               IN NUMBER DEFAULT 0
   ,p_AB_NRFI_RUN                IN NUMBER DEFAULT 0
   ,p_AB_NRFI_PTD                IN NUMBER DEFAULT 0
   ,p_AB_NRFI_YTD                IN NUMBER DEFAULT 0
   ,p_AB_RFI_CMTD               IN NUMBER DEFAULT 0
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
   ) RETURN NUMBER;


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
   ) RETURN NUMBER;


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
   ) RETURN NUMBER;

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
   ) RETURN NUMBER;

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
  , p_LibWrn    OUT NOCOPY VARCHAR2
  , p_LibFpNI   OUT NOCOPY NUMBER
  , p_LibFpFB   OUT NOCOPY NUMBER
  , p_LibFpTA   OUT NOCOPY NUMBER
  , p_LibFpBP   OUT NOCOPY NUMBER
  , p_LibFpAB   OUT NOCOPY NUMBER
  , p_LibFpAP   OUT NOCOPY NUMBER
  , p_LibFpPO   OUT NOCOPY NUMBER
  , p_PayValue  OUT NOCOPY NUMBER
  , p_PayeVal   OUT NOCOPY NUMBER
  , p_SiteVal   OUT NOCOPY NUMBER
  , p_It3Ind    OUT NOCOPY NUMBER
  , p_PfUpdFig  OUT NOCOPY NUMBER
  , p_RaUpdFig  OUT NOCOPY NUMBER
  , p_OUpdFig   OUT NOCOPY NUMBER
  , p_NtiUpdFig OUT NOCOPY NUMBER
  , p_OvrWrn    OUT NOCOPY VARCHAR2
  )RETURN NUMBER;





END py_za_tx_01032000;


 

/
