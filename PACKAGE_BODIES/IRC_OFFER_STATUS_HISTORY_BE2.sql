--------------------------------------------------------
--  DDL for Package Body IRC_OFFER_STATUS_HISTORY_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_OFFER_STATUS_HISTORY_BE2" as 
--Code generated on 29/08/2013 09:58:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_offer_status_history_a (
p_effective_date               date,
p_offer_status_history_id      number,
p_status_change_date           date,
p_change_reason                varchar2,
p_decline_reason               varchar2,
p_note_text                    varchar2,
p_object_version_number        number) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  irc_offer_status_history_be2.update_offer_status_history_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.irc.api.offer_status_history.update_offer_status_history';
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
    l_text:='<offer_status_history>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_status_history_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_offer_status_history_id);
    l_text:=l_text||'</offer_status_history_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<status_change_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_status_change_date);
    l_text:=l_text||'</status_change_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<change_reason>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_change_reason);
    l_text:=l_text||'</change_reason>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<decline_reason>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_decline_reason);
    l_text:=l_text||'</decline_reason>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<note_text>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_note_text);
    l_text:=l_text||'</note_text>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</offer_status_history>';
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
end update_offer_status_history_a;
end irc_offer_status_history_be2;

/
