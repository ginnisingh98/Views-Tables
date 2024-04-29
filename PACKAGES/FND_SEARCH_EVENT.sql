--------------------------------------------------------
--  DDL for Package FND_SEARCH_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SEARCH_EVENT" AUTHID CURRENT_USER as
-- $Header: FNDCLGEHS.pls 120.1.12010000.1 2008/07/25 14:24:29 appldev ship $
FUNCTION On_Object_Change(p_subscription_guid in raw,
        p_event in out NOCOPY WF_EVENT_T ) return VARCHAR2;

--Called when an incremental crawl starts
FUNCTION Start_Crawl(obj_name in varchar2) return VARCHAR2;
--Called when an incremental crawl ends
FUNCTION End_Crawl(obj_name in varchar2,change_type in varchar2) return VARCHAR2;
--Called when an incremental crawl errors out
FUNCTION Reset_Crawl(obj_name in varchar2,change_type in varchar2) return VARCHAR2;


end FND_SEARCH_EVENT;

/
