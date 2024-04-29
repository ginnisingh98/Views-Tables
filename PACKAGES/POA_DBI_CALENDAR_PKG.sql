--------------------------------------------------------
--  DDL for Package POA_DBI_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_CALENDAR_PKG" AUTHID CURRENT_USER AS
/* $Header: poadbicals.pls 115.1 2002/09/27 17:25:49 mangupta noship $ */

Function current_report_start_date(as_of_date date,
                              period_type varchar2,
                              comparison_type varchar2) return date;

Function previous_report_start_date(as_of_date date,
                              period_type varchar2,
                              comparison_type varchar2) return date;

Function previous_period_start_date(as_of_date date,
                              period_type varchar2,
                              comparison_type varchar2) return date;

Function current_period_start_date(as_of_date date,
                              period_type varchar2) return date;

Function previous_period_asof_date(as_of_date date,
                                   period_type varchar2,
                                   comparison_type varchar2) return date;
end;


 

/
