--------------------------------------------------------
--  DDL for Package PQH_RLT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RLT_RKD" AUTHID CURRENT_USER as
/* $Header: pqrltrhi.pkh 120.0 2005/05/29 02:32:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_routing_list_id                in number
 ,p_routing_list_name_o            in varchar2
 ,p_enable_flag_o		   in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_rlt_rkd;

 

/
