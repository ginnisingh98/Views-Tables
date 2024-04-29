--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_FUND_SRCS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_FUND_SRCS_BK1" AUTHID CURRENT_USER as
/* $Header: pqwfsapi.pkh 120.0 2005/05/29 02:59:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_WORKSHEET_FUND_SRC_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET_FUND_SRC_b
  (
   p_worksheet_bdgt_elmnt_id        in  number
  ,p_distribution_percentage        in  number
  ,p_cost_allocation_keyflex_id     in  number
  ,p_project_id                     in  number
  ,p_award_id                       in  number
  ,p_task_id                        in  number
  ,p_expenditure_type               in  varchar2
  ,p_organization_id                in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_WORKSHEET_FUND_SRC_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET_FUND_SRC_a
  (
   p_worksheet_fund_src_id          in  number
  ,p_worksheet_bdgt_elmnt_id        in  number
  ,p_distribution_percentage        in  number
  ,p_cost_allocation_keyflex_id     in  number
  ,p_project_id                     in  number
  ,p_award_id                       in  number
  ,p_task_id                        in  number
  ,p_expenditure_type               in  varchar2
  ,p_organization_id                in  number
  ,p_object_version_number          in  number
  );
--
end pqh_WORKSHEET_FUND_SRCS_bk1;

 

/
