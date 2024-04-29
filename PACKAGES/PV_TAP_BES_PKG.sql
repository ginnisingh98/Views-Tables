--------------------------------------------------------
--  DDL for Package PV_TAP_BES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_TAP_BES_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtbess.pls 115.0 2003/10/15 03:52:20 rdsharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_TAP_BES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- This package includes all the PRM related Territory Assignment
-- subscriptions for following modules -
--             * Organization Update
--             * Party Site Update
--             * Location Update
--             * Contact Point Update
-- ===============================================================

-- Start of Comments
--
--      API name  : organization_update_post
--      Type      : Public
--      Function  : This function is used as a subscription for Organization
--                  update business event attached to following event -
--                      - oracle.apps.ar.hz.Organization.update
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                p_subscription_guid      IN raw
--                p_event                  IN out NOCOPY wf_event_t
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:   Subscription attach to 'oracle.apps.ar.hz.Organization.update'
--               event.
--
--
-- End of Comments
 FUNCTION organization_update_post
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 RETURN VARCHAR2;

-- Start of Comments
--
--      API name  : partysite_update_post
--      Type      : Public
--      Function  : This function is used as a subscription for Party Site
--                  update business event attached to following event -
--                      - oracle.apps.ar.hz.PartySite.update
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                p_subscription_guid      IN raw
--                p_event                  IN out NOCOPY wf_event_t
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:   Subscription attach to 'oracle.apps.ar.hz.PartySite.update'
--               event.
--
--
-- End of Comments
 FUNCTION partysite_update_post
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 RETURN VARCHAR2;

-- Start of Comments
--
--      API name  : location_update_post
--      Type      : Public
--      Function  : This function is used as a subscription for location
--                  update business event attached to following event -
--                      - oracle.apps.ar.hz.Location.update
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                p_subscription_guid      IN raw
--                p_event                  IN out NOCOPY wf_event_t
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:   Subscription attach to 'oracle.apps.ar.hz.Location.update'
--               event.
--
--
-- End of Comments
 FUNCTION location_update_post
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 RETURN VARCHAR2;

--
--      API name  : contactpoint_update_post
--      Type      : Public
--      Function  : This function is used as a subscription for Contact point
--                  update business event attached to following event -
--                      - oracle.apps.ar.hz.ContactPoint.update
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                p_subscription_guid      IN raw
--                p_event                  IN out NOCOPY wf_event_t
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:   Subscription attach to 'oracle.apps.ar.hz.ContactPoint.update'
--               event.
--
--
-- End of Comments
 FUNCTION contactpoint_update_post
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 RETURN VARCHAR2;

END PV_TAP_BES_PKG;

 

/
