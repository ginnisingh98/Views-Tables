--------------------------------------------------------
--  DDL for Package PQH_DOCUMENT_ATTRIBUTES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOCUMENT_ATTRIBUTES_SWI" AUTHID CURRENT_USER As
/* $Header: pqdoaswi.pkh 115.1 2003/03/06 20:36:27 nsanghal noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_document_attribute >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_document_attributes_api.create_document_attribute
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
PROCEDURE create_document_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_attribute_id                 in     number
  ,p_tag_name                     in     varchar2
  ,p_document_attribute_id           out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_document_attribute >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_document_attributes_api.delete_document_attribute
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
PROCEDURE delete_document_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_document_attribute_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_document_attribute >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_document_attributes_api.update_document_attribute
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
PROCEDURE update_document_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_document_attribute_id        in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_document_id                  in     number    default hr_api.g_number
  ,p_attribute_id                 in     number    default hr_api.g_number
  ,p_tag_name                     in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ,p_return_status                   out NOCOPY varchar2
  );
end pqh_document_attributes_swi;

 

/
