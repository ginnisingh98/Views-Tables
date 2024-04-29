--------------------------------------------------------
--  DDL for Package Body PER_DATA_UPDATE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DATA_UPDATE_REPORT" AS
/* $Header: perdtupr.pkb 120.15 2006/09/08 17:33:44 jabubaka noship $ */
summCtr NUMBER;
critCtr NUMBER;
vCtr NUMBER;

FUNCTION get_parameter_value(f_parameter_name IN varchar2,
                             f_upgrade_definition_id IN number) return varchar2
is
  cursor csr_get_parameter_value(f_parameter_name varchar2,
                                 f_upgrade_definition_id number) is
  select parameter_value
    from pay_upgrade_parameters
   where parameter_name = f_parameter_name
     and upgrade_definition_id = f_upgrade_definition_id;

l_parameter_value pay_upgrade_parameters.parameter_value%type;

begin
   open  csr_get_parameter_value(f_parameter_name, f_upgrade_definition_id);
   fetch csr_get_parameter_value into l_parameter_value;
   if (csr_get_parameter_value%NOTFOUND) then
      l_parameter_value := null;
   end if;
   close csr_get_parameter_value;
   return l_parameter_value;
end get_parameter_value;

PROCEDURE DATA_REPORT_INITIATE (p_request_id number,
                                p_report_content varchar2,
				p_importance varchar2,
				p_product varchar2,
				p_template_name varchar2,
				p_xml OUT NOCOPY BLOB) AS
   begin
	 POPULATE_REPORT_DATA(p_request_id,
	                      p_report_content,
			      p_importance,
			      p_product,
			      p_xml);
end DATA_REPORT_INITIATE;

PROCEDURE POPULATE_REPORT_DATA(p_request_id number,
                               p_report_content varchar2,
                               p_importance varchar2,
                               p_product varchar2,
                               l_xfdf_blob OUT NOCOPY BLOB) AS
--                               p_output_fname out nocopy varchar2) IS
cursor c_processes is
 select name process_name
 from   pay_upgrade_definitions_tl
 where  language = userenv('LANG');


cursor c_get_process_data is
  select
        pud.upgrade_definition_id upgrade_definition_id,
        pudt.NAME             process_name,
        pud.LEGISLATION_CODE  legislation_code,
        pud.DESCRIPTION       description,
        decode(pud.UPGRADE_LEVEL,'B','Business Group',
                                 'L', 'Legislation',
                                 'G', 'Global') upgrade_level,
        pud.CRITICALITY       criticality_code,
        decode(pud.CRITICALITY, 'C', 'Critical',
                                'R', 'Recommended',
                                'O', 'Optional') criticality,
        decode(pud.criticality, 'C', 1, 'R', 2, 'O', 3) criticality_sort,
        pud.THREADING_LEVEL   threading_level,
        pud.FAILURE_POINT     failure_point,
        pud.LEGISLATIVELY_ENABLED legislatively_enabled,
        pud.UPGRADE_METHOD    upgrade_method,
        pud.UPGRADE_PROCEDURE upgrade_procedure,
        pud.QUALIFYING_PROCEDURE qualifying_procedure,
        app.DESCRIPTION       application_name,
        pud.VALIDATE_CODE     validate_code,
        pud.FIRST_PATCHSET    introduced,
        pud.ADDITIONAL_INFO   additional_info
from    pay_upgrade_definitions_tl pudt,
        pay_upgrade_definitions    pud,
        fnd_application_vl         app
where   pud.owner_application_id = app.application_id (+)
and     pudt.upgrade_definition_id = pud.upgrade_definition_id
and     ((pud.first_patchset like '%' || p_product || '%')
or      (p_product is null))
and     instr(p_importance, pud.criticality) > 0
and     pudt.language = userenv('LANG')
order   by criticality_sort, pudt.name;

cursor c_get_legislation_code(lg_upgrade_definition_id number) is
  select pul.legislation_code
    from pay_upgrade_legislations pul
   where pul.upgrade_definition_id = lg_upgrade_definition_id;

