--------------------------------------------------------
--  DDL for Package Body IGS_AS_DOCUMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_DOCUMENTS_API" AS
/* $Header: IGSAS42B.pls 120.1 2006/01/18 22:57:11 swaghmar noship $ */

  PROCEDURE update_order_item_status (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER
  ) IS
    /*******************************************************************************
      Created by   : rbezawad
      Date created : 18-Jan-2002
      Purpose      : This procedure updates the order status and the items status of the order.
      Known limitations/enhancements/remarks:
      Change History: (who, when, what: NO CREATION RECORDS HERE!)
      Who             When            What
      swaghmar	  16-Jan-2006	   Bug# 4951054 - Added check for disabling the UI's
    *******************************************************************************/
    CURSOR cur_processed_items IS
      SELECT     ROWID row_id,
                 item_status,
                 date_produced,
                 order_number,
                 item_number
      FROM       igs_as_ord_itm_int oii
      WHERE      item_status = 'PROCESSED'
      ORDER BY   order_number,
                 item_number
      FOR UPDATE NOWAIT;
    --
    CURSOR cur_completed_orders IS
      SELECT     ord.ROWID row_id,
                 ord.*
      FROM       igs_as_order_hdr ord
      WHERE      order_status = 'INPROCESS'
      AND        NOT EXISTS ( SELECT item_number
                              FROM   igs_as_doc_details itm
                              WHERE  ord.order_number = itm.order_number
                              AND    itm.item_status <> 'PROCESSED')
      ORDER BY   order_number
      FOR UPDATE NOWAIT;
    --
    CURSOR cur_doc_details (
      cp_order_number                       igs_as_doc_details.order_number%TYPE,
      cp_item_number                        igs_as_doc_details.item_number%TYPE
    ) IS
      SELECT ROWID row_id,
             dd.*
      FROM   igs_as_doc_details dd
      WHERE  order_number = cp_order_number
      AND    item_number = cp_item_number;
    --
    doc_details_rec cur_doc_details%ROWTYPE;
    --
    CURSOR cur_doc_date (cp_order_number igs_as_doc_details.order_number%TYPE) IS
      SELECT MAX (date_produced)
      FROM   igs_as_doc_details
      WHERE  order_number = cp_order_number;
    --
    l_date_produced igs_as_doc_details.date_produced%TYPE;
    l_return_status VARCHAR2 (1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2 (2000);
  BEGIN


    retcode := 0;
    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

    -- Populate the data into OSS Transcripts tables from Interface Table
    FOR processed_items_rec IN cur_processed_items LOOP
      OPEN cur_doc_details (processed_items_rec.order_number, processed_items_rec.item_number);
      FETCH cur_doc_details INTO doc_details_rec;
      IF cur_doc_details%FOUND THEN
        --Update item_status, date_produced Columns of OSS Document Details table with interface table data
        igs_as_doc_details_pkg.update_row (
          x_mode                         => 'R',
          x_rowid                        => doc_details_rec.row_id,
          x_order_number                 => doc_details_rec.order_number,
          x_document_type                => doc_details_rec.document_type,
          x_document_sub_type            => doc_details_rec.document_sub_type,
          x_item_number                  => doc_details_rec.item_number,
          x_item_status                  => processed_items_rec.item_status,
          x_date_produced                => processed_items_rec.date_produced,
          x_incl_curr_course             => doc_details_rec.incl_curr_course,
          x_num_of_copies                => doc_details_rec.num_of_copies,
          x_comments                     => doc_details_rec.comments,
          x_recip_pers_name              => doc_details_rec.recip_pers_name,
          x_recip_inst_name              => doc_details_rec.recip_inst_name,
          x_recip_addr_line_1            => doc_details_rec.recip_addr_line_1,
          x_recip_addr_line_2            => doc_details_rec.recip_addr_line_2,
          x_recip_addr_line_3            => doc_details_rec.recip_addr_line_3,
          x_recip_addr_line_4            => doc_details_rec.recip_addr_line_4,
          x_recip_city                   => doc_details_rec.recip_city,
          x_recip_postal_code            => doc_details_rec.recip_postal_code,
          x_recip_state                  => doc_details_rec.recip_state,
          x_recip_province               => doc_details_rec.recip_province,
          x_recip_county                 => doc_details_rec.recip_county,
          x_recip_country                => doc_details_rec.recip_country,
          x_recip_fax_area_code          => doc_details_rec.recip_fax_area_code,
          x_recip_fax_country_code       => doc_details_rec.recip_fax_country_code,
          x_recip_fax_number             => doc_details_rec.recip_fax_number,
          x_delivery_method_type         => doc_details_rec.delivery_method_type,
          x_programs_on_file             => doc_details_rec.programs_on_file,
          x_missing_acad_record_data_ind => doc_details_rec.missing_acad_record_data_ind,
          x_missing_academic_record_data => doc_details_rec.missing_academic_record_data,
          x_send_transcript_immediately  => doc_details_rec.send_transcript_immediately,
          x_hold_release_of_final_grades => doc_details_rec.hold_release_of_final_grades,
          x_fgrade_cal_type              => doc_details_rec.fgrade_cal_type,
          x_fgrade_seq_num               => doc_details_rec.fgrade_seq_num,
          x_hold_degree_expected         => doc_details_rec.hold_degree_expected,
          x_deghold_cal_type             => doc_details_rec.deghold_cal_type,
          x_deghold_seq_num              => doc_details_rec.deghold_seq_num,
          x_hold_for_grade_chg           => doc_details_rec.hold_for_grade_chg,
          x_special_instr                => doc_details_rec.special_instr,
          x_express_mail_type            => doc_details_rec.express_mail_type,
          x_express_mail_track_num       => doc_details_rec.express_mail_track_num,
          x_ge_certification             => doc_details_rec.ge_certification,
          x_external_comments            => doc_details_rec.external_comments,
          x_internal_comments            => doc_details_rec.internal_comments,
          x_dup_requested                => doc_details_rec.dup_requested,
          x_dup_req_date                 => doc_details_rec.dup_req_date,
          x_dup_sent_date                => doc_details_rec.dup_sent_date,
          x_enr_term_cal_type            => doc_details_rec.enr_term_cal_type,
          x_enr_ci_sequence_number       => doc_details_rec.enr_ci_sequence_number,
          x_incl_attempted_hours         => doc_details_rec.incl_attempted_hours,
          x_incl_class_rank              => doc_details_rec.incl_class_rank,
          x_incl_progresssion_status     => doc_details_rec.incl_progresssion_status,
          x_incl_class_standing          => doc_details_rec.incl_class_standing,
          x_incl_cum_hours_earned        => doc_details_rec.incl_cum_hours_earned,
          x_incl_gpa                     => doc_details_rec.incl_gpa,
          x_incl_date_of_graduation      => doc_details_rec.incl_date_of_graduation,
          x_incl_degree_dates            => doc_details_rec.incl_degree_dates,
          x_incl_degree_earned           => doc_details_rec.incl_degree_earned,
          x_incl_date_of_entry           => doc_details_rec.incl_date_of_entry,
          x_incl_drop_withdrawal_dates   => doc_details_rec.incl_drop_withdrawal_dates,
          x_incl_hrs_for_curr_term       => doc_details_rec.incl_hrs_earned_for_curr_term,
          x_incl_majors                  => doc_details_rec.incl_majors,
          x_incl_last_date_of_enrollment => doc_details_rec.incl_last_date_of_enrollment,
          x_incl_professional_licensure  => doc_details_rec.incl_professional_licensure,
          x_incl_college_affiliation     => doc_details_rec.incl_college_affiliation,
          x_incl_instruction_dates       => doc_details_rec.incl_instruction_dates,
          x_incl_usec_dates              => doc_details_rec.incl_usec_dates,
          x_incl_program_attempt         => doc_details_rec.incl_program_attempt,
          x_incl_attendence_type         => doc_details_rec.incl_attendence_type,
          x_incl_last_term_enrolled      => doc_details_rec.incl_last_term_enrolled,
          x_incl_ssn                     => doc_details_rec.incl_ssn,
          x_incl_date_of_birth           => doc_details_rec.incl_date_of_birth,
          x_incl_disciplin_standing      => doc_details_rec.incl_disciplin_standing,
          x_incl_no_future_term          => doc_details_rec.incl_no_future_term,
          x_incl_acurat_till_copmp_dt    => doc_details_rec.incl_acurat_till_copmp_dt,
          x_incl_cant_rel_without_sign   => doc_details_rec.incl_cant_rel_without_sign,
          x_return_status                => l_return_status,
          x_msg_data                     => l_msg_data,
          x_msg_count                    => l_msg_count,
          x_doc_fee_per_copy             => doc_details_rec.doc_fee_per_copy,
          x_delivery_fee                 => doc_details_rec.delivery_fee,
          x_recip_email                  => doc_details_rec.recip_email,
          x_overridden_doc_delivery_fee  => doc_details_rec.overridden_doc_delivery_fee,
          x_overridden_document_fee      => doc_details_rec.overridden_document_fee,
          x_fee_overridden_by            => doc_details_rec.fee_overridden_by,
          x_fee_overridden_date          => doc_details_rec.fee_overridden_date,
          x_incl_department              => doc_details_rec.incl_department,
          x_incl_field_of_stdy           => doc_details_rec.incl_field_of_stdy,
          x_incl_attend_mode             => doc_details_rec.incl_attend_mode,
          x_incl_yop_acad_prd            => doc_details_rec.incl_yop_acad_prd,
          x_incl_intrmsn_st_end          => doc_details_rec.incl_intrmsn_st_end,
          x_incl_hnrs_lvl                => doc_details_rec.incl_hnrs_lvl,
          x_incl_awards                  => doc_details_rec.incl_awards,
          x_incl_award_aim               => doc_details_rec.incl_award_aim,
          x_incl_acad_sessions           => doc_details_rec.incl_acad_sessions,
          x_incl_st_end_acad_ses         => doc_details_rec.incl_st_end_acad_ses,
          x_incl_hesa_num                => doc_details_rec.incl_hesa_num,
          x_incl_location                => doc_details_rec.incl_location,
          x_incl_program_type            => doc_details_rec.incl_program_type,
          x_incl_program_name            => doc_details_rec.incl_program_name,
          x_incl_prog_atmpt_stat         => doc_details_rec.incl_prog_atmpt_stat,
          x_incl_prog_atmpt_end          => doc_details_rec.incl_prog_atmpt_end,
          x_incl_prog_atmpt_strt         => doc_details_rec.incl_prog_atmpt_strt,
          x_incl_req_cmplete             => doc_details_rec.incl_req_cmplete,
          x_incl_expected_compl_dt       => doc_details_rec.incl_expected_compl_dt,
          x_incl_conferral_dt            => doc_details_rec.incl_conferral_dt,
          x_incl_thesis_title            => doc_details_rec.incl_thesis_title,
          x_incl_program_code            => doc_details_rec.incl_program_code,
          x_incl_program_ver             => doc_details_rec.incl_program_ver,
          x_incl_stud_no                 => doc_details_rec.incl_stud_no,
          x_incl_surname                 => doc_details_rec.incl_surname,
          x_incl_fore_name               => doc_details_rec.incl_fore_name,
          x_incl_prev_names              => doc_details_rec.incl_prev_names,
          x_incl_initials                => doc_details_rec.incl_initials,
          x_doc_purpose_code             => doc_details_rec.doc_purpose_code,
          x_plan_id                      => doc_details_rec.plan_id,
          x_produced_by                  => doc_details_rec.produced_by,
          x_person_id                    => doc_details_rec.person_id
        );
        IF (l_return_status = fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name ('IGS', 'IGS_AS_ITEM_STATUS');
          fnd_message.set_token ('ORDER_NUMBER', doc_details_rec.order_number);
          fnd_message.set_token ('ITEM_NUMBER', doc_details_rec.item_number);
          fnd_file.put_line (fnd_file.LOG, fnd_message.get);
          --Delete the Item Number record from Interface table after updating the OSS Document Details Table
          DELETE      igs_as_ord_itm_int
          WHERE ROWID = processed_items_rec.row_id;
        ELSE
          -- IF the RETURN status IS error than LOG a message AND the message
          -- data that was retunred by the above API
          fnd_message.set_name ('IGS', 'IGS_AS_ITEM_STATUS_ERR');
          fnd_message.set_token ('ORDER_NUMBER', doc_details_rec.order_number);
          fnd_message.set_token ('ITEM_NUMBER', doc_details_rec.item_number);
          fnd_file.put_line (fnd_file.LOG, l_msg_data);
          IF l_msg_count = 1 THEN
            fnd_file.put_line (fnd_file.LOG, fnd_message.get);
          ELSE
            FOR l_count IN 1 .. l_msg_count LOOP
              fnd_message.set_encoded (fnd_msg_pub.get (p_msg_index => l_count, p_encoded => 'T'));
              fnd_file.put_line (fnd_file.LOG, fnd_message.get);
            END LOOP;
          END IF;
        END IF;
      END IF;
      CLOSE cur_doc_details;
    END LOOP;
    fnd_file.put_line (fnd_file.LOG, '+---------------------------------------------------------------------------+');
    --
    -- Update the order/request status to 'COMPLETED' if all the
    -- items of the order have status 'PROCESSED'
    --
    FOR completed_orders_rec IN cur_completed_orders LOOP
      OPEN cur_doc_date (completed_orders_rec.order_number);
      FETCH cur_doc_date INTO l_date_produced;
      CLOSE cur_doc_date;
      l_return_status := NULL;
      l_msg_data := NULL;
      l_msg_count := NULL;
      -- Update the Order Status, Date of Completion for the Request in the OSS Order Table.
      igs_as_order_hdr_pkg.update_row (
        x_mode                         => 'R',
        x_rowid                        => completed_orders_rec.row_id,
        x_order_number                 => completed_orders_rec.order_number,
        x_order_status                 => 'COMPLETED',
        x_date_completed               => l_date_produced,
        x_person_id                    => completed_orders_rec.person_id,
        x_addr_line_1                  => completed_orders_rec.addr_line_1,
        x_addr_line_2                  => completed_orders_rec.addr_line_2,
        x_addr_line_3                  => completed_orders_rec.addr_line_3,
        x_addr_line_4                  => completed_orders_rec.addr_line_4,
        x_city                         => completed_orders_rec.city,
        x_state                        => completed_orders_rec.state,
        x_province                     => completed_orders_rec.province,
        x_county                       => completed_orders_rec.county,
        x_country                      => completed_orders_rec.country,
        x_postal_code                  => completed_orders_rec.postal_code,
        x_email_address                => completed_orders_rec.email_address,
        x_phone_country_code           => completed_orders_rec.phone_country_code,
        x_phone_area_code              => completed_orders_rec.phone_area_code,
        x_phone_number                 => completed_orders_rec.phone_number,
        x_phone_extension              => completed_orders_rec.phone_extension,
        x_fax_country_code             => completed_orders_rec.fax_country_code,
        x_fax_area_code                => completed_orders_rec.fax_area_code,
        x_fax_number                   => completed_orders_rec.fax_number,
        x_delivery_fee                 => completed_orders_rec.delivery_fee,
        x_order_fee                    => completed_orders_rec.order_fee,
        x_request_type                 => completed_orders_rec.request_type,
        x_submit_method                => completed_orders_rec.submit_method,
        x_invoice_id                   => completed_orders_rec.invoice_id,
        x_return_status                => l_return_status,
        x_msg_data                     => l_msg_data,
        x_msg_count                    => l_msg_count,
        x_order_description            => completed_orders_rec.order_description,
        x_order_placed_by              => completed_orders_rec.order_placed_by
      );
      IF (l_return_status = fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name ('IGS', 'IGS_AS_ORDER_STATUS');
        fnd_message.set_token ('ORDER_NUMBER', completed_orders_rec.order_number);
        fnd_file.put_line (fnd_file.LOG, fnd_message.get);
      ELSE
        -- IF the RETURN status IS error than LOG a message AND the message
        -- data that was retunred by the above API
        fnd_message.set_name ('IGS', 'IGS_AS_ORDER_STATUS_ERR');
        fnd_message.set_token ('ORDER_NUMBER', completed_orders_rec.order_number);
        fnd_file.put_line (fnd_file.LOG, fnd_message.get);
        IF l_msg_count = 1 THEN
          fnd_file.put_line (fnd_file.LOG, fnd_message.get);
        ELSE
          FOR l_count IN 1 .. l_msg_count LOOP
            fnd_message.set_encoded (fnd_msg_pub.get (p_msg_index => l_count, p_encoded => 'T'));
            fnd_file.put_line (fnd_file.LOG, fnd_message.get);
          END LOOP;
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      errbuf := fnd_message.get_string ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      retcode := 2;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'Update_Order_Item_Status(): ' || SQLERRM);
      fnd_file.put_line (fnd_file.LOG, fnd_message.get);
      igs_ge_msg_stack.ADD;
      igs_ge_msg_stack.conc_exception_hndl;
  END update_order_item_status;

  PROCEDURE update_document_details (
    p_order_number                 IN     NUMBER,
    p_item_number                  IN     NUMBER,
    p_init_msg_list                IN     VARCHAR2,
    p_return_status                OUT NOCOPY VARCHAR2,
    p_msg_count                    OUT NOCOPY NUMBER,
    p_msg_data                     OUT NOCOPY VARCHAR2,
    p_person_id                    IN     VARCHAR2,
    p_fee_amt                      IN     NUMBER,
    p_recorded_by                  IN     NUMBER,
    p_plan_id                      IN     NUMBER,
    p_invoice_id                   IN     NUMBER,
    p_plan_cal_type                IN     VARCHAR2,
    p_plan_ci_sequence_number      IN     NUMBER
  ) IS
    /*******************************************************************************
      Created by   : rbezawad
      Date created : 21-Jan-2002
      Purpose      : This procedure updates Transcipt's Order, Item Statuses to INPROCESS.
                     And also inserts the Transcripts Request record into Interface table.
      Known limitations/enhancements/remarks:
      Change History: (who, when, what: NO CREATION RECORDS HERE!)
      Who      When        What
      kdande   29-Nov-2002 Changed the logic to create an interface item.
    *******************************************************************************/
    CURSOR cur_order_hdr IS
      SELECT ord.ROWID row_id,
             ord.*
      FROM   igs_as_order_hdr ord
      WHERE  order_number = p_order_number;
    --
    order_hdr_rec           cur_order_hdr%ROWTYPE;
    --
    CURSOR cur_doc_details IS
      SELECT   ROWID row_id,
               dd.*
      FROM     igs_as_doc_details dd
      WHERE    dd.order_number = p_order_number
      AND      dd.item_number = NVL (p_item_number, dd.item_number)
      ORDER BY dd.item_number;
    --
    CURSOR cur_ord_int_details (cp_order_number NUMBER, cp_item_number NUMBER) IS
      SELECT 'X'
      FROM   igs_as_ord_itm_int
      WHERE  order_number = cp_order_number
      AND    item_number = cp_item_number;
    --
    CURSOR cur_ord_int_dupl_doc (cp_order_number NUMBER, cp_item_number NUMBER) IS
      SELECT 'X'
      FROM   igs_as_ord_itm_int intr,
             igs_as_dup_docs dup
      WHERE  intr.order_number = cp_order_number
      AND    intr.item_number = cp_item_number
      AND    intr.item_status = 'PROCESSED'
      AND    intr.order_number = dup.order_number
      AND    intr.item_number = dup.item_number;
    --
    ord_int_details_rec     cur_ord_int_details%ROWTYPE;
    rec_ord_int_dupl_doc    cur_ord_int_dupl_doc%ROWTYPE;
    l_return_status         VARCHAR2 (1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2 (2000);
    l_person_id             igs_as_order_hdr.person_id%TYPE;
    lv_rowid                VARCHAR2 (25);
    l_create_interface_item BOOLEAN;
  BEGIN
    --Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;
    OPEN cur_order_hdr;
    FETCH cur_order_hdr INTO order_hdr_rec;
    IF  p_order_number IS NOT NULL
        AND p_plan_id IS NULL THEN
      IF (cur_order_hdr%FOUND) THEN
        l_person_id := order_hdr_rec.person_id; -- Need the var to pass to the recal procdure
        --Update the Order status to 'In Process' and other order details.
        igs_as_order_hdr_pkg.update_row (
          x_mode                         => 'R',
          x_rowid                        => order_hdr_rec.row_id,
          x_order_number                 => order_hdr_rec.order_number,
          x_order_status                 => 'INPROCESS',
          x_date_completed               => order_hdr_rec.date_completed,
          x_person_id                    => order_hdr_rec.person_id,
          x_addr_line_1                  => order_hdr_rec.addr_line_1,
          x_addr_line_2                  => order_hdr_rec.addr_line_2,
          x_addr_line_3                  => order_hdr_rec.addr_line_3,
          x_addr_line_4                  => order_hdr_rec.addr_line_4,
          x_city                         => order_hdr_rec.city,
          x_state                        => order_hdr_rec.state,
          x_province                     => order_hdr_rec.province,
          x_county                       => order_hdr_rec.county,
          x_country                      => order_hdr_rec.country,
          x_postal_code                  => order_hdr_rec.postal_code,
          x_email_address                => order_hdr_rec.email_address,
          x_phone_country_code           => order_hdr_rec.phone_country_code,
          x_phone_area_code              => order_hdr_rec.phone_area_code,
          x_phone_number                 => order_hdr_rec.phone_number,
          x_phone_extension              => order_hdr_rec.phone_extension,
          x_fax_country_code             => order_hdr_rec.fax_country_code,
          x_fax_area_code                => order_hdr_rec.fax_area_code,
          x_fax_number                   => order_hdr_rec.fax_number,
          x_delivery_fee                 => order_hdr_rec.delivery_fee,
          x_order_fee                    => order_hdr_rec.order_fee,
          x_request_type                 => order_hdr_rec.request_type,
          x_submit_method                => order_hdr_rec.submit_method,
          x_invoice_id                   => order_hdr_rec.invoice_id,
          x_return_status                => l_return_status,
          x_msg_data                     => l_msg_data,
          x_msg_count                    => l_msg_count,
          x_order_description            => order_hdr_rec.order_description,
          x_order_placed_by              => order_hdr_rec.order_placed_by
        );
        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          p_return_status := l_return_status;
          p_msg_count := l_msg_count;
          p_msg_data := l_msg_data;
          RETURN;
        END IF;
        FOR doc_details_rec IN cur_doc_details LOOP
          l_return_status := NULL;
          l_msg_data := NULL;
          l_msg_count := NULL;
          --Update the Order's Item status to 'In Process'
          igs_as_doc_details_pkg.update_row (
            x_mode                         => 'R',
            x_rowid                        => doc_details_rec.row_id,
            x_order_number                 => doc_details_rec.order_number,
            x_document_type                => doc_details_rec.document_type,
            x_document_sub_type            => doc_details_rec.document_sub_type,
            x_item_number                  => doc_details_rec.item_number,
            x_item_status                  => 'INPROCESS',
            x_date_produced                => doc_details_rec.date_produced,
            x_incl_curr_course             => doc_details_rec.incl_curr_course,
            x_num_of_copies                => doc_details_rec.num_of_copies,
            x_comments                     => doc_details_rec.comments,
            x_recip_pers_name              => doc_details_rec.recip_pers_name,
            x_recip_inst_name              => doc_details_rec.recip_inst_name,
            x_recip_addr_line_1            => doc_details_rec.recip_addr_line_1,
            x_recip_addr_line_2            => doc_details_rec.recip_addr_line_2,
            x_recip_addr_line_3            => doc_details_rec.recip_addr_line_3,
            x_recip_addr_line_4            => doc_details_rec.recip_addr_line_4,
            x_recip_city                   => doc_details_rec.recip_city,
            x_recip_postal_code            => doc_details_rec.recip_postal_code,
            x_recip_state                  => doc_details_rec.recip_state,
            x_recip_province               => doc_details_rec.recip_province,
            x_recip_county                 => doc_details_rec.recip_county,
            x_recip_country                => doc_details_rec.recip_country,
            x_recip_fax_area_code          => doc_details_rec.recip_fax_area_code,
            x_recip_fax_country_code       => doc_details_rec.recip_fax_country_code,
            x_recip_fax_number             => doc_details_rec.recip_fax_number,
            x_delivery_method_type         => doc_details_rec.delivery_method_type,
            x_programs_on_file             => doc_details_rec.programs_on_file,
            x_missing_acad_record_data_ind => doc_details_rec.missing_acad_record_data_ind,
            x_missing_academic_record_data => doc_details_rec.missing_academic_record_data,
            x_send_transcript_immediately  => doc_details_rec.send_transcript_immediately,
            x_hold_release_of_final_grades => doc_details_rec.hold_release_of_final_grades,
            x_fgrade_cal_type              => doc_details_rec.fgrade_cal_type,
            x_fgrade_seq_num               => doc_details_rec.fgrade_seq_num,
            x_hold_degree_expected         => doc_details_rec.hold_degree_expected,
            x_deghold_cal_type             => doc_details_rec.deghold_cal_type,
            x_deghold_seq_num              => doc_details_rec.deghold_seq_num,
            x_hold_for_grade_chg           => doc_details_rec.hold_for_grade_chg,
            x_special_instr                => doc_details_rec.special_instr,
            x_express_mail_type            => doc_details_rec.express_mail_type,
            x_express_mail_track_num       => doc_details_rec.express_mail_track_num,
            x_ge_certification             => doc_details_rec.ge_certification,
            x_external_comments            => doc_details_rec.external_comments,
            x_internal_comments            => doc_details_rec.internal_comments,
            x_dup_requested                => doc_details_rec.dup_requested,
            x_dup_req_date                 => doc_details_rec.dup_req_date,
            x_dup_sent_date                => doc_details_rec.dup_sent_date,
            x_enr_term_cal_type            => doc_details_rec.enr_term_cal_type,
            x_enr_ci_sequence_number       => doc_details_rec.enr_ci_sequence_number,
            x_incl_attempted_hours         => doc_details_rec.incl_attempted_hours,
            x_incl_class_rank              => doc_details_rec.incl_class_rank,
            x_incl_progresssion_status     => doc_details_rec.incl_progresssion_status,
            x_incl_class_standing          => doc_details_rec.incl_class_standing,
            x_incl_cum_hours_earned        => doc_details_rec.incl_cum_hours_earned,
            x_incl_gpa                     => doc_details_rec.incl_gpa,
            x_incl_date_of_graduation      => doc_details_rec.incl_date_of_graduation,
            x_incl_degree_dates            => doc_details_rec.incl_degree_dates,
            x_incl_degree_earned           => doc_details_rec.incl_degree_earned,
            x_incl_date_of_entry           => doc_details_rec.incl_date_of_entry,
            x_incl_drop_withdrawal_dates   => doc_details_rec.incl_drop_withdrawal_dates,
            x_incl_hrs_for_curr_term       => doc_details_rec.incl_hrs_earned_for_curr_term,
            x_incl_majors                  => doc_details_rec.incl_majors,
            x_incl_last_date_of_enrollment => doc_details_rec.incl_last_date_of_enrollment,
            x_incl_professional_licensure  => doc_details_rec.incl_professional_licensure,
            x_incl_college_affiliation     => doc_details_rec.incl_college_affiliation,
            x_incl_instruction_dates       => doc_details_rec.incl_instruction_dates,
            x_incl_usec_dates              => doc_details_rec.incl_usec_dates,
            x_incl_program_attempt         => doc_details_rec.incl_program_attempt,
            x_incl_attendence_type         => doc_details_rec.incl_attendence_type,
            x_incl_last_term_enrolled      => doc_details_rec.incl_last_term_enrolled,
            x_incl_ssn                     => doc_details_rec.incl_ssn,
            x_incl_date_of_birth           => doc_details_rec.incl_date_of_birth,
            x_incl_disciplin_standing      => doc_details_rec.incl_disciplin_standing,
            x_incl_no_future_term          => doc_details_rec.incl_no_future_term,
            x_incl_acurat_till_copmp_dt    => doc_details_rec.incl_acurat_till_copmp_dt,
            x_incl_cant_rel_without_sign   => doc_details_rec.incl_cant_rel_without_sign,
            x_return_status                => l_return_status,
            x_msg_data                     => l_msg_data,
            x_msg_count                    => l_msg_count,
            x_doc_fee_per_copy             => doc_details_rec.doc_fee_per_copy,
            x_delivery_fee                 => doc_details_rec.delivery_fee,
            x_recip_email                  => doc_details_rec.recip_email,
            x_overridden_doc_delivery_fee  => doc_details_rec.overridden_doc_delivery_fee,
            x_overridden_document_fee      => doc_details_rec.overridden_document_fee,
            x_fee_overridden_by            => doc_details_rec.fee_overridden_by,
            x_fee_overridden_date          => doc_details_rec.fee_overridden_date,
            x_incl_department              => doc_details_rec.incl_department,
            x_incl_field_of_stdy           => doc_details_rec.incl_field_of_stdy,
            x_incl_attend_mode             => doc_details_rec.incl_attend_mode,
            x_incl_yop_acad_prd            => doc_details_rec.incl_yop_acad_prd,
            x_incl_intrmsn_st_end          => doc_details_rec.incl_intrmsn_st_end,
            x_incl_hnrs_lvl                => doc_details_rec.incl_hnrs_lvl,
            x_incl_awards                  => doc_details_rec.incl_awards,
            x_incl_award_aim               => doc_details_rec.incl_award_aim,
            x_incl_acad_sessions           => doc_details_rec.incl_acad_sessions,
            x_incl_st_end_acad_ses         => doc_details_rec.incl_st_end_acad_ses,
            x_incl_hesa_num                => doc_details_rec.incl_hesa_num,
            x_incl_location                => doc_details_rec.incl_location,
            x_incl_program_type            => doc_details_rec.incl_program_type,
            x_incl_program_name            => doc_details_rec.incl_program_name,
            x_incl_prog_atmpt_stat         => doc_details_rec.incl_prog_atmpt_stat,
            x_incl_prog_atmpt_end          => doc_details_rec.incl_prog_atmpt_end,
            x_incl_prog_atmpt_strt         => doc_details_rec.incl_prog_atmpt_strt,
            x_incl_req_cmplete             => doc_details_rec.incl_req_cmplete,
            x_incl_expected_compl_dt       => doc_details_rec.incl_expected_compl_dt,
            x_incl_conferral_dt            => doc_details_rec.incl_conferral_dt,
            x_incl_thesis_title            => doc_details_rec.incl_thesis_title,
            x_incl_program_code            => doc_details_rec.incl_program_code,
            x_incl_program_ver             => doc_details_rec.incl_program_ver,
            x_incl_stud_no                 => doc_details_rec.incl_stud_no,
            x_incl_surname                 => doc_details_rec.incl_surname,
            x_incl_fore_name               => doc_details_rec.incl_fore_name,
            x_incl_prev_names              => doc_details_rec.incl_prev_names,
            x_incl_initials                => doc_details_rec.incl_initials,
            x_doc_purpose_code             => doc_details_rec.doc_purpose_code,
            x_plan_id                      => doc_details_rec.plan_id,
            x_produced_by                  => doc_details_rec.produced_by,
            x_person_id                    => doc_details_rec.person_id
          );
          IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            p_return_status := l_return_status;
            p_msg_count := l_msg_count;
            p_msg_data := l_msg_data;
            RETURN;
          END IF;
          OPEN cur_ord_int_details (doc_details_rec.order_number, doc_details_rec.item_number);
          FETCH cur_ord_int_details INTO ord_int_details_rec;
          IF cur_ord_int_details%NOTFOUND THEN
            l_create_interface_item := TRUE;
          ELSE
            l_create_interface_item := FALSE;
            OPEN cur_ord_int_dupl_doc (doc_details_rec.order_number, doc_details_rec.item_number);
            FETCH cur_ord_int_dupl_doc INTO rec_ord_int_dupl_doc;
            IF (cur_ord_int_dupl_doc%FOUND) THEN
              l_create_interface_item := TRUE;
            END IF;
            CLOSE cur_ord_int_dupl_doc;
          END IF;
          IF (l_create_interface_item) THEN
            -- Inserting the Items of Order information into Interface table.
            INSERT INTO igs_as_ord_itm_int
                        (order_number, person_id, document_type,
                         document_sub_type, item_number, item_status,
                         date_produced, num_of_copies,
                         programs_on_file, comments, recip_pers_name,
                         recip_inst_name, recip_addr_line_1,
                         recip_addr_line_2, recip_addr_line_3,
                         recip_addr_line_4, recip_city,
                         recip_postal_code, recip_state,
                         recip_province, recip_county, recip_country,
                         recip_fax_area_code, recip_fax_country_code,
                         recip_fax_number, delivery_method_type,
                         dup_requested, dup_req_date, dup_sent_date,
                         fgrade_cal_type, fgrade_seq_num,
                         deghold_cal_type, deghold_seq_num,
                         hold_for_grade_chg, hold_degree_expected,
                         hold_release_of_final_grades, incl_curr_course,
                         missing_acad_record_data_ind, missing_academic_record_data,
                         send_transcript_immediately, special_instr,
                         express_mail_type, express_mail_track_num,
                         ge_certification, external_comments,
                         internal_comments, enr_term_cal_type,
                         enr_ci_sequence_number, incl_attempted_hours,
                         incl_class_rank, incl_progresssion_status,
                         incl_class_standing, incl_cum_hours_earned,
                         incl_gpa, incl_date_of_graduation,
                         incl_degree_dates, incl_degree_earned,
                         incl_date_of_entry, incl_drop_withdrawal_dates,
                         incl_hrs_earned_for_curr_term, incl_majors,
                         incl_last_date_of_enrollment, incl_professional_licensure,
                         incl_college_affiliation, incl_instruction_dates,
                         incl_usec_dates, incl_program_attempt,
                         incl_attendence_type, incl_last_term_enrolled,
                         incl_ssn, incl_date_of_birth,
                         incl_disciplin_standing, incl_no_future_term,
                         incl_acurat_till_copmp_dt, incl_cant_rel_without_sign,
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login,
                         request_id, program_id,
                         program_application_id, program_update_date,
                         recip_email)
                 VALUES (order_hdr_rec.order_number, order_hdr_rec.person_id, doc_details_rec.document_type,
                         doc_details_rec.document_sub_type, doc_details_rec.item_number, 'INPROCESS',
                         doc_details_rec.date_produced, doc_details_rec.num_of_copies,
                         doc_details_rec.programs_on_file, doc_details_rec.comments, doc_details_rec.recip_pers_name,
                         doc_details_rec.recip_inst_name, doc_details_rec.recip_addr_line_1,
                         doc_details_rec.recip_addr_line_2, doc_details_rec.recip_addr_line_3,
                         doc_details_rec.recip_addr_line_4, doc_details_rec.recip_city,
                         doc_details_rec.recip_postal_code, doc_details_rec.recip_state,
                         doc_details_rec.recip_province, doc_details_rec.recip_county, doc_details_rec.recip_country,
                         doc_details_rec.recip_fax_area_code, doc_details_rec.recip_fax_country_code,
                         doc_details_rec.recip_fax_number, doc_details_rec.delivery_method_type,
                         doc_details_rec.dup_requested, doc_details_rec.dup_req_date, doc_details_rec.dup_sent_date,
                         doc_details_rec.fgrade_cal_type, doc_details_rec.fgrade_seq_num,
                         doc_details_rec.deghold_cal_type, doc_details_rec.deghold_seq_num,
                         doc_details_rec.hold_for_grade_chg, doc_details_rec.hold_degree_expected,
                         doc_details_rec.hold_release_of_final_grades, doc_details_rec.incl_curr_course,
                         doc_details_rec.missing_acad_record_data_ind, doc_details_rec.missing_academic_record_data,
                         doc_details_rec.send_transcript_immediately, doc_details_rec.special_instr,
                         doc_details_rec.express_mail_type, doc_details_rec.express_mail_track_num,
                         doc_details_rec.ge_certification, doc_details_rec.external_comments,
                         doc_details_rec.internal_comments, doc_details_rec.enr_term_cal_type,
                         doc_details_rec.enr_ci_sequence_number, doc_details_rec.incl_attempted_hours,
                         doc_details_rec.incl_class_rank, doc_details_rec.incl_progresssion_status,
                         doc_details_rec.incl_class_standing, doc_details_rec.incl_cum_hours_earned,
                         doc_details_rec.incl_gpa, doc_details_rec.incl_date_of_graduation,
                         doc_details_rec.incl_degree_dates, doc_details_rec.incl_degree_earned,
                         doc_details_rec.incl_date_of_entry, doc_details_rec.incl_drop_withdrawal_dates,
                         doc_details_rec.incl_hrs_earned_for_curr_term, doc_details_rec.incl_majors,
                         doc_details_rec.incl_last_date_of_enrollment, doc_details_rec.incl_professional_licensure,
                         doc_details_rec.incl_college_affiliation, doc_details_rec.incl_instruction_dates,
                         doc_details_rec.incl_usec_dates, doc_details_rec.incl_program_attempt,
                         doc_details_rec.incl_attendence_type, doc_details_rec.incl_last_term_enrolled,
                         doc_details_rec.incl_ssn, doc_details_rec.incl_date_of_birth,
                         doc_details_rec.incl_disciplin_standing, doc_details_rec.incl_no_future_term,
                         doc_details_rec.incl_acurat_till_copmp_dt, doc_details_rec.incl_cant_rel_without_sign,
                         doc_details_rec.creation_date, doc_details_rec.created_by, doc_details_rec.last_update_date,
                         doc_details_rec.last_updated_by, doc_details_rec.last_update_login,
                         doc_details_rec.request_id, doc_details_rec.program_id,
                         doc_details_rec.program_application_id, doc_details_rec.program_update_date,
                         doc_details_rec.recip_email);
          END IF;
          CLOSE cur_ord_int_details;
        END LOOP;
        CLOSE cur_order_hdr;
        -- Added by msrinivi Bug 2407082
        -- Recal all amounts since lft has been paid
        igs_as_ss_doc_request.recalc_after_lft_paid (
          p_person_id                    => l_person_id,
          p_order_number                 => p_order_number,
          p_return_status                => p_return_status,
          p_msg_data                     => p_msg_data,
          p_msg_count                    => p_msg_count
        );
        IF (NVL (l_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success) THEN
          p_return_status := l_return_status;
          p_msg_count := l_msg_count;
          p_msg_data := l_msg_data;
          RETURN;
        END IF;
      ELSE
        --If Order Details are not found for the passed Order Number
        CLOSE cur_order_hdr;
        fnd_message.set_name ('IGS', 'IGS_AS_ORDER_NOT_FOUND');
        fnd_message.set_token ('ORDER_NUMBER', TO_CHAR (p_order_number));
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF  p_order_number IS NULL
           AND p_plan_id IS NOT NULL THEN
      -- Insert a record into IGS_AS_DOC_FEE_PMNT table to note that the student has subscribed to the plan.
      igs_as_doc_fee_pmnt_pkg.insert_row (
        x_rowid                        => lv_rowid,
        x_person_id                    => p_person_id,
        x_fee_paid_date                => SYSDATE,
        x_fee_amount                   => p_fee_amt,
        x_fee_recorded_date            => SYSDATE,
        x_fee_recorded_by              => p_recorded_by,
        x_mode                         => 'R',
        x_plan_id                      => p_plan_id,
        x_invoice_id                   => p_invoice_id,
        x_plan_discon_from             => NULL,
        x_plan_discon_by               => NULL,
        x_num_of_copies                => NULL,
        x_prev_paid_plan               => 'N',
        x_cal_type                     => p_plan_cal_type,
        x_ci_sequence_number           => p_plan_ci_sequence_number,
        x_program_on_file              => NULL,
        x_return_status                => l_return_status,
        x_msg_data                     => l_msg_data,
        x_msg_count                    => l_msg_count
      );
    END IF;
    --Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    --Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => p_msg_count, p_data => p_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => p_msg_count, p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => p_msg_count, p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'update_document_details: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false, p_count => p_msg_count, p_data => p_msg_data);
  END update_document_details;

  PROCEDURE upd_doc_fee_pmnt (
    p_person_id                           NUMBER,
    p_plan_id                             NUMBER,
    p_num_copies                          NUMBER,
    p_program_on_file                     VARCHAR2,
    p_operation                           VARCHAR2
  ) IS
    CURSOR cur_doc_fee_upd IS
      SELECT f.ROWID row_id,
             f.*
      FROM   igs_as_doc_fee_pmnt f
      WHERE  person_id = p_person_id
      AND    plan_id = p_plan_id
      AND    NVL (program_on_file, 'A') = NVL (p_program_on_file, 'A');
    /*
     Bug 2719682
     cursor to find rec irrespective if program on file for non-free plan
    */
    CURSOR cur_doc_fee_upd_non_free IS
      SELECT f.ROWID row_id,
             f.*
      FROM   igs_as_doc_fee_pmnt f
      WHERE  person_id = p_person_id
      AND    plan_id = p_plan_id;
    --
    CURSOR cur_free_plan IS
      SELECT 'Y'
      FROM   igs_as_servic_plan asp,
             igs_lookups_view lkv
      WHERE  asp.plan_type = lkv.meaning
      AND    lkv.lookup_type = 'TRANSCRIPT_SERVICE_PLAN_TYPE'
      AND    lkv.lookup_code = 'FREE_TRANSCRIPT'
      AND    asp.plan_id = p_plan_id;
    --
    l_free_plan      VARCHAR2 (1)                       := 'N';
    non_free_fee_rec cur_doc_fee_upd_non_free%ROWTYPE;
    fee_rec          cur_doc_fee_upd%ROWTYPE;
    lvrow_id         VARCHAR2 (30);
    l_return_status  VARCHAR2 (10);
    l_msg_data       VARCHAR2 (100);
    l_msg_count      NUMBER;
    lnumcopies       NUMBER                             := 0;
  BEGIN
    -- check whether plan is free or non-free
    OPEN cur_free_plan;
    FETCH cur_free_plan INTO l_free_plan;
    CLOSE cur_free_plan;
    IF p_operation = 'I'
       OR p_operation = 'U' THEN
      --See if the record already exists for the student for the given plan ID
      IF l_free_plan = 'Y' THEN
        OPEN cur_doc_fee_upd;
        FETCH cur_doc_fee_upd INTO fee_rec;
        CLOSE cur_doc_fee_upd;
        IF fee_rec.person_id IS NULL THEN
          lvrow_id := NULL;
          -- No record exists hence insert a record.
          igs_as_doc_fee_pmnt_pkg.insert_row (
            x_rowid                        => lvrow_id,
            x_person_id                    => p_person_id,
            x_fee_paid_date                => SYSDATE,
            x_fee_amount                   => 0,
            x_fee_recorded_date            => SYSDATE,
            x_fee_recorded_by              => p_person_id,
            x_mode                         => 'R',
            x_plan_id                      => p_plan_id,
            x_invoice_id                   => NULL,
            x_plan_discon_from             => NULL,
            x_plan_discon_by               => NULL,
            x_num_of_copies                => p_num_copies,
            x_prev_paid_plan               => 'N',
            x_cal_type                     => NULL,
            x_ci_sequence_number           => NULL,
            x_program_on_file              => p_program_on_file,
            x_return_status                => l_return_status,
            x_msg_data                     => l_msg_data,
            x_msg_count                    => l_msg_count
          );
        ELSE
          -- Record is already existing hence update the row..
          igs_as_doc_fee_pmnt_pkg.update_row (
            x_rowid                        => fee_rec.row_id,
            x_person_id                    => fee_rec.person_id,
            x_fee_paid_date                => fee_rec.fee_paid_date,
            x_fee_amount                   => fee_rec.fee_amount,
            x_fee_recorded_date            => fee_rec.fee_recorded_date,
            x_fee_recorded_by              => fee_rec.fee_recorded_by,
            x_mode                         => 'R',
            x_plan_id                      => fee_rec.plan_id,
            x_invoice_id                   => fee_rec.invoice_id,
            x_plan_discon_from             => fee_rec.plan_discon_from,
            x_plan_discon_by               => fee_rec.plan_discon_by,
            x_num_of_copies                => p_num_copies, --NVL (fee_rec.num_of_copies, 0) + p_num_copies,
            x_prev_paid_plan               => fee_rec.prev_paid_plan,
            x_cal_type                     => fee_rec.cal_type,
            x_ci_sequence_number           => fee_rec.ci_sequence_number,
            x_program_on_file              => fee_rec.program_on_file,
            x_return_status                => l_return_status,
            x_msg_data                     => l_msg_data,
            x_msg_count                    => l_msg_count
          );
        END IF; -- IF FOR RECORD EXISTS FOR INSERT
      ELSE -- i.e. l_free_plan = 'N'
        OPEN cur_doc_fee_upd_non_free;
        FETCH cur_doc_fee_upd_non_free INTO non_free_fee_rec;
        CLOSE cur_doc_fee_upd_non_free;
        IF non_free_fee_rec.person_id IS NULL THEN
          -- No record exists hence insert a record.
          lvrow_id := NULL;
          igs_as_doc_fee_pmnt_pkg.insert_row (
            x_rowid                        => lvrow_id,
            x_person_id                    => p_person_id,
            x_fee_paid_date                => SYSDATE,
            x_fee_amount                   => 0,
            x_fee_recorded_date            => SYSDATE,
            x_fee_recorded_by              => p_person_id,
            x_mode                         => 'R',
            x_plan_id                      => p_plan_id,
            x_invoice_id                   => NULL,
            x_plan_discon_from             => NULL,
            x_plan_discon_by               => NULL,
            x_num_of_copies                => p_num_copies,
            x_prev_paid_plan               => 'N',
            x_cal_type                     => NULL,
            x_ci_sequence_number           => NULL,
            x_program_on_file              => p_program_on_file,
            x_return_status                => l_return_status,
            x_msg_data                     => l_msg_data,
            x_msg_count                    => l_msg_count
          );
        ELSE
          -- Record is already existing hence update the row..
          igs_as_doc_fee_pmnt_pkg.update_row (
            x_rowid                        => non_free_fee_rec.row_id,
            x_person_id                    => non_free_fee_rec.person_id,
            x_fee_paid_date                => non_free_fee_rec.fee_paid_date,
            x_fee_amount                   => non_free_fee_rec.fee_amount,
            x_fee_recorded_date            => non_free_fee_rec.fee_recorded_date,
            x_fee_recorded_by              => non_free_fee_rec.fee_recorded_by,
            x_mode                         => 'R',
            x_plan_id                      => non_free_fee_rec.plan_id,
            x_invoice_id                   => non_free_fee_rec.invoice_id,
            x_plan_discon_from             => non_free_fee_rec.plan_discon_from,
            x_plan_discon_by               => non_free_fee_rec.plan_discon_by,
            x_num_of_copies                => p_num_copies, --NVL (non_free_fee_rec.num_of_copies, 0) + p_num_copies,
            x_prev_paid_plan               => non_free_fee_rec.prev_paid_plan,
            x_cal_type                     => non_free_fee_rec.cal_type,
            x_ci_sequence_number           => non_free_fee_rec.ci_sequence_number,
            x_program_on_file              => non_free_fee_rec.program_on_file,
            x_return_status                => l_return_status,
            x_msg_data                     => l_msg_data,
            x_msg_count                    => l_msg_count
          );
        END IF; -- IF FOR RECORD EXISTS FOR INSERT
      END IF; -- l_free_plan = 'Y'
    ELSIF p_operation = 'D' THEN
      IF l_free_plan = 'Y' THEN
        OPEN cur_doc_fee_upd;
        FETCH cur_doc_fee_upd INTO fee_rec;
        CLOSE cur_doc_fee_upd;
        IF ((NVL (fee_rec.num_of_copies, 0) - p_num_copies) < 0) THEN
          lnumcopies := 0;
        ELSE
          lnumcopies := fee_rec.num_of_copies - p_num_copies;
        END IF;
        IF fee_rec.person_id IS NOT NULL THEN
          igs_as_doc_fee_pmnt_pkg.update_row (
            x_rowid                        => fee_rec.row_id,
            x_person_id                    => fee_rec.person_id,
            x_fee_paid_date                => fee_rec.fee_paid_date,
            x_fee_amount                   => fee_rec.fee_amount,
            x_fee_recorded_date            => fee_rec.fee_recorded_date,
            x_fee_recorded_by              => fee_rec.fee_recorded_by,
            x_mode                         => 'R',
            x_plan_id                      => fee_rec.plan_id,
            x_invoice_id                   => fee_rec.invoice_id,
            x_plan_discon_from             => fee_rec.plan_discon_from,
            x_plan_discon_by               => fee_rec.plan_discon_by,
            x_num_of_copies                => lnumcopies,
            x_prev_paid_plan               => fee_rec.prev_paid_plan,
            x_cal_type                     => fee_rec.cal_type,
            x_ci_sequence_number           => fee_rec.ci_sequence_number,
            x_program_on_file              => fee_rec.program_on_file,
            x_return_status                => l_return_status,
            x_msg_data                     => l_msg_data,
            x_msg_count                    => l_msg_count
          );
        END IF;
      ELSE -- i.e. l_free_plan = 'N'
        OPEN cur_doc_fee_upd_non_free;
        FETCH cur_doc_fee_upd_non_free INTO non_free_fee_rec;
        CLOSE cur_doc_fee_upd_non_free;
        IF ((NVL (non_free_fee_rec.num_of_copies, 0) - p_num_copies) < 0) THEN
          lnumcopies := 0;
        ELSE
          lnumcopies := non_free_fee_rec.num_of_copies - p_num_copies;
        END IF;
        IF non_free_fee_rec.person_id IS NOT NULL THEN
          igs_as_doc_fee_pmnt_pkg.update_row (
            x_rowid                        => non_free_fee_rec.row_id,
            x_person_id                    => non_free_fee_rec.person_id,
            x_fee_paid_date                => non_free_fee_rec.fee_paid_date,
            x_fee_amount                   => non_free_fee_rec.fee_amount,
            x_fee_recorded_date            => non_free_fee_rec.fee_recorded_date,
            x_fee_recorded_by              => non_free_fee_rec.fee_recorded_by,
            x_mode                         => 'R',
            x_plan_id                      => non_free_fee_rec.plan_id,
            x_invoice_id                   => non_free_fee_rec.invoice_id,
            x_plan_discon_from             => non_free_fee_rec.plan_discon_from,
            x_plan_discon_by               => non_free_fee_rec.plan_discon_by,
            x_num_of_copies                => lnumcopies,
            x_prev_paid_plan               => non_free_fee_rec.prev_paid_plan,
            x_cal_type                     => non_free_fee_rec.cal_type,
            x_ci_sequence_number           => non_free_fee_rec.ci_sequence_number,
            x_program_on_file              => non_free_fee_rec.program_on_file,
            x_return_status                => l_return_status,
            x_msg_data                     => l_msg_data,
            x_msg_count                    => l_msg_count
          );
        END IF;
      END IF; -- l_free_plan = 'Y'
    END IF; --IF  p_operation
  END upd_doc_fee_pmnt;
END igs_as_documents_api;

/
