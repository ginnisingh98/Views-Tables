--------------------------------------------------------
--  DDL for Package Body XLA_HIST_LEDGER_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_HIST_LEDGER_UPG_PKG" AS
/* $Header: xlahupg.pkb 120.18.12010000.4 2010/04/08 14:52:25 kapkumar ship $ */
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
|    01-DEC-07  Kapil Kumar                   PHASE 1                   |
|    02-JAN-10  Kapil Kumar                   PHASE 2 (redesign)        |
|    31-MAR-10  Kapil Kumar                   PHASE 2.1                 |
+======================================================================*/


--=============================================================================
--               *********** Global Variables **********
--=============================================================================

g_application_id                 NUMBER;                         -- concurrent program user input
g_primary_ledger_id              NUMBER;                         -- concurrent program user input
g_secondary_alc_ledger_id        NUMBER;                         -- concurrent program user input
g_start_date			 DATE;                           -- concurrent program user input
g_conversion_option		 VARCHAR2(10);                   -- concurrent program user input if secondary else derived
g_currency_conversion_type       VARCHAR2(100);                  -- concurrent program user input if secondary else derived
g_currency_conversion_date	 DATE;                           -- concurrent program user input if secondary else derived
g_validation_mode                VARCHAR2(20);                   -- concurrent program user input
g_batch_size                     NUMBER;                         -- concurrent program user input
g_num_workers		         NUMBER;                         -- concurrent program user input

g_sec_alc_end_date               DATE;                           -- derived value
g_sec_alc_min_acctng_batch_id    NUMBER;			 -- added by vgopiset
g_upgrade_id			 NUMBER;
g_relationship_id		 NUMBER;
g_script_name                    VARCHAR2(100);

g_ledger_category_code		 VARCHAR2(30);
g_primary_currency_code          VARCHAR2(15);
g_sec_alc_currency_code          VARCHAR2(15);
g_sec_alc_mau                    NUMBER;
g_sec_alc_precision		 NUMBER;
g_primary_slam                   VARCHAR2(300);
g_secondary_slam                 VARCHAR2(300);
g_secondary_slam_type            VARCHAR2(10);
g_primary_slam_type              VARCHAR2(10);
g_secondary_budget               VARCHAR2(300);
g_primary_budget                 VARCHAR2(300);
g_primary_aad			 VARCHAR2(30);
g_primary_aad_owner		 VARCHAR2(1);
g_secondary_aad			 VARCHAR2(30);
g_secondary_aad_owner		 VARCHAR2(1);
g_primary_coa      		 NUMBER;
g_secondary_coa    		 NUMBER;
g_mapping_relationship_id        NUMBER;
g_coa_mapping_name               VARCHAR2(50);
g_dynamic_inserts                VARCHAR2(10);
g_primary_cal_set_name           VARCHAR2(100);
g_primary_cal_per_type	         VARCHAR2(100);
g_primary_sec_alc_set_name       VARCHAR2(100);
g_primary_sec_alc_per_type       VARCHAR2(100);

g_untransferred_headers          NUMBER	    DEFAULT NULL;
g_alc_exists                     NUMBER     DEFAULT NULL;
g_rate_exists                    NUMBER     DEFAULT NULL;

TYPE workerList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_worker                        workerList;

g_ccid_map                       VARCHAR2(10);
g_calendar_convert               VARCHAR2(10);
g_dynamic_flag                   VARCHAR2(10);
g_mapping_rel_id                 NUMBER;
g_coa_map_name                   VARCHAR2(50);

g_currency_count                 NUMBER;
g_numerator		         NUMBER;
g_denominator                    NUMBER;
g_rate                           NUMBER;

g_failed_runs                    NUMBER;
g_success_runs			 NUMBER;
g_recovery_failed_runs           NUMBER;

g_validation_failed              EXCEPTION;
g_child_failed			 EXCEPTION;

g_error_text			 VARCHAR2(10000);



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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_hist_ledger_upg_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;


C_LOG_SIZE            CONSTANT NUMBER          := 2000;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE)
IS

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
         (p_location   => 'xla_hist_ledger_upg_pkg.trace');
END trace;



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
             )
IS

l_log_module                   VARCHAR2(240);
l_mode_meaning                 VARCHAR2(20);

