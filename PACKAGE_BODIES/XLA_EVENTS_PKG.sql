--------------------------------------------------------
--  DDL for Package Body XLA_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EVENTS_PKG" AS
-- $Header: xlaevevt.pkb 120.99.12010000.5 2010/02/26 09:12:20 krsankar ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlaevevt.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_events_pkg                                                          |
|                                                                            |
| DESCRIPTION                                                                |
|    This is a XLA private package, which contains all the APIs              |
|    required for processing accounting events.                              |
|                                                                            |
|    The public wrapper called xla_event_pub_pkg, is built based on          |
|    this package.                                                           |
|                                                                            |
|    Note:                                                                   |
|       - the APIs do not execute any COMMIT or ROLLBACK except in           |
|       - period_close procedure.
|       - these APIs are not supposed to return any error when being         |
|         used in production. Internal english message are hard-coded.       |
|                                                                            |
| HISTORY                                                                    |
|    08-Feb-01 G. Qu           Created                                       |
|    10-Mar-01 P. Labrevois    Reviewed                                      |
|    28-Mar-01 P. Labrevois    Review security columns                       |
|    27-Apr-01 P. Labrevois    Review per new datamodel change               |
|    10-Aug-01 P. Labrevois    Added bulk                                    |
|    13-Sep-01 P. Labrevois    Reviewed                                      |
|    08-Feb-02 S. Singhania    Reviewed and performed major changes          |
|    10-Feb-02 S. Singhania    Made changes in APIs to handle 'Transaction   |
|                               Number' (new column added in xla_entities)   |
|    13-Feb-02 S. Singhania    Made changes in APIs to handle 'Event Number' |
|    18-Feb-02 S. Singhania    Procedure 'Initialize' is made public. Minor  |
|                               changes.                                     |
|    04-Mar-02 S. Singhania    Changes in the function "get_id_mapping"      |
|                              Added condition "entity_id = g_entity_id" in  |
|                               all the update APIs.                         |
|                              Removed date validation calls and truncated   |
|                               event date in all the APIs                   |
|    18-Mar-02 S. Singhania    Modified the Bulk APIs to improve performance |
|                               by using a "Temporary table"                 |
|    08-Apr-02 S. Singhania    Removed the not required, redundant APIs      |
|    19-Apr-02 S. Singhania    Added seperate API to update transaction      |
|                               number. modified the APIs based on changes   |
|                               in "event_source_info" & "entity_source_info |
|    08-May-02 S. Singhania    Made changes in the routines to include:      |
|                               NOT NULL ledger_id, NULL valuation_method.   |
|                               legal_entity_id is made NULL in XLA_ENTITIES |
|                               Removed "legal_entity_id" from XLA_EVENTS    |
|                               Bug # 2351677                                |
|    14-May-02 S. Singhania    Modified "event_exists" routine and changed   |
|                               cursors in 'cache_application_setups'.       |
|    31-May-02 S. Singhania    Made changes based on Bug # 2392835. Updated  |
|                               code at all the places to make sure          |
|                               'source_id_date_n' is not used.              |
|                              Changes based on Bug # 2385846. Changes made  |
|                               to support XLA_ENTITY_ID_MAPPINGS column     |
|                               name changes. Modified APIs 'update_event'   |
|                               and 'update_event_status' to update          |
|                               'process_status' with 'event_status'         |
|                              Renamed 'create_entity_event' API to          |
|                               'create_bulk_events'                         |
|    14-Jun-02 S. Singhania    Added the bulk API, 'update_event_status_bulk'|
|                               to update event/entity status in bulk. This  |
|                               API will be called by Accounting Program     |
|    18-Jul-02 S. Singhania    Added curosr in 'cache_application_setup' to  |
|                               cache application from xla_subledgers.       |
|                              Commented 'validate_event_date' routine. Date |
|                               validation is not needed.                    |
|                              Commented 'update_entity_status' and 'evaluate|
|                               _entity_status'. Bug # 2464825. Removed      |
|                               reference to g_entity_status_code.           |
|                              Cleaned up Exception messages.                |
|    23-Jul-02 S. Singhania    Modified code to handle to issue of 'enabled  |
|                               flags'.( see DLD closed issues).             |
|    14-Aug-02 S. Singhania    Changed XLA_ENTITES and XLA_ENTITIES_S to     |
|                               XLA_TRANSACTION_ENTITIES and                 |
|                               XLA_TRANSACTION_ENTITIES_S                   |
|    09-Sep-02 S. Singhania    Made changes to 'cache_entity_info' to handle |
|                               MANUAL events. Bug # 2529997.                |
|    09-Sep-02 S. Singhania    modified 'create_bulk_events' routine (with   |
|                               single array) to handle entities belonging   |
|                               to multiple security contexts. Bug # 2530796 |
|    08-Nov-02 S. Singhania    Included and verified 'get_entity_id' API for |
|                               'document mode' Accounting Program           |
|    21-Feb-03 S. Singhania    Added 'Trace' procedure.                      |
|    10-Apr-03 S. Singhania    Made changes due to change in temporary table |
|                                name (bug # 2897261)                        |
|    12-Jun-03 S. Singhania    Fixed FND Messages (bug # 3001156).           |
|                              Removed commented APIs.                       |
|    10-Jul-03 S. Singhania    Added new APIs for MANUAL events (2899700)    |
|                                - UPDATE_MANUAL_EVENT                       |
|                                - CREATE_MANUAL_EVENT                       |
|                                - DELETE_PROCESSED_EVENT                    |
|                              modified other internal routines to handle the|
|                                the case of MANUAL events.                  |
|                              removed update_event_status_bulk API          |
|                                (accounting program do not use this anymore)|
|    12-Aug-03 S. Singhania    Fixed a typo in GET_ID_MAPPING                |
|    21-Aug-03 S. Singhania    Enhanced the following APIs to fix 2701681    |
|                                - update_event_status                       |
|                                - update_event                              |
|                                - delete_event                              |
|                                - delete_events                             |
|                                - delete_processed_event                    |
|    28-Aug-03 S. Singhania    Modified UPDATE_EVENT to fix 3111204          |
|    04-Sep-03 S. Singhania    Enhanced APIs to support 'Source Application':|
|                                - Added parameter p_source_application_id to|
|                                  CREATE_BULK_EVENTS API                    |
|                                - Added validation for source application in|
|                                  CREATE_EVENT and CREATE_BULK_EVENTS       |
|                                - Modified the insert statment to insert    |
|                                  source application in CREATE_ENTITY_EVENT |
|    05-Sep-03 S. Singhania    To improve performance, the structures to     |
|                                store event_types, event_classes and        |
|                                entity_types are modified. Following were   |
|                                impacted:                                   |
|                                - CACHE_APPLICATION_SETUP                   |
|                                - VALIDATE_EVENT_ENTITY_CODE                |
|                                - VALIDATE_EVNENT_CLASS_CODE                |
|                                - VALIDATE_EVNET_TYPE_CODE.                 |
|    12-Dec-03 S. Singhania    Bug # 3268790.                                |
|                                - Modified cursors in CACHE_ENTITY_INFO not |
|                                  to lock rows in xla_transaction_entities. |
|                                - Routines DELETE_EVENTS and DELETE_EVENT   |
|                                  are modified not to delete entites when   |
|                                  last STANDARD event is deleted for the    |
|                                  entity.                                   |
|    04-Mar-04 W. Shen         Gapless event processing project              |
|    25-Mar-04 W. Shen         add trace                                     |
|    23-Jun-04 W. Shen         New API delete_entity to delete entities      |
|                                from xla_transaction_entities(bug 3316535)  |
|    10-Aug-04 S. Singhania    Added trace messages to help debug the code   |
|    23-OCT-04 W. Shen         New API to delete/update/create event in bulk |
|    09-Nov-04 S. Singhania    Made chnages for valuation method enhancements|
|                                Following routines were modified:           |
|                                - CACHE_APPLICATION_SETUP                   |
|                                - RESET_CACHE                               |
|                                - VALIDATE_CONTEXT                          |
|                                - VALIDATE_LEDGER (New routine added)       |
|    23-OCT-04 W. Shen         bulk delete API, when delete transaction      |
|                               entities, make sure only delete those        |
|                               affected by the batch.                       |
|    1- APR-05 W. Shen         Add transaction_date to the following API:    |
|                               create_event, create_manual_event            |
|                               create_bulk_events(two of them)              |
|                               update_event                                 |
|    20-Apr-05 S. Singhania    Bug 4312353.                                  |
|                              - Modified signature of routines in to reflect|
|                                the change in the way we handle valuation   |
|                                method different from other security columns|
|                              - The major impact is on the following:       |
|                                - SOURCE_INFO_CHANGED                       |
|                                - CACHE_ENTITY_INFO                         |
|                                - CREATE_BULK_EVENTS                        |
|    02-May-05 V. Kumar        Removed function create_bulk_events,          |
|                              Bug # 4323140                                 |
|    22-Jul-05 Swapna Vellani  Modified an insert statement in               |
|                              create_bulk_events procedure Bug #4458604     |
|    2- Aug-05 W. Shen         remove the validation for p_source_app_id     |
|                                bug 4526089                                 |
|    30- Aug-05 W. Shen        when no entity exists, event_exists will      |
|                               return false instead of raising exception    |
|                                bug 4529563                                 |
|    30-Aug-05 S. Singhania    Bug 4519181: Added call to                    |
|                                XLA_SECURITY_PKG.SET_SECURITY_CONTEXT to    |
|                                each public API.                            |
|    07-Oct-09 VGOPISET        Bug:8967771 , few queries on XLA_EVENTS has   |
|                                 no join on APPLICATION_ID                  |
+===========================================================================*/

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring private constants
-------------------------------------------------------------------------------

C_YES                       CONSTANT VARCHAR2(1)  := 'Y'; -- yes flag
C_NO                        CONSTANT VARCHAR2(1)  := 'N'; -- no flag

C_NUM                       CONSTANT NUMBER       := -99;
C_CHAR                      CONSTANT VARCHAR2(30) := ' ';

C_EVENT_DELETE              CONSTANT VARCHAR2(1)  := 'D';
C_EVENT_CREATE              CONSTANT VARCHAR2(1)  := 'C';
C_EVENT_UPDATE              CONSTANT VARCHAR2(1)  := 'U';
C_EVENT_QUERY               CONSTANT VARCHAR2(1)  := 'Q';

C_MANUAL_ENTITY             CONSTANT VARCHAR2(30) := 'MANUAL';
C_MANUAL_EVENT_CONTEXT      CONSTANT VARCHAR2(30) := 'MANUAL';
C_REGULAR_EVENT_CONTEXT     CONSTANT VARCHAR2(30) := 'REGULAR';
-------------------------------------------------------------------------------
-- declaring private pl/sql types
-------------------------------------------------------------------------------
TYPE t_event_type IS RECORD
        (event_class_code               VARCHAR2(30)
        ,enabled_flag                   VARCHAR2(1));

TYPE t_class_type IS RECORD
        (entity_type_code               VARCHAR2(30)
        ,enabled_flag                   VARCHAR2(1));

TYPE t_entity_type IS RECORD
        (id_mapping                     VARCHAR2(8)
        ,enabled_flag                   VARCHAR2(1));


TYPE t_parameter_tbl     IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
TYPE t_number_tbl        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_array_event_type  IS TABLE OF  t_event_type  INDEX BY VARCHAR2(30);
TYPE t_array_event_class IS TABLE OF  t_class_type  INDEX BY VARCHAR2(30);
TYPE t_array_entity_type IS TABLE OF  t_entity_type INDEX BY VARCHAR2(30);
TYPE t_event_status_tbl  IS TABLE OF  xla_events.event_status_code%type
                                      INDEX BY BINARY_INTEGER;
TYPE t_on_hold_flag_tbl  IS TABLE OF  xla_events.on_hold_flag%type
                                      INDEX BY BINARY_INTEGER;
TYPE t_event_number_tbl  IS TABLE OF  xla_events.event_number%type
                                      INDEX BY BINARY_INTEGER;
TYPE t_ledger_status_tbl IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- declaring private variables
-------------------------------------------------------------------------------

g_entity_type_code_tbl      t_array_entity_type;  -- for caching entity_type
g_event_class_code_tbl      t_array_event_class;  -- for caching event_class
g_event_type_code_tbl       t_array_event_type;   -- for caching event_type
g_event_status_code_tbl     t_parameter_tbl;      -- for caching event_status
g_process_status_code_tbl   t_parameter_tbl;      -- for caching internal status
g_id_mapping                VARCHAR2(12);         -- for caching entity mapping

g_ledger_status_tbl         t_ledger_status_tbl;
                              -- for caching the value if event can be created

g_source_info               xla_events_pub_pkg.t_event_source_info;
g_entity_id                 PLS_INTEGER;           -- Entity id
g_entity_type_code          VARCHAR2(30);          -- Entity code
g_valuation_method          VARCHAR2(80);          -- valuation method

g_application_id            PLS_INTEGER;
g_transaction_number        VARCHAR2(240);
g_max_event_number          NUMBER           := 0;
g_context                   VARCHAR2(30);
g_action                    VARCHAR2(1);
g_gapless_flag              VARCHAR2(1);
g_gapless_array_event_status t_event_status_tbl;
g_gapless_event_number t_event_number_tbl;

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

C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_events_pkg';

g_debug_flag        VARCHAR2(1):= NVL(fnd_profile.value('XLA_DEBUG_TRACE'),'N');

--l_log_module          VARCHAR2(240);
g_log_level           NUMBER;
g_log_enabled         BOOLEAN;


-------------------------------------------------------------------------------
-- forward declarion of private procedures and functions
-------------------------------------------------------------------------------

PROCEDURE validate_context
   (p_application_id               IN  INTEGER
   ,p_ledger_id                    IN  INTEGER
   ,p_entity_type_code             IN  VARCHAR2);

PROCEDURE validate_ids
   (p_entity_type_code             IN  VARCHAR2
   ,p_source_id_int_1              IN  INTEGER
   ,p_source_id_int_2              IN  INTEGER
   ,p_source_id_int_3              IN  INTEGER
   ,p_source_id_int_4              IN  INTEGER
   ,p_source_id_char_1             IN  VARCHAR2
   ,p_source_id_char_2             IN  VARCHAR2
   ,p_source_id_char_3             IN  VARCHAR2
   ,p_source_id_char_4             IN  VARCHAR2);

PROCEDURE validate_cached_setup;

PROCEDURE cache_application_setup
   (p_application_id               IN  INTEGER);

PROCEDURE validate_entity_type_code
   (p_entity_type_code             IN  VARCHAR2);

PROCEDURE validate_event_class_code
   (p_entity_type_code             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2);

PROCEDURE validate_event_type_code
   (p_entity_type_code             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2
   ,p_event_type_code              IN  VARCHAR2);

PROCEDURE validate_status_code
    (p_event_status_code            IN  VARCHAR2
    ,p_process_status_code          IN  VARCHAR2);

PROCEDURE validate_params
   (p_source_info                  IN  xla_events_pub_pkg.t_event_source_info
   ,p_event_class_code             IN  VARCHAR2 DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2 DEFAULT NULL
   ,p_event_date                   IN  DATE     DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2 DEFAULT NULL
   ,p_process_status_code          IN  VARCHAR2 DEFAULT NULL);

PROCEDURE validate_ledger
   (p_ledger_id                    IN  NUMBER
   ,p_application_id               IN  NUMBER);

PROCEDURE cache_entity_info
   (p_source_info                  IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  PLS_INTEGER);

PROCEDURE update_entity_trx_number
   (p_transaction_number           IN  VARCHAR2);

PROCEDURE reset_cache;

PROCEDURE set_context
   (p_context                      IN  VARCHAR2);

FUNCTION source_info_changed
   (p_event_source_info1           IN  xla_events_pub_pkg.t_event_source_info
   ,p_event_source_info2           IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method1            IN  VARCHAR2
   ,p_valuation_method2            IN  VARCHAR2)
RETURN BOOLEAN;

FUNCTION get_id_mapping
   (p_entity_type_code             IN  VARCHAR2
   ,p_source_id_code_1             IN  VARCHAR2
   ,p_source_id_code_2             IN  VARCHAR2
   ,p_source_id_code_3             IN  VARCHAR2
   ,p_source_id_code_4             IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION create_entity_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_type_code              IN  VARCHAR2
   ,p_event_date                   IN  DATE
   ,p_event_status_code            IN  VARCHAR2
   ,p_process_status_code          IN  VARCHAR2
   ,p_event_number                 IN  NUMBER
   ,p_transaction_date             IN  DATE
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info
                                       DEFAULT NULL
   ,p_budgetary_control_flag       IN  VARCHAR2)
RETURN INTEGER;

FUNCTION  add_entity_event
   (p_entity_id                    IN  INTEGER
   ,p_application_id               IN  INTEGER
   ,p_ledger_id                    IN  INTEGER
   ,p_legal_entity_id              IN  INTEGER
   ,p_event_type_code              IN  VARCHAR2
   ,p_event_date                   IN  DATE
   ,p_event_status_code            IN  VARCHAR2
   ,p_process_status_code          IN  VARCHAR2
   ,p_event_number                 IN  NUMBER
   ,p_transaction_date             IN  DATE
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info
                                       DEFAULT NULL
   ,p_budgetary_control_flag       IN  VARCHAR2)
RETURN INTEGER;

PROCEDURE delete_je;

FUNCTION validate_id_where_clause return VARCHAR2;
FUNCTION join_id_where_clause return VARCHAR2;

FUNCTION get_application_name
   (p_application_id            IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_ledger_name
   (p_ledger_id            IN NUMBER)
RETURN VARCHAR2;


--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================

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
         (p_location   => 'xla_events_pkg.trace');
END trace;

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
-- Following are the routines on which "single event/entity" public APIs
-- are based.
--
--    1.    create_event
--    2.    create_manual_event
--    3.    update_event_status (for multiple events for an entity)
--    4.    update_event        (update multiple attributes for an event)
--    5.    update_manual_event (update multiple attributes for an event)
--    6.    delete_event        (for a single event)
--    7.    delete_events       (for multiple events for an entity)
--    8.    purge_entity
--    9.    get_event_info      (for an event)
--   10.    get_event_status    (for an event)
--   11.    event_exists        (for an entity)
--   12.    update_transaction_number
--   13.    get_entity_id
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

--=============================================================================
--
-- For MANUAL events this API cannot be called.
--
--=============================================================================

FUNCTION create_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_type_code              IN  VARCHAR2
   ,p_event_date                   IN  DATE
   ,p_event_status_code            IN  VARCHAR2
   ,p_event_number                 IN  INTEGER          DEFAULT NULL
   ,p_transaction_date             IN  DATE        DEFAULT NULL
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info
                                       DEFAULT NULL
   ,p_budgetary_control_flag       IN  VARCHAR2)
RETURN INTEGER IS
l_event_date                  DATE;
L_CONSTANT        CONSTANT    VARCHAR2(30) := '##UNDEFINED##'; --chr(12);

/*
CURSOR csr_xla_applications IS
   SELECT application_id
   FROM   xla_subledgers
   WHERE  application_id = p_event_source_info.source_application_id;
*/
l_log_module                VARCHAR2(240);
l_return_id INTEGER;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_event';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure create_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'p_event_type_code = '||p_event_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'p_event_date = '||p_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'p_event_status_code = '||p_event_status_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'p_event_number = '||p_event_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'budgetary_control_flag = '||p_budgetary_control_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  end if;

   SAVEPOINT before_event_creation;
   g_action := C_EVENT_CREATE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- check to see the API is not called for manual events
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'For MANUAL events this API cannot be called'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_array_event_info (fn)');
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   IF p_event_type_code IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Event Type Code has an invalid value. It cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.create_event');
   END IF;
   IF p_event_date IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Event Date has an invalid value. It cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.create_event');
   END IF;
   IF p_event_status_code IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Event Status Code has an invalid value. It cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.create_event');
   END IF;

   ----------------------------------------------------------------------------
   -- truncate date
   ----------------------------------------------------------------------------
   l_event_date := TRUNC(p_event_date);

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info             => p_event_source_info
      ,p_event_type_code         => p_event_type_code
      ,p_event_status_code       => p_event_status_code
      ,p_process_status_code     => C_INTERNAL_UNPROCESSED);

   ----------------------------------------------------------------------------
   -- Get document PK.
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => p_valuation_method
      ,p_event_id         => NULL);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
         (p_msg      => 'gapless_flag:'||g_gapless_flag
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_number:'||to_char(p_event_number)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'g_entity_id:'||to_char(g_entity_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;

   IF (g_gapless_flag = 'Y'
       and (p_event_number is null or p_event_number<1)) THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'The developer has to give the event number greater than 0 when create new event for gapless processing.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.create_event');
   END IF;
   ----------------------------------------------------------------------------
   -- If the PK is NULL, create an entity as well as the event. Otherwise,
   -- add a new event to the entity.
   ----------------------------------------------------------------------------
   IF g_entity_id IS NULL THEN
      l_return_id:=create_entity_event
               (p_event_source_info      => p_event_source_info
               ,p_valuation_method       => p_valuation_method
               ,p_event_type_code        => p_event_type_code
               ,p_event_date             => l_event_date
               ,p_event_status_code      => p_event_status_code
               ,p_process_status_code    => C_INTERNAL_UNPROCESSED
               ,p_event_number           => p_event_number
               ,p_transaction_date       => p_transaction_date
               ,p_reference_info         => p_reference_info
               ,p_budgetary_control_flag => p_budgetary_control_flag);
   ELSIF NVL(g_transaction_number,L_CONSTANT) <>
             NVL(p_event_source_info.transaction_number,L_CONSTANT) THEN
      update_entity_trx_number
         (p_transaction_number       => p_event_source_info.transaction_number);

      l_return_id:=add_entity_event
               (p_entity_id              => g_entity_id
               ,p_application_id         => p_event_source_info.application_id
               ,p_ledger_id              => p_event_source_info.ledger_id
               ,p_legal_entity_id        => p_event_source_info.legal_entity_id
               ,p_event_type_code        => p_event_type_code
               ,p_event_date             => l_event_date
               ,p_event_status_code      => p_event_status_code
               ,p_process_status_code    => C_INTERNAL_UNPROCESSED
               ,p_event_number           => p_event_number
               ,p_transaction_date       => p_transaction_date
               ,p_reference_info         => p_reference_info
               ,p_budgetary_control_flag => p_budgetary_control_flag);
   ELSE
      l_return_id:=add_entity_event
               (p_entity_id              => g_entity_id
               ,p_application_id         => p_event_source_info.application_id
               ,p_ledger_id              => p_event_source_info.ledger_id
               ,p_legal_entity_id        => p_event_source_info.legal_entity_id
               ,p_event_type_code        => p_event_type_code
               ,p_event_date             => l_event_date
               ,p_event_status_code      => p_event_status_code
               ,p_process_status_code    => C_INTERNAL_UNPROCESSED
               ,p_event_number           => p_event_number
               ,p_transaction_date       => p_transaction_date
               ,p_reference_info         => p_reference_info
               ,p_budgetary_control_flag => p_budgetary_control_flag);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'end of procedure create_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
      trace
         (p_msg      => 'return value is:'||to_char(l_return_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;
   RETURN l_return_id;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_event_creation;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_event_creation;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.create_event (fn)');
END create_event;


--=============================================================================
--
-- This API is specific for MANUAL events. Bug # 2899700.
--
--=============================================================================

FUNCTION create_manual_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_event_type_code              IN  VARCHAR2
   ,p_event_date                   IN  DATE
   ,p_event_status_code            IN  VARCHAR2
   ,p_process_status_code          IN  VARCHAR2
   ,p_event_number                 IN  INTEGER          DEFAULT NULL
   ,p_transaction_date             IN  DATE        DEFAULT NULL
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info DEFAULT NULL
   ,p_budgetary_control_flag       IN  VARCHAR2)
RETURN INTEGER IS
l_event_date                  DATE;
L_CONSTANT        CONSTANT    VARCHAR2(30) := '##UNDEFINED##'; --chr(12);
l_log_module                VARCHAR2(240);
l_return_id INTEGER;
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_manual_event';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure create_manual_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_type_code = '||p_event_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_date = '||p_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_status_code = '||p_event_status_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_process_status_code = '||p_process_status_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_number = '||p_event_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_budgetary_control_flag = '||p_budgetary_control_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   SAVEPOINT before_event_creation;
   g_action := C_EVENT_CREATE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- check to see the API is not called for regular events
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      g_context := C_MANUAL_EVENT_CONTEXT;
   ELSE
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'For REGULAR events this API cannot be called'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_array_event_info (fn)');
   END IF;

   ----------------------------------------------------------------------------
   -- perform specific validations for 'creating events'
   ----------------------------------------------------------------------------
   IF p_event_type_code IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Event Type Code has an invalid value. It cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.create_manual_event');
   END IF;
   IF p_event_date IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Event Date cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.create_manual_event');
   END IF;
   IF p_event_status_code IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Event Status Code cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.create_manual_event');
   END IF;
   IF p_process_status_code IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Process Status Code cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.create_manual_event');
   END IF;

   ----------------------------------------------------------------------------
   -- truncate date
   ----------------------------------------------------------------------------
   l_event_date := TRUNC(p_event_date);

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info             => p_event_source_info
      ,p_event_type_code         => p_event_type_code
      ,p_event_status_code       => p_event_status_code
      ,p_process_status_code     => p_process_status_code);

   ----------------------------------------------------------------------------
   -- Get document PK.
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => NULL
      ,p_event_id         => NULL);

   ----------------------------------------------------------------------------
   -- If the PK is NULL, create an entity as well as the event. Otherwise,
   -- add a new event to the entity.
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF g_entity_id IS NULL THEN
      l_return_id:=create_entity_event
               (p_event_source_info      => p_event_source_info
               ,p_valuation_method        => NULL
               ,p_event_type_code        => p_event_type_code
               ,p_event_date             => l_event_date
               ,p_event_status_code      => p_event_status_code
               ,p_process_status_code    => p_process_status_code
               ,p_event_number           => p_event_number
               ,p_transaction_date       => p_transaction_date
               ,p_reference_info         => p_reference_info
               ,p_budgetary_control_flag => p_budgetary_control_flag);
   ELSIF NVL(g_transaction_number,L_CONSTANT) <>
             NVL(p_event_source_info.transaction_number,L_CONSTANT) THEN
      update_entity_trx_number
         (p_transaction_number       => p_event_source_info.transaction_number);

      l_return_id:=add_entity_event
               (p_entity_id              => g_entity_id
               ,p_application_id         => p_event_source_info.application_id
               ,p_ledger_id              => p_event_source_info.ledger_id
               ,p_legal_entity_id        => p_event_source_info.legal_entity_id
               ,p_event_type_code        => p_event_type_code
               ,p_event_date             => l_event_date
               ,p_event_status_code      => p_event_status_code
               ,p_process_status_code    => p_process_status_code
               ,p_event_number           => p_event_number
               ,p_transaction_date       => p_transaction_date
               ,p_reference_info         => p_reference_info
               ,p_budgetary_control_flag => p_budgetary_control_flag);
   ELSE
      l_return_id:=add_entity_event
               (p_entity_id              => g_entity_id
               ,p_application_id         => p_event_source_info.application_id
               ,p_ledger_id              => p_event_source_info.ledger_id
               ,p_legal_entity_id        => p_event_source_info.legal_entity_id
               ,p_event_type_code        => p_event_type_code
               ,p_event_date             => l_event_date
               ,p_event_status_code      => p_event_status_code
               ,p_process_status_code    => p_process_status_code
               ,p_event_number           => p_event_number
               ,p_transaction_date       => p_transaction_date
               ,p_reference_info         => p_reference_info
               ,p_budgetary_control_flag => p_budgetary_control_flag);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'end of procedure create_manual_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
      trace
         (p_msg      => 'return value is:'||to_char(l_return_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;
   RETURN l_return_id;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_event_creation;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_event_creation;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.create_manual_event (fn)');
END create_manual_event;



--=============================================================================
--
-- For MANUAL events this API cannot be called.
--
--=============================================================================

PROCEDURE update_event_status
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2   DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2   DEFAULT NULL
   ,p_event_date                   IN  DATE       DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2) IS
l_event_date              DATE;
l_array_events            t_number_tbl;
l_array_event_status      t_event_status_tbl;
l_array_on_hold_flag      t_on_hold_flag_tbl;
l_temp_event_number       xla_events.event_number%type;
l_array_event_number      t_event_number_tbl;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_event_status';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure update_event_status'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_type_code = '||p_event_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_date = '||p_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_status_code = '||p_event_status_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);

  END IF;

   SAVEPOINT before_event_update;
   g_action := C_EVENT_UPDATE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- check to see the API is not called for manual events
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'For MANUAL events this API cannot be called'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_array_event_info (fn)');
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   ----------------------------------------------------------------------------
   -- perform validations specific to 'updating event's status'
   ----------------------------------------------------------------------------
   IF p_event_status_code IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Event Status Code cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_event_status');
   END IF;

   ----------------------------------------------------------------------------
   -- truncate date
   ----------------------------------------------------------------------------
   l_event_date := TRUNC(p_event_date);

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info          => p_event_source_info
      ,p_event_class_code     => p_event_class_code
      ,p_event_type_code      => p_event_type_code
      ,p_event_status_code    => p_event_status_code
      ,p_process_status_code  => C_INTERNAL_UNPROCESSED);

   ----------------------------------------------------------------------------
   -- Get document PK
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => p_valuation_method
      ,p_event_id         => NULL);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'gapless_flag = '||g_gapless_flag
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
      trace
         (p_msg      => 'g_entity_id = '||to_char(g_entity_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Check entity existency
   ----------------------------------------------------------------------------
   IF  g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_event_status');
   END IF;

   ----------------------------------------------------------------------------
   -- Fetching event ids for the events that are going to be updated
   ----------------------------------------------------------------------------
   if(g_gapless_flag='N') then
     SELECT event_id     BULK COLLECT
       INTO l_array_events
       FROM xla_events
      WHERE event_status_code    NOT IN (xla_events_pub_pkg.C_EVENT_PROCESSED,
                                         xla_events_pub_pkg.C_EVENT_NOACTION) -- Bug 9197871
        AND event_date           = NVL(l_event_date, event_date)
        AND event_type_code      = NVL(p_event_type_code, event_type_code)
        AND entity_id            = g_entity_id
	AND application_id       = g_application_id -- 8967771
        AND event_type_code  IN
               (SELECT event_type_code
                 FROM   xla_event_types_b
                 WHERE  application_id      = g_application_id
                   AND  entity_code         = g_entity_type_code
                   AND  event_class_code    = NVL(p_event_class_code,
                                                  event_class_code));
   else
     SELECT event_id,
            event_status_code,
            on_hold_flag,
            event_number     BULK COLLECT
       INTO l_array_events,
            l_array_event_status,
            l_array_on_hold_flag,
            l_array_event_number
       FROM xla_events
      WHERE event_status_code    NOT IN (xla_events_pub_pkg.C_EVENT_PROCESSED,
                                         xla_events_pub_pkg.C_EVENT_NOACTION)  -- Bug 9197871
        AND event_date           = NVL(l_event_date, event_date)
        AND event_type_code      = NVL(p_event_type_code, event_type_code)
        AND entity_id            = g_entity_id
	AND application_id       = g_application_id -- 8967771
        AND event_type_code  IN
               (SELECT event_type_code
                 FROM   xla_event_types_b
                 WHERE  application_id      = g_application_id
                   AND  entity_code         = g_entity_type_code
                   AND  event_class_code    = NVL(p_event_class_code,
                                                  event_class_code))
     Order by event_number;
   end if;
   ----------------------------------------------------------------------------
   -- Call routine to delete errors/JEs related to the event bug # 2701681
   ----------------------------------------------------------------------------

   FOR i IN 1..l_array_events.COUNT LOOP
      xla_journal_entries_pkg.delete_journal_entries
         (p_event_id                  => l_array_events(i)
         ,p_application_id            => g_application_id);
   END LOOP;

   ----------------------------------------------------------------------------
   -- Actual status update
   ----------------------------------------------------------------------------
   FORAll i IN 1..l_array_events.COUNT
      UPDATE xla_events
         SET event_status_code      = p_event_status_code
            ,process_status_code    = C_INTERNAL_UNPROCESSED
            ,last_update_date       = sysdate
            ,last_updated_by        = xla_environment_pkg.g_usr_id
            ,last_update_login      = xla_environment_pkg.g_login_id
            ,program_update_date    = sysdate
            ,program_application_id = xla_environment_pkg.g_prog_appl_id
            ,program_id             = xla_environment_pkg.g_prog_id
            ,request_id             = xla_environment_pkg.g_Req_Id
         WHERE event_id             = l_array_events(i)
	 AND   application_id       = g_application_id  -- 8967771
	 ;
   if(g_gapless_flag='Y') then

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_event_status_code:'||p_event_status_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

     if(p_event_status_code='I') then
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
               (p_msg      => 'l_array_event_status(1):'||
                              l_array_event_status(1)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
          trace
               (p_msg      => ' l_array_on_hold_flag(1):'||
                              l_array_on_hold_flag(1)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
        end if;
        if(l_array_event_status(1)<>'I' and l_array_on_hold_flag(1)='N') then
            update xla_events
               set on_hold_flag='Y'
             where entity_id=g_entity_id
                   and event_number >l_array_event_number(1)
                   and on_hold_flag='N'
		   AND application_id       = g_application_id -- 8967771
            ;
        end if;
     else
       FOR i IN 1..l_array_events.COUNT loop
         if(l_array_on_hold_flag(i)='Y') then
           exit;
         elsif (l_array_event_status(i)='I') then
         -- a gap is filled
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
                  (p_msg      => 'l_array_event_status(i) is I, i is:'||
                                 to_char(i)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   =>l_log_module);
             trace
                  (p_msg      => ' l_array_event_number(i):'||
                                 to_char(l_array_event_number(i))
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   =>l_log_module);
           end if;

           SELECT event_status_code,  event_number     BULK COLLECT
             INTO g_gapless_array_event_status, g_gapless_event_number
             FROM xla_events
            Where entity_id            = g_entity_id
                  and event_number>l_array_event_number(i)
		  AND application_id       = g_application_id -- 8967771
            Order by event_number;

           l_temp_event_number:=l_array_event_number(i)+1;
           For j in 1..g_gapless_event_number.COUNT loop
             if(g_gapless_event_number(j)=l_temp_event_number
                      and g_gapless_array_event_status(j)<>'I') then
               l_temp_event_number:=l_temp_event_number+1;
             else
               exit;
             end if;
           end loop;
           --l_temp_event_number is the next gap
           -- update the on_hold_flag of event between l_array_event_number(i)
           -- and --l_temp_event_number+1
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
                  (p_msg      => 'l_temp_event_number:'||
                                 to_char(l_temp_event_number)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   =>l_log_module);
           end if;

           update xla_events
              set on_hold_flag='N'
            where entity_id=g_entity_id
                  and event_number >l_array_event_number(i)
                  and event_number <l_temp_event_number+1
		  AND application_id       = g_application_id -- 8967771
		  ;
           exit;
         end if;
       end loop;
     end if;
   end if;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure update_event_status'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  end if;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_event_update;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_event_update;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.update_event_status');
END update_event_status;


--=============================================================================
--
--  For MANUAL events this API cannot be called.
--
--=============================================================================

PROCEDURE update_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  INTEGER
   ,p_event_type_code              IN  VARCHAR2   DEFAULT NULL
   ,p_event_date                   IN  DATE       DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2   DEFAULT NULL
   ,p_transaction_date             IN  DATE       DEFAULT NULL
   ,p_event_number                 IN  INTEGER    DEFAULT NULL
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info
                                       DEFAULT NULL
   ,p_overwrite_event_num          IN  VARCHAR2   DEFAULT 'N'
   ,p_overwrite_ref_info           IN  VARCHAR2   DEFAULT 'N') IS
l_event_date             DATE;
l_process_status_code    VARCHAR2(1);
l_old_event_status_code      xla_events.event_status_code%TYPE;
l_old_on_hold_flag           xla_events.on_hold_flag%TYPE;
l_old_event_number           xla_events.event_number%TYPE;
l_event_status_code      xla_events.event_status_code%TYPE;
l_on_hold_flag           xla_events.on_hold_flag%TYPE:='Y';
l_temp_event_number      xla_events.event_number%type;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_event';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure update_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_type_code = '||p_event_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_date = '||p_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_status_code = '||p_event_status_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_number = '||p_event_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_overwrite_event_num = '||p_overwrite_event_num
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_overwrite_ref_info = '||p_overwrite_ref_info
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   SAVEPOINT before_event_update;
   g_action := C_EVENT_UPDATE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- check to see the API is not called for manual events
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'For MANUAL events this API cannot be called'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_event');
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   ----------------------------------------------------------------------------
   -- perfrom validations specific to 'updating event'
   ----------------------------------------------------------------------------
   IF  p_event_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Event ID cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_event');
   END IF;


   IF p_event_status_code IS NOT NULL THEN
      l_process_status_code := C_INTERNAL_UNPROCESSED;
   END IF;

   ----------------------------------------------------------------------------
   -- truncate date
   ----------------------------------------------------------------------------
   l_event_date := TRUNC(p_event_date);

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info          => p_event_source_info
      ,p_event_type_code      => p_event_type_code
      ,p_event_status_code    => p_event_status_code
      ,p_process_status_code  => l_process_status_code);

   ----------------------------------------------------------------------------
   -- Get document PK
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => p_valuation_method
      ,p_event_id         => p_event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'gapless_flag = '||g_gapless_flag
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
      trace
         (p_msg      => 'g_entity_id = '||to_char(g_entity_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
      trace
         (p_msg      => 'p_overwrite_event_num:'||p_overwrite_event_num
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
      trace
         (p_msg      => 'p_event_number:'||to_char(p_event_number)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Check entity existency
   ----------------------------------------------------------------------------
   IF g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_event');
   END IF;

   if(g_gapless_flag='Y' and
             (p_overwrite_event_num=C_YES and
                            (p_event_number is null or p_event_number<1))) then
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'The developer has to give the event number when change event number for gapless processing.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_event');

   end if;
   ----------------------------------------------------------------------------
   -- Following statement make sure that when event type and/or event date
   -- is updated, it puts the internal status back to 'Unporcessed' which is
   -- used (in the following statement) to call delete journal entries.
   -- bug # 3111204
   -- For this the event_status_code is left untouched becuase that status
   -- could have 'U/I/N' values and we do not want to change that status unless
   -- it comes from the input.
   ----------------------------------------------------------------------------
   IF p_event_type_code IS NOT NULL OR p_event_date IS NOT NULL THEN
      l_process_status_code := C_INTERNAL_UNPROCESSED;
   END IF;

   ----------------------------------------------------------------------------
   -- Call routine to delete errors/JEs related to the event bug # 2701681
   ----------------------------------------------------------------------------
   IF l_process_status_code = C_INTERNAL_UNPROCESSED THEN
      xla_journal_entries_pkg.delete_journal_entries
         (p_event_id                  => p_event_id
         ,p_application_id            => g_application_id);
   END IF;

   if(g_gapless_flag='Y' and (p_overwrite_event_num=C_YES
                               or p_event_status_code is not null)) then
     -- the on-hold-flag will be affected
     begin
       select event_status_code, on_hold_flag, event_number
         into l_old_event_status_code, l_old_on_hold_flag, l_old_event_number
         from xla_events
        WHERE event_id             = p_event_id
              AND entity_id            = g_entity_id
              AND event_status_code    <> xla_events_pub_pkg.C_EVENT_PROCESSED
	      AND application_id       = g_application_id -- 8967771
	      ;
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
              (p_msg      => 'l_old_event_status_code:'||l_old_event_status_code
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   =>l_log_module);
         trace
              (p_msg      => 'l_old_event_number:'||to_char(l_old_event_number)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   =>l_log_module);
       END IF;


     Exception
       WHEN OTHERS THEN
         xla_exceptions_pkg.raise_message
           (p_appli_s_name   => 'XLA'
           ,p_msg_name       => 'XLA_COMMON_ERROR'
           ,p_token_1        => 'ERROR'
           ,p_value_1        =>
           'Unable to perform UPDATE on the event. The event ('||p_event_id ||
                              ') is either invalid or has been final accounted.'
           ,p_token_2        => 'LOCATION'
           ,p_value_2        => 'xla_events_pkg.update_event');
     END;
   END IF;
   ----------------------------------------------------------------------------
   -- Actual update
   ----------------------------------------------------------------------------
   UPDATE xla_events
      SET event_type_code       = NVL(p_event_type_code  , event_type_code)
         ,event_date            = NVL(l_event_date       , event_date)
         ,transaction_date      = NVL(p_transaction_date , transaction_date)
         ,event_status_code     = NVL(p_event_status_code, event_status_code)
         ,process_status_code   = NVL(l_process_status_code,process_status_code)
         ,event_number          = DECODE(p_overwrite_event_num,C_YES,
                          NVL(p_event_number,g_max_event_number+1),event_number)
         ,reference_num_1       = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_num_1,reference_num_1)
         ,reference_num_2       = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_num_2,reference_num_2)
         ,reference_num_3       = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_num_3,reference_num_3)
         ,reference_num_4       = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_num_4,reference_num_4)
         ,reference_char_1      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_char_1,reference_char_1)
         ,reference_char_2      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_char_2,reference_char_2)
         ,reference_char_3      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_char_3,reference_char_3)
         ,reference_char_4      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_char_4,reference_char_4)
         ,reference_date_1      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_date_1,reference_date_1)
         ,reference_date_2      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_date_2,reference_date_2)
         ,reference_date_3      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_date_3,reference_date_3)
         ,reference_date_4      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_date_4,reference_date_4)
         ,last_update_date      = sysdate
         ,last_updated_by       = xla_environment_pkg.g_usr_id
         ,last_update_login     = xla_environment_pkg.g_login_id
         ,program_update_date   = sysdate
         ,program_application_id= xla_environment_pkg.g_prog_appl_id
         ,program_id            = xla_environment_pkg.g_prog_id
         ,request_id            = xla_environment_pkg.g_Req_Id
      WHERE event_id            = p_event_id
        AND entity_id           = g_entity_id
        AND event_status_code   <> xla_events_pub_pkg.C_EVENT_PROCESSED
	AND application_id       = g_application_id -- 8967771
	;

   IF SQL%ROWCOUNT <> 1    THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Unable to perform UPDATE on the event. The event ('||p_event_id ||
                              ') is either invalid or has been final accounted.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_event');
   END IF;

   if(g_gapless_flag='Y' and
              ((p_overwrite_event_num=C_YES
                       and l_old_event_number <>p_event_number)
                or (p_event_status_code is not null
                       and p_event_status_code<>l_old_event_status_code))) then
   -- there are 5 cases need to be considered:
   -- 1. status_code change to 'I'
   -- 2. status_code change from 'I' to others
   -- 3. event_number changed
   -- 4. 1 and 3
   -- 5. 2 and 3
     if(p_overwrite_event_num=C_YES and l_old_event_number <>p_event_number)then
       if(l_old_event_number<p_event_number) then
         if(l_old_on_hold_flag='N') then
           if(l_old_event_status_code<>'I') then
             update xla_events
                set on_hold_flag='Y'
              where entity_id=g_entity_id
                    and event_status_code<> xla_events_pub_pkg.C_EVENT_PROCESSED
                    and event_number>l_old_event_number
		    AND application_id       = g_application_id -- 8967771
		    ;
           else
             update xla_events
                set on_hold_flag='Y'
              where entity_id=g_entity_id
                    and event_id=p_event_id
		    AND application_id       = g_application_id -- 8967771
		    ;
           end if;
         end if;
       else
         -- in this case, all the event > l_old_event_number must be on hold
         -- already and they will be still on hold event
         -- between l_old_event_number and p_event_number could be affected.
         begin
           select event_status_code, on_hold_flag
             into l_event_status_code, l_on_hold_flag
             from xla_events
            where entity_id=g_entity_id
                  and event_number=p_event_number-1
		  AND application_id       = g_application_id -- 8967771
		  ;
         exception
           when NO_DATA_FOUND then
             if(p_event_number=1) then
               l_on_hold_flag:='N';
               l_event_status_code:='U';
             else
               l_on_hold_flag:='Y';
             end if;
         end;
         if(l_on_hold_flag='N' and l_event_status_code<>'I') then
           if(nvl(p_event_status_code, l_old_event_status_code)='I') then
             update xla_events
                set on_hold_flag='N'
              where event_id=p_event_id
	      AND application_id       = g_application_id -- 8967771
	      ;
           else
             -- update from this event til the next gap, set on_hold_flag to 'N'
             SELECT event_status_code,  event_number     BULK COLLECT
               INTO g_gapless_array_event_status, g_gapless_event_number
               FROM xla_events
              Where entity_id            = g_entity_id
                    and event_number>p_event_number
                    and event_number<l_old_event_number
		    AND application_id       = g_application_id -- 8967771
              Order by event_number;

             l_temp_event_number:=p_event_number+1;
             For j in 1..g_gapless_event_number.COUNT loop
               if(g_gapless_event_number(j)=l_temp_event_number
                        and g_gapless_array_event_status(j)<>'I') then
                 l_temp_event_number:=l_temp_event_number+1;
               else
                 exit;
               end if;
             end loop;
             --l_temp_event_number is the next gap
             -- update the on_hold_flag of event between l_array_event_number(i)
             -- and --l_temp_event_number+1

             update xla_events
                set on_hold_flag='N'
              where entity_id=g_entity_id
                    and event_number >p_event_number-1
                    and event_number <l_temp_event_number+1
		    AND application_id       = g_application_id -- 8967771
		    ;
           end if;
         end if;
       end if;
     else --event number is not updated, but the status changed
       if(p_event_status_code='I' and l_old_on_hold_flag='N') then
       -- new gap
         update xla_events
            set on_hold_flag='Y'
          where entity_id=g_entity_id
                and event_number>l_old_event_number
                and on_hold_flag='N'
		AND application_id       = g_application_id -- 8967771
		;

       elsif(l_old_event_status_code='I' and l_old_on_hold_flag='N') then
       -- old gap eliminated
         SELECT event_status_code,  event_number     BULK COLLECT
           INTO g_gapless_array_event_status, g_gapless_event_number
           FROM xla_events
          Where entity_id            = g_entity_id
                and event_number>l_old_event_number
		AND application_id       = g_application_id -- 8967771
          Order by event_number;

         l_temp_event_number:=l_old_event_number+1;
         For j in 1..g_gapless_event_number.COUNT loop
           if(g_gapless_event_number(j)=l_temp_event_number
                    and g_gapless_array_event_status(j)<>'I') then
             l_temp_event_number:=l_temp_event_number+1;
           else
             exit;
           end if;
         end loop;
         --l_temp_event_number is the next gap
         -- update the on_hold_flag of event between l_array_event_number(i)
         -- and --l_temp_event_number+1

         update xla_events
            set on_hold_flag='N'
          where entity_id=g_entity_id
                and event_number >l_old_event_number
                and event_number <l_temp_event_number+1
		AND application_id       = g_application_id -- 8967771
		;

       end if;
     end if;
   end if;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure update_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_event_update;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_event_update;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.update_event');
