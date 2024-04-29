--------------------------------------------------------
--  DDL for Package PSP_PEE_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PEE_EXT" AUTHID CURRENT_USER as
/* $Header: PSPEEEXS.pls 120.0 2006/01/31 22:44 dpaudel noship $ */

Procedure insert_external_eff_line_ext
( p_batch_name                   in             varchar2
, p_distribution_date            in             date
, p_person_id                    in             number
, p_assignment_id                in             number
, p_currency_code                in             varchar2
, p_distribution_amount          in             number
, p_business_group_id            in             number
, p_set_of_books_id              in             number
, p_gl_code_combination_id       in             number
, p_project_id                   in             number
, p_task_id                      in             number
, p_award_id                     in             number
, p_expenditure_organization_id  in             number
, p_expenditure_type             in             varchar2
, p_attribute_category           in             varchar2
, p_attribute1                   in             varchar2
, p_attribute2                   in             varchar2
, p_attribute3                   in             varchar2
, p_attribute4                   in             varchar2
, p_attribute5                   in             varchar2
, p_attribute6                   in             varchar2
, p_attribute7                   in             varchar2
, p_attribute8                   in             varchar2
, p_attribute9                   in             varchar2
, p_attribute10                  in             varchar2
, p_attribute11                  in             varchar2
, p_attribute12                  in             varchar2
, p_attribute13                  in             varchar2
, p_attribute14                  in             varchar2
, p_attribute15                  in             varchar2
);

Procedure update_external_eff_line_ext
( p_external_effort_line_id      in             number
, p_batch_name                   in             varchar2
, p_distribution_date            in             date
, p_person_id                    in             number
, p_assignment_id                in             number
, p_currency_code                in             varchar2
, p_distribution_amount          in             number
, p_business_group_id            in             number
, p_set_of_books_id              in             number
, p_gl_code_combination_id       in             number
, p_project_id                   in             number
, p_task_id                      in             number
, p_award_id                     in             number
, p_expenditure_organization_id  in             number
, p_expenditure_type             in             varchar2
, p_attribute_category           in             varchar2
, p_attribute1                   in             varchar2
, p_attribute2                   in             varchar2
, p_attribute3                   in             varchar2
, p_attribute4                   in             varchar2
, p_attribute5                   in             varchar2
, p_attribute6                   in             varchar2
, p_attribute7                   in             varchar2
, p_attribute8                   in             varchar2
, p_attribute9                   in             varchar2
, p_attribute10                  in             varchar2
, p_attribute11                  in             varchar2
, p_attribute12                  in             varchar2
, p_attribute13                  in             varchar2
, p_attribute14                  in             varchar2
, p_attribute15                  in             varchar2
, p_object_version_number        in             number
);

Procedure delete_external_eff_line_ext
( p_external_effort_line_id      in             number
, p_object_version_number        in             number
);

END PSP_PEE_EXT;

 

/