--------------------------------------------------------
--  DDL for Package Body PER_PERRPFP3_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPFP3_XMLP_PKG" AS
/* $Header: PERRPFP3B.pls 120.3 2008/05/15 09:13:09 amakrish noship $ */
function BeforeReport return boolean is
l_commit number;
begin
P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
c_end_of_time := hr_general.end_of_time;

declare
	v_name varchar2(350);
        v_title varchar2(400);
        v_label_expr varchar2(32000);
        v_column_expr varchar2(32000);
	v_legislation_code varchar2(30);
begin


 /* hr_standard.event('BEFORE REPORT'); */


dt_fndate.change_ses_date(p_ses_date => trunc(p_session_date),
                          p_commit   => l_commit);



 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

  select  peo.first_name ||
	  decode(peo.first_name,null,null,' ') ||
          peo.last_name
  into    v_name
  from    per_all_people_f peo
  where  peo.person_id = p_person_id
  and p_session_date between peo.effective_start_date
                       and     peo.effective_end_date;
  c_header_name := v_name;


  select org_information10
  into c_currency_code
  from hr_organization_information
  where organization_id = p_business_group_id
  and org_information_context = 'Business Group Information';

/*srw.message('101','ts1');*/null;

 hr_reports.get_desc_flex_context('PER','PER_ASSIGNMENT_STATUSES',
      'sst',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_sec_ass_df_details := v_column_expr;
        c_sec_ass_df_label   :=  v_label_expr;
   else
	c_sec_ass_df_details := 'sst.attribute1';
   end if;


/*srw.message('102','t2');*/null;

 hr_reports.get_desc_flex_context('PER','PER_EVENTS',
      'a',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_inter_df_details := v_column_expr;
        c_inter_df_label   :=  v_label_expr;
   else
	c_inter_df_details := 'a.attribute1';
   end if;


/*srw.message('103','t6');*/null;

 hr_reports.get_desc_flex_context('PER','PER_ASSIGNMENTS',
      'asg',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_ass_df_details := v_column_expr;
        c_ass_df_label   :=  v_label_expr;
   else
	c_ass_df_details := 'as'||'g.ass_attribute1';
   end if;



 hr_reports.get_desc_flex_context('PER','PER_PERIODS_OF_SERVICE',
      'a',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_per_serv_df_details := v_column_expr;
        c_per_serv_df_label   :=  v_label_expr;
   else
	c_per_serv_df_details := 'a.attribute1';
   end if;
/*srw.message('103','t4');*/null;

 hr_reports.get_desc_flex_context('PER','PER_ASSIGNMENT_EXTRA_INFO',
      'f',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_fur_info_df_details := v_column_expr;
        c_fur_info_df_label   :=  v_label_expr;
   else
	c_fur_info_df_details := 'f.aei_attribute1';
   end if;
/*srw.message('001','msg1');*/null;

 hr_reports.get_desc_flex_context('PER','Assignment Developer DF',
      'f',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_fur_info_ddf_details := v_column_expr;
        c_fur_info_ddf_label   :=  v_label_expr;
   else
	c_fur_info_df_details := 'f.aei_information1';
   end if;
/*srw.message('002','msg2');*/null;

 hr_reports.get_desc_flex_context('PAY','PAY_PERSONAL_PAYMENT_METHODS',
      'ppm',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_ppm_df_details := v_column_expr;
        c_ppm_df_label   :=  v_label_expr;
   else
	c_ppm_df_details := 'ppm.attribute1';
   end if;

 hr_reports.get_desc_flex_context('PAY','PAY_ELEMENT_ENTRIES',
      'ee',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_ele_df_details :=  v_column_expr;
        c_ele_df_label   :=  v_label_expr;
   else
	c_ele_df_details := 'ee.attribute1';
   end if;



    select  PBG.LEGISLATION_CODE
    into    v_legislation_code
    from     PER_BUSINESS_GROUPS PBG
    where    PBG.BUSINESS_GROUP_ID = p_business_group_id;

	declare
		v_id_flex_num	number;
	begin
		select PBG.COST_ALLOCATION_STRUCTURE
                into   v_id_flex_num
                from   PER_BUSINESS_GROUPS PBG
                where PBG.BUSINESS_GROUP_ID = p_business_group_id;
		if v_id_flex_num is not null then
		  c_cost_id_flex_num := v_id_flex_num;

 null;
		end if;
	exception
		when others then null;
	end;
	declare
		v_id_flex_num	number;
	begin
		select rule_mode
		into   v_id_flex_num
		from   pay_legislation_rules
		where  legislation_code = v_legislation_code
		and    rule_type        = 'S'
		and    exists
      			(select null
       			from   FND_SEGMENT_ATTRIBUTE_VALUES
       			where  ID_FLEX_NUM = rule_mode
       			and    APPLICATION_ID = 800
       			and    ID_FLEX_CODE = 'SCL'
       			and    SEGMENT_ATTRIBUTE_TYPE = 'ASSIGNMENT'
       			and    ATTRIBUTE_VALUE = 'Y');

		c_scl_id_flex_num := v_id_flex_num;

 null;
	exception
		when others then null;
	end;

end;
  return (TRUE);
end;

function c_get_fur_info_flexformula(information_type in varchar2) return number is
begin

declare
        v_title varchar2(600);
        v_label_expr varchar2(600);
        v_column_expr varchar2(2000);
begin
hr_reports.get_dvlpr_desc_flex('PER','Assignment Developer DF',
information_type,'paei',v_title,v_label_expr,v_column_expr);
c_fur_info_ddf_details := v_column_expr;
c_fur_info_ddf_label := ''''||v_label_expr||'''';
return('');
end;

RETURN NULL; end;

function C_scl_segsFormula return Number is
begin

begin

return(0);
end;

RETURN NULL; end;

function c_get_ext_acctformula(category in varchar2, territory_code in varchar2) return character is
begin

declare
	v_id_flex_num number;
begin
if category = 'MT' and territory_code is not null then
	begin
		select TO_NUMBER(l.rule_mode)
		into   v_id_flex_num
		from   pay_legislation_rules l
		where  l.legislation_code = territory_code
		and    l.rule_type = 'E';
                c_ext_acct_id := v_id_flex_num;

 null;
	exception
		when others then null;
        end;

end if;
return('');
end;
RETURN NULL; end;

function AfterReport return boolean is
begin

 /* hr_standard.event('AFTER REPORT'); */

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_ext_acct_id_p return number is
	Begin
	 return C_ext_acct_id;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_details_p return varchar2 is
	Begin
	 return C_details;
	 END;
 Function C_cont_details_p return varchar2 is
	Begin
	 return C_cont_details;
	 END;
 Function C_requirement_desc_p return varchar2 is
	Begin
	 return C_requirement_desc;
	 END;
 Function C_requirement_value_p return varchar2 is
	Begin
	 return C_requirement_value;
	 END;
 Function C_header_name_p return varchar2 is
	Begin
	 return C_header_name;
	 END;
 Function C_pay_meth_count_p return number is
	Begin
	 return C_pay_meth_count;
	 END;
 Function C_emp_df_details_p return varchar2 is
	Begin
	 return C_emp_df_details;
	 END;
 Function C_emp_leg_df_details_p return varchar2 is
	Begin
	 return C_emp_leg_df_details;
	 END;
 Function C_add_df_details_p return varchar2 is
	Begin
	 return C_add_df_details;
	 END;
 Function C_cont_df_details_p return varchar2 is
	Begin
	 return C_cont_df_details;
	 END;
 Function C_app_df_details_p return varchar2 is
	Begin
	 return C_app_df_details;
	 END;
 Function c_app_ass_df_details_p return varchar2 is
	Begin
	 return c_app_ass_df_details;
	 END;
 Function C_sec_ass_df_details_p return varchar2 is
	Begin
	 return C_sec_ass_df_details;
	 END;
 Function C_per_serv_df_details_p return varchar2 is
	Begin
	 return C_per_serv_df_details;
	 END;
 Function C_temp_p return varchar2 is
	Begin
	 return C_temp;
	 END;
 Function C_add_df_label_p return varchar2 is
	Begin
	 return C_add_df_label;
	 END;
 Function C_emp_df_label_p return varchar2 is
	Begin
	 return C_emp_df_label;
	 END;
 Function C_emp_leg_df_label_p return varchar2 is
	Begin
	 return C_emp_leg_df_label;
	 END;
 Function C_cont_df_label_p return varchar2 is
	Begin
	 return C_cont_df_label;
	 END;
 Function C_app_df_label_p return varchar2 is
	Begin
	 return C_app_df_label;
	 END;
 Function C_app_ass_df_label_p return varchar2 is
	Begin
	 return C_app_ass_df_label;
	 END;
 Function C_app_sec_status_details_p return varchar2 is
	Begin
	 return C_app_sec_status_details;
	 END;
 Function C_app_sec_status_label_p return varchar2 is
	Begin
	 return C_app_sec_status_label;
	 END;
 Function C_inter_df_details_p return varchar2 is
	Begin
	 return C_inter_df_details;
	 END;
 Function C_inter_df_label_p return varchar2 is
	Begin
	 return C_inter_df_label;
	 END;
 Function C_sec_ass_df_label_p return varchar2 is
	Begin
	 return C_sec_ass_df_label;
	 END;
 Function C_ass_df_details_p return varchar2 is
	Begin
	 return C_ass_df_details;
	 END;
 Function C_ass_df_label_p return varchar2 is
	Begin
	 return C_ass_df_label;
	 END;
 Function C_fur_info_df_details_p return varchar2 is
	Begin
	 return C_fur_info_df_details;
	 END;
 Function C_fur_info_df_label_p return varchar2 is
	Begin
	 return C_fur_info_df_label;
	 END;
 Function C_fur_info_ddf_details_p return varchar2 is
	Begin
	 return C_fur_info_ddf_details;
	 END;
 Function C_fur_info_ddf_label_p return varchar2 is
	Begin
	 return C_fur_info_ddf_label;
	 END;
 Function C_cost_id_flex_num_p return number is
	Begin
	 return C_cost_id_flex_num;
	 END;
 Function C_scl_id_flex_num_p return number is
	Begin
	 return C_scl_id_flex_num;
	 END;
 Function C_scl_desc_p return varchar2 is
	Begin
	 return C_scl_desc;
	 END;
 Function C_scl_value_p return varchar2 is
	Begin
	 return C_scl_value;
	 END;
 Function C_cost_desc_p return varchar2 is
	Begin
	 return C_cost_desc;
	 END;
 Function C_cost_values_p return varchar2 is
	Begin
	 return C_cost_values;
	 END;
 Function C_ppm_df_details_p return varchar2 is
	Begin
	 return C_ppm_df_details;
	 END;
 Function C_ppm_df_label_p return varchar2 is
	Begin
	 return C_ppm_df_label;
	 END;
 Function C_ext_act_desc_p return varchar2 is
	Begin
	 return C_ext_act_desc;
	 END;
 Function C_ext_act_values_p return varchar2 is
	Begin
	 return C_ext_act_values;
	 END;
 Function C_ele_df_details_p return varchar2 is
	Begin
	 return C_ele_df_details;
	 END;
 Function C_ele_df_label_p return varchar2 is
	Begin
	 return C_ele_df_label;
	 END;
 Function C_ele_cost_desc_p return varchar2 is
	Begin
	 return C_ele_cost_desc;
	 END;
 Function C_ele_cost_values_p return varchar2 is
	Begin
	 return C_ele_cost_values;
	 END;
 Function C_event_df_details_p return varchar2 is
	Begin
	 return C_event_df_details;
	 END;
 Function C_event_df_label_p return varchar2 is
	Begin
	 return C_event_df_label;
	 END;
 Function C_book_df_details_p return varchar2 is
	Begin
	 return C_book_df_details;
	 END;
 Function C_book_df_label_p return varchar2 is
	Begin
	 return C_book_df_label;
	 END;
 Function C_special_df_details_p return varchar2 is
	Begin
	 return C_special_df_details;
	 END;
 Function C_special_df_label_p return varchar2 is
	Begin
	 return C_special_df_label;
	 END;
 Function C_per_serv_df_label_p return varchar2 is
	Begin
	 return C_per_serv_df_label;
	 END;
 Function C_absence_df_details_p return varchar2 is
	Begin
	 return C_absence_df_details;
	 END;
 Function C_absence_df_label_p return varchar2 is
	Begin
	 return C_absence_df_label;
	 END;
 Function C_subtitle_p return varchar2 is
	Begin
	 return C_subtitle;
	 END;
 Function C_END_OF_TIME_p return date is
	Begin
	 return C_END_OF_TIME;
	 END;
 Function C_currency_code_p return varchar2 is
	Begin
	 return C_currency_code;
	 END;
function M_1FormatTrigger return number is
v_detailcount number(10);
begin
  select count(*)
  into v_detailcount
  from per_periods_of_service pps,
       per_all_people_f peo
where pps.person_id = p_person_id
and   pps.business_group_id = p_business_group_id
and   pps.termination_accepted_person_id = peo.person_id(+)
and   pps.actual_termination_date between peo.effective_start_date(+)
      and peo.effective_end_date(+);
return v_detailcount;
end;

function M_5FormatTrigger return number is
  v_detailcount number(10);
begin
  select count(*)
  into v_detailcount
  from per_all_assignments_f asg,
       per_all_people_f peo
where  asg.supervisor_id = peo.person_id(+)
and    asg.effective_start_date between peo.effective_start_date(+)
                           and peo.effective_end_date(+)
and    asg.business_group_id = p_business_group_id
and    asg.person_id = p_person_id;
return v_detailcount;
end;

function M_6FormatTrigger return number is
 v_detailcount number(10);
begin
select count(*)
  into v_detailcount
  from per_secondary_ass_statuses ast,
       per_all_assignments_f pa
where ast.assignment_id = pa.assignment_id
and   pa.person_id = p_person_id
and   pa.business_group_id = p_business_group_id;

return v_detailcount;
end;

function M_8FormatTrigger return number is
  v_detailcount number(10);
begin

select count(*)
  into v_detailcount
  from per_spinal_point_placements_f pssp,
       per_all_assignments_f pa
where pssp.assignment_id = pa.assignment_id
and   pa.person_id = p_person_id
and   pa.business_group_id = p_business_group_id;
return v_detailcount;
end;

END PER_PERRPFP3_XMLP_PKG ;

/