cursor c_execution_status(lp_upgrade_definition_id number) is
  select pus.legislation_code  status_leg_code,
         bus.name              status_bg_name,
         decode(pus.status, 'C', 'Complete',
                            'P', 'Processing') status,
         pus.executed          executed,
         pus.request_id        request_id
    from pay_upgrade_status    pus,
         per_business_groups   bus
   where pus.upgrade_definition_id = lp_upgrade_definition_id
     and pus.business_group_id     = bus.business_group_id (+);

cursor c_detect_status (p_upgrade_definition_id number) is
       select upgrade_definition_id
         from pay_upgrade_status
        where upgrade_definition_id = p_upgrade_definition_id;

cursor c_profile_option_name (p_config_option_name varchar2) is
  select user_profile_option_name
    from fnd_profile_options_vl
   where profile_option_name = p_config_option_name;

l_xfdf_string            CLOB;
l_c_data_start           varchar2(10);
l_c_data_end             varchar2(5);
l_content_both           varchar2(30);
l_content_summary        varchar2(30);
l_content_detail         varchar2(30);
l_critCodeCShown         boolean;
l_critCodeRShown         boolean;
l_critCodeOShown         boolean;
l_database_name          varchar2(10);
l_process_name           pay_upgrade_definitions_tl.name%type;
l_legislation_code       pay_upgrade_definitions.legislation_code%type;
l_enabled_leg_code       varchar2(150);
l_required               varchar2(10);
l_prepatch               varchar2(10);
l_inpatch                varchar2(10);
l_postpatch              varchar2(10);
l_when_to_run            varchar2(10);
l_exec_config_option     varchar2(30);
l_configurable           varchar2(10);
l_config_option_name     varchar2(80);
l_option_name            varchar2(80);
l_execution_point        varchar2(80);
l_exec_lookup_type       varchar2(80);
l_exec_status            varchar2(10);
l_status_leg_code        pay_upgrade_status.legislation_code%type;
l_status_bg_name         per_business_groups.name%type;
l_status                 pay_upgrade_status.status%type;
l_executed               varchar2(10);
l_leg_code_rows          number;
l_lookup_execution_point varchar2(10);
l_lookup_no              varchar2(10);
l_lookup_yes             varchar2(10);
l_request_id             pay_upgrade_status.request_id%type;
l_rows_found             boolean;
l_sql                    varchar2(400);
l_str_start              varchar2(100);
l_str_dbname             varchar2(100);
l_str_execution_date     varchar2(100);
l_str_process_name       varchar2(100);
l_str_legislation_code   varchar2(100);
l_str_enabled_leg_code   varchar2(100);
l_str_upgrade_level      varchar2(100);
l_str_required           varchar2(100);
l_str_exec_status        varchar2(100);
l_str_introduced         varchar2(100);
l_str_criticality        varchar2(100);
l_str_criticality_code   varchar2(100);
l_str_prepatch           varchar2(100);
l_str_inpatch            varchar2(100);
l_str_postpatch          varchar2(100);
l_str_configurable       varchar2(100);
l_str_config_option_name varchar2(100);
l_str_execution_point    varchar2(100);
l_str_additional_info    varchar2(100);
l_str_g_status           varchar2(100);
l_str_g_process          varchar2(100);
l_str_status_leg_code    varchar2(100);
l_str_status_bg_name     varchar2(100);
l_str_status             varchar2(100);
l_str_executed           varchar2(100);
l_str_request_id         varchar2(100);
l_str_g_summary          varchar2(100);
l_str_open               varchar2(10);
l_str_close              varchar2(10);
l_str_open_end           varchar2(10);
l_status_rows            number;
l_str_list_g_process     varchar2(30);
l_str_list_g_summary     varchar2(30);
l_str_list_g_criticality varchar2(30);
l_str_g_criticality      varchar2(30);
l_strsumm1               varchar2(3000);
l_strsumm2               varchar2(3000);
begin
 l_c_data_start     := '<![CDATA[';
 l_c_data_end       := ']]>';
 l_content_both     := 'BOTH';
 l_content_summary  := 'SUMMARY';
 l_content_detail   := 'DETAIL';
 l_critCodeCShown   := false;
 l_critCodeRShown   := false;
 l_critCodeOShown   := false;
 l_executed         := l_lookup_no;
 l_exec_status      := l_lookup_no;
 l_leg_code_rows    := 0;
 l_lookup_yes       := hr_general.decode_lookup('YES_NO','Y');
 l_lookup_no        := hr_general.decode_lookup('YES_NO','N');
 l_rows_found       := false;
 l_str_dbname       := 'DBNAME';
 l_str_execution_date   := 'EXECUTION_DATE';
 l_str_process_name     := 'PROCESS_NAME';
 l_str_legislation_code := 'LEGISLATION_CODE';
 l_str_enabled_leg_code := 'ENABLED_LEG_CODE';
 l_str_upgrade_level := 'UPGRADE_LEVEL';
 l_str_required     := 'REQUIRED';
 l_str_exec_status  := 'EXEC_STATUS';
 l_str_introduced   := 'INTRODUCED';
 l_str_criticality  := 'CRITICALITY';
 l_str_criticality_code  := 'CRITICALITY_CODE';
 l_str_prepatch     := 'PREPATCH';
 l_str_inpatch      := 'INPATCH';
 l_str_postpatch    := 'POSTPATCH';
 l_str_configurable := 'CONFIGURABLE';
 l_str_config_option_name := 'CONFIG_OPTION_NAME';
 l_str_execution_point := 'EXECUTION_POINT';
 l_str_additional_info := 'ADDITIONAL_INFO';
 l_str_status_leg_code := 'STATUS_LEG_CODE';
 l_str_status_bg_name := 'STATUS_BG_NAME';
 l_str_status       := 'STATUS';
 l_str_executed     := 'EXECUTED';
 l_str_request_id   := 'REQUEST_ID';
 l_str_start        := 'START';
 l_str_g_summary    := 'G_SUMMARY';
 l_str_list_g_summary := 'LIST_G_SUMMARY';
 l_str_list_g_criticality := 'LIST_G_CRITICALITY';
 l_str_list_g_process := 'LIST_G_PROCESS';
 l_str_g_process      := 'G_PROCESS';
 l_str_g_status       := 'G_STATUS';
 l_str_g_criticality  := 'G_CRITICALITY';
