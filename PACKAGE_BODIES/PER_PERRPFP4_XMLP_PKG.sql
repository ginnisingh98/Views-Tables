--------------------------------------------------------
--  DDL for Package Body PER_PERRPFP4_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPFP4_XMLP_PKG" AS
/* $Header: PERRPFP4B.pls 120.1 2007/12/06 11:29:23 amakrish noship $ */
function BeforeReport return boolean is
l_date_format varchar2(20):='DD-MON-YYYY';
begin
P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
--c_end_of_time := hr_general.end_of_time;
c_end_of_time :=to_char(to_date(hr_general.end_of_time,l_date_format),'YYYY-MM-DD');
declare
	v_name varchar2(382);
        v_title varchar2(400);
        v_label_expr varchar2(32000);
        v_column_expr varchar2(32000);
	v_legislation_code varchar2(30);
begin


/*srw.message('001','start');*/null;

--hr_standard.event('BEFORE REPORT');

 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

/*srw.message('002','bg');*/null;

  select  peo.first_name ||
	  decode(peo.first_name,null,null,' ') ||
          peo.last_name
  into    v_name
  from    per_all_people_f peo
  where  peo.person_id = p_person_id
  and  p_session_date between peo.effective_start_date
                       and     peo.effective_end_date;
  c_header_name := v_name;
