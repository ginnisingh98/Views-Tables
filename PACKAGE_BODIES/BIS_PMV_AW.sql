--------------------------------------------------------
--  DDL for Package Body BIS_PMV_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_AW" AS
/* $Header: BISVAWDB.pls 120.0 2005/06/01 16:44:29 appldev noship $ */

	PROCEDURE SET_DIMENSION_LEVEL_VALUES (p_parameters_tbl  IN	BIS_PMV_PAGE_PARAMETER_TBL,
					      p_aw_name	    	IN	VARCHAR2) IS

	  l_dim_level_name		VARCHAR2(255);
	  l_dim_level_id		VARCHAR2(255);
	  statement			VARCHAR2(100);

	  BEGIN

          IF p_parameters_tbl IS NOT NULL THEN
	  FOR i IN 1..p_parameters_tbl.COUNT
		  LOOP
		  	l_dim_level_name 		:= p_parameters_tbl(i).parameter_name;
		    	l_dim_level_id 	:= p_parameters_tbl(i).parameter_value;

		    	statement := 'limit ' || l_dim_level_name || ' to ' || '''' || l_dim_level_id || '''';

   	  	    	BEGIN
		    		dbms_aw.execute(statement);
                        EXCEPTION WHEN OTHERS THEN
                          NULL;

		    	END;
	  END LOOP;
	  END IF;
	  dbms_aw.execute('aw attach ' || p_aw_name);
	END;

END BIS_PMV_AW;

/