--
dbms_lob.createtemporary(l_xfdf_string, FALSE, DBMS_LOB.CALL);
dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
dbms_lob.createtemporary(l_xfdf_blob,TRUE);
hr_xml_pub_utility.clob_to_blob(l_xfdf_string,l_xfdf_blob);
--
--
  dt_fndate.set_effective_date(trunc(sysdate));
--
-- Initialise counters for the XMLTables
--
  PER_DATA_UPDATE_REPORT.summXMLTable.DELETE;
  summCtr:=0;
  PER_DATA_UPDATE_REPORT.critXMLTable.DELETE;
  critCtr:=0;
  PER_DATA_UPDATE_REPORT.vXMLTable.DELETE;
  vCtr:=0;
--
-- <LIST_G_SUMMARY>
--
if p_report_content in (l_content_summary, l_content_both) then
  PER_DATA_UPDATE_REPORT.summXMLTable(summCtr).TagValue := '<' || l_str_list_g_summary || '>' ;
  summCtr:=summCtr+1;
end if;
--
-- <LIST_G_CRITICALITY>
--
if p_report_content in (l_content_detail, l_content_both) then
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_list_g_criticality || '>';
  critCtr:=critCtr+1;
end if;
--
-- retrieve the processes
--
 for l_cursor_get_data in c_get_process_data
 --
 loop
 --
 l_rows_found := true;
 --
 -- REQUIRED
 -- dynamic sql to retrieve result of the code.
 --
  declare
  skip_sub_block exception;
  begin
    begin
    --
      if l_cursor_get_data.validate_code is not null then
        l_sql := 'begin ' || l_cursor_get_data.validate_code || '(:x); end;';
    --
        execute immediate l_sql
                using out l_required;
        if l_required    = 'TRUE'  then
          l_required := l_lookup_yes;
        elsif l_required = 'FALSE' then
          l_required := l_lookup_no;
        end if;
      else
        l_required := 'Undefined';
      end if;
    --
    exception
    when others then
      l_required := 'Error';
      raise skip_sub_block;
    end;

  exception
    when skip_sub_block then null;
  end;
