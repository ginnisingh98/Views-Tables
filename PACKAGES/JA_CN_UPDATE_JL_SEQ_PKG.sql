--------------------------------------------------------
--  DDL for Package JA_CN_UPDATE_JL_SEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_UPDATE_JL_SEQ_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNVJSS.pls 120.0.12000000.1 2007/08/13 14:09:56 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNVJSS.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used to fetch a sequence number                   |
  --|        for Journal Itemization program                                |
  --|                                                                       |
  --| PUBLIC PROCEDURE LIST                                                 |
  --|      FUNCTION  Fetch_JL_Seq                                           |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      03/13/2006     Jackey Li          Created                        |
  --      04/28/2007     Qingjun Zhao       Add column Ledger_id to table   |
  --                                        ja_cn_journal_numbering         |
  --+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --    Fetch_JL_Seq                     Public
  --
  --  DESCRIPTION:
  --       This procedure is used to fetch a sequence number under the
  --       Legal Entity and ledger, Period Name for Journal Itemization program
  --
  --  PARAMETERS:
  --      In: p_legal_entity_ID            legal entity ID
  --          p_ledger_id                  ledger ID
  --          p_period_name                period_name
  --
  --  DESIGN REFERENCES:
  --      CNAO_Update_Journal_Sequence_PKG_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/13/2006      Jackey Li          Created
  --      04/28/2007     Qingjun Zhao       Add column Ledger_id to table
  --                                        ja_cn_journal_numbering
  --===========================================================================
  FUNCTION Fetch_JL_Seq(p_legal_entity_ID IN NUMBER
                       ,p_ledger_id       in number
                       ,p_period_name     IN VARCHAR2) RETURN NUMBER;

END JA_CN_UPDATE_JL_SEQ_PKG;

 

/
