--------------------------------------------------------
--  DDL for Package POS_APPR_REJ_SUPP_EVENT_RAISE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_APPR_REJ_SUPP_EVENT_RAISE" AUTHID CURRENT_USER AS
 /* $Header: POSSPARES.pls 120.0.12010000.2 2010/02/08 14:09:37 ntungare noship $ */
-- Author  : JAYASANKAR
-- Created : 12/7/2009 12:26:54 PM
-- Purpose :

-- Public type declarations
FUNCTION raise_appr_rej_supp_event(p_event_name VARCHAR2,param1 VARCHAR2,
                                       param2 VARCHAR2) RETURN NUMBER ;
----Test Subscriptions to be deleted later-------
FUNCTION app_supp_subscription(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)RETURN VARCHAR2;
FUNCTION app_supp_user_subscription(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)RETURN VARCHAR2;
FUNCTION rej_supp_subscription(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)RETURN VARCHAR2;
FUNCTION rej_supp_user_subscription(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)RETURN VARCHAR2;
END pos_appr_rej_supp_event_raise;

/
