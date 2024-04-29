--------------------------------------------------------
--  DDL for Package XLA_ACCOUNTING_CACHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCOUNTING_CACHE_PKG" AUTHID CURRENT_USER AS
-- $Header: xlaapche.pkh 120.14.12010000.4 2009/05/07 06:24:45 svellani ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlaapche.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_accounting_cache_pkg                                                |
|                                                                            |
| DESCRIPTION                                                                |
|    This package is defined to cache the frequently used data during        |
|    execution of Accounting Program. This is to improve performance and     |
|    provide modular structure and lean interaction between Accounting Engine|
|    and Accounting Program.                                                 |
|                                                                            |
|    Note: the APIs do not excute COMMIT or ROLLBACK.                        |
|                                                                            |
| HISTORY                                                                    |
|    30-Oct-02  S. Singhania    Created                                      |
|    19-Dec-02  S. Singhania    Added specifications for set_process_cache   |
|    21-Feb-03  S. Singhania    Made changes for the new bulk approach of the|
|                                 accounting program                         |
|                                      - added 'p_max_event_date' param to   |
|                                           load_application_ledgers         |
|                                      - added procedure 'get_pad_info'      |
|    04-Apr-03  S. Singhania    Modified the specifications for:             |
|                                 - GetValueNum                              |
|                                 - GetValueDate                             |
|                                 - GetValueChar                             |
|    07-May-03  S. Singhania    Based on requirements from the 'Accounting   |
|                                 Engine' remodified the specifications for: |
|                                 - GetValueNum                              |
|                                 - GetValueDate                             |
|                                 - GetValueChar                             |
|                                 - load_application_ledgers                 |
|                                 - GetAlcLedgers                            |
|                               Renamed 'GetBaseLedgers' to 'GetLedgers'     |
|    16-Jul-03  S. Singhania    Added following APIs:                        |
|                                 - GetValueNum         (Overloaded)         |
|                                 - GetValueDate        (Overloaded)         |
|                                 - GetValueChar        (Overloaded)         |
|                                 - GetSessionValueChar                      |
|                                 - GetSessionValueChar (Overloaded)         |
|                                 - get_event_info                           |
|                               Modified specifications for:                 |
|                                 - GetValueChar                             |
|                                 - Get_PAD_info                             |
|    11-Sep-03  S. Singhania    Made changes to cache je_category (# 3109690)|
|                                 - Added API GET_JE_CATEGORY                |
|    20-Sep-04  S. Singhania    Added the following to support bulk changes  |
|                                 in the accounting engine                   |
|                                 - Added types T_REC_PAD and T_ARRAY_PAD    |
|                                 - Added API GetArrayPad                    |
|    9-Mar-05   W. Shen         Add the function BuildLedgerArray and        |
|                                 GetLedgerArray to support the calculation  |
|                                 of rounding                                |
|    26-May-05   W. Shen         Add the function GetCurrencyMau             |
+===========================================================================*/

TYPE t_array_ledger_id IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_array_num       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_array_varchar   IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
--8238617
 g_primary_ledger_currency  VARCHAR2(30):=null;

TYPE t_array_ledger_attrs IS RECORD (
  array_ledger_id              t_array_num
 ,array_ledger_type            t_array_varchar
 ,array_ledger_currency_code   t_array_varchar
 ,array_rounding_rule_code     t_array_varchar
 ,array_rounding_offset        t_array_num
 ,array_mau                    t_array_num
 ,array_default_rate_type      t_array_varchar
 ,array_inhert_type_flag       t_array_varchar
 ,array_max_roll_date          t_array_num
);


g_reversal_error               BOOLEAN DEFAULT FALSE;    --bug 7253269
g_hist_bflow_error_exists      BOOLEAN DEFAULT FALSE;    -- This line belongs to historic upgraded data.


-------------------------------------------------------------------------------
-- Following sturctures are used for caching PADs
-------------------------------------------------------------------------------
TYPE t_rec_pad IS RECORD
   (acctg_method_rule_id               NUMBER
   ,amb_context_code                   VARCHAR2(30)
   ,product_rule_owner                 VARCHAR2(1)
   ,product_rule_code                  VARCHAR2(30)
   ,ledger_product_rule_name           VARCHAR2(80)
   ,session_product_rule_name          VARCHAR2(80)
   ,pad_package_name                   VARCHAR2(80)
   ,compile_status_code                VARCHAR2(1)
   ,start_date_active                  DATE
   ,end_date_active                    DATE);

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_array_pad IS TABLE OF t_rec_pad INDEX BY BINARY_INTEGER;


PROCEDURE load_application_ledgers
       (p_application_id             IN  INTEGER
       ,p_event_ledger_id            IN  INTEGER -- ledger id stamped on events
       ,p_max_event_date             IN  DATE        DEFAULT TRUNC(sysdate));

PROCEDURE get_pad_info
       (p_ledger_id                  IN  NUMBER -- primary/secondary ledger id
       ,p_event_date                 IN  DATE
       ,p_pad_owner                  OUT NOCOPY VARCHAR2
       ,p_pad_code                   OUT NOCOPY VARCHAR2
       ,p_ledger_pad_name            OUT NOCOPY VARCHAR2
       ,p_session_pad_name           OUT NOCOPY VARCHAR2
       ,p_pad_compile_status         OUT NOCOPY VARCHAR2
       ,p_pad_package_name           OUT NOCOPY VARCHAR2);

FUNCTION GetArrayPad
       (p_ledger_id                  IN  NUMBER -- primary/secondary ledger id
       ,p_max_event_date             IN  DATE
       ,p_min_event_date             IN  DATE)
RETURN t_array_pad;

PROCEDURE get_event_info
        (p_ledger_id                  IN  NUMBER
        ,p_event_class_code           IN  VARCHAR2
        ,p_event_type_code            IN  VARCHAR2
        ,p_ledger_event_class_name    OUT NOCOPY VARCHAR2
        ,p_session_event_class_name   OUT NOCOPY VARCHAR2
        ,p_ledger_event_type_name     OUT NOCOPY VARCHAR2
        ,p_session_event_type_name    OUT NOCOPY VARCHAR2);

FUNCTION get_je_category
        (p_ledger_id                  IN  NUMBER
        ,p_event_class_code           IN  VARCHAR2)
RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- get system source values from accounting cache
-------------------------------------------------------------------------------

FUNCTION GetValueNum
       (p_source_code                IN VARCHAR2
       ,p_target_ledger_id           IN NUMBER)
RETURN NUMBER;

FUNCTION GetValueNum
       (p_source_code                IN VARCHAR2)
RETURN NUMBER;

FUNCTION GetValueDate
       (p_source_code                IN VARCHAR2
       ,p_target_ledger_id           IN NUMBER)
RETURN DATE;

FUNCTION GetValueDate
       (p_source_code                IN VARCHAR2)
RETURN DATE;

FUNCTION GetValueChar
       (p_source_code                IN VARCHAR2
       ,p_target_ledger_id           IN NUMBER)
RETURN VARCHAR2;

FUNCTION GetValueChar
       (p_source_code                IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetSessionValueChar
       (p_source_code                IN VARCHAR2
       ,p_target_ledger_id           IN NUMBER)
RETURN VARCHAR2;

FUNCTION GetSessionValueChar
       (p_source_code                IN VARCHAR2)
RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- Get base ledgers, alternate currency ledgers from accounting
-- cache
-------------------------------------------------------------------------------

FUNCTION GetAlcLedgers
       (p_primary_ledger_id          IN NUMBER )
RETURN t_array_ledger_id;

FUNCTION GetLedgers
RETURN t_array_ledger_id;

Procedure BuildLedgerArray
( p_array_ledger_attrs OUT NOCOPY t_array_ledger_attrs)
;
PROCEDURE GetLedgerArray
( p_array_ledger_attrs OUT NOCOPY t_array_ledger_attrs)
;

FUNCTION GetCurrencyMau(p_currency_code IN VARCHAR2) return NUMBER
;
END xla_accounting_cache_pkg;

/
