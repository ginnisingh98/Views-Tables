--------------------------------------------------------
--  DDL for Package PQH_CEP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CEP_RKU" AUTHID CURRENT_USER as
/* $Header: pqceprhi.pkh 120.0 2005/05/29 01:40:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_copy_entity_pref_id            in number
 ,p_table_route_id                 in number
 ,p_copy_entity_txn_id             in number
 ,p_select_flag                    in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_table_route_id_o               in number
 ,p_copy_entity_txn_id_o           in number
 ,p_select_flag_o                  in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_cep_rku;

 

/
