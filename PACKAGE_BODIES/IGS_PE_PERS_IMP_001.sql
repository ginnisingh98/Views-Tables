--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERS_IMP_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERS_IMP_001" AS
/* $Header: IGSPE15B.pls 120.3 2006/04/27 07:38:54 prbhardw noship $ */


  -- These are the package variables to hold the value of whether the particular category is included or not.

            g_person_type_inc          BOOLEAN;
            g_person_stat_inc          BOOLEAN;
            g_person_addr_inc          BOOLEAN;
            g_person_alias_inc         BOOLEAN;
            g_person_id_types_inc      BOOLEAN;
            g_person_spcl_need_inc     BOOLEAN;
            g_person_emp_dtl_inc       BOOLEAN;
            g_person_int_dtl_inc       BOOLEAN;
            g_person_hlth_ins_inc      BOOLEAN;
            g_person_mil_dtl_inc       BOOLEAN;
            g_person_act_inc           BOOLEAN;
            g_person_rel_inc           BOOLEAN;
            g_person_ath_inc           BOOLEAN;
            g_person_lang_inc          BOOLEAN;
            g_person_contact_inc       BOOLEAN;
            g_person_disc_dtls_inc     BOOLEAN;
            g_person_housing_stat_inc  BOOLEAN;
            g_person_acad_honors_inc   BOOLEAN;
            g_person_res_dtl_inc       BOOLEAN;
            g_rel_acad_hist_inc        BOOLEAN;
            g_rel_addr_inc             BOOLEAN;
            g_rel_contact_inc          BOOLEAN;
            g_rel_empl_dtl_inc         BOOLEAN;
	    g_privacy_dtl_inc          BOOLEAN;
