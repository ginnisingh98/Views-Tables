--------------------------------------------------------
--  DDL for Package Body XLA_TB_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TB_BALANCE_PKG" AS
/* $Header: xlatbbal.pkb 120.8.12010000.6 2009/04/24 13:42:47 nksurana ship $ */
/*======================================================================+
|             Copyright (c) 2000-2001 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tb_balance_pkg                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    Description                                                        |
|                                                                       |
| HISTORY                                                               |
|    01-Dec-05 Mizuru Asada          Created                            |
|                                                                       |
|     23-Sep-2008  rajose    bug#7364921 Upgraded invoices not appearing|
|                            in the TB report for a given date range.   |
|     5-Mar-2009   ssawhney  BUG 8222265 mainline perf changes          |
+======================================================================*/


C_PACKAGE_NAME           CONSTANT VARCHAR2(30) := 'xla_tb_balance_pkg';
-- Object Version Number (OVN)
C_OVN                    CONSTANT NUMBER(15)   := 1;
C_OWNER_ORACLE           CONSTANT VARCHAR2(30) := 'S';
C_CREATE_MODE            CONSTANT VARCHAR2(30) := 'CREATE';
C_UPDATE_MODE            CONSTANT VARCHAR2(30) := 'UPDATE';

g_mode                   VARCHAR2(30);  -- C_CREATE_MODE / C_UPDATE_MODE


TYPE r_definition IS RECORD
  (definition_code        xla_tb_definitions_b.definition_code%TYPE
  ,name                   xla_tb_definitions_tl.name%TYPE
  ,ledger_id              xla_tb_definitions_b.ledger_id%TYPE
  ,description            xla_tb_definitions_tl.description%TYPE
  ,balance_side_code      xla_tb_definitions_b.balance_side_code%TYPE);


--

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
                      := 'xla.plsql.xla_tb_balance_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.trace');
END trace;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Submit_Data_Manager                                                   |
|                                                                       |
| Submit Data Manager. Called in Update mode.                                            |
|                                                                       |
+======================================================================*/
PROCEDURE submit_data_manager
  (p_definition_rec   IN  r_definition
  ,p_je_source_name   IN  VARCHAR2
  ,p_gl_date_from     IN  DATE
  ,p_gl_date_to       IN  DATE
  ,p_process_mode     IN  VARCHAR2)
IS


   --
   -- WHO column information
   --
   l_last_update_date          DATE;
   l_last_updated_by           NUMBER(15);
   l_last_update_login         NUMBER(15);

   l_log_module                VARCHAR2(240);
   l_req_id                    fnd_concurrent_requests.request_id%TYPE;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.submit_data_manager';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of submit_data_manager'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;


   l_last_update_date        := sysdate;
   l_last_updated_by         := xla_environment_pkg.g_usr_id;
   l_last_update_login       := xla_environment_pkg.g_login_id;


   --
   -- UPDATE - p_process_mode = NULL
   -- In this case, data in
   --
   l_req_id := fnd_request.submit_request
                     (application => 'XLA'
                     ,program     => 'XLATBDMG'
                     ,description => NULL
                     ,start_time  => SYSDATE
                     ,sub_request => NULL
		     ,argument1   => NULL -- application_id
                     ,argument2   => p_definition_rec.ledger_id
                     ,argument3   => NULL  -- Group_Id
                     ,argument4   => p_definition_rec.definition_code
                     ,argument5   => p_process_mode   --Request_Mode
                     ,argument6   => p_je_source_name
                     ,argument7   => NULL   --upg_batch_id
                     ,argument8   => fnd_date.date_to_canonical(p_gl_date_from)
                     ,argument9   => fnd_date.date_to_canonical(p_gl_date_to)
                     );

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of submit_data_manager'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.submit_data_manager');
END submit_data_manager;
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Validate_Definition                                                   |
|                                                                       |
| Validate Report Definition                                            |
|                                                                       |
+======================================================================*/
FUNCTION validate_definition
  (p_definition_rec   IN  r_definition)
RETURN BOOLEAN IS

   l_log_module        VARCHAR2(240);

   l_db_cnt            PLS_INTEGER;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_definition';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of validate_definition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   --
   -- Check if Definition Code exists in db
   --
   SELECT COUNT(1)
     INTO l_db_cnt
     FROM xla_tb_definitions_b
    WHERE definition_code = p_definition_rec.definition_code;

   IF l_db_cnt = 0 THEN

      IF g_mode = C_CREATE_MODE THEN

         RETURN TRUE;

      ELSIF g_mode = C_UPDATE_MODE THEN

         fnd_message.set_name('XLA','XLA_TB_INVALID_DEF_CODE');
         fnd_message.set_token('DEFINITION_CODE'
                              ,p_definition_rec.definition_code);

         fnd_msg_pub.add;
         RETURN FALSE;

      END IF;

   ELSIF l_db_cnt = 1 THEN

      IF g_mode = C_CREATE_MODE THEN

         fnd_message.set_name('XLA','XLA_TB_PARAM_DUP_DEF_CODE');
         fnd_msg_pub.add;
         RETURN FALSE;

      ELSIF g_mode = C_UPDATE_MODE THEN

         RETURN TRUE;

      END IF;

   ELSE
      --
      --  Data Corruption
      --
      RETURN FALSE;

   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
        RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.validate_je_sources');
END validate_definition;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Validate_Ledgers                                                      |
|                                                                       |
| Validate ledgers                                                      |
|                                                                       |
+======================================================================*/
FUNCTION  validate_ledger
  (p_ledger_id     IN NUMBER)
RETURN BOOLEAN
IS

   l_log_module        VARCHAR2(240);
   l_db_cnt            PLS_INTEGER;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_ledger';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of validate_ledger'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   --
   -- Check for null ledger ids is already done in check_required_params
   --

   SELECT COUNT(1)
     INTO l_db_cnt
     FROM gl_ledgers  gl
    WHERE gl.ledger_id = p_ledger_id;

   IF l_db_cnt = 1 THEN

       --
       --  if p_ledger_id is valid, then return true.
       --
       RETURN TRUE;

   ELSIF l_db_cnt = 0 THEN

       --
       -- if p_ledger_id is invalid, then return false.
       --
      fnd_message.set_name('XLA','XLA_COMMON_INVALID_PARAM2');
      fnd_message.set_token('PARAMETER_VALUE',p_ledger_id);
      fnd_message.set_token('PARAMETER','p_ledger_id');

       fnd_msg_pub.add;
       RETURN FALSE;

   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
       RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.validate_ledger');
END validate_ledger;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| validate_je_sources                                                   |
|                                                                       |
| <Description of the procedure>                                        |
|                                                                       |
+======================================================================*/
FUNCTION validate_je_source
  (p_je_source_name     IN VARCHAR2)
