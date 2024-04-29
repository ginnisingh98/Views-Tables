--------------------------------------------------------
--  DDL for Package PSP_POA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_POA_RKI" AUTHID CURRENT_USER as
/* $Header: PSPOARHS.pls 120.0 2005/11/20 23:57 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_organization_account_id      in number
  ,p_gl_code_combination_id       in number
  ,p_project_id                   in number
  ,p_expenditure_organization_id  in number
  ,p_expenditure_type             in varchar2
  ,p_task_id                      in number
  ,p_award_id                     in number
  ,p_comments                     in varchar2
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
  ,p_set_of_books_id              in number
  ,p_account_type_code            in varchar2
  ,p_start_date_active            in date
  ,p_business_group_id            in number
  ,p_end_date_active              in date
  ,p_organization_id              in number
  ,p_poeta_start_date             in date
  ,p_poeta_end_date               in date
  ,p_object_version_number        in number
  ,p_funding_source_code          in varchar2
  );
end psp_poa_rki;

 

/
