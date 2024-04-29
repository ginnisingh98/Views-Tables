--------------------------------------------------------
--  DDL for Package PAY_GB_P11D_CAR_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_P11D_CAR_EXTRACT" AUTHID CURRENT_USER AS
/* $Header: pygb11ce.pkh 120.0.12010000.1 2008/07/27 22:42:56 appldev ship $ */

FUNCTION get_prim_asg_start_date(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_asg_end_date(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_ben_start_date(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_ben_start_date(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_ben_end_date(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_ben_end_date(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_vin(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_vin(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_make(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_make(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_model(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_model(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_dfr(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_dfr(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_price(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_price(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_fuel_type(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_fuel_type(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_co2_emi(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_co2_emi(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_optional_acc(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_optional_acc(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_acc_added_after(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_capital_contrib(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_capital_contrib(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_private_contrib(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_private_contrib(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_engine_capacity(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_engine_capacity(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_fuel_benefit(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_fuel_benefit(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prim_vehicle_details_id(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_fuel_reinstated(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_free_fuel_withdrawn(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION prim_additional_fuel_days(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION check_person_inclusion(p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION post_process_rule(p_ext_rslt_id IN NUMBER) RETURN VARCHAR2;

FUNCTION post_process_rule_04(p_ext_rslt_id IN NUMBER) RETURN VARCHAR2;


END pay_gb_p11d_car_extract;

/
