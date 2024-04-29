--------------------------------------------------------
--  DDL for Package Body FA_BUSINESS_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_BUSINESS_EVENTS" AS
/* $Header: fawfbevb.pls 120.2.12010000.2 2009/07/19 10:47:10 glchen ship $ */

--
-- PUBLIC FUNCTIONS
--

FUNCTION test(p_event_name in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return varchar2 IS
BEGIN
  return(wf_event.test(p_event_name => p_event_name));
END test;

PROCEDURE raise(p_event_name       in varchar2,
                p_event_key        in varchar2,
                p_event_data       in clob default NULL,
                p_parameter_name1  in varchar2 default NULL,
                p_parameter_value1 in varchar2 default NULL,
                p_parameter_name2  in varchar2 default NULL,
                p_parameter_value2 in varchar2 default NULL,
                p_parameter_name3  in varchar2 default NULL,
                p_parameter_value3 in varchar2 default NULL,
                p_parameter_name4  in varchar2 default NULL,
                p_parameter_value4 in varchar2 default NULL,
                p_parameter_name5  in varchar2 default NULL,
                p_parameter_value5 in varchar2 default NULL,
                p_parameter_name6  in varchar2 default NULL,
                p_parameter_value6 in varchar2 default NULL,
                p_parameter_name7  in varchar2 default NULL,
                p_parameter_value7 in varchar2 default NULL,
                p_parameter_name8  in varchar2 default NULL,
                p_parameter_value8 in varchar2 default NULL,
                p_parameter_name9  in varchar2 default NULL,
                p_parameter_value9 in varchar2 default NULL,
                p_parameter_name10  in varchar2 default NULL,
                p_parameter_value10 in varchar2 default NULL,
                p_parameter_name11  in varchar2 default NULL,
                p_parameter_value11 in varchar2 default NULL,
                p_parameter_name12  in varchar2 default NULL,
                p_parameter_value12 in varchar2 default NULL,
                p_parameter_name13  in varchar2 default NULL,
                p_parameter_value13 in varchar2 default NULL,
                p_parameter_name14  in varchar2 default NULL,
                p_parameter_value14 in varchar2 default NULL,
                p_parameter_name15  in varchar2 default NULL,
                p_parameter_value15 in varchar2 default NULL,
                p_parameter_name16  in varchar2 default NULL,
                p_parameter_value16 in varchar2 default NULL,
                p_parameter_name17  in varchar2 default NULL,
                p_parameter_value17 in varchar2 default NULL,
                p_parameter_name18  in varchar2 default NULL,
                p_parameter_value18 in varchar2 default NULL,
                p_parameter_name19  in varchar2 default NULL,
                p_parameter_value19 in varchar2 default NULL,
                p_parameter_name20  in varchar2 default NULL,
                p_parameter_value20 in varchar2 default NULL,
                p_send_date         in date default NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  l_param_list WF_PARAMETER_LIST_T := wf_parameter_list_t();
BEGIN

  if (p_parameter_name1 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name1,
      p_value => p_parameter_value1,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name2 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name2,
      p_value => p_parameter_value2,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name3 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name3,
      p_value => p_parameter_value3,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name4 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name4,
      p_value => p_parameter_value4,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name5 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name5,
      p_value => p_parameter_value5,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name6 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name6,
      p_value => p_parameter_value6,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name7 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name7,
      p_value => p_parameter_value7,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name8 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name8,
      p_value => p_parameter_value8,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name9 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name9,
      p_value => p_parameter_value9,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name10 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name10,
      p_value => p_parameter_value10,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name11 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name11,
      p_value => p_parameter_value11,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name12 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name12,
      p_value => p_parameter_value12,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name13 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name13,
      p_value => p_parameter_value13,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name14 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name14,
      p_value => p_parameter_value14,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name15 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name15,
      p_value => p_parameter_value15,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name16 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name16,
      p_value => p_parameter_value16,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name17 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name17,
      p_value => p_parameter_value17,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name18 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name18,
      p_value => p_parameter_value18,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name19 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name19,
      p_value => p_parameter_value19,
      p_parameterlist => l_param_list);
  end if;

  if (p_parameter_name20 is not null) then
    wf_event.AddParameterToList(
      p_name => p_parameter_name20,
      p_value => p_parameter_value20,
      p_parameterlist => l_param_list);
  end if;

  wf_event.raise(p_event_name => p_event_name,
                 p_event_key => p_event_key,
                 p_event_data => p_event_data,
                 p_parameters => l_param_list,
                 p_send_date => p_send_date);
END raise;

END fa_business_events;

/
