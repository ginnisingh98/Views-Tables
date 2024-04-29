--------------------------------------------------------
--  DDL for Package Body PAY_CNU_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CNU_API" as
/* $Header: pycnuapi.pkb 115.6 2004/02/06 04:53:20 sspratur noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_CNU_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_CONTRIBUTION_USAGE >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_contribution_usage(
   p_validate                     IN      boolean  default false
  ,p_effective_date               IN      date
  ,p_date_from                    IN      date
  ,p_date_to                      IN      date     default null
  ,p_group_code                   IN      varchar2
  ,p_process_type                 IN      varchar2
  ,p_element_name                 IN      varchar2
  ,p_contribution_usage_type      IN      varchar2
  ,p_rate_type                    IN      varchar2 default null
  ,p_rate_category                IN      varchar2
  ,p_contribution_code            IN      varchar2 default null
  ,p_contribution_type            IN      varchar2
  ,p_retro_contribution_code      IN      varchar2 default null
  ,p_business_group_id            IN      varchar2 default null
  ,p_object_version_number           OUT  nocopy number
  ,p_contribution_usage_id           OUT  nocopy number
  ,p_code_rate_id                 IN OUT  nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Contribution Usage';
  l_contribution_usage_id   number;
  l_object_version_number   number;
  l_effective_date          date;
  l_date_from               date;
  l_date_to                 date;
  l_adj_cu_id               number;
  l_adj_ovn                 number;
  l_adj_date_to             date;
  l_code_Rate_id            number;
  l_original_code_Rate_id   number;
  --
  cursor csr_adjust is
    select cnu.contribution_usage_id, cnu.object_version_number
      from   pay_fr_contribution_usages cnu
     where  cnu.group_code   = p_group_code
       and  cnu.process_type = p_process_type
       and  cnu.element_name = p_element_name
       and  cnu.contribution_usage_type = p_contribution_usage_type
       and  cnu.date_to is null
       and  cnu.date_from < p_date_from
       and (  nvl(p_business_group_id, -1)
            = nvl(cnu.business_group_id, -1)
           );
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_CONTRIBUTION_USAGE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date        := trunc(p_effective_date);
  l_date_from             := trunc(p_date_from);
  l_date_to               := trunc(p_date_to);
  l_code_Rate_id          := p_code_Rate_id;
  l_original_code_Rate_id := p_code_Rate_id;
  --
  -- update an existing record if necessary
  --
  Open  csr_adjust;
  Fetch csr_adjust into l_adj_cu_id, l_adj_ovn;
  if    csr_adjust%FOUND
  then
    -- a row exists and needs adjusting. Always set validate to false
    -- as this insert rollback will rollback the update.
    --
    close csr_adjust;
    pay_cnu_api.update_contribution_usage
    (p_validate                     => FALSE
    ,p_effective_date               => l_effective_date
    ,p_contribution_usage_id        => l_adj_cu_id
    ,p_date_to                      => l_date_from-1
    ,p_contribution_code            => p_contribution_code
    ,p_contribution_type            => p_contribution_type
    ,p_object_version_number        => l_adj_ovn
    ,p_code_rate_id                 => l_code_rate_id
    );
  else
    close csr_adjust;
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_cnu_api_bk1.create_contribution_usage_b
  (p_effective_date              => l_effective_date
  ,p_date_from                   => l_date_from
  ,p_date_to                     => l_date_to
  ,p_group_code                  => p_group_code
  ,p_process_type                => p_process_type
  ,p_element_name                => p_element_name
  ,p_contribution_usage_type     => p_contribution_usage_type
  ,p_rate_type                   => p_rate_type
  ,p_rate_category               => p_rate_category
  ,p_contribution_code           => p_contribution_code
  ,p_contribution_type           => p_contribution_type
  ,p_retro_contribution_code     => p_retro_contribution_code
  ,p_business_group_id           => p_business_group_id
  ,p_code_Rate_id                => l_code_Rate_id
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CONTRIBUTION_USAGE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  pay_cnu_ins.ins
  (p_effective_date              => l_effective_date
  ,p_date_from                   => l_date_from
  ,p_date_to                     => l_date_to
  ,p_group_code                  => p_group_code
  ,p_process_type                => p_process_type
  ,p_element_name                => p_element_name
  ,p_contribution_usage_type     => p_contribution_usage_type
  ,p_rate_type                   => p_rate_type
  ,p_rate_category               => p_rate_category
  ,p_contribution_code           => p_contribution_code
  ,p_contribution_type           => p_contribution_type
  ,p_retro_contribution_code     => p_retro_contribution_code
  ,p_business_group_id           => p_business_group_id
  ,p_contribution_usage_id       => l_contribution_usage_id
  ,p_object_version_number       => l_object_version_number
  ,p_code_Rate_id                => l_code_Rate_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  pay_cnu_api_bk1.create_contribution_usage_a
  (p_effective_date              => l_effective_date
  ,p_date_from                   => l_date_from
  ,p_date_to                     => l_date_to
  ,p_group_code                  => p_group_code
  ,p_process_type                => p_process_type
  ,p_element_name                => p_element_name
  ,p_contribution_usage_type     => p_contribution_usage_type
  ,p_rate_type                   => p_rate_type
  ,p_rate_category               => p_rate_category
  ,p_contribution_code           => p_contribution_code
  ,p_contribution_type           => p_contribution_type
  ,p_retro_contribution_code     => p_retro_contribution_code
  ,p_business_group_id           => p_business_group_id
  ,p_contribution_usage_id       => l_contribution_usage_id
  ,p_object_version_number       => l_object_version_number
  ,p_code_Rate_id                => l_code_Rate_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CONTRIBUTION_USAGE'
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
  p_contribution_usage_id   := l_contribution_usage_id;
  p_object_version_number   := l_object_version_number;
  p_code_Rate_id            := l_code_Rate_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_CONTRIBUTION_USAGE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_contribution_usage_id   := null;
    p_object_version_number   := null;
    p_code_Rate_id            := l_original_code_Rate_id;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_CONTRIBUTION_USAGE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    -- Reset IN OUT params and set OUT params.
    --
    p_contribution_usage_id   := null;
    p_object_version_number   := null;
    p_code_Rate_id            := l_original_code_Rate_id;
    --
    raise;
end create_contribution_usage;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_CONTRIBUTION_USAGE >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_contribution_usage
  (p_validate                     IN      boolean  default false
  ,p_effective_date               IN      date
  ,p_contribution_usage_id        IN      number
  ,p_date_to                      IN      date     default hr_api.g_date
  ,p_contribution_code            IN      varchar2
  ,p_contribution_type            IN      varchar2
  ,p_retro_contribution_code      IN      varchar2 default hr_api.g_varchar2
  ,p_object_version_number        IN OUT  nocopy number
  ,p_code_rate_id                 IN      varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Contribution Usage';
  l_effective_date          date;
  l_date_to                 date;
  l_object_version_number   number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_CONTRIBUTION_USAGE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date         := trunc(p_effective_date);
  l_object_version_number  := p_object_version_number;
  l_date_to                := trunc(p_date_to);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_cnu_api_bk2.update_contribution_usage_b
  (p_effective_date                 => l_effective_date
  ,p_contribution_usage_id          => p_contribution_usage_id
  ,p_object_version_number          => l_object_version_number
  ,p_date_to                        => l_date_to
  ,p_contribution_code              => p_contribution_code
  ,p_contribution_type              => p_contribution_type
  ,p_retro_contribution_code        => p_retro_contribution_code
  ,p_code_rate_id                   => p_code_rate_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CONTRIBUTION_USAGE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  pay_cnu_upd.upd
  (p_effective_date              => l_effective_date
  ,p_contribution_usage_id       => p_contribution_usage_id
  ,p_date_to                     => l_date_to
  ,p_contribution_code           => p_contribution_code
  ,p_contribution_type           => p_contribution_type
  ,p_retro_contribution_code     => p_retro_contribution_code
  ,p_object_version_number       => l_object_version_number
  ,p_code_rate_id                   => p_code_rate_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  pay_cnu_api_bk2.update_contribution_usage_a
  (p_effective_date                 => l_effective_date
  ,p_contribution_usage_id          => p_contribution_usage_id
  ,p_object_version_number          => l_object_version_number
  ,p_date_to                        => l_date_to
  ,p_contribution_code              => p_contribution_code
  ,p_contribution_type              => p_contribution_type
  ,p_retro_contribution_code        => p_retro_contribution_code
  ,p_code_rate_id                   => p_code_rate_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CONTRIBUTION_USAGE'
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
     p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_CONTRIBUTION_USAGE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_CONTRIBUTION_USAGE;
    --
    -- Reset IN OUT params and set OUT params.
    --
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_contribution_usage;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_CONTRIBUTION_USAGE >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_contribution_usage
  (p_validate                      in     boolean  default false
  ,p_contribution_usage_id         in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Contribution Usage';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_CONTRIBUTION_USAGE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    pay_cnu_api_bk3.delete_contribution_usage_b
  (p_contribution_usage_id       => p_contribution_usage_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CONTRIBUTION_USAGE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  pay_cnu_del.del
  (p_contribution_usage_id   => p_contribution_usage_id
  ,p_object_version_number   => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  pay_cnu_api_bk3.delete_contribution_usage_a
  (p_contribution_usage_id       => p_contribution_usage_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CONTRIBUTION_USAGE'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_CONTRIBUTION_USAGE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_CONTRIBUTION_USAGE;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_contribution_usage;
--
end pay_cnu_api;

/
