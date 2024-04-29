--------------------------------------------------------
--  DDL for Package IEX_TERR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_TERR_PUB" AUTHID CURRENT_USER AS
/* $Header: iexkters.pls 120.1.12000000.2 2007/04/26 09:16:17 gnramasa ship $ */

PG_DEBUG NUMBER;

FUNCTION party_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)  return varchar2;

FUNCTION partysite_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)  return varchar2;

FUNCTION partysiteuse_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)  return varchar2;

FUNCTION location_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)  return varchar2;

FUNCTION account_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)  return varchar2;

FUNCTION profile_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)  return varchar2;

 FUNCTION accountsite_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t) return varchar2;

 FUNCTION accountsiteuse_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t) return varchar2;

 FUNCTION profileamt_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2;

FUNCTION finprofile_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)  return varchar2;

 PROCEDURE logMessage (p_text in varchar2);

--IEX Summary Table Synchronization Start.
 FUNCTION SYNC_TCA_SUMMARY(
 p_party_id in number default null,
 p_account_id in number default null,
 p_site_use_id in number default null,
 p_collector_id in number default null,
 p_level in varchar2
 ) return varchar2;
 --IEX Summary Table Synchronization End.


END; -- Package spec

 

/
