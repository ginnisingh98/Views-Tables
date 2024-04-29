--------------------------------------------------------
--  DDL for Package AS_GAR_OPPTYS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_GAR_OPPTYS_PUB" AUTHID CURRENT_USER as
/* $Header: asxgrops.pls 120.1 2005/08/21 08:54 subabu noship $ */
/*-------------------------------------------------------------------------*
 |                             PUBLIC CONSTANTS
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC DATATYPES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC VARIABLES
 *-------------------------------------------------------------------------*/

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

PROCEDURE EXPLODE_TEAMS_OPPTYS(
          x_errbuf       OUT NOCOPY VARCHAR2,
          x_retcode       OUT NOCOPY VARCHAR2,
          p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
          x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE EXPLODE_GROUPS_OPPTYS(
          x_errbuf        OUT NOCOPY VARCHAR2,
          x_retcode       OUT NOCOPY VARCHAR2,
          p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
          x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE SET_TEAM_LEAD_OPPTYS(
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY VARCHAR2,
        p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
        x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_ACCESSES_OPPTYS(
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY VARCHAR2,
        p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
        x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_TERR_ACCESSES_OPPTYS(
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY VARCHAR2,
        p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
        x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE PERFORM_OPPTY_CLEANUP(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE ASSIGN_OPPTY_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2);

END AS_GAR_OPPTYS_PUB;

 

/
