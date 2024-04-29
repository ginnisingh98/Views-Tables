--------------------------------------------------------
--  DDL for Package PQH_WEL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WEL_RKD" AUTHID CURRENT_USER as
/* $Header: pqwelrhi.pkh 120.0 2005/05/29 02:58:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_worksheet_bdgt_elmnt_id        in number
 ,p_worksheet_budget_set_id_o      in number
 ,p_element_type_id_o              in number
 ,p_distribution_percentage_o      in number
 ,p_object_version_number_o        in number
  );
--
end pqh_wel_rkd;

 

/