--These variables are added as part of Admissions Import process Enhancements Bug 3191401
            g_person_creds_inc         BOOLEAN;
            g_acad_hist_inc            BOOLEAN;

  PROCEDURE prc_pe_category(
            p_batch_id  IN NUMBER,
            p_source_type_id IN NUMBER,
            p_match_set_id   IN NUMBER,
            p_interface_run_id  IN NUMBER
             )
  AS
  /*************************************************************
  Created By :pkpatel
  Date Created By :29-APR-2003
  Purpose : This procedure will call all the procedures for person related categories
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  asbala     13-OCT-2003        Bug 3130316. Import Process Logging Framework Related changes.
  asbala     21-OCT-2003        Bug 3130316. Import Process - New logic to delete completed records.
  ***************************************************************/
   l_meaning  igs_lookup_values.meaning%TYPE;
   l_count NUMBER;
   l_count1 NUMBER;
   l_count2 NUMBER;
   l_count3 NUMBER;
   l_count4 NUMBER;
   l_count5 NUMBER;
   l_count6 NUMBER;
   l_var    VARCHAR2(1);
   l_enable_log VARCHAR2(1);
   l_interface_run_id IGS_AD_INTERFACE_CTL.interface_run_id%TYPE;
   l_status       VARCHAR2(5);
   l_industry     VARCHAR2(5);
   l_schema       VARCHAR2(30);
   l_return       BOOLEAN;

   CURSOR meaning_cur(cp_lookup_code igs_lookup_values.lookup_code%TYPE,
                      cp_lookup_type igs_lookup_values.lookup_type%TYPE)
   IS
   SELECT meaning
   FROM   igs_lookup_values
   WHERE  lookup_type = cp_lookup_type AND
          lookup_code = cp_lookup_code;

  BEGIN
     -- Process person related source categories
    igs_pe_pers_imp_001.set_stat_matc_rvw_pers_rcds(p_source_type_id,
                                                   p_batch_id);

    l_return := fnd_installation.get_app_info('IGS', l_status, l_industry, l_schema);

    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_interface_run_id := igs_ad_imp_001.g_interface_run_id;

    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_INTERFACE_ALL',
                           cascade => TRUE);

    -- The logic in this procedure is :
    -- 1. The interface_run_id is updated in all tables and the statistics are gathered.
    -- 2. Then all records with match_ind = '22' (ie., reviewed) are made status '1' and the respective processes are
    --    called for further processing

    -- Delete all the records before processing for duplicate check.
    DELETE FROM igs_ad_imp_near_mtch_all
    WHERE interface_id IN
    (SELECT interface_id FROM igs_ad_interface_all
     WHERE interface_run_id = l_interface_run_id AND
           status='2');

    -- Populating the child interface table with the interface_run_id value.
    UPDATE igs_ad_api_int_all    aapi
    SET interface_run_id=l_interface_run_id
    WHERE  aapi.status='2' AND
    EXISTS (SELECT 1
    FROM igs_ad_interface_all ai
    WHERE
    ai.interface_id=aapi.interface_id AND
    ai.status IN ('1','2') AND
    ai.interface_run_id=l_interface_run_id);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_API_INT_ALL',
                           cascade => TRUE);

    -- Populating the child interface table with the interface_run_id value.
    UPDATE igs_ad_stat_int_all  adi
    SET   interface_run_id=l_interface_run_id
    WHERE  adi.status='2' AND
    EXISTS (SELECT 1
      FROM igs_ad_interface_all ai
      WHERE ai.interface_id=adi.interface_id AND
        ai.status IN ('1','2') AND
        ai.interface_run_id=l_interface_run_id);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_STAT_INT_ALL',
                           cascade => TRUE);

    -- Populating the child interface table with the interface_run_id value.
    UPDATE IGS_AD_ADDR_INT_ALL   ait
    SET
       interface_run_id=l_interface_run_id
    WHERE  ait.status='2' AND
    EXISTS (SELECT 1
    FROM igs_ad_interface_all ai
    WHERE
    ai.interface_id=ait.interface_id AND
    ai.status IN ('1','2') AND
    ai.interface_run_id=l_interface_run_id);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_ADDR_INT_ALL',
                           cascade => TRUE);

    -- Populating the child interface table with the interface_run_id value.
    UPDATE IGS_AD_ADDRUSAGE_INT_ALL   ait
    SET interface_run_id=l_interface_run_id
    WHERE  ait.status='2' AND
    EXISTS (SELECT 1
    FROM IGS_AD_ADDR_INT_ALL ai
    WHERE
    ai.interface_addr_id = ait.interface_addr_id AND
    ai.status IN ('1','2') AND
    ai.interface_run_id=l_interface_run_id);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_ADDRUSAGE_INT_ALL',
                           cascade => TRUE);

    -- Update records with match_ind '22' to status = '1'
    -- Person Details
    UPDATE IGS_AD_INTERFACE_all SET STATUS = '1'
    WHERE PERSON_MATCH_IND = '22'  AND STATUS = '2'
    AND SOURCE_TYPE_ID = P_SOURCE_TYPE_ID
    AND BATCH_ID = P_BATCH_ID;

    UPDATE IGS_AD_STAT_INT_all SET STATUS = '1'
    WHERE MATCH_IND = '22'  AND STATUS = '2'
    AND INTERFACE_RUN_ID = l_interface_run_id;

    -- Address Details
    UPDATE IGS_AD_ADDR_INT_all SET STATUS = '1'
    WHERE MATCH_IND = '22'  AND STATUS = '2'
    AND INTERFACE_RUN_ID = l_interface_run_id;

    -- Address Usages
      UPDATE IGS_AD_ADDRUSAGE_INT_all iau SET    STATUS = '1'
      WHERE  MATCH_IND = '22'  AND    STATUS = '2'
      AND  INTERFACE_RUN_ID = l_interface_run_id;

    UPDATE IGS_AD_API_INT_all SET STATUS = '1'
    WHERE MATCH_IND = '22'  AND STATUS = '2'
    AND  INTERFACE_RUN_ID = l_interface_run_id;

    igs_ad_imp_002.prc_pe_dtls
              (p_d_batch_id       => p_batch_id,
               p_d_source_type_id => p_source_type_id,
               p_match_set_id     => p_match_set_id
               );

    IF g_person_type_inc THEN
            OPEN meaning_cur('PERSON_TYPE','IMP_CATEGORIES');
            FETCH meaning_cur INTO l_meaning;
            CLOSE meaning_cur;

      IF l_enable_log = 'Y' THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_PE_BEG_IMP');
            FND_MESSAGE.SET_TOKEN('TYPE_NAME',l_meaning);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF;

            -- pupulate the child table with the interface run ID from the package.

            UPDATE igs_pe_type_int pti
            SET  interface_run_id=l_interface_run_id
            WHERE  pti.status='2' AND
            EXISTS (SELECT 1
                    FROM igs_ad_interface_all ai
                    WHERE
                          ai.interface_id=pti.interface_id AND
                          ai.status IN ('1','4') AND
                          ai.interface_run_id=l_interface_run_id);

          FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_TYPE_INT',
                           cascade => TRUE);

      -- Person Types
        UPDATE igs_pe_type_int SET status = '1'
        WHERE match_ind = '22'  AND status = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

          igs_ad_imp_013.prc_pe_type(
                     p_source_type_id=>p_source_type_id ,
                     p_batch_id=>p_batch_id );
         END IF;


         IF g_person_stat_inc THEN
           IF l_enable_log = 'Y' THEN
             igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_STAT');
           END IF;


        -- Populating the child interface table with the interface_run_id value.
	UPDATE igs_pe_eit_int  pei
        SET
           interface_run_id=l_interface_run_id
        WHERE  pei.status='2' AND
        EXISTS (SELECT 1
            FROM igs_ad_interface_all ai
            WHERE
            ai.interface_id=pei.interface_id AND
            ai.status IN ('1','4') AND
            ai.interface_run_id=l_interface_run_id);


    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_EIT_INT',
                           cascade => TRUE);

            -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_pe_race_int  adli
            SET
               interface_run_id=l_interface_run_id
            WHERE  adli.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=adli.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

          FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_RACE_INT',
                           cascade => TRUE);

       UPDATE igs_pe_eit_int
       SET status = '1'
       WHERE match_ind = '22'  AND
         status = '2'      AND
             INTERFACE_RUN_ID = l_interface_run_id;

       UPDATE igs_pe_race_int
       SET status = '1'
       WHERE match_ind = '22'  AND
         status = '2'      AND
             INTERFACE_RUN_ID = l_interface_run_id;

            Igs_Ad_Imp_008.PRC_PE_STAT(
                     p_source_type_id=>p_source_type_id ,
                     p_batch_id=>p_batch_id );

         END IF;

         IF g_person_addr_inc THEN

              IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_ADDR');
              END IF;


                Igs_Ad_Imp_026.PRC_PE_ADDR(
                p_source_type_id=>p_source_type_id,
                p_batch_id=>p_batch_id );

         END IF;


         IF g_person_alias_inc THEN
           IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_ALIAS');
           END IF;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_ad_alias_int_all     adai
            SET
               interface_run_id=l_interface_run_id
            WHERE  adai.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=adai.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

        FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_ALIAS_INT_ALL',
                           cascade => TRUE);

        UPDATE IGS_AD_ALIAS_INT_all SET STATUS = '1'
        WHERE MATCH_IND = '22'  AND STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

        Igs_Ad_Imp_006.PRC_PE_ALIAS(
               p_source_type_id=>p_source_type_id,
               p_batch_id=>p_batch_id);
         END IF;


         IF g_person_id_types_inc THEN
           IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_ID_TYP');
           END IF;

        Igs_Ad_Imp_007.PRC_PE_ID_TYPES(
               p_source_type_id=>p_source_type_id,
               p_batch_id=>p_batch_id );
         END IF;


         IF g_person_spcl_need_inc THEN
          IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_SPL_NEED');
          END IF;

            -- pupulate the child table with the interface run ID from the package.
            UPDATE igs_ad_disablty_int_all adi
            SET    interface_run_id=l_interface_run_id
            WHERE  adi.status='2' AND
            EXISTS (SELECT 1
                    FROM igs_ad_interface_all ai
                    WHERE ai.interface_id=adi.interface_id AND
                          ai.status IN ('1','4') AND
                          ai.interface_run_id=l_interface_run_id);

        FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_DISABLTY_INT_ALL',
                           cascade => TRUE);

         -- pupulate the child table with the interface run ID from the package.
        UPDATE IGS_AD_DISABLTY_INT_all SET STATUS = '1'
        WHERE MATCH_IND = '22'  AND STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

            UPDATE igs_pe_sn_srvce_int  snci
            SET interface_run_id=l_interface_run_id
            WHERE  snci.status='2' AND
            EXISTS (SELECT 1
                    FROM igs_ad_interface_all ai,
                         igs_ad_disablty_int_all adi
                    WHERE ai.interface_id=adi.interface_id AND
                          adi.INTERFACE_DISABLTY_ID=snci.INTERFACE_DISABLTY_ID AND
                          ai.status IN ('1','4') AND
                          ai.interface_run_id=l_interface_run_id);

        FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_SN_SRVCE_INT',
                           cascade => TRUE);

            -- pupulate the child table with the interface run ID from the package.
        UPDATE igs_pe_sn_srvce_int
        SET    status = '1'
        WHERE  match_ind = '22'  AND
               status = '2'      AND
               INTERFACE_RUN_ID = l_interface_run_id;

            UPDATE igs_pe_sn_conct_int  psci
            SET
                   interface_run_id=l_interface_run_id
            WHERE  psci.status='2' AND
            EXISTS (SELECT 1
                    FROM igs_ad_interface_all ai,
                         igs_ad_disablty_int_all adi
                    WHERE
                          ai.interface_id=adi.interface_id AND
                          adi.INTERFACE_DISABLTY_ID=psci.INTERFACE_DISABLTY_ID AND
                          ai.status IN ('1','4') AND
                          ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_SN_CONCT_INT',
                           cascade => TRUE);
           UPDATE igs_pe_sn_conct_int
           SET   status = '1'
           WHERE match_ind = '22'  AND
             status = '2'      AND
             INTERFACE_RUN_ID = l_interface_run_id;

       Igs_Ad_Imp_008.PRC_PE_SPL_NEEDS(
              p_source_type_id=>p_source_type_id,
              p_batch_id=>p_batch_id );

         END IF;

        IF g_person_emp_dtl_inc THEN
          IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_EMP_DTL');
          END IF;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_ad_emp_int_all    admpi
            SET
               interface_run_id=l_interface_run_id
            WHERE  admpi.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=admpi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

       -- gather statistics for the table after populating it's interface_run_id
       FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_EMP_INT_ALL',
                           cascade => TRUE);

        UPDATE IGS_AD_EMP_INT_all SET STATUS = '1'
        WHERE MATCH_IND = '22'  AND STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

                Igs_Ad_Imp_006.PRC_PE_EMPNT_DTLS(
                                    p_source_type_id=>p_source_type_id,
                                    p_batch_id=>p_batch_id );

        END IF;

        IF g_person_int_dtl_inc THEN
              IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_INTL_DTL');
              END IF;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE IGS_PE_VISA_INT  pvi
            SET
               interface_run_id=l_interface_run_id
            WHERE  pvi.status IN ('1','2') AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=pvi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_VISA_INT',
                           cascade => TRUE);

       UPDATE IGS_PE_VISA_INT SET STATUS = '1'
       WHERE MATCH_IND = '22'  AND STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE IGS_PE_PASSPORT_INT   ppi
            SET
               interface_run_id=l_interface_run_id
            WHERE  ppi.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=ppi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_PASSPORT_INT',
                           cascade => TRUE);
       UPDATE IGS_PE_PASSPORT_INT SET STATUS = '1'
       WHERE MATCH_IND = '22'  AND STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE IGS_PE_VST_HIST_INT    pvhi
            SET
               interface_run_id=l_interface_run_id
            WHERE  pvhi.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai,
                     IGS_PE_VISA_INT pi
                WHERE
                pi.INTERFACE_VISA_ID=pvhi.INTERFACE_VISA_ID AND
                ai.interface_id=pi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_VST_HIST_INT',
                           cascade => TRUE);

        UPDATE IGS_PE_VST_HIST_INT SET STATUS = '1'
        WHERE MATCH_IND = '22'  AND STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

            -- Populating the child interface table with the interface_run_id value.
            --skpandey, Bug#4114660: Changed table alias name to optimize performance
	    UPDATE IGS_PE_EIT_INT    pei
            SET
               interface_run_id=l_interface_run_id
            WHERE  pei.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=pei.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_EIT_INT',
                           cascade => TRUE);
       UPDATE IGS_PE_EIT_INT SET STATUS = '1'
       WHERE MATCH_IND = '22'  AND STATUS = '2'
       AND INFORMATION_TYPE = 'PE_INT_PERM_RES'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

        UPDATE igs_pe_citizen_int   pci
            SET
               interface_run_id=l_interface_run_id
            WHERE  pci.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=pci.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_CITIZEN_INT',
                           cascade => TRUE);

          UPDATE igs_pe_citizen_int SET status = '1'
          WHERE match_ind = '22'  AND status = '2' AND
             INTERFACE_RUN_ID = l_interface_run_id;

            UPDATE igs_pe_fund_src_int    pfsi
            SET
               interface_run_id=l_interface_run_id
            WHERE  pfsi.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=pfsi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_FUND_SRC_INT',
                           cascade => TRUE);
          UPDATE igs_pe_fund_src_int SET status = '1'
           WHERE match_ind = '22'  AND status = '2'
             AND INTERFACE_RUN_ID = l_interface_run_id;

                Igs_Ad_Imp_007.PRC_PE_INTL_DTLS(
                                    P_SOURCE_TYPE_ID=>P_SOURCE_TYPE_ID,
                                   P_BATCH_ID=>P_BATCH_ID );
        END IF;

         IF g_person_hlth_ins_inc THEN
          IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_HLTH_INS');
          END IF;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_pe_immu_dtl_int    pidi
            SET
               interface_run_id=l_interface_run_id
            WHERE  pidi.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=pidi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_IMMU_DTL_INT',
                           cascade => TRUE);


           UPDATE igs_pe_immu_dtl_int
           SET status = '1'
           WHERE match_ind = '22'  AND
             status = '2'      AND
             INTERFACE_RUN_ID = l_interface_run_id;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_ad_hlth_ins_int_all     adhi
            SET
               interface_run_id=l_interface_run_id
            WHERE  adhi.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=adhi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_HLTH_INS_INT_ALL',
                           cascade => TRUE);

        UPDATE IGS_AD_HLTH_INS_INT_all SET STATUS = '1'
        WHERE MATCH_IND = '22'  AND STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

                Igs_Ad_Imp_007.PRC_PE_HLTH_DTLS(
                                  p_source_type_id=>p_source_type_id,
                                  p_batch_id=>p_batch_id );
         END IF;

        IF g_person_mil_dtl_inc THEN
          IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_MIL');
          END IF;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_ad_military_int_all    admi
            SET
               interface_run_id=l_interface_run_id
            WHERE  admi.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=admi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_MILITARY_INT_ALL',
                           cascade => TRUE);

        UPDATE IGS_AD_MILITARY_INT_all SET STATUS = '1'
        WHERE MATCH_IND = '22'  AND STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

        Igs_Ad_Imp_007.PRC_PE_MLTRY_DTLS(
                                    p_source_type_id=>p_source_type_id,
                                   p_batch_id=>p_batch_id );

        END IF;

        IF g_person_act_inc THEN
          IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_EXTR_CUR');
          END IF;



            -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_ad_excurr_int_all    adei
            SET
               interface_run_id=l_interface_run_id
            WHERE  adei.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=adei.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_EXCURR_INT_ALL',
                           cascade => TRUE);

        UPDATE IGS_AD_EXCURR_INT_all SET STATUS = '1'
        WHERE MATCH_IND = '22'  AND STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

        Igs_Ad_Imp_006.PRC_PE_EXTCLR_DTLS(
                                            p_source_type_id=>p_source_type_id,
                                           p_batch_id=>p_batch_id );
        END IF;

        IF g_person_rel_inc THEN
          IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_REL');
          END IF;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE IGS_AD_RELATIONS_INT_ALL  ari
            SET interface_run_id=l_interface_run_id
            WHERE  ari.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=ari.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_RELATIONS_INT_ALL',
                           cascade => TRUE);
          UPDATE IGS_AD_RELATIONS_INT_all iar
          SET    STATUS = '1'
          WHERE  MATCH_IND = '22'  AND    STATUS = '2'
          AND  INTERFACE_RUN_ID = l_interface_run_id;

        IF g_rel_addr_inc THEN

            UPDATE igs_ad_reladdr_int_all  ari1
            SET interface_run_id=l_interface_run_id
            WHERE  ari1.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai,
                     IGS_AD_RELATIONS_INT_ALL adi
                WHERE
                adi.INTERFACE_RELATIONS_ID=ari1.INTERFACE_RELATIONS_ID AND
                ai.interface_id=adi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

           -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_RELADDR_INT_ALL',
                           cascade => TRUE);
          UPDATE IGS_AD_RELADDR_INT_all iara
          SET    STATUS = '1'
          WHERE  MATCH_IND = '22'  AND    STATUS = '2'
          AND  INTERFACE_RUN_ID = l_interface_run_id;

        END IF;

        IF g_rel_empl_dtl_inc THEN
            UPDATE igs_ad_relemp_int_all  ari2
            SET interface_run_id=l_interface_run_id
            WHERE  ari2.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai,
                     IGS_AD_RELATIONS_INT_ALL adi
                WHERE adi.INTERFACE_RELATIONS_ID=ari2.INTERFACE_RELATIONS_ID AND
                ai.interface_id=adi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_RELEMP_INT_ALL',
                           cascade => TRUE);
           UPDATE IGS_AD_RELEMP_INT_all ire
           SET    STATUS = '1'
           WHERE  MATCH_IND = '22'  AND    STATUS = '2'
           AND  INTERFACE_RUN_ID = l_interface_run_id;

        END IF;


    IF g_rel_acad_hist_inc THEN

            UPDATE Igs_Ad_Relacad_Int_all  ari3
            SET interface_run_id=l_interface_run_id
            WHERE  ari3.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai,
                     IGS_AD_RELATIONS_INT_ALL adi
                WHERE adi.INTERFACE_RELATIONS_ID=ari3.INTERFACE_RELATIONS_ID AND
                ai.interface_id=adi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_RELACAD_INT_ALL',
                           cascade => TRUE);
      UPDATE IGS_AD_RELACAD_INT_ALL iara
      SET    STATUS = '1'
      WHERE  MATCH_IND = '22'  AND    STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

    END IF;


        IF g_rel_contact_inc THEN
            UPDATE igs_ad_rel_con_int_all  ari4
            SET
               interface_run_id=l_interface_run_id
            WHERE  ari4.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai,
                     IGS_AD_RELATIONS_INT_ALL adi
                WHERE
                adi.INTERFACE_RELATIONS_ID=ari4.INTERFACE_RELATIONS_ID AND
                ai.interface_id=adi.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);
            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_REL_CON_INT_ALL',
                           cascade => TRUE);
		   UPDATE IGS_AD_REL_CON_INT_all iarc
		   SET    STATUS = '1'
		   WHERE  MATCH_IND = '22'  AND    STATUS = '2'
			AND  INTERFACE_RUN_ID = l_interface_run_id;

		END IF;

                Igs_Ad_Imp_008.PRC_PE_RELNS(
                                    p_source_type_id=>p_source_type_id,
                                   p_batch_id=>p_batch_id );
        END IF;


        IF g_person_ath_inc THEN
		  IF l_enable_log = 'Y' THEN
							igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_ATHL');
		  END IF;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_pe_ath_dtl_int  adli
            SET
               interface_run_id=l_interface_run_id
            WHERE  adli.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=adli.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_ATH_DTL_INT',
                           cascade => TRUE);

        UPDATE igs_pe_ath_dtl_int
        SET status = '1'
        WHERE match_ind = '22'  AND status = '2' AND
          INTERFACE_RUN_ID = l_interface_run_id;

        -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_pe_ath_prg_int  adli
            SET
               interface_run_id=l_interface_run_id
            WHERE  adli.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=adli.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_ATH_PRG_INT',
                           cascade => TRUE);
        UPDATE igs_pe_ath_prg_int
        SET status = '1'
        WHERE match_ind = '22'  AND status = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

        igs_ad_imp_012.prc_apcnt_ath(
               p_source_type_id=>p_source_type_id,
               p_batch_id=>p_batch_id );
        END IF;

        IF g_person_lang_inc THEN
		  IF l_enable_log = 'Y' THEN
					igs_ad_imp_001.set_message(p_name => 'IGS_PE_BEG_PE_LAN');
		  END IF;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_ad_language_int_all     adli
            SET
               interface_run_id=l_interface_run_id
            WHERE  adli.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=adli.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_LANGUAGE_INT_ALL',
                           cascade => TRUE);
		   UPDATE IGS_AD_LANGUAGE_INT_all il
		   SET    STATUS = '1'
		   WHERE  MATCH_IND = '22' AND    STATUS = '2'
			AND  INTERFACE_RUN_ID = l_interface_run_id;

        igs_ad_imp_012.prc_pe_language(
                                   p_source_type_id=>p_source_type_id,
                                   p_batch_id=>p_batch_id );
        END IF;



        IF g_person_contact_inc THEN
              IF l_enable_log = 'Y' THEN
                        igs_ad_imp_001.set_message(p_name => 'IGS_PE_BEG_PE_CON');
              END IF;

            -- Populating the child interface table with the interface_run_id value.
            UPDATE igs_ad_contacts_int_all    adci
            SET
               interface_run_id=l_interface_run_id
            WHERE  adci.status='2' AND
            EXISTS (SELECT 1
                FROM igs_ad_interface_all ai
                WHERE
                ai.interface_id=adci.interface_id AND
                ai.status IN ('1','4') AND
                ai.interface_run_id=l_interface_run_id);

            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_CONTACTS_INT_ALL',
                           cascade => TRUE);
          UPDATE IGS_AD_CONTACTS_INT_all ic
          SET    STATUS = '1'
          WHERE  MATCH_IND = '22'  AND    STATUS = '2'
          AND  INTERFACE_RUN_ID = l_interface_run_id;

        igs_ad_imp_012.prc_pe_cntct_dtls(
                                    p_source_type_id=>p_source_type_id,
                                    p_batch_id=>p_batch_id );
        END IF;


       IF g_person_disc_dtls_inc THEN
        IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_DISCIPLINARY');
        END IF;

           -- Update interface tables for Felony and hearing details.

            UPDATE igs_pe_flny_dtl_int pfi
            SET
                   interface_run_id=l_interface_run_id
            WHERE  pfi.status='2' AND
            EXISTS (SELECT 1
                    FROM igs_ad_interface_all ai
                    WHERE
                          ai.interface_id=pfi.interface_id AND
                          ai.status IN ('1','4') AND
                          ai.interface_run_id=l_interface_run_id);
             -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_FLNY_DTL_INT',
                           cascade => TRUE);
        UPDATE igs_pe_flny_dtl_int
        SET status = '1'
        WHERE match_ind = '22'  AND status = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

        UPDATE igs_pe_hear_dtl_int phi
            SET
                   interface_run_id=l_interface_run_id
            WHERE  phi.status='2' AND
            EXISTS (SELECT 1
                    FROM igs_ad_interface_all ai
                    WHERE
                          ai.interface_id=phi.interface_id AND
                          ai.status IN ('1','4') AND
                          ai.interface_run_id=l_interface_run_id);
            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_HEAR_DTL_INT',
                           cascade => TRUE);
        UPDATE igs_pe_hear_dtl_int
        SET status = '1'
        WHERE match_ind = '22'  AND status = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

       Igs_Ad_Imp_025.prc_pe_disciplinary_dtls(
                                p_source_type_id  => p_source_type_id,
                                p_batch_id        => p_batch_id );

       END IF;

       IF g_person_housing_stat_inc THEN
        IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_PE_HOUSING');
        END IF;

           -- Populating the child interface table with the interface_run_id value.
           UPDATE igs_pe_housing_int  phi
           SET
                   interface_run_id=l_interface_run_id
            WHERE  phi.status='2' AND
            EXISTS (SELECT 1
                    FROM igs_ad_interface_all ai
                    WHERE
                          ai.interface_id=phi.interface_id AND
                          ai.status IN ('1','4') AND
                          ai.interface_run_id=l_interface_run_id);

            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_HOUSING_INT',
                           cascade => TRUE);
        UPDATE igs_pe_housing_int
        SET status = '1'
        WHERE match_ind = '22'  AND status = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

       Igs_Ad_Imp_025.prc_pe_house_status(
                                p_source_type_id  => p_source_type_id,
                                p_batch_id        => p_batch_id );

       END IF;

       IF g_person_acad_honors_inc THEN
        IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message(p_name => 'IGS_AD_BEG_ACAD_HONORS');
        END IF;


          -- Populating the child interface table with the interface_run_id value.
          UPDATE igs_ad_acadhonor_int_all  ahi
          SET
             interface_run_id=l_interface_run_id
          WHERE  ahi.status='2' AND
          EXISTS (SELECT 1
              FROM igs_ad_interface_all ai
              WHERE
              ai.interface_id=ahi.interface_id AND
              ai.status IN ('1','4') AND
              ai.interface_run_id=l_interface_run_id);

            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_ACADHONOR_INT_ALL',
                           cascade => TRUE);
      UPDATE IGS_AD_ACADHONOR_INT_all iah
      SET    STATUS = '1'
      WHERE  MATCH_IND = '22'  AND STATUS = '2'
        AND  INTERFACE_RUN_ID = l_interface_run_id;

    Igs_Ad_Imp_011.prc_apcnt_acadhnr_dtls(
                               p_source_type_id=>p_source_type_id,
                               p_batch_id=>p_batch_id );

       END IF;

       IF g_person_res_dtl_inc THEN
          IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.set_message(p_name => 'IGS_PE_BEG_RES_DTLS');
          END IF;


           -- Update interface tables for Felony and hearing details.

            UPDATE igs_pe_res_dtls_int rdi
            SET
                   interface_run_id=l_interface_run_id
            WHERE  rdi.status='2' AND
            EXISTS (SELECT 1
                    FROM igs_ad_interface_all ai
                    WHERE
                          ai.interface_id=rdi.interface_id AND
                          ai.status IN ('1','4') AND
                          ai.interface_run_id=l_interface_run_id);

            -- gather statistics for the table after populating it's interface_run_id
           FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_PE_RES_DTLS_INT',
                           cascade => TRUE);
          UPDATE igs_pe_res_dtls_int iah
          SET    STATUS = '1'
          WHERE  MATCH_IND = '22'  AND STATUS = '2'
          AND  INTERFACE_RUN_ID = l_interface_run_id;

          Igs_Ad_Imp_011.prc_pe_res_dtls(
                       p_source_type_id=>p_source_type_id,
                       p_batch_id=>p_batch_id );

       END IF;

    IF g_person_creds_inc THEN

      IF l_enable_log = 'Y' THEN
       l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'PERSON_CREDENTIALS', 8405);
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_pe_Cred_int a
      SET    interface_run_id = l_interface_run_id
      WHERE  EXISTS  (SELECT 1
                              FROM   igs_ad_interface_all
                              WHERE  interface_run_id = l_interface_run_id
                              AND  interface_id = a.interface_id
                              AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_PE_CRED_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_013.prc_pe_cred_details (p_interface_run_id => l_interface_run_id,
                                              p_enable_log       => l_enable_log,
                                              p_rule             => igs_ad_gen_016.find_source_cat_rule (p_source_type_id, 'PERSON_CREDENTIALS'));

    END IF; -- g_person_creds_inc

    IF g_acad_hist_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'PERSON_ACADEMIC_HISTORY', 8405);

      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_acadhis_int_all a
      SET    interface_run_id = l_interface_run_id,
               person_id = (SELECT person_id
                          FROM   igs_ad_interface_all
                          WHERE  interface_id = a.interface_id)
      WHERE EXISTS (SELECT 1
                              FROM   igs_ad_interface_all
                              WHERE  interface_run_id = l_interface_run_id
                              AND  interface_id = a.interface_id
                              AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_ACADHIS_INT_ALL',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_013.prc_pe_acad_hist (p_interface_run_id => l_interface_run_id,
                                              p_enable_log       => l_enable_log,
                                              p_rule             => igs_ad_gen_016.find_source_cat_rule (p_source_type_id, 'PERSON_ACADEMIC_HISTORY'));

    END IF; -- g_person_creds_inc

    IF g_privacy_dtl_inc THEN

	l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'PRIVACY_DETAILS', 8405);

	IF l_enable_log = 'Y' THEN
	  igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',p_token_name  => 'TYPE_NAME',p_token_value => l_meaning);
	END IF;

	-- Populating the interface table with the interface_run_id value
	UPDATE igs_pe_privacy_int a
	SET    interface_run_id = l_interface_run_id
	WHERE EXISTS (SELECT 1
 	              FROM  igs_ad_interface_all
	              WHERE interface_run_id = l_interface_run_id
	              AND   interface_id = a.interface_id
	              AND   status IN ('1','4'));

	-- Gather statistics of the table
	FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'igs_pe_privacy_int',cascade => TRUE);

          UPDATE igs_pe_privacy_int iah
          SET    STATUS = '1'
          WHERE  MATCH_IND = '22'  AND STATUS = '2'
          AND  INTERFACE_RUN_ID = l_interface_run_id;

	-- Call category entity import procedure
	igs_ad_imp_025.prc_priv_dtls (p_source_type_id=>p_source_type_id,p_batch_id=>p_batch_id );

    END IF;

    --Raise Bulk address process notification
    IGS_PE_WF_GEN. ADDR_BULK_SYNCHRONIZATION(IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS);

  END prc_pe_category;


  PROCEDURE del_cmpld_pe_records(
    p_batch_id  IN NUMBER
  )AS
  /*************************************************************
  Created By :pkpatel
  Date Created By :29-APR-2003
  Purpose : This will delete from all the person related tables as per the record status in the IGS_AD_INTERFACE table.
            The delete will happen only if the category for the table is included.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  vrathi          08-Jul-2003     Bug:3038248 Delete record from igs_ad_addrusage_int before deleting from igs_ad_addr_int
  pkpatel         11-DEC-2003     Bug 2863933 (Removed the individual UPDATE of IGS_AD_INTERFACE_ALL and made it single UPDATE)
                                  Added 3 intermediate COMMIT statements.
  nsidana         6/21/2004       Bug 3533035 : First need to update the records in relations_int table to 4 in case any child did not process
                                  successfully. Then we need to delete from relations_int table, the records with status 1.
				  Previously, the reverse was happening, so the record in parent relations_int table was getting deleted even though
				  some child errored out.
  (reverse chronological order - newest change first)
  ***************************************************************/
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_interface_run_id IGS_AD_INTERFACE_CTL.interface_run_id%TYPE;

  BEGIN
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_pe_pers_imp_001.del_cmpld_pe_records';
  l_label := 'igs.plsql.igs_pe_pers_imp_001.del_cmpld_pe_records.';

  -- Commit all the pending transactions
  COMMIT;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_pe_pers_imp_001.del_cmpld_pe_records.begin';
    l_debug_str := 'Batch Id : ' || p_batch_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  -- update record status of all the records in igs_AD_interface with current interface_run_id to '1'
  UPDATE igs_ad_interface_all
  SET record_status = '1'
  WHERE interface_run_id = l_interface_run_id;

        -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('PERSON');

        -- Delete from the tables for Statistics
        pe_cat_stats('PERSON_STATISTICS_STAT');

        DELETE FROM igs_ad_stat_int_all
		WHERE  status = '1' AND interface_run_id = l_interface_run_id;

        -- Delete from the table IGS_AD_ADDRUSAGE_INT
        pe_cat_stats('PERSON_ADDRESS');

        -- new logic to delete processed records from interface table
        DELETE FROM igs_ad_addrusage_int_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

        DELETE FROM igs_ad_addr_int_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

        -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('PERSON_ID_TYPES');

        DELETE FROM igs_ad_api_int_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;


    IF g_person_stat_inc THEN
	    pe_cat_stats('PERSON_STATISTICS');

      -- new logic to delete processed records from interface table
        DELETE FROM igs_pe_race_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

        DELETE FROM igs_pe_eit_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

    END IF;

    IF g_person_type_inc THEN
        pe_cat_stats('PERSON_TYPE');

		DELETE FROM igs_pe_type_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

    END IF;

	IF g_person_alias_inc  THEN
      -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('PERSON_ALIAS');

		DELETE FROM IGS_AD_ALIAS_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

    END IF;

    IF g_person_spcl_need_inc  THEN
      -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('PERSON_SPECIAL_NEEDS');

        DELETE FROM igs_pe_sn_srvce_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

		DELETE FROM igs_pe_sn_conct_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

        DELETE FROM IGS_AD_DISABLTY_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

    END IF;

    IF g_person_emp_dtl_inc THEN
      -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('PERSON_EMPLOYMENT_DETAILS');

		DELETE FROM IGS_AD_EMP_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

    END IF;


    IF g_person_int_dtl_inc THEN
      -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('PERSON_INTERNATIONAL_DETAILS');

        DELETE FROM IGS_PE_VST_HIST_INT WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

        UPDATE igs_pe_visa_int ad
        SET status = '4', error_code = 'E347'
        WHERE ad.interface_run_id = l_interface_run_id AND
              ad.status = '1' AND
              EXISTS (SELECT 1 FROM igs_pe_vst_hist_int ai WHERE ad.interface_visa_id = ai.interface_visa_id);

        -- DELETE FROM TABLE IGS_PE_VISA_INT
        DELETE FROM IGS_PE_VISA_INT WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

        DELETE FROM IGS_PE_PASSPORT_INT WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

        DELETE FROM igs_pe_citizen_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

        DELETE FROM igs_pe_fund_src_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

        DELETE FROM igs_pe_eit_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

    END IF;


    IF g_person_hlth_ins_inc  THEN
      -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('PERSON_HEALTH_INSURANCE');

	  -- Delete from the table IGS_AD_HLTH_INS_INT
        DELETE FROM IGS_AD_HLTH_INS_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

      -- Delete from the table igs_pe_immu_dtl_int
        DELETE FROM igs_pe_immu_dtl_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

    END IF;

    -- Intermediate commit for all the transactions till this point
    COMMIT;

    -- Delete from the table IGS_AD_MILITARY_INT
    IF g_person_mil_dtl_inc THEN

        pe_cat_stats('PERSON_MILITARY_DETAILS');

        DELETE FROM IGS_AD_MILITARY_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

    END IF;

         -- Delete from the table IGS_AD_EXCURR_INT
    IF g_person_act_inc THEN

        pe_cat_stats('PERSON_ACTIVITIES');

        DELETE FROM IGS_AD_EXCURR_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

      END IF;


        -- Delete from the table IGS_PE_RES_DTL_INT
      IF g_person_res_dtl_inc THEN

        pe_cat_stats('PERSON_RESIDENCY_DETAILS');

        DELETE FROM IGS_PE_RES_DTLS_INT WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

      END IF;

         -- Delete from the table IGS_AD_ACADHONOR_INT
      IF g_person_acad_honors_inc THEN
      -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('PERSON_ACAD_HONORS');

        DELETE FROM IGS_AD_ACADHONOR_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

      END IF;

      IF g_rel_empl_dtl_inc THEN
      -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('RELATIONS_EMPLOYMENT_DETAILS');

        DELETE FROM IGS_AD_RELEMP_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

	  END IF;

      IF g_rel_contact_inc THEN
      -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('RELATIONS_CONTACTS');

        DELETE FROM igs_ad_rel_con_int_all WHERE
        status = '1' AND interface_run_id = l_interface_run_id;

      END IF;

         -- Delete from the table IGS_AD_RELADDR_INT
      IF g_rel_addr_inc THEN

		pe_cat_stats('RELATIONS_ADDRESS');

		DELETE FROM igs_ad_reladdr_int_all WHERE
        status = '1' AND interface_run_id = l_interface_run_id;

      END IF;

      IF g_rel_acad_hist_inc THEN
      -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('RELATIONS_ACAD_HISTORY');

        DELETE FROM IGS_AD_RELACAD_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

	  END IF;


      IF g_person_rel_inc THEN
        -- call the procedure to store statistics in igs_ad_imp_stats
        pe_cat_stats('PERSON_RELATIONS');


