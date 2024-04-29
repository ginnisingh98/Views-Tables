--------------------------------------------------------
--  DDL for Package FII_CC_MAINTAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_CC_MAINTAIN_PKG" AUTHID CURRENT_USER AS
/* $Header: FIICCCMS.pls 120.1 2005/10/30 05:05:32 appldev noship $ */

-- *******************************************************************
-- Package level variables
-- *******************************************************************

 CCDIM_VS_ID		NUMBER		:= NULL;
 FIIDIM_Debug		BOOLEAN		:= FALSE;
 FII_User_Id		NUMBER		:= NULL;
 FII_Login_Id		NUMBER		:= NULL;
 FII_Req_Id		NUMBER		:= NULL;
 CCDIM_PARENT_FLEX_ID 	NUMBER(15)	:= NULL;
 CCDIM_PARENT_VSET_ID 	NUMBER(15)	:= NULL;
 CCDIM_PARENT_NODE	VARCHAR2(150)   := NULL;
 CCDIM_imm_Child	VARCHAR2(150)   := NULL;
 CCDIM_imm_Child_ID	NUMBER(15)	:= NULL;
 CCDIM_fatal_err	EXCEPTION;
 CCDIM_MULT_PAR_err	EXCEPTION;
 CCDIM_NOT_ENABLED	EXCEPTION;
 CCDIM_next_is_leaf	VARCHAR2(1)     := NULL;

-- ************************************************************************
-- Procedure
--   Init_Load          This is the main procedure of cost center dimension
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
--   Incre_Update       This is the main procedure of cost center dimension
--                      maintenance program (incremental update).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Incre_Update (errbuf   OUT  NOCOPY  VARCHAR2,
		          retcode  OUT  NOCOPY  VARCHAR2);

END FII_CC_MAINTAIN_PKG;

 

/
