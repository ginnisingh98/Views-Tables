--------------------------------------------------------
--  DDL for Package GHR_AGENCY_APPEALS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_AGENCY_APPEALS_BK_1" AUTHID CURRENT_USER as
/* $Header: ghcaaapi.pkh 120.1 2005/10/02 01:56:59 aroussel $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_agency_appeal_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_agency_appeal_b
  (p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_appeal_date                    in     date
  ,p_reason_for_appeal              in     varchar2
  ,p_source_decision_date           in     date
  ,p_docket_num                     in     varchar2
  ,p_agency_recvd_req_for_files     in     date
  ,p_files_due                      in     date
  ,p_files_forwd                    in     date
  ,p_agency_brief_due               in     date
  ,p_agency_brief_forwd             in     date
  ,p_agency_recvd_appellant_brief   in     date
  ,p_decision_date                  in     date
  ,p_dec_recvd_by_agency            in     date
  ,p_decision                       in     varchar2
  ,p_dec_forwd_to_org               in     date
  ,p_agency_rfr_suspense            in     date
  ,p_request_for_rfr                in     date
  ,p_rfr_docket_num                 in     varchar2
  ,p_rfr_requested_by               in     varchar2
  ,p_agency_rfr_due                 in     date
  ,p_rfr_forwd_to_org               in     date
  ,p_org_forwd_rfr_to_agency        in     date
  ,p_agency_forwd_rfr_ofo           in     date
  ,p_rfr_decision                   in     varchar2
  ,p_rfr_decision_date              in     date
  ,p_agency_recvd_rfr_dec           in     date
  ,p_rfr_decision_forwd_to_org      in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_agency_appeal_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_agency_appeal_a
  (p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_appeal_date                    in     date
  ,p_reason_for_appeal              in     varchar2
  ,p_source_decision_date           in     date
  ,p_docket_num                     in     varchar2
  ,p_agency_recvd_req_for_files     in     date
  ,p_files_due                      in     date
  ,p_files_forwd                    in     date
  ,p_agency_brief_due               in     date
  ,p_agency_brief_forwd             in     date
  ,p_agency_recvd_appellant_brief   in     date
  ,p_decision_date                  in     date
  ,p_dec_recvd_by_agency            in     date
  ,p_decision                       in     varchar2
  ,p_dec_forwd_to_org               in     date
  ,p_agency_rfr_suspense            in     date
  ,p_request_for_rfr                in     date
  ,p_rfr_docket_num                 in     varchar2
  ,p_rfr_requested_by               in     varchar2
  ,p_agency_rfr_due                 in     date
  ,p_rfr_forwd_to_org               in     date
  ,p_org_forwd_rfr_to_agency        in     date
  ,p_agency_forwd_rfr_ofo           in     date
  ,p_rfr_decision                   in     varchar2
  ,p_rfr_decision_date              in     date
  ,p_agency_recvd_rfr_dec           in     date
  ,p_rfr_decision_forwd_to_org      in     date
  ,p_compl_agency_appeal_id         in     number
  ,p_object_version_number          in     number
  );
--
end ghr_agency_appeals_bk_1;

 

/
