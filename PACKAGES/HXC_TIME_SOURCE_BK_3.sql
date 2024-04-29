--------------------------------------------------------
--  DDL for Package HXC_TIME_SOURCE_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_SOURCE_BK_3" AUTHID CURRENT_USER as
/* $Header: hxchtsapi.pkh 120.1 2005/10/02 02:06:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_source_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_source_b
  (p_time_source_id                 in     NUMBER
  ,p_object_version_number          in     NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_source_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_source_a
  (p_time_source_id                 in     NUMBER
  ,p_object_version_number          in     NUMBER
  );
--
end hxc_time_source_bk_3;

 

/
