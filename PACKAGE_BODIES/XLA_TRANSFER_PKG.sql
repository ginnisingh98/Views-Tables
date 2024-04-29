--------------------------------------------------------
--  DDL for Package Body XLA_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TRANSFER_PKG" AS
/* $Header: xlaaptrn.pkb 120.63.12010000.27 2012/08/13 07:05:55 sragadde ship $         */
/*==========================================================================+
|  Copyright (c) 2003 Oracle Corporation Belmont, California, USA           |
|                          ALL rights reserved.                             |
+===========================================================================+
|                                                                           |
| FILENAME                                                                  |
|                                                                           |
| xlaaptrn.pkb  Common Transfer TO GL API                                   |
|                                                                           |
|                                                                           |
| DESCRIPTION                                                               |
|   THE routine transfers subledger journal entries TO GL.                  |
|                                                                           |
|   THE journal Import request IS submitted FOR EACH PRIMARY AND secondary  |
|   ledgers. ALC ledgers are processed along WITH THE PRIMARY ledger.       |
|                                                                           |
|                                                                           |
| PUBLIC PROCEDURES                                                         |
|     xla_transfer_main                                                     |
|                                                                           |
| PRIVATE FUNCTIONS                                                         |
|                                                                           |
| PUBLIC FUNCTIONS                                                          |
|                                                                           |
| PRIVATE PROCEDURES                                                        |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|                                                                           |
|     21-Jul-2003  Shishir Joshi   Created.                                 |
|     18-Sep-2003  Shishir Joshi   Made changes for  document LEVEL transfer|
|     29-Sep-2003  Shishir Joshi   Added code TO hanlde GL Post security.   |
|     03-Oct-2003  Shishir Joshi   Populate reference11 WITH recon reference|
|                                  IN summary transfer.                     |
|     01-Dec-2003  Shishir Joshi   For encumbrnace entries entered amounts  |
|                                  would be same as accounted amounts. Also,|
|                                  encumbrance entries will always be in the|
|                                  currency of the ledger.                  |
|     02-Jan-2004  Shishir Joshi   Bug 3344168. Also includes trace changes |
|                                  - Modified the code to support 'Disable  |
|                                  Journal Import' profile option.          |
|     01-Mar-2005  Shishir Joshi   Inserting -1 value for set of books when |
|                                  inserting rows into the                  |
|                                  gl_interface_confrol table per Deborah's |
|                                  recommendation. JI is modified to        |
|                                  support intercompany functionality.      |
|     15-Apr-2005  Swapna Vellani  Added mutl-table Journal Import.         |
|     04-Aug-2005  Wynne Chan      Bug 4458381 - Public Sector Enhancements |
|     07-Oct-2005  Shishir Joshi   Trial Balance chnages. Bug 4630945       |
|     30-Nov-2005  Vinay Kumar     Bug4769315 Added filter on application_id|
|     13-Jan-2005  Vinay Kumar     Modified the logic to pick JE to transfer|
|                                  and signature of gl_transfer_main        |
|                                  Bug 4945075 Acoid creating n1_index and  |
|                                    n2_index on GL INTERFACE Table         |
|     03-Mar-2006  Vinay Kumar     Bug 5041325 Removed the procedure        |
|                                   update_gl_sl_link                       |
|     09-Mar-2006  S. Singhania    Bug 5056632.                             |
|                                    - Modified validate_input_parameters.  |
|                                    - Added paramter p_caller to           |
|                                      gl_tranfer_main                      |
|                                    - Modified select_journal_entries.     |
|                                    - Modified logic to get group_ids      |
|     02-Jun-2006 Vinay Kumar     Bug 5254655  Fix for Standalone Transfer  |
|                                      to GL                                |
|     22-Aug-2006 Ejaz Sayyed     Bug#5437400 - update gl_transfer_date in  |
|                                 set_transfer_status procedure and         |
|                                  in select_journal_entries procedure,     |
|                                 set trnsfr status code 'S'for combined mod|
|                                 and remove parameter p_ledger_id          |
|     22-Aug-2006 V. Swapna        Bug 5438564. Comment out the call to     |
|                                  validate_accounting_periods to handle    |
|                                  a performance issue.                     |
|     4-Sep-2008   rajose          bug#7320079 To pass the je_source_name   |
|                                  while spawning data manager. This helps  |
|                                  in finding the application from          |
|				   which the data manager has been spawned. |
|     12-Aug-2009  rajose          bug#8691650  Phase 2                     |
|     01-Sep-2010  VGOPISET        10047096 Perf changes in the UPDATE of   |
|                                  XLA_AE_HEADERS in Select_Journal_Entries |
|     26-NOV-2010  Narayanan M.S.  Bug#10124492 Headers with gl_transfer_sta|
|                                  tus_code as 'NT' will not be reset to 'N'|
|                                  or 'Y'                                   |
|                                  Bug#9839301 Modified procedure           |
|                                  get_ledger_options to use table          |
|                                  gl_access_set_assignments instead of     |
|                                  gl_access_sets to derive the access_set_id|
|    28-SEP-2011  Narayanan M.S.   Bug 12965313. Performance fix for GL.    |
|                                  Passing value 'TRUE' for the paramter    |
|                                  'create_n3_index' when creating temporary|
|                                  interface table.                         |
+===========================================================================*/
-- Constants

C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_transfer_pkg';

-- PLSQL Data Types

TYPE t_array_ids         IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;

TYPE r_ledger_rec IS RECORD
   (ledger_id             NUMBER
   ,NAME                  gl_ledgers.NAME%TYPE
   ,ledger_category_code  gl_ledgers.ledger_category_code%TYPE
   ,group_id              gl_interface.group_id%TYPE
   ,interface_run_id      gl_interface_control.interface_run_id%TYPE
   ,gllezl_request_id     NUMBER
   ,access_set_id         NUMBER
   );
TYPE t_array_ledgers IS TABLE OF r_ledger_rec INDEX BY BINARY_INTEGER;

--
-- Global Variables
--
--
-- Input Parameters
--
g_application_id         PLS_INTEGER;
g_program_id             PLS_INTEGER;
g_user_id                PLS_INTEGER;
g_request_id             PLS_INTEGER;
g_end_date               DATE;
g_batch_name             VARCHAR2(50);
g_accounting_batch_id    PLS_INTEGER;
g_entity_id              NUMBER; -- 8761772
g_process_category       xla_event_class_grps_b.event_class_group_code%TYPE;
g_security_id_int_1      xla_transaction_entities.source_id_int_1%TYPE;
g_security_id_int_2      xla_transaction_entities.source_id_int_2%TYPE;
g_security_id_int_3      xla_transaction_entities.source_id_int_3%TYPE;
g_security_id_char_1     xla_transaction_entities.source_id_char_1%TYPE;
g_security_id_char_2     xla_transaction_entities.source_id_char_2%TYPE;
g_security_id_char_3     xla_transaction_entities.source_id_char_3%TYPE;
g_valuation_method       xla_transaction_entities.valuation_method%TYPE;
g_caller                 VARCHAR2(80);


 -- Batch level global variables
 g_interface_run_id       PLS_INTEGER;
 g_je_source_name         gl_je_sources.user_je_source_name%TYPE;
 g_user_source_name       gl_je_sources.user_je_source_name%TYPE;
 g_import_key_flag        gl_je_sources.import_using_key_flag%TYPE;
 g_transfer_mode          VARCHAR2(30);
 g_primary_ledger_id      PLS_INTEGER;
 g_parent_group_id        PLS_INTEGER;
 g_transaction_security   VARCHAR2(4000);
 g_use_ledger_security    VARCHAR2(1)
      := nvl(fnd_profile.value('XLA_USE_LEDGER_SECURITY'), 'N');
 g_disable_gllezl_flag    VARCHAR2(1) := NVL(fnd_profile.value('XLA_DISABLE_GLLEZL'),'N');

 -- Ledger level global variables
 g_group_id               PLS_INTEGER;
 g_transfer_summary_mode  VARCHAR2(1);
 g_access_set_id          PLS_INTEGER := fnd_profile.value('GL_ACCESS_SET_ID');
 g_sec_access_set_id      PLS_INTEGER := fnd_profile.value('XLA_GL_SECONDARY_ACCESS_SET_ID');
 g_gl_interface_table_name VARCHAR2(30);
 g_budgetary_control_flag gl_ledgers.enable_budgetary_control_flag%TYPE;
 --
 -- Flow Control Flags
 --
 g_proceed                VARCHAR2(1) := 'Y';


 -- Ledger Arrarys
 g_primary_ledgers_tab    t_array_ledgers;   -- primary,secondary ledgers
 g_all_ledgers_tab        t_array_ledgers;   -- primary,secondary, ALC
 g_alc_ledger_id_tab      t_array_ids;       -- primary+ALC
 g_ledger_id_tab          t_array_ids;
 g_gllezl_requests_tab    t_array_ids;
 g_group_id_tab           t_array_ids;
 g_all_ledger_ids_tab     XLA_NUMBER_ARRAY_TYPE;

-- Global variables for debugging
g_log_level     PLS_INTEGER  :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_log_enabled   BOOLEAN :=  fnd_log.test
                               (log_level  => g_log_level
                               ,module     => C_DEFAULT_MODULE);


/*===================================================================
print DEBUG messages

=====================================================================*/
PROCEDURE trace (p_msg          IN VARCHAR2
                ,p_level        IN NUMBER
                ,p_module       IN VARCHAR2) IS
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
         (p_location   => 'xla_acct_setup_pub_pkg.trace');
END trace;

--=============================================================================
--                   ******* Print Log File **********
--=============================================================================
PROCEDURE print_logfile(p_msg  IN  VARCHAR2) IS
BEGIN

   fnd_file.put_line(fnd_file.log,p_msg);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_acct_setup_pub_pkg.print_logfile');
END print_logfile;


/*===========================================================================+
  PROCEDURE
     GET_GLLEZL_STATUS

  DESCRIPTION
   THE routine checkes status OF THE previously submitted journal import
   requests.

   THE FUNCTION returns FALSE IF it finds a failed JI request.

  SCOPE - PRIVATE

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED

  ARGUMENTS


  NOTES

 +===========================================================================*/

FUNCTION  get_gllezl_status
RETURN BOOLEAN IS
   l_callStatus    BOOLEAN;
   l_phase         VARCHAR2(30);
   l_status        VARCHAR2(30);
   l_dev_phase     VARCHAR2(30);
   l_dev_status    VARCHAR2(30);
   l_message       VARCHAR2(240);
   l_gllezl_status gl_interface.status%TYPE;
   l_index         PLS_INTEGER := 0;
   l_log_module  VARCHAR2(240);

   l_get_gllezl_status     BOOLEAN        := TRUE;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_gllezl_status';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('get_gllezl_status.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Journal import request count = ' || g_gllezl_requests_tab.COUNT,C_LEVEL_STATEMENT,l_Log_module);
   END IF;
   --
   -- Check if any previous requests failed
   --
   IF (g_gllezl_requests_tab.COUNT > 0) THEN
      l_index := g_gllezl_requests_tab.FIRST;
      FOR i IN 1..g_gllezl_requests_tab.COUNT
      LOOP

         trace('Calling fnd_concurrent.get_request_status',C_LEVEL_EVENT,l_Log_module);
        /*
         l_callStatus := fnd_concurrent.get_request_status
            (request_id    => g_gllezl_requests_tab(l_index)
            ,phase         => l_phase
            ,status        => l_status
            ,dev_phase     => l_dev_phase
            ,dev_status    => l_dev_status
            ,message       => l_message
            );
         */

        -- bug#8691650 used wait for request to avoid any -ve ledger_id issue in gl tables

        l_callStatus := fnd_concurrent.wait_for_request
            (request_id =>  g_gllezl_requests_tab(l_index)
            ,interval   => 5
            ,phase      => l_phase
            ,status     => l_status
            ,dev_phase  => l_dev_phase
            ,dev_status => l_dev_status
            ,message    => l_message);


         IF (
	       l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL'
	       AND l_dev_status <> 'WARNING' -- bug#8691650 dont raise exception if request is in warning
             )
	  THEN
            xla_accounting_err_pkg.build_message
               (p_appli_s_name => 'XLA'
               ,p_msg_name     => 'XLA_GLT_GLLEZL_FAILED'
               ,p_token_1      => 'REQUEST_ID'
               ,p_value_1      => g_gllezl_requests_tab(l_index)
              -- ,p_token_2      => 'LEDGER_NAME'
              -- ,p_value_2      => g_primary_ledgers_tab(i).name
               ,p_entity_id    => NULL
               ,p_event_id     => NULL
               );

	       l_get_gllezl_status := FALSE; -- bug#8691650 wait for the loop to complete
	     --RETURN FALSE;

          END IF;

         l_index := g_gllezl_requests_tab.NEXT(l_index);
      END LOOP;

      RETURN l_get_gllezl_status; --added bug#8691650

   ELSE

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('There are no journal import requets submitted at this time.',C_LEVEL_STATEMENT,l_Log_module);
      END IF;

   END IF;

   --RETURN TRUE;

   RETURN l_get_gllezl_status; --added bug#8691650

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.get_gllezl_status');
END get_gllezl_status;



