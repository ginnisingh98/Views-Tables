--------------------------------------------------------
--  DDL for Package IRC_LINKED_CANDIDATES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LINKED_CANDIDATES_SWI" AUTHID CURRENT_USER As
/* $Header: irilcswi.pkh 120.0.12010000.1 2010/03/17 14:15:18 vmummidi noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_linked_candidate >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: IRC_LINKED_CANDIDATES_API.create_linked_candidate
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
PROCEDURE create_linked_candidate
  (p_validate                       in           number   default hr_api.g_false_num
  ,p_duplicate_set_id               in           number
  ,p_party_id                       in           number
  ,p_status                         in           varchar2
  ,p_target_party_id                in           number   default null
  ,p_link_id                        in           number
  ,p_object_version_number          out nocopy   number
  ,p_return_status                  out nocopy   varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_linked_candidate >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: IRC_LINKED_CANDIDATES_API.update_linked_candidate
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
PROCEDURE update_linked_candidate
  (p_validate                       in            number   default hr_api.g_false_num
  ,p_link_id                        in            number
  ,p_duplicate_set_id               in            number
  ,p_party_id                       in            number
  ,p_status                         in            varchar2
  ,p_target_party_id                in            number   default null
  ,p_object_version_number          in out nocopy number
  ,p_return_status                  out nocopy    varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_linked_candidate >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: IRC_LINKED_CANDIDATES_API.delete_linked_candidate
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
PROCEDURE delete_linked_candidate
  (p_validate                       in          number   default hr_api.g_false_num
  ,p_link_id                        in          number
  ,p_object_version_number          in          number
  ,p_return_status                  out nocopy  varchar2
  );
 end IRC_LINKED_CANDIDATES_SWI;

/
