--------------------------------------------------------
--  DDL for Package Body IGS_FI_WAV_UTILS_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_WAV_UTILS_002" AS
/* $Header: IGSFI97B.pls 120.6 2005/10/31 10:31:53 appldev noship $ */
  /************************************************************************
    Created By :  Umesh Udayaprakash
    Date Created By :  7/4/2005
    Purpose :  Generic util Pacakge for Waiver Functionality
               Created as part of FI234 - Tuition Waivers enh. Bug # 3392095
    Known limitations,enhancements,remarks:
    Change History
    Who                 When                What
    smadathi           28-Oct-2005          Bug 4704177: Enhancement for Tuition Waiver
                                            CCR. Added function to check for the Error Account = 'Y'
    gurprsin            25-Oct-2005         Bug 4686711, Modified the cursor definition in reverse_waiver
                                            and get_waiver_reversal_amount methods.
    akandreg            20-Oct-2005         Bug 4677083, Modified the reverse_waiver function to
                                            include the GL_DATE validation.
  *************************************************************************/
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

      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_fi_wav_utils_002.' || p_v_module, p_v_string);
    END IF;

  END log_to_fnd;

  PROCEDURE call_charges_api( p_n_person_id         IN  hz_parties.party_id%TYPE,
                              p_v_fee_cal_type      IN  igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                              p_n_fee_ci_seq_number IN  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                              p_v_waiver_name       IN  igs_fi_waiver_pgms.waiver_name%TYPE,
                              p_v_adj_fee_type      IN  igs_fi_fee_type.fee_type%TYPE,
                              p_v_currency_cd       IN  igs_fi_control.currency_cd%TYPE,
                              p_n_waiver_amt        IN  igs_fi_inv_int_all.invoice_amount%TYPE,
                              p_d_gl_date           IN  igs_fi_invln_int.gl_date%TYPE,
                              p_n_invoice_id        OUT NOCOPY igs_fi_inv_int.invoice_id%TYPE,
                              x_return_status       OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      :   Umesh Udayaprakash
   Date Created By :   7/4/2005
   Purpose         :   invoked within the waiver processing routine, public Waiver API
                       and waiver application routine for creating waiver adjustment transactions.
                       Created as part of FI234 - Tuition Waivers enh. Bug # 3392095
   Known limitations,enhancements,remarks:
   Change History
   Who        When         What
   ******************************************************************/
    --Cursor for retreving the Description
    CURSOR cur_fee_type_desc(cp_v_fee_type   igs_fi_fee_type.fee_type%TYPE,
                             cp_closed_ind igs_fi_fee_type.closed_ind%TYPE) IS
      SELECT description
      FROM  igs_fi_fee_type_all
      WHERE fee_type = cp_v_fee_type
      AND closed_ind = cp_closed_ind;

    l_rec_chg_header        igs_fi_charges_api_pvt.header_rec_type;
    l_rec_chg_line_tbl      igs_fi_charges_api_pvt.line_tbl_type;
    l_rec_chg_line_id_tbl   igs_fi_charges_api_pvt.line_id_tbl_type;
    l_cur_fee_type_desc cur_fee_type_desc%ROWTYPE;
    l_n_msg_count           NUMBER      := 0;
    l_v_msg_data            VARCHAR2(4000) := NULL;
    l_n_waiver_amount       NUMBER;
    l_msg VARCHAR2(2000);
  BEGIN
    /**
     Check For Required parameters.
    */
    IF ( p_n_person_id IS NULL OR p_v_fee_cal_type IS NULL OR p_n_fee_ci_seq_number  IS NULL OR
         p_v_waiver_name IS NULL OR p_v_adj_fee_type IS NULL OR p_v_currency_cd IS NULL OR
         p_n_waiver_amt  IS NULL OR p_d_gl_date IS NULL) THEN
          x_return_status :='E';
          return;
    END IF;
    /**
      Logging of all the Input Parameters
    */
    log_to_fnd(p_v_module  => 'call_charges_api',
               p_v_string  => 'Person Id ' || p_n_person_id);
    log_to_fnd(p_v_module  => 'call_charges_api',
               p_v_string  => 'Fee cal Type ' || p_v_fee_cal_type);
    log_to_fnd(p_v_module  => 'call_charges_api',
               p_v_string  => 'Fee Sequence Number ' || p_n_fee_ci_seq_number);
    log_to_fnd(p_v_module  => 'call_charges_api',
               p_v_string  => 'Waiver Name ' || p_v_waiver_name);
    log_to_fnd(p_v_module  => 'call_charges_api',
               p_v_string  => 'Adjustment Fee Type ' || p_v_adj_fee_type);
    log_to_fnd(p_v_module  => 'call_charges_api',
               p_v_string  => 'Currency Code ' ||p_v_currency_cd);
    log_to_fnd(p_v_module  => 'call_charges_api',
               p_v_string  => 'Waiver Amount ' || p_n_waiver_amt);
    log_to_fnd(p_v_module  => 'call_charges_api',
               p_v_string  => 'Gl Date ' || p_d_gl_date);

    OPEN cur_fee_type_desc(cp_v_fee_type => p_v_adj_fee_type,
                           cp_closed_ind => 'N');
    FETCH cur_fee_type_desc INTO l_cur_fee_type_desc;


    --Check whether there exists a feetype in the igs_fi_fee_type_all table.
    IF cur_fee_type_desc%NOTFOUND THEN
      CLOSE cur_fee_type_desc;
      x_return_status :='E';
      RETURN;
    END IF;

    CLOSE cur_fee_type_desc;

    l_rec_chg_header.p_person_id := p_n_person_id;
    l_rec_chg_header.p_fee_type := p_v_adj_fee_type;
    l_rec_chg_header.p_fee_cat := NULL;
    l_rec_chg_header.p_fee_cal_type := p_v_fee_cal_type;
    l_rec_chg_header.p_fee_ci_sequence_number := p_n_fee_ci_seq_number;
    l_rec_chg_header.p_course_cd := NULL;
    l_rec_chg_header.p_attendance_type := NULL;
    l_rec_chg_header.p_attendance_mode := NULL;
    l_rec_chg_header.p_invoice_amount := ABS(p_n_waiver_amt);
    l_rec_chg_header.p_invoice_creation_date := TRUNC(SYSDATE);
    l_rec_chg_header.p_invoice_desc := l_cur_fee_type_desc.description;
    l_rec_chg_header.p_transaction_type :=  'WAIVER_ADJ';
    l_rec_chg_header.p_currency_cd := p_v_currency_cd;
    l_rec_chg_header.p_exchange_rate := 1;
    l_rec_chg_header.p_effective_date := TRUNC(SYSDATE);
    l_rec_chg_header.p_waiver_flag := NULL;
    l_rec_chg_header.p_waiver_reason := NULL;
    l_rec_chg_header.p_source_transaction_id := NULL;
    l_rec_chg_header.p_waiver_name := p_v_waiver_name;

    l_rec_chg_line_tbl(1).p_s_chg_method_type    := NULL;
    l_rec_chg_line_tbl(1).p_description          := l_cur_fee_type_desc.description;
    l_rec_chg_line_tbl(1).p_chg_elements         := NULL;
    l_rec_chg_line_tbl(1).p_amount               := ABS(p_n_waiver_amt);
    l_rec_chg_line_tbl(1).p_unit_attempt_status  := NULL;
    l_rec_chg_line_tbl(1).p_eftsu                := NULL;
    l_rec_chg_line_tbl(1).p_credit_points        := NULL;
    l_rec_chg_line_tbl(1).p_org_unit_cd          := NULL;
    l_rec_chg_line_tbl(1).p_attribute_category   := NULL;
    l_rec_chg_line_tbl(1).p_attribute1           := NULL;
    l_rec_chg_line_tbl(1).p_attribute2           := NULL;
    l_rec_chg_line_tbl(1).p_attribute3           := NULL;
    l_rec_chg_line_tbl(1).p_attribute4           := NULL;
    l_rec_chg_line_tbl(1).p_attribute5           := NULL;
    l_rec_chg_line_tbl(1).p_attribute6           := NULL;
    l_rec_chg_line_tbl(1).p_attribute7           := NULL;
    l_rec_chg_line_tbl(1).p_attribute8           := NULL;
    l_rec_chg_line_tbl(1).p_attribute9           := NULL;
    l_rec_chg_line_tbl(1).p_attribute10          := NULL;
    l_rec_chg_line_tbl(1).p_attribute11          := NULL;
    l_rec_chg_line_tbl(1).p_attribute12          := NULL;
    l_rec_chg_line_tbl(1).p_attribute13          := NULL;
    l_rec_chg_line_tbl(1).p_attribute14          := NULL;
    l_rec_chg_line_tbl(1).p_attribute15          := NULL;
    l_rec_chg_line_tbl(1).p_attribute16          := NULL;
    l_rec_chg_line_tbl(1).p_attribute17          := NULL;
    l_rec_chg_line_tbl(1).p_attribute18          := NULL;
    l_rec_chg_line_tbl(1).p_attribute19          := NULL;
    l_rec_chg_line_tbl(1).p_attribute20          := NULL;
    l_rec_chg_line_tbl(1).p_location_cd          := NULL;
    l_rec_chg_line_tbl(1).p_uoo_id               := NULL;
    l_rec_chg_line_tbl(1).p_d_gl_date            := p_d_gl_date;
    l_rec_chg_line_tbl(1).p_residency_status_cd  := NULL;

    log_to_fnd(p_v_module  => 'call_charges_api',
               p_v_string  => 'Before Calling the Create Charges Api');

    --Call Out ot the Create Charges methos to Create Charge.
    igs_fi_charges_api_pvt.create_charge(p_api_version      => 2.0,
                                         p_init_msg_list    => FND_API.G_FALSE,
                                         p_commit           => FND_API.G_FALSE,
                                         p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                                         p_header_rec       => l_rec_chg_header,
                                         p_line_tbl         => l_rec_chg_line_tbl,
                                         x_invoice_id       => p_n_invoice_id,
                                         x_line_id_tbl      => l_rec_chg_line_id_tbl,
                                         x_return_status    => x_return_status,
                                         x_msg_count        => l_n_msg_count,
                                         x_msg_data         => l_v_msg_data,
                                         x_waiver_amount    => l_n_waiver_amount);
    log_to_fnd(p_v_module  => 'value of x_return_status',
               p_v_string  => 'After Calling the Create Charges Api'|| x_return_status );

    IF x_return_status <> 'S' then
      x_return_status := 'E';
      IF l_n_msg_count = 1 THEN
        fnd_message.set_encoded(l_v_msg_data);
        log_to_fnd(p_v_module  => 'call_charges_api',
                   p_v_string  => 'Error Message ' || fnd_message.get);
      ELSE
        FOR l_count IN 1 .. l_n_msg_count LOOP
          l_msg := fnd_msg_pub.get(p_msg_index => l_count, p_encoded => 'T');
          fnd_message.set_encoded(l_msg);
          log_to_fnd(p_v_module  => 'call_charges_api',
                     p_v_string  => 'Error Message ' || fnd_message.get);
        END LOOP;
      END IF;
    ELSE
      log_to_fnd(p_v_module  => 'call_charges_api',
                 p_v_string  => 'Invoice Id ' || p_n_invoice_id);
    END IF;
  END  call_charges_api;

  PROCEDURE call_credits_api(p_n_person_id         IN hz_parties.party_id%TYPE,
                             p_v_fee_cal_type      IN igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                             p_n_fee_ci_seq_number IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                             p_v_waiver_name       IN igs_fi_waiver_pgms.waiver_name%TYPE,
                             p_n_credit_type_id    IN igs_fi_credits.credit_id%TYPE,
                             p_v_currency_cd       IN igs_fi_control.currency_cd%TYPE,
                             p_n_waiver_amt        IN NUMBER,
                             p_d_gl_date           IN igs_fi_invln_int.gl_date%TYPE,
                             p_n_credit_id         OUT NOCOPY NUMBER,
                             x_return_status       OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      :   Umesh Udayaprakash
   Date Created By :   7/4/2005
   Purpose         :   Invoked within the waiver processing routine for creating
                       waiver credit transactions.
                       Created as part of FI234 - Tuition Waivers enh. Bug # 3392095
   Known limitations,enhancements,remarks:
   Change History
   Who        When         What
   ******************************************************************/
  -- Cursor for selecting the credit type Description for the Credit id passed.
    CURSOR cur_credit_type_desc(cp_n_credit_type_id   NUMBER ) IS
      SELECT crtyp.description
      FROM igs_fi_cr_types crtyp
      WHERE credit_type_id = cp_n_credit_type_id;

    l_v_credit_class igs_fi_cr_types_all.credit_class%TYPE;
    l_b_return_status BOOLEAN;
    l_b_validation_flag BOOLEAN;
    l_v_msg_name            VARCHAR2(4000) := NULL;
    l_n_msg_count           NUMBER      := 0;
    l_v_msg_data            VARCHAR2(4000) := NULL;
    l_n_credit_activity_id  igs_fi_cr_activities.credit_activity_id%TYPE;
    l_n_credit_number  igs_fi_credits_all.credit_number%TYPE;
    l_cur_credit_type_desc cur_credit_type_desc%ROWTYPE;
    l_credit_rec_type igs_fi_credit_pvt.credit_rec_type;
    l_attribute_rec_type igs_fi_credits_api_pub.attribute_rec_type;
    l_msg VARCHAR2(2000);
  BEGIN

    IF ( p_n_person_id IS NULL OR p_v_fee_cal_type IS NULL OR p_n_fee_ci_seq_number IS NULL OR
         p_v_waiver_name IS NULL OR p_n_credit_type_id IS NULL OR p_v_currency_cd IS NULL OR
         p_n_waiver_amt  IS NULL OR p_d_gl_date IS NULL ) THEN
      x_return_status :='E';
      RETURN;
    END IF;
    /**
      Logging of all the Input Parameters
    */
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => 'Person Id ' || p_n_person_id);
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => ' Fee Calendar Type ' || p_v_fee_cal_type);
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => ' Fee Sequence Number ' || p_n_fee_ci_seq_number );
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => 'Waiver Name ' || p_v_waiver_name);
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => 'Credit Type Id ' || p_n_credit_type_id);
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => ' Currency Code ' || p_v_currency_cd);
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => 'Waiver Amount ' || p_n_waiver_amt);
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => 'Gl Date ' || p_d_gl_date);
    /**
      Call out to Check Whether the Credit Type is active as on the System Date.
    */
    igs_fi_crdapi_util.validate_credit_type(p_n_credit_type_id => p_n_credit_type_id,
                                            p_v_credit_class   =>l_v_credit_class,
                                            p_b_return_stat    =>l_b_return_status);
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => 'After the Call out to validate_credit_type Api');
    IF l_b_return_status = FALSE THEN
      x_return_status := 'E';
      RETURN;
    END IF;
    /**
      Call out to Check Whether the Credit class is Valid or not.
    */
    l_b_validation_flag := igs_fi_crdapi_util.validate_igs_lkp( p_v_lookup_type => 'IGS_FI_CREDIT_CLASS',
                                                                p_v_lookup_code => l_v_credit_class);
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => 'After the Call out to validate_igs_lkp Api for validating Credit class');
    IF l_b_validation_flag = FALSE THEN
      x_return_status := 'E';
      RETURN;
    END IF;
    /**
      Call out to Check Whether the Credit Instrument is Valid or not.
    */
    l_b_validation_flag := igs_fi_crdapi_util.validate_igs_lkp( p_v_lookup_type => 'IGS_FI_CREDIT_INSTRUMENT',
                                                                p_v_lookup_code => 'WAIVER');
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => 'After the Call out to validate_igs_lkp Api for validating Credit Instrument');

    IF l_b_validation_flag = FALSE THEN
       x_return_status := 'E';
       RETURN;
    END IF;
    /**
      Call out to Check Whether the Waiver Amount passed is Valid or not.
    */
    igs_fi_crdapi_util.validate_amount( p_n_amount => p_n_waiver_amt,
                                        p_b_return_status => l_b_validation_flag,
                                        p_v_message_name => l_v_msg_name);
    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => 'After the Call out to validate_amount Api for validating Waiver Amount');
    IF l_b_validation_flag = FALSE THEN
       fnd_message.set_name('IGS',l_v_msg_name);
       log_to_fnd(p_v_module  => 'call_credits_api',
                  p_v_string  => 'Message Returned from validate_amount Api ' || fnd_message.get);
       x_return_status := 'E';
       RETURN;
    END IF;

    OPEN cur_credit_type_desc(p_n_credit_type_id);
    FETCH cur_credit_type_desc INTO l_cur_credit_type_desc;
    CLOSE cur_credit_type_desc;

    l_credit_rec_type.p_credit_status               :='CLEARED';
    l_credit_rec_type.p_credit_source               := NULL;
    l_credit_rec_type.p_party_id                    := p_n_person_id;
    l_credit_rec_type.p_credit_type_id              := p_n_credit_type_id;
    l_credit_rec_type.p_credit_instrument           := 'WAIVER';
    l_credit_rec_type.p_description                 := l_cur_credit_type_desc.description;
    l_credit_rec_type.p_amount                      := p_n_waiver_amt;
    l_credit_rec_type.p_currency_cd                 := p_v_currency_cd;
    l_credit_rec_type.p_exchange_rate               := 1;
    l_credit_rec_type.p_transaction_date            := TRUNC(SYSDATE);
    l_credit_rec_type.p_effective_date              := TRUNC(SYSDATE);
    l_credit_rec_type.p_source_transaction_id       := NULL;
    l_credit_rec_type.p_receipt_lockbox_number      := NULL;
    l_credit_rec_type.p_credit_card_code            := NULL;
    l_credit_rec_type.p_credit_card_holder_name     := NULL;
    l_credit_rec_type.p_credit_card_number          := NULL;
    l_credit_rec_type.p_credit_card_expiration_date := NULL;
    l_credit_rec_type.p_credit_card_approval_code   := NULL;
    l_credit_rec_type.p_invoice_id                  := NULL;
    l_credit_rec_type.p_awd_yr_cal_type             := NULL;
    l_credit_rec_type.p_awd_yr_ci_sequence_number   := NULL;
    l_credit_rec_type.p_fee_cal_type                := p_v_fee_cal_type;
    l_credit_rec_type.p_fee_ci_sequence_number      := p_n_fee_ci_seq_number;
    l_credit_rec_type.p_check_number                := NULL;
    l_credit_rec_type.p_source_tran_type            := NULL;
    l_credit_rec_type.p_source_tran_ref_number      := NULL;
    l_credit_rec_type.p_gl_date                     := p_d_gl_date;
    l_credit_rec_type.p_v_credit_card_payee_cd      := NULL;
    l_credit_rec_type.p_v_credit_card_status_code   := NULL;
    l_credit_rec_type.p_v_credit_card_tangible_cd   := NULL;
    l_credit_rec_type.p_lockbox_interface_id        := NULL;
    l_credit_rec_type.p_batch_name                  := NULL;
    l_credit_rec_type.p_deposit_date                := NULL;
    l_credit_rec_type.p_waiver_name                 := p_v_waiver_name;

    l_attribute_rec_type.p_attribute_category := NULL;
    l_attribute_rec_type.p_attribute1         := NULL;
    l_attribute_rec_type.p_attribute2         := NULL;
    l_attribute_rec_type.p_attribute3         := NULL;
    l_attribute_rec_type.p_attribute4         := NULL;
    l_attribute_rec_type.p_attribute5         := NULL;
    l_attribute_rec_type.p_attribute6         := NULL;
    l_attribute_rec_type.p_attribute7         := NULL;
    l_attribute_rec_type.p_attribute8         := NULL;
    l_attribute_rec_type.p_attribute9         := NULL;
    l_attribute_rec_type.p_attribute10        := NULL;
    l_attribute_rec_type.p_attribute11        := NULL;
    l_attribute_rec_type.p_attribute12        := NULL;
    l_attribute_rec_type.p_attribute13        := NULL;
    l_attribute_rec_type.p_attribute14        := NULL;
    l_attribute_rec_type.p_attribute15        := NULL;
    l_attribute_rec_type.p_attribute16        := NULL;
    l_attribute_rec_type.p_attribute17        := NULL;
    l_attribute_rec_type.p_attribute18        := NULL;
    l_attribute_rec_type.p_attribute19        := NULL;
    l_attribute_rec_type.p_attribute20        := NULL;

    log_to_fnd(p_v_module  => 'call_credits_api',
               p_v_string  => 'Before the Callout to the igs_fi_credit_pvt.create_credit Api');
    --Call Out to Create waiver credits
    igs_fi_credit_pvt.create_credit(p_api_version         => 2.1,
                                    p_init_msg_list       => FND_API.G_FALSE,
                                    p_commit              => FND_API.G_FALSE,
                                    p_validation_level    => FND_API.G_VALID_LEVEL_NONE,
                                    x_return_status       => x_return_status,
                                    x_msg_count           => l_n_msg_count,
                                    x_msg_data            => l_v_msg_data,
                                    p_credit_rec          => l_credit_rec_type,
                                    p_attribute_record    => l_attribute_rec_type,
                                    x_credit_id           => p_n_credit_id,
                                    x_credit_activity_id  => l_n_credit_activity_id,
                                    x_credit_number       => l_n_credit_number);
    IF x_return_status <> 'S' then
       x_return_status := 'E';
      --Code to Loop accross the message and Log It
      IF l_n_msg_count = 1 THEN
        fnd_message.set_encoded(l_v_msg_data);
        log_to_fnd(p_v_module  => 'call_credits_api',
                   p_v_string  => 'Error Message ' || fnd_message.get);
      ELSE
        FOR l_count IN 1 .. l_n_msg_count LOOP
          l_msg := fnd_msg_pub.get(p_msg_index => l_count, p_encoded => 'T');
          fnd_message.set_encoded(l_msg);
          log_to_fnd(p_v_module  => 'call_credits_api',
                     p_v_string  => 'Error Message ' || fnd_message.get);
        END LOOP;
      END IF;
    ELSE
      log_to_fnd(p_v_module  => 'call_credits_api',
                 p_v_string  => 'Credit Id ' || p_n_credit_id );
    END IF;
  END  call_credits_api;

  PROCEDURE reverse_waiver(p_n_source_credit_id  IN igs_fi_applications.credit_id%TYPE,
                           p_v_reversal_reason   IN igs_lookup_values.lookup_code%TYPE,
                           p_v_reversal_comments IN igs_fi_credits_all.reversal_comments%TYPE,
                           p_d_reversal_gl_date  IN DATE,
                           p_v_return_status     OUT NOCOPY VARCHAR2,
                           p_v_message_name      OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      :   Umesh Udayaprakash
   Date Created By :   7/4/2005
   Purpose         :   procedure Used in Reverse transaction Self service Page.
                       Created as part of FI234 - Tuition Waivers enh. Bug # 3392095
   Known limitations,enhancements,remarks:
   Change History
   Who        When         What
   gurprsin  25-Oct-2005   Bug 4686711, Modified the cursor cur_appl_record definition.
   akandreg  20-Oct-2005   Bug 4677083, Modified the reverse_waiver function to
                           include the GL_DATE validation.
   ******************************************************************/
    --Cursor to Check whether the Waiver Credit Record Exists
    CURSOR cur_credit_rec_exists(cp_n_source_credit_id   NUMBER ) IS
      SELECT   crd.rowid,crd. *
      FROM     igs_fi_credits_all crd
      WHERE    crd.credit_id     = cp_n_source_credit_id;

    ----Cursor to Check whether any application Records exists for the Waiver Credit Transaction
    CURSOR cur_appl_record(cp_n_source_credit_id NUMBER) IS
      SELECT igs_fi_gen_007.get_sum_appl_amnt(appl.application_id) amount_applied,
             appl.application_id,
             appl.credit_id,
             appl.invoice_id
      FROM  igs_fi_applications appl,
            igs_fi_inv_int_all inv
      WHERE appl.credit_id    = cp_n_source_credit_id
      AND   appl.invoice_id     = inv.invoice_id
      AND   appl.application_type = 'APP'
      AND   inv.transaction_type <> 'WAIVER_ADJ'
--Added for the Bug 4686711, to exclude those charges for which unapp record exists in application table.
      AND NOT EXISTS (
          SELECT 'X'
          FROM   IGS_FI_APPLICATIONS APPL2
          WHERE  APPL2.APPLICATION_TYPE    = 'UNAPP'
          AND    APPL2.LINK_APPLICATION_ID = APPL.APPLICATION_ID
          AND    APPL2.AMOUNT_APPLIED      = - APPL.AMOUNT_APPLIED)
      ORDER BY appl.application_id;

    --Cursor to obtain the waiver program attributes.
    CURSOR cur_waiver_prg_attr(cp_fee_cal_type igs_fi_waiver_pgms.fee_cal_type%TYPE,
                               cp_fee_ci_sequence_number igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
                               cp_waiver_name igs_fi_waiver_pgms.waiver_name%TYPE) IS
      SELECT fwp.fee_cal_type,
             fwp.fee_ci_sequence_number,
             fwp.waiver_name,
             fwp.credit_type_id,
             fwp.target_fee_type,
             fwp.adjustment_fee_type
      FROM  igs_fi_waiver_pgms fwp
      WHERE fwp.fee_cal_type    = cp_fee_cal_type
      AND   fwp.fee_ci_sequence_number = cp_fee_ci_sequence_number
      AND   fwp.waiver_name = cp_waiver_name;


    l_v_conv_proc_ind igs_fi_control.conv_process_run_ind%TYPE;
    l_v_message_name fnd_new_messages.message_name%TYPE;
    l_v_meaning igs_lookup_values.meaning%TYPE;

    l_cur_credit_rec_exists cur_credit_rec_exists%ROWTYPE;
    l_cur_appl_record cur_appl_record%ROWTYPE;
    l_cur_waiver_prg_attr cur_waiver_prg_attr%ROWTYPE;

    l_n_application_id igs_fi_applications.application_id%TYPE;
    l_n_dr_gl_ccid     igs_fi_cr_activities.dr_gl_ccid%TYPE;
    l_n_cr_gl_ccid     igs_fi_cr_activities.cr_gl_ccid%TYPE;
    l_v_dr_account_cd  igs_fi_cr_activities.dr_account_cd%TYPE;
    l_v_cr_account_cd  igs_fi_cr_activities.cr_account_cd%TYPE;
    l_n_unapp_amount   igs_fi_credits_all.unapplied_amount%TYPE;
    l_n_inv_amt_due    igs_fi_inv_int_all.invoice_amount_due%TYPE;
    l_v_err_msg        fnd_new_messages.message_name%TYPE;
    l_b_status         BOOLEAN;
    l_n_wav_adj_amount NUMBER;
    l_n_unapplied_amount NUMBER;
    e_expected_error     EXCEPTION;

    l_v_currency_cd igs_fi_control_all.currency_cd%TYPE;
    l_v_curr_desc fnd_currencies_tl.name%TYPE;
    l_n_invoice_id igs_fi_inv_int.invoice_id%TYPE;

    l_v_closing_status VARCHAR2(1);

  BEGIN
    SAVEPOINT sp_reverse_waiver; -- Save point for the procedure to Rollout if any failure occurs.
    --Check For mandatory parameters
    IF ( p_n_source_credit_id IS NULL OR  p_v_reversal_reason IS NULL OR p_d_reversal_gl_date  IS NULL) THEN
      p_v_return_status := 'E';
      p_v_message_name := 'IGS_UC_NO_MANDATORY_PARAMS';
      RETURN;
    END IF;
    /**
      Logging of all the Input Parameters
    */
    log_to_fnd(p_v_module  => 'reverse_waiver',
               p_v_string  => 'Source Credit Id ' || p_n_source_credit_id );
    log_to_fnd(p_v_module  => 'reverse_waiver',
               p_v_string  => 'Reversal Reason ' || p_v_reversal_reason );
    log_to_fnd(p_v_module  => 'reverse_waiver',
               p_v_string  => 'Reversal Gl date ' || p_d_reversal_gl_date );

    --Check for the hold Conversion process is executed
    igs_fi_gen_007.finp_get_conv_prc_run_ind(p_n_conv_process_run_ind => l_v_conv_proc_ind ,
                                             p_v_message_name         => l_v_message_name);
    log_to_fnd(p_v_module  => 'reverse_waiver',
               p_v_string  => 'After the Callout to the finp_get_conv_prc_run_ind Api');

    IF l_v_conv_proc_ind = 1 AND l_v_message_name IS NULL THEN
      p_v_return_status := 'E';
      p_v_message_name := 'IGS_FI_REASS_BAL_PRC_RUN';
      RETURN;
    END IF;

    --Check whether the Waiver Credit Record Exists
    OPEN cur_credit_rec_exists(p_n_source_credit_id);
    FETCH cur_credit_rec_exists INTO l_cur_credit_rec_exists;

    IF cur_credit_rec_exists%NOTFOUND THEN
      CLOSE cur_credit_rec_exists;
      p_v_return_status := 'E';
      p_v_message_name := 'IGS_FI_WAV_SRC_CRD_INVALID';
      RETURN;
    END IF;
    CLOSE cur_credit_rec_exists;
    -- Check of Waiver Credit Status
    IF l_cur_credit_rec_exists.STATUS = 'REVERSED' THEN
      p_v_return_status := 'E';
      p_v_message_name := 'IGS_FI_WAV_SRC_CRD_REVERSED';
      RETURN;
    END IF;
    log_to_fnd(p_v_module  => 'reverse_waiver',
               p_v_string  => 'Completed the Validation of the Source Credit id and Status');

    --Bug 4677083, Modified the reverse_waiver function to include the GL_DATE validation.
    -- Check GL Date Status
    igs_fi_gen_gl.get_period_status_for_date(p_d_date => p_d_reversal_gl_date,
                                                         p_v_closing_status => l_v_closing_status,
                                                         p_v_message_name => l_v_message_name);
    IF l_v_message_name IS NOT NULL THEN
      log_to_fnd(p_v_module  => 'reverse_waiver',
                 p_v_string  => 'Validation Failed for GL date Status');
      p_v_return_status := 'E';
      p_v_message_name := l_v_message_name;
      RETURN;
    ELSIF l_v_closing_status NOT IN ('O','F') THEN
        log_to_fnd(p_v_module  => 'reverse_waiver',
                   p_v_string  => 'GL date is not in open or Future period');
        p_v_return_status := 'E';
        p_v_message_name := 'IGS_FI_INVALID_GL_DATE';
        RETURN;
    END IF;

    log_to_fnd(p_v_module  => 'reverse_waiver',
               p_v_string  => 'Completed successfully the Validation of GL date Status');

    l_v_meaning := igs_fi_gen_gl.get_lkp_meaning(p_v_lookup_type => 'IGS_FI_WAV_REVERSAL_REASON' ,
                                                 p_v_lookup_code => p_v_reversal_reason );
   -- Check for application Records  for the Waiver Credit Transaction
    FOR l_cur_appl_record IN cur_appl_record(cp_n_source_credit_id => p_n_source_credit_id)
    LOOP
      l_n_application_id := l_cur_appl_record.application_id;

      igs_fi_gen_007.create_application(p_application_id    => l_n_application_id,
                                        p_credit_id         => l_cur_appl_record.credit_id,
                                        p_invoice_id        => l_cur_appl_record.invoice_id,
                                        p_amount_apply      => l_cur_appl_record.amount_applied,
                                        p_appl_type         => 'UNAPP',
                                        p_appl_hierarchy_id => NULL,
                                        p_validation        => 'Y',
                                        p_dr_gl_ccid        => l_n_dr_gl_ccid,
                                        p_cr_gl_ccid        => l_n_cr_gl_ccid,
                                        p_dr_account_cd     => l_v_dr_account_cd,
                                        p_cr_account_cd     => l_v_cr_account_cd,
                                        p_unapp_amount      => l_n_unapplied_amount,
                                        p_inv_amt_due       => l_n_inv_amt_due,
                                        p_err_msg           => p_v_message_name,
                                        p_status            => l_b_status,
                                        p_d_gl_date         => p_d_reversal_gl_date);
      IF l_b_status = FALSE THEN

        fnd_message.set_name('IGS',p_v_message_name);
        log_to_fnd(p_v_module  => 'reverse_waiver',
                   p_v_string  => 'Existing with this Message from create_application Api ' || fnd_message.get);
        RAISE e_expected_error;
      END IF;
    END LOOP;
    -- retervie the Waiver program Attribute
    OPEN cur_waiver_prg_attr( cp_fee_cal_type =>l_cur_credit_rec_exists.fee_cal_type,
                              cp_fee_ci_sequence_number =>l_cur_credit_rec_exists.fee_ci_sequence_number,
                              cp_waiver_name =>l_cur_credit_rec_exists.waiver_name);

    FETCH cur_waiver_prg_attr INTO l_cur_waiver_prg_attr;
    CLOSE cur_waiver_prg_attr;
    -- Call out to Reterive the local Currency Setup
    igs_fi_gen_gl.finp_get_cur(p_v_currency_cd  => l_v_currency_cd,
                               p_v_curr_desc    => l_v_curr_desc,
                               p_v_message_name => l_v_message_name);
    IF l_v_message_name <> NULL THEN
      fnd_message.set_name('IGS',l_v_message_name);
      log_to_fnd(p_v_module  => 'reverse_waiver',
                 p_v_string  => 'Exiting After the call igs_fi_gen_gl.finp_get_cur ' || fnd_message.get);
      RAISE e_expected_error;
    END IF ;
    --call out to create a Waiver adjustment Charge
    IF l_n_unapplied_amount > 0 THEN

      log_to_fnd(p_v_module  => 'reverse_waiver',
                 p_v_string  => 'Before the Callout to call Charges Api method when the Un Applied Amount is > 0 ');
      call_charges_api(p_n_person_id          => l_cur_credit_rec_exists.party_id,
                       p_v_fee_cal_type       => l_cur_credit_rec_exists.fee_cal_type,
                       p_n_fee_ci_seq_number  => l_cur_credit_rec_exists.fee_ci_sequence_number,
                       p_v_waiver_name        => l_cur_waiver_prg_attr.waiver_name,
                       p_v_adj_fee_type       => l_cur_waiver_prg_attr.adjustment_fee_type,
                       p_v_currency_cd        => l_v_currency_cd,
                       p_n_waiver_amt         => l_n_unapplied_amount,
                       p_d_gl_date            => p_d_reversal_gl_date,
                       p_n_invoice_id         => l_n_invoice_id,
                       x_return_status        => p_v_return_status);

      IF p_v_return_status <> 'S' THEN
        RAISE e_expected_error;
      END IF;
      log_to_fnd(p_v_module  => 'reverse_waiver',
                 p_v_string  => 'Before the Callout to igs_fi_gen_007.create_application');
        --Call out for applying the waiver adjustment Cahrge against the waiver credit
      l_n_application_id := null;
      igs_fi_gen_007.create_application(p_application_id    => l_n_application_id,
                                        p_credit_id         => p_n_source_credit_id,
                                        p_invoice_id        => l_n_invoice_id,
                                        p_amount_apply      => l_n_unapplied_amount,
                                        p_appl_type         => 'APP',
                                        p_appl_hierarchy_id => NULL,
                                        p_validation        => 'Y',
                                        p_dr_gl_ccid        => l_n_dr_gl_ccid,
                                        p_cr_gl_ccid        => l_n_cr_gl_ccid,
                                        p_dr_account_cd     => l_v_dr_account_cd,
                                        p_cr_account_cd     => l_v_cr_account_cd,
                                        p_unapp_amount      => l_n_unapp_amount,
                                        p_inv_amt_due       => l_n_inv_amt_due,
                                        p_err_msg           => p_v_message_name,
                                        p_status            => l_b_status,
                                        p_d_gl_date         => p_d_reversal_gl_date);
      IF l_b_status = FALSE THEN
        fnd_message.set_name('IGS',p_v_message_name);
        log_to_fnd(p_v_module  => 'reverse_waiver',
                   p_v_string  => 'Exiting After the call igs_fi_gen_007.create_application ' || fnd_message.get);
        RAISE e_expected_error;
      END IF;
      log_to_fnd(p_v_module  => 'reverse_waiver',
                 p_v_string  => 'Before the Callout to update the Credit api Table');
      --Call out to update the credit status to Reversed.
      igs_fi_credits_pkg.update_row(x_rowid                       => l_cur_credit_rec_exists.rowid,
                                    x_credit_id                   => l_cur_credit_rec_exists.credit_id,
                                    x_credit_number               => l_cur_credit_rec_exists.credit_number,
                                    x_status                      => 'REVERSED',
                                    x_credit_source               => l_cur_credit_rec_exists.credit_source,
                                    x_party_id                    => l_cur_credit_rec_exists.party_id,
                                    x_credit_type_id              => l_cur_credit_rec_exists.credit_type_id,
                                    x_credit_instrument           => l_cur_credit_rec_exists.credit_instrument,
                                    x_description                 => l_cur_credit_rec_exists.description,
                                    x_amount                      => l_cur_credit_rec_exists.amount,
                                    x_currency_cd                 => l_cur_credit_rec_exists.currency_cd,
                                    x_exchange_rate               => l_cur_credit_rec_exists.exchange_rate,
                                    x_transaction_date            => l_cur_credit_rec_exists.transaction_date,
                                    x_effective_date              => l_cur_credit_rec_exists.effective_date,
                                    x_reversal_date               => TRUNC(SYSDATE),
                                    x_reversal_reason_code        => p_v_reversal_reason,
                                    x_reversal_comments           => p_v_reversal_comments,
                                    x_unapplied_amount            => l_cur_credit_rec_exists.unapplied_amount,
                                    x_source_transaction_id       => l_cur_credit_rec_exists.source_transaction_id,
                                    x_receipt_lockbox_number      => l_cur_credit_rec_exists.receipt_lockbox_number,
                                    x_merchant_id                 => l_cur_credit_rec_exists.merchant_id,
                                    x_credit_card_code            => l_cur_credit_rec_exists.credit_card_code,
                                    x_credit_card_holder_name     => l_cur_credit_rec_exists.credit_card_holder_name,
                                    x_credit_card_number          => l_cur_credit_rec_exists.credit_card_number,
                                    x_credit_card_expiration_date => l_cur_credit_rec_exists.credit_card_expiration_date,
                                    x_credit_card_approval_code   => l_cur_credit_rec_exists.credit_card_approval_code,
                                    x_awd_yr_cal_type             => l_cur_credit_rec_exists.awd_yr_cal_type,
                                    x_awd_yr_ci_sequence_number   => l_cur_credit_rec_exists.awd_yr_ci_sequence_number,
                                    x_fee_cal_type                => l_cur_credit_rec_exists.fee_cal_type,
                                    x_fee_ci_sequence_number      => l_cur_credit_rec_exists.fee_ci_sequence_number,
                                    x_attribute_category          => l_cur_credit_rec_exists.attribute_category,
                                    x_attribute1                  => l_cur_credit_rec_exists.attribute1,
                                    x_attribute2                  => l_cur_credit_rec_exists.attribute2,
                                    x_attribute3                  => l_cur_credit_rec_exists.attribute3,
                                    x_attribute4                  => l_cur_credit_rec_exists.attribute4,
                                    x_attribute5                  => l_cur_credit_rec_exists.attribute5,
                                    x_attribute6                  => l_cur_credit_rec_exists.attribute6,
                                    x_attribute7                  => l_cur_credit_rec_exists.attribute7,
                                    x_attribute8                  => l_cur_credit_rec_exists.attribute8,
                                    x_attribute9                  => l_cur_credit_rec_exists.attribute9,
                                    x_attribute10                 => l_cur_credit_rec_exists.attribute10,
                                    x_attribute11                 => l_cur_credit_rec_exists.attribute11,
                                    x_attribute12                 => l_cur_credit_rec_exists.attribute12,
                                    x_attribute13                 => l_cur_credit_rec_exists.attribute13,
                                    x_attribute14                 => l_cur_credit_rec_exists.attribute14,
                                    x_attribute15                 => l_cur_credit_rec_exists.attribute15,
                                    x_attribute16                 => l_cur_credit_rec_exists.attribute16,
                                    x_attribute17                 => l_cur_credit_rec_exists.attribute17,
                                    x_attribute18                 => l_cur_credit_rec_exists.attribute18,
                                    x_attribute19                 => l_cur_credit_rec_exists.attribute19,
                                    x_attribute20                 => l_cur_credit_rec_exists.attribute20,
                                    x_gl_date                     => l_cur_credit_rec_exists.gl_date,
                                    x_check_number                => l_cur_credit_rec_exists.check_number,
                                    x_source_transaction_type     => l_cur_credit_rec_exists.source_transaction_type,
                                    x_source_transaction_ref      => l_cur_credit_rec_exists.source_transaction_ref,
                                    x_credit_card_status_code     => l_cur_credit_rec_exists.credit_card_status_code,
                                    x_credit_card_payee_cd        => l_cur_credit_rec_exists.credit_card_payee_cd,
                                    x_credit_card_tangible_cd     => l_cur_credit_rec_exists.credit_card_tangible_cd,
                                    x_lockbox_interface_id        => l_cur_credit_rec_exists.lockbox_interface_id,
                                    x_batch_name                  => l_cur_credit_rec_exists.batch_name,
                                    x_deposit_date                => l_cur_credit_rec_exists.deposit_date,
                                    x_source_invoice_id           => l_cur_credit_rec_exists.source_invoice_id,
                                    x_tax_year_code               => l_cur_credit_rec_exists.tax_year_code,
                                    x_waiver_name                 => l_cur_credit_rec_exists.waiver_name
                                   );
    END IF; --End of the check for l_n_unapplied_amount > 0
    p_v_return_status :='S';
    EXCEPTION
      WHEN e_expected_error THEN
        ROLLBACK TO sp_reverse_waiver;
        p_v_message_name := 'IGS_FI_WAV_REVERSAL_FAIL';
        p_v_return_status := 'E';
      WHEN OTHERS THEN
        ROLLBACK TO sp_reverse_waiver;
        p_v_message_name := 'IGS_FI_WAV_REVERSAL_FAIL';
        p_v_return_status := 'E';
  END  reverse_waiver;


  FUNCTION get_waiver_reversal_amount(p_n_source_credit_id IN igs_fi_applications.credit_id%TYPE) RETURN NUMBER IS
    /******************************************************************
     Created By      :   Umesh Udayaprakash
     Date Created By :   7/4/2005
     Purpose         :   Function to return the waiver Reversal Amount.
                         Created as part of FI234 - Tuition Waivers enh. Bug # 3392095
     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     gurprsin  25-Oct-2005   Bug 4686711, Modified the cursor cur_waiver_credit_tran_exists definition.
     ******************************************************************/

    --Cursor to Check whether a waiver credit Record Exists
    CURSOR cur_credit_rec_exists(cp_n_source_credit_id   NUMBER ) IS
      SELECT   crd. *
      FROM     igs_fi_credits_all crd
      WHERE    crd.credit_id     = cp_n_source_credit_id;
    --Cursor to Check whether any application record exists for the waiver credit Transaction.
    CURSOR cur_waiver_credit_tran_exists(cp_n_source_credit_id   NUMBER ) IS
      SELECT igs_fi_gen_007.get_sum_appl_amnt(appl.application_id) amount_applied,
             appl.application_id,
             appl.credit_id,
             appl.invoice_id
      FROM     igs_fi_applications appl,
               igs_fi_inv_int_all inv
      WHERE    appl.credit_id    = cp_n_source_credit_id
      AND      appl.invoice_id     = inv.invoice_id
      AND      appl.application_type = 'APP'
      AND      inv.transaction_type <> 'WAIVER_ADJ'
--Added for the Bug 4686711, to exclude those charges for which unapp record exists in application table.
      AND      NOT EXISTS (
               SELECT 'X'
               FROM   IGS_FI_APPLICATIONS APPL2
               WHERE  APPL2.APPLICATION_TYPE    = 'UNAPP'
               AND    APPL2.LINK_APPLICATION_ID = APPL.APPLICATION_ID
               AND    APPL2.AMOUNT_APPLIED      = - APPL.AMOUNT_APPLIED)
      ORDER BY appl.application_id;

    l_cur_credit_rec_exists cur_credit_rec_exists%ROWTYPE;
    l_cur_wav_credit_tran_exists cur_waiver_credit_tran_exists%ROWTYPE;
    l_n_unapplied_amount NUMBER;

  BEGIN
    log_to_fnd(p_v_module  => 'get_waiver_reversal_amount',
               p_v_string  => 'Source Credit Id ' || p_n_source_credit_id);

    --Check for waiver credit record transaction
    OPEN cur_credit_rec_exists(cp_n_source_credit_id => p_n_source_credit_id);
    FETCH cur_credit_rec_exists INTO l_cur_credit_rec_exists;
    IF cur_credit_rec_exists%NOTFOUND THEN
      CLOSE cur_credit_rec_exists;
      RETURN 0;
    END IF; --End of check for the Cursor cur_credit_rec_exists
    CLOSE cur_credit_rec_exists;

    log_to_fnd(p_v_module  => 'get_waiver_reversal_amount',
               p_v_string  => 'After the Check whether the Credit Record Exists');

    --Check whether the Status of waiver credit is reversed if so return 0
    IF l_cur_credit_rec_exists.status = 'REVERSED' THEN
      RETURN 0;
    END IF;

    l_n_unapplied_amount := l_cur_credit_rec_exists.unapplied_amount;
    --Looping across the application record to sum the unapplied amount value for the waiver credit Transaction.
    FOR l_cur_wav_credit_tran_exists IN cur_waiver_credit_tran_exists( cp_n_source_credit_id => p_n_source_credit_id)
    LOOP
      l_n_unapplied_amount := l_n_unapplied_amount + NVL(l_cur_wav_credit_tran_exists.amount_applied,0);
    END LOOP;
    log_to_fnd(p_v_module  => 'get_waiver_reversal_amount',
               p_v_string  => 'Before returning the unapplied Amount value' || l_n_unapplied_amount);
    RETURN l_n_unapplied_amount;

  END  get_waiver_reversal_amount;

  FUNCTION check_stdnt_wav_assignment(p_n_person_id         IN hz_parties.party_id%TYPE,
                                      p_v_fee_type          IN igs_fi_f_typ_ca_inst.fee_type%TYPE,
                                      p_v_fee_cal_type      IN igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                      p_n_fee_ci_seq_number IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) RETURN BOOLEAN IS
    /******************************************************************
     Created By      :   Umesh Udayaprakash
     Date Created By :   7/4/2005
     Purpose         :   Invokes Charges API for creating a charge
                         Created as part of FI234 - Tuition Waivers enh. Bug # 3392095
     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     ******************************************************************/
    --Cursor to Check whether a waiver  Record Exists
    CURSOR cur_waiver_pgm_rec_exists(cp_v_fee_type           igs_fi_f_typ_ca_inst.fee_type%TYPE,
                                     cp_v_fee_cal_type       igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                     cp_n_fee_ci_seq_number  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
      SELECT   fwp.fee_cal_type,
               fwp.fee_ci_sequence_number,
               fwp.waiver_name,
               fwp.waiver_method_code
      FROM     igs_fi_waiver_pgms fwp
      WHERE    fwp.target_fee_type = cp_v_fee_type
      AND      fwp.fee_cal_type    = cp_v_fee_cal_type
      AND      fwp.fee_ci_sequence_number = cp_n_fee_ci_seq_number
      AND      fwp.waiver_method_code = 'COMP_RULE';
    --Cursor to Check whether student Assignment exists for waiver  Record
    CURSOR cur_wav_stud_assg_rec_exists(cp_n_person_id          hz_parties.party_id%TYPE,
                                           cp_v_waiver_name        igs_fi_waiver_pgms.waiver_name%TYPE,
                                           cp_v_fee_cal_type       igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                           cp_n_fee_ci_seq_number  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
      SELECT   fwsp.waiver_name,
               fwsp.person_id,
               fwsp.assignment_status_code
      FROM     igs_fi_wav_std_pgms fwsp
      WHERE    fwsp.fee_cal_type = cp_v_fee_cal_type
      AND      fwsp.fee_ci_sequence_number = cp_n_fee_ci_seq_number
      AND      fwsp.waiver_name = cp_v_waiver_name
      AND      fwsp.person_id = cp_n_person_id
      AND      fwsp.assignment_status_code = 'ACTIVE';

    l_cur_waiver_pgm_rec_exists cur_waiver_pgm_rec_exists%ROWTYPE;
    l_cur_wav_stud_assg_rec_exists cur_wav_stud_assg_rec_exists%ROWTYPE;
    l_b_return_flag BOOLEAN;
  BEGIN
    l_b_return_flag := FALSE;
    log_to_fnd(p_v_module  => 'check_stdnt_wav_assignment',
               p_v_string  => 'Before looping the IGS_FI_WAIVER_PGMS table for waiver programs');
    /**
      Logging of all the Input Parameters
    */
    log_to_fnd(p_v_module  => 'check_stdnt_wav_assignment',
               p_v_string  => 'Person Id ' || p_n_person_id);
    log_to_fnd(p_v_module  => 'check_stdnt_wav_assignment',
               p_v_string  => 'Fee Type ' || p_v_fee_type);
    log_to_fnd(p_v_module  => 'check_stdnt_wav_assignment',
               p_v_string  => 'Fee Calendar Type ' || p_v_fee_cal_type);
    log_to_fnd(p_v_module  => 'check_stdnt_wav_assignment',
               p_v_string  => 'Fee Sequence Number ' || p_n_fee_ci_seq_number);

    --Looping across the waiver programs for the feetyep,feecaltype and sequence number
    FOR l_cur_waiver_pgm_rec_exists IN cur_waiver_pgm_rec_exists ( cp_v_fee_type          => p_v_fee_type,
                                                                   cp_v_fee_cal_type      => p_v_fee_cal_type,
                                                                   cp_n_fee_ci_seq_number => p_n_fee_ci_seq_number)
    LOOP
      --if the waiver methos_code is not Comp_rule return from the function.
      IF l_cur_waiver_pgm_rec_exists.waiver_method_code <> 'COMP_RULE' THEN
        log_to_fnd(p_v_module  => 'check_stdnt_wav_assignment',
                   p_v_string  => 'Waiver Method Code While Existing ' || l_cur_waiver_pgm_rec_exists.waiver_method_code);
        l_b_return_flag := FALSE;
        EXIT;
      END IF;
      --Check whether the Student Waiver program Assignment is active if so return True from the function
      OPEN cur_wav_stud_assg_rec_exists( cp_n_person_id         => p_n_person_id,
                                         cp_v_waiver_name       => l_cur_waiver_pgm_rec_exists.waiver_name,
                                         cp_v_fee_cal_type      => p_v_fee_cal_type,
                                         cp_n_fee_ci_seq_number => p_n_fee_ci_seq_number);
      FETCH cur_wav_stud_assg_rec_exists INTO l_cur_wav_stud_assg_rec_exists;
      IF cur_wav_stud_assg_rec_exists%FOUND THEN
        l_b_return_flag := TRUE;
        CLOSE cur_wav_stud_assg_rec_exists;
        EXIT;
      END IF; -- END Of the check for the waiver student assignment cursor.
      CLOSE cur_wav_stud_assg_rec_exists;
    END LOOP;
    log_to_fnd(p_v_module  => 'check_stdnt_wav_assignment',
               p_v_string  => 'After the looping Logic to Find a Active Student Assignment');
    RETURN l_b_return_flag;
  END  check_stdnt_wav_assignment;


  FUNCTION check_fee_type(p_v_fee_type               IN    igs_fi_f_typ_ca_inst.fee_type%TYPE,
                          p_v_fee_cal_type           IN    igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                          p_n_dest_fee_ci_seq_number IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) RETURN BOOLEAN IS
    /******************************************************************
     Created By      :   Umesh Udayaprakash
     Date Created By :   7/4/2005
     Purpose         :   Function Used in the Rollover page to check whether the
                         Fee Type is valid or not.
                         Created as part of FI234 - Tuition Waivers enh. Bug # 3392095
     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     ******************************************************************/
    --Cursor to check whether the fee type records exists in the Destination Calendar passed.
    CURSOR cur_check_fee_type(cp_v_fee_type igs_fi_f_typ_ca_inst.fee_type%TYPE,
                              cp_v_fee_cal_type       igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                              cp_n_dest_fee_ci_seq_number igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
      SELECT 'X'
      FROM igs_fi_f_typ_ca_inst_all
      WHERE fee_type = cp_v_fee_type
      AND   fee_cal_type  = cp_v_fee_cal_type
      AND   fee_ci_sequence_number = cp_n_dest_fee_ci_seq_number;

      l_cur_check_fee_type cur_check_fee_type%ROWTYPE;

  BEGIN
    OPEN cur_check_fee_type(cp_v_fee_type     => p_v_fee_type,
                            cp_v_fee_cal_type => p_v_fee_cal_type,
                            cp_n_dest_fee_ci_seq_number => p_n_dest_fee_ci_seq_number);
    FETCH cur_check_fee_type INTO l_cur_check_fee_type;
    IF cur_check_fee_type%NOTFOUND THEN
      CLOSE cur_check_fee_type;
      RETURN FALSE;
    END IF;
    CLOSE cur_check_fee_type;
    RETURN TRUE;
  END check_fee_type;


  PROCEDURE roll_over_wav_assign(p_rollover_rowid                IN VARCHAR2,
                                 p_v_stud_rollover_flag          IN VARCHAR2,
                                 p_n_dest_fee_ci_seq_number      IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                                 p_v_rollover_status             OUT NOCOPY VARCHAR2) IS
    /******************************************************************
     Created By      :   Umesh Udayaprakash
     Date Created By :   7/4/2005
     Purpose         :   Procedure for rolling the Waiver program and Student assignment.
                         Created as part of FI234 - Tuition Waivers enh. Bug # 3392095
     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     ******************************************************************/
    --Cursor to select the waiver program to be rolled over
    CURSOR cur_waiver_pgms (cp_rollover_rowid VARCHAR2) IS
      SELECT pgms.*
      FROM igs_fi_waiver_pgms pgms
      WHERE pgms.rowid = cp_rollover_rowid;

    --Cursor to select the prereq waiver programs of the waiver program to be rolled over.
    CURSOR cur_pre_req_wav_programs(cp_v_waiver_name igs_fi_wav_pr_preqs.sub_waiver_name%TYPE,
                                    cp_v_fee_cal_type igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                    cp_n_fee_ci_sequence_number igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
      SELECT sup_waiver_name,
        sub_waiver_name,
        fee_cal_type,
        fee_ci_sequence_number
      FROM igs_fi_wav_pr_preqs
      WHERE sub_waiver_name = cp_v_waiver_name
      AND   fee_cal_type = cp_v_fee_cal_type
      AND   fee_ci_sequence_number = cp_n_fee_ci_sequence_number;
    --Cursor to Check whether the prereq program already exists in the destincation calendar
    CURSOR cur_prereq_wav_prgms_exist(cp_v_waiver_name igs_fi_wav_pr_preqs.sub_waiver_name%TYPE,
                                         cp_v_fee_cal_type igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                         cp_n_fee_ci_sequence_number igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
      SELECT 'x'
      FROM igs_fi_waiver_pgms
      WHERE waiver_name = cp_v_waiver_name
      AND   fee_cal_type = cp_v_fee_cal_type
      AND   fee_ci_sequence_number = cp_n_fee_ci_sequence_number;

    --Cursor to select the Student waiver Assignment for Rolling over.
    CURSOR cur_stud_waiver_assign(cp_v_waiver_name igs_fi_wav_pr_preqs.sub_waiver_name%TYPE,
                                  cp_v_fee_cal_type igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                  cp_n_fee_ci_sequence_number igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
      SELECT stuwavpgm.*
      FROM  igs_fi_wav_std_pgms stuwavpgm
      WHERE stuwavpgm.fee_cal_type = cp_v_fee_cal_type
      AND   stuwavpgm.fee_ci_sequence_number = cp_n_fee_ci_sequence_number
      AND   stuwavpgm.waiver_name = cp_v_waiver_name
      AND   stuwavpgm.assignment_status_code ='ACTIVE';

    l_cur_waiver_pgms cur_waiver_pgms%ROWTYPE;
    l_cur_pre_req_wav_programs cur_pre_req_wav_programs%ROWTYPE;
    l_cur_prereq_wav_prgms_exist cur_prereq_wav_prgms_exist%ROWTYPE;
    l_cur_stud_waiver_assign cur_stud_waiver_assign%ROWTYPE;
    l_waiver_relation_id igs_fi_wav_pr_preqs.waiver_relation_id%TYPE;
    l_waiver_student_id igs_fi_wav_std_pgms.waiver_student_id%TYPE;
    l_waiver_pgm_found_flag BOOLEAN;
    e_expected_error         EXCEPTION;
    l_rowid ROWID;

  BEGIN
    SAVEPOINT sp_roll_over_waiver;
    l_waiver_pgm_found_flag := FALSE;
    /**
      Logging of all the Input Parameters
    */
    log_to_fnd(p_v_module  => 'roll_over_wav_assign',
               p_v_string  => 'Rollover RowId ' || p_rollover_rowid);
    log_to_fnd(p_v_module  => 'roll_over_wav_assign',
               p_v_string  => 'Student Rollover Flag ' || p_v_stud_rollover_flag);
    log_to_fnd(p_v_module  => 'roll_over_wav_assign',
               p_v_string  => 'Destination Fee Sequence Number ' || p_n_dest_fee_ci_seq_number);

    --Select the Waiver program data to be rolled over
    OPEN cur_waiver_pgms( cp_rollover_rowid => p_rollover_rowid);
    FETCH cur_waiver_pgms INTO l_cur_waiver_pgms;

    IF cur_waiver_pgms%NOTFOUND THEN
      CLOSE cur_waiver_pgms;
      RAISE e_expected_error;
    END IF;
    CLOSE cur_waiver_pgms;
    log_to_fnd(p_v_module  => 'roll_over_wav_assign',
               p_v_string  => 'After selecting the Waiver Program for Rollover');
    --Check whether the Adjustment fee Type is already rolled over to the destination calendar
    IF l_cur_waiver_pgms.adjustment_fee_type IS NOT NULL THEN
      IF NOT check_fee_type(p_v_fee_type                    => l_cur_waiver_pgms.adjustment_fee_type,
                            p_v_fee_cal_type                => l_cur_waiver_pgms.fee_cal_type,
                            p_n_dest_fee_ci_seq_number      => p_n_dest_fee_ci_seq_number)  THEN
        RAISE e_expected_error;
      END IF;
    END IF;
    --Check whether the target fee Type is already rolled over to the destination calendar
    IF l_cur_waiver_pgms.target_fee_type IS NOT NULL THEN
      IF NOT check_fee_type(p_v_fee_type                    => l_cur_waiver_pgms.target_fee_type,
                            p_v_fee_cal_type                => l_cur_waiver_pgms.fee_cal_type,
                            p_n_dest_fee_ci_seq_number      => p_n_dest_fee_ci_seq_number)  THEN
        RAISE e_expected_error;
      END IF;
    END IF;
    --Check whether the rule fee type is already rolled over to the destination calendar
    IF (l_cur_waiver_pgms.rule_fee_type IS NOT NULL AND l_cur_waiver_pgms.waiver_method_code = 'COMP_RULE') THEN
      IF NOT check_fee_type(p_v_fee_type                    => l_cur_waiver_pgms.rule_fee_type,
                            p_v_fee_cal_type                => l_cur_waiver_pgms.fee_cal_type,
                            p_n_dest_fee_ci_seq_number      => p_n_dest_fee_ci_seq_number)  THEN
        RAISE e_expected_error;
      END IF;
    END IF;
    log_to_fnd(p_v_module  => 'roll_over_wav_assign',
               p_v_string  => 'After The Check for the Fee Types Validation');
    --Rollover the waiver program to the destination calendar.
    l_rowid := null;
    igs_fi_waiver_pgms_pkg.insert_row(x_rowid                   => l_rowid,
                                      x_fee_cal_type            => l_cur_waiver_pgms.fee_cal_type,
                                      x_fee_ci_sequence_number  => p_n_dest_fee_ci_seq_number,
                                      x_waiver_name             => l_cur_waiver_pgms.waiver_name,
                                      x_waiver_desc             => l_cur_waiver_pgms.waiver_desc,
                                      x_waiver_status_code      => l_cur_waiver_pgms.waiver_status_code,
                                      x_credit_type_id          => l_cur_waiver_pgms.credit_type_id,
                                      x_adjustment_fee_type     => l_cur_waiver_pgms.adjustment_fee_type,
                                      x_target_fee_type         => l_cur_waiver_pgms.target_fee_type,
                                      x_waiver_method_code      => l_cur_waiver_pgms.waiver_method_code,
                                      x_waiver_mode_code        => l_cur_waiver_pgms.waiver_mode_code,
                                      x_waiver_criteria_code    => l_cur_waiver_pgms.waiver_criteria_code,
                                      x_waiver_percent_alloc    => l_cur_waiver_pgms.waiver_percent_alloc,
                                      x_rule_fee_type           => l_cur_waiver_pgms.rule_fee_type);
    log_to_fnd(p_v_module  => 'roll_over_wav_assign',
               p_v_string  => 'Before the Validation of Pre Requisite Waiver Programs');
    --Code logic to identify and Rollover the Pre waiver programs
    FOR l_cur_pre_req_wav_programs IN cur_pre_req_wav_programs(cp_v_waiver_name            =>l_cur_waiver_pgms.waiver_name,
                                                               cp_v_fee_cal_type           =>l_cur_waiver_pgms.fee_cal_type,
                                                               cp_n_fee_ci_sequence_number =>l_cur_waiver_pgms.fee_ci_sequence_number)
    LOOP
      --Check whether the pre req waiver program has been rolled over to the Destination Fee calendar.
      OPEN cur_prereq_wav_prgms_exist(   cp_v_waiver_name               =>l_cur_pre_req_wav_programs.sup_waiver_name,
                                         cp_v_fee_cal_type             =>l_cur_pre_req_wav_programs.fee_cal_type,
                                         cp_n_fee_ci_sequence_number   =>p_n_dest_fee_ci_seq_number );

      FETCH cur_prereq_wav_prgms_exist INTO l_cur_prereq_wav_prgms_exist;
      --If the pre req waiver program has not been rolled over to the Destination Fee calendar stop further processing after Raising the Exception.
      IF cur_prereq_wav_prgms_exist%NOTFOUND THEN
        log_to_fnd(p_v_module  => 'roll_over_wav_assign',
                   p_v_string  => 'Identified preqWaiverprogram not been Rolled over to the Destination Calendar' || l_cur_pre_req_wav_programs.sup_waiver_name);
        CLOSE cur_prereq_wav_prgms_exist;
        RAISE e_expected_error;
      END IF;
      CLOSE cur_prereq_wav_prgms_exist;
        l_rowid := NULL;
        l_waiver_relation_id := NULL;
        --Insert the PRe req Waiver program to the destination calendar in the waiver pre req table.
        igs_fi_wav_pr_preqs_pkg.insert_row(x_rowid                   =>  l_rowid,
                                           x_waiver_relation_id      =>  l_waiver_relation_id,
                                           x_fee_cal_type            =>  l_cur_pre_req_wav_programs.fee_cal_type,
                                           x_fee_ci_sequence_number  =>  p_n_dest_fee_ci_seq_number,
                                           x_sup_waiver_name         =>  l_cur_pre_req_wav_programs.sup_waiver_name,
                                           x_sub_waiver_name         =>  l_cur_pre_req_wav_programs.sub_waiver_name,
                                           x_mode => 'R');

    END LOOP;

    log_to_fnd(p_v_module  => 'roll_over_wav_assign',
               p_v_string  => 'After the Validation of Pre Requisite Waiver Programs');
    --Check whether the student Asssignment Rollover has been selected.
    IF p_v_stud_rollover_flag = 'Y' THEN

      log_to_fnd(p_v_module  => 'roll_over_wav_assign',
                 p_v_string  => 'Before Rolling over the Student Waiver Assignment' || l_cur_waiver_pgms.waiver_name);
      --Loop to identify the Active student assignments for the waiver program
      FOR l_cur_stud_waiver_assign IN cur_stud_waiver_assign(cp_v_waiver_name              => l_cur_waiver_pgms.waiver_name,
                                                             cp_v_fee_cal_type             => l_cur_waiver_pgms.fee_cal_type,
                                                             cp_n_fee_ci_sequence_number   => l_cur_waiver_pgms.fee_ci_sequence_number)
      LOOP
        --Insert the Student Assignment to the Destination fee calendar.
        l_rowid := null;
        l_waiver_student_id := null;
        igs_fi_wav_std_pgms_pkg.insert_row( x_rowid                   =>  l_rowid,
                                            x_waiver_student_id       =>  l_waiver_student_id,
                                            x_fee_cal_type            =>  l_cur_stud_waiver_assign.fee_cal_type,
                                            x_fee_ci_sequence_number  =>  p_n_dest_fee_ci_seq_number,
                                            x_waiver_name             =>  l_cur_stud_waiver_assign.waiver_name,
                                            x_person_id               =>  l_cur_stud_waiver_assign.person_id,
                                            x_assignment_status_code  =>  l_cur_stud_waiver_assign.assignment_status_code,
                                            x_mode                    =>  'R');

      END LOOP;
      log_to_fnd(p_v_module  => 'roll_over_wav_assign',
                 p_v_string  => 'After Rolling over the Student Waiver Assignment' || l_cur_waiver_pgms.waiver_name);
    END IF;
    p_v_rollover_status := 'S';
    COMMIT;
    EXCEPTION
      WHEN e_expected_error THEN
        ROLLBACK TO sp_roll_over_waiver;
        log_to_fnd(p_v_module  => 'roll_over_wav_assign',
                   p_v_string  => 'Returing from the Expected Error Section' );
        p_v_rollover_status := 'E';
      WHEN OTHERS THEN
        ROLLBACK TO sp_roll_over_waiver;
        log_to_fnd(p_v_module  => 'roll_over_wav_assign',
                   p_v_string  => 'Returing from the When Others Error Section' );
        p_v_rollover_status := 'E';
  END roll_over_wav_assign;

  PROCEDURE update_wav_assign_status(
    p_v_fee_cal_type       IN  VARCHAR2,
    p_n_fee_ci_seq_number  IN  NUMBER,
    p_v_waiver_name        IN  VARCHAR2,
    p_v_new_status         IN  VARCHAR2,
    x_return_status        OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      :   Anji Yedubati
   Date Created By :   11-JUL-2005
   Purpose         :   To update the Student Waiver Assignment Status
                       Created as part of Tuition Waivers Enhancment Bug # 3392095

   Known limitations,enhancements,remarks:

   Change History  :
   WHO        WHEN         WHAT
  ***************************************************************** */

    CURSOR stdnt_wav_assgn_cur (
      cp_fee_cal_type      igs_fi_wav_std_pgms.fee_cal_type%TYPE,
      cp_fee_ci_seq_number igs_fi_wav_std_pgms.fee_ci_sequence_number%TYPE,
      cp_waiver_name       igs_fi_wav_std_pgms.waiver_name%TYPE,
      cp_new_status        igs_fi_wav_std_pgms.assignment_status_code%TYPE) IS
    SELECT fwsp.*, fwsp.ROWID
    FROM igs_fi_wav_std_pgms fwsp
    WHERE fee_cal_type     = cp_fee_cal_type
    AND fee_ci_sequence_number = cp_fee_ci_seq_number
    AND waiver_name       = cp_waiver_name
    AND assignment_status_code <> cp_new_status;

  BEGIN

    x_return_status := 'S';
    log_to_fnd(p_v_module  => 'roll_over_wav_assign',
               p_v_string  => 'Before the stdnt_wav_assgn_rec' );
    -- Identify the Student Waiver Assignments
    FOR stdnt_wav_assgn_rec IN stdnt_wav_assgn_cur(p_v_fee_cal_type,p_n_fee_ci_seq_number,p_v_waiver_name,p_v_new_status) LOOP

      BEGIN
        --Callout to update the student Waiver Assignment Status.
        igs_fi_wav_std_pgms_pkg.update_row(
          x_rowid                  => stdnt_wav_assgn_rec.ROWID,
          x_waiver_student_id      => stdnt_wav_assgn_rec.waiver_student_id,
          x_fee_cal_type           => stdnt_wav_assgn_rec.fee_cal_type,
          x_fee_ci_sequence_number => stdnt_wav_assgn_rec.fee_ci_sequence_number,
          x_waiver_name            => stdnt_wav_assgn_rec.waiver_name,
          x_person_id              => stdnt_wav_assgn_rec.person_id,
          x_assignment_status_code => p_v_new_status,
          x_mode                   => 'R');

      EXCEPTION

        WHEN OTHERS THEN

          x_return_status := 'E';
          log_to_fnd(p_v_module  => 'update_wav_assign_status.exception',
                     p_v_string  => 'sqlerrm ' || SQLERRM );
          -- Log the SQLERRM message and return to the calling Procedure
          IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igs.plsql.update_wav_assign_status.exception','sqlerrm ' || SQLERRM);
          END IF;

      END;

    END LOOP;
    log_to_fnd(p_v_module  => 'roll_over_wav_assign',
               p_v_string  => 'Returing from the When Others Error Section' );
  END update_wav_assign_status;

  FUNCTION check_chg_error_account  ( p_n_person_id         IN  hz_parties.party_id%TYPE,
                                      p_v_fee_type          IN  igs_fi_fee_type_all.fee_type%TYPE,
                                      p_v_fee_cal_type      IN  igs_ca_inst_all.cal_type%TYPE,
                                      p_n_fee_ci_seq_number IN  igs_ca_inst_all.sequence_number%TYPE
                                    ) RETURN NUMBER AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 28 October 2005
--
-- Purpose:
-- Invoked     : from create waiver routine , public APi
-- Function    : public procedure to verify if charge
--               transactions exists with error account "Y"
-- Parameters  : p_v_fee_cal_type        : IN parameter. Required.
--               p_n_fee_ci_seq_number   : IN parameter. Required.
--               p_v_fee_type            : IN parameter. Required.
--               p_n_person_id           : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
-- Cursor for checking for Error Transactions
    CURSOR cur_chg(cp_n_person_id      igs_fi_inv_int.person_id%TYPE,
                   cp_v_fee_type       igs_fi_inv_int.fee_type%TYPE,
                   cp_v_fee_cal_type   igs_fi_inv_int.fee_cal_type%TYPE,
                   cp_n_fee_ci_seq     igs_fi_inv_int.fee_ci_sequence_number%TYPE) IS
    SELECT 'x'
    FROM   igs_fi_inv_int inv,
           igs_fi_invln_int invln
    WHERE  inv.person_id = cp_n_person_id
    AND    inv.fee_type  = cp_v_fee_type
    AND    inv.fee_cal_type = cp_v_fee_cal_type
    AND    inv.fee_ci_sequence_number = cp_n_fee_ci_seq
    AND    inv.invoice_id = invln.invoice_id
    AND    invln.error_account = 'Y';

    l_rec_chg             cur_chg%ROWTYPE;
  BEGIN
    OPEN cur_chg(
      cp_n_person_id    => p_n_person_id,
      cp_v_fee_type     => p_v_fee_type,
      cp_v_fee_cal_type => p_v_fee_cal_type,
      cp_n_fee_ci_seq   => p_n_fee_ci_seq_number
    );
    FETCH cur_chg INTO l_rec_chg;
    IF cur_chg%FOUND THEN
      CLOSE cur_chg;
      RETURN 1;
    END IF;
    CLOSE cur_chg;
    RETURN 0;
  END check_chg_error_account;

END igs_fi_wav_utils_002;

/
