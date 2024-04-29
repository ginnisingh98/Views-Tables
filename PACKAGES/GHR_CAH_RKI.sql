--------------------------------------------------------
--  DDL for Package GHR_CAH_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CAH_RKI" AUTHID CURRENT_USER as
/* $Header: ghcahrhi.pkh 120.0 2005/05/29 02:48:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
  procedure after_insert
  (p_effective_date               in date
  ,p_compl_ca_header_id           in number
  ,p_complaint_id                 in number
  ,p_ca_source                    in varchar2
  ,p_last_compliance_report       in date
  ,p_compliance_closed            in date
  ,p_compl_docket_number          in varchar2
  ,p_appeal_docket_number         in varchar2
  ,p_pfe_docket_number            in varchar2
  ,p_pfe_received                 in date
  ,p_agency_brief_pfe_due         in date
  ,p_agency_brief_pfe_date        in date
  ,p_decision_pfe_date            in date
  ,p_decision_pfe                 in varchar2
  ,p_agency_recvd_pfe_decision    in date
  ,p_agency_pfe_brief_forwd       in date
  ,p_agency_notified_noncom       in date
  ,p_comrep_noncom_req            in varchar2
  ,p_eeo_off_req_data_from_org    in date
  ,p_org_forwd_data_to_eeo_off    in date
  ,p_dec_implemented              in date
  ,p_complaint_reinstated         in date
  ,p_stage_complaint_reinstated   in varchar2
  ,p_object_version_number        in number
  );
end ghr_cah_rki;

 

/
