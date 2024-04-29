--------------------------------------------------------
--  DDL for Package PVX_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_EVENT_PKG" AUTHID CURRENT_USER AS
/*$Header: pvxbuevs.pls 115.0 2003/07/15 08:15:27 nramu noship $ */

 FUNCTION item_key(p_event_name  IN VARCHAR2) RETURN VARCHAR2;
 -----------------------------------------------------
 -- Return Item_Key according to PV Event to be raised
 -- Item_Key is <Event_Name>-pvwfapp_s.nextval
 -----------------------------------------------------

 FUNCTION check_event(p_event_name IN VARCHAR2) RETURN VARCHAR2;
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
 -- Check if Event is like 'oracle.apps.pv.%'
 -- Get the item_key
 -- Raise event
 ----------------------------------------------
 (p_event_name          IN   VARCHAR2,
  p_event_key           IN   VARCHAR2,
  p_data                IN   CLOB DEFAULT NULL,
  p_parameters          IN   wf_parameter_list_t DEFAULT NULL);

END pvx_event_pkg;

 

/
