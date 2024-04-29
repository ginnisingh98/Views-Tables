--------------------------------------------------------
--  DDL for Package Body IGS_UC_EXP_APPLICANT_DTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_EXP_APPLICANT_DTLS" AS
/* $Header: IGSUC44B.pls 120.6 2006/08/30 03:36:37 jbaber ship $  */

-- Standard WHO columns to be used across all the package
g_created_by                  NUMBER := fnd_global.user_id;
g_last_updated_by             NUMBER := g_created_by;
g_last_update_login           NUMBER := fnd_global.login_id;


PROCEDURE export_process ( errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                           p_app_no IN NUMBER,
                           p_addr_usage_home IN VARCHAR2,
                           p_addr_usage_corr IN VARCHAR2
) AS
  /******************************************************************
  Created By      : AYEDUBAT
  Date Created By : 13-JUN-2003
  Purpose         : This is the main procedure which is being called from the
                    concurrent manager to export the UCAS applicant details to OSS.
  This Process is mainly divided into 6 parts :
  1. Populating Admission Interface Tables to export Applicant Details to OSS
  2. Populating Admission Interface Tables to export Applicant  Address Details to OSS
  3. Displaying the Manual Updations required to Applicant Names Information
  4. Calling the Admission Import Process, if interface records are populated
  5. Process the Admission Interface Records for errors and
     update the UCAS Interface Tables with Sent To OSS Flag
  6. Launching Export UCAS Applicant to OSS Error Report, if any errors found
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT
  AYEDUBAT   15-JUL-03    Changed the cursor,cur_ninumber_alt_type to remove the condition,
                          ni_number_alt_pers_type IS NULL as part of Multiple Cycles Enh Bug#2669208
  AYEDUBAT   16-JUL-2003  Modified to correct the the title value of UCAS with the pre-adjucent_name in OSS
                          Added ORDER BY Clause while processing the Applications for Bug#2669208
  DSRIDHAR   25-SEP-2003  Bug No. 2980137. Added a local variable to obtain the return code from
                          pop_res_dtls_int.
  RGANGARA    10-APR-2004 bug# 3553352. Added validation to check Whether Decision Maker ID has been set for each
                          of the Systems which have atleast one Applicant record for processing.
  ANWEST      30-SEP-2004 Bug# 3642740 Added 2 new cursors and 2 FOR
              LOOPS to review and process all 'I' records
  ANWEST      25-NOV-2004 Modified for UCFD040 - Bug# 4015492 Added 2 new cursors,
              2 new data types, 6 new local variables, 1 new procedure,
                          1 more mandatory check and code logic associated with
                          person residency term
  ANWEST      21-JUL-2005 Bug# 4465994 Corrected app_no parameter
  ANWEST      18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
  JCHAKRAB    20-Feb-2006 Modified for bugs 3691220, 3691210, 3691176 - replaced existing cursors
                          cur_exp_applicant_dtls, cur_app_address_dtls, cur_app_name_dtls with REF CURSORS
                          to improve performance
  ***************************************************************** */

  -- Fetch the Source Type ID for UCAS Person from Person Source Types Table
  CURSOR cur_pe_src_types IS
    SELECT source_type_id
    FROM IGS_PE_SRC_TYPES_ALL
    WHERE source_type = 'UCAS PER'
    AND   NVL(closed_ind,'N') = 'N';

  l_src_type_id IGS_PE_SRC_TYPES_ALL.source_type_id%TYPE;

  -- Fetch the NI Number Alternate Type from UCAS Setup for NMAS System
  CURSOR cur_ninumber_alt_type IS
    SELECT name,ni_number_alt_pers_type
    FROM IGS_UC_DEFAULTS
    WHERE system_code = 'N';

  cur_ninumber_alt_type_rec cur_ninumber_alt_type%ROWTYPE;

  -- Cursors to get the Distinct Systems for the records to be selected for processing
  -- Added for bug# bug# 3553352
  CURSOR cur_chk_app_systems(cp_app_no igs_uc_applicants.app_no%TYPE ) IS
    SELECT DISTINCT system_code
    FROM   igs_uc_applicants ucap
    WHERE  ucap.app_no = NVL(cp_app_no, ucap.app_no)
      AND  NVL(ucap.sent_to_oss,'N') = 'N';

  -- Cursor to check whether decision make id is set for the sytem
  -- Added for bug# bug# 3553352
  CURSOR cur_chk_dcsn_maker_setup(cp_system_code igs_uc_defaults.system_code%TYPE) IS
    SELECT name, decision_make_id
    FROM   igs_uc_defaults
    WHERE  system_code = cp_system_code;

  chk_dcsn_maker_setup_rec cur_chk_dcsn_maker_setup%ROWTYPE ;


  -- Fetch the OSS Person Details for an UCAS Applicant
  CURSOR cur_uc_person_dtls(cp_person_id IGS_PE_PERSON.person_id%TYPE) IS
    SELECT person_id, person_number,title,
           last_name surname, first_name given_names, gender sex,
           birth_date, pre_name_adjunct
    FROM IGS_PE_PERSON_BASE_V
    WHERE person_id = cp_person_id;
  cur_uc_person_dtls_rec cur_uc_person_dtls%ROWTYPE;

  -- Fetch the OSS Person ID of an UCAS Applicant
  CURSOR cur_uc_app_dtls (cp_app_no IGS_UC_APPLICANTS.app_no%TYPE) IS
    SELECT ucap.app_no, ucap.oss_person_id, domicile_apr, ucap.country_birth
    FROM IGS_UC_APPLICANTS ucap
    WHERE ucap.app_no = cp_app_no;
  cur_uc_app_dtls_rec cur_uc_app_dtls%ROWTYPE;

  -- Fetch the Interface ID for the passed Batch ID and Person ID
  CURSOR cur_ad_interface_id ( cp_batch_id IGS_AD_INTERFACE_ALL.batch_id%TYPE,
                               cp_person_id IGS_AD_INTERFACE_ALL.person_id%TYPE) IS
    SELECT interface_id
    FROM IGS_AD_INTERFACE_ALL
    WHERE batch_id = cp_batch_id
    AND person_id = cp_person_id;

  /* Cursors used in the Export Applicant Details Logic */

  -- Cursor to fetch the Applicant Details for Update
  CURSOR cur_upd_ucas_app ( cp_app_no IGS_UC_APPLICANTS.app_no%TYPE) IS
    SELECT ucap.rowid,ucap.*
    FROM IGS_UC_APPLICANTS ucap
    WHERE ucap.app_no = cp_app_no;
  cur_ucas_app_rec cur_upd_ucas_app%ROWTYPE;


  /* Cursors used in the Export Applicant Address Details to OSS Logic  */

  -- Cursor to fetch the Applicant Address Details for Update
  CURSOR cur_upd_app_address ( cp_app_no IGS_UC_APP_ADDRESES.app_no%TYPE) IS
    SELECT ucad.rowid,ucad.*
    FROM IGS_UC_APP_ADDRESES ucad
    WHERE ucad.app_no = cp_app_no;
  cur_app_address_rec cur_upd_app_address%ROWTYPE;


  /* Cursors used in displaying Applicant Name Details to be changed manually */

  -- Cursor to fetch the Applicant Name Details for Update
  CURSOR cur_upd_app_name ( cp_app_no IGS_UC_APP_NAMES.app_no%TYPE) IS
    SELECT ucn.rowid,ucn.*
    FROM IGS_UC_APP_NAMES ucn
    WHERE ucn.app_no = cp_app_no;
  cur_app_name_rec cur_upd_app_name%ROWTYPE;

  -- Fetch the HESA Mapping value
  CURSOR cur_hesa_map (cp_assoc IGS_HE_CODE_MAP_VAL.association_code%TYPE,
                       cp_map1 IGS_HE_CODE_MAP_VAL.map2%TYPE ) IS
    SELECT map2
    FROM IGS_HE_CODE_MAP_VAL
    WHERE association_code = cp_assoc
    AND   map1  = cp_map1;
  l_oss_val IGS_HE_CODE_MAP_VAL.map2%TYPE;

  /* Cursors used to Process the Admission Interface Tables data */

  CURSOR cur_proc_applicants(cp_batch_id IGS_AD_INTERFACE_ALL.batch_id%TYPE) IS
    SELECT ucap.rowid,ucap.*
    FROM IGS_UC_APPLICANTS ucap
    WHERE ucap.ad_batch_id = cp_batch_id;

  CURSOR cur_proc_app_address(cp_batch_id IGS_AD_INTERFACE_ALL.batch_id%TYPE) IS
    SELECT ucad.rowid,ucad.*
    FROM IGS_UC_APP_ADDRESES ucad
    WHERE ucad.ad_batch_id = cp_batch_id;

  CURSOR cur_ad_interface_exist (cp_batch_id IGS_AD_INTERFACE_ALL.batch_id%TYPE,
                                 cp_interface_id IGS_AD_INTERFACE_ALL.INTERFACE_ID%TYPE) IS
    SELECT 'X'
    FROM IGS_AD_INTERFACE_ALL
    WHERE batch_id = cp_batch_id
    AND interface_id = cp_interface_id;

  -- anwest Bug# 3642740 New cursor to store UCAS applicants in error
  CURSOR cur_proc_applicants_i IS
    SELECT ucapi.rowid, ucapi.*
    FROM IGS_UC_APPLICANTS ucapi
    WHERE ucapi.sent_to_oss = 'I';

  -- anwest Bug# 3642740 New cursor to store UCAS applicant addresses in error
  CURSOR cur_proc_app_address_i IS
    SELECT ucadi.rowid, ucadi.*
    FROM IGS_UC_APP_ADDRESES ucadi
    WHERE ucadi.sent_to_oss_flag = 'I';


  /* Cursors used to retrieve the Term Calender for insertion in the Residency
    Interface Table. */

  -- anwest UCFD040 Bug# 4015492 New cursor to store maximum current cycle
  CURSOR cur_get_current_cycle IS
    SELECT max(current_cycle)
    FROM IGS_UC_DEFAULTS;
  l_max_curr_cycle IGS_UC_DEFAULTS.current_cycle%TYPE;

  -- anwest UCFD040 Bug# 4015492 New cursor to store load calender instances for UCAS
  --             system codes and cycles
  CURSOR cur_get_term(cp_entry_year igs_uc_sys_calndrs.entry_year%type) IS
      SELECT DISTINCT ucsyscal.system_code,
                      ucsyscal.entry_year,
                      cainstall.cal_type,
                      cainstall.sequence_number,
                      cainstall.start_dt
      FROM IGS_CA_INST_ALL cainstall,
           IGS_CA_INST_REL cainstrel,
           IGS_CA_TYPE catype,
           IGS_CA_STAT castat,
           IGS_UC_SYS_CALNDRS ucsyscal
      WHERE castat.s_cal_status = 'ACTIVE' and
            catype.s_cal_cat = 'LOAD' and
            cainstall.cal_status = castat.s_cal_status  and
            cainstall.cal_type = catype.cal_type and
            cainstall.cal_type = cainstrel.sub_cal_type and
            cainstrel.sub_ci_sequence_number = cainstall.sequence_number and
            cainstrel.sup_cal_type = ucsyscal.aca_cal_type and
            cainstrel.sup_ci_sequence_number = ucsyscal.aca_cal_seq_no and
            ucsyscal.entry_year <= cp_entry_year + 1 and
            ucsyscal.entry_year >= cp_entry_year - 1
      ORDER BY ucsyscal.system_code, cainstall.start_dt;

  -- anwest UCFD040 Bug# 4015492 New type to hold attributes of a cursor above
  TYPE res_term_type IS RECORD (system_code igs_uc_sys_calndrs.system_code%TYPE,
                entry_year  igs_uc_sys_calndrs.entry_year%TYPE,
                    cal_type    igs_ca_inst_all.cal_type%TYPE,
                    sequence_number igs_ca_inst_all.sequence_number%TYPE);

  -- anwest UCFD040 Bug# 4015492 New type to store multiple record types
  TYPE res_term_table_type IS TABLE OF res_term_type INDEX BY BINARY_INTEGER;

  --jchakrab added for 3691176
  TYPE applicant_record IS RECORD (
      app_no                  IGS_UC_APPLICANTS.APP_NO%TYPE,
      system_code             IGS_UC_APPLICANTS.SYSTEM_CODE%TYPE,
      oss_person_id           IGS_UC_APPLICANTS.OSS_PERSON_ID%TYPE,
      scn                     IGS_UC_APPLICANTS.SCN%TYPE,
      ni_number               IGS_UC_APPLICANTS.NI_NUMBER%TYPE,
      residential_category    IGS_UC_APPLICANTS.RESIDENTIAL_CATEGORY%TYPE,
      nationality             IGS_UC_APPLICANTS.NATIONALITY%TYPE,
      dual_nationality        IGS_UC_APPLICANTS.DUAL_NATIONALITY%TYPE,
      special_needs           IGS_UC_APPLICANTS.SPECIAL_NEEDS%TYPE,
      school                  IGS_UC_APPLICANTS.SCHOOL%TYPE,
      application_date        IGS_UC_APPLICANTS.APPLICATION_DATE%TYPE,
      country_birth           IGS_UC_APPLICANTS.COUNTRY_BIRTH%TYPE );

  TYPE t_cur_exp_applicant_dtls IS REF CURSOR RETURN applicant_record;
  cur_exp_applicant_dtls t_cur_exp_applicant_dtls;

  cur_exp_applicant_dtls_rec applicant_record;

  --jchakrab added for 3691210
  TYPE t_cur_app_address_dtls IS REF CURSOR RETURN IGS_UC_APP_ADDRESES%ROWTYPE;
  cur_app_address_dtls t_cur_app_address_dtls;

  --cur_app_address_dtls_rec app_address_record;
  cur_app_address_dtls_rec IGS_UC_APP_ADDRESES%ROWTYPE;

  --jchakrab added for 3691220
  TYPE app_name_record IS RECORD (
      app_no      IGS_UC_APP_NAMES.APP_NO%TYPE,
      title       IGS_UC_APP_NAMES.TITLE%TYPE,
      fore_names  IGS_UC_APP_NAMES.FORE_NAMES%TYPE,
      surname     IGS_UC_APP_NAMES.SURNAME%TYPE,
      birth_date  IGS_UC_APP_NAMES.BIRTH_DATE%TYPE,
      sex         IGS_UC_APP_NAMES.SEX%TYPE );

  TYPE t_cur_app_name_dtls IS REF CURSOR RETURN app_name_record;
  cur_app_name_dtls t_cur_app_name_dtls;

  cur_app_name_dtls_rec app_name_record;

  -- local variables
  l_mandatory_check BOOLEAN;
  l_app_valid_status BOOLEAN;
  l_adm_imp_status BOOLEAN;
  l_adm_error_encountered BOOLEAN;
  l_dummy VARCHAR2(1);
  l_oss_country_code  igs_he_code_map_val.map2%TYPE;

  l_rep_request_id NUMBER;
  l_sent_to_oss_flag IGS_UC_APP_NAMES.sent_to_oss_flag%TYPE;
  l_dom_text_value IGS_UC_REF_APR.dom_text%TYPE;
  l_ad_batch_id IGS_AD_IMP_BATCH_DET.batch_id%TYPE;
  l_ad_interface_id IGS_AD_INTERFACE_ALL.interface_id%TYPE;


  -- Bug No. 2980137. Variable to obtain the return code.
  l_retcode NUMBER;

  -- anwest UCFD040 Bug# 4015492 New local variables required
  l_res_term_det res_term_table_type;
  l_res_term_loc NUMBER;
  l_term_cal_type IGS_CA_INST_ALL.cal_type%TYPE;
  l_term_sequence_number IGS_CA_INST_ALL.sequence_number%TYPE;
  l_prev_system_code IGS_UC_SYS_CALNDRS.system_code%TYPE;
  l_prev_entry_year IGS_UC_SYS_CALNDRS.entry_year%TYPE;

  PROCEDURE get_term_dtls(p_app_no IN NUMBER,
            p_res_term_det IN res_term_table_type,
            p_term_cal_type OUT NOCOPY VARCHAR2,
            p_term_sequence_number OUT NOCOPY NUMBER,
            p_app_valid_status IN OUT NOCOPY BOOLEAN) IS

  /******************************************************************************
    Created By      : ANWEST
    Date Created By : 25-NOV-2004
    Purpose         : Created for UCFD040 Bug# 4015492.  Attempts to retrieve the
                  earliest Load Calender Instance from the local Table data
                  type, matching the application system code and entry year

    Known limitations,enhancements,remarks:

    CHANGE HISTORY:
     WHO        WHEN        WHAT
     anwest 20-Dec_2004 Bug# 4080259 Modified logging logic for applicants
                    without any choices
  ******************************************************************************/

    -- retrieves application system codes and entry years from their
    -- application choices
    CURSOR cur_get_syscode_entryyr(cp_app_no igs_uc_applicants.app_no%TYPE ) IS
        SELECT system_code, entry_year
            FROM IGS_UC_APP_CHOICES
            WHERE app_no = cp_app_no
            ORDER BY entry_year;

        -- local variables required
        l_appl_sys_code IGS_UC_APP_CHOICES.system_code%TYPE;
        l_appl_entry_yr IGS_UC_APP_CHOICES.entry_year%TYPE;
        l_found_term BOOLEAN;
        l_count NUMBER;

  BEGIN

    -- set local variables
    l_appl_sys_code := NULL;
        l_appl_entry_yr := NULL;
        l_found_term := FALSE;
        l_count :=  0;

          -- loop through each application choice of an applicant
        FOR cur_get_syscode_entryyr_rec IN cur_get_syscode_entryyr(p_app_no) LOOP

            l_count := l_count + 1;
            l_appl_sys_code :=  cur_get_syscode_entryyr_rec.system_code;
            l_appl_entry_yr := cur_get_syscode_entryyr_rec.entry_year;

            -- loop through the collection looking for a match
        FOR l_loc IN p_res_term_det.FIRST..p_res_term_det.LAST LOOP

            -- if a match is found set the OUT parameters
            -- and exit this loop
            IF p_res_term_det(l_loc).system_code = l_appl_sys_code AND
                p_res_term_det(l_loc).entry_year = l_appl_entry_yr THEN

                p_term_cal_type := p_res_term_det(l_loc).cal_type;
                p_term_sequence_number := p_res_term_det(l_loc).sequence_number;
                l_found_term := TRUE;
                EXIT;

            END IF;

            END LOOP;

            -- and then exit this loop as well
            IF l_found_term THEN
                EXIT;
            END IF;

        END LOOP;

        -- anwest Bug# 4080259 Moved logging of this error message to outside
        --             FOR LOOP to catch applicants without any choices
        IF l_count = 0 THEN
            fnd_file.put_line( fnd_file.LOG ,' ');
        fnd_message.set_name('IGS','IGS_UC_APPNO_NOT_FOUND');
        fnd_message.set_token('APP_NO', p_app_no);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
        ELSIF p_term_cal_type IS NULL OR p_term_sequence_number IS NULL THEN
            fnd_file.put_line( fnd_file.LOG ,' ');
        fnd_message.set_name('IGS','IGS_UC_NO_TERM_CAL');
        fnd_message.set_token('APP_NO', p_app_no);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        END IF;

  EXCEPTION

    WHEN OTHERS THEN
            p_app_valid_status := FALSE;
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGS_UC_EXP_APPLICANT_DTLS.GET_TERM_DTLS'||' - '||SQLERRM);
            fnd_file.put_line(fnd_file.LOG,fnd_message.get());

  END get_term_dtls;


