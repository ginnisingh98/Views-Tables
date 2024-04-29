--------------------------------------------------------
--  DDL for Package PQH_RLT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RLT_RKI" AUTHID CURRENT_USER as
/* $Header: pqrltrhi.pkh 120.0 2005/05/29 02:32:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_routing_list_id                in number
 ,p_routing_list_name              in varchar2
 ,p_enable_flag			   in varchar2
 ,p_object_version_number          in number
  );
end pqh_rlt_rki;

 

/
