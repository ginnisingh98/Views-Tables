--------------------------------------------------------
--  DDL for Package HR_FORM_DATA_GROUPS_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_DATA_GROUPS_API_BK3" AUTHID CURRENT_USER as
/* $Header: hrfdgapi.pkh 120.0 2005/05/31 00:16:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_form_data_group_b -------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_data_group_b
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  --,p_application_id                in     number
  --,p_form_id                       in     number
  ,p_form_data_group_id            in     number
  ,p_data_group_name               in     varchar2
  ,p_user_data_group_name          in     varchar2
  ,p_description                   in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_form_data_group_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_data_group_a
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  --,p_application_id                in     number
  --,p_form_id                       in     number
  ,p_form_data_group_id            in     number
  ,p_data_group_name               in     varchar2
  ,p_user_data_group_name          in     varchar2
  ,p_description                   in     varchar2
  ,p_object_version_number         in     number
  );
--
end hr_form_data_groups_api_bk3;

 

/
