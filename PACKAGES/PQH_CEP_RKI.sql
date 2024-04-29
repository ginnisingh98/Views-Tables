--------------------------------------------------------
--  DDL for Package PQH_CEP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CEP_RKI" AUTHID CURRENT_USER as
/* $Header: pqceprhi.pkh 120.0 2005/05/29 01:40:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_copy_entity_pref_id            in number
 ,p_table_route_id                 in number
 ,p_copy_entity_txn_id             in number
 ,p_select_flag                    in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end pqh_cep_rki;

 

/
