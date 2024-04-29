--------------------------------------------------------
--  DDL for Package HR_QUEST_ANSWER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_ANSWER_API" AUTHID CURRENT_USER as
/* $Header: hrqsaapi.pkh 120.0 2005/05/31 02:25:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_quest_answer >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsa_ins.ins
--
-- Pre-requisites
--
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--
--  p_questionnaire_answer_id  will have generated and surrogate value.
--
-- Post Failure:
--
--  p_questionnaire_answer_id  will have null.
--
-- Access Status:
--
--  Internal Development use only.
--
-- {End of comments}
--
procedure create_quest_answer
  ( p_validate                       in     boolean  default false
   ,p_effective_date                 in     date
   ,p_questionnaire_template_id      in     number
   ,p_type                           in     varchar2
   ,p_type_object_id                 in     number
   ,p_business_group_id              in     number
   ,p_questionnaire_answer_id           out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_quest_answer >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsa_upd.upd
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
--
-- Access Status:
--
--  Internal Development use only.
--
-- {End of comments}
--

procedure update_quest_answer
  (
    p_validate                     in     boolean  default false
   ,p_effective_date               in     date
   ,p_questionnaire_answer_id      in     number
   ,p_questionnaire_template_id    in     number   default hr_api.g_number
   ,p_type                         in     varchar2 default hr_api.g_varchar2
   ,p_type_object_id               in     number   default hr_api.g_number
   ,p_business_group_id            in     number   default hr_api.g_number
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_quest_answer >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsa_del.del
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
--
-- Access Status:
--
--  Internal Development use only.
--
-- {End of comments}
--

 procedure delete_quest_answer
  (
   p_validate                      in     boolean  default false
  ,p_questionnaire_answer_id       in     number
  );
--
end hr_quest_answer_api;

 

/
