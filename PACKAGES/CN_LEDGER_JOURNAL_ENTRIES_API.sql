--------------------------------------------------------
--  DDL for Package CN_LEDGER_JOURNAL_ENTRIES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_LEDGER_JOURNAL_ENTRIES_API" AUTHID CURRENT_USER as
/* $Header: cnsbjes.pls 115.3 2001/10/29 17:12:39 pkm ship    $ */

/*
Date	  Name	     	Description
---------------------------------------------------------------------------+
29-DEC-94 A. Lower	Created package


  Name	  : CN_LEDGER_JOURNAL_ENTRIES_API
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

  FUNCTION New_JE (X_batch_id			 NUMBER,
		   X_salesrep_id		 NUMBER,
		   X_period_id 			 NUMBER,
		   X_account   			 NUMBER,
		   X_credit			 NUMBER,
		   X_debit			 NUMBER,
		   X_date			 DATE) return NUMBER;

  --+
  -- Procedure name
  --   New_JE
  -- Purpose
  --   An API function which returns the journal entry ID of a newly created
  --     entry.
  --+

  FUNCTION New_JE (X_batch_id			 NUMBER,
		   X_salesrep_id		 NUMBER,
		   X_period_id 			 NUMBER,
		   X_account   			 NUMBER,
		   X_credit			 NUMBER,
		   X_debit			 NUMBER,
		   X_date			 DATE,
		   X_reason			 VARCHAR2) return NUMBER;

  FUNCTION New_JE (X_batch_id			 NUMBER,
		   X_salesrep_id		 NUMBER,
		   X_period_id 			 NUMBER,
		   x_role_id                     NUMBER,
		   x_credit_type_id              NUMBER,
		   X_account   			 NUMBER,
		   X_credit			 NUMBER,
		   X_debit			 NUMBER,
		   X_date			 DATE) return NUMBER;

  PROCEDURE Names_From_IDs (X_batch_id		 NUMBER,
			    X_who_name  IN OUT VARCHAR2,
			    X_reason      IN OUT VARCHAR2,
			    X_posted      IN OUT VARCHAR2,
			    X_srp_period_id	 NUMBER,
			    X_balance_id	 NUMBER,
			    X_salesrep_name IN OUT VARCHAR2,
			    X_account_name  IN OUT VARCHAR2,
			    X_period_name   IN OUT VARCHAR2,
			    X_salesrep_id   IN OUT NUMBER,
			    X_period_id     IN OUT NUMBER);

END CN_LEDGER_JOURNAL_ENTRIES_API;

 

/
