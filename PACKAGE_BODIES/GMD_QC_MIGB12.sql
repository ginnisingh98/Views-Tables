--------------------------------------------------------
--  DDL for Package Body GMD_QC_MIGB12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_MIGB12" AS
/* $Header: gmdmb12b.pls 120.1 2006/09/22 11:48:30 ragsriva noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    gmdmb12b.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMD_QC_MIGB12                                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains migration procedures/functions                  |
 |    for Quality for 12 migration for batch_id.                            |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 +==========================================================================+
*/


/*===========================================================================
--  PROCEDURE
--    get_material_detail_id
--
--  DESCRIPTION:
--    This procedure takes the new batch_id and existing step_no and determines
--    the new material_detail_id for the batch_id/step_no combination.
--
--  PARAMETERS:
--
--    p_migration_run_id    IN  NUMBER         - Migration Id.
--
--    p_key_id              IN  NUMBER         - Key of record that is current.
--                                             - Used for Error reporting.
--
--    p_rec_context         IN  NUMBER         - Record Context of migration.
--                                             - 1 = sample events
--                                             - 2 = gmd_wip_spec.
--
--    p_new_batch_id        IN  NUMBER         - New Batch Id.
--
--    x_new_matl_det_id     OUT NUMBER         - New Material Detail Id
--
--    x_exception_count     OUT NUMBER         - Exception Count
--
--=========================================================================== */

PROCEDURE GET_MATL_DETAIL_ID
( p_migration_run_id IN  NUMBER
, p_key_id           IN  NUMBER
, p_rec_context      IN  NUMBER
, p_new_batch_id     IN  NUMBER
, p_old_mat_det_id   IN  NUMBER
, x_new_matl_det_id  OUT NOCOPY NUMBER
, x_exception_count  OUT NOCOPY NUMBER)

IS


/*==========================================
   Cursor to get existing line_no and type.
  ==========================================*/

CURSOR get_line_info IS
SELECT line_no, line_type
FROM   gme_material_details
WHERE  material_detail_id = p_old_mat_det_id;

l_line_no        gme_material_details.line_no%TYPE;
l_line_type      gme_material_details.line_type%TYPE;

/*==========================================
   Cursor to new material detail id.
  ==========================================*/

CURSOR get_matl_det IS
SELECT material_detail_id
FROM   gme_material_details
WHERE  batch_id = p_new_batch_id
AND    line_no = l_line_no
AND    line_type = l_line_type;

GET_LINE_INFO_ERROR    EXCEPTION;
GET_MATL_DETL_ERROR    EXCEPTION;

l_record               VARCHAR2(35);
l_recordkey            VARCHAR2(35);

BEGIN

x_exception_count := 0;

/*==============================
   Get line_no and line_type.
  ==============================*/

OPEN get_line_info;
FETCH get_line_info INTO l_line_no, l_line_type;
IF (get_line_info%NOTFOUND) THEN
   x_new_matl_det_id := NULL;
   CLOSE get_line_info;
   RAISE GET_LINE_INFO_ERROR;
END IF;
CLOSE get_line_info;

/*==============================
   Get new material detail id.
  ==============================*/

OPEN get_matl_det;
FETCH get_matl_det INTO x_new_matl_det_id;
IF (get_matl_det%NOTFOUND) THEN
   CLOSE get_matl_det;
   x_new_matl_det_id := NULL;
   RAISE GET_MATL_DETL_ERROR;
END IF;
CLOSE get_matl_det;

