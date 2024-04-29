--------------------------------------------------------
--  DDL for Package FII_COM_MAINTAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_COM_MAINTAIN_PKG" AUTHID CURRENT_USER AS
/* $Header: FIICOCMS.pls 120.1 2005/10/30 05:05:34 appldev noship $ */

-- *******************************************************************
-- Package level variables
-- *******************************************************************

 CODIM_VS_ID		        NUMBER		:= NULL;
 FIIDIM_Debug			BOOLEAN		:= FALSE;
 FII_User_Id			NUMBER		:= NULL;
 FII_Login_Id			NUMBER		:= NULL;
 FII_Req_Id			NUMBER		:= NULL;
 CODIM_PARENT_FLEX_ID           NUMBER(15)	:= NULL;
 CODIM_PARENT_VSET_ID 	        NUMBER(15)	:= NULL;
 CODIM_PARENT_NODE		VARCHAR2(150)   := NULL;
 CODIM_imm_Child		VARCHAR2(150)   := NULL;
 CODIM_imm_Child_ID	        NUMBER(15)	:= NULL;
 CODIM_fatal_err		EXCEPTION;
 CODIM_MULT_PAR_err	        EXCEPTION;
 CODIM_NOT_ENABLED		EXCEPTION;
 CODIM_next_is_leaf	        VARCHAR2(1)     := NULL;

-- ************************************************************************
-- Procedure
--   Init_Load          This is the main procedure of company dimension
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
--   Incre_Update       This is the main procedure of company dimension
--                      maintenance program (incremental update).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Incre_Update (errbuf   OUT  NOCOPY  VARCHAR2,
		          retcode  OUT  NOCOPY  VARCHAR2);

END FII_COM_MAINTAIN_PKG;

 

/
