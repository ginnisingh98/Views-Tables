--------------------------------------------------------
--  DDL for Package XLA_HIST_LEDGER_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_HIST_LEDGER_UPG_PKG" AUTHID CURRENT_USER AS
/* $Header: xlahupg.pkh 120.4.12010000.2 2010/01/03 07:59:13 vkasina ship $ */
/*======================================================================+
|             Copyright (c) 2000-2001 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_hist_ledger_upg_pkg                                            |
|                                                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    Description                                                        |
|                                                                       |
| HISTORY                                                               |
|    01-DEC-07  Kapil Kumar         Created                             |
|    02-JAN-10  Kapil Kumar         PHASE2 (redesign)                   |
|                                                                       |
+======================================================================*/



PROCEDURE upg_main
             (
	      p_errbuf                     OUT NOCOPY VARCHAR2
	     ,p_retcode                    OUT NOCOPY NUMBER
	     ,p_application_id             IN  NUMBER
	     ,p_primary_ledger_id          IN  NUMBER
             ,p_sec_alc_ledger_id          IN  NUMBER
	     ,p_rep_ledger_type            IN  VARCHAR2
	     ,p_mode                       IN  VARCHAR2
	     ,p_mode_check	           IN  VARCHAR2
	     ,p_start_date                 IN  DATE
             ,p_conversion_option          IN  VARCHAR2
             ,p_currency_conversion_type   IN  VARCHAR2
             ,p_currency_conversion_date   IN  DATE
	     ,p_batch_size                 IN  NUMBER
	     ,p_num_workers		   IN  NUMBER
             );



PROCEDURE validate_recovery_mode;


PROCEDURE validate_final_mode;


PROCEDURE retrieve_validate;


PROCEDURE populate_rates;

PROCEDURE insert_data(p_primary_ledger_id IN NUMBER,
		      p_sec_alc_ledger_id IN NUMBER,
		      p_application_id    IN NUMBER,
		      p_relationship_id   IN NUMBER,
		      p_upgrade_id        IN NUMBER,
		      p_script_name       IN VARCHAR2,
		      p_batch_size        IN NUMBER,
		      p_num_workers       IN NUMBER);

PROCEDURE historic_worker
             (
	      p_errbuf                     OUT NOCOPY VARCHAR2
	     ,p_retcode                    OUT NOCOPY NUMBER
	     ,p_batch_size                 IN  NUMBER
	     ,p_worker_id                  IN  NUMBER
	     ,p_num_workers                IN  NUMBER
	     ,p_script_name                IN  VARCHAR2
	     ,p_application_id             IN  NUMBER
	     ,p_primary_ledger_id          IN  NUMBER
             ,p_sec_alc_ledger_id          IN  NUMBER
             ,p_ugprade_id                 IN  NUMBER
	     ,p_relationship_id		   IN  NUMBER
	     ,p_ccid_map                   IN  VARCHAR2
             ,p_calendar_convert           IN  VARCHAR2
             ,p_dynamic_flag               IN  VARCHAR2
	     ,p_mapping_rel_id             IN  NUMBER
	     ,p_coa_map_name               IN  VARCHAR2
             );

END xla_hist_ledger_upg_pkg;

/
