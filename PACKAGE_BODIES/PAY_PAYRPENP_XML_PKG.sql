--------------------------------------------------------
--  DDL for Package Body PAY_PAYRPENP_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYRPENP_XML_PKG" AS
/* $Header: pyxmlenp.pkb 120.1 2006/01/04 01:05 pgongada noship $ */

g_package_name varchar2(30) := 'PAY_PAYRPENP_XML_PKG';
g_xml_data     clob;

--
-- Private function to get the template name.
--

function get_template_name(p_app_short_name varchar2
                          ,p_template_code varchar2) return varchar2 is

 l_template_name xdo_templates_tl.template_name%type;
begin

    l_template_name := 'Not Defined';
    select template_name
    into l_template_name
    from xdo_templates_tl
    where application_short_name= p_app_short_name
    and	template_code= p_template_code
    and	language=userenv('LANG');

 return l_template_name;

exception
   when no_data_found then
      return l_template_name;
end get_template_name;

--
FUNCTION get_display_name(p_group_column VARCHAR2) RETURN VARCHAR2 IS
--
BEGIN
--
	CASE p_group_column
		WHEN 'payroll_name' THEN RETURN 'Payroll Name';
		WHEN 'organization_name' THEN RETURN 'Organization';
		WHEN 'location_code' THEN RETURN 'Location';
		ELSE RETURN NULL;
	END CASE;
--
END get_display_name;
--
procedure append_parameters_data(
                       p_organization_name          in varchar2
		      ,p_payroll_name               in varchar2
		      ,p_location_code              in varchar2
		      ,p_consolidation_set_name     in varchar2
		      ,p_business_group_name        in varchar2
		      ,p_no_data_found              in number
		      ,p_report_date		    in varchar2
		      ,p_start_date      	    in date
		      ,p_end_date		    in date
		      ,p_group_column1		    in varchar2
		      ,p_group_column2		    in varchar2
		      ,p_group_column3		    in varchar2
		      ,p_sort_option_one	    in varchar2
		      ,p_sort_option_two            in varchar2
		      ,p_sort_option_three	    in varchar2
		      ,p_template_name		    in varchar2
		      ) is
l_start_date_char varchar2(60);
l_end_date_char   varchar2(60);
l_tag  varchar2(200);

begin
    l_start_date_char := fnd_date.date_to_displaydate(p_start_date);
    l_end_date_char   := fnd_date.date_to_displaydate(p_end_date);

    l_tag := pay_prl_xml_utils.getTag('CP_ORGANIZATION_NAME', p_organization_name );
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_PAYROLL_NAME',p_payroll_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_LOCATION_CODE',p_location_code);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_CONSOLIDATION_SET_NAME',p_consolidation_set_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CONSOLIDATION_SET_NAME',p_consolidation_set_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_BUSINESS_GROUP_NAME',p_business_group_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_NO_DATA_FOUND', to_char(p_no_data_found) );
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_REPORT_DATE',p_report_date);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_START_DATE',l_start_date_char);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_END_DATE',l_end_date_char);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_GROUP_COLUMN1',get_display_name(p_group_column1));
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_GROUP_COLUMN2',get_display_name(p_group_column2));
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_GROUP_COLUMN3',get_display_name(p_group_column3));
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_SORT_OPTION1',p_sort_option_one);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_SORT_OPTION2',p_sort_option_two);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_SORT_OPTION3',p_sort_option_three);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_TEMPLATE_NAME',p_template_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

end;

--
-- Private procedure to append master data to the clob.
--

procedure append_master_group_data(
                                  p_master_column1   in varchar2,
		                  p_master_column2   in varchar2,
		                  p_master_column3   in varchar2
		                  )is

l_tag  varchar2(200);

begin
    l_tag := pay_prl_xml_utils.getTag('REG_A',p_master_column1);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('REG_B',p_master_column2);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('REG_C',p_master_column3);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

end;

--
-- Procedure to append detail data to the clob.
--

procedure append_detail_group_data(
	                      p_ICX_period_start_date    in varchar2
			     ,p_ICX_period_end_date      in varchar2
			     ,p_order_name               in varchar2
	                     ,p_organization_name        in varchar2
			     ,p_consolidation_set_name   in varchar2
			     ,p_payroll_name             in varchar2
			     ,p_location_code            in varchar2
			     ,p_assignment_id            in number
			     ,p_pay_basis                in varchar2
			     ,p_full_name                in varchar2
			     ,p_user_status              in varchar2
			     ,p_person_id                in number
			     ,p_assignment_number        in varchar2
			     ,p_cf_absence_type          in varchar2
			     ,p_cf_data_found            in number
	                    )is

