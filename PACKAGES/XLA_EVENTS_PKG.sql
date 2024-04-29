--------------------------------------------------------
--  DDL for Package XLA_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EVENTS_PKG" AUTHID CURRENT_USER AS
-- $Header: xlaevevt.pkh 120.31 2006/05/30 16:50:47 wychan ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlaevevt.pkh                                                            |
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
|       - the APIs do not execute any COMMIT or ROLLBACK.                    |
|                                                                            |
| HISTORY                                                                    |
|    08-Feb-01 G. Gu           Created                                       |
|    10-Mar-01 P. Labrevois    Reviewed                                      |
|    17-Mar-01 P. Labrevois    Added array create_event                      |
|    13-Sep-01 P. Labrevois    Added 2nd array create_event                  |
|    08-Feb-02 S. Singhania    Reviewed and performed major changes          |
|    10-Feb-02 S. Singhania    Made changes in APIs to handle 'Transaction   |
|                                Number' (new column added in xla_entities)  |
|    13-Feb-02 S. Singhania    Made changes in APIs to handle 'Event Number' |
|    18-Feb-02 S. Singhania    Added specification for 'Initialize'          |
|    05-Apr-02 S. Singhania    Removed the not required, redundant APIs      |
|    19-Apr-02 S. Singhania    Added seperate API to update transaction      |
|                                number.                                     |
|    06-May-02 S. Singhania    Added "ledger_id" parameter in the bulk API   |
|                                "create_entity_event"                       |
|    31-May-02 S. Singhania    Renamed 'create_entity_event' API to          |
|                                'create_bulk_events'                        |
|    13-Jun-02 S. Singhania    Added 'update_event_status_bulk' API to be    |
|                                used by Accounting Program                  |
|    09-Sep-02 S. Singhania    Modified signature of 'create_bulk_events'.   |
|                                Bug # 2530796                               |
|    08-Nov-02 S. Singhania    Included specifications for 'get_entity_id'   |
|                                API for 'document mode' Accounting Program  |
|    10-Jul-03 S. Singhania    Added new APIs for MANUAL events (2899700)    |
|                                - UPDATE_MANUAL_EVENT                       |
|                                - CREATE_MANUAL_EVENT                       |
|                                - DELETE_PROCESSED_EVENT                    |
|    04-Sep-03 S. Singhania    Added parameter p_source_application_id to the|
|                                CREATE_BULK_EVENTS API                      |
|    23-Jun-04 W. Shen         New API delete_entity to delete entities      |
|                                from xla_transaction_entities(bug 3316535)  |
|    23-OCT-04 W. Shen         New API to delete/update/create event in bulk |
|    4-Apr-05  W. Shen         Add Transaction_date to create_event and      |
|                                create_manual_event API                     |
|    20-Apr-05 S. Singhania    Bug 4312353. Modified signature of routines in|
|                                to reflect the change in the way we handle  |
|                                valuation method different from other       |
|                                security columns.                           |
|    02-May-05 V. Kumar        Removed function create_bulk_events,          |
|                              Bug # 4323140                                 |
+===========================================================================*/

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------

--C_CONTEXT_EVENTAPI               CONSTANT VARCHAR2(1)  := 'A';
--C_CONTEXT_POSTING                CONSTANT VARCHAR2(1)  := 'P';
--C_CONTEXT_PURGE                  CONSTANT VARCHAR2(1)  := 'P';

C_INTERNAL_UNPROCESSED           CONSTANT VARCHAR2(1)  := 'U';
C_INTERNAL_DRAFT                 CONSTANT VARCHAR2(1)  := 'D';
C_INTERNAL_FINAL                 CONSTANT VARCHAR2(1)  := 'P';
C_INTERNAL_ERROR                 CONSTANT VARCHAR2(1)  := 'E';
C_INTERNAL_INVALID               CONSTANT VARCHAR2(1)  := 'I';


-------------------------------------------------------------------------------
-- Misc. routines
-------------------------------------------------------------------------------

PROCEDURE initialize;

-------------------------------------------------------------------------------
-- Event creation routines
-------------------------------------------------------------------------------

FUNCTION create_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_type_code              IN  VARCHAR2
   ,p_event_date                   IN  DATE
   ,p_event_status_code            IN  VARCHAR2
   ,p_event_number                 IN  INTEGER     DEFAULT NULL
   ,p_transaction_date             IN  DATE        DEFAULT NULL
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info DEFAULT NULL
   ,p_budgetary_control_flag       IN  VARCHAR2)
