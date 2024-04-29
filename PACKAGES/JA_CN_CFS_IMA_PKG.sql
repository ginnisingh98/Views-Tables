--------------------------------------------------------
--  DDL for Package JA_CN_CFS_IMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CFS_IMA_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNIMAS.pls 120.0.12000000.1 2007/08/13 14:09:42 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 1998 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNIMAS.pls
  --|
  --| DESCRIPTION
  --|
  --|      This package is to provide share procedures for CNAO programs
  --|
  --| PROCEDURE LIST
  --|
  --|   Item_Mapping_Analysis_Report
  --|
  --|
  --| HISTORY
  --|   27-APR-2007     Joy Liu Created
  --+======================================================================*/

 l_module_prefix              VARCHAR2(100) :='JA_CN_CFS_IMA_PKG';

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --Item_Mapping_Analysis_Report                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the record which item mapping form saved.
  --    It can help the audience know the cash flow of the company and do cash forecasting based on it
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf                  Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode                 Mandatory parameter for PL/SQL concurrent programs
  --      In:      P_APLICATION_ID	         Application ID
  --      In:    P_EVENT_CLASS_CODE          Event class code
  --      In:  P_SUPPORTING_REFERENCE_CODE   Supporting reference code
  --      In:   P_CHART_OF_ACCOUNTS_ID       Chart of Accounts ID

  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      27-APR-2007     Joy Liu Created
  --
  --===========================================================================

     PROCEDURE Item_Mapping_Analysis_Report(errbuf                        OUT NOCOPY VARCHAR2
                                           ,retcode                       OUT NOCOPY VARCHAR2
                                           ,P_APLICATION_ID		            IN Number
                                           ,P_EVENT_CLASS_CODE		        IN Varchar2
                                           ,P_SUPPORTING_REFERENCE_CODE		IN Varchar2
                                           ,P_CHART_OF_ACCOUNTS_ID        IN NUMBER);



END JA_CN_CFS_IMA_PKG;

 

/
