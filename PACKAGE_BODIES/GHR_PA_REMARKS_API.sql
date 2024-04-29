--------------------------------------------------------
--  DDL for Package Body GHR_PA_REMARKS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PA_REMARKS_API" as
/* $Header: ghpreapi.pkb 120.1 2006/01/27 12:31:54 vravikan noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ghr_pa_remarks_api.';

--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pa_remarks> >--------------------------|
-- ----------------------------------------------------------------------------
--

--Assumption : Create_pa_remarks is manipulated as create/update based on the existence of the record
--only where OVN = 1, else according to this logic a new rec. will be created.

procedure create_pa_remarks
  (p_validate                      in     boolean    default false
  ,p_pa_request_id 	           in     number
  ,p_remark_id                     in     number
  ,p_description                   in     varchar2  default null
  ,p_remark_code_information1      in     varchar2  default null
  ,p_remark_code_information2      in     varchar2  default null
  ,p_remark_code_information3      in     varchar2  default null
  ,p_remark_code_information4      in     varchar2  default null
  ,p_remark_code_information5      in     varchar2  default null
  ,p_pa_remark_id                  out nocopy   number
  ,p_object_version_number         out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
   Cursor C_Sel1 is
    Select pre.pa_remark_id,
          pre.object_version_number
    from  ghr_pa_remarks pre,
          ghr_noac_remarks nre
    where pre.pa_request_id     = p_pa_request_id and
          pre.remark_id         = p_remark_id and
          nre.remark_id         = pre.remark_id and
          (nre.nature_of_action_id =
                 (select par.first_noa_id
                  from   ghr_pa_requests par
                  where  pa_request_id = p_pa_request_id
                 ) or
          nre.nature_of_action_id =
                 (select par.second_noa_id
                  from   ghr_pa_requests par
                  where  pa_request_id = p_pa_request_id
                 )
            )
            and
          nvl(nre.required_flag,hr_api.g_varchar2)   = 'Y';


  l_proc                        varchar2(72) := g_package || 'create_pa_remarks';
  l_exists                      boolean  := false;
  l_object_version_number       ghr_pa_remarks.object_version_number%TYPE;
  l_pa_remark_id                ghr_pa_remarks.pa_remark_id%TYPE;

begin
  -- check if required remarks already exists , as it might have been populated,by the create_sf52 bp,
  -- prior to this call.

  for remark in C_Sel1 loop
      l_exists                := TRUE;
      l_pa_remark_id          := remark.pa_remark_id;
      l_object_version_number :=  remark.object_version_number;
  end loop;

  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  savepoint create_pa_remarks;
  --
  --
  -- Call Before Process User Hook
  --
  begin
	ghr_pa_remarks_bk1.create_pa_remarks_b	(
           p_pa_request_id            => p_pa_request_id
          ,p_remark_id                => p_remark_id
          ,p_description              => p_description
          ,p_remark_code_information1 => p_remark_code_information1
          ,p_remark_code_information2 => p_remark_code_information2
          ,p_remark_code_information3 => p_remark_code_information3
          ,p_remark_code_information4 => p_remark_code_information4
          ,p_remark_code_information5 => p_remark_code_information5
 	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_ghr_pa_remarks',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Process Logic
  --
 If l_exists then
  -- call update procedure
  l_object_version_number := 1;
  update_pa_remarks
  (p_validate                 => p_validate
  ,p_pa_remark_id             => l_pa_remark_id
  ,p_description              => p_description
  ,p_remark_code_information1 => p_remark_code_information1
  ,p_remark_code_information2 => p_remark_code_information2
  ,p_remark_code_information3 => p_remark_code_information3
  ,p_remark_code_information4 => p_remark_code_information4
  ,p_remark_code_information5 => p_remark_code_information5
  ,p_object_version_number =>l_object_version_number
  );
else

-- if record does not exist already , call ins procedure to create a new record
  ghr_pre_ins.ins
 (p_pa_remark_id             => l_pa_remark_id
 ,p_pa_request_id            => p_pa_request_id
 ,p_remark_id                => p_remark_id
 ,p_description              => p_description
 ,p_remark_code_information1 => p_remark_code_information1
 ,p_remark_code_information2 => p_remark_code_information2
 ,p_remark_code_information3 => p_remark_code_information3
 ,p_remark_code_information4 => p_remark_code_information4
 ,p_remark_code_information5 => p_remark_code_information5
 ,p_object_version_number    => l_object_version_number
 ,p_validate                 => p_validate
 );
end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  --
  -- Call After Process User Hook
  --
  begin
	ghr_pa_remarks_bk1.create_pa_remarks_a	(
           p_pa_remark_id             => l_pa_remark_id
          ,p_pa_request_id            => p_pa_request_id
          ,p_remark_id                => p_remark_id
          ,p_description              => p_description
          ,p_remark_code_information1 => p_remark_code_information1
          ,p_remark_code_information2 => p_remark_code_information2
          ,p_remark_code_information3 => p_remark_code_information3
          ,p_remark_code_information4 => p_remark_code_information4
          ,p_remark_code_information5 => p_remark_code_information5
          ,p_object_version_number    => l_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_ghr_pa_remarks',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_pa_remark_id           := l_pa_remark_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_pa_remarks;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pa_remark_id           := null;
    p_object_version_number  := null;

    when others then
      ROLLBACK TO create_pa_remarks;
    p_pa_remark_id           := null;
    p_object_version_number  := null;
      raise;

    hr_utility.set_location(' Leaving:'||l_proc, 12);

end create_pa_remarks;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< update_pa_remarks> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pa_remarks
  (p_validate                      in     boolean  default false
  ,p_pa_remark_id                  in     number
  ,p_object_version_number         in out nocopy number
  ,p_remark_code_information1      in     varchar2  default hr_api.g_varchar2
  ,p_remark_code_information2      in     varchar2  default hr_api.g_varchar2
  ,p_remark_code_information3      in     varchar2  default hr_api.g_varchar2
  ,p_remark_code_information4      in     varchar2  default hr_api.g_varchar2
  ,p_remark_code_information5      in     varchar2  default hr_api.g_varchar2
  ,p_description                   in     varchar2  default hr_api.g_varchar2
   )
is
  l_proc                varchar2(72) := g_package || 'update_pa_remarks';
  l_object_version_number ghr_pa_remarks.object_version_number%TYPE;
  l_init_ovn ghr_pa_remarks.object_version_number%TYPE;

begin
hr_utility.set_location('Entering:'|| l_proc, 5);
  --
    l_init_ovn := p_object_version_number;
    savepoint update_pa_remarks;
  --
  -- Call Before Process User Hook
  --
  begin
	ghr_pa_remarks_bk2.update_pa_remarks_b	(
           p_pa_remark_id             => p_pa_remark_id
          ,p_description              => p_description
          ,p_remark_code_information1 => p_remark_code_information1
          ,p_remark_code_information2 => p_remark_code_information2
          ,p_remark_code_information3 => p_remark_code_information3
          ,p_remark_code_information4 => p_remark_code_information4
          ,p_remark_code_information5 => p_remark_code_information5
          ,p_object_version_number    => p_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_ghr_pa_remarks',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  --
  -- Store the original ovn in case we rollback when p_validate is true
  --
  l_object_version_number  := p_object_version_number;

  hr_utility.set_location(l_proc, 6);
  ghr_pre_upd.upd
  (p_pa_remark_id             => p_pa_remark_id
  ,p_description              => p_description
  ,p_remark_code_information1 => p_remark_code_information1
  ,p_remark_code_information2 => p_remark_code_information2
  ,p_remark_code_information3 => p_remark_code_information3
  ,p_remark_code_information4 => p_remark_code_information4
  ,p_remark_code_information5 => p_remark_code_information5
  ,p_object_version_number    => p_object_version_number
  ,p_validate                 => p_validate
  );
--
  --
  -- Call After Process User Hook
  --
  begin
	ghr_pa_remarks_bk2.update_pa_remarks_a	(
           p_pa_remark_id             => p_pa_remark_id
          ,p_description              => p_description
          ,p_remark_code_information1 => p_remark_code_information1
          ,p_remark_code_information2 => p_remark_code_information2
          ,p_remark_code_information3 => p_remark_code_information3
          ,p_remark_code_information4 => p_remark_code_information4
          ,p_remark_code_information5 => p_remark_code_information5
          ,p_object_version_number    => l_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_ghr_pa_remarks',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User Hook call
  --
if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
 -- p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_pa_remarks;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    When Others then
      ROLLBACK TO update_pa_remarks;
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
    p_object_version_number  := l_init_ovn;

      raise;
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end update_pa_remarks;

--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_pa_remarks >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pa_remarks
  (p_validate                      in     boolean  default false
  ,p_pa_remark_id                  in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_pa_remarks';
  l_exists                boolean      := false;
  --
  Cursor  C_remark_reqd1 is
    select  1
    from    ghr_noac_remarks  nre,
            ghr_pa_remarks    pre,
            ghr_pa_requests   par
    where   pre.pa_remark_id         = p_pa_remark_id
    and     par.pa_request_id        = pre.pa_request_id
    and     nre.remark_id            = pre.remark_id
    and     nre.nature_of_action_id  = par.first_noa_id
    and     nre.required_flag        = 'Y'
    and     nre.enabled_flag         = 'Y'
    and     nvl(par.effective_date,TRUNC(sysdate)) between nre.date_from
                         and nvl(nre.date_to,nvl(par.effective_date,TRUNC(sysdate)));
--    and     nvl(par.effective_date,sysdate) between
--            nvl(start_date_active,nvl(par.effective_date,sysdate))
--    and     nvl(end_date_active,nvl(par.effective_date,sysdate));
-- amended by SUE 3/24/97


  Cursor  C_remark_reqd2 is
    select  1
    from    ghr_noac_remarks  nre,
            ghr_pa_remarks    pre,
            ghr_pa_requests   par
    where   pre.pa_remark_id         = p_pa_remark_id
    and     par.pa_request_id        = pre.pa_request_id
    and     nre.remark_id            = pre.remark_id
    and     nre.nature_of_action_id  = par.second_noa_id
    and     nre.required_flag        = 'Y'
    and     nre.enabled_flag         = 'Y'
    and     nvl(par.effective_date,TRUNC(sysdate)) between nre.date_from
                         and nvl(nre.date_to,nvl(par.effective_date,TRUNC(sysdate)));

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
    savepoint delete_pa_remarks;
  --
  --
  -- Call Before Process User Hook
  --
  begin
	ghr_pa_remarks_bk3.delete_pa_remarks_b	(
              p_pa_remark_id            => p_pa_remark_id
             ,p_object_version_number   => p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_ghr_pa_remarks',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 7);

  --
  -- Process Logic - Delete pa_remarks details if the specific pa_remark_id is not required
  -- for the first_noa_id specified for the pa_request_id
  -- and for the second_noa_id

  for remark_reqd in c_remark_reqd1 loop
      l_exists := true;
      exit;
  end loop;
 -- if it is a reqd. remark for the 1st Noa, then error
  if l_exists then
    hr_utility.set_message(8301,'GHR_38116_REM_REQD');
    hr_utility.raise_error;
  else
-- if not reqd. for 1st noa, then check if it is reqd. for 2nd noa
    for remark_reqd in c_remark_reqd2 loop
        l_exists := true;
    end loop;
  End if;
--if not reqd, then delete the remark
  If not l_exists then
    ghr_pre_del.del
    (p_pa_remark_id                  => p_pa_remark_id
    ,p_object_version_number         => p_object_version_number
    ,p_validate                      => p_validate
     );
  Else
 -- error to indicate reqd. remark for 2nd noa
    hr_utility.set_message(8301,'GHR_38128_REM_REQD_2');
    hr_utility.raise_error;
  End if;
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Call After Process User Hook
  --
  begin
	ghr_pa_remarks_bk3.delete_pa_remarks_a	(
              p_pa_remark_id            => p_pa_remark_id
             ,p_object_version_number   => p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_ghr_pa_remarks',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_pa_remarks;
    --
  When Others then
    ROLLBACK TO delete_pa_remarks;
    raise;

  hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_pa_remarks;
--
--
end ghr_pa_remarks_api;

/
