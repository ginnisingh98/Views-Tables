--------------------------------------------------------
--  DDL for Package PER_QAT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QAT_RKI" AUTHID CURRENT_USER as
/* $Header: peqatrhi.pkh 120.0 2005/05/31 16:07:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end per_qat_rki;

 

/