EXCEPTION

  WHEN GET_LINE_INFO_ERROR THEN

    /*===============================================
       Format the error message based on the context
       that this routine was called from.
      ===============================================*/

    IF (p_rec_context = 1) THEN  -- gmd_sampling_events
       l_record := 'gmd_sampling_events';
       l_recordkey := 'sampling_event_id';
    ELSE   -- gmd_wip_spec_vrs
       l_record := 'gmd_wip_spec_vrs';
       l_recordkey := 'spec_vr_id';
    END IF;

    -- Bug# 5559748 Changed FND_LOG.LEVEL_UNEXPECTED to LEVEL_ERROR
    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_ERROR,
       p_message_token   => 'GMD_MIG_BATCH_LINE',
       p_context         => 'Quality Batch Migration - GMDI',
       p_token1          => 'REC',
       p_token2          => 'KEY',
       p_token3          => 'KEYVAL',
       p_param1          => l_record,
       p_param2          => l_recordkey,
       p_param3          => to_char(p_key_id),
       p_app_short_name  => 'GMD');

      x_exception_count := x_exception_count + 1;

  WHEN GET_MATL_DETL_ERROR THEN

    /*===============================================
       Format the error message based on the context
       that this routine was called from.
      ===============================================*/

    IF (p_rec_context = 1) THEN  -- gmd_sampling_events
       l_record := 'gmd_sampling_events';
       l_recordkey := 'sampling_event_id';
    ELSE   -- gmd_wip_spec_vrs
       l_record := 'gmd_wip_spec_vrs';
       l_recordkey := 'spec_vr_id';
    END IF;

    -- Bug# 5559748 Changed FND_LOG.LEVEL_UNEXPECTED to LEVEL_ERROR
    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_ERROR,
       p_message_token   => 'GMD_MIG_BATCH_DETL',
       p_context         => 'Quality Batch Migration - GMDI',
       p_token1          => 'REC',
       p_token2          => 'KEY',
       p_token3          => 'KEYVAL',
       p_param1          => l_record,
       p_param2          => l_recordkey,
       p_param3          => to_char(p_key_id),
       p_app_short_name  => 'GMD');

      x_exception_count := x_exception_count + 1;

  WHEN OTHERS THEN
     GMA_COMMON_LOGGING.gma_migration_central_log (
        p_run_id => p_migration_run_id,
        p_log_level => FND_LOG.LEVEL_UNEXPECTED,
        p_message_token => 'GMA_MIGRATION_DB_ERROR',
        p_context         => 'Quality Batch Migration - GMDI',
        p_db_error        => SQLERRM,
        p_app_short_name  => 'GMA');

      x_exception_count := x_exception_count + 1;

END GET_MATL_DETAIL_ID;


/*===========================================================================
--  PROCEDURE
--    gmd_qc_migrate_batch_id.
--
--  DESCRIPTION:
--    This procedure migrates batch_ids in Quality for 12.0.
--    It will be run as part of GME migration.  For wip batches that
--    have be closed and re-created this routine will update GMD quality
--    with references to the cloned batch batch_id.
--
--  PARAMETERS:
--
--    p_migration_run_id    IN  NUMBER         - Migration Id.
--
--    p_commit              IN  VARCHAR2       - Commit Flag
--
--    x_exception_count     OUT NUMBER         - Exception Count
--
--=========================================================================== */

PROCEDURE GMD_QC_MIGRATE_BATCH_ID
( p_migration_run_id IN  NUMBER
, p_commit           IN  VARCHAR2
, x_exception_count  OUT NOCOPY NUMBER)

IS

/*=====================================
   Counters for updates.
  =====================================*/

l_samp_event_upd         NUMBER;
l_samples_upd            NUMBER;
l_wip_spec_upd           NUMBER;
l_ss_matl_upd            NUMBER;


/*=====================================
   Cursor to get migrated batches.
  =====================================*/

CURSOR get_mig_batch IS
SELECT old_batch_id, new_batch_id
FROM   gme_batch_mapping_mig;

l_mig_batch     get_mig_batch%ROWTYPE;


/*=====================================
   Cursor to get gmd_sampling_events.
  =====================================*/

CURSOR get_sampling_event IS
SELECT step_no, step_id, material_detail_id, sampling_event_id
FROM   gmd_sampling_events
WHERE  batch_id = l_mig_batch.old_batch_id;

l_sam_event        get_sampling_event%ROWTYPE;

/*=====================================
   Cursor to get new batchstep id.
  =====================================*/

CURSOR get_new_step_id (p_batch_id NUMBER, p_step_no VARCHAR2) IS
SELECT batchstep_id
FROM   gme_batch_steps
WHERE  batch_id = p_batch_id
AND    batchstep_no = p_step_no;

l_new_step_id       gme_batch_steps.batchstep_id%TYPE;

/*=====================================
   Cursor to get gmd_wip_spec_vrs.
  =====================================*/

CURSOR get_wip_spec IS
SELECT step_no, step_id, material_detail_id, spec_vr_id
FROM   gmd_wip_spec_vrs
WHERE  batch_id = l_mig_batch.old_batch_id;

l_wip_spec          get_wip_spec%ROWTYPE;

/*=======================================
   Cursor to get gmd_ss_material_detail.
  =======================================*/

CURSOR get_ss_matl_src IS
SELECT source_id
FROM   gmd_ss_material_sources
WHERE  batch_id = l_mig_batch.old_batch_id;

l_ss_matl           get_ss_matl_src%ROWTYPE;


l_mat_exception_count NUMBER;
l_new_det_id        NUMBER;

NO_MATL_ID            EXCEPTION;
NO_STEP_ID            EXCEPTION;
NO_WIP_MATL_ID        EXCEPTION;
NO_WIP_STEP_ID        EXCEPTION;


BEGIN

x_exception_count := 0;
l_samp_event_upd := 0;
l_samples_upd := 0;
l_wip_spec_upd := 0;
l_ss_matl_upd := 0;

