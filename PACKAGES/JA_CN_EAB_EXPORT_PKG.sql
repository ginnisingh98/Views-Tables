--------------------------------------------------------
--  DDL for Package JA_CN_EAB_EXPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_EAB_EXPORT_PKG" AUTHID CURRENT_USER AS
--$Header: JACNVBES.pls 120.0.12000000.1 2007/08/13 14:09:54 qzhao noship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNVBES.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used to export electronic accounting book         |
--|                                                                       |
--| PUBLILC PROCEDURE LIST                                                |
--|      PROCEDURE  Execute_Export                                        |
--|                                                                       |
--| HISTORY                                                               |
--|      03/13/2006     Jackey Li          Created                        |
--+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --    Execute_Export                     Public
  --
  --  DESCRIPTION:
  --        It is a main procedure used to implement the export functionality
  --
  --  PARAMETERS:
  --      In: P_COA_ID                    chart of accounts ID
  --          p_le_id                     legal entity ID
  --          P_LEDGER_ID                 Ledger id
  --          p_fiscal_year               fiscal_year
  --
  --  DESIGN REFERENCES:
  --      CNAO_Electronic_Accounting_Book_Export.doc
  --
  --  CHANGE HISTORY:
  --      03/13/2006      Jackey Li          Created
  --      04/30/2007      Yucheng Sun        Updated
  --===========================================================================
  PROCEDURE Execute_Export(P_COA_ID      IN NUMBER
                          ,p_le_id       IN NUMBER
                          ,P_LEDGER_ID   IN NUMBER
                          ,p_fiscal_year IN VARCHAR2);

END JA_CN_EAB_EXPORT_PKG;


 

/
