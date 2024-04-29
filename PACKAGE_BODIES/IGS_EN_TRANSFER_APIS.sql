--------------------------------------------------------
--  DDL for Package Body IGS_EN_TRANSFER_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_TRANSFER_APIS" AS
/* $Header: IGSEN82B.pls 120.18 2006/09/15 09:00:19 bdeviset noship $ */
/*-------------------------------------------------------------------------------------------
   Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC

  --Change History:
  --Who         When            What
  --ckasu     20-Nov-2004       modifed cleanup_job by changing order of parameters passed.
  --ckasu     02-DEC-2004       created as a part of Bug #4044329
  --bdeviset  02-DEC-2004       Bug# 4044319.Modified validate_src_prgm_unt_attempts.
  --stutta    10-DEC-2004       Bug#4046782. Removed procedure chk_set_prm_prg_for_src_career
  --ckasu     11-Dec-2004      modified file as a part of bug# 4061818,4061914
  --ckasu     20-Dec-2004      modified file as a part of bug# 4063726
  --bdeviset  22-Dec-2004      Modifed program_transfer_api  as part Bug#4083015.
  --smaddali  21-dec-04        Modified procedure validate_src_prgm_unt_attempts for bug#4083358
  --amuthu    23-DEC-2004      Modified the program_transfer_api, to add two validation in career mode
  -- smaddali 5-jan-2005       Modified procedure program_transfer_api for bug#4103437
  -- ckasu    07-JAN-2005      Modified code inorder to include person holds and person step
  --                           validations as a part of bug# 4083552
  -- bdeviset 21-Mar-2005      Modified update_destination_program procedure for Bug# 4248338, 4248367
  -- sgurusam 17-Jun-2005      Modified validate_person_steps procedure for EN317FD
  -- bdeviset 20-OCT-2005      Modified validate_src_prgm_unt_attempts procedure for bug# 4691498
  -- stutta   26-Nov-2005      Created procedure val_unchk_sub_units and added call. Bug #4763202
  -- ckasu    08-DEC-2005     passed SYSDATE for update_source instead of p_actual_date param
  --                           as part of bug#4869869
  -- ckasu    17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL) in CLEANUP_JOB procedure
  --                          as a part of bug#4958173
  -- ckasu     06-MAR-2006     added new cursor c_get_enr_method_type as a part of bug#5070732 in
  --                           validate_prgm_attend_type_step Procedure

  -------------------------------------------------------------------------------------------*/


   g_pkg_name    CONSTANT VARCHAR2(30) := 'IGS_EN_TRANSFER_APIS';
   g_debug_level CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_transfer_dt  DATE;
  FUNCTION is_career_model_enabled RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : returns True when Career model  is  enabled  else False.
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------
  BEGIN

    IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') =  'Y' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  END is_career_model_enabled;

  PROCEDURE parse_messages( p_message_names IN VARCHAR2) AS

    l_strtpoint_msg NUMBER;
    l_endpoint_msg  NUMBER;
    l_cindex_msg    NUMBER;
    l_pre_cindex_msg NUMBER;
    l_nth_occurence_msg NUMBER;
    l_messages_str  VARCHAR2(2000);
    l_message_name  VARCHAR2(100);
    l_messg_and_unitcd_sep NUMBER;
    l_unit_cd       VARCHAR2(100);

  BEGIN

    l_strtpoint_msg      :=  0;
    l_pre_cindex_msg     :=  0;
    l_nth_occurence_msg  :=  1;
    l_messages_str := p_message_names||';';
    l_cindex_msg := INSTR(l_messages_str,';',1,l_nth_occurence_msg);

    WHILE (l_cindex_msg <> 0 )  LOOP

        l_strtpoint_msg  :=  l_pre_cindex_msg + 1;
        l_endpoint_msg   :=  l_cindex_msg - l_strtpoint_msg;
        l_pre_cindex_msg :=  l_cindex_msg;
        l_message_name := substr(l_messages_str,l_strtpoint_msg,l_endpoint_msg);
        l_messg_and_unitcd_sep := INSTR(l_message_name,'*',1,1);

        IF l_messg_and_unitcd_sep <> 0 THEN
           l_unit_cd      := substr(l_message_name,l_messg_and_unitcd_sep + 1,(l_cindex_msg-l_messg_and_unitcd_sep-1));
               l_message_name := substr(l_message_name,1,l_messg_and_unitcd_sep - 1);
               FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
               FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_cd);
           FND_MSG_PUB.ADD;
        ELSE
           FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
           FND_MSG_PUB.ADD;
        END IF;

        l_nth_occurence_msg := l_nth_occurence_msg + 1;
        l_cindex_msg := INSTR(l_messages_str,';',1,l_nth_occurence_msg);

    END LOOP; -- end of l_cindex_msg <> 0  LOOP

  END parse_messages;

  PROCEDURE is_destn_prgm_att_discon(
      p_person_id               IN   NUMBER,
      p_dest_program_cd         IN   VARCHAR2,
      p_dest_prog_ver           IN   NUMBER,
      p_status                  OUT  NOCOPY BOOLEAN
  ) AS

  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : Returns True when destination Program attempt is discontinued else False
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

    l_val  VARCHAR2(10);
    CURSOR c_get_prgm_att_status IS
       Select 'Y'
       From   IGS_EN_STDNT_PS_ATT_ALL
       Where  person_id = p_person_id and
              course_cd =  p_dest_program_cd and
              version_number =  p_dest_prog_ver and
              course_attempt_status  = 'DISCONTIN';

    BEGIN
     OPEN c_get_prgm_att_status;
     FETCH c_get_prgm_att_status  INTO l_val;
     IF (c_get_prgm_att_status%FOUND) THEN
       CLOSE c_get_prgm_att_status;
       p_status := TRUE;
     ELSE
       CLOSE c_get_prgm_att_status;
       p_status := FALSE;
     END IF;

  END is_destn_prgm_att_discon;


  PROCEDURE update_destination_prgm(
    p_person_id              IN   NUMBER,
    p_src_course_cd          IN   VARCHAR2,
    p_course_cd              IN   VARCHAR2,
    p_new_dest_key_flag      IN OUT NOCOPY  VARCHAR2,
    p_stdnt_confrm_ind       IN   VARCHAR2,
    p_dest_fut_dt_trans_flag IN   VARCHAR2,
    p_dest_commence_dt       IN   DATE,
    p_tran_across_careers    IN   BOOLEAN,
    p_term_cal_type           IN   VARCHAR2,
    p_term_seq_num            IN   NUMBER
  ) AS
  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : This Procedure is used to update the destination program  during transfer
  --Change History:
  --Who         When            What
  --stutta    10-DEC-2004   Removed setting/unsetting of global. It is set in program_trasfer
  --                        _api, before the call to this procedure. Calculating the program
  --                        attempt status and sending it in all ps_att update row call. Bug #4046782
 -- bdeviset 21-Mar-2005    Modified update_destination_program procedure for Bug# 4248338, 4248367.
 --                         As start date is disabled in transfer page assinging the dest program
 --                         comm dt to src program comm dt so that the user encounters no errors
 --                         while transferring units from src to dest.
 -- stutta  26-Sep-2005     Added call to create_update_term_rec for bug 4588264
  --------------------------------------------------------------------------------------------
    CURSOR c_get_stdnt_ps_att_dtls IS
       SELECT *
       FROM IGS_EN_STDNT_PS_ATT
       WHERE person_id = p_person_id AND
             course_cd = p_course_cd;

    CURSOR c_get_discont_reason IS
       SELECT discontinuation_reason_cd
       FROM IGS_EN_DCNT_REASONCD
       WHERE  dcnt_program_ind = 'Y' AND
              closed_ind   = 'N'     AND
                  sys_dflt_ind = 'Y'     AND
              s_discontinuation_reason_type = 'TRANSFER';

    CURSOR c_get_comm_dt_of_src_prg IS
       SELECT commencement_dt
       FROM IGS_EN_STDNT_PS_ATT
       WHERE person_id = p_person_id AND
            course_cd = p_src_course_cd;

    l_src_commence_dt           IGS_EN_STDNT_PS_ATT.COMMENCEMENT_DT%TYPE;
    l_course_attempt_status  IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
    l_discont_reason_code         IGS_EN_DCNT_REASONCD.discontinuation_reason_cd%TYPE;
    l_stdnt_ps_attempt_dtls_rec  c_get_stdnt_ps_att_dtls%ROWTYPE;
	l_key_program_flag      igs_en_spa_terms.key_program_flag%TYPE := FND_API.G_MISS_CHAR;
	l_message_name VARCHAR2(2000);
  BEGIN
    OPEN  c_get_stdnt_ps_att_dtls;
    FETCH c_get_stdnt_ps_att_dtls INTO l_stdnt_ps_attempt_dtls_rec;
    IF (c_get_stdnt_ps_att_dtls%FOUND) THEN
        IF (p_new_dest_key_flag <> l_stdnt_ps_attempt_dtls_rec.key_program AND p_new_dest_key_flag = 'Y') THEN
					l_key_program_flag := p_new_dest_key_flag;
	    END IF;
        IF p_dest_fut_dt_trans_flag = 'S'   THEN
           -- if it is an immediate transfer then make the dest as primary and key if source is key
           -- else if source is non key p_new_dest_key_flag contains the old value of destination program
           l_stdnt_ps_attempt_dtls_rec.key_program := p_new_dest_key_flag;
           IF is_career_model_enabled THEN
                l_stdnt_ps_attempt_dtls_rec.primary_program_type := 'PRIMARY';
           END IF;
        ELSIF (p_stdnt_confrm_ind = 'Y' AND l_stdnt_ps_attempt_dtls_rec.student_confirmed_ind = 'N' AND is_career_model_enabled) THEN
       -- this is to avoid a null value for primary program type when a unconfirmed program attempt
       -- is the destination program in future dated transfer
               l_stdnt_ps_attempt_dtls_rec.primary_program_type := 'SECONDARY';
        END IF;

        IF p_stdnt_confrm_ind = 'Y' AND l_stdnt_ps_attempt_dtls_rec.commencement_dt IS NULL THEN
           OPEN c_get_comm_dt_of_src_prg;
           FETCH c_get_comm_dt_of_src_prg INTO l_src_commence_dt;
           CLOSE c_get_comm_dt_of_src_prg;
           l_stdnt_ps_attempt_dtls_rec.commencement_dt := NVL(p_dest_commence_dt,l_src_commence_dt);
        END IF;

        l_stdnt_ps_attempt_dtls_rec.course_attempt_status :=
            igs_en_gen_006.Enrp_Get_Sca_Status(
                    p_person_id => l_stdnt_ps_attempt_dtls_rec.PERSON_ID,
                    p_course_cd =>  l_stdnt_ps_attempt_dtls_rec.COURSE_CD,
                    p_course_attempt_status => l_stdnt_ps_attempt_dtls_rec.course_attempt_status,
                    p_student_confirmed_ind => p_stdnt_confrm_ind,
                    p_discontinued_dt => NULL,
                    p_lapsed_dt => l_stdnt_ps_attempt_dtls_rec.LAPSED_DT,
                    p_course_rqrmnt_complete_ind => l_stdnt_ps_attempt_dtls_rec.COURSE_RQRMNT_COMPLETE_IND,
                    p_logical_delete_dt => l_stdnt_ps_attempt_dtls_rec.logical_delete_dt );
        igs_en_spa_terms_api.set_spa_term_cal_type(P_TERM_CAL_TYPE);
		igs_en_spa_terms_api.set_spa_term_sequence_number (p_term_seq_num);
        IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                      X_ROWID                               => l_stdnt_ps_attempt_dtls_rec.row_id,
                      X_PERSON_ID                           => l_stdnt_ps_attempt_dtls_rec.PERSON_ID,
                      X_COURSE_CD                           => l_stdnt_ps_attempt_dtls_rec.COURSE_CD,
                      X_ADVANCED_STANDING_IND               => l_stdnt_ps_attempt_dtls_rec.ADVANCED_STANDING_IND,
                      X_FEE_CAT                             => l_stdnt_ps_attempt_dtls_rec.fee_cat,
                      X_CORRESPONDENCE_CAT                  => l_stdnt_ps_attempt_dtls_rec.correspondence_cat,
                      X_SELF_HELP_GROUP_IND                 => l_stdnt_ps_attempt_dtls_rec.SELF_HELP_GROUP_IND,
                      X_LOGICAL_DELETE_DT                   => l_stdnt_ps_attempt_dtls_rec.logical_delete_dt,
                      X_ADM_ADMISSION_APPL_NUMBER           => l_stdnt_ps_attempt_dtls_rec.adm_admission_appl_number,
                      X_ADM_NOMINATED_COURSE_CD             => l_stdnt_ps_attempt_dtls_rec.adm_nominated_course_cd,
                      X_ADM_SEQUENCE_NUMBER                 => l_stdnt_ps_attempt_dtls_rec.adm_sequence_number,
                      X_VERSION_NUMBER                      => l_stdnt_ps_attempt_dtls_rec.version_number,
                      X_CAL_TYPE                            => l_stdnt_ps_attempt_dtls_rec.cal_type,
                      X_LOCATION_CD                         => l_stdnt_ps_attempt_dtls_rec.location_cd,
                      X_ATTENDANCE_MODE                     => l_stdnt_ps_attempt_dtls_rec.attendance_mode,
                      X_ATTENDANCE_TYPE                     => l_stdnt_ps_attempt_dtls_rec.attendance_type,
                      X_COO_ID                              => l_stdnt_ps_attempt_dtls_rec.coo_id,
                      X_STUDENT_CONFIRMED_IND               => p_stdnt_confrm_ind,
                      X_COMMENCEMENT_DT                     =>  l_stdnt_ps_attempt_dtls_rec.commencement_dt,
                      X_COURSE_ATTEMPT_STATUS               => l_stdnt_ps_attempt_dtls_rec.course_attempt_status,
                      X_PROGRESSION_STATUS                  => l_stdnt_ps_attempt_dtls_rec.PROGRESSION_STATUS,
                      X_DERIVED_ATT_TYPE                    => l_stdnt_ps_attempt_dtls_rec.DERIVED_ATT_TYPE,
                      X_DERIVED_ATT_MODE                    => l_stdnt_ps_attempt_dtls_rec.DERIVED_ATT_MODE,
                      X_PROVISIONAL_IND                     => l_stdnt_ps_attempt_dtls_rec.provisional_ind,
                      X_DISCONTINUED_DT                     => NULL,
                      X_DISCONTINUATION_REASON_CD           => NULL,
                      X_LAPSED_DT                           => l_stdnt_ps_attempt_dtls_rec.LAPSED_DT,
                      X_FUNDING_SOURCE                      => l_stdnt_ps_attempt_dtls_rec.funding_source,
                      X_EXAM_LOCATION_CD                    => l_stdnt_ps_attempt_dtls_rec.EXAM_LOCATION_CD,
                      X_DERIVED_COMPLETION_YR               => l_stdnt_ps_attempt_dtls_rec.DERIVED_COMPLETION_YR,
                      X_DERIVED_COMPLETION_PERD             => l_stdnt_ps_attempt_dtls_rec.DERIVED_COMPLETION_PERD,
                      X_NOMINATED_COMPLETION_YR             => l_stdnt_ps_attempt_dtls_rec.nominated_completion_yr,
                      X_NOMINATED_COMPLETION_PERD           => l_stdnt_ps_attempt_dtls_rec.NOMINATED_COMPLETION_PERD,
                      X_RULE_CHECK_IND                      => l_stdnt_ps_attempt_dtls_rec.RULE_CHECK_IND,
                      X_WAIVE_OPTION_CHECK_IND              => l_stdnt_ps_attempt_dtls_rec.WAIVE_OPTION_CHECK_IND,
                      X_LAST_RULE_CHECK_DT                  => l_stdnt_ps_attempt_dtls_rec.LAST_RULE_CHECK_DT,
                      X_PUBLISH_OUTCOMES_IND                => l_stdnt_ps_attempt_dtls_rec.PUBLISH_OUTCOMES_IND,
                      X_COURSE_RQRMNT_COMPLETE_IND          => l_stdnt_ps_attempt_dtls_rec.COURSE_RQRMNT_COMPLETE_IND,
                      X_COURSE_RQRMNTS_COMPLETE_DT          => l_stdnt_ps_attempt_dtls_rec.COURSE_RQRMNTS_COMPLETE_DT,
                      X_S_COMPLETED_SOURCE_TYPE             => l_stdnt_ps_attempt_dtls_rec.S_COMPLETED_SOURCE_TYPE,
                      X_OVERRIDE_TIME_LIMITATION            => l_stdnt_ps_attempt_dtls_rec.OVERRIDE_TIME_LIMITATION,
                      x_last_date_of_attendance             => l_stdnt_ps_attempt_dtls_rec.last_date_of_attendance,
                      x_dropped_by                          => l_stdnt_ps_attempt_dtls_rec.dropped_by,
                      X_IGS_PR_CLASS_STD_ID                 => l_stdnt_ps_attempt_dtls_rec.igs_pr_class_std_id,
                      x_primary_program_type                => l_stdnt_ps_attempt_dtls_rec.primary_program_type,
                      x_primary_prog_type_source            => l_stdnt_ps_attempt_dtls_rec.primary_prog_type_source,
                      x_catalog_cal_type                    => l_stdnt_ps_attempt_dtls_rec.catalog_cal_type,
                      x_catalog_seq_num                     => l_stdnt_ps_attempt_dtls_rec.catalog_seq_num,
                      x_key_program                         => l_stdnt_ps_attempt_dtls_rec.key_program,
                      x_override_cmpl_dt                    => l_stdnt_ps_attempt_dtls_rec.override_cmpl_dt,
                      x_manual_ovr_cmpl_dt_ind              => l_stdnt_ps_attempt_dtls_rec.manual_ovr_cmpl_dt_ind,
                      X_MODE                                =>  'R',
                      X_ATTRIBUTE_CATEGORY                  => l_stdnt_ps_attempt_dtls_rec.attribute_category,
                      X_ATTRIBUTE1                          => l_stdnt_ps_attempt_dtls_rec.attribute1,
                      X_ATTRIBUTE2                          => l_stdnt_ps_attempt_dtls_rec.attribute2,
                      X_ATTRIBUTE3                          => l_stdnt_ps_attempt_dtls_rec.attribute3,
                      X_ATTRIBUTE4                          => l_stdnt_ps_attempt_dtls_rec.attribute4,
                      X_ATTRIBUTE5                          => l_stdnt_ps_attempt_dtls_rec.attribute5,
                      X_ATTRIBUTE6                          => l_stdnt_ps_attempt_dtls_rec.attribute6,
                      X_ATTRIBUTE7                          => l_stdnt_ps_attempt_dtls_rec.attribute7,
                      X_ATTRIBUTE8                          => l_stdnt_ps_attempt_dtls_rec.attribute8,
                      X_ATTRIBUTE9                          => l_stdnt_ps_attempt_dtls_rec.attribute9,
                      X_ATTRIBUTE10                         => l_stdnt_ps_attempt_dtls_rec.attribute10,
                      X_ATTRIBUTE11                         => l_stdnt_ps_attempt_dtls_rec.attribute11,
                      X_ATTRIBUTE12                         => l_stdnt_ps_attempt_dtls_rec.attribute12,
                      X_ATTRIBUTE13                         => l_stdnt_ps_attempt_dtls_rec.attribute13,
                      X_ATTRIBUTE14                         => l_stdnt_ps_attempt_dtls_rec.attribute14,
                      X_ATTRIBUTE15                         => l_stdnt_ps_attempt_dtls_rec.attribute15,
                      X_ATTRIBUTE16                         => l_stdnt_ps_attempt_dtls_rec.attribute16,
                      X_ATTRIBUTE17                         => l_stdnt_ps_attempt_dtls_rec.attribute17,
                      X_ATTRIBUTE18                         => l_stdnt_ps_attempt_dtls_rec.attribute18,
                      X_ATTRIBUTE19                         => l_stdnt_ps_attempt_dtls_rec.attribute19,
                      X_ATTRIBUTE20                         => l_stdnt_ps_attempt_dtls_rec.attribute20,
                      X_FUTURE_DATED_TRANS_FLAG             => p_dest_fut_dt_trans_flag);
		      igs_en_spa_terms_api.set_spa_term_cal_type(NULL);
		      igs_en_spa_terms_api.set_spa_term_sequence_number (NULL);
                      IF p_dest_fut_dt_trans_flag = 'S'   THEN
                                igs_en_spa_terms_api.create_update_term_rec(p_person_id => l_stdnt_ps_attempt_dtls_rec.PERSON_ID,
                                                          p_program_cd => l_stdnt_ps_attempt_dtls_rec.COURSE_CD,
                                                          p_term_cal_type => P_TERM_CAL_TYPE,
                                                          p_term_sequence_number => p_term_seq_num,
                                                          p_key_program_flag => l_key_program_flag,
                                                          p_program_changed => TRUE,
                                                          p_ripple_frwrd => TRUE,
                                                          p_message_name => l_message_name,
                                                          p_update_rec => TRUE);
                     END IF;


        END IF; -- end of c_get_stdnt_ps_att_dtls%FOUND)

    CLOSE c_get_stdnt_ps_att_dtls;

    EXCEPTION

       WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
            --allow calls before dml and after dml to this package from igs_en_stdnt_ps_att_pkg to fire
            IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml :=  FALSE ;
            igs_en_spa_terms_api.set_spa_term_cal_type(NULL);
            igs_en_spa_terms_api.set_spa_term_sequence_number (NULL);
            RAISE;
       WHEN FND_API.G_EXC_ERROR THEN
            IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml :=  FALSE ;
	    igs_en_spa_terms_api.set_spa_term_cal_type(NULL);
	    igs_en_spa_terms_api.set_spa_term_sequence_number (NULL);

            RAISE;
       WHEN OTHERS THEN
            --allow calls before dml and after dml to this package from igs_en_stdnt_ps_att_pkg to fire
            IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml :=  FALSE ;
	    igs_en_spa_terms_api.set_spa_term_cal_type(NULL);
	    igs_en_spa_terms_api.set_spa_term_sequence_number (NULL);
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.update_destination_prgm');
            IGS_GE_MSG_STACK.ADD;
            IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.update_destination_prgm :',SQLERRM);
            END IF;
            App_Exception.Raise_Exception;

  END update_destination_prgm;


  PROCEDURE set_dest_prgm_att_params(
     p_person_id              IN   NUMBER,
     p_src_program_cd         IN   VARCHAR2,
     p_term_cal_type          IN   VARCHAR2,
     p_term_seq_num           IN   NUMBER,
     p_dest_primary_prg_type  IN OUT NOCOPY VARCHAR2,
     p_dest_key_prgm_flag     IN OUT NOCOPY VARCHAR2,
     p_dest_commence_dt       IN OUT NOCOPY DATE,
     p_dest_fut_dt_trans_flag IN OUT NOCOPY VARCHAR2,
     p_transfer_re            IN   VARCHAR2

    )AS
  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : This procedure is used to set the destination program attempt key program
  --           parameter and future dated transfer flag respectively.
  --Change History:
  --Who         When            What
  --somasekar   13-apr-2005     bug# 4179106 modified to set the future date
  --                                 transfer sucessful to 'S'
  -------------------------------------------------------------------------------------------

   /*  This function sets the Destination Program Key Program value, future date
       transfer flag and destination Primary program Type.
       In Career mode    destination Primary program Type = 'Y' and key program = Y
       when source key program = 'Y' else set destination program  key program = Y

   */

    l_begin_trans_dt_alias      IGS_EN_CAL_CONF.BEGIN_TRANS_DT_ALIAS%TYPE;
    l_begin_trans_dt_alias_val  DATE;
    l_src_key_prgm              IGS_EN_STDNT_PS_ATT.KEY_PROGRAM%TYPE;
    l_src_commence_dt           IGS_EN_STDNT_PS_ATT.COMMENCEMENT_DT%TYPE;
    CURSOR c_get_key_val_frm_src_prg IS
       SELECT key_program,commencement_dt
       FROM IGS_EN_STDNT_PS_ATT
       WHERE person_id = p_person_id AND
            course_cd = p_src_program_cd;
    CURSOR c_get_begin_trans_dt_alias IS
       SELECT begin_trans_dt_alias
       FROM IGS_EN_CAL_CONF
       WHERE s_control_num = 1;
    CURSOR c_get_begin_trans_dt_alias_val(c_begin_dt_alias IGS_EN_CAL_CONF.BEGIN_TRANS_DT_ALIAS%TYPE) IS
       SELECT ALIAS_VAL
       FROM IGS_CA_DA_INST_V
       WHERE dt_alias =  c_begin_dt_alias AND
            cal_type = p_term_cal_type AND
            ci_sequence_number = p_term_seq_num;


  BEGIN

    IF (is_career_model_enabled) THEN
        p_dest_primary_prg_type := 'PRIMARY';
    END IF;
    OPEN c_get_key_val_frm_src_prg;
    FETCH c_get_key_val_frm_src_prg INTO l_src_key_prgm,l_src_commence_dt;
    CLOSE c_get_key_val_frm_src_prg;

    IF l_src_key_prgm = 'Y' THEN
          p_dest_key_prgm_flag := 'Y';
    END IF;

    IF p_transfer_re = 'Y' THEN
       IF p_dest_commence_dt <> l_src_commence_dt  THEN
          p_dest_commence_dt := l_src_commence_dt;
       END IF;
    END IF;-- end of p_transfer_re = Y IF THEN

    OPEN c_get_begin_trans_dt_alias;
    FETCH c_get_begin_trans_dt_alias INTO l_begin_trans_dt_alias;
    IF c_get_begin_trans_dt_alias%FOUND AND  l_begin_trans_dt_alias IS NOT NULL  THEN
       CLOSE c_get_begin_trans_dt_alias;
       OPEN c_get_begin_trans_dt_alias_val(l_begin_trans_dt_alias);
       FETCH c_get_begin_trans_dt_alias_val INTO l_begin_trans_dt_alias_val;
       CLOSE c_get_begin_trans_dt_alias_val;
       IF l_begin_trans_dt_alias_val > TRUNC(SYSDATE) THEN
          p_dest_fut_dt_trans_flag := 'Y';
       ELSIF l_begin_trans_dt_alias_val <= TRUNC(SYSDATE) THEN
             p_dest_fut_dt_trans_flag := 'S';
       ELSIF l_begin_trans_dt_alias_val IS NULL THEN
             p_dest_fut_dt_trans_flag := 'S';
       END IF;
       RETURN;
    ELSE
      CLOSE c_get_begin_trans_dt_alias;
      p_dest_fut_dt_trans_flag := 'S';
      RETURN;
    END IF;

   EXCEPTION
      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
           RAISE;
      WHEN FND_API.G_EXC_ERROR THEN
           RAISE;
      WHEN OTHERS THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.set_dest_prgm_att_params');
           IGS_GE_MSG_STACK.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
               FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.set_dest_prgm_att_params :',SQLERRM);
           END IF;
           App_Exception.Raise_Exception;

  END set_dest_prgm_att_params;

   PROCEDURE create_prgm_admin_record (
     p_person_id              IN   NUMBER,
     p_src_program_cd         IN   VARCHAR2,
     p_dest_program_cd        IN   VARCHAR2,
     p_acad_cal_type          IN   VARCHAR2,
     p_acad_seq_num           IN   NUMBER
    ) AS
  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : This procedure creates program administration record
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

   l_enr_cal_type    IGS_AS_SC_ATMPT_ENR.CAL_TYPE%TYPE;
   l_enr_seq_num     IGS_AS_SC_ATMPT_ENR.CI_SEQUENCE_NUMBER%TYPE;
   l_enr_category    IGS_AS_SC_ATMPT_ENR.ENROLMENT_CAT%TYPE;
   l_sub_ci_seq_num  IGS_CA_INST_REL.SUB_CI_SEQUENCE_NUMBER%TYPE;
   l_return_value    BOOLEAN;
   l_message_name    FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;

   CURSOR c_get_enrolment_cal_type IS
      SELECT scae.cal_type, scae.ci_sequence_number, scae.enrolment_cat
      FROM   IGS_AS_SC_ATMPT_ENR scae, IGS_CA_INST ci
      WHERE  scae.person_id = p_person_id  AND
                 scae.course_cd = p_src_program_cd AND
                 ci.cal_type = scae.cal_type AND
                 ci.sequence_number = scae.ci_sequence_number
      ORDER BY ci.start_dt DESC;

  CURSOR c_get_cal_rel_dtl_for_enr_cal (c_enr_cal_type IGS_CA_INST_REL.sub_cal_type%TYPE) IS
     SELECT cir.sub_ci_sequence_number
     FROM   IGS_CA_INST_REL cir
     WHERE  cir.sup_cal_type     = p_acad_cal_type AND
            cir.sup_ci_sequence_number = p_acad_seq_num AND
            cir.sub_cal_type     =   c_enr_cal_type;

  BEGIN

   OPEN c_get_enrolment_cal_type;
   FETCH c_get_enrolment_cal_type INTO l_enr_cal_type,l_enr_seq_num,l_enr_category;

   IF (c_get_enrolment_cal_type%FOUND) THEN
      CLOSE c_get_enrolment_cal_type;
      OPEN   c_get_cal_rel_dtl_for_enr_cal(l_enr_cal_type);
      FETCH  c_get_cal_rel_dtl_for_enr_cal INTO l_sub_ci_seq_num;

      IF (c_get_cal_rel_dtl_for_enr_cal%FOUND) THEN
          CLOSE c_get_cal_rel_dtl_for_enr_cal;
          l_return_value := IGS_EN_GEN_009.ENRP_INS_SCAE_TRNSFR(p_person_id,
                                                                p_dest_program_cd,
                                                                l_enr_cal_type,
                                                                l_sub_ci_seq_num,
                                                                l_enr_category,
                                                                l_message_name);
      ELSE
         CLOSE c_get_cal_rel_dtl_for_enr_cal;
      END IF;
   ELSE
      CLOSE c_get_enrolment_cal_type;
   END IF; -- end of c_get_enrolment_cal_type%FOUND IF THEN

   EXCEPTION
      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
           RAISE;
      WHEN FND_API.G_EXC_ERROR THEN
           RAISE;
      WHEN OTHERS THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.validate_src_prgm_unt_set_att');
           IGS_GE_MSG_STACK.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
               FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.create_prgm_admin_record :',SQLERRM);
           END IF;
           App_Exception.Raise_Exception;

  END create_prgm_admin_record;


  PROCEDURE check_is_dest_prgm_actv_confrm (
   p_person_id               IN   NUMBER,
   p_source_program_cd       IN   VARCHAR2,
   p_acad_cal_type           IN   VARCHAR2,
   p_acad_seq_num            IN   NUMBER,
   p_dest_program_cd         IN   VARCHAR2,
   p_show_warning            IN   VARCHAR2,
   p_dest_confirmed_ind      IN OUT  NOCOPY VARCHAR2
  ) AS
   -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : This program check whether destination program  student confirm indicator is
  --           active or not and confirms it if it passed validations.
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------


   CURSOR c_get_dest_prg_dtls(c_person_id IGS_EN_STDNT_PS_ATT.PERSON_ID%TYPE,c_program_cd IGS_EN_STDNT_PS_ATT.COURSE_CD%TYPE) IS
      SELECT *
      FROM IGS_EN_STDNT_PS_ATT
      WHERE person_id = c_person_id AND
            course_cd = c_program_cd;
   l_val_sca_confrm_status   BOOLEAN;
   l_val_sca_elgbl_status    BOOLEAN;
   l_message_name            FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
   l_message_name1            FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
   l_dest_sca_rec            c_get_dest_prg_dtls%ROWTYPE;

  BEGIN

    OPEN   c_get_dest_prg_dtls(p_person_id,p_dest_program_cd);
    FETCH  c_get_dest_prg_dtls INTO l_dest_sca_rec;
    CLOSE  c_get_dest_prg_dtls;
    l_val_sca_confrm_status :=  IGS_EN_VAL_SCA.enrp_val_sca_confirm(p_person_id,
                                                                    p_dest_program_cd,
                                                                    l_dest_sca_rec.adm_admission_appl_number,
                                                                    l_dest_sca_rec.adm_nominated_course_cd,
                                                                    l_dest_sca_rec.adm_sequence_number,
                                                                    l_dest_sca_rec.student_confirmed_ind,
                                                                    l_dest_sca_rec.course_attempt_status,
                                                                    l_message_name);
    IF l_val_sca_confrm_status = FALSE THEN
       IF l_message_name IN ('IGS_EN_ASSOCIATE_ADMPRG_APPL') AND p_show_warning = 'Y' THEN
          FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
          FND_MSG_PUB.ADD;
       END IF;
       IF l_message_name IN ('IGS_EN_PRG_ATT_CONF_ENR','IGS_EN_CONF_IND_ONLY_BE_CHANG') THEN
          FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;-- end of l_val_sca_confrm_status = FALSE  IF THEN

    l_val_sca_elgbl_status := IGS_EN_GEN_006.ENRP_GET_SCA_ELGBL(p_person_id,
                                                                p_dest_program_cd,
                                                                'RETURN',
                                                                p_acad_cal_type,
                                                                p_acad_seq_num,
                                                                'Y',
                                                                l_message_name1);

    IF l_val_sca_elgbl_status = FALSE THEN
       IF l_message_name1 NOT IN ('IGS_EN_STUD_INELIG_TO_RE_ENR','IGS_EN_INELIGBLE_DUE_TO_LAPSE',
                                  'IGS_EN_STUD_INELIGIBLE_RE_ENR','IGS_EN_STUD_NOT_HAVE_CURR_AFF',
                                  'IGS_EN_INTERM_DOES_NOT_END', 'IGS_RE_SUPERV_%_MUST_TOT_100')  THEN
           FND_MESSAGE.SET_NAME( 'IGS' , l_message_name1);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;-- end of l_val_sca_elgbl_status = FALSE  IF THEN

    p_dest_confirmed_ind := 'Y';

    EXCEPTION

      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
           RAISE;
      WHEN FND_API.G_EXC_ERROR THEN
           RAISE;
      WHEN OTHERS THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.check_is_dest_prgm_actv_confrm');
           IGS_GE_MSG_STACK.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
               FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.check_is_dest_prgm_actv_confrm :',SQLERRM);
           END IF;
           App_Exception.Raise_Exception;

  END check_is_dest_prgm_actv_confrm;


  PROCEDURE check_for_debt(
    p_person_id               IN   NUMBER,
    p_source_program_cd       IN   VARCHAR2,
    p_message_name            OUT NOCOPY VARCHAR2
  ) AS
  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : This procedure checks for the debt
  --Change History:
  --Who         When            What
  --bdeviset    08-APR-2005     Changed cursors c_get_debt_for_src_prgm_att and c_get_debt_for_src_prgm_att
        --                            tp access data from igs_fi_inv_int instead of IGS_FI_FEE_AS for bug#4177199
  -------------------------------------------------------------------------------------------
   l_debt_exists     IGS_FI_FEE_AS.person_id%TYPE;
   CURSOR c_get_debt_for_src_prgm_att IS
      SELECT person_id
      FROM igs_fi_inv_int
                        WHERE person_id = p_person_id
                        AND course_cd = p_source_program_cd
                        AND transaction_type IN ('ASSESSMENT', 'RETENTION', 'SPECIAL')
                        AND invoice_amount_due > 0;

   CURSOR c_getdebt_for_all_prgms IS
                        SELECT person_id
                        FROM igs_fi_inv_int
                        WHERE person_id = p_person_id
                        AND course_cd IS NULL
                        AND invoice_amount_due > 0;

  BEGIN
    OPEN c_get_debt_for_src_prgm_att;
    FETCH c_get_debt_for_src_prgm_att INTO l_debt_exists;
    IF ( c_get_debt_for_src_prgm_att%FOUND ) THEN
        p_message_name := 'IGS_EN_STUD_EXIST_DEBT_PRG';
        CLOSE c_get_debt_for_src_prgm_att;
        RETURN;
    ELSE
        CLOSE c_get_debt_for_src_prgm_att;
    END IF;

    OPEN  c_getdebt_for_all_prgms;
    FETCH c_getdebt_for_all_prgms INTO l_debt_exists;
    IF ( c_getdebt_for_all_prgms%FOUND ) THEN
        p_message_name := 'IGS_EN_PRSN_EXISTING_DEBT';
        CLOSE c_getdebt_for_all_prgms;
        RETURN;
    ELSE
        CLOSE c_getdebt_for_all_prgms;
    END IF;

    EXCEPTION
       WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
            RAISE;
       WHEN FND_API.G_EXC_ERROR THEN
           RAISE;
       WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.check_for_debt');
            IGS_GE_MSG_STACK.ADD;
            IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
               FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.check_for_debt :',SQLERRM);
            END IF;
            App_Exception.Raise_Exception;

  END check_for_debt;

 PROCEDURE check_for_holds(
    p_person_id               IN   NUMBER,
    p_dest_program_cd         IN   VARCHAR2,
    p_term_cal_type           IN   VARCHAR2,
    p_term_seq_num            IN   NUMBER,
    p_person_type             IN   VARCHAR2,
    p_return_status           IN OUT NOCOPY  VARCHAR2,
    p_show_warning            IN   VARCHAR2
   )AS
  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : This procedure checks for the holds
  --Change History:
  --Who         When            What
  -- ckasu    07-JAN-2005      Modified code inorder to include check for deny all enrollment
  --                           activity as a part of bug# 4083552

  -------------------------------------------------------------------------------------------
    l_deny_warn      VARCHAR2(100);
    l_message_name   FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
    l_hold_status    BOOLEAN;

    v_message_name          varchar2(30);
    v_message_name2         varchar2(30);
    v_first_message_name    varchar2(30);
    v_first_message_name2   varchar2(30);
    v_return_type           VARCHAR2(1);
    v_attendance_types      VARCHAR2(100);
    v_encmb_fail            BOOLEAN;


  BEGIN

    -- checks whether Student is excluded from the  Admission or Enrolment of destination course or not

    l_hold_status := IGS_EN_VAL_ENCMB.enrp_val_excld_crs(p_person_id,
                                                         p_dest_program_cd,
                                                         SYSDATE,
                                                         l_message_name
                                                         );
    IF l_hold_status = FALSE THEN

       IF p_show_warning = 'Y'  THEN

         FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_NOTTRNS_NOMINATED_PRG');
         FND_MSG_PUB.ADD;
         FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_PERS_ENCUMB_SYS');
         FND_MSG_PUB.ADD;
       END IF;

    END IF;


    IF IGS_EN_VAL_ENCMB.enrp_val_enr_encmb( -- -- calling with census date
                        p_person_id,
                        p_dest_program_cd,
                        p_term_cal_type,
                        p_term_seq_num,
                        v_message_name,
                        v_message_name2,
                        v_return_type,
                        SYSDATE
                        ) = FALSE THEN

                        IF p_show_warning = 'Y' AND (l_message_name <>   NVL(v_message_name,v_message_name2))  THEN

                                 -- log the warning message here

                                 FND_MESSAGE.SET_NAME( 'IGS' ,NVL(v_message_name,v_message_name2));
                                 FND_MSG_PUB.ADD;

                                 FND_MESSAGE.SET_NAME( 'IGS' ,'IGS_EN_PERS_ENCUMB_SYS');
                                 FND_MSG_PUB.ADD;

                        END IF;

     END IF; -- end of IF enrp_val_enr_encmb_pt(


  -- check whether a hold with Deny All Enrollment acticity effect
  -- exists for the student or not

     igs_en_elgbl_person.eval_ss_deny_all_hold (
                                                   p_person_id     => p_person_id,
                                                   p_person_type   => p_person_type,
                                                   p_course_cd     => p_dest_program_cd,
                                                   p_load_calendar_type => p_term_cal_type,
                                                   p_load_cal_sequence_number => p_term_seq_num,
                                                   p_status        => l_deny_warn,
                                                   p_message       => l_message_name);

     IF l_deny_warn = 'E'  THEN
          IF l_message_name IS NOT NULL THEN
             FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
             FND_MSG_PUB.ADD;
             p_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
     END IF;-- end of l_deny_warn = 'E' IF THEN



    EXCEPTION
      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
           RAISE;
      WHEN FND_API.G_EXC_ERROR THEN
            RAISE;
      WHEN OTHERS THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.check_for_holds');
           IGS_GE_MSG_STACK.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
               FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.check_for_holds :',SQLERRM);
           END IF;
           App_Exception.Raise_Exception;

  END check_for_holds;

  FUNCTION enrp_val_excld_unit_pt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
        v_pue_start_dt          IGS_PE_PERS_UNT_EXCL.pue_start_dt%TYPE;
        v_expiry_dt             IGS_PE_PERS_UNT_EXCL.expiry_dt%TYPE;
        CURSOR c_psd_ed IS
                SELECT  pue.pue_start_dt,
                        pue.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT    pee,
                        IGS_PE_PERS_UNT_EXCL            pue
                WHERE   pee.person_id = p_person_id AND
                        pee.s_encmb_effect_type = 'EXC_CRS_U' AND
                        pee.course_cd = p_course_cd AND
                        pue.person_id = pee.person_id AND
                        pue.encumbrance_type = pee.encumbrance_type AND
                        pue.pen_start_dt = pee.pen_start_dt AND
                        pue.s_encmb_effect_type = pee.s_encmb_effect_type AND
                        pue.pee_start_dt = pee.pee_start_dt AND
                        pue.pee_sequence_number = pee.sequence_number AND
                        pue.unit_cd = p_unit_cd;
  BEGIN
        -- This function validates whether or not a IGS_PE_PERSON is
        -- excluded from admission or enrolment in a specific IGS_PS_UNIT.
        p_message_name := null;
        -- Validate the input parameters
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL OR
                        p_unit_cd IS NULL OR
                        p_effective_dt IS NULL THEN
                p_message_name := null;
                RETURN TRUE;
        END IF;

        --Validate for an exclusion from a specific IGS_PS_UNIT.
        OPEN    c_psd_ed;
        LOOP
                FETCH   c_psd_ed        INTO    v_pue_start_dt,
                                                v_expiry_dt;
                EXIT WHEN c_psd_ed%NOTFOUND;
                --Validate if the dates of a returned record overlap with the effective date.
                IF v_expiry_dt IS NULL THEN
                        IF v_pue_start_dt <= p_effective_dt THEN
                                CLOSE c_psd_ed;
                                p_message_name := 'IGS_EN_PRSN_ENCUMB_EXC_ENR';
                                RETURN FALSE;
                        END IF;
                ELSE
                        IF p_effective_dt BETWEEN v_pue_start_dt AND (v_expiry_dt - 1) THEN
                                CLOSE c_psd_ed;
                                p_message_name := 'IGS_EN_PRSN_ENCUMB_EXC_ENR';
                                RETURN FALSE;
                        END IF;
                END IF;
        END LOOP;
        CLOSE   c_psd_ed;
        --- Return the default value
        p_message_name := null;
        RETURN TRUE;
  END;
  EXCEPTION
      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
           RAISE;
      WHEN FND_API.G_EXC_ERROR THEN
           RAISE;
      WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.enrp_val_excld_unit_pt');
                IGS_GE_MSG_STACK.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
               FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.enrp_val_excld_unit_pt :',SQLERRM);
           END IF;
           App_Exception.Raise_Exception;

  END enrp_val_excld_unit_pt;


  PROCEDURE upd_or_create_dest_term_rec(
     p_person_id               IN   NUMBER,
     p_dest_program_cd         IN   VARCHAR2,
     p_term_cal_type           IN   VARCHAR2,
     p_term_seq_num            IN   NUMBER,
     p_key_program_flag        IN   VARCHAR2,
     p_message_name            OUT NOCOPY VARCHAR2,
     p_dest_fut_dt_trans_flag IN   VARCHAR2

  ) AS

  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : this function is used to create or update destination program attempt
  --Change History:
  --Who         When            What
 -- stutta  26-Sep-2005     Added call to create_update_term_rec for bug 4588264
  -------------------------------------------------------------------------------------------

   l_key_program_flag      igs_en_spa_terms.key_program_flag%TYPE;
  BEGIN

       IF p_dest_fut_dt_trans_flag = 'Y' THEN
          -- delete the global table before populating it

		  l_key_program_flag := FND_API.G_MISS_CHAR;
		  IF p_key_program_flag = 'Y' THEN
			l_key_program_flag := p_key_program_flag;
		  END IF;
          igs_en_spa_terms_api.create_update_term_rec(p_person_id         => p_person_id,
                                               p_program_cd             => p_dest_program_cd,
                                               p_term_cal_type          => p_term_cal_type,
                                               p_term_sequence_NUMBER   => p_term_seq_num,
                                               p_key_program_flag       => l_key_program_flag,
                                               p_ripple_frwrd           => TRUE,
                                               p_program_changed        => TRUE,
                                               p_message_name           => p_message_name,
                                               p_update_rec             => TRUE);


      END IF;

   EXCEPTION
      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
           RAISE;
      WHEN FND_API.G_EXC_ERROR THEN
           RAISE;
      WHEN OTHERS THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.upd_or_create_dest_term_rec');
           IGS_GE_MSG_STACK.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
               FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.upd_or_create_dest_term_rec :',SQLERRM);
           END IF;
           App_Exception.Raise_Exception;

  END upd_or_create_dest_term_rec;

  FUNCTION is_tranfer_across_careers(
    p_src_program_cd       IN   VARCHAR2,
    p_src_progam_ver       IN   NUMBER,
    p_dest_program_cd      IN   VARCHAR2,
    p_dest_prog_ver        IN   NUMBER,
    p_src_career_type      OUT  NOCOPY VARCHAR2
  ) RETURN BOOLEAN AS

  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : This function returns when Transfer is across careers and
  --           false when transfer is with in the careers
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

    CURSOR c_get_career_type(c_program_cd IGS_PS_VER.course_cd%TYPE,c_program_ver IGS_PS_VER.version_number%TYPE) IS
       SELECT course_type
       FROM   IGS_PS_VER
       WHERE  course_cd =  c_program_cd AND
              version_number = c_program_ver;
    l_src_prgm_career    IGS_PS_VER.COURSE_TYPE%TYPE;
    l_dest_prgm_career    IGS_PS_VER.COURSE_TYPE%TYPE;

  BEGIN

    OPEN c_get_career_type(p_src_program_cd,p_src_progam_ver);
    FETCH c_get_career_type INTO l_src_prgm_career;
    CLOSE c_get_career_type;
    OPEN c_get_career_type(p_dest_program_cd,p_dest_prog_ver);
    FETCH c_get_career_type INTO l_dest_prgm_career;
    CLOSE c_get_career_type;
    IF (l_src_prgm_career <> l_dest_prgm_career) THEN
        p_src_career_type := l_src_prgm_career;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

  END is_tranfer_across_careers;


  PROCEDURE getunits_in_src_notin_dest_prg(
    p_person_id               IN   NUMBER,
    p_source_program_cd       IN   VARCHAR2,
    p_dest_program_cd         IN   VARCHAR2,
    p_uoo_ids_transfered      IN   VARCHAR2,
    p_drop                    IN   BOOLEAN,
    p_show_warning            IN   VARCHAR2
  ) AS
  -------------------------------------------------------------------------------------------
  -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
  -- Purpose : returns all units in sorce that are not in destination
  --Change History:
  --Who         When            What

  --------------------------------------------------------------------------------------------
    l_unit_not_in_dest_prgm BOOLEAN;
    l_uooid   NUMBER;
    l_unchk_units_in_src  VARCHAR2(2000);

    CURSOR c_get_all_enr_waitlstd_units IS
       SELECT unit_cd,uoo_id
       FROM IGS_EN_SU_ATTEMPT
       WHERE person_id = p_person_id  AND
             course_cd = p_source_program_cd AND
             unit_attempt_status IN ('ENROLLED','WAITLISTED','INVALID');
     l_cindex      NUMBER;
     l_temp_uoo_ids    VARCHAR2(1000);

  BEGIN

        l_temp_uoo_ids := ',' || p_uoo_ids_transfered || ',' ;
       -- getting all unchecked/unselected units in Source whose status is Enrolled or Waitlisted
       -- or Invalid during Transfer.

       FOR l_all_units_in_src_prgm_rec IN   c_get_all_enr_waitlstd_units LOOP

           l_cindex := INSTR(l_temp_uoo_ids,','||l_all_units_in_src_prgm_rec.uoo_id||',',1,1);
           IF  l_cindex = 0 THEN
              IF l_unchk_units_in_src IS NULL THEN
                 l_unchk_units_in_src := l_all_units_in_src_prgm_rec.unit_cd ;
              ELSE
                 l_unchk_units_in_src := l_unchk_units_in_src || ' , '|| l_all_units_in_src_prgm_rec.unit_cd ;
              END IF;
           END IF;-- end of  l_cindex <> 0 IF THEN
       END LOOP;--end of units in src Prgm Loop

       -- when these units are being dropped in the immediate transfer then show the message
       IF p_show_warning = 'Y' AND l_unchk_units_in_src IS NOT NULL  AND p_drop  THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_EN_TRN_EN_WL_U_NO_SEL');
          FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unchk_units_in_src);
          FND_MSG_PUB.ADD;
       END IF;

       EXCEPTION
          WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
               RAISE;
          WHEN FND_API.G_EXC_ERROR THEN
               RAISE;
          WHEN OTHERS THEN
               Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
               FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.getunits_in_src_notin_dest_prg');
               IGS_GE_MSG_STACK.ADD;
               IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                   FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.getunits_in_src_notin_dest_prg :',SQLERRM);
               END IF;
               App_Exception.Raise_Exception;

  END getunits_in_src_notin_dest_prg;


