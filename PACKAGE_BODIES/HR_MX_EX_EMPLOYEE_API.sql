--------------------------------------------------------
--  DDL for Package Body HR_MX_EX_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MX_EX_EMPLOYEE_API" AS
/* $Header: pemxwrxe.pkb 120.0 2005/05/31 11:38 appldev noship $ */
--
  g_package  VARCHAR2(33);
  g_debug    BOOLEAN;
-- -----------------------------------------------------------------------------
-- |------------------------< mx_final_process_emp >--------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE mx_final_process_emp
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_period_of_service_id          IN     NUMBER
  ,p_ss_leaving_reason             IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_final_process_date            IN OUT NOCOPY DATE
  ,p_org_now_no_manager_warning       OUT NOCOPY BOOLEAN
  ,p_asg_future_changes_warning       OUT NOCOPY BOOLEAN
  ,p_entries_changed_warning          OUT NOCOPY VARCHAR2
  )
IS
    -- Declare cursors and local variables
    l_proc               VARCHAR2(72);
    l_business_group_id  per_periods_of_service.business_group_id%TYPE;

    CURSOR csr_get_bg IS
    SELECT business_group_id
      FROM per_periods_of_service
     WHERE period_of_service_id = p_period_of_service_id;
    --
  BEGIN

    l_proc  := g_package||'mx_final_process_emp';

  if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -----------------------------------------------------------------
  -- Fetch Business Group ID for the given Period of Service.
  -----------------------------------------------------------------
  OPEN csr_get_bg;
  FETCH csr_get_bg INTO l_business_group_id;

  IF csr_get_bg%NOTFOUND THEN

     if g_debug then
       hr_utility.set_location(l_proc, 20);
     end if;

     CLOSE csr_get_bg;
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  END IF;
  --
  CLOSE csr_get_bg;

  -----------------------------------------------------------------
  -- Check if the business group lies within 'MX' legislation
  -----------------------------------------------------------------
  hr_mx_utility.check_bus_grp(l_business_group_id, 'MX');

 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;

    --
  -----------------------------------------------------------------
   -- Validate the Leaving Reason entered, if any.
  -----------------------------------------------------------------
   per_mx_validations.check_SS_Leaving_Reason(p_ss_leaving_reason);

   if g_debug then
       hr_utility.set_location(l_proc, 40);
   end if;

  -----------------------------------------------------------------
   -- Load the Leaving Reason onto the Global Variable.
  -----------------------------------------------------------------
   hr_mx_assignment_api.g_leaving_reason := p_ss_leaving_reason;

    -----------------------------------------
    -- Call the person business process
    -----------------------------------------
    hr_ex_employee_api.final_process_emp
  (p_validate                      =>	p_validate
  ,p_period_of_service_id          =>	p_period_of_service_id
  ,p_object_version_number         =>	p_object_version_number
  ,p_final_process_date            =>	p_final_process_date
  ,p_org_now_no_manager_warning    =>	p_org_now_no_manager_warning
  ,p_asg_future_changes_warning    =>	p_asg_future_changes_warning
  ,p_entries_changed_warning       =>	p_entries_changed_warning );

  --
   if g_debug then
       hr_utility.set_location('Leaving: '||l_proc, 50);
   end if;
  --
  END mx_final_process_emp;

BEGIN

  g_package  :=  'hr_mx_ex_employee_api.';
  g_debug    :=  hr_utility.debug_enabled;

END hr_mx_ex_employee_api;

/
