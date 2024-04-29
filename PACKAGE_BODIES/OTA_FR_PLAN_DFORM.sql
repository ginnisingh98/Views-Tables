--------------------------------------------------------
--  DDL for Package Body OTA_FR_PLAN_DFORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FR_PLAN_DFORM" AS
/* $Header: otafrpdf.pkb 120.0.12010000.1 2008/10/14 06:31:50 parusia noship $ */
--
g_convert_to_utf8  boolean;
---------------------------------------------------
-- Main procedure for building XML string
------------------------------------------------------
PROCEDURE pdf_main_fill_table(p_business_group_id NUMBER,
                               p_company_id       NUMBER DEFAULT NULL,
                               p_estab_id         NUMBER DEFAULT NULL,
                               p_calendar         VARCHAR2,
                               p_time_period_id   NUMBER,
                               p_consolidate      VARCHAR2,
			       p_training_plan_id NUMBER DEFAULT NULL,
			       p_list_events      VARCHAR2,
			       p_template_name    VARCHAR2, -- added to match parameters with CP
			       p_xml OUT NOCOPY CLOB)
IS
--
l_tp_select varchar2(150);
l_tp_from varchar2(150);
l_tp_where varchar2(300);
l_tp_order varchar2(50);
l_organization_where varchar2(200);
l_organization_from varchar2(100);
l_where_tplan varchar2(100);
l_sql varchar2(1500);
--
l_plan_id number;
l_plan_name ota_training_plans.name%TYPE;
l_org_name hr_organization_units.name%TYPE;
l_period_from varchar2(25);
l_period_to varchar2(25);
l_budget_level varchar2(20);
--
l_total_delg_member number;
l_act_number_evt number;
l_act_duration_evt number;
l_act_total_duration number;
--
l_evt_number number;
l_total_evt_duration_hours number;
l_evt_duration_hours number;
l_evt_duration_per_delg number;
l_evt_delegates number;
--
l_act_total_class number;
l_act_class_duration number;
--
-- Cursor to choose training plan members
Cursor csr_plan_members(c_training_plan_id number) IS
select course_tl.version_name      member_name
      ,course.activity_version_id  member_id
      ,course_tl.description       member_description
      ,'ACTIVITY_VERSION'          member_level
from ota_activity_versions course,
     ota_activity_versions_tl course_tl
where course.activity_version_id = course_tl.activity_version_id(+)
and   course_tl.language(+) = userenv('LANG')
and exists
       (select null
        from ota_training_plan_members tpm
        where tpm.training_plan_id = c_training_plan_id
        and tpm.activity_version_id = course.activity_version_id
        and tpm.member_status_type_id <> 'CANCELLED')
union
select category_tl.name           member_name
      ,category.activity_id       member_id
      ,category_tl.description    member_description
      ,'ACTIVITY_DEFINITION' member_level
from ota_activity_definitions category,
     ota_activity_definitions_tl category_tl
where category.activity_id = category_tl.activity_id(+)
and     category_tl.language(+) = userenv('LANG')
and exists
       (select null
        from ota_training_plan_members tpm
        where tpm.training_plan_id = c_training_plan_id
        and tpm.activity_definition_id = category.activity_id
        and tpm.member_status_type_id <> 'CANCELLED');
--
-- Cursor for delegates per employee category
Cursor csr_delegates_per_catg(c_member_id number,
                              c_member_level varchar2,
                              c_training_plan_id number,
                              c_business_group_id number)IS
select sum(pbv.value) delg_number
      ,ec.lookup_code emp_code
      ,ec.meaning emp_catg
from per_budgets pb,
     per_budget_versions pbr,
     per_budget_values pbv,
     per_budget_elements pbe,
     ota_training_plan_members tpm,
     hr_lookups ec
where pb.unit = 'FR_DELEGATES_PER_CATEGORY'
  and pb.budget_type_code = 'OTA_BUDGET'
  and pb.business_group_id = tpm.business_group_id
  and pb.budget_id = pbr.budget_id
  and pbr.budget_version_id = pbe.budget_version_id
  and pbv.budget_element_id = pbe.budget_element_id
  and pbv.business_group_id = tpm.business_group_id
  and tpm.business_group_id = c_business_group_id
  and pbe.training_plan_member_id = tpm.training_plan_member_id
  and pbe.event_id is null
  and pbe.business_group_id = tpm.business_group_id
  and tpm.training_plan_id = c_training_plan_id
  and decode(c_member_level,
             'ACTIVITY_VERSION', tpm.activity_version_id ,
             'ACTIVITY_DEFINITION', tpm.activity_definition_id) = c_member_id
  and ec.lookup_type = 'FR_EMPLOYEE_CATEGORY'
  and ec.lookup_code = pbv.budget_information1
  group by ec.lookup_code,ec.meaning;
