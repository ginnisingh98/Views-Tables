--------------------------------------------------------
--  DDL for Package FII_COM_CC_DIM_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_COM_CC_DIM_MAPS_PKG" AUTHID CURRENT_USER AS
/* $Header: FIICCMPS.pls 120.1 2005/10/30 05:05:41 appldev noship $ */


-- ***********************************************************************************
-- Package level variables
-- ***********************************************************************************


 FIIDIM_Debug			BOOLEAN		:= FALSE;
 FII_User_Id			NUMBER		:= NULL;
 FII_Login_Id			NUMBER		:= NULL;
 COMCCDIM_fatal_err		EXCEPTION;

-- ************************************************************************************
-- Procedure
--   Init_Load          This is the main procedure of company cost center mapping table
--                      maintenance program (initial load).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Init_Load (errbuf		OUT	NOCOPY VARCHAR2,
		       retcode		OUT	NOCOPY VARCHAR2);

-- **************************************************************************************
-- Procedure
--   Incre_Update       This is the main procedure of company cost center mapping table
--                      maintenance program (incremental update).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Incre_Update (errbuf   OUT  NOCOPY  VARCHAR2,
		          retcode  OUT  NOCOPY  VARCHAR2);

END FII_COM_CC_DIM_MAPS_PKG;

 

/
