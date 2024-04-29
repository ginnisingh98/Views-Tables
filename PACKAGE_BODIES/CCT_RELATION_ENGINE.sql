--------------------------------------------------------
--  DDL for Package Body CCT_RELATION_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_RELATION_ENGINE" as
/* $Header: cctureeb.pls 120.0 2005/06/02 09:37:18 appldev noship $ */

  PROCEDURE delete_interaction_keys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER)
    IS
      -- Enter the procedure variables here. As shown below
      --  variable_name        datatype  NOT NULL DEFAULT default_value;
      l_code CCT_INTERACTION_KEYS.INTERACTION_KEY%TYPE;
   BEGIN
         -- Standard Start of API savepoint
        SAVEPOINT  delete_interaction_keys_pt;

        l_code :=  get_interaction_key_code(p_interaction_key_id);

        delete cct_interaction_keys
        where interaction_key_id = p_interaction_key_id;

        -- delete  data from related tables
        delete_class_rule_ikeys(p_interaction_key_id, p_user_id, l_code);

        delete_ivr_ikeys(p_interaction_key_id, p_user_id, l_code);

        delete_route_param_ikeys(p_interaction_key_id, p_user_id, l_code);

        delete_softphone_ikeys(p_interaction_key_id, p_user_id, l_code);

   EXCEPTION
      WHEN others THEN
          ROLLBACK TO delete_interaction_keys_pt;
   END delete_interaction_keys;

   PROCEDURE delete_rt_class_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER)
   IS
      -- Enter the procedure variables here. As shown below
      --  variable_name        datatype  NOT NULL DEFAULT default_value;
      l_code CCT_INTERACTION_KEYS.INTERACTION_KEY%TYPE;
   BEGIN
         -- Standard Start of API savepoint
        SAVEPOINT  delete_rt_class_ikeys_pt;

        l_code :=  get_interaction_key_code(p_interaction_key_id);

        -- delete  data from related tables
        delete_class_rule_ikeys(p_interaction_key_id, p_user_id, l_code);

        delete_route_param_ikeys(p_interaction_key_id, p_user_id, l_code);

   EXCEPTION
      WHEN others THEN
          ROLLBACK TO delete_rt_class_ikeys_pt;
   END delete_rt_class_ikeys;


   FUNCTION get_interaction_key_code
     ( p_interaction_key_id IN NUMBER)
   RETURN VARCHAR2
   IS
     l_code CCT_INTERACTION_KEYS.INTERACTION_KEY%TYPE;
   BEGIN

        select interaction_key into l_code
        from cct_interaction_keys
        where interaction_key_id = p_interaction_key_id;

   RETURN l_code;
   END  get_interaction_key_code;


   PROCEDURE delete_class_rule_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER)
   IS
     l_code CCT_INTERACTION_KEYS.INTERACTION_KEY%TYPE;
   BEGIN

     l_code := get_interaction_key_code(p_interaction_key_id);
     delete_class_rule_ikeys(p_interaction_key_id, p_user_id, l_code);
   END   delete_class_rule_ikeys;


   PROCEDURE delete_class_rule_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER, p_interaction_key_code IN VARCHAR2)
   IS
   BEGIN

        update cct_classification_rules
        set f_deletedflag ='D', last_updated_by = p_user_id, last_update_date = sysdate
        where key = p_interaction_key_code;


   END  delete_class_rule_ikeys;

   PROCEDURE delete_route_param_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER)
   IS
     l_code CCT_INTERACTION_KEYS.INTERACTION_KEY%TYPE;
   BEGIN
     l_code := get_interaction_key_code(p_interaction_key_id);
     delete_route_param_ikeys(p_interaction_key_id, p_user_id, l_code);
   END delete_route_param_ikeys;

   PROCEDURE delete_route_param_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER, p_interaction_key_code IN VARCHAR2)
   IS
   BEGIN

        update cct_route_params
        set f_deletedflag = 'D', last_updated_by = p_user_id, last_update_date = sysdate
        where param = p_interaction_key_code
        and sequence is null;

   END delete_route_param_ikeys;

   PROCEDURE delete_ivr_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER)
   IS
     l_code CCT_INTERACTION_KEYS.INTERACTION_KEY%TYPE;
   BEGIN
     l_code := get_interaction_key_code(p_interaction_key_id);
     delete_ivr_ikeys(p_interaction_key_id, p_user_id, l_code);
   END delete_ivr_ikeys;

   PROCEDURE delete_ivr_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER, p_interaction_key_code IN VARCHAR2)
   IS
   BEGIN

        update cct_ivr_maps
        set f_deletedflag = 'D', last_updated_by = p_user_id, last_update_date = sysdate
        where interaction_key_id = p_interaction_key_id;

   END delete_ivr_ikeys;


   PROCEDURE delete_softphone_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER)
   IS
     l_code CCT_INTERACTION_KEYS.INTERACTION_KEY%TYPE;
   BEGIN
     l_code := get_interaction_key_code(p_interaction_key_id);
     delete_softphone_ikeys(p_interaction_key_id, p_user_id, l_code);
   END delete_softphone_ikeys;

   PROCEDURE delete_softphone_ikeys
     ( p_interaction_key_id IN NUMBER, p_user_id IN NUMBER, p_interaction_key_code IN VARCHAR2)
   IS
   BEGIN
    null;
   /*
        update cct_ivr_maps
        set f_deletedflag = 'D', last_updated_by = p_user_id, last_update_date = sysdate
        where interaction_key_id = p_interaction_key_id;
   */
   END delete_softphone_ikeys;

END CCT_RELATION_ENGINE;

/
