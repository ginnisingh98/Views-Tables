--------------------------------------------------------
--  DDL for Package Body BEN_REPORTING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_REPORTING_API" as
/* $Header: bebmnapi.pkb 115.6 2002/12/11 10:35:08 lakrish ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_reporting_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_reporting >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_reporting
  (p_validate                       in  boolean   default false
  ,p_reporting_id                   out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_thread_id                      in  number    default null
  ,p_sequence                       in  number    default null
  ,p_text                           in  varchar2  default null
  ,p_rep_typ_cd                     in  varchar2  default null
  ,p_error_message_code             in  varchar2  default null
  ,p_national_identifier            in  varchar2  default null
  ,p_related_person_ler_id          in  number    default null
  ,p_temporal_ler_id                in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_related_person_id              in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_val                            in  number    default null
  ,p_mo_num                         in  number    default null
  ,p_yr_num                         in  number    default null
  ,p_object_version_number          out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_reporting_id ben_reporting.reporting_id%TYPE;
  l_proc varchar2(72) := g_package||'create_reporting';
  l_object_version_number ben_reporting.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_reporting;
  --
  hr_utility.set_location(l_proc, 20);
  --
  ben_bmn_ins.ins
    (p_reporting_id                  => l_reporting_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_thread_id                     => p_thread_id
    ,p_sequence                      => p_sequence
    ,p_text                          => p_text
    ,p_rep_typ_cd                    => p_rep_typ_cd
    ,p_error_message_code            => p_error_message_code
    ,p_national_identifier           => p_national_identifier
    ,p_related_person_ler_id         => p_related_person_ler_id
    ,p_temporal_ler_id               => p_temporal_ler_id
    ,p_ler_id                        => p_ler_id
    ,p_person_id                     => p_person_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_related_person_id             => p_related_person_id
    ,p_oipl_id                       => p_oipl_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_actl_prem_id                   =>  p_actl_prem_id
    ,p_val                            =>  p_val
    ,p_mo_num                         =>  p_mo_num
    ,p_yr_num                         =>  p_yr_num
    ,p_object_version_number         => l_object_version_number);
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
  p_reporting_id := l_reporting_id;
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
    ROLLBACK TO create_reporting;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_reporting_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    -- Set all output arguments
    --
    p_reporting_id := null;
    p_object_version_number  := null;

    ROLLBACK TO create_reporting;
    raise;
    --
end create_reporting;
-- ----------------------------------------------------------------------------
-- |------------------------< update_reporting >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_reporting
  (p_validate                       in  boolean   default false
  ,p_reporting_id                   in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_thread_id                      in  number    default hr_api.g_number
  ,p_sequence                       in  number    default hr_api.g_number
  ,p_text                           in  varchar2  default hr_api.g_varchar2
  ,p_rep_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_error_message_code             in  varchar2  default hr_api.g_varchar2
  ,p_national_identifier            in  varchar2  default hr_api.g_varchar2
  ,p_related_person_ler_id          in  number    default hr_api.g_number
  ,p_temporal_ler_id                in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_related_person_id              in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_val                            in  number    default hr_api.g_number
  ,p_mo_num                         in  number    default hr_api.g_number
  ,p_yr_num                         in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_reporting';
  l_object_version_number ben_reporting.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_reporting;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  ben_bmn_upd.upd
    (p_reporting_id                  => p_reporting_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_thread_id                     => p_thread_id
    ,p_sequence                      => p_sequence
    ,p_text                          => p_text
    ,p_rep_typ_cd                    => p_rep_typ_cd
    ,p_error_message_code            => p_error_message_code
    ,p_national_identifier           => p_national_identifier
    ,p_related_person_ler_id         => p_related_person_ler_id
    ,p_temporal_ler_id               => p_temporal_ler_id
    ,p_ler_id                        => p_ler_id
    ,p_person_id                     => p_person_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_related_person_id             => p_related_person_id
    ,p_oipl_id                       => p_oipl_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_actl_prem_id                   =>  p_actl_prem_id
    ,p_val                            =>  p_val
    ,p_mo_num                         =>  p_mo_num
    ,p_yr_num                         =>  p_yr_num
    ,p_object_version_number         => l_object_version_number);
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
    ROLLBACK TO update_reporting;
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
    -- Set all output arguments
    --

    ROLLBACK TO update_reporting;
    raise;
    --
end update_reporting;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_reporting >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_reporting
  (p_validate                       in  boolean  default false
  ,p_reporting_id                   in  number
  ,p_object_version_number          in out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_reporting';
  l_object_version_number ben_reporting.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_reporting;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  ben_bmn_del.del
    (p_reporting_id                  => p_reporting_id
    ,p_object_version_number         => l_object_version_number);
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
    ROLLBACK TO delete_reporting;
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

    ROLLBACK TO delete_reporting;
    raise;
    --
end delete_reporting;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_reporting_id                   in     number
  ,p_object_version_number          in     number) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_bmn_shd.lck
    (p_reporting_id               => p_reporting_id
    ,p_object_version_number      => p_object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_reporting_api;

/
