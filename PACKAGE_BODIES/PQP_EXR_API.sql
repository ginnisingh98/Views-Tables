--------------------------------------------------------
--  DDL for Package Body PQP_EXR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EXR_API" as
/* $Header: pqexrapi.pkb 120.0.12010000.2 2008/08/08 07:13:20 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqp_exr_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_exception_report >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_exception_report
  (p_validate                      in     boolean  default false
  ,p_exception_report_name          in     varchar2
  ,p_legislation_code               in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_currency_code                  in     varchar2 default null
  ,p_balance_type_id                in     number   default null
  ,p_balance_dimension_id           in     number   default null
  ,p_variance_type                  in     varchar2 default null
  ,p_variance_value                 in     number   default null
  ,p_comparison_type                in     varchar2 default null
  ,p_comparison_value               in     number   default null
  ,p_language_code                  in     varchar2  default hr_api.userenv_lang
  ,p_exception_report_id               out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_output_format_type             in     varchar2
  ,p_variance_operator              in     varchar2
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                       varchar2(72) := g_package||'create_exception_report';
  l_exception_report_id  number;
  l_object_version_number      number;
  l_language_code varchar2(30);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_exception_report;

  hr_utility.set_location(l_proc, 20);

  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    pqp_exception_report_bk1.create_exception_report_b
      (p_exception_report_name => p_exception_report_name
  ,p_legislation_code          => p_legislation_code
  ,p_business_group_id         => p_business_group_id
  ,p_currency_code             => p_currency_code
  ,p_balance_type_id           => p_balance_type_id
  ,p_balance_dimension_id      => p_balance_dimension_id
  ,p_variance_type             => p_variance_type
  ,p_variance_value            => p_variance_value
  ,p_comparison_type           => p_comparison_type
  ,p_comparison_value          => p_comparison_value
  ,p_output_format_type        => p_output_format_type
  ,p_variance_operator         => p_variance_operator
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_exception_report'
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


  pqp_exr_ins.ins (
   p_exception_report_name => p_exception_report_name
  ,p_legislation_code      => p_legislation_code
  ,p_business_group_id     => p_business_group_id
  ,p_currency_code         => p_currency_code
  ,p_balance_type_id       => p_balance_type_id
  ,p_balance_dimension_id  => p_balance_dimension_id
  ,p_variance_type         => p_variance_type
  ,p_variance_value        => p_variance_value
  ,p_comparison_type       => p_comparison_type
  ,p_comparison_value      => p_comparison_value
  ,p_exception_report_id   => l_exception_report_id
  ,p_object_version_number => l_object_version_number
  ,p_output_format_type    => p_output_format_type
  ,p_variance_operator     => p_variance_operator
  );

  pqp_ert_ins.ins_tl(
   p_language_code         => p_language_code
  ,p_exception_report_id   => l_exception_report_id
  ,p_exception_report_name => p_exception_report_name
  );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pqp_exception_report_bk1.create_exception_report_a
      (p_exception_report_name => p_exception_report_name
  ,p_legislation_code          => p_legislation_code
  ,p_business_group_id         => p_business_group_id
  ,p_currency_code             => p_currency_code
  ,p_balance_type_id           => p_balance_type_id
  ,p_balance_dimension_id      => p_balance_dimension_id
  ,p_variance_type             => p_variance_type
  ,p_variance_value            => p_variance_value
  ,p_comparison_type           => p_comparison_type
  ,p_comparison_value          => p_comparison_value
  ,p_exception_report_id       => l_exception_report_id
  ,p_object_version_number     => l_object_version_number
  ,p_output_format_type        => p_output_format_type
  ,p_variance_operator         => p_variance_operator
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_exception_report'
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
  p_exception_report_id        := l_exception_report_id;
  p_object_version_number      := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_exception_report;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_exception_report_id        := null;
    p_object_version_number      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_exception_report;
    p_exception_report_id        := null;
    p_object_version_number      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_exception_report;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_exception_report >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_exception_report
  (p_validate                      in     boolean  default false
  ,p_exception_report_name          in     varchar2 default hr_api.g_varchar2
  ,p_legislation_code               in     varchar2 default hr_api.g_varchar2
  ,p_business_group_id              in     number   default hr_api.g_number
  ,p_currency_code                  in     varchar2 default hr_api.g_varchar2
  ,p_balance_type_id                in     number   default hr_api.g_number
  ,p_balance_dimension_id           in     number   default hr_api.g_number
  ,p_variance_type                  in     varchar2 default hr_api.g_varchar2
  ,p_variance_value                 in     number   default hr_api.g_number
  ,p_comparison_type                in     varchar2 default hr_api.g_varchar2
  ,p_comparison_value               in     number   default hr_api.g_number
  ,p_exception_report_id            in     number   default hr_api.g_number
  ,p_language_code                  in     varchar2 default hr_api.userenv_lang
  ,p_object_version_number          in out nocopy number
  ,p_output_format_type             in     varchar2 default hr_api.g_varchar2
  ,p_variance_operator              in     varchar2 default hr_api.g_varchar2

  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_exception_report';
  l_object_version_number      number;
  l_language_code       varchar2(30);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_exception_report;

  hr_utility.set_location(l_proc, 20);

  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    pqp_exception_report_bk2.update_exception_report_b
      (p_exception_report_name => p_exception_report_name
  ,p_legislation_code          => p_legislation_code
  ,p_business_group_id         => p_business_group_id
  ,p_currency_code             => p_currency_code
  ,p_balance_type_id           => p_balance_type_id
  ,p_balance_dimension_id      => p_balance_dimension_id
  ,p_variance_type             => p_variance_type
  ,p_variance_value            => p_variance_value
  ,p_comparison_type           => p_comparison_type
  ,p_comparison_value          => p_comparison_value
  ,p_exception_report_id       => p_exception_report_id
  ,p_object_version_number     => p_object_version_number
  ,p_output_format_type        => p_output_format_type
  ,p_variance_operator         => p_variance_operator
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_exception_report'
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
  l_object_version_number  := p_object_version_number;


  pqp_exr_upd.upd (
   p_exception_report_id   => p_exception_report_id
  ,p_object_version_number => l_object_version_number
  ,p_exception_report_name => p_exception_report_name
  ,p_legislation_code      => p_legislation_code
  ,p_business_group_id     => p_business_group_id
  ,p_currency_code         => p_currency_code
  ,p_balance_type_id       => p_balance_type_id
  ,p_balance_dimension_id  => p_balance_dimension_id
  ,p_variance_type         => p_variance_type
  ,p_variance_value        => p_variance_value
  ,p_comparison_type       => p_comparison_type
  ,p_comparison_value      => p_comparison_value
  ,p_output_format_type    => p_output_format_type
  ,p_variance_operator     => p_variance_operator
      );

  pqp_ert_upd.upd_tl(
   p_language_code         => p_language_code
  ,p_exception_report_id   => p_exception_report_id
  ,p_exception_report_name => p_exception_report_name
  );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pqp_exception_report_bk2.update_exception_report_a
      (p_exception_report_name => p_exception_report_name
  ,p_legislation_code          => p_legislation_code
  ,p_business_group_id         => p_business_group_id
  ,p_currency_code             => p_currency_code
  ,p_balance_type_id           => p_balance_type_id
  ,p_balance_dimension_id      => p_balance_dimension_id
  ,p_variance_type             => p_variance_type
  ,p_variance_value            => p_variance_value
  ,p_comparison_type           => p_comparison_type
  ,p_comparison_value          => p_comparison_value
  ,p_exception_report_id       => p_exception_report_id
  ,p_object_version_number     => l_object_version_number
  ,p_output_format_type        => p_output_format_type
  ,p_variance_operator         => p_variance_operator
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_exception_report'
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
  p_object_version_number      := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_exception_report;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_exception_report;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    p_object_version_number      := null;
    raise;
end update_exception_report;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_exception_report >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_exception_report
  (p_validate                      in     boolean  default false
  ,p_exception_report_id           in     number
  ,p_object_version_number         in     number
  ) is

  --
  -- Declare cursors and local variables
  --
  cursor csr_bg_id (c_exception_report_id in number) is
  select per.business_group_id
    from pqp_exception_reports per
   where per.exception_report_id = c_exception_report_id;

  l_business_group_id   number;
  l_proc                varchar2(72) := g_package||'delete_exception_report';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_exception_report;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  open csr_bg_id(p_exception_report_id);
  fetch csr_bg_id into l_business_group_id;
  close csr_bg_id;

  begin

    pqp_exception_report_bk3.delete_exception_report_b
      (p_exception_report_id   => p_exception_report_id
      ,p_business_group_id     => l_business_group_id
      ,p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_exception_report'
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

  pqp_ert_del.del_tl(
  p_exception_report_id   => p_exception_report_id
  );


  pqp_exr_del.del (
    p_exception_report_id => p_exception_report_id
   ,p_object_version_number => p_object_version_number
      );


  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pqp_exception_report_bk3.delete_exception_report_a
      (p_exception_report_id   => p_exception_report_id
      ,p_business_group_id     => l_business_group_id
      ,p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_exception_report'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_exception_report;
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
    rollback to delete_exception_report;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_exception_report;
--
end pqp_exr_api;

/
