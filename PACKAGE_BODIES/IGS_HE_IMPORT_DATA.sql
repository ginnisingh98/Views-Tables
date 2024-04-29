--------------------------------------------------------
--  DDL for Package Body IGS_HE_IMPORT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_IMPORT_DATA" AS
/* $Header: IGSHE24B.pls 120.2 2006/02/09 17:43:04 jbaber noship $ */

  l_conc_request_id  NUMBER;
  l_org_id  CONSTANT igs_ps_ver.org_id%TYPE := IGS_GE_GEN_003.GET_ORG_ID ;
  l_oss_domicile        igs_he_code_map_val.map2%TYPE ;
  l_oss_ethnicity       igs_he_code_map_val.map2%TYPE ;
  l_oss_nation          igs_he_code_map_val.map2%TYPE ;
  l_oss_occupation      igs_he_code_map_val.map2%TYPE ;
  l_oss_gender          igs_he_code_map_val.map2%TYPE ;
  l_oss_high_qual       igs_he_code_map_val.map2%TYPE ;
  l_oss_subj1           igs_he_code_map_val.map2%TYPE ;
  l_oss_subj2           igs_he_code_map_val.map2%TYPE ;
  l_oss_subj3           igs_he_code_map_val.map2%TYPE ;
  l_oss_proportion      igs_he_code_map_val.map2%TYPE ;
  l_oss_disability      igs_he_code_map_val.map2%TYPE ;
  l_oss_fee_elig        igs_he_code_values.value%TYPE ;
  l_oss_inst            igs_or_org_alt_ids.org_structure_id%TYPE ;
  l_oss_social_class    igs_he_code_map_val.map2%TYPE ;
  l_batch_id            igs_he_ucas_imp_err.batch_id%TYPE ;
  l_error_flag BOOLEAN ;

  -- Get the oss person details
  CURSOR c_pe_det ( cp_person_number igs_pe_person.person_number%TYPE ) IS
  SELECT p.party_id person_id, p.person_last_name surname,
       p.person_first_name given_names,
      pp.gender sex,
      pp.date_of_birth birth_dt
  FROM hz_parties p , hz_person_profiles pp
  WHERE p.party_number = cp_person_number AND
        pp.party_id(+)=p.party_id AND
        SYSDATE BETWEEN NVL(pp.effective_start_date,SYSDATE) AND NVL(pp.effective_end_date,SYSDATE);
  c_pe_det_rec c_pe_det%ROWTYPE ;

  PROCEDURE log_error(p_error_code igs_he_ucas_imp_err.error_code%TYPE  ,
                      p_interface_id igs_he_ucas_imp_err.interface_hesa_id%TYPE,
                      p_append VARCHAR2) IS
    /******************************************************************
     Created By      :   smaddali
     Date Created By :   30-oct-2002
     Purpose         :   To create error records in import interface error table
                      for the passed batch_id and interface_id and error code
     Known limitations,enhancements,remarks:
     Change History
     Who       When       What
    ***************************************************************** */

    l_error_interface_id NUMBER ;
    l_rowid VARCHAR2(50) ;
    l_error_text igs_he_ucas_imp_err.error_text%TYPE ;

    CURSOR c_err_text IS
    SELECT description
    FROM igs_lookups_view
    WHERE lookup_type = 'IGS_HE_IMP_ERR' AND
          lookup_code = p_error_code AND
          closed_ind = 'N' ;

  BEGIN

      -- Get the error text from lookups
      l_error_text := NULL ;
      OPEN c_err_text ;
      FETCH c_err_text INTO l_error_text ;
      CLOSE c_err_text ;

      -- If data needs to be appended to the error text then append at the end
      IF p_append IS NOT NULL THEN
         l_error_text := l_error_text || ' ' || p_append ;
      END IF ;

      l_rowid := NULL ;
      l_error_interface_id := NULL ;
      igs_he_ucas_imp_err_pkg.insert_row ( X_ROWID => l_rowid ,
                 X_ERROR_INTERFACE_ID => l_error_interface_id ,
                 X_INTERFACE_HESA_ID => p_interface_id ,
                 X_BATCH_ID => l_batch_id ,
                 X_ERROR_CODE => p_error_code ,
                 X_ERROR_TEXT => l_error_text ,
                 X_MODE => 'R' ) ;

  EXCEPTION

    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_HE_IMPORT_DATA.LOG_ERROR'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.LOG,fnd_message.get());
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END log_error ;

  FUNCTION deleted_alt_id_exists(p_person_id igs_pe_alt_pers_id.pe_person_id%TYPE,
                                 p_alt_pers_id igs_pe_alt_pers_id.api_person_id%TYPE,
                                 p_alt_person_type igs_pe_alt_pers_id.person_id_type%TYPE,
                                 p_start_dt igs_pe_alt_pers_id.start_dt%TYPE) RETURN BOOLEAN AS

        /******************************************************************
        Created By      :   sjlaport
        Date Created By :   07-February-2005
        Purpose         :   Determines if a logically deleted Alternate Id
                            record exists with the value and start date.

        Known limitations,enhancements,remarks:
        Change History
        Who          When        What
        ***************************************************************** */


        CURSOR c_pe_alt_pers_del IS
        SELECT  *
        FROM igs_pe_alt_pers_id
        WHERE pe_person_id = p_person_id
        AND person_id_type= p_alt_person_type
        AND api_person_id = p_alt_pers_id
        AND TRUNC(start_dt) = TRUNC(p_start_dt);

        c_pe_alt_pers_del_rec   c_pe_alt_pers_del%ROWTYPE;

        l_row_found BOOLEAN;


        BEGIN

          l_row_found := FALSE;

          OPEN c_pe_alt_pers_del;
          FETCH c_pe_alt_pers_del INTO c_pe_alt_pers_del_rec;

          l_row_found := c_pe_alt_pers_del%FOUND;

          CLOSE c_pe_alt_pers_del;

          RETURN l_row_found;

       EXCEPTION
       WHEN OTHERS THEN

       IF c_pe_alt_pers_del%ISOPEN THEN
          CLOSE c_pe_alt_pers_del;
       END IF ;

       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGS_HE_IMPORT_DATA.DELETED_ALT_ID_EXISTS'||' - '||SQLERRM);
       fnd_file.put_line(fnd_file.LOG,fnd_message.get());
       IGS_GE_MSG_STACK.ADD;

       App_Exception.Raise_Exception;


  END deleted_alt_id_exists;


  PROCEDURE import_alternate_person_id(p_interface_hesa_id igs_he_ucas_imp_int.interface_hesa_id%TYPE,
                           p_interface_id NUMBER,
                           p_status VARCHAR,
                           p_orgid NUMBER,
                           p_person_id igs_pe_alt_pers_id.pe_person_id%TYPE,
                           p_alt_pers_id igs_pe_alt_pers_id.api_person_id%TYPE,
                           p_alt_person_type igs_pe_alt_pers_id.person_id_type%TYPE) AS

        /******************************************************************
        Created By      :   sjlaport
        Date Created By :   24-September-2004
        Purpose         :   Import alternate person id based on alternate person
                            type

        Known limitations,enhancements,remarks:
        Change History
        Who          When        What
        sjlaport     31-Jan-05   Modified parameter type and cursor c_pe_alt_pers
                                 for HE358 to ignore logically deleted records. Included
                                 call to new function to check for logically deleted records.
        ***************************************************************** */

        l_interface_api_id        NUMBER ;
        l_created_by              CONSTANT NUMBER := FND_GLOBAL.USER_ID;
        l_last_updated_by         CONSTANT NUMBER := FND_GLOBAL.LOGIN_ID;
        l_api_start_dt            igs_ad_api_int.start_dt%TYPE;
        l_insert_record           BOOLEAN;

        -- sjlaport HEFD350 Process 4
        -- Select the latest alternate person id details for the specified person
        CURSOR c_pe_alt_pers(cp_person_id_type igs_pe_alt_pers_id.person_id_type%TYPE) IS
        SELECT  *
        FROM igs_pe_alt_pers_id
        WHERE pe_person_id = p_person_id
        AND person_id_type= cp_person_id_type
        AND (end_dt IS NULL OR start_dt <> end_dt)
        ORDER BY start_dt DESC;

        c_pe_alt_pers_rec   c_pe_alt_pers%ROWTYPE;

        BEGIN

            l_insert_record := FALSE;

            -- Check if the person already has this alternate person id record with this person id type
            OPEN c_pe_alt_pers(p_alt_person_type);
            FETCH c_pe_alt_pers INTO c_pe_alt_pers_rec;

            IF c_pe_alt_pers%NOTFOUND THEN

                 CLOSE c_pe_alt_pers;

                 IF deleted_alt_id_exists(p_person_id, p_alt_pers_id, p_alt_person_type, TRUNC(SYSDATE)) THEN
                     log_error('E39', p_interface_hesa_id, p_alt_person_type || ' ' || p_alt_pers_id);
                 ELSE

                     -- No records exist with for person being imported
                     -- so create this id directly
                     INSERT INTO igs_ad_api_int(status,
                                                org_id,
                                                person_id_type,
                                                alternate_id,
                                                start_dt,
                                                end_dt,
                                                interface_api_id,
                                                interface_id,
                                                created_by,
                                                creation_date,
                                                last_updated_by,
                                                last_update_date)
                                        VALUES (p_status,
                                                p_orgid,
                                                p_alt_person_type,
                                                p_alt_pers_id,
                                                TRUNC(SYSDATE),
                                                NULL,
                                                igs_ad_api_int_s.NEXTVAL,
                                                p_interface_id,
                                                l_created_by,
                                                SYSDATE,
                                                l_last_updated_by,
                                                SYSDATE ) RETURNING interface_api_id INTO l_interface_api_id;

                 END IF;

            ELSE

                CLOSE c_pe_alt_pers;

                -- An existing record was found. Determine if the
                -- latest record matches the id that we are importing
                IF c_pe_alt_pers_rec.api_person_id <> p_alt_pers_id THEN


                    IF  Trunc(c_pe_alt_pers_rec.start_dt) >= Trunc(SYSDATE) THEN

                        -- Unable to create alternate person id record
                        -- because future dated records exists with a different for this person id type
                        log_error('E37', p_interface_hesa_id, p_alt_person_type || ' ' || p_alt_pers_id);

                    ELSE

                        -- If all the other api records had started before sysdate then set
                        -- the last started record's end date to sysdate - 1 and create  the new api
                        -- record starting from sysdate
                        IF NVL(Trunc(c_pe_alt_pers_rec.end_dt), Trunc(SYSDATE)) >= Trunc(SYSDATE) THEN


                            IF p_alt_person_type <> 'HUSID' THEN

                                -- Log error as active id already exists for this
                                -- record with a different id
                               log_error('E38', p_interface_hesa_id, p_alt_person_type || ' ' || p_alt_pers_id);

                            ELSE

                                IF deleted_alt_id_exists(p_person_id, p_alt_pers_id, p_alt_person_type, TRUNC(SYSDATE)) THEN
                                    log_error('E39', p_interface_hesa_id, p_alt_person_type || ' ' || p_alt_pers_id);
                                ELSE

                                    -- Close existing record
                                    INSERT INTO igs_ad_api_int(status,
                                                               org_id,
                                                               person_id_type,
                                                               alternate_id,
                                                               start_dt,
                                                               end_dt,
                                                               interface_api_id,
                                                               interface_id,
                                                               created_by,
                                                               creation_date,
                                                               last_updated_by,
                                                               last_update_date)
                                                       VALUES (p_status,
                                                               p_orgid,
                                                               p_alt_person_type,
                                                               c_pe_alt_pers_rec.api_person_id,
                                                               NVL(c_pe_alt_pers_rec.start_dt , Trunc(SYSDATE - 1) ),
                                                               Trunc(SYSDATE - 1),
                                                               igs_ad_api_int_s.NEXTVAL,
                                                               p_interface_id,
                                                               l_created_by,
                                                               SYSDATE,
                                                               l_last_updated_by,
                                                               SYSDATE ) RETURNING interface_api_id INTO l_interface_api_id;


                                    -- Flag the insert of the new imported record
                                    l_insert_record := TRUE;

                                END IF;

                            END IF;

                        ELSE

                            IF deleted_alt_id_exists(p_person_id, p_alt_pers_id, p_alt_person_type, TRUNC(SYSDATE)) THEN
                                log_error('E39', p_interface_hesa_id, p_alt_person_type || ' ' || p_alt_pers_id);
                            ELSE

                                -- A new record can be inserted for all alternate person id types
                                -- if End Date < SYSDATE
                                l_insert_record := TRUE;

                            END IF;


                       END IF;


                        IF l_insert_record THEN

                            -- Create a new record based on the interface record
                            -- starting from SYSDATE
                            INSERT INTO igs_ad_api_int(status,
                                                       org_id,
                                                       person_id_type,
                                                       alternate_id,
                                                       start_dt,
                                                       end_dt,
                                                       interface_api_id,
                                                       interface_id,
                                                       created_by,
                                                       creation_date,
                                                       last_updated_by,
                                                       last_update_date)
                                               VALUES (p_status,
                                                       p_orgid,
                                                       p_alt_person_type,
                                                       p_alt_pers_id,
                                                       TRUNC(SYSDATE),
                                                       NULL,
                                                       igs_ad_api_int_s.NEXTVAL,
                                                       p_interface_id,
                                                       l_created_by,
                                                       SYSDATE,
                                                       l_last_updated_by,
                                                       SYSDATE ) RETURNING interface_api_id INTO l_interface_api_id;

                        END IF;

                    END IF;

                ELSE  -- Matching id found

                    IF  TRUNC(c_pe_alt_pers_rec.start_dt) >= TRUNC(SYSDATE) THEN

                        -- Issue warning as future dated record already
                        -- exists will the same id
                        fnd_message.set_name('IGS','IGS_HE_ALT_FUTURE_REC_EXISTS');
                        fnd_message.set_token('ALT_PERS_TYPE',p_alt_person_type);
                        fnd_message.set_token('ALT_PERS_ID',p_alt_pers_id);
                        fnd_file.put_line(fnd_file.LOG,fnd_message.get());

                    ELSIF TRUNC(c_pe_alt_pers_rec.end_dt) >= TRUNC(SYSDATE) THEN

                        IF p_alt_person_type <> 'HUSID' THEN

                            -- Issue warning that we are unable to create alternate person id record
                            -- because future dated record exists with the same id
                            fnd_message.set_name('IGS','IGS_HE_ALT_ACTIVE_REC_EXISTS');
                            fnd_message.set_token('ALT_PERS_TYPE',p_alt_person_type);
                            fnd_message.set_token('ALT_PERS_ID',p_alt_pers_id);
                            fnd_file.put_line(fnd_file.LOG,fnd_message.get());

                        ELSE

                            -- Create the record starting from the previous records end date
                            l_api_start_dt := TRUNC(c_pe_alt_pers_rec.end_dt + 1);


                            IF deleted_alt_id_exists(p_person_id, p_alt_pers_id, p_alt_person_type, l_api_start_dt) THEN
                                log_error('E39', p_interface_hesa_id, p_alt_person_type || ' ' || p_alt_pers_id);
                            ELSE

                                l_insert_record := TRUE;

                                -- Issue warning that future dated record will be created
                                fnd_message.set_name('IGS','IGS_HE_ALT_FUTURE_REC_CREATED');
                                fnd_message.set_token('ALT_PERS_TYPE',p_alt_person_type);
                                fnd_message.set_token('ALT_PERS_ID',p_alt_pers_id);
                                fnd_file.put_line(fnd_file.LOG,fnd_message.get());

                            END IF;

                        END IF;  -- Alternate id type is not HUSID

                    ELSIF TRUNC(c_pe_alt_pers_rec.end_dt) IS NOT NULL THEN


                        IF deleted_alt_id_exists(p_person_id, p_alt_pers_id, p_alt_person_type, TRUNC(SYSDATE)) THEN
                            log_error('E39', p_interface_hesa_id, p_alt_person_type || ' ' || p_alt_pers_id);
                        ELSE

                            -- End date < SYSDATE
                            -- Create record from SYSDATE
                            l_api_start_dt := TRUNC(SYSDATE);

                            l_insert_record := TRUE;

                        END IF;

                    END IF; -- End date >= SYSDATE

                    IF l_insert_record THEN

                        -- Create record from specified start date
                        INSERT INTO igs_ad_api_int(status,
                                                   org_id,
                                                   person_id_type,
                                                   alternate_id,
                                                   start_dt,
                                                   end_dt,
                                                   interface_api_id,
                                                   interface_id,
                                                   created_by,
                                                   creation_date,
                                                   last_updated_by,
                                                   last_update_date)
                                           VALUES (p_status,
                                                   p_orgid,
                                                   p_alt_person_type,
                                                   p_alt_pers_id,
                                                   l_api_start_dt,
                                                   NULL,
                                                   igs_ad_api_int_s.NEXTVAL,
                                                   p_interface_id,
                                                   l_created_by,
                                                   SYSDATE,
                                                   l_last_updated_by,
                                                   SYSDATE ) RETURNING interface_api_id INTO l_interface_api_id;

                    END IF; -- Insert record

                END IF; -- Existing non-matching record found

             END IF; -- No record found

             EXCEPTION
             WHEN OTHERS THEN

             IF c_pe_alt_pers%ISOPEN THEN
                CLOSE c_pe_alt_pers;
             END IF ;

             fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
             fnd_message.set_token('NAME','IGS_HE_IMPORT_DATA.IMPORT_ALTERNATE_PERSON_ID'||' - '||SQLERRM);
             fnd_file.put_line(fnd_file.LOG,fnd_message.get());
             IGS_GE_MSG_STACK.ADD;

             App_Exception.Raise_Exception;

  END import_alternate_person_id;

  PROCEDURE populate_imp_int (
                      p_source_type_id igs_pe_src_types_all.source_type_id%TYPE,
                      p_batch_id NUMBER, -- admission import batch id
                      p_orgid NUMBER ,
                      p_person_id igs_pe_person.person_id%TYPE ,
                      p_hesa_id igs_he_ucas_imp_int.interface_hesa_id%TYPE) AS
    /******************************************************************
     Created By      :   smaddali
     Date Created By :   29-oct-2002
     Purpose         :   To populate import person details interface tables
                       for the passed person
     Known limitations,enhancements,remarks:
     Change History
     Who     When       What

     uudayapr 25-Nov-2003  Removed the Trim Statement from the Cursor c_interface for Birth_dt as a part of bug#3175113 fix
     smaddali 17-dec-2002 giving NVL(sysdate) for start_date of disability,citizen and
     alternate person id record for bug 2715487
     smaddali 31-dec-2002 modified this procedure to import disaibility type, bug 2730129
     smaddali 9-jan-03 modified cursor c_interface to trim fields being selected to remove spaces  , bug 2740653
     ayedubat 09-OCT-03 Removed the cursor,c_pe_stat and put an additional validation
                        to populate the admission statistics interface table only
                        if the ethnic origin is provided in the interface table for Bug# 3175020
     ayedubat 14-OCT-03 Changed the Logic for populating the altenate person id interface table
                        if the student has an Alternate Person ID record with the same TYPE and ID
                        and that is the latest record for Bug# 2762866
     sjlaport 07-Dec-04 Added call to method import_alternate_person_id and removed cursors that were
                        were no longer used
    ***************************************************************** */

    l_status              VARCHAR2(2);
    l_record_status       VARCHAR2(1);
    l_created_by              CONSTANT NUMBER := FND_GLOBAL.USER_ID;
    l_last_updated_by         CONSTANT NUMBER := FND_GLOBAL.LOGIN_ID;
    l_request_id              CONSTANT NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_program_application_id  CONSTANT NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_program_id              CONSTANT NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_interface_id            NUMBER ;
    l_interface_stat_id       NUMBER ;
    l_interface_api_id       NUMBER ;
    l_interface_disablty_id        NUMBER ;
    l_interface_citizenship_id       NUMBER ;

    -- Get all the interface records for the passed batch id
    -- smaddali 9-jan-03 modified this cursor for bug 2740653 , trimming interface record fields to remove spaces
    CURSOR c_interface IS
    SELECT trim(a.interface_hesa_id) interface_hesa_id , trim(a.batch_id) batch_id,
        upper(trim(a.husid)) husid , trim(a.person_number) person_number,
        upper(trim(a.ucasnum)) ucasnum, upper(trim(a.scotvec)) scotvec, trim(a.surname) surname,
        trim(a.given_names) given_names , (a.birth_dt) birth_dt,
        trim(a.country_code) country_code, trim(a.disability_type) disability_type
    FROM igs_he_ucas_imp_int  a
    WHERE a.batch_id = l_batch_id AND
        interface_hesa_id = p_hesa_id ;
    c_interface_rec c_interface%ROWTYPE ;

    -- Get the latest citizenship record for the person and interface country code
    CURSOR c_pe_nat IS
    SELECT *
    FROM hz_citizenship
    WHERE party_id = p_person_id AND
          country_code = l_oss_nation
    ORDER BY date_recognized DESC ;
    c_pe_nat_rec c_pe_nat%ROWTYPE ;

    -- Get all the citizenship records for the person of a different country than
    -- the interface country code , and close them
    CURSOR c_other_nat IS
    SELECT *
    FROM hz_citizenship
    WHERE party_id = p_person_id AND
          country_code <> l_oss_nation
    ORDER BY country_code DESC ;

    -- check if the person has a record for the interface disability type which is not ended
    -- smaddali modified this cursor to check that end_date is null and
    -- start date could be null or not equal to sysdate, bug 2730129
    CURSOR c_pe_dis IS
    SELECT  dis.rowid,dis.*
    FROM igs_pe_pers_disablty dis
    WHERE person_id = p_person_id AND
          disability_type = l_oss_disability AND
          end_date IS NULL
    ORDER BY start_date DESC ;
    c_pe_dis_rec c_pe_dis%ROWTYPE ;

    -- Get all the disability records for the person to be closed
    -- smaddali modified this cursor to exclude current disability type , bug 2730129
    CURSOR c_other_dis IS
    SELECT  dis.*
    FROM igs_pe_pers_disablty dis
    WHERE person_id = p_person_id
        AND disability_type <> l_oss_disability
        AND start_date IS NOT NULL
    ORDER BY dis.disability_type DESC ;

    -- smaddali added this cursor for bug 2730129
    -- check if there are any disability records of the passed type which are starting on  sysdate
    CURSOR c_pe_dis_sysdate IS
    SELECT  dis.*
    FROM igs_pe_pers_disablty dis
    WHERE person_id = p_person_id AND
          disability_type = l_oss_disability AND
          Trunc(start_date) = Trunc(SYSDATE)
    ORDER BY start_date DESC ;
    c_pe_dis_sysdate_rec c_pe_dis_sysdate%ROWTYPE ;

  BEGIN
        l_status := '2' ;
        l_record_status := '2';

