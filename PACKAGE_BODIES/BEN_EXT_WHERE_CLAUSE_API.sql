--------------------------------------------------------
--  DDL for Package Body BEN_EXT_WHERE_CLAUSE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_WHERE_CLAUSE_API" as
/* $Header: bexwcapi.pkb 120.2 2005/10/11 06:44:36 rbingi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ext_where_clause_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ext_where_clause >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ext_where_clause
  (p_validate                       in  boolean   default false
  ,p_ext_where_clause_id            out nocopy number
  ,p_seq_num                        in  number    default null
  ,p_oper_cd                        in  varchar2  default null
  ,p_val                            in  varchar2  default null
  ,p_and_or_cd                      in  varchar2  default null
  ,p_ext_data_elmt_id               in  number    default null
  ,p_cond_ext_data_elmt_id          in  number    default null
  ,p_ext_rcd_in_file_id             in  number    default null
  ,p_ext_data_elmt_in_rcd_id        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_cond_ext_data_elmt_in_rcd_id   in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_where_clause_id ben_ext_where_clause.ext_where_clause_id%TYPE;
  l_proc varchar2(72) := g_package||'create_ext_where_clause';
  l_object_version_number ben_ext_where_clause.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ext_where_clause;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ext_where_clause
    --
    ben_ext_where_clause_bk1.create_ext_where_clause_b
      (
       p_seq_num                        =>  p_seq_num
      ,p_oper_cd                        =>  p_oper_cd
      ,p_val                            =>  p_val
      ,p_and_or_cd                      =>  p_and_or_cd
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_cond_ext_data_elmt_id          =>  p_cond_ext_data_elmt_id
      ,p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      ,p_ext_data_elmt_in_rcd_id        =>  p_ext_data_elmt_in_rcd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_cond_ext_data_elmt_in_rcd_id   =>  p_cond_ext_data_elmt_in_rcd_id
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ext_where_clause'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ext_where_clause
    --
  end;
  --
  ben_xwc_ins.ins
    (
     p_ext_where_clause_id           => l_ext_where_clause_id
    ,p_seq_num                       => p_seq_num
    ,p_oper_cd                       => p_oper_cd
    ,p_val                           => p_val
    ,p_and_or_cd                     => p_and_or_cd
    ,p_ext_data_elmt_id              => p_ext_data_elmt_id
    ,p_cond_ext_data_elmt_id         => p_cond_ext_data_elmt_id
    ,p_ext_rcd_in_file_id            => p_ext_rcd_in_file_id
    ,p_ext_data_elmt_in_rcd_id       => p_ext_data_elmt_in_rcd_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_cond_ext_data_elmt_in_rcd_id  => p_cond_ext_data_elmt_in_rcd_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ext_where_clause
    --
    ben_ext_where_clause_bk1.create_ext_where_clause_a
      (
       p_ext_where_clause_id            =>  l_ext_where_clause_id
      ,p_seq_num                        =>  p_seq_num
      ,p_oper_cd                        =>  p_oper_cd
      ,p_val                            =>  p_val
      ,p_and_or_cd                      =>  p_and_or_cd
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_cond_ext_data_elmt_id          =>  p_cond_ext_data_elmt_id
      ,p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      ,p_ext_data_elmt_in_rcd_id        =>  p_ext_data_elmt_in_rcd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_cond_ext_data_elmt_in_rcd_id   =>  p_cond_ext_data_elmt_in_rcd_id
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ext_where_clause'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ext_where_clause
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
  p_ext_where_clause_id := l_ext_where_clause_id;
  p_object_version_number := l_object_version_number;
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
    ROLLBACK TO create_ext_where_clause;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_where_clause_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ext_where_clause;
    p_ext_where_clause_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_ext_where_clause;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ext_where_clause >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ext_where_clause
  (p_validate                       in  boolean   default false
  ,p_ext_where_clause_id            in  number
  ,p_seq_num                        in  number    default hr_api.g_number
  ,p_oper_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  varchar2  default hr_api.g_varchar2
  ,p_and_or_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_ext_data_elmt_id               in  number    default hr_api.g_number
  ,p_cond_ext_data_elmt_id          in  number    default hr_api.g_number
  ,p_ext_rcd_in_file_id             in  number    default hr_api.g_number
  ,p_ext_data_elmt_in_rcd_id        in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_cond_ext_data_elmt_in_rcd_id   in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ext_where_clause';
  l_object_version_number ben_ext_where_clause.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ext_where_clause;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ext_where_clause
    --
    ben_ext_where_clause_bk2.update_ext_where_clause_b
      (
       p_ext_where_clause_id            =>  p_ext_where_clause_id
      ,p_seq_num                        =>  p_seq_num
      ,p_oper_cd                        =>  p_oper_cd
      ,p_val                            =>  p_val
      ,p_and_or_cd                      =>  p_and_or_cd
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_cond_ext_data_elmt_id          =>  p_cond_ext_data_elmt_id
      ,p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      ,p_ext_data_elmt_in_rcd_id        =>  p_ext_data_elmt_in_rcd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      ,p_cond_ext_data_elmt_in_rcd_id   =>  p_cond_ext_data_elmt_in_rcd_id
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ext_where_clause'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ext_where_clause
    --
  end;
  --
  ben_xwc_upd.upd
    (
     p_ext_where_clause_id           => p_ext_where_clause_id
    ,p_seq_num                       => p_seq_num
    ,p_oper_cd                       => p_oper_cd
    ,p_val                           => p_val
    ,p_and_or_cd                     => p_and_or_cd
    ,p_ext_data_elmt_id              => p_ext_data_elmt_id
    ,p_cond_ext_data_elmt_id         => p_cond_ext_data_elmt_id
    ,p_ext_rcd_in_file_id            => p_ext_rcd_in_file_id
    ,p_ext_data_elmt_in_rcd_id       => p_ext_data_elmt_in_rcd_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_cond_ext_data_elmt_in_rcd_id  => p_cond_ext_data_elmt_in_rcd_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ext_where_clause
    --
    ben_ext_where_clause_bk2.update_ext_where_clause_a
      (
       p_ext_where_clause_id            =>  p_ext_where_clause_id
      ,p_seq_num                        =>  p_seq_num
      ,p_oper_cd                        =>  p_oper_cd
      ,p_val                            =>  p_val
      ,p_and_or_cd                      =>  p_and_or_cd
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_cond_ext_data_elmt_id          =>  p_cond_ext_data_elmt_id
      ,p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      ,p_ext_data_elmt_in_rcd_id        =>  p_ext_data_elmt_in_rcd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_cond_ext_data_elmt_in_rcd_id   =>  p_cond_ext_data_elmt_in_rcd_id
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ext_where_clause'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ext_where_clause
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
  p_object_version_number := l_object_version_number;
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
    ROLLBACK TO update_ext_where_clause;
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
    ROLLBACK TO update_ext_where_clause;
    raise;
    --
end update_ext_where_clause;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ext_where_clause >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ext_where_clause
  (p_validate                       in  boolean  default false
  ,p_ext_where_clause_id            in  number
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ext_where_clause';
  l_object_version_number ben_ext_where_clause.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ext_where_clause;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_ext_where_clause
    --
    ben_ext_where_clause_bk3.delete_ext_where_clause_b
      (
       p_ext_where_clause_id            =>  p_ext_where_clause_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ext_where_clause'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ext_where_clause
    --
  end;
  --
  ben_xwc_del.del
    (
     p_ext_where_clause_id           => p_ext_where_clause_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ext_where_clause
    --
    ben_ext_where_clause_bk3.delete_ext_where_clause_a
      (
       p_ext_where_clause_id            =>  p_ext_where_clause_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ext_where_clause'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ext_where_clause
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
    ROLLBACK TO delete_ext_where_clause;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_ext_where_clause;
    raise;
    --
end delete_ext_where_clause;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_where_clause_id                   in     number
  ,p_object_version_number          in     number
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
  ben_xwc_shd.lck
    (
      p_ext_where_clause_id                 => p_ext_where_clause_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------< multi_rows_edit >----------------------------------|
-- |----The procedure checks for Completeness of the AND , OR Conditon -------|
-- |-------and will be called from ON-COMMIT Trigger of the Form -------------|
-- ----------------------------------------------------------------------------
--
procedure multi_rows_edit
                        (p_business_group_id       in number
                        ,p_legislation_code        in varchar2
                        ,p_ext_rcd_in_file_id      in number
                        ,p_ext_data_elmt_in_rcd_id in number
                        ,p_ext_data_elmt_id        in number )
                        is
--
  l_proc  varchar2(72) := 'insert_validate';
--
 cursor c_xwc is
  SELECT seq_num, and_or_cd
  FROM ben_ext_where_clause xwc
  WHERE ( business_group_id is null
      or business_group_id = p_business_group_id )
  and (legislation_code is null
      or legislation_code = p_legislation_code )
  and (ext_rcd_in_file_id = p_ext_rcd_in_file_id
      or p_ext_rcd_in_file_id is null )
  and (ext_data_elmt_in_rcd_id  = p_ext_data_elmt_in_rcd_id
      or p_ext_data_elmt_in_rcd_id is null)
  and (ext_data_elmt_id = p_ext_data_elmt_id
      or p_ext_data_elmt_id is null)
  ORDER BY seq_num;
--
l_dynamic_sql_stmt varchar2(500);
l_rec_defined BOOLEAN := FALSE;
--
Begin
--
l_dynamic_sql_stmt := 'Begin If ';
--
   for l_xwc in c_xwc
   Loop
     l_dynamic_sql_stmt := l_dynamic_sql_stmt || ' TRUE '||l_xwc.and_or_cd;
     l_rec_defined := TRUE ;
    --
   End Loop;
--
l_dynamic_sql_stmt := l_dynamic_sql_stmt || ' then null; end if; end;';
  If l_rec_defined then
    begin
     execute immediate l_dynamic_sql_stmt;
    exception
      when others then
        fnd_message.set_name('BEN','BEN_94457_CHK_AND_OR_CD');
        fnd_message.raise_error;
    end;
  End if;
--
End multi_rows_edit;
--
end ben_ext_where_clause_api;

/
