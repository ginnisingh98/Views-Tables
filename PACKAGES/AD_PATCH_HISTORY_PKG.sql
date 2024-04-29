--------------------------------------------------------
--  DDL for Package AD_PATCH_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PATCH_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: adphmnts.pls 115.4 2002/12/11 23:08:28 wjenkins ship $ */


-- PROCEDURE backfill_onsite_versions:
-- Walks back in time and fills the onsite-versions of certain actions.
--
-- If p_min_run_date is null, then it looks at the entire history, otherwise
-- only looks at patch runs since p_min_run_date (inclusive).
--
-- Commits?: Yes
--
procedure backfill_onsite_versions
           (p_min_run_date date);


-- PROCEDURE bld_cf_repos_using_upload_hist:
-- Inserts into AD_CHECK_FILES using information uploaded from applptch.txt.
-- Does something ONLY if the checkfile repository is empty AND is some patch
-- history information exists.
--
-- Commits?: Yes
--
procedure bld_cf_repos_using_upload_hist
           (anything_inserted out nocopy number);


end ad_patch_history_pkg;

 

/