--
if p_report_content in (l_content_summary, l_content_both) then
   -- <G_SUMMARY>
   PER_DATA_UPDATE_REPORT.summXMLTable(summCtr).TagValue := '<' || l_str_g_summary || '>';
   summCtr:=summCtr+1;
   -- <PROCESS_NAME>
   PER_DATA_UPDATE_REPORT.summXMLTable(summCtr).TagValue := '<' || l_str_process_name || '>' || l_c_data_start || l_cursor_get_data.process_name || l_c_data_end || '</' || l_str_process_name || '>';
   summCtr:=summCtr+1;
   -- <UPGRADE_LEVEL>
   PER_DATA_UPDATE_REPORT.summXMLTable(summCtr).TagValue := '<' || l_str_upgrade_level || '>' || l_cursor_get_data.upgrade_level || '</' || l_str_upgrade_level || '>';
   summCtr:=summCtr+1;
   -- <REQUIRED>
   PER_DATA_UPDATE_REPORT.summXMLTable(summCtr).TagValue := '<' || l_str_required || '>' || l_required || '</' || l_str_required || '>';
   summCtr:=summCtr+1;
   -- <EXEC_STATUS>
   open c_detect_status(l_cursor_get_data.upgrade_definition_id);
   fetch c_detect_status into l_status_rows;
   if c_detect_status%FOUND then
     l_exec_status := l_lookup_yes;
   else
     l_exec_status := l_lookup_no;
   end if;
   close c_detect_status;
   PER_DATA_UPDATE_REPORT.summXMLTable(summCtr).TagValue := '<' || l_str_exec_status || '>' || l_exec_status || '</' || l_str_exec_status || '>';
   summCtr:=summCtr+1;
   -- <INTRODUCED>
   PER_DATA_UPDATE_REPORT.summXMLTable(summCtr).TagValue := '<' || l_str_introduced || '>' || l_cursor_get_data.introduced || '</' || l_str_introduced || '>';
   summCtr:=summCtr+1;
   -- <CRITICALITY>
   PER_DATA_UPDATE_REPORT.summXMLTable(summCtr).TagValue := '<' || l_str_criticality || '>' || l_cursor_get_data.criticality || '</' || l_str_criticality || '>';
   summCtr:=summCtr+1;
 end if;
 --
if p_report_content in (l_content_detail, l_content_both) then
  --
  -- </LIST_G_PROCESS>
  -- </G_CRITICALLY>
  --
  -- <CRITICALITY_CODE>
  -- <LIST_G_PROCESS>
  --
  if (l_cursor_get_data.criticality_code    = 'C') and
     not l_critCodeCShown then
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_g_criticality || '>';
    critCtr:=critCtr+1;
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_criticality_code || '>' || l_cursor_get_data.criticality_code  || '</' || l_str_criticality_code || '>';
    critCtr:=critCtr+1;
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_list_g_process || '>';
    critCtr:=critCtr+1;
    l_critCodeCShown := true;
  end if;
  if (l_cursor_get_data.criticality_code = 'R') and
     not l_critCodeRShown then
    if l_critCodeCShown then
      PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '</' || l_str_list_g_process  || '>';
      critCtr:=critCtr+1;
      PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '</' || l_str_g_criticality || '>';
      critCtr:=critCtr+1;
      PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_g_criticality || '>';
      critCtr:=critCtr+1;
    else
      PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_g_criticality || '>';
      critCtr:=critCtr+1;
    end if;
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_criticality_code || '>' || l_cursor_get_data.criticality_code  || '</' || l_str_criticality_code || '>';
    critCtr:=critCtr+1;
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_list_g_process  || '>';
    critCtr:=critCtr+1;
    l_critCodeRShown := true;
  end if;
  if (l_cursor_get_data.criticality_code = 'O') and
    not l_critCodeOShown then
    if l_critCodeRShown or l_critCodeCShown then
      PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '</' || l_str_list_g_process  || '>';
      critCtr:=critCtr+1;
      PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '</' || l_str_g_criticality || '>';
      critCtr:=critCtr+1;
      PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_g_criticality || '>';
      critCtr:=critCtr+1;
    else
      PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_g_criticality || '>';
      critCtr:=critCtr+1;
    end if;
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_criticality_code || '>' || l_cursor_get_data.criticality_code  || '</' || l_str_criticality_code || '>';
    critCtr:=critCtr+1;
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_list_g_process  || '>';
    critCtr:=critCtr+1;
    l_critCodeOShown := true;
  end if;
 --
 -- <G_PROCESS>
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_g_process  || '>';
    critCtr:=critCtr+1;
 --
 -- derivation of Detailed Report Fields
 --
 -- ENABLED_LEG_CODE
 --
