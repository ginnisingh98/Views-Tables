--------------------------------------------------------
--  DDL for Package Body CN_BIS_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_BIS_UTIL_PVT" AS
-- $Header: cnvbisub.pls 115.1.1158.2 2003/01/21 19:08:15 jjhuang noship $

G_PKG_NAME                  CONSTANT VARCHAR2(30)   := 'CN_BIS_UTIL_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12)   := 'cnvbisub.pls';

g_debug_mode                BOOLEAN                 := FALSE;

g_parallel_degree           NUMBER                  := 0;

-- -------------------------------------------------------------------------+
-- set_debug
--  Procedure to set the debug mode.
--  Access: Public
--  Parameters:
--      p_debug,      IN, debug mode, either true or false.
--  Return:
--      None.
-- -------------------------------------------------------------------------+
PROCEDURE set_debug(p_debug IN BOOLEAN) IS
BEGIN
    IF (p_debug = FALSE OR p_debug IS NULL)
    THEN
        g_debug_mode := FALSE;
    ELSE
        g_debug_mode := TRUE;
    END IF;
END set_debug;

-- -------------------------------------------------------------------------+
-- get_debug
--  Function to get the debug mode.
--  Access: Public
--  Parameters:
--      None.
--  Return:
--      TRUE:   debug mode is set.
--      FALSE:  debug mode is not set.
-- -------------------------------------------------------------------------+
FUNCTION get_debug RETURN BOOLEAN IS
BEGIN
    RETURN g_debug_mode;
END get_debug;

-- -------------------------------------------------------------------------+
-- debug_msg
--  Procedure to write a message to the concurrent manager output file.
--  Access: Public
--  Parameters:
--      p_message,      IN, The message that will be written to the output file.
--      p_indenting,    IN, The number of space for indenting. Default 0.
--  Return:
--      None.
-- -------------------------------------------------------------------------+
PROCEDURE debug_msg(p_message IN VARCHAR2, p_indenting IN NUMBER) IS
BEGIN
    IF get_debug = TRUE
    THEN
        bis_collection_utilities.debug(p_message, p_indenting);
        --dbms_output.put_line(p_message);
    END IF;
END debug_msg;

-- -------------------------------------------------------------------------+
-- log_msg
--  Procedure to write a message to the concurrent manager log file using
--  BIS_COLLECTION_UTILITIES.log.
--  Access: Public
--  Parameters:
--      p_message,      IN, The message that will be written to the log file.
--      p_indenting,    IN, The number of space for indenting. Default 0.
--  Return:
--      None.
-- -------------------------------------------------------------------------+
PROCEDURE log_msg(p_message IN VARCHAR2, p_indenting IN NUMBER) IS
BEGIN
    bis_collection_utilities.log(p_message, p_indenting);
END log_msg;

-- -------------------------------------------------------------------------+
-- set_degree_of_parallelism
--  Procedure to set the degree of parallelism from BIS common parameters.
--  If it's null, then set it to 0.
--  Access: Public
--  Parameters:
--      None.
-- -------------------------------------------------------------------------+
PROCEDURE set_degree_of_parallelism IS
BEGIN
    g_parallel_degree := bis_common_parameters.get_degree_of_parallelism;

    IF g_parallel_degree IS NULL
    THEN
        g_parallel_degree := 0;
    END IF;

    log_msg('Set degree of parallelism : ' || TO_CHAR(g_parallel_degree), 0);
END set_degree_of_parallelism;

-- -------------------------------------------------------------------------+
-- get_degree_of_parallelism
--  Function to get the degree of parallelism from BIS common parameters.
--  Access: Public
--  Parameters:
--      None.
--  Return:
--      NUMBER.
-- -------------------------------------------------------------------------+
FUNCTION get_degree_of_parallelism RETURN NUMBER IS
BEGIN
    RETURN g_parallel_degree;
END get_degree_of_parallelism;

-- -------------------------------------------------------------------------+
-- enable_parallel
--  Procedure to enable parallel.
--  Access: Public
--  Parameters:
--      None.
--  Return:
--      None.
-- -------------------------------------------------------------------------+
PROCEDURE enable_parallel IS
    stm     VARCHAR2(100);
BEGIN
    set_degree_of_parallelism;
    stm := 'ALTER SESSION FORCE PARALLEL QUERY PARALLEL ' || TO_CHAR(get_degree_of_parallelism);
    EXECUTE IMMEDIATE stm;
    log_msg('Parallel enabled.', 0 );
END enable_parallel;

-- -------------------------------------------------------------------------+
-- disable_parallel
--  Procedure to disable parallel.
--  Access: Public
--  Parameters:
--      None.
--  Return:
--      None.
-- -------------------------------------------------------------------------+
PROCEDURE disable_parallel IS
    stm     VARCHAR2(100);
BEGIN
    stm := 'ALTER SESSION DISABLE PARALLEL QUERY';
    EXECUTE IMMEDIATE stm;
    log_msg('Parallel disabled.', 0 );
END disable_parallel;

-- -------------------------------------------------------------------------+
-- setup
--  Function from bis to do setup for runtime profile options.
--  Access: Public
--  Parameters:
--      p_object_name,  IN, an object name to do setup.
--  Return:
--      TRUE:   setup is successful.
--      FALSE:  setup failed.
-- -------------------------------------------------------------------------+
FUNCTION setup(p_object_name IN VARCHAR2) RETURN BOOLEAN IS
    l_success BOOLEAN := TRUE;
