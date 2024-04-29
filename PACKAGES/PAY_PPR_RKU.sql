--------------------------------------------------------
--  DDL for Package PAY_PPR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPR_RKU" AUTHID CURRENT_USER as
/* $Header: pypprrhi.pkh 120.0 2005/05/29 07:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_status_processing_rule_id    in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_element_type_id              in number
  ,p_assignment_status_type_id    in number
  ,p_formula_id                   in number
  ,p_comment_id                   in number
  ,p_comments                     in varchar2
  ,p_legislation_subgroup         in varchar2
  ,p_object_version_number        in number
  ,p_formula_mismatch_warning     in boolean
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_element_type_id_o            in number
  ,p_assignment_status_type_id_o  in number
  ,p_formula_id_o                 in number
  ,p_processing_rule_o            in varchar2
  ,p_comment_id_o                 in number
  ,p_comments_o                   in varchar2
  ,p_legislation_subgroup_o       in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_ppr_rku;

 

/
