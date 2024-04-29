--------------------------------------------------------
--  DDL for Package XLA_00140_AAD_S_000002_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_00140_AAD_S_000002_PKG" AS
--
/*======================================================================+
|                Copyright (c) 1997 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| Package Name                                                          |
|     XLA_00140_AAD_S_000002_PKG                                        |
|                                                                       |
| DESCRIPTION                                                           |
|     Package generated From Product Accounting Definition              |
|      Name    : Assets Standard Accounting                             |
|      Code    : FA_STANDARD_ACCOUNTING                                 |
|      Owner   : PRODUCT                                                |
|      Version :                                                        |
|      AMB Context Code: DEFAULT                                        |
| HISTORY                                                               |
|     Generated at 30-08-2013 at 12:08:55 by user ANONYMOUS             |
+=======================================================================*/
--
--
FUNCTION GetMeaning (
  p_flex_value_set_id               IN INTEGER
, p_flex_value                      IN VARCHAR2
, p_source_code                     IN VARCHAR2
, p_source_type_code                IN VARCHAR2
, p_source_application_id           IN INTEGER
)
RETURN VARCHAR2
;

FUNCTION CreateJournalEntries(
        p_application_id         IN NUMBER
      , p_base_ledger_id         IN NUMBER
      , p_pad_start_date         IN DATE
      , p_pad_end_date           IN DATE
      , p_primary_ledger_id      IN NUMBER)
RETURN NUMBER;
--
--
END XLA_00140_AAD_S_000002_PKG;
--

/
