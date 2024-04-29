--------------------------------------------------------
--  DDL for Package Body HR_ELC_RESULT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ELC_RESULT_API" as
/* $Header: peersapi.pkb 115.3 2002/12/11 10:29:50 pkakar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_elc_result_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_election_result >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_election_result
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_job_id                        in     number
  ,p_person_id                     in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_primary_contact_flag          in     varchar2
  ,p_election_candidate_id         in     number
  ,p_ovn_election_candidates        in out nocopy number
  ,p_business_group_id             in     number
  ,p_election_id                   in     number
  ,p_rank                          in     number
  ,p_role_id                          out nocopy number
  ,p_ovn_per_roles           out nocopy number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                         varchar2(72) := g_package||'create_election_result';
  l_job_group_id                 number;
  l_role_id                      per_roles.role_id%TYPE;
  l_ovn_election_candidates       per_election_candidates.object_version_number%TYPE;
  l_temp_ovn per_election_candidates.object_version_number%TYPE := p_ovn_election_candidates;
  l_ovn_per_roles       per_roles.object_version_number%TYPE;
  l_effective_date           date;
  l_start_date               date;
  l_end_date                 date;
--
-- Cusor to get the job_group_id for the given job_id
   cursor c_get_job_group_id is
     select job_group_id
     from per_jobs
     where job_id = p_job_id;
---
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_election_result;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := trunc(p_effective_date);
     l_start_date:= trunc(p_start_date);
     l_end_date:= trunc(p_end_date);

  -- Get job_group_id for the passed in job_id
  open c_get_job_group_id;
  fetch c_get_job_group_id into l_job_group_id;
  close c_get_job_group_id;
  --
  -- store ovn passed in
  l_ovn_election_candidates := p_ovn_election_candidates;
  -- Call per_supplementary_role_api to create the record in per_roles
  per_supplementary_role_api.create_supplementary_role
      (p_effective_date                => l_effective_date
      ,p_job_group_id                  => l_job_group_id
      ,p_job_id                        => p_job_id
      ,p_person_id                     => p_person_id
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      ,p_primary_contact_flag          => p_primary_contact_flag
      ,p_role_id                       => l_role_id
      ,p_object_version_number        => l_ovn_per_roles);
  --
 --  Call the per_elc_candidate_api to insert the rank and
 -- role for the candidate.

 hr_elc_candidate_api.update_election_candidate
     (p_election_candidate_id         => p_election_candidate_id
     ,p_object_version_number         => l_ovn_election_candidates
     ,p_business_group_id             => p_business_group_id
     ,p_person_id                     => p_person_id
     ,p_election_id                   => p_election_id
     ,p_rank                          => p_rank
     ,p_role_id                       => l_role_id);

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --

  -- Set all output arguments
  --
  p_role_id                     := l_role_id;
  p_ovn_election_candidates      := l_ovn_election_candidates;
  p_ovn_per_roles      := l_ovn_per_roles;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_election_result;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
   p_role_id                     := null;
    p_ovn_per_roles      := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_election_result ;
    --
    -- set in out parameters and set out parameters
    --
    p_role_id                     := null;
    p_ovn_per_roles      := null;
    p_ovn_election_candidates     := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_election_result;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< update_election_result >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_election_result
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_role_id                       in     number
  ,p_ovn_per_roles                 in out nocopy number
  ,p_job_id                        in     number   default hr_api.g_number
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_primary_contact_flag          in     varchar2 default hr_api.g_varchar2
  ,p_election_candidate_id         in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_election_id                   in     number   default hr_api.g_number
  ,p_ovn_election_candidates       in out nocopy number
  ,p_rank                          in     number   default hr_api.g_number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_election_result';
  l_job_group_id        number;
  l_ovn_election_candidates       per_election_candidates.object_version_number%TYPE;
  l_ovn_per_roles       per_roles.object_version_number%TYPE;
  l_effective_date           date;
  l_start_date               date;
  l_end_date                 date;
--
-- Cusor to get the job_group_id for the given job_id
   cursor c_get_job_group_id is
     select job_group_id
     from per_jobs
     where job_id = p_job_id;
---
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_election_result;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := trunc(p_effective_date);
     l_start_date:= trunc(p_start_date);
     l_end_date:= trunc(p_end_date);

  -- Get job_group_id for the passed in job_id
  open c_get_job_group_id;
  fetch c_get_job_group_id into l_job_group_id;
  close c_get_job_group_id;
  --
  -- store ovn passed in
  l_ovn_election_candidates    :=  p_ovn_election_candidates;
  l_ovn_per_roles    :=  p_ovn_per_roles;

  -- Call per_supplementary_role_api to update the record in per_roles
  per_supplementary_role_api.update_supplementary_role
      (p_effective_date                => l_effective_date
      ,p_role_id                       => p_role_id
      ,p_object_version_number         => l_ovn_per_roles
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      ,p_primary_contact_flag          => p_primary_contact_flag);
  --
  --
 --  Call the per_elc_candidate_api to insert the rank
 --  and role fro the candidate.

 hr_elc_candidate_api.update_election_candidate
     (p_election_candidate_id         => p_election_candidate_id
     ,p_object_version_number        => l_ovn_election_candidates
     ,p_business_group_id             => p_business_group_id
     ,p_election_id                   => p_election_id
     ,p_person_id                     => p_person_id
     ,p_rank                          => p_rank
     ,p_role_id                       => p_role_id);
  -- Set all output arguments
  --
  p_ovn_election_candidates      := l_ovn_election_candidates;
  p_ovn_per_roles      := l_ovn_per_roles;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_election_result;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ovn_election_candidates      := null;
    p_ovn_per_roles      := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_election_result ;
    --
    -- set in out parameters and set out parameters
    --
     p_ovn_election_candidates      := null;
    p_ovn_per_roles      := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_election_result;
--
end hr_elc_result_api;

/