--
-- Cursor for list of events
Cursor csr_event_list (c_member_id number,
                       c_member_level varchar2)IS
select distinct class.event_id  class_id
      ,class_tl.title           class_title
      ,fnd_date.date_to_canonical(class.course_start_date)  class_from
      ,fnd_date.date_to_canonical(class.course_end_date)    class_to
from ota_events class,
     ota_events_tl class_tl,
     ota_activity_versions course
where class.event_id is not null
  and class_tl.event_id = class.event_id
  and class_tl.language(+) = userenv('LANG')
  and class.activity_version_id = course.activity_version_id
  and decode(c_member_level,
             'ACTIVITY_VERSION',course.activity_version_id ,
             'ACTIVITY_DEFINITION',course.activity_id) = c_member_id;
--
-- Cursor for delegates per event per employee category
Cursor csr_evt_delegates_per_catg(c_event_id number,
                            c_member_id number,
                            c_member_level varchar2,
                            c_training_plan_id number,
                            c_business_group_id number) IS
select count(pbv.budget_information1) evt_delg_number
      ,ec.lookup_code evt_emp_code
      ,ec.meaning evt_emp_catg
from per_budgets pb,
     per_budget_versions pbr,
     per_budget_values pbv,
     per_budget_elements pbe,
     ota_training_plan_members tpm,
     hr_lookups ec
where pb.unit = 'FR_DELEGATES_PER_CATEGORY'
  and pb.budget_type_code = 'OTA_BUDGET'
  and pb.business_group_id = tpm.business_group_id
  and pb.budget_id = pbr.budget_id
  and pbr.budget_version_id = pbe.budget_version_id
  and pbv.budget_element_id = pbe.budget_element_id
  and pbv.business_group_id = tpm.business_group_id
  and tpm.business_group_id = c_business_group_id
  and pbe.training_plan_member_id = tpm.training_plan_member_id
  and pbe.event_id = c_event_id
  and pbe.business_group_id = tpm.business_group_id
  and tpm.training_plan_id = c_training_plan_id
  and decode(c_member_level,
             'ACTIVITY_VERSION', tpm.activity_version_id ,
             'ACTIVITY_DEFINITION', tpm.activity_definition_id) = c_member_id
  and ec.lookup_type = 'FR_EMPLOYEE_CATEGORY'
  and ec.lookup_code = pbv.budget_information1
group by ec.lookup_code,ec.meaning;
--
TYPE ref_cursor_type IS REF CURSOR;
ref_csr_training_plan ref_cursor_type;
--
BEGIN
-- Starting to build the XML string
dbms_lob.createtemporary(p_xml, TRUE, dbms_lob.session);
dbms_lob.open(p_xml,dbms_lob.lob_readwrite);
load_xml_declaration(p_xml);
load_xml_label(p_xml,'FIELDS',TRUE);
--
-- Building up the main cursor to fetch training plans and corresponding training plan  values
l_organization_from := '';
--
l_tp_select :='Select tp.training_plan_id, tp.name,org_unit.name, fnd_date.date_to_canonical(period.start_date),fnd_date.date_to_canonical(period.end_date)';
l_tp_from := ' from ota_training_plans tp ,per_time_periods period, hr_organization_units org_unit';
l_tp_where := ' where tp.business_group_id = :p_business_group_id'
             ||' and tp.time_period_id = period.time_period_id'
             ||' and period.time_period_id = :p_time_period_id'
             ||' and period.period_set_name = :p_calendar'
             ||' and org_unit.organization_id = tp.organization_id';
l_tp_order := ' order by tp.name';
--
IF p_company_id is null THEN
   IF p_estab_id is null THEN
      l_organization_where := ' and :p_company_id is null and :p_estab_id is null';
   ELSE
      l_organization_where := ' and :p_company_id is null and tp.organization_id = :p_estab_id';
   END IF;
