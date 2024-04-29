--------------------------------------------------------
--  DDL for Package PQH_TKT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TKT_RKU" AUTHID CURRENT_USER as
/* $Header: pqtktrhi.pkh 120.0 2005/05/29 02:49:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_tatigkeit_detail_id          in number
  ,p_tatigkeit_number             in varchar2
  ,p_description                  in varchar2
  ,p_object_version_number        in number
  ,p_tatigkeit_number_o           in varchar2
  ,p_description_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_tkt_rku;

 

/
