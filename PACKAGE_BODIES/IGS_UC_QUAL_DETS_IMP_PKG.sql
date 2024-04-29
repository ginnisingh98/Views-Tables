--------------------------------------------------------
--  DDL for Package Body IGS_UC_QUAL_DETS_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_QUAL_DETS_IMP_PKG" AS
/* $Header: IGSUC28B.pls 120.3 2006/05/29 04:18:27 jbaber noship $ */

  PROCEDURE igs_uc_qual_dets_imp (errbuf    OUT NOCOPY    VARCHAR2,
                                  retcode   OUT NOCOPY    NUMBER  ) AS
    /*************************************************************
    Created By : rgopalan
    Date Created On : 2002/02/22
    Purpose : This procedure will import Qualification details
              of an applicant from the UCAS INterface table to Sec/Ter
              qualification details table
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    jbaber       25-MAY-06  Bug# 5210481 R12 Performance Repository
    anwest       18-JAN-06  Bug# 4950285 R12 Disable OSS Mandate
    rbezawad     09-DEC-02  Modified the process w.r.t. Bug 2639319.
    smaddali                Modified cursor cur_del_rec to delete the unique record being inserted ,
                            identified by unique key fields for bug 2450449 , also modified call to htis cursor
    bayadav      08-JAN-03  Modified  Cur_person_id cursor to cehck for EBL_AMMENDED_RESULT first then EBL_RESULT
                            while fetching value for approved result
    ayedubat     07-MAR-03  For the Bug,2824978 the column x_imported_date in Igs_uc_qual_dets_pkg.insert_row
                            call is populated with  SYSDATE.
                            For the Bug, 2825034 the existing qualifications are deleted first and importing all
                            the qualifications in the UCAS Interface table again.
                            For the Bug, 2825118 a validation is added to check the parent existence of the
                            Grading Schema+Grade Combination before calling the TBH for insertion/updation.
    (reverse chronological order - newest change first)
    ***************************************************************/

    /* This is to pickup records from UCAS interface table which have atleast
       one record in UCAS Interface Table,IGS_UC_APP_RESULTS */
    CURSOR Cur_UCAS_interface IS
    SELECT ROWID, Subject_id, year, sitting, Awarding_body,
           external_ref, UPPER(TRIM(Exam_level)) exam_level, Title,
           UPPER(TRIM(Subject_code)) subject_code, Imported
    FROM IGS_UC_COM_EBL_SUBJ
    WHERE subject_id IN ( SELECT DISTINCT subject_id FROM IGS_UC_APP_RESULTS ) ;

    /* This is to get the person id from the oss table for the corresponding person number */
    --smaddali 27-jun-2002 added condition that oss_person_id should be not null for bug 2430139
    --smaddali selecting new columns iua.app_no and pe.person_number for bug 2430139 ,to show in log file
    --jbaber modified to use hz_parties rather than igs_pe_person for performance - bug 5210481
    CURSOR Cur_person_id (l_subject_id igs_uc_app_results.subject_id%TYPE)  IS
    SELECT iua.app_no, pe.party_number person_number, iua.Oss_person_id person_id,
           NVL(UPPER(TRIM(iuar.EBL_AMENDED_RESULT)),UPPER(TRIM(iuar.EBL_result))) ebl_result,
           UPPER(TRIM(iuar.Claimed_result)) claimed_result
    FROM  IGS_UC_APP_RESULTS iuar,
          IGS_UC_APPLICANTS iua,
          HZ_PARTIES pe
    WHERE iuar.Subject_id = l_subject_id
      AND iuar.App_id = iua.App_id
      AND iua.oss_person_id IS NOT NULL
      AND pe.party_id = iua.oss_person_id ;

    /* Fetch all the Qualifications Imported from UCAS for deletion */
    CURSOR cur_del_qual_dets IS
      SELECT uqd.ROWID, uqd.qual_dets_id, uqd.person_id, uqd.exam_level, uqd.subject_code, uqd.year, uqd.sitting, uqd.awarding_body, uqd.approved_result
      FROM IGS_UC_QUAL_DETS uqd
      WHERE imported_flag = 'Y' ;

    /* this is to check whether the record is unique in igs_uc_qual_dets table */
    --smaddali 27-jun-2002 added parameter l_approved_result as this field also is part of the unique key
    -- also added NVL condition for fields which are nullable for bug 2430139
    --smaddali 18-jul-02 interchanged position of parameters exam_level and subject_code for bug 2430139
    CURSOR Cur_check_uniqueness ( l_person_id     igs_uc_qual_dets.person_id%TYPE,
                                  l_exam_level    igs_uc_qual_dets.exam_level%TYPE,
                                  l_subject_code  igs_uc_qual_dets.subject_code%TYPE,
                                  l_year          igs_uc_com_ebl_subj.year%TYPE,
                                  l_sitting       igs_uc_com_ebl_subj.sitting%TYPE,
                                  l_awarding_body igs_uc_com_ebl_subj.awarding_body%TYPE ,
                                  l_approved_result igs_uc_qual_dets.approved_result%TYPE ) IS
    SELECT imported_flag
    FROM   igs_uc_qual_dets
    WHERE  person_id       = l_person_id
    AND    Exam_level      = l_exam_level
    AND    ((subject_code = l_subject_code) OR (subject_code IS NULL AND l_subject_code IS NULL))
    AND    ((year = l_year) OR (year IS NULL AND l_year IS NULL))
    AND    ((sitting = l_sitting) OR (sitting IS NULL AND l_sitting IS NULL))
    AND    ((awarding_body = l_awarding_body) OR (awarding_body IS NULL AND l_awarding_body IS NULL))
    AND    ( (approved_result = l_approved_result) OR (approved_result IS NULL AND l_approved_result IS NULL) ) ;

    /* this will pickup data from HESA table for Awarding body, based in the association code */
    CURSOR Cur_Awarding_body (l_awarding_body igs_uc_com_ebl_subj.awarding_body%TYPE) IS
    SELECT Map2 FROM Igs_he_code_map_val
    WHERE  Association_code = 'UCAS_OSS_AWD_BDY_ASSOC'
    AND    Map1 = l_awarding_body;

    /* this will pickup data from HESA table for Subject code, based in the association code */
    CURSOR Cur_subject_code (l_subject_code  igs_uc_com_ebl_subj.subject_code%TYPE) IS
    SELECT Map2 FROM Igs_he_code_map_val
    WHERE  Association_code = 'UCAS_OSS_SBJ_ASSOC'
    AND    Map1 = l_subject_code;

    /* this will pickup data from HESA table for Exam_level, based in the association code */
    CURSOR Cur_exam_level (l_exam_level  igs_uc_com_ebl_subj.exam_level%TYPE) IS
    SELECT Map2 FROM Igs_he_code_map_val
    WHERE  Association_code = 'UCAS_OSS_AWD_ASSOC'
    AND    Map1 = l_exam_level;

    /* this is to get values from igs_uc_qual_dets table for updation when manually entered */
    CURSOR Cur_qual_dets (l_person_id      igs_uc_qual_dets.person_id%TYPE,
                          l_exam_level     igs_uc_qual_dets.exam_level%TYPE,
                          l_subject_code   igs_uc_qual_dets.subject_code%TYPE,
                          l_year           igs_uc_com_ebl_subj.year%TYPE,
                          l_sitting        igs_uc_com_ebl_subj.sitting%TYPE,
                          l_awarding_body  igs_uc_com_ebl_subj.awarding_body%TYPE) IS
    SELECT ROWID, Qual_dets_id, Person_id, Exam_level, Subject_code, Year, Sitting, Awarding_body,
           Grading_schema_cd, Version_number, Predicted_result, Approved_result, Claimed_result,
           UCAS_tariff, Imported_flag, Imported_date
    FROM  igs_uc_qual_dets
    WHERE person_id      = l_person_id
    AND   Exam_level     = l_exam_level
    AND   Subject_code   = l_subject_code
    AND   Year           = l_year
    AND   Sitting        = l_sitting
    AND   Awarding_body  = l_awarding_body;
    cur_qual_dets_val     Cur_qual_dets%ROWTYPE;

    --smaddali added cursor for bug 2409543 to get the grading schema cd associated to the qualification (award)
    CURSOR c_grad_sch (cp_award_cd  igs_ps_awd.award_cd%TYPE ) IS
    SELECT grading_schema_cd , gs_version_number
    FROM igs_ps_awd
    WHERE award_cd = cp_award_cd ;
    c_grad_sch_rec  c_grad_sch%ROWTYPE ;

    --Check if Advanced standing details exists for the qualification or not.
    CURSOR cur_adv_std_exists(cp_qual_dets_id igs_uc_qual_dets.qual_dets_id%TYPE) IS
    SELECT 'X'
    FROM igs_av_stnd_unit_lvl_all
    WHERE qual_dets_id = cp_qual_dets_id;

    --Get the Person Number for the Person ID passed.
    CURSOR cur_per_no(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
      SELECT person_number
      FROM   igs_pe_person_base_v
      WHERE  person_id = cp_person_id;

    --To Identify whether the qualification is valid or not
    CURSOR cur_qual_valid ( cp_person_id          igs_uc_qual_dets.person_id%TYPE,
                            cp_subject_code       igs_uc_qual_dets.subject_code%TYPE,
                            cp_year               igs_uc_qual_dets.year%TYPE,
                            cp_sitting            igs_uc_qual_dets.sitting%TYPE,
                            cp_awarding_body      igs_uc_qual_dets.awarding_body%TYPE,
                            cp_exam_level         igs_uc_qual_dets.exam_level%TYPE,
                            cp_approved_result    igs_uc_qual_dets.approved_result%TYPE) IS
    SELECT 'X'
    FROM   igs_uc_app_results apr
    WHERE  apr.app_no IN ( SELECT app_no
                           FROM   igs_uc_applicants
                           WHERE  oss_person_id = cp_person_id
                         )
    AND    apr.subject_id IN ( SELECT subject_id
                               FROM   igs_uc_com_ebl_subj
                               WHERE  subject_code IN ( SELECT msbj.map1
                                                        FROM   igs_he_code_map_val msbj
                                                        WHERE  msbj.association_code = 'UCAS_OSS_SBJ_ASSOC'
                                                        AND    msbj.map2 = cp_subject_code  )
                              )
    AND    apr.year    = cp_year
    AND    apr.sitting = cp_sitting
    AND    apr.award_body IN ( SELECT mawb.map1
                               FROM   igs_he_code_map_val mawb
                               WHERE  mawb.association_code = 'UCAS_OSS_AWD_BDY_ASSOC'
                               AND    mawb.map2 = cp_awarding_body
                              )
    AND    apr.exam_level IN ( SELECT mawd.map1
                               FROM   igs_he_code_map_val mawd
                               WHERE  mawd.association_code = 'UCAS_OSS_AWD_ASSOC'
                               AND    mawd.map2 = cp_exam_level
                             )
    AND    ( (NVL(UPPER(TRIM(apr.ebl_amended_result)),UPPER(TRIM(apr.ebl_result))) = cp_approved_result)
             OR (cp_approved_result IS NULL AND apr.ebl_amended_result IS NULL AND apr.ebl_result IS NULL)
           );

    l_oss_awarding_body   igs_uc_qual_dets.Awarding_body%TYPE;
    l_oss_subject_code    igs_uc_qual_dets.subject_code%TYPE;
    l_oss_exam_level      igs_uc_qual_dets.exam_level%TYPE;
    l_person_id           igs_uc_qual_dets.person_id%TYPE;
    l_exam_level          igs_uc_qual_dets.exam_level%TYPE;
    l_subject_code        igs_uc_qual_dets.subject_code%TYPE;
    l_year                igs_uc_com_ebl_subj.year%TYPE;
    l_sitting             igs_uc_com_ebl_subj.sitting%TYPE;
    l_awarding_body       igs_uc_com_ebl_subj.awarding_body%TYPE;
    l_imported            igs_uc_qual_dets.imported_flag%TYPE;
    l_qual_dets_id igs_uc_qual_dets.Qual_dets_id%TYPE;
    igs_uc_he_not_enabled_excep EXCEPTION;

    l_records_updated     NUMBER;
    l_records_inserted    NUMBER;
    l_records_deleted     NUMBER;
    l_records_errored     NUMBER;

    l_msg_index           NUMBER;
    l_msg_count           NUMBER;
    l_mesg_data           VARCHAR2(2000);
    l_rowid               VARCHAR2(25);
    l_validation_status   BOOLEAN ;
    l_rec_found           VARCHAR2(1);
    l_person_number        igs_pe_person_base_v.person_number%TYPE;

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    /* defaulting the err buf and err code so that if it ends with out error this value will be returned */
    errbuf  := NULL;
    retcode := 0;
    l_records_deleted := 0;

    /* Checking whether the UK profile is enabled */
    IF NOT (igs_uc_utils.is_ucas_hesa_enabled) THEN
      RAISE igs_uc_he_not_enabled_excep;  /* user defined exception */
    END IF;

    -- Displays log message "Deleting the existing qualifications that are imported from UCAS and not having Advanced standing details associated with it.".
    fnd_message.set_name('IGS','IGS_UC_QUAL_DETS_DELETE');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log,' ' );

    -- Deleting All the existing Qualifications Records Imported from UCAS
    -- and creating the Qualifications from the UCAS Interface Table.
    -- This was enhanced for the bug,2825034
    FOR cur_del_qual_dets_rec IN cur_del_qual_dets LOOP

      l_rec_found := NULL;
      --Check if Advanced standing details exists for the qualification or not.
      OPEN cur_adv_std_exists(cur_del_qual_dets_rec.qual_dets_id);
      FETCH cur_adv_std_exists INTO l_rec_found;
      CLOSE cur_adv_std_exists ;

      IF l_rec_found = 'X' THEN
        --If advanced standing details exists then check it it is a Qualification which was sent in error by UCAS.
        --To check whether the qualification in valid or not, verify the existence of Qualification record in the
        --IGS_UC_APP_RESULTS table.  If a record exists in App. Results table then consider it as a valid qualification.

        --Get the Person Number for the Person ID passed.
        OPEN cur_per_no (cur_del_qual_dets_rec.person_id);
        FETCH cur_per_no INTO l_person_number;
        CLOSE cur_per_no;

        l_rec_found          := NULL;
        --Check if the record exists in IGS_UC_APP_RESULTS for the Qualification Details exists in the IGS_UC_QUAL_DETS table.
        OPEN cur_qual_valid (cur_del_qual_dets_rec.person_id,
                             cur_del_qual_dets_rec.subject_code,
                             cur_del_qual_dets_rec.year,
                             cur_del_qual_dets_rec.sitting,
                             cur_del_qual_dets_rec.awarding_body,
                             cur_del_qual_dets_rec.exam_level,
                             cur_del_qual_dets_rec.approved_result );
        FETCH cur_qual_valid INTO l_rec_found;
        CLOSE cur_qual_valid;

        --If record exists then consider the Qualification as a valid otherwise its an invalid qualification which was not resent by UCAS.
        IF l_rec_found = 'X' THEN
          --Valid Qualification. So display appropriate message asking user's mannual review.
          fnd_message.set_name('IGS','IGS_UC_QUAL_ADV_DET_EXISTS');
          fnd_message.set_token('PER_NO',  l_person_number);
          fnd_message.set_token('EXM_LVL', cur_del_qual_dets_rec.exam_level);
          fnd_message.set_token('SUBJ_CD', cur_del_qual_dets_rec.subject_code);
          fnd_message.set_token('YEAR',    cur_del_qual_dets_rec.year);
          fnd_message.set_token('SITTING', cur_del_qual_dets_rec.sitting);
          fnd_message.set_token('AWD_BDY', cur_del_qual_dets_rec.awarding_body);
          fnd_message.set_token('EBL_RSLT',cur_del_qual_dets_rec.approved_result);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          fnd_file.put_line(fnd_file.log,' ' );
        ELSE
          --Invalid Qualification. So display appropriate message asking user's mannual review.
          fnd_message.set_name('IGS','IGS_UC_QUAL_DETS_INVALID');
          fnd_message.set_token('PER_NO',  l_person_number);
          fnd_message.set_token('EXM_LVL', cur_del_qual_dets_rec.exam_level);
          fnd_message.set_token('SUBJ_CD', cur_del_qual_dets_rec.subject_code);
          fnd_message.set_token('YEAR',    cur_del_qual_dets_rec.year);
          fnd_message.set_token('SITTING', cur_del_qual_dets_rec.sitting);
          fnd_message.set_token('AWD_BDY', cur_del_qual_dets_rec.awarding_body);
          fnd_message.set_token('EBL_RSLT',cur_del_qual_dets_rec.approved_result);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          fnd_file.put_line(fnd_file.log,' ' );
        END IF;

      ELSE
        --Delete the existing imported Qualification when advanced standing details doesn't exists.
        igs_uc_qual_dets_pkg.delete_row( x_rowid => cur_del_qual_dets_rec.ROWID );
        l_records_deleted := l_records_deleted + 1;
      END IF;

    END LOOP ;

    -- Displays log message "Importing Qualification details data from UCAS Interface table to Qualification Details table".
    fnd_file.put_line(fnd_file.log,' ' );
    fnd_message.set_name('IGS','IGS_UC_IMP_QUAL_DETS');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log,' ' );

    /* Picking up records from igs_uc_com_ebl_subj table for Importing in to qual dets table */
    FOR I IN cur_ucas_interface LOOP

      -- initializing the local variables
      l_oss_exam_level := NULL ;
      l_oss_subject_code := NULL ;
      l_oss_awarding_body := NULL ;

      /* taking the map1 value for the exam level */
      OPEN  Cur_exam_level (I.Exam_level);
      FETCH Cur_exam_level INTO l_oss_exam_level;
      CLOSE Cur_exam_level;

      /* taking the map1 value for the Subject code*/
      OPEN  Cur_Subject_code (I.subject_code);
      FETCH Cur_Subject_code INTO l_oss_subject_code;
      CLOSE Cur_Subject_code;

      /* taking the map1 value for the Awarding body */
      OPEN  Cur_Awarding_body (I.Awarding_body);
      FETCH Cur_Awarding_body INTO l_oss_awarding_body;
      CLOSE Cur_Awarding_body;


      /* getting the associated person id for inserting in to igs_uc_qual_dets table */
      FOR J IN cur_person_id (I.subject_id)  LOOP
        BEGIN

          l_msg_count := igs_ge_msg_stack.count_msg;
          l_imported := NULL;

          /* checking whether the same record combination exists */
          --smaddali 27-jun-2002 added parameter j.ebl_result as this field also is part of te unique key for bug 2430139
          OPEN   Cur_check_uniqueness (J.person_id,  l_oss_exam_level, l_oss_subject_code,
                                       I.year, I.sitting, l_oss_awarding_body, J.ebl_result);
          FETCH  Cur_check_uniqueness INTO l_imported ;
          CLOSE  Cur_check_uniqueness;

          IF l_imported = 'Y' THEN

            --Diplays message "the record is already imported.
            --so nothing should happen in this case i.e., not considered for import".
            fnd_message.set_name('IGS','IGS_UC_QUAL_DETS_REC_EXISTS');
            fnd_message.set_token('PER_NO',  J.person_number);
            fnd_message.set_token('APP_NO',  J.app_no);
            fnd_message.set_token('EXM_LVL', l_oss_exam_level);
            fnd_message.set_token('SUBJ_CD', l_oss_subject_code);
            fnd_message.set_token('YEAR',    I.year);
            fnd_message.set_token('SITTING', I.sitting);
            fnd_message.set_token('AWD_BDY', l_oss_awarding_body);
            fnd_message.set_token('EBL_RSLT',J.ebl_result);
            fnd_file.put_line(fnd_file.log, fnd_message.get);

          ELSIF l_imported = 'N' THEN

            /* This means the record is manually entered so only the approved result should be updated */
            OPEN   cur_qual_dets (J.person_id,  l_oss_exam_level, l_oss_subject_code, I.year, I.sitting, l_oss_awarding_body);
            FETCH  cur_qual_dets INTO Cur_qual_dets_val;
            CLOSE  cur_qual_dets;

            l_rec_found := NULL;
            --Check if Advanced standing details exists for the non-imported qualification or not.
            OPEN cur_adv_std_exists(Cur_qual_dets_val.qual_dets_id);
            FETCH cur_adv_std_exists INTO l_rec_found;
            CLOSE cur_adv_std_exists ;

            IF l_rec_found = 'X' THEN
              --Display a message that qualification is not updated because of advanced standing details exist.
              fnd_message.set_name('IGS','IGS_UC_ADV_STD_DET_EXISTS');
              fnd_message.set_token('PER_NO',  J.person_number);
              fnd_message.set_token('APP_NO',  J.app_no);
              fnd_message.set_token('EXM_LVL', Cur_qual_dets_val.Exam_level);
              fnd_message.set_token('SUBJ_CD', Cur_qual_dets_val.subject_code);
              fnd_message.set_token('YEAR',    Cur_qual_dets_val.year);
              fnd_message.set_token('SITTING', Cur_qual_dets_val.sitting);
              fnd_message.set_token('AWD_BDY', Cur_qual_dets_val.awarding_body);
              fnd_message.set_token('EBL_RSLT',J.ebl_result);
              fnd_file.put_line(fnd_file.log, fnd_message.get);
            ELSE
              --Diplays message "Updating record".
              fnd_message.set_name('IGS','IGS_UC_UPD_QUAL_DETS_REC');
              fnd_message.set_token('PER_NO',  J.person_number);
              fnd_message.set_token('APP_NO',  J.app_no);
              fnd_message.set_token('EXM_LVL', Cur_qual_dets_val.Exam_level);
              fnd_message.set_token('SUBJ_CD', Cur_qual_dets_val.subject_code);
              fnd_message.set_token('YEAR',    Cur_qual_dets_val.year);
              fnd_message.set_token('SITTING', Cur_qual_dets_val.sitting);
              fnd_message.set_token('AWD_BDY', Cur_qual_dets_val.awarding_body);
              fnd_message.set_token('GS_CD',   Cur_qual_dets_val.grading_schema_cd);
              fnd_message.set_token('GS_VER',  Cur_qual_dets_val.version_number);
              fnd_message.set_token('PRD_RSLT',Cur_qual_dets_val.predicted_result);
              fnd_message.set_token('EBL_RSLT',J.ebl_result);
              fnd_message.set_token('CLM_RSLT',Cur_qual_dets_val.claimed_result);
              fnd_message.set_token('TARIFF',  Cur_qual_dets_val.ucas_tariff);
              fnd_file.put_line(fnd_file.log, fnd_message.get);

              IF cur_qual_dets_val.grading_schema_cd IS NOT NULL
                AND cur_qual_dets_val.version_number IS NOT NULL
                AND j.ebl_result IS NOT NULL
                AND NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                          UPPER(TRIM(c_grad_sch_rec.grading_schema_cd)),
                          c_grad_sch_rec.gs_version_number,
                          UPPER(TRIM(j.claimed_result)) ) THEN

               fnd_message.set_name('IGS','IGS_UC_GRAD_NOT_FOUND');
               fnd_message.set_token('GS_CD',cur_qual_dets_val.grading_schema_cd);
               fnd_message.set_token('GS_VER',cur_qual_dets_val.version_number);
               fnd_message.set_token('APP_RESULT',j.ebl_result);
               fnd_file.put_line(fnd_file.log, fnd_message.get);
               l_records_errored := NVL(l_records_errored ,0) + 1 ;

              ELSE

                igs_uc_qual_dets_pkg.Update_row ( x_mode              => 'R',
                                                  x_rowid             => Cur_qual_dets_val.ROWID,
                                                  x_Qual_dets_id      => Cur_qual_dets_val.Qual_dets_id,
                                                  x_Person_id         => Cur_qual_dets_val.person_id,
                                                  x_Exam_level        => Cur_qual_dets_val.Exam_level,
                                                  x_Subject_code      => Cur_qual_dets_val.subject_code,
                                                  x_Year              => Cur_qual_dets_val.year,
                                                  x_Sitting           => Cur_qual_dets_val.sitting,
                                                  x_Awarding_body     => Cur_qual_dets_val.awarding_body,
                                                  x_grading_schema_cd => Cur_qual_dets_val.grading_schema_cd,
                                                  x_version_number    => Cur_qual_dets_val.version_number,
                                                  x_Predicted_result  => Cur_qual_dets_val.predicted_result,
                                                  x_Approved_result   => J.EBL_result,
                                                  x_Claimed_result    => Cur_qual_dets_val.claimed_result,
                                                  x_UCAS_tariff       => Cur_qual_dets_val.ucas_tariff,
                                                  x_Imported_flag     => 'Y',
                                                  x_Imported_date     => Cur_qual_dets_val.Imported_date );
                l_records_updated := NVL(l_records_updated,0) + 1 ;

              END IF;

            END IF;  -- End of check for existence of Advanced Standing Unit level details

          ELSIF l_imported IS NULL Then

            --smaddali added this code for bug 2409543
            c_grad_sch_rec := NULL  ;
            OPEN c_grad_sch (l_oss_exam_level) ;
            FETCH c_grad_sch INTO  c_grad_sch_rec ;
            CLOSE c_grad_sch ;

            --smaddali 27-jun-2002 added fields grading_schema_cd , version_number, logging person_number
            --instead of person_id and logging application number for bug 2430139
            --Diplays message "Inserting record".
            fnd_message.set_name('IGS','IGS_UC_INS_QUAL_DETS_REC');
            fnd_message.set_token('PER_NO',  J.person_Number);
            fnd_message.set_token('APP_NO',  J.app_no);
            fnd_message.set_token('EXM_LVL', l_oss_exam_level||' ('||I.exam_level||') ');
            fnd_message.set_token('SUBJ_CD', l_oss_subject_code||' (' ||I.subject_code||') ');
            fnd_message.set_token('YEAR',    I.year);
            fnd_message.set_token('SITTING', I.sitting);
            fnd_message.set_token('AWD_BDY', l_oss_awarding_body||' ('||I.Awarding_body||') ');
            fnd_message.set_token('GS_CD',   C_grad_sch_rec.grading_schema_cd);
            fnd_message.set_token('GS_VER',  C_grad_sch_rec.gs_version_number);
            fnd_message.set_token('EBL_RSLT',J.ebl_result);
            fnd_message.set_token('CLM_RSLT',J.claimed_result);
            fnd_file.put_line(fnd_file.log, fnd_message.get);

            l_rowid := NULL ;
            l_validation_status := TRUE ;

            -- Check whether the UCAS EXam Level to OSS Award Mapping exist in the HESA Table
            IF l_oss_exam_level IS NULL THEN
              fnd_message.set_name('IGS','IGS_UC_INV_MAPPING_VAL');
              fnd_message.set_token('CODE',I.Exam_level);
              fnd_message.set_token('TYPE', 'EXAM LEVEL');
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              l_validation_status := FALSE ;
            END IF ;

            -- Check whether the Grading Scema and Grade Combination exist in the Parent Table
            IF c_grad_sch_rec.grading_schema_cd IS NOT NULL
              AND c_grad_sch_rec.gs_version_number IS NOT NULL
              AND j.ebl_result IS NOT NULL
              AND NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                        UPPER(TRIM(c_grad_sch_rec.grading_schema_cd)),
                        c_grad_sch_rec.gs_version_number,
                        UPPER(TRIM(j.ebl_result)) ) THEN

              fnd_message.set_name('IGS','IGS_UC_GRAD_NOT_FOUND');
              fnd_message.set_token('GS_CD',c_grad_sch_rec.grading_schema_cd);
              fnd_message.set_token('GS_VER',c_grad_sch_rec.gs_version_number);
              fnd_message.set_token('APP_RESULT',j.ebl_result);
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              l_validation_status := FALSE ;

            ELSIF c_grad_sch_rec.grading_schema_cd IS NOT NULL
              AND c_grad_sch_rec.gs_version_number IS NOT NULL
              AND j.claimed_result IS NOT NULL
              AND NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                        UPPER(TRIM(c_grad_sch_rec.grading_schema_cd)),
                        c_grad_sch_rec.gs_version_number,
                        UPPER(TRIM(j.claimed_result)) ) THEN

              fnd_message.set_name('IGS','IGS_UC_GRAD_NOT_FOUND');
              fnd_message.set_token('GS_CD',c_grad_sch_rec.grading_schema_cd);
              fnd_message.set_token('GS_VER',c_grad_sch_rec.gs_version_number);
              fnd_message.set_token('APP_RESULT',j.claimed_result);
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              l_validation_status := FALSE ;

            END IF ;

            IF l_validation_status = TRUE THEN

              /* Inserting record in to igs_uc_qual_dets table thru TBH */
              Igs_uc_qual_dets_pkg.Insert_row ( x_mode              => 'R',
                                                x_rowid             => l_rowid,
                                                x_Qual_dets_id      => l_Qual_dets_id,
                                                x_Person_id         => J.person_id,
                                                x_Exam_level        => l_oss_exam_level,
                                                x_Subject_code      => l_oss_subject_code,
                                                x_Year              => I.year,
                                                x_Sitting           => I.sitting,
                                                x_Awarding_body     => l_oss_awarding_body,
                                                x_grading_schema_cd => c_grad_sch_rec.grading_schema_cd ,
                                                x_version_number    => c_grad_sch_rec.gs_version_number,
                                                x_Predicted_result  => NULL,
                                                x_Approved_result   => J.EBL_result,
                                                x_Claimed_result    => J.claimed_result,
                                                x_UCAS_tariff       => NULL,
                                                x_Imported_flag     => 'Y',
                                                x_Imported_date     => TRUNC(SYSDATE) );

              l_records_inserted := NVL(l_records_inserted ,0) + 1 ;
            ELSE
              l_records_errored := NVL(l_records_errored ,0) + 1 ;
            END IF;

          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            --When the error occurs, log the Error message and continue with processing of next record.
            l_records_errored := NVL(l_records_errored ,0) + 1 ;
            l_mesg_data := NULL;
            l_msg_index := NULL;
            IF ( l_msg_count <> igs_ge_msg_stack.count_msg) THEN
              igs_ge_msg_stack.get(igs_ge_msg_stack.count_msg,fnd_api.g_false, l_mesg_data, l_msg_index);
              IF l_mesg_data IS NOT NULL THEN
                l_mesg_data := ' - '||l_mesg_data;
              END IF;
            ELSE
              l_mesg_data := SQLERRM;
              IF l_mesg_data IS NOT NULL THEN
                l_mesg_data := ' - '||l_mesg_data;
              END IF;
            END IF;
            fnd_message.set_name('IGS','IGS_UC_QUAL_DET_IMP_ERR');
            fnd_file.put_line(fnd_file.log,fnd_message.get()||l_mesg_data);

        END; -- End of Anonymous block

        fnd_file.put_line(fnd_file.log,' ' );
        l_msg_count := NULL;

      END LOOP;  -- Insert/Update Igs_uc_qual_dets looop

    END LOOP;  -- igs_uc_com_ebl_subj Records Loop

    fnd_file.put_line(fnd_file.log,' ' );
    fnd_file.put_line(fnd_file.log,RPAD('-',22,'-'));
    fnd_file.put_line(fnd_file.log,SUBSTR(fnd_message.get_string('IGS','IGS_UC_INS_REC_STAT_INT'), 29, 22));
    fnd_file.put_line(fnd_file.log,RPAD('-',22,'-'));
    fnd_message.set_name('IGS','IGS_UC_DEL_REC_COUNT');
    fnd_message.set_token('REC_CNT', NVL(l_records_deleted,0));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_message.set_name('IGS','IGS_UC_INS_REC_COUNT');
    fnd_message.set_token('REC_CNT', NVL(l_records_inserted,0));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_message.set_name('IGS','IGS_UC_UPD_REC_COUNT');
    fnd_message.set_token('REC_CNT', NVL(l_records_updated,0));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_message.set_name('IGS','IGS_UC_ERR_REC_COUNT');
    fnd_message.set_token('REC_CNT', NVL(l_records_errored,0));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log,' ' );


  EXCEPTION

    WHEN igs_uc_he_not_enabled_excep THEN
      fnd_message.set_name('IGS','IGS_UC_HE_NOT_ENABLED');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      retcode   := 2;
      igs_ge_msg_stack.conc_exception_hndl;

    WHEN OTHERS THEN
      ROLLBACK;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME', 'IGS_UC_QUAL_DETS_IMP_PKG.IGS_UC_QUAL_DETS_IMP'||' - '||SQLERRM);
      fnd_message.retrieve (Errbuf);
      retcode := 2;
      igs_ge_msg_stack.conc_exception_hndl;

  END igs_uc_qual_dets_imp;





