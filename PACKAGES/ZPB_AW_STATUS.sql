--------------------------------------------------------
--  DDL for Package ZPB_AW_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_AW_STATUS" AUTHID CURRENT_USER AS
/* $Header: zpb_aw_status.pls 120.0.12010.4 2006/08/03 12:08:09 appldev noship $ */


------------------------------------------------------------------------------
-- GET_STATUS
--
-- Takes a query defined in ZPB_SQL_STATUS and sets the status of the
-- LASTQUERYVS for each dimension defined in that query.  Also sets the
-- LASTQUERYDIMVS structure for all dimensions affected by the query
--
-- IN: p_aw    - The AW the query is defined on
--     p_query - The query name
------------------------------------------------------------------------------
PROCEDURE GET_STATUS (p_aw    IN VARCHAR2,
                      p_query IN VARCHAR2);

------------------------------------------------------------------------------
-- GET__EXCPETION_STATUS
--
-- Takes a query defined in ZPB_SQL_STATUS and sets the status of the
-- LASTQUERYVS for each dimension defined in that query.  Also sets the
-- LASTQUERYDIMVS structure for all dimensions affected by the query
--
-- This query is expected to be defined on the exception table. The instance
-- passed in will modify the SQL to be executed on the current instance view
-- of that instance/BP
--
-- IN: p_aw    - The AW the query is defined on
--     p_query - The query name
------------------------------------------------------------------------------
PROCEDURE GET_EXCEPTION_STATUS (p_user_id  IN VARCHAR2,
                                p_query    IN VARCHAR2,
                                p_instance IN VARCHAR2);

------------------------------------------------------------------------------
-- GET_QUERY_DIMS
--
-- Sets the LastQueryDimVS for the dimensions that are part of the query
------------------------------------------------------------------------------
PROCEDURE GET_QUERY_DIMS (p_aw        IN VARCHAR2,
                          p_query     IN VARCHAR2);

------------------------------------------------------------------------------
-- GET_STATUS_COUNT
--
-- Returns the # of dimension members that are part of a particular query and
-- dimension.  p_dimension is the AW name of the dimension, like CCTR_ORGS
------------------------------------------------------------------------------
FUNCTION GET_STATUS_COUNT (p_aw        IN VARCHAR2,
                           p_query     IN VARCHAR2,
                           p_dimension IN VARCHAR2)
   return NUMBER;

PROCEDURE SET_PERSONAL_ALIAS_FLAG ;
PROCEDURE RESET_PERSONAL_ALIAS_FLAG ;
FUNCTION GET_PERSONAL_ALIAS_FLAG return VARCHAR2 ;

END ZPB_AW_STATUS;

 

/