/*srw.message('003','name');*/null;




 hr_reports.get_desc_flex('PER','PER_ASSIGNMENT_STATUSES',
      'sst',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_sec_ass_df_details := v_column_expr;
        c_sec_ass_df_label   :=  v_label_expr;
   else
	c_sec_ass_df_details := 'sst.attribute1';
   end if;



 hr_reports.get_desc_flex('PER','PER_PEOPLE',
      'peo',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_emp_df_details := v_column_expr;
        c_emp_df_label   :=  v_label_expr;
   else
	c_emp_df_details := 'peo.attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_ASSIGNMENT_STATUSES',
      'sst',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_app_sec_status_details := v_column_expr;
        c_app_sec_status_label   :=  v_label_expr;
   else
	c_app_sec_status_details := 'sst.attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_EVENTS',
      'a',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_inter_df_details := v_column_expr;
        c_inter_df_label   :=  v_label_expr;
   else
	c_inter_df_details := 'a.attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_ASSIGNMENTS',
      'asg',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_app_ass_df_details := v_column_expr;
        c_app_ass_df_label   :=  v_label_expr;
   else
	c_app_ass_df_details := 'as'||'g.ass_attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_APPLICATIONS',
      'app',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_app_df_details := v_column_expr;
        c_app_df_label   :=  v_label_expr;
   else
	c_app_df_details := 'app.appl_attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_CONTACTS',
      'con',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_cont_df_details := v_column_expr;
        c_cont_df_label   :=  v_label_expr;
   else
	c_cont_df_details := 'peo.cont_attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_ADDRESSES',
      'addr',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_add_df_details := v_column_expr;
        c_add_df_label   :=  v_label_expr;
   else
	c_add_df_details := 'addr.addr_attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_ASSIGNMENTS',
      'asg',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_ass_df_details := v_column_expr;
        c_ass_df_label   :=  v_label_expr;
   else
	c_ass_df_details := 'as'||'g.ass_attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_ABSENCE_ATTENDANCES',
      'a',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_absence_df_details := v_column_expr;
        c_absence_df_label   :=  v_label_expr;
   else
	c_absence_df_details := 'a.attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_PERIODS_OF_SERVICE',
      'a',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_per_serv_df_details := v_column_expr;
        c_per_serv_df_label   :=  v_label_expr;
   else
	c_per_serv_df_details := 'a.attribute1';
   end if;

 hr_reports.get_desc_flex('PER','Assignment Developer DF',
      'f',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_fur_info_df_details := v_column_expr;
        c_fur_info_df_label   :=  v_label_expr;
   else
	c_fur_info_df_details := 'f.aei_attribute1';
   end if;

 hr_reports.get_desc_flex('PAY','PAY_PERSONAL_PAYMENT_METHODS',
      'ppm',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_ppm_df_details := v_column_expr;
        c_ppm_df_label   :=  v_label_expr;
   else
	c_ppm_df_details := 'ppm.attribute1';
   end if;

 hr_reports.get_desc_flex('PAY','PAY_ELEMENT_ENTRIES',
      'ee',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_ele_df_details :=  v_column_expr;
        c_ele_df_label   :=  v_label_expr;
   else
	c_ele_df_details := 'ee.attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_EVENTS',
      'a',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_event_df_details :=  v_column_expr;
        c_event_df_label   :=  v_label_expr;
   else
	c_event_df_details := 'a.attribute1';
   end if;

 hr_reports.get_desc_flex('PER','PER_BOOKINGS',
      'b',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_book_df_details :=  v_column_expr;
        c_book_df_label   :=  v_label_expr;
   else
	c_book_df_details := 'b.attribute1';
   end if;

hr_reports.get_desc_flex('PER','PER_PERSON_ANALYSES',
      'jr',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_special_df_details :=  v_column_expr;
        c_special_df_label   :=  v_label_expr;
   else
	c_special_df_details := 'jr.attribute1';
   end if;

    select  PBG.LEGISLATION_CODE
    into    v_legislation_code
    from     PER_BUSINESS_GROUPS PBG
    where    PBG.BUSINESS_GROUP_ID = p_business_group_id;

	declare
		v_id_flex_num	varchar2(150);
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

	exception
		when others then null;
	end;


end;
  return (TRUE);
end;

function c_get_auth_repformula(authorising_person_id in number, replacement_person_id in number) return number is
begin

declare
	v_authorizer_name varchar2(600);
        v_replacement_name varchar2(600);
begin
if authorising_person_id is not null then
 select hr1.meaning || decode(hr1.meaning,null,null,' ')
        || peo.first_name
        || decode(peo.first_name,null,null,' ')
        || peo.last_name
   into v_authorizer_name
   from per_all_people_f peo
   ,    hr_lookups hr1
  where AUTHORISING_PERSON_ID = peo.person_id
  and     peo.effective_start_date = (select min(peo2.effective_start_date)
                                    from  per_all_people_f peo2
                                    where peo2.person_id = peo.person_id)
  and     hr1.lookup_type  (+) = 'TITLE'
  and     hr1.lookup_code  (+) = peo.title;

  c_authorized_by := v_authorizer_name;
end if;

if replacement_person_id is not null then
 select hr1.meaning || decode(hr1.meaning,null,null,' ')
        || peo.first_name
        || decode(peo.first_name,null,null,' ')
        || peo.last_name
   into v_replacement_name
   from per_all_people_f peo
   ,    hr_lookups hr1
  where replacement_PERSON_ID = peo.person_id
  and     peo.effective_start_date = (select min(peo2.effective_start_date)
                                    from  per_all_people_f peo2
                                    where peo2.person_id = peo.person_id )
  and     hr1.lookup_type  (+) = 'TITLE'
  and     hr1.lookup_code  (+) = peo.title;

  c_replaced_by := v_replacement_name;
end if;
return('');
end;

RETURN NULL; end;

function AfterReport return boolean is
begin


--hr_standard.event('AFTER REPORT');

return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function c_req_value_p return varchar2 is
	Begin
	 return c_req_value;
	 END;
 Function C_req_descript_p return varchar2 is
	Begin
	 return C_req_descript;
	 END;
 Function C_authorized_by_p return varchar2 is
	Begin
	 return C_authorized_by;
	 END;
 Function C_replaced_by_p return varchar2 is
	Begin
	 return C_replaced_by;
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
 Function C_cost_id_flex_num_p return varchar2 is
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
 Function C_END_OF_TIME_p return varchar2 is
	Begin
	 return C_END_OF_TIME;
	 END;
END PER_PERRPFP4_XMLP_PKG ;

/