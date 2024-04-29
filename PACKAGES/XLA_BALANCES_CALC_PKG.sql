--------------------------------------------------------
--  DDL for Package XLA_BALANCES_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_BALANCES_CALC_PKG" AUTHID CURRENT_USER as
/* $Header: xlabacalc.pkh 120.0.12010000.5 2010/04/14 09:22:49 karamakr noship $ */

TYPE t_array_varchar   IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

--
--
FUNCTION calculate_balances ( p_application_id        IN   INTEGER
                            , p_ledger_id             IN   INTEGER
                            , p_entity_id             IN   INTEGER
                            , p_event_id              IN   INTEGER
                            , p_ae_header_id          IN   INTEGER
                            , p_ae_line_num           IN   INTEGER
                            , p_request_id            IN   INTEGER
                            , p_accounting_batch_id   IN   INTEGER
                            , p_update_mode           IN   VARCHAR2
                            , p_execution_mode        IN   VARCHAR2
                            )
RETURN BOOLEAN;

PROCEDURE open_period_srs (
      p_errbuf                 OUT NOCOPY      VARCHAR2
    , p_retcode                OUT NOCOPY      NUMBER
    , p_application_id         IN              NUMBER
	, p_ledger_id              IN              NUMBER
    , p_period_name            IN              VARCHAR2
   );

PROCEDURE massive_update_srs (
      p_errbuf                OUT NOCOPY      VARCHAR2,
      p_retcode               OUT NOCOPY      NUMBER,
      p_application_id        IN              NUMBER,
      p_ledger_id             IN              NUMBER,
      p_accounting_batch_id   IN              NUMBER,
	  p_update_mode           IN              VARCHAR2
   );

FUNCTION massive_update (
      p_application_id        IN   INTEGER
    , p_ledger_id             IN   INTEGER
    , p_entity_id             IN   INTEGER
    , p_event_id              IN   INTEGER
    , p_request_id            IN   INTEGER
    , p_accounting_batch_id   IN   INTEGER
    , p_update_mode           IN   VARCHAR2
    , p_execution_mode        IN   VARCHAR2
   )
RETURN BOOLEAN;

FUNCTION single_update
  (
    p_application_id          IN INTEGER
   ,p_ae_header_id            IN INTEGER
   ,p_ae_line_num             IN INTEGER
   ,p_update_mode             IN VARCHAR2
  ) RETURN BOOLEAN;

FUNCTION lock_bal_concurrency_control (
      p_application_id        IN   INTEGER
	, p_ledger_id             IN   INTEGER
	, p_entity_id             IN   INTEGER
	, p_event_id              IN   INTEGER
	, p_ae_header_id          IN   INTEGER
	, p_ae_line_num           IN   INTEGER
	, p_request_id            IN   INTEGER
	, p_accounting_batch_id   IN   INTEGER
	, p_execution_mode        IN   VARCHAR2
	, p_concurrency_class     IN   VARCHAR2
   )
RETURN BOOLEAN;
--
--
END xla_balances_calc_pkg;

/
