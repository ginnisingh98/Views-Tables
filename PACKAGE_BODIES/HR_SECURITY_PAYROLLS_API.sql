--------------------------------------------------------
--  DDL for Package Body HR_SECURITY_PAYROLLS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SECURITY_PAYROLLS_API" as
/* $Header: hrsprapi.pkb 120.0 2005/11/18 02:19:08 pchowdav noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_security_payrolls_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pay_security_payroll >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_pay_security_payroll
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_security_profile_id           in     number
  ,p_payroll_id                    in     number
  ,p_object_version_number         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc               varchar2(72) :=
  g_package||'create_pay_security_payroll';
  l_effective_date          date;
  --
  -- Declare out parameters
  --
  l_object_version_number   number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_pay_security_payroll;

  l_object_version_number    := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date         := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_security_payrolls_bk1.create_pay_security_payroll_b
      (p_effective_date                 => l_effective_date
      ,p_security_profile_id            => p_security_profile_id
      ,p_payroll_id                     => p_payroll_id
      );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PAY_SECURITY_PAYROLL'
        ,p_hook_type   => 'BP'
        );
  end;

   --hr_utility.set_location('Entering:'|| l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
   pay_spr_ins.ins
     (p_effective_date                 => l_effective_date
      ,p_security_profile_id            => p_security_profile_id
      ,p_payroll_id                     => p_payroll_id
      ,p_object_version_number          => l_object_version_number
       );
  --
  -- Asign out parameters
  --
  p_object_version_number     := l_object_version_number;

  hr_utility.set_location('Entering:'|| l_proc,40);

  --
  -- Call After Process User Hook
  --
  begin
      hr_security_payrolls_bk1.create_pay_security_payroll_a
      (p_effective_date                 => l_effective_date
      ,p_security_profile_id            => p_security_profile_id
      ,p_payroll_id                     => p_payroll_id
      ,p_object_version_number          => l_object_version_number
      );



  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PAY_SECURITY_PAYROLL'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
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
    rollback to create_pay_security_payroll;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_pay_security_payroll;
    p_object_version_number := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_pay_security_payroll;
--
-- --------------------------------------------------------------------------
-- |-----------------------< delete_pay_security_payroll >-----------------|
-- --------------------------------------------------------------------------
--
procedure delete_pay_security_payroll
  (p_validate                      in     boolean  default false
  ,p_security_profile_id           in     number
  ,p_payroll_id                    in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc               varchar2(72) :=
  g_package||'create_pay_security_payroll';
  --l_effective_date          date;
  --
  -- Declare out parameters
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
 savepoint delete_pay_security_payroll;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --l_effective_date         := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_security_payrolls_bk2.delete_pay_security_payroll_b
      (p_security_profile_id            => p_security_profile_id
      ,p_payroll_id                     => p_payroll_id
       );
 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PAY_SECURITY_PAYROLL'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location('Entering:'|| l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
   pay_spr_del.del
     (p_security_profile_id            => p_security_profile_id
     ,p_payroll_id                     => p_payroll_id
     ,p_object_version_number          => p_object_version_number
       );

  hr_utility.set_location('Entering:'|| l_proc,40);

  --
  -- Call After Process User Hook
  --
  begin
      hr_security_payrolls_bk2.delete_pay_security_payroll_a
      (p_security_profile_id            => p_security_profile_id
      ,p_payroll_id                     => p_payroll_id
      ,p_object_version_number          => p_object_version_number
      );


exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PAY_SECURITY_PAYROLL'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
 if p_validate then
    raise hr_api.validate_enabled;
  end if;
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
    rollback to delete_pay_security_payroll;
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
    rollback to delete_pay_security_payroll;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_pay_security_payroll;
--
--
end hr_security_payrolls_api;

/
