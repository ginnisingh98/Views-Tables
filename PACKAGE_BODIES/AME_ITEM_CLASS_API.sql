--------------------------------------------------------
--  DDL for Package Body AME_ITEM_CLASS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ITEM_CLASS_API" as
/* $Header: amitcapi.pkb 120.1 2005/12/08 21:00 santosin noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'AME_ITEM_CLASS_API.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_AME_ITEM_CLASS >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_ame_item_class
                        (p_validate                in         boolean  default false
                        ,p_language_code           in         varchar2 default
                                                                         hr_api.userenv_lang
                        ,p_name                    in         varchar2
                        ,p_user_item_class_name    in         varchar2
                        ,p_item_class_id           out nocopy number
                        ,p_object_version_number   out nocopy number
                        ,p_start_date              out nocopy date
                        ,p_end_date                out nocopy date
                        ) is
  --
  -- Declare cursors and local variables
  --
  l_item_class_id         number;
  l_proc                  varchar2(72) := g_package||'create_ame_item_class';
  l_object_version_number number;
  l_start_date            date;
  l_end_date              date;
  l_language_code         varchar2(30);
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint create_ame_item_class;
    --
    -- Remember IN OUT parameter IN values. None here.
    --
    -- Call Before Process User Hook
    --
    begin
    --(sri: change the signature to include language_code
      ame_item_class_bk1.create_ame_item_class_b
                        (p_name                    => p_name);
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'create_ame_item_class'
                              ,p_hook_type   => 'BP'
                              );
    end;
    --
    -- Validate the language provided
    --
    l_language_code := p_language_code;
    hr_api.validate_language_code(p_language_code => l_language_code);
    --
    -- Process Logic
    --
    ame_itc_ins.ins (p_effective_date           => sysdate
                    ,p_name                     => p_name
                    ,p_item_class_id            => l_item_class_id
                    ,p_object_version_number    => l_object_version_number
                    ,p_start_date               => l_start_date
                    ,p_end_date                 => l_end_date
                    );
    --
    -- Create the translation rows
    --
    ame_itl_ins.ins_tl
      (p_language_code        => l_language_code
      ,p_item_class_id        => l_item_class_id
      ,p_user_item_class_name => p_user_item_class_name
      );
    --
    -- Call After Process User Hook
    --
    begin
      ame_item_class_bk1.create_ame_item_class_a
                        (p_name                    => p_name
                        ,p_item_class_id           => l_item_class_id
                        ,p_object_version_number   => l_object_version_number
                        ,p_start_date              => l_start_date
                        ,p_end_date                => l_end_date
                        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'create_ame_item_class'
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
    p_item_class_id             := l_item_class_id;
    p_object_version_number     := l_object_version_number;
    p_start_date                := l_start_date;
    p_end_date                  := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to create_ame_item_class;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      p_item_class_id          := null;
      p_object_version_number  := null;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to create_ame_item_class;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_item_class_id          := null;
      p_object_version_number  := null;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end create_ame_item_class;
--
-- ----------------------------------------------------------------------------
-- |-----------------------<UPDATE_AME_ITEM_CLASS>----------------------------|
-- ----------------------------------------------------------------------------
procedure update_ame_item_class
        (p_validate                     in     boolean   default false
        ,p_language_code                in     varchar2  default
                                                          hr_api.userenv_lang
        ,p_item_class_id                in     number
        ,p_user_item_class_name         in     varchar2  default hr_api.g_varchar2
        ,p_object_version_number        in out nocopy number
        ,p_start_date                      out nocopy date
        ,p_end_date                        out nocopy date
        ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'update_ame_item_class';
  l_object_version_number     number;
  l_start_date                date;
  l_end_date                  date;
  l_language_code             varchar2(30);
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_ame_item_class;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
       --(sri: change the signature to include language_code
      ame_item_class_bk2.update_ame_item_class_b
              (p_item_class_id            => p_item_class_id
              ,p_user_item_class_name     => p_user_item_class_name
              ,p_object_version_number    => p_object_version_number
              );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'update_ame_item_class'
                              ,p_hook_type   => 'BP'
                              );
    end;
    --validate the language provided
    l_language_code := p_language_code;
    hr_api.validate_language_code(p_language_code => l_language_code);
    --
    -- Process Logic
    --
/*     ame_itc_upd.upd
      (p_effective_date        => sysdate
      ,p_datetrack_mode        => hr_api.g_update
      ,p_item_class_id         => p_item_class_id
      ,p_object_version_number => p_object_version_number
      ,p_name                  => hr_api.g_varchar2
      ,p_start_date            => l_start_date
      ,p_end_date              => l_end_date
      );
    --*/
    -- Create the translation rows
    --
    ame_itl_upd.upd_tl
      (p_language_code        => l_language_code
      ,p_item_class_id        => p_item_class_id
      ,p_user_item_class_name => p_user_item_class_name
      );
    --
    -- Call After Process User Hook
    --
    begin
      ame_item_class_bk2.update_ame_item_class_a
              (p_item_class_id           => p_item_class_id
              ,p_object_version_number   => p_object_version_number
              ,p_user_item_class_name    => p_user_item_class_name
              ,p_start_date              => l_start_date
              ,p_end_date                => l_end_date
              );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'update_ame_item_class'
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
    -- Set all OUT parameters with out values.
    --
    p_start_date   := l_start_date;
    p_end_date     := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to update_ame_item_class;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to update_ame_item_class;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end update_ame_item_class;
