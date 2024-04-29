--------------------------------------------------------
--  DDL for Package Body IGR_IMP_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_IMP_001" AS
/* $Header: IGSRT02B.pls 120.1 2006/06/27 12:24:29 rbezawad noship $ */
  PROCEDURE trn_ss_inq_int_data(
    errbuf              OUT NOCOPY   VARCHAR2,
    retcode             OUT NOCOPY   NUMBER,
    p_inquiry_type_id   IN    NUMBER,
    p_inq_start_date    IN    VARCHAR2 ,
    p_inq_end_date      IN    VARCHAR2
  ) AS
    /* Variable Declaration */
    l_bool  BOOLEAN;
    l_batch_desc             igs_ad_imp_batch_det.batch_Desc%TYPE;
    l_batch_id                     NUMBER;
    l_interface_id                 NUMBER;
    l_status                       NUMBER := 0;
    l_tokenstr                     VARCHAR2(500);
    completed_flag                 VARCHAR2(1);
    inserted              CONSTANT VARCHAR2(1)    := 'I' ;
    updated               CONSTANT VARCHAR2(1)    := 'U' ;
    l_inq_start_date               DATE           := igs_ge_date.igsdate(P_INQ_START_DATE);
    l_inq_end_date                 DATE           := igs_ge_date.igsdate(P_INQ_END_DATE);

--    need to use todate to run from backend API, so retaining the below two lines
--    l_inq_start_date               DATE           := todate(P_INQ_START_DATE);
--    l_inq_end_date                 DATE           := todate(P_INQ_END_DATE);

    null_validation_fails          EXCEPTION;
    date_validation_fails          EXCEPTION;

    CURSOR batch_id_cur IS
      SELECT igs_ad_interface_batch_id_s.nextval FROM dual;

    CURSOR interface_id_cur IS
      SELECT igs_ad_interface_s.nextval FROM dual;

       /* This Main Cursor retrieves all the Person and Inquiry Details,
       with Status 'I' or 'U' which are then inserted
       into IGS_AD_INTERFACE_ALL,IGS_AD_STAT_INT,IGS_PE_CITIZEN_INT and
       IGS_AD_INQ_APPL_INT after all the validations are successfull
    */

    CURSOR inq_per_cur IS
      SELECT
        pe.org_id,
        pe.inq_person_id,
        pe.imp_source_type_id,
        pe.given_name,
        pe.middle_name,
        pe.surname,
        pe.preferred_given_name,
        pe.title,
        pe.suffix,
        pe.pre_name_adjunct,
        pe.birth_dt,
        pe.sex,
        pe.ethnic_origin,
        pe.citizenship1_id,
        pe.citizenship2_id,
        inq.inq_inq_id,
        inq.inquiry_type_id,
        inq.inq_entry_level_id,
        inq.inquiry_source_type_id,
        inq.inquiry_date,
        inq.edu_goal_id,
        inq.school_of_interest_id,
        inq.how_knowus_id,
        inq.who_influenced_id,
        inq.comments,
        inq.acad_cal_type,
        inq.acad_ci_sequence_number,
        inq.adm_cal_type,
        inq.adm_ci_sequence_number,
        inq.attribute_category,
        inq.attribute1,
        inq.attribute2,
        inq.attribute3,
        inq.attribute4,
        inq.attribute5,
        inq.attribute6,
        inq.attribute7,
        inq.attribute8,
        inq.attribute9,
        inq.attribute10,
        inq.attribute11,
        inq.attribute12,
        inq.attribute13,
        inq.attribute14,
        inq.attribute15,
        inq.attribute16,
        inq.attribute17,
        inq.attribute18,
        inq.attribute19,
        inq.attribute20,
    inq.source_promotion_id
      FROM
    igr_is_person pe,
        igr_is_inquiry inq
      WHERE
        pe.inq_person_id = inq.inq_person_id     AND
         inq.inquiry_type_id = p_inquiry_type_id AND
        (
         inq.inquiry_date is Null OR
         (TRUNC(inq.inquiry_date) BETWEEN
           NVL(l_inq_start_date, TRUNC(inq.inquiry_date)) AND
           NVL(l_inq_end_date,TRUNC(inq.inquiry_date))
         )
        ) AND
        pe.status  IN (inserted,updated) AND
        inq.status IN (inserted,updated);

    CURSOR inq_per_contacts_cur(l_person_id igr_is_contact.inq_person_id%TYPE) IS
      SELECT
        inq_contact_id,
        inq_person_id,
        request_id,
        phone_country_code,
        phone_area_code,
        phone_number,
        phone_extension,
        phone_line_type,
        email_address
      FROM
        igr_is_contact
      WHERE
        inq_person_id = l_person_id AND
        status IN (inserted,updated);

    CURSOR inq_per_addr_cur(l_person_id igr_is_address.inq_person_id%TYPE) IS
      SELECT
        addr_line_1,
        addr_line_2,
        addr_line_3,
        addr_line_4,
        city,
        state,
        county,
        province,
        country,
        postcode,
        start_date,
        end_date,
        addr_usage
      FROM
        igr_is_address
      WHERE
        inq_person_id = l_person_id  AND
        status IN (inserted,updated);

    CURSOR inq_per_acad_cur(l_person_id igr_is_acad.inq_person_id%TYPE) IS
      SELECT
        institution_cd,
        current_inst,
        start_date,
        end_date,
        planned_completion_date,
        degree_earned,
        course_major,
        selfrep_inst_gpa,
        selfrep_rank_in_class,
        selfrep_classsize,
        selfrep_total_cp_earned
      FROM
        igr_is_acad
      WHERE
        inq_person_id = l_person_id AND
        status IN (inserted,updated);

    CURSOR inq_per_extra_cur(l_person_id igr_is_extracurr.inq_person_id%TYPE) IS
      SELECT
        interest_type_code,
        interest_name,
        activity_source_cd,
        start_date,
        end_date
      FROM
        igr_is_extracurr
      WHERE
        inq_person_id = l_person_id AND
        status IN (inserted,updated);

    CURSOR inq_sub_interest_type_cur (cp_interest_type_code igr_is_extracurr.interest_type_code%TYPE) IS
      SELECT
    lookup_type
      FROM
        fnd_lookup_values
      WHERE
        lookup_code = cp_interest_type_code AND
        lookup_type in ( 'ENTERTAINMENT', 'INTEREST_TYPE') AND
    enabled_flag = 'Y';

    l_sub_interest_type_code igs_ad_excurr_int.sub_interest_type_code%TYPE;

    CURSOR inq_per_test_cur(l_person_id igr_is_test.inq_person_id%TYPE) IS
      SELECT
        inq_test_id,
        admission_test_type,
        comp_test_score,
        test_date,
        test_source_id
      FROM
        igr_is_test
      WHERE
        inq_person_id =  l_person_id AND
        status IN (inserted,updated);

    CURSOR inq_per_testseg_cur(l_test_id igr_is_testseg.inq_test_id%TYPE) IS
      SELECT
        test_segment_id,
        test_score
      FROM
        igr_is_testseg
      WHERE
        inq_test_id = l_test_id  AND
        status IN (inserted,updated);

    CURSOR inq_info_cur(l_inq_id igr_is_info_req.inq_inq_id%TYPE) IS
      SELECT
        package_item_id
      FROM
        igr_is_info_req
      WHERE
        inq_inq_id = l_inq_id AND
        status IN (inserted,updated);

    -- Bug no 2843629
    -- by rrengara on 13-mar-2003
    -- This cursor will return an empty record if lines table doesnt have
    -- any record correspoding to the inquiry record
    -- So that it will insert dummy record in the interface table

    CURSOR inq_lines_cur(l_inq_inq_id igr_is_i_lines.inq_inq_id%TYPE) IS
       SELECT
         preference,
         product_category_id,
         product_category_set_id
       FROM
         igr_is_i_lines
       WHERE
         inq_inq_id = l_inq_inq_id AND
         status IN (inserted,updated);


