--------------------------------------------------------
--  DDL for Package GHR_CAH_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CAH_RKD" AUTHID CURRENT_USER as
/* $Header: ghcahrhi.pkh 120.0 2005/05/29 02:48:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
  procedure after_delete
  (p_compl_ca_header_id           in number
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
end ghr_cah_rkd;

 

/
