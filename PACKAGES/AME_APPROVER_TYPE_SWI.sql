--------------------------------------------------------
--  DDL for Package AME_APPROVER_TYPE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_TYPE_SWI" AUTHID CURRENT_USER As
/* $Header: amaptswi.pkh 120.1 2006/04/21 08:37 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_approver_type >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_approver_type_api.create_ame_approver_type
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
PROCEDURE create_ame_approver_type
  (p_validate                  in           number   default hr_api.g_false_num
  ,p_orig_system               in           varchar2
  ,p_approver_type_id          in           number
  ,p_object_version_number     out nocopy   number
  ,p_start_date                out nocopy   date
  ,p_end_date                  out nocopy   date
  ,p_return_status             out nocopy   varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ame_approver_type >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_approver_api.delete_ame_approver_type
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
PROCEDURE delete_ame_approver_type
  (p_validate                in              number   default hr_api.g_false_num
  ,p_approver_type_id        in              number
  ,p_object_version_number   in out nocopy   number
  ,p_start_date                 out nocopy   date
  ,p_end_date                   out nocopy   date
  ,p_return_status              out nocopy   varchar2
  );
 end ame_approver_type_swi;

 

/
