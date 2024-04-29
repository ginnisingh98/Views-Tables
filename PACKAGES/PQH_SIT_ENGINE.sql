--------------------------------------------------------
--  DDL for Package PQH_SIT_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SIT_ENGINE" AUTHID CURRENT_USER  as
/* $Header: pqsiteng.pkh 120.0 2005/05/29 02:42 appldev noship $ */
g_package varchar2(30) := 'pqh_sit_engine';
Function GET_TRANSACTION_VALUE (p_person_id      IN  number,
                                p_effective_date in date,
                                p_attribute_id   IN  number) RETURN  varchar2 ;

function check_attribute_result(p_rule_from in varchar2,
                                p_txn_value in varchar2,
                                p_rule_to   in varchar2,
                                p_value_style_cd in varchar2,
                                p_exclude_flag in varchar2) return BOOLEAN ;

PROCEDURE apply_defined_rules(p_stat_sit_id    IN number,
                              p_person_id      IN number,
                              p_effective_date IN DATE,
                              p_rule_type      IN VARCHAR2 DEFAULT 'REQUIRED',
                              p_status_flag    OUT NOCOPY varchar2) ;

Function is_situation_valid(p_person_id NUMBER,
                               p_effective_date IN DATE,
                               p_statutory_situation_id NUMBER) RETURN VARCHAR2;
end pqh_sit_engine;

 

/
