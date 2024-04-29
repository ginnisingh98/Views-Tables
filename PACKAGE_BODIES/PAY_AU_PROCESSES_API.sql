--------------------------------------------------------
--  DDL for Package Body PAY_AU_PROCESSES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_PROCESSES_API" as
/* $Header: pyaprapi.pkb 120.0 2005/05/29 02:58 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33);
--
-- ------------------------------------------------------------------------
-- |--------------------------< create_au_process >------------------------|
-- ------------------------------------------------------------------------
--
procedure create_au_process
  (p_validate                      in      boolean  default false,
   p_short_name                    in      varchar2,
   p_name                          in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_business_group_id             in      number,
   p_legislation_code              IN      varchar2,
   p_description                   IN      varchar2,
   p_accrual_category              IN      varchar2,
   p_process_id                    out nocopy number,
   p_object_version_number         out nocopy number)  is
  --
  -- Declare cursors and local variables
  --
  --
  -- Out variables
  --
  l_process_id                 pay_au_processes.process_id%TYPE;
  l_object_version_number      pay_au_processes.object_version_number%TYPE;
  --
  l_proc                       varchar2(72);
  --
  -- Declare a cursor that will check whether the passed
  -- in short_name, business_group_id and legislation_code or
  -- name, business_group_id and legislation_code for a unique
  -- combination
  --
  cursor csr_valid_combo is
  select process_id from pay_au_processes pap
  where  pap.legislation_code = p_legislation_code
  and    (pap.business_group_id is null
          or pap.business_group_id = p_business_group_id)
  and    (pap.short_name = p_short_name
          or pap.name = p_name);
  --
begin
  l_proc      := g_package||'create_au_process';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint create_au_process;
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
     open csr_valid_combo;
     fetch csr_valid_combo into l_process_id;

     -- If the process does not exist then create it.
     -- Do not error if the process does exist, simply return.
     --
     if csr_valid_combo%notfound then
        --
        -- Insert the process.
        --
           pay_apr_ins.ins
           (
            p_process_id                   => l_process_id,
            p_short_name                   => p_short_name,
            p_name                         => p_name,
            p_enabled_flag                 => p_enabled_flag,
            p_business_group_id            => p_business_group_id,
            p_legislation_code             => p_legislation_code,
            p_description                  => p_description,
            p_accrual_category             => p_accrual_category,
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
  p_process_id := l_process_id;
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
    p_process_id  := null;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_au_process;
    --
end create_au_process;
--
-- ------------------------------------------------------------------------
-- |--------------------------< delete_au_process >------------------------|
-- ------------------------------------------------------------------------
--
procedure delete_au_process
  (p_validate                      in      boolean  default false,
   p_process_id                    in      number,
   p_object_version_number         in      number)  is
  --
  l_proc                       varchar2(72);
  --
begin
  l_proc                       := g_package||'delete_au_process';
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint delete_au_process;
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
    pay_apr_del.del
      (p_process_id                => p_process_id,
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
    ROLLBACK TO delete_au_process;
end delete_au_process;
--
--
-- ------------------------------------------------------------------------
-- |--------------------------< update_au_process >-----------------------|
-- ------------------------------------------------------------------------
--
procedure update_au_process
  (p_validate                      in      boolean  default false,
   p_process_id                    in      number,
   p_short_name                    in      varchar2,
   p_name                          in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_business_group_id             in      number,
   p_legislation_code              in      varchar2,
   p_description                   in      varchar2,
   p_accrual_category              in      varchar2,
   p_object_version_number         in out  nocopy   number
  )  is
  --
  l_proc                       varchar2(72);
  --
begin
  l_proc := g_package||'update_au_process';
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint update_au_process;
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
    pay_apr_upd.upd
      (p_process_id                   => p_process_id,
       p_object_version_number        => p_object_version_number,
       p_short_name                   => p_short_name,
       p_name                         => p_name,
       p_enabled_flag                 => p_enabled_flag,
       p_business_group_id            => p_business_group_id,
       p_legislation_code             => p_legislation_code,
       p_description                  => p_description,
       p_accrual_category             => p_accrual_category
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
    ROLLBACK TO update_au_process;
end update_au_process;
--
--
begin
  g_package  := '  pay_au_processes_api.';
end pay_au_processes_api;

/
