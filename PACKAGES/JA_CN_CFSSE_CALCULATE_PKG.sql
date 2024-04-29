--------------------------------------------------------
--  DDL for Package JA_CN_CFSSE_CALCULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CFSSE_CALCULATE_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNCSCS.pls 120.1.12010000.2 2008/10/28 06:28:26 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNCSCS.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used to implement calculation for main part of    |
  --|       cash flow statement                                             |
  --|                                                                       |
  --| Public PROCEDURE LIST                                                 |
  --|      PROCEDURE  Generate_Cfs_Xml                                      |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      03/22/2006     Jackey Li          Created                        |
  --|      22/09/2008     Chaoqun Wu         Updated for CNAO Enhancement   |
  --+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --    Generate_Cfs_Xml                  Public
  --
  --  DESCRIPTION:
  --        It is to generate xml output for main part of cash flow statement
  --            for small enterprise by following format of FSG xml output.
  --
  --  PARAMETERS:
  --      In: p_legal_entity_id           legal entity ID
  --          p_set_of_bks_id             set of books ID
  --          p_period_name               period name
  --          p_axis_set_id               axis set id
  --          p_rounding_option           rounding option
  --          p_balance_type              balance type
  --          p_internal_trx_flag         is intercompany transactions
  --
  --  DESIGN REFERENCES:
  --      CNAO_Cashflow_Statement_Generation(SE)_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/22/2006      Jackey Li          Created
  --      04/9/2007       Joy liu            updated
  --      22/09/2008      Chaoqun Wu         Updated for CNAO Enhancement
  --  parameter p_coa is added, change p_set_of_bks_id to p_ledger_id.
  --===========================================================================
  PROCEDURE Generate_Cfs_Xml(p_legal_entity_id   IN NUMBER
                            ,p_ledger_id     IN NUMBER
                            ,p_period_name       IN VARCHAR2
                            ,p_axis_set_id       IN NUMBER
                            ,p_rounding_option   IN VARCHAR2
                            ,p_balance_type      IN VARCHAR2
                           -- ,p_internal_trx_flag IN VARCHAR2
                            ,p_coa               IN NUMBER
                            ,p_segment_override  IN VARCHAR2); --added for CNAO Enhancement

END JA_CN_CFSSE_CALCULATE_PKG;

/
