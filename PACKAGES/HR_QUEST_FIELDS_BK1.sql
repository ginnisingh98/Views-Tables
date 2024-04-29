--------------------------------------------------------
--  DDL for Package HR_QUEST_FIELDS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_FIELDS_BK1" AUTHID CURRENT_USER as
/* $Header: hrqsfapi.pkh 120.0 2005/05/31 02:27:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< insert_quest_fields_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_quest_fields_b
  (
   p_effective_date                 in     date
  ,p_questionnaire_template_id      in     number
  ,p_name                           in     varchar2
  ,p_type                           in     varchar2
  ,p_sql_required_flag              in     varchar2
  ,p_html_text                      in     varchar2
  ,p_sql_text                       in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< insert_quest_fields_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_quest_fields_a
  (
   p_effective_date                 in     date
  ,p_questionnaire_template_id      in     number
  ,p_name                           in     varchar2
  ,p_type                           in     varchar2
  ,p_sql_required_flag              in     varchar2
  ,p_html_text                      in     varchar2
  ,p_sql_text                       in     varchar2
  ,p_field_id                       in     number
  ,p_object_version_number          in     number
  );
--
end hr_quest_fields_bk1;

 

/
