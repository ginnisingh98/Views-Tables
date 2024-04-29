--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_BEP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_BEP" as 
--Code generated on 30/08/2013 11:36:28
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_assignment_a (
p_effective_date               date,
p_assignment_id                number,
p_datetrack_mode               varchar2,
p_loc_change_tax_issues        boolean,
p_delete_asg_budgets           boolean,
p_org_now_no_manager_warning   boolean,
p_element_salary_warning       boolean,
p_element_entries_warning      boolean,
p_spp_warning                  boolean,
p_cost_warning                 boolean,
p_life_events_exists           boolean,
p_cobra_coverage_elements      boolean,
p_assgt_term_elements          boolean) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_assignment_beP.delete_assignment_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.assignment.delete_assignment';
  l_message:=wf_event.test(l_event_name);
  --
  if (l_message='MESSAGE') then
    hr_utility.set_location(l_proc,20);
    --
    -- get a key for the event
    --
    open get_seq;
    fetch get_seq into l_event_key;
    close get_seq;
    --
    -- build the xml data for the event
    --
    dbms_lob.createTemporary(l_event_data,false,dbms_lob.call);
    l_text:='<?xml version =''1.0'' encoding =''ASCII''?>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_id);
    l_text:=l_text||'</assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<datetrack_mode>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_datetrack_mode);
    l_text:=l_text||'</datetrack_mode>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<loc_change_tax_issues>';
if(P_LOC_CHANGE_TAX_ISSUES) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</loc_change_tax_issues>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<delete_asg_budgets>';
if(P_DELETE_ASG_BUDGETS) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</delete_asg_budgets>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_now_no_manager_warning>';
if(P_ORG_NOW_NO_MANAGER_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</org_now_no_manager_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_salary_warning>';
if(P_ELEMENT_SALARY_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</element_salary_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_entries_warning>';
if(P_ELEMENT_ENTRIES_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</element_entries_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<spp_warning>';
if(P_SPP_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</spp_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_warning>';
if(P_COST_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</cost_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<life_events_exists>';
if(P_LIFE_EVENTS_EXISTS) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</life_events_exists>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cobra_coverage_elements>';
if(P_COBRA_COVERAGE_ELEMENTS) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</cobra_coverage_elements>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assgt_term_elements>';
if(P_ASSGT_TERM_ELEMENTS) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</assgt_term_elements>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</assignment>';
    --
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    -- raise the event with the event data
    wf_event.raise(p_event_name=>l_event_name
                  ,p_event_key=>l_event_key
                  ,p_event_data=>l_event_data);
  elsif (l_message='KEY') then
    hr_utility.set_location(l_proc,30);
    -- get a key for the event
    open get_seq;
    fetch get_seq into l_event_key;
    close get_seq;
    -- this is a key event, so just raise the event
    -- without the event data
    wf_event.raise(p_event_name=>l_event_name
                  ,p_event_key=>l_event_key);
  elsif (l_message='NONE') then
    hr_utility.set_location(l_proc,40);
    -- no event is required, so do nothing
    null;
  end if;
    hr_utility.set_location('Leaving: '||l_proc,50);
end delete_assignment_a;
end hr_assignment_beP;

/
