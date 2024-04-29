--------------------------------------------------------
--  DDL for Package HR_QUESTIONNAIRE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUESTIONNAIRE_BK2" AUTHID CURRENT_USER as
/* $Header: hrqsnapi.pkh 120.1 2005/09/09 02:11:47 pveerepa noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_questionnaire_a >------------------------|
-- ----------------------------------------------------------------------------
--

procedure update_questionnaire_a
  (
   p_questionnaire_template_id    in     number
  ,p_object_version_number        in     number
  ,p_name                         in     varchar2
  ,p_available_flag               in     varchar2
  ,p_business_group_id            in     number
  ,p_text                         in     varchar2
  ,p_effective_date               in     date
  );


-- ----------------------------------------------------------------------------
-- |--------------------< update_questionnaire_b >------------------------|
-- ----------------------------------------------------------------------------
--

procedure update_questionnaire_b
  (
   p_effective_date               in     date
  ,p_questionnaire_template_id    in     number
  ,p_object_version_number        in     number
  ,p_name                         in     varchar2
  ,p_available_flag               in     varchar2
  ,p_business_group_id            in     number
  ,p_text                         in     varchar2
  );


end hr_questionnaire_bk2;

 

/
