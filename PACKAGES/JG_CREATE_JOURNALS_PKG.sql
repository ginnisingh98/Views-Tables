--------------------------------------------------------
--  DDL for Package JG_CREATE_JOURNALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_CREATE_JOURNALS_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzztals.pls 115.2 2002/11/20 09:21:37 arimai ship $ */

  PROCEDURE create_journal;

  PROCEDURE write_error_to_output;

  PROCEDURE Create_Offset_For_Acct_Range;

  TYPE KEY_SEGMENTS_TABLE IS TABLE OF gl_code_combinations.segment1%TYPE
        INDEX BY BINARY_INTEGER;
  G_key_segment             KEY_SEGMENTS_TABLE;
  G_offset_grp_key_segment  KEY_SEGMENTS_TABLE;

  --
  -- Allocated table records
  --
  TYPE ALLOCATED_LINE IS RECORD (je_batch_name    	  GL_JE_BATCHES.name%TYPE,
	 			je_header_name 		  GL_JE_HEADERS.name%TYPE,
	 			code_combination_id	  GL_JE_LINES.code_combination_id%TYPE,
	 			je_line_num		  GL_JE_LINES.je_line_num%TYPE,
				cc_range_id		  JG_ZZ_TA_CC_RANGES.cc_range_id%TYPE,
				remarks			  VARCHAR2(240),
	 			accounted_cr		  GL_JE_LINES.accounted_cr%TYPE,
	 			accounted_dr		  GL_JE_LINES.accounted_dr%TYPE,
	 			destn_account_number	  GL_CODE_COMBINATIONS.segment1%TYPE,
	 			destn_accted_cr		  GL_JE_LINES.accounted_cr%TYPE,
	 			destn_accted_dr		  GL_JE_LINES.accounted_dr%TYPE,
				destn_entered_cr	  GL_JE_LINES.entered_cr%TYPE,
				destn_entered_dr	  GL_JE_LINES.entered_dr%TYPE);

  TYPE ALLOCATED_LINES_TABLE IS TABLE OF ALLOCATED_LINE INDEX BY BINARY_INTEGER;
  alloc_lines_arr		ALLOCATED_LINES_TABLE;
  i				BINARY_INTEGER := 0; -- total num of alloc lines

  G_total_alloc_accted_cr_amt  	GL_JE_LINES.accounted_cr%TYPE := 0;
  G_total_alloc_accted_dr_amt  	GL_JE_LINES.accounted_dr%TYPE := 0;

  G_total_offset_accted_cr_amt  GL_JE_LINES.accounted_cr%TYPE := 0;
  G_total_offset_accted_dr_amt  GL_JE_LINES.accounted_dr%TYPE := 0;
  G_total_offset_entered_cr_amt GL_JE_LINES.entered_cr%TYPE := 0;
  G_total_offset_entered_dr_amt GL_JE_LINES.entered_dr%TYPE := 0;

  G_Journal_Name		GL_INTERFACE.reference4%TYPE := NULL;
  G_Journal_Description		GL_INTERFACE.reference5%TYPE := NULL;
  G_Batch_Name			GL_INTERFACE.reference1%TYPE := NULL;

END JG_CREATE_JOURNALS_PKG;

 

/
