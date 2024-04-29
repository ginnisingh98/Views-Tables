--------------------------------------------------------
--  DDL for Package Body PQH_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CONTEXT" as
/* $Header: pqhcntxt.pkb 120.0 2005/05/29 02:02:26 appldev noship $ */
   function get_global_context (p_context in varchar2) return varchar2
   is
      v_global_context  pqh_copy_entity_contexts.context%type;
      v_global_app      pqh_copy_entity_contexts.application_short_name%type;
      v_global_txn      pqh_copy_entity_contexts.transaction_short_name%type;
      v_global_resp     pqh_copy_entity_contexts.responsibility_key%type;
      v_global_legis    pqh_copy_entity_contexts.legislation_code%type;
      --
      v_local_context   pqh_copy_entity_contexts.context%type;
      v_local_app       pqh_copy_entity_contexts.application_short_name%type;
      v_local_txn       pqh_copy_entity_contexts.transaction_short_name%type;
      v_local_resp      pqh_copy_entity_contexts.responsibility_key%type;
      v_local_legis     pqh_copy_entity_contexts.legislation_code%type;
      --
      cursor c_current_context (p_context                 varchar2 default null
                      )
             is
             select context
                  , transaction_short_name
                  , application_short_name
                  , responsibility_key
                  , legislation_code
             from pqh_copy_entity_contexts cec
             where context                = p_context
             ;
      cursor c_global_context (p_txn_short_name          varchar2 default null
                             , p_current_context         varchar2 default null
                      )
             is
             select context
             from pqh_copy_entity_contexts cec
             where transaction_short_name = p_txn_short_name
             and   context               <> p_current_context
             and   application_short_name IS NULL
             and   responsibility_key     IS NULL
             and   legislation_code       IS NULL
             ;
      cursor c_app_context (p_txn_short_name          varchar2 default null
                          , p_app_short_name          varchar2 default null
                          , p_current_context         varchar2 default null
                      )
             is
             select context
             from pqh_copy_entity_contexts cec
             where transaction_short_name = p_txn_short_name
             and   application_short_name = p_app_short_name
             and   context               <> p_current_context
             and   responsibility_key     IS NULL
             and   legislation_code       IS NULL
             ;
      cursor c_resp_context (p_txn_short_name          varchar2 default null
                           , p_app_short_name          varchar2 default null
                           , p_resp_key                varchar2 default null
                           , p_current_context         varchar2 default null
                      )
             is
             select context
             from pqh_copy_entity_contexts cec
             where transaction_short_name = p_txn_short_name
             and   application_short_name = p_app_short_name
             and   responsibility_key     = p_resp_key
             and   context               <> p_current_context
             and   legislation_code       IS NULL
             ;
      cursor c_legis_context (p_txn_short_name          varchar2 default null
                            , p_app_short_name          varchar2 default null
                            , p_legis_code              varchar2 default null
                            , p_current_context         varchar2 default null
                      )
             is
             select context
             from pqh_copy_entity_contexts cec
             where transaction_short_name = p_txn_short_name
             and   application_short_name = p_app_short_name
             and   legislation_code       = p_legis_code
             and   context               <> p_current_context
             and   responsibility_key     IS NULL
             ;
   begin
       -- get passed context's information
       open c_current_context(p_context => p_context);
       fetch c_current_context into v_local_context
                          , v_local_txn
                          , v_local_app
                          , v_local_resp
                          , v_local_legis;
       close c_current_context;
       -- if there is no app defined then this is the global context
       IF v_local_app IS NULL THEN
          RETURN p_context;
       END IF;
       -- Try with App and Resp
       IF v_local_resp IS NOT NULL THEN
          open c_resp_context(p_txn_short_name => v_local_txn
                            , p_current_context=> p_context
                            , p_app_short_name => v_local_app
                            , p_resp_key       => v_local_resp);
          fetch c_resp_context into v_global_context;
          close c_resp_context;
          IF v_global_context IS NOT NULL THEN
              RETURN v_global_context;
          END IF;
       END IF;
       -- Try with App and Legis
       IF v_local_legis IS NOT NULL THEN
          open c_legis_context(p_txn_short_name => v_local_txn
                       , p_current_context=> p_context
                       , p_app_short_name => v_local_app
                       , p_legis_code     => v_local_legis);
          fetch c_legis_context into v_global_context;
          close c_legis_context;
          IF v_global_context IS NOT NULL THEN
              RETURN v_global_context;
          END IF;
       END IF;
       -- Try with App only
       open c_app_context(p_txn_short_name => v_local_txn
                    , p_current_context=> p_context
                    , p_app_short_name => v_local_app);
       fetch c_app_context into v_global_context;
       close c_app_context;
       IF v_global_context IS NOT NULL THEN
           RETURN v_global_context;
       END IF;
       -- get global context
       open c_global_context(p_txn_short_name => v_local_txn
                    , p_current_context=> p_context);
       fetch c_global_context into v_global_context;
       close c_global_context;
       IF v_global_context IS NOT NULL THEN
           RETURN v_global_context;
       END IF;
       RETURN null ; -- since no global context found.
   end;
end;

/
