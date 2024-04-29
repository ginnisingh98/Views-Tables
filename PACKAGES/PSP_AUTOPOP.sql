--------------------------------------------------------
--  DDL for Package PSP_AUTOPOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_AUTOPOP" AUTHID CURRENT_USER AS
--$Header: PSPAUTOS.pls 120.0.12000000.1 2007/01/18 12:03:13 appldev noship $

PROCEDURE main(
    p_acct_type        			IN VARCHAR2,
    p_person_id				IN NUMBER,
    p_assignment_id			IN NUMBER,
    p_element_type_id      		IN NUMBER,
    p_project_id                    IN NUMBER,
    p_expenditure_organization_id   IN NUMBER,
    p_task_id                       IN NUMBER,
    p_award_id                      IN NUMBER,
    p_expenditure_type              IN VARCHAR2,
    p_gl_code_combination_id        IN NUMBER,
    p_payroll_date			IN DATE,
    p_set_of_books_id                IN NUMBER,
    p_business_group_id              In NUMBER,
    ret_expenditure_type	      OUT NOCOPY VARCHAR2,
    ret_gl_code_combination_id      OUT NOCOPY NUMBER,
    retcode                         OUT NOCOPY VARCHAR2);


END;

 

/
