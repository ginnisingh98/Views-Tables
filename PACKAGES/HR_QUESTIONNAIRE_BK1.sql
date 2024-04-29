--------------------------------------------------------
--  DDL for Package HR_QUESTIONNAIRE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUESTIONNAIRE_BK1" AUTHID CURRENT_USER as
/* $Header: hrqsnapi.pkh 120.1 2005/09/09 02:11:47 pveerepa noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_questionnaire_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_questionnaire_b
(
   p_name                           in     varchar2
  ,p_available_flag                 in     varchar2
  ,p_business_group_id              in     number
  ,p_text                           in     varchar2
  ,p_effective_date                 in     date
);

--
-- ----------------------------------------------------------------------------
-- |--------------------< create_questionnaire_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_questionnaire_a
(
   p_name                           in     varchar2
  ,p_available_flag                 in     varchar2
  ,p_business_group_id              in     number
  ,p_text                           in     varchar2
  ,p_effective_date                 in     date
  ,p_questionnaire_template_id      in     number
  ,p_object_version_number          in     number
);


end hr_questionnaire_bk1;

 

/
