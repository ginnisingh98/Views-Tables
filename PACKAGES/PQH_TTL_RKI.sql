--------------------------------------------------------
--  DDL for Package PQH_TTL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TTL_RKI" AUTHID CURRENT_USER as
/* $Header: pqttlrhi.pkh 120.1 2005/08/06 13:15:26 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_template_id                    in number
 ,p_template_name                  in varchar2
 ,p_language                       in varchar2
 ,p_source_lang                    in varchar2
  );
end pqh_ttl_rki;

 

/
