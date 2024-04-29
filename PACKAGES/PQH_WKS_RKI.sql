--------------------------------------------------------
--  DDL for Package PQH_WKS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WKS_RKI" AUTHID CURRENT_USER as
/* $Header: pqwksrhi.pkh 120.0 2005/05/29 03:01:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_worksheet_id                   in number
 ,p_budget_id                      in number
 ,p_worksheet_name                 in varchar2
 ,p_version_number                 in number
 ,p_action_date                    in date
 ,p_date_from                      in date
 ,p_date_to                        in date
 ,p_worksheet_mode_cd              in varchar2
 ,p_transaction_status                         in varchar2
 ,p_object_version_number          in number
 ,p_budget_version_id              in number
 ,p_propagation_method             in varchar2
 ,p_effective_date                 in date
 ,p_wf_transaction_category_id     in number
  );
end pqh_wks_rki;

 

/
