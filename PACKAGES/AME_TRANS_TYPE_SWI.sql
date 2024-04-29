--------------------------------------------------------
--  DDL for Package AME_TRANS_TYPE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_TRANS_TYPE_SWI" AUTHID CURRENT_USER As
/* $Header: amacaswi.pkh 120.0 2005/09/02 03:47 mbocutt noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_ame_transaction_type >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_trans_type_api.create_ame_transaction_type
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
PROCEDURE create_ame_transaction_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_name             in     varchar2
  ,p_fnd_application_id           in     number
  ,p_transaction_type_id          in     varchar2  default null
  ,p_application_id               in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_ame_transaction_type >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_trans_type_api.update_ame_transaction_type
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
PROCEDURE update_ame_transaction_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_name             in     varchar2  default hr_api.g_varchar2
  ,p_transaction_type_id          in     varchar2  default hr_api.g_varchar2
  ,p_application_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ame_transaction_type >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_trans_type_api.delete_ame_transaction_type
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
PROCEDURE delete_ame_transaction_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end ame_trans_type_swi;

 

/
