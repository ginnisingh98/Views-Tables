--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_DATA_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_DATA_GROUPS_API" AUTHID CURRENT_USER as
/* $Header: hrtdgapi.pkh 120.0 2005/05/31 03:03:39 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< copy_template_data_group >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new template data group in
--              the HR Schema based on an existing template data group. It also --              creates a copy of every object within the copied from template
--              data group in the new template data group.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_language_code                N    Varchar2
--   p_template_data_group_id_from  Y    Number
--   p_form_template_id             Y    Number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_template_data_group_id_to    Number
--   p_object_version_number        Number
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure copy_template_data_group
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_template_data_group_id_from   in     number
  ,p_form_template_id              in     number
  ,p_template_data_group_id_to        out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_template_data_group >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new template data group in
--              the HR Schema. It also creates a template item for each form
--              item associated with the form data group.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_form_data_group_id           Y    Number
--   p_form_template_id             Y    Number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_template_data_group_id       Number
--   p_object_version_number        Number
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_template_data_group
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_form_template_id              in     number
  ,p_form_data_group_id            in     number
  ,p_template_data_group_id           out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_template_data_group >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a template data group form the
--              HR Schema. It also removes any items associated with the form
--              data group which are not associated with any other data group
--              within the template.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_template_data_group_id       Y    Number
--   p_object_version_number        Y    Number
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
--   Internal.
--
-- {End Of Comments}
--
procedure delete_template_data_group
  (p_validate                      in     boolean  default false
  ,p_template_data_group_id        in     number
  ,p_object_version_number         in     number
  );
--
end hr_template_data_groups_api;

 

/
