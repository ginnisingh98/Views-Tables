--------------------------------------------------------
--  DDL for Package Body WF_AGT_DYN_FUNCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_AGT_DYN_FUNCS" as
/* $Header: WFAGTDFNB.pls 120.2 2005/09/02 16:25:27 vshanmug noship $ */
--
--Static enqueue procedure calls
--
PROCEDURE StaticEnqueue(p_qh_name    in  varchar2,
                        p_event      in wf_event_t,
                        p_out_agent_override in  wf_agent_t,
                        p_executed   out nocopy boolean)
as
  l_qh_name varchar2(240);
begin
  p_executed := FALSE;
  l_qh_name := upper(trim(p_qh_name));

  if (l_qh_name = 'WF_EVENT_OJMSTEXT_QH') then
    WF_EVENT_OJMSTEXT_QH.Enqueue(p_event, p_out_agent_override);
    p_executed := TRUE;
    return;
  end if;
  if (l_qh_name = 'WF_EVENT_QH') then
    WF_EVENT_QH.Enqueue(p_event, p_out_agent_override);
    p_executed := TRUE;
    return;
  end if;

end StaticEnqueue;

--
--Static dequeue procedure calls
--
PROCEDURE StaticDequeue(p_qh_name    in  varchar2,
	                    p_agent_guid in  raw,
	                    p_event      in out nocopy wf_event_t,
                  	    p_wait       in  binary_integer,
	                    p_executed   out nocopy boolean)
as
  l_qh_name varchar2(240);
begin
  p_executed := FALSE;
  l_qh_name := upper(trim(p_qh_name));

  if (l_qh_name = 'WF_EVENT_OJMSTEXT_QH') then
    WF_EVENT_OJMSTEXT_QH.Dequeue(p_agent_guid, p_event, p_wait);
    p_executed := TRUE;
    return;
  end if;
  if (l_qh_name = 'WF_EVENT_QH') then
     WF_EVENT_QH.Dequeue(p_agent_guid, p_event, p_wait);
     p_executed := TRUE;
     return;
  end if;

end StaticDequeue;

end WF_AGT_DYN_FUNCS;

/
