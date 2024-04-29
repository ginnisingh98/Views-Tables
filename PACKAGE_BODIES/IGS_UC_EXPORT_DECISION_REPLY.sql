--------------------------------------------------------
--  DDL for Package Body IGS_UC_EXPORT_DECISION_REPLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_EXPORT_DECISION_REPLY" AS
/* $Header: IGSUC65B.pls 120.6 2006/06/19 06:04:03 anwest ship $  */

PROCEDURE export_decision( p_app_no        igs_uc_app_choices.app_no%TYPE,
                           p_choice_number igs_uc_app_choices.choice_no%TYPE ) AS
/****************************************************************
 Created By      :  ayedubat
 Date Created By :  17-SEP-2002
 Purpose         :  This process populates the admissions decision import
                    process interface tables for exporting the UCAS Decision
                    to OSS Application Outcome Status.
 Known limitations,enhancements,remarks:
 Change History
 Who        When          What
 Nishikant  01-OCT-2002   A new column extra_round_nbr added in the TBH calls of
                          the package IGS_UC_APP_CHOICES_PKG.
 ayedubat   20-OCT-2002   Added a Logic to check whether the decision is required to export or not
                          for the bug fix: 2628041
 smaddali 19-oct-2002     added igs_uc_old_oustat_pkg.delete_row call whenever
            export_to_oss_status is being set to "DC" and captured record is found ,for bug 2630219
 ayedubat 13-DEC-2002     Changed the where clause cursor,cur_oss_appl_inst to replace the local
                          variables used to compare the academic and admissions calendars for bug:2708981
 ayedubat 26-MAR-2003     Changed the procedure to create a new cursor,c_ch_system which is used to
                          create the Decision Import batch ids only for the Systems for which atleast
                          one Application Choice Record exist for the bug: 2669209
 jchakrab   03-Oct-2005   Modified for 4506750 Impact - added extra filter for IGS_AD_CODE_CLASSES.class_type_code
 jchin      20-jan-06     Modified for R12 Perf improvements - Bug 3691277 and 3691250
 jchakrab   22-May-06     Modified for 5165624
******************************************************************/

  -- Cursor to find the details of default UCAS setup defined in the SYSTEM.
  -- smaddali modified this cursor to add check for system_code , for bug 2643048 UCFD102 build
  CURSOR cur_ucas_setup( cp_system_code  igs_uc_defaults.system_code%TYPE) IS
  SELECT *
  FROM igs_uc_defaults
  WHERE system_code  = NVL(cp_system_code,system_code) ;
  cur_ucas_setup_rec cur_ucas_setup%ROWTYPE;

  -- Cursor to fetch the UCAS Application choices
  -- If both application number and choice are not passed it fetches all the application choices
  -- If only application number is passed, it fetches the App. choices of the passed app. number
  -- If both App. number and Choice are passed, it fetches only one Application
  -- smaddali modified this cursor to add the where clause of System_code check , bug 2643048 UCFD102 build
  CURSOR cur_ucas_app_choice IS
    SELECT uac.*,uac.ROWID
    FROM igs_uc_app_choices uac,
         igs_uc_defaults ud
    WHERE uac.app_no = NVL(p_app_no,uac.app_no)
    AND   uac.choice_no = NVL( p_choice_number,uac.choice_no )
    AND   uac.export_to_oss_status = 'AC'
    AND   ud.system_code = uac.system_code
    AND   ud.current_inst_code = uac.institute_code
    ORDER BY uac.ucas_cycle, uac.app_no, uac.choice_no ;
  cur_ucas_app_choice_rec cur_ucas_app_choice%ROWTYPE;

  -- Cursor to find the OSS Application Instance for the current UACS Application Choice
  -- smaddali modified this cursor to add the where clause of System_code check , bug 2643048 UCFD102 build
  -- jchin - bug 3691277 and 3691250
  CURSOR cur_oss_appl_inst( cp_app_no     igs_uc_app_choices.app_no%TYPE,
                            cp_choice_no  igs_uc_app_choices.choice_no%TYPE,
                            cp_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE) IS
    SELECT APLINST.ADM_OUTCOME_STATUS, APLINST.ADM_OFFER_RESP_STATUS,
           APLINST.PERSON_ID, APLINST.ADMISSION_APPL_NUMBER,
           APLINST.NOMINATED_COURSE_CD, APLINST.SEQUENCE_NUMBER,
           APLINST.CRV_VERSION_NUMBER, APLINST.LOCATION_CD,
           APLINST.ATTENDANCE_MODE, APLINST.ATTENDANCE_TYPE, APLINST.UNIT_SET_CD,
           APLINST.US_VERSION_NUMBER, APL.ACAD_CAL_TYPE, UAC.POINT_OF_ENTRY
    FROM   IGS_UC_APP_CHOICES UAC,
           IGS_UC_APPLICANTS UA,
           IGS_UC_DEFAULTS UD,
           IGS_AD_SS_APPL_TYP AAT,
           IGS_AD_APPL_ALL APL,
           IGS_AD_PS_APPL_INST_ALL APLINST,
           IGS_UC_SYS_CALNDRS USC
    WHERE  UAC.APP_NO = CP_APP_NO
    AND    UAC.CHOICE_NO = CP_CHOICE_NO
    AND    UAC.UCAS_CYCLE = CP_UCAS_CYCLE
    AND    UA.APP_NO = UAC.APP_NO
    AND    UA.OSS_PERSON_ID = APL.PERSON_ID
    AND    TO_CHAR (UA.APP_NO) = APL.ALT_APPL_ID
    AND    APL.CHOICE_NUMBER = UAC.CHOICE_NO
    AND    UAC.SYSTEM_CODE = UD.SYSTEM_CODE
    AND    UD.APPLICATION_TYPE = AAT.ADMISSION_APPLICATION_TYPE
    AND    UAC.SYSTEM_CODE = USC.SYSTEM_CODE
    AND    UAC.ENTRY_YEAR = USC.ENTRY_YEAR
    AND    (UAC.ENTRY_MONTH = USC.ENTRY_MONTH OR USC.ENTRY_MONTH = 0)
    AND    APL.ACAD_CAL_TYPE = USC.ACA_CAL_TYPE
    AND    APL.ACAD_CI_SEQUENCE_NUMBER = USC.ACA_CAL_SEQ_NO
    AND    APL.ADM_CAL_TYPE = USC.ADM_CAL_TYPE
    AND    APL.ADM_CI_SEQUENCE_NUMBER = USC.ADM_CAL_SEQ_NO
    AND    APL.ADMISSION_CAT = AAT.ADMISSION_CAT
    AND    APL.S_ADMISSION_PROCESS_TYPE = AAT.S_ADMISSION_PROCESS_TYPE
    AND    APL.PERSON_ID = APLINST.PERSON_ID
    AND    APL.ADMISSION_APPL_NUMBER = APLINST.ADMISSION_APPL_NUMBER
    AND    APLINST.NOMINATED_COURSE_CD = UAC.OSS_PROGRAM_CODE
    AND    APLINST.CRV_VERSION_NUMBER = UAC.OSS_PROGRAM_VERSION
    AND    APLINST.LOCATION_CD = UAC.OSS_LOCATION
    AND    APLINST.ATTENDANCE_MODE = UAC.OSS_ATTENDANCE_MODE
    AND    APLINST.ATTENDANCE_TYPE = UAC.OSS_ATTENDANCE_TYPE;
  cur_oss_appl_inst_rec cur_oss_appl_inst%ROWTYPE;

  -- Check the existence of unit set code corresponding to the application instance
  -- jchin - bug 3691277 and 3691250
  CURSOR cur_unit_set_cd(
           p_unit_set_cd  igs_ad_ps_appl_inst_all.unit_set_cd%TYPE,
           p_us_version_number  igs_ad_ps_appl_inst_all.us_version_number%TYPE,
           p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
           p_crv_version_number  igs_ad_ps_appl_inst_all.crv_version_number%TYPE,
           p_acad_cal_type  igs_ad_appl_all.acad_cal_type%TYPE,
           p_location_cd  igs_ad_ps_appl_inst_all.location_cd%TYPE,
           p_attendance_mode  igs_ad_ps_appl_inst_all.attendance_mode%TYPE,
           p_attendance_type  igs_ad_ps_appl_inst_all.attendance_type%TYPE,
           p_point_of_entry  igs_uc_app_choices.point_of_entry%TYPE
           ) IS
    SELECT US.UNIT_SET_CD,
           US.VERSION_NUMBER US_VERSION_NUMBER
    FROM   IGS_PS_OFR_UNIT_SET COUS,
           IGS_PS_OFR_OPT COO,
           IGS_EN_UNIT_SET US,
           IGS_EN_UNIT_SET_CAT USC,
           IGS_PS_US_PRENR_CFG CFG
    WHERE  COUS.UNIT_SET_CD = P_UNIT_SET_CD
    AND    COUS.US_VERSION_NUMBER = P_US_VERSION_NUMBER
    AND    COUS.COURSE_CD = P_NOMINATED_COURSE_CD
    AND    COUS.CRV_VERSION_NUMBER = P_CRV_VERSION_NUMBER
    AND    COUS.CAL_TYPE = P_ACAD_CAL_TYPE
    AND    COO.LOCATION_CD = P_LOCATION_CD
    AND    COO.ATTENDANCE_MODE = P_ATTENDANCE_MODE
    AND    COO.ATTENDANCE_TYPE = P_ATTENDANCE_TYPE
    AND    COO.COURSE_CD = COUS.COURSE_CD
    AND    COO.VERSION_NUMBER = COUS.CRV_VERSION_NUMBER
    AND    COO.CAL_TYPE = COUS.CAL_TYPE
    AND    US.UNIT_SET_CD = COUS.UNIT_SET_CD
    AND    US.VERSION_NUMBER = COUS.US_VERSION_NUMBER
    AND    US.UNIT_SET_CAT = USC.UNIT_SET_CAT
    AND    USC.S_UNIT_SET_CAT ='PRENRL_YR'
    AND    US.UNIT_SET_CD = CFG.UNIT_SET_CD
    AND    CFG.SEQUENCE_NO = NVL(P_POINT_OF_ENTRY,1)
    AND    NOT EXISTS (SELECT COURSE_CD FROM IGS_PS_OF_OPT_UNT_ST COOUS WHERE COOUS.COO_ID = COO.COO_ID)
    UNION ALL
    SELECT US.UNIT_SET_CD,
           US.VERSION_NUMBER US_VERSION_NUMBER
    FROM   IGS_PS_OF_OPT_UNT_ST COOUS,
           IGS_EN_UNIT_SET US,
           IGS_EN_UNIT_SET_CAT USC,
           IGS_PS_US_PRENR_CFG CFG
    WHERE  COOUS.UNIT_SET_CD = P_UNIT_SET_CD
    AND    COOUS.US_VERSION_NUMBER = P_US_VERSION_NUMBER
    AND    COOUS.COURSE_CD = P_NOMINATED_COURSE_CD
    AND    COOUS.CRV_VERSION_NUMBER = P_CRV_VERSION_NUMBER
    AND    COOUS.CAL_TYPE = P_ACAD_CAL_TYPE
    AND    COOUS.LOCATION_CD = P_LOCATION_CD
    AND    COOUS.ATTENDANCE_MODE = P_ATTENDANCE_MODE
    AND    COOUS.ATTENDANCE_TYPE = P_ATTENDANCE_TYPE
    AND    US.UNIT_SET_CD = COOUS.UNIT_SET_CD
    AND    US.VERSION_NUMBER = COOUS.US_VERSION_NUMBER
    AND    US.UNIT_SET_CAT = USC.UNIT_SET_CAT
    AND    USC.S_UNIT_SET_CAT ='PRENRL_YR'
    AND    US.UNIT_SET_CD = CFG.UNIT_SET_CD
    AND    CFG.SEQUENCE_NO = NVL(P_POINT_OF_ENTRY,1);
  cur_unit_set_cd_rec cur_unit_set_cd%ROWTYPE;


  -- Cursor to fetch the previous Outcome Status details captured for the current Application Choice
  CURSOR cur_prev_ou_captured( p_app_no    IGS_UC_APP_CHOICES.APP_NO%TYPE,
                               p_choice_no IGS_UC_APP_CHOICES.CHOICE_NO%TYPE ) IS
    SELECT uoc.*, uoc.ROWID
    FROM  igs_uc_old_oustat uoc
    WHERE  uoc.app_no    = p_app_no
    AND    uoc.choice_no = p_choice_no;
  cur_prev_ou_captured_rec cur_prev_ou_captured%ROWTYPE;

  -- Cursor to fetch the latest decision setting Transaction
  CURSOR cur_latest_trans( p_app_no     igs_uc_app_choices.app_no%TYPE,
                           p_choice_no  igs_uc_app_choices.choice_no%TYPE,
                           p_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE) IS
    SELECT *
    FROM   igs_uc_transactions tran
    WHERE  tran.app_no    = p_app_no
    AND    tran.choice_no = p_choice_no
    AND    tran.ucas_cycle = p_ucas_cycle
    AND    tran.transaction_type IN ( 'LA','LD','RA','RD','RX' )
    ORDER BY tran.uc_tran_id DESC;
  cur_latest_trans_rec cur_latest_trans%ROWTYPE;

  -- Cursor to Check whether there exists any un processed transaction
  CURSOR cur_unprocess_trans_exist( p_app_no     igs_uc_app_choices.app_no%TYPE,
                                    p_choice_no  igs_uc_app_choices.choice_no%TYPE,
                                    p_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE) IS
    SELECT 'X'
    FROM   igs_uc_transactions tran
    WHERE  tran.app_no    = p_app_no
    AND    tran.choice_no = p_choice_no
    AND    tran.ucas_cycle = p_ucas_cycle
    AND    tran.transaction_type IN ( 'LA','LD','RA','RD','RX' )
    AND   ( NVL(tran.sent_to_ucas,'N') = 'N' OR tran.error_code <> 0 ) ;
  cur_unprocess_trans_exist_rec cur_unprocess_trans_exist%ROWTYPE;

  -- Cursor to find the OSS User Outcome Status mapped to the defaulted Decision
  -- of the current Application Instance
  --smaddali modified cursor to add check for system_code ,for bug 2643048 UCFD102 build
  CURSOR cur_ou_mapping ( p_decision IGS_UC_MAP_OUT_STAT.DECISION_CODE%TYPE,
                          p_system_code  igs_uc_map_out_stat.system_code%TYPE) IS
    SELECT mos.adm_outcome_status
    FROM igs_uc_map_out_stat mos
    WHERE mos.system_code = p_system_code
    AND   mos.decision_code = p_decision
    AND   mos.default_ind = 'Y'
    AND   mos.closed_ind  <> 'Y' ;
  cur_ou_mapping_rec cur_ou_mapping%ROWTYPE;

  -- Cursor to fetch the System Admission Outcome status of the
  -- current OSS Application Instance outcome status
  CURSOR cur_s_adm_ou_stat(p_adm_out_status IGS_AD_OU_STAT.ADM_OUTCOME_STATUS%TYPE) IS
    SELECT s_adm_outcome_status
    FROM  igs_ad_ou_stat
    WHERE adm_outcome_status = p_adm_out_status;
  cur_s_adm_ou_stat_rec cur_s_adm_ou_stat%ROWTYPE;

  -- Cursor to find the the value of Reconsideration Flag
  -- from the Admission Application,igs_ad_ps_appl_all
  CURSOR cur_recons_flag ( p_person_id IGS_AD_PS_APPL_ALL.PERSON_ID%TYPE,
             p_admission_appl_number IGS_AD_PS_APPL_ALL.ADMISSION_APPL_NUMBER%TYPE,
             p_nominated_course_code IGS_AD_PS_APPL_ALL.NOMINATED_COURSE_CD%TYPE ) IS
    SELECT req_for_reconsideration_ind
    FROM igs_ad_ps_appl_all
    WHERE person_id             = p_person_id
    AND   admission_appl_number = p_admission_appl_number
    AND   nominated_course_cd   = p_nominated_course_code;
  cur_recons_flag_rec cur_recons_flag%ROWTYPE;

  -- Cursor to fetch all the Application Choices of the current institution which are
  -- errored out in the previous decision import process
    -- smaddali modified this cursor to add the where clause of System_code check , bug 2643048 UCFD102 build
  CURSOR cur_dp_app_choice  IS
    SELECT uac.*,uac.ROWID
    FROM igs_uc_app_choices uac,
         igs_uc_defaults ud
    WHERE uac.app_no =    NVL( p_app_no,uac.app_no)
    AND   uac.choice_no = NVL( p_choice_number,uac.choice_no )
    AND   uac.batch_id IS NOT NULL
    AND   uac.export_to_oss_status = 'DP'
    AND   uac.institute_code = ud.current_inst_code
    AND   uac.system_code = ud.system_code ;
  cur_dp_app_choice_rec cur_dp_app_choice%ROWTYPE ;

  -- Cursor to check for the errorin the import decision process
  CURSOR cur_dec_import_error( p_batch_id IGS_AD_BATC_DEF_DET_ALL.batch_id%TYPE ,
                               p_person_id IGS_AD_ADMDE_INT_ALL.person_id%TYPE,
                               p_admission_appl_number IGS_AD_ADMDE_INT_ALL.admission_appl_number%TYPE,
                               p_nominated_course_cd IGS_AD_ADMDE_INT_ALL.nominated_course_cd%TYPE,
                               p_sequence_number IGS_AD_ADMDE_INT_ALL.sequence_number%TYPE ) IS
    SELECT error_code, status
    FROM igs_ad_admde_int_all
    WHERE batch_id              = p_batch_id
    AND   person_id             = p_person_id
    AND   admission_appl_number = p_admission_appl_number
    AND   nominated_course_cd   = p_nominated_course_cd
    AND   sequence_number       = p_sequence_number
    AND  ( status IN ('3','2') OR   error_code IS NOT NULL ) ;
  cur_dec_import_error_rec cur_dec_import_error%ROWTYPE ;

  -- Cursor to fetch the record Admission Decision import Interface table
  CURSOR cur_admde_interface ( p_interface_mkdes_id IGS_AD_ADMDE_INT_ALL.interface_mkdes_id%TYPE ) IS
    SELECT *
    FROM igs_ad_admde_int_all
    WHERE interface_mkdes_id = p_interface_mkdes_id ;
  cur_admde_interface_rec cur_admde_interface%ROWTYPE;

  --Cursor to fetch the record from Admission Decision import Interface batch table
  CURSOR cur_batc_def_det ( p_batch_id IGS_AD_BATC_DEF_DET_ALL.batch_id%TYPE ) IS
    SELECT *
    FROM igs_ad_batc_def_det_all
    WHERE batch_id = p_batch_id ;
  cur_batc_def_det_rec  cur_batc_def_det%ROWTYPE ;

  -- Cursor to fetch the default Pending Reason
  -- used when the Bulk reject reset by UCAS to PENDING
  CURSOR cur_pending_reason IS
    SELECT code_id
    FROM igs_ad_code_classes
    WHERE class = 'PENDING_REASON'
    AND   system_default = 'Y'
    AND   class_type_code = 'ADM_CODE_CLASSES';
  cur_pending_reason_rec cur_pending_reason%ROWTYPE ;

  -- Cursor selecte a value from Sequence,IGS_AD_INTERFACE_CTL_S  */
  CURSOR cur_interface_ctl_s IS
    SELECT igs_ad_interface_ctl_s.NEXTVAL
    FROM DUAL ;

  -- to get all the distinct system_codes belonging to the passed application choice parameter
  CURSOR c_ch_system IS
    SELECT DISTINCT a.system_code, a.entry_year, a.entry_month
    FROM   igs_uc_app_choices a,
           igs_uc_defaults ud
    WHERE  a.app_no = NVL(p_app_no, a.app_no)
    AND    a.choice_no = NVL(p_choice_number,a.choice_no)
    AND    a.export_to_oss_status = 'AC'
    AND    ud.system_code = a.system_code
    AND    ud.current_inst_code = a.institute_code;

  --Cursor to get the Calendar details for the given System, Entry Month and Entry Year.
  CURSOR cur_sys_entry_cal_det ( cp_system_code  igs_uc_sys_calndrs.system_code%TYPE,
                                 cp_entry_year   igs_uc_sys_calndrs.entry_year%TYPE,
                                 cp_entry_month  igs_uc_sys_calndrs.entry_month%TYPE ) IS
    SELECT aca_cal_type,
           aca_cal_seq_no,
           adm_cal_type,
           adm_cal_seq_no
    FROM  igs_uc_sys_calndrs sc
    WHERE sc.system_code = cp_system_code
    AND   sc.entry_year  = cp_entry_year
    AND   sc.entry_month = cp_entry_month;

  l_sys_entry_cal_det_rec cur_sys_entry_cal_det%ROWTYPE;

  --Cursor to get the Admission Process Category and Admission Process Type for the
  --Admission Application Type defined for the System in UCAS Setup.
  CURSOR cur_apc_det ( cp_application_type igs_uc_defaults.application_type%TYPE) IS
    SELECT admission_cat, s_admission_process_type
    FROM   igs_ad_ss_appl_typ
    WHERE  admission_application_type = cp_application_type
    AND    closed_ind = 'N';

    l_apc_det_rec cur_apc_det%ROWTYPE;

  -- Define the Local Variables
  l_conc_request_id NUMBER(15);
  l_app_inst_sys_adm_ou_status  igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  l_oss_ou_status_of_app_choice igs_ad_ou_stat.adm_outcome_status%TYPE;
  l_latest_trans_decision       igs_uc_transactions.decision%TYPE;

  l_batch_id           igs_ad_batc_def_det_all.batch_id%TYPE ;
  l_deffered_batch_id  igs_ad_batc_def_det_all.batch_id%TYPE ;
  l_current_batch_id   igs_ad_batc_def_det_all.batch_id%TYPE ;

  l_export_to_oss_status  igs_uc_app_choices.export_to_oss_status%TYPE ;
  l_app_choice_error_code igs_uc_app_choices.error_code%TYPE ;

  l_rowid VARCHAR2(25);
  l_interface_mkdes_id igs_ad_admde_int_all.interface_mkdes_id%TYPE ;
  l_interface_run_id   igs_ad_admde_int_all.interface_run_id%TYPE ;
  l_return_status VARCHAR2(10) ;
  l_error_message fnd_new_messages.message_text%TYPE ;
  l_description VARCHAR2(2000);

  l_ch_batch_id          igs_uc_app_choices.batch_id%TYPE ;
  l_reconsideration_flag igs_ad_ps_appl.req_for_reconsideration_ind%TYPE;

  --Record Type to hold the batch_id created for a system cycle calendars.
  TYPE batch_det_type IS RECORD
   (  system_code igs_uc_app_choices.system_code%TYPE,
      entry_year  igs_uc_app_choices.entry_year%TYPE,
      entry_month igs_uc_app_choices.entry_month%TYPE,
      batch_id    igs_ad_batc_def_det_all.batch_id%TYPE
    );

  --Table Type to hold the batch_id created for diferrent system cycle calendars.
   TYPE batch_det_table_type IS TABLE OF batch_det_type INDEX BY BINARY_INTEGER;

  --Table/Collection variable to hold the records for batch ids created of diferrent system, cycle and calendars.
  l_batch_id_det batch_det_table_type;
  l_batch_id_loc NUMBER;


  PROCEDURE get_batchid_loc( p_system_code IN igs_uc_app_choices.system_code%TYPE,
                             p_entry_year  IN igs_uc_app_choices.entry_year%TYPE,
                             p_entry_month IN igs_uc_app_choices.entry_month%TYPE,
                             p_batch_id_loc OUT NOCOPY NUMBER) IS
      /******************************************************************
       Created By      :   rbezawad
       Date Created By :   16-Jun-03
       Purpose         :   Local Procedure to export_decision() procedure, which retuns the Batch ID location
                           in pl/sql table(l_batch_id_det) of Batch ID for passed parameter criteria.
       Known limitations,enhancements,remarks:
       Change History
       Who       When         What
       rbezawad  24-Jul-2003  Done modifications to retrieve the batch id location based on system code, entry year and entry month.
                                Modifications are done as part of UCCR007 and UCCR203 enhancement, Bug No: 3022067.
      ***************************************************************** */
  BEGIN

    -- Search for the Batch ID location only when the PL/SQL table has some data.
    IF l_batch_id_det.FIRST IS NOT NULL AND l_batch_id_det.LAST IS NOT NULL THEN

      --Loop through the pl/sql table and check for the values.
      FOR l_loc IN l_batch_id_det.FIRST..l_batch_id_det.LAST LOOP
        IF l_batch_id_det(l_loc).system_code = p_system_code AND
           l_batch_id_det(l_loc).entry_year = p_entry_year AND
           l_batch_id_det(l_loc).entry_month = p_entry_month THEN
          --If the Batch ID found for the matching parameters then return the location of batch id in to out parameter p_batch_id_loc.
          p_batch_id_loc := l_loc;
          EXIT;
        END IF;
      END LOOP;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_EXPORT_DECISION_REPLY.GET_BATCHID_LOC'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.LOG,fnd_message.get());
      App_Exception.Raise_Exception;

  END get_batchid_loc;


