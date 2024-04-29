--------------------------------------------------------
--  DDL for Package IGC_CBC_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CBC_INQUIRY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCINQRS.pls 120.2.12000000.1 2007/08/20 12:15:26 mbremkum ship $ */

PROCEDURE Initialize
(
  p_amount_type          IN    VARCHAR2,
  p_period_cutoff        IN    gl_periods.period_name%TYPE,
  p_set_of_books_id      IN    gl_period_statuses.set_of_books_id%TYPE,
  p_gl_budget_version_id IN   gl_budget_versions.budget_version_id%TYPE
);

FUNCTION Check_Amount_Type
  (p_period_name          IN gl_periods.period_name%TYPE,
   p_period_year          IN gl_periods.period_year%TYPE,
   p_quarter_num          IN gl_periods.quarter_num%TYPE,
   p_period_num           IN gl_periods.period_num%TYPE,
   p_actual_flag          IN igc_cbc_je_lines.actual_flag%TYPE,
   p_gl_budget_version_id IN  gl_budget_versions.budget_version_id%TYPE
   )  RETURN VARCHAR2 ;

PRAGMA RESTRICT_REFERENCES(Check_Amount_Type,RNDS,WNDS,WNPS);

FUNCTION  Get_Amount_Type RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(Get_Amount_Type,RNDS,WNDS,WNPS);


FUNCTION  Get_Period_Name RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(Get_Period_Name,RNDS,WNDS,WNPS);

FUNCTION Get_FC_Balances(
  p_mode       IN  VARCHAR2,
  p_dccid      IN  igc_cbc_je_lines.code_combination_id%TYPE,   -- Detail CCID
  p_sob_id     IN  igc_cbc_je_lines.set_of_books_id%TYPE,   -- Set of Books ID
  p_budget_ver IN  igc_cbc_je_lines.budget_version_id%TYPE, -- Budget ID
  p_period_yr  IN  igc_cbc_je_lines.period_year%TYPE,  -- Period year, ie 2000
  p_period_nm  IN  igc_cbc_je_lines.period_num%TYPE,  -- Period number
  p_quarter_nm IN  igc_cbc_je_lines.quarter_num%TYPE, -- Quarter number (1-4)
  p_batch_id   IN  igc_cbc_je_lines.cbc_je_batch_id%TYPE,
  p_actual_flg IN  igc_cbc_je_lines.actual_flag%TYPE, --- 'B' or 'E'
  p_enc_type_id IN igc_cbc_je_lines.encumbrance_type_id%TYPE, -- 1000 or 1082
  p_line_num   IN  igc_cbc_je_lines.cbc_je_line_num%TYPE
		     )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(Get_FC_Balances,WNDS,WNPS,RNPS);


END IGC_CBC_INQUIRY_PKG;

 

/
