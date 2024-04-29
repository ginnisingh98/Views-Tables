--------------------------------------------------------
--  DDL for Package Body IGS_FI_WAV_DTLS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_WAV_DTLS_WF" AS
/* $Header: IGSFI96B.pls 120.2 2006/05/12 04:18:59 abshriva noship $ */

  PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                         p_v_string IN VARCHAR2 ) IS
    /******************************************************************
     Created By      :   Umesh Udayaprakash
     Date Created By :   8/5/2005
     Purpose         :   Procedure for logging

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
  BEGIN

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_fi_wav_dtls_wf.' || p_v_module, p_v_string);
    END IF;

  END log_to_fnd;

  PROCEDURE raise_wavtrandtlstofa_event( p_n_person_id	        IN  hz_parties.party_id%TYPE,
                                         p_v_waiver_name	      IN  igs_fi_waiver_pgms.waiver_name%TYPE,
                                         p_c_fee_cal_type	      IN  igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                         p_n_fee_ci_seq_number  IN  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                                         p_n_waiver_amount	    IN  igs_fi_inv_int_all.invoice_amount%TYPE) AS
    /******************************************************************
     Created By      :   Umesh Udayaprakash
     Date Created By :   8/5/2005
     Purpose         :   Procedure for raise workflow notification for Financial Aid

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
     abshriva 12-May-2006 Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
     uudayapr 10/27/2005 Bug 4704177 Added the workflow parameter P_FIN_AID_ADMIN to
                                     pass the Notifying user based on the profile Value
                                     IGS_FI_WAV_NOTIFY_USER
    ***************************************************************** */
    CURSOR cur_cal_desc(c_cal_load_cal_type    IN igs_ca_inst_all.cal_type%TYPE,
                        c_n_load_ci_seq_number IN igs_ca_inst_all.sequence_number%TYPE
                        ) IS
      SELECT description
      FROM IGS_CA_INST_ALL
      WHERE cal_type = c_cal_load_cal_type
      AND sequence_number = c_n_load_ci_seq_number;

    CURSOR cur_person_details(c_n_person_id	        IN  hz_parties.party_id%TYPE) IS
      SELECT person_number, full_name
      FROM IGS_PE_PERSON_BASE_V
      WHERE person_id = c_n_person_id;

    CURSOR cur_alt_person_id (c_n_person_id	        IN  hz_parties.party_id%TYPE) IS
      SELECT api_person_id, person_id_type
      FROM igs_pe_person_id_type_v
      WHERE pe_person_id = c_n_person_id;

    CURSOR c_seq_num IS
      SELECT  igs_fi_wav_wf_trans_fa_s.NEXTVAL
      FROM sys.dual;

    l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
    l_c_load_cal_type   igs_ca_inst_all.cal_type%TYPE;
    l_n_load_ci_seq_number igs_ca_inst_all.sequence_number%TYPE;
    l_v_message_name fnd_new_messages.message_name%TYPE;
    l_b_returnflag BOOLEAN;

    l_v_load_description igs_ca_inst_all.description%TYPE;
    l_cur_person_details cur_person_details%ROWTYPE;
    l_cur_alt_person_id cur_alt_person_id%ROWTYPE;
    ln_seq_val          NUMBER;
    lv_raise_event VARCHAR2(100);
  BEGIN
    --Check whether the workflow profile has been enabled.
    IF NVL(FND_PROFILE.VALUE('IGS_WF_ENABLE'),'N') = 'Y'  THEN

        lv_raise_event := 'oracle.apps.igs.fi.WaiverTransDtlsToFA';

        --Call Out to derive the load period.
      l_b_returnflag := igs_fi_gen_001.finp_get_lfci_reln ( p_cal_type               =>  p_c_fee_cal_type,
                                                            p_ci_sequence_number     =>  p_n_fee_ci_seq_number,
                                                            p_cal_category           =>  'FEE' ,
                                                            p_ret_cal_type           =>  l_c_load_cal_type,
                                                            p_ret_ci_sequence_number =>  l_n_load_ci_seq_number,
                                                            p_message_name           => l_v_message_name);
      IF NOT l_b_returnflag THEN
        log_to_fnd (p_v_module => 'raise_wavtrandtlstofa_event',
                    p_v_string => l_v_message_name);
      ELSE
        --Callout to get the calendar Description
        OPEN cur_cal_desc(c_cal_load_cal_type => l_c_load_cal_type,
                          c_n_load_ci_seq_number =>l_n_load_ci_seq_number );
        FETCH cur_cal_desc INTO l_v_load_description;
        CLOSE cur_cal_desc;

        --Call out to get the person details
        OPEN cur_person_details(c_n_person_id => p_n_person_id);
        FETCH cur_person_details INTO l_cur_person_details;
        CLOSE cur_person_details;
        --Call out to get the alternate person id
        OPEN cur_alt_person_id(c_n_person_id => p_n_person_id);
        FETCH cur_alt_person_id INTO l_cur_alt_person_id;
        CLOSE cur_alt_person_id;
        --Creation of paramter List
        wf_event.AddParameterToList(p_name  => 'PERSON_ID',
                                    p_value => p_n_person_id,
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'PERSON_NUMBER',
                                    p_value => l_cur_person_details.person_number,
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'PERSON_NAME',
                                    p_value => l_cur_person_details.full_name,
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'PERSON_ID_TYPE',
                                    p_value => l_cur_alt_person_id.person_id_type,
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'ALTERNATE_ID',
                                    p_value => l_cur_alt_person_id.api_person_id,
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'WAIVER_NAME',
                                    p_value => p_v_waiver_name,
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'LOAD_CAL_TYPE',
                                    p_value => l_c_load_cal_type,
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'LOAD_CI_SEQUENCE_NUMBER',
                                    p_value => l_n_load_ci_seq_number,
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'LOAD_CAL_DESC',
                                    p_value => l_v_load_description,
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'WAIVER_AMOUNT',
                                    p_value => igs_fi_gen_gl.get_formatted_amount(p_n_waiver_amount),
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'TRANSACTION_DATE',
                                    p_value => TRUNC(sysdate),
                                    p_parameterlist=> l_parameter_list);

        wf_event.AddParameterToList(p_name  => 'P_FIN_AID_ADMIN',
                                    p_value => NVL(FND_PROFILE.VALUE('IGS_FI_WAV_NOTIFY_USER'),'SYSADMIN'),
                                    p_parameterlist=> l_parameter_list);
        --Call out to generate the sequence number
        OPEN  c_seq_num;
        FETCH c_seq_num INTO ln_seq_val ;
        CLOSE c_seq_num ;
        --Raising the Bussiness event
        wf_event.raise( p_event_name => lv_raise_event,
                        p_event_key  => 'WTRANTOFA' || ln_seq_val,
                        p_parameters => l_parameter_list);
        --Deleting the parameter List
        l_parameter_list.DELETE;

      END IF;
    END IF ;
    EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT('IGS_FI_WAV_DTLS_WF', 'raise_wavtrandtlstofa_event',ln_seq_val,lv_raise_event);
      raise;
 END raise_wavtrandtlstofa_event;

