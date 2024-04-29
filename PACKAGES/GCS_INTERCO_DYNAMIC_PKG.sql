--------------------------------------------------------
--  DDL for Package GCS_INTERCO_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_INTERCO_DYNAMIC_PKG" AUTHID CURRENT_USER AS
 /*$Header: gcsicdps.pls 120.2 2006/03/10 05:21:31 spala noship $ */

--
-- Package
--   gcs_interco_dynamic_pkg
-- Purpose
--   Dynamic package procedures for the Translation Program
-- History
--   08-JAN-04    Srini Pala       Created
--
  --
  -- Procedure
  --   Insert_Interco_Lines

  -- Purpose

  --   This routine is responsible for inserting all the intercompnay
  --   entry lineentities for each intercompany rule into the
  --   GCS_ENTRY_LINES table.

  -- Process steps are as follwos:
     --  The routine uses different set of SQl statements to insert
     --  elimination lines into the GCS_ENTRY_LINES table based on the
     --  p_elim_mode parameter.

     -- Elimination lines are created based on the matching rule set
     -- at the hierarchy level.
     -- The matching will be done by organization, company or cost center.

  -- Arguments

  -- Example
  --   GCS_TRANSLATION_PKG.Roll_Forward_Historical_Rates;
  -- Notes
  --

   FUNCTION  INSR_INTERCO_LINES (p_hierarchy_id IN NUMBER,
                                 p_cal_period_id IN NUMBER,
                                 p_entity_id IN NUMBER,
                                 p_match_rule_code VARCHAR2,
				 p_balance_type  VARCHAR2,
				 p_elim_mode  IN VARCHAR2,
                                 P_Currency_code IN VARCHAR2,
                                 p_dataset_code IN NUMBER,
                                 p_lob_dim_col_name IN VARCHAR2,
                                 p_cons_run_name IN VARCHAR2,
                                 p_period_end_date IN DATE,
                                 p_fem_ledger_id  IN NUMBER)
                                RETURN BOOLEAN;


  --
  -- Function
  --   insertr_suspense_lines

  -- Purpose

  --   This routine is responsible for inserting the suspense plug in lines
  --   into the GCS_ENTRY_LINES table.

  -- Process steps are as follwos:

  -- Reason
     -- Before consolidation the intercompany transactions have to be
     -- eliminated to avoid double counting in the consolidation entity.
     -- The elimination is just done by switching debits and credits for the
     -- balanced intercompnay transactions.

     -- May be some of the intercompany transactions that are not balanced
     -- becuase of missed transactions or errors.
     -- In this case along with creating elimination entries,
     -- the processe engine has to create suspense lines to balnace the
     -- unbalanced intercompany transactions.

     -- The plug-in suspense lines will be generated in two steps by
     -- using two different SQL statements.
	-- The first SQL statement generates suspense lines for the unbalanced
        -- matched intercompnay transactions.
        -- EXAMPLE
        --   ORG_ID     Line	Interco_id	Cr	      Dr
	-------------------------------------------------------------
        --   01.1001   	2020	02.2004        100.00
        --   02.2004	2020    01.1001                     80.00

        --  In the above transactions there are matched transactions
	--  but the balances are off by 20. So a suspense line
	-- will be generated with balance 20.

	-- The second SQL statement generates suspense line for the unmatched
        -- intercompnay transactions.

	-- EXAMPLE
        --   ORG_ID     Line	Interco_id	Cr	      Dr
	-------------------------------------------------------------
	--	01.6677 	3434		02.9978		100.00

 	-- If you look at the above transaction there is no matching
	-- intercompnay transaction, so a suspense line has to be created
	-- to balance the above transaction.

   FUNCTION  INSR_SUSPENSE_LINES(p_hierarchy_id IN NUMBER,
                             	   p_cal_period_id IN NUMBER,
                             	   p_entity_id IN NUMBER,
                                   p_match_rule_code VARCHAR2,
			     	   p_balance_type  VARCHAR2,
			     	   p_elim_mode  IN VARCHAR2,
                             	   p_currency_code IN VARCHAR2,
                                   p_data_set_code IN NUMBER,
                                   p_err_code OUT NOCOPY VARCHAR2,
                                   p_err_msg OUT NOCOPY VARCHAR2)
                                                        RETURN BOOLEAN;



  --
  -- Procedure
  --   Insert_Interco_Trx
  -- Purpose
  --  Inserts eligible elimination transactions
  --  into GCS_INTERCO_ELM_TRX after dataprep operation.
  --
 -- Arguments
 -- P_entry_id        Entry_id (created by dataprep) for the monetary currency
 -- p_stat_entry_id   Entry id (created by dataprep) for the stat currency
 -- p_Hierarchy_id    Hierarchy_id for the above entries.
 --                   This hierarchy id will
 --                   be used to determine the matching rule like
 -- 		      match by organization, match by company,
 --                   or match by cost center.
 -- x_errbuf          Returns error message to concurrent manager,
 --                   if there are any errors.
 -- x_retcode         Returns error code to concurrent manager,
 --                   if there are any errors.

  -- Synatx for Calling from external package.

     --  GCS_INTERCO_PROCESSING_PKG.Insert_Interco_Trx	(1112,
     --							1114
     --  						10041)
     --

     --


  PROCEDURE Insert_Interco_Trx(p_entry_id In NUMBER,
                              p_stat_entry_id IN NUMBER,
                              p_hierarchy_id IN NUMBER,
                              p_period_end_date IN DATE,
                              x_errbuf OUT NOCOPY VARCHAR2,
                              x_retcode OUT NOCOPY VARCHAR2);

END GCS_INTERCO_DYNAMIC_PKG;

 

/
