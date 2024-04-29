--------------------------------------------------------
--  DDL for Package ECX_INBOUND_LISTENER_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_INBOUND_LISTENER_QH" AUTHID CURRENT_USER as
-- $Header: ECXILQHS.pls 120.1.12000000.1 2007/01/16 06:11:07 appldev ship $

queue_handler_exit exception;

PROCEDURE Dequeue(p_agent_guid in         raw,
                  p_event      out nocopy wf_event_t);

PROCEDURE enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t default null);
end ECX_INBOUND_LISTENER_QH;

 

/
