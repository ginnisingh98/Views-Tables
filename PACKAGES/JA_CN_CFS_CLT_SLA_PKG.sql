--------------------------------------------------------
--  DDL for Package JA_CN_CFS_CLT_SLA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CFS_CLT_SLA_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNSLAS.pls 120.1.12010000.2 2008/10/28 07:03:47 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNCDCS.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used in Collecting CFS Data from SLA in the CNAO  |
  --|     Project.                                                          |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE Collect_SLA_Data                                       |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      23/04/2006     Shujuan Yan           Created
  --|      08/09/2008     Yao Zhang        Fix Bug#7334017 for R12 enhancment|                |
  --+======================================================================*/
  l_module_prefix VARCHAR2(100) := 'JA_CN_CFS_CLA_CLT_PKG';
  G_MODULE_PREFIX   VARCHAR2(30) := 'JA_CN_CFS_DATA_CLT_PKG.';
  G_PROC_LEVEL      INT := fnd_log.LEVEL_PROCEDURE;
  G_STATEMENT_LEVEL INT := fnd_log.LEVEL_STATEMENT;
  g_debug_devel     INT;
   -- Fix Bug#7334017 add begin
  --==========================================================================
  --  PROCEDURE NAME:
  --    get_balancing_segment                     public
  --
  --  DESCRIPTION:
  --  This procedure returns the balancing segment value of a CCID.
  --
  --  PARAMETERS:
  --      In: P_CC_ID         NUMBER
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/09/2008     Yao Zhang          Created
  --===========================================================================
  FUNCTION get_balancing_segment
  ( P_CC_ID               IN        NUMBER
  )
  RETURN VARCHAR2;
  -- Fix Bug#7334017 add end
  --==========================================================================
  --  PROCEDURE NAME:
  --    collect_sla_data                     Public
  --
  --  DESCRIPTION:
  --        This procedure is used to search the record in sla module and insert
  --        the cash flow item into CFS tables
  --
  --  PARAMETERS:
  --      In: p_coa_id                     Chart of Accounts id
  --          p_ledger_id                  Ledger ID
  --          p_le_id                      legal entity ID
  --          p_period_set_name            period_set_name
  --          p_gl_period_from             the calculation period
  --          p_gl_period_to               the calculation period
  --          p_source                     Source
  --
  --  DESIGN REFERENCES:
  --      CNAO_CFS_Data_collection_TD.doc
  --
  --  CHANGE HISTORY:
  --      23/04/2006     Shujuan Yan          Created
  --===========================================================================
  PROCEDURE collect_SLA_data(P_COA_ID          IN NUMBER,
                             P_LEDGER_ID       IN NUMBER,
                             P_LE_ID           IN NUMBER,
                             P_PERIOD_SET_NAME IN VARCHAR2,
                             P_GL_PERIOD_FROM  IN VARCHAR2,
                             P_GL_PERIOD_TO    IN VARCHAR2,
                             P_SOURCE          IN VARCHAR2);

end JA_CN_CFS_CLT_SLA_PKG;

/
