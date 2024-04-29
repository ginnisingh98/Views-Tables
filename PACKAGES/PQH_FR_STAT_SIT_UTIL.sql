--------------------------------------------------------
--  DDL for Package PQH_FR_STAT_SIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_STAT_SIT_UTIL" AUTHID CURRENT_USER AS
/* $Header: pqstsutl.pkh 120.0 2005/05/29 02:44 appldev noship $ */


/* Following three functions will be used in FR PS Predefined Statutory Situations
   Get_txn_catg_attr_meaning 	: Returns the valueset meaning for a given Situation Id.
    Get_txn_value_query		: Returns gets the value set query for a given transaction category attribute id
    Rules_exist			: Checks whether rules exist for a given situation or not
*/
    FUNCTION Get_txn_catg_attr_meaning(p_stat_situation_rule_id NUMBER, p_value_for varchar2 DEFAULT 'FROM') return VARCHAR2;
    FUNCTION Get_txn_value_query (p_txn_category_attribute_id NUMBER) return VARCHAR2;
    FUNCTION Rules_exist(p_stat_situation_id NUMBER) return VARCHAR2;
    FUNCTION  Is_input_is_valid(p_txn_category_attribute_id NUMBER, p_from_value varchar2 ) return varchar2;
   /* following functions are added for transaction attributes processing */
   Function get_los_in_ps  ( p_person_id IN    NUMBER default NULL,
                              p_determination_date  IN    DATE default NULL)
                              return number;
     Function get_general_los (p_person_id IN    NUMBER default NULL,
                              p_determination_date  IN    DATE default NULL)
                              return number;
    Function get_employee_type (p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_determination_date IN DATE) return varchar2;
    Function get_situation_type (p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_determination_date IN DATE) return varchar2;
    Function get_relationship_type  (p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_determination_date IN DATE) return varchar2;
    Function get_dependent_age  (p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_determination_date IN DATE) return number;
  --
    FUNCTION is_situation_renewable(p_emp_stat_situation_id  NUMBER,
                                    p_statutory_situation_id NUMBER) RETURN VARCHAR2;
  --
    FUNCTION get_number_of_renewals(p_emp_stat_situation_id NUMBER) RETURN NUMBER;
  --
  --deenath - New function to get number of renewals created since in Update Renewal Situation,
  --we dont want to count the situation being updated as a renewal
    FUNCTION get_num_renewals(p_emp_stat_situation_id   IN NUMBER,
                              p_renew_stat_situation_id IN NUMBER) RETURN NUMBER;
  --
    Function is_situation_valid(p_person_id NUMBER,
                                p_emp_stat_situation_id NUMBER,
                                p_statutory_situation_id NUMBER) RETURN VARCHAR2 ;
   FUNCTION chk_rule_condition(p_emp_stat_situation_id   IN NUMBER,
                               p_statutory_situation_id  IN NUMBER,
                               p_txn_category_attribute_id IN NUMBER,
                               p_from_value              IN VARCHAR2,
                               p_to_value                IN VARCHAR2,
                               p_negate                  IN VARCHAR2) RETURN BOOLEAN;
   Function is_current_situation(p_emp_stat_situation_id NUMBER) RETURN varchar2;
   Function get_dflt_situation(p_business_group_id IN NUMBER,
                               p_situation_type IN VARCHAR2,
                               p_sub_type IN VARCHAR2 DEFAULT NULL,
                               p_effective_date IN DATE DEFAULT SYSDATE) RETURN NUMBER ;
   Function get_time_line(p_provisional_start_date IN DATE, p_provisional_end_date IN DATE,
                          p_effective_date IN DATE) RETURN VARCHAR2;
--   Function get_time_line_code(p_provisional_start_date IN DATE, p_provisional_end_date IN DATE,
--                          p_effective_date IN DATE) RETURN VARCHAR2;
   FUNCTION get_time_line_code(p_provisional_start_date IN DATE,
                               p_actual_end_date        IN DATE,
                               p_provisional_end_date   IN DATE,
                               p_effective_date         IN DATE) RETURN VARCHAR2;
  FUNCTION get_update_time_line_code(p_provisional_start_date IN DATE,
                                     p_provisional_end_date   IN DATE,
                                     p_effective_date         IN DATE,
                                     p_approval_flag          IN VARCHAR2,
                                     p_renew_flag             IN VARCHAR2,
                                     p_situation_type         IN VARCHAR2,
                                     p_sub_type               IN VARCHAR2,
                                     p_default_flag           IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION get_delete_time_line_code(p_person_id              IN NUMBER,
                                     p_provisional_start_date IN DATE,
                                     p_provisional_end_date   IN DATE,
                                     p_effective_date         IN DATE) RETURN VARCHAR2;

End pqh_fr_stat_sit_util;

 

/
