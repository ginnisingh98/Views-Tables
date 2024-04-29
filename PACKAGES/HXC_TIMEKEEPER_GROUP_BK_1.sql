--------------------------------------------------------
--  DDL for Package HXC_TIMEKEEPER_GROUP_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMEKEEPER_GROUP_BK_1" AUTHID CURRENT_USER as
/* $Header: hxctkgapi.pkh 120.0 2005/05/29 06:01:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< create_timekeeper_group_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_timekeeper_group_b
  (p_tk_group_id                    in     number
  ,p_object_version_number          in     number
  ,p_tk_group_name                  in     varchar2
  ,p_tk_resource_id                    in     number
  ,p_business_group_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< create_timekeeper_group_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_timekeeper_group_a
  (p_tk_group_id               in     number
  ,p_object_version_number     in     number
  ,p_tk_group_name             in     varchar2
  ,p_tk_resource_id               in     number
  ,p_business_group_id              in     number
  );
--
end hxc_timekeeper_group_bk_1;

 

/
