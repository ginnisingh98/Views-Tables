--------------------------------------------------------
--  DDL for Package Body PAY_AU_MODULE_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_MODULE_TYPES_API" as
/* $Header: pyamtapi.pkb 120.0 2005/05/29 02:56 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33);
--
-- ------------------------------------------------------------------------
-- |--------------------------< create_au_module_type >-------------------|
-- ------------------------------------------------------------------------
--
procedure create_au_module_type
  (p_validate                      in      boolean  default false,
   p_name                          in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_description                   IN      varchar2,
   p_module_type_id                out nocopy number,
   p_object_version_number         out nocopy number)  is
  --
  -- Declare cursors and local variables
  --
  --
  -- Out variables
  --
  l_module_type_id             pay_au_module_types.module_type_id%TYPE;
  l_object_version_number      pay_au_module_types.object_version_number%TYPE;
  --
  l_proc                       varchar2(72);
  --
  -- Declare a cursor that will check whether the passed
  -- in name for a unique name
  --
  cursor csr_valid_name is
  select module_type_id from pay_au_module_types pamt
  where  pamt.name  = p_name;
  --
  --
begin
  l_proc := g_package||'create_au_module_type';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint create_au_module_type;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- Process Logic
  --
  --------------------------------------------------------
  -- Check for unique short name,business_group_id and
  -- legislation_code combo --
  --------------------------------------------------------
     open csr_valid_name;
     fetch csr_valid_name into l_module_type_id;

     -- If the process does not exist then create it.
     -- Do not error if the process does exist, simply return.
     --
     if csr_valid_name%notfound then
        --
        -- Insert the module type.
        --
           pay_amt_ins.ins
           (
            p_module_type_id               => l_module_type_id,
            p_name                         => p_name,
            p_enabled_flag                 => p_enabled_flag,
            p_description                  => p_description,
            p_object_version_number        => l_object_version_number
           );
     end if;
     close csr_valid_name;
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
  p_module_type_id := l_module_type_id;
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
    p_module_type_id  := null;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_au_module_type;
    --
end create_au_module_type;
--
-- ------------------------------------------------------------------------
-- |--------------------------< delete_au_module_type >-------------------|
-- ------------------------------------------------------------------------
--
procedure delete_au_module_type
  (p_validate                      in      boolean  default false,
   p_module_type_id                in      number,
   p_object_version_number         in      number)  is
  --
  l_proc                       varchar2(72);
  --
begin
  l_proc := g_package||'delete_au_module_type';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint delete_au_module_type;
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
    pay_amt_del.del
      (p_module_type_id            => p_module_type_id,
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
    ROLLBACK TO delete_au_module_type;
end delete_au_module_type;
--
--
-- ------------------------------------------------------------------------
-- |--------------------------< update_au_module_type >--------------------|
-- ------------------------------------------------------------------------
--
procedure update_au_module_type
  (p_validate                      in      boolean  default false,
   p_module_type_id                in      number,
   p_name                          in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_description                   in      varchar2,
   p_object_version_number         in out  nocopy   number
  )  is
  --
  l_proc                       varchar2(72);
  --
begin
  l_proc := g_package||'update_au_module_type';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint update_au_module_type;
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
    pay_amt_upd.upd
      (p_module_type_id               => p_module_type_id,
       p_object_version_number        => p_object_version_number,
       p_name                         => p_name,
       p_enabled_flag                 => p_enabled_flag,
       p_description                  => p_description
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
    ROLLBACK TO update_au_module_type;
end update_au_module_type;
--
--
begin
  g_package := '  pay_au_module_types_api.';
end pay_au_module_types_api;

/