--------------------------------------------------------
--  DDL for Package PQH_TRAN_CATEGORY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TRAN_CATEGORY_BK1" AUTHID CURRENT_USER as
/* $Header: pqtctapi.pkh 120.1 2005/10/02 02:28:26 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_TRAN_CATEGORY_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_TRAN_CATEGORY_b
  (
   p_custom_wf_process_name         in  varchar2
  ,p_custom_workflow_name           in  varchar2
  ,p_form_name                      in  varchar2
  ,p_freeze_status_cd               in  varchar2
  ,p_future_action_cd               in  varchar2
  ,p_member_cd                      in  varchar2
  ,p_name                           in  varchar2
  ,p_short_name                     in  varchar2
  ,p_post_style_cd                  in  varchar2
  ,p_post_txn_function              in  varchar2
  ,p_route_validated_txn_flag       in  varchar2
  ,p_prevent_approver_skip          in  varchar2
  ,p_workflow_enable_flag           in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_timeout_days                   in  number
  ,p_consolidated_table_route_id    in  number
  ,p_business_group_id              in  number
  ,p_setup_type_cd                  in  varchar2
  ,p_master_table_route_id    in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_TRAN_CATEGORY_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_TRAN_CATEGORY_a
  (
   p_transaction_category_id        in  number
  ,p_custom_wf_process_name         in  varchar2
  ,p_custom_workflow_name           in  varchar2
  ,p_form_name                      in  varchar2
  ,p_freeze_status_cd               in  varchar2
  ,p_future_action_cd               in  varchar2
  ,p_member_cd                      in  varchar2
  ,p_name                           in  varchar2
  ,p_short_name                     in  varchar2
  ,p_post_style_cd                  in  varchar2
  ,p_post_txn_function              in  varchar2
  ,p_route_validated_txn_flag       in  varchar2
  ,p_prevent_approver_skip          in  varchar2
  ,p_workflow_enable_flag       in  varchar2
  ,p_enable_flag       in  varchar2
  ,p_timeout_days                   in  number
  ,p_object_version_number          in  number
  ,p_consolidated_table_route_id    in  number
  ,p_business_group_id              in  number
  ,p_setup_type_cd                  in  varchar2
  ,p_master_table_route_id    in  number
  ,p_effective_date                 in  date
  );
--
end pqh_TRAN_CATEGORY_bk1;

 

/
