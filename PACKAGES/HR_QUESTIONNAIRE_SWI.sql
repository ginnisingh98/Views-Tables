--------------------------------------------------------
--  DDL for Package HR_QUESTIONNAIRE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUESTIONNAIRE_SWI" AUTHID CURRENT_USER AS
/* $Header: hrqstswi.pkh 120.1 2005/09/09 02:12:27 pveerepa noship $ */

/*
Procedure update_questionnaire_recs
  (p_effective_date IN DATE
  ,p_quest_tbl IN OUT NOCOPY HR_QUEST_TABLE
  ,p_error_message OUT NOCOPY LONG
  ,p_status OUT NOCOPY VARCHAR2);
 */
-- ----------------------------------------------------------------------------
-- |---------------------------< update_questionnaire >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_questionnaire_api.update_questionnaire
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

Procedure update_questionnaire
  (p_questionnaire_template_id in number
  ,p_object_version_number     in out nocopy number
  ,p_text		       in CLOB
  ,p_available_flag            in varchar2 default hr_api.g_varchar2
  ,p_business_group_id         in number   default hr_api.g_number
  ,p_effective_date            in date     default hr_api.g_date
  ,p_validate                  in number   default hr_api.g_false_num
  ,p_return_status             out nocopy  varchar2);

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_questionnaire >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_questionnaire_api.delete_questionnaire
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

Procedure delete_questionnaire
  (p_questionnaire_template_id in number
  ,p_object_version_number     in number
  ,p_validate                  in number default hr_api.g_false_num
  ,p_return_status             out nocopy varchar2);

-- ----------------------------------------------------------------------------
-- |--------------------------< create_questionnaire >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_questionnaire_api.create_questionnaire
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

Procedure create_questionnaire
  (p_questionnaire_template_id in number
  ,p_name                      in varchar2
  ,p_text                      in CLOB
  ,p_available_flag            in varchar2
  ,p_business_group_id         in number
  ,p_object_version_number     out nocopy number
  ,p_effective_date            in date   default hr_api.g_date
  ,p_validate                  in number default hr_api.g_false_num
  ,p_return_status             out nocopy varchar2);


END HR_QUESTIONNAIRE_SWI;

 

/
