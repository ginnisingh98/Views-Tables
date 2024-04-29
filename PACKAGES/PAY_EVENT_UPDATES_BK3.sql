--------------------------------------------------------
--  DDL for Package PAY_EVENT_UPDATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_UPDATES_BK3" AUTHID CURRENT_USER as
/* $Header: pypeuapi.pkh 120.1 2005/10/02 02:32:43 aroussel $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< delete_event_update_b >------------------|
-- ---------------------------------------------------------------------
--
procedure delete_event_update_b
  (p_event_update_id              in     number
  ,p_object_version_number        in  number
  );
-- ----------------------------------------------------------------------
-- |---------------------< delete_event_update_a >------------------|
-- ---------------------------------------------------------------------
--
procedure delete_event_update_a
  (p_event_update_id              in     number
  ,p_object_version_number        in  number
  );
end pay_event_updates_bk3;

 

/
