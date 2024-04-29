--------------------------------------------------------
--  DDL for Package Body HR_MX_EMPLOYEE_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MX_EMPLOYEE_APPLICANT_API" AS
/* $Header: pemxwrea.pkb 120.0 2005/05/31 11:33 appldev noship $ */
--
  g_package  varchar2(33);
  g_debug    boolean;
-- -----------------------------------------------------------------------------
-- |--------------------< mx_hire_to_employee_applicant >----------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE mx_hire_to_employee_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_hire_date                    IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_per_object_version_number    IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT NULL
  ,p_hire_all_accepted_asgs       IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE    DEFAULT NULL
  ,p_CURP_id                      IN     per_all_people_f.national_identifier%TYPE   DEFAULT hr_api.g_varchar2
  ,p_employee_number              IN OUT NOCOPY per_all_people_f.employee_number%TYPE
  ,p_per_effective_start_date        OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_per_effective_end_date          OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  ,p_oversubscribed_vacancy_id       OUT NOCOPY NUMBER
  )
is
    -- Declare cursors and local variables
    l_proc               VARCHAR2(72);
    l_business_group_id  per_all_people_f.business_group_id%TYPE;

    --
  BEGIN

    l_proc := g_package||'mx_hire_to_employee_applicant';

    if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
    end if;

    -----------------------------------------------------------------
    -- Check that the business group of the person is in 'MX'
    -- legislation.
    -----------------------------------------------------------------
    l_business_group_id := hr_mx_utility.get_bg_from_person(p_person_id);

   if g_debug then
    hr_utility.set_location(l_proc, 20);
   end if;

    hr_mx_utility.check_bus_grp(l_business_group_id, 'MX');

   if g_debug then
    hr_utility.set_location(l_proc, 30);
   end if;

    --
    -- Call the person business process
    --
    hr_employee_applicant_api.hire_to_employee_applicant
  (p_validate                     =>	p_validate
  ,p_hire_date                    =>	p_hire_date
  ,p_person_id                    =>	p_person_id
  ,p_per_object_version_number    =>	p_per_object_version_number
  ,p_person_type_id               =>	p_person_type_id
  ,p_hire_all_accepted_asgs       =>	p_hire_all_accepted_asgs
  ,p_assignment_id                =>	p_assignment_id
  ,p_national_identifier          =>	p_CURP_id
  ,p_employee_number              =>	p_employee_number
  ,p_per_effective_start_date     =>	p_per_effective_start_date
  ,p_per_effective_end_date       =>	p_per_effective_end_date
  ,p_assign_payroll_warning       =>	p_assign_payroll_warning
  ,p_oversubscribed_vacancy_id    =>	p_oversubscribed_vacancy_id );

  --
  if g_debug then
       hr_utility.set_location('Leaving: '||l_proc, 40);
  end if;
  --
  end mx_hire_to_employee_applicant;

begin
  g_package := 'hr_mx_employee_applicant_api.';
  g_debug   := hr_utility.debug_enabled;
end hr_mx_employee_applicant_api;

/
