--------------------------------------------------------
--  DDL for Package GHR_CAH_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CAH_RKU" AUTHID CURRENT_USER as
/* $Header: ghcahrhi.pkh 120.0 2005/05/29 02:48:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
  procedure after_update
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
  ,p_complaint_id_o               in number
  ,p_ca_source_o                  in varchar2
  ,p_last_compliance_report_o     in date
  ,p_compliance_closed_o          in date
  ,p_compl_docket_number_o        in varchar2
  ,p_appeal_docket_number_o       in varchar2
  ,p_pfe_docket_number_o          in varchar2
  ,p_pfe_received_o               in date
  ,p_agency_brief_pfe_due_o       in date
  ,p_agency_brief_pfe_date_o      in date
  ,p_decision_pfe_date_o          in date
  ,p_decision_pfe_o               in varchar2
  ,p_agency_recvd_pfe_decision_o  in date
  ,p_agency_pfe_brief_forwd_o     in date
  ,p_agency_notified_noncom_o     in date
  ,p_comrep_noncom_req_o          in varchar2
  ,p_eeo_off_req_data_from_org_o  in date
  ,p_org_forwd_data_to_eeo_off_o  in date
  ,p_dec_implemented_o            in date
  ,p_complaint_reinstated_o       in date
  ,p_stage_complaint_reinstated_o in varchar2
  ,p_object_version_number_o      in number
  );
--
end ghr_cah_rku;

 

/
