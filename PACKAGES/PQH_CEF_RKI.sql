--------------------------------------------------------
--  DDL for Package PQH_CEF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CEF_RKI" AUTHID CURRENT_USER as
/* $Header: pqcefrhi.pkh 120.2 2005/10/12 20:18:24 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_copy_entity_function_id        in number
 ,p_table_route_id                 in number
 ,p_function_type_cd               in varchar2
 ,p_pre_copy_function_name         in varchar2
 ,p_copy_function_name             in varchar2
 ,p_post_copy_function_name        in varchar2
 ,p_object_version_number          in number
 ,p_context                        in varchar2
 ,p_effective_date                 in date
  );
end pqh_cef_rki;

 

/