PROCEDURE val_unchk_sub_units(
    p_person_id               IN   NUMBER,
    p_source_program_cd       IN   VARCHAR2,
    p_uoo_ids_transfered      IN OUT NOCOPY VARCHAR2,
    p_drop                    IN   BOOLEAN,
    p_show_warning            IN   VARCHAR2

  ) AS
  -------------------------------------------------------------------------------------------
  -- Created by  : Susmitha Tutta, Oracle Student Systems Oracle IDC
  -- Purpose : Throws warning if a superior is checked and subordinate unchecked for transfer
  -- and unchecked source units are not to be dropped.
  --Change History:
  --Who         When            What

  --------------------------------------------------------------------------------------------
    l_unit_not_in_dest_prgm BOOLEAN;
    l_uooid   NUMBER;
    l_unchk_units_in_src  VARCHAR2(2000);

    CURSOR c_get_all_src_units IS
       SELECT sua.unit_cd,sua.uoo_id, uoo.sup_uoo_id
       FROM IGS_EN_SU_ATTEMPT sua, IGS_PS_UNIT_OFR_OPT uoo
       WHERE person_id = p_person_id  AND
             course_cd = p_source_program_cd AND
	     uoo.uoo_id = sua.uoo_id AND
	     uoo.sup_uoo_id IS NOT NULL AND
	     sua.unit_attempt_status <> 'DROPPED';
     l_cindex      NUMBER;
     l_temp_uoo_ids    VARCHAR2(1000);
     l_sub_not_selected BOOLEAN := FALSE;
