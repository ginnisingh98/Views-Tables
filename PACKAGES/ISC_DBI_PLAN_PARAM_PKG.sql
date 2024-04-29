--------------------------------------------------------
--  DDL for Package ISC_DBI_PLAN_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_PLAN_PARAM_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCRGAGS.pls 115.0 2003/07/25 01:02:01 chu noship $ */

FUNCTION get_plan RETURN NUMBER;

FUNCTION get_plan_currency RETURN VARCHAR2;

FUNCTION get_plan_period RETURN NUMBER;

FUNCTION a RETURN DATE;

FUNCTION b RETURN DATE;

FUNCTION get_page_params RETURN VARCHAR2;


END ISC_DBI_PLAN_PARAM_PKG;


 

/
