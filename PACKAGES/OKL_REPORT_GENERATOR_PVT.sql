--------------------------------------------------------
--  DDL for Package OKL_REPORT_GENERATOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REPORT_GENERATOR_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLRRPTS.pls 120.4.12010000.3 2008/11/14 08:30:10 nikshah ship $*/

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  g_app_name           CONSTANT VARCHAR2(3)   := okl_api.g_app_name;
  g_unexpected_error   CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  g_sqlerrm_token      CONSTANT VARCHAR2(200) := 'SQLERRM';
  g_sqlcode_token      CONSTANT VARCHAR2(200) := 'SQLCODE';
  g_pkg_name           CONSTANT VARCHAR2(200) := 'OKL_REPORTS_PVT';
  g_col_name_token     CONSTANT VARCHAR2(200) := okl_api.g_col_name_token;
  g_parent_table_token CONSTANT VARCHAR2(200) := okl_api.g_parent_table_token;
  g_child_table_token  CONSTANT VARCHAR2(200) := okl_api.g_child_table_token;
  g_no_parent_record   CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  g_invalid_value      CONSTANT VARCHAR2(200) := okl_api.g_invalid_value;
  g_required_value     CONSTANT VARCHAR2(200) := okl_api.g_required_value;
  g_representation_type         VARCHAR2(20)  := 'PRIMARY';
  g_exception_halt_validation EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE reports_gt_tbl_type IS TABLE OF okl_g_reports_gt%ROWTYPE
    INDEX BY BINARY_INTEGER;

  p_report_id        NUMBER;
  p_ledger_id        NUMBER;
  p_book_class_code  VARCHAR2(30);
  p_report_type      VARCHAR2(15);
  p_report_type_code VARCHAR2(15);
  p_gl_period_from   VARCHAR2(15);
  p_gl_period_to     VARCHAR2(15);
  p_drill1_yn        VARCHAR2(1);
  p_drill2_yn        VARCHAR2(1);
  p_summary_yn       VARCHAR2(1);

  FUNCTION generate_gross_inv_recon_rpt RETURN BOOLEAN;

END OKL_REPORT_GENERATOR_PVT;

/