END update_event;


--=============================================================================
--
--  This API is specific for MANUAL events. Bug # 2899700.
--
--=============================================================================

PROCEDURE update_manual_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_event_id                     IN  INTEGER
   ,p_event_type_code              IN  VARCHAR2   DEFAULT NULL
   ,p_event_date                   IN  DATE       DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2   DEFAULT NULL
   ,p_process_status_code          IN  VARCHAR2   DEFAULT NULL
   ,p_event_number                 IN  INTEGER    DEFAULT NULL
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info
                                       DEFAULT NULL
   ,p_overwrite_event_num          IN  VARCHAR2   DEFAULT 'N'
   ,p_overwrite_ref_info           IN  VARCHAR2   DEFAULT 'N') IS
l_event_date                DATE;
l_log_module                VARCHAR2(240);
l_rowcount                  NUMBER;
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_manual_event';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure update_manual_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_type_code = '||p_event_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_date = '||p_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_status_code = '||p_event_status_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_process_status_code = '||p_process_status_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_number = '||p_event_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_overwrite_event_num = '||p_overwrite_event_num
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_overwrite_ref_info = '||p_overwrite_ref_info
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   SAVEPOINT before_event_update;
   g_action := C_EVENT_UPDATE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- check to see the API is not called for regular events
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      g_context := C_MANUAL_EVENT_CONTEXT;
   ELSE
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'For REGULAR events this API cannot be called'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_manual_event');
   END IF;

   ----------------------------------------------------------------------------
   -- perfrom validations specific to 'updating event'
   ----------------------------------------------------------------------------
   IF  p_event_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Event ID cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_manual_event');
   END IF;

   ----------------------------------------------------------------------------
   -- validate to make sure that both p_event_status_code and
   -- p_process_status_code should either be NULL or NOT NULL
   ----------------------------------------------------------------------------
   IF (((p_event_status_code IS NOT NULL) AND (p_process_status_code IS NULL))OR
       ((p_event_status_code IS NULL) AND (p_process_status_code IS NOT NULL)))
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Inconsistent values for event statuses: '||
                              'p_event_status_code    = '||p_event_status_code||
                              'p_process_status_code  = '||p_process_status_code
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_manual_event');
   END IF;

   ----------------------------------------------------------------------------
   -- truncate date
   ----------------------------------------------------------------------------
   l_event_date := TRUNC(p_event_date);

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info          => p_event_source_info
      ,p_event_type_code      => p_event_type_code
      ,p_event_status_code    => p_event_status_code
      ,p_process_status_code  => p_process_status_code);

   ----------------------------------------------------------------------------
   -- Get document PK
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => NULL
      ,p_event_id         => p_event_id);

   ----------------------------------------------------------------------------
   -- Check entity existency
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF  g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_manual_event');
   END IF;

   ----------------------------------------------------------------------------
   -- Actual status update
   ----------------------------------------------------------------------------
   UPDATE xla_events
      SET event_type_code       = NVL(p_event_type_code  , event_type_code)
         ,event_date            = NVL(l_event_date       , event_date)
         ,event_status_code     = NVL(p_event_status_code, event_status_code)
         ,process_status_code   = NVL(p_process_status_code,process_status_code)
         ,event_number          = DECODE(p_overwrite_event_num,C_YES,
                          NVL(p_event_number,g_max_event_number+1),event_number)
         ,reference_num_1       = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_num_1,reference_num_1)
         ,reference_num_2       = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_num_2,reference_num_2)
         ,reference_num_3       = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_num_3,reference_num_3)
         ,reference_num_4       = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_num_4,reference_num_4)
         ,reference_char_1      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_char_1,reference_char_1)
         ,reference_char_2      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_char_2,reference_char_2)
         ,reference_char_3      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_char_3,reference_char_3)
         ,reference_char_4      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_char_4,reference_char_4)
         ,reference_date_1      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_date_1,reference_date_1)
         ,reference_date_2      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_date_2,reference_date_2)
         ,reference_date_3      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_date_3,reference_date_3)
         ,reference_date_4      = DECODE(p_overwrite_ref_info,C_YES,
                             p_reference_info.reference_date_4,reference_date_4)
         ,last_update_date      = sysdate
         ,last_updated_by       = xla_environment_pkg.g_usr_id
         ,last_update_login     = xla_environment_pkg.g_login_id
         ,program_update_date   = sysdate
         ,program_application_id= xla_environment_pkg.g_prog_appl_id
         ,program_id            = xla_environment_pkg.g_prog_id
         ,request_id            = xla_environment_pkg.g_Req_Id
      WHERE event_id            = p_event_id
        AND entity_id           = g_entity_id
        AND event_status_code   <> xla_events_pub_pkg.C_EVENT_PROCESSED
	AND application_id       = g_application_id -- 8967771
	;

   l_rowcount :=  SQL%ROWCOUNT;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number for rows updated = '||l_rowcount
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF l_rowcount <> 1    THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Unable to perform UPDATE on the event. The event ('||p_event_id ||
                            ') is invalid'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_manual_event');
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'end of procedure update_manual_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_event_update;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_event_update;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.update_manual_event');
END update_manual_event;


