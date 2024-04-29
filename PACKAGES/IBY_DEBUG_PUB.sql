--------------------------------------------------------
--  DDL for Package IBY_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DEBUG_PUB" AUTHID CURRENT_USER AS
/* $Header: ibypdbgs.pls 120.1.12010000.2 2010/02/05 00:27:23 svinjamu ship $ */

    -- Default debug level
    G_DEBUG_LEVEL CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

    -- Default debug module; set so that this pkg will be the
    -- logging module when one is not explicitly passed
    --
    G_DEBUG_MODULE CONSTANT VARCHAR2(50) := 'iby.plsql.IBY_DEBUG_PUB.Add';

    -- unexpected error, critical failure
    G_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
    -- caught/expected error
    G_LEVEL_ERROR CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
    -- expected exception
    G_LEVEL_EXCEPTION CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
    -- non-error event
    G_LEVEL_EVENT CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
    -- procedure/function entry or exit
    G_LEVEL_PROCEDURE CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
    -- lowest logging level; info
    G_LEVEL_INFO CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;


--
-- Name: Add
-- Purporse: Logs a debug message at the default level, using the
--           default module name.
--
PROCEDURE Add(debug_msg IN VARCHAR2);

--
-- Name: Add
-- Purpose: Adds a debugging message
-- Args: debug_msg => message to print
--       debug_level => importance level of message; should be set
--                      to one of the constants in FND_LOG
--       module => IBY module that is adding the message; should be of
--                 the form 'iby.plsql.<pkg name>.<method>.<label>'
--
--
PROCEDURE Add(debug_msg IN VARCHAR2, debug_level IN NUMBER, module IN VARCHAR2);

PROCEDURE Log(module IN VARCHAR2,debug_msg IN VARCHAR2,  debug_level IN NUMBER);


END IBY_DEBUG_PUB;

/
