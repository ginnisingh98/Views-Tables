--------------------------------------------------------
--  DDL for Package Body IGS_FI_PP_STD_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PP_STD_ATTRS_PKG" AS
/* $Header: IGSSIE0B.pls 120.1 2005/08/10 03:37:43 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_pp_std_attrs%ROWTYPE;
  new_references igs_fi_pp_std_attrs%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_plan_status_code                  IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_notes                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_pp_std_attrs
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.student_plan_id                   := x_student_plan_id;
    new_references.person_id                         := x_person_id;
    new_references.payment_plan_name                 := x_payment_plan_name;
    new_references.plan_start_date                   := x_plan_start_date;
    new_references.plan_end_date                     := x_plan_end_date;
    new_references.plan_status_code                  := x_plan_status_code;
    new_references.processing_fee_amt                := x_processing_fee_amt;
    new_references.processing_fee_type               := x_processing_fee_type;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.notes                             := x_notes;
    new_references.invoice_id                        := x_invoice_id;
    new_references.attribute_category                := x_attribute_category;
    new_references.attribute1                        := x_attribute1;
    new_references.attribute2                        := x_attribute2;
    new_references.attribute3                        := x_attribute3;
    new_references.attribute4                        := x_attribute4;
    new_references.attribute5                        := x_attribute5;
    new_references.attribute6                        := x_attribute6;
    new_references.attribute7                        := x_attribute7;
    new_references.attribute8                        := x_attribute8;
    new_references.attribute9                        := x_attribute9;
    new_references.attribute10                       := x_attribute10;
    new_references.attribute11                       := x_attribute11;
    new_references.attribute12                       := x_attribute12;
    new_references.attribute13                       := x_attribute13;
    new_references.attribute14                       := x_attribute14;
    new_references.attribute15                       := x_attribute15;
    new_references.attribute16                       := x_attribute16;
    new_references.attribute17                       := x_attribute17;
    new_references.attribute18                       := x_attribute18;
    new_references.attribute19                       := x_attribute19;
    new_references.attribute20                       := x_attribute20;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.payment_plan_name,
           new_references.plan_start_date
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c_personid IS
      SELECT   rowid
      FROM     hz_parties
      WHERE    party_id = new_references.person_id
      AND      status = 'A';

    rec_personid  c_personid%ROWTYPE;

  BEGIN
    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      OPEN c_personid;
      FETCH c_personid INTO rec_personid;
      IF (c_personid%FOUND) THEN
        CLOSE c_personid;
      ELSE
        CLOSE c_personid;
        fnd_message.set_name ('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (((old_references.payment_plan_name = new_references.payment_plan_name)) OR
        ((new_references.payment_plan_name IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_pp_templates_pkg.get_pk_for_validation (
                new_references.payment_plan_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_PKG.get_pk_for_validation (
                new_references.fee_cal_type,
                new_references.fee_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.processing_fee_type = new_references.processing_fee_type)) OR
        ((new_references.processing_fee_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_fee_type_PKG.get_pk_for_validation (
                new_references.processing_fee_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_fi_pp_instlmnts_pkg.get_fk_igs_fi_pp_std_attrs (
      old_references.student_plan_id
    );

  END check_child_existance;

  FUNCTION create_processing_charge( p_n_person_id              igs_fi_pp_std_attrs.person_id%TYPE,
                                     p_v_fee_type               igs_fi_pp_std_attrs.processing_fee_type%TYPE,
                                     p_v_fee_cal_type           igs_fi_pp_std_attrs.fee_cal_type%TYPE,
                                     p_n_fee_ci_sequence_number igs_fi_pp_std_attrs.fee_ci_sequence_number%TYPE,
                                     p_n_amount                 igs_fi_pp_std_attrs.processing_fee_amt%TYPE,
                                     p_v_plan_name              igs_fi_pp_std_attrs.payment_plan_name%TYPE,
                                     p_d_start_date             igs_fi_pp_std_attrs.plan_start_date%TYPE ) RETURN NUMBER IS
  /*
  ||  Created By : shtatiko
  ||  Created On : 02-SEP-2003
  ||  Purpose : To create a charge for Processing Fee Amount.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || svuppala  04-AUG-2005   Enh 3392095 - Tution Waivers build
  ||                         Impact of Charges API version Number change
  ||                         Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  ||  (reverse chronological order - newest change first)
  */

  l_chg_rec             igs_fi_charges_api_pvt.header_rec_type;
  l_chg_line_tbl        igs_fi_charges_api_pvt.line_tbl_type;
  l_line_tbl            igs_fi_charges_api_pvt.line_id_tbl_type;
  l_n_invoice_id        igs_fi_inv_int.invoice_id%TYPE;
  l_v_message_name      VARCHAR2(30);
  l_v_curr_desc         VARCHAR2(100);
  l_msg_count           NUMBER(5);
  l_msg_data            VARCHAR2(2000);
  l_msg                 VARCHAR2(2000);
  l_v_status            VARCHAR2(2);

  l_n_waiver_amount NUMBER;
  BEGIN

    l_chg_rec.p_person_id                := p_n_person_id;
    l_chg_rec.p_fee_type                 := p_v_fee_type;
    l_chg_rec.p_fee_cat                  := NULL;
    l_chg_rec.p_fee_cal_type             := p_v_fee_cal_type;
    l_chg_rec.p_fee_ci_sequence_number   := p_n_fee_ci_sequence_number;
    l_chg_rec.p_course_cd                := NULL;
    l_chg_rec.p_attendance_type          := NULL;
    l_chg_rec.p_attendance_mode          := NULL;
    l_chg_rec.p_invoice_amount           := p_n_amount;
    l_chg_rec.p_invoice_creation_date    := TRUNC(SYSDATE);

    -- Get Invoice Description from Message
    fnd_message.set_name( 'IGS', 'IGS_FI_PP_PROCESSING_FEE' );
    fnd_message.set_token( 'PLAN_NAME', p_v_plan_name );
    fnd_message.set_token( 'START_DATE', p_d_start_date );
    l_chg_rec.p_invoice_desc             := fnd_message.get;

    l_chg_rec.p_transaction_type         := 'PAY_PLAN';

    --Capture the default currency that is set up in System Options Form.
    igs_fi_gen_gl.finp_get_cur( p_v_currency_cd    => l_chg_rec.p_currency_cd,
                                p_v_curr_desc      => l_v_curr_desc,
                                p_v_message_name   => l_v_message_name
                              );
    IF l_v_message_name IS NOT NULL THEN
      fnd_message.set_name('IGS',l_v_message_name);
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    l_chg_rec.p_exchange_rate            := 1;
    l_chg_rec.p_effective_date           := TRUNC(SYSDATE);
    l_chg_rec.p_waiver_flag              := NULL;
    l_chg_rec.p_waiver_reason            := NULL;
    l_chg_rec.p_source_transaction_id    := NULL;

    l_chg_line_tbl(1).p_s_chg_method_type         := NULL;
    l_chg_line_tbl(1).p_description               := l_chg_rec.p_invoice_desc;
    l_chg_line_tbl(1).p_chg_elements              := 1;
    l_chg_line_tbl(1).p_amount                    := p_n_amount;
    l_chg_line_tbl(1).p_unit_attempt_status       := NULL;
    l_chg_line_tbl(1).p_eftsu                     := NULL;
    l_chg_line_tbl(1).p_credit_points             := NULL;
    l_chg_line_tbl(1).p_org_unit_cd               := NULL;
    l_chg_line_tbl(1).p_attribute_category        := NULL;
    l_chg_line_tbl(1).p_attribute1                := NULL;
    l_chg_line_tbl(1).p_attribute2                := NULL;
    l_chg_line_tbl(1).p_attribute3                := NULL;
    l_chg_line_tbl(1).p_attribute4                := NULL;
    l_chg_line_tbl(1).p_attribute5                := NULL;
    l_chg_line_tbl(1).p_attribute6                := NULL;
    l_chg_line_tbl(1).p_attribute7                := NULL;
    l_chg_line_tbl(1).p_attribute8                := NULL;
    l_chg_line_tbl(1).p_attribute9                := NULL;
    l_chg_line_tbl(1).p_attribute10               := NULL;
    l_chg_line_tbl(1).p_attribute11               := NULL;
    l_chg_line_tbl(1).p_attribute12               := NULL;
    l_chg_line_tbl(1).p_attribute13               := NULL;
    l_chg_line_tbl(1).p_attribute14               := NULL;
    l_chg_line_tbl(1).p_attribute15               := NULL;
    l_chg_line_tbl(1).p_attribute16               := NULL;
    l_chg_line_tbl(1).p_attribute17               := NULL;
    l_chg_line_tbl(1).p_attribute18               := NULL;
    l_chg_line_tbl(1).p_attribute19               := NULL;
    l_chg_line_tbl(1).p_attribute20               := NULL;
    l_chg_line_tbl(1).p_location_cd               := NULL;
    l_chg_line_tbl(1).p_uoo_id                    := NULL;
    l_chg_line_tbl(1).p_d_gl_date                 := SYSDATE;

    igs_fi_charges_api_pvt.create_charge(p_api_version      => 2.0,
                                         p_init_msg_list    => 'T',
                                         p_commit           => 'F',
                                         p_validation_level => NULL,
                                         p_header_rec       => l_chg_rec,
                                         p_line_tbl         => l_chg_line_tbl,
                                         x_invoice_id       => l_n_invoice_id,
                                         x_line_id_tbl      => l_line_tbl,
                                         x_return_status    => l_v_status,
                                         x_msg_count        => l_msg_count,
                                         x_msg_data         => l_msg_data,
                                         x_waiver_amount    => l_n_waiver_amount);

    IF l_v_status <> 'S' THEN
      IF l_msg_count = 1 THEN
        fnd_message.set_encoded(l_msg_data);
        l_msg := fnd_message.get;
        fnd_message.set_name('IGS', 'IGS_FI_ERR_TXT');
        fnd_message.set_token('TEXT', l_msg);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      ELSE
        l_msg := '';
        FOR l_count IN 1 .. l_msg_count LOOP
          l_msg := l_msg||fnd_msg_pub.get(p_msg_index => l_count, p_encoded => 'T') || ' ';
        END LOOP;
        fnd_message.set_name('IGS', 'IGS_FI_ERR_TXT');
        fnd_message.set_token('TEXT', l_msg);
        app_exception.raise_exception;
      END IF;
    END IF;

    RETURN l_n_invoice_id;

  END create_processing_charge;

  FUNCTION get_pk_for_validation (
    x_student_plan_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_pp_std_attrs
      WHERE    student_plan_id = x_student_plan_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_pk_for_validation;


  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_pp_std_attrs
      WHERE    person_id = x_person_id
      AND      payment_plan_name = x_payment_plan_name
      AND      plan_start_date = x_plan_start_date
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_pp_std_attrs
      WHERE   ((fee_cal_type = x_cal_type) AND
               (fee_ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_PPSA_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;

  PROCEDURE  BeforeRowInsertUpdateDelete( p_inserting IN BOOLEAN DEFAULT FALSE,
                                          p_updating  IN BOOLEAN DEFAULT FALSE,
                                          p_deleting  IN BOOLEAN DEFAULT FALSE ) AS
  /*
  ||  Created By : shtatiko
  ||  Created On : 24-AUG-2003
  ||  Purpose : To carryout actions to be done before inserting/updating/deleting
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  l_n_invoice_id igs_fi_inv_int_all.invoice_id%TYPE;
  BEGIN

    IF (p_updating) THEN
      -- If Plan Status is changed to ACTIVE, then create processing charge.
      IF old_references.plan_status_code = 'PLANNED'
         AND new_references.plan_status_code = 'ACTIVE' THEN
        IF new_references.processing_fee_amt IS NOT NULL THEN
          IF new_references.fee_cal_type IS NULL THEN
            fnd_message.set_name('IGS',
                                 'IGS_FI_PP_NO_FEE_PERIOD');
            fnd_message.set_token( 'PLAN_NAME', new_references.payment_plan_name);
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
          END IF;

          l_n_invoice_id := create_processing_charge( p_n_person_id              => new_references.person_id,
                                                      p_v_fee_type               => new_references.processing_fee_type,
                                                      p_v_fee_cal_type           => new_references.fee_cal_type,
                                                      p_n_fee_ci_sequence_number => new_references.fee_ci_sequence_number,
                                                      p_n_amount                 => new_references.processing_fee_amt,
                                                      p_v_plan_name              => new_references.payment_plan_name,
                                                      p_d_start_date             => new_references.plan_start_date );
          new_references.invoice_id := l_n_invoice_id;
        END IF;
      END IF;
    END IF;

  END BeforeRowInsertUpdateDelete;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_plan_status_code                  IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_notes                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_student_plan_id,
      x_person_id,
      x_payment_plan_name,
      x_plan_start_date,
      x_plan_end_date,
      x_plan_status_code,
      x_processing_fee_amt,
      x_processing_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_notes,
      x_invoice_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.student_plan_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
      BeforeRowInsertUpdateDelete(p_updating => TRUE);
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.student_plan_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_student_plan_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_plan_status_code                  IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_notes                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_FI_PP_STD_ATTRS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_student_plan_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_student_plan_id                   => x_student_plan_id,
      x_person_id                         => x_person_id,
      x_payment_plan_name                 => x_payment_plan_name,
      x_plan_start_date                   => x_plan_start_date,
      x_plan_end_date                     => x_plan_end_date,
      x_plan_status_code                  => x_plan_status_code,
      x_processing_fee_amt                => x_processing_fee_amt,
      x_processing_fee_type               => x_processing_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_notes                             => x_notes,
      x_invoice_id                        => x_invoice_id,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_pp_std_attrs (
      student_plan_id,
      person_id,
      payment_plan_name,
      plan_start_date,
      plan_end_date,
      plan_status_code,
      processing_fee_amt,
      processing_fee_type,
      fee_cal_type,
      fee_ci_sequence_number,
      notes,
      invoice_id,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      igs_fi_pp_std_attrs_s.NEXTVAL,
      new_references.person_id,
      new_references.payment_plan_name,
      new_references.plan_start_date,
      new_references.plan_end_date,
      new_references.plan_status_code,
      new_references.processing_fee_amt,
      new_references.processing_fee_type,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.notes,
      new_references.invoice_id,
      new_references.attribute_category,
      new_references.attribute1,
      new_references.attribute2,
      new_references.attribute3,
      new_references.attribute4,
      new_references.attribute5,
      new_references.attribute6,
      new_references.attribute7,
      new_references.attribute8,
      new_references.attribute9,
      new_references.attribute10,
      new_references.attribute11,
      new_references.attribute12,
      new_references.attribute13,
      new_references.attribute14,
      new_references.attribute15,
      new_references.attribute16,
      new_references.attribute17,
      new_references.attribute18,
      new_references.attribute19,
      new_references.attribute20,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, student_plan_id INTO x_rowid, x_student_plan_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_plan_status_code                  IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_notes                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        payment_plan_name,
        plan_start_date,
        plan_end_date,
        plan_status_code,
        processing_fee_amt,
        processing_fee_type,
        fee_cal_type,
        fee_ci_sequence_number,
        notes,
        invoice_id,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20
      FROM  igs_fi_pp_std_attrs
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.payment_plan_name = x_payment_plan_name)
        AND (tlinfo.plan_start_date = x_plan_start_date)
        AND (tlinfo.plan_end_date = x_plan_end_date)
        AND (tlinfo.plan_status_code = x_plan_status_code)
        AND ((tlinfo.processing_fee_amt = x_processing_fee_amt) OR ((tlinfo.processing_fee_amt IS NULL) AND (X_processing_fee_amt IS NULL)))
        AND ((tlinfo.processing_fee_type = x_processing_fee_type) OR ((tlinfo.processing_fee_type IS NULL) AND (X_processing_fee_type IS NULL)))
        AND ((tlinfo.fee_cal_type = x_fee_cal_type) OR ((tlinfo.fee_cal_type IS NULL) AND (X_fee_cal_type IS NULL)))
        AND ((tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number) OR ((tlinfo.fee_ci_sequence_number IS NULL) AND (X_fee_ci_sequence_number IS NULL)))
        AND ((tlinfo.notes = x_notes) OR ((tlinfo.notes IS NULL) AND (X_notes IS NULL)))
        AND ((tlinfo.invoice_id = x_invoice_id) OR ((tlinfo.invoice_id IS NULL) AND (X_invoice_id IS NULL)))
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.attribute16 = x_attribute16) OR ((tlinfo.attribute16 IS NULL) AND (X_attribute16 IS NULL)))
        AND ((tlinfo.attribute17 = x_attribute17) OR ((tlinfo.attribute17 IS NULL) AND (X_attribute17 IS NULL)))
        AND ((tlinfo.attribute18 = x_attribute18) OR ((tlinfo.attribute18 IS NULL) AND (X_attribute18 IS NULL)))
        AND ((tlinfo.attribute19 = x_attribute19) OR ((tlinfo.attribute19 IS NULL) AND (X_attribute19 IS NULL)))
        AND ((tlinfo.attribute20 = x_attribute20) OR ((tlinfo.attribute20 IS NULL) AND (X_attribute20 IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_plan_status_code                  IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_notes                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_FI_PP_STD_ATTRS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_student_plan_id                   => x_student_plan_id,
      x_person_id                         => x_person_id,
      x_payment_plan_name                 => x_payment_plan_name,
      x_plan_start_date                   => x_plan_start_date,
      x_plan_end_date                     => x_plan_end_date,
      x_plan_status_code                  => x_plan_status_code,
      x_processing_fee_amt                => x_processing_fee_amt,
      x_processing_fee_type               => x_processing_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_notes                             => x_notes,
      x_invoice_id                        => x_invoice_id,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igs_fi_pp_std_attrs
      SET
        person_id                         = new_references.person_id,
        payment_plan_name                 = new_references.payment_plan_name,
        plan_start_date                   = new_references.plan_start_date,
        plan_end_date                     = new_references.plan_end_date,
        plan_status_code                  = new_references.plan_status_code,
        processing_fee_amt                = new_references.processing_fee_amt,
        processing_fee_type               = new_references.processing_fee_type,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
        notes                             = new_references.notes,
        invoice_id                        = new_references.invoice_id,
        attribute_category                = new_references.attribute_category,
        attribute1                        = new_references.attribute1,
        attribute2                        = new_references.attribute2,
        attribute3                        = new_references.attribute3,
        attribute4                        = new_references.attribute4,
        attribute5                        = new_references.attribute5,
        attribute6                        = new_references.attribute6,
        attribute7                        = new_references.attribute7,
        attribute8                        = new_references.attribute8,
        attribute9                        = new_references.attribute9,
        attribute10                       = new_references.attribute10,
        attribute11                       = new_references.attribute11,
        attribute12                       = new_references.attribute12,
        attribute13                       = new_references.attribute13,
        attribute14                       = new_references.attribute14,
        attribute15                       = new_references.attribute15,
        attribute16                       = new_references.attribute16,
        attribute17                       = new_references.attribute17,
        attribute18                       = new_references.attribute18,
        attribute19                       = new_references.attribute19,
        attribute20                       = new_references.attribute20,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_student_plan_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_plan_status_code                  IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_notes                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_pp_std_attrs
      WHERE    student_plan_id                   = x_student_plan_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_student_plan_id,
        x_person_id,
        x_payment_plan_name,
        x_plan_start_date,
        x_plan_end_date,
        x_plan_status_code,
        x_processing_fee_amt,
        x_processing_fee_type,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_notes,
        x_invoice_id,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_attribute16,
        x_attribute17,
        x_attribute18,
        x_attribute19,
        x_attribute20,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_student_plan_id,
      x_person_id,
      x_payment_plan_name,
      x_plan_start_date,
      x_plan_end_date,
      x_plan_status_code,
      x_processing_fee_amt,
      x_processing_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_notes,
      x_invoice_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igs_fi_pp_std_attrs
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_pp_std_attrs_pkg;

/