-- nsidana Bug 3533035 : First update the relations_int table to status 4 in case any child was not processed successfully. Then delete the records having status 1.
        UPDATE IGS_AD_RELATIONS_INT_all ad
        SET status = '4', error_code = 'E347'
        WHERE ad.interface_run_id = l_interface_run_id AND
              ad.status = '1' AND
              ( EXISTS (SELECT 1 FROM igs_ad_relemp_int_all ai WHERE ad.interface_relations_id = ai.interface_relations_id)
			   OR EXISTS (SELECT 1 FROM igs_ad_rel_con_int_all ai WHERE ad.interface_relations_id = ai.interface_relations_id)
			   OR EXISTS (SELECT 1 FROM  IGS_AD_RELACAD_INT_all ai WHERE ad.interface_relations_ID = ai.interface_relations_ID)
               OR EXISTS (SELECT 1 FROM igs_ad_reladdr_int_all ai WHERE ad.interface_relations_ID = ai.interface_relations_ID )
			  );

        DELETE FROM IGS_AD_RELATIONS_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;
      -- end of delete logic

      END IF;

      IF g_person_ath_inc THEN

		-- Delete from the table igs_pe_ath_dtl_int
        pe_cat_stats('PERSON_ATHLETICS');

        DELETE FROM igs_pe_ath_dtl_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

       -- Delete from the table igs_pe_ath_prg_int
        DELETE FROM igs_pe_ath_prg_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

      END IF;


      IF g_person_housing_stat_inc THEN
        pe_cat_stats('PERSON_HOUSING_STATUS');

		-- Delete from the table igs_pe_housing_int
        DELETE FROM igs_pe_housing_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

      END IF;


      IF g_person_disc_dtls_inc THEN
        pe_cat_stats('PERSON_DISCIPLINARY_DTLS');

		  -- Delete from the table igs_pe_flny_dtl_int
        DELETE FROM igs_pe_flny_dtl_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

        -- Delete from the table igs_pe_hear_dtl_int
        DELETE FROM igs_pe_hear_dtl_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

	  END IF;

      IF g_person_contact_inc THEN
        pe_cat_stats('PERSON_CONTACTS');
        -- new logic to delete processed records from interface table
        DELETE FROM IGS_AD_CONTACTS_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

      END IF;

      IF g_person_lang_inc THEN
        pe_cat_stats('PERSON_LANGUAGES');
      -- new logic to delete processed records from interface table
        DELETE FROM IGS_AD_LANGUAGE_INT_all WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

	  END IF;

      IF g_person_creds_inc THEN
		 pe_cat_stats('PERSON_CREDENTIALS');

        DELETE FROM IGS_PE_CRED_INT WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

      END IF;

      IF g_acad_hist_inc THEN
         pe_cat_stats('PERSON_ACADEMIC_HISTORY');

        DELETE FROM IGS_AD_ACADHIS_INT_ALL WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

      END IF;

      IF g_privacy_dtl_inc   THEN
         pe_cat_stats('PRIVACY_DETAILS');

        DELETE FROM igs_pe_privacy_int WHERE
        STATUS = '1' AND interface_run_id = l_interface_run_id;

      END IF;


      UPDATE igs_ad_interface_all ad
        SET record_status = '3'
        WHERE ad.interface_run_id = l_interface_run_id AND
          (   EXISTS (SELECT 1 FROM igs_ad_interface_all ai WHERE ad.interface_id = ai.interface_id AND status = '3')
		   OR EXISTS (SELECT 1 FROM igs_ad_stat_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_addr_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_api_int_all ai  WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_race_int ai     WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_eit_int  ai     WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_type_int ai     WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_alias_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_disablty_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_emp_int_all ai  WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_visa_int ai     WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_passport_int ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_citizen_int ai  WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_fund_src_int ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_hlth_ins_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_immu_dtl_int ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_military_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_excurr_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_res_dtls_int ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_acadhonor_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_relations_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_ath_dtl_int ai  WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_ath_prg_int ai  WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_housing_int ai  WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_flny_dtl_int ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_hear_dtl_int ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_contacts_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_language_int_all ai WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_cred_int ai     WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_ad_acadhis_int_all ai  WHERE ad.interface_id = ai.interface_id)
		   OR EXISTS (SELECT 1 FROM igs_pe_privacy_int ai  WHERE ad.interface_id = ai.interface_id));

      -- Commit all the transactions
      COMMIT;

  END del_cmpld_pe_records;



