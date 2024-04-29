--------------------------------------------------------
--  DDL for Package HXC_TK_GROUP_QUERY_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TK_GROUP_QUERY_BK_1" AUTHID CURRENT_USER as
/* $Header: hxctkgqapi.pkh 120.0 2005/05/29 06:11:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< create_tk_group_query_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_tk_group_query_b
  (p_tk_group_query_id              in     number
  ,p_tk_group_id                    in     number
  ,p_object_version_number          in     number
  ,p_group_query_name                  in     varchar2
  ,p_include_exclude                in  varchar2
  ,p_system_user                    in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< create_tk_group_query_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_tk_group_query_a
  (p_tk_group_query_id         in     number
  ,p_tk_group_id               in     number
  ,p_object_version_number     in     number
  ,p_group_query_name             in     varchar2
  ,p_include_exclude                in  varchar2
  ,p_system_user                    in  varchar2
  );
--
end hxc_tk_group_query_bk_1;

 

/
