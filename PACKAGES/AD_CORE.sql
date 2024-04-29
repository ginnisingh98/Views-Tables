--------------------------------------------------------
--  DDL for Package AD_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_CORE" AUTHID CURRENT_USER as
/* $Header: aducores.pls 115.1 2003/05/22 19:01:12 kksingh noship $ */

-- Given an elapsed time in days (such as that returned by subtracting 2
-- dates in SQL), return the formatted value in Hrs/Mins/Secs.
--   Supported format_modes: 1, 2
--     1 => Always display hrs, min, secs
--       eg: 0.00030093 days is displayed as 0 Hrs, 0 Mins, 26 Secs
--     2 => Only display applicable units
--       eg: 0.00030093 days is displayed as 26 Secs

function get_formatted_elapsed_time
(
  p_ela_days number,
  p_format_mode number
) return varchar2;

pragma restrict_references (get_formatted_elapsed_time, wnds, rnds,
                                                        wnps, rnps);

end ad_core;

 

/

  GRANT EXECUTE ON "APPS"."AD_CORE" TO "AD_PATCH_MONITOR_ROLE";