PROCEDURE set_stat_matc_rvw_pers_rcds (
      p_source_type_id IN NUMBER,
      p_batch_id IN NUMBER
      )
AS
/*************************************************************
  Created By :pkpatel
  Date Created By :29-APR-2003
  Purpose : This procedure gets called at the beginning of import process.
            The package variables are initialized here as per the categories included or not and then
            used further.
            Here also the pending records with match_ind 22 are updated to status 1, and this happens as per the
            category is included or not.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
 ***************************************************************/
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);

BEGIN
/* initialise variables to DEFAULT value FALSE*/
  g_person_type_inc           := FALSE;
  g_person_stat_inc           := FALSE;
  g_person_addr_inc           := FALSE;
  g_person_alias_inc          := FALSE;
  g_person_id_types_inc       := FALSE;
  g_person_spcl_need_inc      := FALSE;
  g_person_emp_dtl_inc        := FALSE;
  g_person_int_dtl_inc        := FALSE;
  g_person_hlth_ins_inc       := FALSE;
  g_person_mil_dtl_inc        := FALSE;
  g_person_act_inc            := FALSE;
  g_person_rel_inc            := FALSE;
  g_person_ath_inc            := FALSE;
  g_person_lang_inc           := FALSE;
  g_person_contact_inc        := FALSE;
  g_person_disc_dtls_inc      := FALSE;
  g_person_housing_stat_inc   := FALSE;
  g_person_acad_honors_inc    := FALSE;
  g_person_res_dtl_inc        := FALSE;
  g_rel_acad_hist_inc         := FALSE;
  g_rel_addr_inc              := FALSE;
  g_rel_contact_inc           := FALSE;
  g_rel_empl_dtl_inc          := FALSE;
  g_person_creds_inc          := FALSE;
  g_acad_hist_inc             := FALSE;
  g_privacy_dtl_inc           := FALSE;

  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_pe_pers_imp_001.set_stat_matc_rvw_pers_rcds';
  l_label := 'igs.plsql.igs_pe_pers_imp_001.set_stat_matc_rvw_pers_rcds.';

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_pe_pers_imp_001.set_stat_matc_rvw_pers_rcds.begin';
    l_debug_str := 'Source Type Id : ' || p_source_type_id || ' Batch ID :' || p_batch_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;


        g_person_type_inc      := igs_ad_gen_016.chk_src_cat( p_source_type_id, 'PERSON_TYPE');
        g_person_stat_inc      := igs_ad_gen_016.chk_src_cat( p_source_type_id, 'PERSON_STATISTICS');
        g_person_addr_inc      := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_ADDRESS');
        g_person_alias_inc     := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_ALIAS');
        g_person_id_types_inc  := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_ID_TYPES');
        g_person_spcl_need_inc := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_SPECIAL_NEEDS');
        g_person_emp_dtl_inc   := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_EMPLOYMENT_DETAILS');
        g_person_int_dtl_inc   := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_INTERNATIONAL_DETAILS');
        g_person_hlth_ins_inc  := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_HEALTH_INSURANCE');
        g_person_mil_dtl_inc       := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_MILITARY_DETAILS');
        g_person_act_inc           := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_ACTIVITIES');
        g_person_rel_inc           := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_RELATIONS');
        g_person_ath_inc           := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_ATHLETICS' );
        g_person_lang_inc          := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_LANGUAGES');
        g_person_contact_inc       := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_CONTACTS');
        g_person_disc_dtls_inc     := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_DISCIPLINARY_DTLS');
        g_person_housing_stat_inc  := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_HOUSING_STATUS');
        g_person_acad_honors_inc   := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_ACAD_HONORS');
        g_person_res_dtl_inc       := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PERSON_RESIDENCY_DETAILS');
        g_rel_acad_hist_inc        := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'RELATIONS_ACAD_HISTORY');
        g_rel_addr_inc             := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'RELATIONS_ADDRESS');
        g_rel_contact_inc          := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'RELATIONS_CONTACTS');
        g_rel_empl_dtl_inc         := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'RELATIONS_EMPLOYMENT_DETAILS');
	g_privacy_dtl_inc          := igs_ad_gen_016.chk_src_cat(p_source_type_id, 'PRIVACY_DETAILS');

  --Intialization of variables are added as part of Admissions Import process Enhancements Bug #3191401
       g_person_creds_inc   := igs_ad_gen_016.chk_src_cat(p_source_type_id,'PERSON_CREDENTIALS');
       g_acad_hist_inc         := igs_ad_gen_016.chk_src_cat(p_source_type_id,'PERSON_ACADEMIC_HISTORY');


