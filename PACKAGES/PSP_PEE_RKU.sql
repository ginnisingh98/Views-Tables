--------------------------------------------------------
--  DDL for Package PSP_PEE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PEE_RKU" AUTHID CURRENT_USER as
/* $Header: PSPEERHS.pls 120.0 2006/01/31 22:43 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_external_effort_line_id      in number
  ,p_batch_name                   in varchar2
  ,p_object_version_number        in number
  ,p_distribution_date            in date
  ,p_person_id                    in number
  ,p_assignment_id                in number
  ,p_currency_code                in varchar2
  ,p_distribution_amount          in number
  ,p_business_group_id            in number
  ,p_set_of_books_id              in number
  ,p_gl_code_combination_id       in number
  ,p_project_id                   in number
  ,p_task_id                      in number
  ,p_award_id                     in number
  ,p_expenditure_organization_id  in number
  ,p_expenditure_type             in varchar2
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_batch_name_o                 in varchar2
  ,p_object_version_number_o      in number
  ,p_distribution_date_o          in date
  ,p_person_id_o                  in number
  ,p_assignment_id_o              in number
  ,p_currency_code_o              in varchar2
  ,p_distribution_amount_o        in number
  ,p_business_group_id_o          in number
  ,p_set_of_books_id_o            in number
  ,p_gl_code_combination_id_o     in number
  ,p_project_id_o                 in number
  ,p_task_id_o                    in number
  ,p_award_id_o                   in number
  ,p_expenditure_organization_i_o in number
  ,p_expenditure_type_o           in varchar2
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
  );
--
end psp_pee_rku;

 

/
