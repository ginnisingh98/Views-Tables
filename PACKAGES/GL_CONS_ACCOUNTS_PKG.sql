--------------------------------------------------------
--  DDL for Package GL_CONS_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONS_ACCOUNTS_PKG" AUTHID CURRENT_USER as
/* $Header: glicoacs.pls 120.3 2005/05/05 01:04:00 kvora ship $ */
--
-- Package
--   gl_consolidation_accounts_pkg
-- Purpose
--   Package procedures for Consolidation RUN form,
--     Accounts block
-- History
--   20-APR-94	E Wilson	Created
--

  --
  -- Procedure
  --   Insert_Consolidation_Accounts
  -- Purpose
  --   Insert records into GL_CONSOLIDATION_ACCOUNTS for new consolidation
  -- Arguments
  --   consolidation_run_id
  --   consolidation_id
  --   from_ledger_id     Subsidiary ledger id
  -- Example
  --   GL_CONSOLIDATION_ACCOUNTS_PKG.Insert_Consolidation_Accounts(
  --                              :SUBMIT.consolidation_run_id,
  --                              :SUBMIT.consolidation_id,
  --                              :SUBMIT.from_ledger_id)
  -- Notes
  --
  FUNCTION Insert_Consolidation_Accounts(
		X_Consolidation_Run_Id		NUMBER,
		X_Consolidation_Id		NUMBER,
		X_From_Ledger_Id		NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   Check_Unique_Element_Sequence
  -- Purpose
  --   Verify element_sequence is unique for consolidation_id
  --   consolidation_run_id combination
  -- Arguments
  --   rowid                   gl_consolidation_accounts rowid
  --   consolidation_id
  --   consolidation_run_id
  --   element_sequence        account ranges line number
  -- Example
  --   GL_CONSOLIDATION_ACCOUNTS_PKG.Check_Unique_Element_Sequence(
  --                              :ACCOUNTS.rowid
  --                              :SUBMIT.consolidation_id,
  --                              :SUBMIT.consolidation_run_id,
  --                              :ACCOUNTS.element_sequence)
  -- Notes
  --
  PROCEDURE Check_Unique_Element_Sequence(
		X_Rowid				VARCHAR2,
		X_Consolidation_Id		NUMBER,
		X_Consolidation_Run_Id		NUMBER,
		X_Element_Sequence		NUMBER);

  --
  -- Procedure
  --   Check_Account_Ranges_Overlap
  -- Purpose
  --   Verify that Account Ranges do not overlap
  -- Arguments
  --   rowid                   gl_consolidation_accounts rowid
  --   consolidation_id
  --   consolidation_run_id
  --   segment1_low..segment30_low  account low
  --   segment1_high..segment30_high  account high
  --
  PROCEDURE Check_Account_Ranges_Overlap(
		X_Rowid				VARCHAR2,
		X_Consolidation_Id		NUMBER,
		X_Consolidation_Run_Id		NUMBER,
		X_Segment1_Low		        VARCHAR2,
		X_Segment1_High		        VARCHAR2,
		X_Segment2_Low		        VARCHAR2,
		X_Segment2_High		        VARCHAR2,
		X_Segment3_Low		        VARCHAR2,
		X_Segment3_High		        VARCHAR2,
		X_Segment4_Low		        VARCHAR2,
		X_Segment4_High		        VARCHAR2,
		X_Segment5_Low		        VARCHAR2,
		X_Segment5_High		        VARCHAR2,
		X_Segment6_Low		        VARCHAR2,
		X_Segment6_High		        VARCHAR2,
		X_Segment7_Low		        VARCHAR2,
		X_Segment7_High		        VARCHAR2,
		X_Segment8_Low		        VARCHAR2,
		X_Segment8_High		        VARCHAR2,
		X_Segment9_Low		        VARCHAR2,
		X_Segment9_High		        VARCHAR2,
		X_Segment10_Low 	        VARCHAR2,
		X_Segment10_High	        VARCHAR2,
		X_Segment11_Low		        VARCHAR2,
		X_Segment11_High	        VARCHAR2,
		X_Segment12_Low		        VARCHAR2,
		X_Segment12_High	        VARCHAR2,
		X_Segment13_Low		        VARCHAR2,
		X_Segment13_High	        VARCHAR2,
		X_Segment14_Low		        VARCHAR2,
		X_Segment14_High	        VARCHAR2,
		X_Segment15_Low		        VARCHAR2,
		X_Segment15_High	        VARCHAR2,
		X_Segment16_Low		        VARCHAR2,
		X_Segment16_High	        VARCHAR2,
		X_Segment17_Low		        VARCHAR2,
		X_Segment17_High	        VARCHAR2,
		X_Segment18_Low		        VARCHAR2,
		X_Segment18_High	        VARCHAR2,
		X_Segment19_Low		        VARCHAR2,
		X_Segment19_High	        VARCHAR2,
		X_Segment20_Low 	        VARCHAR2,
		X_Segment20_High	        VARCHAR2,
		X_Segment21_Low		        VARCHAR2,
		X_Segment21_High	        VARCHAR2,
		X_Segment22_Low		        VARCHAR2,
		X_Segment22_High	        VARCHAR2,
		X_Segment23_Low		        VARCHAR2,
		X_Segment23_High	        VARCHAR2,
		X_Segment24_Low		        VARCHAR2,
		X_Segment24_High	        VARCHAR2,
		X_Segment25_Low		        VARCHAR2,
		X_Segment25_High	        VARCHAR2,
		X_Segment26_Low		        VARCHAR2,
		X_Segment26_High	        VARCHAR2,
		X_Segment27_Low		        VARCHAR2,
		X_Segment27_High	        VARCHAR2,
		X_Segment28_Low		        VARCHAR2,
		X_Segment28_High	        VARCHAR2,
		X_Segment29_Low		        VARCHAR2,
		X_Segment29_High	        VARCHAR2,
		X_Segment30_Low 	        VARCHAR2,
		X_Segment30_High	        VARCHAR2
		);

  --
  -- Procedure
  --   Count_Ranges
  -- Purpose
  --   Count the number of existing ranges for a consolidation run
  -- Arguments
  --   consolidation_id
  --   consolidation_run_id
  -- Example
  --   GL_CONSOLIDATION_ACCOUNTS_PKG.Ccount_Ranges(
  --                              :SUBMIT.consolidation_id,
  --                              :SUBMIT.consolidation_run_id)
  -- Notes
  --
  FUNCTION Count_Ranges(
		X_Consolidation_Id		NUMBER,
		X_Consolidation_Run_Id		NUMBER) RETURN BOOLEAN;

/* Name: copy_ranges
 * Desc: Copies the ranges for the source run id to the target run id.
 */
PROCEDURE copy_ranges(
            ConsolidationId NUMBER,
            SourceRunId     NUMBER,
            TargetRunId     NUMBER);


  --
  -- Procedure
  --   Delete_Account_Range
  -- Purpose
  --   Delete the existing ranges for a consolidation run
  -- Arguments
  --   consolidation_id
  --   std_consolidation_run_id
  --   avg_consolidation_run_id
  -- Example
  --   GL_CONS_ACCOUNTS_PKG.Delete_Account_Range(
  --                              :SUBMIT.consolidation_id,
  --                              :SUBMIT.std_consolidation_run_id,
  --                              :SUBMIT.avg_consolidation_run_id)
  -- Notes
  --
  PROCEDURE Delete_Account_Range(
                 ConsolidationId  NUMBER,
                 StdRunId         NUMBER,
                 AvgRunId         NUMBER);


END GL_CONS_ACCOUNTS_PKG;

 

/