PROCEDURE validate_pe_qual(p_uc_qual_cur igs_ad_imp_028.c_uc_qual_cur%ROWTYPE,
                           p_status      OUT  NOCOPY VARCHAR2,
                                                                        p_error_code  OUT NOCOPY VARCHAR2) IS
    /*************************************************************
    Created By : rgangara
    Date Created On : 19-May-03
    Purpose : This procedure will be called by Admission Import Process
              while importing Previous QUalification details Legacy Data.
              This is a validation procedure which would validate the
              data populated in Interface table before being imported into OSS.
              UCAS Bug for tracking this change in UCAS - Bug# 2961536
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    anwest          09-Jun-04      Changes for bug #4401841
    rgangara        19-May-03      Create version for Adm Legacy import API.
                                   UCAS bug for this Enh 2961536.

    rgangara        04-JUL-03      Removed references to CLOSED INdicators as it is not
                                   required for Legacy import. Also allowing for
                                   S_Award_Type = COURSE.(bug#3037207, 3037229, 3037238).
                                   Also removed reference to institution status = 'ACTIVE'
                                   after clarifying with Babitha/Sara.

    (reverse chronological order - newest change first)
    ***************************************************************/


   -- For validating Exam level/Qualification
   CURSOR Cur_exam_lvl IS
   SELECT grading_schema_cd,
          gs_version_number
   FROM   igs_ps_awd
   WHERE  award_cd = p_uc_qual_cur.exam_level
   AND    s_award_type IN ('ENTRYQUAL', 'COURSE');

   exam_lvl_rec cur_exam_lvl%ROWTYPE;

   -- For validating Subject Code
   CURSOR cur_subj_code IS
   SELECT 'X'
   FROM   igs_ps_fld_of_study
   WHERE  field_of_study = p_uc_qual_cur.subject_code;

   -- Hard coded values for YEAR validation as mentioned in Adm TD TD_LegacyImport_Admissions_s1a.
   p_min_year  NUMBER := 1900;
   p_max_year  NUMBER := 2200;


   -- For validating Awarding Body
   -- anwest 09-Jun-05
   -- updated cursor for HZ_PARTIES.PARTY_NUMBER issue - bug #4401841
   CURSOR cur_awd_body IS
   SELECT 'X'
   FROM  hz_parties hp,
         igs_pe_hz_parties ihp,
         igs_or_org_inst_type oit,
         igs_or_inst_stat  ois
   WHERE hp.party_id = ihp.party_id
   AND   ihp.oss_org_unit_cd = p_uc_qual_cur.awarding_body
   AND   hp.status = 'A'
   AND   ihp.oi_institution_status = ois.institution_status (+)
   AND   ihp.oi_institution_type = oit.institution_type (+)
   AND   ihp.inst_org_ind = 'I'
   AND   oit.system_inst_type IN ('POST-SECONDARY','OTHER');


   -- Validating Grading Schema.
   -- Grading schema can be provided by user in the INT Table.
   -- If user provided the Grading schema details in the INT table, then
   -- it has to be validated that it exists in Grading schema master table.
   -- If found then check whether any of the Grades (Claimed, Predicted and
   -- Approved) are valid for the grading schema given. If not log error
   -- else import the grading schema details.
   -- However, when user has not provided any grading schema details then
   -- the grading schema derived from the Exam level is to be used for all
   -- validations.
   CURSOR cur_grd_sch (cp_grd_sch igs_as_grd_sch_grade.grading_schema_cd%TYPE,
                       cp_grd_ver igs_as_grd_sch_grade.version_number%TYPE,
                       cp_grade igs_as_grd_sch_grade.grade%TYPE) IS
   SELECT 'X'
   FROM   igs_as_grd_sch_grade gsch,
          igs_as_grd_schema ags
   WHERE  gsch.grading_schema_cd = ags.grading_schema_cd
   AND    gsch.version_number    = ags.version_number
   AND    gsch.grading_schema_cd = cp_grd_sch
   AND    gsch.version_number    = cp_grd_ver
   AND    ags.grading_schema_type = 'AWARD'
   AND    gsch.grade  = NVL(cp_grade, gsch.grade);

   l_grd_sch_rec cur_grd_sch%ROWTYPE;
   lv_found  VARCHAR2(1) := 'N';
   l_grading_schema igs_as_grd_sch_grade.grading_schema_cd%TYPE;
   l_version_number igs_as_grd_sch_grade.version_number%TYPE;

   BEGIN

      -- Exam Level/Qualification Validation
         OPEN Cur_exam_lvl;
         FETCH cur_exam_lvl INTO exam_lvl_rec;

         IF cur_exam_lvl%NOTFOUND THEN
            CLOSE cur_exam_lvl;
            exam_lvl_rec.grading_schema_cd := NULL;
            exam_lvl_rec.GS_version_number := NULL;
            p_status := '3';
            p_error_code := 'E627';
            Return;
         ELSE
            CLOSE cur_exam_lvl;
         END IF;

      -- Subject Code validation
      IF p_uc_qual_cur.subject_code IS NOT NULL THEN
         OPEN Cur_subj_code;
         FETCH Cur_subj_code INTO lv_found;
         IF Cur_subj_code%NOTFOUND THEN
            CLOSE cur_subj_code;
            p_status := '3';
            p_error_code := 'E628';
            Return;
         ELSE
            CLOSE cur_subj_code;
         END IF;
      END IF;

      -- YEAR validation
      IF p_uc_qual_cur.year IS NOT NULL THEN
         IF p_uc_qual_cur.year NOT BETWEEN p_min_year AND p_max_year THEN
            p_status := '3';
            p_error_code := 'E629';
            Return;
         END IF;
      END IF;


      -- Awarding Body validation
      IF p_uc_qual_cur.awarding_body IS NOT NULL THEN
         OPEN Cur_awd_body;
         FETCH Cur_awd_body INTO lv_found;
         IF Cur_awd_body%NOTFOUND THEN
            p_status := '3';
            p_error_code := 'E630';
            CLOSE cur_awd_body;
            Return;
         ELSE
            CLOSE cur_awd_body;
         END IF;
      END IF;

      -- validating that if Grading Schema is provided by the user, it exists in OSS.
      IF p_uc_qual_cur.grading_schema_cd IS NOT NULL OR p_uc_qual_cur.version_Number IS NOT NULL THEN
         -- Since only grading schema is to be checked, passing NULL for Grade parameter
         OPEN Cur_grd_sch(p_uc_qual_cur.grading_schema_cd,
                          p_uc_qual_cur.version_Number,
                          '');
         FETCH Cur_grd_sch INTO l_grd_sch_rec;
         IF Cur_grd_sch%NOTFOUND THEN
            CLOSE Cur_grd_sch;
            p_status := '3';
            p_error_code := 'E682';
            Return;
         ELSE
            -- Since user entered Grading schema is valid, set the variables with these values for
            -- further processing and validations
            l_grading_schema := p_uc_qual_cur.grading_schema_cd;
            l_version_number := p_uc_qual_cur.version_number;
            CLOSE Cur_grd_sch;
         END IF;
      ELSE
        -- Since user entered Grading schema is NULL, set the variables with values from Exam level's
        -- grading schema for further processing and validations.
        l_grading_schema := exam_lvl_rec.grading_schema_cd;
        l_version_number := exam_lvl_rec.gs_version_number;
      END IF;

      -- Grading Schema and Version for Predicted Result
      IF  p_uc_qual_cur.predicted_result IS NOT NULL THEN
         OPEN Cur_grd_sch (l_grading_schema,
                           l_version_number,
                           p_uc_qual_cur.predicted_result);
         FETCH Cur_grd_sch INTO l_grd_sch_rec;
         IF Cur_grd_sch%NOTFOUND THEN
            CLOSE Cur_grd_sch;
            p_status := '3';
            p_error_code := 'E631';
            Return;
         ELSE
            CLOSE Cur_grd_sch;
         END IF;
      END IF;


      -- Grading Schema and Version for Approved Result
      IF p_uc_qual_cur.approved_result IS NOT NULL THEN
         OPEN Cur_grd_sch (l_grading_schema,
                           l_version_number,
                           p_uc_qual_cur.approved_result);
         FETCH Cur_grd_sch INTO l_grd_sch_rec;
         IF Cur_grd_sch%NOTFOUND THEN
            CLOSE Cur_grd_sch;
            p_status := '3';
            p_error_code := 'E632';
            Return;
         ELSE
            CLOSE Cur_grd_sch;
         END IF;
      END IF;


      -- Grading Schema and Version for CLAIMED Result
      IF p_uc_qual_cur.claimed_result IS NOT NULL THEN
         OPEN Cur_grd_sch (l_grading_schema,
                           l_version_number,
                           p_uc_qual_cur.claimed_result);
         FETCH Cur_grd_sch INTO l_grd_sch_rec;
         IF Cur_grd_sch%NOTFOUND THEN
            CLOSE Cur_grd_sch;
            p_status := '3';
            p_error_code := 'E633';
            Return;
         ELSE
            CLOSE Cur_grd_sch;
         END IF;
      END IF;


      -- Validate SITTING
      IF NOT p_uc_qual_cur.Sitting  IN ('S', 'W') THEN
         p_status := '3';
         p_error_code := 'E634';
         Return;
      END IF;

      -- At this point all validations are successful
      p_status := 1;
      p_error_code := NULL;

END validate_pe_qual;

END igs_uc_qual_dets_imp_pkg;

/
