--------------------------------------------------------
--  DDL for Package FII_UDD1_MAINTAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_UDD1_MAINTAIN_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIU1CMS.pls 120.1 2005/10/30 05:05:37 appldev noship $ */

-- *******************************************************************
-- Package level variables
-- *******************************************************************

 UDIM1_VS_ID		        NUMBER		:= NULL;
 FIIDIM_Debug			BOOLEAN		:= FALSE;
 FII_User_Id			NUMBER		:= NULL;
 FII_Login_Id			NUMBER		:= NULL;
 FII_Req_Id			NUMBER		:= NULL;
 UDIM1_PARENT_FLEX_ID           NUMBER(15)	:= NULL;
 UDIM1_PARENT_VSET_ID 	        NUMBER(15)	:= NULL;
 UDIM1_PARENT_NODE		VARCHAR2(150)   := NULL;
 UDIM1_imm_Child		VARCHAR2(150)   := NULL;
 UDIM1_imm_Child_ID	        NUMBER(15)	:= NULL;
 UDIM1_fatal_err		EXCEPTION;
 UDIM1_MULT_PAR_err	        EXCEPTION;
 UDIM1_NOT_ENABLED		EXCEPTION;
 UDIM1_next_is_leaf	        VARCHAR2(1)     := NULL;

-- ************************************************************************
-- Procedure
--   Init_Load          This is the main procedure of User Defined dimension1
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
--   Incre_Update       This is the main procedure of User Defined dimension1
--                      maintenance program (incremental update).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Incre_Update (errbuf   OUT  NOCOPY  VARCHAR2,
		          retcode  OUT  NOCOPY  VARCHAR2);

END FII_UDD1_MAINTAIN_PKG;

 

/