/* *************** importing person details ***************** */

        -- Get the hesa interface record details
        OPEN c_interface ;
        FETCH c_interface INTO c_interface_rec ;
        CLOSE c_interface ;

        -- Create an interface record for this person
        -- Since this person already exists in oss and the person identifier is known , matching can be skipped
        -- and directly the person record can be updated ,hence match_ind is set to 15
        INSERT INTO igs_ad_interface(person_number,
                                     interface_id,
                                     batch_id,
                                     org_id,
                                     source_type_id,
                                     person_id,
                                     surname,
                                     given_names,
                                     sex,
                                     birth_dt,
                                     status,
                                     record_status,
                                     match_ind,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     request_id,
                                     program_application_id,
                                     program_id,
                                     program_update_date )
        VALUES(c_interface_rec.person_number,
               igs_ad_interface_s.NEXTVAL,
               p_batch_id,
               p_orgid,
               p_source_type_id,
               c_pe_det_rec.person_id,
               NVL(c_interface_rec.surname,c_pe_det_rec.surname),
               NVL(c_interface_rec.given_names,c_pe_det_rec.given_names),
               NVL(l_oss_gender,c_pe_det_rec.sex),
               NVL(c_interface_rec.birth_dt,c_pe_det_rec.birth_dt),
               l_status,
               l_record_status,
               '15',
               l_created_by,
               SYSDATE,
               l_last_updated_by,
               SYSDATE,
               l_request_id,
               l_program_application_id,
               l_program_id,
               SYSDATE ) RETURNING interface_id INTO  l_interface_id;

        -- Populate the person Statistics interface table with the ethnic origin, if provided
        -- If interface record does not have ethnic origin then statistic record need not be required to populate
        -- modified this as part of the bug, 3175020
        -- Get the person statistical details

        IF l_oss_ethnicity IS NOT NULL THEN

          l_interface_stat_id := NULL;
          INSERT INTO igs_ad_stat_int(interface_stat_id,
                                      interface_id,
                                      status,
                                      org_id,
                                      ethnic_origin,
                                      created_by,
                                      creation_date,
                                      last_updated_by,
                                      last_update_date)
          VALUES (igs_ad_stat_int_s.NEXTVAL,
                  l_interface_id,
                  l_status,
                  p_orgid,
                  l_oss_ethnicity,
                  l_created_by,
                  SYSDATE,
                  l_last_updated_by,
                  SYSDATE) RETURNING interface_stat_id INTO l_interface_stat_id;
        END IF;

/* *************** end of importing person details ***************** */


/* *************** importing person disability details ***************** */

        -- If disability type is given in interface recprd then Import person disability type into oss
        IF c_interface_rec.disability_type IS NOT NULL THEN
            -- Firstly Close all the existing disability records for this person
            FOR c_other_dis_rec IN c_other_dis LOOP
                -- Close the disability record by end dating it
                INSERT INTO igs_ad_disablty_int(interface_disablty_id,
                                            interface_id,
                                            status,
                                            disability_type,
                                            start_date,
                                            end_date,
                                            created_by,
                                            creation_date,
                                            last_updated_by,
                                            last_update_date)
                VALUES (igs_ad_disablty_int_s.NEXTVAL ,
                        l_interface_id,
                        l_status,
                        c_other_dis_rec.disability_type,
                        NVL(c_other_dis_rec.start_date,TRUNC(SYSDATE)),
                        TRUNC(SYSDATE),
                        l_created_by,
                        SYSDATE,
                        l_last_updated_by,
                        SYSDATE) RETURNING interface_disablty_id INTO l_interface_disablty_id ;
            END LOOP ;

            -- Check if already person has any records of this disability type which are not ended .
            -- If not then create a new record
            -- smaddali removed code making end_date null for existing records , bug 2730129
            OPEN c_pe_dis ;
            FETCH c_pe_dis INTO c_pe_dis_rec;
            IF c_pe_dis%NOTFOUND THEN
                CLOSE c_pe_dis;
                -- create a new disability record if already some other record did not start on sysdate
                OPEN c_pe_dis_sysdate ;
                FETCH c_pe_dis_sysdate INTO c_pe_dis_sysdate_rec;
                IF c_pe_dis_sysdate%NOTFOUND THEN
                                INSERT INTO igs_ad_disablty_int(interface_disablty_id,
                                            interface_id,
                                            status,
                                            disability_type,
                                            start_date,
                                            end_date,
                                            created_by,
                                            creation_date,
                                            last_updated_by,
                                            last_update_date)
                                VALUES (igs_ad_disablty_int_s.NEXTVAL ,
                                        l_interface_id,
                                        l_status,
                                        l_oss_disability,
                                        TRUNC(SYSDATE),
                                        NULL,
                                        l_created_by,
                                        SYSDATE,
                                        l_last_updated_by,
                                        SYSDATE) RETURNING interface_disablty_id INTO l_interface_disablty_id ;
                ELSE
                   -- If already this disability record exists which started on sysdate and ended some date ,
                   -- we need to update that records end date to null so that it will be active
                                INSERT INTO igs_ad_disablty_int(interface_disablty_id,
                                            interface_id,
                                            status,
                                            disability_type,
                                            start_date,
                                            end_date,
                                            created_by,
                                            creation_date,
                                            last_updated_by,
                                            last_update_date)
                                VALUES (igs_ad_disablty_int_s.NEXTVAL ,
                                        l_interface_id,
                                        l_status,
                                        c_pe_dis_sysdate_rec.disability_type,
                                        NVL(c_pe_dis_sysdate_rec.start_date, Trunc(SYSDATE)),
                                        NULL,
                                        l_created_by,
                                        SYSDATE,
                                        l_last_updated_by,
                                        SYSDATE) RETURNING interface_disablty_id INTO l_interface_disablty_id ;
                END IF ;
                CLOSE c_pe_dis_sysdate;


            ELSE
               CLOSE c_pe_dis;
               -- The person has same disability type records which are open
               IF c_pe_dis_rec.start_date IS NULL THEN
                  -- If this disability record already exists with an open end date and start_date as nul then
                  -- make its start date as sysdate if there there is not one more disability record of this type which has started on sysdate
                  OPEN c_pe_dis_sysdate ;
                  FETCH c_pe_dis_sysdate INTO c_pe_dis_sysdate_rec;
                  IF c_pe_dis_sysdate%NOTFOUND THEN
                         CLOSE c_pe_dis_sysdate;
                         BEGIN
                                IGS_PE_PERS_DISABLTY_PKG.UPDATE_ROW (
                                      X_ROWID => c_pe_dis_rec.rowid,
                                      X_IGS_PE_PERS_DISABLTY_ID   => c_pe_dis_rec.igs_pe_pers_disablty_id,
                                       x_PERSON_ID => c_pe_dis_rec.person_id,
                                       x_DISABILITY_TYPE => c_pe_dis_rec.disability_type,
                                       x_CONTACT_IND => c_pe_dis_rec.contact_ind ,
                                       x_SPECIAL_ALLOW_CD => c_pe_dis_rec.special_allow_cd,
                                       x_SUPPORT_LEVEL_CD => c_pe_dis_rec.support_level_cd ,
                                       x_DOCUMENTED => c_pe_dis_rec.documented ,
                                       x_SPECIAL_SERVICE_ID => c_pe_dis_rec.special_service_id ,
                                       x_ATTRIBUTE_CATEGORY => c_pe_dis_rec.attribute_category ,
                                       x_ATTRIBUTE1 => c_pe_dis_rec.attribute1,
                                       x_ATTRIBUTE2 => c_pe_dis_rec.attribute2,
                                       x_ATTRIBUTE3 => c_pe_dis_rec.attribute3,
                                       x_ATTRIBUTE4 => c_pe_dis_rec.attribute4,
                                       x_ATTRIBUTE5 => c_pe_dis_rec.attribute5,
                                       x_ATTRIBUTE6 => c_pe_dis_rec.attribute6,
                                       x_ATTRIBUTE7 => c_pe_dis_rec.attribute7,
                                       x_ATTRIBUTE8 => c_pe_dis_rec.attribute8,
                                       x_ATTRIBUTE9 => c_pe_dis_rec.attribute9,
                                       x_ATTRIBUTE10 =>  c_pe_dis_rec.attribute10,
                                       x_ATTRIBUTE11 => c_pe_dis_rec.attribute11,
                                       x_ATTRIBUTE12 => c_pe_dis_rec.attribute12,
                                        x_ATTRIBUTE13 => c_pe_dis_rec.attribute13,
                                       x_ATTRIBUTE14 => c_pe_dis_rec.attribute14,
                                       x_ATTRIBUTE15 => c_pe_dis_rec.attribute15,
                                       x_ATTRIBUTE16 => c_pe_dis_rec.attribute16,
                                       x_ATTRIBUTE17 => c_pe_dis_rec.attribute17,
                                       x_ATTRIBUTE18 => c_pe_dis_rec.attribute18,
                                       x_ATTRIBUTE19 => c_pe_dis_rec.attribute19,
                                       x_ATTRIBUTE20 => c_pe_dis_rec.attribute20,
                                       X_ELIG_EARLY_REG_IND    => c_pe_dis_rec.elig_early_reg_ind,
                                       X_START_DATE              => TRUNC(SYSDATE),
                                       X_END_DATE              => NULL,
                                       X_INFO_SOURCE            => c_pe_dis_rec.info_source,
                                       X_INTERVIEWER_ID         => c_pe_dis_rec.interviewer_id,
                                       X_INTERVIEWER_DATE       => c_pe_dis_rec.interviewer_date,
                                      X_MODE => 'R'
                                  );
                         EXCEPTION
                            WHEN OTHERS THEN
                                 -- log error message that update of disability records start date from null to
                                 -- sysdate failed due to unhandled exception raised by the tbh
                                 log_error('E34' ,c_interface_rec.interface_hesa_id, SQLERRM);
                         END  ;
                  ELSE
                       -- already this disability type record starting on sysdate exists for this person ,
                       -- so cannot create one more
                       CLOSE c_pe_dis_sysdate;
                       -- If already this disability record exists which started on sysdate and ended some date ,
                       -- we need to update that records end date to null so that it will be active
                       INSERT INTO igs_ad_disablty_int(interface_disablty_id,
                                            interface_id,
                                            status,
                                            disability_type,
                                            start_date,
                                            end_date,
                                            created_by,
                                            creation_date,
                                            last_updated_by,
                                            last_update_date)
                                VALUES (igs_ad_disablty_int_s.NEXTVAL ,
                                        l_interface_id,
                                        l_status,
                                        c_pe_dis_sysdate_rec.disability_type,
                                        c_pe_dis_sysdate_rec.start_date,
                                        NULL,
                                        l_created_by,
                                        SYSDATE,
                                        l_last_updated_by,
                                        SYSDATE) RETURNING interface_disablty_id INTO l_interface_disablty_id ;
                  END IF ;

               END IF ; -- if existing record's start date is null then make it sysdate

            END IF ; -- if open disability record doesnot exist
        END IF ; -- import disability type

