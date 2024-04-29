--------------------------------------------------------
--  DDL for Package AS_GAR_QOT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_GAR_QOT_PUB" AUTHID CURRENT_USER as
/* $Header: asxgrqts.pls 120.2 2005/09/30 02:16 subabu noship $ */
/*-------------------------------------------------------------------------*
 |                             PUBLIC CONSTANTS
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC DATATYPES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC VARIABLES
 *-------------------------------------------------------------------------*/
g_debug_flag              VARCHAR2(1);

/*-------------------------------------------------------------------------*
 |                             PUBLIC ROUTINES
 *-------------------------------------------------------------------------*/
PROCEDURE GAR_WRAPPER(
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_run_mode        IN  VARCHAR2,
    p_debug_mode      IN  VARCHAR2,
    p_trace_mode      IN  VARCHAR2,
    p_worker_id       IN  VARCHAR2,
    P_percent_analyzed  IN  NUMBER );

PROCEDURE EXPLODE_TEAMS_QOT(
          x_errbuf       OUT NOCOPY VARCHAR2,
          x_retcode       OUT NOCOPY VARCHAR2,
          p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
          x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE EXPLODE_GROUPS_QOT(
          x_errbuf        OUT NOCOPY VARCHAR2,
          x_retcode       OUT NOCOPY VARCHAR2,
          p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
          x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE SET_TEAM_LEAD_QOT(
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY VARCHAR2,
        p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
        x_return_status OUT NOCOPY VARCHAR2);
PROCEDURE SET_FAF_QOT(
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY VARCHAR2,
        p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
        x_return_status OUT NOCOPY VARCHAR2);
PROCEDURE INSERT_ACCESSES_QOT(
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY VARCHAR2,
        p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
        x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_TERR_ACCESSES_QOT(
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY VARCHAR2,
        p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
        x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE PERFORM_QOT_CLEANUP(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE ASSIGN_QOT_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2);

END AS_GAR_QOT_PUB;

 

/
