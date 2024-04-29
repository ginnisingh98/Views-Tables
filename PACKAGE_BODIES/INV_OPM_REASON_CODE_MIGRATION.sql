--------------------------------------------------------
--  DDL for Package Body INV_OPM_REASON_CODE_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_OPM_REASON_CODE_MIGRATION" AS
/* $Header: INVRCDSB.pls 120.0 2005/10/06 14:06:14 jgogna noship $ */

/*====================================================================
--  PROCEDURE:
--   MIGRATE_REASON_CODE
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate OPM Reason Codes
--
--  PARAMETERS:
--    p_migration_run_id   This is used for message logging.
--    p_commit             Commit flag.
--    x_failure_count      count of the failed lines.An out parameter.
--
--  SYNOPSIS:
--
--    MIGRATE_REASON_CODE (  p_migration_run_id  IN NUMBER
--                          , p_commit IN VARCHAR2
--                          , x_failure_count OUT NUMBER)
--
--  HISTORY
--    5/23/2005 - nchekuri
--====================================================================*/
PROCEDURE MIGRATE_REASON_CODE (  p_migration_run_id  IN NUMBER
                                 , p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE
                                 , x_failure_count OUT NOCOPY NUMBER) IS

l_failure_count NUMBER := 0;
l_success_count NUMBER := 0;
l_reason_id	NUMBER;


CURSOR  opm_reas_cds_cur  IS
SELECT  b.reason_code,
        b.delete_mark,
        tl.reason_desc1,
        b.creation_date,
        b.created_by,
        b.last_updated_by,
        b.last_update_login
   FROM sy_reas_cds_b b, sy_reas_cds_tl tl,
        fnd_languages fl
  WHERE tl.language = fl.language_code
    AND fl.installed_flag = 'B'
    AND b.reason_code = tl.reason_code
    AND b.reason_id IS NULL;

BEGIN

   /* Begin by logging a message that reason_code migration has started */
   gma_common_logging.gma_migration_central_log (
                  p_run_id      => p_migration_run_id
                , p_log_level   => FND_LOG.LEVEL_PROCEDURE
                , p_app_short_name => 'GMA'
                , p_message_token  => 'GMA_MIGRATION_TABLE_STARTED'
                , p_table_name  => 'SY_REAS_CDS'
                , p_context     => 'REASON_CODES');

   FOR l_rec IN opm_reas_cds_cur LOOP

      BEGIN

         SELECT mtl_transaction_reasons_s.nextval
           INTO l_reason_id FROM DUAL;

         INSERT INTO mtl_transaction_reasons
                 (  reason_id
                  , reason_name
                  , description
                  , disable_date
                  , creation_date
                  , created_by
                  , last_update_date
                  , last_updated_by
                  , last_update_login) VALUES
		 (l_reason_id
		, l_rec.reason_code
		, l_rec.reason_desc1
                , DECODE(l_rec.delete_mark,1,SYSDATE,NULL)
		, SYSDATE
		, l_rec.created_by
		, SYSDATE
		, l_rec.last_updated_by
		, l_rec.last_update_login);

         /* set the reason_id column in sy_reas_cds with this new reason_id */

         UPDATE sy_reas_cds_b
            SET reason_id = l_reason_id
          WHERE reason_code = l_rec.reason_code;

      EXCEPTION
         WHEN OTHERS THEN
             /* Failure count goes up by 1 */
             l_failure_count := l_failure_count+1;
             gma_common_logging.gma_migration_central_log (
        	  p_run_id	=> p_migration_run_id
        	, p_log_level   => FND_LOG.LEVEL_UNEXPECTED
        	, p_app_short_name =>'GMA'
        	, p_message_token  => 'GMA_MIGRATION_DB_ERROR'
        	, p_db_error    => sqlerrm
        	, p_table_name  => 'SY_REAS_CDS'
                , p_context	=> 'REASON_CODES');

      END;

      /* If we are here, we take it that a row has been successfully processed */
      l_success_count := l_success_count +1;
   END LOOP;

   /* We now have the total number of rows that failed */
   x_failure_count := l_failure_count;

   /* commit if the flag is set */
   IF ( p_commit = FND_API.G_TRUE)
   THEN
      COMMIT;
   END IF;

   /* End by logging a message that reason_code migration has been succesful */
   gma_common_logging.gma_migration_central_log (
                  p_run_id      => p_migration_run_id
                , p_log_level   => FND_LOG.LEVEL_PROCEDURE
                , p_app_short_name => 'GMA'
                , p_message_token  => 'GMA_MIGRATION_TABLE_SUCCESS'
                , p_table_name  => 'SY_REAS_CDS'
                , p_context     => 'REASON_CODES'
                , p_param1      => l_success_count
                , p_param2      => l_failure_count );
EXCEPTION

WHEN OTHERS THEN

   gma_common_logging.gma_migration_central_log (
	p_run_id	=> p_migration_run_id
	, p_log_level	=> FND_LOG.LEVEL_UNEXPECTED
	, p_app_short_name =>'GMA'
	, p_message_token  => 'GMA_MIGRATION_DB_ERROR'
	, p_db_error	=> sqlerrm
	, p_table_name	=> 'SY_REAS_CDS'
        , p_context	=> 'REASON_CODES');

END MIGRATE_REASON_CODE;

END;

/
