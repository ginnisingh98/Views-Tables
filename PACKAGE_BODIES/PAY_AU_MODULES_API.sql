--------------------------------------------------------
--  DDL for Package Body PAY_AU_MODULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_MODULES_API" as
/* $Header: pyamoapi.pkb 120.0 2005/05/29 02:54 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33);
--
-- ------------------------------------------------------------------------
-- |--------------------------< create_au_module >------------------------|
-- ------------------------------------------------------------------------
--
procedure create_au_module
  (p_validate                      in      boolean  default false,
   p_name                          in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_module_type_id                in      number,
   p_business_group_id             in      number,
   p_legislation_code              in      varchar2,
   p_description                   in      varchar2,
   p_package_name                  in      varchar2,
   p_procedure_function_name       in      varchar2,
   p_formula_name                  in      varchar2,
   p_module_id                     out nocopy number,
   p_object_version_number         out nocopy number)  is
  --
  -- Declare cursors and local variables
  --
  --
  -- Out variables
  --
  l_module_id                  pay_au_modules.module_id%TYPE;
  l_object_version_number      pay_au_modules.object_version_number%TYPE;
  --
  l_proc                       varchar2(72);
  l_dummy_number               number(1);
  --
  -- Declare a cursor that will check whether the passed
  -- in process_id and internal_name for a unique combination
  --
  cursor csr_valid_combo is
  select module_id
  from   pay_au_modules pam
  where  pam.name  = p_name
  and    (pam.business_group_id is null
         or pam.business_group_id = p_business_group_id)
  and    pam.legislation_code = p_legislation_code;
  --
begin
  l_proc := g_package||'create_au_module';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint create_au_module;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
  -- Process Logic
  --
  --------------------------------------------------------
  -- Check for unique short name,business_group_id and
  -- legislation_code combo --
  --------------------------------------------------------
     open csr_valid_combo;
     fetch csr_valid_combo into l_module_id;

     -- If the process parameter does not exist then create it.
     -- Do not error if the process does exist, simply return.
     --
     if csr_valid_combo%notfound then
        --
        -- Insert the process parameter.
        --
           pay_amo_ins.ins
           (
            p_name                         => p_name,
            p_enabled_flag                 => p_enabled_flag,
            p_module_type_id               => p_module_type_id,
            p_business_group_id            => p_business_group_id,
            p_legislation_code             => p_legislation_code,
            p_description                  => p_description,
            p_package_name                 => p_package_name,
            p_procedure_function_name      => p_procedure_function_name,
            p_formula_name                 => p_formula_name,
            p_module_id                    => l_module_id,
            p_object_version_number        => l_object_version_number
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
  p_module_id  := l_module_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_module_id  := null;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_au_module;
    --
end create_au_module;
--
-- ------------------------------------------------------------------------
-- |--------------------------< delete_au_module >------------------------|
-- ------------------------------------------------------------------------
--
procedure delete_au_module
  (p_validate                      in      boolean  default false,
   p_module_id                     in      number,
   p_object_version_number         in      number)  is
  --
  l_proc                       varchar2(72);
  --
begin
  l_proc := g_package||'delete_au_module';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint delete_au_module;
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
    pay_amo_del.del
      (p_module_id                 => p_module_id,
       p_object_version_number     => p_object_version_number);
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
    ROLLBACK TO delete_au_module;
end delete_au_module;
--
--
-- ------------------------------------------------------------------------
-- |--------------------------< update_au_module >------------------------|
-- ------------------------------------------------------------------------
--
procedure update_au_module
  (p_validate                      in      boolean  default false,
   p_module_id                     in      number,
   p_name                          in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_module_type_id                in      number,
   p_business_group_id             in      number,
   p_legislation_code              in      varchar2,
   p_description                   in      varchar2,
   p_package_name                  in      varchar2,
   p_procedure_function_name       in      varchar2,
   p_formula_name                  in      varchar2,
   p_object_version_number         in out  nocopy   number
  )  is
  --
  l_proc                       varchar2(72);
  --
begin
  l_proc := g_package||'update_au_module';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint update_au_module;
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
    pay_amo_upd.upd
      (p_module_id                    => p_module_id,
       p_object_version_number        => p_object_version_number,
       p_name                         => p_name,
       p_enabled_flag                 => p_enabled_flag,
       p_module_type_id               => p_module_type_id,
       p_business_group_id            => p_business_group_id,
       p_legislation_code             => p_legislation_code,
       p_description                  => p_description,
       p_package_name                 => p_package_name,
       p_procedure_function_name      => p_procedure_function_name,
       p_formula_name                 => p_formula_name
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
    ROLLBACK TO update_au_module;
end update_au_module;
--
--
begin
  g_package   := '  pay_au_modules_api.';
end pay_au_modules_api;

/
