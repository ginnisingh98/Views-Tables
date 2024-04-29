--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_ENTRY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_ENTRY_BK3" AUTHID CURRENT_USER as
/* $Header: pyeleapi.pkh 120.2.12010000.1 2008/07/27 22:30:34 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_element_entry_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_element_entry_b
  (p_datetrack_delete_mode in varchar2
  ,p_effective_date        in date
  ,p_element_entry_id      in number
  ,p_object_version_number in number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_element_entry_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_element_entry_a
  (p_datetrack_delete_mode in varchar2
  ,p_effective_date        in date
  ,p_element_entry_id      in number
  ,p_object_version_number in number
  ,p_effective_start_date  in date
  ,p_effective_end_date    in date
  ,p_delete_warning        in boolean
  );
--
end pay_element_entry_bk3;

/