BEGIN

  --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
  IGS_GE_GEN_003.SET_ORG_ID;

  -- inititalize concurrent manager variables
  errbuf := NULL;
  retcode := 0;

  /* Validate parameters before starting the processing */
  IF p_addr_usage_home IS NULL AND p_addr_usage_corr = 'HOME' THEN
      fnd_message.set_name('IGS','IGS_UC_ADDR_USAGE_CORR');
      errbuf := fnd_message.get;
      fnd_file.put_line(fnd_file.LOG,errbuf);
      retcode := 2 ;
      RETURN;
  ELSIF p_addr_usage_corr IS NULL AND p_addr_usage_home = 'CORR' THEN
      fnd_message.set_name('IGS','IGS_UC_ADDR_USAGE_HOME');
      errbuf := fnd_message.get;
      fnd_file.put_line(fnd_file.LOG,errbuf);
      retcode := 2 ;
      RETURN;
  ELSIF p_addr_usage_corr = p_addr_usage_home THEN
      fnd_message.set_name('IGS','IGS_UC_ADDR_USAGE_SAME');
      errbuf := fnd_message.get;
      fnd_file.put_line(fnd_file.LOG,errbuf);
      retcode := 2 ;
      RETURN;
  END IF;


  /* Check the mandatory validations before starting the processing
     If any one of them are not satisfied then log message and exit the processing */
  l_mandatory_check := TRUE;

  -- Check whether the Person Source Type 'UCAS PER' defined in the setup
  OPEN cur_pe_src_types;
  FETCH cur_pe_src_types INTO l_src_type_id;
  IF cur_pe_src_types%NOTFOUND THEN

    fnd_file.put_line( fnd_file.LOG ,' ');
    fnd_message.set_name('IGS','IGS_UC_NO_UCAS_SRC_TYP');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    l_mandatory_check := FALSE;

  END IF;
  CLOSE cur_pe_src_types;

  -- Check whether the NMAS System is defined and NI Number Person ID Type
  -- is not defined in UCAS Setup for NMAS System
  OPEN cur_ninumber_alt_type;
  FETCH cur_ninumber_alt_type INTO cur_ninumber_alt_type_rec ;
  IF cur_ninumber_alt_type%FOUND AND cur_ninumber_alt_type_rec.ni_number_alt_pers_type IS NULL THEN

    fnd_file.put_line( fnd_file.LOG ,' ');
    fnd_message.set_name('IGS','IGS_UC_NI_TYPE_NOT_SET');
    fnd_message.set_token('SYSTEM_NAME', cur_ninumber_alt_type_rec.name);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    l_mandatory_check := FALSE;

  END IF;
  CLOSE cur_ninumber_alt_type;

  -- Check whether the Residency Class Profile is defined for Residency Category import
  IF fnd_profile.value('IGS_FI_RES_CLASS_ID') IS NULL THEN

    fnd_file.put_line( fnd_file.LOG ,' ');
    fnd_message.set_name('IGS','IGS_UC_RES_CLASS_NOT_DEF');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    l_mandatory_check := FALSE;

  END IF;

  -- Check Whether Decision Maker ID has been set for each of the Systems which have atleast
  -- one Applicant record for processing. Added the code as part of bug# 3553352
  FOR chk_app_systems_rec IN cur_chk_app_systems(p_app_no)
  LOOP

    OPEN cur_chk_dcsn_maker_setup(chk_app_systems_rec.system_code);
    FETCH cur_chk_dcsn_maker_setup INTO chk_dcsn_maker_setup_rec;
    CLOSE cur_chk_dcsn_maker_setup;

    IF chk_dcsn_maker_setup_rec.decision_make_id IS NULL THEN
       fnd_message.set_name('IGS','IGS_UC_SETUP_DEC_MAKE');
       fnd_message.set_token('SYSTEM', chk_dcsn_maker_setup_rec.name );
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       l_mandatory_check := FALSE;
    END IF;

  END LOOP;

  -- anwest UCFD040 Bug# 4015492 New mandatory check
  -- Check whether there is at least one current cycle for any system code present
  -- If there is, check whether any term/load calenders can be retrieved for that year
  -- If it does, populate the Table data type for quick lookup later when populating
  -- residency term

  OPEN cur_get_current_cycle;
  FETCH cur_get_current_cycle INTO l_max_curr_cycle;

  IF cur_get_current_cycle%NOTFOUND OR
    l_max_curr_cycle IS NULL THEN

    CLOSE cur_get_current_cycle;
        fnd_file.put_line(fnd_file.LOG ,' ');
    fnd_message.set_name('IGS','IGS_UC_CYCLE_NOT_FOUND');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    l_mandatory_check := FALSE;

  ELSE

    CLOSE cur_get_current_cycle;
    l_res_term_loc := 0;

    FOR cur_get_term_rec IN cur_get_term(l_max_curr_cycle - 2000) LOOP

        IF (l_prev_system_code IS NULL AND l_prev_entry_year IS NULL) OR
            (cur_get_term_rec.system_code <> l_prev_system_code) OR
            (cur_get_term_rec.entry_year <> l_prev_entry_year) THEN

                l_res_term_det(l_res_term_loc).system_code := cur_get_term_rec.system_code;
                l_res_term_det(l_res_term_loc).entry_year := cur_get_term_rec.entry_year;
                l_res_term_det(l_res_term_loc).cal_type := cur_get_term_rec.cal_type;
                l_res_term_det(l_res_term_loc).sequence_number := cur_get_term_rec.sequence_number;
                l_prev_system_code := cur_get_term_rec.system_code;
                l_prev_entry_year := cur_get_term_rec.entry_year;
                    l_res_term_loc := l_res_term_loc + 1;

            END IF;

        END LOOP;

    IF l_res_term_loc = 0 THEN

        fnd_file.put_line(fnd_file.LOG ,' ');
        fnd_message.set_name('IGS','IGS_UC_NO_LOAD_CAL_FOUND');
        fnd_message.set_token('PREV_CYCLE', l_max_curr_cycle - 1);
        fnd_message.set_token('CURR_CYCLE', l_max_curr_cycle);
        fnd_message.set_token('NEXT_CYCLE', l_max_curr_cycle + 1);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
            l_mandatory_check := FALSE;

        END IF;

  END IF;


  -- If any of the Mandatory Validations are failed then exit the processing
  IF l_mandatory_check = FALSE THEN
    retcode := 2 ;
    RETURN;
  END IF;

  /******** End mandatory checks */


  /******** Populating the Admission Interface Tables to export Applicant Details to OSS  *********/

  -- Initialize the Batch ID to NULL
  l_ad_batch_id := NULL;

  -- Log the message 'Exporting Applicant details to OSS' with TimeStamp
  fnd_message.set_name('IGS','IGS_UC_EXP_APPLCNT_DET');
  fnd_file.put_line(fnd_file.log, fnd_message.get||'  ('||to_char(SYSDATE,'DD-MON-YYYY HH:MI:SS')||')');
  fnd_file.put_line( fnd_file.LOG ,' ');

  --jchakrab added for 3691176
  IF p_app_no IS NULL THEN
    OPEN cur_exp_applicant_dtls FOR
      SELECT APP_NO, SYSTEM_CODE, OSS_PERSON_ID, SCN, NI_NUMBER, RESIDENTIAL_CATEGORY,
             NATIONALITY, DUAL_NATIONALITY, SPECIAL_NEEDS, SCHOOL, APPLICATION_DATE,
             COUNTRY_BIRTH
      FROM IGS_UC_APPLICANTS UCAP
      WHERE UCAP.SENT_TO_OSS = 'N'
      ORDER BY UCAP.APP_NO;

  ELSE
    OPEN cur_exp_applicant_dtls FOR
      SELECT APP_NO, SYSTEM_CODE, OSS_PERSON_ID, SCN, NI_NUMBER, RESIDENTIAL_CATEGORY,
             NATIONALITY, DUAL_NATIONALITY, SPECIAL_NEEDS, SCHOOL, APPLICATION_DATE,
             COUNTRY_BIRTH
      FROM IGS_UC_APPLICANTS UCAP
      WHERE UCAP.APP_NO = p_app_no AND
            UCAP.SENT_TO_OSS = 'N'
      ORDER BY UCAP.APP_NO;
  END IF;


  -- Loop through all the records in IGS_UC_APPLICANTS table satisfying the criteria,
  -- SENT_TO_OSS is N and passed parameter,P_APP_NO
  LOOP
    FETCH cur_exp_applicant_dtls INTO cur_exp_applicant_dtls_rec;
    EXIT WHEN cur_exp_applicant_dtls%NOTFOUND;

    -- Check whether the OSS Person ID value is populated for this Applicant
    -- If OSS Person ID is null then log the message and stop processing the current applicant
    IF cur_exp_applicant_dtls_rec.oss_person_id is NULL THEN

      -- Log the message 'OSS Person ID is not populated for the Application Number'
      fnd_message.set_name('IGS','IGS_UC_APP_PER_ID_NOT_EXITS');
      fnd_message.set_token('APP_NO',cur_exp_applicant_dtls_rec.app_no);
      fnd_file.put_line(fnd_file.log, fnd_message.get);

    ELSE

      -- get the Applicant Person Details in OSS
      cur_uc_person_dtls_rec := NULL;
      OPEN cur_uc_person_dtls(cur_exp_applicant_dtls_rec.oss_person_id);
      FETCH cur_uc_person_dtls INTO cur_uc_person_dtls_rec;
      CLOSE cur_uc_person_dtls;

      -- Log the message 'Processing the Applicant with Person Number: XXX and Application Number: XXX'
      fnd_message.set_name('IGS','IGS_UC_EXP_APP_DET_PROC');
      fnd_message.set_token('PER_NO',cur_uc_person_dtls_rec.person_number);
      fnd_message.set_token('APP_NO',cur_exp_applicant_dtls_rec.app_no);
      fnd_file.put_line(fnd_file.log, fnd_message.get);

      -- If the Batch ID is already generated use the same,
      -- otherwise create the new Batch ID ( i.e. for First Time)
      IF l_ad_batch_id IS NULL THEN

        -- Fetch the Batch ID from the Sequence, IGS_AD_INTERFACE_BATCH_ID_S and
        -- populate the admission interface batch  table
        INSERT INTO igs_ad_imp_batch_det (
          batch_id,
          batch_desc,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          request_id,
          program_application_id,
          program_update_date,
          program_id )
        VALUES (
          IGS_AD_INTERFACE_BATCH_ID_S.NEXTVAL,
          fnd_message.get_string('IGS','IGS_UC_IMP_FROM_UCAS_BATCH_ID'),
          g_created_by,
          SYSDATE,
          g_last_updated_by,
          SYSDATE,
          g_last_update_login,
          DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_request_id),
          DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.prog_appl_id),
          DECODE(fnd_global.conc_request_id,-1,NULL,SYSDATE),
          DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_program_id) )
        RETURNING batch_id INTO l_ad_batch_id;

      END IF;

      -- create the save point, l_exp_curr_applicant
      SAVEPOINT l_exp_curr_applicant;

      -- Initialize the Applicant valid status to TRUE
      l_app_valid_status := TRUE;

      /* Populate the IGS_AD_INTERFACE_ALL table with Interface ID, Batch ID, Source Type ID,Person ID,
         match_ind as "15" and person details */

      -- Check if a record exists in IGS_AD_INTERFACE_ALL for the Admissions Batch ID and Person ID
      -- If exists use the same ID( that is If same person was processed earlier for some other
      -- UCAS system Application), otherwise create a new Interface ID
      l_ad_interface_id := NULL;

      OPEN cur_ad_interface_id(l_ad_batch_id, cur_exp_applicant_dtls_rec.oss_person_id);
      FETCH cur_ad_interface_id INTO l_ad_interface_id;
      CLOSE cur_ad_interface_id;

      IF l_ad_interface_id IS NULL THEN

        -- Get OSS country code
        l_oss_country_code := NULL;
        OPEN cur_hesa_map('UCAS_OSS_COUNTRY_ASSOC',cur_exp_applicant_dtls_rec.country_birth);
        FETCH cur_hesa_map INTO l_oss_country_code;
        CLOSE cur_hesa_map;

        -- Log a warning if country code exists but OSS mapping doesn't
        IF l_oss_country_code IS NULL AND cur_exp_applicant_dtls_rec.country_birth IS NOT NULL THEN
            fnd_message.set_name('IGS','IGS_UC_INV_COUNTRY_MAP');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
        END IF;

        INSERT INTO igs_ad_interface_all (
          interface_id,
          batch_id,
          source_type_id,
          person_id,
          match_ind,
          surname,
          given_names,
          sex,
          birth_dt,
          pre_name_adjunct,
          status,
          record_status,
          pref_alternate_id,
          birth_country,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login )
        VALUES (
          IGS_AD_INTERFACE_S.NEXTVAL,
          l_ad_batch_id,
          l_src_type_id,
          cur_uc_person_dtls_rec.person_id,
          '15',
          cur_uc_person_dtls_rec.surname,
          cur_uc_person_dtls_rec.given_names,
          cur_uc_person_dtls_rec.sex,
          cur_uc_person_dtls_rec.birth_date,
          cur_uc_person_dtls_rec.pre_name_adjunct,
          '2',
          '2',
          NULL,
          l_oss_country_code,
          g_created_by,
          SYSDATE,
          g_last_updated_by,
          SYSDATE,
          g_last_update_login )
        RETURNING interface_id INTO l_ad_interface_id ;

      END IF;

      -- Check the Admission Source Categories Setup included Alternate Person Type Category.
      --  If included Populate the Interface Table,
      --  so that this record will be processed by the Admission Import Process
      IF cur_exp_applicant_dtls_rec.ni_number IS NOT NULL OR cur_exp_applicant_dtls_rec.scn IS NOT NULL THEN

        IF chk_src_cat(l_src_type_id, 'PERSON_ID_TYPES') THEN

          -- Call the procedure to populate the Alternate Person ID interface table for NI NUMBER
          pop_api_int ( cur_exp_applicant_dtls_rec.ni_number,
                        cur_ninumber_alt_type_rec.ni_number_alt_pers_type,
                        cur_exp_applicant_dtls_rec.scn,
                        cur_exp_applicant_dtls_rec.oss_person_id,
                        l_ad_interface_id, l_app_valid_status);
        ELSE

          -- Display the warning message in the log file
          fnd_message.set_name('IGS','IGS_UC_ADM_INT_NOT_IMP');
          fnd_message.set_token('INT_TYPE', 'ALTERNATE PERSON ID');
          fnd_file.put_line(fnd_file.log, fnd_message.get);

        END IF;

      END IF;

      -- Check the Admission Source Categories Setup included Residential Ctaegory Category.
      --  If included Populate the Interface Table,
      --  so that this record will be processed by the Admission Import Process
      IF cur_exp_applicant_dtls_rec.residential_category IS NOT NULL THEN

        IF chk_src_cat(l_src_type_id,'PERSON_RESIDENCY_DETAILS') THEN

            -- anwest UCFD040 Bug# 4015492 New logic to retrieve Load Calender
            --             before populating IGS_PE_RES_DTLS_INT

            l_term_cal_type := NULL;
            l_term_sequence_number := NULL;

            -- retrieve the CAL_TYPE and SEQUENCE_NUMBER from the user
            -- defined Table type for this application
            -- anwest 21-Jul-2005 Bug# 4465994 Corrected app_no parameter
            get_term_dtls(cur_exp_applicant_dtls_rec.app_no,
                          l_res_term_det, l_term_cal_type,
                          l_term_sequence_number,
                          l_app_valid_status);

            -- anwest Bug# 4080259 Moved logging of error messages to
            --             get_term_dtls procedure
            -- if they exist, populate the interface table
            IF l_term_cal_type IS NOT NULL AND
            l_term_sequence_number IS NOT NULL THEN

            pop_res_dtls_int(cur_exp_applicant_dtls_rec.residential_category,
                                    cur_exp_applicant_dtls_rec.application_date,
                                    cur_exp_applicant_dtls_rec.system_code,
                        l_ad_interface_id,
                        l_term_cal_type, -- anwest UCFD040 Bug# 4015492 Added new parameter
                        l_term_sequence_number, -- anwest UCFD040 Bug# 4015492 Added new parameter
                        l_app_valid_status);
            END IF;

        ELSE

            -- Display the warning message in the log file
            fnd_message.set_name('IGS','IGS_UC_ADM_INT_NOT_IMP');
            fnd_message.set_token('INT_TYPE', 'RESIDENCY');
            fnd_file.put_line(fnd_file.log, fnd_message.get);

        END IF;

      END IF;

      -- Check the Admission Source Categories Setup included International Details Category.
      --  If included Populate the Interface Table,
      --  so that this record will be processed by the Admission Import Process
      IF cur_exp_applicant_dtls_rec.nationality IS NOT NULL OR cur_exp_applicant_dtls_rec.dual_nationality IS NOT NULL THEN

        IF chk_src_cat(l_src_type_id,'PERSON_INTERNATIONAL_DETAILS') THEN

          -- Call the procedure to populate the Nationality  and Dual Nationality details
          pop_citizen_int(cur_exp_applicant_dtls_rec.nationality,
                          cur_exp_applicant_dtls_rec.dual_nationality,
                          cur_exp_applicant_dtls_rec.oss_person_id,
                          cur_exp_applicant_dtls_rec.application_date,
                          l_ad_interface_id, l_app_valid_status);
        ELSE

          -- Display the warning message in the log file
          fnd_message.set_name('IGS','IGS_UC_ADM_INT_NOT_IMP');
          fnd_message.set_token('INT_TYPE', 'INTERNATIONAL');
          fnd_file.put_line(fnd_file.log, fnd_message.get);

        END IF;

      END IF;

      -- Check the Admission Source Categories Setup included Special Needs Category.
      --  If included Populate the Interface Table,
      --  so that this record will be processed by the Admission Import Process
      IF cur_exp_applicant_dtls_rec.special_needs IS NOT NULL THEN

        IF chk_src_cat(l_src_type_id,'PERSON_SPECIAL_NEEDS') THEN
          -- Call the procedure to populate the Special Needs
          pop_disability_int(cur_exp_applicant_dtls_rec.special_needs,
                             cur_exp_applicant_dtls_rec.oss_person_id,
                             cur_exp_applicant_dtls_rec.application_date,
                             l_ad_interface_id, l_app_valid_status);
        ELSE

          -- Display the warning message in the log file
          fnd_message.set_name('IGS','IGS_UC_ADM_INT_NOT_IMP');
          fnd_message.set_token('INT_TYPE', 'SPECIAL NEEDS');
          fnd_file.put_line(fnd_file.log, fnd_message.get);

        END IF;

      END IF;

      -- Check the Admission Source Categories Setup included Academic History Category
      --  If included Populate the Interface Table,
      --  so that this record will be processed by the Admission Import Process
      IF cur_exp_applicant_dtls_rec.school IS NOT NULL THEN

        IF chk_src_cat(l_src_type_id,'PERSON_ACADEMIC_HISTORY') THEN

          -- Call the procedure to populate the academic history
          pop_acad_hist_int(cur_exp_applicant_dtls_rec.oss_person_id,
                            cur_uc_person_dtls_rec.person_number,
                            cur_exp_applicant_dtls_rec.school,
                            l_ad_interface_id,
                            l_app_valid_status);
        ELSE
          -- Display the warning message in the log file
          fnd_message.set_name('IGS','IGS_UC_ADM_INT_NOT_IMP');
          fnd_message.set_token('INT_TYPE', 'ACADEMIC HISTORY');
          fnd_file.put_line(fnd_file.log, fnd_message.get);

        END IF;


      END IF;

      IF l_app_valid_status = FALSE THEN

        -- Delete all the entries for the current applicant from interface tables
        -- except the batch Table since the batch_id is same for all Applicants
        -- i.e. roll back upto to l_exp_curr_applicant
        ROLLBACK TO l_exp_curr_applicant;

      ELSE

        cur_ucas_app_rec := NULL;
        OPEN cur_upd_ucas_app (cur_exp_applicant_dtls_rec.app_no);
        FETCH cur_upd_ucas_app INTO cur_ucas_app_rec;
        CLOSE cur_upd_ucas_app;

        -- Update the UCAS Applicants Table with Batch ID and Interface ID
        igs_uc_applicants_pkg.update_row (
          x_rowid                         => cur_ucas_app_rec.rowid
          ,x_app_id                       => cur_ucas_app_rec.app_id
          ,x_app_no                       => cur_ucas_app_rec.app_no
          ,x_check_digit                  => cur_ucas_app_rec.check_digit
          ,x_personal_id                  => cur_ucas_app_rec.personal_id
          ,x_enquiry_no                   => cur_ucas_app_rec.enquiry_no
          ,x_oss_person_id                => cur_ucas_app_rec.oss_person_id
          ,x_application_source           => cur_ucas_app_rec.application_source
          ,x_name_change_date             => cur_ucas_app_rec.name_change_date
          ,x_student_support              => cur_ucas_app_rec.student_support
          ,x_address_area                 => cur_ucas_app_rec.address_area
          ,x_application_date             => cur_ucas_app_rec.application_date
          ,x_application_sent_date        => cur_ucas_app_rec.application_sent_date
          ,x_application_sent_run         => cur_ucas_app_rec.application_sent_run
          ,x_lea_code                     => cur_ucas_app_rec.lea_code
          ,x_fee_payer_code               => cur_ucas_app_rec.fee_payer_code
          ,x_fee_text                     => cur_ucas_app_rec.fee_text
          ,x_domicile_apr                 => cur_ucas_app_rec.domicile_apr
          ,x_code_changed_date            => cur_ucas_app_rec.code_changed_date
          ,x_school                       => cur_ucas_app_rec.school
          ,x_withdrawn                    => cur_ucas_app_rec.withdrawn
          ,x_withdrawn_date               => cur_ucas_app_rec.withdrawn_date
          ,x_rel_to_clear_reason          => cur_ucas_app_rec.rel_to_clear_reason
          ,x_route_b                      => cur_ucas_app_rec.route_b
          ,x_exam_change_date             => cur_ucas_app_rec.exam_change_date
          ,x_a_levels                     => cur_ucas_app_rec.a_levels
          ,x_as_levels                    => cur_ucas_app_rec.as_levels
          ,x_highers                      => cur_ucas_app_rec.highers
          ,x_csys                         => cur_ucas_app_rec.csys
          ,x_winter                       => cur_ucas_app_rec.winter
          ,x_previous                     => cur_ucas_app_rec.previous
          ,x_gnvq                         => cur_ucas_app_rec.gnvq
          ,x_btec                         => cur_ucas_app_rec.btec
          ,x_ilc                          => cur_ucas_app_rec.ilc
          ,x_ailc                         => cur_ucas_app_rec.ailc
          ,x_ib                           => cur_ucas_app_rec.ib
          ,x_manual                       => cur_ucas_app_rec.manual
          ,x_reg_num                      => cur_ucas_app_rec.reg_num
          ,x_oeq                          => cur_ucas_app_rec.oeq
          ,x_eas                          => cur_ucas_app_rec.eas
          ,x_roa                          => cur_ucas_app_rec.roa
          ,x_status                       => cur_ucas_app_rec.status
          ,x_firm_now                     => cur_ucas_app_rec.firm_now
          ,x_firm_reply                   => cur_ucas_app_rec.firm_reply
          ,x_insurance_reply              => cur_ucas_app_rec.insurance_reply
          ,x_conf_hist_firm_reply         => cur_ucas_app_rec.conf_hist_firm_reply
          ,x_conf_hist_ins_reply          => cur_ucas_app_rec.conf_hist_ins_reply
          ,x_residential_category         => cur_ucas_app_rec.residential_category
          ,x_personal_statement           => cur_ucas_app_rec.personal_statement
          ,x_match_prev                   => cur_ucas_app_rec.match_prev
          ,x_match_prev_date              => cur_ucas_app_rec.match_prev_date
          ,x_match_winter                 => cur_ucas_app_rec.match_winter
          ,x_match_summer                 => cur_ucas_app_rec.match_summer
          ,x_gnvq_date                    => cur_ucas_app_rec.gnvq_date
          ,x_ib_date                      => cur_ucas_app_rec.ib_date
          ,x_ilc_date                     => cur_ucas_app_rec.ilc_date
          ,x_ailc_date                    => cur_ucas_app_rec.ailc_date
          ,x_gcseqa_date                  => cur_ucas_app_rec.gcseqa_date
          ,x_uk_entry_date                => cur_ucas_app_rec.uk_entry_date
          ,x_prev_surname                 => cur_ucas_app_rec.prev_surname
          ,x_criminal_convictions         => cur_ucas_app_rec.criminal_convictions
          ,x_sent_to_hesa                 => cur_ucas_app_rec.sent_to_hesa
          ,x_sent_to_oss                  => cur_ucas_app_rec.sent_to_oss
          ,x_batch_identifier             => cur_ucas_app_rec.batch_identifier
          ,x_mode                         => 'R'
          ,x_gce                          => cur_ucas_app_rec.gce
          ,x_vce                          => cur_ucas_app_rec.vce
          ,x_sqa                          => cur_ucas_app_rec.sqa
          ,x_previousas                   => cur_ucas_app_rec.previousas
          ,x_keyskills                    => cur_ucas_app_rec.keyskills
          ,x_vocational                   => cur_ucas_app_rec.vocational
          ,x_scn                          => cur_ucas_app_rec.scn
          ,x_prevoeq                      => cur_ucas_app_rec.prevoeq
          ,x_choices_transparent_ind      => cur_ucas_app_rec.choices_transparent_ind
          ,x_extra_status                 => cur_ucas_app_rec.extra_status
          ,x_extra_passport_no            => cur_ucas_app_rec.extra_passport_no
          ,x_request_app_dets_ind         => cur_ucas_app_rec.request_app_dets_ind
          ,x_request_copy_app_frm_ind     => cur_ucas_app_rec.request_copy_app_frm_ind
          ,x_cef_no                       => cur_ucas_app_rec.cef_no
          ,x_system_code                  => cur_ucas_app_rec.system_code
          ,x_gcse_eng                     => cur_ucas_app_rec.gcse_eng
          ,x_gcse_math                    => cur_ucas_app_rec.gcse_math
          ,x_degree_subject               => cur_ucas_app_rec.degree_subject
          ,x_degree_status                => cur_ucas_app_rec.degree_status
          ,x_degree_class                 => cur_ucas_app_rec.degree_class
          ,x_gcse_sci                     => cur_ucas_app_rec.gcse_sci
          ,x_welshspeaker                 => cur_ucas_app_rec.welshspeaker
          ,x_ni_number                    => cur_ucas_app_rec.ni_number
          ,x_earliest_start               => cur_ucas_app_rec.earliest_start
          ,x_near_inst                    => cur_ucas_app_rec.near_inst
          ,x_pref_reg                     => cur_ucas_app_rec.pref_reg
          ,x_qual_eng                     => cur_ucas_app_rec.qual_eng
          ,x_qual_math                    => cur_ucas_app_rec.qual_math
          ,x_qual_sci                     => cur_ucas_app_rec.qual_sci
          ,x_main_qual                    => cur_ucas_app_rec.main_qual
          ,x_qual_5                       => cur_ucas_app_rec.qual_5
          ,x_future_serv                  => cur_ucas_app_rec.future_serv
          ,x_future_set                   => cur_ucas_app_rec.future_set
          ,x_present_serv                 => cur_ucas_app_rec.present_serv
          ,x_present_set                  => cur_ucas_app_rec.present_set
          ,x_curr_employment              => cur_ucas_app_rec.curr_employment
          ,x_edu_qualification            => cur_ucas_app_rec.edu_qualification
          ,x_ad_batch_id                  => l_ad_batch_id
          ,x_ad_interface_id              => l_ad_interface_id
          ,x_nationality                  => cur_ucas_app_rec.nationality
          ,x_dual_nationality             => cur_ucas_app_rec.dual_nationality
          ,x_special_needs                => cur_ucas_app_rec.special_needs
          ,x_country_birth                => cur_ucas_app_rec.country_birth );

      END IF; -- End of validating the current Applicant Status

    END IF; -- End of OSS Person ID Check

  END LOOP; -- End of looping through the Applicant Records
  CLOSE cur_exp_applicant_dtls;

  /************* End of Exporting Applicant Details to OSS  *****************/


  /****** Poulating the Admission Interface Tables to export Applicant Address Details to OSS  *****/

  -- Log the message 'Exporting Applicant Address details to OSS' with Time Stamp
  fnd_file.put_line( fnd_file.LOG ,' ');
  fnd_message.set_name('IGS','IGS_UC_EXP_APPLCNT_ADDR_DET');
  fnd_file.put_line(fnd_file.log, fnd_message.get||'  ('||to_char(SYSDATE,'DD-MON-YYYY HH:MI:SS')||')');
  fnd_file.put_line( fnd_file.LOG ,' ');

  --jchakrab added for 3691210
  IF p_app_no IS NULL THEN
    OPEN cur_app_address_dtls FOR
    SELECT *
    FROM IGS_UC_APP_ADDRESES
    WHERE SENT_TO_OSS_FLAG = 'N'
    ORDER BY APP_NO;
  ELSE
    OPEN cur_app_address_dtls FOR
    SELECT *
    FROM IGS_UC_APP_ADDRESES
    WHERE APP_NO = p_app_no AND
          SENT_TO_OSS_FLAG = 'N'
    ORDER BY APP_NO;
  END IF;

  -- Loop through all the records in IGS_UC_APP_ADDRESES table satisfying the criteria,
  -- SENT_TO_OSS_FLAG is N and passed parameter,P_APP_NO
  LOOP
    FETCH cur_app_address_dtls INTO cur_app_address_dtls_rec;
    EXIT WHEN cur_app_address_dtls%NOTFOUND;

    -- Get the OSS Person ID of the UCAS Applicant
    cur_uc_app_dtls_rec := NULL;
    OPEN cur_uc_app_dtls(cur_app_address_dtls_rec.app_no);
    FETCH cur_uc_app_dtls INTO cur_uc_app_dtls_rec;
    CLOSE cur_uc_app_dtls;

    -- Check whether the OSS Person ID value is populated for this Applicant
    -- If OSS Person ID is null then log the message and stop processing the current applicant
    IF cur_uc_app_dtls_rec.oss_person_id IS NULL THEN

      -- Log the message 'OSS Person ID is not populated for the Application Number'
      fnd_message.set_name('IGS','IGS_UC_APP_PER_ID_NOT_EXITS');
      fnd_message.set_token('APP_NO',cur_uc_app_dtls_rec.app_no);
      fnd_file.put_line(fnd_file.log, fnd_message.get);

    ELSE

      -- get the Applicant Person Details in OSS
      OPEN cur_uc_person_dtls(cur_uc_app_dtls_rec.oss_person_id);
      FETCH cur_uc_person_dtls INTO cur_uc_person_dtls_rec;
      CLOSE cur_uc_person_dtls;

      -- Log the message 'Processing the Applicant with Person Number: XXX and Applicantion Number: XXX'
      fnd_message.set_name('IGS','IGS_UC_EXP_APP_DET_PROC');
      fnd_message.set_token('PER_NO',cur_uc_person_dtls_rec.person_number);
      fnd_message.set_token('APP_NO',cur_uc_app_dtls_rec.app_no);
      fnd_file.put_line(fnd_file.log, fnd_message.get);

      -- If the Batch ID is already generated use the same,
      -- otherwise create the new Batch ID ( i.e. for First Time)
      IF l_ad_batch_id IS NULL THEN

        -- Fetch the Batch ID from the Sequence, IGS_AD_INTERFACE_BATCH_ID_S and
        -- populate the admission interface batch  table

        INSERT INTO igs_ad_imp_batch_det (
          batch_id,
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
        VALUES (
          IGS_AD_INTERFACE_BATCH_ID_S.NEXTVAL,
          fnd_message.get_string('IGS','IGS_UC_IMP_FROM_UCAS_BATCH_ID'),
          fnd_global.user_id,
          SYSDATE,
          fnd_global.user_id,
          SYSDATE,
          fnd_global.login_id,
          DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_request_id),
          DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.prog_appl_id),
          DECODE(fnd_global.conc_request_id,-1,NULL,SYSDATE),
          DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_program_id)
        )
        RETURNING batch_id INTO l_ad_batch_id;

      END IF;

      -- create the save point, l_exp_curr_applicant
      SAVEPOINT l_exp_curr_applicant;

      -- Initialize the Applicant valid status to TRUE
      l_app_valid_status := TRUE;

      -- Check if a record exists in IGS_AD_INTERFACE_ALL for the Admissions Batch ID and Person ID
      -- If exists use the same ID, otherwise create a new Interface ID
      l_ad_interface_id := NULL;

      OPEN cur_ad_interface_id(l_ad_batch_id, cur_uc_app_dtls_rec.oss_person_id);
      FETCH cur_ad_interface_id INTO l_ad_interface_id;
      CLOSE cur_ad_interface_id;

      IF l_ad_interface_id IS NULL THEN

          -- Get OSS country code
        l_oss_country_code := NULL;
        OPEN cur_hesa_map('UCAS_OSS_COUNTRY_ASSOC',cur_uc_app_dtls_rec.country_birth);
        FETCH cur_hesa_map INTO l_oss_country_code;
        CLOSE cur_hesa_map;

        -- Log a warning if country code exists but OSS mapping doesn't
        IF l_oss_country_code IS NULL AND cur_uc_app_dtls_rec.country_birth IS NOT NULL THEN
            fnd_message.set_name('IGS','IGS_UC_INV_COUNTRY_MAP');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
        END IF;

        INSERT INTO igs_ad_interface_all (
          interface_id,
          batch_id,
          source_type_id,
          person_id,
          match_ind,
          surname,
          given_names,
          sex,
          birth_dt,
          pre_name_adjunct,
          status,
          record_status,
          pref_alternate_id,
          birth_country,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login )
        VALUES (
          IGS_AD_INTERFACE_S.NEXTVAL,
          l_ad_batch_id,
          l_src_type_id,
          cur_uc_app_dtls_rec.oss_person_id,
          '15',
          cur_uc_person_dtls_rec.surname,
          cur_uc_person_dtls_rec.given_names,
          cur_uc_person_dtls_rec.sex,
          cur_uc_person_dtls_rec.birth_date,
          cur_uc_person_dtls_rec.pre_name_adjunct,
          '2',
          '2',
          NULL,
          l_oss_country_code,
          g_created_by,
          SYSDATE,
          g_last_updated_by,
          SYSDATE,
          g_last_update_login )
        RETURNING interface_id INTO l_ad_interface_id ;

      END IF;

      -- Check the Admission Source Categories Setup included Contact Details Category.
      --  If included Populate the Interface Table,
      --  so that this record will be processed by the Admission Import Process
      IF cur_app_address_dtls_rec.telephone IS NOT NULL OR cur_app_address_dtls_rec.email IS NOT NULL
         OR cur_app_address_dtls_rec.home_phone IS NOT NULL OR cur_app_address_dtls_rec.mobile IS NOT NULL THEN

        IF chk_src_cat(l_src_type_id,'PERSON_CONTACTS') THEN


          /* Call the Local Procedure, pop_contact_int to populate the columns,
             TELEPHONE, EMAIL and HOMEPHONE */
          pop_contact_int ( cur_app_address_dtls_rec.telephone,
                            cur_app_address_dtls_rec.email,
                            cur_app_address_dtls_rec.home_phone,
                            cur_app_address_dtls_rec.mobile,
                            l_ad_interface_id, l_app_valid_status );
        ELSE

          -- Display the warning message in the log file
          fnd_message.set_name('IGS','IGS_UC_ADM_INT_NOT_IMP');
          fnd_message.set_token('INT_TYPE', 'CONTACTS');
          fnd_file.put_line(fnd_file.log, fnd_message.get);

        END IF;

      END IF;

      -- Check the Admission Source Categories Setup included Address Details Category.
      --  If included Populate the Interface Table,
      --  so that this record will be processed by the Admission Import Process
      IF cur_app_address_dtls_rec.address1 IS NOT NULL OR cur_app_address_dtls_rec.address2 IS NOT NULL OR
         cur_app_address_dtls_rec.address3 IS NOT NULL OR cur_app_address_dtls_rec.address4 IS NOT NULL OR
         cur_app_address_dtls_rec.post_code IS NOT NULL OR cur_app_address_dtls_rec.home_address1 IS NOT NULL OR
         cur_app_address_dtls_rec.home_address2 IS NOT NULL OR  cur_app_address_dtls_rec.home_address3 IS NOT NULL OR
         cur_app_address_dtls_rec.home_address4 IS NOT NULL OR cur_app_address_dtls_rec.home_postcode IS NOT NULL  THEN

        IF chk_src_cat(l_src_type_id,'PERSON_ADDRESS') THEN


          /* Call the Local Procedure, pop_address_int to populate the columns,
            Address Intreface and Address Usage Interface Tables */
          pop_address_int ( cur_app_address_dtls_rec, cur_uc_app_dtls_rec.domicile_apr,
                            l_ad_interface_id, p_addr_usage_home, p_addr_usage_corr, l_app_valid_status );

        ELSE

          -- Display the warning message in the log file
          fnd_message.set_name('IGS','IGS_UC_ADM_INT_NOT_IMP');
          fnd_message.set_token('INT_TYPE', 'ADDRESS');
          fnd_file.put_line(fnd_file.log, fnd_message.get);

        END IF;

      END IF;

      IF l_app_valid_status = FALSE THEN

        -- Delete all the entries for the current applicant from interface tables
        -- except the batch table since the batch_id is same for all Applicants
        -- i.e. roll back upto to l_exp_curr_applicant
        ROLLBACK TO l_exp_curr_applicant;

      ELSE

        /* Update the IGS_UC_APP_ADDRESES Table with AD_BATCH_ID => Admissions Batch ID and
           AD_INTERFACE_ID => Admissions Interface ID  */
        cur_app_address_rec := NULL;
        OPEN cur_upd_app_address (cur_app_address_dtls_rec.app_no);
        FETCH cur_upd_app_address INTO cur_app_address_rec;
        CLOSE cur_upd_app_address;
        igs_uc_app_addreses_pkg.update_row (
          x_rowid                        => cur_app_address_rec.rowid,
          x_app_no                      => cur_app_address_rec.app_no,
          x_address_area                => cur_app_address_rec.address_area,
          x_address1                    => cur_app_address_rec.address1,
          x_address2                    => cur_app_address_rec.address2,
          x_address3                    => cur_app_address_rec.address3,
          x_address4                    => cur_app_address_rec.address4,
          x_post_code                   => cur_app_address_rec.post_code,
          x_mail_sort                   => cur_app_address_rec.mail_sort,
          x_telephone                   => cur_app_address_rec.telephone,
          x_fax                         => cur_app_address_rec.fax,
          x_email                       => cur_app_address_rec.email,
          x_home_address1               => cur_app_address_rec.home_address1,
          x_home_address2               => cur_app_address_rec.home_address2,
          x_home_address3               => cur_app_address_rec.home_address3,
          x_home_address4               => cur_app_address_rec.home_address4,
          x_home_postcode               => cur_app_address_rec.home_postcode,
          x_home_phone                  => cur_app_address_rec.home_phone,
          x_home_fax                    => cur_app_address_rec.home_fax,
          x_home_email                  => cur_app_address_rec.home_email,
          x_sent_to_oss_flag            => cur_app_address_rec.sent_to_oss_flag,
          x_mobile                      => cur_app_address_rec.mobile,
          x_country_code                => cur_app_address_rec.country_code,
          x_home_country_code           => cur_app_address_rec.home_country_code,
          x_ad_batch_id                 => l_ad_batch_id,
          x_ad_interface_id             => l_ad_interface_id,
          x_mode                        => 'R'     );

     END IF;

    END IF; -- End of OSS_PERSON_ID Check

  END LOOP;
  CLOSE cur_app_address_dtls;

  /***** End of Exporting Applicant Address Details to OSS  *******/


  /***** Displaying the Manual Updations required to Applicant Names Information  *******/

  -- Log the message 'Following changes in Applicant information need to be updated manually in Student System'
  fnd_file.put_line( fnd_file.LOG ,' ');
  fnd_message.set_name('IGS','IGS_UC_EXP_UPD_APP_INF');
  fnd_file.put_line(fnd_file.log, fnd_message.get||'  ('||to_char(SYSDATE,'DD-MON-YYYY HH:MI:SS')||')');
  fnd_file.put_line( fnd_file.LOG ,' ');

  --jchakrab added for 3691220
  IF p_app_no IS NULL THEN
    OPEN cur_app_name_dtls FOR
      SELECT APP_NO,TITLE, FORE_NAMES, SURNAME, BIRTH_DATE, SEX
      FROM IGS_UC_APP_NAMES
      WHERE SENT_TO_OSS_FLAG = 'N'
      ORDER BY APP_NO;

  ELSE
    OPEN cur_app_name_dtls FOR
      SELECT APP_NO,TITLE, FORE_NAMES, SURNAME, BIRTH_DATE, SEX
      FROM IGS_UC_APP_NAMES
      WHERE APP_NO = p_app_no AND
            SENT_TO_OSS_FLAG = 'N'
      ORDER BY APP_NO;
  END IF;

  -- Loop through all the records in IGS_UC_APP_NAMES table satisfying the criteria,
  -- SENT_TO_OSS_FLAG is N and passed parameter,P_APP_NO
  LOOP
    FETCH cur_app_name_dtls INTO cur_app_name_dtls_rec;
    EXIT WHEN cur_app_name_dtls%NOTFOUND;

    -- Get the OSS Person ID of the UCAS Applicant
    cur_uc_app_dtls_rec := NULL;
    OPEN cur_uc_app_dtls(cur_app_name_dtls_rec.app_no);
    FETCH cur_uc_app_dtls INTO cur_uc_app_dtls_rec;
    CLOSE cur_uc_app_dtls;

    -- Check whether the OSS Person ID value is populated for this Applicant
    -- If OSS Person ID is null then log the message and stop processing the current applicant
    IF cur_uc_app_dtls_rec.oss_person_id IS NULL THEN

      -- Log the message 'OSS Person ID is not populated for the Application Number'
      fnd_message.set_name('IGS','IGS_UC_APP_PER_ID_NOT_EXITS');
      fnd_message.set_token('APP_NO',cur_uc_app_dtls_rec.app_no);
      fnd_file.put_line(fnd_file.log, fnd_message.get);

    ELSE

      -- Get the Applicant Person Details in OSS
      OPEN cur_uc_person_dtls(cur_uc_app_dtls_rec.oss_person_id);
      FETCH cur_uc_person_dtls INTO cur_uc_person_dtls_rec;
      CLOSE cur_uc_person_dtls;

      -- Log the message 'Processing the Applicant with Person Number: XXX and Applicantion Number: XXX'
      fnd_message.set_name('IGS','IGS_UC_EXP_APP_DET_PROC');
      fnd_message.set_token('PER_NO',cur_uc_person_dtls_rec.person_number);
      fnd_message.set_token('APP_NO',cur_uc_app_dtls_rec.app_no);
      fnd_file.put_line(fnd_file.log, fnd_message.get);

      -- get the OSS mapping value for Sex
      -- If sex is null or mapping not found, log the message and continue with the next applicant
      l_oss_val := NULL;
      OPEN cur_hesa_map('UC_OSS_HE_GEN_ASSOC', cur_app_name_dtls_rec.sex);
      FETCH cur_hesa_map INTO l_oss_val;

      IF cur_hesa_map%NOTFOUND AND cur_app_name_dtls_rec.sex IS NOT NULL THEN

        fnd_message.set_name('IGS','IGS_UC_INV_MAPPING_VAL');
        fnd_message.set_token('CODE', cur_app_name_dtls_rec.sex);
        fnd_message.set_token('TYPE','SEX');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

      ELSE
        -- If OSS person details are not equal to UCAS person details then report the changes required
        IF( NVL(cur_app_name_dtls_rec.title,'*') <> NVL(cur_uc_person_dtls_rec.pre_name_adjunct,'*') OR
            NVL(cur_app_name_dtls_rec.fore_names,'*') <> NVL(cur_uc_person_dtls_rec.given_names,'*') OR
            NVL(cur_app_name_dtls_rec.surname,'*') <> NVL(cur_uc_person_dtls_rec.surname,'*') OR
            NVL(TRUNC(cur_app_name_dtls_rec.birth_date),SYSDATE) <> NVL(TRUNC(cur_uc_person_dtls_rec.birth_date),SYSDATE) OR
            NVL(l_oss_val,'*') <> NVL(cur_uc_person_dtls_rec.sex,'*') )  THEN

          -- Log the message displaying the APP_NAME Interface Table Details
          fnd_message.set_name('IGS','IGS_UC_EXP_UPD_APP_DET');
          fnd_message.set_token('TITLE',cur_app_name_dtls_rec.title);
          fnd_message.set_token('FORE_NAMES',cur_app_name_dtls_rec.fore_names);
          fnd_message.set_token('SURNAME',cur_app_name_dtls_rec.surname);
          fnd_message.set_token('BIRTH_DATE',cur_app_name_dtls_rec.birth_date);
          fnd_message.set_token('SEX',l_oss_val);
          fnd_file.put_line(fnd_file.log, fnd_message.get);

        END IF;

       /* Update the IGS_UC_APP_NAMES Table with sent_to_oss_flag to 'Y' */
        cur_app_name_rec := NULL;
        OPEN cur_upd_app_name (cur_app_name_dtls_rec.app_no);
        FETCH cur_upd_app_name INTO cur_app_name_rec;
        CLOSE cur_upd_app_name;

        igs_uc_app_names_pkg.update_row(
           x_rowid                     => cur_app_name_rec.rowid
          ,x_app_no                    => cur_app_name_rec.app_no
          ,x_check_digit               => cur_app_name_rec.check_digit
          ,x_name_change_date          => cur_app_name_rec.name_change_date
          ,x_title                     => cur_app_name_rec.title
          ,x_fore_names                => cur_app_name_rec.fore_names
          ,x_surname                   => cur_app_name_rec.surname
          ,x_birth_date                => cur_app_name_rec.birth_date
          ,x_sex                       => cur_app_name_rec.sex
          ,x_sent_to_oss_flag          => 'Y'
          ,x_mode                      => 'R' );

      END IF;
      CLOSE cur_hesa_map;

    END IF;

  END LOOP;
  CLOSE cur_app_name_dtls;

  /***** End of the Manual Updations required to Applicant Information  *******/


  /******************  Call the Admission Import Process   ****************/

  -- Initialize the status variables
  l_adm_imp_status := TRUE;
  l_adm_error_encountered := FALSE;

  adm_import_process (l_ad_batch_id, l_src_type_id, l_adm_imp_status );


  /******* Process the Interface Records and update the UCAS Interface Tables ******/

  IF l_adm_imp_status = TRUE THEN

    -- Processing the records in the IGS_UC_APPLICANTS Table
    FOR cur_proc_applicant_rec IN cur_proc_applicants(l_ad_batch_id) LOOP

      -- Check whether the record exist in the IGS_AD_INTERFACE Table for the
      -- Admission Batch ID and Interface ID
      OPEN cur_ad_interface_exist( cur_proc_applicant_rec.ad_batch_id, cur_proc_applicant_rec.ad_interface_id);
      FETCH cur_ad_interface_exist INTO l_dummy;

      IF cur_ad_interface_exist%FOUND THEN
        l_sent_to_oss_flag := 'I';
        l_adm_error_encountered := TRUE;
      ELSE
        l_sent_to_oss_flag := 'Y';
      END IF;
      CLOSE cur_ad_interface_exist;

        -- update the IGS_UC_APPLICANTS Table
        cur_ucas_app_rec := NULL;
        OPEN cur_upd_ucas_app (cur_proc_applicant_rec.app_no);
        FETCH cur_upd_ucas_app INTO cur_ucas_app_rec;
        CLOSE cur_upd_ucas_app;

        -- Update the UCAS Applicants Table with Batch ID and Interface ID
        igs_uc_applicants_pkg.update_row (
          x_rowid                         => cur_ucas_app_rec.rowid
          ,x_app_id                       => cur_ucas_app_rec.app_id
          ,x_app_no                       => cur_ucas_app_rec.app_no
          ,x_check_digit                  => cur_ucas_app_rec.check_digit
          ,x_personal_id                  => cur_ucas_app_rec.personal_id
          ,x_enquiry_no                   => cur_ucas_app_rec.enquiry_no
          ,x_oss_person_id                => cur_ucas_app_rec.oss_person_id
          ,x_application_source           => cur_ucas_app_rec.application_source
          ,x_name_change_date             => cur_ucas_app_rec.name_change_date
          ,x_student_support              => cur_ucas_app_rec.student_support
          ,x_address_area                 => cur_ucas_app_rec.address_area
          ,x_application_date             => cur_ucas_app_rec.application_date
          ,x_application_sent_date        => cur_ucas_app_rec.application_sent_date
          ,x_application_sent_run         => cur_ucas_app_rec.application_sent_run
          ,x_lea_code                     => cur_ucas_app_rec.lea_code
          ,x_fee_payer_code               => cur_ucas_app_rec.fee_payer_code
          ,x_fee_text                     => cur_ucas_app_rec.fee_text
          ,x_domicile_apr                 => cur_ucas_app_rec.domicile_apr
          ,x_code_changed_date            => cur_ucas_app_rec.code_changed_date
          ,x_school                       => cur_ucas_app_rec.school
          ,x_withdrawn                    => cur_ucas_app_rec.withdrawn
          ,x_withdrawn_date               => cur_ucas_app_rec.withdrawn_date
          ,x_rel_to_clear_reason          => cur_ucas_app_rec.rel_to_clear_reason
          ,x_route_b                      => cur_ucas_app_rec.route_b
          ,x_exam_change_date             => cur_ucas_app_rec.exam_change_date
          ,x_a_levels                     => cur_ucas_app_rec.a_levels
          ,x_as_levels                    => cur_ucas_app_rec.as_levels
          ,x_highers                      => cur_ucas_app_rec.highers
          ,x_csys                         => cur_ucas_app_rec.csys
          ,x_winter                       => cur_ucas_app_rec.winter
          ,x_previous                     => cur_ucas_app_rec.previous
          ,x_gnvq                         => cur_ucas_app_rec.gnvq
          ,x_btec                         => cur_ucas_app_rec.btec
          ,x_ilc                          => cur_ucas_app_rec.ilc
          ,x_ailc                         => cur_ucas_app_rec.ailc
          ,x_ib                           => cur_ucas_app_rec.ib
          ,x_manual                       => cur_ucas_app_rec.manual
          ,x_reg_num                      => cur_ucas_app_rec.reg_num
          ,x_oeq                          => cur_ucas_app_rec.oeq
          ,x_eas                          => cur_ucas_app_rec.eas
          ,x_roa                          => cur_ucas_app_rec.roa
          ,x_status                       => cur_ucas_app_rec.status
          ,x_firm_now                     => cur_ucas_app_rec.firm_now
          ,x_firm_reply                   => cur_ucas_app_rec.firm_reply
          ,x_insurance_reply              => cur_ucas_app_rec.insurance_reply
          ,x_conf_hist_firm_reply         => cur_ucas_app_rec.conf_hist_firm_reply
          ,x_conf_hist_ins_reply          => cur_ucas_app_rec.conf_hist_ins_reply
          ,x_residential_category         => cur_ucas_app_rec.residential_category
          ,x_personal_statement           => cur_ucas_app_rec.personal_statement
          ,x_match_prev                   => cur_ucas_app_rec.match_prev
          ,x_match_prev_date              => cur_ucas_app_rec.match_prev_date
          ,x_match_winter                 => cur_ucas_app_rec.match_winter
          ,x_match_summer                 => cur_ucas_app_rec.match_summer
          ,x_gnvq_date                    => cur_ucas_app_rec.gnvq_date
          ,x_ib_date                      => cur_ucas_app_rec.ib_date
          ,x_ilc_date                     => cur_ucas_app_rec.ilc_date
          ,x_ailc_date                    => cur_ucas_app_rec.ailc_date
          ,x_gcseqa_date                  => cur_ucas_app_rec.gcseqa_date
          ,x_uk_entry_date                => cur_ucas_app_rec.uk_entry_date
          ,x_prev_surname                 => cur_ucas_app_rec.prev_surname
          ,x_criminal_convictions         => cur_ucas_app_rec.criminal_convictions
          ,x_sent_to_hesa                 => cur_ucas_app_rec.sent_to_hesa
          ,x_sent_to_oss                  => l_sent_to_oss_flag       -- updated column
          ,x_batch_identifier             => cur_ucas_app_rec.batch_identifier
          ,x_mode                         => 'R'
          ,x_gce                          => cur_ucas_app_rec.gce
          ,x_vce                          => cur_ucas_app_rec.vce
          ,x_sqa                          => cur_ucas_app_rec.sqa
          ,x_previousas                   => cur_ucas_app_rec.previousas
          ,x_keyskills                    => cur_ucas_app_rec.keyskills
          ,x_vocational                   => cur_ucas_app_rec.vocational
          ,x_scn                          => cur_ucas_app_rec.scn
          ,x_prevoeq                      => cur_ucas_app_rec.prevoeq
          ,x_choices_transparent_ind      => cur_ucas_app_rec.choices_transparent_ind
          ,x_extra_status                 => cur_ucas_app_rec.extra_status
          ,x_extra_passport_no            => cur_ucas_app_rec.extra_passport_no
          ,x_request_app_dets_ind         => cur_ucas_app_rec.request_app_dets_ind
          ,x_request_copy_app_frm_ind     => cur_ucas_app_rec.request_copy_app_frm_ind
          ,x_cef_no                       => cur_ucas_app_rec.cef_no
          ,x_system_code                  => cur_ucas_app_rec.system_code
          ,x_gcse_eng                     => cur_ucas_app_rec.gcse_eng
          ,x_gcse_math                    => cur_ucas_app_rec.gcse_math
          ,x_degree_subject               => cur_ucas_app_rec.degree_subject
          ,x_degree_status                => cur_ucas_app_rec.degree_status
          ,x_degree_class                 => cur_ucas_app_rec.degree_class
          ,x_gcse_sci                     => cur_ucas_app_rec.gcse_sci
          ,x_welshspeaker                 => cur_ucas_app_rec.welshspeaker
          ,x_ni_number                    => cur_ucas_app_rec.ni_number
          ,x_earliest_start               => cur_ucas_app_rec.earliest_start
          ,x_near_inst                    => cur_ucas_app_rec.near_inst
          ,x_pref_reg                     => cur_ucas_app_rec.pref_reg
          ,x_qual_eng                     => cur_ucas_app_rec.qual_eng
          ,x_qual_math                    => cur_ucas_app_rec.qual_math
          ,x_qual_sci                     => cur_ucas_app_rec.qual_sci
          ,x_main_qual                    => cur_ucas_app_rec.main_qual
          ,x_qual_5                       => cur_ucas_app_rec.qual_5
          ,x_future_serv                  => cur_ucas_app_rec.future_serv
          ,x_future_set                   => cur_ucas_app_rec.future_set
          ,x_present_serv                 => cur_ucas_app_rec.present_serv
          ,x_present_set                  => cur_ucas_app_rec.present_set
          ,x_curr_employment              => cur_ucas_app_rec.curr_employment
          ,x_edu_qualification            => cur_ucas_app_rec.edu_qualification
          ,x_ad_batch_id                  => cur_ucas_app_rec.ad_batch_id
          ,x_ad_interface_id              => cur_ucas_app_rec.ad_interface_id
          ,x_nationality                  => cur_ucas_app_rec.nationality
          ,x_dual_nationality             => cur_ucas_app_rec.dual_nationality
          ,x_special_needs                => cur_ucas_app_rec.special_needs
          ,x_country_birth                => cur_ucas_app_rec.country_birth );

    END LOOP;

    -- Processing the records in the IGS_UC_APP_ADDRESES Table
    FOR cur_proc_app_address_rec IN cur_proc_app_address(l_ad_batch_id) LOOP

      -- Check whether the record exist in the IGS_AD_INTERFACE Table for the
      -- Admission Batch ID and Interface ID
      OPEN cur_ad_interface_exist( cur_proc_app_address_rec.ad_batch_id, cur_proc_app_address_rec.ad_interface_id);
      FETCH cur_ad_interface_exist INTO l_dummy;

      IF cur_ad_interface_exist%FOUND THEN
        l_sent_to_oss_flag := 'I';
        l_adm_error_encountered := TRUE;
      ELSE
        l_sent_to_oss_flag := 'Y';
      END IF;
      CLOSE cur_ad_interface_exist;

      -- Update the IGS_UC_APP_ADDRESES Table
      cur_app_address_rec := NULL;
      OPEN cur_upd_app_address (cur_proc_app_address_rec.app_no);
      FETCH cur_upd_app_address INTO cur_app_address_rec;
      CLOSE cur_upd_app_address;
      igs_uc_app_addreses_pkg.update_row (
        x_rowid                        => cur_app_address_rec.rowid,
        x_app_no                      => cur_app_address_rec.app_no,
        x_address_area                => cur_app_address_rec.address_area,
        x_address1                    => cur_app_address_rec.address1,
        x_address2                    => cur_app_address_rec.address2,
        x_address3                    => cur_app_address_rec.address3,
        x_address4                    => cur_app_address_rec.address4,
        x_post_code                   => cur_app_address_rec.post_code,
        x_mail_sort                   => cur_app_address_rec.mail_sort,
        x_telephone                   => cur_app_address_rec.telephone,
        x_fax                         => cur_app_address_rec.fax,
        x_email                       => cur_app_address_rec.email,
        x_home_address1               => cur_app_address_rec.home_address1,
        x_home_address2               => cur_app_address_rec.home_address2,
        x_home_address3               => cur_app_address_rec.home_address3,
        x_home_address4               => cur_app_address_rec.home_address4,
        x_home_postcode               => cur_app_address_rec.home_postcode,
        x_home_phone                  => cur_app_address_rec.home_phone,
        x_home_fax                    => cur_app_address_rec.home_fax,
        x_home_email                  => cur_app_address_rec.home_email,
        x_sent_to_oss_flag            => l_sent_to_oss_flag,
        x_mobile                      => cur_app_address_rec.mobile,
        x_country_code                => cur_app_address_rec.country_code,
        x_home_country_code           => cur_app_address_rec.home_country_code,
        x_ad_batch_id                 => cur_app_address_rec.ad_batch_id,
        x_ad_interface_id             => cur_app_address_rec.ad_interface_id,
        x_mode                        => 'R'     );

    END LOOP;

  END IF;

  -- anwest Bug# 3642740
  -- Processing the records in the IGS_UC_APPLICANTS Table with SENT_TO_OSS set to 'I'
  FOR cur_proc_applicant_i_rec IN cur_proc_applicants_i LOOP

    -- Check whether the record exist in the IGS_AD_INTERFACE Table for the
        -- Admission Batch ID and Interface ID
    OPEN cur_ad_interface_exist(cur_proc_applicant_i_rec.ad_batch_id, cur_proc_applicant_i_rec.ad_interface_id);
        FETCH cur_ad_interface_exist INTO l_dummy;

        IF cur_ad_interface_exist%NOTFOUND THEN

            -- does not exist so update the UCAS Applicants Table with 'Y' for SENT_TO_OSS
        cur_ucas_app_rec := NULL;
        OPEN cur_upd_ucas_app (cur_proc_applicant_i_rec.app_no);
        FETCH cur_upd_ucas_app INTO cur_ucas_app_rec;
            CLOSE cur_upd_ucas_app;
        igs_uc_applicants_pkg.update_row (
            x_rowid                         => cur_ucas_app_rec.rowid
            ,x_app_id                       => cur_ucas_app_rec.app_id
                ,x_app_no                       => cur_ucas_app_rec.app_no
                ,x_check_digit                  => cur_ucas_app_rec.check_digit
                ,x_personal_id                  => cur_ucas_app_rec.personal_id
                ,x_enquiry_no                   => cur_ucas_app_rec.enquiry_no
                ,x_oss_person_id                => cur_ucas_app_rec.oss_person_id
                ,x_application_source           => cur_ucas_app_rec.application_source
                ,x_name_change_date             => cur_ucas_app_rec.name_change_date
                ,x_student_support              => cur_ucas_app_rec.student_support
                ,x_address_area                 => cur_ucas_app_rec.address_area
                ,x_application_date             => cur_ucas_app_rec.application_date
                ,x_application_sent_date        => cur_ucas_app_rec.application_sent_date
                ,x_application_sent_run         => cur_ucas_app_rec.application_sent_run
                ,x_lea_code                     => cur_ucas_app_rec.lea_code
                ,x_fee_payer_code               => cur_ucas_app_rec.fee_payer_code
                ,x_fee_text                     => cur_ucas_app_rec.fee_text
                ,x_domicile_apr                 => cur_ucas_app_rec.domicile_apr
                ,x_code_changed_date            => cur_ucas_app_rec.code_changed_date
                ,x_school                       => cur_ucas_app_rec.school
                ,x_withdrawn                    => cur_ucas_app_rec.withdrawn
                ,x_withdrawn_date               => cur_ucas_app_rec.withdrawn_date
                ,x_rel_to_clear_reason          => cur_ucas_app_rec.rel_to_clear_reason
                ,x_route_b                      => cur_ucas_app_rec.route_b
                ,x_exam_change_date             => cur_ucas_app_rec.exam_change_date
                ,x_a_levels                     => cur_ucas_app_rec.a_levels
                ,x_as_levels                    => cur_ucas_app_rec.as_levels
                ,x_highers                      => cur_ucas_app_rec.highers
                ,x_csys                         => cur_ucas_app_rec.csys
                ,x_winter                       => cur_ucas_app_rec.winter
                ,x_previous                     => cur_ucas_app_rec.previous
                ,x_gnvq                         => cur_ucas_app_rec.gnvq
                ,x_btec                         => cur_ucas_app_rec.btec
                ,x_ilc                          => cur_ucas_app_rec.ilc
                ,x_ailc                         => cur_ucas_app_rec.ailc
                ,x_ib                           => cur_ucas_app_rec.ib
                ,x_manual                       => cur_ucas_app_rec.manual
                ,x_reg_num                      => cur_ucas_app_rec.reg_num
                ,x_oeq                          => cur_ucas_app_rec.oeq
                ,x_eas                          => cur_ucas_app_rec.eas
                ,x_roa                          => cur_ucas_app_rec.roa
                ,x_status                       => cur_ucas_app_rec.status
                ,x_firm_now                     => cur_ucas_app_rec.firm_now
                ,x_firm_reply                   => cur_ucas_app_rec.firm_reply
                ,x_insurance_reply              => cur_ucas_app_rec.insurance_reply
                ,x_conf_hist_firm_reply         => cur_ucas_app_rec.conf_hist_firm_reply
                ,x_conf_hist_ins_reply          => cur_ucas_app_rec.conf_hist_ins_reply
                ,x_residential_category         => cur_ucas_app_rec.residential_category
                ,x_personal_statement           => cur_ucas_app_rec.personal_statement
                ,x_match_prev                   => cur_ucas_app_rec.match_prev
                ,x_match_prev_date              => cur_ucas_app_rec.match_prev_date
                ,x_match_winter                 => cur_ucas_app_rec.match_winter
                ,x_match_summer                 => cur_ucas_app_rec.match_summer
                ,x_gnvq_date                    => cur_ucas_app_rec.gnvq_date
                ,x_ib_date                      => cur_ucas_app_rec.ib_date
                ,x_ilc_date                     => cur_ucas_app_rec.ilc_date
                ,x_ailc_date                    => cur_ucas_app_rec.ailc_date
                ,x_gcseqa_date                  => cur_ucas_app_rec.gcseqa_date
                ,x_uk_entry_date                => cur_ucas_app_rec.uk_entry_date
                ,x_prev_surname                 => cur_ucas_app_rec.prev_surname
                ,x_criminal_convictions         => cur_ucas_app_rec.criminal_convictions
                ,x_sent_to_hesa                 => cur_ucas_app_rec.sent_to_hesa
                ,x_sent_to_oss                  => 'Y'
                ,x_batch_identifier             => cur_ucas_app_rec.batch_identifier
                ,x_mode                         => 'R'
                ,x_gce                          => cur_ucas_app_rec.gce
                ,x_vce                          => cur_ucas_app_rec.vce
                ,x_sqa                          => cur_ucas_app_rec.sqa
                ,x_previousas                   => cur_ucas_app_rec.previousas
                ,x_keyskills                    => cur_ucas_app_rec.keyskills
                ,x_vocational                   => cur_ucas_app_rec.vocational
                ,x_scn                          => cur_ucas_app_rec.scn
                ,x_prevoeq                      => cur_ucas_app_rec.prevoeq
                ,x_choices_transparent_ind      => cur_ucas_app_rec.choices_transparent_ind
                ,x_extra_status                 => cur_ucas_app_rec.extra_status
                ,x_extra_passport_no            => cur_ucas_app_rec.extra_passport_no
                ,x_request_app_dets_ind         => cur_ucas_app_rec.request_app_dets_ind
                ,x_request_copy_app_frm_ind     => cur_ucas_app_rec.request_copy_app_frm_ind
                ,x_cef_no                       => cur_ucas_app_rec.cef_no
                ,x_system_code                  => cur_ucas_app_rec.system_code
                ,x_gcse_eng                     => cur_ucas_app_rec.gcse_eng
                ,x_gcse_math                    => cur_ucas_app_rec.gcse_math
                ,x_degree_subject               => cur_ucas_app_rec.degree_subject
                ,x_degree_status                => cur_ucas_app_rec.degree_status
                ,x_degree_class                 => cur_ucas_app_rec.degree_class
                ,x_gcse_sci                     => cur_ucas_app_rec.gcse_sci
                ,x_welshspeaker                 => cur_ucas_app_rec.welshspeaker
                ,x_ni_number                    => cur_ucas_app_rec.ni_number
                ,x_earliest_start               => cur_ucas_app_rec.earliest_start
                ,x_near_inst                    => cur_ucas_app_rec.near_inst
                ,x_pref_reg                     => cur_ucas_app_rec.pref_reg
                ,x_qual_eng                     => cur_ucas_app_rec.qual_eng
                ,x_qual_math                    => cur_ucas_app_rec.qual_math
                ,x_qual_sci                     => cur_ucas_app_rec.qual_sci
                ,x_main_qual                    => cur_ucas_app_rec.main_qual
                ,x_qual_5                       => cur_ucas_app_rec.qual_5
                ,x_future_serv                  => cur_ucas_app_rec.future_serv
                ,x_future_set                   => cur_ucas_app_rec.future_set
                ,x_present_serv                 => cur_ucas_app_rec.present_serv
                ,x_present_set                  => cur_ucas_app_rec.present_set
                ,x_curr_employment              => cur_ucas_app_rec.curr_employment
                ,x_edu_qualification            => cur_ucas_app_rec.edu_qualification
                ,x_ad_batch_id                  => cur_ucas_app_rec.ad_batch_id
                ,x_ad_interface_id              => cur_ucas_app_rec.ad_interface_id
                ,x_nationality                  => cur_ucas_app_rec.nationality
                ,x_dual_nationality             => cur_ucas_app_rec.dual_nationality
                ,x_special_needs                => cur_ucas_app_rec.special_needs
                ,x_country_birth                => cur_ucas_app_rec.country_birth );

    END IF;

        CLOSE cur_ad_interface_exist;

  END LOOP;


  -- anwest Bug# 3642740
  -- Processing the records in the IGS_UC_APP_ADDRESES Table with SENT_TO_OSS_FLAG set to 'I'
  FOR cur_proc_app_address_i_rec IN cur_proc_app_address_i LOOP

    -- Check whether the record exist in the IGS_AD_INTERFACE Table for the
        -- Admission Batch ID and Interface ID
    OPEN cur_ad_interface_exist(cur_proc_app_address_i_rec.ad_batch_id, cur_proc_app_address_i_rec.ad_interface_id);
        FETCH cur_ad_interface_exist INTO l_dummy;

        IF cur_ad_interface_exist%NOTFOUND THEN

            -- does not exist so update the UCAS Applicant Addresses Table with 'Y' for SENT_TO_OSS_FLAG
            cur_app_address_rec := NULL;
            OPEN cur_upd_app_address (cur_proc_app_address_i_rec.app_no);
            FETCH cur_upd_app_address INTO cur_app_address_rec;
            CLOSE cur_upd_app_address;
            igs_uc_app_addreses_pkg.update_row (
                x_rowid                       => cur_app_address_rec.rowid,
                x_app_no                      => cur_app_address_rec.app_no,
                x_address_area                => cur_app_address_rec.address_area,
                x_address1                    => cur_app_address_rec.address1,
                x_address2                    => cur_app_address_rec.address2,
                x_address3                    => cur_app_address_rec.address3,
                x_address4                    => cur_app_address_rec.address4,
                x_post_code                   => cur_app_address_rec.post_code,
                x_mail_sort                   => cur_app_address_rec.mail_sort,
                x_telephone                   => cur_app_address_rec.telephone,
                x_fax                         => cur_app_address_rec.fax,
                x_email                       => cur_app_address_rec.email,
                x_home_address1               => cur_app_address_rec.home_address1,
                x_home_address2               => cur_app_address_rec.home_address2,
                x_home_address3               => cur_app_address_rec.home_address3,
                x_home_address4               => cur_app_address_rec.home_address4,
                x_home_postcode               => cur_app_address_rec.home_postcode,
                x_home_phone                  => cur_app_address_rec.home_phone,
                x_home_fax                    => cur_app_address_rec.home_fax,
                x_home_email                  => cur_app_address_rec.home_email,
                x_sent_to_oss_flag            => 'Y',
                x_mobile                      => cur_app_address_rec.mobile,
                x_country_code                => cur_app_address_rec.country_code,
                x_home_country_code           => cur_app_address_rec.home_country_code,
                x_ad_batch_id                 => cur_app_address_rec.ad_batch_id,
                x_ad_interface_id             => cur_app_address_rec.ad_interface_id,
                x_mode                        => 'R'     );
        END IF;

        CLOSE cur_ad_interface_exist;

    END LOOP;


  /******* End of Processing the Interface Records *******/


  /******** Launching Export UCAS Applicant to OSS Error Report job ********/

  IF l_adm_error_encountered = TRUE THEN

    -- Submit the Error report to show the errors generated while exporting the applicant details
    l_rep_request_id := NULL ;
    l_rep_request_id := fnd_request.submit_request(
                         'IGS','IGSUCS37','Export UCAS Applicant Details to OSS Error Report',
                         NULL, FALSE, NULL , NULL, NULL, NULL, CHR(0),
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL );

    IF l_rep_request_id > 0 THEN

      -- If error report successfully submitted then log message
      fnd_file.put_line( fnd_file.LOG ,' ');
      fnd_message.set_name('IGS','IGS_UC_EXP_APP_REP_SUBM');
      fnd_message.set_token('REQ_ID',TO_CHAR(l_rep_request_id));
      fnd_file.put_line( fnd_file.LOG ,fnd_message.get||'  ('||to_char(SYSDATE,'DD-MON-YYYY HH:MI:SS')||')');

    ELSE

      -- If error report failed to be launched then log message
      fnd_file.put_line( fnd_file.LOG ,' ');
      fnd_message.set_name('IGS','IGS_UC_EXP_APP_SUBM_ERR');
      fnd_file.put_line( fnd_file.LOG ,fnd_message.get||'  ('||to_char(SYSDATE,'DD-MON-YYYY HH:MI:SS')||')');

    END IF;

  END IF;

  /******** End of Launching Export UCAS Applicant to OSS Error Report ********/

