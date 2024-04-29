--------------------------------------------------------
--  DDL for Package HR_EMPLOYEE_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EMPLOYEE_BK4" 
/* $Header: peempapi.pkh 120.2.12010000.4 2009/03/09 13:25:50 swamukhe ship $ */
AUTHID CURRENT_USER AS
--
-- -----------------------------------------------------------------------------
-- |----------------------------< hire_into_job_b >----------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE hire_into_job_b
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_business_group_id            IN     NUMBER
  ,p_object_version_number        IN     NUMBER
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_employee_number              IN     VARCHAR2
  ,p_person_type_id               IN     NUMBER
  ,p_national_identifier          IN     VARCHAR2
  ,p_per_information7             IN     VARCHAR2 --3414274
  );
--
-- -----------------------------------------------------------------------------
-- |----------------------------< hire_into_job_a >----------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE hire_into_job_a
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_business_group_id            IN     NUMBER
  ,p_object_version_number        IN     NUMBER
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_employee_number              IN     VARCHAR2
  ,p_person_type_id               IN     NUMBER
  ,p_national_identifier          IN     VARCHAR2
  ,p_per_information7             IN     VARCHAR2 --3414274
  ,p_assignment_id                IN     NUMBER   --Bug#3919096
  ,p_effective_start_date         IN     DATE
  ,p_effective_end_date           IN     DATE
  ,p_assign_payroll_warning       IN     BOOLEAN
  ,p_orig_hire_warning            IN     BOOLEAN
  );
--
END hr_employee_bk4;

/
