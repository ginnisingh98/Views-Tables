--------------------------------------------------------
--  DDL for Package AS_GAR_LEADS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_GAR_LEADS_PUB" AUTHID CURRENT_USER as
/* $Header: asxgrlds.pls 120.1.12010000.2 2010/03/01 10:36:14 sariff ship $ */
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

PROCEDURE EXPLODE_TEAMS_LEADS(
          x_errbuf       OUT NOCOPY VARCHAR2,
          x_retcode       OUT NOCOPY VARCHAR2,
          p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
          x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE EXPLODE_GROUPS_LEADS(
          x_errbuf        OUT NOCOPY VARCHAR2,
          x_retcode       OUT NOCOPY VARCHAR2,
          p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
          x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE SET_TEAM_LEAD_LEADS(
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY VARCHAR2,
        p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
        x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_ACCESSES_LEADS(
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY VARCHAR2,
        p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
        x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_TERR_ACCESSES_LEADS(
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY VARCHAR2,
        p_terr_globals  IN  AS_GAR.TERR_GLOBALS,
        x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE PERFORM_LEAD_CLEANUP(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE ASSIGN_LEAD_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2);

-- three new procedure added for bug 8615468
PROCEDURE ASSIGN_DEFAULT_LEAD_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE UNCHECK_LEAD_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE UNCHECK_ASSIGN_SALESFORCE(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  AS_GAR.TERR_GLOBALS,
    x_return_status    OUT NOCOPY VARCHAR2);

END AS_GAR_LEADS_PUB;

/
