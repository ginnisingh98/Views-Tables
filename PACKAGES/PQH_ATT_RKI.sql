--------------------------------------------------------
--  DDL for Package PQH_ATT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATT_RKI" AUTHID CURRENT_USER as
/* $Header: pqattrhi.pkh 120.4 2007/04/19 12:41:32 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_attribute_id                   in number
 ,p_attribute_name                 in varchar2
 ,p_master_attribute_id            in number
 ,p_master_table_route_id          in number
 ,p_column_name                    in varchar2
 ,p_column_type                    in varchar2
 ,p_enable_flag                    in varchar2
 ,p_width                          in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_region_itemname                in  varchar2
 ,p_attribute_itemname             in  varchar2
 ,p_decode_function_name           in  varchar2
  );
end pqh_att_rki;

/
