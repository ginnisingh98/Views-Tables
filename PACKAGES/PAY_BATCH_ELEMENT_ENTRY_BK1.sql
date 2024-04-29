--------------------------------------------------------
--  DDL for Package PAY_BATCH_ELEMENT_ENTRY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BATCH_ELEMENT_ENTRY_BK1" AUTHID CURRENT_USER as
/* $Header: pybthapi.pkh 120.4 2005/10/28 05:44:22 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_header_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_header_b
  (p_session_date                  in     date
  ,p_batch_name                    in     varchar2
  ,p_batch_status                  in     varchar2
  ,p_business_group_id             in     number
  ,p_action_if_exists              in     varchar2
  ,p_batch_reference               in     varchar2
  ,p_batch_source                  in     varchar2
  ,p_comments                      in     varchar2
  ,p_date_effective_changes        in     varchar2
  ,p_purge_after_transfer          in     varchar2
  ,p_reject_if_future_changes      in     varchar2
  ,p_reject_if_results_exists      in     varchar2
  ,p_purge_after_rollback          in     varchar2
  ,p_batch_type                    in     varchar2
  ,p_REJECT_ENTRY_NOT_REMOVED      in     varchar2
  ,p_ROLLBACK_ENTRY_UPDATES        in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_header_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_header_a
  (p_session_date                  in     date
  ,p_batch_name                    in     varchar2
  ,p_batch_status                  in     varchar2
  ,p_business_group_id             in     number
  ,p_action_if_exists              in     varchar2
  ,p_batch_reference               in     varchar2
  ,p_batch_source                  in     varchar2
  ,p_comments                      in     varchar2
  ,p_date_effective_changes        in     varchar2
  ,p_purge_after_transfer          in     varchar2
  ,p_reject_if_future_changes      in     varchar2
  ,p_batch_id                      in     number
  ,p_object_version_number         in     number
  ,p_reject_if_results_exists      in     varchar2
  ,p_purge_after_rollback          in     varchar2
  ,p_batch_type                    in     varchar2
  ,p_REJECT_ENTRY_NOT_REMOVED      in     varchar2
  ,p_ROLLBACK_ENTRY_UPDATES        in     varchar2
  );
--
end pay_batch_element_entry_bk1;

 

/
