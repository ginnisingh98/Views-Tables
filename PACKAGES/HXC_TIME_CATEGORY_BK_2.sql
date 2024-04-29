--------------------------------------------------------
--  DDL for Package HXC_TIME_CATEGORY_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_CATEGORY_BK_2" AUTHID CURRENT_USER as
/* $Header: hxchtcapi.pkh 120.0.12010000.5 2009/01/07 12:08:56 asrajago ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_time_category_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_category_b
  (p_time_category_id               in     number
  ,p_object_version_number          in     number
  ,p_time_category_name             in     varchar2
  ,p_operator                       in     varchar2
  ,p_description                    in     varchar2
  ,p_display                        in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_time_category_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_category_a
  (p_time_category_id               in     number
  ,p_object_version_number          in     number
  ,p_time_category_name             in     varchar2
  ,p_operator                       in     varchar2
  ,p_description                    in     varchar2
  ,p_display                        in     varchar2
  );
--
end hxc_time_category_bk_2;

/
