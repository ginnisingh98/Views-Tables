--------------------------------------------------------
--  DDL for Package Body PER_SHARED_TYPES_TL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SHARED_TYPES_TL_API" as
/* $Header: pesttapi.pkb 115.3 2002/12/11 17:08:13 eumenyio ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_shared_types_tl_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_shared_types_tl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_shared_types_tl
  (p_validate                       in  boolean   default false
  ,p_shared_type_id                 out nocopy number
  ,p_language                       out nocopy varchar2
  ,p_source_lang                    in  varchar2  default null
  ,p_shared_type_name               in  varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_shared_type_id per_shared_types_tl.shared_type_id%TYPE;
  l_language per_shared_types_tl.language%TYPE;
  l_proc varchar2(72) := g_package||'create_shared_types_tl';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_shared_types_tl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_shared_types_tl
    --
    per_shared_types_tl_bk1.create_shared_types_tl_b
      (
       p_source_lang                    =>  p_source_lang
      ,p_shared_type_name               =>  p_shared_type_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_shared_types_tl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_shared_types_tl
    --
  end;
  --
  per_stt_ins.ins_tl
    (
     p_shared_type_id                => l_shared_type_id
    ,p_language_code                 => l_language
    ,p_shared_type_name              => p_shared_type_name
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_shared_types_tl
    --
    per_shared_types_tl_bk1.create_shared_types_tl_a
      (
       p_shared_type_id                 =>  l_shared_type_id
      ,p_language                       =>  l_language
      ,p_source_lang                    =>  p_source_lang
      ,p_shared_type_name               =>  p_shared_type_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_shared_types_tl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_shared_types_tl
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_shared_type_id := l_shared_type_id;
  p_language := l_language;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_shared_types_tl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_shared_type_id := null;
    p_language := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_language        := null;
    p_shared_type_id  := null;
    ROLLBACK TO create_shared_types_tl;
    raise;
    --
end create_shared_types_tl;
-- ----------------------------------------------------------------------------
-- |------------------------< update_shared_types_tl >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_shared_types_tl
  (p_validate                       in  boolean   default false
  ,p_shared_type_id                 in  number
  ,p_language                       out nocopy varchar2
  ,p_source_lang                    in  varchar2  default hr_api.g_varchar2
  ,p_shared_type_name               in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_shared_types_tl';
  l_language per_shared_types_tl.language%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_shared_types_tl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_shared_types_tl
    --
    per_shared_types_tl_bk2.update_shared_types_tl_b
      (
       p_shared_type_id                 =>  p_shared_type_id
      ,p_source_lang                    =>  p_source_lang
      ,p_shared_type_name               =>  p_shared_type_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_shared_types_tl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_shared_types_tl
    --
  end;
  --
  per_stt_upd.upd_tl
    (
     p_shared_type_id                => p_shared_type_id
    ,p_language_code                 => l_language
    ,p_shared_type_name              => p_shared_type_name
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_shared_types_tl
    --
    per_shared_types_tl_bk2.update_shared_types_tl_a
      (
       p_shared_type_id                 =>  p_shared_type_id
      ,p_language                       =>  l_language
      ,p_source_lang                    =>  p_source_lang
      ,p_shared_type_name               =>  p_shared_type_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_shared_types_tl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_shared_types_tl
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_language := l_language;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_shared_types_tl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_language  := null;
    ROLLBACK TO update_shared_types_tl;
    raise;
    --
end update_shared_types_tl;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_shared_types_tl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_shared_types_tl
  (p_validate                       in  boolean  default false
  ,p_shared_type_id                 in  number
  ,p_language                       out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_shared_types_tl';
  l_language per_shared_types_tl.language%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_shared_types_tl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_shared_types_tl
    --
    per_shared_types_tl_bk3.delete_shared_types_tl_b
      (
       p_shared_type_id                 =>  p_shared_type_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_shared_types_tl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_shared_types_tl
    --
  end;
  --
  per_stt_del.del_tl
    (
     p_shared_type_id                => p_shared_type_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_shared_types_tl
    --
    per_shared_types_tl_bk3.delete_shared_types_tl_a
      (
       p_shared_type_id                 =>  p_shared_type_id
      ,p_language                       =>  l_language
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_shared_types_tl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_shared_types_tl
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_shared_types_tl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_language  := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_language  := null;
    ROLLBACK TO delete_shared_types_tl;
    raise;
    --
end delete_shared_types_tl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_shared_type_id                   in     number
  ,p_language          in     varchar2
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  per_stt_shd.lck
    (
      p_shared_type_id                 => p_shared_type_id
     ,p_language                       => p_language
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end per_shared_types_tl_api;

/
