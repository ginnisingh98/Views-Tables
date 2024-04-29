--------------------------------------------------------
--  DDL for Package FII_FIN_CAT_MAINTAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_FIN_CAT_MAINTAIN_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIFICMS.pls 115.2 2003/08/22 00:39:50 phu noship $  */

-- *******************************************************************
-- Package level variables
-- *******************************************************************

 FINDIM_VS_ID		NUMBER		:= NULL;
 FIIDIM_Debug		BOOLEAN		:= FALSE;
 FII_User_Id		NUMBER		:= NULL;
 FII_Login_Id		NUMBER		:= NULL;
 FII_Req_Id		NUMBER		:= NULL;
 FINDIM_PARENT_FLEX_ID 	NUMBER(15)	:= NULL;
 FINDIM_PARENT_VSET_ID 	NUMBER(15)	:= NULL;
 FINDIM_PARENT_NODE     VARCHAR2(150)   := NULL;
 FINDIM_imm_Child       VARCHAR2(150)   := NULL;
 FINDIM_imm_Child_ID	NUMBER(15)	:= NULL;
 FINDIM_fatal_err	EXCEPTION;
 FINDIM_MULT_PAR_err    EXCEPTION;
 FINDIM_Invalid_FC_ASG_err EXCEPTION;
 FINDIM_NOT_ENABLED     EXCEPTION;
 FINDIM_NO_FC_TYPE_ASGN EXCEPTION;
 FINDIM_next_is_leaf    VARCHAR2(1)     := NULL;

-- ************************************************************************
-- Procedure
--   Init_Load          This is the main procedure of FC dimension maintenance
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
--   Incre_Update       This is the main procedure of FC dimension maintenance
--                      program (incremental update).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Incre_Update (errbuf   OUT  NOCOPY  VARCHAR2,
		          retcode  OUT  NOCOPY  VARCHAR2);

END FII_FIN_CAT_MAINTAIN_PKG;

 

/
