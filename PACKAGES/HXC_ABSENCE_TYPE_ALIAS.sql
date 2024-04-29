--------------------------------------------------------
--  DDL for Package HXC_ABSENCE_TYPE_ALIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ABSENCE_TYPE_ALIAS" AUTHID CURRENT_USER AS
/* $Header: hxcabstypealias.pkh 120.0.12010000.6 2010/01/07 13:51:59 amakrish noship $ */

    PROCEDURE ins_otl_abs_type_elements_temp(p_tc_abs_type_alias_def_id IN hxc_alias_definitions_tl.alias_definition_id%TYPE,
                                            p_tc_abs_payroll_id IN pay_payrolls_f.payroll_id%TYPE,
                                            p_tc_abs_element_set_id IN pay_element_sets_tl.element_set_id%TYPE,
                                            p_tc_abs_absence_type_id IN per_abs_attendance_types_tl.absence_attendance_type_id%TYPE);

    PROCEDURE create_alias_definition(p_alias_definition_id OUT nocopy NUMBER,
                                      p_alias_definition_name IN VARCHAR2,
                                      p_object_version_number OUT nocopy NUMBER,
                                      p_alias_definition_name_exists OUT nocopy VARCHAR2);

    PROCEDURE create_alias_value(p_alias_value_name IN VARCHAR2,
                                 p_alias_definition_id IN NUMBER,
                                 p_attribute1 IN VARCHAR2 DEFAULT NULL,
                                 p_date_from IN VARCHAR2,
                                 p_date_to   IN VARCHAR2,
                                 p_alias_value_name_exists OUT nocopy VARCHAR2);

    PROCEDURE create_time_category(p_time_category_name IN VARCHAR2,
                                   p_description        IN VARCHAR2,
                                   p_time_category_id      OUT nocopy NUMBER,
                                   p_object_version_number OUT nocopy NUMBER,
                                   p_component_type_id     OUT nocopy NUMBER,
                                   p_time_category_exists  OUT nocopy VARCHAR2);

    PROCEDURE create_time_category_comp(p_time_category_id  IN NUMBER,
    					p_value_id          IN VARCHAR2,
    					p_component_type_id IN NUMBER,
                                 	p_time_category_comp_exists OUT nocopy VARCHAR2);



END hxc_absence_type_alias;



/
