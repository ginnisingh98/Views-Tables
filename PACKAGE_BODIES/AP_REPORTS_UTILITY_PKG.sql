--------------------------------------------------------
--  DDL for Package Body AP_REPORTS_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_REPORTS_UTILITY_PKG" AS
/* $Header: aprptutb.pls 120.3 2004/10/29 18:54:52 pjena noship $ */

FUNCTION get_period_name(l_invoice_id IN NUMBER) RETURN VARCHAR2
IS
  l_sob_id   NUMBER;
  l_inv_date DATE;
  l_period_name gl_period_statuses.period_name%TYPE := '';
BEGIN
  select set_of_books_id, invoice_date
  into   l_sob_id, l_inv_date
  from   ap_invoices_all
  where  invoice_id = l_invoice_id;

  select period_name
  into   l_period_name
  from   gl_period_statuses
  where  application_id = 200
  and    set_of_books_id = l_sob_id
  and    l_inv_Date between start_date and end_date;

  return(l_period_name);

END get_period_name;


FUNCTION get_check_period_name(l_check_id IN NUMBER) RETURN VARCHAR2
IS
  l_sob_id     NUMBER;
  l_check_date DATE;
  l_period_name gl_period_statuses.period_name%TYPE := '';
BEGIN
  select APS.set_of_books_id, AC.check_date
  into   l_sob_id, l_check_date
  from   ap_checks_all AC, ap_system_parameters_all APS
  where  check_id = l_check_id
  and    AC.org_id = APS.org_id;

  select period_name
  into   l_period_name
  from   gl_period_statuses
  where  application_id = 200
  and    set_of_books_id = l_sob_id
  and    l_check_date between start_date and end_date;

  return(l_period_name);

END get_check_period_name;


END AP_REPORTS_UTILITY_PKG;

/
