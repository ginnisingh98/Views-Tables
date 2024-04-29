--------------------------------------------------------
--  DDL for Package CSF_WF_EVENT_SUBSCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_WF_EVENT_SUBSCR_PKG" AUTHID CURRENT_USER as
/* $Header: csfwfevs.pls 120.1 2005/08/30 09:11:18 rhungund noship $ */
-- Start of Comments
-- Package name     : CSF_WF_EVENT_SUBSCR_PKG
-- Purpose          : Preventive Maintenance Business Event Subscription API
-- History          : Initial Version for release 11.5.9


  FUNCTION VALIDATE_SR_FOR_DEBRIEF(
               p_service_request_number IN         VARCHAR2
	      ) RETURN VARCHAR2;

  FUNCTION CSF_VERIFY_PM_SR(p_subscription_guid in raw,
                            p_event in out nocopy WF_EVENT_T) RETURN varchar2;

END CSF_WF_EVENT_SUBSCR_PKG; -- Package spec

 

/
