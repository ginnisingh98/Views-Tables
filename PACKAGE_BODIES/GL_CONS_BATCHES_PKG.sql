--------------------------------------------------------
--  DDL for Package Body GL_CONS_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONS_BATCHES_PKG" AS
/* $Header: glicobtb.pls 120.12 2006/01/04 22:51:16 djogg ship $ */

--
-- PUBLIC FUNCTIONS
--

  FUNCTION Insert_Consolidation_Batches(
	X_Batch_Query_Options_Flag VARCHAR2,
        X_Consolidation_Id        NUMBER,
        X_Consolidation_Run_Id    NUMBER,
        X_Last_Updated_By         NUMBER,
        X_From_Ledger_Id          NUMBER,
        X_To_Ledger_Id            NUMBER,
	X_Default_Period_Name     VARCHAR2,
	X_Currency_Code           VARCHAR2) RETURN BOOLEAN IS

   CURSOR batches is
   SELECT consolidation_run_id
     FROM GL_CONS_BATCHES glcb
    WHERE  glcb.consolidation_run_id = X_Consolidation_run_Id;

  dummy NUMBER;

  BEGIN
    IF (X_Batch_Query_Options_Flag = 'U' OR X_Batch_Query_Options_Flag is NULL)
    THEN
      INSERT INTO GL_CONS_BATCHES
        (consolidation_id, consolidation_run_id, je_batch_id,
         last_update_date, last_updated_by)
      SELECT DISTINCT X_Consolidation_Id, X_Consolidation_Run_Id,
         h.je_batch_id, sysdate, X_Last_Updated_By
      FROM   GL_JE_HEADERS h
      WHERE h.status = 'P'
      AND   h.ACTUAL_FLAG = 'A'
      AND   h.period_name = X_Default_Period_Name
      AND   h.ledger_id = X_From_Ledger_Id
      AND  NOT EXISTS
          (select 'X'
           from   gl_cons_batches cb, gl_consolidation c,
                  gl_consolidation_history ch
           where  c.consolidation_id = cb.consolidation_id
           and    c.to_ledger_id = X_To_Ledger_Id
           and    cb.je_batch_id = h.je_batch_id
           and    ch.consolidation_run_id = cb.consolidation_run_id
           and    ch.to_currency_code = X_Currency_Code);

    ELSIF (X_Batch_Query_Options_Flag = 'C') THEN
      INSERT INTO GL_CONS_BATCHES
        (consolidation_id, consolidation_run_id, je_batch_id,
         last_update_date, last_updated_by)
      SELECT DISTINCT
         X_Consolidation_Id, X_Consolidation_Run_Id, h.je_batch_id,
         sysdate, X_Last_Updated_By
      FROM   GL_JE_HEADERS h
      WHERE  status = 'P'
      AND    ACTUAL_FLAG = 'A'
      AND    period_name = X_Default_Period_Name
      AND    h.ledger_id = X_From_Ledger_Id
      AND  EXISTS
          (select 'X'
           from   gl_cons_batches cb, gl_consolidation c,
                  gl_consolidation_history ch
           where  c.consolidation_id = cb.consolidation_id
           and    c.to_ledger_id = X_To_Ledger_Id
           and    cb.je_batch_id = h.je_batch_id
           and    ch.consolidation_run_id = cb.consolidation_run_id
           and    ch.to_currency_code = X_Currency_Code);
     ELSE
       INSERT INTO GL_CONS_BATCHES
        (consolidation_id, consolidation_run_id, je_batch_id,
         last_update_date, last_updated_by)
      SELECT DISTINCT
         X_Consolidation_Id, X_Consolidation_Run_Id, h.je_batch_id,
         sysdate, X_Last_Updated_By
      FROM   GL_JE_HEADERS h
      WHERE  status = 'P'
      AND    ACTUAL_FLAG = 'A'
      AND    period_name = X_Default_Period_Name
      AND    h.ledger_id = X_From_Ledger_Id;
    END IF;

  -- Check to see if any batches inserted so we can return a boolean value.
    OPEN batches;
    FETCH batches INTO dummy;

    IF (batches%FOUND) THEN
      CLOSE  batches;
      RETURN TRUE;
    ELSE
      CLOSE batches;
      RETURN FALSE;
    END IF;

  END Insert_Consolidation_Batches;



-- Insert_Cons_Batch only inserts one batch at a time into
-- the Gl_Cons_Batches table. It is called from Pre-Update
-- of Batches block.

  PROCEDURE Insert_Cons_Batch(
        X_Consolidation_Id        NUMBER,
        X_Consolidation_Run_Id    NUMBER,
	X_Je_Batch_Id		  NUMBER,
        X_User_Id                 NUMBER) IS

  BEGIN

    INSERT INTO gl_cons_batches
      (consolidation_id, consolidation_run_id, je_batch_id,
       last_update_date, last_updated_by) values
      (X_Consolidation_Id, X_Consolidation_Run_Id, X_Je_Batch_Id,
       sysdate, X_User_Id);

  END Insert_Cons_Batch;



-- Delete_Cons_Batch only deletes one batch at a time from
-- the Gl_Cons_Batches table. It is called from Pre-Update
-- of Batches block.

  PROCEDURE Delete_Cons_Batch( X_Je_Batch_Id  NUMBER) IS

  BEGIN

    DELETE FROM gl_cons_batches
      where je_batch_id = X_Je_Batch_Id;


  END Delete_Cons_Batch;


-- Remove gl_cons_batches rows for a particular consolidation run

  PROCEDURE Remove_Cons_Run_Batches(
    x_errbuf        OUT NOCOPY VARCHAR2,
    x_retcode       OUT NOCOPY VARCHAR2,
    p_consolidation_run_id     NUMBER) IS
  BEGIN
    DELETE FROM gl_cons_batches cb
    WHERE cb.consolidation_run_id = p_consolidation_run_id;
  END Remove_Cons_Run_Batches;

END GL_CONS_BATCHES_PKG;

/