--
-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_AME_ITEM_CLASS >-----------------------------|
-- ----------------------------------------------------------------------------
procedure delete_ame_item_class
  (p_validate              in     boolean  default false
  ,p_item_class_id         in     number
  ,p_object_version_number in out nocopy number
  ,p_start_date               out nocopy date
  ,p_end_date                 out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor getItemClassUsageCur is
    select application_id,
           object_version_number
      from ame_item_class_usages
     where item_class_id = p_item_class_id
       and sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate);
  l_proc                   varchar2(72) := g_package||'delete_ame_item_class';
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  l_start_date_child       date;
  l_end_date_child         date;
  l_applicationIds         ame_util.idList;
  l_objectVersionNumbers   ame_util.idList;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint delete_ame_item_class;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_item_class_bk3.delete_ame_item_class_b
       (p_item_class_id         => p_item_class_id
       ,p_object_version_number => p_object_version_number
       );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'delete_ame_item_class'
                              ,p_hook_type   => 'BP'
                              );
    end;
    --
    -- Process Logic
    --
    -- Remove the usages for the item_class.
    --
    open getItemClassUsageCur;
    fetch getItemClassUsageCur bulk collect into l_applicationIds,
                                                 l_objectVersionNumbers;
    close getItemClassUsageCur;
    for indx in 1..l_applicationIds.count
    loop
    delete_ame_item_class_usage
      (p_validate              => p_validate
      ,p_application_id        => l_applicationIds(indx)
      ,p_item_class_id         => p_item_class_id
      ,p_object_version_number => l_objectVersionNumbers(indx)
      ,p_start_date            => l_start_date_child
      ,p_end_date              => l_end_date_child
      );
    end loop;
    --
    -- Remove the Item Class
    --
    ame_itc_del.del
        (p_effective_date          => sysdate
        ,p_datetrack_mode          => hr_api.g_delete
        ,p_item_class_id           => p_item_class_id
        ,p_object_version_number   => p_object_version_number
        ,p_start_date              => l_start_date
        ,p_end_date                => l_end_date
        );
    --
    -- Call After Process User Hook
    --
    begin
      ame_item_class_bk3.delete_ame_item_class_a
         (p_item_class_id           => p_item_class_id
         ,p_object_version_number   => p_object_version_number
         ,p_start_date              => l_start_date
         ,p_end_date                => l_end_date
          );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'delete_ame_item_class'
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
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date  := l_start_date;
    p_end_date    := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to delete_ame_item_class;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to delete_ame_item_class;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end delete_ame_item_class;
