--------------------------------------------------------
--  DDL for Package FII_AR_COLLECTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_COLLECTORS_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARCOLLS.pls 120.0.12000000.1 2007/02/23 02:27:40 applrt ship $ */

-- *******************************************************************
-- Package level variables
-- *******************************************************************

 FIIDIM_Debug			BOOLEAN		:= FALSE;
 FII_User_Id			NUMBER		:= NULL;
 FII_Login_Id			NUMBER		:= NULL;
 FII_Req_Id			NUMBER		:= NULL;
 CODIM_fatal_err		EXCEPTION;

-- ************************************************************************

-- Procedure
--   Init_Load          This is the main procedure of collector dimension
--                      maintenance program (initial load).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Init_Load (errbuf		OUT	NOCOPY VARCHAR2,
		       retcode		OUT	NOCOPY VARCHAR2);

-- ************************************************************************
-- Procedure
--   Incre_Update       This is the main procedure of collector dimension
--                      maintenance program (incremental update).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Incre_Update (errbuf   OUT  NOCOPY  VARCHAR2,
		          retcode  OUT  NOCOPY  VARCHAR2);

END FII_AR_COLLECTORS_PKG;

 

/
