--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_DYNSQLGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_DYNSQLGEN" AUTHID CURRENT_USER AS
/* $Header: hriopsql.pkh 115.1 2002/12/20 11:35:21 cbridge noship $ */

FUNCTION get_query(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
                   p_ak_region_code   IN VARCHAR2)
                  return varchar2;

FUNCTION get_no_viewby_query(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
                             p_ak_region_code   IN VARCHAR2)
                   return varchar2;

FUNCTION get_drill_into_query(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
                              p_ak_region_code   IN VARCHAR2)
                   return varchar2;

END HRI_OLTP_PMV_DYNSQLGEN;

 

/
