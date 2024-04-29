--------------------------------------------------------
--  DDL for Package Body AME_APPROVER_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APPROVER_TYPE_API" as
/* $Header: amaptapi.pkb 120.1 2006/04/21 08:43:18 avarri noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ame_approver_type_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_ame_approver_type >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_approver_type
  (p_validate                      in            boolean  default false
  ,p_orig_system                   in            varchar2
  ,p_approver_type_id              out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_start_date                    out nocopy    date
  ,p_end_date                      out nocopy    date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc             varchar2(72)   := g_package||'create_ame_approver_type';
  l_approver_type_id                number;
  l_object_version_number           number;
  l_start_date                      date;
  l_end_date                        date;
  l_swi_call                        boolean;
  l_swi_package_name varchar2(30)   := 'ame_approver_type_swi';
--
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint create_ame_approver_type;
    --
    -- Remember IN OUT parameter IN values. None here.
    --
    -- Call Before Process User Hook
  begin
    ame_approver_type_bk1.create_ame_approver_type_b
      (p_approver_type_id       => p_approver_type_id
      ,p_orig_system            => p_orig_system
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name  => 'create_ame_approver_type'
        ,p_hook_type    => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  l_swi_call := true;
  --
 ame_apt_ins.ins(p_effective_date               => sysdate
                ,p_approver_type_id             => l_approver_type_id
                ,p_orig_system                  => p_orig_system
                ,p_object_version_number        => l_object_version_number
                ,p_start_date                   => l_start_date
                ,p_end_date                     => l_end_date
                );
  --
  -- Call After Process User Hook
  --
  begin
    ame_approver_type_bk1.create_ame_approver_type_a
      (p_orig_system                   => p_orig_system
      ,p_approver_type_id              => l_approver_type_id
      ,p_object_version_number         => l_object_version_number
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_approver_type'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_approver_type_id           := l_approver_type_id;
  p_object_version_number      := l_object_version_number;
  p_start_date                 := l_start_date;
  p_end_date                   := l_end_date;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ame_approver_type;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
   p_approver_type_id           := null;
   p_object_version_number      := null;
   p_start_date                 := null;
   p_end_date                   := null;
 hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ame_approver_type;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_approver_type_id           := null;
    p_object_version_number      := null;
    p_start_date                 := null;
    p_end_date                   := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ame_approver_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_ame_approver_type >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_approver_type
  (p_validate                   in      boolean  default false
  ,p_approver_type_id           in      number
  ,p_object_version_number      in out  nocopy   number
  ,p_start_date                    out  nocopy   date
  ,p_end_date                      out  nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor attribute_cur(p_approver_type_id in number,
                           p_effective_date in date) is
    select attribute_id, object_version_number
      from ame_attributes
      where
        approver_type_id = p_approver_type_id
        and p_effective_date
        between start_date and nvl(end_date - ame_util.oneSecond, p_effective_date);
  --
  l_proc                       varchar2(72) := g_package||'delete_ame_approver_type';
  l_effective_date             date;

  l_attribute_ids          ame_util.idList;
  l_atr_object_version_number  number;
  l_atr_object_version_numbers ame_util.idList;
  l_atr_start_date             date;
  l_atr_end_date               date;
  l_apt_object_version_number  number;
  l_apt_start_date             date;
  l_apt_end_date               date;
  l_apg_object_version_number  number;
  l_apg_orig_system            varchar2(100);
  l_approver_group_ids          ame_util.idList;
  l_apu_approver_type_ids      ame_util.idList;
  l_apu_object_version_number  number;
  l_apu_object_version_numbers ame_util.idList;
  l_apu_start_date             date;
  l_apu_end_date               date;
  l_rule_types                 ame_util.idList;
  l_effective_date2            date;
  l_config_count               number;
  l_rule_usage_count           number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- Issue a savepoint.
  --
  -- Set the effective date to the sysdate
  l_effective_date            := sysdate;
  l_apt_object_version_number := p_object_version_number;
  l_atr_object_version_number := p_object_version_number;

  savepoint delete_ame_approver_type;
  --
  -- Process Logic
  -- Call DBMS_UTILITY.FORMAT_CALL_STACK to check if the call has been made
  -- from the 'AME_APPROVER_SWI' package.
  -- if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,'AME_APPROVER_SWI') = 0) then
  -- Call Before Process User Hook
  begin
    ame_approver_type_bk2.delete_ame_approver_type_b
      (p_approver_type_id        => p_approver_type_id
      ,p_object_version_number   => p_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_approver_type'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Remove approvertype
  --
  l_effective_date2 := sysdate;
  l_apt_object_version_number := p_object_version_number;
  ame_apt_del.del(p_approver_type_id      => p_approver_type_id
                 ,p_datetrack_mode        => hr_api.g_delete
                 ,p_object_version_number => l_apt_object_version_number
                 ,p_effective_date        => sysdate
                 ,p_start_date            => l_apt_start_date
                 ,p_end_date              => l_apt_end_date
                 );
  --
  -- Call After Process User Hook
  --
  begin
     ame_approver_type_bk2.delete_ame_approver_type_a
      (p_approver_type_id        => p_approver_type_id
      ,p_object_version_number   => l_apt_object_version_number
      ,p_start_date              => l_apt_start_date
      ,p_end_date                => l_apt_end_date
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error(p_module_name => 'delete_ame_approver_type'
                                          ,p_hook_type   => 'AP'
                                          );
  end;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_apt_object_version_number;
  p_start_date := l_apt_start_date;
  p_end_date := l_apt_end_date;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ame_approver_type;
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
  when others then
    --
    -- A validation or unexpected error has occurred
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO delete_ame_approver_type;
    raise;
    --
    -- End of fix.
    --
end delete_ame_approver_type;
--
end ame_approver_type_api;

/