BEGIN

  -- Initialize all the local variables
  l_app_inst_sys_adm_ou_status  := NULL ;
  l_oss_ou_status_of_app_choice := NULL ;
  l_latest_trans_decision := NULL ;

  l_batch_id := NULL ;
  l_deffered_batch_id := NULL ;
  l_current_batch_id  := NULL ;

  l_export_to_oss_status := NULL ;
  l_app_choice_error_code := NULL ;

  l_interface_mkdes_id := NULL ;
  l_interface_run_id := NULL ;
  l_return_status := NULL ;
  l_error_message := NULL ;
  l_batch_id_loc := 0;

  -- Get the Concurrent Request ID of the current export of UCAS application to
  -- OSS admission applications run
  l_conc_request_id := fnd_global.conc_request_id();

  FOR c_ch_system_rec IN c_ch_system LOOP

    -- Insert a record into the Admission Decision Import Batch table,IGS_AD_BATC_DEF_DET_ALL
    -- for the deffered and current academic/admission calendar session details for each of the ucas systems
    -- This Batch ID will be used while populating the Admission Decision Import Process Interface Table
    FOR cur_ucas_setup_rec IN cur_ucas_setup(c_ch_system_rec.system_code) LOOP

      --Get the APC details corresponding to the Application Type defined in UCAS Setup
      OPEN cur_apc_det(cur_ucas_setup_rec.application_type);
      FETCH cur_apc_det INTO l_apc_det_rec;
      CLOSE cur_apc_det;

      -- We need to create a separate batch id for each of the UCAS System's calendars
      -- Get the Batch ID Description value from the Message,IGS_UC_DEC_BATCH
      fnd_message.set_name('IGS','IGS_UC_DEC_BATCH');
      l_description := fnd_message.get;
      l_rowid := NULL ;
      l_batch_id := NULL;

      --Get the Calendar details for the given System, Entry Month and Entry Year from System Calendards table.
      l_sys_entry_cal_det_rec := NULL;
      OPEN cur_sys_entry_cal_det (c_ch_system_rec.system_code, c_ch_system_rec.entry_year, c_ch_system_rec.entry_month);
      FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
      --If no matching Entry Year and Entry Month record for the system is found in the System Calendars table then
      --  get the calendar details from the IGS_UC_SYS_CALNDRS table based on the system, Entry Year and Entry Month as 0 (Zero).
      IF cur_sys_entry_cal_det%NOTFOUND THEN
        CLOSE cur_sys_entry_cal_det;
        OPEN cur_sys_entry_cal_det(c_ch_system_rec.system_code, c_ch_system_rec.entry_year, 0);
        FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
      END IF;
      CLOSE cur_sys_entry_cal_det;

      -- We need to create a separate batch id for each of the calendar setup available for UCAS System, Entry Year and Entry Month details.
      igs_ad_batc_def_det_pkg.insert_row(
                    x_rowid                     => l_rowid,
                    x_batch_id                  => l_batch_id,
                    x_description               => l_description,
                    x_acad_cal_type             => l_sys_entry_cal_det_rec.aca_cal_type,
                    x_acad_ci_sequence_number   => l_sys_entry_cal_det_rec.aca_cal_seq_no,
                    x_adm_cal_type              => l_sys_entry_cal_det_rec.adm_cal_type,
                    x_adm_ci_sequence_number    => l_sys_entry_cal_det_rec.adm_cal_seq_no,
                    x_admission_cat             => l_apc_det_rec.admission_cat,
                    x_s_admission_process_type  => l_apc_det_rec.s_admission_process_type,
                    x_decision_make_id          => cur_ucas_setup_rec.decision_make_id,
                    x_decision_date             => SYSDATE,
                    x_decision_reason_id        => cur_ucas_setup_rec.decision_reason_id,
                    x_pending_reason_id         => NULL,
                    x_offer_dt                  => NULL,
                    x_offer_response_dt         => NULL,
                    x_mode                      => 'R'   );

      --Store the information of Batch ID created into a pl/sql table
      l_batch_id_det(l_batch_id_loc).system_code := c_ch_system_rec.system_code;
      l_batch_id_det(l_batch_id_loc).entry_year := c_ch_system_rec.entry_year;
      l_batch_id_det(l_batch_id_loc).entry_month := c_ch_system_rec.entry_month;
      l_batch_id_det(l_batch_id_loc).batch_id := l_batch_id;
      l_batch_id_loc := l_batch_id_loc + 1;

    END LOOP ;

  END LOOP ;

  /* Process all the Application Choice records of the passed p_app_no,p_choice_number
     and of the current institution with Export_to_oss Status = "AC"  */
  FOR cur_ucas_app_choice_rec IN cur_ucas_app_choice LOOP

     -- Initialize the variable at the start of each application choice
     -- which will be used to update the application choice record at the end of processing

     l_export_to_oss_status := NULL ;
     l_app_choice_error_code := NULL ;
     l_ch_batch_id := NULL ;
     l_interface_mkdes_id := NULL ;
     l_interface_run_id := NULL ;
     l_rowid := NULL ;

     -- Fetch the default values setup for the UCAS SYSTEM to which this application choice belongs to,
     -- These values will be used in this procedure wherever default values requires
     cur_ucas_setup_rec := NULL ;
     OPEN cur_ucas_setup(cur_ucas_app_choice_rec.system_code) ;
     FETCH cur_ucas_setup INTO cur_ucas_setup_rec;
     CLOSE cur_ucas_setup;

     -- 1. Get the Batch ID of the Admission Decision Import Batch table,IGS_AD_BATC_DEF_DET_ALL
     -- smaddali modified the code to get the batch id corresponding to the UCAS system ,for UCFD102 build , bug 2643048
     l_batch_id := NULL ;
     l_batch_id_loc :=NULL;
     get_batchid_loc(p_system_code  => cur_ucas_app_choice_rec.system_code,
                     p_entry_year   => cur_ucas_app_choice_rec.entry_year,
                     p_entry_month  => cur_ucas_app_choice_rec.entry_month,
                     p_batch_id_loc => l_batch_id_loc);
     IF l_batch_id_loc IS NOT NULL THEN
       l_batch_id := l_batch_id_det(l_batch_id_loc).batch_id;
     END IF;

     -- Identify whether the Application Instance for the current Application Choice Exist or not
     OPEN cur_oss_appl_inst( cur_ucas_app_choice_rec.app_no,
                             cur_ucas_app_choice_rec.choice_no,
                             cur_ucas_app_choice_rec.ucas_cycle);
     FETCH cur_oss_appl_inst INTO cur_oss_appl_inst_rec ;

     IF cur_oss_appl_inst%NOTFOUND THEN
       -- update UCAS Application Chocie record to set error Code to 'D002'
       l_app_choice_error_code := 'D002' ;
       l_export_to_oss_status := cur_ucas_app_choice_rec.export_to_oss_status ;
       l_ch_batch_id := NULL ;
       -- Write the error message to the Log file indicating the error occurred
       fnd_message.set_name('IGS','IGS_UC_APP_INST_NOTFOUND');
       fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
       fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

     ELSE  /* OSS Application Instance Found */

       -- jchin - bug 3691277 and 3691250
       -- added check whether the matching unit-set-code exists for the identofi application instance
       OPEN cur_unit_set_cd(cur_oss_appl_inst_rec.unit_set_cd,
                            cur_oss_appl_inst_rec.us_version_number,
                            cur_oss_appl_inst_rec.nominated_course_cd,
                            cur_oss_appl_inst_rec.crv_version_number,
                            cur_oss_appl_inst_rec.acad_cal_type,
                            cur_oss_appl_inst_rec.location_cd,
                            cur_oss_appl_inst_rec.attendance_mode,
                            cur_oss_appl_inst_rec.attendance_type,
                            cur_oss_appl_inst_rec.point_of_entry);
       FETCH cur_unit_set_cd INTO cur_unit_set_cd_rec;

       IF cur_unit_set_cd%NOTFOUND THEN
         -- update UCAS Application Chocie record to set error Code to 'D002'
         l_app_choice_error_code := 'D002' ;
         l_export_to_oss_status := cur_ucas_app_choice_rec.export_to_oss_status ;
         l_ch_batch_id := NULL ;
         -- Write the error message to the Log file indicating the error occurred
         fnd_message.set_name('IGS','IGS_UC_APP_INST_NOTFOUND');
         fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
         fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
         fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       ELSE /* OSS Application Instance and unit-set-code found */

        -- Get the System Admission Outcome status of the current admission Application Outcome status
        -- This will be used in the following code
        cur_s_adm_ou_stat_rec := NULL ;
        OPEN cur_s_adm_ou_stat( cur_oss_appl_inst_rec.adm_outcome_status );
        FETCH cur_s_adm_ou_stat INTO cur_s_adm_ou_stat_rec;
        CLOSE cur_s_adm_ou_stat;
        l_app_inst_sys_adm_ou_status := cur_s_adm_ou_stat_rec.s_adm_outcome_status;

         -- Get the Default OSS admission Outcome status of the Application choice decision
         -- This will be used in the following code
         cur_ou_mapping_rec := NULL ;
         OPEN cur_ou_mapping ( cur_ucas_app_choice_rec.decision,cur_ucas_app_choice_rec.system_code );
         FETCH cur_ou_mapping INTO cur_ou_mapping_rec;
         CLOSE cur_ou_mapping;
         l_oss_ou_status_of_app_choice :=  cur_ou_mapping_rec.adm_outcome_status;

         -- Find the latest Decision setting UCAS transaction of the Application Choice
         -- This will be used in the following code
         cur_latest_trans_rec := NULL ;
         OPEN cur_latest_trans( cur_ucas_app_choice_rec.app_no,
                                cur_ucas_app_choice_rec.choice_no,
                                cur_ucas_app_choice_rec.ucas_cycle);
         FETCH cur_latest_trans INTO cur_latest_trans_rec;
         CLOSE cur_latest_trans;

         --anwest 06-JUN-06 Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
         IF cur_latest_trans_rec.transaction_type = 'RA' THEN
            l_latest_trans_decision := cur_ucas_app_choice_rec.decision;
         ELSE
            l_latest_trans_decision := cur_latest_trans_rec.decision;
         END IF;

         -- Check whether the previous Outcome details are captured for the current Application Instance or not
         -- in IGS_UC_OLD_OUSTAT Table
         OPEN cur_prev_ou_captured( cur_ucas_app_choice_rec.app_no,
                                        cur_ucas_app_choice_rec.choice_no );
         FETCH cur_prev_ou_captured INTO cur_prev_ou_captured_rec;


         /*** Logic for: Previous Outcome details are captured
              That is if the previous Outcome details are captured for the current Application Instance
              in IGS_UC_OLD_OUSTAT Table, then import the application choice decision */
         IF cur_prev_ou_captured%FOUND THEN

           -- If Previous Outcome details are captured and there is no trasaction decision found,
           -- the raise the error with error Code to 'D005'
           IF l_latest_trans_decision IS NULL THEN --anwest 06-JUN-06 Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES

             -- Update the Appchoice record with export_to_oss_status as 'DC'
             l_export_to_oss_status := 'DC' ;
             l_app_choice_error_code := NULL ;
                   l_ch_batch_id := NULL ;
             -- smaddali added igs_uc_old_oustat_pkg.delete_row call for bug 2630219
             -- 4. Delete the corresponding record from IGS_UC_OLD_OUSTAT table for current Application and Choice
             igs_uc_old_oustat_pkg.delete_row(
             X_ROWID     => cur_prev_ou_captured_rec.ROWID ) ;

             -- Write the error message to the Log file indicating the error occurred
             fnd_message.set_name('IGS','IGS_UC_TRAN_NOT_FOUND');
             fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no) );
             fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no) );
             fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

           ELSE /* Latest Transaction was found */

             --anwest 06-JUN-06 Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
             IF cur_latest_trans_rec.transaction_type = 'RD' AND l_latest_trans_decision = 'C' THEN
                -- Find the OSS User Outcome Status mapped to the tapplication choice decision
                OPEN cur_ou_mapping (cur_ucas_app_choice_rec.decision, cur_ucas_app_choice_rec.system_code);
                FETCH cur_ou_mapping INTO cur_ou_mapping_rec ;
             ELSE
               -- Find the OSS User Outcome Status mapped to the latest transaction Decision of the Application Choice
               OPEN cur_ou_mapping ( l_latest_trans_decision , cur_ucas_app_choice_rec.system_code ) ;
               FETCH cur_ou_mapping INTO cur_ou_mapping_rec ;
             END IF;

             -- If the mapping of Transaction Decision to Default OSS User Outcome Status is defined
             IF cur_ou_mapping%FOUND THEN

               CLOSE cur_ou_mapping ;
               -- If previous Captured Outcome status is equal to transaction decision mapped User Outthe status
               -- and the previous Captured Outcome status is 'PENDING',
               -- then no need to import the Decision, so update the Application Choice status to 'DC'
               OPEN cur_s_adm_ou_stat( cur_prev_ou_captured_rec.old_outcome_status ) ;
               FETCH cur_s_adm_ou_stat INTO cur_s_adm_ou_stat_rec ;
               CLOSE cur_s_adm_ou_stat ;

               IF cur_ou_mapping_rec.adm_outcome_status = cur_prev_ou_captured_rec.old_outcome_status AND
                 cur_s_adm_ou_stat_rec.s_adm_outcome_status = 'PENDING' THEN

                 -- Update the Appchoice record with export_to_oss_status as 'DC'
                 l_export_to_oss_status := 'DC' ;
                 l_app_choice_error_code := NULL ;
                 l_ch_batch_id := NULL ;

                 -- smaddali added igs_uc_old_oustat_pkg.delete_row call for bug 2630219
                 -- 4. Delete the corresponding record from IGS_UC_OLD_OUSTAT table for current Application and Choice
                 igs_uc_old_oustat_pkg.delete_row(
                   x_rowid     => cur_prev_ou_captured_rec.ROWID ) ;

               ELSE /* Previous Captured Outcome status is not 'PENDING' */

                 /* Populate the Admission Decision Import Interface tables with the default OSS user outcome status
                 corresponding to UCAS latest decision setting Transaction Decision */

                 -- 2. Populate the Admission Decision Import Interface table,IGS_AD_ADMDE_INT_ALL as,

                 /*Populate the Admission Decision Import Interface tables with default OSS user outcome status
                 mapped to the UCAS Transaction Decision.

                 If the UCAS Transaction Decision maps to the captured OSS user outcome Status or
                 the latest transaction setting decision is an RD or an RA transaction and
                 the decision in the transaction maps to the captured  OSS outcome status,
                 then Populate the Decision_maker, decision_reason and Decision Date details from
                 IGS_UC_OLD_OUSTAT table and Application Instance information from CUR_OSS_APPL_INST_REC
                 Else,Populate the Decision_maker, decision_reason,Decision_date details from UCAS Setup
                 and Application Instance information CUR_OSS_APPL_INST_REC.

                 The offer_dt should be set to the decision date from the igs_uc_app_choices for the choice being
                 imported unless the outcome status is being synchronized with an unprocessed UCAS transaction
                 in which case it should be set to the transaction date created.  */

                 /* Get the Interface Run ID value from Sequence */
                 OPEN cur_interface_ctl_s ;
                 FETCH cur_interface_ctl_s INTO l_interface_run_id;
                 CLOSE cur_interface_ctl_s;

                 -- Derive the Reconsideration Flag value based on the Admission outcome status to be changed.  This Reconsideration
                 -- Flag value will be stored in igs_ad_admde_int_all table and used for exporting UCAS decisions to OSS.
                 l_reconsideration_flag := NULL;
                 IF igs_ad_gen_008.admp_get_saos(cur_ou_mapping_rec.adm_outcome_status) IN ('REJECTED','NO-QUOTA') THEN
                   -- Set the Reconsideration Flat to 'Y' for allowing institutions to process UCAS applications seemlessly.
                   l_reconsideration_flag := 'Y';
                 ELSE
                   -- When Application Decision to be changed is not REJECTED or NO-QUOTA then there is no need to set the flag.
                   l_reconsideration_flag := 'N';
                 END IF;

                 --anwest 06-JUN-06 Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
                 IF cur_ou_mapping_rec.adm_outcome_status = cur_prev_ou_captured_rec.old_outcome_status THEN

                   l_rowid := NULL ;
                   igs_ad_admde_int_pkg.insert_row (
                     x_rowid                    =>  l_rowid,
                     x_interface_mkdes_id       =>  l_interface_mkdes_id,
                     x_interface_run_id         =>  l_interface_run_id,
                     x_batch_id                 =>  l_batch_id,
                     x_person_id                =>  cur_oss_appl_inst_rec.person_id,
                     x_admission_appl_number    =>  cur_oss_appl_inst_rec.admission_appl_number,
                     x_nominated_course_cd      =>  cur_oss_appl_inst_rec.nominated_course_cd,
                     x_sequence_number          =>  cur_oss_appl_inst_rec.sequence_number,
                     x_adm_outcome_status       =>  cur_ou_mapping_rec.adm_outcome_status,
                     x_decision_make_id         =>  cur_prev_ou_captured_rec.decision_make_id,
                     x_decision_date            =>  cur_prev_ou_captured_rec.decision_date,
                     x_decision_reason_id       =>  cur_prev_ou_captured_rec.decision_reason_id,
                     x_pending_reason_id        =>  NULL,
                     x_offer_dt                 =>  TRUNC(NVL(cur_ucas_app_choice_rec.decision_date, SYSDATE)),
                     x_offer_response_dt        =>  NULL,
                     x_status                   =>  '2', --Pending Status
                     x_error_code               =>  NULL,
                     x_mode                     =>  'R',
                     x_reconsider_flag          =>  l_reconsideration_flag );

                 ELSE

                   l_rowid := NULL ;
                   igs_ad_admde_int_pkg.insert_row (
                     x_rowid                    =>  l_rowid,
                     x_interface_mkdes_id       =>  l_interface_mkdes_id,
                     x_interface_run_id         =>  l_interface_run_id,
                     x_batch_id                 =>  l_batch_id,
                     x_person_id                =>  cur_oss_appl_inst_rec.person_id,
                     x_admission_appl_number    =>  cur_oss_appl_inst_rec.admission_appl_number,
                     x_nominated_course_cd      =>  cur_oss_appl_inst_rec.nominated_course_cd,
                     x_sequence_number          =>  cur_oss_appl_inst_rec.sequence_number,
                     x_adm_outcome_status       =>  cur_ou_mapping_rec.adm_outcome_status,
                     x_decision_make_id         =>  cur_ucas_setup_rec.decision_make_id,
                     x_decision_date            =>  TRUNC(NVL(cur_ucas_app_choice_rec.decision_date, SYSDATE)),
                     x_decision_reason_id       =>  cur_ucas_setup_rec.decision_reason_id,
                     x_pending_reason_id        =>  NULL,
                     x_offer_dt                 =>  TRUNC(NVL(cur_ucas_app_choice_rec.decision_date, SYSDATE)),
                     x_offer_response_dt        =>  NULL,
                     x_status                   =>  '2', --Pending Status
                     x_error_code               =>  NULL,
                     x_mode                     =>  'R',
                     x_reconsider_flag          =>  l_reconsideration_flag );

                 END IF;

                 -- 3. Update the Application Choice Record with export_to_oss_status = 'DP' and Concurrent Request ID
                 -- Assign DP' to local variable,l_export_to_oss_status and update the Application Choice Record at the end
                 l_export_to_oss_status := 'DP';
                       l_app_choice_error_code := NULL ;
                 l_ch_batch_id := NULL ;
                 -- 4. Delete the corresponding record from IGS_UC_OLD_OUSTAT table for current Application and Choice Number.
                 igs_uc_old_oustat_pkg.delete_row(
                   x_rowid     => cur_prev_ou_captured_rec.ROWID ) ;

               END IF; /* End of checking the outcome status as 'PENDING'  */

             ELSE /* raise the error with code 'D006' */

               CLOSE cur_ou_mapping;
               l_app_choice_error_code := 'D006' ;
               l_export_to_oss_status :=  cur_ucas_app_choice_rec.export_to_oss_status;
               l_ch_batch_id := NULL ;

               -- Write the error message to the Log file indicating the error occurred
               fnd_message.set_name('IGS','IGS_UC_TRANS_DEC_NOT_MAPPED');
               fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no ));
               fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
               fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

             END IF; /* End of mapping found */

           END IF; /* Latest Transaction Found  */


         /*** Logic for: Bulk Reject by UACAS
         That is, The Application Choice decision is 'R'(Reject) and Action flag set to 'R' */
         ELSIF cur_ucas_app_choice_rec.decision = 'R' AND cur_ucas_app_choice_rec.action = 'R' THEN

           -- Check weather there exists any unprocessed transaction
           OPEN cur_unprocess_trans_exist( cur_ucas_app_choice_rec.app_no,
                                           cur_ucas_app_choice_rec.choice_no,
                                           cur_ucas_app_choice_rec.ucas_cycle);
           FETCH cur_unprocess_trans_exist INTO cur_unprocess_trans_exist_rec;

           -- If the System Admission Outcome status of the Application instance is 'PENDING' or
           -- no unprocessed decision setting transaction exists
           IF l_app_inst_sys_adm_ou_status = 'PENDING' AND  cur_unprocess_trans_exist%NOTFOUND THEN

             /* Populate the Admission Decision Import Interface tables with the default OSS user outcome status
             with system outcome status type of 'REJECTED' from the UCAS setup  */

             --1. Insert a record into Admission Decision Import Interface table,IGS_AD_ADMDE_INT_ALL

              /* Get the Interface Run ID value from Sequence */
              OPEN cur_interface_ctl_s ;
              FETCH cur_interface_ctl_s INTO l_interface_run_id;
              CLOSE cur_interface_ctl_s;

              -- Derive the Reconsideration Flag value based on the Admission outcome status to be changed.  This Reconsideration
              -- Flag value will be stored in igs_ad_admde_int_all table and used for exporting UCAS decisions to OSS.
              l_reconsideration_flag := NULL;
              IF igs_ad_gen_008.admp_get_saos(cur_ucas_setup_rec.rejected_outcome_status) IN ('REJECTED','NO-QUOTA') THEN
                -- Set the Reconsideration Flat to 'Y' for allowing institutions to process UCAS applications seemlessly.
                l_reconsideration_flag := 'Y';
              ELSE
                -- When Application Decision to be changed is not REJECTED or NO-QUOTA then there is no need to set the flag.
                l_reconsideration_flag := 'N';
              END IF;

              /* call the insert_row of the Admission Decision Import Interface table, IGS_AD_ADMDE_INT_ALL */
              igs_ad_admde_int_pkg.insert_row (
               x_rowid                    =>  l_rowid,
               x_interface_mkdes_id       =>  l_interface_mkdes_id,
               x_interface_run_id         =>  l_interface_run_id,
               x_batch_id                 =>  l_batch_id,
               x_person_id                =>  cur_oss_appl_inst_rec.person_id,
               x_admission_appl_number    =>  cur_oss_appl_inst_rec.admission_appl_number,
               x_nominated_course_cd      =>  cur_oss_appl_inst_rec.nominated_course_cd,
               x_sequence_number          =>  cur_oss_appl_inst_rec.sequence_number,
               x_adm_outcome_status       =>  cur_ucas_setup_rec.rejected_outcome_status,
               x_decision_make_id         =>  cur_ucas_setup_rec.decision_make_id,
               x_decision_date            =>  TRUNC(NVL(cur_ucas_app_choice_rec.decision_date, SYSDATE)),
               x_decision_reason_id       =>  cur_ucas_setup_rec.decision_reason_id,
               x_pending_reason_id        =>  NULL,
               x_offer_dt                 =>  NULL,
               x_offer_response_dt        =>  NULL,
               x_status                   =>  '2', --Pending Status
               x_error_code               =>  NULL,
               x_mode                     =>  'R',
               x_reconsider_flag          =>  l_reconsideration_flag );

              -- 3. Update the Application Choice Record with export_to_oss_status='DP' and Concurrent Request ID
              l_export_to_oss_status := 'DP';
              l_app_choice_error_code := NULL ;
              l_ch_batch_id := NULL ;

           ELSE /* Raise the error with error_code ='D007' */

              l_app_choice_error_code := 'D007' ;
              l_export_to_oss_status := cur_ucas_app_choice_rec.export_to_oss_status;
              l_ch_batch_id := NULL ;

              -- Write the error message to the Log file indicating the error occurred
              fnd_message.set_name('IGS','IGS_UC_EXP_BULK_REJ_DEC_FAIL');
              fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
              fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
              fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

            END IF ;
            CLOSE cur_unprocess_trans_exist ;


         /*** Logic for: Bulk Reject is reset by UCAS
              That is, if the Application Choice decision is NULL and Action flag IS NULL and the Application
              Instance system Outocme status is 'REJECTED' and If there is any transaction exists, then
              it should be either the latest decision setting transaction
              is processed by UCAS or transaction decision is 'R' then, import the Admission decision   */
         ELSIF cur_ucas_app_choice_rec.decision IS NULL  AND
             cur_ucas_app_choice_rec.action IS NULL    AND
             l_app_inst_sys_adm_ou_status = 'REJECTED' AND
             ( l_latest_trans_decision IS NULL OR  -- transaction deos not exist
              ( l_latest_trans_decision = 'R' OR
              ( cur_latest_trans_rec.sent_to_ucas = 'Y' AND cur_latest_trans_rec.error_code = 0 ))) THEN

           /* Populate the Admission Decision Import Interface tables with the default OSS user outcome status
            with system outcome status type of 'PENDING' */

           -- 1. Insert a record into Admission Decision Import Interface table,IGS_AD_ADMDE_INT_ALL

           /* Get the Pending Reason ID */
           OPEN cur_pending_reason;
           FETCH cur_pending_reason INTO cur_pending_reason_rec;
           CLOSE cur_pending_reason;

           /* Get the Interface Run ID value from Sequence */
           OPEN cur_interface_ctl_s ;
           FETCH cur_interface_ctl_s INTO l_interface_run_id ;
           CLOSE cur_interface_ctl_s ;

           -- Derive the Reconsideration Flag value based on the Admission outcome status to be changed.  This Reconsideration
           -- Flag value will be stored in igs_ad_admde_int_all table and used for exporting UCAS decisions to OSS.
           l_reconsideration_flag := NULL;
           IF igs_ad_gen_008.admp_get_saos(cur_ucas_setup_rec.pending_outcome_status) IN ('REJECTED','NO-QUOTA') THEN
             -- Set the Reconsideration Flat to 'Y' for allowing institutions to process UCAS applications seemlessly.
             l_reconsideration_flag := 'Y';
           ELSE
             -- When Application Decision to be changed is not REJECTED or NO-QUOTA then there is no need to set the flag.
             l_reconsideration_flag := 'N';
           END IF;

           /* call the insert_row of the Admission Decision Import Interface table, IGS_AD_ADMDE_INT_ALL */
           igs_ad_admde_int_pkg.insert_row (
                 x_rowid                    =>  l_rowid,
                 x_interface_mkdes_id       =>  l_interface_mkdes_id,
                 x_interface_run_id         =>  l_interface_run_id,
                 x_batch_id                 =>  l_batch_id,
                 x_person_id                =>  cur_oss_appl_inst_rec.person_id,
                 x_admission_appl_number    =>  cur_oss_appl_inst_rec.admission_appl_number,
                 x_nominated_course_cd      =>  cur_oss_appl_inst_rec.nominated_course_cd,
                 x_sequence_number          =>  cur_oss_appl_inst_rec.sequence_number,
                 x_adm_outcome_status       =>  cur_ucas_setup_rec.pending_outcome_status,
                 x_decision_make_id         =>  cur_ucas_setup_rec.decision_make_id,
                 x_decision_date            =>  TRUNC(cur_ucas_app_choice_rec.decision_date),
                 x_decision_reason_id       =>  cur_ucas_setup_rec.decision_reason_id,
                 x_pending_reason_id        =>  cur_pending_reason_rec.code_id,
                 x_offer_dt                 =>  NULL,
                 x_offer_response_dt        =>  NULL,
                 x_status                   =>  '2', --Pending Status
                 x_error_code               =>  NULL,
                 x_mode                     =>  'R',
                 x_reconsider_flag          =>  l_reconsideration_flag );

           -- 3. Update the Application Choice Record with export_to_oss_status='DP' and Concurrent Request ID
           l_export_to_oss_status := 'DP';
           l_app_choice_error_code := NULL ;
           l_ch_batch_id := NULL ;

         /*** Logic For: Check whether the decision is NULL, required to export or not */
         ELSIF cur_ucas_app_choice_rec.decision IS NULL AND
                   l_latest_trans_decision IS NULL AND
                   l_app_inst_sys_adm_ou_status = 'PENDING'  THEN

           -- Update the Appchoice record with export_to_oss_status as 'DC'
           l_export_to_oss_status := 'DC' ;
           l_app_choice_error_code := NULL ;
           l_ch_batch_id := NULL ;

         /*** Lgogic For: OSS admission Outcome status of the Application choice decision is not equal to
            the Application Instances admission Outcome status */
           /* NVL is added because even if the value of l_oss_ou_status_of_app_choice is NULL, condition should be processed */
         ELSIF NVL(l_oss_ou_status_of_app_choice,' ') <> cur_oss_appl_inst_rec.adm_outcome_status THEN

           -- Get the Reconsideration flag of the Admission Application
           OPEN cur_recons_flag ( cur_oss_appl_inst_rec.person_id,
                                  cur_oss_appl_inst_rec.admission_appl_number,
                                  cur_oss_appl_inst_rec.nominated_course_cd ) ;
           FETCH cur_recons_flag INTO cur_recons_flag_rec;
           CLOSE cur_recons_flag;

           -- If the System Admission outcome status is one of 'REJECTED','VOIDED', 'WITHDRAWN' and
           -- request for reconsideration flag is not set to 'Y' then raise error
           IF l_app_inst_sys_adm_ou_status IN ( 'REJECTED', 'VOIDED', 'WITHDRAWN' ) AND
             cur_recons_flag_rec.req_for_reconsideration_ind <> 'Y'  THEN
             /* Raise the error with code 'D004' */
             l_app_choice_error_code := 'D004' ;
             l_export_to_oss_status := cur_ucas_app_choice_rec.export_to_oss_status;
             l_ch_batch_id := NULL ;
            -- Write the error message to the Log file indicating the error occurred
             fnd_message.set_name('IGS','IGS_UC_APP_INST_COMPLETED');
             fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
             fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
             fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

           ELSE

             -- If the latest decision setting transaction is processed successfully,
             -- then populate the OSS admission outcome ststaus corresponding to Application Choice
             IF  cur_latest_trans_rec.sent_to_ucas = 'Y' AND cur_latest_trans_rec.error_code = 0 THEN

               IF l_oss_ou_status_of_app_choice IS NOT NULL THEN
               /* Populate the Admission Decision Import Interface tables with the default OSS user outcome status
                 corresponding to Application Choice Decision */

               -- 1. Insert a record into Admission Decision Import Interface table,IGS_AD_ADMDE_INT_ALL
               /* Get the Interface Run ID value from Sequence */
               OPEN cur_interface_ctl_s ;
               FETCH cur_interface_ctl_s INTO l_interface_run_id;
               CLOSE cur_interface_ctl_s;

               -- Derive the Reconsideration Flag value based on the Admission outcome status to be changed.  This Reconsideration
               -- Flag value will be stored in igs_ad_admde_int_all table and used for exporting UCAS decisions to OSS.
               l_reconsideration_flag := NULL;
               IF igs_ad_gen_008.admp_get_saos(l_oss_ou_status_of_app_choice) IN ('REJECTED','NO-QUOTA') THEN
                 -- Set the Reconsideration Flat to 'Y' for allowing institutions to process UCAS applications seemlessly.
                 l_reconsideration_flag := 'Y';
               ELSE
                 -- When Application Decision to be changed is not REJECTED or NO-QUOTA then there is no need to set the flag.
                 l_reconsideration_flag := 'N';
               END IF;

               /* call the insert_row of the Admission Decision Import Interface table, IGS_AD_ADMDE_INT_ALL */
               igs_ad_admde_int_pkg.insert_row (
                   x_rowid                    =>  l_rowid,
                   x_interface_mkdes_id       =>  l_interface_mkdes_id,
                   x_interface_run_id         =>  l_interface_run_id,
                   x_batch_id                 =>  l_batch_id,
                   x_person_id                =>  cur_oss_appl_inst_rec.person_id,
                   x_admission_appl_number    =>  cur_oss_appl_inst_rec.admission_appl_number,
                   x_nominated_course_cd      =>  cur_oss_appl_inst_rec.nominated_course_cd,
                   x_sequence_number          =>  cur_oss_appl_inst_rec.sequence_number,
                   x_adm_outcome_status       =>  l_oss_ou_status_of_app_choice,
                   x_decision_make_id         =>  cur_ucas_setup_rec.decision_make_id,
                   x_decision_date            =>  TRUNC(NVL(cur_ucas_app_choice_rec.decision_date, SYSDATE)),
                   x_decision_reason_id       =>  cur_ucas_setup_rec.decision_reason_id,
                   x_pending_reason_id        =>  NULL,
                   x_offer_dt                 =>  TRUNC(NVL(cur_ucas_app_choice_rec.decision_date, SYSDATE)),
                   x_offer_response_dt        =>  NULL,
                   x_status                   =>  '2', --Pending Status
                   x_error_code               =>  NULL,
                   x_mode                     =>  'R',
                   x_reconsider_flag          =>  l_reconsideration_flag );

                 -- 3. Update the Application Choice Record with export_to_oss_status='DP' and Concurrent Request ID
                 l_export_to_oss_status := 'DP';
                 l_app_choice_error_code := NULL ;
                 l_ch_batch_id := NULL ;

               ELSE /* raise the error with code 'D003' */
                 l_app_choice_error_code := 'D003' ;
                 l_export_to_oss_status := cur_ucas_app_choice_rec.export_to_oss_status;
                 l_ch_batch_id := NULL ;

                 -- Write the error message to the Log file indicating the error occurred
                 fnd_message.set_name('IGS','IGS_UC_APPCH_DEC_NOT_MAPPED');
                 fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
                 fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
                 fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
               END IF;

            ELSE /* If the latest decision setting transaction is NOT processed successfully,
            then populate the OSS admission outcome ststaus corresponding to UCAS Transaction Decision*/

             -- Find the OSS User Outcome Status mapped to the Latest Transaction Decision
             OPEN cur_ou_mapping ( l_latest_trans_decision ,cur_ucas_app_choice_rec.system_code);
             FETCH cur_ou_mapping INTO cur_ou_mapping_rec;
              -- If the mapping of Transaction Decision to Default OSS User Outcome Status is defined
             IF cur_ou_mapping%FOUND THEN
               /* Populate the Admission Decision Import Interface tables with the default OSS user outcome status
                corresponding to UCAS Transaction Decision */
               -- 1. Insert a record into Admission Decision Import Interface table,IGS_AD_ADMDE_INT_ALL

               /* Get the Interface Run ID value from Sequence */
               OPEN cur_interface_ctl_s ;
               FETCH cur_interface_ctl_s INTO l_interface_run_id;
               CLOSE cur_interface_ctl_s;

               -- Derive the Reconsideration Flag value based on the Admission outcome status to be changed.  This Reconsideration
               -- Flag value will be stored in igs_ad_admde_int_all table and used for exporting UCAS decisions to OSS.
               l_reconsideration_flag := NULL;
               IF igs_ad_gen_008.admp_get_saos(cur_ou_mapping_rec.adm_outcome_status) IN ('REJECTED','NO-QUOTA') THEN
                 -- Set the Reconsideration Flat to 'Y' for allowing institutions to process UCAS applications seemlessly.
                 l_reconsideration_flag := 'Y';
               ELSE
                 -- When Application Decision to be changed is not REJECTED or NO-QUOTA then there is no need to set the flag.
                 l_reconsideration_flag := 'N';
               END IF;

               /* call the insert_row of the Admission Decision Import Interface table, IGS_AD_ADMDE_INT_ALL */
               igs_ad_admde_int_pkg.insert_row (
                   x_rowid                    =>  l_rowid,
                   x_interface_mkdes_id       =>  l_interface_mkdes_id,
                   x_interface_run_id         =>  l_interface_run_id,
                   x_batch_id                 =>  l_batch_id,
                   x_person_id                =>  cur_oss_appl_inst_rec.person_id,
                   x_admission_appl_number    =>  cur_oss_appl_inst_rec.admission_appl_number,
                   x_nominated_course_cd      =>  cur_oss_appl_inst_rec.nominated_course_cd,
                   x_sequence_number          =>  cur_oss_appl_inst_rec.sequence_number,
                   x_adm_outcome_status       =>  cur_ou_mapping_rec.adm_outcome_status,
                   x_decision_make_id         =>  cur_ucas_setup_rec.decision_make_id,
                   x_decision_date            =>  TRUNC(NVL(cur_ucas_app_choice_rec.decision_date, SYSDATE)),
                   x_decision_reason_id       =>  cur_ucas_setup_rec.decision_reason_id,
                   x_pending_reason_id        =>  NULL,
                   x_offer_dt                 =>  TRUNC(cur_latest_trans_rec.creation_date), --Populate the Transaction Date
                   x_offer_response_dt        =>  NULL,
                   x_status                   =>  '2', -- pending status
                   x_error_code               =>  NULL,
                   x_mode                     =>  'R',
                   x_reconsider_flag          =>  l_reconsideration_flag );

               -- 3. Update the Application Choice Record with export_to_oss_status='DP' and Concurrent Request ID
               l_export_to_oss_status := 'DP';
               l_app_choice_error_code := NULL ;
               l_ch_batch_id := NULL ;

             ELSE /* raise the error with code 'D006' */

              l_app_choice_error_code := 'D006' ;
              l_export_to_oss_status := cur_ucas_app_choice_rec.export_to_oss_status;
              l_ch_batch_id := NULL ;

              -- Write the error message to the Log file indicating the error occurred
              fnd_message.set_name('IGS','IGS_UC_TRANS_DEC_NOT_MAPPED');
              fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
              fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
              fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

             END IF;
             CLOSE cur_ou_mapping;

           END IF; /* end of the latest decision setting transaction logic */

         END IF; /* End of the System Admission outcome status is one of 'REJECTED','VOIDED', 'WITHDRAWN' */

       /*** Logic For: If all the above four conditions are failed */
       ELSE /*   then no need to impot the Admission decision. Change the export to OSS status to 'DC' */

         -- Update the Appchoice record with export_to_oss_status as 'DC'
         l_export_to_oss_status := 'DC' ;
         l_app_choice_error_code := NULL ;
         l_ch_batch_id := NULL ;

       END IF; /* end of Previous Outcome details process */
       CLOSE cur_prev_ou_captured;

       -- jchin - 3691277 and 3691250
       END IF;  /* End If for cursor cur_unit_set_cd%NOTFOUND */
       CLOSE cur_unit_set_cd;


     END IF; /* End of processing the current OSS Application Instance */
     CLOSE cur_oss_appl_inst;

     /* *********  End of populating the Admission Decision Import Interface Table *********/

    /* If the Application choice status is changed to 'DP', then Call the Admission Decision
        Import Process which update the outcome decision for an application  */
     IF l_export_to_oss_status = 'DP' THEN

       -- Fetch the populated record from the Import Interface Table
       OPEN cur_admde_interface ( l_interface_mkdes_id ) ;
       FETCH cur_admde_interface INTO cur_admde_interface_rec ;
       CLOSE cur_admde_interface ;

       OPEN cur_batc_def_det ( cur_admde_interface_rec.batch_id ) ;
       FETCH cur_batc_def_det INTO cur_batc_def_det_rec ;
       CLOSE cur_batc_def_det ;

       -- Find the System Admission Outcome status
       OPEN cur_s_adm_ou_stat( cur_admde_interface_rec.adm_outcome_status ) ;
       FETCH cur_s_adm_ou_stat INTO cur_s_adm_ou_stat_rec ;
       CLOSE cur_s_adm_ou_stat ;

       l_reconsideration_flag := NULL;
       IF cur_s_adm_ou_stat_rec.s_adm_outcome_status IN ('REJECTED','NO-QUOTA') THEN
         l_reconsideration_flag := 'Y';
       ELSE
         l_reconsideration_flag := 'N';
       END IF;

       /* Admission Decision Import Process Call */

       igs_ad_imp_adm_des.prc_adm_outcome_status(
          p_person_id                => cur_admde_interface_rec.person_id ,
          p_admission_appl_number    => cur_admde_interface_rec.admission_appl_number ,
          p_nominated_course_cd      => cur_admde_interface_rec.nominated_course_cd ,
          p_sequence_number          => cur_admde_interface_rec.sequence_number ,
          p_adm_outcome_status       => cur_admde_interface_rec.adm_outcome_status ,
          p_s_adm_outcome_status     => cur_s_adm_ou_stat_rec.s_adm_outcome_status ,
          p_acad_cal_type            => cur_batc_def_det_rec.acad_cal_type ,
          p_acad_ci_sequence_number  => cur_batc_def_det_rec.acad_ci_sequence_number ,
          p_adm_cal_type             => cur_batc_def_det_rec.adm_cal_type ,
          p_adm_ci_sequence_number   => cur_batc_def_det_rec.adm_ci_sequence_number ,
          p_admission_cat            => cur_batc_def_det_rec.admission_cat ,
          p_s_admission_process_type => cur_batc_def_det_rec.s_admission_process_type ,
          p_batch_id                 => cur_admde_interface_rec.batch_id ,
          p_interface_run_id         => cur_admde_interface_rec.interface_run_id ,
          p_interface_mkdes_id       => cur_admde_interface_rec.interface_mkdes_id ,
          p_error_message            => l_error_message, -- Replaced error_code with error_message Bug 3297241
          p_return_status            => l_return_status,
          p_ucas_transaction         => 'Y',
          p_reconsideration          => l_reconsideration_flag);

       IF l_return_status = 'FALSE' AND l_error_message IS NOT NULL THEN

         /* raise the error with code 'D001' */
         l_app_choice_error_code :='D001' ;
         l_export_to_oss_status :='DP';
         l_ch_batch_id := l_batch_id ;

         -- Write the error message to the Log file indicating the error occurred
         fnd_message.set_name('IGS','IGS_UC_DEC_IMP_ERR');
         fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
         fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
         fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

       ELSE  /* If l_error_message IS NULL, that means Decision Process was successfull */
         l_app_choice_error_code := NULL ;
         l_export_to_oss_status :='DC';
         l_ch_batch_id := NULL ;

       END IF ;

     END IF ;

    /*  Update the  Application choice record with the error code, batch_id and status */

     igs_uc_app_choices_pkg.update_row
             ( x_rowid                      => cur_ucas_app_choice_rec.ROWID
              ,x_app_choice_id              => cur_ucas_app_choice_rec.app_choice_id
              ,x_app_id                     => cur_ucas_app_choice_rec.app_id
              ,x_app_no                     => cur_ucas_app_choice_rec.app_no
              ,x_choice_no                  => cur_ucas_app_choice_rec.choice_no
              ,x_last_change                => cur_ucas_app_choice_rec.last_change
              ,x_institute_code             => cur_ucas_app_choice_rec.institute_code
              ,x_ucas_program_code          => cur_ucas_app_choice_rec.ucas_program_code
              ,x_oss_program_code           => cur_ucas_app_choice_rec.oss_program_code
              ,x_oss_program_version        => cur_ucas_app_choice_rec.oss_program_version
              ,x_oss_attendance_type        => cur_ucas_app_choice_rec.oss_attendance_type
              ,x_oss_attendance_mode        => cur_ucas_app_choice_rec.oss_attendance_mode
              ,x_campus                     => cur_ucas_app_choice_rec.campus
              ,x_oss_location               => cur_ucas_app_choice_rec.oss_location
              ,x_faculty                    => cur_ucas_app_choice_rec.faculty
              ,x_entry_year                 => cur_ucas_app_choice_rec.entry_year
              ,x_entry_month                => cur_ucas_app_choice_rec.entry_month
              ,x_point_of_entry             => cur_ucas_app_choice_rec.point_of_entry
              ,x_home                       => cur_ucas_app_choice_rec.home
              ,x_deferred                   => cur_ucas_app_choice_rec.deferred
              ,x_route_b_pref_round         => cur_ucas_app_choice_rec.route_b_pref_round
              ,x_route_b_actual_round       => cur_ucas_app_choice_rec.route_b_actual_round
              ,x_condition_category         => cur_ucas_app_choice_rec.condition_category
              ,x_condition_code             => cur_ucas_app_choice_rec.condition_code
              ,x_decision                   => cur_ucas_app_choice_rec.decision
              ,x_decision_date              => cur_ucas_app_choice_rec.decision_date
              ,x_decision_number            => cur_ucas_app_choice_rec.decision_number
              ,x_reply                      => cur_ucas_app_choice_rec.reply
              ,x_summary_of_cond            => cur_ucas_app_choice_rec.summary_of_cond
              ,x_choice_cancelled           => cur_ucas_app_choice_rec.choice_cancelled
              ,x_action                     => cur_ucas_app_choice_rec.action
              ,x_substitution               => cur_ucas_app_choice_rec.substitution
              ,x_date_substituted           => cur_ucas_app_choice_rec.date_substituted
              ,x_prev_institution           => cur_ucas_app_choice_rec.prev_institution
              ,x_prev_course                => cur_ucas_app_choice_rec.prev_course
              ,x_prev_campus                => cur_ucas_app_choice_rec.prev_campus
              ,x_ucas_amendment             => cur_ucas_app_choice_rec.ucas_amendment
              ,x_withdrawal_reason          => cur_ucas_app_choice_rec.withdrawal_reason
              ,x_offer_course               => cur_ucas_app_choice_rec.offer_course
              ,x_offer_campus               => cur_ucas_app_choice_rec.offer_campus
              ,x_offer_crse_length          => cur_ucas_app_choice_rec.offer_crse_length
              ,x_offer_entry_month          => cur_ucas_app_choice_rec.offer_entry_month
              ,x_offer_entry_year           => cur_ucas_app_choice_rec.offer_entry_year
              ,x_offer_entry_point          => cur_ucas_app_choice_rec.offer_entry_point
              ,x_offer_text                 => cur_ucas_app_choice_rec.offer_text
              ,x_export_to_oss_status       => l_export_to_oss_status
              ,x_error_code                 => l_app_choice_error_code
              ,x_request_id                 => l_conc_request_id
              ,x_batch_id                   => l_ch_batch_id
              ,x_mode                       => 'R'
              ,x_extra_round_nbr            => cur_ucas_app_choice_rec.extra_round_nbr
              ,x_system_code                => cur_ucas_app_choice_rec.system_code
              ,x_part_time                  => cur_ucas_app_choice_rec.part_time
              ,x_interview                  => cur_ucas_app_choice_rec.interview
              ,x_late_application           => cur_ucas_app_choice_rec.late_application
              ,x_modular                    => cur_ucas_app_choice_rec.modular
              ,x_residential                => cur_ucas_app_choice_rec.residential
              ,x_ucas_cycle                 => cur_ucas_app_choice_rec.ucas_cycle);

  END LOOP ; /*  end of processing the application choice records */


  /* Check for the Previous Application Choices which are errored out earlier,
     but corrected by running the Decision Import Process Independently.
     If there are no errors in the Admission Decision Importinterface table,
     then change the corresponding Application Choice export to OSS status to 'DC' */
  FOR cur_dp_app_choice_rec IN cur_dp_app_choice LOOP

     -- Fetch the default values setup for the UCAS SYSTEM to which this application choice belongs to,
     -- These values will be used in this procedure wherever default values requires
     cur_ucas_setup_rec := NULL ;
     OPEN cur_ucas_setup(cur_dp_app_choice_rec.system_code) ;
     FETCH cur_ucas_setup INTO cur_ucas_setup_rec;
     CLOSE cur_ucas_setup;

     -- 1. Get the Batch ID corresponding to the UCAS system available in Admission Decision Import Batch table,IGS_AD_BATC_DEF_DET_ALL
     l_batch_id := NULL ;
     l_batch_id_loc := NULL;
     get_batchid_loc(p_system_code  => cur_dp_app_choice_rec.system_code,
                     p_entry_year   => cur_dp_app_choice_rec.entry_year,
                     p_entry_month  => cur_dp_app_choice_rec.entry_month,
                     p_batch_id_loc => l_batch_id_loc);
     IF l_batch_id_loc IS NOT NULL THEN
       l_batch_id := l_batch_id_det(l_batch_id_loc).batch_id;
     ELSE
       --If batch ID is not availabe then assign it as zero.  So that the application choice
       -- will be identified as errored in previous run and necessary checks will be performed
       -- to move the application choice status to DC.
       l_batch_id := 0;
     END IF;

    IF  cur_dp_app_choice_rec.batch_id <> l_batch_id THEN

      OPEN cur_oss_appl_inst( cur_dp_app_choice_rec.app_no,
                              cur_dp_app_choice_rec.choice_no,
                              cur_dp_app_choice_rec.ucas_cycle);
      FETCH cur_oss_appl_inst INTO cur_oss_appl_inst_rec;

      -- jchin - bug 3691277 and 3691250
      IF cur_oss_appl_inst%FOUND THEN
        /* OSS Application Instance Found */
        --check whether the matching unit-set-code exists for the identofi application instance
        OPEN cur_unit_set_cd(cur_oss_appl_inst_rec.unit_set_cd,
                             cur_oss_appl_inst_rec.us_version_number,
                             cur_oss_appl_inst_rec.nominated_course_cd,
                             cur_oss_appl_inst_rec.crv_version_number,
                             cur_oss_appl_inst_rec.acad_cal_type,
                             cur_oss_appl_inst_rec.location_cd,
                             cur_oss_appl_inst_rec.attendance_mode,
                             cur_oss_appl_inst_rec.attendance_type,
                             cur_oss_appl_inst_rec.point_of_entry);
        FETCH cur_unit_set_cd INTO cur_unit_set_cd_rec;

        IF cur_unit_set_cd%FOUND THEN
          /* OSS Application Instance and unit-set-code found */
          --Continue processing

      OPEN cur_dec_import_error ( cur_dp_app_choice_rec.batch_id,
                                  cur_oss_appl_inst_rec.person_id,
                                  cur_oss_appl_inst_rec.admission_appl_number,
                                  cur_oss_appl_inst_rec.nominated_course_cd,
                                  cur_oss_appl_inst_rec.sequence_number );
      FETCH cur_dec_import_error INTO cur_dec_import_error_rec;

      IF cur_dec_import_error%NOTFOUND THEN

        igs_uc_app_choices_pkg.update_row (
         x_rowid                      => cur_dp_app_choice_rec.ROWID
        ,x_app_choice_id              => cur_dp_app_choice_rec.app_choice_id
        ,x_app_id                     => cur_dp_app_choice_rec.app_id
        ,x_app_no                     => cur_dp_app_choice_rec.app_no
        ,x_choice_no                  => cur_dp_app_choice_rec.choice_no
        ,x_last_change                => cur_dp_app_choice_rec.last_change
        ,x_institute_code             => cur_dp_app_choice_rec.institute_code
        ,x_ucas_program_code          => cur_dp_app_choice_rec.ucas_program_code
        ,x_oss_program_code           => cur_dp_app_choice_rec.oss_program_code
        ,x_oss_program_version        => cur_dp_app_choice_rec.oss_program_version
        ,x_oss_attendance_type        => cur_dp_app_choice_rec.oss_attendance_type
        ,x_oss_attendance_mode        => cur_dp_app_choice_rec.oss_attendance_mode
        ,x_campus                     => cur_dp_app_choice_rec.campus
        ,x_oss_location               => cur_dp_app_choice_rec.oss_location
        ,x_faculty                    => cur_dp_app_choice_rec.faculty
        ,x_entry_year                 => cur_dp_app_choice_rec.entry_year
        ,x_entry_month                => cur_dp_app_choice_rec.entry_month
        ,x_point_of_entry             => cur_dp_app_choice_rec.point_of_entry
        ,x_home                       => cur_dp_app_choice_rec.home
        ,x_deferred                   => cur_dp_app_choice_rec.deferred
        ,x_route_b_pref_round         => cur_dp_app_choice_rec.route_b_pref_round
        ,x_route_b_actual_round       => cur_dp_app_choice_rec.route_b_actual_round
        ,x_condition_category         => cur_dp_app_choice_rec.condition_category
        ,x_condition_code             => cur_dp_app_choice_rec.condition_code
        ,x_decision                   => cur_dp_app_choice_rec.decision
        ,x_decision_date              => cur_dp_app_choice_rec.decision_date
        ,x_decision_number            => cur_dp_app_choice_rec.decision_number
        ,x_reply                      => cur_dp_app_choice_rec.reply
        ,x_summary_of_cond            => cur_dp_app_choice_rec.summary_of_cond
        ,x_choice_cancelled           => cur_dp_app_choice_rec.choice_cancelled
        ,x_action                     => cur_dp_app_choice_rec.action
        ,x_substitution               => cur_dp_app_choice_rec.substitution
        ,x_date_substituted           => cur_dp_app_choice_rec.date_substituted
        ,x_prev_institution           => cur_dp_app_choice_rec.prev_institution
        ,x_prev_course                => cur_dp_app_choice_rec.prev_course
        ,x_prev_campus                => cur_dp_app_choice_rec.prev_campus
        ,x_ucas_amendment             => cur_dp_app_choice_rec.ucas_amendment
        ,x_withdrawal_reason          => cur_dp_app_choice_rec.withdrawal_reason
        ,x_offer_course               => cur_dp_app_choice_rec.offer_course
        ,x_offer_campus               => cur_dp_app_choice_rec.offer_campus
        ,x_offer_crse_length          => cur_dp_app_choice_rec.offer_crse_length
        ,x_offer_entry_month          => cur_dp_app_choice_rec.offer_entry_month
        ,x_offer_entry_year           => cur_dp_app_choice_rec.offer_entry_year
        ,x_offer_entry_point          => cur_dp_app_choice_rec.offer_entry_point
        ,x_offer_text                 => cur_dp_app_choice_rec.offer_text
        ,x_export_to_oss_status       => 'DC'
        ,x_error_code                 => NULL
        ,x_request_id                 => l_conc_request_id
        ,x_batch_id                   => NULL
        ,x_mode                       => 'R'
        ,x_extra_round_nbr            => cur_dp_app_choice_rec.extra_round_nbr
        ,x_system_code                => cur_dp_app_choice_rec.system_code
        ,x_part_time                  => cur_dp_app_choice_rec.part_time
        ,x_interview                  => cur_dp_app_choice_rec.interview
        ,x_late_application           => cur_dp_app_choice_rec.late_application
        ,x_modular                    => cur_dp_app_choice_rec.modular
        ,x_residential                => cur_dp_app_choice_rec.residential
        ,x_ucas_cycle                 => cur_dp_app_choice_rec.ucas_cycle);

      ELSE

        -- Write the error message to the Log file indicating the error occurred
        fnd_message.set_name('IGS','IGS_UC_DEC_IMP_ERR');
        fnd_message.set_token('APP_NO',TO_CHAR(cur_dp_app_choice_rec.app_no));
        fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_dp_app_choice_rec.choice_no));
        fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

      END IF;
      CLOSE cur_dec_import_error;

        -- jchin - 3691277 and 3691250
        END IF;  /* End If for cursor cur_unit_set_cd%FOUND */
        CLOSE cur_unit_set_cd;
      END IF ; /* End If for cur_oss_appl_inst%FOUND */
      CLOSE cur_oss_appl_inst;

    END IF ;

  END LOOP ; /* End of previous Application Choices which are errored out */

  EXCEPTION
    WHEN OTHERS THEN

      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_EXPORT_DECISION_REPLY.EXPORT_DECISION'||' - '||SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