l_leg_code_rows := 0;
l_enabled_leg_code := null;
--
if (l_cursor_get_data.legislation_code is null) and
   (l_cursor_get_data.legislatively_enabled = 'Y') then
  --
  for l_cursor_get_leg in c_get_legislation_code(l_cursor_get_data.upgrade_definition_id)
  --
  loop
    if l_leg_code_rows > 0 then
      l_enabled_leg_code := l_enabled_leg_code || ','
                            || l_cursor_get_leg.legislation_code;
    else
      l_enabled_leg_code := l_enabled_leg_code || l_cursor_get_leg.legislation_code;
    end if;
    l_leg_code_rows := l_leg_code_rows+1;
  end loop;
end if;
--
if l_leg_code_rows = 0 then
  l_enabled_leg_code := 'N/A';
end if;

  --
  -- PREPATCH
  --
  l_prepatch  := get_parameter_value('CAN_RUN_PRE_PATCH',
                 l_cursor_get_data.upgrade_definition_id);
  if l_prepatch = 'Y' then
       l_prepatch := l_lookup_yes;
  else l_prepatch := l_lookup_no;
  end if;
  --
  -- INPATCH
  --
  l_inpatch   := get_parameter_value('CAN_RUN_IN_PATCH',
                 l_cursor_get_data.upgrade_definition_id);
  if l_inpatch = 'Y' then
     l_inpatch := l_lookup_yes;
  else l_inpatch := l_lookup_no;
  end if;
  --
  -- POSTPATCH
  --
  l_postpatch := get_parameter_value('CAN_RUN_POST_PATCH',
                 l_cursor_get_data.upgrade_definition_id);
  if l_postpatch = 'Y' then
     l_postpatch := l_lookup_yes;
  else l_postpatch := l_lookup_no;
  end if;
  --
  -- WHEN_TO_RUN
  --
  l_when_to_run := nvl(get_parameter_value('WHEN_TO_RUN',
                   l_cursor_get_data.upgrade_definition_id),
                   'N/A');
  --
  -- EXEC_CONFIG_OPTION
  --
  l_exec_config_option := nvl(get_parameter_value('EXEC_CONFIG_OPTION',
                            l_cursor_get_data.upgrade_definition_id),
                            'N/A');
  --
  -- CONFIGURABLE
  --
  if (l_when_to_run = 'N/A') and (l_exec_config_option = 'N/A')
    then l_configurable := l_lookup_no;
  else l_configurable := l_lookup_yes;
  end if;
  --
  -- CONFIG_OPTION_NAME
  --
  l_option_name := l_exec_config_option;
  --
  --
  -- EXECUTION_POINT
  --
  l_execution_point := null;
  --
  if (l_option_name <> 'N/A') then
   -- config option name
   open c_profile_option_name(l_option_name);
   fetch c_profile_option_name into l_config_option_name;
   if c_profile_option_name%NOTFOUND then
     l_config_option_name := l_option_name;
   end if;
   close c_profile_option_name;
   -- exec_lookup_type
   l_exec_lookup_type := nvl(get_parameter_value('EXEC_LOOKUP_TYPE',
                            l_cursor_get_data.upgrade_definition_id),
                            'N/A');
   if l_exec_lookup_type = 'N/A' then
   -- no EXEC_LOOKUP_TYPE parameter found so return internal value
     fnd_profile.get(l_option_name, l_execution_point);
     l_execution_point := nvl(l_execution_point,'N/A');
   else
   -- an EXEC_LOOKUP_TYPE parameter was found so derive lookup value
   -- for the profile option and meaning
     fnd_profile.get(l_option_name, l_lookup_execution_point);
     l_execution_point := nvl(hr_general.decode_lookup(l_exec_lookup_type,
                              l_lookup_execution_point), l_lookup_execution_point);
   end if;
   --
  else
   l_config_option_name := l_option_name;
  end if;
  -- <UPGRADE_LEVEL>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_upgrade_level || '>' || l_cursor_get_data.upgrade_level || '</' || l_str_upgrade_level || '>';
  critCtr:=critCtr+1;
  -- <CRITICALITY>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_criticality || '>' || l_cursor_get_data.criticality || '</' || l_str_criticality || '>';
  critCtr:=critCtr+1;
  -- <PROCESS_NAME>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_process_name || '>' || l_c_data_start ||  l_cursor_get_data.process_name || l_c_data_end  || '</' || l_str_process_name || '>';
  critCtr:=critCtr+1;
  -- <LEGISLATION_CODE>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_legislation_code || '>' || l_cursor_get_data.legislation_code || '</' || l_str_legislation_code || '>';
  critCtr:=critCtr+1;
  -- <ENABLED_LEG_CODE>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_enabled_leg_code || '>' || l_enabled_leg_code || '</' || l_str_enabled_leg_code || '>' ;
  critCtr:=critCtr+1;
  -- <REQUIRED>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_required || '>' || l_required || '</' || l_str_required || '>';
  critCtr:=critCtr+1;
  -- <PREPATCH>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_prepatch || '>' || l_prepatch || '</' || l_str_prepatch || '>';
  critCtr:=critCtr+1;
  -- <INPATCH>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_inpatch || '>' || l_inpatch || '</' || l_str_inpatch || '>';
  critCtr:=critCtr+1;
  -- <POSTPATCH>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_postpatch || '>' || l_postpatch || '</' || l_str_postpatch || '>';
  critCtr:=critCtr+1;
  -- <CONFIGURABLE>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_configurable || '>' || l_configurable || '</' || l_str_configurable || '>';
  critCtr:=critCtr+1;
  -- <CONFIG_OPTION_NAME>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_config_option_name || '>' || l_c_data_start || l_config_option_name || l_c_data_end || '</' || l_str_config_option_name || '>';
  critCtr:=critCtr+1;
  -- <EXECUTION_POINT>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_execution_point || '>' || l_execution_point || '</' || l_str_execution_point || '>';
  critCtr:=critCtr+1;
  -- <INTRODUCED>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_introduced || '>' || l_cursor_get_data.introduced || '</' || l_str_introduced || '>';
  critCtr:=critCtr+1;
  -- <ADDITIONAL_INFO>
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_additional_info || '>' || l_c_data_start || l_cursor_get_data.additional_info || l_c_data_end || '</' || l_str_additional_info || '>';
  critCtr:=critCtr+1;
  -----------  STATUS SECTION ---------------------------------------------
  for l_cursor_status_data in c_execution_status(l_cursor_get_data.upgrade_definition_id)
  loop
    -- <G_STATUS>
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_g_status || '>';
    critCtr:=critCtr+1;
    -- <STATUS_LEG_CODE>
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_status_leg_code || '>' || l_cursor_status_data.status_leg_code || '</' || l_str_status_leg_code || '>';
    critCtr:=critCtr+1;
    -- <STATUS_BG_NAME>
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_status_bg_name || '>' || l_c_data_start || nvl(l_cursor_status_data.status_bg_name,'N/A') || l_c_data_end || '</' || l_str_status_bg_name || '>';
    critCtr:=critCtr+1;
    -- <STATUS>
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_status || '>' || l_cursor_status_data.status || '</' || l_str_status || '>';
    critCtr:=critCtr+1;
    -- <EXECUTED>
    if l_cursor_status_data.executed = 'Y'
    then l_executed := l_lookup_yes;
    else l_executed := l_lookup_no;
    end if;
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_executed || '>' || l_executed || '</' || l_str_executed || '>';
    critCtr:=critCtr+1;
    -- <REQUEST_ID>
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '<' || l_str_request_id || '>' || to_char(l_request_id) || '</' || l_str_request_id || '>';
    critCtr:=critCtr+1;
    -- </G_STATUS>
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '</' || l_str_g_status || '>';
    critCtr:=critCtr+1;
  end loop;----  for each status


PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '</' || l_str_g_process || '>';
critCtr:=critCtr+1;

end if;
--
-- <G_SUMMARY>
if p_report_content in (l_content_summary, l_content_both) then
   PER_DATA_UPDATE_REPORT.summXMLTable(summCtr).TagValue := '</' || l_str_g_summary || '>';
   summCtr:=summCtr+1;
end if;

end loop; -- for each process
--
-- </LIST G_PROCESS>
-- </G_CRITICALITY>
-- </LIST_G_CRITICALITY>
--
if p_report_content in (l_content_detail, l_content_both) then
  if l_rows_found then
    PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '</' || l_str_list_g_process || '>';
    critCtr:=critCtr+1;
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '</' || l_str_g_criticality || '>';
  critCtr:=critCtr+1;
  end if;
  PER_DATA_UPDATE_REPORT.critXMLTable(critCtr).TagValue := '</' || l_str_list_g_criticality ||  '>';
  critCtr:=critCtr+1;
end if;
--
-- </LIST_G_SUMMARY>
--
if p_report_content in (l_content_summary, l_content_both) then
  PER_DATA_UPDATE_REPORT.summXMLTable(summCtr).TagValue := '</LIST_G_SUMMARY>';
  summCtr:=summCtr+1;
end if;

/*
-- Options for writing
-- 1. Write from XML Table to XML file
--
 WritetoXML(p_output_fname);
--
*/

