--------------------------------------------------------
--  DDL for Package Body BIS_PARAMETER_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PARAMETER_VALIDATION" AS
/* $Header: BISPARMB.pls 120.2 2006/03/28 10:42:14 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.97=120.2):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_PARAMETER_VALIDATE                                  --
--                                                                        --
--  DESCRIPTION:  This package contains all the procedures used to        --
--                validate the Report Generator parameters.               --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  03/28/06   nbarik	  This package is a candidate for stubbing        --
--                        but since there are dependencies keeping it now --
----------------------------------------------------------------------------
/*
	nbarik - 03/27/06 - Bug Fix 4941893
	This package shouldn't be used for new code.
	This is not stubbed yet because of there are some dependencies.
	If there is any change required to this package, then chage it in
	appropriate places and remove it from here.
*/
FUNCTION getTimeLovSql (p_dimn_level_short_name IN VARCHAR2,
                        p_dimn_level_value      IN VARCHAR2,
                        p_sql_type              IN VARCHAR2 DEFAULT NULL,
                        p_region_code           IN VARCHAR2,
                        pResponsibilityId       IN VARCHAR2,
                        pOrgParam               IN VARCHAR2,
                        pOrgValue               IN VARCHAR2) RETURN VARCHAR2
IS

   l_sql_statement		VARCHAR2(3000);
   l_bind_sql			VARCHAR2(3000);
   l_bind_variables     VARCHAR2(3000);
   l_bind_count         NUMBER;
   l_return_status 		VARCHAR2(2000);
   l_msg_count 			NUMBER;
   l_msg_data 			VARCHAR2(2000);

BEGIN
	BIS_PMV_PARAMETERS_PVT.getTimeLovSql (
		p_parameter_name => p_dimn_level_short_name
	,	p_parameter_description => p_dimn_level_value
	,	p_sql_type => p_sql_type
	,	p_date => NULL
	,	p_region_code => p_region_code
	, 	p_responsibility_id => pResponsibilityId
	,	p_org_name => pOrgParam
	,	p_org_value => pOrgValue
	,	x_sql_statement => l_sql_statement
	,	x_bind_sql => l_bind_sql
	,	x_bind_variables => l_bind_variables
	,	x_bind_count => l_bind_count
	,	x_return_status => l_return_status
	,	x_msg_count => l_msg_count
	,	x_msg_data => l_msg_data
	);

	RETURN l_sql_statement;

EXCEPTION
	WHEN OTHERS THEN
		NULL;
END getTimeLovSql;

PROCEDURE drillAcross(	pUrlString IN VARCHAR2
    		,	pUserId  IN VARCHAR2 DEFAULT NULL
    		, 	pRespId  IN VARCHAR2 DEFAULT NULL
    		, 	pSessionId IN VARCHAR2 DEFAULT NULL
    		, 	pFunctionName IN VARCHAR2 DEFAULT NULL
	)
IS
BEGIN
  BISVIEWER_PUB.showReport(
 		pUrlString
 	,	pUserId
 	, 	pRespId
 	,	pSessionId
 	,	pFunctionName
 );
END drillacross;

FUNCTION  getHierarchyElementId (
			pElementShortName IN VARCHAR2
		,	pDimensionShortName IN VARCHAR2
		)
	RETURN VARCHAR2
IS
    vElementId NUMBER;
BEGIN
	vElementId := BIS_PMV_UTIL.getHierarchyElementId (
					pElementShortName
				,	pDimensionShortName
				);
	RETURN vElementId;
EXCEPTION
	WHEN OTHERS THEN
    	RETURN 0;
END getHierarchyElementId;

FUNCTION getDimensionForAttribute (
			pAttributecode IN VARCHAR2
		,	pRegionCode    IN VARCHAR2
		)
RETURN VARCHAR2
IS
  l_attribute2 VARCHAR2(100);
BEGIN
	l_attribute2 := BIS_PMV_UTIL.getDimensionForAttribute (
						pAttributecode
					,	pRegionCode
					);
  RETURN l_attribute2;
EXCEPTION
  WHEN OTHERS THEN
  	NULL;
END getDimensionForAttribute;

END BIS_PARAMETER_VALIDATION;

/
