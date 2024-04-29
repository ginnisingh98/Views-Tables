--------------------------------------------------------
--  DDL for Package PER_HU_EMP_CERT_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_EMP_CERT_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pehuecar.pkh 115.1 2004/03/26 05:35:50 grchandr noship $ */


FUNCTION get_parameter(
         p_parameter_string IN VARCHAR2
        ,p_token            IN VARCHAR2
         ) RETURN VARCHAR2;

PROCEDURE get_all_parameters(p_payroll_action_id  IN         NUMBER
                            ,p_business_group_id  OUT NOCOPY NUMBER
                            ,p_start_date         OUT NOCOPY DATE
                            ,p_end_date           OUT NOCOPY DATE
                            ,p_payroll_id         OUT NOCOPY NUMBER
                            ,p_issue_date         OUT NOCOPY DATE
                            );

PROCEDURE range_code(p_actid IN  NUMBER
                    ,sqlstr OUT NOCOPY VARCHAR2);

PROCEDURE action_creation_code (p_actid    IN NUMBER
                               ,stperson  IN NUMBER
                               ,endperson IN NUMBER
                               ,chunk     IN NUMBER);

PROCEDURE archive_code (p_assactid       in number,
                          p_effective_date in date);

PROCEDURE get_person_address(p_person_id          IN NUMBER
                         ,p_assactid              IN NUMBER
                         ,p_assignment_id         IN NUMBER
                         ,p_termination_date      IN DATE
                         ,p_effective_date        IN DATE
                         );

PROCEDURE get_employee_data(p_assactid              IN NUMBER
                           ,p_assignment_id         IN OUT NOCOPY NUMBER
                           ,p_effective_date        IN DATE
                           ,p_person_id             IN OUT NOCOPY NUMBER
                           ,p_end_date              IN OUT NOCOPY DATE
                           );

END per_hu_emp_cert_archive;

 

/
