--------------------------------------------------------
--  DDL for Package Body AHL_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DEBUG_PUB" AS
/* $Header: AHLPDEBB.pls 115.7 2003/08/04 18:56:54 sikumar noship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

-- file handler we will use for log file.
--G_FILE                                  UTL_FILE.FILE_TYPE;

-- running in file debug mode.
--G_FILE_NAME                             VARCHAR2(100);
--G_FILE_PATH                             VARCHAR2(200);

-- running in normal debug mode by calling dbms_output.
--G_DBMS_DEBUG                            BOOLEAN := FALSE;

-- buffer size used by dbms_output.debug
--G_BUFFER_SIZE                           CONSTANT NUMBER := 1000000;
--G_MAX_LINE_SIZE_OF_FILE                 CONSTANT NUMBER := 1023;
--G_MAX_LINE_SIZE_OF_DBMS                 CONSTANT NUMBER := 255;

-- level of debug has been called.
--G_COUNT                                 NUMBER := 0;
  G_DEFAULT_MODULE_PREFIX CONSTANT VARCHAR2(80) := 'ahl.plsql.AHL_DEBUG_PUB.';

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------
--PROCEDURE enable_file_debug;


/**
 * PRIVATE PROCEDURE enable_file_debug
 *
 * DESCRIPTION
 *    Enables writing debug messages to a file.
 *		      Requires file patch (directory), THIS SHOULD BE
 *			   DEFINED IN INIT.ORA PARAMETER 'UTIL_FILE_DIR',
 *			   file name (Any valid OS file name).
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *  sikumar obseleted.
 *
 *
 */

/*PROCEDURE enable_file_debug IS


BEGIN
    -- Open log file in 'append' mode.
    IF NOT UTL_FILE.is_open( G_FILE  ) THEN
        G_FILE := UTL_FILE.fopen( G_FILE_PATH, G_FILE_NAME , 'a' );
        UTL_FILE.put_line( G_FILE, '#######' );
    END IF;

    G_FILE_DEBUG := TRUE;
EXCEPTION
    -- file location or name was invalid
    WHEN UTL_FILE.INVALID_PATH THEN
        FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_PATH' );
        FND_MESSAGE.SET_TOKEN( 'FILE_DIR', G_FILE_PATH );
        FND_MSG_PUB.ADD;
        G_FILE_DEBUG := FALSE;
        G_COUNT := 0;
        RAISE FND_API.G_EXC_ERROR;
    -- the open_mode string was invalid
    WHEN UTL_FILE.INVALID_MODE THEN
        FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_MODE' );
        FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
        FND_MESSAGE.SET_TOKEN( 'FILE_MODE', 'w' );
        FND_MSG_PUB.ADD;
        G_FILE_DEBUG := FALSE;
        G_COUNT := 0;
        RAISE FND_API.G_EXC_ERROR;
    -- file could not be opened as requested
    WHEN UTL_FILE.INVALID_OPERATION THEN
        FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_OPERATN' );
        FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
        FND_MESSAGE.SET_TOKEN( 'TEMP_DIR', G_FILE_PATH );
        FND_MSG_PUB.ADD;
        G_FILE_DEBUG := FALSE;
        G_COUNT := 0;
        RAISE FND_API.G_EXC_ERROR;
END enable_file_debug;*/

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Enable file or dbms debug based on profile options.
 *     AHL_API_FILE_DEBUG_ON : Turn on/off file debug, i.e. debug message
 *                            will be written to a user specified file.
 *                            The file name and file path is stored in
 *                            profiles AHL_API_DEBUG_FILE_PATH and
 *                            AHL_API_DEBUG_FILE_NAME. File path must be
 *                            database writable.
 *     AHL_API_DBMS_DEBUG_ON : Turn on/off dbms debug.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *  sikumar made it new logging framework compatiable.
 *  commented out all the code for AHL specific logging
 *  no longer needed and should not be used.
 *
 */

PROCEDURE enable_debug IS

