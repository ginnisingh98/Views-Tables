--------------------------------------------------------
--  DDL for Package Body PAY_WCI_RATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_WCI_RATES_API" as
/* $Header: pypwrapi.pkb 115.2 2002/12/05 15:26:16 swinton noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'pay_wci_rates_api';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_wci_rate>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_wci_rate
  (p_validate                      in     boolean  default false
  ,p_account_id                    in     number
  ,p_code                          in     varchar2
  ,p_rate                          in     number   default null
  ,p_description                   in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_rate_id                       out    nocopy number
  ,p_object_version_number         out    nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_wci_rate';
  l_business_group_id     number;
  --
  cursor csr_business_group_id is
    select business_group_id
    from pay_wci_accounts
    where account_id = p_account_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Derive necessary parameters
  --
  open csr_business_group_id;
  fetch csr_business_group_id into l_business_group_id;
  close csr_business_group_id;
  --
  -- Issue a savepoint
  --
  savepoint create_wci_rate;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    pay_wci_rates_bk1.create_wci_rate_b
      (p_business_group_id             => l_business_group_id
      ,p_account_id                    => p_account_id
      ,p_code                          => p_code
      ,p_rate                          => p_rate
      ,p_description                   => p_description
      ,p_comments                      => p_comments
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_wci_rate'
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
  pay_pwr_ins.ins
     (p_rate_id                     => p_rate_id
     ,p_business_group_id           => l_business_group_id
     ,p_account_id                  => p_account_id
     ,p_code                        => p_code
     ,p_rate                        => p_rate
     ,p_description                 => p_description
     ,p_comments                    => p_comments
     ,p_object_version_number       => p_object_version_number
    );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_wci_rates_bk1.create_wci_rate_a
      (p_business_group_id             => l_business_group_id
      ,p_account_id                    => p_account_id
      ,p_code                          => p_code
      ,p_rate                          => p_rate
      ,p_description                   => p_description
      ,p_comments                      => p_comments
      ,p_rate_id                       => p_rate_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_wci_rate'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception

  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_wci_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rate_id                := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_wci_rate;
    --
    -- Bugfix 2692195
    -- Reset all OUT/IN OUT parameters
    --
    p_rate_id := null;
    p_object_version_number := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_wci_rate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_wci_rate >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_wci_rate
  (p_validate                      in     boolean  default false
  ,p_rate_id                       in     number
  ,p_object_version_number         in out nocopy number
  ,p_code                          in     varchar2 default hr_api.g_varchar2
  ,p_rate                          in     number   default hr_api.g_number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_wci_rate';
  l_business_group_id     number;
  l_account_id            number;
  l_object_version_number number;
  --
  cursor csr_record_details is
    select business_group_id, account_id
    from pay_wci_rates
    where rate_id = p_rate_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Store in out parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint
  --
  savepoint update_wci_rate;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Derive necessary parameters
  --
  open csr_record_details;
  fetch csr_record_details into l_business_group_id, l_account_id;
  close csr_record_details;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_wci_rates_bk2.update_wci_rate_b
      (p_rate_id                       => p_rate_id
      ,p_object_version_number         => l_object_version_number
      ,p_business_group_id             => l_business_group_id
      ,p_account_id                    => l_account_id
      ,p_code                          => p_code
      ,p_rate                          => p_rate
      ,p_description                   => p_description
      ,p_comments                      => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_wci_rate'
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
  pay_pwr_upd.upd
     (p_rate_id                      => p_rate_id
     ,p_object_version_number        => l_object_version_number
     ,p_code                         => p_code
     ,p_rate                         => p_rate
     ,p_description                  => p_description
     ,p_comments                     => p_comments
    );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_wci_rates_bk2.update_wci_rate_a
      (p_rate_id                       => p_rate_id
      ,p_object_version_number         => l_object_version_number
      ,p_business_group_id             => l_business_group_id
      ,p_account_id                    => l_account_id
      ,p_code                          => p_code
      ,p_rate                          => p_rate
      ,p_description                   => p_description
      ,p_comments                      => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_wci_rate'
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception

  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_wci_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_wci_rate;
    --
    -- Bugfix 2692195
    -- Reset all OUT/IN OUT parameters
    --
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_wci_rate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_wci_rate >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_wci_rate
  (p_validate                      in     boolean  default false
  ,p_object_version_number         in     number
  ,p_rate_id                       in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'delete_wci_rate';
  l_business_group_id     number;
  --
  cursor csr_business_group_id is
    select business_group_id
    from pay_wci_rates
    where rate_id = p_rate_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_wci_rate;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Derive necessary parameters
  --
  open csr_business_group_id;
  fetch csr_business_group_id into l_business_group_id;
  close csr_business_group_id;

  --
  -- Call Before Process User Hook
  --
  begin
    pay_wci_rates_bk3.delete_wci_rate_b
      (p_rate_id                       => p_rate_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => l_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_wci_rate'
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
  pay_pwr_del.del
     (p_rate_id                      => p_rate_id
     ,p_object_version_number        => p_object_version_number
    );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_wci_rates_bk3.delete_wci_rate_a
      (p_rate_id                       => p_rate_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id               => l_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_wci_rate'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception

  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_wci_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_wci_rate;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end delete_wci_rate;
--
end pay_wci_rates_api;

/