--
-- ----------------------------------------------------------------------------
-- |-------------------< CREATE_AME_ITEM_CLASS_USAGE >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_ame_item_class_usage
                        (p_validate                in     boolean  default false
                        ,p_item_id_query           in     varchar2
                        ,p_item_class_order_number in     number
                        ,p_item_class_par_mode     in     varchar2
                        ,p_item_class_sublist_mode in     varchar2
                        ,p_application_id          in out nocopy number
                        ,p_item_class_id           in out nocopy number
                        ,p_object_version_number      out nocopy number
                        ,p_start_date                 out nocopy date
                        ,p_end_date                   out nocopy date
                         ) is
  -- Declare cursors and local variables
  --
  l_application_id        number;
  l_item_class_id         number;
  l_proc                  varchar2(72) := g_package||'create_ame_item_class_usage';
  l_object_version_number number;
  l_start_date            date;
  l_end_date              date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    l_application_id := p_application_id;
    l_item_class_id := p_item_class_id;
    --
    -- Issue a savepoint
    --
    savepoint create_ame_item_class_usage;
    --
    -- Remember IN OUT parameter IN values. None here.
    --
    -- Call Before Process User Hook
    --
    begin
      ame_item_class_bk4.create_ame_item_class_usage_b
                        (p_item_id_query            => p_item_id_query
                        ,p_item_class_order_number  => p_item_class_order_number
                        ,p_item_class_par_mode      => p_item_class_par_mode
                        ,p_item_class_sublist_mode  => p_item_class_sublist_mode
                        ,p_application_id           => p_application_id
                        ,p_item_class_id            => p_item_class_id
                        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'create_ame_item_class_usage'
                              ,p_hook_type   => 'BP'
                              );
    end;
    --
    -- Process Logic
    --
    ame_itu_ins.ins
          (p_effective_date           => sysdate
          ,p_item_id_query            => p_item_id_query
          ,p_item_class_order_number  => p_item_class_order_number
          ,p_item_class_par_mode      => p_item_class_par_mode
          ,p_item_class_sublist_mode  => p_item_class_sublist_mode
          ,p_application_id           => l_application_id
          ,p_item_class_id            => l_item_class_id
          ,p_object_version_number    => l_object_version_number
          ,p_start_date               => l_start_date
          ,p_end_date                 => l_end_date
          );
    --
    -- Call After Process User Hook
    --
    begin
      ame_item_class_bk4.create_ame_item_class_usage_a
                    (p_item_id_query            => p_item_id_query
                    ,p_item_class_order_number  => p_item_class_order_number
                    ,p_item_class_par_mode      => p_item_class_par_mode
                    ,p_item_class_sublist_mode  => p_item_class_sublist_mode
                    ,p_application_id           => l_application_id
                    ,p_item_class_id            => l_item_class_id
                    ,p_object_version_number    => l_object_version_number
                    ,p_start_date               => l_start_date
                    ,p_end_date                 => l_end_date
                    );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'create_ame_item_class_usage'
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
    p_application_id            := l_application_id;
    p_item_class_id             := l_item_class_id;
    p_object_version_number     := l_object_version_number;
    p_start_date                := l_start_date;
    p_end_date                  := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to create_ame_item_class_usage;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      p_application_id         := null;
      p_item_class_id          := null;
      p_object_version_number  := null;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to create_ame_item_class_usage;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_application_id         := null;
      p_item_class_id          := null;
      p_object_version_number  := null;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end create_ame_item_class_usage;
