--------------------------------------------------------
--  DDL for Package XLA_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_BALANCES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlabacom.pkh 120.15.12010000.4 2008/12/24 17:11:18 svellani ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_balances_pkg                                                   |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Balance Calculation Package                                    |
|                                                                       |
| HISTORY                                                               |
|    27-AUG-02 A.Quaglia      Created                                   |
|    31-OCT-03 A.Quaglia      Bug3202694:                               |
|                             massive_update:                           |
|                                added p_entity_id                      |
|                                old, deprecated API maintained until   |
|                                uptake is done.                        |
|    26-NOV-03 A.Quaglia      Bug3264347:                               |
|                             massive_update_srs:                       |
|                                new param p_dummy                      |
|    29-JUL-04 A.Quaglia      Bug3202694:                               |
|                             massive_update:                           |
|                                removed deprecated API                 |
|                                                                       |
|                                                                       |
+======================================================================*/

TYPE t_array_varchar   IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;  -- bug 7441310

FUNCTION single_update
  (
    p_application_id          IN INTEGER
   ,p_ae_header_id            IN INTEGER
   ,p_ae_line_num             IN INTEGER
   ,p_update_mode             IN VARCHAR2
  ) RETURN BOOLEAN;


FUNCTION massive_update
  (
    p_application_id          IN INTEGER
   ,p_ledger_id               IN INTEGER
   ,p_entity_id               IN INTEGER
   ,p_event_id                IN INTEGER
   ,p_request_id              IN INTEGER
   ,p_accounting_batch_id     IN INTEGER
   ,p_update_mode             IN VARCHAR2
   ,p_execution_mode          IN VARCHAR2
  ) RETURN BOOLEAN;


FUNCTION massive_update_for_events(
   p_application_id           IN INTEGER) RETURN BOOLEAN;

PROCEDURE massive_update_srs
                        ( p_errbuf               OUT NOCOPY VARCHAR2
                         ,p_retcode              OUT NOCOPY NUMBER
                         ,p_application_id       IN         NUMBER
                         ,p_dummy                IN         VARCHAR2
                         ,p_ledger_id            IN         NUMBER
                         ,p_accounting_batch_id  IN         NUMBER
                         ,p_update_mode          IN         VARCHAR2
                        );





FUNCTION recreate
  ( p_application_id             IN INTEGER
   ,p_ledger_id                  IN INTEGER
   ,p_party_type_code            IN VARCHAR2
   ,p_party_id                   IN INTEGER
   ,p_party_site_id              IN INTEGER
   ,p_starting_period_name       IN VARCHAR2
   ,p_account_segment_value_low  IN VARCHAR2
   ,p_account_segment_value_high IN VARCHAR2
  ) RETURN BOOLEAN;

PROCEDURE recreate_srs
                     ( p_errbuf                     OUT NOCOPY VARCHAR2
                      ,p_retcode                    OUT NOCOPY NUMBER
                      ,p_application_id             IN         INTEGER
                      ,p_ledger_id                  IN         INTEGER
                      ,p_party_type_code            IN         VARCHAR2
                      ,p_party_id                   IN         INTEGER
                      ,p_party_site_id              IN         INTEGER
                      ,p_starting_period_name       IN         VARCHAR2
                      ,p_account_segment_value_low  IN         VARCHAR2
                      ,p_account_segment_value_high IN         VARCHAR2
                     );




FUNCTION synchronize
  ( p_chart_of_accounts_id       IN INTEGER
   ,p_account_segment_value      IN VARCHAR2
  ) RETURN BOOLEAN;


FUNCTION open_period
  ( p_ledger_id                  IN INTEGER
  ) RETURN BOOLEAN;

PROCEDURE open_period_srs
                        ( p_errbuf       OUT NOCOPY VARCHAR2
                         ,p_retcode      OUT NOCOPY NUMBER
                         ,p_ledger_id    IN         NUMBER
                        );


FUNCTION initialize
  ( p_application_id             IN INTEGER
   ,p_ledger_id                  IN INTEGER
   ,p_code_combination_id        IN INTEGER
   ,p_party_type_code            IN VARCHAR2
   ,p_party_id                   IN INTEGER
   ,p_party_site_id              IN INTEGER
   ,p_period_name                IN VARCHAR2
   ,p_new_beginning_balance_dr   IN NUMBER
   ,p_new_beginning_balance_cr   IN NUMBER
  ) RETURN BOOLEAN;


 FUNCTION open_period_event
   ( p_subscription_guid IN     raw
    ,p_event             IN OUT NOCOPY WF_EVENT_T)
 RETURN VARCHAR2;


END xla_balances_pkg;

/
