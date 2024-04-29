--------------------------------------------------------
--  DDL for Package Body GCS_DYN_EPB_DATATR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DYN_EPB_DATATR_PKG" AS
/* $Header: gcsdynepbtrb.pls 120.3 2008/04/21 15:14:14 hakumar ship $ */
--
-- Package
--   gcs_dyn_epb_datatr__pkg
-- Purpose
--   FCH/EPB Link
-- History
--   12-DEC-04	R Goyal		Created

--

  --
  -- Function
  --   Gcs_Epb_Tr_Data
  -- Purpose
  --   Transfer data from FEM_BALANCES to FEM_DATAx
  -- Arguments
  --   errbuf:  Buffer to hold the error message
  --   retcode: Return code
  --   p_hierarchy_id      GCS Hierarchy for which data needs to be transferred
  --   p_balance_type_code ACTUAl or AVERAGE
  --   p_cal_period_id     Period identifier
  --   p_hierarchy_obj_def_id  Line Item hierarchy identifier
  -- Example
  --
  -- Notes
  --

   PROCEDURE Gcs_Epb_Tr_Data  (
                        errbuf       OUT NOCOPY VARCHAR2,
                        retcode      OUT NOCOPY VARCHAR2,
                        p_hierarchy_id          NUMBER,
		        p_balance_type_code     VARCHAR2,
		        p_cal_period_id         NUMBER,
                        p_analysis_cycle_id     NUMBER ) IS

   BEGIN
    null;
   END Gcs_Epb_Tr_Data ;

  -- bugfix 5569522: Added procedure
  -- Procedure
  --   submit_business_process()
  -- Purpose
  --   Called by execute_consolidation to launch the business process after the
  --   Consolidation process is completed.
  -- Arguments
  --    errbuf:              VARCHAR2 Buffer to store the error message
  --    retcode:             VARCHAR2 Return code
  --	p_analysis_cycle_id  NUMBER   Analysis Cycle ID
  --	p_cal_period_id	     VARCHAR2 Calendar Peirod ID

  PROCEDURE	submit_business_process	(
                         errbuf    OUT NOCOPY VARCHAR2,
                    	 retcode   OUT NOCOPY VARCHAR2,
                         p_analysis_cycle_id  NUMBER,
  			 p_cal_period_id      VARCHAR2) IS
   BEGIN
    null;
   END submit_business_process ;

END GCS_DYN_EPB_DATATR_PKG;

/
