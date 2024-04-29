--------------------------------------------------------
--  DDL for Package Body IGS_UC_EXPORT_HESA_TO_OSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_EXPORT_HESA_TO_OSS_PKG" AS
/* $Header: IGSUC25B.pls 120.3 2006/08/21 03:52:22 jbaber noship $ */

  PROCEDURE chk_person_present (l_per_id igs_pe_person.person_id%TYPE, l_per_present OUT NOCOPY VARCHAR2) IS
  /*************************************************************
  Created By      : sowsubra
  Date Created By : 11-FEB-2002
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who          When            What
  ayedubat    31-DEC-2002   Changed the cur_person_present_in_oss to fetch the records from
                            igs_pe_person_base_v instead of igs_pe_person to improve performance
                            for bug, 2726113
  (reverse chronological order - newest change first)
  ***************************************************************/

    /* To check if the person is present in the oss tables*/
    CURSOR cur_person_present_in_oss( l_per_id IGS_PE_PERSON.person_id%TYPE) IS
        SELECT COUNT(*) n_count
        FROM  igs_pe_person_base_v
        WHERE person_id  = l_per_id;
    person_present_rec  cur_person_present_in_oss%ROWTYPE;

  BEGIN

     -- check if the person exists in OSS and set the return flag
     person_present_rec := NULL ;
     OPEN cur_person_present_in_oss(l_per_id);
     FETCH cur_person_present_in_oss INTO person_present_rec;
     IF person_present_rec.n_count = 0  THEN
        l_per_present  := 'N';
     ELSE
       l_per_present :='Y';
     END IF;
     CLOSE cur_person_present_in_oss ;

  EXCEPTION WHEN OTHERS THEN
    RAISE;
  END chk_person_present;


  PROCEDURE pre_enrollement_process( l_person_id IGS_PE_PERSON.person_id%TYPE ,l_COURSE_CD VARCHAR2 ,l_VERSION_NUMBER NUMBER) IS
  /*************************************************************
  Created By      : sowsubra
  Date Created By : 11-FEB-2002
  Purpose :

  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  p_message  VARCHAR2(100);
  p_status  NUMBER;
  retcode  NUMBER;
  errbuf  VARCHAR2(100);

  BEGIN
    -- call the Pre-enrollment process
     igs_en_hesa_pkg.hesa_stats_enr( l_person_id,l_COURSE_CD,l_VERSION_NUMBER,p_message,p_status);

  EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK;
        retcode :=p_status;
        errbuf :=p_message;
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END pre_enrollement_process;


  PROCEDURE import_process(
    p_source_type_id igs_pe_src_types_all.source_type_id%TYPE,
    p_batch_id NUMBER
  )  IS

    /******************************************************************
     Created By      :   rbezawad
     Date Created By :   22-Sep-03
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
       igs_ad_imp_001.imp_adm_data ( errbuf                      => l_errbuff,
                                     retcode                     => l_retcode ,
                                     p_batch_id                  => p_batch_id,
                                     p_source_type_id            => p_source_type_id,
                                     p_match_set_id              => match_set_rec.match_set_id,
                                     p_acad_cal_type             => NULL ,
                                     p_acad_sequence_number      => NULL ,
                                     p_adm_cal_type              => NULL ,
                                     p_adm_sequence_number       => NULL ,
                                     p_admission_cat             => NULL ,
                                     p_s_admission_process_type  => NULL ,
                                     p_interface_run_id          => l_interface_run_id ,
                                     P_org_id                    => NULL ) ;

  EXCEPTION
    WHEN OTHERS THEN
        IF cur_match_set%ISOPEN THEN
            CLOSE cur_match_set;
        END IF ;
        -- even though the admission import process completes in error , this process should continue processing
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_EXPORT_HESA_TO_OSS_PKG.IMPORT_PROCESS'||' - '||SQLERRM);
        fnd_file.put_line(fnd_file.LOG,fnd_message.get());
  END import_process;


  PROCEDURE export_data(errbuf OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY NUMBER,
                        p_person_id IGS_PE_PERSON.person_id%TYPE) IS
  /*************************************************************
  Created By      : sowsubra
  Date Created By : 11-FEB-2002
  Purpose :

  Know limitations, enhancements or remarks
  Change History (reverse chronological order - newest change first)
  Who             When            What
  --------------------------------------------------------------------------------
  smaddali 26-mar-2002  UCCR002(bug#2278817) replaced direct DML with TBH calls,
                          replaced text being written into LOG file with Message names
  smaddali 02-apr-2002  Modified the source field for social class from starh_social_class to
                          starh_socio_economic field of table igs_uc_app_stats for UCCR002 bug#2278817
                          Also changed the name of table igs_uc_attendance_history to igs_uc_attend_hist
                          and package name igs_uc_attendance_history to igs_uc_attend_hist.
                          Changed tbh calls of igs_uc_app_stats_pkg and igs_uc_applicants to add new columns
  smaddali 15-jul-02    Modified cursors to get mapped values for domicile,social_class,institution,occupation for bug 2497509
  smaddali 18-jul-02    Added cursor c_person and passing person_number instead of person_id to log messages,bug2497516
  bayadav  06-Nov-2002  Added  Columns as part of UCFD102 Build. Bug NO: 2643048
  pmarada  26-dec-02    Bug 2726132, i)Removed the igs_he_st_spa_all_pkg.update_row.
                                    ii)creating record in igs_uc_attend_hist if the record not exist else updating.
  ayedubat 31-DEC-2002  Fixed all the issues as mentioned in the bug, 2727487
  rbezawad 19-Sep-2003  Modified the process w.r.t. UCFD210 Build, Bug 2893542 to populate the Previous education details into
                             OSS Academic History and obsolete the functionality related to IGS_UC_ATTEND_HIST.
  rgangara 30-Jan-2004  Modified cur_all_applicants cursor to check for Sent_to_hesa flag from IGS_UC_APP_STATS instead of
                        IGS_UC_APPLICANTS. The Sent_to_hesa is for all practical purposes obsolete. Also removed update of
                        Applicant's.Sent_to_hesa as it is no more required as part of bug 3405245
  arvsrini    27-Jul-2004  Added code to shift the exporting ethnic code logic from IGSUC44B.pls to the current process.
                           Included logic to export ethnic details in case of the same person having multiple information coming from
                           different systems Bug#3796641
  anwest   18-JAN-2006  Bug# 4950285 R12 Disable OSS Mandate
  ***************************************************************/

    /* smaddali added  this cursor to get the person_number to display in the log file , bug 2497516 */
    CURSOR c_person ( cp_person_id igs_pe_person.person_id%TYPE ) IS
      SELECT person_number
      FROM igs_pe_person_base_v
      WHERE person_id = cp_person_id ;
    l_person_number igs_pe_person.person_number%TYPE := NULL ;

    /* cursor to select all applicants and details whose details have not been exported to HESA */
    CURSOR  cur_all_applicants(cp_person_id igs_pe_person.person_id%TYPE ) IS
      SELECT  app.app_no,
              app.app_id,
              app.oss_person_id,
              TO_CHAR(app.domicile_apr) domicile_apr,
              app.system_code,
              app.country_birth,
              stat.starh_pocc,
              stat.starh_socio_economic,
              stat.starh_pocc_edu_chg_dt
      FROM  igs_uc_applicants app, igs_uc_app_stats stat
      WHERE app.app_no = stat.app_no
        AND oss_person_id = NVL(cp_person_id, oss_person_id)
        AND stat.sent_to_hesa = 'N'
      ORDER BY app.system_code, app.app_no ;

    --Check whether the UCAS setup is defined or not for the Default prev_inst_left_date value.
    CURSOR cur_ucas_setup ( cp_person_id igs_pe_person.person_id%TYPE ) IS
      SELECT system_code
      FROM igs_uc_defaults
      WHERE prev_inst_left_date IS NULL
      AND system_code IN ( SELECT DISTINCT app.system_code
                           FROM igs_uc_applicants app, igs_uc_app_stats stat
                           WHERE app.app_no = stat.app_no
                           AND   oss_person_id = NVL(cp_person_id, oss_person_id)
                           AND   stat.sent_to_hesa = 'N' );

    -- Get the Source type ID of UCAS for admission import process
    --smaddali modified this cursor to get the source type UCAS PER instead of UCAS APPL ,bug 2724140
    CURSOR cur_src_type_id IS
    SELECT source_type_id
    FROM igs_pe_src_types_all
    WHERE source_type = 'UCAS PER'
    AND   NVL(closed_ind,'N') = 'N';

    l_src_type_id_rec cur_src_type_id%ROWTYPE;

    --Check whether the Source Category of Academic History is included within the source Type "UCAS PER" or not.
    CURSOR cur_pe_src_cat (cp_source_type_id igs_pe_src_types_all.source_type_id%TYPE,
                           cp_category  IGS_AD_SOURCE_CAT.category_name%TYPE) IS
    SELECT 'X'
    FROM  igs_ad_source_cat_v
    WHERE source_type_id = cp_source_type_id
    AND   category_name  = cp_category
    AND   include_ind    = 'Y';

    -- Cursor to find the OSS mapping values for UCAS codes
    CURSOR cur_ucas_oss_map ( cp_association_code IGS_HE_CODE_MAP_VAL.association_code%TYPE,
                              cp_map1 IGS_HE_CODE_MAP_VAL.map1%TYPE ) IS
      SELECT map2
      FROM igs_he_code_map_val
      WHERE association_code = cp_association_code
        AND map1 = cp_map1 ;

    CURSOR get_had_details (l_per_id igs_pe_person.person_id%TYPE) IS
      SELECT had.ROWID ,had.*
      FROM igs_he_ad_dtl_all had
      WHERE  person_id = l_per_id;

    CURSOR get_st_spa_details( l_per_id igs_pe_person.person_id%TYPE) IS
      SELECT course_cd, version_number
      FROM igs_he_st_spa_all hestspa
      WHERE person_id = l_per_id;

    --smaddali start ,new cursors created to remove direct DML from code
    CURSOR cur_upd_uc_appl ( p_app_id IGS_UC_APPLICANTS.app_id%TYPE) IS
    SELECT app.ROWID , app.*
    FROM igs_uc_applicants  app
    WHERE app.app_id = p_app_id ;

    CURSOR cur_upd_uc_app_stats ( p_app_id IGS_UC_APP_STATS.app_id%TYPE) IS
    SELECT apst.ROWID , apst.*
    FROM igs_uc_app_stats apst
    WHERE apst.app_id = p_app_id ;

    CURSOR cur_ad_appl_inst (p_per_id igs_pe_person.person_id%TYPE) IS
      SELECT admission_appl_number,
             nominated_course_cd,
             sequence_number
      FROM   igs_ad_ps_appl_inst_all
      WHERE  person_id = p_per_id;

    CURSOR cur_he_ad_dtl_all(p_per_id igs_pe_person.person_id%TYPE) IS
      SELECT COUNT(*)
      FROM   igs_he_ad_dtl_all
      WHERE person_id = p_per_id;

    -- Get the Batch ID for admission application import process
    CURSOR c_bat_id IS
    SELECT igs_ad_interface_batch_id_s.NEXTVAL
    FROM dual;

    -- Get the Person number for the passed person id.
    CURSOR c_person_info (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
      SELECT person_number, last_name surname, first_name given_names, gender sex, birth_date birth_dt
      FROM   igs_pe_person_base_v
      WHERE  person_id = cp_person_id;
    l_person_info_rec c_person_info%ROWTYPE;

    -- Get the admission application instance interface records whose import has failed
    CURSOR c_adm_int( cp_batch_id igs_ad_interface.batch_id%TYPE) IS
    SELECT a.person_number, a.interface_id
    FROM   igs_ad_interface a
    WHERE  a.batch_id = cp_batch_id
    AND   ( a.status IN ('2','3') OR a.record_status='3' ) ;

    -- to fetch the system code in the order U,S,N,G in case there are multiple ethnic data
    CURSOR  cur_sys_ethnic(cp_person_id igs_pe_person.person_id%TYPE ) IS
    SELECT  app.system_code,app.app_no
    FROM  igs_uc_applicants app, igs_uc_app_stats stat
    WHERE app.app_no = stat.app_no
    AND oss_person_id = cp_person_id
    ORDER BY app.system_code DESC;

    -- Get the Applicant Statistics interface records whose import has failed
    CURSOR c_stat_int (cp_interface_id igs_ad_acadhis_int_all.interface_id%TYPE) IS
    SELECT  a.*
    FROM  igs_ad_stat_int_all a
    WHERE a.interface_id = cp_interface_id
    AND   a.status = '3';
    l_interface_stat_rec c_stat_int%ROWTYPE ;

    l_imp_batch_id igs_ad_interface_all.batch_id%TYPE ;
    l_interface_id igs_ad_interface_all.interface_id%TYPE ;
    l_interface_stat_id igs_ad_stat_int_all.interface_stat_id%TYPE;
    l_chk_per_present           VARCHAR2(1) :=  'Y';
    l_col_ad_null               VARCHAR2(1) :=  'Y';
    l_col_spa_null              VARCHAR2(1) :=  'Y';
    l_dom_cd                    igs_he_ad_dtl_all.domicile_cd%TYPE;
    l_occ_code                  igs_he_ad_dtl_all.occupation_cd%TYPE;
    l_soc_code                  igs_he_ad_dtl_all.social_class_cd%TYPE;
    l_starh_pocc_edu_chg_dt     igs_uc_app_stats.starh_pocc_edu_chg_dt%TYPE;

    l_oss_religion_cd           igs_ad_stat_int.religion_cd%TYPE;
    l_oss_ethnic_origin         igs_ad_stat_int.ethnic_origin%TYPE;
    l_ethnic_cd                 igs_uc_app_stats.starh_ethnic%TYPE;
    l_max_sys_ethnic            cur_sys_ethnic%ROWTYPE;

    had_rec                     get_had_details%ROWTYPE;
    hestspa_rec                 get_st_spa_details%ROWTYPE;
    all_appl_rec                cur_all_applicants%ROWTYPE;
    l_app_stat_rec              cur_upd_uc_app_stats%ROWTYPE;

    l_rowid                     VARCHAR2(250);
    l_count NUMBER := 0;
    l_mapping_failed VARCHAR2(1) ;
    l_rec_found      VARCHAR2(1);
    l_no_setup       VARCHAR2(1);
    l_error_occurred VARCHAR2(1);
    l_stat_int_rec_populated VARCHAR2(1);
    l_return_status VARCHAR2(1);
    l_msg_data      VARCHAR2(100);

    igs_uc_he_not_enabled_excep EXCEPTION;

    -- anwest 17-FEB-2006 Bug#5034713
    l_ucas_code igs_uc_app_stats.starh_pocc%TYPE;

  BEGIN

      --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
      IGS_GE_GEN_003.SET_ORG_ID;

      /* To check if the country code profile is set  to UK  - if not  the  process should be terminated */
      IF  NOT (IGS_UC_UTILS.IS_UCAS_HESA_ENABLED) THEN
         RAISE IGS_UC_HE_NOT_ENABLED_EXCEP;
      END IF;

      --Check if any UCAS applicants exist whose HESA data hasn't been exported yet ,
      -- If not log a message and exit
      OPEN cur_all_applicants(p_person_id);
      FETCH cur_all_applicants INTO all_appl_rec;
      /* If there are no applicants with sent_to_hesa value = 'N'  then make an entry into the log file */
      IF  (cur_all_applicants%NOTFOUND) THEN

         FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.get_string('IGS','IGS_UC_HE_NO_DATA'));
         retcode:=1;
         RETURN;

      END IF;
      CLOSE  cur_all_applicants;

      --Previous Institution leaving Day/Month details must be defined in UCAS Setup for all the systems for which
      --  applications are being exported to OSS.  If the value is not defined for any of the systems an error should
      --  be recorded in the log file and the process should halt.
      l_rec_found := 'N';
      l_no_setup  := 'N';
      FOR l_ucas_setup_rec IN cur_ucas_setup(p_person_id)
      LOOP
         fnd_message.set_name('IGS','IGS_UC_SETUP_PREV_INST_DET');
         fnd_message.set_token('SYSTEM',l_ucas_setup_rec.system_code);
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         l_no_setup := 'Y';
      END LOOP;

      -- Check whether the Person Source Type 'UCAS PER' defined in the setup
      l_src_type_id_rec := NULL ;
      OPEN cur_src_type_id;
      FETCH cur_src_type_id INTO l_src_type_id_rec;
      IF cur_src_type_id%NOTFOUND THEN
        fnd_message.set_name('IGS','IGS_UC_NO_UCAS_SRC_TYP');
        fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
        l_no_setup := 'Y';
      ELSE

         -- Check the Admission Source Categories Setup included the Category. If included Populate
         -- the Interface Table, so that this record will be processed by the Admission Import Process
        OPEN cur_pe_src_cat(l_src_type_id_rec.source_type_id,'PERSON_STATISTICS');
        FETCH cur_pe_src_cat INTO l_rec_found;
        IF cur_pe_src_cat%NOTFOUND THEN
           fnd_message.set_name('IGS','IGS_UC_ADM_INT_NOT_IMP');
           fnd_message.set_token('INT_TYPE', 'STATISTIC');
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           l_no_setup := 'Y';
        END IF;
        CLOSE cur_pe_src_cat;

      END IF;
      CLOSE cur_src_type_id;

      IF l_no_setup = 'Y' THEN
         retcode:=1;
         RETURN;
      END IF;

      /* Loop through all the UCAS Applicant records whose data need to be exported */

      FOR  all_appl_rec IN cur_all_applicants(p_person_id) LOOP

          fnd_file.put_line(fnd_file.log,' ');
          /* check  if the person is present in OSS, if not then donot process the person */
          chk_person_present(all_appl_rec.oss_person_id, l_chk_per_present);
          IF (l_chk_per_present = 'N')  THEN

            FND_MESSAGE.Set_Name('IGS','IGS_UC_HE_NO_PERS');
            FND_MESSAGE.Set_Token('PERSON_ID',all_appl_rec.app_no);
            FND_FILE.PUT_LINE (FND_FILE.LOG,FND_MESSAGE.get );
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.get_string('IGS','IGS_UC_HE_NOT_PROC') );

          ELSE /*  If the person details present in OSS*/

              l_mapping_failed := 'N';

              --smaddali added this cursor to get the person_number to be shown in the log file , bug2497516
              l_person_number := NULL ;
              OPEN c_person(all_appl_rec.oss_person_id);
              FETCH c_person INTO l_person_number;
              CLOSE c_person ;

            -----------------------------------------------------------------------------------------------------------------
            /****  Find all the OSS mapping codes for the values to be exported to OSS from igs_he_code_map_val table ******/
            -----------------------------------------------------------------------------------------------------------------

              /* fetch the DOMICILE CODE for the applicant */
              l_dom_cd := NULL ;
              IF all_appl_rec.domicile_apr IS NOT NULL THEN
                OPEN cur_ucas_oss_map('UC_OSS_HE_DOM_ASSOC',all_appl_rec.domicile_apr);
                FETCH cur_ucas_oss_map INTO l_dom_cd;

                IF cur_ucas_oss_map%NOTFOUND THEN

                  FND_MESSAGE.Set_Name('IGS','IGS_UC_NO_DOM_MAPPING');
                  FND_MESSAGE.Set_Token('PERSON_ID',l_person_number);
                  FND_MESSAGE.Set_Token('CODE',all_appl_rec.domicile_apr);
                  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.get );
                  l_mapping_failed := 'Y';

                END IF ;
                CLOSE cur_ucas_oss_map;

              END IF;


              /* fetch the occupation code  for the  particular applicant */
              l_occ_code := NULL ;
              IF all_appl_rec.starh_pocc IS NOT NULL THEN

                -- anwest 17-FEB-2006 Bug#5034713
                l_ucas_code := nvl(ltrim(all_appl_rec.starh_pocc,'0'),'0');

                OPEN cur_ucas_oss_map('UC_OSS_HE_OCC_ASSOC', l_ucas_code);
                FETCH cur_ucas_oss_map INTO l_occ_code;

                IF cur_ucas_oss_map%NOTFOUND THEN

                  FND_MESSAGE.Set_Name('IGS','IGS_UC_NO_OCC_MAPPING');
                  FND_MESSAGE.Set_Token('PERSON_ID',l_person_number);
                  FND_MESSAGE.Set_Token('CODE',all_appl_rec.starh_pocc );
                  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.get );
                  l_mapping_failed := 'Y';

                END IF;
                CLOSE cur_ucas_oss_map;

              END IF ;


              /* fetch the social class code for the  particular applicant */
              l_soc_code := NULL ;
              IF all_appl_rec.starh_socio_economic IS NOT NULL THEN

                OPEN cur_ucas_oss_map('UC_OSS_HE_SOC_ASSOC',all_appl_rec.starh_socio_economic);
                FETCH cur_ucas_oss_map INTO l_soc_code;
                IF cur_ucas_oss_map%NOTFOUND THEN

                  FND_MESSAGE.Set_Name('IGS','IGS_UC_NO_SOC_MAPPING');
                  FND_MESSAGE.Set_Token('PERSON_ID',l_person_number);
                  FND_MESSAGE.Set_Token('CODE',all_appl_rec.starh_socio_economic );
                  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.get );
                  l_mapping_failed := 'Y';

                END IF ;
                CLOSE cur_ucas_oss_map;
              END IF ;

            l_max_sys_ethnic := NULL;
            OPEN cur_sys_ethnic(all_appl_rec.oss_person_id);
            FETCH cur_sys_ethnic INTO l_max_sys_ethnic;
            CLOSE cur_sys_ethnic;

            -- to process only one record in case multiple records are present for the same person
            IF all_appl_rec.system_code = l_max_sys_ethnic.system_code THEN

              -- Get the country description for the IGS_UC_APPLICANTS.COUNTRY_BIRTH column,
              -- and populate IGS_AD_STAT_INT interface table
              -- Also get the ethnic and religion code mappings from mapping table and populate it
              -- into populate IGS_AD_STAT_INT interface table as per bug 3094405
              l_app_stat_rec := NULL;
              OPEN cur_upd_uc_app_stats (all_appl_rec.app_id);
              FETCH cur_upd_uc_app_stats INTO l_app_stat_rec;
              CLOSE cur_upd_uc_app_stats;
              l_ethnic_cd := NVL(l_app_stat_rec.starh_ethnic,l_app_stat_rec.starx_ethnic);

              IF l_ethnic_cd IS NOT NULL  OR l_app_stat_rec.ivstarx_religion IS NOT NULL THEN
                l_oss_ethnic_origin := NULL;
                l_oss_religion_cd   := NULL;

                  -- Get the OSS Ethnic code mapping
                  IF l_ethnic_cd IS NOT NULL THEN
                    OPEN cur_ucas_oss_map('UC_OSS_HE_ETH_ASSOC',l_ethnic_cd);
                    FETCH cur_ucas_oss_map INTO l_oss_ethnic_origin;
                    IF cur_ucas_oss_map%NOTFOUND THEN
                      l_oss_ethnic_origin := NULL;
                      l_mapping_failed := 'Y';
                      fnd_message.set_name('IGS','IGS_UC_INV_MAPPING_VAL');
                      fnd_message.set_token('CODE',l_ethnic_cd );
                      fnd_message.set_token('TYPE','ETHNIC' );
                      fnd_file.put_line(fnd_file.log, fnd_message.get);
                    END IF;
                    CLOSE cur_ucas_oss_map;
                  END IF ;

                  -- Get the OSS Religion code mapping
                  IF l_app_stat_rec.ivstarx_religion IS NOT NULL THEN
                    OPEN cur_ucas_oss_map('OSS_HESA_RELIG_ASSOC',l_app_stat_rec.ivstarx_religion);
                    FETCH cur_ucas_oss_map INTO l_oss_religion_cd;
                    IF cur_ucas_oss_map%NOTFOUND THEN
                      l_oss_religion_cd := NULL;
                      l_mapping_failed := 'Y';
                      fnd_message.set_name('IGS','IGS_UC_INV_MAPPING_VAL');
                      fnd_message.set_token('CODE',l_app_stat_rec.ivstarx_religion );
                      fnd_message.set_token('TYPE','RELIGION' );
                      fnd_file.put_line(fnd_file.log, fnd_message.get);
                    END IF;
                    CLOSE cur_ucas_oss_map;
                  END IF;

              END IF;  --Ethnic values NOT NULL check.
            END IF;  -- checking sytem code


        /********* END of mapping the HESA codes    **************/

          IF l_mapping_failed = 'N' THEN

              /* Fetch the fields in the tables for this particular person_id and call the TBH to insert/update the  table  */
              -- check if there is a record for the passed person in igs_he_ad_dtl_all ,
              -- if not then create a new record from the corresponding OSS admission record for the person
              -- smaddali start replacing the select statement with a cursor
              l_count :=0 ;
              OPEN cur_he_ad_dtl_all(all_appl_rec.oss_person_id) ;
              FETCH cur_he_ad_dtl_all INTO l_count;
              CLOSE cur_he_ad_dtl_all ;

              IF l_count = 0 THEN

                  FOR lv_ad_appl_inst IN cur_ad_appl_inst(all_appl_rec.oss_person_id) LOOP
                      l_rowid := NULL ;
                      igs_he_ad_dtl_all_pkg.insert_row(
                           x_rowid                 => l_rowid,
                           x_org_id                => NULL,
                           x_hesa_ad_dtl_id        => l_count,
                           x_person_id             => all_appl_rec.oss_person_id,
                           x_admission_appl_number => lv_ad_appl_inst.admission_appl_number,
                           x_nominated_course_cd   => lv_ad_appl_inst.nominated_course_cd,
                           x_sequence_number       => lv_ad_appl_inst.sequence_number,
                           x_occupation_cd         => l_occ_code,
                           x_domicile_cd           => l_dom_cd,
                           x_social_class_cd       => l_soc_code,
                           x_special_student_cd    => NULL,
                           x_mode                  => 'R'  );

                  END LOOP ;

              ELSE

                  FOR had_rec IN get_had_details(all_appl_rec.oss_person_id) LOOP
                      igs_he_ad_dtl_all_pkg.update_row (
                      x_mode                       => 'R',
                      x_rowid                      => had_rec.ROWID,
                      x_org_id                     => had_rec.org_id,
                      x_hesa_ad_dtl_id             => had_rec.hesa_ad_dtl_id,
                      x_person_id                  => had_rec.person_id,
                      x_admission_appl_number      => had_rec.admission_appl_number,
                      x_nominated_course_cd        => had_rec.nominated_course_cd,
                      x_sequence_number            => had_rec.sequence_number,
                      x_occupation_cd              => NVL(l_occ_code,had_rec.occupation_cd ),
                      x_domicile_cd                => NVL(l_dom_cd,had_rec.domicile_cd ),
                      x_social_class_cd            => NVL(l_soc_code,had_rec.social_class_cd ),
                      x_special_student_cd         => had_rec.special_student_cd );

                  END LOOP ;

              END IF ;

            l_interface_id := NULL;

            --  call the pre-enrollment process to create person details, it will update/create rec in IGS_HE_ST_SPA_ALL table.
            hestspa_rec := NULL; -- initializing to NULL
            OPEN get_st_spa_details(all_appl_rec.oss_person_id);
            FETCH  get_st_spa_details INTO hestspa_rec;
            CLOSE get_st_spa_details;

            --Call to pre-enrollment
            pre_enrollement_process( all_appl_rec.oss_person_id,hestspa_rec.course_cd,hestspa_rec.version_number);

            --  l_acadhis_int_rec_populated := 'N';
            l_stat_int_rec_populated := 'N';
            l_error_occurred := 'N';


            -- Start of - Ethnic code origin processing
            -- Check if current applicant's system_code is max(system_code) among all applications of the person.
            IF all_appl_rec.system_code = l_max_sys_ethnic.system_code  THEN

              IF l_error_occurred = 'N'  AND l_oss_ethnic_origin IS NOT NULL THEN
                   OPEN c_person_info(all_appl_rec.oss_person_id);
                   FETCH c_person_info INTO l_person_info_rec;
                   CLOSE c_person_info;


                        IF l_imp_batch_id IS NULL THEN
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
                                   fnd_message.get_string('IGS','IGS_UC_IMP_ACAD_HIST_BATCH_ID'),
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
                        END IF;

                        IF l_interface_id IS NULL THEN


                          INSERT INTO igs_ad_interface(person_number,
                                                     interface_id,
                                                     batch_id,
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
                                                     last_update_login,
                                                     request_id,
                                                     program_application_id,
                                                     program_update_date,
                                                     program_id)
                        VALUES(l_person_info_rec.person_number,
                               igs_ad_interface_s.NEXTVAL,
                               l_imp_batch_id,
                               l_src_type_id_rec.source_type_id,
                               all_appl_rec.oss_person_id,
                               l_person_info_rec.surname,
                               l_person_info_rec.given_names,
                               l_person_info_rec.sex,
                               l_person_info_rec.birth_dt,
                               '1',  --status
                               '2',  --record_status,
                               '15', --Match_Ind
                               fnd_global.user_id,
                               SYSDATE,
                               fnd_global.user_id,
                               SYSDATE,
                               fnd_global.login_id,
                               DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_request_id),
                               DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.prog_appl_id),
                               DECODE(fnd_global.conc_request_id,-1,NULL,SYSDATE),
                               DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_program_id) )
                        RETURNING interface_id INTO  l_interface_id;
                       END IF;

                       l_interface_stat_id := NULL;

                       INSERT INTO igs_ad_stat_int_all (
                              interface_stat_id
                             ,interface_id
                             ,ethnic_origin
                             ,religion_cd
                             ,status
                             ,created_by
                             ,creation_date
                             ,last_updated_by
                             ,last_update_date
                             ,last_update_login )
                       VALUES(
                              IGS_AD_STAT_INT_S.NEXTVAL,
                              l_interface_id,
                              l_oss_ethnic_origin,
                              l_oss_religion_cd,
                              '2',
                              fnd_global.user_id,
                              SYSDATE,
                              fnd_global.user_id,
                              SYSDATE,
                              fnd_global.login_id )
                        RETURNING interface_stat_id INTO l_interface_stat_id;

                        l_stat_int_rec_populated := 'Y';

              END IF; -- checking l_error_code
            ELSE
                 fnd_message.set_name('IGS','IGS_UC_SYS_STAT_NOT_IMP') ;
                 fnd_message.set_token('APP_NO1',all_appl_rec.app_no);
                 fnd_message.set_token('SYS_CODE1',all_appl_rec.system_code);
                 fnd_message.set_token('APP_NO2',l_max_sys_ethnic.app_no);
                 fnd_message.set_token('SYS_CODE2',l_max_sys_ethnic.system_code);
                 fnd_message.set_token('PER_NO',l_person_number);
                 fnd_file.put_line(fnd_file.log,fnd_message.get);
            END IF; -- checking for system code



                  IF l_error_occurred = 'N' THEN

                    FOR j IN cur_upd_uc_app_stats(all_appl_rec.app_id) LOOP
                       igs_uc_app_stats_pkg.update_row(
                         X_ROWID                        => j.ROWID ,
                         X_APP_STAT_ID                  => j.app_stat_id ,
                         X_APP_ID                       => j.app_id ,
                         X_APP_NO                       => j.app_no ,
                         X_STARH_ETHNIC                 => j.starh_ethnic ,
                         X_STARH_SOCIAL_CLASS           => j.starh_social_class ,
                         X_STARH_POCC_EDU_CHG_DT        => j.starh_POCC_edu_chg_dt ,
                         X_STARH_POCC                   => j.starh_POCC ,
                         X_STARH_POCC_TEXT              => j.starh_POCC_text ,
                         X_STARH_LAST_EDU_INST          => j.starh_last_edu_inst ,
                         X_STARH_EDU_LEAVE_DATE         => j.starh_edu_leave_date ,
                         X_STARH_LEA                    => j.starh_LEA ,
                         X_STARX_ETHNIC                 => j.starx_ethnic ,
                         X_STARX_POCC_EDU_CHG           => j.starx_POCC_edu_chg ,
                         X_STARX_POCC                 => j.starx_POCC ,
                         X_STARX_POCC_TEXT            => j.starx_POCC_text ,
                         X_SENT_TO_HESA               => 'Y'     ,
                         X_MODE                       => 'R'     ,
                         -- 2-apr-2002 smaddali added these 3 new columns for UCCR002 bug#2278817
                         X_STARH_SOCIO_ECONOMIC       => j.starh_socio_economic ,
                         X_STARX_SOCIO_ECONOMIC       => j.starx_socio_economic ,
                         X_STARX_OCC_BACKGROUND       => j.starx_occ_background,
                         -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
                         x_ivstarh_dependants        => j.ivstarh_dependants,
                         x_ivstarh_married           => j.ivstarh_married,
                         x_ivstarx_religion          => j.ivstarx_religion,
                         x_ivstarx_dependants        => j.ivstarx_dependants,
                         x_ivstarx_married           => j.ivstarx_married  );

                    END LOOP;

                    IF l_stat_int_rec_populated = 'Y' THEN
                      /* Record the successful export of HESA details into Interface tables in log file */
                      fnd_message.set_name('IGS','IGS_UC_EXP_STAT_INT_SUCC') ;
                      fnd_message.set_token('PERSON_NO',l_person_number);
                      fnd_file.put_line(fnd_file.log,fnd_message.get);
                    END IF;

                    /* Record the successful export of HESA details into OSS in log file */
                    fnd_message.set_name('IGS','IGS_UC_EXP_SUCC') ;
                    fnd_message.set_token('PERSON_ID',l_person_number);
                    fnd_file.put_line(fnd_file.log,fnd_message.get);

                  END IF;  --End of l_error_occurred = 'N' check.

              END IF ; /* End mapping failed check */

          END IF;  /* End of checking, the person is present in OSS */

      END LOOP;

      -- If Academic History import interface tables have been populated
      -- then call the import process
      IF l_imp_batch_id IS NOT NULL THEN
        fnd_file.put_line( fnd_file.LOG ,' ');
        fnd_message.set_name('IGS','IGS_UC_ADM_IMP_PROC_LAUNCH');
        fnd_message.set_token('REQ_ID',TO_CHAR(l_imp_batch_id));
        fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
        fnd_file.put_line( fnd_file.LOG ,'-----------------------------------');
        COMMIT;
        --Call the import_process() procedure to launch the AD import process.
        import_process(l_src_type_id_rec.source_type_id, l_imp_batch_id);
        fnd_file.put_line( fnd_file.LOG ,'-----------------------------------');
        fnd_file.put_line( fnd_file.LOG ,' ');

        -- For each import interface record corresponding the Admissions Batch ID
        FOR l_imp_int_rec IN c_adm_int(l_imp_batch_id)  LOOP

            -- Get the Ethnic(statistic) import interface record corresponding to the interface record and
            -- log the error if the import has failed for this record
            OPEN c_stat_int(l_imp_int_rec.interface_id);
            FETCH c_stat_int INTO l_interface_stat_rec;
            IF c_stat_int%FOUND THEN
              --When Statistic import failed.
              fnd_message.set_name('IGS','IGS_UC_IMP_STAT_FAIL');
              fnd_message.set_token('PERSON_NO',l_imp_int_rec.person_number);
              fnd_message.set_token('ETHNIC',   l_interface_stat_rec.ethnic_origin);
              fnd_message.set_token('INT_ID',   l_imp_int_rec.interface_id);
              fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
            END IF;
            CLOSE c_stat_int;
        END LOOP ;

      END IF ; -- if person interface records have been populated

  EXCEPTION

     WHEN  IGS_UC_HE_NOT_ENABLED_EXCEP THEN
        retcode :=2;
        errbuf :=FND_MESSAGE.get_string('IGS','IGS_UC_HE_NOT_ENABLED');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

     WHEN OTHERS THEN
        ROLLBACK;
        retcode :=2;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'SQLERRM -> ' || SQLERRM);
        FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.Set_Token('NAME','igs_uc_export_hesa_to_oss_pkg.export_data');
        errbuf :=FND_MESSAGE.get ;
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END export_data;


END igs_uc_export_hesa_to_oss_pkg;

/