ELSE
   -- when company is not null
   IF p_estab_id is null THEN
      -- check the p_consolidate flag
      IF p_consolidate = 'N' THEN
         l_organization_where := ' and tp.organization_id = :p_company_id and :p_estab_id is null';
      ELSE
         -- when p_consolidate is 'Y'
         l_organization_from := ', hr_organization_information org_info';
         l_organization_where := ' and tp.organization_id = org_info.organization_id'
          ||' and org_info.org_information1 = fnd_number.number_to_canonical(:p_company_id)'
          ||' and :p_estab_id is null';
         --
      END IF;
   ELSE
      -- if estab is not null
      l_organization_from := ', hr_organization_information org_info';
      l_organization_where := ' and tp.organization_id = org_info.organization_id'
                ||' and org_info.org_information1 = fnd_number.number_to_canonical(:p_company_id)'
                ||' and org_info.organization_id = :p_estab_id';
      --
   END IF;
END IF;
--
IF p_training_plan_id is not null THEN
   l_where_tplan := ' and tp.training_plan_id = :p_training_plan_id';
ELSE
   l_where_tplan := ' and :p_training_plan_id is null';
END IF;
--
l_sql := l_tp_select||l_tp_from||l_organization_from||l_tp_where||l_organization_where||l_where_tplan||l_tp_order;
--
OPEN ref_csr_training_plan FOR  l_sql
  USING p_business_group_id, p_time_period_id,p_calendar, p_company_id, p_estab_id, p_training_plan_id;
