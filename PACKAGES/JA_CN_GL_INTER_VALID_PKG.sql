--------------------------------------------------------
--  DDL for Package JA_CN_GL_INTER_VALID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_GL_INTER_VALID_PKG" AUTHID CURRENT_USER AS
--$Header: JACNGIVS.pls 120.2.12010000.2 2008/10/28 07:01:28 shyan ship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNGIVS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used for GL Journals and Intercompany Transactions|
--|     Validation in the CNAO Project.                                   |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE GL_Validation                                          |
--|      PROCEDURE Intercompany_Validation                                |
--|                                                                       |
--| HISTORY                                                               |
--|      02/24/2006     Andrew Liu          Created                       |
--|      04/30/2007     Yucheng Sun         Updated
--|      04/09/2008     Chaoqun Wu          Updated for CNAO Enhancement  |
--+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --    GL_Validation                 Public
  --
  --  DESCRIPTION:
  --      This procedure checks GL Journals and output the invalid ones.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER              Chart of Accounts id
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_LEDGER_ID             NUMBER              ID of the ledger
  --      In: P_START_PERIOD          VARCHAR2            Start period
  --      In: P_END_PERIOD            VARCHAR2            End period
  --      In: P_SOURCE                VARCHAR2            Specified journal source
  --      In: P_JOURNAL_CTG           VARCHAR2            Specified journal category
  --      In: P_STATUS                VARCHAR2            The gl status transfered from AGIS
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    02/24/2006     Andrew Liu          Created
  --      04/13/2007     Yucheng Sun         Updated
  --                                         delete parameter: P_COM_SEGMENT
  --      03/09/2008     Chaoqun Wu          Updated
  --                                         CNAO Enhancement: add company segment
  --===========================================================================
  PROCEDURE GL_Validation( errbuf          OUT NOCOPY VARCHAR2
                          ,retcode         OUT NOCOPY VARCHAR2
                          ,P_COA_ID        IN NUMBER
                          ,P_LE_ID         IN NUMBER
                          ,P_LEDGER_ID     IN NUMBER
                          ,P_START_PERIOD  IN VARCHAR2
                          ,P_END_PERIOD    IN VARCHAR2
                          ,P_SOURCE        IN VARCHAR2
                          ,P_JOURNAL_CTG   IN VARCHAR2
                          ,P_STATUS        IN VARCHAR2
                          ,P_COM_SEG       IN VARCHAR2  --Added for CNAO Enhancement
                         );

  --==========================================================================
  --  PROCEDURE NAME:
  --    Intercompany_Validation       Public
  --
  --  DESCRIPTION:
  --      This procedure checks Intercompany transactions and output
  --      the invalid ones.
  --
   --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER              chart of accounts ID
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_LEDGER_ID             NUMBER              ID of the ledger
  --      In: P_START_PERIOD          VARCHAR2            Start period
  --      In: P_END_PERIOD            VARCHAR2            End period
  --      In: P_STATUS                VARCHAR2            The gl status transfered from AGIS
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    02/24/2006     Andrew Liu          Created
  --      04/21/2007     Yucheng Sun         Updated
  --                                         delete parameter: P_COM_SEGMENT
  --      02/09/2008     Chaoqun Wu          Updated
  --                                         CNAO Enhancement: add company segment
  --===========================================================================
  PROCEDURE Intercompany_Validation( errbuf          OUT NOCOPY VARCHAR2
                                    ,retcode         OUT NOCOPY VARCHAR2
                                    ,P_COA_ID        IN NUMBER
                                    ,P_LE_ID         IN NUMBER
                                    ,P_LEDGER_ID     IN NUMBER
                                    ,P_START_PERIOD  IN VARCHAR2
                                    ,P_END_PERIOD    IN VARCHAR2
                                    ,P_STATUS        IN VARCHAR2
                                    ,P_COM_SEG      IN VARCHAR2  --Added for CNAO Enhancement
  );


  /*procedure  Get_Account_Combo_and_Desc(
    P_SOB_ID IN number,    P_CCID IN number,
    P_ACCOUNT OUT VARCHAR2,P_ACCOUNT_DESC OUT VARCHAR2
  );*/
END JA_CN_GL_INTER_VALID_PKG;


/