--2775931 Start
    CURSOR inq_per_race_cur(l_person_id igr_is_race.person_id%TYPE) IS
      SELECT
        race_cd
      FROM
        igr_is_race
      WHERE
        person_id = l_person_id AND
        status IN (inserted,updated);
--2775931 Start


    /* LOCAL PROCEDURES FOR VALIDATIONS */
    -----------------------------------------------------------------------------------------------------------
    /* Each record from the Self Service table is validated for Null values
       before inserting into the corresponding Interface tables
       using the validation procedures here */

    PROCEDURE validate_interface(inq_rec IN inq_per_cur%ROWTYPE,
                                 status OUT NOCOPY NUMBER,
                                 batch_id IN NUMBER,
                                 interface_id IN NUMBER,
                                 l_token OUT NOCOPY VARCHAR2) AS
    BEGIN
      status:=1;
     IF inq_rec.imp_source_type_id IS NULL OR inq_rec.surname IS NULL OR inq_rec.given_name IS NULL OR
         batch_id IS NULL OR interface_id IS NULL THEN
        status:=0;
        l_token := NULL;
        IF inq_rec.imp_source_type_id IS null THEN
          l_token := 'imp_source_type_id';
        END IF;
        IF inq_rec.surname IS null THEN
          l_token := l_token ||', surname';
        END IF;
        IF inq_rec.given_name IS null THEN
          l_token:=  l_token ||', given_name';
        END IF;
        IF batch_id IS null THEN
          l_token := l_token || ' ,batch_id';
        END IF;
        IF interface_id is null THEN
          l_token := l_token ||' ,interface_id ';
        END IF;
      END IF;
    END validate_interface;

    PROCEDURE validate_inq_appl_int(inq_rec IN inq_per_cur%ROWTYPE, status OUT NOCOPY NUMBER,l_token OUT NOCOPY VARCHAR2) AS
    BEGIN
      status:=1;
      l_token:=NULL;
      IF inq_rec.inquiry_date IS NULL OR inq_rec.inquiry_source_type_id IS NULL OR inq_rec.inquiry_type_id IS NULL THEN
        status:=0;
      END IF;
      IF inq_rec.inquiry_date IS NULL THEN
        l_token:= 'inquiry_date';
      END IF;
      IF inq_rec.inquiry_source_type_id IS NULL THEN
        l_token:= l_token ||', inquiry_source_type_id';
      END IF;
      IF inq_rec.inquiry_type_id IS NULL THEN
        l_token:= l_token ||', p_inquiry_type_id';
      END IF;
    END validate_inq_appl_int;

    PROCEDURE validate_addr_int(inq_per_addr_rec IN inq_per_addr_cur%ROWTYPE, status OUT NOCOPY NUMBER,l_token OUT NOCOPY VARCHAR2) AS
    BEGIN
      status:=1;
      l_token:=NULL;
      IF inq_per_addr_rec.addr_line_1 IS NULL OR inq_per_addr_rec.country IS NULL THEN
        status:=0;
      END IF;
      IF inq_per_addr_rec.addr_line_1 IS NULL THEN
        l_token:='addr_line_1 ';
      END IF;
      IF inq_per_addr_rec.country IS NULL THEN
      l_token:=l_token ||', country';
      END IF;
    END validate_addr_int;

    PROCEDURE validate_addrusage_int(inq_per_addr_rec IN inq_per_addr_cur%ROWTYPE,
                                     status OUT NOCOPY NUMBER,l_token OUT NOCOPY VARCHAR2)  AS
    BEGIN
      status:=1;
      l_token:=NULL;
      IF inq_per_addr_rec.addr_usage IS NULL THEN
        status:=0;
        l_token:='addr_usage';
      END IF;
    END validate_addrusage_int;

    PROCEDURE validate_acadhis_int(inq_per_acad_rec IN inq_per_acad_cur%ROWTYPE, status OUT NOCOPY NUMBER,
                                   l_token OUT NOCOPY VARCHAR2) AS
    BEGIN
      status:=1;
      l_token:=NULL;
      IF inq_per_acad_rec.institution_cd IS NULL OR inq_per_acad_rec.current_inst IS NULL THEN
        status:=0;
      END IF;
      IF inq_per_acad_rec.institution_cd IS NULL THEN
        l_token:='institution_cd ';
      END IF;
      IF inq_per_acad_rec.current_inst IS NULL THEN
        l_token:=l_token ||',current_inst';
      END IF;
    END validate_acadhis_int;

    PROCEDURE validate_excurr_act_int(inq_per_extra_rec IN inq_per_extra_cur%ROWTYPE,
                                        status OUT NOCOPY NUMBER,l_token OUT NOCOPY VARCHAR2) AS
    BEGIN
      status:=1;
      l_token:=NULL;
      IF inq_per_extra_rec.interest_name IS NULL THEN
        status:=0;
        l_token:='interest_name';
      END IF;
    END validate_excurr_act_int;

    PROCEDURE validate_inq_pkg_int(inq_info_rec IN inq_info_cur%ROWTYPE,status OUT NOCOPY NUMBER,l_token OUT NOCOPY VARCHAR2) AS
    BEGIN
      status:=1;
      l_token:=NULL;
      IF inq_info_rec.package_item_id IS NULL THEN
        status:=0;
        l_token:='package_item_id';
      END IF;
    END validate_inq_pkg_int;

    PROCEDURE validate_test_int(inq_per_test_rec IN inq_per_test_cur%ROWTYPE, status OUT NOCOPY NUMBER,l_token OUT NOCOPY VARCHAR2) AS
    BEGIN
      status :=1;
      l_token:=NULL;
      IF inq_per_test_rec.admission_test_type IS NULL OR inq_per_test_rec.test_date IS NULL THEN
        status :=0;
      END IF;
      IF inq_per_test_rec.admission_test_type IS NULL THEN
        l_token:='admission_test_type';
      END IF;
      IF inq_per_test_rec.test_date IS NULL THEN
        l_token:=l_token||', test_date';
      END IF;
    END validate_test_int;

    PROCEDURE validate_test_segs_int(inq_per_testseg_rec IN inq_per_testseg_cur%ROWTYPE,
                                     status OUT NOCOPY NUMBER,l_token OUT NOCOPY VARCHAR2) AS
    BEGIN
      status:=1;
      l_token:=NULL;
      IF inq_per_testseg_rec.test_segment_id IS NULL OR
         inq_per_testseg_rec.test_score IS NULL THEN
        status:=0;
      END IF;
      IF inq_per_testseg_rec.test_segment_id IS NULL THEN
        l_token:=l_token || ', test_segment_id';
      END IF;
      IF inq_per_testseg_rec.test_score IS NULL THEN
        l_token:=l_token ||', test_score';
      END IF;
    END validate_test_segs_int;