LOOP
    FETCH ref_csr_training_plan INTO
                     l_plan_id, l_plan_name, l_org_name, l_period_from, l_period_to;
    EXIT WHEN ref_csr_training_plan%NOTFOUND;
    -- Assign value to training plan label
    load_xml_label(p_xml, 'TRAIN_PLAN', TRUE);
    -- Find the budget level
    l_budget_level:= get_budget_level(p_business_group_id);
    --
    -- Assign value to field tags
    load_xml(p_xml,'plan_name', l_plan_name);
    load_xml(p_xml, 'org_name', l_org_name);
    load_xml(p_xml, 'plan_period_from', l_period_from);
    load_xml(p_xml, 'plan_period_to', l_period_to);
    load_xml(p_xml, 'plan_budget_level', l_budget_level);
    -- Call cursor for plan members
    FOR member_list IN csr_plan_members(l_plan_id) LOOP
        -- Assign value to plan member label
        load_xml_label(p_xml, 'PLAN_MEMBER', TRUE);
        --
        l_total_delg_member := 0;
        -- call csr_delegates_per_catg with type and member id
        FOR count_delg IN csr_delegates_per_catg(member_list.member_id,
                                                 member_list.member_level,
                                                 l_plan_id,
                                                 p_business_group_id)
        LOOP
           -- Calculate total delegates
           l_total_delg_member := l_total_delg_member + count_delg.delg_number;
           -- Assign value to delegates for activity label
           load_xml_label(p_xml, 'ACT_EMP_CATG', TRUE);
           -- Assign value to field tags
           load_xml(p_xml, 'delg_number', count_delg.delg_number);
           load_xml(p_xml, 'emp_catg', count_delg.emp_catg);
           --
           load_xml_label(p_xml, 'ACT_EMP_CATG', FALSE);
        END LOOP;
        --
        l_act_number_evt := get_member_budget_values('FR_NUMBER_EVENTS'
                                                    ,member_list.member_level
                                                    ,member_list.member_id
                                                    ,l_plan_id
                                                    ,p_business_group_id);
        l_act_duration_evt := get_member_budget_values('FR_DURATION_HOURS'
                                                    ,member_list.member_level
                                                    ,member_list.member_id
                                                    ,l_plan_id
                                                    ,p_business_group_id);
        l_act_total_duration := l_total_delg_member * l_act_number_evt * l_act_duration_evt;
        --
        l_evt_number:= 0;
        l_total_evt_duration_hours := 0;
        -- Check if classes are to be listed
        IF p_list_events = 'Y' THEN
           -- Assign value to the entire class label
           load_xml_label(p_xml, 'CLASSES', TRUE);
           -- call csr_event_list with type and member id
           FOR class_details IN csr_event_list(member_list.member_id, member_list.member_level)
           LOOP
              -- Assign value to class list label
              load_xml_label(p_xml, 'EVENT_LIST', TRUE);
              -- Calculate the count by adding each event
              l_evt_number := l_evt_number +1;
              -- call procedure for estimating event level values
              l_evt_duration_per_delg := get_event_duration(class_details.class_id,
                                                            l_plan_id,
                                                            member_list.member_level,
                                                            member_list.member_id,
                                                            p_business_group_id);
              l_evt_delegates := 0;
              -- call csr_evt_det_per_catg
              FOR count_evt_delg IN csr_evt_delegates_per_catg(class_details.class_id,
                                                               member_list.member_id,
                                                               member_list.member_level,
                                                               l_plan_id,
                                                               p_business_group_id)
	      LOOP
	         -- calculate the number of delegates for this event
	         l_evt_delegates := l_evt_delegates +1;
	         -- Assign value to delegates for event label
	         load_xml_label(p_xml, 'EVT_EMP_CATG', TRUE);
	         -- Assign value to field tags
	         load_xml(p_xml, 'evt_delg_number', count_evt_delg.evt_delg_number);
	         load_xml(p_xml, 'evt_emp_catg', count_evt_delg.evt_emp_catg);
	         --
	         load_xml_label(p_xml, 'EVT_EMP_CATG', FALSE);
	      END LOOP;
	      l_evt_duration_hours := l_evt_duration_per_delg * l_evt_delegates;
	      -- Add up the duration
	      l_total_evt_duration_hours := l_total_evt_duration_hours + l_evt_duration_hours;
	      --
	      -- Assign value to field tags
	      load_xml(p_xml, 'class_title', class_details.class_title);
	      load_xml(p_xml, 'course_start_date', class_details.class_from);
	      load_xml(p_xml, 'course_end_date', class_details.class_to);
	      load_xml(p_xml, 'class_duration', l_evt_duration_hours);
	      --
	      load_xml_label(p_xml, 'EVENT_LIST', FALSE);
	      --
           END LOOP; -- event loop
        load_xml_label(p_xml, 'CLASSES', FALSE);
        END IF; -- check for listing classes
        -- Determine values
        IF l_budget_level = 'EVENT' THEN
           l_act_total_class := l_evt_number;
           l_act_class_duration := l_total_evt_duration_hours;
        ELSIF l_budget_level = 'ACTIVITY' THEN
           l_act_total_class := l_act_number_evt;
           l_act_class_duration :=l_act_total_duration;
        END IF;
        -- Assign value to field tags
        load_xml(p_xml, 'member_name', member_list.member_name);
        load_xml(p_xml, 'member_description', member_list.member_description);
        load_xml(p_xml, 'member_total_class', l_act_total_class);
        load_xml(p_xml, 'member_class_duration',l_act_class_duration);
        --
        load_xml_label(p_xml, 'PLAN_MEMBER', FALSE);
    END LOOP; -- member loop
load_xml_label(p_xml, 'TRAIN_PLAN', FALSE);
END LOOP; -- training plan loop
load_xml_label(p_xml,'FIELDS',FALSE);
--
END pdf_main_fill_table;
--------------------------------------------------------------------------
-- Function for retrieving budget level for a training plan
--------------------------------------------------------------------------
FUNCTION get_budget_level(p_business_group_id number) return varchar2 IS
--
l_bl_training_plan varchar2(20);
l_bl_number_events varchar2(20);
l_bl_duration_hours varchar2(20);
l_bl_delegate_per_category varchar2(20);
--
function get_level(p_business_group_id number,
                   p_measurement_code varchar2) return varchar2 is
  --
  l_budget_level varchar2(30);
  --
  cursor csr_budget_level(c_business_group_id number,
                          c_measurement_code varchar2) is
  select budget_level
  from ota_tp_measurement_types
  where business_group_id = p_business_group_id
  and   tp_measurement_code = p_measurement_code;
  --
  begin
    open csr_budget_level(p_business_group_id,p_measurement_code);
    fetch csr_budget_level into l_budget_level;
    if csr_budget_level%notfound then
       l_budget_level := null;
       fnd_message.set_name('OTA','OTA_13878_PDF_BUD_MISSING');
       fnd_file.put_line (fnd_file.LOG, fnd_message.get);
    end if;
    close csr_budget_level;
    --
    return l_budget_level;
  end;
