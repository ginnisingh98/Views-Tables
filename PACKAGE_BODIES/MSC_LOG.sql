--------------------------------------------------------
--  DDL for Package Body MSC_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_LOG" as
/* $Header: MSCLOGB.pls 120.0 2005/05/25 19:01:57 appldev noship $ */

   PROCEDURE STRING(LOG_LEVEL IN NUMBER,
                    MODULE    IN VARCHAR2,
                    MESSAGE   IN VARCHAR2) IS
   BEGIN
      if (LOG_LEVEL < FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         return;
      end if;
      if (LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(LOG_LEVEL,MODULE,MESSAGE);
      end if;
   END STRING;

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
                      DB_INSTANCE     IN NUMBER   DEFAULT NULL) IS
   BEGIN
      if (LOG_LEVEL < FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         return;
      end if;
      if (LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING_WITH_CONTEXT(LOG_LEVEL,MODULE,MESSAGE,ENCODED,
	NODE,NODE_IP_ADDRESS,PROCESS_ID,JVM_ID,THREAD_ID,AUDSID,DB_INSTANCE);
      end if;
   END STRING_WITH_CONTEXT;

   PROCEDURE MESSAGE(LOG_LEVEL   IN NUMBER,
                     MODULE      IN VARCHAR2,
                     POP_MESSAGE IN BOOLEAN ) IS
   BEGIN
      if (LOG_LEVEL < FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         return;
      end if;
      if (LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(LOG_LEVEL,MODULE,POP_MESSAGE);
      end if;
   END MESSAGE;

   PROCEDURE MESSAGE_WITH_CONTEXT(LOG_LEVEL IN NUMBER,
                      MODULE           IN VARCHAR2,
                      POP_MESSAGE      IN BOOLEAN DEFAULT NULL, --Default FALSE
                      NODE             IN VARCHAR2 DEFAULT NULL,
                      NODE_IP_ADDRESS  IN VARCHAR2 DEFAULT NULL,
                      PROCESS_ID       IN VARCHAR2 DEFAULT NULL,
                      JVM_ID           IN VARCHAR2 DEFAULT NULL,
                      THREAD_ID        IN VARCHAR2 DEFAULT NULL,
                      AUDSID          IN NUMBER   DEFAULT NULL,
                      DB_INSTANCE     IN NUMBER   DEFAULT NULL) IS
   BEGIN
      if (LOG_LEVEL < FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         return;
      end if;
      if (LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

      FND_LOG.MESSAGE_WITH_CONTEXT(LOG_LEVEL,MODULE,POP_MESSAGE,
	NODE,NODE_IP_ADDRESS,PROCESS_ID,JVM_ID,THREAD_ID,AUDSID,DB_INSTANCE);
      end if;
   END MESSAGE_WITH_CONTEXT;

   FUNCTION TEST(LOG_LEVEL IN NUMBER,
                 MODULE    IN VARCHAR2) RETURN BOOLEAN IS
   BEGIN
      if ( LOG_LEVEL < FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         return FALSE;
      end if;
      return FND_LOG_REPOSITORY.CHECK_ACCESS_INTERNAL (MODULE, LOG_LEVEL);
   END TEST;

end MSC_LOG;

/
