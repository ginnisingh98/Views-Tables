--------------------------------------------------------
--  DDL for Package BSC_DIMENSION_KEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIMENSION_KEYS_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCDKEYS.pls 120.0 2005/09/15 23:39 appldev noship $ */
reporting_keys_exception EXCEPTION;
TYPE TimePeriod is record (
start_period number,
start_year number,
end_period number,
end_year number);
TYPE TabTimePeriods is table of TimePeriod index by BINARY_INTEGER;

Procedure initialize_query (
p_kpi varchar2,
p_dim_set varchar2,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL,
p_option_string varchar2,
p_error_message out nocopy varchar2
);
END BSC_DIMENSION_KEYS_PKG;

 

/
