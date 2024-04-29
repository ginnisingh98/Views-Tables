--------------------------------------------------------
--  DDL for Package PQH_TRL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TRL_RKU" AUTHID CURRENT_USER as
/* $Header: pqtrlrhi.pkh 115.1 2002/12/12 21:39:34 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_table_route_id               in number
  ,p_display_name                 in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_display_name_o               in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end pqh_trl_rku;

 

/