FOR l_mig_batch IN get_mig_batch LOOP

  BEGIN   -- begin for get_mig_batch

     /*===========================================
        Check for batch in gmd_sampling_events.
       ===========================================*/
     FOR l_sam_event IN get_sampling_event LOOP
       BEGIN    -- begin for get_sampling_event
         l_new_step_id := NULL;
         l_new_det_id := NULL;
         IF (l_sam_event.step_id IS NOT NULL) THEN
            OPEN get_new_step_id (l_mig_batch.new_batch_id, l_sam_event.step_no);
            FETCH get_new_step_id INTO l_new_step_id;
            IF (get_new_step_id%NOTFOUND) THEN
               CLOSE get_new_step_id;
               RAISE NO_STEP_ID;
            END IF;
            CLOSE get_new_step_id;
         END IF;

         IF (l_sam_event.material_detail_id IS NOT NULL) THEN
            GET_MATL_DETAIL_ID     (p_migration_run_id,
               l_sam_event.sampling_event_id,
               1,
               l_mig_batch.new_batch_id,
               l_sam_event.material_detail_id,
               l_new_det_id,
               l_mat_exception_count);

            IF (l_mat_exception_count > 0) THEN
               RAISE NO_MATL_ID;
               /*======================================
                  Raise exception to go to next
                  sampling event record.
                  Error logged in called  routine.
                *======================================*/
            END IF;
         END IF;

       /*==================================
          Update gmd_sampling_events and
          gmd_samples.
         ==================================*/

        UPDATE gmd_sampling_events
        SET    batch_id = l_mig_batch.new_batch_id,
               step_id = l_new_step_id,
               material_detail_id = l_new_det_id
        WHERE  sampling_event_id = l_sam_event.sampling_event_id;

        l_samp_event_upd := l_samp_event_upd + 1;


        UPDATE gmd_samples
        SET    batch_id = l_mig_batch.new_batch_id,
               step_id = l_new_step_id,
               material_detail_id = l_new_det_id
        WHERE  sampling_event_id = l_sam_event.sampling_event_id;

        l_samples_upd := l_samples_upd + SQL%ROWCOUNT;

        IF (p_commit = FND_API.G_TRUE) THEN
           COMMIT;
        END IF;

        EXCEPTION   -- for get_sampling_event
            WHEN NO_MATL_ID THEN
               --  get next sampling event record.
               NULL;

            WHEN NO_STEP_ID THEN
              -- Bug# 5559748 Changed FND_LOG.LEVEL_UNEXPECTED to LEVEL_ERROR
              GMA_COMMON_LOGGING.gma_migration_central_log (
                  p_run_id          => p_migration_run_id,
                  p_log_level       => FND_LOG.LEVEL_ERROR,
                  p_message_token   => 'GMD_MIG_BATCH_STEP_ID',
                  p_context         => 'Quality Batch Migration - GSE',
                  p_token1          => 'REC',
                  p_token2          => 'KEY',
                  p_token3          => 'KEYVAL',
                  p_param1          => 'gmd_sampling_events',
                  p_param2          => 'sampling_event_id',
                  p_param3          => to_char(l_sam_event.sampling_event_id),
                  p_app_short_name  => 'GMD');

                 x_exception_count := x_exception_count + 1;

            WHEN OTHERS THEN
                GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id => p_migration_run_id,
                   p_log_level => FND_LOG.LEVEL_UNEXPECTED,
                   p_message_token => 'GMA_MIGRATION_DB_ERROR',
                   p_context         => 'Quality Batch Migration - GSE',
                   p_db_error        => SQLERRM,
                   p_app_short_name  => 'GMA');

                 x_exception_count := x_exception_count + 1;

       END;     -- end for get_sampling_event

     END LOOP;  -- end loop for get_sampling_event.

     /*=========================================
       Check for batch in gmd_wip_spec_vrs.
       =========================================*/
     FOR l_wip_spec IN get_wip_spec LOOP
       BEGIN    -- begin for get_wip_spec
         l_new_step_id := NULL;
         l_new_det_id := NULL;
         IF (l_wip_spec.step_id IS NOT NULL) THEN
            OPEN get_new_step_id (l_mig_batch.new_batch_id, l_wip_spec.step_no);
            FETCH get_new_step_id INTO l_new_step_id;
            IF (get_new_step_id%NOTFOUND) THEN
               CLOSE get_new_step_id;
               RAISE NO_WIP_STEP_ID;
            END IF;
	    CLOSE get_new_step_id;

	 END IF;

	 IF (l_wip_spec.material_detail_id IS NOT NULL) THEN
	    GET_MATL_DETAIL_ID     (p_migration_run_id,
	       l_wip_spec.spec_vr_id,
	       2,
	       l_mig_batch.new_batch_id,
	       l_wip_spec.material_detail_id,
	       l_new_det_id,
	       l_mat_exception_count);
	    IF (l_mat_exception_count > 0) THEN
               RAISE NO_WIP_MATL_ID;
               /*==================================
                  Raise exception to to to next
                  gmd_wip_spec_vrs record.
                  Error logged in called routine.
                 ==================================*/
            END IF;
         END IF;

         UPDATE gmd_wip_spec_vrs
         SET   batch_id = l_mig_batch.new_batch_id,
               step_id = l_new_step_id,
               material_detail_id = l_new_det_id
         WHERE  spec_vr_id = l_wip_spec.spec_vr_id;

         l_wip_spec_upd := l_wip_spec_upd + 1;

         IF (p_commit = FND_API.G_TRUE) THEN
            COMMIT;
         END IF;

         EXCEPTION -- for get-wip-spec

            WHEN NO_WIP_MATL_ID THEN
                NULL;  -- get next record.

            WHEN NO_WIP_STEP_ID THEN
              -- Bug# 5559748 Changed FND_LOG.LEVEL_UNEXPECTED to LEVEL_ERROR
              GMA_COMMON_LOGGING.gma_migration_central_log (
                  p_run_id          => p_migration_run_id,
                  p_log_level       => FND_LOG.LEVEL_ERROR,
                  p_message_token   => 'GMD_MIG_BATCH_STEP_ID',
                  p_context         => 'Quality Batch Migration - GWS',
                  p_token1          => 'REC',
                  p_token2          => 'KEY',
                  p_token3          => 'KEYVAL',
                  p_param1          => 'gmd_wip_spec_vrs',
                  p_param2          => 'spec_vr_id',
                  p_param3          => to_char(l_wip_spec.spec_vr_id),
                  p_app_short_name  => 'GMD');

                 x_exception_count := x_exception_count + 1;


            WHEN OTHERS THEN
                GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id => p_migration_run_id,
                   p_log_level => FND_LOG.LEVEL_UNEXPECTED,
                   p_message_token => 'GMA_MIGRATION_DB_ERROR',
                   p_context         => 'Quality Batch Migration - GWS',
                   p_db_error        => SQLERRM,
                   p_app_short_name  => 'GMA');

                 x_exception_count := x_exception_count + 1;
       END;     -- end for get_sampling_event

     END LOOP;  -- end loop for get_wip_spec

     /*=============================================
        Check gmd_ss_material_source for batch_id.
       =============================================*/

     FOR l_ss_matl IN get_ss_matl_src LOOP
       BEGIN    -- begin for get_ss_matl_src
         UPDATE gmd_ss_material_sources
         SET   batch_id = l_mig_batch.new_batch_id
         WHERE source_id = l_ss_matl.source_id;

         l_ss_matl_upd := l_ss_matl_upd + SQL%ROWCOUNT;

         IF (p_commit = FND_API.G_TRUE) THEN
            COMMIT;
         END IF;

       EXCEPTION -- for get_ss_matl_src

            WHEN OTHERS THEN
                GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id => p_migration_run_id,
                   p_log_level => FND_LOG.LEVEL_UNEXPECTED,
                   p_message_token => 'GMA_MIGRATION_DB_ERROR',
                   p_context         => 'Quality Batch Migration - GSMS',
                   p_db_error        => SQLERRM,
                   p_app_short_name  => 'GMA');

                 x_exception_count := x_exception_count + 1;

       END;     -- begin for get_ss_matl_src

     END LOOP;  -- end loop for get_ss_matl_src


  EXCEPTION   -- for get_mig_batch.
       WHEN OTHERS THEN
           GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id => p_migration_run_id,
              p_log_level => FND_LOG.LEVEL_UNEXPECTED,
              p_message_token => 'GMA_MIGRATION_DB_ERROR',
              p_context         => 'Quality Batch Migration - GMB',
              p_db_error        => SQLERRM,
              p_app_short_name  => 'GMA');

            x_exception_count := x_exception_count + 1;

  END;    --  end for get_mig_batch.

END LOOP;


/*============================
    Log update counts.
  ============================*/
-- Bug# 5559748 Changed FND_LOG.LEVEL_UNEXPECTED to LEVEL_EVENT
GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_BATCH_SUMMARY',
       p_context         => 'Quality Batch Migration',
       p_token1          => 'SAMEVTUPD',
       p_token2          => 'SAMPUPD',
       p_token3          => 'WIPUPD',
       p_token4          => 'MATDET',
       p_param1          => to_char(l_samp_event_upd),
       p_param2          => to_char(l_samples_upd),
       p_param3          => to_char(l_wip_spec_upd),
       p_param4          => to_char(l_ss_matl_upd),
       p_app_short_name  => 'GMD');


END GMD_QC_MIGRATE_BATCH_ID;

END;

/
