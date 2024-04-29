--------------------------------------------------------
--  DDL for Package HR_KI_INTEGRATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_INTEGRATIONS_SWI" AUTHID CURRENT_USER As
/* $Header: hrintswi.pkh 115.0 2004/01/09 01:41 vkarandi noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------------< validate_integration >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the servlet wrapper procedure to the following
--  API: hr_ki_integrations_api.validate_integration
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
PROCEDURE validate_integration
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_integration_id               in     number
  ,p_object_version_number        in out nocopy    number
  ,p_error                        out nocopy varchar2
  ,p_return_status                out nocopy varchar2
  );
--
end hr_ki_integrations_swi;

 

/
