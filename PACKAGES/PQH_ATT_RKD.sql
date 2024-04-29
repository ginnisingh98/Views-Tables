--------------------------------------------------------
--  DDL for Package PQH_ATT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATT_RKD" AUTHID CURRENT_USER as
/* $Header: pqattrhi.pkh 120.4 2007/04/19 12:41:32 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_attribute_id                   in number
 ,p_attribute_name_o               in varchar2
 ,p_master_attribute_id_o          in number
 ,p_master_table_route_id_o        in number
 ,p_column_name_o                  in varchar2
 ,p_column_type_o                  in varchar2
 ,p_enable_flag_o                  in varchar2
 ,p_width_o                        in number
 ,p_object_version_number_o        in number
 ,p_region_itemname_o              in  varchar2
 ,p_attribute_itemname_o           in  varchar2
 ,p_decode_function_name_o         in  varchar2
  );
--
end pqh_att_rkd;

/
