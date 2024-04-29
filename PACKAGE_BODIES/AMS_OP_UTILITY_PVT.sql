--------------------------------------------------------
--  DDL for Package Body AMS_OP_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_OP_UTILITY_PVT" as
/* $Header: amsoputb.pls 120.0 2005/05/31 21:20:39 appldev noship $ */

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
RETURN Number

IS
cursor c_level_number
is
  select mss.level_number
  from ibe_dsp_msite_sct_sects mss
  where mss.child_section_id=
     (select msite_root_section_id
     from ibe_msites_b
     where msite_id=p_mini_site_id)
     and mss.mini_site_id =
	(select msite_id
         from ibe_msites_b
	 where master_msite_flag='Y');

l_level_number number;
BEGIN
   open c_level_number;
   fetch c_level_number into l_level_number;
   close c_level_number;

   if (l_level_number is null) then
      return 0;
   end if;

   RETURN l_level_number ;

EXCEPTION
   WHEN others THEN
      raise;
END;

END AMS_OP_UTILITY_PVT;

/