-- 2. Write from XML Table to BLOB
-- Writing to a BLOB
--
-- <START>
--
  dbms_lob.writeAppend(l_xfdf_string, length('<' || l_str_start || '>'),
                               '<' || l_str_start || '>');
--
-- <DBNAME> DATABASE NAME </DBNAME>
--
  select name into l_database_name from v$database;
  dbms_lob.writeAppend(l_xfdf_string,
                 length('<DBNAME>' || l_database_name || '</DBNAME>'),
                       '<DBNAME>' || l_database_name || '</DBNAME>');
--
-- derive SUMMARY information
--
IF summXMLTable.count > 0 then
FOR ctr_summ_table in summXMLTable.FIRST .. summXMLTable.LAST LOOP
  l_strsumm1 := summXMLTable(ctr_summ_table).TagValue;
  dbms_lob.writeAppend(l_xfdf_string,
           length(l_strsumm1),
                  l_strsumm1);
END LOOP;
END IF;
--
-- derive CRITICALITY information
--
IF critXMLTable.count > 0 then
FOR ctr_crit_table in critXMLTable.FIRST .. critXMLTable.LAST LOOP
  l_strsumm2 := critXMLTable(ctr_crit_table).TagValue;
  dbms_lob.writeAppend(l_xfdf_string,
           length(l_strsumm2),
                  l_strsumm2);
END LOOP;
END IF;
--
-- </START>
dbms_lob.writeAppend(l_xfdf_string,length('</' || l_str_start || '>'),
                                          '</' || l_str_start || '>');
--
DBMS_LOB.CREATETEMPORARY(l_xfdf_blob, TRUE);
hr_xml_pub_utility.clob_to_blob(l_xfdf_string, l_xfdf_blob);
--
end POPULATE_REPORT_DATA;

