--------------------------------------------------------
--  DDL for Package Body GHR_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_ASSIGNMENT_API" as
/* $Header: ghasgapi.pkb 120.0 2006/01/27 12:39:35 vravikan noship $ */
--
g_package varchar2(33) :=  ' ghr_assignment_api.';

--
--
-- ----------------------------------------------------------------------------
-- |----------------------< accept_apl_asg >----------------------|
-- ----------------------------------------------------------------------------
  procedure accept_apl_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  )
--
is

 l_proc                     varchar2(72);
 l_object_version_number    per_assignments_f.object_version_number%type;
 l_init_ovn per_assignments_f.object_version_number%type;


BEGIN
  l_proc :=  g_package ||'accept_apl_asg';
  -- NOCOPY Changes
  l_init_ovn :=  p_object_version_number;
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --

  SAVEPOINT ghr_accept_apl_asg;

  l_object_version_number   :=   p_object_version_number;

  hr_utility.set_location(l_proc, 10);
  --
  ghr_session.set_session_var_for_core
  (p_effective_date  => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 15);
     hr_assignment_api.accept_apl_asg
     (p_effective_date             =>   p_effective_date
     ,p_datetrack_update_mode      =>   p_datetrack_update_mode
     ,p_assignment_id              =>   p_assignment_id
     ,p_object_version_number      =>   l_object_version_number
     ,p_assignment_status_type_id  =>   p_assignment_status_type_id
     ,p_change_reason              =>   p_change_reason
     ,p_effective_start_date       =>   p_effective_start_date
     ,p_effective_end_date         =>   p_effective_end_date
    );
 hr_utility.set_location(l_proc, 20);
  --
 ghr_history_api.post_update_process;

  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
   p_object_version_number  :=  l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 25);
EXCEPTION
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_accept_apl_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_object_version_number  :=  l_object_version_number;
    p_effective_start_date   :=  null;
    p_effective_end_date     :=  null;

    hr_utility.set_location(' Leaving:'||l_proc, 30);
 WHEN others then
   ROLLBACK TO ghr_accept_apl_asg;
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
    p_object_version_number  := l_init_ovn;
    p_effective_start_date   :=  null;
    p_effective_end_date     :=  null;

   raise;

end accept_apl_asg;

end ghr_assignment_api;

/
