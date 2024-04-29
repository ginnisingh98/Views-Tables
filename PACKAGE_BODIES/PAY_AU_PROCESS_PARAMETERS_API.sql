--------------------------------------------------------
--  DDL for Package Body PAY_AU_PROCESS_PARAMETERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_PROCESS_PARAMETERS_API" as
/* $Header: pyappapi.pkb 120.0 2005/05/29 02:57 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33);
--
-- ------------------------------------------------------------------------
-- |--------------------------< create_au_process_parameter >-------------|
-- ------------------------------------------------------------------------
--
procedure create_au_process_parameter
  (p_validate                      in      boolean  default false,
   p_process_id                    in      number,
   p_internal_name                 in      varchar2,
   p_data_type                     in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_process_parameter_id          out nocopy number,
   p_object_version_number         out nocopy number)  is
  --
  -- Declare cursors and local variables
  --
  --
  -- Out variables
  --
  l_process_parameter_id       pay_au_process_parameters.process_parameter_id%TYPE;
  l_object_version_number      pay_au_process_parameters.object_version_number%TYPE;
  --
  l_proc                       varchar2(72);
  l_dummy_number               number(1);
  --
  -- Declare a cursor that will check whether the passed
  -- in process_id and internal_name for a unique combination
  --
  cursor csr_valid_combo is
  select process_parameter_id
  from   pay_au_process_parameters papp
  where  papp.process_id  = p_process_id
  and    papp.internal_name = p_internal_name;
  --
begin
  l_proc := g_package||'create_au_process_parameter';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint create_au_process_parameter;
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
     fetch csr_valid_combo into l_process_parameter_id;

     -- If the process parameter does not exist then create it.
     -- Do not error if the process does exist, simply return.
     --
     if csr_valid_combo%notfound then
        --
        -- Insert the process parameter.
        --
           pay_app_ins.ins
           (
            p_process_id                   => p_process_id,
            p_internal_name                => p_internal_name,
            p_data_type                    => p_data_type,
            p_enabled_flag                 => p_enabled_flag,
            p_process_parameter_id         => l_process_parameter_id,
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
  p_process_parameter_id  := l_process_parameter_id;
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
    p_process_parameter_id  := null;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_au_process_parameter;
    --
end create_au_process_parameter;
--
-- ------------------------------------------------------------------------
-- |--------------------------< delete_au_process_parameter >-------------|
-- ------------------------------------------------------------------------
--
procedure delete_au_process_parameter
  (p_validate                      in      boolean  default false,
   p_process_parameter_id          in      number,
   p_object_version_number         in      number)  is
  --
  l_proc                       varchar2(72);
  --
begin
  l_proc  := g_package||'delete_au_process_parameter';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint delete_au_process_parameter;
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
    pay_app_del.del
      (p_process_parameter_id      => p_process_parameter_id,
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
    ROLLBACK TO delete_au_process_parameter;
end delete_au_process_parameter;
--
--
-- ------------------------------------------------------------------------
-- |--------------------------< update_au_process_parameter >-------------|
-- ------------------------------------------------------------------------
--
procedure update_au_process_parameter
  (p_validate                      in      boolean  default false,
   p_process_parameter_id          in      number,
   p_process_id                    in      number,
   p_internal_name                 in      varchar2,
   p_data_type                     in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_object_version_number         in out  nocopy   number
  )  is
  --
  l_proc                       varchar2(72);
  --
begin
  l_proc  := g_package||'update_au_process_parameter';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint update_au_process_parameter;
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
    pay_app_upd.upd
      (p_process_parameter_id         => p_process_parameter_id,
       p_object_version_number        => p_object_version_number,
       p_process_id                   => p_process_id,
       p_internal_name                => p_internal_name,
       p_data_type                    => p_data_type,
       p_enabled_flag                 => p_enabled_flag
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
    ROLLBACK TO update_au_process_parameter;
end update_au_process_parameter;
--
begin
  g_package  := '  pay_au_process_parameters_api.';
end pay_au_process_parameters_api;

/
