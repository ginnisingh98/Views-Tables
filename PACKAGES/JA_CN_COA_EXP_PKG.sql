--------------------------------------------------------
--  DDL for Package JA_CN_COA_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_COA_EXP_PKG" AUTHID CURRENT_USER AS
--$Header: JACNCAES.pls 120.0.12000000.1 2007/08/13 14:09:10 qzhao noship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNCAES.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used for Chart of Accout Export, including        |
--|     Natural Account and 4 Subsidiary Account of "Project",            |
--|     "Third Party", "Cost Center" and "Personnel", in the CNAO Project.|
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Coa_Export                                             |
--|                                                                       |
--| HISTORY                                                               |
--|      03/03/2006     Andrew Liu          Created                       |
--+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --    Coa_Export                    Public
  --
  --  DESCRIPTION:
  --      This procedure calls COA Export programs according to
  --      the specified account type.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER              chart of accounts ID
  --      In: P_LEDGER_ID             NUMBER              ID of Ledger
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_ACCOUNT_TYPE          VARCHAR2            Type of the account
  --      In: P_XML_TEMPLATE_LANGUAGE   VARCHAR2  template language of NA exception report
  --      In: P_XML_TEMPLATE_TERRITORY  VARCHAR2  template territory of NA exception report
  --      In: P_XML_OUTPUT_FORMAT       VARCHAR2  output format of NA exception report
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/03/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Coa_Export( errbuf          OUT NOCOPY VARCHAR2
                       ,retcode         OUT NOCOPY VARCHAR2
                       ,P_COA_ID        IN NUMBER
                       ,P_LEDGER_ID        IN NUMBER
                       ,P_LE_ID         IN NUMBER
                       ,P_ACCOUNT_TYPE  IN VARCHAR2
                       ,P_XML_TEMPLATE_LANGUAGE    IN VARCHAR2
                       ,P_XML_TEMPLATE_TERRITORY   IN VARCHAR2
                       ,P_XML_OUTPUT_FORMAT        IN VARCHAR2
                      );


  --PROCEDURE Get_Acc_Subs_View( P_LEDGER_ID IN number );

END JA_CN_COA_EXP_PKG;


 

/
