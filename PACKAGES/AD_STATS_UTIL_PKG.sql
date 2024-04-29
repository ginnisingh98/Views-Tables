--------------------------------------------------------
--  DDL for Package AD_STATS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_STATS_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: adustats.pls 115.1 2002/12/10 23:35:06 wjenkins ship $ */

--
-- procedure gather_stats_if_necessary:
--
-- Gather stats if necessary for a given subsystem, based on the count
-- inserted in this run.
--
-- p_gather_stats_flag = FALSE => Maintain the counts as usual but dont
-- actually gather the stats.
--
-- If p_gather_stats_flag is TRUE, then p_commit_flag is ignored.
--
-- p_gathered_stats_flag is passed back indicating whether stats were actually
-- gathered or not.
--
procedure gather_stats_if_necessary
           (p_subsystem_code                    varchar2,
            p_rows_inserted_this_run            number,
            p_gather_stats_flag                 boolean,
            p_commit_flag                       boolean,
            p_gathered_stats_flag    out nocopy boolean);


end ad_stats_util_pkg;

 

/
