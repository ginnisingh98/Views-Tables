--------------------------------------------------------
--  DDL for Package BIS_BIA_DIM_MAP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BIA_DIM_MAP_UTIL" AUTHID CURRENT_USER AS
/*$Header: BISDIMUS.pls 120.1 2006/05/09 13:10:07 aguwalan noship $*/

-- GET_COUNTRIES_BY_AREA is not used by UI/Backend
-- Also its SQL is reported in SQL Performance Repository, hence commenting it
-- FUNCTION GET_COUNTRIES_BY_AREA(p_AREA_CODE VARCHAR2) RETURN VARCHAR2;

PROCEDURE ADD_AREA_COUNTRY_ASSOCIATION (p_area_code VARCHAR2 , p_country_code VARCHAR2) ;
PROCEDURE DEL_AREA_COUNTRY_ASSO(p_area_code VARCHAR2 );
END BIS_BIA_DIM_MAP_UTIL;

 

/