EXCEPTION

  WHEN OTHERS THEN

    ROLLBACK;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_UC_EXP_APPLICANT_DTLS.EXPORT_PROCESS'||' - '||SQLERRM);
    errbuf := fnd_message.get;
    retcode := 2 ;
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

END export_process;


PROCEDURE pop_api_int ( p_ni_number IN VARCHAR2,
                        p_ninumber_alt_type IN VARCHAR2,
                        p_scn  IN VARCHAR2,
                        p_person_id IN NUMBER,
                        p_interface_id IN NUMBER,
                        p_app_valid_status IN OUT NOCOPY BOOLEAN) IS
  /******************************************************************
  Created By      : AYEDUBAT
  Date Created By : 16-JUN-2003
  Purpose         : Populates the Admission Alternate ID Interface Tables and set the
                    parameter,p_app_valid_status to FALSE if an exception is raised.
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT

  ***************************************************************** */

  CURSOR cur_alt_pers_dtls ( cp_person_id    IGS_PE_ALT_PERS_ID.pe_person_id%TYPE,
                             cp_pers_id_type IGS_PE_ALT_PERS_ID.person_id_type%TYPE) IS
    SELECT api_person_id, start_dt, end_dt
    FROM IGS_PE_ALT_PERS_ID
    WHERE pe_person_id = cp_person_id
    AND person_id_type = cp_pers_id_type
    ORDER BY START_DT DESC;
  cur_alt_pers_dtls_rec cur_alt_pers_dtls%ROWTYPE;

  CURSOR cur_pers_type_unique ( cp_person_id_type IGS_PE_PERSON_ID_TYP.person_id_type%TYPE) IS
    SELECT 'X'
    FROM IGS_PE_PERSON_ID_TYP
    WHERE person_id_type = cp_person_id_type
    AND unique_ind = 'Y'
    AND closed_ind = 'N';

  CURSOR cur_pers_id_exist ( cp_api_person_id IGS_PE_ALT_PERS_ID.api_person_id%TYPE,
                             cp_person_id_type IGS_PE_ALT_PERS_ID.person_id_type%TYPE) IS
    SELECT 'X'
    FROM IGS_PE_ALT_PERS_ID
    WHERE api_person_id = cp_api_person_id
    AND person_id_type = cp_person_id_type;
  l_dummy VARCHAR2(1);

