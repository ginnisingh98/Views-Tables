--------------------------------------------------------
--  DDL for Package Body IGS_UC_DAT_IMP_FROM_UCAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_DAT_IMP_FROM_UCAS" AS
/* $Header: IGSUC19B.pls 120.2 2006/08/21 03:51:35 jbaber noship $  */

  PROCEDURE insert_dat_into_ucas (
     errbuf                     OUT NOCOPY     VARCHAR2
    ,retcode                    OUT NOCOPY     NUMBER
    ,p_report_mode              IN      VARCHAR2
    ,p_n_rec_cnt_for_commit     IN      NUMBER
    ,p_c_import_appl_data       IN      VARCHAR2
     ) IS
     -- parameter p_c_import_appl added as part of UCCR002 Bug# 2278817

    /******************************************************************
     Created By      :   M. S. GARCHA
     Date Created By :   10-OCT-2001
     Purpose         :
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     kkillams  24-Sep-2002  Call to proc_cvname_view procedure is removed.
                            New procedure calls proc_cvRefTariff_view
                            proc_cvJointAdmissions_view
                            proc_cvRefSocioEconomic_view
                            proc_cvRefSocialClass_view
                            proc_cvRefPre2000POCC_view  are added to
                            populate respective UCAS views.
                            w.r.t. UCFD06 build bug no : 2574566
    ayedubat  14-NOV-2002  Added two new procedures,proc_ivstarg_view and proc_ivstart_view
                           The procedures proc_uvcontgrp,proc_uvcontact_view,
                           proc_cvcourse_view, proc_uvcourse_view, proc_uvcoursevacancies_view,
                           proc_uvcoursevacoptions_view, proc_uvcoursekeyword_view
                           are changed to execute on every run, rather for p_c_import_appl_data = 'Y'.
    ***************************************************************** */

  BEGIN
    NULL;
  END insert_dat_into_ucas;


  PROCEDURE update_ucas_app_with_pers_id (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER
  ) IS
    /******************************************************************
     Created By      :   rbezawad
     Date Created By :   10-Jun-2002
     Purpose         :   To update the IGS_UC_APPLICANTS.OSS_PERSON_ID column with the IGS_PE_ALT_PERS_ID_V.PE_PERSON_ID column value.
                         This needs to be run after running the "Import data from UCAS" and "Admission Import Process".
     Known limitations,enhancements,remarks:
     Change History
     Who       When        What
     rbezawad  2-Oct-2002  6 Columns choices_transparent_ind, extra_status, extra_passport_no, request_app_dets_ind,
                             request_copy_app_frm_ind, cef_no are added to IGS_UC_APPLICANTS TBH call w.r.t. UCFD06, bug 2574566.
     ayedubat  13-NOV-2002 Columns from System_code to edu_qualification are added to IGS_UC_APPLICANTS TBH call for Enh Bug# 2643048
     ayedubat  04-DEC-2002 Changed the WHERE clause of the cursor,cur_applicant to add to_char to a.app_no column since the column
                           b.api_person_id is a VARCHAR2 field and changed the comparision of b.person_id_type directly with UCASID to
                           the appropriate id of the UCAS system of the Applicant as for the small systems support
                           for the bug fix: 2670807
     anwest    18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    ***************************************************************** */

    CURSOR cur_applicant IS
      SELECT a.rowid
             ,a.app_id
             ,a.app_no
             ,a.check_digit
             ,a.personal_id
             ,a.enquiry_no
             ,a.oss_person_id
             ,a.application_source
             ,a.name_change_date
             ,a.student_support
             ,a.address_area
             ,a.application_date
             ,a.application_sent_date
             ,a.application_sent_run
             ,a.lea_code
             ,a.fee_payer_code
             ,a.fee_text
             ,a.domicile_apr
             ,a.code_changed_date
             ,a.school
             ,a.withdrawn
             ,a.withdrawn_date
             ,a.rel_to_clear_reason
             ,a.route_b
             ,a.exam_change_date
             ,a.a_levels
             ,a.as_levels
             ,a.highers
             ,a.csys
             ,a.winter
             ,a.previous
             ,a.gnvq
             ,a.btec
             ,a.ilc
             ,a.ailc
             ,a.ib
             ,a.manual
             ,a.reg_num
             ,a.oeq
             ,a.eas
             ,a.roa
             ,a.status
             ,a.firm_now
             ,a.firm_reply
             ,a.insurance_reply
             ,a.conf_hist_firm_reply
             ,a.conf_hist_ins_reply
             ,a.residential_category
             ,a.personal_statement
             ,a.match_prev
             ,a.match_prev_date
             ,a.match_winter
             ,a.match_summer
             ,a.gnvq_date
             ,a.ib_date
             ,a.ilc_date
             ,a.ailc_date
             ,a.gcseqa_date
             ,a.uk_entry_date
             ,a.prev_surname
             ,a.criminal_convictions
             ,a.sent_to_hesa
             ,a.sent_to_oss
             ,a.batch_identifier
             ,a.gce
             ,a.vce
             ,a.sqa
             ,a.previousas
             ,a.keyskills
             ,a.vocational
             ,a.scn
             ,a.prevoeq
             ,b.pe_person_id
             ,a.choices_transparent_ind
             ,a.extra_status
             ,a.extra_passport_no
             ,a.request_app_dets_ind
             ,a.request_copy_app_frm_ind
             ,a.cef_no
             ,a.system_code
             ,a.gcse_eng
             ,a.gcse_math
             ,a.degree_subject
             ,a.degree_status
             ,a.degree_class
             ,a.gcse_sci
             ,a.welshspeaker
             ,a.ni_number
             ,a.earliest_start
             ,a.near_inst
             ,a.pref_reg
             ,a.qual_eng
             ,a.qual_math
             ,a.qual_sci
             ,a.main_qual
             ,a.qual_5
             ,a.future_serv
             ,a.future_set
             ,a.present_serv
             ,a.present_set
             ,a.curr_employment
             ,a.edu_qualification
             ,a.ad_batch_id
             ,a.ad_interface_id
             ,a.nationality
             ,a.dual_nationality
             ,a.special_needs
             ,a.country_birth
      FROM   igs_uc_applicants a, igs_pe_alt_pers_id_v b
      WHERE  a.oss_person_id IS NULL
	      AND  b.api_person_id = to_char(a.app_no)
        AND  b.person_id_type = DECODE(a.system_code,'U','UCASID','G','GTTRID','N','NMASID','S','SWASID')
        AND  NVL(b.start_dt, SYSDATE) <= SYSDATE
        AND  NVL(b.end_dt, SYSDATE)   >= SYSDATE
      ORDER BY a.app_no;

    l_app_count NUMBER :=0 ;

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    --Loop through the all the Applicants records that needs to populate the OSS_person_id value.
    FOR applicant_rec IN cur_applicant
    LOOP
      --Updates the IGS_UC_APPLICANTS.OSS_PERSON_ID column with the IGS_PE_ALT_PERS_ID_V.PE_PERSON_ID column value.
      igs_uc_applicants_pkg.update_row
      ( x_rowid                               => applicant_rec.rowid
       ,x_app_id                              => applicant_rec.app_id
       ,x_app_no                              => applicant_rec.app_no
       ,x_check_digit                         => applicant_rec.check_digit
       ,x_personal_id                         => applicant_rec.personal_id
       ,x_enquiry_no                          => applicant_rec.enquiry_no
       ,x_oss_person_id                       => applicant_rec.pe_person_id
       ,x_application_source                  => applicant_rec.application_source
       ,x_name_change_date                    => applicant_rec.name_change_date
       ,x_student_support                     => applicant_rec.student_support
       ,x_address_area                        => applicant_rec.address_area
       ,x_application_date                    => applicant_rec.application_date
       ,x_application_sent_date               => applicant_rec.application_sent_date
       ,x_application_sent_run                => applicant_rec.application_sent_run
       ,x_lea_code                            => applicant_rec.lea_code
       ,x_fee_payer_code                      => applicant_rec.fee_payer_code
       ,x_fee_text                            => applicant_rec.fee_text
       ,x_domicile_apr                        => applicant_rec.domicile_apr
       ,x_code_changed_date                   => applicant_rec.code_changed_date
       ,x_school                              => applicant_rec.school
       ,x_withdrawn                           => applicant_rec.withdrawn
       ,x_withdrawn_date                      => applicant_rec.withdrawn_date
       ,x_rel_to_clear_reason                 => applicant_rec.rel_to_clear_reason
       ,x_route_b                             => applicant_rec.route_b
       ,x_exam_change_date                    => applicant_rec.exam_change_date
       ,x_a_levels                            => applicant_rec.a_levels
       ,x_as_levels                           => applicant_rec.as_levels
       ,x_highers                             => applicant_rec.highers
       ,x_csys                                => applicant_rec.csys
       ,x_winter                              => applicant_rec.winter
       ,x_previous                            => applicant_rec.previous
       ,x_gnvq                                => applicant_rec.gnvq
       ,x_btec                                => applicant_rec.btec
       ,x_ilc                                 => applicant_rec.ilc
       ,x_ailc                                => applicant_rec.ailc
       ,x_ib                                  => applicant_rec.ib
       ,x_manual                              => applicant_rec.manual
       ,x_reg_num                             => applicant_rec.reg_num
       ,x_oeq                                 => applicant_rec.oeq
       ,x_eas                                 => applicant_rec.eas
       ,x_roa                                 => applicant_rec.roa
       ,x_status                              => applicant_rec.status
       ,x_firm_now                            => applicant_rec.firm_now
       ,x_firm_reply                          => applicant_rec.firm_reply
       ,x_insurance_reply                     => applicant_rec.insurance_reply
       ,x_conf_hist_firm_reply                => applicant_rec.conf_hist_firm_reply
       ,x_conf_hist_ins_reply                 => applicant_rec.conf_hist_ins_reply
       ,x_residential_category                => applicant_rec.residential_category
       ,x_personal_statement                  => applicant_rec.personal_statement
       ,x_match_prev                          => applicant_rec.match_prev
       ,x_match_prev_date                     => applicant_rec.match_prev_date
       ,x_match_winter                        => applicant_rec.match_winter
       ,x_match_summer                        => applicant_rec.match_summer
       ,x_gnvq_date                           => applicant_rec.gnvq_date
       ,x_ib_date                             => applicant_rec.ib_date
       ,x_ilc_date                            => applicant_rec.ilc_date
       ,x_ailc_date                           => applicant_rec.ailc_date
       ,x_gcseqa_date                         => applicant_rec.gcseqa_date
       ,x_uk_entry_date                       => applicant_rec.uk_entry_date
       ,x_prev_surname                        => applicant_rec.prev_surname
       ,x_criminal_convictions                => applicant_rec.criminal_convictions
       ,x_sent_to_hesa                        => applicant_rec.sent_to_hesa
       ,x_sent_to_oss                         => NULL
       ,x_batch_identifier                    => applicant_rec.batch_identifier
       ,x_gce                                 => applicant_rec.gce
       ,x_vce                                 => applicant_rec.vce
       ,x_sqa                                 => applicant_rec.sqa
       ,x_previousas                          => applicant_rec.previousas
       ,x_keyskills                           => applicant_rec.keyskills
       ,x_vocational                          => applicant_rec.vocational
       ,x_scn                                 => applicant_rec.scn
       ,x_prevoeq                             => applicant_rec.prevoeq
       ,x_mode                                => 'R'
       ,x_choices_transparent_ind             => applicant_rec.choices_transparent_ind
       ,x_extra_status                        => applicant_rec.extra_status
       ,x_extra_passport_no                   => applicant_rec.extra_passport_no
       ,x_request_app_dets_ind                => applicant_rec.request_app_dets_ind
       ,x_request_copy_app_frm_ind            => applicant_rec.request_copy_app_frm_ind
       ,x_cef_no                              => applicant_rec.cef_no
       ,x_system_code                         => applicant_rec.system_code
       ,x_gcse_eng                            => applicant_rec.gcse_eng
       ,x_gcse_math                           => applicant_rec.gcse_math
       ,x_degree_subject                      => applicant_rec.degree_subject
       ,x_degree_status                       => applicant_rec.degree_status
       ,x_degree_class                        => applicant_rec.degree_class
       ,x_gcse_sci                            => applicant_rec.gcse_sci
       ,x_welshspeaker                        => applicant_rec.welshspeaker
       ,x_ni_number                           => applicant_rec.ni_number
       ,x_earliest_start                      => applicant_rec.earliest_start
       ,x_near_inst                           => applicant_rec.near_inst
       ,x_pref_reg                            => applicant_rec.pref_reg
       ,x_qual_eng                            => applicant_rec.qual_eng
       ,x_qual_math                           => applicant_rec.qual_math
       ,x_qual_sci                            => applicant_rec.qual_sci
       ,x_main_qual                           => applicant_rec.main_qual
       ,x_qual_5                              => applicant_rec.qual_5
       ,x_future_serv                         => applicant_rec.future_serv
       ,x_future_set                          => applicant_rec.future_set
       ,x_present_serv                        => applicant_rec.present_serv
       ,x_present_set                         => applicant_rec.present_set
       ,x_curr_employment                     => applicant_rec.curr_employment
       ,x_edu_qualification                   => applicant_rec.edu_qualification
       ,x_ad_batch_id                         => applicant_rec.ad_batch_id
       ,x_ad_interface_id                     => applicant_rec.ad_interface_id
       ,x_nationality                         => applicant_rec.nationality
       ,x_dual_nationality                    => applicant_rec.dual_nationality
       ,x_special_needs                       => applicant_rec.special_needs
       ,x_country_birth                       => applicant_rec.country_birth
      );

      l_app_count := l_app_count + 1;

      fnd_message.set_name('IGS','IGS_UC_UPD_APP_PID_REC');
      fnd_message.set_token('APP_NO', TO_CHAR(applicant_rec.app_no));
      fnd_message.set_token('OSS_PID',TO_CHAR(applicant_rec.pe_person_id));
      fnd_file.put_line(fnd_file.log, fnd_message.get);

    END LOOP;

    fnd_file.put_line(fnd_file.log, ' ');
    fnd_message.set_name('IGS','IGS_UC_APP_COUNT');
    fnd_message.set_token('APP_COUNT', TO_CHAR(l_app_count));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      retcode := 2;
      Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME', 'IGS_UC_DAT_IMP_FROM_UCAS.UPDATE_UCAS_APP_WITH_PERS_ID');
      errbuf  := fnd_message.get;
      Igs_Ge_Msg_Stack.CONC_EXCEPTION_HNDL;

  END update_ucas_app_with_pers_id;

END igs_uc_dat_imp_from_ucas;

/
