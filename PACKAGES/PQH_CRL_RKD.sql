--------------------------------------------------------
--  DDL for Package PQH_CRL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRL_RKD" AUTHID CURRENT_USER as
/* $Header: pqcrlrhi.pkh 120.0 2005/05/29 01:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_criteria_rate_defn_id        in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end pqh_crl_rkd;

 

/
