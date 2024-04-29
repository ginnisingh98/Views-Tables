--------------------------------------------------------
--  DDL for Package Body PAY_PAYRPANP_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYRPANP_XML_PKG" AS
/* $Header: pyxmlanp.pkb 120.1 2005/10/18 06:36 mkataria noship $ */

g_package_name varchar2(30) := 'PAY_PAYRPANP_XML_PKG';
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
--
--

function get_action_type( p_action_type_code varchar2) return varchar2 is

 cursor c_action_type_meaning(c_action_type_code varchar2) is
 select meaning
 from hr_lookups
 where lookup_type = 'ACTION_TYPE'
 and lookup_code = c_action_type_code ;

 l_action_type_meaning  VARCHAR2(80);

begin

 open c_action_type_meaning(p_action_type_code);
 fetch c_action_type_meaning into l_action_type_meaning;
 close c_action_type_meaning;

 return l_action_type_meaning;

end get_action_type;

--
--
--

procedure append_parameters_data
                      (
                       p_consolidation_set_name       in varchar2
                      ,p_payroll_name		      in varchar2
                      ,p_business_group_name	      in varchar2
                      ,p_record_counter	              in number
                      ,p_report_name		      in varchar2
                      ,p_mode_desc		      in varchar2
                      ,p_report_date                  in varchar2
                      ,p_start_date		      in date
                      ,p_end_date		      in date
                      ,p_template_name	              in varchar2
		      ) is

l_start_date_char varchar2(60);
l_end_date_char   varchar2(60);
l_tag  varchar2(200);

begin
    l_start_date_char := fnd_date.date_to_displaydate(p_start_date);
    l_end_date_char   := fnd_date.date_to_displaydate(p_end_date);

    l_tag := pay_prl_xml_utils.getTag('CP_CONSOLIDATION_SET_NAME', p_consolidation_set_name );
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_PAYROLL_NAME',p_payroll_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_BUSINESS_GROUP_NAME',p_business_group_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_RECORD_COUNT',p_record_counter);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_REPORT_NAME',p_report_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_MODE_DESC',p_mode_desc);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_REPORT_DATE', p_report_date );
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_START_DATE',l_start_date_char);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_END_DATE',l_end_date_char);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CP_TEMPLATE_NAME',p_template_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

end;

--
-- Private procedure to append master data to the clob.
--

procedure append_group_data(
                        p_consolidation_set_name  varchar2
		       ,p_payroll_name            varchar2
		       ,p_effective_date          date
		       ,p_assignment_number       varchar2
		       ,p_action_type             varchar2
		       ,p_action_number           number
		       ,p_person_id               number
		       ,p_full_name               varchar2
		       ,p_employee_number         number
		       ,p_action_type_meaning     varchar2
		       ,p_record_counter          number
		        )is

l_tag  varchar2(200);

