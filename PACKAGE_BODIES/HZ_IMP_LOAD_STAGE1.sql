--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_STAGE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_STAGE1" AS
/*$Header: ARHLS1WB.pls 120.14 2005/10/30 03:53:12 appldev noship $*/

PROCEDURE WORKER_PROCESS (
  Errbuf                      OUT NOCOPY     VARCHAR2,
  Retcode                     OUT NOCOPY     VARCHAR2,
  P_BATCH_ID                  IN             NUMBER,
  P_ACTUAL_CONTENT_SRC        IN             VARCHAR2,
  P_RERUN		      IN	     VARCHAR2,
  P_BATCH_MODE_FLAG	      IN	     VARCHAR2
) IS

  START_TIME        DATE := sysdate;
  P_OS              VARCHAR2(30);
  P_FROM_OSR        VARCHAR2(255);
  P_TO_OSR          VARCHAR2(255);
  l_rerun	    VARCHAR2(1) := 'Y';
  l_hwm_stage       NUMBER := 0;
  -- Bug 4594407
  l_pp_status       VARCHAR2(30);

BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stage 1 WORKER_PROCESS+');

  /* Avoid skip scans in matching */
  execute immediate 'alter session set events ''10196 trace name context forever, level 1''';

  LOOP
    P_OS := NULL;
    -- Bug 4594407
    HZ_IMP_LOAD_WRAPPER.RETRIEVE_WORK_UNIT(P_BATCH_ID, '1' , P_OS, P_FROM_OSR, P_TO_OSR,
                                           l_hwm_stage, l_pp_status);

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_OS = ' || P_OS);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_FROM_OSR = ' || P_FROM_OSR);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_TO_OSR = ' || P_TO_OSR);


    IF (P_OS IS NULL) Then
      EXIT;
    END IF;

    /* If there's some error with the batch in previous run, we need to check
       if the batch has been completed at least once. If not, we need to
       set l_rerun = 'N' such that it'll pick up records with null interface
       status */
    IF P_RERUN = 'U' OR P_RERUN = 'L' THEN
      BEGIN
        select hwm_stage into l_hwm_stage
        from hz_imp_work_units
        where batch_id = P_BATCH_ID
        and orig_system = P_OS
        and from_orig_system_ref = P_FROM_OSR;

        IF l_hwm_stage <= 1 THEN
          l_rerun := 'N';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          l_rerun := 'N';
      END;
    END IF;

    /* If new batch or resume, set re-run flag to 'N'.
       Usually for resume, stage 1 is skipped. But if somehow the staging
       tables are cleaned up after what-if, we need to match parties again.
       So, it we're stage 1 and it's resume, we treat it as a new batch */
    IF P_RERUN = 'N' OR P_RERUN = 'R' THEN
      l_rerun := 'N';
    END IF;

    HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_PARTIES(P_BATCH_ID, P_OS, P_FROM_OSR, P_TO_OSR, P_ACTUAL_CONTENT_SRC, l_rerun, P_BATCH_MODE_FLAG);

    /* Update status to Complete for the work unit that just finished */
    UPDATE HZ_IMP_WORK_UNITS
      SET STATUS = 'C'
    WHERE BATCH_ID = P_BATCH_ID
      AND FROM_ORIG_SYSTEM_REF = P_FROM_OSR;

    COMMIT;

  END LOOP;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stage 1 WORKER_PROCESS-');

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);

    errbuf  := FND_MESSAGE.get;
    retcode := 2;

    UPDATE hz_imp_batch_summary
    SET import_status = 'ERROR'
    WHERE batch_id = P_BATCH_ID;

    UPDATE hz_imp_batch_details
    SET import_status = 'ERROR'
    WHERE batch_id = P_BATCH_ID
    AND run_number = (SELECT max(run_number)
    		      FROM hz_imp_batch_details
    		      WHERE batch_id = P_BATCH_ID);

    COMMIT;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in stage 1 worker: ' || SQLERRM);

END WORKER_PROCESS;


END HZ_IMP_LOAD_STAGE1;

/
