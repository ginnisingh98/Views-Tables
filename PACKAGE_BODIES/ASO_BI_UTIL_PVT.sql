--------------------------------------------------------
--  DDL for Package Body ASO_BI_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_BI_UTIL_PVT" AS
/* $Header: asovbildutlb.pls 120.0 2005/05/31 01:25:46 appldev noship $ */
g_aso_schema VARCHAR2(30):= NULL;
G_TABLE_NOT_EXIST      EXCEPTION;
	PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);

--
-- Initializes g_aso_schema variable
--
PROCEDURE INIT
AS
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);
 l_stmt                VARCHAR2(50);
BEGIN

  -- Find the schema owner and tablespace
  -- ASO_BI_QUOTE_HDRS_ALL is using
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.DEBUG('Getting APP info.');
  END IF;

  IF(FND_INSTALLATION.GET_APP_INFO('ASO', l_status, l_industry, g_aso_schema))
  THEN
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.DEBUG('g_aso_schema is '||g_aso_schema);
  END IF;
  END IF;

END INIT;

--
-- Truncates the tabl, if the table doesnot exists,
-- does nothing
PROCEDURE Truncate_Table(p_table_name IN VARCHAR2)
AS
    l_stmt VARCHAR2(100);
BEGIN
    l_stmt := 'TRUNCATE table '||g_aso_schema||'.'||p_table_name;

    EXECUTE IMMEDIATE l_stmt;
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Truncated table :' || p_table_name);
  END IF;

EXCEPTION
    WHEN G_TABLE_NOT_EXIST THEN
        null;      -- Oracle 942, table does not exist, no actions
    WHEN OTHERS THEN
        RAISE;
END Truncate_Table;

-- Gathers table stats on the table specified
PROCEDURE Analyze_Table(p_table_Name IN VARCHAR2)
AS
 l_table_name Varchar2(40);
 l_status     VARCHAR2(30);
 l_industry   VARCHAR2(30);
BEGIN

     l_table_name := p_table_name;
     IF (g_aso_schema IS NULL) Then
        IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
           BIS_COLLECTION_UTILITIES.DEBUG('Getting APP info.');
        END IF;

        IF(FND_INSTALLATION.GET_APP_INFO('ASO', l_status, l_industry, g_aso_schema)) THEN
          IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
            BIS_COLLECTION_UTILITIES.DEBUG('g_aso_schema is '||g_aso_schema);
          END IF;
        END IF;
     END IF;

     IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
        BIS_COLLECTION_UTILITIES.Debug('Analyzing the table:'||l_table_name);
     END IF;

     fnd_stats.gather_table_stats (ownname=>g_aso_schema,
                                   tabname=>l_table_name);

END Analyze_Table;

-- Wrapper function for parallel enabling the initial load
FUNCTION get_closest_rate_sql (
		x_from_currency   VARCHAR2,
		x_to_currency   VARCHAR2,
		x_conversion_date   DATE,
		x_conversion_type   VARCHAR2,
	  x_max_roll_days   NUMBER ) RETURN NUMBER PARALLEL_ENABLE AS
  rate NUMBER;
BEGIN
    rate := GL_CURRENCY_API.get_closest_rate_sql(x_from_currency, x_to_currency,
                              x_conversion_date, x_conversion_type,
                              x_max_roll_days);
   return rate;
END;


END ASO_BI_UTIL_PVT;

/
