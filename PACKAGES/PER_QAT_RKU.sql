--------------------------------------------------------
--  DDL for Package PER_QAT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QAT_RKU" AUTHID CURRENT_USER as
/* $Header: peqatrhi.pkh 120.0 2005/05/31 16:07:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_qualification_id             in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_title                        in varchar2
  ,p_group_ranking                in varchar2
  ,p_license_restrictions         in varchar2
  ,p_awarding_body                in varchar2
  ,p_grade_attained               in varchar2
  ,p_reimbursement_arrangements   in varchar2
  ,p_training_completed_units     in varchar2
  ,p_membership_category          in varchar2
  ,p_source_lang_o                in varchar2
  ,p_title_o                      in varchar2
  ,p_group_ranking_o              in varchar2
  ,p_license_restrictions_o       in varchar2
  ,p_awarding_body_o              in varchar2
  ,p_grade_attained_o             in varchar2
  ,p_reimbursement_arrangements_o in varchar2
  ,p_training_completed_units_o   in varchar2
  ,p_membership_category_o        in varchar2
  );
--
end per_qat_rku;

 

/
