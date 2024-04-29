--------------------------------------------------------
--  DDL for Package HXC_TIME_SOURCE_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_SOURCE_BK_2" AUTHID CURRENT_USER as
/* $Header: hxchtsapi.pkh 120.1 2005/10/02 02:06:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_time_source_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_source_b
  (p_time_source_id                 in     NUMBER
  ,p_object_version_number          in     NUMBER
  ,p_name                           in     VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_time_source_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_source_a
  (p_time_source_id                 in     NUMBER
  ,p_object_version_number          in     NUMBER
  ,p_name                           in     VARCHAR2
  );
--
end hxc_time_source_bk_2;

 

/
