--------------------------------------------------------
--  DDL for Package HR_QUEST_ANS_VAL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_ANS_VAL_SWI" AUTHID CURRENT_USER As
/* $Header: hrqsvswi.pkh 120.0 2005/05/31 02:31:48 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< insert_quest_answer_val >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_quest_ans_val_swi.insert_quest_answer_val
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
PROCEDURE insert_quest_answer_val
  (p_quest_answer_val_id          in	 number
  ,p_questionnaire_answer_id      in     number
  ,p_field_id                     in     number
  ,p_object_version_number           out nocopy number
  ,p_value                        in     varchar2  default hr_api.g_varchar2
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< set_base_key_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_qsv_ins.set_base_key_value
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
PROCEDURE set_base_key_value
  (p_quest_answer_val_id          in     number
  ,p_return_status                   out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_quest_answer_val >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_quest_ans_val_swi.delete_quest_answer_val
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
PROCEDURE delete_quest_answer_val
  (p_quest_answer_val_id          in     number
  ,p_object_version_number        in     number
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_quest_answer_val >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_quest_ans_val_swi.update_quest_answer_val
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
PROCEDURE update_quest_answer_val
  (p_quest_answer_val_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_value                        in     varchar2  default hr_api.g_varchar2
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
-- This procedure is responsible for commiting data from transaction
-- table (hr_api_transaction_step_id) to the base table
--
-- Parameters:
-- p_document is the document having the data that needs to be committed
-- p_return_status is the return status after committing the date. In case of
-- any errors/warnings the p_return_status is populated with 'E' or 'W'
-- p_validate is the flag to indicate whether to rollback data or not
-- p_effective_date is the current effective date
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------

Procedure process_api
(
  p_document                in           CLOB
 ,p_return_status           out  nocopy  VARCHAR2
 ,p_validate                in           number    default hr_api.g_false_num
 ,p_effective_date          in           date      default null
);

end hr_quest_ans_val_swi;

 

/
