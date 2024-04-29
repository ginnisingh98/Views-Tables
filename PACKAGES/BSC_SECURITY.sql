--------------------------------------------------------
--  DDL for Package BSC_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SECURITY" AUTHID CURRENT_USER AS
/* $Header: BSCSSECS.pls 120.2 2006/01/24 16:07:29 calaw noship $ */

/*-------------------------------------------------------------------------+
 | PUBLIC  CONSTANTS                                                       |
 +-------------------------------------------------------------------------*/

-- User Types

DB_USER_TYPE         CONSTANT NUMBER(1) := 0;
BSCADMIN_TYPE        CONSTANT NUMBER(1) := 1;
SYSADMIN_TYPE        CONSTANT NUMBER(1) := 2;

-- Error Message Types (from BSC_MESSAGE_LOGS)

DB_ERR_MSG           CONSTANT NUMBER := 0;
APP_ERR_MSG          CONSTANT NUMBER := 1;
WARN_ERR_MSG         CONSTANT NUMBER := 2;
INFO_ERR_MSG         CONSTANT NUMBER := 3;
DEBUG_ERR_MSG        CONSTANT NUMBER := 4;

CRLF                 CONSTANT VARCHAR2(1) := '
';

--
-- This package-level pragma means that the initialization section of this
-- package cannot write any DB or package status
--
-- Currently, this package has no initialization section
--

pragma restrict_references (bsc_security, WNPS, WNDS);

--
-- Name
--   get_user_info
-- Purpose
--   Gets user_pwd, user_type and scheme un/pwd for OBSC and UBSC users.
--
-- Arguments
--   x_user_name
--   x_user_pwd
--   x_user_id
--   x_user_type
--   x_obsc_un
--   x_obsc_pwd
--   x_ubsc_un
--   x_ubsc_pwd
--   x_debug_flag
--   x_status
--   x_calling_fn
--

PROCEDURE get_user_info(
                x_user_name  IN     VARCHAR2,
                x_user_pwd   IN OUT NOCOPY VARCHAR2,
                x_user_id    IN OUT NOCOPY NUMBER,
                x_user_type  IN OUT NOCOPY NUMBER,
                x_obsc_un    IN OUT NOCOPY VARCHAR2,
                x_obsc_pwd   IN OUT NOCOPY VARCHAR2,
                x_ubsc_un    IN OUT NOCOPY VARCHAR2,
                x_ubsc_pwd   IN OUT NOCOPY VARCHAR2,
                x_debug_flag IN     VARCHAR2 := 'NO',
                x_status     IN OUT NOCOPY BOOLEAN,
                x_calling_fn IN     VARCHAR2);

-- Overloaded procedure for VB code, since VB cannot read from PL/SQL
-- parameters.

PROCEDURE get_user_info(
                x_sid        IN VARCHAR2,
                x_user_name  IN VARCHAR2,
                x_debug_flag IN VARCHAR2 := 'NO',
                x_calling_fn IN VARCHAR2);

--
-- Name
--   Check_System_Lock
-- Purpose
--   Enforce system locking for all OBSC models
-- Note
--   OBSC client applications should call this procedure identify
--   and register itself at v$session view, and to obtain the lock
--   of the system after it connects to database.
--   The following rules are enforced in the locking:
--     1. Loader, Optimizer, Security Wizard, Designer, Builder:
--        a. only one process can run on the system at any given
--           point of time.
--        b. no other process can run while this process is running
--
--     2. iViewer, Viewer (in user mode):
--        a. multiple Viewer processes can run on the system at the
--           same time
--        b. no other process can run while Viewer is running
--
-- Parameter:
--   x_program_id - program identifier, has the following value
--                   a. Loader                              =  -100
--                   b. Metadata Optimizer                  =  -200
--                   c. Security Wizard                     =  -300
--                   d. KPI Designer                        =  -400
--                   e. BSC Builder                         =  -500
--                   f. iViewer or VB Viewer (in user mode) =  -600
--   x_debug_flag  - debug flag
--   x_user_id     - Session Management, passed by OA Fwk for user name
--   x_icx_session_id - Session Management, passed by OA Fwk from IBuilder only
--                      Other OBSC clients will the first 3 parms.

Procedure Check_System_Lock(
        x_program_id        IN  Number,
        x_debug_flag            IN      Varchar2 := 'NO',
        x_user_id               IN      Number  :=NULL,
        x_icx_session_id        IN      Number  :=NULL
);


--
-- Name
--   Refresh_System_Lock
-- Purpose
--   Cleanup BSC_CURRENT_SESSIONS table before acquiring locks
--   Called by BSC_SECURITY.CHECK_SYSTEM_LOCK and BSC_LOCKS_PUB.GET_SYSTEM_LOCK
--   1) Delete all orphan the sessions
--   2) Delete all the session not being reused by FND
--   3) Delete all sessions, which have their concurrent programs in invalid or hang status
--   4) Kill IViewer Sessions that have been INACTIVE more than 20 minutes
--   5) Delete all the Killed Sessions
--
-- Parameter:
--   p_program_id - program identifier

Procedure Refresh_System_Lock(
    p_program_id      IN      Number
);


--
-- Name
--   Check_Source_System_Lock
-- Purpose
--   Enforce system locking for all OBSC models in the source system
--   This is issued by Migration (-800)
--
-- Parameter:
--   x_debug_flag  - debug flag

Procedure Check_Source_System_Lock(
        x_debug_flag            IN      Varchar2 := 'NO'
);


--
-- Name
--   Delete_Bsc_Session
-- Purpose
--   Delete the current session from BSC_CURRENT_SESSIONS table.

PROCEDURE Delete_Bsc_Session;

--
-- Name
-- Delete from BSC_CURRENT_SESSION using ICX Session ID

PROCEDURE Delete_Bsc_Session_ICX(
        p_icx_session_id        IN              NUMBER
);


--
-- Name
--   user_has_lock
-- Purpose
--   Return Y if user holds locks
--       else return N
-- Parameter:
--   x_SID - Sessuib ID that user currently belongs

FUNCTION user_has_lock(
  X_SID in NUMBER) RETURN VARCHAR2;

--
-- Name
--   user_has_lock
-- Purpose
--   Return Y if user holds locks
--       else return N
-- Parameter:
--   x_SID - Sessuib ID that user currently belongs
--   x_Schema - BSC schema name performance improvement

FUNCTION user_has_lock (
  X_SID in NUMBER,  X_SCHEMA IN VARCHAR2) RETURN VARCHAR2;

--
-- Name
--   can_meta_run
-- Purpose
--   Return Y if no user holds any locks and Meta Optimizer can start running
--       else return N
--

FUNCTION can_meta_run RETURN VARCHAR2;

--
-- Name
--   is_meta_inside
-- Purpose
--   Return Y if Meta Optimizer is inside the system
--       else return N

FUNCTION is_meta_inside RETURN VARCHAR2;

END bsc_security;

 

/
