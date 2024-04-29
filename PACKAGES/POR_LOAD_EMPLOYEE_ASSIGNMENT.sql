--------------------------------------------------------
--  DDL for Package POR_LOAD_EMPLOYEE_ASSIGNMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_LOAD_EMPLOYEE_ASSIGNMENT" AUTHID CURRENT_USER as
/* $Header: PORLEMAS.pls 115.2 2002/11/19 00:35:22 jjessup ship $ */

PROCEDURE insert_update_employee_asg(
        x_person_id IN NUMBER,
        x_business_group_id IN NUMBER,
        x_location_name IN VARCHAR2,
        x_assignment_number IN OUT NOCOPY VARCHAR2,
        x_default_employee_account IN VARCHAR2,
        x_set_of_books_name IN VARCHAR2,
        x_job_name IN VARCHAR2,
        x_supervisor_emp_number IN VARCHAR2,
        x_effective_start_date IN DATE,
        x_effective_end_date IN DATE);

FUNCTION get_set_of_books_id(p_set_of_books_name IN VARCHAR2) RETURN NUMBER;

FUNCTION get_chart_of_accounts_id (p_set_of_books_id IN NUMBER) RETURN NUMBER;

FUNCTION get_ccid (p_chart_of_accounts_id IN NUMBER, p_concatenated_segs IN VARCHAR2) RETURN NUMBER;

PROCEDURE get_assignment_exists(p_person_id IN NUMBER,p_effective_start_date IN DATE, p_effective_end_date IN DATE,l_assignment_id OUT NOCOPY NUMBER,l_object_version_number OUT NOCOPY NUMBER);

FUNCTION get_job_id (p_job_name IN VARCHAR2, p_business_group_id IN NUMBER) RETURN NUMBER;

FUNCTION get_supervisor_id(x_supervisor_emp_num IN VARCHAR2) RETURN NUMBER;

FUNCTION get_address_exists(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION get_location_id (p_location_name IN VARCHAR2) RETURN NUMBER;
END POR_LOAD_EMPLOYEE_ASSIGNMENT;

 

/
