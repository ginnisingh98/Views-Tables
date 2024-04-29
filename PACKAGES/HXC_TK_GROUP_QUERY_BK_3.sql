--------------------------------------------------------
--  DDL for Package HXC_TK_GROUP_QUERY_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TK_GROUP_QUERY_BK_3" AUTHID CURRENT_USER as
/* $Header: hxctkgqapi.pkh 120.0 2005/05/29 06:11:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< delete_tk_group_query_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_tk_group_query_b
  (p_tk_group_query_id         in  number
  ,p_object_version_number     in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_tk_group_query_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_tk_group_query_a
  (p_tk_group_query_id         in  number
  ,p_object_version_number     in  number
  );
--
end hxc_tk_group_query_bk_3;

 

/
