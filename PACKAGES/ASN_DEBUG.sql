--------------------------------------------------------
--  DDL for Package ASN_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASN_DEBUG" AUTHID CURRENT_USER AS
/* $Header: RCVDBUGS.pls 120.0.12010000.3 2010/01/25 19:41:47 vthevark ship $ */
/*===========================================================================
  PACKAGE NAME:      ASN_DEBUG

  DESCRIPTION:          Contains the routines needed to write debug messages
                        to a file

  CLIENT/SERVER:  Server

  LIBRARY NAME          NONE

  OWNER:                Raj Bhakta

  PROCEDURES/FUNCTIONS: PUT_LINE(v_line in varchar2))

===========================================================================*/

/*===========================================================================
  PROCEDURE NAME: PUT_LINE()

  DESCRIPTION:          Writes messages to a file

  PARAMETERS:           v_line in varchar2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Raj Bhakta       03/26/97   Created
===========================================================================*/
    PROCEDURE put_line(
        v_line  IN VARCHAR2,
        v_level IN VARCHAR2 DEFAULT fnd_log.level_error,
	v_inv_debug_level IN NUMBER DEFAULT 9 -- lcm changes
    );

    g_current_module    VARCHAR2(255)  := 'po.plsql.ASN_DEBUG';
    g_level             NUMBER         := 0;
    g_procedure_stack   VARCHAR2(4000) := '?                   ';
    g_current_procedure VARCHAR2(20)   := '?                   ';
    g_inv_debug_enabled VARCHAR2(1)    := fnd_profile.VALUE('INV_DEBUG_TRACE'); -- lcm changes
    FUNCTION get_debugging_enabled
        RETURN BOOLEAN;

    PROCEDURE set_module_name(
        module IN VARCHAR2
    );

    PROCEDURE start_procedure(
        procedure_name IN VARCHAR2
    );

    PROCEDURE stop_procedure(
        procedure_name     IN VARCHAR2,
        pop_this_procedure IN BOOLEAN DEFAULT TRUE
    );

    PROCEDURE print_stack;

    PROCEDURE debug_msg(
        line  IN VARCHAR2,
        LEVEL IN VARCHAR2 DEFAULT NULL,
        label IN VARCHAR2 DEFAULT NULL,
        inv_debug_level IN NUMBER DEFAULT 9       -- Bug 9152790: rcv debug enhancement

    );

    PROCEDURE debug_msg_ex(
        MESSAGE        IN VARCHAR2,
        module         IN VARCHAR2 DEFAULT NULL,
        procedure_name IN VARCHAR2 DEFAULT NULL,
        line_num       IN NUMBER DEFAULT NULL,
        LEVEL          IN VARCHAR2 DEFAULT NULL,
        INV_DEBUG_LEVEL IN NUMBER DEFAULT 9       -- Bug 9152790: rcv debug enhancement

    );

-- If you do not specify a level then it will use the last level specified
--   if there is no last level specified then it Will default to log level: Statement
-- If you do not specify a module then it will use the last module specified
--   if there is no last module specified then it Will default to module name: RCV
    PROCEDURE get_calling_module(
        p_module      OUT NOCOPY    VARCHAR2,
        p_procedure   OUT NOCOPY    VARCHAR2,
        p_label       OUT NOCOPY    VARCHAR2,
        p_stack_depth IN            NUMBER DEFAULT 2
    );

    FUNCTION is_debug_on RETURN VARCHAR2;        -- Bug 9152790: rcv debug enhancement

END asn_debug;

/
