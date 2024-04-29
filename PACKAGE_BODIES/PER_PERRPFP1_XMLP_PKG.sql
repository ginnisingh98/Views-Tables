--------------------------------------------------------
--  DDL for Package Body PER_PERRPFP1_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPFP1_XMLP_PKG" AS
/* $Header: PERRPFP1B.pls 120.1 2007/12/06 11:28:20 amakrish noship $ */
function BeforeReport return boolean is
begin
P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
c_end_of_time := '4712-12-31';
  declare
	v_name varchar2(350);
        v_title varchar2(400);
        v_label_expr varchar2(32000);
        v_column_expr varchar2(32000);
	v_legislation_code varchar2(30);
begin


--hr_standard.event('BEFORE REPORT');

/*srw.message('001','Start of Before Report Trigger');*/null;


 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

/*srw.message('002','Business Group = '||c_business_group_name);*/null;


  select  peo.first_name ||
	  decode(peo.first_name,null,null,' ') ||
          peo.last_name
  into    v_name
  from    per_all_people_f peo
  where  peo.person_id = p_person_id
  and  p_session_date between peo.effective_start_date
                       and     peo.effective_end_date;
  c_header_name := v_name;

/*srw.message('003','Person = '||c_header_name);*/null;



 hr_reports.get_desc_flex_context('PER','PER_PEOPLE',
      'peo',v_title,v_label_expr,v_column_expr);
  if  v_column_expr is not null
	then
   	c_emp_df_details := v_column_expr;
        c_emp_df_label   :=  v_label_expr;
   else
        c_emp_df_details := 'peo.attribute1';
        c_emp_df_label   :=  'rpad('' '',1,'' '')';
   end if;