END set_stat_matc_rvw_pers_rcds;

PROCEDURE  prc_pe_imp_record_sts(
    p_interface_id IN  igs_ad_interface_all.interface_id%TYPE
  )
AS
/*************************************************************
  Created By :pkpatel
  Date Created By :29-APR-2003
  Purpose : This procedure puts the logic for all the person categories to finally update the record status
  of the IGS_AD_INTERFACE table. Record Status '1' success and '3' failure.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
 ***************************************************************/
-- asbala  15-10-2003  procedure stubbed. the delete logic is implemented differently now. See details
-- in SWS: Import Process Enhancements Build
BEGIN
  NULL;
END prc_pe_imp_record_sts;

--< nsidana 9/23/2003 Admissions Import process enhancements : Lookups caching >

FUNCTION validate_lookup_type_code(p_lookup_type IN fnd_lookup_values.lookup_type%TYPE,
                                   p_lookup_code IN fnd_lookup_values.lookup_type%TYPE,
                                   p_application_id IN NUMBER)
RETURN BOOLEAN IS
/*****************************************************************
 Created By    : nsidana

 Creation date : 9/23/2003

 Purpose       : This function is to validate the lookup type and lookup
 code combination. It checks if the lookup type and lookup code combination
 is a valid one. It uses PL/SQL table to evaluate this.

 Know limitations, enhancements or remarks

 Change History
 Who             When            What

 (reverse chronological order - newest change first)
***************************************************************/

-- Cursor to fetch all the lookup codes associated with a lookup type.
-- Will be used to cache the lookups.

CURSOR c_fetch_lkups(cp_lkup_type VARCHAR2,cp_application_id fnd_lookup_values.view_application_id%TYPE,
                     cp_security_group_id fnd_lookup_values.security_group_id%TYPE)
IS
SELECT lookup_type,lookup_code
FROM   fnd_lookup_values
WHERE  lookup_type         = cp_lkup_type AND
       view_application_id = cp_application_id AND
       security_group_id   = cp_security_group_id AND
       language            = userenv('LANG') AND
       enabled_flag        = 'Y';

CURSOR c_validate_lkup_code(cp_lkup_type VARCHAR2, cp_lkup_code VARCHAR2, cp_application_id fnd_lookup_values.view_application_id%TYPE,
                           cp_security_group_id fnd_lookup_values.security_group_id%TYPE)
