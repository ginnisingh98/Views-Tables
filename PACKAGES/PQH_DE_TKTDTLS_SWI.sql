--------------------------------------------------------
--  DDL for Package PQH_DE_TKTDTLS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_TKTDTLS_SWI" AUTHID CURRENT_USER As
/* $Header: pqtktswi.pkh 115.1 2002/12/05 00:30:30 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_tkt_dtls >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_tktdtls_api.delete_tkt_dtls
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
PROCEDURE delete_tkt_dtls
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_tatigkeit_detail_id          in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< insert_tkt_dtls >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_tktdtls_api.insert_tkt_dtls
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
PROCEDURE insert_tkt_dtls
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_tatigkeit_number             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2
  ,p_tatigkeit_detail_id             out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_tkt_dtls >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_tktdtls_api.update_tkt_dtls
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
PROCEDURE update_tkt_dtls
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_tatigkeit_number             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_tatigkeit_detail_id          in     number
  ,p_object_version_number        in   out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end pqh_de_tktdtls_swi;

 

/