BEGIN
    IF bis_collection_utilities.setup(p_object_name => p_object_name ) = FALSE
    THEN
        l_success := FALSE;
        log_msg(cn_bis_util_pvt.g_failure_status || cn_bis_util_pvt.g_separator || ' Setup ' || p_object_name, 0);
        debug_msg(cn_bis_util_pvt.g_failure_status || cn_bis_util_pvt.g_separator || ' Setup ' || p_object_name, 0);
    ELSE
        log_msg(cn_bis_util_pvt.g_success_status || cn_bis_util_pvt.g_separator || ' Setup ' || p_object_name, 0);
        debug_msg(cn_bis_util_pvt.g_success_status || cn_bis_util_pvt.g_separator || ' Setup ' || p_object_name, 0);
    END IF;

    RETURN l_success;
END setup;

-- -------------------------------------------------------------------------+
-- wrapup
--  Procedure from bis to wrap up the concurrent program using
--      bis_collection_utilities.wrapup().
--  Access: Public
--  Parameters:
--      p_status,       IN BOOLEAN, TRUE if the process is a success,
--                          FALSE if any of your code failed. You must keep
--                          in mind that SETUP and WRAPUP both will commit.
--                          So you must rollback before you call these API.
--      p_count,        IN NUMBER DEFAULT 0, The number of rows that have been
--                          successfully processed. This number is going to be
--                          shown in the status viewer form. This number is what
--                          the customer will understand as the number of records
--                          that your concurrent program processed.
--      p_message,      IN VARCHAR2 DEFAULT NULL, If the request were a success,
--                          pass null. If there is a failure, pass the error message.
--                          This message will be shown in the status viewer form.
--      p_period_from,  IN DATE DEFAULT NULL, If you are using from date and
--                          to date as the parameters to collect data,
--                          populate this parameter.
--      p_period_to,    IN DATE DEFAULT NULL, If you are using from date and
--                          to date as the parameters to collect data,
--                          populate this parameter.
--      p_attribute1,   IN VARCHAR2 DEFAULT NULL, If you are using flexfield columns
--                          (attribute1 - attribute10), populate this parameter.
--      p_attribute2,   IN VARCHAR2 DEFAULT NULL, If you are using flexfield columns
--                          (attribute1 - attribute10), populate this parameter.
--      p_attribute3,   IN VARCHAR2 DEFAULT NULL, If you are using flexfield columns
--                          (attribute1 - attribute10), populate this parameter.
--      p_attribute4,   IN VARCHAR2 DEFAULT NULL, If you are using flexfield columns
--                          (attribute1 - attribute10), populate this parameter.
--      p_attribute5,   IN VARCHAR2 DEFAULT NULL, If you are using flexfield columns
--                          (attribute1 - attribute10), populate this parameter.
--      p_attribute6,   IN VARCHAR2 DEFAULT NULL, If you are using flexfield columns
--                          (attribute1 - attribute10), populate this parameter.
--      p_attribute7,   IN VARCHAR2 DEFAULT NULL, If you are using flexfield columns
--                          (attribute1 - attribute10), populate this parameter.
--      p_attribute8,   IN VARCHAR2 DEFAULT NULL, If you are using flexfield columns
--                          (attribute1 - attribute10), populate this parameter.
--      p_attribute9,   IN VARCHAR2 DEFAULT NULL, If you are using flexfield columns
--                          (attribute1 - attribute10), populate this parameter.
--      p_attribute10,  IN VARCHAR2 DEFAULT NULL, If you are using flexfield columns
--                          (attribute1 - attribute10), populate this parameter.
--  Return:
--      None.
-- -------------------------------------------------------------------------+
PROCEDURE wrapup(
                p_status             IN BOOLEAN,
                p_count              IN NUMBER,
                p_message            IN VARCHAR2,
                p_period_from        IN DATE,
                p_period_to          IN DATE,
                p_attribute1         IN VARCHAR2,
                p_attribute2         IN VARCHAR2,
                p_attribute3         IN VARCHAR2,
                p_attribute4         IN VARCHAR2,
                p_attribute5         IN VARCHAR2,
                p_attribute6         IN VARCHAR2,
                p_attribute7         IN VARCHAR2,
                p_attribute8         IN VARCHAR2,
                p_attribute9         IN VARCHAR2,
                p_attribute10        IN VARCHAR2
                ) IS
BEGIN
        bis_collection_utilities.wrapup(
            p_status        => p_status,
            p_count         => p_count,
            p_message       => p_message,
            p_period_from   => p_period_from,
            p_period_to     => p_period_to,
            p_attribute1    => p_attribute1,
            p_attribute2    => p_attribute2,
            p_attribute3    => p_attribute3,
            p_attribute4    => p_attribute4,
            p_attribute5    => p_attribute5,
            p_attribute6    => p_attribute6,
            p_attribute7    => p_attribute7,
            p_attribute8    => p_attribute8,
            p_attribute9    => p_attribute9,
            p_attribute10   => p_attribute10
        );
END wrapup;

END CN_BIS_UTIL_PVT;

/
