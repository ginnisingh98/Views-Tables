--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_FEEDS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_FEEDS_API" as
/* $Header: pypbfapi.pkb 115.3 2004/02/26 04:29:54 tvankayl noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_BALANCE_FEEDS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_balance_feed >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_feed
  (p_validate                      in     boolean	default false
  ,p_effective_date                in     date
  ,p_balance_type_id		   in     number
  ,p_input_value_id		   in     number
  ,p_scale			   in     varchar2
  ,p_business_group_id             in     number	default null
  ,p_legislation_code		   in     varchar2	default null
  ,p_legislation_subgroup	   in     varchar2	default null
  ,p_initial_feed		   in     boolean	default false
  ,p_balance_feed_id                  out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number            out nocopy number
  ,p_exist_run_result_warning         out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'create_balance_feed';
  l_effective_date	 date;

  --Declare OUT variables
  l_balance_feed_id      pay_balance_feeds_f.balance_feed_id%type;
  l_effective_start_date pay_balance_feeds_f.effective_start_date%type;
  l_effective_end_date   pay_balance_feeds_f.effective_end_date%type;
  l_object_version_number pay_balance_feeds_f.object_version_number%type;
  l_exist_run_result_warning boolean;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_balance_feed;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := trunc(p_effective_date);
  --
  -- Lookup validation added here so that there are no numeric or value
  -- errors for scale.
  --
  if p_scale is not null
  and hr_api.NOT_EXISTS_IN_HR_LOOKUPS
        (p_effective_date => p_effective_date
        ,p_lookup_type    => 'ADD_SUBTRACT'
        ,p_lookup_code    => p_scale
        ) then
    --
    fnd_message.set_name(801,'HR_52966_INVALID_LOOKUP');
    fnd_message.raise_error;
    --
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BALANCE_FEEDS_BK1.create_balance_feed_b
      (p_effective_date       => l_effective_date
      ,p_business_group_id    => p_business_group_id
      ,p_legislation_code     => p_legislation_code
      ,p_balance_type_id      => p_balance_type_id
      ,p_input_value_id	      => p_input_value_id
      ,p_scale		      => p_scale
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_balance_feed'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
	pay_pbf_ins.ins
	    (p_effective_date		=> l_effective_date
	    ,p_balance_type_id          => p_balance_type_id
	    ,p_input_value_id           => p_input_value_id
	    ,p_scale			=> p_scale
	    ,p_business_group_id	=> p_business_group_id
	    ,p_legislation_code         => p_legislation_code
	    ,p_legislation_subgroup     => p_legislation_subgroup
	    ,p_initial_feed		=> p_initial_feed
	    ,p_balance_feed_id          => l_balance_feed_id
	    ,p_object_version_number    => l_object_version_number
	    ,p_effective_start_date     => l_effective_start_date
	    ,p_effective_end_date       => l_effective_end_date
	    ,p_exist_run_result_warning => l_exist_run_result_warning
	    );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BALANCE_FEEDS_BK1.create_balance_feed_a
      (p_effective_date            => l_effective_date
      ,p_business_group_id	   => p_business_group_id
      ,p_legislation_code	   => p_legislation_code
      ,p_balance_type_id	   => p_balance_type_id
      ,p_input_value_id		   => p_input_value_id
      ,p_scale			   => p_scale
      ,p_legislation_subgroup	   => p_legislation_subgroup
      ,p_balance_feed_id           => l_balance_feed_id
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      ,p_object_version_number     => l_object_version_number
      ,p_exist_run_result_warning  => l_exist_run_result_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_balance_feed'
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
  -- Set all output arguments
  --
  p_balance_feed_id          := l_balance_feed_id;
  p_effective_start_date     := l_effective_start_date;
  p_effective_end_date       := l_effective_end_date;
  p_object_version_number    := l_object_version_number;
  p_exist_run_result_warning := l_exist_run_result_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_balance_feed;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_balance_feed_id          := null;
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_object_version_number    := null;
    p_exist_run_result_warning := l_exist_run_result_warning;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_balance_feed;

    p_balance_feed_id          := null;
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_object_version_number    := null;
    p_exist_run_result_warning := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_balance_feed;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_balance_feed >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_balance_feed
  (p_validate	                   in     boolean  default false
  ,p_effective_date		   in     date
  ,p_datetrack_update_mode	   in     varchar2
  ,p_balance_feed_id		   in     number
  ,p_scale			   in     varchar2 default hr_api.g_number
  ,p_object_version_number	   in out nocopy  number
  ,p_effective_start_date	      out nocopy  date
  ,p_effective_end_date		      out nocopy  date
  ,p_exist_run_result_warning	      out nocopy  boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  cursor csr_sel is
  select balance_type_id,input_value_id,legislation_code,
         business_group_id,legislation_subgroup
  from   pay_balance_feeds_f
  where  balance_feed_id =p_balance_feed_id
  and    p_effective_date between effective_start_date and effective_end_date;

  l_proc                 varchar2(72) := g_package||'update_balance_feed';
  l_effective_date	 date;

  --Declare OUT variables
  l_effective_start_date  pay_balance_feeds_f.effective_start_date%type;
  l_effective_end_date    pay_balance_feeds_f.effective_end_date%type;
  l_object_version_number pay_balance_feeds_f.object_version_number%type;
  l_exist_run_result_warning boolean;

  l_balance_type_id      pay_balance_feeds_f.balance_type_id%type;
  l_input_value_id       pay_balance_feeds_f.input_value_id%type;
  l_legislation_code     pay_balance_feeds_f.legislation_code%type;
  l_business_group_id    pay_balance_feeds_f.business_group_id%type;
  l_legislation_subgroup pay_balance_feeds_f.legislation_subgroup%type;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_balance_feed;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := trunc(p_effective_date);
     l_object_version_number := p_object_version_number;
  --
  -- Lookup validation added here so that there are no numeric or value
  -- errors for scale.
  --
  if nvl(p_scale, hr_api.g_number) <> hr_api.g_number
  and hr_api.NOT_EXISTS_IN_HR_LOOKUPS
        (p_effective_date => p_effective_date
        ,p_lookup_type    => 'ADD_SUBTRACT'
        ,p_lookup_code    => p_scale
        ) then
    --
    fnd_message.set_name(801,'HR_52966_INVALID_LOOKUP');
    fnd_message.raise_error;
    --
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BALANCE_FEEDS_BK2.update_balance_feed_b
      (p_effective_date		=> l_effective_date
      ,p_datetrack_update_mode	=> p_datetrack_update_mode
      ,p_balance_feed_id	=> p_balance_feed_id
      ,p_scale			=> p_scale
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_balance_feed'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  open csr_sel;
  fetch csr_sel into l_balance_type_id, l_input_value_id, l_legislation_code,
                     l_business_group_id, l_legislation_subgroup;
  if(csr_sel%notfound) then
     close csr_sel;
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.raise_error;
  else
     close csr_sel;
  end if;
  --
  --
  -- Process Logic
	pay_pbf_upd.upd
	    (p_effective_date		=> l_effective_date
	    ,p_datetrack_mode		=> p_datetrack_update_mode
	    ,p_balance_feed_id          => p_balance_feed_id
	    ,p_object_version_number    => l_object_version_number
	    ,p_balance_type_id          => l_balance_type_id
	    ,p_input_value_id           => l_input_value_id
	    ,p_scale                    => p_scale
	    ,p_business_group_id        => l_business_group_id
	    ,p_legislation_code         => l_legislation_code
	    ,p_legislation_subgroup     => l_legislation_subgroup
	    ,p_effective_start_date     => l_effective_start_date
	    ,p_effective_end_date       => l_effective_end_date
	    ,p_exist_run_result_warning => l_exist_run_result_warning
	    );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BALANCE_FEEDS_BK2.update_balance_feed_a
      (p_effective_date		  => l_effective_date
      ,p_datetrack_update_mode	  => p_datetrack_update_mode
      ,p_balance_feed_id	  => p_balance_feed_id
      ,p_scale			  => p_scale
      ,p_effective_start_date	  => l_effective_start_date
      ,p_effective_end_date	  => l_effective_end_date
      ,p_object_version_number	  => l_object_version_number
      ,p_exist_run_result_warning => l_exist_run_result_warning
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_balance_feed'
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
  -- Set all output arguments
  --
  p_effective_start_date     := l_effective_start_date;
  p_effective_end_date       := l_effective_end_date;
  p_object_version_number    := l_object_version_number;
  p_exist_run_result_warning := l_exist_run_result_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_balance_feed;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_object_version_number    := l_object_version_number;
    p_exist_run_result_warning := l_exist_run_result_warning;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_balance_feed;

    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_object_version_number    := l_object_version_number;
    p_exist_run_result_warning := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_balance_feed;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_balance_feed >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_feed
  (p_validate                        in     boolean default false
  ,p_effective_date                  in     date
  ,p_datetrack_delete_mode           in     varchar2
  ,p_balance_feed_id                 in     number
  ,p_object_version_number           in out nocopy number
  ,p_effective_start_date               out nocopy date
  ,p_effective_end_date                 out nocopy date
  ,p_exist_run_result_warning	        out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'delete_balance_feed';
  l_effective_date	 date;

  --Declare OUT variables
  l_effective_start_date pay_balance_feeds_f.effective_start_date%type;
  l_effective_end_date   pay_balance_feeds_f.effective_end_date%type;
  l_object_version_number pay_balance_feeds_f.object_version_number%type;
  l_exist_run_result_warning boolean;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_balance_feed;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := trunc(p_effective_date);
     l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BALANCE_FEEDS_BK3.delete_balance_feed_b
      (p_effective_date		=> l_effective_date
      ,p_datetrack_delete_mode  => p_datetrack_delete_mode
      ,p_balance_feed_id        => p_balance_feed_id
      ,p_object_version_number  => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_balance_feed'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
	pay_pbf_del.del
	    (p_effective_date		=> l_effective_date
	    ,p_datetrack_mode		=> p_datetrack_delete_mode
	    ,p_balance_feed_id          => p_balance_feed_id
	    ,p_object_version_number    => l_object_version_number
	    ,p_effective_start_date     => l_effective_start_date
	    ,p_effective_end_date       => l_effective_end_date
	    ,p_exist_run_result_warning => l_exist_run_result_warning
	    );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BALANCE_FEEDS_BK3.delete_balance_feed_a
      (p_effective_date		  => l_effective_date
      ,p_datetrack_delete_mode    => p_datetrack_delete_mode
      ,p_balance_feed_id          => p_balance_feed_id
      ,p_object_version_number    => l_object_version_number
      ,p_effective_start_date     => l_effective_start_date
      ,p_effective_end_date       => l_effective_end_date
      ,p_exist_run_result_warning => l_exist_run_result_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_balance_feed'
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
  -- Set all output arguments
  --
  p_effective_start_date     := l_effective_start_date;
  p_effective_end_date       := l_effective_end_date;
  p_object_version_number    := l_object_version_number;
  p_exist_run_result_warning := l_exist_run_result_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_balance_feed;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_object_version_number    := l_object_version_number;
    p_exist_run_result_warning := l_exist_run_result_warning;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_balance_feed;

    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_object_version_number    := l_object_version_number;
    p_exist_run_result_warning := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_balance_feed;
--
end PAY_BALANCE_FEEDS_API;

/
