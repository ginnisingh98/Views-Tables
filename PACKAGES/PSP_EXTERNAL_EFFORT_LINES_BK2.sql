--------------------------------------------------------
--  DDL for Package PSP_EXTERNAL_EFFORT_LINES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EXTERNAL_EFFORT_LINES_BK2" AUTHID CURRENT_USER AS
/* $Header: PSPEEAIS.pls 120.3 2006/07/06 13:25:21 tbalacha noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< update_external_effort_line_b >------------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE update_external_effort_line_b
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

--
-- ----------------------------------------------------------------------------
-- |----------------------< update_external_effort_line_a >------------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE update_external_effort_line_a
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
, p_return_status                in             boolean
);
END psp_external_effort_lines_bk2;

/
