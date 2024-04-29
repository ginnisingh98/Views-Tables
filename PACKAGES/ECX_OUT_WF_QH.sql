--------------------------------------------------------
--  DDL for Package ECX_OUT_WF_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_OUT_WF_QH" AUTHID CURRENT_USER as
-- $Header: ECXOWFQS.pls 115.2 2003/01/30 18:29:13 mtai ship $

navigation  binary_integer := dbms_aq.next_message;
retmsg	    varchar2(200)  := null;
retcode     pls_integer    := 0;
msgid       raw(16);
queue_handler_exit exception;

PROCEDURE Dequeue(p_agent_guid in  raw,
                  p_event      out NOCOPY wf_event_t);

PROCEDURE enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t default null);

end ECX_OUT_WF_QH;

 

/