PROCEDURE WritetoXML (
        p_output_fname out nocopy varchar2)
IS
        p_l_fp UTL_FILE.FILE_TYPE;
        l_audit_log_dir varchar2(500);
        l_file_name varchar2(50);
        l_check_flag number;
        l_database_name varchar2(10);
BEGIN
        l_audit_log_dir := '/sqlcom/outbound';
-----------------------------------------------------------------------------
        -- Writing into XML File
-----------------------------------------------------------------------------
        -- Assigning the File name.
        l_file_name :=  'KK' || to_char(sysdate,'HH24:MI:SS') ||'.xml';
        -- Getting the Util file directory name.mostly it'll be /sqlcom/outbound )
        BEGIN
                SELECT value
                INTO l_audit_log_dir
                FROM v$parameter
                WHERE LOWER(name) = 'utl_file_dir';
                -- Check whether more than one util file directory is found
                IF INSTR(l_audit_log_dir,',') > 0 THEN
                   l_audit_log_dir := substr(l_audit_log_dir,1,instr(l_audit_log_dir,',')-1);
                END IF;
        EXCEPTION
                when no_data_found then
              null;
        END;
        -- Find out whether the OS is MS or Unix based
        -- If it's greater than 0, it's unix based environment
        IF INSTR(l_audit_log_dir,'/') > 0 THEN
                p_output_fname := l_audit_log_dir || '/' || l_file_name;
        ELSE
        p_output_fname := l_audit_log_dir || '\' || l_file_name;
        END IF;
        -- getting Agency name
        p_l_fp := utl_file.fopen(l_audit_log_dir,l_file_name,'A');
        -- Writing from and to dates
--
--
-- <START>
--
  PER_DATA_UPDATE_REPORT.vXMLTable(vCtr).TagValue := '<START>';
  vCtr:=vCtr+1;
--
-- <DBNAME>
--
  select name into l_database_name from v$database;
  PER_DATA_UPDATE_REPORT.vXMLTable(vCtr).TagValue := '<DBNAME>' || l_database_name || '</DBNAME>';
  vCtr:=vCtr+1;
--
-- SUMMARY LISTINGS
--
        IF summXMLTable.count > 0 then
          FOR ctr_summ_table IN summXMLTable.FIRST .. summXMLTable.LAST LOOP
            PER_DATA_UPDATE_REPORT.vXMLTable(vCtr).TagValue := summXMLTable(ctr_summ_table).TagValue;
            vCtr:=vCtr+1;
          END LOOP;
        END IF;
--
-- CRITICALITY LISTINGS
--
        IF critXMLTable.count > 0 then
          FOR ctr_crit_table IN critXMLTable.FIRST .. critXMLTable.LAST LOOP
            PER_DATA_UPDATE_REPORT.vXMLTable(vCtr).TagValue := critXMLTable(ctr_crit_table).TagValue;
            vCtr:=vCtr+1;
          END LOOP;
        END IF;
--
-- </START>
--
  PER_DATA_UPDATE_REPORT.vXMLTable(vCtr).TagValue := '</START>';
  vCtr:=vCtr+1;
-- Write to XML
--
        IF vXMLTable.count > 0 then
          FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
            WriteXMLvalues(p_l_fp,vXMLTable(ctr_table).TagValue);
          END LOOP;
        END IF;
        utl_file.fclose(p_l_fp);
END WritetoXML;
------------------------------------------------------------------
PROCEDURE WriteXMLvalues( p_l_fp utl_file.file_type, p_value IN VARCHAR2) IS
BEGIN
        utl_file.put_line(p_l_fp, p_value );
null;
END WriteXMLvalues;
------------------------------------------------------------------
procedure fetch_rtf_blob
  (p_rtf_blob OUT NOCOPY blob)
IS
BEGIN
select file_data
into p_rtf_blob
from fnd_lobs
where file_name like '%/per/11.5.0/patch/115/publisher/templates/PERDTUPR.rtf';
EXCEPTION
when no_data_found then
     null;
END fetch_rtf_blob;


end PER_DATA_UPDATE_REPORT;

/