--=============================================================================
--
-- Bug # 2899700. This API can be called for Manual and Standard events.
-- Bug 3268790. commented the statements that delete rows for entites.
--
--=============================================================================

PROCEDURE delete_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  INTEGER) IS
l_on_hold_flag xla_events.on_hold_flag%type;
l_event_status_code xla_events.event_status_code%type;
l_event_number xla_events.event_number%type;
l_log_module                VARCHAR2(240);
l_rowcount                  NUMBER;
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_event';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure delete_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   SAVEPOINT before_event_delete;
   g_action := C_EVENT_DELETE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- Set the right context for calling this API
   -- Changed to fix bug # 2899700
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      g_context := C_MANUAL_EVENT_CONTEXT;
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   ----------------------------------------------------------------------------
   -- perform validations specific to 'deleting event'
   ----------------------------------------------------------------------------
   IF  p_event_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Event ID cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_event');
   END IF;

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info       => p_event_source_info);

   ----------------------------------------------------------------------------
   -- Get document PK
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => p_valuation_method
      ,p_event_id         => p_event_id);

   ----------------------------------------------------------------------------
   -- Check entity existency
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF  g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_event');
   END IF;

   ----------------------------------------------------------------------------
   -- Call routine to delete errors/JEs related to the event bug # 2701681
   ----------------------------------------------------------------------------
   xla_journal_entries_pkg.delete_journal_entries
      (p_event_id                  => p_event_id
      ,p_application_id            => g_application_id);

   if(g_gapless_flag='Y') then
     begin
       select on_hold_flag, event_status_code, event_number
         into l_on_hold_flag, l_event_status_code, l_event_number
         from xla_events
        WHERE event_id  = p_event_id
              AND entity_id = g_entity_id
              AND event_status_code  <> xla_events_pub_pkg.C_EVENT_PROCESSED
	      AND application_id       = g_application_id -- 8967771
	      ;
     exception when others then
       xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Unable to perform DELETE on the event. The event ('|| p_event_id ||
                              ') is either invalid or has been final accounted.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_event');
     end;
   end if;

   ----------------------------------------------------------------------------
   -- Actual Delete of the event
   ----------------------------------------------------------------------------
   DELETE xla_events
    WHERE event_id  = p_event_id
      AND entity_id = g_entity_id
      AND event_status_code  <> xla_events_pub_pkg.C_EVENT_PROCESSED
      AND application_id       = g_application_id -- 8967771
      ;

   l_rowcount := SQL%ROWCOUNT;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number for events deleted = '||l_rowcount
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF l_rowcount <> 1    THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Unable to perform DELETE on the event. The event ('|| p_event_id ||
                              ') is either invalid or has been final accounted.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_event');

   ELSIF g_context = C_MANUAL_EVENT_CONTEXT THEN
      --------------------------------------------------------------------------
      -- this if condition is added to make sure that the entity row is
      -- deleted only for Manula events and not for statndard event.Bug 3268790.
      --------------------------------------------------------------------------
         ----------------------------------------------------------------------
         -- following will delete the row from entities if there is no
         -- event exists for the entity
         ----------------------------------------------------------------------
         DELETE xla_transaction_entities xte
          WHERE xte.entity_id = g_entity_id
            AND xte.application_id = g_application_id
            AND NOT EXISTS
                       (SELECT '1' FROM xla_events xe
                         WHERE xe.entity_id = xte.entity_id
                           AND xe.application_id = xte.application_id);

      l_rowcount := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_msg      => 'Number for entities deleted = '||l_rowcount
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
      END IF;

   ELSIF (g_gapless_flag='Y' and l_on_hold_flag='N'
                             and l_event_status_code<>'I') then
        update xla_events
           set on_hold_flag='Y'
         where entity_id=g_entity_id
               and event_number>l_event_number
	       AND application_id       = g_application_id -- 8967771
	       ;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'end of procedure delete_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_event_delete;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_event_delete;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.delete_event');
END delete_event;


--=============================================================================
--
-- This API is specific for MANUAL events. (delebrate restriction)
-- Added this API to fix bug # 2899700.
--
--=============================================================================

PROCEDURE delete_processed_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_event_id                     IN  INTEGER) IS
l_log_module                VARCHAR2(240);
l_rowcount                  NUMBER;
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_processed_event';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure delete_processed_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   trace('> xla_events_pkg.delete_processed_event'                  , 20);

   SAVEPOINT before_event_delete;
   g_action := C_EVENT_DELETE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- Set the right context for calling this API
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      g_context := C_MANUAL_EVENT_CONTEXT;
   ELSE
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'For REGULAR events this API cannot be called'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_processed_event');
   END IF;

   ----------------------------------------------------------------------------
   -- perform validations specific to 'deleting event'
   ----------------------------------------------------------------------------
   IF  p_event_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Event ID cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_processed_event');
   END IF;

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info       => p_event_source_info);

   ----------------------------------------------------------------------------
   -- Get document PK
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => NULL
      ,p_event_id         => p_event_id);

   ----------------------------------------------------------------------------
   -- Check entity existency
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF  g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_processed_event');
   END IF;

   ----------------------------------------------------------------------------
   -- Call routine to delete errors/JEs related to the event bug # 2701681
   ----------------------------------------------------------------------------
   xla_journal_entries_pkg.delete_journal_entries
      (p_event_id                  => p_event_id
      ,p_application_id            => g_application_id);

   ----------------------------------------------------------------------------
   -- Actual Delete of the event
   ----------------------------------------------------------------------------
   DELETE xla_events
    WHERE event_id  = p_event_id
      AND entity_id = g_entity_id
      AND event_status_code  = xla_events_pub_pkg.C_EVENT_PROCESSED
      AND application_id       = g_application_id -- 8967771
      ;

   l_rowcount := SQL%ROWCOUNT;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number for events deleted = '||l_rowcount
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF l_rowcount <> 1    THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Unable to perform DELETE on the event. The event ('|| p_event_id ||
                         ') is either invalid or has not been final accounted.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_processed_event');
   ELSE
      -------------------------------------------------------------------------
      -- following will delete the row from entities if there is no
      -- event exists for the entity
      -------------------------------------------------------------------------
      DELETE xla_transaction_entities xte
       WHERE xte.entity_id = g_entity_id
         AND xte.application_id = g_application_id
         AND NOT EXISTS
                (SELECT '1' FROM xla_events xe
                  WHERE xe.entity_id = xte.entity_id
                    AND xe.application_id = xte.application_id);

      l_rowcount := SQL%ROWCOUNT;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_msg      => 'Number for entities deleted = '||l_rowcount
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
      END IF;
   END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure delete_processed_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_event_delete;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_event_delete;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.delete_processed_event');
END delete_processed_event;


--=============================================================================
--
-- For MANUAL events this API cannot be called.
-- Bug 3268790. commented the statements that delete rows for entites.
--
--=============================================================================

FUNCTION delete_events
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2 DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2 DEFAULT NULL
   ,p_event_date                   IN  DATE     DEFAULT NULL)
RETURN INTEGER IS
l_event_deleted                 INTEGER;
l_event_date                    DATE;
l_array_events                  t_number_tbl;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_events';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure delete_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_type_code = '||p_event_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_date = '||p_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   SAVEPOINT before_event_delete;
   g_action := C_EVENT_DELETE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- check to see the API is not called for manual events
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'For MANUAL events this API cannot be called'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_events');
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   ----------------------------------------------------------------------------
   -- truncate date
   ----------------------------------------------------------------------------
   l_event_date := TRUNC(p_event_date);

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info       => p_event_source_info
      ,p_event_class_code  => p_event_class_code
      ,p_event_type_code   => p_event_type_code);

   ----------------------------------------------------------------------------
   -- Get document PK
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => p_valuation_method
      ,p_event_id         => NULL);

   ----------------------------------------------------------------------------
   -- Check entity existency
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF  g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_events (fn)');
   END IF;

   ----------------------------------------------------------------------------
   -- Fetching event ids for the events that are going to be deleted
   ----------------------------------------------------------------------------
   begin
     if(g_gapless_flag='N') then
       SELECT event_id     BULK COLLECT
         INTO l_array_events
         FROM xla_events
       WHERE  event_date          = NVL(l_event_date, event_date)
         AND  event_status_code   <> xla_events_pub_pkg.C_EVENT_PROCESSED
         AND  event_type_code     = NVL(p_event_type_code, event_type_code)
         AND  entity_id           = g_entity_id
	 AND  application_id       = g_application_id -- 8967771
         AND  event_type_code IN
                (SELECT event_type_code
                 FROM   xla_event_types_b
                 WHERE  application_id      = g_application_id
                   AND  entity_code         = g_entity_type_code
                   AND  event_class_code    = NVL(p_event_class_code,
                                                  event_class_code));
     else
       SELECT event_id, event_number     BULK COLLECT
         INTO l_array_events, g_gapless_event_number
         FROM xla_events
       WHERE  event_date          = NVL(l_event_date, event_date)
         AND  event_status_code   <> xla_events_pub_pkg.C_EVENT_PROCESSED
         AND  event_type_code     = NVL(p_event_type_code, event_type_code)
         AND  entity_id           = g_entity_id
	 AND  application_id       = g_application_id -- 8967771
         AND  event_type_code IN
                (SELECT event_type_code
                 FROM   xla_event_types_b
                 WHERE  application_id      = g_application_id
                   AND  entity_code         = g_entity_type_code
                   AND  event_class_code    = NVL(p_event_class_code,
                                                  event_class_code))
       order by event_number;
     end if;
   exception when no_data_found then
     null;
   end;

   ----------------------------------------------------------------------------
   -- Call routine to delete errors/JEs related to the event bug # 2701681
   ----------------------------------------------------------------------------
   FOR i IN 1..l_array_events.COUNT LOOP
      xla_journal_entries_pkg.delete_journal_entries
         (p_event_id                  => l_array_events(i)
         ,p_application_id            => g_application_id);
   END LOOP;

   ----------------------------------------------------------------------------
   -- Actual Delete
   ----------------------------------------------------------------------------
   FORAll i IN 1..l_array_events.COUNT
      DELETE xla_events
         WHERE event_id             = l_array_events(i)
	 AND   application_id       = g_application_id -- 8967771
	 ;

   l_event_deleted := SQL%ROWCOUNT;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of events deleted = '||l_event_deleted
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
      trace
         (p_msg      => 'g_gapless_flag = '||g_gapless_flag
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   if(g_gapless_flag='Y' and l_event_deleted>0 ) then
     update xla_events
        set on_hold_flag='Y'
      where event_number>g_gapless_event_number(1)
            and on_hold_flag='N'
            and entity_id=g_entity_id
	    AND application_id       = g_application_id -- 8967771
	    ;
   end if;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure delete_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'return value:'||to_char(l_event_deleted)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   RETURN l_event_deleted;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_event_delete;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_event_delete;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.delete_events (fn)');
END delete_events;


--============================================================================
--
-- This function is used to delete one entity. It will:
--    - validate input parameters
--    - check if there is still event associated with the entity
--    - if yes, return 1 without deletion
--    - else delete entity, return 0
--
--============================================================================

FUNCTION delete_entity
   (p_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method        IN  VARCHAR2)
RETURN INTEGER IS

l_log_module                VARCHAR2(240);
l_temp                      NUMBER;
l_entity_id                 XLA_TRANSACTION_ENTITIES.ENTITY_ID%TYPE;
cursor c_existing_events is
    select 1
      from xla_events
     where entity_id=l_entity_id;
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_entity';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure delete_entity'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||p_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||p_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||p_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||p_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||p_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||p_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||p_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||p_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||p_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||p_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;


  SAVEPOINT before_entity_delete;
   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_source_info.application_id);

  ----------------------------------------------------------------------------
  -- Validate parameters
  ----------------------------------------------------------------------------
  validate_params
     (p_source_info       => p_source_info);

  BEGIN
    SELECT entity_id
      INTO l_entity_id
      FROM xla_transaction_entities a
     WHERE a.application_id                  = p_source_info.application_id
       AND a.ledger_id                       = p_source_info.ledger_id
       AND a.entity_code                     = p_source_info.entity_type_code
       AND NVL(a.source_id_int_1,-99)      =
                     NVL(p_source_info.source_id_int_1,-99)  --	8372505: Relpaced C_NUM with -99, C_CHAR with ' '.
       AND NVL(a.source_id_int_2,-99)      =
                     NVL(p_source_info.source_id_int_2,-99)
       AND NVL(a.source_id_int_3,-99)      =
                     NVL(p_source_info.source_id_int_3,-99)
       AND NVL(a.source_id_int_4,-99)      =
                     NVL(p_source_info.source_id_int_4,-99)
       AND NVL(a.source_id_char_1,' ')    =
                     NVL(p_source_info.source_id_char_1,' ')
       AND NVL(a.source_id_char_2,' ')    =
                     NVL(p_source_info.source_id_char_2,' ')
       AND NVL(a.source_id_char_3,' ')    =
                     NVL(p_source_info.source_id_char_3,' ')
       AND NVL(a.source_id_char_4,' ')    =
                     NVL(p_source_info.source_id_char_4,' ')
       AND NVL(a.valuation_method,C_CHAR)    =
                     NVL(p_valuation_method,C_CHAR)
       AND NVL(a.security_id_int_1,-99)    =
                     NVL(xla_events_pub_pkg.g_security.security_id_int_1,-99)
       AND NVL(a.security_id_int_2,-99)    =
                     NVL(xla_events_pub_pkg.g_security.security_id_int_2,-99)
       AND NVL(a.security_id_int_3,-99)    =
                    NVL(xla_events_pub_pkg.g_security.security_id_int_3,-99)
       AND NVL(a.security_id_char_1,' ')  =
                    NVL(xla_events_pub_pkg.g_security.security_id_char_1,' ')
       AND NVL(a.security_id_char_2,' ')  =
                    NVL(xla_events_pub_pkg.g_security.security_id_char_2,' ')
       AND NVL(a.security_id_char_3,' ')  =
                   NVL(xla_events_pub_pkg.g_security.security_id_char_3,' ');
  EXCEPTION when others then
    xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Unable to perform DELETE on the entity. The entity does not exist'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_entity');
  END;

  OPEN c_existing_events;
  FETCH c_existing_events into l_temp;

  IF c_existing_events%FOUND THEN
  -- there is event existing for the entity, can't delete
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
           (p_msg      => 'There is event existing for the entity, id:'||
                          to_char(l_entity_id)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   =>l_log_module);
    END IF;
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'END of function delete_entity, return 1'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   =>l_log_module);
    END IF;
    CLOSE c_existing_events;
    RETURN 1;
  END IF;
  CLOSE c_existing_events;

  DELETE xla_transaction_entities
   WHERE entity_id = l_entity_id
     AND application_id = p_source_info.application_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of entities deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of function delete_entity, return 0'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;
   RETURN 0;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_entity_delete;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_entity_delete;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.delete_entity');
END delete_entity;

--=============================================================================
--
-- following is not the final code and is not tested as there is no requirement
-- for purge routine, for now.
--
--=============================================================================

PROCEDURE purge_entity
   (p_event_source_info          IN  xla_events_pub_pkg.t_event_source_info) IS
BEGIN
   trace('> xla_events_pkg.delete_entity'                 , 20);

   SAVEPOINT before_entity_delete;
   g_action := C_EVENT_DELETE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   --
   -- Validate parameters
   --
   validate_params
      (p_source_info       => p_event_source_info);

   --
   -- Get document PK
   --
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => NULL
      ,p_event_id         => NULL);

   --
   -- Check entity existency
   --
   IF  g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
 'No event exists for the document represented by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.delete_entity');
   END IF;

   trace('< xla_events_pkg.delete_entity'                 , 20);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_entity_delete;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_entity_delete;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.delete_entity');
END purge_entity;


--=============================================================================
--
--
-- Changed to fix bug # 2899700.
--
--=============================================================================

FUNCTION get_event_info
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  INTEGER)
RETURN xla_events_pub_pkg.t_event_info IS

l_event_info                    xla_events_pub_pkg.t_event_info;
l_log_module                VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_event_info';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure get_event_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- Set the right context for calling this API
   -- Changed to fix bug # 2899700
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      g_context := C_MANUAL_EVENT_CONTEXT;
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   g_action := C_EVENT_QUERY;

   ----------------------------------------------------------------------------
   -- perform validation specific to 'get event information'
   ----------------------------------------------------------------------------
   IF  p_event_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Event ID has an invalid value. It cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_event_info');
   END IF;

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info       => p_event_source_info);

   ----------------------------------------------------------------------------
   -- Get document PK
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => p_valuation_method
      ,p_event_id         => p_event_id);

   ----------------------------------------------------------------------------
   -- Check entity existency
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF  g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_event_info');
   END IF;

   SELECT event_id
         ,event_number
         ,event_type_code
         ,event_date
         ,event_status_code
         ,on_hold_flag
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
         ,reference_date_4
   INTO   l_event_info.event_id
         ,l_event_info.event_number
         ,l_event_info.event_type_code
         ,l_event_info.event_date
         ,l_event_info.event_status_code
         ,l_event_info.on_hold_flag
         ,l_event_info.reference_num_1
         ,l_event_info.reference_num_2
         ,l_event_info.reference_num_3
         ,l_event_info.reference_num_4
         ,l_event_info.reference_char_1
         ,l_event_info.reference_char_2
         ,l_event_info.reference_char_3
         ,l_event_info.reference_char_4
         ,l_event_info.reference_date_1
         ,l_event_info.reference_date_2
         ,l_event_info.reference_date_3
         ,l_event_info.reference_date_4
   FROM   xla_events
   WHERE  event_id            = p_event_id
     AND  entity_id           = g_entity_id
     AND application_id       = g_application_id -- 8967771
     ;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure get_event_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   RETURN (l_event_info);
