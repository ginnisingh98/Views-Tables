--------------------------------------------------------
--  DDL for Package GHR_CAA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CAA_RKI" AUTHID CURRENT_USER as
/* $Header: ghcaarhi.pkh 120.0 2005/05/29 02:47:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_compl_agency_appeal_id       in number
  ,p_complaint_id                 in number
  ,p_appeal_date                  in date
  ,p_reason_for_appeal            in varchar2
  ,p_source_decision_date         in date
  ,p_docket_num                   in varchar2
  ,p_agency_recvd_req_for_files   in date
  ,p_files_due                    in date
  ,p_files_forwd                  in date
  ,p_agency_brief_due             in date
  ,p_agency_brief_forwd           in date
  ,p_agency_recvd_appellant_brief in date
  ,p_decision_date                in date
  ,p_dec_recvd_by_agency          in date
  ,p_decision                     in varchar2
  ,p_dec_forwd_to_org             in date
  ,p_agency_rfr_suspense          in date
  ,p_request_for_rfr              in date
  ,p_rfr_docket_num               in varchar2
  ,p_rfr_requested_by             in varchar2
  ,p_agency_rfr_due               in date
  ,p_rfr_forwd_to_org             in date
  ,p_org_forwd_rfr_to_agency      in date
  ,p_agency_forwd_rfr_ofo         in date
  ,p_rfr_decision_date            in date
  ,p_agency_recvd_rfr_dec         in date
  ,p_rfr_decision_forwd_to_org    in date
  ,p_rfr_decision                 in varchar2
  ,p_object_version_number        in number
  );
end ghr_caa_rki;

 

/
