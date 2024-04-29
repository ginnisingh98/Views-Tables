--------------------------------------------------------
--  DDL for Package HR_H2PI_PERSON_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_H2PI_PERSON_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: hrh2pipe.pkh 115.2 2002/03/07 15:36:31 pkm ship     $ */

g_to_business_group_id NUMBER(15);
g_request_id NUMBER(15);

PROCEDURE upload_person_level (p_from_client_id NUMBER);
PROCEDURE upload_person (p_from_client_id NUMBER,
                         p_person_id              NUMBER,
                         p_effective_start_date   DATE);
PROCEDURE delete_address (p_from_client_id NUMBER,
                          p_person_id              NUMBER);
PROCEDURE upload_address (p_from_client_id NUMBER,
                          p_address_id             NUMBER,
                          p_effective_start_date   DATE);
PROCEDURE terminate_person (p_from_client_id NUMBER,
                            p_person_id              NUMBER,
                            p_effective_start_date   DATE);
PROCEDURE upload_assignment (p_from_client_id NUMBER,
                             p_assignment_id          NUMBER,
                             p_effective_start_date   DATE);
PROCEDURE upload_period_of_service (p_from_client_id NUMBER,
                                    p_period_of_service_id   NUMBER,
                                    p_effective_start_date   DATE);
PROCEDURE upload_salary (p_from_client_id NUMBER,
                         p_pay_proposal_id        NUMBER,
                         p_effective_start_date   DATE);
PROCEDURE upload_payment_method (p_from_client_id     NUMBER,
                                 p_personal_payment_method_id NUMBER,
                                 p_effective_start_date       DATE);
PROCEDURE upload_cost_allocation (p_from_client_id NUMBER,
                                  p_cost_allocation_id     NUMBER,
                                  p_effective_start_date   DATE);
PROCEDURE upload_element_entry (p_from_client_id NUMBER,
                                p_element_entry_id       NUMBER,
                                p_effective_start_date   DATE);
PROCEDURE upload_federal_tax_record (p_from_client_id NUMBER,
                                     p_emp_fed_tax_rule_id    NUMBER,
                                     p_effective_start_date   DATE);
PROCEDURE upload_state_tax_record (p_from_client_id NUMBER,
                                   p_emp_state_tax_rule_id  NUMBER,
                                   p_effective_start_date   DATE);
PROCEDURE upload_county_tax_record (p_from_client_id NUMBER,
                                    p_emp_county_tax_rule_id NUMBER,
                                    p_effective_start_date   DATE);
PROCEDURE upload_city_tax_record (p_from_client_id NUMBER,
                                  p_emp_city_tax_rule_id   NUMBER,
                                  p_effective_start_date   DATE);
PROCEDURE create_end_date_records (p_from_client_id NUMBER);
PROCEDURE upload_tax_percentage ( p_from_client_id  NUMBER,
                                  p_person_id       NUMBER);


END hr_h2pi_person_upload;

 

/
