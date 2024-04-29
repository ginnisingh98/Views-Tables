--------------------------------------------------------
--  DDL for Package JA_CN_CFS_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CFS_REPORT_PKG" AUTHID CURRENT_USER AS
 --$Header: JACNCFDS.pls 120.6.12010000.2 2008/10/28 06:17:34 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|      JACNCFDS.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used to generate the CFS detail report.           |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|                                                                       |
  --|      PROCEDURE    Cfs_Detail_Report     PUBLIC                        |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      30/12/2006     Shujuan Yan         Created
  --|      08/09/2008     Yao Zhang           Fix bug#7334017               |
  --|                                                                       |
  --+======================================================================*/
  l_Module_Prefix VARCHAR2(100) := 'JA_CN_CFS_REPORT_PKG';
  --==========================================================================
  --  PROCEDURE NAME:
  --    Cfs_Detail_Report                 Public
  --
  --  DESCRIPTION:
  --      This procedure is to generate the cfs detail report.
  --
  --  PARAMETERS:
  --      Out: errbuf
  --      Out: retcode
  --      In: P_LEGAL_ENTITY_ID       ID of Legal Entity
  --      In: P_LEDGER_ID             ID of Set Of Book
  --      In: P_Chart_of_Accounts_ID  Identifier of gl chart of account
  --      In: P_ADHOC_PREFIX          Ad hoc prefix for FSG report, a required
  --                                  parameter for FSG report
  --      In: P_INDUSTRY              Industry with constant value 'C' for
  --                                  now, a required parameter for FSG report
  --      In: P_ID_FLEX_CODE          ID flex code, a required parameter for
  --                                  FSG report
  --      In: P_REPORT_ID             Identifier of FSG report
  --      In: P_GL_PERIOD_FROM        Start period
  --      In: P_GL_PERIOD_TO          End period
  --      In: P_SOURCE                Source of the collection
  --      In: P_INTERNAL_TRX          To indicate if intercompany transactions
  --                                  should be involved in amount calculation
  --                                  of cash flow statement.
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      04/27/2007     Qingjun Zhao          Created
  --      28/02/2008     Arming                Fix bug#6751696
  --      08/09/2008     Yao Zhang             Fix bug#7334017 for R12 enhancment
  --===========================================================================

  PROCEDURE Cfs_Detail_Report
  (
    Errbuf                 OUT NOCOPY VARCHAR2
   ,Retcode                OUT NOCOPY VARCHAR2
   ,p_Legal_Entity_Id      IN NUMBER
   ,p_Ledger_Id            IN NUMBER
   ,p_Chart_Of_Accounts_Id IN NUMBER
   ,p_Adhoc_Prefix         IN VARCHAR2
   ,p_Industry             IN VARCHAR2
   ,p_Id_Flex_Code         IN VARCHAR2
   ,p_Report_Id            IN NUMBER
   ,p_Row_Set_Id           IN NUMBER
   -- Fix bug#6751696 delete begin
   --,P_Row_Name             IN VARCHAR2
   -- Fix bug#6751696 delete end
   -- Fix bug#6751696 add begin
   ,P_Row_Name             IN NUMBER
   -- Fix bug#6751696 add end
   ,p_Gl_Period_From       IN VARCHAR2
   ,p_Gl_Period_To         IN VARCHAR2
   ,p_Source               IN VARCHAR2
   ,P_BSV                  IN VARCHAR2--Fix bug#7334017  add
  );

END Ja_Cn_Cfs_Report_Pkg;


/
