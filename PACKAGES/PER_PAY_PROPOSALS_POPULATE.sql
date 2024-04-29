--------------------------------------------------------
--  DDL for Package PER_PAY_PROPOSALS_POPULATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PAY_PROPOSALS_POPULATE" AUTHID CURRENT_USER AS
/* $Header: pepaprpo.pkh 120.0.12000000.1 2007/01/22 00:42:58 appldev ship $*/


  PROCEDURE GET_GRADE(p_date                         DATE,
                      p_assignment_id                NUMBER,
                      p_business_group_id            NUMBER,
                      p_grade                    OUT NOCOPY VARCHAR2,
                      p_minimum_salary           OUT NOCOPY NUMBER,
                      p_maximum_salary           OUT NOCOPY NUMBER,
                      p_midpoint_salary          OUT NOCOPY NUMBER,
                      p_grade_uom                OUT NOCOPY VARCHAR2);

  PROCEDURE GET_ELEMENT_ID(p_assignment_id     IN    NUMBER,
                       p_business_group_id     IN    NUMBER,
                       p_change_date           IN    DATE,
                       p_payroll_value           OUT NOCOPY NUMBER,
                       p_element_entry_id        OUT NOCOPY NUMBER);

  PROCEDURE GET_CURRENCY_FORMAT(curcode              VARCHAR2,
                                fstring       IN OUT NOCOPY VARCHAR2);

  PROCEDURE GET_NUMBER_FORMAT(fstring IN OUT NOCOPY VARCHAR2);

  PROCEDURE GET_DEFAULTS(p_assignment_id      IN     NUMBER
                        ,p_date               IN OUT NOCOPY DATE
                        ,p_business_group_id     OUT NOCOPY NUMBER
                        ,p_currency              OUT NOCOPY VARCHAR2
                        ,p_format_string         OUT NOCOPY VARCHAR2
                        ,p_salary_basis_name     OUT NOCOPY VARCHAR2
                        ,p_pay_basis_name        OUT NOCOPY VARCHAR2
                        ,p_pay_basis             OUT NOCOPY VARCHAR2
                        ,p_pay_annualization_factor OUT NOCOPY NUMBER
                        ,p_grade                 OUT NOCOPY VARCHAR2
                        ,p_grade_annualization_factor OUT NOCOPY NUMBER
                        ,p_minimum_salary        OUT NOCOPY NUMBER
                        ,p_maximum_salary        OUT NOCOPY NUMBER
                        ,p_midpoint_salary       OUT NOCOPY NUMBER
                        ,p_prev_salary           OUT NOCOPY NUMBER
                        ,p_last_change_date      OUT NOCOPY DATE
                        ,p_element_entry_id      OUT NOCOPY NUMBER
                        ,p_basis_changed         OUT NOCOPY BOOLEAN
                        ,p_uom                   OUT NOCOPY VARCHAR2
                        ,p_grade_uom             OUT NOCOPY VARCHAR2);

  PROCEDURE GET_BASIS_DETAILS(p_effective_date             DATE
                             ,p_assignment_id              NUMBER
                             ,p_currency                   OUT NOCOPY VARCHAR2
                             ,p_salary_basis_name          OUT NOCOPY VARCHAR2
                             ,p_pay_basis_name             OUT NOCOPY VARCHAR2
                             ,p_pay_basis                  OUT NOCOPY VARCHAR2
                             ,p_pay_annualization_factor   OUT NOCOPY NUMBER
                             ,p_grade_basis                OUT NOCOPY VARCHAR2
                             ,p_grade_annualization_factor OUT NOCOPY NUMBER
                             ,p_element_type_id            OUT NOCOPY NUMBER
                             ,p_uom                        OUT NOCOPY VARCHAR2);

  PROCEDURE GET_PREV_SALARY(p_date           IN OUT NOCOPY    DATE
                           ,p_assignment_id  IN     NUMBER
                           ,p_prev_salary       OUT NOCOPY NUMBER
                           ,p_last_change_date  OUT NOCOPY DATE
                           ,p_basis_changed     OUT NOCOPY BOOLEAN);

  PROCEDURE GET_PAYROLL(p_assignment_id         NUMBER
                       ,p_date                  DATE
                       ,p_payroll           OUT NOCOPY VARCHAR2
                       ,p_payrolls_per_year OUT NOCOPY NUMBER);

  procedure get_hours(p_assignment_id      NUMBER
                     ,p_date               DATE
                     ,p_hours_per_year OUT NOCOPY NUMBER);
  procedure get_asg_hours(p_assignment_id      NUMBER
                     ,p_date               DATE
                     ,p_hours_per_year OUT NOCOPY NUMBER);
  procedure get_norm_hours(p_assignment_id      NUMBER
                     ,p_date               DATE
                     ,p_hours_per_year OUT NOCOPY NUMBER);

END per_pay_proposals_populate;

 

/
