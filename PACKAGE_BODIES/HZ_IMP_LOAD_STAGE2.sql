--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_STAGE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_STAGE2" AS
/*$Header: ARHLS2WB.pls 120.29 2007/09/25 12:48:46 rarajend ship $*/

PROCEDURE ERROR_LIMIT_HANDLING(
  P_BATCH_ID                 IN             NUMBER,
  P_BATCH_MODE_FLAG          IN             VARCHAR2

) IS
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR_LIMIT Reached, return to caller wrapper');

  commit;

  -- update batch summary table and detail table
  -- set statu as complete with error

  update hz_imp_batch_summary
  set IMPORT_STATUS = 'COMPL_ERROR_LIMIT'
  where BATCH_ID = P_BATCH_ID;

  UPDATE hz_imp_batch_details
  SET import_status = 'COMPL_ERROR_LIMIT'
  WHERE batch_id = P_BATCH_ID
  AND run_number = (SELECT max(run_number)
    		      FROM hz_imp_batch_details
    		      WHERE batch_id = P_BATCH_ID);

/* comment out as this will be done in main wrapper

  HZ_IMP_LOAD_WRAPPER.cleanup_staging(P_BATCH_ID, P_BATCH_MODE_FLAG);
*/

  commit;

END ERROR_LIMIT_HANDLING;

PROCEDURE WHAT_IF_ANALYSIS (
  P_BATCH_ID          IN             NUMBER,
  P_OS                IN             VARCHAR2
) IS
BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG,'WHAT_IF_ANALYSIS handling');

  -- update batch summary table and detail table
  -- set statu as action required

  update hz_imp_batch_summary
  set IMPORT_STATUS = 'ACTION_REQUIRED'
  where BATCH_ID = P_BATCH_ID;

  UPDATE hz_imp_batch_details
  SET import_status = 'ACTION_REQUIRED'
  WHERE batch_id = P_BATCH_ID
  AND run_number = (SELECT max(run_number)
    		      FROM hz_imp_batch_details
    		      WHERE batch_id = P_BATCH_ID);

  -- get summary for each entity, update batch summary table
  -- columns like 'NEW_UNIQUE_ADDRESSES' and 'EXISTING_ADDRESSES'
  HZ_IMP_LOAD_BATCH_COUNTS_PKG.what_if_import_counts(P_BATCH_ID, P_OS);

END WHAT_IF_ANALYSIS;


/**********************************************
 * public procedure WORKER_PROCESS
 *
 * DESCRIPTION
 *     Stage 2 WORKER_PROCESS.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     P_BATCH_ID                     IN         NUMBER(15,0),
 *     P_ACTUAL_CONTENT_SRC           IN         VARCHAR2(30),
 *     P_RERUN                        IN         VARCHAR2(1),
 *     P_ERROR_LIMIT                  IN         NUMBER,
 *     P_BATCH_MODE_FLAG              IN         VARCHAR2(1),
 *     P_USER_ID                      IN         NUMBER(15,0),
 *     P_SYSDATE                      IN         DATE,
 *     P_LAST_UPDATE_LOGIN            IN         NUMBER(15,0),
 *     P_PROGRAM_ID                   IN         NUMBER(15,0),
 *     P_PROGRAM_APPLICATION_ID       IN         NUMBER(15,0),
 *     P_REQUEST_ID                   IN         NUMBER(15,0),
 *     P_APPLICATION_ID               IN         NUMBER,
 *     P_GMISS_CHAR                   IN         VARCHAR2(1),
 *     P_GMISS_NUM                    IN         NUMBER,
 *     P_GMISS_DATE                   IN         DATE,
 *     P_FLEX_VALIDATION              IN         VARCHAR2(1),
 *     P_DSS_SECURITY                 IN         VARCHAR2(1),
 *     P_ALLOW_DISABLED_LOOKUP        IN         VARCHAR2(1),
 *     P_PROFILE_VERSION              IN         VARCHAR2(30)
 *     P_WHAT_IF_ANALYSIS             IN         VARCHAR2,
 *     P_REGISTRY_DEDUP               IN         VARCHAR2,
 *     P_REGISTRY_DEDUP_MATCH_RULE_ID IN         VARCHAR2,
 *   OUT:
 *     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
 *     X_MSG_COUNT                    OUT NOCOPY NUMBER,
 *     X_MSG_DATA                     OUT NOCOPY VARCHAR2
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-10-03   Kate Shan    o Created
 *
**********************************************/

