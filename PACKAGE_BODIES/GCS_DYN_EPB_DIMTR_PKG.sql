--------------------------------------------------------
--  DDL for Package Body GCS_DYN_EPB_DIMTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DYN_EPB_DIMTR_PKG" AS
/* $Header: gcsdyndimtrb.pls 120.1 2005/10/30 05:17:44 appldev noship $ */
--
-- Package
--   gcs_dyn_epb_dimtr__pkg
-- Purpose
--   FCH/EPB Link
-- History
--   12-DEC-04	R Goyal		Created

--

  --
  -- Function
  --   Gcs_Epb_Tr_Dim
  -- Purpose
  --   Transfer dim from FEM_BALANCES to FEM_DIMx
  -- Arguments
  --   errbuf:  Buffer to hold the error message
  --   retcode: Return code
  --   p_hierarchy_id      GCS Hierarchy for which dim needs to be transferred
  --   p_balance_type_code ACTUAl or AVERAGE
  --   p_cal_period_id     Period identifier
  --   p_hierarchy_obj_def_id  Line Item hierarchy identifier
  -- Example
  --
  -- Notes
  --

   PROCEDURE Gcs_Epb_Tr_Dim  (
                        errbuf       OUT NOCOPY VARCHAR2,
                        retcode      OUT NOCOPY VARCHAR2 ) IS

   BEGIN
    null;
   END Gcs_Epb_Tr_Dim ;



END GCS_DYN_EPB_DIMTR_PKG;

/
