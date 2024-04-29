--------------------------------------------------------
--  DDL for Package Body HR_LEG_API_HOOK_CALL_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEG_API_HOOK_CALL_INTERNAL" as
/* $Header: peahlbsi.pkb 115.2 2002/12/03 13:42:42 apholt ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_leg_api_hook_call_internal.';
--
-- ------------------------------------------------------------------------
-- |---------------------< create_leg_api_hook_call >-------------------------|
-- ------------------------------------------------------------------------
--
procedure create_leg_api_hook_call
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_hook_id                  in     number,
   p_api_hook_call_type           in     varchar2,
   p_sequence                     in     number,
   p_enabled_flag                 in     varchar2  default 'Y',
   p_legislation_code             in     varchar2  default null,
   p_call_package                 in     varchar2  default null,
   p_call_procedure               in     varchar2  default null,
   p_api_hook_call_id             out nocopy    number,
   p_object_version_number        out nocopy    number) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  --
  --
  -- Out variables
  --
  l_api_hook_call_id           hr_api_hook_calls.api_hook_call_id%TYPE;
  l_object_version_number      hr_api_hook_calls.object_version_number%TYPE;

  -- Temp variables
  l_encoded_error              hr_api_hook_calls.encoded_error%TYPE := null;
  l_status                     hr_api_hook_calls.status%TYPE := 'N';
  l_pre_processor_date         hr_api_hook_calls.pre_processor_date%TYPE := null;
  --
  l_proc                       varchar2(72) := g_package||'create_leg_api_hook_call';
  --
  -- Declare a cursor that will check whether the passed
  -- in hook package and hook procedure form a unique combination

   cursor csr_valid_combo is
   select api_hook_call_id from hr_api_hook_calls
   where api_hook_id = p_api_hook_id
   and   nvl(legislation_code,'x') = nvl(p_legislation_code,'x')
   and   nvl(call_package, 'x') = nvl(p_call_package,'x')
   and   nvl(call_procedure, 'x') = nvl(p_call_procedure, 'x')
   and   application_id IS NULL;

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
  savepoint create_leg_api_hook_call;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  if (p_legislation_code is null) then
    --
    hr_utility.set_message(800, 'PER_52150_AHC_LEG_CODE_NULL');
    hr_utility.raise_error;
    --
  end if;
  --
  -- Process Logic
  ----------------------------------------------------------------------------
  -- Check for combination of hook call id, leg code, call pack, call proc --
  ----------------------------------------------------------------------------
  open csr_valid_combo;
  fetch csr_valid_combo into l_api_hook_call_id;

    -- Only call row handler code if the row doesn't already exist.
    if csr_valid_combo%notfound then
    --
    -- Insert the hook row.
    --
      hr_ahc_ins.ins
      (
       p_api_hook_call_id             => l_api_hook_call_id ,
       p_effective_date               => l_effective_date,
       p_api_hook_id                  => p_api_hook_id,
       p_api_hook_call_type           => p_api_hook_call_type,
       p_legislation_code             => p_legislation_code,
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
    end if;

  close csr_valid_combo;

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
    ROLLBACK TO create_leg_api_hook_call;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_api_hook_call_id  := null;
    p_object_version_number := null;
  when others then
    ROLLBACK TO create_leg_api_hook_call;
    p_api_hook_call_id  := null;
    p_object_version_number := null;
    RAISE;
end create_leg_api_hook_call;
--
--
-- ---------------------------------------------------------------------------
-- |--------------------------< delete_leg_api_hook_call >-------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_leg_api_hook_call
  (p_validate                           in     boolean  default false,
   p_api_hook_call_id                   in     number,
   p_object_version_number              in     number)  is
  --
  l_proc                   varchar2(72) := g_package||'delete_leg_api_hook_call';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_leg_api_hook_call;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
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
    ROLLBACK TO delete_leg_api_hook_call;
  when others then
    ROLLBACK TO delete_leg_api_hook_call;
    raise;
end delete_leg_api_hook_call;
--
--
-- ------------------------------------------------------------------------
-- |---------------------< update_leg_api_hook_call >-------------------------|
-- ------------------------------------------------------------------------
--
procedure update_leg_api_hook_call
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
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  --
  -- Out variables
  --
  l_object_version_number      hr_api_hook_calls.object_version_number%TYPE;

  l_proc                       varchar2(72) := g_package||'update_leg_api_hook_call';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Set l_effective_date equal to truncated version of p_effective_date for
  -- API work. Stops dates being passed to row handlers with time portion.
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Capture the in value for the object version number
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint update_leg_api_hook_call;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- Update the hook call row
  --
  hr_ahc_upd.upd
  (
  p_api_hook_call_id             => p_api_hook_call_id ,
  p_effective_date               => l_effective_date,
  p_sequence                     => p_sequence,
  p_enabled_flag                 => p_enabled_flag,
  p_call_package                 => p_call_package,
  p_call_procedure               => p_call_procedure,
  p_object_version_number        => p_object_version_number
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
    p_object_version_number := l_object_version_number;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_leg_api_hook_call;
    --
  when others then
    ROLLBACK TO update_leg_api_hook_call;
    p_object_version_number := null;
    RAISE;
end update_leg_api_hook_call;
--
end hr_leg_api_hook_call_internal;

/
