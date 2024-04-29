--------------------------------------------------------
--  DDL for Package Body IGS_AD_OFFRESP_STATUS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_OFFRESP_STATUS_WF" AS
/* $Header: IGSADD0B.pls 115.2 2003/10/21 14:59:05 rboddu noship $ */
---------------------------------------------------------------------------------------------------------------------------------------
--  Created By : rboddu
--  Date Created On : 07-OCT-2003
--  Purpose : Bug: 3132406. This package is used to raise the Offer Response Status change Business Events.
--  Change History
--  Who             When            What
--
---------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE adm_offer_response_changed (
       p_person_id              IN igs_ad_ps_appl_inst_all.person_id%TYPE,
       p_admission_appl_number  IN igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
       p_nominated_course_cd    IN igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
       p_sequence_number        IN igs_ad_ps_appl_inst_all.sequence_number%TYPE,
       p_old_offresp_status     IN igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE,
       p_new_offresp_status     IN igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE
       ) IS

    -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_offresp_stat_wf_s.NEXTVAL
      FROM     SYS.dual;

      CURSOR cur_prof_value IS
      SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
      FROM dual;

      ln_seq_val          NUMBER;
      lv_item_type        VARCHAR2(100) ;
      l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
      lv_raise_event      VARCHAR2(100);
      l_cur_prof_value   cur_prof_value%ROWTYPE;


  BEGIN

  -- Checking if the Workflow is installed at the environment or not.
    OPEN cur_prof_value;
    FETCH cur_prof_value INTO l_cur_prof_value;
    CLOSE cur_prof_value;

    IF (l_cur_prof_value.value = 'Y') THEN

       lv_raise_event := 'oracle.apps.igs.ad.offerresponse.changed';

       -- Get the sequence value
       OPEN  c_seq_num;
       FETCH c_seq_num INTO ln_seq_val ;
       CLOSE c_seq_num ;

       wf_event.AddParameterToList(p_name         =>'P_PERSON_ID',
                                   p_value        => p_person_id,
                                   p_parameterlist=> l_parameter_list);

       wf_event.AddParameterToList(p_name         =>'P_ADMISSION_APPL_NUMBER',
                                   p_value        => p_admission_appl_number,
                                   p_parameterlist=> l_parameter_list);

       wf_event.AddParameterToList(p_name         =>'P_NOMINATED_COURSE_CD',
                                   p_value        => p_nominated_course_cd,
                                   p_parameterlist=> l_parameter_list);

       wf_event.AddParameterToList(p_name         =>'P_SEQUENCE_NUMBER',
                                   p_value        => p_sequence_number,
                                   p_parameterlist=> l_parameter_list);

       wf_event.AddParameterToList(p_name         =>'P_NEW_OFFER_RESPONSE_STATUS',
                                   p_value        => p_new_offresp_status,
                                   p_parameterlist=> l_parameter_list);

       wf_event.AddParameterToList(p_name         =>'P_OLD_OFFER_RESPONSE_STATUS',
                                   p_value        => p_old_offresp_status,
                                   p_parameterlist=> l_parameter_list);



       -- Raise the event
       wf_event.raise( p_event_name => lv_raise_event,
                       p_event_key  => ln_seq_val,
                       p_parameters => l_parameter_list);

        l_parameter_list.delete;
     END IF;
  EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('IGS_AD_OFFRESP_STATUS_WF', 'WF_RAISE_EVENT',
    lv_item_type||ln_seq_val,lv_raise_event);
    RAISE;

  END adm_offer_response_changed;


  PROCEDURE wf_get_person_attributes(
                       itemtype    IN  VARCHAR2  ,
			itemkey     IN  VARCHAR2  ,
			actid	    IN  NUMBER   ,
                        funcmode    IN  VARCHAR2  ,
			resultout   OUT NOCOPY VARCHAR2 )

  ------------------------------------------------------------------
    --Created by  : rboddu, Oracle IDC
    --Date created: 10-OCT-2003
    --
    --Purpose: Single Response Build : 3132406
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
  -------------------------------------------------------------------
  IS
    l_event_name        VARCHAR2(200);
    l_event_message     WF_EVENT_T;
    l_person_number     igs_pe_person_base_v.person_number%TYPE;
    l_full_name         igs_pe_person_base_v.full_name%TYPE;
    l_person_id         igs_pe_person_base_v.person_id%TYPE;

    CURSOR get_person_attr IS
    SELECT person_number, full_name
    FROM igs_pe_person_base_v
    WHERE person_id = l_person_id;

    CURSOR cur_user_name IS
    SELECT user_name
    FROM fnd_user
    WHERE user_id = fnd_global.user_id;

    l_wf_role fnd_user.user_name%TYPE;


  BEGIN

    IF funcmode='RUN' THEN

      l_person_id := wf_engine.getitemattrnumber(itemtype,itemkey,'P_PERSON_ID');

      OPEN get_person_attr;
      FETCH get_person_attr INTO l_person_number, l_full_name;
      CLOSE get_person_attr;

      OPEN cur_user_name;
      FETCH cur_user_name INTO l_wf_role;
      CLOSE cur_user_name;

      wf_engine.setitemattrtext(itemtype,itemkey,'P_PERSON_NUMBER',l_person_number);
      wf_engine.setitemattrtext(itemtype,itemkey,'P_FULL_NAME',l_full_name);
      wf_engine.setitemattrtext(itemtype,itemkey,'P_WF_ROLE',l_wf_role);

    END IF;

  END wf_get_person_attributes;


  PROCEDURE check_single_response  (
                        itemtype    IN  VARCHAR2  ,
			itemkey     IN  VARCHAR2  ,
			actid	    IN  NUMBER   ,
                        funcmode    IN  VARCHAR2  ,
			resultout   OUT NOCOPY VARCHAR2
		       ) AS

  ------------------------------------------------------------------
    --Created by  : rboddu, Oracle IDC
    --Date created: 10-OCT-2003
    --
    --Purpose: Single Response Build : 3132406
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
  -------------------------------------------------------------------

    CURSOR get_person_attr (p_person_id igs_pe_person_base_v.person_id%TYPE) IS
    SELECT person_number, full_name
    FROM igs_pe_person_base_v
    WHERE person_id = p_person_id;

    CURSOR get_alternate_code ( p_cal_type igs_ca_inst.cal_type%TYPE,
                           p_sequence_number igs_ca_inst.sequence_number%TYPE) IS
    SELECT alternate_code
    FROM igs_ca_inst
    WHERE cal_type = p_cal_type
    AND sequence_number = p_sequence_number;

    CURSOR get_single_response (p_person_id igs_ad_appl_all.person_id%TYPE,
                                p_admission_appl_number igs_ad_appl_all.admission_appl_number%TYPE,
                                p_admission_cat igs_ad_appl_all.admission_cat%TYPE,
                                p_s_admission_process_type igs_ad_appl_all.s_admission_process_type%TYPE) IS
    SELECT admprd.single_response_flag
    FROM igs_ad_prd_ad_prc_ca admprd,
         igs_ad_appl_all appl,
         igs_ad_ps_appl_inst_all aplinst
    WHERE appl.person_id = p_person_id
          AND appl.admission_appl_number = p_admission_appl_number
          AND appl.person_id = aplinst.person_id
          AND appl.admission_appl_number = aplinst.admission_appl_number
          AND admprd.adm_cal_type = NVL(aplinst.adm_cal_type,appl.adm_cal_type)
          AND admprd.adm_ci_sequence_number = NVL(aplinst.adm_ci_sequence_number,appl.adm_ci_sequence_number)
          AND admprd.admission_cat = p_admission_cat
          AND admprd.s_admission_process_type = p_s_admission_process_type;

    CURSOR cur_user_name IS
    SELECT user_name
    FROM fnd_user
    WHERE user_id = fnd_global.user_id;

    l_wf_role           fnd_user.user_name%TYPE;
    l_event_message     WF_EVENT_T;
    l_person_number     igs_pe_person_base_v.person_number%TYPE;
    l_full_name         igs_pe_person_base_v.full_name%TYPE;

    l_person_id         igs_pe_person_base_v.person_id%TYPE;
    l_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE;
    l_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE;
    l_sequence_number     igs_ad_ps_appl_inst_all.sequence_number%TYPE;

    v_admission_cat                 igs_ad_appl.admission_cat%TYPE;
    v_s_admission_process_type      igs_ad_appl.s_admission_process_type%TYPE;
    v_acad_cal_type                 igs_ad_appl.acad_cal_type%TYPE;
    v_acad_ci_sequence_number       igs_ad_appl.acad_ci_sequence_number%TYPE;
    v_aa_adm_cal_type               igs_ad_appl.adm_cal_type%TYPE;
    v_aa_adm_ci_sequence_number     igs_ad_appl.adm_ci_sequence_number%TYPE;
    v_adm_cal_type                  igs_ad_appl.adm_cal_type%TYPE;
    v_adm_ci_sequence_number        igs_ad_appl.adm_ci_sequence_number%TYPE;
    v_appl_dt                       igs_ad_appl.appl_dt%TYPE;
    v_adm_appl_status               igs_ad_appl.adm_appl_status%TYPE;
    v_adm_fee_status                igs_ad_appl.adm_fee_status%TYPE;
    l_single_response_flag          VARCHAR2(1);
    l_acad_alt_code                 igs_ca_inst.alternate_code%TYPE;
    l_adm_alt_code                  igs_ca_inst.alternate_code%TYPE;
    l_new_offer_resp_status         igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE;

  BEGIN
    IF funcmode='RUN' THEN

      l_person_id := wf_engine.getitemattrnumber(itemtype,itemkey,'P_PERSON_ID');
      l_admission_appl_number := wf_engine.getitemattrnumber(itemtype,itemkey,'P_ADMISSION_APPL_NUMBER');
      l_nominated_course_cd := wf_engine.getitemattrtext(itemtype,itemkey,'P_NOMINATED_COURSE_CD');
      l_sequence_number := wf_engine.getitemattrnumber(itemtype,itemkey,'P_SEQUENCE_NUMBER');
      l_new_offer_resp_status := wf_engine.getitemattrtext(itemtype,itemkey,'P_NEW_OFFER_RESPONSE_STATUS');

      -- Fetch the Application details of the current application by calling the following standard API.
              igs_ad_gen_002.admp_get_aa_dtl(
                 l_person_id,
                 l_admission_appl_number,
                 v_admission_cat,
                 v_s_admission_process_type,
                 v_acad_cal_type,
                 v_acad_ci_sequence_number,
                 v_aa_adm_cal_type,
                 v_aa_adm_ci_sequence_number,
                 v_appl_dt,
                 v_adm_appl_status,
                 v_adm_fee_status);

       --If the Single Response is set, then set the Workflow attributes appropriately and return 'Y'
       --Else return 'N'

       IF igs_ad_gen_008.admp_get_saors(l_new_offer_resp_status) = 'ACCEPTED' THEN
          --Fetch the Single Response flag set for the current Admission Period / APC combination.
         OPEN get_single_response (l_person_id, l_admission_appl_number,v_admission_cat,v_s_admission_process_type);
         FETCH get_single_response INTO l_single_response_flag;
         CLOSE get_single_response;

          IF l_single_response_flag = 'Y' THEN

            OPEN cur_user_name;
            FETCH cur_user_name INTO l_wf_role;
            CLOSE cur_user_name;

            OPEN get_person_attr(l_person_id);
            FETCH get_person_attr INTO l_person_number, l_full_name;
            CLOSE get_person_attr;

            OPEN get_alternate_code(v_acad_cal_type,v_acad_ci_sequence_number);
            FETCH get_alternate_code INTO l_acad_alt_code;
            CLOSE get_alternate_code;

  	    OPEN get_alternate_code(v_aa_adm_cal_type,v_aa_adm_ci_sequence_number);
            FETCH get_alternate_code INTO l_adm_alt_code;
            CLOSE get_alternate_code;

            wf_engine.setitemattrtext(itemtype,itemkey,'P_PERSON_NUMBER',l_person_number);
            wf_engine.setitemattrtext(itemtype,itemkey,'P_FULL_NAME',l_full_name);
            wf_engine.setitemattrtext(itemtype,itemkey,'P_ACAD_ADM_CAL',l_acad_alt_code||'/'||l_adm_alt_code);
            wf_engine.setitemattrtext(itemtype,itemkey,'P_WF_ROLE',l_wf_role);
            resultout := 'COMPLETE:Y';
          ELSE
            resultout := 'COMPLETE:N';
          END IF;
       ELSE
         resultout := 'COMPLETE:N';
       END IF;
    END IF;
  END check_single_response;
END igs_ad_offresp_status_wf;

/