BEGIN

       l_temp_uoo_ids := ',' || p_uoo_ids_transfered || ',' ;

       FOR l_all_src_units_rec IN   c_get_all_src_units LOOP

           IF  (INSTR(l_temp_uoo_ids,','||l_all_src_units_rec.sup_uoo_id||',',1,1) <>0
           AND INSTR (l_temp_uoo_ids,','||l_all_src_units_rec.uoo_id||',',1,1) = 0) THEN
	      p_uoo_ids_transfered := p_uoo_ids_transfered||','||l_all_src_units_rec.uoo_id;
	      l_sub_not_selected := TRUE;
	   END IF;
       END LOOP;

       -- when these units are being dropped in the immediate transfer then show the message
       IF p_show_warning = 'Y' AND l_sub_not_selected  AND NOT p_drop  THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_EN_TRN_SUB_NO_SEL_DROP'); -- subordinates units of all superiors unit selected for transfer will be dropped.
          FND_MSG_PUB.ADD;
       END IF;

EXCEPTION
  WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
       RAISE;
  WHEN FND_API.G_EXC_ERROR THEN
       RAISE;
  WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.val_unchk_sub_units');
       IGS_GE_MSG_STACK.ADD;
       IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
	   FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.val_unchk_sub_units :',SQLERRM);
       END IF;
       App_Exception.Raise_Exception;

