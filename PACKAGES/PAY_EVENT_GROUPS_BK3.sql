--------------------------------------------------------
--  DDL for Package PAY_EVENT_GROUPS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_GROUPS_BK3" AUTHID CURRENT_USER as
/* $Header: pyevgapi.pkh 120.3 2005/10/24 01:00:46 adkumar noship $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< delete_event_group_b  >------------------|
-- ---------------------------------------------------------------------
--
procedure delete_event_group_b
 ( p_event_group_id                 in     number
  ,p_object_version_number          in number
 );
--
-- ----------------------------------------------------------------------
-- |---------------------< delete_event_group_a  >----------------------|
-- ---------------------------------------------------------------------
--
procedure delete_event_group_a
 ( p_event_group_id                 in     number
  ,p_object_version_number          in number
 );
--
end pay_event_groups_bk3;

 

/
