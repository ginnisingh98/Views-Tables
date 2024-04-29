--------------------------------------------------------
--  DDL for Package GHR_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_EVENTS_PKG" AUTHID CURRENT_USER as
/* $Header: ghrwseve.pkh 120.0.12010000.3 2009/05/26 12:06:09 utokachi noship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< GHR_EVENTS_PKG >--------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure contains the code associated to the form GHRWSEVE.
--    Procedure get_next_event_id will return the next value from sequence ghr_events_s.
--	Procedure delete_check will return a boolean TRUE if the event_id can be deleted.
--
--
--  Pre Conditions:
--
--
--  In Arguments:
--    p_event_id passes the ghr_events.event_id (delete_check)
--
--
--  OUT Arguments:
-- 	get_next_event_id out is ghr_events_s.nextval
--	delete_ok out is boolean TRUE = OK to delete, FALSE = Stop Delete
--
--
--  Post Success:
--
--
--  Post Failure:
--
--
--  Developer Implementation Notes:
--
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION get_next_event_id
RETURN NUMBER;
--
--
FUNCTION delete_ok
  (p_event_id     IN  ghr_events.event_id%TYPE)
   RETURN BOOLEAN;
--
--
end ghr_events_pkg;

/
