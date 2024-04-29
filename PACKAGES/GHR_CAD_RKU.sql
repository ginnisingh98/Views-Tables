--------------------------------------------------------
--  DDL for Package GHR_CAD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CAD_RKU" AUTHID CURRENT_USER as
/* $Header: ghcadrhi.pkh 120.0 2005/05/29 02:47:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_compl_adr_id                 in number
  ,p_complaint_id                 in number
  ,p_stage                        in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_adr_resource                 in varchar2
  ,p_technique                    in varchar2
  ,p_outcome                      in varchar2
  ,p_adr_offered                  in varchar2
  ,p_date_accepted                in date
  ,p_object_version_number        in number
  ,p_complaint_id_o               in number
  ,p_stage_o                      in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_adr_resource_o               in varchar2
  ,p_technique_o                  in varchar2
  ,p_outcome_o                    in varchar2
  ,p_adr_offered_o                in varchar2
  ,p_date_accepted_o              in date
  ,p_object_version_number_o      in number
  );
--
end ghr_cad_rku;

 

/
