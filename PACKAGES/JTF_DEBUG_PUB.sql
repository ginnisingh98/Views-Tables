--------------------------------------------------------
--  DDL for Package JTF_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DEBUG_PUB" AUTHID CURRENT_USER as
/* $Header: JTFPDBGS.pls 120.2 2006/02/20 02:17:33 snellepa ship $ */
-- Start of Comments
-- Package name     : JTF_DEBUG_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


   /**
     * The record type for a PL/SQL table (collection) used for TABLE mode.
     * <p>
     */

-- Changed for 4862507 , Cannot access Remote package variable
  TYPE Debug_Rec_Type IS RECORD
  (
    module_name   varchar2(240)  := Chr(0),
    debug_message varchar2(4000) := Chr(0)
  );
  TYPE  Debug_Tbl_Type      IS TABLE OF Debug_Rec_Type
                                    INDEX BY BINARY_INTEGER;

  G_MISS_DEBUG_TBL      Debug_Tbl_Type;
  G_EXC_OTHERS  NUMBER := 100;
  PAD_LENGTH         NUMBER := 50;
  FILE_LINESIZE      NUMBER := 1023;

  /** The format functions return a varchar2 which formats and concatenates
    * the parameters passed to it.
    *
    * @parameter varchar2   name of the parameter e.g., 'COLUMN NAME'
    * @value                value of the parameter
    *
    */
  FUNCTION FormatNumber(parameter in varchar2, value in number) RETURN VARCHAR2;
  FUNCTION FormatDate(parameter in varchar2, value in date) RETURN VARCHAR2;
  FUNCTION FormatChar(parameter in varchar2, value in varchar2) RETURN VARCHAR2;
  FUNCTION FormatBoolean(parameter in varchar2, value in boolean) RETURN VARCHAR2;
  FUNCTION FormatIndent(parameter in varchar2) RETURN VARCHAR2;
  FUNCTION FormatSeperator RETURN VARCHAR2;

  /** getVersion returns the Header information of this package */
  FUNCTION getVersion RETURN VARCHAR2;

  /** Debug writes debugging information to a file. It includes server
   *  debugging info and information passed through the p_debug_tbl.
   *
   * @param p_file_name  filename (including the path) of the file where
   *                     debugging information should be written to.
   *                     CURRENTLY, NOT IMPLEMENTED.
   * @param p_debug_tbl  other (midtier, client) debugging information
   *                     that needs to be written to the file.
   * @param p_module     The module that we need to use for selecting data
   *                     from fnd_log_messages
   */
  PROCEDURE  Debug(
                   p_file_name  IN varchar2 := FND_API.G_MISS_CHAR,
                   p_debug_tbl  IN  debug_tbl_type := G_MISS_DEBUG_TBL,
                   p_module            IN  varchar2,
                   x_path              OUT NOCOPY varchar2,
                   x_filename          OUT NOCOPY varchar2,
                   x_msg_count         OUT NOCOPY number,
                   X_MSG_DATA        OUT NOCOPY VARCHAR2,
	           X_RETURN_STATUS   OUT NOCOPY VARCHAR2
                  );
