--------------------------------------------------------
--  DDL for Package WSMPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPLOAD" AUTHID CURRENT_USER AS
/* $Header: WSMLOADS.pls 120.0.12010000.1 2008/07/29 02:08:28 appldev ship $ */

    /*-----------------------------------------------------------------+
    | Globals:                                                         |
    +-----------------------------------------------------------------*/

    G_GROUP_ID      NUMBER := NULL;
    G_HEADER_ID      NUMBER := NULL; -- xleSplit
    l_user_id number      := FND_GLOBAL.USER_ID;
    l_login_id number     := FND_GLOBAL.LOGIN_ID;
    l_request_id number   := FND_GLOBAL.CONC_REQUEST_ID;
    l_prog_appl_id number := FND_GLOBAL.PROG_APPL_ID;
    l_program_id number   := FND_GLOBAL.CONC_PROGRAM_ID;
    l_debug varchar2(1)   := FND_PROFILE.VALUE('MRP_DEBUG');

    /*-----------------------------------------------------------------+
    | Load:                                                            |
    | Procedure call for mass load of split/merge transactions stored  |
    | in wip_split_merge_tnx_interface table.                          |
    |                                                                  |
    | To execute the interface for a limited number of records         |
    | populate group_id during interfacing the records and call LOAD   |
    | with x_group_id parameter populated. LOAD picks up pending       |
    | records with null group_id if x_group_id is null.                |
    |                                                                  |
    +-----------------------------------------------------------------*/
    PROCEDURE LOAD(ERRBUF       OUT NOCOPY VARCHAR2,
                   RETCODE      OUT NOCOPY NUMBER,
                   p_copy_qa     IN VARCHAR2,
                   p_group_id    IN NUMBER
                   );

    -- Start: Added overloaded procedure for APS-WLT --
    PROCEDURE LOAD(ERRBUF       OUT NOCOPY VARCHAR2,
                   RETCODE      OUT NOCOPY NUMBER,
                   p_copy_qa     IN VARCHAR2,
                   p_group_id    IN NUMBER,
                   p_copy_flag   IN NUMBER
                   );
    -- End: Added overloaded procedure for APS-WLT --

END WSMPLOAD;

/
