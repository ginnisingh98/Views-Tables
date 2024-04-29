--------------------------------------------------------
--  DDL for Package PQH_TKT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TKT_RKD" AUTHID CURRENT_USER as
/* $Header: pqtktrhi.pkh 120.0 2005/05/29 02:49:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_tatigkeit_detail_id          in number
  ,p_tatigkeit_number_o           in varchar2
  ,p_description_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_tkt_rkd;

 

/
