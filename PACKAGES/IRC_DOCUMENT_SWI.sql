--------------------------------------------------------
--  DDL for Package IRC_DOCUMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DOCUMENT_SWI" AUTHID CURRENT_USER As
/* $Header: iridoswi.pkh 120.0.12000000.2 2007/03/23 10:39:05 vboggava noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_document >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_document_api.create_document
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
PROCEDURE create_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_type                         in     varchar2
  ,p_person_id                    in     number
  ,p_mime_type                    in     varchar2
  ,p_assignment_id                in     number    default null
  ,p_file_name                    in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_document_id                  in     number
  ,p_end_date			  in     date     default null
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_document >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_document_api.delete_document
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
PROCEDURE delete_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_object_version_number        in     number
  ,p_person_id                    in     number
  ,p_party_id			  in	 number
  ,p_end_date			  In     Date
  ,p_type                         in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_document >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_document_api.update_document
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
PROCEDURE update_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_mime_type                    in     varchar2  default hr_api.g_varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_file_name                    in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_person_id			  In     number	   default hr_api.g_number
  ,p_party_id			  in	 number    default hr_api.g_number
  ,p_end_date			  In     Date      default hr_api.g_date
  ,p_assignment_id		  In     number	   default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_new_doc_id			  out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end irc_document_swi;

 

/