/* *************** end of importing person disability details ***************** */


/* *************** importing person citizenship details ***************** */

        -- If country  code is given in the interface record then import person nationality to oss
        IF c_interface_rec.country_code IS NOT NULL THEN
            -- Firstly Close all the existing citizenship records for this person
            FOR c_other_nat_rec IN c_other_nat LOOP
                -- Close the citizenship record by end dating it
                INSERT INTO igs_pe_citizen_int(interface_citizenship_id,
                                                    interface_id,
                                                    status,
                                                    country_code,
                                                    date_recognized,
                                                    date_disowned,
                                                    end_date,
                                                    created_by,
                                                    creation_date,
                                                    last_updated_by,
                                                    last_update_date)
                VALUES (igs_pe_citizen_int_s.NEXTVAL,
                                l_interface_id,
                                l_status,
                                c_other_nat_rec.country_code,
                                NVL(c_other_nat_rec.date_recognized,TRUNC(SYSDATE)) ,
                                NULL,
                                TRUNC(SYSDATE),
                                l_created_by,
                                SYSDATE,
                                l_last_updated_by,
                                SYSDATE) RETURNING interface_citizenship_id INTO l_interface_citizenship_id;
            END LOOP ;

            -- Check if the person already has a citizenship record for this country
            -- If no then create a new record
            OPEN c_pe_nat ;
            FETCH c_pe_nat INTO c_pe_nat_rec ;
            IF c_pe_nat%NOTFOUND THEN
                CLOSE c_pe_nat ;
                -- If person is not already having citizenship for this country then
                -- create a new nationality record
                INSERT INTO igs_pe_citizen_int(interface_citizenship_id,
                                            interface_id,
                                            status,
                                            country_code,
                                            date_recognized,
                                            created_by,
                                            creation_date,
                                            last_updated_by,
                                            last_update_date)
                VALUES (igs_pe_citizen_int_s.NEXTVAL,
                        l_interface_id,
                        l_status,
                        l_oss_nation,
                        Trunc(SYSDATE) ,
                        l_created_by,
                        SYSDATE,
                        l_last_updated_by,
                        SYSDATE) RETURNING interface_citizenship_id INTO l_interface_citizenship_id;
            ELSE
                CLOSE c_pe_nat ;
               -- If already the person has a citizenship record for this country then
               -- Get the Latest citizenship record for this person in this country and update its
               -- start and end dates appropriately
               IF Trunc(c_pe_nat_rec.date_recognized) <= Trunc(SYSDATE) THEN
                        -- If the latest record start date is before sysdate then update its end date to NULL
                        -- But if it is a future record then we cannot create a valid citizenship record ,hence log error
                        INSERT INTO igs_pe_citizen_int(interface_citizenship_id,
                                                    interface_id,
                                                    status,
                                                    country_code,
                                                    date_recognized,
                                                    date_disowned,
                                                    end_date,
                                                    created_by,
                                                    creation_date,
                                                    last_updated_by,
                                                    last_update_date)
                        VALUES (igs_pe_citizen_int_s.NEXTVAL,
                                l_interface_id,
                                l_status,
                                c_pe_nat_rec.country_code,
                                NVL(c_pe_nat_rec.date_recognized,TRUNC(SYSDATE)) ,
                                NULL,
                                NULL,
                                l_created_by,
                                SYSDATE,
                                l_last_updated_by,
                                SYSDATE) RETURNING interface_citizenship_id INTO l_interface_citizenship_id;
               ELSE
                      -- log error message that unable to create citizenship record due to future dated records existing
                      log_error('E29' ,c_interface_rec.interface_hesa_id, NULL);
               END IF; -- date comparisions

            END IF ; -- nationality record already exists
        END IF ; -- import country code

/* *************** end of importing person citizenship details ***************** */



/* *************** importing UCASID alternate person id details ***************** */

    -- Populate alternate person ID details interface table with UCASID
        IF c_interface_rec.ucasnum IS NOT NULL THEN

            import_alternate_person_id(c_interface_rec.interface_hesa_id,
                               l_interface_id,
                               l_status,
                               p_orgid,
                               p_person_id,
                               c_interface_rec.ucasnum, 'UCASID');
        END IF;

/* *************** end of importing UCASID alternate person id details ***************** */

/* *************** importing HUSID alternate person id details ***************** */

    -- Populate alternate person ID details interface table with HUSID
        IF c_interface_rec.husid IS NOT NULL THEN

            import_alternate_person_id(c_interface_rec.interface_hesa_id,
                               l_interface_id,
                               l_status,
                               p_orgid,
                               p_person_id,
                               c_interface_rec.husid, 'HUSID');
        END IF;

/* *************** end of importing HUSID alternate person id details ***************** */

