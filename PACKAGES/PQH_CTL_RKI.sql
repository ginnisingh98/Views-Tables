--------------------------------------------------------
--  DDL for Package PQH_CTL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CTL_RKI" AUTHID CURRENT_USER as
/* $Header: pqctlrhi.pkh 120.1 2005/08/06 13:15:37 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_transaction_category_id        in number
 ,p_name                           in varchar2
 ,p_language                       in varchar2
 ,p_source_lang                    in varchar2
  );
end pqh_ctl_rki;

 

/
