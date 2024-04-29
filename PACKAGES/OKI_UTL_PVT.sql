--------------------------------------------------------
--  DDL for Package OKI_UTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_UTL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRUTLS.pls 115.17 2002/12/01 17:51:10 rpotnuru noship $ */

--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_UTL_PVT
-- Type       : Process
-- Purpose    : This package contains procedure and functions that are common
--              to other packages
-- Modification History
-- 16-Jul-2001  mezra         Created
-- 20-Sep-2001  mezra         Added get_aging_label function.
-- 27-Sep-2001  mezra         Change get_period_set, get_period_type,
--                            get_period_name to take a parameter value
--                            that is defaulted to to null.
-- 01-Oct-2001  mezra         Added function to determine the start and
--                            end value of the age grouping.
--                            Added function to get the bin title for the
--                            aging detail bin.
-- 19-Dec-2001 mezra          Added function get_aging_label1,
--                            get_aging_label2, get_aging_label3,
--                            get_aging_label4 to get the aging label for
--                            column.
-- 26-Dec-2001 mezra          Added cursors that are used across packages:
--                            g_tactk_all_csr, g_tactk_by_org_csr,
--                            g_rnwl_oppty_all_csr, g_rnwl_oppty_by_org_csr,
--                            g_k_exp_in_qtr_all_csr, g_k_exp_in_qtr_by_org_csr,
--                            g_org_csr.
--                            Added get_bin_title2 to retrieve the title for the
--                            drilldown bins.
-- 26-Dec-2001 mezra          Added function to default the build summary date.
-- 04-Jan-2002 mezra          Remove all functions and procedures for the bin.
-- 08-Apr-2002 mezra          Added g_bin_disp_lkup_csr cursor to retrieve bin
--                            display lookup details.
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
  -- Global cursor to get gl_periods data

--------------------------------------------------------------------------------
  CURSOR g_glpr_csr
  (   p_period_set_name    IN VARCHAR2
    , p_period_type        IN VARCHAR2
    , p_summary_build_date IN DATE ) RETURN gl_periods%ROWTYPE ;

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
  TYPE g_tactk_all_csr_row IS RECORD
  (
     value          oki_sales_k_hdrs.base_contract_amount%TYPE
   , contract_count oki_sales_k_hdrs.chr_id%TYPE
  ) ;

  CURSOR g_tactk_all_csr
  (
     p_start_date IN DATE
  ) RETURN g_tactk_all_csr_row ;


  TYPE g_tactk_by_org_csr_row IS RECORD
  (
     value             oki_sales_k_hdrs.base_contract_amount%TYPE
   , contract_count    oki_sales_k_hdrs.chr_id%TYPE
   , authoring_org_id  oki_sales_k_hdrs.authoring_org_id%TYPE
  ) ;

  CURSOR g_tactk_by_org_csr
  (
     p_start_date       IN DATE
   , p_authoring_org_id IN NUMBER
  ) RETURN g_tactk_by_org_csr_row ;


  TYPE g_rnwl_oppty_all_csr_row IS RECORD
  (
     value            oki_sales_k_hdrs.base_contract_amount%TYPE
   , contract_count   oki_sales_k_hdrs.chr_id%TYPE
  ) ;

  CURSOR g_rnwl_oppty_all_csr
  (
     p_qtr_end_date       IN DATE
  ) RETURN g_rnwl_oppty_all_csr_row ;

  TYPE g_rnwl_oppty_by_org_csr_row IS RECORD
  (
     value            oki_sales_k_hdrs.base_contract_amount%TYPE
   , contract_count   oki_sales_k_hdrs.chr_id%TYPE
  ) ;

  CURSOR g_rnwl_oppty_by_org_csr
  (
     p_qtr_end_date     IN DATE
   , p_authoring_org_id IN NUMBER
  ) RETURN g_rnwl_oppty_by_org_csr_row ;


  TYPE g_k_exp_in_qtr_all_csr_row IS RECORD
  (
     value            oki_sales_k_hdrs.base_contract_amount%TYPE
   , contract_count   oki_sales_k_hdrs.chr_id%TYPE
  ) ;

  CURSOR g_k_exp_in_qtr_all_csr
  (
     p_qtr_start_date     IN DATE
   , p_qtr_end_date       IN DATE
  ) RETURN g_k_exp_in_qtr_all_csr_row ;


  TYPE g_k_exp_in_qtr_by_org_csr_row IS RECORD
  (
     value            oki_sales_k_hdrs.base_contract_amount%TYPE
   , contract_count   oki_sales_k_hdrs.chr_id%TYPE
  ) ;

  CURSOR g_k_exp_in_qtr_by_org_csr
  (
     p_qtr_start_date   IN DATE
   , p_qtr_end_date     IN DATE
   , p_authoring_org_id IN NUMBER
  ) RETURN g_k_exp_in_qtr_by_org_csr_row ;


  --
  -- Cursor to return the distinct authoring_org_id and
  -- organization_name from the oki_sales_k_hdrs table
  --
  TYPE g_org_csr_row IS RECORD
  (
     authoring_org_id  oki_sales_k_hdrs.authoring_org_id%TYPE
   , organization_name oki_sales_k_hdrs.organization_name%TYPE
  ) ;

  CURSOR g_org_csr RETURN g_org_csr_row ;

  --
  -- Cursor to return the bin metadata
  --
  TYPE g_bin_disp_lkup_csr_row IS RECORD
  (
     bin_code_meaning oki_bin_disp_lkup.bin_code_meaning%TYPE
   , bin_code_seq     oki_bin_disp_lkup.bin_code_seq%TYPE
  ) ;

  CURSOR g_bin_disp_lkup_csr
  (  p_bin_id   IN VARCHAR2
   , p_bin_code IN VARCHAR2
  ) RETURN g_bin_disp_lkup_csr_row ;

--------------------------------------------------------------------------------
  -- Function that gl period dates

--------------------------------------------------------------------------------
  PROCEDURE get_gl_period_date
  (
     x_retcode OUT NOCOPY VARCHAR2
  );


END oki_utl_pvt ;

 

/
