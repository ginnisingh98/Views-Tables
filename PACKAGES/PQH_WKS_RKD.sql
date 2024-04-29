--------------------------------------------------------
--  DDL for Package PQH_WKS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WKS_RKD" AUTHID CURRENT_USER as
/* $Header: pqwksrhi.pkh 120.0 2005/05/29 03:01:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_worksheet_id                   in number
 ,p_budget_id_o                    in number
 ,p_worksheet_name_o               in varchar2
 ,p_version_number_o               in number
 ,p_action_date_o                  in date
 ,p_date_from_o                    in date
 ,p_date_to_o                      in date
 ,p_worksheet_mode_cd_o            in varchar2
 ,p_transaction_status_o                       in varchar2
 ,p_object_version_number_o        in number
 ,p_budget_version_id_o            in number
 ,p_propagation_method_o           in varchar2
 ,p_wf_transaction_category_id_o   in number
  );
--
end pqh_wks_rkd;

 

/
