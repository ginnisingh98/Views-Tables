--------------------------------------------------------
--  DDL for Package PQH_CRL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRL_RKI" AUTHID CURRENT_USER as
/* $Header: pqcrlrhi.pkh 120.0 2005/05/29 01:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_criteria_rate_defn_id        in number
  ,p_name                         in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end pqh_crl_rki;

 

/
