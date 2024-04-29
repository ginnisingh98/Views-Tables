--------------------------------------------------------
--  DDL for Package PSP_ORGANIZATION_ACCOUNTS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ORGANIZATION_ACCOUNTS_SWI" AUTHID CURRENT_USER As
/* $Header: PSPOASWS.pls 120.0 2005/11/20 23:57 dpaudel noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_organization_account >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_organization_accounts_api.create_organization_account
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_organization_account
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_gl_code_combination_id       in     number
  ,p_project_id                   in     number
  ,p_expenditure_organization_id  in     number
  ,p_expenditure_type             in     varchar2
  ,p_task_id                      in     number
  ,p_award_id                     in     number
  ,p_comments                     in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_account_type_code            in     varchar2
  ,p_start_date_active            in     date
  ,p_business_group_id            in     number
  ,p_end_date_active              in     date
  ,p_organization_id              in     number
  ,p_poeta_start_date             in     date  default null
  ,p_poeta_end_date               in     date  default null
  ,p_funding_source_code          in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_organization_account_id      in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_organization_account >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_organization_accounts_api.delete_organization_account
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_organization_account
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_account_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_organization_account >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_organization_accounts_api.update_organization_account
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_organization_account
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_account_id      in     number
  ,p_gl_code_combination_id       in     number
  ,p_project_id                   in     number
  ,p_expenditure_organization_id  in     number
  ,p_expenditure_type             in     varchar2
  ,p_task_id                      in     number
  ,p_award_id                     in     number
  ,p_comments                     in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_account_type_code            in     varchar2
  ,p_start_date_active            in     date
  ,p_business_group_id            in     number
  ,p_end_date_active              in     date
  ,p_organization_id              in     number
  ,p_poeta_start_date             in     date  default null
  ,p_poeta_end_date               in     date  default null
  ,p_funding_source_code          in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
 end psp_organization_accounts_swi;

 

/