/*
* Start of Comments
*
*      API name        : Handle_Exceptions
*      Type            : Public
*      Function        : Exception handling routine
*                        1. Called by Call_Exception_Handlers
*                        2. Handle exception according to different
*                           p_exception_level
*
*
*      Parameters      :
*      IN              :
*            p_api_name              IN      VARCHAR2
*            p_pkg_name              IN      VARCHAR2
*            p_exception_level       IN      NUMBER
*            p_package_type          IN      VARCHAR2
*            x_msg_count             IN      NUMBER
*            x_msg_data              IN      VARCHAR2
*            p_log_level             IN      NUMBER
*            p_log_module            IN      VARCHAR2
*      OUT NOCOPY             :
*
*
*      Version :       Current version 1.0
*                      Initial version 1.0
*
* End of Comments
*/

  PROCEDURE Handle_Exceptions(
                P_API_NAME        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
                P_PKG_NAME        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
                P_EXCEPTION_LEVEL IN  NUMBER   := FND_API.G_MISS_NUM,
                P_SQLCODE         IN  NUMBER   DEFAULT NULL,
                P_SQLERRM         IN  VARCHAR2 DEFAULT NULL,
                P_MSG_COUNT       IN  NUMBER := FND_API.G_MISS_NUM,
                P_LOG_LEVEL       IN  NUMBER   DEFAULT NULL,
                P_LOG_MODULE      IN  VARCHAR2 DEFAULT NULL,
                X_MSG_COUNT       OUT NOCOPY NUMBER,
                X_MSG_DATA        OUT NOCOPY VARCHAR2,
	        X_RETURN_STATUS   OUT NOCOPY VARCHAR2);


  /* Returns upto 15 messages (4000 characters) from the message stack
   *
   * @param p_message_count    number of messages that need to be retrieved.
   * @param x_message_count    number of messages actually retrieved.
   * @param x_msgs             the message information
   *
   * Currently x_message_count can be less than p_message_count.
   *
   *
   * This procedure was built to satisfy the following special case:
   * In the spreadtable when you use Ctl+ Alt + F1 to log messages any errors
   * raised in this procedure should be handled. The messages shown to the user   * should be those raised in the logging process and not other application
   * errors. Also, these messages should be deleted once they are displayed -
   * this ensures that if the application displays all messages at some point
   * in future these messages are not displayed.
   *
   * For all other purposes use the standard get_messages
   *
   */
  PROCEDURE Get_Messages (
       p_message_count IN  NUMBER,
       x_message_count OUT NOCOPY NUMBER,
       x_msgs          OUT NOCOPY VARCHAR2);


  /* Method to set global variable for setting session ID
   *
   * @param p_sessionID   ICX session ID for current session
   *
   * set the global session ID
   */
   PROCEDURE  SET_ICX_SESSION_ID(
                   p_sessionID   IN NUMBER);

  /* Logs the messages into FND_LOG_MESSAGES table
   *
   * @param p_log_level   logging level for the message
   * @param p_module      module for which message is being logged
   * @param p_message     actual message
   * @param p_icx_session_id   ICX session ID for the module
   *
   *  Writes the message to the log file for the spec'd level and module
   *  if logging is enabled for this level and module
   */
   PROCEDURE LOG_DEBUG(p_log_level IN NUMBER,
                    p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2,
                    p_icx_session_id IN NUMBER);

  /* Logs the messages into FND_LOG_MESSAGES table
   *
   * @param p_log_level   logging level for the message
   * @param p_module      module for which message is being logged
   * @param p_message     actual message
   *
   *  Writes the message to the log file for the spec'd level and module
   *  if logging is enabled for this level and module
   */
   PROCEDURE LOG_DEBUG(p_log_level IN NUMBER,
                    p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2);

  /*
   *  Utility method to write specific kind of logging messages
   * @param p_module      module for which message is being logged
   * @param p_message     actual message
   *
   */
   PROCEDURE LOG_ENTERING_METHOD( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2);

  /*
   *  Utility method to write specific kind of logging messages
   * @param p_module      module for which message is being logged
   * @param p_message     actual message
   *
   */
   PROCEDURE LOG_EXITING_METHOD( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2);

  /*
   *  Utility method to write specific kind of logging messages
   * @param p_module      module for which message is being logged
   * @param p_message     actual message
   *
   */
   PROCEDURE LOG_UNEXPECTED_ERROR( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2);

  /*
   *  Utility method to write specific kind of logging messages
   * @param p_module      module for which message is being logged
   * @param p_message     actual message
   *
   */
   PROCEDURE LOG_PARAMETERS( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2);

  /*
   * A method to find out, if logging is on at the level of
   * logging parameters
   */

   FUNCTION IS_LOG_PARAMETERS_ON( p_module    IN VARCHAR2) RETURN BOOLEAN;
  /*
   *  Utility method to write specific kind of logging messages
   * @param p_module      module for which message is being logged
   * @param p_message     actual message
   *
   */
   PROCEDURE LOG_EXCEPTION( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2);

  /*
   *  Utility method to write specific kind of logging messages
   * @param p_module      module for which message is being logged
   * @param p_message     actual message
   *
   */
   PROCEDURE LOG_EVENT( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2);

  /*
   *  Utility method to write specific kind of logging messages
   * @param p_module      module for which message is being logged
   * @param p_message     actual message
   *
   */
   PROCEDURE LOG_STATEMENT( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2);


   /*
    * This function will substitute a token for an invalid paramater
    *
    */

    FUNCTION GET_INVALID_PARAM_MSG (p_token_value IN VARCHAR2) RETURN VARCHAR2;

End JTF_DEBUG_PUB;

 

/