EXCEPTION
WHEN NO_DATA_FOUND                            THEN
   xla_exceptions_pkg.raise_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_COMMON_ERROR'
      ,p_token_1        => 'ERROR'
      ,p_value_1        => 'The event id '||p_event_id||' does not exist'
      ,p_token_2        => 'LOCATION'
      ,p_value_2        => 'xla_events_pkg.get_event_info');
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.get_event_info (fn)');
END get_event_info;


--=============================================================================
--
--
--
--=============================================================================

FUNCTION get_event_status
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  INTEGER)
RETURN VARCHAR2 IS

l_event_info                 xla_events_pub_pkg.t_event_info;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_event_status';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure get_event_status'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   l_event_info := get_event_info
                      (p_event_source_info   => p_event_source_info
                      ,p_valuation_method    => p_valuation_method
                      ,p_event_id            => p_event_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'return value = '||l_event_info.event_status_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'end of procedure get_event_status'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   RETURN l_event_info.event_status_code;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.get_event_status (fn)');
END get_event_status ;


--=============================================================================
--
--
-- Changed to fix bug # 2899700. (Added parameter p_event_id)
--
--=============================================================================

FUNCTION event_exists
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2     DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2     DEFAULT NULL
   ,p_event_date                   IN  DATE         DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2     DEFAULT NULL
   ,p_event_number                 IN  INTEGER      DEFAULT NULL
   ,p_event_id                     IN  PLS_INTEGER  DEFAULT NULL)
RETURN BOOLEAN IS

l_event_status_code          VARCHAR2(1);
l_event_date                 DATE;

CURSOR c1 IS
   SELECT event_status_code
   FROM   xla_events
   WHERE  event_date          = NVL(l_event_date, event_date)
     AND  event_type_code     = NVL(p_event_type_code, event_type_code)
     AND  event_status_code   = NVL(p_event_status_code, event_status_code)
     AND  event_number        = NVL(p_event_number, event_number)
     AND  event_id            = NVL(p_event_id, event_id)
     AND  entity_id           = g_entity_id
     AND  application_id      = g_application_id -- 8967771
     AND  event_type_code IN (SELECT event_type_code
                              FROM   xla_event_types_b
                              WHERE  application_id   = g_application_id
                                AND  entity_code      = g_entity_type_code
                                AND  event_class_code = NVL(p_event_class_code,
                                                            event_class_code));
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.event_exists';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure event_exists'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_type_code = '||p_event_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_date = '||p_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_status_code = '||p_event_status_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_number = '||p_event_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- Set the right context for calling this API
   -- Changed to fix bug # 2899700
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      IF p_event_id IS NULL THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'For MANUAL events event_id cannot be NULL'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.event_exists');
      END IF;
      g_context := C_MANUAL_EVENT_CONTEXT;
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   g_action := C_EVENT_QUERY;

   ----------------------------------------------------------------------------
   -- truncate date
   ----------------------------------------------------------------------------
   l_event_date := TRUNC(p_event_date);

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
     (p_source_info       => p_event_source_info
     ,p_event_class_code  => p_event_class_code
     ,p_event_type_code   => p_event_type_code);
--     ,p_event_status_code => p_event_status_code);

   ----------------------------------------------------------------------------
   -- Get the entity info, cached in globals
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info      => p_event_source_info
      ,p_valuation_method => p_valuation_method
      ,p_event_id         => p_event_id);

   ----------------------------------------------------------------------------
   -- Check entity existency
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF  g_entity_id IS NULL  THEN

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace
            (p_msg      => 'no entity exist, return value is false'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   =>l_log_module);
         trace
            (p_msg      => 'end of procedure event_exists'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   =>l_log_module);
       END IF;
       RETURN FALSE;
/*
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.event_exists (fn)');
*/
   END IF;

   OPEN c1;

   FETCH c1 INTO  l_event_status_code;

    IF c1%NOTFOUND THEN
       CLOSE c1;

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace
            (p_msg      => 'return value is false'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   =>l_log_module);
         trace
            (p_msg      => 'end of procedure event_exists'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   =>l_log_module);
       END IF;

       RETURN FALSE;
    ELSE
       CLOSE c1;
       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace
            (p_msg      => 'return value is true'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   =>l_log_module);
         trace
            (p_msg      => 'end of procedure event_exists'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   =>l_log_module);
       END IF;
       RETURN TRUE;
    END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;
   RAISE;
WHEN NO_DATA_FOUND THEN
   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;
   RETURN FALSE;
WHEN OTHERS THEN
   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.event_exists (fn)');
END event_exists;


--=============================================================================
--
--
-- Changed to fix bug # 2899700. (Added parameter p_event_id)
--
--=============================================================================

PROCEDURE update_transaction_number
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_transaction_number           IN  VARCHAR2
   ,p_event_id                     IN  PLS_INTEGER  DEFAULT NULL) IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_transaction_number';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure update_transaction_number'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_transaction_number = '||p_transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- Set the right context for calling this API
   -- Changed to fix bug # 2899700
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      IF p_event_id IS NULL THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'For MANUAL events event_id cannot be NULL'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.update_transaction_number');
      END IF;
      g_context := C_MANUAL_EVENT_CONTEXT;
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   g_action := C_EVENT_UPDATE;

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info       => p_event_source_info);

   ----------------------------------------------------------------------------
   -- Get the entity info, cached in globals
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info        => p_event_source_info
      ,p_valuation_method   => p_valuation_method
      ,p_event_id           => p_event_id);

   ----------------------------------------------------------------------------
   -- Check entity existency
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF  g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_transaction_number');
   END IF;

   update_entity_trx_number
      (p_transaction_number          => p_transaction_number);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure update_transaction_number'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.update_transaction_number');
END update_transaction_number;


--=============================================================================
--
--
-- Changed to fix bug # 2899700. (Added parameter p_event_id)
--
--=============================================================================

FUNCTION  get_entity_id
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  PLS_INTEGER  DEFAULT NULL)
RETURN INTEGER IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_entity_id';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure get_entity_id'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   ----------------------------------------------------------------------------
   -- Set the right context for calling this API
   -- Changed to fix bug # 2899700
   ----------------------------------------------------------------------------
   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      IF p_event_id IS NULL THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'For MANUAL events event_id cannot be NULL'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.get_entity_id');
      END IF;
      g_context := C_MANUAL_EVENT_CONTEXT;
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info       => p_event_source_info);

   ----------------------------------------------------------------------------
   -- Get the entity info, cached in globals
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info        => p_event_source_info
      ,p_valuation_method   => p_valuation_method
      ,p_event_id           => p_event_id);

   ----------------------------------------------------------------------------
   -- Check entity existency
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF  g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_entity_id');
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure get_entity_id'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'return value is:'||to_char(g_entity_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   RETURN g_entity_id;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
       (p_location => 'xla_events_pkg.get_entity_id');
END get_entity_id;


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
-- Following are the public routines on which bulk public APIs
-- are based.
--
--    1.    create_bulk_events
--    2.    get_array_event_info       (for an entity)
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
--
-- For MANUAL events this API cannot be called
--
--=============================================================================

PROCEDURE create_bulk_events
       (p_source_application_id        IN  INTEGER     DEFAULT NULL
       ,p_application_id               IN  INTEGER
       ,p_legal_entity_id              IN  INTEGER     DEFAULT NULL
       ,p_ledger_id                    IN  INTEGER
       ,p_entity_type_code             IN  VARCHAR2)
IS

TYPE t_array_number      IS TABLE OF NUMBER          INDEX BY BINARY_INTEGER;
TYPE t_array_char        IS TABLE OF VARCHAR2(30)    INDEX BY BINARY_INTEGER;
TYPE t_array_char_ref    IS TABLE OF VARCHAR2(240)   INDEX BY BINARY_INTEGER;

l_array_source_id_int_1           t_array_number;
l_array_source_id_int_2           t_array_number;
l_array_source_id_int_3           t_array_number;
l_array_source_id_int_4           t_array_number;
l_array_source_id_char_1          t_array_char;
l_array_source_id_char_2          t_array_char;
l_array_source_id_char_3          t_array_char;
l_array_source_id_char_4          t_array_char;
l_array_valuation_method          t_array_char;
l_array_security_id_int_1         t_array_number;
l_array_security_id_int_2         t_array_number;
l_array_security_id_int_3         t_array_number;
l_array_security_id_char_1        t_array_char;
l_array_security_id_char_2        t_array_char;
l_array_security_id_char_3        t_array_char;
l_array_source_trx_number         t_array_char_ref;

l_array_entity_id                 t_array_number;
l_array_event_id                  t_array_number;

l_array_event_number              xla_events_pub_pkg.t_array_event_number;
l_array_event_date                xla_events_pub_pkg.t_array_event_date;
l_array_transaction_date          xla_events_pub_pkg.t_array_event_date;
l_array_event_status_code         xla_events_pub_pkg.t_array_event_status_code;
l_last                            PLS_INTEGER;
l_entity_id                       PLS_INTEGER;
l_current_entity_id               PLS_INTEGER;
l_current_event_number            NUMBER;

l_on_hold_flag                    xla_events.on_hold_flag%type:='N';
l_event_count                     number;
l_array_on_hold_flag              t_on_hold_flag_tbl;

l_rowcount                        NUMBER;
l_rowcount_gt                     NUMBER;

/* --bug 4526089
CURSOR csr_xla_applications IS
   SELECT application_id
   FROM   xla_subledgers
   WHERE  application_id = p_source_application_id;
*/
l_log_module                VARCHAR2(240);

CURSOR csr_xla_event_exist IS
   SELECT 1
   FROM xla_events_int_gt;

CURSOR csr_xla_event_number IS
   SELECT 1
   FROM xla_events_int_gt
   WHERE event_number is null or event_number<1;

CURSOR csr_processing_gapless IS
     SELECT entity_id, event_id, event_number, event_status_code
     FROM xla_events_int_gt
     ORDER BY entity_id, event_number;

CURSOR csr_status_error is
   SELECT 1 from xla_events_int_gt
   WHERE event_status_code not in ('I', 'U', 'N');

CURSOR csr_event_type_error(p_entity_code VARCHAR2, p_app_id NUMBER) is
   SELECT 1
   FROM xla_events_int_gt xeg, xla_event_types_b xet
   WHERE xet.entity_code(+) = p_entity_code
     AND xet.application_id(+) = p_app_id
     AND xeg.event_type_code = xet.event_type_code (+)
     AND nvl(xet.enabled_flag, 'N') = 'N';

CURSOR csr_parameter_mismatch(p_entity_code VARCHAR2, p_app_id NUMBER) is
   SELECT 1
     FROM xla_events_int_gt xeg
    WHERE xeg.entity_code <> p_entity_code
       OR xeg.application_id <> p_app_id;

l_update_gt_string varchar2(4000);
l_query_string varchar2(4000);

CURSOR csr_get_trx_entities is
   SELECT xla_transaction_entities_s.nextval
            ,source_id_int_1
            ,source_id_int_2
            ,source_id_int_3
            ,source_id_int_4
            ,source_id_char_1
            ,source_id_char_2
            ,source_id_char_3
            ,source_id_char_4
            ,valuation_method
    FROM (
        SELECT DISTINCT
            source_id_int_1
            ,source_id_int_2
            ,source_id_int_3
            ,source_id_int_4
            ,source_id_char_1
            ,source_id_char_2
            ,source_id_char_3
            ,source_id_char_4
            ,valuation_method
         FROM xla_events_int_gt);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_bulk_events';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure create_bulk_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_source_application_id = '||p_source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_legal_entity_id = '||p_legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_entity_type_code = '||p_entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;


   SAVEPOINT before_event_creation;
   g_action := C_EVENT_CREATE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_application_id);

   ----------------------------------------------------------------------------
   -- This API cannot be called for manual events.
   ----------------------------------------------------------------------------
   IF p_entity_type_code = C_MANUAL_ENTITY THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'For MANUAL events this API cannot be called'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_array_event_info (fn)');
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   ----------------------------------------------------------------------------
   -- Immediately exit if the table is empty
   -- the l_rowcount_gt is also useful to find if there is invalid data
   ----------------------------------------------------------------------------
   select count(1) into l_rowcount_gt from xla_events_int_gt;
   if(l_rowcount_gt = 0) then
     return;
   end if;

   ----------------------------------------------------------------------------
   -- perform source application validation
   ----------------------------------------------------------------------------

   validate_context
      (p_application_id           => p_application_id
      ,p_ledger_id                => p_ledger_id
      ,p_entity_type_code         => p_entity_type_code);

   IF g_application_id IS NULL OR g_application_id <> p_application_id THEN
      cache_application_setup
         (p_application_id => p_application_id);
   END IF;

   -- assign g_id_mapping which will be used to create the where clause
   validate_entity_type_code
      (p_entity_type_code         => p_entity_type_code);

   select enable_gapless_events_flag
     into g_gapless_flag
     from xla_entity_types_b
    where entity_code=p_entity_type_code
          and application_id=p_application_id;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'g_gapless_flag= '||g_gapless_flag
         ,p_level    =>C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;

  -- can it be moved after the insertion as well?
   if(g_gapless_flag='Y') then
     open csr_xla_event_number;
     fetch csr_xla_event_number into l_last;
     if(csr_xla_event_number%FOUND) THEN
       close csr_xla_event_number;
       xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        =>
            'Event Number must be a number greater than 0 for entities that are subject to gapless processing'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.create_bulk_events');
       return;
     end if;
     close csr_xla_event_number;
   end if;

   -- validate if the data is ok
   BEGIN
     IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace
            (p_msg      => 'before validate data '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   =>l_log_module);
     END IF;
     l_query_string :=
     'SELECT 1
       FROM dual
      WHERE EXISTS
              (SELECT 1
                 FROM xla_events_int_gt xeg
                WHERE xeg.entity_code <> :1
                      OR xeg.application_id <> :2
                      OR xeg.event_status_code not in (''I'', ''U'', ''N'')
                      OR xeg.event_type_code not in
                           (SELECT event_type_code
                              FROM xla_event_types_b
                             WHERE application_id = :3
                               AND entity_code = :4
                               AND enabled_flag = ''Y'') OR '
           || validate_id_where_clause || ')';

     EXECUTE IMMEDIATE l_query_string INTO l_last
        USING p_entity_type_code
              ,p_application_id
              ,p_application_id
              ,p_entity_type_code;

     -- there is error! Do the validation to find the error.
     open csr_parameter_mismatch(p_entity_type_code, p_application_id);
     fetch csr_parameter_mismatch into l_last;
     if(csr_parameter_mismatch%FOUND) THEN
       close csr_parameter_mismatch;
       xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        =>
            'The parameters passed to the procedure do not match with the data in the xla_events_int_gt table'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.create_bulk_events');
       return;
     end if;
     close csr_parameter_mismatch;

     open csr_status_error;
     fetch csr_status_error into l_last;
     if(csr_status_error%FOUND) THEN
       close csr_status_error;
       xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'Event status must be I, U or N'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.create_bulk_events');
       return;
     end if;
     close csr_status_error;

     open csr_event_type_error(p_entity_type_code, p_application_id);
     fetch csr_event_type_error into l_last;
     if(csr_event_type_error%FOUND) THEN
       close csr_event_type_error;
       xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'Event type must be a valid event type'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.create_bulk_events');
       return;
     end if;
     close csr_event_type_error;

     xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        =>
            'Please check transaction ids in gt table. Mapped ids must have a not-null value, while unmapped ids cannot have value'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.create_bulk_events');
   EXCEPTION
     WHEN others then
        --exception means the data is good
        null;
     END;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'just before insert into xla_transaction entities'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;


   ----------------------------------------------------------------------------
   -- Bug 4312353. Modified the following loop to create new entities based
   -- on the promary key of the transaction that includes all the internal
   -- source identifiers and the valuation method
   ----------------------------------------------------------------------------

   OPEN csr_get_trx_entities;
   LOOP
      FETCH csr_get_trx_entities BULK COLLECT INTO
          l_array_entity_id
         ,l_array_source_id_int_1
         ,l_array_source_id_int_2
         ,l_array_source_id_int_3
         ,l_array_source_id_int_4
         ,l_array_source_id_char_1
         ,l_array_source_id_char_2
         ,l_array_source_id_char_3
         ,l_array_source_id_char_4
         ,l_array_valuation_method
      LIMIT 2000;

      FORALL i in 1..l_array_entity_id.COUNT
        INSERT INTO xla_transaction_entities
           (entity_id
           ,application_id
           ,source_application_id
           ,ledger_id
           ,legal_entity_id
           ,entity_code
           ,transaction_number
           ,creation_date
           ,created_by
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,valuation_method
           ,security_id_int_1
           ,security_id_int_2
           ,security_id_int_3
           ,security_id_char_1
           ,security_id_char_2
           ,security_id_char_3
           ,source_id_int_1
           ,source_id_int_2
           ,source_id_int_3
           ,source_id_int_4
           ,source_id_char_1
           ,source_id_char_2
           ,source_id_char_3
           ,source_id_char_4)
        (SELECT /*+ index (xe xla_events_int_gt_n1) */
            l_array_entity_id(i)
           , p_application_id
           , nvl(p_source_application_id, p_application_id)
           , p_ledger_id
           ,  xe.legal_entity_id   /* Bug 4458604*/
           , p_entity_type_code
           , xe.transaction_number
           , sysdate
           , xla_environment_pkg.g_usr_id
           , sysdate
           , xla_environment_pkg.g_usr_id
           , xla_environment_pkg.g_login_id
           ,  xe.valuation_method
           ,  xe.security_id_int_1
           ,  xe.security_id_int_2
           ,  xe.security_id_int_3
           ,  xe.security_id_char_1
           ,  xe.security_id_char_2
           ,  xe.security_id_char_3
           ,  xe.source_id_int_1
           ,  xe.source_id_int_2
           ,  xe.source_id_int_3
           ,  xe.source_id_int_4
           ,  xe.source_id_char_1
           ,  xe.source_id_char_2
           ,  xe.source_id_char_3
           ,  xe.source_id_char_4
        FROM xla_events_int_gt  xe
        WHERE NVL( xe.source_id_int_1,-99) = NVL(l_array_source_id_int_1(i),-99 )  -- 8967771: Relpaced C_NUM with -99
         AND NVL( xe.source_id_int_2,-99)  = NVL(l_array_source_id_int_2(i),-99 )
         AND NVL( xe.source_id_int_3,-99)  = NVL(l_array_source_id_int_3(i),-99 )
         AND NVL( xe.source_id_int_4,-99)  = NVL(l_array_source_id_int_4(i),-99 )
         AND NVL( xe.source_id_char_1,' ') = NVL(l_array_source_id_char_1(i),' ' )  -- 8967771: Relpaced C_CHAR with ' '
         AND NVL( xe.source_id_char_2,' ') = NVL(l_array_source_id_char_2(i),' ' )
         AND NVL( xe.source_id_char_3,' ') = NVL(l_array_source_id_char_3(i),' ' )
         AND NVL( xe.source_id_char_4,' ') = NVL(l_array_source_id_char_4(i),' ' )
         AND NVL( xe.valuation_method,' ') = NVL(l_array_valuation_method(i),' ' )
         AND ROWNUM = 1
         );

      FORALL i IN 1..l_array_entity_id.COUNT
        UPDATE  /*+ index (xe xla_events_int_gt_n1) */  xla_events_int_gt  xe
           SET  xe.entity_id = l_array_entity_id(i)
              , xe.event_id  = xla_events_s.nextval
         WHERE NVL( xe.source_id_int_1,-99)= NVL(l_array_source_id_int_1(i),-99)  -- 8967771: Relpaced C_NUM with -99
          AND NVL( xe.source_id_int_2,-99) = NVL(l_array_source_id_int_2(i),-99)
          AND NVL( xe.source_id_int_3,-99) = NVL(l_array_source_id_int_3(i),-99)
          AND NVL( xe.source_id_int_4,-99) = NVL(l_array_source_id_int_4(i),-99)
          AND NVL( xe.source_id_char_1,' ')= NVL(l_array_source_id_char_1(i),' ') -- 8967771: Relpaced C_CHAR with ' '
          AND NVL( xe.source_id_char_2,' ')= NVL(l_array_source_id_char_2(i),' ')
          AND NVL( xe.source_id_char_3,' ')= NVL(l_array_source_id_char_3(i),' ')
          AND NVL( xe.source_id_char_4,' ')= NVL(l_array_source_id_char_4(i),' ')
          AND NVL( xe.valuation_method,' ')=NVL(l_array_valuation_method(i),' ');

      EXIT WHEN csr_get_trx_entities%NOTFOUND;
   END LOOP;


   IF(g_gapless_flag = 'Y') THEN
     open csr_processing_gapless;

     l_current_entity_id := null;
     l_on_hold_flag := 'N';
     l_current_event_number := 1;
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => 'Entering a loop to process the gapless on-hold flag'
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   =>l_log_module);
     END IF;
     LOOP

       FETCH csr_processing_gapless
       BULK COLLECT INTO l_array_entity_id
                         , l_array_event_id
                         , l_array_event_number
                         , l_array_event_status_code
       LIMIT 2000;

       -- next is to loop to set the on_hold_flag

       FOR i in 1..l_array_event_id.COUNT LOOP
         IF(l_current_entity_id = l_array_entity_id (i)) THEN
           IF(l_on_hold_flag = 'N' ) THEN
             IF(l_current_event_number = l_array_event_number(i)) THEN
               l_array_on_hold_flag(i) := 'N';
               IF(l_array_event_status_code(i) = 'I') THEN
                 l_on_hold_flag :='Y';
               ELSE
                 l_current_event_number := l_current_event_number + 1;
               END IF;
             ELSE
               l_on_hold_flag :='Y';
               l_array_on_hold_flag(i) := 'Y';
             END IF;
           ELSE
             l_array_on_hold_flag(i) := 'Y';
           END IF;
         ELSE
           l_current_entity_id := l_array_entity_id (i);
           IF(l_array_event_number(i) = 1) THEN
             l_array_on_hold_flag(i) := 'N';
             IF(l_array_event_status_code(i) = 'I') THEN
               l_on_hold_flag :='Y';
             ELSE
               l_on_hold_flag :='N';
               l_current_event_number := l_current_event_number + 1;
             END IF;
           ELSE
             l_on_hold_flag :='Y';
             l_array_on_hold_flag(i) := 'Y';
           END IF;
         END IF;
       END LOOP;

       FORALL i in 1..l_array_event_id.COUNT
         UPDATE xla_events_int_gt
            SET on_hold_flag = l_array_on_hold_flag(i)
          WHERE event_id=l_array_event_id(i);

       EXIT when csr_processing_gapless%NOTFOUND;
     END LOOP;

     CLOSE csr_processing_gapless;

     IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace
            (p_msg      => 'before insert into xla_events table'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   =>l_log_module);
     END IF;

     INSERT INTO xla_events
          (event_id
          ,application_id
          ,event_type_code
          ,entity_id
          ,event_number
          ,event_status_code
          ,process_status_code
          ,event_date
          ,transaction_date
          ,budgetary_control_flag
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,program_update_date
          ,program_application_id
          ,program_id
          ,request_id
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
          ,reference_date_4
          ,on_hold_flag)
          (SELECT event_id
              ,application_id
              ,event_type_code
              ,entity_id
              ,event_number
              ,event_status_code
              ,C_INTERNAL_UNPROCESSED
              ,TRUNC(event_date)
              ,nvl(transaction_date, TRUNC(event_date))
              ,nvl(xla_events_int_gt.budgetary_control_flag,'N')
              ,sysdate
              ,xla_environment_pkg.g_usr_id
              ,sysdate
              ,xla_environment_pkg.g_usr_id
              ,xla_environment_pkg.g_login_id
              ,sysdate
              ,xla_environment_pkg.g_prog_appl_id
              ,xla_environment_pkg.g_prog_id
              ,xla_environment_pkg.g_req_Id
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
              ,reference_date_4
              ,on_hold_flag
           FROM xla_events_int_gt);
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => 'Number of events created(gapless) = '||
                          to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   =>l_log_module);
     END IF;

   ELSE -- not gapless
     IF (C_LEVEL_STATEMENT>= g_log_level) THEN
        trace
            (p_msg      => 'before insert into xla_events table nongapless'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   =>l_log_module);
     END IF;


     INSERT INTO xla_events
          (event_id
          ,application_id
          ,event_type_code
          ,entity_id
          ,event_number
          ,event_status_code
          ,process_status_code
          ,event_date
          ,transaction_date
          ,budgetary_control_flag
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,program_update_date
          ,program_application_id
          ,program_id
          ,request_id
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
          ,reference_date_4
          ,on_hold_flag)
          (SELECT event_id
              ,application_id
              ,event_type_code
              ,entity_id
              ,nvl(event_number, nvl(max(event_number)
                   over (partition by entity_id), 0)+
                   ROW_NUMBER() over (PARTITION BY entity_id order by event_id))
              ,event_status_code
              ,C_INTERNAL_UNPROCESSED
              ,TRUNC(event_date)
              ,nvl(transaction_date, TRUNC(event_date))
              ,nvl(xla_events_int_gt.budgetary_control_flag,'N')
              ,sysdate
              ,xla_environment_pkg.g_usr_id
              ,sysdate
              ,xla_environment_pkg.g_usr_id
              ,xla_environment_pkg.g_login_id
              ,sysdate
              ,xla_environment_pkg.g_prog_appl_id
              ,xla_environment_pkg.g_prog_id
              ,xla_environment_pkg.g_req_Id
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
              ,reference_date_4
              ,'N'
           FROM xla_events_int_gt);
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => 'Number of events created(non gapless) = '||
                          to_char(SQL%ROWCOUNT)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   =>l_log_module);
     END IF;
   END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure create_bulk_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_event_creation;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_event_creation;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.create_bulk_events(blk)');