BEGIN

  -- Creating the Alternate ID type for NI_NNUMBER column
  IF p_ni_number IS NOT NULL AND p_ninumber_alt_type IS NOT NULL THEN

    -- Check if a record already exists for NI Number Person ID Type for the current applicant
    OPEN cur_alt_pers_dtls ( p_person_id, p_ninumber_alt_type );
    FETCH cur_alt_pers_dtls INTO cur_alt_pers_dtls_rec;

    IF cur_alt_pers_dtls%FOUND THEN

      -- If UCAS NI Number  is not equal to the existing OSS Alternate Person ID
      -- Then Log the message
      IF p_ni_number <> cur_alt_pers_dtls_rec.api_person_id THEN

        fnd_message.set_name('IGS','IGS_UC_NI_NUM_NOT_MATCH');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

      ELSIF cur_alt_pers_dtls_rec.end_dt IS NOT NULL THEN

        fnd_message.set_name('IGS','IGS_UC_NI_NUM_END_DATED');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

      END IF;

    ELSE

      -- Check whether the NI Number Alternate Person ID Type is defined as Unique
      OPEN cur_pers_type_unique(p_ninumber_alt_type);
      FETCH cur_pers_type_unique INTO l_dummy;

      -- Check whether the NI Number is used by another person or not
      OPEN cur_pers_id_exist(p_ni_number, p_ninumber_alt_type);
      FETCH cur_pers_id_exist INTO l_dummy;

      -- If NI Number Alternate Person ID Type is defined as Unique and NI Number is used by another person
      --    display log message 'Warning - UCAS NI Number is in use by another person- please review
      IF cur_pers_type_unique%FOUND AND cur_pers_id_exist%FOUND THEN

        fnd_message.set_name('IGS','IGS_UC_NI_NUM_END_DATED');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

      ELSE

        -- Populate the IGS_AD_API_INT table
        INSERT INTO igs_ad_api_int (
          interface_api_id
          ,interface_id
          ,person_id_type
          ,alternate_id
          ,status
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login )
        VALUES(
          IGS_AD_API_INT_S.NEXTVAL
          ,p_interface_id
          ,p_ninumber_alt_type
          ,p_ni_number
          ,'2'
          ,g_created_by
          ,SYSDATE
          ,g_last_updated_by
          ,SYSDATE
          ,g_last_update_login );

      END IF;
      CLOSE cur_pers_type_unique;
      CLOSE cur_pers_id_exist;

    END IF;
    CLOSE cur_alt_pers_dtls;

  END IF;

  -- Creating the Alternate ID type for SCN column
  IF p_scn IS NOT NULL THEN

    -- Check if a record already exists for UCASREGNO Person ID Type for the current applicant
    cur_alt_pers_dtls_rec := NULL;
    OPEN cur_alt_pers_dtls ( p_person_id, 'UCASREGNO' );
    FETCH cur_alt_pers_dtls INTO cur_alt_pers_dtls_rec;

    IF cur_alt_pers_dtls%FOUND THEN

      -- If UCAS SCN  is not equal to the existing OSS Alternate Person ID
      -- Then Log the message in the Log file
      IF p_scn <> cur_alt_pers_dtls_rec.api_person_id THEN

        fnd_message.set_name('IGS','IGS_UC_SCN_NOT_MATCH');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

      ELSIF cur_alt_pers_dtls_rec.end_dt IS NOT NULL THEN

        fnd_message.set_name('IGS','IGS_UC_SCN_END_DATED');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

      END IF;

    ELSE

      -- Check whether the 'UCASREGNO' Alternate Person ID Type is defined as Unique
      OPEN cur_pers_type_unique('UCASREGNO');
      FETCH cur_pers_type_unique INTO l_dummy;

      -- Check whether the SCN is used by another person or not
      OPEN cur_pers_id_exist(p_scn, 'UCASREGNO');
      FETCH cur_pers_id_exist INTO l_dummy;

      -- If UCASREGNO Alternate Person ID Type is defined as Unique and SCN is used by another person
      --    display log message 'Warning - SCN is in use by another person- please review
      IF cur_pers_type_unique%FOUND AND cur_pers_id_exist%FOUND THEN

        fnd_message.set_name('IGS','IGS_UC_SCN_IN_USE');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

      ELSE

        INSERT INTO igs_ad_api_int (
          interface_api_id
          ,interface_id
          ,person_id_type
          ,alternate_id
          ,status
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login  )
        VALUES   (
          IGS_AD_API_INT_S.NEXTVAL
          ,p_interface_id
          ,'UCASREGNO'
          ,p_scn
          ,'2'
          ,g_created_by
          ,SYSDATE
          ,g_last_updated_by
          ,SYSDATE
          ,g_last_update_login );

      END IF;
      CLOSE cur_pers_type_unique;
      CLOSE cur_pers_id_exist;

    END IF;
    CLOSE cur_alt_pers_dtls;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_app_valid_status := FALSE;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_UC_EXP_APPLICANT_DTLS.POP_API_INT'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.LOG,fnd_message.get());

