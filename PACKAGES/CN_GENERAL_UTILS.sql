--------------------------------------------------------
--  DDL for Package CN_GENERAL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GENERAL_UTILS" AUTHID CURRENT_USER AS
-- $Header: cnsyguts.pls 120.1 2005/08/10 03:46:56 hithanki noship $

/*
Package Name
   cn_general_utils
Purpose
   This package consists of general utilities used throughout commissions.

History
--------------------------------------------------------------------------+
06-SEP-94  P Cook	Created by removing the non-generation specific
                        procedures and functions from cn_utils.
06-DEC-94  P Cook	modified get_salesrep_name to return more info
			and renamed to get_salesrep_info
04-APR-96  A Saxena	Added get_set_of_books_id function and pragma
03-JUN-96  A Saxena	Added get_currency_CODE function and pragma
*/

  FUNCTION get_set_of_books_id RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (GET_SET_OF_BOOKS_ID, WNDS, WNPS, RNPS);

  FUNCTION get_currency(p_org_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_currency_code RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (GET_CURRENCY_CODE, WNDS, WNPS, RNPS);

  PROCEDURE get_period_info ( x_period_date   IN     DATE
			     ,x_period_id     IN OUT NOCOPY NUMBER
			     ,x_period_name   IN OUT NOCOPY VARCHAR2
			     ,x_period_status    OUT NOCOPY VARCHAR2
			     ,x_start_date	 OUT NOCOPY DATE
			     ,x_end_date	 OUT NOCOPY DATE);
  --
  -- Procedure Name
  --   get_meaning
  -- Purpose
  --    Get meaning for given lookup type and code
  -- Arguments
  --    lookup_code	lookup type
  --    lookup_type	lookup code
  --    meaning		translated meaning
  --

  FUNCTION get_meaning(x_lookup_code VARCHAR2,
                       x_lookup_type VARCHAR2) RETURN VARCHAR2;

  --
  -- Procedure Name
  --   get_period_id
  -- Purpose
  --   Get period for given date
  --

  FUNCTION get_period_id(X_period_date DATE) RETURN NUMBER;

  --
  -- Procedure Name
  --   get_period_name
  -- Purpose
  --   Get period name for given period_id
  --

  FUNCTION get_period_name(X_period_id NUMBER) RETURN VARCHAR2;
  --
  -- Procedure Name
  --   Get_Salesrep_info
  -- Purpose
  --   Get Salesrep details given a salesrep id
  --

  PROCEDURE get_salesrep_info(  X_Salesrep_id 	          NUMBER
          		       ,X_Name    	   IN OUT NOCOPY VARCHAR2
			       ,X_employee_number  IN OUT NOCOPY NUMBER);
  --
  -- Procedure Name
  --
  -- Purpose
  --

 FUNCTION get_username (X_userid number) RETURN varchar2;

END cn_general_utils;

 

/
