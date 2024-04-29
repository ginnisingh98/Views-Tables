--------------------------------------------------------
--  DDL for Package AHL_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DEBUG_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPDEBS.pls 115.4 2003/08/04 18:57:28 sikumar noship $ */
--------------------------------------
-- declaration of public global varibles
--------------------------------------

G_FILE_DEBUG          BOOLEAN := FALSE;

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
 *
 *
 *
 */

PROCEDURE enable_debug;

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
 *
 *
 *
 */

PROCEDURE disable_debug;

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
 *
 *
 *
 */

PROCEDURE debug (
    p_message                               IN     VARCHAR2,
    p_prefix                                IN     VARCHAR2 DEFAULT 'DEBUG'
);

/**
 * PROCEDURE log_app_messages
 *
 * DESCRIPTION
 *     Put debug messages based on message count in message stack.
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
 *
 *
 *
 */

PROCEDURE log_app_messages (
    p_msg_count                             IN     NUMBER,
    p_msg_data                              IN     VARCHAR2,
    p_msg_type                              IN     VARCHAR2 DEFAULT 'ERROR'
);

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
FUNCTION is_log_enabled RETURN VARCHAR2;

END AHL_DEBUG_PUB;

 

/