END pop_api_int;


PROCEDURE pop_res_dtls_int( p_rescat IN VARCHAR2,
                            p_application_date IN DATE,
                            p_system_code IN VARCHAR2,
                            p_interface_id IN NUMBER,
                            p_cal_type IN VARCHAR2, -- anwest UCFD040 Bug# 4015492 Added new parameter
                            p_sequence_number IN NUMBER, -- anwest UCFD040 Bug# 4015492 Added new parameter
                            p_app_valid_status IN OUT NOCOPY BOOLEAN) AS
  /******************************************************************
  Created By      : AYEDUBAT
  Date Created By : 16-JUN-2003
  Purpose         : Populate the Residency Details Interface Table, IGS_PE_RES_DTLS_INT
                    and set the parameter,p_app_valid_status to FALSE
                    if any validation is failed or an exception is raised.
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT
   dsridhar   25-SEP-2003  Bug No. 2980137. While inserting into IGS_PE_RES_DTLS_INT,
                           the EVALUATOR field is populated with PERSON_NUMBER instead
               of DECISION_MAKE_ID. Added a cursor to get the PERSON_NUMBER
               from DECISION_MAKE_ID. Added a new variable p_retcode to this
               procedure to return the error code in case of an error.
   rgangara   10-APR-2004  Bug 3553352. Removed cursor cur_uc_defaults and associated
                           validation as this has been moved to top of the process as
                           mandatory check instead of doing it at AppNo level.
   anwest     25-NOV-2004  UCFD040 - Bug# 4015492 Added 2 new parameters to the signature
               and updated the INSERT statement to include these and remove
               START_DT
  ***************************************************************** */

  -- Fetch the HESA Mapping value
  CURSOR cur_hesa_map (cp_assoc IGS_HE_CODE_MAP_VAL.association_code%TYPE,
                       cp_map1 IGS_HE_CODE_MAP_VAL.map2%TYPE ) IS
    SELECT map2
    FROM IGS_HE_CODE_MAP_VAL
    WHERE association_code = cp_assoc
    AND   map1  = cp_map1;
  l_oss_val IGS_HE_CODE_MAP_VAL.map2%TYPE;

  l_residency_status_cd IGS_PE_RES_DTLS.residency_status_cd%TYPE;

  -- Cursor to fetch the person number based on person id. Bug No. 2980137.
  CURSOR cur_person_number IS
  SELECT pv.person_number
    FROM igs_pe_person_base_v pv, igs_uc_defaults ucd
   WHERE pv.person_id = ucd.decision_make_id
     AND ucd.system_code = p_system_code;

  l_person_number igs_pe_person_base_v.person_number%TYPE;

