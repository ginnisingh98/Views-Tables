--------------------------------------------------------
--  DDL for Package PQH_ATL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATL_RKD" AUTHID CURRENT_USER as
/* $Header: pqatlrhi.pkh 120.1 2005/08/06 13:15:43 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_attribute_id                   in number
 ,p_attribute_name_o               in varchar2
 ,p_language_o                     in varchar2
 ,p_source_lang_o                  in varchar2
  );
--
end pqh_atl_rkd;

 

/
