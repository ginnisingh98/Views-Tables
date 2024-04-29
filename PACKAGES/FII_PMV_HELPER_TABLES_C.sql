--------------------------------------------------------
--  DDL for Package FII_PMV_HELPER_TABLES_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PMV_HELPER_TABLES_C" AUTHID CURRENT_USER AS
/* $Header: FIIPMVHS.pls 120.1 2005/10/30 05:05:43 appldev noship $ */

-- *******************************************************************
-- Package level variables
-- *******************************************************************


 FIIDIM_Debug			BOOLEAN		:= FALSE;
 FII_User_Id			NUMBER		:= NULL;
 FII_Login_Id			NUMBER		:= NULL;
 FII_Req_Id			NUMBER		:= NULL;
 PMVH_fatal_err		        EXCEPTION;

 TYPE dim_nodes_rec is RECORD (number_of_nodes number (15), dim_short_name varchar2 (30), gain number);
 type dim_nodes_tab is table of dim_nodes_rec
    index by binary_integer;

-- ************************************************************************
-- Procedure
--   Load_Main          This is the main procedure of PMV Helper Table Population
--                      program.
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   p_load_mode        Load Mode INIT/INCRE
--   errbuf		Standard error buffer
--   retcode 		Standard return code

 PROCEDURE Load_Main (errbuf	OUT NOCOPY VARCHAR2,
	 	      retcode	OUT NOCOPY VARCHAR2,
		      p_load_mode  IN VARCHAR2);

END FII_PMV_HELPER_TABLES_C;

 

/
