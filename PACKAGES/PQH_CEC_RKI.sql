--------------------------------------------------------
--  DDL for Package PQH_CEC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CEC_RKI" AUTHID CURRENT_USER as
/* $Header: pqcecrhi.pkh 120.2 2005/10/12 20:18:15 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_context                        in varchar2
 ,p_application_short_name         in varchar2
 ,p_legislation_code               in varchar2
 ,p_responsibility_key             in varchar2
 ,p_transaction_short_name         in varchar2
 ,p_object_version_number          in number
  );
end pqh_cec_rki;

 

/
