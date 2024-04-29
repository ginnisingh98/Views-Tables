--------------------------------------------------------
--  DDL for Package FII_SETUP_VAL_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_SETUP_VAL_C" AUTHID CURRENT_USER AS
/* $Header: FIISVALS.pls 120.0.12000000.1 2007/04/11 09:58:54 dhmehra ship $ */



/************************************************************************
     			 PUBLIC PROCEDURES
************************************************************************/



-------------------------------------------------------------------------------

  -- Procedure
  --   	Main
  -- Purpose
  --   	This is the main routine of the Validate Setup program
  -- History
  --   	08-30-06	 W Wong	        Created
  -- Arguments
  --    X_User_ID  User ID used for checking user setup
  --    X_Debug    Debug mode
  -- Example
  --    result := FII_SETUP_VAL_C.Main(Errbuf, Retcode, X_User);
  -- Notes
  --
  PROCEDURE Main (Errbuf  IN OUT NOCOPY VARCHAR2,
                  Retcode IN OUT NOCOPY VARCHAR2,
                  X_User  IN VARCHAR2);

END FII_SETUP_VAL_C;

 

/
