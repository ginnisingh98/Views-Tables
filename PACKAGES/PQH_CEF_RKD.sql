--------------------------------------------------------
--  DDL for Package PQH_CEF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CEF_RKD" AUTHID CURRENT_USER as
/* $Header: pqcefrhi.pkh 120.2 2005/10/12 20:18:24 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_copy_entity_function_id        in number
 ,p_table_route_id_o               in number
 ,p_function_type_cd_o             in varchar2
 ,p_pre_copy_function_name_o       in varchar2
 ,p_copy_function_name_o           in varchar2
 ,p_post_copy_function_name_o      in varchar2
 ,p_object_version_number_o        in number
 ,p_context_o                      in varchar2
  );
--
end pqh_cef_rkd;

 

/
