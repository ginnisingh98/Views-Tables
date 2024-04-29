--------------------------------------------------------
--  DDL for Package OE_BIS_ALERTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BIS_ALERTS" AUTHID CURRENT_USER AS
--$Header: OEXALRTS.pls 115.1 99/08/09 13:40:39 porting shi $

FUNCTION Calculate_Actual
(
  p_set_of_books_id         VARCHAR2,
  p_sales_channel           VARCHAR2,
  p_prod_catg               VARCHAR2,
  p_area                    VARCHAR2,
  p_period_set_Name         VARCHAR2,
  p_time_period             VARCHAR2,
  p_target_level_short_name VARCHAR2
)
RETURN NUMBER;

PROCEDURE Process_Alerts
( p_target_level_short_name    VARCHAR2,
  p_time_period                VARCHAR2
);

PROCEDURE PostActual( target_level_id        in number,
                      org_level_value        in varchar2,
                      time_level_value       in varchar2,
                      dimension1_level_value in varchar2,
                      dimension2_level_value in varchar2,
                      dimension3_level_value in varchar2,
                      actual                 in number,
                      period_set_name        in varchar2);

PROCEDURE oe_strt_wf_process(
       p_exception_message IN varchar2,
       p_subject          IN varchar2,
       p_sob              IN varchar2,
       p_area             IN varchar2,
       p_prod_cat         IN varchar2,
       p_sales_channel    IN varchar2,
       p_period           IN varchar2,
       p_target           IN varchar2,
       p_actual           IN varchar2,
       p_wf_process       IN varchar2,
       p_role             IN varchar2,
       p_resp_id          IN number,
       p_report_name      IN varchar2,
       p_report_param     IN varchar2,
       x_return_status    OUT varchar2);

END OE_BIS_ALERTS;

 

/
