--------------------------------------------------------
--  DDL for Package PQH_BDGT_REALLOC_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_REALLOC_LOG_PKG" AUTHID CURRENT_USER AS
/* $Header: pqbpllog.pkh 115.0 2003/02/06 15:23:29 kgowripe noship $ */
--
-- Start Log for a given entity (Folder/Transaction/Transaction Entity)
--
PROCEDURE  start_log(p_folder_id IN Number Default Null
                    ,p_transaction_id IN Number Default Null
                    ,p_entity_id IN Number Default Null
                    ,p_txn_entity_type IN varchar2 -- T/R/D
                    ,p_bdgt_entity_type IN varchar2 Default Null);

PROCEDURE log_rule_for_entity(p_folder_id IN NUMBER
                             ,p_transaction_id IN NUMBER
                             ,p_txn_entity_type IN varchar2 --(D/R)
                             ,p_bdgt_entity_type IN varchar2 Default Null
                             ,p_entity_id IN NUMBER  Default NULL
                             ,p_budget_period_id IN NUMBER Default NULL
                             ,p_rule_name IN varchar2  Default NULL
                             ,p_rule_level IN varchar2
                             ,p_rule_msg_cd IN Varchar2 );
PROCEDURE end_log(p_txn_entity_type IN varchar2
                 ,p_folder_id IN NUMBER DEFAULT NULL
                 ,p_transaction_id IN NUMBER DEFAULT NULL
                 ,p_entity_id IN NUMBER DEFAULT NULL);

END pqh_bdgt_realloc_log_pkg;

 

/
