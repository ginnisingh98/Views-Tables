--------------------------------------------------------
--  DDL for Package HXC_TK_GRP_QUERY_CRITERIA_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TK_GRP_QUERY_CRITERIA_BK_1" AUTHID CURRENT_USER as
/* $Header: hxctkgqcapi.pkh 120.0 2005/05/29 06:14:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< create_tk_grp_query_criteria_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_tk_grp_query_criteria_b
  (p_tk_group_query_criteria_id     in     number
  ,p_tk_group_query_id              in     number
  ,p_object_version_number          in     number
  ,p_criteria_type                  in  varchar2
  ,p_criteria_id                    in  number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< create_tk_grp_query_criteria_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_tk_grp_query_criteria_a
  (p_tk_group_query_criteria_id in     number
  ,p_tk_group_query_id          in     number
  ,p_object_version_number      in     number
  ,p_criteria_type              in  varchar2
  ,p_criteria_id                in  number
  );
--
end hxc_tk_grp_query_criteria_bk_1;

 

/
