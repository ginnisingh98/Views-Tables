--------------------------------------------------------
--  DDL for Package Body HR_API_MODULE_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_API_MODULE_INTERNAL" as
/* $Header: peamdbsi.pkb 115.0 99/07/17 18:29:25 porting ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_api_module_internal.';
--
-- ------------------------------------------------------------------------
-- |--------------------------< create_api_module >----------------------------|
-- ------------------------------------------------------------------------
--
procedure create_api_module
  (p_validate                      in      boolean  default false,
   p_effective_date                in      date,
   p_api_module_type               IN      varchar2,
   p_module_name                   IN      varchar2,
   p_data_within_business_group    IN      varchar2   default 'Y',
   p_legislation_code              IN      varchar2   default null,
   p_module_package                IN      varchar2   default null,
   p_api_module_id                 OUT     number)  is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  --
  -- Out variables
  --
  l_api_module_id              hr_api_modules.api_module_id%TYPE;
  --
  l_proc                       varchar2(72) := g_package||'create_module';
  --
  -- Declare a cursor that will check whether the passed
  -- in module type and module name form a unique combination
  --
  cursor csr_valid_combo is
  select api_module_id from hr_api_modules ham
  where ham.module_name = p_module_name
  and   ham.api_module_type = p_api_module_type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Set l_effective_date equal to truncated version of p_effective_date for
  -- API work. Stops dates being passed to row handlers with time portion.
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint create_api_module;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process Logic
  --
  --------------------------------------------------------
  -- Check for unique Module name and module type combo --
  --------------------------------------------------------
     open csr_valid_combo;
     fetch csr_valid_combo into l_api_module_id;

     -- If the module does not exist then create it.
     -- Do not error if the module does exist, simply return.
     --
     if csr_valid_combo%notfound then
        --
        -- Insert the module.
        --
           hr_amd_ins.ins
           (
            p_api_module_id                => l_api_module_id,
            p_effective_date               => l_effective_date,
            p_api_module_type              => p_api_module_type,
            p_module_name                  => p_module_name,
            p_data_within_business_group   => p_data_within_business_group,
            p_legislation_code             => p_legislation_code,
            p_module_package               => p_module_package
           );
     end if;
     close csr_valid_combo;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_api_module_id := l_api_module_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_api_module_id  := null;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_api_module;
    --
end create_api_module;
--
-- ------------------------------------------------------------------------
-- |--------------------------< delete_api_module >----------------------------|
-- ------------------------------------------------------------------------
--
procedure delete_api_module
  (p_validate                      in      boolean  default false,
   p_api_module_id                 in     number)  is
  --
  l_proc                       varchar2(72) := g_package||'delete_api_module';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint delete_api_module;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process Logic
  --
    hr_amd_del.del
      (p_api_module_id                => p_api_module_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_api_module;
end delete_api_module;
--
--
-- ------------------------------------------------------------------------
-- |--------------------------< update_api_module >----------------------------|
-- ------------------------------------------------------------------------
--
procedure update_api_module
  (p_validate                      in      boolean  default false,
   p_api_module_id                 in      number,
   p_module_name                   IN      varchar2 default hr_api.g_varchar2,
   p_module_package                IN      varchar2 default hr_api.g_varchar2,
   p_data_within_business_group    IN      varchar2 default hr_api.g_varchar2,
   p_effective_date                IN      date
  )  is
  --
  l_proc                       varchar2(72) := g_package||'update_api_module';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint update_api_module;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process Logic
  --
    hr_amd_upd.upd
      (p_api_module_id                => p_api_module_id,
       p_module_name                  => p_module_name,
       p_module_package               => p_module_package,
       p_data_within_business_group   => p_data_within_business_group,
       p_effective_date               => p_effective_date
       );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_api_module;
end update_api_module;
--
end hr_api_module_internal;

/
