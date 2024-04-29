--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATION_EVENTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATION_EVENTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqvleapi.pkh 120.1 2005/10/02 02:28:47 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Validation_event_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Validation_event_b
  (p_validation_event_id                        in     number
  ,p_object_version_number                in     number);
 --
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Validation_event_a >-------------------------|
-- ----------------------------------------------------------------------------
--

Procedure Delete_Validation_event_a
  (p_validation_event_id                        in     number
  ,p_object_version_number                in     number);

end pqh_fr_validation_events_bk3;

 

/
