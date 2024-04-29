--------------------------------------------------------
--  DDL for Package FEM_CHECK_BR_DIS_MBRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_CHECK_BR_DIS_MBRS_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_chk_dis_mbrs.pls 120.0 2008/01/09 19:20:08 gcheng ship $ */

-------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
-------------------------------------------------------------------------------

PROCEDURE Report_Invalid_Rules (
  errbuf             OUT NOCOPY VARCHAR2,
  retcode            OUT NOCOPY VARCHAR2,
  p_rule_type        IN  VARCHAR2,
  p_ledger_id        IN  NUMBER,
  p_effective_date   IN  VARCHAR2,
  p_folder_id        IN  NUMBER,
  p_object_id        IN  NUMBER,
  p_dim_id           IN  NUMBER,
  p_request_name     IN  VARCHAR2);

PROCEDURE Purge_Report_Data(errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY VARCHAR2,
                            p_execution_start_date IN VARCHAR2,
                            p_execution_end_date IN VARCHAR2,
                            p_request_id IN NUMBER);

FUNCTION Get_Unique_Report_Row RETURN NUMBER;

END FEM_CHECK_BR_DIS_MBRS_PKG;

/