--2775931 start

    PROCEDURE validate_race_int(inq_per_race_rec IN inq_per_race_cur%ROWTYPE, status OUT NOCOPY NUMBER,
                                   l_token OUT NOCOPY VARCHAR2) AS
    CURSOR c_get_lookup_code IS
    SELECT lookup_code
    FROM igs_lookup_values
    WHERE lookup_type = 'PE_RACE'
    AND enabled_flag = 'Y';
    BEGIN
      status:=1;
      l_token:=NULL;
      IF inq_per_race_rec.race_cd IS NULL THEN
        status:=0;
      END IF;
      IF inq_per_race_rec.race_cd IS NULL THEN
        l_token:='race_cd ';
      END IF;
      FOR c_get_lookup_code_rec IN c_get_lookup_code LOOP

        IF c_get_lookup_code_rec.lookup_code=inq_per_race_rec.race_cd THEN
     status:=1;
     EXIT;
    ELSE
        status:=2;
        l_token:='race_cd ';
    END IF;
      END LOOP;

    END validate_race_int;

--2775931 end


    /* LOCAL PROCEDURES END */
    ----------------------------------------------------------------------------------------------
  /* Main procedure body */

  BEGIN
     retcode:=0;
    igs_ge_gen_003.set_org_id(null);
    igs_ge_msg_stack.initialize;
     -- Navin.Sinha 30-Jun-03 Bug No: 3023795 If end date is not entered, then default in the end date to be the sysdate.
     IF l_inq_start_date IS NOT NULL AND l_inq_end_date IS NULL THEN
       l_inq_end_date := SYSDATE;
     END IF;

     -- Navin.Sinha 30-Jun-03 Bug No: 3023795  end dates is => start_date
     IF ((l_inq_start_date IS NOT NULL) AND (l_inq_end_date IS NOT NULL) AND (l_inq_start_date <= l_inq_end_date))
       OR ((l_inq_start_date IS NULL) AND (l_inq_end_date IS NULL)) THEN

      /*Entire batch of records processed in this process are given this unique interface id */
        FOR inq_rec IN inq_per_cur LOOP /* The outermost LOOP starts here */
        BEGIN

         IF l_batch_id IS NULL THEN
           /* If the Parameter Start Date is less than End Date then Start processing */
           /*Entire batch of records processed in this process are given this unique batch id */
           OPEN batch_id_cur;
           FETCH batch_id_cur into l_batch_id;
           CLOSE batch_id_cur;
           l_batch_Desc := 'Self Service Inquiry import batch ' || IGS_GE_NUMBER.TO_CANN(l_batch_id);
           fnd_file.put_line(fnd_file.log,'For importing self service inquiry records:');
           fnd_file.put_line(fnd_file.log,'Batch Id : '||IGS_GE_NUMBER.TO_CANN(l_batch_id));
           fnd_file.put_line(fnd_file.log,'Batch description : '||l_batch_desc);
           BEGIN
             INSERT INTO IGS_AD_IMP_BATCH_DET
               ( batch_id,
                 batch_Desc,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date
               )VALUES
               (
                 l_batch_id,
                 l_batch_desc,
                 1,
                 sysdate,
                 1,
                 sysdate,
                 null,
                 fnd_global.conc_request_id,
                 fnd_global.prog_appl_id,
                 fnd_global.conc_program_id,
                 sysdate);
           EXCEPTION WHEN OTHERS THEN
             l_status:=0;
             fnd_file.put_line(fnd_file.log,'Insert on IGS_AD_IMP_BATCH_DET failed '||SQLERRM);
             RAISE;
           END;
         END IF; --End of Batch ID null check

        /* The Interface ID should be unique for each record --rghosh for bug 3365975 */
        OPEN interface_id_cur;
        FETCH interface_id_cur into l_interface_id;
        CLOSE interface_id_cur;

        SAVEPOINT inqsavepoint ;
          completed_flag := 'Y'; /* this flag is set to 'N' when any of the validation fails */
          /* Validate the data in Self Service table for not null before inseting into igs_ad_interface_all */
          validate_interface(inq_rec, l_status,l_batch_id,l_interface_id,l_tokenstr);

          IF l_status = 1 THEN  /* Validation Successful */
      BEGIN
            INSERT INTO igs_ad_interface_all /* Insert valid record into this interface table */
            (
             org_id,
             interface_id,
             batch_id,
             source_type_id,
             surname,
             middle_name,
             given_names,
             preferred_given_name,
             sex,
             birth_dt,
             title,
             suffix,
             pre_name_adjunct,
             level_of_qual,
             proof_of_insurance,
             proof_of_immun,
             pref_alternate_id,
             person_id,
             status,
             military_service_reg,
             veteran,
             match_ind,
             person_match_ind,
             error_code,
             record_status,
             interface_run_id,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             attribute16,
             attribute17,
             attribute18,
             attribute19,
             attribute20,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             person_number
            )
            VALUES
            (
             inq_rec.org_id,
             l_interface_id,
             l_batch_id,
             inq_rec.imp_source_type_id,
             inq_rec.surname,
             inq_rec.middle_name,
             inq_rec.given_name,
             inq_rec.preferred_given_name,
             inq_rec.sex,
             inq_rec.birth_dt,
             inq_rec.title,
             inq_rec.suffix,
             inq_rec.pre_name_adjunct,
             null,
             null,
             null,
             null,
             null,
             '2',
             null,
             null,
             null,
             null,
             null,
             '2',
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             1,
             sysdate,
             1,
             sysdate,
             null,
             fnd_global.conc_request_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_program_id,
             sysdate,
             null
            );
        EXCEPTION WHEN OTHERS THEN
      l_status:=0;
          fnd_file.put_line(fnd_file.log,'Insert on IGS_AD_INTERFACE_ALL failed '||SQLERRM);
      RAISE;
        END;

        BEGIN
            INSERT INTO igs_ad_stat_int
            (
             org_id                  ,
             interface_stat_id       ,
             interface_id            ,
             marital_status          ,
             religion_cd             ,
             person_id               ,
             status                  ,
             match_ind               ,
             error_code              ,
             created_by              ,
             creation_date           ,
             last_updated_by         ,
             last_update_date        ,
             last_update_login       ,
             request_id              ,
             program_application_id  ,
             program_id              ,
             program_update_date     ,
             ethnic_origin           ,
             place_of_birth          ,
             marital_status_effective_date,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             attribute16,
             attribute17,
             attribute18,
             attribute19,
             attribute20
            )VALUES
            (
             inq_rec.org_id          ,
             igs_ad_stat_int_s.nextval,
             l_interface_id          ,
             null                    ,
             null                    ,
             null                    ,
             '2'                     ,
             null                    ,
             null                    ,
             1                       ,
             sysdate                 ,
             1                       ,
             sysdate                 ,
             null                    ,
             fnd_global.conc_request_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_program_id,
             sysdate                 ,
             inq_rec.ethnic_origin   ,
             null                    ,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null
            );
        EXCEPTION WHEN OTHERS THEN
      l_status:=0;
          fnd_file.put_line(fnd_file.log,'Insert on igs_ad_stat_int failed '||SQLERRM);
      RAISE;
        END;

          ELSE  /* l_status = 0 ie Validation failed*/
            fnd_message.set_name('IGS','IGS_AD_SS_TO_INT_NULL_FAIL');
            fnd_message.set_token('TABLE_NAME','igs_ad_interface_all');
            fnd_message.set_token('COL_NAMES',l_tokenstr);
            fnd_message.set_token('ID',inq_rec.inq_person_id);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
        RAISE null_validation_fails;
          END IF;

          /* If atleast one of citizenship1_id and citizenship2_id is not null then Insert */
          IF inq_rec.citizenship1_id IS NOT NULL THEN
          BEGIN
        INSERT INTO igs_pe_citizen_int
            (
             interface_citizenship_id,
             interface_id           ,
             country_code           ,
             document_type          ,
             document_reference     ,
             date_disowned          ,
             date_recognized        ,
             end_date               ,
             match_ind              ,
             status                 ,
             error_code             ,
             dup_citizenship_id     ,
             program_id             ,
             program_application_id ,
             program_update_date    ,
             created_by             ,
             creation_date          ,
             last_updated_by        ,
             last_update_date       ,
             last_update_login      ,
             request_id
            ) VALUES
            (
             igs_ad_citizen_int_s.nextval,
             l_interface_id         ,
             inq_rec.citizenship1_id,
             null                   ,
             null                   ,
             null                   ,
             null                   ,
             null                   ,
             null                   ,
             '2'                    ,
             null                   ,
             null                   ,
             fnd_global.conc_program_id,
             fnd_global.prog_appl_id,
             sysdate,
             1,
             sysdate,
             1,
             sysdate,
             fnd_global.login_id,
             fnd_global.conc_request_id
            );
        EXCEPTION WHEN OTHERS THEN
      l_status:=0;
          fnd_file.put_line(fnd_file.log,'Insert on IGS_PE_CITIZEN_INT failed '||SQLERRM);
      RAISE;
        END;


          END IF;

      IF inq_rec.citizenship2_id IS NOT NULL THEN
          BEGIN
            INSERT INTO igs_pe_citizen_int
            (
             interface_citizenship_id   ,
             interface_id           ,
             country_code           ,
             document_type          ,
             document_reference     ,
             date_disowned          ,
             date_recognized        ,
             end_date               ,
             match_ind              ,
             status                 ,
             error_code             ,
             dup_citizenship_id     ,
             program_id             ,
             program_application_id ,
             program_update_date    ,
             created_by             ,
             creation_date          ,
             last_updated_by        ,
             last_update_date       ,
             last_update_login      ,
             request_id
            ) VALUES
            (
             igs_ad_citizen_int_s.nextval,
             l_interface_id         ,
             inq_rec.citizenship2_id,
             null                   ,
             null                   ,
             null                   ,
             null                   ,
             null                   ,
             null                   ,
             '2'                    ,
             null                   ,
             null                   ,
             fnd_global.conc_program_id,
             fnd_global.prog_appl_id,
             sysdate,
             1,
             sysdate,
             1,
             sysdate,
             fnd_global.login_id,
             fnd_global.conc_request_id
            );
         EXCEPTION WHEN OTHERS THEN
       l_status:=0;
           fnd_file.put_line(fnd_file.log,'Insert on IGS_PE_CITIZEN_INT failed '||SQLERRM);
       RAISE;
         END;


          END IF;

          /* Validate the data in Self Service table for not null before inseting into igs_ad_inq_appl_int */
          validate_inq_appl_int(inq_rec, l_status,l_tokenstr);
          IF l_status = 1 THEN /* Validation Successfull*/
      BEGIN
            INSERT INTO igr_i_appl_int
            (
             interface_inq_appl_id    ,
             interface_id             ,
             enquiry_appl_number      ,
             acad_cal_type            ,
             acad_ci_sequence_number  ,
             adm_cal_type             ,
             adm_ci_sequence_number   ,
             inquiry_status           ,
             inquiry_dt               ,
--             dup_person_id            ,
--             dup_enquiry_appl_number  ,
             inquiry_source_type      ,
             inquiry_type_id  ,
             inquiry_entry_level_id   ,
             registering_person_id    ,
             override_process_ind     ,
             indicated_mailing_dt     ,
             last_process_dt          ,
             comments                 ,
             edu_goal_id              ,
             inquiry_school_of_interest_id,
             learn_source_id          ,
             influence_source_id      ,
             status                   ,
             match_ind                ,
             error_code               ,
             attribute_category       ,
             attribute1               ,
             attribute2               ,
             attribute3               ,
             attribute4               ,
             attribute5               ,
             attribute6               ,
             attribute7               ,
             attribute8               ,
             attribute9               ,
             attribute10              ,
             attribute11              ,
             attribute12              ,
             attribute13              ,
             attribute14              ,
             attribute15              ,
             attribute16              ,
             attribute17              ,
             attribute18              ,
             attribute19              ,
             attribute20              ,
             created_by               ,
             creation_date            ,
             last_updated_by          ,
             last_update_date         ,
             last_update_login        ,
             request_id               ,
             program_application_id   ,
             program_id               ,
             program_update_date,
         source_promotion_id
            )VALUES
            (
             igr_i_appl_int_s.nextval,
             l_interface_id           ,
             null                     ,
             inq_rec.acad_cal_type            ,
             inq_rec.acad_ci_sequence_number  ,
             inq_rec.adm_cal_type             ,
             inq_rec.adm_ci_sequence_number   ,
             'OSS_REGISTERED'           , -- hard coding here as this status is seeded in lookups
             inq_rec.inquiry_date               ,
--             null                     ,
--             null                     ,
             inq_rec.inquiry_source_type_id    ,
             inq_rec.inquiry_type_id  ,
             inq_rec.inq_entry_level_id   ,
             null            ,
             'N'             ,
             null     ,
             null          ,
             inq_rec.comments                 ,
             inq_rec.edu_goal_id              ,
             inq_rec.school_of_interest_id,
             inq_rec.how_knowus_id          ,
             inq_rec.who_influenced_id      ,
             '2'                   ,
             null                     ,
             null                     ,
             inq_rec.attribute_category       ,
             inq_rec.attribute1               ,
             inq_rec.attribute2               ,
             inq_rec.attribute3               ,
             inq_rec.attribute4               ,
             inq_rec.attribute5               ,
             inq_rec.attribute6               ,
             inq_rec.attribute7               ,
             inq_rec.attribute8               ,
             inq_rec.attribute9               ,
             inq_rec.attribute10              ,
             inq_rec.attribute11              ,
             inq_rec.attribute12              ,
             inq_rec.attribute13              ,
             inq_rec.attribute14              ,
             inq_rec.attribute15              ,
             inq_rec.attribute16              ,
             inq_rec.attribute17              ,
             inq_rec.attribute18              ,
             inq_rec.attribute19              ,
             inq_rec.attribute20              ,
             1               ,
             sysdate            ,
             1          ,
             sysdate         ,
             null        ,
             fnd_global.conc_request_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_program_id,
             sysdate,
         inq_rec.source_promotion_id
            );
         EXCEPTION WHEN OTHERS THEN
       l_status:=0;
           fnd_file.put_line(fnd_file.log,'Insert on IGR_I_APPL_INT failed '||SQLERRM);
           RAISE;
         END;
          ELSE /* l_status = 0 i.e Validation failed*/
            fnd_message.set_name('IGS','IGS_AD_SS_TO_INT_NULL_FAIL');
            fnd_message.set_token('TABLE_NAME','igr_i_appl_int');
            fnd_message.set_token('COL_NAMES',l_tokenstr);
            fnd_message.set_token('ID',inq_rec.inq_person_id);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
        RAISE null_validation_fails;
          END IF;

          /* if all the validations are successful so far update the Status of
             Corresponding Self Service Records to Transferred (T) */
          UPDATE igr_is_inquiry SET status = 'T' WHERE inq_person_id = inq_rec.inq_person_id;
          UPDATE igr_is_person SET status = 'T' WHERE inq_person_id = inq_rec.inq_person_id;

          /* Now import the Child tables */
      -- kamohan  21-MAY-2002
      -- Bug 2378114 Add a row for Phone and Email separately
          FOR inq_per_contacts_rec IN inq_per_contacts_cur(inq_rec.inq_person_id) LOOP
             IF inq_per_contacts_rec.phone_number IS NOT NULL THEN
             BEGIN
           INSERT INTO igs_ad_contacts_int
           (
        phone_extension,
        status,
        match_ind,
        error_code,
        dup_contact_point_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
        interface_contacts_id,
        interface_id,
        contact_point_type,
        email_address,
        email_format,
        primary_flag,
        phone_line_type,
        phone_country_code,
        phone_area_code,
        phone_number
           ) VALUES
           (
        inq_per_contacts_rec.phone_extension,
        '2',
        NULL,
        NULL,
        NULL,
        1,
        SYSDATE,
        1,
        SYSDATE,
        NULL,
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        SYSDATE,
        inq_rec.org_id,
        igs_ad_contacts_int_s.nextval,
        l_interface_id,
        'PHONE',
        NULL,
        NULL,
        NULL,
        inq_per_contacts_rec.phone_line_type,
        inq_per_contacts_rec.phone_country_code,
        inq_per_contacts_rec.phone_area_code,
        inq_per_contacts_rec.phone_number
           );
            EXCEPTION WHEN OTHERS THEN
          l_status:=0;
              fnd_file.put_line(fnd_file.log,'Insert on IGS_AD_CONTACTS_INT failed '||SQLERRM);
          RAISE;
            END;

             END IF;
         IF inq_per_contacts_rec.email_address IS NOT NULL THEN
         BEGIN
           INSERT INTO igs_ad_contacts_int
               (
        phone_extension,
        status,
        match_ind,
        error_code,
        dup_contact_point_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
        interface_contacts_id,
        interface_id,
        contact_point_type,
        email_address,
        email_format,
        primary_flag,
        phone_line_type,
        phone_country_code,
        phone_area_code,
        phone_number
           ) VALUES
           (
        NULL,
        '2',
        NULL,
        NULL,
        NULL,
        1,
        SYSDATE,
        1,
        SYSDATE,
        NULL,
        fnd_global.conc_request_id,
        fnd_global.prog_appl_id,
        fnd_global.conc_program_id,
        SYSDATE,
        inq_rec.org_id,
        igs_ad_contacts_int_s.nextval,
        l_interface_id,
        'EMAIL',
        inq_per_contacts_rec.email_address,
        'MAILTEXT', -- kamohan // Bug 2712105
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
           );
             EXCEPTION WHEN OTHERS THEN
           l_status:=0;
               fnd_file.put_line(fnd_file.log,'Insert on IGS_AD_CONTACTS_INT failed '||SQLERRM);
           RAISE;
             END;

         END IF; -- kamohan Bug 2378114 End of Fix

             /* Update the Status of corresponding Self Service record to Transferred */
             UPDATE igr_is_contact SET status = 'T' WHERE inq_person_id = inq_rec.inq_person_id;
          END LOOP;

          FOR inq_per_addr_rec IN inq_per_addr_cur(inq_rec.inq_person_id) LOOP
             /* Validate the data in Self Service table for not null before inseting into igs_ad_addr_int */
             validate_addr_int(inq_per_addr_rec, l_status,l_tokenstr);
             IF l_status = 1 THEN /*Validation Successfull*/
         BEGIN
               INSERT INTO igs_ad_addr_int
               (
                interface_addr_id      ,
                interface_id           ,
                addr_line_1            ,
                org_id                 ,
                addr_line_2            ,
                addr_line_3            ,
                addr_line_4            ,
                postcode               ,
                city                   ,
                state                  ,
                county                 ,
                province               ,
                country                ,
                other_details          ,
                other_details_1        ,
                other_details_2        ,
                delivery_point_code    ,
                other_details_3        ,
                correspondence_flag    ,
                start_date             ,
                end_date               ,
                match_ind              ,
                status                 ,
                error_code             ,
                created_by             ,
                request_id             ,
                program_application_id ,
                program_id             ,
                program_update_date    ,
                contact_person_id      ,
                date_last_verified     ,
                dup_party_site_id      ,
                last_updated_by        ,
                last_update_date       ,
                last_update_login      ,
                creation_date
               ) VALUES
               (
                igs_ad_addr_int_s.nextval,
                l_interface_id           ,
                inq_per_addr_rec.addr_line_1            ,
                inq_rec.org_id                 ,
                inq_per_addr_rec.addr_line_2            ,
                inq_per_addr_rec.addr_line_3            ,
                inq_per_addr_rec.addr_line_4            ,
                inq_per_addr_rec.postcode               ,
                inq_per_addr_rec.city                   ,
                inq_per_addr_rec.state                  ,
                inq_per_addr_rec.county                 ,
                inq_per_addr_rec.province               ,
                inq_per_addr_rec.country                ,
                null                                    ,
                null                                    ,
                null                                    ,
                null                                    ,
                null                                    ,
                null                                    ,
                NVL(inq_per_addr_rec.start_date,SYSDATE),
                inq_per_addr_rec.end_date               ,
                null      ,
                '2'                 ,
                null             ,
                1             ,
                fnd_global.conc_request_id,
                fnd_global.prog_appl_id,
                fnd_global.conc_program_id,
                sysdate,
                null                                    ,
                null                                    ,
                null                                    ,
                1        ,
                sysdate       ,
                null      ,
                sysdate
               );
            EXCEPTION WHEN OTHERS THEN
          l_status:=0;
              fnd_file.put_line(fnd_file.log,'Insert on IGS_AD_ADDR_INT failed '||SQLERRM);
          RAISE;
            END;

             ELSE /* l_status = 0 i.e Validation failed*/
               fnd_message.set_name('IGS','IGS_AD_SS_TO_INT_NULL_FAIL');
               fnd_message.set_token('TABLE_NAME','igs_ad_addr_int');
               fnd_message.set_token('COL_NAMES',l_tokenstr);
               fnd_message.set_token('ID',inq_rec.inq_person_id);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
           RAISE null_validation_fails;
             END IF;

             validate_addrusage_int(inq_per_addr_rec, l_status,l_tokenstr);

         IF l_status = 1 THEN /* Validation Successful */
         BEGIN
               INSERT INTO igs_ad_addrusage_int
               (
                last_update_login      ,
                request_id             ,
                program_application_id ,
                program_id             ,
                program_update_date    ,
                interface_addr_id      ,
                org_id                 ,
                interface_addrusage_id ,
                site_use_code          ,
                comments               ,
                status                 ,
                creation_date          ,
                last_updated_by        ,
                last_update_date       ,
                created_by             ,
                error_code             ,
                match_ind
               ) VALUES
               (
                null      ,
                fnd_global.conc_request_id,
                fnd_global.prog_appl_id,
                fnd_global.conc_program_id,
                sysdate    ,
                igs_ad_addr_int_s.currval,
                inq_rec.org_id                 ,
                igs_ad_addrusage_int_s.nextval,
                inq_per_addr_rec.addr_usage ,
                null             ,
                '2'              ,
                sysdate          ,
                1        ,
                sysdate          ,
                1                ,
                null             ,
                null
               );
            EXCEPTION WHEN OTHERS THEN
          l_status:=0;
              fnd_file.put_line(fnd_file.log,'Insert on IGS_AD_ADDRUSAGE_INT failed '||SQLERRM);
          RAISE;
            END;

               UPDATE igr_is_address SET status = 'T' WHERE inq_person_id = inq_rec.inq_person_id;
             ELSE /* l_status = 0 i.e Validation failed*/
               fnd_message.set_name('IGS','IGS_AD_SS_TO_INT_NULL_FAIL');
               fnd_message.set_token('TABLE_NAME','igs_ad_addrusage_int');
               fnd_message.set_token('COL_NAMES',l_tokenstr);
               fnd_message.set_token('ID',inq_rec.inq_person_id);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
           RAISE null_validation_fails;
             END IF;
          END LOOP;


          FOR inq_per_acad_rec IN inq_per_acad_cur(inq_rec.inq_person_id) LOOP
             /* Validate the data in Self Service table for not null before inseting into igs_ad_acadhis_int */
             validate_acadhis_int(inq_per_acad_rec,l_status,l_tokenstr);
             IF l_status = 1 THEN
         BEGIN
               INSERT INTO igs_ad_acadhis_int
               (
                org_id                         ,
                attribute9                     ,
                attribute10                    ,
                attribute11                    ,
                attribute12                    ,
                attribute13                    ,
                attribute14                    ,
                attribute15                    ,
                attribute16                    ,
                attribute17                    ,
                selfrep_rank_in_class          ,
                selfrep_weighted_gpa           ,
                attribute8                     ,
                attribute18                    ,
                attribute19                    ,
                attribute20                    ,
                match_ind                      ,
                status                         ,
                error_code                     ,
                dup_acad_history_id            ,
                created_by                     ,
                creation_date                  ,
                last_updated_by                ,
                last_update_date               ,
                last_update_login              ,
                request_id                     ,
                program_application_id         ,
                program_id                     ,
                program_update_date            ,
                type_of_school                 ,
                interface_acadhis_id           ,
                interface_id                   ,
                institution_code               ,
                current_inst                   ,
                degree_attempted         ,
                degree_earned            ,
                program_code                   ,
                comments                       ,
                start_date                     ,
                end_date                       ,
                planned_completion_date        ,
                selfrep_total_cp_attempted     ,
                selfrep_total_cp_earned        ,
                selfrep_total_gp_units_attemp,
                selfrep_inst_gpa               ,
                selfrep_grading_scale_id       ,
                attribute6                     ,
                attribute7                     ,
                selfrep_weighted_rank          ,
                attribute_category             ,
                attribute1                     ,
                attribute2                     ,
                attribute3                     ,
                attribute4                     ,
                attribute5                     ,
                class_size
               ) VALUES
               (
                inq_rec.org_id                 ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                inq_per_acad_rec.selfrep_rank_in_class ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                '2'                            ,
                null                           ,
                null                           ,
                1                              ,
                sysdate                        ,
                1                              ,
                sysdate                        ,
                null                           ,
                fnd_global.conc_request_id     ,
                fnd_global.prog_appl_id        ,
                fnd_global.conc_program_id     ,
                sysdate                        ,
                null                           ,
                igs_ad_acadhis_int_s.nextval   ,
                l_interface_id                 ,
                inq_per_acad_rec.institution_cd               ,
                inq_per_acad_rec.current_inst                ,
                null                                         ,
                inq_per_acad_rec.degree_earned         ,
                inq_per_acad_rec.course_major                ,
                null                                         ,
                inq_per_acad_rec.start_date                  ,
                inq_per_acad_rec.end_date                    ,
                inq_per_acad_rec.planned_completion_date     ,
                null                                         ,
                inq_per_acad_rec.selfrep_total_cp_earned     ,
                null                                         ,
                inq_per_acad_rec.selfrep_inst_gpa            ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                inq_per_acad_rec.selfrep_classsize
               );
             EXCEPTION WHEN OTHERS THEN
          l_status:=0;
              fnd_file.put_line(fnd_file.log,'Insert on IGS_AD_ACADHIS_INT failed '||SQLERRM);
          RAISE;
             END;

               UPDATE igr_is_acad SET status = 'T' WHERE inq_person_id = inq_rec.inq_person_id;
             ELSE /* l_status = 0 i.e Validation failed*/
               fnd_message.set_name('IGS','IGS_AD_SS_TO_INT_NULL_FAIL');
               fnd_message.set_token('TABLE_NAME','igs_ad_acadhis_int');
               fnd_message.set_token('COL_NAMES',l_tokenstr);
               fnd_message.set_token('ID',inq_rec.inq_person_id);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
           RAISE null_validation_fails;
             END IF;
          END LOOP;

          FOR inq_per_extra_rec IN inq_per_extra_cur(inq_rec.inq_person_id) LOOP
             /* Validate the data in Self Service table for not null before inseting into igs_ad_excurr_int */
             validate_excurr_act_int(inq_per_extra_rec,l_status,l_tokenstr);
             IF l_status = 1 THEN
           -- nsinha bug 2733230
               l_sub_interest_type_code := NULL;
           IF inq_per_extra_rec.interest_type_code IS NOT NULL THEN
             -- kamohan bug 2722947
             OPEN  inq_sub_interest_type_cur ( inq_per_extra_rec.interest_type_code);
             FETCH inq_sub_interest_type_cur INTO l_sub_interest_type_code;
             CLOSE inq_sub_interest_type_cur;
           END IF;
               BEGIN
               INSERT INTO igs_ad_excurr_int
               (
                sub_interest_type_code         ,
                hours_per_week                 ,
                weeks_per_year                 ,
                interest_name                  ,
                team                           ,
                org_id                         ,
                interface_excurr_id            ,
                interface_id                   ,
                comments                       ,
                start_date                     ,
                end_date                       ,
                match_ind                      ,
                status                         ,
                error_code                     ,
                created_by                     ,
                creation_date                  ,
                last_updated_by                ,
                last_update_date               ,
                last_update_login              ,
                request_id                     ,
                program_application_id         ,
                program_id                     ,
                program_update_date            ,
                interest_type_code             ,
                level_of_interest              ,
                level_of_participation         ,
                dup_person_interest_id         ,
                sport_indicator                ,
                activity_source_cd             ,
                rank
               ) VALUES
               (
                l_sub_interest_type_code,
                null                           ,
                null                           ,
                inq_per_extra_rec.interest_name,
                null                           ,
                inq_rec.org_id                 ,
                igs_ad_excurr_int_s.nextval    ,
                l_interface_id                 ,
                null                           ,
                inq_per_extra_rec.start_date   ,
                inq_per_extra_rec.end_date     ,
                null                           ,
                '2'                            ,
                null                           ,
                1                              ,
                sysdate                        ,
                1                              ,
                sysdate                        ,
                null                           ,
                fnd_global.conc_request_id,
                fnd_global.prog_appl_id,
                fnd_global.conc_program_id,
                sysdate           ,
                inq_per_extra_rec.interest_type_code  ,
                null                           ,
                null                           ,
                null                           ,
                null                           ,
                inq_per_extra_rec.activity_source_cd  ,
                null
               );
             EXCEPTION WHEN OTHERS THEN
           l_status:=0;
               fnd_file.put_line(fnd_file.log,'Insert on IGS_AD_EXCURR_INT failed '||SQLERRM);
           RAISE;
             END;

               UPDATE igr_is_extracurr SET status = 'T' WHERE inq_person_id = inq_rec.inq_person_id;
             ELSE /* l_status = 0 i.e Validation failed*/
               fnd_message.set_name('IGS','IGS_AD_SS_TO_INT_NULL_FAIL');
               fnd_message.set_token('TABLE_NAME','igs_ad_excurr_int');
               fnd_message.set_token('COL_NAMES',l_tokenstr);
               fnd_message.set_token('ID',inq_rec.inq_person_id);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
           RAISE null_validation_fails;
             END IF;
         END LOOP;

         FOR inq_per_test_rec IN inq_per_test_cur(inq_rec.inq_person_id) LOOP
            /* Validate the data in Self Service table for not null before inseting into igs_ad_test_int */
            validate_test_int(inq_per_test_rec , l_status,l_tokenstr);
            IF l_status = 1 THEN /*Validation Successfull*/
        BEGIN
              INSERT INTO igs_ad_test_int
              (
               interface_test_id      ,
               interface_id           ,
               admission_test_type    ,
               registration_number    ,
               test_date              ,
               score_report_date      ,
               edu_level_id           ,
               score_type             ,
               score_source_id        ,
               non_standard_admin     ,
               special_code           ,
               status                 ,
               match_ind              ,
               error_code             ,
               created_by             ,
               creation_date          ,
               last_updated_by        ,
               last_update_date       ,
               last_update_login      ,
               request_id             ,
               program_application_id ,
               program_id             ,
               program_update_date
              ) VALUES
              (
               igs_ad_test_int_s.nextval,
               l_interface_id         ,
               inq_per_test_rec.admission_test_type,
               null                   ,
               inq_per_test_rec.test_date      ,
               null                   ,
               null                   ,
               null                   ,
               inq_per_test_rec.test_source_id,
               null                   ,
               null                   ,
               '2'                    ,
               null                   ,
               null                   ,
               1                      ,
               sysdate                ,
               1                      ,
               sysdate                ,
               null                   ,
               fnd_global.conc_request_id,
               fnd_global.prog_appl_id,
               fnd_global.conc_program_id,
               sysdate
              );
           EXCEPTION WHEN OTHERS THEN
         l_status:=0;
             fnd_file.put_line(fnd_file.log,'Insert on IGS_AD_TEST_INT failed '||SQLERRM);
         RAISE;
           END;

              UPDATE igr_is_test SET status = 'T' WHERE inq_person_id = inq_rec.inq_person_id;
            ELSE /* l_status = 0 i.e Validation failed*/
              fnd_message.set_name('IGS','IGS_AD_SS_TO_INT_NULL_FAIL');
              fnd_message.set_token('TABLE_NAME','igs_ad_test_int');
              fnd_message.set_token('COL_NAMES',l_tokenstr);
              fnd_message.set_token('ID',inq_rec.inq_person_id);
              fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE null_validation_fails;
            END IF;
            /*For each of the record from main cursor process the records in this cursor */
            FOR inq_per_testseg_rec IN INQ_PER_TESTSEG_CUR(inq_per_test_rec.inq_test_id) LOOP
               /* Validate the data in Self Service table for not null before inseting into igs_ad_test_segs_int */
               validate_test_segs_int(inq_per_testseg_rec, l_status,l_tokenstr);
               IF l_status = 1 THEN
               BEGIN
                 INSERT INTO igs_ad_test_segs_int
                 (
                  percentile                     ,
                  national_percentile            ,
                  state_percentile               ,
                  latest_official_percentile     ,
                  percentile_year_rank           ,
                  score_band_upper               ,
                  score_band_lower               ,
                  irregularity_code              ,
                  match_ind                      ,
                  status                         ,
                  error_code                     ,
                  created_by                     ,
                  creation_date                  ,
                  last_updated_by                ,
                  last_update_date               ,
                  last_update_login              ,
                  request_id                     ,
                  program_application_id         ,
                  program_id                     ,
                  program_update_date            ,
                  interface_testsegs_id          ,
                  interface_test_id              ,
                  admission_test_type            ,
                  test_segment_id                ,
                  test_score
                 ) VALUES
                 (
                  null                           ,
                  null                           ,
                  null                           ,
                  null                           ,
                  null                           ,
                  null                           ,
                  null                           ,
                  null                           ,
                  null                           ,
                  '2'                            ,
                  null                           ,
                  1                              ,
                  sysdate                        ,
                  1                              ,
                  sysdate                        ,
                  null                           ,
                  fnd_global.conc_request_id     ,
                  fnd_global.prog_appl_id        ,
                  fnd_global.conc_program_id     ,
                  sysdate                        ,
                  igs_ad_test_segs_int_s.nextval ,
                  igs_ad_test_int_s.currval      ,
                  inq_per_test_rec.admission_test_type,
                  inq_per_testseg_rec.test_segment_id ,
                  inq_per_testseg_rec.test_score
                 );
              EXCEPTION WHEN OTHERS THEN
            l_status:=0;
                fnd_file.put_line(fnd_file.log,'Insert on IGS_AD_TEST_SEGS_INT failed '||SQLERRM);
          RAISE;
              END;

                 /* After Successful Insertion Update the corresponding Self Service table with STATUS as 'T' */
                 UPDATE igr_is_testseg SET status = 'T' WHERE inq_test_id = inq_per_test_rec.inq_test_id;
               ELSE /* l_status = 0 i.e Validation failed*/
                 fnd_message.set_name('IGS','IGS_AD_SS_TO_INT_NULL_FAIL');
                 fnd_message.set_token('TABLE_NAME','igs_ad_test_segs_int');
                 fnd_message.set_token('COL_NAMES',l_tokenstr);
                 fnd_message.set_token('ID',inq_per_test_rec.inq_test_id);
                 fnd_file.put_line(fnd_file.log,fnd_message.get);
         RAISE null_validation_fails;
               END IF;
            END LOOP;  /*  inner FOR LOOP is closed here */
         END LOOP; /* Outer FOR LOOP is closed here */

         FOR inq_info_rec IN inq_info_cur(inq_rec.inq_inq_id) loop
            /* Validate the data in Self Service table for not null before inseting into igs_ad_inq_pkg_int */
            validate_inq_pkg_int(INQ_INFO_rec,l_status,l_tokenstr);
            IF l_status = 1 THEN /*Validation Successfull*/
        BEGIN
              INSERT INTO igr_i_pkg_int
              (
               interface_inq_pkg_id           ,
               interface_inq_appl_id          ,
               package_item_id                ,
               status                         ,
               match_ind                      ,
               error_code                     ,
               created_by                     ,
               creation_date                  ,
               last_updated_by                ,
               last_update_date               ,
               last_update_login              ,
               request_id                     ,
               program_application_id         ,
               program_id                     ,
               program_update_date
              ) VALUES
              (
               igr_i_pkg_int_s.nextval   ,
               igr_i_appl_int_s.currval  ,
               inq_info_rec.package_item_id ,
               '2'                            ,
               null                           ,
               null                           ,
               1                              ,
               sysdate                        ,
               1                              ,
               sysdate                        ,
               null                           ,
               fnd_global.conc_request_id     ,
               fnd_global.prog_appl_id        ,
               fnd_global.conc_program_id     ,
               sysdate
               );
             EXCEPTION WHEN OTHERS THEN
           l_status:=0;
               fnd_file.put_line(fnd_file.log,'Insert on IGR_I_PKG_INT failed '||SQLERRM);
           RAISE;
             END;

              UPDATE igr_is_info_req SET status = 'T' WHERE inq_inq_id = inq_rec.inq_inq_id;
            ELSE /* l_status = 0 i.e Validation failed*/
              fnd_message.set_name('IGS','IGS_AD_SS_TO_INT_NULL_FAIL');
              fnd_message.set_token('TABLE_NAME','igs_ad_inq_pkg_int');
              fnd_message.set_token('COL_NAMES',l_tokenstr);
              fnd_message.set_token('ID',inq_rec.inq_person_id);
              fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE null_validation_fails;
            END IF;
         END LOOP;

     FOR inq_lines_rec IN inq_lines_cur(inq_rec.inq_inq_id) LOOP
            /* No validation required for the data that is comming from SS Table -
               we just need to transfer this data to the interface table */
            BEGIN
          INSERT INTO igr_i_lines_int
              (
           interface_lines_id     ,
               interface_inq_appl_id  ,
               preference             ,
               product_category_id    ,
               product_category_set_id  ,
               status                 ,
               match_ind              ,
               error_code             ,
               created_by             ,
               creation_date          ,
               last_updated_by        ,
               last_update_date       ,
               last_update_login      ,
               request_id             ,
               program_application_id ,
               program_id             ,
               program_update_date
              ) VALUES
              (
               igr_i_lines_int_s.nextval,
               igr_i_appl_int_s.currval,
               inq_lines_rec.preference,
               inq_lines_rec.product_category_id  ,
               inq_lines_rec.product_category_set_id  ,
               '2'                    ,
               null                   ,
               null                   ,
               1                      ,
               sysdate                ,
               1                      ,
               sysdate                ,
               null                   ,
               fnd_global.conc_request_id,
               fnd_global.prog_appl_id,
               fnd_global.conc_program_id,
               sysdate
              );
           EXCEPTION WHEN OTHERS THEN
         l_status:=0;
             fnd_file.put_line(fnd_file.log,'Insert on IGR_I_LINES_INT failed '||SQLERRM);
         RAISE;
           END;

              UPDATE igr_is_i_lines SET status = 'T' WHERE inq_inq_id = inq_rec.inq_inq_id;
          END LOOP;



