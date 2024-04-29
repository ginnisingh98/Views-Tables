--------------------------------------------------------
--  DDL for Package AMS_DCF_DEFAULT_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DCF_DEFAULT_VALUES" AUTHID CURRENT_USER AS
/* $Header: amsvdohs.pls 115.8 2002/05/21 10:40:04 pkm ship        $ */

-- FUNCTION
--    get events default aggregate_by
FUNCTION get_events_aggregate(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- FUNCTION
--    get campaigns default aggregate by
FUNCTION get_campaigns_aggregate(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


-- FUNCTION
--    get funds default aggregate by
FUNCTION get_funds_aggregate(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


-- FUNCTION
--    get Events default year
FUNCTION get_events_year(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- FUNCTION
--    get events default quarter
FUNCTION get_events_quarter(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- FUNCTION
--    get campaigns default year
FUNCTION get_campaigns_year(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- FUNCTION
--    get campaigns default quarter
FUNCTION get_campaigns_quarter(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- FUNCTION
--    get funds default year
FUNCTION get_funds_year(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- FUNCTION
--    get funds default quarter
FUNCTION get_funds_quarter(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- FUNCTION
--    get default period
FUNCTION get_default_period (parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- FUNCTION
--    get default period incremental
FUNCTION get_default_period_inc (parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


FUNCTION get_default_quarter(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

FUNCTION get_default_year(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

FUNCTION get_default_period_hom(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


END AMS_DCF_DEFAULT_VALUES;
--show errors;

 

/