END create_bulk_events;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE update_bulk_event_statuses(p_application_id INTEGER)
IS

TYPE t_array_number      IS TABLE OF NUMBER          INDEX BY BINARY_INTEGER;

l_array_entity_id                 t_array_number;
l_array_event_id                  t_array_number;
l_array_event_number              xla_events_pub_pkg.t_array_event_number;
l_array_event_status_code         xla_events_pub_pkg.t_array_event_status_code;

l_array_on_hold_flag      t_on_hold_flag_tbl;

l_log_module                VARCHAR2(240);
l_rowcount_gt               PLS_INTEGER;
l_current_event_number      xla_events.event_number%TYPE;
l_current_entity_id         PLS_INTEGER;
l_application_id            PLS_INTEGER;
l_on_hold_flag              xla_events.on_hold_flag%TYPE;

-- This cursor will check
-- 1. the application_id, entity_code, event_id is not null
-- 2. the old and new event_status_code is valid
-- 3. no manual entity events are modified
-- 4. application_id is populated and all equals p_application_id
CURSOR csr_manual_processed_events(app_id NUMBER) is
  SELECT 1
    FROM xla_events_int_gt xeg, xla_events xe, xla_entity_types_b xet
   WHERE xeg.application_id = xe.application_id (+)
     AND xeg.event_id = xe.event_id (+)
     AND xeg.entity_code = xet.entity_code (+)
     AND xet.application_id(+) = app_id
     AND (xeg.entity_code = C_MANUAL_ENTITY
          OR xeg.event_status_code not in ('I', 'N', 'U')
          OR xe.event_status_code  not in ('I', 'N', 'U')
          OR xe.application_id is null
          OR xe.event_id is null
          OR xet.entity_code is null
          OR xeg.application_id <> app_id);

CURSOR csr_invalid_app(app_id NUMBER) is
  SELECT 1
    FROM xla_events_int_gt xeg
   WHERE xeg.application_id <> app_id;

CURSOR csr_invalid_event_id(app_id NUMBER) is
  SELECT 1
    FROM xla_events_int_gt xeg, xla_events xe
   WHERE xeg.application_id = xe.application_id (+)
     AND xeg.event_id = xe.event_id (+)
     AND xe.event_id is null;

CURSOR csr_invalid_event_status(app_id NUMBER) is
  SELECT 1
    FROM xla_events_int_gt xeg, xla_events xe
   WHERE xeg.application_id = xe.application_id
     AND xeg.event_id = xe.event_id
     AND (xe.event_status_code not in ('I', 'N', 'U')
         OR xeg.event_status_code not in ('I', 'N', 'U'));

CURSOR csr_lock_te is
   SELECT xte.entity_id
     FROM xla_transaction_entities xte
    WHERE xte.application_id = p_application_id
      AND xte.entity_id in
          (SELECT entity_id
             FROM xla_events_int_gt xeg, xla_entity_types_b xet
            WHERE xeg.application_id = xet.application_id
              AND xeg.entity_code = xet.entity_code
              AND xet.enable_gapless_events_flag = 'Y')
      FOR UPDATE NOWAIT;

Cursor csr_new_gap is
       Select min(xe.event_number), xe.entity_id, xe.application_id
         From xla_events_int_gt xeg,
              xla_events xe,
              xla_entity_types_b xet
        Where xeg.event_id = xe.event_id
          And xeg.application_id = xe.application_id
          And xeg.entity_code = xet.entity_code
          And xeg.application_id = xet.application_id
          And xet.enable_gapless_events_flag = 'Y'
          And xe.event_status_code <> 'I'
          And xeg.event_status_code = 'I'
          And xe.on_hold_flag = 'N'
       Group by xe.entity_id, xe.application_id;

Cursor csr_erased_gap is
    Select xe.entity_id,
            xe.event_id,
            xe.event_number,
            nvl(xeg.event_status_code, xe.event_status_code)
       FROM xla_events xe, xla_events_int_gt xeg
      Where xe.event_id = xeg.event_id(+)
        And xe.entity_id in (
              Select xe.entity_id
                From xla_events_int_gt xeg,
                     xla_events xe,
                     xla_entity_types_b xet
               Where xeg.event_id = xe.event_id
                 And xet.entity_code = xeg.entity_code
                 And xet.application_id = xe.application_id
                 And xet.enable_gapless_events_flag = 'Y'
                 And xe.event_status_code = 'I'
                 And xeg.event_status_code <> 'I'
                 And xe.on_hold_flag = 'N')
     Order by entity_id, event_number;

l_temp number;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_bulk_event_statuses';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure .update_bulk_event_statuses'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   SAVEPOINT before_update_bulk_statuses;
   g_action := C_EVENT_UPDATE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_application_id);

   IF g_application_id IS NULL OR g_application_id <> p_application_id THEN
      cache_application_setup
         (p_application_id => p_application_id);
   END IF;

   ----------------------------------------------------------------------------
   -- Check if the data is valid
   ----------------------------------------------------------------------------
   open csr_manual_processed_events(p_application_id);
   fetch csr_manual_processed_events into l_temp;
   if(csr_manual_processed_events%FOUND) THEN
     close csr_manual_processed_events;

     open csr_invalid_app(p_application_id);
     fetch csr_invalid_app into l_temp;
     if(csr_invalid_app%FOUND) THEN
       close csr_invalid_app;
       xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'The parameter application_id does not match with the data in xla_events_int_gt table'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_bulk_event_statuses(fn)');
     end if;
     close csr_invalid_app;

     open csr_invalid_event_id(p_application_id);
     fetch csr_invalid_event_id into l_temp;
     if(csr_invalid_event_id%FOUND) THEN
       close csr_invalid_event_id;
       xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => '(Application id, Event ID) is not valid'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_bulk_event_statuses(fn)');
     end if;
     close csr_invalid_event_id;

     open csr_invalid_event_status(p_application_id);
     fetch csr_invalid_event_status into l_temp;
     if(csr_invalid_event_status%FOUND) THEN
       close csr_invalid_event_status;
       xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Both the new and the old event status must be valid and cannot be P'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_bulk_event_statuses(fn)');
     end if;
     close csr_invalid_event_status;

     -- If reach here, must be entity code error
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'The entity_code is not valid. Either it does not match with the event id, or it is MANUAL entity. This API cannot be called for MANUAL entity'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_bulk_event_statuses(fn)');
   end if;
   close csr_manual_processed_events;


  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'after the validation'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;

   -- lock the entity in xla_transaction_entities table
   -- for the entities that require gapless processing
   open csr_lock_te;
   close csr_lock_te;

   ----------------------------------------------------------------------------
   -- set the on_hold_flag to 'Y' for all the new gap generated
   ----------------------------------------------------------------------------
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'processing the new gaps'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;
   OPEN csr_new_gap;
   LOOP
     FETCH csr_new_gap
     into l_current_event_number,
          l_current_entity_id,
          l_application_id;
     EXIT WHEN csr_new_gap%NOTFOUND;

     UPDATE xla_events
        SET on_hold_flag = 'Y'
      WHERE entity_id = l_current_entity_id
        AND event_number > l_current_event_number
        AND application_id = l_application_id;
   END LOOP;
   CLOSE csr_new_gap;

   ----------------------------------------------------------------------------
   -- reset the on_hold_flag for all the existing gap elimited
   ----------------------------------------------------------------------------
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'processing the erased gaps'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;
   open csr_erased_gap;

   l_current_entity_id := null;
   l_on_hold_flag := 'N';
   l_current_event_number := 1;
   LOOP
     FETCH csr_erased_gap
     BULK COLLECT INTO l_array_entity_id
                         , l_array_event_id
                         , l_array_event_number
                         , l_array_event_status_code
     LIMIT 2000;

     -- next is to loop to set the on_hold_flag
     FOR i in 1..l_array_event_id.COUNT LOOP
         IF(l_current_entity_id = l_array_entity_id (i)) THEN
           IF(l_on_hold_flag = 'N' ) THEN
             IF(l_current_event_number = l_array_event_number(i)) THEN
               l_array_on_hold_flag(i) := 'N';
               IF(l_array_event_status_code(i) = 'I') THEN
                 l_on_hold_flag :='Y';
               ELSE
                 l_current_event_number := l_current_event_number + 1;
               END IF;
             ELSE
               l_on_hold_flag :='Y';
               l_array_on_hold_flag(i) := 'Y';
             END IF;
           ELSE
             l_array_on_hold_flag(i) := 'Y';
           END IF;
         ELSE
           l_current_entity_id := l_array_entity_id (i);
           IF(l_array_event_number(i) = 1) THEN
             l_array_on_hold_flag(i) := 'N';
             IF(l_array_event_status_code(i) = 'I') THEN
               l_on_hold_flag :='Y';
             ELSE
               l_on_hold_flag :='N';
               l_current_event_number := l_current_event_number + 1;
             END IF;
           ELSE
             l_on_hold_flag :='Y';
             l_array_on_hold_flag(i) := 'Y';
           END IF;
         END IF;
     END LOOP;

     FORALL i in 1..l_array_event_id.COUNT
       UPDATE xla_events
          SET on_hold_flag = l_array_on_hold_flag(i)
        WHERE event_id=l_array_event_id(i)
	AND   application_id = p_application_id -- 8967771
	;
     EXIT when csr_erased_gap%NOTFOUND;
   END LOOP;

   CLOSE csr_erased_gap;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'before update the table'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;

   UPDATE xla_events xe
      SET xe.event_status_code = (
           SELECT event_status_code
             FROM xla_events_int_gt xeg
            WHERE xeg.event_id = xe.event_id),
          xe.process_status_code = 'U'
    WHERE xe.event_id in (
             SELECT event_id
               FROM xla_events_int_gt)
    AND   xe.application_id = p_application_id -- 8967771
	       ;

/*  -- Maintaining the Draft balance is no more required bug 5529569

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'before calling massive_update'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;

  IF(NOT xla_balances_pkg.massive_update_for_events(p_application_id
                                                     => p_application_id)) THEN
       xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        =>
            'Error in the routine that does balance reversals'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.update_bulk_event_statuses');
  END IF;
*/
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'before calling delete_je'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;
  delete_je;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure update_bulk_event_statuses'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_update_bulk_statuses;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_update_bulk_statuses;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.update_bulk_event_statuses(blk)');
END update_bulk_event_statuses;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE delete_bulk_events(p_application_id INTEGER)
IS

l_log_module                VARCHAR2(240);

l_rowcount_gt               PLS_INTEGER;
l_event_number      xla_events.event_number%TYPE;
l_entity_id         PLS_INTEGER;
l_application_id            PLS_INTEGER;
-- This cursor will check
-- 1. the application_id, entity_code, event_id is not null
-- 2. the event_status_code cannot be 'P'
-- 3. no manual entity events are modified
-- 4. application_id is populated and all equals p_application_id
CURSOR csr_manual_processed_events(app_id NUMBER) is
  SELECT 1
    FROM xla_events_int_gt xeg, xla_events xe, xla_transaction_entities xte
   WHERE xeg.application_id = xe.application_id (+)
     AND xeg.event_id = xe.event_id (+)
     AND xe.entity_id = xte.entity_id (+)
     AND xte.application_id(+) = app_id
     AND (xeg.entity_code = C_MANUAL_ENTITY
          OR xe.event_status_code  not in ('I', 'N', 'U')
          OR xe.application_id is null
          OR xte.entity_code is null
          OR xe.event_id is null
          OR xeg.application_id <> app_id);

CURSOR csr_invalid_app(app_id NUMBER) is
  SELECT 1
    FROM xla_events_int_gt xeg
   WHERE xeg.application_id <> app_id;

CURSOR csr_invalid_event_id(app_id NUMBER) is
  SELECT 1
    FROM xla_events_int_gt xeg, xla_events xe
   WHERE xeg.application_id = xe.application_id (+)
     AND xeg.event_id = xe.event_id (+)
     AND xe.event_id is null;

CURSOR csr_invalid_event_status(app_id NUMBER) is
  SELECT 1
    FROM xla_events_int_gt xeg, xla_events xe
   WHERE xeg.application_id = xe.application_id
     AND xeg.event_id = xe.event_id
     AND xe.event_status_code not in ('I', 'N', 'U');

CURSOR csr_lock_te is
   SELECT xte.entity_id
     FROM xla_transaction_entities xte
    WHERE xte.application_id = p_application_id
          AND xte.entity_id in
          (SELECT entity_id
             FROM xla_events_int_gt xeg, xla_entity_types_b xet
            WHERE xeg.application_id = xet.application_id
              AND xeg.entity_code = xet.entity_code
              AND xet.enable_gapless_events_flag = 'Y')
      FOR UPDATE NOWAIT;

Cursor csr_new_gap is
       Select min(xe.event_number), xe.entity_id, xe.application_id
         From xla_events_int_gt xeg,
              xla_events xe,
              xla_entity_types_b xet
        Where xeg.event_id = xe.event_id
          And xeg.application_id = xe.application_id
          And xeg.entity_code = xet.entity_code
          And xeg.application_id = xet.application_id
          And xet.enable_gapless_events_flag = 'Y'
          And xe.event_status_code <> 'I'
          And xe.on_hold_flag = 'N'
       Group by xe.entity_id, xe.application_id;

l_temp number;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_bulk_events';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure .update_bulk_event_statuses'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   SAVEPOINT before_delete_bulk_events;
   g_action := C_EVENT_UPDATE;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_application_id);

   IF g_application_id IS NULL OR g_application_id <> p_application_id THEN
      cache_application_setup
         (p_application_id => p_application_id);
   END IF;

   ----------------------------------------------------------------------------
   -- Check if the data is valid
   ----------------------------------------------------------------------------
   open csr_manual_processed_events(p_application_id);
   fetch csr_manual_processed_events into l_temp;
   if(csr_manual_processed_events%FOUND) THEN
     close csr_manual_processed_events;

     open csr_invalid_app(p_application_id);
     fetch csr_invalid_app into l_temp;
     if(csr_invalid_app%FOUND) THEN
       close csr_invalid_app;
       xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'The parameter application_id does not match with the data in xla_events_int_gt table'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_bulk_event_statuses(fn)');
     end if;
     close csr_invalid_app;

     open csr_invalid_event_id(p_application_id);
     fetch csr_invalid_event_id into l_temp;
     if(csr_invalid_event_id%FOUND) THEN
       close csr_invalid_event_id;
       xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => '(Application id, Event ID) is not valid'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_bulk_event_statuses(fn)');
     end if;
     close csr_invalid_event_id;

     open csr_invalid_event_status(p_application_id);
     fetch csr_invalid_event_status into l_temp;
     if(csr_invalid_event_status%FOUND) THEN
       close csr_invalid_event_status;
       xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'The events to be deleted must be in status I, N or U'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.update_bulk_event_statuses(fn)');
     end if;
     close csr_invalid_event_status;

     -- if reach here, it must be entity code problem
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Either the entity code does not match with the event id, or the entity code is MANUAL. This API cannot be called to delete event for MANUAL entity'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_array_event_info (fn)');
   end if;
   close csr_manual_processed_events;

   ----------------------------------------------------------------------------
   -- Immediately exit if the table is empty
   -- the l_rowcount_gt is also useful to find if there is invalid data
   ----------------------------------------------------------------------------
   select count(1) into l_rowcount_gt from xla_events_int_gt;
   if(l_rowcount_gt = 0) then
     return;
   end if;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'before lock te'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;

   -- lock the entity in xla_transaction_entities table
   -- for the entities that require gapless processing
   open csr_lock_te;
   close csr_lock_te;

/*  -- Maintaining the Draft balance is no more required bug 5529569

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'before calling massive_update'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;

   IF(NOT xla_balances_pkg.massive_update_for_events(p_application_id
                                                => p_application_id)) THEN
       xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        =>
            'Error in the routine that does balance reversals'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.delete_bulk_events');
   END IF;
*/

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'before calling delete_je'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;

  delete_je;

   ----------------------------------------------------------------------------
   -- set the on_hold_flag to 'Y' for all the new gap generated
   ----------------------------------------------------------------------------
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'before process gapless'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;
   OPEN csr_new_gap;
   LOOP
     FETCH csr_new_gap into l_event_number, l_entity_id, l_application_id;
     EXIT WHEN csr_new_gap%NOTFOUND;

     UPDATE xla_events
        SET on_hold_flag = 'Y'
      WHERE entity_id = l_entity_id
        AND event_number > l_event_number
        AND application_id = l_application_id;
   END LOOP;
   CLOSE csr_new_gap;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'before deleting events'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;

  UPDATE xla_events_int_gt xeg
      SET xeg.entity_id =
               (SELECT xe.entity_id
                  FROM xla_events  xe
                 WHERE xe.event_id = xeg.event_id
		 AND   xe.application_id = p_application_id -- 8967771
		);

   DELETE xla_events
    WHERE event_id in (
            SELECT event_id
              FROM xla_events_int_gt)
    AND   application_id = p_application_id -- 8967771
    ;
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'Number of events deleted:'||to_char(SQL%ROWCOUNT)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;

   DELETE xla_transaction_entities xte
    WHERE not exists (
            SELECT 1
              FROM xla_events xe
             WHERE xe.entity_id = xte.entity_id
               AND xe.application_id = xte.application_id
               AND xte.application_id = p_application_id)
               AND entity_id in (
                   SELECT entity_id
                     FROM xla_events_int_gt);

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
     trace
         (p_msg      => 'Number of transaction entity deleted:'||
                        to_char(SQL%ROWCOUNT)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
  END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure delete_bulk_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   ROLLBACK to SAVEPOINT before_delete_bulk_event;
   RAISE;
WHEN OTHERS                                   THEN
   ROLLBACK to SAVEPOINT before_delete_bulk_event;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.delete_bulk_events(blk)');
END delete_bulk_events;

--=============================================================================
--
--  For MANUAL events this API cannot be called.
--
--=============================================================================

FUNCTION  get_array_event_info
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2 DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2 DEFAULT NULL
   ,p_event_date                   IN  DATE     DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2 DEFAULT NULL)
RETURN xla_events_pub_pkg.t_array_event_info IS

l_array_event_info              xla_events_pub_pkg.t_array_event_info;
l_count                         INTEGER := 0;
l_event_date                    DATE;

CURSOR c1 IS
   SELECT event_id
         ,event_number
         ,event_type_code
         ,event_date
         ,event_status_code
         ,on_hold_flag
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
         ,reference_date_4
     FROM xla_events
    WHERE event_date          = NVL(l_event_date, event_date)
      AND event_status_code   = NVL(p_event_status_code,event_status_code)
      AND event_type_code     = NVL(p_event_type_code  ,event_type_code)
      AND entity_id           = g_entity_id
      AND application_id       = g_application_id -- 8967771
      AND event_type_code IN (SELECT event_type_code
                                FROM xla_event_types_b
                               WHERE application_id    = g_application_id
                                 AND entity_code       = g_entity_type_code
                                 AND event_class_code  = NVL(p_event_class_code,
                                                             event_class_code));
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_array_event_info';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure get_array_event_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_application_id = '||
                        p_event_source_info.source_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'application_id = '||p_event_source_info.application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'legal_entity_id = '||
                        p_event_source_info.legal_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'ledger_id = '||p_event_source_info.ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'entity_type_code = '||
                        p_event_source_info.entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'transaction_number = '||
                        p_event_source_info.transaction_number
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_1 = '||
                        p_event_source_info.source_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_2 = '||
                        p_event_source_info.source_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_3 = '||
                        p_event_source_info.source_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_int_4 = '||
                        p_event_source_info.source_id_int_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_1 = '||
                        p_event_source_info.source_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_2 = '||
                        p_event_source_info.source_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_3 = '||
                        p_event_source_info.source_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'source_id_char_4 = '||
                        p_event_source_info.source_id_char_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_type_code = '||p_event_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_date = '||p_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_status_code = '||p_event_status_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_1 = '||
                        xla_events_pub_pkg.g_security.security_id_int_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_2 = '||
                        xla_events_pub_pkg.g_security.security_id_int_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_int_3 = '||
                        xla_events_pub_pkg.g_security.security_id_int_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_1 = '||
                        xla_events_pub_pkg.g_security.security_id_char_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_2 = '||
                        xla_events_pub_pkg.g_security.security_id_char_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'security_id_char_3 = '||
                        xla_events_pub_pkg.g_security.security_id_char_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;
   g_action := C_EVENT_QUERY;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security.
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_event_source_info.application_id);

   IF p_event_source_info.entity_type_code = C_MANUAL_ENTITY THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'For MANUAL events this API cannot be called'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_array_event_info (fn)');
   ELSE
      g_context := C_REGULAR_EVENT_CONTEXT;
   END IF;

   ----------------------------------------------------------------------------
   -- truncate date
   ----------------------------------------------------------------------------
   l_event_date    := TRUNC(p_event_date);

   ----------------------------------------------------------------------------
   -- Validate parameters
   ----------------------------------------------------------------------------
   validate_params
      (p_source_info       => p_event_source_info
      ,p_event_class_code  => p_event_class_code
      ,p_event_type_code   => p_event_type_code);