/**
  Procedure for raising student waiver assignment event
*/

  PROCEDURE raise_stdntwavassign_event(p_n_person_id	        IN  hz_parties.party_id%TYPE,
                                       p_v_waiver_name	      IN  igs_fi_waiver_pgms.waiver_name%TYPE,
                                       p_c_fee_cal_type	      IN  igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                       p_n_fee_ci_seq_number  IN  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) AS

  CURSOR cur_person_details(c_n_person_id	        IN  hz_parties.party_id%TYPE) IS
    SELECT person_number, full_name
    FROM IGS_PE_PERSON_BASE_V
    WHERE person_id = c_n_person_id;

  CURSOR c_seq_num IS
    SELECT  igs_fi_wav_wf_stud_s.NEXTVAL
    FROM sys.dual;

  l_cur_person_details cur_person_details%ROWTYPE;
  l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
  lv_raise_event VARCHAR2(100);
  ln_seq_val          NUMBER;
  BEGIN
    --Check whether the workflow profile has been enabled.
    IF NVL(FND_PROFILE.VALUE('IGS_WF_ENABLE'),'N') = 'Y'  THEN
      lv_raise_event := 'oracle.apps.igs.fi.StudWavAssignments';
      --Call out to get the person details
      OPEN cur_person_details(c_n_person_id => p_n_person_id);
      FETCH cur_person_details INTO l_cur_person_details;
      CLOSE cur_person_details;
      --Creation of paramter List
      wf_event.AddParameterToList(p_name  => 'PERSON_ID',
                                  p_value => p_n_person_id,
                                  p_parameterlist=> l_parameter_list);

      wf_event.AddParameterToList(p_name  => 'PERSON_NUMBER',
                                  p_value => l_cur_person_details.person_number,
                                  p_parameterlist=> l_parameter_list);

      wf_event.AddParameterToList(p_name  => 'PERSON_NAME',
                                  p_value => l_cur_person_details.full_name,
                                  p_parameterlist=> l_parameter_list);

      wf_event.AddParameterToList(p_name  => 'WAIVER_NAME',
                                  p_value => p_v_waiver_name,
                                  p_parameterlist=> l_parameter_list);

      wf_event.AddParameterToList(p_name  => 'FEE_CAL_TYPE',
                                  p_value => p_c_fee_cal_type,
                                  p_parameterlist=> l_parameter_list);

      wf_event.AddParameterToList(p_name  => 'FEE_CI_SEQUENCE_NUMBER',
                                  p_value => p_n_fee_ci_seq_number,
                                  p_parameterlist=> l_parameter_list);

      OPEN  c_seq_num;
      FETCH c_seq_num INTO ln_seq_val ;
      CLOSE c_seq_num ;
      --Raising the Bussiness event
      wf_event.raise( p_event_name => lv_raise_event,
                      p_event_key  => 'WAVASSGN' || ln_seq_val,
                      p_parameters => l_parameter_list);
      --Deleting the parameter List
      l_parameter_list.DELETE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    WF_CORE.CONTEXT('IGS_FI_WAV_DTLS_WF', 'raise_stdntwavassign_event',ln_seq_val,lv_raise_event);
    raise;

  END raise_stdntwavassign_event;

END  igs_fi_wav_dtls_wf;

/
