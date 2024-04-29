--------------------------------------------------------
--  DDL for Package Body PQH_FR_VALIDATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_VALIDATIONS_API" as
/* $Header: pqvldapi.pkb 115.3 2002/12/05 00:30:53 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_FR_VALIDATIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_Validation >------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_Validation
  (p_effective_date               in     date
  ,p_pension_fund_type_code         in     varchar2
  ,p_pension_fund_id                in     number
  ,p_business_group_id              in     number
  ,p_person_id                      in     number
  ,p_previously_validated_flag      in     varchar2
  ,p_request_date                   in     date
  ,p_completion_date                in     date
  ,p_previous_employer_id           in     number
  ,p_status                         in     varchar2
  ,p_employer_amount                in     number
  ,p_employer_currency_code         in     varchar2
  ,p_employee_amount                in     number
  ,p_employee_currency_code         in     varchar2
  ,p_deduction_per_period           in     number
  ,p_deduction_currency_code        in     varchar2
  ,p_percent_of_salary              in     number
  ,p_validation_id                     out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)       := g_package||'Insert_Validation';
  l_object_Version_Number    PQH_FR_VALIDATIONS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date           Date;
  l_validation_id 		PQH_FR_VALIDATIONS.VALIDATION_ID%TYPE;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_Validation;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
   PQH_FR_VALIDATIONS_BK1.Insert_Validation_b
   (p_effective_date               => l_effective_date
  ,p_pension_fund_type_code        => p_pension_fund_type_code
  ,p_pension_fund_id               => p_pension_fund_id
  ,p_business_group_id             => p_business_group_id
  ,p_person_id                     => p_person_id
  ,p_previously_validated_flag     => p_previously_validated_flag
  ,p_request_date                  => p_request_date
  ,p_completion_date               => p_completion_date
  ,p_previous_employer_id          => p_previous_employer_id
  ,p_status                        => p_status
  ,p_employer_amount               => p_employer_amount
  ,p_employer_currency_code        => p_employer_currency_code
  ,p_employee_amount               => p_employee_amount
  ,p_employee_currency_code        => p_employee_currency_code
  ,p_deduction_per_period          => p_deduction_per_period
  ,p_deduction_currency_code       => p_deduction_currency_code
  ,p_percent_of_salary             => p_percent_of_salary
   );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_VALIDATIONS_API.Insert_Validation'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_vld_ins.ins
     (
    p_effective_date               => l_effective_date
  ,p_pension_fund_type_code        => p_pension_fund_type_code
  ,p_pension_fund_id               => p_pension_fund_id
  ,p_business_group_id             => p_business_group_id
  ,p_person_id                     => p_person_id
  ,p_previously_validated_flag     => p_previously_validated_flag
  ,p_request_date                  => p_request_date
  ,p_completion_date               => p_completion_date
  ,p_previous_employer_id          => p_previous_employer_id
  ,p_status                        => p_status
  ,p_employer_amount               => p_employer_amount
  ,p_employer_currency_code        => p_employer_currency_code
  ,p_employee_amount               => p_employee_amount
  ,p_employee_currency_code        => p_employee_currency_code
  ,p_deduction_per_period          => p_deduction_per_period
  ,p_deduction_currency_code       => p_deduction_currency_code
  ,p_percent_of_salary             => p_percent_of_salary
  ,p_validation_id		   => l_validation_id
  ,p_object_version_number         => l_object_version_number
     );

  --
  -- Call After Process User Hook
  --
  begin
     PQH_FR_VALIDATIONS_BK1.Insert_Validation_a
     (
     p_effective_date              => l_effective_date
  ,p_pension_fund_type_code        => p_pension_fund_type_code
  ,p_pension_fund_id               => p_pension_fund_id
  ,p_business_group_id             => p_business_group_id
  ,p_person_id                     => p_person_id
  ,p_previously_validated_flag     => p_previously_validated_flag
  ,p_request_date                  => p_request_date
  ,p_completion_date               => p_completion_date
  ,p_previous_employer_id          => p_previous_employer_id
  ,p_status                        => p_status
  ,p_employer_amount               => p_employer_amount
  ,p_employer_currency_code        => p_employer_currency_code
  ,p_employee_amount               => p_employee_amount
  ,p_employee_currency_code        => p_employee_currency_code
  ,p_deduction_per_period          => p_deduction_per_period
  ,p_deduction_currency_code       => p_deduction_currency_code
  ,p_percent_of_salary             => p_percent_of_salary
     );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_VALIDATIONS_API.Insert_Validation'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
-- Removed p_validate from the generated code to facilitate
-- writing wrappers to selfservice easily.
--
--  if p_validate then
--    raise hr_api.validate_enabled;
--  end if;
  --
  -- Set all output arguments
  --
     p_validation_id := l_validation_id;
     p_object_version_number := l_object_version_number;


  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_Validation;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
  p_validation_id := null;
  p_object_version_number := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_Validation;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_Validation;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Validation >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_Validation
  (
  p_effective_date               in     date
  ,p_validation_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_pension_fund_type_code       in     varchar2
  ,p_pension_fund_id              in     number
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_previously_validated_flag    in     varchar2
  ,p_request_date                 in     date
  ,p_completion_date              in     date
  ,p_previous_employer_id         in     number
  ,p_status                       in     varchar2
  ,p_employer_amount              in     number
  ,p_employer_currency_code       in     varchar2
  ,p_employee_amount              in     number
  ,p_employee_currency_code       in     varchar2
  ,p_deduction_per_period         in     number
  ,p_deduction_currency_code      in     varchar2
  ,p_percent_of_salary            in     number
  ) Is

  l_proc  varchar2(72)    := g_package||'Update_Validation';
  l_object_Version_Number PQH_FR_VALIDATIONS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date        Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_Validation;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin

   PQH_FR_VALIDATIONS_BK2.Update_Validation_b
  (
  p_effective_date               => l_effective_date
  ,p_validation_id               => p_validation_id
  ,p_object_version_number       => l_object_version_number
  ,p_pension_fund_type_code      => p_pension_fund_type_code
  ,p_pension_fund_id             => p_pension_fund_id
  ,p_business_group_id           => p_business_group_id
  ,p_person_id                   => p_person_id
  ,p_previously_validated_flag   => p_previously_validated_flag
  ,p_request_date                => p_request_date
  ,p_completion_date             => p_completion_date
  ,p_previous_employer_id        => p_previous_employer_id
  ,p_status                      => p_status
  ,p_employer_amount             => p_employer_amount
  ,p_employer_currency_code      => p_employer_currency_code
  ,p_employee_amount             => p_employee_amount
  ,p_employee_currency_code      => p_employee_currency_code
  ,p_deduction_per_period        => p_deduction_per_period
  ,p_deduction_currency_code     => p_deduction_currency_code
  ,p_percent_of_salary           => p_percent_of_salary
  );

 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Validation'
        ,p_hook_type   => 'BP'
        );
  end;

  pqh_vld_upd.upd
  (
  p_effective_date               => l_effective_date
  ,p_validation_id               => p_validation_id
  ,p_object_version_number       => l_object_version_number
  ,p_pension_fund_type_code      => p_pension_fund_type_code
  ,p_pension_fund_id             => p_pension_fund_id
  ,p_business_group_id           => p_business_group_id
  ,p_person_id                   => p_person_id
  ,p_previously_validated_flag   => p_previously_validated_flag
  ,p_request_date                => p_request_date
  ,p_completion_date             => p_completion_date
  ,p_previous_employer_id        => p_previous_employer_id
  ,p_status                      => p_status
  ,p_employer_amount             => p_employer_amount
  ,p_employer_currency_code      => p_employer_currency_code
  ,p_employee_amount             => p_employee_amount
  ,p_employee_currency_code      => p_employee_currency_code
  ,p_deduction_per_period        => p_deduction_per_period
  ,p_deduction_currency_code     => p_deduction_currency_code
  ,p_percent_of_salary           => p_percent_of_salary
  );

--
--
  -- Call After Process User Hook
  --
  begin

   PQH_FR_VALIDATIONS_BK2.Update_Validation_a
  (
  p_effective_date               => l_effective_date
  ,p_validation_id               => p_validation_id
  ,p_object_version_number       => l_object_version_number
  ,p_pension_fund_type_code      => p_pension_fund_type_code
  ,p_pension_fund_id             => p_pension_fund_id
  ,p_business_group_id           => p_business_group_id
  ,p_person_id                   => p_person_id
  ,p_previously_validated_flag   => p_previously_validated_flag
  ,p_request_date                => p_request_date
  ,p_completion_date             => p_completion_date
  ,p_previous_employer_id        => p_previous_employer_id
  ,p_status                      => p_status
  ,p_employer_amount             => p_employer_amount
  ,p_employer_currency_code      => p_employer_currency_code
  ,p_employee_amount             => p_employee_amount
  ,p_employee_currency_code      => p_employee_currency_code
  ,p_deduction_per_period        => p_deduction_per_period
  ,p_deduction_currency_code     => p_deduction_currency_code
  ,p_percent_of_salary           => p_percent_of_salary

  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Validation'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
--  if p_validate then
--    raise hr_api.validate_enabled;
--  end if;
  --
  -- Set all output arguments
  --

  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Update_Validation;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
  p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Update_Validation;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_Validation;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_Validation>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_Validation
  (
  p_validation_id                        in     number
  ,p_object_version_number                in     number
  ) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_Validation';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_Validation;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_FR_VALIDATIONS_BK3.Delete_Validation_b
  (
  p_validation_id            => p_validation_id
  ,p_object_version_number   => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Validation'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_vld_del.del
    (
  p_validation_id            => p_validation_id
  ,p_object_version_number   => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin

   PQH_FR_VALIDATIONS_BK3.Delete_Validation_a
  (
  p_validation_id            => p_validation_id
  ,p_object_version_number   => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Validation'
        ,p_hook_type   => 'AP');
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
--  if p_validate then
--    raise hr_api.validate_enabled;
--  end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_Validation;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_Validation;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_Validation;

end PQH_FR_VALIDATIONS_API;

/
