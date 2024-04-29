--------------------------------------------------------
--  DDL for Package GL_CONS_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONS_BATCHES_PKG" AUTHID CURRENT_USER as
/* $Header: glicobts.pls 120.5 2005/12/07 08:29:56 mikeward ship $ */
--
-- Package
--   gl_cons_batches_pkg
-- Purpose
--   Package procedures for Consolidation RUN form,
--     BATCHES block
-- History
--   20-APR-94	E Wilson	Created
--   25-JAN-95	C Schalk	Modifed to accept Batch_Query_Options
--   10-MAR-95	C Schalk	Added GL_CONS_DELETE_BATCH. Renamed
--				Insert_Cons_Batches to Insert_Cons
--				_Batch.
--   05-22-95   C Schalk        Added 'And Actual_Flag = 'A'' for 276779

--

  --
  -- Procedure
  --   Insert_Consolidation_Batches
  -- Purpose
  --   Insert records into GL_CONS_BATCHES for new consolidation
  -- Arguments
  --   batch_query_options
  --   consolidation_id
  --   consolidation_run_id
  --   last_updated_by
  -- Example
  --   GL_CONS_BATCHES_PKG.Insert_Consolidation_Batches(
  --                   :SELECT_BATCHES.batch_query_options,
  --                   :SUBMIT.consolidation_id,
  --                   :SUBMIT.consolidation_run_id,
  --                   :SUBMIT.last_updated_by,
  --                   :SUBMIT.to_ledger_id,
  --                   :SUBMIT.from_ledger_id,
  --                   :SUBMIT.from_period_name);
  -- Notes
  --
  FUNCTION Insert_Consolidation_Batches(
		X_Batch_Query_Options_Flag	VARCHAR2,
		X_Consolidation_Id		NUMBER,
		X_Consolidation_Run_Id		NUMBER,
		X_Last_Updated_By		NUMBER,
		X_From_Ledger_Id		NUMBER,
		X_To_Ledger_Id			NUMBER,
		X_Default_Period_Name		VARCHAR2,
		X_Currency_Code			VARCHAR2) RETURN BOOLEAN;

  --
  -- Procedure
  --   Insert_Cons_Batch
  -- Purpose
  --   Insert batch selected for consolidation into GL_CONS_BATCHES
  -- Arguments
  --   consolidation_id
  --   consolidation_run_id
  --   je_batch_id
  --   user_id
  -- Example
  --   GL_CONS_BATCHES_PKG.Insert_Cons_Batch(
  --              :SUBMIT.consolidation_id,
  --              :SUBMIT.consolidation_run_id,
  --              :BATCHES.je_batch_id,
  --               fnd_profile.value('USER_ID'))
  -- Notes
  --
  PROCEDURE Insert_Cons_Batch(
		X_Consolidation_Id		NUMBER,
		X_Consolidation_Run_Id		NUMBER,
		X_Je_Batch_Id			NUMBER,
		X_User_Id			NUMBER);

  --
  -- Procedure
  --   Delete_Cons_Batch
  -- Purpose
  --   Delete a single batch selected rom GL_CONS_BATCHES.
  --   It is called when for a marked record that is not consolidated
  --   but inserted into GL_CONS_BATCHES because the selected_all_before
  --   flag is set.
  --
  -- Arguments
  --   je_batch_id
  -- Example
  --   GL_CONS_BATCHES_PKG.Delete_Cons_Batch(
  --              :BATCHES.je_batch_id,
  --               )
  -- Notes
  --
  PROCEDURE Delete_Cons_Batch( X_Je_Batch_Id  NUMBER);

  --
  -- Procedure
  --   Remove_Cons_Run_Batches
  -- Purpose
  --   Remove all rows in gl_cons_batches for the specified
  --   consolidation_run_id. This is a concurrent program.
  -- Arguments
  --   p_consolidation_run_id
  -- Example
  --   GL_CONS_BATCHES_PKG.Remove_Cons_Run_Batches(
  --              x_errbuf,
  --              x_retcode,
  --              cons_run_id
  --   )
  -- Notes
  --
  PROCEDURE Remove_Cons_Run_Batches(
    x_errbuf        OUT NOCOPY VARCHAR2,
    x_retcode       OUT NOCOPY VARCHAR2,
    p_consolidation_run_id     NUMBER);

END GL_CONS_BATCHES_PKG;

 

/
