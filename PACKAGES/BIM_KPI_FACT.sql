--------------------------------------------------------
--  DDL for Package BIM_KPI_FACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_KPI_FACT" AUTHID CURRENT_USER AS
/* $Header: bimkpifs.pls 115.6 2004/03/02 05:15:17 kpadiyar ship $*/

FUNCTION  calculate_days(
   p_start_date             DATE,
   p_end_date               DATE,
   p_aggregate              VARCHAR2 ,
   p_period                 VARCHAR2) return NUMBER;

PROCEDURE  populate
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE                 OUT  NOCOPY NUMBER);

END BIM_KPI_FACT;

 

/
