--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_LINK_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_LINK_BK3" AUTHID CURRENT_USER as
/* $Header: pypelapi.pkh 120.3.12010000.1 2008/07/27 23:21:44 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_element_link_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_element_link_b
  (p_effective_date              in        date
  ,p_element_link_id             in        number
  ,p_datetrack_delete_mode       in        varchar2
  ,p_object_version_number       in        number
   );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_element_link_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_element_link_a
  (p_effective_date              in        date
  ,p_element_link_id             in        number
  ,p_datetrack_delete_mode       in        varchar2
  ,p_object_version_number       in        number
  ,p_effective_start_date        in    	   date
  ,p_effective_end_date          in        date
  ,p_entries_warning		 in        boolean
  );
end PAY_ELEMENT_LINK_bk3;

/