/*===================================================================
| INSERT ROWS INTO THE GL_INTERFACE_CONTROL                          |
|                                                                    |
=====================================================================*/
PROCEDURE insert_interface_control(p_ledger_id NUMBER
                                   ,p_table_name VARCHAR2) IS

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_interface_control';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('insert_interface_control.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      print_logfile ('p_ledger_id = ' || p_ledger_id);
      print_logfile ('g_group_id  = ' || g_group_id);
      print_logfile ('g_budgetary_control_flag  = ' || g_budgetary_control_flag);

      trace('g_budgetary_control_flag:',C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   --8429053
   --Passing NULL for GL_INTERFACE table so data will not be
   --retained in GL_INTERFACE table with PROCESSED status

   INSERT INTO gl_interface_control
   (
    je_source_name,
    status,
    interface_run_id,
    group_id,
    set_of_books_id,
    packet_id,
    interface_table_name,
    processed_table_code
    )
   VALUES
   (
    g_je_source_name,
    'S',
    g_interface_run_id,
    g_group_id,
    -1,
    Decode(g_budgetary_control_flag, 'N', NULL, -3),
    p_table_name,
    'S' --8429053, 8691650 Commented
       --decode(g_gl_interface_table_name, 'GL_INTERFACE',NULL,'S') --8429053
   );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(SQL%ROWCOUNT|| ' rows inserted into the interface control table' ,C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('insert_interface_control.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      trace('Insert into the GL_INTERFACE_CONTROL failed',C_LEVEL_UNEXPECTED,l_Log_module);
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.get_gllezl_status');

END insert_interface_control;
/*===========================================================================+
  PROCEDURE
     CREATE_LOG_ENTRS

  DESCRIPTION
     THE PROCEDURE creates log ENTRY FOR EACH PRIMARY AND secondary ledger.


  SCOPE - PRIVATE

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED

  ARGUMENTS
     p_ledger_id  - PRIMARY/secondary ledger identifier.


  NOTES

 +===========================================================================*/

PROCEDURE insert_transfer_log ( p_ledger_id NUMBER) IS

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_transfer_log';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('insert_transfer_log.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Inserting a row into the transfer to GL log table.',C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   INSERT INTO xla_transfer_logs
     (
       application_id
      ,ledger_id
      ,parent_group_id
      ,group_id
      ,transfer_status_code
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,PROGRAM_UPDATE_DATE
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,REQUEST_ID
      )
   VALUES
    (
       g_application_id
      ,p_ledger_id
      ,g_parent_group_id
      ,g_group_id
      ,'INCOMPLETE'                            -- Incomplete
      ,SYSDATE
      ,g_user_id
      ,SYSDATE
      ,xla_environment_pkg.g_usr_id
      ,xla_environment_pkg.g_login_id
      ,SYSDATE
      ,xla_environment_pkg.g_prog_appl_id
      ,xla_environment_pkg.g_prog_id
      ,xla_environment_pkg.g_Req_Id
    );

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('insert_transfer_log.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;


EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.insert_transfer_log');
END insert_transfer_log;


/*===========================================================================+
  FUNCTION
     SUBMIT_JOURNAL_IMPORT

  DESCRIPTION
     THE PROCEDURE handles THE Journal Import submission.


  SCOPE - PRIVATE

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED

  ARGUMENTS


  NOTES

 +===========================================================================*/
FUNCTION  submit_journal_import (p_ledger_id         IN         NUMBER
                                ,p_interface_run_id  IN         NUMBER
                                ) RETURN NUMBER IS
   l_gllezl_request_id NUMBER;
   l_summary_flag      VARCHAR2(1);
   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.submit_journal_import';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('submit_journal_import.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_ledger_id        = ' || p_ledger_id,C_LEVEL_STATEMENT,l_Log_module);
      trace('p_interface_run_id = ' || p_interface_run_id,C_LEVEL_STATEMENT,l_Log_module);
   END IF;


    IF g_transfer_summary_mode IN ('A','P') THEN
      l_summary_flag := 'Y';
    ELSE
      l_summary_flag := 'N';
    END IF;

    l_gllezl_request_id:= fnd_request.submit_request
      (
      application => 'SQLGL',                 -- application short name
      program     => 'GLLEZL',                -- program short name
      description => NULL,                    -- program name
      start_time  => NULL,                    -- start date
      sub_request => FALSE,                   -- sub-request
      argument1   => p_interface_run_id,      -- interface run id
      argument2   => -602,                    -- set of books id
      argument3   => 'N',                     -- error to suspense flag
      argument4   => NULL,                    -- from accounting date
      argument5   => NULL,                    -- to accounting date
      argument6   => l_summary_flag,          -- create summary flag
      argument7   => 'N',                     -- import desc flex flag
      argument8   => 'Y'                      -- Data security mode flag
      );

   IF NVL(l_gllezl_request_id,0) = 0 THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace('Unable to submit the Journal Import',C_LEVEL_ERROR,l_Log_module);
      END IF;

      -- Add an error message.
      xla_accounting_err_pkg.build_message
         (p_appli_s_name => 'XLA'
         ,p_msg_name     => 'XLA_GLT_GLLEZL_SUBMIT_FAILED'
         ,p_token_1      => 'LEDGER_NAME'
         ,p_value_1      => g_all_ledgers_tab(p_ledger_id).NAME
         ,p_entity_id    => NULL
         ,p_event_id     => NULL
         );
   ELSE
      IF (g_log_enabled  AND C_LEVEL_EVENT >= g_log_level) THEN
         trace('The Journal Import has been submitted successfully. Request Id = ' || l_gllezl_request_id,C_LEVEL_EVENT,l_Log_module);
      END IF;

      --
      -- Journal Import is submitted successfully.
      --
      g_all_ledgers_tab(p_ledger_id).gllezl_request_id
                                         := l_gllezl_request_id;

      -- Populate GLLEZL request ID for ALC ledgers
      IF g_all_ledgers_tab(p_ledger_id).ledger_category_code = 'PRIMARY' THEN
            FOR i IN g_alc_ledger_id_tab.FIRST..g_alc_ledger_id_tab.LAST
            LOOP
               g_all_ledgers_tab(g_alc_ledger_id_tab(i)).gllezl_request_id := l_gllezl_request_id;
               trace('GLLEZL Request Id = ' || g_all_ledgers_tab(g_alc_ledger_id_tab(i)).gllezl_request_id,C_LEVEL_EVENT,l_Log_module);
            END LOOP;
      END IF;
      g_gllezl_requests_tab(p_ledger_id) := l_gllezl_request_id;

      UPDATE xla_transfer_logs
      SET    gllezl_request_id  = l_gllezl_request_id
      WHERE  group_id           = g_group_id;
   END IF;
   COMMIT;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('submit_journal_import.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   RETURN(l_gllezl_request_id);


EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.submit_journal_import');
END submit_journal_import;


/*====================================================================
 Get ledgers associated WITH THE PRIMARY ledger

=====================================================================*/
PROCEDURE get_ledgers (p_ledger_id  IN  NUMBER) IS

   CURSOR c_getledgers(p_ledger_id NUMBER
                      ,p_application_id NUMBER ) IS
      SELECT ledger_id
            ,NAME
            ,ledger_category_code
       FROM  xla_ledger_relationships_v xlr
      WHERE  xlr.primary_ledger_id         = p_ledger_id
        AND  xlr.relationship_enabled_flag = 'Y'
        AND  EXISTS (SELECT 1
                       FROM xla_ledger_options xlo
                      WHERE application_id = p_application_id
                        AND DECODE(xlr.ledger_category_code
                                   ,'ALC',xlr.ledger_id
                                   ,xlo.ledger_id) = xlr.ledger_id
                        AND DECODE(xlr.ledger_category_code
                                   ,'SECONDARY',xlo.capture_event_flag
                                   ,'N') = 'N'
                        AND DECODE(xlr.ledger_category_code
                                   ,'ALC','Y'
                                   ,xlo.enabled_flag) = 'Y')
      ORDER BY DECODE(xlr.ledger_category_code,
                     'PRIMARY',1,
                     'ALC',2
                     ,3);

l_ledger_name            gl_ledgers.NAME%TYPE;
l_count                  PLS_INTEGER := 0;
l_alc_count              PLS_INTEGER := 0;
l_log_module             VARCHAR2(240);
l_ledger_category_code   gl_ledgers.ledger_category_code%TYPE;


BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_ledgers';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('get_ledgers.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_ledger_id = ' ||p_ledger_id,C_LEVEL_STATEMENT,l_Log_module);
   END IF;


   SELECT NAME
         ,ledger_category_code
         ,enable_budgetary_control_flag
   INTO   l_ledger_name
         ,l_ledger_category_code
         ,g_budgetary_control_flag
   FROM   gl_ledgers led
   WHERE  led.ledger_id = p_ledger_id;


   --
   -- If the transfer is submitted for a primary ledger then derive
   -- all associated ledgers for processing.  If the transfer is submitted
   -- for a secondary ledger (For VM based products only) then process only
   -- the secondary ledger.
   --

   IF (l_ledger_category_code = 'PRIMARY') THEN
      g_primary_ledger_id := p_ledger_id;
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Deriving ledgers associated with the primary ledger',C_LEVEL_STATEMENT,l_Log_module);
      END IF;

      FOR ledger_rec IN c_getledgers(p_ledger_id,g_application_id)
      LOOP
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Ledger Rec Name = '||ledger_rec.NAME,C_LEVEL_STATEMENT,l_Log_module);
            trace('Ledger Rec id = '  ||ledger_rec.ledger_id,C_LEVEL_STATEMENT,l_Log_module);
         END IF;

         g_all_ledgers_tab(ledger_rec.ledger_id).ledger_id     := ledger_rec.ledger_id;
         g_all_ledgers_tab(ledger_rec.ledger_id).NAME          := ledger_rec.NAME;
         g_all_ledgers_tab(ledger_rec.ledger_id).ledger_category_code
                := ledger_rec.ledger_category_code;

         IF (ledger_rec.ledger_category_code IN ('PRIMARY','SECONDARY')) THEN
            l_count := l_count+1;
            g_primary_ledgers_tab(l_count).ledger_id     :=  ledger_rec.ledger_id;
            g_primary_ledgers_tab(l_count).NAME          :=  ledger_rec.NAME;
            g_primary_ledgers_tab(l_count).ledger_category_code
                                                         :=  ledger_rec.ledger_category_code;
         END IF;

         IF (ledger_rec.ledger_category_code IN ('ALC','PRIMARY')) THEN
            l_alc_count := l_alc_count+1;
            g_alc_ledger_id_tab(l_alc_count) := ledger_rec.ledger_id;
         END IF;
      END LOOP;
   ELSIF (l_ledger_category_code = 'SECONDARY') THEN
      l_count := l_count+1;
      g_primary_ledgers_tab(l_count).ledger_id := p_ledger_id;
      g_all_ledgers_tab(p_ledger_id).ledger_id := p_ledger_id;
      g_all_ledgers_tab(p_ledger_id).NAME      := l_ledger_name;
   ELSE
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace('Invalid ledger. A ledger must be either a primary or a secondary ledger',C_LEVEL_PROCEDURE,l_Log_module);
      END IF;

      -- Add error message
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('Total number of ledgers selected = '|| g_all_ledgers_tab.COUNT,C_LEVEL_PROCEDURE,l_Log_module);
      trace('get_ledgers.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_transfer_pkg.get_ledgers');
END get_ledgers;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    GET_LEDGER_OPTIONS                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Derive ledger LEVEL options                                              |
 |  are called FROM FROM this PROCEDURE.                                     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |     p_ledger_id  PRIMARY/Secondary ledger id                              |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_ledger_options(p_ledger_id IN NUMBER) IS
  l_access_set_id NUMBER;
  l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_ledger_options';
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      trace('get_ledger_options.Begin',C_LEVEL_PROCEDURE,l_Log_module);
      trace('p_ledger_id = ' || p_ledger_id,C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   BEGIN
      SELECT xlo.transfer_to_gl_mode_code
      INTO   g_transfer_summary_mode
      FROM   xla_ledger_options xlo
      WHERE  xlo.application_id = g_application_id
      AND    xlo.ledger_id      = p_ledger_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'The ledger setup is not complete. Please run Update Subledger Accounting Options program for your application '||
                                 'ledger_id = '||p_ledger_id||
                                 ' application_id = '|| g_application_id
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.get_ledger_options');
   END;

   -- Derive access set id based on the use ledger security option
   --
   IF (g_use_ledger_security = 'Y') THEN
      IF (g_access_set_id IS NOT NULL OR g_sec_access_set_id IS NOT NULL) THEN
         BEGIN
		 --Added for bug 9839301
            /*SELECT access_set_id
            INTO   l_access_set_id
            FROM   gl_access_sets aset, gl_ledgers led
            WHERE  aset.chart_of_accounts_id = led.chart_of_accounts_id
            AND    led.ledger_id             = p_ledger_id
            AND    aset.access_set_id IN (g_access_set_id, g_sec_access_set_id)
            AND    ROWNUM = 1;*/
            SELECT access_set_id
            INTO   l_access_set_id
            FROM   gl_access_set_assignments gasa
            WHERE  gasa.ledger_id = p_ledger_id
            AND    gasa.access_set_id IN (g_access_set_id, g_sec_access_set_id)
            AND    ROWNUM = 1;
        --Added for bug 9839301
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'Access set Id not found for the ledger ID = '
                                 ||p_ledger_id
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.get_ledger_options');
            trace('Access set Id not found.',C_LEVEL_STATEMENT,l_Log_module);

         END;
      END IF;
   ELSE
      SELECT implicit_access_set_id
      INTO   l_access_set_id
      FROM   gl_ledgers led
      WHERE  led.ledger_id = p_ledger_id;
   END IF;

   g_all_ledgers_tab(p_ledger_id).access_set_id := l_access_set_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('g_transfer_summary_mode = ' || g_transfer_summary_mode,C_LEVEL_STATEMENT,l_Log_module);
      trace('l_access_set_id         = ' || l_access_set_id,C_LEVEL_STATEMENT,l_Log_module);
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      trace('get_ledger_options.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
       trace('Error deriving subledger options for the ledger',C_LEVEL_UNEXPECTED,l_Log_module);
       xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.get_ledger_options');
END get_ledger_options;

/*====================================================================
 Populate ALC ledgers

*====================================================================*/

PROCEDURE get_alc_ledgers IS
   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_alc_ledgers';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('get_alc_ledgers.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   g_ledger_id_tab := g_alc_ledger_id_tab;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('get_alc_ledgers.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
       IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
          trace('Error assigning ALC ledgers',C_LEVEL_UNEXPECTED,l_Log_module);
       END IF;
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.get_alc_ledgers');
END get_alc_ledgers;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_transaction_security                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Dynamically build THE TRANSACTION security clause based ON               |
 |  input PARAMETERS                                                         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE set_transaction_security IS
   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.set_transaction_security';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('set_transaction_security.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;


   --
   -- Check if security has been specified
   --

   IF ( g_security_id_int_1  IS NOT  NULL OR
        g_security_id_int_2  IS NOT  NULL OR
        g_security_id_int_3  IS NOT  NULL OR
        g_security_id_char_1 IS NOT  NULL OR
        g_security_id_char_2 IS NOT  NULL OR
        g_security_id_char_3 IS NOT  NULL OR
        g_valuation_method   IS NOT  NULL) THEN

      -- Security info has been provided.
      g_transaction_security := NULL;
       -- commented bug 14307411
      /*IF (g_security_id_int_1  IS NOT  NULL) THEN
         g_transaction_security := ' AND xte.security_id_int_1 = ' || g_security_id_int_1;
      END IF;*/

     --added bug  14307411
     IF (g_security_id_int_1  IS NOT  NULL) THEN
          select DECODE(g_application_id,707, ' AND NVL(xte.security_id_int_1,'|| g_security_id_int_1||') = ' ||g_security_id_int_1,
                                                                  ' AND xte.security_id_int_1 = '|| g_security_id_int_1)
                                                                  into   g_transaction_security from dual ;

      END IF;
      -- end  bug  14307411
      IF (g_security_id_int_2  IS NOT  NULL) THEN
         g_transaction_security :=  g_transaction_security ||' AND xte.security_id_int_2 = '  || g_security_id_int_2;
      END IF;
      IF (g_security_id_int_3  IS NOT  NULL) THEN
         g_transaction_security :=  g_transaction_security ||' AND xte.security_id_int_3 = '  || g_security_id_int_3;
      END IF;
      IF (g_security_id_char_1  IS NOT  NULL) THEN
         g_transaction_security :=  g_transaction_security ||' AND xte.security_id_char_1 = ''' || g_security_id_char_1 || '''';
      END IF;
      IF (g_security_id_char_2  IS NOT  NULL) THEN
         g_transaction_security :=  g_transaction_security ||' AND xte.security_id_char_2 = ''' || g_security_id_char_2 || '''';
      END IF;
      IF (g_security_id_char_3  IS NOT  NULL) THEN
         g_transaction_security :=  g_transaction_security ||' AND xte.security_id_char_3 = ''' || g_security_id_char_3 || '''';
      END IF;
      IF (g_valuation_method  IS NOT  NULL) THEN
         g_transaction_security :=  g_transaction_security ||' AND xte.valuation_method =  '''  || g_valuation_method || '''';
      END IF;
   END IF;

   --trace('g_transaction_security = ' || g_transaction_security,C_LEVEL_STATEMENT,l_Log_module);
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('set_transaction_security.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;


END set_transaction_security;


/*====================================================================
* VALIDATE input PARAMETERS

*====================================================================*/
PROCEDURE validate_input_parameters IS
   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_input_parameters';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('validate_input_parameters.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;


   -- Validate input parameters

   CASE
   WHEN g_transfer_mode NOT IN ('STANDALONE','COMBINED')
   THEN
        trace('Invalid transfer mode. The transfer mode must be either Standalone or Combined.'
             ,C_LEVEL_ERROR,l_Log_module);

        xla_exceptions_pkg.raise_message
           (p_appli_s_name   => 'XLA'
           ,p_msg_name       => 'XLA_COMMON_ERROR'
           ,p_token_1        => 'LOCATION'
           ,p_value_1        => 'xla_transfer_pkg.validate_input_parameters'
           ,p_token_2        => 'ERROR'
           ,p_value_2        => 'Transfer mode must be either Standalone or Combined');

   WHEN g_caller IN (C_TP_MERGE,C_MPA_COMPLETE)
   AND g_accounting_batch_id IS NULL
   THEN
      trace('Accounting batch identifier must be specified.'
              ,C_LEVEL_ERROR
              ,l_log_module);

      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_transfer_pkg.validate_input_parameters'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'Accounting batch identifier must be specified.');

   WHEN g_caller IN (C_ACCTPROG_DOCUMENT)
   AND g_entity_id IS NULL
   THEN
      trace('Entity Identifier must be specified.'
              ,C_LEVEL_ERROR
              ,l_log_module);

      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_transfer_pkg.validate_input_parameters'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'Entity identifier must be specified.');

   WHEN g_transfer_mode = 'STANDALONE'
   AND g_caller IN (C_ACCTPROG_BATCH)
   AND g_end_date IS  NULL
   THEN
      trace('An end date must be specified for batch accounting in standalone mode'
           ,C_LEVEL_ERROR,l_Log_module);

      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_transfer_pkg.validate_input_parameters'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'End date must be specified for batch accounting in Standalone mode');

   ELSE
      NULL;
   END CASE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('validate_input_parameters.End',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.validate_input_parameters');
END validate_input_parameters;


/*===========================================================================+
  PROCEDURE
     RECOVER_BATCH

  DESCRIPTION
     Performs RECOVERY opration FOR THE previously failed transfer batches.


  SCOPE - PRIVATE

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED

  ARGUMENTS


  NOTES

 +===========================================================================*/
PROCEDURE recover_batch IS
   l_log_module  VARCHAR2(240);
   l_first_time_recover BOOLEAN := FALSE;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Recover_Batch';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('recover_batch.Begin',C_LEVEL_PROCEDURE,l_Log_module);
   END IF;

   -- Check if there are any previously failed batches. Ignore request that
   -- are either runnning, pending or inactive.
   -- Phase Code: R - Running, P - Pending, I - Inactive

   IF ( g_group_id_tab.COUNT <= 0) THEN
      SELECT group_id
            ,gllezl_request_id
      BULK COLLECT INTO
            g_group_id_tab
           ,g_gllezl_requests_tab
      FROM   xla_transfer_logs xtb1
      WHERE  application_id = g_application_id
        AND  request_id NOT IN
            ( SELECT xtb.request_id
                        FROM   xla_transfer_logs       xtb
                              ,fnd_concurrent_requests fcr
                        WHERE  xtb.application_id       = g_application_id
                        AND    xtb.transfer_status_code = 'INCOMPLETE'
                       --AND    xtb.gllezl_request_id IS NOT NULL
                        AND    xtb.request_id           = fcr.request_id
                        AND    fcr.phase_code IN ('R','P','I'));

     /*bug#8691650 The l_first_time_recover flag indicates that there are group id's to be recovered */
     IF g_group_id_tab.COUNT > 0 THEN
        l_first_time_recover := TRUE;
     END IF;

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Found '|| g_group_id_tab.COUNT || ' batches to recover', C_LEVEL_STATEMENT,l_log_module);
   END IF;

   IF (g_group_id_tab.COUNT > 0) THEN
      --
      -- Reset journal entry headers
      --
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Updating XLA_AE_HEADERS',C_LEVEL_STATEMENT,l_log_module);
     END IF;
      FORALL i IN g_group_id_tab.FIRST..g_group_id_tab.LAST
        UPDATE xla_ae_headers
        SET    group_id                = NULL
              ,gl_transfer_status_code = 'N'
              ,gl_transfer_date        = NULL
              ,program_update_date     = SYSDATE
              ,program_id              = g_program_id
              ,request_id              = g_request_id
        WHERE  group_id = g_group_id_tab(i)
		--Added for 10124492
		AND gl_transfer_status_code <> 'NT';
		--Added for 10124492

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace(SQL%ROWCOUNT || ' Headers updated.',C_LEVEL_STATEMENT,l_log_module);
        --
        -- Delete log entries
        --
        trace('Deleting rows from xla_transfer_logs ',C_LEVEL_STATEMENT,l_log_module);
     END IF;
      FORALL i IN g_group_id_tab.FIRST..g_group_id_tab.LAST
        DELETE xla_transfer_logs
        WHERE  group_id = g_group_id_tab(i);

      --
      -- Delete XLA_TRANSFER_LEDGERS
      --

      trace('Deleting rows from XLA_TRANSFER_LEDGERS',C_LEVEL_STATEMENT,l_log_module);
      FORALL i IN g_group_id_tab.FIRST..g_group_id_tab.LAST
         DELETE xla_transfer_ledgers
         WHERE  group_id = g_group_id_tab(i);

      IF SQL%NOTFOUND THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('No rows found in the XLA_TRANSFER_LEDGERS table.',C_LEVEL_STATEMENT,l_log_module);
         END IF;
      ELSE
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace(SQL%ROWCOUNT || 'Rows deleted from the XLA_TRANSFER_LEDGERS',C_LEVEL_STATEMENT,l_log_module);
         END IF;
      END IF;




      --
      -- Delete rows from gl_interface, GL journals
      --

      /* bug#8691650 use the g_group_id_tab to delete batches which needs to be recovered */
      IF l_first_time_recover THEN
         FOR i IN g_group_id_tab.FIRST .. g_group_id_tab.LAST
         LOOP

            IF (C_LEVEL_EVENT >= g_log_level) THEN
              trace('First time recover calling gl_journal_import_sla_pkg.delete_batches',C_LEVEL_EVENT,l_log_module);
            END IF;

             gl_journal_import_sla_pkg.delete_batches
                (x_je_source_name => g_je_source_name
                ,x_group_id       => g_group_id_tab(i)
                );

         END LOOP;

      END IF;

      FOR i IN g_primary_ledgers_tab.FIRST..g_primary_ledgers_tab.LAST
      LOOP
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Looping for each group identifier ' ,C_LEVEL_STATEMENT,l_log_module);
         END IF;
         IF (g_primary_ledgers_tab(i).gllezl_request_id IS NOT NULL) THEN
           IF (C_LEVEL_EVENT >= g_log_level) THEN
              trace('Calling gl_journal_import_sla_pkg.delete_batches',C_LEVEL_EVENT,l_log_module);
           END IF;
             gl_journal_import_sla_pkg.delete_batches
                (x_je_source_name => g_je_source_name
                ,x_group_id       => g_primary_ledgers_tab(i).group_id
                );
         END IF;
      END LOOP;

     COMMIT;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('recover_batch.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
      trace('Batch Recovery failed',C_LEVEL_UNEXPECTED,l_log_module);
   END IF;
      RAISE;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_transfer_pkg.recover_batch');
END recover_batch;

/*====================================================================
*  Perform period VALIDATION IF GL IS Installed AND THE transfer IS  *
*  submitted IN stanalone MODE.                                      *
*====================================================================*/

PROCEDURE validate_accounting_periods ( p_ledger_id IN NUMBER) IS
   TYPE t_period_name    IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
   TYPE t_period_year    IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;

   l_period_name_tab         t_period_name;
   l_period_year_tab         t_period_year;
   l_ledger_ids_tab          t_array_ids;
   l_budget_version_id_tab   t_array_ids;
   l_budget_name_tab         t_period_name;
   l_period_val_failed       BOOLEAN := FALSE;
   l_index                   PLS_INTEGER;
   l_actual_flag             xla_event_class_attrs.ALLOW_ACTUALS_FLAG%TYPE;
   l_budget_flag             xla_event_class_attrs.ALLOW_BUDGETS_FLAG%TYPE;
   l_encum_flag              xla_event_class_attrs.ALLOW_ENCUMBRANCE_FLAG%TYPE;
   l_statement               VARCHAR2(4000);
   l_log_module              VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_accounting_periods';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('validate_accounting_periods.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Number of ledgers selected for a period validation = ' ||g_all_ledgers_tab.count,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   -- Populate a SQL variable to be used for casting.
   g_all_ledger_ids_tab := XLA_NUMBER_ARRAY_TYPE();

   l_index := g_all_ledgers_tab.FIRST;
   FOR i IN 1..g_all_ledgers_tab.COUNT
   LOOP
      --trace('Ledger Id = ' || g_all_ledgers_tab(l_index).ledger_id,C_LEVEL_STATEMENT,l_log_module);
      g_all_ledger_ids_tab.EXTEND;
      g_all_ledger_ids_tab(i) := g_all_ledgers_tab(l_index).ledger_id;
      l_index := g_all_ledgers_tab.NEXT(l_index);
   END LOOP;

   -- Get balance types allowed for an application.

   SELECT actual_flag,budget_flag,encumbrance_flag
   INTO   l_actual_flag, l_budget_flag, l_encum_flag
   FROM (SELECT MAX(DECODE(NVL(ALLOW_ACTUALS_FLAG,'N'),'Y','Y','Z')) actual_flag
               ,MAX(DECODE(NVL(ALLOW_BUDGETS_FLAG,'N'),'Y','Y','Z')) budget_flag
               ,MAX(DECODE(NVL(ALLOW_encumbrance_FLAG,'N'),'Y','Y','Z')) encumbrance_flag
         FROM   xla_event_class_attrs
         WHERE  application_id     = g_application_id
         GROUP BY allow_actuals_flag, allow_budgets_flag, allow_encumbrance_flag
         ORDER BY actual_flag,budget_flag,encumbrance_flag)
   WHERE ROWNUM = 1;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('l_actual_flag = ' || l_actual_flag,C_LEVEL_STATEMENT,l_log_module);
      trace('l_budget_flag = ' || l_budget_flag,C_LEVEL_STATEMENT,l_log_module);
      trace('l_encum_flag  = ' || l_encum_flag,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   -- Check for closed periods
   IF (g_entity_id IS NOT NULL) THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Performing period validations for the document level transfer.',C_LEVEL_STATEMENT,l_log_module);
      END IF;
      IF (l_actual_flag = 'Y') THEN

      l_statement :=
         'SELECT DISTINCT aeh.period_name
                        ,aeh.ledger_id
         FROM   xla_ae_headers aeh
               ,gl_period_statuses gps
               ,TABLE (CAST(:1 AS XLA_NUMBER_ARRAY_TYPE))led
         WHERE  aeh.application_id                  = :2                --g_application_id
         AND    aeh.ledger_id                       = led.column_value
         AND    aeh.entity_id                       = :3                --g_entity_id
         AND    aeh.gl_transfer_status_code         = ''N''
         AND    aeh.accounting_entry_status_code    = ''F''
         AND    aeh.balance_type_code               = ''A''
         AND    gps.application_id                  = 101
         AND    gps.ledger_id                       = aeh.ledger_id
         AND    gps.period_name                     = aeh.period_name
         AND    NVL(gps.adjustment_period_flag,''N'') = ''N''
         AND    gps.closing_status IN (''C'',''N'',''P'')';

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace('l_statement := ' || l_statement,C_LEVEL_STATEMENT,l_log_module);
     END IF;
     EXECUTE IMMEDIATE l_statement
     BULK COLLECT INTO
           l_period_name_tab
          ,l_ledger_ids_tab
     USING g_all_ledger_ids_tab
          ,g_application_id
          ,g_entity_id;

     IF SQL%FOUND THEN
        IF (C_LEVEL_ERROR >= g_log_level) THEN
           trace('There are journal entries in a closed period.',C_LEVEL_ERROR,l_log_module);
        END IF;
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace('Number of closed periods = ' || l_period_name_tab.COUNT,C_LEVEL_STATEMENT,l_log_module);
        END IF;

        l_period_val_failed := TRUE;
        FOR j IN l_period_name_tab.FIRST..l_period_name_tab.LAST
        LOOP
           xla_accounting_err_pkg.build_message
                 (p_appli_s_name => 'XLA'
                 ,p_msg_name     => 'XLA_GLT_PERIOD_CLOSED'
                 ,p_token_1      => 'PERIOD_NAME'
                 ,p_value_1      => l_period_name_tab(j)
                 ,p_token_2      => 'LEDGER_NAME'
                 ,p_value_2      => g_all_ledgers_tab(l_ledger_ids_tab(j)).NAME
                 ,p_entity_id    => NULL
                 ,p_event_id     => NULL
                 );
           -- Display error message when there are unposted
           -- records in given period and the period is closed.
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace('The period ' ||l_period_name_tab(j) || ' is closed for the ledger '
                  || g_all_ledgers_tab(l_ledger_ids_tab(j)).NAME ,C_LEVEL_STATEMENT,l_log_module);
           END IF;
        END LOOP;
     END IF;
     END IF;
     -- Perform period validations for budget entries
     --
     IF (l_budget_flag = 'Y') THEN
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('Performing budget period validations for a document level transfer.',C_LEVEL_STATEMENT,l_log_module);
       END IF;
       l_statement := '
         SELECT DISTINCT gps.period_year
                       ,gbv.budget_name
         FROM    xla_ae_headers           aeh
               ,gl_period_statuses       gps
               ,gl_budget_period_ranges  gbp
               ,gl_budget_versions       gbv
               ,TABLE (CAST(:1 AS XLA_NUMBER_ARRAY_TYPE))led
         WHERE aeh.application_id      = :2
         AND   aeh.ledger_id           = led.column_value
         AND   aeh.balance_type_code   = ''B''
         AND   aeh.entity_id           = :3 --g_entity_id
         AND   aeh.gl_transfer_status_code         = ''N''
         AND   aeh.accounting_entry_status_code    = ''F''
         AND   gps.application_id                  = 101
         AND   gps.ledger_id                       = aeh.ledger_id
         AND   gps.period_name                     = aeh.period_name
         AND   NVL(gps.adjustment_period_flag,''N'') = ''N''
         AND   gps.period_year                     = gbp.period_year
         AND   aeh.budget_version_id               = gbp.budget_version_id
         AND   gbp.open_flag                       <> ''O''
         AND   gbv.budget_version_id               = aeh.budget_version_id ';

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('l_statement := ' || l_statement,C_LEVEL_STATEMENT,l_log_module);
         END IF;
         EXECUTE IMMEDIATE l_statement
         BULK COLLECT INTO
              l_period_year_tab
             ,l_budget_name_tab
         USING g_all_ledger_ids_tab
             ,g_application_id
             ,g_entity_id;

         IF SQL%FOUND THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace('Number of closed budget versions = ' || l_period_year_tab.COUNT,C_LEVEL_STATEMENT,l_log_module);
            END IF;
            l_period_val_failed := TRUE;
            FOR j IN l_budget_name_tab.FIRST..l_budget_name_tab.LAST
            LOOP
            xla_accounting_err_pkg.build_message
                 (p_appli_s_name => 'XLA'
                 ,p_msg_name     => 'XLA_GLT_BUDGET_YEAR_CLOSED'
                 ,p_token_1      => 'YEAR'
                 ,p_value_1      => l_period_year_tab(j)
                 ,p_entity_id    => NULL
                 ,p_event_id     => NULL
                 );
               -- Display error message when there are unposted
               -- records in given period and the period is closed.
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace('The budget ' ||l_budget_name_tab(j) || ' is in a closed year. ' || l_period_year_tab(j),C_LEVEL_ERROR,l_log_module);
               END IF;
           END LOOP;
        END IF;
     END IF; -- l_budget_flag = 'Y'
     IF (l_encum_flag = 'Y') THEN
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('Performing encumbrance period validations for a document level transfer.',C_LEVEL_STATEMENT,l_log_module);
       END IF;
        l_statement :=
           ' SELECT DISTINCT aeh.ledger_id
                   ,gll.latest_encumbrance_year
           FROM    xla_ae_headers        aeh
                  ,gl_period_statuses         gps
                  ,gl_ledgers                 gll
                  ,TABLE (CAST(:1 AS XLA_NUMBER_ARRAY_TYPE))led
            WHERE aeh.application_id      = :2                  --g_application_id
            AND   aeh.entity_id           = :3                  --g_entity_id
            AND   aeh.ledger_id           = led.column_value
            AND   aeh.balance_type_code   = ''E''
            AND   aeh.ledger_id           = gll.ledger_id
            AND   aeh.gl_transfer_status_code         = ''N''
            AND   aeh.accounting_entry_status_code    = ''F''
            AND   gps.application_id                  = 101
            AND   gps.ledger_id                       = aeh.ledger_id
            AND   gps.period_name                     = aeh.period_name
            AND   gps.period_year                     > gll.latest_encumbrance_year ';

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('l_statement = ' || l_statement,C_LEVEL_STATEMENT,l_log_module);
         END IF;
         EXECUTE IMMEDIATE l_statement
         BULK COLLECT INTO
               l_ledger_ids_tab
              ,l_period_year_tab
         USING g_all_ledger_ids_tab
              ,g_application_id
              ,g_entity_id;

         IF SQL%FOUND THEN
            l_period_val_failed := TRUE;
            FOR j IN l_ledger_ids_tab.FIRST..l_ledger_ids_tab.LAST
            LOOP
               xla_accounting_err_pkg.build_message
                 (p_appli_s_name => 'XLA'
                 ,p_msg_name     => 'XLA_GLT_ENCUM_YEAR_CLOSED'
                 ,p_token_1      => 'LEDGER_NAME'
                 ,p_value_1      =>  g_all_ledgers_tab(l_ledger_ids_tab(j)).NAME
                 ,p_token_2      => 'YEAR'
                 ,p_value_2      => l_period_year_tab(j)
                 ,p_entity_id    => NULL
                 ,p_event_id     => NULL
                 );
               -- Display an error message when there are unposted
               -- records the closed period.
               IF (C_LEVEL_ERROR >= g_log_level) THEN
                   trace('The last open encumbrance year for the ledger ' ||g_all_ledgers_tab(l_ledger_ids_tab(j)).NAME  || ' is ' || l_period_year_tab(j),C_LEVEL_ERROR,l_log_module);
               END IF;
            END LOOP;
         END IF;
      END IF;
  ELSIF ( g_end_date IS NOT NULL ) THEN
     IF (l_actual_flag = 'Y') THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace('Performing period validations for the batch level transfer.',C_LEVEL_STATEMENT,l_log_module);
     END IF;
     l_statement :=
        'SELECT DISTINCT aeh.period_name
                        ,aeh.ledger_id
        FROM    xla_ae_headers             aeh
               ,gl_period_statuses         gps
               ,xla_transaction_entities   xte
               ,xla_event_types_b          xet
               ,xla_event_class_attrs      xec
               ,xla_ledger_relationships_v xlr
               ,TABLE (CAST(:1 AS XLA_NUMBER_ARRAY_TYPE))led
         WHERE xte.entity_id           = aeh.entity_id
         AND   aeh.application_id      = :2 --g_application_id
         AND   aeh.ledger_id           = led.column_value
         AND   aeh.accounting_date    <= :3 --g_end_date
         AND   aeh.balance_type_code   = ''A''
         AND   aeh.ledger_id           = xlr.ledger_id
         AND   xte.entity_code         = xec.entity_code
         AND   xte.application_id      = xec.application_id
         AND   xec.application_id      = xet.application_id
         AND   xec.entity_code         = xet.entity_code
         AND   xec.event_class_code    = xet.event_class_code
         AND   xec.event_class_group_code
                                       = NVL(:4,xec.event_class_group_code)
         AND   xet.event_type_code     = aeh.event_type_code
         AND   xet.application_id      = aeh.application_id
         AND   xet.entity_code         = xte.entity_code
         AND   aeh.gl_transfer_status_code         = ''N''
         AND   aeh.accounting_entry_status_code    = ''F''
         AND   gps.application_id                  = 101
         AND   gps.ledger_id                       = aeh.ledger_id
         AND   gps.period_name                     = aeh.period_name
         AND   NVL(gps.adjustment_period_flag,''N'') = ''N''
         AND   gps.closing_status IN (''C'',''N'',''P'')'
         || g_transaction_security;

     --trace('l_statement := ' || l_statement,C_LEVEL_STATEMENT,l_log_module);
     EXECUTE IMMEDIATE l_statement
     BULK COLLECT INTO
           l_period_name_tab
          ,l_ledger_ids_tab
     USING g_all_ledger_ids_tab
          ,g_application_id
          ,g_end_date
          ,g_process_category;

        IF SQL%FOUND THEN
           IF (C_LEVEL_ERROR >= g_log_level) THEN
              trace('There are journal entries in a closed period.',C_LEVEL_ERROR,l_log_module);
           END IF;
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace('Number of periods closed  = ' || l_period_name_tab.COUNT,C_LEVEL_STATEMENT,l_log_module);
           END IF;
           l_period_val_failed := TRUE;
           FOR j IN l_period_name_tab.FIRST..l_period_name_tab.LAST
           LOOP
              xla_accounting_err_pkg.build_message
                    (p_appli_s_name => 'XLA'
                    ,p_msg_name     => 'XLA_GLT_PERIOD_CLOSED'
                    ,p_token_1      => 'PERIOD_NAME'
                    ,p_value_1      => l_period_name_tab(j)
                    ,p_token_2      => 'LEDGER_NAME'
                    ,p_value_2      => g_all_ledgers_tab(l_ledger_ids_tab(j)).NAME
                    ,p_entity_id    => NULL
                    ,p_event_id     => NULL
                    );
              -- Display error message when there are unposted
              -- records in given period and the period is closed.
              IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                 trace('The period ' ||l_period_name_tab(j) || ' is closed for the ledger '
                     || g_all_ledgers_tab(l_ledger_ids_tab(j)).NAME ,C_LEVEL_STATEMENT,l_log_module);
              END IF;
           END LOOP;
        END IF;
     END IF;
     -- Perform period validations for budget entries
     --
     IF (l_budget_flag = 'Y') THEN
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('Performing budget period validations for a batch level transfer.',C_LEVEL_STATEMENT,l_log_module);
       END IF;
       l_statement := '
        SELECT DISTINCT gps.period_year
                       ,gbv.budget_name
        FROM    xla_ae_headers           aeh
               ,xla_transaction_entities xte
               ,xla_event_types_b        xet
               ,xla_event_class_attrs    xec
               ,gl_period_statuses       gps
               ,gl_budget_period_ranges  gbp
               ,gl_budget_versions       gbv
               ,TABLE (CAST(:1 AS XLA_NUMBER_ARRAY_TYPE))led
         WHERE xte.entity_id           = aeh.entity_id
         AND   aeh.application_id      = :2
         AND   aeh.ledger_id           = led.column_value
         AND   aeh.accounting_date    <= :3 --g_end_date
         AND   aeh.balance_type_code   = ''B''
         AND   xte.entity_code         = xec.entity_code
         AND   xte.application_id      = xec.application_id
         AND   xec.application_id      = xet.application_id
         AND   xec.entity_code         = xet.entity_code
         AND   xec.event_class_code    = xet.event_class_code
         AND   xec.event_class_group_code
                                       = NVL(:4,xec.event_class_group_code)
         AND   xet.event_type_code     = aeh.event_type_code
         AND   xet.application_id      = aeh.application_id
         AND   xet.entity_code         = xte.entity_code
         AND   aeh.gl_transfer_status_code         = ''N''
         AND   aeh.accounting_entry_status_code    = ''F''
         AND   gps.application_id                  = 101
         AND   gps.ledger_id                       = aeh.ledger_id
         AND   gps.period_name                     = aeh.period_name
         AND   NVL(gps.adjustment_period_flag,''N'') = ''N''
         AND   gps.period_year                     = gbp.period_year
         AND   aeh.budget_version_id               = gbp.budget_version_id
         AND   gbp.open_flag                       <> ''O''
         AND   gbv.budget_version_id               = aeh.budget_version_id '
         || g_transaction_security;

         --trace('l_statement := ' || l_statement,C_LEVEL_STATEMENT,l_log_module);
         EXECUTE IMMEDIATE l_statement
         BULK COLLECT INTO
              l_period_year_tab
             ,l_budget_name_tab
         USING g_all_ledger_ids_tab
             ,g_application_id
             ,g_end_date
             ,g_process_category;

         IF SQL%FOUND THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace('Number of closed budget versions = ' || l_period_year_tab.COUNT,C_LEVEL_STATEMENT,l_log_module);
            END IF;
            l_period_val_failed := TRUE;
            FOR j IN l_budget_name_tab.FIRST..l_budget_name_tab.LAST
            LOOP
            xla_accounting_err_pkg.build_message
                 (p_appli_s_name => 'XLA'
                 ,p_msg_name     => 'XLA_GLT_BUDGET_YEAR_CLOSED'
                 ,p_token_1      => 'YEAR'
                 ,p_value_1      => l_period_year_tab(j)
                 ,p_entity_id    => NULL
                 ,p_event_id     => NULL
                 );
               -- Display error message when there are unposted
               -- records in given period and the period is closed.
               IF (C_LEVEL_ERROR >= g_log_level) THEN
                  trace('The budget ' ||l_budget_name_tab(j) || ' is in a closed year. ' || l_period_year_tab(j),C_LEVEL_ERROR,l_log_module);
               END IF;
           END LOOP;
        END IF;
     END IF;

     IF (l_encum_flag = 'Y') THEN
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('Performing encumbrance period validations for a batch level transfer.',C_LEVEL_STATEMENT,l_log_module);
       END IF;
        l_statement :=
           ' SELECT DISTINCT aeh.ledger_id
                          ,gll.latest_encumbrance_year
           FROM    xla_ae_headers        aeh
                  ,gl_period_statuses         gps
                  ,xla_transaction_entities   xte
                  ,xla_event_types_b          xet
                  ,xla_event_class_attrs      xec
                  ,gl_ledgers                 gll
                  ,TABLE (CAST(:1 AS XLA_NUMBER_ARRAY_TYPE))led
            WHERE xte.entity_id           = aeh.entity_id
            AND   aeh.application_id      = :2 --g_application_id
            AND   aeh.ledger_id           = led.column_value
            AND   aeh.accounting_date    <= :3 --g_end_date
            AND   aeh.balance_type_code   = ''E''
            AND   aeh.ledger_id           = gll.ledger_id
            AND   xte.entity_code         = xec.entity_code
            AND   xte.application_id      = xec.application_id
            AND   xec.application_id      = xet.application_id
            AND   xec.entity_code         = xet.entity_code
            AND   xec.event_class_code    = xet.event_class_code
            AND   xec.event_class_group_code = NVL(:4,xec.event_class_group_code)
            AND   xet.event_type_code     = aeh.event_type_code
            AND   xet.application_id      = aeh.application_id
            AND   xet.entity_code         = xte.entity_code
            AND   aeh.gl_transfer_status_code         = ''N''
            AND   aeh.accounting_entry_status_code    = ''F''
            AND   gps.application_id                  = 101
            AND   gps.ledger_id                       = aeh.ledger_id
            AND   gps.period_name                     = aeh.period_name
            AND   gps.period_year                     > gll.latest_encumbrance_year '
            || g_transaction_security;

         EXECUTE IMMEDIATE l_statement
         BULK COLLECT INTO
               l_ledger_ids_tab
              ,l_period_year_tab
         USING g_all_ledger_ids_tab
              ,g_application_id
              ,g_end_date
              ,g_process_category;

         IF SQL%FOUND THEN
            l_period_val_failed := TRUE;
            FOR j IN l_ledger_ids_tab.FIRST..l_ledger_ids_tab.LAST
            LOOP
               xla_accounting_err_pkg.build_message
                 (p_appli_s_name => 'XLA'
                 ,p_msg_name     => 'XLA_GLT_ENCUM_YEAR_CLOSED'
                 ,p_token_1      => 'YEAR'
                 ,p_value_1      => l_period_year_tab(j)
                 ,p_token_2      => 'LEDGER_NAME'
                 ,p_value_2      =>  g_all_ledgers_tab(l_ledger_ids_tab(j)).NAME
                 ,p_entity_id    => NULL
                 ,p_event_id     => NULL
                 );
               -- Display an error message when there are unposted
               -- records the closed period.
               IF (C_LEVEL_ERROR >= g_log_level) THEN
                  trace('The last open encumbrance year for the ledger ' ||g_all_ledgers_tab(l_ledger_ids_tab(j)).NAME  || ' is ' || l_period_year_tab(j),C_LEVEL_ERROR,l_log_module);
               END IF;
            END LOOP;
         END IF;
      END IF;
   END IF;

   IF (l_period_val_failed) THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace('Transfer to GL period validation has failed.',C_LEVEL_ERROR,l_log_module);
      END IF;
      xla_exceptions_pkg.raise_exception;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('validate_accounting_periods.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_trasnfer_pkg.validate_accounting_periods');
END validate_accounting_periods;


/*====================================================================
  THE PROCEDURE selects AND marks THE journal entries
*====================================================================*/
-- removed parameter p_ledger_id
PROCEDURE select_journal_entries IS
    l_statement   VARCHAR2(4000);
    l_log_module  VARCHAR2(240);
    l_je_count    NUMBER;
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.select_journal_entries';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('select_journal_entries.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Number of ledgers selected = ' || g_ledger_id_tab.COUNT,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   -- Select accounting headers for the transfer

   IF (g_transfer_mode = 'COMBINED') THEN
      CASE g_caller
          WHEN C_ACCTPROG_BATCH THEN
            -- Bug 5056632.
            -- group_id, gl_transfer_date and gl_transfer_status_code
            -- is pre populated in the accounting program. get the count.
            -- Bug 5437400 - update transfer status and transfer date in
            -- combined mode.
         FORALL i IN g_ledger_id_tab.FIRST..g_ledger_id_tab.LAST
            UPDATE /*+ index(xah, XLA_AE_HEADERS_N1) */
               xla_ae_headers xah
            SET    gl_transfer_date             = sysdate,
                   gl_transfer_status_code      = 'S'
            WHERE  application_id               = g_application_id
            AND    ledger_id                    = g_ledger_id_tab(i)
            AND    group_id                     = g_group_id
            AND    gl_transfer_status_code      = 'N'
            AND    accounting_entry_status_code = 'F'
	    -- added Bug#8691650
            AND EXISTS
                (
                  SELECT 1 FROM xla_ae_lines xal
                  WHERE xah.ae_header_id = xal.ae_header_id
                  AND  xah.application_id = xal.application_id
               )
	    AND EXISTS
	        (
		  -- added hint for perf bug#10047096
		  SELECT /*+ no_unnest */ 1 FROM xla_events xle
                  WHERE xah.event_id = xle.event_id
                  AND  xah.application_id = xle.application_id
		  AND xle.event_status_code  = 'P'
		  AND xle.process_status_code = 'P'
		);


          l_je_count  := SQL%ROWCOUNT;

      WHEN C_ACCTPROG_DOCUMENT THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Selecting journal entris for the document ' || g_entity_id,C_LEVEL_STATEMENT,l_log_module);
         END IF;
         FORALL i IN g_ledger_id_tab.FIRST..g_ledger_id_tab.LAST
            UPDATE xla_ae_headers aeh
            SET    program_update_date          = SYSDATE,
                   program_id                   = g_program_id,
                   request_id                   = g_request_id,
                   group_id                     = g_group_id,
                   gl_transfer_date             = sysdate,
                   gl_transfer_status_code      = 'S'
            WHERE  application_id               = g_application_id
            AND    ledger_id                    = g_ledger_id_tab(i)
            AND    gl_transfer_status_code      = 'N'
            AND    entity_id                    = g_entity_id
            AND    accounting_entry_status_code = 'F'
            -- added Bug#8691650
            AND EXISTS
                (
                  SELECT 1 FROM xla_ae_lines xal
                  WHERE aeh.ae_header_id = xal.ae_header_id
                  AND  aeh.application_id = xal.application_id
                )
   	   AND EXISTS
	        (
		  SELECT 1 FROM xla_events xle
                  WHERE aeh.event_id = xle.event_id
                  AND  aeh.application_id = xle.application_id
		  AND xle.event_status_code  = 'P'
		  AND xle.process_status_code = 'P'
		);


         l_je_count  := SQL%ROWCOUNT;

      ELSE -- When C_TP_MERGE or C_MPA_COMPLETE
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Selecting journal entries for the accounting batch id ' || g_accounting_batch_id,C_LEVEL_STATEMENT,l_log_module);
         END IF;
         FORALL i IN g_ledger_id_tab.FIRST .. g_ledger_id_tab.LAST
           UPDATE xla_ae_headers aeh
           SET    program_update_date          = SYSDATE,
                  program_id                   = g_program_id,
                  group_id                     = g_group_id,
                  gl_transfer_date             = SYSDATE,
                  gl_transfer_status_code      = 'S'
           WHERE  application_id               = g_application_id
           AND    ledger_id                    = g_ledger_id_tab(i)
           AND    gl_transfer_status_code      = 'N'
           AND    accounting_batch_id          = g_accounting_batch_id
           AND    accounting_entry_status_code = 'F'
	    -- added Bug#8691650
            AND EXISTS
                (
                  SELECT 1 FROM xla_ae_lines xal
                  WHERE aeh.ae_header_id = xal.ae_header_id
                  AND  aeh.application_id = xal.application_id
               )
	    AND EXISTS
	        (
		  SELECT 1 FROM xla_events xle
                  WHERE aeh.event_id = xle.event_id
                  AND  aeh.application_id = xle.application_id
		  AND xle.event_status_code  = 'P'
		  AND xle.process_status_code = 'P'
		);

         l_je_count  := SQL%ROWCOUNT;

      END CASE;

   ELSIF g_transfer_mode = 'STANDALONE' THEN
      IF g_caller = C_ACCTPROG_DOCUMENT THEN
         FORALL i IN g_ledger_id_tab.FIRST..g_ledger_id_tab.LAST
           UPDATE xla_ae_headers aeh
           SET    program_update_date          = SYSDATE,
                  program_id                   = g_program_id,
                  request_id                   = g_request_id,
                  gl_transfer_date             = sysdate,
                  gl_transfer_status_code      = 'S',
                  group_id                     = g_group_id
           WHERE  application_id               = g_application_id
           AND    ledger_id                    = g_ledger_id_tab(i)
           AND    entity_id                    = g_entity_id
           AND    gl_transfer_status_code      = 'N'
           AND    accounting_entry_status_code = 'F'
 	    -- added Bug#8691650
           AND EXISTS
                (
                  SELECT 1 FROM xla_ae_lines xal
                  WHERE aeh.ae_header_id = xal.ae_header_id
                  AND  aeh.application_id = xal.application_id
               )
	  AND EXISTS
	        (
		  SELECT 1 FROM xla_events xle
                  WHERE aeh.event_id = xle.event_id
                  AND  aeh.application_id = xle.application_id
		  AND xle.event_status_code  = 'P'
		  AND xle.process_status_code = 'P'
		);

           l_je_count  := SQL%ROWCOUNT;

      ELSIF g_caller = C_ACCTPROG_BATCH THEN  -- Standalone batch transfer
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Standalone batch transfer.',C_LEVEL_STATEMENT,l_log_module);
         END IF;

	 -- for bug 8417930
	 -- added extra conditions to make the below update and
	 -- gl_interface insert query in SYNC.

         l_statement :=
               ' UPDATE
               (SELECT /*+ leading(aeh,xet,xte) use_hash(xet,xec,xeca) use_nl(xte)
                swap_join_inputs(xet) swap_join_inputs(xec) swap_join_inputs(xeca) */
                aeh.program_update_date -- added hint per performance change 7259699
                      ,aeh.program_id
                      ,aeh.request_id
                      ,aeh.gl_transfer_date
                      ,aeh.gl_transfer_status_code
                      ,aeh.group_id
                FROM   xla_ae_headers           aeh
                      ,xla_transaction_entities xte
                      ,xla_event_types_b        xet
                      ,xla_event_class_attrs    xeca
                      ,xla_event_classes_b      xec
                WHERE xte.entity_id           = aeh.entity_id
                AND   xte.application_id      = :1 --g_application_id
                AND   aeh.application_id      = xte.application_id
                AND   aeh.ledger_id           = :2 --g_ledger_id_tab(i)
				AND   aeh.je_category_name    in (select je_category_name from gl_je_categories) --8417930
				AND   EXISTS(select 1 from gl_period_statuses glp
							where glp.application_id = 101
							and glp.ledger_id = aeh.ledger_id
							and glp.period_name = aeh.period_name) --8417930
                AND   aeh.accounting_date    <= :3 --g_end_date
                AND   xte.entity_code         = xec.entity_code
                AND   xeca.application_id      = xec.application_id
                AND   xeca.event_class_code    = xec.event_class_code
                AND   xeca.entity_code         = xec.entity_code
                AND   xeca.event_class_group_code = Nvl(:4,xeca.event_class_group_code)
                AND   xec.event_class_code     = xet.event_class_code
                AND   xet.event_type_code      = aeh.event_type_code
                AND   xet.application_id       = aeh.application_id
                AND   xec.application_id       = xet.application_id
                AND   xet.event_class_code     = xec.event_class_code
                AND   aeh.gl_transfer_status_code         = ''N''
                AND   aeh.accounting_entry_status_code    = ''F''
                AND EXISTS
                  (
                   SELECT 1 FROM xla_ae_lines xal
                   WHERE aeh.ae_header_id = xal.ae_header_id
                   AND  aeh.application_id = xal.application_id
                 )
                AND EXISTS
	        (
		  SELECT 1 FROM xla_events xle
                  WHERE aeh.event_id = xle.event_id
                  AND  aeh.application_id = xle.application_id
		  AND xle.event_status_code  = ''P''
		  AND xle.process_status_code = ''P''
		)
               '
                || g_transaction_security
                || ' ) SET program_update_date = SYSDATE
                 ,program_id                   = :5 --g_program_id
                 ,request_id                   = :6 --g_request_id
                 ,gl_transfer_date             = Sysdate
                 ,group_id                     = :7 --g_group_id
                 ,gl_transfer_status_code      = ''S''';

         trace('l_statement_2 := ' || l_statement,C_LEVEL_STATEMENT,l_log_module);

         FORALL i IN g_ledger_id_tab.FIRST..g_ledger_id_tab.LAST
            EXECUTE IMMEDIATE l_statement
            USING g_application_id
                 ,g_ledger_id_tab(i)
                 ,g_end_date
                 ,g_process_category
                 ,g_program_id
                 ,g_request_id
                 ,g_group_id;

             l_je_count  := SQL%ROWCOUNT;

       END IF;
   END IF;


   IF (NVL(l_je_count,0) = 0)  THEN
      -- Add the code to stop the transfer batch if no entries are
      -- found for the primary ledger.
      g_proceed := 'N';
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('No subledger journal entries were found for the specified criteria.',C_LEVEL_STATEMENT,l_log_module);
      END IF;
   ELSE
      g_proceed := 'Y';
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Total journal entries selected = ' || l_je_count,C_LEVEL_STATEMENT,l_log_module);
      END IF;
      --
      -- Create log entry
      --
      --insert_transfer_log(p_ledger_id => p_ledger_id);
   END IF;

   --
   -- Display number of journal entries selected for each ledger.
   --
/*   FOR i IN g_ledger_id_tab.first..g_ledger_id_tab.last LOOP
      trace('g_ledger_id = ' ||g_ledger_id_tab(i),C_LEVEL_STATEMENT,l_log_module);
      trace('ledger_name = ' ||g_all_ledgers_tab(g_ledger_id_tab(i)).NAME,C_LEVEL_STATEMENT,l_log_module);
      trace('Rowcount    = ' ||SQL%BULK_ROWCOUNT(i),C_LEVEL_STATEMENT,l_log_module);

      IF (SQL%BULK_ROWCOUNT(i) > 0)  THEN
         xla_accounting_err_pkg.build_message
            (p_appli_s_name => 'XLA'
            ,p_msg_name     => 'XLA_GLT_JE_COUNT'
            ,p_token_1      => 'LEDGER_NAME'
            ,p_value_1      => g_all_ledgers_tab(g_ledger_id_tab(i)).NAME
            ,p_token_2      => 'COUNT'
            ,p_value_2      => SQL%BULK_ROWCOUNT(i)
            ,p_entity_id    => NULL
            ,p_event_id     => NULL
            );
      END IF;
   END LOOP;
*/

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('select_journal_entries.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
       IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
          trace('Unexpected error in ',C_LEVEL_UNEXPECTED,l_log_module);
       END IF;
      RAISE;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_transfer_pkg.select_journal_entries');
END select_journal_entries;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    SET_APPLICATION_INFO                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Derive application LEVEL information.                                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |     p_application_id  Application ID OF THE CALLING application.          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 +===========================================================================*/


PROCEDURE set_application_info  IS
   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.set_application_info';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('set_application_info.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
   -- Populate application level info
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Populate application level information',C_LEVEL_STATEMENT,l_log_module);
   END IF;
   SELECT js.je_source_name
         ,decode(js.import_using_key_flag,'Y',js.je_source_key
                ,js.user_je_source_name)
         ,js.import_using_key_flag
   INTO   g_je_source_name
         ,g_user_source_name
         ,g_import_key_flag
   FROM   gl_je_sources  js
         ,xla_subledgers xsl
   WHERE  xsl.application_id = g_application_id
   AND    js.je_source_name  = xsl.je_source_name;


   --
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('set_application_info.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.set_application_info');
END set_application_info;

/*===========================================================================+
  PROCEDURE
     gl_interface_insert

  DESCRIPTION
   Inserts ROWS INTO THE GL_ITERFACE TABLE

  SCOPE - PRIVATE

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED

  ARGUMENTS


  NOTES

 +===========================================================================*/

PROCEDURE insert_gl_interface IS
  l_log_module  VARCHAR2(240);
  l_statement  VARCHAR2(4500);
  l_je_count    NUMBER;


BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_gl_interface';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('gl_interface_insert.Begin',C_LEVEL_PROCEDURE,l_log_module);
      trace('g_disable_gllezl_flag = '||g_disable_gllezl_flag,C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   -- Check if GL Journal Import should be submitted.  Do not use multi table insert if
   -- GL is not installed or for document level transfer.

     IF g_disable_gllezl_flag = 'Y' OR g_entity_id IS NOT NULL THEN
        g_gl_interface_table_name :=  'GL_INTERFACE';
     ELSE
        g_gl_interface_table_name := 'XLA_GLT_'||to_char(g_group_id);
	--Added for bug 12965313 start
        GL_JOURNAL_IMPORT_PKG.create_table
	(g_gl_interface_table_name,
	create_n1_index => FALSE,
	create_n2_index => FALSE,
	create_n3_index => TRUE
	);
	--Added for bug 12965313 end
     END IF;

     print_logfile ('GL Inerface tablename = ' || g_gl_interface_table_name);
     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace('tablename = '||g_gl_interface_table_name,C_LEVEL_PROCEDURE,l_log_module);
     END IF;



     print_logfile ('GL Inerface tablename = ' || g_gl_interface_table_name);
     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace('tablename = '||g_gl_interface_table_name,C_LEVEL_PROCEDURE,l_log_module);
     END IF;


      print_logfile ('tablename = ' || g_gl_interface_table_name);
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('tablename = '||g_gl_interface_table_name,C_LEVEL_PROCEDURE,l_log_module);
      END IF;

      --7512923 added extra columns to gl_interface_table
      --7419726 changed the decode statement of funds_reserved_flag
      --7591257 added extra columns to pass Currency Conversion rate, type and date
      l_statement := 'INSERT INTO '||g_gl_interface_table_name||
          '(
        status,                           ledger_id
       ,user_je_source_name,              user_je_category_name
       ,accounting_date
       ,currency_code
       ,date_created,                     created_by
       ,actual_flag
       ,budget_version_id
       ,encumbrance_type_id
       ,code_combination_id,              stat_amount
       ,entered_dr
       ,entered_cr
       ,accounted_dr
       ,accounted_cr
       ,reference1
       ,reference4
       ,reference5
       ,reference10
       ,reference11
       ,subledger_doc_sequence_id
       ,subledger_doc_sequence_value
       ,gl_sl_link_table
       ,gl_sl_link_id
       ,request_id
       ,ussgl_transaction_code
       ,je_header_id,                     group_id
       ,period_name,                      jgzz_recon_ref
       ,reference_date
       ,funds_reserved_flag
       ,reference25
       ,reference26
       ,reference27
       ,reference28
       ,reference29
       ,reference30
       )
   SELECT /*+ ordered index(aeh,xla_ae_headers_n1) use_nl(jc,led,ael,gps) */
           ''NEW'',                        aeh.ledger_id
           ,:1     ,                       decode(:2,''Y'',jc.je_category_key
                                                 ,jc.user_je_category_name)
          ,DECODE(:3, ''P'' , gps.end_date , aeh.accounting_date)
          ,DECODE(aeh.balance_type_code , ''E'' , led.currency_code , ael.currency_code)
          ,SYSDATE,                        :4
          ,aeh.balance_type_code
          ,aeh.budget_version_id
          ,ael.encumbrance_type_id         -- 4458381
          ,ael.code_combination_id,        ael.statistical_amount
          ,DECODE(aeh.balance_type_code, ''E'', ael.accounted_dr, ael.entered_dr) -- 4458381
          ,DECODE(aeh.balance_type_code, ''E'', ael.accounted_cr, ael.entered_cr) -- 4458381
          ,accounted_dr
          ,accounted_cr
          ,:5                               -- Reference1
          ,DECODE(reference_date , NULL , NULL
                  ,TO_CHAR(reference_date,''DD-MON-YYYY''))||
           DECODE(:6 , ''A'' , TO_CHAR(aeh.accounting_date ,''DD-MON-YYYY'')
                  ,''P'' ,aeh.period_name
                  ,''D'' ,aeh.ae_header_id
                  ,''E'' ,TO_CHAR(aeh.accounting_date ,''DD-MON-YYYY'') -- added E/F lookup code for bug8681466
                  ,''F'' ,aeh.period_name)  --Reference4
          ,DECODE(:7,''D'',substrb(aeh.description,1,240),null)
          ,DECODE(DECODE(:8,''D'',''D'',''E'',''D'',''F'',''D'',''S'')||ael.gl_transfer_mode_code --added bug 8846459 to show line description
                 ,''SS'',null,substrb(ael.description,1,240))
          ,DECODE(:9||ael.gl_transfer_mode_code,
                  ''AS'',jgzz_recon_ref,
                  ''PS'',jgzz_recon_ref,
                  aeh.ae_header_id||''-''||ael.ae_line_num) -- Reference11
          ,aeh.doc_sequence_id
          ,aeh.doc_sequence_value
          ,ael.gl_sl_link_table
          ,ael.gl_sl_link_id
          ,:10
          ,ael.ussgl_transaction_code
          ,aeh.ae_header_id,             :11
          ,aeh.period_name,              ael.jgzz_recon_ref
          ,aeh.reference_date
	  ,decode(led.enable_budgetary_control_flag
                ,''Y'',
                   decode(aeh.funds_status_code, ''A'', ''Y'', ''S'', ''Y'', ''P'', ''Y'', NULL)
                  ,''Y'')
           ,aeh.entity_id
           ,aeh.event_id
           ,ael.ae_header_id
           ,ael.ae_line_num
           ,ael.accounted_dr
           ,ael.accounted_cr
   FROM   xla_ae_headers     aeh
         ,xla_ae_lines       ael
         ,gl_je_categories   jc
         ,gl_period_statuses gps
         ,gl_ledgers         led
   WHERE ael.application_id        = aeh.application_id
   AND   ael.ae_header_id          = aeh.ae_header_id
   AND   aeh.group_id              = :12
   AND   aeh.application_id        = :13                --4769315
   AND   aeh.je_category_name      = jc.je_category_name
   AND   gps.application_id        = 101
   AND   gps.ledger_id             = aeh.ledger_id
   AND   led.ledger_id             = gps.ledger_id
   AND   aeh.period_name           = gps.period_name
   AND   aeh.gl_transfer_status_code = ''S''';

/*
For bug 8407619
Following columns have been removed from the above Insert and Select
	currency_conversion_date
       ,user_currency_conversion_type
       ,currency_conversion_rate

*/

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('l_statement = ' || l_statement,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   EXECUTE IMMEDIATE l_statement
   USING g_user_source_name
        ,g_import_key_flag
        ,g_transfer_summary_mode
        ,g_user_id
        ,g_batch_name
        ,g_transfer_summary_mode
        ,g_transfer_summary_mode
        ,g_transfer_summary_mode
        ,g_transfer_summary_mode
        ,g_request_id
        ,g_group_id
        ,g_group_id
        ,g_application_id;

/*
Comment start for 8417930  (reverting the changes done earlier)

 l_je_count  := SQL%ROWCOUNT;


 IF (NVL(l_je_count,0) = 0)  THEN
      -- Add the code to stop the transfer batch if no entries are
      -- found for the primary ledger.
      g_proceed := 'N';
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(SQL%ROWCOUNT || '   rows are inserted into the GL_INTERFACE table',C_LEVEL_STATEMENT,l_log_module);
       END IF;
   ELSE
      g_proceed := 'Y';
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(SQL%ROWCOUNT || '   rows are inserted into the GL_INTERFACE table',C_LEVEL_STATEMENT,l_log_module);
   END IF;

  END IF;

 Comment end for 8417930 */

-- For bug 8417930
-- Added to find how many rows were inserted into GL_INTERFACE table

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(SQL%ROWCOUNT || '   rows are inserted into the GL_INTERFACE table',C_LEVEL_STATEMENT,l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('gl_interface_insert.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
      (p_location => 'xla_transfer_pkg.gl_interface_insert');
END insert_gl_interface;

/*===========================================================================+
  PROCEDURE
     wait_for_gllezl

  DESCRIPTION
   Wait FOR THE journal import request TO COMPLETE.

  SCOPE - PRIVATE

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED

  ARGUMENTS


  NOTES

 +===========================================================================*/
FUNCTION  wait_for_gllezl RETURN BOOLEAN IS
   l_callStatus        BOOLEAN;
   l_phase             VARCHAR2(30);
   l_status            VARCHAR2(30);
   l_dev_phase         VARCHAR2(30);
   l_dev_status        VARCHAR2(30);
   l_message           VARCHAR2(240);
   l_gllezl_status     BOOLEAN        := TRUE;
   l_index             PLS_INTEGER    := 0;
   l_log_module        VARCHAR2(240);
   l_gl_status          VARCHAR2(30);
   g_gl_interface_table_name  VARCHAR2(30);
   l_journal_import_status  BOOLEAN    :=TRUE;
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.wait_for_gllezl';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('wait_for_gllezl.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Ledgers count = ' || g_primary_ledgers_tab.COUNT,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   FOR i IN REVERSE g_primary_ledgers_tab.first..g_primary_ledgers_tab.last
   LOOP
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace('Looping for the ledger = ' || g_primary_ledgers_tab(i).ledger_id,C_LEVEL_STATEMENT,l_log_module);
      END IF;

      IF (g_primary_ledgers_tab(i).gllezl_request_id IS NOT NULL) THEN
         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace('Checking status for request id = ' || g_primary_ledgers_tab(i).gllezl_request_id,C_LEVEL_EVENT,l_log_module);
         END IF;

         l_callStatus := fnd_concurrent.wait_for_request
            (request_id => g_primary_ledgers_tab(i).gllezl_request_id
            ,interval   => 5
            ,phase      => l_phase
            ,status     => l_status
            ,dev_phase  => l_dev_phase
            ,dev_status => l_dev_status
            ,message    => l_message);

        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('l_dev_phase = '  || l_dev_phase,C_LEVEL_STATEMENT,l_log_module);
          trace('l_dev_status = ' || l_dev_status,C_LEVEL_STATEMENT,l_log_module);
        END IF;

    /*
     --For bug 8417930
     -- Added below IF condition to avoid online transfer to GL failing
     -- with "table or view does not exist".
     */

     IF g_disable_gllezl_flag = 'Y' OR g_entity_id IS NOT NULL THEN
        g_gl_interface_table_name :=  'GL_INTERFACE';
     ELSE
        g_gl_interface_table_name := 'XLA_GLT_'||to_char(g_primary_ledgers_tab(i).group_id);
     END IF;


  --added bug 6945231
      IF ( l_dev_phase = 'COMPLETE' AND l_dev_status  ='WARNING') THEN
           IF (C_LEVEL_ERROR >= g_log_level) THEN
               trace('selecting from gl interface '|| g_gl_interface_table_name,C_LEVEL_PROCEDURE,l_log_module);
            END IF;

         -- removed join of ledger id from below query for bug 7529513
         BEGIN
           EXECUTE IMMEDIATE
          'select  status   from ' ||g_gl_interface_table_name||
          ' where user_je_source_name= :1
           and group_id = :2
           and request_id = :4
           -- and status like ''E%''
	   and status <> ''PROCESSED'' AND status NOT LIKE ''W%''
           and rownum=1 ' into l_gl_status
           using g_user_source_name,g_primary_ledgers_tab(i).group_id, g_primary_ledgers_tab(i).gllezl_request_id;

         --IF l_gl_status like 'E%' THEN --Bug#8691650
         IF ( l_gl_status <> 'PROCESSED' AND l_gl_status NOT LIKE 'W%' ) THEN

	   IF (C_LEVEL_ERROR >= g_log_level) THEN
               trace('Data found  in Gl interface with Error Status and journal import request failed. Request Id = ' || g_primary_ledgers_tab(i).gllezl_request_id,C_LEVEL_ERROR,l_log_module);
            END IF;
             l_journal_import_status:=FALSE;
            xla_accounting_err_pkg.build_message
                 (p_appli_s_name => 'XLA'
                 ,p_msg_name     => 'XLA_GLT_GLLEZL_FAILED'
                 ,p_token_1      => 'REQUEST_ID'
                 ,p_value_1      => g_primary_ledgers_tab(i).gllezl_request_id
                 ,p_token_2      => 'LEDGER_NAME'
                 ,p_value_2      => g_primary_ledgers_tab(i).NAME
                 ,p_entity_id    => NULL
                 ,p_event_id     => NULL
                 );
            -- Perform Recovery
            recover_batch;
         END IF;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (C_LEVEL_ERROR >= g_log_level) THEN
                trace('No data in gl_interface '|| g_gl_interface_table_name,C_LEVEL_PROCEDURE,l_log_module);
              END IF;
            /*no data exists in error so dont recover */
             NULL; --Bug#8691650
        END;

     END IF;

       l_gl_status :=NULL;


          IF  ( l_dev_phase = 'COMPLETE' AND l_dev_status NOT IN ( 'NORMAL','WARNING')) THEN -- added bug 7653258 Transfer to Gl should issue a rollback for all other JI statuses like cancelled/terminated/Error
            IF (C_LEVEL_ERROR >= g_log_level) THEN
               trace('The journal import request failed. Request Id = ' || g_primary_ledgers_tab(i).gllezl_request_id,C_LEVEL_ERROR,l_log_module);
            END IF;
            l_journal_import_status:=FALSE;
            xla_accounting_err_pkg.build_message
                 (p_appli_s_name => 'XLA'
                 ,p_msg_name     => 'XLA_GLT_GLLEZL_FAILED'
                 ,p_token_1      => 'REQUEST_ID'
                 ,p_value_1      => g_primary_ledgers_tab(i).gllezl_request_id
                 ,p_token_2      => 'LEDGER_NAME'
                 ,p_value_2      => g_primary_ledgers_tab(i).NAME
                 ,p_entity_id    => NULL
                 ,p_event_id     => NULL
                 );
            -- Perform Recovery
            recover_batch;
         END IF;

  --8429053 Added following IF condition in order to delete
  --E% status data from GL_INTERFACE.

        If g_gl_interface_table_name = 'GL_INTERFACE' Then
                delete from gl_interface
                where user_je_source_name = g_user_source_name
                and group_id = g_primary_ledgers_tab(i).group_id;
                --and request_id = g_primary_ledgers_tab(i).gllezl_request_id

                IF SQL%NOTFOUND THEN
                    IF (C_LEVEL_ERROR >= g_log_level) THEN
                        trace('No rows found in GL_INTERFACE Table With E% errors.',C_LEVEL_ERROR,l_log_module);
                    END IF;
                ELSE
                    IF (C_LEVEL_ERROR >= g_log_level) THEN
                        trace(SQL%ROWCOUNT || 'Rows deleted from GL_INTERFACE Table',C_LEVEL_ERROR,l_log_module);
                    END IF;
                END IF;
        END IF;
  --8429053 END

  END IF;

END LOOP;

IF l_journal_import_status = TRUE THEN
l_gllezl_status  := TRUE;
ELSE l_gllezl_status:=FALSE;
END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('wait_for_gllezl.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   RETURN(l_gllezl_status);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.wait_for_gllezl');
END wait_for_gllezl;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_transfer_status                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Updates the transfer to GL status to yes to indicate that journal entries|
 |  have been transferred successfully.                                      |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE set_transfer_status IS
   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.set_transfer_status';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('set_transfer_status.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
   --
   -- Update XLA_AE_HEADERS
   --
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Updating  xla_ae_headers ',C_LEVEL_STATEMENT,l_log_module);
   END IF;

   FORALL i IN g_group_id_tab.FIRST..g_group_id_tab.LAST
      UPDATE /*+ index(XLA_AE_HEADERS,XLA_AE_HEADERS_N1) */
             xla_ae_headers
      SET    gl_transfer_status_code = 'Y',
             gl_transfer_date        = sysdate -- bug#5437400
      WHERE  group_id                = g_group_id_tab(i)
        AND  application_id          = g_application_id  --4769315
		--Added for 10124492
		AND gl_transfer_status_code <> 'NT';
		--Added for 10124492

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('set_transfer_status.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
     (p_location => 'xla_transfer_pkg.set_transfer_status');
END set_transfer_status;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_transfer_log                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Deletes the transfer to GL log.                                          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_transfer_log IS
   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_transfer_log';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('delete_transfer_log.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   -- Delete transfer to GL log
   --
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Deleting rows from the transfer log.',C_LEVEL_STATEMENT,l_log_module);
   END IF;

   FORALL i IN g_group_id_tab.FIRST..g_group_id_tab.LAST
      DELETE xla_transfer_logs
      WHERE group_id = g_group_id_tab(i);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('delete_transfer_log.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
     (p_location => 'xla_transfer_pkg.delete_transfer_log');
END delete_transfer_log;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_secondary_ledgers                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Keeps track of journal entries transferred for secondary ledgers         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    p_secondary_ledger_id -- Secondary ledger identifier                   |                    |
 | NOTES                                                                     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_secondary_ledgers ( p_secondary_ledger_id  IN NUMBER ) IS
   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_secondary_ledgers';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('insert_secondary_ledgers.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('insert_secondary_ledgers.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
   INSERT INTO xla_transfer_ledgers
      (GROUP_ID
      ,SECONDARY_LEDGER_ID
      ,PRIMARY_LEDGER_ID
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,PROGRAM_UPDATE_DATE
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,REQUEST_ID
      )
   VALUES
      (g_group_id
      ,p_secondary_ledger_id
      ,g_primary_ledger_id
      ,SYSDATE
      ,g_user_id
      ,SYSDATE
      ,xla_environment_pkg.g_usr_id
      ,xla_environment_pkg.g_login_id
      ,SYSDATE
      ,xla_environment_pkg.g_prog_appl_id
      ,xla_environment_pkg.g_prog_id
      ,xla_environment_pkg.g_Req_Id
      );
EXCEPTION
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
     (p_location => 'xla_transfer_pkg.insert_secondary_ledgers');
END insert_secondary_ledgers;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    COMPLETE_BATCH                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  The procedure performs the finishing tasks after inserting journal       |
 |  entries into the GL interface table.                                     |
 |                                                                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |     p_submit_gl_post  Submit GL post                                      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE complete_batch(p_submit_gl_post VARCHAR2) IS
   l_req_id      NUMBER;
   l_submit_post BOOLEAN := FALSE;
   l_ledger_id   NUMBER;
   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.complete_batch';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('complete_batch.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_submit_gl_post = ' || p_submit_gl_post,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   FOR i IN g_primary_ledgers_tab.FIRST..g_primary_ledgers_tab.LAST
   LOOP
      l_ledger_id := g_primary_ledgers_tab(i).ledger_id;
      IF (NVL(p_submit_gl_post,'N') = 'Y'
          AND g_all_ledgers_tab(l_ledger_id).access_set_id IS NOT NULL) THEN

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace('l_submit_post = TRUE',C_LEVEL_STATEMENT,l_log_module);
          END IF;
         l_submit_post := TRUE;
      ELSE
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('l_submit_post = FALSE',C_LEVEL_STATEMENT,l_log_module);
         END IF;
      END IF;

      IF (g_primary_ledgers_tab(i).ledger_category_code = 'SECONDARY') THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Inserting a row into the XLA_TRANSFER_LEDGERS table.',C_LEVEL_STATEMENT,l_log_module);
         END IF;

         insert_secondary_ledgers
            (p_secondary_ledger_id => g_primary_ledgers_tab(i).ledger_id
            );
     END IF;
     IF (g_log_enabled  AND C_LEVEL_EVENT >= g_log_level) THEN
        trace('Calling  gl_journal_import_SLA_pkg.keep_batches ',C_LEVEL_EVENT,l_log_module);
     END IF;

     IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace('p_submit_gl_post = ' || p_submit_gl_post,C_LEVEL_STATEMENT,l_log_module);
        trace('access_set_id    = ' || g_all_ledgers_tab(l_ledger_id).access_set_id,C_LEVEL_STATEMENT,l_log_module);
     END IF;

     -- keep batches and submit GL post
     gl_journal_import_SLA_pkg.keep_batches
         (x_je_source_name   => g_je_source_name
         ,x_group_id         => g_primary_ledgers_tab(i).group_id
         ,start_posting      => l_submit_post
         ,data_access_set_id => g_all_ledgers_tab(l_ledger_id).access_set_id
         ,req_id             => l_req_id);

   END LOOP;

   IF (g_group_id_tab.COUNT > 0) THEN
      set_transfer_status;
      delete_transfer_log;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('complete_batch.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.complete_batch');
END complete_batch;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    IS_REPORT_DEFN_FOUND                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   For a given ledger, check if an Open Account Balances Listing Report    |                                                                         |
 |   Definition does exist.                                                  |
 |   When no report definition is found, data manager is not submitted       |
 |   for the ledger.                                                         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |     p_ledger_id                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                            |
 +===========================================================================*/

FUNCTION is_report_defn_found
   (p_ledger_id       IN NUMBER
   ,p_je_source_name  IN VARCHAR2)
RETURN BOOLEAN IS

  l_cnt                    PLS_INTEGER DEFAULT 0;
  l_log_module             VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.is_report_defn_found';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('is_report_defn_found.Begin'
           ,C_LEVEL_PROCEDURE
           ,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      -- Print all input parameters
      trace('p_ledger_id        = ' || p_ledger_id
           ,C_LEVEL_STATEMENT
           ,l_log_module);
      trace('p_je_source_name   = ' || p_je_source_name
           ,C_LEVEL_STATEMENT
           ,l_log_module);
   END IF;

   SELECT COUNT(1)
     INTO l_cnt
     FROM xla_tb_definitions_b    xtd
         ,xla_tb_defn_je_sources  xjs
    WHERE xtd.definition_code = xjs.definition_code
      AND xjs.je_source_name  = p_je_source_name
      and xtd.ledger_id       = p_ledger_id;

   IF l_cnt > 0 THEN

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace('# of report definitions ' || l_cnt
           ,C_LEVEL_STATEMENT
           ,l_log_module);
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('is_report_defn_found.End'
              ,C_LEVEL_PROCEDURE
              ,l_log_module);
      END IF;

      RETURN TRUE;

   ELSE

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace('No report definition for this ledger'
           ,C_LEVEL_STATEMENT
           ,l_log_module);
      END IF;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace('is_report_defn_found.End'
              ,C_LEVEL_PROCEDURE
              ,l_log_module);
      END IF;

      RETURN FALSE;

   END IF;


EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.is_report_defn_found');
END is_report_defn_found;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    GL_TRANSFER_MAIN                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  Main PROCEDURE that controls THE process flow. ALL THE sub procedures    |
 |  are called FROM FROM this PROCEDURE.                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |     p_application_id  Application ID OF THE CALLING application.          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 +===========================================================================*/


PROCEDURE gl_transfer_main(p_application_id        IN   NUMBER
                          ,p_transfer_mode         IN   VARCHAR2
                          ,p_ledger_id             IN   NUMBER
                          ,p_securiy_id_int_1      IN   NUMBER     DEFAULT NULL
                          ,p_securiy_id_int_2      IN   NUMBER     DEFAULT NULL
                          ,p_securiy_id_int_3      IN   NUMBER     DEFAULT NULL
                          ,p_securiy_id_char_1     IN   VARCHAR2   DEFAULT NULL
                          ,p_securiy_id_char_2     IN   VARCHAR2   DEFAULT NULL
                          ,p_securiy_id_char_3     IN   VARCHAR2   DEFAULT NULL
                          ,p_valuation_method      IN   VARCHAR2   DEFAULT NULL
                          ,p_process_category      IN   VARCHAR2   DEFAULT NULL
                          ,p_accounting_batch_id   IN   NUMBER     DEFAULT NULL
                          ,p_entity_id             IN   NUMBER     DEFAULT NULL
                          ,p_batch_name            IN   VARCHAR2   DEFAULT NULL
                          ,p_end_date              IN   DATE       DEFAULT NULL
                          ,p_submit_gl_post        IN   VARCHAR2   DEFAULT 'N'
                          ,p_caller                IN   VARCHAR2   DEFAULT C_ACCTPROG_BATCH
                         ) IS
--Local Variables
  l_ledger_id              NUMBER;
  l_gllezl_request_id      PLS_INTEGER;
  l_log_module             VARCHAR2(240);
  l_count                  PLS_INTEGER;
  l_req_id                 PLS_INTEGER;
  l_index                  PLS_INTEGER;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.gl_transfer_main';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('gl_transfer_main.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      -- Print all input parameters
      trace('---------------------------------------------------',C_LEVEL_STATEMENT,l_log_module);
      trace('p_application_id        = ' || p_application_id     ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_transfer_mode         = ' || p_transfer_mode      ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_ledger_id             = ' || p_ledger_id          ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_securiy_id_int_1      = ' || p_securiy_id_int_1   ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_securiy_id_int_2      = ' || p_securiy_id_int_2   ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_securiy_id_int_3      = ' || p_securiy_id_int_3   ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_securiy_id_char_1     = ' || p_securiy_id_char_1  ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_securiy_id_char_2     = ' || p_securiy_id_char_2  ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_securiy_id_char_3     = ' || p_securiy_id_char_3  ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_valuation_method      = ' || p_valuation_method   ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_process_category      = ' || p_process_category   ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_accounting_batch_id   = ' || p_accounting_batch_id,C_LEVEL_STATEMENT,l_log_module);
      trace('p_entity_id             = ' || p_entity_id          ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_batch_name            = ' || p_batch_name         ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_end_date              = ' || TO_CHAR(p_end_date,'MM/DD/YYYY'),C_LEVEL_STATEMENT,l_log_module);
      trace('p_submit_gl_post        = ' || p_submit_gl_post     ,C_LEVEL_STATEMENT,l_log_module);
      trace('p_caller                = ' || p_caller             ,C_LEVEL_STATEMENT,l_log_module);
      trace('---------------------------------------------------',C_LEVEL_STATEMENT,l_log_module);

      trace('Global variables',C_LEVEL_STATEMENT,l_log_module);
      trace('---------------------------------------------------',C_LEVEL_STATEMENT,l_log_module);
      trace('g_use_ledger_security   = ' || g_use_ledger_security,C_LEVEL_STATEMENT,l_log_module);
      trace('g_access_set_id         = ' || g_access_set_id      ,C_LEVEL_STATEMENT,l_log_module);
      trace('g_sec_access_set_id     = ' || g_sec_access_set_id  ,C_LEVEL_STATEMENT,l_log_module);
      trace('---------------------------------------------------',C_LEVEL_STATEMENT,l_log_module);
   END IF;


   -- Set Global Variables
   g_application_id        := p_application_id;
   g_entity_id             := p_entity_id;
   g_end_date              := p_end_date;
   g_user_id               := fnd_global.user_id;
   g_request_id            := fnd_global.conc_request_id;
   g_transfer_mode         := p_transfer_mode;
   g_accounting_batch_id   := p_accounting_batch_id;
   g_batch_name            := p_batch_name;
   g_program_id            := fnd_global.conc_program_id;
   g_security_id_int_1     := p_securiy_id_int_1;
   g_security_id_int_2     := p_securiy_id_int_2;
   g_security_id_int_3     := p_securiy_id_int_3;
   g_security_id_char_1    := p_securiy_id_char_1;
   g_security_id_char_2    := p_securiy_id_char_2;
   g_security_id_char_3    := p_securiy_id_char_3;
   g_valuation_method      := p_valuation_method;
   g_process_category      := p_process_category;
   g_caller                := p_caller;

   -- Validate input parameters
   validate_input_parameters;
   set_transaction_security;

   --Get application information
   set_application_info;

   -- Check if GL is installed.
      IF g_disable_gllezl_flag = 'N' THEN
         trace('Submit Journal Import has been enabled.',C_LEVEL_STATEMENT,l_log_module);
      ELSE
         trace('Submit Journal Import has been disabled.',C_LEVEL_STATEMENT,l_log_module);
      END IF;

   --Get ledgers to process
   get_ledgers(p_ledger_id);

   IF (p_transfer_mode = 'STANDALONE') THEN
      trace('Checking for failed batches',C_LEVEL_STATEMENT,l_log_module);
      -- Check for previously failed batches.
      --
      recover_batch;
      -- Initialize the group_id table.
      g_group_id_tab.DELETE;
      --
      -- Perform period validation.
      --
      --
      -- Commenting out the call to validate_accounting_periods for bug 5438564
      --
     /* validate_accounting_periods (p_ledger_id => p_ledger_id); */
   END IF;

   --
   -- Loop for each primary and secondary ledger
   --

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Number of primary and secondary ledgers to process = ' || g_primary_ledgers_tab.COUNT,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   IF g_caller = C_ACCTPROG_BATCH AND g_transfer_mode = 'COMBINED' THEN
      FOR i IN g_primary_ledgers_tab.FIRST..g_primary_ledgers_tab.LAST
      LOOP
         FOR j IN xla_accounting_pkg.g_array_ledger_id.FIRST..xla_accounting_pkg.g_array_ledger_id.LAST
         LOOP
            IF xla_accounting_pkg.g_array_ledger_id(j) = g_primary_ledgers_tab(i).ledger_id THEN
               g_primary_ledgers_tab(i).group_id := xla_accounting_pkg.g_array_group_id(j);
               exit;
            END IF;
         END LOOP;
      END LOOP;
   END IF;

   FOR i IN g_primary_ledgers_tab.FIRST..g_primary_ledgers_tab.LAST
   LOOP
         l_ledger_id := g_primary_ledgers_tab(i).ledger_id;
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Primary/Secondary ledger loop',C_LEVEL_STATEMENT,l_log_module);
            trace('Loop for each primary and secondary ledger',C_LEVEL_STATEMENT,l_log_module);
            trace('Ledger Name = ' || g_all_ledgers_tab(l_ledger_id).NAME || '  Ledger Id = ' || l_ledger_id,C_LEVEL_STATEMENT,l_log_module);
         END IF;

         -- Initialize ledgers array
         g_ledger_id_tab.DELETE;

         --Get ledger level options
         get_ledger_options(p_ledger_id => l_ledger_id);


         --
         -- Populate group id and inter_run_id;
         --
	 --For bug fix 7677948
         IF g_caller = C_ACCTPROG_BATCH AND g_transfer_mode = 'COMBINED' THEN
            SELECT gl_journal_import_s.NEXTVAL
            INTO   g_primary_ledgers_tab(i).interface_run_id
            FROM   dual;
         ELSE
            SELECT gl_journal_import_s.NEXTVAL
                  ,gl_interface_control_s.NEXTVAL
            INTO   g_primary_ledgers_tab(i).interface_run_id
                  ,g_primary_ledgers_tab(i).group_id
            FROM   dual;

	    --For bug fix 6941347
	    g_arr_group_id(g_arr_group_id.COUNT +1):= g_primary_ledgers_tab(i).group_id;

         END IF;

         g_group_id         := g_primary_ledgers_tab(i).group_id;
         g_interface_run_id := g_primary_ledgers_tab(i).interface_run_id;
         g_group_id_tab(i)  := g_group_id;


         IF (g_primary_ledgers_tab(i).ledger_category_code = 'PRIMARY') THEN
            -- Get associated ALC ledgers
            --
            get_alc_ledgers;
         ELSE
            g_ledger_id_tab(1) := g_primary_ledgers_tab(i).ledger_id;
         END IF;


         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('Updating Group ID',C_LEVEL_STATEMENT,l_log_module);
         END IF;

         -- Set the group id
         FOR i IN g_ledger_id_tab.first..g_ledger_id_tab.last
         LOOP
            g_all_ledgers_tab(g_ledger_id_tab(i)).group_id := g_group_id;
         END LOOP;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           FOR i IN g_ledger_id_tab.first..g_ledger_id_tab.last
           LOOP
               trace('Ledgers selected for the processing',C_LEVEL_STATEMENT,l_log_module);
               trace('Ledger id = ' ||g_ledger_id_tab(i),C_LEVEL_STATEMENT,l_log_module);
           END LOOP;
         END IF;

         IF (g_parent_group_id IS NULL) THEN
            g_parent_group_id := g_group_id;
         END IF;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            ---------------------------------------------------------------------
            trace('Group_id         = ' || g_group_id,C_LEVEL_STATEMENT,l_log_module);
            trace('Interface_run_id = ' || g_interface_run_id,C_LEVEL_STATEMENT,l_log_module);
            trace('Inserting an entry into the audit table',C_LEVEL_STATEMENT,l_log_module);
            ---------------------------------------------------------------------
         END IF;

         -- Select entries to transfer
         select_journal_entries;

         -- Proceed further only if there are records to process.
         IF g_proceed  = 'Y' THEN
            --
            -- Create a log entry
            --
            insert_transfer_log(g_primary_ledgers_tab(i).ledger_id);
            --
            -- Populate the GL_INTERFACE table
            --
            insert_gl_interface;
            IF g_disable_gllezl_flag = 'N' THEN
               IF (get_gllezl_status) THEN
                  insert_interface_control
                     (p_ledger_id        => g_primary_ledgers_tab(i).ledger_id
                     ,p_table_name       => g_gl_interface_table_name
                     );

                  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
                     trace('Calling PSA_FUNDS_CHECKER_PKG',C_LEVEL_STATEMENT,l_log_module);
                  END IF;

                 PSA_FUNDS_CHECKER_PKG.populate_group_id
                   (p_grp_id         => g_primary_ledgers_tab(i).group_id
                   ,p_application_id => g_application_id
                   ,p_je_batch_name  => g_batch_name
                   );

                  -- Submit Journal Import
                  print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||'- Submitting the Journal Import');
                  l_gllezl_request_id := submit_journal_import
                     (p_ledger_id         => g_primary_ledgers_tab(i).ledger_id
                     ,p_interface_run_id  => g_interface_run_id
                     );

              IF l_gllezl_request_id > 0 THEN
                 -- Journal Import Success
                 g_gllezl_requests_tab(i)                   := l_gllezl_request_id;
                 g_primary_ledgers_tab(i).gllezl_request_id := l_gllezl_request_id;
              ELSE
                 -- Journal Import Failed

                 -- Journal Import Failed
                -- bug#8691650
               IF g_gl_interface_table_name = 'GL_INTERFACE' THEN
 	          FORALL i IN g_group_id_tab.FIRST..g_group_id_tab.LAST
                  DELETE FROM gl_interface
  	          WHERE user_je_source_name = g_user_source_name
 	          AND group_id = g_group_id_tab(i);
	       END IF;

                 recover_batch;
                 xla_exceptions_pkg.raise_exception;
              END IF;

            ELSE
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace('get_gllezl_status return false, raise exception',C_LEVEL_STATEMENT,l_log_module);
               END IF;

            --8429053
			--When get_gllezl_status returns false, data that are newly inserted
			--into GL_INTERFACE table are not deleted. Added below code to
			--delete those data in GL_INTERFACE.

                        If g_gl_interface_table_name = 'GL_INTERFACE' Then

			  --bug#8691650 delete for all the group ids in a loop

			   FORALL i IN g_group_id_tab.FIRST..g_group_id_tab.LAST
                     	   delete from gl_interface
			   where user_je_source_name = g_user_source_name
			   and group_id = g_group_id_tab(i);

				/* commented 8691650
				delete from gl_interface
				where user_je_source_name = g_user_source_name
				and group_id = g_primary_ledgers_tab(i).group_id
				and request_id = g_request_id;
				*/

				IF SQL%NOTFOUND THEN
			    	IF (C_LEVEL_ERROR >= g_log_level) THEN
					trace('No rows found in GL_INTERFACE Table.',C_LEVEL_ERROR,l_log_module);
				    END IF;
				ELSE
				    IF (C_LEVEL_ERROR >= g_log_level) THEN
					trace(SQL%ROWCOUNT || 'Rows deleted from GL_INTERFACE Table',C_LEVEL_ERROR,l_log_module);
				    END IF;
				END IF;
			END IF;

               recover_batch;
               xla_exceptions_pkg.raise_exception;
            END IF;
         END IF;
      ELSE
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace('There are no entries to process in the ledger '|| g_all_ledgers_tab(l_ledger_id).NAME,C_LEVEL_STATEMENT,l_log_module);
         END IF;
       --  g_group_id_tab.DELETE(i); group id is needed to drop the tables
      END IF;
   END LOOP; -- primary/secondary ledgers loop

   -- Wait for journal import to complete.
   -- IF g_proceed  = 'Y' THEN -- Commented for bug 8417930

   IF g_disable_gllezl_flag = 'N' AND g_gllezl_requests_tab.COUNT > 0 THEN
      IF (wait_for_gllezl) THEN
         print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||'- Journal Import completed ');
         complete_batch(p_submit_gl_post => p_submit_gl_post);

         -- Drop GL_INTERFACE tables.
	 --7512923 GL_INTERFACE tables will not be dropped.
         /*IF g_caller <> C_ACCTPROG_DOCUMENT THEN   -- Document mode use GL_INTERFACE table only
            FOR i IN g_primary_ledgers_tab.FIRST..g_primary_ledgers_tab.LAST
            LOOP
               IF g_primary_ledgers_tab(i).gllezl_request_id IS NOT NULL
                  AND (g_entity_id IS NULL OR g_disable_gllezl_flag = 'N') THEN
                  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace('Dropping table  ' || 'XLA_GLT_'||g_primary_ledgers_tab(i).group_id,C_LEVEL_STATEMENT,l_log_module);
                  END IF;
                   GL_JOURNAL_IMPORT_PKG.drop_table('XLA_GLT_' || g_primary_ledgers_tab(i).group_id);
               END IF;
            END LOOP;
         END IF;*/

         l_index := g_all_ledgers_tab.FIRST;
         FOR i in g_all_ledgers_tab.FIRST..g_all_ledgers_tab.LAST
            LOOP
               -- Submit Trial Balance Data Manager only if definitions exist
               -- for a Ledger and a JE source.
               --
               IF is_report_defn_found
                     (p_ledger_id      => g_all_ledgers_tab(l_index).ledger_id
                     ,p_je_source_name => g_je_source_name)
               THEN
                  IF g_all_ledgers_tab(l_index).gllezl_request_id IS NOT NULL THEN
                     trace('Submitting Trial Balance Data Manager for ledger ID = ' || g_all_ledgers_tab(l_index).ledger_id,C_LEVEL_STATEMENT,l_log_module);
                     l_req_id := FND_REQUEST.SUBMIT_REQUEST
                        (application => 'XLA'
                        ,program     => 'XLATBDMG'
                        ,description => NULL
                        ,start_time  => SYSDATE
                        ,sub_request => NULL
			,argument1   => NULL     -- dummy application (for bug 8271212 nksurana)
                        ,argument2   => g_all_ledgers_tab(l_index).ledger_id -- Foster City Corp. l_ledger_id
                        ,argument3   => g_all_ledgers_tab(l_index).GROUP_id --l_group_id
                        ,argument4   => NULL  --l_definition_code
                        ,argument5   => NULL  --l_request_mode
                        ,argument6   => g_je_source_name --bug#7320079 NULL  --l_je_source_name
                        ,argument7   => NULL  --l_upg_batch_id
                        );
                     /*bug#7320079 Passed the je_source_name while spawning data manager. This helps in finding the correct
		     application from which the data manager has been spawned. */

                     trace('Trial Balance Data Manager Request Id = ' || l_req_id,C_LEVEL_STATEMENT,l_log_module);
                  END IF;
               COMMIT;
               END IF;

               l_index := g_all_ledgers_tab.NEXT(l_index);
               IF l_index IS NULL THEN
                  EXIT;
               END IF;
         END LOOP;
      END IF;
   ELSIF g_disable_gllezl_flag = 'Y' THEN
      trace('Journal Import is Disabled',C_LEVEL_STATEMENT,l_log_module);
      set_transfer_status;

      -- Added for Bug 9087997 Start

      l_index := g_all_ledgers_tab.FIRST;
         FOR i in g_all_ledgers_tab.FIRST..g_all_ledgers_tab.LAST
            LOOP
               -- Submit Trial Balance Data Manager only if definitions exist
               -- for a Ledger and a JE source.
               --
               IF is_report_defn_found
                     (p_ledger_id      => g_all_ledgers_tab(l_index).ledger_id
                     ,p_je_source_name => g_je_source_name)
               THEN

                     trace('Submitting Trial Balance Data Manager for ledger ID = ' || g_all_ledgers_tab(l_index).ledger_id,C_LEVEL_STATEMENT,l_log_module);
                     l_req_id := FND_REQUEST.SUBMIT_REQUEST
                        (application => 'XLA'
                        ,program     => 'XLATBDMG'
                        ,description => NULL
                        ,start_time  => SYSDATE
                        ,sub_request => NULL
			,argument1   => NULL     -- dummy application (for bug 8271212 nksurana)
                        ,argument2   => g_all_ledgers_tab(l_index).ledger_id -- Foster City Corp. l_ledger_id
                        ,argument3   => g_all_ledgers_tab(l_index).GROUP_id --l_group_id
                        ,argument4   => NULL  --l_definition_code
                        ,argument5   => NULL  --l_request_mode
                        ,argument6   => g_je_source_name --bug#7320079 NULL  --l_je_source_name
                        ,argument7   => NULL  --l_upg_batch_id
                        );
                     /*bug#7320079 Passed the je_source_name while spawning data manager. This helps in finding the correct
		     application from which the data manager has been spawned. */

                     trace('Trial Balance Data Manager Request Id = ' || l_req_id,C_LEVEL_STATEMENT,l_log_module);

               COMMIT;
               END IF;

               l_index := g_all_ledgers_tab.NEXT(l_index);
               IF l_index IS NULL THEN
                  EXIT;
               END IF;
         END LOOP;

      -- Added for Bug 9087997 End

      delete_transfer_log;
   END IF;

/* Comment start for bug 8417930

ELSE  -- g_proceed flag is 'N'
  FOR i IN g_primary_ledgers_tab.FIRST..g_primary_ledgers_tab.LAST
  LOOP
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace('Resetting Gl Transfer Flag to N in XLA_AE_HEADERS',C_LEVEL_STATEMENT,l_log_module);
     END IF;
      UPDATE xla_ae_headers
        SET    group_id                = NULL
              ,gl_transfer_status_code = 'N'
              ,gl_transfer_date        = NULL
              ,program_update_date     = SYSDATE
              ,program_id              = g_program_id
              ,request_id              = g_request_id
        WHERE  group_id = g_primary_ledgers_tab(i).group_id;
  END LOOP;
  delete_transfer_log;

  Comment End for bug 8417930  */

/*   IF g_total_rows_created > 0 THEN
      trace('The transfer process completed successfully.',C_LEVEL_STATEMENT,l_log_module);
   ELSE
      trace('There are no entries to transfer for the specified criteria.',C_LEVEL_STATEMENT,l_log_module);
   END IF;
*/

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('GL_TRANSFER_MAIN.End',C_LEVEL_PROCEDURE,l_log_module);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
        (p_location => 'xla_transfer_pkg.gl_transfer_main');
END GL_TRANSFER_MAIN;

BEGIN
--   l_log_module     := C_DEFAULT_MODULE;
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;
END XLA_TRANSFER_PKG;

/
