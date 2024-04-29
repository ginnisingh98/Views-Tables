--------------------------------------------------------
--  DDL for Package JA_CN_GSSM_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_GSSM_EXP_PKG" AUTHID CURRENT_USER AS
--$Header: JACNGSES.pls 120.0.12000000.1 2007/08/13 14:09:40 qzhao noship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNGSES.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used for GSSM Export, for Enterprise and          |
--|     Public Sector in the CNAO Project.                                |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Ent_GSSM_Export                                        |
--|      PROCEDURE Pub_GSSM_Export                                        |
--|                                                                       |
--| HISTORY                                                               |
--|      05/17/2006     Andrew Liu          Created                       |
--+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --    GSSM_Export                   PUBLIC
  --
  --  DESCRIPTION:
  --      This procedure calls GSSM Export program to export GSSM for
  --      Enterprise and Public Sector.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_GSSM_TYPE             VARCHAR2            Type of ENT/PUB
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    05/17/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE GSSM_Export( errbuf          OUT NOCOPY VARCHAR2
                        ,retcode         OUT NOCOPY VARCHAR2
                        ,P_GSSM_TYPE     IN VARCHAR2
                       );
END JA_CN_GSSM_EXP_PKG;

 

/