--
-- ----------------------------------------------------------------------------
-- |---------------------<UPDATE_AME_ITEM_CLASS_USAGE>------------------------|
-- ----------------------------------------------------------------------------
procedure update_ame_item_class_usage
        (p_validate                     in     boolean   default false
        ,p_application_id               in     number
        ,p_item_class_id                in     number
        ,p_item_id_query                in     varchar2  default hr_api.g_varchar2
        ,p_item_class_order_number      in     number    default hr_api.g_number
        ,p_item_class_par_mode          in     varchar2  default hr_api.g_varchar2
        ,p_item_class_sublist_mode      in     varchar2  default hr_api.g_varchar2
        ,p_object_version_number        in out nocopy number
        ,p_start_date                   out nocopy date
        ,p_end_date                     out nocopy date
        ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'update_ame_item_class_usage';
  l_object_version_number     number;
  l_start_date                date;
  l_end_date                  date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_ame_item_class_usage;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_item_class_bk5.update_ame_item_class_usage_b
                (p_application_id          => p_application_id
                ,p_item_class_id           => p_item_class_id
                ,p_object_version_number   => p_object_version_number
                ,p_item_id_query           => p_item_id_query
                ,p_item_class_order_number => p_item_class_order_number
                ,p_item_class_par_mode     => p_item_class_par_mode
                ,p_item_class_sublist_mode => p_item_class_sublist_mode
                );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'update_ame_item_class_usage'
                              ,p_hook_type   => 'BP'
                              );
    end;
    --
    -- Process Logic
    --
    ame_itu_upd.upd
      (p_effective_date           => sysdate
      ,p_datetrack_mode           => hr_api.g_update
      ,p_application_id           => p_application_id
      ,p_item_class_id            => p_item_class_id
      ,p_object_version_number    => p_object_version_number
      ,p_item_id_query            => p_item_id_query
      ,p_item_class_order_number  => p_item_class_order_number
      ,p_item_class_par_mode      => p_item_class_par_mode
      ,p_item_class_sublist_mode  => p_item_class_sublist_mode
      ,p_start_date               => l_start_date
      ,p_end_date                 => l_end_date
      );
    --
    -- Call After Process User Hook
    --
    begin
      ame_item_class_bk5.update_ame_item_class_usage_a
                (p_application_id            => p_application_id
                ,p_item_class_id             => p_item_class_id
                ,p_object_version_number     => p_object_version_number
                ,p_item_id_query             => p_item_id_query
                ,p_item_class_order_number   => p_item_class_order_number
                ,p_item_class_par_mode       => p_item_class_par_mode
                ,p_item_class_sublist_mode   => p_item_class_sublist_mode
                ,p_start_date                => l_start_date
                ,p_end_date                  => l_end_date
                );

    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'update_ame_item_class_usage'
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
    -- Set all OUT parameters with out values.
    --
    p_start_date   := l_start_date;
    p_end_date     := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to update_ame_item_class_usage;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to update_ame_item_class_usage;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end update_ame_item_class_usage;
--
-- ----------------------------------------------------------------------------
-- |-------------------< DELETE_AME_ITEM_CLASS_USAGE >------------------------|
-- ----------------------------------------------------------------------------
procedure delete_ame_item_class_usage
                          (p_validate              in boolean  default false
                          ,p_application_id        in number
                          ,p_item_class_id         in number
                          ,p_object_version_number in out nocopy number
                          ,p_start_date               out nocopy date
                          ,p_end_date                 out nocopy date
                          ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'delete_ame_item_class_usage';
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint delete_ame_item_class_usage;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_item_class_bk6.delete_ame_item_class_usage_b
              (p_application_id         => p_application_id
              ,p_item_class_id          => p_item_class_id
              ,p_object_version_number  => p_object_version_number
              );

    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'delete_ame_item_class_usage'
                              ,p_hook_type   => 'BP'
                              );
    end;
    --
    -- Process Logic
    --
    ame_itu_del.del
        (p_effective_date        => sysdate
        ,p_datetrack_mode        => hr_api.g_delete
        ,p_application_id        => p_application_id
        ,p_item_class_id         => p_item_class_id
        ,p_object_version_number => p_object_version_number
        ,p_start_date            => l_start_date
        ,p_end_date              => l_end_date
        );
    --
    -- Call After Process User Hook
    --
    begin
      ame_item_class_bk6.delete_ame_item_class_usage_a
        (p_application_id         => p_application_id
        ,p_item_class_id          => p_item_class_id
        ,p_object_version_number  => p_object_version_number
        ,p_start_date             => l_start_date
        ,p_end_date               => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'delete_ame_item_class_usage'
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
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date  := l_start_date;
    p_end_date    := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to delete_ame_item_class_usage;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to delete_ame_item_class_usage;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end delete_ame_item_class_usage;
--
end AME_ITEM_CLASS_API;

/