--
BEGIN
  l_bl_number_events := get_level(p_business_group_id, 'FR_NUMBER_EVENTS');
  l_bl_duration_hours := get_level(p_business_group_id, 'FR_DURATION_HOURS');
  l_bl_delegate_per_category := get_level(p_business_group_id, 'FR_DELEGATES_PER_CATEGORY');
  --
  /* If budgeting at the event level the measurement type 'FR_NUMBER_EVENTS'
     will not be defined.  Therefore set :c_bl_number_events to 'EVENT'.
     This will ensure that the before-report trigger error checking does not
     fail because either 1) they all need to be defined at 'ACTIVITY' level
       or 2) Budgeting at Event level so set c_bl_number_event to 'EVENT'
             As they all need to match but at event level this measure is undefined */
  --
  if l_bl_duration_hours = 'EVENT' and
   l_bl_delegate_per_category = 'EVENT' then
       l_bl_number_events := 'EVENT';
  end if;
  --
  l_bl_training_plan := l_bl_number_events;
  --
  RETURN l_bl_training_plan;
END get_budget_level;
--------------------------------------------------------------------------
--Function for calculating member budget values:
---------------------------------------------------------------------------
FUNCTION get_member_budget_values(p_measure_code varchar2
                                 ,p_member_level varchar2
                                 ,p_member_id number
                                 ,p_training_plan_id number
                                 ,p_business_group_id number) return number
IS
--
l_budget_value number;
-- Cursor to fetch values according to measurement type
Cursor csr_cal_budget_values(c_measure_code varchar2,
                             c_member_id number,
                             c_member_level varchar2,
                             c_training_plan_id number,
                             c_business_group_id number) is
select sum(pbv.value) value
from per_budgets pb,
     per_budget_versions pbr,
     per_budget_values pbv,
     per_budget_elements pbe,
     ota_training_plan_members tpm
where pb.unit = c_measure_code
  and pb.budget_type_code = 'OTA_BUDGET'
  and pb.business_group_id = tpm.business_group_id
  and pb.budget_id = pbr.budget_id
  and pbr.budget_version_id = pbe.budget_version_id
  and pbv.budget_element_id = pbe.budget_element_id
  and pbv.business_group_id = tpm.business_group_id
  and tpm.business_group_id = c_business_group_id
  and pbe.training_plan_member_id = tpm.training_plan_member_id
  and pbe.event_id is null
  and pbe.business_group_id = tpm.business_group_id
  and tpm.training_plan_id = c_training_plan_id
  and decode(c_member_level,
             'ACTIVITY_VERSION', tpm.activity_version_id ,
             'ACTIVITY_DEFINITION', tpm.activity_definition_id) = c_member_id;
--
BEGIN
--
OPEN csr_cal_budget_values(p_measure_code,
                           p_member_id,
                           p_member_level,
                           p_training_plan_id,
                           p_business_group_id);
FETCH csr_cal_budget_values INTO l_budget_value;
CLOSE csr_cal_budget_values;
--
IF l_budget_value is null THEN
   l_budget_value :=0;
END IF;
--
RETURN l_budget_value;
--
END get_member_budget_values;
------------------------------------------
--Function for calculating event duration
------------------------------------------
FUNCTION get_event_duration(p_training_plan_id number,
                            p_event_id number,
                            p_member_level varchar2,
                            p_member_id number,
                            p_business_group_id number) return number is
--
l_total number;
--
Cursor csr_sum_evt_duration(c_training_plan_id number,
                            c_event_id number,
                            c_member_level varchar,
                            c_member_id number,
                            c_business_group_id number) is
select sum(pbv.value)
from per_budgets pb,
     per_budget_versions pbr,
     per_budget_values pbv,
     per_budget_elements pbe,
     ota_training_plan_members tpm
where pb.unit = 'FR_DURATION_HOURS'
  and pb.budget_type_code = 'OTA_BUDGET'
  and pb.business_group_id = tpm.business_group_id
  and pb.budget_id = pbr.budget_id
  and pbr.budget_version_id = pbe.budget_version_id
  and pbv.budget_element_id = pbe.budget_element_id
  and pbv.business_group_id = tpm.business_group_id
  and tpm.business_group_id = c_business_group_id
  and pbe.event_id = c_event_id
  and pbe.training_plan_member_id = tpm.training_plan_member_id
  and pbe.business_group_id = tpm.business_group_id
  and tpm.training_plan_id = c_training_plan_id
  and decode(c_member_level,
             'ACTIVITY_VERSION', tpm.activity_version_id ,
             'ACTIVITY_DEFINITION', tpm.activity_definition_id) = c_member_id;