IS
SELECT 'X'
FROM   fnd_lookup_values
WHERE  lookup_type         = cp_lkup_type AND
       lookup_code         = cp_lkup_code AND
       view_application_id = cp_application_id AND
       security_group_id   = cp_security_group_id AND
       language            = userenv('LANG') AND
       enabled_flag        = 'Y';

l_rec       c_fetch_lkups%ROWTYPE;
l_hash_code NUMBER;
l_var       VARCHAR2(1);
l_var2      VARCHAR2(80);

BEGIN

  IF ((p_lookup_type IS NOT NULL) AND (p_lookup_code IS NOT NULL) AND (p_application_id IS NOT NULL))
  THEN

    -- all parameters passed. Proceed further...

    l_hash_code := DBMS_UTILITY.GET_HASH_VALUE(p_lookup_type||'@*?'||p_lookup_code||'@*?'||p_application_id,1000,25000);

    IF l_lookups_tab.EXISTS(l_hash_code)
    THEN
        RETURN(TRUE);
    ELSE
       -- check if the lookup type was cached or not.

       l_hash_code := DBMS_UTILITY.GET_HASH_VALUE(p_lookup_type||'@*?'||p_application_id,1000,25000);

       IF l_lookup_type_tab.EXISTS(l_hash_code)
       THEN
           -- Lookup type was cached, but the lookup code passed to the function is not associated with it. The combination is invalid.
           RETURN(FALSE);
       ELSE
           -- No cache hit. Validate the lookup type and code and cache it.

           OPEN c_validate_lkup_code(p_lookup_type,p_lookup_code,p_application_id,0);
           FETCH c_validate_lkup_code INTO l_var;
           CLOSE c_validate_lkup_code;

           IF (l_var = 'X') THEN
              -- cache the lookup type and the lookup codes.

              l_hash_code:=DBMS_UTILITY.GET_HASH_VALUE(p_lookup_type||'@*?'||p_application_id,1000,25000);

              l_lookup_type_tab(l_hash_code):=p_lookup_type;

              -- cache the lookup codes for this type also.

              OPEN c_fetch_lkups(p_lookup_type,p_application_id,0);
              LOOP
                  FETCH c_fetch_lkups INTO l_rec;
                  EXIT WHEN c_fetch_lkups%NOTFOUND;

                  l_var2:=NULL;
                  l_var2:=l_rec.lookup_type||'@*?'||l_rec.lookup_code;

                  l_hash_code:=DBMS_UTILITY.GET_HASH_VALUE(l_rec.lookup_type||'@*?'||l_rec.lookup_code||'@*?'||p_application_id,1000,25000);
                  l_lookups_tab(l_hash_code):=l_var2;

              END LOOP;
              CLOSE c_fetch_lkups;

             -- Lookups cached. Return TRUE.

              RETURN(TRUE);
           ELSE
               -- Lookup type and code combination is not valid. Return FALSE.
               RETURN(FALSE);
           END IF;
       END IF;
    END IF;
  ELSE
    RETURN(FALSE); -- all parameters not passed.
  END IF;

END validate_lookup_type_code;


