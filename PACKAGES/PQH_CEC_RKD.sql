--------------------------------------------------------
--  DDL for Package PQH_CEC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CEC_RKD" AUTHID CURRENT_USER as
/* $Header: pqcecrhi.pkh 120.2 2005/10/12 20:18:15 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_context                        in varchar2
 ,p_application_short_name_o       in varchar2
 ,p_legislation_code_o             in varchar2
 ,p_responsibility_key_o           in varchar2
 ,p_transaction_short_name_o       in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_cec_rkd;

 

/