RETURN BOOLEAN IS

   l_log_module        VARCHAR2(240);

   l_db_cnt            PLS_INTEGER;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_je_source';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of validate_je_source'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   --
   -- Check if Journal Source exists in db
   -- This procedure does not validate journal source against
   -- xla_tb_defn_je_sources.
   --
   SELECT COUNT(1)
     INTO l_db_cnt
     FROM xla_subledgers  xs
         ,gl_je_sources   gs
    WHERE xs.je_source_name = gs.je_source_name
      AND xs.je_source_name = p_je_source_name;

   IF l_db_cnt = 1 THEN

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           (p_msg      => 'END of validate_je_source - db count = 1'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      END IF;

      --
      --  If Journal source is valid, then return true.
      --
      RETURN TRUE;

   ELSE

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           (p_msg      => 'END of validate_je_source - db count = 0'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      END IF;

      RETURN FALSE;

   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
        RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.validate_je_source');
END validate_je_source;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Validate_Ccids                                                        |
|                                                                       |
| Validate code combination ids                                         |
|                                                                       |
+======================================================================*/
FUNCTION validate_ccids
  (p_definition_rec IN r_definition)
RETURN BOOLEAN IS

   l_log_module        VARCHAR2(240);

   l_param_cnt         PLS_INTEGER;
   l_db_cnt            PLS_INTEGER;

   t_array_ccid        fnd_table_of_number;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_ccids';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of validate_ccids'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   SELECT COUNT(1)
     INTO l_db_cnt
     FROM xla_tb_balances_gt
    WHERE definition_code = p_definition_rec.definition_code;

   IF l_db_cnt = 0 THEN


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'END of validate_ccids - No ccid'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
      END IF;

      --
      --  No ccid in the GT table
      --
      IF g_mode = C_CREATE_MODE THEN

         fnd_message.set_name('XLA','XLA_TB_NO_CCID_IN_GT');
         fnd_msg_pub.add;

         RETURN FALSE;

      ELSE

         RETURN TRUE;

      END IF;

   ELSE

      --
      --  Select invalid ccids
      --
      SELECT code_combination_id
        BULK COLLECT
        INTO t_array_ccid
        FROM xla_tb_balances_gt
       WHERE code_combination_id NOT IN
               (SELECT code_combination_id
                  FROM gl_code_combinations gcc
                      ,gl_ledgers           gld
                 WHERE gcc.chart_of_accounts_id = gld.chart_of_accounts_id
                   AND gld.ledger_id            = p_definition_rec.ledger_id);

      IF t_array_ccid.COUNT = 0 THEN

         --
         --  No invalid ccids.  Return TRUE.
         --

         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
            trace
              (p_msg      => 'END of validate_ccids - Ccids are valid'
              ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);
         END IF;

         RETURN TRUE;

      ELSE

         FOR i IN t_array_ccid.FIRST .. t_array_ccid.LAST LOOP

            fnd_message.set_name('XLA','XLA_TB_INVALID_CCID');
            fnd_message.set_token('CCID',t_array_ccid(i));
            fnd_msg_pub.add;

         END LOOP;

         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
            trace
              (p_msg      => 'END of validate_ccids - Invalid ccids'
              ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);
         END IF;

         RETURN FALSE;

      END IF;

   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
       RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.validate_ccids');
END validate_ccids;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Check_Required_Params                                                 |
|                                                                       |
| Check if required parameters are passed in                            |
|   - p_definition_rec.definition_code                                  |
|   - p_definition_rec.name                                             |
|   - p_definition_rec.ledger_id                                        |
|   - p_definition_rec.balance_side_code                                |
|   - p_je_source_name                                                  |
|   - p_mode                                                            |
+======================================================================*/
FUNCTION validate_required_params
  (p_definition_rec    IN r_definition
  ,p_je_source_name    IN VARCHAR2
  ,p_gl_date_from      IN DATE
  ,p_gl_date_to        IN DATE
  ,p_mode              IN VARCHAR2)
RETURN BOOLEAN IS

   l_err_found         BOOLEAN := FALSE;

   l_log_module        VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_required_params';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of validate_required_params'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   --
   --  Mandatory parameters check
   --
   IF p_definition_rec.definition_code IS NULL THEN

      fnd_message.set_name('XLA','XLA_COMMON_NULL_PARAM');
      fnd_message.set_token('PARAMETER','p_definition_code');

      fnd_msg_pub.add;
      l_err_found := TRUE;

   END IF;

   IF p_definition_rec.name IS NULL THEN

      fnd_message.set_name('XLA','XLA_COMMON_NULL_PARAM');
      fnd_message.set_token('PARAMETER','p_definition_name');

      fnd_msg_pub.add;
      l_err_found := TRUE;

   END IF;

   IF p_definition_rec.ledger_id IS NULL THEN

      fnd_message.set_name('XLA','XLA_COMMON_NULL_PARAM');
      fnd_message.set_token('PARAMETER','p_ledger_id');

      fnd_msg_pub.add;
      l_err_found := TRUE;

   END IF;

   IF p_je_source_name IS NULL THEN

      fnd_message.set_name('XLA','XLA_COMMON_NULL_PARAM');
      fnd_message.set_token('PARAMETER','p_je_source_name');

      fnd_msg_pub.add;
      l_err_found := TRUE;

   END IF;

   IF g_mode = C_UPDATE_MODE THEN

      IF p_gl_date_from IS NULL THEN

         fnd_message.set_name('XLA','XLA_COMMON_NULL_PARAM');
         fnd_message.set_token('PARAMETER','p_gl_date_from');

         fnd_msg_pub.add;
         l_err_found := TRUE;

      END IF;

      IF p_gl_date_to IS NULL THEN

         fnd_message.set_name('XLA','XLA_COMMON_NULL_PARAM');
         fnd_message.set_token('PARAMETER','p_gl_date_to');

         fnd_msg_pub.add;
         l_err_found := TRUE;

      END IF;

   END IF;

   IF p_mode IS NULL THEN

      fnd_message.set_name('XLA','XLA_COMMON_NULL_PARAM');
      fnd_message.set_token('PARAMETER','p_mode');

      fnd_msg_pub.add;
      l_err_found := TRUE;

   ELSIF p_mode NOT IN (C_CREATE_MODE, C_UPDATE_MODE) THEN

      fnd_message.set_name('XLA','XLA_COMMON_INVALID_PARAM2');
      fnd_message.set_token('PARAMETER_VALUE',p_mode);
      fnd_message.set_token('PARAMETER','p_mode');

      fnd_msg_pub.add;
      l_err_found := TRUE;

   END IF;

   IF l_err_found = FALSE THEN

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           (p_msg      => 'END of validate_required_params - no error found'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      END IF;

      RETURN TRUE;

   ELSE

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           (p_msg      => 'END of validate_required_params - Error found'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      END IF;

      RETURN FALSE;

   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
       RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.validate_required_params');

END validate_required_params;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Validate_Parameters                                                   |
|                                                                       |
| Validate input parameters                                             |
|                                                                       |
+======================================================================*/
FUNCTION validate_parameters
  (p_definition_rec    IN r_definition
  ,p_je_source_name    IN VARCHAR2
  ,p_gl_date_from      IN DATE
  ,p_gl_date_to        IN DATE
  ,p_mode              IN VARCHAR2)
RETURN BOOLEAN IS

   l_val_defn          BOOLEAN := TRUE;
   l_val_ledger        BOOLEAN := TRUE;
   l_val_je_sources    BOOLEAN := TRUE;
   l_val_ccids         BOOLEAN := TRUE;

   l_error_param       VARCHAR2(30);

   l_log_module        VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_parameters';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of validate_parameters'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   --
   --  Check if required parameters are passed in
   --
   IF NOT validate_required_params
            (p_definition_rec => p_definition_rec
            ,p_je_source_name => p_je_source_name
            ,p_gl_date_from   => p_gl_date_from
            ,p_gl_date_to     => p_gl_date_to
            ,p_mode           => p_mode)
   THEN

      RETURN FALSE;

   END IF;

   --
   -- Check definition exists in db
   --
   IF NOT validate_definition
              (p_definition_rec => p_definition_rec) THEN

      l_val_defn := FALSE;

   END IF;

   --
   -- Check ledger exists in db
   --
   IF NOT validate_ledger
               (p_ledger_id => p_definition_rec.ledger_id) THEN

      l_val_ledger := FALSE;

   END IF;

   --
   -- Check je source exists in db
   --
   IF NOT validate_je_source(p_je_source_name => p_je_source_name) THEN

     l_val_je_sources := FALSE;

   END IF;

   --
   --  Return results
   --
   IF NOT l_val_defn        OR NOT l_val_ledger
   OR NOT l_val_je_sources  OR NOT l_val_ccids
   THEN

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           (p_msg      => 'END of validate_parameters - Error found'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      END IF;

      RETURN FALSE;

   ELSE

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           (p_msg      => 'END of validate_parameters - No error found'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      END IF;

      RETURN TRUE;

   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
       RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.validate_parameters');

END validate_parameters;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| <procedure name>                                                      |
|                                                                       |
| <Description of the procedure>                                        |
|                                                                       |
+======================================================================*/
PROCEDURE create_definition
  (p_definition_rec   IN  r_definition)
IS

   C_ENABLED_FLAG      CONSTANT VARCHAR2(1)  := 'Y';
   C_DEFINED_BY_CODE   CONSTANT VARCHAR2(30) := 'FLEXFIELD';
   C_DEFN_STATUS_CODE  CONSTANT VARCHAR2(30) := 'NEW';
   C_DEFN_OWNER_CODE   CONSTANT VARCHAR2(30) := 'S';

   l_rowid             ROWID;

   l_creation_date     DATE;
   l_last_update_date  DATE;
   l_created_by        NUMBER(15);
   l_last_updated_by   NUMBER(15);
   l_last_update_login NUMBER(15);

   l_log_module                VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_definition';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of create_definition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   l_creation_date           := sysdate;
   l_last_update_date        := sysdate;
   l_created_by              := xla_environment_pkg.g_usr_id;
   l_last_updated_by         := xla_environment_pkg.g_usr_id;
   l_last_update_login       := xla_environment_pkg.g_login_id;

   xla_tb_definition_pvt.insert_row
     (p_rowid                     => l_rowid
     ,p_definition_code           => p_definition_rec.definition_code
     ,p_object_version_number     => C_OVN
     ,p_ledger_id                 => p_definition_rec.ledger_id
     ,p_enabled_flag              => C_ENABLED_FLAG
     ,p_balance_side_code         => NVL(p_definition_rec.balance_side_code,'C')
     ,p_defined_by_code           => C_DEFINED_BY_CODE
     ,p_definition_status_code    => C_DEFN_STATUS_CODE
     ,p_name                      => SUBSTRB(p_definition_rec.NAME,1,80)
     ,p_description               => p_definition_rec.description
     ,p_defn_owner_code           => C_DEFN_OWNER_CODE
     ,p_creation_date             => l_creation_date
     ,p_created_by                => l_created_by
     ,p_last_update_date          => l_last_update_date
     ,p_last_updated_by           => l_last_updated_by
     ,p_last_update_login         => l_last_update_login);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of create_definition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
       RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.create_definition');
END create_definition;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Create_Je_Source                                                      |
|                                                                       |
| Create Journal Source                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE create_je_source
  (p_definition_code  IN  VARCHAR2
  ,p_je_source_name   IN  VARCHAR2)
IS

   l_log_module                  VARCHAR2(240);

   l_creation_date               DATE;
   l_last_update_date            DATE;
   l_created_by                  NUMBER(15);
   l_last_updated_by             NUMBER(15);
   l_last_update_login           NUMBER(15);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_je_source';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of create_je_source'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   l_creation_date           := sysdate;
   l_last_update_date        := sysdate;
   l_created_by              := xla_environment_pkg.g_usr_id;
   l_last_updated_by         := xla_environment_pkg.g_usr_id;
   l_last_update_login       := xla_environment_pkg.g_login_id;

   INSERT INTO xla_tb_defn_je_sources
         (definition_code
         ,je_source_name
         ,object_version_number
         ,owner_code
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login)
   SELECT
          p_definition_code
         ,p_je_source_name
         ,C_OVN
         ,C_OWNER_ORACLE
         ,l_creation_date
         ,l_created_by
         ,l_last_update_date
         ,l_last_updated_by
         ,l_last_update_login
     FROM dual
    WHERE NOT EXISTS (
          SELECT 1
            FROM xla_tb_defn_je_sources
           WHERE definition_code = p_definition_code
             AND je_source_name  = p_je_source_name);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of create_je_source'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.create_je_source');
END create_je_source;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Create_Defn_Details                                                   |
|                                                                       |
| Create report definition details                                      |
|                                                                       |
+======================================================================*/
PROCEDURE create_defn_details
  (p_definition_code  IN  VARCHAR2)
IS

   l_log_module                  VARCHAR2(240);

   l_creation_date               DATE;
   l_last_update_date            DATE;
   l_created_by                  NUMBER(15);
   l_last_updated_by             NUMBER(15);
   l_last_update_login           NUMBER(15);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_defn_details';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of create_defn_details'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   l_creation_date           := sysdate;
   l_last_update_date        := sysdate;
   l_created_by              := xla_environment_pkg.g_usr_id;
   l_last_updated_by         := xla_environment_pkg.g_usr_id;
   l_last_update_login       := xla_environment_pkg.g_login_id;

   --
   -- As record elements (e.g. p_balance_tbl(i).balance_date) is not allowed
   -- in forall statements, reassgin parameters to local variables
   --
   INSERT INTO xla_tb_defn_details
         (definition_detail_id
         ,object_version_number
         ,definition_code
         ,flexfield_segment_code
         ,segment_value_from
         ,segment_value_to
         ,code_combination_id
         ,owner_code
         ,balance_date
         ,balance_amount
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login)
   SELECT
          xla_tb_defn_details_s.NEXTVAL
         ,C_OVN
         ,p_definition_code
         ,NULL  -- flexfield segment code
         ,NULL  -- segment value from
         ,NULL  -- segment value to
         ,code_combination_id
         ,C_OWNER_ORACLE
         ,balance_date
         ,balance_amount
         ,l_creation_date
         ,l_created_by
         ,l_last_update_date
         ,l_last_updated_by
         ,l_last_update_login
     FROM xla_tb_balances_gt
    WHERE definition_code = p_definition_code;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of create_defn_details'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.create_defn_details');
END create_defn_details;

PROCEDURE update_definition
  (p_definition_rec   IN  r_definition)
IS

   C_ENABLED_FLAG     CONSTANT VARCHAR2(1)  := 'Y';
   C_DEFINED_BY_CODE  CONSTANT VARCHAR2(30) := 'FLEXFIELD';
   C_DEFN_STATUS_CODE CONSTANT VARCHAR2(30) := 'NEW';
   C_DEFN_OWNER_CODE  CONSTANT VARCHAR2(30) := 'S';

   l_ovn                       NUMBER;
   l_ledger_id                 xla_tb_definitions_b.ledger_id%TYPE;
   l_enabled_flag              xla_tb_definitions_b.enabled_flag%TYPE;
   l_balance_side_code         xla_tb_definitions_b.balance_side_code%TYPE;
   l_defined_by_code           xla_tb_definitions_b.defined_by_code%TYPE;
   l_definition_status_code    xla_tb_definitions_b.definition_status_code%TYPE;
   l_owner_code                xla_tb_definitions_b.owner_code%TYPE;
   l_name                      xla_tb_definitions_vl.NAME%TYPE;
   l_description               xla_tb_definitions_vl.description%TYPE;

   l_creation_date             DATE;
   l_last_update_date          DATE;
   l_created_by                NUMBER(15);
   l_last_updated_by           NUMBER(15);
   l_last_update_login         NUMBER(15);

   l_log_module                VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_definition';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of update_definition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   l_creation_date           := sysdate;
   l_last_update_date        := sysdate;
   l_created_by              := xla_environment_pkg.g_usr_id;
   l_last_updated_by         := xla_environment_pkg.g_usr_id;
   l_last_update_login       := xla_environment_pkg.g_login_id;

   SELECT object_version_number
         ,NVL(p_definition_rec.ledger_id,ledger_id)
         ,enabled_flag
         ,NVL(p_definition_rec.balance_side_code,balance_side_code)
         ,defined_by_code
         ,definition_status_code
         ,owner_code
         ,NVL(p_definition_rec.NAME,NAME)
         ,NVL(p_definition_rec.description,description)
     INTO l_ovn
         ,l_ledger_id
         ,l_enabled_flag
         ,l_balance_side_code
         ,l_defined_by_code
         ,l_definition_status_code
         ,l_owner_code
         ,l_name
         ,l_description
     FROM xla_tb_definitions_vl
    WHERE definition_code = p_definition_rec.definition_code
      AND defined_by_code = C_DEFINED_BY_CODE
      AND owner_code      = C_DEFN_OWNER_CODE
      FOR UPDATE;

   xla_tb_definition_pvt.update_row
     (p_definition_code           => p_definition_rec.definition_code
     ,p_object_version_number     => l_ovn
     ,p_ledger_id                 => p_definition_rec.ledger_id
     ,p_enabled_flag              => C_ENABLED_FLAG
     ,p_balance_side_code         => NVL(p_definition_rec.balance_side_code,'C')
     ,p_defined_by_code           => C_DEFINED_BY_CODE
     ,p_definition_status_code    => C_DEFN_STATUS_CODE
     ,p_name                      => p_definition_rec.name
     ,p_description               => p_definition_rec.description
     ,p_defn_owner_code           => C_DEFN_OWNER_CODE
     ,p_last_update_date          => l_last_update_date
     ,p_last_updated_by           => l_last_updated_by
     ,p_last_update_login         => l_last_update_login);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of update_definition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       NULL;
   WHEN xla_exceptions_pkg.application_exception THEN
       RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.create_definition');
END update_definition;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Update_Je_Source                                                      |
|                                                                       |
| Update Journal Source                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE update_je_source
  (p_definition_code  IN  VARCHAR2
  ,p_je_source_name   IN  VARCHAR2)
IS


   l_db_cnt                    PLS_INTEGER;

   --
   -- WHO column information
   --
   l_last_update_date          DATE;
   l_last_updated_by           NUMBER(15);
   l_last_update_login         NUMBER(15);

   l_log_module                VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_je_source';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of update_je_source'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;


   l_last_update_date        := sysdate;
   l_last_updated_by         := xla_environment_pkg.g_usr_id;
   l_last_update_login       := xla_environment_pkg.g_login_id;

   SELECT COUNT(1)
     INTO l_db_cnt
     FROM xla_subledgers  xs
         ,gl_je_sources   gs
    WHERE xs.je_source_name = gs.je_source_name
      AND xs.je_source_name = p_je_source_name;

   IF l_db_cnt = 0 THEN

      create_je_source
        (p_definition_code  => p_definition_code
        ,p_je_source_name   => p_je_source_name);

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of update_je_source'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tb_balance_pkg.update_je_sources');
END update_je_source;

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Update_Defn_Details                                                   |
|                                                                       |
| Update Report Definition Details                                      |
|                                                                       |
+======================================================================*/
PROCEDURE update_defn_details
  (p_definition_code   IN  VARCHAR2)
IS

   --
   -- Variables for WHO column information
   --
   l_last_update_date  DATE;
   l_last_updated_by   NUMBER(15);
   l_last_update_login NUMBER(15);

   l_log_module                VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_defn_details';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of update_defn_details'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   l_last_update_date        := sysdate;
   l_last_updated_by         := xla_environment_pkg.g_usr_id;
   l_last_update_login       := xla_environment_pkg.g_login_id;

   MERGE INTO xla_tb_defn_details dt
   USING (SELECT code_combination_id
                ,balance_date
                ,balance_amount
            FROM xla_tb_balances_gt
           WHERE definition_code = p_definition_code) gt

      ON (dt.code_combination_id = gt.code_combination_id)

    WHEN MATCHED THEN
         UPDATE SET dt.object_version_number = dt.object_version_number + 1
                   ,dt.balance_date   = gt.balance_date
                   ,dt.balance_amount = gt.balance_amount
          WHERE dt.balance_date   <> gt.balance_date
             OR dt.balance_amount <> gt.balance_amount

    WHEN NOT MATCHED THEN
         INSERT (definition_detail_id
                ,object_version_number
                ,definition_code
                ,flexfield_segment_code
                ,segment_value_from
                ,segment_value_to
                ,code_combination_id
                ,owner_code
                ,balance_date
                ,balance_amount
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,last_update_login)
         VALUES (xla_tb_defn_details_s.NEXTVAL
                ,C_OVN
                ,p_definition_code
                ,NULL
                ,NULL
                ,NULL
                ,gt.code_combination_id
                ,C_OWNER_ORACLE
                ,gt.balance_date
                ,gt.balance_amount
                ,l_last_update_date
                ,l_last_updated_by
                ,l_last_update_date
                ,l_last_updated_by
                ,l_last_update_login);


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of update_defn_details'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

END update_defn_details;

--============================================================================
--
--  Private Procedures
-- The procedure inserts a row into the xla_gl_ledgers table
-- to store default values for ledger attributes related to the Trial Balance.
--============================================================================

PROCEDURE create_ledger
   ( p_ledger_id  IN NUMBER
   ) IS

   l_log_module                VARCHAR2(240);
   l_api_name         CONSTANT VARCHAR2(30) := 'create_ledger';
   l_ledger_id                 gl_ledgers.ledger_id%TYPE;
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_ledger';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of create_ledger'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   BEGIN
      SELECT ledger_id
      INTO   l_ledger_id
      FROM   xla_gl_ledgers
      WHERE  ledger_id = p_ledger_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         INSERT INTO xla_gl_ledgers
            (  LEDGER_ID
              ,OBJECT_VERSION_NUMBER
              ,WORK_UNIT
              ,NUM_OF_WORKERS
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,LAST_UPDATE_LOGIN
            )
         VALUES
            ( p_ledger_id
             ,1
             ,5000
             ,1
             ,SYSDATE
             ,xla_environment_pkg.g_usr_id
             ,SYSDATE
             ,xla_environment_pkg.g_usr_id
             ,xla_environment_pkg.g_login_id
            );
      WHEN OTHERS THEN
         RAISE;

   END;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of create_ledger'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE FND_API.G_EXC_ERROR;
   WHEN OTHERS THEN
        FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name       => C_PACKAGE_NAME
          ,p_procedure_name => l_api_name);

        xla_exceptions_pkg.raise_message
            (p_location => 'xla_tb_balance_pkg.create_ledger');

END create_ledger;
--============================================================================
--
--  Public Procedures
--
--============================================================================
PROCEDURE create_balances
  (p_api_version      IN  NUMBER
  ,p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit           IN  VARCHAR2 := FND_API.G_FALSE
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2
  ,p_definition_rec   IN  r_definition
  ,p_je_source_name   IN  VARCHAR2)
IS

   l_log_module                VARCHAR2(240);
   l_api_name         CONSTANT VARCHAR2(30) := 'create_balances';


BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_balances';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of create_balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   create_definition
     (p_definition_rec   => p_definition_rec);

   create_ledger
     (p_ledger_id        => p_definition_rec.ledger_id);

   create_je_source
     (p_definition_code  => p_definition_rec.definition_code
     ,p_je_source_name   => p_je_source_name);

   create_defn_details
     (p_definition_code  => p_definition_rec.definition_code);

   IF FND_API.To_Boolean( p_commit ) THEN

      COMMIT WORK;

   END IF;

   xla_tb_data_manager_pvt.add_partition
     (p_definition_code => p_definition_rec.definition_code);

   --
   -- Pass in process mode 'CHANGED' as data manager needs to
   -- create segment ranges in xla_tb_data_manager_pvt.upload.
   --
   submit_data_manager
     (p_definition_rec   => p_definition_rec
     ,p_je_source_name   => p_je_source_name
     ,p_gl_date_from     => NULL
     ,p_gl_date_to       => NULL
     ,p_process_mode     => 'CHANGED');


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of create_balance'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN

     RAISE FND_API.G_EXC_ERROR;

WHEN OTHERS THEN

     FND_MSG_PUB.Add_Exc_Msg
       (p_pkg_name       => C_PACKAGE_NAME
       ,p_procedure_name => l_api_name);

     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_balance_pkg.create_balances');

END create_balances;

PROCEDURE update_balances
  (p_api_version      IN  NUMBER
  ,p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit           IN  VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2
  ,p_definition_rec   IN  r_definition
  ,p_je_source_name   IN  VARCHAR2
  ,p_gl_date_from     IN  DATE
  ,p_gl_date_to       IN  DATE)
IS

   l_log_module                VARCHAR2(240);
   l_api_name         CONSTANT VARCHAR2(30) := 'update_balances';


BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_balances';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of update_balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   update_definition
     (p_definition_rec   => p_definition_rec);

   update_je_source
     (p_definition_code  => p_definition_rec.definition_code
     ,p_je_source_name   => p_je_source_name);

   update_defn_details
     (p_definition_code  => p_definition_rec.definition_code);

   submit_data_manager
     (p_definition_rec   => p_definition_rec
     ,p_je_source_name   => p_je_source_name
     ,p_gl_date_from     => p_gl_date_from
     ,p_gl_date_to       => p_gl_date_to
     ,p_process_mode     => NULL);

   IF FND_API.To_Boolean( p_commit ) THEN

      COMMIT WORK;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of update_balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN

     RAISE FND_API.G_EXC_ERROR;

WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_balance_pkg.update_balances');
END update_balances;

PROCEDURE upload_balances
  (p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_definition_code   IN  VARCHAR2
  ,p_definition_name   IN  VARCHAR2
  ,p_definition_desc   IN  VARCHAR2
  ,p_ledger_id         IN  NUMBER
  ,p_balance_side_code IN  VARCHAR2
  ,p_je_source_name    IN  VARCHAR2
  ,p_gl_date_from      IN  DATE
  ,p_gl_date_to        IN  DATE
  ,p_mode              IN  VARCHAR2
  )
IS

   l_log_module                VARCHAR2(240);
   l_api_name         CONSTANT VARCHAR2(30) := 'upload_balances';

   l_definition_rec            r_definition;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.upload_balances';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of upload_balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_definition_code = '||p_definition_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_definition_name = '||p_definition_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_definition_desc = '||p_definition_desc
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_balance_side_code = '||p_balance_side_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_je_source_name = '||p_je_source_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_gl_date_from = '||p_gl_date_from
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_gl_date_to = '||p_gl_date_to
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_mode = '||p_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;



   xla_environment_pkg.refresh;

   g_mode   := NVL(p_mode,'C_CREATE_MODE');

   l_definition_rec.definition_code   := p_definition_code;
   l_definition_rec.name              := p_definition_name;
   l_definition_rec.description       := p_definition_desc;
   l_definition_rec.ledger_id         := p_ledger_id;
   l_definition_rec.balance_side_code := p_balance_side_code;

   IF NOT validate_parameters
     (p_definition_rec    => l_definition_rec
     ,p_je_source_name    => p_je_source_name
     ,p_gl_date_from      => p_gl_date_from
     ,p_gl_date_to        => p_gl_date_to
     ,p_mode              => p_mode)
   THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      RETURN;

   END IF;

   IF NOT validate_ccids
      (p_definition_rec => l_definition_rec)
   THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      RETURN;

   END IF;

   IF g_mode = C_CREATE_MODE THEN

      create_balances
        (p_api_version      => p_api_version
        ,p_init_msg_list    => p_init_msg_list
        ,p_commit           => p_commit
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data
        ,p_definition_rec   => l_definition_rec
        ,p_je_source_name   => p_je_source_name);

   ELSIF g_mode = C_UPDATE_MODE THEN

      update_balances
        (p_api_version      => p_api_version
        ,p_init_msg_list    => p_init_msg_list
        ,p_commit           => p_commit
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data
        ,p_definition_rec   => l_definition_rec
        ,p_je_source_name   => p_je_source_name
        ,p_gl_date_from     => p_gl_date_from
        ,p_gl_date_to       => p_gl_date_to);

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of upload_balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN

     RAISE;

WHEN OTHERS THEN

    xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_balance_pkg.upload_balances');

END upload_balances;

PROCEDURE populate_user_trans_view
IS

    CURSOR c_event_class IS
       SELECT DISTINCT
           xut.application_id
          ,xec.entity_code
          ,xut.event_class_code
          ,xut.reporting_view_name
      FROM xla_tb_user_trans_views xut
          ,xla_event_classes_b xec
     WHERE xut.application_id       =  xec.application_id
       AND xut.event_class_code     =  xec.event_class_code
       AND xut.select_string        = '###'
       ;

    l_application_id       NUMBER(15);
    l_entity_code          VARCHAR2(30);
    l_event_class_code     VARCHAR2(30);
    l_reporting_view_name  VARCHAR2(30);
    l_select_string        VARCHAR2(4000);
    l_from_string          VARCHAR2(4000);
    l_where_string         VARCHAR2(4000);

    l_log_module           VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.populate_user_trans_view';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of populate_user_trans_view'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Inserting user transaction views'
           ,C_LEVEL_STATEMENT
           ,l_Log_module);
   END IF;

   --add parallel hint per bug 8222265

       INSERT INTO xla_tb_user_trans_views
          (definition_code
          ,application_id
          ,event_class_code
          ,reporting_view_name
          ,select_string
          ,from_string
          ,where_string
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          )
       SELECT /*+ leading(XTB,XECA,XTD) use_hash(XECA,XTD) swap_join_inputs(XECA) swap_join_inputs(XTD) parallel(XTB)*/
              DISTINCT
              xtb.definition_code
             ,source_application_id
             ,xeca.event_class_code
             ,xeca.reporting_view_name
             ,'###'
             ,'###'
             ,'###'
             ,SYSDATE
             ,xla_environment_pkg.g_Usr_Id
             ,SYSDATE
             ,xla_environment_pkg.g_Usr_Id
             ,xla_environment_pkg.g_Login_Id
             ,xla_environment_pkg.g_req_Id
             ,xla_environment_pkg.g_Prog_Appl_Id
             ,xla_environment_pkg.g_Prog_Id
             ,SYSDATE
       FROM   xla_trial_balances xtb
             ,xla_tb_definitions_b xtd
             ,xla_event_class_attrs xeca
       WHERE  xeca.event_class_code     <> 'MANUAL'
       AND    xtb.event_class_code      = xeca.event_class_code
       AND    xtb.source_application_id = xeca.application_id
       AND    xtb.definition_code       = xtd.definition_code
       AND NOT EXISTS
          (SELECT 'x'
             FROM  xla_tb_user_trans_views  xut
            WHERE  xut.definition_code  = xtb.definition_code
              AND  xut.application_id   = xtb.source_application_id
              AND  xut.event_class_code = xtb.event_class_code
                );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('# of rows inserted = ' || SQL%ROWCOUNT
           ,C_LEVEL_STATEMENT
           ,l_Log_module);
   END IF;

   OPEN c_event_class;
      LOOP
         FETCH c_event_class
          INTO l_application_id
              ,l_entity_code
              ,l_event_class_code
              ,l_reporting_view_name;

         EXIT WHEN c_event_class%NOTFOUND;

         IF l_event_class_code <> 'MANUAL'  THEN

            xla_report_utility_pkg.get_transaction_id
               (p_application_id      =>  l_application_id
               ,p_entity_code         =>  l_entity_code
               ,p_event_class_code    =>  l_event_class_code
               ,p_reporting_view_name =>  l_reporting_view_name
               ,p_select_str          =>  l_select_string
               ,p_from_str            =>  l_from_string
               ,p_where_str           =>  l_where_string);

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN

               trace
                  (p_msg      => 'l_select_string = ' || l_select_string
                  ,p_level    => C_LEVEL_PROCEDURE
                  ,p_module   => l_log_module);
               trace
                  (p_msg      => 'l_from_string = '   || l_from_string
                  ,p_level    => C_LEVEL_PROCEDURE
                  ,p_module   => l_log_module);
               trace
                  (p_msg      => 'l_where_string = '  || l_where_string
                  ,p_level    => C_LEVEL_PROCEDURE
                  ,p_module   => l_log_module);

               trace('Updating user transaction view...'
                    ,C_LEVEL_STATEMENT
                    ,l_Log_module);

            END IF;

            UPDATE xla_tb_user_trans_views
               SET select_string = l_select_string
                  ,from_string   = l_from_string
                  ,where_string  = l_where_string
            WHERE application_id = l_application_id
            AND   event_class_code = l_event_class_code
            ;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace('# of rows updated = ' || SQL%ROWCOUNT
                   ,C_LEVEL_STATEMENT
                   ,l_Log_module);
            END IF;

         END IF;
      END LOOP;
   CLOSE c_event_class;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of populate_user_trans_view'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
     RAISE;
WHEN OTHERS THEN
     xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_data_manager_pvt.populate_user_trans_view');
END populate_user_trans_view;

PROCEDURE create_ap_balances
  (p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_balance_side_code IN  VARCHAR2
  ,p_je_source_name    IN  VARCHAR2
  )
IS

l_log_module                VARCHAR2(240);
l_api_name         CONSTANT VARCHAR2(30) := 'create_ap_balances';

l_status       VARCHAR2(30);
l_industry     VARCHAR2(30);
l_schema       VARCHAR2(30);

l_count         NUMBER;

l_usr_id        NUMBER := xla_environment_pkg.g_Usr_Id;
l_login_id      NUMBER := xla_environment_pkg.g_Login_Id;
l_req_id        NUMBER := xla_environment_pkg.g_req_Id;
l_prog_appl_id  NUMBER := xla_environment_pkg.g_Prog_Appl_Id;
l_prog_id       NUMBER := xla_environment_pkg.g_Prog_Id;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_ap_balances';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of create_ap_balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_balance_side_code = '||p_balance_side_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_je_source_name = '||p_je_source_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF(NOT(ad_event_registry_pkg.is_event_done(
            p_owner  => 'XLA',
            p_event_name => 'XLA_AP_TRIAL_UPG_AP_BAL'))) THEN
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
               (p_msg      => 'Inserting for ap entries'
               ,p_level    => C_LEVEL_PROCEDURE
               ,p_module   => l_log_module);
      END IF;

 --for bug#7364921 did a trunc of xah.accounting_date in the query below
