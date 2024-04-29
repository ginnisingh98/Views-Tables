--------------------------------------------------------
--  DDL for Package Body IGS_FI_COM_RECS_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_COM_RECS_INT_PKG" AS
/* $Header: IGSSIC9B.pls 120.0 2005/06/01 17:50:12 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_com_recs_int%ROWTYPE;
  new_references igs_fi_com_recs_int%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_transaction_category              IN     VARCHAR2,
    x_transaction_header_id             IN     NUMBER,
    x_transaction_number                IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_effective_date                    IN     DATE,
    x_fee_type                          IN     VARCHAR2,
    x_s_fee_type                        IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_category                      IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_course_description                IN     VARCHAR2,
    x_reversal_flag                     IN     VARCHAR2,
    x_reversal_reason                   IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_transaction_line_id               IN     NUMBER,
    x_charge_method_type                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_charge_elements                   IN     NUMBER,
    x_amount                            IN     NUMBER,
    x_credit_points                     IN     NUMBER,
    x_unit_offering_option_id           IN     NUMBER,
    x_cr_gl_code_combination_id         IN     NUMBER,
    x_dr_gl_code_combination_id         IN     NUMBER,
    x_credit_account_code               IN     VARCHAR2,
    x_debit_account_code                IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_credit_type_id                    IN     NUMBER,
    x_credit_class                      IN     VARCHAR2,
    x_currency_cd                       IN     VARCHAR2,
    x_extract_flag                      IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_student_party_id                  IN     NUMBER,
    x_source_invoice_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 21-APR-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        22-Apr-2004     Enh 3558549 - FI224 - Comm Rec Enhancements
  ||                                  Added 2 new columns student_party_id and source_invoice_id
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_com_recs_int
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
    new_references.transaction_category              := x_transaction_category;
    new_references.transaction_header_id             := x_transaction_header_id;
    new_references.transaction_number                := x_transaction_number;
    new_references.party_id                          := x_party_id;
    new_references.transaction_date                  := x_transaction_date;
    new_references.effective_date                    := x_effective_date;
    new_references.fee_type                          := x_fee_type;
    new_references.s_fee_type                        := x_s_fee_type;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.fee_category                      := x_fee_category;
    new_references.course_cd                         := x_course_cd;
    new_references.attendance_mode                   := x_attendance_mode;
    new_references.attendance_type                   := x_attendance_type;
    new_references.course_description                := x_course_description;
    new_references.reversal_flag                     := x_reversal_flag;
    new_references.reversal_reason                   := x_reversal_reason;
    new_references.line_number                       := x_line_number;
    new_references.transaction_line_id               := x_transaction_line_id;
    new_references.charge_method_type                := x_charge_method_type;
    new_references.description                       := x_description;
    new_references.charge_elements                   := x_charge_elements;
    new_references.amount                            := x_amount;
    new_references.credit_points                     := x_credit_points;
    new_references.unit_offering_option_id           := x_unit_offering_option_id;
    new_references.credit_gl_code_combination_id     := x_cr_gl_code_combination_id;
    new_references.debit_gl_code_combination_id      := x_dr_gl_code_combination_id;
    new_references.credit_account_code               := x_credit_account_code;
    new_references.debit_account_code                := x_debit_account_code;
    new_references.org_unit_cd                       := x_org_unit_cd;
    new_references.location_cd                       := x_location_cd;
    new_references.gl_date                           := x_gl_date;
    new_references.credit_type_id                    := x_credit_type_id;
    new_references.credit_class                      := x_credit_class;
    new_references.currency_cd                       := x_currency_cd;
    new_references.extract_flag                      := x_extract_flag;
    new_references.student_party_id                  := x_student_party_id;
    new_references.source_invoice_id                 := x_source_invoice_id;

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


  FUNCTION get_pk_for_validation (
    x_transaction_category              IN     VARCHAR2,
    x_transaction_header_id             IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 21-APR-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_com_recs_int
      WHERE    transaction_category = x_transaction_category
      AND      transaction_header_id = x_transaction_header_id
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_transaction_category              IN     VARCHAR2,
    x_transaction_header_id             IN     NUMBER,
    x_transaction_number                IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_effective_date                    IN     DATE,
    x_fee_type                          IN     VARCHAR2,
    x_s_fee_type                        IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_category                      IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_course_description                IN     VARCHAR2,
    x_reversal_flag                     IN     VARCHAR2,
    x_reversal_reason                   IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_transaction_line_id               IN     NUMBER,
    x_charge_method_type                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_charge_elements                   IN     NUMBER,
    x_amount                            IN     NUMBER,
    x_credit_points                     IN     NUMBER,
    x_unit_offering_option_id           IN     NUMBER,
    x_cr_gl_code_combination_id         IN     NUMBER,
    x_dr_gl_code_combination_id         IN     NUMBER,
    x_credit_account_code               IN     VARCHAR2,
    x_debit_account_code                IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_credit_type_id                    IN     NUMBER,
    x_credit_class                      IN     VARCHAR2,
    x_currency_cd                       IN     VARCHAR2,
    x_extract_flag                      IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_student_party_id                  IN     NUMBER,
    x_source_invoice_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 21-APR-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        22-Apr-2004     Enh 3558549 - FI224 - Comm Rec Enhancements
  ||                                  Added 2 new columns student_party_id and source_invoice_id
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_transaction_category,
      x_transaction_header_id,
      x_transaction_number,
      x_party_id,
      x_transaction_date,
      x_effective_date,
      x_fee_type,
      x_s_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_category,
      x_course_cd,
      x_attendance_mode,
      x_attendance_type,
      x_course_description,
      x_reversal_flag,
      x_reversal_reason,
      x_line_number,
      x_transaction_line_id,
      x_charge_method_type,
      x_description,
      x_charge_elements,
      x_amount,
      x_credit_points,
      x_unit_offering_option_id,
      x_cr_gl_code_combination_id,
      x_dr_gl_code_combination_id,
      x_credit_account_code,
      x_debit_account_code,
      x_org_unit_cd,
      x_location_cd,
      x_gl_date,
      x_credit_type_id,
      x_credit_class,
      x_currency_cd,
      x_extract_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_student_party_id,
      x_source_invoice_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.transaction_category,
             new_references.transaction_header_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.transaction_category,
             new_references.transaction_header_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_transaction_category              IN     VARCHAR2,
    x_transaction_header_id             IN     NUMBER,
    x_transaction_number                IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_effective_date                    IN     DATE,
    x_fee_type                          IN     VARCHAR2,
    x_s_fee_type                        IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_category                      IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_course_description                IN     VARCHAR2,
    x_reversal_flag                     IN     VARCHAR2,
    x_reversal_reason                   IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_transaction_line_id               IN     NUMBER,
    x_charge_method_type                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_charge_elements                   IN     NUMBER,
    x_amount                            IN     NUMBER,
    x_credit_points                     IN     NUMBER,
    x_unit_offering_option_id           IN     NUMBER,
    x_cr_gl_code_combination_id         IN     NUMBER,
    x_dr_gl_code_combination_id         IN     NUMBER,
    x_credit_account_code               IN     VARCHAR2,
    x_debit_account_code                IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_credit_type_id                    IN     NUMBER,
    x_credit_class                      IN     VARCHAR2,
    x_currency_cd                       IN     VARCHAR2,
    x_extract_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_student_party_id                  IN     NUMBER,
    x_source_invoice_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 21-APR-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        22-Apr-2004     Enh 3558549 - FI224 - Comm Rec Enhancements
  ||                                  Added 2 new columns student_party_id and source_invoice_id
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_COM_RECS_INT_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_transaction_category              => x_transaction_category,
      x_transaction_header_id             => x_transaction_header_id,
      x_transaction_number                => x_transaction_number,
      x_party_id                          => x_party_id,
      x_transaction_date                  => x_transaction_date,
      x_effective_date                    => x_effective_date,
      x_fee_type                          => x_fee_type,
      x_s_fee_type                        => x_s_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_fee_category                      => x_fee_category,
      x_course_cd                         => x_course_cd,
      x_attendance_mode                   => x_attendance_mode,
      x_attendance_type                   => x_attendance_type,
      x_course_description                => x_course_description,
      x_reversal_flag                     => x_reversal_flag,
      x_reversal_reason                   => x_reversal_reason,
      x_line_number                       => x_line_number,
      x_transaction_line_id               => x_transaction_line_id,
      x_charge_method_type                => x_charge_method_type,
      x_description                       => x_description,
      x_charge_elements                   => x_charge_elements,
      x_amount                            => x_amount,
      x_credit_points                     => x_credit_points,
      x_unit_offering_option_id           => x_unit_offering_option_id,
      x_cr_gl_code_combination_id         => x_cr_gl_code_combination_id,
      x_dr_gl_code_combination_id         => x_dr_gl_code_combination_id,
      x_credit_account_code               => x_credit_account_code,
      x_debit_account_code                => x_debit_account_code,
      x_org_unit_cd                       => x_org_unit_cd,
      x_location_cd                       => x_location_cd,
      x_gl_date                           => x_gl_date,
      x_credit_type_id                    => x_credit_type_id,
      x_credit_class                      => x_credit_class,
      x_currency_cd                       => x_currency_cd,
      x_extract_flag                      => x_extract_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_student_party_id                  => x_student_party_id,
      x_source_invoice_id                 => x_source_invoice_id
    );

    INSERT INTO igs_fi_com_recs_int (
      transaction_category,
      transaction_header_id,
      transaction_number,
      party_id,
      transaction_date,
      effective_date,
      fee_type,
      s_fee_type,
      fee_cal_type,
      fee_ci_sequence_number,
      fee_category,
      course_cd,
      attendance_mode,
      attendance_type,
      course_description,
      reversal_flag,
      reversal_reason,
      line_number,
      transaction_line_id,
      charge_method_type,
      description,
      charge_elements,
      amount,
      credit_points,
      unit_offering_option_id,
      credit_gl_code_combination_id,
      debit_gl_code_combination_id,
      credit_account_code,
      debit_account_code,
      org_unit_cd,
      location_cd,
      gl_date,
      credit_type_id,
      credit_class,
      currency_cd,
      extract_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      student_party_id,
      source_invoice_id
    ) VALUES (
      new_references.transaction_category,
      new_references.transaction_header_id,
      new_references.transaction_number,
      new_references.party_id,
      new_references.transaction_date,
      new_references.effective_date,
      new_references.fee_type,
      new_references.s_fee_type,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.fee_category,
      new_references.course_cd,
      new_references.attendance_mode,
      new_references.attendance_type,
      new_references.course_description,
      new_references.reversal_flag,
      new_references.reversal_reason,
      new_references.line_number,
      new_references.transaction_line_id,
      new_references.charge_method_type,
      new_references.description,
      new_references.charge_elements,
      new_references.amount,
      new_references.credit_points,
      new_references.unit_offering_option_id,
      new_references.credit_gl_code_combination_id,
      new_references.debit_gl_code_combination_id,
      new_references.credit_account_code,
      new_references.debit_account_code,
      new_references.org_unit_cd,
      new_references.location_cd,
      new_references.gl_date,
      new_references.credit_type_id,
      new_references.credit_class,
      new_references.currency_cd,
      new_references.extract_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.student_party_id,
      new_references.source_invoice_id
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_transaction_category              IN     VARCHAR2,
    x_transaction_header_id             IN     NUMBER,
    x_transaction_number                IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_effective_date                    IN     DATE,
    x_fee_type                          IN     VARCHAR2,
    x_s_fee_type                        IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_category                      IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_course_description                IN     VARCHAR2,
    x_reversal_flag                     IN     VARCHAR2,
    x_reversal_reason                   IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_transaction_line_id               IN     NUMBER,
    x_charge_method_type                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_charge_elements                   IN     NUMBER,
    x_amount                            IN     NUMBER,
    x_credit_points                     IN     NUMBER,
    x_unit_offering_option_id           IN     NUMBER,
    x_cr_gl_code_combination_id         IN     NUMBER,
    x_dr_gl_code_combination_id         IN     NUMBER,
    x_credit_account_code               IN     VARCHAR2,
    x_debit_account_code                IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_credit_type_id                    IN     NUMBER,
    x_credit_class                      IN     VARCHAR2,
    x_currency_cd                       IN     VARCHAR2,
    x_extract_flag                      IN     VARCHAR2,
    x_student_party_id                  IN     NUMBER,
    x_source_invoice_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 21-APR-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        22-Apr-2004     Enh 3558549 - FI224 - Comm Rec Enhancements
  ||                                  Added 2 new columns student_party_id and source_invoice_id
  */
    CURSOR c1 IS
      SELECT
        transaction_number,
        party_id,
        transaction_date,
        effective_date,
        fee_type,
        s_fee_type,
        fee_cal_type,
        fee_ci_sequence_number,
        fee_category,
        course_cd,
        attendance_mode,
        attendance_type,
        course_description,
        reversal_flag,
        reversal_reason,
        line_number,
        transaction_line_id,
        charge_method_type,
        description,
        charge_elements,
        amount,
        credit_points,
        unit_offering_option_id,
        credit_gl_code_combination_id,
        debit_gl_code_combination_id,
        credit_account_code,
        debit_account_code,
        org_unit_cd,
        location_cd,
        gl_date,
        credit_type_id,
        credit_class,
        currency_cd,
        extract_flag,
        student_party_id,
        source_invoice_id
      FROM  igs_fi_com_recs_int
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
        (tlinfo.transaction_number = x_transaction_number)
        AND (tlinfo.party_id = x_party_id)
        AND (tlinfo.transaction_date = x_transaction_date)
        AND (tlinfo.effective_date = x_effective_date)
        AND ((tlinfo.fee_type = x_fee_type) OR ((tlinfo.fee_type IS NULL) AND (X_fee_type IS NULL)))
        AND ((tlinfo.s_fee_type = x_s_fee_type) OR ((tlinfo.s_fee_type IS NULL) AND (X_s_fee_type IS NULL)))
        AND ((tlinfo.fee_cal_type = x_fee_cal_type) OR ((tlinfo.fee_cal_type IS NULL) AND (X_fee_cal_type IS NULL)))
        AND ((tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number) OR ((tlinfo.fee_ci_sequence_number IS NULL) AND (X_fee_ci_sequence_number IS NULL)))
        AND ((tlinfo.fee_category = x_fee_category) OR ((tlinfo.fee_category IS NULL) AND (X_fee_category IS NULL)))
        AND ((tlinfo.course_cd = x_course_cd) OR ((tlinfo.course_cd IS NULL) AND (X_course_cd IS NULL)))
        AND ((tlinfo.attendance_mode = x_attendance_mode) OR ((tlinfo.attendance_mode IS NULL) AND (X_attendance_mode IS NULL)))
        AND ((tlinfo.attendance_type = x_attendance_type) OR ((tlinfo.attendance_type IS NULL) AND (X_attendance_type IS NULL)))
        AND ((tlinfo.course_description = x_course_description) OR ((tlinfo.course_description IS NULL) AND (X_course_description IS NULL)))
        AND ((tlinfo.reversal_flag = x_reversal_flag) OR ((tlinfo.reversal_flag IS NULL) AND (X_reversal_flag IS NULL)))
        AND ((tlinfo.reversal_reason = x_reversal_reason) OR ((tlinfo.reversal_reason IS NULL) AND (X_reversal_reason IS NULL)))
        AND ((tlinfo.line_number = x_line_number) OR ((tlinfo.line_number IS NULL) AND (X_line_number IS NULL)))
        AND ((tlinfo.transaction_line_id = x_transaction_line_id) OR ((tlinfo.transaction_line_id IS NULL) AND (X_transaction_line_id IS NULL)))
        AND ((tlinfo.charge_method_type = x_charge_method_type) OR ((tlinfo.charge_method_type IS NULL) AND (X_charge_method_type IS NULL)))
        AND ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND ((tlinfo.charge_elements = x_charge_elements) OR ((tlinfo.charge_elements IS NULL) AND (X_charge_elements IS NULL)))
        AND (tlinfo.amount = x_amount)
        AND ((tlinfo.credit_points = x_credit_points) OR ((tlinfo.credit_points IS NULL) AND (X_credit_points IS NULL)))
        AND ((tlinfo.unit_offering_option_id = x_unit_offering_option_id) OR ((tlinfo.unit_offering_option_id IS NULL) AND (X_unit_offering_option_id IS NULL)))
        AND ((tlinfo.credit_gl_code_combination_id = x_cr_gl_code_combination_id) OR ((tlinfo.credit_gl_code_combination_id IS NULL) AND (x_cr_gl_code_combination_id IS NULL)))
        AND ((tlinfo.debit_gl_code_combination_id = x_dr_gl_code_combination_id) OR ((tlinfo.debit_gl_code_combination_id IS NULL) AND (x_dr_gl_code_combination_id IS NULL)))
        AND ((tlinfo.credit_account_code = x_credit_account_code) OR ((tlinfo.credit_account_code IS NULL) AND (X_credit_account_code IS NULL)))
        AND ((tlinfo.debit_account_code = x_debit_account_code) OR ((tlinfo.debit_account_code IS NULL) AND (X_debit_account_code IS NULL)))
        AND ((tlinfo.org_unit_cd = x_org_unit_cd) OR ((tlinfo.org_unit_cd IS NULL) AND (X_org_unit_cd IS NULL)))
        AND ((tlinfo.location_cd = x_location_cd) OR ((tlinfo.location_cd IS NULL) AND (X_location_cd IS NULL)))
        AND (tlinfo.gl_date = x_gl_date)
        AND ((tlinfo.credit_type_id = x_credit_type_id) OR ((tlinfo.credit_type_id IS NULL) AND (X_credit_type_id IS NULL)))
        AND ((tlinfo.credit_class = x_credit_class) OR ((tlinfo.credit_class IS NULL) AND (X_credit_class IS NULL)))
        AND ((tlinfo.currency_cd = x_currency_cd) OR ((tlinfo.currency_cd IS NULL) AND (X_currency_cd IS NULL)))
        AND ((tlinfo.extract_flag = x_extract_flag) OR ((tlinfo.extract_flag IS NULL) AND (X_extract_flag IS NULL)))
        AND ((tlinfo.student_party_id = x_student_party_id) OR ((tlinfo.student_party_id IS NULL) AND (x_student_party_id IS NULL)))
        AND ((tlinfo.source_invoice_id = x_source_invoice_id) OR ((tlinfo.source_invoice_id IS NULL) AND (x_source_invoice_id IS NULL)))
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
    x_transaction_category              IN     VARCHAR2,
    x_transaction_header_id             IN     NUMBER,
    x_transaction_number                IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_effective_date                    IN     DATE,
    x_fee_type                          IN     VARCHAR2,
    x_s_fee_type                        IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_category                      IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_course_description                IN     VARCHAR2,
    x_reversal_flag                     IN     VARCHAR2,
    x_reversal_reason                   IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_transaction_line_id               IN     NUMBER,
    x_charge_method_type                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_charge_elements                   IN     NUMBER,
    x_amount                            IN     NUMBER,
    x_credit_points                     IN     NUMBER,
    x_unit_offering_option_id           IN     NUMBER,
    x_cr_gl_code_combination_id         IN     NUMBER,
    x_dr_gl_code_combination_id         IN     NUMBER,
    x_credit_account_code               IN     VARCHAR2,
    x_debit_account_code                IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_credit_type_id                    IN     NUMBER,
    x_credit_class                      IN     VARCHAR2,
    x_currency_cd                       IN     VARCHAR2,
    x_extract_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_student_party_id                  IN     NUMBER,
    x_source_invoice_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 21-APR-2003
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        22-Apr-2004     Enh 3558549 - FI224 - Comm Rec Enhancements
  ||                                  Added 2 new columns student_party_id and source_invoice_id
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_COM_RECS_INT_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_transaction_category              => x_transaction_category,
      x_transaction_header_id             => x_transaction_header_id,
      x_transaction_number                => x_transaction_number,
      x_party_id                          => x_party_id,
      x_transaction_date                  => x_transaction_date,
      x_effective_date                    => x_effective_date,
      x_fee_type                          => x_fee_type,
      x_s_fee_type                        => x_s_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_fee_category                      => x_fee_category,
      x_course_cd                         => x_course_cd,
      x_attendance_mode                   => x_attendance_mode,
      x_attendance_type                   => x_attendance_type,
      x_course_description                => x_course_description,
      x_reversal_flag                     => x_reversal_flag,
      x_reversal_reason                   => x_reversal_reason,
      x_line_number                       => x_line_number,
      x_transaction_line_id               => x_transaction_line_id,
      x_charge_method_type                => x_charge_method_type,
      x_description                       => x_description,
      x_charge_elements                   => x_charge_elements,
      x_amount                            => x_amount,
      x_credit_points                     => x_credit_points,
      x_unit_offering_option_id           => x_unit_offering_option_id,
      x_cr_gl_code_combination_id         => x_cr_gl_code_combination_id,
      x_dr_gl_code_combination_id         => x_dr_gl_code_combination_id,
      x_credit_account_code               => x_credit_account_code,
      x_debit_account_code                => x_debit_account_code,
      x_org_unit_cd                       => x_org_unit_cd,
      x_location_cd                       => x_location_cd,
      x_gl_date                           => x_gl_date,
      x_credit_type_id                    => x_credit_type_id,
      x_credit_class                      => x_credit_class,
      x_currency_cd                       => x_currency_cd,
      x_extract_flag                      => x_extract_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_student_party_id                  => x_student_party_id,
      x_source_invoice_id                 => x_source_invoice_id
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

    UPDATE igs_fi_com_recs_int
      SET
        transaction_number                = new_references.transaction_number,
        party_id                          = new_references.party_id,
        transaction_date                  = new_references.transaction_date,
        effective_date                    = new_references.effective_date,
        fee_type                          = new_references.fee_type,
        s_fee_type                        = new_references.s_fee_type,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
        fee_category                      = new_references.fee_category,
        course_cd                         = new_references.course_cd,
        attendance_mode                   = new_references.attendance_mode,
        attendance_type                   = new_references.attendance_type,
        course_description                = new_references.course_description,
        reversal_flag                     = new_references.reversal_flag,
        reversal_reason                   = new_references.reversal_reason,
        line_number                       = new_references.line_number,
        transaction_line_id               = new_references.transaction_line_id,
        charge_method_type                = new_references.charge_method_type,
        description                       = new_references.description,
        charge_elements                   = new_references.charge_elements,
        amount                            = new_references.amount,
        credit_points                     = new_references.credit_points,
        unit_offering_option_id           = new_references.unit_offering_option_id,
        credit_gl_code_combination_id     = new_references.credit_gl_code_combination_id,
        debit_gl_code_combination_id      = new_references.debit_gl_code_combination_id,
        credit_account_code               = new_references.credit_account_code,
        debit_account_code                = new_references.debit_account_code,
        org_unit_cd                       = new_references.org_unit_cd,
        location_cd                       = new_references.location_cd,
        gl_date                           = new_references.gl_date,
        credit_type_id                    = new_references.credit_type_id,
        credit_class                      = new_references.credit_class,
        currency_cd                       = new_references.currency_cd,
        extract_flag                      = new_references.extract_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        student_party_id                  = new_references.student_party_id,
        source_invoice_id                 = new_references.source_invoice_id
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_transaction_category              IN     VARCHAR2,
    x_transaction_header_id             IN     NUMBER,
    x_transaction_number                IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_effective_date                    IN     DATE,
    x_fee_type                          IN     VARCHAR2,
    x_s_fee_type                        IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_category                      IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_course_description                IN     VARCHAR2,
    x_reversal_flag                     IN     VARCHAR2,
    x_reversal_reason                   IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_transaction_line_id               IN     NUMBER,
    x_charge_method_type                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_charge_elements                   IN     NUMBER,
    x_amount                            IN     NUMBER,
    x_credit_points                     IN     NUMBER,
    x_unit_offering_option_id           IN     NUMBER,
    x_cr_gl_code_combination_id         IN     NUMBER,
    x_dr_gl_code_combination_id         IN     NUMBER,
    x_credit_account_code               IN     VARCHAR2,
    x_debit_account_code                IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_credit_type_id                    IN     NUMBER,
    x_credit_class                      IN     VARCHAR2,
    x_currency_cd                       IN     VARCHAR2,
    x_extract_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_student_party_id                  IN     NUMBER,
    x_source_invoice_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 21-APR-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        22-Apr-2004     Enh 3558549 - FI224 - Comm Rec Enhancements
  ||                                  Added 2 new columns student_party_id and source_invoice_id
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_com_recs_int
      WHERE    transaction_category              = x_transaction_category
      AND      transaction_header_id             = x_transaction_header_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_transaction_category,
        x_transaction_header_id,
        x_transaction_number,
        x_party_id,
        x_transaction_date,
        x_effective_date,
        x_fee_type,
        x_s_fee_type,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_fee_category,
        x_course_cd,
        x_attendance_mode,
        x_attendance_type,
        x_course_description,
        x_reversal_flag,
        x_reversal_reason,
        x_line_number,
        x_transaction_line_id,
        x_charge_method_type,
        x_description,
        x_charge_elements,
        x_amount,
        x_credit_points,
        x_unit_offering_option_id,
        x_cr_gl_code_combination_id,
        x_dr_gl_code_combination_id,
        x_credit_account_code,
        x_debit_account_code,
        x_org_unit_cd,
        x_location_cd,
        x_gl_date,
        x_credit_type_id,
        x_credit_class,
        x_currency_cd,
        x_extract_flag,
        x_mode,
        x_student_party_id,
        x_source_invoice_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_transaction_category,
      x_transaction_header_id,
      x_transaction_number,
      x_party_id,
      x_transaction_date,
      x_effective_date,
      x_fee_type,
      x_s_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_category,
      x_course_cd,
      x_attendance_mode,
      x_attendance_type,
      x_course_description,
      x_reversal_flag,
      x_reversal_reason,
      x_line_number,
      x_transaction_line_id,
      x_charge_method_type,
      x_description,
      x_charge_elements,
      x_amount,
      x_credit_points,
      x_unit_offering_option_id,
      x_cr_gl_code_combination_id,
      x_dr_gl_code_combination_id,
      x_credit_account_code,
      x_debit_account_code,
      x_org_unit_cd,
      x_location_cd,
      x_gl_date,
      x_credit_type_id,
      x_credit_class,
      x_currency_cd,
      x_extract_flag,
      x_mode,
      x_student_party_id,
      x_source_invoice_id
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 21-APR-2003
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

    DELETE FROM igs_fi_com_recs_int
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_com_recs_int_pkg;

/
