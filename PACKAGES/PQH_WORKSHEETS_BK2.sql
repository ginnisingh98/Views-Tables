--------------------------------------------------------
--  DDL for Package PQH_WORKSHEETS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEETS_BK2" AUTHID CURRENT_USER as
/* $Header: pqwksapi.pkh 120.0 2005/05/29 03:00:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_WORKSHEET_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_WORKSHEET_b
  (
   p_worksheet_id                   in  number
  ,p_budget_id                      in  number
  ,p_worksheet_name                 in  varchar2
  ,p_version_number                 in  number
  ,p_action_date                    in  date
  ,p_date_from                      in  date
  ,p_date_to                        in  date
  ,p_worksheet_mode_cd              in  varchar2
  ,p_transaction_status                         in  varchar2
  ,p_object_version_number          in  number
  ,p_budget_version_id              in  number
  ,p_propagation_method             in  varchar2
  ,p_effective_date                 in  date
  ,p_wf_transaction_category_id     in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_WORKSHEET_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_WORKSHEET_a
  (
   p_worksheet_id                   in  number
  ,p_budget_id                      in  number
  ,p_worksheet_name                 in  varchar2
  ,p_version_number                 in  number
  ,p_action_date                    in  date
  ,p_date_from                      in  date
  ,p_date_to                        in  date
  ,p_worksheet_mode_cd              in  varchar2
  ,p_transaction_status                         in  varchar2
  ,p_object_version_number          in  number
  ,p_budget_version_id              in  number
  ,p_propagation_method             in  varchar2
  ,p_effective_date                 in  date
  ,p_wf_transaction_category_id     in  number
  );
--
end pqh_WORKSHEETS_bk2;

 

/
