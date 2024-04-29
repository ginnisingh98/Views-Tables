--------------------------------------------------------
--  DDL for Package PQH_TRL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TRL_RKD" AUTHID CURRENT_USER as
/* $Header: pqtrlrhi.pkh 115.1 2002/12/12 21:39:34 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_table_route_id               in number
  ,p_language                     in varchar2
  ,p_display_name_o               in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end pqh_trl_rkd;

 

/
