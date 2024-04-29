--------------------------------------------------------
--  DDL for Package FII_GL_BUDGET_EXTRACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_BUDGET_EXTRACTION" AUTHID CURRENT_USER AS
/*$Header: FIIBUDXS.pls 120.1 2005/10/30 05:05:45 appldev noship $*/

--
-- PUBLIC PROCEDURES

  --
  -- Procedure
  --   	Main
  -- Purpose
  --   	This is the main routine for the Budget Upload Program from GL
  -- History
  --   	9-28-04	 M Manasseh	        Created
  -- Arguments
  --    retcode VARCHAR2  value ='S' (Success) or 'E' (Error)
  -- Notes
  --
  PROCEDURE Main(retcode IN OUT NOCOPY VARCHAR2);

END FII_GL_BUDGET_EXTRACTION;


 

/
