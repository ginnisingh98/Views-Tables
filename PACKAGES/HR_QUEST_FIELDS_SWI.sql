--------------------------------------------------------
--  DDL for Package HR_QUEST_FIELDS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_FIELDS_SWI" AUTHID CURRENT_USER As
/* $Header: hrqsfswi.pkh 120.0 2005/05/31 02:28:32 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_quest_fields >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_quest_fields_api.insert_quest_fields
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
PROCEDURE insert_quest_fields
  (p_field_id                     in	 number
  ,p_questionnaire_template_id    in     number
  ,p_name                         in     varchar2
  ,p_type                         in     varchar2
  ,p_html_text                    in     varchar2
  ,p_sql_required_flag            in     varchar2
  ,p_sql_text                     in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        out    nocopy number
  ,p_effective_date               in     date
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                out	 nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< update_quest_fields >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_quest_fields_api.update_quest_fields
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
PROCEDURE update_quest_fields
  (p_field_id                     in     number
  ,p_sql_text                     in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                out	 nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_quest_fields >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_quest_fields_api.delete_quest_fields
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
PROCEDURE delete_quest_fields
  (p_field_id                     in     number
  ,p_object_version_number        in     number
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                out	 nocopy varchar2
  );

PROCEDURE delete_quest_fields
  (p_field_id                     in     number
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                out	 nocopy varchar2
  );

end hr_quest_fields_swi;

 

/
