--------------------------------------------------------
--  DDL for Package Body HR_API_HOOK_CALL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_API_HOOK_CALL_API" as
/* $Header: peahcapi.pkb 120.1 2007/08/20 10:34:44 ande ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_api_hook_call.';
--
-- ------------------------------------------------------------------------
-- |---------------------< create_api_hook_call >-------------------------|
-- ------------------------------------------------------------------------
--
procedure create_api_hook_call
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_hook_id                  in     number,
   p_api_hook_call_type           in     varchar2,
   p_sequence                     in     number,
   p_enabled_flag                 in     varchar2,
   p_call_package                 in     varchar2  default null,
   p_call_procedure               in     varchar2  default null,
   p_api_hook_call_id             out nocopy    number,
   p_object_version_number        out nocopy    number) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  --
  -- Out variables
  --
  l_api_hook_call_id           hr_api_hook_calls.api_hook_call_id%TYPE;
  l_object_version_number      hr_api_hook_calls.object_version_number%TYPE;

-- Temp variables
  l_encoded_error              hr_api_hook_calls.encoded_error%TYPE := null;
  l_status                     hr_api_hook_calls.status%TYPE := 'N';
  l_pre_processor_date         hr_api_hook_calls.pre_processor_date%TYPE := null;
  l_legislation_code           hr_api_hook_calls.legislation_code%TYPE := null;
  --
  l_proc                       varchar2(72) := g_package||'create_api_hook_call';
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
    savepoint create_api_hook_call;
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
  -- Insert the hook row.
  --

  hr_ahc_ins.ins
  (
  p_api_hook_call_id             => l_api_hook_call_id ,
  p_effective_date               => l_effective_date,
  p_api_hook_id                  => p_api_hook_id,
  p_api_hook_call_type           => p_api_hook_call_type,
  p_legislation_code             => l_legislation_code,
  p_sequence                     => p_sequence,
  p_enabled_flag                 => p_enabled_flag,
  p_call_package                 => p_call_package,
  p_call_procedure               => p_call_procedure,
  p_pre_processor_date           => l_pre_processor_date,
  p_encoded_error                => l_encoded_error,
  p_status                       => l_status,
  p_object_version_number        => l_object_version_number
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
  -- Set all output arguments
  --
  p_api_hook_call_id := l_api_hook_call_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_api_hook_call;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_api_hook_call_id  := null;
    p_object_version_number := null;
    --
  WHEN others then
    --added as part of
    --NOCOPY Performance Changes for 11.5.9
    ROLLBACK TO create_api_hook_call;
     p_object_version_number :=null;
    p_api_hook_call_id  := null;
    --
end create_api_hook_call;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< delete_api_hook_call >-------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_api_hook_call
  (p_validate                           in     boolean  default false,
   p_api_hook_call_id                   in     number,
   p_object_version_number              in     number
  )  is
  --
  l_proc                   varchar2(72) := g_package||'delete_api_hook_call';
  l_leg_code               hr_api_hook_calls.legislation_code%TYPE;
  --
  -- Setup a cursor to retrieve leg code for the hook call
  --
     Cursor csr_get_leg_code is
     Select legislation_code
     from   hr_api_hook_calls
     where api_hook_call_id = p_api_hook_call_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint delete_api_hook_call;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
     open csr_get_leg_code;
     fetch csr_get_leg_code into l_leg_code;

     if (l_leg_code is not null) then
        hr_utility.set_message(800, 'PER_52149_AHC_CANNOT_DEL_ROW');
        hr_utility.raise_error;
     end if;
  --
  -- Process Logic
  --
    hr_ahc_del.del
      (p_api_hook_call_id                => p_api_hook_call_id,
       p_object_version_number           => p_object_version_number);
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
    ROLLBACK TO delete_api_hook_call;
end delete_api_hook_call;
--
-- ------------------------------------------------------------------------
-- |---------------------< update_api_hook_call >-------------------------|
-- ------------------------------------------------------------------------
--
procedure update_api_hook_call
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_hook_call_id             in     number,
   p_sequence                     in     number    default hr_api.g_number,
   p_enabled_flag                 in     varchar2  default hr_api.g_varchar2,
   p_call_package                 in     varchar2  default hr_api.g_varchar2,
   p_call_procedure               in     varchar2  default hr_api.g_varchar2,
   p_object_version_number        in out nocopy    number
  ) is
  --
  l_proc                   varchar2(72) := g_package||'update_api_hook_call';
  --
  -- Declare cursors and local variables
  --
  l_effective_date        date;
  --
  l_object_version_number number;
  --
  l_leg_code               hr_api_hook_calls.legislation_code%TYPE;
  --
  -- Setup a cursor to retrieve leg code for the hook call
  --
     Cursor csr_get_leg_code is
     Select legislation_code
     from   hr_api_hook_calls
     where api_hook_call_id = p_api_hook_call_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Set l_effective_date equal to truncated version of p_effective_date for
  -- API work. Stops dates being passed to row handlers with time portion.
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Capture the IN value for OVN
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint update_api_hook_call;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  open csr_get_leg_code;
  fetch csr_get_leg_code into l_leg_code;
  if (l_leg_code is not null) then
     --
     close csr_get_leg_code;
     hr_utility.set_message(800, 'PER_52149_AHC_CANNOT_DEL_ROW');
     hr_utility.raise_error;
     --
  end if;
  close csr_get_leg_code;
  --
  -- Update the hook row.
  --
  hr_ahc_upd.upd
    (p_api_hook_call_id             => p_api_hook_call_id
    ,p_effective_date               => l_effective_date
    ,p_sequence                     => p_sequence
    ,p_enabled_flag                 => p_enabled_flag
    ,p_call_package                 => p_call_package
    ,p_call_procedure               => p_call_procedure
    ,p_object_version_number        => p_object_version_number
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
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_api_hook_call;
    --
  WHEN others then
    --added as part of
    --NOCOPY Performance Changes for 11.5.9
    ROLLBACK TO update_api_hook_call;
     p_object_version_number :=null;
    --
end update_api_hook_call;
--
--
end hr_api_hook_call_api;

/