--2775931 start
          FOR inq_per_race_rec IN inq_per_race_cur(inq_rec.inq_person_id) LOOP
             /* Validate the data in Self Service table igr_is_race for not null before inserting into igs_pe_race_int */
             /* Validate the data in Self Service table igr_is_race, race_cd column for value from lookup before inserting into igs_pe_race_int */
             validate_race_int(inq_per_race_rec,l_status,l_tokenstr);
             IF l_status = 1 THEN
         BEGIN
           INSERT INTO igs_pe_race_int
               (
        interface_race_id,
        interface_id,
        race_cd,
        status,
        match_ind,
        error_code,
        request_id,
        program_id,
        program_application_id,
        program_update_date,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
                ) VALUES
               (
                 igs_pe_race_int_s.nextval   ,
         l_interface_id,
                 inq_per_race_rec.race_cd,
                 '2',
         null,
         null,
         fnd_global.conc_request_id,
         fnd_global.conc_program_id,
         fnd_global.prog_appl_id,
         sysdate,
         1,
         sysdate,
         1,
         sysdate,
         null
               );
            EXCEPTION WHEN OTHERS THEN
          l_status:=0;
              fnd_file.put_line(fnd_file.log,'Insert on IGS_PE_RACE_INT failed '||SQLERRM);
          RAISE;
            END;

           UPDATE igr_is_race SET status = 'T' WHERE person_id = inq_rec.inq_person_id;
             ELSIF l_status = 2 THEN /* l_status = 0 i.e Validation failed due to lookup_code check */
           fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
               fnd_message.set_token('TABLE_NAME','igs_pe_race_int');
               fnd_message.set_token('COL_NAMES',l_tokenstr);
               fnd_message.set_token('ID',inq_rec.inq_person_id);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
           RAISE null_validation_fails;
         ELSE /* l_status = 0 i.e Validation failed due to null check */

           fnd_message.set_name('IGS','IGS_AD_SS_TO_INT_NULL_FAIL');
               fnd_message.set_token('TABLE_NAME','igs_pe_race_int');
               fnd_message.set_token('COL_NAMES',l_tokenstr);
               fnd_message.set_token('ID',inq_rec.inq_person_id);
               fnd_file.put_line(fnd_file.log,fnd_message.get);

           RAISE null_validation_fails;
             END IF;
          END LOOP;

