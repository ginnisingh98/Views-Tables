--------------------------------------------------------
--  DDL for Package BIS_PARAMETER_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PARAMETER_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: BISPARMS.pls 120.1 2006/03/28 10:39:19 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls+5 \
-- dbdrv: checkfile(115.22=120.1):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_PARAMETER_VALIDATE                                  --
--                                                                        --
--  DESCRIPTION:  This package contains all the procedures used to        --
--                validate the Report Generator parameters.               --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  03/28/06   nbarik	  This package is a candidate for stubbing        --
--                        but since there are dependencies keeping it now --
----------------------------------------------------------------------------
  FUNCTION getTimeLovSql (p_dimn_level_short_name IN VARCHAR2,
                          p_dimn_level_value	  IN VARCHAR2,
                          p_sql_type		  	  IN VARCHAR2 DEFAULT NULL,
                          p_region_code           IN VARCHAR2,
                          pResponsibilityId       IN VARCHAR2,
                          pOrgParam               IN VARCHAR2,
                          pOrgValue               IN VARCHAR2) RETURN VARCHAR2;


  PROCEDURE drillAcross(pUrlString        IN VARCHAR2,
                        pUserId           IN VARCHAR2 DEFAULT NULL,
                        pRespId           IN VARCHAR2 DEFAULT NULL,
                        pSessionId        IN VARCHAR2 DEFAULT NULL,
                        pFunctionName     IN VARCHAR2 DEFAULT NULL
                       );

  FUNCTION getHierarchyElementId
                          (pElementShortName IN VARCHAR2,
                           pDimensionShortNAme IN VARCHAR2)
                           RETURN VARCHAR2;

  FUNCTION getDimensionForAttribute
                         (pAttributeCode IN VARCHAR2,
                          pRegionCode    IN VARCHAR2)
                          RETURN VARCHAR2;

END BIS_PARAMETER_VALIDATION;

 

/
