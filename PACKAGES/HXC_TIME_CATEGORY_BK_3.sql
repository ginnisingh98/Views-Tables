--------------------------------------------------------
--  DDL for Package HXC_TIME_CATEGORY_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_CATEGORY_BK_3" AUTHID CURRENT_USER as
/* $Header: hxchtcapi.pkh 120.0.12010000.5 2009/01/07 12:08:56 asrajago ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_category_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_category_b
  (p_time_category_id               in  number
  ,p_time_Category_name             in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_category_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_category_a
  (p_time_category_id               in  number
  ,p_time_Category_name             in  varchar2
  ,p_object_version_number          in  number
  );
--
end hxc_time_category_bk_3;




/
