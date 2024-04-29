--------------------------------------------------------
--  DDL for Package Body PJI_LAUNCH_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_LAUNCH_EXT" AS
/* $Header: PJILN02B.pls 120.0.12010000.2 2009/08/28 07:20:18 dlella noship $ */
/** Called from : PJI_LAUNCH_UPP_MAIN.CREATE_UPP_BATCHES
    This function will override the project pickup logic of the Launch
    process ONLY for projects that are NOT linked to any program. For all
    projects linked to a program, the project pickup logic of Launch process
    CANNOT be overridden. This function has to return a PLSQL table of
    project_id's only. **/

PROCEDURE PROJ_LIST (p_prg_proj_tbl OUT NOCOPY  prg_proj_tbl,
                     p_context OUT NOCOPY  varchar2,
                     p_budget_lines_count OUT NOCOPY  number) IS

l_prg_proj_tbl    prg_proj_tbl;

BEGIN

/* The following variable can have only 2 values, INCREMENTAL and UPGRADE.
   For daily processing, this value will be INCREMENTAL. Only in an upgrade
   scenario, change this value to UPGRADE */
p_context := 'INCREMENTAL';

/*
p_context := 'UPGRADE';
Uncomment this and comment the above if running in upgrade scenario */

/** Sample code :
    This query will return a PLSQL table contaning project_id's of all such
    projects which have greater than 10,000 budget lines. Similar logic may
    be used to derive project_id's based on different conditions to override
    the project pick up logic of Launch process.

    SELECT proj_id BULK COLLECT
    INTO l_prg_proj_tbl
    FROM
        (SELECT proj_id, cnt
        FROM
            (SELECT pa.project_id proj_id,
            COUNT(bl.budget_version_id) cnt
            FROM pa_projects_all pa,
                 pa_budget_versions bv,
                 pa_budget_lines bl
            WHERE pa.project_id = bv.project_id
            AND bv.budget_version_id = bl.budget_version_id
            GROUP BY pa.project_id)
        WHERE cnt > 1000);
**/

p_prg_proj_tbl := l_prg_proj_tbl;

/* The following variable stores the number of budget lines that will be used
   as a reference while determining the batch size in Launch process.
   This division by budget lines is done for proper load balancing among
   batches created in Launch process and ensures that similar volumes of
   data is processed in each batch.
   An example would be to limit batch size to 200000 budget lines as below
p_budget_lines_count := 200000;
*/

p_budget_lines_count := 0;
/* Change the value of the above variable to divide batches by number of
   budget lines to process in each batch.
   Note that passing a value for this variable will ONLY be honoured
   when p_context = UPGRADE */

/* The following combination of extension parameters will be considered valid
   and will be used for creating batches :
   1. p_context = UPGRADE, p_budget_lines_count > 0, p_prg_proj_tbl.count > 0
   2. p_context = UPGRADE, p_budget_lines_count > 0, p_prg_proj_tbl.count = 0
   3. p_context = INCREMENTAL/UPGRADE(p_budget_lines_count=0), p_prg_proj_tbl.count > 0
   4. p_context = INCREMENTAL(p_budget_lines_count=0), p_prg_proj_tbl.count = 0
*/

END PROJ_LIST;

END PJI_LAUNCH_EXT;

/
