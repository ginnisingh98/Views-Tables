--------------------------------------------------------
--  DDL for Package GHR_CAD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CAD_RKD" AUTHID CURRENT_USER as
/* $Header: ghcadrhi.pkh 120.0 2005/05/29 02:47:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_compl_adr_id               in number
  ,p_complaint_id_o             in number
  ,p_stage_o                    in varchar2
  ,p_start_date_o               in date
  ,p_end_date_o                 in date
  ,p_adr_resource_o             in varchar2
  ,p_technique_o                in varchar2
  ,p_outcome_o                  in varchar2
  ,p_adr_offered_o              in varchar2
  ,p_date_accepted_o            in date
  ,p_object_version_number_o    in number
  );
--
end ghr_cad_rkd;

 

/
