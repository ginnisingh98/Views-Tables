--------------------------------------------------------
--  DDL for Package JA_CN_CFS_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CFS_INT_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNINTS.pls 120.2 2007/12/03 04:19:23 qzhao noship $
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
  --|      23/04/2006     Shujuan Yan           Created                     |
  --+======================================================================*/
  l_module_prefix VARCHAR2(100) := 'JA_CN_CFS_CLA_CLT_PKG';
  G_MODULE_PREFIX   VARCHAR2(30) := 'JA_CN_CFS_INT_PKG.';
  G_PROC_LEVEL      INT := fnd_log.LEVEL_PROCEDURE;
  G_STATEMENT_LEVEL INT := fnd_log.LEVEL_STATEMENT;
  g_debug_devel     INT;
  --==========================================================================
  --  PROCEDURE NAME:
  --    import_sla_data                     Public
  --
  --  DESCRIPTION:
  --        This procedure is used to import the cash flow activity data from
  --        interface table inot CFS tables.
  --
  --  PARAMETERS:
  --      In: p_coa_id                     Chart of Accounts id
  --          p_ledger_id                  Ledger ID
  --          p_legal_entity_id                      legal entity ID
  --
  --  DESIGN REFERENCES:
  --      CNAO_CFS_Data_collection_TD.doc
  --
  --  CHANGE HISTORY:
  --      05/09/2009     Shujuan Yan          Created
  --===========================================================================
 PROCEDURE import_CFS_data(ERRBUF             OUT NOCOPY VARCHAR2,
                            RETCODE           OUT NOCOPY VARCHAR2,
                            P_COA_ID          IN NUMBER,
                            P_LEDGER_ID       IN NUMBER,
                            P_legal_entity_ID IN NUMBER);

end JA_CN_CFS_INT_PKG;

/
