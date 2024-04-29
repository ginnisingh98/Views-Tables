--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_BDGT_ELMNTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_BDGT_ELMNTS_BK1" AUTHID CURRENT_USER as
/* $Header: pqwelapi.pkh 120.0 2005/05/29 02:58:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_WORKSHEET_BDGT_ELMNT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET_BDGT_ELMNT_b
  (
   p_worksheet_budget_set_id        in  number
  ,p_element_type_id                in  number
  ,p_distribution_percentage        in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_WORKSHEET_BDGT_ELMNT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET_BDGT_ELMNT_a
  (
   p_worksheet_bdgt_elmnt_id        in  number
  ,p_worksheet_budget_set_id        in  number
  ,p_element_type_id                in  number
  ,p_distribution_percentage        in  number
  ,p_object_version_number          in  number
  );
--
end pqh_WORKSHEET_BDGT_ELMNTS_bk1;

 

/
