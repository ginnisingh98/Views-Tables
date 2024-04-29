--------------------------------------------------------
--  DDL for Package JA_CN_ACC_JE_ITEMIZATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_ACC_JE_ITEMIZATION_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNAJIS.pls 120.0.12000000.1 2007/08/13 14:09:07 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|       JACNAJIS.pls                                                    |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used in account and journal itemizatoin to        |
  --|     generate                                                          |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE populate_journal_of_period                             |
  --|      PROCEDURE get_description_from_GIS                               |
  --|      PROCEDURE unitemize_journal_lines                                |
  --|      PROCEDURE generate_code_combination_view                         |
  --|      PROCEDURE get_period_range                                       |
  --|      PROCEDURE transfer_gl_sla_to_cnao                                |
  --|      PROCEDURE generate_journal_and_line_num                          |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      04/12/2007     Qingjun Zhao          Created                     |
  --+========================================================================

  --=========================================================================
  --  PROCEDURE NAME:
  --    transfer_gl_sla_to_cnao                   Public
  --
  --  DESCRIPTION:
  --        This is main procedure through which other procedures are called
  --        according to source and category of journal.Then call generate
  --        journal number and journal line number procedure and call post
  --        program
  --  PARAMETERS:
  --     Out: errbuf                 Mandatory parameter for PL/SQL concurrent
  --                                 programs
  --     Out: retcode                Mandatory parameter for PL/SQL concurrent
  --                                 programs
  --     In: P_chart_of_accounts_id  Id of Chart of Accounts
  --     In: p_period_name           Accounting period name
  --     In: p_legal_entity_ID       Legal entity id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      04/12/2007     Qingjun Zhao          Created
  --===========================================================================

  PROCEDURE Transfer_Gl_Sla_To_Cnao(Errbuf                 OUT NOCOPY VARCHAR2,
                                    Retcode                OUT NOCOPY VARCHAR2,
                                    p_Chart_Of_Accounts_Id IN NUMBER,
                                    p_Ledger_Id            IN NUMBER,
                                    p_Legal_Entity_Id      IN NUMBER,
                                    p_Period_Name          IN VARCHAR2);

END Ja_Cn_Acc_Je_Itemization_Pkg;

 

/