PROCEDURE pe_cat_stats(p_source_category IN VARCHAR2) AS
/*****************************************************************
 Created By    : asbala

 Creation date : 9/23/2003

 Purpose       : This function is to insert the statistics into igs_ad_imp_stats.

 Know limitations, enhancements or remarks

 Change History
 Who             When            What
 pkpatel         27-Mar-2006     Bug 5114924(Defined variables l_success .. as NUMBER instead of NUMBER(5))
 skpandey        25-JAN-2006     Bug#4114660: Used local variable in place of Literals to optimize performance
 pkpatel         11-DEC-2003     Bug 2863933 (Added the logic to populate for Credential and Academic History.
                                 Used local variables to populate WHO columns)
 (reverse chronological order - newest change first)
***************************************************************/

  CURSOR cur_person_type (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status
  FROM IGS_PE_TYPE_INT
  WHERE interface_run_id = p_interface_run_id
  GROUP BY status;

  CURSOR cur_person_stat_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_STAT_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR  cur_person_stat_eit_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_EIT_INT WHERE interface_run_id = p_interface_run_id AND
            information_type IN ('PE_STAT_RES_COUNTRY','PE_STAT_RES_STATE', 'PE_STAT_RES_STATUS') GROUP BY status;

  CURSOR cur_person_race_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_RACE_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_addr_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_ADDR_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_addrusage_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1, status FROM IGS_AD_ADDRUSAGE_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_alias_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_ALIAS_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_id_types_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_API_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_spcl_need_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_DISABLTY_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_srvc_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_SN_SRVCE_INT  WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_conc_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_SN_CONCT_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_emp_dtl_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_EMP_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_visa_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_VISA_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_passport_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_PASSPORT_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_hist_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_VST_HIST_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_eit_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE,p_information_type VARCHAR2) IS
  SELECT count(*) count1,status FROM IGS_PE_EIT_INT  WHERE interface_run_id = p_interface_run_id AND
           information_type = p_information_type GROUP BY status;

  CURSOR cur_person_citizen_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_CITIZEN_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_fund_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_FUND_SRC_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_immu_dtl_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_IMMU_DTL_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_health_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_HLTH_INS_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_mil_dtl_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_MILITARY_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_act_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_EXCURR_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_rel_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_RELATIONS_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_ath_dtl_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_ATH_DTL_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_ath_prg_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_ATH_PRG_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_lang_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_LANGUAGE_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_contact_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_CONTACTS_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_flny_dtls_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_FLNY_DTL_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_hear_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_HEAR_DTL_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_housing_stat_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_HOUSING_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_acad_honors_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_ACADHONOR_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_person_res_dtl_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_PE_RES_DTLS_INT WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_relacad_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_RELACAD_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_rel_addr_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_RELADDR_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_relcon_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_REL_CON_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_relemp_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_RELEMP_INT_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_ad_interface_all (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM IGS_AD_INTERFACE_ALL WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_cred_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM igs_pe_cred_int WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_acadhis_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM igs_ad_acadhis_int_all WHERE interface_run_id = p_interface_run_id GROUP BY status;

  CURSOR cur_privacy_int (p_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE) IS
  SELECT count(*) count1,status FROM igs_pe_privacy_int  WHERE interface_run_id = p_interface_run_id GROUP BY status;


  l_interface_run_id igs_ad_imp_001.g_interface_run_id%TYPE;
  l_success NUMBER;
  l_error NUMBER;
  l_warning NUMBER;
  l_total_rec NUMBER;
  l_sysdate  DATE;
  l_user_id  NUMBER;
  l_tab VARCHAR2(30);
  l_source_category VARCHAR2(30);
BEGIN
  l_sysdate := SYSDATE;
  l_user_id := fnd_global.user_id;
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_success := 0;
  l_error := 0;
  l_warning := 0;
  l_total_rec := 0;

  IF (p_source_category = 'PERSON') THEN
    FOR rec_ad_interface_all IN cur_ad_interface_all(l_interface_run_id)
    LOOP
      IF rec_ad_interface_all.status = '1' THEN
        l_success := rec_ad_interface_all.count1;
      ELSIF rec_ad_interface_all.status = '3' THEN
        l_error := rec_ad_interface_all.count1;
      ELSIF rec_ad_interface_all.status = '4' THEN
        l_warning := rec_ad_interface_all.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_AD_INTERFACE_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
           l_interface_run_id,
           p_source_category,
       l_tab,
           l_total_rec,
       l_warning,
       l_success,
       l_error,
       l_user_id,
       l_sysdate,
       l_user_id,
       l_sysdate
    );
  END IF;

  IF (p_source_category = 'PERSON_TYPE') THEN

    FOR rec_person_type IN cur_person_type(l_interface_run_id)
    LOOP
      IF rec_person_type.status = '1' THEN
        l_success := rec_person_type.count1;
      ELSIF rec_person_type.status = '3' THEN
        l_error := rec_person_type.count1;
      ELSIF rec_person_type.status = '4' THEN
        l_warning := rec_person_type.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_PE_TYPE_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
           l_interface_run_id,
           p_source_category,
       l_tab,
           l_total_rec,
       l_warning,
       l_success,
       l_error,
       l_user_id,
       l_sysdate,
       l_user_id,
       l_sysdate
     );
  END IF;

  IF (p_source_category = 'PERSON_STATISTICS_STAT') THEN
    FOR rec_person_stat_int  IN cur_person_stat_int(l_interface_run_id)
    LOOP
      IF rec_person_stat_int.status = '1' THEN
        l_success := rec_person_stat_int.count1;
      ELSIF rec_person_stat_int.status = '3' THEN
        l_error := rec_person_stat_int.count1;
      ELSIF rec_person_stat_int.status = '4' THEN
        l_warning := rec_person_stat_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_AD_STAT_INT_ALL';
    l_source_category := 'PERSON_STATISTICS';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            l_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_STATISTICS') THEN

    FOR rec_person_stat_eit_int  IN cur_person_stat_eit_int(l_interface_run_id)
    LOOP
      IF rec_person_stat_eit_int.status = '1' THEN
          l_success := rec_person_stat_eit_int.count1;
      ELSIF rec_person_stat_eit_int.status = '3' THEN
          l_error := rec_person_stat_eit_int.count1;
      ELSIF rec_person_stat_eit_int.status = '4' THEN
          l_warning := rec_person_stat_eit_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_PE_EIT_INT-STAT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_race_int IN cur_person_race_int(l_interface_run_id)
    LOOP
      IF rec_person_race_int.status = '1' THEN
          l_success := rec_person_race_int.count1;
      ELSIF rec_person_race_int.status = '3' THEN
          l_error := rec_person_race_int.count1;
      ELSIF rec_person_race_int.status = '4' THEN
          l_warning := rec_person_race_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_PE_RACE_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_ADDRESS') THEN
    FOR rec_person_addr_int IN cur_person_addr_int(l_interface_run_id)
    LOOP
      IF rec_person_addr_int.status = '1' THEN
          l_success := rec_person_addr_int.count1;
      ELSIF rec_person_addr_int.status = '3' THEN
          l_error := rec_person_addr_int.count1;
      ELSIF rec_person_addr_int.status = '4' THEN
          l_warning := rec_person_addr_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_AD_ADDR_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_addrusage_int IN cur_person_addrusage_int(l_interface_run_id)
    LOOP
      IF rec_person_addrusage_int.status = '1' THEN
          l_success := rec_person_addrusage_int.count1;
      ELSIF rec_person_addrusage_int.status = '3' THEN
          l_error := rec_person_addrusage_int.count1;
      ELSIF rec_person_addrusage_int.status = '4' THEN
          l_warning := rec_person_addrusage_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_AD_ADDRUSAGE_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_ALIAS') THEN
    FOR rec_person_alias_int IN cur_person_alias_int(l_interface_run_id)
    LOOP
      IF rec_person_alias_int.status = '1' THEN
          l_success := rec_person_alias_int.count1;
      ELSIF rec_person_alias_int.status = '3' THEN
          l_error := rec_person_alias_int.count1;
      ELSIF rec_person_alias_int.status = '4' THEN
          l_warning := rec_person_alias_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_AD_ALIAS_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );


  END IF;

  IF (p_source_category = 'PERSON_ID_TYPES') THEN

    FOR rec_person_id_types_int IN cur_person_id_types_int(l_interface_run_id)
    LOOP
      IF rec_person_id_types_int.status = '1' THEN
          l_success := rec_person_id_types_int.count1;
      ELSIF rec_person_id_types_int.status = '3' THEN
          l_error := rec_person_id_types_int.count1;
      ELSIF rec_person_id_types_int.status = '4' THEN
          l_warning := rec_person_id_types_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_AD_API_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_SPECIAL_NEEDS') THEN
    FOR rec_person_spcl_need_int IN cur_person_spcl_need_int(l_interface_run_id)
    LOOP
      IF rec_person_spcl_need_int.status = '1' THEN
          l_success := rec_person_spcl_need_int.count1;
      ELSIF rec_person_spcl_need_int.status = '3' THEN
          l_error := rec_person_spcl_need_int.count1;
      ELSIF rec_person_spcl_need_int.status = '4' THEN
          l_warning := rec_person_spcl_need_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_AD_DISABLTY_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_srvc_int IN cur_person_srvc_int(l_interface_run_id)
    LOOP
      IF rec_person_srvc_int.status = '1' THEN
          l_success := rec_person_srvc_int.count1;
      ELSIF rec_person_srvc_int.status = '3' THEN
          l_error := rec_person_srvc_int.count1;
      ELSIF rec_person_srvc_int.status = '4' THEN
          l_warning := rec_person_srvc_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_PE_SN_SRVCE_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_conc_int IN cur_person_conc_int(l_interface_run_id)
    LOOP
      IF rec_person_conc_int.status = '1' THEN
          l_success := rec_person_conc_int.count1;
      ELSIF rec_person_conc_int.status = '3' THEN
          l_error := rec_person_conc_int.count1;
      ELSIF rec_person_conc_int.status = '4' THEN
          l_warning := rec_person_conc_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_PE_SN_CONCT_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_EMPLOYMENT_DETAILS') THEN
    FOR rec_person_emp_dtl_int IN cur_person_emp_dtl_int(l_interface_run_id)
    LOOP
      IF rec_person_emp_dtl_int.status = '1' THEN
          l_success := rec_person_emp_dtl_int.count1;
      ELSIF rec_person_emp_dtl_int.status = '3' THEN
          l_error := rec_person_emp_dtl_int.count1;
      ELSIF rec_person_emp_dtl_int.status = '4' THEN
          l_warning := rec_person_emp_dtl_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_total_rec + l_success + l_error + l_warning;
    l_tab := 'IGS_AD_EMP_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_INTERNATIONAL_DETAILS') THEN
    FOR rec_person_visa_int IN cur_person_visa_int(l_interface_run_id)
    LOOP
      IF rec_person_visa_int.status = '1' THEN
          l_success := rec_person_visa_int.count1;
      ELSIF rec_person_visa_int.status = '3' THEN
          l_error := rec_person_visa_int.count1;
      ELSIF rec_person_visa_int.status = '4' THEN
          l_warning := rec_person_visa_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_PE_VISA_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_passport_int IN cur_person_passport_int(l_interface_run_id)
    LOOP
      IF rec_person_passport_int.status = '1' THEN
          l_success := rec_person_passport_int.count1;
      ELSIF rec_person_passport_int.status = '3' THEN
          l_error := rec_person_passport_int.count1;
      ELSIF rec_person_passport_int.status = '4' THEN
          l_warning := rec_person_passport_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_PE_PASSPORT_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_hist_int IN cur_person_hist_int(l_interface_run_id)
    LOOP
      IF rec_person_hist_int.status = '1' THEN
          l_success := rec_person_hist_int.count1;
      ELSIF rec_person_hist_int.status = '3' THEN
          l_error := rec_person_hist_int.count1;
      ELSIF rec_person_hist_int.status = '4' THEN
          l_warning := rec_person_hist_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_PE_VST_HIST_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_eit_int IN cur_person_eit_int(l_interface_run_id,'PE_INT_PERM_RES')
    LOOP
      IF rec_person_eit_int.status = '1' THEN
          l_success := rec_person_eit_int.count1;
      ELSIF rec_person_eit_int.status = '3' THEN
          l_error := rec_person_eit_int.count1;
      ELSIF rec_person_eit_int.status = '4' THEN
          l_warning := rec_person_eit_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_PE_EIT_INT-INTL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_citizen_int IN cur_person_citizen_int(l_interface_run_id)
    LOOP
      IF rec_person_citizen_int.status = '1' THEN
          l_success := rec_person_citizen_int.count1;
      ELSIF rec_person_citizen_int.status = '3' THEN
          l_error := rec_person_citizen_int.count1;
      ELSIF rec_person_citizen_int.status = '4' THEN
          l_warning := rec_person_citizen_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec := l_success + l_error + l_warning;
    l_tab := 'IGS_PE_CITIZEN_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_fund_int IN cur_person_fund_int(l_interface_run_id)
    LOOP
      IF rec_person_fund_int.status = '1' THEN
          l_success := rec_person_fund_int.count1;
      ELSIF rec_person_fund_int.status = '3' THEN
          l_error := rec_person_fund_int.count1;
      ELSIF rec_person_fund_int.status = '4' THEN
          l_warning := rec_person_fund_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_PE_FUND_SRC_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_HEALTH_INSURANCE') THEN
    FOR rec_person_immu_dtl_int IN cur_person_immu_dtl_int(l_interface_run_id)
    LOOP
      IF rec_person_immu_dtl_int.status = '1' THEN
          l_success := rec_person_immu_dtl_int.count1;
      ELSIF rec_person_immu_dtl_int.status = '3' THEN
          l_error := rec_person_immu_dtl_int.count1;
      ELSIF rec_person_immu_dtl_int.status = '4' THEN
          l_warning := rec_person_immu_dtl_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_PE_IMMU_DTL_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_health_int IN cur_person_health_int(l_interface_run_id)
    LOOP
      IF rec_person_health_int.status = '1' THEN
          l_success := rec_person_health_int.count1;
      ELSIF rec_person_health_int.status = '3' THEN
          l_error := rec_person_health_int.count1;
      ELSIF rec_person_health_int.status = '4' THEN
          l_warning := rec_person_health_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_HLTH_INS_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_MILITARY_DETAILS') THEN
    FOR rec_person_mil_dtl_int IN cur_person_mil_dtl_int(l_interface_run_id)
    LOOP
      IF rec_person_mil_dtl_int.status = '1' THEN
          l_success := rec_person_mil_dtl_int.count1;
      ELSIF rec_person_mil_dtl_int.status = '3' THEN
          l_error := rec_person_mil_dtl_int.count1;
      ELSIF rec_person_mil_dtl_int.status = '4' THEN
          l_warning := rec_person_mil_dtl_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_MILITARY_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_ACTIVITIES') THEN
    FOR rec_person_act_int IN cur_person_act_int(l_interface_run_id)
    LOOP
      IF rec_person_act_int.status = '1' THEN
          l_success := rec_person_act_int.count1;
      ELSIF rec_person_act_int.status = '3' THEN
          l_error := rec_person_act_int.count1;
      ELSIF rec_person_act_int.status = '4' THEN
          l_warning := rec_person_act_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_EXCURR_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_RELATIONS') THEN
    FOR rec_person_rel_int IN cur_person_rel_int(l_interface_run_id)
    LOOP
      IF rec_person_rel_int.status = '1' THEN
          l_success := rec_person_rel_int.count1;
      ELSIF rec_person_rel_int.status = '3' THEN
          l_error := rec_person_rel_int.count1;
      ELSIF rec_person_rel_int.status = '4' THEN
          l_warning := rec_person_rel_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_RELATIONS_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_ATHLETICS') THEN
    FOR rec_person_ath_dtl_int IN cur_person_ath_dtl_int(l_interface_run_id)
    LOOP
      IF rec_person_ath_dtl_int.status = '1' THEN
          l_success := rec_person_ath_dtl_int.count1;
      ELSIF rec_person_ath_dtl_int.status = '3' THEN
          l_error := rec_person_ath_dtl_int.count1;
      ELSIF rec_person_ath_dtl_int.status = '4' THEN
          l_warning := rec_person_ath_dtl_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_PE_ATH_DTL_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_ath_prg_int IN cur_person_ath_prg_int(l_interface_run_id)
    LOOP
      IF rec_person_ath_prg_int.status = '1' THEN
          l_success := rec_person_ath_prg_int.count1;
      ELSIF rec_person_ath_prg_int.status = '3' THEN
          l_error := rec_person_ath_prg_int.count1;
      ELSIF rec_person_ath_prg_int.status = '4' THEN
          l_warning := rec_person_ath_prg_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_PE_ATH_PRG_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_LANGUAGES') THEN
    FOR rec_person_lang_int IN cur_person_lang_int(l_interface_run_id)
    LOOP
      IF rec_person_lang_int.status = '1' THEN
          l_success := rec_person_lang_int.count1;
      ELSIF rec_person_lang_int.status = '3' THEN
          l_error := rec_person_lang_int.count1;
      ELSIF rec_person_lang_int.status = '4' THEN
          l_warning := rec_person_lang_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_LANGUAGE_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_CONTACTS') THEN
    FOR rec_person_contact_int IN cur_person_contact_int(l_interface_run_id)
    LOOP
      IF rec_person_contact_int.status = '1' THEN
          l_success := rec_person_contact_int.count1;
      ELSIF rec_person_contact_int.status = '3' THEN
          l_error := rec_person_contact_int.count1;
      ELSIF rec_person_contact_int.status = '4' THEN
          l_warning := rec_person_contact_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_CONTACTS_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_DISCIPLINARY_DTLS') THEN
    FOR rec_person_flny_dtls_int IN cur_person_flny_dtls_int(l_interface_run_id)
    LOOP
      IF rec_person_flny_dtls_int.status = '1' THEN
          l_success := rec_person_flny_dtls_int.count1;
      ELSIF rec_person_flny_dtls_int.status = '3' THEN
          l_error := rec_person_flny_dtls_int.count1;
      ELSIF rec_person_flny_dtls_int.status = '4' THEN
          l_warning := rec_person_flny_dtls_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_PE_FLNY_DTL_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

    l_success := 0;
    l_error := 0;
    l_warning := 0;
    l_total_rec := 0;

    FOR rec_person_hear_int IN cur_person_hear_int(l_interface_run_id)
    LOOP
      IF rec_person_hear_int.status = '1' THEN
          l_success := rec_person_hear_int.count1;
      ELSIF rec_person_hear_int.status = '3' THEN
          l_error := rec_person_hear_int.count1;
      ELSIF rec_person_hear_int.status = '4' THEN
          l_warning := rec_person_hear_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_PE_HEAR_DTL_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_HOUSING_STATUS') THEN
    FOR rec_person_housing_stat_int IN cur_person_housing_stat_int(l_interface_run_id)
    LOOP
      IF rec_person_housing_stat_int.status = '1' THEN
          l_success := rec_person_housing_stat_int.count1;
      ELSIF rec_person_housing_stat_int.status = '3' THEN
          l_error := rec_person_housing_stat_int.count1;
      ELSIF rec_person_housing_stat_int.status = '4' THEN
          l_warning := rec_person_housing_stat_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_PE_HOUSING_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_ACAD_HONORS') THEN
    FOR rec_person_acad_honors_int IN cur_person_acad_honors_int(l_interface_run_id)
    LOOP
      IF rec_person_acad_honors_int.status = '1' THEN
          l_success := rec_person_acad_honors_int.count1;
      ELSIF rec_person_acad_honors_int.status = '3' THEN
          l_error := rec_person_acad_honors_int.count1;
      ELSIF rec_person_acad_honors_int.status = '4' THEN
          l_warning := rec_person_acad_honors_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_ACADHONOR_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_RESIDENCY_DETAILS') THEN
    FOR rec_person_res_dtl_int IN cur_person_res_dtl_int(l_interface_run_id)
    LOOP
      IF rec_person_res_dtl_int.status = '1' THEN
          l_success := rec_person_res_dtl_int.count1;
      ELSIF rec_person_res_dtl_int.status = '3' THEN
          l_error := rec_person_res_dtl_int.count1;
      ELSIF rec_person_res_dtl_int.status = '4' THEN
          l_warning := rec_person_res_dtl_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_PE_RES_DTLS_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'RELATIONS_ACAD_HISTORY' ) THEN
    FOR rec_relacad_int IN cur_relacad_int(l_interface_run_id)
    LOOP
      IF rec_relacad_int.status = '1' THEN
          l_success := rec_relacad_int.count1;
      ELSIF rec_relacad_int.status = '3' THEN
          l_error := rec_relacad_int.count1;
      ELSIF rec_relacad_int.status = '4' THEN
          l_warning := rec_relacad_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_RELACAD_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;
  IF (p_source_category = 'RELATIONS_ADDRESS') THEN
    FOR rec_rel_addr_int IN cur_rel_addr_int(l_interface_run_id)
    LOOP
      IF rec_rel_addr_int.status = '1' THEN
          l_success := rec_rel_addr_int.count1;
      ELSIF rec_rel_addr_int.status = '3' THEN
          l_error := rec_rel_addr_int.count1;
      ELSIF rec_rel_addr_int.status = '4' THEN
          l_warning := rec_rel_addr_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;

    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_RELADDR_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;
  IF (p_source_category = 'RELATIONS_CONTACTS') THEN
    FOR rec_relcon_int IN cur_relcon_int(l_interface_run_id)
    LOOP
      IF rec_relcon_int.status = '1' THEN
          l_success := rec_relcon_int.count1;
      ELSIF rec_relcon_int.status = '3' THEN
          l_error := rec_relcon_int.count1;
      ELSIF rec_relcon_int.status = '4' THEN
          l_warning := rec_relcon_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_REL_CON_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;
  IF (p_source_category = 'RELATIONS_EMPLOYMENT_DETAILS') THEN
    FOR rec_relemp_int IN cur_relemp_int(l_interface_run_id)
    LOOP
      IF rec_relemp_int.status = '1' THEN
          l_success := rec_relemp_int.count1;
      ELSIF rec_relemp_int.status = '3' THEN
          l_error := rec_relemp_int.count1;
      ELSIF rec_relemp_int.status = '4' THEN
          l_warning := rec_relemp_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_RELEMP_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );


  END IF;

  IF (p_source_category = 'PERSON_CREDENTIALS') THEN
    FOR rec_cred_int IN cur_cred_int(l_interface_run_id)
    LOOP
      IF rec_cred_int.status = '1' THEN
          l_success := rec_cred_int.count1;
      ELSIF rec_cred_int.status = '3' THEN
          l_error := rec_cred_int.count1;
      ELSIF rec_cred_int.status = '4' THEN
          l_warning := rec_cred_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_PE_CRED_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PERSON_ACADEMIC_HISTORY') THEN
    FOR rec_acadhis_int IN cur_acadhis_int(l_interface_run_id)
    LOOP
      IF rec_acadhis_int.status = '1' THEN
          l_success := rec_acadhis_int.count1;
      ELSIF rec_acadhis_int.status = '3' THEN
          l_error := rec_acadhis_int.count1;
      ELSIF rec_acadhis_int.status = '4' THEN
          l_warning := rec_acadhis_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_AD_ACADHIS_INT_ALL';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

  IF (p_source_category = 'PRIVACY_DETAILS') THEN
    FOR rec_privacy_int IN cur_privacy_int(l_interface_run_id)
    LOOP
      IF rec_privacy_int.status = '1' THEN
          l_success := rec_privacy_int.count1;
      ELSIF rec_privacy_int.status = '3' THEN
          l_error := rec_privacy_int.count1;
      ELSIF rec_privacy_int.status = '4' THEN
          l_warning := rec_privacy_int.count1;
      END IF;
    END LOOP;

    IF l_success IS NULL THEN
       l_success := 0;
    END IF;
    IF l_error IS NULL THEN
       l_error := 0;
    END IF;
    IF l_warning IS NULL THEN
       l_warning := 0;
    END IF;
    l_total_rec :=  l_success + l_error + l_warning;
    l_tab := 'IGS_PE_PRIVACY_INT';
    INSERT INTO IGS_AD_IMP_STATS
      (
        INTERFACE_RUN_ID,
    SRC_CAT_CODE,
    ENTITY_NAME,
    TOTAL_REC_NUM,
    TOTAL_WARN_NUM,
    TOTAL_SUCCESS_NUM,
    TOTAL_ERROR_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE
      )
    VALUES(
            l_interface_run_id,
            p_source_category,
        l_tab,
            l_total_rec,
        l_warning,
        l_success,
        l_error,
        l_user_id,
        l_sysdate,
        l_user_id,
        l_sysdate
     );

  END IF;

