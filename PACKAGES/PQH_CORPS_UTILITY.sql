--------------------------------------------------------
--  DDL for Package PQH_CORPS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CORPS_UTILITY" AUTHID CURRENT_USER as
/* $Header: pqcpdutl.pkh 120.0 2005/05/29 01:45:02 appldev noship $ */

Procedure review_submit_valid_corps(p_copy_entity_txn_id IN NUMBER,
                                    p_effective_date IN DATE,
                                    p_business_group_id IN NUMBER,
                                    p_status OUT NOCOPY VARCHAR2);

Function get_step_name(p_step_id IN Number,
                       p_effective_date IN Date) RETURN varchar2;

Function get_increased_index(p_gross_index IN NUMBER,
                             p_effective_date IN date) Return Number;

Function get_salary_rate(p_gross_index IN NUMBER,
                         p_effective_date IN DATE,
                         p_copy_entity_txn_id IN NUMBER DEFAULT NULL,
                         p_currency_code  IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

Function get_increased_index(p_gross_index IN NUMBER,
                             p_copy_entity_txn_id IN NUMBER) RETURN NUMBER;

Function get_global_basic_sal_rate(p_effective_date in DATE) RETURN NUMBER;

Function get_cet_business_area(p_copy_entity_txn_id IN Number) return Varchar2;

Function get_step_name_for_hgrid(p_step_id IN Number, p_effective_date IN DATE) RETURN VARCHAR2;

Function get_bg_type_of_ps(p_business_group_id IN NUMBER) RETURN VARCHAR2;

Function get_cpd_status(p_node_number IN varchar2,
                        p_copy_entity_txn_id IN NUMBER) RETURN VARCHAR2;

Function chk_steps_exist_for_index(p_gross_index IN NUMBER) RETURN VARCHAR2;

FUNCTION  bus_area_pgm_entity_exist(p_bus_area_cd IN Varchar2,
                                    P_pgm_id IN NUMBER)
RETURN varchar2;

FUNCTION chk_primary_prof_field(p_corps_definition_id IN NUMBER
                               ,p_field_of_prof_activity_id IN NUMBER)
RETURN VARCHAR2;
FUNCTION chk_corps_info_exists(p_corps_definition_id IN NUMBER
                              ,p_information_type IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_corps_name(p_corps_definition_id IN VARCHAR2) Return Varchar2;

FUNCTION los_in_months(p_los_years IN Number,
                       p_los_months IN Number,
                       p_los_days   IN Number) Return Number;

FUNCTION get_from_step_name( p_step_cer_id        IN  Number,
                             p_copy_entity_txn_id IN  Number) Return Varchar2;

Procedure update_or_delete_crpath ( p_crpath_cer_id    IN  Number,
                                p_effective_date       IN  Date,
                                p_dml_operation        IN Varchar2);

Function decode_stage_entity(p_copy_entity_txn_id IN NUMBER,
                             p_table_alias        IN VARCHAR2,
                             p_copy_entity_result_id IN NUMBER) RETURN VARCHAR2;

FUNCTION is_career_def_exist(p_Copy_Entity_txn_Id IN NUMBER,
                             p_mirror_src_entity_rslt_id IN Number,
                             p_from_step_id IN NUMBER,
                             p_to_corps_id IN Number,
                             p_to_grade_id In Number,
                             p_to_step_id In Number ,
                             p_copy_entity_result_id In Number) RETURN VARCHAR2;

FUNCTION get_pgm_id (p_corps_definition_id IN NUMBER)   RETURN NUMBER;


function get_date_of_placement(p_career_level in varchar2, p_assignment_id in number,
                               p_career_level_id in number)
    return date;

   FUNCTION get_gross_index (p_step_id IN NUMBER, p_effective_date IN DATE)
      RETURN NUMBER;
 Function get_postStyle_of_grdldr(p_txn_id in varchar2) return varchar2;

End pqh_corps_utility;

 

/