BEGIN

    /*G_COUNT := G_COUNT + 1;

    IF G_COUNT > 1 THEN
        RETURN;
    END IF;

    IF FND_PROFILE.value( 'AHL_API_FILE_DEBUG_ON' ) = 'Y' THEN

        G_FILE_NAME := NVL(FND_PROFILE.value( 'AHL_API_FILE_DEBUG_NAME' ), 'ahldebug.log');
        G_FILE_PATH := FND_PROFILE.value( 'AHL_API_FILE_DEBUG_PATH' );
        G_FILE_DEBUG := TRUE;
        enable_file_debug;
    ELSIF FND_PROFILE.value( 'AHL_API_DBMS_DEBUG_ON' ) = 'Y' THEN
        -- Enable calls to dbms_output.
--        DBMS_OUTPUT.enable( G_BUFFER_SIZE );
        G_DBMS_DEBUG := TRUE;

    END IF;*/

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      G_FILE_DEBUG := TRUE;
    END IF;

END enable_debug;

/**
 * PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Disable file or dbms debug.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *  sikumar made it new logging framework compatiable.
 *  no longer needed and should be used.
 *
 *
 */

PROCEDURE disable_debug IS

BEGIN
    RETURN;
    /*G_COUNT := G_COUNT - 1;

    IF G_COUNT > 0 THEN
        RETURN;
    END IF;

    IF G_FILE_DEBUG THEN
        IF UTL_FILE.is_open( G_FILE ) THEN
        BEGIN
            UTL_FILE.fclose( G_FILE );
            G_FILE_DEBUG := FALSE;
        EXCEPTION
            WHEN UTL_FILE.INVALID_FILEHANDLE THEN
                FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_HANDLE' );
                FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
                FND_MSG_PUB.ADD;
                G_FILE_DEBUG := FALSE;
                G_COUNT := 0;
                RAISE FND_API.G_EXC_ERROR;

            WHEN UTL_FILE.WRITE_ERROR THEN
                FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_WRITE_ERROR' );
                FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
                FND_MSG_PUB.ADD;
                G_FILE_DEBUG := FALSE;
                G_COUNT := 0;
                RAISE FND_API.G_EXC_ERROR;
        END;
        END IF;
    ELSIF G_DBMS_DEBUG THEN
        G_DBMS_DEBUG := FALSE;
    END IF;*/

END disable_debug;

/**
 * PROCEDURE debug
 *
 * DESCRIPTION
 *     Put debug message.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_message                      Message you want to put in log.
 *     p_prefix                       Prefix of the message. Default value is
 *                                    DEBUG.
 * NOTES
 *
 * MODIFICATION HISTORY
 *  sikumar made it new logging framework compatiable.
 *  commented out all the code for AHL specific logging
 *
 */

PROCEDURE debug (
    p_message                               IN     VARCHAR2,
    p_prefix                                IN     VARCHAR2
) IS

    /*l_message                               VARCHAR2(4000);
    l_len                                   NUMBER;
    l_times                                 NUMBER;
	l_prefix                                VARCHAR2(2000);
	l_user_name                             VARCHAR2(30);
    i                                       NUMBER;
    j                                       NUMBER;

    buffer_overflow                         EXCEPTION;
    PRAGMA EXCEPTION_INIT(buffer_overflow, -20000);*/