PROCEDURE WORKER_PROCESS(
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
    P_WHAT_IF_ANALYSIS             IN         VARCHAR2,
    P_REGISTRY_DEDUP               IN         VARCHAR2,
    P_REGISTRY_DEDUP_MATCH_RULE_ID IN         VARCHAR2
) IS

  l_dml_record       HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE;
  l_hwm_stage        NUMBER;
--  l_rerun_flag       VARCHAR2(1) := 'N';
  l_start_error_id   NUMBER;
  l_current_error_id NUMBER;
  l_real_error_count NUMBER;
  l_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_what_if_sg_data_exists VARCHAR2(1) ;
  l_batch_run_before VARCHAR2(1) ;
  l_os               VARCHAR2(30);
  -- Bug 4594407
  l_pp_status        VARCHAR2(30);

BEGIN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stage 2 WORKER_PROCESS (+)');

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
  l_dml_record.PROGRAM_ID	        := P_PROGRAM_ID;
  l_dml_record.PROGRAM_APPLICATION_ID := P_PROGRAM_APPLICATION_ID;
  l_dml_record.REQUEST_ID	        := P_REQUEST_ID;
  l_dml_record.APPLICATION_ID         := P_APPLICATION_ID;
  l_dml_record.GMISS_CHAR             := P_GMISS_CHAR;
  l_dml_record.GMISS_NUM              := P_GMISS_NUM;
  l_dml_record.GMISS_DATE             := P_GMISS_DATE;
  l_dml_record.FLEX_VALIDATION        := P_FLEX_VALIDATION;
  l_dml_record.DSS_SECURITY           := P_DSS_SECURITY;
  l_dml_record.ALLOW_DISABLED_LOOKUP  := P_ALLOW_DISABLED_LOOKUP;
  l_dml_record.PROFILE_VERSION        := P_PROFILE_VERSION;
  -- get the start error_id sequence number
  SELECT hz_imp_errors_s.NEXTVAL INTO l_start_error_id FROM dual;

  -- check if staging table has data
  l_what_if_sg_data_exists := HZ_IMP_LOAD_WRAPPER.STAGING_DATA_EXISTS(P_BATCH_ID, P_BATCH_MODE_FLAG, 2);

  LOOP

    -- get the start error_id sequence number
    -- if NO. of errors >= Error Limit, worker should not pick the next WU

    --FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: check for error limit');
    SELECT hz_imp_errors_s.CURRVAL INTO l_current_error_id FROM dual;

    -- if estimated error is greater than error limit
    IF l_current_error_id - l_start_error_id >= l_dml_record.ERROR_LIMIT AND
       l_dml_record.OS IS NOT NUll THEN

      -- get real number of errors
      SELECT count(rowid) INTO l_real_error_count
      FROM HZ_IMP_TMP_ERRORS
      WHERE BATCH_ID = l_dml_record.BATCH_ID and
            REQUEST_ID = l_dml_record.REQUEST_ID ;

      -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'Real error count =' || l_real_error_count);

      IF l_real_error_count >= l_dml_record.ERROR_LIMIT THEN

        /* bug 3401629 fix
        -- error limit reached , decrease stage in HZ_IMP_WORK_UNITS table
        UPDATE HZ_IMP_WORK_UNITS
        SET STATUS = 'C', STAGE = STAGE-1
        WHERE BATCH_ID = l_dml_record.BATCH_ID
        AND FROM_ORIG_SYSTEM_REF = l_dml_record.FROM_OSR;
        */

        Retcode := 2;
        ERROR_LIMIT_HANDLING(l_dml_record.BATCH_ID, l_dml_record.BATCH_MODE_FLAG);
        RETURN;
      END IF;
    END IF;


    -- get the next available worker
    l_dml_record.OS := NUll;
    -- Bug 4594407
    HZ_IMP_LOAD_WRAPPER.RETRIEVE_WORK_UNIT(P_BATCH_ID, '2' , l_dml_record.OS, l_dml_record.FROM_OSR, l_dml_record.TO_OSR,
                                           l_hwm_stage, l_pp_status);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Retrieved Work unit');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'wu_os:' || l_dml_record.OS);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'from_osr:' || l_dml_record.FROM_OSR);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'to_osr:' || l_dml_record.TO_OSR);

    IF (l_dml_record.OS IS NULL) Then
      EXIT;
    ELSE
      l_os := l_dml_record.OS;
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

    -- IF rerun flag is not 'R' or  rerun flag is 'R' but no data in staging table
    -- call matching and dqm

    -- IF P_WHAT_IF_ANALYSIS is null OR (P_WHAT_IF_ANALYSIS is not null AND P_WHAT_IF_ANALYSIS <> 'R') THEN
    IF upper(P_RERUN) <> 'R'  OR
       ( upper(P_RERUN) = 'R' and  l_what_if_sg_data_exists = 'N' ) THEN


      -- this event needs to be set for matching (at least)
      -- it disables index skip scans ..which do not want
      -- and there is a cbo bug that makes it look cheaper.
      -- it is session specific, so in the multiple worker case, each worker
      -- must set this at the begining of matching.

      execute immediate 'alter session set events ''10196 trace name context forever, level 1''';


      -- call Matching of Other Entities

      -- matching of relationships
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_RELATIONSHIPS(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        l_dml_record.ACTUAL_CONTENT_SRC,
        l_dml_record.RERUN,
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_RELATIONSHIPS completed ');

      -- matching of org contacts
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_CONTACTS(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        l_dml_record.ACTUAL_CONTENT_SRC,
        l_dml_record.RERUN,
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_CONTACTS completed ');

      -- matching of addresses
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_ADDRESSES(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
--        l_dml_record.ACTUAL_CONTENT_SRC,
        l_dml_record.RERUN,
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_ADDRESSES completed ');

      -- matching of contact points
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_CONTACT_POINTS(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
--        l_dml_record.ACTUAL_CONTENT_SRC,
        l_dml_record.RERUN,
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_CONTACT_POINTS completed ');

      -- matching of party site use
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_ADDRUSES(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        l_dml_record.ACTUAL_CONTENT_SRC,
        l_dml_record.RERUN,
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_ADDRUSES completed ');

      -- matching of contact role
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_CONTACTROLES(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        l_dml_record.ACTUAL_CONTENT_SRC,
        l_dml_record.RERUN,
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_CONTACTROLES completed ');

      -- matching of financial reports
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_FINANCIAL_REPORTS(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        l_dml_record.ACTUAL_CONTENT_SRC,
        l_dml_record.RERUN,
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_FINANCIAL_REPORTS completed ');

      -- matching of financial numbers
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_FINANCIAL_NUMBERS(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        l_dml_record.ACTUAL_CONTENT_SRC,
        l_dml_record.RERUN,
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_FINANCIAL_NUMBERS completed ');

      -- matching of credit ratings
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_CREDIT_RATINGS(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        l_dml_record.SYSDATE,
        l_dml_record.ACTUAL_CONTENT_SRC,
        l_dml_record.RERUN,
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_CREDIT_RATINGS completed ');

      -- matching of code assignments
      HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_CODE_ASSIGNMENTS(
        l_dml_record.BATCH_ID,
        l_dml_record.OS,
        l_dml_record.FROM_OSR,
        l_dml_record.TO_OSR,
        l_dml_record.ACTUAL_CONTENT_SRC,
        l_dml_record.RERUN,
        l_dml_record.BATCH_MODE_FLAG
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_CODE_ASSIGNMENTS completed ');

      IF P_REGISTRY_DEDUP = 'Y' THEN

        -- fetch record for DQM

        -- IF re-run parameter is or 'Error Limit Reached',
        -- or 'completed with errors' , or 'What-If Resume'
	-- or 'Unexpected Errors' with current stg < HWM
        -- set table with new Ids Generated by matching,
        -- If re-run parameter is  'new batch', call DQM

        IF  P_RERUN = 'L' OR
            P_RERUN = 'E' OR
            (P_RERUN = 'R'  and  l_what_if_sg_data_exists = 'Y')  OR
            (P_RERUN = 'U' AND l_hwm_stage >= 3)
        THEN

          FND_FILE.PUT_LINE(FND_FILE.LOG, 'update dup party id ');

	  -- update dup party id
          UPDATE HZ_IMP_DUP_PARTIES idp
          SET PARTY_ID =
             ( SELECT PARTY_ID FROM HZ_IMP_PARTIES_SG ips
               WHERE ips.PARTY_ORIG_SYSTEM = idp.PARTY_OS
                 and ips.PARTY_ORIG_SYSTEM_REFERENCE = idp.PARTY_OSR
                 and ips.BATCH_ID = P_BATCH_ID)
          WHERE idp.BATCH_ID = P_BATCH_ID
            AND idp.PARTY_OS = l_dml_record.OS
            AND idp.PARTY_OSR BETWEEN l_dml_record.FROM_OSR AND l_dml_record.TO_OSR
             AND idp.PARTY_OSR IN (SELECT PARTY_ORIG_SYSTEM_REFERENCE
                                  FROM HZ_IMP_PARTIES_SG
                                  WHERE BATCH_ID = P_BATCH_ID
                                  AND PARTY_ORIG_SYSTEM = idp.PARTY_OS
                                  AND PARTY_ORIG_SYSTEM_REFERENCE BETWEEN l_dml_record.FROM_OSR AND l_dml_record.TO_OSR);

          -- update dup party site
          UPDATE HZ_IMP_DUP_DETAILS idd
          SET (PARTY_ID, RECORD_ID)=
              ( SELECT PARTY_ID, PARTY_SITE_ID FROM HZ_IMP_ADDRESSES_SG ias
                WHERE ias.PARTY_ORIG_SYSTEM = idd.PARTY_OS
                  and ias.PARTY_ORIG_SYSTEM_REFERENCE = idd.PARTY_OSR
                  and ias.SITE_ORIG_SYSTEM = idd.RECORD_OS
                  and ias.SITE_ORIG_SYSTEM_REFERENCE = idd.RECORD_OSR
                  and ias.BATCH_ID = P_BATCH_ID)
          WHERE ENTITY = 'PARTY_SITES'
            and idd.BATCH_ID = P_BATCH_ID
            AND idd.PARTY_OS = l_dml_record.OS
            AND idd.PARTY_OSR BETWEEN l_dml_record.FROM_OSR AND l_dml_record.TO_OSR
            AND idd.PARTY_OSR IN (SELECT PARTY_ORIG_SYSTEM_REFERENCE
                                  FROM HZ_IMP_ADDRESSES_SG
                                  WHERE BATCH_ID = P_BATCH_ID
                                  AND PARTY_ORIG_SYSTEM = idd.PARTY_OS
                                  AND PARTY_ORIG_SYSTEM_REFERENCE BETWEEN l_dml_record.FROM_OSR AND l_dml_record.TO_OSR);


	  -- update dup contact

          UPDATE HZ_IMP_DUP_DETAILS idd
          SET (PARTY_ID, RECORD_ID)=
              ( SELECT PARTY_ID, CONTACT_ID FROM HZ_IMP_CONTACTS_SG ics
                WHERE ics.CONTACT_ORIG_SYSTEM = idd.RECORD_OS
                  and ics.CONTACT_ORIG_SYSTEM_REFERENCE = idd.RECORD_OSR
                  and ics.BATCH_ID = P_BATCH_ID)
          WHERE ENTITY = 'CONTACTS'
            and idd.BATCH_ID = P_BATCH_ID
            AND idd.PARTY_OS = l_dml_record.OS
            AND idd.PARTY_OSR BETWEEN l_dml_record.FROM_OSR AND l_dml_record.TO_OSR
            AND idd.RECORD_OSR IN (SELECT CONTACT_ORIG_SYSTEM_REFERENCE
                                  FROM HZ_IMP_CONTACTS_SG
                                  WHERE BATCH_ID = P_BATCH_ID
                                  AND CONTACT_ORIG_SYSTEM = idd.RECORD_OS
                                  AND SUB_ORIG_SYSTEM_REFERENCE BETWEEN l_dml_record.FROM_OSR AND l_dml_record.TO_OSR);


	  -- update dup contact point

          UPDATE HZ_IMP_DUP_DETAILS idd
          SET (PARTY_ID, RECORD_ID)=
              ( SELECT PARTY_ID, CONTACT_POINT_ID FROM HZ_IMP_CONTACTPTS_SG ics
                WHERE ics.PARTY_ORIG_SYSTEM = idd.PARTY_OS
                  and ics.PARTY_ORIG_SYSTEM_REFERENCE = idd.PARTY_OSR
                  and ics.BATCH_ID = P_BATCH_ID)
          WHERE ENTITY = 'CONTACT_POINTS'
            and idd.BATCH_ID = P_BATCH_ID
            AND idd.PARTY_OS = l_dml_record.OS
            AND idd.PARTY_OSR BETWEEN l_dml_record.FROM_OSR AND l_dml_record.TO_OSR
            AND idd.PARTY_OSR IN (SELECT PARTY_ORIG_SYSTEM_REFERENCE
                                  FROM HZ_IMP_CONTACTPTS_SG
                                  WHERE BATCH_ID = P_BATCH_ID
                                  AND PARTY_ORIG_SYSTEM = idd.PARTY_OS
                                  AND PARTY_ORIG_SYSTEM_REFERENCE BETWEEN l_dml_record.FROM_OSR AND l_dml_record.TO_OSR);

        ELSE

          FND_FILE.PUT_LINE(FND_FILE.LOG, 'calling DQM ');
          HZ_DQM_DUP_ID_PKG.interface_tca_dup_id (
            p_batch_id               => l_dml_record.BATCH_ID,
            p_match_rule_id          => P_REGISTRY_DEDUP_MATCH_RULE_ID,
            p_from_osr               => l_dml_record.FROM_OSR,
            p_to_osr                 => l_dml_record.TO_OSR,
            p_batch_mode_flag        => l_dml_record.BATCH_MODE_FLAG,
--            p_init_msg_list          => 'F',
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'DQM return status ERROR');
	    FND_FILE.PUT_LINE(FND_FILE.LOG, SubStr('l_msg_data = '||l_msg_data,1,255));
            FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'message[' ||I||']=');
              FND_FILE.PUT_LINE(FND_FILE.LOG, Substr(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ),1,255));
            END LOOP;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END IF;
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'DQM complete successfully ');

        END IF;

      END IF;	-- end of IF P_REGISTRY_DEDUP = 'Y'

    END IF; -- IF P_RERUN <> 'R'

    -- Call V+DML Of Parties when
    -- WHAT-IF ANALYSIS parameter  <> 'ANALYSIS'
    IF P_WHAT_IF_ANALYSIS is null OR (P_WHAT_IF_ANALYSIS is not null AND P_WHAT_IF_ANALYSIS <> 'A') THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'LOAD_PARTIES ... ');

      HZ_IMP_LOAD_PARTIES_PKG.LOAD_PARTIES (
        P_DML_RECORD             => l_dml_record,
        X_RETURN_STATUS          => l_return_status,
        X_MSG_COUNT              => l_msg_count,
        X_MSG_DATA               => l_msg_data
      );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'LOAD_PARTIES successfully ');

      -- Bug 4594407
      -- Populate staging table for unprocessed post-processing records from previous run
      -- matching of parties
      -- Bug 4925023 : handle cases when records passed stage 3 at previous run.
      --   Change from l_hwm_stage = 2 to l_hwm_stage >= 2
      IF l_hwm_stage >= 2 AND l_pp_status = 'U' THEN
        HZ_IMP_LOAD_SSM_MATCHING_PKG.MATCH_PARTIES(
          l_dml_record.BATCH_ID,
          l_dml_record.OS,
          l_dml_record.FROM_OSR,
          l_dml_record.TO_OSR,
          l_dml_record.ACTUAL_CONTENT_SRC,
          'N',
          l_dml_record.BATCH_MODE_FLAG
        );
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATCH_PARTIES completed ');
      END IF;

    END IF;

    /* Update status to Complete for the work unit that just finished */
    UPDATE HZ_IMP_WORK_UNITS
      SET STATUS = 'C'
    WHERE BATCH_ID = l_dml_record.BATCH_ID
      AND FROM_ORIG_SYSTEM_REF = l_dml_record.FROM_OSR;

    COMMIT;

  END LOOP;

  -- What-If parameter  = 'ANALYSIS'
  IF P_WHAT_IF_ANALYSIS = 'A' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'debug: ANALYSIS ');
    WHAT_IF_ANALYSIS(l_dml_record.BATCH_ID, l_os);
  END IF;

/* code is moved to the wrapper
  IF P_BATCH_MODE_FLAG = 'Y' THEN
    --  Analyze staging table after matching
    fnd_stats.gather_table_stats('AR', 'HZ_IMP_ADDRESSES_SG', percent=>5, degree=>4);
    fnd_stats.gather_table_stats('AR', 'HZ_IMP_ADDRESSUSES_SG', percent=>5, degree=>4);
    fnd_stats.gather_table_stats('AR', 'HZ_IMP_CLASSIFICS_SG', percent=>5, degree=>4);
    fnd_stats.gather_table_stats('AR', 'HZ_IMP_CONTACTPTS_SG', percent=>5, degree=>4);
    fnd_stats.gather_table_stats('AR', 'HZ_IMP_CONTACTROLES_SG', percent=>5, degree=>4);
    fnd_stats.gather_table_stats('AR', 'HZ_IMP_CONTACTS_SG', percent=>5, degree=>4);
    fnd_stats.gather_table_stats('AR', 'HZ_IMP_CREDITRTNGS_SG', percent=>5, degree=>4);
    fnd_stats.gather_table_stats('AR', 'HZ_IMP_FINNUMBERS_SG', percent=>5, degree=>4);
    fnd_stats.gather_table_stats('AR', 'HZ_IMP_FINREPORTS_SG', percent=>5, degree=>4);
    fnd_stats.gather_table_stats('AR', 'HZ_IMP_RELSHIPS_SG', percent=>5, degree=>4);
  END IF;
*/

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stage 2 WORKER_PROCESS (-)');

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

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Stage 2 worker: SQLERRM: ' || SQLERRM);
  FND_FILE.PUT_LINE(FND_FILE.LOG, SubStr('l_msg_data = '||l_msg_data,1,255));
  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'message[' ||I||']=');
      FND_FILE.PUT_LINE(FND_FILE.LOG, Substr(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ),1,255));
  END LOOP;


END WORKER_PROCESS;


END HZ_IMP_LOAD_STAGE2;

/
