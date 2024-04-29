--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_DATA_GROUPS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_DATA_GROUPS_BK2" AUTHID CURRENT_USER as
/* $Header: hrtdgapi.pkh 120.0 2005/05/31 03:03:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_template_data_group_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_data_group_b
  (p_effective_date                in     date
  ,p_form_data_group_id            in     number
  ,p_form_template_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_template_data_group_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_data_group_a
  (p_effective_date                in     date
  ,p_form_data_group_id            in     number
  ,p_form_template_id              in     number
  ,p_template_data_group_id        in     number
  ,p_object_version_number         in     number
  );
--
end hr_template_data_groups_bk2;

 

/
