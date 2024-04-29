--------------------------------------------------------
--  DDL for Package Body IGS_AS_DOC_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_DOC_DETAILS_PKG" AS
/* $Header: IGSDI71B.pls 115.11 2004/01/16 08:40:31 kdande noship $ */
  l_rowid        VARCHAR2 (25);
  old_references igs_as_doc_details%ROWTYPE;
  new_references igs_as_doc_details%ROWTYPE;
  --
  --
  --
  PROCEDURE update_fees_of_remaining_items (
    x_person_id                    IN     NUMBER,
    x_document_type                IN     VARCHAR2,
    x_document_sub_type            IN     VARCHAR2
  ) IS
    --
    -- Get the items whose document fee is to be re-calculated
    --
    CURSOR cur_items_to_be_processed IS
      SELECT   doc.ROWID,
               doc.*
      FROM     igs_as_doc_details doc
      WHERE    doc.person_id = x_person_id
      AND      doc.document_type = x_document_type
      AND      doc.document_sub_type = x_document_sub_type
      AND      doc.item_status = 'INCOMPLETE'
      ORDER BY creation_date;
    --
    l_return_status VARCHAR2 (10);
    l_msg_data      VARCHAR2 (2000);
    l_msg_count     NUMBER;
  BEGIN
    FOR rec_items_to_be_processed IN cur_items_to_be_processed LOOP
      igs_as_doc_details_pkg.update_row (
        x_rowid                        => rec_items_to_be_processed.ROWID,
        x_order_number                 => rec_items_to_be_processed.order_number,
        x_document_type                => rec_items_to_be_processed.document_type,
        x_document_sub_type            => rec_items_to_be_processed.document_sub_type,
        x_item_number                  => rec_items_to_be_processed.item_number,
        x_item_status                  => rec_items_to_be_processed.item_status,
        x_date_produced                => rec_items_to_be_processed.date_produced,
        x_incl_curr_course             => rec_items_to_be_processed.incl_curr_course,
        x_num_of_copies                => rec_items_to_be_processed.num_of_copies,
        x_comments                     => rec_items_to_be_processed.comments,
        x_recip_pers_name              => rec_items_to_be_processed.recip_pers_name,
        x_recip_inst_name              => rec_items_to_be_processed.recip_inst_name,
        x_recip_addr_line_1            => rec_items_to_be_processed.recip_addr_line_1,
        x_recip_addr_line_2            => rec_items_to_be_processed.recip_addr_line_2,
        x_recip_addr_line_3            => rec_items_to_be_processed.recip_addr_line_3,
        x_recip_addr_line_4            => rec_items_to_be_processed.recip_addr_line_4,
        x_recip_city                   => rec_items_to_be_processed.recip_city,
        x_recip_postal_code            => rec_items_to_be_processed.recip_postal_code,
        x_recip_state                  => rec_items_to_be_processed.recip_state,
        x_recip_province               => rec_items_to_be_processed.recip_province,
        x_recip_county                 => rec_items_to_be_processed.recip_county,
        x_recip_country                => rec_items_to_be_processed.recip_country,
        x_recip_fax_area_code          => rec_items_to_be_processed.recip_fax_area_code,
        x_recip_fax_country_code       => rec_items_to_be_processed.recip_fax_country_code,
        x_recip_fax_number             => rec_items_to_be_processed.recip_fax_number,
        x_delivery_method_type         => rec_items_to_be_processed.delivery_method_type,
        x_programs_on_file             => rec_items_to_be_processed.programs_on_file,
        x_missing_acad_record_data_ind => rec_items_to_be_processed.missing_acad_record_data_ind,
        x_missing_academic_record_data => rec_items_to_be_processed.missing_academic_record_data,
        x_send_transcript_immediately  => rec_items_to_be_processed.send_transcript_immediately,
        x_hold_release_of_final_grades => rec_items_to_be_processed.hold_release_of_final_grades,
        x_fgrade_cal_type              => rec_items_to_be_processed.fgrade_cal_type,
        x_fgrade_seq_num               => rec_items_to_be_processed.fgrade_seq_num,
        x_hold_degree_expected         => rec_items_to_be_processed.hold_degree_expected,
        x_deghold_cal_type             => rec_items_to_be_processed.deghold_cal_type,
        x_deghold_seq_num              => rec_items_to_be_processed.deghold_seq_num,
        x_hold_for_grade_chg           => rec_items_to_be_processed.hold_for_grade_chg,
        x_special_instr                => rec_items_to_be_processed.special_instr,
        x_express_mail_type            => rec_items_to_be_processed.express_mail_type,
        x_express_mail_track_num       => rec_items_to_be_processed.express_mail_track_num,
        x_ge_certification             => rec_items_to_be_processed.ge_certification,
        x_external_comments            => rec_items_to_be_processed.external_comments,
        x_internal_comments            => rec_items_to_be_processed.internal_comments,
        x_dup_requested                => rec_items_to_be_processed.dup_requested,
        x_dup_req_date                 => rec_items_to_be_processed.dup_req_date,
        x_dup_sent_date                => rec_items_to_be_processed.dup_sent_date,
        x_enr_term_cal_type            => rec_items_to_be_processed.enr_term_cal_type,
        x_enr_ci_sequence_number       => rec_items_to_be_processed.enr_ci_sequence_number,
        x_incl_attempted_hours         => rec_items_to_be_processed.incl_attempted_hours,
        x_incl_class_rank              => rec_items_to_be_processed.incl_class_rank,
        x_incl_progresssion_status     => rec_items_to_be_processed.incl_progresssion_status,
        x_incl_class_standing          => rec_items_to_be_processed.incl_class_standing,
        x_incl_cum_hours_earned        => rec_items_to_be_processed.incl_cum_hours_earned,
        x_incl_gpa                     => rec_items_to_be_processed.incl_gpa,
        x_incl_date_of_graduation      => rec_items_to_be_processed.incl_date_of_graduation,
        x_incl_degree_dates            => rec_items_to_be_processed.incl_degree_dates,
        x_incl_degree_earned           => rec_items_to_be_processed.incl_degree_earned,
        x_incl_date_of_entry           => rec_items_to_be_processed.incl_date_of_entry,
        x_incl_drop_withdrawal_dates   => rec_items_to_be_processed.incl_drop_withdrawal_dates,
        x_incl_hrs_for_curr_term       => 'Y',
        x_incl_majors                  => rec_items_to_be_processed.incl_majors,
        x_incl_last_date_of_enrollment => rec_items_to_be_processed.incl_last_date_of_enrollment,
        x_incl_professional_licensure  => rec_items_to_be_processed.incl_professional_licensure,
        x_incl_college_affiliation     => rec_items_to_be_processed.incl_college_affiliation,
        x_incl_instruction_dates       => rec_items_to_be_processed.incl_instruction_dates,
        x_incl_usec_dates              => rec_items_to_be_processed.incl_usec_dates,
        x_incl_program_attempt         => rec_items_to_be_processed.incl_program_attempt,
        x_incl_attendence_type         => rec_items_to_be_processed.incl_attendence_type,
        x_incl_last_term_enrolled      => rec_items_to_be_processed.incl_last_term_enrolled,
        x_incl_ssn                     => rec_items_to_be_processed.incl_ssn,
        x_incl_date_of_birth           => rec_items_to_be_processed.incl_date_of_birth,
        x_incl_disciplin_standing      => rec_items_to_be_processed.incl_disciplin_standing,
        x_incl_no_future_term          => rec_items_to_be_processed.incl_no_future_term,
        x_incl_acurat_till_copmp_dt    => rec_items_to_be_processed.incl_acurat_till_copmp_dt,
        x_incl_cant_rel_without_sign   => rec_items_to_be_processed.incl_cant_rel_without_sign,
        x_mode                         => 'C',
        x_return_status                => l_return_status,
        x_msg_data                     => l_msg_data,
        x_msg_count                    => l_msg_count,
        x_doc_fee_per_copy             => rec_items_to_be_processed.doc_fee_per_copy,
        x_delivery_fee                 => rec_items_to_be_processed.delivery_fee,
        x_recip_email                  => rec_items_to_be_processed.recip_email,
        x_overridden_doc_delivery_fee  => rec_items_to_be_processed.overridden_doc_delivery_fee,
        x_overridden_document_fee      => rec_items_to_be_processed.overridden_document_fee,
        x_fee_overridden_by            => rec_items_to_be_processed.fee_overridden_by,
        x_fee_overridden_date          => rec_items_to_be_processed.fee_overridden_date,
        x_incl_department              => rec_items_to_be_processed.incl_department,
        x_incl_field_of_stdy           => rec_items_to_be_processed.incl_field_of_stdy,
        x_incl_attend_mode             => rec_items_to_be_processed.incl_attend_mode,
        x_incl_yop_acad_prd            => rec_items_to_be_processed.incl_yop_acad_prd,
        x_incl_intrmsn_st_end          => rec_items_to_be_processed.incl_intrmsn_st_end,
        x_incl_hnrs_lvl                => rec_items_to_be_processed.incl_hnrs_lvl,
        x_incl_awards                  => rec_items_to_be_processed.incl_awards,
        x_incl_award_aim               => rec_items_to_be_processed.incl_award_aim,
        x_incl_acad_sessions           => rec_items_to_be_processed.incl_acad_sessions,
        x_incl_st_end_acad_ses         => rec_items_to_be_processed.incl_st_end_acad_ses,
        x_incl_hesa_num                => rec_items_to_be_processed.incl_hesa_num,
        x_incl_location                => rec_items_to_be_processed.incl_location,
        x_incl_program_type            => rec_items_to_be_processed.incl_program_type,
        x_incl_program_name            => rec_items_to_be_processed.incl_program_name,
        x_incl_prog_atmpt_stat         => rec_items_to_be_processed.incl_prog_atmpt_stat,
        x_incl_prog_atmpt_end          => rec_items_to_be_processed.incl_prog_atmpt_end,
        x_incl_prog_atmpt_strt         => rec_items_to_be_processed.incl_prog_atmpt_strt,
        x_incl_req_cmplete             => rec_items_to_be_processed.incl_req_cmplete,
        x_incl_expected_compl_dt       => rec_items_to_be_processed.incl_expected_compl_dt,
        x_incl_conferral_dt            => rec_items_to_be_processed.incl_conferral_dt,
        x_incl_thesis_title            => rec_items_to_be_processed.incl_thesis_title,
        x_incl_program_code            => rec_items_to_be_processed.incl_program_code,
        x_incl_program_ver             => rec_items_to_be_processed.incl_program_ver,
        x_incl_stud_no                 => rec_items_to_be_processed.incl_stud_no,
        x_incl_surname                 => rec_items_to_be_processed.incl_surname,
        x_incl_fore_name               => rec_items_to_be_processed.incl_fore_name,
        x_incl_prev_names              => rec_items_to_be_processed.incl_prev_names,
        x_incl_initials                => rec_items_to_be_processed.incl_initials,
        x_doc_purpose_code             => rec_items_to_be_processed.doc_purpose_code,
        x_plan_id                      => rec_items_to_be_processed.plan_id,
        x_produced_by                  => rec_items_to_be_processed.produced_by,
        x_person_id                    => rec_items_to_be_processed.person_id
      );
    END LOOP;
  END update_fees_of_remaining_items;
  --
  --
  --
  PROCEDURE set_column_values (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2,
    x_order_number                 IN     NUMBER,
    x_document_type                IN     VARCHAR2,
    x_document_sub_type            IN     VARCHAR2,
    x_item_number                  IN     NUMBER,
    x_item_status                  IN     VARCHAR2,
    x_date_produced                IN     DATE,
    x_incl_curr_course             IN     VARCHAR2,
    x_num_of_copies                IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_recip_pers_name              IN     VARCHAR2,
    x_recip_inst_name              IN     VARCHAR2,
    x_recip_addr_line_1            IN     VARCHAR2,
    x_recip_addr_line_2            IN     VARCHAR2,
    x_recip_addr_line_3            IN     VARCHAR2,
    x_recip_addr_line_4            IN     VARCHAR2,
    x_recip_city                   IN     VARCHAR2,
    x_recip_postal_code            IN     VARCHAR2,
    x_recip_state                  IN     VARCHAR2,
    x_recip_province               IN     VARCHAR2,
    x_recip_county                 IN     VARCHAR2,
    x_recip_country                IN     VARCHAR2,
    x_recip_fax_area_code          IN     VARCHAR2,
    x_recip_fax_country_code       IN     VARCHAR2,
    x_recip_fax_number             IN     VARCHAR2,
    x_delivery_method_type         IN     VARCHAR2,
    x_programs_on_file             IN     VARCHAR2,
    x_missing_acad_record_data_ind IN     VARCHAR2,
    x_missing_academic_record_data IN     VARCHAR2,
    x_send_transcript_immediately  IN     VARCHAR2,
    x_hold_release_of_final_grades IN     VARCHAR2,
    x_fgrade_cal_type              IN     VARCHAR2,
    x_fgrade_seq_num               IN     NUMBER,
    x_hold_degree_expected         IN     VARCHAR2,
    x_deghold_cal_type             IN     VARCHAR2,
    x_deghold_seq_num              IN     NUMBER,
    x_hold_for_grade_chg           IN     VARCHAR2,
    x_special_instr                IN     VARCHAR2,
    x_express_mail_type            IN     VARCHAR2,
    x_express_mail_track_num       IN     VARCHAR2,
    x_ge_certification             IN     VARCHAR2,
    x_external_comments            IN     VARCHAR2,
    x_internal_comments            IN     VARCHAR2,
    x_dup_requested                IN     VARCHAR2,
    x_dup_req_date                 IN     DATE,
    x_dup_sent_date                IN     DATE,
    x_enr_term_cal_type            IN     VARCHAR2,
    x_enr_ci_sequence_number       IN     NUMBER,
    x_incl_attempted_hours         IN     VARCHAR2,
    x_incl_class_rank              IN     VARCHAR2,
    x_incl_progresssion_status     IN     VARCHAR2,
    x_incl_class_standing          IN     VARCHAR2,
    x_incl_cum_hours_earned        IN     VARCHAR2,
    x_incl_gpa                     IN     VARCHAR2,
    x_incl_date_of_graduation      IN     VARCHAR2,
    x_incl_degree_dates            IN     VARCHAR2,
    x_incl_degree_earned           IN     VARCHAR2,
    x_incl_date_of_entry           IN     VARCHAR2,
    x_incl_drop_withdrawal_dates   IN     VARCHAR2,
    x_incl_hrs_for_curr_term       IN     VARCHAR2,
    x_incl_majors                  IN     VARCHAR2,
    x_incl_last_date_of_enrollment IN     VARCHAR2,
    x_incl_professional_licensure  IN     VARCHAR2,
    x_incl_college_affiliation     IN     VARCHAR2,
    x_incl_instruction_dates       IN     VARCHAR2,
    x_incl_usec_dates              IN     VARCHAR2,
    x_incl_program_attempt         IN     VARCHAR2,
    x_incl_attendence_type         IN     VARCHAR2,
    x_incl_last_term_enrolled      IN     VARCHAR2,
    x_incl_ssn                     IN     VARCHAR2,
    x_incl_date_of_birth           IN     VARCHAR2,
    x_incl_disciplin_standing      IN     VARCHAR2,
    x_incl_no_future_term          IN     VARCHAR2,
    x_incl_acurat_till_copmp_dt    IN     VARCHAR2,
    x_incl_cant_rel_without_sign   IN     VARCHAR2,
    x_creation_date                IN     DATE,
    x_created_by                   IN     NUMBER,
    x_last_update_date             IN     DATE,
    x_last_updated_by              IN     NUMBER,
    x_last_update_login            IN     NUMBER,
    x_doc_fee_per_copy             IN     NUMBER,
    x_delivery_fee                 IN     NUMBER,
    x_recip_email                  IN     VARCHAR2,
    x_overridden_doc_delivery_fee  IN     NUMBER,
    x_overridden_document_fee      IN     NUMBER,
    x_fee_overridden_by            IN     NUMBER,
    x_fee_overridden_date          IN     DATE,
    x_incl_department              IN     VARCHAR2,
    x_incl_field_of_stdy           IN     VARCHAR2,
    x_incl_attend_mode             IN     VARCHAR2,
    x_incl_yop_acad_prd            IN     VARCHAR2,
    x_incl_intrmsn_st_end          IN     VARCHAR2,
    x_incl_hnrs_lvl                IN     VARCHAR2,
    x_incl_awards                  IN     VARCHAR2,
    x_incl_award_aim               IN     VARCHAR2,
    x_incl_acad_sessions           IN     VARCHAR2,
    x_incl_st_end_acad_ses         IN     VARCHAR2,
    x_incl_hesa_num                IN     VARCHAR2,
    x_incl_location                IN     VARCHAR2,
    x_incl_program_type            IN     VARCHAR2,
    x_incl_program_name            IN     VARCHAR2,
    x_incl_prog_atmpt_stat         IN     VARCHAR2,
    x_incl_prog_atmpt_end          IN     VARCHAR2,
    x_incl_prog_atmpt_strt         IN     VARCHAR2,
    x_incl_req_cmplete             IN     VARCHAR2,
    x_incl_expected_compl_dt       IN     VARCHAR2,
    x_incl_conferral_dt            IN     VARCHAR2,
    x_incl_thesis_title            IN     VARCHAR2,
    x_incl_program_code            IN     VARCHAR2,
    x_incl_program_ver             IN     VARCHAR2,
    x_incl_stud_no                 IN     VARCHAR2,
    x_incl_surname                 IN     VARCHAR2,
    x_incl_fore_name               IN     VARCHAR2,
    x_incl_prev_names              IN     VARCHAR2,
    x_incl_initials                IN     VARCHAR2,
    x_doc_purpose_code             IN     VARCHAR2,
    x_plan_id                      IN     NUMBER,
    x_produced_by                  IN     NUMBER,
    x_person_id                    IN     NUMBER
  ) AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Initialises the Old and New references for the columns of the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR cur_old_ref_values IS
      SELECT *
      FROM   igs_as_doc_details
      WHERE  ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND)
        AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))
       ) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.order_number := x_order_number;
    new_references.document_type := x_document_type;
    new_references.document_sub_type := x_document_sub_type;
    new_references.item_number := x_item_number;
    new_references.item_status := x_item_status;
    new_references.date_produced := x_date_produced;
    new_references.incl_curr_course := x_incl_curr_course;
    new_references.num_of_copies := x_num_of_copies;
    new_references.comments := x_comments;
    new_references.recip_pers_name := x_recip_pers_name;
    new_references.recip_inst_name := x_recip_inst_name;
    new_references.recip_addr_line_1 := x_recip_addr_line_1;
    new_references.recip_addr_line_2 := x_recip_addr_line_2;
    new_references.recip_addr_line_3 := x_recip_addr_line_3;
    new_references.recip_addr_line_4 := x_recip_addr_line_4;
    new_references.recip_city := x_recip_city;
    new_references.recip_postal_code := x_recip_postal_code;
    new_references.recip_state := x_recip_state;
    new_references.recip_province := x_recip_province;
    new_references.recip_county := x_recip_county;
    new_references.recip_country := x_recip_country;
    new_references.recip_fax_area_code := x_recip_fax_area_code;
    new_references.recip_fax_country_code := x_recip_fax_country_code;
    new_references.recip_fax_number := x_recip_fax_number;
    new_references.delivery_method_type := x_delivery_method_type;
    new_references.programs_on_file := x_programs_on_file;
    new_references.missing_acad_record_data_ind := x_missing_acad_record_data_ind;
    new_references.missing_academic_record_data := x_missing_academic_record_data;
    new_references.send_transcript_immediately := x_send_transcript_immediately;
    new_references.hold_release_of_final_grades := x_hold_release_of_final_grades;
    new_references.fgrade_cal_type := x_fgrade_cal_type;
    new_references.fgrade_seq_num := x_fgrade_seq_num;
    new_references.hold_degree_expected := x_hold_degree_expected;
    new_references.deghold_cal_type := x_deghold_cal_type;
    new_references.deghold_seq_num := x_deghold_seq_num;
    new_references.hold_for_grade_chg := x_hold_for_grade_chg;
    new_references.special_instr := x_special_instr;
    new_references.express_mail_type := x_express_mail_type;
    new_references.express_mail_track_num := x_express_mail_track_num;
    new_references.ge_certification := x_ge_certification;
    new_references.external_comments := x_external_comments;
    new_references.internal_comments := x_internal_comments;
    new_references.dup_requested := x_dup_requested;
    new_references.dup_req_date := x_dup_req_date;
    new_references.dup_sent_date := x_dup_sent_date;
    new_references.enr_term_cal_type := x_enr_term_cal_type;
    new_references.enr_ci_sequence_number := x_enr_ci_sequence_number;
    new_references.incl_attempted_hours := x_incl_attempted_hours;
    new_references.incl_class_rank := x_incl_class_rank;
    new_references.incl_progresssion_status := x_incl_progresssion_status;
    new_references.incl_class_standing := x_incl_class_standing;
    new_references.incl_cum_hours_earned := x_incl_cum_hours_earned;
    new_references.incl_gpa := x_incl_gpa;
    new_references.incl_date_of_graduation := x_incl_date_of_graduation;
    new_references.incl_degree_dates := x_incl_degree_dates;
    new_references.incl_degree_earned := x_incl_degree_earned;
    new_references.incl_date_of_entry := x_incl_date_of_entry;
    new_references.incl_drop_withdrawal_dates := x_incl_drop_withdrawal_dates;
    new_references.incl_hrs_earned_for_curr_term := x_incl_hrs_for_curr_term;
    new_references.incl_majors := x_incl_majors;
    new_references.incl_last_date_of_enrollment := x_incl_last_date_of_enrollment;
    new_references.incl_professional_licensure := x_incl_professional_licensure;
    new_references.incl_college_affiliation := x_incl_college_affiliation;
    new_references.incl_instruction_dates := x_incl_instruction_dates;
    new_references.incl_usec_dates := x_incl_usec_dates;
    new_references.incl_program_attempt := x_incl_program_attempt;
    new_references.incl_attendence_type := x_incl_attendence_type;
    new_references.incl_last_term_enrolled := x_incl_last_term_enrolled;
    new_references.incl_ssn := x_incl_ssn;
    new_references.incl_date_of_birth := x_incl_date_of_birth;
    new_references.incl_disciplin_standing := x_incl_disciplin_standing;
    new_references.incl_no_future_term := x_incl_no_future_term;
    new_references.incl_acurat_till_copmp_dt := x_incl_acurat_till_copmp_dt;
    new_references.incl_cant_rel_without_sign := x_incl_cant_rel_without_sign;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
    new_references.doc_fee_per_copy := x_doc_fee_per_copy;
    new_references.delivery_fee := x_delivery_fee;
    new_references.recip_email := x_recip_email;
    new_references.overridden_doc_delivery_fee := x_overridden_doc_delivery_fee;
    new_references.overridden_document_fee := x_overridden_document_fee;
    new_references.fee_overridden_by := x_fee_overridden_by;
    new_references.fee_overridden_date := x_fee_overridden_date;
    new_references.incl_department := x_incl_department;
    new_references.incl_field_of_stdy := x_incl_field_of_stdy;
    new_references.incl_attend_mode := x_incl_attend_mode;
    new_references.incl_yop_acad_prd := x_incl_yop_acad_prd;
    new_references.incl_intrmsn_st_end := x_incl_intrmsn_st_end;
    new_references.incl_hnrs_lvl := x_incl_hnrs_lvl;
    new_references.incl_awards := x_incl_awards;
    new_references.incl_award_aim := x_incl_award_aim;
    new_references.incl_acad_sessions := x_incl_acad_sessions;
    new_references.incl_st_end_acad_ses := x_incl_st_end_acad_ses;
    new_references.incl_hesa_num := x_incl_hesa_num;
    new_references.incl_location := x_incl_location;
    new_references.incl_program_type := x_incl_program_type;
    new_references.incl_program_name := x_incl_program_name;
    new_references.incl_prog_atmpt_stat := x_incl_prog_atmpt_stat;
    new_references.incl_prog_atmpt_end := x_incl_prog_atmpt_end;
    new_references.incl_prog_atmpt_strt := x_incl_prog_atmpt_strt;
    new_references.incl_req_cmplete := x_incl_req_cmplete;
    new_references.incl_expected_compl_dt := x_incl_expected_compl_dt;
    new_references.incl_conferral_dt := x_incl_conferral_dt;
    new_references.incl_thesis_title := x_incl_thesis_title;
    new_references.incl_program_code := x_incl_program_code;
    new_references.incl_program_ver := x_incl_program_ver;
    new_references.incl_stud_no := x_incl_stud_no;
    new_references.incl_surname := x_incl_surname;
    new_references.incl_fore_name := x_incl_fore_name;
    new_references.incl_prev_names := x_incl_prev_names;
    new_references.incl_initials := x_incl_initials;
    new_references.doc_purpose_code := x_doc_purpose_code;
    new_references.plan_id := x_plan_id;
    new_references.produced_by := x_produced_by;
    new_references.person_id := x_person_id;
  END set_column_values;
  --
  --
  --
  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : manu.srinivasan
  ||  Created On : 28-JAN-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF (((old_references.delivery_method_type = new_references.delivery_method_type))
        OR ((new_references.delivery_method_type IS NULL))
       ) THEN
      NULL;
    /* ELSIF NOT igs_as_doc_dlvy_typ_pkg.get_pk_For_validation (
              new_references.delivery_method_type
            ) THEN
    fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;*/
    END IF;
    IF (((old_references.fgrade_cal_type = new_references.fgrade_cal_type)
         AND (old_references.fgrade_seq_num = new_references.fgrade_seq_num)
        )
        OR ((new_references.fgrade_cal_type IS NULL)
            OR (new_references.fgrade_seq_num IS NULL)
           )
       ) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (new_references.fgrade_cal_type, new_references.fgrade_seq_num) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    IF (((old_references.deghold_cal_type = new_references.deghold_cal_type)
         AND (old_references.deghold_seq_num = new_references.deghold_seq_num)
        )
        OR ((new_references.deghold_cal_type IS NULL)
            OR (new_references.deghold_seq_num IS NULL)
           )
       ) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (new_references.deghold_cal_type, new_references.deghold_seq_num) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    IF (((old_references.order_number = new_references.order_number))
        OR ((new_references.order_number IS NULL))
       ) THEN
      NULL;
    ELSIF NOT igs_as_order_hdr_pkg.get_pk_for_validation (new_references.order_number) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
  END check_parent_existance;
  --
  --
  --
  FUNCTION get_pk_for_validation (x_item_number IN NUMBER)
    RETURN BOOLEAN AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Validates the Primary Key of the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR cur_rowid IS
      SELECT     ROWID
      FROM       igs_as_doc_details
      WHERE      item_number = x_item_number
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN (TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN (FALSE);
    END IF;
  END get_pk_for_validation;

  PROCEDURE get_fk_igs_as_doc_dlvy_typ (x_delivery_method_type IN VARCHAR2) AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Validates the Foreign Keys for the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_doc_details
      WHERE  ((delivery_method_type = x_delivery_method_type));
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AS_TIINFO_TDELY_FK');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_as_doc_dlvy_typ;
  --
  --
  --
  PROCEDURE get_fk_igs_ca_inst (x_cal_type IN VARCHAR2, x_sequence_number IN NUMBER) AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Validates the Foreign Keys for the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_doc_details
      WHERE  ((fgrade_cal_type = x_cal_type)
              AND (fgrade_seq_num = x_sequence_number)
             )
OR           ((deghold_cal_type = x_cal_type)
              AND (deghold_seq_num = x_sequence_number)
             );
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AS_TIINFO_CA_FK');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_ca_inst;
  --
  --
  --
  PROCEDURE get_fk_igs_as_order_hdr (x_order_number IN NUMBER) AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Validates the Foreign Keys for the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_doc_details
      WHERE  ((order_number = x_order_number));
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AS_TIINFO_ORDHDR_FK');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_as_order_hdr;
  --
  --
  --
  PROCEDURE before_dml (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2,
    x_order_number                 IN     NUMBER,
    x_document_type                IN     VARCHAR2,
    x_document_sub_type            IN     VARCHAR2,
    x_item_number                  IN     NUMBER,
    x_item_status                  IN     VARCHAR2,
    x_date_produced                IN     DATE,
    x_incl_curr_course             IN     VARCHAR2,
    x_num_of_copies                IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_recip_pers_name              IN     VARCHAR2,
    x_recip_inst_name              IN     VARCHAR2,
    x_recip_addr_line_1            IN     VARCHAR2,
    x_recip_addr_line_2            IN     VARCHAR2,
    x_recip_addr_line_3            IN     VARCHAR2,
    x_recip_addr_line_4            IN     VARCHAR2,
    x_recip_city                   IN     VARCHAR2,
    x_recip_postal_code            IN     VARCHAR2,
    x_recip_state                  IN     VARCHAR2,
    x_recip_province               IN     VARCHAR2,
    x_recip_county                 IN     VARCHAR2,
    x_recip_country                IN     VARCHAR2,
    x_recip_fax_area_code          IN     VARCHAR2,
    x_recip_fax_country_code       IN     VARCHAR2,
    x_recip_fax_number             IN     VARCHAR2,
    x_delivery_method_type         IN     VARCHAR2,
    x_programs_on_file             IN     VARCHAR2,
    x_missing_acad_record_data_ind IN     VARCHAR2,
    x_missing_academic_record_data IN     VARCHAR2,
    x_send_transcript_immediately  IN     VARCHAR2,
    x_hold_release_of_final_grades IN     VARCHAR2,
    x_fgrade_cal_type              IN     VARCHAR2,
    x_fgrade_seq_num               IN     NUMBER,
    x_hold_degree_expected         IN     VARCHAR2,
    x_deghold_cal_type             IN     VARCHAR2,
    x_deghold_seq_num              IN     NUMBER,
    x_hold_for_grade_chg           IN     VARCHAR2,
    x_special_instr                IN     VARCHAR2,
    x_express_mail_type            IN     VARCHAR2,
    x_express_mail_track_num       IN     VARCHAR2,
    x_ge_certification             IN     VARCHAR2,
    x_external_comments            IN     VARCHAR2,
    x_internal_comments            IN     VARCHAR2,
    x_dup_requested                IN     VARCHAR2,
    x_dup_req_date                 IN     DATE,
    x_dup_sent_date                IN     DATE,
    x_enr_term_cal_type            IN     VARCHAR2,
    x_enr_ci_sequence_number       IN     NUMBER,
    x_incl_attempted_hours         IN     VARCHAR2,
    x_incl_class_rank              IN     VARCHAR2,
    x_incl_progresssion_status     IN     VARCHAR2,
    x_incl_class_standing          IN     VARCHAR2,
    x_incl_cum_hours_earned        IN     VARCHAR2,
    x_incl_gpa                     IN     VARCHAR2,
    x_incl_date_of_graduation      IN     VARCHAR2,
    x_incl_degree_dates            IN     VARCHAR2,
    x_incl_degree_earned           IN     VARCHAR2,
    x_incl_date_of_entry           IN     VARCHAR2,
    x_incl_drop_withdrawal_dates   IN     VARCHAR2,
    x_incl_hrs_for_curr_term       IN     VARCHAR2,
    x_incl_majors                  IN     VARCHAR2,
    x_incl_last_date_of_enrollment IN     VARCHAR2,
    x_incl_professional_licensure  IN     VARCHAR2,
    x_incl_college_affiliation     IN     VARCHAR2,
    x_incl_instruction_dates       IN     VARCHAR2,
    x_incl_usec_dates              IN     VARCHAR2,
    x_incl_program_attempt         IN     VARCHAR2,
    x_incl_attendence_type         IN     VARCHAR2,
    x_incl_last_term_enrolled      IN     VARCHAR2,
    x_incl_ssn                     IN     VARCHAR2,
    x_incl_date_of_birth           IN     VARCHAR2,
    x_incl_disciplin_standing      IN     VARCHAR2,
    x_incl_no_future_term          IN     VARCHAR2,
    x_incl_acurat_till_copmp_dt    IN     VARCHAR2,
    x_incl_cant_rel_without_sign   IN     VARCHAR2,
    x_creation_date                IN     DATE,
    x_created_by                   IN     NUMBER,
    x_last_update_date             IN     DATE,
    x_last_updated_by              IN     NUMBER,
    x_last_update_login            IN     NUMBER,
    x_doc_fee_per_copy             IN     NUMBER,
    x_delivery_fee                 IN     NUMBER,
    x_recip_email                  IN     VARCHAR2,
    x_overridden_doc_delivery_fee  IN     NUMBER,
    x_overridden_document_fee      IN     NUMBER,
    x_fee_overridden_by            IN     NUMBER,
    x_fee_overridden_date          IN     DATE,
    x_incl_department              IN     VARCHAR2,
    x_incl_field_of_stdy           IN     VARCHAR2,
    x_incl_attend_mode             IN     VARCHAR2,
    x_incl_yop_acad_prd            IN     VARCHAR2,
    x_incl_intrmsn_st_end          IN     VARCHAR2,
    x_incl_hnrs_lvl                IN     VARCHAR2,
    x_incl_awards                  IN     VARCHAR2,
    x_incl_award_aim               IN     VARCHAR2,
    x_incl_acad_sessions           IN     VARCHAR2,
    x_incl_st_end_acad_ses         IN     VARCHAR2,
    x_incl_hesa_num                IN     VARCHAR2,
    x_incl_location                IN     VARCHAR2,
    x_incl_program_type            IN     VARCHAR2,
    x_incl_program_name            IN     VARCHAR2,
    x_incl_prog_atmpt_stat         IN     VARCHAR2,
    x_incl_prog_atmpt_end          IN     VARCHAR2,
    x_incl_prog_atmpt_strt         IN     VARCHAR2,
    x_incl_req_cmplete             IN     VARCHAR2,
    x_incl_expected_compl_dt       IN     VARCHAR2,
    x_incl_conferral_dt            IN     VARCHAR2,
    x_incl_thesis_title            IN     VARCHAR2,
    x_incl_program_code            IN     VARCHAR2,
    x_incl_program_ver             IN     VARCHAR2,
    x_incl_stud_no                 IN     VARCHAR2,
    x_incl_surname                 IN     VARCHAR2,
    x_incl_fore_name               IN     VARCHAR2,
    x_incl_prev_names              IN     VARCHAR2,
    x_incl_initials                IN     VARCHAR2,
    x_doc_purpose_code             IN     VARCHAR2,
    x_plan_id                      IN     NUMBER,
    x_produced_by                  IN     NUMBER,
    x_person_id                    IN     NUMBER
  ) AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Initialises the columns, Checks Constraints, Calls the
    ||            Trigger Handlers for the table, before any DML operation.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR c_pers IS
      SELECT person_id,
             request_type
      FROM   igs_as_order_hdr
      WHERE  order_number = x_order_number;
    CURSOR c_trans_fee IS
      SELECT COUNT (*)
      FROM   igs_as_doc_details
      WHERE  order_number = x_order_number
      AND    document_sub_type = 'LIFE_TIME_TRANS';
    l_person_id         igs_as_order_hdr.person_id%TYPE;
    l_doc_fee           igs_as_doc_details.doc_fee_per_copy%TYPE;
    l_delivery_fee      igs_as_doc_details.delivery_fee%TYPE;
    l_num_lft_in_order  NUMBER;
    l_plan_id           igs_as_doc_details.plan_id%TYPE;
    l_request_type      igs_as_order_hdr.request_type%TYPE;
    l_old_doc_fee       igs_as_doc_details.doc_fee_per_copy%TYPE;
    l_old_delivery_fee  igs_as_doc_details.delivery_fee%TYPE;
    l_old_num_of_copies igs_as_doc_details.num_of_copies%TYPE;
    CURSOR cur_doc_and_deliv_fee IS
      SELECT num_of_copies
      FROM   igs_as_doc_details
      WHERE  item_number = NVL (x_item_number, -1);
  BEGIN
    l_plan_id := x_plan_id;
    OPEN c_pers;
    FETCH c_pers INTO l_person_id,
                      l_request_type;
    CLOSE c_pers;
    OPEN c_trans_fee;
    FETCH c_trans_fee INTO l_num_lft_in_order;
    CLOSE c_trans_fee;
    -- Get the delivery and document fee.
    IF p_action <> 'DELETE' THEN
      igs_as_ss_doc_request.get_doc_and_delivery_fee (
        p_person_id                    => l_person_id,
        p_document_type                => x_document_type,
        p_document_sub_type            => x_document_sub_type,
        p_number_of_copies             => x_num_of_copies,
        p_delivery_method_type         => x_delivery_method_type,
        p_document_fee                 => l_doc_fee,
        p_delivery_fee                 => l_delivery_fee,
        p_program_on_file              => x_programs_on_file,
        p_plan_id                      => l_plan_id,
        p_item_number                  => x_item_number
      );
    END IF;
    -- If it is a bulk order then make document fee = 0;
    IF NVL (l_request_type, 'X') = 'B' THEN
      l_doc_fee := 0;
      l_plan_id := NULL;
    END IF;
    set_column_values (
      p_action,
      x_rowid,
      x_order_number,
      x_document_type,
      x_document_sub_type,
      x_item_number,
      x_item_status,
      x_date_produced,
      x_incl_curr_course,
      x_num_of_copies,
      x_comments,
      x_recip_pers_name,
      x_recip_inst_name,
      x_recip_addr_line_1,
      x_recip_addr_line_2,
      x_recip_addr_line_3,
      x_recip_addr_line_4,
      x_recip_city,
      x_recip_postal_code,
      x_recip_state,
      x_recip_province,
      x_recip_county,
      x_recip_country,
      x_recip_fax_area_code,
      x_recip_fax_country_code,
      x_recip_fax_number,
      x_delivery_method_type,
      x_programs_on_file,
      x_missing_acad_record_data_ind,
      x_missing_academic_record_data,
      x_send_transcript_immediately,
      x_hold_release_of_final_grades,
      x_fgrade_cal_type,
      x_fgrade_seq_num,
      x_hold_degree_expected,
      x_deghold_cal_type,
      x_deghold_seq_num,
      x_hold_for_grade_chg,
      x_special_instr,
      x_express_mail_type,
      x_express_mail_track_num,
      x_ge_certification,
      x_external_comments,
      x_internal_comments,
      x_dup_requested,
      x_dup_req_date,
      x_dup_sent_date,
      x_enr_term_cal_type,
      x_enr_ci_sequence_number,
      x_incl_attempted_hours,
      x_incl_class_rank,
      x_incl_progresssion_status,
      x_incl_class_standing,
      x_incl_cum_hours_earned,
      x_incl_gpa,
      x_incl_date_of_graduation,
      x_incl_degree_dates,
      x_incl_degree_earned,
      x_incl_date_of_entry,
      x_incl_drop_withdrawal_dates,
      x_incl_hrs_for_curr_term,
      x_incl_majors,
      x_incl_last_date_of_enrollment,
      x_incl_professional_licensure,
      x_incl_college_affiliation,
      x_incl_instruction_dates,
      x_incl_usec_dates,
      x_incl_program_attempt,
      x_incl_attendence_type,
      x_incl_last_term_enrolled,
      x_incl_ssn,
      x_incl_date_of_birth,
      x_incl_disciplin_standing,
      x_incl_no_future_term,
      x_incl_acurat_till_copmp_dt,
      x_incl_cant_rel_without_sign,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l_doc_fee,
      l_delivery_fee,
      x_recip_email,
      x_overridden_doc_delivery_fee,
      x_overridden_document_fee,
      x_fee_overridden_by,
      x_fee_overridden_date,
      x_incl_department,
      x_incl_field_of_stdy,
      x_incl_attend_mode,
      x_incl_yop_acad_prd,
      x_incl_intrmsn_st_end,
      x_incl_hnrs_lvl,
      x_incl_awards,
      x_incl_award_aim,
      x_incl_acad_sessions,
      x_incl_st_end_acad_ses,
      x_incl_hesa_num,
      x_incl_location,
      x_incl_program_type,
      x_incl_program_name,
      x_incl_prog_atmpt_stat,
      x_incl_prog_atmpt_end,
      x_incl_prog_atmpt_strt,
      x_incl_req_cmplete,
      x_incl_expected_compl_dt,
      x_incl_conferral_dt,
      x_incl_thesis_title,
      x_incl_program_code,
      x_incl_program_ver,
      x_incl_stud_no,
      x_incl_surname,
      x_incl_fore_name,
      x_incl_prev_names,
      x_incl_initials,
      x_doc_purpose_code,
      l_plan_id,
      x_produced_by,
      x_person_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF (get_pk_for_validation (new_references.item_number)) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF (get_pk_for_validation (new_references.item_number)) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  END before_dml;
  --
  --
  --
  PROCEDURE insert_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_order_number                 IN     NUMBER,
    x_document_type                IN     VARCHAR2,
    x_document_sub_type            IN     VARCHAR2,
    x_item_number                  IN OUT NOCOPY NUMBER,
    x_item_status                  IN     VARCHAR2,
    x_date_produced                IN     DATE,
    x_incl_curr_course             IN     VARCHAR2,
    x_num_of_copies                IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_recip_pers_name              IN     VARCHAR2,
    x_recip_inst_name              IN     VARCHAR2,
    x_recip_addr_line_1            IN     VARCHAR2,
    x_recip_addr_line_2            IN     VARCHAR2,
    x_recip_addr_line_3            IN     VARCHAR2,
    x_recip_addr_line_4            IN     VARCHAR2,
    x_recip_city                   IN     VARCHAR2,
    x_recip_postal_code            IN     VARCHAR2,
    x_recip_state                  IN     VARCHAR2,
    x_recip_province               IN     VARCHAR2,
    x_recip_county                 IN     VARCHAR2,
    x_recip_country                IN     VARCHAR2,
    x_recip_fax_area_code          IN     VARCHAR2,
    x_recip_fax_country_code       IN     VARCHAR2,
    x_recip_fax_number             IN     VARCHAR2,
    x_delivery_method_type         IN     VARCHAR2,
    x_programs_on_file             IN     VARCHAR2,
    x_missing_acad_record_data_ind IN     VARCHAR2,
    x_missing_academic_record_data IN     VARCHAR2,
    x_send_transcript_immediately  IN     VARCHAR2,
    x_hold_release_of_final_grades IN     VARCHAR2,
    x_fgrade_cal_type              IN     VARCHAR2,
    x_fgrade_seq_num               IN     NUMBER,
    x_hold_degree_expected         IN     VARCHAR2,
    x_deghold_cal_type             IN     VARCHAR2,
    x_deghold_seq_num              IN     NUMBER,
    x_hold_for_grade_chg           IN     VARCHAR2,
    x_special_instr                IN     VARCHAR2,
    x_express_mail_type            IN     VARCHAR2,
    x_express_mail_track_num       IN     VARCHAR2,
    x_ge_certification             IN     VARCHAR2,
    x_external_comments            IN     VARCHAR2,
    x_internal_comments            IN     VARCHAR2,
    x_dup_requested                IN     VARCHAR2,
    x_dup_req_date                 IN     DATE,
    x_dup_sent_date                IN     DATE,
    x_enr_term_cal_type            IN     VARCHAR2,
    x_enr_ci_sequence_number       IN     NUMBER,
    x_incl_attempted_hours         IN     VARCHAR2,
    x_incl_class_rank              IN     VARCHAR2,
    x_incl_progresssion_status     IN     VARCHAR2,
    x_incl_class_standing          IN     VARCHAR2,
    x_incl_cum_hours_earned        IN     VARCHAR2,
    x_incl_gpa                     IN     VARCHAR2,
    x_incl_date_of_graduation      IN     VARCHAR2,
    x_incl_degree_dates            IN     VARCHAR2,
    x_incl_degree_earned           IN     VARCHAR2,
    x_incl_date_of_entry           IN     VARCHAR2,
    x_incl_drop_withdrawal_dates   IN     VARCHAR2,
    x_incl_hrs_for_curr_term       IN     VARCHAR2,
    x_incl_majors                  IN     VARCHAR2,
    x_incl_last_date_of_enrollment IN     VARCHAR2,
    x_incl_professional_licensure  IN     VARCHAR2,
    x_incl_college_affiliation     IN     VARCHAR2,
    x_incl_instruction_dates       IN     VARCHAR2,
    x_incl_usec_dates              IN     VARCHAR2,
    x_incl_program_attempt         IN     VARCHAR2,
    x_incl_attendence_type         IN     VARCHAR2,
    x_incl_last_term_enrolled      IN     VARCHAR2,
    x_incl_ssn                     IN     VARCHAR2,
    x_incl_date_of_birth           IN     VARCHAR2,
    x_incl_disciplin_standing      IN     VARCHAR2,
    x_incl_no_future_term          IN     VARCHAR2,
    x_incl_acurat_till_copmp_dt    IN     VARCHAR2,
    x_incl_cant_rel_without_sign   IN     VARCHAR2,
    x_mode                         IN     VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_doc_fee_per_copy             IN     NUMBER,
    x_delivery_fee                 IN     NUMBER,
    x_recip_email                  IN     VARCHAR2,
    x_overridden_doc_delivery_fee  IN     NUMBER,
    x_overridden_document_fee      IN     NUMBER,
    x_fee_overridden_by            IN     NUMBER,
    x_fee_overridden_date          IN     DATE,
    x_incl_department              IN     VARCHAR2,
    x_incl_field_of_stdy           IN     VARCHAR2,
    x_incl_attend_mode             IN     VARCHAR2,
    x_incl_yop_acad_prd            IN     VARCHAR2,
    x_incl_intrmsn_st_end          IN     VARCHAR2,
    x_incl_hnrs_lvl                IN     VARCHAR2,
    x_incl_awards                  IN     VARCHAR2,
    x_incl_award_aim               IN     VARCHAR2,
    x_incl_acad_sessions           IN     VARCHAR2,
    x_incl_st_end_acad_ses         IN     VARCHAR2,
    x_incl_hesa_num                IN     VARCHAR2,
    x_incl_location                IN     VARCHAR2,
    x_incl_program_type            IN     VARCHAR2,
    x_incl_program_name            IN     VARCHAR2,
    x_incl_prog_atmpt_stat         IN     VARCHAR2,
    x_incl_prog_atmpt_end          IN     VARCHAR2,
    x_incl_prog_atmpt_strt         IN     VARCHAR2,
    x_incl_req_cmplete             IN     VARCHAR2,
    x_incl_expected_compl_dt       IN     VARCHAR2,
    x_incl_conferral_dt            IN     VARCHAR2,
    x_incl_thesis_title            IN     VARCHAR2,
    x_incl_program_code            IN     VARCHAR2,
    x_incl_program_ver             IN     VARCHAR2,
    x_incl_stud_no                 IN     VARCHAR2,
    x_incl_surname                 IN     VARCHAR2,
    x_incl_fore_name               IN     VARCHAR2,
    x_incl_prev_names              IN     VARCHAR2,
    x_incl_initials                IN     VARCHAR2,
    x_doc_purpose_code             IN     VARCHAR2,
    x_plan_id                      IN     NUMBER,
    x_produced_by                  IN     NUMBER,
    x_person_id                    IN     NUMBER
  ) AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Handles the INSERT DML logic for the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR c IS
      SELECT ROWID
      FROM   igs_as_doc_details
      WHERE  item_number = x_item_number;
    CURSOR c_other_items_in_order IS
      SELECT a.*,
             a.ROWID
      FROM   igs_as_doc_details a
      WHERE  order_number = x_order_number
      AND    item_number <> x_item_number
      AND    document_type = 'TRANSCRIPT';
    x_last_update_date       DATE;
    x_last_updated_by        NUMBER;
    x_last_update_login      NUMBER;
    x_request_id             NUMBER;
    x_program_id             NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date    DATE;
  BEGIN
    fnd_msg_pub.initialize;
    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id = -1) THEN
        x_request_id := NULL;
        x_program_id := NULL;
        x_program_application_id := NULL;
        x_program_update_date := NULL;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    IF x_item_number IS NULL THEN
      SELECT igs_as_doc_details_s.NEXTVAL
      INTO   x_item_number
      FROM   DUAL;
    END IF;
    before_dml (
      p_action                       => 'INSERT',
      x_rowid                        => x_rowid,
      x_order_number                 => x_order_number,
      x_document_type                => x_document_type,
      x_document_sub_type            => x_document_sub_type,
      x_item_number                  => x_item_number,
      x_item_status                  => x_item_status,
      x_date_produced                => x_date_produced,
      x_incl_curr_course             => x_incl_curr_course,
      x_num_of_copies                => x_num_of_copies,
      x_comments                     => x_comments,
      x_recip_pers_name              => x_recip_pers_name,
      x_recip_inst_name              => x_recip_inst_name,
      x_recip_addr_line_1            => x_recip_addr_line_1,
      x_recip_addr_line_2            => x_recip_addr_line_2,
      x_recip_addr_line_3            => x_recip_addr_line_3,
      x_recip_addr_line_4            => x_recip_addr_line_4,
      x_recip_city                   => x_recip_city,
      x_recip_postal_code            => x_recip_postal_code,
      x_recip_state                  => x_recip_state,
      x_recip_province               => x_recip_province,
      x_recip_county                 => x_recip_county,
      x_recip_country                => x_recip_country,
      x_recip_fax_area_code          => x_recip_fax_area_code,
      x_recip_fax_country_code       => x_recip_fax_country_code,
      x_recip_fax_number             => x_recip_fax_number,
      x_delivery_method_type         => x_delivery_method_type,
      x_programs_on_file             => x_programs_on_file,
      x_missing_acad_record_data_ind => x_missing_acad_record_data_ind,
      x_missing_academic_record_data => x_missing_academic_record_data,
      x_send_transcript_immediately  => x_send_transcript_immediately,
      x_hold_release_of_final_grades => x_hold_release_of_final_grades,
      x_fgrade_cal_type              => x_fgrade_cal_type,
      x_fgrade_seq_num               => x_fgrade_seq_num,
      x_hold_degree_expected         => x_hold_degree_expected,
      x_deghold_cal_type             => x_deghold_cal_type,
      x_deghold_seq_num              => x_deghold_seq_num,
      x_hold_for_grade_chg           => x_hold_for_grade_chg,
      x_special_instr                => x_special_instr,
      x_express_mail_type            => x_express_mail_type,
      x_express_mail_track_num       => x_express_mail_track_num,
      x_ge_certification             => x_ge_certification,
      x_external_comments            => x_external_comments,
      x_internal_comments            => x_internal_comments,
      x_dup_requested                => x_dup_requested,
      x_dup_req_date                 => x_dup_req_date,
      x_dup_sent_date                => x_dup_sent_date,
      x_enr_term_cal_type            => x_enr_term_cal_type,
      x_enr_ci_sequence_number       => x_enr_ci_sequence_number,
      x_incl_attempted_hours         => x_incl_attempted_hours,
      x_incl_class_rank              => x_incl_class_rank,
      x_incl_progresssion_status     => x_incl_progresssion_status,
      x_incl_class_standing          => x_incl_class_standing,
      x_incl_cum_hours_earned        => x_incl_cum_hours_earned,
      x_incl_gpa                     => x_incl_gpa,
      x_incl_date_of_graduation      => x_incl_date_of_graduation,
      x_incl_degree_dates            => x_incl_degree_dates,
      x_incl_degree_earned           => x_incl_degree_earned,
      x_incl_date_of_entry           => x_incl_date_of_entry,
      x_incl_drop_withdrawal_dates   => x_incl_drop_withdrawal_dates,
      x_incl_hrs_for_curr_term       => x_incl_hrs_for_curr_term,
      x_incl_majors                  => x_incl_majors,
      x_incl_last_date_of_enrollment => x_incl_last_date_of_enrollment,
      x_incl_professional_licensure  => x_incl_professional_licensure,
      x_incl_college_affiliation     => x_incl_college_affiliation,
      x_incl_instruction_dates       => x_incl_instruction_dates,
      x_incl_usec_dates              => x_incl_usec_dates,
      x_incl_program_attempt         => x_incl_program_attempt,
      x_incl_attendence_type         => x_incl_attendence_type,
      x_incl_last_term_enrolled      => x_incl_last_term_enrolled,
      x_incl_ssn                     => x_incl_ssn,
      x_incl_date_of_birth           => x_incl_date_of_birth,
      x_incl_disciplin_standing      => x_incl_disciplin_standing,
      x_incl_no_future_term          => x_incl_no_future_term,
      x_incl_acurat_till_copmp_dt    => x_incl_acurat_till_copmp_dt,
      x_incl_cant_rel_without_sign   => x_incl_cant_rel_without_sign,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_doc_fee_per_copy             => x_doc_fee_per_copy,
      x_delivery_fee                 => x_delivery_fee,
      x_recip_email                  => x_recip_email,
      x_overridden_doc_delivery_fee  => x_overridden_doc_delivery_fee,
      x_overridden_document_fee      => x_overridden_document_fee,
      x_fee_overridden_by            => x_fee_overridden_by,
      x_fee_overridden_date          => x_fee_overridden_date,
      x_incl_department              => x_incl_department,
      x_incl_field_of_stdy           => x_incl_field_of_stdy,
      x_incl_attend_mode             => x_incl_attend_mode,
      x_incl_yop_acad_prd            => x_incl_yop_acad_prd,
      x_incl_intrmsn_st_end          => x_incl_intrmsn_st_end,
      x_incl_hnrs_lvl                => x_incl_hnrs_lvl,
      x_incl_awards                  => x_incl_awards,
      x_incl_award_aim               => x_incl_award_aim,
      x_incl_acad_sessions           => x_incl_acad_sessions,
      x_incl_st_end_acad_ses         => x_incl_st_end_acad_ses,
      x_incl_hesa_num                => x_incl_hesa_num,
      x_incl_location                => x_incl_location,
      x_incl_program_type            => x_incl_program_type,
      x_incl_program_name            => x_incl_program_name,
      x_incl_prog_atmpt_stat         => x_incl_prog_atmpt_stat,
      x_incl_prog_atmpt_end          => x_incl_prog_atmpt_end,
      x_incl_prog_atmpt_strt         => x_incl_prog_atmpt_strt,
      x_incl_req_cmplete             => x_incl_req_cmplete,
      x_incl_expected_compl_dt       => x_incl_expected_compl_dt,
      x_incl_conferral_dt            => x_incl_conferral_dt,
      x_incl_thesis_title            => x_incl_thesis_title,
      x_incl_program_code            => x_incl_program_code,
      x_incl_program_ver             => x_incl_program_ver,
      x_incl_stud_no                 => x_incl_stud_no,
      x_incl_surname                 => x_incl_surname,
      x_incl_fore_name               => x_incl_fore_name,
      x_incl_prev_names              => x_incl_prev_names,
      x_incl_initials                => x_incl_initials,
      x_doc_purpose_code             => x_doc_purpose_code,
      x_plan_id                      => x_plan_id,
      x_produced_by                  => x_produced_by,
      x_person_id                    => x_person_id
    );
    INSERT INTO igs_as_doc_details
                (order_number, document_type, document_sub_type,
                 item_number, item_status, date_produced,
                 incl_curr_course, num_of_copies, comments,
                 recip_pers_name, recip_inst_name, recip_addr_line_1,
                 recip_addr_line_2, recip_addr_line_3, recip_addr_line_4,
                 recip_city, recip_postal_code, recip_state,
                 recip_province, recip_county, recip_country,
                 recip_fax_area_code, recip_fax_country_code,
                 recip_fax_number, delivery_method_type, programs_on_file,
                 missing_acad_record_data_ind, missing_academic_record_data,
                 send_transcript_immediately, hold_release_of_final_grades,
                 fgrade_cal_type, fgrade_seq_num, hold_degree_expected,
                 deghold_cal_type, deghold_seq_num, hold_for_grade_chg,
                 special_instr, express_mail_type, express_mail_track_num,
                 ge_certification, external_comments, internal_comments,
                 dup_requested, dup_req_date, dup_sent_date,
                 enr_term_cal_type, enr_ci_sequence_number,
                 incl_attempted_hours, incl_class_rank,
                 incl_progresssion_status, incl_class_standing,
                 incl_cum_hours_earned, incl_gpa, incl_date_of_graduation,
                 incl_degree_dates, incl_degree_earned, incl_date_of_entry,
                 incl_drop_withdrawal_dates, incl_hrs_earned_for_curr_term,
                 incl_majors, incl_last_date_of_enrollment,
                 incl_professional_licensure, incl_college_affiliation,
                 incl_instruction_dates, incl_usec_dates,
                 incl_program_attempt, incl_attendence_type,
                 incl_last_term_enrolled, incl_ssn, incl_date_of_birth,
                 incl_disciplin_standing, incl_no_future_term,
                 incl_acurat_till_copmp_dt, incl_cant_rel_without_sign,
                 creation_date, created_by, last_update_date, last_updated_by, last_update_login,
                 request_id, program_id, program_application_id, program_update_date,
                 doc_fee_per_copy, delivery_fee, recip_email,
                 overridden_doc_delivery_fee, overridden_document_fee,
                 fee_overridden_by, fee_overridden_date, incl_department,
                 incl_field_of_stdy, incl_attend_mode, incl_yop_acad_prd,
                 incl_intrmsn_st_end, incl_hnrs_lvl, incl_awards,
                 incl_award_aim, incl_acad_sessions, incl_st_end_acad_ses,
                 incl_hesa_num, incl_location, incl_program_type,
                 incl_program_name, incl_prog_atmpt_stat,
                 incl_prog_atmpt_end, incl_prog_atmpt_strt,
                 incl_req_cmplete, incl_expected_compl_dt,
                 incl_conferral_dt, incl_thesis_title, incl_program_code,
                 incl_program_ver, incl_stud_no, incl_surname,
                 incl_fore_name, incl_prev_names, incl_initials,
                 doc_purpose_code, plan_id, produced_by,
                 person_id)
         VALUES (new_references.order_number, new_references.document_type, new_references.document_sub_type,
                 new_references.item_number, new_references.item_status, new_references.date_produced,
                 new_references.incl_curr_course, new_references.num_of_copies, new_references.comments,
                 new_references.recip_pers_name, new_references.recip_inst_name, new_references.recip_addr_line_1,
                 new_references.recip_addr_line_2, new_references.recip_addr_line_3, new_references.recip_addr_line_4,
                 new_references.recip_city, new_references.recip_postal_code, new_references.recip_state,
                 new_references.recip_province, new_references.recip_county, new_references.recip_country,
                 new_references.recip_fax_area_code, new_references.recip_fax_country_code,
                 new_references.recip_fax_number, new_references.delivery_method_type, new_references.programs_on_file,
                 new_references.missing_acad_record_data_ind, new_references.missing_academic_record_data,
                 new_references.send_transcript_immediately, new_references.hold_release_of_final_grades,
                 new_references.fgrade_cal_type, new_references.fgrade_seq_num, new_references.hold_degree_expected,
                 new_references.deghold_cal_type, new_references.deghold_seq_num, new_references.hold_for_grade_chg,
                 new_references.special_instr, new_references.express_mail_type, new_references.express_mail_track_num,
                 new_references.ge_certification, new_references.external_comments, new_references.internal_comments,
                 new_references.dup_requested, new_references.dup_req_date, new_references.dup_sent_date,
                 new_references.enr_term_cal_type, new_references.enr_ci_sequence_number,
                 new_references.incl_attempted_hours, new_references.incl_class_rank,
                 new_references.incl_progresssion_status, new_references.incl_class_standing,
                 new_references.incl_cum_hours_earned, new_references.incl_gpa, new_references.incl_date_of_graduation,
                 new_references.incl_degree_dates, new_references.incl_degree_earned, new_references.incl_date_of_entry,
                 new_references.incl_drop_withdrawal_dates, new_references.incl_hrs_earned_for_curr_term,
                 new_references.incl_majors, new_references.incl_last_date_of_enrollment,
                 new_references.incl_professional_licensure, new_references.incl_college_affiliation,
                 new_references.incl_instruction_dates, new_references.incl_usec_dates,
                 new_references.incl_program_attempt, new_references.incl_attendence_type,
                 new_references.incl_last_term_enrolled, new_references.incl_ssn, new_references.incl_date_of_birth,
                 new_references.incl_disciplin_standing, new_references.incl_no_future_term,
                 new_references.incl_acurat_till_copmp_dt, new_references.incl_cant_rel_without_sign,
                 x_last_update_date, x_last_updated_by, x_last_update_date, x_last_updated_by, x_last_update_login,
                 x_request_id, x_program_id, x_program_application_id, x_program_update_date,
                 new_references.doc_fee_per_copy, new_references.delivery_fee, new_references.recip_email,
                 new_references.overridden_doc_delivery_fee, new_references.overridden_document_fee,
                 new_references.fee_overridden_by, new_references.fee_overridden_date, new_references.incl_department,
                 new_references.incl_field_of_stdy, new_references.incl_attend_mode, new_references.incl_yop_acad_prd,
                 new_references.incl_intrmsn_st_end, new_references.incl_hnrs_lvl, new_references.incl_awards,
                 new_references.incl_award_aim, new_references.incl_acad_sessions, new_references.incl_st_end_acad_ses,
                 new_references.incl_hesa_num, new_references.incl_location, new_references.incl_program_type,
                 new_references.incl_program_name, new_references.incl_prog_atmpt_stat,
                 new_references.incl_prog_atmpt_end, new_references.incl_prog_atmpt_strt,
                 new_references.incl_req_cmplete, new_references.incl_expected_compl_dt,
                 new_references.incl_conferral_dt, new_references.incl_thesis_title, new_references.incl_program_code,
                 new_references.incl_program_ver, new_references.incl_stud_no, new_references.incl_surname,
                 new_references.incl_fore_name, new_references.incl_prev_names, new_references.incl_initials,
                 new_references.doc_purpose_code, new_references.plan_id, new_references.produced_by,
                 new_references.person_id);
    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
    --Call to update the amount in order header table
    igs_as_ss_doc_request.update_order_fee (
      p_order_number                 => x_order_number,
      p_item_number                  => x_item_number,
      p_old_sub_doc_type             => NULL,
      p_old_deliv_type               => NULL,
      p_old_num_copies               => NULL,
      p_new_sub_doc_type             => x_document_sub_type,
      p_new_deliv_type               => x_delivery_method_type,
      p_new_num_copies               => x_num_of_copies,
      p_return_status                => x_return_status,
      p_msg_data                     => x_msg_data,
      p_msg_count                    => x_msg_count
    );
    IF NVL (x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;
    -- Call procedure to insert/Update record in IGS_AS_DOC_FEE_PMNT table.
    IF new_references.plan_id IS NOT NULL THEN
      igs_as_documents_api.upd_doc_fee_pmnt (
        p_person_id                    => new_references.person_id,
        p_plan_id                      => new_references.plan_id,
        p_num_copies                   => new_references.num_of_copies,
        p_program_on_file              => new_references.programs_on_file,
        p_operation                    => 'I'
      );
    END IF;
    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'Insert_Row : ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
  END insert_row;
  --
  --
  --
  PROCEDURE lock_row (
    x_rowid                        IN     VARCHAR2,
    x_order_number                 IN     NUMBER,
    x_document_type                IN     VARCHAR2,
    x_document_sub_type            IN     VARCHAR2,
    x_item_number                  IN     NUMBER,
    x_item_status                  IN     VARCHAR2,
    x_date_produced                IN     DATE,
    x_incl_curr_course             IN     VARCHAR2,
    x_num_of_copies                IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_recip_pers_name              IN     VARCHAR2,
    x_recip_inst_name              IN     VARCHAR2,
    x_recip_addr_line_1            IN     VARCHAR2,
    x_recip_addr_line_2            IN     VARCHAR2,
    x_recip_addr_line_3            IN     VARCHAR2,
    x_recip_addr_line_4            IN     VARCHAR2,
    x_recip_city                   IN     VARCHAR2,
    x_recip_postal_code            IN     VARCHAR2,
    x_recip_state                  IN     VARCHAR2,
    x_recip_province               IN     VARCHAR2,
    x_recip_county                 IN     VARCHAR2,
    x_recip_country                IN     VARCHAR2,
    x_recip_fax_area_code          IN     VARCHAR2,
    x_recip_fax_country_code       IN     VARCHAR2,
    x_recip_fax_number             IN     VARCHAR2,
    x_delivery_method_type         IN     VARCHAR2,
    x_programs_on_file             IN     VARCHAR2,
    x_missing_acad_record_data_ind IN     VARCHAR2,
    x_missing_academic_record_data IN     VARCHAR2,
    x_send_transcript_immediately  IN     VARCHAR2,
    x_hold_release_of_final_grades IN     VARCHAR2,
    x_fgrade_cal_type              IN     VARCHAR2,
    x_fgrade_seq_num               IN     NUMBER,
    x_hold_degree_expected         IN     VARCHAR2,
    x_deghold_cal_type             IN     VARCHAR2,
    x_deghold_seq_num              IN     NUMBER,
    x_hold_for_grade_chg           IN     VARCHAR2,
    x_special_instr                IN     VARCHAR2,
    x_express_mail_type            IN     VARCHAR2,
    x_express_mail_track_num       IN     VARCHAR2,
    x_ge_certification             IN     VARCHAR2,
    x_external_comments            IN     VARCHAR2,
    x_internal_comments            IN     VARCHAR2,
    x_dup_requested                IN     VARCHAR2,
    x_dup_req_date                 IN     DATE,
    x_dup_sent_date                IN     DATE,
    x_enr_term_cal_type            IN     VARCHAR2,
    x_enr_ci_sequence_number       IN     NUMBER,
    x_incl_attempted_hours         IN     VARCHAR2,
    x_incl_class_rank              IN     VARCHAR2,
    x_incl_progresssion_status     IN     VARCHAR2,
    x_incl_class_standing          IN     VARCHAR2,
    x_incl_cum_hours_earned        IN     VARCHAR2,
    x_incl_gpa                     IN     VARCHAR2,
    x_incl_date_of_graduation      IN     VARCHAR2,
    x_incl_degree_dates            IN     VARCHAR2,
    x_incl_degree_earned           IN     VARCHAR2,
    x_incl_date_of_entry           IN     VARCHAR2,
    x_incl_drop_withdrawal_dates   IN     VARCHAR2,
    x_incl_hrs_for_curr_term       IN     VARCHAR2,
    x_incl_majors                  IN     VARCHAR2,
    x_incl_last_date_of_enrollment IN     VARCHAR2,
    x_incl_professional_licensure  IN     VARCHAR2,
    x_incl_college_affiliation     IN     VARCHAR2,
    x_incl_instruction_dates       IN     VARCHAR2,
    x_incl_usec_dates              IN     VARCHAR2,
    x_incl_program_attempt         IN     VARCHAR2,
    x_incl_attendence_type         IN     VARCHAR2,
    x_incl_last_term_enrolled      IN     VARCHAR2,
    x_incl_ssn                     IN     VARCHAR2,
    x_incl_date_of_birth           IN     VARCHAR2,
    x_incl_disciplin_standing      IN     VARCHAR2,
    x_incl_no_future_term          IN     VARCHAR2,
    x_incl_acurat_till_copmp_dt    IN     VARCHAR2,
    x_incl_cant_rel_without_sign   IN     VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_doc_fee_per_copy             IN     NUMBER,
    x_delivery_fee                 IN     NUMBER,
    x_recip_email                  IN     VARCHAR2,
    x_overridden_doc_delivery_fee  IN     NUMBER,
    x_overridden_document_fee      IN     NUMBER,
    x_fee_overridden_by            IN     NUMBER,
    x_fee_overridden_date          IN     DATE,
    x_incl_department              IN     VARCHAR2,
    x_incl_field_of_stdy           IN     VARCHAR2,
    x_incl_attend_mode             IN     VARCHAR2,
    x_incl_yop_acad_prd            IN     VARCHAR2,
    x_incl_intrmsn_st_end          IN     VARCHAR2,
    x_incl_hnrs_lvl                IN     VARCHAR2,
    x_incl_awards                  IN     VARCHAR2,
    x_incl_award_aim               IN     VARCHAR2,
    x_incl_acad_sessions           IN     VARCHAR2,
    x_incl_st_end_acad_ses         IN     VARCHAR2,
    x_incl_hesa_num                IN     VARCHAR2,
    x_incl_location                IN     VARCHAR2,
    x_incl_program_type            IN     VARCHAR2,
    x_incl_program_name            IN     VARCHAR2,
    x_incl_prog_atmpt_stat         IN     VARCHAR2,
    x_incl_prog_atmpt_end          IN     VARCHAR2,
    x_incl_prog_atmpt_strt         IN     VARCHAR2,
    x_incl_req_cmplete             IN     VARCHAR2,
    x_incl_expected_compl_dt       IN     VARCHAR2,
    x_incl_conferral_dt            IN     VARCHAR2,
    x_incl_thesis_title            IN     VARCHAR2,
    x_incl_program_code            IN     VARCHAR2,
    x_incl_program_ver             IN     VARCHAR2,
    x_incl_stud_no                 IN     VARCHAR2,
    x_incl_surname                 IN     VARCHAR2,
    x_incl_fore_name               IN     VARCHAR2,
    x_incl_prev_names              IN     VARCHAR2,
    x_incl_initials                IN     VARCHAR2,
    x_doc_purpose_code             IN     VARCHAR2,
    x_plan_id                      IN     NUMBER,
    x_produced_by                  IN     NUMBER,
    x_person_id                    IN     NUMBER
  ) AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Handles the LOCK mechanism for the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR c1 IS
      SELECT     order_number,
                 document_type,
                 document_sub_type,
                 item_status,
                 date_produced,
                 incl_curr_course,
                 num_of_copies,
                 comments,
                 recip_pers_name,
                 recip_inst_name,
                 recip_addr_line_1,
                 recip_addr_line_2,
                 recip_addr_line_3,
                 recip_addr_line_4,
                 recip_city,
                 recip_postal_code,
                 recip_state,
                 recip_province,
                 recip_county,
                 recip_country,
                 recip_fax_area_code,
                 recip_fax_country_code,
                 recip_fax_number,
                 delivery_method_type,
                 programs_on_file,
                 missing_acad_record_data_ind,
                 missing_academic_record_data,
                 send_transcript_immediately,
                 hold_release_of_final_grades,
                 fgrade_cal_type,
                 fgrade_seq_num,
                 hold_degree_expected,
                 deghold_cal_type,
                 deghold_seq_num,
                 hold_for_grade_chg,
                 special_instr,
                 express_mail_type,
                 express_mail_track_num,
                 ge_certification,
                 external_comments,
                 internal_comments,
                 dup_requested,
                 dup_req_date,
                 dup_sent_date,
                 enr_term_cal_type,
                 enr_ci_sequence_number,
                 incl_attempted_hours,
                 incl_class_rank,
                 incl_progresssion_status,
                 incl_class_standing,
                 incl_cum_hours_earned,
                 incl_gpa,
                 incl_date_of_graduation,
                 incl_degree_dates,
                 incl_degree_earned,
                 incl_date_of_entry,
                 incl_drop_withdrawal_dates,
                 incl_hrs_earned_for_curr_term,
                 incl_majors,
                 incl_last_date_of_enrollment,
                 incl_professional_licensure,
                 incl_college_affiliation,
                 incl_instruction_dates,
                 incl_usec_dates,
                 incl_program_attempt,
                 incl_attendence_type,
                 incl_last_term_enrolled,
                 incl_ssn,
                 incl_date_of_birth,
                 incl_disciplin_standing,
                 incl_no_future_term,
                 incl_acurat_till_copmp_dt,
                 incl_cant_rel_without_sign,
                 doc_fee_per_copy,
                 delivery_fee,
                 recip_email,
                 overridden_doc_delivery_fee,
                 overridden_document_fee,
                 fee_overridden_by,
                 fee_overridden_date,
                 incl_department,
                 incl_field_of_stdy,
                 incl_attend_mode,
                 incl_yop_acad_prd,
                 incl_intrmsn_st_end,
                 incl_hnrs_lvl,
                 incl_awards,
                 incl_award_aim,
                 incl_acad_sessions,
                 incl_st_end_acad_ses,
                 incl_hesa_num,
                 incl_location,
                 incl_program_type,
                 incl_program_name,
                 incl_prog_atmpt_stat,
                 incl_prog_atmpt_end,
                 incl_prog_atmpt_strt,
                 incl_req_cmplete,
                 incl_expected_compl_dt,
                 incl_conferral_dt,
                 incl_thesis_title,
                 incl_program_code,
                 incl_program_ver,
                 incl_stud_no,
                 incl_surname,
                 incl_fore_name,
                 incl_prev_names,
                 incl_initials,
                 doc_purpose_code,
                 plan_id,
                 produced_by,
                 person_id
      FROM       igs_as_doc_details
      WHERE      ROWID = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;
  BEGIN
    fnd_msg_pub.initialize;
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      CLOSE c1;
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
      RETURN;
    END IF;
    CLOSE c1;
    IF ((tlinfo.order_number = x_order_number)
        AND (tlinfo.document_type = x_document_type)
        AND (tlinfo.document_sub_type = x_document_sub_type)
        AND ((tlinfo.item_status = x_item_status)
             OR ((tlinfo.item_status IS NULL)
                 AND (x_item_status IS NULL)
                )
            )
        AND ((tlinfo.date_produced = x_date_produced)
             OR ((tlinfo.date_produced IS NULL)
                 AND (x_date_produced IS NULL)
                )
            )
        AND (tlinfo.incl_curr_course = x_incl_curr_course
             OR ((tlinfo.incl_curr_course IS NULL)
                 AND (x_incl_curr_course IS NULL)
                )
            )
        AND (tlinfo.num_of_copies = x_num_of_copies)
        AND ((tlinfo.comments = x_comments)
             OR ((tlinfo.comments IS NULL)
                 AND (x_comments IS NULL)
                )
            )
        AND ((tlinfo.recip_pers_name = x_recip_pers_name)
             OR ((tlinfo.recip_pers_name IS NULL)
                 AND (x_recip_pers_name IS NULL)
                )
            )
        AND ((tlinfo.recip_inst_name = x_recip_inst_name)
             OR ((tlinfo.recip_inst_name IS NULL)
                 AND (x_recip_inst_name IS NULL)
                )
            )
        AND (tlinfo.recip_addr_line_1 = x_recip_addr_line_1)
        AND ((tlinfo.recip_addr_line_2 = x_recip_addr_line_2)
             OR ((tlinfo.recip_addr_line_2 IS NULL)
                 AND (x_recip_addr_line_2 IS NULL)
                )
            )
        AND ((tlinfo.recip_addr_line_3 = x_recip_addr_line_3)
             OR ((tlinfo.recip_addr_line_3 IS NULL)
                 AND (x_recip_addr_line_3 IS NULL)
                )
            )
        AND ((tlinfo.recip_addr_line_4 = x_recip_addr_line_4)
             OR ((tlinfo.recip_addr_line_4 IS NULL)
                 AND (x_recip_addr_line_4 IS NULL)
                )
            )
        AND ((tlinfo.recip_city = x_recip_city)
             OR ((tlinfo.recip_city IS NULL)
                 AND (x_recip_city IS NULL)
                )
            )
        AND ((tlinfo.recip_postal_code = x_recip_postal_code)
             OR ((tlinfo.recip_postal_code IS NULL)
                 AND (x_recip_postal_code IS NULL)
                )
            )
        AND ((tlinfo.recip_state = x_recip_state)
             OR ((tlinfo.recip_state IS NULL)
                 AND (x_recip_state IS NULL)
                )
            )
        AND ((tlinfo.recip_province = x_recip_province)
             OR ((tlinfo.recip_province IS NULL)
                 AND (x_recip_province IS NULL)
                )
            )
        AND ((tlinfo.recip_county = x_recip_county)
             OR ((tlinfo.recip_county IS NULL)
                 AND (x_recip_county IS NULL)
                )
            )
        AND (tlinfo.recip_country = x_recip_country)
        AND ((tlinfo.recip_fax_area_code = x_recip_fax_area_code)
             OR ((tlinfo.recip_fax_area_code IS NULL)
                 AND (x_recip_fax_area_code IS NULL)
                )
            )
        AND ((tlinfo.recip_fax_country_code = x_recip_fax_country_code)
             OR ((tlinfo.recip_fax_country_code IS NULL)
                 AND (x_recip_fax_country_code IS NULL)
                )
            )
        AND ((tlinfo.recip_fax_number = x_recip_fax_number)
             OR ((tlinfo.recip_fax_number IS NULL)
                 AND (x_recip_fax_number IS NULL)
                )
            )
        AND (tlinfo.delivery_method_type = x_delivery_method_type)
        AND ((tlinfo.programs_on_file = x_programs_on_file)
             OR ((tlinfo.programs_on_file IS NULL)
                 AND (x_programs_on_file IS NULL)
                )
            )
        AND ((tlinfo.missing_acad_record_data_ind = x_missing_acad_record_data_ind)
             OR ((tlinfo.missing_acad_record_data_ind IS NULL)
                 AND (x_missing_acad_record_data_ind IS NULL)
                )
            )
        AND ((tlinfo.missing_academic_record_data = x_missing_academic_record_data)
             OR ((tlinfo.missing_academic_record_data IS NULL)
                 AND (x_missing_academic_record_data IS NULL)
                )
            )
        AND ((tlinfo.send_transcript_immediately = x_send_transcript_immediately)
             OR ((tlinfo.send_transcript_immediately IS NULL)
                 AND (x_send_transcript_immediately IS NULL)
                )
            )
        AND ((tlinfo.hold_release_of_final_grades = x_hold_release_of_final_grades)
             OR ((tlinfo.hold_release_of_final_grades IS NULL)
                 AND (x_hold_release_of_final_grades IS NULL)
                )
            )
        AND ((tlinfo.fgrade_cal_type = x_fgrade_cal_type)
             OR ((tlinfo.fgrade_cal_type IS NULL)
                 AND (x_fgrade_cal_type IS NULL)
                )
            )
        AND ((tlinfo.fgrade_seq_num = x_fgrade_seq_num)
             OR ((tlinfo.fgrade_seq_num IS NULL)
                 AND (x_fgrade_seq_num IS NULL)
                )
            )
        AND ((tlinfo.hold_degree_expected = x_hold_degree_expected)
             OR ((tlinfo.hold_degree_expected IS NULL)
                 AND (x_hold_degree_expected IS NULL)
                )
            )
        AND ((tlinfo.deghold_cal_type = x_deghold_cal_type)
             OR ((tlinfo.deghold_cal_type IS NULL)
                 AND (x_deghold_cal_type IS NULL)
                )
            )
        AND ((tlinfo.deghold_seq_num = x_deghold_seq_num)
             OR ((tlinfo.deghold_seq_num IS NULL)
                 AND (x_deghold_seq_num IS NULL)
                )
            )
        AND ((tlinfo.hold_for_grade_chg = x_hold_for_grade_chg)
             OR ((tlinfo.hold_for_grade_chg IS NULL)
                 AND (x_hold_for_grade_chg IS NULL)
                )
            )
        AND ((tlinfo.special_instr = x_special_instr)
             OR ((tlinfo.special_instr IS NULL)
                 AND (x_special_instr IS NULL)
                )
            )
        AND ((tlinfo.express_mail_type = x_express_mail_type)
             OR ((tlinfo.express_mail_type IS NULL)
                 AND (x_express_mail_type IS NULL)
                )
            )
        AND ((tlinfo.express_mail_track_num = x_express_mail_track_num)
             OR ((tlinfo.express_mail_track_num IS NULL)
                 AND (x_express_mail_track_num IS NULL)
                )
            )
        AND ((tlinfo.ge_certification = x_ge_certification)
             OR ((tlinfo.ge_certification IS NULL)
                 AND (x_ge_certification IS NULL)
                )
            )
        AND ((tlinfo.external_comments = x_external_comments)
             OR ((tlinfo.external_comments IS NULL)
                 AND (x_external_comments IS NULL)
                )
            )
        AND ((tlinfo.internal_comments = x_internal_comments)
             OR ((tlinfo.internal_comments IS NULL)
                 AND (x_internal_comments IS NULL)
                )
            )
        AND ((tlinfo.dup_requested = x_dup_requested)
             OR ((tlinfo.dup_requested IS NULL)
                 AND (x_dup_requested IS NULL)
                )
            )
        AND ((tlinfo.dup_req_date = x_dup_req_date)
             OR ((tlinfo.dup_req_date IS NULL)
                 AND (x_dup_req_date IS NULL)
                )
            )
        AND ((tlinfo.dup_sent_date = x_dup_sent_date)
             OR ((tlinfo.dup_sent_date IS NULL)
                 AND (x_dup_sent_date IS NULL)
                )
            )
        AND ((tlinfo.enr_term_cal_type = x_enr_term_cal_type)
             OR ((tlinfo.enr_term_cal_type IS NULL)
                 AND (x_enr_term_cal_type IS NULL)
                )
            )
        AND ((tlinfo.enr_ci_sequence_number = x_enr_ci_sequence_number)
             OR ((tlinfo.enr_ci_sequence_number IS NULL)
                 AND (x_enr_ci_sequence_number IS NULL)
                )
            )
        AND ((tlinfo.incl_attempted_hours = x_incl_attempted_hours)
             OR ((tlinfo.incl_attempted_hours IS NULL)
                 AND (x_incl_attempted_hours IS NULL)
                )
            )
        AND ((tlinfo.incl_class_rank = x_incl_class_rank)
             OR ((tlinfo.incl_class_rank IS NULL)
                 AND (x_incl_class_rank IS NULL)
                )
            )
        AND ((tlinfo.incl_progresssion_status = x_incl_progresssion_status)
             OR ((tlinfo.incl_progresssion_status IS NULL)
                 AND (x_incl_progresssion_status IS NULL)
                )
            )
        AND ((tlinfo.incl_class_standing = x_incl_class_standing)
             OR ((tlinfo.incl_class_standing IS NULL)
                 AND (x_incl_class_standing IS NULL)
                )
            )
        AND ((tlinfo.incl_cum_hours_earned = x_incl_cum_hours_earned)
             OR ((tlinfo.incl_cum_hours_earned IS NULL)
                 AND (x_incl_cum_hours_earned IS NULL)
                )
            )
        AND ((tlinfo.incl_gpa = x_incl_gpa)
             OR ((tlinfo.incl_gpa IS NULL)
                 AND (x_incl_gpa IS NULL)
                )
            )
        AND ((tlinfo.incl_date_of_graduation = x_incl_date_of_graduation)
             OR ((tlinfo.incl_date_of_graduation IS NULL)
                 AND (x_incl_date_of_graduation IS NULL)
                )
            )
        AND ((tlinfo.incl_degree_dates = x_incl_degree_dates)
             OR ((tlinfo.incl_degree_dates IS NULL)
                 AND (x_incl_degree_dates IS NULL)
                )
            )
        AND ((tlinfo.incl_degree_earned = x_incl_degree_earned)
             OR ((tlinfo.incl_degree_earned IS NULL)
                 AND (x_incl_degree_earned IS NULL)
                )
            )
        AND ((tlinfo.incl_date_of_entry = x_incl_date_of_entry)
             OR ((tlinfo.incl_date_of_entry IS NULL)
                 AND (x_incl_date_of_entry IS NULL)
                )
            )
        AND ((tlinfo.incl_drop_withdrawal_dates = x_incl_drop_withdrawal_dates)
             OR ((tlinfo.incl_drop_withdrawal_dates IS NULL)
                 AND (x_incl_drop_withdrawal_dates IS NULL)
                )
            )
        AND ((tlinfo.incl_hrs_earned_for_curr_term = x_incl_hrs_for_curr_term)
             OR ((tlinfo.incl_hrs_earned_for_curr_term IS NULL)
                 AND (x_incl_hrs_for_curr_term IS NULL)
                )
            )
        AND ((tlinfo.incl_majors = x_incl_majors)
             OR ((tlinfo.incl_majors IS NULL)
                 AND (x_incl_majors IS NULL)
                )
            )
        AND ((tlinfo.incl_last_date_of_enrollment = x_incl_last_date_of_enrollment)
             OR ((tlinfo.incl_last_date_of_enrollment IS NULL)
                 AND (x_incl_last_date_of_enrollment IS NULL)
                )
            )
        AND ((tlinfo.incl_professional_licensure = x_incl_professional_licensure)
             OR ((tlinfo.incl_professional_licensure IS NULL)
                 AND (x_incl_professional_licensure IS NULL)
                )
            )
        AND ((tlinfo.incl_college_affiliation = x_incl_college_affiliation)
             OR ((tlinfo.incl_college_affiliation IS NULL)
                 AND (x_incl_college_affiliation IS NULL)
                )
            )
        AND ((tlinfo.incl_instruction_dates = x_incl_instruction_dates)
             OR ((tlinfo.incl_instruction_dates IS NULL)
                 AND (x_incl_instruction_dates IS NULL)
                )
            )
        AND ((tlinfo.incl_usec_dates = x_incl_usec_dates)
             OR ((tlinfo.incl_usec_dates IS NULL)
                 AND (x_incl_usec_dates IS NULL)
                )
            )
        AND ((tlinfo.incl_program_attempt = x_incl_program_attempt)
             OR ((tlinfo.incl_program_attempt IS NULL)
                 AND (x_incl_program_attempt IS NULL)
                )
            )
        AND ((tlinfo.incl_attendence_type = x_incl_attendence_type)
             OR ((tlinfo.incl_attendence_type IS NULL)
                 AND (x_incl_attendence_type IS NULL)
                )
            )
        AND ((tlinfo.incl_last_term_enrolled = x_incl_last_term_enrolled)
             OR ((tlinfo.incl_last_term_enrolled IS NULL)
                 AND (x_incl_last_term_enrolled IS NULL)
                )
            )
        AND ((tlinfo.incl_ssn = x_incl_ssn)
             OR ((tlinfo.incl_ssn IS NULL)
                 AND (x_incl_ssn IS NULL)
                )
            )
        AND ((tlinfo.incl_date_of_birth = x_incl_date_of_birth)
             OR ((tlinfo.incl_date_of_birth IS NULL)
                 AND (x_incl_date_of_birth IS NULL)
                )
            )
        AND ((tlinfo.incl_disciplin_standing = x_incl_disciplin_standing)
             OR ((tlinfo.incl_disciplin_standing IS NULL)
                 AND (x_incl_disciplin_standing IS NULL)
                )
            )
        AND ((tlinfo.incl_no_future_term = x_incl_no_future_term)
             OR ((tlinfo.incl_no_future_term IS NULL)
                 AND (x_incl_no_future_term IS NULL)
                )
            )
        AND ((tlinfo.incl_acurat_till_copmp_dt = x_incl_acurat_till_copmp_dt)
             OR ((tlinfo.incl_acurat_till_copmp_dt IS NULL)
                 AND (x_incl_acurat_till_copmp_dt IS NULL)
                )
            )
        AND ((tlinfo.incl_cant_rel_without_sign = x_incl_cant_rel_without_sign)
             OR ((tlinfo.incl_cant_rel_without_sign IS NULL)
                 AND (x_incl_cant_rel_without_sign IS NULL)
                )
            )
        AND ((tlinfo.doc_fee_per_copy = x_doc_fee_per_copy)
             OR ((tlinfo.doc_fee_per_copy IS NULL)
                 AND (x_doc_fee_per_copy IS NULL)
                )
            )
        AND ((tlinfo.delivery_fee = x_delivery_fee)
             OR ((tlinfo.delivery_fee IS NULL)
                 AND (x_delivery_fee IS NULL)
                )
            )
        AND ((tlinfo.recip_email = x_recip_email)
             OR ((tlinfo.recip_email IS NULL)
                 AND (x_recip_email IS NULL)
                )
            )
        AND ((tlinfo.overridden_doc_delivery_fee = x_overridden_doc_delivery_fee)
             OR ((tlinfo.overridden_doc_delivery_fee IS NULL)
                 AND (x_overridden_doc_delivery_fee IS NULL)
                )
            )
        AND ((tlinfo.overridden_document_fee = x_overridden_document_fee)
             OR ((tlinfo.overridden_document_fee IS NULL)
                 AND (x_overridden_document_fee IS NULL)
                )
            )
        AND ((tlinfo.fee_overridden_by = x_fee_overridden_by)
             OR ((tlinfo.fee_overridden_by IS NULL)
                 AND (x_fee_overridden_by IS NULL)
                )
            )
        AND ((tlinfo.fee_overridden_date = x_fee_overridden_date)
             OR ((tlinfo.fee_overridden_date IS NULL)
                 AND (x_fee_overridden_date IS NULL)
                )
            )
        AND ((tlinfo.incl_department = x_incl_department)
             OR ((tlinfo.incl_department IS NULL)
                 AND (x_incl_department IS NULL)
                )
            )
        AND ((tlinfo.incl_field_of_stdy = x_incl_field_of_stdy)
             OR ((tlinfo.incl_field_of_stdy IS NULL)
                 AND (x_incl_field_of_stdy IS NULL)
                )
            )
        AND ((tlinfo.incl_attend_mode = x_incl_attend_mode)
             OR ((tlinfo.incl_attend_mode IS NULL)
                 AND (x_incl_attend_mode IS NULL)
                )
            )
        AND ((tlinfo.incl_yop_acad_prd = x_incl_yop_acad_prd)
             OR ((tlinfo.incl_yop_acad_prd IS NULL)
                 AND (x_incl_yop_acad_prd IS NULL)
                )
            )
        AND ((tlinfo.incl_intrmsn_st_end = x_incl_intrmsn_st_end)
             OR ((tlinfo.incl_intrmsn_st_end IS NULL)
                 AND (x_incl_intrmsn_st_end IS NULL)
                )
            )
        AND ((tlinfo.incl_hnrs_lvl = x_incl_hnrs_lvl)
             OR ((tlinfo.incl_hnrs_lvl IS NULL)
                 AND (x_incl_hnrs_lvl IS NULL)
                )
            )
        AND ((tlinfo.incl_awards = x_incl_awards)
             OR ((tlinfo.incl_awards IS NULL)
                 AND (x_incl_awards IS NULL)
                )
            )
        AND ((tlinfo.incl_award_aim = x_incl_award_aim)
             OR ((tlinfo.incl_award_aim IS NULL)
                 AND (x_incl_award_aim IS NULL)
                )
            )
        AND ((tlinfo.incl_acad_sessions = x_incl_acad_sessions)
             OR ((tlinfo.incl_acad_sessions IS NULL)
                 AND (x_incl_acad_sessions IS NULL)
                )
            )
        AND ((tlinfo.incl_st_end_acad_ses = x_incl_st_end_acad_ses)
             OR ((tlinfo.incl_st_end_acad_ses IS NULL)
                 AND (x_incl_st_end_acad_ses IS NULL)
                )
            )
        AND ((tlinfo.incl_hesa_num = x_incl_hesa_num)
             OR ((tlinfo.incl_hesa_num IS NULL)
                 AND (x_incl_hesa_num IS NULL)
                )
            )
        AND ((tlinfo.incl_location = x_incl_location)
             OR ((tlinfo.incl_location IS NULL)
                 AND (x_incl_location IS NULL)
                )
            )
        AND ((tlinfo.incl_program_type = x_incl_program_type)
             OR ((tlinfo.incl_program_type IS NULL)
                 AND (x_incl_program_type IS NULL)
                )
            )
        AND ((tlinfo.incl_program_name = x_incl_program_name)
             OR ((tlinfo.incl_program_name IS NULL)
                 AND (x_incl_program_name IS NULL)
                )
            )
        AND ((tlinfo.incl_prog_atmpt_stat = x_incl_prog_atmpt_stat)
             OR ((tlinfo.incl_prog_atmpt_stat IS NULL)
                 AND (x_incl_prog_atmpt_stat IS NULL)
                )
            )
        AND ((tlinfo.incl_prog_atmpt_end = x_incl_prog_atmpt_end)
             OR ((tlinfo.incl_prog_atmpt_end IS NULL)
                 AND (x_incl_prog_atmpt_end IS NULL)
                )
            )
        AND ((tlinfo.incl_prog_atmpt_strt = x_incl_prog_atmpt_strt)
             OR ((tlinfo.incl_prog_atmpt_strt IS NULL)
                 AND (x_incl_prog_atmpt_strt IS NULL)
                )
            )
        AND ((tlinfo.incl_req_cmplete = x_incl_req_cmplete)
             OR ((tlinfo.incl_req_cmplete IS NULL)
                 AND (x_incl_req_cmplete IS NULL)
                )
            )
        AND ((tlinfo.incl_expected_compl_dt = x_incl_expected_compl_dt)
             OR ((tlinfo.incl_expected_compl_dt IS NULL)
                 AND (x_incl_expected_compl_dt IS NULL)
                )
            )
        AND ((tlinfo.incl_conferral_dt = x_incl_conferral_dt)
             OR ((tlinfo.incl_conferral_dt IS NULL)
                 AND (x_incl_conferral_dt IS NULL)
                )
            )
        AND ((tlinfo.incl_thesis_title = x_incl_thesis_title)
             OR ((tlinfo.incl_thesis_title IS NULL)
                 AND (x_incl_thesis_title IS NULL)
                )
            )
        AND ((tlinfo.incl_program_code = x_incl_program_code)
             OR ((tlinfo.incl_program_code IS NULL)
                 AND (x_incl_program_code IS NULL)
                )
            )
        AND ((tlinfo.incl_program_ver = x_incl_program_ver)
             OR ((tlinfo.incl_program_ver IS NULL)
                 AND (x_incl_program_ver IS NULL)
                )
            )
        AND ((tlinfo.incl_stud_no = x_incl_stud_no)
             OR ((tlinfo.incl_stud_no IS NULL)
                 AND (x_incl_stud_no IS NULL)
                )
            )
        AND ((tlinfo.incl_surname = x_incl_surname)
             OR ((tlinfo.incl_surname IS NULL)
                 AND (x_incl_surname IS NULL)
                )
            )
        AND ((tlinfo.incl_fore_name = x_incl_fore_name)
             OR ((tlinfo.incl_fore_name IS NULL)
                 AND (x_incl_fore_name IS NULL)
                )
            )
        AND ((tlinfo.incl_prev_names = x_incl_prev_names)
             OR ((tlinfo.incl_prev_names IS NULL)
                 AND (x_incl_prev_names IS NULL)
                )
            )
        AND ((tlinfo.incl_initials = x_incl_initials)
             OR ((tlinfo.incl_initials IS NULL)
                 AND (x_incl_initials IS NULL)
                )
            )
        AND ((tlinfo.doc_purpose_code = x_doc_purpose_code)
             OR ((tlinfo.doc_purpose_code IS NULL)
                 AND (x_doc_purpose_code IS NULL)
                )
            )
        AND ((tlinfo.plan_id = x_plan_id)
             OR ((tlinfo.plan_id IS NULL)
                 AND (x_plan_id IS NULL)
                )
            )
        AND ((tlinfo.produced_by = x_produced_by)
             OR ((tlinfo.produced_by IS NULL)
                 AND (x_produced_by IS NULL)
                )
            )
        AND ((tlinfo.person_id = x_person_id)
             OR ((tlinfo.person_id IS NULL)
                 AND (x_person_id IS NULL)
                )
            )
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name ('FND', '*' || x_rowid || '*');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'Insert_Row : ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
  END lock_row;
  --
  --
  --
  PROCEDURE update_row (
    x_rowid                        IN     VARCHAR2,
    x_order_number                 IN     NUMBER,
    x_document_type                IN     VARCHAR2,
    x_document_sub_type            IN     VARCHAR2,
    x_item_number                  IN     NUMBER,
    x_item_status                  IN     VARCHAR2,
    x_date_produced                IN     DATE,
    x_incl_curr_course             IN     VARCHAR2,
    x_num_of_copies                IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_recip_pers_name              IN     VARCHAR2,
    x_recip_inst_name              IN     VARCHAR2,
    x_recip_addr_line_1            IN     VARCHAR2,
    x_recip_addr_line_2            IN     VARCHAR2,
    x_recip_addr_line_3            IN     VARCHAR2,
    x_recip_addr_line_4            IN     VARCHAR2,
    x_recip_city                   IN     VARCHAR2,
    x_recip_postal_code            IN     VARCHAR2,
    x_recip_state                  IN     VARCHAR2,
    x_recip_province               IN     VARCHAR2,
    x_recip_county                 IN     VARCHAR2,
    x_recip_country                IN     VARCHAR2,
    x_recip_fax_area_code          IN     VARCHAR2,
    x_recip_fax_country_code       IN     VARCHAR2,
    x_recip_fax_number             IN     VARCHAR2,
    x_delivery_method_type         IN     VARCHAR2,
    x_programs_on_file             IN     VARCHAR2,
    x_missing_acad_record_data_ind IN     VARCHAR2,
    x_missing_academic_record_data IN     VARCHAR2,
    x_send_transcript_immediately  IN     VARCHAR2,
    x_hold_release_of_final_grades IN     VARCHAR2,
    x_fgrade_cal_type              IN     VARCHAR2,
    x_fgrade_seq_num               IN     NUMBER,
    x_hold_degree_expected         IN     VARCHAR2,
    x_deghold_cal_type             IN     VARCHAR2,
    x_deghold_seq_num              IN     NUMBER,
    x_hold_for_grade_chg           IN     VARCHAR2,
    x_special_instr                IN     VARCHAR2,
    x_express_mail_type            IN     VARCHAR2,
    x_express_mail_track_num       IN     VARCHAR2,
    x_ge_certification             IN     VARCHAR2,
    x_external_comments            IN     VARCHAR2,
    x_internal_comments            IN     VARCHAR2,
    x_dup_requested                IN     VARCHAR2,
    x_dup_req_date                 IN     DATE,
    x_dup_sent_date                IN     DATE,
    x_enr_term_cal_type            IN     VARCHAR2,
    x_enr_ci_sequence_number       IN     NUMBER,
    x_incl_attempted_hours         IN     VARCHAR2,
    x_incl_class_rank              IN     VARCHAR2,
    x_incl_progresssion_status     IN     VARCHAR2,
    x_incl_class_standing          IN     VARCHAR2,
    x_incl_cum_hours_earned        IN     VARCHAR2,
    x_incl_gpa                     IN     VARCHAR2,
    x_incl_date_of_graduation      IN     VARCHAR2,
    x_incl_degree_dates            IN     VARCHAR2,
    x_incl_degree_earned           IN     VARCHAR2,
    x_incl_date_of_entry           IN     VARCHAR2,
    x_incl_drop_withdrawal_dates   IN     VARCHAR2,
    x_incl_hrs_for_curr_term       IN     VARCHAR2,
    x_incl_majors                  IN     VARCHAR2,
    x_incl_last_date_of_enrollment IN     VARCHAR2,
    x_incl_professional_licensure  IN     VARCHAR2,
    x_incl_college_affiliation     IN     VARCHAR2,
    x_incl_instruction_dates       IN     VARCHAR2,
    x_incl_usec_dates              IN     VARCHAR2,
    x_incl_program_attempt         IN     VARCHAR2,
    x_incl_attendence_type         IN     VARCHAR2,
    x_incl_last_term_enrolled      IN     VARCHAR2,
    x_incl_ssn                     IN     VARCHAR2,
    x_incl_date_of_birth           IN     VARCHAR2,
    x_incl_disciplin_standing      IN     VARCHAR2,
    x_incl_no_future_term          IN     VARCHAR2,
    x_incl_acurat_till_copmp_dt    IN     VARCHAR2,
    x_incl_cant_rel_without_sign   IN     VARCHAR2,
    x_mode                         IN     VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_doc_fee_per_copy             IN     NUMBER,
    x_delivery_fee                 IN     NUMBER,
    x_recip_email                  IN     VARCHAR2,
    x_overridden_doc_delivery_fee  IN     NUMBER,
    x_overridden_document_fee      IN     NUMBER,
    x_fee_overridden_by            IN     NUMBER,
    x_fee_overridden_date          IN     DATE,
    x_incl_department              IN     VARCHAR2,
    x_incl_field_of_stdy           IN     VARCHAR2,
    x_incl_attend_mode             IN     VARCHAR2,
    x_incl_yop_acad_prd            IN     VARCHAR2,
    x_incl_intrmsn_st_end          IN     VARCHAR2,
    x_incl_hnrs_lvl                IN     VARCHAR2,
    x_incl_awards                  IN     VARCHAR2,
    x_incl_award_aim               IN     VARCHAR2,
    x_incl_acad_sessions           IN     VARCHAR2,
    x_incl_st_end_acad_ses         IN     VARCHAR2,
    x_incl_hesa_num                IN     VARCHAR2,
    x_incl_location                IN     VARCHAR2,
    x_incl_program_type            IN     VARCHAR2,
    x_incl_program_name            IN     VARCHAR2,
    x_incl_prog_atmpt_stat         IN     VARCHAR2,
    x_incl_prog_atmpt_end          IN     VARCHAR2,
    x_incl_prog_atmpt_strt         IN     VARCHAR2,
    x_incl_req_cmplete             IN     VARCHAR2,
    x_incl_expected_compl_dt       IN     VARCHAR2,
    x_incl_conferral_dt            IN     VARCHAR2,
    x_incl_thesis_title            IN     VARCHAR2,
    x_incl_program_code            IN     VARCHAR2,
    x_incl_program_ver             IN     VARCHAR2,
    x_incl_stud_no                 IN     VARCHAR2,
    x_incl_surname                 IN     VARCHAR2,
    x_incl_fore_name               IN     VARCHAR2,
    x_incl_prev_names              IN     VARCHAR2,
    x_incl_initials                IN     VARCHAR2,
    x_doc_purpose_code             IN     VARCHAR2,
    x_plan_id                      IN     NUMBER,
    x_produced_by                  IN     NUMBER,
    x_person_id                    IN     NUMBER
  ) AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Handles the UPDATE DML logic for the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    x_last_update_date       DATE;
    x_last_updated_by        NUMBER;
    x_last_update_login      NUMBER;
    x_request_id             NUMBER;
    x_program_id             NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date    DATE;
  BEGIN
    fnd_msg_pub.initialize;
    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode IN ('R', 'C')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    before_dml (
      p_action                       => 'UPDATE',
      x_rowid                        => x_rowid,
      x_order_number                 => x_order_number,
      x_document_type                => x_document_type,
      x_document_sub_type            => x_document_sub_type,
      x_item_number                  => x_item_number,
      x_item_status                  => x_item_status,
      x_date_produced                => x_date_produced,
      x_incl_curr_course             => x_incl_curr_course,
      x_num_of_copies                => x_num_of_copies,
      x_comments                     => x_comments,
      x_recip_pers_name              => x_recip_pers_name,
      x_recip_inst_name              => x_recip_inst_name,
      x_recip_addr_line_1            => x_recip_addr_line_1,
      x_recip_addr_line_2            => x_recip_addr_line_2,
      x_recip_addr_line_3            => x_recip_addr_line_3,
      x_recip_addr_line_4            => x_recip_addr_line_4,
      x_recip_city                   => x_recip_city,
      x_recip_postal_code            => x_recip_postal_code,
      x_recip_state                  => x_recip_state,
      x_recip_province               => x_recip_province,
      x_recip_county                 => x_recip_county,
      x_recip_country                => x_recip_country,
      x_recip_fax_area_code          => x_recip_fax_area_code,
      x_recip_fax_country_code       => x_recip_fax_country_code,
      x_recip_fax_number             => x_recip_fax_number,
      x_delivery_method_type         => x_delivery_method_type,
      x_programs_on_file             => x_programs_on_file,
      x_missing_acad_record_data_ind => x_missing_acad_record_data_ind,
      x_missing_academic_record_data => x_missing_academic_record_data,
      x_send_transcript_immediately  => x_send_transcript_immediately,
      x_hold_release_of_final_grades => x_hold_release_of_final_grades,
      x_fgrade_cal_type              => x_fgrade_cal_type,
      x_fgrade_seq_num               => x_fgrade_seq_num,
      x_hold_degree_expected         => x_hold_degree_expected,
      x_deghold_cal_type             => x_deghold_cal_type,
      x_deghold_seq_num              => x_deghold_seq_num,
      x_hold_for_grade_chg           => x_hold_for_grade_chg,
      x_special_instr                => x_special_instr,
      x_express_mail_type            => x_express_mail_type,
      x_express_mail_track_num       => x_express_mail_track_num,
      x_ge_certification             => x_ge_certification,
      x_external_comments            => x_external_comments,
      x_internal_comments            => x_internal_comments,
      x_dup_requested                => x_dup_requested,
      x_dup_req_date                 => x_dup_req_date,
      x_dup_sent_date                => x_dup_sent_date,
      x_enr_term_cal_type            => x_enr_term_cal_type,
      x_enr_ci_sequence_number       => x_enr_ci_sequence_number,
      x_incl_attempted_hours         => x_incl_attempted_hours,
      x_incl_class_rank              => x_incl_class_rank,
      x_incl_progresssion_status     => x_incl_progresssion_status,
      x_incl_class_standing          => x_incl_class_standing,
      x_incl_cum_hours_earned        => x_incl_cum_hours_earned,
      x_incl_gpa                     => x_incl_gpa,
      x_incl_date_of_graduation      => x_incl_date_of_graduation,
      x_incl_degree_dates            => x_incl_degree_dates,
      x_incl_degree_earned           => x_incl_degree_earned,
      x_incl_date_of_entry           => x_incl_date_of_entry,
      x_incl_drop_withdrawal_dates   => x_incl_drop_withdrawal_dates,
      x_incl_hrs_for_curr_term       => x_incl_hrs_for_curr_term,
      x_incl_majors                  => x_incl_majors,
      x_incl_last_date_of_enrollment => x_incl_last_date_of_enrollment,
      x_incl_professional_licensure  => x_incl_professional_licensure,
      x_incl_college_affiliation     => x_incl_college_affiliation,
      x_incl_instruction_dates       => x_incl_instruction_dates,
      x_incl_usec_dates              => x_incl_usec_dates,
      x_incl_program_attempt         => x_incl_program_attempt,
      x_incl_attendence_type         => x_incl_attendence_type,
      x_incl_last_term_enrolled      => x_incl_last_term_enrolled,
      x_incl_ssn                     => x_incl_ssn,
      x_incl_date_of_birth           => x_incl_date_of_birth,
      x_incl_disciplin_standing      => x_incl_disciplin_standing,
      x_incl_no_future_term          => x_incl_no_future_term,
      x_incl_acurat_till_copmp_dt    => x_incl_acurat_till_copmp_dt,
      x_incl_cant_rel_without_sign   => x_incl_cant_rel_without_sign,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_doc_fee_per_copy             => x_doc_fee_per_copy,
      x_delivery_fee                 => x_delivery_fee,
      x_recip_email                  => x_recip_email,
      x_overridden_doc_delivery_fee  => x_overridden_doc_delivery_fee,
      x_overridden_document_fee      => x_overridden_document_fee,
      x_fee_overridden_by            => x_fee_overridden_by,
      x_fee_overridden_date          => x_fee_overridden_date,
      x_incl_department              => x_incl_department,
      x_incl_field_of_stdy           => x_incl_field_of_stdy,
      x_incl_attend_mode             => x_incl_attend_mode,
      x_incl_yop_acad_prd            => x_incl_yop_acad_prd,
      x_incl_intrmsn_st_end          => x_incl_intrmsn_st_end,
      x_incl_hnrs_lvl                => x_incl_hnrs_lvl,
      x_incl_awards                  => x_incl_awards,
      x_incl_award_aim               => x_incl_award_aim,
      x_incl_acad_sessions           => x_incl_acad_sessions,
      x_incl_st_end_acad_ses         => x_incl_st_end_acad_ses,
      x_incl_hesa_num                => x_incl_hesa_num,
      x_incl_location                => x_incl_location,
      x_incl_program_type            => x_incl_program_type,
      x_incl_program_name            => x_incl_program_name,
      x_incl_prog_atmpt_stat         => x_incl_prog_atmpt_stat,
      x_incl_prog_atmpt_end          => x_incl_prog_atmpt_end,
      x_incl_prog_atmpt_strt         => x_incl_prog_atmpt_strt,
      x_incl_req_cmplete             => x_incl_req_cmplete,
      x_incl_expected_compl_dt       => x_incl_expected_compl_dt,
      x_incl_conferral_dt            => x_incl_conferral_dt,
      x_incl_thesis_title            => x_incl_thesis_title,
      x_incl_program_code            => x_incl_program_code,
      x_incl_program_ver             => x_incl_program_ver,
      x_incl_stud_no                 => x_incl_stud_no,
      x_incl_surname                 => x_incl_surname,
      x_incl_fore_name               => x_incl_fore_name,
      x_incl_prev_names              => x_incl_prev_names,
      x_incl_initials                => x_incl_initials,
      x_doc_purpose_code             => x_doc_purpose_code,
      x_plan_id                      => x_plan_id,
      x_produced_by                  => x_produced_by,
      x_person_id                    => x_person_id
    );
    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id = -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;
    UPDATE igs_as_doc_details
       SET order_number = new_references.order_number,
           document_type = new_references.document_type,
           document_sub_type = new_references.document_sub_type,
           item_status = new_references.item_status,
           date_produced = new_references.date_produced,
           incl_curr_course = new_references.incl_curr_course,
           num_of_copies = new_references.num_of_copies,
           comments = new_references.comments,
           recip_pers_name = new_references.recip_pers_name,
           recip_inst_name = new_references.recip_inst_name,
           recip_addr_line_1 = new_references.recip_addr_line_1,
           recip_addr_line_2 = new_references.recip_addr_line_2,
           recip_addr_line_3 = new_references.recip_addr_line_3,
           recip_addr_line_4 = new_references.recip_addr_line_4,
           recip_city = new_references.recip_city,
           recip_postal_code = new_references.recip_postal_code,
           recip_state = new_references.recip_state,
           recip_province = new_references.recip_province,
           recip_county = new_references.recip_county,
           recip_country = new_references.recip_country,
           recip_fax_area_code = new_references.recip_fax_area_code,
           recip_fax_country_code = new_references.recip_fax_country_code,
           recip_fax_number = new_references.recip_fax_number,
           delivery_method_type = new_references.delivery_method_type,
           programs_on_file = new_references.programs_on_file,
           missing_acad_record_data_ind = new_references.missing_acad_record_data_ind,
           missing_academic_record_data = new_references.missing_academic_record_data,
           send_transcript_immediately = new_references.send_transcript_immediately,
           hold_release_of_final_grades = new_references.hold_release_of_final_grades,
           fgrade_cal_type = new_references.fgrade_cal_type,
           fgrade_seq_num = new_references.fgrade_seq_num,
           hold_degree_expected = new_references.hold_degree_expected,
           deghold_cal_type = new_references.deghold_cal_type,
           deghold_seq_num = new_references.deghold_seq_num,
           hold_for_grade_chg = new_references.hold_for_grade_chg,
           special_instr = new_references.special_instr,
           express_mail_type = new_references.express_mail_type,
           express_mail_track_num = new_references.express_mail_track_num,
           ge_certification = new_references.ge_certification,
           external_comments = new_references.external_comments,
           internal_comments = new_references.internal_comments,
           dup_requested = new_references.dup_requested,
           dup_req_date = new_references.dup_req_date,
           dup_sent_date = new_references.dup_sent_date,
           enr_term_cal_type = new_references.enr_term_cal_type,
           enr_ci_sequence_number = new_references.enr_ci_sequence_number,
           incl_attempted_hours = new_references.incl_attempted_hours,
           incl_class_rank = new_references.incl_class_rank,
           incl_progresssion_status = new_references.incl_progresssion_status,
           incl_class_standing = new_references.incl_class_standing,
           incl_cum_hours_earned = new_references.incl_cum_hours_earned,
           incl_gpa = new_references.incl_gpa,
           incl_date_of_graduation = new_references.incl_date_of_graduation,
           incl_degree_dates = new_references.incl_degree_dates,
           incl_degree_earned = new_references.incl_degree_earned,
           incl_date_of_entry = new_references.incl_date_of_entry,
           incl_drop_withdrawal_dates = new_references.incl_drop_withdrawal_dates,
           incl_hrs_earned_for_curr_term = new_references.incl_hrs_earned_for_curr_term,
           incl_majors = new_references.incl_majors,
           incl_last_date_of_enrollment = new_references.incl_last_date_of_enrollment,
           incl_professional_licensure = new_references.incl_professional_licensure,
           incl_college_affiliation = new_references.incl_college_affiliation,
           incl_instruction_dates = new_references.incl_instruction_dates,
           incl_usec_dates = new_references.incl_usec_dates,
           incl_program_attempt = new_references.incl_program_attempt,
           incl_attendence_type = new_references.incl_attendence_type,
           incl_last_term_enrolled = new_references.incl_last_term_enrolled,
           incl_ssn = new_references.incl_ssn,
           incl_date_of_birth = new_references.incl_date_of_birth,
           incl_disciplin_standing = new_references.incl_disciplin_standing,
           incl_no_future_term = new_references.incl_no_future_term,
           incl_acurat_till_copmp_dt = new_references.incl_acurat_till_copmp_dt,
           incl_cant_rel_without_sign = new_references.incl_cant_rel_without_sign,
           last_update_date = x_last_update_date,
           last_updated_by = x_last_updated_by,
           last_update_login = x_last_update_login,
           request_id = x_request_id,
           program_id = x_program_id,
           program_application_id = x_program_application_id,
           program_update_date = x_program_update_date,
           doc_fee_per_copy = new_references.doc_fee_per_copy,
           delivery_fee = new_references.delivery_fee,
           recip_email = new_references.recip_email,
           overridden_doc_delivery_fee = new_references.overridden_doc_delivery_fee,
           overridden_document_fee = new_references.overridden_document_fee,
           fee_overridden_by = new_references.fee_overridden_by,
           fee_overridden_date = new_references.fee_overridden_date,
           incl_department = new_references.incl_department,
           incl_field_of_stdy = new_references.incl_field_of_stdy,
           incl_attend_mode = new_references.incl_attend_mode,
           incl_yop_acad_prd = new_references.incl_yop_acad_prd,
           incl_intrmsn_st_end = new_references.incl_intrmsn_st_end,
           incl_hnrs_lvl = new_references.incl_hnrs_lvl,
           incl_awards = new_references.incl_awards,
           incl_award_aim = new_references.incl_award_aim,
           incl_acad_sessions = new_references.incl_acad_sessions,
           incl_st_end_acad_ses = new_references.incl_st_end_acad_ses,
           incl_hesa_num = new_references.incl_hesa_num,
           incl_location = new_references.incl_location,
           incl_program_type = new_references.incl_program_type,
           incl_program_name = new_references.incl_program_name,
           incl_prog_atmpt_stat = new_references.incl_prog_atmpt_stat,
           incl_prog_atmpt_end = new_references.incl_prog_atmpt_end,
           incl_prog_atmpt_strt = new_references.incl_prog_atmpt_strt,
           incl_req_cmplete = new_references.incl_req_cmplete,
           incl_expected_compl_dt = new_references.incl_expected_compl_dt,
           incl_conferral_dt = new_references.incl_conferral_dt,
           incl_thesis_title = new_references.incl_thesis_title,
           incl_program_code = new_references.incl_program_code,
           incl_program_ver = new_references.incl_program_ver,
           incl_stud_no = new_references.incl_stud_no,
           incl_surname = new_references.incl_surname,
           incl_fore_name = new_references.incl_fore_name,
           incl_prev_names = new_references.incl_prev_names,
           incl_initials = new_references.incl_initials,
           doc_purpose_code = new_references.doc_purpose_code,
           plan_id = new_references.plan_id,
           produced_by = new_references.produced_by,
           person_id = new_references.person_id
     WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    IF (x_mode = 'R') THEN
      update_fees_of_remaining_items (
        x_person_id                    => old_references.person_id,
        x_document_type                => old_references.document_type,
        x_document_sub_type            => old_references.document_sub_type
      );
    END IF;
    --
    -- Send a notification to the student informing about the document production
    -- when the produced_by and date_produced are entered by the user.
    --
    IF ((new_references.missing_acad_record_data_ind = 'Y')
        AND (old_references.produced_by <> new_references.produced_by)
        AND (old_references.date_produced <> new_references.date_produced)
       ) THEN
      DECLARE
        CURSOR cur_document_type (cp_document_type IN VARCHAR2) IS
          SELECT lkup.meaning
          FROM   igs_lookups_view lkup
          WHERE  lkup.lookup_type = 'IGS_AS_DOCUMENT_TYPE'
          AND    lkup.lookup_code = cp_document_type;
        CURSOR cur_document_sub_type (cp_document_sub_type IN VARCHAR2) IS
          SELECT lkup.meaning
          FROM   igs_lookups_view lkup
          WHERE  lkup.lookup_type = 'IGS_AS_DOCUMENT_SUB_TYPE'
          AND    lkup.lookup_code = cp_document_sub_type;
        CURSOR cur_delivery_method (cp_delivery_method_type IN VARCHAR2) IS
          SELECT description
          FROM   igs_as_doc_dlvy_typ
          WHERE  delivery_method_type = cp_delivery_method_type;
        rec_document_type     cur_document_type%ROWTYPE;
        rec_document_sub_type cur_document_sub_type%ROWTYPE;
        rec_delivery_method   cur_delivery_method%ROWTYPE;
      BEGIN
        OPEN cur_delivery_method (new_references.delivery_method_type);
        FETCH cur_delivery_method INTO rec_delivery_method;
        CLOSE cur_delivery_method;
        OPEN cur_document_type (new_references.document_type);
        FETCH cur_document_type INTO rec_document_type;
        CLOSE cur_document_type;
        OPEN cur_document_sub_type (new_references.document_sub_type);
        FETCH cur_document_sub_type INTO rec_document_sub_type;
        CLOSE cur_document_sub_type;
        igs_as_prod_doc.notify_miss_acad_rec_prod (
          p_person_id                    => new_references.person_id,
          p_order_number                 => new_references.order_number,
          p_item_number                  => new_references.item_number,
          p_document_type                => rec_document_type.meaning || ' - ' || rec_document_sub_type.meaning,
          p_recipient_name               => new_references.recip_pers_name,
          p_receiving_inst_name          => new_references.recip_inst_name,
          p_delivery_method              => rec_delivery_method.description,
          p_fulfillment_date_time        => new_references.date_produced
        );
      END;
    END IF;
    --Call to update the amount in order header table
    igs_as_ss_doc_request.update_order_fee (
      p_order_number                 => x_order_number,
      p_item_number                  => x_item_number,
      p_old_sub_doc_type             => old_references.document_sub_type,
      p_old_deliv_type               => old_references.delivery_method_type,
      p_old_num_copies               => old_references.num_of_copies,
      p_new_sub_doc_type             => x_document_sub_type,
      p_new_deliv_type               => x_delivery_method_type,
      p_new_num_copies               => x_num_of_copies,
      p_return_status                => x_return_status,
      p_msg_data                     => x_msg_data,
      p_msg_count                    => x_msg_count
    );
    IF NVL (x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;
    -- Call procedure to insert/Update record in IGS_AS_DOC_FEE_PMNT table.
    IF new_references.plan_id IS NOT NULL THEN
      igs_as_documents_api.upd_doc_fee_pmnt (
        p_person_id                    => new_references.person_id,
        p_plan_id                      => new_references.plan_id,
        p_num_copies                   => new_references.num_of_copies, --(new_references.num_of_copies - old_references.num_of_copies),
        p_program_on_file              => new_references.programs_on_file,
        p_operation                    => 'U'
      );
    END IF;
    IF (new_references.missing_acad_record_data_ind = 'Y') THEN
      IF (old_references.item_status = 'INCOMPLETE'
          AND new_references.item_status = 'INPROCESS'
         ) THEN
        --
        -- Added code to fix bug# 3039150
        --
        DECLARE
          CURSOR cur_admin_to_notify IS
            SELECT administrator_id
            FROM   igs_as_docproc_stup;
          CURSOR cur_person_details (cp_party_id IN NUMBER) IS
            SELECT party_number,
                   party_name
            FROM   hz_parties
            WHERE  party_id = cp_party_id;
          l_admin_to_notify  igs_as_docproc_stup.administrator_id%TYPE;
          rec_person_details cur_person_details%ROWTYPE;
        BEGIN
          OPEN cur_admin_to_notify;
          FETCH cur_admin_to_notify INTO l_admin_to_notify;
          CLOSE cur_admin_to_notify;
          IF (l_admin_to_notify IS NOT NULL) THEN
            OPEN cur_person_details (new_references.person_id);
            FETCH cur_person_details INTO rec_person_details;
            CLOSE cur_person_details;
            igs_as_notify_student.wf_launch_as007 (
              p_user                         => l_admin_to_notify,
              p_stud_id                      => new_references.person_id,
              p_stud_number                  => rec_person_details.party_number,
              p_stud_name                    => rec_person_details.party_name,
              p_order_number                 => new_references.order_number,
              p_item_number                  => new_references.item_number
            );
          END IF;
        END;
      END IF;
    END IF;
    IF (old_references.item_status = 'INPROCESS'
        AND new_references.item_status = 'PROCESSED'
       ) THEN
      --
      -- Update the Duplicate Documents History record (if any for the item) when the item is PROCESSED.
      --
      DECLARE
        CURSOR cur_hist_update_needed (cp_order_number IN NUMBER, cp_item_number IN NUMBER) IS
          SELECT dd.ROWID,
                 dd.*
          FROM   igs_as_dup_docs dd
          WHERE  dd.order_number = cp_order_number
          AND    dd.item_number = cp_item_number
          AND    dd.fulfilled_by IS NULL;
      BEGIN
        FOR rec_hist_update_needed IN cur_hist_update_needed (new_references.order_number, new_references.item_number) LOOP
          igs_as_dup_docs_pkg.update_row (
            x_rowid                        => rec_hist_update_needed.ROWID,
            x_order_number                 => rec_hist_update_needed.order_number,
            x_item_number                  => rec_hist_update_needed.item_number,
            x_requested_by                 => rec_hist_update_needed.requested_by,
            x_requested_date               => rec_hist_update_needed.requested_date,
            x_fulfilled_by                 => new_references.produced_by,
            x_fulfilled_date               => new_references.date_produced,
            x_return_status                => x_return_status,
            x_msg_data                     => x_msg_data,
            x_msg_count                    => x_msg_count
          );
        END LOOP;
      END;
    END IF;
    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'Insert_Row : ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
  END update_row;
  --
  --
  --
  PROCEDURE add_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_order_number                 IN     NUMBER,
    x_document_type                IN     VARCHAR2,
    x_document_sub_type            IN     VARCHAR2,
    x_item_number                  IN OUT NOCOPY NUMBER,
    x_item_status                  IN     VARCHAR2,
    x_date_produced                IN     DATE,
    x_incl_curr_course             IN     VARCHAR2,
    x_num_of_copies                IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_recip_pers_name              IN     VARCHAR2,
    x_recip_inst_name              IN     VARCHAR2,
    x_recip_addr_line_1            IN     VARCHAR2,
    x_recip_addr_line_2            IN     VARCHAR2,
    x_recip_addr_line_3            IN     VARCHAR2,
    x_recip_addr_line_4            IN     VARCHAR2,
    x_recip_city                   IN     VARCHAR2,
    x_recip_postal_code            IN     VARCHAR2,
    x_recip_state                  IN     VARCHAR2,
    x_recip_province               IN     VARCHAR2,
    x_recip_county                 IN     VARCHAR2,
    x_recip_country                IN     VARCHAR2,
    x_recip_fax_area_code          IN     VARCHAR2,
    x_recip_fax_country_code       IN     VARCHAR2,
    x_recip_fax_number             IN     VARCHAR2,
    x_delivery_method_type         IN     VARCHAR2,
    x_programs_on_file             IN     VARCHAR2,
    x_missing_acad_record_data_ind IN     VARCHAR2,
    x_missing_academic_record_data IN     VARCHAR2,
    x_send_transcript_immediately  IN     VARCHAR2,
    x_hold_release_of_final_grades IN     VARCHAR2,
    x_fgrade_cal_type              IN     VARCHAR2,
    x_fgrade_seq_num               IN     NUMBER,
    x_hold_degree_expected         IN     VARCHAR2,
    x_deghold_cal_type             IN     VARCHAR2,
    x_deghold_seq_num              IN     NUMBER,
    x_hold_for_grade_chg           IN     VARCHAR2,
    x_special_instr                IN     VARCHAR2,
    x_express_mail_type            IN     VARCHAR2,
    x_express_mail_track_num       IN     VARCHAR2,
    x_ge_certification             IN     VARCHAR2,
    x_external_comments            IN     VARCHAR2,
    x_internal_comments            IN     VARCHAR2,
    x_dup_requested                IN     VARCHAR2,
    x_dup_req_date                 IN     DATE,
    x_dup_sent_date                IN     DATE,
    x_enr_term_cal_type            IN     VARCHAR2,
    x_enr_ci_sequence_number       IN     NUMBER,
    x_incl_attempted_hours         IN     VARCHAR2,
    x_incl_class_rank              IN     VARCHAR2,
    x_incl_progresssion_status     IN     VARCHAR2,
    x_incl_class_standing          IN     VARCHAR2,
    x_incl_cum_hours_earned        IN     VARCHAR2,
    x_incl_gpa                     IN     VARCHAR2,
    x_incl_date_of_graduation      IN     VARCHAR2,
    x_incl_degree_dates            IN     VARCHAR2,
    x_incl_degree_earned           IN     VARCHAR2,
    x_incl_date_of_entry           IN     VARCHAR2,
    x_incl_drop_withdrawal_dates   IN     VARCHAR2,
    x_incl_hrs_for_curr_term       IN     VARCHAR2,
    x_incl_majors                  IN     VARCHAR2,
    x_incl_last_date_of_enrollment IN     VARCHAR2,
    x_incl_professional_licensure  IN     VARCHAR2,
    x_incl_college_affiliation     IN     VARCHAR2,
    x_incl_instruction_dates       IN     VARCHAR2,
    x_incl_usec_dates              IN     VARCHAR2,
    x_incl_program_attempt         IN     VARCHAR2,
    x_incl_attendence_type         IN     VARCHAR2,
    x_incl_last_term_enrolled      IN     VARCHAR2,
    x_incl_ssn                     IN     VARCHAR2,
    x_incl_date_of_birth           IN     VARCHAR2,
    x_incl_disciplin_standing      IN     VARCHAR2,
    x_incl_no_future_term          IN     VARCHAR2,
    x_incl_acurat_till_copmp_dt    IN     VARCHAR2,
    x_incl_cant_rel_without_sign   IN     VARCHAR2,
    x_mode                         IN     VARCHAR2,
    x_doc_fee_per_copy             IN     NUMBER,
    x_delivery_fee                 IN     NUMBER,
    x_recip_email                  IN     VARCHAR2,
    x_overridden_doc_delivery_fee  IN     NUMBER,
    x_overridden_document_fee      IN     NUMBER,
    x_fee_overridden_by            IN     NUMBER,
    x_fee_overridden_date          IN     DATE,
    x_incl_department              IN     VARCHAR2,
    x_incl_field_of_stdy           IN     VARCHAR2,
    x_incl_attend_mode             IN     VARCHAR2,
    x_incl_yop_acad_prd            IN     VARCHAR2,
    x_incl_intrmsn_st_end          IN     VARCHAR2,
    x_incl_hnrs_lvl                IN     VARCHAR2,
    x_incl_awards                  IN     VARCHAR2,
    x_incl_award_aim               IN     VARCHAR2,
    x_incl_acad_sessions           IN     VARCHAR2,
    x_incl_st_end_acad_ses         IN     VARCHAR2,
    x_incl_hesa_num                IN     VARCHAR2,
    x_incl_location                IN     VARCHAR2,
    x_incl_program_type            IN     VARCHAR2,
    x_incl_program_name            IN     VARCHAR2,
    x_incl_prog_atmpt_stat         IN     VARCHAR2,
    x_incl_prog_atmpt_end          IN     VARCHAR2,
    x_incl_prog_atmpt_strt         IN     VARCHAR2,
    x_incl_req_cmplete             IN     VARCHAR2,
    x_incl_expected_compl_dt       IN     VARCHAR2,
    x_incl_conferral_dt            IN     VARCHAR2,
    x_incl_thesis_title            IN     VARCHAR2,
    x_incl_program_code            IN     VARCHAR2,
    x_incl_program_ver             IN     VARCHAR2,
    x_incl_stud_no                 IN     VARCHAR2,
    x_incl_surname                 IN     VARCHAR2,
    x_incl_fore_name               IN     VARCHAR2,
    x_incl_prev_names              IN     VARCHAR2,
    x_incl_initials                IN     VARCHAR2,
    x_doc_purpose_code             IN     VARCHAR2,
    x_plan_id                      IN     NUMBER,
    x_produced_by                  IN     NUMBER,
    x_person_id                    IN     NUMBER
  ) AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR c1 IS
      SELECT ROWID
      FROM   igs_as_doc_details
      WHERE  item_number = x_item_number;
    l_return_status VARCHAR2 (10);
    l_msg_data      VARCHAR2 (2000);
    l_msg_count     NUMBER (10);
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_order_number,
        x_document_type,
        x_document_sub_type,
        x_item_number,
        x_item_status,
        x_date_produced,
        x_incl_curr_course,
        x_num_of_copies,
        x_comments,
        x_recip_pers_name,
        x_recip_inst_name,
        x_recip_addr_line_1,
        x_recip_addr_line_2,
        x_recip_addr_line_3,
        x_recip_addr_line_4,
        x_recip_city,
        x_recip_postal_code,
        x_recip_state,
        x_recip_province,
        x_recip_county,
        x_recip_country,
        x_recip_fax_area_code,
        x_recip_fax_country_code,
        x_recip_fax_number,
        x_delivery_method_type,
        x_programs_on_file,
        x_missing_acad_record_data_ind,
        x_missing_academic_record_data,
        x_send_transcript_immediately,
        x_hold_release_of_final_grades,
        x_fgrade_cal_type,
        x_fgrade_seq_num,
        x_hold_degree_expected,
        x_deghold_cal_type,
        x_deghold_seq_num,
        x_hold_for_grade_chg,
        x_special_instr,
        x_express_mail_type,
        x_express_mail_track_num,
        x_ge_certification,
        x_external_comments,
        x_internal_comments,
        x_dup_requested,
        x_dup_req_date,
        x_dup_sent_date,
        x_enr_term_cal_type,
        x_enr_ci_sequence_number,
        x_incl_attempted_hours,
        x_incl_class_rank,
        x_incl_progresssion_status,
        x_incl_class_standing,
        x_incl_cum_hours_earned,
        x_incl_gpa,
        x_incl_date_of_graduation,
        x_incl_degree_dates,
        x_incl_degree_earned,
        x_incl_date_of_entry,
        x_incl_drop_withdrawal_dates,
        x_incl_hrs_for_curr_term,
        x_incl_majors,
        x_incl_last_date_of_enrollment,
        x_incl_professional_licensure,
        x_incl_college_affiliation,
        x_incl_instruction_dates,
        x_incl_usec_dates,
        x_incl_program_attempt,
        x_incl_attendence_type,
        x_incl_last_term_enrolled,
        x_incl_ssn,
        x_incl_date_of_birth,
        x_incl_disciplin_standing,
        x_incl_no_future_term,
        x_incl_acurat_till_copmp_dt,
        x_incl_cant_rel_without_sign,
        x_mode,
        l_return_status,
        l_msg_data,
        l_msg_count,
        x_doc_fee_per_copy,
        x_delivery_fee,
        x_recip_email,
        x_overridden_doc_delivery_fee,
        x_overridden_document_fee,
        x_fee_overridden_by,
        x_fee_overridden_date,
        x_incl_department,
        x_incl_field_of_stdy,
        x_incl_attend_mode,
        x_incl_yop_acad_prd,
        x_incl_intrmsn_st_end,
        x_incl_hnrs_lvl,
        x_incl_awards,
        x_incl_award_aim,
        x_incl_acad_sessions,
        x_incl_st_end_acad_ses,
        x_incl_hesa_num,
        x_incl_location,
        x_incl_program_type,
        x_incl_program_name,
        x_incl_prog_atmpt_stat,
        x_incl_prog_atmpt_end,
        x_incl_prog_atmpt_strt,
        x_incl_req_cmplete,
        x_incl_expected_compl_dt,
        x_incl_conferral_dt,
        x_incl_thesis_title,
        x_incl_program_code,
        x_incl_program_ver,
        x_incl_stud_no,
        x_incl_surname,
        x_incl_fore_name,
        x_incl_prev_names,
        x_incl_initials,
        x_doc_purpose_code,
        x_plan_id,
        x_produced_by,
        x_person_id
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_order_number,
      x_document_type,
      x_document_sub_type,
      x_item_number,
      x_item_status,
      x_date_produced,
      x_incl_curr_course,
      x_num_of_copies,
      x_comments,
      x_recip_pers_name,
      x_recip_inst_name,
      x_recip_addr_line_1,
      x_recip_addr_line_2,
      x_recip_addr_line_3,
      x_recip_addr_line_4,
      x_recip_city,
      x_recip_postal_code,
      x_recip_state,
      x_recip_province,
      x_recip_county,
      x_recip_country,
      x_recip_fax_area_code,
      x_recip_fax_country_code,
      x_recip_fax_number,
      x_delivery_method_type,
      x_programs_on_file,
      x_missing_acad_record_data_ind,
      x_missing_academic_record_data,
      x_send_transcript_immediately,
      x_hold_release_of_final_grades,
      x_fgrade_cal_type,
      x_fgrade_seq_num,
      x_hold_degree_expected,
      x_deghold_cal_type,
      x_deghold_seq_num,
      x_hold_for_grade_chg,
      x_special_instr,
      x_express_mail_type,
      x_express_mail_track_num,
      x_ge_certification,
      x_external_comments,
      x_internal_comments,
      x_dup_requested,
      x_dup_req_date,
      x_dup_sent_date,
      x_enr_term_cal_type,
      x_enr_ci_sequence_number,
      x_incl_attempted_hours,
      x_incl_class_rank,
      x_incl_progresssion_status,
      x_incl_class_standing,
      x_incl_cum_hours_earned,
      x_incl_gpa,
      x_incl_date_of_graduation,
      x_incl_degree_dates,
      x_incl_degree_earned,
      x_incl_date_of_entry,
      x_incl_drop_withdrawal_dates,
      x_incl_hrs_for_curr_term,
      x_incl_majors,
      x_incl_last_date_of_enrollment,
      x_incl_professional_licensure,
      x_incl_college_affiliation,
      x_incl_instruction_dates,
      x_incl_usec_dates,
      x_incl_program_attempt,
      x_incl_attendence_type,
      x_incl_last_term_enrolled,
      x_incl_ssn,
      x_incl_date_of_birth,
      x_incl_disciplin_standing,
      x_incl_no_future_term,
      x_incl_acurat_till_copmp_dt,
      x_incl_cant_rel_without_sign,
      x_mode,
      l_return_status,
      l_msg_data,
      l_msg_count,
      x_doc_fee_per_copy,
      x_delivery_fee,
      x_recip_email,
      x_overridden_doc_delivery_fee,
      x_overridden_document_fee,
      x_fee_overridden_by,
      x_fee_overridden_date,
      x_incl_department,
      x_incl_field_of_stdy,
      x_incl_attend_mode,
      x_incl_yop_acad_prd,
      x_incl_intrmsn_st_end,
      x_incl_hnrs_lvl,
      x_incl_awards,
      x_incl_award_aim,
      x_incl_acad_sessions,
      x_incl_st_end_acad_ses,
      x_incl_hesa_num,
      x_incl_location,
      x_incl_program_type,
      x_incl_program_name,
      x_incl_prog_atmpt_stat,
      x_incl_prog_atmpt_end,
      x_incl_prog_atmpt_strt,
      x_incl_req_cmplete,
      x_incl_expected_compl_dt,
      x_incl_conferral_dt,
      x_incl_thesis_title,
      x_incl_program_code,
      x_incl_program_ver,
      x_incl_stud_no,
      x_incl_surname,
      x_incl_fore_name,
      x_incl_prev_names,
      x_incl_initials,
      x_doc_purpose_code,
      x_plan_id,
      x_produced_by,
      x_person_id
    );
  END add_row;
  --
  --
  --
  PROCEDURE delete_row (
    x_rowid                        IN     VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER
  ) AS
    /*
    ||  Created By : manu.srinivasan
    ||  Created On : 28-JAN-2002
    ||  Purpose : Handles the DELETE DML logic for the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR c_items_for_this_order (
      p_order_number                        igs_as_doc_details.order_number%TYPE,
      p_item_number                         igs_as_doc_details.item_number%TYPE
    ) IS
      SELECT a.*,
             a.ROWID
      FROM   igs_as_doc_details a
      WHERE  order_number = p_order_number
      AND    item_number <> p_item_number;
    l_rowid VARCHAR2 (26);
  BEGIN
    fnd_msg_pub.initialize;
    before_dml (p_action => 'DELETE', x_rowid => x_rowid);
    DELETE FROM igs_as_doc_details
          WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    igs_as_documents_api.upd_doc_fee_pmnt (
      p_person_id                    => old_references.person_id,
      p_plan_id                      => old_references.plan_id,
      p_num_copies                   => old_references.num_of_copies,
      p_program_on_file              => old_references.programs_on_file,
      p_operation                    => 'D'
    );
    --
    update_fees_of_remaining_items (
      x_person_id                    => old_references.person_id,
      x_document_type                => old_references.document_type,
      x_document_sub_type            => old_references.document_sub_type
    );
    --Call to update the amount in order header table
    igs_as_ss_doc_request.update_order_fee (
      p_order_number                 => old_references.order_number,
      p_item_number                  => old_references.item_number,
      p_old_sub_doc_type             => old_references.document_sub_type,
      p_old_deliv_type               => old_references.delivery_method_type,
      p_old_num_copies               => old_references.num_of_copies,
      p_new_sub_doc_type             => NULL,
      p_new_deliv_type               => NULL,
      p_new_num_copies               => NULL,
      p_return_status                => x_return_status,
      p_msg_data                     => x_msg_data,
      p_msg_count                    => x_msg_count
    );
    IF NVL (x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;
    -- Call procedure to insert/Update record in IGS_AS_DOC_FEE_PMNT table.
    IF old_references.plan_id IS NOT NULL THEN
      igs_as_documents_api.upd_doc_fee_pmnt (
        p_person_id                    => old_references.person_id,
        p_plan_id                      => old_references.plan_id,
        p_num_copies                   => old_references.num_of_copies,
        p_program_on_file              => old_references.programs_on_file,
        p_operation                    => 'D'
      );
    END IF;
    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    --
    RETURN;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'Insert_Row : ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN;
  END delete_row;
END igs_as_doc_details_pkg;

/
