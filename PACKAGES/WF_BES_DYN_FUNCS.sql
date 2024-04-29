--------------------------------------------------------
--  DDL for Package WF_BES_DYN_FUNCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_BES_DYN_FUNCS" AUTHID CURRENT_USER as
/* $Header: WFBESDFNS.pls 120.2 2005/07/02 08:18:33 appldev noship $ */
--
-- Generate
PROCEDURE Generate(p_func_name  in varchar2,
                  p_event_name in varchar2,
                  p_event_key in varchar2,
                  p_parameter_list in wf_parameter_list_t,
                  x_msg     in out nocopy clob,
                  x_executed  out nocopy boolean);

--
-- Rule Function
-- Assuming the func name is the right rule function for passed subscription
PROCEDURE RuleFunction(p_func_name in varchar2,
                      p_subscription_guid in     raw,
                      p_event             in out nocopy wf_event_t,
                      x_result    in out nocopy varchar2,
                      x_executed   out nocopy boolean);

end WF_BES_DYN_FUNCS;

 

/
