--------------------------------------------------------
--  DDL for Package PQH_CTL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CTL_RKU" AUTHID CURRENT_USER as
/* $Header: pqctlrhi.pkh 120.1 2005/08/06 13:15:37 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_transaction_category_id        in number
 ,p_name                           in varchar2
 ,p_language                       in varchar2
 ,p_source_lang                    in varchar2
 ,p_name_o                         in varchar2
 ,p_language_o                     in varchar2
 ,p_source_lang_o                  in varchar2
  );
--
end pqh_ctl_rku;

 

/
