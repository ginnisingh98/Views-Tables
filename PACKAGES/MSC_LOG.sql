--------------------------------------------------------
--  DDL for Package MSC_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_LOG" AUTHID CURRENT_USER as
/* $Header: MSCLOGS.pls 115.0 2003/06/26 17:58:47 pabram noship $ */

   /*
   **  Writes the message to the log file for the spec'd level and module
   **  if logging is enabled for this level and module
   */
   PROCEDURE STRING(LOG_LEVEL IN NUMBER,
                    MODULE    IN VARCHAR2,
                    MESSAGE   IN VARCHAR2);

   /*
   **  Writes the message with context information to the log file for
   **  the spec'd level and module if logging is enabled for this level
   **  and module
   */
   PROCEDURE STRING_WITH_CONTEXT(LOG_LEVEL  IN NUMBER,
                      MODULE           IN VARCHAR2,
                      MESSAGE          IN VARCHAR2,
                      ENCODED          IN VARCHAR2 DEFAULT NULL,
                      NODE             IN VARCHAR2 DEFAULT NULL,
                      NODE_IP_ADDRESS  IN VARCHAR2 DEFAULT NULL,
                      PROCESS_ID       IN VARCHAR2 DEFAULT NULL,
                      JVM_ID           IN VARCHAR2 DEFAULT NULL,
                      THREAD_ID        IN VARCHAR2 DEFAULT NULL,
                      AUDSID          IN NUMBER   DEFAULT NULL,
                      DB_INSTANCE     IN NUMBER   DEFAULT NULL);

   /*
   **  Writes a message to the log file if this level and module is enabled
   **  The message gets set previously with FND_MESSAGE.SET_NAME,
   **  SET_TOKEN, etc.
   **  The message is popped off the message dictionary stack, if POP_MESSAGE
   **  is TRUE.  Pass FALSE for POP_MESSAGE if the message will also be
   **  displayed to the user later.
   **  Example usage:
   **  FND_MESSAGE.SET_NAME(...);    -- Set message
   **  FND_MESSAGE.SET_TOKEN(...);   -- Set token in message
   **  FND_LOG.MESSAGE(..., FALSE);  -- Log message
   **  FND_MESSAGE.ERROR;            -- Display message
   */
   PROCEDURE MESSAGE(LOG_LEVEL   IN NUMBER,
                     MODULE      IN VARCHAR2,
                     POP_MESSAGE IN BOOLEAN DEFAULT NULL);

   /*
   **  Writes a message with context to the log file if this level and
   **  module is enabled.  This requires that the message was set
   **  previously with FND_MESSAGE.SET_NAME, SET_TOKEN, etc.
   **  The message is popped off the message dictionary stack, if POP_MESSAGE
   **  is TRUE.  Pass FALSE for POP_MESSAGE if the message will also be
   **  displayed to the user later.  If POP_MESSAGE isn't passed, the
   **  message will not be popped off the stack, so it must be displayed
   **  or explicitly cleared later on.
   */
   PROCEDURE MESSAGE_WITH_CONTEXT(LOG_LEVEL IN NUMBER,
                      MODULE           IN VARCHAR2,
                      POP_MESSAGE      IN BOOLEAN DEFAULT NULL, --Default FALSE
                      NODE             IN VARCHAR2 DEFAULT NULL,
                      NODE_IP_ADDRESS  IN VARCHAR2 DEFAULT NULL,
                      PROCESS_ID       IN VARCHAR2 DEFAULT NULL,
                      JVM_ID           IN VARCHAR2 DEFAULT NULL,
                      THREAD_ID        IN VARCHAR2 DEFAULT NULL,
                      AUDSID          IN NUMBER   DEFAULT NULL,
                      DB_INSTANCE     IN NUMBER   DEFAULT NULL);

   /*
   ** Tests whether logging is enabled for this level and module, to
   ** avoid the performance penalty of building long debug message
   ** strings unnecessarily.
   */
   FUNCTION TEST(LOG_LEVEL IN NUMBER,
                 MODULE    IN VARCHAR2) RETURN BOOLEAN;
end MSC_LOG;

 

/
