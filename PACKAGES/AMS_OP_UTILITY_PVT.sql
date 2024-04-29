--------------------------------------------------------
--  DDL for Package AMS_OP_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_OP_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: amsoputs.pls 120.0 2005/05/31 14:37:29 appldev noship $ */

------------------------------------------------------------------------------
-- HISTORY
--   05/08/2001    rmajumda    Created
--
------------------------------------------------------------------------------


---------------------------------------------------------------------
-- FUNCTION
--   get_root_section_level
--
-- PURPOSE
--   Returns the level number of the root section with respect to
--   the master mini site. The root section is derived from the
--   given mini site.
--
-- NOTES
--    1. It will return the level_number of the root section
--    2. It will return 0 if no data found
---------------------------------------------------------------------
FUNCTION get_root_section_level(
   p_mini_site_id     IN      Number
)
RETURN Number;

END AMS_OP_UTILITY_PVT;

 

/
