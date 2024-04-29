--------------------------------------------------------
--  DDL for Package PY_ZA_TOTAL_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_TOTAL_PACKAGE" AUTHID CURRENT_USER AS
/* $Header: pyzatotpkg.pkh 120.0.12000000.2 2007/06/29 08:43:24 rpahune noship $ */
/* Copyright (c) Oracle Corporation 2005. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation

   NAME
      py_za_total_package

   DESCRIPTION

   NOTES
      .

   MODIFICATION HISTORY
      Person      Date        Version Bug     Comments
      ---------   ----------- ------- ------- ---------------------------------
      J.N. Louw   04/04/2007  115.2   5964600
      J.N. Louw   14/09/2005  115.1   4566053 Added annualisation to the split
      R.V. Pahune 05/08/2005  115.0   4346920 Balance feed enhancement
      J.N. Louw   17/08/2005  115.0           Initial Version
*/

-------------------------------------------------------------------------------
--                           PACKAGE GLOBAL AREA                             --
-------------------------------------------------------------------------------
-- hr_utility wrapper globals
   g_HrTraceEnabled  BOOLEAN DEFAULT FALSE;
   g_HrTracePipeName VARCHAR2(30);
-- Indent
   g_indent          VARCHAR2(30);
-------------------------------------------------------------------------------
--                           PACKAGE SPECIFICATION                           --
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
  ) RETURN NUMBER;

END py_za_total_package;


 

/
