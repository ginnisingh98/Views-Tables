--------------------------------------------------------
--  DDL for Package HR_SOURCE_FORM_TEMPLATES_BSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SOURCE_FORM_TEMPLATES_BSI" AUTHID CURRENT_USER as
/* $Header: hrsftbsi.pkh 115.2 2003/09/24 02:00:35 bsubrama noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_source_form_template >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process inserts a new source form
--              template in the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_form_template_id_to          Y    Number
--   p_form_template_id_from        Y    Number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_source_form_template_id      Number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_source_form_template
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_form_template_id_from         in     number
  ,p_form_template_id_to           in     number
  ,p_source_form_template_id       out nocopy    number
  ,p_object_version_number         out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_source_form_template >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process deletes a source form
--              template from the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_source_form_template_id      Y    Number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_source_form_template
  (p_validate                      in     boolean  default false
  ,p_source_form_template_id       in     number
  ,p_object_version_number         in     number
  );
--
end hr_source_form_templates_bsi;

 

/
