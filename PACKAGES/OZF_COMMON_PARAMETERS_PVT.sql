--------------------------------------------------------
--  DDL for Package OZF_COMMON_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_COMMON_PARAMETERS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcoms.pls 115.0 2003/10/23 23:09:56 mkothari noship $  */
   VERSION  CONSTANT VARCHAR (80) := '$Header: ozfvcoms.pls 115.0 2003/10/23 23:09:56 mkothari noship $';

-- ------------------------
-- Global Variables
-- ------------------------



-- ------------------------
-- Public functions
-- ------------------------

   FUNCTION GET_PERIOD_SET_NAME
     RETURN VARCHAR2;

   FUNCTION GET_START_DAY_OF_WEEK_ID
     RETURN VARCHAR2;

   FUNCTION GET_PERIOD_TYPE
     RETURN VARCHAR2;

   FUNCTION GET_GLOBAL_START_DATE
     RETURN DATE;

   FUNCTION CHECK_GLOBAL_PARAMETERS(
	 p_parameter_list	IN DBMS_SQL.VARCHAR2_TABLE)
     RETURN boolean;

   FUNCTION GET_DEGREE_OF_PARALLELISM
     RETURN NUMBER;

END ozf_common_parameters_pvt;

 

/
