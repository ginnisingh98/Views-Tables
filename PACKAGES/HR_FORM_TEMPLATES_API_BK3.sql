--------------------------------------------------------
--  DDL for Package HR_FORM_TEMPLATES_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_TEMPLATES_API_BK3" AUTHID CURRENT_USER as
/* $Header: hrtmpapi.pkh 120.0 2005/05/31 03:20:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_template_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_b
  (p_form_template_id              in number
  ,p_object_version_number         in number
  ,p_delete_children_flag          in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_template_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_a
  (p_form_template_id              in number
  ,p_object_version_number         in number
  ,p_delete_children_flag          in varchar2
  );
--
end hr_form_templates_api_bk3;

 

/
