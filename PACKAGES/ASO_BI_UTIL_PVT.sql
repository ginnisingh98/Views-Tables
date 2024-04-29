--------------------------------------------------------
--  DDL for Package ASO_BI_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_UTIL_PVT" AUTHID CURRENT_USER AS
 /* $Header: asovbildutls.pls 120.0 2005/05/31 01:27:35 appldev noship $ */

 --This is the Initial Procedure to find the schema owner and tablespace

  PROCEDURE INIT;

  --This is used for Truncating Tables

  PROCEDURE Truncate_Table(p_table_name IN VARCHAR2);


  --This is used for Analysing Tables

  Procedure Analyze_Table(p_table_Name IN VARCHAR2);

  --This is a wrapper function for parallel execution

  FUNCTION get_closest_rate_sql (
		x_from_currency   VARCHAR2,
		x_to_currency   VARCHAR2,
		x_conversion_date   DATE,
		x_conversion_type   VARCHAR2 DEFAULT NULL,
	  x_max_roll_days   NUMBER ) RETURN NUMBER PARALLEL_ENABLE;


END ASO_BI_UTIL_PVT;

 

/