--
BEGIN
--
OPEN  csr_sum_evt_duration(p_training_plan_id,
                           p_event_id,
                           p_member_level,
                           p_member_id,
                           p_business_group_id);
FETCH csr_sum_evt_duration INTO l_total;
CLOSE csr_sum_evt_duration;
--
IF l_total is null THEN
   l_total := 0;
END IF;
return l_total;
--
EXCEPTION
when others then
            return 0;
END get_event_duration;
--
------------------------------------------------------
-- Procedure for writing format of XML string
---------------------------------------------------------
procedure load_xml_declaration(p_xml            in out nocopy clob)
is
--
  cursor csr_get_lookup(p_lookup_type    varchar2
                       ,p_lookup_code    varchar2
                       ,p_view_app_id    number default 3) is
  select meaning,tag
  FROM   fnd_lookup_values flv
  WHERE  lookup_type         = p_lookup_type
  AND    lookup_code         = p_lookup_code
  AND    language            = userenv('LANG')
  AND    view_application_id = p_view_app_id
  and    SECURITY_GROUP_ID   = decode(substr(userenv('CLIENT_INFO'),55,1),
                                 ' ', 0,
                                 NULL, 0,
                                 '0', 0,
                                 fnd_global.lookup_security_group(
                                     FLV.LOOKUP_TYPE,FLV.VIEW_APPLICATION_ID));
  rec_lookup  csr_get_lookup%ROWTYPE;
  --
begin
  --
  open csr_get_lookup('FND_ISO_CHARACTER_SET_MAP',
                    substr(USERENV('LANGUAGE'),instr(USERENV('LANGUAGE'),'.')+1),
                    0);
    fetch csr_get_lookup into rec_lookup;
    close csr_get_lookup;
    --
    if rec_lookup.tag is null then
      g_convert_to_utf8 := TRUE;
    else
      g_convert_to_utf8 := FALSE;
    end if;
    write_to_clob(p_xml,'<?xml version="1.0" encoding="'||
                   nvl(rec_lookup.tag,'UTF-8')||'" ?>');
  --
end load_xml_declaration;
--
-------------------------------------------------------------
-- Procedure for appending labels of the XML string
-------------------------------------------------------------
procedure load_xml_label(p_xml            in out nocopy clob,
                         p_node           varchar2,
                         p_open_not_close boolean) is
begin
  if p_open_not_close then
    write_to_clob (p_xml,'<'||p_node||'>
');
  else
    write_to_clob (p_xml,'</'||p_node||'>
');
  end if;
end load_xml_label;
--
----------------------------------------------------------------
-- Procedure for writing tag names and values
---------------------------------------------------------------
procedure load_xml (p_xml            in out nocopy clob,
                    p_node           varchar2,
                    p_data           varchar2,
                    p_attribs        varchar2 default null)
is
  l_data varchar2(2000);
begin
  /* Handle special characters in data */
  l_data := REPLACE (p_data, '&', '&amp;');
  l_data := REPLACE (l_data, '>', '&gt;');
  l_data := REPLACE (l_data, '<', '&lt;');
  l_data := REPLACE (l_data, '''', '&apos;');
  l_data := REPLACE (l_data, '"', '&quot;');
  write_to_clob(p_xml,'<'||p_node||ltrim(' '||p_attribs)||'>'||
            l_data||'</'||p_node||'>');
end load_xml;
-----------------------------------------------------------
-- Procedure for writing the clob
-----------------------------------------------------------
procedure write_to_clob (p_xml  in out nocopy clob,
                         p_data varchar2) is
begin

  if g_convert_to_utf8 then
    dbms_lob.writeappend(p_xml,
                         length(convert(p_data,'UTF8')),
                         convert(p_data,'UTF8'));
  else
    dbms_lob.writeappend(p_xml, length(p_data), p_data);
  end if;
end write_to_clob;
--------------------------------------------------------------------
END OTA_FR_PLAN_DFORM;

/
