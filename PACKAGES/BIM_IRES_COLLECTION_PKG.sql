--------------------------------------------------------
--  DDL for Package BIM_IRES_COLLECTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_IRES_COLLECTION_PKG" AUTHID CURRENT_USER AS
/* $Header: bimiress.pls 115.1 2002/04/29 10:21:25 pkm ship        $*/
FUNCTION  calculate_days(
    p_start_date         DATE
   ,p_end_date           DATE
   ,p_aggregate          VARCHAR2
   ,p_period             VARCHAR2) return NUMBER;
FUNCTION  calculate_days(  --overloaded function
    p_start_date              DATE
   ,p_end_date                DATE
   ,p_aggregate               VARCHAR2
   ,p_period                  VARCHAR2
   ,p_date                    DATE
   ,p_cur_period_start_date   DATE
   ,p_cur_period_end_date     DATE
   ,p_prev_period_start_date  DATE
   ,p_prev_period_end_date    DATE) return NUMBER;
FUNCTION get_min_date return DATE;
END BIM_IRES_COLLECTION_PKG;

 

/
