--------------------------------------------------------
--  DDL for Package HR_QUESTIONNAIRE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUESTIONNAIRE_BK3" AUTHID CURRENT_USER as
/* $Header: hrqsnapi.pkh 120.1 2005/09/09 02:11:47 pveerepa noship $ */

--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_questionnaire_a >------------------------|
-- ----------------------------------------------------------------------------
--
 procedure delete_questionnaire_a
  (
   p_questionnaire_template_id            in     number
  ,p_object_version_number                in     number
  );

-- ----------------------------------------------------------------------------
-- |--------------------< delete_questionnaire_b >------------------------|
-- ----------------------------------------------------------------------------
--

procedure delete_questionnaire_b
  (
   p_questionnaire_template_id            in     number
  ,p_object_version_number                in     number
  );

end hr_questionnaire_bk3;

 

/
