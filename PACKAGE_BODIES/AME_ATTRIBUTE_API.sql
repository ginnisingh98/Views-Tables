--------------------------------------------------------
--  DDL for Package Body AME_ATTRIBUTE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATTRIBUTE_API" as
/* $Header: amatrapi.pkb 120.1.12010000.3 2019/09/11 13:22:23 jaakhtar ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ame_attribute_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_attribute >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_attribute
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_attribute_type                in     varchar2
  ,p_item_class_id                 in     number
  ,p_approver_type_id              in     number   default null
  ,p_application_id                in     number   default null
  ,p_is_static                     in     varchar2 default ame_util.booleanTrue
  ,p_query_string                  in     varchar2 default null
  ,p_user_editable                 in     varchar2 default ame_util.booleanTrue
  ,p_value_set_id                  in     number   default null
  ,p_attribute_id                     out nocopy   number
  ,p_atr_object_version_number        out nocopy   number
  ,p_atr_start_date                   out nocopy   date
  ,p_atr_end_date                     out nocopy   date
  ,p_atu_object_version_number        out nocopy   number
  ,p_atu_start_date                   out nocopy   date
  ,p_atu_end_date                     out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                         varchar2(72) := g_package||'create_ame_attribute';
  l_attribute_id                 number;
  l_atr_object_version_number    number;
  l_atu_object_version_number    number;
  l_atr_start_date               date;
  l_atu_start_date               date;
  l_atr_end_date                 date;
  l_atu_end_date                 date;
  l_swi_call                     boolean;
  l_swi_package_name             varchar2(30) := 'AME_ATTRIBUTE_SWI';
  l_effective_date               date;
  l_use_count                    number := 0;
  l_name                         ame_attributes.name%type;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_name := upper(p_name);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_attribute;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_attribute_bk1.create_ame_attribute_b
                 (p_name                      => l_name
                 ,p_description               => p_description
                 ,p_attribute_type            => p_attribute_type
                 ,p_item_class_id             => p_item_class_id
                 ,p_approver_type_id          => p_approver_type_id
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_attribute'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_swi_call := true;

  ame_atr_ins.ins(p_effective_date        => l_effective_date
                 ,p_name                  => l_name
                 ,p_attribute_type        => p_attribute_type
                 ,p_description           => p_description
                 ,p_item_class_id         => p_item_class_id
                 ,p_approver_type_id      => p_approver_type_id
                 ,p_attribute_id          => l_attribute_id
                 ,p_object_version_number => l_atr_object_version_number
                 ,p_start_date            => l_atr_start_date
                 ,p_end_date              => l_atr_end_date
                 );
  -- insert data into TL tables
  ame_atl_ins.ins_tl(p_language_code      => p_language_code
                    ,p_attribute_id       => l_attribute_id
                    ,p_description        => p_description
                    );
  -- Call DBMS_UTILITY.FORMAT_CALL_STACK to check if the call has been made from the 'AME_ATTRIBUTE_SWI' package.
  --if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then --Bug #30281732
  if (instr(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then --Bug #30281732
    l_swi_call := false;
    create_ame_attribute_usage
       (p_validate                      => p_validate
       ,p_attribute_id                  => l_attribute_id
       ,p_application_id                => p_application_id
       ,p_is_static                     => p_is_static
       ,p_query_string                  => p_query_string
       ,p_user_editable                 => p_user_editable
       ,p_value_set_id                  => p_value_set_id
       ,p_object_version_number         => l_atu_object_version_number
       ,p_start_date                    => l_atu_start_date
       ,p_end_date                      => l_atu_end_date
     );
   end if;
  --
  -- Call After Process User Hook
  --
  begin
    ame_attribute_bk1.create_ame_attribute_a
                 (p_name                      => l_name
                 ,p_description               => p_description
                 ,p_attribute_type            => p_attribute_type
                 ,p_item_class_id             => p_item_class_id
                 ,p_approver_type_id          => p_approver_type_id
                 ,p_attribute_id              => l_attribute_id
                 ,p_atr_object_version_number => l_atr_object_version_number
                 ,p_atr_start_date            => l_atr_start_date
                 ,p_atr_end_date              => l_atr_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_attribute'
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
  p_attribute_id                   := l_attribute_id;
  p_atr_object_version_number      := l_atr_object_version_number;
  p_atr_start_date                 := l_atr_start_date;
  p_atr_end_date                   := l_atr_end_date;
  if not l_swi_call then
    p_atu_object_version_number    := l_atu_object_version_number;
    p_atu_start_date               := l_atu_start_date;
    p_atu_end_date                 := l_atu_end_date;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ame_attribute;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_attribute_id                   := null;
    p_atr_object_version_number      := null;
    p_atr_start_date                 := null;
    p_atr_end_date                   := null;
    if not l_swi_call then
      p_atu_object_version_number    := null;
      p_atu_start_date               := null;
      p_atu_end_date                 := null;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ame_attribute;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_attribute_id               := null;
    p_atr_object_version_number  := null;
    p_atr_start_date             := null;
    p_atr_end_date               := null;
    if not l_swi_call then
      p_atu_object_version_number:= null;
      p_atu_start_date           := null;
      p_atu_end_date             := null;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ame_attribute;
--
-- ----------------------------------------------------------------------------
-- |------------------< create_ame_attribute_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_attribute_usage
  (p_validate                      in     boolean  default false
  ,p_attribute_id                  in     number
  ,p_application_id                in     number
  ,p_is_static                     in     varchar2 default ame_util.booleanTrue
  ,p_query_string                  in     varchar2 default null
  ,p_user_editable                 in     varchar2 default ame_util.booleanTrue
  ,p_value_set_id                  in     number   default null
  ,p_object_version_number            out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ) is

  --
  -- Declare cursors and local variables
  --
  l_proc                         varchar2(72) := g_package||'create_ame_attribute_usage';
  l_atr_object_version_number    number;
  l_attribute_id                 number;
  l_application_id               number;
  l_atu_object_version_number    number;
  l_atu_start_date               date;
  l_atu_end_date                 date;
  l_effective_date               date;
  l_use_count                    number := 0;
  l_validation_start_date        date;
  l_validation_end_date          date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_attribute_usage;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_attribute_bk2.create_ame_attribute_usage_b
                 (p_attribute_id              => p_attribute_id
                 ,p_application_id            => p_application_id
                 ,p_is_static                 => p_is_static
                 ,p_query_string              => p_query_string
                 ,p_user_editable             => p_user_editable
                 ,p_value_set_id              => p_value_set_id
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_attribute_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  -- insert the row in ame_attribute_usages
  ame_atu_ins.ins(p_attribute_id          => p_attribute_id
                 ,p_application_id        => p_application_id
                 ,p_effective_date        => l_effective_date
                 ,p_use_count             => l_use_count
                 ,p_is_static             => p_is_static
                 ,p_query_string          => p_query_string
                 ,p_user_editable         => p_user_editable
                 ,p_value_set_id          => p_value_set_id
                 ,p_object_version_number => l_atu_object_version_number
                 ,p_start_date            => l_atu_start_date
                 ,p_end_date              => l_atu_end_date
                 );
  --
  -- Call After Process User Hook
  --
  begin
    ame_attribute_bk2.create_ame_attribute_usage_a
                 (p_attribute_id              => p_attribute_id
                 ,p_application_id            => p_application_id
                 ,p_is_static                 => p_is_static
                 ,p_query_string              => p_query_string
                 ,p_user_editable             => p_user_editable
                 ,p_value_set_id              => p_value_set_id
                 ,p_object_version_number     => l_atu_object_version_number
                 ,p_start_date                => l_atu_start_date
                 ,p_end_date                  => l_atu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_attribute_usage'
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
  p_object_version_number    := l_atu_object_version_number;
  p_start_date               := l_atu_start_date;
  p_end_date                 := l_atu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ame_attribute_usage;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number    := null;
    p_start_date               := null;
    p_end_date                 := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ame_attribute_usage;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number    := null;
    p_start_date                       := null;
    p_end_date                 := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ame_attribute_usage;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ame_attribute >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_attribute
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_attribute_id                  in     number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_atr_object_version_number    number;
  l_atr_start_date               date;
  l_atr_end_date                 date;
  l_effective_date               date;
  l_proc                         varchar2(72) := g_package||'update_ame_attribute';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_ame_attribute;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_attribute_bk3.update_ame_attribute_b
                 (p_attribute_id              => p_attribute_id
                 ,p_description               => p_description
                 ,p_object_version_number     => p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_attribute'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_atr_object_version_number := p_object_version_number;
  if p_attribute_id is null then
    fnd_message.set_name('PER', 'AME_400473_INV_ATTRIBUTE_ID');
    fnd_message.raise_error;
  end if;
  ame_atr_upd.upd(p_effective_date         => l_effective_date
                 ,p_datetrack_mode         => 'UPDATE'
                 ,p_attribute_id           => p_attribute_id
                 ,p_object_version_number  => l_atr_object_version_number
                 ,p_description            => p_description
                 ,p_start_date             => l_atr_start_date
                 ,p_end_date               => l_atr_end_date
                 );
  -- update data into TL tables
  ame_atl_upd.upd_tl(p_language_code      => p_language_code
                    ,p_attribute_id       => p_attribute_id
                    ,p_description        => p_description
                    );
  --
  -- Call After Process User Hook
  --
  begin
    ame_attribute_bk3.update_ame_attribute_a
                 (p_attribute_id              => p_attribute_id
                 ,p_description               => p_description
                 ,p_object_version_number     => l_atr_object_version_number
                 ,p_start_date                => l_atr_start_date
                 ,p_end_date                  => l_atr_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_attribute'
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
  p_object_version_number := l_atr_object_version_number;
  p_start_date            := l_atr_start_date;
  p_end_date              := l_atr_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_ame_attribute;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_start_date  := null;
    p_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_ame_attribute;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_start_date  := null;
    p_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_ame_attribute;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_ame_attribute_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_attribute_usage
  (p_validate                      in     boolean  default false
  ,p_attribute_id                  in     number
  ,p_application_id                in     number
  ,p_is_static                     in     varchar2 default ame_util.booleanTrue
  ,p_query_string                  in     varchar2 default null
  ,p_value_set_id                  in     number default null
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_atu_object_version_number    number;
  l_atu_start_date               date;
  l_atu_end_date                 date;
  l_effective_date               date;
  l_proc                         varchar2(72) := g_package||'update_ame_attribute_usage';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_ame_attribute_usage;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_attribute_bk4.update_ame_attribute_usage_b
                 (p_attribute_id              => p_attribute_id
                 ,p_application_id            => p_application_id
                 ,p_is_static                 => p_is_static
                 ,p_query_string              => p_query_string
                 ,p_value_set_id              => p_value_set_id
                 ,p_object_version_number     => p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_attribute_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_atu_object_version_number := p_object_version_number;
  -- update the row in ame_attribute_usages. Parent row locking not needed.
  ame_atu_upd.upd(p_effective_date       => l_effective_date
                 ,p_datetrack_mode       => 'UPDATE'
                 ,p_attribute_id         => p_attribute_id
                 ,p_application_id       => p_application_id
                 ,p_object_version_number=> l_atu_object_version_number
                 ,p_query_string         => p_query_string
                 ,p_is_static            => p_is_static
                 ,p_value_set_id         => p_value_set_id
                 ,p_start_date           => l_atu_start_date
                 ,p_end_date             => l_atu_end_date
                 );
  --
  -- Call After Process User Hook
  --
  begin
    ame_attribute_bk4.update_ame_attribute_usage_a
                 (p_attribute_id              => p_attribute_id
                 ,p_application_id            => p_application_id
                 ,p_is_static                 => p_is_static
                 ,p_query_string              => p_query_string
                 ,p_value_set_id              => p_value_set_id
                 ,p_object_version_number     => l_atu_object_version_number
                 ,p_start_date                => l_atu_start_date
                 ,p_end_date                  => l_atu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_attribute_usage'
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
  p_object_version_number      := l_atu_object_version_number;
  p_start_date                 := l_atu_start_date;
  p_end_date                   := l_atu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_ame_attribute_usage;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_start_date   := null;
    p_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_ame_attribute_usage;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_start_date   := null;
    p_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_ame_attribute_usage;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_ame_attribute_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_attribute_usage
  (p_validate                      in     boolean  default false
  ,p_attribute_id                  in     number
  ,p_application_id                in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                      out nocopy   date
  ,p_end_date                      out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_atr_object_version_number    number;
  l_atu_object_version_number    number;
  l_atr_start_date               date;
  l_atu_start_date               date;
  l_atr_end_date                 date;
  l_atu_end_date                 date;
  l_effective_date               date;
  l_proc                         varchar2(72) := g_package||'delete_ame_attribute_usage';
  l_usage_count                  number;
  l_validation_start_date        date;
  l_validation_end_date          date;
  l_exists                       varchar2(1);
  l_con_start_date               date;
  l_con_end_date                 date;

  cursor c_sel1 is
    select condition_id, object_version_number
      from ame_conditions
     where attribute_id = p_attribute_id
       and sysdate between start_date and
             nvl(end_date - ame_util.oneSecond,sysdate);

  cursor c_sel2 is
    select null
      from ame_mandatory_attributes
     where attribute_id  =  p_attribute_id and
       sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ame_attribute_usage;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_attribute_bk5.delete_ame_attribute_usage_b
                 (p_attribute_id              => p_attribute_id
                 ,p_application_id            => p_application_id
                 ,p_object_version_number     => p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_attribute_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_atu_object_version_number := p_object_version_number;
  --
  -- delete the row in ame_attribute_usages
    ame_atu_del.del(p_effective_date       => l_effective_date
                   ,p_datetrack_mode       => 'DELETE'
                   ,p_attribute_id         => p_attribute_id
                   ,p_application_id       => p_application_id
                   ,p_object_version_number=> l_atu_object_version_number
                   ,p_start_date           => l_atu_start_date
                   ,p_end_date             => l_atu_end_date
                   );
  --
  -- Check number of usages which exist for this attribute. If the attribute is not a mandatory
   --If usages at this point are = 0 delete the attribute row too.
  --

     select count(*)
      into l_usage_count
       from ame_attribute_usages
     where attribute_id  = p_attribute_id
       and l_effective_date between start_date and
            nvl(end_date - ame_util.oneSecond,sysdate);

    if l_usage_count = 0 then
      /* if this is a REQUIRED attribute, do not delete its conditions and the attribute itself
         otherwise, delete all the conditions and the attribute itself, as no other usage exists
      */
      open c_Sel2;
      fetch c_Sel2 into l_exists;
      if c_Sel2%notfound then
        close c_sel2;
        /*Its not a required attribute, so select all the conditions to delete */
        for con_rec in c_Sel1
        loop
          ame_condition_api.delete_ame_condition
            (p_condition_id           => con_rec.condition_id
            ,p_object_version_number  => con_rec.object_version_number
            ,p_start_date             => l_con_start_date
            ,p_end_date               => l_con_end_date
            );
      end loop;

        select object_version_number
          into l_atr_object_version_number
          from ame_attributes
         where attribute_id = p_attribute_id
           and l_effective_date between start_date
           and nvl(end_date - ame_util.oneSecond,sysdate);

        ame_atr_del.del(p_effective_date       => sysdate
                       ,p_datetrack_mode       => 'DELETE'
                       ,p_attribute_id         => p_attribute_id
                       ,p_object_version_number=> l_atr_object_version_number
                       ,p_start_date           => l_atr_start_date
                       ,p_end_date             => l_atr_end_date
                       );
      else
        close c_Sel2;
      end if;
    end if;

  --
  -- Call After Process User Hook
  --
  begin
    ame_attribute_bk5.delete_ame_attribute_usage_a
                 (p_attribute_id              => p_attribute_id
                 ,p_application_id            => p_application_id
                 ,p_object_version_number     => l_atu_object_version_number
                 ,p_start_date                        => l_atu_start_date
                 ,p_end_date                  => l_atu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_attribute_usage'
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
  p_object_version_number   := l_atu_object_version_number;
  p_start_date              := l_atu_start_date;
  p_end_date                := l_atu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_ame_attribute_usage;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_start_date   := null;
    p_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_ame_attribute_usage;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_start_date   := null;
    p_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
  end delete_ame_attribute_usage;
--+
--+
--+
  function calculateUseCount(attributeIdIn   in integer,
                             applicationIdIn in integer) return integer as
    cursor ruleCursor(applicationIdIn in integer) is
      select rule_id
        from ame_rule_usages
        where
          ame_rule_usages.item_id = applicationIdIn and
          ((sysdate between ame_rule_usages.start_date and
            nvl(ame_rule_usages.end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < ame_rule_usages.start_date and
            ame_rule_usages.start_date < nvl(ame_rule_usages.end_date,
                           ame_rule_usages.start_date + ame_util.oneSecond)));
    ruleCount integer;
    tempCount integer;
    useCount integer;
    begin
      useCount := 0;
      for tempRule in ruleCursor(applicationIdIn => applicationIdIn) loop
        select count(*)
          into tempCount
          from
            ame_conditions,
            ame_condition_usages
          where
            ame_conditions.attribute_id = attributeIdIn and
            ame_conditions.condition_id = ame_condition_usages.condition_id and
            ame_condition_usages.rule_id = tempRule.rule_id and
            sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
            ((sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < ame_condition_usages.start_date and
            ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
                           ame_condition_usages.start_date + ame_util.oneSecond)));
        if(tempCount > 0) then
          useCount := useCount + 1;
        else
          select count(*)
            into tempCount
            from
              ame_mandatory_attributes,
              ame_actions,
              ame_action_usages
            where
              ame_mandatory_attributes.attribute_id = attributeIdIn and
              ame_mandatory_attributes.action_type_id = ame_actions.action_type_id and
              ame_actions.action_id = ame_action_usages.action_id and
              ame_action_usages.rule_id = tempRule.rule_id and
               sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate) and
               sysdate between ame_actions.start_date and
                 nvl(ame_actions.end_date - ame_util.oneSecond, sysdate) and
              ((sysdate between ame_action_usages.start_date and
                nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate)) or
                (sysdate < ame_action_usages.start_date and
                 ame_action_usages.start_date < nvl(ame_action_usages.end_date,
                           ame_action_usages.start_date + ame_util.oneSecond)));
          if(tempCount > 0) then
            useCount := useCount + 1;
          end if;
        end if;
      end loop;
      return(useCount);
      exception
        when others then
          fnd_message.set_name('PER','AME_9_INV_ATTRIBUTE_USAGE');
          hr_multi_message.add (p_associated_column1 => 'ATTRIBUTE_ID');
          raise;
          return(null);
    end calculateUseCount;
--+
--+
--+
  procedure updateUseCount(p_attribute_id              in integer
                          ,p_application_id            in integer
                          ,p_atu_object_version_number in integer) as
    useCount         integer;
    l_atu_start_date date;
    l_atu_end_date   date;
    l_atu_object_version_number integer;
    begin
      l_atu_object_version_number := p_atu_object_version_number;
      useCount := calculateUseCount(attributeIdIn   => p_attribute_id
                                   ,applicationIdIn => p_application_id);
      ame_atu_upd.upd(p_attribute_id          => p_attribute_id
                     ,p_datetrack_mode        => hr_api.g_correction
                     ,p_application_id        => p_application_id
                     ,p_use_count             => useCount
                     ,p_effective_date        => sysdate
                     ,p_object_version_number => l_atu_object_version_number
                     ,p_start_date            => l_atu_start_date
                     ,p_end_date              => l_atu_end_date
                     );
    end updateUseCount;
--+
end ame_attribute_api;

/
