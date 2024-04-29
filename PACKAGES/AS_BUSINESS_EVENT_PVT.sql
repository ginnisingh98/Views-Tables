--------------------------------------------------------
--  DDL for Package AS_BUSINESS_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_BUSINESS_EVENT_PVT" AUTHID CURRENT_USER as
/* $Header: asxvbevs.pls 115.0 2003/11/21 13:06:42 sumahali noship $ */

DIRECT_CALL                 CONSTANT VARCHAR2(16) := '__DIRECT_CALL__';

OPPTY_WON_EVENT             CONSTANT VARCHAR2(240) := 'oracle.apps.as.opportunity.update_wonStatus';
OPPTY_LOST_EVENT            CONSTANT VARCHAR2(240) := 'oracle.apps.as.opportunity.update_lostStatus';
OPPTY_CLOSED_EVENT          CONSTANT VARCHAR2(240) := 'oracle.apps.as.opportunity.update_closedStatus';
OPPTY_UPDATE_EVENT          CONSTANT VARCHAR2(240) := 'oracle.apps.as.opportunity.update_header';
OPP_LINES_UPDATE_EVENT      CONSTANT VARCHAR2(240) := 'oracle.apps.as.opportunity.update_lines';
OPP_STEAM_UPDATE_EVENT      CONSTANT VARCHAR2(240) := 'oracle.apps.as.opportunity.update_salesteam';
CUST_STEAM_UPDATE_EVENT     CONSTANT VARCHAR2(240) := 'oracle.apps.as.customer.update_salesteam';

INT_OPPTY_UPDATE_EVENT      CONSTANT VARCHAR2(240) := 'oracle.apps.as.opportunity.int_update_header';
INT_OPP_LINES_UPDATE_EVENT  CONSTANT VARCHAR2(240) := 'oracle.apps.as.opportunity.int_update_lines';
-- The Below internal event is for both Opportunity and customer Sales Teams
INT_STEAM_UPDATE_EVENT      CONSTANT VARCHAR2(240) := 'oracle.apps.as.opportunity.int_update_salesteam';

-- Start of Comments
--
-- NAME
--   AS_BUSINESS_EVENT_PVT
--
-- PURPOSE
--   This package is a private package which contains procedures and functions
--   to raise opportunity related business events.  This is NOT an API package
--
--   Procedures:
--
--
--
-- HISTORY
--   9/17/03        SUMAHALI            created
--
-- End of Comments

PROCEDURE raise_event
----------------------------------------------
-- Check if Event exist
-- Check if Event is like 'oracle.apps.as.%'
-- Get the item_key
-- Raise event
----------------------------------------------
(p_event_name          IN   VARCHAR2,
 p_event_key           IN   VARCHAR2,
 p_data                IN   CLOB DEFAULT NULL,
 p_parameters          IN   wf_parameter_list_t DEFAULT NULL);

PROCEDURE Before_Oppty_Update(
    p_lead_id   IN NUMBER,
    x_event_key OUT NOCOPY VARCHAR2
);

PROCEDURE Update_oppty_post_event(
    p_lead_id   IN NUMBER,
    p_event_key IN VARCHAR2
);

PROCEDURE Before_Opp_Lines_Update(
    p_lead_id   IN NUMBER,
    x_event_key OUT NOCOPY VARCHAR2
);

PROCEDURE Upd_Opp_Lines_post_event(
    p_lead_id   IN NUMBER,
    p_event_key IN VARCHAR2
);

PROCEDURE Before_Opp_STeam_Update(
    p_lead_id   IN NUMBER,
    x_event_key OUT NOCOPY VARCHAR2
);

PROCEDURE Upd_Opp_STeam_post_event(
    p_lead_id   IN NUMBER,
    p_event_key IN VARCHAR2
);

PROCEDURE Before_Cust_STeam_Update(
    p_cust_id   IN NUMBER,
    x_event_key OUT NOCOPY VARCHAR2
);

PROCEDURE Upd_Cust_STeam_post_event(
    p_cust_id   IN NUMBER,
    p_event_key IN VARCHAR2
);

FUNCTION Event_data_delete
-- Rule function for event data deletions used as the last subscription to AS events
 (p_subscription_guid  IN RAW,
  p_event              IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2;

FUNCTION Raise_update_oppty_event (
    p_subscription_guid     IN RAW,
    p_event                 IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Raise_upd_opp_lines_evnt (
    p_subscription_guid     IN RAW,
    p_event                 IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Raise_upd_STeam_evnt (
    p_subscription_guid     IN RAW,
    p_event                 IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

-- This function is for subscribing, for testing/debugging of business events,
-- to business events raised by Opportunity and customer sales team modules
-- which log data to as_event_data table. It creates a new event_key like
-- 'debug<sequence>', The first rows contain the parameters one by one. The
-- parameter name is stored in CHAR01 and value in CHAR02. The subsequent rows
-- contain as_event_data corresponding to the event key received.
-- The original event key is stored in CHAR80.
-- It is the users responsibility to delete these debug rows from the
-- as_event_data table.
FUNCTION Test_event
-- Rule function for event data deletions used as the last subscription to AS events
 (p_subscription_guid  IN RAW,
  p_event              IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2;

END AS_BUSINESS_EVENT_PVT;

 

/
