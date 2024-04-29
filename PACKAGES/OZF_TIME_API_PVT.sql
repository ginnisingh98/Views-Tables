--------------------------------------------------------
--  DDL for Package OZF_TIME_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TIME_API_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvtias.pls 115.2 2004/03/10 01:43:54 mkothari noship $*/

 TYPE G_PERIOD_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

 FUNCTION get_period_start_date(p_time_id         number,
                                p_period_type_id  number) RETURN DATE;

 FUNCTION get_period_end_date(p_time_id         number,
                              p_period_type_id  number) RETURN DATE;

 FUNCTION get_period_name(p_time_id         number,
                          p_period_type_id  number) RETURN VARCHAR2;

 FUNCTION get_lysp_period_name(p_time_id         number,
                               p_period_type_id  number) RETURN VARCHAR2;

 FUNCTION GET_LYSP_ID(p_time_id        number,
                      p_period_type_id number) RETURN NUMBER;

 FUNCTION GET_PERIOD_TBL(p_start_date     varchar2,
                         p_end_date       varchar2,
                         p_period_type_id number) RETURN G_PERIOD_TBL_TYPE;

 FUNCTION Is_Quarter_Allowed(p_start_date     DATE,
                             p_end_date       DATE) RETURN CHAR;

 FUNCTION Is_Period_Range_Valid (p_start_date     DATE,
                                 p_end_date       DATE) RETURN CHAR;

END OZF_TIME_API_PVT;

 

/
