--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_STAGE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_STAGE3" AS
/*$Header: ARHLS3WB.pls 120.15 2005/10/30 03:53:17 appldev noship $*/

PROCEDURE WORKER_PROCESS (
    Errbuf                         OUT NOCOPY VARCHAR2,
    Retcode                        OUT NOCOPY VARCHAR2,
    P_BATCH_ID                     IN         NUMBER,
    P_ACTUAL_CONTENT_SRC           IN         VARCHAR2,
    P_RERUN                        IN         VARCHAR2,
    P_ERROR_LIMIT                  IN         NUMBER,
    P_BATCH_MODE_FLAG              IN         VARCHAR2,
    P_USER_ID                      IN         NUMBER,
    --bug 3932987
    --P_SYSDATE                      IN         DATE,
    P_SYSDATE                      IN         VARCHAR2,
    P_LAST_UPDATE_LOGIN            IN         NUMBER,
    P_PROGRAM_ID                   IN         NUMBER,
    P_PROGRAM_APPLICATION_ID       IN         NUMBER,
    P_REQUEST_ID                   IN         NUMBER,
    P_APPLICATION_ID               IN         NUMBER,
    P_GMISS_CHAR                   IN         VARCHAR2,
    P_GMISS_NUM	                   IN         NUMBER,
    P_GMISS_DATE                   IN         DATE,
    P_FLEX_VALIDATION              IN         VARCHAR2,
    P_DSS_SECURITY                 IN         VARCHAR2,
    P_ALLOW_DISABLED_LOOKUP        IN         VARCHAR2,
    P_PROFILE_VERSION              IN         VARCHAR2,
    P_UPDATE_STR_ADDR              IN         VARCHAR2,
    P_MAINTAIN_LOC_HIST            IN         VARCHAR2,
    P_ALLOW_ADDR_CORR              IN         VARCHAR2
) IS

  l_dml_record       HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE;
  l_rerun_flag       VARCHAR2(1) := 'N';
  l_orig_error_count NUMBER;
  l_start_error_id   NUMBER;
  l_current_error_id NUMBER;
  l_real_error_count NUMBER;
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_hwm_stage        NUMBER;
  l_batch_run_before VARCHAR2(1) ;

  -- Bug 4594407
  l_pp_status        VARCHAR2(30);

BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stage 3 WORKER_PROCESS (+)');

  -- construct DML_RECORD_TYPE l_dml_record
  -- value for l_dml_record.RERUN will be decide later.

  l_dml_record.BATCH_ID	              := P_BATCH_ID;
  l_dml_record.ACTUAL_CONTENT_SRC     := P_ACTUAL_CONTENT_SRC;
  l_dml_record.ERROR_LIMIT            := P_ERROR_LIMIT;
  l_dml_record.BATCH_MODE_FLAG        := P_BATCH_MODE_FLAG;
  l_dml_record.USER_ID                := P_USER_ID;
  --bug 3932987
  --l_dml_record.SYSDATE                := P_SYSDATE;
  l_dml_record.SYSDATE                := to_date(P_SYSDATE,'DD-MM-YY HH24:MI:SS');
  l_dml_record.LAST_UPDATE_LOGIN      := P_LAST_UPDATE_LOGIN;
  l_dml_record.PROGRAM_ID	      := P_PROGRAM_ID;
  l_dml_record.PROGRAM_APPLICATION_ID := P_PROGRAM_APPLICATION_ID;
  l_dml_record.REQUEST_ID	      := P_REQUEST_ID;
  l_dml_record.APPLICATION_ID         := P_APPLICATION_ID;
  l_dml_record.GMISS_CHAR             := P_GMISS_CHAR;
  l_dml_record.GMISS_NUM              := P_GMISS_NUM;
  l_dml_record.GMISS_DATE             := P_GMISS_DATE;
  l_dml_record.FLEX_VALIDATION        := P_FLEX_VALIDATION;
  l_dml_record.DSS_SECURITY           := P_DSS_SECURITY;
  l_dml_record.ALLOW_DISABLED_LOOKUP  := P_ALLOW_DISABLED_LOOKUP;
  l_dml_record.PROFILE_VERSION        := P_PROFILE_VERSION;

  SELECT count(rowid) INTO l_orig_error_count
  FROM HZ_IMP_TMP_ERRORS
  WHERE BATCH_ID = l_dml_record.BATCH_ID
    AND REQUEST_ID = l_dml_record.REQUEST_ID;

  -- get the start error_id sequence number
  SELECT hz_imp_errors_s.NEXTVAL INTO l_start_error_id FROM dual;

  LOOP

    -- get the start error_id sequence number
    -- if NO. of errors >= Error Limit, worker should not pick the next WU

    SELECT hz_imp_errors_s.CURRVAL INTO l_current_error_id FROM dual;

    -- if estimated error is greater than error limit
    IF l_current_error_id - l_start_error_id + l_orig_error_count >= l_dml_record.ERROR_LIMIT AND
       l_dml_record.OS IS NOT NUll THEN

      -- get real number of errors
      SELECT count(rowid) INTO l_real_error_count
      FROM HZ_IMP_TMP_ERRORS
      WHERE BATCH_ID = l_dml_record.BATCH_ID
       AND  REQUEST_ID = l_dml_record.REQUEST_ID;

      -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_real_error_count =' || l_real_error_count);

      IF l_real_error_count >= l_dml_record.ERROR_LIMIT THEN

        -- error limit reached , decrease stage in HZ_IMP_WORK_UNITS table
        UPDATE HZ_IMP_WORK_UNITS
        SET STATUS = 'C', STAGE = STAGE-1
        WHERE BATCH_ID = l_dml_record.BATCH_ID
        AND FROM_ORIG_SYSTEM_REF = l_dml_record.FROM_OSR;

        Retcode := 2;
        HZ_IMP_LOAD_STAGE2.ERROR_LIMIT_HANDLING(l_dml_record.BATCH_ID, l_dml_record.BATCH_MODE_FLAG);
        RETURN;
      END IF;
    END IF;

    -- get the next available worker
    l_dml_record.OS := NUll;
    -- Bug 4594407
    HZ_IMP_LOAD_WRAPPER.RETRIEVE_WORK_UNIT(P_BATCH_ID, '3' , l_dml_record.OS, l_dml_record.FROM_OSR, l_dml_record.TO_OSR,
                                           l_hwm_stage, l_pp_status);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Retrieved Work unit');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'wu_os:' || l_dml_record.OS);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'from_osr:' || l_dml_record.FROM_OSR);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'to_osr:' || l_dml_record.TO_OSR);

    IF (l_dml_record.OS IS NULL) Then
      EXIT;
    END IF;


    -- disable policy function
    hz_common_pub.disable_cont_source_security;

    -- IF re-run parameter is 'Unexpected Errors'/'Error Limit Reached',
    -- and current stg < HWM stage, set re-run flag to 'Y'
    -- IF 'completed with errors' , set re-run flag to 'Y'
    -- IF re-run parameter is 'new batch'm set re-run flag to 'N'
    -- IF re-run parameter is 'what-if-resume' THEN
    -- Look at hz_imp_batch_details table to find out if this batch has been run successfully;
    --    IF  batch run before THEN
    --      set l_dml_record.RERUN flag to 'Y';
    --    ELSE
    --      set l_dml_record.RERUN flag to 'N';
    --    END IF;

    /* Bug 4594407
    -- get high worker mark for current worker
    SELECT HWM_STAGE INTO l_hwm_stage
    FROM HZ_IMP_WORK_UNITS
    WHERE BATCH_ID = l_dml_record.BATCH_ID
    AND FROM_ORIG_SYSTEM_REF = l_dml_record.FROM_OSR;
    */

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: P_RERUN = ' || P_RERUN);

    -- set re-run flag
    IF P_RERUN = 'E' THEN
      l_dml_record.RERUN := 'Y';
    ELSIF (P_RERUN = 'U' OR P_RERUN = 'L') AND l_hwm_stage >= 3 THEN
      l_dml_record.RERUN := 'Y';
    ELSIF P_RERUN = 'R' THEN
      BEGIN
        select 'Y' into l_batch_run_before
        from hz_imp_batch_details
        where batch_id =  P_BATCH_ID
          AND ( import_status = 'COMPL_ERRORS' OR  import_status = 'COMPLETED')
          AND rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_batch_run_before := 'N';
      END;
      IF l_batch_run_before = 'Y' THEN
        l_dml_record.RERUN := 'Y';
      ELSE
        l_dml_record.RERUN := 'N';
      END IF;

    ELSE
      l_dml_record.RERUN := 'N';
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: l_dml_record.RERUN = ' || l_dml_record.RERUN);

    -- Invoke concurrent program for 'V+DML' of all other Entities

    -- Load Relatioship
    HZ_IMP_LOAD_RELATIONSHIPS_PKG.load_relationships (
      P_DML_RECORD  	  => l_dml_record,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: load_relationships completed ');

    -- Bug 4594407
    -- Populate staging table for unprocessed post-processing records from previous run
    -- matching of relationships
    IF l_hwm_stage = 3 AND l_pp_status = 'U' THEN
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_RELATIONSHIPS(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        l_dml_record.ACTUAL_CONTENT_SRC,
        'N',
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_RELATIONSHIPS completed ');
    END IF;

    -- Load Org Contact
    HZ_IMP_LOAD_ORG_CONTACT_PKG.load_org_contacts (
      P_DML_RECORD  	  => l_dml_record,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: load_org_contacts completed ');

    -- Bug 4594407
    -- Populate staging table for unprocessed post-processing records from previous run
    -- matching of org contact
    IF l_hwm_stage = 3 AND l_pp_status = 'U' THEN
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_CONTACTS(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        l_dml_record.ACTUAL_CONTENT_SRC,
        'N',
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_CONTACTS completed ');
    END IF;

    -- Load Addresses
    HZ_IMP_LOAD_ADDRESSES_PKG.load_addresses (
      P_DML_RECORD  	  => l_dml_record,
      P_UPDATE_STR_ADDR   => P_UPDATE_STR_ADDR,
      P_MAINTAIN_LOC_HIST => P_MAINTAIN_LOC_HIST,
      P_ALLOW_ADDR_CORR   => P_ALLOW_ADDR_CORR,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: load_addresses completed ');

    -- Bug 4594407
    -- Populate staging table for unprocessed post-processing records from previous run
    -- matching of addresses
    IF l_hwm_stage = 3 AND l_pp_status = 'U' THEN
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_ADDRESSES(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        'N',
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_ADDRESSES completed ');
    END IF;

    -- Load Contact Point
    HZ_IMP_LOAD_CPT_PKG.load_contactpoints (
      P_DML_RECORD  	  => l_dml_record,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: load_contactpoints completed ');

    -- Bug 4594407
    -- Populate staging table for unprocessed post-processing records from previous run
    -- matching of contact points
    IF l_hwm_stage = 3 AND l_pp_status = 'U' THEN
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_CONTACT_POINTS(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        'N',
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_CONTACT_POINTS completed ');
    END IF;

    -- Load Party Site Use
    HZ_IMP_LOAD_PARTY_SITE_USE_PKG.load_partysiteuses (
      P_DML_RECORD  	  => l_dml_record,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: load_partysiteuses completed ');

    -- Load contact Role
    HZ_IMP_LOAD_CONTACT_ROLE_PKG.load_contactroles (
      P_DML_RECORD  	  => l_dml_record,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: load_contactroles completed ');

    -- Load Financial Reports
    HZ_IMP_LOAD_FINREPORTS_PKG.load_finreports (
      P_DML_RECORD  	  => l_dml_record,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: load_finreports completed ');

    -- Load Financial Numbers
    HZ_IMP_LOAD_FINNUMBERS_PKG.load_finnumbers (
      P_DML_RECORD  	  => l_dml_record,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: load_finnumbers completed ');

    -- Load Credit Ratings
    HZ_IMP_LOAD_CREDITRATINGS_PKG.load_creditratings (
      P_DML_RECORD        => l_dml_record,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: load_creditratings completed ');

    -- Load Code Assignments
    HZ_IMP_LOAD_CODE_ASSIGNMENTS.load_code_assignments (
      P_DML_RECORD  	  => l_dml_record,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: load_code_assignments completed ');


    UPDATE HZ_IMP_WORK_UNITS
      SET STATUS = 'C'
    WHERE BATCH_ID = P_BATCH_ID
      AND FROM_ORIG_SYSTEM_REF = l_dml_record.FROM_OSR;

    COMMIT;
  END LOOP;

/* comment out as this will be done in main wrapper

  -- Clean up Staging table
  HZ_IMP_LOAD_WRAPPER.cleanup_staging(l_dml_record.BATCH_ID, l_dml_record.BATCH_MODE_FLAG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: Staging table cleaned up ');

  -- Delete Work Unit
  delete hz_imp_work_units where batch_id = P_BATCH_ID;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: work united deleted');

  -- Change status ton Summary table to 'COMPLELTE'
  update hz_imp_batch_summary
  set IMPORT_STATUS = 'COMPLETED'
  where BATCH_ID = P_BATCH_ID;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: Summary table updated');
*/
  COMMIT;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stage 3 WORKER_PROCESS (-)');

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

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stage 3 worker: SQLERRM: ' || SQLERRM);
  FND_FILE.PUT_LINE(FND_FILE.LOG, SubStr('l_msg_data = '||l_msg_data,1,255));
  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'message[' ||I||']=');
      FND_FILE.PUT_LINE(FND_FILE.LOG, Substr(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ),1,255));
  END LOOP;

END WORKER_PROCESS;


END HZ_IMP_LOAD_STAGE3;

/
