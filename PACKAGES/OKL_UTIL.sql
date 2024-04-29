--------------------------------------------------------
--  DDL for Package OKL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_UTIL" AUTHID CURRENT_USER AS
 /* $Header: OKLRUTLS.pls 120.2.12010000.2 2008/11/13 13:36:19 kkorrapo ship $ */

  -------------------------
  -- trace global variables
  -------------------------
l_trace_path		        VARCHAR2(255);
l_trace_file		     	UTL_FILE.FILE_TYPE;
l_trace_file_name		VARCHAR2(255);
l_output_file			UTL_FILE.FILE_TYPE;
l_output_file_name		VARCHAR2(255);
l_trace_flag			BOOLEAN:=FALSE;
l_log_flag			BOOLEAN:=FALSE;
l_output_flag			BOOLEAN:=FALSE;
l_request_id			NUMBER;
l_program	                VARCHAR2(80);
l_module	                VARCHAR2(80);
l_complete_trace_file_name	VARCHAR2(255);
l_complete_trace_file_name2	VARCHAR2(255);
  -------------------------
  -- standard trace constants
  -------------------------
g_trc_trace_file_prefix         CONSTANT VARCHAR2(30)  := 'okl_';
g_trc_trace_file_suffix         CONSTANT VARCHAR2(30)  := '.trc';
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE unq_rec_type IS RECORD (
    p_col_name  VARCHAR2(40),
    p_col_val   VARCHAR2(2000));
  TYPE unq_tbl_type IS TABLE OF unq_rec_type
    INDEX BY BINARY_INTEGER;
  TYPE lenchk_rec_type  IS RECORD (
    VName		VARCHAR2(30),
    CName		VARCHAR2(30),
    CDType		VARCHAR2(20),
    CLength		NUMBER,
    CScale		NUMBER);
  TYPE lenchk_tbl_type  IS TABLE OF  lenchk_rec_type
   INDEX BY BINARY_INTEGER;
-- Stores the languages that are currently defined in FND_LANGUAGES.
-- This table is populated by the anonymous block in the package body.
--  g_language_code                 OKL_Datatypes.Var12TabTyp;
--  g_lenchk_tbl    		  lenchk_tbl_type;
  ---------------------------------------------------------------------------
  G_APP_NAME			CONSTANT   VARCHAR2(3)           :=  OKL_Api.G_APP_NAME;
  G_SQLERRM_TOKEN		CONSTANT   VARCHAR2(200)         := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN		CONSTANT   VARCHAR2(200)         := 'ERROR_CODE';
  G_EXPECTED_ERROR		CONSTANT   VARCHAR2(200)         := 'OKL_VALUE_ERROR';
  G_COL_NAME_TOKEN		CONSTANT   VARCHAR2(200)         :=  OKL_Api.G_COL_NAME_TOKEN;
  G_VIEW_TOKEN			CONSTANT   VARCHAR2(200)         := 'G_VIEW_TOKEN';
  ---------------------------------------------------------------------------
  --GLOBAL CONSTANT
  ---------------------------------------------------------------------------



   ----------------------------------------------------------------------------
     --Get country FOR before active line
    ----------------------------------------------------------------------------
     FUNCTION get_preactive_line_inst(p_financial_line IN NUMBER)
     RETURN VARCHAR2;
      pragma restrict_references(get_preactive_line_inst, WNDS,WNPS,RNPS);

    ----------------------------------------------------------------------------
     --   --Get country FOR after active line
    ----------------------------------------------------------------------------
     FUNCTION get_active_line_inst_country(p_financial_line IN NUMBER)
     RETURN VARCHAR2;
      pragma restrict_references(get_active_line_inst_country, WNDS,WNPS,RNPS);

  ----------------------------------------------------------------------------
   --Check if valid code for a type in fnd lookup
  ----------------------------------------------------------------------------
   FUNCTION check_lookup_code(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2)
   RETURN VARCHAR2;
  ----------------------------------------------------------------------------
   --Check if valid value for a  domain(Y/N)
  ----------------------------------------------------------------------------
  FUNCTION check_domain_yn(p_col_value IN VARCHAR2)
   RETURN VARCHAR2;
  ----------------------------------------------------------------------------
   --Check if valid value for a  domain(amount)
  ----------------------------------------------------------------------------
  FUNCTION check_domain_amount(p_col_value IN NUMBER)
   RETURN VARCHAR2;
  ----------------------------------------------------------------------------
   --Check if valid value for date range
  ----------------------------------------------------------------------------
 FUNCTION check_from_to_date_range(p_from_date IN DATE,p_to_date IN DATE  )
   RETURN VARCHAR2;
  ----------------------------------------------------------------------------
   --Check if valid value for Number range
  ----------------------------------------------------------------------------
 FUNCTION check_from_to_number_range(p_from_number IN NUMBER ,p_to_number IN  NUMBER  )
     RETURN VARCHAR2;
 -------------------------------------------------------------------
 FUNCTION check_org_id(p_org_id IN VARCHAR2,
          p_null_allowed  IN VARCHAR2 DEFAULT 'Y')
   RETURN VARCHAR2;
 -------------------------------------------------------------------
FUNCTION get_rec_status (p_start_date IN DATE, p_end_date IN DATE)
RETURN VARCHAR2;
pragma restrict_references(get_rec_status, WNDS,WNPS,RNPS);
------------------------------------------------------------------------

--Bug 7022258-Added by kkorrapo
FUNCTION get_next_seq_num(
    p_seq_name           IN VARCHAR2,
    p_table_name         IN VARCHAR2,
    p_col_name           IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION validate_seq_num(
    p_seq_name           IN VARCHAR2,
    p_table_name         IN VARCHAR2,
    p_col_name           IN VARCHAR2,
    p_value              IN VARCHAR2)
RETURN varchar2;
--Bug 7022258--Addition end
END OKL_UTIL;

/
