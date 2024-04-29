--------------------------------------------------------
--  DDL for Package PAY_BTH_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BTH_RKD" AUTHID CURRENT_USER as
/* $Header: pybthrhi.pkh 120.0 2005/05/29 03:23:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_batch_id                     in number
  ,p_business_group_id_o          in number
  ,p_batch_name_o                 in varchar2
  ,p_batch_status_o               in varchar2
  ,p_action_if_exists_o           in varchar2
  ,p_batch_reference_o            in varchar2
  ,p_batch_source_o               in varchar2
  ,p_batch_type_o                 in varchar2
  ,p_comments_o                   in varchar2
  ,p_date_effective_changes_o     in varchar2
  ,p_purge_after_transfer_o       in varchar2
  ,p_reject_if_future_changes_o   in varchar2
  ,p_object_version_number_o      in number
  ,p_reject_if_results_exists_o   in varchar2
  ,p_purge_after_rollback_o       in varchar2
  ,p_REJECT_ENTRY_NOT_REMOVED_o   in varchar2
  ,p_ROLLBACK_ENTRY_UPDATES_o     in varchar2
  );
--
end pay_bth_rkd;

 

/
