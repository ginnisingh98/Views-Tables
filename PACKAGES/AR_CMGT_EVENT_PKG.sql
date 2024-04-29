--------------------------------------------------------
--  DDL for Package AR_CMGT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_EVENT_PKG" AUTHID CURRENT_USER AS
/*$Header: ARCMBEVS.pls 115.3 2002/10/30 15:12:20 apandit noship $ */

 FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2;

 FUNCTION item_key(p_event_name  IN VARCHAR2,
                   p_unique_identifier IN NUMBER) RETURN VARCHAR2;

 FUNCTION event(p_event_name IN VARCHAR2) RETURN VARCHAR2;
 -----------------------------------------------
 -- Return event name if the entered event exist
 -- Otherwise return NOTFOUND
 -----------------------------------------------

 PROCEDURE AddParamEnvToList
 ------------------------------------------------------
 -- Add Application-Context parameter to the enter list
 ------------------------------------------------------
 ( x_list              IN OUT NOCOPY  WF_PARAMETER_LIST_T,
   p_user_id           IN VARCHAR2  DEFAULT NULL,
   p_resp_id           IN VARCHAR2  DEFAULT NULL,
   p_resp_appl_id      IN VARCHAR2  DEFAULT NULL,
   p_security_group_id IN VARCHAR2  DEFAULT NULL,
   p_org_id            IN VARCHAR2  DEFAULT NULL);

 PROCEDURE raise_event
 ----------------------------------------------
 -- Check if Event exist
 -- Check if Event is like 'oracle.apps.ar.cmgt%'
 -- Get the item_key
 -- Raise event
 ----------------------------------------------
 (p_event_name          IN   VARCHAR2,
  p_event_key           IN   VARCHAR2,
  p_data                IN   CLOB DEFAULT NULL,
  p_parameters          IN   wf_parameter_list_t DEFAULT NULL);

END;

 

/
