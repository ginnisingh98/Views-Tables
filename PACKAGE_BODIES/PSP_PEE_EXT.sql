--------------------------------------------------------
--  DDL for Package Body PSP_PEE_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PEE_EXT" AS
/* $Header: PSPEEEXB.pls 120.0 2006/01/31 22:44 dpaudel noship $ */
-- WARNING:
--          Please note that any PL/SQL statements that cause Commit/Rollback
--          are not allowed in the user extension code. Commit/Rollback's
--          will interfere with the Commit cycle of the main
--          process and Restart/Recover process will not work properly.
--
--         ------------------------------------------------------
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
) IS
BEGIN
  NULL;
  -- EDIT:Add your code here
EXCEPTION
  WHEN others THEN
    fnd_msg_pub.add_exc_msg('PSP_PEE_EXT','INSERT_EXTERNAL_EFF_LINE_EXT');
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
END;

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
)IS
BEGIN
  NULL;
  -- EDIT:Add your code here
EXCEPTION
  WHEN others THEN
    fnd_msg_pub.add_exc_msg('PSP_PEE_EXT','UPDATE_EXTERNAL_EFF_LINE_EXT');
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
END;

Procedure delete_external_eff_line_ext
( p_external_effort_line_id      in             number
, p_object_version_number        in             number
)IS
BEGIN
  NULL;
  -- EDIT:Add your code here
EXCEPTION
  WHEN others THEN
    fnd_msg_pub.add_exc_msg('PSP_PEE_EXT','DELETE_EXTERNAL_EFF_LINE_EXT');
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
END;

END PSP_PEE_EXT;

/
