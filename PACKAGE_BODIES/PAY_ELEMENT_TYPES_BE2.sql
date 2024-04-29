--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_TYPES_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_TYPES_BE2" as 
--Code generated on 29/08/2013 10:00:33
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_element_type_a (
p_effective_date               date,
p_datetrack_update_mode        varchar2,
p_element_type_id              number,
p_object_version_number        number,
p_formula_id                   number,
p_benefit_classification_id    number,
p_additional_entry_allowed_fla varchar2,
p_adjustment_only_flag         varchar2,
p_closed_for_entry_flag        varchar2,
p_element_name                 varchar2,
p_reporting_name               varchar2,
p_description                  varchar2,
p_indirect_only_flag           varchar2,
p_multiple_entries_allowed_fla varchar2,
p_multiply_value_flag          varchar2,
p_post_termination_rule        varchar2,
p_process_in_run_flag          varchar2,
p_processing_priority          number,
p_standard_link_flag           varchar2,
p_comments                     varchar2,
p_third_party_pay_only_flag    varchar2,
p_iterative_flag               varchar2,
p_iterative_formula_id         number,
p_iterative_priority           number,
p_creator_type                 varchar2,
p_retro_summ_ele_id            number,
p_grossup_flag                 varchar2,
p_process_mode                 varchar2,
p_advance_indicator            varchar2,
p_advance_payable              varchar2,
p_advance_deduction            varchar2,
p_process_advance_entry        varchar2,
p_proration_group_id           number,
p_proration_formula_id         number,
p_recalc_event_group_id        number,
p_qualifying_age               number,
p_qualifying_length_of_service number,
p_qualifying_units             varchar2,
p_attribute_category           varchar2,
p_attribute1                   varchar2,
p_attribute2                   varchar2,
p_attribute3                   varchar2,
p_attribute4                   varchar2,
p_attribute5                   varchar2,
p_attribute6                   varchar2,
p_attribute7                   varchar2,
p_attribute8                   varchar2,
p_attribute9                   varchar2,
p_attribute10                  varchar2,
p_attribute11                  varchar2,
p_attribute12                  varchar2,
p_attribute13                  varchar2,
p_attribute14                  varchar2,
p_attribute15                  varchar2,
p_attribute16                  varchar2,
p_attribute17                  varchar2,
p_attribute18                  varchar2,
p_attribute19                  varchar2,
p_attribute20                  varchar2,
p_element_information_category varchar2,
p_element_information1         varchar2,
p_element_information2         varchar2,
p_element_information3         varchar2,
p_element_information4         varchar2,
p_element_information5         varchar2,
p_element_information6         varchar2,
p_element_information7         varchar2,
p_element_information8         varchar2,
p_element_information9         varchar2,
p_element_information10        varchar2,
p_element_information11        varchar2,
p_element_information12        varchar2,
p_element_information13        varchar2,
p_element_information14        varchar2,
p_element_information15        varchar2,
p_element_information16        varchar2,
p_element_information17        varchar2,
p_element_information18        varchar2,
p_element_information19        varchar2,
p_element_information20        varchar2,
p_once_each_period_flag        varchar2,
p_language_code                varchar2,
p_time_definition_type         varchar2,
p_time_definition_id           number,
p_advance_element_type_id      number,
p_deduction_element_type_id    number,
p_effective_start_date         date,
p_effective_end_date           date,
p_comment_id                   number,
p_processing_priority_warning  boolean,
p_element_name_warning         boolean,
p_element_name_change_warning  boolean) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  pay_element_types_be2.update_element_type_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.pay.api.element_types.update_element_type';
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
    l_text:='<element_types>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<datetrack_update_mode>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_datetrack_update_mode);
    l_text:=l_text||'</datetrack_update_mode>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_element_type_id);
    l_text:=l_text||'</element_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<formula_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_formula_id);
    l_text:=l_text||'</formula_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<benefit_classification_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_benefit_classification_id);
    l_text:=l_text||'</benefit_classification_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<additional_entry_allowed_fla>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_additional_entry_allowed_fla);
    l_text:=l_text||'</additional_entry_allowed_fla>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<adjustment_only_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_adjustment_only_flag);
    l_text:=l_text||'</adjustment_only_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<closed_for_entry_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_closed_for_entry_flag);
    l_text:=l_text||'</closed_for_entry_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_name);
    l_text:=l_text||'</element_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<reporting_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_reporting_name);
    l_text:=l_text||'</reporting_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_description);
    l_text:=l_text||'</description>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<indirect_only_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_indirect_only_flag);
    l_text:=l_text||'</indirect_only_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<multiple_entries_allowed_fla>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_multiple_entries_allowed_fla);
    l_text:=l_text||'</multiple_entries_allowed_fla>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<multiply_value_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_multiply_value_flag);
    l_text:=l_text||'</multiply_value_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<post_termination_rule>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_post_termination_rule);
    l_text:=l_text||'</post_termination_rule>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<process_in_run_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_process_in_run_flag);
    l_text:=l_text||'</process_in_run_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<processing_priority>';
    l_text:=l_text||fnd_number.number_to_canonical(p_processing_priority);
    l_text:=l_text||'</processing_priority>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<standard_link_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_standard_link_flag);
    l_text:=l_text||'</standard_link_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<third_party_pay_only_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_third_party_pay_only_flag);
    l_text:=l_text||'</third_party_pay_only_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<iterative_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_iterative_flag);
    l_text:=l_text||'</iterative_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<iterative_formula_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_iterative_formula_id);
    l_text:=l_text||'</iterative_formula_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<iterative_priority>';
    l_text:=l_text||fnd_number.number_to_canonical(p_iterative_priority);
    l_text:=l_text||'</iterative_priority>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<creator_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_creator_type);
    l_text:=l_text||'</creator_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<retro_summ_ele_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_retro_summ_ele_id);
    l_text:=l_text||'</retro_summ_ele_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<grossup_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_grossup_flag);
    l_text:=l_text||'</grossup_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<process_mode>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_process_mode);
    l_text:=l_text||'</process_mode>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<advance_indicator>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_advance_indicator);
    l_text:=l_text||'</advance_indicator>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<advance_payable>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_advance_payable);
    l_text:=l_text||'</advance_payable>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<advance_deduction>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_advance_deduction);
    l_text:=l_text||'</advance_deduction>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<process_advance_entry>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_process_advance_entry);
    l_text:=l_text||'</process_advance_entry>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<proration_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_proration_group_id);
    l_text:=l_text||'</proration_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<proration_formula_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_proration_formula_id);
    l_text:=l_text||'</proration_formula_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<recalc_event_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_recalc_event_group_id);
    l_text:=l_text||'</recalc_event_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<qualifying_age>';
    l_text:=l_text||fnd_number.number_to_canonical(p_qualifying_age);
    l_text:=l_text||'</qualifying_age>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<qualifying_length_of_service>';
    l_text:=l_text||fnd_number.number_to_canonical(p_qualifying_length_of_service);
    l_text:=l_text||'</qualifying_length_of_service>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<qualifying_units>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_qualifying_units);
    l_text:=l_text||'</qualifying_units>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute_category);
    l_text:=l_text||'</attribute_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute1);
    l_text:=l_text||'</attribute1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute2);
    l_text:=l_text||'</attribute2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute3);
    l_text:=l_text||'</attribute3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute4);
    l_text:=l_text||'</attribute4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute5);
    l_text:=l_text||'</attribute5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute6);
    l_text:=l_text||'</attribute6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute7);
    l_text:=l_text||'</attribute7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute8);
    l_text:=l_text||'</attribute8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute9);
    l_text:=l_text||'</attribute9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute10);
    l_text:=l_text||'</attribute10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute11);
    l_text:=l_text||'</attribute11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute12);
    l_text:=l_text||'</attribute12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute13);
    l_text:=l_text||'</attribute13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute14);
    l_text:=l_text||'</attribute14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute15);
    l_text:=l_text||'</attribute15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute16);
    l_text:=l_text||'</attribute16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute17);
    l_text:=l_text||'</attribute17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute18);
    l_text:=l_text||'</attribute18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute19);
    l_text:=l_text||'</attribute19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute20);
    l_text:=l_text||'</attribute20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information_category);
    l_text:=l_text||'</element_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information1);
    l_text:=l_text||'</element_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information2);
    l_text:=l_text||'</element_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information3);
    l_text:=l_text||'</element_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information4);
    l_text:=l_text||'</element_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information5);
    l_text:=l_text||'</element_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information6);
    l_text:=l_text||'</element_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information7);
    l_text:=l_text||'</element_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information8);
    l_text:=l_text||'</element_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information9);
    l_text:=l_text||'</element_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information10);
    l_text:=l_text||'</element_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information11);
    l_text:=l_text||'</element_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information12);
    l_text:=l_text||'</element_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information13);
    l_text:=l_text||'</element_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information14);
    l_text:=l_text||'</element_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information15);
    l_text:=l_text||'</element_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information16);
    l_text:=l_text||'</element_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information17);
    l_text:=l_text||'</element_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information18);
    l_text:=l_text||'</element_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information19);
    l_text:=l_text||'</element_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_element_information20);
    l_text:=l_text||'</element_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<once_each_period_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_once_each_period_flag);
    l_text:=l_text||'</once_each_period_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<language_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_language_code);
    l_text:=l_text||'</language_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<time_definition_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_time_definition_type);
    l_text:=l_text||'</time_definition_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<time_definition_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_time_definition_id);
    l_text:=l_text||'</time_definition_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<advance_element_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_advance_element_type_id);
    l_text:=l_text||'</advance_element_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<deduction_element_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_deduction_element_type_id);
    l_text:=l_text||'</deduction_element_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_start_date);
    l_text:=l_text||'</effective_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_end_date);
    l_text:=l_text||'</effective_end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_comment_id);
    l_text:=l_text||'</comment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<processing_priority_warning>';
