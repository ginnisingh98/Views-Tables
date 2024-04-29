--------------------------------------------------------
--  DDL for Package GHR_CAA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CAA_RKD" AUTHID CURRENT_USER as
/* $Header: ghcaarhi.pkh 120.0 2005/05/29 02:47:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_compl_agency_appeal_id       in number
  ,p_complaint_id_o               in number
  ,p_appeal_date_o                in date
  ,p_reason_for_appeal_o          in varchar2
  ,p_source_decision_date_o       in date
  ,p_docket_num_o                 in varchar2
  ,p_agency_recvd_req_for_files_o in date
  ,p_files_due_o                  in date
  ,p_files_forwd_o                in date
  ,p_agency_brief_due_o           in date
  ,p_agency_brief_forwd_o         in date
  ,p_agency_recvd_appellant_bri_o in date
  ,p_decision_date_o              in date
  ,p_dec_recvd_by_agency_o        in date
  ,p_decision_o                   in varchar2
  ,p_dec_forwd_to_org_o           in date
  ,p_agency_rfr_suspense_o        in date
  ,p_request_for_rfr_o            in date
  ,p_rfr_docket_num_o             in varchar2
  ,p_rfr_requested_by_o           in varchar2
  ,p_agency_rfr_due_o             in date
  ,p_rfr_forwd_to_org_o           in date
  ,p_org_forwd_rfr_to_agency_o    in date
  ,p_agency_forwd_rfr_ofo_o       in date
  ,p_rfr_decision_date_o          in date
  ,p_agency_recvd_rfr_dec_o       in date
  ,p_rfr_decision_forwd_to_org_o  in date
  ,p_rfr_decision_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end ghr_caa_rkd;

 

/