begin
    l_tag := pay_prl_xml_utils.getTag('CONSOLIDATION_SET_NAME',p_consolidation_set_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('PAYROLL_NAME',p_payroll_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('EFFECTIVE_DATE',p_effective_date);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('ASSIGNMENT_NUMBER',p_assignment_number);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('ACTION_TYPE',p_action_type);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('ACTION_NUMBER',p_action_number);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('PERSON_ID',p_person_id);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('FULL_NAME',p_full_name);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('EMPLOYEE_NUMBER',p_employee_number);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CF_ACTION_TYPE',p_action_type_meaning);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    l_tag := pay_prl_xml_utils.getTag('CF_RECORD_COUNTER',p_record_counter);
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

end append_group_data;

--
--
--

Procedure set_condition_clauses
(
 p_mode                         in          varchar2
,p_locking_payroll_condition    out  nocopy varchar2
,p_payroll_action_condition     out  nocopy varchar2
,p_payroll_consolidation_set    out  nocopy varchar2
,p_order_by                     out  nocopy varchar2
) is

begin
/* Checking if picked by be Archiver */
 if p_mode = '01' then
    p_payroll_action_condition := '    ppa.action_type in (''P'',''U'',''B'')
                                    and paa.source_action_id is null
                                    and paa.action_status = ''C''';

    p_locking_payroll_condition := '    ppa_lock.action_type = ''X''
                                     and ppa_lock.report_type = ''XFR_INTERFACE''
                                     and report_category = ''RT''
                                     and report_qualifier = ''FED''
                                     and paa_lock.action_status = ''C''';
    p_payroll_consolidation_set :=
            '    ppa.payroll_id = nvl(:4, ppa.payroll_id)
             and ppa.consolidation_set_id = nvl(:5,
                                                ppa.consolidation_set_id)
             and pay.payroll_id = ppa.payroll_id
             and pcs.consolidation_set_id = ppa.consolidation_set_id';

    p_order_by := 'ppf.order_name, ppf.full_name, ppa.effective_date,
                    ppa.action_type, paa.assignment_action_id';


 /* Checking if transfered in the FLS Tape */
 elsif p_mode = '02' then

    p_payroll_action_condition := '    ppa.action_type = ''X''
                                    and ppa.report_type = ''XFR_INTERFACE''
                                    and paa.action_status = ''C''';

    p_locking_payroll_condition := '    ppa_lock.action_type = ''X''
                                     and ppa_lock.report_type = ''FLS''
                                     and report_category = ''RT''
                                     and report_qualifier = ''PERIODIC''
                                     and paa_lock.action_status = ''C''';
    p_payroll_consolidation_set :=
        '    rtrim(pay_mag_utils.get_parameter(
                          ''TRANSFER_PAYROLL_ID''
                         ,''TRANSFER_CONSOLIDATION_SET_ID''
                         ,ppa.legislative_parameters)) =
                nvl(:4 , rtrim(pay_mag_utils.get_parameter(
                                                      ''TRANSFER_PAYROLL_ID''
                                                     ,''TRANSFER_CONSOLIDATION_SET_ID''
                                                     ,ppa.legislative_parameters)))
          and rtrim(pay_mag_utils.get_parameter(
                          ''TRANSFER_CONSOLIDATION_SET_ID''
                         ,null
                         ,ppa.legislative_parameters)) =
                nvl(:5 , rtrim(pay_mag_utils.get_parameter(
                                                          ''TRANSFER_CONSOLIDATION_SET_ID''
                                                         ,null
                                                         ,ppa.legislative_parameters)))
          and pay.payroll_id = rtrim(pay_mag_utils.get_parameter(
                                ''TRANSFER_PAYROLL_ID''
                               ,''TRANSFER_CONSOLIDATION_SET_ID''
                               ,ppa.legislative_parameters))
          and pcs.consolidation_set_id = rtrim(pay_mag_utils.get_parameter(
                                                          ''TRANSFER_CONSOLIDATION_SET_ID''
                                                         ,null
                                                         ,ppa.legislative_parameters))';


     p_order_by := 'ppf.order_name, ppf.full_name, ppa.effective_date,
                    ppa.action_type, paa.assignment_action_id';

 elsif p_mode = '03' then
    p_payroll_action_condition := '    (ppa.action_type in (''R'',''Q'', ''V'') or
                                         (ppa.action_type = ''B'' and
                                          nvl(ppa.future_process_mode, ''N'') = ''Y''))
                                    and paa.source_action_id is null
                                    and paa.action_status = ''C''';

    p_locking_payroll_condition := '    ppa_lock.action_type = ''C''
                                     and paa_lock.action_status = ''C''';
    p_payroll_consolidation_set :=
            '    ppa.payroll_id = nvl(:4, ppa.payroll_id)
             and ppa.consolidation_set_id = nvl(:5,
                                                ppa.consolidation_set_id)
             and pay.payroll_id = ppa.payroll_id
             and pcs.consolidation_set_id = ppa.consolidation_set_id';

    p_order_by := 'ppf.order_name, ppf.full_name, ppa.effective_date,
                    ppa.action_type, paa.assignment_action_id';

 elsif p_mode = '04' then
    p_payroll_action_condition := '    (ppa.action_type in (''R'',''Q'') or
                                        (ppa.action_type = ''B'' and
                                         nvl(ppa.future_process_mode,''N'') = ''Y''))
                                    and paa.source_action_id is null
                                    and paa.action_status = ''C''';

    p_locking_payroll_condition := '    ppa_lock.action_type in (''P'', ''U'')
                                     and paa_lock.action_status = ''C''';
    p_payroll_consolidation_set :=
            '    ppa.payroll_id = nvl(:4, ppa.payroll_id)
             and ppa.consolidation_set_id = nvl(:5,
                                                ppa.consolidation_set_id)
             and pay.payroll_id = ppa.payroll_id
             and pcs.consolidation_set_id = ppa.consolidation_set_id';

    p_order_by := 'ppf.order_name, ppf.full_name, ppa.effective_date,
                    ppa.action_type, paa.assignment_action_id';
 end if;


