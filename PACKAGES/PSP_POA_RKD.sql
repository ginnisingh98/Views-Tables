--------------------------------------------------------
--  DDL for Package PSP_POA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_POA_RKD" AUTHID CURRENT_USER as
/* $Header: PSPOARHS.pls 120.0 2005/11/20 23:57 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_organization_account_id      in number
  ,p_gl_code_combination_id_o     in number
  ,p_project_id_o                 in number
  ,p_expenditure_organization_i_o in number
  ,p_expenditure_type_o           in varchar2
  ,p_task_id_o                    in number
  ,p_award_id_o                   in number
  ,p_comments_o                   in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_set_of_books_id_o            in number
  ,p_account_type_code_o          in varchar2
  ,p_start_date_active_o          in date
  ,p_business_group_id_o          in number
  ,p_end_date_active_o            in date
  ,p_organization_id_o            in number
  ,p_poeta_start_date_o           in date
  ,p_poeta_end_date_o             in date
  ,p_object_version_number_o      in number
  ,p_funding_source_code_o        in varchar2
  );
--
end psp_poa_rkd;

 

/