--Reason gl_date is populated with time component for upgraded data and the trial balance report
--query does not fetch data for a date including time stamp example report query date range is
--'01-MAY-2008' to '31-MAY-2008' and if for a invoice in trial balance table the gl_date is
--'31-MAY-2008 09:13:00 AM' this invoice will not fall in the above date range. It will fall in the date
-- range for the next day ie '01-MAY-2008' to '01-JUN-2008'

--BUG 8222265 added a swap_join_inputs(gcc) hint and flipped first 2 tables in FROM clause

      INSERT /*+ parallel(xtb) append */ INTO xla_trial_balances xtb(
          record_type_code
         ,source_entity_id
         ,event_class_code
         ,source_application_id
         ,applied_to_entity_id
         ,applied_to_application_id
         ,gl_date
         ,trx_currency_code
         ,entered_rounded_dr
         ,entered_rounded_cr
         ,entered_unrounded_dr
         ,entered_unrounded_cr
         ,acctd_rounded_dr
         ,acctd_rounded_cr
         ,acctd_unrounded_dr
         ,acctd_unrounded_cr
         ,code_combination_id
         ,balancing_segment_value
         ,natural_account_segment_value
         ,cost_center_segment_value
         ,intercompany_segment_value
         ,management_segment_value
         ,ledger_id
         ,definition_code
         ,party_id
         ,party_site_id
         ,party_type_code
         ,ae_header_id
         ,generated_by_code
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date)
      SELECT  /*+ ORDERED NO_EXPAND use_hash(xtd,xdd,xjs,xsu,xal,xah,gcc,xet,xteu,fsav)
                  parallel(alb) parallel(xal) parallel(xah) parallel(gcc) parallel(xteu)
                  parallel(xtd) parallel(xdd) parallel(xjs) parallel(xsu)
                  pq_distribute(xal,hash,hash) pq_distribute(fsav,none,broadcast)
                  pq_distribute(gcc,hash,hash) pq_distribute(xteu,hash,hash)
                  pq_distribute(xjs,none,broadcast) pq_distribute(xsu,none,broadcast)
                  swap_join_inputs(fsav) swap_join_inputs(xtd) swap_join_inputs(xdd)
                  swap_join_inputs(xjs) swap_join_inputs(xsu) swap_join_inputs(gcc) */
         DECODE(xet.event_class_code,'PREPAYMENT APPLICATIONS','APPLIED',DECODE(xteu.entity_id,xah.entity_id,'SOURCE','APPLIED')) record_type_code --bug6373682
         ,xah.entity_id                          source_entity_id
         ,xet.event_class_code                   event_class_code
         ,xah.application_id                     source_application_id
         ,DECODE(xet.event_class_code,'PREPAYMENT APPLICATIONS',xteu.entity_id,DECODE(xteu.entity_id, xah.entity_id,NULL,xteu.entity_id)) applied_to_entity_id --bug6373682
         ,200                                    applied_to_application_id
         ,trunc(xah.accounting_date)             gl_date --bug#7364921
         ,xal.currency_code                      trx_currency_code
         ,SUM(NVL(xal.entered_dr,0))             entered_rounded_dr
         ,SUM(NVL(xal.entered_cr,0))             entered_rounded_cr
         ,SUM(NVL(xal.entered_dr,0))             entered_unrounded_dr
         ,SUM(NVL(xal.entered_cr,0))             entered_unrounded_cr
         ,SUM(NVL(alb.accounted_dr, 0))          acctd_rounded_dr
         ,SUM(NVL(alb.accounted_cr, 0))          acctd_rounded_cr
         ,SUM(NVL(alb.accounted_dr,0))           acctd_unrounded_dr
         ,SUM(NVL(alb.accounted_cr,0))           acctd_unrounded_cr
         ,xal.code_combination_id                code_combination_id
         ,DECODE(fsav.balancing_segment,
              'SEGMENT1', gcc.segment1, 'SEGMENT2', gcc.segment2, 'SEGMENT3', gcc.segment3,
              'SEGMENT4', gcc.segment4, 'SEGMENT5', gcc.segment5, 'SEGMENT6', gcc.segment6,
              'SEGMENT7', gcc.segment7, 'SEGMENT8', gcc.segment8, 'SEGMENT9', gcc.segment9,
              'SEGMENT10', gcc.segment10, 'SEGMENT11', gcc.segment11, 'SEGMENT12', gcc.segment12,
              'SEGMENT13', gcc.segment13, 'SEGMENT14', gcc.segment14, 'SEGMENT15', gcc.segment15,
              'SEGMENT16', gcc.segment16, 'SEGMENT17', gcc.segment17, 'SEGMENT18', gcc.segment18,
              'SEGMENT19', gcc.segment19, 'SEGMENT20', gcc.segment20, 'SEGMENT21', gcc.segment21,
              'SEGMENT22', gcc.segment22, 'SEGMENT23', gcc.segment23, 'SEGMENT24', gcc.segment24,
              'SEGMENT25', gcc.segment25, 'SEGMENT26', gcc.segment26, 'SEGMENT27', gcc.segment27,
              'SEGMENT28', gcc.segment28, 'SEGMENT29', gcc.segment29, 'SEGMENT30', gcc.segment30,
              null)
                                                 balancing_segment_value
         ,DECODE(fsav.account_segment,
              'SEGMENT1', gcc.segment1, 'SEGMENT2', gcc.segment2, 'SEGMENT3', gcc.segment3,
              'SEGMENT4', gcc.segment4, 'SEGMENT5', gcc.segment5, 'SEGMENT6', gcc.segment6,
              'SEGMENT7', gcc.segment7, 'SEGMENT8', gcc.segment8, 'SEGMENT9', gcc.segment9,
              'SEGMENT10', gcc.segment10, 'SEGMENT11', gcc.segment11, 'SEGMENT12', gcc.segment12,
              'SEGMENT13', gcc.segment13, 'SEGMENT14', gcc.segment14, 'SEGMENT15', gcc.segment15,
              'SEGMENT16', gcc.segment16, 'SEGMENT17', gcc.segment17, 'SEGMENT18', gcc.segment18,
              'SEGMENT19', gcc.segment19, 'SEGMENT20', gcc.segment20, 'SEGMENT21', gcc.segment21,
              'SEGMENT22', gcc.segment22, 'SEGMENT23', gcc.segment23, 'SEGMENT24', gcc.segment24,
              'SEGMENT25', gcc.segment25, 'SEGMENT26', gcc.segment26, 'SEGMENT27', gcc.segment27,
              'SEGMENT28', gcc.segment28, 'SEGMENT29', gcc.segment29, 'SEGMENT30', gcc.segment30,
              null)
                                                 natural_account_segment_value
         ,DECODE(fsav.cost_crt_segment,
              'SEGMENT1', gcc.segment1, 'SEGMENT2', gcc.segment2, 'SEGMENT3', gcc.segment3,
              'SEGMENT4', gcc.segment4, 'SEGMENT5', gcc.segment5, 'SEGMENT6', gcc.segment6,
              'SEGMENT7', gcc.segment7, 'SEGMENT8', gcc.segment8, 'SEGMENT9', gcc.segment9,
              'SEGMENT10', gcc.segment10, 'SEGMENT11', gcc.segment11, 'SEGMENT12', gcc.segment12,
              'SEGMENT13', gcc.segment13, 'SEGMENT14', gcc.segment14, 'SEGMENT15', gcc.segment15,
              'SEGMENT16', gcc.segment16, 'SEGMENT17', gcc.segment17, 'SEGMENT18', gcc.segment18,
              'SEGMENT19', gcc.segment19, 'SEGMENT20', gcc.segment20, 'SEGMENT21', gcc.segment21,
              'SEGMENT22', gcc.segment22, 'SEGMENT23', gcc.segment23, 'SEGMENT24', gcc.segment24,
              'SEGMENT25', gcc.segment25, 'SEGMENT26', gcc.segment26, 'SEGMENT27', gcc.segment27,
              'SEGMENT28', gcc.segment28, 'SEGMENT29', gcc.segment29, 'SEGMENT30', gcc.segment30,
              null)
                                                 cost_center_segment_value
         ,DECODE(fsav.intercompany_segment,
              'SEGMENT1', gcc.segment1, 'SEGMENT2', gcc.segment2, 'SEGMENT3', gcc.segment3,
              'SEGMENT4', gcc.segment4, 'SEGMENT5', gcc.segment5, 'SEGMENT6', gcc.segment6,
              'SEGMENT7', gcc.segment7, 'SEGMENT8', gcc.segment8, 'SEGMENT9', gcc.segment9,
              'SEGMENT10', gcc.segment10, 'SEGMENT11', gcc.segment11, 'SEGMENT12', gcc.segment12,
              'SEGMENT13', gcc.segment13, 'SEGMENT14', gcc.segment14, 'SEGMENT15', gcc.segment15,
              'SEGMENT16', gcc.segment16, 'SEGMENT17', gcc.segment17, 'SEGMENT18', gcc.segment18,
              'SEGMENT19', gcc.segment19, 'SEGMENT20', gcc.segment20, 'SEGMENT21', gcc.segment21,
              'SEGMENT22', gcc.segment22, 'SEGMENT23', gcc.segment23, 'SEGMENT24', gcc.segment24,
              'SEGMENT25', gcc.segment25, 'SEGMENT26', gcc.segment26, 'SEGMENT27', gcc.segment27,
              'SEGMENT28', gcc.segment28, 'SEGMENT29', gcc.segment29, 'SEGMENT30', gcc.segment30,
              null)
                                                 intercompany_segment_value
         ,DECODE(fsav.management_segment,
              'SEGMENT1', gcc.segment1, 'SEGMENT2', gcc.segment2, 'SEGMENT3', gcc.segment3,
              'SEGMENT4', gcc.segment4, 'SEGMENT5', gcc.segment5, 'SEGMENT6', gcc.segment6,
              'SEGMENT7', gcc.segment7, 'SEGMENT8', gcc.segment8, 'SEGMENT9', gcc.segment9,
              'SEGMENT10', gcc.segment10, 'SEGMENT11', gcc.segment11, 'SEGMENT12', gcc.segment12,
              'SEGMENT13', gcc.segment13, 'SEGMENT14', gcc.segment14, 'SEGMENT15', gcc.segment15,
              'SEGMENT16', gcc.segment16, 'SEGMENT17', gcc.segment17, 'SEGMENT18', gcc.segment18,
              'SEGMENT19', gcc.segment19, 'SEGMENT20', gcc.segment20, 'SEGMENT21', gcc.segment21,
              'SEGMENT22', gcc.segment22, 'SEGMENT23', gcc.segment23, 'SEGMENT24', gcc.segment24,
              'SEGMENT25', gcc.segment25, 'SEGMENT26', gcc.segment26, 'SEGMENT27', gcc.segment27,
              'SEGMENT28', gcc.segment28, 'SEGMENT29', gcc.segment29, 'SEGMENT30', gcc.segment30,
              null)
                                                 management_segment_value
         ,xah.ledger_id                          ledger_id
         ,xtd.definition_code                    DEFINITION_code
         ,xal.party_id                           party_id
         ,xal.party_site_id                      party_site_id
         ,xal.party_type_code                    party_type_code
         ,xah.ae_header_id                       ae_header_id
         ,'SYSTEM'                               generated_by_code
         ,SYSDATE                                creation_date
         ,l_Usr_Id                               created_by
         ,SYSDATE                                last_update_date
         ,l_Usr_Id                               last_updated_by
         ,l_Login_Id                             last_update_login
         ,l_req_Id                               request_id
         ,l_Prog_Appl_Id                         program_application_id
         ,l_Prog_Id                              program_id
         ,SYSDATE                                program_update_date
        FROM
          xla_ae_headers               PARTITION (AP) xah
	 ,ap_liability_balance                        alb
         ,xla_event_types_b                           xet
         ,xla_tb_defn_details                         xdd
         ,xla_tb_definitions_b                        xtd
         ,xla_tb_defn_je_sources                      xjs
         ,xla_subledgers                              xsu
         ,xla_transaction_entities_upg PARTITION (AP) xteu
         ,xla_ae_lines                 PARTITION (AP) xal
         ,gl_code_combinations                        gcc
         ,( SELECT /*+ NO_MERGE PARALLEL(fsav1) */ id_flex_num
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, 'GL_BALANCING', application_column_name, NULL)) balancing_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, 'GL_ACCOUNT', application_column_name, NULL)) account_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, 'FA_COST_CTR', application_column_name, NULL)) cost_crt_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, 'GL_INTERCOMPANY', application_column_name, NULL)) intercompany_segment
             ,MAX(DECODE(SEGMENT_ATTRIBUTE_TYPE, 'GL_MANAGEMENT', application_column_name, NULL)) management_segment
            FROM fnd_segment_attribute_values  fsav1  -- Need alias here also.
            WHERE application_id = 101
            AND id_flex_code = 'GL#'
            AND attribute_value = 'Y'
            GROUP BY id_flex_num) fsav
       WHERE xtd.definition_code      = xdd.definition_code
         AND xtd.definition_code      = xjs.definition_code
         AND xtd.enabled_flag         = 'Y'
         AND xjs.je_source_name       = xsu.je_source_name
         AND xsu.application_id       = 200
         AND xtd.ledger_id            = alb.set_of_books_id
         AND alb.code_combination_id  = xdd.code_combination_id
         --
         --  AND alb.ae_header_id is NOT NULL     -- now considering both cases in one shot
         --
         AND NVL(alb.ae_header_id, alb.sle_header_id)                = xah.completion_acct_seq_value
         AND NVL2(alb.ae_header_id,200, alb.journal_sequence_id)     = xah.completion_acct_seq_version_id
         AND NVL2(alb.ae_header_id, alb.ae_line_id,alb.sle_line_num) = xal.ae_line_num
         AND (
              (alb.ae_header_id IS NOT NULL AND xah.upg_source_application_id = 200)
              OR
              (alb.ae_header_id IS NULL AND xah.upg_source_application_id = 600 AND xah.upg_batch_id = -5672)
             )
         AND alb.code_combination_id  = xal.code_combination_id
         AND xal.application_id       = 200
         AND xah.gl_transfer_status_code IN ('Y','NT')
         AND xah.application_id       = xal.application_id
         AND xah.ae_header_id         = xal.ae_header_id
         AND xal.code_combination_id  = gcc.code_combination_id
         AND xah.application_id       = xet.application_id
         AND xah.event_type_code      = xet.event_type_code
         AND xteu.application_id      = 200
         AND xteu.entity_code         =  'AP_INVOICES'
         AND xteu.source_id_int_1     = alb.invoice_id
         AND gcc.chart_of_accounts_id = fsav.id_flex_num
       GROUP BY
         DECODE(xet.event_class_code,'PREPAYMENT APPLICATIONS','APPLIED',DECODE(xteu.entity_id,xah.entity_id,'SOURCE','APPLIED'))
         ,xah.entity_id
         ,xet.event_class_code
         ,xah.application_id
         ,DECODE(xet.event_class_code,'PREPAYMENT APPLICATIONS',xteu.entity_id,DECODE(xteu.entity_id, xah.entity_id,NULL,xteu.entity_id))
         ,xah.accounting_date
         ,xal.currency_code
         ,xal.code_combination_id
         ,DECODE(fsav.balancing_segment,
              'SEGMENT1', gcc.segment1, 'SEGMENT2', gcc.segment2, 'SEGMENT3', gcc.segment3,
              'SEGMENT4', gcc.segment4, 'SEGMENT5', gcc.segment5, 'SEGMENT6', gcc.segment6,
              'SEGMENT7', gcc.segment7, 'SEGMENT8', gcc.segment8, 'SEGMENT9', gcc.segment9,
              'SEGMENT10', gcc.segment10, 'SEGMENT11', gcc.segment11, 'SEGMENT12', gcc.segment12,
              'SEGMENT13', gcc.segment13, 'SEGMENT14', gcc.segment14, 'SEGMENT15', gcc.segment15,
              'SEGMENT16', gcc.segment16, 'SEGMENT17', gcc.segment17, 'SEGMENT18', gcc.segment18,
              'SEGMENT19', gcc.segment19, 'SEGMENT20', gcc.segment20, 'SEGMENT21', gcc.segment21,
              'SEGMENT22', gcc.segment22, 'SEGMENT23', gcc.segment23, 'SEGMENT24', gcc.segment24,
              'SEGMENT25', gcc.segment25, 'SEGMENT26', gcc.segment26, 'SEGMENT27', gcc.segment27,
              'SEGMENT28', gcc.segment28, 'SEGMENT29', gcc.segment29, 'SEGMENT30', gcc.segment30,
              null)
         ,DECODE(fsav.account_segment,
              'SEGMENT1', gcc.segment1, 'SEGMENT2', gcc.segment2, 'SEGMENT3', gcc.segment3,
              'SEGMENT4', gcc.segment4, 'SEGMENT5', gcc.segment5, 'SEGMENT6', gcc.segment6,
              'SEGMENT7', gcc.segment7, 'SEGMENT8', gcc.segment8, 'SEGMENT9', gcc.segment9,
              'SEGMENT10', gcc.segment10, 'SEGMENT11', gcc.segment11, 'SEGMENT12', gcc.segment12,
              'SEGMENT13', gcc.segment13, 'SEGMENT14', gcc.segment14, 'SEGMENT15', gcc.segment15,
              'SEGMENT16', gcc.segment16, 'SEGMENT17', gcc.segment17, 'SEGMENT18', gcc.segment18,
              'SEGMENT19', gcc.segment19, 'SEGMENT20', gcc.segment20, 'SEGMENT21', gcc.segment21,
              'SEGMENT22', gcc.segment22, 'SEGMENT23', gcc.segment23, 'SEGMENT24', gcc.segment24,
              'SEGMENT25', gcc.segment25, 'SEGMENT26', gcc.segment26, 'SEGMENT27', gcc.segment27,
              'SEGMENT28', gcc.segment28, 'SEGMENT29', gcc.segment29, 'SEGMENT30', gcc.segment30,
              null)
         ,DECODE(fsav.cost_crt_segment,
              'SEGMENT1', gcc.segment1, 'SEGMENT2', gcc.segment2, 'SEGMENT3', gcc.segment3,
              'SEGMENT4', gcc.segment4, 'SEGMENT5', gcc.segment5, 'SEGMENT6', gcc.segment6,
              'SEGMENT7', gcc.segment7, 'SEGMENT8', gcc.segment8, 'SEGMENT9', gcc.segment9,
              'SEGMENT10', gcc.segment10, 'SEGMENT11', gcc.segment11, 'SEGMENT12', gcc.segment12,
              'SEGMENT13', gcc.segment13, 'SEGMENT14', gcc.segment14, 'SEGMENT15', gcc.segment15,
              'SEGMENT16', gcc.segment16, 'SEGMENT17', gcc.segment17, 'SEGMENT18', gcc.segment18,
              'SEGMENT19', gcc.segment19, 'SEGMENT20', gcc.segment20, 'SEGMENT21', gcc.segment21,
              'SEGMENT22', gcc.segment22, 'SEGMENT23', gcc.segment23, 'SEGMENT24', gcc.segment24,
              'SEGMENT25', gcc.segment25, 'SEGMENT26', gcc.segment26, 'SEGMENT27', gcc.segment27,
              'SEGMENT28', gcc.segment28, 'SEGMENT29', gcc.segment29, 'SEGMENT30', gcc.segment30,
              null)
         ,DECODE(fsav.intercompany_segment,
              'SEGMENT1', gcc.segment1, 'SEGMENT2', gcc.segment2, 'SEGMENT3', gcc.segment3,
              'SEGMENT4', gcc.segment4, 'SEGMENT5', gcc.segment5, 'SEGMENT6', gcc.segment6,
              'SEGMENT7', gcc.segment7, 'SEGMENT8', gcc.segment8, 'SEGMENT9', gcc.segment9,
              'SEGMENT10', gcc.segment10, 'SEGMENT11', gcc.segment11, 'SEGMENT12', gcc.segment12,
              'SEGMENT13', gcc.segment13, 'SEGMENT14', gcc.segment14, 'SEGMENT15', gcc.segment15,
              'SEGMENT16', gcc.segment16, 'SEGMENT17', gcc.segment17, 'SEGMENT18', gcc.segment18,
              'SEGMENT19', gcc.segment19, 'SEGMENT20', gcc.segment20, 'SEGMENT21', gcc.segment21,
              'SEGMENT22', gcc.segment22, 'SEGMENT23', gcc.segment23, 'SEGMENT24', gcc.segment24,
              'SEGMENT25', gcc.segment25, 'SEGMENT26', gcc.segment26, 'SEGMENT27', gcc.segment27,
              'SEGMENT28', gcc.segment28, 'SEGMENT29', gcc.segment29, 'SEGMENT30', gcc.segment30,
              null)
         ,DECODE(fsav.management_segment,
              'SEGMENT1', gcc.segment1, 'SEGMENT2', gcc.segment2, 'SEGMENT3', gcc.segment3,
              'SEGMENT4', gcc.segment4, 'SEGMENT5', gcc.segment5, 'SEGMENT6', gcc.segment6,
              'SEGMENT7', gcc.segment7, 'SEGMENT8', gcc.segment8, 'SEGMENT9', gcc.segment9,
              'SEGMENT10', gcc.segment10, 'SEGMENT11', gcc.segment11, 'SEGMENT12', gcc.segment12,
              'SEGMENT13', gcc.segment13, 'SEGMENT14', gcc.segment14, 'SEGMENT15', gcc.segment15,
              'SEGMENT16', gcc.segment16, 'SEGMENT17', gcc.segment17, 'SEGMENT18', gcc.segment18,
              'SEGMENT19', gcc.segment19, 'SEGMENT20', gcc.segment20, 'SEGMENT21', gcc.segment21,
              'SEGMENT22', gcc.segment22, 'SEGMENT23', gcc.segment23, 'SEGMENT24', gcc.segment24,
              'SEGMENT25', gcc.segment25, 'SEGMENT26', gcc.segment26, 'SEGMENT27', gcc.segment27,
              'SEGMENT28', gcc.segment28, 'SEGMENT29', gcc.segment29, 'SEGMENT30', gcc.segment30,
              null)
         ,xah.ledger_id
         ,xtd.definition_code
         ,xal.party_id
         ,xal.party_site_id
         ,xal.party_type_code
         ,xah.ae_header_id
         ;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('# of rows inserted = ' || SQL%ROWCOUNT
           ,C_LEVEL_STATEMENT
           ,l_Log_module);
      END IF;
      ad_event_registry_pkg.set_event_as_done('XLA', 'XLA_AP_TRIAL_UPG_AP_BAL', 'xla_tb_balance_pkg');
      COMMIT;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of create_ap_balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
