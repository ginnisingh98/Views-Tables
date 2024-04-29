--------------------------------------------------------
--  DDL for Package PQH_DOCUMENTS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOCUMENTS_SWI" AUTHID CURRENT_USER As
/* $Header: pqdocswi.pkh 120.1 2005/09/15 14:17:22 rthiagar noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_document >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_documents_api.create_document
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
  ,p_short_name                   in     varchar2
  ,p_document_name                in     varchar2
  ,p_file_id                      in     number
  ,p_formula_id                   in     number
  ,p_enable_flag                  in     varchar2
  ,p_document_category            in     varchar2
  ,p_document_id                     out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  /* Added for XDO changes */
  ,p_lob_code                     in     varchar2
  ,p_language                     in     varchar2
  ,p_territory                    in     varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_document >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_documents_api.delete_document
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
  ,p_datetrack_mode               in     varchar2
  ,p_document_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_document >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_documents_api.update_document
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
  ,p_datetrack_mode               in     varchar2
  ,p_short_name                   in     varchar2  default hr_api.g_varchar2
  ,p_document_name                in     varchar2  default hr_api.g_varchar2
  ,p_file_id                      in     number    default hr_api.g_number
  ,p_formula_id                   in     number    default hr_api.g_number
  ,p_enable_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_document_category          in     varchar2  default hr_api.g_varchar2
  ,p_document_id                  in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ,p_return_status                   out NOCOPY varchar2
  /* Added for XDO changes */
  ,p_lob_code                     in     varchar2
  ,p_language                     in     varchar2
  ,p_territory                    in     varchar2
  );
end pqh_documents_swi;

 

/
