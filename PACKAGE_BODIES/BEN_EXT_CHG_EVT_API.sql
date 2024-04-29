--------------------------------------------------------
--  DDL for Package Body BEN_EXT_CHG_EVT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_CHG_EVT_API" as
/* $Header: bexclapi.pkb 120.1 2005/06/23 15:04:38 tjesumic noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_CHG_EVT_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_CHG_EVT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_CHG_EVT
  (p_validate                       in  boolean   default false
  ,p_ext_chg_evt_log_id             out nocopy number
  ,p_chg_evt_cd                     in  varchar2  default null
  ,p_chg_eff_dt                     in  date      default null
  ,p_chg_user_id                    in  number    default null
  ,p_prmtr_01                       in  varchar2  default null
  ,p_prmtr_02                       in  varchar2  default null
  ,p_prmtr_03                       in  varchar2  default null
  ,p_prmtr_04                       in  varchar2  default null
  ,p_prmtr_05                       in  varchar2  default null
  ,p_prmtr_06                       in  varchar2  default null
  ,p_prmtr_07                       in  varchar2  default null
  ,p_prmtr_08                       in  varchar2  default null
  ,p_prmtr_09                       in  varchar2  default null
  ,p_prmtr_10                       in  varchar2  default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_new_val1                       in varchar2   default null
  ,p_new_val2                       in varchar2   default null
  ,p_new_val3                       in varchar2   default null
  ,p_new_val4                       in varchar2   default null
  ,p_new_val5                       in varchar2   default null
  ,p_new_val6                       in varchar2   default null
  ,p_old_val1                       in varchar2   default null
  ,p_old_val2                       in varchar2   default null
  ,p_old_val3                       in varchar2   default null
  ,p_old_val4                       in varchar2   default null
  ,p_old_val5                       in varchar2   default null
  ,p_old_val6                       in varchar2   default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_chg_evt_log_id ben_ext_chg_evt_log.ext_chg_evt_log_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_CHG_EVT';
  l_object_version_number ben_ext_chg_evt_log.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  -- savepoint create_EXT_CHG_EVT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_CHG_EVT
    --
    ben_EXT_CHG_EVT_bk1.create_EXT_CHG_EVT_b
      (
       p_chg_evt_cd                     =>  p_chg_evt_cd
      ,p_chg_eff_dt                     =>  p_chg_eff_dt
      ,p_chg_user_id                    =>  p_chg_user_id
      ,p_prmtr_01                       =>  p_prmtr_01
      ,p_prmtr_02                       =>  p_prmtr_02
      ,p_prmtr_03                       =>  p_prmtr_03
      ,p_prmtr_04                       =>  p_prmtr_04
      ,p_prmtr_05                       =>  p_prmtr_05
      ,p_prmtr_06                       =>  p_prmtr_06
      ,p_prmtr_07                       =>  p_prmtr_07
      ,p_prmtr_08                       =>  p_prmtr_08
      ,p_prmtr_09                       =>  p_prmtr_09
      ,p_prmtr_10                       =>  p_prmtr_10
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_CHG_EVT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_CHG_EVT
    --
  end;
  --
  ben_xcl_ins.ins
    (
     p_ext_chg_evt_log_id            => l_ext_chg_evt_log_id
    ,p_chg_evt_cd                    => p_chg_evt_cd
    ,p_chg_eff_dt                    => p_chg_eff_dt
    ,p_chg_user_id                   => p_chg_user_id
    ,p_prmtr_01                      => p_prmtr_01
    ,p_prmtr_02                      => p_prmtr_02
    ,p_prmtr_03                      => p_prmtr_03
    ,p_prmtr_04                      => p_prmtr_04
    ,p_prmtr_05                      => p_prmtr_05
    ,p_prmtr_06                      => p_prmtr_06
    ,p_prmtr_07                      => p_prmtr_07
    ,p_prmtr_08                      => p_prmtr_08
    ,p_prmtr_09                      => p_prmtr_09
    ,p_prmtr_10                      => p_prmtr_10
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_chg_actl_dt                   => sysdate
    ,p_new_val1                      => p_new_val1
    ,p_new_val2                      => p_new_val2
    ,p_new_val3                      => p_new_val3
    ,p_new_val4                      => p_new_val4
    ,p_new_val5                      => p_new_val5
    ,p_new_val6                      => p_new_val6
    ,p_old_val1                      => p_old_val1
    ,p_old_val2                      => p_old_val2
    ,p_old_val3                      => p_old_val3
    ,p_old_val4                      => p_old_val4
    ,p_old_val5                      => p_old_val5
    ,p_old_val6                      => p_old_val6
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_CHG_EVT
    --
    ben_EXT_CHG_EVT_bk1.create_EXT_CHG_EVT_a
      (
       p_ext_chg_evt_log_id             =>  l_ext_chg_evt_log_id
      ,p_chg_evt_cd                     =>  p_chg_evt_cd
      ,p_chg_eff_dt                     =>  p_chg_eff_dt
      ,p_chg_user_id                    =>  p_chg_user_id
      ,p_prmtr_01                       =>  p_prmtr_01
      ,p_prmtr_02                       =>  p_prmtr_02
      ,p_prmtr_03                       =>  p_prmtr_03
      ,p_prmtr_04                       =>  p_prmtr_04
      ,p_prmtr_05                       =>  p_prmtr_05
      ,p_prmtr_06                       =>  p_prmtr_06
      ,p_prmtr_07                       =>  p_prmtr_07
      ,p_prmtr_08                       =>  p_prmtr_08
      ,p_prmtr_09                       =>  p_prmtr_09
      ,p_prmtr_10                       =>  p_prmtr_10
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_CHG_EVT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_CHG_EVT
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  -- if p_validate then
  --   raise hr_api.validate_enabled;
  -- end if;
  --
  -- Set all output arguments
  --
  p_ext_chg_evt_log_id := l_ext_chg_evt_log_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  -- when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    -- ROLLBACK TO create_EXT_CHG_EVT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- p_ext_chg_evt_log_id := null;
    -- p_object_version_number  := null;
    -- hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    --ROLLBACK TO create_EXT_CHG_EVT;
    /* Inserted for nocopy changes */
    p_ext_chg_evt_log_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_EXT_CHG_EVT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_CHG_EVT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CHG_EVT
  (p_validate                       in  boolean   default false
  ,p_ext_chg_evt_log_id             in  number
  ,p_chg_evt_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_chg_eff_dt                     in  date      default hr_api.g_date
  ,p_chg_user_id                    in  number    default hr_api.g_number
  ,p_prmtr_01                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_02                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_03                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_04                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_05                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_06                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_07                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_08                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_09                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_10                       in  varchar2  default hr_api.g_varchar2
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_CHG_EVT';
  l_object_version_number ben_ext_chg_evt_log.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_CHG_EVT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_CHG_EVT
    --
    ben_EXT_CHG_EVT_bk2.update_EXT_CHG_EVT_b
      (
       p_ext_chg_evt_log_id             =>  p_ext_chg_evt_log_id
      ,p_chg_evt_cd                     =>  p_chg_evt_cd
      ,p_chg_eff_dt                     =>  p_chg_eff_dt
      ,p_chg_user_id                    =>  p_chg_user_id
      ,p_prmtr_01                       =>  p_prmtr_01
      ,p_prmtr_02                       =>  p_prmtr_02
      ,p_prmtr_03                       =>  p_prmtr_03
      ,p_prmtr_04                       =>  p_prmtr_04
      ,p_prmtr_05                       =>  p_prmtr_05
      ,p_prmtr_06                       =>  p_prmtr_06
      ,p_prmtr_07                       =>  p_prmtr_07
      ,p_prmtr_08                       =>  p_prmtr_08
      ,p_prmtr_09                       =>  p_prmtr_09
      ,p_prmtr_10                       =>  p_prmtr_10
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_CHG_EVT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_CHG_EVT
    --
  end;
  --
  ben_xcl_upd.upd
    (
     p_ext_chg_evt_log_id            => p_ext_chg_evt_log_id
    ,p_chg_evt_cd                    => p_chg_evt_cd
    ,p_chg_eff_dt                    => p_chg_eff_dt
    ,p_chg_user_id                   => p_chg_user_id
    ,p_prmtr_01                      => p_prmtr_01
    ,p_prmtr_02                      => p_prmtr_02
    ,p_prmtr_03                      => p_prmtr_03
    ,p_prmtr_04                      => p_prmtr_04
    ,p_prmtr_05                      => p_prmtr_05
    ,p_prmtr_06                      => p_prmtr_06
    ,p_prmtr_07                      => p_prmtr_07
    ,p_prmtr_08                      => p_prmtr_08
    ,p_prmtr_09                      => p_prmtr_09
    ,p_prmtr_10                      => p_prmtr_10
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_CHG_EVT
    --
    ben_EXT_CHG_EVT_bk2.update_EXT_CHG_EVT_a
      (
       p_ext_chg_evt_log_id             =>  p_ext_chg_evt_log_id
      ,p_chg_evt_cd                     =>  p_chg_evt_cd
      ,p_chg_eff_dt                     =>  p_chg_eff_dt
      ,p_chg_user_id                    =>  p_chg_user_id
      ,p_prmtr_01                       =>  p_prmtr_01
      ,p_prmtr_02                       =>  p_prmtr_02
      ,p_prmtr_03                       =>  p_prmtr_03
      ,p_prmtr_04                       =>  p_prmtr_04
      ,p_prmtr_05                       =>  p_prmtr_05
      ,p_prmtr_06                       =>  p_prmtr_06
      ,p_prmtr_07                       =>  p_prmtr_07
      ,p_prmtr_08                       =>  p_prmtr_08
      ,p_prmtr_09                       =>  p_prmtr_09
      ,p_prmtr_10                       =>  p_prmtr_10
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_CHG_EVT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_CHG_EVT
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
    ROLLBACK TO update_EXT_CHG_EVT;
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
    ROLLBACK TO update_EXT_CHG_EVT;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_EXT_CHG_EVT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_CHG_EVT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CHG_EVT
  (p_validate                       in  boolean  default false
  ,p_ext_chg_evt_log_id             in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_CHG_EVT';
  l_object_version_number ben_ext_chg_evt_log.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_CHG_EVT;
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
    -- Start of API User Hook for the before hook of delete_EXT_CHG_EVT
    --
    ben_EXT_CHG_EVT_bk3.delete_EXT_CHG_EVT_b
      (
       p_ext_chg_evt_log_id             =>  p_ext_chg_evt_log_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_CHG_EVT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_CHG_EVT
    --
  end;
  --
  ben_xcl_del.del
    (
     p_ext_chg_evt_log_id            => p_ext_chg_evt_log_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_CHG_EVT
    --
    ben_EXT_CHG_EVT_bk3.delete_EXT_CHG_EVT_a
      (
       p_ext_chg_evt_log_id             =>  p_ext_chg_evt_log_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_CHG_EVT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_CHG_EVT
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
    ROLLBACK TO delete_EXT_CHG_EVT;
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
    ROLLBACK TO delete_EXT_CHG_EVT;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_EXT_CHG_EVT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_chg_evt_log_id                   in     number
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
  ben_xcl_shd.lck
    (
      p_ext_chg_evt_log_id                 => p_ext_chg_evt_log_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--


Function  pay_interpreter_ressult  (p_assignment_id    in number,
                                    p_event_group_id  in number,
                                    p_actl_date       in date ,
                                    p_dated_table_id  in number,
                                    p_column_name     in varchar2,
                                    p_effective_date  in  date ,
                                    p_eff_date        in date ,
                                    p_change_type     in varchar2,
                                    p_process_event_id in number  )
                                    return varchar2 is

   l_pay_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
   l_pay_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;
   l_pay_detail_tab          pay_interpreter_pkg.t_detailed_output_table_type;
   l_pay_pro_type_tab        pay_interpreter_pkg.t_proration_type_table_type;
   l_dated_table_id          pay_event_updates.dated_table_id%type ;
   l_pdi_success  varchar2(1) ;
   l_proc varchar2(72) := g_package||'pay_interpreter_ressult';
begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      hr_utility.set_location ('p_assignment_id  '||p_assignment_id,10) ;
      hr_utility.set_location ('p_event_group_id '||p_event_group_id,10);
      hr_utility.set_location ('p_actl_date  '||p_actl_date,10);
      hr_utility.set_location ('p_dated_table_id '||p_dated_table_id,10);
      hr_utility.set_location ('p_column_name '||p_column_name,10);
      hr_utility.set_location ('p_effective_date '||p_effective_date,10);
      hr_utility.set_location ('p_eff_date   '||p_eff_date  ,10);
      hr_utility.set_location ('p_change_type   '||p_change_type ,10);
      hr_utility.set_location ('p_process_event_id '||p_process_event_id ,10);

     l_pdi_success := 'N' ;
      pay_interpreter_pkg.entry_affected(
                     p_element_entry_id      => NULL
                    ,p_assignment_action_id  => NULL
                    ,p_assignment_id         => p_Assignment_id
                    ,p_mode                  => NULL
                    ,p_process               => NULL
                    ,p_event_group_id        => p_event_group_id
                    ,p_process_mode          => 'ENTRY_CREATION_DATE'
                    ,p_start_date            => p_actl_date-1
                    ,p_end_date              => p_actl_date+1
                    ,t_detailed_output       => l_pay_detail_tab
                    ,t_proration_dates       => l_pay_proration_dates
                    ,t_proration_change_type => l_pay_proration_changes
                    ,t_proration_type        => l_pay_pro_type_tab
                    );
    hr_utility.set_location ('count  '||l_pay_detail_tab.count,10) ;
    if  l_pay_detail_tab.count  > 0 then


         for l_pay in 1 ..  l_pay_detail_tab.count
         Loop
        hr_utility.set_location ('dated_table_id  '||l_pay_detail_tab(l_pay).dated_table_id,10) ;
        hr_utility.set_location ('column_name  '||l_pay_detail_tab(l_pay).column_name,10) ;
        hr_utility.set_location ('effective_date  '||l_pay_detail_tab(l_pay).effective_date,10) ;
        hr_utility.set_location ('change_mode   '||l_pay_detail_tab(l_pay).change_mode,10) ;

            if   l_pay_detail_tab(l_pay).dated_table_id= p_dated_table_id
              and l_pay_detail_tab(l_pay).column_name   = p_column_name
              and l_pay_detail_tab(l_pay).effective_date= p_eff_date
              and l_pay_detail_tab(l_pay).change_mode   = p_change_type then
                    l_pdi_success := 'Y' ;
                    exit ;
             end if ;
         End Loop ;
   end if ;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
Return l_pdi_success ;

end ;

end ben_EXT_CHG_EVT_api;

/