END create_ap_balances;

PROCEDURE create_defns_in_batch
     (p_balance_side_code  IN VARCHAR2
     ,p_je_source_name     IN VARCHAR2)
IS

TYPE t_array_vc30   IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
TYPE t_array_num15  IS TABLE OF NUMBER(15)    INDEX BY BINARY_INTEGER;

l_array_defn_code     t_array_vc30;
l_array_ledger_id     t_array_num15;

l_status       VARCHAR2(30);
l_industry     VARCHAR2(30);
l_schema       VARCHAR2(30);

l_log_module                VARCHAR2(240);
l_api_name         CONSTANT VARCHAR2(30) := 'create_defns_in_batch';
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.create_defns_in_batch';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of create_defns_in_batch'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_balance_side_code = '||p_balance_side_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_je_source_name = '||p_je_source_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF(NOT(ad_event_registry_pkg.is_event_done(
            p_owner  => 'XLA',
            p_event_name => 'XLA_AP_TRIAL_UPG_DEFN'))) THEN
      SELECT DISTINCT definition_code, ledger_id
        BULK COLLECT INTO l_array_defn_code, l_array_ledger_id
        FROM  xla_tb_balances_gt tb
       WHERE definition_code NOT IN
             (
              SELECT definition_code
              FROM xla_tb_definitions_b
             );

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
         trace
            (p_msg      => 'Fetched definitions into the array'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      FORALL i IN l_array_defn_code.first .. l_array_defn_code.last
         INSERT INTO   xla_tb_definitions_b
                    (definition_code
                    ,object_version_number
                    ,ledger_id
                    ,enabled_flag
                    ,balance_side_code
                    ,defined_by_code
                    ,definition_status_code
                    ,creation_date
                    ,created_by
                    ,last_update_date
                    ,last_updated_by
                    ,last_update_login
                    ,program_application_id
                    ,program_id
                    ,program_update_date
                    ,owner_code)
             VALUES (l_array_defn_code(i)
                    ,1
                    ,l_array_ledger_id(i)
                    ,'Y'
                    ,p_balance_side_code
                    ,'FLEXFIELD'
                    ,'NEW'
                    ,sysdate
                    ,xla_environment_pkg.g_Usr_Id
                    ,sysdate
                    ,xla_environment_pkg.g_Usr_Id
                    ,xla_environment_pkg.g_login_Id
                    ,xla_environment_pkg.g_Prog_Appl_Id
                    ,xla_environment_pkg.g_Usr_Id
                    ,sysdate
                    ,'S');

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
         trace
            (p_msg      => 'inserted definition into the xla_tb_definitions_b:'|| SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      FORALL i IN l_array_defn_code.first .. l_array_defn_code.last
         INSERT INTO   xla_tb_defn_je_sources
                    (definition_code
                    ,je_source_name
                    ,object_version_number
                    ,creation_date
                    ,created_by
                    ,last_update_date
                    ,last_updated_by
                    ,last_update_login
                    ,owner_code)
             VALUES (l_array_defn_code(i)
                    ,p_je_source_name
                    ,1
                    ,sysdate
                    ,xla_environment_pkg.g_Usr_Id
                    ,sysdate
                    ,xla_environment_pkg.g_Usr_Id
                    ,xla_environment_pkg.g_login_Id
                    ,'S');

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
         trace
            (p_msg      => 'inserted definition into the xla_tb_defn_je_sources:'|| SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      INSERT INTO xla_gl_ledgers
            (  LEDGER_ID
              ,OBJECT_VERSION_NUMBER
              ,WORK_UNIT
              ,NUM_OF_WORKERS
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,LAST_UPDATE_LOGIN
            )
      SELECT DISTINCT
              xtb.ledger_id
             ,1
             ,5000
             ,1
             ,SYSDATE
             ,xla_environment_pkg.g_usr_id
             ,SYSDATE
             ,xla_environment_pkg.g_usr_id
             ,xla_environment_pkg.g_login_id
      FROM xla_tb_balances_gt xtb
      WHERE NOT EXISTS
             (SELECT 1
              FROM   XLA_GL_LEDGERS
              WHERE  ledger_id = xtb.ledger_id);

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
         trace
            (p_msg      => 'inserted ledger info into the xla_gl_ledgers:'|| SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;


      INSERT INTO xla_tb_definitions_tl
         (
          definition_code
         ,name
         ,description
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         ,language
         ,source_lang
         )
      SELECT DISTINCT
          definition_code
         ,definition_name
         ,definition_desc
         ,xla_environment_pkg.g_Usr_Id
         ,sysdate
         ,xla_environment_pkg.g_Usr_Id
         ,sysdate
         ,xla_environment_pkg.g_login_Id
         ,l.language_code
         ,userenv('LANG')
        FROM fnd_languages l
             ,xla_tb_balances_gt tb
       WHERE l.installed_flag in ('I', 'B')
         AND NOT EXISTS
             (SELECT 1
                FROM xla_tb_definitions_tl t
               WHERE t.definition_code = tb.definition_code
                 AND t.language = l.language_code);

      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
         trace
            (p_msg      => 'inserted definition into the xla_tb_definitions_tl:'|| SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

     --
     --  Insert rows into xla_tb_defn_details
     --

      INSERT ALL INTO xla_tb_defn_details
          (definition_detail_id
          ,object_version_number
          ,definition_code
          ,flexfield_segment_code
          ,segment_value_from
          ,segment_value_to
          ,code_combination_id
          ,owner_code
          ,balance_date
          ,balance_amount
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login)
       VALUES (xla_tb_defn_details_s.NEXTVAL
          ,1
          ,definition_code
          ,NULL  -- flexfield segment code
          ,NULL  -- segment value from
          ,NULL  -- segment value to
          ,code_combination_id
          ,owner_code
          ,NULL  -- balance_date
          ,NULL  -- balance_amount
          ,sysdate
          ,xla_environment_pkg.g_Usr_Id
          ,sysdate
          ,xla_environment_pkg.g_Usr_Id
          ,xla_environment_pkg.g_login_Id)
       INTO xla_tb_def_seg_ranges
          (definition_code
          ,line_num
          ,balance_date
          ,owner_code
          ,segment1_from
          ,segment1_to
          ,segment2_from
          ,segment2_to
          ,segment3_from
          ,segment3_to
          ,segment4_from
          ,segment4_to
          ,segment5_from
          ,segment5_to
          ,segment6_from
          ,segment6_to
          ,segment7_from
          ,segment7_to
          ,segment8_from
          ,segment8_to
          ,segment9_from
          ,segment9_to
          ,segment10_from
          ,segment10_to
          ,segment11_from
          ,segment11_to
          ,segment12_from
          ,segment12_to
          ,segment13_from
          ,segment13_to
          ,segment14_from
          ,segment14_to
          ,segment15_from
          ,segment15_to
          ,segment16_from
          ,segment16_to
          ,segment17_from
          ,segment17_to
          ,segment18_from
          ,segment18_to
          ,segment19_from
          ,segment19_to
          ,segment20_from
          ,segment20_to
          ,segment21_from
          ,segment21_to
          ,segment22_from
          ,segment22_to
          ,segment23_from
          ,segment23_to
          ,segment24_from
          ,segment24_to
          ,segment25_from
          ,segment25_to
          ,segment26_from
          ,segment26_to
          ,segment27_from
          ,segment27_to
          ,segment28_from
          ,segment28_to
          ,segment29_from
          ,segment29_to
          ,segment30_from
          ,segment30_to)
       VALUES (definition_code
          ,line_num
          ,NULL  -- balance_date
          ,owner_code
          ,segment1
          ,segment1
          ,segment2
          ,segment2
          ,segment3
          ,segment3
          ,segment4
          ,segment4
          ,segment5
          ,segment5
          ,segment6
          ,segment6
          ,segment7
          ,segment7
          ,segment8
          ,segment8
          ,segment9
          ,segment9
          ,segment10
          ,segment10
          ,segment11
          ,segment11
          ,segment12
          ,segment12
          ,segment13
          ,segment13
          ,segment14
          ,segment14
          ,segment15
          ,segment15
          ,segment16
          ,segment16
          ,segment17
          ,segment17
          ,segment18
          ,segment18
          ,segment19
          ,segment19
          ,segment20
          ,segment20
          ,segment21
          ,segment21
          ,segment22
          ,segment22
          ,segment23
          ,segment23
          ,segment24
          ,segment24
          ,segment25
          ,segment25
          ,segment26
          ,segment26
          ,segment27
          ,segment27
          ,segment28
          ,segment28
          ,segment29
          ,segment29
          ,segment30
          ,segment30)
      SELECT tdd.definition_code         definition_code
         ,ROWNUM line_num
         ,tdd.code_combination_id
         ,'S' owner_code
         ,balance_date
         ,balance_amount
         ,gcc.segment1
         ,gcc.segment2
         ,gcc.segment3
         ,gcc.segment4
         ,gcc.segment5
         ,gcc.segment6
         ,gcc.segment7
         ,gcc.segment8
         ,gcc.segment9
         ,gcc.segment10
         ,gcc.segment11
         ,gcc.segment12
         ,gcc.segment13
         ,gcc.segment14
         ,gcc.segment15
         ,gcc.segment16
         ,gcc.segment17
         ,gcc.segment18
         ,gcc.segment19
         ,gcc.segment20
         ,gcc.segment21
         ,gcc.segment22
         ,gcc.segment23
         ,gcc.segment24
         ,gcc.segment25
         ,gcc.segment26
         ,gcc.segment27
         ,gcc.segment28
         ,gcc.segment29
         ,gcc.segment30
       FROM xla_tb_balances_gt          tdd
           ,gl_code_combinations        gcc
      WHERE gcc.code_combination_id   = tdd.code_combination_id;


      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
         trace
            (p_msg      => 'multi inserted definition into the details and seg ranges:'|| SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

     --
     --  Commit before creating partitions
     --
      COMMIT ;

      IF (NOT FND_INSTALLATION.get_app_info
                       (application_short_name   => 'XLA'
                       ,status                   => l_status
                       ,industry                 => l_industry
                       ,oracle_schema            => l_schema)) THEN
         l_schema := NULL;
      END IF;

     --
     -- Add partitions to xla_trial_balances
     --
      IF (l_array_defn_code.COUNT > 0 ) THEN
         FOR i in  l_array_defn_code.FIRST .. l_array_defn_code.LAST LOOP
            BEGIN
               IF (C_LEVEL_STATEMENT>= g_log_level) THEN
                  trace
                     (p_msg      => 'ALTER TABLE '||l_schema||'.xla_trial_balances'
                                            ||' ADD PARTITION '||l_array_defn_code(i)
                                            || ' VALUES ('''||l_array_defn_code(i)||''' ) executing'
                     ,p_level    => C_LEVEL_STATEMENT
                     ,p_module   => l_log_module);
                  trace
                     (p_msg      => 'l_array_defn_code(i)'||l_array_defn_code(i)
                                               || ' l_ledger(i)'|| l_array_ledger_id(i)
                     ,p_level    => C_LEVEL_STATEMENT
                     ,p_module   => l_log_module);
               END IF;

               EXECUTE IMMEDIATE
                  'ALTER TABLE '||l_schema||'.xla_trial_balances'||' ADD PARTITION '||l_array_defn_code(i)||
                  ' VALUES ('''||l_array_defn_code(i)||''' )';
            EXCEPTION
               WHEN OTHERS THEN
                  IF(SQLCODE = -14312) THEN
                  -- partition already exist
                     IF (C_LEVEL_STATEMENT>= g_log_level) THEN
                        trace
                           (p_msg      => 'partition already exists:' || l_array_defn_code(i)
                           ,p_level    => C_LEVEL_STATEMENT
                           ,p_module   => l_log_module);
                     END IF;
                  ELSE
                     raise;
                  END IF;
            END;

         END LOOP;
      END IF;
      ad_event_registry_pkg.set_event_as_done('XLA', 'XLA_AP_TRIAL_UPG_DEFN', 'xla_tb_balance_pkg');

      COMMIT;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
            (p_msg      => 'END of Upgrade_AP_Balances'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
   END IF;
END create_defns_in_batch;

PROCEDURE Upgrade_AP_Balances
  (p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_balance_side_code IN  VARCHAR2
  ,p_je_source_name    IN  VARCHAR2
  )
IS

   l_log_module                VARCHAR2(240);
   l_api_name         CONSTANT VARCHAR2(30) := 'Upgrade_AP_Balances';

   l_definition_rec            r_definition;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Upgrade_AP_Balances';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of Upgrade_AP_Balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_balance_side_code = '||p_balance_side_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_je_source_name = '||p_je_source_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   xla_environment_pkg.refresh;

   IF NOT validate_je_source
     (p_je_source_name    => p_je_source_name)
   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   create_defns_in_batch
        (p_balance_side_code=> p_balance_side_code
        ,p_je_source_name    => p_je_source_name);

   create_ap_balances
        (p_api_version      => p_api_version
        ,p_init_msg_list    => p_init_msg_list
        ,p_commit           => p_commit
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data
        ,p_balance_side_code=> p_balance_side_code
        ,p_je_source_name   => p_je_source_name);

   populate_user_trans_view;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of Upgrade_AP_Balances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN

     RAISE;

WHEN OTHERS THEN

    xla_exceptions_pkg.raise_message
         (p_location => 'xla_tb_balance_pkg.Upgrade_AP_Balances');

END Upgrade_AP_Balances;

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_tb_balance_pkg;

/