/*srw.message('004','HR_REPORTS = PEO');*/null;



 hr_reports.get_desc_flex_context('PER','PER_CONTACTS',
      'con',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_cont_df_details := v_column_expr;
        c_cont_df_label   :=  v_label_expr;
   else
	c_cont_df_details := 'con.cont_attribute1';
   end if;

/*srw.message('005','HR_REPORTS = CON');*/null;


 hr_reports.get_desc_flex_context('PER','PER_ADDRESSES',
      'addr',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_add_df_details := v_column_expr;
        c_add_df_label   :=  v_label_expr;
   else
	c_add_df_details := 'addr.addr_attribute1';
   end if;

/*srw.message('006','HR_REPORTS = ADDR');*/null;



 hr_reports.get_desc_flex_context('PER','Assignment Developer DF',
      'f',v_title,v_label_expr,v_column_expr);
  if v_column_expr is not null then
  	c_fur_info_df_details := v_column_expr;
        c_fur_info_df_label   :=  v_label_expr;
   else
	c_fur_info_df_details := 'f.aei_attribute1';
   end if;

/*srw.message('007','HR_REPORTS = F');*/null;




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

	exception
		when others then null;
	end;

			begin

  	  select rule_type into p_town_of_birth
	  from pay_legislative_field_info
	  where field_name = 'TOWN_OF_BIRTH'
	  and legislation_code = v_legislation_code;

	exception
	  when no_data_found then
  	  null;
	end;


	begin

  	  select rule_type into p_region_of_birth
	  from pay_legislative_field_info
	  where field_name = 'REGION_OF_BIRTH'
	  and legislation_code = v_legislation_code;

	exception
	  when no_data_found then
  	  null;
	end;


end;

/*srw.message('010','End of Before Report Trigger');*/null;


  return (TRUE);
end;

function c_get_flexformula(style in varchar2) return number is
begin

declare
        v_title varchar2(900);
        v_label_expr varchar2(2000);
        v_column_expr varchar2(2000);
begin
  hr_reports.get_dvlpr_desc_flex('PER','Address Structure',style,
  'ADD1',v_title,v_label_expr,v_column_expr);
  c_details := v_column_expr;
return('');
end;

RETURN NULL; end;

function c_address_copyformula(conc_address in varchar2) return varchar2 is
begin

return conc_address;
end;

function c_split_flexformula(c_address_copy in varchar2) return number is
begin

declare
v_segments_used NUMBER;
v_value1  VARCHAR2(240);
v_value2  VARCHAR2(240);
v_value3 VARCHAR2(240);
v_value4 VARCHAR2(240);
v_value5 VARCHAR2(240);
v_value6 VARCHAR2(240);
v_value7 VARCHAR2(240);
v_value8 VARCHAR2(240);
v_value9 VARCHAR2(240);
v_value10 VARCHAR2(240);
v_value11 VARCHAR2(240);
v_value12 VARCHAR2(240);
v_value13 VARCHAR2(240);
v_value14 VARCHAR2(240);
v_value15 VARCHAR2(240);
v_value16 VARCHAR2(240);
v_value17 VARCHAR2(240);
v_value18 VARCHAR2(240);
v_value19 VARCHAR2(240);
v_value20 VARCHAR2(240);
v_value21 VARCHAR2(240);
v_value22 VARCHAR2(240);
v_value23 VARCHAR2(240);
v_value24 VARCHAR2(240);
v_value25 VARCHAR2(240);
v_value26 VARCHAR2(240);
v_value27 VARCHAR2(240);
v_value28 VARCHAR2(240);
v_value29 VARCHAR2(240);
v_value30 VARCHAR2(240);
begin
hr_reports.get_attributes(
c_address_copy,
'Address Structure',
v_segments_used,
v_value1,
v_value2,
v_value3,
v_value4,
v_value5,
v_value6,
v_value7,
v_value8,
v_value9,
v_value10,
v_value11,
v_value12,
v_value13,
v_value14,
v_value15,
v_value16,
v_value17,
v_value18,
v_value19,
v_value20,
v_value21,
v_value22,
v_value23,
v_value24,
v_value25,
v_value26,
v_value27,
v_value28,
v_value29,
v_value30);

c_address1 := v_value1;
c_address2 := v_value2;
c_address3 := v_value3;
c_address4 := v_value4;
c_address5 := v_value5;
c_address6 := v_value6;
c_address7 := v_value7;
c_address8 := v_value8;
c_address9 := v_value9;
c_address10 := v_value10;
c_address11 := v_value11;
c_address12 := v_value12;
c_address13 := v_value13;
c_address14 := v_value14;
c_address15 := v_value15;
c_address16 := v_value16;
c_address17 := v_value17;
c_address18 := v_value18;
c_address19 := v_value19;
c_address20 := v_value20;
return('');
end;



RETURN NULL; end;

function c_get_emp_leg_dfformula(per_information_category in varchar2) return number is
begin

declare
        v_title varchar2(240);
        v_label_expr varchar2(2000);
        v_column_expr varchar2(2000);
begin
/*srw.message('903','C_get_emp_leg_dfFormula');*/null;


/*srw.message('901','per_information_category = '||per_information_category);*/null;


if per_information_category is not null then
hr_reports.get_dvlpr_desc_flex('PER','Person Developer DF',
per_information_category,'pp',v_title,v_label_expr,v_column_expr);

c_emp_leg_df_details := v_column_expr;
c_emp_leg_df_label := v_label_expr;

return('');
end if;
end;

RETURN NULL; end;

function AfterReport return boolean is
begin

--hr_standard.event('AFTER REPORT');





  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_address1_p return varchar2 is
	Begin
	 return C_address1;
	 END;
 Function C_address2_p return varchar2 is
	Begin
	 return C_address2;
	 END;
 Function C_address3_p return varchar2 is
	Begin
	 return C_address3;
	 END;
 Function C_address4_p return varchar2 is
	Begin
	 return C_address4;
	 END;
 Function C_address5_p return varchar2 is
	Begin
	 return C_address5;
	 END;
 Function C_address6_p return varchar2 is
	Begin
	 return C_address6;
	 END;
 Function C_address7_p return varchar2 is
	Begin
	 return C_address7;
	 END;
 Function C_address8_p return varchar2 is
	Begin
	 return C_address8;
	 END;
 Function C_address9_p return varchar2 is
	Begin
	 return C_address9;
	 END;
 Function C_address10_p return varchar2 is
	Begin
	 return C_address10;
	 END;
 Function C_address11_p return varchar2 is
	Begin
	 return C_address11;
	 END;
 Function C_address12_p return varchar2 is
	Begin
	 return C_address12;
	 END;
 Function C_address13_p return varchar2 is
	Begin
	 return C_address13;
	 END;
 Function C_address14_p return varchar2 is
	Begin
	 return C_address14;
	 END;
 Function C_address15_p return varchar2 is
	Begin
	 return C_address15;
	 END;
 Function C_address16_p return varchar2 is
	Begin
	 return C_address16;
	 END;
 Function C_address17_p return varchar2 is
	Begin
	 return C_address17;
	 END;
 Function C_address18_p return varchar2 is
	Begin
	 return C_address18;
	 END;
 Function C_address19_p return varchar2 is
	Begin
	 return C_address19;
	 END;
 Function C_address20_p return varchar2 is
	Begin
	 return C_address20;
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
 Function C_SUBTITLE_p return varchar2 is
	Begin
	 return C_SUBTITLE;
	 END;
 Function C_details10_p return varchar2 is
	Begin
	 return C_details10;
	 END;
 Function C_END_OF_TIME_p return varchar2 is
	Begin
	 return C_END_OF_TIME;
	 END;


END PER_PERRPFP1_XMLP_PKG;

/
