--------------------------------------------------------
--  DDL for Package HXC_TIMEKEEPER_GROUP_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMEKEEPER_GROUP_BK_3" AUTHID CURRENT_USER as
/* $Header: hxctkgapi.pkh 120.0 2005/05/29 06:01:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< delete_timekeeper_group_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_timekeeper_group_b
  (p_tk_group_id               in  number
  ,p_object_version_number     in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_timekeeper_group_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_timekeeper_group_a
  (p_tk_group_id               in  number
  ,p_object_version_number     in  number
  );
--
end hxc_timekeeper_group_bk_3;

 

/
