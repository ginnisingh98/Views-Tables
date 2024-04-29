--------------------------------------------------------
--  DDL for Package JA_CN_CFS_DATA_CLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CFS_DATA_CLT_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNCDCS.pls 120.0.12010000.2 2008/10/28 06:15:05 shyan ship $

  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNCDCS.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used in Collecting CFS Data from GL/Intercompany/ |
  --|     AR/AP in the CNAO Project.                                        |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE Cfs_Data_Clt                                           |
  --|      PROCEDURE collect_AR_data                                        |
  --|      PROCEDURE collect_AP_data                                        |
  --|      FUNCTION  get_period_name                                        |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      03/01/2006     Andrew Liu          Created                       |
  --|      03/24/2006     Jogen Hu            merge AR,AP parts             |
  --+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --    Cfs_Data_Clt                  public
  --
  --  DESCRIPTION:
  --      This procedure calls data collection programs according to
  --      the specified source.
  --
  --  PARAMETERS:
  --      In: P_SOB_ID                NUMBER              ID of Set Of Book
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_PERIOD_SET_NAME       VARCHAR2            Name of the period set
  --                                                      in the set of book
  --      In: P_GL_PERIOD_FROM        VARCHAR2            Start period
  --      In: P_GL_PERIOD_TO          VARCHAR2            End period
  --      In: P_SOURCE                VARCHAR2            Source of the collection
  --      In: P_DFT_ITEM              VARCHAR2            default CFS item
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/01/2006     Andrew Liu          Created
  --      04/01/2007     Yucheng Sun         Updated
  --===========================================================================
  PROCEDURE Cfs_Data_Clt( P_COA_ID           IN NUMBER
                         ,P_LEDGER_ID        IN NUMBER
                         ,P_LE_ID            IN NUMBER
                         ,P_PERIOD_SET_NAME  IN VARCHAR2
                         ,P_GL_PERIOD_FROM   IN VARCHAR2
                         ,P_GL_PERIOD_TO     IN VARCHAR2
                         ,P_SOURCE           IN VARCHAR2);

 -- Fix bug#7334017 add begin
  --==========================================================================
  --  PROCEDURE NAME:
  --    get_balancing_segment                     public
  --
  --  DESCRIPTION:
  --  This procedure returns the balancing segment value of a CCID.
  --
  --  PARAMETERS:
  --      In: P_CC_ID         NUMBER
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    09/01/2008     Yao Zhang          Created
  --===========================================================================
  FUNCTION get_balancing_segment
  ( P_CC_ID               IN        NUMBER
  )
  RETURN VARCHAR2;
  -- Fix bug#7334017 add end

  --==========================================================================
  --  FUNCTION NAME:
  --    get_period_name                     Public
  --
  --  DESCRIPTION:
  --        This FUNCTION is used to get period name from a period set and given date
  --        the period name is month type
  --
  --  PARAMETERS:
  --      In: p_period_set_name            period set name
  --          p_gl_date                    date
  --          p_period_type                period type
  --  return: period name
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/08/2006     Jogen Hu          Created
  --===========================================================================
  FUNCTION get_period_name(p_period_set_name IN VARCHAR2,
                           p_gl_date         IN DATE,
                           p_period_type     IN VARCHAR2) RETURN VARCHAR2;


END JA_CN_CFS_DATA_CLT_PKG;


/
