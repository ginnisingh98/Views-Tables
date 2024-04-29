--------------------------------------------------------
--  DDL for Package HR_PASSED_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PASSED_SQL" AUTHID CURRENT_USER AS
/* $Header: hrpsdsql.pkh 120.1.12010000.1 2008/07/28 03:42:12 appldev ship $ */
--
--------------------------------------------------------------------------------
--  FUNCTION:         GET_PASSED_SQL_ID                                       --
--                                                                            --
--  DESCRIPTION:      Inserts Query into Parameters tables, and a             --
--                    session date.                                           --
--                                                                            --
--  PARAMETERS:       WHERE clause - query to be executed by HR SQL Control   --
--                    Session Date - date to be used by HR SQL Control        --
--			                                                      --
--			   	 	   	 	                      --
--		 							      --
--  RETURN: 	         parameter list id.                                   --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  10-JUL-02  smcmilla  CREATED                                              --
--------------------------------------------------------------------------------
--
--
FUNCTION GET_PASSED_SQL_ID(p_where_clause   in VARCHAR2
                          ,p_session_date   in VARCHAR2
                          ,p_form_name      in VARCHAR2 default null) RETURN VARCHAR2;

END HR_PASSED_SQL;

/
