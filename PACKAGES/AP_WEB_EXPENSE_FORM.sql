--------------------------------------------------------
--  DDL for Package AP_WEB_EXPENSE_FORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_EXPENSE_FORM" AUTHID CURRENT_USER AS
/* $Header: apwerfms.pls 115.3 2002/11/14 23:04:46 kwidjaja noship $ */

   procedure get_post_query_values(
      p_report_header_id         IN  NUMBER,
      p_distribution_line_number IN  NUMBER,
      p_min_allowed_amount       OUT NOCOPY NUMBER,
      p_violation_string         OUT NOCOPY VARCHAR2,
      p_category_code            OUT NOCOPY VARCHAR2);

   function get_num_violation_lines(
      p_report_header_id         IN NUMBER) RETURN NUMBER;

   function get_num_total_violations(
      p_report_header_id         IN NUMBER) RETURN NUMBER;

   function is_employee_active(
      p_employee_id              IN NUMBER) RETURN VARCHAR2;

   function get_grace_period(
      p_employee_id              IN NUMBER) RETURN VARCHAR2;

end ap_web_expense_form;

 

/
