--------------------------------------------------------
--  DDL for Package PAY_EVENT_UPDATES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_UPDATES_BK1" AUTHID CURRENT_USER as
/* $Header: pypeuapi.pkh 120.1 2005/10/02 02:32:43 aroussel $ */
--
-- ---------------------------------------------------------------------
-- |-------------------< pay_event_update_b >------------------|
-- ---------------------------------------------------------------------
--
procedure create_event_update_b
 ( p_effective_date                 in     date
  ,p_dated_table_id                 in     number
  ,p_change_type                    in     varchar2
  ,p_table_name                     in     varchar2
  ,p_column_name                    in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_event_type                     in     varchar2
 );
--
-- ----------------------------------------------------------------------
-- |------------------< pay_event_update_a>-------------------|
-- ----------------------------------------------------------------------
--
procedure create_event_update_a
 ( p_effective_date                 in     date
  ,p_dated_table_id                 in     number
  ,p_change_type                    in     varchar2
  ,p_table_name                     in     varchar2
  ,p_column_name                    in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_event_type                     in     varchar2
  ,p_event_update_id                   in number
  ,p_object_version_number             in number
  );
--
end pay_event_updates_bk1;

 

/