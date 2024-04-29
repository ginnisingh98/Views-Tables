--------------------------------------------------------
--  DDL for Package PAY_AU_PAYMENT_SUMMARY_AMEND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PAYMENT_SUMMARY_AMEND" AUTHID CURRENT_USER AS
/* $Header: pyaupsam.pkh 120.0.12010000.1 2008/10/13 13:20:47 avenkatk noship $ */

TYPE  archive_db_rec IS RECORD (db_item_name  ff_user_entities.user_entity_name%TYPE
                                ,db_item_value ff_archive_items.value%TYPE
                                );

TYPE archive_db_tab IS TABLE OF archive_db_rec INDEX BY BINARY_INTEGER;


PROCEDURE range_code
        (p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE,
         p_sql                OUT nocopy VARCHAR2);

PROCEDURE initialization_code
        (p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE);

PROCEDURE assignment_action_code
    (p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE,
     p_start_person_id    IN per_all_people_f.person_id%TYPE,
     p_end_person_id      IN per_all_people_f.person_id%TYPE,
     p_chunk              IN NUMBER);

PROCEDURE populate_user_entity_types;

FUNCTION check_user_entity_type(p_user_entity_name IN ff_user_entities.user_entity_name%TYPE)
RETURN VARCHAR2;

PROCEDURE modify_and_archive_code
        (p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%TYPE
        ,p_effective_date        IN DATE
        ,p_all_tab_new           IN archive_db_tab);


PROCEDURE spawn_data_file
        (p_payroll_action_id IN pay_payroll_actions.payroll_action_id%TYPE);


END pay_au_payment_summary_amend;

/
