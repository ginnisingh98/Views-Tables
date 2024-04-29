--------------------------------------------------------
--  DDL for Package FII_LOB_MAINTAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_LOB_MAINTAIN_PKG" AUTHID CURRENT_USER AS
/* $Header: FIILBCMS.pls 115.2 2003/08/22 00:25:23 phu noship $  */

-- *******************************************************************
-- Package level variables
-- *******************************************************************

 LOBDIM_VS_ID		NUMBER		:= NULL;
 FIIDIM_Debug		BOOLEAN		:= FALSE;
 FII_User_Id		NUMBER		:= NULL;
 FII_Login_Id		NUMBER		:= NULL;
 FII_Req_Id		NUMBER		:= NULL;
 LOBDIM_PARENT_FLEX_ID 	NUMBER(15)	:= NULL;
 LOBDIM_PARENT_VSET_ID 	NUMBER(15)	:= NULL;
 LOBDIM_PARENT_NODE     VARCHAR2(150)   := NULL;
 LOBDIM_imm_Child       VARCHAR2(150)   := NULL;
 LOBDIM_imm_Child_ID	NUMBER(15)	:= NULL;
 LOBDIM_fatal_err	EXCEPTION;
 LOBDIM_MULT_PAR_err    EXCEPTION;
 LOBDIM_NOT_ENABLED     EXCEPTION;
 LOBDIM_next_is_leaf    VARCHAR2(1)     := NULL;

-- ************************************************************************
-- Procedure
--   Init_Load          This is the main procedure of LOB dimension maintenance
--                      program (initial load).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Init_Load (errbuf		OUT	NOCOPY VARCHAR2,
		       retcode		OUT	NOCOPY VARCHAR2);

-- ************************************************************************
-- Procedure
--   Incre_Update       This is the main procedure of LOB dimension maintenance
--                      program (incremental update).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Incre_Update (errbuf   OUT  NOCOPY  VARCHAR2,
		          retcode  OUT  NOCOPY  VARCHAR2);

END FII_LOB_MAINTAIN_PKG;

 

/
