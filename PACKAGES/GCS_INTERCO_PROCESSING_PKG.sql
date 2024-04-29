--------------------------------------------------------
--  DDL for Package GCS_INTERCO_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_INTERCO_PROCESSING_PKG" AUTHID CURRENT_USER as
/* $Header: gcsicpes.pls 120.1 2005/10/30 05:18:45 appldev noship $ */

 -- Definition of Global Data Types and Variables
  --
  -- Procedure
  --   interco_process_main
  -- Purpose
  --   This is the main routine in the intercompany elimination entry
  --   processing engine.
  --   Important steps in this routine.
	-- 1)	Get the period information.
	-- 2)	Get the consolidation entity information like currency,
        --      matching rule.
        -- 3)	Get all the subsidiaries for the given consolidation entity.
     	-- 4)	Based on the mode of consolidation run possible values
        --      are Full and Incremental, populate GCS_INTERCO_HDR_GT
        --      with corresponding information. In the same table also
        --      populate previous consolidation run intercompany entry
        --      header id and new rows information.
	-- 5)   Copy all the Intercompany transactions into the
	--      GCS_ENTRY_LINES by calling Insr_Interco_Lines routine.
	-- 6)   After successful suspense plug-in insert the header
        --      entries into the GCS_ENTRY_HEADERS table by calling
        --      the Insert Header procedure.
        -- 7)   Maintain the GCS_CONS_ENG_RUN_DTLS table.
        -- 8)   All the above processing has to be completed in one
        --      commit cycle. So here we may COMMIT.
        -- 10)  After inserting elimination headers, call the
        --      delete procedure to delete all the processed rows
        --      from the GCS_INTERCO_ELM_TRX table.

  -- Arguments
  -- Notes

  PROCEDURE interco_process_main(p_hierarchy_id IN NUMBER,
                                 p_cal_period_id IN NUMBER,
				 p_entity_id IN NUMBER,
				 p_balance_type  VARCHAR2,
				 p_elim_mode  IN VARCHAR2,
				 p_currency_code IN VARCHAR2,
                                 p_run_name IN VARCHAR2,
                                 p_translation_required IN VARCHAR2,
                                 x_errbuf OUT NOCOPY VARCHAR2,
                                 x_retcode OUT NOCOPY VARCHAR2);

 --
  -- Function
  --   insr_interco_hdrs
  -- Purpose
  --   This routine is responsible for inserting distinct pairs of entities
  --   for each intercompany rule into the global temporary table
  --   GCS_INTERCO_HDR_GT.

 FUNCTION  INSR_INTERCO_HDRS   ( p_hierarchy_id IN NUMBER,
                                 p_cal_period_id IN NUMBER,
                                 p_entity_id IN NUMBER,
				 p_balance_type  VARCHAR2,
				 p_elim_mode  IN VARCHAR2,
                                 p_xlation_required IN VARCHAR2,
				 p_currency_code IN VARCHAR2) RETURN BOOLEAN;




 --
  -- Function
  --   insr_elimination_hdrs
  -- Purpose
  --  Inserts elimination entry headers into GCS_ENTRY_HEADERS.
  --

  -- Process steps are as follows:
     --  If the threshold currency of a intercompnay rule is diffrent from
     --  consolidation entity currency, then get the conversion rate for the
     --  target currency.

     --  Then insert elimination entries headers into GCS_ENTRY_HEADERS.

     --  Then raise a warning if suspense exceeded for a pair of entities.


  FUNCTION  INSR_ELIMINATION_HDRS(p_hierarchy_id IN NUMBER,
                                  p_cal_period_id IN NUMBER,
                                  p_entity_id IN NUMBER,
				  p_balance_type  VARCHAR2,
				  p_currency_code IN VARCHAR2)
            RETURN BOOLEAN;


  END GCS_INTERCO_PROCESSING_PKG;

 

/
