--------------------------------------------------------
--  DDL for Package Body AR_LATE_CHARGES_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_LATE_CHARGES_REPORT_PVT" AS
/* $Header: ARLCRPTB.pls 120.0 2006/03/28 00:48:23 kmaheswa noship $ */

--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global Constants                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+


--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240)
                      := 'ar.plsql.ar_late_charges_report_pvt';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_level                      IN NUMBER
  ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE)

IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END trace;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Before_report                                                         |
|                                                                       |
| Code for before_report trigger                                        |
|                                                                       |
+======================================================================*/
FUNCTION before_report RETURN BOOLEAN

IS

   l_log_module               VARCHAR2(240);
   l_return                   BOOLEAN;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.before_report';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of before_report'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg   => 'p_request_id = ' || p_request_id
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_interest_batch_id = ' || p_interest_batch_id
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

   END IF;

   --
   -- 1. Check if both request id and batch id are passed.
   --    If so error out the report
   --

   IF (p_request_id IS NOT NULL AND p_interest_batch_id IS NOT NULL) THEN
       FND_MESSAGE.SET_NAME('AR','AR_LC_PARAMS_INVALID');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   --
   -- 2. Get batch name if batch id alone is passed.
   --

   IF (p_request_id IS NULL AND p_interest_batch_id IS NOT NULL) THEN

      SELECT batch_name
        INTO P_BATCH_NAME_DSP
        FROM ar_interest_batches
       WHERE interest_batch_id = p_interest_batch_id;

      p_batch_name_dsp := ''''||p_batch_name_dsp||'''';

   END IF;

   --
   -- 3. Add additional Where Clause.
   --

   IF (p_request_id IS NULL AND p_interest_batch_id IS NOT NULL) THEN

      p_query_where := '   AND intb.interest_batch_id = :p_interest_batch_id';

   END IF;

   IF (p_request_id IS NOT NULL AND p_interest_batch_id IS NULL) THEN

       p_query_where := '   AND intb.request_id = :p_request_id';

   END IF;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END before_report;

--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
--
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--
--=============================================================================

BEGIN

   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                         (log_level  => g_log_level
                         ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END AR_LATE_CHARGES_REPORT_PVT;

/
