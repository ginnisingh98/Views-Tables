--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATION_EVENTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATION_EVENTS_BK1" AUTHID CURRENT_USER as
/* $Header: pqvleapi.pkh 120.1 2005/10/02 02:28:47 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_Validation_event_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_Validation_event_b
  (p_effective_date               in     date
  ,p_validation_id                  in     number
  ,p_event_type                     in     varchar2
  ,p_event_code                     in     varchar2
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_comments                       in     varchar2);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_Validation_event_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_Validation_event_a
  (p_effective_date               in     date
  ,p_validation_id                  in     number
  ,p_event_type                     in     varchar2
  ,p_event_code                     in     varchar2
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_comments                       in     varchar2);

 --
end pqh_fr_validation_events_bk1;

 

/
