--------------------------------------------------------
--  DDL for Package Body PAY_EVENT_QUALIFIERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVENT_QUALIFIERS_API" as
/* $Header: pyevqapi.pkb 120.0 2005/05/29 04:49:16 appldev noship $ */
--
-- Package Variables
--

g_package  varchar2(33) := '  pay_event_qualifiers_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_event_qualifier> >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_event_qualifier
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_dated_table_id                in     number
  ,p_column_name                   in     varchar2
  ,p_qualifier_name                in     varchar2
  ,p_legislation_code              in     varchar2 default null
  ,p_business_group_id             in     number   default null
  ,p_comparison_column             in     varchar2 default null
  ,p_qualifier_definition          in     varchar2 default null
  ,p_qualifier_where_clause        in     varchar2 default null
  ,p_entry_qualification           in     varchar2 default null
  ,p_assignment_qualification      in     varchar2 default null
  ,p_multi_event_sql               in     varchar2 default null
  ,p_event_qualifier_id               out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_event_qualifier';
  l_effective_date      date;
  l_current             number;
  --
  -- Declare OUT variables
  --
  l_event_qualifier_id      pay_event_qualifiers_f.event_qualifier_id%TYPE;
  l_object_version_number   pay_event_qualifiers_f.object_version_number%TYPE;
  l_effective_start_date    pay_event_qualifiers_f.effective_start_date%TYPE;
  l_effective_end_date      pay_event_qualifiers_f.effective_end_date%TYPE;

  cursor csr_valid_name is
  select  event_qualifier_id
        , effective_start_date
        , effective_end_date
        , object_version_number
  from    pay_event_qualifiers_f
  where   dated_table_id = p_dated_table_id
  and     column_name    = p_column_name
  and     qualifier_name = p_qualifier_name;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_event_qualifier;
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
    hr_utility.set_location(l_proc, 20);


  --------------------------------------------------------
  -- Check for unique qualifier name,table_id,column_name
  --------------------------------------------------------
     open csr_valid_name;
     fetch csr_valid_name
     into l_event_qualifier_id
        , l_effective_start_date
        , l_effective_end_date
        , l_object_version_number;

