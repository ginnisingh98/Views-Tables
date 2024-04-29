--------------------------------------------------------
--  DDL for Package PQH_ATTRIBUTES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATTRIBUTES_BK2" AUTHID CURRENT_USER as
/* $Header: pqattapi.pkh 120.0 2005/05/29 01:26:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ATTRIBUTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ATTRIBUTE_b
  (
   p_attribute_id                   in  number
  ,p_attribute_name                 in  varchar2
  ,p_master_attribute_id            in  number
  ,p_master_table_route_id          in  number
  ,p_column_name                    in  varchar2
  ,p_column_type                    in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_width                          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_region_itemname                in varchar2
  ,p_attribute_itemname             in varchar2
  ,p_decode_function_name           in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ATTRIBUTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ATTRIBUTE_a
  (
   p_attribute_id                   in  number
  ,p_attribute_name                 in  varchar2
  ,p_master_attribute_id            in  number
  ,p_master_table_route_id          in  number
  ,p_column_name                    in  varchar2
  ,p_column_type                    in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_width                          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_region_itemname                in varchar2
  ,p_attribute_itemname             in varchar2
  ,p_decode_function_name           in varchar2
  );
--
end pqh_ATTRIBUTES_bk2;

 

/