--      ,p_event_status_code => p_event_status_code);

   ----------------------------------------------------------------------------
   -- Get document PK
   ----------------------------------------------------------------------------
   cache_entity_info
      (p_source_info        => p_event_source_info
      ,p_valuation_method   => p_valuation_method
      ,p_event_id           => NULL);

   ----------------------------------------------------------------------------
   -- raise error if the entity does not exist
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF g_entity_id IS NULL  THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'No event exists for the document represented '||
                              'by the given source information.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_array_event_info (fn)');
   END IF;

   FOR lc_evt IN c1 LOOP
      l_count := l_count + 1;

      l_array_event_info(l_count).event_id          := lc_evt.event_id;
      l_array_event_info(l_count).event_number      := lc_evt.event_number;
      l_array_event_info(l_count).event_type_code   := lc_evt.event_type_code;
      l_array_event_info(l_count).event_date        := lc_evt.event_date;
      l_array_event_info(l_count).event_status_code := lc_evt.event_status_code;
      l_array_event_info(l_count).on_hold_flag      := lc_evt.on_hold_flag;
      l_array_event_info(l_count).reference_num_1   := lc_evt.reference_num_1;
      l_array_event_info(l_count).reference_num_2   := lc_evt.reference_num_2;
      l_array_event_info(l_count).reference_num_3   := lc_evt.reference_num_3;
      l_array_event_info(l_count).reference_num_4   := lc_evt.reference_num_4;
      l_array_event_info(l_count).reference_char_1  := lc_evt.reference_char_1;
      l_array_event_info(l_count).reference_char_2  := lc_evt.reference_char_2;
      l_array_event_info(l_count).reference_char_3  := lc_evt.reference_char_3;
      l_array_event_info(l_count).reference_char_4  := lc_evt.reference_char_4;
      l_array_event_info(l_count).reference_date_1  := lc_evt.reference_date_1;
      l_array_event_info(l_count).reference_date_2  := lc_evt.reference_date_2;
      l_array_event_info(l_count).reference_date_3  := lc_evt.reference_date_3;
      l_array_event_info(l_count).reference_date_4  := lc_evt.reference_date_4;
   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Number of events found = '||l_array_event_info.count
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
      trace
         (p_msg      => 'end of procedure get_array_event_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   RETURN (l_array_event_info);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.get_array_event_info (fn)');
END get_array_event_info;


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
-- Following are the public routines to set/reset/initialize the cache
--
--    1.    Initialize
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
-- Changed to fix bug # 2899700. (Added g_process_status_code_tbl init...)
--
--=============================================================================

PROCEDURE initialize IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.initialize';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure initialize'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   reset_cache;

   ----------------------------------------------------------------------------
   -- cache event status code
   ----------------------------------------------------------------------------
   g_event_status_code_tbl(1) := xla_events_pub_pkg.C_EVENT_UNPROCESSED;
   g_event_status_code_tbl(2) := xla_events_pub_pkg.C_EVENT_INCOMPLETE;
   g_event_status_code_tbl(3) := xla_events_pub_pkg.C_EVENT_NOACTION;
   g_event_status_code_tbl(4) := xla_events_pub_pkg.C_EVENT_PROCESSED;

   ----------------------------------------------------------------------------
   -- cache process status code
   ----------------------------------------------------------------------------
   g_process_status_code_tbl(1) := C_INTERNAL_UNPROCESSED;
   g_process_status_code_tbl(2) := C_INTERNAL_DRAFT;
   g_process_status_code_tbl(3) := C_INTERNAL_FINAL;
   g_process_status_code_tbl(4) := C_INTERNAL_ERROR;
   g_process_status_code_tbl(5) := C_INTERNAL_INVALID;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure initialize'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.initialize');
END initialize;


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
-- Following are the routines that are private to this package and are
--
--    1.    source_info_changed  (comparing event_source_info)
--    2.    source_info_changed  (comparing entity_source_info)
                                             -- No longer needed
--    3.    validate_context
--    4.    get_id_mapping
--    5.    validate_ids
--    6.    validate_cached_setup
--    7.    cache_application_setup
--    8.    validate_entity_type_code
--    9.    validate_event_class_code
--   10.    validate_event_type_code
--   11.    validate_event_status_code
--   12.    validate_params
--   13.    validate_ledger
--   14.    cache_entity_info
--   15.    create_entity_event
--   16.    update_entity_trx_number
--   17.    add_entity_event
--   18.    reset_cache
--   19.    set_context
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

FUNCTION source_info_changed
   (p_event_source_info1           IN  xla_events_pub_pkg.t_event_source_info
   ,p_event_source_info2           IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method1            IN  VARCHAR2
   ,p_valuation_method2            IN  VARCHAR2)
RETURN BOOLEAN IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.source_info_changed';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure source_info_changed'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   ----------------------------------------------------------------------------
   -- Bug 4312353. Added the the OR condition to check the valuation method
   ----------------------------------------------------------------------------

   IF NVL(p_event_source_info1.application_id,C_NUM)
                            <> NVL(p_event_source_info2.application_id,C_NUM)
   OR NVL(p_event_source_info1.ledger_id,C_NUM)
                            <> NVL(p_event_source_info2.ledger_id,C_NUM)
   OR NVL(p_event_source_info1.legal_entity_id,C_NUM)
                            <> NVL(p_event_source_info2.legal_entity_id,C_NUM)
   OR NVL(p_event_source_info1.entity_type_code,C_NUM)
                            <> NVL(p_event_source_info2.entity_type_code,C_NUM)
   OR NVL(p_event_source_info1.source_id_int_1,C_NUM)
                            <> NVL(p_event_source_info2.source_id_int_1,C_NUM)
   OR NVL(p_event_source_info1.source_id_int_2,C_NUM)
                            <> NVL(p_event_source_info2.source_id_int_2,C_NUM)
   OR NVL(p_event_source_info1.source_id_int_3,C_NUM)
                            <> NVL(p_event_source_info2.source_id_int_3,C_NUM)
   OR NVL(p_event_source_info1.source_id_int_4,C_NUM)
                            <> NVL(p_event_source_info2.source_id_int_4,C_NUM)
   OR NVL(p_event_source_info1.source_id_char_1,C_CHAR)
                            <> NVL(p_event_source_info2.source_id_char_1,C_CHAR)
   OR NVL(p_event_source_info1.source_id_char_2,C_CHAR)
                            <> NVL(p_event_source_info2.source_id_char_2,C_CHAR)
   OR NVL(p_event_source_info1.source_id_char_3,C_CHAR)
                            <> NVL(p_event_source_info2.source_id_char_3,C_CHAR)
   OR NVL(p_event_source_info1.source_id_char_4,C_CHAR)
                            <> NVL(p_event_source_info2.source_id_char_4,C_CHAR)
   OR NVL(p_valuation_method1,C_CHAR) <> NVL(p_valuation_method2,C_CHAR)
   THEN

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'end of procedure source_info_changed'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   =>l_log_module);
         trace
            (p_msg      => 'return value is true'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   =>l_log_module);
      END IF;
      RETURN TRUE;
   ELSE
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'end of procedure source_info_changed'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   =>l_log_module);
         trace
            (p_msg      => 'return value is false'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   =>l_log_module);
      END IF;
      RETURN FALSE;
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.source_info_changed');
END;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE validate_context
   (p_application_id               IN  INTEGER
   ,p_ledger_id                    IN  INTEGER
   ,p_entity_type_code             IN  VARCHAR2) IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_context';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure validate_context'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   IF p_application_id  IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Application ID has an invalid value. It cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_context');
   END IF;

   IF p_ledger_id IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Ledger ID has an invalid value. It cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_context');
   ELSE
      -------------------------------------------------------------------------
      -- Validate ledger
      -------------------------------------------------------------------------
      validate_ledger
         (p_ledger_id            => p_ledger_id
         ,p_application_id       => p_application_id);

   END IF;

   IF p_entity_type_code  IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'Entity Type Code has an invalid value. It cannot have a NULL value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_context');
   END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure validate_context'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.validate_context');
END validate_context;


--=============================================================================
--
--
--
--=============================================================================

FUNCTION  get_id_mapping
   (p_entity_type_code             IN  VARCHAR2
   ,p_source_id_code_1             IN  VARCHAR2
   ,p_source_id_code_2             IN  VARCHAR2
   ,p_source_id_code_3             IN  VARCHAR2
   ,p_source_id_code_4             IN  VARCHAR2)
RETURN VARCHAR2 IS
l_mapping             VARCHAR2(8);
lmap1                 VARCHAR2(1)   := '_';
lmap2                 VARCHAR2(1)   := '_';
lmap3                 VARCHAR2(1)   := '_';
lmap4                 VARCHAR2(1)   := '_';
lmap5                 VARCHAR2(1)   := '_';
lmap6                 VARCHAR2(1)   := '_';
lmap7                 VARCHAR2(1)   := '_';
lmap8                 VARCHAR2(1)   := '_';
l_error               BOOLEAN       := FALSE;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_id_mapping';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure get_id_mapping'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   IF p_source_id_code_1 IS NULL THEN
      IF p_source_id_code_2 IS NULL THEN
         IF p_source_id_code_3 IS NULL THEN
            IF p_source_id_code_4 IS NULL THEN
               l_error := FALSE;
            ELSE
               l_error := TRUE;
            END IF;
         ELSE
            l_error := TRUE;
         END IF;
      ELSE
         l_error := TRUE;
      END IF;
   ELSE
      IF p_source_id_code_2 IS NULL THEN
         IF p_source_id_code_3 IS NULL THEN
            IF p_source_id_code_4 IS NULL THEN
               l_error := FALSE;
            ELSE
               l_error := TRUE;
            END IF;
         ELSE
            l_error := TRUE;
         END IF;
      ELSE
         IF p_source_id_code_3 IS NULL THEN
            IF p_source_id_code_4 IS NULL THEN
               l_error := FALSE;
            ELSE
               l_error := TRUE;
            END IF;
         ELSE
            l_error := FALSE;
         END IF;
      END IF;
   END IF;

   IF l_error THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'The setup for Entity Type, '||
                          p_entity_type_code ||', is incorrect. Internal Error.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.get_id_mapping');
   END IF;

   IF p_source_id_code_1 = 'SOURCE_ID_INT_1'
   OR p_source_id_code_2 = 'SOURCE_ID_INT_1'
   OR p_source_id_code_3 = 'SOURCE_ID_INT_1'
   OR p_source_id_code_4 = 'SOURCE_ID_INT_1'
   THEN
      lmap1 := 'I';
   END IF;

   IF p_source_id_code_1 = 'SOURCE_ID_INT_2'
   OR p_source_id_code_2 = 'SOURCE_ID_INT_2'
   OR p_source_id_code_3 = 'SOURCE_ID_INT_2'
   OR p_source_id_code_4 = 'SOURCE_ID_INT_2'
   THEN
      lmap2 := 'I';
   END IF;

   IF p_source_id_code_1 = 'SOURCE_ID_INT_3'
   OR p_source_id_code_2 = 'SOURCE_ID_INT_3'
   OR p_source_id_code_3 = 'SOURCE_ID_INT_3'
   OR p_source_id_code_4 = 'SOURCE_ID_INT_3'
   THEN
      lmap3 := 'I';
   END IF;

   IF p_source_id_code_1 = 'SOURCE_ID_INT_4'
   OR p_source_id_code_2 = 'SOURCE_ID_INT_4'
   OR p_source_id_code_3 = 'SOURCE_ID_INT_4'
   OR p_source_id_code_4 = 'SOURCE_ID_INT_4'
   THEN
      lmap4 := 'I';
   END IF;

   IF p_source_id_code_1 = 'SOURCE_ID_CHAR_1'
   OR p_source_id_code_2 = 'SOURCE_ID_CHAR_1'
   OR p_source_id_code_3 = 'SOURCE_ID_CHAR_1'
   OR p_source_id_code_4 = 'SOURCE_ID_CHAR_1'
   THEN
      lmap5 := 'I';
   END IF;

   IF p_source_id_code_1 = 'SOURCE_ID_CHAR_2'
   OR p_source_id_code_2 = 'SOURCE_ID_CHAR_2'
   OR p_source_id_code_3 = 'SOURCE_ID_CHAR_2'
   OR p_source_id_code_4 = 'SOURCE_ID_CHAR_2'
   THEN
      lmap6 := 'I';
   END IF;

   IF p_source_id_code_1 = 'SOURCE_ID_CHAR_3'
   OR p_source_id_code_2 = 'SOURCE_ID_CHAR_3'
   OR p_source_id_code_3 = 'SOURCE_ID_CHAR_3'
   OR p_source_id_code_4 = 'SOURCE_ID_CHAR_3'
   THEN
      lmap7 := 'I';
   END IF;

   IF p_source_id_code_1 = 'SOURCE_ID_CHAR_4'
   OR p_source_id_code_2 = 'SOURCE_ID_CHAR_4'
   OR p_source_id_code_3 = 'SOURCE_ID_CHAR_4'
   OR p_source_id_code_4 = 'SOURCE_ID_CHAR_4'
   THEN
      lmap8 := 'I';
   END IF;

   l_mapping := lmap1||lmap2||lmap3||lmap4||lmap5||lmap6||lmap7||lmap8;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure get_id_mapping'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'return value is:'||l_mapping
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   RETURN l_mapping;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.get_id_mapping');
END;


--=============================================================================
--
--
--
--=============================================================================

FUNCTION validate_id_where_clause return VARCHAR2 is
l_string VARCHAR2(1000):=null;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_ids';
  END IF;

  IF substr(g_id_mapping,1,1) = 'I' THEN
    l_string := ' SOURCE_ID_INT_1 is null OR';
  ELSE
    l_string := ' SOURCE_ID_INT_1 is not null OR ';
  END IF;

  IF substr(g_id_mapping,2,1) = 'I' THEN
    l_string := l_string || ' SOURCE_ID_INT_2 is null OR ';
  ELSE
    l_string := l_string || ' SOURCE_ID_INT_2 is not null OR ';
  END IF;

  IF substr(g_id_mapping,3,1) = 'I' THEN
    l_string := l_string || ' SOURCE_ID_INT_3 is null OR';
  ELSE
    l_string := l_string || ' SOURCE_ID_INT_3 is not null OR';
  END IF;

  IF substr(g_id_mapping,4,1) = 'I' THEN
    l_string := l_string || ' SOURCE_ID_INT_4 is null OR';
  ELSE
    l_string := l_string || ' SOURCE_ID_INT_4 is not null OR';
  END IF;

  IF substr(g_id_mapping,5,1) = 'I' THEN
    l_string := l_string || ' SOURCE_ID_CHAR_1 is null OR';
  ELSE
    l_string := l_string || ' SOURCE_ID_CHAR_1 is not null OR';
  END IF;

  IF substr(g_id_mapping,6,1) = 'I' THEN
    l_string := l_string || ' SOURCE_ID_CHAR_2 is null OR';
  ELSE
    l_string := l_string || ' SOURCE_ID_CHAR_2 is not null OR';
  END IF;

  IF substr(g_id_mapping,7,1) = 'I' THEN
    l_string := l_string || ' SOURCE_ID_CHAR_3 is null OR';
  ELSE
    l_string := l_string || ' SOURCE_ID_CHAR_3 is not null OR';
  END IF;

  IF substr(g_id_mapping,8,1) = 'I' THEN
    l_string := l_string || ' SOURCE_ID_CHAR_4 is null ';
  ELSE
    l_string := l_string || ' SOURCE_ID_CHAR_4 is not null ';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure validate_id_where_clause'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'return value is:'||l_string
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

  RETURN l_string;
END validate_id_where_clause;


--=============================================================================
--
--
--
--=============================================================================

FUNCTION join_id_where_clause return VARCHAR2 is
l_string VARCHAR2(1000):=null;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_ids';
  END IF;

  IF substr(g_id_mapping,1,1) = 'I' THEN
    l_string := ' AND xte.source_id_int_1 = xeg.source_id_int_1';
  END IF;

  IF substr(g_id_mapping,2,1) = 'I' THEN
    l_string := l_string || ' AND xte.source_id_int_2 = xeg.source_id_int_2';
  END IF;

  IF substr(g_id_mapping,3,1) = 'I' THEN
    l_string := l_string || ' AND xte.source_id_int_3 = xeg.source_id_int_3';
  END IF;

  IF substr(g_id_mapping,4,1) = 'I' THEN
    l_string := l_string || ' AND xte.source_id_int_4 = xeg.source_id_int_4';
  END IF;

  IF substr(g_id_mapping,5,1) = 'I' THEN
    l_string := l_string || ' AND xte.source_id_char_1 = xeg.source_id_char_1';
  END IF;

  IF substr(g_id_mapping,6,1) = 'I' THEN
    l_string := l_string || ' AND xte.source_id_char_2 = xeg.source_id_char_2';
  END IF;

  IF substr(g_id_mapping,7,1) = 'I' THEN
    l_string := l_string || ' AND xte.source_id_char_3 = xeg.source_id_char_3';
  END IF;

  IF substr(g_id_mapping,8,1) = 'I' THEN
    l_string := l_string || ' AND xte.source_id_char_4 = xeg.source_id_char_4';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure join_id_where_clause'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'return value is:'||l_string
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

  RETURN l_string;
END join_id_where_clause;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE validate_ids
   (p_entity_type_code             IN  VARCHAR2
   ,p_source_id_int_1              IN  INTEGER
   ,p_source_id_int_2              IN  INTEGER
   ,p_source_id_int_3              IN  INTEGER
   ,p_source_id_int_4              IN  INTEGER
   ,p_source_id_char_1             IN  VARCHAR2
   ,p_source_id_char_2             IN  VARCHAR2
   ,p_source_id_char_3             IN  VARCHAR2
   ,p_source_id_char_4             IN  VARCHAR2) IS
l_error               BOOLEAN       := FALSE;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_ids';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure validate_ids'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   IF substr(g_id_mapping,1,1) = 'I' THEN
      IF p_source_id_int_1 IS NULL THEN
         l_error := TRUE;
      END IF;
   ELSE
      IF p_source_id_int_1 IS NOT NULL THEN
         l_error := TRUE;
      END IF;
   END IF;

   IF substr(g_id_mapping,2,1) = 'I' THEN
      IF p_source_id_int_2 IS NULL THEN
         l_error := TRUE;
      END IF;
   ELSE
      IF p_source_id_int_2 IS NOT NULL THEN
         l_error := TRUE;
      END IF;
   END IF;

   IF substr(g_id_mapping,3,1) = 'I' THEN
      IF p_source_id_int_3 IS NULL THEN
         l_error := TRUE;
      END IF;
   ELSE
      IF p_source_id_int_3 IS NOT NULL THEN
         l_error := TRUE;
      END IF;
   END IF;

   IF substr(g_id_mapping,4,1) = 'I' THEN
      IF p_source_id_int_4 IS NULL THEN
         l_error := TRUE;
      END IF;
   ELSE
      IF p_source_id_int_4 IS NOT NULL THEN
         l_error := TRUE;
      END IF;
   END IF;

   IF substr(g_id_mapping,5,1) = 'I' THEN
      IF p_source_id_char_1 IS NULL THEN
         l_error := TRUE;
      END IF;
   ELSE
      IF p_source_id_char_1 IS NOT NULL THEN
         l_error := TRUE;
      END IF;
   END IF;

   IF substr(g_id_mapping,6,1) = 'I' THEN
      IF p_source_id_char_2 IS NULL THEN
         l_error := TRUE;
      END IF;
   ELSE
      IF p_source_id_char_2 IS NOT NULL THEN
         l_error := TRUE;
      END IF;
   END IF;

   IF substr(g_id_mapping,7,1) = 'I' THEN
      IF p_source_id_char_3 IS NULL THEN
         l_error := TRUE;
      END IF;
   ELSE
      IF p_source_id_char_3 IS NOT NULL THEN
         l_error := TRUE;
      END IF;
   END IF;

   IF substr(g_id_mapping,8,1) = 'I' THEN
      IF p_source_id_char_4 IS NULL THEN
         l_error := TRUE;
      END IF;
   ELSE
      IF p_source_id_char_4 IS NOT NULL THEN
         l_error := TRUE;
      END IF;
   END IF;

   IF l_error THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
     'The source information passed does not map to the setups for Entity Type '
                           || p_entity_type_code
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_ids');
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure validate_ids'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;
END;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE validate_cached_setup IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_cached_setup';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure validate_cached_setup'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   IF g_application_id IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
        'The application is not registerd with subledger accounting architectre'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_cached_setup');
   END IF;

   --
   -- Validate that the entity type code tables have been loaded
   --
   IF g_entity_type_code_tbl.FIRST IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'There is no Entity Type Code defined for the application '
                           ||g_application_id
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_cached_setup');
   END IF;

   --
   -- Validate that the event class tables have been loaded
   --
   IF g_event_class_code_tbl.FIRST IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'There is no Event Class defined for the application '
                           ||g_application_id
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_cached_setup');
   END IF;

   --
   -- Validate that the event type code tables have been loaded
   --
   IF g_event_type_code_tbl.FIRST IS NULL THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'There is no Event Type Code defined for the application '
                           ||g_application_id
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_cached_setup');
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure validate_cached_setup'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

END validate_cached_setup;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE cache_application_setup
   (p_application_id               IN  INTEGER) IS
CURSOR csr_xla_application IS
   SELECT application_id
   FROM   xla_subledgers
   WHERE  application_id        = p_application_id;

CURSOR csr_entity_types IS
   SELECT t.entity_code
         ,m.source_id_col_name_1
         ,m.source_id_col_name_2
         ,m.source_id_col_name_3
         ,m.source_id_col_name_4
         ,t.enabled_flag
   FROM   xla_entity_types_b      t
         ,xla_entity_id_mappings  m
   WHERE  t.application_id        = g_application_id
     AND  t.application_id        = m.application_id
     AND  t.entity_code           = m.entity_code;

CURSOR csr_event_classes IS
   SELECT a.entity_code
         ,a.event_class_code
         ,a.enabled_flag
   FROM   xla_event_classes_b  a
   WHERE  a.application_id          = g_application_id;

CURSOR csr_event_types IS
   SELECT a.entity_code
         ,a.event_class_code
         ,a.event_type_code
         ,a.enabled_flag
   FROM   xla_event_types_b      a
   WHERE  a.application_id          = g_application_id;

l_count                         INTEGER;

l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.cache_application_setup';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure cache_application_setup'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   trace('> xla_events_pkg.cache_application_setup'                  , 20);

   g_application_id := null;
   g_entity_type_code_tbl.delete; --clear cache first
   g_event_class_code_tbl.delete; --clear cache first
   g_event_type_code_tbl.delete;  --clear cache first
   g_ledger_status_tbl.delete;    --clear cache first

   --
   -- Cache application id
   --
   FOR c1 IN csr_xla_application LOOP
      g_application_id := c1.application_id;
   END LOOP;

   --
   -- Cache entity code
   --

   FOR c1 IN csr_entity_types LOOP
      g_entity_type_code_tbl(c1.entity_code).enabled_flag := c1.enabled_flag;
      g_entity_type_code_tbl(c1.entity_code).id_mapping   :=
                               get_id_mapping
                                (p_entity_type_code => c1.entity_code
                                ,p_source_id_code_1 => c1.source_id_col_name_1
                                ,p_source_id_code_2 => c1.source_id_col_name_2
                                ,p_source_id_code_3 => c1.source_id_col_name_3
                                ,p_source_id_code_4 => c1.source_id_col_name_4);
   END LOOP;

   --
   -- Cache event class code
   --
   FOR c1 IN csr_event_classes LOOP
      g_event_class_code_tbl(c1.event_class_code).enabled_flag :=
                                                             c1.enabled_flag;
      g_event_class_code_tbl(c1.event_class_code).entity_type_code  :=
                                                             c1.entity_code;
   END LOOP;


   --
   -- Cache event type code
   --
   FOR c1 IN csr_event_types LOOP
      g_event_type_code_tbl(c1.event_type_code).enabled_flag := c1.enabled_flag;
      g_event_type_code_tbl(c1.event_type_code).event_class_code  :=
                                                            c1.event_class_code;
   END LOOP;

   --
   -- Validate the cached information
   --
   validate_cached_setup;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure cache_application_setup'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.cache_application_setup');
