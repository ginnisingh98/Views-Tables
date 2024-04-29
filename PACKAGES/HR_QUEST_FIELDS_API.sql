--------------------------------------------------------
--  DDL for Package HR_QUEST_FIELDS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_FIELDS_API" AUTHID CURRENT_USER as
/* $Header: hrqsfapi.pkh 120.0 2005/05/31 02:27:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_quest_fields >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsf_ins.ins
--
-- Pre-requisites
--
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--
--  p_field_id  will contain newly generated one or surrogate value.
--  p_object_version_number will contain newly modified OVN.
--
--
-- Post Failure:
--
--    p_field_id  will contain null
--    p_object_version_number   will contain null
--
--
-- Access Status:
--
--  Internal Development use only.
--
-- {End of comments}
--

procedure insert_quest_fields
  (   p_validate                       in     boolean  default false
     ,p_effective_date                 in     date
     ,p_questionnaire_template_id      in     number
     ,p_name                           in     varchar2
     ,p_type                           in     varchar2
     ,p_sql_required_flag              in     varchar2
     ,p_html_text                      in     varchar2
     ,p_sql_text                       in     varchar2 default null
     ,p_field_id                          out nocopy number
     ,p_object_version_number             out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_quest_fields >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsf_upd.upd
--
-- Pre-requisites
--
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--
--  p_object_version_number will contain newly modified OVN.
--
--
-- Post Failure:
--
--    p_object_version_number  will contain unmodified OVN.
--
--
-- Access Status:
--
--  Internal Development use only.
--
-- {End of comments}
--

procedure update_quest_fields
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_field_id                     in     number
  ,p_object_version_number        in out nocopy number
  ,p_questionnaire_template_id    in     number   default hr_api.g_number
  ,p_name                         in     varchar2 default hr_api.g_varchar2
  ,p_type                         in     varchar2 default hr_api.g_varchar2
  ,p_sql_required_flag            in     varchar2 default hr_api.g_varchar2
  ,p_html_text                    in     varchar2 default hr_api.g_varchar2
  ,p_sql_text                     in     varchar2 default hr_api.g_varchar2
 );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_quest_fields >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsf_del.del
--
-- Pre-requisites
--
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--
--
--
-- Post Failure:
--
--
--
-- Access Status:
--
--  Internal Development use only.
--
-- {End of comments}
--

procedure delete_quest_fields
  (p_validate                             in     boolean  default false
  ,p_field_id                             in     number
  ,p_object_version_number                in     number
  );
--
end hr_quest_fields_api;

 

/
