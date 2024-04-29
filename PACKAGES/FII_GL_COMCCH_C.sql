--------------------------------------------------------
--  DDL for Package FII_GL_COMCCH_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_COMCCH_C" AUTHID CURRENT_USER AS
/*$Header: FIIGLH1S.pls 115.0 2003/07/28 21:23:21 phu noship $*/

-----------------------------------------------------------------
-- PROCEDURE MAIN
--
-- Populate two helper tables: FII_COM_CC_MAPPINGS and FII_CC_MGR_SUP
-----------------------------------------------------------------
PROCEDURE MAIN(Errbuf        IN OUT  NOCOPY VARCHAR2,
               Retcode       IN OUT  NOCOPY VARCHAR2,
               pmode          IN   VARCHAR2);

END FII_GL_COMCCH_C;

 

/
