--------------------------------------------------------
--  DDL for Package IEX_ATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_ATA_PUB" AUTHID CURRENT_USER AS
/* $Header: iextpins.pls 120.5.12010000.2 2009/07/31 09:33:20 pnaveenk ship $ */

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC CONSTANTS
 |
 *-------------------------------------------------------------------------*/
G_QUALIFIER_CODE_SIZE NUMBER := 30; -- size of qualifier_code

-- flag for NEW MODE in running program
G_NEW_MODE            VARCHAR2(11) := 'NEW';

-- flag for TOTAL MODE in running program
G_TOTAL_MODE          VARCHAR2(5) := 'TOTAL';

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC DATATYPES
 |
 *-------------------------------------------------------------------------*/
TYPE IEX_GLOBALS IS RECORD (
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
    manager_has_access      VARCHAR2(1),
    num_acct_qual           NUMBER,
    num_oppor_qual          NUMBER,
    num_acct_oppor_qual     NUMBER,
    debug_flag              VARCHAR2(1),
    num_rollup_days         NUMBER,
    conversion_type         VARCHAR2(30),
    rec_to_commit           NUMBER,
    rec_to_open             NUMBER);

TYPE QUAL_LIST_REC_TYPE IS RECORD (
    seeded_qualifier_id     NUMBER,
    qualifier_code          VARCHAR2(30)
);

TYPE QUAL_LIST_TBL_TYPE IS TABLE OF QUAL_LIST_REC_TYPE
	INDEX BY BINARY_INTEGER;


/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC VARIABLES
 |
 *-------------------------------------------------------------------------*/

g_user_id                 NUMBER;
g_last_update_login       NUMBER;
g_prog_appl_id            NUMBER;
g_prog_id                 NUMBER;
g_request_id              NUMBER;
g_prev_request_id         NUMBER;
g_num_child_processes     NUMBER;
g_min_num_parallel_proc   NUMBER;
g_NumChildAccountWorker   NUMBER;
g_NumChildOpporWorker     NUMBER;
g_NumChildLeadWorker      NUMBER;
g_num_acct_qual           NUMBER;
g_num_acct_oppor_qual     NUMBER;
g_num_rollup_days         NUMBER;
g_conversion_type         VARCHAR2(30);
g_trace_mode              VARCHAR2(1);
g_debug_flag              VARCHAR2(1);
g_run_mode                VARCHAR2(15);
g_Mode                    VARCHAR2(30);
g_oppor_territories_exist VARCHAR2(1);
g_lead_territories_exist  VARCHAR2(1);
p_lead_status			  VARCHAR2(30);
p_opp_status			  VARCHAR2(30);

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/
--Bug5043777 Removed the parameters which is no longer in use.
PROCEDURE Assign_Territory_Accesses(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    P_ORG_ID              IN NUMBER,
    P_STR_LEVEL           IN VARCHAR2  -- added for bug 8708291 pnaveenk multi level strategy
);

PROCEDURE iex_DEBUG( msg in VARCHAR2);

PROCEDURE Set_Area_Sizes;


END IEX_ATA_PUB;

/