--2775931 end



          IF completed_flag = 'Y' THEN
            /* the records into all the master and child tables inserted successfully */
            COMMIT;
          END IF;
        EXCEPTION  -- of inner loop
          WHEN null_validation_fails THEN
        completed_flag := 'N';    /* validation failed for one of the tables */
            ROLLBACK TO inqsavepoint;
            /* Rollback the insertion of all the records( for the current master record )
               and process the next master record */
          WHEN OTHERS THEN
            ROLLBACK TO inqsavepoint;
        END; -- for inner BEGIN
      END LOOP; /* The outermost LOOP ends here */

      IF l_batch_id IS NULL THEN
        fnd_file.put_line(fnd_file.log,'No Self Service Inquiries are available for import.');
      END IF;

    /* If the Start Date is Greater than End date then Display corresponding message */
    ELSE
      retcode:=2;
      RAISE date_validation_fails;
    END IF;

  EXCEPTION -- main block
    WHEN date_validation_fails THEN
      retcode:=2;
      fnd_message.set_name('IGS','IGS_AD_STDATE_GT_ENDDATE_FAIL');
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log,fnd_message.get);

    WHEN OTHERS THEN
      ROLLBACK;
      retcode:=2;
      ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      Igs_Ge_Msg_Stack.CONC_EXCEPTION_HNDL;

  END trn_ss_inq_int_data;
END IGR_IMP_001; --End of Package

/
