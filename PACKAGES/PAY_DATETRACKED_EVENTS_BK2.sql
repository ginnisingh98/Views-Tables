--------------------------------------------------------
--  DDL for Package PAY_DATETRACKED_EVENTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DATETRACKED_EVENTS_BK2" AUTHID CURRENT_USER as
/* $Header: pydteapi.pkh 120.1 2005/10/02 02:30:27 aroussel $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< update_datetracked_event_b  >------------------|
-- ---------------------------------------------------------------------
--
procedure  update_datetracked_event_b
 ( p_effective_date               in     date
  ,p_datetracked_event_id         in     number
  ,p_object_version_number        in     number
  ,p_event_group_id               in     number
  ,p_dated_table_id               in     number
  ,p_update_type                  in     varchar2
  ,p_column_name                  in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_proration_style              in     varchar2
  );
--
-- ----------------------------------------------------------------------
-- |---------------------< update_datetracked_event_a  >------------------|
-- ----------------------------------------------------------------------
--
procedure update_datetracked_event_a
 ( p_effective_date               in     date
  ,p_datetracked_event_id         in     number
  ,p_object_version_number        in     number
  ,p_event_group_id               in     number
  ,p_dated_table_id               in     number
  ,p_update_type                  in     varchar2
  ,p_column_name                  in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_proration_style              in     varchar2
  );
--
end pay_datetracked_events_bk2;

 

/