END export_decision;



PROCEDURE export_reply( p_app_no        IGS_UC_APP_CHOICES.APP_NO%TYPE,
                        p_choice_number IGS_UC_APP_CHOICES.CHOICE_NO%TYPE ) AS
/******************************************************************
 Created By      :   ayedubat
 Date Created By :   16-SEP-2002
 Purpose         :   This process exports the UCAS reply to OSS by populating the admissions
                     offer response import process interface tables
 Known limitations,enhancements,remarks:
 Change History
 Who        When          What
 Nishikant  01-OCT-2002   A new column extra_round_nbr added in the TBH calls of
                          the package IGS_UC_APP_CHOICES_PKG.
 Ayedubat  18-OCT-2002     Passed NULL to the column,ACTUAL_OFFER_RESPONSE_DT while populating into the interface table,IGS_AD_OFFRESP_INT for the bug fix:2632302
 jchin     20-jan-2006    Modified for R12 Perf improvements - bug 3691277 and 3691250
 jchakrab  22-May-2006    Modified for 5165624
 jbaber    07-Jun-2006    Added decline_ofr_reason for bug 528190/5222716
 ******************************************************************/

  -- Local Variables definition
  l_batch_id igs_ad_offresp_batch.batch_id%TYPE ;
  l_conc_request_id NUMBER(15) ;
  l_errbuf VARCHAR2(2000) ;
  l_retcode NUMBER(15) ;
  l_export_to_oss igs_uc_app_choices.export_to_oss_status%TYPE ;
  l_app_choice_error_code igs_uc_app_choices.error_code%TYPE ;
  l_last_update_login NUMBER(15)  ;
  l_last_updated_by NUMBER(15) ;
  l_description VARCHAR2(2000);
  l_aca_cal_type igs_uc_sys_calndrs.aca_cal_type%TYPE ;
  l_aca_seq_no igs_uc_sys_calndrs.aca_cal_seq_no%TYPE;
  l_adm_cal_type igs_uc_sys_calndrs.adm_cal_type%TYPE ;
  l_adm_seq_no igs_uc_sys_calndrs.adm_cal_seq_no%TYPE ;
  l_ch_error igs_uc_app_choices.error_code%TYPE ;
  l_ch_batch_id igs_uc_app_choices.batch_id%TYPE ;
  l_exp_reply_flag  BOOLEAN ;

  -- Cursor to find the details of default UCAS setup defined in the SYSTEM.
  -- smaddali modified this cursor to add the where clause of System_code check , bug 2643048 UCFD102 build
  CURSOR cur_ucas_setup( cp_system_code igs_uc_defaults.system_code%TYPE)  IS
    SELECT *
    FROM igs_uc_defaults
    WHERE system_code = cp_system_code ;
  cur_ucas_setup_rec cur_ucas_setup%ROWTYPE;

  -- Cursor to fetch the UCAS Application choices
  -- If both application number and choice are not passed it fetches all the application choices
  -- If only application number is passed, it fetches the App. choices of the passed app. number
  -- If both App. number and Choice are passed, it fetches only one Application
    -- smaddali modified this cursor to add the where clause of System_code check , bug 2643048 UCFD102 build
  CURSOR cur_ucas_app_choice IS
    SELECT uac.*,uac.ROWID
    FROM IGS_UC_APP_CHOICES uac,
         igs_uc_defaults ud
    WHERE uac.app_no = NVL(p_app_no,uac.app_no)
    AND   uac.choice_no = NVL( p_choice_number,uac.choice_no )
    AND   uac.export_to_oss_status = 'DC'
    AND   uac.institute_code = ud.current_inst_code
    AND   uac.system_code = ud.system_code
    ORDER BY uac.ucas_cycle, uac.app_no, uac.choice_no;
  cur_ucas_app_choice_rec cur_ucas_app_choice%ROWTYPE;

  -- Cursor to find the OSS Application Instance for the current UACS Application Choice
  -- smaddali modified this cursor to add the where clause of System_code check ,
  --  and modifying the where clause comparing calendars , bug 2643048 UCFD102 build
  -- jchin - bug 3691277 and 3691250
  CURSOR cur_oss_appl_inst( cp_app_no     igs_uc_app_choices.app_no%TYPE,
                            cp_choice_no  igs_uc_app_choices.choice_no%TYPE,
                            cp_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE) IS
    SELECT APLINST.ADM_OUTCOME_STATUS, APLINST.ADM_OFFER_RESP_STATUS,
           APLINST.PERSON_ID, APLINST.ADMISSION_APPL_NUMBER,
           APLINST.NOMINATED_COURSE_CD, APLINST.SEQUENCE_NUMBER,
           APLINST.CRV_VERSION_NUMBER, APLINST.LOCATION_CD,
           APLINST.ATTENDANCE_MODE, APLINST.ATTENDANCE_TYPE, APLINST.UNIT_SET_CD,
           APLINST.US_VERSION_NUMBER, APL.ACAD_CAL_TYPE, UAC.POINT_OF_ENTRY
    FROM   IGS_UC_APP_CHOICES UAC,
           IGS_UC_APPLICANTS UA,
           IGS_UC_DEFAULTS UD,
           IGS_AD_SS_APPL_TYP AAT,
           IGS_AD_APPL_ALL APL,
           IGS_AD_PS_APPL_INST_ALL APLINST,
           IGS_UC_SYS_CALNDRS USC
    WHERE  UAC.APP_NO = CP_APP_NO
    AND    UAC.CHOICE_NO = CP_CHOICE_NO
    AND    UAC.UCAS_CYCLE = CP_UCAS_CYCLE
    AND    UA.APP_NO = UAC.APP_NO
    AND    UA.OSS_PERSON_ID = APL.PERSON_ID
    AND    TO_CHAR (UA.APP_NO) = APL.ALT_APPL_ID
    AND    APL.CHOICE_NUMBER = UAC.CHOICE_NO
    AND    UAC.SYSTEM_CODE = UD.SYSTEM_CODE
    AND    UD.APPLICATION_TYPE = AAT.ADMISSION_APPLICATION_TYPE
    AND    UAC.SYSTEM_CODE = USC.SYSTEM_CODE
    AND    UAC.ENTRY_YEAR = USC.ENTRY_YEAR
    AND    (UAC.ENTRY_MONTH = USC.ENTRY_MONTH OR USC.ENTRY_MONTH = 0)
    AND    APL.ACAD_CAL_TYPE = USC.ACA_CAL_TYPE
    AND    APL.ACAD_CI_SEQUENCE_NUMBER = USC.ACA_CAL_SEQ_NO
    AND    APL.ADM_CAL_TYPE = USC.ADM_CAL_TYPE
    AND    APL.ADM_CI_SEQUENCE_NUMBER = USC.ADM_CAL_SEQ_NO
    AND    APL.ADMISSION_CAT = AAT.ADMISSION_CAT
    AND    APL.S_ADMISSION_PROCESS_TYPE = AAT.S_ADMISSION_PROCESS_TYPE
    AND    APL.PERSON_ID = APLINST.PERSON_ID
    AND    APL.ADMISSION_APPL_NUMBER = APLINST.ADMISSION_APPL_NUMBER
    AND    APLINST.NOMINATED_COURSE_CD = UAC.OSS_PROGRAM_CODE
    AND    APLINST.CRV_VERSION_NUMBER = UAC.OSS_PROGRAM_VERSION
    AND    APLINST.LOCATION_CD = UAC.OSS_LOCATION
    AND    APLINST.ATTENDANCE_MODE = UAC.OSS_ATTENDANCE_MODE
    AND    APLINST.ATTENDANCE_TYPE = UAC.OSS_ATTENDANCE_TYPE;
  cur_oss_appl_inst_rec cur_oss_appl_inst%ROWTYPE;

  -- jchin - bug 3691277 and 3691250
  -- new cursor Check the existence of unit set code corresponding to the application instance
  CURSOR cur_unit_set_cd(
           p_unit_set_cd  igs_ad_ps_appl_inst_all.unit_set_cd%TYPE,
           p_us_version_number  igs_ad_ps_appl_inst_all.us_version_number%TYPE,
           p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
           p_crv_version_number  igs_ad_ps_appl_inst_all.crv_version_number%TYPE,
           p_acad_cal_type  igs_ad_appl_all.acad_cal_type%TYPE,
           p_location_cd  igs_ad_ps_appl_inst_all.location_cd%TYPE,
           p_attendance_mode  igs_ad_ps_appl_inst_all.attendance_mode%TYPE,
           p_attendance_type  igs_ad_ps_appl_inst_all.attendance_type%TYPE,
           p_point_of_entry  igs_uc_app_choices.point_of_entry%TYPE
           ) IS
    SELECT US.UNIT_SET_CD,
           US.VERSION_NUMBER US_VERSION_NUMBER
    FROM   IGS_PS_OFR_UNIT_SET COUS,
           IGS_PS_OFR_OPT COO,
           IGS_EN_UNIT_SET US,
           IGS_EN_UNIT_SET_CAT USC,
           IGS_PS_US_PRENR_CFG CFG
    WHERE  COUS.UNIT_SET_CD = P_UNIT_SET_CD
    AND    COUS.US_VERSION_NUMBER = P_US_VERSION_NUMBER
    AND    COUS.COURSE_CD = P_NOMINATED_COURSE_CD
    AND    COUS.CRV_VERSION_NUMBER = P_CRV_VERSION_NUMBER
    AND    COUS.CAL_TYPE = P_ACAD_CAL_TYPE
    AND    COO.LOCATION_CD = P_LOCATION_CD
    AND    COO.ATTENDANCE_MODE = P_ATTENDANCE_MODE
    AND    COO.ATTENDANCE_TYPE = P_ATTENDANCE_TYPE
    AND    COO.COURSE_CD = COUS.COURSE_CD
    AND    COO.VERSION_NUMBER = COUS.CRV_VERSION_NUMBER
    AND    COO.CAL_TYPE = COUS.CAL_TYPE
    AND    US.UNIT_SET_CD = COUS.UNIT_SET_CD
    AND    US.VERSION_NUMBER = COUS.US_VERSION_NUMBER
    AND    US.UNIT_SET_CAT = USC.UNIT_SET_CAT
    AND    USC.S_UNIT_SET_CAT ='PRENRL_YR'
    AND    US.UNIT_SET_CD = CFG.UNIT_SET_CD
    AND    CFG.SEQUENCE_NO = NVL(P_POINT_OF_ENTRY,1)
    AND    NOT EXISTS (SELECT COURSE_CD FROM IGS_PS_OF_OPT_UNT_ST COOUS WHERE COOUS.COO_ID = COO.COO_ID)
    UNION ALL
    SELECT US.UNIT_SET_CD,
           US.VERSION_NUMBER US_VERSION_NUMBER
    FROM   IGS_PS_OF_OPT_UNT_ST COOUS,
           IGS_EN_UNIT_SET US,
           IGS_EN_UNIT_SET_CAT USC,
           IGS_PS_US_PRENR_CFG CFG
    WHERE  COOUS.UNIT_SET_CD = P_UNIT_SET_CD
    AND    COOUS.US_VERSION_NUMBER = P_US_VERSION_NUMBER
    AND    COOUS.COURSE_CD = P_NOMINATED_COURSE_CD
    AND    COOUS.CRV_VERSION_NUMBER = P_CRV_VERSION_NUMBER
    AND    COOUS.CAL_TYPE = P_ACAD_CAL_TYPE
    AND    COOUS.LOCATION_CD = P_LOCATION_CD
    AND    COOUS.ATTENDANCE_MODE = P_ATTENDANCE_MODE
    AND    COOUS.ATTENDANCE_TYPE = P_ATTENDANCE_TYPE
    AND    US.UNIT_SET_CD = COOUS.UNIT_SET_CD
    AND    US.VERSION_NUMBER = COOUS.US_VERSION_NUMBER
    AND    US.UNIT_SET_CAT = USC.UNIT_SET_CAT
    AND    USC.S_UNIT_SET_CAT ='PRENRL_YR'
    AND    US.UNIT_SET_CD = CFG.UNIT_SET_CD
    AND    CFG.SEQUENCE_NO = NVL(P_POINT_OF_ENTRY,1);
  cur_unit_set_cd_rec cur_unit_set_cd%ROWTYPE;


  -- Cursor to get the OSS user Offer Response mapped to the UCAS system/decision and reply
    -- smaddali modified this cursor to add the where clause of System_code check , bug 2643048 UCFD102 build
  CURSOR cur_map_offr_resp( p_decision igs_uc_app_choices.decision%TYPE,
                            p_reply    igs_uc_app_choices.reply%TYPE,
          p_system_code igs_uc_app_choices.system_code%TYPE) IS
  SELECT adm_offer_resp_status
  FROM   igs_uc_map_off_resp
  WHERE system_code   = p_system_code
  AND   decision_code = p_decision
  AND   reply_code    = p_reply
  AND   closed_ind    <> 'Y';
  cur_map_offr_resp_rec cur_map_offr_resp%ROWTYPE;

  -- Cursor to fetch the System Admission Outcome status of the
  -- current OSS Application Instance outcome status
  CURSOR cur_s_adm_ou_stat(p_adm_out_status igs_ad_ou_stat.adm_outcome_status%TYPE) IS
    SELECT s_adm_outcome_status
    FROM  igs_ad_ou_stat
    WHERE adm_outcome_status = p_adm_out_status;
  cur_s_adm_ou_stat_rec cur_s_adm_ou_stat%ROWTYPE;

  -- Cursor to Fetch the Application Choices of export to OSS status 'RP'
  -- smaddali modified this cursor to add the where clause of System_code check , bug 2643048 UCFD102 build
  CURSOR cur_rp_app_choice IS
    SELECT uac.*,uac.ROWID
    FROM igs_uc_app_choices uac,
         igs_uc_defaults ud
    WHERE uac.app_no = NVL(p_app_no,uac.app_no)
    AND   uac.choice_no = NVL( p_choice_number,uac.choice_no )
    AND   uac.export_to_oss_status = 'RP'
    AND   uac.institute_code = ud.current_inst_code
    AND   uac.system_code = ud.system_code
    ORDER BY uac.ucas_cycle, uac.app_no, uac.choice_no;
  cur_rp_app_choice_rec cur_rp_app_choice%ROWTYPE ;

  -- Cursor to check for the error or pending records in the Offer Response Import Process
  CURSOR cur_reply_import_error ( p_person_id igs_ad_offresp_int.person_id%TYPE,
                                  p_admission_appl_number igs_ad_offresp_int.admission_appl_number%TYPE,
                                  p_nominated_course_cd igs_ad_offresp_int.nominated_course_cd%TYPE,
                                  p_sequence_number igs_ad_offresp_int.sequence_number%TYPE ) IS
    SELECT 'X'
    FROM igs_ad_offresp_int
    WHERE person_id             = p_person_id
    AND   admission_appl_number = p_admission_appl_number
    AND   nominated_course_cd   = p_nominated_course_cd
    AND   sequence_number       = p_sequence_number
    AND   status IN ( 2,3 ) ;
  cur_reply_import_error_rec cur_reply_import_error%ROWTYPE ;

  -- Cursor to fetch the value from the sequence for inserting a record into IGS_AD_OFFRESP_BATCH table
  CURSOR cur_offresp_batc_s IS
  SELECT igs_ad_offresp_batch_s.NEXTVAL
  FROM dual ;

  --Cursor to get the Calendar details for the given System, Entry Month and Entry Year.
  CURSOR cur_sys_entry_cal_det ( cp_system_code  igs_uc_sys_calndrs.system_code%TYPE,
                                 cp_entry_year   igs_uc_sys_calndrs.entry_year%TYPE,
                                 cp_entry_month  igs_uc_sys_calndrs.entry_month%TYPE ) IS
     SELECT aca_cal_type,
            aca_cal_seq_no,
            adm_cal_type,
            adm_cal_seq_no
     FROM  igs_uc_sys_calndrs
     WHERE system_code = cp_system_code
     AND   entry_year = cp_entry_year
     AND   entry_month = cp_entry_month;

  l_sys_entry_cal_det_rec cur_sys_entry_cal_det%ROWTYPE;

  -- Foloowing Local variables are used as OUT parameters for the FND procedure which waits until
  -- the Concurrent Request Completes
  l_phase              VARCHAR2(100) ;
  l_conc_status        VARCHAR2(100) ;
  l_dev_phase          VARCHAR2(100) ;
  l_dev_status         VARCHAR2(100) ;
  l_conc_message       VARCHAR2(100) ;
  l_conc_wait          BOOLEAN ;
  l_decline_ofr_reason VARCHAR2(100);

