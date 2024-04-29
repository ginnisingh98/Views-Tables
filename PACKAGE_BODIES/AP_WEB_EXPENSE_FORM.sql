--------------------------------------------------------
--  DDL for Package Body AP_WEB_EXPENSE_FORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_EXPENSE_FORM" AS
/* $Header: apwerfmb.pls 120.7 2006/05/18 21:14:19 qle noship $ */

CURSOR violations_cur (p_report_header_id NUMBER, p_line_number NUMBER) IS
  SELECT
       alc.displayed_field
  FROM
       ap_pol_violations apv,
       ap_lookup_codes alc
  WHERE
       apv.violation_type = alc.lookup_code
   AND alc.lookup_type = 'OIE_POL_VIOLATION_TYPES'
   AND apv.report_header_id = p_report_header_id
   AND apv.distribution_line_number = p_line_number
  ORDER BY violation_number;


/* ********************************************************************

   Procedure get_post_query_values:

	Used by APXXXEER.fmb to fetch values in POST-QUERY trigger

   ******************************************************************** */

procedure get_post_query_values(
      p_report_header_id         IN  NUMBER,
      p_distribution_line_number IN  NUMBER,
      p_min_allowed_amount       OUT NOCOPY NUMBER,
      p_violation_string         OUT NOCOPY VARCHAR2,
      p_category_code            OUT NOCOPY VARCHAR2) IS

  l_violation_string VARCHAR2(240);
  l_category_code VARCHAR2(80);

begin

   -- select minimum of the allowable amounts of the policy violation
   -- rows for the current expense report line

   begin

     select min(allowable_amount)
     into p_min_allowed_amount
     from ap_pol_violations_all
     where report_header_id = p_report_header_id
     and   distribution_line_number = p_distribution_line_number;

     exception
       when no_data_found then
         p_min_allowed_amount :=0;
       when others then
         raise;
   end;

   -- select and concatenate the policy violations for the current expense
   -- line; limit result to 240 characters.


   FOR violations_rec IN violations_cur(p_report_header_id, p_distribution_line_number) LOOP
     if (l_violation_string IS NULL) then
       l_violation_string := substr(violations_rec.displayed_field, 1, 240);
     else
       l_violation_string := substr(l_violation_string || ', ' || violations_rec.displayed_field , 1, 240);
     end if;

   END LOOP;

   p_violation_string := l_violation_string;

   begin
     select erp.category_code
     into l_category_code
     from ap_expense_report_params erp,
          ap_expense_report_lines erl
     where erl.report_header_id = p_report_header_id
       and erl.distribution_line_number = p_distribution_line_number
       and erl.web_parameter_id = erp.parameter_id;

     exception
       when no_data_found then
         l_category_code := 'NONE';
       when others then
         raise;
  end;

  p_category_code := l_category_code;

end get_post_query_values;


/* ********************************************************************

   Procedure get_num_violation_lines:

	Used by view ap_expense_report_headers_v for APXXXEER.fmb
        to fetch values for audit functionality

   ******************************************************************** */

function get_num_violation_lines(
      p_report_header_id         IN NUMBER) RETURN NUMBER IS

 l_count NUMBER;

begin

 /* Bug fix 3365438
  * The header level daily sum limit violation is not included in the
  * count. Also changed to look at the _all table since this is used
  * also from audit HTML module, with which the auditor can view
  * reports from different orgs than the one on the responsibility.
  * This can be done since ecen though report_header_id is not
  * a unique key, there can be only one report header id across orgs. */
  select count(*)
  into l_count
  from ap_expense_report_lines_all aerp
  where report_header_id = p_report_header_id
  and (itemization_parent_id is null or itemization_parent_id <> -1)
  and exists (select 1  from ap_pol_violations_all apv
              where apv.report_header_id = p_report_header_id
              and apv.distribution_line_number = aerp.distribution_line_number);

  return l_count;
end;

/* ********************************************************************

   Procedure get_num_total_violations:

	Used by view ap_expense_report_headers_v for APXXXEER.fmb
        to fetch values for audit functionality

   ******************************************************************** */

function get_num_total_violations(
      p_report_header_id         IN NUMBER) RETURN NUMBER IS

 l_count NUMBER;

begin
 /* Bug fix 3365438
  * The header level daily sum limit violation is not included in the
  * count. Also changed to look at the _all table since this is used
  * also from audit HTML module, with which the auditor can view
  * reports from different orgs than the one on the responsibility.
  * This can be done since ecen though report_header_id is not
  * a unique key, there can be only one report header id across orgs. */
  select count(*)
  into l_count
  from ap_pol_violations_all apv
  where apv.report_header_id = p_report_header_id
  and   apv.distribution_line_number<> -1;

  return l_count;
end;

/* ********************************************************************

   Procedure is_employee_active:

	Used by view ap_expense_report_headers_v for APXXXEER.fmb
        to fetch values for audit functionality

   ******************************************************************** */

function is_employee_active(
      p_employee_id              IN NUMBER) RETURN VARCHAR2 IS
  l_employee_is_active VARCHAR2(1);

begin

  begin
    select 'Y'
    into l_employee_is_active
    from per_workforce_current_x	-- Bug 3176205: view name changed from hr_employees_current_v to
    where person_id = p_employee_id;	-- per_workforce_current_x to consider Contingent workers as well.

    exception
      when no_data_found then
        l_employee_is_active := 'N';
      when others then
        raise;
  end;

  return l_employee_is_active;

end is_employee_active;


/* ********************************************************************

   Procedure get_grace_period

       Used by form APXXXEER.fmb to derive grace period
       profile setting for employee who filed report.

   ******************************************************************** */

function get_grace_period(
      p_employee_id              IN NUMBER) RETURN VARCHAR2 IS
  l_defined BOOLEAN;
  l_grace_period VARCHAR2(80);
  l_userid VARCHAR2(80);
begin

  begin
    AP_WEB_OA_MAINFLOW_PKG.GetUserID(p_employee_id, l_userid);
    fnd_profile.get_specific(
                          name_z              => 'AP_WEB_POLICY_GRACE_PERIOD',
                          user_id_z           => to_number(l_userid),
                          responsibility_id_z => NULL,
                          application_id_z    => 200,
                          val_z               => l_grace_period,
                          defined_z           => l_defined);

    return to_number(l_grace_period);

  exception
      when others then
       raise;
  end;

end get_grace_period;


end ap_web_expense_form;

/