BEGIN

  -- Importing the Residency Details for p_rescat

  -- Find the OSS mapping value for the UCAS Residential Category value using the
  -- HESA Association Code,UC_OSS_RESCAT_ASSOC
  l_residency_status_cd := NULL ;
  OPEN cur_hesa_map ('UC_OSS_RESCAT_ASSOC', p_rescat) ;
  FETCH cur_hesa_map INTO l_residency_status_cd ;
  CLOSE cur_hesa_map ;

  IF l_residency_status_cd IS NULL THEN
    p_app_valid_status := FALSE;
    fnd_message.set_name('IGS','IGS_UC_INV_MAPPING_VAL');
    fnd_message.set_token('CODE', p_rescat);
    fnd_message.set_token('TYPE', 'RESIDENTIAL CATEGORY');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF ;


  IF p_app_valid_status = TRUE THEN

    -- Bug No. 2980137. Fetching the Person Number based on decision_make_id
    l_person_number := NULL;
    OPEN cur_person_number;
    FETCH cur_person_number INTO l_person_number;
    CLOSE cur_person_number;

    -- Populate the residency details import interface table,IGS_PE_RES_DTLS_INT
    INSERT INTO IGS_PE_RES_DTLS_INT  (
      INTERFACE_RES_ID,
      INTERFACE_ID,
      RESIDENCY_STATUS_CD,
      RESIDENCY_CLASS_CD,
      EVALUATION_DATE,
      EVALUATOR,
      STATUS,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      CAL_TYPE, -- anwest UCFD040 Bug# 4015492 Added new parameter
      SEQUENCE_NUMBER) -- anwest UCFD040 Bug# 4015492 Added new parameter
    VALUES (
      igs_pe_res_dtls_int_s.NEXTVAL
      ,p_interface_id
      ,l_residency_status_cd
      ,fnd_profile.value('IGS_FI_RES_CLASS_ID')
      ,TRUNC(SYSDATE)
      ,l_person_number  -- Bug No. 2980137. Replaced decision_make_id with l_person_number
      ,'2'   -- Pending Status
      ,g_created_by
      ,SYSDATE
      ,g_last_updated_by
      ,SYSDATE
      ,g_last_update_login
      ,p_cal_type -- anwest UCFD040 Bug# 4015492 Added new parameter
      ,p_sequence_number); -- anwest UCFD040 Bug# 4015492 Added new parameter

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_app_valid_status := FALSE;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_UC_EXP_APPLICANT_DTLS.POP_RES_DTLS_INT'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.LOG,fnd_message.get());

