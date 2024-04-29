--------------------------------------------------------
--  DDL for Package FND_OAM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DEBUG" AUTHID CURRENT_USER as
/* $Header: AFOAMDBGS.pls 120.1 2005/09/27 16:53 ilawler noship $ */

   -------------------------
   -- Public Constants/Types
   -------------------------

   --styles, translates to different devices
   STYLE_SCREEN         CONSTANT VARCHAR2(30) := 'SCREEN';
   STYLE_FILE           CONSTANT VARCHAR2(30) := 'FILE';
   STYLE_FND_LOG        CONSTANT VARCHAR2(30) := 'FND_LOG';

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   --Logging-related
   -----------------

   -- Initialize the package's log-related state.  Should be called before any log
   -- statements or ENABLE_STYLE_<type> statements.
   -- Invariants:
   --   None.
   -- Parameters:
   --   p_include_timestamp:    Boolean indicating whether each log line should be prefaced by a timestamp
   --   p_use_indentation:      Boolean indicating whether each line should be indented based on package state.
   --   p_start_indent_level:   Starting indent level
   -- Returns:
   --   TRUE                    Success
   --   FALSE                   Failure
   FUNCTION INIT_LOG(p_include_timestamp        IN BOOLEAN DEFAULT NULL,
                     p_use_indentation          IN BOOLEAN DEFAULT NULL,
                     p_start_indent_level       IN NUMBER DEFAULT NULL)
      RETURN BOOLEAN;

   -- Flushes all log styles, returns TRUE for success, FALSE for failure
   FUNCTION FLUSH_LOG
      RETURN BOOLEAN;

   -- Closes all log styles and resets package state to defaults, returns TRUE for success, FALSE for failure
   FUNCTION CLOSE_LOG
      RETURN BOOLEAN;

   -- Enables logging to the screen via dbms_output.
   FUNCTION ENABLE_STYLE_SCREEN
      RETURN BOOLEAN;

   -- Enables logging to a file in the oracle_home of the database.
   -- Invariants:
   --   A call to INIT_LOG should have already occurred to init package state.
   -- Parameters:
   --   p_file_name_prefix:      Prefix for the file name
   --   p_include_unique_suffix: Boolean indicating whether the file name should be suffixed with a random, hopefully unique string.
   --                            This is useful when there are multiple threads and you want a log for each.
   --   p_write_header:          Boolean indicating whether a header timestamp should be written to the file after open.
   -- Returns:
   --   TRUE                    Success
   --   FALSE                   Failure
   FUNCTION ENABLE_STYLE_FILE(p_file_name_prefix        IN VARCHAR2 DEFAULT NULL,
                              p_include_unique_suffix   IN BOOLEAN DEFAULT NULL,
                              p_write_header            IN BOOLEAN DEFAULT NULL)
      RETURN BOOLEAN;

   -- Enables logging using FND_LOG APIs
   FUNCTION ENABLE_STYLE_FND_LOG
      RETURN BOOLEAN;

   -- Disables a given style, screen/file/fnd_log.  returns true on success, false on failure.
   FUNCTION DISABLE_STYLE(p_style       IN VARCHAR2)
      RETURN BOOLEAN;

   -- Tests to see if logging is enabled for a given level/module
   -- Invariants:
   --   A call to INIT_LOG should have already occurred to init package state.
   -- Parameters:
   --   p_level:                Level of string we wish to log, must be >= system log level.
   --   p_module:               Module of string we wish to log
   -- Returns:
   --   TRUE                    Logging Enabled
   --   FALSE                   Logging Disabled
   FUNCTION TEST(p_level        IN NUMBER,
                 p_module       IN VARCHAR2 DEFAULT NULL)
      RETURN BOOLEAN;

   -- Setter for fnd_oam_debug-controlled log level, overrides FND_LOG or any other predicate source.
   PROCEDURE SET_LOG_LEVEL(p_level      IN NUMBER);

   -- Sets the indent level
   PROCEDURE SET_INDENT_LEVEL(p_level   IN NUMBER);

   -- Logs a string with implicit level=1, module=NULL
   PROCEDURE LOG(p_string IN VARCHAR2);

   -- Logs a string with level p_level and module p_context.
   PROCEDURE LOG(p_level        IN NUMBER,
                 p_context      IN VARCHAR2,
                 p_string       IN VARCHAR2);

   -- Logs a string with a forced, prefixed timestamp
   PROCEDURE LOGSTAMP(p_string IN VARCHAR2);

END FND_OAM_DEBUG;

 

/
