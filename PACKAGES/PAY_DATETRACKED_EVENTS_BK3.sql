--------------------------------------------------------
--  DDL for Package PAY_DATETRACKED_EVENTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DATETRACKED_EVENTS_BK3" AUTHID CURRENT_USER as
/* $Header: pydteapi.pkh 120.1 2005/10/02 02:30:27 aroussel $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< delete_datetracked_event_b  >-------------------------|
-- ---------------------------------------------------------------------
--
procedure delete_datetracked_event_b
 ( p_datetracked_event_id                 in     number
  ,p_object_version_number                in     number
  );
--
-- ----------------------------------------------------------------------
-- |---------------------< delete_datetracked_event_a >-------------------------|
-- ----------------------------------------------------------------------
--
procedure  delete_datetracked_event_a
 ( p_datetracked_event_id                 in     number
  ,p_object_version_number                in     number
  );
end pay_datetracked_events_bk3;

 

/
