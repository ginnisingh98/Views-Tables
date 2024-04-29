--------------------------------------------------------
--  DDL for Package GHR_CST_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CST_RKD" AUTHID CURRENT_USER as
/* $Header: ghcstrhi.pkh 120.0 2005/05/29 03:05:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_compl_agency_cost_id         in number
  ,p_complaint_id_o                in number
  ,p_phase_o                       in varchar2
  ,p_stage_o                       in varchar2
  ,p_category_o                    in varchar2
  ,p_amount_o                      in number
  ,p_cost_date_o                   in date
  ,p_description_o                 in varchar2
  ,p_object_version_number_o       in number
  );
--
end ghr_cst_rkd;

 

/
