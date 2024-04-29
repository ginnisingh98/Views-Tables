--------------------------------------------------------
--  DDL for Package AML_INTERACTION_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_INTERACTION_ENGINE" AUTHID CURRENT_USER as
/* $Header: amlitens.pls 115.1 2003/10/22 02:21:39 solin ship $ */

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC CONSTANTS
 |
 *-------------------------------------------------------------------------*/
G_LOOKBACK_DAYS    NUMBER := 30;



/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC DATATYPES
 |
 *-------------------------------------------------------------------------*/
TYPE INTERACTION_REC_TYPE IS RECORD (
    interaction_id         NUMBER := FND_API.G_MISS_NUM,
    party_id               NUMBER := FND_API.G_MISS_NUM);

TYPE INTERACTION_TBL_TYPE IS TABLE OF INTERACTION_REC_TYPE
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


/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/
PROCEDURE Run_Interaction_Engine(
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY VARCHAR2,
    p_debug_mode       IN  VARCHAR2,
    p_trace_mode       IN  VARCHAR2);

END AML_INTERACTION_ENGINE;

 

/