BEGIN


	--EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
	--p_rep_ledger_type and p_mode_check are concurrent program dependency parameters only

	IF g_log_enabled THEN
	      l_log_module := C_DEFAULT_MODULE||'.upg_main';
   	END IF;


   	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'UPG_MAIN procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
	END IF;
   	fnd_file.put_line(fnd_file.log,'UPG_MAIN procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));


        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			      trace
				 (p_msg      => 'p_application_id = ' || p_application_id
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			      trace
				 (p_msg      => 'p_primary_ledger_id = ' || p_primary_ledger_id
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			      trace
				 (p_msg      => 'p_sec_alc_ledger_id = ' || p_sec_alc_ledger_id
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			      trace
				 (p_msg      => 'p_start_date = ' || to_char(p_start_date, 'DD-MON-RRRR')
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			      trace
				 (p_msg      => 'p_conversion_option = ' || p_conversion_option
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			      trace
				 (p_msg      => 'p_currency_conversion_type =  ' || p_currency_conversion_type
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			      trace
				 (p_msg      => 'p_currency_conversion_date = ' || to_char(p_currency_conversion_date, 'DD-MON-RRRR')
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
                               trace
				 (p_msg      => 'p_mode =  ' || p_mode
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			      trace
				 (p_msg      => 'p_batch_size = ' || p_batch_size
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			      trace
				 (p_msg      => 'p_num_workers = ' || p_num_workers
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);

	END IF;

        g_application_id := p_application_id;
	g_primary_ledger_id := p_primary_ledger_id;
	g_secondary_alc_ledger_id  := p_sec_alc_ledger_id;

	--g_start_date  := fnd_date.canonical_to_date(p_start_date);
	--caused incorrect conversion when special value set used instead of FND_STARDARD_DATE
        --g_start_date  := to_date(p_start_date, 'DD-MON-RRRR');
	g_start_date := p_start_date;

	g_conversion_option := 	p_conversion_option;
	g_currency_conversion_type :=  p_currency_conversion_type;

	--g_currency_conversion_date := fnd_date.canonical_to_date(p_currency_conversion_date);
	--caused incorrect conversion when special value set used instead of FND_STARDARD_DATE
	--g_currency_conversion_date  := to_date(g_currency_conversion_date, 'DD-MON-RRRR');
        g_currency_conversion_date  := p_currency_conversion_date;


	g_validation_mode := p_mode;
	g_batch_size := NVL(p_batch_size , 1000);
        g_num_workers := NVL(p_num_workers, 1);

	-- possible status during run: PHASE-RATE, PHASE-DATA-START, SUCCESS
        -- possible committed status in xla_historic_control: no row, PHASE-DATA-START, SUCCESS
	-- possible p_mode values: V (validation), F (final), R (recovery)

	-- added this to show meaning in the logfile rather than the code.
	SELECT meaning
	  INTO l_mode_meaning
	  FROM xla_lookups
	 WHERE lookup_type = 'XLA_HIST_UPG_MODE'
	   AND lookup_code = p_mode ;



	IF p_mode = 'V' THEN        --validation mode

		-- no commit in this mode
		-- all inserts (rates/historic control) are rolled back

		retrieve_validate();
		validate_final_mode();

		INSERT INTO xla_historic_control(primary_ledger,
						secondary_alc_ledger,
						application_id,
						upgrade_id,
						relationship_id,
						script_name,
						start_date,
						end_date,
						batch_size,
						num_workers,
						status,
						ledger_category_code,
						last_update_date,
						primary_currency_code,
						sec_alc_currency_code,
						sec_alc_mau,
						sec_alc_precision,
						conversion_option,
						currency_conversion_type,
						currency_conversion_date,
						primary_slam,
						primary_coa,
						primary_slam_type,
						primary_aad	 ,
						primary_aad_owner ,
						secondary_slam,
						secondary_coa,
						secondary_slam_type,
						secondary_aad	,
						secondary_aad_owner ,
						mapping_relationship_id,
						coa_mapping_name,
						primary_cal_set_name,
						primary_cal_per_type,
						primary_sec_alc_set_name,
						primary_sec_alc_per_type,
						dynamic_inserts ,
						parent_request_id )
					VALUES (
						g_primary_ledger_id,
						g_secondary_alc_ledger_id,
						g_application_id,
						g_upgrade_id,
						g_relationship_id,
						g_script_name,
						g_start_date,
						g_sec_alc_end_date,
						g_batch_size,
						g_num_workers,
						'PHASE-RATE',               --NULL,
						g_ledger_category_code,
						SYSDATE,
						g_primary_currency_code,
						g_sec_alc_currency_code,
						g_sec_alc_mau,
						g_sec_alc_precision,
						g_conversion_option,
						g_currency_conversion_type,
						g_currency_conversion_date,
						g_primary_slam,
						g_primary_coa,
						g_primary_slam_type,
						g_primary_aad	,
						g_primary_aad_owner	,
						g_secondary_slam,
						g_secondary_coa,
						g_secondary_slam_type,
						g_secondary_aad	,
						g_secondary_aad_owner	,
						g_mapping_relationship_id,
						g_coa_mapping_name,
						g_primary_cal_set_name,
						g_primary_cal_per_type,
						g_primary_sec_alc_set_name,
						g_primary_sec_alc_per_type,
						g_dynamic_inserts ,
						fnd_global.conc_request_id()
					        );

		populate_rates();

		ROLLBACK;


	ELSIF p_mode = 'F' THEN   -- final mode

	      retrieve_validate();   /* retrieve all information needed for run, except start_date, end_date
	                                perform all validations, except gl_transfer since this needs end date
					no commit!  */

	      validate_final_mode();
					/* Check if:
					   a) no failed run status exists for this ledger/applincation/relationship in history table,
					      meaning either first run or all SUCCESS rows only.
					   b) if first run, end date is min(accounting_date)-1 of secondary ledger or infinity if min is null
					   c) if second+ run, end date is min start date - 1 of all previously upgraded start dates
					   d) start should be less than end date retrieved
					   no commit!   */

	       INSERT INTO xla_historic_control(primary_ledger,
						secondary_alc_ledger,
						application_id,
						upgrade_id,
						relationship_id,
						script_name,
						start_date,
						end_date,
						batch_size,
						num_workers,
						status,
						ledger_category_code,
						last_update_date,
						primary_currency_code,
						sec_alc_currency_code,
						sec_alc_mau,
						sec_alc_precision,
						conversion_option,
						currency_conversion_type,
						currency_conversion_date,
						primary_slam,
						primary_coa,
						primary_slam_type,
						primary_aad	,
						primary_aad_owner,
						secondary_slam,
						secondary_coa,
						secondary_slam_type,
						secondary_aad,
						secondary_aad_owner	,
						mapping_relationship_id,
						coa_mapping_name,
						primary_cal_set_name,
						primary_cal_per_type,
						primary_sec_alc_set_name,
						primary_sec_alc_per_type,
						dynamic_inserts,
						sec_alc_min_acctng_batch_id ,
						parent_request_id )
					VALUES (
						g_primary_ledger_id,
						g_secondary_alc_ledger_id,
						g_application_id,
						g_upgrade_id,
						g_relationship_id,
						g_script_name,
						g_start_date,
						g_sec_alc_end_date,
						g_batch_size,
						g_num_workers,
						'PHASE-RATE',               --NULL,
						g_ledger_category_code,
						SYSDATE,
						g_primary_currency_code,
						g_sec_alc_currency_code,
						g_sec_alc_mau,
						g_sec_alc_precision,
						g_conversion_option,
						g_currency_conversion_type,
						g_currency_conversion_date,
						g_primary_slam,
						g_primary_coa,
						g_primary_slam_type,
						g_primary_aad,
						g_primary_aad_owner	,
						g_secondary_slam,
						g_secondary_coa,
						g_secondary_slam_type,
						g_secondary_aad	,
						g_secondary_aad_owner	,
						g_mapping_relationship_id,
						g_coa_mapping_name,
						g_primary_cal_set_name,
						g_primary_cal_per_type,
						g_primary_sec_alc_set_name,
						g_primary_sec_alc_per_type,
						g_dynamic_inserts,
						g_sec_alc_min_acctng_batch_id ,
						fnd_global.conc_request_id()
					        );


	        populate_rates();   /* for different date-range runs, rates will be re-inserted with same
		                       relationship id same but different upgrade id */

		UPDATE xla_historic_control
		   SET status = 'PHASE-DATA-START'
		 WHERE primary_ledger = g_primary_ledger_id
		   AND secondary_alc_ledger = g_secondary_alc_ledger_id
		   AND application_id = g_application_id
		   AND relationship_id = g_relationship_id
		   AND upgrade_id = g_upgrade_id
		   AND script_name = g_script_name
		   AND status = 'PHASE-RATE';

		COMMIT;


		IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			 (p_msg      => 'xla_historic_control updated to PHASE-DATA-START, commit executed'
			 ,p_level    => C_LEVEL_PROCEDURE
			 ,p_module   => l_log_module);
		END IF;


	       insert_data(g_primary_ledger_id,
		         g_secondary_alc_ledger_id,
		         g_application_id,
		         g_relationship_id,
		         g_upgrade_id,
		         g_script_name,
		         g_batch_size,
		         g_num_workers);      /*contains commit after FND submit, and after child workers completed successfully*/


	ELSIF p_mode = 'R' THEN   -- recovery mode


	      validate_recovery_mode();     /*  if mode recovery, input parameters in SRS Submit only allow application/ledgers
				                do not retrieve_validate or populate_rates again, instead use information commited from last failed run
				           Check if:
					   a) failed run should exist for ledger/period/relationship/sec_alc_ledger/application in history table,
					   b) only one failed RUN should exist, if two, error out, if none, error out
					   c) reset all parameters to failed run from table */

	      insert_data(g_primary_ledger_id
		         ,g_secondary_alc_ledger_id
		         ,g_application_id
		         ,g_relationship_id
		         ,g_upgrade_id
		         ,g_script_name
		         ,g_batch_size
		         ,g_num_workers);   -- call procedure with last run details

	END IF;


	p_retcode := 0;
   	p_errbuf := 'Upgrade Mode: ' || l_mode_meaning || ' completed successfully.'; -- changed from p_mode to l_mode_meaning


    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		  (p_msg      => 'UPG_MAIN procedure end time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log,'UPG_MAIN procedure end time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));




EXCEPTION WHEN g_validation_failed THEN

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		 (p_msg      => 'BEGIN of Abnormal Termination EXCEPTION'
		 ,p_level    => C_LEVEL_PROCEDURE
		 ,p_module   => l_log_module);
	END IF;

	p_retcode := 2;
   	p_errbuf := 'Upgrade Failed (g_validation_failed)';

   	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		 (p_msg      => 'END of Abnormal Termination EXCEPTION'
		 ,p_level    => C_LEVEL_PROCEDURE
		 ,p_module   => l_log_module);
	END IF;


WHEN others THEN

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			 (p_msg      => 'BEGIN of others EXCEPTION'
			 ,p_level    => C_LEVEL_PROCEDURE
			 ,p_module   => l_log_module);
	END IF;

	g_error_text := SQLCODE || ' ' || SQLERRM;


	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			 (p_msg      => 'SQL exception raised in upg_main is = ' || g_error_text
			 ,p_level    => C_LEVEL_PROCEDURE
			 ,p_module   => l_log_module);
	END IF;
        fnd_file.put_line(fnd_file.log, 'SQL exception raised in upg_main is = ' || g_error_text);


	p_retcode := 2;
	p_errbuf := 'Upgrade Failed (2)';

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		 (p_msg      => 'END of others EXCEPTION'
		 ,p_level    => C_LEVEL_PROCEDURE
		 ,p_module   => l_log_module);
	END IF;

END;




PROCEDURE validate_recovery_mode
IS

l_log_module                   VARCHAR2(240);

BEGIN

	IF g_log_enabled THEN
	      l_log_module := C_DEFAULT_MODULE||'.validate_recovery_mode';
   	END IF;

   	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'validate_recovery_mode procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
	END IF;
   	fnd_file.put_line(fnd_file.log,'validate_recovery_mode procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));


        -- these sqls are called before current run row is inserted into xla_historic_control

	SELECT COUNT(*)
	  INTO g_recovery_failed_runs
	  FROM xla_historic_control
	 WHERE primary_ledger = g_primary_ledger_id
	   AND secondary_alc_ledger = g_secondary_alc_ledger_id
	   AND application_id = g_application_id
	   AND status <> 'SUCCESS';


	   IF g_recovery_failed_runs = 0 THEN

			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				 (p_msg      => 'Recovery not needed, no failed run. Please re-submit in Final Mode'
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			END IF;
			fnd_file.put_line(fnd_file.log, 'validation failed: recovery not needed, no failed run exists. please re-submit in final mode' );

			ROLLBACK;
			RAISE g_validation_failed;

	  END IF;


	  -- below condition should not be possible in standard code flow without user manipulation

	  IF g_recovery_failed_runs > 1 THEN

			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				 (p_msg      => 'internal error: multiple failed runs, recovery not feasible'
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			END IF;
			fnd_file.put_line(fnd_file.log, 'validation failed: multiple failed runs, recovery not feasible' );

			ROLLBACK;
			RAISE g_validation_failed;

	  END IF;


	  -- below validations assume there is only one failed row existing for the ledger/application


	  SELECT primary_ledger
	         ,secondary_alc_ledger
	         ,application_id
	         ,relationship_id
	         ,upgrade_id
	         ,script_name
	         ,batch_size
	         ,num_workers
	  INTO    g_primary_ledger_id
	         ,g_secondary_alc_ledger_id
	         ,g_application_id
	         ,g_relationship_id
	         ,g_upgrade_id
	         ,g_script_name
	         ,g_batch_size
	         ,g_num_workers
	  FROM xla_historic_control
	 WHERE primary_ledger = g_primary_ledger_id
	   AND secondary_alc_ledger = g_secondary_alc_ledger_id
	   AND application_id = g_application_id
	   AND status = 'PHASE-DATA-START';


   	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'validate_recovery_mode procedure end time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
	END IF;
   	fnd_file.put_line(fnd_file.log,'validate_recovery_mode procedure end time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));


END;




PROCEDURE validate_final_mode
IS

l_log_module                   VARCHAR2(240);

BEGIN

	IF g_log_enabled THEN
	      l_log_module := C_DEFAULT_MODULE||'.validate_final_mode';
   	END IF;


   	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'validate_final_mode procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
	END IF;
   	fnd_file.put_line(fnd_file.log,'validate_final_mode procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));


        -- these sqls are called before current run row is inserted into xla_historic_control

	SELECT COUNT(*)
	  INTO g_failed_runs
	  FROM xla_historic_control
	 WHERE primary_ledger = g_primary_ledger_id
	   AND secondary_alc_ledger = g_secondary_alc_ledger_id
	   AND application_id = g_application_id
	   AND relationship_id = g_relationship_id
	   AND status <> 'SUCCESS';


	SELECT COUNT(*)
	  INTO g_success_runs
	  FROM xla_historic_control
	 WHERE primary_ledger = g_primary_ledger_id
	   AND secondary_alc_ledger = g_secondary_alc_ledger_id
	   AND application_id = g_application_id
	   AND relationship_id = g_relationship_id
	   AND status = 'SUCCESS';



	IF g_failed_runs > 0 THEN

			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				 (p_msg      => 'Failed run exists for specified input criteria, please run in Recovery Mode'
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			END IF;
			fnd_file.put_line(fnd_file.log, 'validation failed: failed run exists for specified input criteria, please run in recovery mode' );

			ROLLBACK;
			RAISE g_validation_failed;

	END IF;


	-- below validations assume this is either a first time run, or x+1 run with all x runs having status SUCCESS



	IF g_success_runs = 0 THEN

			-- if accounted data already exists for secondary ledger, take min accounting date less one, else infinity
			/*
			SELECT nvl(min(accounting_date-1), to_date('31/12/9999', 'DD/MM/YYYY'))
			  INTO g_sec_alc_end_date
			  FROM xla_ae_headers
			 WHERE application_id = g_application_id
			   AND ledger_id = g_secondary_alc_ledger_id
			   AND accounting_entry_status_code = 'F';
			*/

			SELECT min(accounting_batch_id)-1
			  INTO g_sec_alc_min_acctng_batch_id
			  FROM xla_ae_headers
			 WHERE application_id = g_application_id
			   AND ledger_id = g_secondary_alc_ledger_id
			   AND accounting_entry_status_code = 'F';

			g_sec_alc_end_date  := to_date('31/12/9999', 'DD/MM/YYYY');


			-- added by vgopiset
			IF g_sec_alc_min_acctng_batch_id IS NULL THEN
			   SELECT xla_accounting_batches_s.NEXTVAL INTO g_sec_alc_min_acctng_batch_id FROM DUAL;
                        END IF;


	ELSIF g_success_runs > 0 THEN

			--current run is the 2nd or higher run, set end date to start date less one of last run

			SELECT min(start_date-1) , min(sec_alc_min_acctng_batch_id)
			  INTO g_sec_alc_end_date , g_sec_alc_min_acctng_batch_id
			  FROM xla_historic_control
			 WHERE primary_ledger = g_primary_ledger_id
			   AND secondary_alc_ledger = g_secondary_alc_ledger_id
			   AND application_id = g_application_id
			   AND relationship_id = g_relationship_id
			   AND status = 'SUCCESS';

	END IF;


        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			      trace
				 (p_msg      => 'g_start_date = ' || to_char(g_start_date, 'DD-MON-RRRR')
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			      trace
				 (p_msg      => 'g_sec_alc_end_date calculated = ' || to_char(g_sec_alc_end_date, 'DD-MON-RRRR')
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
	END IF;



	IF g_start_date > g_sec_alc_end_date THEN

		IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				 (p_msg      => 'start date specified should be equal to or less than the retrieved end date of ' || to_char(g_sec_alc_end_date, 'DD-MON-RRRR')
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			END IF;
			fnd_file.put_line(fnd_file.log, 'validation failed: start date specified should be equal to or less than the retrieved end date of  ' || to_char(g_sec_alc_end_date,'DD-MON-RRRR'));

			ROLLBACK;
			RAISE g_validation_failed;


	END IF;



	BEGIN   -- Check if all fully accounted data has also been transferred to GL

		SELECT 1
		  INTO g_untransferred_headers
		  FROM DUAL
	  WHERE EXISTS (SELECT /*+ parallel (xla_ae_headers) */ 1
			  FROM xla_ae_headers
			 WHERE ledger_id = g_primary_ledger_id
			   AND accounting_entry_status_code = 'F'
			   AND application_id = g_application_id
			   AND balance_type_code in ('A', 'E')
                           AND event_type_code <> 'MANUAL'
			   AND gl_transfer_status_code = 'N' -- bug9278306
			   AND accounting_date >= g_start_date
			   AND accounting_date <= g_sec_alc_end_date);

	EXCEPTION WHEN others THEN

		IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		      trace
			 (p_msg      => 'All valid entries for primary ledger have been transferred to GL'
			 ,p_level    => C_LEVEL_PROCEDURE
			 ,p_module   => l_log_module);
	  	END IF;

	END;

	IF g_untransferred_headers = 1 THEN
		IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		      trace
			 (p_msg      => 'Error: There are valid accounting entries that have not been transferred to General Ledger'
			 ,p_level    => C_LEVEL_PROCEDURE
			 ,p_module   => l_log_module);
		END IF;

		--fnd_message.set_name('XLA','XLA_UPG_UNTRANS_ENTRIES');
		--fnd_file.put_line(fnd_file.log, 'Validation failed: ' ||  fnd_message.get);
		fnd_file.put_line(fnd_file.log, 'validation failed: there are valid accounting entries that have not been transferred to GL');

		ROLLBACK;
		RAISE g_validation_failed;

	END IF;

   	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'validate_final_mode procedure end time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
	END IF;
   	fnd_file.put_line(fnd_file.log,'validate_final_mode procedure end time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));

END;



PROCEDURE retrieve_validate
IS

l_log_module                   VARCHAR2(240);

BEGIN

	IF g_log_enabled THEN
	      l_log_module := C_DEFAULT_MODULE||'.retrieve_validate';
   	END IF;


   	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'retrieve_validate procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
	END IF;
   	fnd_file.put_line(fnd_file.log,'retrieve_validate procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));


	-- g_upgrade_id := fnd_global.conc_request_id(); commented out

	SELECT xla_upg_batches_s.NEXTVAL INTO g_upgrade_id FROM DUAL;
	g_script_name := 'xlahupg_' || g_upgrade_id;

	--g_sec_alc_end_date: set in validate_final_mode

	SELECT min(relationship_id)
	  INTO g_relationship_id
	  FROM gl_ledger_relationships
	 WHERE primary_ledger_id = g_primary_ledger_id
	   AND target_ledger_id = g_secondary_alc_ledger_id
	   AND application_id = 101
	   AND relationship_enabled_flag = 'Y';

	SELECT currency_code
	  INTO g_primary_currency_code
	  FROM gl_ledgers
	 WHERE ledger_id = g_primary_ledger_id;

	SELECT ledger_category_code, currency_code
	  INTO g_ledger_category_code, g_sec_alc_currency_code   --  ledger category will store 'SECONDARY' or 'ALC' or 'NONE'
	  FROM gl_ledgers
	 WHERE ledger_id = g_secondary_alc_ledger_id;

	SELECT minimum_accountable_unit, precision
	  INTO g_sec_alc_mau, g_sec_alc_precision
	  FROM fnd_currencies
	 WHERE currency_code = g_sec_alc_currency_code;


	 /*
	 IF g_ledger_category_code = 'ALC' THEN

		SELECT alc_init_conv_option_code, alc_initializing_rate_type, alc_initializing_rate_date
		  INTO g_conversion_option, g_currency_conversion_type, g_currency_conversion_date
		  FROM gl_ledger_relationships
		 WHERE relationship_id = g_relationship_id;

		IF ( (g_conversion_option IS NULL) OR (g_currency_conversion_type IS NULL) OR (g_currency_conversion_date IS NULL) ) THEN
			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				 (p_msg      => 'Error: g_conversion_option, g_currency_conversion_type, or g_currency_conversion_date is NULL for ALC ledger'
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			END IF;
			--fnd_message.set_name('XLA','XLA_UPG_GL_LEDG_NULL');
			--fnd_file.put_line(fnd_file.log, 'Validation failed: ' ||  fnd_message.get);
			fnd_file.put_line(fnd_file.log, 'validation failed: g_conversion_option, g_currency_conversion_type, or g_currency_conversion_date is NULL for ALC ledger');

			ROLLBACK;
			RAISE g_validation_failed;

		ELSE
			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				 (p_msg      => 'ALC conversion details retrieved'
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			END IF;
		END IF;
	 END IF;
	 */


	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			       trace
				 (p_msg      => 'g_upgrade_id = ' || g_upgrade_id
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_script_name = ' || g_script_name
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_relationship_id = ' || g_relationship_id
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_primary_currency_code = ' || g_primary_currency_code
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_ledger_category_code = ' || g_ledger_category_code
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
                               trace
				 (p_msg      => 'g_sec_alc_currency_code = ' || g_sec_alc_currency_code
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_sec_alc_mau = ' || g_sec_alc_mau
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_sec_alc_precision = ' || g_sec_alc_precision
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
                               trace
				 (p_msg      => 'g_conversion_option = ' || g_conversion_option
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_currency_conversion_type = ' || g_currency_conversion_type
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_currency_conversion_date = ' || to_char(g_currency_conversion_date, 'DD-MON-RRRR')
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
         END IF;



	SELECT period_set_name, accounted_period_type
	  INTO g_primary_cal_set_name, g_primary_cal_per_type
	  FROM gl_ledgers
	 WHERE ledger_id = g_primary_ledger_id;


	SELECT period_set_name, accounted_period_type
	  INTO g_primary_sec_alc_set_name, g_primary_sec_alc_per_type
	  FROM gl_ledgers
	 WHERE ledger_id = g_secondary_alc_ledger_id;


	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			       trace
				 (p_msg      => 'g_primary_cal_set_name = ' || g_primary_cal_set_name
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_primary_cal_per_type = ' || g_primary_cal_per_type
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_primary_sec_alc_set_name = ' || g_primary_sec_alc_set_name
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			       trace
				 (p_msg      => 'g_primary_sec_alc_per_type = ' || g_primary_sec_alc_per_type
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
	END IF;


        IF g_ledger_category_code = 'ALC' THEN

				BEGIN
					SELECT 1
					INTO g_alc_exists
					FROM DUAL
					WHERE EXISTS (SELECT 1
					      FROM xla_subledgers
					      WHERE alc_enabled_flag = 'Y'
					      AND application_id = g_application_id);


					IF g_alc_exists = 1 THEN
						IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
							trace
							 (p_msg      => 'Application ' || g_application_id || ' is ALC enabled'
							 ,p_level    => C_LEVEL_PROCEDURE
							 ,p_module   => l_log_module);
						END IF;
					END IF;


				EXCEPTION WHEN others THEN

					IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
					      trace
						 (p_msg      => 'Error: Application ' || g_application_id || ' is not ALC-enabled in SLA'
						 ,p_level    => C_LEVEL_PROCEDURE
						 ,p_module   => l_log_module);
					END IF;

					--fnd_message.set_name('XLA','XLA_UPG_ALC_DISABLED');
					--fnd_file.put_line(fnd_file.log, 'Validation failed: ' ||  fnd_message.get);
					fnd_file.put_line(fnd_file.log, 'validation failed: application is not ALC-enabled in SLA');

					ROLLBACK;
					RAISE g_validation_failed;

				END;
	END IF;  -- ledger category code ALC




	IF g_ledger_category_code = 'SECONDARY' THEN

			BEGIN
			 	SELECT    xlr.sla_accounting_method_code
					 ,xlr.chart_of_accounts_id
					 ,xlr.sla_accounting_method_type
					 ,xlr.enable_budgetary_control_flag
					 ,xamr.product_rule_code
					 ,xamr.PRODUCT_RULE_TYPE_CODE
				INTO      g_primary_slam
					 ,g_primary_coa
					 ,g_primary_slam_type
					 ,g_primary_budget
					 ,g_primary_aad
					 ,g_primary_aad_owner
				FROM      xla_ledger_relationships_v xlr ,
					 XLA_ACCTG_METHOD_RULES xamr
				WHERE xlr.ledger_id = g_primary_ledger_id
				AND   xamr.amb_context_code = 'DEFAULT'
				AND   xlr.sla_ACCOUNTING_METHOD_CODE = xamr.ACCOUNTING_METHOD_CODE
				AND   xlr.sla_ACCOUNTING_METHOD_TYPE = xamr.ACCOUNTING_METHOD_TYPE_CODE
				AND   xamr.application_id = g_application_id
				AND   TRUNC(SYSDATE) BETWEEN TRUNC(xamr.start_date_active) AND TRUNC(NVL(xamr.END_DATE_ACTIVE , SYSDATE));

				SELECT    xlr.sla_accounting_method_code
					 ,xlr.chart_of_accounts_id
					 ,xlr.sla_accounting_method_type
					 ,xlr.enable_budgetary_control_flag
					 ,xamr.product_rule_code
					 ,xamr.PRODUCT_RULE_TYPE_CODE
				INTO      g_secondary_slam
					 ,g_secondary_coa
					 ,g_secondary_slam_type
					 ,g_secondary_budget
					 ,g_secondary_aad
					 ,g_secondary_aad_owner
				FROM     xla_ledger_relationships_v xlr ,
					 XLA_ACCTG_METHOD_RULES xamr
				WHERE xlr.ledger_id = g_secondary_alc_ledger_id
				AND   xamr.amb_context_code = 'DEFAULT'
				AND   xlr.sla_ACCOUNTING_METHOD_CODE = xamr.ACCOUNTING_METHOD_CODE
				AND   xlr.sla_ACCOUNTING_METHOD_TYPE = xamr.ACCOUNTING_METHOD_TYPE_CODE
				AND   xamr.application_id = g_application_id
				AND   TRUNC(SYSDATE) BETWEEN TRUNC(xamr.start_date_active) AND TRUNC(NVL(xamr.END_DATE_ACTIVE , SYSDATE));

				IF (g_secondary_aad <> g_primary_aad) OR (g_secondary_aad_owner <> g_primary_aad_owner) OR
				   (g_primary_budget <> g_secondary_budget) THEN

					IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
					      trace
						 (p_msg      => 'Error: Primary and Secondary Ledger have different AADs or budegtary control '
						 ,p_level    => C_LEVEL_PROCEDURE
						 ,p_module   => l_log_module);
					END IF;
					ROLLBACK;
					--fnd_message.set_name('XLA','XLA_UPG_DIFF_SLAM');
					--fnd_file.put_line(fnd_file.log, 'Validation failed: ' ||  fnd_message.get);
					fnd_file.put_line(fnd_file.log, 'validation failed: primary and secondary ledger have different AAD or budegtary control');

					RAISE g_validation_failed;

				ELSE
					IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
					      trace
						 (p_msg      => 'Primary and Secondary Ledger AAD are the same'
						 ,p_level    => C_LEVEL_PROCEDURE
						 ,p_module   => l_log_module);
					END IF;
				END IF;

			EXCEPTION WHEN others THEN

				IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
					      trace
						 (p_msg      => 'Error: AADs or COAs not retrieved'
						 ,p_level    => C_LEVEL_PROCEDURE
						 ,p_module   => l_log_module);
				END IF;

				--fnd_message.set_name('XLA','XLA_UPG_SLAM_COA_FAIL');
				--fnd_file.put_line(fnd_file.log, 'Validation failed: ' ||  fnd_message.get);
				fnd_file.put_line(fnd_file.log, 'validation failed: AADs or COAs not retrieved');

				ROLLBACK;
				RAISE g_validation_failed;

			END;

			IF g_primary_coa <> g_secondary_coa THEN

				   BEGIN

					   SELECT sl_coa_mapping_id
					     INTO g_mapping_relationship_id
					     FROM xla_ledger_relationships_v
					    WHERE ledger_id = g_secondary_alc_ledger_id
					      AND primary_ledger_id = g_primary_ledger_id;

					   SELECT name
					     INTO g_coa_mapping_name
					     FROM gl_coa_mappings
					    WHERE coa_mapping_id = g_mapping_relationship_id;


					    SELECT dynamic_inserts_allowed_flag
					      INTO g_dynamic_inserts
					      FROM fnd_id_flex_structures_vl
					     WHERE application_id = 101
					       AND id_flex_code = 'GL#'
					       AND id_flex_num = g_primary_coa;    -- why is this flag for primary???


						IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
						      trace
							 (p_msg      => 'Chart of accounts mapping exists = ' || g_mapping_relationship_id
							 ,p_level    => C_LEVEL_PROCEDURE
							 ,p_module   => l_log_module);
						      trace
							 (p_msg      => 'Chart of accounts mapping name = ' || g_coa_mapping_name
							 ,p_level    => C_LEVEL_PROCEDURE
							 ,p_module   => l_log_module);
						      trace
							 (p_msg      => 'g_dynamic_inserts = ' || g_dynamic_inserts
							 ,p_level    => C_LEVEL_PROCEDURE
							 ,p_module   => l_log_module);
						END IF;


				   EXCEPTION WHEN others THEN

						IF g_mapping_relationship_id IS NULL THEN
								IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
								      trace
									 (p_msg      => 'Error: No chart of accounts mapping defined'
									 ,p_level    => C_LEVEL_PROCEDURE
									 ,p_module   => l_log_module);
								END IF;
								--fnd_message.set_name('XLA','XLA_UPG_NO_COA');
								--fnd_file.put_line(fnd_file.log, 'Validation failed: ' || fnd_message.get);
								fnd_file.put_line(fnd_file.log, 'validation failed: no chart of accounts mapping defined');

								ROLLBACK;
								RAISE g_validation_failed;
						END IF;

						IF g_coa_mapping_name IS NULL THEN
								IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
								      trace
									 (p_msg      => 'Error: No name defined for the chart of accounts mapping'
									 ,p_level    => C_LEVEL_PROCEDURE
									 ,p_module   => l_log_module);
								END IF;
								--fnd_message.set_name('XLA','XLA_UPG_COA_INV_NAME');
								--fnd_file.put_line(fnd_file.log, 'Validation failed: ' || fnd_message.get);
								fnd_file.put_line(fnd_file.log, 'validation failed: no name defined for chart of accounts mapping');

								ROLLBACK;
								RAISE g_validation_failed;
						END IF;

				   END;


		END IF; -- primary secondary coa

	END IF;    --ledger category code secondary



        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		  (p_msg      => 'retrieve_validate procedure end time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log,'retrieve_validate procedure end time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));


END;


PROCEDURE populate_rates IS

l_log_module              VARCHAR2(240);
l_error_exists            BOOLEAN := FALSE ;

CURSOR c_entered_currencies
IS
                SELECT /*+ parallel(xah) parallel(xal) leading(xah) */ distinct(XAL.currency_code)
                 FROM xla_ae_headers XAH,
                      xla_historic_control XHC,
		      xla_ae_lines XAL
		WHERE XHC.primary_ledger = g_primary_ledger_id
		  AND XHC.secondary_alc_ledger = g_secondary_alc_ledger_id
		  AND XHC.upgrade_id = g_upgrade_id
		  AND XHC.application_id = g_application_id
		  AND XHC.script_name  = g_script_name
		  AND XHC.relationship_id = g_relationship_id
		  AND XHC.status =  'PHASE-RATE'
		  AND XAH.ledger_id = XHC.primary_ledger
		  AND XAH.application_id = XHC.application_id
		  AND XAH.accounting_entry_status_code = 'F'
		  AND XAH.gl_transfer_status_code IN  ('Y', 'NT')   -- bug9278306
		  AND XAH.balance_type_code in ('A', 'E')
                  AND XAH.accounting_date >= XHC.start_date
		  AND XAH.accounting_date <= XHC.end_date
		  AND XAL.application_id = XAH.application_id
		  AND XAL.ae_header_id = XAH.ae_header_id
		  AND nvl(XAH.accounting_batch_id,0) <= NVL(XHC.sec_alc_min_acctng_batch_id , nvl(XAH.accounting_batch_id,0));


BEGIN

	IF g_log_enabled THEN
	      l_log_module := C_DEFAULT_MODULE||'.populate_rates';
	END IF;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		  (p_msg      => 'populate_rates procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log,'populate_rates procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));

	-- Check if somehow exchange rates already exists for this relationship id/upgrade id


	BEGIN

		SELECT 1
		  INTO g_rate_exists
		  FROM DUAL
	  WHERE EXISTS (SELECT 1
			  FROM xla_rc_upgrade_rates
			 WHERE relationship_id = g_relationship_id
			   AND upgrade_run_id = g_upgrade_id);


		IF g_rate_exists = 1  THEN

			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			      trace
				 (p_msg      => 'Error: Currency rates already defined for this upgrade_id and relationship_id'
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			END IF;


			--fnd_message.set_name('XLA','XLA_UPG_RATES_EXIST');
		        --fnd_file.put_line(fnd_file.log, 'Validation failed: ' ||  fnd_message.get);
			fnd_file.put_line(fnd_file.log, 'validation failed: currency rates already defined for this upgrade_id and relationship_id');

			ROLLBACK;
			RAISE g_validation_failed;
		END IF;


	EXCEPTION WHEN others THEN

		IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		      trace
			 (p_msg      => 'Currency rates not already defined for this currency, starting rate population'
			 ,p_level    => C_LEVEL_PROCEDURE
			 ,p_module   => l_log_module);
		END IF;

	END;




	IF g_conversion_option = 'I' THEN

		FOR c_entered_currencies_rec IN c_entered_currencies
		LOOP

			BEGIN
				          -- glustcrs.pls
					 gl_currency_api.get_triangulation_rate(c_entered_currencies_rec.currency_code,
									        g_sec_alc_currency_code,
										g_currency_conversion_date,
										g_currency_conversion_type,
										g_denominator,    -- output from API
										g_numerator,      -- output from API
										g_rate);          -- output from API
	                EXCEPTION WHEN others THEN
					IF ( (g_denominator IS NULL) OR (g_numerator IS NULL) OR (g_rate IS NULL) OR
					     (g_denominator <= 0) OR (g_numerator <= 0) OR (g_rate <= 0)) THEN
				        	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
					      		trace
							 (p_msg      => 'Error: GL API returned a null value for the currency or threw back an EXCEPTION for currency = ' || c_entered_currencies_rec.currency_code
							 ,p_level    => C_LEVEL_PROCEDURE
							 ,p_module   => l_log_module);
						END IF;

						--fnd_message.set_name('XLA','XLA_UPG_CURRENCY_API');
						--fnd_file.put_line(fnd_file.log, fnd_message.get);
						fnd_file.put_line(fnd_file.log, 'validation failed: GL API returned a null value for the currency or threw back an EXCEPTION for currency = ' || c_entered_currencies_rec.currency_code);

						 /* ROLLBACK;
						    RAISE g_validation_failed; */   -- commented by vgopiset

						l_error_exists := TRUE ;

					ELSE
						IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
					      		trace
							 (p_msg      => 'undefined error in populate_rates '
							 ,p_level    => C_LEVEL_PROCEDURE
							 ,p_module   => l_log_module);
						END IF;

						fnd_file.put_line(fnd_file.log, 'validation failed: undefined error in populate rates');

						ROLLBACK;
						RAISE g_validation_failed;


					END IF;
		      END;




	        IF ( (g_denominator IS NULL) OR (g_numerator IS NULL) OR (g_rate IS NULL) OR
		     (g_denominator <= 0) OR (g_numerator <= 0) OR (g_rate <= 0)) THEN

					IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
						trace
						 (p_msg      => 'Error: GL API returned a null value for the currency or threw back an EXCEPTION for currency = ' || c_entered_currencies_rec.currency_code
						 ,p_level    => C_LEVEL_PROCEDURE
						 ,p_module   => l_log_module);
					END IF;

					--fnd_message.set_name('XLA','XLA_UPG_CURRENCY_API');
					--fnd_file.put_line(fnd_file.log, 'Validation failed: ' ||  fnd_message.get || ' ' || c_entered_currencies_rec.currency_code);
					fnd_file.put_line(fnd_file.log, 'validation failed: GL API returned a null value for the currency or threw back an EXCEPTION for currency = ' || c_entered_currencies_rec.currency_code);

					 /* ROLLBACK;
						RAISE g_validation_failed;
					  */                                 -- commented by vgopiset
					l_error_exists := TRUE ;
		ELSE

			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
						trace
						 (p_msg      => 'Validation successful: currency API ' ||  c_entered_currencies_rec.currency_code
						 ,p_level    => C_LEVEL_PROCEDURE
						 ,p_module   => l_log_module);
			END IF;
		END IF;

			INSERT INTO xla_rc_upgrade_rates
					 (relationship_id
					 ,upgrade_run_id
					 ,from_currency
					 ,to_currency
					 ,denominator_rate
					 ,numerator_rate
					 ,conversion_rate
					 ,precision
					 ,minimum_accountable_unit
					 ,creation_date
					 ,created_by
					 ,last_update_date
					 ,last_updated_by
					 ,last_update_login)
				   VALUES(g_relationship_id
					 ,g_upgrade_id
					 ,c_entered_currencies_rec.currency_code
					 ,g_sec_alc_currency_code
					 ,g_denominator
					 ,g_numerator
					 ,g_rate
					 ,null
					 ,null
					 ,SYSDATE
					 ,fnd_global.user_id
					 ,SYSDATE
					 ,fnd_global.user_id
					 ,fnd_global.login_id);


	       END LOOP;   --c_entered_currencies_rec


	        IF l_error_exists  THEN
			ROLLBACK;
			RAISE g_validation_failed;
		END IF;



	ELSIF  g_conversion_option = 'D' THEN


		BEGIN
			gl_currency_api.get_triangulation_rate(g_primary_currency_code,
							       g_sec_alc_currency_code,
							       g_currency_conversion_date,
							       g_currency_conversion_type,
							       g_denominator,    -- output from API
							       g_numerator,      -- output from API
							       g_rate);          -- output from API

	        	EXCEPTION WHEN others THEN
				IF ( (g_denominator IS NULL) OR (g_numerator IS NULL) OR (g_rate IS NULL)
				      OR (g_denominator <= 0) OR (g_numerator <= 0) OR (g_rate <= 0) ) THEN
						       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
							      trace
								 (p_msg      => 'Error: GL API returned a null value for currency or threw back an EXCEPTION for currency ' || g_primary_currency_code
								 ,p_level    => C_LEVEL_PROCEDURE
								 ,p_module   => l_log_module);
							END IF;

							fnd_file.put_line(fnd_file.log, 'validation failed: GL API returned a null value for the currency or threw back an EXCEPTION for currency = ' || g_primary_currency_code);


							ROLLBACK;
							RAISE g_validation_failed;
				 END IF;
		END;





		IF ( (g_denominator IS NULL) OR (g_numerator IS NULL) OR (g_rate IS NULL)
			OR (g_denominator <= 0) OR (g_numerator <= 0) OR (g_rate <= 0) ) THEN

			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				 (p_msg      => 'Error: GL API returned a null value for the currency or threw back an EXCEPTION for currency = ' || g_primary_currency_code
				 ,p_level    => C_LEVEL_PROCEDURE
				 ,p_module   => l_log_module);
			END IF;

			--fnd_message.set_name('XLA','XLA_UPG_CURRENCY_API');
			--fnd_file.put_line(fnd_file.log, 'Validation failed: ' ||  fnd_message.get || ' ' || g_primary_currency_code);
			fnd_file.put_line(fnd_file.log, 'validation failed: GL API returned a null value for the currency or threw back an EXCEPTION for currency = ' || g_primary_currency_code);

			ROLLBACK;
			RAISE g_validation_failed;

		ELSE
			--fnd_file.put_line(fnd_file.log, 'Validation successful: currency API ' ||  g_primary_currency_code);
			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
						trace
						 (p_msg      => 'Validation successful: currency API ' ||  g_primary_currency_code
						 ,p_level    => C_LEVEL_PROCEDURE
						 ,p_module   => l_log_module);
			END IF;


		END IF;


			INSERT INTO xla_rc_upgrade_rates
					 (relationship_id
					 ,upgrade_run_id
					 ,from_currency
					 ,to_currency
					 ,denominator_rate
					 ,numerator_rate
					 ,conversion_rate
					 ,precision
					 ,minimum_accountable_unit
					 ,creation_date
					 ,created_by
					 ,last_update_date
					 ,last_updated_by
					 ,last_update_login)
				   VALUES(g_relationship_id
					 ,g_upgrade_id
					 ,g_primary_currency_code
					 ,g_sec_alc_currency_code
					 ,g_denominator
					 ,g_numerator
					 ,g_rate
					 ,null
					 ,null
					 ,SYSDATE
					 ,fnd_global.user_id
					 ,SYSDATE
					 ,fnd_global.user_id
					 ,fnd_global.login_id);



	END IF;  -- g_conversion_option end if


	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

					SELECT count(*)
					  INTO g_currency_count
					  FROM xla_rc_upgrade_rates
					 WHERE relationship_id = g_relationship_id
				           AND upgrade_run_id = g_upgrade_id;

				      trace
					 (p_msg      => 'Rows inserted into xla_rc_upgrade_rates after calling GL API = ' || g_currency_count
					 ,p_level    => C_LEVEL_PROCEDURE
					 ,p_module   => l_log_module);
	END IF;

       	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		  (p_msg      => 'populate_rates procedure end time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log,'populate_rates procedure end time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));


END;








PROCEDURE insert_data(p_primary_ledger_id IN NUMBER,
		      p_sec_alc_ledger_id IN NUMBER,
		      p_application_id    IN NUMBER,
		      p_relationship_id   IN NUMBER,
		      p_upgrade_id        IN NUMBER,
		      p_script_name       IN VARCHAR2,
		      p_batch_size        IN NUMBER,
		      p_num_workers       IN NUMBER)
IS

l_log_module                VARCHAR2(240);
l_child_notcomplete         BOOLEAN := TRUE;
l_phase                     VARCHAR2(500) := NULL;
l_req_status                VARCHAR2(500) := NULL;
l_devphase                  VARCHAR2(500) := NULL;
l_devstatus                 VARCHAR2(500) := NULL;
l_message                   VARCHAR2(500) := NULL;
l_child_success             VARCHAR2(1);

BEGIN

	IF g_log_enabled THEN
	      l_log_module := C_DEFAULT_MODULE||'.insert_data';
   	END IF;


   	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'insert_data procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
	END IF;
   	fnd_file.put_line(fnd_file.log,'insert_data procedure start time: ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));


	SELECT DECODE(primary_coa, secondary_coa, 'N', 'Y'),
	       DECODE(primary_cal_set_name, primary_sec_alc_set_name,
			 DECODE(primary_cal_per_type, primary_sec_alc_per_type, 'N', 'Y'),
			 'Y'),
	       dynamic_inserts,
	       mapping_relationship_id,
	       coa_mapping_name
	  INTO g_ccid_map,
	       g_calendar_convert,
	       g_dynamic_flag,
	       g_mapping_rel_id,
	       g_coa_map_name
	  FROM xla_historic_control
	 WHERE primary_ledger = p_primary_ledger_id
	   AND secondary_alc_ledger = p_sec_alc_ledger_id
	   AND application_id = p_application_id
	   AND relationship_id = p_relationship_id
	   AND upgrade_id = p_upgrade_id
	   AND script_name = p_script_name
	   AND status = 'PHASE-DATA-START';


	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'g_ccid_map ' || g_ccid_map
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
                        trace
			  (p_msg      => 'g_calendar_convert ' || g_calendar_convert
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			  (p_msg      => 'g_dynamic_flag ' || g_dynamic_flag
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
                        trace
			  (p_msg      => 'g_mapping_rel_id ' || g_mapping_rel_id
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
                        trace
			  (p_msg      => 'g_coa_map_name ' || g_coa_map_name
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
	END IF;


	FOR i in 1..p_num_workers
	LOOP

		    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				  (p_msg      => 'Calling FND_REQUEST.SUBMIT_REQUEST for worker '|| i
				   ,p_level    => C_LEVEL_PROCEDURE
				   ,p_module   => l_log_module);
		    END IF;

		    g_worker(i) := FND_REQUEST.SUBMIT_REQUEST
				      ( application     => 'XLA'
				       ,program         => 'XLAHUPGSUB'
				       ,description     => NULL
				       ,start_time      => NULL
				       ,sub_request     => FALSE
				       ,argument1       => p_batch_size
				       ,argument2       => i                 -- worker_id
				       ,argument3       => p_num_workers
				       ,argument4       => p_script_name
				       ,argument5       => p_application_id
				       ,argument6       => p_primary_ledger_id
				       ,argument7       => p_sec_alc_ledger_id
				       ,argument8       => p_upgrade_id
                                       ,argument9       => p_relationship_id
				       ,argument10      => g_ccid_map
				       ,argument11      => g_calendar_convert
                                       ,argument12      => g_dynamic_flag
				       ,argument13      => g_mapping_rel_id
				       ,argument14      => g_coa_map_name
				       );


		   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				   (p_msg      => 'Called FND_REQUEST.SUBMIT_REQUEST for worker '|| i || ' generated REQUEST_ID ' || g_worker(i)
				   ,p_level    => C_LEVEL_PROCEDURE
				   ,p_module   => l_log_module);
		   END IF;


		   --added below check since parent program ends in normal status even if child workers not spawned
		   IF (g_worker(i) = 0) OR (g_worker(i) IS NULL) OR (g_worker(i) < 0) THEN

				IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				  trace
				   (p_msg      => 'validation failed: invalid request_id, worker '|| i || ' generated REQUEST_ID ' || g_worker(i)
				   ,p_level    => C_LEVEL_PROCEDURE
				   ,p_module   => l_log_module);
				END IF;

				fnd_file.put_line(fnd_file.log, 'validation failed: invalid request_id, worker '|| i || ' generated REQUEST_ID ' || g_worker(i));
				ROLLBACK;
				RAISE G_CHILD_FAILED;


		   END IF;



         END LOOP;


	 COMMIT;   -- commit needed after FND request submission

	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'commit executed after spawning child workers'
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
	 END IF;




	  WHILE l_child_notcomplete
	  LOOP

	     dbms_lock.sleep(100);

	     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				  (p_msg      => 'Checking all child request status after sleeping 100: '
				   ,p_level    => C_LEVEL_PROCEDURE
				   ,p_module   => l_log_module);
	     END IF;

	     l_child_notcomplete := FALSE;

	     FOR i in 1..p_num_workers
	     LOOP

			       IF (FND_CONCURRENT.GET_REQUEST_STATUS
							 (g_worker(i),
							  NULL,
							  NULL,
							  l_phase,
							  l_req_status,
							  l_devphase,
							  l_devstatus,
							  l_message))
				THEN NULL;
				END IF;


				IF (l_devphase <> 'COMPLETE')  THEN
					 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
						trace
						  (p_msg      => 'Worker ' ||  i || ' with request ' || g_worker(i) || ' not complete, loop again'
						  ,p_level    => C_LEVEL_PROCEDURE
						  ,p_module   => l_log_module);
					 END IF;

					l_child_notcomplete := TRUE;   --one or multiple workers will set the same variable to TRUE, never false
				END IF;


				IF (l_devphase = 'COMPLETE') AND l_devstatus NOT IN ('NORMAL','WARNING') THEN
					l_child_success := 'N';   -- one or multiple workers will set the same variable to N, or never set
				END IF;

	    END LOOP;
         END LOOP;


	 -- above loop will continue till all DEVPHASE is complete



	 -- if any subworkers have failed then raise an error */
	 IF l_child_success = 'N' THEN

	         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				   (p_msg      => 'l_child_success = N, raising exception G_CHILD_FAILED'
				   ,p_level    => C_LEVEL_PROCEDURE
				   ,p_module   => l_log_module);
	         END IF;

	         fnd_file.put_line(fnd_file.log, 'validation failed: atleast one child failed with an error');


		 ROLLBACK;
	         RAISE G_CHILD_FAILED;
	         -- run status remains PHASE-DATA-START even if rollback

	 ELSE

		UPDATE xla_historic_control
		   SET status = 'SUCCESS'
		 WHERE primary_ledger = p_primary_ledger_id
		   AND secondary_alc_ledger = p_sec_alc_ledger_id
		   AND application_id = p_application_id
		   AND script_name = p_script_name
		   AND relationship_id = p_relationship_id
		   AND g_upgrade_id = p_upgrade_id
		   AND status = 'PHASE-DATA-START';

		COMMIT;

		IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				  (p_msg      => 'commit executed all spawned child workers successful'
				   ,p_level    => C_LEVEL_PROCEDURE
				   ,p_module   => l_log_module);
		END IF;
	 END IF;

END;




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
             )
IS

l_log_module		    VARCHAR2(240);
l_child_request             NUMBER;
l_table_name                VARCHAR2(50);
l_table_owner               VARCHAR2(30) := 'XLA';

l_any_rows_to_process       BOOLEAN;
l_rows_processed            NUMBER;
l_mapping_rows              NUMBER;
l_gt_count                  NUMBER;

g_sub_validation_failed       EXCEPTION;
gl_invalid_mapping_name       EXCEPTION;
gl_disabled_mapping           EXCEPTION;
gl_invalid_mapping_rules      EXCEPTION;
gl_map_unexpected_error       EXCEPTION;
gl_bsv_map_no_source_bal_seg  EXCEPTION;
gl_bsv_map_no_target_bal_seg  EXCEPTION;
gl_bsv_map_no_segment_map     EXCEPTION;
gl_bsv_map_no_single_value    EXCEPTION;
gl_bsv_map_no_from_segment    EXCEPTION;
gl_bsv_map_not_bsv_derived    EXCEPTION;
gl_bsv_map_setup_error        EXCEPTION;
gl_bsv_map_mapping_error      EXCEPTION;
gl_bsv_map_unexpected_error   EXCEPTION;

l_start_rowid               ROWID;
l_end_rowid                 ROWID;

l_iterations                NUMBER;



BEGIN


	IF g_log_enabled THEN
	    l_log_module := C_DEFAULT_MODULE||'.historic_worker';
   	END IF;

	l_child_request := fnd_global.conc_request_id();
	l_iterations := 0;

	fnd_file.put_line(fnd_file.log, 'Started child worker request ' || l_child_request || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

			trace
			   (p_msg      => 'Started child worker request ' || l_child_request || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_batch_size = ' || p_batch_size
			   ,p_level    => C_LEVEL_PROCEDURE
		      	   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_worker_id = ' || p_worker_id
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_num_workers = ' || p_num_workers
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_script_name = ' || p_script_name
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_application_id = ' || p_application_id
			   ,p_level    => C_LEVEL_PROCEDURE
		      	   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_primary_ledger_id = ' || p_primary_ledger_id
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_sec_alc_ledger_id = ' || p_sec_alc_ledger_id
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_ugprade_id = ' || p_ugprade_id
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_relationship_id = ' || p_relationship_id
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_ccid_map = ' || p_ccid_map
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_calendar_convert = ' || p_calendar_convert
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_dynamic_flag = ' || p_dynamic_flag
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_mapping_rel_id = ' || p_mapping_rel_id
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
			trace
			   (p_msg      => 'p_coa_map_name = ' || p_coa_map_name
			   ,p_level    => C_LEVEL_PROCEDURE
			   ,p_module   => l_log_module);
	 END IF;




	 l_table_name := 'XLA_AE_HEADERS';


	  ad_parallel_updates_pkg.initialize_rowid_range(
		   ad_parallel_updates_pkg.ROWID_RANGE,
		   l_table_owner,
		   l_table_name,
		   p_script_name,
		   p_worker_id,
		   p_num_workers,
		   p_batch_size,
		   0);


	  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		(p_msg      => 'finished calling initialize_rowid_range '
		,p_level    => C_LEVEL_PROCEDURE
		,p_module   => l_log_module);
	  END IF;


	  ad_parallel_updates_pkg.get_rowid_range(
		   l_start_rowid,
		   l_end_rowid,
		   l_any_rows_to_process,
		   p_batch_size,
		   TRUE);

	  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		(p_msg      => 'finished calling get_rowid_range'
		,p_level    => C_LEVEL_PROCEDURE
		,p_module   => l_log_module);
	  END IF;


 WHILE (l_any_rows_to_process = TRUE)
 LOOP

	       l_iterations := l_iterations + 1;

	       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'LOOP iteration started ' || l_iterations
			  ,p_level    => C_LEVEL_PROCEDURE
			  ,p_module   => l_log_module);
	       END IF;


               SELECT COUNT(*)
	       INTO l_gt_count
	       FROM xla_historic_mapping_gt;

	       IF l_gt_count <> 0 THEN

			 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				  (p_msg      => 'GT count not 0 at iteration ' || l_iterations
				  ,p_level    => C_LEVEL_PROCEDURE
				  ,p_module   => l_log_module);
			END IF;

			RAISE g_validation_failed;
			ROLLBACK;

	       END IF;


	  INSERT INTO XLA_AE_HEADERS
		(
		    AE_HEADER_ID
		,   APPLICATION_ID
		,   LEDGER_ID
		,   ENTITY_ID
		,   EVENT_ID
		,   EVENT_TYPE_CODE
		,   ACCOUNTING_DATE
		,   GL_TRANSFER_STATUS_CODE
		,   GL_TRANSFER_DATE
		,   JE_CATEGORY_NAME
		,   ACCOUNTING_ENTRY_STATUS_CODE
		,   ACCOUNTING_ENTRY_TYPE_CODE
		,   AMB_CONTEXT_CODE
		,   PRODUCT_RULE_TYPE_CODE
		,   PRODUCT_RULE_CODE
		,   PRODUCT_RULE_VERSION
		,   DESCRIPTION
		,   DOC_SEQUENCE_ID
		,   DOC_SEQUENCE_VALUE
		,   ACCOUNTING_BATCH_ID
		,   COMPLETION_ACCT_SEQ_VERSION_ID
		,   CLOSE_ACCT_SEQ_VERSION_ID
		,   COMPLETION_ACCT_SEQ_VALUE
		,   CLOSE_ACCT_SEQ_VALUE
		,   BUDGET_VERSION_ID
		,   FUNDS_STATUS_CODE
		,   ENCUMBRANCE_TYPE_ID
		,   BALANCE_TYPE_CODE
		,   REFERENCE_DATE
		,   COMPLETED_DATE
		,   PERIOD_NAME
		,   PACKET_ID
		,   COMPLETION_ACCT_SEQ_ASSIGN_ID
		,   CLOSE_ACCT_SEQ_ASSIGN_ID
		,   DOC_CATEGORY_CODE
		,   ATTRIBUTE_CATEGORY
		,   ATTRIBUTE1
		,   ATTRIBUTE2
		,   ATTRIBUTE3
		,   ATTRIBUTE4
		,   ATTRIBUTE5
		,   ATTRIBUTE6
		,   ATTRIBUTE7
		,   ATTRIBUTE8
		,   ATTRIBUTE9
		,   ATTRIBUTE10
		,   ATTRIBUTE11
		,   ATTRIBUTE12
		,   ATTRIBUTE13
		,   ATTRIBUTE14
		,   ATTRIBUTE15
		,   GROUP_ID
		,   DOC_SEQUENCE_VERSION_ID
		,   DOC_SEQUENCE_ASSIGN_ID
		,   CREATION_DATE
		,   CREATED_BY
		,   LAST_UPDATE_DATE
		,   LAST_UPDATED_BY
		,   LAST_UPDATE_LOGIN
		,   PROGRAM_UPDATE_DATE
		,   PROGRAM_APPLICATION_ID
		,   PROGRAM_ID
		,   REQUEST_ID
		,   UPG_BATCH_ID
		,   UPG_SOURCE_APPLICATION_ID
		,   UPG_VALID_FLAG
		,   ZERO_AMOUNT_FLAG
		,   PARENT_AE_HEADER_ID
		,   PARENT_AE_LINE_NUM
		,   ACCRUAL_REVERSAL_FLAG
		,   MERGE_EVENT_ID         )
		SELECT    /*+ rowid(xah) leading(xah) */
		                                           XLA_AE_HEADERS_S.nextval
		,   XAH.APPLICATION_ID
		,                                          XHC.secondary_alc_ledger
		,   XAH.ENTITY_ID
		,   XAH.EVENT_ID
		,   XAH.EVENT_TYPE_CODE
		,   XAH.ACCOUNTING_DATE
		,   XAH.GL_TRANSFER_STATUS_CODE           -- stamped as Y or NT but assumed transferred via balance intialization
		,   XAH.GL_TRANSFER_DATE
		,   XAH.JE_CATEGORY_NAME
		,   XAH.ACCOUNTING_ENTRY_STATUS_CODE
		,   XAH.ACCOUNTING_ENTRY_TYPE_CODE
		,   XAH.AMB_CONTEXT_CODE
		,   XAH.PRODUCT_RULE_TYPE_CODE
		,   XAH.PRODUCT_RULE_CODE
		,   XAH.PRODUCT_RULE_VERSION
		,   XAH.DESCRIPTION                       -- inherit primary description
		,   XAH.DOC_SEQUENCE_ID
		,   XAH.DOC_SEQUENCE_VALUE
		,                                          NULL                         -- ACCOUNTING_BATCH_ID
		,                                          NULL                         -- COMPLETION_ACCT_SEQ_VERSION_ID
		,                                          NULL                         -- CLOSE_ACCT_SEQ_VERSION_ID
		,                                          NULL                         -- COMPLETION_ACCT_SEQ_VALUE
		,                                          NULL                         -- CLOSE_ACCT_SEQ_VALUE
		,   XAH.BUDGET_VERSION_ID
		,   XAH.FUNDS_STATUS_CODE
		,   XAH.ENCUMBRANCE_TYPE_ID
		,   XAH.BALANCE_TYPE_CODE                 -- validation in place to ensure both ledgers budgetary
		,   XAH.REFERENCE_DATE
		,   XAH.COMPLETED_DATE
		,   XAH.PERIOD_NAME                       -- period name will be converted later if calendar different
		,   XAH.PACKET_ID
		,                                          NULL                          -- COMPLETION_ACCT_SEQ_ASSIGN_ID
		,                                          NULL                          -- CLOSE_ACCT_SEQ_ASSIGN_ID
		,   XAH.DOC_CATEGORY_CODE
		,   XAH.ATTRIBUTE_CATEGORY
		,   XAH.ATTRIBUTE1
		,   XAH.ATTRIBUTE2
		,   XAH.ATTRIBUTE3
		,   XAH.ATTRIBUTE4
		,   XAH.ATTRIBUTE5
		,   XAH.ATTRIBUTE6
		,   XAH.ATTRIBUTE7
		,   XAH.ATTRIBUTE8
		,   XAH.ATTRIBUTE9
		,   XAH.ATTRIBUTE10
		,   XAH.ATTRIBUTE11
		,   XAH.ATTRIBUTE12
		,   XAH.ATTRIBUTE13
		,   XAH.ATTRIBUTE14
		,   XAH.ATTRIBUTE15
		,   XAH.GROUP_ID
		,   XAH.DOC_SEQUENCE_VERSION_ID
		,   XAH.DOC_SEQUENCE_ASSIGN_ID
		,                                        SYSDATE                    -- CREATION_DATE
		,                                        fnd_global.user_id         -- CREATED_BY
		,                                        SYSDATE                    -- LAST_UPDATE_DATE
		,                                        fnd_global.user_id         -- LAST_UPDATED_BY
		,                                        fnd_global.login_id        -- LAST_UPDATE_LOGIN
		,                                        SYSDATE                    -- PROGRAM_UPDATE_DATE
		,                                        fnd_global.prog_appl_id    -- PROGRAM_APPLICATION_ID reverted -601
		,                                        fnd_global.conc_program_id -- PROGRAM_ID reverted -601

		,                                        XHC.upgrade_id             -- REQUEST_ID
		,                                        XAH.ae_header_id           -- UPG_BATCH_ID = AE_HEADER_ID of PRIMARY ledger, cleared later


		,                                         -602                      -- UPG_SOURCE_APPLICATION_ID
	        ,   XAH.UPG_VALID_FLAG
		,   XAH.ZERO_AMOUNT_FLAG
		,   XAH.PARENT_AE_HEADER_ID
		,   XAH.PARENT_AE_LINE_NUM
		,   XAH.ACCRUAL_REVERSAL_FLAG
		,   XAH.MERGE_EVENT_ID
		FROM xla_ae_headers XAH,
                     xla_historic_control XHC
		WHERE XHC.primary_ledger = p_primary_ledger_id          -- worker input
		  AND XHC.secondary_alc_ledger = p_sec_alc_ledger_id    -- worker input
		  AND XHC.upgrade_id = p_ugprade_id                     -- worker input
		  AND XHC.application_id = p_application_id             -- worker input
		  AND XHC.script_name  = p_script_name                  -- worker input
		  AND XHC.relationship_id = p_relationship_id           -- worker input
		  AND XHC.status = 'PHASE-DATA-START'
		  AND XAH.ledger_id = XHC.primary_ledger
		  AND XAH.application_id = XHC.application_id
		  AND XAH.accounting_entry_status_code = 'F'
		  AND XAH.gl_transfer_status_code IN  ('Y','NT')       -- bug9278306
		  AND XAH.balance_type_code in ('A', 'E')
                  AND XAH.accounting_date >= XHC.start_date             -- next run
		  AND XAH.accounting_date <= XHC.end_date
		  --AND XAH.accounting_batch_id <= NVL(XHC.sec_alc_min_acctng_batch_id , XAH.accounting_batch_id)   -- modified by vgopiset
		  AND nvl(XAH.accounting_batch_id,0) <= NVL(XHC.sec_alc_min_acctng_batch_id , nvl(XAH.accounting_batch_id,0))    -- added to handle 11i data
		  AND XAH.event_type_code <> 'MANUAL'                              -- added by vgopiset
		  AND XAH.ROWID BETWEEN l_start_rowid AND l_end_rowid;

		l_rows_processed := SQL%ROWCOUNT;


		IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

			trace
		       	  (p_msg      => 'Rows inserted into xla_ae_headers: ' || l_rows_processed || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
		       	   ,p_level    => C_LEVEL_PROCEDURE
		       	   ,p_module   => l_log_module);

		END IF;



   IF (l_rows_processed <> 0) THEN     --insert into GT/XDL/XAL only when headers are inserted.



          INSERT INTO xla_historic_mapping_gt(primary_header_id, new_header_id)
	       SELECT  /*+ rowid(xah) leading(xah) index(xahnew xla_ae_headers_n2)*/
	              XAH.ae_header_id, XAHNEW.ae_header_id
		 FROM xla_ae_headers XAH,
                      xla_historic_control XHC,
		      xla_ae_headers XAHNEW
		WHERE XHC.primary_ledger = p_primary_ledger_id          -- worker input
		  AND XHC.secondary_alc_ledger = p_sec_alc_ledger_id    -- worker input
		  AND XHC.upgrade_id = p_ugprade_id                     -- worker input
		  AND XHC.application_id = p_application_id             -- worker input
		  AND XHC.script_name  = p_script_name                  -- worker input
		  AND XHC.relationship_id = p_relationship_id           -- worker input
		  AND XHC.status = 'PHASE-DATA-START'
		  AND XAH.ledger_id = XHC.primary_ledger
		  AND XAH.application_id = XHC.application_id
		  AND XAH.accounting_entry_status_code = 'F'
		  AND XAH.gl_transfer_status_code IN  ('Y','NT')       -- bug9278306
		  AND XAH.balance_type_code in ('A', 'E')
                  AND XAH.accounting_date >= XHC.start_date
		  AND XAH.accounting_date <= XHC.end_date
		  --AND XAH.accounting_batch_id <= NVL(XHC.sec_alc_min_acctng_batch_id , XAH.accounting_batch_id)
		  AND nvl(XAH.accounting_batch_id,0) <= NVL(XHC.sec_alc_min_acctng_batch_id , nvl(XAH.accounting_batch_id,0))    -- added to handle 11i data
		  AND XAH.event_type_code <> 'MANUAL'                              -- added by vgopiset
		  AND XAH.ROWID BETWEEN l_start_rowid AND l_end_rowid
		  AND XAHNEW.application_id = XHC.application_id
		  AND XAHNEW.ledger_id = secondary_alc_ledger
		  AND XAHNEW.accounting_entry_status_code = 'F'
		  AND XAHNEW.gl_transfer_status_code IN  ('Y','NT')     -- bug9278306
		  AND XAHNEW.balance_type_code in ('A', 'E')
                  AND XAHNEW.accounting_date >= XHC.start_date
		  AND XAHNEW.accounting_date <= XHC.end_date
		  AND XAHNEW.upg_batch_id = XAH.ae_header_id
		  AND XAHNEW.event_id = XAH.event_id
		  AND XAHNEW.application_id = XAH.application_id;


		l_mapping_rows := SQL%ROWCOUNT;

		IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

			trace
		       	  (p_msg      => 'Rows inserted into xla_historic_mapping_gt: ' || l_mapping_rows || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
		       	   ,p_level    => C_LEVEL_PROCEDURE
		       	   ,p_module   => l_log_module);

		END IF;


		IF l_mapping_rows <> l_rows_processed THEN

		   ROLLBACK; -- added by vgopiset as above INSERTED HEADERS should not be COMMITED

		   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
		       	  (p_msg      => 'XAH rowcount and mapping GT rowcount mismatch'
		       	   ,p_level    => C_LEVEL_PROCEDURE
		       	   ,p_module   => l_log_module);
		   END IF;

		   RAISE g_sub_validation_failed;

		END IF;



	   -- rowid condition not needed below since only x-y rowid XAH headers stored in xla_historic_mapping_gt

	   INSERT INTO XLA_DISTRIBUTION_LINKS
			(
			    APPLICATION_ID
			  , EVENT_ID
			  , AE_HEADER_ID
			  , AE_LINE_NUM
			  , SOURCE_DISTRIBUTION_TYPE
			  , SOURCE_DISTRIBUTION_ID_CHAR_1
			  , SOURCE_DISTRIBUTION_ID_CHAR_2
			  , SOURCE_DISTRIBUTION_ID_CHAR_3
			  , SOURCE_DISTRIBUTION_ID_CHAR_4
			  , SOURCE_DISTRIBUTION_ID_CHAR_5
			  , SOURCE_DISTRIBUTION_ID_NUM_1
			  , SOURCE_DISTRIBUTION_ID_NUM_2
			  , SOURCE_DISTRIBUTION_ID_NUM_3
			  , SOURCE_DISTRIBUTION_ID_NUM_4
			  , SOURCE_DISTRIBUTION_ID_NUM_5
			  , TAX_LINE_REF_ID
			  , TAX_SUMMARY_LINE_REF_ID
			  , TAX_REC_NREC_DIST_REF_ID
			  , STATISTICAL_AMOUNT
			  , REF_AE_HEADER_ID
			  , REF_TEMP_LINE_NUM
			  , ACCOUNTING_LINE_CODE
			  , ACCOUNTING_LINE_TYPE_CODE
			  , MERGE_DUPLICATE_CODE
			  , TEMP_LINE_NUM
			  , REF_EVENT_ID
			  , LINE_DEFINITION_OWNER_CODE
			  , LINE_DEFINITION_CODE
			  , EVENT_CLASS_CODE
			  , EVENT_TYPE_CODE
			  , UPG_BATCH_ID
			  , CALCULATE_ACCTD_AMTS_FLAG
			  , CALCULATE_G_L_AMTS_FLAG
			  , ROUNDING_CLASS_CODE
			  , DOCUMENT_ROUNDING_LEVEL
			  ,				UNROUNDED_ENTERED_DR
			  ,				UNROUNDED_ENTERED_CR
			  , DOC_ROUNDING_ENTERED_AMT
			  , DOC_ROUNDING_ACCTD_AMT
			  ,				UNROUNDED_ACCOUNTED_CR
			  ,				UNROUNDED_ACCOUNTED_DR
			  , APPLIED_TO_APPLICATION_ID
			  , APPLIED_TO_ENTITY_CODE
			  , APPLIED_TO_ENTITY_ID
			  , APPLIED_TO_SOURCE_ID_NUM_1
			  , APPLIED_TO_SOURCE_ID_NUM_2
			  , APPLIED_TO_SOURCE_ID_NUM_3
			  , APPLIED_TO_SOURCE_ID_NUM_4
			  , APPLIED_TO_SOURCE_ID_CHAR_1
			  , APPLIED_TO_SOURCE_ID_CHAR_2
			  , APPLIED_TO_SOURCE_ID_CHAR_3
			  , APPLIED_TO_SOURCE_ID_CHAR_4
			  , APPLIED_TO_DISTRIBUTION_TYPE
			  , APPLIED_TO_DIST_ID_NUM_1
			  , APPLIED_TO_DIST_ID_NUM_2
			  , APPLIED_TO_DIST_ID_NUM_3
			  , APPLIED_TO_DIST_ID_NUM_4
			  , APPLIED_TO_DIST_ID_NUM_5
			  , APPLIED_TO_DIST_ID_CHAR_1
			  , APPLIED_TO_DIST_ID_CHAR_2
			  , APPLIED_TO_DIST_ID_CHAR_3
			  , APPLIED_TO_DIST_ID_CHAR_4
			  , APPLIED_TO_DIST_ID_CHAR_5
			  , ALLOC_TO_APPLICATION_ID
			  , ALLOC_TO_ENTITY_CODE
			  , ALLOC_TO_SOURCE_ID_NUM_1
			  , ALLOC_TO_SOURCE_ID_NUM_2
			  , ALLOC_TO_SOURCE_ID_NUM_3
			  , ALLOC_TO_SOURCE_ID_NUM_4
			  , ALLOC_TO_SOURCE_ID_CHAR_1
			  , ALLOC_TO_SOURCE_ID_CHAR_2
			  , ALLOC_TO_SOURCE_ID_CHAR_3
			  , ALLOC_TO_SOURCE_ID_CHAR_4
			  , ALLOC_TO_DISTRIBUTION_TYPE
			  , ALLOC_TO_DIST_ID_NUM_1
			  , ALLOC_TO_DIST_ID_NUM_2
			  , ALLOC_TO_DIST_ID_NUM_3
			  , ALLOC_TO_DIST_ID_NUM_4
			  , ALLOC_TO_DIST_ID_NUM_5
			  , ALLOC_TO_DIST_ID_CHAR_1
			  , ALLOC_TO_DIST_ID_CHAR_2
			  , ALLOC_TO_DIST_ID_CHAR_3
			  , ALLOC_TO_DIST_ID_CHAR_4
			  , ALLOC_TO_DIST_ID_CHAR_5
			  , GAIN_OR_LOSS_REF)
			SELECT      /*+ leading(xmap) */
			    XDL.APPLICATION_ID
			  , XDL.EVENT_ID
			  ,                                        XMAP.new_header_id
			  , XDL.AE_LINE_NUM
			  , XDL.SOURCE_DISTRIBUTION_TYPE
			  , XDL.SOURCE_DISTRIBUTION_ID_CHAR_1
			  , XDL.SOURCE_DISTRIBUTION_ID_CHAR_2
			  , XDL.SOURCE_DISTRIBUTION_ID_CHAR_3
			  , XDL.SOURCE_DISTRIBUTION_ID_CHAR_4
			  , XDL.SOURCE_DISTRIBUTION_ID_CHAR_5
			  , XDL.SOURCE_DISTRIBUTION_ID_NUM_1
			  , XDL.SOURCE_DISTRIBUTION_ID_NUM_2
			  , XDL.SOURCE_DISTRIBUTION_ID_NUM_3
			  , XDL.SOURCE_DISTRIBUTION_ID_NUM_4
			  , XDL.SOURCE_DISTRIBUTION_ID_NUM_5
			  , XDL.TAX_LINE_REF_ID
			  , XDL.TAX_SUMMARY_LINE_REF_ID
			  , XDL.TAX_REC_NREC_DIST_REF_ID
			  , XDL.STATISTICAL_AMOUNT
			  , 									XDL.ref_ae_header_id  -- REF_AE_HEADER_ID
			  ,                                   	NULL           -- REF_TEMP_LINE_NUM
			  , XDL.ACCOUNTING_LINE_CODE
			  , XDL.ACCOUNTING_LINE_TYPE_CODE
			  , XDL.MERGE_DUPLICATE_CODE
			  -- Taking Absolute Value to ensure we always create reversal entries (even if it means DOUBLE
			  -- REVERSAL) and adding a LARGE VALUE to ensure that PREPAYMENT ADJUSTED cases where +ve/-ve
			  -- exists in the SAME HEADER doesn't cause UNIQUE CONSTRAINT EXCEPTION because of ABS value.
			  , 									ABS( XDL.TEMP_LINE_NUM + 5000000 )
			  , XDL.REF_EVENT_ID
			  , XDL.LINE_DEFINITION_OWNER_CODE
			  , XDL.LINE_DEFINITION_CODE
			  , XDL.EVENT_CLASS_CODE
			  , XDL.EVENT_TYPE_CODE
			  , XDL.UPG_BATCH_ID
			  , XDL.CALCULATE_ACCTD_AMTS_FLAG
			  , XDL.CALCULATE_G_L_AMTS_FLAG
			  , XDL.ROUNDING_CLASS_CODE
			  , XDL.DOCUMENT_ROUNDING_LEVEL
			  , XDL.UNROUNDED_ENTERED_DR              -- retain XDL unrounded entered dr
			  , XDL.UNROUNDED_ENTERED_CR              -- retain XDL unrounded entered cr
			  , XDL.DOC_ROUNDING_ENTERED_AMT
			  , XDL.DOC_ROUNDING_ACCTD_AMT

	,DECODE(XAL.currency_code, XHC.sec_alc_currency_code, XDL.UNROUNDED_ENTERED_CR,
		-- if ledger currency transaction for secondary then set unrounded accounted to unrouned entered
		-- if not ledger currency transaction for secondary ledger then use either of following
	    DECODE(XHC.sec_alc_mau,NULL,

		     (((  DECODE(XHC.conversion_option, 'D', NVL(XDL.UNROUNDED_ACCOUNTED_CR, XDL.UNROUNDED_ENTERED_CR),XDL.UNROUNDED_ENTERED_CR)
			  /XRUR.denominator_rate
			) * XRUR.numerator_rate)
		     ),

		     (((  DECODE(XHC.conversion_option, 'D',NVL(XDL.UNROUNDED_ACCOUNTED_CR, XDL.UNROUNDED_ENTERED_CR),XDL.UNROUNDED_ENTERED_CR)
			  /XRUR.denominator_rate
			) * XRUR.numerator_rate)
			  /XHC.sec_alc_mau)*XHC.sec_alc_mau
		   )
	      )   -- XDL.UNROUNDED_ACCOUNTED_CR

	,DECODE(XAL.currency_code, XHC.sec_alc_currency_code, XDL.UNROUNDED_ENTERED_DR,
		  -- if ledger currency transaction for secondary then set unrounded accounted to unrouned entered
		  -- if not ledger currency transaction for secondary ledger then use either of following
		DECODE(XHC.sec_alc_mau,NULL,

			 (((  DECODE(XHC.conversion_option, 'D', NVL(XDL.UNROUNDED_ACCOUNTED_DR, XDL.UNROUNDED_ENTERED_DR),XDL.UNROUNDED_ENTERED_DR)
			      /XRUR.denominator_rate
			   )  *XRUR.numerator_rate)
			 ),

			 (((  DECODE(XHC.conversion_option, 'D',NVL(XDL.UNROUNDED_ACCOUNTED_DR, XDL.UNROUNDED_ENTERED_DR),XDL.UNROUNDED_ENTERED_DR)
			      /XRUR.denominator_rate
			    ) * XRUR.numerator_rate)
			      /XHC.sec_alc_mau)*XHC.sec_alc_mau
		      )
		)     -- XDL.UNROUNDED_ACCOUNTED_DR
			  , XDL.APPLIED_TO_APPLICATION_ID
			  , XDL.APPLIED_TO_ENTITY_CODE
			  , XDL.APPLIED_TO_ENTITY_ID
			  , XDL.APPLIED_TO_SOURCE_ID_NUM_1
			  , XDL.APPLIED_TO_SOURCE_ID_NUM_2
			  , XDL.APPLIED_TO_SOURCE_ID_NUM_3
			  , XDL.APPLIED_TO_SOURCE_ID_NUM_4
			  , XDL.APPLIED_TO_SOURCE_ID_CHAR_1
			  , XDL.APPLIED_TO_SOURCE_ID_CHAR_2
			  , XDL.APPLIED_TO_SOURCE_ID_CHAR_3
			  , XDL.APPLIED_TO_SOURCE_ID_CHAR_4
			  , XDL.APPLIED_TO_DISTRIBUTION_TYPE
			  , XDL.APPLIED_TO_DIST_ID_NUM_1
			  , XDL.APPLIED_TO_DIST_ID_NUM_2
			  , XDL.APPLIED_TO_DIST_ID_NUM_3
			  , XDL.APPLIED_TO_DIST_ID_NUM_4
			  , XDL.APPLIED_TO_DIST_ID_NUM_5
			  , XDL.APPLIED_TO_DIST_ID_CHAR_1
			  , XDL.APPLIED_TO_DIST_ID_CHAR_2
			  , XDL.APPLIED_TO_DIST_ID_CHAR_3
			  , XDL.APPLIED_TO_DIST_ID_CHAR_4
			  , XDL.APPLIED_TO_DIST_ID_CHAR_5
			  , XDL.ALLOC_TO_APPLICATION_ID
			  , XDL.ALLOC_TO_ENTITY_CODE
			  , XDL.ALLOC_TO_SOURCE_ID_NUM_1
			  , XDL.ALLOC_TO_SOURCE_ID_NUM_2
			  , XDL.ALLOC_TO_SOURCE_ID_NUM_3
			  , XDL.ALLOC_TO_SOURCE_ID_NUM_4
			  , XDL.ALLOC_TO_SOURCE_ID_CHAR_1
			  , XDL.ALLOC_TO_SOURCE_ID_CHAR_2
			  , XDL.ALLOC_TO_SOURCE_ID_CHAR_3
			  , XDL.ALLOC_TO_SOURCE_ID_CHAR_4
			  , XDL.ALLOC_TO_DISTRIBUTION_TYPE
			  , XDL.ALLOC_TO_DIST_ID_NUM_1
			  , XDL.ALLOC_TO_DIST_ID_NUM_2
			  , XDL.ALLOC_TO_DIST_ID_NUM_3
			  , XDL.ALLOC_TO_DIST_ID_NUM_4
			  , XDL.ALLOC_TO_DIST_ID_NUM_5
			  , XDL.ALLOC_TO_DIST_ID_CHAR_1
			  , XDL.ALLOC_TO_DIST_ID_CHAR_2
			  , XDL.ALLOC_TO_DIST_ID_CHAR_3
			  , XDL.ALLOC_TO_DIST_ID_CHAR_4
			  , XDL.ALLOC_TO_DIST_ID_CHAR_5
			  , GAIN_OR_LOSS_REF
			 FROM xla_historic_control XHC,
			      xla_historic_mapping_gt XMAP,
			      xla_ae_lines XAL,
			      xla_distribution_links XDL,
			      xla_rc_upgrade_rates XRUR
			WHERE XHC.primary_ledger = p_primary_ledger_id          -- worker input
			  AND XHC.secondary_alc_ledger = p_sec_alc_ledger_id    -- worker input
			  AND XHC.upgrade_id = p_ugprade_id                     -- worker input
			  AND XHC.application_id = p_application_id             -- worker input
			  AND XHC.script_name  = p_script_name                  -- worker input
			  AND XHC.relationship_id = p_relationship_id           -- worker input
			  AND XHC.status = 'PHASE-DATA-START'
			  AND XMAP.primary_header_id = XAL.ae_header_id
			  AND XAL.application_id = XHC.application_id
			  AND XAL.gain_or_loss_flag <> DECODE(XHC.conversion_option, 'D',' ','Y')
			  AND XDL.application_id = XAL.application_id
			  AND XDL.ae_header_id = XAL.ae_header_id               -- primary header id
			  AND XDL.ae_line_num = XAL.ae_line_num
			  AND XRUR.upgrade_run_id = XHC.upgrade_id
			  AND XRUR.relationship_id = XHC.relationship_id
			  AND XRUR.to_currency = XHC.sec_alc_currency_code
			  AND XRUR.from_currency = DECODE(XHC.conversion_option, 'D',
							  XHC.primary_currency_code,  -- functional currency of primary in case of D, single rate
							  XAL.currency_code);         -- entered currency in XAL in case of I, multiple rates


			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

				trace
				  (p_msg      => 'Rows inserted into xla_distribution_links: ' || SQL%ROWCOUNT ||' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS') -- to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
				   ,p_level    => C_LEVEL_PROCEDURE
				   ,p_module   => l_log_module);

			END IF;



			INSERT INTO XLA_AE_LINES
			(   AE_HEADER_ID
			  , AE_LINE_NUM
			  , APPLICATION_ID
			  , CODE_COMBINATION_ID
			  , GL_TRANSFER_MODE_CODE
			  , GL_SL_LINK_ID
			  , ACCOUNTING_CLASS_CODE
			  , PARTY_ID
			  , PARTY_SITE_ID
			  , PARTY_TYPE_CODE
			  ,			ENTERED_DR
			  ,			ENTERED_CR
			  ,			ACCOUNTED_DR
			  ,			ACCOUNTED_CR
			  , DESCRIPTION
			  , STATISTICAL_AMOUNT
			  , CURRENCY_CODE
			  , CURRENCY_CONVERSION_DATE
			  , CURRENCY_CONVERSION_RATE
			  , CURRENCY_CONVERSION_TYPE
			  , USSGL_TRANSACTION_CODE
			  , JGZZ_RECON_REF
			  , CONTROL_BALANCE_FLAG
			  , ANALYTICAL_BALANCE_FLAG
			  , ATTRIBUTE_CATEGORY
			  , ATTRIBUTE1
			  , ATTRIBUTE2
			  , ATTRIBUTE3
			  , ATTRIBUTE4
			  , ATTRIBUTE5
			  , ATTRIBUTE6
			  , ATTRIBUTE7
			  , ATTRIBUTE8
			  , ATTRIBUTE9
			  , ATTRIBUTE10
			  , ATTRIBUTE11
			  , ATTRIBUTE12
			  , ATTRIBUTE13
			  , ATTRIBUTE14
			  , ATTRIBUTE15
			  , GL_SL_LINK_TABLE
			  , DISPLAYED_LINE_NUMBER
			  , CREATION_DATE
			  , CREATED_BY
			  , LAST_UPDATE_DATE
			  , LAST_UPDATED_BY
			  , LAST_UPDATE_LOGIN
			  , PROGRAM_UPDATE_DATE
			  , PROGRAM_APPLICATION_ID
			  , PROGRAM_ID
			  , REQUEST_ID
			  , UPG_BATCH_ID
			  , UPG_TAX_REFERENCE_ID1
			  , UPG_TAX_REFERENCE_ID2
			  , UPG_TAX_REFERENCE_ID3
			  ,				UNROUNDED_ACCOUNTED_DR
			  ,				UNROUNDED_ACCOUNTED_CR
			  , GAIN_OR_LOSS_FLAG
			  ,				UNROUNDED_ENTERED_DR
			  ,				UNROUNDED_ENTERED_CR
			  , SUBSTITUTED_CCID
			  , BUSINESS_CLASS_CODE
			  , MPA_ACCRUAL_ENTRY_FLAG
			  , ENCUMBRANCE_TYPE_ID
			  , FUNDS_STATUS_CODE
			  , MERGE_CODE_COMBINATION_ID
			  , MERGE_PARTY_ID
			  , MERGE_PARTY_SITE_ID
			  , ACCOUNTING_DATE
			  , LEDGER_ID
			  , SOURCE_TABLE
			  , SOURCE_ID
			  , ACCOUNT_OVERLAY_SOURCE_ID  )
			SELECT  /*+ leading(xmap) */
									      XMAP.new_header_id
			  , XAL.AE_LINE_NUM
			  , XAL.APPLICATION_ID
			  , XAL.CODE_COMBINATION_ID
			  , XAL.GL_TRANSFER_MODE_CODE
			  ,                                                   NULL     --GL_SL_LINK_ID
			  , XAL.ACCOUNTING_CLASS_CODE
			  , XAL.PARTY_ID
			  , XAL.PARTY_SITE_ID
			  , XAL.PARTY_TYPE_CODE
			  , XAL.ENTERED_DR
			  , XAL.ENTERED_CR
			  , DECODE(XAL.currency_code, XHC.sec_alc_currency_code,
					    ENTERED_DR,
					    DECODE(XHC.sec_alc_mau,NULL,
						ROUND(((DECODE(XHC.conversion_option, 'D',
							NVL(XAL.ACCOUNTED_DR, XAL.ENTERED_DR),
							XAL.ENTERED_DR)/XRUR.denominator_rate)*
								XRUR.numerator_rate),XHC.sec_alc_precision),
						ROUND(((DECODE(XHC.conversion_option, 'D',
							NVL(XAL.ACCOUNTED_DR, XAL.ENTERED_DR),
							XAL.ENTERED_DR)/XRUR.denominator_rate)*
							       XRUR.numerator_rate)/XHC.sec_alc_mau)*XHC.sec_alc_mau))
			  , DECODE(XAL.currency_code,XHC.sec_alc_currency_code,
					    ENTERED_CR,
					    DECODE(XHC.sec_alc_mau,NULL,
						ROUND(((DECODE(XHC.conversion_option, 'D',
							NVL(XAL.ACCOUNTED_CR, XAL.ENTERED_CR),
							XAL.ENTERED_CR)/XRUR.denominator_rate)*
								XRUR.numerator_rate),XHC.sec_alc_precision),
						ROUND(((DECODE(XHC.conversion_option, 'D',
							NVL(XAL.ACCOUNTED_CR, XAL.ENTERED_CR),
							XAL.ENTERED_CR)/XRUR.denominator_rate)*
							       XRUR.numerator_rate)/XHC.sec_alc_mau)*XHC.sec_alc_mau))
			  , XAL.DESCRIPTION
			  , XAL.STATISTICAL_AMOUNT
			  , XAL.CURRENCY_CODE
			  , DECODE(XAL.currency_code,XHC.sec_alc_currency_code,
				   null,
				   DECODE(XHC.conversion_option, 'D',
					NVL(XAL.CURRENCY_CONVERSION_DATE, XAL.ACCOUNTING_DATE),
							XHC.currency_conversion_date))                   -- CURRENCY_CONVERSION_DATE
			  , DECODE(XAL.currency_code,XHC.sec_alc_currency_code,
				   null,
				   DECODE(XHC.conversion_option, 'D',
					NVL(XAL.currency_conversion_rate,1)*XRUR.conversion_rate,
							XRUR.conversion_rate))                        -- CURRENCY_CONVERSION_RATE
			  , DECODE(XAL.currency_code,XHC.sec_alc_currency_code,
				   null,
				   DECODE(XHC.conversion_option, 'D',
							NVL(XAL.CURRENCY_CONVERSION_TYPE, 'EMU FIXED'),
							g_currency_conversion_type))                   --CURRENCY_CONVERSION_TYPE

			  , XAL.USSGL_TRANSACTION_CODE
			  , XAL.JGZZ_RECON_REF
			  , NULL                                     --XAL.CONTROL_BALANCE_FLAG
			  , XAL.ANALYTICAL_BALANCE_FLAG
			  , XAL.ATTRIBUTE_CATEGORY
			  , XAL.ATTRIBUTE1
			  , XAL.ATTRIBUTE2
			  , XAL.ATTRIBUTE3
			  , XAL.ATTRIBUTE4
			  , XAL.ATTRIBUTE5
			  , XAL.ATTRIBUTE6
			  , XAL.ATTRIBUTE7
			  , XAL.ATTRIBUTE8
			  , XAL.ATTRIBUTE9
			  , XAL.ATTRIBUTE10
			  , XAL.ATTRIBUTE11
			  , XAL.ATTRIBUTE12
			  , XAL.ATTRIBUTE13
			  , XAL.ATTRIBUTE14
			  , XAL.ATTRIBUTE15
			  , XAL.GL_SL_LINK_TABLE
			  , XAL.DISPLAYED_LINE_NUMBER
			  ,					SYSDATE
			  ,					fnd_global.user_id
			  ,					SYSDATE
			  ,					fnd_global.user_id
			  ,					fnd_global.login_id
			  ,					SYSDATE
			  ,					-602
			  ,					-602
			  ,					XHC.upgrade_id
			  , XAL.UPG_BATCH_ID
			  , XAL.UPG_TAX_REFERENCE_ID1
			  , XAL.UPG_TAX_REFERENCE_ID2
			  , XAL.UPG_TAX_REFERENCE_ID3
			  , DECODE(XAL.currency_code, XHC.sec_alc_currency_code,
				     UNROUNDED_ENTERED_DR,
				     DECODE(XHC.sec_alc_mau,null,
				       (((DECODE(XHC.conversion_option, 'D',
					 NVL(XAL.UNROUNDED_ACCOUNTED_DR, XAL.UNROUNDED_ENTERED_DR),
					   XAL.UNROUNDED_ENTERED_DR)/XRUR.denominator_rate)*
					     XRUR.numerator_rate)),
				       (((DECODE(XHC.conversion_option, 'D',
					 NVL(XAL.UNROUNDED_ACCOUNTED_DR, XAL.UNROUNDED_ENTERED_DR),
					   XAL.UNROUNDED_ENTERED_DR)/XRUR.denominator_rate)*
					     XRUR.numerator_rate)/XHC.sec_alc_mau)*XHC.sec_alc_mau))  --UNROUNDED_ACCOUNTED_DR
			 , DECODE(XAL.currency_code, XHC.sec_alc_currency_code,
				     UNROUNDED_ENTERED_CR,
				     DECODE(XHC.sec_alc_mau,null,
				       (((DECODE(XHC.conversion_option, 'D',
					 NVL(XAL.UNROUNDED_ACCOUNTED_CR, XAL.UNROUNDED_ENTERED_CR),
					   XAL.UNROUNDED_ENTERED_CR)/XRUR.denominator_rate)*
					     XRUR.numerator_rate)),
				       (((DECODE(XHC.conversion_option, 'D',
					 NVL(XAL.UNROUNDED_ACCOUNTED_CR, XAL.UNROUNDED_ENTERED_CR),
					   XAL.UNROUNDED_ENTERED_CR)/XRUR.denominator_rate)*
			     XRUR.numerator_rate)/XHC.sec_alc_mau)*XHC.sec_alc_mau))                  --UNROUNDED_ACCOUNTED_CR
			  , XAL.GAIN_OR_LOSS_FLAG
			  , XAL.UNROUNDED_ENTERED_DR
			  , XAL.UNROUNDED_ENTERED_CR
			  , XAL.SUBSTITUTED_CCID
			  , XAL.BUSINESS_CLASS_CODE
			  , XAL.MPA_ACCRUAL_ENTRY_FLAG
			  , XAL.ENCUMBRANCE_TYPE_ID
			  , XAL.FUNDS_STATUS_CODE
			  , XAL.MERGE_CODE_COMBINATION_ID
			  , XAL.MERGE_PARTY_ID
			  , XAL.MERGE_PARTY_SITE_ID
			  , XAL.ACCOUNTING_DATE
			  ,                                         XHC.secondary_alc_ledger
			  , XAL.SOURCE_TABLE
			  , XAL.SOURCE_ID
			  , XAL.ACCOUNT_OVERLAY_SOURCE_ID
			FROM xla_historic_control XHC,
			      xla_historic_mapping_gt XMAP,
			      xla_ae_lines XAL,
			      xla_rc_upgrade_rates XRUR
			WHERE XHC.primary_ledger = p_primary_ledger_id          -- worker input
			  AND XHC.secondary_alc_ledger = p_sec_alc_ledger_id    -- worker input
			  AND XHC.upgrade_id = p_ugprade_id                     -- worker input
			  AND XHC.application_id = p_application_id             -- worker input
			  AND XHC.script_name  = p_script_name                  -- worker input
			  AND XHC.relationship_id = p_relationship_id           -- worker input
			  AND XHC.status = 'PHASE-DATA-START'
			  AND XMAP.primary_header_id = XAL.ae_header_id      -- primary header id
			  AND XAL.application_id = XHC.application_id
			  AND XAL.gain_or_loss_flag <> DECODE(XHC.conversion_option, 'D',' ','Y')
			  AND XRUR.upgrade_run_id = XHC.upgrade_id
			  AND XRUR.relationship_id = XHC.relationship_id
			  AND XRUR.to_currency = XHC.sec_alc_currency_code
			  AND XRUR.from_currency = DECODE(XHC.conversion_option, 'D',
							  XHC.primary_currency_code,  -- functional currency of primary in case of D, single rate
							  XAL.currency_code);



			IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

				trace
				  (p_msg      => 'Rows inserted into xla_ae_lines: ' || SQL%ROWCOUNT || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS') -- to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
				   ,p_level    => C_LEVEL_PROCEDURE
				   ,p_module   => l_log_module);

			END IF;


		        IF p_ccid_map = 'Y' THEN


				DELETE FROM gl_accts_map_int_gt; -- bug 4564062


				IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
					trace
					 (p_msg      => 'Rows deleted from gl_accts_map_int_gt = ' || SQL%ROWCOUNT
					 ,p_level    => C_LEVEL_PROCEDURE
					 ,p_module   => l_log_module);
				END IF;


				INSERT INTO gl_accts_map_int_gt(coa_mapping_id, from_ccid)
				     SELECT distinct p_mapping_rel_id, code_combination_id
				       FROM xla_ae_lines XAL
				      WHERE application_id = p_application_id
					AND EXISTS (SELECT 1
						      FROM xla_historic_mapping_gt XMAP
						     WHERE XMAP.new_header_id = XAL.ae_header_id);      -- sec/alc header id


				IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

					trace
					  (p_msg      => 'Rows (distinct ccids) inserted into gl_accts_map_int_gt ' || SQL%ROWCOUNT || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
					   ,p_level    => C_LEVEL_PROCEDURE
					   ,p_module   => l_log_module);

				END IF;


				GL_ACCOUNTS_MAP_GRP.MAP(mapping_name =>  p_coa_map_name
						       ,create_ccid  => (NVL(p_dynamic_flag,'N') ='Y' )
						       ,debug        => g_log_enabled);

				UPDATE xla_ae_lines XAL
				   SET code_combination_id = (SELECT (nvl(GL_INT.to_ccid, -1))
							      FROM gl_accts_map_int_gt GL_INT
							      WHERE XAL.code_combination_id = GL_INT.from_ccid
							      AND GL_INT.coa_mapping_id = p_mapping_rel_id)
				 WHERE application_id = p_application_id
				   AND EXISTS (SELECT 1
					       FROM xla_historic_mapping_gt XMAP
					       WHERE XMAP.new_header_id = XAL.ae_header_id);      -- sec/alc header id

				IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

					trace
					  (p_msg      => 'Rows updated in xla_ae_lines with new ccid = ' || SQL%ROWCOUNT || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
					   ,p_level    => C_LEVEL_PROCEDURE
					   ,p_module   => l_log_module);

				END IF;


		       END IF;    --p_ccid_map = 'Y'



		       IF p_calendar_convert = 'Y' THEN

				UPDATE xla_ae_headers XAH
				SET period_name = (SELECT GLS.period_name
						     FROM gl_period_statuses GLS
						    WHERE GLS.ledger_id = p_sec_alc_ledger_id
						      AND GLS.application_id = 101
						      AND GLS.adjustment_period_flag = 'N'
						      AND XAH.accounting_date BETWEEN GLS.start_date AND GLS.end_date
						  )
				 , XAH.upg_batch_id = NULL
				 WHERE XAH.application_id = p_application_id
				 AND XAH.ledger_id = p_sec_alc_ledger_id
				 AND EXISTS (SELECT 1
					     FROM xla_historic_mapping_gt XMAP
					     WHERE XMAP.new_header_id = XAH.ae_header_id);      -- sec/alc header id


				IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

					trace
					  (p_msg      => 'Rows updated in xla_ae_headers with new period and null upgbatchid = ' || SQL%ROWCOUNT || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS') -- to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
					   ,p_level    => C_LEVEL_PROCEDURE
					   ,p_module   => l_log_module);

				END IF;


		       ELSE
				UPDATE xla_ae_headers XAH
				SET XAH.upg_batch_id = NULL
				WHERE XAH.application_id = p_application_id
				AND XAH.ledger_id = p_sec_alc_ledger_id
				AND XAH.upg_batch_id IS NOT NULL
				AND EXISTS (SELECT 1
				       FROM xla_historic_mapping_gt GT
				       WHERE GT.new_header_id = XAH.ae_header_id);

				IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				    trace
				       (p_msg      => 'Rows updated in xla_ae_headers with null upgbatchid: ' || SQL%ROWCOUNT || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
				       ,p_level    => C_LEVEL_PROCEDURE
				       ,p_module   => l_log_module);
				END IF;

		       END IF;   --p_calendar_convert = 'Y'

	ELSE
		IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

		trace
		(p_msg      => 'No Headers to insert, so insert to GT/XDL/XAL Skipped at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
		,p_level    => C_LEVEL_PROCEDURE
		,p_module   => l_log_module);

		END IF;

        END IF;  --  (l_rows_processed <> 0) condition



         ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,    --stamps XAH rowcount only
						       l_end_rowid);

	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		(p_msg      => 'finished calling processed_rowid_range'
		,p_level    => C_LEVEL_PROCEDURE
		,p_module   => l_log_module);
	 END IF;

         COMMIT;   -- GT table cleared for next run


	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		(p_msg      => 'commit in subworker'
		,p_level    => C_LEVEL_PROCEDURE
		,p_module   => l_log_module);
	 END IF;


         -- get new range of rowids
         ad_parallel_updates_pkg.get_rowid_range(l_start_rowid,
					         l_end_rowid,
					         l_any_rows_to_process,
					         p_batch_size,
					         FALSE);

	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		(p_msg      => 'finished calling get_rowid_range'
		,p_level    => C_LEVEL_PROCEDURE
		,p_module   => l_log_module);
	 END IF;


	 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			  (p_msg      => 'LOOP iteration completed ' || l_iterations
			  ,p_level    => C_LEVEL_PROCEDURE
			  ,p_module   => l_log_module);
	 END IF;

END LOOP;

p_retcode := 0;
p_errbuf := 'Subworker successful';


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

	trace
	  (p_msg      => 'Child worker request completed successfully ' || l_child_request || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
	  ,p_level    => C_LEVEL_PROCEDURE
	  ,p_module   => l_log_module);
END IF;
fnd_file.put_line(fnd_file.log, 'Child worker request completed successfully ' || l_child_request || ' at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));


EXCEPTION WHEN GL_INVALID_MAPPING_NAME THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_INVALID_MAPPING_NAME'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: no mapping with the mapping name');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';


WHEN GL_DISABLED_MAPPING THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_DISABLED_MAPPING'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: mapping is disabled, current date is outside the active date range for the mapping');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';


WHEN GL_INVALID_MAPPING_RULES THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_INVALID_MAPPING_RULES'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: mapping rules are incorrectly defined');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';


WHEN GL_MAP_UNEXPECTED_ERROR THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_MAP_UNEXPECTED_ERROR'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: unexpected error');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';


 WHEN GL_BSV_MAP_NO_SOURCE_BAL_SEG THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_BSV_MAP_NO_SOURCE_BAL_SEG'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: source chart of accounts has no balancing segment');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';


WHEN GL_BSV_MAP_NO_TARGET_BAL_SEG THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_BSV_MAP_NO_TARGET_BAL_SEG'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: target chart of accounts has no balancing segment');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';


WHEN GL_BSV_MAP_NO_SEGMENT_MAP THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_BSV_MAP_NO_SEGMENT_MAP'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: no segment mapping for the balancing segment');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';

WHEN GL_BSV_MAP_NO_SINGLE_VALUE THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_BSV_MAP_NO_SINGLE_VALUE'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: no single value to assign to the balancing segment');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';


WHEN GL_BSV_MAP_NO_FROM_SEGMENT THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_BSV_MAP_NO_FROM_SEGMENT'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: no derive-from segment');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';


WHEN GL_BSV_MAP_NOT_BSV_DERIVED THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_BSV_MAP_NOT_BSV_DERIVED'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: derive-from segment is not the balancing segment');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';

WHEN GL_BSV_MAP_SETUP_ERROR THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_BSV_MAP_SETUP_ERROR'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: mapping setup information could not be obtained');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';


WHEN GL_BSV_MAP_MAPPING_ERROR THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_BSV_MAP_MAPPING_ERROR'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: mapping could not be performed');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';


WHEN GL_BSV_MAP_UNEXPECTED_ERROR THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with GL_BSV_MAP_UNEXPECTED_ERROR'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'Exception: unexpected error in BSV mapping information');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(0)';



WHEN g_sub_validation_failed THEN
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with g_sub_validation_failed'
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'XAH rowcount and mapping GT rowcount mismatch');
        p_retcode := 2;
        p_errbuf := 'Subworker failed(1)';


WHEN OTHERS THEN
   	g_error_text := SQLCODE || SQLERRM;
	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace
		   (p_msg      => 'Child worker failed with ' || g_error_text
		   ,p_level    => C_LEVEL_PROCEDURE
		   ,p_module   => l_log_module);
	END IF;
	fnd_file.put_line(fnd_file.log, 'SQL exception child worker = ' || g_error_text);
        p_retcode := 2;
        p_errbuf := 'Subworker failed(2)';

END;


BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;


END xla_hist_ledger_upg_pkg;

/