END val_unchk_sub_units;


  PROCEDURE validate_person_steps(
     p_person_id               IN   NUMBER,
     p_dest_program_cd         IN   VARCHAR2,
     p_dest_prog_ver           IN   NUMBER,
     p_term_cal_type           IN   VARCHAR2,
     p_term_seq_num            IN   NUMBER,
     p_acad_cal_type           IN   VARCHAR2,
     p_acad_seq_num            IN   NUMBER,
     p_person_type             IN   VARCHAR2,
     p_show_warning            IN   VARCHAR2,
     p_return_status           IN OUT NOCOPY  VARCHAR2
   ) AS

  -------------------------------------------------------------------------------------------
  -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
  -- Purpose : this procedure validate all Person steps during program transfer
  --Change History:
  --Who         When            What

  --------------------------------------------------------------------------------------------

    l_deny_warn                     VARCHAR2(100);
    l_message_name                  VARCHAR2(4000);
    l_enrolment_cat                 IGS_PS_TYPE.ENROLMENT_CAT%TYPE;
    l_en_cal_type                   IGS_CA_INST.CAL_TYPE%TYPE;
    l_en_ci_seq_num                 IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    l_commencement_type             VARCHAR2(20);
    l_dummy                         VARCHAR2(100);
    l_enroll_mtd_type               IGS_EN_METHOD_TYPE.ENR_METHOD_TYPE%TYPE;
    l_personsteps_vald_status       BOOLEAN;

    CURSOR c_get_enr_method_type IS
       SELECT enr_method_type
       FROM  IGS_EN_METHOD_TYPE
       WHERE transfer_flag = 'Y' AND
             closed_ind ='N';

  BEGIN

       l_commencement_type := NULL;

       l_enrolment_cat := IGS_EN_GEN_003.Enrp_Get_Enr_Cat(p_person_id                =>p_person_id,
                                                          p_course_cd                =>p_dest_program_cd,
                                                          p_cal_type                 =>p_acad_cal_type,
                                                          p_ci_sequence_number       =>p_acad_seq_num,
                                                          p_session_enrolment_cat    =>NULL,
                                                          p_enrol_cal_type           =>l_en_cal_type,
                                                          p_enrol_ci_sequence_number =>l_en_ci_seq_num,
                                                          p_commencement_type        =>l_commencement_type,
                                                          p_enr_categories           =>l_dummy);

       OPEN  c_get_enr_method_type;
       FETCH c_get_enr_method_type INTO l_enroll_mtd_type;
       CLOSE c_get_enr_method_type;


       l_personsteps_vald_status := igs_en_elgbl_person.eval_person_steps(
                                              p_person_id                 =>p_person_id,
                                              p_person_type               =>p_person_type,
                                              p_load_calendar_type        =>p_term_cal_type,
                                              p_load_cal_sequence_number  =>p_term_seq_num,
                                              p_program_cd                =>p_dest_program_cd,
                                              p_program_version           =>p_dest_prog_ver,
                                              p_enrollment_category       =>l_enrolment_cat,
                                              p_comm_type                 =>l_commencement_type,
                                              p_enrl_method               =>l_enroll_mtd_type,
                                              p_message                   =>l_message_name,
                                              p_deny_warn                 =>l_deny_warn,
                                              p_calling_obj               =>'JOB',
                                              p_create_warning            =>'N'
                                              );


       IF l_personsteps_vald_status  AND l_deny_warn = 'WARN' THEN

              IF l_message_name IS NOT NULL AND  p_show_warning = 'Y' THEN
                parse_messages( l_message_name);
              END IF;

       END IF; -- end of l_personsteps_vald_status = 'FALSE' AND l_deny_warn = 'WARN'  IF THEN

       IF NOT l_personsteps_vald_status AND l_deny_warn = 'DENY' THEN

              IF l_message_name IS NOT NULL AND  p_show_warning = 'Y' THEN
                 parse_messages( l_message_name );
                 p_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              IF l_message_name IS NOT NULL AND  p_show_warning = 'N' THEN
                 parse_messages( l_message_name );
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

       END IF; -- end of  l_personsteps_vald_status = 'FALSE' AND l_deny_warn = 'DENY'  IF THEN


    EXCEPTION
       WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
            RAISE;
       WHEN FND_API.G_EXC_ERROR THEN
            RAISE;
       WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.validate_person_steps');
            IGS_GE_MSG_STACK.ADD;
            IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.validate_person_steps :',SQLERRM);
            END IF;
            App_Exception.Raise_Exception;

  END validate_person_steps;


  PROCEDURE validate_candidacy_tran_dtls(
     p_person_id               IN   NUMBER,
     p_source_program_cd       IN   VARCHAR2,
     p_source_prog_ver         IN   NUMBER,
     p_dest_program_cd         IN   VARCHAR2,
     p_dest_prog_ver           IN   NUMBER,
     p_show_warning            IN   VARCHAR2,
     p_return_status           IN OUT   NOCOPY VARCHAR2
  ) AS

  -------------------------------------------------------------------------------------------
  -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure validates Candidacy transfer details
  --Change History:
  --Who         When            What
  --stutta   13-DEC-2004    Donot validate research candidacy before updating destination program
  --                        if the destination program attempt is discontinued, validate it after
  --                        updating destination program. Bug #4048290
  --------------------------------------------------------------------------------------------

     l_candidacy_tran_status    BOOLEAN;
     l_res_elgbl_status         BOOLEAN;
     l_message_name FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
     l_elgbl_message_name FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;

  BEGIN

     l_candidacy_tran_status := IGS_RE_VAL_CA.resp_val_ca_sca(p_person_id,
                                                              NULL, -- sequence number not known
                                                              NULL, -- old course code does not apply
                                                              p_dest_program_cd,
                                                              NULL,
                                                              NULL,
                                                              NULL, -- admission details does not apply
                                                              l_message_name);

     IF (l_candidacy_tran_status = FALSE AND  p_show_warning = 'Y') THEN
         FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
         FND_MSG_PUB.ADD;
         p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     IF (l_candidacy_tran_status = FALSE AND  p_show_warning = 'N') THEN
         FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_candidacy_tran_status := IGS_EN_INS_CA_TRNSFR.enrp_ins_ca_trnsfr(p_person_id,
                                                                        p_dest_program_cd,
                                                                        NULL,
                                                                        NULL,
                                                                        NULL,
                                                                        p_source_program_cd,
                                                                        'SCA',
                                                                        l_message_name);

     IF (l_candidacy_tran_status = FALSE AND  p_show_warning = 'Y') THEN
         FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
         FND_MSG_PUB.ADD;
         p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     IF (l_candidacy_tran_status = FALSE AND  p_show_warning = 'N') THEN
         FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_res_elgbl_status := IGS_EN_VAL_SCA.enrp_val_res_elgbl(p_person_id,
                                                             p_dest_program_cd,
                                                             p_dest_prog_ver,
                                                             l_elgbl_message_name);

     IF  (l_elgbl_message_name IS NOT NULL AND p_show_warning = 'Y') THEN
       IF l_elgbl_message_name NOT IN ('IGS_RE_SUPERV_%_MUST_TOT_100') THEN
          FND_MESSAGE.SET_NAME( 'IGS' , l_elgbl_message_name);
          FND_MSG_PUB.ADD;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     END IF;


     IF  (l_elgbl_message_name IS NOT NULL AND p_show_warning = 'N') THEN
       IF l_elgbl_message_name NOT IN ('IGS_RE_SUPERV_%_MUST_TOT_100') THEN
          FND_MESSAGE.SET_NAME( 'IGS' , l_elgbl_message_name);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

     EXCEPTION
        WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
             RAISE;
        WHEN FND_API.G_EXC_ERROR THEN
             RAISE;
        WHEN OTHERS THEN
             Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
             FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.validate_candidacy_tran_dtls');
             IGS_GE_MSG_STACK.ADD;
             IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                 FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.validate_candidacy_tran_dtls :',SQLERRM);
             END IF;
             App_Exception.Raise_Exception;

   END validate_candidacy_tran_dtls;


  PROCEDURE validate_advance_st_tran_dtls(
     p_person_id               IN   NUMBER,
     p_source_program_cd       IN   VARCHAR2,
     p_source_prog_ver         IN   NUMBER,
     p_dest_program_cd         IN   VARCHAR2,
     p_dest_prog_ver           IN   NUMBER,
     p_show_warning            IN   VARCHAR2
   ) AS

  -------------------------------------------------------------------------------------------
  -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure validates Advance Standing  details that are
  --           to be transfered is exists for source program.
  --Change History:
  --Who         When            What
  --bdeviset    06-SEP-2006    Bug# 5525374.The message retunred from IGS_EN_GEN_010.adv_stand_trans (IGS_EN_STDNT_ADV_STND_EXIST)
  --                           is a warning message and should be added to the stack only when p_show_warning is passed as 'Y'
  -------------------------------------------------------------------------------------------

     l_val  VARCHAR2(1);
     l_message_name      FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;

     CURSOR c_is_adv_st_exists(c_person_id IGS_AV_ADV_STANDING.PERSON_ID%TYPE,
                               c_source_program_cd IGS_AV_ADV_STANDING.COURSE_CD%TYPE,
                               c_source_prog_ver IGS_AV_ADV_STANDING.VERSION_NUMBER%TYPE )IS
        SELECT 'x'
        FROM IGS_AV_ADV_STANDING
        WHERE person_id = c_person_id AND
              course_cd = c_source_program_cd AND
              version_number = c_source_prog_ver;


  BEGIN

    OPEN c_is_adv_st_exists(p_person_id,p_source_program_cd,p_source_prog_ver);
    FETCH c_is_adv_st_exists INTO l_val;
    IF (c_is_adv_st_exists%FOUND) THEN
        CLOSE c_is_adv_st_exists;
        IGS_EN_GEN_010.adv_stand_trans(p_person_id           => p_person_id,
                                      p_course_cd            => p_source_program_cd,
                                      p_version_number       => p_source_prog_ver,
                                      p_course_cd_new        => p_dest_program_cd,
                                      p_version_number_new   => p_dest_prog_ver,
                                      p_message_name         => l_message_name);
    ELSE
       CLOSE c_is_adv_st_exists;
    END IF; -- end of IF THEN ELSE

    IF p_show_warning = 'Y' AND l_message_name IS NOT NULL THEN
       FND_MESSAGE.SET_NAME( 'IGS' ,l_message_name);
       FND_MSG_PUB.ADD;
    END IF;-- end of l_message_name IF THEN

    EXCEPTION
       WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
            RAISE;
       WHEN FND_API.G_EXC_ERROR THEN
            RAISE;
       WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.validate_advance_st_tran_dtls');
            IGS_GE_MSG_STACK.ADD;
            IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.validate_advance_st_tran_dtls :',SQLERRM);
            END IF;
            App_Exception.Raise_Exception;

  END validate_advance_st_tran_dtls;

  FUNCTION is_sua_enroll_eff_fut_term( p_person_id       IN NUMBER,
                                       p_dest_program_cd IN VARCHAR2,
                                       p_term_cal_type   IN VARCHAR2,
                                       p_term_seq_num    IN NUMBER)
  RETURN BOOLEAN AS

  -------------------------------------------------------------------------------------------
  -- Created by  : bdeviset, Oracle Student Systems Oracle IDC
  -- Purpose : Checks if there are any enrolled/waitlisted/invalid unit attempts in the
  -- effective and future terms.If so returns true else false.
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

   -- cursor to get all the enrolled unit attempts uooid against destination program
  CURSOR c_enroll_sua (cp_person_id     igs_en_stdnt_ps_att.person_id%TYPE,
                       cp_course_cd     igs_en_stdnt_ps_att.course_cd%TYPE) IS

    SELECT  uoo_id
    FROM  IGS_EN_SU_ATTEMPT sua
    WHERE sua.person_id = cp_person_id
    AND   sua.course_cd = cp_course_cd
    AND   sua.unit_attempt_status IN ('ENROLLED','WAITLISTED','INVALID');

    l_unit_exists BOOLEAN;

  BEGIN

    l_unit_exists := FALSE;
    FOR c_enroll_sua_rec IN c_enroll_sua(p_person_id,p_dest_program_cd) LOOP

     -- For each enrolled/waitlisted/invalid unit ateempt check whether it is in
     -- effective and future terms
     -- if so set the flag to true and exit
       IF  IGS_EN_GEN_010.unit_effect_or_future_term(
                                         p_person_id => p_person_id,
                                         p_dest_course_cd => p_dest_program_cd,
                                         p_uoo_id  => c_enroll_sua_rec.uoo_id,
                                         p_term_cal_type => p_term_cal_type ,
                                         p_term_seq_num => p_term_seq_num) THEN


            l_unit_exists := TRUE;
            EXIT;

       END IF;

    END LOOP;

    RETURN l_unit_exists;


  END is_sua_enroll_eff_fut_term;

  FUNCTION  is_unit_rel_dest_acad_cal (p_person_id      IN   NUMBER,
                              p_source_program_cd       IN   VARCHAR2,
                              p_dest_program_cd         IN   VARCHAR2,
                              p_uoo_id                  IN NUMBER,
                              p_message_name            OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
    CURSOR c_sca_detls (cp_person_id igs_en_stdnt_ps_att.person_id%TYPE,
                        cp_course_cd  igs_en_stdnt_ps_att.course_cd%TYPE) IS
  SELECT cal_type
  FROM igs_en_stdnt_ps_att
  WHERE person_id = cp_person_id AND
        course_cd = cp_course_cd ;
  l_old_cal_type  igs_en_stdnt_ps_att.cal_type%TYPE;
  l_new_cal_type  igs_en_stdnt_ps_att.cal_type%TYPE;
  BEGIN
           -- get source acad cal type
           OPEN c_sca_detls(p_person_id, p_source_program_cd );
           FETCH c_sca_detls INTO l_old_cal_type;
           CLOSE c_sca_detls;
           -- get dest cal type
           OPEN c_sca_detls(p_person_id, p_dest_program_cd );
           FETCH c_sca_detls INTO l_new_cal_type;
           CLOSE c_sca_detls;

           IF l_old_cal_type <> l_new_cal_type  THEN
                IF IGS_EN_VAL_SCT.enrp_val_sua_acad (p_person_id,
                           p_source_program_cd,
                           p_uoo_id,
                           l_new_cal_type,
                           p_message_name) = FALSE THEN
                    RETURN FALSE;
                END IF;
           END IF;

           RETURN TRUE;

  END is_unit_rel_dest_acad_cal;


  PROCEDURE validate_src_prgm_unt_attempts(
      p_person_id               IN   NUMBER,
      p_source_program_cd       IN   VARCHAR2,
      p_source_prog_ver         IN   NUMBER,
      p_term_cal_type           IN   VARCHAR2,
      p_term_seq_num            IN   NUMBER,
      p_acad_cal_type           IN   VARCHAR2,
      p_acad_seq_num            IN   NUMBER,
      p_trans_approval_dt       IN   DATE,
      p_trans_actual_dt         IN   DATE,
      p_dest_program_cd         IN   VARCHAR2,
      p_dest_prog_ver           IN   NUMBER,
      p_dest_coo_id             IN   NUMBER,
      p_uoo_ids_to_transfer     IN   VARCHAR2, -- concatenation of selected uoo_id,core_ind; coming from page
      p_uoo_ids_passed_transfer OUT   NOCOPY VARCHAR2, --  units which were successfully transfered among the selected ones from the page
      p_uoo_ids_having_errors   OUT NOCOPY VARCHAR2,
      p_uooids_str              OUT NOCOPY VARCHAR2, -- all selected uoo_ids passed from the page in format uoo_id1,uoo_id2
      p_dest_fut_dt_trans_flag  IN   VARCHAR2,
      p_show_warning            IN   VARCHAR2,
      p_drop                    IN   BOOLEAN,
      p_return_status           IN OUT NOCOPY  VARCHAR2
      ) AS

  -------------------------------------------------------------------------------------------
  -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure validates and transfers unit attempts in source program to the
  --           destination program.
  --Change History:
  --Who         When            What
  --ckasu     02-DEC-2004     modified as a part of Bug#4044329
  -- smaddali  16-dec-04      Modified for bug#4063726
  -- bdeviset  21-Mar-2006    After calling enrp_val_sua_cnfrm_p,while setting message
  --                          used nvl(l_message_name1,l_message_name2) instead of l_message_name1
  --                          as we need to consider l_message_name2 if l_message_name1 is null
  --                          Bug# 5070403
  -------------------------------------------------------------------------------------------

     l_strtpoint NUMBER;
     l_endpoint  NUMBER;
     l_cindex    NUMBER;
     l_pre_cindex NUMBER;
     l_nth_occurence NUMBER;
     l_uooid_coreind_sep_index NUMBER;
     l_uooid_and_coreind VARCHAR2(300);
     l_coreind  VARCHAR2(30);
     l_uooid  NUMBER;
     l_uoo_ids_to_transfer VARCHAR2(3000);
     l_enrp_sua_trans_status  BOOLEAN;
     l_message_name FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
     l_unit_outcome  IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
     l_is_val_sua_trans BOOLEAN;
     l_temp         VARCHAR2(1);
     l_unt_att_status   IGS_EN_SU_ATTEMPT.UNIT_ATTEMPT_STATUS%TYPE;
     l_proceed_aftr_res_val BOOLEAN;
     l_sut_status   BOOLEAN;
     l_sua_trans_status  BOOLEAN;
     l_return_type VARCHAR2(200);
     l_sua_confrm_status  BOOLEAN;
     l_fail_type    VARCHAR2(100);
     l_message_name1  FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
     l_message_name2  FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
     l_return_message FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
     l_del_sua_tran_status  BOOLEAN;
     l_del_all_sua_status   BOOLEAN;
     l_teach_cal_desc    IGS_CA_INST.description%TYPE;
     l_uooids_str  VARCHAR2(1000);
     l_message_name3   FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
     l_error_occured BOOLEAN;


     CURSOR c_get_unit_dtls(c_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE) Is
        SELECT *
        FROM IGS_EN_SU_ATTEMPT
        WHERE person_id = p_person_id AND
              course_cd = p_source_program_cd AND
              uoo_id = c_uoo_id ;

     CURSOR c_get_research_dtls(c_unit_cd IGS_EN_SU_ATTEMPT.unit_cd%TYPE,c_unit_version_number IGS_EN_SU_ATTEMPT.version_number%TYPE) IS
        SELECT 'x'
        FROM   IGS_PS_UNIT_VER uv
        WHERE  uv.unit_cd = c_unit_cd AND
               uv.version_number = c_unit_version_number AND
               uv.research_unit_ind = 'Y';

     CURSOR c_get_teach_cal_dec(c_teach_cal_type IGS_CA_INST.cal_type%TYPE,c_teach_cal_seq_num IGS_CA_INST.sequence_number%TYPE) IS
         SELECT description
         FROM igs_ca_inst
         WHERE cal_type = c_teach_cal_type AND
               sequence_number = c_teach_cal_seq_num ;
      l_unit_dtls_rec  c_get_unit_dtls%ROWTYPE;

      cst_enrolled  CONSTANT  VARCHAR2(10) := 'ENROLLED';
      cst_waitlist  CONSTANT  VARCHAR2(10) := 'WAITLISTED';
      cst_invalid  CONSTANT  VARCHAR2(10) := 'INVALID';
      l_src_crs_type  igs_ps_ver.course_type%TYPE;
  BEGIN

        l_strtpoint      :=  0;
        l_pre_cindex     :=  0;
        l_nth_occurence  :=  1;
        l_uoo_ids_to_transfer := p_uoo_ids_to_transfer ;
        l_cindex := INSTR(l_uoo_ids_to_transfer,';',1,l_nth_occurence);
        p_uoo_ids_having_errors := null;
        l_uooids_str := null;

        WHILE (l_cindex <> 0 )  LOOP

              SAVEPOINT SP_TRANSFER_SUA;
              l_error_occured := FALSE;
              l_strtpoint  :=  l_pre_cindex + 1;
              l_endpoint   :=  l_cindex - l_strtpoint;
              l_pre_cindex :=  l_cindex;
              l_uooid_and_coreind := substr(l_uoo_ids_to_transfer,l_strtpoint,l_endpoint);
              l_uooid_coreind_sep_index := INSTR(l_uooid_and_coreind,',',1);
              l_uooid :=   TO_NUMBER(SUBSTR(l_uooid_and_coreind,1,l_uooid_coreind_sep_index - 1));
              l_coreind := SUBSTR(l_uooid_and_coreind,l_uooid_coreind_sep_index + 1);

              OPEN c_get_unit_dtls(l_uooid);
              FETCH c_get_unit_dtls INTO l_unit_dtls_rec ;
              CLOSE c_get_unit_dtls;


                IF  l_uooids_str IS NULL THEN
                    l_uooids_str := l_uooid;
                ELSE
                    l_uooids_str := l_uooids_str||','||l_uooid;
                END IF;

                l_is_val_sua_trans := TRUE;
                l_proceed_aftr_res_val := TRUE;


                OPEN c_get_teach_cal_dec(l_unit_dtls_rec.cal_type,l_unit_dtls_rec.ci_sequence_number);
                FETCH c_get_teach_cal_dec INTO l_teach_cal_desc;
                CLOSE c_get_teach_cal_dec;

               -- If we are transfering from one academic calendar to different academic calendar then
               -- Units cannot be transfered if no academic calendar link exists.
               IF NOT is_unit_rel_dest_acad_cal(p_person_id,p_source_program_cd,p_dest_program_cd,l_uooid,l_return_message)  THEN
                                -- if transfer of unit failed then show warning and skip current unit attempt
                                IF p_show_warning = 'Y' THEN
                                     IF NOT l_error_occured THEN
                                           l_error_occured := TRUE;
                                           IF p_uoo_ids_having_errors IS NULL THEN
                                              p_uoo_ids_having_errors := l_uooid;
                                           ELSE
                                              p_uoo_ids_having_errors := p_uoo_ids_having_errors ||','||l_uooid;
                                           END IF;
                                           FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERR_UNIT_TRN');
                                           FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_dtls_rec.unit_cd);
                                           FND_MESSAGE.SET_TOKEN('LOCATION_CD',l_unit_dtls_rec.location_cd);
                                           FND_MESSAGE.SET_TOKEN('SECTION',l_unit_dtls_rec.unit_class);
                                           FND_MESSAGE.SET_TOKEN('TEACH_CAL_DESC',l_teach_cal_desc);
                                           FND_MSG_PUB.ADD;
                                     END IF;-- end of NOT l_error_occured IF THEN
                                     FND_MESSAGE.SET_NAME( 'IGS' , l_return_message);
                                     FND_MSG_PUB.ADD;
                                     p_return_status := FND_API.G_RET_STS_ERROR;
                                END IF;
                                IF p_show_warning = 'N' THEN
                                   IF NOT l_error_occured THEN
                                           l_error_occured := TRUE;
                                       IF p_uoo_ids_having_errors IS NULL THEN
                                          p_uoo_ids_having_errors := l_uooid;
                                       ELSE
                                          p_uoo_ids_having_errors := p_uoo_ids_having_errors ||','||l_uooid;
                                       END IF;
                                       FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERR_UNIT_TRN');
                                       FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_dtls_rec.unit_cd);
                                       FND_MESSAGE.SET_TOKEN('LOCATION_CD',l_unit_dtls_rec.location_cd);
                                       FND_MESSAGE.SET_TOKEN('SECTION',l_unit_dtls_rec.unit_class);
                                       FND_MESSAGE.SET_TOKEN('TEACH_CAL_DESC',l_teach_cal_desc);
                                       FND_MSG_PUB.ADD;
                                   END IF;-- end of NOT l_error_occured IF THEN
                                   FND_MESSAGE.SET_NAME( 'IGS' , l_return_message);
                                   FND_MSG_PUB.ADD;
                                   RAISE FND_API.G_EXC_ERROR;
                             END IF;

               ELSE

                    l_enrp_sua_trans_status := IGS_EN_VAL_SCT.enrp_val_sua_trnsfr(p_person_id,
                                                                                  p_source_program_cd,
                                                                                  l_unit_dtls_rec.unit_cd ,
                                                                                  l_unit_dtls_rec.cal_type,
                                                                                  l_unit_dtls_rec.ci_sequence_number,
                                                                                  l_unit_dtls_rec.unit_attempt_status ,
                                                                                  l_message_name,
                                                                                  l_uooid,
                                                                                  l_unit_outcome );
                    -- if above validation failed then log error message and skip this unit attempt
                    IF  NOT l_enrp_sua_trans_status THEN
                        IF NOT l_error_occured THEN
                            l_error_occured := TRUE;
                            IF p_uoo_ids_having_errors IS NULL THEN
                               p_uoo_ids_having_errors := l_uooid;
                            ELSE
                               p_uoo_ids_having_errors := p_uoo_ids_having_errors ||','||l_uooid;
                            END IF;
                            FND_MESSAGE.SET_NAME('IGS','IGS_EN_WARN_UNIT_TRN');
                            FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_dtls_rec.unit_cd);
                            FND_MESSAGE.SET_TOKEN('LOCATION_CD',l_unit_dtls_rec.location_cd);
                            FND_MESSAGE.SET_TOKEN('SECTION',l_unit_dtls_rec.unit_class);
                            FND_MESSAGE.SET_TOKEN('TEACH_CAL_DESC',l_teach_cal_desc);
                            FND_MSG_PUB.ADD;
                         END IF;-- end of NOT l_error_occured IF THEN
                         FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
                         FND_MSG_PUB.ADD;

                    -- if IGS_EN_VAL_SCT.enrp_val_sua_trnsfr validation passed then proceed
                    ELSE
                       -- for completed and discontinued unit attempts perform the 2 validations
                       IF l_unit_dtls_rec.unit_attempt_status IN ('COMPLETED','DISCONTIN') THEN
                            -- if unit attempt is failed then show a warning to the user and proceed
                            IF  l_unit_outcome = 'FAIL' AND p_show_warning = 'Y' THEN
                                  IF NOT l_error_occured THEN
                                     l_error_occured := TRUE;
                                    IF p_uoo_ids_having_errors IS NULL THEN
                                       p_uoo_ids_having_errors := l_uooid;
                                    ELSE
                                       p_uoo_ids_having_errors := p_uoo_ids_having_errors ||','||l_uooid;
                                    END IF;
                                    FND_MESSAGE.SET_NAME('IGS','IGS_EN_WARN_UNIT_TRN');
                                    FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_dtls_rec.unit_cd);
                                    FND_MESSAGE.SET_TOKEN('LOCATION_CD',l_unit_dtls_rec.location_cd);
                                    FND_MESSAGE.SET_TOKEN('SECTION',l_unit_dtls_rec.unit_class);
                                    FND_MESSAGE.SET_TOKEN('TEACH_CAL_DESC',l_teach_cal_desc);
                                    FND_MSG_PUB.ADD;
                                  END IF;-- end of NOT l_error_occured IF THEN
                                  FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_UNATT_PROCEED_TRN_UN');
                                  FND_MSG_PUB.ADD;
                            END IF;

                       END IF; -- end of  ('COMPLETED','DISCONTIN')


                       IF l_proceed_aftr_res_val THEN

                              --- continue Logic
                               -- if enrolled unit attempt belongs to a past term then show warning that it will not be transfered
                               -- but will be dropped from source.
                               -- donot transfer enrolled/invalid/waitlisted unit attempts belonging to a past term
                               -- compared to the effective term
                               IF l_unit_dtls_rec.unit_attempt_status  IN ( cst_enrolled,cst_invalid,cst_waitlist ) AND
                                    NOT igs_en_gen_010.unit_effect_or_future_term(p_person_id,p_dest_program_cd,l_unit_dtls_rec.uoo_id,p_term_cal_type,p_term_seq_num) THEN
                                                --  skip current unit attempt from transfer
                                                --  show warning when unit attempt is not transfered but will be dropped. i.e in intra career transfer
                                                IF p_show_warning = 'Y' THEN
                                                     FND_MESSAGE.SET_NAME('IGS','IGS_EN_WARN_UNIT_TRN');
                                                     FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_dtls_rec.unit_cd);
                                                     FND_MESSAGE.SET_TOKEN('LOCATION_CD',l_unit_dtls_rec.location_cd);
                                                     FND_MESSAGE.SET_TOKEN('SECTION',l_unit_dtls_rec.unit_class);
                                                     FND_MESSAGE.SET_TOKEN('TEACH_CAL_DESC',l_teach_cal_desc);
                                                     FND_MSG_PUB.ADD;
                                                     -- if intra career transfer, warn that unit will not be transfered and will be dropped from source
                                                     IF is_career_model_enabled AND
                                                     NOT is_tranfer_across_careers(p_source_program_cd,p_source_prog_ver,p_dest_program_cd,p_dest_prog_ver,l_src_crs_type) THEN
                                                        FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_PAST_UNT_NOTTRN_DRP');
                                                        FND_MSG_PUB.ADD;
                                                     -- if program mode or inter career transfer then warn that unit will not be transfered
                                                     ELSE
                                                        FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_PAST_UNT_NOTTRN');
                                                        FND_MSG_PUB.ADD;
                                                     END IF;
                                                END IF;
                               ELSE
                                   -- create unit transfer record with the same transfer date as the parent program transfer record
                                   -- smaddali modified the logic to create unit transfer records for bug#4063726
                                      l_sut_status := IGS_EN_GEN_010.ENRP_INS_SUT_TRNSFR(p_person_id,
                                                                                         p_dest_program_cd,
                                                                                         p_source_program_cd,
                                                                                         p_trans_actual_dt,
                                                                                         l_unit_dtls_rec.unit_cd ,
                                                                                         l_unit_dtls_rec.cal_type,
                                                                                         l_unit_dtls_rec.ci_sequence_number,
                                                                                         l_message_name,
                                                                                         l_uooid);

                                       -- these uoo_id string will be used only in validate_prgm_attend_type_step procedure and not anywhere else
                                       -- this is to not validate program steps for units which were selected but not tranfered successfully
                                       IF p_uoo_ids_passed_transfer IS NULL THEN
                                         p_uoo_ids_passed_transfer := l_uooid;
                                       ELSE
                                         p_uoo_ids_passed_transfer := p_uoo_ids_passed_transfer ||','|| l_uooid ;
                                       END IF;

                                       -- checking for unit exclusions before transferring.
                                      IF enrp_val_excld_unit_pt (
                                                                p_person_id,
                                                                p_dest_program_cd,
                                                                l_unit_dtls_rec.unit_cd,
                                                                SYSDATE,
                                                                l_message_name) = FALSE THEN
                                         IF  p_show_warning = 'Y' THEN
                                               IF NOT l_error_occured THEN
                                                  l_error_occured := TRUE;
                                                 IF p_uoo_ids_having_errors IS NULL THEN
                                                    p_uoo_ids_having_errors := l_uooid;
                                                 ELSE
                                                    p_uoo_ids_having_errors := p_uoo_ids_having_errors ||','||l_uooid;
                                                 END IF;
                                                 FND_MESSAGE.SET_NAME('IGS','IGS_EN_WARN_UNIT_TRN');
                                                 FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_dtls_rec.unit_cd);
                                                 FND_MESSAGE.SET_TOKEN('LOCATION_CD',l_unit_dtls_rec.location_cd);
                                                 FND_MESSAGE.SET_TOKEN('SECTION',l_unit_dtls_rec.unit_class);
                                                 FND_MESSAGE.SET_TOKEN('TEACH_CAL_DESC',l_teach_cal_desc);
                                                 FND_MSG_PUB.ADD;
                                               END IF;-- end of NOT l_error_occured IF THEN
                                               FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
                                               FND_MSG_PUB.ADD;
                                               FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_PERS_ENCUMB_SYS');
                                               FND_MSG_PUB.ADD;

                                         END IF;

                                      END IF;


                                       -- calling API to Perform actual unit of Transfer from src to dest Prgm
                                       l_sua_trans_status := igs_en_gen_010.enrp_Ins_Sua_Trnsfr(p_person_id,
                                                                                                p_source_program_cd,
                                                                                                p_dest_program_cd,
                                                                                                p_dest_coo_id,
                                                                                                l_unit_dtls_rec.unit_cd,
                                                                                                l_unit_dtls_rec.version_number,
                                                                                                l_unit_dtls_rec.cal_type,
                                                                                                l_unit_dtls_rec.ci_sequence_number,
                                                                                                l_return_type,
                                                                                                l_message_name,
                                                                                                l_uooid,
                                                                                                l_coreind,
                                                                                                p_term_cal_type,
                                                                                                p_term_seq_num);

                                       IF NOT l_sua_trans_status THEN
                                               -- if transfer of unit failed then show warning and skip current unit attempt
                                                IF p_show_warning = 'Y' THEN
                                                     IF NOT l_error_occured THEN
                                                           l_error_occured := TRUE;
                                                           IF p_uoo_ids_having_errors IS NULL THEN
                                                              p_uoo_ids_having_errors := l_uooid;
                                                           ELSE
                                                              p_uoo_ids_having_errors := p_uoo_ids_having_errors ||','||l_uooid;
                                                           END IF;
                                                           FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERR_UNIT_TRN');
                                                           FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_dtls_rec.unit_cd);
                                                           FND_MESSAGE.SET_TOKEN('LOCATION_CD',l_unit_dtls_rec.location_cd);
                                                           FND_MESSAGE.SET_TOKEN('SECTION',l_unit_dtls_rec.unit_class);
                                                           FND_MESSAGE.SET_TOKEN('TEACH_CAL_DESC',l_teach_cal_desc);
                                                           FND_MSG_PUB.ADD;
                                                     END IF;-- end of NOT l_error_occured IF THEN
                                                     FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
                                                     FND_MSG_PUB.ADD;
                                                     p_return_status := FND_API.G_RET_STS_ERROR;
                                                END IF;
                                                IF p_show_warning = 'N' THEN
                                                   IF NOT l_error_occured THEN
                                                           l_error_occured := TRUE;
                                                       IF p_uoo_ids_having_errors IS NULL THEN
                                                          p_uoo_ids_having_errors := l_uooid;
                                                       ELSE
                                                          p_uoo_ids_having_errors := p_uoo_ids_having_errors ||','||l_uooid;
                                                       END IF;
                                                       FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERR_UNIT_TRN');
                                                       FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_dtls_rec.unit_cd);
                                                       FND_MESSAGE.SET_TOKEN('LOCATION_CD',l_unit_dtls_rec.location_cd);
                                                       FND_MESSAGE.SET_TOKEN('SECTION',l_unit_dtls_rec.unit_class);
                                                       FND_MESSAGE.SET_TOKEN('TEACH_CAL_DESC',l_teach_cal_desc);
                                                       FND_MSG_PUB.ADD;
                                                   END IF;-- end of NOT l_error_occured IF THEN
                                                   FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
                                                   FND_MSG_PUB.ADD;
                                                   RAISE FND_API.G_EXC_ERROR;
                                             END IF;

                                       ELSE -- if l_sua_trans_status THEN


                                         l_sua_confrm_status :=  IGS_EN_VAL_SUA.enrp_val_sua_cnfrm_p (p_person_id,
                                                                                                      p_dest_program_cd,
                                                                                                      p_dest_prog_ver,
                                                                                                      p_dest_coo_id,
                                                                                                      p_acad_cal_type,
                                                                                                      p_acad_seq_num,
                                                                                                      l_uooid,
                                                                                                      l_fail_type,
                                                                                                      l_message_name1,
                                                                                                      l_message_name2);

                                          IF NOT l_sua_confrm_status THEN

                                                 ROLLBACK TO SP_TRANSFER_SUA;
                                                 IF  p_show_warning = 'Y' THEN
                                                     IF NOT l_error_occured THEN
                                                           l_error_occured := TRUE;
                                                           IF p_uoo_ids_having_errors IS NULL THEN
                                                              p_uoo_ids_having_errors := l_uooid;
                                                           ELSE
                                                               p_uoo_ids_having_errors := p_uoo_ids_having_errors ||','||l_uooid;
                                                           END IF;
                                                           FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERR_UNIT_TRN');
                                                           FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_dtls_rec.unit_cd);
                                                           FND_MESSAGE.SET_TOKEN('LOCATION_CD',l_unit_dtls_rec.location_cd);
                                                           FND_MESSAGE.SET_TOKEN('SECTION',l_unit_dtls_rec.unit_class);
                                                           FND_MESSAGE.SET_TOKEN('TEACH_CAL_DESC',l_teach_cal_desc);
                                                           FND_MSG_PUB.ADD;
                                                     END IF;-- end of NOT l_error_occured IF THEN
                                                     FND_MESSAGE.SET_NAME( 'IGS' ,nvl(l_message_name1,l_message_name2));
                                                     FND_MSG_PUB.ADD;
                                                     p_return_status := FND_API.G_RET_STS_ERROR;
                                                 ELSIF p_show_warning = 'N' THEN
                                                     IF NOT l_error_occured THEN
                                                           l_error_occured := TRUE;
                                                           IF p_uoo_ids_having_errors IS NULL THEN
                                                              p_uoo_ids_having_errors := l_uooid;
                                                           ELSE
                                                               p_uoo_ids_having_errors := p_uoo_ids_having_errors ||','||l_uooid;
                                                           END IF;
                                                           FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERR_UNIT_TRN');
                                                           FND_MESSAGE.SET_TOKEN('UNIT_CD',l_unit_dtls_rec.unit_cd);
                                                           FND_MESSAGE.SET_TOKEN('LOCATION_CD',l_unit_dtls_rec.location_cd);
                                                           FND_MESSAGE.SET_TOKEN('SECTION',l_unit_dtls_rec.unit_class);
                                                           FND_MESSAGE.SET_TOKEN('TEACH_CAL_DESC',l_teach_cal_desc);
                                                           FND_MSG_PUB.ADD;
                                                     END IF;-- end of NOT l_error_occured IF THEN
                                                     FND_MESSAGE.SET_NAME( 'IGS' ,nvl(l_message_name1,l_message_name2));
                                                     FND_MSG_PUB.ADD;
                                                     RAISE FND_API.G_EXC_ERROR;
                                                 END IF; -- end of  p_show_warning = 'Y'

                                          END IF; -- end of  NOT l_sua_confrm_status IF THEN

                                       END IF; --end of l_sua_trans_status IF THEN
                            END IF; -- end of enrolled unit in past term

                        END IF; -- end of l_proceed_aftr_res_val IF THEN

                  END IF; -- end of l_is_val_sua_trans IF THEN

              END IF ; -- end of NOT is_unit_rel_dest_acad_cal
              l_nth_occurence := l_nth_occurence + 1;
              l_cindex := INSTR(l_uoo_ids_to_transfer,';',1,l_nth_occurence);

        END LOOP;-- end of WHILE LOOP

        -- p_uoo_ids_string consists of concatenated uoo_ids  seperated by comma
        p_uooids_str := l_uooids_str;

        -- Listing all Enrolled/Waitlisted units that need to be droped that are present in Source but not
        -- in Destination
        getunits_in_src_notin_dest_prg(p_person_id,
                                   p_source_program_cd,
                                   p_dest_program_cd,
                                   l_uooids_str,
                                   p_drop,
                                   p_show_warning);
        val_unchk_sub_units(p_person_id,
                                   p_source_program_cd,
                                   l_uooids_str,  -- add subordinate units also when superior is selected.
                                   p_drop,
                                   p_show_warning);

        l_del_all_sua_status :=   IGS_EN_GEN_010.Enrp_del_all_Sua_Trnsfr(p_person_id,
                                                                         p_source_program_cd,
                                                                         p_dest_program_cd,
                                                                         l_uooids_str,
                                                                         p_term_cal_type,
                                                                         p_term_seq_num,
                                                                         p_drop,
                                                                         l_message_name3);

        IF  l_del_all_sua_status =  FALSE THEN
            IF p_show_warning = 'Y' THEN
               FND_MESSAGE.SET_NAME( 'IGS' , l_message_name3);
               FND_MSG_PUB.ADD;
               p_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            IF p_show_warning = 'N' THEN
               FND_MESSAGE.SET_NAME( 'IGS' , l_message_name3);
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF; -- end of  l_del_all_sua_status =  FALSE



      EXCEPTION
         WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
              RAISE;
         WHEN FND_API.G_EXC_ERROR THEN
              RAISE;
         WHEN OTHERS THEN
              Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.validate_src_prgm_unt_attempts');
              IGS_GE_MSG_STACK.ADD;
              IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.validate_src_prgm_unt_attempts :',SQLERRM);
              END IF;
              App_Exception.Raise_Exception;

   END validate_src_prgm_unt_attempts;


   PROCEDURE validate_prgm_attend_type_step(
      p_person_id               IN   NUMBER,
      p_dest_program_cd         IN   VARCHAR2,
      p_uooids_str              IN   VARCHAR2,
      p_show_warning            IN   VARCHAR2,
      p_return_status           IN OUT NOCOPY  VARCHAR2
   ) AS
  -------------------------------------------------------------------------------------------
  -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure validates attendance Type validation for the destination program.
  --Change History:
  --Who         When            What
  -- ckasu     06-MAR-2006     added new cursor c_get_enr_method_type as a part of bug#5070732
  -- ckasu created this procedure for bug#4063726
  -------------------------------------------------------------------------------------------

     CURSOR c_get_unit_dtls(cp_uoo_id IGS_EN_SU_ATTEMPT.UOO_ID%TYPE) IS
        SELECT cal_type,ci_sequence_number
        FROM IGS_PS_UNIT_OFR_OPT
        WHERE uoo_id = cp_uoo_id;

     CURSOR c_get_earliest_load_cal_dtls(cp_teach_cal_type IGS_CA_TEACH_TO_LOAD_V.TEACH_CAL_TYPE%TYPE,
                                         cp_teach_cal_seq_no IGS_CA_TEACH_TO_LOAD_V.TEACH_CI_SEQUENCE_NUMBER%TYPE) IS

        SELECT load_cal_type,load_ci_sequence_number
        FROM IGS_CA_TEACH_TO_LOAD_V
        WHERE teach_cal_type = cp_teach_cal_type AND
              teach_ci_sequence_number = cp_teach_cal_seq_no
        ORDER BY LOAD_START_DT;

     -- added by ckasu as a part of bug#5070732
     CURSOR c_get_enr_method_type IS
     SELECT enr_method_type
     FROM  IGS_EN_METHOD_TYPE
     WHERE transfer_flag = 'Y'
     AND   closed_ind ='N';


     l_strtpoint NUMBER;
     l_endpoint  NUMBER;
     l_cindex    NUMBER;
     l_pre_cindex NUMBER;
     l_nth_occurence NUMBER;
     l_uooid      NUMBER;
     l_uooids_str VARCHAR2(1000);
     l_cal_type   IGS_PS_UNIT_OFR_OPT.CAL_TYPE%TYPE;
     l_ci_sequence_number  IGS_PS_UNIT_OFR_OPT.CI_SEQUENCE_NUMBER%TYPE;
     l_load_cal_type IGS_CA_TEACH_TO_LOAD_V.LOAD_CAL_TYPE%TYPE;
     l_load_ci_sequence_number  IGS_CA_TEACH_TO_LOAD_V.LOAD_CI_SEQUENCE_NUMBER%TYPE;

     l_enr_method  igs_en_cat_prc_dtl.enr_method_type%TYPE;
     l_message_name1    VARCHAR2(4000);
     l_message_name2    VARCHAR2(4000);
     l_deny_warn        VARCHAR2(10);
     l_return_status    VARCHAR2(30);




     BEGIN

        l_strtpoint      :=  0;
        l_pre_cindex     :=  0;
        l_nth_occurence  :=  1;
        l_uooids_str := p_uooids_str||',';
        l_cindex := INSTR(l_uooids_str,',',1,l_nth_occurence);

        OPEN c_get_enr_method_type;
        FETCH c_get_enr_method_type INTO l_enr_method;
        CLOSE c_get_enr_method_type;


        WHILE (l_cindex <> 0 )  LOOP

              l_strtpoint  :=  l_pre_cindex + 1;
              l_endpoint   :=  l_cindex - l_strtpoint;
              l_pre_cindex :=  l_cindex;
              l_uooid := TO_NUMBER(substr(l_uooids_str,l_strtpoint,l_endpoint));
              l_message_name2 := NULL;
              l_deny_warn     := NULL;
              l_return_status := NULL;
              l_cal_type      := NULL;
              l_ci_sequence_number := NULL;
              l_load_cal_type := NULL;
              l_load_ci_sequence_number := NULL;

              OPEN c_get_unit_dtls(l_uooid);
              FETCH  c_get_unit_dtls INTO l_cal_type,l_ci_sequence_number;
              CLOSE c_get_unit_dtls;

              OPEN c_get_earliest_load_cal_dtls(l_cal_type,l_ci_sequence_number);
              FETCH c_get_earliest_load_cal_dtls INTO l_load_cal_type,l_load_ci_sequence_number;
              CLOSE c_get_earliest_load_cal_dtls;
              -- check for Max cp by passing the null value to credit points
              --so that the default calculation are done for the CP of this unit section
              igs_en_enroll_wlst.ss_eval_min_or_max_cp(p_person_id               => p_person_id,
                                                       p_load_cal_type           => l_load_cal_type,
                                                       p_load_ci_sequence_number => l_load_ci_sequence_number,
                                                       p_uoo_id                  => l_uooid,
                                                       p_program_cd              => p_dest_program_cd,
                                                       p_step_type               => 'FMAX_CRDT',
                                                       p_credit_points           => NULL, -- deliberately passing null, this value will be internally calculated
                                                       p_message_name            => l_message_name2,
                                                       p_deny_warn               => l_deny_warn,
                                                       p_return_status           => l_return_status,
                                                       p_enr_method              => l_enr_method);


            IF l_return_status = 'FALSE' AND l_deny_warn = 'WARN' THEN

              IF l_message_name2 IS NOT NULL AND  p_show_warning = 'Y' THEN
                 FND_MESSAGE.SET_NAME( 'IGS' , l_message_name2);
                 FND_MSG_PUB.ADD;
              END IF;

            END IF; -- show warning message when rule failed in warn


            IF l_return_status = 'FALSE' AND l_deny_warn = 'DENY' THEN

              IF l_message_name2 IS NOT NULL AND  p_show_warning = 'Y' THEN
                 FND_MESSAGE.SET_NAME( 'IGS' , l_message_name2);
                 FND_MSG_PUB.ADD;
                 p_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              IF l_message_name2 IS NOT NULL AND  p_show_warning = 'N' THEN
                 FND_MESSAGE.SET_NAME( 'IGS' , l_message_name2);
                 FND_MSG_PUB.ADD;
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

            END IF; -- show warning/error message when rule failed in deny

            l_nth_occurence := l_nth_occurence + 1;
            l_cindex := INSTR(l_uooids_str,',',1,l_nth_occurence);

        END LOOP;-- end of WHILE LOOP for Max Cp Validation

        -- Validation for Min CP
        l_strtpoint      :=  0;
        l_pre_cindex     :=  0;
        l_nth_occurence  :=  1;
        l_cindex := INSTR(l_uooids_str,',',1,l_nth_occurence);

        WHILE (l_cindex <> 0 )  LOOP

              l_strtpoint  :=  l_pre_cindex + 1;
              l_endpoint   :=  l_cindex - l_strtpoint;
              l_pre_cindex :=  l_cindex;
              l_uooid := TO_NUMBER(substr(l_uooids_str,l_strtpoint,l_endpoint));
              l_message_name2 := NULL;
              l_deny_warn     := NULL;
              l_return_status := NULL;
              l_cal_type      := NULL;
              l_ci_sequence_number := NULL;
              l_load_cal_type := NULL;
              l_load_ci_sequence_number := NULL;

              OPEN c_get_unit_dtls(l_uooid);
              FETCH  c_get_unit_dtls INTO l_cal_type,l_ci_sequence_number;
              CLOSE c_get_unit_dtls;

              OPEN c_get_earliest_load_cal_dtls(l_cal_type,l_ci_sequence_number);
              FETCH c_get_earliest_load_cal_dtls INTO l_load_cal_type,l_load_ci_sequence_number;
              CLOSE c_get_earliest_load_cal_dtls;
               -- call the procedure to evaluate the Min CP by passing ZERO to the
               -- credit points parameter
              igs_en_enroll_wlst.ss_eval_min_or_max_cp(p_person_id               => p_person_id,
                                                       p_load_cal_type           => l_load_cal_type,
                                                       p_load_ci_sequence_number => l_load_ci_sequence_number,
                                                       p_uoo_id                  => l_uooid,
                                                       p_program_cd              => p_dest_program_cd,
                                                       p_step_type               => 'FMIN_CRDT',
                                                       p_credit_points           => 0.0, -- deliberately passing null, this value will be internally calculated
                                                       p_message_name            => l_message_name2,
                                                       p_deny_warn               => l_deny_warn,
                                                       p_return_status           => l_return_status,
                                                       p_enr_method              => l_enr_method);


            IF l_return_status = 'FALSE' AND l_deny_warn = 'WARN' THEN

              IF l_message_name2 IS NOT NULL AND  p_show_warning = 'Y' THEN
                 FND_MESSAGE.SET_NAME( 'IGS' , l_message_name2);
                 FND_MSG_PUB.ADD;
              END IF;

            END IF; -- end of  l_return_status = 'FALSE' AND l_deny_warn = 'WARN'  IF THEN

            IF l_return_status = 'FALSE' AND l_deny_warn = 'DENY' THEN

              IF l_message_name2 IS NOT NULL AND  p_show_warning = 'Y' THEN
                 FND_MESSAGE.SET_NAME( 'IGS' , l_message_name2);
                 FND_MSG_PUB.ADD;
                 p_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              IF l_message_name2 IS NOT NULL AND  p_show_warning = 'N' THEN
                 FND_MESSAGE.SET_NAME( 'IGS' , l_message_name2);
                 FND_MSG_PUB.ADD;
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

            END IF; -- end of  l_return_status = 'FALSE' AND l_deny_warn = 'DENY'  IF THEN


            l_nth_occurence := l_nth_occurence + 1;
            l_cindex := INSTR(l_uooids_str,',',1,l_nth_occurence);

        END LOOP;-- end of WHILE LOOP for Min Cp Validation

        -- Evaluating all person steps except Min cp and Max cp
        l_strtpoint      :=  0;
        l_pre_cindex     :=  0;
        l_nth_occurence  :=  1;
        l_cindex := INSTR(l_uooids_str,',',1,l_nth_occurence);

        WHILE (l_cindex <> 0 )  LOOP

              l_strtpoint  :=  l_pre_cindex + 1;
              l_endpoint   :=  l_cindex - l_strtpoint;
              l_pre_cindex :=  l_cindex;
              l_uooid := TO_NUMBER(substr(l_uooids_str,l_strtpoint,l_endpoint));
              l_message_name2 := NULL;
              l_deny_warn     := NULL;
              l_return_status := NULL;
              l_cal_type      := NULL;
              l_ci_sequence_number := NULL;
              l_load_cal_type := NULL;
              l_load_ci_sequence_number := NULL;


              OPEN c_get_unit_dtls(l_uooid);
              FETCH  c_get_unit_dtls INTO l_cal_type,l_ci_sequence_number;
              CLOSE c_get_unit_dtls;

              OPEN c_get_earliest_load_cal_dtls(l_cal_type,l_ci_sequence_number);
              FETCH c_get_earliest_load_cal_dtls INTO l_load_cal_type,l_load_ci_sequence_number;
              CLOSE c_get_earliest_load_cal_dtls;
               -- call the procedure to evaluate the Min CP by passing ZERO to the
               -- credit points parameter
              IF igs_en_enroll_wlst.validate_prog (
                                         p_person_id          => p_person_id,
                                         p_cal_type           => l_load_cal_type,
                                         p_ci_sequence_number => l_load_ci_sequence_number,
                                         p_uoo_id             => l_uooid,
                                         p_course_cd          => p_dest_program_cd,
                                         p_enr_method_type    => l_enr_method,
                                         p_message_name       => l_message_name2,
                                         p_deny_warn          => l_deny_warn) THEN
                 l_return_status := 'TRUE';
              ELSE
                 l_return_status := 'FALSE';
              END IF;

             IF l_return_status = 'FALSE' AND l_deny_warn = 'WARN' THEN

              IF l_message_name2 IS NOT NULL AND  p_show_warning = 'Y' THEN
                 -- l_message_name2 contains appended message names, hence parse and add to fnd_message pub
                 parse_messages( l_message_name2);
              END IF;

             END IF; -- end of  l_return_status = 'FALSE' AND l_deny_warn = 'WARN'  IF THEN



             IF l_return_status = 'FALSE' AND l_deny_warn = 'DENY' THEN

              IF l_message_name2 IS NOT NULL AND  p_show_warning = 'Y' THEN
                 -- l_message_name2 contains appended message names, hence parse and add to fnd_message pub
                 parse_messages( l_message_name2);
                 p_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              IF l_message_name2 IS NOT NULL AND  p_show_warning = 'N' THEN
                 -- l_message_name2 contains appended message names, hence parse and add to fnd_message pub
                 parse_messages( l_message_name2);
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

             END IF; -- end of  l_return_status = 'FALSE' AND l_deny_warn = 'DENY'  IF THEN

            l_nth_occurence := l_nth_occurence + 1;
            l_cindex := INSTR(l_uooids_str,',',1,l_nth_occurence);

        END LOOP;-- end of WHILE LOOP for Min Cp Validation



    EXCEPTION
         WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
              RAISE;
         WHEN FND_API.G_EXC_ERROR THEN
              RAISE;
         WHEN OTHERS THEN
              Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.validate_prgm_attend_type_step');
              IGS_GE_MSG_STACK.ADD;
              IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.validate_prgm_attend_type_step :',SQLERRM);
              END IF;
              App_Exception.Raise_Exception;
   END validate_prgm_attend_type_step;

   PROCEDURE validate_src_prgm_unt_set_att(
      p_person_id               IN   NUMBER,
      p_source_program_cd       IN   VARCHAR2,
      p_source_prog_ver         IN   NUMBER,
      p_term_cal_type           IN   VARCHAR2,
      p_term_seq_num            IN   NUMBER,
      p_acad_cal_type           IN   VARCHAR2,
      p_acad_seq_num            IN   NUMBER,
      p_trans_approval_dt       IN   DATE,
      p_dest_program_cd         IN   VARCHAR2,
      p_dest_prog_ver           IN   NUMBER,
      p_dest_coo_id             IN   NUMBER,
      p_unit_sets_to_transfer   IN   VARCHAR2,
      p_unit_sets_not_selected  IN   VARCHAR2,
      p_unit_sets_having_errors OUT NOCOPY  VARCHAR2,
      p_show_warning            IN   VARCHAR2,
      p_return_status           IN OUT NOCOPY  VARCHAR2
   ) AS
  -------------------------------------------------------------------------------------------
  -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure validates and transfers the unitsets againts the source program
  --           to the destination program.
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

       l_strtpoint NUMBER;
       l_endpoint  NUMBER;
       l_cindex    NUMBER;
       l_pre_cindex NUMBER;
       l_nth_occurence NUMBER;
       l_unitset_seqno_sep_index NUMBER;
       l_seqno_prmind_sep_index NUMBER;
       l_unitset_seqno_and_prmind VARCHAR2(300);
       l_unitset  VARCHAR2(50);
       l_seqno  NUMBER;
       l_prmind VARCHAR2(3);
       l_unitsets_to_transfer VARCHAR2(3000);
       l_unitset_append_count NUMBER;

       l_unitset_att_exists   BOOLEAN;
       l_val_susa_status      BOOLEAN;
       l_message_name         FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
       l_message_name1         FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
       l_message_name2         FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
       l_message_name3         FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
       l_message_name4         FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
       l_message_text         VARCHAR2(1000);
       l_val_susa_tran        BOOLEAN;
       l_susa_cousr_status    BOOLEAN;
       l_status               BOOLEAN;
       l_status1               BOOLEAN;
       l_status2               BOOLEAN;
       l_error_occured BOOLEAN;
       CURSOR c_get_dest_unitset_att (c_person_id     IN     IGS_AS_SU_SETATMPT.person_id%TYPE,
                                      c_course_cd     IN     IGS_AS_SU_SETATMPT.course_cd%TYPE,
                                      c_unit_set_cd   IN     IGS_AS_SU_SETATMPT.unit_set_cd%TYPE) IS
           SELECT *
           FROM   IGS_AS_SU_SETATMPT
           WHERE  person_id = c_person_id   AND
                  course_cd = c_course_cd   AND
                  unit_set_cd = c_unit_set_cd;
       CURSOR c_get_unitset_att ( c_person_id         IN     IGS_AS_SU_SETATMPT.person_id%TYPE,
                                  c_course_cd         IN     IGS_AS_SU_SETATMPT.course_cd%TYPE,
                                  c_unit_set_cd       IN     IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
                                  c_sequence_number   IN     IGS_AS_SU_SETATMPT.sequence_number%TYPE) IS
           SELECT *
           FROM   IGS_AS_SU_SETATMPT
           WHERE  person_id = c_person_id   AND
                  course_cd = c_course_cd   AND
                  unit_set_cd = c_unit_set_cd AND
                  sequence_number = c_sequence_number ;
       l_dest_unitset_att_rec c_get_dest_unitset_att%ROWTYPE;
       l_unitset_att_rec      c_get_unitset_att%ROWTYPE;

  BEGIN

        l_strtpoint      :=  0;
        l_pre_cindex     :=  0;
        l_nth_occurence  :=  1;
        l_unitset_append_count := 1;
        l_unitsets_to_transfer := p_unit_sets_to_transfer ;
        l_cindex := INSTR(l_unitsets_to_transfer,';',1,l_nth_occurence);
        p_unit_sets_having_errors := null;

        WHILE (l_cindex <> 0 )  LOOP
              l_error_occured := FALSE;
              l_strtpoint  :=  l_pre_cindex + 1;
              l_endpoint   :=  l_cindex - l_strtpoint;
              l_pre_cindex :=  l_cindex;
              l_unitset_seqno_and_prmind := substr(l_unitsets_to_transfer,l_strtpoint,l_endpoint);
              l_unitset_seqno_sep_index  := INSTR(l_unitset_seqno_and_prmind,',',1);
              l_seqno_prmind_sep_index   := INSTR(l_unitset_seqno_and_prmind,',',1,2);
              l_unitset   :=   SUBSTR(l_unitset_seqno_and_prmind,1,l_unitset_seqno_sep_index - 1);
              l_seqno     :=   TO_NUMBER(SUBSTR(l_unitset_seqno_and_prmind,l_unitset_seqno_sep_index+1,l_seqno_prmind_sep_index -(l_unitset_seqno_sep_index+1)));
              l_prmind    :=   SUBSTR(l_unitset_seqno_and_prmind,l_seqno_prmind_sep_index + 1);
              l_unitset_att_exists := FALSE;
              l_val_susa_tran  := TRUE;

              OPEN c_get_dest_unitset_att(p_person_id,p_dest_program_cd,l_unitset);
              FETCH c_get_dest_unitset_att INTO l_dest_unitset_att_rec;
              IF (c_get_dest_unitset_att%FOUND) THEN
               CLOSE c_get_dest_unitset_att;
               l_unitset_att_exists := TRUE;
              ELSE
               CLOSE c_get_dest_unitset_att;
              END IF;

              IF NOT l_unitset_att_exists THEN
                 OPEN c_get_unitset_att(p_person_id,p_source_program_cd,l_unitset,l_seqno);
                 FETCH c_get_unitset_att INTO l_unitset_att_rec;
                 CLOSE c_get_unitset_att;
                 l_val_susa_status := IGS_EN_VAL_SUSA.ENRP_VAL_SUSA( p_person_id,
                                                                     p_dest_program_cd ,
                                                                     l_unitset,
                                                                     l_unitset_att_rec.sequence_number  ,
                                                                     l_unitset_att_rec.us_version_number ,
                                                                     l_unitset_att_rec.selection_dt ,
                                                                     l_unitset_att_rec.student_confirmed_ind ,
                                                                     l_unitset_att_rec.end_dt ,
                                                                     l_unitset_att_rec.parent_unit_set_cd ,
                                                                     l_unitset_att_rec.parent_sequence_number ,
                                                                     l_unitset_att_rec.primary_set_ind ,
                                                                     l_unitset_att_rec.voluntary_end_ind,
                                                                     l_unitset_att_rec.authorised_person_id ,
                                                                     l_unitset_att_rec.authorised_on,
                                                                     l_unitset_att_rec.override_title,
                                                                     l_unitset_att_rec.rqrmnts_complete_ind,
                                                                     l_unitset_att_rec.rqrmnts_complete_dt,
                                                                     l_unitset_att_rec.s_completed_source_type,
                                                                     'INSERT',
                                                                     l_message_name,
                                                                     l_message_text);

               IF  ( l_val_susa_status = FALSE AND  l_message_name IS NOT NULL ) THEN

                     IF l_message_name IN ('IGS_EN_UNIT_SET_PARENT_UNITSE',
                                           'IGS_EN_UNIT_SET_RELATIONSHIP','IGS_EN_UNITSET_HAVE_ONE_PAREN',
                                           'IGS_EN_UNIT_SET_NOTBE_PARENT','IGS_EN_UNIT_SET_NOT_ENDDT',
                                           'IGS_EN_INVALID_RELATIONSHIP','IGS_EN_UNIT_SET_PARENTSET_CON') THEN
                                   null;
                     ELSIF (p_show_warning = 'N' ) THEN
                            IF l_unitset_append_count = 1 THEN
                               p_unit_sets_having_errors := l_unitset_seqno_and_prmind || ';' ;
                            ELSE
                               p_unit_sets_having_errors := p_unit_sets_having_errors || l_unitset_seqno_and_prmind || ';' ;
                            END IF;
                            l_unitset_append_count := l_unitset_append_count + 1;
                            FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERR_US_TRN');
                            FND_MESSAGE.SET_TOKEN('UNIT_SET_CD',l_unitset);
                            FND_MESSAGE.SET_TOKEN('US_VERSION_NUMBER',l_unitset_att_rec.us_version_number);
                            FND_MSG_PUB.ADD;
                            FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
                            FND_MSG_PUB.ADD;
                            RAISE FND_API.G_EXC_ERROR;
                     ELSIF (p_show_warning = 'Y' ) THEN
                        -- if error occured for the first time for this unit set then log the heading and
                        -- increment the count and append to out param. Ignore this logic when further errors occur
                        IF NOT l_error_occured THEN
                            l_error_occured := TRUE;
                            IF l_unitset_append_count = 1 THEN
                               p_unit_sets_having_errors := l_unitset_seqno_and_prmind || ';' ;
                            ELSE
                               p_unit_sets_having_errors := p_unit_sets_having_errors || l_unitset_seqno_and_prmind || ';' ;
                            END IF;
                            l_unitset_append_count := l_unitset_append_count + 1;
                            FND_MESSAGE.SET_NAME('IGS','IGS_EN_WARN_US_TRN');
                            FND_MESSAGE.SET_TOKEN('UNIT_SET_CD',l_unitset);
                            FND_MESSAGE.SET_TOKEN('US_VERSION_NUMBER',l_unitset_att_rec.us_version_number);
                            FND_MSG_PUB.ADD;
                        END IF;
                        FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
                        FND_MSG_PUB.ADD;
                        p_return_status := FND_API.G_RET_STS_ERROR;
                        l_val_susa_tran  := FALSE;

                     END IF;-- end of    l_message_name IN IF THEN

                 END IF;--end of l_val_susa_status = FALSE

                 IF l_val_susa_tran THEN
                    IF IGS_EN_GEN_010.ENRP_INS_SUSA_TRNSFR (p_person_id,
                                                            p_source_program_cd,
                                                            p_dest_program_cd,
                                                            l_unitset,
                                                            l_unitset_att_rec.us_version_number,
                                                            l_unitset_att_rec.sequence_number,
                                                            l_unitset_att_rec.primary_set_ind ,
                                                            l_message_name) = FALSE THEN
                        IF l_message_name  IN ('IGS_EN_UNITSET_REQ_AUTHORISAT',
                                               'IGS_EN_UNITSET_HAVE_ONE_PAREN') THEN
                           null;
                        ELSIF  l_message_name IN ('IGS_EN_SUA_SET_ATT_TRNS_EXIST','IGS_GE_INVALID_VALUE','IGS_EN_PRIMARY_INDICATOR_NOT',
                                                 'IGS_EN_PRIMARY_IND_NOT_SET','IGS_EN_UNIT_SET_SPA_ENR_INACT','IGS_EN_UNIT_SET_UNCONF_REQ',
                                                 'IGS_EN_UNIT_SET_UNCONF_ENDDT','IGS_EN_UNIT_SET_PARENTSET_CON','IGS_EN_NOTDEL_UNITSET_COMPL',
                                                 'IGS_EN_UNITSET_REQ_ENDED','IGS_EN_UNIT_SET_NO_OPEN','IGS_EN_UNIT_SET_EXISTS',
                                                 'IGS_EN_INVALID_RELATIONSHIP', 'IGS_EN_UNIT_SET_NOT_ENDDT','IGS_EN_UNIT_SET_NOT_PARENT_EX',
                                                 'IGS_EN_UNIT_SET_NOTBE_PARENT', 'IGS_EN_UNIT_SET_PARENT_UNITSE','IGS_EN_UNIT_SET_RELATIONSHIP',
                                                 'IGS_EN_UNIT_SETST_ACTIVE', 'IGS_EN_UNIT_SET_EXPDT_NOTSET','IGS_EN_UNIT_SET_REQ_AUTHORISA',
                                                 'IGS_EN_NOTDEL_UNITSET_COND', 'IGS_EN_NOTDEL_UNITSET_PARENT','IGS_EN_NOTDEL_UNITSET_ENDED',
                                                 'IGS_EN_VOLUNTARY_END_INDICATO','IGS_EN_UNIT_SET_UNCONF_SETDT','IGS_EN_UNIT_SET_UNCONF_NOTSET',
                                                 'IGS_EN_ENDDT_NOTBE_EARLIER_DT','IGS_EN_ENDDT_COMPLDT_NOTSET','IGS_EN_SELDT_LE_CURR_DT',
                                                 'IGS_EN_ENDDT_LE_CURR_DT','IGS_EN_COMPLDT_LE_CURR_DT','IGS_EN_COMPLDT_GE_CURR_DT',
                                                 'IGS_EN_SYS_COMPL_SRCTYPE_SET','IGS_EN_COMPL_DT_SET_COMPL_IND','IGS_EN_COMPLDT_NOTBE_SET_COMP',
                                                 'IGS_EN_SU_SET_MUSTBE_CONFIRME','IGS_EN_AUTHORISED_PRSN_NOT','IGS_EN_AUTHDT_AUTHPRSN_SET',
                                                 'IGS_EN_AUTHDT_NOTBE_AUTHPRSN','IGS_EN_AUTHDT_MUSTBE_SET','IGS_EN_UNIT_SETNOT_PERMITTED',
                                                 'IGS_EN_STUD_COMPL_UNITSET','IGS_EN_SUA_NOT_CREATED','IGS_EN_PERS_EXL_ENRL_UNT_SET'
                                                 ,'IGS_EN_PRSN_ENCUMB_REVOKING','IGS_EN_PERS_HAS_ENCUMB') THEN
                                 IF (p_show_warning = 'N' ) THEN
                                     IF l_unitset_append_count = 1 THEN
                                         p_unit_sets_having_errors := l_unitset_seqno_and_prmind || ';' ;
                                      ELSE
                                         p_unit_sets_having_errors := p_unit_sets_having_errors || l_unitset_seqno_and_prmind || ';' ;
                                      END IF;
                                      l_unitset_append_count := l_unitset_append_count + 1;
                                      FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERR_US_TRN');
                                      FND_MESSAGE.SET_TOKEN('UNIT_SET_CD',l_unitset);
                                      FND_MESSAGE.SET_TOKEN('US_VERSION_NUMBER',l_unitset_att_rec.us_version_number);
                                      FND_MSG_PUB.ADD;
                                      FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
                                      FND_MSG_PUB.ADD;
                                      RAISE FND_API.G_EXC_ERROR;
                                 ELSIF (p_show_warning = 'Y' ) THEN
                                    -- if error occured for the first time for this unit set then log the heading and
                                    -- increment the count and append to out param. Ignore this logic when further errors occur
                                    IF NOT l_error_occured THEN
                                      l_error_occured := TRUE;
                                      IF l_unitset_append_count = 1 THEN
                                         p_unit_sets_having_errors := l_unitset_seqno_and_prmind || ';' ;
                                      ELSE
                                         p_unit_sets_having_errors := p_unit_sets_having_errors || l_unitset_seqno_and_prmind || ';' ;
                                      END IF;
                                      l_unitset_append_count := l_unitset_append_count + 1;
                                      FND_MESSAGE.SET_NAME('IGS','IGS_EN_WARN_US_TRN');
                                      FND_MESSAGE.SET_TOKEN('UNIT_SET_CD',l_unitset);
                                      FND_MESSAGE.SET_TOKEN('US_VERSION_NUMBER',l_unitset_att_rec.us_version_number);
                                      FND_MSG_PUB.ADD;
                                    END IF;
                                    FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
                                    FND_MSG_PUB.ADD;
                                    p_return_status := FND_API.G_RET_STS_ERROR;
                                 END IF;-- end of   p_show_warning  = 'N'   IF THEN

                        END IF;-- END OF    l_message_name


                    END IF; -- END OF    IGS_EN_GEN_010.ENRP_INS_SUSA_TRNSFR IF THEN

                    OPEN c_get_dest_unitset_att(p_person_id,p_dest_program_cd,l_unitset);
                    FETCH c_get_dest_unitset_att INTO l_dest_unitset_att_rec;
                    CLOSE c_get_dest_unitset_att;
                    IF (l_dest_unitset_att_rec.primary_set_ind = 'Y') THEN
                        l_susa_cousr_status := IGS_EN_VAL_SUSA.enrp_val_susa_cousr(p_person_id,
                                                                                    p_dest_program_cd,
                                                                                    l_unitset,
                                                                                    l_dest_unitset_att_rec.us_version_number,
                                                                                    l_dest_unitset_att_rec.parent_unit_set_cd,
                                                                                    l_dest_unitset_att_rec.parent_sequence_number,
                                                                                    'E',
                                                                                    l_message_name1,
                                                                                    'Y');
                         IF (l_susa_cousr_status = FALSE ) THEN
                             l_status := IGS_EN_GEN_001.ENRP_DEL_SUSA_TRNSFR(p_person_id,
                                                                             p_dest_program_cd,
                                                                             l_unitset,
                                                                             l_dest_unitset_att_rec.us_version_number,
                                                                             l_message_name2);
                                IF (p_show_warning = 'N' ) THEN
                                     IF l_unitset_append_count = 1 THEN
                                        p_unit_sets_having_errors := l_unitset_seqno_and_prmind || ';' ;
                                     ELSE
                                        p_unit_sets_having_errors := p_unit_sets_having_errors || l_unitset_seqno_and_prmind || ';' ;
                                     END IF;
                                     l_unitset_append_count := l_unitset_append_count + 1;
                                     FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERR_US_TRN');
                                     FND_MESSAGE.SET_TOKEN('UNIT_SET_CD',l_unitset);
                                     FND_MESSAGE.SET_TOKEN('US_VERSION_NUMBER',l_unitset_att_rec.us_version_number);
                                     FND_MSG_PUB.ADD;
                                     FND_MESSAGE.SET_NAME( 'IGS' , l_message_name1);
                                     FND_MSG_PUB.ADD;
                                     IF l_message_name2 IS NOT NULL THEN
                                        FND_MESSAGE.SET_NAME( 'IGS' , l_message_name2);
                                        FND_MSG_PUB.ADD;
                                     END IF;
                                     RAISE FND_API.G_EXC_ERROR;
                                ELSIF (p_show_warning = 'Y' ) THEN
                                    -- if error occured for the first time for this unit set then log the heading and
                                    -- increment the count and append to out param. Ignore this logic when further errors occur
                                    IF NOT l_error_occured THEN
                                         l_error_occured := TRUE;
                                         IF l_unitset_append_count = 1 THEN
                                            p_unit_sets_having_errors := l_unitset_seqno_and_prmind || ';' ;
                                         ELSE
                                            p_unit_sets_having_errors := p_unit_sets_having_errors || l_unitset_seqno_and_prmind || ';' ;
                                         END IF;
                                         l_unitset_append_count := l_unitset_append_count + 1;
                                         FND_MESSAGE.SET_NAME('IGS','IGS_EN_WARN_US_TRN');
                                         FND_MESSAGE.SET_TOKEN('UNIT_SET_CD',l_unitset);
                                         FND_MESSAGE.SET_TOKEN('US_VERSION_NUMBER',l_unitset_att_rec.us_version_number);
                                         FND_MSG_PUB.ADD;
                                     END IF;
                                     FND_MESSAGE.SET_NAME( 'IGS' , l_message_name1);
                                     FND_MSG_PUB.ADD;
                                     IF l_message_name2 IS NOT NULL THEN
                                        FND_MESSAGE.SET_NAME( 'IGS' , l_message_name2);
                                        FND_MSG_PUB.ADD;
                                     END IF;
                                     p_return_status := FND_API.G_RET_STS_ERROR;
                                END IF;-- end of   p_show_warning  = 'N'   IF THEN

                         ELSIF (l_susa_cousr_status = TRUE ) THEN
                               l_status :=  IGS_EN_VAL_SUSA.enrp_val_susa_parent(p_person_id,
                                                                                 p_dest_program_cd,
                                                                                 l_unitset,
                                                                                 l_dest_unitset_att_rec.sequence_number,
                                                                                 l_dest_unitset_att_rec.parent_unit_set_cd,
                                                                                 l_dest_unitset_att_rec.parent_sequence_number,
                                                                                 l_dest_unitset_att_rec.student_confirmed_ind,
                                                                                 l_message_name3,
                                                                                 'N');
                               IF (l_status = FALSE) THEN
                                   l_status1 := IGS_EN_GEN_001.ENRP_DEL_SUSA_TRNSFR(p_person_id,
                                                                             p_dest_program_cd,
                                                                             l_unitset,
                                                                             l_dest_unitset_att_rec.us_version_number,
                                                                             l_message_name4);

                                       IF (p_show_warning = 'N' ) THEN
                                           IF l_unitset_append_count = 1 THEN
                                              p_unit_sets_having_errors := l_unitset_seqno_and_prmind || ';' ;
                                           ELSE
                                              p_unit_sets_having_errors := p_unit_sets_having_errors || l_unitset_seqno_and_prmind || ';' ;
                                           END IF;
                                           l_unitset_append_count := l_unitset_append_count + 1;
                                           FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERR_US_TRN');
                                           FND_MESSAGE.SET_TOKEN('UNIT_SET_CD',l_unitset);
                                           FND_MESSAGE.SET_TOKEN('US_VERSION_NUMBER',l_unitset_att_rec.us_version_number);
                                           FND_MSG_PUB.ADD;
                                           FND_MESSAGE.SET_NAME( 'IGS' , l_message_name3);
                                           FND_MSG_PUB.ADD;
                                           IF l_message_name2 IS NOT NULL THEN
                                                FND_MESSAGE.SET_NAME( 'IGS' , l_message_name4);
                                                FND_MSG_PUB.ADD;
                                           END IF;
                                           RAISE FND_API.G_EXC_ERROR;
                                       ELSIF (p_show_warning = 'Y' ) THEN
                                         -- if error occured for the first time for this unit set then log the heading and
                                         -- increment the count and append to out param. Ignore this logic when further errors occur
                                         IF NOT l_error_occured THEN
                                           l_error_occured := TRUE;

                                           IF l_unitset_append_count = 1 THEN
                                              p_unit_sets_having_errors := l_unitset_seqno_and_prmind || ';' ;
                                           ELSE
                                              p_unit_sets_having_errors := p_unit_sets_having_errors || l_unitset_seqno_and_prmind || ';' ;
                                           END IF;
                                           l_unitset_append_count := l_unitset_append_count + 1;
                                           FND_MESSAGE.SET_NAME('IGS','IGS_EN_WARN_US_TRN');
                                           FND_MESSAGE.SET_TOKEN('UNIT_SET_CD',l_unitset);
                                           FND_MESSAGE.SET_TOKEN('US_VERSION_NUMBER',l_unitset_att_rec.us_version_number);
                                           FND_MSG_PUB.ADD;
                                         END IF;
                                         FND_MESSAGE.SET_NAME( 'IGS' , l_message_name3);
                                         FND_MSG_PUB.ADD;
                                         IF l_message_name2 IS NOT NULL THEN
                                                FND_MESSAGE.SET_NAME( 'IGS' , l_message_name4);
                                                FND_MSG_PUB.ADD;
                                         END IF;
                                         p_return_status := FND_API.G_RET_STS_ERROR;
                                       END IF;-- end of   p_show_warning  = 'Y'   IF THEN

                               END IF;-- end of l_status = FALSE

                         END IF;-- end of l_susa_cousr_status = FALSE  IF THEN

                    END IF;--end of l_dest_unitset_att_rec.primary_set_ind = 'Y' IF THEN

                 END IF;--end of l_val_susa_tran IF THEN

              END IF;-- end of l_unitset_att_exists IF THEN

              l_nth_occurence := l_nth_occurence + 1;
              l_cindex := INSTR(l_unitsets_to_transfer,';',1,l_nth_occurence);

        END LOOP;-- end of WHILE LOOP

    EXCEPTION
       WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
            RAISE;
       WHEN FND_API.G_EXC_ERROR THEN
            RAISE;
       WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.validate_src_prgm_unt_set_att');
            IGS_GE_MSG_STACK.ADD;
            IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.validate_src_prgm_unt_set_att :',SQLERRM);
            END IF;
            App_Exception.Raise_Exception;

   END validate_src_prgm_unt_set_att;

   PROCEDURE update_source_prgm (
    p_person_id               IN   NUMBER,
    p_source_program_cd       IN   VARCHAR2,
    p_source_prog_ver         IN   NUMBER,
    p_dest_program_cd         IN   VARCHAR2,
    p_trans_approval_dt       IN   DATE,
    p_trans_actual_dt         IN   DATE,
    p_dest_fut_dt_trans_flag  IN   VARCHAR2,
    p_discontinue_source      IN   VARCHAR2,
    p_tran_across_careers     IN BOOLEAN,
    p_src_career_type         IN VARCHAR2
    ) AS

  -------------------------------------------------------------------------------------------
  -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure updated the source program when it passes all validations
  --Change History:
  --Who         When            What
  --stutta    10-DEC-2004   Unsetting skip_before_after_dml( allowing recurrsion) if discontinue_source
  --                        is Y for a immediate transfer. This is the only case when skip_before_after
  --                        _dml is unset during the entire process of program transfer. Calculate
  --                        program attempt status depending on whether source is becoming PRIMARY/SECONDARY.
  --                        Pass the program attempt status to update row call. Bug#4046782
  --somasekar   13-apr-2005     bug# 4179106 modified to check the transfer status with 'S'
  --                                  instead of 'N'
  -------------------------------------------------------------------------------------------


    l_course_attempt_status  IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
    l_commencement_dt        IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
    l_discont_reason_code         IGS_EN_DCNT_REASONCD.discontinuation_reason_cd%TYPE;
    l_status        BOOLEAN;
    l_message_name    FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
    CURSOR c_course_type IS
    SELECT course_type
    FROM IGS_PS_VER
    WHERE COURSE_CD = p_source_program_cd
    AND VERSION_NUMBER  = p_source_prog_ver;
    CURSOR c_get_stdnt_ps_att_dtls IS
       SELECT *
       FROM IGS_EN_STDNT_PS_ATT
       WHERE person_id = p_person_id AND
             course_cd = p_source_program_cd;
    l_stdnt_ps_attempt_dtls_rec  c_get_stdnt_ps_att_dtls%ROWTYPE;

       CURSOR c_get_discont_reason IS
       SELECT discontinuation_reason_cd
       FROM IGS_EN_DCNT_REASONCD
       WHERE  dcnt_program_ind = 'Y' AND
              closed_ind   = 'N'     AND
                  sys_dflt_ind = 'Y'     AND
              s_discontinuation_reason_type = 'TRANSFER';
       -- check if any other active program exists in the source career other than the source program
       CURSOR c_act_src_prg_exists_as_prmy IS
       SELECT 'x'
       FROM IGS_EN_STDNT_PS_ATT sca,
            IGS_PS_VER pv
       WHERE sca.person_id   = p_person_id AND
             sca.course_cd = pv.course_cd AND
             sca.version_number = pv.version_number AND
             pv.course_type =  p_src_career_type AND
            sca.course_cd   <> p_source_program_cd AND
            sca.course_attempt_status IN ('ENROLLED','INACTIVE','LAPSED','INTERMIT');
    l_act_src_exist_across_career  c_act_src_prg_exists_as_prmy%ROWTYPE;
    l_course_type igs_ps_ver.course_type%TYPE;
   BEGIN

    OPEN c_get_stdnt_ps_att_dtls;
    FETCH c_get_stdnt_ps_att_dtls INTO l_stdnt_ps_attempt_dtls_rec;
    CLOSE c_get_stdnt_ps_att_dtls;
    IF  p_discontinue_source = 'Y' AND p_dest_fut_dt_trans_flag = 'S' THEN
       -- discontinue source and any enrolled unit attempts left in it
       -- this procedure will automatically make the source secondary and make some other program in that career primary
        OPEN c_get_discont_reason;
        FETCH c_get_discont_reason INTO l_discont_reason_code;
        CLOSE c_get_discont_reason;
        IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml := FALSE;
         -- discontinue the source program attempt on the same date as the program ransfer record was created
         l_status :=   IGS_EN_GEN_012.ENRP_UPD_SCA_DISCONT (
                                                 p_person_id,
                                                 p_source_program_cd,
                                                 p_source_prog_ver,
                                                 l_stdnt_ps_attempt_dtls_rec.course_attempt_status,
                                                 l_stdnt_ps_attempt_dtls_rec.commencement_dt,
                                                 p_trans_actual_dt,
                                                 l_discont_reason_code,
                                                 l_message_name,
                                                 'PROGRAM_TRANSFER' ,
                                                  p_dest_program_cd
                                                 );

         IF l_status = FALSE THEN
            FND_MESSAGE.SET_NAME('IGS',l_message_name);
            FND_MSG_PUB.ADD;
            FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_UNABLE_DISCONT_FROM');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
    ELSIF  p_discontinue_source = 'N'  AND p_dest_fut_dt_trans_flag = 'S' THEN
          -- if source is key then make it non key because destination is already being made key in this case
          IF l_stdnt_ps_attempt_dtls_rec.key_program = 'Y' THEN
             l_stdnt_ps_attempt_dtls_rec.key_program := 'N';
          END IF;


          -- set the primary program type of the source as appropriate
          IF NOT p_tran_across_careers AND is_career_model_enabled THEN
                -- for transfers within career immediate transfers always make source secondary even when source is not discontinued
                  l_stdnt_ps_attempt_dtls_rec.primary_program_type := 'SECONDARY';
          END IF;

          -- DERIVE THE STATUS OF THE SOURCE PROGRAM ATTEMPT
          IF l_stdnt_ps_attempt_dtls_rec.primary_program_type = 'PRIMARY' OR NOT is_career_model_enabled THEN
             -- the source program is a primary or this is program mode, so derive proper status
                    l_stdnt_ps_attempt_dtls_rec.course_attempt_status :=
                            igs_en_gen_006.Enrp_Get_Sca_Status(
                                p_person_id => l_stdnt_ps_attempt_dtls_rec.person_id,
                                p_course_cd =>  l_stdnt_ps_attempt_dtls_rec.course_cd,
                                p_course_attempt_status => l_stdnt_ps_attempt_dtls_rec.course_attempt_status,
                                p_student_confirmed_ind => l_stdnt_ps_attempt_dtls_rec.student_confirmed_ind,
                                p_discontinued_dt => NULL,
                                p_lapsed_dt => l_stdnt_ps_attempt_dtls_rec.lapsed_dt,
                                p_course_rqrmnt_complete_ind => l_stdnt_ps_attempt_dtls_rec.course_rqrmnt_complete_ind,
                                p_logical_delete_dt => l_stdnt_ps_attempt_dtls_rec.logical_delete_dt );
          ELSE
                  OPEN c_course_type;
                  FETCH c_course_type INTO l_course_type;
                  CLOSE c_course_type;
              -- the source program is a secondary, so derive proper status
                l_stdnt_ps_attempt_dtls_rec.course_attempt_status :=
                    igs_en_career_model.enrp_get_sec_sca_status( l_stdnt_ps_attempt_dtls_rec.person_id ,
                                  l_stdnt_ps_attempt_dtls_rec.course_cd ,
                                  l_stdnt_ps_attempt_dtls_rec.course_attempt_status,
                                  l_stdnt_ps_attempt_dtls_rec.primary_program_type ,
                                  l_stdnt_ps_attempt_dtls_rec.primary_prog_type_source,
                                  l_course_type ,
                                  p_dest_program_cd);
          END IF;

              IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                      X_ROWID                               => l_stdnt_ps_attempt_dtls_rec.row_id,
                      X_PERSON_ID                           => l_stdnt_ps_attempt_dtls_rec.PERSON_ID,
                      X_COURSE_CD                           => l_stdnt_ps_attempt_dtls_rec.COURSE_CD,
                      X_ADVANCED_STANDING_IND       => l_stdnt_ps_attempt_dtls_rec.ADVANCED_STANDING_IND,
                      X_FEE_CAT                             => l_stdnt_ps_attempt_dtls_rec.fee_cat,
                      X_CORRESPONDENCE_CAT              => l_stdnt_ps_attempt_dtls_rec.correspondence_cat,
                      X_SELF_HELP_GROUP_IND             => l_stdnt_ps_attempt_dtls_rec.SELF_HELP_GROUP_IND,
                      X_LOGICAL_DELETE_DT               => l_stdnt_ps_attempt_dtls_rec.logical_delete_dt,
                      X_ADM_ADMISSION_APPL_NUMBER       => l_stdnt_ps_attempt_dtls_rec.adm_admission_appl_number,
                      X_ADM_NOMINATED_COURSE_CD         => l_stdnt_ps_attempt_dtls_rec.adm_nominated_course_cd,
                      X_ADM_SEQUENCE_NUMBER                     => l_stdnt_ps_attempt_dtls_rec.adm_sequence_number,
                      X_VERSION_NUMBER                          => l_stdnt_ps_attempt_dtls_rec.version_number,
                      X_CAL_TYPE                                        => l_stdnt_ps_attempt_dtls_rec.cal_type,
                      X_LOCATION_CD                                     => l_stdnt_ps_attempt_dtls_rec.location_cd,
                      X_ATTENDANCE_MODE                         => l_stdnt_ps_attempt_dtls_rec.attendance_mode,
                      X_ATTENDANCE_TYPE                         => l_stdnt_ps_attempt_dtls_rec.attendance_type,
                      X_COO_ID                                          => l_stdnt_ps_attempt_dtls_rec.coo_id,
                      X_STUDENT_CONFIRMED_IND           => l_stdnt_ps_attempt_dtls_rec.student_confirmed_ind,
                      X_COMMENCEMENT_DT                         => l_stdnt_ps_attempt_dtls_rec.commencement_dt,
                      X_COURSE_ATTEMPT_STATUS           => l_stdnt_ps_attempt_dtls_rec.course_attempt_status,
                      X_PROGRESSION_STATUS                      => l_stdnt_ps_attempt_dtls_rec.PROGRESSION_STATUS,
                      X_DERIVED_ATT_TYPE                        => l_stdnt_ps_attempt_dtls_rec.DERIVED_ATT_TYPE,
                      X_DERIVED_ATT_MODE                        => l_stdnt_ps_attempt_dtls_rec.DERIVED_ATT_MODE,
                      X_PROVISIONAL_IND                         => l_stdnt_ps_attempt_dtls_rec.provisional_ind,
                      X_DISCONTINUED_DT                         => l_stdnt_ps_attempt_dtls_rec.discontinued_dt,
                      X_DISCONTINUATION_REASON_CD       => l_stdnt_ps_attempt_dtls_rec.discontinuation_reason_cd,
                      X_LAPSED_DT                               => l_stdnt_ps_attempt_dtls_rec.LAPSED_DT,
                      X_FUNDING_SOURCE                      => l_stdnt_ps_attempt_dtls_rec.funding_source,
                      X_EXAM_LOCATION_CD                    => l_stdnt_ps_attempt_dtls_rec.EXAM_LOCATION_CD,
                      X_DERIVED_COMPLETION_YR           => l_stdnt_ps_attempt_dtls_rec.DERIVED_COMPLETION_YR,
                      X_DERIVED_COMPLETION_PERD         => l_stdnt_ps_attempt_dtls_rec.DERIVED_COMPLETION_PERD,
                      X_NOMINATED_COMPLETION_YR         => l_stdnt_ps_attempt_dtls_rec.nominated_completion_yr,
                      X_NOMINATED_COMPLETION_PERD       => l_stdnt_ps_attempt_dtls_rec.NOMINATED_COMPLETION_PERD,
                      X_RULE_CHECK_IND                      => l_stdnt_ps_attempt_dtls_rec.RULE_CHECK_IND,
                      X_WAIVE_OPTION_CHECK_IND          => l_stdnt_ps_attempt_dtls_rec.WAIVE_OPTION_CHECK_IND,
                      X_LAST_RULE_CHECK_DT                  => l_stdnt_ps_attempt_dtls_rec.LAST_RULE_CHECK_DT,
                      X_PUBLISH_OUTCOMES_IND            => l_stdnt_ps_attempt_dtls_rec.PUBLISH_OUTCOMES_IND,
                      X_COURSE_RQRMNT_COMPLETE_IND      => l_stdnt_ps_attempt_dtls_rec.COURSE_RQRMNT_COMPLETE_IND,
                      X_COURSE_RQRMNTS_COMPLETE_DT      => l_stdnt_ps_attempt_dtls_rec.COURSE_RQRMNTS_COMPLETE_DT,
                      X_S_COMPLETED_SOURCE_TYPE     => l_stdnt_ps_attempt_dtls_rec.S_COMPLETED_SOURCE_TYPE,
                      X_OVERRIDE_TIME_LIMITATION    => l_stdnt_ps_attempt_dtls_rec.OVERRIDE_TIME_LIMITATION,
                      x_last_date_of_attendance     => l_stdnt_ps_attempt_dtls_rec.last_date_of_attendance,
                      x_dropped_by                          => l_stdnt_ps_attempt_dtls_rec.dropped_by,
                      X_IGS_PR_CLASS_STD_ID             => l_stdnt_ps_attempt_dtls_rec.igs_pr_class_std_id,
                      x_primary_program_type        => l_stdnt_ps_attempt_dtls_rec.primary_program_type,
                      x_primary_prog_type_source    => l_stdnt_ps_attempt_dtls_rec.primary_prog_type_source,
                      x_catalog_cal_type            => l_stdnt_ps_attempt_dtls_rec.catalog_cal_type,
                      x_catalog_seq_num             => l_stdnt_ps_attempt_dtls_rec.catalog_seq_num,
                      x_key_program                 => l_stdnt_ps_attempt_dtls_rec.key_program,
                      x_override_cmpl_dt            => l_stdnt_ps_attempt_dtls_rec.override_cmpl_dt,
                      x_manual_ovr_cmpl_dt_ind      => l_stdnt_ps_attempt_dtls_rec.manual_ovr_cmpl_dt_ind,
                      X_MODE                                =>  'R',
                      X_ATTRIBUTE_CATEGORY          => l_stdnt_ps_attempt_dtls_rec.attribute_category,
                      X_ATTRIBUTE1                  => l_stdnt_ps_attempt_dtls_rec.attribute1,
                      X_ATTRIBUTE2                  => l_stdnt_ps_attempt_dtls_rec.attribute2,
                      X_ATTRIBUTE3                  => l_stdnt_ps_attempt_dtls_rec.attribute3,
                      X_ATTRIBUTE4                  => l_stdnt_ps_attempt_dtls_rec.attribute4,
                      X_ATTRIBUTE5                  => l_stdnt_ps_attempt_dtls_rec.attribute5,
                      X_ATTRIBUTE6                  => l_stdnt_ps_attempt_dtls_rec.attribute6,
                      X_ATTRIBUTE7                  => l_stdnt_ps_attempt_dtls_rec.attribute7,
                      X_ATTRIBUTE8                  => l_stdnt_ps_attempt_dtls_rec.attribute8,
                      X_ATTRIBUTE9                  => l_stdnt_ps_attempt_dtls_rec.attribute9,
                      X_ATTRIBUTE10                 => l_stdnt_ps_attempt_dtls_rec.attribute10,
                      X_ATTRIBUTE11                 => l_stdnt_ps_attempt_dtls_rec.attribute11,
                      X_ATTRIBUTE12                 => l_stdnt_ps_attempt_dtls_rec.attribute12,
                      X_ATTRIBUTE13                 => l_stdnt_ps_attempt_dtls_rec.attribute13,
                      X_ATTRIBUTE14                 => l_stdnt_ps_attempt_dtls_rec.attribute14,
                      X_ATTRIBUTE15                 => l_stdnt_ps_attempt_dtls_rec.attribute15,
                      X_ATTRIBUTE16                 => l_stdnt_ps_attempt_dtls_rec.attribute16,
                      X_ATTRIBUTE17                 => l_stdnt_ps_attempt_dtls_rec.attribute17,
                      X_ATTRIBUTE18                 => l_stdnt_ps_attempt_dtls_rec.attribute18,
                      X_ATTRIBUTE19                 => l_stdnt_ps_attempt_dtls_rec.attribute19,
                      X_ATTRIBUTE20                 => l_stdnt_ps_attempt_dtls_rec.attribute20,
                      X_FUTURE_DATED_TRANS_FLAG     => l_stdnt_ps_attempt_dtls_rec.future_dated_trans_flag);




    END IF;-- end of  p_discontinue_source = 'Y' AND p_dest_fut_dt_trans_flag = 'N' IF THEN

    EXCEPTION
      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
           IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml :=  FALSE ;
           RAISE;
      WHEN FND_API.G_EXC_ERROR THEN
           IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml :=  FALSE ;
           RAISE;
      WHEN OTHERS THEN
           IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml :=  FALSE ;
           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_TRANSFER_APIS.update_source_prgm');
           IGS_GE_MSG_STACK.ADD;
           IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.update_source_prgm :',SQLERRM);
           END IF;
           App_Exception.Raise_Exception;

  END update_source_prgm;


  PROCEDURE program_transfer_api(
      p_person_id               IN   NUMBER,
      p_source_program_cd       IN   VARCHAR2,
      p_source_prog_ver         IN   NUMBER,
      p_term_cal_type           IN   VARCHAR2,
      p_term_seq_num            IN   NUMBER,
      p_acad_cal_type           IN   VARCHAR2,
      p_acad_seq_num            IN   NUMBER,
      p_trans_approval_dt       IN   DATE,
      p_trans_actual_dt         IN   DATE,
      p_dest_program_cd         IN   VARCHAR2,
      p_dest_prog_ver           IN   NUMBER,
      p_dest_coo_id             IN   NUMBER,
      p_uoo_ids_to_transfer     IN   VARCHAR2,
      p_uoo_ids_not_selected    IN   VARCHAR2,
      p_uoo_ids_having_errors   OUT NOCOPY  VARCHAR2,
      p_unit_sets_to_transfer   IN   VARCHAR2,
      p_unit_sets_not_selected  IN   VARCHAR2,
      p_unit_sets_having_errors OUT NOCOPY VARCHAR2,
      p_transfer_av             IN   VARCHAR2,
      p_transfer_re             IN   VARCHAR2 ,
      p_discontinue_source      IN   VARCHAR2 ,
      p_show_warning            IN   VARCHAR2,
      p_call_from               IN   VARCHAR2,
      p_process_mode            IN   VARCHAR2,
      p_return_status           OUT NOCOPY  VARCHAR2,
      p_msg_data                OUT NOCOPY VARCHAR2,
      p_msg_count               OUT NOCOPY NUMBER
    ) AS

  -- NOTE: Parameters p_unit_sets_not_selected, p_uoo_ids_not_selected are not being used at the moment.
  -- they had been introduced earlier but are not being removed in anticipation of future need.

     -------------------------------------------------------------------------------------------
  -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure validates holds,debt ,unit attempt transfer,unit set transfer by
  --           invoking appropriate procedures and  updates the source and destination program
  --           respectively
  --Change History:
  --Who         When            What
  --ckasu     02-DEC-2004     modified as a part of Bug#4044329
  --stutta    10-DEC-2004     Setting global skip_before_after_dml to TRUE before update
  --                          update destination, and unsetting it after update source. Bug #4046782
  -- smaddali  16-dec-04  modified for  bug#4063726
  --bdeviset  22-Dec-2004      Modifed so as to update the transfer record when the transfer deatils
  --                           are modified and added extra params status_date and status_flag for inserting
  --                           transfer record as part Bug#4083015.
  --amuthu    23-DEC-2004      In the career mode if the source program of a transfer is secondary
  --                           then an error message would be shown to the user.
  --                           If the source program is primary and unconfrimed then it can be transfered
  --                           only within the career, otherwise an error message would be shown.
  --bdeviset   31-DEC-2004      Bug# 4097481.Added a call to is_sua_enroll_eff_fut_term.
  --smaddali    5-jan-05        Bug#4103437 , modified logic for updating program transfer record
  --somasekar   13-apr-2005     bug# 4179106 modified to check the transfer status with 'S'
  --                                  instead of 'N'
  -- ckasu     08-DEC-2005     passed SYSDATE for update_source instead of p_actual_date param
  --                           as part of bug#4869869

  -------------------------------------------------------------------------------------------

    l_api_name                   CONSTANT    VARCHAR2(30) := 'PROGRAM_TRANSFER_APIS';
    l_discon_reason_code         IGS_EN_STDNT_PS_ATT.DISCONTINUED_DT%TYPE ;
    l_discon_dt                  IGS_EN_STDNT_PS_ATT.DISCONTINUATION_REASON_CD%TYPE ;
    l_status                     BOOLEAN;
    l_return_value               BOOLEAN;
    l_career_model_enabled       BOOLEAN;
    l_tran_across_careers        BOOLEAN;
    l_drop                       BOOLEAN;
    l_sct_tran_status            BOOLEAN;
    l_src_career_type            IGS_PS_VER.COURSE_TYPE%TYPE;
    l_message_name               FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
    l_debt_message_name          FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
    l_hold_status                BOOLEAN;

    l_person_type                   IGS_PE_PERSON_TYPES.person_type_code%TYPE;
    l_src_primary_prg_type    IGS_EN_STDNT_PS_ATT.PRIMARY_PROGRAM_TYPE%TYPE;
    l_src_key_prgm            IGS_EN_STDNT_PS_ATT.KEY_PROGRAM%TYPE;
    l_src_std_confrm_ind      IGS_EN_STDNT_PS_ATT.STUDENT_CONFIRMED_IND%TYPE;
    l_src_prg_reasearch_ind   IGS_PS_TYPE.research_type_ind%TYPE;

    l_dest_primary_prg_type    IGS_EN_STDNT_PS_ATT.PRIMARY_PROGRAM_TYPE%TYPE;
    l_old_dest_key_prgm_flag   IGS_EN_STDNT_PS_ATT.KEY_PROGRAM%TYPE;
    l_new_dest_key_prgm_flag   IGS_EN_STDNT_PS_ATT.KEY_PROGRAM%TYPE;
    l_dest_commence_dt         IGS_EN_STDNT_PS_ATT.COMMENCEMENT_DT%TYPE;
    l_dest_prg_reasearch_ind   IGS_PS_TYPE.research_type_ind%TYPE;
    l_dest_fut_dt_trans_flag   IGS_EN_STDNT_PS_ATT.FUTURE_DATED_TRANS_FLAG%TYPE;
    l_dest_std_confrm_ind      IGS_EN_STDNT_PS_ATT.STUDENT_CONFIRMED_IND%TYPE;
    l_course_attempt_status    IGS_EN_STDNT_PS_ATT.COURSE_ATTEMPT_STATUS%TYPE;
    l_status_date              CONSTANT DATE := SYSDATE;
    l_trans_rowid              VARCHAR2(25);
    l_trans_comments           igs_ps_stdnt_trn.comments%TYPE;
    l_trans_date               igs_ps_stdnt_trn.transfer_dt%TYPE;
    l_trans_status             igs_ps_stdnt_trn.status_flag%TYPE;
    l_unit_sets_to_transfer     VARCHAR2(4000);

    CURSOR c_get_key_val_frm_prg(c_person_id IGS_EN_STDNT_PS_ATT.PERSON_ID%TYPE,c_program_cd IGS_EN_STDNT_PS_ATT.COURSE_CD%TYPE) IS
       SELECT key_program ,student_confirmed_ind,commencement_dt, course_attempt_status
       FROM IGS_EN_STDNT_PS_ATT
       WHERE person_id = c_person_id and
            course_cd = c_program_cd;

    CURSOR c_get_std_course_ind_of_src (c_person_id IGS_EN_STDNT_PS_ATT.PERSON_ID%TYPE,c_program_cd IGS_EN_STDNT_PS_ATT.COURSE_CD%TYPE) IS
       SELECT student_confirmed_ind, primary_program_type
       FROM IGS_EN_STDNT_PS_ATT
       WHERE person_id = c_person_id and
            course_cd = c_program_cd;
    CURSOR c_get_progam_type(c_course_cd IGS_PS_VER.course_cd%TYPE,c_course_ver IGS_PS_VER.version_number%TYPE)  IS
       SELECT cty.research_type_ind
       FROM   IGS_PS_VER crv,
             IGS_PS_TYPE cty
       WHERE  crv.course_cd      = c_course_cd  AND
             crv.version_number = c_course_ver AND
             crv.course_type    = cty.course_type ;

    -- select any UNPROCESSED transfer record for the student with the same source and destination combo
    CURSOR c_chk_trans_rec (c_person_id igs_ps_stdnt_trn.person_id%TYPE,
                            c_course_cd igs_ps_stdnt_trn.course_cd%TYPE,
                            c_transfer_course_cd igs_ps_stdnt_trn.transfer_course_cd%TYPE) IS
     SELECT rowid, transfer_dt, comments
     FROM igs_ps_stdnt_trn
     WHERE person_id = c_person_id
     AND course_cd = c_course_cd
     AND transfer_course_cd = c_transfer_course_cd
     AND STATUS_FLAG = 'U';

   l_uooids_str  VARCHAR2(2000) ;
   l_uoo_ids_passed_transfer  VARCHAR2(4000);


    -- smaddali added the following cursors for bug#4085979
   -- Fetch the relevant admissions course transfer record.
   CURSOR c_act (  cp_person_id  IN     IGS_AD_PS_APPL.person_id%TYPE,
              cp_course_cd  IN     IGS_AD_PS_APPL.nominated_course_cd%TYPE,
              cp_transfer_course_cd       IN IGS_AD_PS_APPL.transfer_course_cd%TYPE) IS
              SELECT transfer_course_cd
              FROM   IGS_AD_PS_APPL
              WHERE  person_id = cp_person_id
              AND    nominated_course_cd = cp_course_cd
              AND    transfer_course_cd = cp_transfer_course_cd;

    -- check if a transfer record exists for the passed source and destination or not
    CURSOR c_trans_exists (c_person_id igs_ps_stdnt_trn.person_id%TYPE,
                            c_course_cd igs_ps_stdnt_trn.course_cd%TYPE,
                            c_transfer_course_cd igs_ps_stdnt_trn.transfer_course_cd%TYPE) IS
     SELECT  transfer_dt
     FROM igs_ps_stdnt_trn
     WHERE person_id = c_person_id
     AND course_cd = c_course_cd
     AND transfer_course_cd = c_transfer_course_cd
     AND status_flag <> 'C';
     l_trans_exists_rec c_trans_exists%ROWTYPE;

    l_adm_course_cd IGS_AD_PS_APPL.transfer_course_cd%TYPE;
    l_adm_transfer BOOLEAN;
	l_key_program IGS_EN_SPA_TERMS.key_program_flag%TYPE;
  BEGIN
     SAVEPOINT TRANSFER_PRGM;
     FND_MSG_PUB.INITIALIZE;
     IF is_career_model_enabled THEN
       l_career_model_enabled := TRUE;
     ELSE
      l_career_model_enabled := FALSE;
     END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;
     -- getting student confirmed indicator for source program
     OPEN c_get_std_course_ind_of_src(p_person_id,p_source_program_cd);
     FETCH c_get_std_course_ind_of_src INTO l_src_std_confrm_ind, l_src_primary_prg_type;
     CLOSE c_get_std_course_ind_of_src;

     IF l_career_model_enabled AND l_src_primary_prg_type = 'SECONDARY' THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_SEC_CANT_BE_SRC');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- getting destination program key flag ,student confirmed
     -- indicator and destination commencement date values
     OPEN c_get_key_val_frm_prg(p_person_id,p_dest_program_cd);
     FETCH c_get_key_val_frm_prg INTO l_old_dest_key_prgm_flag,l_dest_std_confrm_ind,l_dest_commence_dt, l_course_attempt_status;
     CLOSE c_get_key_val_frm_prg;

     -- l_tran_across_careers is assigned with TRUE when transfer is across career else FALSE.
     IF  l_career_model_enabled THEN
             l_tran_across_careers := is_tranfer_across_careers(p_source_program_cd,
                                                          p_source_prog_ver,
                                                          p_dest_program_cd,
                                                          p_dest_prog_ver,
                                                          l_src_career_type);
             IF l_src_std_confrm_ind = 'N' AND l_tran_across_careers THEN
               FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_UN_SRC_ONLY_INTRA');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
     END IF;

     l_new_dest_key_prgm_flag := l_old_dest_key_prgm_flag;
     l_uooids_str := NULL;
     l_adm_transfer := FALSE;

     l_person_type := Igs_En_Gen_008.enrp_get_person_type(p_course_cd =>NULL);

     -- this procedure validates the Holds
     check_for_holds(p_person_id,
                     p_dest_program_cd,
                     p_term_cal_type,
                     p_term_seq_num,
                     l_person_type,
                     p_return_status,
                     p_show_warning);

     -- this procedure validates the person steps
     validate_person_steps(p_person_id,
                           p_dest_program_cd,
                           p_dest_prog_ver,
                           p_term_cal_type,
                           p_term_seq_num,
                           p_acad_cal_type,
                           p_acad_seq_num,
                           l_person_type,
                           p_show_warning,
                           p_return_status);

        -- added for bug #4747585 by chanchal
       IF p_unit_sets_to_transfer IS NOT NULL THEN

          l_unit_sets_to_transfer := arrange_selected_unitsets(p_person_id,
                                                               p_source_program_cd,
                                                               p_unit_sets_to_transfer);

       END IF;


   -- This part need not be processed in case the stored future dated transfer records are being procesed for transfer
   -- since the research candidacy records were copied to the destination when the future dated transfer was created
   -- also the destination program attempt status has already been validated in the process wrapped. hence that too
   -- can be skipped.
   IF p_call_from <> 'PROCESS' THEN

     -- validating and transfering research candidacy of  source program that need to be transfered to destination
     IF p_transfer_re = 'Y' THEN
           -- smaddali   Modified for bug#4063726, to disable transfers between research and non research programs
          -- getting research type indicator value for source program
          OPEN c_get_progam_type(p_source_program_cd,p_source_prog_ver);
          FETCH c_get_progam_type INTO l_src_prg_reasearch_ind;
          CLOSE c_get_progam_type;

          -- getting research type indicator value for destination program
          OPEN c_get_progam_type(p_dest_program_cd,p_dest_prog_ver);
          FETCH c_get_progam_type INTO l_dest_prg_reasearch_ind;
          CLOSE c_get_progam_type;

          -- cheking whether destination is an reasearch program or not when source program
          -- is an research program.
          IF l_src_prg_reasearch_ind = 'N' OR  l_dest_prg_reasearch_ind = 'N' THEN

                FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_NOT_TRN_RESCAND');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;

          END IF;-- end of l_src_prg_reasearch_ind = 'Y' IF THEN

          -- validating and transfering candidacy details
          validate_candidacy_tran_dtls(p_person_id,
                                       p_source_program_cd,
                                       p_source_prog_ver,
                                       p_dest_program_cd,
                                       p_dest_prog_ver,
                                       p_show_warning,
                                       p_return_status);
     END IF;-- end of p_transfer_re IF THEN

     -- when destination program is not confirmed then validating inorder to make it confirm
     IF l_dest_std_confrm_ind = 'N' THEN
        check_is_dest_prgm_actv_confrm (p_person_id,
                                        p_source_program_cd,
                                        p_acad_cal_type,
                                        p_acad_seq_num,
                                        p_dest_program_cd,
                                        p_show_warning,
                                        l_dest_std_confrm_ind);

        -- smaddali added logic for bug# 4085979
        -- to create the program transfer record before destination is confirmed.
        -- if the program is created thru an admission transfer application then
        -- program transfer record should be created before confirming the destination
        -- because the program attempt cannot be confirmed without a transfer record in this case

        -- check if this program is created thru an admission program transfer application
        OPEN c_act (p_person_id, p_dest_program_cd, p_source_program_cd);
        FETCH c_act INTO l_adm_course_cd;
        IF c_act%FOUND THEN
            -- check if there is no existing trasnfer record from this source to this destination
            l_trans_exists_rec := NULL ;
            OPEN c_trans_exists (p_person_id, p_dest_program_cd, p_source_program_cd);
            FETCH c_trans_exists INTO l_trans_exists_rec;
            IF c_trans_exists%NOTFOUND THEN
                  -- set the flag to indicate that program transfer record should be created before
                  -- confirming the destination program attempt
                  l_adm_transfer := TRUE;
            END IF;
            CLOSE c_trans_exists;
        END IF;
        CLOSE c_act;

     END IF;  -- end of l_dest_std_confrm_ind = 'N'

     -- this checks whether destination program is discontinued or not.
     is_destn_prgm_att_discon(p_person_id,p_dest_program_cd,p_dest_prog_ver,l_status);

     -- validation to check when destination program is discontinued status.
     IF  l_status THEN
         l_return_value :=  IGS_EN_GEN_006.ENRP_GET_SCA_ELGBL(p_person_id,
                                                              p_dest_program_cd,
                                                              'RETURN',
                                                              p_acad_cal_type,
                                                              p_acad_seq_num,
                                                              'Y',
                                                              l_message_name);
         IF l_return_value = FALSE AND l_message_name NOT IN ('IGS_EN_STUD_INELIG_TO_RE_ENR','IGS_EN_INELIGBLE_DUE_TO_LAPSE',
                                                               'IGS_EN_STUD_INELIGIBLE_RE_ENR','IGS_EN_STUD_NOT_HAVE_CURR_AFF',
                                                               'IGS_EN_INTERM_DOES_NOT_END') THEN
             FND_MESSAGE.SET_NAME( 'IGS' , l_message_name);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
         END IF;
         l_discon_dt  := NULL;
         l_discon_reason_code := NULL;
     END IF;
   END IF;
   -- p_call_from=PROCESS

     -- set the values of parameters to be used for further processing
     set_dest_prgm_att_params(p_person_id,
                              p_source_program_cd,
                              p_term_cal_type,
                              p_term_seq_num,
                              l_dest_primary_prg_type,
                              l_new_dest_key_prgm_flag,
                              l_dest_commence_dt,
                              l_dest_fut_dt_trans_flag,
                              p_transfer_re);

        -- smaddali added logic for bug# 4085979
        -- if the destination is unconfirmed and is created from admission transfer application then
        -- create the program transfer record before confirming the destination
        IF  l_adm_transfer  THEN
              -- derive the transfer status flag value
              IF l_dest_fut_dt_trans_flag = 'S' THEN
                l_trans_status := 'T';
              ELSE
                l_trans_status := 'U';
              END IF;
                -- insert the transfer record.
                l_sct_tran_status := IGS_EN_GEN_009.Enrp_Ins_Sct_Trnsfr(p_person_id ,
                                                               p_dest_program_cd ,
                                                               p_source_program_cd ,
                                                               p_trans_actual_dt ,
                                                               l_message_name ,
                                                               p_trans_approval_dt,
                                                               p_term_cal_type ,
                                                               p_term_seq_num,
                                                               p_discontinue_source,
                                                               p_uoo_ids_to_transfer,
                                                               l_unit_sets_to_transfer,
                                                               p_transfer_av,
                                                               l_status_date,
                                                               l_trans_status
                                                               );
        END IF ;  -- end of l_adm_transfer


     -- Updating destination program attempt during transfer.
     -- in this case the setting global variable to skip auto calculations of primary/secondary
     -- since the rank calculations need not be done. The destination will always be primary.
       IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml :=  TRUE ;
       update_destination_prgm(p_person_id,
                             p_source_program_cd,
                             p_dest_program_cd,
                             l_new_dest_key_prgm_flag,
                             l_dest_std_confrm_ind,
                             l_dest_fut_dt_trans_flag,
                             l_dest_commence_dt,
                             l_tran_across_careers,
                             p_term_cal_type ,
                             p_term_seq_num);

     -- Creating Transfer Record
     -- store the transfer date so that the same date can be used for creating unit transer record
     -- and discontinue source program attempt
     -- Transfer records are created when either its immediate trasnfer or when the future dates transfer is stored
     -- they will exist when a future dated trasnfer is actually processed.

      IF l_dest_fut_dt_trans_flag = 'S' THEN
        l_trans_status := 'T';
      ELSE
        l_trans_status := 'U';
      END IF;

      -- get the row in case an UNPROCESSED transfer record exists for
      -- the same pair of SPAs.
      OPEN c_chk_trans_rec (p_person_id, p_dest_program_cd, p_source_program_cd);
      FETCH c_chk_trans_rec INTO l_trans_rowid,l_trans_date, l_trans_comments;
      CLOSE c_chk_trans_rec;
      -- added extra check for unconfirmed admission applications, buig#4103437
      IF l_trans_rowid IS NOT NULL AND NOT l_adm_transfer THEN
         -- If an UNPROCESSED trasnfer record exists for the same pair of program codes
         -- then this record needs to be updated with the new information
         -- NOTE: The transfer term calendar information should be same as the old
         --       else the logic would need to change to delete the old term calendars
         --       and create new ones.

             igs_ps_stdnt_trn_pkg.update_row(
                  x_rowid => l_trans_rowid,
                  x_person_id => p_person_id,
                  x_course_cd => p_dest_program_cd,
                  x_transfer_course_cd => p_source_program_cd,
                  x_TRANSFER_DT =>  l_trans_date,
                  x_COMMENTS => l_trans_comments,
                  X_APPROVED_DATE => p_trans_approval_dt,
                  X_EFFECTIVE_TERM_CAL_TYPE => p_term_cal_type,
                  X_EFFECTIVE_TERM_SEQUENCE_NUM => p_term_seq_num,
                  X_DISCONTINUE_SOURCE_FLAG => p_discontinue_source,
                  X_UOOIDS_TO_TRANSFER => p_uoo_ids_to_transfer,
                  X_SUSA_TO_TRANSFER => l_unit_sets_to_transfer,
                  X_TRANSFER_ADV_STAND_FLAG => p_transfer_av,
                  X_STATUS_DATE => l_status_date,
                  X_STATUS_FLAG => l_trans_status
                  );
      ELSE

         -- when a future dated transfer is created If their is a enrolled/waitlisted/invalid unit attempt
         -- in the effective and future terms against destination program then future dated transfer cannot be stored
         IF p_call_from <> 'PROCESS' AND l_dest_fut_dt_trans_flag = 'Y' THEN

           IF is_sua_enroll_eff_fut_term( p_person_id,
                                          p_dest_program_cd,
                                          p_term_cal_type,
                                          p_term_seq_num ) THEN

             FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_ENR_SUA_CUR_FUT_TERM');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;

          END IF;

         END IF;

         -- smaddali added condition to create program transfer record if it hasn't been created before confirming destination
         -- due to l_adm_transfer flag for bug# 4085979
         IF NOT l_adm_transfer  THEN
            -- insert the transfer record.
            l_sct_tran_status := IGS_EN_GEN_009.Enrp_Ins_Sct_Trnsfr(p_person_id ,
                                                               p_dest_program_cd ,
                                                               p_source_program_cd ,
                                                               p_trans_actual_dt ,
                                                               l_message_name ,
                                                               p_trans_approval_dt,
                                                               p_term_cal_type ,
                                                               p_term_seq_num,
                                                               p_discontinue_source,
                                                               p_uoo_ids_to_transfer,
                                                               l_unit_sets_to_transfer,
                                                               p_transfer_av,
                                                               l_status_date,
                                                               l_trans_status
                                                               );
         END IF;

         -- Creating Program Administration Record
         create_prgm_admin_record (p_person_id ,
                                 p_source_program_cd,
                                 p_dest_program_cd,
                                 p_acad_cal_type,
                                 p_acad_seq_num );

          -- creating term record for destination program
		   l_key_program := FND_API.G_MISS_CHAR;
		  IF (l_old_dest_key_prgm_flag <> l_new_dest_key_prgm_flag AND l_new_dest_key_prgm_flag = 'Y') THEN
			-- term api expects key_program_flag values only when key is changing to Y.
			l_key_program := 'Y';
		  END IF;
          upd_or_create_dest_term_rec(p_person_id,
                                      p_dest_program_cd,
                                      p_term_cal_type,
                                      p_term_seq_num,
                                      l_key_program,
                                      l_message_name,
                                      l_dest_fut_dt_trans_flag);
      END IF; -- END of IF l_trans_rowid IS NOT NULL


     -- checking for debt when show warning is Y
     IF p_show_warning = 'Y' THEN
        check_for_debt(p_person_id ,
                       p_source_program_cd,
                       l_debt_message_name);
        IF l_debt_message_name IS NOT NULL THEN
           FND_MESSAGE.SET_NAME( 'IGS' , l_debt_message_name);
           FND_MSG_PUB.ADD;
        END IF;
     END IF;


   IF l_dest_fut_dt_trans_flag = 'S' THEN

     -- Either if the source SPA is discontinued or the job is run in drop mode
     -- all the unit attempts have to be dropped
     IF p_discontinue_source = 'Y' OR p_process_mode = 'DROP' OR ( is_career_model_enabled AND l_tran_across_careers = FALSE ) THEN
        l_drop := TRUE;
     ELSE
        l_drop := FALSE;
     END IF;

     -- validating  and transfering units of source program that need to be transfered to destination
     validate_src_prgm_unt_attempts(p_person_id,
                                    p_source_program_cd,
                                    p_source_prog_ver,
                                    p_term_cal_type,
                                    p_term_seq_num ,
                                    p_acad_cal_type ,
                                    p_acad_seq_num ,
                                    p_trans_approval_dt,
                                    p_trans_actual_dt,
                                    p_dest_program_cd,
                                    p_dest_prog_ver,
                                    p_dest_coo_id ,
                                    p_uoo_ids_to_transfer,
                                    l_uoo_ids_passed_transfer,
                                    p_uoo_ids_having_errors,
                                    l_uooids_str,
                                    l_dest_fut_dt_trans_flag,
                                    p_show_warning,
                                    l_drop,
                                    p_return_status
                                    );
    -- validate the program step validations for destination program attempt if any of the unit attempts are being transfered
    -- added this validation as part of bug#4063726
    IF l_uoo_ids_passed_transfer IS NOT NULL THEN
      validate_prgm_attend_type_step(p_person_id,
                                     p_dest_program_cd,
                                     l_uoo_ids_passed_transfer,
                                     p_show_warning,
                                     p_return_status);
    END IF;

    -- validating and transfering unit sets of source program that need to be transfered to destination
    validate_src_prgm_unt_set_att(p_person_id,
                                  p_source_program_cd,
                                  p_source_prog_ver,
                                  p_term_cal_type,
                                  p_term_seq_num,
                                  p_acad_cal_type,
                                  p_acad_seq_num,
                                  p_trans_approval_dt,
                                  p_dest_program_cd,
                                  p_dest_prog_ver,
                                  p_dest_coo_id,
                                  l_unit_sets_to_transfer ,
                                  p_unit_sets_not_selected,
                                  p_unit_sets_having_errors,
                                  p_show_warning,
                                  p_return_status);


   -- validating and transfering Advance standing of  source program that need to be transfered to destination
   IF p_transfer_av = 'Y' THEN
      validate_advance_st_tran_dtls(p_person_id,
                                    p_source_program_cd,
                                    p_source_prog_ver,
                                    p_dest_program_cd,
                                    p_dest_prog_ver,
                                    p_show_warning);
   END IF; -- end of   p_transfer_av = 'Y'  IF THEN

   -- updating source program attempt status and other values during transfer
   update_source_prgm (p_person_id,
                       p_source_program_cd,
                       p_source_prog_ver,
                       p_dest_program_cd,
                       p_trans_approval_dt,
                       l_status_date,
                          -- passing l_status_date = SYSDATE to p_trans_actual_dt parameter.
                          -- This parameter is used while discontinuing the source program and has be >= Transfer date
                       l_dest_fut_dt_trans_flag,
                       p_discontinue_source,
                       l_tran_across_careers,
                       l_src_career_type);
   END IF;
   -- its an immediate transfer.

   IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml := FALSE;
   FND_MSG_PUB.COUNT_AND_GET( p_count   => p_msg_count,
                               p_data    => p_msg_data);

   IF p_show_warning = 'Y' AND p_msg_count > 0 THEN
      ROLLBACK TO TRANSFER_PRGM;
   END IF;

  EXCEPTION
      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
           IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml := FALSE;
           p_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_ENCODED(FND_MESSAGE.GET_ENCODED());
           FND_MSG_PUB.ADD;
           FND_MSG_PUB.COUNT_AND_GET( p_count          => p_msg_count,
                                     p_data           => p_msg_data);
           ROLLBACK TO TRANSFER_PRGM;
      WHEN FND_API.G_EXC_ERROR THEN
           IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml := FALSE;
           p_return_status := FND_API.G_RET_STS_ERROR;
           FND_MSG_PUB.COUNT_AND_GET( p_count          => p_msg_count,
                                     p_data           => p_msg_data);
           ROLLBACK TO TRANSFER_PRGM;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml := FALSE;
           p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.COUNT_AND_GET( p_count          => p_msg_count,
                                     p_data           => p_msg_data);
           IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.program_transfer_api :',SQLERRM);
           END IF;
           ROLLBACK TO TRANSFER_PRGM;
      WHEN OTHERS THEN
           IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml := FALSE;
           p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,
                                    l_api_name);
           END IF;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => p_msg_count,
                                     p_data           => p_msg_data);
           IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
                FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_program_transfer_apis.program_transfer_api :',SQLERRM);
           END IF;
           ROLLBACK TO TRANSFER_PRGM;

  END PROGRAM_TRANSFER_API;

  PROCEDURE log_err_messages(
    p_msg_count      IN NUMBER,
    p_msg_data       IN VARCHAR2,
    p_warn_and_err_msg OUT NOCOPY VARCHAR2
  ) AS
   -------------------------------------------------------------------------------------------
   -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
   -- purpose : this methos concatenates al the warning and error messages delimited by '<br>'
   --           that were recieved during program transfer.
   --Change History:
   --Who         When            What

   --------------------------------------------------------------------------------------------


    l_msg_count      NUMBER(4);
    l_msg_data       VARCHAR2(4000);
    l_enc_msg        VARCHAR2(2000);
    l_msg_index      NUMBER(4);
    l_msg_text       FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_warn_and_err_msg VARCHAR2(5000);

  BEGIN

    l_msg_count := p_msg_count;
    l_msg_data := p_msg_data;
    l_warn_and_err_msg := null;

    IF l_msg_count =1 THEN
      FND_MESSAGE.SET_ENCODED(l_msg_data);
      l_msg_text := FND_MESSAGE.GET;
      l_warn_and_err_msg := l_msg_text || '<br>';
    ELSIF l_msg_count > 1 THEN
      FOR l_index IN 1..NVL(l_msg_count,0)
      LOOP
            FND_MSG_PUB.GET(FND_MSG_PUB.G_FIRST,
                            FND_API.G_TRUE,
                            l_enc_msg,
                            l_msg_index);
            FND_MESSAGE.SET_ENCODED(l_enc_msg);
            l_msg_text := FND_MESSAGE.GET;
            l_warn_and_err_msg := l_warn_and_err_msg||l_msg_text || '<br>';

            FND_MSG_PUB.DELETE_MSG(l_msg_index);

      END LOOP;
    END IF;
    p_warn_and_err_msg := l_warn_and_err_msg;

  END log_err_messages;


  PROCEDURE cleanup_job(
     errbuf             OUT  NOCOPY   VARCHAR2,
     retcode            OUT   NOCOPY   NUMBER,
     p_term_cal_comb    IN   VARCHAR2,
     p_mode             IN   VARCHAR2,
     p_ignore_warnings  IN   VARCHAR2,
     p_drop_enrolled    IN   VARCHAR2
     ) AS
  -------------------------------------------------------------------------------------------
  -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
  --Change History:
  --Who         When            What
  --ckasu     20-Nov-2004     changed the order of parameters passed
  --ckasu     17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL) as a part of bug#4958173.
  --------------------------------------------------------------------------------------------

  BEGIN

      igs_ge_gen_003.set_org_id(NULL);
      IGS_EN_FUTURE_DT_TRANS.process_fut_dt_trans(errbuf,
                                                  retcode,
                                                  p_term_cal_comb,
                                                  p_mode,
                                                  p_ignore_warnings,
                                                  p_drop_enrolled);

  END CLEANUP_JOB;

    FUNCTION arrange_selected_unitsets(
         p_person_id               IN   NUMBER,
         p_program_cd       IN   VARCHAR2,
         p_unit_sets_to_transfer     IN   VARCHAR2
         ) RETURN VARCHAR2 IS
 -------------------------------------------------------------------------------------------
  -- Created by  : chanchal tyagi, Oracle Student Systems Oracle IDC
  --Change History:
  --Who         When            What
  --ctyagi     25-Nov-2005       changed the order of unitset_attempt string
  -------------------------------------------------------------------------------------------

    CURSOR c_parent_exist (c_person_id IGS_EN_STDNT_PS_ATT.PERSON_ID%TYPE,
                           c_program_cd IGS_EN_STDNT_PS_ATT.COURSE_CD%TYPE,
                           c_unitset_cd   IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE,
                           c_seq_no       IGS_AS_SU_SETATMPT.SEQUENCE_NUMBER%TYPE)
           IS
               SELECT 'x' FROM igs_as_su_setatmpt
               WHERE person_id = c_person_id
               AND  COURSE_CD =  c_program_cd
               AND  UNIT_SET_CD =   c_unitset_cd
               AND  SEQUENCE_NUMBER= c_seq_no
               AND PARENT_UNIT_SET_CD IS NOT NULL;

    CURSOR c_get_child (c_person_id IGS_EN_STDNT_PS_ATT.PERSON_ID%TYPE,
                        c_program_cd IGS_EN_STDNT_PS_ATT.COURSE_CD%TYPE,
                        c_unitset_cd   IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE,
                        c_seq_no       IGS_AS_SU_SETATMPT.SEQUENCE_NUMBER%TYPE)
    IS
      select  susa.unit_set_cd || ',' || susa.sequence_number  AS unitcd_seqno
       from igs_as_su_setatmpt susa
       where susa.person_id =  c_person_id
             AND SUSA.COURSE_CD= c_program_cd
             AND level >= 2
       START WITH
             susa.person_id		= c_person_id AND
             susa.course_cd		= c_program_cd AND
             susa.unit_set_cd		= c_unitset_cd AND
             susa.sequence_number	= c_seq_no
       CONNECT BY
       PRIOR susa.person_id			= susa.person_id AND
       PRIOR susa.course_cd			= susa.course_cd AND
       PRIOR susa.unit_set_cd = susa.parent_unit_set_cd AND
       PRIOR susa.sequence_number = susa.parent_sequence_number
    ORDER BY level;

    l_strtpoint NUMBER;
    l_endpoint  NUMBER;
    l_cindex    NUMBER;
    l_pre_cindex NUMBER;
    l_nth_occurence NUMBER;
    l_unitset_seqno_sep_index NUMBER;
    l_seqno_prmind_sep_index NUMBER;
    l_unitset_seqno_and_prmind VARCHAR2(4000);
    l_unitset  VARCHAR2(4000);
    l_seqno  NUMBER;
    l_prmind VARCHAR2(4000);
    l_unitsets_to_transfer VARCHAR2(4000);


    l_parent_unit_cd VARCHAR2(4000);

    l_sub_token1  NUMBER;
    l_sub_token2  NUMBER;
    l_count_token NUMBER;

    l_token_str  VARCHAR2(4000);

    l_dummy c_parent_exist%ROWTYPE;
    l_dummy_unitcd_seqno  c_get_child%ROWTYPE;

    l_final_selected_unitset VARCHAR2(4000);


 BEGIN

       IF  p_unit_sets_to_transfer IS NOT NULL THEN

           l_unitsets_to_transfer := p_unit_sets_to_transfer;
           l_count_token    :=  1;
           l_strtpoint      :=  0;
           l_pre_cindex     :=  0;
           l_nth_occurence  :=  1;
           l_cindex := INSTR(l_unitsets_to_transfer,';',1,l_nth_occurence);

           --single unit set attempt selected
           IF l_cindex = length(p_unit_sets_to_transfer) THEN
               return p_unit_sets_to_transfer ;
            END IF;

           -- loop to get uniset wihtout any parent unitset
           WHILE (l_cindex <> 0) LOOP
              l_strtpoint  :=  l_pre_cindex + 1;
              l_endpoint   :=  l_cindex - l_strtpoint;
              l_pre_cindex :=  l_cindex;
              l_unitset_seqno_and_prmind := substr(l_unitsets_to_transfer,l_strtpoint,l_endpoint);
              l_unitset_seqno_sep_index  := INSTR(l_unitset_seqno_and_prmind,',',1);
              l_seqno_prmind_sep_index   := INSTR(l_unitset_seqno_and_prmind,',',1,2);
              l_unitset   :=   SUBSTR(l_unitset_seqno_and_prmind,1,l_unitset_seqno_sep_index - 1);
              l_seqno     :=   TO_NUMBER(SUBSTR(l_unitset_seqno_and_prmind,l_unitset_seqno_sep_index+1,l_seqno_prmind_sep_index -(l_unitset_seqno_sep_index+1)));
              l_prmind    :=   SUBSTR(l_unitset_seqno_and_prmind,l_seqno_prmind_sep_index + 1);



               OPEN   c_parent_exist(p_person_id,p_program_cd,l_unitset,l_seqno);
               FETCH  c_parent_exist INTO l_dummy;
                IF   c_parent_exist%NOTFOUND THEN
                      CLOSE  c_parent_exist;
                      l_final_selected_unitset := l_final_selected_unitset || l_unitset_seqno_and_prmind || ';'  ;

                      l_count_token :=  l_count_token+1;
                      l_nth_occurence := l_nth_occurence + 1;
                      l_cindex := INSTR(l_unitsets_to_transfer,';',1,l_nth_occurence);
                ELSE
                CLOSE  c_parent_exist;
                      EXIT ;
                END IF;

           END LOOP;



           IF  l_cindex <   NVL(Length(l_unitsets_to_transfer),0) THEN


                 l_strtpoint      :=  0;
                 l_pre_cindex     :=  0;
                 l_nth_occurence  :=  1;

                 -- loop for all top parent and add the child record
                 WHILE  (l_count_token > 1 ) LOOP
                      l_cindex := INSTR(l_final_selected_unitset,';',1,l_nth_occurence);
                      l_strtpoint  :=  l_pre_cindex + 1;
                      l_endpoint   :=  l_cindex - l_strtpoint;
                      l_pre_cindex :=  l_cindex;
                      l_unitset_seqno_and_prmind := substr(l_unitsets_to_transfer,l_strtpoint,l_endpoint);
                      l_unitset_seqno_sep_index  := INSTR(l_unitset_seqno_and_prmind,',',1);
                      l_seqno_prmind_sep_index   := INSTR(l_unitset_seqno_and_prmind,',',1,2);
                      l_unitset   :=   SUBSTR(l_unitset_seqno_and_prmind,1,l_unitset_seqno_sep_index - 1);
                      l_seqno     :=   TO_NUMBER(SUBSTR(l_unitset_seqno_and_prmind,l_unitset_seqno_sep_index+1,l_seqno_prmind_sep_index -(l_unitset_seqno_sep_index+1)));
                      l_prmind    :=   SUBSTR(l_unitset_seqno_and_prmind,l_seqno_prmind_sep_index + 1);

                      FOR l_dummy_unitcd_seqno  IN   c_get_child(p_person_id,p_program_cd,l_unitset,l_seqno) LOOP

                              l_sub_token1 := InStr(p_unit_sets_to_transfer,l_dummy_unitcd_seqno.unitcd_seqno,1,1);

                              IF l_sub_token1 <> 0 THEN
                                l_sub_token2 := InStr(p_unit_sets_to_transfer,';',l_sub_token1,1);

                                l_token_str :=  SubStr(p_unit_sets_to_transfer,l_sub_token1,l_sub_token2-l_sub_token1);

                                l_final_selected_unitset := l_final_selected_unitset || l_token_str || ';';

                              END IF;
                      END LOOP;

                      l_nth_occurence := l_nth_occurence + 1;

                      l_count_token := l_count_token -1 ;
                 END LOOP;

           END IF;

        --  check if more unitset attempt string are peresent than processed till now
           IF NVL (LENGTH(l_final_selected_unitset),0) < LENGTH(p_unit_sets_to_transfer) THEN
               l_strtpoint      :=  0;
               l_pre_cindex     :=  0;
               l_nth_occurence  :=  1;

               l_cindex := INSTR(p_unit_sets_to_transfer,';',1,l_nth_occurence);

                WHILE (l_cindex <> 0) LOOP
                  l_strtpoint  :=  l_pre_cindex + 1;
                  l_endpoint   :=  l_cindex - l_strtpoint;
                  l_pre_cindex :=  l_cindex;
                  l_unitset_seqno_and_prmind := substr(p_unit_sets_to_transfer,l_strtpoint,l_endpoint);

                  l_sub_token1 := InStr(l_final_selected_unitset,l_unitset_seqno_and_prmind,1,1);

                  IF NVL(l_sub_token1,0) = 0 THEN
                      l_final_selected_unitset := l_final_selected_unitset || l_unitset_seqno_and_prmind || ';' ;
                  END IF;

                  IF NVL (LENGTH(l_final_selected_unitset),0) = LENGTH(p_unit_sets_to_transfer) THEN
                     exit ;
                  END IF;
                  l_nth_occurence := l_nth_occurence + 1;
                  l_cindex := INSTR(p_unit_sets_to_transfer,';',1,l_nth_occurence);
                END LOOP;


           END IF;

       ELSE
            return p_unit_sets_to_transfer;
       END IF;

    return l_final_selected_unitset;

  END  arrange_selected_unitsets;



END IGS_EN_TRANSFER_APIS;

/
