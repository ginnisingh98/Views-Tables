--------------------------------------------------------
--  DDL for Package WF_AGT_DYN_FUNCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_AGT_DYN_FUNCS" AUTHID CURRENT_USER as
/* $Header: WFAGTDFNS.pls 120.1 2005/09/02 13:08:36 mputhiya noship $ */
--
-- Enqueue
--
PROCEDURE StaticEnqueue(p_qh_name    in  varchar2,
                        p_event      in wf_event_t,
                        p_out_agent_override in  wf_agent_t,
                        p_executed   out nocopy boolean);

--
-- Dequeue
--
PROCEDURE StaticDequeue(p_qh_name    in  varchar2,
                        p_agent_guid in  raw,
	                p_event      in out nocopy wf_event_t,
                        p_wait       in  binary_integer,
	                p_executed   out nocopy boolean);

end WF_AGT_DYN_FUNCS;

 

/
