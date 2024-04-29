--------------------------------------------------------
--  DDL for Package Body WF_BES_DYN_FUNCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_BES_DYN_FUNCS" as
/* $Header: WFBESDFNB.pls 120.2 2005/07/02 08:18:36 appldev noship $ */


--
-- Generate
PROCEDURE Generate(p_func_name in varchar2,
                  p_event_name in varchar2,
                  p_event_key in varchar2,
                  p_parameter_list in wf_parameter_list_t,
                  x_msg      in out nocopy clob,
                  x_executed  out nocopy boolean)

is
   l_func_name VARCHAR2(240);
begin
   l_func_name := upper(p_func_name);
   if (l_func_name = 'WF_XML.GENERATE') then --<rwunderl:2769455>
      x_msg := WF_XML.Generate(p_event_name, p_event_key, p_parameter_list);
      x_executed := TRUE;
   else
      x_msg := null;
      x_executed := FALSE;
   end if;
end Generate;

--
-- Rule Function
PROCEDURE RuleFunction(p_func_name in varchar2,
                      p_subscription_guid in     raw,
                      p_event             in out nocopy wf_event_t,
                      x_result            in out nocopy varchar2,
                      x_executed          out nocopy boolean)

is
  l_func_name VARCHAR2(240);
begin
  l_func_name := upper(l_func_name);
  if (l_func_name = 'WF_RULE.DEFAULT_RULE') then
    x_result := wf_rule.default_rule(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_RULE.DEFAULT_RULE2') then
    x_result := wf_rule.default_rule2(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_RULE.DEFAULT_RULE3') then
    x_result := wf_rule.default_rule3(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_RULE.INSTANCE_DEFAULT_RULE') then
    x_result := wf_rule.instance_default_rule(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_RULE.ERROR_RULE') then
    x_result := wf_rule.error_rule(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_RULE.SETPARAMETERSINTOPARAMETERLIST') then
    x_result := wf_rule.setparametersintoparameterlist(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_RULE.SUCCESS') then
    x_result := wf_rule.success(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_RULE.WORKFLOW_PROTOCOL') then
    x_result := wf_rule.workflow_protocol(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_XML.ERROR_RULE') then
    x_result := wf_xml.error_rule(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_XML.RECEIVE') then
    x_result := wf_xml.receive(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_XML.SENDNOTIFICATION') then
    x_result := wf_xml.sendnotification(p_subscription_guid, p_event);
    x_executed := TRUE;
  elsif (l_func_name = 'WF_XML.SUMMARYRULE') then
    x_result := wf_xml.summaryrule(p_subscription_guid, p_event);
    x_executed := TRUE;
  else
    x_result := null;
    x_executed := FALSE;
  end if;
end RuleFunction;

end WF_BES_DYN_FUNCS;

/
