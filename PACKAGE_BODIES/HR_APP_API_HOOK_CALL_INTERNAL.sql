--------------------------------------------------------
--  DDL for Package Body HR_APP_API_HOOK_CALL_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APP_API_HOOK_CALL_INTERNAL" as
/* $Header: peahcbsi.pkb 115.4 2002/12/05 12:51:46 apholt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_app_api_hook_call_internal.';
--
-- ------------------------------------------------------------------------
-- |--------------------< create_app_api_hook_call >----------------------|
-- ------------------------------------------------------------------------
--
procedure create_app_api_hook_call
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_hook_id                  in     number,
   p_api_hook_call_type           in     varchar2,
   p_sequence                     in     number,
   p_application_id               in     number,
   p_app_install_status           in     varchar2,
   p_enabled_flag                 in     varchar2  default 'N',
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

  l_legislation_code           hr_api_hook_calls.legislation_code%TYPE := null;
  l_encoded_error              hr_api_hook_calls.encoded_error%TYPE := null;
  l_status                     hr_api_hook_calls.status%TYPE := 'N';
  l_pre_processor_date         hr_api_hook_calls.pre_processor_date%TYPE := null;
  --
  l_proc                       varchar2(72) :=   g_package
                                              || 'create_app_api_hook_call';
  --
  -- Declare a cursor that will check whether the passed
  -- in hook package and hook procedure form a unique combination

   cursor csr_valid_combo is
   select api_hook_call_id, object_version_number
     from hr_api_hook_calls
   where api_hook_id = p_api_hook_id
   and   nvl(application_id,hr_api.g_number)
       = nvl(p_application_id,hr_api.g_number)
   and   nvl(call_package, hr_api.g_varchar2)
       = nvl(p_call_package,hr_api.g_varchar2)
   and   nvl(call_procedure, hr_api.g_varchar2)
       = nvl(p_call_procedure, hr_api.g_varchar2)
   and   legislation_code IS NULL;

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
  savepoint create_app_api_hook_call;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  if (p_application_id is NULL) then
    --
    hr_utility.set_message(800, 'PER_289090_AHC_APP_ID_NULL');
    hr_utility.raise_error;
    --
  end if;
  --
  if (p_app_install_status is NULL) then
    --
    hr_utility.set_message(800,'PER_289091_AHC_INST_STAT_NULL');
    hr_utility.raise_error;
    --
  end if;
  --
  -- Process Logic
  ----------------------------------------------------------------------------
  -- Check for combination of hook call id, app_id, call pack, call proc --
  ----------------------------------------------------------------------------
  open csr_valid_combo;
  fetch csr_valid_combo into l_api_hook_call_id, l_object_version_number;

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
       p_legislation_code             => l_legislation_code,
       p_sequence                     => p_sequence,
       p_enabled_flag                 => p_enabled_flag,
       p_call_package                 => p_call_package,
       p_call_procedure               => p_call_procedure,
       p_pre_processor_date           => l_pre_processor_date,
       p_encoded_error                => l_encoded_error,
       p_status                       => l_status,
       p_object_version_number        => l_object_version_number,
       p_application_id               => p_application_id,
       p_app_install_status           => p_app_install_status
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
    ROLLBACK TO create_app_api_hook_call;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_api_hook_call_id  := null;
    p_object_version_number := null;
  when others then
    ROLLBACK TO create_app_api_hook_call;
    p_api_hook_call_id  := null;
    p_object_version_number := null;
    RAISE;
end create_app_api_hook_call;
--
--
-- ---------------------------------------------------------------------------
-- |--------------------------< delete_app_api_hook_call >-------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_app_api_hook_call
  (p_validate                           in     boolean  default false,
   p_api_hook_call_id                   in     number,
   p_object_version_number              in     number)  is
  --
  l_proc                   varchar2(72) := g_package||'delete_app_api_hook_call';
  --
  -- Cursor to check application_id
  CURSOR csr_check_app IS
   SELECT 'Y'
     FROM hr_api_hook_calls
    WHERE api_hook_call_id = p_api_hook_call_id
      AND application_id IS NOT NULL;
  --
  -- Cursor to check hook call exists
  CURSOR csr_check_exists IS
   SELECT 'Y'
     FROM hr_api_hook_calls
    WHERE api_hook_call_id = p_api_hook_call_id;
  --
  l_exists varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_app_api_hook_call;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- Ensure the hook call definition specified  is an application specific
  -- hook call, and that application_id is null.
  OPEN csr_check_app;
  FETCH csr_check_app INTO l_exists;
  IF csr_check_app%NOTFOUND THEN
     CLOSE csr_check_app;
     -- api_hook_call_id specified does not reference an application hook call
     --
     -- Check if hook exists at all.
     OPEN csr_check_exists;
     FETCH csr_check_exists INTO l_exists;
     IF csr_check_exists%NOTFOUND THEN
        -- Hook does not exist at all.
         CLOSE csr_check_exists;
         hr_utility.set_message(800,'PER_289096_AHC_HOOK_NOT_EXIST');
         hr_utility.raise_error;
     ELSE
         -- Hook exists, but is not application hook.
         CLOSE csr_check_exists;
         hr_utility.set_message(800,'PER_289092_AHC_NOT_APPL_HOOK');
         hr_utility.raise_error;
     END IF;
  END IF;
  CLOSE csr_check_app;
  --
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
    ROLLBACK TO delete_app_api_hook_call;
  when others then
    ROLLBACK TO delete_app_api_hook_call;
    raise;
end delete_app_api_hook_call;
--
--
-- ------------------------------------------------------------------------
-- |---------------------< update_app_api_hook_call >-------------------------|
-- ------------------------------------------------------------------------
--
procedure update_app_api_hook_call
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_hook_call_id             in     number,
   p_object_version_number        in out nocopy number,
   p_sequence                     in     number    default hr_api.g_number,
   p_app_install_status           in     varchar2  default hr_api.g_varchar2,
   p_enabled_flag                 in     varchar2  default hr_api.g_varchar2,
   p_call_package                 in     varchar2  default hr_api.g_varchar2,
   p_call_procedure               in     varchar2  default hr_api.g_varchar2,
   p_pre_processor_date           in     date      default hr_api.g_date,
   p_encoded_error                in     varchar2  default hr_api.g_varchar2,
   p_status                       in     varchar2  default hr_api.g_varchar2
   ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  --
  -- Out variables
  --
  l_object_version_number      hr_api_hook_calls.object_version_number%TYPE;

  l_proc                       varchar2(72) := g_package||'update_app_api_hook_call';
  --
  -- Cursor to check application_id
  CURSOR csr_check_app IS
   SELECT 'Y'
     FROM hr_api_hook_calls
    WHERE api_hook_call_id = p_api_hook_call_id
      AND application_id IS NOT NULL;
  --
  -- Cursor to check hook call exists
  CURSOR csr_check_exists IS
   SELECT 'Y'
     FROM hr_api_hook_calls
    WHERE api_hook_call_id = p_api_hook_call_id;
  --
  l_exists varchar2(1);
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
  savepoint update_app_api_hook_call;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- Ensure the hook call definition specified  is an application specific
  -- hook call, and that application_id is null.
  OPEN csr_check_app;
  FETCH csr_check_app INTO l_exists;
  IF csr_check_app%NOTFOUND THEN
     CLOSE csr_check_app;
     -- api_hook_call_id specified does not reference an application hook call
     -- Check if hook exists
     OPEN csr_check_exists;
     FETCH csr_check_exists INTO l_exists;
     IF csr_check_exists%NOTFOUND THEN
        CLOSE csr_check_exists;
        -- Hook call does not exist at all
        hr_utility.set_message(800,'PER_289096_AHC_HOOK_NOT_EXIST');
        hr_utility.raise_error;
     ELSE
        CLOSE csr_check_exists;
        -- Hook call exists, but does not reference Application Hook call.
        hr_utility.set_message(800,'PER_289092_AHC_NOT_APPL_HOOK');
        hr_utility.raise_error;
     END IF;
  END IF;
  CLOSE csr_check_app;
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
  p_pre_processor_date           => p_pre_processor_date,
  p_encoded_error                => p_encoded_error,
  p_status                       => p_status,
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
    ROLLBACK TO update_app_api_hook_call;
    --
  when others then
    ROLLBACK TO update_app_api_hook_call;
    p_object_version_number :=null;
    RAISE;
end update_app_api_hook_call;
--
end hr_app_api_hook_call_internal;

/
