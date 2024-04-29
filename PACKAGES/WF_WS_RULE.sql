--------------------------------------------------------
--  DDL for Package WF_WS_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_WS_RULE" AUTHID CURRENT_USER AS
-- $Header: wfwsrules.pls 120.0 2005/10/13 12:37:00 jdang noship $


ws_log_exit exception;

function log_outbound
    (p_subscription_guid  in      raw,
     p_event              in out  NOCOPY WF_EVENT_T) return varchar2;

function log_inbound
    (p_subscription_guid  in      raw,
     p_event              in out  NOCOPY WF_EVENT_T) return varchar2;

end wf_ws_rule;

 

/
