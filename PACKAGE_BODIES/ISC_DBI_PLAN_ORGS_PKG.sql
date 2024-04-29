--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_ORGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_ORGS_PKG" AS
/* $Header: ISCRGALB.pls 115.2 2004/01/30 07:56:20 chu noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_plan			VARCHAR2(10000);
  l_lang			VARCHAR2(10);
  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP
    IF (p_param(i).parameter_name = 'PLAN_SNAPSHOT+PLAN_SNAPSHOT')
      THEN l_plan := p_param(i).parameter_value;
    END IF;
  END LOOP;

  l_lang := USERENV('LANG');

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF (l_plan IS NULL)
    THEN l_stmt := '
SELECT	0	ISC_ATTRIBUTE_1
  FROM	dual
 WHERE	1 = 2 /* PLAN_SNAPSHOT dimension has not been populated */';
    ELSE

  l_stmt := '
SELECT	org.name	ISC_ATTRIBUTE_1 -- Planned Organizations
  FROM	ISC_DBI_PLAN_ORG_SNAPSHOTS	f,
	HR_ALL_ORGANIZATION_UNITS_TL	org
 WHERE	f.organization_id = org.organization_id
   AND	org.language = :ISC_LANG
   AND	f.snapshot_id IN (&PLAN_SNAPSHOT+PLAN_SNAPSHOT)
&ORDER_BY_CLAUSE NULLS LAST';

  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PLAN_ORGS_PKG ;


/
