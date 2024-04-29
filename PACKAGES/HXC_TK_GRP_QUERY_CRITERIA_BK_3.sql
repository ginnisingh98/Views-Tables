--------------------------------------------------------
--  DDL for Package HXC_TK_GRP_QUERY_CRITERIA_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TK_GRP_QUERY_CRITERIA_BK_3" AUTHID CURRENT_USER as
/* $Header: hxctkgqcapi.pkh 120.0 2005/05/29 06:14:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< delete_tk_grp_query_criteria_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_tk_grp_query_criteria_b
  (p_tk_group_query_criteria_id in  number
  ,p_object_version_number      in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_tk_grp_query_criteria_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_tk_grp_query_criteria_a
  (p_tk_group_query_criteria_id in  number
  ,p_object_version_number      in  number
  );
--
end hxc_tk_grp_query_criteria_bk_3;

 

/