l_tag varchar2(200);

begin
    l_tag := pay_prl_xml_utils.getTag('ICX_PERIOD_START_DATE', to_char(p_ICX_period_start_date) );
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('ICX_PERIOD_END_DATE',p_ICX_period_end_date);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('ORDER_NAME',p_order_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('ORGANIZATION_NAME',p_organization_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CONSOLIDATION_SET_NAME',p_consolidation_set_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('PAYROLL_NAME',p_payroll_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('LOCATION_CODE',p_location_code);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('ASSIGNMENT_ID',p_assignment_id);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('PAY_BASIS',p_pay_basis);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('FULL_NAME',p_full_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('USER_STATUS',p_user_status);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('PERSON_ID',p_person_id);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('ASSIGNMENT_NUMBER',p_assignment_number);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CF_ABSENCE_TYPE',p_cf_absence_type);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CF_DATA_FOUND',p_cf_data_found);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

end append_detail_group_data;

--
-- Function to get absence type.
--

function get_absence_type
(
 p_period_start_date  in date
,p_period_end_date    in date
,p_person_id          in number
) return varchar2 is

cursor c_absence(c_person_id number,c_period_end_date date, c_period_start_date date) is
select typ.name
from per_absence_attendances att,
     per_absence_attendance_types typ
where att.person_id = c_person_id
and att.absence_attendance_type_id = typ.absence_attendance_type_id
and att.date_start <= c_period_end_date
and att.date_end   >= c_period_start_date;

l_name  varchar2(30);

begin

open c_absence(p_person_id, p_period_end_date, p_period_start_date);
fetch c_absence into l_name;
close c_absence;

if l_name is null then

return(' ');

else

return(l_name);

end if;

end get_absence_type;

--
--
--

function get_additional_where_clause
(
  p_payroll_id            in number
 ,p_consolidation_set_id  in number
 ,p_organization_id       in number
 ,p_location_id           in number
 ,p_business_group_id     in varchar2
)return varchar2 is

l_additional_where_clause varchar2(4000);
begin

l_additional_where_clause := ' ';
if p_organization_id is not null then
  l_additional_where_clause := l_additional_where_clause || ' and organization_id = '|| p_organization_id ;
end if;

if p_payroll_id is not null then
  l_additional_where_clause := l_additional_where_clause || ' and payroll_id = ' ||p_payroll_id ;
end if;

if p_consolidation_set_id is not null then
  l_additional_where_clause := l_additional_where_clause || ' and consolidation_set_id =' || p_consolidation_set_id ;
end if;

if p_business_group_id is not null then
  l_additional_where_clause := l_additional_where_clause || ' and business_group_id = ' || p_business_group_id ;
end if;

if p_location_id is not null then
  l_additional_where_clause := l_additional_where_clause || ' and location_id = ' || p_location_id ;
end if;

return l_additional_where_clause;

end get_additional_where_clause;


--
-- Procedure to set order by clause and set the values of group by
-- parameters.
--

Procedure set_groupby_orderby_values
(
  p_sort_option_one   in out nocopy     varchar2
 ,p_sort_option_two   in out nocopy     varchar2
 ,p_sort_option_three in out nocopy     varchar2
 ,p_order_by_clause   in out nocopy     varchar2

) is

l_order_1          varchar2(60);
l_order_2          varchar2(60);
l_order_3          varchar2(60);
l_group_column1    varchar2(60);
l_group_column2    varchar2(60);
l_group_column3    varchar2(60);

begin
  l_group_column1 := 'NULL';
  l_group_column2 := 'NULL';
  l_group_column3 := 'NULL';

  l_order_1 := 'NULL';
  l_order_2 := 'NULL';
  l_order_3 := 'NULL';

  if p_sort_option_one is NULL then
      p_sort_option_one := 'Payroll Name';
  end if;

  if p_sort_option_one <> 'Employee Name' and
     p_sort_option_two is NULL then
     p_sort_option_two := 'Employee Name';
  end if;

  if  p_sort_option_one = 'Payroll Name' then
      l_group_column1    := 'payroll_name';
      l_order_1 := 'payroll_name';

  elsif p_sort_option_one = 'Employee Name' then
      l_order_1 := 'order_name, full_name';

  elsif p_sort_option_one = 'Assignment Number' then
      l_order_1 := 'assignment_number';

  elsif p_sort_option_one = 'Organization' then
      l_group_column1    := 'organization_name';
      l_order_1 := 'organization_name';

  elsif p_sort_option_one = 'Location' then
      l_group_column1    := 'location_code';
      l_order_1 := 'location_code';

  elsif p_sort_option_one = 'Assignment Status' then
      l_order_1 := 'user_status';
  end if;



  if  p_sort_option_two = 'Payroll Name' then
      l_group_column2    := 'payroll_name';
      l_order_2 := 'payroll_name';

  elsif p_sort_option_two = 'Employee Name' then
      l_order_2 := 'order_name, full_name';

  elsif p_sort_option_two = 'Assignment Number' then
      l_order_2 := 'assignment_number';

  elsif p_sort_option_two = 'Organization' then
      l_group_column2    := 'organization_name';
      l_order_2 := 'organization_name';

  elsif p_sort_option_two = 'Location' then
      l_group_column2    := 'location_code';
      l_order_2 := 'location_code';

  elsif p_sort_option_two = 'Assignment Status' then
      l_order_2 := 'user_status';
  end if;


  if   p_sort_option_three = 'Payroll Name' then
      l_group_column3    := 'payroll_name';
      l_order_3 := 'payroll_name';

  elsif p_sort_option_three = 'Employee Name' then
      l_order_3 := 'order_name, full_name';

  elsif p_sort_option_three = 'Assignment Number' then
      l_order_3 := 'assignment_number';

  elsif p_sort_option_three = 'Organization' then
      l_group_column3    := 'organization_name';
      l_order_3 := 'organization_name';

  elsif p_sort_option_three = 'Location' then
      l_group_column3   := 'location_code';
      l_order_3 := 'location_code';

  elsif p_sort_option_three = 'Assignment Status' then
      l_order_3 := 'user_status';
  end if;

  p_order_by_clause := l_order_1||', '||l_order_2||', '||l_order_3;

  if l_order_1 <> 'order_name, full_name' and
     l_order_2 <> 'order_name, full_name' and
     l_order_3 <> 'order_name, full_name' then

   p_order_by_clause := p_order_by_clause || ',order_name, full_name';

  end if;

  p_order_by_clause   := p_order_by_clause || ',period_end_date';

  p_sort_option_one   := l_group_column1;
  p_sort_option_two   := l_group_column2;
  p_sort_option_three := l_group_column3;

end set_groupby_orderby_values;

--
--
--
procedure emp_asg_not_processed
(
  p_start_date_char       in varchar2
 ,p_end_date_char         in varchar2
 ,p_payroll_id            in number    default null
 ,p_consolidation_set_id  in number
 ,p_organization_id       in number    default null
 ,p_location_id           in number    default null
 ,p_sort_option_one       in varchar2  default null
 ,p_sort_option_two       in varchar2  default null
 ,p_sort_option_three     in varchar2  default null
 ,p_business_group_id     in varchar2  default null
 ,p_session_date_char     in varchar2  default null
 ,p_template_name         in varchar2
 ,p_xml                   out nocopy clob
)
is

type ref_cursor_type is ref cursor;

type detail_rec_type is record
(
 payroll_name            pay_asgs_not_processed_v.payroll_name%type
,assignment_number       pay_asgs_not_processed_v.assignment_number%type
,order_name              pay_asgs_not_processed_v.order_name%type
,full_name               pay_asgs_not_processed_v.full_name%type
,user_status             pay_asgs_not_processed_v.user_status%type
,period_start_date       pay_asgs_not_processed_v.period_start_date%type
,ICX_period_start_date   varchar2(30)
,period_end_date         pay_asgs_not_processed_v.period_end_date%type
,ICX_period_end_date     varchar2(30)
,location_code           pay_asgs_not_processed_v.location_code%type
,pay_basis               pay_asgs_not_processed_v.pay_basis%type
,assignment_id           pay_asgs_not_processed_v.assignment_id%type
,person_id               per_people_f.person_id%type
,organization_name       pay_asgs_not_processed_v.organization_name%type
,consolidation_set_name  pay_asgs_not_processed_v.consolidation_set_name%type
);

-- Need one cursor for outer group i.e. the master group.
csr_master ref_cursor_type;

-- For each master record there will be detail records.
csr_detail ref_cursor_type;

l_group_column1              varchar2(60);
l_group_column2              varchar2(60);
l_group_column3              varchar2(60);
l_order_by_clause            varchar2(200);
l_group_by_clause            varchar2(200);
l_where_clause               varchar2(2000);
l_additional_where_clause    varchar2(2000);
l_payroll_name               pay_payrolls_f.payroll_name%type;
l_location_code              hr_locations.location_code%type;
l_business_group_name        per_business_groups.name%type;
l_consolidation_set_name     pay_consolidation_sets.consolidation_set_name%type;
l_organization_name          hr_organization_units.name%type;
l_template_name              xdo_templates_tl.template_name%type;
l_master_statement           varchar2(32000);
l_detail_statement           varchar2(32000);
l_master_column1             varchar2(60);
l_master_column2             varchar2(60);
l_master_column3             varchar2(60);
l_tag                        varchar2(200);
cf_data_found                number;
l_no_data_found              number;
cf_absence_type              varchar2(100);

c_detail_rec detail_rec_type;

--
-- Cursor to get payroll name.
--
cursor csr_get_payroll_name (c_payroll_id number)
is
select payroll_name
  from pay_payrolls_f
  where payroll_id = c_payroll_id;

--
-- Cursor to get consolidation_set_name
--
cursor csr_get_consolidation_set_name(c_consolidation_set_id number)
is
select consolidation_set_name
  from pay_consolidation_sets
  where consolidation_set_id = c_consolidation_set_id;

--
-- Cursor to get organization name.
--
cursor csr_get_organization_name(c_organization_id number)
is
select name
  from hr_organization_units
  where organization_id = c_organization_id;

--
--
--
cursor csr_get_bg_name(c_business_group_id number)
is
select name
  from per_business_groups
  where business_group_id = c_business_group_id;



begin
hr_utility.set_location(g_package_name || '.emp_asg_not_processed', 10);

--
-- Get the parameters which will be used to group the assignments.
-- The parameters returned will be used to frame the master cursor query.
--

if ( p_payroll_id is not null ) then
	open csr_get_payroll_name(p_payroll_id);
	fetch csr_get_payroll_name into l_payroll_name;
	close csr_get_payroll_name;
end if;

if (p_organization_id is not null) then
	open csr_get_organization_name(p_organization_id);
	fetch csr_get_organization_name into l_organization_name;
	close csr_get_organization_name;
end if;

open csr_get_consolidation_set_name(p_consolidation_set_id);
fetch csr_get_consolidation_set_name into l_consolidation_set_name;
close csr_get_consolidation_set_name;

open csr_get_bg_name(p_business_group_id);
fetch csr_get_bg_name into l_business_group_name;
close csr_get_bg_name;

l_location_code := payrpenp.get_location_code(p_location_id);

l_template_name := get_template_name('PAY', p_template_name);

--
-- Procedure to set order by clause and group by parameters.
--
l_group_column1   := p_sort_option_one;
l_group_column2   := p_sort_option_two;
l_group_column3   := p_sort_option_three;
l_order_by_clause := ' ';

set_groupby_orderby_values
(
  l_group_column1
 ,l_group_column2
 ,l_group_column3
 ,l_order_by_clause
);

l_group_by_clause := l_group_column1 || ',' || l_group_column2 || ',' ||
                     l_group_column3;
l_group_by_clause := trim(',' from l_group_by_clause);

--
-- Get the additional where clause depending on the user inputs.
--

l_where_clause :=
get_additional_where_clause
(
 p_payroll_id
,p_consolidation_set_id
,p_organization_id
,p_location_id
,p_business_group_id
);
--
-- Frame the statement for master query.
--

l_master_statement := 'select ' ||
                      l_group_column1 || ' column1,' ||
		      l_group_column2 || ' column2,' ||
		      l_group_column3 || ' column3 ' ||
		      ' from pay_asgs_not_processed_v where period_end_date between :1 and :2 ' ||
		      l_where_clause || ' group by ' ||
		      l_group_by_clause || ' order by ' ||
		      l_group_by_clause;

l_detail_statement := 'select ' ||
                      'payroll_name payroll_name,
                      assignment_number assignment_number,
                      order_name order_name,
                      full_name full_name,
                      user_status user_status,
                      period_start_date period_start_date,
                      fnd_date.date_to_displaydate(period_start_date) ICX_period_start_date,
                      period_end_date period_end_date,
                      fnd_date.date_to_displaydate(period_end_date) ICX_period_end_date,
                      location_code location_code,
                      pay_basis pay_basis,
                      assignment_id assignment_id,
                      person_id person_id,
                      organization_name organization_name,
                      consolidation_set_name consolidation_set_name
		      from
                      pay_asgs_not_processed_v
                      where
                      period_end_date between :1 and :2 ' ||
		      l_where_clause ||
		      ' and NVL ('|| l_group_column1 || ' , ''-1'' ) = NVL( :3, ''-1'')' ||
		      ' and NVL ('|| l_group_column2 || ' , ''-1'' ) = NVL( :4, ''-1'')' ||
		      ' and NVL ('|| l_group_column3 || ' , ''-1'' ) = NVL( :5, ''-1'')' ||
		      ' order by '||l_order_by_clause;


dbms_lob.createtemporary(g_xml_data,false,dbms_lob.call);
dbms_lob.open(g_xml_data,dbms_lob.lob_readwrite);

l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';
dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

l_tag := '<PAYRPENP>';
dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

l_tag := '<LIST_G_SORT1>';
dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

cf_data_found := 0;

open csr_master for l_master_statement using fnd_date.canonical_to_date(p_start_date_char),
                                             fnd_date.canonical_to_date(p_end_date_char);
loop

    fetch csr_master into l_master_column1,l_master_column2,l_master_column3;
    exit when csr_master%notfound;

    l_tag := '<G_SORT1>';
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    append_master_group_data(
                       l_master_column1,
		       l_master_column2,
		       l_master_column3
		       );

    open csr_detail for l_detail_statement using to_date(p_start_date_char,'YYYY/MM/DD HH24:MI:SS'),
                                            to_date(p_end_date_char,'YYYY/MM/DD HH24:MI:SS'),
					    l_master_column1,
					    l_master_column2,
					    l_master_column3;

    l_tag := '<LIST_G_FULL_NAME>';
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

         loop

	 fetch csr_detail into c_detail_rec;
	      if csr_detail%found then
	         cf_data_found := 1;
	      else
	         exit;
	      end if;

	 cf_absence_type := get_absence_type(
	                                              c_detail_rec.period_start_date
						      ,c_detail_rec.period_end_date
						      ,c_detail_rec.person_id
						      );

         l_tag := '<G_FULL_NAME>';
         dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);
	 append_detail_group_data(
	                      c_detail_rec.ICX_period_start_date
			     ,c_detail_rec.ICX_period_end_date
			     ,c_detail_rec.order_name
	                     ,c_detail_rec.organization_name
			     ,c_detail_rec.consolidation_set_name
			     ,c_detail_rec.payroll_name
			     ,c_detail_rec.location_code
			     ,c_detail_rec.assignment_id
			    -- ,c_detail_rec.name
			     ,c_detail_rec.pay_basis
			     ,c_detail_rec.full_name
			     ,c_detail_rec.user_status
			     ,c_detail_rec.person_id
			     ,c_detail_rec.assignment_number
			     ,cf_absence_type
			     ,cf_data_found
	                    );
         l_tag := '</G_FULL_NAME>';
         dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

	 --dbms_output.put_line('Full Name = ' || c_detail_rec.full_name);
	 end loop;
	 close csr_detail;

    l_tag := '</LIST_G_FULL_NAME>';
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := '</G_SORT1>';
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

end loop;
close csr_master;

l_tag := '</LIST_G_SORT1>';
dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

--
--
--
if cf_data_found = 0 then
   l_no_data_found := 1;
else
   l_no_data_found := 0;
end if;

append_parameters_data(
                       l_organization_name
		      ,l_payroll_name
		      ,l_location_code
		      ,l_consolidation_set_name
		      ,l_business_group_name
		      ,l_no_data_found
		      ,fnd_date.date_to_displayDT(SysDate)
		      ,fnd_date.canonical_to_date(p_start_date_char)
		      ,fnd_date.canonical_to_date(p_end_date_char)
		      ,l_group_column1
		      ,l_group_column2
                      ,l_group_column3
		      ,p_sort_option_one
		      ,p_sort_option_two
		      ,p_sort_option_three
		      ,l_template_name
		      );

l_tag := '</PAYRPENP>';
dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

p_xml := g_xml_data;

end emp_asg_not_processed;



end PAY_PAYRPENP_XML_PKG;

/
