--------------------------------------------------------
--  DDL for Package CN_BIS_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_BIS_UTIL_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvbisus.pls 115.0.1158.2 2003/01/21 19:07:49 jjhuang noship $

--Error codes when bis setup fails.
g_error_code        CONSTANT NUMBER         := -20000;
g_success_code_msg  CONSTANT VARCHAR2(10)   := '0';

--Statuses used by cn concurrent programs.
g_success_status    CONSTANT VARCHAR2(10)   := 'SUCCESS';
g_failure_status    CONSTANT VARCHAR2(10)   := 'FAILURE';

--Separator
g_separator         CONSTANT VARCHAR2(1)    := ':';

-- -------------------------------------------------------------------------+
-- set_debug
--  Procedure to set the debug mode.
-- -------------------------------------------------------------------------+
PROCEDURE set_debug(p_debug IN BOOLEAN);

-- -------------------------------------------------------------------------+
-- get_debug
--  Function to get the debug mode.
-- -------------------------------------------------------------------------+
FUNCTION get_debug RETURN BOOLEAN;

-- -------------------------------------------------------------------------+
-- debug_msg
--  Procedure to log the debug message.
-- -------------------------------------------------------------------------+
PROCEDURE debug_msg(p_message IN VARCHAR2, p_indenting IN NUMBER DEFAULT 0);

-- -------------------------------------------------------------------------+
-- log_msg
--  Procedure to log the information message.
-- -------------------------------------------------------------------------+
PROCEDURE log_msg(p_message IN VARCHAR2, p_indenting IN NUMBER DEFAULT 0);

-- -------------------------------------------------------------------------+
-- set_degree_of_parallelism
--  Procedure to set the degree of parallelism.
-- -------------------------------------------------------------------------+
PROCEDURE set_degree_of_parallelism;

-- -------------------------------------------------------------------------+
-- get_degree_of_parallelism
--  Function to get the degree of parallelism.
-- -------------------------------------------------------------------------+
FUNCTION get_degree_of_parallelism RETURN NUMBER;

-- -------------------------------------------------------------------------+
-- enable_parallel
--  Procedure to enable parallel.
-- -------------------------------------------------------------------------+
PROCEDURE enable_parallel;

-- -------------------------------------------------------------------------+
-- disable_parallel
--  Procedure to disable parallel.
-- -------------------------------------------------------------------------+
PROCEDURE disable_parallel;

-- -------------------------------------------------------------------------+
-- setup
--  Function to do the setup using bis setup function.
--  This is required for the DBI project.
-- -------------------------------------------------------------------------+
FUNCTION setup(p_object_name IN VARCHAR2) RETURN BOOLEAN;

-- -------------------------------------------------------------------------+
-- wrapup
--  Procedure to do the wrap using bis wrap procedure.
--  This is required for the DBI project.
-- -------------------------------------------------------------------------+
PROCEDURE wrapup(
                p_status             IN BOOLEAN,
                p_count              IN NUMBER DEFAULT 0,
                p_message            IN VARCHAR2 DEFAULT NULL,
                p_period_from        IN DATE DEFAULT NULL,
                p_period_to          IN DATE DEFAULT NULL,
                p_attribute1         IN VARCHAR2 DEFAULT NULL,
                p_attribute2         IN VARCHAR2 DEFAULT NULL,
                p_attribute3         IN VARCHAR2 DEFAULT NULL,
                p_attribute4         IN VARCHAR2 DEFAULT NULL,
                p_attribute5         IN VARCHAR2 DEFAULT NULL,
                p_attribute6         IN VARCHAR2 DEFAULT NULL,
                p_attribute7         IN VARCHAR2 DEFAULT NULL,
                p_attribute8         IN VARCHAR2 DEFAULT NULL,
                p_attribute9         IN VARCHAR2 DEFAULT NULL,
                p_attribute10        IN VARCHAR2 DEFAULT NULL
                );

END CN_BIS_UTIL_PVT;

 

/