END cache_application_setup;


--=============================================================================
-- This procedure assign variable g_id_mapping
-- if the action is delete or query, or if the entity code is enabled
-- else, it raise exception
--=============================================================================
PROCEDURE validate_entity_type_code
   (p_entity_type_code             IN  VARCHAR2) IS
l_enabled_flag          VARCHAR2(1);
l_log_module                VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_entity_type_code';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure validate_entity_type_code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'Entity Type Code           = '||p_entity_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   l_enabled_flag := g_entity_type_code_tbl(p_entity_type_code).enabled_flag;

   IF (g_action = C_EVENT_DELETE) OR (g_action = C_EVENT_QUERY) THEN
      g_id_mapping := g_entity_type_code_tbl(p_entity_type_code).id_mapping;
   ELSIF (l_enabled_flag = C_YES) THEN
      g_id_mapping := g_entity_type_code_tbl(p_entity_type_code).id_mapping;
   ELSIF (l_enabled_flag <> C_YES) THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'The entity Type is not enabled. Disabled entity types are not allowed for create/update APIs.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_entity_type_code');
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure validate_entity_type_code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   xla_exceptions_pkg.raise_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_COMMON_ERROR'
      ,p_token_1        => 'ERROR'
      ,p_value_1        => p_entity_type_code||
      ' is not a defined entity type for the application '||g_application_id
      ,p_token_2        => 'LOCATION'
      ,p_value_2        => 'xla_events_pkg.validate_entity_type_code');
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.validate_entity_type_code');
END validate_entity_type_code;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE validate_event_class_code
   (p_entity_type_code             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2) IS
l_enabled_flag          VARCHAR2(1);
l_entity_code            VARCHAR2(30);
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_event_class_code';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure validate_event_class_code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   l_enabled_flag := g_event_class_code_tbl(p_event_class_code).enabled_flag;
   l_entity_code  :=g_event_class_code_tbl(p_event_class_code).entity_type_code;


   IF (((g_action = C_EVENT_CREATE) OR (g_action = C_EVENT_UPDATE)) AND
       (l_enabled_flag <> C_YES)
      )
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'The Event Class is not enabled. Disabled event classes are not allowed for create/update APIs.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_event_class_code');
   END IF;

   IF p_entity_type_code <> l_entity_code THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Event class '||p_event_class_code||
         ' is not defined for the entity type '||p_entity_type_code||
                              ' and application '||g_application_id
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_event_class_code');
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure validate_event_class_code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   xla_exceptions_pkg.raise_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_COMMON_ERROR'
      ,p_token_1        => 'ERROR'
      ,p_value_1        => p_event_class_code||
      ' is not a defined event class for the application '||g_application_id
      ,p_token_2        => 'LOCATION'
      ,p_value_2        => 'xla_events_pkg.validate_event_class_code');
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.validate_event_class_code');
END validate_event_class_code;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE validate_event_type_code
   (p_entity_type_code             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2
   ,p_event_type_code              IN  VARCHAR2) IS
l_enabled_flag          VARCHAR2(1);
l_entity_code            VARCHAR2(30);
l_event_class_code      VARCHAR2(30);
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_event_type_code';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure validate_event_type_code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   l_enabled_flag      := g_event_type_code_tbl(p_event_type_code).enabled_flag;
   l_event_class_code  :=
                      g_event_type_code_tbl(p_event_type_code).event_class_code;
   l_entity_code       :=
                    g_event_class_code_tbl(l_event_class_code).entity_type_code;

   IF (((g_action = C_EVENT_CREATE) OR (g_action = C_EVENT_UPDATE)) AND
       (l_enabled_flag <> C_YES)
      )
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        =>
         'The Event Type is not enabled. Disabled event types are not allowed for create/update APIs.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_event_type_code');
   END IF;

   IF ((p_entity_type_code <> l_entity_code) OR
       (NVL(p_event_class_code,l_event_class_code) <> l_event_class_code)
      )
   THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Event type '||p_event_type_code||
         ' is not defined for the entity type '||p_entity_type_code||
                              ', event class '||p_event_class_code||
                              ' and application '||g_application_id
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_event_type_code');
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure validate_event_type_code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   trace('< xla_events_pkg.validate_event_type_code'      , 20);
EXCEPTION
WHEN NO_DATA_FOUND THEN
   xla_exceptions_pkg.raise_message
      (p_appli_s_name   => 'XLA'
      ,p_msg_name       => 'XLA_COMMON_ERROR'
      ,p_token_1        => 'ERROR'
      ,p_value_1        => p_event_type_code||
      ' is not a defined event type for the application '||g_application_id
      ,p_token_2        => 'LOCATION'
      ,p_value_2        => 'xla_events_pkg.validate_event_type_code');
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.validate_event_type_code');
END validate_event_type_code;

--=============================================================================
--
--
-- Changed to fix bug # 2899700.
--
--=============================================================================

PROCEDURE validate_status_code
       (p_event_status_code            IN  VARCHAR2
       ,p_process_status_code          IN  VARCHAR2) IS
l_found          BOOLEAN := FALSE;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_status_code';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure validate_status_code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   ----------------------------------------------------------------------------
   -- Validate event status code against the possible valid statuses
   ----------------------------------------------------------------------------
   FOR i IN g_event_status_code_tbl.FIRST .. g_event_status_code_tbl.LAST  LOOP
     IF g_event_status_code_tbl(i) = p_event_status_code THEN
        l_found := TRUE;
        EXIT;
     END IF;
   END LOOP;

   IF NOT l_found THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Event Status Code cannot have a '||
                               p_event_status_code              ||
                              ' value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_status_code');
   END IF;

   ----------------------------------------------------------------------------
   -- Validate process status code against the possible valid statuses
   ----------------------------------------------------------------------------
   l_found := FALSE;
   FOR i IN g_process_status_code_tbl.FIRST .. g_process_status_code_tbl.LAST
   LOOP
     IF g_process_status_code_tbl(i) = p_process_status_code THEN
        l_found := TRUE;
        EXIT;
     END IF;
   END LOOP;

   IF NOT l_found THEN
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Process Status Code cannot have a '||
                               p_process_status_code              ||
                              ' value.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'xla_events_pkg.validate_status_code');
   END IF;

   ----------------------------------------------------------------------------
   -- following code is modified to fix bug # 2899700
   ----------------------------------------------------------------------------
   IF g_context = C_REGULAR_EVENT_CONTEXT THEN

      -------------------------------------------------------------------------
      -- for regular events
      -------------------------------------------------------------------------
      IF p_process_status_code <> C_INTERNAL_UNPROCESSED THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'Process Status Code has an invalid value. '||
                                'It should always have a ''Unprocessed'' value.'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.validate_status_code');
       END IF;

       IF p_event_status_code = xla_events_pub_pkg.C_EVENT_PROCESSED THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'Event Status Code has an invalid value. '||
                                 'It cannot have a ''Processed'' value.'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.validate_status_code');
       END IF;
   ELSIF g_context = C_MANUAL_EVENT_CONTEXT THEN

      -------------------------------------------------------------------------
      -- for manual events
      -------------------------------------------------------------------------

      IF (p_process_status_code = C_INTERNAL_FINAL) THEN
         IF (p_event_status_code <> xla_events_pub_pkg.C_EVENT_PROCESSED) THEN
            xla_exceptions_pkg.raise_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_COMMON_ERROR'
               ,p_token_1        => 'ERROR'
               ,p_value_1        => 'The following combination is invalid: '||
                             'Process Status Code = '|| p_process_status_code ||
                                    ', '||
                               'Event Status Code   = '|| p_event_status_code
               ,p_token_2        => 'LOCATION'
               ,p_value_2        => 'xla_events_pkg.validate_status_code');
         END IF;
      ELSIF (p_process_status_code = C_INTERNAL_DRAFT) THEN
         IF (p_event_status_code <> xla_events_pub_pkg.C_EVENT_UNPROCESSED) THEN
            xla_exceptions_pkg.raise_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_COMMON_ERROR'
               ,p_token_1        => 'ERROR'
               ,p_value_1        => 'The following combination is invalid: '||
                             'Process Status Code = '|| p_process_status_code ||
                                    ', '||
                                 'Event Status Code   = '|| p_event_status_code
               ,p_token_2        => 'LOCATION'
               ,p_value_2        => 'xla_events_pkg.validate_status_code');
         END IF;
      ELSIF (p_process_status_code = C_INTERNAL_UNPROCESSED) THEN
         IF (p_event_status_code = xla_events_pub_pkg.C_EVENT_PROCESSED) THEN
            xla_exceptions_pkg.raise_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_COMMON_ERROR'
               ,p_token_1        => 'ERROR'
               ,p_value_1        => 'The following combination is invalid: '||
                            'Process Status Code = '|| p_process_status_code ||
                                    ', '||
                                'Event Status Code   = '|| p_event_status_code
               ,p_token_2        => 'LOCATION'
               ,p_value_2        => 'xla_events_pkg.validate_status_code');
         END IF;
      ELSE
            xla_exceptions_pkg.raise_message
               (p_appli_s_name   => 'XLA'
               ,p_msg_name       => 'XLA_COMMON_ERROR'
               ,p_token_1        => 'ERROR'
               ,p_value_1        => 'The following combination is invalid: '||
                             'Process Status Code = '|| p_process_status_code ||
                                    ', '||
                                'Event Status Code   = '|| p_event_status_code
               ,p_token_2        => 'LOCATION'
               ,p_value_2        => 'xla_events_pkg.validate_status_code');
      END IF;
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure validate_status_code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.validate_status_code');
END validate_status_code;


--=============================================================================
--
--
--  Date validation is not needed as it is always truncated. (18-Jul-02)
--
--=============================================================================

PROCEDURE validate_params
   (p_source_info                  IN  xla_events_pub_pkg.t_event_source_info
   ,p_event_class_code             IN  VARCHAR2 DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2 DEFAULT NULL
   ,p_event_date                   IN  DATE     DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2 DEFAULT NULL
   ,p_process_status_code          IN  VARCHAR2 DEFAULT NULL) IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_params';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure validate_params'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   ----------------------------------------------------------------------------
   -- Check all mandatory parameters are NOT NULL
   ----------------------------------------------------------------------------
   validate_context
      (p_application_id         => p_source_info.application_id
      ,p_ledger_id              => p_source_info.ledger_id
      ,p_entity_type_code       => p_source_info.entity_type_code);

   ----------------------------------------------------------------------------
   -- Do not check again the source_info if it has been kept the same
   ----------------------------------------------------------------------------
   IF source_info_changed(p_source_info,g_source_info,null,null) THEN

      -------------------------------------------------------------------------
      -- Cache values for the application if not yet done
      -------------------------------------------------------------------------
      IF ((g_application_id IS NULL) OR
          (g_application_id <> p_source_info.application_id))
      THEN
         cache_application_setup
            (p_application_id => p_source_info.application_id);
      END IF;

      validate_entity_type_code
         (p_entity_type_code  => p_source_info.entity_type_code);

      -------------------------------------------------------------------------
      -- Validate the source IDs
      -------------------------------------------------------------------------
      validate_ids
         (p_entity_type_code  => p_source_info.entity_type_code
         ,p_source_id_int_1   => p_source_info.source_id_int_1
         ,p_source_id_int_2   => p_source_info.source_id_int_2
         ,p_source_id_int_3   => p_source_info.source_id_int_3
         ,p_source_id_int_4   => p_source_info.source_id_int_4
         ,p_source_id_char_1  => p_source_info.source_id_char_1
         ,p_source_id_char_2  => p_source_info.source_id_char_2
         ,p_source_id_char_3  => p_source_info.source_id_char_3
         ,p_source_id_char_4  => p_source_info.source_id_char_4);
   END IF;

   ----------------------------------------------------------------------------
   -- Validate the class, if passed
   ----------------------------------------------------------------------------
   IF p_event_class_code IS NOT NULL THEN
      validate_event_class_code
         (p_entity_type_code  => p_source_info.entity_type_code
         ,p_event_class_code  => p_event_class_code);
   END IF;

   ----------------------------------------------------------------------------
   -- Validate the event type, if passed
   ----------------------------------------------------------------------------
   IF p_event_type_code IS NOT NULL THEN
      validate_event_type_code
           (p_entity_type_code  => p_source_info.entity_type_code
           ,p_event_class_code  => p_event_class_code
           ,p_event_type_code   => p_event_type_code);
   END IF;

   ----------------------------------------------------------------------------
   -- Validate the event status code, if passed
   ----------------------------------------------------------------------------
   IF p_event_status_code IS NOT NULL THEN
      validate_status_code
         (p_event_status_code    => p_event_status_code
         ,p_process_status_code  => p_process_status_code);
   END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure validate_params'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.validate_params');
END validate_params;



--=============================================================================
--
--
--
--=============================================================================

PROCEDURE validate_ledger
   (p_ledger_id                    IN  NUMBER
   ,p_application_id               IN  NUMBER) IS
l_enabled_flag              VARCHAR2(1);
l_log_module                VARCHAR2(240);
l_temp                      varchar2(1);
l_application_name          FND_APPLICATION_TL.application_name%TYPE;
l_ledger_name               VARCHAR2(30);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.validate_ledger';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure validate_ledger'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   l_application_name :=  get_application_name
                            (p_application_id   => p_application_id);
   l_ledger_name      :=  get_ledger_name
                            (p_ledger_id        => p_ledger_id);

   IF g_ledger_status_tbl.exists(p_ledger_id) THEN
      IF g_ledger_status_tbl(p_ledger_id) = 'Y' THEN
         NULL;
      ELSE
         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        =>
      'The ledger is either not enabled or is marked as not to create events.'||
                                 'ledger_id = '||p_ledger_id||
                                 'application_id = '|| p_application_id
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_events_pkg.validate_ledger');
      END IF;
   ELSE
      BEGIN
         SELECT DECODE(enabled_flag
                      ,'N','N'
                      ,'Y',capture_event_flag)
           INTO l_temp --g_ledger_status_tbl(p_ledger_id)
           FROM xla_subledger_options_v
          WHERE ledger_id      = p_ledger_id
            AND application_id = p_application_id;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_SU_MISSING_SETUP'
            ,p_token_1        => 'LEDGER_NAME'
            ,p_value_1        =>  l_ledger_name
            ,p_token_2        => 'APPLICATION_NAME'
            ,p_value_2        =>  l_application_name);
      END;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure validate_ledger'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.validate_ledger');
END validate_ledger;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE cache_entity_info
   (p_source_info                  IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  PLS_INTEGER) IS

l_source_info       xla_events_pub_pkg.t_event_source_info;

-------------------------------------------------------------------------------
-- Following three cursors have been modified to remove the 'for update'.
-- The cursors c1 and c2 have also been modified to include 'group by' rather
-- than a subquery to get the max(event_number). Bug 3268790
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Bug 4312353. The following cursor is modifed to use the valuation method as
-- part of primary key to identify transactions. Removed other security
-- columns
-------------------------------------------------------------------------------

CURSOR c1 IS
   SELECT xte.entity_id
         ,xte.entity_code
         ,xte.transaction_number
         ,max(xe.event_number)
         ,xet.enable_gapless_events_flag
   FROM  xla_transaction_entities   xte
        ,xla_events     xe
        ,xla_entity_types_b xet
   WHERE xte.application_id                  = p_source_info.application_id
     AND xte.ledger_id                       = p_source_info.ledger_id
     AND xte.entity_code                     = p_source_info.entity_type_code
     AND NVL(xte.source_id_int_1,-99)   = NVL(p_source_info.source_id_int_1,-99)
     AND NVL(xte.source_id_int_2,-99)   = NVL(p_source_info.source_id_int_2,-99)
     AND NVL(xte.source_id_int_3,-99)   = NVL(p_source_info.source_id_int_3,-99)
     AND NVL(xte.source_id_int_4,-99)   = NVL(p_source_info.source_id_int_4,-99)
     AND NVL(xte.source_id_char_1,' ') = NVL(p_source_info.source_id_char_1,' ')
     AND NVL(xte.source_id_char_2,' ') = NVL(p_source_info.source_id_char_2,' ')
     AND NVL(xte.source_id_char_3,' ') = NVL(p_source_info.source_id_char_3,' ')
     AND NVL(xte.source_id_char_4,' ') = NVL(p_source_info.source_id_char_4,' ')
     AND NVL(xte.valuation_method,' ')    = NVL(p_valuation_method,' ')
     AND xe.entity_id                        = xte.entity_id
     AND xe.application_id                   = xte.application_id -- 8967771
     AND xet.application_id                  = xte.application_id
     AND xte.entity_code                     = xet.entity_code
   GROUP BY
     xte.entity_id,
     xte.entity_code,
     xte.transaction_number,
     xet.enable_gapless_events_flag;


CURSOR get_gapless_flag is
   SELECT a.enable_gapless_events_flag
     FROM xla_entity_types_b a
    WHERE a.entity_code=p_source_info.entity_type_code
          AND a.application_id=p_source_info.application_id;

CURSOR c2 IS
   SELECT a.entity_id
         ,a.entity_code
         ,a.transaction_number
         ,MAX(b.event_number)
         ,c.enable_gapless_events_flag
     FROM xla_transaction_entities   a
         ,xla_events     b
         ,xla_entity_types_b c
    WHERE a.application_id   = p_source_info.application_id
      AND a.entity_id = g_entity_id
      AND b.entity_id = g_entity_id
      AND b.application_id = a.application_id  -- 8967771
      and a.entity_code=c.entity_code
     AND a.application_id = c.application_id
    GROUP BY
      a.entity_id,
      a.entity_code,
      a.transaction_number,
      c.enable_gapless_events_flag;

-------------------------------------------------------------------------------
-- following cursor is for Manual entries.
-------------------------------------------------------------------------------

CURSOR c3 (eventid  IN NUMBER) IS
   SELECT a.entity_id
         ,a.entity_code
         ,a.transaction_number
         ,b.event_number
     FROM xla_transaction_entities   a
         ,xla_events     b
    WHERE b.event_id  = eventid
      AND b.application_id = p_source_info.application_id -- 8967771
      AND a.entity_id = b.entity_id
      AND a.application_id = p_source_info.application_id;
--   FOR UPDATE NOWAIT;

CURSOR c_lock_te (entityid in number) is
   SELECT a.entity_id
     FROM xla_transaction_entities   a
    WHERE a.entity_id=entityid
      AND a.application_id = p_source_info.application_id
      FOR UPDATE NOWAIT;
l_log_module                VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'cache_entity_info';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure cache_entity_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'g_context = '||g_context
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
   END IF;

   IF g_context = C_MANUAL_EVENT_CONTEXT THEN
      -------------------------------------------------------------------------
      -- for manual events
      -------------------------------------------------------------------------
      IF p_event_id IS NULL THEN
         g_entity_id          := NULL;
         g_entity_type_code   := NULL;
         g_transaction_number := NULL;
         g_max_event_number   := 0;
      ELSE
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'using cursor c3'
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
         END IF;

         OPEN c3(p_event_id);
         FETCH c3 INTO g_entity_id
                      ,g_entity_type_code
                      ,g_transaction_number
                      ,g_max_event_number;

         IF c3%NOTFOUND THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'cursor c3 did not fetch a row'
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   =>l_log_module);
            END IF;

            g_entity_id          := NULL;
            g_entity_type_code   := NULL;
            g_transaction_number := NULL;
            g_max_event_number   := 0;
         END IF;
         CLOSE c3;
      END IF;

      g_source_info := p_source_info;
      g_valuation_method := p_valuation_method;
   ELSIF source_info_changed(p_source_info,g_source_info,
                                p_valuation_method,g_valuation_method) THEN
      -------------------------------------------------------------------------
      -- for regular events where source info has changed
      -------------------------------------------------------------------------
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'using cursor c1'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   =>l_log_module);
      END IF;

      OPEN c1;
      FETCH c1 INTO g_entity_id
                   ,g_entity_type_code
                   ,g_transaction_number
                   ,g_max_event_number
                   ,g_gapless_flag;
      IF c1%NOTFOUND THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'cursor c1 did not fetch a row'
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
         END IF;

         g_entity_id          := NULL;
         g_entity_type_code   := NULL;
         g_transaction_number := NULL;
         g_max_event_number   := 0;

         open get_gapless_flag;
         fetch get_gapless_flag into g_gapless_flag;
         if(get_gapless_flag%NOTFOUND) THEN
           g_gapless_flag :='N';
         end if;
         close get_gapless_flag;
      END IF;
      CLOSE c1;

      if (g_gapless_flag='Y' and
             (g_action = C_EVENT_DELETE or
              g_action = C_EVENT_UPDATE or
              g_action = C_EVENT_CREATE)) then
        -- lock xla_trancation_entity table
        open c_lock_te(g_entity_id);
        close c_lock_te;
      end if;
      g_source_info := p_source_info;
      g_valuation_method := p_valuation_method;
   ELSE
      -------------------------------------------------------------------------
      -- for regular events where source info has not changed
      -------------------------------------------------------------------------
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'using cursor c2'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   =>l_log_module);
      END IF;

      OPEN c2;
      FETCH c2 INTO g_entity_id
                   ,g_entity_type_code
                   ,g_transaction_number
                   ,g_max_event_number
                   ,g_gapless_flag;
      IF c2%NOTFOUND THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'cursor c2 did not fetch a row'
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
         END IF;

         g_entity_id          := NULL;
         g_entity_type_code   := NULL;
         g_transaction_number := NULL;
         g_max_event_number   := 0;

         --  added bug 9235968
        IF g_entity_id is NULL THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'using cursor c1 again'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   =>l_log_module);
      END IF;

      OPEN c1;
      FETCH c1 INTO g_entity_id
                   ,g_entity_type_code
                   ,g_transaction_number
                   ,g_max_event_number
                   ,g_gapless_flag;
      IF c1%NOTFOUND THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'cursor c1 also did not fetch a row'
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
         END IF;
         g_entity_id          := NULL;
         g_entity_type_code   := NULL;
         g_transaction_number := NULL;
         g_max_event_number   := 0;
     END IF;
    END IF;
         --end bug 9235968




         open get_gapless_flag;
         fetch get_gapless_flag into g_gapless_flag;
         if(get_gapless_flag%NOTFOUND) THEN
           g_gapless_flag :='N';
         end if;
         close get_gapless_flag;
      ELSIF g_entity_type_code <> p_source_info.entity_type_code THEN
         ----------------------------------------------------------------------
         -- this was added to handle some special cases ????
         ----------------------------------------------------------------------
         g_source_info := l_source_info;
         g_valuation_method := NULL;
         cache_entity_info
            (p_source_info        => p_source_info
            ,p_valuation_method   => p_valuation_method
            ,p_event_id           => NULL);
      END IF;
      if (g_gapless_flag='Y' and
             (g_action = C_EVENT_DELETE or
              g_action = C_EVENT_UPDATE or
              g_action = C_EVENT_CREATE)) then
        -- lock xla_trancation_entity table
        open c_lock_te(g_entity_id);
        close c_lock_te;
      end if;
      CLOSE c2;
   END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'g_entity_id = '||g_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'end of procedure cache_entity_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;
   IF c2%ISOPEN THEN
      CLOSE c2;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;
   IF c2%ISOPEN THEN
      CLOSE c2;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.cache_entity_info');