END pop_res_dtls_int;

PROCEDURE pop_acad_hist_int( p_person_id IN NUMBER,
                             p_person_number IN VARCHAR2,
                             p_school IN NUMBER,
                             p_interface_id IN NUMBER,
                             p_app_valid_status IN OUT NOCOPY BOOLEAN) AS
  /******************************************************************
  Created By      : JTMATHEW
  Date Created By : 08-APR-2005
  Purpose         : Populate the Admission Interface Table, IGS_AD_ACADHIS_INT_ALL for
                    importing the Academic History data and set the parameter,p_app_valid_status
                    to FALSE if any validation is failed or an exception is raised.
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT
  jchin       24-Feb-2006  Modified for R12 perf bugs 4950293
  ***************************************************************** */

  -- UCAS Association mapping
  CURSOR cur_ucas_oss_map (cp_assoc IGS_HE_CODE_MAP_VAL.association_code%TYPE,
                           cp_map1 IGS_HE_CODE_MAP_VAL.map2%TYPE ) IS
    SELECT map2
    FROM IGS_HE_CODE_MAP_VAL
    WHERE association_code = cp_assoc
    AND   map1  = cp_map1;

  -- get the Academic history record for the student
  -- jchin - bug 4950293
  CURSOR  cur_get_hist_details ( cp_person_id igs_ad_acad_history_v.person_id%TYPE ,
                                 cp_inst_cd igs_ad_acad_history_v.institution_code%TYPE ) IS
    SELECT 'X'
    FROM  igs_ad_acad_history_v a
    WHERE a.person_id = cp_person_id
    AND   a.institution_code = cp_inst_cd ;

  l_oss_inst        igs_he_code_map_val.map2%TYPE;
  l_acad_hist_rec   cur_get_hist_details%ROWTYPE;
  l_mapping_failed VARCHAR2(1) ;

BEGIN

      -- initialize variables
      l_acad_hist_rec := NULL;
      l_oss_inst := NULL;
      l_mapping_failed := 'N';

      -- Fetch the OSS school value when given the UCAS school value
      OPEN cur_ucas_oss_map('UC_OSS_HE_INS_ASSOC', p_school);
      FETCH cur_ucas_oss_map INTO l_oss_inst;
      IF (cur_ucas_oss_map%NOTFOUND) THEN

          FND_MESSAGE.Set_Name('IGS','IGS_UC_NO_INST');
          FND_MESSAGE.Set_Token('PERSON_ID',p_person_number);
          FND_MESSAGE.Set_Token('CODE',p_school );
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.get );
          l_mapping_failed := 'Y';

      END IF;
      CLOSE cur_ucas_oss_map;

      IF l_mapping_failed = 'N' THEN

          OPEN cur_get_hist_details(p_person_id,l_oss_inst) ;
          FETCH cur_get_hist_details INTO l_acad_hist_rec;

          IF cur_get_hist_details%NOTFOUND THEN

            --  When no Academic History record exists for the person and OSS Institution passed
            --  Create a new record in Academic History Interface table.

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
                     p_interface_id,
                     l_oss_inst,
                     'N',
                     NULL,
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
                     DECODE(fnd_global.conc_request_id,-1,NULL,SYSDATE) );

          END IF;    -- End of record already exists check => cur_get_hist_details%NOTFOUND
          CLOSE cur_get_hist_details ;

      END IF; -- Mapping failed check


EXCEPTION
  WHEN OTHERS THEN
    p_app_valid_status := FALSE;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_UC_EXP_APPLICANT_DTLS.POP_ACAD_HIST_INT'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.LOG,fnd_message.get());

END pop_acad_hist_int;

PROCEDURE pop_citizen_int ( p_nationality IN NUMBER,
                            p_dual_nationality IN NUMBER,
                            p_person_id IN NUMBER,
                            p_application_date IN DATE,
                            p_interface_id IN NUMBER,
                            p_app_valid_status IN OUT NOCOPY BOOLEAN) AS
  /******************************************************************
  Created By      : AYEDUBAT
  Date Created By : 16-JUN-2003
  Purpose         : Populate the Interface Table, IGS_PE_CITIZEN_INT
                    and set the parameter,p_app_valid_status to FALSE
                    if any validation is failed or an exception is raised.
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT

  ***************************************************************** */

  -- Fetch the HESA Mapping value
  CURSOR cur_hesa_map (cp_assoc IGS_HE_CODE_MAP_VAL.association_code%TYPE,
                       cp_map1 IGS_HE_CODE_MAP_VAL.map2%TYPE ) IS
    SELECT map2
    FROM IGS_HE_CODE_MAP_VAL
    WHERE association_code = cp_assoc
    AND   map1  = cp_map1;
  l_oss_val IGS_HE_CODE_MAP_VAL.map2%TYPE;

  CURSOR cur_citizen_exist (cp_person_id IGS_PE_CITIZENSHIP_V.party_id%TYPE,
                            cp_country_code IGS_PE_CITIZENSHIP_V.country_code%TYPE) IS
    SELECT 'X'
    FROM IGS_PE_CITIZENSHIP_V
    WHERE party_id = cp_person_id
    AND   country_code = cp_country_code;
  l_dummy VARCHAR2(1);

BEGIN

  /* Populating the Interface Table for Nationality Details creation */
  IF p_nationality IS NOT NULL THEN

    -- Get the OSS mapping value for nationality
    l_oss_val := NULL;
    OPEN cur_hesa_map('UC_OSS_HE_NAT_ASSOC', p_nationality);
    FETCH cur_hesa_map INTO l_oss_val;

    IF cur_hesa_map%NOTFOUND THEN

      p_app_valid_status := FALSE;
      fnd_message.set_name('IGS','IGS_UC_INV_MAPPING_VAL');
      fnd_message.set_token('CODE', p_nationality);
      fnd_message.set_token('TYPE', 'NATIONALITY');
      fnd_file.put_line(fnd_file.log, fnd_message.get);

    ELSE

      -- Check if Nationality already exists as citizenship for the current applicant
      OPEN cur_citizen_exist ( p_person_id, l_oss_val);
      FETCH cur_citizen_exist INTO l_dummy;

      IF cur_citizen_exist%NOTFOUND THEN

        INSERT INTO igs_pe_citizen_int (
          interface_citizenship_id
          ,interface_id
          ,country_code
          ,status
          ,date_recognized
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login )
        VALUES (
          IGS_PE_CITIZEN_INT_S.NEXTVAL
          ,p_interface_id
          ,l_oss_val
          ,'2'
          ,p_application_date
          ,g_created_by
          ,SYSDATE
          ,g_last_updated_by
          ,SYSDATE
          ,g_last_update_login );

      END IF;
      CLOSE cur_citizen_exist;

    END IF;
    CLOSE cur_hesa_map;

  END IF; -- End of Nationality Import

  /* Populating the Interface Table for Dual Nationality Details creation */
  IF p_dual_nationality IS NOT NULL THEN

    l_oss_val := NULL;
    OPEN cur_hesa_map('UC_OSS_HE_NAT_ASSOC', p_dual_nationality);
    FETCH cur_hesa_map INTO l_oss_val;

    IF cur_hesa_map%NOTFOUND THEN

      p_app_valid_status := FALSE;
      fnd_message.set_name('IGS','IGS_UC_INV_MAPPING_VAL');
      fnd_message.set_token('CODE', p_dual_nationality);
      fnd_message.set_token('TYPE', 'NATIONALITY');
      fnd_file.put_line(fnd_file.log, fnd_message.get);

    ELSE

      -- Check if Dual Nationality already exists as citizenship for the current applicant
      OPEN cur_citizen_exist ( p_person_id, l_oss_val);
      FETCH cur_citizen_exist INTO l_dummy;

      IF cur_citizen_exist%NOTFOUND THEN

        INSERT INTO igs_pe_citizen_int (
          interface_citizenship_id
          ,interface_id
          ,country_code
          ,status
          ,date_recognized
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login )
        VALUES (
          IGS_PE_CITIZEN_INT_S.NEXTVAL
          ,p_interface_id
          ,l_oss_val
          ,'2'
          ,p_application_date
          ,g_created_by
          ,SYSDATE
          ,g_last_updated_by
          ,SYSDATE
          ,g_last_update_login );

      END IF;
      CLOSE cur_citizen_exist;

    END IF;
    CLOSE cur_hesa_map;

  END IF; -- End of Dual Nationality Import

EXCEPTION
  WHEN OTHERS THEN
    p_app_valid_status := FALSE;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_UC_EXP_APPLICANT_DTLS.POP_CITIZEN_INT'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.LOG,fnd_message.get());

END pop_citizen_int;


PROCEDURE pop_disability_int(p_special_needs IN VARCHAR2,
                             p_person_id IN NUMBER,
                             p_application_date IN DATE,
                             p_interface_id IN NUMBER,
                             p_app_valid_status IN OUT NOCOPY BOOLEAN) AS
  /******************************************************************
  Created By      : AYEDUBAT
  Date Created By : 16-JUN-2003
  Purpose         : Puplate the Admission Interface Table, IGS_AD_DISABLTY_INT_ALL for
                    importing the Special Needs data and set the parameter,p_app_valid_status
                    to FALSE if any validation is failed or an exception is raised.
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT
   jchakrab   20-Sep-2004  Modified for HEFD350 - replaced 3-way mapping UC_OSS_HE_DIS_ASSOC
                           with new 2-way mapping UCAS_OSS_DISABILITY_ASSOC
  ***************************************************************** */

  -- Fetch the HESA Mapping value
  CURSOR cur_hesa_map (cp_assoc IGS_HE_CODE_MAP_VAL.association_code%TYPE,
                       cp_map1 IGS_HE_CODE_MAP_VAL.map2%TYPE ) IS
    SELECT map2
    FROM IGS_HE_CODE_MAP_VAL
    WHERE association_code = cp_assoc
    AND   map1  = cp_map1;
  l_oss_val IGS_HE_CODE_MAP_VAL.map2%TYPE;

  CURSOR cur_disablty_dtls ( cp_person_id IGS_PE_PERS_DISABLTY_V.person_id%TYPE,
                             cp_disability_type IGS_PE_PERS_DISABLTY_V.disability_type%TYPE) IS
    SELECT start_date, end_date
    FROM IGS_PE_PERS_DISABLTY
    WHERE person_id = cp_person_id
    AND disability_type = cp_disability_type
    ORDER BY start_date DESC;
  cur_disablty_dtls_rec cur_disablty_dtls%ROWTYPE;

  -- Fetch the past disability records with end date as NULL
  CURSOR cur_other_disablty_dtls ( cp_person_id IGS_PE_PERS_DISABLTY_V.person_id%TYPE) IS
    SELECT disability_type,start_date
    FROM IGS_PE_PERS_DISABLTY
    WHERE person_id = cp_person_id
    AND TRUNC(start_date) <= TRUNC(SYSDATE)
    AND end_date IS NULL;

  l_dis_start_dt IGS_AD_DISABLTY_INT_ALL.start_date%TYPE;
  l_dis_end_dated BOOLEAN;

BEGIN

  -- Importing Special Needs

  -- get the OSS mapping value for the UCAS Special Needs column
  l_oss_val := NULL;
  OPEN cur_hesa_map('UCAS_OSS_DISABILITY_ASSOC', p_special_needs);
  FETCH cur_hesa_map INTO l_oss_val;

  IF cur_hesa_map%NOTFOUND THEN

    p_app_valid_status := FALSE;
    fnd_message.set_name('IGS','IGS_UC_INV_MAPPING_VAL');
    fnd_message.set_token('CODE', p_special_needs);
    fnd_message.set_token('TYPE', 'DISABILITY TYPE');
    fnd_file.put_line(fnd_file.log, fnd_message.get);

  ELSE

    -- Check if Special Needs already exists as disability for the current applicant
    OPEN cur_disablty_dtls(p_person_id, l_oss_val );
    FETCH cur_disablty_dtls INTO cur_disablty_dtls_rec;

    IF cur_disablty_dtls%FOUND THEN

      IF cur_disablty_dtls_rec.end_date IS NOT NULL THEN

        fnd_message.set_name('IGS','IGS_UC_DISABLTY_END_DATED');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

      END IF;

    ELSE -- If record not found, then populate the interface table

      l_dis_end_dated := FALSE;
      --- Loop through the existing disability records with end date as NULL
      FOR cur_other_disablty_dtls_rec IN cur_other_disablty_dtls(p_person_id) LOOP

        -- Populate the Interface Table for the Disability type with End Date as SYSDATE
        -- Populate the Interface Table, IGS_AD_DISABLTY_INT_ALL
        l_dis_end_dated := TRUE;
        INSERT INTO igs_ad_disablty_int_all (
          interface_disablty_id
          ,interface_id
          ,disability_type
          ,start_date
          ,end_date
          ,status
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login )
        VALUES (
          IGS_AD_DISABLTY_INT_S.NEXTVAL
          ,p_interface_id
          ,cur_other_disablty_dtls_rec.disability_type
          ,cur_other_disablty_dtls_rec.start_date
          ,TRUNC(SYSDATE)
          ,'2'
          ,g_created_by
          ,SYSDATE
          ,g_last_updated_by
          ,SYSDATE
          ,g_last_update_login );

      END LOOP;

      -- If the Previous disability record is end dated then create a new record with
      -- Start Date as SYSDATE else with Application Date
      IF l_dis_end_dated = TRUE THEN
         l_dis_start_dt := TRUNC(SYSDATE);
      ELSE
         l_dis_start_dt := TRUNC(p_application_date);
      END IF;

      -- Populate the Interface Table, IGS_AD_DISABLTY_INT_ALL
      INSERT INTO igs_ad_disablty_int_all (
        interface_disablty_id
        ,interface_id
        ,disability_type
        ,start_date
        ,status
        ,created_by
        ,creation_date
        ,last_updated_by
        ,last_update_date
        ,last_update_login )
      VALUES (
        IGS_AD_DISABLTY_INT_S.NEXTVAL
        ,p_interface_id
        ,l_oss_val
        ,l_dis_start_dt
        ,'2'
        ,g_created_by
        ,SYSDATE
        ,g_last_updated_by
        ,SYSDATE
        ,g_last_update_login );

    END IF;
    CLOSE cur_disablty_dtls;

  END IF;
  CLOSE cur_hesa_map;

EXCEPTION
  WHEN OTHERS THEN
    p_app_valid_status := FALSE;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_UC_EXP_APPLICANT_DTLS.POP_DISABILITY_INT'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.LOG,fnd_message.get());

END pop_disability_int;


PROCEDURE pop_contact_int ( p_telephone IN VARCHAR2,
                            p_email IN VARCHAR2,
                            p_home_phone IN VARCHAR2,
                            p_mobile IN VARCHAR2,
                            p_interface_id IN NUMBER,
                            p_app_valid_status IN OUT NOCOPY BOOLEAN) AS
  /******************************************************************
  Created By      : AYEDUBAT
  Date Created By : 16-JUN-2003
  Purpose         : Puplate the Admission Interface Table, IGS_AD_CONTACTS_INT_ALL
                    and set the Parameter,p_app_valid_status to FALSE if an exception is raised
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT
  jbaber    11-Jul-05     Added mobile for UC325 - UCAS 2007 Support
  ***************************************************************** */

  --To get the Email format to populate into igs_ad_contacts_int_all table.
  CURSOR cur_email_format IS
    SELECT lookup_code
    FROM fnd_lookup_values
    WHERE lookup_type = 'EMAIL_FORMAT'
    AND enabled_flag ='Y'
    AND NVL(START_DATE_ACTIVE,SYSDATE) <=SYSDATE
    AND NVL(END_DATE_ACTIVE,SYSDATE) >= SYSDATE
    AND LANGUAGE = USERENV('LANG') AND view_application_id = 222 AND security_group_id(+) = 0;

  l_email_format FND_LOOKUP_VALUES.lookup_code%TYPE;

