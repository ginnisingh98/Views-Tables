--------------------------------------------------------
--  DDL for Package Body ASO_BI_QOT_PMV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_BI_QOT_PMV_PVT" AS
/* $Header: asovbiqpmvb.pls 115.38 2003/10/23 07:43:55 krsundar noship $*/


-- This will return the SQL Query for Current/Previous VALUES,
-- COUNT of the OPEN QUOTES based on As OF DATE.
PROCEDURE GET_OPEN_QUOTE_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           )
IS
BEGIN

NULL;

END GET_OPEN_QUOTE_SQL;


-- The query returns Open Quotes and Converted Quotes values for different
-- Resource Groups, Direct Resource-Ids and for different XTD and
-- Comparision types.
PROCEDURE GET_QUOTE_CONVERSION_sql(
                              p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                              x_custom_sql     OUT NOCOPY VARCHAR2,
                              x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                              )
IS
BEGIN

NULL;

END GET_QUOTE_CONVERSION_SQL;


-- Returns query which aggregates the values across Time and Sales Group
-- Dimensions tot_conv_value
PROCEDURE GET_NEW_CONV_QUOTE_SQL(
                              p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                              x_custom_sql     OUT NOCOPY VARCHAR2,
                              x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                              )
IS
BEGIN

NULL;

END GET_NEW_CONV_QUOTE_SQL;

-- This will return SQL Query for the Current/Previous VALUES of the
-- OPEN QUOTES
PROCEDURE GET_OPEN_QUOTE_GRAPH_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql  OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
BEGIN

NULL;

END GET_OPEN_QUOTE_GRAPH_SQL ;

-- Returns query which aggregates the values for Converted/New Quotes
-- across Time and Sales Group Dimensions
PROCEDURE GET_QUOTE_TO_ORDER_GRAPH_SQL(
                        p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_TBL,
                        x_custom_sql  OUT NOCOPY VARCHAR2,
                        x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                                      )
IS
BEGIN

NULL;

END GET_QUOTE_TO_ORDER_GRAPH_SQL;

END ASO_BI_QOT_PMV_PVT;

/