end set_condition_clauses;

--
--
--

procedure actions_not_processed
(
  p_start_date_char       in varchar2
 ,p_end_date_char         in varchar2
 ,p_payroll_id            in number    default null
 ,p_consolidation_set_id  in number    default null
 ,p_report_name           in varchar2
 ,p_mode                  in varchar2
 ,p_business_group_id     in varchar2
 ,p_session_date_char     in varchar2
 ,p_template_name         in varchar2
 ,p_xml                   out nocopy clob
)
is

l_tag                        varchar2(200);
l_statement                  varchar2(32000);
l_locking_payroll_condition  varchar2(2000);
l_mode_desc                  varchar2(2000);
l_order_by                   varchar2(2000);
l_payroll_action_condition   varchar2(2000);
l_consolidation_set_name     pay_consolidation_sets.consolidation_set_name%type;
l_consolidation_set_condition varchar2(2000);
l_template_name              varchar2(2000);
l_payroll_name               pay_payrolls_f.payroll_name%type;
l_business_group_name        per_business_groups.name%type;
l_session_date               date;
l_start_date                 date;
l_end_date                   date;
cf_record_counter            number;
cf_action_type               varchar2(80);

type ref_cursor_type is ref cursor;

type report_data_record is record
(
 person_id              number
,full_name              per_people_f.full_name%type
,employee_number        number
,effective_date         varchar2(20)
,action_type            varchar2(30)
,action_number          number
,assignment_number      per_assignments_f.assignment_number%type
,payroll_name           pay_all_payrolls_f.payroll_name%type
,consolidation_set_name pay_consolidation_sets.consolidation_set_name%type
);

l_report_data report_data_record;

-- Need one cursor for outer group i.e. the master group.
csr_report_data ref_cursor_type;

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
--
--
cursor csr_get_bg_name(c_business_group_id number)
is
select name
  from per_business_groups
  where business_group_id = c_business_group_id;


cursor c_report_mode(c_mode hr_lookups.lookup_code%type) is
   select h.meaning from hr_lookups h
    where h.lookup_type = 'PAY_ACTIONS_NOT_PROCESSED'
      and h.lookup_code = c_mode
      and h.enabled_flag = 'Y';


begin

hr_utility.set_location(g_package_name || '.actions not processed', 10);

--
-- Get the parameters which will be used to group the assignments.
-- The parameters returned will be used to frame the master cursor query.
--

open csr_get_payroll_name(p_payroll_id);
fetch csr_get_payroll_name into l_payroll_name;
close csr_get_payroll_name;


open csr_get_consolidation_set_name(p_consolidation_set_id);
fetch csr_get_consolidation_set_name into l_consolidation_set_name;
close csr_get_consolidation_set_name;

open csr_get_bg_name(p_business_group_id);
fetch csr_get_bg_name into l_business_group_name;
close csr_get_bg_name;


l_template_name := get_template_name('PAY', p_template_name);

--
-- Procedure to set order by clause and group by parameters.
--

set_condition_clauses
(
 p_mode                           => p_mode
,p_locking_payroll_condition      => l_locking_payroll_condition
,p_payroll_action_condition       => l_payroll_action_condition
,p_payroll_consolidation_set       => l_consolidation_set_condition
,p_order_by                       => l_order_by
);


