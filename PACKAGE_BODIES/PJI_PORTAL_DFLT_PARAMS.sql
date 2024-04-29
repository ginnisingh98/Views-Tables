--------------------------------------------------------
--  DDL for Package Body PJI_PORTAL_DFLT_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PORTAL_DFLT_PARAMS" AS
/* $Header: PJIRX06B.pls 120.1 2005/12/22 14:36:34 appldev noship $ */

FUNCTION get_dbi_params (p_Report_Type VARCHAR2 DEFAULT 'FM' ) RETURN VARCHAR2 IS
l_Org_ID           VARCHAR2(30);
l_Ent_Quarter_ID_Value NUMBER;

BEGIN
   l_Org_ID:=PJI_PMV_DFLT_PARAMS_PVT.Derive_Organization_ID;
   l_Ent_Quarter_ID_Value:=PJI_PMV_DFLT_PARAMS_PVT.Derive_Ent_Quarter_ID_Value;

   IF p_Report_Type = 'FM' THEN
      RETURN
                 '&'||'YEARLY=TIME_COMPARISON_TYPE+YEARLY'||
                 '&'||'PJI_REP_DIM_2='||l_Org_ID||
                 '&'||'TIME+FII_TIME_ENT_QTR_FROM='||TO_CHAR(l_Ent_Quarter_ID_Value)||
                 '&'||'PJI_REP_DIM_27=FII_GLOBAL1';
   ELSE
      RETURN
                 '&'||'YEARLY=TIME_COMPARISON_TYPE+YEARLY'||
                 '&'||'PJI_REP_DIM_2='||l_Org_ID||
                 '&'||'TIME+FII_TIME_ENT_QTR_FROM='||TO_CHAR(l_Ent_Quarter_ID_Value);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
        RAISE ;
END get_dbi_params;

FUNCTION get_dbi_organization RETURN VARCHAR2 IS
l_Org_ID           VARCHAR2(30);

BEGIN
   l_Org_ID:=PJI_PMV_DFLT_PARAMS_PVT.Derive_Organization_ID;
     RETURN l_Org_ID;
EXCEPTION
   WHEN OTHERS THEN
        RAISE ;

END get_dbi_organization;


-- *****************************************
--  Package Initialization Code
-- *****************************************
BEGIN
	PJI_PMV_DFLT_PARAMS_PVT.InitEnvironment;
EXCEPTION
	WHEN OTHERS THEN
		RAISE;
END PJI_PORTAL_DFLT_PARAMS;

/
