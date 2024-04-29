--------------------------------------------------------
--  DDL for Package HXC_TK_GRP_QUERY_CRITERIA_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TK_GRP_QUERY_CRITERIA_BK_2" AUTHID CURRENT_USER as
/* $Header: hxctkgqcapi.pkh 120.0 2005/05/29 06:14:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------<update_tk_grp_query_criteria_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_tk_grp_query_criteria_b
  (p_tk_group_query_criteria_id in     number
  ,p_tk_group_query_id          in     number
  ,p_object_version_number      in     number
  ,p_criteria_type              in  varchar2
  ,p_criteria_id                in  number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_tk_grp_query_criteria_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_tk_grp_query_criteria_a
  (p_tk_group_query_criteria_id  in     number
  ,p_tk_group_query_id           in     number
  ,p_object_version_number       in     number
  ,p_criteria_type               in  varchar2
  ,p_criteria_id                 in  number
  );
--
end hxc_tk_grp_query_criteria_bk_2;

 

/
