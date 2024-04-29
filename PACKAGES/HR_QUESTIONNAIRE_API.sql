--------------------------------------------------------
--  DDL for Package HR_QUESTIONNAIRE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUESTIONNAIRE_API" AUTHID CURRENT_USER as
/* $Header: hrqsnapi.pkh 120.1 2005/09/09 02:11:47 pveerepa noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_questionnaire >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsn_ins.ins
--
-- Pre-requisites
--
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--
--  p_object_version_number     will have the latest OVN.
--  p_questionnaire_template_id with have the newly generated and passed surrogate value.
--
-- Post Failure:
--
--  p_object_version_number     will be  null.
--  p_questionnaire_template_id with be null.
--
--
-- Access Status:
--
--  Internal Development use only.
--
-- {End of comments}
--
procedure create_questionnaire
  (
   p_validate              	    in     boolean   default false
  ,p_name                           in     varchar2
  ,p_available_flag                 in     varchar2
  ,p_business_group_id              in     number
  ,p_text                           in     CLOB
  ,p_effective_date                 in     date
  ,p_questionnaire_template_id         out nocopy number
  ,p_object_version_number             out nocopy number
  );


--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_questionnaire >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsn_upd.upd
--
-- Pre-requisites
--
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:

--  p_object_version_number  will contain latest OVN.
--
-- Post Failure:

--  p_object_version_number with the old one.
--
-- Access Status:
--
--  Internal Development use only.
--
-- {End of comments}
--

procedure update_questionnaire
  (
   p_validate              	  in     boolean   default false
  ,p_questionnaire_template_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_name                         in     varchar2     default hr_api.g_varchar2
  ,p_available_flag               in     varchar2     default hr_api.g_varchar2
  ,p_business_group_id            in     number       default hr_api.g_number
  ,p_text                         in     CLOB
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_questionnaire> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsn_del.del
--
-- Pre-requisites
--
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--
--  Internal Development use only.
--
-- {End of comments}
--

procedure delete_questionnaire
  (
   p_validate              		  in     boolean   default false
  ,p_questionnaire_template_id            in     number
  ,p_object_version_number                in     number
  );

end hr_questionnaire_api;

 

/
