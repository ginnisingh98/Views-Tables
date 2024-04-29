--------------------------------------------------------
--  DDL for Package Body PSP_ENC_CRT_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ENC_CRT_XML" AS
/* $Header: PSPELXLB.pls 120.0.12010000.2 2008/08/05 10:09:36 ubhat ship $ */

function cf_charging_instformula(p_gl_code_combination_id in number,
                                 p_project_id in number,
                                 p_task_id in number,
                                 p_award_id in number,
                                 p_expenditure_organization_id in number,
                                 p_expenditure_type in varchar2) return char is

	v_retcode 		NUMBER;
  	l_chart_of_accts  	VARCHAR2(20);   	gl_flex_values 		VARCHAR2(2000);
	l_project_number	pa_projects_all.segment1%TYPE;
	l_award_number		VARCHAR2(15);
	l_task_number		VARCHAR2(25);
	l_org_name		hr_all_organization_units_tl.name%TYPE;
BEGIN

		IF p_gl_code_combination_id IS NOT NULL
	THEN
		v_retcode := psp_general.find_chart_of_accts(to_number(p_set_of_books_id), l_chart_of_accts);
		gl_flex_values := fnd_flex_ext.get_segs(application_short_name 	=> 'SQLGL',
							key_flex_code   	=> 'GL#',
						        structure_number	=> to_number(l_chart_of_accts),
                					combination_id   	=> p_gl_code_combination_id);
		RETURN(gl_flex_values);
	ELSE
				SELECT segment1
		INTO	 l_project_number
		FROM   pa_projects_all
		WHERE  project_id = p_project_id;

				SELECT task_number
		INTO	 l_task_number
		FROM 	 PA_TASKS
		WHERE    task_id = p_task_id;

		SELECT award_number
		INTO	 l_award_number
		FROM	 gms_awards_all
		WHERE  award_id = p_award_id;

				SELECT name
		INTO	 l_org_name
		FROM	 hr_all_organization_units
		WHERE  organization_id = p_expenditure_organization_id;
		RETURN(l_project_number||','||l_task_number||','||l_award_number
                       ||','||l_org_name||','||p_expenditure_type);
	END IF;

EXCEPTION
	WHEN 	NO_DATA_FOUND
	THEN	RETURN('No Data Found');

	WHEN 	OTHERS
	THEN	RETURN('Other Error');

END;

function CF_currency_codeFormula return Char is
begin


    RETURN( '(' || psp_general.get_currency_code(p_business_group_id)  || ')');

end;

function CF_run_dateFormula return varchar2 is
   l_run_date varchar2(20);
begin
  fnd_profile.get('ICX_DATE_FORMAT_MASK', g_icx_date_mask);
  l_run_date := to_char(sysdate, g_icx_date_mask);
  return (l_run_date);
end;

function initialize_sched_lookups return boolean is
   cursor get_sched_meanings is
   select lookup_code, meaning
     from fnd_lookup_values_vl
    where lookup_type = 'PSP_SCHEDULE_TYPES'
      and enabled_flag = 'Y'
      and sysdate between start_date_active and nvl(end_date_active, fnd_date.canonical_to_date('4000/01/31'));
   l_sched_rec get_sched_meanings%rowtype;
begin
        G_assignment := null;
        G_global_element := null;
        G_org_level  := null;
        G_suspense := null;
        G_org_default := null;
        G_asg_element := null;
        G_asg_ele_group := null;
  open get_sched_meanings;
  loop
    fetch get_sched_meanings into l_sched_rec;
    if get_sched_meanings%notfound then
      close get_sched_meanings;
      exit;
    end if;
    if l_sched_rec.lookup_code = 'A' then
        G_assignment := ''''|| l_sched_rec.meaning || '''';
    elsif l_sched_rec.lookup_code = 'GE' then
        G_global_element := ''''|| l_sched_rec.meaning || '''';
    elsif l_sched_rec.lookup_code = 'DS' then
        G_org_level  := ''''|| l_sched_rec.meaning || '''';
    elsif l_sched_rec.lookup_code = 'SA' then
        G_suspense := ''''|| l_sched_rec.meaning || '''';
    elsif l_sched_rec.lookup_code = 'DA' then
        G_org_default := ''''|| l_sched_rec.meaning || '''';
    elsif l_sched_rec.lookup_code = 'EG' then
        G_asg_ele_group := ''''|| l_sched_rec.meaning || '''';
    elsif l_sched_rec.lookup_code = 'ET' then
        G_asg_element := ''''|| l_sched_rec.meaning || '''';
    end if;
  end loop;
  fnd_profile.get('ICX_DATE_FORMAT_MASK', g_icx_date_mask);
  g_icx_date_mask := ''''|| g_icx_date_mask ||'''';
  return true;
end;

function last_date_earned(p_payroll_id number) return varchar2 is
 l_date_mask varchar2(20);
cursor get_date_Earned is
 select to_char(max(date_earned), l_date_mask)
   from pay_payroll_actions
  where payroll_id = p_payroll_id
    and action_type = 'R'
    and action_status = 'C';
 l_date_earned varchar2(20);
begin
  fnd_profile.get('ICX_DATE_FORMAT_MASK', l_date_mask);
  open get_date_earned;
  fetch get_date_earned into l_date_earned;
  close get_date_earned;
  return l_date_earned;
end;

function cf_p_orig_req_id return number is
   l_orig_req_id number;
   cursor get_orig_req_id is
   select request_id
     from psp_enc_processes
    where payroll_action_id = p_payroll_action_id
      and request_id <> p_request_id
      and process_code in ( 'CEL', 'LET');
 begin
   l_orig_req_id := null;
   open get_orig_req_id;
  fetch get_orig_req_id into l_orig_req_id;
  close get_orig_req_id;
    return nvl(l_orig_req_id, -999);
 end;

END PSP_ENC_CRT_XML ;

/
