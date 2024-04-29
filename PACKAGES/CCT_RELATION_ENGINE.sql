--------------------------------------------------------
--  DDL for Package CCT_RELATION_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_RELATION_ENGINE" AUTHID CURRENT_USER as
/* $Header: ccturees.pls 115.4 2002/10/02 23:57:24 rajayara noship $ */

   PROCEDURE delete_interaction_keys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER);

   PROCEDURE delete_rt_class_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER);

   FUNCTION get_interaction_key_code
     ( p_interaction_key_id IN NUMBER)
   RETURN VARCHAR2;

     PROCEDURE delete_class_rule_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER);

     PROCEDURE delete_class_rule_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER, p_interaction_key_code IN VARCHAR2);

     PROCEDURE delete_route_param_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER);

     PROCEDURE delete_route_param_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER, p_interaction_key_code IN VARCHAR2);

     PROCEDURE delete_ivr_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER);

     PROCEDURE delete_ivr_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER, p_interaction_key_code IN VARCHAR2);

     PROCEDURE delete_softphone_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER);

     PROCEDURE delete_softphone_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER, p_interaction_key_code IN VARCHAR2);


END CCT_RELATION_ENGINE;

 

/