BEGIN /* begin of export_reply */

  -- Get the Concurrent Request ID of the current export of UCAS application to
  -- OSS admission applications run
  l_conc_request_id := fnd_global.conc_request_id() ;
  l_exp_reply_flag := FALSE ;

  -- Populate the Offer Response Import Interface Batch table,IGS_AD_OFFRESP_BATCH
  -- Get the Batch ID using the sequence, IGS_AD_OFFRESP_BATCH_S
  l_batch_id := NULL ;
  OPEN cur_offresp_batc_s ;
  FETCH cur_offresp_batc_s INTO l_batch_id ;
  CLOSE cur_offresp_batc_s ;

  -- Find the WHO columns to insert a record into IGS_AD_OFFRESP_BATCH table
  l_last_updated_by := NVL(FND_GLOBAL.USER_ID,-1) ;
  l_last_update_login :=  NVL(FND_GLOBAL.LOGIN_ID,-1) ;

  -- Get the Description value from the Message,IGS_UC_OFF_BATCH
  fnd_message.set_name('IGS','IGS_UC_OFF_BATCH');
  l_description := fnd_message.get;

  INSERT INTO igs_ad_offresp_batch
    (  batch_id,
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
    VALUES
    (  l_batch_id,
       l_description,
       l_last_updated_by,
       SYSDATE,
       l_last_updated_by,
       SYSDATE,
       l_last_update_login,
       fnd_global.conc_request_id,
       fnd_global.prog_appl_id,
       SYSDATE,
       fnd_global.conc_program_id  );

  /* Process all the Application Choice records of the passed p_app_no, p_choice_number
   and of the current institution with Export_to_oss Status = 'DC'  */

  FOR cur_ucas_app_choice_rec IN cur_ucas_app_choice LOOP

     -- Initialize the variable for each Application Choice
     l_app_choice_error_code := NULL ;
     l_export_to_oss := NULL ;
   /* Commented the re-initialization of the batch id variable for bug 2738551
      as the value is taken from igs_ad_offresp_batch_s sequence */
     -- l_batch_id := NULL ;

     -- Fetch the default values setup for the UCAS in the SYSTEM,
     -- These values will be used in this procedure whereever default values requires
     cur_ucas_setup_rec := NULL ;
     OPEN cur_ucas_setup(cur_ucas_app_choice_rec.system_code) ;
     FETCH cur_ucas_setup INTO cur_ucas_setup_rec;
     CLOSE cur_ucas_setup;

     --Get the Calendar details for the given System, Entry Month and Entry Year from System Calendards table.
     l_sys_entry_cal_det_rec := NULL;
     OPEN cur_sys_entry_cal_det(cur_ucas_app_choice_rec.system_code, cur_ucas_app_choice_rec.entry_year, cur_ucas_app_choice_rec.entry_month);
     FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
     --If no matching Entry Year and Entry Month record for the system is found in the System Calendars table then
     --  get the calendar details from the IGS_UC_SYS_CALNDRS table based on the system, Entry Year and Entry Month as 0 (Zero).
     IF cur_sys_entry_cal_det%NOTFOUND THEN
       CLOSE cur_sys_entry_cal_det;
       OPEN cur_sys_entry_cal_det(cur_ucas_app_choice_rec.system_code, cur_ucas_app_choice_rec.entry_year, 0);
       FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
     END IF;
     CLOSE cur_sys_entry_cal_det;

     l_aca_cal_type  := l_sys_entry_cal_det_rec.aca_cal_type ;
     l_aca_seq_no    := l_sys_entry_cal_det_rec.aca_cal_seq_no;
     l_adm_cal_type  := l_sys_entry_cal_det_rec.adm_cal_type;
     l_adm_seq_no    := l_sys_entry_cal_det_rec.adm_cal_seq_no ;

     -- Identify whether the Application Instance for the current Application Choice Exist or not
     OPEN cur_oss_appl_inst( cur_ucas_app_choice_rec.app_no,
                             cur_ucas_app_choice_rec.choice_no,
                             cur_ucas_app_choice_rec.ucas_cycle);
     FETCH cur_oss_appl_inst INTO cur_oss_appl_inst_rec;

     IF cur_oss_appl_inst%NOTFOUND THEN

       -- Raise the error with Error Code as 'R002'
       l_app_choice_error_code := 'R002' ;
       l_export_to_oss := cur_ucas_app_choice_rec.export_to_oss_status ;
       l_ch_batch_id := NULL ;
       -- Write the error message to the Log file indicating the error occurred
       fnd_message.set_name('IGS','IGS_UC_APP_INST_NOTFOUND');
       fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
       fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

     ELSE  /* OSS Application Instance Found */

       -- jchin - Bug 3691277 and 3691250
       --check whether the matching unit-set-code exists for the identofi application instance
       OPEN cur_unit_set_cd(cur_oss_appl_inst_rec.unit_set_cd,
                            cur_oss_appl_inst_rec.us_version_number,
                            cur_oss_appl_inst_rec.nominated_course_cd,
                            cur_oss_appl_inst_rec.crv_version_number,
                            cur_oss_appl_inst_rec.acad_cal_type,
                            cur_oss_appl_inst_rec.location_cd,
                            cur_oss_appl_inst_rec.attendance_mode,
                            cur_oss_appl_inst_rec.attendance_type,
                            cur_oss_appl_inst_rec.point_of_entry);
       FETCH cur_unit_set_cd INTO cur_unit_set_cd_rec;

       IF cur_unit_set_cd%NOTFOUND THEN
         -- update UCAS Application Chocie record to set error Code to 'D002'
         l_app_choice_error_code := 'D002' ;
         l_export_to_oss := cur_ucas_app_choice_rec.export_to_oss_status ;
         l_ch_batch_id := NULL ;
         -- Write the error message to the Log file indicating the error occurred
         fnd_message.set_name('IGS','IGS_UC_APP_INST_NOTFOUND');
         fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
         fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
         fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       ELSE /* OSS Application Instance and unit-set-code found */


       -- Check whether UCAS reply needs to exported to OSS or not
       IF cur_ucas_app_choice_rec.reply IS NOT NULL THEN

     -- Find the OSS user Offer Response mapped to the UCAS system decision and reply
     OPEN cur_map_offr_resp( cur_ucas_app_choice_rec.decision,
            cur_ucas_app_choice_rec.reply ,cur_ucas_app_choice_rec.system_code);
     FETCH cur_map_offr_resp INTO cur_map_offr_resp_rec;

     /* If OSS user Offer Response is not mapped to the UCAS system decision and reply  */
     IF cur_map_offr_resp%NOTFOUND THEN
      CLOSE cur_map_offr_resp;
      -- Raise the error with Error Code as 'R003'
      l_app_choice_error_code := 'R003' ;
      l_export_to_oss := cur_ucas_app_choice_rec.export_to_oss_status ;
      l_ch_batch_id := NULL ;
            -- Write the error message to the Log file indicating the error occurred
      fnd_message.set_name('IGS','IGS_UC_DEC_REPLY_NOT_MAPPED');
      fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
      fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
      fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

     ELSE /* OSS user Offer Response mapping to the UCAS system decision and reply found */
      CLOSE cur_map_offr_resp;
      -- Check whether the OSS Application Instance system outcome status is 'OFFER' or 'COND-OFFER'
      OPEN cur_s_adm_ou_stat( cur_oss_appl_inst_rec.adm_outcome_status );
      FETCH cur_s_adm_ou_stat INTO cur_s_adm_ou_stat_rec;
      CLOSE cur_s_adm_ou_stat ;
      IF cur_s_adm_ou_stat_rec.s_adm_outcome_status NOT IN ( 'OFFER', 'COND-OFFER' ) THEN
             -- Raise the error with Error Code as 'R004'
             l_app_choice_error_code := 'R004' ;
             l_export_to_oss := cur_ucas_app_choice_rec.export_to_oss_status ;
             l_ch_batch_id := NULL ;
             -- Write the error message to the Log file indicating the error occurred
             fnd_message.set_name('IGS','IGS_UC_APP_NOT_OFFERED');
             fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
             fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
             fnd_file.put_line( fnd_file.LOG ,fnd_message.get );

      ELSE /* OSS Application Instnace system Offer Response status is 'OFFER' or 'COND-OFFER' */

          -- If the OSS User Admission Offer Response Status mapped to the
          -- Application Choice Reply is not equal to OSS Application Instance Offer Response Status
          IF cur_map_offr_resp_rec.adm_offer_resp_status <> cur_oss_appl_inst_rec.adm_offer_resp_status THEN

            IF igs_ad_gen_008.admp_get_saors(cur_map_offr_resp_rec.adm_offer_resp_status) = 'REJECTED' THEN
               l_decline_ofr_reason := 'NO-REAS-REQ';
            ELSE
               l_decline_ofr_reason := NULL;
            END IF;


            /* Populate Admissions Offer Response import interface table,IGS_AD_OFFRESP_INT */
            INSERT INTO igs_ad_offresp_int
            ( offresp_int_id,
              batch_id,
              person_id,
              admission_appl_number,
              nominated_course_cd,
              sequence_number,
              adm_offer_resp_status,
              actual_offer_response_dt,
              attent_other_inst_cd,
              applicant_acptnce_cndtn,
              def_acad_cal_type,
              def_acad_ci_sequence_number,
              def_adm_cal_type,
              def_adm_ci_sequence_number,
              status,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              request_id,
              program_application_id,
              program_update_date,
              program_id,
              decline_ofr_reason)
            VALUES
            ( igs_ad_offresp_int_s.NEXTVAL,
              l_batch_id,
              cur_oss_appl_inst_rec.person_id,
              cur_oss_appl_inst_rec.admission_appl_number,
              cur_oss_appl_inst_rec.nominated_course_cd,
              cur_oss_appl_inst_rec.sequence_number,
              cur_map_offr_resp_rec.adm_offer_resp_status,
              NULL, --ACTUAL_OFFER_RESPONSE_DT
              NULL, --ATTENT_OTHER_INST_CD
              NULL, --APPLICANT_ACPTNCE_CNDTN
              NULL, --DEF_ACAD_CAL_TYPE
              NULL, --DEF_ACAD_CI_SEQUENCE_NUMBER
              NULL, --DEF_ADM_CAL_TYPE
              NULL, --DEF_ADM_CI_SEQUENCE_NUMBER
              '2',  --Pending Status ( Unprocessed Record)
              l_last_updated_by,
              SYSDATE,
              l_last_updated_by,
              SYSDATE,
              l_last_update_login,
              fnd_global.conc_request_id,
              fnd_global.prog_appl_id,
              SYSDATE,
              fnd_global.conc_program_id,
              l_decline_ofr_reason);

             --  Update the Application Choice record with the export_to_OSS_Status="RP"
             l_export_to_oss := 'RP' ;
             l_app_choice_error_code := NULL ;
             l_ch_batch_id := NULL ;
             l_exp_reply_flag := TRUE ;

           ELSE /* If there is no difference between the Application Instance Offer Response Status
             and  the mapped Application Choice reply, then import of reply is not required */
            /* Update the Application Choice Record with export to OSS status 'COMP' */
               l_export_to_oss := 'COMP' ;
               l_app_choice_error_code := NULL ;
               l_ch_batch_id := NULL ;
               -- Write the error message to the Log file indicating the error occurred
               fnd_message.set_name('IGS','IGS_UC_EXP_APP_COMPLETED');
               fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
               fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
               fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
           END IF;

      END IF; /* End of checking OSS Application Instnace system Offer Response status */

     END IF; /* End of OSS user Offer Response mapped to the UCAS system decision and reply */

       ELSE /*  UCAS reply is NULL, so not required to export to OSS  */
            /* Update the Application Choice Record with export to OSS status 'COMP' */
         l_export_to_oss := 'COMP' ;
         l_app_choice_error_code := NULL ;
         l_ch_batch_id := NULL ;
         -- Write the error message to the Log file indicating the error occurred
         fnd_message.set_name('IGS','IGS_UC_EXP_APP_COMPLETED');
         fnd_message.set_token('APP_NO',TO_CHAR(cur_ucas_app_choice_rec.app_no));
         fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_ucas_app_choice_rec.choice_no));
         fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

       END IF; /* End of UCAS reply exported to OSS */

       --jchin - bug 3691277 and 3691250
       END IF;  /* End If for cur_unit_set_cd%NOTFOUND */
       CLOSE cur_unit_set_cd;

     END IF ; /* End of OSS Application Instance processinng */
     CLOSE cur_oss_appl_inst;

     /*  update the Application choice with the error code ,batch_id and export_to_oss_status*/
     igs_uc_app_choices_pkg.update_row
           ( x_rowid                      => cur_ucas_app_choice_rec.ROWID
            ,x_app_choice_id              => cur_ucas_app_choice_rec.app_choice_id
            ,x_app_id                     => cur_ucas_app_choice_rec.app_id
            ,x_app_no                     => cur_ucas_app_choice_rec.app_no
            ,x_choice_no                  => cur_ucas_app_choice_rec.choice_no
            ,x_last_change                => cur_ucas_app_choice_rec.last_change
            ,x_institute_code             => cur_ucas_app_choice_rec.institute_code
            ,x_ucas_program_code          => cur_ucas_app_choice_rec.ucas_program_code
            ,x_oss_program_code           => cur_ucas_app_choice_rec.oss_program_code
            ,x_oss_program_version        => cur_ucas_app_choice_rec.oss_program_version
            ,x_oss_attendance_type        => cur_ucas_app_choice_rec.oss_attendance_type
            ,x_oss_attendance_mode        => cur_ucas_app_choice_rec.oss_attendance_mode
            ,x_campus                     => cur_ucas_app_choice_rec.campus
            ,x_oss_location               => cur_ucas_app_choice_rec.oss_location
            ,x_faculty                    => cur_ucas_app_choice_rec.faculty
            ,x_entry_year                 => cur_ucas_app_choice_rec.entry_year
            ,x_entry_month                => cur_ucas_app_choice_rec.entry_month
            ,x_point_of_entry             => cur_ucas_app_choice_rec.point_of_entry
            ,x_home                       => cur_ucas_app_choice_rec.home
            ,x_deferred                   => cur_ucas_app_choice_rec.deferred
            ,x_route_b_pref_round         => cur_ucas_app_choice_rec.route_b_pref_round
            ,x_route_b_actual_round       => cur_ucas_app_choice_rec.route_b_actual_round
            ,x_condition_category         => cur_ucas_app_choice_rec.condition_category
            ,x_condition_code             => cur_ucas_app_choice_rec.condition_code
            ,x_decision                   => cur_ucas_app_choice_rec.decision
            ,x_decision_date              => cur_ucas_app_choice_rec.decision_date
            ,x_decision_number            => cur_ucas_app_choice_rec.decision_number
            ,x_reply                      => cur_ucas_app_choice_rec.reply
            ,x_summary_of_cond            => cur_ucas_app_choice_rec.summary_of_cond
            ,x_choice_cancelled           => cur_ucas_app_choice_rec.choice_cancelled
            ,x_action                     => cur_ucas_app_choice_rec.action
            ,x_substitution               => cur_ucas_app_choice_rec.substitution
            ,x_date_substituted           => cur_ucas_app_choice_rec.date_substituted
            ,x_prev_institution           => cur_ucas_app_choice_rec.prev_institution
            ,x_prev_course                => cur_ucas_app_choice_rec.prev_course
            ,x_prev_campus                => cur_ucas_app_choice_rec.prev_campus
            ,x_ucas_amendment             => cur_ucas_app_choice_rec.ucas_amendment
            ,x_withdrawal_reason          => cur_ucas_app_choice_rec.withdrawal_reason
            ,x_offer_course               => cur_ucas_app_choice_rec.offer_course
            ,x_offer_campus               => cur_ucas_app_choice_rec.offer_campus
            ,x_offer_crse_length          => cur_ucas_app_choice_rec.offer_crse_length
            ,x_offer_entry_month          => cur_ucas_app_choice_rec.offer_entry_month
            ,x_offer_entry_year           => cur_ucas_app_choice_rec.offer_entry_year
            ,x_offer_entry_point          => cur_ucas_app_choice_rec.offer_entry_point
            ,x_offer_text                 => cur_ucas_app_choice_rec.offer_text
            ,x_export_to_oss_status       => l_export_to_oss
            ,x_error_code                 => l_app_choice_error_code
            ,x_request_id                 => l_conc_request_id
            ,x_batch_id                   => l_ch_batch_id
            ,x_mode                       => 'R'
            ,x_extra_round_nbr            => cur_ucas_app_choice_rec.extra_round_nbr
            ,x_system_code                => cur_ucas_app_choice_rec.system_code
            ,x_part_time                  => cur_ucas_app_choice_rec.part_time
            ,x_interview                  => cur_ucas_app_choice_rec.interview
            ,x_late_application           => cur_ucas_app_choice_rec.late_application
            ,x_modular                    => cur_ucas_app_choice_rec.modular
            ,x_residential                => cur_ucas_app_choice_rec.residential
            ,x_ucas_cycle                 => cur_ucas_app_choice_rec.ucas_cycle
      );

  END LOOP; /* End of Processing all the Application Choices */

        /**********    End of  Processing all the Application Choices   ********/

  /* If there are any Application choice records with export_to_oss_status is 'RP'
     Then submit the request for 'Admissions Offer Response Import Process' */
  IF l_exp_reply_flag  THEN

    -- Display the information message in the log file
    fnd_message.set_name('IGS','IGS_UC_OFFRESP_IMP_PROC_LAUNCH');
    fnd_message.set_token('REQ_ID',TO_CHAR(l_batch_id));
    fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

    -- Invoke the Admission Import Offer Response Process
    BEGIN

      igs_ad_imp_off_resp_data.imp_off_resp(
        errbuf        => l_errbuf,
        retcode       => l_retcode,
        p_batch_id    => l_batch_id,
        p_yes_no      => '1' ) ;
    EXCEPTION
      WHEN OTHERS THEN
        -- If any of the exception are reported in the offer response import process,
        -- app choice records will be updated below, so need to handle it here
        NULL ;
    END ;

  END IF;
          /******  Admissions Offer Response Import  Process Completed  ************/

  /* Loop through all the Application Choice records according to passesd parameters
     criteria with export to OSS status is 'RP' */
  FOR cur_rp_app_choice_rec IN cur_rp_app_choice  LOOP

    -- Get the OSS Admission application instance for this ucas application choice
    OPEN cur_oss_appl_inst( cur_rp_app_choice_rec.app_no,
                            cur_rp_app_choice_rec.choice_no,
                            cur_rp_app_choice_rec.ucas_cycle );
    FETCH cur_oss_appl_inst INTO cur_oss_appl_inst_rec;

    --jchin - bug 3691277 and 3691250
    IF cur_oss_appl_inst%FOUND THEN
      /* OSS Application Instance Found */
      --check whether the matching unit-set-code exists for the identofi application instance
      OPEN cur_unit_set_cd(cur_oss_appl_inst_rec.unit_set_cd,
                           cur_oss_appl_inst_rec.us_version_number,
                           cur_oss_appl_inst_rec.nominated_course_cd,
                           cur_oss_appl_inst_rec.crv_version_number,
                           cur_oss_appl_inst_rec.acad_cal_type,
                           cur_oss_appl_inst_rec.location_cd,
                           cur_oss_appl_inst_rec.attendance_mode,
                           cur_oss_appl_inst_rec.attendance_type,
                           cur_oss_appl_inst_rec.point_of_entry);
      FETCH cur_unit_set_cd INTO cur_unit_set_cd_rec;

      IF cur_unit_set_cd%FOUND THEN
        /* OSS Application Instance and unit-set-code found */
        --Continue processing

    OPEN cur_reply_import_error ( cur_oss_appl_inst_rec.person_id,
                                  cur_oss_appl_inst_rec.admission_appl_number,
                                  cur_oss_appl_inst_rec.nominated_course_cd,
                                  cur_oss_appl_inst_rec.sequence_number );
    FETCH cur_reply_import_error INTO cur_reply_import_error_rec;

    -- If there are any errors in Offer Response import,
    -- update the Application Choice Record with error code 'ROO1'
    IF cur_reply_import_error%FOUND  THEN
      -- log message in log file
      fnd_message.set_name('IGS','IGS_UC_OFFRESP_IMP_ERR');
      fnd_message.set_token('APP_NO',TO_CHAR(cur_rp_app_choice_rec.app_no));
      fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_rp_app_choice_rec.choice_no));
      fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

      -- If the error was generated during the current run, then update the record with error code
      IF cur_rp_app_choice_rec.batch_id IS NULL THEN
         l_export_to_oss :=  cur_rp_app_choice_rec.export_to_oss_status ;
         l_app_choice_error_code := 'ROO1' ;
         l_ch_batch_id := l_batch_id ;
      ELSE
         l_export_to_oss :=  cur_rp_app_choice_rec.export_to_oss_status ;
         l_app_choice_error_code := cur_rp_app_choice_rec.error_code ;
         l_ch_batch_id := cur_rp_app_choice_rec.batch_id ;
      END IF ;
    ELSE
       -- Update the Application Choice with export to OSS status as 'COMP', Concurrent Request ID
       -- and clear the error code and batch ID
       l_export_to_oss := 'COMP' ;
       l_app_choice_error_code := NULL ;
       l_ch_batch_id := NULL ;
       -- Write the error message to the Log file indicating the error occurred
       fnd_message.set_name('IGS','IGS_UC_EXP_APP_COMPLETED');
       fnd_message.set_token('APP_NO',TO_CHAR(cur_rp_app_choice_rec.app_no));
       fnd_message.set_token('CHOICE_NO',TO_CHAR(cur_rp_app_choice_rec.choice_no));
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
    END IF;
    CLOSE cur_reply_import_error;
      -- jchin - bug 3691277 and 3691250
      END IF; /* End If for cur_unit_set_cd%FOUND */
      CLOSE cur_unit_set_cd;

    END IF ; /* End If for cur_oss_appl_inst%FOUND */
    CLOSE cur_oss_appl_inst;

    -- Update the Application Choice with export to OSS status , Concurrent Request ID
    igs_uc_app_choices_pkg.update_row
         ( x_rowid                      => cur_rp_app_choice_rec.ROWID
          ,x_app_choice_id              => cur_rp_app_choice_rec.app_choice_id
          ,x_app_id                     => cur_rp_app_choice_rec.app_id
          ,x_app_no                     => cur_rp_app_choice_rec.app_no
          ,x_choice_no                  => cur_rp_app_choice_rec.choice_no
          ,x_last_change                => cur_rp_app_choice_rec.last_change
          ,x_institute_code             => cur_rp_app_choice_rec.institute_code
          ,x_ucas_program_code          => cur_rp_app_choice_rec.ucas_program_code
          ,x_oss_program_code           => cur_rp_app_choice_rec.oss_program_code
          ,x_oss_program_version        => cur_rp_app_choice_rec.oss_program_version
          ,x_oss_attendance_type        => cur_rp_app_choice_rec.oss_attendance_type
          ,x_oss_attendance_mode        => cur_rp_app_choice_rec.oss_attendance_mode
          ,x_campus                     => cur_rp_app_choice_rec.campus
          ,x_oss_location               => cur_rp_app_choice_rec.oss_location
          ,x_faculty                    => cur_rp_app_choice_rec.faculty
          ,x_entry_year                 => cur_rp_app_choice_rec.entry_year
          ,x_entry_month                => cur_rp_app_choice_rec.entry_month
          ,x_point_of_entry             => cur_rp_app_choice_rec.point_of_entry
          ,x_home                       => cur_rp_app_choice_rec.home
          ,x_deferred                   => cur_rp_app_choice_rec.deferred
          ,x_route_b_pref_round         => cur_rp_app_choice_rec.route_b_pref_round
          ,x_route_b_actual_round       => cur_rp_app_choice_rec.route_b_actual_round
          ,x_condition_category         => cur_rp_app_choice_rec.condition_category
          ,x_condition_code             => cur_rp_app_choice_rec.condition_code
          ,x_decision                   => cur_rp_app_choice_rec.decision
          ,x_decision_date              => cur_rp_app_choice_rec.decision_date
          ,x_decision_number            => cur_rp_app_choice_rec.decision_number
          ,x_reply                      => cur_rp_app_choice_rec.reply
          ,x_summary_of_cond            => cur_rp_app_choice_rec.summary_of_cond
          ,x_choice_cancelled           => cur_rp_app_choice_rec.choice_cancelled
          ,x_action                     => cur_rp_app_choice_rec.action
          ,x_substitution               => cur_rp_app_choice_rec.substitution
          ,x_date_substituted           => cur_rp_app_choice_rec.date_substituted
          ,x_prev_institution           => cur_rp_app_choice_rec.prev_institution
          ,x_prev_course                => cur_rp_app_choice_rec.prev_course
          ,x_prev_campus                => cur_rp_app_choice_rec.prev_campus
          ,x_ucas_amendment             => cur_rp_app_choice_rec.ucas_amendment
          ,x_withdrawal_reason          => cur_rp_app_choice_rec.withdrawal_reason
          ,x_offer_course               => cur_rp_app_choice_rec.offer_course
          ,x_offer_campus               => cur_rp_app_choice_rec.offer_campus
          ,x_offer_crse_length          => cur_rp_app_choice_rec.offer_crse_length
          ,x_offer_entry_month          => cur_rp_app_choice_rec.offer_entry_month
          ,x_offer_entry_year           => cur_rp_app_choice_rec.offer_entry_year
          ,x_offer_entry_point          => cur_rp_app_choice_rec.offer_entry_point
          ,x_offer_text                 => cur_rp_app_choice_rec.offer_text
          ,x_export_to_oss_status       => l_export_to_oss
          ,x_error_code                 => l_app_choice_error_code
          ,x_request_id                 => l_conc_request_id
          ,x_batch_id                   => l_ch_batch_id
          ,x_mode                       => 'R'
          ,x_extra_round_nbr            => cur_rp_app_choice_rec.extra_round_nbr
          ,x_system_code                => cur_rp_app_choice_rec.system_code
          ,x_part_time                  => cur_rp_app_choice_rec.part_time
          ,x_interview                  => cur_rp_app_choice_rec.interview
          ,x_late_application           => cur_rp_app_choice_rec.late_application
          ,x_modular                    => cur_rp_app_choice_rec.modular
          ,x_residential                => cur_rp_app_choice_rec.residential
          ,x_ucas_cycle                 => cur_rp_app_choice_rec.ucas_cycle
    );

  END LOOP ;
        /******* End of processing the Offer Response exported Application Choices ********/

  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_EXPORT_DECISION_REPLY.EXPORT_REPLY'||' - '||SQLERRM);
      igs_ge_msg_stack.add;
      App_Exception.Raise_Exception;

  END export_reply ;

END igs_uc_export_decision_reply ;

/
