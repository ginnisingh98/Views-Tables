--------------------------------------------------------
--  DDL for Package JA_CN_ITEMIZATION_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_ITEMIZATION_INTERFACE" AUTHID CURRENT_USER AS
  --$Header: JACNITIS.pls 120.1 2007/12/03 04:19:44 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|      JACNITIS.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used to import the legacy data user input in      |
  --|     interface table. It will validate the journal lines user input    |
  --|     and make the data enable to import to table ja_cn_journal_lines.  |
  --|     After import these data, call CNAO post program.                  |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|                                                                       |
  --|      PROCEDURE    Import_Itemization_Data     PUBLIC                        |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      01/08/2007     yanbo liu         Created                      |
  --|                                                                       |
  --+======================================================================*/
    l_module_prefix        VARCHAR2(100) :='JA_CN_ITEMIZATION_INTERFACE';
    --TYPE SEGMENTS_TBL IS TABLE OF ja_cn_item_interface.segment1%TYPE;
    l_Company_Column_Name  varchar2(25);
    l_Account_Column_Name  varchar2(25);
    l_Cost_CRT_Column_Name varchar2(25);
    l_coa number(15);
  --==========================================================================
  --  PROCEDURE NAME:
  --    Invoice_Category                 Public
  --
  --  DESCRIPTION:
  --    This procedure is the main program of itemization interface program.
  --    It will process the data in interface table and import them into
  --    table ja_cn_journal_lines. At last post journals to ja_cn_account_balances.
  --
  --  PARAMETERS:
  --      P_LEDGER_ID               ledger id
  --      P_LEGAL_ENTITY_ID         legal entity id
  --      P_PERIOD_FROM             begin period
  --      P_PERIOD_TO               end period
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --
  --===========================================================================


  PROCEDURE Import_Itemization_Data(Errbuf            OUT NOCOPY VARCHAR2,
                                    Retcode           OUT NOCOPY VARCHAR2,
                                    P_LEGAL_ENTITY_ID IN NUMBER,
                                    P_LEDGER_ID       IN NUMBER,
                                    P_PERIOD_FROM     IN VARCHAR2,
                                    P_PERIOD_TO       IN VARCHAR2
                                    );

end JA_CN_ITEMIZATION_INTERFACE;




/
