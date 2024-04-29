--------------------------------------------------------
--  DDL for Package PER_PCL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PCL_RKD" AUTHID CURRENT_USER as
/* $Header: pepclrhi.pkh 120.0 2005/05/31 13:01:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_cagr_entitlement_line_id     in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_cagr_entitlement_id_o        in number
  ,p_mandatory_o                  in varchar2
  ,p_value_o                      in varchar2
  ,p_range_from_o                 in varchar2
  ,p_range_to_o                   in varchar2
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_parent_spine_id_o            in number
  ,p_step_id_o                    in number
  ,p_from_step_id_o               in number
  ,p_to_step_id_o                 in number
  ,p_status_o                     in varchar2
  ,p_oipl_id_o                    in number
  ,p_object_version_number_o      in number
  ,p_grade_spine_id_o             in number
  ,p_eligy_prfl_id_o              in number
  );
--
end per_pcl_rkd;

 

/
