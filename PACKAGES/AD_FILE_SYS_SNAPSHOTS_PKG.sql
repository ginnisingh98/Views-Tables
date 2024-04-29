--------------------------------------------------------
--  DDL for Package AD_FILE_SYS_SNAPSHOTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_FILE_SYS_SNAPSHOTS_PKG" AUTHID CURRENT_USER as
/* $Header: adfssnps.pls 120.0.12010000.1 2008/07/25 08:03:18 appldev ship $ */

-- ACTION code to use when inserting into the temp table for use with
-- update_current_view() with p_patch_runs_spec = 'IN_TEMP_TAB'

G_PR_ID_ACT_CD constant number := 20;


-- return codes when instantiating a current-view snapshot

G_SNAPSHOT_MAINT_DISALLOWED  constant varchar2(2) := 'NA';
G_ALREADY_INSTANTIATED       constant varchar2(2) := 'AI';
G_NO_PRESEEDED_BASELINE      constant varchar2(3) := 'NPB';
G_INSTANTIATED_SNAPSHOT      constant varchar2(2) := 'IS';
G_INSTANTIATED_SNAPSHOT_BUGS constant varchar2(3) := 'ISB';


-- Returns TRUE if we are allowed to maintain snapshots (using a temporary
-- strategy)
function snapshot_maint_allowed return boolean;

-- Update curr-vw snapshot using info from a single patch run
--   Pre-req: Temp table AD_PTCH_HST_EXE_COP_TMP must be empty
procedure update_current_view
           (p_patch_run_id number,
            p_appl_top_id  number default null);

-- Update curr-vw snapshot using info from a set of patch runs
--   Pre-req: Temp table AD_PTCH_HST_EXE_COP_TMP must be populated with
--            (only) the patch-run-id's (if called in IN_TEMP_TAB mode)


-- patch-runs specifier: 'IN_TEMP_TAB' or 'ALL'
procedure update_current_view
           (p_patch_runs_spec          varchar2,
            p_appl_top_id              number,
            p_caller_is_managing_locks boolean);

-- Instantiate a current-view
-- Note: See return-code "constants" above.
-- Note2: This procedure ALWAYS commits.
procedure instantiate_current_view
           (p_release_id                           number,
            p_appl_top_id                          number,
            p_fail_if_no_preseeded_rows            boolean default TRUE,
            p_caller_is_managing_locks             boolean default FALSE,
            p_return_code               out nocopy varchar2);

-- BUG 3402506  - sallamse , 02-03-04
-- Backfill the current-view snapshot if necessary.
-- Note: See return-code "constants" above.
-- Note2: This procedure ALWAYS commits.
procedure backfill_bugs_from_patch_hist
           (p_snapshot_id number);

procedure update_rel_name(rel_name varchar2);

end ad_file_sys_snapshots_pkg;

/
