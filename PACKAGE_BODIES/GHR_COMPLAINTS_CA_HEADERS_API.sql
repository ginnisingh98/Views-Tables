--------------------------------------------------------
--  DDL for Package Body GHR_COMPLAINTS_CA_HEADERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPLAINTS_CA_HEADERS_API" as
/* $Header: ghcahapi.pkb 115.2 2003/01/30 16:31:31 asubrahm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_complaints_ca_headers_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_ca_header >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ca_header
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_complaint_id                   in     number   default null
  ,p_ca_source                      in     varchar2 default null
  ,p_last_compliance_report         in     date     default null
  ,p_compliance_closed              in	   date     default null
  ,p_compl_docket_number            in	   varchar2 default null
  ,p_appeal_docket_number           in	   varchar2 default null
  ,p_pfe_docket_number              in	   varchar2 default null
  ,p_pfe_received                   in     date     default null
  ,p_agency_brief_pfe_due           in	   date     default null
  ,p_agency_brief_pfe_date          in	   date     default null
  ,p_decision_pfe_date              in	   date     default null
  ,p_decision_pfe                   in	   varchar2 default null
  ,p_agency_recvd_pfe_decision      in 	   date     default null
  ,p_agency_pfe_brief_forwd         in	   date     default null
  ,p_agency_notified_noncom         in	   date     default null
  ,p_comrep_noncom_req              in	   varchar2 default null
  ,p_eeo_off_req_data_from_org      in	   date     default null
  ,p_org_forwd_data_to_eeo_off      in	   date     default null
  ,p_dec_implemented                in	   date     default null
  ,p_complaint_reinstated           in	   date     default null
  ,p_stage_complaint_reinstated     in	   varchar2 default null
  ,p_compl_ca_header_id             out nocopy    number
  ,p_object_version_number          out nocopy    number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'create_ca_header';
  l_compl_ca_header_id    number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_ca_header;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaints_ca_headers_bk_1.create_ca_header_b
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_ca_source                      => p_ca_source
      ,p_last_compliance_report         => p_last_compliance_report
      ,p_compliance_closed              => p_compliance_closed
      ,p_compl_docket_number            => p_compl_docket_number
      ,p_appeal_docket_number           => p_appeal_docket_number
      ,p_pfe_docket_number              => p_pfe_docket_number
      ,p_pfe_received                   => p_pfe_received
      ,p_agency_brief_pfe_due           => p_agency_brief_pfe_due
      ,p_agency_brief_pfe_date          => p_agency_brief_pfe_date
      ,p_decision_pfe_date              => p_decision_pfe_date
      ,p_decision_pfe                   => p_decision_pfe
      ,p_agency_recvd_pfe_decision      => p_agency_recvd_pfe_decision
      ,p_agency_pfe_brief_forwd         => p_agency_pfe_brief_forwd
      ,p_agency_notified_noncom         => p_agency_notified_noncom
      ,p_comrep_noncom_req              => p_comrep_noncom_req
      ,p_eeo_off_req_data_from_org      => p_eeo_off_req_data_from_org
      ,p_org_forwd_data_to_eeo_off      => p_org_forwd_data_to_eeo_off
      ,p_dec_implemented                => p_dec_implemented
      ,p_complaint_reinstated           => p_complaint_reinstated
      ,p_stage_complaint_reinstated     => p_stage_complaint_reinstated
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ca_header'
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
  ghr_cah_ins.ins
  (
   p_effective_date                 => p_effective_date
  ,p_complaint_id                   => p_complaint_id
  ,p_ca_source                      => p_ca_source
  ,p_last_compliance_report         => p_last_compliance_report
  ,p_compliance_closed              => p_compliance_closed
  ,p_compl_docket_number            => p_compl_docket_number
  ,p_appeal_docket_number           => p_appeal_docket_number
  ,p_pfe_docket_number              => p_pfe_docket_number
  ,p_pfe_received                   => p_pfe_received
  ,p_agency_brief_pfe_due           => p_agency_brief_pfe_due
  ,p_agency_brief_pfe_date          => p_agency_brief_pfe_date
  ,p_decision_pfe_date              => p_decision_pfe_date
  ,p_decision_pfe                   => p_decision_pfe
  ,p_agency_recvd_pfe_decision      => p_agency_recvd_pfe_decision
  ,p_agency_pfe_brief_forwd         => p_agency_pfe_brief_forwd
  ,p_agency_notified_noncom         => p_agency_notified_noncom
  ,p_comrep_noncom_req              => p_comrep_noncom_req
  ,p_eeo_off_req_data_from_org      => p_eeo_off_req_data_from_org
  ,p_org_forwd_data_to_eeo_off      => p_org_forwd_data_to_eeo_off
  ,p_dec_implemented                => p_dec_implemented
  ,p_complaint_reinstated           => p_complaint_reinstated
  ,p_stage_complaint_reinstated     => p_stage_complaint_reinstated
  ,p_compl_ca_header_id             => l_compl_ca_header_id
  ,p_object_version_number          => l_object_version_number
  );
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaints_ca_headers_bk_1.create_ca_header_a
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_ca_source                      => p_ca_source
      ,p_last_compliance_report         => p_last_compliance_report
      ,p_compliance_closed              => p_compliance_closed
      ,p_compl_docket_number            => p_compl_docket_number
      ,p_appeal_docket_number           => p_appeal_docket_number
      ,p_pfe_docket_number              => p_pfe_docket_number
      ,p_pfe_received                   => p_pfe_received
      ,p_agency_brief_pfe_due           => p_agency_brief_pfe_due
      ,p_agency_brief_pfe_date          => p_agency_brief_pfe_date
      ,p_decision_pfe_date              => p_decision_pfe_date
      ,p_decision_pfe                   => p_decision_pfe
      ,p_agency_recvd_pfe_decision      => p_agency_recvd_pfe_decision
      ,p_agency_pfe_brief_forwd         => p_agency_pfe_brief_forwd
      ,p_agency_notified_noncom         => p_agency_notified_noncom
      ,p_comrep_noncom_req              => p_comrep_noncom_req
      ,p_eeo_off_req_data_from_org      => p_eeo_off_req_data_from_org
      ,p_org_forwd_data_to_eeo_off      => p_org_forwd_data_to_eeo_off
      ,p_dec_implemented                => p_dec_implemented
      ,p_complaint_reinstated           => p_complaint_reinstated
      ,p_stage_complaint_reinstated     => p_stage_complaint_reinstated
      ,p_compl_ca_header_id             => l_compl_ca_header_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ca_header'
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
  p_compl_ca_header_id     := l_compl_ca_header_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ca_header;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_compl_ca_header_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ca_header;
    -- RESET In/Out Params and Set Out Params
     p_compl_ca_header_id     := null;
     p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ca_header;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_ca_header >-----------------------------|
-- ----------------------------------------------------------------------------
--

procedure update_ca_header
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_compl_ca_header_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_complaint_id                 in     number    default hr_api.g_number
  ,p_ca_source                    in     varchar2  default hr_api.g_varchar2
  ,p_last_compliance_report       in     date      default hr_api.g_date
  ,p_compliance_closed            in     date      default hr_api.g_date
  ,p_compl_docket_number          in     varchar2  default hr_api.g_varchar2
  ,p_appeal_docket_number         in     varchar2  default hr_api.g_varchar2
  ,p_pfe_docket_number            in     varchar2  default hr_api.g_varchar2
  ,p_pfe_received                 in     date      default hr_api.g_date
  ,p_agency_brief_pfe_due         in     date      default hr_api.g_date
  ,p_agency_brief_pfe_date        in     date      default hr_api.g_date
  ,p_decision_pfe_date            in     date      default hr_api.g_date
  ,p_decision_pfe                 in     varchar2  default hr_api.g_varchar2
  ,p_agency_recvd_pfe_decision    in     date      default hr_api.g_date
  ,p_agency_pfe_brief_forwd       in     date      default hr_api.g_date
  ,p_agency_notified_noncom       in     date      default hr_api.g_date
  ,p_comrep_noncom_req            in     varchar2  default hr_api.g_varchar2
  ,p_eeo_off_req_data_from_org    in     date      default hr_api.g_date
  ,p_org_forwd_data_to_eeo_off    in     date      default hr_api.g_date
  ,p_dec_implemented              in     date      default hr_api.g_date
  ,p_complaint_reinstated         in     date      default hr_api.g_date
  ,p_stage_complaint_reinstated   in     varchar2  default hr_api.g_varchar2
 )

is
  l_proc                varchar2(72) := g_package||'update_ca_header';
  l_compl_ca_header_id    number;
  l_object_version_number number;
begin
hr_utility.set_location('Entering:'|| l_proc, 5);
  --
   savepoint update_ca_header;
  --
  -- Initialise Local Variables
     l_object_version_number:=p_object_version_number;

  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaints_ca_headers_bk_2.update_ca_header_b
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_ca_source                      => p_ca_source
      ,p_last_compliance_report         => p_last_compliance_report
      ,p_compliance_closed              => p_compliance_closed
      ,p_compl_docket_number            => p_compl_docket_number
      ,p_appeal_docket_number           => p_appeal_docket_number
      ,p_pfe_docket_number              => p_pfe_docket_number
      ,p_pfe_received                   => p_pfe_received
      ,p_agency_brief_pfe_due           => p_agency_brief_pfe_due
      ,p_agency_brief_pfe_date          => p_agency_brief_pfe_date
      ,p_decision_pfe_date              => p_decision_pfe_date
      ,p_decision_pfe                   => p_decision_pfe
      ,p_agency_recvd_pfe_decision      => p_agency_recvd_pfe_decision
      ,p_agency_pfe_brief_forwd         => p_agency_pfe_brief_forwd
      ,p_agency_notified_noncom         => p_agency_notified_noncom
      ,p_comrep_noncom_req              => p_comrep_noncom_req
      ,p_eeo_off_req_data_from_org      => p_eeo_off_req_data_from_org
      ,p_org_forwd_data_to_eeo_off      => p_org_forwd_data_to_eeo_off
      ,p_dec_implemented                => p_dec_implemented
      ,p_complaint_reinstated           => p_complaint_reinstated
      ,p_stage_complaint_reinstated     => p_stage_complaint_reinstated
      ,p_compl_ca_header_id             => p_compl_ca_header_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ca_header'
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

  ghr_cah_upd.upd
  (p_effective_date                 => p_effective_date
  ,p_complaint_id                   => p_complaint_id
  ,p_ca_source                      => p_ca_source
  ,p_last_compliance_report         => p_last_compliance_report
  ,p_compliance_closed              => p_compliance_closed
  ,p_compl_docket_number            => p_compl_docket_number
  ,p_appeal_docket_number           => p_appeal_docket_number
  ,p_pfe_docket_number              => p_pfe_docket_number
  ,p_pfe_received                   => p_pfe_received
  ,p_agency_brief_pfe_due           => p_agency_brief_pfe_due
  ,p_agency_brief_pfe_date          => p_agency_brief_pfe_date
  ,p_decision_pfe_date              => p_decision_pfe_date
  ,p_decision_pfe                   => p_decision_pfe
  ,p_agency_recvd_pfe_decision      => p_agency_recvd_pfe_decision
  ,p_agency_pfe_brief_forwd         => p_agency_pfe_brief_forwd
  ,p_agency_notified_noncom         => p_agency_notified_noncom
  ,p_comrep_noncom_req              => p_comrep_noncom_req
  ,p_eeo_off_req_data_from_org      => p_eeo_off_req_data_from_org
  ,p_org_forwd_data_to_eeo_off      => p_org_forwd_data_to_eeo_off
  ,p_dec_implemented                => p_dec_implemented
  ,p_complaint_reinstated           => p_complaint_reinstated
  ,p_stage_complaint_reinstated     => p_stage_complaint_reinstated
  ,p_compl_ca_header_id             => p_compl_ca_header_id
  ,p_object_version_number          => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaints_ca_headers_bk_2.update_ca_header_a
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_ca_source                      => p_ca_source
      ,p_last_compliance_report         => p_last_compliance_report
      ,p_compliance_closed              => p_compliance_closed
      ,p_compl_docket_number            => p_compl_docket_number
      ,p_appeal_docket_number           => p_appeal_docket_number
      ,p_pfe_docket_number              => p_pfe_docket_number
      ,p_pfe_received                   => p_pfe_received
      ,p_agency_brief_pfe_due           => p_agency_brief_pfe_due
      ,p_agency_brief_pfe_date          => p_agency_brief_pfe_date
      ,p_decision_pfe_date              => p_decision_pfe_date
      ,p_decision_pfe                   => p_decision_pfe
      ,p_agency_recvd_pfe_decision      => p_agency_recvd_pfe_decision
      ,p_agency_pfe_brief_forwd         => p_agency_pfe_brief_forwd
      ,p_agency_notified_noncom         => p_agency_notified_noncom
      ,p_comrep_noncom_req              => p_comrep_noncom_req
      ,p_eeo_off_req_data_from_org      => p_eeo_off_req_data_from_org
      ,p_org_forwd_data_to_eeo_off      => p_org_forwd_data_to_eeo_off
      ,p_dec_implemented                => p_dec_implemented
      ,p_complaint_reinstated           => p_complaint_reinstated
      ,p_stage_complaint_reinstated     => p_stage_complaint_reinstated
      ,p_compl_ca_header_id             => p_compl_ca_header_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ca_header'
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
    rollback to update_ca_header;
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
    rollback to update_ca_header;
    -- RESET In/Out Parameter
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end update_ca_header;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ca_header >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ca_header
  (p_validate                      in     boolean  default false
  ,p_compl_ca_header_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_ca_header';
  l_exists                boolean      := false;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  savepoint delete_ca_header;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaints_ca_headers_bk_3.delete_ca_header_b
      (p_compl_ca_header_id            => p_compl_ca_header_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ca_header'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
 -- Process Logic
   ghr_cah_del.del
    (p_compl_ca_header_id            => p_compl_ca_header_id
    ,p_object_version_number         => p_object_version_number
     );
 --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaints_ca_headers_bk_3.delete_ca_header_a
      (p_compl_ca_header_id            => p_compl_ca_header_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ca_header'
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
    ROLLBACK TO delete_ca_header;
    --
  When Others then
    ROLLBACK TO delete_ca_header;
    raise;

  hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_ca_header;
end ghr_complaints_ca_headers_api;


/
