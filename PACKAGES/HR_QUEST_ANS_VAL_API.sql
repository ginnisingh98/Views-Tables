--------------------------------------------------------
--  DDL for Package HR_QUEST_ANS_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_ANS_VAL_API" AUTHID CURRENT_USER as
/* $Header: hrqsvapi.pkh 120.0 2005/05/31 02:30:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_quest_answer_val >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsv_ins.ins
--
-- Pre-requisites
--
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--
--  p_quest_answer_val_id    will contain the generated or surrogate value.
--  p_object_version_number  will contain latest OVN.
--
-- Post Failure:
--
--  p_quest_answer_val_id    will contain null
--  p_object_version_number  will contain null
--
-- Access Status:
--
--  Internal Development use only.
--
-- {End of comments}
--
procedure insert_quest_answer_val
  ( p_validate                       in     boolean  default false
   ,p_questionnaire_answer_id        in     number
   ,p_field_id                       in     number
   ,p_value                          in     varchar2 default null
   ,p_quest_answer_val_id               out nocopy number
   ,p_object_version_number             out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_quest_answer_val >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsv_upd.upd
--
-- Pre-requisites
--
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--
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
procedure update_quest_answer_val
  (p_validate                     in     boolean  default false
  ,p_quest_answer_val_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_value                        in     varchar2 default hr_api.g_varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_quest_answer_val >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:This procedure is the API wrapper procedure to the following
--
--  RHI: hr_qsv_del.del
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

procedure delete_quest_answer_val
  (
   p_validate                      in     boolean  default false
  ,p_quest_answer_val_id           in     number
  ,p_object_version_number         in     number
  );

--
end hr_quest_ans_val_api;

 

/
