--------------------------------------------------------
--  DDL for Package Body GHR_AGENCY_APPEALS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_AGENCY_APPEALS_API" as
/* $Header: ghcaaapi.pkb 115.1 2003/01/30 16:31:26 asubrahm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_complaints_appeals_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_agency_appeal>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_agency_appeal
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_complaint_id                   in     number   default null
  ,p_appeal_date                    in     date     default null
  ,p_reason_for_appeal              in     varchar2 default null
  ,p_source_decision_date           in	   date     default null
  ,p_docket_num                     in	   varchar2 default null
  ,p_agency_recvd_req_for_files     in	   date     default null
  ,p_files_due                      in	   date     default null
  ,p_files_forwd                    in     date     default null
  ,p_agency_brief_due               in	   date     default null
  ,p_agency_brief_forwd             in	   date     default null
  ,p_agency_recvd_appellant_brief   in	   date     default null
  ,p_decision_date                  in	   date     default null
  ,p_dec_recvd_by_agency            in     date     default null
  ,p_decision                       in     varchar2 default null
  ,p_dec_forwd_to_org               in 	   date     default null
  ,p_agency_rfr_suspense            in	   date     default null
  ,p_request_for_rfr                in	   date     default null
  ,p_rfr_docket_num                 in	   varchar2 default null
  ,p_rfr_requested_by               in	   varchar2 default null
  ,p_agency_rfr_due                 in	   date     default null
  ,p_rfr_forwd_to_org               in	   date     default null
  ,p_org_forwd_rfr_to_agency        in	   date     default null
  ,p_agency_forwd_rfr_ofo           in	   date     default null
  ,p_rfr_decision                   in     varchar2 default null
  ,p_rfr_decision_date              in     date     default null
  ,p_agency_recvd_rfr_dec           in     date     default null
  ,p_rfr_decision_forwd_to_org      in     date     default null
  ,p_compl_agency_appeal_id         out nocopy    number
  ,p_object_version_number          out nocopy    number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                      varchar2(72) := g_package||'create_agency_appeal';
  l_compl_agency_appeal_id    number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_agency_appeal;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_agency_appeals_bk_1.create_agency_appeal_b
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_appeal_date                    => p_appeal_date
      ,p_reason_for_appeal              => p_reason_for_appeal
      ,p_source_decision_date           => p_source_decision_date
      ,p_docket_num                     => p_docket_num
      ,p_agency_recvd_req_for_files     => p_agency_recvd_req_for_files
      ,p_files_due                      => p_files_due
      ,p_files_forwd                    => p_files_forwd
      ,p_agency_brief_due               => p_agency_brief_due
      ,p_agency_brief_forwd             => p_agency_brief_forwd
      ,p_agency_recvd_appellant_brief   => p_agency_recvd_appellant_brief
      ,p_decision_date                  => p_decision_date
      ,p_dec_recvd_by_agency            => p_dec_recvd_by_agency
      ,p_decision                       => p_decision
      ,p_dec_forwd_to_org               => p_dec_forwd_to_org
      ,p_agency_rfr_suspense            => p_agency_rfr_suspense
      ,p_request_for_rfr                => p_request_for_rfr
      ,p_rfr_docket_num                 => p_rfr_docket_num
      ,p_rfr_requested_by               => p_rfr_requested_by
      ,p_agency_rfr_due                 => p_agency_rfr_due
      ,p_rfr_forwd_to_org               => p_rfr_forwd_to_org
      ,p_org_forwd_rfr_to_agency        => p_org_forwd_rfr_to_agency
      ,p_agency_forwd_rfr_ofo           => p_agency_forwd_rfr_ofo
      ,p_rfr_decision                   => p_rfr_decision
      ,p_rfr_decision_date              => p_rfr_decision_date
      ,p_agency_recvd_rfr_dec           => p_agency_recvd_rfr_dec
      ,p_rfr_decision_forwd_to_org      => p_rfr_decision_forwd_to_org
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_agency_appeal'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  ghr_caa_ins.ins
  (
   p_effective_date                 => p_effective_date
  ,p_complaint_id                   => p_complaint_id
  ,p_appeal_date                    => p_appeal_date
  ,p_reason_for_appeal              => p_reason_for_appeal
  ,p_source_decision_date           => p_source_decision_date
  ,p_docket_num                     => p_docket_num
  ,p_agency_recvd_req_for_files     => p_agency_recvd_req_for_files
  ,p_files_due                      => p_files_due
  ,p_files_forwd                    => p_files_forwd
  ,p_agency_brief_due               => p_agency_brief_due
  ,p_agency_brief_forwd             => p_agency_brief_forwd
  ,p_agency_recvd_appellant_brief   => p_agency_recvd_appellant_brief
  ,p_decision_date                  => p_decision_date
  ,p_dec_recvd_by_agency            => p_dec_recvd_by_agency
  ,p_decision                       => p_decision
  ,p_dec_forwd_to_org               => p_dec_forwd_to_org
  ,p_agency_rfr_suspense            => p_agency_rfr_suspense
  ,p_request_for_rfr                => p_request_for_rfr
  ,p_rfr_docket_num                 => p_rfr_docket_num
  ,p_rfr_requested_by               => p_rfr_requested_by
  ,p_agency_rfr_due                 => p_agency_rfr_due
  ,p_rfr_forwd_to_org               => p_rfr_forwd_to_org
  ,p_org_forwd_rfr_to_agency        => p_org_forwd_rfr_to_agency
  ,p_agency_forwd_rfr_ofo           => p_agency_forwd_rfr_ofo
  ,p_rfr_decision                   => p_rfr_decision
  ,p_rfr_decision_date              => p_rfr_decision_date
  ,p_agency_recvd_rfr_dec           => p_agency_recvd_rfr_dec
  ,p_rfr_decision_forwd_to_org      => p_rfr_decision_forwd_to_org
  ,p_compl_agency_appeal_id         => l_compl_agency_appeal_id
  ,p_object_version_number          => l_object_version_number
  );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_agency_appeals_bk_1.create_agency_appeal_a
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_appeal_date                    => p_appeal_date
      ,p_reason_for_appeal              => p_reason_for_appeal
      ,p_source_decision_date           => p_source_decision_date
      ,p_docket_num                     => p_docket_num
      ,p_agency_recvd_req_for_files     => p_agency_recvd_req_for_files
      ,p_files_due                      => p_files_due
      ,p_files_forwd                    => p_files_forwd
      ,p_agency_brief_due               => p_agency_brief_due
      ,p_agency_brief_forwd             => p_agency_brief_forwd
      ,p_agency_recvd_appellant_brief   => p_agency_recvd_appellant_brief
      ,p_decision_date                  => p_decision_date
      ,p_dec_recvd_by_agency            => p_dec_recvd_by_agency
      ,p_decision                       => p_decision
      ,p_dec_forwd_to_org               => p_dec_forwd_to_org
      ,p_agency_rfr_suspense            => p_agency_rfr_suspense
      ,p_request_for_rfr                => p_request_for_rfr
      ,p_rfr_docket_num                 => p_rfr_docket_num
      ,p_rfr_requested_by               => p_rfr_requested_by
      ,p_agency_rfr_due                 => p_agency_rfr_due
      ,p_rfr_forwd_to_org               => p_rfr_forwd_to_org
      ,p_org_forwd_rfr_to_agency        => p_org_forwd_rfr_to_agency
      ,p_agency_forwd_rfr_ofo           => p_agency_forwd_rfr_ofo
      ,p_rfr_decision                   => p_rfr_decision
      ,p_rfr_decision_date              => p_rfr_decision_date
      ,p_agency_recvd_rfr_dec           => p_agency_recvd_rfr_dec
      ,p_rfr_decision_forwd_to_org      => p_rfr_decision_forwd_to_org
      ,p_compl_agency_appeal_id         => p_compl_agency_appeal_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_agency_appeal'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_compl_agency_appeal_id := l_compl_agency_appeal_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_agency_appeal;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_compl_agency_appeal_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_agency_appeal;
    p_compl_agency_appeal_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_agency_appeal;
--


procedure update_agency_appeal
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_compl_agency_appeal_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_complaint_id                 in     number    default hr_api.g_number
  ,p_appeal_date                  in     date      default hr_api.g_date
  ,p_reason_for_appeal            in     varchar2  default hr_api.g_varchar2
  ,p_source_decision_date         in     date      default hr_api.g_date
  ,p_docket_num                   in     varchar2  default hr_api.g_varchar2
  ,p_agency_recvd_req_for_files   in     date      default hr_api.g_date
  ,p_files_due                    in     date      default hr_api.g_date
  ,p_files_forwd                  in     date      default hr_api.g_date
  ,p_agency_brief_due             in     date      default hr_api.g_date
  ,p_agency_brief_forwd           in     date      default hr_api.g_date
  ,p_agency_recvd_appellant_brief in     date      default hr_api.g_date
  ,p_decision_date                in     date      default hr_api.g_date
  ,p_dec_recvd_by_agency          in     date      default hr_api.g_date
  ,p_decision                     in     varchar2  default hr_api.g_varchar2
  ,p_dec_forwd_to_org             in     date      default hr_api.g_date
  ,p_agency_rfr_suspense          in     date      default hr_api.g_date
  ,p_request_for_rfr              in     date      default hr_api.g_date
  ,p_rfr_docket_num               in     varchar2  default hr_api.g_varchar2
  ,p_rfr_requested_by             in     varchar2  default hr_api.g_varchar2
  ,p_agency_rfr_due               in     date      default hr_api.g_date
  ,p_rfr_forwd_to_org             in     date      default hr_api.g_date
  ,p_org_forwd_rfr_to_agency      in     date      default hr_api.g_date
  ,p_agency_forwd_rfr_ofo         in     date      default hr_api.g_date
  ,p_rfr_decision                 in     varchar2  default hr_api.g_varchar2
  ,p_rfr_decision_date            in     date      default hr_api.g_date
  ,p_agency_recvd_rfr_dec         in     date      default hr_api.g_date
  ,p_rfr_decision_forwd_to_org    in     date      default hr_api.g_date
)

is
  l_proc                  varchar2(72) := g_package||'update_agency_appeal';
  l_object_version_number number;
begin
hr_utility.set_location('Entering:'|| l_proc, 5);
  --
   savepoint update_agency_appeal;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_agency_appeals_bk_2.update_agency_appeal_b
      (p_effective_date                 => trunc(p_effective_date)
      ,p_compl_agency_appeal_id         => p_compl_agency_appeal_id
      ,p_complaint_id                   => p_complaint_id
      ,p_appeal_date                    => p_appeal_date
      ,p_reason_for_appeal              => p_reason_for_appeal
      ,p_source_decision_date           => p_source_decision_date
      ,p_docket_num                     => p_docket_num
      ,p_agency_recvd_req_for_files     => p_agency_recvd_req_for_files
      ,p_files_due                      => p_files_due
      ,p_files_forwd                    => p_files_forwd
      ,p_agency_brief_due               => p_agency_brief_due
      ,p_agency_brief_forwd             => p_agency_brief_forwd
      ,p_agency_recvd_appellant_brief   => p_agency_recvd_appellant_brief
      ,p_decision_date                  => p_decision_date
      ,p_dec_recvd_by_agency            => p_dec_recvd_by_agency
      ,p_decision                       => p_decision
      ,p_dec_forwd_to_org               => p_dec_forwd_to_org
      ,p_agency_rfr_suspense            => p_agency_rfr_suspense
      ,p_request_for_rfr                => p_request_for_rfr
      ,p_rfr_docket_num                 => p_rfr_docket_num
      ,p_rfr_requested_by               => p_rfr_requested_by
      ,p_agency_rfr_due                 => p_agency_rfr_due
      ,p_rfr_forwd_to_org               => p_rfr_forwd_to_org
      ,p_org_forwd_rfr_to_agency        => p_org_forwd_rfr_to_agency
      ,p_agency_forwd_rfr_ofo           => p_agency_forwd_rfr_ofo
      ,p_rfr_decision                   => p_rfr_decision
      ,p_rfr_decision_date              => p_rfr_decision_date
      ,p_agency_recvd_rfr_dec           => p_agency_recvd_rfr_dec
      ,p_rfr_decision_forwd_to_org      => p_rfr_decision_forwd_to_org
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_agency_appeal'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
 -- Store the original ovn in case we rollback when p_validate is true
 --
  l_object_version_number  := p_object_version_number;

  hr_utility.set_location(l_proc, 6);

  ghr_caa_upd.upd
  (p_effective_date                 => p_effective_date
  ,p_compl_agency_appeal_id         => p_compl_agency_appeal_id
  ,p_complaint_id                   => p_complaint_id
  ,p_appeal_date                    => p_appeal_date
  ,p_reason_for_appeal              => p_reason_for_appeal
  ,p_source_decision_date           => p_source_decision_date
  ,p_docket_num                     => p_docket_num
  ,p_agency_recvd_req_for_files     => p_agency_recvd_req_for_files
  ,p_files_due                      => p_files_due
  ,p_files_forwd                    => p_files_forwd
  ,p_agency_brief_due               => p_agency_brief_due
  ,p_agency_brief_forwd             => p_agency_brief_forwd
  ,p_agency_recvd_appellant_brief   => p_agency_recvd_appellant_brief
  ,p_decision_date                  => p_decision_date
  ,p_dec_recvd_by_agency            => p_dec_recvd_by_agency
  ,p_decision                       => p_decision
  ,p_dec_forwd_to_org               => p_dec_forwd_to_org
  ,p_agency_rfr_suspense            => p_agency_rfr_suspense
  ,p_request_for_rfr                => p_request_for_rfr
  ,p_rfr_docket_num                 => p_rfr_docket_num
  ,p_rfr_requested_by               => p_rfr_requested_by
  ,p_agency_rfr_due                 => p_agency_rfr_due
  ,p_rfr_forwd_to_org               => p_rfr_forwd_to_org
  ,p_org_forwd_rfr_to_agency        => p_org_forwd_rfr_to_agency
  ,p_agency_forwd_rfr_ofo           => p_agency_forwd_rfr_ofo
  ,p_rfr_decision                   => p_rfr_decision
  ,p_rfr_decision_date              => p_rfr_decision_date
  ,p_agency_recvd_rfr_dec           => p_agency_recvd_rfr_dec
  ,p_rfr_decision_forwd_to_org      => p_rfr_decision_forwd_to_org
  ,p_object_version_number          => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    ghr_agency_appeals_bk_2.update_agency_appeal_a
      (p_effective_date                 => trunc(p_effective_date)
      ,p_compl_agency_appeal_id         => p_compl_agency_appeal_id
      ,p_complaint_id                   => p_complaint_id
      ,p_appeal_date                    => p_appeal_date
      ,p_reason_for_appeal              => p_reason_for_appeal
      ,p_source_decision_date           => p_source_decision_date
      ,p_docket_num                     => p_docket_num
      ,p_agency_recvd_req_for_files     => p_agency_recvd_req_for_files
      ,p_files_due                      => p_files_due
      ,p_files_forwd                    => p_files_forwd
      ,p_agency_brief_due               => p_agency_brief_due
      ,p_agency_brief_forwd             => p_agency_brief_forwd
      ,p_agency_recvd_appellant_brief   => p_agency_recvd_appellant_brief
      ,p_decision_date                  => p_decision_date
      ,p_dec_recvd_by_agency            => p_dec_recvd_by_agency
      ,p_decision                       => p_decision
      ,p_dec_forwd_to_org               => p_dec_forwd_to_org
      ,p_agency_rfr_suspense            => p_agency_rfr_suspense
      ,p_request_for_rfr                => p_request_for_rfr
      ,p_rfr_docket_num                 => p_rfr_docket_num
      ,p_rfr_requested_by               => p_rfr_requested_by
      ,p_agency_rfr_due                 => p_agency_rfr_due
      ,p_rfr_forwd_to_org               => p_rfr_forwd_to_org
      ,p_org_forwd_rfr_to_agency        => p_org_forwd_rfr_to_agency
      ,p_agency_forwd_rfr_ofo           => p_agency_forwd_rfr_ofo
      ,p_rfr_decision                   => p_rfr_decision
      ,p_rfr_decision_date              => p_rfr_decision_date
      ,p_agency_recvd_rfr_dec           => p_agency_recvd_rfr_dec
      ,p_rfr_decision_forwd_to_org      => p_rfr_decision_forwd_to_org
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_agency_appeal'
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_agency_appeal;
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
    rollback to update_agency_appeal;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end update_agency_appeal;

-- ----------------------------------------------------------------------------
-- |-----------------------< delete_agency_appeal >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_agency_appeal
  (p_validate                      in     boolean  default false
  ,p_compl_agency_appeal_id        in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_agency_appeal';
  l_exists                boolean      := false;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  savepoint delete_agency_appeal;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_agency_appeals_bk_3.delete_agency_appeal_b
      (p_compl_agency_appeal_id            => p_compl_agency_appeal_id
      ,p_object_version_number             => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_agency_appeal'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

 -- Process Logic
   ghr_caa_del.del
    (p_compl_agency_appeal_id            => p_compl_agency_appeal_id
    ,p_object_version_number             => p_object_version_number
     );
 --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_agency_appeals_bk_3.delete_agency_appeal_a
      (p_compl_agency_appeal_id            => p_compl_agency_appeal_id
      ,p_object_version_number             => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_agency_appeal'
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_agency_appeal;
    --
  When Others then
    ROLLBACK TO delete_agency_appeal;
    raise;

  hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_agency_appeal;

end ghr_agency_appeals_api;

/
