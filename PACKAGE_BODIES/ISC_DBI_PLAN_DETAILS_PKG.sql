--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_DETAILS_PKG" AS
/* $Header: ISCRGAKB.pls 115.2 2004/01/30 07:56:09 chu noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_plan			VARCHAR2(10000);
  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP
    IF (p_param(i).parameter_name = 'PLAN_SNAPSHOT+PLAN_SNAPSHOT')
      THEN l_plan := p_param(i).parameter_value;
    END IF;
  END LOOP;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF (l_plan IS NULL)
    THEN l_stmt := '
SELECT	0	ISC_ATTRIBUTE_1,
	0	ISC_ATTRIBUTE_2,
	0	ISC_ATTRIBUTE_3,
	0	ISC_ATTRIBUTE_4,
	0 	ISC_ATTRIBUTE_5,
	0	ISC_ATTRIBUTE_6,
	0 	ISC_MEASURE_1,
	0	ISC_MEASURE_2
  FROM	dual
 WHERE	1 = 2 /* PLAN_SNAPSHOT dimension has not been populated */';
    ELSE

  l_stmt := '
SELECT	f.compile_designator		ISC_ATTRIBUTE_1, -- Plan name
	f.description			ISC_ATTRIBUTE_2, -- Plan Description
	to_char(f.data_start_date)
	   ||'' - ''
	   || to_char(f.cutoff_date)	ISC_ATTRIBUTE_3, -- Plan Horizon
	lkup.meaning			ISC_ATTRIBUTE_4, -- Plan Type
	f.data_start_date		ISC_ATTRIBUTE_5, -- Run Date
	f.snapshot_date			ISC_ATTRIBUTE_6, -- Snapshot Date
	f.org_cnt			ISC_MEASURE_1, -- Planned Organizations
	f.snapshot_id			ISC_MEASURE_2 -- Snapshot ID
  FROM	ISC_DBI_PLAN_SNAPSHOTS	f,
	MFG_LOOKUPS		lkup
 WHERE 	lkup.lookup_type = ''MSC_PLAN_TYPE_LONG''
   AND	lkup.lookup_code = f.curr_plan_type
   AND	enabled_flag = ''Y''
   AND	f.snapshot_id IN (&PLAN_SNAPSHOT+PLAN_SNAPSHOT)
&ORDER_BY_CLAUSE NULLS LAST';

END IF;

  x_custom_sql := l_stmt;


END Get_Sql;

END ISC_DBI_PLAN_DETAILS_PKG ;


/
