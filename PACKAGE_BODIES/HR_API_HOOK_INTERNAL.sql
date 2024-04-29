--------------------------------------------------------
--  DDL for Package Body HR_API_HOOK_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_API_HOOK_INTERNAL" as
/* $Header: peahkbsi.pkb 115.1 2002/12/03 16:24:43 apholt ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_api_hook_internal.';
--
-- ------------------------------------------------------------------------
-- |--------------------------< create_api_hook >----------------------------|
-- ------------------------------------------------------------------------
--
procedure create_api_hook
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_module_id                in     number,
   p_api_hook_type                in     varchar2,
   p_hook_package                 in     varchar2,
   p_hook_procedure               in     varchar2,
   p_legislation_code             in     varchar2         default null,
   p_legislation_package          in     varchar2         default null,
   p_legislation_function         in     varchar2         default null,
   p_api_hook_id                  OUT NOCOPY    number) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  --
  -- Out variables
  --
  l_api_hook_id                hr_api_hooks.api_hook_id%TYPE;
  l_proc                       varchar2(72) := g_package||'create_api_hook';
  --
  --
  -- Declare a cursor that will check whether the passed
  -- in hook package and hook procedure form a unique combination
     cursor csr_valid_combo is
     select api_hook_id from hr_api_hooks hah
     where hah.hook_package = p_hook_package
     and   hah.hook_procedure = p_hook_procedure;

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
    savepoint create_api_hook;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process Logic
     open csr_valid_combo;
     fetch csr_valid_combo into l_api_hook_id;

  -- If the module does not exist then create it.
  -- Do not error if the module does exist, simply return.
  --
     if csr_valid_combo%notfound then
      --
      -- Insert the hook row.
      --
      hr_ahk_ins.ins
      (
      p_api_hook_id                  =>  l_api_hook_id,
      p_effective_date               =>  l_effective_date,
      p_api_module_id                =>  p_api_module_id,
      p_api_hook_type                =>  p_api_hook_type,
      p_hook_package                 =>  p_hook_package,
      p_hook_procedure               =>  p_hook_procedure,
      p_legislation_code             =>  p_legislation_code,
      p_legislation_package          =>  p_legislation_package,
      p_legislation_function         =>  p_legislation_function
      );
      --
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
  p_api_hook_id := l_api_hook_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_api_hook_id  := null;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_api_hook;
    --
  when others then
    ROLLBACK TO create_api_hook;
    p_api_hook_id  := null;
    RAISE;
end create_api_hook;
--
-- ------------------------------------------------------------------------
-- |--------------------------< delete_api_hook >----------------------------|
-- ------------------------------------------------------------------------
--
procedure delete_api_hook
  (p_validate                      in      boolean  default false,
   p_api_hook_id                   in     number)  is
  --
  l_proc                       varchar2(72) := g_package||'delete_api_hook';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint delete_api_hook;
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
    hr_ahk_del.del
      (p_api_hook_id                => p_api_hook_id);
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
    ROLLBACK TO delete_api_hook;
    --
end delete_api_hook;
--
-- ------------------------------------------------------------------------
-- |--------------------------< update_api_hook >----------------------------|
-- ------------------------------------------------------------------------
--
procedure update_api_hook
  (p_validate                     in     boolean      default false,
   p_effective_date               in     date,
   p_api_hook_id                  in     number,
   p_api_hook_type                in     varchar2     default hr_api.g_varchar2,
   p_hook_package                 in     varchar2     default hr_api.g_varchar2,
   p_hook_procedure               in     varchar2     default hr_api.g_varchar2,
   p_legislation_package          in     varchar2     default hr_api.g_varchar2,
   p_legislation_function         in     varchar2     default hr_api.g_varchar2
  )
is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  --
  -- Out variables
  --
  l_api_hook_id                hr_api_hooks.api_hook_id%TYPE;
  --
  l_proc                       varchar2(72) := g_package||'update_api_hook';
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
    savepoint update_api_hook;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- Update the hook row.
  --
  hr_ahk_upd.upd
    (p_api_hook_id                  =>  p_api_hook_id,
     p_effective_date               =>  l_effective_date,
     p_api_hook_type                =>  p_api_hook_type,
     p_hook_package                 =>  p_hook_package,
     p_hook_procedure               =>  p_hook_procedure,
     p_legislation_package          =>  p_legislation_package,
     p_legislation_function         =>  p_legislation_function
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
  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_api_hook;
    --
end update_api_hook;
--
end hr_api_hook_internal;

/
