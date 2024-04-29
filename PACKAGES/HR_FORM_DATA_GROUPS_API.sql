--------------------------------------------------------
--  DDL for Package HR_FORM_DATA_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_DATA_GROUPS_API" AUTHID CURRENT_USER as
/* $Header: hrfdgapi.pkh 120.0 2005/05/31 00:16:43 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_form_data_group >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new form data group in the
--              HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                        Reqd Type     Description
--   p_language_code              N   Varchar2
--   p_application_id             Y   Number
--   p_form_id                    Y   Number
--   p_data_group_name            Y   Varchar2
--   p_user_data_group_name       Y   Varchar2
--   p_description                N   Varchar2
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_form_data_group_id	    Number
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
procedure create_form_data_group
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_application_id                in     number
  ,p_form_id                       in     number
  ,p_data_group_name               in     varchar2
  ,p_user_data_group_name          in     varchar2
  ,p_description                   in     varchar2 default null
  ,p_form_data_group_id               out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_form_data_group >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a form data group form the
--  HR Schema. It also removes any associations between the data group and
--  items, without removing the item itself.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_form_data_group_id	    Y    Number
--   p_object_version_number        Y    Number
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
procedure delete_form_data_group
  (p_validate                      in     boolean  default false
  ,p_form_data_group_id            in     number
  ,p_object_version_number         in     number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_form_data_group >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process updates a form data group in the
--              HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                        Reqd Type     Description
--   p_language_code              N   Varchar2
--   p_form_data_group_id         Y   Number
--   p_data_group_name            Y   Varchar2
--   p_user_data_group_name       Y   Varchar2
--   p_description                N   Varchar2
--
-- Post Success:
--
--
--   Name                           Type     Description
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
procedure update_form_data_group
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  --,p_application_id                in     number
  --,p_form_id                       in     number
  ,p_form_data_group_id            in     number
  ,p_data_group_name               in     varchar2 default hr_api.g_varchar2
  ,p_user_data_group_name          in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
end hr_form_data_groups_api;

 

/
