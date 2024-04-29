--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_SWI" AUTHID CURRENT_USER As
/* $Header: pypucswi.pkh 120.0 2005/05/29 07:59 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_user_column >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_user_column_api.create_user_column
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
PROCEDURE create_user_column
  (
   p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_user_table_id                in     number
  ,p_formula_id                   in     number    default null
  ,p_user_column_name             in     varchar2
  ,p_user_column_id                  out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2

  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_user_column >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_user_column_api.update_user_column
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
PROCEDURE update_user_column
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_user_column_id               in     number
  ,p_user_column_name             in     varchar2  default hr_api.g_varchar2
  ,p_formula_id                   in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2

  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_user_column >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_user_column_api.delete_user_column
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
PROCEDURE delete_user_column
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_user_column_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2

  );
 end pay_user_column_swi;

 

/
