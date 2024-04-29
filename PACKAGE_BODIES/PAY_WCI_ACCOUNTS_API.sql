--------------------------------------------------------
--  DDL for Package Body PAY_WCI_ACCOUNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_WCI_ACCOUNTS_API" as
/* $Header: pypwaapi.pkb 115.2 2002/12/05 14:13:01 swinton noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'pay_wci_accounts_api';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_wci_account >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_wci_account
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_carrier_id                    in     number
  ,p_account_number                in     varchar2
  ,p_name                          in     varchar2 default null
  ,p_location_id                   in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_account_id                    out    nocopy number
  ,p_object_version_number         out    nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'update_wci_account';
  l_effective_date        date;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_wci_account;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_wci_accounts_bk1.create_wci_account_b
      (p_effective_date                => l_effective_date
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_carrier_id                    => p_carrier_id
      ,p_account_number                => p_account_number
      ,p_name                          => p_name
      ,p_location_id                   => p_location_id
      ,p_comments                      => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_wci_account'
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
  pay_pwa_ins.ins
     (p_business_group_id           => p_business_group_id
     ,p_carrier_id                  => p_carrier_id
     ,p_account_number              => p_account_number
     ,p_object_version_number       => p_object_version_number
     ,p_name                        => p_name
     ,p_location_id                 => p_location_id
     ,p_comments                    => p_comments
     ,p_account_id                  => p_account_id
    );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_wci_accounts_bk1.create_wci_account_a
      (p_effective_date                => l_effective_date
      ,p_account_id                    => p_account_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_carrier_id                    => p_carrier_id
      ,p_account_number                => p_account_number
      ,p_name                          => p_name
      ,p_location_id                   => p_location_id
      ,p_comments                      => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_wci_account'
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
    rollback to create_wci_account;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_account_id             := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_wci_account;
    --
    -- Bugfix 2692195
    -- Set all out parameters to null
    --
    p_account_id := null;
    p_object_version_number := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_wci_account;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_wci_account >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_wci_account
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_account_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2
  ,p_location_id                   in     number   default hr_api.g_number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'update_wci_account';
  l_business_group_id     number;
  l_effective_date        date;
  l_carrier_id            number;
  l_object_version_number number;
  --
  cursor csr_record_details is
    select business_group_id, carrier_id
    from pay_wci_accounts
    where account_id = p_account_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Store in out parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint
  --
  savepoint update_wci_account;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Derive necessary parameters
  --
  open csr_record_details;
  fetch csr_record_details into l_business_group_id, l_carrier_id;
  close csr_record_details;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_wci_accounts_bk2.update_wci_account_b
      (p_effective_date                => l_effective_date
      ,p_account_id                    => p_account_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => l_business_group_id
      ,p_carrier_id                    => l_carrier_id
      ,p_name                          => p_name
      ,p_account_number                => p_account_number
      ,p_location_id                   => p_location_id
      ,p_comments                      => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_wci_account'
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
  pay_pwa_upd.upd
     (p_account_id                   => p_account_id
     ,p_object_version_number        => p_object_version_number
     ,p_name                         => p_name
     ,p_account_number               => p_account_number
     ,p_location_id                  => p_location_id
     ,p_comments                     => p_comments
    );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_wci_accounts_bk2.update_wci_account_a
      (p_effective_date                => l_effective_date
      ,p_account_id                    => p_account_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => l_business_group_id
      ,p_carrier_id                    => l_carrier_id
      ,p_name                          => p_name
      ,p_account_number                => p_account_number
      ,p_location_id                   => p_location_id
      ,p_comments                      => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_wci_account'
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
    rollback to update_wci_account;
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
    rollback to create_wci_account;
    --
    -- Bugfix 2692195
    -- Reset all IN OUT parameters
    --
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_wci_account;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_wci_account >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_wci_account
  (p_validate                      in     boolean  default false
  ,p_account_id                    in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'delete_wci_account';
  l_business_group_id     number;
  --
  cursor csr_business_group_id is
    select business_group_id
    from pay_wci_accounts
    where account_id = p_account_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_wci_account;
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
    pay_wci_accounts_bk3.delete_wci_account_b
      (p_account_id                    => p_account_id
      ,p_business_group_id             => l_business_group_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_wci_account'
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
  pay_pwa_del.del
     (p_account_id                   => p_account_id
     ,p_object_version_number        => p_object_version_number
    );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_wci_accounts_bk3.delete_wci_account_a
      (p_account_id                    => p_account_id
      ,p_business_group_id             => l_business_group_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_wci_account'
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
    rollback to delete_wci_account;
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
    rollback to delete_wci_account;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end delete_wci_account;
--
end pay_wci_accounts_api;

/
