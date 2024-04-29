--------------------------------------------------------
--  DDL for Package HXC_TIMEKEEPER_GROUP_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMEKEEPER_GROUP_BK_2" AUTHID CURRENT_USER as
/* $Header: hxctkgapi.pkh 120.0 2005/05/29 06:01:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------<update_timekeeper_group_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_timekeeper_group_b
  (p_tk_group_id               in     number
  ,p_object_version_number     in     number
  ,p_tk_group_name             in     varchar2
  ,p_tk_resource_id               in     number
  ,p_business_group_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_timekeeper_group_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_timekeeper_group_a
  (p_tk_group_id               in     number
  ,p_object_version_number     in     number
  ,p_tk_group_name             in     varchar2
  ,p_tk_resource_id            in     number
  ,p_business_group_id              in     number
  );
--
end hxc_timekeeper_group_bk_2;

 

/
