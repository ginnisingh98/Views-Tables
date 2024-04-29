--------------------------------------------------------
--  DDL for Package Body IRC_PARTY_BE4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PARTY_BE4" as 
--Code generated on 30/08/2013 11:35:53
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_user_a (
p_user_name                    varchar2,
p_password                     varchar2,
p_start_date                   date,
p_email                        varchar2,
p_language                     varchar2,
p_allow_access                 varchar2,
p_last_name                    varchar2,
p_first_name                   varchar2,
p_per_information_category     varchar2,
p_per_information1             varchar2,
p_per_information2             varchar2,
p_per_information3             varchar2,
p_per_information4             varchar2,
p_per_information5             varchar2,
p_per_information6             varchar2,
p_per_information7             varchar2,
p_per_information8             varchar2,
p_per_information9             varchar2,
p_per_information10            varchar2,
p_per_information11            varchar2,
p_per_information12            varchar2,
p_per_information13            varchar2,
p_per_information14            varchar2,
p_per_information15            varchar2,
p_per_information16            varchar2,
p_per_information17            varchar2,
p_per_information18            varchar2,
p_per_information19            varchar2,
p_per_information20            varchar2,
p_per_information21            varchar2,
p_per_information22            varchar2,
p_per_information23            varchar2,
p_per_information24            varchar2,
p_per_information25            varchar2,
p_per_information26            varchar2,
p_per_information27            varchar2,
p_per_information28            varchar2,
p_per_information29            varchar2,
p_per_information30            varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  irc_party_be4.create_user_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.irc.api.party.create_user';
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
    l_text:='<party>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<user_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_user_name);
    l_text:=l_text||'</user_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<password>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_password);
    l_text:=l_text||'</password>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_start_date);
    l_text:=l_text||'</start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<email>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_email);
    l_text:=l_text||'</email>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<language>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_language);
    l_text:=l_text||'</language>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<allow_access>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_allow_access);
    l_text:=l_text||'</allow_access>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<last_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_last_name);
    l_text:=l_text||'</last_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<first_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_first_name);
    l_text:=l_text||'</first_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information_category);
    l_text:=l_text||'</per_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information1);
    l_text:=l_text||'</per_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information2);
    l_text:=l_text||'</per_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information3);
    l_text:=l_text||'</per_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information4);
    l_text:=l_text||'</per_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information5);
    l_text:=l_text||'</per_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information6);
    l_text:=l_text||'</per_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information7);
    l_text:=l_text||'</per_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information8);
    l_text:=l_text||'</per_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information9);
    l_text:=l_text||'</per_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information10);
    l_text:=l_text||'</per_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information11);
    l_text:=l_text||'</per_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information12);
    l_text:=l_text||'</per_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information13);
    l_text:=l_text||'</per_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information14);
    l_text:=l_text||'</per_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information15);
    l_text:=l_text||'</per_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information16);
    l_text:=l_text||'</per_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information17);
    l_text:=l_text||'</per_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information18);
    l_text:=l_text||'</per_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information19);
    l_text:=l_text||'</per_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information20);
    l_text:=l_text||'</per_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information21);
    l_text:=l_text||'</per_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information22);
    l_text:=l_text||'</per_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information23);
    l_text:=l_text||'</per_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information24);
    l_text:=l_text||'</per_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information25);
    l_text:=l_text||'</per_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information26);
    l_text:=l_text||'</per_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information27);
    l_text:=l_text||'</per_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information28);
    l_text:=l_text||'</per_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information29);
    l_text:=l_text||'</per_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information30);
    l_text:=l_text||'</per_information30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</party>';
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
end create_user_a;
end irc_party_be4;

/
