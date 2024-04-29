--------------------------------------------------------
--  DDL for Package PQH_DOCUMENTS_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOCUMENTS_WRAPPER" AUTHID CURRENT_USER As
/* $Header: pqdocwrp.pkh 115.2 2003/04/14 12:28:31 svorugan noship $*/
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
-- The delete_document delets all child records then deletes Master record
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default trunc(sysdate)
  ,p_datetrack_mode               in     varchar2
  ,p_document_id                  in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ,p_return_status                   out NOCOPY varchar2
  );
end pqh_documents_wrapper;

 

/
