--------------------------------------------------------
--  DDL for Package Body BOM_FILTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_FILTER" AS
/* $Header: BOMXRECB.pls 120.1 2005/06/01 19:04:52 appldev  $ */
/*==========================================================================+
|   Copyright (c) 2003 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMXRECB.pls                                               |
| DESCRIPTION  : Procedure explores and marks the parent items in 	    |
|		 BOM_EXPLOSION_TEMP table.
| Parameters   :	p_ParamSortOrder  Sort Order Array	            |
|			p_GroupId	  Explosion Group ID		    |
|			x_ResultSortOrder Resultant Sort Order Array 	    |
|									    |
| Revision								    |
| 2003/10/22	Ajay			creation			    |
| 2004/1/16	Ajay			Modified the method to only update  |
|					the row with flag.		    |
|                                                                           |
+==========================================================================*/

	G_PARAM_LIST PARAM_LIST;

	PROCEDURE applyFilter (p_ParamSortOrder dbms_sql.VARCHAR2_TABLE, p_GroupId VARCHAR2) as

	l_st DATE := sysdate;
	BEGIN

--	Reset the flag
		UPDATE BOM_EXPLOSIONS_ALL
		   SET HGRID_FLAG=NULL
		 WHERE HGRID_FLAG='Y'
	           AND group_id = p_GroupId
	           AND plan_level <> 0;

	--	 Update all the resultant rows to HGRID_FLAG='Y'
	--	 Code to handle if the SORT_ORDER array is empty.
		 IF p_ParamSortOrder IS NOT NULL AND p_ParamSortOrder.COUNT <> 0 THEN
		 FORALL j IN p_ParamSortOrder.FIRST .. p_ParamSortOrder.LAST
			UPDATE BOM_EXPLOSIONS_ALL SET hgrid_flag='Y' WHERE SORT_ORDER=p_ParamSortOrder(j) AND GROUP_ID=p_GroupId;
		 END IF;
 		--dbms_output.put_line('applying filter: start: ' || to_char(l_st, 'mm-dd-yyyy hh24:mi:ss'));
                --dbms_output.put_line('applying filter: end  : ' || to_char(sysdate, 'mm-dd-yyyy hh24:mi:ss'));
		 EXCEPTION
			WHEN NO_DATA_FOUND THEN
       	               null;
				--debug('The BOM_EXPLOSION_TEMP table doesnt have data...');
	END applyFilter;


        /*******************************************************************
        * Procedure: addBindParameter
        * Parameter: p_bind_parameter IN VARCHAR2
        * Purpose  : Helper method to be called for building the query string
	*	     with the required bind values.
	*	     The java layer would call this for every bind parameter to
	*	     be added to the filter query.
        *
        *********************************************************************/
	PROCEDURE addBindParameter(p_bind_parameter VARCHAR2)
	AS
	BEGIN
		G_PARAM_LIST(G_PARAM_LIST.COUNT + 1) := p_bind_parameter;
	END;

        PROCEDURE clearBindParameter
	AS
	BEGIN
	  G_PARAM_LIST.delete;
	END;

	PROCEDURE enableParents
	AS
		l_comps_in_filter BINARY_INTEGER := bom_filter.sort_order_t.COUNT;
		l_sort_order VARCHAR2(2000);
		l_st date := sysdate;
		l_cnt number;
	BEGIN
		FOR comps IN 1..l_comps_in_filter
		LOOP
			--
			-- split the sort_order to get all the parents
			--
			l_sort_order := bom_filter.sort_order_t(comps);
			l_cnt := floor(length(l_sort_order)/Bom_Common_Definitions.G_Bom_SortCode_Width) - 1;

			FOR ind IN 1..l_cnt
			LOOP
				--bom_filter.sort_order_t.extend;
				bom_filter.sort_order_t(bom_filter.sort_order_t.COUNT+1) :=
						substr(l_sort_order,1,(ind*Bom_Common_Definitions.G_Bom_SortCode_Width));
			END LOOP;
		END LOOP;

		--dbms_output.put_line('enabling parents done: ' || to_char(l_st, 'mm-dd-yyyy hh24:mi:ss'));
		--dbms_output.put_line(to_char(sysdate, 'mm-dd-yyyy hh24:mi:ss'));

		EXCEPTION
			WHEN OTHERS THEN
				--dbms_output.put_line('error: ' || substr(sqlerrm,1,200));
				raise;
	END;

	/*******************************************************************
	* Procedure: applyFilter
	* Parameter: p_filterQuery IN VARCHAR2
	*	     p_GroupId	   IN NUMBER
	* Purpose  : Dynamically execute the filter query and apply the filter
	*	     to the explosion identified by the given group id
	*********************************************************************/
	PROCEDURE applyFilter( p_FilterQuery IN VARCHAR2
			     , p_GroupId     IN NUMBER
			     , p_TemplateId  IN NUMBER
			      )
	AS
		filter_cursor INTEGER := DBMS_SQL.OPEN_CURSOR;
		rows_processed BINARY_INTEGER;
		--sort_order_t sort_order := sort_order();
		ind NUMBER := 0;
		l_sort_order VARCHAR2(2000);
	BEGIN
    --bug: 	4277972, delete sort order table before returning list that meets criteria.
    if sort_order_t.count > 0 then
      sort_order_t.delete;
    end if;

		--
		-- parse the query and get only the sort_orders
		--
		--sort_order_t := sort_order();
		DBMS_SQL.PARSE
		( filter_cursor
		, 'SELECT st_order
		     FROM ( ' || p_filterQuery ||
		  '       ) order by st_order'
		, DBMS_SQL.NATIVE
		);

		--DBMS_SQL.DEFINE_COLUMN(filter_cursor,1,l_sort_order,2000);
		DBMS_SQL.DEFINE_ARRAY(filter_cursor,1,bom_filter.sort_order_t,1000,1);
		/*
		DBMS_SQL.PARSE
		( filter_cursor
		,  'SELECT ST_ORDER sort_order '               ||
		   'BULK COLLECT INTO ' || ':'||G_PARAM_LIST.COUNT+1 ||
		   '  FROM '                                   ||
		   '  ( '                                      ||
		   p_FilterQuery                               ||
		   '   )  '
		, DBMS_SQL.NATIVE
		);
		*/
		--
		-- bind all the parameters and execute
		--
		FOR params IN 1..G_PARAM_LIST.COUNT
		LOOP
			DBMS_SQL.BIND_VARIABLE(filter_cursor, ':'||params,G_PARAM_LIST(params));
		END LOOP;

		--
		-- Execute and fetch all components that match the criteria
		--
		rows_processed := DBMS_SQL.EXECUTE(filter_cursor);
		LOOP
		-- fetch a row
			rows_processed := dbms_sql.fetch_rows(filter_cursor);
    				-- fetch columns from the row
			    dbms_sql.column_value(filter_cursor, 1, bom_filter.sort_order_t);
			EXIT WHEN rows_processed <> 1000;

		END LOOP;
		DBMS_SQL.CLOSE_CURSOR(filter_cursor);
		enableParents;
		applyFilter(bom_filter.sort_order_t, p_GroupId);
		EXCEPTION
			WHEN OTHERS THEN
			  IF (DBMS_SQL.IS_OPEN(filter_cursor))
			  THEN
				DBMS_SQL.CLOSE_CURSOR(filter_cursor);
			  END IF;
			  RAISE;
	END applyFilter;
	/* Procedure Apply filter Ends */

END bom_filter;

/
