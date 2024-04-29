--------------------------------------------------------
--  DDL for Package HR_CALENDAR_ENTRY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CALENDAR_ENTRY_BK3" AUTHID CURRENT_USER as
/* $Header: peentapi.pkh 120.0 2005/05/31 08:08:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_calendar_entry_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_calendar_entry_b
  (p_calendar_entry_id             in      number
  ,p_object_version_number         in      number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_calendar_entry_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_calendar_entry_a
  (p_calendar_entry_id             in      number
  ,p_object_version_number         in      number
  );

end HR_CALENDAR_ENTRY_BK3;

 

/
