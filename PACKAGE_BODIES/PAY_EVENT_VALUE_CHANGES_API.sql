--------------------------------------------------------
--  DDL for Package Body PAY_EVENT_VALUE_CHANGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVENT_VALUE_CHANGES_API" as
/* $Header: pyevcapi.pkb 120.0 2005/05/29 04:46:18 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_event_value_changes_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_event_value_change> >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_event_value_change
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_event_qualifier_id             in     number
  ,p_default_event                  in     varchar2
  ,p_valid_event                    in     varchar2
  ,p_datetracked_event_id           in     number   default null
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_from_value                     in     varchar2 default null
  ,p_to_value                       in     varchar2 default null
  ,p_proration_style                in     varchar2 default null
  ,p_qualifier_value                in     varchar2 default null
  ,p_event_value_change_id             out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_event_value_change';
  l_effective_date      date;
  l_counter             number; --misc number
  --
  -- Declare OUT variables
  --
  l_event_value_change_id   pay_event_value_changes_f.event_value_change_id%TYPE;
  l_object_version_number   pay_event_value_changes_f.object_version_number%TYPE;
  l_effective_start_date    pay_event_value_changes_f.effective_start_date%TYPE;
  l_effective_end_date      pay_event_value_changes_f.effective_end_date%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_event_value_change;
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
    hr_utility.set_location(l_proc, 20);

  --
  -- Call Before Process User Hook
  --
  begin
    pay_event_value_changes_bk1.create_event_value_change_b
      (p_effective_date           =>  l_effective_date
      ,p_event_qualifier_id       => p_event_qualifier_id
      ,p_default_event            => p_default_event
      ,p_valid_event              => p_valid_event
      ,p_datetracked_event_id     => p_datetracked_event_id
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_from_value               => p_from_value
      ,p_to_value                 => p_to_value
      ,p_proration_style          => p_proration_style
      ,p_qualifier_value          => p_qualifier_value
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_event_value_change'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --

-- If new event qualifier type, driving first row is attempted creation
-- of the evc representing the default value
if (p_default_event = 'Y') then
  --------------------------------------------------------
  -- Using more than one qualifier on a given event
  -- IS NOT SUPPORTED.  Hence we error if a default row already exists
  -- eg we are inserting a second qualifier.
  --------------------------------------------------------
    select count(*)
    into  l_counter
    from  pay_event_value_changes_f
    where p_effective_date between effective_start_date and effective_end_date
    and   p_datetracked_event_id = datetracked_event_id
    and   default_event = 'Y';

   if (l_counter <> 0) then --A qualifier type already exists
      hr_utility.set_message(801, 'HR_449144_QUA_FWK_ID_EXISTS');
      -- The vague message is: This Qualification Id already exists....
      hr_utility.raise_error;
   end if;
end if;

  hr_utility.set_location(l_proc, 40);


  --
  -- Process Logic
  --
  --
  -- Call the row handler
  --
    pay_evc_ins.ins
      (p_effective_date           =>  l_effective_date
      ,p_event_qualifier_id       => p_event_qualifier_id
      ,p_default_event            => p_default_event
      ,p_valid_event              => p_valid_event
      ,p_datetracked_event_id     => p_datetracked_event_id
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_from_value               => p_from_value
      ,p_to_value                 => p_to_value
      ,p_proration_style          => p_proration_style
      ,p_qualifier_value          => p_qualifier_value
      ,p_event_value_change_id      =>  l_event_value_change_id
      ,p_object_version_number      =>  l_object_version_number
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      );
    --
  hr_utility.set_location(l_proc, 50);

  --
  -- Call After Process User Hook
  --
  begin
    pay_event_value_changes_bk1.create_event_value_change_a
      (p_effective_date           =>  l_effective_date
      ,p_event_qualifier_id       => p_event_qualifier_id
      ,p_default_event            => p_default_event
      ,p_valid_event              => p_valid_event
      ,p_datetracked_event_id     => p_datetracked_event_id
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_from_value               => p_from_value
      ,p_to_value                 => p_to_value
      ,p_proration_style          => p_proration_style
      ,p_qualifier_value          => p_qualifier_value
      ,p_event_value_change_id      =>  l_event_value_change_id
      ,p_object_version_number      =>  l_object_version_number
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_event_value_change'
        ,p_hook_type   => 'AP'
        );
  end;

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
  p_event_value_change_id  := l_event_value_change_id;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_event_value_change;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_event_value_change_id  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_event_value_change;
    p_event_value_change_id  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_event_value_change;
--

--
-- ----------------------------------------------------------------------------
-- |----------------------< update_event_value_change >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_event_value_change
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_event_qualifier_id           in     number
  ,p_default_event                in     varchar2
  ,p_valid_event                  in     varchar2
  ,p_datetracked_event_id         in     number   default hr_api.g_number
  ,p_business_group_id            in     number   default hr_api.g_number
  ,p_legislation_code             in     varchar2 default hr_api.g_varchar2
  ,p_from_value                   in     varchar2 default hr_api.g_varchar2
  ,p_to_value                     in     varchar2 default hr_api.g_varchar2
  ,p_proration_style              in     varchar2 default hr_api.g_varchar2
  ,p_qualifier_value              in     varchar2 default hr_api.g_varchar2
  ,p_event_value_change_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_event_value_change';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date     pay_event_value_changes_f.effective_start_date%TYPE;
  l_effective_end_date       pay_event_value_changes_f.effective_end_date%TYPE;
  --
  -- Declare IN OUT variable
  --
  l_object_version_number    pay_event_value_changes_f.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint and assign in-out parameters to local variable
  --

  l_object_version_number := p_object_version_number;
  savepoint update_event_value_change;
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_event_value_changes_bk2.update_event_value_change_b
      (p_effective_date           =>  l_effective_date
      ,p_datetrack_mode           => p_datetrack_mode
      ,p_event_qualifier_id       => p_event_qualifier_id
      ,p_default_event            => p_default_event
      ,p_valid_event              => p_valid_event
      ,p_datetracked_event_id     => p_datetracked_event_id
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_from_value               => p_from_value
      ,p_to_value                 => p_to_value
      ,p_proration_style          => p_proration_style
      ,p_qualifier_value          => p_qualifier_value
      ,p_event_value_change_id    => p_event_value_change_id
      ,p_object_version_number    => l_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_event_value_change'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  -- Call the row handler
  --
  pay_evc_upd.upd
    (p_effective_date           =>  l_effective_date
    ,p_datetrack_mode           =>  p_datetrack_mode
    ,p_event_value_change_id    =>  p_event_value_change_id
    ,p_object_version_number    =>  p_object_version_number
    ,p_from_value               =>  p_from_value
    ,p_to_value                 =>  p_to_value
    ,p_valid_event              =>  p_valid_event
    ,p_proration_style          =>  p_proration_style
    ,p_qualifier_value          =>  p_qualifier_value
    ,p_effective_start_date     =>  l_effective_start_date
    ,p_effective_end_date       =>  l_effective_end_date
    );
--

    --
    hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_event_value_changes_bk2.update_event_value_change_a
      (p_effective_date           =>  l_effective_date
      ,p_datetrack_mode           => p_datetrack_mode
      ,p_event_qualifier_id       => p_event_qualifier_id
      ,p_default_event            => p_default_event
      ,p_valid_event              => p_valid_event
      ,p_datetracked_event_id     => p_datetracked_event_id
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_from_value               => p_from_value
      ,p_to_value                 => p_to_value
      ,p_proration_style          => p_proration_style
      ,p_qualifier_value          => p_qualifier_value
      ,p_event_value_change_id    => p_event_value_change_id
      ,p_object_version_number    => l_object_version_number
      ,p_effective_start_date     =>  l_effective_start_date
      ,p_effective_end_date       =>  l_effective_end_date
      );
  exception
   when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_event_value_change_a'
        ,p_hook_type   => 'AP'
        );
  end;
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
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := p_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_event_value_change;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_event_value_change;
    raise;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_event_value_change;



-- ----------------------------------------------------------------------------
-- |------------------------< delete_event_value_change >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_event_value_change
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_event_value_change_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc               varchar2(72) := g_package||'delete_event_value_change';
  l_effective_date     date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date  pay_event_value_changes_f.effective_start_date%type;
  l_effective_end_date    pay_event_value_changes_f.effective_end_date%type;
  l_validation_start_date date;
  l_validation_end_date   date;
  l_object_version_number pay_event_value_changes_f.object_version_number%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint and assign in-out parameters to local variable
  --
  savepoint delete_event_value_change;
  l_object_version_number := p_object_version_number;
  --
  hr_utility.set_location(l_proc, 10);
  --
    l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_event_value_changes_bk3.delete_event_value_change_b
     (p_effective_date              =>     l_effective_date
     ,p_datetrack_mode              =>     p_datetrack_mode
     ,p_event_value_change_id       =>     p_event_value_change_id
     ,p_object_version_number       =>     p_object_version_number
     ,p_business_group_id           =>     p_business_group_id
     ,p_legislation_code            =>     p_legislation_code
     );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_event_value_change'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
    hr_utility.set_location(l_proc, 30);
  --
  -- Lock the non-translated table row handler for ZAP datetrack delete mode
  --
  if p_datetrack_mode = hr_api.g_zap then
  --
    pay_evc_shd.lck(p_effective_date        => l_effective_date
                   ,p_datetrack_mode        => p_datetrack_mode
                   ,p_event_value_change_id => p_event_value_change_id
                   ,p_object_version_number => p_object_version_number
                   ,p_validation_start_date => l_validation_start_date
                   ,p_validation_end_date   => l_validation_end_date
                   );
  --
  end if; -- mode = ZAP
  --
  -- Call the row handler to delete the event_qualifier
  --
    pay_evc_del.del
      (p_effective_date             => l_effective_date
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_event_value_change_id      => p_event_value_change_id
      ,p_object_version_number      => p_object_version_number
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_event_value_changes_bk3.delete_event_value_change_a
      (p_effective_date            => l_effective_date
      ,p_datetrack_mode     => p_datetrack_mode
      ,p_event_value_change_id     => p_event_value_change_id
      ,p_object_version_number     => p_object_version_number
      ,p_business_group_id         => p_business_group_id
      ,p_legislation_code          => p_legislation_code
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      );
    --
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set out parameters
  --
    p_object_version_number := p_object_version_number;
    p_effective_start_date  := l_effective_start_date;
    p_effective_end_date    := l_effective_end_date;
    --
  hr_utility.set_location(l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_event_value_change;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO delete_event_value_change;
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    raise;
  --
end delete_event_value_change;
-- ----------------------------------------------------------------------------

end pay_event_value_changes_api;

/