BEGIN

  -- Populate the Admission Contacts Interface Table for Primary Phone Number
  IF p_telephone IS NOT NULL THEN

    INSERT INTO igs_ad_contacts_int_all (
      interface_contacts_id
      ,interface_id
      ,phone_number
      ,status
      ,contact_point_type
      ,primary_flag
      ,phone_line_type
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login )
    VALUES (
      IGS_AD_CONTACTS_INT_S.NEXTVAL
      ,p_interface_id
      ,p_telephone
      ,'2'
      ,'PHONE'
      ,'Y'
      ,'GEN'
      ,g_created_by
      ,SYSDATE
      ,g_last_updated_by
      ,SYSDATE
      ,g_last_update_login );

  END IF;

  -- Populate the Admission Contacts Interface Table for E-Mail Address creation
  IF p_email IS NOT NULL THEN

    -- Find the EMAIL Format to be used from the Look ups
    OPEN cur_email_format;
    FETCH cur_email_format INTO l_email_format;
    CLOSE cur_email_format;

    INSERT INTO igs_ad_contacts_int_all (
      interface_contacts_id
      ,interface_id
      ,email_address
      ,email_format
      ,status
      ,contact_point_type
      ,primary_flag
      ,phone_line_type
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login )
    VALUES (
      IGS_AD_CONTACTS_INT_S.NEXTVAL
      ,p_interface_id
      ,p_email
      ,l_email_format
      ,'2'
      ,'EMAIL'
      ,'N'
      ,'GEN'
      ,g_created_by
      ,SYSDATE
      ,g_last_updated_by
      ,SYSDATE
      ,g_last_update_login );

  END IF;

  -- Populate the Admission Contacts Interface Table for Home Phone Number creation
  IF p_home_phone IS NOT NULL THEN

    INSERT INTO igs_ad_contacts_int_all (
      interface_contacts_id
      ,interface_id
      ,phone_number
      ,status
      ,contact_point_type
      ,primary_flag
      ,phone_line_type
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login )
    VALUES (
      IGS_AD_CONTACTS_INT_S.NEXTVAL
      ,p_interface_id
      ,p_home_phone
      ,'2'
      ,'PHONE'
      ,'N'
      ,'GEN'
      ,g_created_by
      ,SYSDATE
      ,g_last_updated_by
      ,SYSDATE
      ,g_last_update_login );

  END IF;

  -- Populate the Admission Contacts Interface Table for Mobile Number creation
  IF p_mobile IS NOT NULL THEN

    INSERT INTO igs_ad_contacts_int_all (
      interface_contacts_id
      ,interface_id
      ,phone_number
      ,status
      ,contact_point_type
      ,primary_flag
      ,phone_line_type
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login )
    VALUES (
      IGS_AD_CONTACTS_INT_S.NEXTVAL
      ,p_interface_id
      ,p_mobile
      ,'2'
      ,'PHONE'
      ,'N'
      ,'MOBILE'
      ,g_created_by
      ,SYSDATE
      ,g_last_updated_by
      ,SYSDATE
      ,g_last_update_login );

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_app_valid_status := FALSE;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_UC_EXP_APPLICANT_DTLS.POP_CONTACT_INT'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.LOG,fnd_message.get());

END pop_contact_int;


FUNCTION get_country_code(p_app_no            IN IGS_UC_APP_ADDRESES.app_no%TYPE,
                          p_ucas_country_code IN VARCHAR2,
                          p_address_area      IN VARCHAR2,
                          p_address4          IN VARCHAR2,
                          p_adr_type          IN VARCHAR2)
RETURN VARCHAR2 AS
  /******************************************************************
  Created By      : JBaber
  Date Created By : 16-Jul-2006
  Purpose         : Derive country code value
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT
  ***************************************************************** */

  -- Fetch the Territory Code for the Address4 or HomeAddress4
  CURSOR cur_short_name ( p_short_name FND_TERRITORIES_VL.territory_short_name%TYPE ) IS
    SELECT territory_code
    FROM FND_TERRITORIES_VL
    WHERE territory_short_name = p_short_name ;
  cur_short_name_rec cur_short_name%ROWTYPE ;

  -- Fetch the OSS Nationality Code mapped to Domicile APR
  CURSOR cur_map (p_assoc igs_he_code_map_val.association_code%TYPE,
                  p_map1  igs_he_code_map_val.map2%TYPE ) IS
    SELECT map2
    FROM  IGS_HE_CODE_MAP_VAL
    WHERE association_code = p_assoc
    AND   map1  = p_map1;

  l_country_code        IGS_AD_ADDR_INT_ALL.country%TYPE;

BEGIN

  /* Derive Country Code */
  l_country_code := NULL ;
  IF p_ucas_country_code IS NOT NULL THEN

      -- This gets the US standard country code
      OPEN cur_map('UCAS_OSS_COUNTRY_ASSOC', p_ucas_country_code);
      FETCH cur_map INTO l_country_code;
      CLOSE cur_map;

  ELSE

      -- If address4 is TCA Country description then consider country code
      -- associated with Country description
      OPEN cur_short_name(p_address4);
      FETCH cur_short_name INTO cur_short_name_rec ;

      IF  cur_short_name%FOUND  THEN
        l_country_code := cur_short_name_rec.territory_code;
      END IF;

      CLOSE cur_short_name ;

  END IF;

  -- If country code could not be derived,
  -- assign the Obsolete Country CD Territory
  IF l_country_code IS NULL THEN
    l_country_code := 'ZR' ;

    -- Display warning that the country for this student address should be checked
    fnd_message.set_name('IGS','IGS_UC_INVAL_COUNTRY_CODE') ;
    fnd_message.set_token('APPNO',p_app_no) ;
    fnd_message.set_token('ADR_TYPE',p_adr_type) ;
    fnd_file.put_line(fnd_file.log, fnd_message.get) ;
  END IF ;

  RETURN l_country_code;

END get_country_code;


PROCEDURE pop_address_int ( p_app_address_dtls_rec IN IGS_UC_APP_ADDRESES%ROWTYPE,
                            p_domocile_apr IN VARCHAR2,
                            p_interface_id IN NUMBER,
                            p_addr_usage_home IN VARCHAR2,
                            p_addr_usage_corr IN VARCHAR2,
                            p_app_valid_status IN OUT NOCOPY BOOLEAN) AS
  /******************************************************************
  Created By      : AYEDUBAT
  Date Created By : 16-JUN-2003
  Purpose         : Puplate the Admission Interface Tables,
                    IGS_AD_ADDR_INT_ALL and IGS_AD_ADDRUSAGE_INT_ALL
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT

  anwest      20-Sep-2004  Bug# 3622076 - Code to prevent NULL value
               for UCAS home_address1
  ***************************************************************** */


  l_country_code IGS_AD_ADDR_INT_ALL.country%TYPE;
  l_interface_addr_id IGS_AD_ADDR_INT_ALL.interface_addr_id%TYPE;

  -- anwest Bug# 3622076 Local variable to store first line of address in
  l_home_address1 igs_ad_addr_int_all.addr_line_1%TYPE;

  l_home_flag  BOOLEAN := TRUE;
  l_corr_flag  BOOLEAN := TRUE;
  l_usage      VARCHAR2(80);

BEGIN


  -- Check if home address exists
  IF  p_app_address_dtls_rec.home_address1 IS NULL AND
      p_app_address_dtls_rec.home_address2 IS NULL AND
      p_app_address_dtls_rec.home_address3 IS NULL AND
      p_app_address_dtls_rec.home_address4 IS NULL AND
      p_app_address_dtls_rec.home_postcode IS NULL  THEN

      l_home_flag := FALSE;

  END IF;

  -- Check if correspondence address exists
  IF  p_app_address_dtls_rec.address1 IS NULL AND
      p_app_address_dtls_rec.address2 IS NULL AND
      p_app_address_dtls_rec.address3 IS NULL AND
      p_app_address_dtls_rec.address4 IS NULL AND
      p_app_address_dtls_rec.post_code IS NULL  THEN

      l_corr_flag := FALSE;

  END IF;

  -------------------------------------------------------------------
  /* Import correspondence address  */
  -------------------------------------------------------------------
  IF l_corr_flag THEN

    -- Logic for caluculating the 'COUNTRY' coumn value for both Correspondence Address
    l_country_code := get_country_code(p_app_address_dtls_rec.app_no,
                                       p_app_address_dtls_rec.country_code,
                                       p_app_address_dtls_rec.address_area,
                                       p_app_address_dtls_rec.address4,
                                       'CORRESPONDENCE') ;

    -- Populate the Address Interface table for single address, and secondary address
    l_interface_addr_id := NULL;
    INSERT INTO igs_ad_addr_int_all (
      interface_addr_id
      ,interface_id
      ,addr_line_1
      ,addr_line_2
      ,addr_line_3
      ,addr_line_4
      ,postcode
      ,country
      ,delivery_point_code
      ,correspondence_flag
      ,start_date
      ,status
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login  )
    VALUES (
      IGS_AD_ADDR_INT_S.NEXTVAL
      ,p_interface_id
      ,p_app_address_dtls_rec.address1
      ,p_app_address_dtls_rec.address2
      ,p_app_address_dtls_rec.address3
      ,p_app_address_dtls_rec.address4
      ,p_app_address_dtls_rec.post_code
      ,l_country_code
      ,p_app_address_dtls_rec.mail_sort
      ,'Y'
      ,SYSDATE
      ,'2'
      ,g_created_by
      ,SYSDATE
      ,g_last_updated_by
      ,SYSDATE
      ,g_last_update_login )
    RETURNING interface_addr_id INTO l_interface_addr_id ;

    -- If no home address was provided then correspondence address usage is set to HOME
    IF NOT l_home_flag THEN
      l_usage := NVL(p_addr_usage_home,'HOME');
    ELSE
      l_usage := NVL(p_addr_usage_corr,'CORR');
    END IF;

    -- Populating the Address Usage Interface Table for Correspondence Address
    INSERT INTO igs_ad_addrusage_int_all (
      interface_addrusage_id
      ,interface_addr_id
      ,site_use_code
      ,status
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login )
    VALUES (
      igs_ad_addrusage_int_s.NEXTVAL
      ,l_interface_addr_id
      ,l_usage
      ,'2'
      ,g_created_by
      ,SYSDATE
      ,g_last_updated_by
      ,SYSDATE
      ,g_last_update_login );

  END IF;


  -------------------------------------------------------------------
  /* Import home address  */
  -------------------------------------------------------------------
  IF l_home_flag THEN

    -- Logic for caluculating the 'COUNTRY' coumn value for both Correspondence Address
    l_country_code := get_country_code(p_app_address_dtls_rec.app_no,
                                       p_app_address_dtls_rec.home_country_code,
                                       p_app_address_dtls_rec.address_area,
                                       p_app_address_dtls_rec.home_address4,
                                       'HOME') ;

    -- anwest Bug# 3622076 If address line 1 is NULL substitute dummy value
    IF p_app_address_dtls_rec.home_address1 IS NULL THEN
        fnd_message.set_name('IGS', 'IGS_UC_NO_ADD_GIVEN');
        l_home_address1 := fnd_message.get;
    ELSE
        l_home_address1 := p_app_address_dtls_rec.home_address1;
    END IF;

    l_interface_addr_id := NULL;
    INSERT INTO igs_ad_addr_int_all(
      interface_addr_id
      ,interface_id
      ,addr_line_1
      ,addr_line_2
      ,addr_line_3
      ,addr_line_4
      ,postcode
      ,country
      ,delivery_point_code
      ,correspondence_flag
      ,start_date
      ,status
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login )
    VALUES (
      IGS_AD_ADDR_INT_S.NEXTVAL
      ,p_interface_id
      ,l_home_address1
      ,p_app_address_dtls_rec.home_address2
      ,p_app_address_dtls_rec.home_address3
      ,p_app_address_dtls_rec.home_address4
      ,p_app_address_dtls_rec.home_postcode
      ,l_country_code
      ,p_app_address_dtls_rec.mail_sort
      ,'N'
      ,SYSDATE
      ,'2'
      ,g_created_by
      ,SYSDATE
      ,g_last_updated_by
      ,SYSDATE
      ,g_last_update_login )
    RETURNING interface_addr_id INTO l_interface_addr_id ;

    -- Populating the Address Usage Interface Table for Home Address
    -- Usage is given by p_addr_usage_home if available, otherwise use HOME
    INSERT INTO igs_ad_addrusage_int_all (
      interface_addrusage_id
      ,interface_addr_id
      ,site_use_code
      ,status
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login )
    VALUES (
      igs_ad_addrusage_int_s.NEXTVAL
      ,l_interface_addr_id
      ,NVL(p_addr_usage_home, 'HOME')
      ,'2'
      ,g_created_by
      ,SYSDATE
      ,g_last_updated_by
      ,SYSDATE
      ,g_last_update_login );

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    p_app_valid_status := FALSE;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_UC_EXP_APPLICANT_DTLS.POP_ADDRESS_INT'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.LOG,fnd_message.get());

END pop_address_int;

FUNCTION  chk_src_cat ( p_source_type_id IN NUMBER,
                        p_category IN VARCHAR2 )
RETURN BOOLEAN AS
  /******************************************************************
  Created By      : AYEDUBAT
  Date Created By : 16-JUN-2003
  Purpose         : To check whether a source type is included or not
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT

  ***************************************************************** */

  l_dummy VARCHAR2(1);
  CURSOR cur_src_included ( cp_source_type_id IGS_AD_SOURCE_CAT.source_type_id%TYPE,
                            cp_category  IGS_AD_SOURCE_CAT.category_name%TYPE) IS
  SELECT 'X'
  FROM  IGS_AD_SOURCE_CAT
  WHERE source_type_id = cp_source_type_id AND
        category_name = cp_category AND
        include_ind = 'Y';

BEGIN

  -- Check whether the Source Type is included
  OPEN cur_src_included(p_source_type_id, p_category);
  FETCH cur_src_included INTO l_dummy;

  -- If included return True, otherwise return False
  IF cur_src_included%FOUND THEN
    CLOSE cur_src_included;
    RETURN TRUE;
  ELSE
    CLOSE cur_src_included;
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF cur_src_included%ISOPEN THEN
      CLOSE cur_src_included;
    END IF;
    RETURN FALSE;

END chk_src_cat;


PROCEDURE adm_import_process( p_ad_batch_id IN NUMBER,
                              p_source_type_id IN NUMBER,
                              p_status IN OUT NOCOPY BOOLEAN) IS
  /******************************************************************
  Created By      : AYEDUBAT
  Date Created By : 16-JUN-2003
  Purpose         : To Call Admission Import Process API
  Known limitations,enhancements,remarks:

  CHANGE HISTORY:
   WHO        WHEN         WHAT

  ***************************************************************** */

  CURSOR cur_match_set ( cp_source_type_id IGS_PE_MATCH_SETS.source_type_id%TYPE) IS
    SELECT match_set_id
    FROM IGS_PE_MATCH_SETS
    WHERE  source_type_id = cp_source_type_id;
  l_match_set_id IGS_PE_MATCH_SETS.match_set_id%TYPE;

  -- Fetch the Interface ID for the passed Batch ID
  CURSOR cur_ad_interface ( cp_batch_id IGS_AD_INTERFACE_ALL.batch_id%TYPE) IS
    SELECT interface_id
    FROM IGS_AD_INTERFACE_ALL
    WHERE batch_id = cp_batch_id;
  l_interface_id IGS_AD_INTERFACE_ALL.interface_id%TYPE;

  l_interface_run_id igs_ad_interface_ctl.interface_run_id%TYPE;
  l_errbuff VARCHAR2(100) ;
  l_retcode NUMBER ;


BEGIN

  -- Initialize the variables
  l_interface_run_id := NULL ;
  l_errbuff:= NULL ;
  l_retcode := NULL ;

  -- Get the match set criteria corresponding to the ucas source type to be used for the person import
  l_match_set_id := NULL ;
  OPEN cur_match_set(p_source_type_id);
  FETCH cur_match_set INTO l_match_set_id;
  CLOSE cur_match_set;

  -- Check whether any records exist in the Admission Interface Table for the Batch ID
  OPEN cur_ad_interface(p_ad_batch_id);
  FETCH cur_ad_interface INTO l_interface_id;

  /* The admission import process should be launched only if admission interface records are inserted
  in instance of the current run and the Source Type ID and Match Set ID are not null */
  IF NVL(p_ad_batch_id,0) <> 0 AND cur_ad_interface%FOUND AND
     NVL(p_source_type_id,0) <> 0 AND NVL(l_match_set_id,0) <> 0 THEN

    p_status := TRUE;
    -- Display the Message in the Log File
    fnd_file.put_line( fnd_file.LOG ,' ');
    fnd_message.set_name('IGS','IGS_UC_ADM_IMP_PROC_LAUNCH');
    fnd_message.set_token('REQ_ID',TO_CHAR(p_ad_batch_id));
    fnd_file.put_line( fnd_file.LOG ,fnd_message.get||'  ('||to_char(SYSDATE,'DD-MON-YYYY HH:MI:SS')||')');

    -- Call admission application import process procedure because current process
    -- has to wait until import process is finished
    IGS_AD_IMP_001.IMP_ADM_DATA ( errbuf => l_errbuff,
                                  retcode => l_retcode ,
                                  p_batch_id =>  p_ad_batch_id,
                                  p_source_type_id => p_source_type_id,
                                  p_match_set_id => l_match_set_id,
                                  p_acad_cal_type => NULL ,
                                  p_acad_sequence_number => NULL ,
                                  p_adm_cal_type => NULL ,
                                  p_adm_sequence_number => NULL ,
                                  p_admission_cat => NULL ,
                                  p_s_admission_process_type => NULL ,
                                  p_interface_run_id =>  l_interface_run_id ,
                                  p_org_id => NULL ) ;


  ELSE

    p_status := FALSE;
    -- As the required parameters are not avilable to launch Admission Import Process,
    -- Log message is populated in log file.
    fnd_file.put_line( fnd_file.LOG ,' ');
    fnd_message.set_name('IGS','IGS_UC_NOT_LAUNCH_IMP_PROC');
    fnd_file.put_line(fnd_file.log, fnd_message.get);

  END IF;
  CLOSE cur_ad_interface;

EXCEPTION
  WHEN OTHERS THEN
    p_status := FALSE;
    -- even though the admission import process completes in error , this process should continue processing
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_UC_EXP_APPLICANT_DTLS.ADM_IMPORT_PROCESS'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.LOG,fnd_message.get());

END adm_import_process;

END igs_uc_exp_applicant_dtls;

/