END pe_cat_stats;

PROCEDURE validate_ucas_id(p_api_id     IN  VARCHAR2,
                           p_person_id  IN  NUMBER,
                           p_api_type   IN  VARCHAR2,
			   p_action     OUT NOCOPY VARCHAR2,
			   p_error_code OUT NOCOPY VARCHAR2)
/****************************************************************
||  Created By : nsidana
||  Created On : 6/23/2004
||  Purpose : To validate if the UCAS ID need to be processed.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
||  gmaheswa       25-jan-05     Bug: 3882788 Removed the truncate caluse for sysdate inoder to process only active records
****************************************************************/
AS
  CURSOR chk_any_ucas_active_id(cp_person_id NUMBER,cp_api_type VARCHAR2)
  IS
    SELECT api_person_id
    FROM IGS_PE_ALT_PERS_ID
    WHERE pe_person_id   = cp_person_id
    AND   person_id_type = cp_api_type
    AND   SYSDATE BETWEEN TRUNC(START_DT) AND NVL(END_DT,SYSDATE);

   l_ucas_id              igs_pe_alt_pers_id.api_person_id%TYPE ;
   l_api_id		  igs_pe_alt_pers_id.api_person_id%TYPE;
   l_start_dt		  DATE;
   l_end_dt		  DATE;

BEGIN
  l_ucas_id := null;
  p_action      :=null;
  p_error_code  := null;

  OPEN chk_any_ucas_active_id(p_person_id,p_api_type);
  FETCH chk_any_ucas_active_id INTO l_ucas_id;
  CLOSE chk_any_ucas_active_id;

  IF (l_ucas_id IS NULL)
  THEN
     -- No active UCAS ID exists, process this interface record.
      p_action     := 'P';
      p_error_code := null;
  ELSIF (l_ucas_id IS NOT NULL)
  THEN
        IF (l_ucas_id = p_api_id)
	THEN
	  -- Skip this record as the record in the interface is same as the one in the actual table and is the active one.
	  p_action     := 'S';
          p_error_code := null;
	ELSE
	  -- Error out this record as another active UCAS ID is present in the system.
          p_action     := 'E';
          p_error_code := 'E560';
	END IF;
  END IF;
END validate_ucas_id;

-- change for country code inconsistency bug 3738488

FUNCTION validate_country_code(p_country_code  IN  VARCHAR2)
RETURN BOOLEAN
/****************************************************************
||  Created By : prbhardw
||  Created On : 11/04/2006
||  Purpose : To validate if the country code is a valid ISO country.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
****************************************************************/
AS
  CURSOR chk_cntry_code(cp_country_code VARCHAR2)
  IS
    SELECT territory_short_name
    FROM fnd_territories_vl
    WHERE territory_code   = cp_country_code;

   l_country_name              fnd_territories_vl.territory_short_name%TYPE ;

BEGIN
  l_country_name := NULL;

  OPEN chk_cntry_code(p_country_code);
  FETCH chk_cntry_code INTO l_country_name;
  CLOSE chk_cntry_code;

  IF (l_country_name IS NULL)
  THEN
      RETURN FALSE;
  ELSE
      RETURN TRUE;
  END IF;
END validate_country_code;

END igs_pe_pers_imp_001;

/
