--------------------------------------------------------
--  DDL for Package FND_OAM_DSCFG_PROCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCFG_PROCS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSCPROCS.pls 120.1 2005/11/23 17:02 yawu noship $ */

   ---------------
   -- Constants --
   ---------------
   -- Procedure Types are stored in DS_API_PKG

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- Accessor function, checks if internal state is initialized.
   -- Invariants:
   --   None
   -- Parameters:
   --   None
   -- Returns:
   --   Boolean where TRUE=Initialized
   -- Exceptions:
   --   None
   FUNCTION IS_INITIALIZED
      RETURN BOOLEAN;

   -- Accessor function, obtains the in-progress proc_id.
   -- Invariants:
   --   Only has a value during proc execution after GET_NEXT_PROC or SET_CURRENT_PROC has been called.
   -- Parameters:
   --   None
   -- Returns:
   --   The proc_id stored in the package state.
   -- Exceptions:
   --   If the proc state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_ID
      RETURN NUMBER;

   -- Accessor function, obtains the in-progress proc_type.
   -- Invariants:
   --   Only has a value during proc execution after GET_NEXT_PROC or SET_CURRENT_PROC has been called.
   -- Parameters:
   --   None
   -- Returns:
   --   The proc_type stored in the package state.
   -- Exceptions:
   --   If the proc state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_TYPE
      RETURN VARCHAR2;

   -- Accessor function, obtains the in-progress error_is_fatal_flag
   -- Invariants:
   --   Only has a value during proc execution after GET_NEXT_PROC or SET_CURRENT_PROC has been called.
   -- Parameters:
   --   None
   -- Returns:
   --   The error_is_fatal_flag stored in the package state.
   -- Exceptions:
   --   If the proc state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_ERROR_IS_FATAL
      RETURN VARCHAR2;

   -- Accessor function, obtains the currently executing proc's location
   -- Invariants:
   --   Only has a value during proc execution after GET_NEXT_PROC or SET_CURRENT_PROC has been called.
   -- Parameters:
   --   None
   -- Returns:
   --   The proc location stored in the package state.
   -- Exceptions:
   --   If the proc state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_LOCATION
      RETURN VARCHAR2;

   -- Accessor function, obtains the currently executing proc executable
   -- Invariants:
   --   Only has a value during proc execution after GET_NEXT_PROC or SET_CURRENT_PROC has been called.
   -- Parameters:
   --   None
   -- Returns:
   --   The proc executable stored in the package state.
   -- Exceptions:
   --   If the proc state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_EXECUTABLE
      RETURN VARCHAR2;

   -- This procedure obtains the next proc id for a given stage by iterating across the DS_PROCS table using
   -- a package state cursor.  It obeys START_DATE/END_DATE restriction and orders the results based on
   -- the priority.  If the provided stage doesn't match the last provided stage, the cursor is re-executed.
   -- Invariants:
   --   None
   -- Parameters:
   --   x_proc_id               proc_id of the next proc.
   --   x_proc_type             proc_type of the next proc.
   --   x_location              Location of the next proc.
   --   x_executable            Executable of the next proc.
   -- Return Statuses:
   --   Throws NO_DATA_FOUND when there are no more procs to fetch.
   PROCEDURE GET_NEXT_PROC(p_stage              IN VARCHAR2,
                           x_proc_id            OUT NOCOPY NUMBER,
                           x_proc_type          OUT NOCOPY VARCHAR2,
                           x_error_is_fatal     OUT NOCOPY VARCHAR2,
                           x_location           OUT NOCOPY VARCHAR2,
                           x_executable         OUT NOCOPY VARCHAR2);

   -- Procedure allowing the user to set the current proc by its id.  Initializes state so that calls
   -- to ADD_DIRECTIVE/ADD_MAPPED_KEY will include proc state.  Unnecessary if proc_id was the last one
   -- obtained from a call to GET_NEXT_PROC.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_proc_id       proc_id you want to set as the currently executing proc
   -- Return Statuses:
   --   Throws NO_DATA_FOUND if the proc_id is invalid.
   PROCEDURE SET_CURRENT_PROC(p_proc_id IN NUMBER);



   --procedures required by FNDLOADER

  procedure LOAD_ROW (
      X_PROC_ID             in NUMBER,
      X_PROC_TYPE           IN VARCHAR2,
      X_STAGE               IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_PRIORITY            IN NUMBER,
      X_ERROR_IS_FATAL_FLAG IN VARCHAR2,
      X_LOCATION            IN VARCHAR2,
      X_EXECUTABLE          IN VARCHAR2,
      X_OWNER               in VARCHAR2,
      x_custom_mode         in varchar2,
      x_last_update_date    in varchar2);

  procedure INSERT_ROW (
      X_ROWID               in out nocopy VARCHAR2,
      X_PROC_ID             in NUMBER,
      X_PROC_TYPE           IN VARCHAR2,
      X_STAGE               IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_PRIORITY            IN NUMBER,
      X_ERROR_IS_FATAL_FLAG IN VARCHAR2,
      X_LOCATION            IN VARCHAR2,
      X_EXECUTABLE          IN VARCHAR2,
      X_CREATED_BY          in NUMBER,
      X_CREATION_DATE       in DATE,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER);

  procedure LOCK_ROW (
      X_ROWID               in out nocopy VARCHAR2,
      X_PROC_ID             in NUMBER,
      X_PROC_TYPE           IN VARCHAR2,
      X_STAGE               IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_PRIORITY            IN NUMBER,
      X_ERROR_IS_FATAL_FLAG IN VARCHAR2,
      X_LOCATION            IN VARCHAR2,
      X_EXECUTABLE          IN VARCHAR2,
      X_CREATED_BY          in NUMBER,
      X_CREATION_DATE       in DATE,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER);


  procedure UPDATE_ROW (
      X_PROC_ID             in NUMBER,
      X_PROC_TYPE           IN VARCHAR2,
      X_STAGE               IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_PRIORITY            IN NUMBER,
      X_ERROR_IS_FATAL_FLAG IN VARCHAR2,
      X_LOCATION            IN VARCHAR2,
      X_EXECUTABLE          IN VARCHAR2,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER);

  procedure DELETE_ROW (
      X_PROC_ID           in NUMBER);


END FND_OAM_DSCFG_PROCS_PKG;

 

/
