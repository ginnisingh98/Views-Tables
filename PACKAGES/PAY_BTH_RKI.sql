--------------------------------------------------------
--  DDL for Package PAY_BTH_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BTH_RKI" AUTHID CURRENT_USER as
/* $Header: pybthrhi.pkh 120.0 2005/05/29 03:23:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_session_date                 in date
  ,p_batch_id                     in number
  ,p_business_group_id            in number
  ,p_batch_name                   in varchar2
  ,p_batch_status                 in varchar2
  ,p_action_if_exists             in varchar2
  ,p_batch_reference              in varchar2
  ,p_batch_source                 in varchar2
  ,p_batch_type                   in varchar2
  ,p_comments                     in varchar2
  ,p_date_effective_changes       in varchar2
  ,p_purge_after_transfer         in varchar2
  ,p_reject_if_future_changes     in varchar2
  ,p_object_version_number        in number
  ,p_reject_if_results_exists     in varchar2
  ,p_REJECT_ENTRY_NOT_REMOVED     in varchar2
  ,p_ROLLBACK_ENTRY_UPDATES       in varchar2
  ,p_purge_after_rollback         in varchar2
  );
end pay_bth_rki;

 

/
