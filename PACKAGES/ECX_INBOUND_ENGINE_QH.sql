--------------------------------------------------------
--  DDL for Package ECX_INBOUND_ENGINE_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_INBOUND_ENGINE_QH" AUTHID CURRENT_USER as
-- $Header: ECXIEQHS.pls 120.2 2006/03/23 07:11:35 susaha ship $
-- Define a Global variable for the Business Event
g_event  wf_event_t;

PROCEDURE Dequeue(p_agent_guid in  raw,
                  p_event      out nocopy wf_event_t);
PROCEDURE enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t default null);
end ECX_INBOUND_ENGINE_QH;

 

/
