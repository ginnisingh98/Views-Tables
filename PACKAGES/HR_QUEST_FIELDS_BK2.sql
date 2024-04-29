--------------------------------------------------------
--  DDL for Package HR_QUEST_FIELDS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_FIELDS_BK2" AUTHID CURRENT_USER as
/* $Header: hrqsfapi.pkh 120.0 2005/05/31 02:27:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_quest_fields_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_quest_fields_b
  (
   p_effective_date               in     date
  ,p_field_id                     in     number
  ,p_object_version_number        in     number
  ,p_questionnaire_template_id    in     number
  ,p_name                         in     varchar2
  ,p_type                         in     varchar2
  ,p_sql_required_flag            in     varchar2
  ,p_html_text                    in     varchar2
  ,p_sql_text                     in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_quest_fields_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_quest_fields_a
  (
   p_effective_date               in     date
  ,p_field_id                     in     number
  ,p_object_version_number        in     number
  ,p_questionnaire_template_id    in     number
  ,p_name                         in     varchar2
  ,p_type                         in     varchar2
  ,p_sql_required_flag            in     varchar2
  ,p_html_text                    in     varchar2
  ,p_sql_text                     in     varchar2
  );
--
end hr_quest_fields_bk2;

 

/
