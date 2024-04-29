--------------------------------------------------------
--  DDL for Package ARRX_COGS_REP_INNER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_COGS_REP_INNER" AUTHID CURRENT_USER AS
/* $Header: ARRXRCGS.pls 120.1 2005/10/30 04:45:56 appldev noship $ */

PROCEDURE populate_rows (
  p_gl_date_low   	 IN  DATE,
  p_gl_date_high  	 IN  DATE,
  p_sales_order_low      IN  VARCHAR2 DEFAULT NULL,
  p_sales_order_high	 IN  VARCHAR2 DEFAULT NULL,
  p_posted_lines_only	 IN  VARCHAR2 DEFAULT NULL,
  p_unmatched_items_only IN  VARCHAR2 DEFAULT NULL,
  p_user_id 		 IN  NUMBER,
  p_request_id      	 IN  NUMBER,
  x_retcode         	 OUT NOCOPY NUMBER,
  x_errbuf          	 OUT NOCOPY VARCHAR2);


FUNCTION get_cost(
  p_account_class   VARCHAR2,
  p_rec_offset_flag VARCHAR2,
  p_line_id         NUMBER,
  p_base_transaction_value NUMBER) RETURN NUMBER;


PROCEDURE populate_summary (
  p_gl_date_low   	 IN  DATE,
  p_gl_date_high  	 IN  DATE,
  p_chart_of_accounts_id IN  NUMBER,
  p_gl_account_low       IN  VARCHAR2 DEFAULT NULL,
  p_gl_account_high      IN  VARCHAR2 DEFAULT NULL,
  p_posted_lines_only	 IN  VARCHAR2 DEFAULT NULL,
  p_user_id 		 IN  NUMBER,
  p_request_id      	 IN  NUMBER,
  x_retcode         	 OUT NOCOPY NUMBER,
  x_errbuf          	 OUT NOCOPY VARCHAR2);


END arrx_cogs_rep_inner;

 

/