--
-- Frame the statement for query.
--

l_statement :=
'select
  ppf.person_id person_id,
  ppf.full_name full_name,
  ppf.employee_number employee_number,
  fnd_date.date_to_displaydate(ppa.effective_date) effective_date,
  ppa.action_type action_type,
  paa.assignment_action_id action_number,
  paf.assignment_number assignment_number,
  pay.payroll_name payroll_name,
  pcs.consolidation_set_name consolidation_set_name

 from
  pay_consolidation_sets pcs,
  pay_all_payrolls_f pay,
  per_all_people_f ppf,
  per_all_assignments_f paf,
  pay_assignment_actions paa,
  pay_payroll_actions ppa

where ' || l_payroll_action_condition ||
  ' and ppa.effective_date between :1 and :2
  and ppa.business_group_id = :3
  and paa.payroll_action_id = ppa.payroll_action_id
  and paf.assignment_id = paa.assignment_id
  and ppf.person_id = paf.person_id
  and ' || l_consolidation_set_condition ||
  ' and ppa.effective_date between paf.effective_start_date
                             and paf.effective_end_date
  and ppa.effective_date between ppf.effective_start_date
                             and ppf.effective_end_date
  and ppa.effective_date between pay.effective_start_date
                             and pay.effective_end_date
  and not exists(
            select null
              from pay_action_interlocks pai,
                   pay_assignment_actions paa_lock,
                   pay_payroll_actions ppa_lock
             where pai.locked_action_id = paa.assignment_action_id
                                          /* Action from main Query */
               and pai.locking_action_id = paa_lock.assignment_action_id
               and ppa_lock.payroll_action_id = paa_lock.payroll_action_id
               and ' ||  l_locking_payroll_condition || ' ) order by ' || l_order_by;



dbms_lob.createtemporary(g_xml_data,false,dbms_lob.call);
dbms_lob.open(g_xml_data,dbms_lob.lob_readwrite);

l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';
dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

l_tag := '<PAYRPANP>';
dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

l_tag := '<LIST_G_PERSON_ID>';
dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);


l_session_date     := fnd_date.canonical_to_date(p_session_date_char);
l_start_date       := fnd_date.canonical_to_date(p_start_date_char);
l_end_date         := fnd_date.canonical_to_date(p_end_date_char);


cf_record_counter := 0;

open csr_report_data for l_statement using l_start_date,l_end_date,p_business_group_id,
                                           p_payroll_id,p_consolidation_set_id;

loop

    fetch csr_report_data into l_report_data;
    exit when csr_report_data%notfound;

    cf_record_counter := cf_record_counter + 1;

    cf_action_type := get_action_type(l_report_data.action_type);

    l_tag := '<G_PERSON_ID>';
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

    append_group_data(
                        l_report_data.consolidation_set_name
		       ,l_report_data.payroll_name
		       ,l_report_data.effective_date
		       ,l_report_data.assignment_number
		       ,l_report_data.action_type
		       ,l_report_data.action_number
		       ,l_report_data.person_id
		       ,l_report_data.full_name
		       ,l_report_data.employee_number
		       ,cf_action_type
		       ,cf_record_counter
		       );


    l_tag := '</G_PERSON_ID>';
    dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

end loop;
close csr_report_data;

l_tag := '</LIST_G_PERSON_ID>';
dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

--
--
--
open c_report_mode(p_mode);
fetch c_report_mode into l_mode_desc;
close c_report_mode;

append_parameters_data(
                       l_consolidation_set_name
                      ,l_payroll_name
		      ,l_business_group_name
		      ,cf_record_counter
		      ,p_report_name
		      ,l_mode_desc
		      ,fnd_date.date_to_displayDT(SysDate)
		      ,l_start_date
		      ,l_end_date
		      ,l_template_name
		      );

l_tag := '</PAYRPANP>';
dbms_lob.writeappend(g_xml_data, length(l_tag), l_tag);

p_xml := g_xml_data;

end actions_not_processed;


end PAY_PAYRPANP_XML_PKG;

/