RETURN INTEGER;

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
RETURN INTEGER;

PROCEDURE create_bulk_events
   (p_source_application_id        IN  INTEGER     DEFAULT NULL
   ,p_application_id               IN  INTEGER
   ,p_legal_entity_id              IN  INTEGER     DEFAULT NULL
   ,p_ledger_id                    IN  INTEGER
   ,p_entity_type_code             IN  VARCHAR2);


-------------------------------------------------------------------------------
-- Event updation routines
-------------------------------------------------------------------------------

PROCEDURE update_event_status
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2   DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2   DEFAULT NULL
   ,p_event_date                   IN  DATE       DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2);

PROCEDURE update_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  INTEGER
   ,p_event_type_code              IN  VARCHAR2   DEFAULT NULL
   ,p_event_date                   IN  DATE       DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2   DEFAULT NULL
   ,p_transaction_date             IN  DATE       DEFAULT NULL
   ,p_event_number                 IN  INTEGER    DEFAULT NULL
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info DEFAULT NULL
   ,p_overwrite_event_num          IN  VARCHAR2   DEFAULT 'N'
   ,p_overwrite_ref_info           IN  VARCHAR2   DEFAULT 'N');

PROCEDURE update_manual_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_event_id                     IN  INTEGER
   ,p_event_type_code              IN  VARCHAR2   DEFAULT NULL
   ,p_event_date                   IN  DATE       DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2   DEFAULT NULL
   ,p_process_status_code          IN  VARCHAR2   DEFAULT NULL
   ,p_event_number                 IN  INTEGER    DEFAULT NULL
   ,p_reference_info               IN  xla_events_pub_pkg.t_event_reference_info DEFAULT NULL
   ,p_overwrite_event_num          IN  VARCHAR2   DEFAULT 'N'
   ,p_overwrite_ref_info           IN  VARCHAR2   DEFAULT 'N');

PROCEDURE update_bulk_event_statuses
   (p_application_id               IN  INTEGER);

-------------------------------------------------------------------------------
-- Event deletion routines
-------------------------------------------------------------------------------

PROCEDURE delete_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  INTEGER);

PROCEDURE delete_processed_event
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_event_id                     IN  INTEGER);

FUNCTION delete_events
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2   DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2   DEFAULT NULL
   ,p_event_date                   IN  DATE       DEFAULT NULL)
RETURN INTEGER;

-- return 1 if there is event for the entity, return 0 if success
FUNCTION delete_entity
   (p_source_info                  IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2)
RETURN INTEGER;

PROCEDURE delete_bulk_events
   (p_application_id               IN  INTEGER);

-------------------------------------------------------------------------------
-- Entity purge routines
-------------------------------------------------------------------------------

PROCEDURE purge_entity
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info);

-------------------------------------------------------------------------------
-- Event information routines
-------------------------------------------------------------------------------

FUNCTION get_event_info
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  INTEGER)
RETURN xla_events_pub_pkg.t_event_info;

FUNCTION get_event_status
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  INTEGER)
RETURN VARCHAR2;

FUNCTION event_exists
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2     DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2     DEFAULT NULL
   ,p_event_date                   IN  DATE         DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2     DEFAULT NULL
   ,p_event_number                 IN  INTEGER      DEFAULT NULL
   ,p_event_id                     IN  PLS_INTEGER  DEFAULT NULL)
RETURN BOOLEAN;

FUNCTION get_array_event_info
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_class_code             IN  VARCHAR2   DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2   DEFAULT NULL
   ,p_event_date                   IN  DATE       DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2   DEFAULT NULL)
RETURN xla_events_pub_pkg.t_array_event_info;

-------------------------------------------------------------------------------
-- Entity update routines
-------------------------------------------------------------------------------

PROCEDURE update_transaction_number
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_transaction_number           IN  VARCHAR2
   ,p_event_id                     IN  PLS_INTEGER  DEFAULT NULL);

-------------------------------------------------------------------------------
-- Entity information routines
-------------------------------------------------------------------------------

FUNCTION  get_entity_id
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_valuation_method             IN  VARCHAR2
   ,p_event_id                     IN  PLS_INTEGER  DEFAULT NULL)
RETURN INTEGER;

FUNCTION period_close
        (p_period_name IN VARCHAR2
         ,p_ledger_id  IN NUMBER
         ,p_mode       IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION period_close
        (p_application_id       IN NUMBER
        ,p_ledger_id            IN NUMBER
        ,p_period_name          IN VARCHAR2)
RETURN VARCHAR2;


END xla_events_pkg;
 

/
