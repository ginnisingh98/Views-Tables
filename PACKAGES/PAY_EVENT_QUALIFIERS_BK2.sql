--------------------------------------------------------
--  DDL for Package PAY_EVENT_QUALIFIERS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_QUALIFIERS_BK2" AUTHID CURRENT_USER as
/* $Header: pyevqapi.pkh 120.1 2005/10/02 02:31:23 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_event_qualifier_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_event_qualifier_b
  (p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_event_qualifier_id            in     number
  ,p_dated_table_id                in     number
  ,p_column_name                   in     varchar2
  ,p_qualifier_name                in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_business_group_id             in     number
  ,p_comparison_column             in     varchar2
  ,p_qualifier_definition          in     varchar2
  ,p_qualifier_where_clause        in     varchar2
  ,p_entry_qualification           in     varchar2
  ,p_assignment_qualification      in     varchar2
  ,p_multi_event_sql               in     varchar2
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_event_qualifier_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_event_qualifier_a
  (p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_event_qualifier_id            in     number
  ,p_dated_table_id                in     number
  ,p_column_name                   in     varchar2
  ,p_qualifier_name                in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_business_group_id             in     number
  ,p_comparison_column             in     varchar2
  ,p_qualifier_definition          in     varchar2
  ,p_qualifier_where_clause        in     varchar2
  ,p_entry_qualification           in     varchar2
  ,p_assignment_qualification      in     varchar2
  ,p_multi_event_sql               in     varchar2
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );

--
end pay_event_qualifiers_bk2;

 

/
