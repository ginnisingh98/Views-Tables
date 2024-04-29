--------------------------------------------------------
--  DDL for Package JTF_AUTH_PRINCIPALS_B_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AUTH_PRINCIPALS_B_UPDATE" AUTHID CURRENT_USER as
/* $Header: jtfusersyncs.pls 120.2.12010000.2 2018/04/02 13:27:43 ctilley noship $*/
function sync_uname(p_subscription_guid in raw,p_event in out NOCOPY WF_EVENT_T) return varchar2;

end JTF_AUTH_PRINCIPALS_B_UPDATE;


/
