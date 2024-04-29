--------------------------------------------------------
--  DDL for Package AS_GAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_GAR" AUTHID CURRENT_USER as
/* $Header: asxgarps.pls 120.0 2005/08/05 01:15 subabu noship $ */
---------------------------------------------------------------------------
--    Start of Comments
---------------------------------------------------------------------------
--    PACKAGE NAME:   AS_GAR
--    ---------------------------------------------------------------------
--    NOTES
--    -----
--    1: This package contains all the common procedures and functions
--       called from within the individual entity packages.
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
    run_mode                VARCHAR2(7),
    worker_id               NUMBER,
    bulk_size               NUMBER,
    cursor_limit            NUMBER,
    oppor_territories_exist VARCHAR2(1),
    lead_territories_exist VARCHAR2(1));

/*-------------------------------------------------------------------------*
 |                             PUBLIC VARIABLES
 *-------------------------------------------------------------------------*/

G_TAP_FLAG VARCHAR2(1) := 'N';
G_NEW_MODE            VARCHAR2(3) := 'NEW';
G_TOTAL_MODE          VARCHAR2(5) := 'TOTAL';
G_DEBUG_FLAG          VARCHAR2(1) := 'N';
/*-------------------------------------------------------------------------*
|                  DEBUG MESSAGES
*--------------------------------------------------------------------------*/
G_CALL_TO              VARCHAR2(10) := 'CALL TO:: ';
G_PROCESS              VARCHAR2(12) := 'PROCEDURE:: ';
G_START                VARCHAR2(5) :=  'START';
G_END                  VARCHAR2(3) :=  'END';
G_GENERAL_EXCEPTION    VARCHAR2(25) := 'GENERAL EXCEPTION OCCURED';
G_RETURN_STATUS        VARCHAR2(17) := 'RETURN STATUS :- ';
G_SQLCODE              VARCHAR2(11) := 'SQLCODE :- ';
G_SQLERRM              VARCHAR2(11) := 'SQLERRM :- ';
G_N_ROWS_PROCESSED     VARCHAR2(20) :=  '# ROWS PROCESSED :- ';
G_INS_WINNERS          VARCHAR2(21) := 'INSERT INTO WINNERS::';
G_UPD_ACCESSES         VARCHAR2(17) := 'UPDATE ACCESSES::';
G_DEADLOCK             VARCHAR2(31) := 'DEADLOCK DETECTED::ATTEMPTS :- ';
G_BULK_INS             VARCHAR2(13) := 'BULK INSERT::';
G_BULK_UPD             VARCHAR2(13) := 'BULK UPDATE::';
G_BULK_DEL             VARCHAR2(13) := 'BULK DELETE::';
G_IND_INS              VARCHAR2(19) := 'INDIVIDUAL INSERT::';
G_IND_UPD              VARCHAR2(19) := 'INDIVIDUAL UPDATE::';
G_IND_DEL              VARCHAR2(19) := 'INDIVIDUAL DELETE::';

G_CW		  VARCHAR2(23) := 'GET_WINNERS_PARALLEL:: ';
G_CEX_GROUPS		   VARCHAR2(17) := 'EXPLODE GROUPS:: ';
G_CEX_TEAMS		   VARCHAR2(16) := 'EXPLODE TEAMS:: ';
G_STLEAD		    VARCHAR2(19) := 'SET TEAM LEADER:: ';
G_INSACC		    VARCHAR2(30) := 'INSERT INTO ENTITY ACCESSES:: ';
G_INSTERRACC		    VARCHAR2(33) := 'INSERT INTO TERRITORY ACCESSES:: ';
G_CPPR		    VARCHAR2(26) := 'PROCESS_PARTNER_RECORDS:: ';
G_CC		  VARCHAR2(18) := 'PERFORM_CLEANUP:: ';
G_CO		  VARCHAR2(19) := 'OWNER_ASSIGNMENT:: ';
G_CBE_EXISTS             VARCHAR2(25) := 'EVENT SUBSCRIPTION EXISTS';
G_CBE_RAISE              VARCHAR2(10) := 'RAISING BE';
G_SETAREASIZE          VARCHAR2(20) := 'Set Area Size';
/*-------------------------------------------------------------------------*
 |                             PUBLIC ROUTINES
 *-------------------------------------------------------------------------*/
PROCEDURE Init(
    p_run_mode        IN  VARCHAR2,
    p_worker_id       IN  VARCHAR2,
    px_terr_globals  IN OUT NOCOPY AS_GAR.TERR_GLOBALS);
FUNCTION Exist_Subscription(p_event_name IN VARCHAR2) return VARCHAR2;
PROCEDURE Raise_BE(p_terr_globals IN OUT NOCOPY AS_GAR.TERR_GLOBALS);
PROCEDURE LOG_Exception(
    msg IN VARCHAR2, errbuf IN VARCHAR2, retcode IN VARCHAR2);
PROCEDURE SETTRACE;
PROCEDURE LOG(msg in VARCHAR2);
PROCEDURE Set_Area_Sizes;
END AS_GAR;

 

/