if(P_PROCESSING_PRIORITY_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</processing_priority_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_name_warning>';
if(P_ELEMENT_NAME_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</element_name_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_name_change_warning>';
if(P_ELEMENT_NAME_CHANGE_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</element_name_change_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</element_types>';
    --
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    if p_effective_start_date is not NULL and
       p_effective_start_date > trunc(SYSDATE) and
        fnd_profile.value('HR_DEFER_FD_BE_EVENTS') = 'Y' then 
       -- raise the event with the event data, with send date set to effective date
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_event_data=>l_event_data
                     ,p_send_date => p_effective_start_date);
        --
    else 
       -- raise the event with the event data
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_event_data=>l_event_data);
    end if;
  elsif (l_message='KEY') then
    hr_utility.set_location(l_proc,30);
    -- get a key for the event
    open get_seq;
    fetch get_seq into l_event_key;
    close get_seq;
    if p_effective_start_date is not NULL and
       p_effective_start_date > trunc(SYSDATE) and
        fnd_profile.value('HR_DEFER_FD_BE_EVENTS') = 'Y' then 
       -- this is a key event, so just raise the event
       -- without the event data, with send date set to effective date
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_send_date => p_effective_start_date);
       --
    else
       -- this is a key event, so just raise the event
       -- without the event data
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key);
    end if;
  elsif (l_message='NONE') then
    hr_utility.set_location(l_proc,40);
    -- no event is required, so do nothing
    null;
  end if;
    hr_utility.set_location('Leaving: '||l_proc,50);
end update_element_type_a;
end pay_element_types_be2;

/
