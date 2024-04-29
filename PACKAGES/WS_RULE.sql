--------------------------------------------------------
--  DDL for Package WS_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WS_RULE" AUTHID CURRENT_USER AS
-- $Header: wsrules.pls 115.2 2004/01/09 23:21:32 jjxie noship $


ws_log_exit exception;

function log_outbound
    (p_subscription_guid  in      raw,
     p_event              in out  WF_EVENT_T) return varchar2;

function log_inbound
    (p_subscription_guid  in      raw,
     p_event              in out  WF_EVENT_T) return varchar2;

end ws_rule;

 

/
