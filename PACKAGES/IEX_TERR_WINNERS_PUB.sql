--------------------------------------------------------
--  DDL for Package IEX_TERR_WINNERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_TERR_WINNERS_PUB" AUTHID CURRENT_USER as
/* $Header: iexttwps.pls 120.0 2005/07/21 12:46:55 schekuri noship $ */
---------------------------------------------------------------------------
--    Start of Comments
---------------------------------------------------------------------------
--    PACKAGE NAME:   IEX_TERR_WINNERS_PUB
--    ---------------------------------------------------------------------
--    PURPOSE
--
--      Public Package for the concurrent program
--      "Generate Access Records".
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package to be used  by the dependent procedures
--             of  "Generate Access Records" conc job.
--
--    HISTORY
--      04/14/2002  AXAVIER Francis Xavier Created.
--      06/28/2003  SESUNDAR Modified for implementing parallel workers
--      11/10/2003  SESUNDAR Added cursor_limit for bug fix 3164624
--      11/11/2003  SESUNDAR Fixed bug#3194696
--	11/13/2003  MMUSUVAT Enh3100827, opp status parameter
--
---------------------------------------------------------------------------



/*-------------------------------------------------------------------------*
 |                             PUBLIC CONSTANTS
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC DATATYPES
 *-------------------------------------------------------------------------*/
TYPE TERR_GLOBALS IS RECORD (
    user_id                 NUMBER,
    last_update_login       NUMBER,
    prog_appl_id            NUMBER,
    prog_id                 NUMBER,
    request_id              NUMBER,
    prev_request_id         NUMBER,
    sequence                NUMBER,
    num_child_processes     NUMBER,
    min_num_parallel_proc   NUMBER,
    max_rank                NUMBER,
    run_mode                VARCHAR2(7),
    oppor_territories_exist VARCHAR2(1),
    lead_territories_exist VARCHAR2(1),
    manager_has_access      VARCHAR2(1),
    num_acct_qual           NUMBER,
    num_oppor_qual          NUMBER,
    num_lead_qual           NUMBER,
    num_acct_oppor_qual     NUMBER,
    num_acct_lead_qual      NUMBER,
    debug_flag              VARCHAR2(1),
    num_rollup_days         NUMBER,
    conversion_type         VARCHAR2(30),
    lead_status             VARCHAR2(7),
    opp_status              VARCHAR2(7),  -- mmusuvat, enh3100827
    enable_dups_rs_del      VARCHAR2(1),
    transaction_type        VARCHAR2(30),
    worker_id               NUMBER,
    actual_workers          NUMBER,
    num_child_account_worker       NUMBER,
    num_child_oppor_worker         NUMBER,
    num_child_lead_worker          NUMBER,
    bulk_size                      NUMBER,
    disable_lead_processing VARCHAR2(1),
    cursor_limit            NUMBER);


/*-------------------------------------------------------------------------*
 |                             PUBLIC VARIABLES
 *-------------------------------------------------------------------------*/
g_user_id                 NUMBER;
g_last_update_login       NUMBER;
g_prog_appl_id            NUMBER;
g_prog_id                 NUMBER;
g_request_id              NUMBER;
g_prev_request_id         NUMBER;
g_num_child_processes     NUMBER;
g_min_num_parallel_proc   NUMBER;
g_num_acct_qual           NUMBER;
g_num_oppor_qual          NUMBER;
g_num_lead_qual           NUMBER;
g_num_acct_oppor_qual     NUMBER;
g_num_acct_lead_qual      NUMBER;
g_num_rollup_days         NUMBER;
g_conversion_type         VARCHAR2(30);
g_debug_flag              VARCHAR2(1);
g_oppor_territories_exist VARCHAR2(1);
g_lead_territories_exist  VARCHAR2(1);
g_run_mode                VARCHAR2(7);

G_TAP_FLAG VARCHAR2(1) := 'N';

/*-------------------------------------------------------------------------*
 |                             PUBLIC ROUTINES
 *-------------------------------------------------------------------------*/
PROCEDURE Print_Debug( msg in VARCHAR2);
PROCEDURE Analyze_Table(
    schema IN VARCHAR2,
    table_name IN VARCHAR2,
    p_percent IN NUMBER );


END IEX_TERR_WINNERS_PUB;

 

/
