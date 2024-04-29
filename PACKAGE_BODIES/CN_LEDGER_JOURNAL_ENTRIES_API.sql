--------------------------------------------------------
--  DDL for Package Body CN_LEDGER_JOURNAL_ENTRIES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_LEDGER_JOURNAL_ENTRIES_API" as
/* $Header: cnsbjeb.pls 115.4 2001/10/29 17:12:38 pkm ship    $ */

/*
Date      Name          Description
---------------------------------------------------------------------------+
29-DEC-94 A. Lower      Created package
06-23-95  A. Erickson   cn_periods.period_name  column name update
MAR-02-99 H. Chen       code changes for MLS

  Name    : CN_LEDGER_JOURNAL_ENTRIES_API
  Purpose : Holds functions for accessing and procedures for setting
            properties of journal entries.

  Notes   :

*/

  --+
  -- Procedure name
  --   New_JE
  -- Purpose
  --   An API function which returns the journal entry ID of a newly created
  --     entry.
  --+

  FUNCTION New_JE (X_batch_id                    NUMBER,
                   X_salesrep_id                 NUMBER,
                   X_period_id                   NUMBER,
                   X_account                     NUMBER,
                   X_credit                      NUMBER,
                   X_debit                       NUMBER,
                   X_date                        DATE) return NUMBER IS
      JE_Return NUMBER;

    BEGIN

      INSERT INTO cn_ledger_journal_entries
        (batch_id, srp_period_id, balance_id, credit, debit, je_date,
                ledger_je_id, reason)
        (SELECT X_batch_id, srp_per.srp_period_id, X_account,
                X_credit, X_debit, X_date,
                cn_ledger_journal_entries_s.nextval,
                batch.reason
           FROM cn_srp_periods srp_per,
                cn_ledger_je_batches batch
          WHERE salesrep_id = X_salesrep_id
            AND period_id = X_period_id
            AND batch.batch_id = X_batch_id);

      SELECT cn_ledger_journal_entries_s.currval INTO JE_Return FROM dual;

      RETURN JE_Return;

    END New_JE;


  --+
  -- Procedure name
  --   New_JE
  -- Purpose
  --   An API function which returns the journal entry ID of a newly created
  --     entry.
  --+

  FUNCTION New_JE (X_batch_id                    NUMBER,
                   X_salesrep_id                 NUMBER,
                   X_period_id                   NUMBER,
		   x_role_id                     NUMBER,
		   x_credit_type_id              NUMBER,
                   X_account                     NUMBER,
                   X_credit                      NUMBER,
                   X_debit                       NUMBER,
                   X_date                        DATE) return NUMBER IS
      JE_Return NUMBER;

    BEGIN

       --dbms_output.put_line('Salesrep: ' || x_salesrep_id);
       --dbms_output.put_line('Period: ' || x_period_id);
       --dbms_output.put_line('Credit: ' || x_credit_type_id);
       --dbms_output.put_line('Role: ' || x_role_id);
       --dbms_output.put_line('Batch: ' || x_batch_id);

      INSERT INTO cn_ledger_journal_entries
        (batch_id,
	 srp_period_id,
	 balance_id,
	 credit,
	 debit,
	 je_date,
	 ledger_je_id,
	 reason)
        (SELECT X_batch_id,
	 srp_per.srp_period_id,
	 X_account,
	 X_credit,
	 X_debit,
	 X_date,
	 cn_ledger_journal_entries_s.nextval,
	 batch.reason
	 FROM cn_srp_periods srp_per,
	 cn_ledger_je_batches batch
	 WHERE  salesrep_id = X_salesrep_id
	 AND period_id = x_period_id
	 AND credit_type_id = x_credit_type_id
	 AND role_id = x_role_id
	 AND batch.batch_id = X_batch_id);

      --dbms_output.put_line('Insert ...' || SQL%rowcount);

      SELECT  cn_ledger_journal_entries_s.CURRVAL INTO JE_Return FROM dual;

      RETURN JE_Return;

    END New_JE;


  --+
  -- Procedure name
  --   New_JE
  -- Purpose
  --   An API function which returns the journal entry ID of a newly created
  --     entry.
  --+

  FUNCTION New_JE (X_batch_id                    NUMBER,
                   X_salesrep_id                 NUMBER,
                   X_period_id                   NUMBER,
                   X_account                     NUMBER,
                   X_credit                      NUMBER,
                   X_debit                       NUMBER,
                   X_date                        DATE,
                   X_reason                      VARCHAR2) return NUMBER IS
      JE_Return NUMBER;

    BEGIN

      INSERT INTO cn_ledger_journal_entries
        (batch_id, srp_period_id, balance_id, credit, debit, je_date,
                ledger_je_id, reason)
        (SELECT X_batch_id, srp_per.srp_period_id, X_account,
                X_credit, X_debit, X_date,
                cn_ledger_journal_entries_s.nextval, X_reason
           FROM cn_srp_periods srp_per
          WHERE salesrep_id = X_salesrep_id
            AND period_id = X_period_id);

      SELECT cn_ledger_journal_entries_s.currval INTO JE_Return FROM dual;

      RETURN JE_Return;

    END New_JE;


  PROCEDURE Names_From_IDs (X_batch_id           NUMBER,
                            X_who_name  IN OUT VARCHAR2,
                            X_reason      IN OUT VARCHAR2,
                            X_posted      IN OUT VARCHAR2,
                            X_srp_period_id      NUMBER,
                            X_balance_id         NUMBER,
                            X_salesrep_name IN OUT VARCHAR2,
                            X_account_name  IN OUT VARCHAR2,
                            X_period_name   IN OUT VARCHAR2,
                            X_salesrep_id   IN OUT NUMBER,
                            X_period_id     IN OUT NUMBER) IS

      Dummy NUMBER(15);
    BEGIN

    BEGIN

      SELECT who, reason, decode(status, 'POSTED', 'Y', 'N')
         INTO X_who_name, X_reason, X_posted
         FROM cn_ledger_je_batches
        WHERE batch_id = X_batch_id;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

          Dummy := 1;

    END;

    BEGIN

        SELECT rep.name, rep.salesrep_id
          INTO X_salesrep_name, X_salesrep_id
          FROM cn_salesreps rep,
               cn_srp_periods per
         WHERE per.srp_period_id = X_srp_period_id
           AND rep.salesrep_id = per.salesrep_id;

      SELECT per.period_name, per.period_ID
        INTO X_period_name, X_period_id
        FROM cn_periods per,
             cn_srp_periods srp
       WHERE srp.period_id = per.period_id
         AND srp.srp_period_id = X_srp_period_id;

-- MLS Change
-- replace  cn_subledger_balance_types with cn_ledger_bal_types
--          SELECT balance_name INTO X_account_name
--                          FROM cn_subledger_balance_types
--                         WHERE balance_id = X_balance_id;
          SELECT balance_name INTO X_account_name
                          FROM cn_ledger_bal_types
                         WHERE balance_id = X_balance_id;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

          Dummy := 1;

    END;

    END Names_From_IDs;


END CN_LEDGER_JOURNAL_ENTRIES_API;

/