BEGIN

    /*l_len := LENGTH( p_message  );

    IF l_len + LENGTH( p_prefix ) + 3 > G_MAX_LINE_SIZE_OF_FILE THEN
        FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_MAXLINE' );
        FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
        FND_MESSAGE.SET_TOKEN( 'MAXLINE', G_MAX_LINE_SIZE_OF_FILE );
        FND_MSG_PUB.ADD;
        G_FILE_DEBUG := FALSE;
        G_COUNT := 0;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Retrieves the user name
	 l_user_name := fnd_global.user_name;
	 -- This is Required when the session is established outside of normal application connection
    IF l_user_name IS NULL
	 THEN
      SELECT OSUSER INTO l_user_name FROM v$session
       WHERE audsid =
        (SELECT userenv('SESSIONID') FROM DUAL);
    END IF;
      l_prefix := l_user_name ||':' ||to_char( sysdate, 'mm/dd/yy hh:mi:ss')|| '-'  ||p_prefix;
    --
    l_message := l_prefix || ' - ' || p_message;

    IF G_FILE_DEBUG THEN
    BEGIN
        UTL_FILE.put_line( G_FILE, l_message );
        UTL_FILE.fflush( G_FILE );
    EXCEPTION
	    -- file handle is invalid
        WHEN UTL_FILE.INVALID_FILEHANDLE THEN
            FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_HANDLE' );
            FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
            FND_MSG_PUB.ADD;
            G_FILE_DEBUG := FALSE;
            G_COUNT := 0;
            RAISE FND_API.G_EXC_ERROR;
        -- file is not open for writing/appending
        WHEN UTL_FILE.INVALID_OPERATION THEN
            FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_INVALID_OPERATN' );
            FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
            FND_MESSAGE.SET_TOKEN( 'TEMP_DIR', G_FILE_PATH );
            FND_MSG_PUB.ADD;
            G_FILE_DEBUG := FALSE;
            G_COUNT := 0;
            RAISE FND_API.G_EXC_ERROR;
        -- OS error occured during write operation
        WHEN UTL_FILE.WRITE_ERROR THEN
            FND_MESSAGE.SET_NAME( 'FND', 'CONC-TEMPFILE_WRITE_ERROR' );
            FND_MESSAGE.SET_TOKEN( 'TEMP_FILE', G_FILE_NAME );
            FND_MSG_PUB.ADD;
            G_FILE_DEBUG := FALSE;
            G_COUNT := 0;
            RAISE FND_API.G_EXC_ERROR;
    END;
--    ELSIF G_DBMS_DEBUG THEN
--        l_times := CEIL( l_len/G_MAX_LINE_SIZE_OF_DBMS );
--        j := 1;
--
--        BEGIN
--        FOR i IN 1..l_times LOOP
--            DBMS_OUTPUT.put_line( SUBSTR( l_message, j, 255 ) );
--            j := j + 255;
--        END LOOP;
--        EXCEPTION
--            WHEN buffer_overflow THEN
--                G_DBMS_DEBUG := FALSE;
--                G_COUNT := 0;
--                NULL;
--        END;
    END IF;*/

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string
	  (
			fnd_log.level_statement,
			G_DEFAULT_MODULE_PREFIX || p_prefix ,
			p_message
	  );
   END IF;

END debug;

/**
 * PROCEDURE log_app_messages
 *
 * DESCRIPTION
 *     Put log messages based on message count in message stack.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_msg_count                    Message count in message stack.
 *     p_msg_data                     Message data if message count is 1.
 *     p_msg_type                     Message type used as prefix of the message.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *  sikumar made it new logging framework compatiable.
 *
 *
 */

PROCEDURE log_app_messages (
    p_msg_count                             IN     NUMBER,
    p_msg_data                              IN     VARCHAR2,
    p_msg_type                              IN     VARCHAR2
) IS

    i                                       NUMBER;

BEGIN
    IF p_msg_count <= 0 THEN
        RETURN;
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      IF p_msg_count = 1 THEN
        debug( p_msg_data, p_msg_type );
      ELSE
        FOR i IN 1..p_msg_count LOOP
               debug( FND_MSG_PUB.Get( p_encoded => FND_API.G_FALSE ), p_msg_type );
        END LOOP;
		--Resets the message table index to point to the top of the message table
        --or the botom of the message table
        FND_MSG_PUB.reset;
      END IF;
   END IF;

END log_app_messages;

/**
 * Function is_log_enabled RETURNS 'Y' or 'N'
 *
 * DESCRIPTION
 *     Included for backward compatiablity to find out whether statement level logging is enabled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *
 *
 */

FUNCTION is_log_enabled RETURN VARCHAR2 IS

BEGIN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
END is_log_enabled;


END AHL_DEBUG_PUB;

/