/* *************** importing UCASREGNO alternate person id details ***************** */

    -- Populate alternate person ID details interface table with UCASREGNO
        IF c_interface_rec.scotvec IS NOT NULL THEN

            import_alternate_person_id(c_interface_rec.interface_hesa_id,
                               l_interface_id,
                               l_status,
                               p_orgid,
                               p_person_id,
                               c_interface_rec.scotvec, 'UCASREGNO');
        END IF;

 /* *************** end of importing UCASREGNO alternate person id details ***************** */



  EXCEPTION
    WHEN OTHERS THEN
      IF  c_interface%ISOPEN THEN
          CLOSE c_interface ;
      END IF ;
      IF c_pe_nat%ISOPEN THEN
           CLOSE  c_pe_nat;
      END IF ;
      IF c_pe_dis%ISOPEN THEN
           CLOSE c_pe_dis;
      END IF ;
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UCAS_EXPORT_TO_OSS.POPULATE_IMP_INT'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.LOG,fnd_message.get());
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END  populate_imp_int;


  PROCEDURE import_process(
    p_source_type_id igs_pe_src_types_all.source_type_id%TYPE,
    p_batch_id NUMBER,
    p_orgid NUMBER
  )  IS

    /******************************************************************
     Created By      :   smaddali
     Date Created By :   29-oct-2002
     Purpose         :  Submit the call for admission application import process
     Known limitations,enhancements,remarks:
     Change History
     Who       When          What
     ***************************************************************** */

    l_row_id VARCHAR2(26);

    CURSOR cur_match_set IS
      SELECT match_set_id
      FROM   igs_pe_match_sets
      WHERE  source_type_id = p_source_type_id;
    match_set_rec cur_match_set%ROWTYPE;

    l_interface_run_id igs_ad_interface_ctl.interface_run_id%TYPE;
    l_errbuff VARCHAR2(100) ;
    l_retcode NUMBER ;

  BEGIN

      -- Get the match set criteria corresponding to the ucas source type to be used for the person import
      match_set_rec := NULL ;
      OPEN cur_match_set;
      FETCH cur_match_set INTO match_set_rec;
      CLOSE cur_match_set;


       -- Call admission application import process procedure because current process has to wait until import process is finished
       IGS_AD_IMP_001.IMP_ADM_DATA ( errbuf => l_errbuff,
                                  retcode => l_retcode ,
                                   p_batch_id =>  p_batch_id,
                                  p_source_type_id => p_source_type_id,
                                  p_match_set_id => match_set_rec.match_set_id,
                                  p_acad_cal_type => NULL ,
                                  p_acad_sequence_number => NULL ,
                                  p_adm_cal_type => NULL ,
                                  p_adm_sequence_number => NULL ,
                                  p_admission_cat => NULL ,
                                  p_s_admission_process_type => NULL ,
                                  p_interface_run_id =>  l_interface_run_id ,
                                  P_org_id => NULL ) ;


  EXCEPTION
    WHEN OTHERS THEN
        IF cur_match_set%ISOPEN THEN
            CLOSE cur_match_set;
        END IF ;
        -- even though the admission import process completes in error , this process should continue processing
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_HE_IMPORT_DATA.IMPORT_PROCESS'||' - '||SQLERRM);
        fnd_file.put_line(fnd_file.LOG,fnd_message.get());
  END import_process;

  PROCEDURE main_process(
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER,
    p_batch_id igs_he_batch_int.batch_id%TYPE ,
    p_pers_det VARCHAR2 ,
    p_spa_det VARCHAR2
  ) IS
    /******************************************************************
     Created By      :   smaddali
     Date Created By :   29-oct-2002
     Purpose         :   Main process called from concurrent manager for "Import HESA Student Details" process
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     uudayapr  03-dec-2003  enh#3291662 Modified the cursor c_alt_orgid,c_inst as per the td of HECR212.
     uudayapr  25-Nov-2003  Removed the Trim Statement from the Cursor c_interface for Birth_dt as a part of bug#3175113 fix
     smaddali               Added validations for the 12 ucas tariff fields to check if oss code is mapped or not
                            and to  pass oss code while creating tariff records , bug 2671022
     ayedubat  11-FEB-2003  Added two new cursors,cur_calc_type and cur_ut_award_map for fetching the new
                            UCAS Tariff Calculation Setup created in this Enhancement.
                            Changed the logic of getting the HESA Tariff to OSS Award mapping from
                            'HESA_AWD_UT_ASSOC' HESA Association to the new setup. Bug # 2717744
     rbezawad  26-Feb-03    Modified w.r.t. Bug 2777247.  Added code to insert record into IGS_AD_IMP_BATCH_DET table.
     rbezawad  16-Sep-03    Modified the process w.r.t. UCFD210 Build, Bug 2893542 to populate the Previous education details into
                            OSS Academic History and obsolete the functionality related to IGS_UC_ATTEND_HIST.
     sjlaport  24-Feb-05    Corrected reference to HESA disability association OSS_HESA_DISABILITY_ASSOC
     sjlaport  31-Jan-05    Modified cursor c_alt_persid for HE358 to ignore logically deleted records.
     anwest    18-JAN-2006  Bug# 4950285 R12 Disable OSS Mandate
    ***************************************************************** */

    IGS_UC_HE_NOT_ENABLED_EXCEP EXCEPTION;
    l_no_setup BOOLEAN ;
    l_rep_request_id NUMBER ;
    l_imp_batch_id igs_ad_interface.batch_id%TYPE ;
    l_ins_tariff BOOLEAN ;
    l_upd_spa BOOLEAN ;
    l_upd_susa BOOLEAN ;
    l_upd_person BOOLEAN ;
    l_rowid VARCHAR2(50) ;
    l_hesa_st_spau_id igs_he_st_spa_ut.hesa_st_spau_id%TYPE;


    -- Get all the error records for the passed batch id and interface id
    CURSOR c_del_err(cp_interface_id igs_he_ucas_imp_int.interface_hesa_id%TYPE) IS
    SELECT err.rowid
    FROM igs_he_ucas_imp_err err
    WHERE err.batch_id = p_batch_id AND
         err.interface_hesa_id = NVL(cp_interface_id, err.interface_hesa_id);
    c_del_err_rec c_del_err%ROWTYPE ;

    -- check if person id type is setup
    CURSOR c_alt_persid_type( cp_persid_type igs_pe_person_id_typ.person_id_type%TYPE ) IS
    SELECT 'X'
    FROM igs_pe_person_id_typ
    WHERE person_id_type = cp_persid_type ;

    -- Check if alternate id type HESA_INST for institution is setup
    CURSOR c_alt_orgid IS
    SELECT 'X'
    FROM igs_or_org_alt_idtyp
      WHERE system_id_type = 'HESA_INST'
    AND NVL (close_ind, 'N') = 'N' ;

    l_altid VARCHAR2(1) ;

    --Check whether the Source Category of Academic History is included within the source Type "UCAS PER" or not.
    CURSOR cur_pe_src_cat (cp_source_type_id igs_pe_src_types_all.source_type_id%TYPE) IS
    SELECT 'X'
    FROM  igs_ad_source_cat_v
    WHERE source_type_id = cp_source_type_id
    AND   category_name  = 'PERSON_ACADEMIC_HISTORY'
    AND   include_ind    = 'Y';

    -- Get all the interface records for the passed batch id
    -- smaddali modified this cursor to add trim to all columns to remove spaces as part of bug 2740653
    CURSOR c_interface IS
    SELECT TRIM(a.interface_hesa_id) interface_hesa_id , TRIM(a.batch_id) batch_id,
        UPPER(TRIM(a.husid)) husid , TRIM(a.person_number) person_number, TRIM(a.course_cd) course_cd,
        TRIM(a.unit_set_cd) unit_set_cd, UPPER(TRIM(a.ucasnum)) ucasnum, UPPER(TRIM(a.scotvec)) scotvec,
        TRIM(a.surname) surname, TRIM(a.given_names) given_names , (a.birth_dt) birth_dt,
        TRIM(a.sex) sex, TRIM(a.domicile_cd) domicile_cd, TRIM(a.country_code) country_code,
        TRIM(a.ethnic_origin) ethnic_origin, TRIM(a.disability_type) disability_type,
        a.prev_inst_left_date prev_inst_left_date, TRIM(a.occcode) occcode, TRIM(a.highest_qual_on_entry) highest_qual_on_entry,
        TRIM(a.subject_qualaim1) subject_qualaim1, TRIM(a.subject_qualaim2) subject_qualaim2 ,
        TRIM(a.subject_qualaim3) subject_qualaim3 ,TRIM(a.qualaim_proportion) qualaim_proportion,
        TRIM(a.fee_eligibility) fee_eligibility, TRIM(a.postcode) postcode, TRIM(a.social_class_ind) social_class_ind,
        TRIM(a.occupation_code) occupation_code, TRIM(a.inst_code) inst_code, TRIM(a.gceasn) gceasn,
        TRIM(a.gceasts) gceasts, TRIM(a.vceasn) vceasn, TRIM(a.vceasts) vceasts, TRIM(a.gcean) gcean,
        TRIM(a.gceats) gceats, TRIM(a.vcean) vcean, TRIM(a.vceats) vceats, TRIM(a.ksqn) ksqn,
        TRIM(a.ksqts) ksqts, TRIM(a.uksan) uksan, TRIM(a.uksats) uksats, TRIM(a.sahn) sahn,
        TRIM(a.sahts) sahts, TRIM(a.shn) shn, TRIM(a.shts) shts, TRIM(a.si2n) si2n, TRIM(a.si2ts) si2ts,
        TRIM(a.ssgcn) ssgcn, TRIM(a.ssgcts) ssgcts, TRIM(a.scsn) scsn, TRIM(a.scsts) scsts,
        TRIM(a.aean) aean, TRIM(a.aeats) aeats, TRIM(a.total_ucas_tariff) total_ucas_tariff
    FROM igs_he_ucas_imp_int  a
    WHERE a.batch_id = p_batch_id ;
    c_interface_rec c_interface%ROWTYPE ;


    -- Get the person id for the passed alternate person id
    CURSOR c_alt_persid( cp_persid_type igs_pe_alt_pers_id.person_id_type%TYPE,
                              cp_person_id igs_pe_alt_pers_id.api_person_id%TYPE ) IS
    SELECT  party_number person_number
    FROM igs_pe_alt_pers_id , hz_parties
    WHERE person_id_type = cp_persid_type AND
          api_person_id = cp_person_id AND
          NVL(start_dt,SYSDATE) <= SYSDATE AND
          end_dt IS NULL  AND
          party_id = pe_person_id
    AND   (end_dt IS NULL OR start_dt  <> end_dt);

    c_alt_persid_rec c_alt_persid%ROWTYPE ;

    l_person_number igs_pe_person.person_number%TYPE ;

    -- get the student program attempt hesa record
    CURSOR c_spa( cp_person_id igs_he_st_spa.person_id%TYPE ,
                cp_course_cd igs_he_st_spa.course_cd%TYPE ) IS
    SELECT person_id ,course_cd , version_number
    FROM igs_he_st_spa_all
    WHERE person_id = cp_person_id AND
          course_cd = NVL(cp_course_cd,course_cd) ;
    l_spa c_spa%ROWTYPE;

    -- get the student unit set attempt hesa record
    CURSOR c_susa( cp_person_id igs_he_en_susa.person_id%TYPE ,
                cp_course_cd igs_he_en_susa.course_cd%TYPE ,
                cp_unit_set_cd igs_he_en_susa.unit_set_cd%TYPE ) IS
    SELECT 'X'
    FROM igs_he_en_susa
    WHERE person_id = cp_person_id AND
          course_cd = NVL(cp_course_cd,course_cd)  AND
          unit_set_cd = NVL(cp_unit_set_cd,unit_set_cd) ;
    l_susa VARCHAR2(1);

    -- get oss value from ucas oss hesa association
    CURSOR c_mapping ( cp_assoc_code igs_he_code_map_val.association_code%TYPE ,
                       cp_value igs_he_code_map_val.map3%TYPE ) IS
    SELECT map2
    FROM igs_he_code_map_val
    WHERE association_code = cp_assoc_code AND
          map3 = cp_value ;

    -- get oss value from oss hesa association
    CURSOR c_mapping1 ( cp_assoc_code igs_he_code_map_val.association_code%TYPE ,
                       cp_value igs_he_code_map_val.map1%TYPE ) IS
    SELECT map2
    FROM igs_he_code_map_val
    WHERE association_code = cp_assoc_code AND
          map1 = cp_value ;

    -- get the oss code for highest qualification on entry field
    -- smaddali modified this cursor for bug 2726086 to compare highest_qual to grade instead of rank
    -- smaddali modified cursor topget onlyopen code values , bug 2730388
    -- modified the cursor replace the equal comparision with EXISTS for bug, 3463819
    CURSOR c_high_qual( cp_high_qual igs_as_grd_sch_grade.grade%TYPE ) IS
    SELECT grade
    FROM igs_as_grd_sch_grade gsg
    WHERE
      EXISTS( SELECT 'X' FROM igs_he_code_values
              WHERE code_type = 'HESA_HIGH_QUAL_ON_ENT' AND
                    value = gsg.grading_schema_cd AND
                    NVL(closed_ind,'N' ) = 'N'  )
      AND gsg.grade= cp_high_qual
      AND ROWNUM < 2;

    -- get the oss inst code
    CURSOR c_inst( cp_inst_code igs_or_org_alt_ids.org_alternate_id%TYPE ) IS
    SELECT ORG_STRUCTURE_ID
    FROM IGS_OR_ORG_ALT_IDS OAI,IGS_OR_ORG_ALT_IDTYP_V OAIT
    WHERE OAI.ORG_alternate_ID = CP_INST_CODE
    AND   OAI.ORG_STRUCTURE_TYPE = 'INSTITUTE'
    AND   TRUNC (SYSDATE) BETWEEN TRUNC (OAI.START_DATE) AND NVL (TRUNC (OAI.END_DATE), TRUNC (SYSDATE)+1)
    AND   OAI.ORG_ALTERNATE_ID_TYPE = OAIT.ORG_ALTERNATE_ID_TYPE
    AND   OAIT.SYSTEM_ID_TYPE = 'HESA_INST';

    -- Get the oss  field of study
    CURSOR c_field_study( cp_subject igs_ps_fld_of_study.field_of_study%TYPE) IS
    SELECT a.field_of_study
    FROM igs_ps_fld_of_study a
    WHERE a.govt_field_of_study = cp_subject AND
          a.closed_ind = 'N'
    ORDER BY a.field_of_study ;

    -- Get the Batch ID for admission application import process
    CURSOR c_bat_id IS
    SELECT igs_ad_interface_batch_id_s.NEXTVAL
    FROM dual;

    -- Get the Source type ID of UCAS for admission import process
    --smaddali modified this cursor to get the source type UCAS PER instead of UCAS APPL ,bug 2724140
    CURSOR c_src_type_id IS
    SELECT source_type_id
    FROM igs_pe_src_types_all
    WHERE source_type = 'UCAS PER'
    AND   NVL(closed_ind,'N') = 'N';

    c_src_type_id_rec c_src_type_id%ROWTYPE;

    -- get the student program attempt hesa record for update
    CURSOR c_upd_spa( cp_person_id igs_he_st_spa.person_id%TYPE ,
                cp_course_cd igs_he_st_spa.course_cd%TYPE ) IS
    SELECT spa.rowid , spa.*
    FROM igs_he_st_spa_all spa
    WHERE spa.person_id = cp_person_id AND
          spa.course_cd = NVL(cp_course_cd,course_cd) ;

    -- get the student unit set attempt hesa record
    CURSOR c_upd_susa( cp_person_id igs_he_en_susa.person_id%TYPE ,
                cp_course_cd igs_he_en_susa.course_cd%TYPE ,
                cp_unit_set_cd igs_he_en_susa.unit_set_cd%TYPE ) IS
    SELECT susa.rowid , susa.*
    FROM igs_he_en_susa susa
    WHERE susa.person_id = cp_person_id AND
          susa.course_cd = NVL(cp_course_cd,course_cd)  AND
          susa.unit_set_cd = NVL(cp_unit_set_cd,unit_set_cd) ;

    -- get all the ucas tariff records for the student
    CURSOR c_del_tariff( cp_person_id igs_he_st_spa_ut.person_id%TYPE ,
                         cp_course_cd igs_he_st_spa_ut.course_cd%TYPE ) IS
    SELECT rowid
    FROM igs_he_st_spa_ut_all
    WHERE person_id = cp_person_id AND
        course_cd = cp_course_cd ;

    -- get the Academic history record for the student
    CURSOR c_acad_hist ( cp_person_id igs_ad_acad_history_v.person_id%TYPE ,
                         cp_inst_cd igs_ad_acad_history_v.institution_code%TYPE ) IS
    SELECT a.*
    FROM  igs_ad_acad_history_v a
    WHERE a.person_id = cp_person_id
    AND   a.institution_code = cp_inst_cd ;
    l_acad_hist_rec c_acad_hist%ROWTYPE ;

    -- get the Academic history record for the student
    CURSOR c_acad_hist_count ( cp_person_id igs_ad_acad_history_v.person_id%TYPE ,
                               cp_inst_cd igs_ad_acad_history_v.institution_code%TYPE ) IS
    SELECT COUNT(*)
    FROM   igs_ad_acad_history_v a
    WHERE  a.person_id = cp_person_id
    AND    a.institution_code = cp_inst_cd ;
    l_acad_hist_count NUMBER(3);

    -- Get the Person number for the passed person id.
    CURSOR c_person_info (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
      SELECT person_number, last_name surname, first_name given_names, gender sex, birth_date birth_dt
      FROM   igs_pe_person_base_v
      WHERE  person_id = cp_person_id;
    l_person_info_rec c_person_info%ROWTYPE;

    -- Get the Admission Interface ID while populating Acad Hisotry Interface table
    --   if it is already created as part of Person details import or not.
    CURSOR c_adm_int_id( cp_batch_id  igs_ad_interface_all.batch_id%TYPE,
                         cp_person_id igs_ad_interface_all.person_id%TYPE ) IS
    SELECT a.interface_id
    FROM   igs_ad_interface_all a
    WHERE  a.batch_id = cp_batch_id
    AND    a.person_id= cp_person_id
    AND    a.status = '2'
    AND    a.record_status='2';
    l_interface_id igs_ad_interface_all.interface_id%TYPE ;

    -- Get the admission application instance interface records whose import has failed
    CURSOR c_adm_int( cp_batch_id igs_ad_interface.batch_id%TYPE,
            cp_person_number igs_pe_person.person_number%TYPE ) IS
    SELECT  a.person_number, a.interface_id
    FROM igs_ad_interface a
    WHERE a.batch_id = cp_batch_id AND
          a.person_number= cp_person_number AND
           ( a.status IN ('2','3') OR a.record_status='3' ) ;
    c_adm_int_rec c_adm_int%ROWTYPE ;

    -- Get the Academic History interface records whose import has failed
    CURSOR c_acadhis_int (cp_interface_id igs_ad_acadhis_int_all.interface_id%TYPE) IS
    SELECT  a.interface_acadhis_id
    FROM  igs_ad_acadhis_int_all a
    WHERE a.interface_id = cp_interface_id
    AND   a.status = '3';
    l_interface_acadhis_id igs_ad_acadhis_int_all.interface_acadhis_id%TYPE ;

    -- Get the hesa import interface record for the passed person number
    -- smaddali modified this cursor to add trim to remove spaces  as part of bug fix 2740653
    CURSOR c_imp_int IS
    SELECT  trim(a.interface_hesa_id) interface_hesa_id , trim(a.person_number) person_number
    FROM igs_he_ucas_imp_int a
    WHERE a.batch_id = p_batch_id  ;
    c_imp_int_rec c_imp_int%ROWTYPE ;

    -- To get the External Calculation Type used for UCAS Tariff Calculation
    CURSOR cur_calc_type IS
      SELECT utct.tariff_calc_type_cd
      FROM  IGS_HE_UT_CALC_TYPE utct
      WHERE utct.external_calc_ind = 'Y'
        AND utct.closed_ind = 'N' ;
    l_tariff_calc_type_cd IGS_HE_UT_CALC_TYPE.tariff_calc_type_cd%TYPE ;

    -- To get the Default OSS Ward mapped to a HESA Tariff Level
    CURSOR cur_ut_award_map ( cp_calc_type  IGS_HE_UT_LVL_AWARD.tariff_calc_type_cd%TYPE,
                              cp_tariff_level_cd IGS_HE_UT_LVL_AWARD.tariff_level_cd%TYPE ) IS
      SELECT utla.award_cd
      FROM IGS_HE_UT_LVL_AWARD utla
      WHERE utla.tariff_calc_type_cd = cp_calc_type
        AND utla.tariff_level_cd = cp_tariff_level_cd
        AND utla.default_award_ind = 'Y'
        AND utla.closed_ind = 'N' ;

    -- smaddali added these local variables to hold OSS Award code for each HESA UT qualification ,bug#2671022
    l_oss_gceasn IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_vceasn IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_gcean  IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_vcean  IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_ksqn   IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_uksan  IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_sahn   IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_shn    IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_si2n   IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_ssgcn  IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_scsn   IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_oss_aean   IGS_HE_UT_LVL_AWARD.award_cd%TYPE;
    l_call_pers_imp BOOLEAN ;
    l_return_status VARCHAR2(1);
    l_msg_data      VARCHAR2(100);

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    -- inititalize variables
    errbuf := NULL;
    l_no_setup := FALSE ;
    l_batch_id := p_batch_id ;

    -- Checking whether the UK profile is enabled
    -- If country code is not set to GB then exit job
    IF Not (IGS_UC_UTILS.IS_UCAS_HESA_ENABLED) THEN
      Raise IGS_UC_HE_NOT_ENABLED_EXCEP; -- user defined exception
    END IF;

    -- Validate the Parameters ,atleast one of person details or program attempt details should be imported
    -- Both p_spa_det and p_pers_det should not be having value N
    IF p_pers_det = 'N' AND p_spa_det = 'N' THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_HE_IMP_INV_PARAM');
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       retcode := 3 ;
       RETURN ;
    END IF ;

    -- Delete all the error records existing for the passed batch_id
    FOR c_del_err_rec IN c_del_err(NULL) LOOP
         igs_he_ucas_imp_err_pkg.delete_row( X_ROWID => c_del_err_rec.rowid ) ;
    END LOOP ;

    -- Person Id type setup validations
    -- If a person id type HUSID is not setup then log error
    l_altid := NULL ;
    OPEN c_alt_persid_type('HUSID') ;
    FETCH c_alt_persid_type INTO l_altid ;
    IF c_alt_persid_type%NOTFOUND THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_HE_NO_HUSID');
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       l_no_setup := TRUE ;
    END IF;
    CLOSE c_alt_persid_type ;

    -- If a person if type of UCASID is not setup then log error
    l_altid := NULL ;
    OPEN c_alt_persid_type('UCASID') ;
    FETCH c_alt_persid_type INTO l_altid ;
    IF c_alt_persid_type%NOTFOUND THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_HE_NO_UCASID');
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       l_no_setup := TRUE ;
    END IF;
    CLOSE c_alt_persid_type ;

    -- If a person id type of UCASREGNO is not setup then log error
    l_altid := NULL ;
    OPEN c_alt_persid_type('UCASREGNO') ;
    FETCH c_alt_persid_type INTO l_altid ;
    IF c_alt_persid_type%NOTFOUND THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_HE_NO_SCOTVEC');
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       l_no_setup := TRUE ;
    END IF;
    CLOSE c_alt_persid_type ;

    -- If an institution alternate id type of HESA_INST has not been setup then log error
    l_altid := NULL ;
    OPEN c_alt_orgid ;
    FETCH c_alt_orgid INTO l_altid ;
    IF c_alt_orgid%NOTFOUND THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_HE_NO_HESAINST');
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       l_no_setup := TRUE ;
    END IF;
    CLOSE c_alt_orgid ;

    -- Check whether the Person Source Type 'UCAS PER' defined in the setup
    c_src_type_id_rec := NULL ;
    OPEN c_src_type_id;
    FETCH c_src_type_id INTO c_src_type_id_rec;
    IF c_src_type_id%NOTFOUND THEN
       fnd_message.set_name('IGS','IGS_UC_NO_UCAS_SRC_TYP');
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       l_no_setup := TRUE ;
    ELSE
       --Check whether the Source Category of Academic History is included within the source Type "UCAS PER" or not.
       l_altid := NULL ;
       OPEN cur_pe_src_cat(c_src_type_id_rec.source_type_id);
       FETCH cur_pe_src_cat INTO l_altid;
       IF cur_pe_src_cat%NOTFOUND THEN
         fnd_message.set_name('IGS','IGS_UC_SETUP_SRC_CAT');
         fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
         l_no_setup := TRUE ;
       END IF;
       CLOSE cur_pe_src_cat;
    END IF;
   CLOSE c_src_type_id;

    -- If setup is not found then end the job
    IF  l_no_setup THEN
      -- end job in error state
       retcode := 3 ;
       RETURN ;
    END IF ;

    -- If there are no interface records for the passed batch_id then log error  and exit job
    c_interface_rec := NULL ;
    OPEN c_interface ;
    FETCH c_interface INTO c_interface_rec ;
    IF c_interface%NOTFOUND THEN
       CLOSE c_interface ;
       retcode := 3;
       FND_MESSAGE.SET_NAME('IGS','IGS_HE_NO_INT_RECS');
       FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id) ;
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       RETURN ;
    ELSE
       CLOSE c_interface ;
    END IF ;

    l_call_pers_imp := FALSE ;
    -- If Import person details parameter is set to Yes then Generate the batch_id and source_type_id
    -- for calling the import process
    IF  p_pers_det = 'Y' THEN
       -- Get the batch ID for populating person interface tables and
       -- running the application import process
       l_imp_batch_id := NULL ;
       OPEN c_bat_id;
       FETCH c_bat_id INTO l_imp_batch_id;
       CLOSE c_bat_id;

       INSERT INTO igs_ad_imp_batch_det ( batch_id,
                                          batch_desc,
                                          created_by,
                                          creation_date,
                                          last_updated_by,
                                          last_update_date,
                                          last_update_login,
                                          request_id,
                                          program_application_id,
                                          program_update_date,
                                          program_id)
                                 VALUES ( l_imp_batch_id,
                                          fnd_message.get_string('IGS','IGS_HE_IMP_HESA_DET_BATCH_ID'),
                                          fnd_global.user_id,
                                          SYSDATE,
                                          fnd_global.user_id,
                                          SYSDATE,
                                          fnd_global.login_id,
                                          DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_request_id),
                                          DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.prog_appl_id),
                                          DECODE(fnd_global.conc_request_id,-1,NULL,SYSDATE),
                                          DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_program_id)
                                        );
    END IF ;

    -- Process all the import interface reocrds for the passed Batch ID
    FOR c_interface_rec IN c_interface LOOP
       fnd_file.put_line( fnd_file.LOG ,' ');
       fnd_message.set_name('IGS','IGS_HE_PROC_INT');
       fnd_message.set_token('INTERFACE_ID',c_interface_rec.interface_hesa_id) ;
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

        l_error_flag := FALSE ;
        l_person_number := NULL ;
        l_oss_gceasn  := NULL ;
        l_oss_vceasn  := NULL ;
        l_oss_gcean   := NULL ;
        l_oss_vcean   := NULL ;
        l_oss_ksqn    := NULL ;
        l_oss_uksan   := NULL ;
        l_oss_sahn    := NULL ;
        l_oss_shn     := NULL ;
        l_oss_si2n    := NULL ;
        l_oss_ssgcn   := NULL ;
        l_oss_scsn    := NULL ;
        l_oss_aean    := NULL ;
        l_oss_gender := NULL ;
        l_oss_nation := NULL ;
        l_oss_disability := NULL ;
        l_oss_ethnicity := NULL ;
        l_oss_subj1 := NULL ;
        l_oss_subj2 := NULL ;
        l_oss_subj3 := NULL ;
        l_oss_proportion := NULL ;
        l_oss_domicile := NULL ;
        l_oss_occupation := NULL ;
        l_oss_social_class := NULL ;
        l_oss_inst := NULL ;
        l_oss_high_qual := NULL ;
        l_oss_fee_elig := NULL ;

        l_ins_tariff := FALSE ;
        l_upd_spa := FALSE ;
        l_upd_person := FALSE ;


       -- Validate person identifier
       -- If person identifier is not provided for this interface record then log error
       IF c_interface_rec.HUSID IS NULL AND c_interface_rec.UCASNUM IS NULL AND
           c_interface_rec.PERSON_NUMBER IS NULL THEN
           log_error('E01' , c_interface_rec.interface_hesa_id , NULL ) ;
           l_error_flag := TRUE ;
       ELSE
           IF c_interface_rec.person_number IS NOT NULL THEN
               --If person number is given in the interface record then use that identify oss person
               l_person_number := c_interface_rec.person_number ;
           ELSIF c_interface_rec.husid IS NOT NULL THEN
               -- Elsif husid is given ,use it to get the oss person
               OPEN c_alt_persid('HUSID' , c_interface_rec.husid) ;
               FETCH c_alt_persid INTO c_alt_persid_rec ;
               IF c_alt_persid%FOUND THEN
                  -- If the given husid is a valid alternate person id then get the person number
                  CLOSE c_alt_persid ;
                  l_person_number := c_alt_persid_rec.person_number ;
               ELSE
                  -- If given husid is not a valid alternate person id then use ucasid
                  CLOSE c_alt_persid ;
                  OPEN c_alt_persid('UCASID' , c_interface_rec.ucasnum) ;
                  FETCH c_alt_persid INTO c_alt_persid_rec ;
                  IF c_alt_persid%FOUND THEN
                     -- if ucasid is a valid alternate person id then get the person number
                     l_person_number := c_alt_persid_rec.person_number ;
                  END IF ;
                  CLOSE c_alt_persid ;
               END IF ;
           ELSE -- husid is null but ucasid is not null in the interface record
                  OPEN c_alt_persid('UCASID' , c_interface_rec.ucasnum) ;
                  FETCH c_alt_persid INTO c_alt_persid_rec ;
                  IF c_alt_persid%FOUND THEN
                     -- if ucasid is a valid aleternate person id then get the person number
                     l_person_number := c_alt_persid_rec.person_number ;
                  END IF ;
                  CLOSE c_alt_persid ;
           END IF ;

           -- If the person number of the interface record is identified then get the oss person details
           IF l_person_number IS NOT NULL THEN
               OPEN c_pe_det( l_person_number) ;
               FETCH c_pe_det INTO c_pe_det_rec ;
               IF c_pe_det%NOTFOUND THEN
                   -- If the oss person record for the identified person number is not found then log error
                   log_error('E02' ,c_interface_rec.interface_hesa_id, NULL);
                   l_error_flag := TRUE;
               ELSE
                  -- If oss person record is found but the person identifier in the interface record is null
                  -- then update the interface record with the identified person number
                  IF  c_interface_rec.person_number IS NULL THEN
                       c_interface_rec.person_number := l_person_number ;
                       UPDATE igs_he_ucas_imp_int SET person_number = l_person_number
                        WHERE batch_id =p_batch_id AND interface_hesa_id = c_interface_rec.interface_hesa_id ;
                  END IF ;
               END IF ;
               CLOSE c_pe_det ;
           ELSE
               -- If person identifier is not found then log an error
               log_error('E02' ,c_interface_rec.interface_hesa_id, NULL);
               l_error_flag := TRUE;
           END IF ; -- if person details found

       END IF ;  -- if person identifier found

       -- If person found in oss then continue with the other validations ,else skip this record
       IF NOT l_error_flag THEN

          -- validate program and unit set fields
          IF p_spa_det = 'Y' THEN
             -- check if the hesa program attempt record exists for this person
             OPEN c_spa(c_pe_det_rec.person_id,c_interface_rec.course_cd) ;
             FETCH c_spa INTO l_spa ;
             IF c_spa%NOTFOUND THEN
                 IF c_interface_rec.course_cd IS NOT NULL THEN
                   -- Log a message that no student program attempt hesa record found for
                   -- the course specified in the interface record
                   log_error('E03' ,c_interface_rec.interface_hesa_id, NULL);
                   l_error_flag := TRUE;
                 ELSE
                   -- Log a message that no student program attempt hesa records found for
                   -- the student in  any program
                   log_error('E05' ,c_interface_rec.interface_hesa_id, NULL);
                   l_error_flag := TRUE;
                 END IF ;
             END IF ;
             CLOSE c_spa ;

             -- If fee eligibility needs to be imported then
             -- check if the hesa unit set attempt record exists for this person
             IF c_interface_rec.fee_eligibility IS NOT NULL THEN
                 OPEN c_susa(c_pe_det_rec.person_id,c_interface_rec.course_cd,c_interface_rec.unit_set_cd) ;
                 FETCH c_susa INTO l_susa ;
                 IF c_susa%NOTFOUND THEN
                   -- Log a message that no student unit set attempt hesa record found for
                   -- the course and unit set specified in the interface record
                    IF c_interface_rec.unit_set_cd IS NOT NULL THEN
                        log_error('E04' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                    ELSE
                   -- Log a message that no student unit set attempt hesa records found for
                   -- the student in any unit set
                        log_error('E06' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                    END IF ;
                 END IF ;
                 CLOSE c_susa ;
             END IF ; -- if fee eligibility is not null
          END IF ; -- import program details parameter is set to yes

          -- If course and unit set validations passed then continue with the other validations
          -- else skip this record
          IF NOT l_error_flag THEN

             -- if import person details parameter has value yes then validate if hesa coded person fields
             -- are mapped to corresponding oss codes
             IF p_pers_det = 'Y' THEN

                -- if sex is not mapped to oss gender code then log error
                IF c_interface_rec.sex IS NOT NULL THEN
                   l_upd_person := TRUE ;
                   OPEN c_mapping('UC_OSS_HE_GEN_ASSOC' , c_interface_rec.sex) ;
                   FETCH c_mapping INTO l_oss_gender ;
                   IF c_mapping%NOTFOUND THEN
                        log_error('E07' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_mapping ;
                END IF ;

                -- if country is not mapped to oss nationality code the log error
                IF c_interface_rec.country_code IS NOT NULL THEN
                   l_upd_person := TRUE ;
                   OPEN c_mapping('UC_OSS_HE_NAT_ASSOC' , c_interface_rec.country_code) ;
                   FETCH c_mapping INTO l_oss_nation ;
                   IF c_mapping%NOTFOUND THEN
                        log_error('E08' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_mapping ;
                END IF ;

                -- if disability type is not mapped to oss disability code then log error
                IF c_interface_rec.disability_type IS NOT NULL THEN
                   l_upd_person := TRUE ;
                   OPEN c_mapping1('OSS_HESA_DISABILITY_ASSOC' , c_interface_rec.disability_type) ;
                   FETCH c_mapping1 INTO l_oss_disability ;
                   IF c_mapping1%NOTFOUND THEN
                        log_error('E09' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_mapping1 ;
                END IF ;

                -- if ethnicity is not mapped to oss ethnicity code then log error
                IF c_interface_rec.ethnic_origin IS NOT NULL THEN
                   l_upd_person := TRUE ;
                   OPEN c_mapping('UC_OSS_HE_ETH_ASSOC' , c_interface_rec.ethnic_origin) ;
                   FETCH c_mapping INTO l_oss_ethnicity ;
                   IF c_mapping%NOTFOUND THEN
                        log_error('E10' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_mapping ;
                END IF ;


             -- if inst_code is not mapped to oss institution code then log error
             IF c_interface_rec.inst_code IS NOT NULL THEN
            --Get the OSS Institution Code from the Alternate Institution Codes where Code Type = HESA_INST
            OPEN c_inst( c_interface_rec.inst_code) ;
            FETCH c_inst INTO l_oss_inst ;
            CLOSE c_inst ;

            IF l_oss_inst IS NULL THEN
                 IF SUBSTR (c_interface_rec.inst_code,1,1) = 'U' THEN
                     --Get the OSS Institution Code(map2) from HESA Mapping with Association code as UC_OSS_HE_INS_ASSOC
                 -- and map1 as UCAS Institute code without left most character.
                 OPEN c_mapping1('UC_OSS_HE_INS_ASSOC', SUBSTR(c_interface_rec.inst_code,2,LENGTH(c_interface_rec.inst_code)) );
                 FETCH c_mapping1 INTO l_oss_inst;
                 CLOSE c_mapping1;
                 IF l_oss_inst IS NULL THEN
                   log_error('E18' ,c_interface_rec.interface_hesa_id, NULL);
                   l_error_flag := TRUE;
                END IF;
                 ELSE
                log_error('E18' ,c_interface_rec.interface_hesa_id, NULL);
                l_error_flag := TRUE;
                 END IF;
            END IF ;

             END IF ;

             -- If prev_inst_left_date is given without giving the institute last attended then log error
             IF c_interface_rec.prev_inst_left_date IS NOT NULL AND c_interface_rec.inst_code IS NULL THEN
                log_error('E28' ,c_interface_rec.interface_hesa_id, NULL);
                l_error_flag := TRUE;
             END IF ;


                -- if any person details have been populated then we need to populate the person import interface tables
                IF c_interface_rec.given_names IS NOT NULL OR
                   c_interface_rec.surname IS NOT NULL OR
                   c_interface_rec.ucasnum IS NOT NULL OR
                   c_interface_rec.husid IS NOT NULL OR
                   c_interface_rec.scotvec IS NOT NULL THEN
                   l_upd_person := TRUE ;
                END IF ;

             END IF; -- person details being imported

             -- if import program attempt details parameter has value yes then validate if program attempt
             -- hesa coded fields are mapped to corresponding oss values
             IF p_spa_det = 'Y' THEN

                -- if subject of qualification aim1 is not mapped to oss field of study then log error
                IF c_interface_rec.subject_qualaim1 IS NOT NULL THEN
                   l_upd_spa := TRUE ;
                   OPEN c_field_study(c_interface_rec.subject_qualaim1) ;
                   FETCH c_field_study INTO l_oss_subj1 ;
                   IF c_field_study%NOTFOUND THEN
                        log_error('E11' ,c_interface_rec.interface_hesa_id,'1');
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_field_study ;
                END IF ;

                -- if subject of qualification aim2 is not mapped to oss field of study then log error
                IF c_interface_rec.subject_qualaim2 IS NOT NULL THEN
                   l_upd_spa := TRUE ;
                   OPEN c_field_study(c_interface_rec.subject_qualaim2) ;
                   FETCH c_field_study INTO l_oss_subj2 ;
                   IF c_field_study%NOTFOUND THEN
                        log_error('E11' ,c_interface_rec.interface_hesa_id,'2');
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_field_study ;
                END IF ;

                -- if subject of qualification aim3 is not mapped to oss field of study then log error
                IF c_interface_rec.subject_qualaim3 IS NOT NULL THEN
                   l_upd_spa := TRUE ;
                   OPEN c_field_study(c_interface_rec.subject_qualaim3) ;
                   FETCH c_field_study INTO l_oss_subj3 ;
                   IF c_field_study%NOTFOUND THEN
                        log_error('E11' ,c_interface_rec.interface_hesa_id,'3');
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_field_study ;
                END IF ;


                -- if qualification aim proportion is not mapped to oss proportion code then log error
                IF c_interface_rec.qualaim_proportion IS NOT NULL THEN
                   l_upd_spa := TRUE ;
                   OPEN c_mapping1('OSS_HESA_PROPORTION_ASSOC' , c_interface_rec.qualaim_proportion) ;
                   FETCH c_mapping1 INTO l_oss_proportion ;
                   IF c_mapping1%NOTFOUND THEN
                        log_error('E12' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_mapping1 ;
                END IF ;

                -- if domicile is  not mapped to oss domicile code then log error
                IF c_interface_rec.domicile_cd IS NOT NULL THEN
                   l_upd_spa := TRUE ;
                   OPEN c_mapping('UC_OSS_HE_DOM_ASSOC' , c_interface_rec.domicile_cd) ;
                   FETCH c_mapping INTO l_oss_domicile ;
                   IF c_mapping%NOTFOUND THEN
                        log_error('E13' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_mapping ;
                END IF ;

                -- if occupation is not mapped to oss occupation code then log error
                IF c_interface_rec.occupation_code IS NOT NULL THEN
                   l_upd_spa := TRUE ;
                   OPEN c_mapping('UC_OSS_HE_OCC_ASSOC' , c_interface_rec.occupation_code) ;
                   FETCH c_mapping INTO l_oss_occupation ;
                   IF c_mapping%NOTFOUND THEN
                        log_error('E14' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_mapping ;
                END IF ;

                -- if social class is not mapped to oss social class code then log error
                IF c_interface_rec.social_class_ind IS NOT NULL THEN
                   l_upd_spa := TRUE ;
                   OPEN c_mapping('UC_OSS_HE_SOC_ASSOC' , c_interface_rec.social_class_ind) ;
                   FETCH c_mapping INTO l_oss_social_class ;
                   IF c_mapping%NOTFOUND THEN
                        log_error('E15' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_mapping ;
                END IF ;

                -- if highest qualification is not mapped to oss grade then log error
                IF c_interface_rec.highest_qual_on_entry IS NOT NULL THEN
                   l_upd_spa := TRUE ;
                   OPEN c_high_qual( c_interface_rec.highest_qual_on_entry) ;
                   FETCH c_high_qual INTO l_oss_high_qual ;
                   IF c_high_qual%NOTFOUND THEN
                        log_error('E16' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_high_qual ;
                END IF ;

                -- if fee eligibility is not mapped to oss code then log error
                IF c_interface_rec.fee_eligibility IS NOT NULL THEN
                   OPEN c_mapping1('OSS_HESA_FEEELIG_ASSOC' , c_interface_rec.fee_eligibility) ;
                   FETCH c_mapping1 INTO l_oss_fee_elig ;
                   IF c_mapping1%NOTFOUND THEN
                        log_error('E17' ,c_interface_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                   END IF ;
                   CLOSE c_mapping1 ;
                END IF ;

                -- if number of qualifications is given but tariff score is not given for any qualification then log error
                IF c_interface_rec.gceasn IS NOT NULL  AND c_interface_rec.gceasts IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, 'GCSEAS');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.vceasn IS NOT NULL  AND c_interface_rec.vceasts IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, 'VCSEAS');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.gcean IS NOT NULL  AND c_interface_rec.gceats IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, 'GCSEA');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.vcean IS NOT NULL  AND c_interface_rec.vceats IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, 'VCSEA');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.ksqn IS NOT NULL  AND c_interface_rec.ksqts IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, 'KEYSKL');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.uksan IS NOT NULL  AND c_interface_rec.uksats IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, '1UNKEYSKL');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.sahn IS NOT NULL  AND c_interface_rec.sahts IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, 'SCOTADH');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.shn IS NOT NULL  AND c_interface_rec.shts IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, 'SCOTH');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.si2n IS NOT NULL  AND c_interface_rec.si2ts IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, 'SCOTI2');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.ssgcn IS NOT NULL  AND c_interface_rec.ssgcts IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, 'SCOTST');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.scsn IS NOT NULL  AND c_interface_rec.scsts IS NULL THEN
                       log_error('E19' ,c_interface_rec.interface_hesa_id, 'SCOTCO');
                       l_error_flag := TRUE;
                END IF ;


               -- if number of qualifications is not given but tariff score is given for any qualification then log error
                IF c_interface_rec.gceasn IS NULL  AND c_interface_rec.gceasts IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, 'GCSEAS');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.vceasn IS NULL  AND c_interface_rec.vceasts IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, 'VCSEAS');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.gcean IS NULL  AND c_interface_rec.gceats IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, 'GCSEA');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.vcean IS NULL  AND c_interface_rec.vceats IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, 'VCSEA');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.ksqn IS NULL  AND c_interface_rec.ksqts IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, 'KEYSKL');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.uksan IS NULL  AND c_interface_rec.uksats IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, '1UNKEYSKL');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.sahn IS NULL  AND c_interface_rec.sahts IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, 'SCOTADH');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.shn IS NULL  AND c_interface_rec.shts IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, 'SCOTH');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.si2n IS NULL  AND c_interface_rec.si2ts IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, 'SCOTI2');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.ssgcn IS NULL  AND c_interface_rec.ssgcts IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, 'SCOTST');
                       l_error_flag := TRUE;
                END IF ;

                IF c_interface_rec.scsn IS NULL  AND c_interface_rec.scsts IS NOT NULL THEN
                       log_error('E20' ,c_interface_rec.interface_hesa_id, 'SCOTCO');
                       l_error_flag := TRUE;
                END IF ;

                -- Check whether any of the UCAS Tariff fields is imported
                IF  c_interface_rec.gceasn IS NOT NULL OR c_interface_rec.vceasn IS NOT NULL
                  OR c_interface_rec.gcean IS NOT NULL OR c_interface_rec.vcean  IS NOT NULL
                  OR c_interface_rec.ksqn  IS NOT NULL OR c_interface_rec.uksan  IS NOT NULL
                  OR c_interface_rec.sahn  IS NOT NULL OR c_interface_rec.shn    IS NOT NULL
                  OR c_interface_rec.si2n  IS NOT NULL OR c_interface_rec.ssgcn  IS NOT NULL
                  OR c_interface_rec.scsn  IS NOT NULL OR c_interface_rec.aean   IS NOT NULL
                  OR c_interface_rec.aeats IS NOT NULL THEN

                  -- Check whether UCAS Tariff Calculation Type setup is defined for External Caculation Type
                  -- If not find, then log the error
                  OPEN cur_calc_type;
                  FETCH cur_calc_type INTO l_tariff_calc_type_cd;
                  IF cur_calc_type%NOTFOUND THEN
                    log_error('E35', c_interface_rec.interface_hesa_id,NULL );
                    l_error_flag := TRUE;
                  END IF;
                  CLOSE cur_calc_type;

                  IF NOT l_error_flag THEN

                    -- if OSS Award code  is not mapped for any qualification then log error
                    IF c_interface_rec.gceasn IS NOT NULL OR c_interface_rec.gceasts IS NOT NULL THEN
                       OPEN cur_ut_award_map ( l_tariff_calc_type_cd,'GCSEAS' );
                       FETCH cur_ut_award_map INTO l_oss_gceasn ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, 'GCSEAS');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.vceasn IS NOT NULL  OR c_interface_rec.vceasts IS NOT NULL THEN
                       OPEN cur_ut_award_map( l_tariff_calc_type_cd ,'VCSEAS' ) ;
                       FETCH cur_ut_award_map INTO l_oss_vceasn ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, 'VCSEAS');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.gcean IS NOT NULL  OR c_interface_rec.gceats IS NOT NULL THEN
                       OPEN cur_ut_award_map(l_tariff_calc_type_cd , 'GCSEA' ) ;
                       FETCH cur_ut_award_map INTO l_oss_gcean ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, 'GCSEA');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.vcean IS NOT NULL  OR c_interface_rec.vceats IS NOT NULL THEN
                       OPEN cur_ut_award_map(l_tariff_calc_type_cd , 'VCSEA') ;
                       FETCH cur_ut_award_map INTO l_oss_vcean ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, 'VCSEA');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.ksqn IS NOT NULL  OR c_interface_rec.ksqts IS NOT NULL THEN
                       OPEN cur_ut_award_map(l_tariff_calc_type_cd , 'KEYSKL') ;
                       FETCH cur_ut_award_map INTO l_oss_ksqn ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, 'KEYSKL');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.uksan IS NOT NULL  OR c_interface_rec.uksats IS NOT NULL THEN
                       OPEN cur_ut_award_map(l_tariff_calc_type_cd , '1UNKEYSKL') ;
                       FETCH cur_ut_award_map INTO l_oss_uksan;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, '1UNKEYSKL');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.sahn IS NOT NULL  OR  c_interface_rec.sahts IS NOT NULL THEN
                       OPEN cur_ut_award_map(l_tariff_calc_type_cd , 'SCOTADH') ;
                       FETCH cur_ut_award_map INTO l_oss_sahn ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, 'SCOTADH');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.shn IS NOT NULL  OR c_interface_rec.shts IS NOT NULL THEN
                       OPEN cur_ut_award_map(l_tariff_calc_type_cd ,  'SCOTH') ;
                       FETCH cur_ut_award_map INTO l_oss_shn ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, 'SCOTH');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.si2n IS NOT NULL  OR c_interface_rec.si2ts IS NOT NULL THEN
                       OPEN cur_ut_award_map(l_tariff_calc_type_cd ,  'SCOTI2') ;
                       FETCH cur_ut_award_map INTO l_oss_si2n ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, 'SCOTI2');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.ssgcn IS NOT NULL  OR c_interface_rec.ssgcts IS NOT NULL THEN
                       OPEN cur_ut_award_map(l_tariff_calc_type_cd ,  'SCOTST') ;
                       FETCH cur_ut_award_map INTO l_oss_ssgcn ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, 'SCOTST');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.scsn IS NOT NULL  OR c_interface_rec.scsts IS NOT NULL THEN
                       OPEN cur_ut_award_map(l_tariff_calc_type_cd ,  'SCOTCO') ;
                       FETCH cur_ut_award_map INTO l_oss_scsn ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id, 'SCOTCO');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                    IF c_interface_rec.aean IS NOT NULL  OR c_interface_rec.aeats IS NOT NULL THEN
                       OPEN cur_ut_award_map(l_tariff_calc_type_cd ,  'ADVEXT') ;
                       FETCH cur_ut_award_map INTO l_oss_aean ;
                       IF cur_ut_award_map%NOTFOUND THEN
                           log_error('E33' ,c_interface_rec.interface_hesa_id,'ADVEXT');
                           l_error_flag := TRUE;
                       END IF ;
                       CLOSE cur_ut_award_map ;
                    END IF ;

                  END IF; /* End of checking the UCAS Tariff Calculation Setup exist */

                END IF ; /* End of validating the UCAS Tariff related fields */

                -- If total tariff is given without individual tariffs present , then log error
                IF c_interface_rec.total_ucas_tariff IS NOT NULL AND c_interface_rec.aeats IS NULL AND
                  c_interface_rec.scsts IS NULL AND c_interface_rec.ssgcts IS NULL AND
                  c_interface_rec.si2ts IS NULL AND c_interface_rec.shts IS NULL AND
                  c_interface_rec.sahts IS NULL AND c_interface_rec.uksats IS NULL AND
                  c_interface_rec.ksqts IS NULL AND c_interface_rec.vceats IS NULL AND
                  c_interface_rec.gceats IS NULL AND c_interface_rec.vceasts IS NULL AND
                  c_interface_rec.gceasts IS NULL THEN
                       log_error('E27' ,c_interface_rec.interface_hesa_id, NULL);
                       l_error_flag := TRUE;
                END IF ;

                -- check if ucas tariff records need to be created , i.e if tariff details have been populated or not
                IF c_interface_rec.aeats IS NOT NULL OR
                  c_interface_rec.scsts IS NOT NULL OR c_interface_rec.ssgcts IS NOT NULL OR
                  c_interface_rec.si2ts IS NOT NULL OR c_interface_rec.shts IS NOT NULL OR
                  c_interface_rec.sahts IS NOT NULL OR c_interface_rec.uksats IS NOT NULL OR
                  c_interface_rec.ksqts IS NOT NULL OR c_interface_rec.vceats IS NOT NULL OR
                  c_interface_rec.gceats IS NOT NULL OR c_interface_rec.vceasts IS NOT NULL OR
                  c_interface_rec.gceasts IS NOT NULL THEN
                       l_ins_tariff := TRUE;
                END IF ;

                -- check if spa hesa record needs to be updated
                IF c_interface_rec.total_ucas_tariff IS NOT NULL OR c_interface_rec.postcode IS NOT NULL OR
                   c_interface_rec.occcode IS NOT NULL THEN
                   l_upd_spa := TRUE ;
                END IF ;

             END IF ; -- import student program details

             -- If hesa code validations passed then continue with the import of person and program details
             -- else skip this record
             IF NOT l_error_flag THEN

                -- if import person details parameter is set then populate person interface tables
                IF p_pers_det = 'Y' AND l_upd_person THEN

                   -- Set flag that person import process needs to be called
                   l_call_pers_imp := TRUE ;
                   -- Populate the admission person import interface tables
                   populate_imp_int ( c_src_type_id_rec.source_type_id, l_imp_batch_id, l_org_id ,
                             c_pe_det_rec.person_id , c_interface_rec.interface_hesa_id);


                   -- Import academic history details along with person details
                   -- If institute_cd is given then create or upadate attendance history records
                   IF c_interface_rec.inst_code IS NOT NULL THEN
                        --Get the Perosn Number for the Person ID passed.
                        OPEN c_person_info(c_pe_det_rec.person_id);
                        FETCH c_person_info INTO l_person_info_rec;
                        CLOSE c_person_info;

                        --Check if there exists a Academic History record for the person and OSS Institution Code.
                        OPEN c_acad_hist(c_pe_det_rec.person_id , l_oss_inst);
                        FETCH c_acad_hist INTO l_acad_hist_rec ;

                        IF c_acad_hist%FOUND THEN
                          CLOSE c_acad_hist ;
                          --Check If there are multiple Academic History records for the person and OSS institution passed.
                          OPEN c_acad_hist_count(c_pe_det_rec.person_id , l_oss_inst);
                          FETCH c_acad_hist_count INTO l_acad_hist_count ;
                          CLOSE c_acad_hist_count ;

                          --When there are more than 1 Academic History records existing for Person and OSS Institution passed
                          IF l_acad_hist_count > 1 THEN
                            --Log a message asking users for mannual review and update
                            fnd_message.set_name('IGS','IGS_UC_ACAD_HIST_REC_EXISTS');
                            fnd_message.set_token('PERSON_NO',l_person_info_rec.person_number);
                            fnd_message.set_token('INST', l_oss_inst);
                            fnd_message.set_token('END_DT', TO_CHAR(c_interface_rec.prev_inst_left_date,'DD-MON-YYYY'));
                            fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

                          ELSE
                            --When only one Academic History record exists then Check the discrepancy rule set for Source Type "UCAS PER"
                            --  is set to "Updating Existing Values With Imported Values" or not.
                            IF  igs_ad_imp_001.find_source_cat_rule (c_src_type_id_rec.source_type_id, 'PERSON_ACADEMIC_HISTORY') <> 'I' THEN
                              --Log a message asking users for mannual review and update
                              fnd_message.set_name('IGS','IGS_UC_DSCRPNCY_RULE_NOT_SET');
                              fnd_message.set_token('PERSON_NO',l_person_info_rec.person_number);
                              fnd_message.set_token('INST', l_oss_inst);
                              fnd_message.set_token('END_DT', TO_CHAR(c_interface_rec.prev_inst_left_date,'DD-MON-YYYY'));
                              fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
                            ELSE
                              --When the discrepancy is set to import then Update the history record for the student with the date left
                              BEGIN
                                 l_return_status := NULL;
                                 l_msg_data      := NULL;
                                 Igs_Ad_Acad_History_Pkg.update_row (
                                     x_rowid                      => l_acad_hist_rec.row_id,
                                     x_attribute14                => l_acad_hist_rec.attribute14,
                                     x_attribute15                => l_acad_hist_rec.attribute15,
                                     x_attribute16                => l_acad_hist_rec.attribute16,
                                     x_attribute17                => l_acad_hist_rec.attribute17,
                                     x_attribute18                => l_acad_hist_rec.attribute18,
                                     x_attribute19                => l_acad_hist_rec.attribute19,
                                     x_attribute20                => l_acad_hist_rec.attribute20,
                                     x_attribute13                => l_acad_hist_rec.attribute13,
                                     x_attribute11                => l_acad_hist_rec.attribute11,
                                     x_attribute12                => l_acad_hist_rec.attribute12,
                                     x_education_id               => l_acad_hist_rec.Education_Id,
                                     x_person_id                  => l_acad_hist_rec.person_id,
                                     x_current_inst               => l_acad_hist_rec.current_inst,
                                     x_degree_attempted       => l_acad_hist_rec.degree_attempted,      --modified academic History LOV Build
                                     x_program_code               => l_acad_hist_rec.Program_Code,
                                     x_degree_earned          => l_acad_hist_rec.degree_earned,
                                     x_comments                   => l_acad_hist_rec.Comments,
                                     x_start_date                 => l_acad_hist_rec.Start_Date,
                                     x_end_date                   => NVL(c_interface_rec.prev_inst_left_date,l_acad_hist_rec.End_Date),
                                     x_planned_completion_date    => l_acad_hist_rec.planned_completion_date,
                                     x_recalc_total_cp_attempted  => l_acad_hist_rec.recalc_total_cp_attempted,
                                     x_recalc_total_cp_earned     => l_acad_hist_rec.recalc_total_cp_earned,
                                     x_recalc_total_unit_gp       => l_acad_hist_rec.recalc_total_unit_gp,
                                     x_recalc_tot_gpa_units_attemp=> l_acad_hist_rec.recalc_total_gpa_units_attemp,
                                     x_recalc_inst_gpa            => l_acad_hist_rec.recalc_inst_gpa,
                                     x_recalc_grading_scale_id    => l_acad_hist_rec.recalc_grading_scale_id,
                                     x_selfrep_total_cp_attempted => l_acad_hist_rec.selfrep_total_cp_attempted,
                                     x_selfrep_total_cp_earned    => l_acad_hist_rec.selfrep_total_cp_earned,
                                     x_selfrep_total_unit_gp      => l_acad_hist_rec.selfrep_total_unit_gp,
                                     x_selfrep_tot_gpa_uts_attemp => l_acad_hist_rec.selfrep_total_gpa_units_attemp,
                                     x_selfrep_inst_gpa           => l_acad_hist_rec.selfrep_inst_gpa,
                                     x_selfrep_grading_scale_id   => l_acad_hist_rec.selfrep_grading_scale_id,
                                     x_selfrep_weighted_gpa       => l_acad_hist_rec.selfrep_weighted_gpa,
                                     x_selfrep_rank_in_class      => l_acad_hist_rec.selfrep_rank_in_class,
                                     x_selfrep_weighed_rank       => l_acad_hist_rec.selfrep_weighed_rank,
                                     x_type_of_school             => l_acad_hist_rec.type_of_school,
                                     x_institution_code           => l_acad_hist_rec.institution_code,
                                     x_attribute_category         => l_acad_hist_rec.attribute_category,
                                     x_attribute1                 => l_acad_hist_rec.attribute1,
                                     x_attribute2                 => l_acad_hist_rec.attribute2,
                                     x_attribute3                 => l_acad_hist_rec.attribute3,
                                     x_attribute4                 => l_acad_hist_rec.attribute4,
                                     x_attribute5                 => l_acad_hist_rec.attribute5,
                                     x_attribute6                 => l_acad_hist_rec.attribute6,
                                     x_attribute7                 => l_acad_hist_rec.attribute7,
                                     x_attribute8                 => l_acad_hist_rec.attribute8,
                                     x_attribute9                 => l_acad_hist_rec.attribute9,
                                     x_attribute10                => l_acad_hist_rec.attribute10,
                                     x_selfrep_class_size         => l_acad_hist_rec.selfrep_class_size,
                                     x_transcript_required        => l_acad_hist_rec.transcript_required,
                                     x_object_version_number  => l_acad_hist_rec.object_version_number,
                                     x_msg_data                   => l_msg_data,
                                     x_return_status              => l_return_status,
                                     x_mode                       => 'R');

                                IF l_return_status IN ('E','U') THEN
                                   log_error('E25' ,c_interface_rec.interface_hesa_id, l_msg_data);
                                   l_error_flag := TRUE;
                                   fnd_message.set_name('IGS','IGS_HE_UPD_ATT_FAIL');
                                   fnd_file.put_line( fnd_file.LOG ,fnd_message.get ||' - '|| l_msg_data);
                                END IF;

                              EXCEPTION
                                WHEN OTHERS THEN
                                   log_error('E25' ,c_interface_rec.interface_hesa_id, l_msg_data);
                                   l_error_flag := TRUE;
                                   fnd_message.set_name('IGS','IGS_HE_UPD_ATT_FAIL');
                                   fnd_file.put_line( fnd_file.LOG ,fnd_message.get ||' - '|| l_msg_data);
                              END;

                            END IF; --End of Discrepancy Rule Check.

                          END IF;  --End of Multiple Academic History records check.

                        ELSE
                          --When there is no Academic History reocrd exists for the person and OSS Institution passed.
                          CLOSE c_acad_hist ;
                          BEGIN

                             -- Retrieve the Interface ID already created as part of Person details import.
                             l_interface_id := NULL;
                             OPEN c_adm_int_id (l_imp_batch_id, c_pe_det_rec.person_id);
                             FETCH c_adm_int_id INTO l_interface_id;
                             CLOSE c_adm_int_id;

                             l_interface_acadhis_id := NULL;
                             -- Create an Academic History interface record for this person
                             INSERT INTO igs_ad_acadhis_int_all ( interface_acadhis_id,
                                                                  interface_id,
                                                                  institution_code,
                                                                  current_inst,
                                                                  end_date,
                                                                  status,
                                                                  transcript_required,
                                                                  created_by,
                                                                  creation_date,
                                                                  last_updated_by,
                                                                  last_update_date,
                                                                  last_update_login,
                                                                  request_id,
                                                                  program_application_id,
                                                                  program_id,
                                                                  program_update_date )
                             VALUES ( igs_ad_acadhis_int_s.NEXTVAL,
                                      l_interface_id,
                                      l_oss_inst,
                                      'N',
                                      c_interface_rec.prev_inst_left_date,
                                      '2',
                                      'N',
                                      fnd_global.user_id,
                                      SYSDATE,
                                      fnd_global.user_id,
                                      SYSDATE,
                                      fnd_global.login_id,
                                      DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_request_id),
                                      DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.prog_appl_id),
                                      DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_program_id),
                                      DECODE(fnd_global.conc_request_id,-1,NULL,SYSDATE) )
                             RETURNING interface_acadhis_id INTO l_interface_acadhis_id;

                          EXCEPTION
                            WHEN OTHERS THEN
                                log_error('E24' ,c_interface_rec.interface_hesa_id, NULL);
                                l_error_flag := TRUE;
                                fnd_message.set_name('IGS','IGS_HE_INS_ATT_FAIL');
                                fnd_file.put_line( fnd_file.LOG ,fnd_message.get || ' - ' || SQLERRM);
                          END ;
                        END IF ;  -- record already exists
                   END IF ; -- end of updating or inserting attendance history records

                END IF ; -- person details to be imported

                -- if import program attempt details parameter set then import data into hesa tables
                IF p_spa_det = 'Y' THEN

                   -- If there is data to be imported into spa record then update student program attempt hesa records
                   IF l_upd_spa THEN
                     BEGIN
                       FOR c_upd_spa_rec IN c_upd_spa( c_pe_det_rec.person_id , c_interface_rec.course_cd) LOOP
                           igs_he_st_spa_all_pkg.update_row (
                                X_ROWID                   => c_upd_spa_rec.rowid ,
                                X_HESA_ST_SPA_ID          => c_upd_spa_rec.hesa_st_spa_id,
                                X_ORG_ID                  => c_upd_spa_rec.org_id,
                                X_PERSON_ID               => c_upd_spa_rec.person_id,
                                X_COURSE_CD               => c_upd_spa_rec.course_cd,
                                X_VERSION_NUMBER          => c_upd_spa_rec.version_number,
                                X_FE_STUDENT_MARKER       => c_upd_spa_rec.fe_student_marker,
                                X_DOMICILE_CD             => NVL(l_oss_domicile, c_upd_spa_rec.domicile_cd),
                                X_INST_LAST_ATTENDED      => c_upd_spa_rec.inst_last_attended,
                                X_YEAR_LEFT_LAST_INST     => c_upd_spa_rec.year_left_last_inst,
                                X_HIGHEST_QUAL_ON_ENTRY   => NVL(c_interface_rec.highest_qual_on_entry,c_upd_spa_rec.highest_qual_on_entry),
                                X_DATE_QUAL_ON_ENTRY_CALC => c_upd_spa_rec.date_qual_on_entry_calc,
                                X_A_LEVEL_POINT_SCORE     => c_upd_spa_rec.a_level_point_score,
                                X_HIGHERS_POINTS_SCORES   => c_upd_spa_rec.highers_points_scores,
                                X_OCCUPATION_CODE         => NVL(l_oss_occupation,c_upd_spa_rec.occupation_code),
                                X_COMMENCEMENT_DT         => c_upd_spa_rec.commencement_dt,
                                X_SPECIAL_STUDENT         => c_upd_spa_rec.special_student,
                                X_STUDENT_QUAL_AIM         => c_upd_spa_rec.student_qual_aim,
                                X_STUDENT_FE_QUAL_AIM     => c_upd_spa_rec.student_fe_qual_aim,
                                X_TEACHER_TRAIN_PROG_ID   => c_upd_spa_rec.teacher_train_prog_id,
                                X_ITT_PHASE               => c_upd_spa_rec.itt_phase,
                                X_BILINGUAL_ITT_MARKER    => c_upd_spa_rec.bilingual_itt_marker,
                                X_TEACHING_QUAL_GAIN_SECTOR => c_upd_spa_rec.teaching_qual_gain_sector,
                                X_TEACHING_QUAL_GAIN_SUBJ1  => c_upd_spa_rec.teaching_qual_gain_subj1,
                                X_TEACHING_QUAL_GAIN_SUBJ2  => c_upd_spa_rec.teaching_qual_gain_subj2 ,
                                X_TEACHING_QUAL_GAIN_SUBJ3  => c_upd_spa_rec.teaching_qual_gain_subj3,
                                X_STUDENT_INST_NUMBER     => c_upd_spa_rec.student_inst_number,
                                X_DESTINATION             => c_upd_spa_rec.destination,
                                X_ITT_PROG_OUTCOME        => c_upd_spa_rec.itt_prog_outcome,
                                X_HESA_RETURN_NAME        => c_upd_spa_rec.hesa_return_name,
                                X_HESA_RETURN_ID          => c_upd_spa_rec.hesa_return_id,
                                X_HESA_SUBMISSION_NAME    => c_upd_spa_rec.hesa_submission_name,
                                X_ASSOCIATE_UCAS_NUMBER   => c_upd_spa_rec.associate_ucas_number,
                                X_ASSOCIATE_SCOTT_CAND    => c_upd_spa_rec.associate_scott_cand,
                                X_ASSOCIATE_TEACH_REF_NUM => c_upd_spa_rec.associate_teach_ref_num,
                                X_ASSOCIATE_NHS_REG_NUM   => c_upd_spa_rec.associate_nhs_reg_num,
                                X_NHS_FUNDING_SOURCE      => c_upd_spa_rec.nhs_funding_source,
                                X_UFI_PLACE               => c_upd_spa_rec.ufi_place,
                                X_POSTCODE                => NVL(c_interface_rec.postcode,c_upd_spa_rec.postcode),
                                X_SOCIAL_CLASS_IND        => NVL(l_oss_social_class,c_upd_spa_rec.social_class_ind),
                                X_OCCCODE                 => NVL(c_interface_rec.occcode,c_upd_spa_rec.occcode),
                                X_TOTAL_UCAS_TARIFF       => NVL(c_interface_rec.total_ucas_tariff,c_upd_spa_rec.total_ucas_tariff),
                                X_NHS_EMPLOYER            => c_upd_spa_rec.nhs_employer,
                                X_RETURN_TYPE             => c_upd_spa_rec.return_type,
                                X_QUAL_AIM_SUBJ1          => NVL(l_oss_subj1,c_upd_spa_rec.qual_aim_subj1),
                                X_QUAL_AIM_SUBJ2          => NVL(l_oss_subj2,c_upd_spa_rec.qual_aim_subj2),
                                X_QUAL_AIM_SUBJ3          => NVL(l_oss_subj3,c_upd_spa_rec.qual_aim_subj3),
                                X_QUAL_AIM_PROPORTION     => NVL(l_oss_proportion,c_upd_spa_rec.qual_aim_proportion) ,
                                X_MODE                    => 'R',
                                X_DEPENDANTS_CD           => c_upd_spa_rec.dependants_cd ,
                                X_IMPLIED_FUND_RATE       => c_upd_spa_rec.implied_fund_rate ,
                                X_GOV_INITIATIVES_CD      => c_upd_spa_rec.gov_initiatives_cd ,
                                X_UNITS_FOR_QUAL          => c_upd_spa_rec.units_for_qual ,
                                X_DISADV_UPLIFT_ELIG_CD   => c_upd_spa_rec.disadv_uplift_elig_cd ,
                                X_FRANCH_PARTNER_CD       => c_upd_spa_rec.franch_partner_cd ,
                                X_UNITS_COMPLETED         => c_upd_spa_rec.units_completed ,
                                X_FRANCH_OUT_ARR_CD       => c_upd_spa_rec.franch_out_arr_cd ,
                                X_EMPLOYER_ROLE_CD        => c_upd_spa_rec.employer_role_cd ,
                                X_DISADV_UPLIFT_FACTOR    => c_upd_spa_rec.disadv_uplift_factor ,
                                X_ENH_FUND_ELIG_CD        => c_upd_spa_rec.enh_fund_elig_cd,
                                X_EXCLUDE_FLAG            => c_upd_spa_rec.exclude_flag
                                ) ;
                       END LOOP;
                     EXCEPTION
                        WHEN OTHERS THEN
                            log_error('E22' ,c_interface_rec.interface_hesa_id, NULL);
                            l_error_flag := TRUE;
                            fnd_message.set_name('IGS','IGS_HE_UPD_SPA_FAIL');
                            fnd_file.put_line( fnd_file.LOG ,fnd_message.get|| ' - ' || SQLERRM);
                     END ;

                   END IF ; -- end of updating spa

                   -- If tariff data is to be imported and Program attempt update has not failed then
                   -- import tariff details into oss
                   IF l_ins_tariff AND NOT l_error_flag THEN
                      BEGIN
                        -- If course cd is given in the interface record then create tariff records under that spa
                        -- If course cd is not specified then create tariff records under all the spa records for the student
                        FOR c_spa_rec IN c_spa( c_pe_det_rec.person_id , c_interface_rec.course_cd) LOOP
                           -- delete existing tariff records for the student program attempt record

                           FOR c_del_tariff_rec IN c_del_tariff(c_spa_rec.person_id, c_spa_rec.course_cd) LOOP
                             igs_he_st_spa_ut_all_pkg.delete_row( X_ROWID => c_del_tariff_rec.rowid );
                           END LOOP ;

                           -- smaddali modified the igs_he_st_spa_yt_all_pkg insert row calls for bug 2671022
                           -- to pass the OSS award code instead of the HESA UT code

                           -- If qualification GCSEAS details are given then create a ucas tariff record
                           IF c_interface_rec.gceasn IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id ,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>   l_oss_gceasn ,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.gceasn ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.gceasts ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification VCSEAS details are given then create a ucas tariff record
                           IF c_interface_rec.vceasn IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id ,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>   l_oss_vceasn ,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.vceasn ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.vceasts ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification GCSEA details are given then create a ucas tariff record
                           IF c_interface_rec.gcean IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id ,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>   l_oss_gcean ,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.gcean ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.gceats ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification VCSEA details are given then create a ucas tariff record
                           IF c_interface_rec.vcean IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id ,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>   l_oss_vcean ,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.vcean ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.vceats ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification KEYSKL details are given then create a ucas tariff record
                           IF c_interface_rec.ksqn IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>   l_oss_ksqn ,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.ksqn ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.ksqts ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification 1UNKEYSKL details are given then create a ucas tariff record
                           IF c_interface_rec.uksan IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id ,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>   l_oss_uksan,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.uksan ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.uksats ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification SCOTADH details are given then create a ucas tariff record
                           IF c_interface_rec.sahn IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id ,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>   l_oss_sahn ,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.sahn ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.sahts ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification SCOTH details are given then create a ucas tariff record
                           IF c_interface_rec.shn IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>   l_oss_shn,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.shn ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.shts ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification SCOTST details are given then create a ucas tariff record
                           IF c_interface_rec.ssgcn IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id ,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>    l_oss_ssgcn,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.ssgcn ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.ssgcts ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification SCOTI2 details are given then create a ucas tariff record
                           IF c_interface_rec.si2n IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id ,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>  l_oss_si2n ,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.si2n ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.si2ts ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification SCOTCO details are given then create a ucas tariff record
                           IF c_interface_rec.scsn IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>  l_oss_scsn ,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.scsn ,
                                X_TARIFF_SCORE                 =>  c_interface_rec.scsts ,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                           -- If qualification ADVEXT details are given then create a ucas tariff record
                           IF c_interface_rec.aean IS NOT NULL OR c_interface_rec.aeats IS NOT NULL THEN
                              l_rowid := NULL ;
                              l_hesa_st_spau_id := NULL ;
                              igs_he_st_spa_ut_all_pkg.insert_row (
                                X_ROWID                        =>  l_rowid ,
                                X_HESA_ST_SPAU_ID              =>  l_hesa_st_spau_id ,
                                X_ORG_ID                       =>  l_org_id ,
                                X_PERSON_ID                    =>  c_spa_rec.person_id ,
                                X_COURSE_CD                    =>  c_spa_rec.course_cd,
                                X_VERSION_NUMBER               =>  c_spa_rec.version_number ,
                                X_QUALIFICATION_LEVEL          =>  l_oss_aean ,
                                X_NUMBER_OF_QUAL               =>  c_interface_rec.aean,
                                X_TARIFF_SCORE                 =>  c_interface_rec.aeats,
                                X_MODE                         => 'R'
                                ) ;
                           END IF ;

                        END LOOP ;
                      EXCEPTION
                         WHEN OTHERS THEN
                            log_error('E21' ,c_interface_rec.interface_hesa_id, NULL);
                            l_error_flag := TRUE;
                            fnd_message.set_name('IGS','IGS_HE_INS_TAR_FAIL');
                            fnd_file.put_line( fnd_file.LOG ,fnd_message.get|| ' - ' || SQLERRM);
                      END ;
                   END IF ; -- end of inserting tariff records

                   -- If fee_eligibility needs to be imported and tariff creation is successful then update student unit set attempt hesa records
                   -- If unit set is given in the interface record then Update the student susa records
                   -- belonging to this unit set , else update all susa records for that student
                   IF c_interface_rec.fee_eligibility IS NOT NULL AND NOT l_error_flag THEN
                     BEGIN
                        FOR c_upd_susa_rec IN c_upd_susa(c_pe_det_rec.person_id,c_interface_rec.course_cd, c_interface_rec.unit_set_cd) LOOP
                            igs_he_en_susa_pkg.update_row(
                                 X_ROWID                        => c_upd_susa_rec.rowid ,
                                 X_HESA_EN_SUSA_ID              => c_upd_susa_rec.hesa_en_susa_id,
                                 X_PERSON_ID                    => c_upd_susa_rec.person_id ,
                                 X_COURSE_CD                    => c_upd_susa_rec.course_cd ,
                                 X_UNIT_SET_CD                  => c_upd_susa_rec.unit_set_cd ,
                                 X_US_VERSION_NUMBER            => c_upd_susa_rec.us_version_number ,
                                 X_SEQUENCE_NUMBER              => c_upd_susa_rec.sequence_number ,
                                 X_NEW_HE_ENTRANT_CD            => c_upd_susa_rec.new_he_entrant_cd ,
                                 X_TERM_TIME_ACCOM              => c_upd_susa_rec.term_time_accom ,
                                 X_DISABILITY_ALLOW             => c_upd_susa_rec.disability_allow ,
                                 X_ADDITIONAL_SUP_BAND          => c_upd_susa_rec.additional_sup_band ,
                                 X_SLDD_DISCRETE_PROV           => c_upd_susa_rec.sldd_discrete_prov ,
                                 X_STUDY_MODE                   => c_upd_susa_rec.study_mode ,
                                 X_STUDY_LOCATION               => c_upd_susa_rec.study_location ,
                                 X_FTE_PERC_OVERRIDE            => c_upd_susa_rec.fte_perc_override ,
                                 X_FRANCHISING_ACTIVITY         => c_upd_susa_rec.franchising_activity ,
                                 X_COMPLETION_STATUS            => c_upd_susa_rec.completion_status ,
                                 X_GOOD_STAND_MARKER            => c_upd_susa_rec.good_stand_marker ,
                                 X_COMPLETE_PYR_STUDY_CD        => c_upd_susa_rec.complete_pyr_study_cd ,
                                 X_CREDIT_VALUE_YOP1            => c_upd_susa_rec.credit_value_yop1 ,
                                 X_CREDIT_VALUE_YOP2            => c_upd_susa_rec.credit_value_yop2 ,
                                 X_CREDIT_VALUE_YOP3            => c_upd_susa_rec.credit_value_yop3 ,
                                 X_CREDIT_VALUE_YOP4            => c_upd_susa_rec.credit_value_yop4 ,
                                 X_CREDIT_LEVEL_ACHIEVED1       => c_upd_susa_rec.credit_level_achieved1 ,
                                 X_CREDIT_LEVEL_ACHIEVED2       => c_upd_susa_rec.credit_level_achieved2 ,
                                 X_CREDIT_LEVEL_ACHIEVED3       => c_upd_susa_rec.credit_level_achieved3 ,
                                 X_CREDIT_LEVEL_ACHIEVED4       => c_upd_susa_rec.credit_level_achieved4 ,
                                 X_CREDIT_PT_ACHIEVED1          => c_upd_susa_rec.credit_pt_achieved1 ,
                                 X_CREDIT_PT_ACHIEVED2          => c_upd_susa_rec.credit_pt_achieved2 ,
                                 X_CREDIT_PT_ACHIEVED3          => c_upd_susa_rec.credit_pt_achieved3 ,
                                 X_CREDIT_PT_ACHIEVED4          => c_upd_susa_rec.credit_pt_achieved4 ,
                                 X_CREDIT_LEVEL1                => c_upd_susa_rec.credit_level1 ,
                                 X_CREDIT_LEVEL2                => c_upd_susa_rec.credit_level2 ,
                                 X_CREDIT_LEVEL3                => c_upd_susa_rec.credit_level3 ,
                                 X_CREDIT_LEVEL4                => c_upd_susa_rec.credit_level4 ,
                                 X_ADDITIONAL_SUP_COST          => c_upd_susa_rec.additional_sup_cost,
                                 X_ENH_FUND_ELIG_CD             => c_upd_susa_rec.enh_fund_elig_cd,
                                 X_DISADV_UPLIFT_FACTOR         => c_upd_susa_rec.disadv_uplift_factor,
                                 X_YEAR_STU                     => c_upd_susa_rec.year_stu,
                                 X_GRAD_SCH_GRADE               => c_upd_susa_rec.grad_sch_grade ,
                                 X_MARK                         => c_upd_susa_rec.mark ,
                                 X_TEACHING_INST1               => c_upd_susa_rec.teaching_inst1 ,
                                 X_TEACHING_INST2               => c_upd_susa_rec.teaching_inst2 ,
                                 X_PRO_NOT_TAUGHT               => c_upd_susa_rec.pro_not_taught ,
                                 X_FUNDABILITY_CODE             => c_upd_susa_rec.fundability_code ,
                                 X_FEE_ELIGIBILITY              => l_oss_fee_elig ,
                                 X_FEE_BAND                     => c_upd_susa_rec.fee_band ,
                                 X_NON_PAYMENT_REASON           => c_upd_susa_rec.non_payment_reason ,
                                 X_STUDENT_FEE                  => c_upd_susa_rec.student_fee ,
                                 X_FTE_INTENSITY                => c_upd_susa_rec.fte_intensity ,
                                 X_CALCULATED_FTE               => c_upd_susa_rec.calculated_fte ,
                                 X_FTE_CALC_TYPE                => c_upd_susa_rec.fte_calc_type ,
                                 X_TYPE_OF_YEAR                 => c_upd_susa_rec.type_of_year ,
                                 X_MODE                         => 'R'
                                 ) ;
                        END LOOP ;
                     EXCEPTION
                        WHEN OTHERS THEN
                            log_error('E23' ,c_interface_rec.interface_hesa_id, NULL);
                            l_error_flag := TRUE;
                            fnd_message.set_name('IGS','IGS_HE_UPD_SUSA_FAIL');
                            fnd_file.put_line( fnd_file.LOG ,fnd_message.get || ' - ' || SQLERRM);
                     END;
                   END IF ; -- susa to be updated

                END IF ;  -- program details to be imported


             END IF ; -- if hesa code mapping validations pass

          END IF ; -- if course and unit set validations are passed

       END IF ; -- if person validations passed

    END LOOP ; -- loop interface records

    -- If person import tables have been populated and population of person interface tables is successful
    -- then call the import process
    IF l_call_pers_imp  THEN

        -- call the application import process to update person details ,
        -- create/update citizenship , disability,ethnic_origin,alternate person id records
        fnd_file.put_line( fnd_file.LOG ,' ');
        fnd_message.set_name('IGS','IGS_UC_ADM_IMP_PROC_LAUNCH');
        fnd_message.set_token('REQ_ID',TO_CHAR(l_imp_batch_id));
        fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
        fnd_file.put_line( fnd_file.LOG ,'-----------------------------------');
        COMMIT;
        import_process(c_src_type_id_rec.source_type_id, l_imp_batch_id, l_org_id);
        fnd_file.put_line( fnd_file.LOG ,'-----------------------------------');
        fnd_file.put_line( fnd_file.LOG ,' ');

        -- For each failed person import record create an interface error record in hesa interface error table
        FOR c_imp_int_rec IN c_imp_int  LOOP
            -- Get the person import interface record corresponding to the hesa interface record and
            -- create error record for this interface record if the import has failed for this record
            OPEN c_adm_int(l_imp_batch_id, c_imp_int_rec.person_number );
            FETCH c_adm_int INTO c_adm_int_rec ;
            IF c_adm_int%FOUND THEN
                 --Check if Admission import failed because of Academic History details.
                 OPEN c_acadhis_int(c_adm_int_rec.interface_id);
                 FETCH c_acadhis_int INTO l_interface_acadhis_id;
                 IF c_acadhis_int%FOUND THEN
                        --When Academic History import failed.
                        log_error('E36' ,c_imp_int_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                        fnd_message.set_name('IGS','IGS_HE_ACAD_HIST_IMP_FAIL');
                        fnd_message.set_token('INT_ID',c_imp_int_rec.interface_hesa_id);
                        fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
                 ELSE
                        log_error('E26' ,c_imp_int_rec.interface_hesa_id, NULL);
                        l_error_flag := TRUE;
                        fnd_message.set_name('IGS','IGS_HE_PER_IMP_FAIL');
                        fnd_message.set_token('INT_ID',c_imp_int_rec.interface_hesa_id);
                        fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
                 END IF;
                 CLOSE c_acadhis_int;
            END IF ;
            CLOSE c_adm_int ;
        END LOOP ;

    END IF ; -- if person interface records have been populated

    -- delete successfully imported interface records
    FOR c_interface_rec IN c_interface LOOP
        -- If no errors have been logged for this interface record then delete this interface record
        OPEN c_del_err(c_interface_rec.interface_hesa_id) ;
        FETCH c_del_err INTO c_del_err_rec ;
        IF c_del_err%NOTFOUND THEN
          DELETE FROM igs_he_ucas_imp_int WHERE batch_id = p_batch_id
                   AND interface_hesa_id = c_interface_rec.interface_hesa_id ;
        END IF ;
        CLOSE c_del_err ;
    END LOOP; -- deleting successful interface records

    -- delete batch definition record if all the interface records of the batch has been imported successfully
    OPEN c_interface ;
    FETCH c_interface INTO c_interface_rec ;
    IF c_interface%NOTFOUND THEN
       DELETE FROM igs_he_batch_int WHERE batch_id = p_batch_id ;
    END IF ;
    CLOSE c_interface ;

    -- Submit the Error report to show the errors generated while importing hesa interface records
    l_rep_request_id := NULL ;
    l_rep_request_id := Fnd_Request.Submit_Request
                          ( 'IGS',
                            'IGSHES02',
                             'Import HESA Student Details Error Report - Landscape',
                             NULL,
                             FALSE,
                             p_batch_id ,
                             CHR(0),
                             NULL,
                             NULL,
                             NULL ,
                             NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    IF l_rep_request_id > 0 THEN
              -- if error report successfully submitted then log message
              fnd_file.put_line( fnd_file.LOG ,' ');
              fnd_message.set_name('IGS','IGS_HE_REPSUBM');
              fnd_message.set_token('REQ_ID',TO_CHAR(l_rep_request_id));
              fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
    ELSE
              -- if error report failed to be launched then log message
              fnd_message.set_name('IGS','IGS_HE_REP_SUBM_ERR');
              fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
    END IF; -- submitted error report



  EXCEPTION
    WHEN IGS_UC_HE_NOT_ENABLED_EXCEP THEN
      -- ucas functionality is not enabled
      Errbuf          :=  fnd_message.get_string ('IGS', 'IGS_UC_HE_NOT_ENABLED');
      Retcode         := 3 ;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_HE_IMPORT_DATA.MAIN_PROCESS'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.LOG,fnd_message.get);
      Retcode := 3 ;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END main_process;

END igs_he_import_data;

/
