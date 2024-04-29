--------------------------------------------------------
--  DDL for Package Body HR_CAGR_PARAMETER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAGR_PARAMETER_API" as
/* $Header: pecpaapi.pkb 115.5 2002/12/10 15:21:05 pkakar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_cagr_parameter_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cagr_parameter >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cagr_parameter
  (p_validate                       in     boolean   default false
  ,p_effective_date                 in     date
  ,p_cagr_api_id                    in     number
  ,p_display_name                   in     varchar2
  ,p_parameter_name                 in     varchar2
  ,p_column_type                    in     varchar2
  ,p_column_size                    in     number
  ,p_uom_parameter                  in     varchar2  default null
  ,p_uom_lookup                     in     varchar2  default null
  ,p_default_uom                    in     varchar2  default null
  ,p_hidden                         in     varchar2
  ,p_cagr_api_param_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_cagr_parameter';
  l_object_version_number per_cagr_api_parameters.object_version_number%TYPE;
  l_cagr_api_param_id     per_cagr_api_parameters.object_version_number%TYPE;
  l_effective_date        DATE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_cagr_parameter;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  per_cpa_ins.ins
    (
     p_effective_date                => l_effective_date
    ,p_cagr_api_id                   => p_cagr_api_id
    ,p_display_name                  => p_display_name
    ,p_parameter_name                => p_parameter_name
    ,p_column_type                   => p_column_type
    ,p_column_size                   => p_column_size
    ,p_uom_parameter                 => p_uom_parameter
    ,p_uom_lookup                    => p_uom_lookup
	,p_default_uom                   => p_default_uom
	,p_hidden                        => p_hidden
    ,p_cagr_api_param_id             => l_cagr_api_param_id
    ,p_object_version_number         => l_object_version_number
    );
  --
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
  p_object_version_number := l_object_version_number;
  p_cagr_api_param_id     := l_cagr_api_param_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_cagr_parameter;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_cagr_api_param_id      := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_cagr_parameter;
    -- Set out parameters
    p_object_version_number  := null;
    p_cagr_api_param_id      := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_cagr_parameter;
-- ----------------------------------------------------------------------------
-- |------------------------< update_cagr_parameter >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cagr_parameter
  (p_validate                       in     boolean   default false
  ,p_effective_date                 in     date
  ,p_cagr_api_param_id              in     number
  ,p_cagr_api_id                    in     number    default hr_api.g_number
  ,p_display_name                   in     varchar2  default hr_api.g_varchar2
  ,p_parameter_name                 in     varchar2  default hr_api.g_varchar2
  ,p_column_type                    in     varchar2  default hr_api.g_varchar2
  ,p_column_size                    in     number    default hr_api.g_number
  ,p_uom_parameter                  in     varchar2  default hr_api.g_varchar2
  ,p_uom_lookup                     in     varchar2  default hr_api.g_varchar2
  ,p_default_uom                    in     varchar2  default hr_api.g_varchar2
  ,p_hidden                         in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_cagr_parameter';
  l_object_version_number per_cagr_api_parameters.object_version_number%TYPE;
  l_effective_date        DATE;
  l_temp_object_version_number per_cagr_api_parameters.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_cagr_parameter;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  l_temp_object_version_number := p_object_version_number;
  --
  per_cpa_upd.upd
    (
     p_cagr_api_param_id             => p_cagr_api_param_id
    ,p_effective_date                => l_effective_date
    ,p_cagr_api_id                   => p_cagr_api_id
    ,p_display_name                  => p_display_name
    ,p_parameter_name                => p_parameter_name
    ,p_column_type                   => p_column_type
    ,p_column_size                   => p_column_size
    ,p_uom_parameter                 => p_uom_parameter
    ,p_uom_lookup                    => p_uom_lookup
	,p_default_uom                   => p_default_uom
	,p_hidden                        => p_hidden
    ,p_object_version_number         => l_object_version_number
    );
  --
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
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_cagr_parameter;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_cagr_parameter;
    --
    -- Reset in out parameters
    p_object_version_number        := l_temp_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_cagr_parameter;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cagr_parameter >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cagr_parameter
  (
   p_cagr_api_param_id              in     number
  ,p_validate                       in     boolean  default false
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_cagr_parameter';
  l_object_version_number per_cagr_api_parameters.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_cagr_parameter;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_cpa_del.del
    (
     p_cagr_api_param_id             => p_cagr_api_param_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_cagr_parameter;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_cagr_parameter;
    -- set in out parameters
    p_object_version_number := l_object_version_number;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
    raise;
    --
end delete_cagr_parameter;
--
end hr_cagr_parameter_api;

/
