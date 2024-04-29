--------------------------------------------------------
--  DDL for Package POR_CHANGE_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_CHANGE_REQUEST_PKG" AUTHID CURRENT_USER AS
/* $Header: PORRCHOS.pls 120.1.12010000.3 2008/11/25 06:18:49 rojain ship $ */

  FUNCTION is_order_values_differ (reqlineid NUMBER) RETURN VARCHAR2;

  FUNCTION get_changed_req_total(reqheaderid IN NUMBER) RETURN NUMBER;

  FUNCTION get_changed_nonrec_tax_total(reqheaderid IN NUMBER) RETURN NUMBER;

  FUNCTION get_changed_line_total(reqlineid IN NUMBER) RETURN NUMBER;

  FUNCTION get_int_changed_line_total(reqlineid IN NUMBER) RETURN NUMBER;

  FUNCTION get_changed_cur_line_total(reqlineid IN NUMBER) RETURN NUMBER;

  FUNCTION get_chn_line_nonrec_tax_total(reqlineid IN NUMBER) RETURN NUMBER;

  FUNCTION get_changed_line_rec_tax_total(reqlineid IN NUMBER) RETURN NUMBER;

  FUNCTION get_intchnline_nonrectax_total(reqlineid IN NUMBER) RETURN NUMBER;

  FUNCTION get_intchnline_rectax_total(reqlineid IN NUMBER) RETURN NUMBER;


  FUNCTION get_change_hist_overall_status(requestgroupid IN NUMBER, reqlineid NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_multiple_distributions(req_line_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_changed_line_quantity(reqlineid IN NUMBER) RETURN NUMBER;

  FUNCTION get_unit_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_currency_unit_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_cur_line_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_line_qty(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_chng_cur_line_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_changed_line_qty(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_line_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_changed_line_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_line_total(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_changed_line_total(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_price_break_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_price_break_cur_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_price_break_trx_price(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_dist_changed_line_qty(reqheaderid NUMBER, reqlineid NUMBER) RETURN NUMBER;

  FUNCTION get_dist_changed_line_amt(reqheaderid NUMBER, reqlineid NUMBER) RETURN NUMBER;

  FUNCTION get_hist_changed_line_amount(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_line_amount(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_cur_line_total(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_cur_line_amount(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_chng_cur_line_total(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_hist_chng_cur_line_amount(reqlineid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_chng_hist_req_status_notfn(requestgroupid IN NUMBER, reqlineid NUMBER) RETURN VARCHAR2;

  FUNCTION get_hist_cur_dist_amount(reqdistid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

  FUNCTION get_chng_hist_cur_dist_amount(reqdistid IN NUMBER, chgreqgrpid IN NUMBER) RETURN NUMBER;

END por_change_request_pkg;

/
