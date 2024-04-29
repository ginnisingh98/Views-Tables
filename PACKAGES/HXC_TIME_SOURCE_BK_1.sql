--------------------------------------------------------
--  DDL for Package HXC_TIME_SOURCE_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_SOURCE_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchtsapi.pkh 120.1 2005/10/02 02:06:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_time_source_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_source_b
  (p_time_source_id                 in     NUMBER
  ,p_object_version_number          in     NUMBER
  ,p_name                           in     VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_time_source_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_source_a
  (p_time_source_id                 in     NUMBER
  ,p_object_version_number          in     NUMBER
  ,p_name                           in     VARCHAR2
  );
--
end hxc_time_source_bk_1;

 

/
