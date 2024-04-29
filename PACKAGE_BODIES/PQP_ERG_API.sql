--------------------------------------------------------
--  DDL for Package Body PQP_ERG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ERG_API" as
/* $Header: pqergapi.pkb 120.1 2006/10/20 18:43:18 sshetty noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqp_erg_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_exception_group >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_exception_group
  (p_validate                      in     boolean  default false
  ,p_exception_group_name           in     varchar2 default null
  ,p_exception_report_id            in     number
  ,p_legislation_code               in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_consolidation_set_id           in     number   default null
  ,p_payroll_id                     in     number   default null
  ,p_exception_group_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_output_format                  in     varchar2
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                       varchar2(72) := g_package||'create_exception_group';
  l_exception_group_id  number;
  l_object_version_number      number;
  l_output_format              pqp_exception_report_groups.output_format%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_exception_group;

  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  l_output_format :=p_output_format;
  begin
    pqp_exception_group_bk1.create_exception_group_b
      (p_exception_group_name    => p_exception_group_name
      ,p_exception_report_id     => p_exception_report_id
      ,p_legislation_code        => p_legislation_code
      ,p_business_group_id       => p_business_group_id
      ,p_consolidation_set_id    => p_consolidation_set_id
      ,p_payroll_id              => p_payroll_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_exception_group'
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
  IF p_output_format ='TXT' THEN
   l_output_format:='PDF' ;
  END IF;

  pqp_erg_ins.ins (
   p_exception_group_name  => p_exception_group_name
  ,p_exception_report_id   => p_exception_report_id
  ,p_legislation_code      => p_legislation_code
  ,p_business_group_id     => p_business_group_id
  ,p_consolidation_set_id  => p_consolidation_set_id
  ,p_payroll_id            => p_payroll_id
  ,p_exception_group_id    => l_exception_group_id
  ,p_object_version_number => l_object_version_number
  ,p_output_format         => l_output_format
      );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pqp_exception_group_bk1.create_exception_group_a
      (p_exception_group_name    => p_exception_group_name
      ,p_exception_report_id     => p_exception_report_id
      ,p_legislation_code        => p_legislation_code
      ,p_business_group_id       => p_business_group_id
      ,p_consolidation_set_id    => p_consolidation_set_id
      ,p_payroll_id              => p_payroll_id
      ,p_exception_group_id      => l_exception_group_id
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_exception_group'
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
  p_exception_group_id        := l_exception_group_id;
  p_object_version_number      := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_exception_group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_exception_group_id        := null;
    p_object_version_number      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_exception_group;
    p_exception_group_id        := null;
    p_object_version_number     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_exception_group;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_exception_group >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_exception_group
  (p_validate                     in     boolean   default false
  ,p_exception_group_id           in     number    default hr_api.g_number
  ,p_exception_group_name         in     varchar2  default hr_api.g_varchar2
  ,p_exception_report_id          in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_consolidation_set_id         in     number    default hr_api.g_number
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_output_format                in     varchar2  default hr_api.g_varchar2
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_exception_group';
  l_object_version_number      number;

  l_output_format              pqp_exception_report_groups.output_format%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_exception_group;

  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  l_output_format:=p_output_format;
  begin
    pqp_exception_group_bk2.update_exception_group_b
      (p_exception_group_name    => p_exception_group_name
      ,p_exception_report_id     => p_exception_report_id
      ,p_legislation_code        => p_legislation_code
      ,p_business_group_id       => p_business_group_id
      ,p_consolidation_set_id    => p_consolidation_set_id
      ,p_payroll_id              => p_payroll_id
      ,p_exception_group_id      => p_exception_group_id
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_exception_group'
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

  IF p_output_format ='TXT' THEN
   l_output_format:='PDF' ;
  END IF;

  pqp_erg_upd.upd (
   p_exception_group_name  => p_exception_group_name
  ,p_exception_report_id   => p_exception_report_id
  ,p_legislation_code      => p_legislation_code
  ,p_business_group_id     => p_business_group_id
  ,p_consolidation_set_id  => p_consolidation_set_id
  ,p_payroll_id            => p_payroll_id
  ,p_exception_group_id    => p_exception_group_id
  ,p_object_version_number => l_object_version_number
  ,p_output_format         => l_output_format
      );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pqp_exception_group_bk2.update_exception_group_a
      (p_exception_group_name    => p_exception_group_name
      ,p_exception_report_id     => p_exception_report_id
      ,p_legislation_code        => p_legislation_code
      ,p_business_group_id       => p_business_group_id
      ,p_consolidation_set_id    => p_consolidation_set_id
      ,p_payroll_id              => p_payroll_id
      ,p_exception_group_id      => p_exception_group_id
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_exception_group'
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
    rollback to update_exception_group;
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
    rollback to update_exception_group;
    p_object_version_number      :=  l_object_version_number    ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_exception_group;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_exception_group >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_exception_group
  (p_validate                      in     boolean  default false
  ,p_exception_group_id            in     number
  ,p_object_version_number         in     number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_exception_group';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_exception_group;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pqp_exception_group_bk3.delete_exception_group_b
      (p_exception_group_id => p_exception_group_id
      ,p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_exception_group'
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


  pqp_erg_del.del (
    p_exception_group_id => p_exception_group_id
   ,p_object_version_number => p_object_version_number
      );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pqp_exception_group_bk3.delete_exception_group_a
      (p_exception_group_id => p_exception_group_id
      ,p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_exception_group'
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
    rollback to delete_exception_group;
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
    rollback to delete_exception_group;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_exception_group;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_exception_group >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_exception_group
  (p_validate                      in     boolean  default false
  ,p_exception_group_name          in     varchar2
  ,p_business_group_id		   in	  number
  ) is

  --
  -- Declare cursors and local variables
  --
  Cursor c_GrpDets Is
  Select * from pqp_exception_report_groups
  Where exception_group_name = p_exception_group_name
    and business_group_id    = p_business_group_id;


  -- RowType variable declaration
  r_GrpDets		c_GrpDets%ROWTYPE;

  -- Local variable declaration
  l_proc                varchar2(72) := g_package||'delete_exception_group';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Process Logic
  --
  For r_GrpDets in c_GrpDets
  Loop -- 1

    pqp_erg_api.delete_exception_group
      		(p_validate			=> p_validate
      		,p_exception_group_id		=> r_GrpDets.exception_group_id
      		,p_object_version_number	=> r_GrpDets.object_version_number
      		);

  End Loop; -- 1
  --
  hr_utility.set_location(l_proc, 20);
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);
    raise;
end delete_exception_group;
--
end pqp_erg_api;

/