IF csr_valid_name%notfound then
  -- The Qualifier we are trying to create does not yet exist
  -- so create now.

  --------------------------------------------------------
  -- NB. At this point only one qualifier IN USE on a datetracked event
  -- is supported, but we'll allow creation of the qual, but raise
  -- an error in the evc api if insert is performed via UI
  --------------------------------------------------------

  --
  -- Call Before Process User Hook
  --
  begin
    pay_event_qualifiers_bk1.create_event_qualifier_b
      (p_effective_date             =>  l_effective_date
      ,p_dated_table_id             =>  p_dated_table_id
      ,p_column_name                =>  p_column_name
      ,p_qualifier_name             =>  p_qualifier_name
      ,p_legislation_code           =>  p_legislation_code
      ,p_business_group_id          =>  p_business_group_id
      ,p_comparison_column          =>  p_comparison_column
      ,p_qualifier_definition       =>  p_qualifier_definition
      ,p_qualifier_where_clause     =>  p_qualifier_where_clause
      ,p_entry_qualification        =>  p_entry_qualification
      ,p_assignment_qualification   =>  p_assignment_qualification
      ,p_multi_event_sql            =>  p_multi_event_sql
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_event_qualifier'
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
  --
  -- Call the row handler
  --
    pay_evq_ins.ins
      (p_effective_date             =>  l_effective_date
      ,p_dated_table_id             =>  p_dated_table_id
      ,p_column_name                =>  p_column_name
      ,p_qualifier_name             =>  p_qualifier_name
      ,p_legislation_code           =>  p_legislation_code
      ,p_business_group_id          =>  p_business_group_id
      ,p_comparison_column          =>  p_comparison_column
      ,p_qualifier_definition       =>  p_qualifier_definition
      ,p_qualifier_where_clause     =>  p_qualifier_where_clause
      ,p_entry_qualification        =>  p_entry_qualification
      ,p_assignment_qualification   =>  p_assignment_qualification
      ,p_multi_event_sql            =>  p_multi_event_sql
      ,p_event_qualifier_id         =>  l_event_qualifier_id
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
    pay_event_qualifiers_bk1.create_event_qualifier_a
      (p_effective_date             =>  l_effective_date
      ,p_dated_table_id             =>  p_dated_table_id
      ,p_column_name                =>  p_column_name
      ,p_qualifier_name             =>  p_qualifier_name
      ,p_legislation_code           =>  p_legislation_code
      ,p_business_group_id          =>  p_business_group_id
      ,p_comparison_column          =>  p_comparison_column
      ,p_qualifier_definition       =>  p_qualifier_definition
      ,p_qualifier_where_clause     =>  p_qualifier_where_clause
      ,p_entry_qualification        =>  p_entry_qualification
      ,p_assignment_qualification   =>  p_assignment_qualification
      ,p_multi_event_sql            =>  p_multi_event_sql
      ,p_event_qualifier_id         =>  l_event_qualifier_id
      ,p_object_version_number      =>  l_object_version_number
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_event_qualifier'
        ,p_hook_type   => 'AP'
        );
  end;

END IF; -- Only done insert and hooks if %notfound
     close csr_valid_name;
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
  p_event_qualifier_id     := l_event_qualifier_id;
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
    rollback to create_event_qualifier;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_event_qualifier_id     := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_event_qualifier;
    p_event_qualifier_id     := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_event_qualifier;
--

--
-- ----------------------------------------------------------------------------
-- |----------------------< update_event_qualifier >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_event_qualifier
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_event_qualifier_id           in     number
  ,p_dated_table_id               in     number
  ,p_column_name                  in     varchar2
  ,p_qualifier_name               in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_comparison_column            in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_definition         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_where_clause       in     varchar2  default hr_api.g_varchar2
  ,p_entry_qualification          in     varchar2  default hr_api.g_varchar2
  ,p_assignment_qualification     in     varchar2  default hr_api.g_varchar2
  ,p_multi_event_sql              in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_event_qualifier';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date     pay_event_qualifiers_f.effective_start_date%TYPE;
  l_effective_end_date       pay_event_qualifiers_f.effective_end_date%TYPE;
  --
  -- Declare IN OUT variable
  --
  l_object_version_number    pay_event_qualifiers_f.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint and assign in-out parameters to local variable
  --

  l_object_version_number := p_object_version_number;
  savepoint update_event_qualifier;
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
    pay_event_qualifiers_bk2.update_event_qualifier_b
      (p_effective_date             =>  l_effective_date
      ,p_datetrack_update_mode      =>  p_datetrack_update_mode
      ,p_event_qualifier_id         =>  p_event_qualifier_id
      ,p_dated_table_id             =>  p_dated_table_id
      ,p_column_name                =>  p_column_name
      ,p_qualifier_name             =>  p_qualifier_name
      ,p_legislation_code           =>  p_legislation_code
      ,p_business_group_id          =>  p_business_group_id
      ,p_comparison_column          =>  p_comparison_column
      ,p_qualifier_definition       =>  p_qualifier_definition
      ,p_qualifier_where_clause     =>  p_qualifier_where_clause
      ,p_entry_qualification        =>  p_entry_qualification
      ,p_assignment_qualification   =>  p_assignment_qualification
      ,p_multi_event_sql            =>  p_multi_event_sql
      ,p_object_version_number      =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_event_qualifier'
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
  pay_evq_upd.upd
    (p_effective_date             =>  l_effective_date
    ,p_datetrack_mode             =>  p_datetrack_update_mode
    ,p_event_qualifier_id         =>  p_event_qualifier_id
    ,p_object_version_number      =>  l_object_version_number
    ,p_comparison_column          =>  p_comparison_column
    ,p_qualifier_definition       =>  p_qualifier_definition
    ,p_qualifier_where_clause     =>  p_qualifier_where_clause
    ,p_entry_qualification        =>  p_entry_qualification
    ,p_assignment_qualification   =>  p_assignment_qualification
    ,p_multi_event_sql            =>  p_multi_event_sql
    ,p_effective_start_date       =>  l_effective_start_date
    ,p_effective_end_date         =>  l_effective_end_date
    );
--

    --
    hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_event_qualifiers_bk2.update_event_qualifier_a
      (p_effective_date             =>  l_effective_date
      ,p_datetrack_update_mode      =>  p_datetrack_update_mode
      ,p_event_qualifier_id         =>  p_event_qualifier_id
      ,p_dated_table_id             =>  p_dated_table_id
      ,p_column_name                =>  p_column_name
      ,p_qualifier_name             =>  p_qualifier_name
      ,p_legislation_code           =>  p_legislation_code
      ,p_business_group_id          =>  p_business_group_id
      ,p_comparison_column          =>  p_comparison_column
      ,p_qualifier_definition       =>  p_qualifier_definition
      ,p_qualifier_where_clause     =>  p_qualifier_where_clause
      ,p_entry_qualification        =>  p_entry_qualification
      ,p_assignment_qualification   =>  p_assignment_qualification
      ,p_multi_event_sql            =>  p_multi_event_sql
      ,p_object_version_number      =>  p_object_version_number
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      );
  exception
   when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_event_qualifier_a'
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
    rollback to update_event_qualifier;
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
    rollback to update_event_qualifier;
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_event_qualifier;



-- ----------------------------------------------------------------------------
-- |------------------------< delete_event_qualifier >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_event_qualifier
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_event_qualifier_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc               varchar2(72) := g_package||'delete_event_qualifier';
  l_effective_date     date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date  pay_event_qualifiers_f.effective_start_date%type;
  l_effective_end_date    pay_event_qualifiers_f.effective_end_date%type;
  l_validation_start_date date;
  l_validation_end_date   date;
  l_object_version_number pay_event_qualifiers_f.object_version_number%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint and assign in-out parameters to local variable
  --
  savepoint delete_event_qualifier;
  l_object_version_number := p_object_version_number;
  --
  hr_utility.set_location(l_proc, 10);
  --
    l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_event_qualifiers_bk3.delete_event_qualifier_b
     (p_effective_date                =>     l_effective_date
     ,p_datetrack_delete_mode         =>     p_datetrack_delete_mode
     ,p_event_qualifier_id            =>     p_event_qualifier_id
     ,p_object_version_number         =>     p_object_version_number
     ,p_business_group_id             =>     p_business_group_id
     ,p_legislation_code              =>     p_legislation_code
     );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_event_qualifier'
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
  if p_datetrack_delete_mode = hr_api.g_zap then
  --
    pay_evq_shd.lck(p_effective_date        => l_effective_date
                   ,p_datetrack_mode        => p_datetrack_delete_mode
                   ,p_event_qualifier_id    => p_event_qualifier_id
                   ,p_object_version_number => p_object_version_number
                   ,p_validation_start_date => l_validation_start_date
                   ,p_validation_end_date   => l_validation_end_date
                   );
  --
  end if; -- mode = ZAP
  --
  -- Call the row handler to delete the event_qualifier
  --
    pay_evq_del.del
      (p_effective_date               => l_effective_date
      ,p_datetrack_mode               => p_datetrack_delete_mode
      ,p_event_qualifier_id                  => p_event_qualifier_id
      ,p_object_version_number        => p_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_event_qualifiers_bk3.delete_event_qualifier_a
      (p_effective_date            => l_effective_date
      ,p_datetrack_delete_mode     => p_datetrack_delete_mode
      ,p_event_qualifier_id        => p_event_qualifier_id
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
    ROLLBACK TO delete_event_qualifier;
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
    ROLLBACK TO delete_event_qualifier;
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    raise;
  --
end delete_event_qualifier;
-- ----------------------------------------------------------------------------

end pay_event_qualifiers_api;

/
