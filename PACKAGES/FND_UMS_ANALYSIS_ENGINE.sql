--------------------------------------------------------
--  DDL for Package FND_UMS_ANALYSIS_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_UMS_ANALYSIS_ENGINE" AUTHID CURRENT_USER as
/* $Header: AFUMSAES.pls 120.1 2005/07/02 04:20:42 appldev noship $ */

-- modes:

-- normal (the default)

MODE_NORMAL constant varchar2(30) := 'NORMAL';

-- debug mode producing a more extensive report

MODE_DEBUG constant varchar2(30) := 'DEBUG';

-- dependency analysis status codes:

-- all patches already (implicitly or explicitly) applied

STATUS_APPLIED constant varchar2(30) := 'APPLIED';

-- at least one patch is not (implicitly or explicitly) applied and
-- no prereqs are missing

STATUS_READY constant varchar2(30) := 'READY';

-- at least one top-level bugfix doesn't have data in the UMS repository

STATUS_NO_INFORMATION constant varchar2(30) := 'NO_INFORMATION';

-- at least one prereq is missing

STATUS_MISSING constant varchar2(30) := 'MISSING';

-- at least one patch in the list of patches has been obsoleted

STATUS_OBSOLETED constant varchar2(30) := 'OBSOLETED';

-- data or internal error

STATUS_ERROR constant varchar2(30) := 'ERROR';

--------------------------------------------------------------------------------
-- Analyzes the dependency information of merged bugs to find out if there are
-- any prereqs that need to be applied along with the current merged bugs.
-- The resulting list of bugs should be merged with the current merged bugs.
--
-- Following algorithm is used to derive x_status:
--
-- If there is an error then ERROR,
-- else if merge patch contains an obsolete patch then OBSOLETED,
-- else if there is a missing prereq then MISSING,
-- else if merge patch contains an un-applied non-UMS bugfix then NO_INFORMATION,
-- else if merge patch contains an un-applied patch then READY
-- else (all merged patches are applied) then APPLIED.
--
-- p_appl_top_id - the application top id
-- p_release_name - the release name (e.g., '11i')
-- p_bug_numbers - the comma-separated list of bug numbers and language codes
--    (e.g., '1234567:US,2345678:US,2345678:TR,3456789:NLS_F'
--    from which to begin the analysis. The language code for an NLS bugfix is
--    prefixed with 'NLS_' keyword.
-- p_mode - the mode (e.g., MODE_NORMAL, MODE_DEBUG)
-- x_status - the status
--------------------------------------------------------------------------------
procedure analyze_dependencies(p_appl_top_id  in  number,
                               p_release_name in  varchar2,
                               p_bug_numbers  in  varchar2,
                               p_mode         in  varchar2,
                               x_status       out nocopy varchar2);

--------------------------------------------------------------------------------
-- Returns a comma-separated list of the missing prereqs.
-- analyze_dependencies must be called first.
-- e.g.: '12345,12346,12347'
--
-- return: a comma-separated list of the missing prereqs.
-- exception: if analyze_dependencies is not called,
--            or it returned STATUS_OBSOLETED or STATUS_ERROR.
--------------------------------------------------------------------------------
function get_prereq_list return varchar2;

--------------------------------------------------------------------------------
-- Gets the number of pieces of the report.
--
-- return: the number of pieces of the report
--------------------------------------------------------------------------------
function get_report_count return number;

--------------------------------------------------------------------------------
-- Gets the specified piece of the report.
--
-- i - the one-based index of the piece to get
--
-- return: the specified piece of the report
--------------------------------------------------------------------------------
function get_report(i in number) return varchar2;

end fnd_ums_analysis_engine;

 

/
