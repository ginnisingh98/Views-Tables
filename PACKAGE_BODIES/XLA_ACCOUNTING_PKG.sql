--------------------------------------------------------
--  DDL for Package Body XLA_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCOUNTING_PKG" AS
/* $Header: xlaapeng.pkb 120.164.12010000.33 2012/08/09 08:35:00 sragadde ship $ */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         ALL rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_accounting_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     Package body for the Accounting Program.                               |
|                                                                            |
| HISTORY                                                                    |
|     11/08/2002    S. Singhania    Created                                  |
|     02/07/2003    S. Singhania    Made changes TO improve performance using|
|                                     BULK architecture.                     |
|     05/21/2003    S. Singhania    Fix FOR bug # 2970204.                   |
|     06/11/2003    S. Singhania    Added calls TO:                          |
|                                     -XLA_TRANSFER_PKG.GL_TRANSFER_MAIN     |
|                                     -XLA_BALANCE_PKG.MASSIVE_UPDATE FOR    |
|                                        UPDATE OF balance                   |
|                                     -post_commit_procedure bug #2957496    |
|     06/16/2003    S. Singhania    Added code TO LOCK entities BEFORE       |
|                                     updating EVENTS TABLE. PROCEDURE       |
|                                     modified : BATCH_ACCOUNTING            |
|                                   Modified THE CURSOR TO REF CURSOR IN     |
|                                     ENQUEUE_MESSAGES. included filters     |
|                                     based ON xla_events.                   |
|     06/17/2003    S. Singhania    Changed THE NAME OF THE VIEW used        |
|                                     XLA_EVENT_ENTITIES_V TO                |
|                                     XLA_ENTITY_EVENTS_V                    |
|     06/26/2003    S. Singhania    Bug fix FOR bug # 3022532. (TABLE NAME   |
|                                     changes.)                              |
|     07/05/2003    S. Singhania    Modified code 'spawn child' TO make sure |
|                                     children are NOT spawned IF there are  |
|                                     NO EVENTS TO process.                  |
|     07/17/2003    S. Singhania    Fix FOR Bug # 3051978. THE STATEMENT FOR |
|                                     UPDATE OF EVENTS IN 'complete_entries' |
|                                     IS modified.                           |
|     07/22/2003    S. Singhania    Removed THE USE OF CHR FROM THE code     |
|     07/29/2003    S. Singhania    NAME CHANGE FOR objects used IN THE queue|
|                                   Removed THE code that does PAD           |
|                                     incompatibility CHECK.                 |
|                                   Added code TO INSERT program LEVEL errors|
|                                     INTO xla_accounting_errors.            |
|                                   Commented OUT code IN xla_accounting_log |
|                                     routine.                               |
|                                   Added THE funtion IS_PARENT_RUNNING      |
|     07/30/2003    S. Singhania    Modified ACCOUNTING_PROGRAM_BATCH,       |
|                                     UNIT_PROCESSOR_BATCH TO RETURN THE     |
|                                     p_retcode = 1 IN CASE OF EVENTS IN     |
|                                     error (bug # 2709397)                  |
|     07/31/2003    S. Singhania    Added anonymous BLOCK around EXECUTE     |
|                                     IMMEDIATE calls.                       |
|     08/05/2003    S. Singhania    Added parameter P_ACCOUNTING_FLAG TO     |
|                                     ACCOUNTING_PROGRAM_DOCUMENT            |
|                                   Document MODE routines are rewritten.    |
|                                   Added code IN UNIT_PROCESSOR TO CHECK THE|
|                                     error count AND EXIT OUT OF THE LOOP   |
|                                     AND STOP processing.                   |
|     08/06/2003    S. Singhania    Correct PARAMETERS are passed TO THE     |
|                                     calls TO THE 'pre-processing procedure,|
|                                     'post-processing procedure' AND 'post- |
|                                      COMMIT PROCEDURE'.                    |
|     09/09/2003    S. Singhania    TO SET error SOURCE, changed THE CALL TO |
|                                     XLA_ACCOUNTING_ERR_PKG.SET_ERROR_SOURCE|
|     09/17/2003    S. Singhania    Performance changes (bug # 3118344)      |
|                                     - Modified ACCOUNTING_PROGRAM_BATCH TO |
|                                       build WHERE condition FOR dynamic SQL|
|                                       based ON security PARAMETERS AND     |
|                                       process CATEGORY code                |
|                                     - Modified BATCH_ACCOUNTING TO WRITE   |
|                                       dynamic SQL TO prevent NVL.          |
|                                     - Modified cursors IN ENQUEUE_MESSAGES |
|                                   Added filter FOR MANUAL EVENTS.          |
|     10/01/2003    S. Singhania    NOTE:THIS IS BASED ON xlaapeng.pkb 116.12|
|     10/01/2003    S. Singhania    Made SOURCE Application Changes.         |
|                                     (major REWRITE)                        |
|                                   Added semicolon TO THE EXIT STATEMENT.   |
|                                     (Bug # 3165900)                        |
|                                   Handle THE CASE WHEN Extract PROCEDURE IS|
|                                     NOT defined FOR an application.        |
|                                     (Bug # 3182763)                        |
|     10/15/2003    S. Singhania    Fix FOR bug # 2709397 TO SET THE correct |
|                                     request status.                        |
|                                     - FOR this defined AND used EXCEPTION  |
|                                       'normal_termination'                 |
|     10/31/2003    Shishir Joshi   Bug 3220355. Modified INSERT INTO THE    |
|                                     XLA_EVENTS_GT TABLE.                   |
|     11/18/2003    S. Singhania    Bug 3220355. Modified INSERT INTO THE    |
|                                     XLA_EVENTS_GT TABLE.                   |
|                                   Removed THE NOWAIT FROM THE FOR UPDATE   |
|                                     statements IN THE batch MODE.          |
|                                     (Bug # 2697222)                        |
|     11/19/2003    S. Singhania    Initilaized 'g_report_request_id' IN THE |
|                                     ACCOUNTING_PROGRAM_DOCUMENT so that THE|
|                                     EVENTS are stamped correctly WITH THE  |
|                                     request_id IN THE OFFLINE MODE.        |
|     11/24/2003    Shishir Joshi   Bug 3275659. Modified INSERT INTO THE    |
|                                     XLA_EVENTS_GT TABLE.                   |
|     11/24/2003    S. Singhania    Bug 3275659.                             |
|                                     - Modified INSERT INTO XLA_EVENTS_GT.  |
|                                     - Added 'p_report_request_id' param TO |
|                                       UNIT_PROCESSOR_BATCH                 |
|                                     - Modified SPAWN_CHILD_PROCESSES TO    |
|                                       included THE NEW parameter WHILE     |
|                                       submitting XLAACCUP.                 |
|     11/24/2003    S. Singhania    Bug 3239212.                             |
|                                     - Added more IF condition TO SET OUT   |
|                                       variables IN ACCOUNTING_PROGRAM_BATCH|
|                                     - Added two OUT PARAMETERS TO routnie  |
|                                       WAIT_FOR_REQUESTS                    |
|     12/19/2003    S. Singhania    Added calls TO sequencing apis FOR THE   |
|                                     batch MODE.  Bug 3000020.              |
|                                     - modified specs UNIT_PROCESSOR_BATCH  |
|                                     - added routine SEQUENCING_BATCH_INIT  |
|                                     - added calls TO sequencing apis IN    |
|                                         - POST_ACCOUNTING                  |
|                                         - COMPLETE_ENTRIES                 |
|                                   moved COMMIT down AFTER CALL TO THE      |
|                                     pre-processing PROCEDURE               |
|     12/19/2003    S. Singhania    Modified THE CURSOR's where clause in    |
|                                     ENQUEUE_MESSAGES. Bug 3327641          |
|     01/12/2004    S. Singhania    Bug # 3365680. Added hint TO THE UPDATE  |
|                                     STATEMENT so that INDEX XLA_EVENTS_U1  |
|                                     IS always used.                        |
|     01/26/2004    W. Shen         Bug # 3339505. replace THE program hook  |
|                                     WITH workflow business event.          |
|     02/13/2004    S. Singhania    FIXED NOCOPY warnings.                   |
|     02/28/2004    S. Singhania    Bug 3416534. Added FND_LOG messages.     |
|     03/23/2004    S. Singhania    Added a parameter p_module TO THE TRACE  |
|                                     calls AND THE PROCEDURE.               |
|                                   Made changes FOR handling THE accounting |
|                                     OF THE gapless EVENTS. Ffg modified:   |
|                                     - PRE_ACCOUNTING                       |
|                                     - DOCUMENT_PROCESSOR                   |
|     03/26/2004    S. Singhania    Bug 3498491. Added CLEAR messages, WHERE |
|                                     ever possible, TO make sure IF there IS|
|                                     an EXCEPTION a CLEAR message IS given  |
|                                     IN THE log FILE.                       |
|     04/28/2004    S. Singhania    Cleaned THE FILE, removed commented  code|
|     05/05/2004    S. Singhania    Made changes TO CALL THE NEW api FOR     |
|                                     balance UPDATE/reversal.               |
|                                   Verified that ALL THE workflow EVENTS are|
|                                     raised IN FINAL AND DRAFT modes.       |
|                                   Document MODE accounting:                |
|                                     - Reviewed THE code path               |
|                                     - Verified CALL TO THE workflows EVENTS|
|                                     - Verified CALL TO THE Sequencing apis |
|     07/15/2004    W. Shen         NEW event status 'R' introduced.         |
|     08/03/2004    S. Singhania    Bug 3808349.                             |
|                                     Modified THE code that build THE string|
|                                     g_security_condition TO USE THE COLUMN |
|                                     'valuation_method'                     |
|     09/28/2004    K. Boussema    Modified procedures TO cleanup Accounting |
|                                  Event Extract Diagnostics data:           |
|                                      - delete_request_je() AND             |
|                                      - delete_transaction_je()             |
|     12/08/2004    K. Boussema    Renamed THE diagnostic framework TABLES:  |
|                                  - xla_extract_events BY xla_diag_events   |
|                                  - xla_extract_ledgers BY xla_diag_ledgers |
|                                  - xla_extract_sources BY xla_diag_sources |
|     01/04/2005    S. Singhania   Bug 3928357. g_total_error_Count IS SET TO|
|                                    have THE right value IN document MODE   |
|                                    API.                                    |
|                                  Bug 3571389. Made changes TO refer TO THE |
|                                    XLA_ACCTOUNTING_QTAB queue TABLE IN XLA |
|                                     SCHEMA.                                |
|                                    Made changes TO refer TO THE TYPE       |
|                                     XLA_QUEUE_MSG_TYPE IN APPS SCHEMA      |
|     01/04/2005    S. Singhania   Bug 4364612. WHILE loading xla_events_gt, |
|                                     valuation method COLUMN IS populated.  |
|     05/27/2005    V. Kumar       Bug 4339454 Added handle_accounting_hook  |
|                                     procedure to replace business event by |
|                                     APIS in accounting program             |
|     01/06/2005    W. Shen        Modify insert into xla_events_gt to insert|
|                                     transaction_date                       |
|     06/06/2005    M. Asada       Bug 4259032 Processing Unit Enhancement   |
|     14/06/2005    V. Swapna      Bug 4426342 Enabled business events for   |
|                                     all products                           |
|     15/06/2005    V. Swapna      Bug 3071916 Made changes to call balance  |
|                                     calculation routine only if there are  |
|                                     valid entries                          |
|     06/24/2005    S. Singhania   Bug 3443872. Added code to set security   |
|                                     context in unit_processor_batch for    |
|                                     child threads (XLAACCUP)               |
|     06/30/2005    V. Kumar       Bug 4459117 Added Cash Management in      |
|                                     handle_accounting_hooks                |
|     07/11/2005    A. Wan         Bug 4262811 MPA Project                   |
|     08/01/2005    W. Chan        4458381 - Public Sector Enhancement       |
|     09/12/2005    V.Swapna       4599690 - Added Process Manufacturing     |
|                                  Financials to handle_accounting_hooks     |
|     09/14/2005    W.Chan         4606566 - Pass budgetary_control_mode to  |
|                                  AP hook if calling for BC mode            |
|     10/12/2005    A.Wan          4645092 - MPA report changes              |
|     18-Oct-2005   V. Kumar       Removed code for Analytical Criteria      |
|     28-Oct-2005   W. Shen        Third party merge, add logic to prevent   |
|                                    third party merge event been processed  |
|                                  here                                      |
|     07-Nov-2005   S. Singhania   Modofied event_application_manager to     |
|                                    print accounting, transfer time in log  |
|     16-Nov-2005   Shishir Joshi  Bug #4677032. Performance Improvement.    |
|     17-Nov-2005   V. Kumar       Bug#4736699 Added hint for performance    |
|     23-Nov-2005   V. Kumar       Bug#4752936 Added join on  application_id |
|     30-Nov-2005   V.Swapna       4745309 - Added Payroll                   |
|                                    to handle_accounting_hooks              |
|     30-Nov-2005   V. Kumar       Bug#4769388/4769270 Added hints           |
|     12-Dec-2005   S. Singhania   Bug 4883192. Modified the delete statement|
|                                    that deletes from xla_distribution_links|
|     14-Dec-2005   V. Kumar       Bug#4727703 Added condition to avoid unne-|
|                                   -cessary execution of DELETE statements  |
|     29-Dec-2005   V. Kumar       Bug#4879954 Added hint for performance    |
|     12-Jan-2006   V. Kumar       Modified the logic to call GL transfer API|
|                                  within child thread when transfer mode is |
|                                  COMBINED (accounting and transfering to GL|
|     01-Feb-2006   V. Swapna      Bug 4963736: Modified the call to         |
|                                  event_application_manager                 |
|     10-Feb-2006   A.Wan          Bug 4670097 - budgetary control='N'       |
|     12-Feb-2006   A.Wan          4860037 - anytime process order issue     |
|     17-Feb-2006   V.Kumar        5034929 - Modified Cursor csr_event_class |
|     23-Feb-2006   V.Kumar        5056659 - Changed date mask to HH24:MI:SS |
|     02-Mar-2006   V. Swapna      Bug 5018098: Added an exception to handle |
|                                  no data found error in batch_accounting   |
|     19-Apr-2006   A.Wan          Bug 5149363 - performance fix             |
|     20-Apr-2006   A.Wan          Bug 5054831 - duplicate entires           |
|     11-May-2006   A.Wan          Bug 5221578 - log message is too long     |
|     08/31/2006    V. Swapna      Bug: 5257343. Add a new parameter to      |
|                                  unit_processor_batch, also, add this in   |
|                                  the call to submit the child program.     |
|     14-Sep-2006   A.Wan          Bug 5531502 - AAD_dbase_invalid need to   |
|                                  check if it is called in BC mode.  If so  |
|                                  then validate for _BC_PKG, else _PKG.     |
|     13-Oct-2009   VGOPISET       bug:8423174 UNIT_PROCESSOR cursor changed |
|                                  to exclude budgetary events               |
|     13-JUN-2012   VKANTETI       bug:14105024 To eliminate the duplicates  |
|                                  while building event classes list         |
|     17-JUL-2012   NMIKKILI	   Bug 14307411 Codefix to support new       |
|                                  costing security function                 |
+===========================================================================*/

--=============================================================================
--           ****************  declarations  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring private constants and structures
-------------------------------------------------------------------------------
C_QUEUE_TABLE         CONSTANT VARCHAR2(30) := 'xla_accounting_qtab';
C_CHAR                CONSTANT VARCHAR2(30) := '##UNDEFINED##'; -- CHR(12);
C_NUM                 CONSTANT NUMBER       := 9.99E125;

C_BATCH_PROGRAM       CONSTANT VARCHAR2(80) := 'Batch Accounting Program';
C_UNIT_PROCESSOR      CONSTANT VARCHAR2(80) := 'Unit Processor';
C_MANUAL              CONSTANT VARCHAR2(30) := 'MANUAL';

------------------------------------------------------------------------
-- 4597150 Process Event
------------------------------------------------------------------------
C_DELIMITER           CONSTANT VARCHAR2(30)    := '#-#-#-#-#-#-#-#';
C_COMMA               CONSTANT VARCHAR2(30)    := ''',''';
C_QUOTE               CONSTANT VARCHAR2(30)    := '''';

-- 8423174 added join on BUDGETARY CONTROL FLAG to exclude Budgetary Events
C_LOCK_EVENTS_STR     CONSTANT VARCHAR2(32000) :=
'
      SELECT /*+ leading(tab,evt) use_nl(evt) */
             evt.event_id
        FROM xla_events                 evt
            ,xla_event_types_b          xet
            ,TABLE(CAST(:1 AS xla_array_number_type))    tab
       WHERE evt.application_id        = :2
         AND evt.event_date           <= :3
         AND evt.entity_id             = tab.column_value
         AND evt.application_id        = xet.application_id
         AND evt.event_type_code       = xet.event_type_code
         AND xet.event_class_code     IN ($event_classes$)
         AND evt.event_type_code  NOT IN (''FULL_MERGE'', ''PARTIAL_MERGE'')
         AND evt.process_status_code  IN (''U'',''D'',''E'',''R'',''I'')
         AND evt.event_status_code    IN (''U'', DECODE(:4, ''F'',''N'',''U''))
	 AND nvl(evt.budgetary_control_flag,    ''N'') = ''N'' -- bug:8423174
FOR UPDATE OF evt.event_id skip locked
';

-- 8423174 added join on BUDGETARY CONTROL FLAG to exclude Budgetary Events
C_CURR_INS_EVENTS     CONSTANT VARCHAR2(32000) := '
       INSERT INTO xla_events_gt
             (entity_id
             ,application_id
             ,ledger_id
             ,legal_entity_id
             ,entity_code
             ,transaction_number
             ,source_id_int_1
             ,source_id_int_2
             ,source_id_int_3
             ,source_id_int_4
             ,source_id_char_1
             ,source_id_char_2
             ,source_id_char_3
             ,source_id_char_4
             ,event_id
             ,event_class_code
             ,event_type_code
             ,event_number
             ,event_date
             ,transaction_date
             ,event_status_code
             ,process_status_code
             ,valuation_method
             ,budgetary_control_flag
             ,reference_num_1
             ,reference_num_2
             ,reference_num_3
             ,reference_num_4
             ,reference_char_1
             ,reference_char_2
             ,reference_char_3
             ,reference_char_4
             ,reference_date_1
             ,reference_date_2
             ,reference_date_3
             ,reference_date_4)
       SELECT /*+ LEADING(EVT,XET,ENT,ECA) USE_NL(EVT,XET,ENT,ECA) */
              evt.entity_id
             ,evt.application_id
             ,ent.ledger_id
             ,ent.legal_entity_id
             ,ent.entity_code
             ,ent.transaction_number
             ,ent.source_id_int_1
             ,ent.source_id_int_2
             ,ent.source_id_int_3
             ,ent.source_id_int_4
             ,ent.source_id_char_1
             ,ent.source_id_char_2
             ,ent.source_id_char_3
             ,ent.source_id_char_4
             ,evt.event_id
             ,xet.event_class_code
             ,evt.event_type_code
             ,evt.event_number
             ,evt.event_date
             ,evt.transaction_date
             ,evt.event_status_code
             ,evt.process_status_code
             ,ent.valuation_method
             ,NVL(evt.budgetary_control_flag,''N'')
             ,evt.reference_num_1
             ,evt.reference_num_2
             ,evt.reference_num_3
             ,evt.reference_num_4
             ,evt.reference_char_1
             ,evt.reference_char_2
             ,evt.reference_char_3
             ,evt.reference_char_4
             ,evt.reference_date_1
             ,evt.reference_date_2
             ,evt.reference_date_3
             ,evt.reference_date_4
        FROM xla_events                 evt
            ,xla_transaction_entities   ent
            ,xla_event_types_b          xet
            ,xla_event_class_attrs      eca
       WHERE evt.application_id        = :1
         AND evt.event_date           <= :2
         AND evt.event_id              = :3
         AND evt.application_id        = ent.application_id
         AND evt.entity_id             = ent.entity_id
         AND evt.application_id        = xet.application_id
         AND evt.event_type_code       = xet.event_type_code
         AND eca.application_id        = xet.application_id
         AND eca.entity_code           = xet.entity_code
         AND eca.event_class_code      = xet.event_class_code
         AND xet.event_class_code IN ($event_classes$)
         AND evt.event_type_code NOT IN (''FULL_MERGE'', ''PARTIAL_MERGE'')
         AND evt.process_status_code  IN (''U'',''D'',''E'',''R'',''I'')
         AND evt.event_status_code IN
            (''U'', DECODE(:4, ''F'',''N'',''U''))
	 AND nvl(evt.budgetary_control_flag,    ''N'') = ''N'' -- bug:8423174
';

--
--      Unprocessed Event Number of Process Order -1 must be lower than
--  those of all Process Order higher than the current Process Order.
--
-- 8423174 added join on BUDGETARY CONTROL FLAG to exclude Budgetary Events
C_ANYTIME_INS_EVENTS  CONSTANT VARCHAR2(32000) := '
       INSERT INTO xla_events_gt
             (entity_id
             ,application_id
             ,ledger_id
             ,legal_entity_id
             ,entity_code
             ,transaction_number
             ,source_id_int_1
             ,source_id_int_2
             ,source_id_int_3
             ,source_id_int_4
             ,source_id_char_1
             ,source_id_char_2
             ,source_id_char_3
             ,source_id_char_4
             ,event_id
             ,event_class_code
             ,event_type_code
             ,event_number
             ,event_date
             ,transaction_date
             ,event_status_code
             ,process_status_code
             ,valuation_method
             ,budgetary_control_flag
             ,reference_num_1
             ,reference_num_2
             ,reference_num_3
             ,reference_num_4
             ,reference_char_1
             ,reference_char_2
             ,reference_char_3
             ,reference_char_4
             ,reference_date_1
             ,reference_date_2
             ,reference_date_3
             ,reference_date_4)
       SELECT /*+ LEADING(EVT,XET,ENT,ECA) USE_NL(EVT,XET,ENT,ECA) */
              evt.entity_id
             ,evt.application_id
             ,ent.ledger_id
             ,ent.legal_entity_id
             ,ent.entity_code
             ,ent.transaction_number
             ,ent.source_id_int_1
             ,ent.source_id_int_2
             ,ent.source_id_int_3
             ,ent.source_id_int_4
             ,ent.source_id_char_1
             ,ent.source_id_char_2
             ,ent.source_id_char_3
             ,ent.source_id_char_4
             ,evt.event_id
             ,xet.event_class_code
             ,evt.event_type_code
             ,evt.event_number
             ,evt.event_date
             ,evt.transaction_date
             ,evt.event_status_code
             ,evt.process_status_code
             ,ent.valuation_method
             ,NVL(evt.budgetary_control_flag,''N'')
             ,evt.reference_num_1
             ,evt.reference_num_2
             ,evt.reference_num_3
             ,evt.reference_num_4
             ,evt.reference_char_1
             ,evt.reference_char_2
             ,evt.reference_char_3
             ,evt.reference_char_4
             ,evt.reference_date_1
             ,evt.reference_date_2
             ,evt.reference_date_3
             ,evt.reference_date_4
         FROM xla_events                evt
             ,xla_transaction_entities  ent
             ,xla_event_types_b         xet
             ,xla_event_class_attrs     eca
        WHERE evt.application_id        = :1
          AND evt.event_date           <= :2
          AND evt.event_id              = :3
          AND evt.application_id        = ent.application_id
          AND evt.entity_id             = ent.entity_id
          AND evt.application_id        = xet.application_id
          AND evt.event_type_code       = xet.event_type_code
          AND eca.application_id        = xet.application_id
          AND eca.entity_code           = xet.entity_code
          AND eca.event_class_code      = xet.event_class_code
          AND xet.event_class_code IN ($event_classes$)
          AND evt.event_type_code NOT IN (''FULL_MERGE'', ''PARTIAL_MERGE'')
          AND evt.process_status_code  IN (''U'',''D'',''E'',''R'',''I'')
	  AND nvl(evt.budgetary_control_flag,    ''N'') = ''N'' -- bug:8423174
          AND evt.event_status_code IN
            (''U'', DECODE(:4, ''F'',''N'',''U''))
          AND evt.event_number <
                 (SELECT NVL(MIN(evt2.event_number), evt.event_number + 1)
                    FROM xla_events                    evt2
                        ,xla_transaction_entities_upg  ent2
                        ,xla_event_types_b             xet2
                        ,xla_event_class_attrs         eca2
                   WHERE evt2.application_id        = evt.application_id
                     AND evt2.entity_id             = evt.entity_id
                     AND evt2.event_date            = :5
                     AND evt2.application_id        = ent2.application_id
                     AND evt2.entity_id             = ent2.entity_id
                     AND evt2.application_id        = xet2.application_id
                     AND evt2.event_type_code       = xet2.event_type_code
                     AND eca2.application_id        = xet2.application_id
                     AND eca2.entity_code           = xet2.entity_code
                     AND eca2.event_class_code      = xet2.event_class_code
                     AND xet2.event_class_code NOT IN ($event_class_current_order$)
                     AND xet2.event_class_code NOT IN ($event_class_anytime_order$)
                     AND evt2.event_type_code  NOT IN (''FULL_MERGE'', ''PARTIAL_MERGE'')
                     AND evt2.process_status_code  IN (''U'',''D'',''E'',''R'',''I'')
                     AND evt2.event_status_code IN
                       (''U'', DECODE(:6, ''F'',''N'',''U''))
                 )
';
------------------------------------------------------------------------


TYPE r_parent_data IS RECORD
   (total_entity_count             NUMBER
   ,enqueued_msg_count             NUMBER);

TYPE r_child_data IS RECORD
   (selected_entity_count          NUMBER
   ,dequeued_msg_count             NUMBER
   ,selected_event_count           NUMBER);

TYPE t_array_char_code IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
TYPE t_array_char      IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
TYPE t_array_char_ext  IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE t_array_date      IS TABLE OF DATE          INDEX BY BINARY_INTEGER;
TYPE t_array_integer   IS TABLE OF INTEGER       INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- declaring named exceptions
-------------------------------------------------------------------------------
normal_termination     EXCEPTION;
resource_busy          EXCEPTION;
PRAGMA EXCEPTION_INIT(resource_busy, -54);

-------------------------------------------------------------------------------
-- declaring private variables
-------------------------------------------------------------------------------
g_accounting_batch_id          PLS_INTEGER;
g_queue_table_name             VARCHAR2(80);
g_xla_schema_name              VARCHAR2(30);
g_queue_name                   VARCHAR2(30);
g_comp_queue_name              VARCHAR2(30);
g_ledger_ids                   xla_accounting_pkg.t_array_number;
g_process_count                PLS_INTEGER;
g_ep_request_ids               xla_accounting_pkg.t_array_number;
g_ep_reqid                     PLS_INTEGER;
g_unit_size                    PLS_INTEGER;
g_error_limit                  PLS_INTEGER;
g_seq_enabled_flag             VARCHAR2(1);
g_global_context               VARCHAR2(30);
g_conc_hold                    VARCHAR2(1);

g_current_entity_id            NUMBER;  -- 8761772
g_failed_event_id              NUMBER;  -- 8761772
g_processing_mode              VARCHAR2(30);
g_execution_mode               VARCHAR2(10);
g_budgetary_control_mode       VARCHAR2(30); -- 4458381

g_total_error_count            NUMBER         := 0; -- This is used by parent thread to set request status
g_parent_data                  r_parent_data;
g_child_data                   r_child_data;

-- Bug 8282549
g_queue_created_flag              VARCHAR2(1) :='N';
g_queue_started_flag              VARCHAR2(1) :='N';


-------------------------------------------------------------------------------
-- forward declarion of private procedures and functions
-------------------------------------------------------------------------------
--PROCEDURE accounting_manager_batch;

PROCEDURE batch_accounting;

PROCEDURE enqueue_messages
(p_processing_order           INTEGER
,p_max_processing_order       INTEGER
,p_children_spawned           IN OUT NOCOPY BOOLEAN
,p_msg_count                  IN OUT NOCOPY INTEGER);

PROCEDURE process_events;

-- 5054831
FUNCTION  AAD_dbase_invalid(p_pad_name  IN VARCHAR2,p_ledger_category_code IN VARCHAR2,p_enable_bc_flag IN VARCHAR2) return BOOLEAN;
PROCEDURE ValidateAAD(p_array_event_dates  IN t_array_date);

PROCEDURE ValidateAAD
       (p_max_event_date             IN  DATE);


PROCEDURE unit_processor;

PROCEDURE complete_entries;

PROCEDURE wait_for_requests
       (p_array_request_id           IN  t_array_number
       ,p_error_status               OUT NOCOPY VARCHAR2
       ,p_warning_status             OUT NOCOPY VARCHAR2);

 --FSAH-PSFT FP
 PROCEDURE wait_for_combo_edit_req
	 (p_request_id                 IN  NUMBER
	 ,p_error_status               OUT NOCOPY VARCHAR2
	 ,p_warning_status             OUT NOCOPY VARCHAR2);


FUNCTION is_any_child_running
RETURN BOOLEAN;

FUNCTION is_parent_running
RETURN BOOLEAN;

PROCEDURE events_processor(l_processing_order IN NUMBER);    -- bug 7193986

PROCEDURE delete_batch_je;

PROCEDURE delete_request_je;

/*
PROCEDURE document_processor
       (p_entity_id                  IN NUMBER);

PROCEDURE delete_transaction_je
       (p_entity_id                  IN NUMBER);
*/

PROCEDURE spawn_child_processes;

PROCEDURE pre_accounting;

PROCEDURE post_accounting
       (p_queue_started_flag         IN OUT NOCOPY VARCHAR2
       ,p_queue_created_flag         IN OUT NOCOPY VARCHAR2
       ,p_seq_api_called_flag        IN OUT NOCOPY VARCHAR2);

PROCEDURE event_application_manager
       (p_source_application_id      IN  NUMBER
       ,p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_process_category           IN  VARCHAR2
       ,p_end_date                   IN  DATE
       ,p_accounting_flag            IN  VARCHAR2
       ,p_accounting_mode            IN  VARCHAR2
       ,p_error_only_flag            IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2
       ,p_valuation_method           IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2);

PROCEDURE sequencing_batch_init
       (p_seq_enabled_flag           IN OUT NOCOPY VARCHAR2);

PROCEDURE raise_accounting_event
       (p_application_id             IN NUMBER
       ,p_ledger_id                  IN NUMBER
       ,p_process_category           IN VARCHAR2
       ,p_end_date                   IN DATE
       ,p_accounting_mode            IN VARCHAR2
       ,p_valuation_method           IN VARCHAR2
       ,p_security_id_int_1          IN NUMBER
       ,p_security_id_int_2          IN NUMBER
       ,p_security_id_int_3          IN NUMBER
       ,p_security_id_char_1         IN VARCHAR2
       ,p_security_id_char_2         IN VARCHAR2
       ,p_security_id_char_3         IN VARCHAR2
       ,p_report_request_id          IN NUMBER
       ,p_event_name                 IN VARCHAR2
       ,p_event_key                  IN VARCHAR2);

PROCEDURE raise_unit_event
       (p_application_id             IN NUMBER
       ,p_accounting_mode            IN VARCHAR2
       ,p_event_name                 IN VARCHAR2
       ,p_event_key                  IN VARCHAR2);

PROCEDURE handle_accounting_hook
       (p_application_id             IN NUMBER
       ,p_ledger_id                  IN NUMBER
       ,p_process_category           IN VARCHAR2
       ,p_end_date                   IN DATE
       ,p_accounting_mode            IN VARCHAR2
       ,p_budgetary_control_mode     IN VARCHAR2
       ,p_valuation_method           IN VARCHAR2
       ,p_security_id_int_1          IN NUMBER
       ,p_security_id_int_2          IN NUMBER
       ,p_security_id_int_3          IN NUMBER
       ,p_security_id_char_1         IN VARCHAR2
       ,p_security_id_char_2         IN VARCHAR2
       ,p_security_id_char_3         IN VARCHAR2
       ,p_report_request_id          IN NUMBER
       ,p_event_name                 IN VARCHAR2
       ,p_event_key                  IN VARCHAR2);

FUNCTION concat_event_classes
      (p_processing_order            IN NUMBER)
RETURN VARCHAR2;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_accounting_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

C_LOG_SIZE            CONSTANT NUMBER          := 2000;  -- 5221578  actual size is 4000, but maybe too long to be readable

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS

l_max  NUMBER;
l_pos  NUMBER := 1;

BEGIN

   l_pos := 1;

   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN

      l_max := length(p_msg);
      IF l_max <= C_LOG_SIZE THEN
         fnd_log.string(p_level, p_module, p_msg);
      ELSE
         -- 5221578 log messages in C_LOG_SIZE
         WHILE (l_pos-1)*C_LOG_SIZE <= l_max LOOP
             fnd_log.string(p_level, p_module, substr(p_msg, (l_pos-1)*C_LOG_SIZE+1, C_LOG_SIZE));
             l_pos := l_pos+1;
         END LOOP;
      END IF;
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_accounting_pkg.trace');
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
         (p_location   => 'xla_accounting_pkg.print_logfile');
END print_logfile;


--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following routines are used while accounting for a batch of documents
--
--    1.    accounting_program_batch    (procedure)
--    2.    event_application_cp        (conc executible procedure)
--    3.    event_application_manager
--    4.    unit_processor_batch        (conc executible procedure)
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE accounting_program_batch
       (p_source_application_id      IN  NUMBER
       ,p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_process_category           IN  VARCHAR2
       ,p_end_date                   IN  DATE
       ,p_accounting_flag            IN  VARCHAR2
       ,p_accounting_mode            IN  VARCHAR2
       ,p_error_only_flag            IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2
       ,p_valuation_method           IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER) IS
l_array_event_appl_id             xla_number_array_type;
l_array_request_id                t_array_number;
l_array_mpa_request_id            t_array_number;
l_mpa_request_id                  NUMBER(10);
l_xml_output                      BOOLEAN;
l_str_event_application           VARCHAR2(2000);
l_error_status                    VARCHAR2(1) := 'N';
l_warning_status                  VARCHAR2(1) := 'N';
l_log_module                      VARCHAR2(240);
l_xla_val_ccid_req_id             NUMBER(10); -- FSAH-PSFT FP
l_iso_language                    FND_LANGUAGES.iso_language%TYPE;
l_iso_territory                   FND_LANGUAGES.iso_territory%TYPE;
l_code                            NUMBER; -- FSAH-PSFT FP
BEGIN
   --
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Starting of the Parent Thread');

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.accounting_program_batch';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure ACCOUNTING_PROGRAM_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_application_id = '||to_char(p_source_application_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||to_char(p_application_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_process_category = '||p_process_category
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_end_date = '||to_char(p_end_date,'DD-MON-YYYY')
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_flag = '||p_accounting_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_error_only_flag = '||p_error_only_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transfer_flag = '||p_transfer_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_gl_posting_flag = '||p_gl_posting_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_gl_batch_name = '||p_gl_batch_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_1 = '||p_security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_1 = '||p_security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_3 = '||p_security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_1 = '||p_security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_2 = '||p_security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_3 = '||p_security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


   print_logfile('Starting main program for the source application = '||p_source_application_id);

   g_report_request_id := fnd_global.conc_request_id();

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_report_request_id = '||g_report_request_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Making sure at leat source application or event application is passed
   -- This condition should never arise, as it should be validated in the
   -- request parameters.
   ----------------------------------------------------------------------------
   IF ((p_source_application_id IS NULL) AND (p_application_id IS NULL)) THEN
      xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'LOCATION'
            ,p_value_1        => 'xla_accounting_pkg.accounting_program_batch'
            ,p_token_2        => 'ERROR'
            ,p_value_2        => 'Source application and event application both cannot be NULL');
   END IF;

   ----------------------------------------------------------------------------
   -- Fetching Accounting Batch Id
   ----------------------------------------------------------------------------
   SELECT xla_accounting_batches_s.NEXTVAL INTO g_accounting_batch_id FROM DUAL;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_accounting_batch_id = '||g_accounting_batch_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Initializing errors package
   ----------------------------------------------------------------------------
   xla_accounting_err_pkg.set_options
      (p_error_source     => xla_accounting_err_pkg.C_ACCT_PROGRAM
      ,p_request_id       => g_report_request_id
      ,p_application_id   => p_application_id);

   ----------------------------------------------------------------------------
   -- Building filter condition based on security columns and valuation method
   -- This condition will be added dynamically to select statemtents.
   ----------------------------------------------------------------------------
   SELECT
   DECODE(p_valuation_method,NULL,NULL,'and valuation_method = '''||p_valuation_method||''' ')||
   --DECODE(p_security_id_int_1,NULL,NULL,'and security_id_int_1 = '||p_security_id_int_1||' ')|| --14307411
   DECODE(p_security_id_int_1,NULL,NULL
                                   ,DECODE(p_application_id,707, 'and NVL(security_id_int_1,'||p_security_id_int_1||') = '||p_security_id_int_1||' ',
                                                                  'and security_id_int_1 = '||p_security_id_int_1||' '))||   --14307411
   DECODE(p_security_id_int_2,NULL,NULL,'and security_id_int_2 = '||p_security_id_int_2||' ')||
   DECODE(p_security_id_int_3,NULL,NULL,'and security_id_int_3 = '||p_security_id_int_3||' ')||
   DECODE(p_security_id_char_1,NULL,NULL,'and security_id_char_1 = '''||p_security_id_char_1||''' ')||
   DECODE(p_security_id_char_2,NULL,NULL,'and security_id_char_2 = '''||p_security_id_char_2||''' ')||
   DECODE(p_security_id_char_3,NULL,NULL,'and security_id_char_3 = '''||p_security_id_char_3||''' ')
   INTO g_security_condition
   FROM DUAL;

   ----------------------------------------------------------------------------
   -- Building filter condition based process_category.
   -- This condition will be added dynamically to select statemtents.
   ----------------------------------------------------------------------------
   SELECT
   DECODE(p_process_category,NULL,NULL,'and event_class_group_code = '''||p_process_category||'''')
   INTO g_process_category_condition
   FROM DUAL;

   ----------------------------------------------------------------------------
   -- Building filter condition based on source_application_id.
   ----------------------------------------------------------------------------
   SELECT
   DECODE(p_source_application_id,NULL,NULL,'and source_application_id = '||p_source_application_id)
   INTO g_source_appl_condition
   FROM DUAL;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_security_condition = '||g_security_condition
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_process_category_condition = '||g_process_category_condition
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_source_appl_condition = '||g_source_appl_condition
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Dynamic conditions built');

   ----------------------------------------------------------------------------
   -- Finding Event Applications.
   ----------------------------------------------------------------------------

   IF p_application_id IS NOT NULL THEN
      l_array_event_appl_id := xla_number_array_type(p_application_id);
   ELSIF p_application_id IS NULL THEN
      l_str_event_application :=
         'SELECT application_id
            FROM xla_entity_events_v
           WHERE source_application_id           = :2
             AND ledger_id                       = :3
             AND event_date                     <= :4
             AND process_status_code             IN (''R'',''I'',''E'',DECODE(:5,''N'',''D'',''E'')
                                                                ,DECODE(:6,''N'',''U'',''E'')
                                                    )
             AND event_status_code               IN (''U'',DECODE(:7,''F'',''N'',''U''))
             AND entity_code                     <> '''||C_MANUAL||'''
             AND NVL(budgetary_control_flag,''N'') = ''N'' '||
             g_security_condition||' '||
             g_process_category_condition||' '||
             'GROUP BY application_id';

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'l_str_event_application = '||l_str_event_application
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      EXECUTE IMMEDIATE l_str_event_application
        BULK COLLECT INTO l_array_event_appl_id
        USING p_source_application_id
             ,p_ledger_id
             ,p_end_Date
             ,p_error_only_flag
             ,p_error_only_flag
             ,p_accounting_mode;
   END IF;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Event Applications Determined');
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of Event Applications = '||l_array_event_appl_id.COUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF l_array_event_appl_id.COUNT = 0 THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'No event applications fetched for the source application. '||
                           'There are no events to process in this run.'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;
      xla_accounting_err_pkg.build_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_NO_EVENT_TO_PROCESS'
         ,p_entity_id      => NULL
         ,p_event_id       => NULL);

      print_logfile('Technical warning : There are no events to process.');

      -------------------------------------------------------------------------
      -- Following exception is added to make sure the request ends normal when
      -- no event is found to process for the given criteria.
      -- bug # 2709397
      -------------------------------------------------------------------------
      RAISE normal_termination;
   ELSIF l_array_event_appl_id.COUNT = 1 THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Processing event application = '||l_array_event_appl_id(1)
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

    event_application_manager
         (p_source_application_id      => p_source_application_id
         ,p_application_id             => l_array_event_appl_id(1)
         ,p_ledger_id                  => p_ledger_id
         ,p_process_category           => p_process_category
         ,p_end_date                   => p_end_date
         ,p_accounting_flag            => p_accounting_flag
         ,p_accounting_mode            => p_accounting_mode
         ,p_error_only_flag            => p_error_only_flag
         ,p_transfer_flag              => p_transfer_flag
         ,p_gl_posting_flag            => p_gl_posting_flag
         ,p_gl_batch_name              => p_gl_batch_name
         ,p_valuation_method           => p_valuation_method
         ,p_security_id_int_1          => p_security_id_int_1
         ,p_security_id_int_2          => p_security_id_int_2
         ,p_security_id_int_3          => p_security_id_int_3
         ,p_security_id_char_1         => p_security_id_char_1
         ,p_security_id_char_2         => p_security_id_char_2
         ,p_security_id_char_3         => p_security_id_char_3);


   ELSE

      FOR i IN 1..l_array_event_appl_id.COUNT LOOP
         l_array_request_id(i) :=
            fnd_request.submit_request
               (application     => 'XLA'
               ,program         => 'XLAACCEA'
               ,description     => NULL
               ,start_time      => NULL
               ,sub_request     => FALSE
               ,argument1       => p_source_application_id
               ,argument2       => l_array_event_appl_id(i)
               ,argument3       => p_ledger_id
               ,argument4       => p_process_category
               ,argument5       => p_end_date
               ,argument6       => p_accounting_flag
               ,argument7       => p_accounting_mode
               ,argument8       => p_error_only_flag
               ,argument9       => p_transfer_flag
               ,argument10      => p_gl_posting_flag
               ,argument11      => p_gl_batch_name
               ,argument12      => g_accounting_batch_id
               ,argument13      => g_report_request_id
               ,argument14      => p_valuation_method
               ,argument15      => p_security_id_int_1
               ,argument16      => p_security_id_int_2
               ,argument17      => p_security_id_int_3
               ,argument18      => p_security_id_char_1
               ,argument19      => p_security_id_char_2
               ,argument20      => p_security_id_char_3);
         IF l_array_request_id(i) = 0 THEN
            xla_accounting_err_pkg.build_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
               ,p_token_1        => 'APPLICATION_NAME'
               ,p_value_1        => 'SLA'
               ,p_entity_id      => NULL
               ,p_event_id       => NULL);

            print_logfile('Technical Error : Unable to submit accounting program request for '||
                          'application '||l_array_event_appl_id(i));

            xla_exceptions_pkg.raise_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
               ,p_token_1        => 'APPLICATION_NAME'
               ,p_value_1        => 'SLA');
         END IF;
      END LOOP;


      IF (C_LEVEL_EVENT >= g_log_level) THEN
         FOR i IN 1 .. l_array_request_id.count LOOP
         trace
            (p_msg      => 'Submitted request '||l_array_request_id(i)||
                           'to process event application = '||l_array_event_appl_id(i)
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
         END LOOP;
      END IF;

      -------------------------------------------------------------------------
      -- Commit is required after fnd_request.submit_request
      -------------------------------------------------------------------------
      COMMIT;

      -------------------------------------------------------------------------
      -- wait for requests to complete
      -------------------------------------------------------------------------
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Waiting for Acct Prg - parent requests to complete.');
      wait_for_requests
         (p_array_request_id     => l_array_request_id
         ,p_error_status         => l_error_status
         ,p_warning_status       => l_warning_status);
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Monitoring of Acct Prg - parent requests completed.');
   END IF;


   --------------------------------------------------------
   -- 4645092 set request id for get_mpa_accrual_context
   --------------------------------------------------------
   dbms_session.set_identifier (client_id => g_report_request_id);
   IF xla_context_pkg.get_mpa_accrual_context = 'Y' THEN
      g_mpa_accrual_exists := 'Y';
   ELSE
      g_mpa_accrual_exists := 'N';
   END IF;
   --------------------------------------------------------

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('g_mpa_accrual_exists= '|| g_mpa_accrual_exists,
             C_LEVEL_STATEMENT,l_log_module);
   end if;

   IF NVL(g_mpa_accrual_exists,'N') = 'Y' THEN  -- 4645092

      SELECT lower(iso_language),iso_territory
      INTO   l_iso_language,l_iso_territory
      FROM   FND_LANGUAGES
      WHERE  language_code = USERENV('LANG');

      l_xml_output := fnd_request.add_layout(
                          'XLA', 'XLARPMPB'
                          ,l_iso_language, l_iso_territory, 'PDF');

      FOR i IN 1..l_array_event_appl_id.COUNT LOOP

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('p_source_application_id = '|| to_char(p_source_application_id),
                 C_LEVEL_STATEMENT,l_log_module);
          trace('p_application_id = '|| to_char(l_array_event_appl_id(i)),
                 C_LEVEL_STATEMENT,l_log_module);
          trace('p_ledger_id = '|| to_char(p_ledger_id),
                 C_LEVEL_STATEMENT,l_log_module);
          trace('p_process_category_code = '|| p_process_category,
                 C_LEVEL_STATEMENT,l_log_module);
          trace('p_create_accounting = '|| p_accounting_flag,
                 C_LEVEL_STATEMENT,l_log_module);
          trace('p_end_date = '|| to_char(p_end_date,'DD-MON-YYYY'),
                 C_LEVEL_STATEMENT,l_log_module);
          trace('p_accounting_mode = '|| p_accounting_mode,
                 C_LEVEL_STATEMENT,l_log_module);
          trace('p_errors_only_flag = '|| p_error_only_flag,
                 C_LEVEL_STATEMENT,l_log_module);
          trace('p_transfer_to_gl_flag = '|| p_transfer_flag,
                 C_LEVEL_STATEMENT,l_log_module);
          trace('p_post_in_gl_flag = '|| p_gl_posting_flag,
                 C_LEVEL_STATEMENT,l_log_module);
          trace('p_gl_batch_name = '|| p_gl_batch_name,
                 C_LEVEL_STATEMENT,l_log_module);
          trace('g_accounting_batch_id = '|| g_accounting_batch_id,
                 C_LEVEL_STATEMENT,l_log_module);
       END IF;

       l_array_mpa_request_id(i) := xla_mpa_accrual_rprtg_pkg.run_report
                                     (p_source_application_id
                                     ,l_array_event_appl_id(i)
                                     ,p_ledger_id
                                     ,p_process_category
                                     ,p_end_date
                                     ,p_accounting_flag
                                     ,p_accounting_mode
                                     ,p_error_only_flag
                                     ,p_transfer_flag
                                     ,p_gl_posting_flag
                                     ,p_gl_batch_name
                                     ,g_accounting_batch_id);


       IF l_array_mpa_request_id(i) = 0 THEN
          xla_accounting_err_pkg.build_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
               ,p_token_1        => 'APPLICATION_NAME'
               ,p_value_1        => 'SLA'
               ,p_entity_id      => NULL
               ,p_event_id       => NULL);

          print_logfile('Technical Error : '||
                'Unable to submit Subledger Multiperiod Accounting'||
                ' and Accrual Reversal Report request for '||
                'application '||l_array_event_appl_id(i));

          xla_exceptions_pkg.raise_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
               ,p_token_1        => 'APPLICATION_NAME'
               ,p_value_1        => 'SLA');
         END IF;

      END LOOP;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         FOR i IN 1 .. l_array_mpa_request_id.count LOOP
         trace
            (p_msg      => 'Submitted request '||l_array_mpa_request_id(i)||
                           'to process mpa report for application = '||
                           l_array_event_appl_id(i)
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
         END LOOP;
      END IF;

         -------------------------------------------------------------------------
      -- Commit is required after fnd_request.submit_request
      -------------------------------------------------------------------------
      COMMIT;

      -------------------------------------------------------------------------
      -- wait for requests to complete
      -------------------------------------------------------------------------
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH:MI:SS')||
           '- Waiting for MPA Prg - parent requests to complete.');
      wait_for_requests
         (p_array_request_id     => l_array_mpa_request_id
         ,p_error_status         => l_error_status
         ,p_warning_status       => l_warning_status);
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH:MI:SS')||
           ' - Monitoring of MPA Prg - parent requests completed.');

   END IF;

   --------------------------------------------------------
   -- 4645092 clear out MPA-Accrual flag
   --------------------------------------------------------
   xla_context_pkg.clear_mpa_accrual_context(p_client_id => g_report_request_id);

   ----------------------------------------------------------------------------
   -- insert any errors that were build in this session (for them to appear
   -- on the report).
   ----------------------------------------------------------------------------
   xla_accounting_err_pkg.insert_errors;


    -- FSAH-PSFT FP

	-- profile value XLA:Enable External Code Combination Validation

	    /* IF (  nvl(fnd_profile.value('XLA_FSAH_EXT_CCID_VAL'),'N') = 'Y') THEN

	     l_xla_val_ccid_req_id:= fnd_request.submit_request
				  (application     => 'XLA'
				  ,program         => 'XLACCIDVAL'
				  ,description     => NULL
				  ,start_time      => NULL
				  ,sub_request     => FALSE
				  ,argument1       => p_application_id
				  ,argument2       => g_accounting_batch_id
				  ,argument3       => p_ledger_id
				  ,argument4       => g_parent_request_id
				 );

		   IF l_xla_val_ccid_req_id = 0 THEN
			    xla_accounting_err_pkg.build_message
			       (p_appli_s_name   => 'XLA'
			       ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
			       ,p_token_1        => 'APPLICATION_NAME'
			       ,p_value_1        => 'SLA'
			       ,p_entity_id      => NULL
			       ,p_event_id       => NULL);

			    print_logfile('Technical Error : Unable to submit java
	  concurrent program request');

			    xla_exceptions_pkg.raise_message
			       (p_appli_s_name   => 'XLA'
			       ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
			       ,p_token_1        => 'APPLICATION_NAME'
			       ,p_value_1        => 'SLA');
		  END IF;

	      END IF; */
	--  FSAH-PSFT FP

   COMMIT;

    --FSAH-PSFT FP

  /*-------------------------------------------------------------------------
  -- wait for requests to complete
  -------------------------------------------------------------------------
	   print_logfile(to_char(sysdate,'DD-MON-YYYY HH:MI:SS')||
		'- Waiting for Combo Edit Validation - parent requests to complete.');
	   wait_for_combo_edit_req
	      (p_request_id           => l_xla_val_ccid_req_id
	      ,p_error_status         => l_error_status
	      ,p_warning_status       => l_warning_status);
	   print_logfile(to_char(sysdate,'DD-MON-YYYY HH:MI:SS')||
	     ' - Monitoring of Combo Edit Validation - parent requests completed.');

     xla_accounting_err_pkg.insert_errors; */

   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   -- Following if conditioin is added to set the retcode to 1 when there are
   -- events with errors for that run of accounting program. (bug # 2709397)
   -- The if condition is modified to make sure the report request ends in
   -- ERROR/WARNING if any of the Parent request end in ERROR/WARNING.
   -- (Bug # 3239212).
   ----------------------------------------------------------------------------
   p_accounting_batch_id := g_accounting_batch_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_error_status = '||l_error_status
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'l_warning_status = '||l_warning_status
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_total_error_count = '||g_total_error_count
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

-- FSAH-PSFT FP
 -- Set retcode as warning when ever CmboEdit returns Invalid CCID's -- 7502532
     IF (  nvl(fnd_profile.value('XLA_FSAH_EXT_CCID_VAL'),'N') = 'Y') THEN
	BEGIN
	 SELECT 1 INTO l_code FROM dual WHERE EXISTS
	      (SELECT 1 FROM xla_events  xe, xla_ae_headers xah WHERE
	       xe.application_id= p_application_id AND
	       xe.application_id=xah.application_id AND
	       xe.process_status_code in ('I','R') AND
	       xe.event_status_code ='U' AND
	       xah.ledger_id = p_ledger_id AND
	       xah.accounting_batch_id = g_accounting_batch_id AND
	       xah.accounting_entry_status_code in ('R','I'));
	EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	  NULL;
	END;

	IF l_code >=1 THEN
	   l_warning_status:='Y';
	END IF;
     END IF;
  -- FSAH-PSFT FP

   IF l_error_status = 'Y' THEN
      -------------------------------------------------------------------------
      -- This is effective only if there are multiple event applications
      -------------------------------------------------------------------------
      p_retcode             := 2;
      p_errbuf              := 'Accouting Report ended in Error because one '||
                               'of the Parent Accounting Program ended in Error';
   ELSIF l_warning_status = 'Y' THEN
      -------------------------------------------------------------------------
      -- This is effective only if there are multiple event applications
      -------------------------------------------------------------------------
      p_retcode             := 1;
      p_errbuf              := 'Accouting Report ended in Warning because one '||
                               'of the Parent Accounting Program ended in Warning';
   ELSIF g_total_error_count = 0 THEN
      p_retcode             := 0;
      p_errbuf              := 'Accounting Program completed Normal';
   ELSIF g_total_error_count <> 0 THEN
      -------------------------------------------------------------------------
      -- This is effective only if there is one event application
      -------------------------------------------------------------------------
      p_retcode             := 1;
      p_errbuf              := 'Accounting Program ended in Warning because '||
                               'there are some events that are in error';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure ACCOUNTING_PROGRAM_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN normal_termination THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_accounting_batch_id    := g_accounting_batch_id;
   p_retcode                := 0;
   p_errbuf                 := 'Accounting Program did not find any events.';

   print_logfile(p_errbuf);

   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'NORMAL_TERMINATION exception was raised in the code'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;

  -- Bug 8282549
  IF g_queue_started_flag = 'Y' THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Ready to stop the message queue'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      dbms_aqadm.stop_queue(queue_name     => g_queue_name
                           ,wait           => TRUE);               --5056507
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue stopped = '||g_queue_name);
      dbms_aqadm.stop_queue(queue_name     => g_comp_queue_name
                           ,wait           => TRUE);               --5056507
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue stopped = '||g_comp_queue_name);
      g_queue_started_flag := 'N';

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Message queue stopped'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

   IF g_queue_created_flag = 'Y' THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Ready to drop the message queue'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      dbms_aqadm.drop_queue(queue_name     => g_queue_name);
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue dropped = '||g_queue_name);
      dbms_aqadm.drop_queue(queue_name     => g_comp_queue_name);
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue dropped = '||g_comp_queue_name);
      g_queue_created_flag := 'N';

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Message queue dropped'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;
   END IF;
   ----------------------------------------------------------------------------
   -- insert any errors that were build in this session (for them to appear
   -- on the report).
   ----------------------------------------------------------------------------
   xla_accounting_err_pkg.insert_errors;

   COMMIT;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure ACCOUNTING_PROGRAM_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
WHEN xla_exceptions_pkg.application_exception THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_accounting_batch_id    := g_accounting_batch_id;
   p_retcode                := 2;
   p_errbuf                 := xla_messages_pkg.get_message;

   print_logfile(p_errbuf);

   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- insert any errors that were build in this session (for them to appear
   -- on the report).
   ----------------------------------------------------------------------------
   xla_accounting_err_pkg.insert_errors;
   COMMIT;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure ACCOUNTING_PROGRAM_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
WHEN OTHERS THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_accounting_batch_id    := g_accounting_batch_id;
   p_retcode                := 2;
   p_errbuf                 := sqlerrm;

   print_logfile(p_errbuf);

   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_UNEXPECTED
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- insert any errors that were build in this session (for them to appear
   -- on the report).
   ----------------------------------------------------------------------------
   xla_accounting_err_pkg.build_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
      ,p_token_1        => 'APPLICATION_NAME'
      ,p_value_1        => 'SLA'
      ,p_entity_id      => NULL
      ,p_event_id       => NULL);

   xla_accounting_err_pkg.insert_errors;
   COMMIT;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure ACCOUNTING_PROGRAM_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
END accounting_program_batch;  -- end of procedure


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE event_application_cp
       (p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_source_application_id      IN  NUMBER
       ,p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_process_category           IN  VARCHAR2
       ,p_end_date                   IN  DATE
       ,p_accounting_flag            IN  VARCHAR2
       ,p_accounting_mode            IN  VARCHAR2
       ,p_error_only_flag            IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2
       ,p_accounting_batch_id        IN  NUMBER
       ,p_report_request_id          IN  NUMBER
       ,p_valuation_method           IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2) IS
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.event_application_cp';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure EVENT_APPLICATION_CP'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_application_id = '||p_source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_process_category = '||p_process_category
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_end_date = '||p_end_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_flag = '||p_accounting_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_error_only_flag = '||p_error_only_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transfer_flag = '||p_transfer_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_gl_posting_flag = '||p_gl_posting_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_gl_batch_name = '||p_gl_batch_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_batch_id = '||p_accounting_batch_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_report_request_id = '||p_report_request_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_1 = '||p_security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_1 = '||p_security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_3 = '||p_security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_1 = '||p_security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_2 = '||p_security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_3 = '||p_security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


   print_logfile('Starting request for the event application = '||p_application_id);

   ----------------------------------------------------------------------------
   -- Initializing errors package
   ----------------------------------------------------------------------------
   xla_accounting_err_pkg.set_options
      (p_error_source     => xla_accounting_err_pkg.C_ACCT_PROGRAM
      ,p_request_id       => p_report_request_id
      ,p_application_id   => p_application_id);

   g_accounting_batch_id             := p_accounting_batch_id;
   g_report_request_id               := p_report_request_id;

   ----------------------------------------------------------------------------
   -- Building filter condition based on security columns and valuation method
   -- This condition will be added dynamically to select statemtents.
   ----------------------------------------------------------------------------
   SELECT
   DECODE(p_valuation_method,NULL,NULL,'and valuation_method = '''||p_valuation_method||''' ')||
   --DECODE(p_security_id_int_1,NULL,NULL,'and security_id_int_1 = '||p_security_id_int_1||' ')|| --14307411
   DECODE(p_security_id_int_1,NULL,NULL
                                   ,DECODE(p_application_id,707, 'and NVL(security_id_int_1,p_security_id_int_1) = '||p_security_id_int_1||' ',
                                                                  'and security_id_int_1 = '||p_security_id_int_1||' '))||  --14307411
   DECODE(p_security_id_int_2,NULL,NULL,'and security_id_int_2 = '||p_security_id_int_2||' ')||
   DECODE(p_security_id_int_3,NULL,NULL,'and security_id_int_3 = '||p_security_id_int_3||' ')||
   DECODE(p_security_id_char_1,NULL,NULL,'and security_id_char_1 = '''||p_security_id_char_1||''' ')||
   DECODE(p_security_id_char_2,NULL,NULL,'and security_id_char_2 = '''||p_security_id_char_2||''' ')||
   DECODE(p_security_id_char_3,NULL,NULL,'and security_id_char_3 = '''||p_security_id_char_3||''' ')
   INTO g_security_condition
   FROM DUAL;

   ----------------------------------------------------------------------------
   -- Building filter condition based process_category.
   -- This condition will be added dynamically to select statemtents.
   ----------------------------------------------------------------------------
   SELECT
   DECODE(p_process_category,NULL,NULL,'and event_class_group_code = '''||p_process_category||'''')
   INTO g_process_category_condition
   FROM DUAL;

   ----------------------------------------------------------------------------
   -- Building filter condition based on source_application_id.
   ----------------------------------------------------------------------------
   SELECT
   DECODE(p_source_application_id,NULL,NULL,'and source_application_id = '||p_source_application_id)
   INTO g_source_appl_condition
   FROM DUAL;
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Dynamic conditions built');

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_security_condition = '||g_security_condition
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_process_category_condition = '||g_process_category_condition
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_source_appl_condition = '||g_source_appl_condition
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- call event_application_manager
   ----------------------------------------------------------------------------
     event_application_manager
         (p_source_application_id      => p_source_application_id
         ,p_application_id             => p_application_id
         ,p_ledger_id                  => p_ledger_id
         ,p_process_category           => p_process_category
         ,p_end_date                   => p_end_date
         ,p_accounting_flag            => p_accounting_flag
         ,p_accounting_mode            => p_accounting_mode
         ,p_error_only_flag            => p_error_only_flag
         ,p_transfer_flag              => p_transfer_flag
         ,p_gl_posting_flag            => p_gl_posting_flag
         ,p_gl_batch_name              => p_gl_batch_name
         ,p_valuation_method           => p_valuation_method
         ,p_security_id_int_1          => p_security_id_int_1
         ,p_security_id_int_2          => p_security_id_int_2
         ,p_security_id_int_3          => p_security_id_int_3
         ,p_security_id_char_1         => p_security_id_char_1
         ,p_security_id_char_2         => p_security_id_char_2
         ,p_security_id_char_3         => p_security_id_char_3);

   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   -- Following if conditioin is added to set the retcode to 1 when there are
   -- events with errors for that run of accounting program. (bug # 2709397)
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_total_error_count = '||g_total_error_count
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF g_total_error_count = 0 THEN
      p_retcode             := 0;
      p_errbuf              := 'Accounting Program completed Normal';
   ELSE
      p_retcode             := 1;
      p_errbuf              := 'Accounting Program completed Normal with some events in error';
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure EVENT_APPLICATION_CP'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN normal_termination THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_retcode             := 0;
   p_errbuf              := 'Accounting Program did not find any events.';

   print_logfile(p_errbuf);

   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'NORMAL_TERMINATION exception was raised in the code'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   ----------------------------------------------------------------------------
   -- insert any errors that were build in this session (for them to appear
   -- on the report).
   ----------------------------------------------------------------------------
   xla_accounting_err_pkg.insert_errors;

   COMMIT;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure EVENT_APPLICATION_CP'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
WHEN xla_exceptions_pkg.application_exception THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_retcode                := 2;
   p_errbuf                 := xla_messages_pkg.get_message;

   print_logfile(p_errbuf);

   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- insert any errors that were build in this session (for them to appear
   -- on the report).
   ----------------------------------------------------------------------------
   xla_accounting_err_pkg.insert_errors;

   COMMIT;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure EVENT_APPLICATION_CP'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
WHEN OTHERS THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_retcode                := 2;
   p_errbuf                 := sqlerrm;

   print_logfile(p_errbuf);

   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_UNEXPECTED
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- insert any errors that were build in this session (for them to appear
   -- on the report).
   ----------------------------------------------------------------------------
   xla_accounting_err_pkg.build_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
      ,p_token_1        => 'APPLICATION_NAME'
      ,p_value_1        => 'SLA'
      ,p_entity_id      => NULL
      ,p_event_id       => NULL);

   xla_accounting_err_pkg.insert_errors;

   COMMIT;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure EVENT_APPLICATION_CP'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
END event_application_cp;   -- end of procedure


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE event_application_manager
       (p_source_application_id      IN  NUMBER
       ,p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_process_category           IN  VARCHAR2
       ,p_end_date                   IN  DATE
       ,p_accounting_flag            IN  VARCHAR2
       ,p_accounting_mode            IN  VARCHAR2
       ,p_error_only_flag            IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2
       ,p_valuation_method           IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2) IS

l_transfer_mode                   VARCHAR2(30);
l_sqlerrm                         VARCHAR2(2000);
l_log_module                      VARCHAR2(240);

l_temp                            BOOLEAN;
l_status                          VARCHAR2(80);
l_industry                        VARCHAR2(80);
l_xla_schema_name                 VARCHAR2(30);

l_acct_begin_time                 NUMBER;
l_acct_end_time                   NUMBER;
l_transfer_begin_time             NUMBER;
l_transfer_end_time               NUMBER;

--FSAH-PSFT FP
 l_xla_val_ccid_req_id             NUMBER(10);--FSAH
 l_error_status                    VARCHAR2(1) := 'N'; --FSAH
 l_warning_status                  VARCHAR2(1) := 'N'; --FSAH

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.event_application_manager';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure EVENT_APPLICATION_MANAGER'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_application_id = '||p_source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_process_category = '||p_process_category
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_end_date = '||p_end_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_flag = '||p_accounting_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_error_only_flag = '||p_error_only_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transfer_flag = '||p_transfer_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_gl_posting_flag = '||p_gl_posting_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_gl_batch_name = '||p_gl_batch_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_1 = '||p_security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_2 = '||p_security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_3 = '||p_security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_1 = '||p_security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_2 = '||p_security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_3 = '||p_security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Initializing global variables
   ----------------------------------------------------------------------------
   g_application_id                  := p_application_id;
   g_ledger_id                       := p_ledger_id;
   g_process_category                := p_process_category;
   g_end_date                        := p_end_date;
   g_accounting_flag                 := p_accounting_flag;
   g_accounting_mode                 := p_accounting_mode;
   g_error_only_flag                 := p_error_only_flag;
   g_transfer_flag                   := p_transfer_flag;
   g_gl_posting_flag                 := p_gl_posting_flag;
   g_gl_batch_name                   := p_gl_batch_name;
   -- Bug 4963736
   g_valuation_method                := p_valuation_method;
   g_security_id_int_1               := p_security_id_int_1;
   g_security_id_int_2               := p_security_id_int_2;
   g_security_id_int_3               := p_security_id_int_3;
   g_security_id_char_1              := p_security_id_char_1;
   g_security_id_char_2              := p_security_id_char_2;
   g_security_id_char_3              := p_security_id_char_3;

   g_processing_mode                 := 'BATCH';
   g_execution_mode                  := 'OFFLINE';
   g_total_error_count               := 0;
   g_parent_request_id               := fnd_global.conc_request_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_processing_mode = '||g_processing_mode
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_execution_mode = '||g_execution_mode
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_parent_request_id = '||g_parent_request_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   l_acct_begin_time                 := 0;
   l_acct_end_time                   := 0;
   l_transfer_begin_time             := 0;
   l_transfer_end_time               := 0;


   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- the accounting program to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_application_id);

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Security_context set for application = '||p_application_id
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Security Context Set ');

   ----------------------------------------------------------------------------
   -- Following sets the session's client identifier for the purpose of global
   -- application context.
   ----------------------------------------------------------------------------
   dbms_session.set_identifier
      (client_id      => g_parent_request_id);

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Session identifier set to = '||g_parent_request_id
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Session Identifier Set ');

   ----------------------------------------------------------------------------
   -- Determining xla_schema_name and queue_table_name
   ----------------------------------------------------------------------------
   l_temp := fnd_installation.get_app_info
                (application_short_name     => 'XLA'
                ,status                     => l_status
                ,industry                   => l_industry
                ,oracle_schema              => l_xla_schema_name);

   g_queue_table_name := l_xla_schema_name||'.'||C_QUEUE_TABLE;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_queue_table_name = '||g_queue_table_name
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Determining queue_name based on request id
   ----------------------------------------------------------------------------
   g_queue_name      := l_xla_schema_name || '.XLA_'||TO_CHAR(g_parent_request_id)||'_DOC_Q';
   g_comp_queue_name := l_xla_schema_name || '.XLA_'||TO_CHAR(g_parent_request_id)||'_COMP_Q';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_queue_name = '||g_queue_name
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- call routines to create accounting entries
   ----------------------------------------------------------------------------
   IF g_accounting_flag = 'Y' THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Accounting process being called'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      l_acct_begin_time := dbms_utility.get_time;

      batch_accounting;

      l_acct_end_time := dbms_utility.get_time;


      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Accounting process completed'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

   ----------------------------------------------------------------------------
   -- call routines to perform 'Transfer to GL'
   ----------------------------------------------------------------------------
   IF  ((g_transfer_flag = 'Y') AND (g_accounting_flag = 'N'))
   THEN

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Transfer to GL process being called'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      l_transfer_begin_time := dbms_utility.get_time;

      xla_accounting_err_pkg.set_options
         (p_error_source     => xla_accounting_err_pkg.C_TRANSFER_TO_GL);

      l_transfer_mode := 'STANDALONE';

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'l_transfer_mode = '||l_transfer_mode
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Calling transfer routine XLA_TRANSFER_PKG.GL_TRANSFER_MAIN'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      --
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Submitting the transfer to GL');
      xla_transfer_pkg.gl_transfer_main
         (p_application_id        => g_application_id
         ,p_transfer_mode         => l_transfer_mode
         ,p_ledger_id             => g_ledger_id
         ,p_securiy_id_int_1      => g_security_id_int_1
         ,p_securiy_id_int_2      => g_security_id_int_2
         ,p_securiy_id_int_3      => g_security_id_int_3
         ,p_securiy_id_char_1     => g_security_id_char_1
         ,p_securiy_id_char_2     => g_security_id_char_2
         ,p_securiy_id_char_3     => g_security_id_char_3
         ,p_valuation_method      => g_valuation_method
         ,p_process_category      => g_process_category
         ,p_accounting_batch_id   => g_accounting_batch_id
         ,p_entity_id             => NULL
         ,p_batch_name            => g_gl_batch_name
         ,p_end_date              => g_end_date
         ,p_submit_gl_post        => g_gl_posting_flag
         ,p_caller                => xla_transfer_pkg.C_ACCTPROG_BATCH); -- Bug 5056632

      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' -  End of the transfer to GL');
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Transfer routine XLA_TRANSFER_PKG.GL_TRANSFER_MAIN executed'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      xla_accounting_err_pkg.set_options
         (p_error_source     => xla_accounting_err_pkg.C_ACCT_PROGRAM);

      l_transfer_end_time := dbms_utility.get_time;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Transfer to GL process completed'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

   -- FSAH-PSFT FP
	-- profile value XLA:Enable External Code Combination Validation
     if(fnd_profile.value('XLA_FSAH_EXT_CCID_VAL') IS NOT NULL) THEN
	 IF (  nvl(fnd_profile.value('XLA_FSAH_EXT_CCID_VAL'),'N') = 'Y') THEN

	 l_xla_val_ccid_req_id:= fnd_request.submit_request
			     (application     => 'XLA'
			     ,program         => 'XLACCIDVAL'
			     ,description     => NULL
			     ,start_time      => NULL
			     ,sub_request     => FALSE
			     ,argument1       => p_application_id
			     ,argument2       => g_accounting_batch_id
			     ,argument3       => p_ledger_id
			     ,argument4       => g_parent_request_id
			    );

	      IF l_xla_val_ccid_req_id = 0 THEN
		       xla_accounting_err_pkg.build_message
			  (p_appli_s_name   => 'XLA'
			  ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
			  ,p_token_1        => 'APPLICATION_NAME'
			  ,p_value_1        => 'SLA'
			  ,p_entity_id      => NULL
			  ,p_event_id       => NULL);

		       print_logfile('Technical Error : Unable to submit java
	 concurrent program request');

		       xla_exceptions_pkg.raise_message
			  (p_appli_s_name   => 'XLA'
			  ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
			  ,p_token_1        => 'APPLICATION_NAME'
			  ,p_value_1        => 'SLA');
	     END IF;

	 END IF;
	 COMMIT;

	 -------------------------------------------------------------------------
	 -- wait for requests to complete
	 -------------------------------------------------------------------------
	      print_logfile(to_char(sysdate,'DD-MON-YYYY HH:MI:SS')||
		   '- Waiting for Combo Edit Validation - parent requests to complete.');
	      wait_for_combo_edit_req
		 (p_request_id           => l_xla_val_ccid_req_id
		 ,p_error_status         => l_error_status
		 ,p_warning_status       => l_warning_status);
	      print_logfile(to_char(sysdate,'DD-MON-YYYY HH:MI:SS')||
		' - Monitoring of Combo Edit Validation - parent requests completed.');

	 xla_accounting_err_pkg.insert_errors;
	END IF;
	-- FSAH-PSFT FP
   ----------------------------------------------------------------------------
   -- Handle postaccounting hook
   ----------------------------------------------------------------------------
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - executing postaccounting hook');
      handle_accounting_hook
                 (p_application_id         => g_application_id
                 ,p_ledger_id              => g_ledger_id
                 ,p_process_category       => g_process_category
                 ,p_end_date               => g_end_date
                 ,p_accounting_mode        => g_accounting_mode
                 ,p_budgetary_control_mode => g_budgetary_control_mode
                 ,p_valuation_method       => g_valuation_method
                 ,p_security_id_int_1      => g_security_id_int_1
                 ,p_security_id_int_2      => g_security_id_int_2
                 ,p_security_id_int_3      => g_security_id_int_3
                 ,p_security_id_char_1     => g_security_id_char_1
                 ,p_security_id_char_2     => g_security_id_char_2
                 ,p_security_id_char_3     => g_security_id_char_3
                 ,p_report_request_id      => g_report_request_id
                 ,p_event_name             => 'postaccounting'
                 ,p_event_key              => to_char(g_accounting_batch_id)||'-'
                                        ||to_char(g_parent_request_id));
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - postaccounting hook executed successfully');

   COMMIT;
   dbms_session.set_identifier(client_id => g_parent_request_id); -- added for bug11903966
   print_logfile('- Accounting Time = '||((l_acct_end_time - l_acct_begin_time)/100)||' secs');
   print_logfile('- Transfer Time   = '||((l_transfer_end_time - l_transfer_begin_time)/100)||' secs');

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'COMMIT issued in the procedure EVENT_APPLICATION_MANAGER'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure EVENT_APPLICATION_MANAGER'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN normal_termination THEN
   RAISE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_accounting_err_pkg.build_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
      ,p_token_1        => 'APPLICATION_NAME'
      ,p_value_1        => 'SLA'
      ,p_entity_id      => NULL
      ,p_event_id       => NULL);
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_pkg.event_application_manager');
END event_application_manager;   -- end of procedure


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE unit_processor_batch
       (p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_end_date                   IN  VARCHAR2  -- Bug 5151844
       ,p_accounting_mode            IN  VARCHAR2
       ,p_error_only_flag            IN  VARCHAR2
       ,p_accounting_batch_id        IN  NUMBER
       ,p_parent_request_id          IN  NUMBER
       ,p_report_request_id          IN  NUMBER
       ,p_queue_name                 IN  VARCHAR2
       ,p_comp_queue_name            IN  VARCHAR2
       ,p_error_limit                IN  NUMBER
       ,p_seq_enabled_flag           IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2) IS -- Bug 5257343

l_log_module                      VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.unit_processor_batch';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure UNIT_PROCESSOR_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_end_date = '||p_end_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_error_only_flag = '||p_error_only_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_batch_id = '||p_accounting_batch_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_parent_request_id = '||p_parent_request_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_report_request_id = '||p_report_request_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_queue_name = '||p_queue_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_comp_queue_name = '||p_comp_queue_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_error_limit = '||p_error_limit
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_seq_enabled_flag = '||p_seq_enabled_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_gl_batch_name = '||p_gl_batch_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;


   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Executing Unit Processor ...');
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Initializing variables');

   ----------------------------------------------------------------------------
   -- Initializing global variables
   ----------------------------------------------------------------------------
   g_application_id                  := p_application_id;
   g_ledger_id                       := p_ledger_id;
   g_end_date                        := to_date(p_end_date,'YYYY/MM/DD');
   g_accounting_mode                 := p_accounting_mode;
   g_accounting_batch_id             := p_accounting_batch_id;
   g_parent_request_id               := p_parent_request_id;
   g_report_request_id               := p_report_request_id;
   g_queue_name                      := p_queue_name;
   g_comp_queue_name                 := p_comp_queue_name;
   g_error_limit                     := p_error_limit;
   g_seq_enabled_flag                := p_seq_enabled_flag;

   g_ep_reqid                        := fnd_global.conc_request_id;
   g_execution_mode                  := 'OFFLINE';
   g_processing_mode                 := 'BATCH';
   g_current_entity_id               := NULL;
   g_transfer_flag                   := p_transfer_flag;
   g_gl_posting_flag                 := p_gl_posting_flag;
   g_gl_batch_name                   := p_gl_batch_name; -- Bug 5257343


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_ep_reqid = '||g_ep_reqid
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_execution_mode = '||g_execution_mode
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_processing_mode = '||g_processing_mode
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   g_child_data.selected_entity_count := 0;
   g_child_data.dequeued_msg_count    := 0;
   g_child_data.selected_event_count  := 0;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- the accounting program to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_application_id);

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Security_context set for application = '||p_application_id
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Security Context Set ');

   ----------------------------------------------------------------------------
   -- Following sets the session's client identifier for the purpose of global
   -- application context.
   ----------------------------------------------------------------------------
   dbms_session.set_identifier
      (client_id      => g_parent_request_id);

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Session identifier set to = '||g_parent_request_id
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Initializing error package
   ----------------------------------------------------------------------------
   xla_accounting_err_pkg.initialize
      (p_client_id        => g_parent_request_id
      ,p_error_limit      => g_error_limit
      ,p_error_source     => xla_accounting_err_pkg.C_ACCT_ENGINE
      ,p_application_id   => g_application_id);

   ----------------------------------------------------------------------------
   -- Call the main accounting routine 'unit_processor'
   ----------------------------------------------------------------------------
   unit_processor;

   ----------------------------------------------------------------------------
   -- 4645092 Set report request for MPA report
   ----------------------------------------------------------------------------
   IF g_mpa_accrual_exists = 'Y' THEN
      xla_context_pkg.set_mpa_accrual_context
         (p_mpa_accrual_exists            => 'Y'
         ,p_client_id                     => g_report_request_id);
   END IF;

   ----------------------------------------------------------------------------
   -- Following if conditioin is added to set the retcode to 1 when there are
   -- events with errors for that run of child thread in accounting program.
   -- (bug # 2709397)
   ----------------------------------------------------------------------------

    --bug 7253269 condition included
    IF xla_accounting_err_pkg.g_error_count = 0 AND NOT XLA_ACCOUNTING_CACHE_PKG.g_hist_bflow_error_exists
    AND NOT XLA_AE_LINES_PKG.g_hist_reversal_error_exists AND NOT xla_accounting_cache_pkg.g_reversal_error THEN
      p_errbuf   := 'Unit Processor completed normally';
      p_retcode  := 0;
   ELSE
      p_errbuf   := 'Unit Processor completed normally with some events in error';
      p_retcode  := 1;
   END IF;


   COMMIT;
   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'COMMIT issued in the procedure UNIT_PROCESSOR_BATCH'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Unit Processor completed successfully ...');

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure UNIT_PROCESSOR_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ----------------------------------------------------------------------------
   -- Following stores the error message in the accounting log table
   ----------------------------------------------------------------------------
   p_errbuf   := xla_messages_pkg.get_message;
   p_retcode  := 2;

   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
   END IF;

   ROLLBACK;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'ROLLBACK issued in the procedure UNIT_PROCESSOR_BATCH'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure UNIT_PROCESSOR_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
WHEN OTHERS THEN
   ----------------------------------------------------------------------------
   -- Following stores the error message in the accounting log table
   ----------------------------------------------------------------------------
   IF SQLCODE = -25228 AND g_conc_hold = 'Y'  /* Timeout; queue is likely empty... */
   THEN
       p_retcode  := 1;
   ELSE
       p_retcode  := 2;
   END IF;

   p_errbuf   := sqlerrm;
   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_UNEXPECTED
         ,p_module   => l_log_module);
   END IF;

   ROLLBACK;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'ROLLBACK issued in the procedure UNIT_PROCESSOR_BATCH'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure UNIT_PROCESSOR_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
END unit_processor_batch;  -- end of function

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE accounting_program_events
(p_application_id         IN INTEGER
,p_accounting_mode        IN VARCHAR2
,p_gl_posting_flag        IN VARCHAR2
,p_offline_flag           IN VARCHAR2
,p_accounting_batch_id    IN OUT NOCOPY INTEGER
,p_errbuf                 IN OUT NOCOPY VARCHAR2
,p_retcode                IN OUT NOCOPY INTEGER)
IS
-- Retrieve any ledgers that does not enable budgetary control
CURSOR c_invalid_bc_ledgers IS
  SELECT gl.ledger_id, gl.name ledger_name
    FROM xla_acct_prog_events_gt xpa
       , gl_ledgers              gl
   WHERE xpa.ledger_id                 = gl.ledger_id
     AND enable_budgetary_control_flag = 'N'
     AND ROWNUM = 1;

-- Retrieve any ledgers that does not contains any JLD that indicates budgetary
-- control validation
CURSOR c_invalid_ledger_id IS
  SELECT xgl.ledger_id
       , xgl.name ledger_name
       , xam.name slam_name
    FROM xla_acct_prog_events_gt   xap
       , xla_gl_ledgers_v          xgl
       , xla_acctg_methods_tl      xam
       , xla_acctg_method_rules    xar
       , xla_aad_line_defn_assgns  xal
       , xla_line_definitions_b    xld
   WHERE xld.application_id(+)              = xal.application_id
     AND xld.amb_context_code(+)            = xal.amb_context_code
     AND xld.event_class_code(+)            = xal.event_class_code
     AND xld.event_type_code(+)             = xal.event_type_code
     AND xld.line_definition_owner_code(+)  = xal.line_definition_owner_code
     AND xld.line_definition_code(+)        = xal.line_definition_code
     AND xld.budgetary_control_flag(+)      = 'Y'
     AND xal.application_id(+)              = xar.application_id
     AND xal.amb_context_code(+)            = xar.amb_context_code
     AND xal.product_rule_type_code(+)      = xar.product_rule_type_code
     AND xal.product_rule_code(+)           = xar.product_rule_code
     AND xar.accounting_method_type_code(+) = xgl.sla_accounting_method_type
     AND xar.accounting_method_code(+)      = xgl.sla_accounting_method_code
     AND xar.application_id(+)              = p_application_id
     AND xar.amb_context_code(+)            = NVL(fnd_profile.value('XLA_AMB_CONTEXT'),'DEFAULT')
     AND xam.accounting_method_type_code(+) = xgl.sla_accounting_method_type
     AND xam.accounting_method_code(+)      = xgl.sla_accounting_method_code
     AND xam.language(+)                    = USERENV('LANG')
     AND xgl.ledger_id                      = xap.ledger_id
   GROUP BY xgl.ledger_id
          , xgl.name
          , xam.name
   HAVING count(*) = 0;

CURSOR c_lock_entity_events IS
  SELECT /*+ LEADING (XAP) USE_NL (XAP XE XTE) */
         xe.event_id
    FROM xla_transaction_entities   xte
       , xla_events                 xe
       , xla_acct_prog_events_gt    xap
   WHERE xte.application_id = xe.application_id
     AND xte.entity_id      = xe.entity_id
     AND xe.application_id  = p_application_id
     AND xe.event_id        = xap.event_id
  FOR UPDATE NOWAIT;

CURSOR c_entities IS
  SELECT distinct entity_id
    FROM xla_acct_prog_events_gt xap
       , xla_events              xe
   WHERE xe.application_id   = p_application_id
     AND xe.event_id         = xap.event_id;

-- Retrieve list of ledgers to be processed
CURSOR c_ledgers IS
  SELECT DISTINCT ledger_id
    FROM xla_acct_prog_events_gt;

i                         INTEGER;
l_request_id              INTEGER;
l_array_event_id          t_array_integer;
l_ret_flag_bal_update     BOOLEAN;
l_transfer_mode           VARCHAR2(30);
l_event_source_info       xla_events_pub_pkg.t_event_source_info;

l_log_module              VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.accounting_program_events';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure accounting_program_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_gl_posting_flag = '||p_gl_posting_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_offline_flag = '||p_offline_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   SAVEPOINT  SP_EVENTS;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Established a savepoint SP_EVENTS'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;


   --
   -- Initializing errors package
   --
   xla_accounting_err_pkg.initialize
         (p_client_id        => NULL
         ,p_error_limit      => NULL
         ,p_error_source     => xla_accounting_err_pkg.C_ACCT_PROGRAM
         ,p_application_id   => p_application_id);

   --
   -- If called with budgetary control mode, ensure all ledgers of the entity
   -- have budgetary control enabled.
   --
   IF (p_accounting_mode IN ('FUNDS_RESERVE', 'FUNDS_CHECK')) THEN
     IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace
           (p_msg      => 'BEGIN LOOP: XLA_AP_INVALID_BC_LEDGER'
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
     END IF;

     FOR l_err IN c_invalid_bc_ledgers LOOP
       IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace
             (p_msg      => 'LOOP: Error XLA_AP_INVALID_BC_LEDGER - '||
                            'ledger = '||l_err.ledger_name
             ,p_level    => C_LEVEL_ERROR
             ,p_module   => l_log_module);
       END IF;

       xla_accounting_err_pkg.build_message
           (p_appli_s_name   => 'XLA'
           ,p_msg_name       => 'XLA_AP_INVALID_BC_LEDGER'
           ,p_token_1        => 'LEDGER_NAME'
           ,p_value_1        => l_err.ledger_name
           ,p_entity_id      => NULL
           ,p_event_id       => NULL);
     END LOOP;

     IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace
           (p_msg      => 'END LOOP: XLA_AP_INVALID_BC_LEDGER'
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
     END IF;

     IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace
           (p_msg      => 'BEGIN LOOP: XLA_AP_INVALID_LEDGER_JLD'
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
     END IF;

     FOR l_err IN c_invalid_ledger_id LOOP
       IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace
             (p_msg      => 'LOOP: Error XLA_AP_INVALID_LEDGER_JLD - '||
                            'slam = '||l_err.slam_name||
                            ', ledger = '||l_err.ledger_name
             ,p_level    => C_LEVEL_ERROR
             ,p_module   => l_log_module);
       END IF;

       xla_accounting_err_pkg.build_message
           (p_appli_s_name   => 'XLA'
           ,p_msg_name       => 'XLA_AP_INVALID_LEDGER_JLD'
           ,p_token_1        => 'SLAM_NAME'
           ,p_value_1        => l_err.slam_name
           ,p_token_2        => 'LEDGER_NAME'
           ,p_value_2        => l_err.ledger_name
           ,p_entity_id      => NULL
           ,p_event_id       => NULL);
     END LOOP;

     IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace
           (p_msg      => 'END LOOP: XLA_AP_INVALID_LEDGER_JLD'
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
     END IF;

   END IF;

   g_application_id        := p_application_id;
   g_processing_mode       := 'DOCUMENT';

   IF (p_accounting_mode = 'NONE') THEN
     g_accounting_mode := 'N';
     g_budgetary_control_mode := 'NONE';
   ELSIF (p_accounting_mode = 'FUNDS_RESERVE') THEN
     g_accounting_mode := 'F';
     g_budgetary_control_mode := p_accounting_mode;
   ELSIF (p_accounting_mode = 'FUNDS_CHECK') THEN
     g_accounting_mode := 'D';
     g_budgetary_control_mode := p_accounting_mode;
   ELSIF (p_accounting_mode = 'DRAFT') THEN
     g_accounting_mode := 'D';
     g_budgetary_control_mode := 'NONE';
   ELSE -- FINAL
     g_accounting_mode := 'F';
     g_budgetary_control_mode := 'NONE';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_accounting_mode = '||g_accounting_mode
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_budgetary_control_mode = '||g_budgetary_control_mode
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- the accounting program to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_application_id);

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Security_context set for application = '||p_application_id
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   --
   -- Lock all entity and events in xla_entity_events_v that exists in the
   -- xla_acct_prog_events_gt
   --
   OPEN c_lock_entity_events;
   FETCH c_lock_entity_events BULK COLLECT INTO l_array_event_id;
   CLOSE c_lock_entity_events;

   --
   -- Following sets the session's client identifier for the purpose of global
   --
   -- application context.
   --
   SELECT xla_accounting_batches_s.nextval INTO p_accounting_batch_id FROM DUAL;
   g_accounting_batch_id := p_accounting_batch_id;

   dbms_session.set_identifier
         (client_id      => g_accounting_batch_id);

   IF (g_accounting_mode ='F' AND g_budgetary_control_mode = 'NONE') THEN
    IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
     l_ret_flag_bal_update := xla_balances_pkg.massive_update_for_events
          (p_application_id    => g_application_id);

     IF (C_LEVEL_EVENT >= g_log_level) THEN
       trace
         (p_msg      => 'Fucntion XLA_BALANCES_PKG.MASSIVE_UPDATE executed'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
     END IF;

     IF (C_LEVEL_EVENT >= g_log_level) THEN
       trace
            (p_msg      => 'l_ret_flag_bal_update = '||CASE WHEN l_ret_flag_bal_update
                                                            THEN 'TRUE'
                                                            ELSE 'FALSE' END
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
     END IF;

     IF NOT l_ret_flag_bal_update THEN
       xla_accounting_err_pkg.build_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_AP_BAL_UPDATE_FAILED'
            ,p_entity_id      => NULL
            ,p_event_id       => NULL);

       print_logfile
            ('Technical problem : Problem in submitting request for balance update');

       xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_AP_BAL_UPDATE_FAILED');
     ELSE
       print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - request for balance calulation submitted');
     END IF;
    END IF;
   END IF;

     --
     -- Delete the journal entries created for the events and entities to be processed
     --

   IF (g_accounting_mode IN ('D','F')) THEN
     delete_batch_je;

     FORALL i IN 1..l_array_event_id.COUNT
       UPDATE xla_events xe
          SET process_status_code     = 'U'
        WHERE xe.on_hold_flag         = 'N'
          AND xe.process_status_code <> 'P'
          AND xe.event_type_code not in ('FULL_MERGE', 'PARTIAL_MERGE')
          AND xe.event_id             = l_array_event_id(i);
   END IF;

   --
   -- Process the events by ledger
   --
   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN LOOP: loop ledger'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   FOR l_ledger IN c_ledgers LOOP
     IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace
           (p_msg      => 'LOOP: ledger_id = '||l_ledger.ledger_id
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'g_accounting_mode = '||g_accounting_mode
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
     END IF;

     g_ledger_id := l_ledger.ledger_id;


     IF (g_accounting_mode IN ('D','F')) THEN

	  -- 7193986 start

    FOR x IN (
        SELECT DISTINCT xla_evt_class_orders_gt.processing_order
        FROM    xla_acct_prog_events_gt     ,
            xla_events                  ,
            xla_event_types_b           ,
            xla_transaction_entities,
            xla_evt_class_orders_gt
        WHERE   xla_events.event_id                         = xla_acct_prog_events_gt.event_id
            AND xla_events.application_id                   = p_application_id
            AND xla_transaction_entities.application_id = p_application_id
            AND xla_events.entity_id                        = xla_transaction_entities.entity_id
            AND xla_event_types_b.application_id            = p_application_id
            AND xla_transaction_entities.entity_code    = xla_event_types_b.entity_code
            AND xla_events.event_type_code                  = xla_event_types_b.event_type_code
            AND xla_event_types_b.event_class_code          = xla_evt_class_orders_gt.event_class_code
	    AND xla_events.process_status_code <> 'P'  --condition added, bug8680284
        ORDER BY xla_evt_class_orders_gt.processing_order ASC)
    LOOP

        IF (C_LEVEL_EVENT >= g_log_level) THEN
              trace
             (p_msg      => 'BEGIN LOOP: event processor for order = ' || x.processing_order
             ,p_level    => C_LEVEL_EVENT
             ,p_module   => l_log_module);
        END IF;

        events_processor (x.processing_order);

        IF (C_LEVEL_EVENT >= g_log_level) THEN
              trace
             (p_msg      => 'END LOOP: event processor for order = ' || x.processing_order
             ,p_level    => C_LEVEL_EVENT
             ,p_module   => l_log_module);
        END IF;

    END LOOP;


    -- 7193986 end


        IF (g_accounting_mode = 'F' AND g_budgetary_control_mode = 'NONE') THEN
	 IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
          l_ret_flag_bal_update := xla_balances_pkg.massive_update
                                   (p_application_id      => g_application_id
                                   ,p_ledger_id           => NULL
                                   ,p_entity_id           => NULL
                                   ,p_event_id            => NULL
                                   ,p_request_id          => NULL
                                   ,p_accounting_batch_id => g_accounting_batch_id
                                   ,p_update_mode         => 'A'
                                   ,p_execution_mode      => 'O');
	 ELSE
          l_ret_flag_bal_update := xla_balances_calc_pkg.massive_update
                                   (p_application_id      => g_application_id
                                   ,p_ledger_id           => g_ledger_id
                                   ,p_entity_id           => NULL
                                   ,p_event_id            => NULL
                                   ,p_request_id          => NULL
                                   ,p_accounting_batch_id => g_accounting_batch_id
                                   ,p_update_mode         => 'A'
                                   ,p_execution_mode      => 'O');
         END IF;

          IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'l_ret_flag_bal_update = '||CASE WHEN l_ret_flag_bal_update
                                                               THEN 'TRUE'
                                                               ELSE 'FALSE' END
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
          END IF;

          IF NOT l_ret_flag_bal_update THEN
            --bug 11666797
            /*xla_accounting_err_pkg.build_message
                 (p_appli_s_name   => 'XLA'
                 ,p_msg_name       => 'XLA_AP_BAL_UPDATE_FAILED'
                 ,p_entity_id      => NULL
                 ,p_event_id       => NULL);*/

            /*print_logfile
               ('Technical problem : Problem in submitting request for balance update');*/
			   NULL;

            /*xla_exceptions_pkg.raise_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_AP_BAL_UPDATE_FAILED');*/
          ELSE
            print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - request for balance calulation submitted');
          END IF;
        END IF;
     END IF;

     --
     -- Call transfer to GL if requested
     --
     IF (p_gl_posting_flag = 'Y' AND
         g_accounting_mode IN ('F', 'N')) THEN

       IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
              (p_msg      => 'Transfer to GL process being called'
              ,p_level    => C_LEVEL_EVENT
              ,p_module   => l_log_module);
       END IF;

       IF p_offline_flag = 'Y' THEN

         xla_accounting_err_pkg.set_options
                 (p_error_source     => xla_accounting_err_pkg.C_TRANSFER_TO_GL);

         IF p_accounting_mode = 'NONE' THEN
            l_transfer_mode := 'STANDALONE';
         ELSE
            l_transfer_mode := 'COMBINED';
         END IF;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'l_transfer_mode = '||l_transfer_mode
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Calling transfer routine XLA_TRANSFER_PKG.GL_TRANSFER_MAIN'
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;

         FOR l in c_entities LOOP
           xla_transfer_pkg.gl_transfer_main
               (p_application_id      => p_application_id
               ,p_transfer_mode       => l_transfer_mode
               ,p_ledger_id           => g_ledger_id
               ,p_securiy_id_int_1    => NULL
               ,p_securiy_id_int_2    => NULL
               ,p_securiy_id_int_3    => NULL
               ,p_securiy_id_char_1   => NULL
               ,p_securiy_id_char_2   => NULL
               ,p_securiy_id_char_3   => NULL
               ,p_valuation_method    => NULL
               ,p_process_category    => NULL
               ,p_accounting_batch_id => g_accounting_batch_id
               ,p_entity_id           => l.entity_id
               ,p_batch_name          => NULL
               ,p_end_date            => NULL
               ,p_submit_gl_post      => 'Y'
               ,p_caller              => xla_transfer_pkg.C_ACCTPROG_DOCUMENT); -- Bug 5056632
         END LOOP;

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Transfer routine XLA_TRANSFER_PKG.GL_TRANSFER_MAIN executed'
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;

         xla_accounting_err_pkg.set_options
               (p_error_source     => xla_accounting_err_pkg.C_ACCT_PROGRAM);
       ELSE
         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Calling XLA_ACCOUNTING_PUB_PKG.ACCOUNTING_PROGRAM_DOCUMENT '||
                              'to submit concurrent request for the transfer'
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;

         l_event_source_info.application_id := p_application_id;
         FOR l in c_entities LOOP
           xla_accounting_pub_pkg.accounting_program_document
            (p_event_source_info               => l_event_source_info
            ,p_entity_id                       => l.entity_id
            ,p_accounting_flag                 => 'N'
            ,p_accounting_mode                 => NULL
            ,p_transfer_flag                   => 'Y'
            ,p_gl_posting_flag                 => 'Y'
            ,p_offline_flag                    => 'Y'
            ,p_accounting_batch_id             => p_accounting_batch_id
            ,p_errbuf                          => p_errbuf
            ,p_retcode                         => p_retcode
            ,p_request_id                      => l_request_id);
         END LOOP;

       END IF;
     END IF;

   END LOOP;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
       (p_msg      => 'END LOOP: loop ledger'
       ,p_level    => C_LEVEL_EVENT
       ,p_module   => l_log_module);
   END IF;


   --
   -- Insert errors
   --
   xla_accounting_err_pkg.insert_errors;

   IF xla_accounting_err_pkg.g_error_count-xla_accounting_err_pkg.g_warning_count = 0 THEN
     p_retcode := 0;
     p_errbuf  := 'Accounting Program completed Normal';
   ELSE
     p_retcode := 1;
     p_errbuf  := 'Accounting Program completed Normal with some events in error';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_errbuf = '||p_errbuf
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_retcode = '||p_retcode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure accounting_program_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_accounting_batch_id    := g_accounting_batch_id;
   p_retcode                := 2;
   p_errbuf                 := xla_messages_pkg.get_message;

   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => p_errbuf
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   ROLLBACK TO SP_EVENTS;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'ROLLBACK issued in the procedure accounting_program_events'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   xla_accounting_err_pkg.insert_errors;

WHEN OTHERS THEN
   ----------------------------------------------------------------------------
   -- set out variables
   ----------------------------------------------------------------------------
   p_accounting_batch_id    := g_accounting_batch_id;
   p_retcode                := 2;
   p_errbuf                 := sqlerrm;

   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         (p_msg      => NULL
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
   END IF;

   ROLLBACK TO SP_EVENTS;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'ROLLBACK issued in the procedure accounting_program_events'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   xla_accounting_err_pkg.insert_errors;

END accounting_program_events; -- end of procedure

--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following routines are used while accounting for a document
--
--    1.    accounting_program_document  (procedure)
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================
--=============================================================================
--
--
--
--=============================================================================
PROCEDURE accounting_program_document
       (p_application_id             IN  INTEGER
       ,p_entity_id                  IN  NUMBER
       ,p_accounting_flag            IN  VARCHAR2    DEFAULT 'Y'
       ,p_accounting_mode            IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_offline_flag               IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER) IS
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.accounting_program_document';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure ACCOUNTING_PROGRAM_DOCUMENT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

  -- Bug 7560116 Journal Import not getting spawned as Security Context is not getting set correctly when
  --             this procedure is called directly to perform GL xfer
  xla_security_pkg.set_security_context(p_application_id);


   INSERT INTO xla_acct_prog_events_gt (event_id, ledger_id)
     SELECT xe.event_id, xte.ledger_id
       FROM xla_events                         xe
          , xla_transaction_entities           xte
      WHERE xte.application_id                 = p_application_id
        AND xte.entity_id                      = p_entity_id
        AND xe.application_id                  = p_application_id
        AND xe.entity_id                       = p_entity_id
        AND (p_accounting_flag = 'N' OR
             NVL(xe.budgetary_control_flag,'N') = DECODE(p_accounting_mode
                                                        ,'D','N'
                                                        ,'F','N'
                                                        ,'Y'));



    -- 7193986 start


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Rows inserted into xla_acct_prog_events_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;


   INSERT INTO xla_evt_class_orders_gt
      (event_class_code
      ,processing_order
      )
      SELECT xec.event_class_code
           , NVL(t.max_level, -1)
        FROM xla_event_classes_b xec
           , (SELECT application_id, event_class_code, max(LEVEL) AS max_level
                FROM (SELECT application_id, event_class_code, prior_event_class_code
                        FROM xla_event_class_predecs
                       WHERE application_id = p_application_id
                       UNION
                      SELECT application_id, prior_event_class_code, NULL
                        FROM xla_event_class_predecs
                       WHERE application_id = p_application_id) xep
                CONNECT BY application_id         = PRIOR application_id
                       AND prior_event_class_code = PRIOR event_class_code
                 GROUP BY application_id, event_class_code) t
       WHERE xec.event_class_code = t.event_class_code(+)
         AND xec.application_id   = t.application_id(+)
         AND xec.application_id   = p_application_id
         AND xec.event_class_code <> 'MANUAL';


    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of rows inserted into xla_evt_class_orders_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;

     -- 7193986 end




   xla_accounting_pkg.accounting_program_events
           (p_application_id      => p_application_id
           ,p_accounting_mode     => CASE WHEN p_accounting_flag = 'N'
                                          THEN 'NONE'
                                          WHEN p_accounting_mode = 'D'
                                          THEN 'DRAFT'
                                          when p_accounting_mode = 'F'
                                          THEN 'FINAL'
                                          ELSE p_accounting_mode END
           ,p_gl_posting_flag     => p_gl_posting_flag
           ,p_offline_flag        => p_offline_flag
           ,p_accounting_batch_id => p_accounting_batch_id
           ,p_errbuf              => p_errbuf
           ,p_retcode             => p_retcode);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure ACCOUNTING_PROGRAM_DOCUMENT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location   => 'xla_accounting_pkg.accounting_program_document');
END accounting_program_document; -- end of procedure


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following routines are used while accounting for batch of documents
--
--    1.    batch_accounting
--    2.    pre_accounting
--    3.    delete_request_je
--    4.    post_accounting
--    5.    enqueue_messages
--    6.    spawn_child_processes
--    7.    wait_for_requests
--    8.    unit_processor
--    9.    is_parent_running
--   10.    sequencing_batch_init
--   11.    process_events
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE batch_accounting IS
l_pre_processing_str              VARCHAR2(2000);



l_seq_api_called_flag             VARCHAR2(1) := 'N';

l_ret_flag_bal_reversal           BOOLEAN     := FALSE;
l_ret_flag_bal_update             BOOLEAN     := FALSE;

l_str_lock_entities               VARCHAR2(2000);
l_str_update_events               VARCHAR2(2000);

l_error_status                    VARCHAR2(1) := 'N';
l_warning_status                  VARCHAR2(1) := 'N';
l_log_module                      VARCHAR2(240);

l_acct_batch_entries              NUMBER;


BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.batch_accounting';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure BATCH_ACCOUNTING'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   -------------------------------------------------------------------------
   -- Reading setup options for the event application and the ledger
   -------------------------------------------------------------------------
   BEGIN

    SELECT xso.error_limit
          ,NVL(xso.processes,1)
          ,NVL(xso.processing_unit_size,1)
      INTO g_error_limit
          ,g_process_count
          ,g_unit_size
      FROM xla_subledger_options_v       xso
     WHERE xso.application_id          = g_application_id
       AND xso.ledger_id               = g_ledger_id;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'ERROR: Subledger Accounting Options are not defined for this ledger and application.'||
                                  'Please run Update Subledger Accounting Options program for your application.'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_accounting_pkg.batch_accounting');
   END;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_error_limit = '||g_error_limit
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_process_count = '||g_process_count
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'g_unit_size = '||g_unit_size
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Setup for the ledger and Event applications Read');

   ----------------------------------------------------------------------------
   -- perform pre-accounting steps
   ----------------------------------------------------------------------------
   pre_accounting();
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Pre-Accounting steps performed');

   ----------------------------------------------------------------------------
   -- initialize queue for loading documents and completion message
   ----------------------------------------------------------------------------
   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Creating message queue'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   dbms_aqadm.create_queue
      (queue_name                 => g_queue_name
      ,queue_table                => g_queue_table_name); --C_QUEUE_TABLE);
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue Created = '||g_queue_name);

   dbms_aqadm.create_queue
      (queue_name                 => g_comp_queue_name
      ,queue_table                => g_queue_table_name); --C_QUEUE_TABLE);
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue Created = '||g_comp_queue_name);

   g_queue_created_flag := 'Y';

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Message queue created'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'Starting Message queue'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   dbms_aqadm.start_queue
      (queue_name                 => g_queue_name);
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue Started = '||g_queue_name);

   dbms_aqadm.start_queue
      (queue_name                 => g_comp_queue_name);
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue Started = '||g_comp_queue_name);

   g_queue_started_flag := 'Y';

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Message queue started'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;
   ----------------------------------------------------------------------------
   -- Initialize the error count in the Global Application Context
   -- (for keeping error count accross multiple child processes)
   -- The context is set in context of "parent request id" which is same as
   -- "sys_context('USERENV','CLIENT_IDENTIFIER').
   ----------------------------------------------------------------------------
   xla_context_pkg.set_acct_err_context
      (p_error_count            => 0
      ,p_client_id              => g_parent_request_id);

   xla_context_pkg.set_event_count_context
      (p_event_count          => 0
      ,p_client_id            => g_parent_request_id);

   xla_context_pkg.set_event_nohdr_context
      (p_nohdr_extract_flag   => 'N'
      ,p_client_id            => g_parent_request_id);

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Global Context Initialized');

   ----------------------------------------------------------------------------
   -- Call sequencing routine batch_init in FINAL accounting
   ----------------------------------------------------------------------------
   IF g_accounting_mode = 'F' THEN
      sequencing_batch_init
         (p_seq_enabled_flag         => g_seq_enabled_flag);
      l_seq_api_called_flag := 'Y';
   END IF;

   dbms_session.set_identifier(client_id => g_parent_request_id); -- added for bug11903966
   ----------------------------------------------------------------------------
   -- enqueue messages in the queue
   ----------------------------------------------------------------------------
   --enqueue_messages;
   process_events;

   ----------------------------------------------------------------------------
   -- Check and wait for Event Processors to complete
   ----------------------------------------------------------------------------
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Waiting for Unit Processor requests to complete');
   wait_for_requests
      (p_array_request_id     => g_ep_request_ids
      ,p_error_status         => l_error_status
      ,p_warning_status       => l_warning_status);
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' -  Child Threads completed');

   ----------------------------------------------------------------------------
   -- calling post-accounting
   ----------------------------------------------------------------------------
 -- Bug 8282549  modified the call to pass g_queue_started_flag and g_queue_created_flag
   post_accounting
      (p_queue_started_flag       => g_queue_started_flag
      ,p_queue_created_flag       => g_queue_created_flag
      ,p_seq_api_called_flag      => l_seq_api_called_flag);

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Executed post-accounting routine');

   IF ((g_error_limit IS NOT NULL) AND
       (g_total_error_count >= g_error_limit)
      )
   THEN
     print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Message: The error limit defined in the setups was reached for this application');

    -- Bug 2742357. Print the message in the report also
            xla_accounting_err_pkg.build_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_AP_ERROR_LIMIT'
               ,p_entity_id      =>  NULL
               ,p_event_id       =>  NULL);


   END IF;

   COMMIT;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'COMMIT issued in BATCH_ACCOUNTING'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Call massive update only if there is any valid entry
   -- Bug 5065965. Modified the following sql for performance.
   ----------------------------------------------------------------------------
   SELECT COUNT(1) INTO l_acct_batch_entries FROM DUAL
    WHERE EXISTS
       (SELECT 'Y'
          FROM xla_events
         WHERE application_id      = g_application_id
           AND request_id          = g_report_request_id
           AND process_status_code IN ('P')
       );

   IF (l_acct_batch_entries > 0) THEN
    IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
          (p_msg      => 'Calling function XLA_BALANCES_PKG.MASSIVE_UPDATE'
          ,p_level    => C_LEVEL_EVENT
          ,p_module   => l_log_module);
      END IF;

      l_ret_flag_bal_update :=
       xla_balances_pkg.massive_update
         (p_application_id          => g_application_id --NULL
         ,p_ledger_id               => NULL
         ,p_entity_id               => NULL
         ,p_event_id                => NULL
         ,p_request_id              => NULL
         ,p_accounting_batch_id     => g_accounting_batch_id
         ,p_update_mode             => 'A'
         ,p_execution_mode          => 'C');

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace
         (p_msg      => 'Fucntion XLA_BALANCES_PKG.MASSIVE_UPDATE executed'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
      END IF;
     ELSE
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
          (p_msg      => 'Calling function xla_balances_calc_pkg.MASSIVE_UPDATE'
          ,p_level    => C_LEVEL_EVENT
          ,p_module   => l_log_module);
      END IF;

      l_ret_flag_bal_update :=
       xla_balances_calc_pkg.massive_update
         (p_application_id          => g_application_id --NULL
         ,p_ledger_id               => g_ledger_id
         ,p_entity_id               => NULL
         ,p_event_id                => NULL
         ,p_request_id              => NULL
         ,p_accounting_batch_id     => g_accounting_batch_id
         ,p_update_mode             => 'A'
         ,p_execution_mode          => 'C');

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace
         (p_msg      => 'Fucntion xla_balances_calc_pkg.MASSIVE_UPDATE executed'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
      END IF;
     END IF;


      IF NOT l_ret_flag_bal_update THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'l_ret_flag_bal_update = FALSE'
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;

         xla_accounting_err_pkg.build_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_AP_BAL_UPDATE_FAILED'
            ,p_entity_id      => NULL
            ,p_event_id       => NULL);

         print_logfile('Technical problem : Problem in submitting request for balance update');

         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_AP_BAL_UPDATE_FAILED');
      ELSE
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'l_ret_flag_bal_update = TRUE'
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;
         print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - request for balance calulation submitted');
      END IF;
   END IF;

   --
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' -  Accounting Program completed successfully');

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure BATCH_ACCOUNTING'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN normal_termination THEN
   RAISE;
WHEN xla_exceptions_pkg.application_exception THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'xla_exceptions_pkg.application_exception: BATCH_ACCOUNTING'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;

   ROLLBACK;
   ----------------------------------------------------------------------------
   -- calling post-accounting
   ----------------------------------------------------------------------------
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Post Accounting Started');
   -- Bug 8282549  modified the call to pass g_queue_started_flag and g_queue_created_flag
   post_accounting
      (p_queue_started_flag       => g_queue_started_flag
      ,p_queue_created_flag       => g_queue_created_flag
      ,p_seq_api_called_flag      => l_seq_api_called_flag);

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Post Accounting Ended');
   --

   RAISE;
WHEN OTHERS THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'Exception: BATCH_ACCOUNTING'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;

   ROLLBACK;
   ----------------------------------------------------------------------------
   -- calling post-accounting
   ----------------------------------------------------------------------------
   -- Bug 8282549  modified the call to pass g_queue_started_flag and g_queue_created_flag
   post_accounting
      (p_queue_started_flag       => g_queue_started_flag
      ,p_queue_created_flag       => g_queue_created_flag
      ,p_seq_api_called_flag      => l_seq_api_called_flag);

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Executed post-accounting routine');

   xla_accounting_err_pkg.build_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
      ,p_token_1        => 'APPLICATION_NAME'
      ,p_value_1        => 'SLA'
      ,p_entity_id      => NULL
      ,p_event_id       => NULL);
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_accounting_pkg.batch_accounting');
END batch_accounting;   -- end of procedure


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE pre_accounting IS
l_str_lock_entities               VARCHAR2(2000);
l_str_update_events               VARCHAR2(2000);
l_pre_processing_str              VARCHAR2(2000);
l_ret_flag_bal_reversal           BOOLEAN;
l_events_count                    NUMBER;
l_sqlerrm                         VARCHAR2(2000);
l_log_module                      VARCHAR2(240);
l_draft_exists_flag               VARCHAR2(1);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.pre_accounting';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure PRE_ACCOUNTING'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Handle preaccounting hook
   ----------------------------------------------------------------------------
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - executing preaccounting hook');
   handle_accounting_hook
              (p_application_id         => g_application_id
              ,p_ledger_id              => g_ledger_id
              ,p_process_category       => g_process_category
              ,p_end_date               => g_end_date
              ,p_accounting_mode        => g_accounting_mode
              ,p_budgetary_control_mode => g_budgetary_control_mode
              ,p_valuation_method       => g_valuation_method
              ,p_security_id_int_1      => g_security_id_int_1
              ,p_security_id_int_2      => g_security_id_int_2
              ,p_security_id_int_3      => g_security_id_int_3
              ,p_security_id_char_1     => g_security_id_char_1
              ,p_security_id_char_2     => g_security_id_char_2
              ,p_security_id_char_3     => g_security_id_char_3
              ,p_report_request_id      => NULL
              ,p_event_name             => 'preaccounting'
              ,p_event_key              => to_char(g_accounting_batch_id)||'-'
                                      ||to_char(g_parent_request_id));
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - preaccounting hook executed successfully');


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure PRE_ACCOUNTING'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN normal_termination THEN
   RAISE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_accounting_err_pkg.build_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
      ,p_token_1        => 'APPLICATION_NAME'
      ,p_value_1        => 'SLA'
      ,p_entity_id      => NULL
      ,p_event_id       => NULL);
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_accounting_pkg.pre_accounting');
END pre_accounting;   -- end of procedure


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE delete_request_je IS
l_log_module                      VARCHAR2(240);
l_delete_count                    NUMBER;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_request_je';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure DELETE_REQUEST_JE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   --
   -- Delete from xla_accounting_errors
   --
   DELETE FROM xla_accounting_errors
      WHERE event_id IN
               (SELECT event_id FROM xla_events_gt);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of errors deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   --
   -- Delete from xla_distribution_links
   --
   DELETE /*+ index(xdl,XLA_DISTRIBUTION_LINKS_N3) */ FROM xla_distribution_links xdl
   WHERE ae_header_id IN
           (SELECT  /*+ cardinality(XE,10) leading(XE) use_nl(XH) unnest */ xh.ae_header_id
              FROM xla_events_gt            xe,
                   xla_ae_headers           xh
             WHERE xe.process_status_code in ('D','E','R','I')
               AND xh.application_id = xe.application_id
               AND xh.event_id       = xe.event_id
           )
   AND application_id = g_application_id;

   l_delete_count := SQL%ROWCOUNT;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of distribution links deleted = '||l_delete_count
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF l_delete_count > 0 THEN
      --
      -- Delete from xla_ae_segment_values
      --
      DELETE /*+ index(XLA_AE_SEGMENT_VALUES, XLA_AE_SEGMENT_VALUES_U1) */
        FROM xla_ae_segment_values
       WHERE ae_header_id IN
           (SELECT xh.ae_header_id
              FROM xla_events_gt            xe,
                   xla_ae_headers           xh
             WHERE xe.process_status_code in ('D','E','R', 'I')
               AND xh.application_id = xe.application_id
               AND xh.event_id       = xe.event_id
           );

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of segment values deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      --
      -- Delete from xla_ae_line_acs
      --
      DELETE /*+ use_nl_with_index(XLA_AE_LINE_ACS,XLA_AE_LINE_ACS_U1) leading(VW_NSO_1) */
           FROM xla_ae_line_acs

       WHERE ae_header_id IN
                  (SELECT/*+ cardinality(evt,10) unnest */ aeh.ae_header_id
                     FROM xla_events_gt     evt
                         ,xla_ae_headers    aeh
                    WHERE evt.process_status_code in ('D','E','R','I')
                      AND aeh.application_id       = evt.application_id
                      AND aeh.event_id             = evt.event_id);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of line acs deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      --
      -- Delete from xla_ae_header_acs
      --
      DELETE FROM xla_ae_header_acs
         WHERE ae_header_id IN
               (SELECT aeh.ae_header_id
                  FROM xla_events_gt     evt
                      ,xla_ae_headers    aeh
                 WHERE evt.process_status_code in ('D','E','R','I')
                   AND aeh.application_id       = evt.application_id
                   AND aeh.event_id             = evt.event_id);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of header acs deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      --
      -- Delete from xla_ae_lines
      --
      DELETE FROM xla_ae_lines
         WHERE application_id  = g_application_id
           AND ae_header_id IN
           (SELECT xh.ae_header_id
              FROM xla_events_gt     xe,
                   xla_ae_headers           xh
             WHERE xe.process_status_code in ('D','E','R','I')
               AND xh.application_id = xe.application_id
               AND xh.event_id       = xe.event_id
           );

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of ae lines deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      --
      -- Delete from xla_ae_headers
      --
      DELETE /*+ index(aeh, xla_ae_headers_n2) */
        FROM xla_ae_headers aeh
       WHERE application_id = g_application_id
         AND event_id IN (SELECT event_id
                            FROM xla_events_gt
                           WHERE process_status_code IN ('D','E','R','I'));

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of ae headers deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

   END IF;

   ----------------------------------------------------------------------------
   --
   -- Used by the Accounting Event Extract Diagnostics process
   --
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   -- following deletes the Accounting Event Extract Diagnostics data
   -- for the events that are being accounted in this run.
   ----------------------------------------------------------------------------

   IF (  nvl(fnd_profile.value('XLA_DIAGNOSTIC_MODE'),'N') = 'Y') THEN

      DELETE FROM xla_diag_sources
         WHERE event_id IN
               (SELECT event_id FROM xla_events_gt);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of Extract sources rows deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      DELETE FROM xla_diag_events
      WHERE event_id IN
               (SELECT event_id FROM xla_events_gt);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of Extract events deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
      --bug6369888
      DELETE FROM xla_diag_ledgers d
	WHERE d.application_id = g_application_id
	AND NOT EXISTS
		(SELECT ledger_id,     request_id
		 FROM xla_diag_events
		WHERE application_id = d.application_id
		AND   request_id = d.accounting_request_id
		AND   ledger_id = d.primary_ledger_id
		 );

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of Extract ledgers deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
     END IF;

   END IF;

   ----------------------------------------------------------------------------
   --
   -- End of code used  by the Accounting Event Extract Diagnostics process
   --
   ----------------------------------------------------------------------------


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure DELETE_REQUEST_JE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_pkg.delete_request_je');
END delete_request_je;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE post_accounting
       (p_queue_started_flag         IN OUT NOCOPY VARCHAR2
       ,p_queue_created_flag         IN OUT NOCOPY VARCHAR2
       ,p_seq_api_called_flag        IN OUT NOCOPY VARCHAR2) IS
l_seq_status                      VARCHAR2(30);
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.post_accounting';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure POST_ACCOUNTING'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
   dbms_session.set_identifier(client_id => g_parent_request_id); -- added for bug11903966
   ----------------------------------------------------------------------------
   -- Total error error counts are read into a local variable before the
   -- global context is cleared. This is later used to set the 'p_retcode'.
   -- bug # 2709397.
   ----------------------------------------------------------------------------
   g_total_error_count := xla_accounting_err_pkg.get_total_error_count;


   --
   -- 4865292
   -- Compare event count with header extract count
   -- Display messages when the counts are different
   --
   IF xla_context_pkg.get_event_nohdr_context = 'Y' THEN

      xla_accounting_err_pkg.build_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_NO_HDR_EXTRACT'
         ,p_entity_id      => NULL
         ,p_event_id       => NULL
         ,p_ledger_id      => g_ledger_id);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_total_error_count = '||g_total_error_count
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- clean up the global application context
   ----------------------------------------------------------------------------
   xla_context_pkg.clear_acct_err_context
      (p_client_id            => g_parent_request_id);

   xla_context_pkg.clear_event_context
      (p_client_id            => g_parent_request_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Global Context cleared'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Global Context cleared');

   ----------------------------------------------------------------------------
   -- clean up queues for each event application
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_queue_started_flag = '||p_queue_started_flag
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_queue_created_flag = '||p_queue_created_flag
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF p_queue_started_flag = 'Y' THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Ready to stop the message queue'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      dbms_aqadm.stop_queue(queue_name     => g_queue_name
                           ,wait           => TRUE);               --5056507
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue stopped = '||g_queue_name);
      dbms_aqadm.stop_queue(queue_name     => g_comp_queue_name
                           ,wait           => TRUE);               --5056507
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue stopped = '||g_comp_queue_name);
      p_queue_started_flag := 'N';

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Message queue stopped'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

   IF p_queue_created_flag = 'Y' THEN
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Ready to drop the message queue'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      dbms_aqadm.drop_queue(queue_name     => g_queue_name);
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue dropped = '||g_queue_name);
      dbms_aqadm.drop_queue(queue_name     => g_comp_queue_name);
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Queue dropped = '||g_comp_queue_name);
      p_queue_created_flag := 'N';

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Message queue dropped'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

   ----------------------------------------------------------------------------
   -- Call sequencing batch_exit
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_seq_api_called_flag = '||p_seq_api_called_flag
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF p_seq_api_called_flag = 'Y' THEN
      BEGIN
         print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Calling sequencing batch_exit');

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Calling the procedure FUN_SEQ_BATCH.BATCH_EXIT'
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;

         fun_seq_batch.batch_exit
            (p_request_id             => g_parent_request_id
            ,x_status                 => l_seq_status);
         p_seq_api_called_flag := 'N';
         print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Returned from sequencing batch_exit');

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Procedure FUN_SEQ_BATCH.BATCH_EXIT executed'
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'l_seq_status = '||l_seq_status
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;

         IF l_seq_status <> 'SUCCESS' THEN
            xla_accounting_err_pkg.build_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
               ,p_token_1        => 'APPLICATION_NAME'
               ,p_value_1        => 'SLA'
               ,p_entity_id      => NULL
               ,p_event_id       => NULL);

            print_logfile('Technical problem : Problem encountered in sequencing BATCH_EXIT. '||
                          'Please submit the concurrent program to compelte this process');
         END IF;
      EXCEPTION
      WHEN OTHERS THEN
         xla_accounting_err_pkg.build_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
            ,p_token_1        => 'APPLICATION_NAME'
            ,p_value_1        => 'SLA'
            ,p_entity_id      => NULL
            ,p_event_id       => NULL);

         print_logfile('Technical problem : Problem encountered in sequencing BATCH_EXIT. '||
                       'Please submit the concurrent program to compelte this process');
      END;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure POST_ACCOUNTING'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_accounting_err_pkg.build_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
      ,p_token_1        => 'APPLICATION_NAME'
      ,p_value_1        => 'SLA'
      ,p_entity_id      => NULL
      ,p_event_id       => NULL);
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_pkg.post_accounting');
END post_accounting;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE enqueue_messages
(p_processing_order           INTEGER
,p_max_processing_order       INTEGER
,p_children_spawned           IN OUT NOCOPY BOOLEAN
,p_msg_count                  IN OUT NOCOPY INTEGER)
IS
TYPE ref_cur_type IS REF CURSOR;
csr_event_class    ref_cur_type;
csr_entity         ref_cur_type;

l_cur_event_stmt       VARCHAR2(8000);
l_cur_entity_stmt      VARCHAR2(8000);

l_entity_id           xla_array_number_type; -- xla_number_array_type;
l_entity_found        BOOLEAN  := FALSE;
l_children_spawned    BOOLEAN  := FALSE;
l_unit_count          NUMBER   := 0;
l_enq_options         dbms_aq.enqueue_options_t;
l_msg_prop            dbms_aq.message_properties_t;
l_message             xla_queue_msg_type; --SYSTEM.xla_queue_msg_type;
l_msgid               RAW(16);

l_event_class_code    VARCHAR2(30);
l_unit_size           NUMBER   := 0;

l_log_module                      VARCHAR2(240);
l_combine_event_classes           VARCHAR2(10000);
l_anytime_class                   VARCHAR2(5000);
l_current_class                   VARCHAR2(5000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.enqueue_messages';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure ENQUEUE_MESSAGES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_processing_order = '||p_processing_order
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Ready to Enqueue documents in the queue');
   -------------------------------------------------------------------------------
   -- Retrieve Processing Unit Size at Event Class Level
   -------------------------------------------------------------------------------
   --bug6369888 changed cursor to merge into single query.
   l_cur_event_stmt :=
      'SELECT /*+ index(evt,XLA_EVENTS_N3) */ MIN(nvl(xjc.processing_unit_size,   :1))
  FROM xla_events evt,
       xla_transaction_entities ent,
       xla_event_types_b xet,
       xla_event_class_attrs eca,
       xla_evt_class_orders_gt xpo,
       xla_je_categories xjc
   WHERE ent.application_id = :3
     AND ent.ledger_id = :4
     AND evt.application_id = :5
     AND evt.entity_id = ent.entity_id
     AND xet.application_id = evt.application_id
     AND xet.event_type_code = evt.event_type_code
     AND eca.application_id = xet.application_id
     AND eca.entity_code = xet.entity_code
     AND eca.event_class_code = xet.event_class_code
     AND eca.event_class_group_code = nvl(:6,    eca.event_class_group_code)
     AND evt.event_type_code NOT IN(''FULL_MERGE'',    ''PARTIAL_MERGE'')
     AND evt.process_status_code IN(''I'',    ''E'',    ''R'',    decode(:7,    ''N'',    ''D'',    ''E''),    decode(:8,    ''N'',    ''U'',    ''E''))
     AND evt.event_status_code IN(''U'',    decode(:9,    ''F'',    ''N'',    ''U''))
     AND evt.on_hold_flag = ''N''
     AND evt.event_date <= :10
     AND ent.entity_code <> :11
     AND nvl(evt.budgetary_control_flag,    ''N'') = ''N''
     AND xet.event_class_code = xpo.event_class_code
     AND xpo.processing_order = :2
     AND xjc.application_id = :12
     AND xjc.ledger_id = :13
     AND xjc.event_class_code = xpo.event_class_code '
     ||g_security_condition;

l_cur_entity_stmt :=
   'SELECT /*+ leading(evt) use_nl(ent) index(evt,XLA_EVENTS_N3) */  -- Bug 5529420 reverted bug6369888 modified hint bug9192859
          DISTINCT evt.entity_id
     FROM xla_events                 evt
         ,xla_transaction_entities   ent
         ,xla_event_types_b          xet
         ,xla_event_class_attrs      eca
         ,xla_evt_class_orders_gt    xpo
    WHERE ent.application_id                    = :1
      AND ent.ledger_id                         = :2
      AND evt.application_id                    = :3
      AND evt.entity_id                         = ent.entity_id
      AND xet.application_id                    = evt.application_id
      AND xet.event_type_code                   = evt.event_type_code
      AND eca.application_id                    = xet.application_id
      AND eca.entity_code                       = xet.entity_code
      AND eca.event_class_code                  = xet.event_class_code
      AND eca.event_class_group_code            = NVL(:4, eca.event_class_group_code)
      AND evt.event_type_code              NOT IN (''FULL_MERGE'', ''PARTIAL_MERGE'')
      AND evt.process_status_code              IN (''I'',''E'', ''R'',DECODE(:5,''N'',''D'',''E'')
                                                               ,DECODE(:6,''N'',''U'',''E'')
                                                  )
      AND evt.event_status_code                IN (''U'',DECODE(:7,''F'',''N'',''U''))
      AND evt.on_hold_flag                      = ''N''
      AND evt.event_date                       <= :8
      AND ent.entity_code                      <> :9
      AND NVL(evt.budgetary_control_flag,''N'')   = ''N''
      AND xet.event_class_code                  = xpo.event_class_code
      AND xpo.processing_order                  = :10 '
      ||g_security_condition;

   ----------------------------------------------------------------------------
   -- initiating queue/message related variables
   ----------------------------------------------------------------------------
   l_enq_options.visibility          := dbms_aq.IMMEDIATE;
   l_enq_options.relative_msgid      := NULL;
   l_enq_options.sequence_deviation  := NULL;

   IF (p_processing_order = -1) THEN
     l_msg_prop.priority             := p_max_processing_order+1;
   ELSE
     l_msg_prop.priority             := p_processing_order;
   END IF;
   l_msg_prop.DELAY                  := dbms_aq.NO_DELAY;
   l_msg_prop.expiration             := dbms_aq.NEVER;
   l_msg_prop.correlation            := NULL;
   l_msg_prop.exception_queue        := NULL;
   l_msg_prop.sender_id              := NULL;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
      (p_msg      => 'l_cur_event_stmt '||l_cur_event_stmt
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
   END IF;
   --bug6369888 removed loop
   SELECT MAX(xjc.processing_unit_size)
   INTO l_unit_size
        FROM xla_je_categories xjc,
         (
          SELECT
          xpo.event_class_code
          FROM xla_evt_class_orders_gt xpo
          WHERE xpo.processing_order = p_processing_order
         )    tab1
   WHERE xjc.application_id   = g_application_id
   AND xjc.ledger_id        = g_ledger_id
   AND xjc.event_class_code = tab1.event_class_code;

   IF l_unit_size <> NULL THEN
	OPEN csr_event_class FOR l_cur_event_stmt USING g_unit_size
                                                  ,p_processing_order
                                                  ,g_application_id
                                                  ,g_ledger_id
                                                  ,g_application_id
                                                  ,g_process_category
                                                  ,g_error_only_flag
                                                  ,g_error_only_flag
                                                  ,g_accounting_mode
                                                  ,g_end_date
                                                  ,C_MANUAL
                                                  ,g_application_id
                                                  ,g_ledger_id ;
	FETCH csr_event_class INTO l_unit_size;
	CLOSE csr_event_class;
    END IF;

      -------------------------------------------------------------------------------------------------
      -- 4597150 Find all event class for process order of -1
      -------------------------------------------------------------------------------------------------
      l_anytime_class := concat_event_classes(-1);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_msg      => 'Event class for processing order of -1 = '||l_anytime_class
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      END IF;

      ----------------------------------------------------------
      -- 4597150 Find all event class for current process order
      ----------------------------------------------------------
      IF p_processing_order <> -1 THEN
         l_current_class := concat_event_classes(p_processing_order);
      ELSE
         l_current_class := l_anytime_class;
	 l_anytime_class := ''; -- 14105024
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'Event class for processing order of '
                             ||p_processing_order||' = '||l_current_class
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
      END IF;

      -------------------------------------------------------------------------
      -- 4597150 : combine Current and Anytime event classes
      -- e.g. 'EC1','EC2'#-#-#-#-#-#-#-#'EC3','EC4'
      -- When Current Process Order is -1, l_current_class = l_anytime_class
      -------------------------------------------------------------------------
      l_combine_event_classes  := l_current_class||C_DELIMITER||l_anytime_class;
      l_msg_prop.user_property :=
                           SYS.AnyData.ConvertVarchar2(l_combine_event_classes);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_msg      => 'l_cur_entity_stmt '||l_cur_entity_stmt
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      END IF;

      OPEN csr_entity FOR l_cur_entity_stmt USING g_application_id
                                                 ,g_ledger_id
                                                 ,g_application_id
                                                 ,g_process_category
                                                 ,g_error_only_flag
                                                 ,g_error_only_flag
                                                 ,g_accounting_mode
                                                 ,g_end_date
                                                 ,C_MANUAL
                                                 ,p_processing_order;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'g_unit_size '||g_unit_size
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      ----------------------------------------------------------------------------
      -- loop for each data fetched from the cursor. This will enqueue the data
      -- in the queue
      ----------------------------------------------------------------------------
      LOOP
         FETCH csr_entity BULK COLLECT INTO l_entity_id LIMIT NVL(l_unit_size,g_unit_size);

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => ' l_entity_id.COUNT ='||l_entity_id.COUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            FOR i in 1..l_entity_id.COUNT LOOP
                trace
                   (p_msg      => 'entity_id ='||l_entity_id(i)
                   ,p_level    => C_LEVEL_STATEMENT
                   ,p_module   => l_log_module);
            END LOOP;
         END IF;

         -------------------------------------------------------------------------
         -- following is the only way to exit the indefinite loop. It exits when
         -- no documents are fetched into the array variable 'l_entity_id'
         -------------------------------------------------------------------------
         EXIT WHEN l_entity_id.COUNT = 0;

         IF NOT p_children_spawned THEN
            ----------------------------------------------------------------------------
            -- spawn parallel processes, "event processors" for processing documents.
            -- number of paralle process spawned depends on the ledger setup
            ----------------------------------------------------------------------------
            --
            print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Spawning unit processors');

            spawn_child_processes;
            p_children_spawned := TRUE;
            print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Unit processors spawned');

         END IF;

         -------------------------------------------------------------------------
         -- l_entity_found is set to TRUE to indicate that there are events that
         -- that are eligible to be processed
         -------------------------------------------------------------------------
         l_entity_found := TRUE;
         l_unit_count := l_unit_count + 1;
         p_msg_count := p_msg_count + 1;

         -------------------------------------------------------------------------
         -- create a message from the fetched entity ids.
         -------------------------------------------------------------------------
         l_message      := xla_queue_msg_type(l_entity_id); --SYSTEM.xla_queue_msg_type(l_entity_id);

         -------------------------------------------------------------------------
         -- enqueue the message in the queue
         -------------------------------------------------------------------------
         dbms_aq.enqueue
            (g_queue_name
            ,l_enq_options
            ,l_msg_prop
            ,l_message
            ,l_msgid);

         g_parent_data.total_entity_count := g_parent_data.total_entity_count +
                                             csr_entity%ROWCOUNT;
      END LOOP;

      CLOSE csr_entity;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure ENQUEUE_MESSAGES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  IF csr_event_class%NOTFOUND THEN
     xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'Journal categories does not have data for this ledger and application.
                                  Please run Update Subledger Accounting Options program for your
                                  application '||'ledger_id = '||g_ledger_id||
                                 ' application_id = '|| g_application_id
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_accounting_pkg.enqueue_messages');
  END IF;
WHEN normal_termination THEN
   IF csr_entity%ISOPEN THEN
     CLOSE csr_entity;
   END IF;
   RAISE;
WHEN xla_exceptions_pkg.application_exception THEN
   IF csr_entity%ISOPEN THEN
     CLOSE csr_entity;
   END IF;
   RAISE;
WHEN OTHERS THEN
   IF csr_entity%ISOPEN THEN
     CLOSE csr_entity;
   END IF;
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_accounting_pkg.enqueue_messages');
END enqueue_messages;  -- end of procedure

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE dequeue_completion_messages
(p_msg_count       INTEGER)
IS
l_msgid                 RAW(16);
l_conf_msg_prop         dbms_aq.message_properties_t;
l_conf_message          xla_queue_msg_type; -- SYSTEM.xla_queue_msg_type;
l_deq_options           dbms_aq.dequeue_options_t;
l_msg_count             INTEGER;

l_log_module            VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.dequeue_completion_messages';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure dequeue_completion_messages'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN LOOP : dequeue completion messges - p_msg_count = '||p_msg_count
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   l_deq_options.consumer_name  := NULL;
   l_deq_options.dequeue_mode   := dbms_aq.REMOVE;
   l_deq_options.navigation     := dbms_aq.FIRST_MESSAGE;
   l_deq_options.visibility     := dbms_aq.IMMEDIATE;
   l_deq_options.wait           := 60;
   l_deq_options.msgid          := NULL;
   l_deq_options.correlation    := NULL;

   l_msg_count                  := p_msg_count;

   --
   -- Get completion messages for all document messages before proceeding
   --
   WHILE (l_msg_count > 0) LOOP
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'LOOP : dequeue completion messges : '||p_msg_count
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      l_msgid := NULL;
      BEGIN

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Begin LOOP : dequeue completion messges : '||p_msg_count
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;

         dbms_aq.dequeue
             (g_comp_queue_name
             ,l_deq_options
             ,l_conf_msg_prop
             ,l_conf_message
             ,l_msgid);

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Dequeue one completion message'
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;

         l_msg_count := l_msg_count - 1;

      EXCEPTION
         WHEN OTHERS THEN
            IF (C_LEVEL_EVENT >= g_log_level) THEN
               trace
                  (p_msg      => 'No completion message to dequeue'
                  ,p_level    => C_LEVEL_EVENT
                  ,p_module   => l_log_module);
            END IF;

            IF (NOT is_any_child_running) THEN
               IF (C_LEVEL_EVENT >= g_log_level) THEN
                  trace
                     (p_msg      => 'No children process running : EXIT dequeue completion message'
                     ,p_level    => C_LEVEL_EVENT
                     ,p_module   => l_log_module);
               END IF;

               EXIT;
            END IF;

      END;
   END LOOP;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'END LOOP : dequeue completion messges'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure dequeue_completion_messages'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN normal_termination THEN
   RAISE;
WHEN xla_exceptions_pkg.application_exception THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'xla_exceptions_pkg.application_exception: dequeue_completion_messages'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN OTHERS THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'EXCEPTION: dequeue_completion_messages'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_pkg.dequeue_completion_messages');
END dequeue_completion_messages; -- end of procedure




--=============================================================================
--
--
--
--=============================================================================
PROCEDURE process_events IS
l_children_spawned      BOOLEAN;
l_msg_count             INTEGER;
l_msg_count2            INTEGER;
l_total_msg_count       INTEGER;
l_enq_options           dbms_aq.enqueue_options_t;
l_msg_prop              dbms_aq.message_properties_t;
l_message               xla_queue_msg_type; -- SYSTEM.xla_queue_msg_type;
l_msgid                 RAW(16);
l_max_processing_order  INTEGER;
l_num_level             INTEGER;

l_log_module            VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.process_events';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure process_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   INSERT INTO xla_evt_class_orders_gt
      (event_class_code
      ,processing_order
      )
      SELECT xec.event_class_code
           , NVL(t.max_level, -1)
        FROM xla_event_classes_b xec
           , (SELECT application_id, event_class_code, max(LEVEL) AS max_level
                FROM (SELECT application_id, event_class_code, prior_event_class_code
                        FROM xla_event_class_predecs
                       WHERE application_id = g_application_id
                       UNION
                      SELECT application_id, prior_event_class_code, NULL
                        FROM xla_event_class_predecs
                       WHERE application_id = g_application_id) xep
                CONNECT BY application_id         = PRIOR application_id
                       AND prior_event_class_code = PRIOR event_class_code
                 GROUP BY application_id, event_class_code) t
       WHERE xec.event_class_code = t.event_class_code(+)
         AND xec.application_id   = t.application_id(+)
         AND xec.application_id   = g_application_id
         AND xec.event_class_code <> 'MANUAL';

   SELECT max(processing_order)
     INTO l_max_processing_order
     FROM xla_evt_class_orders_gt;

   IF (l_max_processing_order = -1) THEN
      l_num_level := 1;
   ELSE
      l_num_level := l_max_processing_order + 1; -- 5113664 to loop one more to handle -1 process order
   END IF;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Max processing order = '||l_max_processing_order
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   g_parent_data.total_entity_count := 0;

   l_total_msg_count      := 0;
   l_msg_count            := 0;
   l_children_spawned     := FALSE;

   l_enq_options.visibility         := dbms_aq.IMMEDIATE;
   l_enq_options.relative_msgid     := NULL;
   l_enq_options.sequence_deviation := NULL;

   l_msg_prop.priority        := l_max_processing_order + 2;
   l_msg_prop.DELAY           := dbms_aq.NO_DELAY;
   l_msg_prop.expiration      := dbms_aq.NEVER;
   l_msg_prop.correlation     := NULL;
   l_msg_prop.exception_queue := NULL;
   l_msg_prop.sender_id       := NULL;

   l_message := xla_queue_msg_type(NULL); -- SYSTEM.xla_queue_msg_type(NULL);

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN LOOP : enqueue document messges'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   --
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Begin enqueue');
   --
   -- Porcess document starting from the event with lowest processing event
   --
   FOR i IN 1..l_num_level LOOP
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'LOOP : enqueue document messges : '||i
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      IF (l_max_processing_order > 0) THEN

         l_msg_count := 0;

         --------------------------------------------------------------------------------------------------------------------
         -- 5113664
         -- To handle case when only processing order -1 events exist, and there are no events for other processing order.
         -- When enqueue_message cannot find events of processing order 'i' in csr_entity, it also cannot process -1 order events.
         -- Therefore -1 events will not be processed.
         -- Increase l_num_level by 1 more than l_max_processing_order to act as a dummy to loop for any remaining -1 events.
         -- This is like a 'catch all'.
         --------------------------------------------------------------------------------------------------------------------
         IF i <= l_max_processing_order THEN
            enqueue_messages(p_processing_order     => i
                            ,p_children_spawned     => l_children_spawned
                            ,p_max_processing_order => l_max_processing_order
                            ,p_msg_count            => l_msg_count);
         ELSE
            enqueue_messages(p_processing_order     => -1
                            ,p_children_spawned     => l_children_spawned
                            ,p_max_processing_order => l_max_processing_order
                            ,p_msg_count            => l_msg_count);
         END IF;

         l_total_msg_count := l_total_msg_count + l_msg_count;

      --------------------------------------------------------------------------------------------------------
      -- 4597150 l_max_processing_order < 0 implies only process order -1 exists, and no other process orders.
      -- Only call enqueue_messages with -1 if there are no other process orders.
      --------------------------------------------------------------------------------------------------------
      ELSE
         l_msg_count := 0;
         enqueue_messages(p_processing_order     => -1
                         ,p_children_spawned     => l_children_spawned
                         ,p_max_processing_order => l_max_processing_order
                         ,p_msg_count            => l_msg_count);
         l_total_msg_count := l_total_msg_count + l_msg_count;
      END IF;

      --
      -- After queueing the highest priority events, queue the events that can
      -- be processed anytime
      --
      /* 4597150
      IF (i = 1) THEN
         l_msg_count2 := 0;
         enqueue_messages(p_processing_order     => -1
                         ,p_children_spawned     => l_children_spawned
                         ,p_max_processing_order => l_max_processing_order
                         ,p_msg_count            => l_msg_count2);
         l_total_msg_count := l_total_msg_count + l_msg_count2;
      END IF;
      */

      IF (l_children_spawned) THEN
         --
         -- If after processing the last processing order message and
         -- child processes are created, enqueue NULL messages to the
         -- document queue to signal the child processes that there is
         -- no more documents to be processed
         --
         -- 5113664 increase l_max_processing_order by 1 since l_num_level is increased also
         -- IF (i = l_max_processing_order OR l_max_processing_order = -1) THEN
         IF (i = (l_max_processing_order+1) OR l_max_processing_order = -1) THEN

            IF (C_LEVEL_EVENT >= g_log_level) THEN
               trace
                  (p_msg      => 'BEGIN LOOP : enqueue dummy messges'
                  ,p_level    => C_LEVEL_EVENT
                  ,p_module   => l_log_module);
            END IF;

            FOR j IN 1..g_process_count LOOP
               IF (C_LEVEL_EVENT >= g_log_level) THEN
                  trace
                     (p_msg      => 'LOOP : enqueue dummy messges : '||j
                     ,p_level    => C_LEVEL_EVENT
                     ,p_module   => l_log_module);
               END IF;

               dbms_aq.enqueue
                    (g_queue_name
                    ,l_enq_options
                    ,l_msg_prop
                    ,l_message
                    ,l_msgid);
            END LOOP;

            IF (C_LEVEL_EVENT >= g_log_level) THEN
               trace
                  (p_msg      => 'END LOOP: enqueue dummy messges'
                  ,p_level    => C_LEVEL_EVENT
                  ,p_module   => l_log_module);
            END IF;

         END IF;

         IF (l_msg_count > 0) THEN
           dequeue_completion_messages(p_msg_count => l_msg_count);
         END IF;

         IF (NOT is_any_child_running) THEN

            IF (C_LEVEL_EVENT >= g_log_level) THEN
               trace
                  (p_msg      => 'No children process running : EXIT processing events'
                  ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
            END IF;

            EXIT;
         END IF;

      END IF; -- if l_children_spawned

   END LOOP;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'END LOOP : enqueue document messges'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   IF (NOT l_children_spawned) THEN
      xla_accounting_err_pkg.build_message
               (p_appli_s_name      => 'XLA'
               ,p_msg_name          => 'XLA_AP_NO_EVENT_TO_PROCESS'
               ,p_entity_id         => NULL
               ,p_event_id          => NULL);

      print_logfile('Technical warning : There are no events to process.');

      RAISE normal_termination;

   ELSE
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Enqueueing completed');

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of processing units = '||l_total_msg_count
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      => 'Number of entities = '|| g_parent_data.total_entity_count
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure process_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN normal_termination THEN
   RAISE;
WHEN xla_exceptions_pkg.application_exception THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'xla_exceptions_pkg.application_exception: process_events'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN OTHERS THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'EXCEPTION: process_events'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_pkg.process_events');
END process_events; -- end of procedure



--=============================================================================
--
--
--
--=============================================================================
PROCEDURE spawn_child_processes IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_ep_request_ids                  xla_accounting_pkg.t_array_number;
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.spawn_child_processes';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure SPAWN_CHILD_PROCESSES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   FOR i IN 1..(g_process_count) LOOP
      l_ep_request_ids(i) :=
         fnd_request.submit_request
            (application     => 'XLA'
            ,program         => 'XLAACCUP'
            ,description     => NULL
            ,start_time      => NULL
            ,sub_request     => FALSE
            ,argument1       => g_application_id
            ,argument2       => g_ledger_id
            ,argument3       => to_char(g_end_date,'YYYY/MM/DD')
            ,argument4       => g_accounting_mode
            ,argument5       => g_error_only_flag
            ,argument6       => g_accounting_batch_id
            ,argument7       => g_parent_request_id
            ,argument8       => g_report_request_id
            ,argument9       => g_queue_name
            ,argument10      => g_comp_queue_name
            ,argument11      => g_error_limit
            ,argument12      => g_seq_enabled_flag
            ,argument13      => g_transfer_flag
            ,argument14      => g_gl_posting_flag
            ,argument15      => g_gl_batch_name);  -- Bug 5257343

      IF l_ep_request_ids(i) = 0 THEN
         IF (C_LEVEL_EXCEPTION>= g_log_level) THEN
            trace
               (p_msg      => 'Technical Error : Unable to submit child requests.'
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
         END IF;

         xla_accounting_err_pkg.build_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
            ,p_token_1        => 'APPLICATION_NAME'
            ,p_value_1        => 'SLA'
            ,p_entity_id      => NULL
            ,p_event_id       => NULL);

         print_logfile('Technical Error : Unable to submit child requests');

         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'LOCATION'
            ,p_value_1        => 'xla_accounting_pkg.spawn_child_processes'
            ,p_token_2        => 'ERROR'
            ,p_value_2        => 'Technical Error : Unable to submit child requests.');

      END IF;
   END LOOP;

   g_ep_request_ids := l_ep_request_ids;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      FOR i IN 1 .. l_ep_request_ids.count LOOP
         trace
            (p_msg      => 'Submitted unit processor request = '||l_ep_request_ids(i)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END LOOP;
   END IF;

   COMMIT;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'COMMIT issued in AUTONOMOUS_TRANSACTION procedure SPAWN_CHILD_PROCESSES'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure SPAWN_CHILD_PROCESSES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_pkg.spawn_child_processes');
END spawn_child_processes; -- end of procedure


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE wait_for_requests
       (p_array_request_id           IN  t_array_number
       ,p_error_status               OUT NOCOPY VARCHAR2
       ,p_warning_status             OUT NOCOPY VARCHAR2) IS
l_phase                           VARCHAR2(30);
l_status                          VARCHAR2(30);
l_dphase                          VARCHAR2(30);
l_dstatus                         VARCHAR2(30);
l_message                         VARCHAR2(240);
l_btemp                           BOOLEAN;
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.wait_for_requests';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure WAIT_FOR_REQUESTS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Waiting for active/pending requests to complete
   ----------------------------------------------------------------------------
   IF p_array_request_id.count > 0 THEN
      FOR i IN 1..p_array_request_id.count LOOP

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'waiting for request id = '||p_array_request_id(i)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;

         l_btemp := fnd_concurrent.wait_for_request
                       (request_id    => p_array_request_id(i)
                       ,interval      => 30
                       ,phase         => l_phase
                       ,status        => l_status
                       ,dev_phase     => l_dphase
                       ,dev_status    => l_dstatus
                       ,message       => l_message);
         IF NOT l_btemp THEN
            xla_accounting_err_pkg.build_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
               ,p_token_1        => 'APPLICATION_NAME'
               ,p_value_1        => 'SLA'
               ,p_entity_id      => NULL
               ,p_event_id       => NULL);

            print_logfile('Technical problem : FND_CONCURRENT.WAIT_FOR_REQUEST returned FALSE '||
                          'while executing for request id '||p_array_request_id(i));
         ELSE
            IF (C_LEVEL_EVENT >= g_log_level) THEN
               trace
                  (p_msg      => 'request completed with status = '||l_status
                  ,p_level    => C_LEVEL_EVENT
                  ,p_module   => l_log_module);
            END IF;

            IF l_dstatus = 'WARNING' THEN
               p_warning_status := 'Y';
            ELSIF l_dstatus = 'ERROR' THEN
               p_error_status := 'Y';
            END IF;
         END IF;
      END LOOP;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure WAIT_FOR_REQUESTS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
               (p_location       => 'xla_accounting_pkg.wait_for_requests');
END wait_for_requests;  -- end of procedure

--FSAH-PSFT FP
 --=============================================================================
 --
 --
 --
 --=============================================================================
 PROCEDURE wait_for_combo_edit_req
 (p_request_id                 IN  NUMBER
 ,p_error_status               OUT NOCOPY VARCHAR2
 ,p_warning_status             OUT NOCOPY VARCHAR2) IS
 l_phase                           VARCHAR2(30);
 l_status                          VARCHAR2(30);
 l_dphase                          VARCHAR2(30);
 l_dstatus                         VARCHAR2(30);
 l_message                         VARCHAR2(240);
 l_btemp                           BOOLEAN;
 l_log_module                      VARCHAR2(240);
 BEGIN
 IF g_log_enabled THEN
 l_log_module := C_DEFAULT_MODULE||'.wait_for_combo_edit_req';
 END IF;
 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
 trace
   (p_msg      => 'BEGIN of procedure WAIT_FOR_COMBO_EDIT_REQ'
   ,p_level    => C_LEVEL_PROCEDURE
   ,p_module   => l_log_module);
 END IF;

 ----------------------------------------------------------------------------
 -- Waiting for active/pending requests to complete
 ----------------------------------------------------------------------------
 IF p_request_id <> 0 THEN
     l_btemp := fnd_concurrent.wait_for_request
		 (request_id    => p_request_id
		 ,interval      => 30
		 ,phase         => l_phase
		 ,status        => l_status
		 ,dev_phase     => l_dphase
		 ,dev_status    => l_dstatus
		 ,message       => l_message);
   IF NOT l_btemp THEN
      xla_accounting_err_pkg.build_message
	 (p_appli_s_name   => 'XLA'
	 ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
	 ,p_token_1        => 'APPLICATION_NAME'
	 ,p_value_1        => 'SLA'
	 ,p_entity_id      => NULL
	 ,p_event_id       => NULL);

      print_logfile('Technical problem : FND_CONCURRENT.WAIT_FOR_REQUEST returned FALSE '||
		    'while executing for request id '||p_request_id);
   ELSE
      IF (C_LEVEL_EVENT >= g_log_level) THEN
	 trace
	    (p_msg      => 'request completed with status = '||l_status
	    ,p_level    => C_LEVEL_EVENT
	    ,p_module   => l_log_module);
      END IF;

      IF l_dstatus = 'WARNING' THEN
	 p_warning_status := 'Y';
      ELSIF l_dstatus = 'ERROR' THEN
	 p_error_status := 'Y';
      END IF;
   END IF;
 END IF;

 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
 trace
   (p_msg      => 'END of procedure WAIT_FOR_REQUESTS'
   ,p_level    => C_LEVEL_PROCEDURE
   ,p_module   => l_log_module);
 END IF;
 EXCEPTION
 WHEN xla_exceptions_pkg.application_exception THEN
 RAISE;
 WHEN OTHERS THEN
 xla_exceptions_pkg.raise_message
	 (p_location       => 'xla_accounting_pkg.wait_for_combo_edit_req');
 END wait_for_combo_edit_req;  -- end of procedure
 --FSAH-PSFT FP



--=============================================================================
-- 5054831 - To validate that the AAD is valid in the database.
--
--
--=============================================================================
FUNCTION AAD_dbase_invalid(p_pad_name  IN VARCHAR2,p_ledger_category_code IN VARCHAR2,p_enable_bc_flag IN VARCHAR2 ) return BOOLEAN
IS

CURSOR c_aad_status(c_pad_name VARCHAR2) IS
SELECT status
FROM   all_objects
WHERE  object_name = c_pad_name
and    owner = user
ORDER BY STATUS asc;

/*
select decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.linkname is null
  and (o.type# not in (1 ,
                      10 )
       or
       (o.type# = 1 and 1 = (select 1
                              from sys.ind$ i
                             where i.obj# = o.obj#
                               and i.type# in (1, 2, 3, 4, 6, 7, 9))))
  and o.name <> '_NEXT_OBJECT'
  and o.name <> '_default_auditing_options_'
  and o.name  = p_pad_name
  and u.name  ='APPS'
order by 1 asc;
*/

l_log_module   VARCHAR2(240);
l_status       VARCHAR2(10);
l_pad_name     VARCHAR2(30);  -- 5531502

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AAD_dbase_invalid';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure AAD_dbase_invalid'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'AAD p_pad_name= '||p_pad_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
            (p_msg      => 'p_ledger_category_code= '||p_ledger_category_code
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);

      trace
            (p_msg      => 'p_enable_bc_flag= '||p_enable_bc_flag
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
      END IF; -- 8238617 Added debug statements


   -- 5531502 Need to check for BC package
   IF NVL(g_budgetary_control_mode,'NONE') = 'NONE' THEN
      l_pad_name := p_pad_name;
   ELSE
   -- 6509160 Process non bc AAd package for Secondary non bc enabled ledger
   IF  p_ledger_category_code='SECONDARY' AND p_enable_bc_flag='N' THEN
     /* commented for bug-9245677 */
     /* l_pad_name := p_pad_name; */
     NULL; /* added for bug-9245677 */
    ELSE
    l_pad_name := REPLACE(p_pad_name,'_PKG','_BC_PKG');
   END IF;
   END IF;
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'g_budgetary_control_mode = '||g_budgetary_control_mode
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      => 'l_pad_name = '||l_pad_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;

     /* added for bug-9245677 */
   IF ( NVL(g_budgetary_control_mode,'NONE') = 'NONE'
        OR
	NOT( p_ledger_category_code='SECONDARY' and p_enable_bc_flag='N')
      )
  THEN

   OPEN  c_aad_status (l_pad_name);
   FETCH c_aad_status INTO l_status;
   IF c_aad_status%NOTFOUND or l_status = 'INVALID' THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => l_pad_name||' is invalid.'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
     print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - AAD Package '||l_pad_name||' is invalid.'|| ' Ledger Category is '||p_ledger_category_code||'.'); --Bug 11063454
      END IF;
      CLOSE c_aad_status;
      return TRUE;
   END IF;
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - AAD Package '||l_pad_name||' is valid.'|| ' Ledger Category is '||p_ledger_category_code||'.'); --Bug 11063454
   CLOSE c_aad_status;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure AAD_dbase_invalid'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => l_pad_name||' is valid.'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   return FALSE;

EXCEPTION
WHEN normal_termination THEN
   if c_aad_status%ISOPEN THEN
      close c_aad_status;
   end if;
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'normal_termination: AAD_dbase_invalid'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN xla_exceptions_pkg.application_exception THEN
   if c_aad_status%ISOPEN THEN
      close c_aad_status;
   end if;
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'xla_exceptions_pkg.application_exception: AAD_dbase_invalid'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN OTHERS THEN
   if c_aad_status%ISOPEN THEN
      close c_aad_status;
   end if;
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'EXCEPTION: AAD_dbase_invalid'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_pkg.AAD_dbase_invalid');

END AAD_dbase_invalid;

--=============================================================================
-- 5054831 TO validate that the AAD is valid and there are events in the
--         date range of the AAD
--
--=============================================================================
PROCEDURE ValidateAAD (p_array_event_dates IN t_array_date)
IS

l_log_module          VARCHAR2(240);
l_array_ledgers       xla_accounting_cache_pkg.t_array_ledger_id;
l_array_ledger_pad    xla_accounting_cache_pkg.t_array_pad;
l_max_event_date      date;
l_min_event_date      date;
l_count               NUMBER :=0;
l_encoded_msg         VARCHAR2(2000) := null;
l_ledger_category_code VARCHAR2(50);
l_enable_bc_flag       VARCHAR2(1):=null;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.ValidateAAD';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure ValidateAAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_array_ledgers := xla_accounting_cache_pkg.GetLedgers;

   if p_array_event_dates.COUNT > 0 then
      l_min_event_date := p_array_event_dates(1);
      l_max_event_date := p_array_event_dates(p_array_event_dates.COUNT);
   end if;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
            (p_msg      => 'count='||p_array_event_dates.COUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      trace
            (p_msg      => 'min event_date='||l_min_event_date
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      trace
            (p_msg      => 'max event_date='||l_max_event_date
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      FOR i in 1 .. p_array_event_dates.COUNT LOOP
      trace
            (p_msg      => 'event_date='||p_array_event_dates(i)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END LOOP;

   END IF;

   FOR i in 1..l_array_ledgers.COUNT LOOP

  -- get category code of ledger
     SELECT ledger_category_code,enable_budgetary_control_flag
     INTO l_ledger_category_code,l_enable_bc_flag
     FROM gl_ledgers
     WHERE ledger_id = l_array_ledgers(i);
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
                (p_msg      => 'ledger category code ='||l_ledger_category_code||'bc flag='||l_enable_bc_flag
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);

     END IF;

       -- get the AAD for this ledger
       l_array_ledger_pad := xla_accounting_cache_pkg.GetArrayPad
                                   (p_ledger_id      => l_array_ledgers(i)
                                   ,p_max_event_date => l_max_event_date
                                   ,p_min_event_date => l_min_event_date);

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
                (p_msg      => 'ledger='||l_array_ledgers(i)
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);
          FOR j in 1..l_array_ledger_pad.COUNT LOOP
              trace
                    (p_msg      => 'pad ='||l_array_ledger_pad(j).pad_package_name||
                                   '  status='||l_array_ledger_pad(j).compile_status_code||
                                   '  start='||l_array_ledger_pad(j).start_date_active||
                                   '  end='||l_array_ledger_pad(j).end_date_active
                    ,p_level    => C_LEVEL_STATEMENT
                    ,p_module   => l_log_module);
          END LOOP;
       END IF;

       -- Verify if any AAD is invalid and there are event dates within the AAD date range.
       FOR k in 1..l_array_ledger_pad.COUNT LOOP
         -- Bug 8323089 : Changed from compile_status_code = 'N' to compile_status_code <> 'Y'
           IF l_array_ledger_pad(k).compile_status_code <> 'Y' or
              (l_array_ledger_pad(k).compile_status_code = 'Y' and AAD_dbase_invalid(l_array_ledger_pad(k).pad_package_name,l_ledger_category_code,l_enable_bc_flag)) THEN

              FOR l in 1..p_array_event_dates.COUNT LOOP
                  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                        trace
                              (p_msg      => 'event date = '||p_array_event_dates(l)||
                                             '   pad='||l_array_ledger_pad(k).pad_package_name||
                                             '   start='||l_array_ledger_pad(k).start_date_active||
                                             '   end='||l_array_ledger_pad(k).end_date_active
                              ,p_level    => C_LEVEL_STATEMENT
                              ,p_module   => l_log_module);
                  END IF;

                  IF p_array_event_dates(l) >= l_array_ledger_pad(k).start_date_active AND
                     p_array_event_dates(l) <= NVL(l_array_ledger_pad(k).end_date_active,p_array_event_dates(l)) THEN

                     l_count := l_count + 1;
                     /*--------------------------------------------------------------------------------------------------
                     -- problem; error is not deleted on rerun during online accounting.  for batch, error is not created.
                     xla_accounting_err_pkg.build_message
                           (p_appli_s_name            => 'XLA'
                           ,p_msg_name                => 'XLA_AP_PAD_INACTIVE'
                           ,p_token_1                 => 'PAD_NAME'
                           ,p_value_1                 => l_array_ledger_pad(k).ledger_product_rule_name
                           ,p_token_2                 => 'OWNER'
                           ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                            'XLA_OWNER_TYPE'
                                                            ,l_array_ledger_pad(k).product_rule_owner)
                           ,p_token_3                 => 'SUBLEDGER_ACCTG_METHOD'
                           ,p_value_3                 => xla_accounting_cache_pkg.GetSessionValueChar
                                                            (p_source_code         => 'XLA_ACCOUNTING_METHOD_NAME'
                                                            ,p_target_ledger_id    => l_array_ledgers(i))
                           ,p_entity_id               => null
                           ,p_event_id                => null
                           ,p_ledger_id               => l_array_ledgers(i)
                           ,p_accounting_batch_id     => g_accounting_batch_id);
                     --------------------------------------------------------------------------------------------------*/
                     xla_messages_pkg.build_message
                           (p_appli_s_name            => 'XLA'
                           ,p_msg_name                => 'XLA_AP_PAD_INACTIVE'
                           ,p_token_1                 => 'PAD_NAME'
                           ,p_value_1                 => l_array_ledger_pad(k).ledger_product_rule_name
                           ,p_token_2                 => 'OWNER'
                           ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                            'XLA_OWNER_TYPE'
                                                            ,l_array_ledger_pad(k).product_rule_owner)
                           ,p_token_3                 => 'SUBLEDGER_ACCTG_METHOD'
                           ,p_value_3                 => xla_accounting_cache_pkg.GetSessionValueChar
                                                            (p_source_code         => 'XLA_ACCOUNTING_METHOD_NAME'
                                                            ,p_target_ledger_id    => l_array_ledgers(i)));

                     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                        trace
                           (p_msg      => 'Invalid AAD = '||l_array_ledger_pad(k).pad_package_name
                           ,p_level    => C_LEVEL_STATEMENT
                           ,p_module   => l_log_module);
                     END IF;
                     exit;

                  END IF;

              END LOOP;   -- p_array_event_dates

           END IF;    -- l_array_ledger_pad(k).compile_status_code = 'N'

       END LOOP;    --  l_array_ledger_pad

   END LOOP;   -- l_array_ledgers

   IF l_count> 0 THEN
      l_encoded_msg := fnd_message.get();
      raise xla_exceptions_pkg.application_exception;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure ValidateAAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'xla_exceptions_pkg.application_exception: ValidateAAD'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   IF l_count>0 THEN
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - '||l_encoded_msg);
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN  -- log
      trace
         (p_msg      => l_encoded_msg
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      END IF;
   END IF;
   RAISE;
WHEN OTHERS THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'EXCEPTION: ValidateAAD'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_pkg.ValidateAAD');
END ValidateAAD;


--=============================================================================
--
-- The following ValidateAAD is called from unit_processor in batch accounting.
-- It checks validity of AAD in the AMB and in database. If any AAD is invalid
-- in AMB or in database, the procedure terminates 'Accoutning Program'.
--
--=============================================================================

PROCEDURE ValidateAAD
       (p_max_event_date             IN  DATE)
IS

C_MIN_EVENT_DATE      CONSTANT DATE := TO_DATE('01/01/1900','DD/MM/YYYY');

l_log_module          VARCHAR2(240);
l_array_ledgers       xla_accounting_cache_pkg.t_array_ledger_id;
l_array_ledger_pad    xla_accounting_cache_pkg.t_array_pad;
l_count               NUMBER :=0;
l_message             VARCHAR2(2000);

l_pad_name            VARCHAR2(240);
l_pad_owner           VARCHAR2(240);
l_slam                VARCHAR2(240);
l_ledger_category_code  VARCHAR2(50);
l_enable_bc_flag       VARCHAR2(1):=null;


BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.ValidateAAD';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure ValidateAAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_max_event_date = '||p_max_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_array_ledgers := xla_accounting_cache_pkg.GetLedgers;

   FOR i in 1..l_array_ledgers.COUNT LOOP

   -- get category code of ledger
     SELECT ledger_category_code,enable_budgetary_control_flag
     INTO l_ledger_category_code,l_enable_bc_flag
     FROM gl_ledgers
     WHERE ledger_id = l_array_ledgers(i);

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
                (p_msg      => 'ledger category code ='||l_ledger_category_code||' bc flag='||l_enable_bc_flag
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);

    END IF;

      -- get the AAD for this ledger
      l_array_ledger_pad :=
         xla_accounting_cache_pkg.GetArrayPad
            (p_ledger_id         => l_array_ledgers(i)
            ,p_max_event_date    => p_max_event_date
            ,p_min_event_date    => C_MIN_EVENT_DATE);


      -- Verify if any AAD is invalid and there are event dates within the AAD date range.
      FOR k in 1..l_array_ledger_pad.COUNT LOOP
      -- Bug 8323089 : Changed from compile_status_code = 'N' to compile_status_code <> 'Y'
         IF (l_array_ledger_pad(k).compile_status_code <> 'Y' OR
            (l_array_ledger_pad(k).compile_status_code = 'Y' AND
             AAD_dbase_invalid(l_array_ledger_pad(k).pad_package_name,l_ledger_category_code,l_enable_bc_flag)
            )
            )
         THEN
            l_pad_name  := l_array_ledger_pad(k).ledger_product_rule_name;
            l_pad_owner := xla_lookups_pkg.get_meaning
                              ('XLA_OWNER_TYPE'
                              ,l_array_ledger_pad(k).product_rule_owner);
            l_slam      := xla_accounting_cache_pkg.GetSessionValueChar
                              (p_source_code         => 'XLA_ACCOUNTING_METHOD_NAME'
                              ,p_target_ledger_id    => l_array_ledgers(i));

            l_count := l_count + 1;

            xla_messages_pkg.build_message
               (p_appli_s_name            => 'XLA'
               ,p_msg_name                => 'XLA_AP_PAD_INACTIVE'
               ,p_token_1                 => 'PAD_NAME'
               ,p_value_1                 => l_pad_name
               ,p_token_2                 => 'OWNER'
               ,p_value_2                 => l_pad_owner
               ,p_token_3                 => 'SUBLEDGER_ACCTG_METHOD'
               ,p_value_3                 => l_slam);

            l_message := fnd_message.get();

            print_logfile(l_message);

         END IF;    -- l_array_ledger_pad(k).compile_status_code = 'N'
      END LOOP;    --  l_array_ledger_pad
   END LOOP;   -- l_array_ledgers

   IF l_count > 0 THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_accounting_pkg.ValidateAAD');
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure ValidateAAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_pkg.ValidateAAD');
END ValidateAAD;

--=============================================================================
--
--
--
--=============================================================================

PROCEDURE unit_processor IS
TYPE t_lock_events_cur IS REF CURSOR;
lock_events_cur                   t_lock_events_cur;

l_deq_options                     dbms_aq.dequeue_options_t;
l_enq_options                     dbms_aq.enqueue_options_t;
l_msg_prop                        dbms_aq.message_properties_t;
l_msgid                           RAW(16);
--l_message                         xla_queue_msg_type; --SYSTEM.xla_queue_msg_type;
l_entity_count                    NUMBER                     := 0;
l_event_count                     NUMBER                     := 0;
l_dequeue_flag                    BOOLEAN;

l_ret_val_acctg_engine            NUMBER;
l_sqlerrm                         VARCHAR2(2000);
l_log_module                      VARCHAR2(240);
l_transfer_mode                   VARCHAR2(30);

l_array_events                    xla_accounting_pkg.t_array_number;

-------------------------------------------------------
-- 4597150
-------------------------------------------------------
l_all_event_classes               VARCHAR2(10000);
l_class_current_order             VARCHAR2(5000);
l_class_anytime_order             VARCHAR2(5000);
l_str1_insert_events               VARCHAR2(32000);
l_str2_insert_events               VARCHAR2(32000);
l_evt_num_subqry                  VARCHAR2(32000);
-------------------------------------------------------
l_lock_events_str                 VARCHAR2(32000); --14105024
-------------------------------------------------------
-- Bug 5056632
-------------------------------------------------------
l_array_base_ledgers              xla_accounting_cache_pkg.t_array_ledger_id;
l_array_alc_ledgers               xla_accounting_cache_pkg.t_array_ledger_id;
l_primary_ledger_group_id         NUMBER;
l_temp                            NUMBER;

l_event_insert_count              number;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.unit_processor';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure UNIT_PROCESSOR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Ready to cache the Application and Ledger Level Sources ...');

   xla_accounting_cache_pkg.load_application_ledgers
      (p_application_id      => g_application_id
      ,p_event_ledger_id     => g_ledger_id
      ,p_max_event_date      => g_end_date);

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Cached the Application and Ledger Level Sources');

   -- validate AADs
   ValidateAAD(g_end_date);

   --
   -- Bug 5056632
   -- The following fetches group_id and stores them in an array for Transfer
   -- to GL. There is a distinct groupid for each base ledger. ALCs share
   -- their group_id with Primary ledger..
   --
   IF g_accounting_mode = 'F' AND g_transfer_flag = 'Y' THEN
      l_array_base_ledgers := xla_accounting_cache_pkg.GetLedgers;
      l_array_alc_ledgers  := xla_accounting_cache_pkg.GetAlcLedgers(g_ledger_id);
   --For bug fix 7677948
      FOR i IN l_array_base_ledgers.FIRST..l_array_base_ledgers.LAST LOOP
         SELECT gl_interface_control_s.NEXTVAL, l_array_base_ledgers(i)
           INTO g_array_group_id(i), g_array_ledger_id(i)
           FROM DUAL;

         IF l_array_alc_ledgers.COUNT > 0 AND
            l_array_base_ledgers(i) = g_ledger_id
         THEN
            l_primary_ledger_group_id := g_array_group_id(i);
         END IF;
      END LOOP;

      IF l_array_alc_ledgers.COUNT > 0 THEN
         l_temp := g_array_group_id.COUNT;
         FOR i IN (l_array_alc_ledgers.FIRST)..(l_array_alc_ledgers.LAST) LOOP
            g_array_group_id(i+l_temp)  := l_primary_ledger_group_id;
            g_array_ledger_id(i+l_temp) := l_array_alc_ledgers(i);
         END LOOP;
      END IF;
   END IF;

   ----------------------------------------------------------------------------
   -- Following initiates queue/message related variables
   ----------------------------------------------------------------------------
   l_deq_options.consumer_name       := NULL;
   l_deq_options.dequeue_mode        := dbms_aq.REMOVE;
   l_deq_options.navigation          := dbms_aq.FIRST_MESSAGE;
   l_deq_options.visibility          := dbms_aq.IMMEDIATE;
   l_deq_options.wait                := 60;
   l_deq_options.msgid               := NULL;
   l_deq_options.correlation         := NULL;

   l_enq_options.visibility         := dbms_aq.IMMEDIATE;
   l_enq_options.relative_msgid     := NULL;
   l_enq_options.sequence_deviation := NULL;

   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Entering the loop to read document units from the queue ...');

   LOOP  -- (reading messages from the queue)
      -------------------------------------------------------------------------
      -- Initializing variables for a loop
      -------------------------------------------------------------------------
      l_event_count := 0;

      -------------------------------------------------------------------------
      -- Following checks to make sure the error count for the accounting
      -- program has not reached the error limit.
      -------------------------------------------------------------------------
      IF ((xla_accounting_err_pkg.g_error_limit IS NOT NULL) AND
          (xla_accounting_err_pkg.get_total_error_count >=
                 xla_accounting_err_pkg.g_error_limit
          )
         )
      THEN
         print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - This child process is exiting the loop due to the error limit defined in the setups');

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Message : This child process is exiting the loop due to the error limit defined in the setups'
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;
         EXIT;
      END IF;

      -------------------------------------------------------------------------
      -- Following checks whether the parent accounting program is active
      -- or not.
      -------------------------------------------------------------------------
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Checking status of the parent Accounting Program');
      IF NOT is_parent_running THEN

         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'Technical Error : The parent request for this request is not running'
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
         END IF;

         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'LOCATION'
            ,p_value_1        => 'xla_accounting_pkg.unit_processor'
            ,p_token_2        => 'ERROR'
            ,p_value_2        => 'Technical Error : The parent request for this request is not running.');
      END IF;

      -------------------------------------------------------------------------
      -- read message from the queue.
      -------------------------------------------------------------------------

      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Dequeuing the unit from the queue');

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Ready to dequeue message from message queue'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      l_dequeue_flag := TRUE;
      WHILE (l_dequeue_flag) LOOP
        BEGIN
          dbms_aq.dequeue
             (g_queue_name
             ,l_deq_options
             ,l_msg_prop
             ,g_message
             ,l_msgid);
          l_dequeue_flag := FALSE;
        EXCEPTION
          WHEN OTHERS THEN

              IF g_conc_hold = 'Y' AND SQLCODE = -25228 /* Timeout; queue is likely empty... */
                THEN
                     print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
                          ||' - Dequeue of ' ||
                          g_queue_name ||' Timed out');
                     print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
                          ||' - Please run Transfer to GL explicitly.');
                     trace(p_msg => 'Queue is empty.'
                          ,p_level => C_LEVEL_EXCEPTION
                          ,p_module   => l_log_module);

                     RAISE;
              END IF;

            IF NOT is_parent_running THEN

               IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  trace
                     (p_msg      => 'Technical Error : The parent request for this request is not running'
                     ,p_level    => C_LEVEL_EXCEPTION
                     ,p_module   => l_log_module);
               END IF;

               xla_exceptions_pkg.raise_message
                  (p_appli_s_name   => 'XLA'
                  ,p_msg_name       => 'XLA_COMMON_ERROR'
                  ,p_token_1        => 'LOCATION'
                  ,p_value_1        => 'xla_accounting_pkg.unit_processor'
                  ,p_token_2        => 'ERROR'
                  ,p_value_2        => 'Technical Error : The parent request for this request is not running.');
            END IF;
        END;
      END LOOP;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Message from message queue is dequeued'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      g_child_data.dequeued_msg_count := g_child_data.dequeued_msg_count + 1;

      -------------------------------------------------------------------------
      -- Following code transfer control out of the loop when the message
      -- fetched from the queue has no documents in it (ie NULL).
      -- It is a very important step because this is the only exit point of
      -- the loop.
      -------------------------------------------------------------------------
      IF g_message.entity_ids IS NULL THEN
         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'Exiting the LOOP because this is end of messages in the message queue'
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;
         EXIT;
      END IF;

      g_child_data.selected_entity_count :=
         g_child_data.selected_entity_count + g_message.entity_ids.COUNT;

      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Fetching event information for the documents in the unit');

      -------------------------------------------------------------------------
      -- Following statement inserts event information into the temporary table
      -- for product teams to perform extract.
      -------------------------------------------------------------------------
      ----------------------------------------------------------------------------------------
      -- 4597150 Additional debug
      ----------------------------------------------------------------------------------------
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         FOR i IN 1..g_message.entity_ids.COUNT LOOP

              trace
                  (p_msg      => 'Entity_id = '||i||' = '||g_message.entity_ids(i)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);

         END LOOP;
      END IF;
      ----------------------------------------------------------------------------------------

      -------------------------------------------------------------------------------------------------
      -- 4597150 - divide Current Event Class and Anytime Event Class
      --         - list of EVENT_CLASSES is the same for each entity in this Child Process
      -------------------------------------------------------------------------------------------------
      -- if l_msg_prop.user_property = 'EC1','EC2'#-#-#-#-#-#-#-#'EC3','EC4' then
      --    l_class_current_order = 'EC1','EC2'
      --    l_class_anytime_order = 'EC3','EC4'
      -------------------------------------------------------------------------------------------------
      IF g_message.entity_ids IS NOT NULL THEN

         ---------------------------------------------------------------------------
         -- extract combined event_classes from queue
         ---------------------------------------------------------------------------
         l_all_event_classes := SYS.AnyData.AccessVarchar2(l_msg_prop.user_property);

         l_class_current_order :=
              SUBSTRB(l_all_event_classes
                     ,1
                     ,INSTRB(l_all_event_classes,C_DELIMITER)-1);

         l_class_anytime_order :=
              SUBSTRB(l_all_event_classes
                     ,LENGTH(C_DELIMITER)
                      + INSTRB(l_all_event_classes,C_DELIMITER));

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                (p_msg      => 'Event_Class : all     = '||l_all_event_classes
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);
            trace
                (p_msg      => 'Event_Class : current = '||l_class_current_order
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);
            trace
                (p_msg      => 'Event_Class : anytime = '||l_class_anytime_order
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);
         END IF;

      END IF;

      -------------------------------------------------------------------------
      -- Following is added to lock events. Bug 5534133
      -------------------------------------------------------------------------
      IF l_class_anytime_order is NULL THEN
         l_lock_events_str := REPLACE(C_LOCK_EVENTS_STR
                                     ,'$event_classes$'
                                     ,l_class_current_order);
      ELSE
         l_lock_events_str := REPLACE(C_LOCK_EVENTS_STR
                                     ,'$event_classes$'
                                     ,l_class_current_order||','||l_class_anytime_order);
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'l_lock_events_str = '|| l_lock_events_str
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      l_str1_insert_events := C_CURR_INS_EVENTS;

      l_str1_insert_events := REPLACE(l_str1_insert_events
                                     ,'$event_classes$'
                                     ,l_class_current_order);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'First l_str1_insert_events = '|| l_str1_insert_events
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      IF  l_class_anytime_order IS NOT NULL
      AND NVL(l_class_current_order,-1) <> NVL(l_class_anytime_order,-1)
      THEN
         -- if only Processing Order -1 exist, then they are the same

         l_str2_insert_events := C_ANYTIME_INS_EVENTS;

         l_str2_insert_events := REPLACE(l_str2_insert_events
                                        ,'$event_classes$'
                                        ,l_class_anytime_order);

         l_str2_insert_events := REPLACE(l_str2_insert_events
                                        ,'$event_class_current_order$'
                                        ,l_class_current_order);

         l_str2_insert_events := REPLACE(l_str2_insert_events
                                        ,'$event_class_anytime_order$'
                                        ,l_class_anytime_order);  -- 4860037

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'Second l_str2_insert_events = '|| l_str2_insert_events
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;
      END IF;

      OPEN lock_events_cur for l_lock_events_str
      USING xla_accounting_pkg.g_message.entity_ids
           ,g_application_id
           ,g_end_date
           ,g_accounting_mode;
         LOOP
            fetch lock_events_cur bulk collect into l_array_events limit 5000;
            EXIT WHEN l_array_events.COUNT = 0;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'l_array_events.COUNT = '|| l_array_events.COUNT
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
            END IF;


            FORALL i IN 1..l_array_events.COUNT
            EXECUTE IMMEDIATE l_str1_insert_events
            USING g_application_id
                 ,g_end_date
                 ,l_array_events(i)
                 ,g_accounting_mode;

            l_event_insert_count := SQL%ROWCOUNT;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'l_event_insert_count = '||l_event_insert_count
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
            END IF;

            --
            -- 4865292
            -- Compare event count with header extract count
            --
            l_event_count := l_event_count + l_event_insert_count;

            --- End of First Insert ----------------------------------------------------------------------------

            ----------------------------------------------------------------------------------------------------
            -- 4597150
            -- Second insert into xla_events_gt is for process order -1
            -- When all process orders are -1, events are inserted in
            -- the previous insert statement. In this case, l_class_anytime_order
            -- becomes null.
            ----------------------------------------------------------------------------------------------------

            IF  l_class_anytime_order IS NOT NULL
            AND NVL(l_class_current_order,-1) <> NVL(l_class_anytime_order,-1)
            THEN

               FORALL i IN 1..l_array_events.COUNT
               EXECUTE IMMEDIATE l_str2_insert_events
               USING g_application_id
                    ,g_end_date
                    ,l_array_events(i)
                    ,g_accounting_mode
                    ,g_end_date
                    ,g_accounting_mode;

               l_event_insert_count := SQL%ROWCOUNT;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                     (p_msg      => 'l_event_insert_count = '||l_event_insert_count
                     ,p_level    => C_LEVEL_STATEMENT
                     ,p_module   => l_log_module);
               END IF;

               --
               -- 4865292
               -- Compare event count with header extract count
               --
               l_event_count := l_event_count + l_event_insert_count;

            END IF;
         END LOOP;
      CLOSE lock_events_cur;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of events in XLA_EVENTS_GT = '||l_event_count
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      IF l_event_count = 0 THEN
       GOTO enqueue_completion_msg;
      END IF;

      delete_request_je;

      --
      -- 4865292
      -- Compare event count with header extract count
      --
      xla_context_pkg.set_event_count_context
         (p_event_count => l_event_count
         ,p_client_id   => g_parent_request_id);
      --------------------------------------------------------------------------
      -- Handle extract hook
      --------------------------------------------------------------------------
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - executing extract hook');
      handle_accounting_hook
                 (p_application_id         => g_application_id
                 ,p_ledger_id              => NULL
                 ,p_process_category       => NULL
                 ,p_end_date               => NULL
                 ,p_accounting_mode        => g_accounting_mode
                 ,p_budgetary_control_mode => g_budgetary_control_mode
                 ,p_valuation_method       => NULL
                 ,p_security_id_int_1      => NULL
                 ,p_security_id_int_2      => NULL
                 ,p_security_id_int_3      => NULL
                 ,p_security_id_char_1     => NULL
                 ,p_security_id_char_2     => NULL
                 ,p_security_id_char_3     => NULL
                 ,p_report_request_id      => NULL
                 ,p_event_name             => 'extract'
                 ,p_event_key              =>  to_char(g_accounting_batch_id)||'-'
                                               ||to_char(g_parent_request_id)||'-'
                                               ||rawtohex(l_msgid));
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - extract hook executed successfully');

      dbms_session.set_identifier(client_id => g_parent_request_id); -- added for bug11903966
      ----------------------------------------------------------------------
      -- Call accounting engine
      ----------------------------------------------------------------------
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Calling the function XLA_ACCOUNTING_ENGINE_PKG.ACCOUNTINGENGINE'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      l_ret_val_acctg_engine :=
         xla_accounting_engine_pkg.AccountingEngine
            (p_application_id       => g_application_id
            ,p_ledger_id            => g_ledger_id
            ,p_end_date             => g_end_date        -- 4262811
            ,p_accounting_mode      => g_accounting_mode
            ,p_accounting_batch_id  => g_accounting_batch_id
            ,p_budgetary_control_mode => 'NONE');

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Function XLA_ACCOUNTING_ENGINE_PKG.ACCOUNTINGENGINE executed'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'l_ret_val_acctg_engine = '||l_ret_val_acctg_engine
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      => 'g_accounting_mode = '||g_accounting_mode
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

   ----------------------------------------------------------------------------
   -- Handle postprocessing hook
   ----------------------------------------------------------------------------
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - executing postprocessing hook');
      handle_accounting_hook
                 (p_application_id         => g_application_id
                 ,p_ledger_id              => NULL
                 ,p_process_category       => NULL
                 ,p_end_date               => NULL
                 ,p_accounting_mode        => g_accounting_mode
                 ,p_budgetary_control_mode => g_budgetary_control_mode
                 ,p_valuation_method       => NULL
                 ,p_security_id_int_1      => NULL
                 ,p_security_id_int_2      => NULL
                 ,p_security_id_int_3      => NULL
                 ,p_security_id_char_1     => NULL
                 ,p_security_id_char_2     => NULL
                 ,p_security_id_char_3     => NULL
                 ,p_report_request_id      => NULL
                 ,p_event_name             => 'postprocessing'
                 ,p_event_key              =>  to_char(g_accounting_batch_id)||'-'
                                               ||to_char(g_parent_request_id)||'-'
                                               ||rawtohex(l_msgid));
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - postprocessing hook executed successfully');

      dbms_session.set_identifier(client_id => g_parent_request_id); -- added for bug11903966
      -------------------------------------------------------------------------
      -- After processing each unit (fetched from the queue), accounting
      -- entries are sequenced (in FINAL mode) and commited in base tables and
      -- errors are moved from array to error table,
      -------------------------------------------------------------------------
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Completing Journal Entries');

      complete_entries;
      xla_accounting_err_pkg.insert_errors;

      -------------------------------------------------------------------------
      -- Following checks whether the parent accounting program is active
      -- or not before commiting the transaction
      -------------------------------------------------------------------------
      IF is_parent_running THEN
         COMMIT;

         IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => 'COMMIT issued in UNIT_PROCESSOR'
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
         END IF;

      ELSE
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'Technical Error : The parent request for this request is not running'
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
         END IF;

         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'LOCATION'
            ,p_value_1        => 'xla_accounting_pkg.pre_accounting'
            ,p_token_2        => 'ERROR'
            ,p_value_2        => 'Technical Error : The parent request for this request is not running.');
      END IF;

      <<enqueue_completion_msg>>
      --
      -- After processing one document message, enqueue a completion message
      --
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Enqueue completion message'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      g_message := xla_queue_msg_type(NULL);
      dbms_aq.enqueue
                (g_comp_queue_name
                ,l_enq_options
                ,l_msg_prop
                ,g_message
                ,l_msgid);

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Done Enqueue completion message'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

   END LOOP; -- (reading messages from the queue)

   ----------------------------------------------------------------------------
   -- call routines to perform 'Transfer to GL'
   ----------------------------------------------------------------------------
   IF  ((g_transfer_flag = 'Y') AND (g_accounting_mode = 'F' ))    THEN

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Transfer to GL process being called'
            ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
      END IF;

      xla_accounting_err_pkg.set_options
         (p_error_source     => xla_accounting_err_pkg.C_TRANSFER_TO_GL);

      l_transfer_mode := 'COMBINED';

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'l_transfer_mode = '||l_transfer_mode
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Calling transfer routine XLA_TRANSFER_PKG.GL_TRANSFER_MAIN'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      --
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Submitting the transfer to GL');
      xla_transfer_pkg.gl_transfer_main
         (p_application_id        => g_application_id
         ,p_transfer_mode         => l_transfer_mode
         ,p_ledger_id             => g_ledger_id
         ,p_securiy_id_int_1      => g_security_id_int_1
         ,p_securiy_id_int_2      => g_security_id_int_2
         ,p_securiy_id_int_3      => g_security_id_int_3
         ,p_securiy_id_char_1     => g_security_id_char_1
         ,p_securiy_id_char_2     => g_security_id_char_2
         ,p_securiy_id_char_3     => g_security_id_char_3
         ,p_valuation_method      => g_valuation_method
         ,p_process_category      => g_process_category
         ,p_accounting_batch_id   => NULL
         ,p_entity_id             => NULL
         ,p_batch_name            => g_gl_batch_name
         ,p_end_date              => g_end_date
         ,p_submit_gl_post        => g_gl_posting_flag
         ,p_caller                => xla_transfer_pkg.C_ACCTPROG_BATCH); -- Bug 5056632

      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' -  End of the transfer to GL');

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Transfer routine XLA_TRANSFER_PKG.GL_TRANSFER_MAIN executed'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      xla_accounting_err_pkg.set_options
         (p_error_source     => xla_accounting_err_pkg.C_ACCT_PROGRAM);

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure UNIT_PROCESSOR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   g_message := xla_queue_msg_type(NULL);
   dbms_aq.enqueue
                (g_comp_queue_name
                ,l_enq_options
                ,l_msg_prop
                ,g_message
                ,l_msgid);
   RAISE;
WHEN OTHERS THEN
   IF SQLCODE = -25228 AND g_conc_hold = 'Y' /* Timeout; queue is likely empty... */
   THEN
       RAISE;
   END IF;
   g_message := xla_queue_msg_type(NULL);
   dbms_aq.enqueue
                (g_comp_queue_name
                ,l_enq_options
                ,l_msg_prop
                ,g_message
                ,l_msgid);
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_accounting_pkg.unit_processor');
END unit_processor;  -- end of function



--=============================================================================
--
--
--
--=============================================================================
FUNCTION is_parent_running
RETURN BOOLEAN IS
l_phase                           VARCHAR2(30);
l_status                          VARCHAR2(30);
l_dphase                          VARCHAR2(30);
l_dstatus                         VARCHAR2(30);
l_message                         VARCHAR2(240);
l_btemp                           BOOLEAN;
l_result                          BOOLEAN;
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.is_parent_running';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function IS_PARENT_RUNNING'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Waiting for active/pending requests to complete
   ----------------------------------------------------------------------------
   l_btemp := fnd_concurrent.get_request_status
                 (request_id    => g_parent_request_id
                 ,phase         => l_phase
                 ,status        => l_status
                 ,dev_phase     => l_dphase
                 ,dev_status    => l_dstatus
                 ,message       => l_message);

   IF NOT l_btemp THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'Technical problem : FND_CONCURRENT.GET_REQUEST_STATUS returned FALSE '||
                           'while executing for request id '||g_parent_request_id
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;

      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_accounting_pkg.is_parent_running'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'Technical problem : FND_CONCURRENT.GET_REQUEST_STATUS returned FALSE '||
                              'while executing for request id '||g_parent_request_id);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_dphase = '||l_dphase
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF l_dphase = 'RUNNING' THEN
      l_result := TRUE;
   ELSE
      l_result := FALSE;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of function IS_PARENT_RUNNING'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_accounting_pkg.is_parent_running');
END is_parent_running;  -- end of procedure

--=============================================================================
--
--
--
--=============================================================================
FUNCTION is_any_child_running
RETURN BOOLEAN IS
l_phase                           VARCHAR2(30);
l_status                          VARCHAR2(30);
l_dphase                          VARCHAR2(30);
l_dstatus                         VARCHAR2(30);
l_message                         VARCHAR2(240);
l_btemp                           BOOLEAN;
l_result                          BOOLEAN;
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.is_any_child_running';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function is_any_child_running'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_result := FALSE;
   IF g_ep_request_ids.count > 0 THEN

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'BEGIN LOOP: get child process status'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
      END IF;

      FOR i IN 1..g_ep_request_ids.count LOOP
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
            trace
               (p_msg      => 'LOO: get child process status : '||g_ep_request_ids(i)
               ,p_level    => C_LEVEL_PROCEDURE
               ,p_module   => l_log_module);
         END IF;

         ----------------------------------------------------------------------------
         -- Check the child process status
         ----------------------------------------------------------------------------
         l_btemp := fnd_concurrent.get_request_status
                 (request_id    => g_ep_request_ids(i)
                 ,phase         => l_phase
                 ,status        => l_status
                 ,dev_phase     => l_dphase
                 ,dev_status    => l_dstatus
                 ,message       => l_message);

         IF NOT l_btemp THEN
            IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
               trace
                  (p_msg      => 'Technical problem : FND_CONCURRENT.GET_REQUEST_STATUS '||
                                 'returned FALSE '||
                                 'while executing for request id '||g_ep_request_ids(i)
                  ,p_level    => C_LEVEL_EXCEPTION
                  ,p_module   => l_log_module);
            END IF;

            xla_exceptions_pkg.raise_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_COMMON_ERROR'
               ,p_token_1        => 'LOCATION'
               ,p_value_1        => 'xla_accounting_pkg.is_any_child_running'
               ,p_token_2        => 'ERROR'
               ,p_value_2        => 'Technical problem : FND_CONCURRENT.GET_REQUEST_STATUS returned FALSE '||
                                    'while executing for request id '||g_ep_request_ids(i));
         END IF;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'l_dphase = '||l_dphase
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;

         IF l_dphase IN ('PENDING', 'RUNNING') THEN

            IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
               trace
                  (p_msg      => 'Child '||g_ep_request_ids(i)||' is running'
                  ,p_level    => C_LEVEL_PROCEDURE
                  ,p_module   => l_log_module);
            END IF;

            l_result := TRUE;
            EXIT;
         END IF;
      END LOOP;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'END LOOP: get child process status'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
      END IF;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of function is_any_child_running'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_accounting_pkg.is_any_child_running');
END is_any_child_running;  -- end of procedure



--=============================================================================
--
--
--
--=============================================================================
PROCEDURE sequencing_batch_init
       (p_seq_enabled_flag           IN OUT NOCOPY VARCHAR2) IS
l_xla_application_id              NUMBER         := 602;
l_xla_seq_entity                  VARCHAR2(30)   := 'XLA_AE_HEADERS';
l_seq_event_code                  VARCHAR2(30)   := 'COMPLETION';
l_seq_context_value               fun_seq_batch.context_value_tbl_type;

l_seq_status                      VARCHAR2(30);
l_seq_context_id                  NUMBER;
l_sqlerrm                         VARCHAR2(2000);
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.sequencing_batch_init';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure SEQUENCING_BATCH_INIT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_seq_enabled_flag = '||p_seq_enabled_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Getting ledger ids that will be used/cached in this run of accounting
   -- program (Actually this should come from cache but as cache is not
   -- activated in parent, the SQL is repeated here. This may change in
   -- future).
   ----------------------------------------------------------------------------
   SELECT  xlr.ledger_id BULK COLLECT
      INTO l_seq_context_value
      FROM xla_ledger_relationships_v       xlr
          ,xla_subledger_options_v          xso
     WHERE xlr.relationship_enabled_flag    = 'Y'
       AND xlr.ledger_category_code         IN ('ALC','PRIMARY','SECONDARY')
       AND DECODE(xso.valuation_method_flag
                 ,'N',xlr.primary_ledger_id
                 ,DECODE(xlr.ledger_category_code
                        ,'ALC',xlr.primary_ledger_id
                        ,xlr.ledger_id)
                 )                           = g_ledger_id
       AND xso.application_id                = g_application_id
       AND xso.ledger_id                     = DECODE(xlr.ledger_category_code
                                                     ,'ALC',xlr.primary_ledger_id
                                                     ,xlr.ledger_id)
       AND xso.enabled_flag                  = 'Y';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of ledgers being passed to the sequencing api = '||
                        l_seq_context_value.COUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Calling sequencing's batch init
   ----------------------------------------------------------------------------
   BEGIN
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Calling sequencing batch_init');
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Calling procedure FUN_SEQ_BATCH.BATCH_INIT'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      fun_seq_batch.batch_init
         (p_application_id      => l_xla_application_id
         ,p_table_name          => l_xla_seq_entity
         ,p_event_code          => l_seq_event_code
         ,p_context_type        => 'LEDGER_AND_CURRENCY'
         ,p_context_value_tbl   => l_seq_context_value
         ,p_request_id          => g_parent_request_id
         ,x_status              => l_seq_status
         ,x_seq_context_id      => l_seq_context_id);

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Procedure FUN_SEQ_BATCH.BATCH_INIT executed'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;
      print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Returned from sequencing batch_init');

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'l_seq_status = '||l_seq_status
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      => 'l_seq_context_id = '||l_seq_context_id
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      IF l_seq_status = 'NO_SEQUENCING' THEN
         p_seq_enabled_flag := 'N';
      ELSE
         p_seq_enabled_flag := 'Y';
      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      l_sqlerrm := sqlerrm;

      IF (C_LEVEL_EXCEPTION>= g_log_level) THEN
         trace
            (p_msg      => 'Technical problem : Problem encountered in sequencing BATCH_INIT.'||
                           xla_environment_pkg.g_chr_newline||
                           l_sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;

      xla_accounting_err_pkg.build_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
         ,p_token_1        => 'APPLICATION_NAME'
         ,p_value_1        => 'SLA'
         ,p_entity_id      => NULL
         ,p_event_id       => NULL);

      print_logfile('Technical problem : Problem encountered in sequencing BATCH_INIT.');

      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'LOCATION'
         ,p_value_1        => 'xla_accounting_pkg.sequencing_batch_init'
         ,p_token_2        => 'ERROR'
         ,p_value_2        => 'Technical problem : Problem encountered in sequencing BATCH_INIT.'||
                              xla_environment_pkg.g_chr_newline||
                              l_sqlerrm);
   END;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_seq_enabled_flag = '||p_seq_enabled_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure SEQUENCING_BATCH_INIT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_accounting_pkg.sequencing_batch_init');
END sequencing_batch_init;  -- end of procedure


--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following routines are used while accounting for batch of events
--
--    1.    events_processor
--    2.    delete_batch_je
--
--
--
--
--
--
--
--
--
--
--=============================================================================

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE events_processor(l_processing_order IN NUMBER)    -- bug 7193986
IS
l_ret_val_acctg_engine            NUMBER;
l_seq_status                      VARCHAR2(30);
l_max_event_date                  DATE;
l_log_module                      VARCHAR2(240);

-- 5054831 -----------------------------------
l_array_event_dates               t_array_date;
CURSOR c_events IS
SELECT distinct event_date
FROM   xla_events a
      ,xla_acct_prog_events_gt b
WHERE  a.application_id         = g_application_id
AND    a.event_id               = b.event_id
AND    a.process_status_code    = 'U'
AND    a.event_status_code     IN ('U',DECODE(g_accounting_mode,'F','N','U'))
AND    a.on_hold_flag           = 'N'
AND    a.event_type_code not in ('FULL_MERGE', 'PARTIAL_MERGE')
AND    b.ledger_id              = g_ledger_id
ORDER BY event_date asc;
----------------------------------------------

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.events_processor';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure events_processor'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   xla_accounting_cache_pkg.load_application_ledgers
              (p_application_id      => g_application_id
              ,p_event_ledger_id     => g_ledger_id);

   -- 5054831 -----------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      FOR i in (select a.* from xla_acct_prog_events_gt b, xla_events a WHERE  a.application_id         = g_application_id
                                                                        AND    a.event_id               = b.event_id
                                                                        AND    a.process_status_code    = 'U'
                                                                        AND    a.event_status_code     IN ('U',DECODE(g_accounting_mode,'F','N','U'))
                                                                        AND    a.on_hold_flag           = 'N'
                                                                        AND    a.event_type_code not in ('FULL_MERGE', 'PARTIAL_MERGE')
                                                                        AND    b.ledger_id              = g_ledger_id) LOOP
         trace
            (p_msg      => 'event_id='||i.event_id||'  event_date='||i.event_date||'  status='||i.process_status_code
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END LOOP;
   END IF;

   OPEN c_events;
   FETCH c_events BULK COLLECT INTO l_array_event_dates;
   CLOSE c_events;

   ValidateAAD(l_array_event_dates);
   ----------------------------------------
-- bug 7193986 start
   --
   -- Delete the events inserted from the previous run
   --
        DELETE FROM XLA_EVENTS_GT;
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_msg      => '# rows deleted XLA_EVENTS_GT = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
        END IF;
    DELETE FROM XLA_AE_LINES_GT;
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_msg      => '# rows deleted  XLA_AE_LINES_GT = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
        END IF;
    DELETE FROM XLA_AE_HEADERS_GT;
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
         (p_msg      => '# rows deleted  XLA_AE_HEADERS_GT = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
        END IF;
    DELETE FROM XLA_VALIDATION_LINES_GT;
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
            trace
         (p_msg      => '# rows deleted  XLA_VALIDATION_LINES_GT = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
        END IF;


   --
   -- Insert into xla_events_gt for the entity in xla_acct_prog_events_gt
   -- for the p_application_id and p_ledger_id.
   --
   INSERT INTO xla_events_gt
      (entity_id
      ,application_id
      ,ledger_id
      ,legal_entity_id
      ,entity_code
      ,transaction_number
      ,source_id_int_1
      ,source_id_int_2
      ,source_id_int_3
      ,source_id_int_4
      ,source_id_char_1
      ,source_id_char_2
      ,source_id_char_3
      ,source_id_char_4
      ,event_id
      ,event_class_code
      ,event_type_code
      ,event_number
      ,event_date
      ,transaction_date
      ,event_status_code
      ,process_status_code
      ,valuation_method
      ,budgetary_control_flag
      ,reference_num_1
      ,reference_num_2
      ,reference_num_3
      ,reference_num_4
      ,reference_char_1
      ,reference_char_2
      ,reference_char_3
      ,reference_char_4
      ,reference_date_1
      ,reference_date_2
      ,reference_date_3
      ,reference_date_4)
     SELECT xev.entity_id
           ,xev.application_id
           ,xev.ledger_id
           ,xev.legal_entity_id
           ,xev.entity_code
           ,xev.transaction_number
           ,xev.source_id_int_1
           ,xev.source_id_int_2
           ,xev.source_id_int_3
           ,xev.source_id_int_4
           ,xev.source_id_char_1
           ,xev.source_id_char_2
           ,xev.source_id_char_3
           ,xev.source_id_char_4
           ,xev.event_id
           ,xev.event_class_code
           ,xev.event_type_code
           ,xev.event_number
           ,xev.event_date
           ,xev.transaction_date
           ,xev.event_status_code
           ,xev.process_status_code
           ,xev.valuation_method
           ,NVL(xev.budgetary_control_flag,'N')
           ,xev.reference_num_1
           ,xev.reference_num_2
           ,xev.reference_num_3
           ,xev.reference_num_4
           ,xev.reference_char_1
           ,xev.reference_char_2
           ,xev.reference_char_3
           ,xev.reference_char_4
           ,xev.reference_date_1
           ,xev.reference_date_2
           ,xev.reference_date_3
           ,xev.reference_date_4
       FROM xla_entity_events_v        xev
          , xla_acct_prog_events_gt    xap
      WHERE xev.application_id         = g_application_id
        AND xev.event_id               = xap.event_id
        AND xev.process_status_code    = 'U'
        AND xev.event_status_code     IN ('U',DECODE(g_accounting_mode,'F','N','U'))
        AND xev.on_hold_flag           = 'N'
        AND xev.event_type_code not in ('FULL_MERGE', 'PARTIAL_MERGE')
        AND xap.ledger_id              = g_ledger_id
        AND xap.event_id IN (
                          SELECT xla_events.event_id
                FROM    xla_acct_prog_events_gt     ,
                    xla_events                  ,
                    xla_event_types_b           ,
                    xla_transaction_entities,
                    xla_evt_class_orders_gt
                WHERE   xla_events.event_id                         = xla_acct_prog_events_gt.event_id
                    AND xla_events.application_id                   = g_application_id
                    AND xla_transaction_entities.application_id = g_application_id
                    AND xla_events.entity_id                        = xla_transaction_entities.entity_id
                    AND xla_event_types_b.application_id            = g_application_id
                    AND xla_transaction_entities.entity_code    = xla_event_types_b.entity_code
                    AND xla_events.event_type_code                  = xla_event_types_b.event_type_code
                    AND xla_event_types_b.event_class_code          = xla_evt_class_orders_gt.event_class_code
		     AND xla_events.process_status_code <> 'P'  --condition added, bug8680284
                    AND xla_evt_class_orders_gt.processing_order = l_processing_order
                             )
      ORDER BY xev.entity_id, xev.event_number;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => '# rows inserted into xla_events_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;


   -- bug 7193986 end


   SELECT max(event_date)
     INTO l_max_event_date
     FROM xla_events_gt;
   --
   -- Call subledger extract API
   --
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - executing extract hook');
   handle_accounting_hook
                 (p_application_id         => g_application_id
                 ,p_ledger_id              => NULL
                 ,p_process_category       => NULL
                 ,p_end_date               => NULL
                 ,p_accounting_mode        => g_accounting_mode
                 ,p_budgetary_control_mode => g_budgetary_control_mode
                 ,p_valuation_method       => NULL
                 ,p_security_id_int_1      => NULL
                 ,p_security_id_int_2      => NULL
                 ,p_security_id_int_3      => NULL
                 ,p_security_id_char_1     => NULL
                 ,p_security_id_char_2     => NULL
                 ,p_security_id_char_3     => NULL
                 ,p_report_request_id      => NULL
                 ,p_event_name             => 'extract'
                 ,p_event_key              =>  to_char(g_accounting_batch_id));
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - extract hook executed successfully');

   xla_accounting_err_pkg.set_options
            (p_error_source     => xla_accounting_err_pkg.C_ACCT_ENGINE);

   l_ret_val_acctg_engine :=
         xla_accounting_engine_pkg.AccountingEngine
            (p_application_id         => g_application_id
            ,p_ledger_id              => g_ledger_id
            ,p_end_date               => l_max_event_date
            ,p_accounting_mode        => g_accounting_mode
            ,p_accounting_batch_id    => g_accounting_batch_id
            ,p_budgetary_control_mode => g_budgetary_control_mode
            );

   xla_accounting_err_pkg.set_options
            (p_error_source     => xla_accounting_err_pkg.C_ACCT_PROGRAM);

   --
   -- Call subledger post-processing API
   --
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - executing postprocessing hook');
   handle_accounting_hook
                 (p_application_id         => g_application_id
                 ,p_ledger_id              => NULL
                 ,p_process_category       => NULL
                 ,p_end_date               => NULL
                 ,p_accounting_mode        => g_accounting_mode
                 ,p_budgetary_control_mode => g_budgetary_control_mode
                 ,p_valuation_method       => NULL
                 ,p_security_id_int_1      => NULL
                 ,p_security_id_int_2      => NULL
                 ,p_security_id_int_3      => NULL
                 ,p_security_id_char_1     => NULL
                 ,p_security_id_char_2     => NULL
                 ,p_security_id_char_3     => NULL
                 ,p_report_request_id      => NULL
                 ,p_event_name             => 'postprocessing'
                 ,p_event_key              =>  to_char(g_accounting_batch_id));
   print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - postprocessing hook executed successfully');

   complete_entries;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure events_processor'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_accounting_pkg.events_processor');
END events_processor;  -- end of procedure

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE delete_batch_je
IS

CURSOR c_headers IS
  SELECT /*+ LEADING (XAP) USE_NL (XAP XE XAH) */
         xah.ae_header_id
    FROM xla_ae_headers          xah
       , xla_events              xe
       , xla_acct_prog_events_gt xap
   WHERE xah.application_id                = xe.application_id
     AND xah.event_id                      = xe.event_id
     AND xah.accounting_entry_status_code <> 'F'
     AND xe.application_id                 = g_application_id
     AND xe.process_status_code           <> 'P'
     AND xe.event_id                       = xap.event_id;

l_array_event_id                  t_array_integer;
l_array_header_id                 t_array_integer;
l_array_packet_id                 t_array_integer;
l_log_module                      VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_batch_je';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg      => 'BEGIN of procedure delete_batch_je'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  SELECT /*+ leading(xap,xe) use_nl(xe) index(xe,XLA_EVENTS_U1) */
         xe.event_id
    BULK COLLECT INTO l_array_event_id
    FROM xla_events              xe
       , xla_acct_prog_events_gt xap
   WHERE xe.application_id       = g_application_id
     AND xe.process_status_code <> 'P'
     AND xe.event_id             = xap.event_id;

  IF (l_array_event_id.COUNT > 0) THEN

    FORALL i IN 1..l_array_event_id.COUNT
      DELETE FROM xla_accounting_errors
         WHERE application_id = g_application_id
           AND event_id = l_array_event_id(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => '# xla_accounting_errors deleted = '||SQL%ROWCOUNT
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
    END IF;

    FORALL i IN 1..l_array_event_id.COUNT
      DELETE FROM xla_diag_sources
        WHERE event_id = l_array_event_id(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace(p_msg      => '# xla_diag_sources deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
    END IF;

    FORALL i IN 1..l_array_event_id.COUNT
      DELETE FROM xla_diag_events
       WHERE application_id = g_application_id
         AND event_id = l_array_event_id(i);

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace(p_msg      => '# xla_diag_events deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
    END IF;
    --bug6369888
    DELETE FROM xla_diag_ledgers d
	WHERE d.application_id = g_application_id
	AND NOT EXISTS
		(SELECT ledger_id,     request_id
		 FROM xla_diag_events
		WHERE application_id = d.application_id
		AND   request_id = d.accounting_request_id
		AND   ledger_id = d.primary_ledger_id
		 );

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '# xla_diag_ledgers deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;

    FORALL i IN 1..l_array_event_id.COUNT
      DELETE FROM gl_bc_packets
       WHERE application_id = g_application_id
         AND event_id = l_array_event_id(i)
       RETURNING packet_id BULK COLLECT INTO l_array_packet_id;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace(p_msg      => '# gl_bc_packets deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
    END IF;

    IF (l_array_packet_id.COUNT > 0) THEN
      FORALL i IN 1..l_array_packet_id.COUNT
        DELETE FROM gl_bc_packet_arrival_order
         WHERE packet_id = l_array_packet_id(i);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg      => '# gl_bc_packet_arrival_order deleted = '||SQL%ROWCOUNT
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
      END IF;
    END IF;

    OPEN c_headers;
    FETCH c_headers BULK COLLECT INTO l_array_header_id;
    CLOSE c_headers;

    IF (l_array_header_id.COUNT > 0) THEN
      FORALL i IN 1..l_array_header_id.COUNT
        DELETE FROM xla_distribution_links
         WHERE application_id = g_application_id
           AND ae_header_id = l_array_header_id(i);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg      => '# xla_distribution_links deleted = '||SQL%ROWCOUNT
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
      END IF;

      FORALL i IN 1..l_array_header_id.COUNT
        DELETE FROM xla_ae_segment_values
         WHERE ae_header_id = l_array_header_id(i);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace (p_msg      => '# xla_ae_segment_values deleted = '||SQL%ROWCOUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
      END IF;

      FORALL i IN 1..l_array_header_id.COUNT
        DELETE FROM xla_ae_line_acs
         WHERE ae_header_id = l_array_header_id(i);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace (p_msg      => '# xla_ae_line_acs deleted = '||SQL%ROWCOUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
      END IF;

      FORALL i IN 1..l_array_header_id.COUNT
        DELETE FROM xla_ae_header_acs
         WHERE ae_header_id = l_array_header_id(i);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace (p_msg      => '# xla_ae_header_acs deleted = '||SQL%ROWCOUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
      END IF;

      FORALL i IN 1..l_array_header_id.COUNT
        DELETE FROM xla_ae_lines
         WHERE application_id = g_application_id
           AND ae_header_id = l_array_header_id(i);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_msg      => '# xla_ae_lines deleted = '||SQL%ROWCOUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
      END IF;

      FORALL i IN 1..l_array_header_id.COUNT
        DELETE FROM xla_ae_headers
         WHERE application_id = g_application_id
           AND ae_header_id = l_array_header_id(i);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_msg      => '# xla_ae_headers deleted = '||SQL%ROWCOUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
      END IF;
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg      => 'END of procedure delete_batch_je'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_pkg.delete_batch_je');
END delete_batch_je;


--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following routines are used while accounting for batch of documents as well
-- as for a single document
--
--    2.    complete_entries
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================

--=============================================================================
--
--
--
--=============================================================================

PROCEDURE complete_entries IS
l_index                           NUMBER         := 0;
l_array_ae_header_id              t_array_number;
l_array_completion_date           t_array_date;
l_array_seq_version_id            t_array_number;
l_array_sequence_number           t_array_number;
l_array_assignment_id             t_array_number;
l_array_error_code                t_array_char;

l_xla_application_id              NUMBER         := 602;
l_xla_seq_entity                  VARCHAR2(30)   := 'XLA_AE_HEADERS';
l_seq_event_code                  VARCHAR2(30)   := 'COMPLETION';
l_control_attribute_rec           fun_seq.control_attribute_rec_type;
l_control_date_tbl                fun_seq.control_date_tbl_type;

l_sqlerrm                         VARCHAR2(2000);
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.complete_entries';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure COMPLETE_ENTRIES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- If "accounting mode = F", perform sequencing for the subledger journal
   -- entries
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_accounting_mode = '||g_accounting_mode
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF g_accounting_mode = 'F' THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'g_processing_mode = '||g_processing_mode
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      => 'g_seq_enabled_flag = '||g_seq_enabled_flag
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      IF g_processing_mode = 'BATCH' AND g_seq_enabled_flag = 'Y' THEN
         BEGIN
            print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Calling sequencing populate_acct_seq_info');

            IF (C_LEVEL_EVENT >= g_log_level) THEN
               trace
                  (p_msg      => 'Calling procedure FUN_SEQ_BATCH.POPULATE_ACCT_SEQ_INFO'
                  ,p_level    => C_LEVEL_EVENT
                  ,p_module   => l_log_module);
            END IF;

            fun_seq_batch.populate_acct_seq_info
               (p_calling_program         => 'ACCOUNTING'
               ,p_request_id              => g_parent_request_id);

            IF (C_LEVEL_EVENT >= g_log_level) THEN
               trace
                  (p_msg      => 'Procedure FUN_SEQ_BATCH.POPULATE_ACCT_SEQ_INFO executed'
                  ,p_level    => C_LEVEL_EVENT
                  ,p_module   => l_log_module);
            END IF;

            print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Returned from sequencing populate_acct_seq_info');
         EXCEPTION
         WHEN OTHERS THEN
            l_sqlerrm := sqlerrm;

            IF (C_LEVEL_EXCEPTION>= g_log_level) THEN
               trace
                  (p_msg      => 'Technical problem : Problem encountered in sequencing POPULATE_ACCT_SEQ_INFO.'||
                                 xla_environment_pkg.g_chr_newline||
                                 l_sqlerrm
                  ,p_level    => C_LEVEL_EXCEPTION
                  ,p_module   => l_log_module);
            END IF;

            xla_accounting_err_pkg.build_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
               ,p_token_1        => 'APPLICATION_NAME'
               ,p_value_1        => 'SLA'
               ,p_entity_id      => NULL
               ,p_event_id       => NULL);

            print_logfile('Technical problem : Problem encountered in sequencing POPULATE_ACCT_SEQ_INFO.');

            xla_exceptions_pkg.raise_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_COMMON_ERROR'
               ,p_token_1        => 'LOCATION'
               ,p_value_1        => 'xla_accounting_pkg.complete_entries'
               ,p_token_2        => 'ERROR'
               ,p_value_2        => 'Technical problem : Problem encountered in sequencing POPULATE_ACCT_SEQ_INFO.'||
                                    xla_environment_pkg.g_chr_newline||
                                    l_sqlerrm);
         END;
      ELSIF g_processing_mode = 'DOCUMENT' THEN
         print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Calling sequencing get_sequence_number');

         FOR c1 IN (SELECT /*+ leading(xsl,xeg,aeh) use_nl(aeh) index(xla_ae_headers_n2) */
                           aeh.ae_header_id                ae_header_id
                          ,aeh.ledger_id                   ledger_id
                          ,aeh.balance_type_code           balance_type_code
                          ,xsl.je_source_name              je_source_name
                          ,aeh.je_category_name            je_category_name
                          ,aeh.doc_category_code           doc_category_code
                          ,aeh.event_type_code             accounting_event_type_code
                          ,aeh.accounting_entry_type_code  accounting_entry_type_code
                          ,aeh.accounting_date             gl_date
                          ,aeh.completed_date              completion_date
                      FROM xla_ae_headers  aeh
                          ,xla_events_gt   xeg
                          ,xla_subledgers  xsl
                     WHERE aeh.application_id = xeg.application_id
                       AND aeh.event_id       = xeg.event_id
                       AND xsl.application_id = xeg.application_id
                       AND xsl.application_id = g_application_id
                       AND nvl(aeh.zero_amount_flag, 'N') = 'N')
         LOOP
            l_index                                         := l_index + 1;

            l_control_attribute_rec.balance_type            := c1.balance_type_code;
            l_control_attribute_rec.journal_source          := c1.je_source_name;
            l_control_attribute_rec.journal_category        := c1.je_category_name;
            l_control_attribute_rec.document_category       := c1.doc_category_code;
            l_control_attribute_rec.accounting_event_type   := g_application_id||'.'||c1.accounting_event_type_code;
            l_control_attribute_rec.accounting_entry_type   := c1.accounting_entry_type_code;

            l_control_date_tbl := fun_seq.control_date_tbl_type();
            l_control_date_tbl.EXTEND(2);
            l_control_date_tbl(1).date_type                 :='GL_DATE';
            l_control_date_tbl(1).date_value                := c1.gl_date;
            l_control_date_tbl(2).date_type                 :='COMPLETION_DATE';
            l_control_date_tbl(2).date_value                := c1.completion_date;

            BEGIN
               IF (C_LEVEL_EVENT >= g_log_level) THEN
                  trace
                     (p_msg      => 'Calling procedure FUN_SEQ.GET_SEQUENCE_NUMBER'
                     ,p_level    => C_LEVEL_EVENT
                     ,p_module   => l_log_module);
               END IF;

               fun_seq.get_sequence_number
                  (p_context_type           => 'LEDGER_AND_CURRENCY'
                  ,p_context_value          => c1.ledger_id
                  ,p_application_id         => l_xla_application_id
                  ,p_table_name             => l_xla_seq_entity
                  ,p_event_code             => l_seq_event_code
                  ,p_control_attribute_rec  => l_control_attribute_rec
                  ,p_control_date_tbl       => l_control_date_tbl
                  ,p_suppress_error         => 'N'
                  ,x_seq_version_id         => l_array_seq_version_id(l_index)
                  ,x_sequence_number        => l_array_sequence_number(l_index)
                  ,x_assignment_id          => l_array_assignment_id(l_index)
                  ,x_error_code             => l_array_error_code(l_index));

               IF (C_LEVEL_EVENT >= g_log_level) THEN
                  trace
                     (p_msg      => 'Procedure FUN_SEQ.GET_SEQUENCE_NUMBER executed'
                     ,p_level    => C_LEVEL_EVENT
                     ,p_module   => l_log_module);
               END IF;

            l_array_ae_header_id(l_index)    := c1.ae_header_id;
            l_array_completion_date(l_index) := sysdate;

            EXCEPTION
            WHEN OTHERS THEN
               l_sqlerrm := sqlerrm;

               IF (C_LEVEL_EXCEPTION>= g_log_level) THEN
                  trace
                     (p_msg      => 'Technical problem : Problem encountered in sequencing GET_SEQUENCE_NUMBER.'||
                                    xla_environment_pkg.g_chr_newline||
                                    l_sqlerrm
                     ,p_level    => C_LEVEL_EXCEPTION
                     ,p_module   => l_log_module);
               END IF;

               xla_accounting_err_pkg.build_message
                  (p_appli_s_name   => 'XLA'
                  ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
                  ,p_token_1        => 'APPLICATION_NAME'
                  ,p_value_1        => 'SLA'
                  ,p_entity_id      => NULL
                  ,p_event_id       => NULL);

               print_logfile('Technical problem : Problem encountered in sequencing GET_SEQUENCE_NUMBER.');

               xla_exceptions_pkg.raise_message
                  (p_appli_s_name   => 'XLA'
                  ,p_msg_name       => 'XLA_COMMON_ERROR'
                  ,p_token_1        => 'LOCATION'
                  ,p_value_1        => 'xla_accounting_pkg.complete_entries'
                  ,p_token_2        => 'ERROR'
                  ,p_value_2        => 'Technical problem : Problem encountered in sequencing GET_SEQUENCE_NUMBER.'||
                                       xla_environment_pkg.g_chr_newline||
                                       l_sqlerrm);
            END;
         END LOOP;

         FORALL i IN 1..l_array_ae_header_id.COUNT
         UPDATE xla_ae_headers  aeh
            SET aeh.completed_date                 = l_array_completion_date(i)
               ,aeh.completion_acct_seq_assign_id  = l_array_assignment_id(i)
               ,aeh.completion_acct_seq_version_id = l_array_seq_version_id(i)
               ,aeh.completion_acct_seq_value      = l_array_sequence_number(i)
          WHERE aeh.ae_header_id = l_array_ae_header_id(i);

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'Number of headers sequenced = '||SQL%ROWCOUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;
         print_logfile(to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||' - Returned from sequencing get_sequence_number');
      END IF;
   END IF;

   ----------------------------------------------------------------------------
   -- Following updates event status in xla_events.
   -- Statement updated to fix Bug # 3051978
   -- Statement updated to fix Bug # 4961401
   ----------------------------------------------------------------------------
   UPDATE (SELECT /*+ leading(tmp) index(evt, XLA_EVENTS_U1) use_nl(evt)*/ --4769388
                  evt.event_status_code
                 ,evt.process_status_code
                 ,evt.last_update_date
                 ,evt.last_updated_by
                 ,evt.last_update_login
                 ,evt.program_update_date
                 ,evt.program_application_id
                 ,evt.program_id
                 ,evt.request_id
		 ,evt.reference_char_4 --bug 13811614
                 --,DECODE(tmp.process_status_code,'P','P','U')  new_event_status_code -- bug 4961401
                 ,CASE WHEN evt.event_status_code = 'N' OR tmp.event_status_code = 'N' THEN 'N' --bug 13811614
                       WHEN tmp.process_status_code = 'P' THEN 'P'
                       ELSE 'U' END new_event_status_code
                 --,tmp.process_status_code                      new_process_status_code -- bug 4961401
                 ,DECODE(evt.event_status_code,'N','P',tmp.process_status_code) new_process_status_code
		 ,tmp.reference_char_4 new_reference_char_4 --bug 13811614
             FROM xla_events           evt
                 ,xla_events_gt        tmp
            WHERE evt.event_id            = tmp.event_id
              AND evt.application_id      = g_application_id
            )
       SET event_status_code       = new_event_status_code
          ,process_status_code     = new_process_status_code
	  ,reference_char_4        = new_reference_char_4
          ,last_update_date        = sysdate
          ,last_updated_by         = xla_environment_pkg.g_usr_id
          ,last_update_login       = xla_environment_pkg.g_login_id
          ,request_id              = g_report_request_id;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of events updated = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

 -- Start of 12411043
 /*
 -- Start of 8411568

 	    UPDATE xla_events xe
 	    SET    xe.event_status_code       = 'P'
 	          ,xe.process_status_code     = 'P'
 	          ,xe.last_update_date        = sysdate
 	          ,xe.last_updated_by         = xla_environment_pkg.g_usr_id
 	          ,xe.last_update_login       = xla_environment_pkg.g_login_id
 	          ,xe.request_id              = g_report_request_id
 	    WHERE  xe.event_id IN (SELECT   xle.event_id
 	                           FROM     gl_ledgers glg
 	                                   ,xla_acctg_methods_b xam
 	                                   ,xla_acctg_method_rules xamr
 	                                   ,xla_prod_acct_headers xpah
 	                                   ,xla_event_types_b xetb
 	                                   ,xla_aad_line_defn_assgns xald
 	                                   ,xla_line_definitions_b xldb
 	                                   ,xla_ledger_relationships_v xlr
 	                                   ,xla_ledger_options xlo
 	                                   ,xla_events_gt xle
 	                           WHERE    glg.sla_accounting_method_code = xam.accounting_method_code
 	                                    AND glg.sla_accounting_method_type = xam.accounting_method_type_code
 	                                    AND xam.accounting_method_code = xamr.accounting_method_code
 	                                    AND xam.accounting_method_type_code = xamr.accounting_method_type_code
 	                                    AND xamr.application_id = xle.application_id
 	                                    AND xetb.application_id = xpah.application_id
 	                                    AND xetb.entity_code = xpah.entity_code
 	                                    AND xetb.event_class_code = xpah.event_class_code
 	                                    AND (Substr(xpah.event_type_code,-4) = '_ALL'
 	                                          OR xetb.event_type_code = xpah.event_type_code)
 	                                    AND xpah.application_id = xamr.application_id
 	                                    AND xpah.product_rule_type_code = xamr.product_rule_type_code
 	                                    AND xpah.product_rule_code = xamr.product_rule_code
 	                                    AND xpah.amb_context_code = xamr.amb_context_code
 	                                    AND xpah.amb_context_code = Nvl(xla_profiles_pkg.Get_value('XLA_AMB_CONTEXT'),
 	                                                                    'DEFAULT')
 	                                    AND xetb.event_type_code = xle.event_type_code
 	                                    AND xle.event_status_code = 'U'
 	                                    AND xle.process_status_code = 'U'
 	                                    AND glg.ledger_id = xlr.ledger_id
 	                                    AND xlr.primary_ledger_id = xle.ledger_id
 	                                    AND xlr.relationship_enabled_flag = 'Y'
 	                                    AND xlr.ledger_id = xlo.ledger_id
 	                                    AND xlo.application_id = xle.application_id
 	                                    AND xlo.enabled_flag = 'Y'
 	                                    AND xald.application_id(+) = xpah.application_id
 	                                    AND xald.amb_context_code(+) = xpah.amb_context_code
 	                                    AND xald.product_rule_type_code(+) =  xpah.product_rule_type_code
 	                                    AND xald.product_rule_code(+) = xpah.product_rule_code
 	                                    AND xald.event_class_code(+) = xpah.event_class_code
 	                                    AND xald.event_type_code(+) = xpah.event_type_code
 	                                    AND xald.application_id = xldb.application_id(+)
 	                                    AND xald.amb_context_code = xldb.amb_context_code(+)
 	                                    AND xald.event_class_code = xldb.event_class_code (+)
 	                                    AND xald.event_type_code = xldb.event_type_code(+)
 	                                    AND xald.line_definition_owner_code = xldb.line_definition_owner_code(+)
 	                                    AND xald.line_definition_code = xldb.line_definition_code(+)
 	                                    AND xldb.enabled_flag(+) = 'Y'
 	                           GROUP BY xle.event_id
 	                           HAVING   Sum(CASE
 	                                            WHEN xle.event_date BETWEEN Nvl(xamr.start_date_active,xle.event_date)
 	                                                 AND Nvl(xamr.end_date_active,xle.event_date)
 	                                            THEN Decode(Nvl(xpah.accounting_required_flag,'N'),'Y'
 	                                                       ,Decode(Nvl(xldb.budgetary_control_flag,'X'),xle.budgetary_control_flag,1,0)
 	                                                       ,0)
 	                                            ELSE 0
 	                                        END) = 0)
 	    AND    xe.event_status_code = 'U'
 	    AND    xe.process_status_code = 'U'
 	    AND    xe.application_id = g_application_id;

 	    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
 	       trace
 	          (p_msg      => 'Number of events updated (accounting not needed): = '||SQL%ROWCOUNT
 	          ,p_level    => C_LEVEL_STATEMENT
 	          ,p_module   => l_log_module);
 	    END IF;

 	 -- End of 8411568
         */
      -- End of 12411043
   ----------------------------------------------------------------------------
   -- Following call inserts errors into error table
   ----------------------------------------------------------------------------
   --xla_accounting_err_pkg.insert_errors; -- bug 5206382

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure COMPLETE_ENTRIES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_accounting_pkg.complete_entries');
END complete_entries;  -- end of procedure


--------------------------------------------------------------------------------
-- This procedure is used to raise preaccounting event or postaccounting event
-- p_event_name will be 'preaccounting' or 'postaccounting'
--------------------------------------------------------------------------------
PROCEDURE raise_accounting_event( p_application_id IN NUMBER
                 ,p_ledger_id IN NUMBER
                 ,p_process_category IN VARCHAR2
                 ,p_end_date IN DATE
                 ,p_accounting_mode IN VARCHAR2
                 ,p_valuation_method IN VARCHAR2
                 ,p_security_id_int_1 IN NUMBER
                 ,p_security_id_int_2 IN NUMBER
                 ,p_security_id_int_3 IN NUMBER
                 ,p_security_id_char_1 IN VARCHAR2
                 ,p_security_id_char_2 IN VARCHAR2
                 ,p_security_id_char_3 IN VARCHAR2
                 ,p_report_request_id IN NUMBER
                 ,p_event_name IN VARCHAR2
                 ,p_event_key IN VARCHAR2)
IS

x_progress VARCHAR2(100) := '000';
l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
l_event_name VARCHAR2(50):='oracle.apps.xla.accounting.'||p_event_name;
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.raise_accounting_event';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure RAISE_ACCOUNTING_EVENT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_process_category = '||p_process_category
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_end_date = '||p_end_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_1 = '||p_security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_2 = '||p_security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_int_3 = '||p_security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_1 = '||p_security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_2 = '||p_security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_security_id_char_3 = '||p_security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_report_request_id = '||p_report_request_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_name = '||p_event_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_key = '||p_event_key
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   print_logfile('event key = '||p_event_key);

x_progress := '001';

-- Add Parameters
wf_event.AddParameterToList(p_name =>'APPLICATION_ID',
                                                        p_value => p_application_id,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'LEDGER_ID',
                                                        p_value => p_ledger_id,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'PROCESS_CATEGORY',
                                                        p_value => p_process_category,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'END_DATE',
                                                        p_value => p_end_date,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'ACCOUNTING_MODE',
                                                        p_value => p_accounting_mode,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'VALUATION_METHOD',
                                                        p_value => p_valuation_method,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'SECURITY_ID_INT_1',
                                                        p_value => p_security_id_int_1,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'SECURITY_ID_INT_2',
                                                        p_value => p_security_id_int_2,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'SECURITY_ID_INT_3',
                                                        p_value => p_security_id_int_3,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'SECURITY_ID_CHAR_1',
                                                        p_value => p_security_id_char_1,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'SECURITY_ID_CHAR_2',
                                                        p_value => p_security_id_char_2,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'SECURITY_ID_CHAR_3',
                                                        p_value => p_security_id_char_3,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'REQUEST_ID',
                                                        p_value => p_report_request_id,
                                                        p_parameterlist => l_parameter_list);

-- FSAH-PSFT FP
if(fnd_profile.value('XLA_FSAH_EXT_CCID_VAL') IS NOT NULL) THEN
	 wf_event.AddParameterToList(p_name =>'ACCOUNTING_BATCH_ID',
							  p_value => g_accounting_batch_id,
							  p_parameterlist =>l_parameter_list);
 END IF; -- FSAH-PSFT FP

x_progress := '002';

wf_event.RAISE( p_event_name => l_event_name,
                                        p_event_key => p_event_key,
                                        p_parameters => l_parameter_list);


l_parameter_list.DELETE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure RAISE_ACCOUNTING_EVENT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
  WHEN others THEN
    wf_core.CONTEXT('xla_accounting_pkg','raise_accounting_event',x_progress);
        RAISE;

END raise_accounting_event;


--------------------------------------------------------------------------------
-- This procedure is used to raise postprocessing event or extract event
-- p_event_name will be 'postprocessing' or 'extract'
--------------------------------------------------------------------------------
PROCEDURE raise_unit_event( p_application_id IN NUMBER
                 ,p_accounting_mode IN VARCHAR2
                 ,p_event_name IN VARCHAR2
                 ,p_event_key IN VARCHAR2)
IS

x_progress VARCHAR2(100) := '000';
l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
l_event_name VARCHAR2(50):='oracle.apps.xla.accounting.'||p_event_name;
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.raise_unit_event';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure RAISE_UNIT_EVENT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_name = '||p_event_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_key = '||p_event_key
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   print_logfile('event key = '||p_event_key);

x_progress := '001';

-- Add Parameters
wf_event.AddParameterToList(p_name =>'APPLICATION_ID',
                                                        p_value => p_application_id,
                                                        p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'ACCOUNTING_MODE',
                                                        p_value => p_accounting_mode,
                                                        p_parameterlist => l_parameter_list);
x_progress := '002';

wf_event.RAISE( p_event_name => l_event_name,
                                        p_event_key => p_event_key,
                                        p_parameters => l_parameter_list);

l_parameter_list.DELETE;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure RAISE_UNIT_EVENT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
  WHEN others THEN
    wf_core.CONTEXT('xla_accounting_pkg','raise_unit_event',x_progress);
        RAISE;

END raise_unit_event;

--------------------------------------------------------------------------------
-- This procedure is used to handle accounting hooks for preaccounting, extract,
-- postprocessing and postaccounting.
-- p_event_name will be 'postprocessing' or 'extract' or 'preaccounting' or
-- 'postaccounting'
--------------------------------------------------------------------------------
PROCEDURE handle_accounting_hook
       (p_application_id         IN NUMBER
       ,p_ledger_id              IN NUMBER
       ,p_process_category       IN VARCHAR2
       ,p_end_date               IN DATE
       ,p_accounting_mode        IN VARCHAR2
       ,p_budgetary_control_mode IN VARCHAR2
       ,p_valuation_method       IN VARCHAR2
       ,p_security_id_int_1      IN NUMBER
       ,p_security_id_int_2      IN NUMBER
       ,p_security_id_int_3      IN NUMBER
       ,p_security_id_char_1     IN VARCHAR2
       ,p_security_id_char_2     IN VARCHAR2
       ,p_security_id_char_3     IN VARCHAR2
       ,p_report_request_id      IN NUMBER
       ,p_event_name             IN VARCHAR2
       ,p_event_key              IN VARCHAR2)
IS
l_log_module              VARCHAR2(240);
l_sqlerrm                 VARCHAR2(2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.handle_accounting_hook';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure handle_accounting_hook'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

 --------------------------------------------------------------------------
 -- Calling different API's depending on Application ID
 --------------------------------------------------------------------------
  CASE
      --
      -- For Account Payables
      --
      WHEN p_application_id = 200 THEN
            xla_ap_acct_hooks_pkg.main
               ( p_application_id     => p_application_id
                ,p_ledger_id          => p_ledger_id
                ,p_process_category   => p_process_category
                ,p_end_date           => p_end_date
                ,p_accounting_mode    => CASE WHEN NVL(p_budgetary_control_mode,'NONE') = 'NONE'
                                              THEN p_accounting_mode
                                              ELSE p_budgetary_control_mode
                                         END -- 4606566
                ,p_valuation_method   => p_valuation_method
                ,p_security_id_int_1  => p_security_id_int_1
                ,p_security_id_int_2  => p_security_id_int_2
                ,p_security_id_int_3  => p_security_id_int_3
                ,p_security_id_char_1 => p_security_id_char_1
                ,p_security_id_char_2 => p_security_id_char_2
                ,p_security_id_char_3 => p_security_id_char_3
                ,p_report_request_id  => p_report_request_id
                ,p_event_name         => p_event_name);

      --
      -- For Account Recievables
      --
      WHEN p_application_id = 222 THEN
            xla_ar_acct_hooks_pkg.main
               ( p_application_id     => p_application_id
                ,p_ledger_id          => p_ledger_id
                ,p_process_category   => p_process_category
                ,p_end_date           => p_end_date
                ,p_accounting_mode    => p_accounting_mode
                ,p_valuation_method   => p_valuation_method
                ,p_security_id_int_1  => p_security_id_int_1
                ,p_security_id_int_2  => p_security_id_int_2
                ,p_security_id_int_3  => p_security_id_int_3
                ,p_security_id_char_1 => p_security_id_char_1
                ,p_security_id_char_2 => p_security_id_char_2
                ,p_security_id_char_3 => p_security_id_char_3
                ,p_report_request_id  => p_report_request_id
                ,p_event_name         => p_event_name);

      --
      -- For Fixed Assets
      --
      WHEN p_application_id = 140 THEN
            xla_fa_acct_hooks_pkg.main
               ( p_application_id     => p_application_id
                ,p_ledger_id          => p_ledger_id
                ,p_process_category   => p_process_category
                ,p_end_date           => p_end_date
                ,p_accounting_mode    => p_accounting_mode
                ,p_valuation_method   => p_valuation_method
                ,p_security_id_int_1  => p_security_id_int_1
                ,p_security_id_int_2  => p_security_id_int_2
                ,p_security_id_int_3  => p_security_id_int_3
                ,p_security_id_char_1 => p_security_id_char_1
                ,p_security_id_char_2 => p_security_id_char_2
                ,p_security_id_char_3 => p_security_id_char_3
                ,p_report_request_id  => p_report_request_id
                ,p_event_name         => p_event_name);

      --
      -- For Cash Managment
      --
      WHEN p_application_id = 260 THEN
            xla_ce_acct_hooks_pkg.main
               ( p_application_id     => p_application_id
                ,p_ledger_id          => p_ledger_id
                ,p_process_category   => p_process_category
                ,p_end_date           => p_end_date
                ,p_accounting_mode    => p_accounting_mode
                ,p_valuation_method   => p_valuation_method
                ,p_security_id_int_1  => p_security_id_int_1
                ,p_security_id_int_2  => p_security_id_int_2
                ,p_security_id_int_3  => p_security_id_int_3
                ,p_security_id_char_1 => p_security_id_char_1
                ,p_security_id_char_2 => p_security_id_char_2
                ,p_security_id_char_3 => p_security_id_char_3
                ,p_report_request_id  => p_report_request_id
                ,p_event_name         => p_event_name);



      --
      -- For Process Manufacturing Financials
      --

      WHEN p_application_id = 555 THEN
            xla_gmf_acct_hooks_pkg.main
               ( p_application_id     => p_application_id
                ,p_ledger_id          => p_ledger_id
                ,p_process_category   => p_process_category
                ,p_end_date           => p_end_date
                ,p_accounting_mode    => p_accounting_mode
                ,p_valuation_method   => p_valuation_method
                ,p_security_id_int_1  => p_security_id_int_1
                ,p_security_id_int_2  => p_security_id_int_2
                ,p_security_id_int_3  => p_security_id_int_3
                ,p_security_id_char_1 => p_security_id_char_1
                ,p_security_id_char_2 => p_security_id_char_2
                ,p_security_id_char_3 => p_security_id_char_3
                ,p_report_request_id  => p_report_request_id
                ,p_event_name         => p_event_name);

      --
      -- For Payroll
      --

      WHEN p_application_id = 801 THEN
            xla_pay_acct_hooks_pkg.main
               ( p_application_id     => p_application_id
                ,p_ledger_id          => p_ledger_id
                ,p_process_category   => p_process_category
                ,p_end_date           => p_end_date
                ,p_accounting_mode    => p_accounting_mode
                ,p_valuation_method   => p_valuation_method
                ,p_security_id_int_1  => p_security_id_int_1
                ,p_security_id_int_2  => p_security_id_int_2
                ,p_security_id_int_3  => p_security_id_int_3
                ,p_security_id_char_1 => p_security_id_char_1
                ,p_security_id_char_2 => p_security_id_char_2
                ,p_security_id_char_3 => p_security_id_char_3
                ,p_report_request_id  => p_report_request_id
                ,p_event_name         => p_event_name);

      -- Bug 12725312
      -- Added a call to OKL API.
      --
      -- For Lease Management
      --

      WHEN p_application_id = 540 THEN
            xla_okl_acct_hooks_pkg.main
               ( p_application_id     => p_application_id
                ,p_ledger_id          => p_ledger_id
                ,p_process_category   => p_process_category
                ,p_end_date           => p_end_date
                ,p_accounting_mode    => p_accounting_mode
                ,p_valuation_method   => p_valuation_method
                ,p_security_id_int_1  => p_security_id_int_1
                ,p_security_id_int_2  => p_security_id_int_2
                ,p_security_id_int_3  => p_security_id_int_3
                ,p_security_id_char_1 => p_security_id_char_1
                ,p_security_id_char_2 => p_security_id_char_2
                ,p_security_id_char_3 => p_security_id_char_3
                ,p_report_request_id  => p_report_request_id
                ,p_event_name         => p_event_name);

      --
      -- For all other products
      --
      ELSE
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'Warning: Product is not integrated using APIs'
                  ,p_level    => C_LEVEL_PROCEDURE
                  ,p_module   => l_log_module);
            END IF;
  END CASE;

  --
  -- raising business event for all the subledgers
  --

  IF p_event_name IN ('extract','postprocessing') THEN
          raise_unit_event
            (p_application_id  => p_application_id
            ,p_accounting_mode => p_accounting_mode
            ,p_event_name      => p_event_name
            ,p_event_key       => p_event_key);
    ELSE
          raise_accounting_event
            (p_application_id     => p_application_id
            ,p_ledger_id          => p_ledger_id
            ,p_process_category   => p_process_category
            ,p_end_date           => p_end_date
            ,p_accounting_mode    => p_accounting_mode
            ,p_valuation_method   => p_valuation_method
            ,p_security_id_int_1  => p_security_id_int_1
            ,p_security_id_int_2  => p_security_id_int_2
            ,p_security_id_int_3  => p_security_id_int_3
            ,p_security_id_char_1 => p_security_id_char_1
            ,p_security_id_char_2 => p_security_id_char_2
            ,p_security_id_char_3 => p_security_id_char_3
            ,p_report_request_id  => p_report_request_id
            ,p_event_name         => p_event_name
            ,p_event_key          => p_event_key);
  END IF;

  -- Call to PSA accounting hook
  xla_psa_acct_hooks_pkg.main
               ( p_application_id     => p_application_id
                ,p_ledger_id          => p_ledger_id
                ,p_process_category   => p_process_category
                ,p_end_date           => p_end_date
                ,p_accounting_mode    => p_accounting_mode
                ,p_valuation_method   => p_valuation_method
                ,p_security_id_int_1  => p_security_id_int_1
                ,p_security_id_int_2  => p_security_id_int_2
                ,p_security_id_int_3  => p_security_id_int_3
                ,p_security_id_char_1 => p_security_id_char_1
                ,p_security_id_char_2 => p_security_id_char_2
                ,p_security_id_char_3 => p_security_id_char_3
                ,p_report_request_id  => p_report_request_id
                ,p_event_name         => p_event_name);

  -- Call to Federal accounting hook
  xla_fv_acct_hooks_pkg.main
               ( p_application_id     => p_application_id
                ,p_ledger_id          => p_ledger_id
                ,p_process_category   => p_process_category
                ,p_end_date           => p_end_date
                ,p_accounting_mode    => p_accounting_mode
                ,p_valuation_method   => p_valuation_method
                ,p_security_id_int_1  => p_security_id_int_1
                ,p_security_id_int_2  => p_security_id_int_2
                ,p_security_id_int_3  => p_security_id_int_3
                ,p_security_id_char_1 => p_security_id_char_1
                ,p_security_id_char_2 => p_security_id_char_2
                ,p_security_id_char_3 => p_security_id_char_3
                ,p_report_request_id  => p_report_request_id
                ,p_event_name         => p_event_name);


-- Call to IGI accounting hook bug6359422

xla_igi_acct_hooks_pkg.main
               ( p_application_id     => p_application_id
                ,p_ledger_id          => p_ledger_id
                ,p_process_category   => p_process_category
                ,p_end_date           => p_end_date
                ,p_accounting_mode    => p_accounting_mode
                ,p_valuation_method   => p_valuation_method
                ,p_security_id_int_1  => p_security_id_int_1
                ,p_security_id_int_2  => p_security_id_int_2
                ,p_security_id_int_3  => p_security_id_int_3
                ,p_security_id_char_1 => p_security_id_char_1
                ,p_security_id_char_2 => p_security_id_char_2
                ,p_security_id_char_3 => p_security_id_char_3
                ,p_report_request_id  => p_report_request_id
                ,p_event_name         => p_event_name);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure handle_accounting_hooks'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

 EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
     RAISE;
   WHEN others THEN
     l_sqlerrm := sqlerrm;

     IF (C_LEVEL_EXCEPTION>= g_log_level) THEN
        trace
           (p_msg      => 'Technical problem : Exception encounterd while raising '||
                          'business event for '||p_event_name||
                          xla_environment_pkg.g_chr_newline||l_sqlerrm
           ,p_level    => C_LEVEL_EXCEPTION
           ,p_module   => l_log_module);
     END IF;

     xla_accounting_err_pkg.build_message
        (p_appli_s_name   => 'XLA'
        ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
        ,p_token_1        => 'APPLICATION_NAME'
        ,p_value_1        => 'SLA'
        ,p_entity_id      => NULL
        ,p_event_id       => NULL);

     print_logfile('Technical problem : Exception encounterd while raising busniess event for '||p_event_name);

     xla_exceptions_pkg.raise_message
        (p_appli_s_name   => 'XLA'
        ,p_msg_name       => 'XLA_COMMON_ERROR'
        ,p_token_1        => 'LOCATION'
        ,p_value_1        => 'xla_accounting_pkg.handle_accounting_hook'
        ,p_token_2        => 'ERROR'
        ,p_value_2        => 'Technical problem : Exception encounterd while raising '||
                             'busniess event for '||p_event_name||
                             xla_environment_pkg.g_chr_newline||l_sqlerrm);
END handle_accounting_hook;

FUNCTION concat_event_classes
      (p_processing_order IN NUMBER)
RETURN VARCHAR2
IS
   l_concat_classes VARCHAR2(5000);
BEGIN
   l_concat_classes := NULL;
   --
   -- changes done for bug 5673550 to put filter based on process category
   --
   IF g_process_category IS NULL THEN
      FOR c IN (SELECT event_class_code FROM xla_evt_class_orders_gt WHERE processing_order = p_processing_order) LOOP
         IF l_concat_classes IS NULL THEN
            l_concat_classes := C_QUOTE;
         ELSE
            l_concat_classes := l_concat_classes || C_COMMA;
         END IF;
         l_concat_classes := l_concat_classes || c.event_class_code;
      END LOOP;
   ELSE
      FOR c IN (SELECT xec.event_class_code
                  FROM xla_evt_class_orders_gt xec
                      ,xla_event_class_attrs xea
                 WHERE xea.application_id        = g_application_id
                   AND xea.event_class_code      = xec.event_class_code
                   AND xea.event_class_group_code = g_process_category
                   AND xec.processing_order = p_processing_order) LOOP
         IF l_concat_classes IS NULL THEN
            l_concat_classes := C_QUOTE;
         ELSE
            l_concat_classes := l_concat_classes || C_COMMA;
         END IF;
         l_concat_classes := l_concat_classes || c.event_class_code;
      END LOOP;
   END IF;

   IF l_concat_classes IS NOT NULL THEN
      l_concat_classes := l_concat_classes || C_QUOTE;
   END IF;

   RETURN l_concat_classes;

END concat_event_classes;

--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--
--
--
--
--
--
--
--
--
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

   g_conc_hold := fnd_profile.value('CONC_HOLD');

END xla_accounting_pkg;

/
