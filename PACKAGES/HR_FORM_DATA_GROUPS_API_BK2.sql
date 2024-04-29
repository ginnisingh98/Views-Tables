--------------------------------------------------------
--  DDL for Package HR_FORM_DATA_GROUPS_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_DATA_GROUPS_API_BK2" AUTHID CURRENT_USER as
/* $Header: hrfdgapi.pkh 120.0 2005/05/31 00:16:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_form_data_group_b >-----------------------
--|

-- ----------------------------------------------------------------------------
--
procedure delete_form_data_group_b
  (p_form_data_group_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_form_data_group_a >-----------------------
--|

-- ----------------------------------------------------------------------------
--
procedure delete_form_data_group_a
  (p_form_data_group_id            in     number
  ,p_object_version_number         in     number
  );
--
end hr_form_data_groups_api_bk2;

 

/
