--------------------------------------------------------
--  DDL for Package PQH_ATL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATL_RKI" AUTHID CURRENT_USER as
/* $Header: pqatlrhi.pkh 120.1 2005/08/06 13:15:43 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_attribute_id                   in number
 ,p_attribute_name                 in varchar2
 ,p_language                       in varchar2
 ,p_source_lang                    in varchar2
  );
end pqh_atl_rki;

 

/
