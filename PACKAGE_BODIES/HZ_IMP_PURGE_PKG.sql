--------------------------------------------------------
--  DDL for Package Body HZ_IMP_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_PURGE_PKG" AS
/*$Header: ARHLPRGB.pls 115.6 2004/05/04 00:56:38 wawong noship $ */
PROCEDURE Purge_Batch(     errbuf                          OUT NOCOPY   VARCHAR2,
                           retcode                         OUT NOCOPY   VARCHAR2,
                           p_batch_id                      IN           VARCHAR2
) IS
i                NUMBER;
l_error_message  VARCHAR2(2000);
l_status         HZ_IMP_BATCH_SUMMARY.MAIN_CONC_STATUS%TYPE;
BEGIN

   /* Check for 8i database */
   BEGIN
      SELECT REPLACE(substr(version,  1, instr(version, '.', 1, 3)),'.')
      INTO  i
      FROM  v$instance;

   IF i >= 920 then
      NULL;
   ELSE
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK WORK;
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_IMP_DB_VER_CHECK' );
     FND_MSG_PUB.ADD;
      FND_MSG_PUB.Reset;
      FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
        l_error_message := FND_MSG_PUB.Get( p_msg_index   =>  i,
                              p_encoded     =>  FND_API.G_FALSE);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_error_message );
        FND_FILE.PUT_LINE(FND_FILE.log, l_error_message );
      END LOOP;
     retcode := 2;
     return;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK WORK;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occured ');
     FND_FILE.put_line(fnd_file.log,sqlerrm);
     retcode := 2;
     return;
   WHEN OTHERS THEN
     ROLLBACK WORK;
     FND_FILE.put_line(fnd_file.log,sqlerrm);
     Retcode := 2;
     return;
  END;

   /* Batch is Processing */
   BEGIN
     SELECT main_conc_status INTO l_status
      FROM  hz_imp_batch_summary
     WHERE  batch_id = p_batch_id;

     IF l_status = 'PROCESSING' THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK WORK;
             FND_FILE.put_line(fnd_file.log,'Error : You cannot purge a batch when a batch is being processed.');
             retcode := 2;
             return;
        WHEN OTHERS THEN
             ROLLBACK WORK;
             FND_FILE.put_line(fnd_file.log,sqlerrm);
             retcode := 2;
             return;
   END;
   FND_FILE.put_line(fnd_file.log,' Purge Starts ... ');

    -- DQM Tables
    FND_FILE.put_line(fnd_file.log,' Purging DQM Tables ... ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_INT_DEDUP_RESULTS (+) ');

    DELETE HZ_IMP_INT_DEDUP_RESULTS WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_INT_DEDUP_RESULTS (-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_DUP_PARTIES (+) ');

    DELETE HZ_IMP_DUP_PARTIES       WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_DUP_PARTIES (-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_DUP_DETAILS (+) ');

    DELETE HZ_IMP_DUP_DETAILS       WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_DUP_DETAILS (-) ');
    FND_FILE.put_line(fnd_file.log,' Purged DQM Tables ... ');

    -- Interface Tables
    FND_FILE.put_line(fnd_file.log,' Purging Interface Tables ... ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_PARTIES_INT(+) ');

    DELETE HZ_IMP_PARTIES_INT       WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_PARTIES_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_ADDRESSES_INT(+) ');

    DELETE HZ_IMP_ADDRESSES_INT     WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_ADDRESSES_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_ADDRESSUSES_INT(+) ');

    DELETE HZ_IMP_ADDRESSUSES_INT   WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_ADDRESSUSES_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTPTS_INT(+) ');

    DELETE HZ_IMP_CONTACTPTS_INT    WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTPTS_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_RELSHIPS_INT(+) ');

    DELETE HZ_IMP_RELSHIPS_INT      WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_RELSHIPS_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTS_INT(+) ');

    DELETE HZ_IMP_CONTACTS_INT      WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTS_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTROLES_INT(+) ');

    DELETE HZ_IMP_CONTACTROLES_INT  WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTROLES_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CREDITRTNGS_INT(+) ');

    DELETE HZ_IMP_CREDITRTNGS_INT   WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CREDITRTNGS_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CLASSIFICS_INT(+) ');

    DELETE HZ_IMP_CLASSIFICS_INT    WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CLASSIFICS_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_FINNUMBERS_INT(+) ');

    DELETE HZ_IMP_FINNUMBERS_INT    WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_FINNUMBERS_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_FINREPORTS_INT(+) ');

    DELETE HZ_IMP_FINREPORTS_INT    WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_FINREPORTS_INT(-) ');
    FND_FILE.put_line(fnd_file.log,' Purged Interface Tables ... ');



    --Staging Tables
    FND_FILE.put_line(fnd_file.log,' Purging Staging Tables ... ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_PARTIES_SG (+)');

    DELETE HZ_IMP_PARTIES_SG       WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_PARTIES_SG (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_ADDRESSES_SG (+)');

    DELETE HZ_IMP_ADDRESSES_SG     WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_ADDRESSES_SG (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_ADDRESSUSES_SG (+)');

    DELETE HZ_IMP_ADDRESSUSES_SG   WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_ADDRESSUSES_SG (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTPTS_SG (+)');

    DELETE HZ_IMP_CONTACTPTS_SG    WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTPTS_SG (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_RELSHIPS_SG (+)');

    DELETE HZ_IMP_RELSHIPS_SG      WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_RELSHIPS_SG (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTS_SG (+)');

    DELETE HZ_IMP_CONTACTS_SG      WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTS_SG (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTROLES_SG (+)');

    DELETE HZ_IMP_CONTACTROLES_SG  WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CONTACTROLES_SG (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CREDITRTNGS_SG (+)');

    DELETE HZ_IMP_CREDITRTNGS_SG   WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CREDITRTNGS_SG (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CLASSIFICS_SG (+)');

    DELETE HZ_IMP_CLASSIFICS_SG    WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_CLASSIFICS_SG (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_FINNUMBERS_SG (+)');

    DELETE HZ_IMP_FINNUMBERS_SG    WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_FINNUMBERS_SG (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_FINREPORTS_SG (+)');

    DELETE HZ_IMP_FINREPORTS_SG    WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_FINREPORTS_SG  (-)');
    FND_FILE.put_line(fnd_file.log,' Purged Staging Tables ... ');

    -- Error Tables
    FND_FILE.put_line(fnd_file.log,' Purging Error Tables ... ');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_ERRORS  (+)');

    DELETE HZ_IMP_ERRORS           WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_ERRORS  (-)');
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_TMP_ERRORS  (+)');

    DELETE HZ_IMP_TMP_ERRORS       WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_TMP_ERRORS  (-)');
    FND_FILE.put_line(fnd_file.log,' Purged Error Tables ... ');

    -- Work Units Table
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_WORK_UNITS  (+)');
    DELETE HZ_IMP_WORK_UNITS       WHERE batch_id = p_batch_id;
    COMMIT;

    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_WORK_UNITS  (-)');

    -- Bug No 3310475
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_OSR_CHANGE  (+)');
    DELETE HZ_IMP_OSR_CHANGE       WHERE batch_id = p_batch_id;
    COMMIT;
    FND_FILE.put_line(fnd_file.log,' Purge HZ_IMP_OSR_CHANGE  (-)');
    FND_FILE.put_line(fnd_file.log,' Purge Ends ... ');

    FND_FILE.put_line(fnd_file.log,' Update hz_imp_batch_summary table (+)');
    -- Update hz_imp_batch_summary table.
    UPDATE HZ_IMP_BATCH_SUMMARY
       SET BATCH_STATUS      = 'PURGED',
           PURGE_DATE        =  SYSDATE,
           PURGED_BY_USER_ID =  HZ_UTILITY_V2PUB.user_id
     WHERE batch_id          =  p_batch_id;
    COMMIT;

   FND_FILE.put_line(fnd_file.log,' Update hz_imp_batch_summary table (-)');
  EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK WORK;
       FND_FILE.put_line(fnd_file.log,sqlerrm);
       retcode := 2;
       return;
END Purge_Batch  ;

END HZ_IMP_PURGE_PKG;

/
