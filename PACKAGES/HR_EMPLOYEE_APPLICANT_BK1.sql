--------------------------------------------------------
--  DDL for Package HR_EMPLOYEE_APPLICANT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EMPLOYEE_APPLICANT_BK1" 
/* $Header: peemaapi.pkh 120.2.12010000.5 2010/03/26 07:29:49 gpurohit ship $ */
AUTHID CURRENT_USER AS
--
-- +---------------------------------------------------------------------------+
-- |---------------------< hire_to_employee_applicant_b >----------------------|
-- +---------------------------------------------------------------------------+
--
PROCEDURE hire_to_employee_applicant_b
  (p_hire_date                    IN DATE
  ,p_person_id                    IN NUMBER
  ,p_business_group_id            IN NUMBER
  ,p_person_type_id               IN NUMBER
  ,p_hire_all_accepted_asgs       IN VARCHAR2
  ,p_assignment_id                IN NUMBER
  ,p_per_object_version_number    IN NUMBER
  ,p_national_identifier          IN VARCHAR2
  ,p_employee_number              IN VARCHAR2
  );
--
-- -----------------------------------------------------------------------------
-- |---------------------< hire_to_employee_applicant_a >----------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE hire_to_employee_applicant_a
  (p_hire_date                    IN DATE
  ,p_person_id                    IN NUMBER
  ,p_business_group_id            IN NUMBER
  ,p_person_type_id               IN NUMBER
  ,p_hire_all_accepted_asgs       IN VARCHAR2
  ,p_assignment_id                IN NUMBER
  ,p_per_object_version_number    IN NUMBER
  ,p_national_identifier          IN VARCHAR2
  ,p_employee_number              IN VARCHAR2
  ,p_per_effective_start_date     IN DATE
  ,p_per_effective_end_date       IN DATE
  ,p_assign_payroll_warning       IN BOOLEAN
  ,p_oversubscribed_vacancy_id    IN number
  );
--
END hr_employee_applicant_bk1;

/
