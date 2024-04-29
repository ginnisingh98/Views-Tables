--------------------------------------------------------
--  DDL for Package PAY_DATETRACKED_EVENTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DATETRACKED_EVENTS_BK1" AUTHID CURRENT_USER as
/* $Header: pydteapi.pkh 120.1 2005/10/02 02:30:27 aroussel $ */
--
-- ---------------------------------------------------------------------
-- |-------------------< create_datetracked_event_b  >------------------|
-- ---------------------------------------------------------------------
--
procedure  create_datetracked_event_b
 ( p_effective_date                 in     date
  ,p_event_group_id                 in     number
  ,p_dated_table_id                 in     number
  ,p_update_type                    in     varchar2
  ,p_column_name                    in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_proration_style                in     varchar2
 );
--
-- ----------------------------------------------------------------------
-- |------------------< create_datetracked_event_a >-------------------|
-- ----------------------------------------------------------------------
--
procedure create_datetracked_event_a
 ( p_effective_date                 in     date
  ,p_event_group_id                 in     number
  ,p_dated_table_id                 in     number
  ,p_update_type                    in     varchar2
  ,p_column_name                    in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_datetracked_event_id           in     number
  ,p_object_version_number          in     number
  ,p_proration_style                in     varchar2
   );
end pay_datetracked_events_bk1;

 

/
