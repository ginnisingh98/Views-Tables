--------------------------------------------------------
--  DDL for Package Body IGS_AD_WF_P2A
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_WF_P2A" AS
/* $Header: IGSADD4B.pls 120.2 2005/11/21 05:48:43 appldev noship $ */
---------------------------------------------------------------------------------------------------------------------------------------
--  Created By : akadam
--  Date Created On : 06-JUL-2005
--  Purpose : Bug: Prospect to Applicant Management Build.
--  Change History
--  Who             When            What
--
---------------------------------------------------------------------------------------------------------------------------------------

  TYPE DFFAttributeSet IS TABLE OF IGS_SS_APP_PGM_STG.attribute1%TYPE;
  g_dff_attribute DFFAttributeSet;
  g_dff_attribute_category IGS_SS_APP_PGM_STG.attribute_category%TYPE;



 PROCEDURE set_return_message(
            itemtype  in  VARCHAR2,
	        itemkey   in  VARCHAR2,
            message_name in VARCHAR2,
            message_count in NUMBER,
            return_status in VARCHAR2,
            message_token in VARCHAR2 DEFAULT NULL,
            message_token_text in VARCHAR2 DEFAULT NULL) IS

 l_msg_idx_start               NUMBER;
 l_msg_index                   NUMBER;
 l_app_nme                     VARCHAR2(1000);
 l_msg_nme                     VARCHAR2(2000);
 l_msg_txt                     fnd_new_messages.message_text%TYPE;

  BEGIN
    wf_engine.setitemattrtext(itemtype,itemkey,'P_RETURN_STATUS',return_status);
    wf_engine.setitemattrnumber(itemtype,itemkey,'P_MSG_COUNT',message_count);

    l_msg_index := igs_ge_msg_stack.count_msg;
    FND_MESSAGE.SET_NAME('IGS',message_name);
    IF message_token IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(message_token ,message_token_text);
    END IF;
    IGS_GE_MSG_STACK.ADD;

    igs_ge_msg_stack.get(l_msg_index + 1,'T',l_msg_txt,l_msg_idx_start);
    igs_ge_msg_stack.delete_msg(l_msg_idx_start);
    fnd_message.parse_encoded (l_msg_txt, l_app_nme, l_msg_nme);
    fnd_message.set_encoded (l_msg_txt);
    l_msg_txt := fnd_message.get;

    wf_engine.setitemattrtext(itemtype,itemkey,'P_MSG_DATA',l_msg_txt);
  END set_return_message;

  PROCEDURE call_apl_pre_crt_apis(
            itemtype  in  VARCHAR2  ,
	    itemkey   in  VARCHAR2  ,
	    actid     in  NUMBER   ,
            funcmode  in  VARCHAR2  ,
	    resultout   OUT NOCOPY VARCHAR2 )

  ------------------------------------------------------------------
    --Created by  : akadam, Oracle IDC
    --Date created: 10-OCT-2003
    --
    --Purpose: Prospect to Applicant Management Build
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
  -------------------------------------------------------------------
  IS

    CURSOR c_app_type_det ( cp_app_type IGS_AD_SS_APPL_TYP.admission_application_type%TYPE) IS
      SELECT  admission_cat,s_admission_process_type
      FROM  igs_ad_ss_appl_typ
      WHERE admission_application_type = cp_app_type;

    CURSOR c_seq_num IS
      SELECT IGS_SS_ADM_APPL_S.NEXTVAL
      FROM sys.dual;

    l_person_id IGS_PE_HZ_PARTIES.party_id%TYPE;
    l_login_role VARCHAR2(30);
    l_acad_cal_type IGS_CA_INST_ALL.cal_type%TYPE;
    l_acad_cal_seq_number IGS_CA_INST_ALL.sequence_number%TYPE;
    l_adm_cal_type IGS_CA_INST_ALL.cal_type%TYPE;
    l_adm_ci_sequence_number IGS_CA_INST_ALL.sequence_number%TYPE;
    l_application_type IGS_AD_SS_APPL_TYP.admission_application_type%TYPE;
    l_location_code IGS_SS_APP_PGM_STG.location_cd%TYPE;
    l_program_type IGS_PS_TYPE_ALL.course_type%TYPE;
    l_sch_apl_to_id IGS_SS_APP_PGM_STG.sch_apl_to_id%TYPE;
    l_attendance_type IGS_SS_APP_PGM_STG.attendance_type%TYPE;
    l_attendance_mode IGS_SS_APP_PGM_STG.attendance_mode%TYPE;
    l_entry_status IGS_SS_ADM_APPL_STG.entry_status%TYPE;
    l_entry_level IGS_SS_ADM_APPL_STG.entry_level%TYPE;
    l_spcl_gr1 IGS_SS_ADM_APPL_STG.spcl_grp_1%TYPE;
    l_spcl_gr2 IGS_SS_ADM_APPL_STG.spcl_grp_2%TYPE;
    l_apply_for_finaid IGS_SS_ADM_APPL_STG.apply_for_finaid%TYPE;
    l_finaid_apply_date IGS_SS_ADM_APPL_STG.finaid_apply_date%TYPE;
    l_application_fee_amount IGS_SS_ADM_APPL_STG.appl_fee_amt%TYPE;


    l_admission_cat IGS_AD_SS_APPL_TYP.admission_cat%TYPE;
    l_s_process_type IGS_AD_SS_APPL_TYP.s_admission_process_type%TYPE;
    l_seq_val           NUMBER;
    l_appl_source_id   IGS_AD_CODE_CLASSES.code_id%TYPE;

    l_return_status VARCHAR2(3);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_ss_adm_appl_id NUMBER;
    l_ss_admappl_pgm_id NUMBER;

  BEGIN

    IF funcmode='RUN' THEN

      l_person_id                     := wf_engine.getitemattrnumber(itemtype,itemkey,'P_PERSON_ID');
      l_login_role                    := wf_engine.getitemattrtext(itemtype,itemkey,'P_LOGIN_RESP');
      l_acad_cal_type                 := wf_engine.getitemattrtext(itemtype,itemkey,'P_ACAD_CAL_TYPE');
      l_acad_cal_seq_number           := wf_engine.getitemattrnumber(itemtype,itemkey,'P_ACAD_CAL_SEQ_NUMBER');
      l_adm_cal_type                  := wf_engine.getitemattrtext(itemtype,itemkey,'P_ADM_CAL_TYPE');
      l_adm_ci_sequence_number        := wf_engine.getitemattrnumber(itemtype,itemkey,'P_ADM_CI_SEQUENCE_NUMBER');
      l_application_type              := wf_engine.getitemattrtext(itemtype,itemkey,'P_APPLICATION_TYPE');
      l_location_code                 := wf_engine.getitemattrtext(itemtype,itemkey,'P_LOCATION_CODE');
      l_program_type                  := wf_engine.getitemattrtext(itemtype,itemkey,'P_PROGRAM_TYPE');
      l_sch_apl_to_id                 := wf_engine.getitemattrnumber(itemtype,itemkey,'P_SCH_APL_TO_ID');
      l_attendance_type               := wf_engine.getitemattrtext(itemtype,itemkey,'P_ATTENDANCE_TYPE');
      l_attendance_mode               := wf_engine.getitemattrtext(itemtype,itemkey,'P_ATTENDANCE_MODE');
      l_entry_status                  := wf_engine.getitemattrtext(itemtype,itemkey,'P_ENTRY_STATUS');
      l_entry_level                   := wf_engine.getitemattrtext(itemtype,itemkey,'P_ENTRY_LEVEL');
      l_spcl_gr1                      := wf_engine.getitemattrtext(itemtype,itemkey,'P_SPCL_GR1');
      l_spcl_gr2                      := wf_engine.getitemattrtext(itemtype,itemkey,'P_SPCL_GR2');
      l_apply_for_finaid              := wf_engine.getitemattrtext(itemtype,itemkey,'P_APPLY_FOR_FINAID');
      l_finaid_apply_date             := wf_engine.getitemattrtext(itemtype,itemkey,'P_APPLY_FOR_FINAID');
      l_application_fee_amount        := wf_engine.getitemattrtext(itemtype,itemkey,'P_APPLICATION_FEE_AMOUNT');
      l_appl_source_id                := wf_engine.getitemattrtext(itemtype,itemkey,'P_APPL_SOURCE_ID');

      l_admission_cat := NULL;
      l_s_process_type := NULL;

      l_return_status := NULL;
      l_msg_count := NULL;
      l_msg_data := NULL;
      l_ss_adm_appl_id := NULL;
      l_ss_admappl_pgm_id := NULL;

      OPEN c_app_type_det(l_application_type);
      FETCH c_app_type_det INTO l_admission_cat,l_s_process_type;
      CLOSE c_app_type_det;


      SAVEPOINT PRE_CREATE_APPLICATION_WF;

      IGS_PRECREATE_APPL_PUB.PRE_CREATE_APPLICATION(
        p_api_version => 1.0,
	    p_init_msg_list => null,
	    p_commit => null,
	    p_validation_level => 0,
	    x_return_status => l_return_status,
	    x_msg_count => l_msg_count,
	    x_msg_data => l_msg_data,
	    p_person_id => l_person_id,
	    p_appl_date => trunc(SYSDATE),
	    p_acad_cal_type => l_acad_cal_type,
	    p_acad_cal_seq_number => l_acad_cal_seq_number,
	    p_adm_cal_type => l_adm_cal_type,
	    p_adm_cal_seq_number => l_adm_ci_sequence_number,
	    p_entry_status => l_entry_status,
	    p_entry_level => l_entry_level,
	    p_spcl_gr1 => l_spcl_gr1,
	    p_spcl_gr2 => l_spcl_gr2,
	    p_apply_for_finaid => l_apply_for_finaid,
	    p_finaid_apply_date => l_finaid_apply_date,
	    p_admission_application_type => l_application_type,
	    p_apsource_id => l_appl_source_id,
	    p_application_fee_amount => l_application_fee_amount,
	    x_ss_adm_appl_id => l_ss_adm_appl_id
	);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          wf_engine.setitemattrtext(itemtype,itemkey,'P_RETURN_STATUS',l_return_status);
          wf_engine.setitemattrnumber(itemtype,itemkey,'P_MSG_COUNT',1);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_MSG_DATA',l_msg_data);
          resultout := 'COMPLETE:ERROR';
          RETURN;
      END IF;

      IF (l_attendance_type IS NOT NULL OR
         l_location_code   IS NOT NULL OR
         l_attendance_mode   IS NOT NULL ) AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN

         l_return_status := NULL;
         l_msg_count := NULL;
         l_msg_data := NULL;

         IGS_PRECREATE_APPL_PUB.PRE_CREATE_APPLICATION_INST(
			p_api_version => 1.0,
			p_init_msg_list => null,
			p_commit => null,
			p_validation_level => 0,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			p_ss_adm_appl_id => l_ss_adm_appl_id,
			p_sch_apl_to_id => l_sch_apl_to_id,
			p_location_cd => l_location_code,
			p_attendance_type => l_attendance_type,
			p_attendance_mode => l_attendance_mode,
			p_attribute_category => g_dff_attribute_category ,
			p_attribute1 => g_dff_attribute(1),
			p_attribute2 => g_dff_attribute(2),
			p_attribute3 => g_dff_attribute(3),
			p_attribute4 => g_dff_attribute(4),
			p_attribute5 => g_dff_attribute(5),
			p_attribute6 => g_dff_attribute(6),
			p_attribute7 => g_dff_attribute(7),
			p_attribute8 => g_dff_attribute(8),
			p_attribute9 => g_dff_attribute(9),
			p_attribute10 => g_dff_attribute(10),
			p_attribute11 => g_dff_attribute(11),
			p_attribute12 => g_dff_attribute(12),
			p_attribute13 => g_dff_attribute(13),
			p_attribute14 => g_dff_attribute(14),
			p_attribute15 => g_dff_attribute(15),
			p_attribute16 => g_dff_attribute(16),
			p_attribute17 => g_dff_attribute(17),
			p_attribute18 => g_dff_attribute(18),
			p_attribute19 => g_dff_attribute(19),
			p_attribute20 => g_dff_attribute(20),
			p_attribute21 => g_dff_attribute(21),
			p_attribute22 => g_dff_attribute(22),
			p_attribute23 => g_dff_attribute(23),
			p_attribute24 => g_dff_attribute(24),
			p_attribute25 => g_dff_attribute(25),
			p_attribute26 => g_dff_attribute(26),
			p_attribute27 => g_dff_attribute(27),
			p_attribute28 => g_dff_attribute(28),
			p_attribute29 => g_dff_attribute(29),
			p_attribute30 => g_dff_attribute(30),
			p_attribute31 => g_dff_attribute(31),
			p_attribute32 => g_dff_attribute(32),
			p_attribute33 => g_dff_attribute(33),
			p_attribute34 => g_dff_attribute(34),
			p_attribute35 => g_dff_attribute(35),
			p_attribute36 => g_dff_attribute(36),
			p_attribute37 => g_dff_attribute(37),
			p_attribute38 => g_dff_attribute(38),
			p_attribute39 => g_dff_attribute(39),
			p_attribute40 => g_dff_attribute(40),
			x_ss_admappl_pgm_id => l_ss_admappl_pgm_id
            );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          ROLLBACK TO PRE_CREATE_APPLICATION_WF;
          wf_engine.setitemattrtext(itemtype,itemkey,'P_RETURN_STATUS',l_return_status);
          wf_engine.setitemattrnumber(itemtype,itemkey,'P_MSG_COUNT',1);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_MSG_DATA',l_msg_data);
          resultout := 'COMPLETE:ERROR';
          RETURN;
        END IF;

      END IF;


      set_return_message(itemtype,itemkey,null,null,'S');
      wf_engine.setitemattrtext(itemtype,itemkey,'P_SS_ADM_APPL_ID', l_ss_adm_appl_id);

      resultout := 'COMPLETE:SUCCESS';

    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        set_return_message(itemtype,itemkey,'IGS_GE_UNHANDLED_EXP',1,'U','NAME','CALL_APL_PRE_CRT_APIS');

        WF_CORE.CONTEXT ('IGS_AD_WF_P2A', 'CALL_APL_PRE_CRT_APIS', itemtype,
                          itemkey, to_char(actid), funcmode);
        RAISE;

  END call_apl_pre_crt_apis;


  PROCEDURE call_drv_usr_hks(
            itemtype  in  VARCHAR2  ,
	    itemkey   in  VARCHAR2  ,
	    actid     in  NUMBER   ,
            funcmode  in  VARCHAR2  ,
	    resultout   OUT NOCOPY VARCHAR2 ) IS


     CURSOR c_appl_fee_amount ( cp_app_type IGS_AD_SS_APPL_TYP.admission_application_type%TYPE) IS
       SELECT application_fee_amount,admission_application_type
       FROM igs_ad_ss_appl_typ
       WHERE admission_application_type = cp_app_type;

     CURSOR c_appl_type_uhk_prl IS
       SELECT  FND_PROFILE.VALUE('IGS_AD_APPL_TYPE_UHK') value
       FROM dual;

     CURSOR c_appl_fee_uhk_prl IS
       SELECT  FND_PROFILE.VALUE('IGS_AD_APPL_FEE_UHK') value
       FROM dual;

     l_person_id IGS_PE_HZ_PARTIES.party_id%TYPE;
     l_login_role VARCHAR2(30);
     l_acad_cal_type IGS_CA_INST_ALL.cal_type%TYPE;
     l_acad_cal_seq_number IGS_CA_INST_ALL.sequence_number%TYPE;
     l_adm_cal_type IGS_CA_INST_ALL.cal_type%TYPE;
     l_adm_ci_sequence_number IGS_CA_INST_ALL.sequence_number%TYPE;
     l_application_type IGS_AD_SS_APPL_TYP.admission_application_type%TYPE;
     l_location_code IGS_SS_APP_PGM_STG.location_cd%TYPE;
     l_program_type IGS_PS_TYPE_ALL.course_type%TYPE;
     l_sch_apl_to_id IGS_SS_APP_PGM_STG.sch_apl_to_id%TYPE;
     l_attendance_type IGS_SS_APP_PGM_STG.attendance_type%TYPE;
     l_attendance_mode IGS_SS_APP_PGM_STG.attendance_mode%TYPE;
     l_oo_attribute_1 VARCHAR2(1);
     l_oo_attribute_2 VARCHAR2(1);
     l_oo_attribute_3 VARCHAR2(1);
     l_oo_attribute_4 VARCHAR2(1);
     l_oo_attribute_5 VARCHAR2(1);
     l_oo_attribute_6 VARCHAR2(1);
     l_oo_attribute_7 VARCHAR2(1);
     l_oo_attribute_8 VARCHAR2(1);
     l_oo_attribute_9 VARCHAR2(1);
     l_oo_attribute_10 VARCHAR2(1);
     l_citizenship_residency_ind VARCHAR2(1);
     l_cit_res_attribute_1 VARCHAR2(1);
     l_cit_res_attribute_2 VARCHAR2(1);
     l_cit_res_attribute_3 VARCHAR2(1);
     l_cit_res_attribute_4 VARCHAR2(1);
     l_cit_res_attribute_5 VARCHAR2(1);
     l_cit_res_attribute_6 VARCHAR2(1);
     l_cit_res_attribute_7 VARCHAR2(1);
     l_cit_res_attribute_8 VARCHAR2(1);
     l_cit_res_attribute_9 VARCHAR2(1);
     l_cit_res_attribute_10 VARCHAR2(1);
     l_state_of_res_type_code VARCHAR2(30);
     l_dom_attribute_1 VARCHAR2(1);
     l_dom_attribute_2 VARCHAR2(1);
     l_dom_attribute_3 VARCHAR2(1);
     l_dom_attribute_4 VARCHAR2(1);
     l_dom_attribute_5 VARCHAR2(1);
     l_dom_attribute_6 VARCHAR2(1);
     l_dom_attribute_7 VARCHAR2(1);
     l_dom_attribute_8 VARCHAR2(1);
     l_dom_attribute_9 VARCHAR2(1);
     l_dom_attribute_10 VARCHAR2(1);
     l_gen_attribute_1 VARCHAR2(1);
     l_gen_attribute_2 VARCHAR2(1);
     l_gen_attribute_3 VARCHAR2(1);
     l_gen_attribute_4 VARCHAR2(1);
     l_gen_attribute_5 VARCHAR2(1);
     l_gen_attribute_6 VARCHAR2(1);
     l_gen_attribute_7 VARCHAR2(1);
     l_gen_attribute_8 VARCHAR2(1);
     l_gen_attribute_9 VARCHAR2(1);
     l_gen_attribute_10 VARCHAR2(1);
     l_gen_attribute_11 VARCHAR2(1);
     l_gen_attribute_12 VARCHAR2(1);
     l_gen_attribute_13 VARCHAR2(1);
     l_gen_attribute_14 VARCHAR2(1);
     l_gen_attribute_15 VARCHAR2(1);
     l_gen_attribute_16 VARCHAR2(1);
     l_gen_attribute_17 VARCHAR2(1);
     l_gen_attribute_18 VARCHAR2(1);
     l_gen_attribute_19 VARCHAR2(1);
     l_gen_attribute_20 VARCHAR2(1);
     l_entry_status IGS_SS_ADM_APPL_STG.entry_status%TYPE;
     l_entry_level IGS_SS_ADM_APPL_STG.entry_level%TYPE;
     l_spcl_gr1 IGS_SS_ADM_APPL_STG.spcl_grp_1%TYPE;
     l_spcl_gr2 IGS_SS_ADM_APPL_STG.spcl_grp_2%TYPE;
     l_apply_for_finaid IGS_SS_ADM_APPL_STG.apply_for_finaid%TYPE;
     l_finaid_apply_date IGS_SS_ADM_APPL_STG.finaid_apply_date%TYPE;
     l_application_fee_amount IGS_SS_ADM_APPL_STG.appl_fee_amt%TYPE;

     l_application_fee_amount_test IGS_SS_ADM_APPL_STG.appl_fee_amt%TYPE;

     cl_appl_type IGS_AD_SS_APPL_TYP.admission_application_type%TYPE;
     l_result VARCHAR2(30);
     l_appl_type_uhk_prl c_appl_type_uhk_prl%ROWTYPE;
     l_appl_fee_uhk_prl c_appl_fee_uhk_prl%ROWTYPE;
     l_appl_date DATE;
     i BINARY_INTEGER;
  BEGIN

    IF g_dff_attribute IS NULL THEN

      g_dff_attribute := DFFAttributeSet(null,null,null,null,null,null,null,null,null,null,
                                         null,null,null,null,null,null,null,null,null,null,
                                         null,null,null,null,null,null,null,null,null,null,
                                         null,null,null,null,null,null,null,null,null,null,null);
    ELSE
     FOR i IN g_dff_attribute.FIRST..g_dff_attribute.LAST LOOP

     g_dff_attribute(i) := null;
     END LOOP;

    END IF;

    g_dff_attribute_category := NULL;
    cl_appl_type := NULL;
    l_appl_fee_uhk_prl := NULL;
    l_appl_type_uhk_prl := NULL;

    OPEN c_appl_type_uhk_prl;
    FETCH c_appl_type_uhk_prl INTO l_appl_type_uhk_prl;
    CLOSE c_appl_type_uhk_prl;

    l_appl_date := trunc(SYSDATE);

    IF funcmode='RUN' THEN

      l_person_id                     := wf_engine.getitemattrnumber(itemtype,itemkey,'P_PERSON_ID');
      l_login_role                  	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_LOGIN_RESP');
      l_acad_cal_type               	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_ACAD_CAL_TYPE');
      l_acad_cal_seq_number         	:= wf_engine.getitemattrnumber(itemtype,itemkey,'P_ACAD_CAL_SEQ_NUMBER');
      l_adm_cal_type                	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_ADM_CAL_TYPE');
      l_adm_ci_sequence_number      	:= wf_engine.getitemattrnumber(itemtype,itemkey,'P_ADM_CI_SEQUENCE_NUMBER');
      l_application_type            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_APPLICATION_TYPE');
      l_location_code               	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_LOCATION_CODE');
      l_program_type                	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_PROGRAM_TYPE');
      l_sch_apl_to_id               	:= wf_engine.getitemattrnumber(itemtype,itemkey,'P_SCH_APL_TO_ID');
      l_attendance_type             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_ATTENDANCE_TYPE');
      l_attendance_mode             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_ATTENDANCE_MODE');
      l_oo_attribute_1              	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_OO_ATTRIBUTE_1');
      l_oo_attribute_2              	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_OO_ATTRIBUTE_2');
      l_oo_attribute_3              	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_OO_ATTRIBUTE_3');
      l_oo_attribute_4              	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_OO_ATTRIBUTE_4');
      l_oo_attribute_5              	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_OO_ATTRIBUTE_5');
      l_oo_attribute_6              	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_OO_ATTRIBUTE_6');
      l_oo_attribute_7              	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_OO_ATTRIBUTE_7');
      l_oo_attribute_8                  := wf_engine.getitemattrtext(itemtype,itemkey,'P_OO_ATTRIBUTE_8');
      l_oo_attribute_9              	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_OO_ATTRIBUTE_9');
      l_oo_attribute_10             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_OO_ATTRIBUTE_10');
      l_citizenship_residency_ind   	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CITIZENSHIP_RESIDENCY_IND');
      l_cit_res_attribute_1         	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CIT_RES_ATTRIBUTE_1');
      l_cit_res_attribute_2         	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CIT_RES_ATTRIBUTE_2');
      l_cit_res_attribute_3         	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CIT_RES_ATTRIBUTE_3');
      l_cit_res_attribute_4         	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CIT_RES_ATTRIBUTE_4');
      l_cit_res_attribute_5         	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CIT_RES_ATTRIBUTE_5');
      l_cit_res_attribute_6         	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CIT_RES_ATTRIBUTE_6');
      l_cit_res_attribute_7         	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CIT_RES_ATTRIBUTE_7');
      l_cit_res_attribute_8         	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CIT_RES_ATTRIBUTE_8');
      l_cit_res_attribute_9         	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CIT_RES_ATTRIBUTE_9');
      l_cit_res_attribute_10        	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_CIT_RES_ATTRIBUTE_10');
      l_state_of_res_type_code      	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_STATE_OF_RES_TYPE_CODE');
      l_dom_attribute_1             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_DOM_ATTRIBUTE_1');
      l_dom_attribute_2             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_DOM_ATTRIBUTE_2');
      l_dom_attribute_3             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_DOM_ATTRIBUTE_3');
      l_dom_attribute_4             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_DOM_ATTRIBUTE_4');
      l_dom_attribute_5             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_DOM_ATTRIBUTE_5');
      l_dom_attribute_6                 := wf_engine.getitemattrtext(itemtype,itemkey,'P_DOM_ATTRIBUTE_6');
      l_dom_attribute_7             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_DOM_ATTRIBUTE_7');
      l_dom_attribute_8             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_DOM_ATTRIBUTE_8');
      l_dom_attribute_9             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_DOM_ATTRIBUTE_9');
      l_dom_attribute_10            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_DOM_ATTRIBUTE_10');
      l_gen_attribute_1             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_1');
      l_gen_attribute_2             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_2');
      l_gen_attribute_3             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_3');
      l_gen_attribute_4             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_4');
      l_gen_attribute_5             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_5');
      l_gen_attribute_6             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_6');
      l_gen_attribute_7             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_7');
      l_gen_attribute_8             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_8');
      l_gen_attribute_9             	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_9');
      l_gen_attribute_10            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_10');
      l_gen_attribute_11            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_11');
      l_gen_attribute_12            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_12');
      l_gen_attribute_13            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_13');
      l_gen_attribute_14            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_14');
      l_gen_attribute_15            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_15');
      l_gen_attribute_16            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_16');
      l_gen_attribute_17            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_17');
      l_gen_attribute_18            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_18');
      l_gen_attribute_19            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_19');
      l_gen_attribute_20            	:= wf_engine.getitemattrtext(itemtype,itemkey,'P_GEN_ATTRIBUTE_20');

      IF l_appl_type_uhk_prl.value ='Y' THEN

        igs_ad_uhk_pre_create_appl_pkg.derive_app_type (
          p_person_id                     =>   l_person_id,
          p_login_resp                    =>   l_login_role,
          p_acad_cal_type                 =>   l_acad_cal_type,
          p_acad_cal_seq_number           =>   l_acad_cal_seq_number,
          p_adm_cal_type                  =>   l_adm_cal_type,
          p_adm_ci_sequence_number        =>   l_adm_ci_sequence_number,
          p_application_type              =>   l_application_type,
          p_location_code                 =>   l_location_code,
          p_program_type                  =>   l_program_type,
          p_sch_apl_to_id                 =>   l_sch_apl_to_id,
          p_attendance_type               =>   l_attendance_type,
          p_attendance_mode               =>   l_attendance_mode,
          p_oo_attribute_1                =>   l_oo_attribute_1,
          p_oo_attribute_2                =>   l_oo_attribute_2,
          p_oo_attribute_3                =>   l_oo_attribute_3,
          p_oo_attribute_4                =>   l_oo_attribute_4,
          p_oo_attribute_5                =>   l_oo_attribute_5,
          p_oo_attribute_6                =>   l_oo_attribute_6,
          p_oo_attribute_7                =>   l_oo_attribute_7,
          p_oo_attribute_8                =>   l_oo_attribute_8,
          p_oo_attribute_9                =>   l_oo_attribute_9,
          p_oo_attribute_10               =>   l_oo_attribute_10,
          p_citizenship_residency_ind     =>   l_citizenship_residency_ind,
          p_cit_res_attribute_1           =>   l_cit_res_attribute_1,
          p_cit_res_attribute_2           =>   l_cit_res_attribute_2,
          p_cit_res_attribute_3           =>   l_cit_res_attribute_3,
          p_cit_res_attribute_4           =>   l_cit_res_attribute_4,
          p_cit_res_attribute_5           =>   l_cit_res_attribute_5,
          p_cit_res_attribute_6           =>   l_cit_res_attribute_6,
          p_cit_res_attribute_7           =>   l_cit_res_attribute_7,
          p_cit_res_attribute_8           =>   l_cit_res_attribute_8,
          p_cit_res_attribute_9           =>   l_cit_res_attribute_9,
          p_cit_res_attribute_10          =>   l_cit_res_attribute_10,
          p_state_of_res_type_code        =>   l_state_of_res_type_code,
          p_dom_attribute_1               =>   l_dom_attribute_1,
          p_dom_attribute_2               =>   l_dom_attribute_2,
          p_dom_attribute_3               =>   l_dom_attribute_3,
          p_dom_attribute_4               =>   l_dom_attribute_4,
          p_dom_attribute_5               =>   l_dom_attribute_5,
          p_dom_attribute_6               =>   l_dom_attribute_6,
          p_dom_attribute_7               =>   l_dom_attribute_7,
          p_dom_attribute_8               =>   l_dom_attribute_8,
          p_dom_attribute_9               =>   l_dom_attribute_9,
          p_dom_attribute_10              =>   l_dom_attribute_10,
          p_gen_attribute_1               =>   l_gen_attribute_1,
          p_gen_attribute_2               =>   l_gen_attribute_2,
          p_gen_attribute_3               =>   l_gen_attribute_3,
          p_gen_attribute_4               =>   l_gen_attribute_4,
          p_gen_attribute_5               =>   l_gen_attribute_5,
          p_gen_attribute_6               =>   l_gen_attribute_6,
          p_gen_attribute_7               =>   l_gen_attribute_7,
          p_gen_attribute_8               =>   l_gen_attribute_8,
          p_gen_attribute_9               =>   l_gen_attribute_9,
          p_gen_attribute_10              =>   l_gen_attribute_10,
          p_gen_attribute_11              =>   l_gen_attribute_11,
          p_gen_attribute_12              =>   l_gen_attribute_12,
          p_gen_attribute_13              =>   l_gen_attribute_13,
          p_gen_attribute_14              =>   l_gen_attribute_14,
          p_gen_attribute_15              =>   l_gen_attribute_15,
          p_gen_attribute_16              =>   l_gen_attribute_16,
          p_gen_attribute_17              =>   l_gen_attribute_17,
          p_gen_attribute_18              =>   l_gen_attribute_18,
          p_gen_attribute_19              =>   l_gen_attribute_19,
          p_gen_attribute_20              =>   l_gen_attribute_20,
          p_entry_status                  =>   l_entry_status,
          p_entry_level                   =>   l_entry_level,
          p_spcl_gr1                      =>   l_spcl_gr1,
          p_spcl_gr2                      =>   l_spcl_gr2,
          p_apply_for_finaid              =>   l_apply_for_finaid,
          p_finaid_apply_date             =>   l_finaid_apply_date,
          p_appl_date                     =>   l_appl_date,
          p_attribute_category            =>   g_dff_attribute_category,
          p_attribute1                    =>   g_dff_attribute(1),
          p_attribute2                    =>   g_dff_attribute(2),
          p_attribute3                    =>   g_dff_attribute(3),
          p_attribute4                    =>   g_dff_attribute(4),
          p_attribute5                    =>   g_dff_attribute(5),
          p_attribute6                    =>   g_dff_attribute(6),
          p_attribute7                    =>   g_dff_attribute(7),
          p_attribute8                    =>   g_dff_attribute(8),
          p_attribute9                    =>   g_dff_attribute(9),
          p_attribute10                   =>   g_dff_attribute(10),
          p_attribute11                   =>   g_dff_attribute(11),
          p_attribute12                   =>   g_dff_attribute(12),
          p_attribute13                   =>   g_dff_attribute(13),
          p_attribute14                   =>   g_dff_attribute(14),
          p_attribute15                   =>   g_dff_attribute(15),
          p_attribute16                   =>   g_dff_attribute(16),
          p_attribute17                   =>   g_dff_attribute(17),
          p_attribute18                   =>   g_dff_attribute(18),
          p_attribute19                   =>   g_dff_attribute(19),
          p_attribute20                   =>   g_dff_attribute(20),
          p_attribute21                   =>   g_dff_attribute(21),
          p_attribute22                   =>   g_dff_attribute(22),
          p_attribute23                   =>   g_dff_attribute(23),
          p_attribute24                   =>   g_dff_attribute(24),
          p_attribute25                   =>   g_dff_attribute(25),
          p_attribute26                   =>   g_dff_attribute(26),
          p_attribute27                   =>   g_dff_attribute(27),
          p_attribute28                   =>   g_dff_attribute(28),
          p_attribute29                   =>   g_dff_attribute(29),
          p_attribute30                   =>   g_dff_attribute(30),
          p_attribute31                   =>   g_dff_attribute(31),
          p_attribute32                   =>   g_dff_attribute(32),
          p_attribute33                   =>   g_dff_attribute(33),
          p_attribute34                   =>   g_dff_attribute(34),
          p_attribute35                   =>   g_dff_attribute(35),
          p_attribute36                   =>   g_dff_attribute(36),
          p_attribute37                   =>   g_dff_attribute(37),
          p_attribute38                   =>   g_dff_attribute(38),
          p_attribute39                   =>   g_dff_attribute(39),
          p_attribute40                   =>   g_dff_attribute(40)
          );
      END IF;

        OPEN c_appl_fee_amount(l_application_type);
        FETCH c_appl_fee_amount INTO l_application_fee_amount,cl_appl_type;
        CLOSE c_appl_fee_amount;

        IF l_application_fee_amount IS NULL THEN
             l_application_fee_amount := 0;
        END IF;

        OPEN c_appl_fee_uhk_prl;
        FETCH c_appl_fee_uhk_prl INTO l_appl_fee_uhk_prl;
        CLOSE c_appl_fee_uhk_prl;

        IF l_appl_fee_uhk_prl.value = 'Y' THEN

          igs_ad_uhk_pre_create_appl_pkg.derive_app_fee (
            p_person_id                     =>   l_person_id,
            p_login_resp                    =>   l_login_role,
            p_acad_cal_type                 =>   l_acad_cal_type,
            p_acad_cal_seq_number           =>   l_acad_cal_seq_number,
            p_adm_cal_type                  =>   l_adm_cal_type,
            p_adm_ci_sequence_number        =>   l_adm_ci_sequence_number,
            p_application_type              =>   l_application_type,
            p_application_fee_amount        =>   l_application_fee_amount,
            p_location_code                 =>   l_location_code,
            p_program_type                  =>   l_program_type,
            p_sch_apl_to_id                 =>   l_sch_apl_to_id,
            p_attendance_type               =>   l_attendance_type,
            p_attendance_mode               =>   l_attendance_mode,
            p_oo_attribute_1                =>   l_oo_attribute_1,
            p_oo_attribute_2                =>   l_oo_attribute_2,
            p_oo_attribute_3                =>   l_oo_attribute_3,
            p_oo_attribute_4                =>   l_oo_attribute_4,
            p_oo_attribute_5                =>   l_oo_attribute_5,
            p_oo_attribute_6                =>   l_oo_attribute_6,
            p_oo_attribute_7                =>   l_oo_attribute_7,
            p_oo_attribute_8                =>   l_oo_attribute_8,
            p_oo_attribute_9                =>   l_oo_attribute_9,
            p_oo_attribute_10               =>   l_oo_attribute_10,
            p_citizenship_residency_ind     =>   l_citizenship_residency_ind,
            p_cit_res_attribute_1           =>   l_cit_res_attribute_1,
            p_cit_res_attribute_2           =>   l_cit_res_attribute_2,
            p_cit_res_attribute_3           =>   l_cit_res_attribute_3,
            p_cit_res_attribute_4           =>   l_cit_res_attribute_4,
            p_cit_res_attribute_5           =>   l_cit_res_attribute_5,
            p_cit_res_attribute_6           =>   l_cit_res_attribute_6,
            p_cit_res_attribute_7           =>   l_cit_res_attribute_7,
            p_cit_res_attribute_8           =>   l_cit_res_attribute_8,
            p_cit_res_attribute_9           =>   l_cit_res_attribute_9,
            p_cit_res_attribute_10          =>   l_cit_res_attribute_10,
            p_state_of_res_type_code        =>   l_state_of_res_type_code,
            p_dom_attribute_1               =>   l_dom_attribute_1,
            p_dom_attribute_2               =>   l_dom_attribute_2,
            p_dom_attribute_3               =>   l_dom_attribute_3,
            p_dom_attribute_4               =>   l_dom_attribute_4,
            p_dom_attribute_5               =>   l_dom_attribute_5,
            p_dom_attribute_6               =>   l_dom_attribute_6,
            p_dom_attribute_7               =>   l_dom_attribute_7,
            p_dom_attribute_8               =>   l_dom_attribute_8,
            p_dom_attribute_9               =>   l_dom_attribute_9,
            p_dom_attribute_10              =>   l_dom_attribute_10,
            p_gen_attribute_1               =>   l_gen_attribute_1,
            p_gen_attribute_2               =>   l_gen_attribute_2,
            p_gen_attribute_3               =>   l_gen_attribute_3,
            p_gen_attribute_4               =>   l_gen_attribute_4,
            p_gen_attribute_5               =>   l_gen_attribute_5,
            p_gen_attribute_6               =>   l_gen_attribute_6,
            p_gen_attribute_7               =>   l_gen_attribute_7,
            p_gen_attribute_8               =>   l_gen_attribute_8,
            p_gen_attribute_9               =>   l_gen_attribute_9,
            p_gen_attribute_10              =>   l_gen_attribute_10,
            p_gen_attribute_11              =>   l_gen_attribute_11,
            p_gen_attribute_12              =>   l_gen_attribute_12,
            p_gen_attribute_13              =>   l_gen_attribute_13,
            p_gen_attribute_14              =>   l_gen_attribute_14,
            p_gen_attribute_15              =>   l_gen_attribute_15,
            p_gen_attribute_16              =>   l_gen_attribute_16,
            p_gen_attribute_17              =>   l_gen_attribute_17,
            p_gen_attribute_18              =>   l_gen_attribute_18,
            p_gen_attribute_19              =>   l_gen_attribute_19,
            p_gen_attribute_20              =>   l_gen_attribute_20,
            p_entry_status                  =>   l_entry_status,
            p_entry_level                   =>   l_entry_level,
            p_spcl_gr1                      =>   l_spcl_gr1,
            p_spcl_gr2                      =>   l_spcl_gr2,
            p_apply_for_finaid              =>   l_apply_for_finaid,
            p_finaid_apply_date             =>   l_finaid_apply_date,
            p_appl_date                     =>   l_appl_date,
            p_attribute_category            =>   g_dff_attribute_category,
            p_attribute1                    =>   g_dff_attribute(1),
            p_attribute2                    =>   g_dff_attribute(2),
            p_attribute3                    =>   g_dff_attribute(3),
            p_attribute4                    =>   g_dff_attribute(4),
            p_attribute5                    =>   g_dff_attribute(5),
            p_attribute6                    =>   g_dff_attribute(6),
            p_attribute7                    =>   g_dff_attribute(7),
            p_attribute8                    =>   g_dff_attribute(8),
            p_attribute9                    =>   g_dff_attribute(9),
            p_attribute10                   =>   g_dff_attribute(10),
            p_attribute11                   =>   g_dff_attribute(11),
            p_attribute12                   =>   g_dff_attribute(12),
            p_attribute13                   =>   g_dff_attribute(13),
            p_attribute14                   =>   g_dff_attribute(14),
            p_attribute15                   =>   g_dff_attribute(15),
            p_attribute16                   =>   g_dff_attribute(16),
            p_attribute17                   =>   g_dff_attribute(17),
            p_attribute18                   =>   g_dff_attribute(18),
            p_attribute19                   =>   g_dff_attribute(19),
            p_attribute20                   =>   g_dff_attribute(20),
            p_attribute21                   =>   g_dff_attribute(21),
            p_attribute22                   =>   g_dff_attribute(22),
            p_attribute23                   =>   g_dff_attribute(23),
            p_attribute24                   =>   g_dff_attribute(24),
            p_attribute25                   =>   g_dff_attribute(25),
            p_attribute26                   =>   g_dff_attribute(26),
            p_attribute27                   =>   g_dff_attribute(27),
            p_attribute28                   =>   g_dff_attribute(28),
            p_attribute29                   =>   g_dff_attribute(29),
            p_attribute30                   =>   g_dff_attribute(30),
            p_attribute31                   =>   g_dff_attribute(31),
            p_attribute32                   =>   g_dff_attribute(32),
            p_attribute33                   =>   g_dff_attribute(33),
            p_attribute34                   =>   g_dff_attribute(34),
            p_attribute35                   =>   g_dff_attribute(35),
            p_attribute36                   =>   g_dff_attribute(36),
            p_attribute37                   =>   g_dff_attribute(37),
            p_attribute38                   =>   g_dff_attribute(38),
            p_attribute39                   =>   g_dff_attribute(39),
            p_attribute40                   =>   g_dff_attribute(40)
            );

          IF l_application_fee_amount IS NULL THEN
            l_application_fee_amount := 0;
          END IF;

        END IF;


        OPEN c_appl_fee_amount(l_application_type);
        FETCH c_appl_fee_amount INTO l_application_fee_amount_test,cl_appl_type;
        CLOSE c_appl_fee_amount;

        IF l_application_type IS NULL THEN
          set_return_message(itemtype,itemkey,'IGS_SS_AD_APPL_MUST',1,'E');
          l_result := 'COMPLETE:ERROR';
        ELSIF cl_appl_type IS NULL THEN
          set_return_message(itemtype,itemkey,'IGS_AD_APPL_TYP_NOT_SETUP',1,'E');
          l_result := 'COMPLETE:ERROR';
        ELSE
          l_result := 'COMPLETE:SUCCESS';
        END IF;


          wf_engine.setitemattrtext(itemtype,itemkey,'P_APPLICATION_TYPE',  l_application_type);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_LOCATION_CODE',  l_location_code);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_PROGRAM_TYPE',   l_program_type);
          wf_engine.setitemattrnumber(itemtype,itemkey,'P_SCH_APL_TO_ID', l_sch_apl_to_id);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_ATTENDANCE_TYPE', l_attendance_type);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_ATTENDANCE_MODE', l_attendance_mode);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_ENTRY_STATUS', l_entry_status);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_ENTRY_LEVEL', l_entry_level);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_SPCL_GR1', l_spcl_gr1);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_SPCL_GR2', l_spcl_gr2);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_APPLY_FOR_FINAID', l_apply_for_finaid);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_APPLY_FOR_FINAID', l_finaid_apply_date);
          wf_engine.setitemattrtext(itemtype,itemkey,'P_APPLICATION_FEE_AMOUNT', l_application_fee_amount);

      resultout := l_result;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        set_return_message(itemtype,itemkey,'IGS_GE_UNHANDLED_EXP',1,'U','NAME','CALL_DRV_USR_HKS');
        WF_CORE.CONTEXT ('IGS_AD_WF_P2A', 'CALL_DRV_USR_HKS', itemtype,
                          itemkey, to_char(actid), funcmode);
        RAISE;

  END call_drv_usr_hks;

  PROCEDURE drv_par_bef_api_cal(
            itemtype  in  VARCHAR2  ,
	    itemkey   in  VARCHAR2  ,
	    actid     in  NUMBER   ,
            funcmode  in  VARCHAR2  ,
	    resultout   OUT NOCOPY VARCHAR2 ) IS

    CURSOR c_source_id (cp_source IGS_AD_CODE_CLASSES.system_status%TYPE) IS
      SELECT code_id
      FROM igs_ad_code_classes
      WHERE upper(system_status) = cp_source
            and class = 'SYS_APPL_SOURCE' and system_default = 'Y'
	    AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';

    l_login_role VARCHAR2(30);
    l_appl_source_id   IGS_AD_CODE_CLASSES.code_id%TYPE;
    l_app_source IGS_AD_CODE_CLASSES.system_status%TYPE;

  BEGIN

    l_appl_source_id := NULL;

    IF funcmode='RUN' THEN

      l_login_role := wf_engine.getitemattrtext(itemtype,itemkey,'P_LOGIN_RESP');

      IF l_login_role = 'ADMIN' THEN

        l_app_source := 'WEB_STAFF';

      ELSE

        l_app_source := 'WEB_APPL';

      END IF;

      OPEN c_source_id(l_app_source);
      FETCH c_source_id INTO l_appl_source_id;
      CLOSE c_source_id;

      IF l_appl_source_id IS NULL THEN

        IF l_app_source = 'WEB_APPL' THEN

          set_return_message(itemtype,itemkey,'IGS_AD_APL_SRC_WEB_APP',1,'E');
          resultout := 'COMPLETE:ERROR';
          RETURN;

        ELSE

          set_return_message(itemtype,itemkey,'IGS_AD_APL_SRC_WEB_STAFF',1,'E');
          resultout := 'COMPLETE:ERROR';
          RETURN;

        END IF;

      END IF;

      wf_engine.setitemattrtext(itemtype,itemkey,'P_APPL_SOURCE_ID', l_appl_source_id);

      resultout := 'COMPLETE:SUCCESS';
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        set_return_message(itemtype,itemkey,'IGS_GE_UNHANDLED_EXP',1,'U','NAME','DRV_PAR_BEF_API_CAL');
        WF_CORE.CONTEXT ('IGS_AD_WF_P2A', 'DRV_PAR_BEF_API_CAL', itemtype,
                          itemkey, to_char(actid), funcmode);
        RAISE;

  END drv_par_bef_api_cal;


  PROCEDURE val_application_type(
            itemtype  in  VARCHAR2  ,
	    itemkey   in  VARCHAR2  ,
	    actid     in  NUMBER   ,
            funcmode  in  VARCHAR2  ,
	    resultout   OUT NOCOPY VARCHAR2 ) IS
    l_result VARCHAR2(30);


    CURSOR c_app_type_det ( cp_app_type IGS_AD_SS_APPL_TYP.admission_application_type%TYPE) IS
      SELECT  admission_cat,s_admission_process_type
      FROM  igs_ad_ss_appl_typ
      WHERE admission_application_type = cp_app_type;

   -- Cursor to validate whether the Application Type is available in the current Admission Calendar
    CURSOR c_apptype_admcal(p_adm_cal_type IGS_AD_PRD_AD_PRC_CA.adm_cal_type%TYPE,p_adm_cal_seq IGS_AD_PRD_AD_PRC_CA.adm_ci_sequence_number%TYPE
                             , p_admission_cat IGS_AD_PRD_AD_PRC_CA.admission_cat%TYPE, p_s_admission_process_type IGS_AD_PRD_AD_PRC_CA.s_admission_process_type%TYPE) IS
      SELECT s_admission_process_type
      FROM IGS_AD_PRD_AD_PRC_CA
      WHERE adm_cal_type = p_adm_cal_type AND
            adm_ci_sequence_number = p_adm_cal_seq AND
            admission_cat = p_admission_cat AND
            s_admission_process_type = p_s_admission_process_type;


    l_person_id IGS_PE_HZ_PARTIES.party_id%TYPE;
    l_login_role VARCHAR2(30);
    l_acad_cal_type IGS_CA_INST_ALL.cal_type%TYPE;
    l_acad_cal_seq_number IGS_CA_INST_ALL.sequence_number%TYPE;
    l_adm_cal_type IGS_CA_INST_ALL.cal_type%TYPE;
    l_adm_ci_sequence_number IGS_CA_INST_ALL.sequence_number%TYPE;
    l_application_type IGS_AD_SS_APPL_TYP.admission_application_type%TYPE;
    l_application_type_test IGS_AD_PRD_AD_PRC_CA.s_admission_process_type%TYPE;

    l_location_code IGS_SS_APP_PGM_STG.location_cd%TYPE;
    l_attendance_type IGS_SS_APP_PGM_STG.attendance_type%TYPE;
    l_attendance_mode IGS_SS_APP_PGM_STG.attendance_mode%TYPE;

    l_admission_cat IGS_AD_SS_APPL_TYP.admission_cat%TYPE;
    l_s_process_type IGS_AD_SS_APPL_TYP.s_admission_process_type%TYPE;
    l_submission_deadline DATE;

    l_loc_des       IGS_AD_LOCATION.description%TYPE;
    l_attd_type_des IGS_EN_ATD_TYPE.description%TYPE;
    l_attd_mode_des IGS_EN_ATD_MODE.description%TYPE;
    l_parval VARCHAR2(200);

  BEGIN


    l_loc_des       := NULL;
    l_attd_type_des := NULL;
    l_attd_mode_des := NULL;
    l_application_type_test := NULL;

    IF funcmode='RUN' THEN
      l_person_id                     := wf_engine.getitemattrnumber(itemtype,itemkey,'P_PERSON_ID');
      l_login_role                    := wf_engine.getitemattrtext(itemtype,itemkey,'P_LOGIN_RESP');
      l_acad_cal_type                 := wf_engine.getitemattrtext(itemtype,itemkey,'P_ACAD_CAL_TYPE');
      l_acad_cal_seq_number           := wf_engine.getitemattrnumber(itemtype,itemkey,'P_ACAD_CAL_SEQ_NUMBER');
      l_adm_cal_type                  := wf_engine.getitemattrtext(itemtype,itemkey,'P_ADM_CAL_TYPE');
      l_adm_ci_sequence_number        := wf_engine.getitemattrnumber(itemtype,itemkey,'P_ADM_CI_SEQUENCE_NUMBER');
      l_application_type              := wf_engine.getitemattrtext(itemtype,itemkey,'P_APPLICATION_TYPE');
      l_location_code                 := wf_engine.getitemattrtext(itemtype,itemkey,'P_LOCATION_CODE');
      l_attendance_type               := wf_engine.getitemattrtext(itemtype,itemkey,'P_ATTENDANCE_TYPE');
      l_attendance_mode               := wf_engine.getitemattrtext(itemtype,itemkey,'P_ATTENDANCE_MODE');


      IF l_person_id IS NULL OR l_acad_cal_type IS NULL OR l_acad_cal_seq_number IS NULL OR
         l_adm_cal_type IS NULL OR l_adm_ci_sequence_number IS NULL OR l_application_type IS NULL THEN
         set_return_message(itemtype,itemkey,'IGS_AD_PRECREATE_PARAM_MISSING',1,'E');
         resultout := 'COMPLETE:ERROR';
         RETURN;
      END IF;

      l_admission_cat := NULL;
      l_s_process_type := NULL;

      OPEN c_app_type_det(l_application_type);
      FETCH c_app_type_det INTO l_admission_cat,l_s_process_type;
      CLOSE c_app_type_det;

      OPEN c_apptype_admcal(l_adm_cal_type,l_adm_ci_sequence_number,l_admission_cat,l_s_process_type);
      FETCH c_apptype_admcal INTO l_application_type_test;
      CLOSE c_apptype_admcal;

      IF l_application_type_test IS NULL THEN

        set_return_message(itemtype,itemkey,'IGS_AD_INVALID_APP_TYPE',1,'E');
        resultout := 'COMPLETE:ERROR';
        RETURN;

      END IF;


      l_submission_deadline := igs_ad_gen_003.get_apc_date ('SUBMISSION_DEADLINE',
                                    l_adm_cal_type,
                                    l_adm_ci_sequence_number,
                                    l_admission_cat,
                                    l_s_process_type,
                                    null,
                                    null,
                                    l_acad_cal_type,
                                    l_location_code,
                                    l_attendance_mode,
                                    l_attendance_type
                                   );


      IF l_submission_deadline IS NOT NULL AND l_submission_deadline < trunc(SYSDATE) THEN

        set_return_message(itemtype,itemkey,'IGS_AD_SUB_DEADLINE',1,'E');
        resultout := 'COMPLETE:ERROR';
        RETURN;

      END IF;

      resultout := 'COMPLETE:SUCCESS';
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        set_return_message(itemtype,itemkey,'IGS_GE_UNHANDLED_EXP',1,'U','NAME','VAL_APPLICATION_TYPE');
        WF_CORE.CONTEXT ('IGS_AD_WF_P2A', 'VAL_APPLICATION_TYPE', itemtype,
                          itemkey, to_char(actid), funcmode);
        RAISE;

  END val_application_type;


END igs_ad_wf_p2a;

/
