--------------------------------------------------------
--  DDL for Package PAY_BATCH_ELEMENT_ENTRY_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BATCH_ELEMENT_ENTRY_BK6" AUTHID CURRENT_USER as
/* $Header: pybthapi.pkh 120.4 2005/10/28 05:44:22 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_total_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_total_b
  (p_session_date                  in     date
  ,p_batch_control_id              in     number
  ,p_object_version_number         in     number
  ,p_control_status                in     varchar2
  ,p_control_total                 in     varchar2
  ,p_control_type                  in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_total_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_total_a
  (p_session_date                  in     date
  ,p_batch_control_id              in     number
  ,p_object_version_number         in     number
  ,p_control_status                in     varchar2
  ,p_control_total                 in     varchar2
  ,p_control_type                  in     varchar2
  );
--
end pay_batch_element_entry_bk6;

 

/
