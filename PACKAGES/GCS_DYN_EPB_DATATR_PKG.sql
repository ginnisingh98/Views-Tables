--------------------------------------------------------
--  DDL for Package GCS_DYN_EPB_DATATR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DYN_EPB_DATATR_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsdynepbtrs.pls 120.3 2007/12/13 11:52:12 cdesouza noship $ */


  -- bugfix 5569522: Added p_analysis_cycle_id
  -- Procedure
  --   Gcs_Epb_Tr_Data
  -- Purpose
  --   Transfer data from FEM_BALANCES to FEM_DATA11
  -- Arguments
  --   errbuf:             Buffer to store the error message
  --   retcode:            Return code
  --   p_hierarchy_id      GCS Hierarchy for which data needs to be transferred
  --   p_balance_type_code ACTUAl or AVERAGE
  --   p_period_name       Period name
  --   p_hierarchy_obj_def_id  Line Item hierarchy identifier
  --   p_analysis_cycle_id     Analysis Cycle ID.
  -- Example
  --
  -- Notes
  PROCEDURE Gcs_Epb_Tr_Data (
                errbuf       OUT NOCOPY VARCHAR2,
		retcode      OUT NOCOPY VARCHAR2,
		p_hierarchy_id          NUMBER,
		p_balance_type_code     VARCHAR2,
		p_cal_period_id         NUMBER,
        p_analysis_cycle_id     NUMBER );



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
                         p_analysis_cycle_id  IN NUMBER,
  						 p_cal_period_id      IN VARCHAR2);


END GCS_DYN_EPB_DATATR_PKG;

/
