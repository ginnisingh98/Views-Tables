--------------------------------------------------------
--  DDL for Package HXC_TIME_CATEGORY_COMP_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_CATEGORY_COMP_BK_3" AUTHID CURRENT_USER as
/* $Header: hxctccapi.pkh 120.0 2005/05/29 05:55:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_category_comp_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_category_comp_b
  (p_time_category_comp_id          in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_category_comp_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_category_comp_a
  (p_time_category_comp_id          in  number
  ,p_object_version_number          in  number
  );
--
end hxc_time_category_comp_bk_3;

 

/
