--------------------------------------------------------
--  DDL for Package GHR_CCL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CCL_RKU" AUTHID CURRENT_USER as
/* $Header: ghcclrhi.pkh 120.0 2005/05/29 02:50:51 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_compl_claim_id               in number
  ,p_complaint_id                 in number
  ,p_claim                        in varchar2
  ,p_incident_date                in date
  ,p_phase                        in varchar2
  ,p_mixed_flag                   in varchar2
  ,p_claim_source                 in varchar2
  ,p_agency_acceptance            in varchar2
  ,p_aj_acceptance                in varchar2
  ,p_agency_appeal                in varchar2
  ,p_complaint_id_o               in number
  ,p_claim_o                      in varchar2
  ,p_incident_date_o              in date
  ,p_phase_o                      in varchar2
  ,p_mixed_flag_o                 in varchar2
  ,p_claim_source_o               in varchar2
  ,p_agency_acceptance_o          in varchar2
  ,p_aj_acceptance_o              in varchar2
  ,p_agency_appeal_o              in varchar2
  );
--
end ghr_ccl_rku;

 

/