END cache_entity_info;


--=============================================================================
--
--
-- Changed to fix bug # 2899700. (Added parameter p_process_status_code)
--
--=============================================================================

FUNCTION create_entity_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_type_code              IN  VARCHAR2
   ,p_event_date                   IN  DATE
   ,p_event_status_code            IN  VARCHAR2
   ,p_process_status_code          IN  VARCHAR2
   ,p_event_number                 IN  NUMBER
   ,p_transaction_date             IN  DATE
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info
                                       DEFAULT NULL
   ,p_budgetary_control_flag       IN  VARCHAR2)
RETURN INTEGER IS

l_entity_id              INTEGER;
l_log_module             VARCHAR2(240);
l_return_id              INTEGER;
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_entity_event';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure create_entity_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   INSERT INTO xla_transaction_entities
      (entity_id
      ,application_id
      ,source_application_id
      ,ledger_id
      ,legal_entity_id
      ,entity_code
      ,transaction_number
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,valuation_method
      ,security_id_int_1
      ,security_id_int_2
      ,security_id_int_3
      ,security_id_char_1
      ,security_id_char_2
      ,security_id_char_3
      ,source_id_int_1
      ,source_id_int_2
      ,source_id_int_3
      ,source_id_int_4
      ,source_id_char_1
      ,source_id_char_2
      ,source_id_char_3
      ,source_id_char_4)
   VALUES
      (xla_transaction_entities_s.nextval
      ,p_event_source_info.application_id
      ,NVL(p_event_source_info.source_application_id,
           p_event_source_info.application_id)
      ,p_event_source_info.ledger_id
      ,p_event_source_info.legal_entity_id
      ,p_event_source_info.entity_type_code
      ,p_event_source_info.transaction_number
      ,sysdate
      ,xla_environment_pkg.g_usr_id
      ,sysdate
      ,xla_environment_pkg.g_usr_id
      ,xla_environment_pkg.g_login_id
      ,p_valuation_method
      ,xla_events_pub_pkg.g_security.security_id_int_1
      ,xla_events_pub_pkg.g_security.security_id_int_2
      ,xla_events_pub_pkg.g_security.security_id_int_3
      ,xla_events_pub_pkg.g_security.security_id_char_1
      ,xla_events_pub_pkg.g_security.security_id_char_2
      ,xla_events_pub_pkg.g_security.security_id_char_3
      ,p_event_source_info.source_id_int_1
      ,p_event_source_info.source_id_int_2
      ,p_event_source_info.source_id_int_3
      ,p_event_source_info.source_id_int_4
      ,p_event_source_info.source_id_char_1
      ,p_event_source_info.source_id_char_2
      ,p_event_source_info.source_id_char_3
      ,p_event_source_info.source_id_char_4)
   RETURNING entity_id INTO l_entity_id;

   g_entity_id          := l_entity_id;
   g_entity_type_code   := p_event_source_info.entity_type_code;
   g_transaction_number := p_event_source_info.transaction_number;
   g_max_event_number   := 0;

   l_return_id:=add_entity_event
            (p_entity_id              => l_entity_id
            ,p_application_id         => p_event_source_info.application_id
            ,p_ledger_id              => p_event_source_info.ledger_id
            ,p_legal_entity_id        => p_event_source_info.legal_entity_id
            ,p_event_type_code        => p_event_type_code
            ,p_event_date             => p_event_date
            ,p_event_status_code      => p_event_status_code
            ,p_process_status_code    => p_process_status_code
            ,p_event_number           => p_event_number
            ,p_transaction_date       => p_transaction_date
            ,p_reference_info         => p_reference_info
            ,p_budgetary_control_flag => p_budgetary_control_flag);
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure create_entity_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'return value:'||to_char(l_return_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

  return l_return_id;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.create_entity_event');
END create_entity_event;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE update_entity_trx_number
   (p_transaction_number           IN  VARCHAR2) IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_entity_trx_number';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure update_entity_trx_number'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   UPDATE xla_transaction_entities
      SET transaction_number   = p_transaction_number
    WHERE entity_id            = g_entity_id
      AND application_id       = g_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure update_entity_trx_number'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.update_entity_trx_number');
END update_entity_trx_number;

--=============================================================================
--
--
-- Changed to fix bug # 2899700. (Added parameter p_process_status_code)
--
--=============================================================================

FUNCTION  add_entity_event
   (p_entity_id                    IN  INTEGER
   ,p_application_id               IN  INTEGER
   ,p_ledger_id                    IN  INTEGER
   ,p_legal_entity_id              IN  INTEGER
   ,p_event_type_code              IN  VARCHAR2
   ,p_event_date                   IN  DATE
   ,p_event_status_code            IN  VARCHAR2
   ,p_process_status_code          IN  VARCHAR2
   ,p_event_number                 IN  NUMBER
   ,p_transaction_date             IN  DATE
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info
                                       DEFAULT NULL
   ,p_budgetary_control_flag       IN  VARCHAR2)
RETURN INTEGER IS
l_event_id            INTEGER;
l_on_hold_flag        XLA_EVENTS.ON_HOLD_FLAG%TYPE:='N';
l_event_status_code   XLA_EVENTS.EVENT_STATUS_CODE%TYPE;
l_temp_event_number   XLA_EVENTS.event_number%TYPE;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.add_entity_event';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure add_entity_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   if(g_gapless_flag='Y' and p_event_number>1) then
     begin
       select on_hold_flag, event_status_code
         into l_on_hold_flag, l_event_status_code
         from xla_events
        where entity_id=p_entity_id
              and event_number=p_event_number-1
	      and application_id = p_application_id -- 8967771
	      ;
     exception
       when no_data_found then
         l_on_hold_flag:='Y';
     end;
     if(l_on_hold_flag = 'N' and l_event_status_code = 'I' ) then
       l_on_hold_flag := 'Y';
     end if;
   end if;

   INSERT INTO xla_events
      (event_id
      ,application_id
      ,event_type_code
      ,entity_id
      ,event_number
      ,transaction_date
      ,event_status_code
      ,process_status_code
      ,event_date
      ,budgetary_control_flag
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,program_update_date
      ,program_application_id
      ,program_id
      ,request_id
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
      ,reference_date_4
      ,on_hold_flag)
   VALUES
      (xla_events_s.nextval
      ,p_application_id
      ,p_event_type_code
      ,p_entity_id
      ,NVL(p_event_number,g_max_event_number + 1)
      ,NVL(p_transaction_date, TRUNC(p_event_date))
      ,p_event_status_code
      ,p_process_status_code
      ,TRUNC(p_event_date)
      ,p_budgetary_control_flag
      ,sysdate
      ,xla_environment_pkg.g_usr_id
      ,sysdate
      ,xla_environment_pkg.g_usr_id
      ,xla_environment_pkg.g_login_id
      ,sysdate
      ,xla_environment_pkg.g_prog_appl_id
      ,xla_environment_pkg.g_prog_id
      ,xla_environment_pkg.g_Req_Id
      ,p_reference_info.reference_num_1
      ,p_reference_info.reference_num_2
      ,p_reference_info.reference_num_3
      ,p_reference_info.reference_num_4
      ,p_reference_info.reference_char_1
      ,p_reference_info.reference_char_2
      ,p_reference_info.reference_char_3
      ,p_reference_info.reference_char_4
      ,p_reference_info.reference_date_1
      ,p_reference_info.reference_date_2
      ,p_reference_info.reference_date_3
      ,p_reference_info.reference_date_4
      ,l_on_hold_flag)
   RETURNING event_id INTO l_event_id;

   if(l_on_hold_flag = 'N' and
        g_gapless_flag='Y' and p_event_status_code<>'I') then
   -- set the following event on_hold to 'N'

     SELECT event_status_code,  event_number     BULK COLLECT
       INTO g_gapless_array_event_status, g_gapless_event_number
       FROM xla_events
      Where entity_id            = g_entity_id
            and event_number> p_event_number
	    and application_id = p_application_id -- 8967771
      Order by event_number;

     l_temp_event_number:=p_event_number+1;
     For j in 1..g_gapless_event_number.COUNT loop
       if(g_gapless_event_number(j)=l_temp_event_number
                      and g_gapless_array_event_status(j)<>'I') then
         l_temp_event_number:=l_temp_event_number+1;
       else
         exit;
       end if;
     end loop;
     --l_temp_event_number is the next gap
     -- update the on_hold_flag of event between l_array_event_number(i)
     -- and --l_temp_event_number+1

     update xla_events
        set on_hold_flag='N'
      where entity_id=p_entity_id
            and event_number >p_event_number
            and event_number <l_temp_event_number+1
	    and application_id = p_application_id -- 8967771
	    ;

   end if;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure add_entity_event'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'return value:'||to_char(l_event_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;
   RETURN l_event_id;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.add_event (fn)');
END add_entity_event;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE reset_cache IS
l_dummy_class_tbl               t_array_event_class;
l_dummy_type_tbl                t_array_event_type;
l_dummy_entity_tbl              t_array_entity_type;
l_dummy_tbl                     t_parameter_tbl;
l_source_info                   xla_events_pub_pkg.t_event_source_info;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reset_cache';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure reset_cache'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;


   g_entity_id                := NULL;
   g_entity_type_code         := NULL;
   g_valuation_method         := NULL;

   g_max_event_number         := 0;
   g_application_id           := NULL;
   g_action                   := NULL;
   g_gapless_flag             :='N';

   --
   -- Clear all cache but the event status which is static
   --
   g_entity_type_code_tbl     := l_dummy_entity_tbl              ;
   g_event_class_code_tbl     := l_dummy_class_tbl               ;
   g_event_type_code_tbl      := l_dummy_type_tbl                ;
   g_ledger_status_tbl.delete;
   g_source_info              := l_source_info;
--   g_context                  := C_CONTEXT_EVENTAPI;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of reset_cache'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.reset_cache');
END reset_cache;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE set_context
   (p_context                      IN  VARCHAR2) IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.set_context';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure set_context'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;
   g_context := p_context;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure set_context'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.set_context');
END set_context;


--=============================================================================
--
--
--
--=============================================================================

PROCEDURE delete_je IS
l_log_module                      VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_je';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure DELETE_JE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   -- shall we join to xla_events to get only the event with status D or I?
   -- good: reduce the event_id that are selected
   -- bad:  need to join to xla_events table
   DELETE FROM xla_accounting_errors
      WHERE event_id IN
               (SELECT xeg.event_id FROM xla_events_int_gt xeg, xla_events xe
                 WHERE xeg.event_id = xe.event_id
		   AND xe.application_id = g_application_id -- 8967771
                   AND xe.event_status_code in ('D', 'I'));

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of errors deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

-- Bug 5529420
DELETE FROM xla_distribution_links
    WHERE application_id= g_application_id and ae_header_id IN
            (SELECT xh.ae_header_id
               FROM xla_events_int_gt        xeg,
                    xla_ae_headers           xh
               WHERE
               xh.event_id = xeg.event_id AND
               xh.application_id = g_application_id AND
               xh.accounting_entry_status_code IN ('D','R','RELATED_EVENT_ERROR','I','N')
            );


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of distribution links deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

      --
      -- Delete from xla_ae_segment_values
      --

   DELETE FROM xla_ae_segment_values
      WHERE ae_header_id IN
               (SELECT xah.ae_header_id
                  FROM xla_events        xe
                      ,xla_ae_headers    xah
                      ,xla_events_int_gt     xeg
                 WHERE xe.application_id = xah.application_id
		   AND xe.application_id = g_application_id -- 8967771
                   AND xah.event_id      = xe.event_id
                   AND xeg.event_id      = xe.event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of segment values deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

      --
      -- Delete from xla_ae_line_acs
      --

       DELETE FROM xla_ae_line_acs
       WHERE ae_header_id IN
               (SELECT xah.ae_header_id
                    FROM xla_events        xe
                        ,xla_ae_headers    xah
                        ,xla_events_int_gt xeg
                 WHERE xe.application_id = xah.application_id
		   AND xe.application_id = g_application_id -- 8967771
                   AND xah.event_id      = xe.event_id
                   AND xeg.event_id      = xe.event_id);

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
              (SELECT xah.ae_header_id
                    FROM xla_events        xe
                        ,xla_ae_headers    xah
                        ,xla_events_int_gt xeg
                 WHERE xe.application_id = xah.application_id
		   AND xe.application_id = g_application_id -- 8967771
                   AND xah.event_id      = xe.event_id
                   AND xeg.event_id      = xe.event_id);


      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of header acs deleted = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      --
      -- Delete from xla_ae_line_details
      --

   DELETE FROM xla_ae_line_details
      WHERE ae_header_id IN
               (SELECT xah.ae_header_id
                  FROM xla_events        xe
                      ,xla_ae_headers    xah
                      ,xla_events_int_gt     xeg
                 WHERE xe.application_id = xah.application_id
		   AND xe.application_id = g_application_id -- 8967771
                   AND xah.event_id      = xe.event_id
                   AND xeg.event_id      = xe.event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of line details deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

      --
      -- Delete from xla_ae_header_details
      --

   DELETE FROM xla_ae_header_details
      WHERE ae_header_id IN
               (SELECT xah.ae_header_id
                  FROM xla_events        xe
                      ,xla_ae_headers    xah
                      ,xla_events_int_gt     xeg
                 WHERE xe.application_id = xah.application_id
		   AND xe.application_id = g_application_id -- 8967771
                   AND xah.event_id      = xe.event_id
                   AND xeg.event_id      = xe.event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of header details deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

      --
      -- Delete from xla_ae_lines
      --

   DELETE FROM xla_ae_lines
      WHERE application_id  = g_application_id
        AND ae_header_id IN
               (SELECT xah.ae_header_id
                  FROM xla_events        xe
                      ,xla_ae_headers    xah
                      ,xla_events_int_gt     xeg
                 WHERE xe.application_id = xah.application_id
                   AND xe.application_id = g_application_id
                   AND xah.application_id = g_application_id
                   AND xah.event_id      = xe.event_id
                   AND xeg.event_id      = xe.event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of ae lines deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

      --
      -- Delete from xla_ae_headers
      --

   DELETE FROM xla_ae_headers
      WHERE application_id  = g_application_id
        AND ae_header_id IN
               (SELECT xah.ae_header_id
                  FROM xla_events        xe
                      ,xla_ae_headers    xah
                      ,xla_events_int_gt     xeg
                 WHERE xe.application_id = xah.application_id
		   AND xe.application_id = g_application_id -- 8967771
                   AND xah.event_id      = xe.event_id
                   AND xeg.event_id      = xe.event_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of ae headers deleted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure DELETE_JE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_events_pkg.delete_je');
END delete_je;




--=============================================================================
--
--
--
--=============================================================================

FUNCTION period_close
   (p_period_name                 IN VARCHAR2
   ,p_ledger_id                   IN NUMBER
   ,p_mode                        IN VARCHAR2)
RETURN VARCHAR2 IS
   l_period_start_date               DATE;
   l_period_end_date                 DATE;
   l_unprocessed                     NUMBER(2) := 0;
   l_log_module                      VARCHAR2(240);
   l_request_id                      NUMBER(10);
   l_check_events                    NUMBER(2) := 0;
   l_primary_ledger_id               GL_LEDGERS.ledger_id%TYPE;
   l_ledger_id                       GL_LEDGERS.ledger_id%TYPE;
   l_user_id                         NUMBER;
   l_resp_id                         NUMBER;
   l_resp_appl_id                    NUMBER;
   l_xml_output                      BOOLEAN;
   l_iso_language                    FND_LANGUAGES.iso_language%TYPE;
   l_iso_territory                   FND_LANGUAGES.iso_territory%TYPE;
   l_user_je_source_name             XLA_LOOKUPS.meaning%TYPE;
   l_ledger_name                     GL_LEDGERS.name%TYPE;
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.period_close';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of function period_close'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_period_name = '       ||
         p_period_name, C_LEVEL_STATEMENT, l_log_module);
      trace('p_ledger_id = '||
         to_char(p_ledger_id), C_LEVEL_STATEMENT, l_log_module);
      trace('p_mode = '||
         p_mode, C_LEVEL_STATEMENT, l_log_module);
   END IF;


   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security implementation
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(602);

   l_unprocessed := xla_period_close_exp_pkg.check_period_close
                                           (101
                                           ,p_period_name
                                           ,p_ledger_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('l_unprocessed = '       ||
         to_char(l_unprocessed), C_LEVEL_STATEMENT, l_log_module);
   END IF;

   IF l_unprocessed > 0 THEN

      IF p_mode = 'W' THEN

         DELETE FROM xla_transfer_ledgers
         WHERE group_id IN
               (SELECT group_id
                  FROM gl_je_batches
                 WHERE status = 'P'
                   AND default_period_name = p_period_name)
                   AND (primary_ledger_id is null OR
                        primary_ledger_id = p_ledger_id OR
                        secondary_ledger_id = p_ledger_id);

        BEGIN

            SELECT lower(iso_language),iso_territory
              INTO l_iso_language,l_iso_territory
              FROM FND_LANGUAGES
             WHERE language_code = USERENV('LANG');

            SELECT meaning
              INTO l_user_je_source_name
              FROM xla_lookups
             WHERE lookup_type = 'XLA_ADR_SIDE'
               AND lookup_code = 'ALL';

            SELECT name
              INTO l_ledger_name
              FROM gl_ledgers
             WHERE ledger_id = p_ledger_id;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                  NULL;
           WHEN OTHERS THEN
                  RAISE;
        END;

        l_xml_output := fnd_request.add_layout('XLA'
                                             ,'XLAPEXRPT'
                                             ,l_iso_language
                                             ,l_iso_territory
                                             ,'PDF');

        l_request_id := fnd_request.submit_request
                        (application     => 'XLA'
                        ,program         => 'XLAPEXRPT'
                        ,description     => NULL
                        ,start_time      => NULL
                        ,sub_request     => FALSE
                        ,argument1       => 101
                        ,argument2       => l_user_je_source_name
                        ,argument3       => p_ledger_id
                        ,argument4       => l_ledger_name
                        ,argument5       => p_period_name
                        ,argument6       => p_period_name
                        ,argument7       => NULL
                        ,argument8       => NULL
                        ,argument9       => NULL
                        ,argument10      => NULL
                        ,argument11      => NULL
                        ,argument12      => NULL
                        ,argument13      => 'W');

        commit;   -- commit is mandatory after fnd_request.submit_request

        IF l_request_id = 0 THEN
           xla_exceptions_pkg.raise_message
              (p_appli_s_name   => 'XLA'
              ,p_msg_name       => 'XLA_REP_TECHNICAL_ERROR'
              ,p_token_1        => 'APPLICATION_NAME'
              ,p_value_1        => 'SLA');
        END IF;

        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace('Concurrent request submitted'|| to_char(l_request_id),
                  C_LEVEL_STATEMENT,l_log_module);
        END IF;

    END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
       ( p_msg      => 'END of functon period_close'
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
    END IF;
-- 9038422 Even though there are unaccounted events, no Notification will be sent.
--    RETURN 'WARNING';    --   Notification with Warning will be sent.
  END IF;

  RETURN 'SUCCESS';    -- No Notification.

EXCEPTION
     WHEN XLA_EXCEPTIONS_PKG.application_exception THEN
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace('End of function Period Close with error', C_LEVEL_STATEMENT,
                 l_log_module);
        END IF;
        RETURN 'ERROR';     --   Notification with Error will be sent.
END period_close;

--=============================================================================
--
-- Private Function to Get the application name for a given application id
--
--=============================================================================

FUNCTION get_application_name
   (p_application_id            IN NUMBER)
RETURN VARCHAR2 IS
    l_log_module                      VARCHAR2(240);
    l_application_name                FND_APPLICATION_TL.application_name%TYPE;

BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_application_name';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of get_application_name'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;


  SELECT  fat.application_name
    INTO  l_application_name
    FROM  fnd_application_tl fat
  WHERE  fat.application_id = p_application_id
    AND  fat.language = nvl(USERENV('LANG'),fat.language);


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'get_application_name'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  RETURN l_application_name;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace('End of Get Application name', C_LEVEL_STATEMENT,l_log_module);
        END IF;
        RETURN l_application_name;
END get_application_name;


--=============================================================================
--
-- Private Function to Get the ledger associated with a ledger id
--
--=============================================================================

FUNCTION get_ledger_name
   (p_ledger_id            IN NUMBER)
RETURN VARCHAR2 IS
    l_log_module                      VARCHAR2(240);
    l_ledger_name                     VARCHAR2(30);

BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_ledger_name';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of get_ledger_name'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

    SELECT name
     INTO l_ledger_name
     FROM gl_ledgers
    WHERE ledger_id = p_ledger_id;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of get_ledger_name'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  RETURN l_ledger_name;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace('End of Get ledger name', C_LEVEL_STATEMENT,l_log_module);
        END IF;
        RETURN l_ledger_name;
END get_ledger_name;

FUNCTION period_close
   (p_application_id              IN NUMBER
   ,p_ledger_id                   IN NUMBER
   ,p_period_name                 IN VARCHAR2)
RETURN VARCHAR2 IS
   l_period_start_date               DATE;
   l_period_end_date                 DATE;
   l_unprocessed                     NUMBER(1) := 0;
   l_log_module                      VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.period_close';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of function period_close for Subledger Uptake'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('p_application_id = '       ||
         to_char(p_application_id), C_LEVEL_STATEMENT, l_log_module);
      trace('p_ledger_id = '||
         to_char(p_ledger_id), C_LEVEL_STATEMENT, l_log_module);
      trace('p_period_name = '||
         p_period_name, C_LEVEL_STATEMENT, l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Following sets the Security Context for the execution. This enables the
   -- event API to respect the transaction security implementation
   ----------------------------------------------------------------------------
   xla_security_pkg.set_security_context(p_application_id);
-- 4949921
   l_unprocessed := xla_period_close_exp_pkg.check_period_close
                                           (p_application_id
                                           ,p_period_name
                                           ,p_ledger_id);

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('l_unprocessed = '       ||
         to_char(l_unprocessed), C_LEVEL_STATEMENT, l_log_module);
   END IF;

 IF l_unprocessed > 0 THEN

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
       ( p_msg      => 'END of function period close for Subledger Uptake'
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
    END IF;

    RETURN 'FALSE';
 ELSE

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
       ( p_msg      => 'END of function period close for Subledger Uptake'
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
    END IF;

    RETURN 'TRUE';
 END IF;

EXCEPTION
     WHEN OTHERS THEN
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace('End of function Period Close for Subledger Uptake with error'
              ,C_LEVEL_STATEMENT
              ,l_log_module);
        END IF;
        RETURN 'ERROR';
END period_close;

--=============================================================================
--          *******************  Initialization  *********************
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
-- Following .............
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
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

   initialize;

END xla_events_pkg;

/
