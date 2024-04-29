--------------------------------------------------------
--  DDL for Package Body WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_UTIL" as
/* $Header: WFUTILB.pls 120.4 2005/10/28 11:18:29 dlam ship $ */
--------------------------------------------------------------------------
/*
** call_me_later - <described in WFUTILS.pls>
*/
PROCEDURE call_me_later(p_callback   in varchar2,
                        p_when       in date,
                        p_parameters in wf_parameter_list_t default null) is
begin
  wf_event.raise(p_event_name => 'oracle.apps.wf.callback.delay',
                 p_event_key  => p_callback,
                 p_event_data => null,
                 p_parameters => p_parameters,
                 p_send_date  => p_when);
end;
---------------------------------------------------------------------------
/*
** call_me_later_rf - <described in WFUTILS.pls>
*/
FUNCTION call_me_later_rf(p_subscription_guid in raw,
                          p_event in out nocopy wf_event_t) return varchar2
is
  my_callback  varchar2(256)        := p_event.getEventKey();
  my_parms     wf_parameter_list_t  := p_event.GetParameterList();
begin
  execute immediate 'begin '||my_callback||'(:v1); end;' using in my_parms;
  return 'SUCCESS';
end;
---------------------------------------------------------------------------
end WF_UTIL;

/
