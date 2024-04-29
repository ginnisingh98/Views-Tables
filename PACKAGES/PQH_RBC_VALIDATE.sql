--------------------------------------------------------
--  DDL for Package PQH_RBC_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RBC_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: pqrbcval.pkh 120.1 2006/03/02 03:32 srenukun noship $ */

--checks if matrix has atleast one criteira added
function matrix_has_criteria(p_copy_entity_txn_id in number) return varchar2;
--checks if matrix has atleast one criteira values added
function matrix_has_criteria_values(p_copy_entity_txn_id in number) return varchar2;
--checks if matrix has atleast one criteira nodes added
function matrix_has_criteria_nodes(p_copy_entity_txn_id in number) return varchar2;
--checks if matrix has atleast one rate type added
function matrix_has_rate_type(p_copy_entity_txn_id in number) return varchar2;
--checks if matrix has duplicate criteria added
function matrix_has_criteria_dup(p_copy_entity_txn_id in number) return varchar2;
--checks if matrix has used plan name already existing
function plan_name_exists(l_pl_id in number,p_name in varchar2, p_business_group_id in number) return varchar2;
--checks if matrix has used plan short code already existing
function plan_short_code_exists(l_pl_id in number,p_short_code in varchar2, p_business_group_id in number) return varchar2;
--checks if matrix has used plan short name already existing
function plan_short_name_exists(l_pl_id in number,p_short_name in varchar2, p_business_group_id in number) return varchar2;
--checks if matrix has rates
function matrix_has_rates(p_copy_entity_txn_id in number) return varchar2;

--checks if matrix has used plan already existing
-- it in turn calls plan_short_code_exists,plan_name_exists,plan_short_name_exists
function check_plan_duplicate(p_copy_entity_txn_id in number)return varchar2;
-- checks if rate type is added twice
function matrix_has_ratetype_dup(p_copy_entity_txn_id in number) return varchar2;

-- checks if we have any criteria values added twice
-- it takes help of check_critval_dup_in_rmn,check_critval_row to make it more modular
function check_critval_dup_in_txn(p_copy_entity_txn_id number) return varchar2;
function check_critval_dup_in_rmn(p_copy_entity_result_id_node number,p_copy_entity_result_id_val number) return varchar2;
function check_critval_row  (p_copy_entity_result_id_row1 number
                            ,p_copy_entity_result_id_row2 number
                            ) return varchar2 ;

-- MAIN FUCTION TO BE CALLED
procedure check_warnings(p_copy_entity_txn_id in number,p_status out nocopy varchar2,p_warning_message out nocopy varchar2);
--validation before submit to be called
procedure pre_validate_matrix(p_copy_entity_txn_id in number,p_status out nocopy varchar2);
-- validations on submit button called
procedure on_validate_matrix(p_copy_entity_txn_id in number,p_status out nocopy varchar2);
-- all validations on before and on submit
procedure validate_matrix(p_copy_entity_txn_id in number,p_status out nocopy varchar2);


end PQH_RBC_VALIDATE;

 

/
