--------------------------------------------------------
--  DDL for Package Body HR_CANCEL_PLACEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CANCEL_PLACEMENT_API" AS
/* $Header: pecplapi.pkb 115.7 2002/12/10 15:36:42 pkakar noship $ */
--
-- Package Variables
--
g_package  VARCHAR2(33) := 'hr_cancel_placement_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< cancel_placement >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE cancel_placement
  (p_validate            IN     BOOLEAN  DEFAULT FALSE
  ,p_person_id           IN     NUMBER
  ,p_effective_date      IN     DATE
  ,p_supervisor_warning     OUT NOCOPY BOOLEAN
  ,p_recruiter_warning      OUT NOCOPY BOOLEAN
  ,p_event_warning          OUT NOCOPY BOOLEAN
  ,p_interview_warning      OUT NOCOPY BOOLEAN
  ,p_review_warning         OUT NOCOPY BOOLEAN
  ,p_vacancy_warning        OUT NOCOPY BOOLEAN
  ,p_requisition_warning    OUT NOCOPY BOOLEAN
  ,p_budget_warning         OUT NOCOPY BOOLEAN
  ,p_payment_warning        OUT NOCOPY BOOLEAN) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) := g_package||'cancel_placement';
  l_system_person_type  per_person_types.system_person_type%TYPE;
  l_business_group_id   per_periods_of_placement.business_group_id%TYPE;
  l_date_start          DATE;
  l_effective_date      DATE;
  --
  CURSOR csr_date_start IS
    SELECT date_start,
           business_group_id
    FROM   per_periods_of_placement pp
    WHERE  pp.person_id = p_person_id
    AND    l_effective_date BETWEEN pp.date_start
                                AND NVL(pp.actual_termination_date,hr_general.end_of_time);
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT cancel_placement;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Retrieve date_start from the period of placement record.
  --
  OPEN  csr_date_start;
  FETCH csr_date_start INTO l_date_start, l_business_group_id;
  --
  IF csr_date_start%NOTFOUND THEN
    --
    CLOSE csr_date_start;
    --
    hr_utility.set_message(801,'HR_289751_CWK_POP_ERROR');
    hr_utility.raise_error;
    --
  END IF;
  --
  CLOSE csr_date_start;
  --
  -- Call Before Process User Hook
  --
  BEGIN
    --
    per_cancel_placement_bk1.cancel_placement_b
      (p_business_group_id => l_business_group_id
      ,p_person_id         => p_person_id
      ,p_effective_date    => l_effective_date);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'cancel_placement'
        ,p_hook_type   => 'BP');
      --
  END;
  --
  hr_utility.set_location(l_proc, 20);
  --
  per_cancel_hire_or_apl_pkg.lock_cwk_rows
    (p_person_id         => p_person_id
    ,p_effective_date    => l_effective_date
    ,p_business_group_id => l_business_group_id);
  --
  hr_utility.set_location(l_proc, 25);
  --
  -- Validation checks to ensure that the canelling of
  -- the placement is a valid operation for the worker.
  --
  per_cancel_hire_or_apl_pkg.pre_cancel_placement_checks
    (p_person_id           => p_person_id
    ,p_business_group_id   => l_business_group_id
    ,p_effective_date      => l_effective_date
    ,p_date_start          => l_date_start
    ,p_supervisor_warning  => p_supervisor_warning
    ,p_recruiter_warning   => p_recruiter_warning
    ,p_event_warning       => p_event_warning
    ,p_interview_warning   => p_interview_warning
    ,p_review_warning      => p_review_warning
    ,p_vacancy_warning     => p_vacancy_warning
    ,p_requisition_warning => p_requisition_warning
    ,p_budget_warning      => p_budget_warning
    ,p_payment_warning     => p_payment_warning );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  per_cancel_hire_or_apl_pkg.do_cancel_placement
    (p_person_id            => p_person_id
    ,p_business_group_id    => l_business_group_id
    ,p_effective_date       => l_effective_date
    ,p_date_start           => l_date_start);
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Call After Process User Hook
  --
  BEGIN
    --
    per_cancel_placement_bk1.cancel_placement_a
      (p_business_group_id   => l_business_group_id
      ,p_person_id           => p_person_id
      ,p_effective_date      => l_effective_date
      ,p_supervisor_warning  => p_supervisor_warning
      ,p_recruiter_warning   => p_recruiter_warning
      ,p_event_warning       => p_event_warning
      ,p_interview_warning   => p_interview_warning
      ,p_review_warning      => p_review_warning
      ,p_vacancy_warning     => p_vacancy_warning
      ,p_requisition_warning => p_requisition_warning
      ,p_budget_warning      => p_budget_warning
      ,p_payment_warning     => p_payment_warning);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'cancel_placement'
        ,p_hook_type   => 'AP');
      --
  END;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 997);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO cancel_placement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO cancel_placement;
    --
    -- set out parameters
    --
   p_supervisor_warning := false;
   p_recruiter_warning  := false;
   p_event_warning      := false;
   p_interview_warning  := false;
   p_review_warning     := false;
   p_vacancy_warning    := false;
   p_requisition_warning := false;
   p_budget_warning      := false;
   p_payment_warning      := false;
   hr_utility.set_location(' Leaving:'||l_proc, 999);
    RAISE;
    --
END cancel_placement;
--
END hr_cancel_placement_api;

/
