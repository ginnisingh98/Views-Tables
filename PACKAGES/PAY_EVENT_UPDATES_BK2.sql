--------------------------------------------------------
--  DDL for Package PAY_EVENT_UPDATES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_UPDATES_BK2" AUTHID CURRENT_USER as
/* $Header: pypeuapi.pkh 120.1 2005/10/02 02:32:43 aroussel $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< update_event_update_b >------------------|
-- ---------------------------------------------------------------------
--
procedure update_event_update_b
 ( p_effective_date                 in     date
  ,p_event_update_id              in     number
  ,p_object_version_number        in  number
  ,p_dated_table_id               in     number
  ,p_change_type                  in     varchar2
  ,p_table_name                   in     varchar2
  ,p_column_name                  in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_event_type                   in     varchar2
  );
-- ----------------------------------------------------------------------
-- |---------------------< update_event_update_a >------------------|
-- ---------------------------------------------------------------------
--
procedure update_event_update_a
 ( p_effective_date                 in     date
  ,p_event_update_id              in     number
  ,p_object_version_number        in  number
  ,p_dated_table_id               in     number
  ,p_change_type                  in     varchar2
  ,p_table_name                   in     varchar2
  ,p_column_name                  in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_event_type                   in     varchar2
  );
end pay_event_updates_bk2;

 

/
