--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_PNOTE_P_P_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_PNOTE_P_P_PKG" AS
/* $Header: IGFLI30B.pls 115.4 2002/11/28 14:28:20 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_dl_pnote_p_p_all%ROWTYPE;
  new_references igf_sl_dl_pnote_p_p_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_pnpp_id                           IN     NUMBER      DEFAULT NULL,
    x_batch_seq_num                     IN     NUMBER      DEFAULT NULL,
    x_loan_id                           IN     NUMBER      DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_loan_amt_offered                  IN     NUMBER      DEFAULT NULL,
    x_loan_amt_accepted                 IN     NUMBER      DEFAULT NULL,
    x_loan_per_begin_date               IN     DATE        DEFAULT NULL,
    x_loan_per_end_date                 IN     DATE        DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_s_ssn                             IN     VARCHAR2    DEFAULT NULL,
    x_s_first_name                      IN     VARCHAR2    DEFAULT NULL,
    x_s_last_name                       IN     VARCHAR2    DEFAULT NULL,
    x_s_middle_name                     IN     VARCHAR2    DEFAULT NULL,
    x_s_date_of_birth                   IN     DATE        DEFAULT NULL,
    x_s_citizenship_status              IN     VARCHAR2    DEFAULT NULL,
    x_s_alien_reg_number                IN     VARCHAR2    DEFAULT NULL,
    x_s_license_num                     IN     VARCHAR2    DEFAULT NULL,
    x_s_license_state                   IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_addr1                     IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_addr2                     IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_city                      IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_state                     IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_province                  IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_county                    IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_country                   IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_zip                       IN     VARCHAR2    DEFAULT NULL,
    x_s_email_addr                      IN     VARCHAR2    DEFAULT NULL,
    x_s_phone                           IN     VARCHAR2    DEFAULT NULL,
    x_p_person_id                       IN     NUMBER      DEFAULT NULL,
    x_p_ssn                             IN     VARCHAR2    DEFAULT NULL,
    x_p_last_name                       IN     VARCHAR2    DEFAULT NULL,
    x_p_first_name                      IN     VARCHAR2    DEFAULT NULL,
    x_p_middle_name                     IN     VARCHAR2    DEFAULT NULL,
    x_p_date_of_birth                   IN     DATE        DEFAULT NULL,
    x_p_citizenship_status              IN     VARCHAR2    DEFAULT NULL,
    x_p_alien_reg_num                   IN     VARCHAR2    DEFAULT NULL,
    x_p_license_num                     IN     VARCHAR2    DEFAULT NULL,
    x_p_license_state                   IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_addr1                     IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_addr2                     IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_city                      IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_state                     IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_province                  IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_county                    IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_country                   IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_zip                       IN     VARCHAR2    DEFAULT NULL,
    x_p_email_addr                      IN     VARCHAR2    DEFAULT NULL,
    x_p_phone                           IN     VARCHAR2    DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SL_DL_PNOTE_P_P_ALL
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
    new_references.pnpp_id                           := x_pnpp_id;
    new_references.batch_seq_num                     := x_batch_seq_num;
    new_references.loan_id                           := x_loan_id;
    new_references.loan_number                       := x_loan_number;
    new_references.loan_amt_offered                  := x_loan_amt_offered;
    new_references.loan_amt_accepted                 := x_loan_amt_accepted;
    new_references.loan_per_begin_date               := x_loan_per_begin_date;
    new_references.loan_per_end_date                 := x_loan_per_end_date;
    new_references.person_id                         := x_person_id;
    new_references.s_ssn                             := x_s_ssn;
    new_references.s_first_name                      := x_s_first_name;
    new_references.s_last_name                       := x_s_last_name;
    new_references.s_middle_name                     := x_s_middle_name;
    new_references.s_date_of_birth                   := x_s_date_of_birth;
    new_references.s_citizenship_status              := x_s_citizenship_status;
    new_references.s_alien_reg_number                := x_s_alien_reg_number;
    new_references.s_license_num                     := x_s_license_num;
    new_references.s_license_state                   := x_s_license_state;
    new_references.s_permt_addr1                     := x_s_permt_addr1;
    new_references.s_permt_addr2                     := x_s_permt_addr2;
    new_references.s_permt_city                      := x_s_permt_city;
    new_references.s_permt_state                     := x_s_permt_state;
    new_references.s_permt_province                  := x_s_permt_province;
    new_references.s_permt_county                    := x_s_permt_county;
    new_references.s_permt_country                   := x_s_permt_country;
    new_references.s_permt_zip                       := x_s_permt_zip;
    new_references.s_email_addr                      := x_s_email_addr;
    new_references.s_phone                           := x_s_phone;
    new_references.p_person_id                       := x_p_person_id;
    new_references.p_ssn                             := x_p_ssn;
    new_references.p_last_name                       := x_p_last_name;
    new_references.p_first_name                      := x_p_first_name;
    new_references.p_middle_name                     := x_p_middle_name;
    new_references.p_date_of_birth                   := x_p_date_of_birth;
    new_references.p_citizenship_status              := x_p_citizenship_status;
    new_references.p_alien_reg_num                   := x_p_alien_reg_num;
    new_references.p_license_num                     := x_p_license_num;
    new_references.p_license_state                   := x_p_license_state;
    new_references.p_permt_addr1                     := x_p_permt_addr1;
    new_references.p_permt_addr2                     := x_p_permt_addr2;
    new_references.p_permt_city                      := x_p_permt_city;
    new_references.p_permt_state                     := x_p_permt_state;
    new_references.p_permt_province                  := x_p_permt_province;
    new_references.p_permt_county                    := x_p_permt_county;
    new_references.p_permt_country                   := x_p_permt_country;
    new_references.p_permt_zip                       := x_p_permt_zip;
    new_references.p_email_addr                      := x_p_email_addr;
    new_references.p_phone                           := x_p_phone;
    new_references.status                            := x_status;

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


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.loan_id = new_references.loan_id)) OR
        ((new_references.loan_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_loans_pkg.get_pk_for_validation (
                new_references.loan_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_pnpp_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_dl_pnote_p_p_all
      WHERE    pnpp_id = x_pnpp_id
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


  PROCEDURE get_fk_igf_sl_loans (
    x_loan_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_dl_pnote_p_p_all
      WHERE   ((loan_id = x_loan_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_PNPP_LAR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_loans;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_pnpp_id                           IN     NUMBER      DEFAULT NULL,
    x_batch_seq_num                     IN     NUMBER      DEFAULT NULL,
    x_loan_id                           IN     NUMBER      DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_loan_amt_offered                  IN     NUMBER      DEFAULT NULL,
    x_loan_amt_accepted                 IN     NUMBER      DEFAULT NULL,
    x_loan_per_begin_date               IN     DATE        DEFAULT NULL,
    x_loan_per_end_date                 IN     DATE        DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_s_ssn                             IN     VARCHAR2    DEFAULT NULL,
    x_s_first_name                      IN     VARCHAR2    DEFAULT NULL,
    x_s_last_name                       IN     VARCHAR2    DEFAULT NULL,
    x_s_middle_name                     IN     VARCHAR2    DEFAULT NULL,
    x_s_date_of_birth                   IN     DATE        DEFAULT NULL,
    x_s_citizenship_status              IN     VARCHAR2    DEFAULT NULL,
    x_s_alien_reg_number                IN     VARCHAR2    DEFAULT NULL,
    x_s_license_num                     IN     VARCHAR2    DEFAULT NULL,
    x_s_license_state                   IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_addr1                     IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_addr2                     IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_city                      IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_state                     IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_province                  IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_county                    IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_country                   IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_zip                       IN     VARCHAR2    DEFAULT NULL,
    x_s_email_addr                      IN     VARCHAR2    DEFAULT NULL,
    x_s_phone                           IN     VARCHAR2    DEFAULT NULL,
    x_p_person_id                       IN     NUMBER      DEFAULT NULL,
    x_p_ssn                             IN     VARCHAR2    DEFAULT NULL,
    x_p_last_name                       IN     VARCHAR2    DEFAULT NULL,
    x_p_first_name                      IN     VARCHAR2    DEFAULT NULL,
    x_p_middle_name                     IN     VARCHAR2    DEFAULT NULL,
    x_p_date_of_birth                   IN     DATE        DEFAULT NULL,
    x_p_citizenship_status              IN     VARCHAR2    DEFAULT NULL,
    x_p_alien_reg_num                   IN     VARCHAR2    DEFAULT NULL,
    x_p_license_num                     IN     VARCHAR2    DEFAULT NULL,
    x_p_license_state                   IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_addr1                     IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_addr2                     IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_city                      IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_state                     IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_province                  IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_county                    IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_country                   IN     VARCHAR2    DEFAULT NULL,
    x_p_permt_zip                       IN     VARCHAR2    DEFAULT NULL,
    x_p_email_addr                      IN     VARCHAR2    DEFAULT NULL,
    x_p_phone                           IN     VARCHAR2    DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
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
      x_pnpp_id,
      x_batch_seq_num,
      x_loan_id,
      x_loan_number,
      x_loan_amt_offered,
      x_loan_amt_accepted,
      x_loan_per_begin_date,
      x_loan_per_end_date,
      x_person_id,
      x_s_ssn,
      x_s_first_name,
      x_s_last_name,
      x_s_middle_name,
      x_s_date_of_birth,
      x_s_citizenship_status,
      x_s_alien_reg_number,
      x_s_license_num,
      x_s_license_state,
      x_s_permt_addr1,
      x_s_permt_addr2,
      x_s_permt_city,
      x_s_permt_state,
      x_s_permt_province,
      x_s_permt_county,
      x_s_permt_country,
      x_s_permt_zip,
      x_s_email_addr,
      x_s_phone,
      x_p_person_id,
      x_p_ssn,
      x_p_last_name,
      x_p_first_name,
      x_p_middle_name,
      x_p_date_of_birth,
      x_p_citizenship_status,
      x_p_alien_reg_num,
      x_p_license_num,
      x_p_license_state,
      x_p_permt_addr1,
      x_p_permt_addr2,
      x_p_permt_city,
      x_p_permt_state,
      x_p_permt_province,
      x_p_permt_county,
      x_p_permt_country,
      x_p_permt_zip,
      x_p_email_addr,
      x_p_phone,
      x_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.pnpp_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.pnpp_id
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
    x_pnpp_id                           IN OUT NOCOPY NUMBER,
    x_batch_seq_num                     IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_amt_offered                  IN     NUMBER,
    x_loan_amt_accepted                 IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_person_id                         IN     NUMBER,
    x_s_ssn                             IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_alien_reg_number                IN     VARCHAR2,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_province                  IN     VARCHAR2,
    x_s_permt_county                    IN     VARCHAR2,
    x_s_permt_country                   IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_phone                           IN     VARCHAR2,
    x_p_person_id                       IN     NUMBER,
    x_p_ssn                             IN     VARCHAR2,
    x_p_last_name                       IN     VARCHAR2,
    x_p_first_name                      IN     VARCHAR2,
    x_p_middle_name                     IN     VARCHAR2,
    x_p_date_of_birth                   IN     DATE,
    x_p_citizenship_status              IN     VARCHAR2,
    x_p_alien_reg_num                   IN     VARCHAR2,
    x_p_license_num                     IN     VARCHAR2,
    x_p_license_state                   IN     VARCHAR2,
    x_p_permt_addr1                     IN     VARCHAR2,
    x_p_permt_addr2                     IN     VARCHAR2,
    x_p_permt_city                      IN     VARCHAR2,
    x_p_permt_state                     IN     VARCHAR2,
    x_p_permt_province                  IN     VARCHAR2,
    x_p_permt_county                    IN     VARCHAR2,
    x_p_permt_country                   IN     VARCHAR2,
    x_p_permt_zip                       IN     VARCHAR2,
    x_p_email_addr                      IN     VARCHAR2,
    x_p_phone                           IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_dl_pnote_p_p_all
      WHERE    pnpp_id                           = x_pnpp_id;

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igf_sl_dl_pnote_p_p_all_s.NEXTVAL
    INTO      x_pnpp_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_pnpp_id                           => x_pnpp_id,
      x_batch_seq_num                     => x_batch_seq_num,
      x_loan_id                           => x_loan_id,
      x_loan_number                       => x_loan_number,
      x_loan_amt_offered                  => x_loan_amt_offered,
      x_loan_amt_accepted                 => x_loan_amt_accepted,
      x_loan_per_begin_date               => x_loan_per_begin_date,
      x_loan_per_end_date                 => x_loan_per_end_date,
      x_person_id                         => x_person_id,
      x_s_ssn                             => x_s_ssn,
      x_s_first_name                      => x_s_first_name,
      x_s_last_name                       => x_s_last_name,
      x_s_middle_name                     => x_s_middle_name,
      x_s_date_of_birth                   => x_s_date_of_birth,
      x_s_citizenship_status              => x_s_citizenship_status,
      x_s_alien_reg_number                => x_s_alien_reg_number,
      x_s_license_num                     => x_s_license_num,
      x_s_license_state                   => x_s_license_state,
      x_s_permt_addr1                     => x_s_permt_addr1,
      x_s_permt_addr2                     => x_s_permt_addr2,
      x_s_permt_city                      => x_s_permt_city,
      x_s_permt_state                     => x_s_permt_state,
      x_s_permt_province                  => x_s_permt_province,
      x_s_permt_county                    => x_s_permt_county,
      x_s_permt_country                   => x_s_permt_country,
      x_s_permt_zip                       => x_s_permt_zip,
      x_s_email_addr                      => x_s_email_addr,
      x_s_phone                           => x_s_phone,
      x_p_person_id                       => x_p_person_id,
      x_p_ssn                             => x_p_ssn,
      x_p_last_name                       => x_p_last_name,
      x_p_first_name                      => x_p_first_name,
      x_p_middle_name                     => x_p_middle_name,
      x_p_date_of_birth                   => x_p_date_of_birth,
      x_p_citizenship_status              => x_p_citizenship_status,
      x_p_alien_reg_num                   => x_p_alien_reg_num,
      x_p_license_num                     => x_p_license_num,
      x_p_license_state                   => x_p_license_state,
      x_p_permt_addr1                     => x_p_permt_addr1,
      x_p_permt_addr2                     => x_p_permt_addr2,
      x_p_permt_city                      => x_p_permt_city,
      x_p_permt_state                     => x_p_permt_state,
      x_p_permt_province                  => x_p_permt_province,
      x_p_permt_county                    => x_p_permt_county,
      x_p_permt_country                   => x_p_permt_country,
      x_p_permt_zip                       => x_p_permt_zip,
      x_p_email_addr                      => x_p_email_addr,
      x_p_phone                           => x_p_phone,
      x_status                            => x_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sl_dl_pnote_p_p_all (
      pnpp_id,
      batch_seq_num,
      loan_id,
      loan_number,
      loan_amt_offered,
      loan_amt_accepted,
      loan_per_begin_date,
      loan_per_end_date,
      person_id,
      s_ssn,
      s_first_name,
      s_last_name,
      s_middle_name,
      s_date_of_birth,
      s_citizenship_status,
      s_alien_reg_number,
      s_license_num,
      s_license_state,
      s_permt_addr1,
      s_permt_addr2,
      s_permt_city,
      s_permt_state,
      s_permt_province,
      s_permt_county,
      s_permt_country,
      s_permt_zip,
      s_email_addr,
      s_phone,
      p_person_id,
      p_ssn,
      p_last_name,
      p_first_name,
      p_middle_name,
      p_date_of_birth,
      p_citizenship_status,
      p_alien_reg_num,
      p_license_num,
      p_license_state,
      p_permt_addr1,
      p_permt_addr2,
      p_permt_city,
      p_permt_state,
      p_permt_province,
      p_permt_county,
      p_permt_country,
      p_permt_zip,
      p_email_addr,
      p_phone,
      status,
      org_id,
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
      new_references.pnpp_id,
      new_references.batch_seq_num,
      new_references.loan_id,
      new_references.loan_number,
      new_references.loan_amt_offered,
      new_references.loan_amt_accepted,
      new_references.loan_per_begin_date,
      new_references.loan_per_end_date,
      new_references.person_id,
      new_references.s_ssn,
      new_references.s_first_name,
      new_references.s_last_name,
      new_references.s_middle_name,
      new_references.s_date_of_birth,
      new_references.s_citizenship_status,
      new_references.s_alien_reg_number,
      new_references.s_license_num,
      new_references.s_license_state,
      new_references.s_permt_addr1,
      new_references.s_permt_addr2,
      new_references.s_permt_city,
      new_references.s_permt_state,
      new_references.s_permt_province,
      new_references.s_permt_county,
      new_references.s_permt_country,
      new_references.s_permt_zip,
      new_references.s_email_addr,
      new_references.s_phone,
      new_references.p_person_id,
      new_references.p_ssn,
      new_references.p_last_name,
      new_references.p_first_name,
      new_references.p_middle_name,
      new_references.p_date_of_birth,
      new_references.p_citizenship_status,
      new_references.p_alien_reg_num,
      new_references.p_license_num,
      new_references.p_license_state,
      new_references.p_permt_addr1,
      new_references.p_permt_addr2,
      new_references.p_permt_city,
      new_references.p_permt_state,
      new_references.p_permt_province,
      new_references.p_permt_county,
      new_references.p_permt_country,
      new_references.p_permt_zip,
      new_references.p_email_addr,
      new_references.p_phone,
      new_references.status,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_pnpp_id                           IN     NUMBER,
    x_batch_seq_num                     IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_amt_offered                  IN     NUMBER,
    x_loan_amt_accepted                 IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_person_id                         IN     NUMBER,
    x_s_ssn                             IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_alien_reg_number                IN     VARCHAR2,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_province                  IN     VARCHAR2,
    x_s_permt_county                    IN     VARCHAR2,
    x_s_permt_country                   IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_phone                           IN     VARCHAR2,
    x_p_person_id                       IN     NUMBER,
    x_p_ssn                             IN     VARCHAR2,
    x_p_last_name                       IN     VARCHAR2,
    x_p_first_name                      IN     VARCHAR2,
    x_p_middle_name                     IN     VARCHAR2,
    x_p_date_of_birth                   IN     DATE,
    x_p_citizenship_status              IN     VARCHAR2,
    x_p_alien_reg_num                   IN     VARCHAR2,
    x_p_license_num                     IN     VARCHAR2,
    x_p_license_state                   IN     VARCHAR2,
    x_p_permt_addr1                     IN     VARCHAR2,
    x_p_permt_addr2                     IN     VARCHAR2,
    x_p_permt_city                      IN     VARCHAR2,
    x_p_permt_state                     IN     VARCHAR2,
    x_p_permt_province                  IN     VARCHAR2,
    x_p_permt_county                    IN     VARCHAR2,
    x_p_permt_country                   IN     VARCHAR2,
    x_p_permt_zip                       IN     VARCHAR2,
    x_p_email_addr                      IN     VARCHAR2,
    x_p_phone                           IN     VARCHAR2,
    x_status                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        batch_seq_num,
        loan_id,
        loan_number,
        loan_amt_offered,
        loan_amt_accepted,
        loan_per_begin_date,
        loan_per_end_date,
        person_id,
        s_ssn,
        s_first_name,
        s_last_name,
        s_middle_name,
        s_date_of_birth,
        s_citizenship_status,
        s_alien_reg_number,
        s_license_num,
        s_license_state,
        s_permt_addr1,
        s_permt_addr2,
        s_permt_city,
        s_permt_state,
        s_permt_province,
        s_permt_county,
        s_permt_country,
        s_permt_zip,
        s_email_addr,
        s_phone,
        p_person_id,
        p_ssn,
        p_last_name,
        p_first_name,
        p_middle_name,
        p_date_of_birth,
        p_citizenship_status,
        p_alien_reg_num,
        p_license_num,
        p_license_state,
        p_permt_addr1,
        p_permt_addr2,
        p_permt_city,
        p_permt_state,
        p_permt_province,
        p_permt_county,
        p_permt_country,
        p_permt_zip,
        p_email_addr,
        p_phone,
        status
      FROM  igf_sl_dl_pnote_p_p_all
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
        (tlinfo.batch_seq_num = x_batch_seq_num)
        AND (tlinfo.loan_id = x_loan_id)
        AND (tlinfo.loan_number = x_loan_number)
        AND ((tlinfo.loan_amt_offered = x_loan_amt_offered) OR ((tlinfo.loan_amt_offered IS NULL) AND (X_loan_amt_offered IS NULL)))
        AND ((tlinfo.loan_amt_accepted = x_loan_amt_accepted) OR ((tlinfo.loan_amt_accepted IS NULL) AND (X_loan_amt_accepted IS NULL)))
        AND ((tlinfo.loan_per_begin_date = x_loan_per_begin_date) OR ((tlinfo.loan_per_begin_date IS NULL) AND (X_loan_per_begin_date IS NULL)))
        AND ((tlinfo.loan_per_end_date = x_loan_per_end_date) OR ((tlinfo.loan_per_end_date IS NULL) AND (X_loan_per_end_date IS NULL)))
        AND ((tlinfo.person_id = x_person_id) OR ((tlinfo.person_id IS NULL) AND (X_person_id IS NULL)))
        AND ((tlinfo.s_ssn = x_s_ssn) OR ((tlinfo.s_ssn IS NULL) AND (X_s_ssn IS NULL)))
        AND ((tlinfo.s_first_name = x_s_first_name) OR ((tlinfo.s_first_name IS NULL) AND (X_s_first_name IS NULL)))
        AND ((tlinfo.s_last_name = x_s_last_name) OR ((tlinfo.s_last_name IS NULL) AND (X_s_last_name IS NULL)))
        AND ((tlinfo.s_middle_name = x_s_middle_name) OR ((tlinfo.s_middle_name IS NULL) AND (X_s_middle_name IS NULL)))
        AND ((tlinfo.s_date_of_birth = x_s_date_of_birth) OR ((tlinfo.s_date_of_birth IS NULL) AND (X_s_date_of_birth IS NULL)))
        AND ((tlinfo.s_citizenship_status = x_s_citizenship_status) OR ((tlinfo.s_citizenship_status IS NULL) AND (X_s_citizenship_status IS NULL)))
        AND ((tlinfo.s_alien_reg_number = x_s_alien_reg_number) OR ((tlinfo.s_alien_reg_number IS NULL) AND (X_s_alien_reg_number IS NULL)))
        AND ((tlinfo.s_license_num = x_s_license_num) OR ((tlinfo.s_license_num IS NULL) AND (X_s_license_num IS NULL)))
        AND ((tlinfo.s_license_state = x_s_license_state) OR ((tlinfo.s_license_state IS NULL) AND (X_s_license_state IS NULL)))
        AND ((tlinfo.s_permt_addr1 = x_s_permt_addr1) OR ((tlinfo.s_permt_addr1 IS NULL) AND (X_s_permt_addr1 IS NULL)))
        AND ((tlinfo.s_permt_addr2 = x_s_permt_addr2) OR ((tlinfo.s_permt_addr2 IS NULL) AND (X_s_permt_addr2 IS NULL)))
        AND ((tlinfo.s_permt_city = x_s_permt_city) OR ((tlinfo.s_permt_city IS NULL) AND (X_s_permt_city IS NULL)))
        AND ((tlinfo.s_permt_state = x_s_permt_state) OR ((tlinfo.s_permt_state IS NULL) AND (X_s_permt_state IS NULL)))
        AND ((tlinfo.s_permt_province = x_s_permt_province) OR ((tlinfo.s_permt_province IS NULL) AND (X_s_permt_province IS NULL)))
        AND ((tlinfo.s_permt_county = x_s_permt_county) OR ((tlinfo.s_permt_county IS NULL) AND (X_s_permt_county IS NULL)))
        AND ((tlinfo.s_permt_country = x_s_permt_country) OR ((tlinfo.s_permt_country IS NULL) AND (X_s_permt_country IS NULL)))
        AND ((tlinfo.s_permt_zip = x_s_permt_zip) OR ((tlinfo.s_permt_zip IS NULL) AND (X_s_permt_zip IS NULL)))
        AND ((tlinfo.s_email_addr = x_s_email_addr) OR ((tlinfo.s_email_addr IS NULL) AND (X_s_email_addr IS NULL)))
        AND ((tlinfo.s_phone = x_s_phone) OR ((tlinfo.s_phone IS NULL) AND (X_s_phone IS NULL)))
        AND ((tlinfo.p_person_id = x_p_person_id) OR ((tlinfo.p_person_id IS NULL) AND (X_p_person_id IS NULL)))
        AND ((tlinfo.p_ssn = x_p_ssn) OR ((tlinfo.p_ssn IS NULL) AND (X_p_ssn IS NULL)))
        AND ((tlinfo.p_last_name = x_p_last_name) OR ((tlinfo.p_last_name IS NULL) AND (X_p_last_name IS NULL)))
        AND ((tlinfo.p_first_name = x_p_first_name) OR ((tlinfo.p_first_name IS NULL) AND (X_p_first_name IS NULL)))
        AND ((tlinfo.p_middle_name = x_p_middle_name) OR ((tlinfo.p_middle_name IS NULL) AND (X_p_middle_name IS NULL)))
        AND ((tlinfo.p_date_of_birth = x_p_date_of_birth) OR ((tlinfo.p_date_of_birth IS NULL) AND (X_p_date_of_birth IS NULL)))
        AND ((tlinfo.p_citizenship_status = x_p_citizenship_status) OR ((tlinfo.p_citizenship_status IS NULL) AND (X_p_citizenship_status IS NULL)))
        AND ((tlinfo.p_alien_reg_num = x_p_alien_reg_num) OR ((tlinfo.p_alien_reg_num IS NULL) AND (X_p_alien_reg_num IS NULL)))
        AND ((tlinfo.p_license_num = x_p_license_num) OR ((tlinfo.p_license_num IS NULL) AND (X_p_license_num IS NULL)))
        AND ((tlinfo.p_license_state = x_p_license_state) OR ((tlinfo.p_license_state IS NULL) AND (X_p_license_state IS NULL)))
        AND ((tlinfo.p_permt_addr1 = x_p_permt_addr1) OR ((tlinfo.p_permt_addr1 IS NULL) AND (X_p_permt_addr1 IS NULL)))
        AND ((tlinfo.p_permt_addr2 = x_p_permt_addr2) OR ((tlinfo.p_permt_addr2 IS NULL) AND (X_p_permt_addr2 IS NULL)))
        AND ((tlinfo.p_permt_city = x_p_permt_city) OR ((tlinfo.p_permt_city IS NULL) AND (X_p_permt_city IS NULL)))
        AND ((tlinfo.p_permt_state = x_p_permt_state) OR ((tlinfo.p_permt_state IS NULL) AND (X_p_permt_state IS NULL)))
        AND ((tlinfo.p_permt_province = x_p_permt_province) OR ((tlinfo.p_permt_province IS NULL) AND (X_p_permt_province IS NULL)))
        AND ((tlinfo.p_permt_county = x_p_permt_county) OR ((tlinfo.p_permt_county IS NULL) AND (X_p_permt_county IS NULL)))
        AND ((tlinfo.p_permt_country = x_p_permt_country) OR ((tlinfo.p_permt_country IS NULL) AND (X_p_permt_country IS NULL)))
        AND ((tlinfo.p_permt_zip = x_p_permt_zip) OR ((tlinfo.p_permt_zip IS NULL) AND (X_p_permt_zip IS NULL)))
        AND ((tlinfo.p_email_addr = x_p_email_addr) OR ((tlinfo.p_email_addr IS NULL) AND (X_p_email_addr IS NULL)))
        AND ((tlinfo.p_phone = x_p_phone) OR ((tlinfo.p_phone IS NULL) AND (X_p_phone IS NULL)))
        AND ((tlinfo.status = x_status) OR ((tlinfo.status IS NULL) AND (X_status IS NULL)))
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
    x_pnpp_id                           IN     NUMBER,
    x_batch_seq_num                     IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_amt_offered                  IN     NUMBER,
    x_loan_amt_accepted                 IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_person_id                         IN     NUMBER,
    x_s_ssn                             IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_alien_reg_number                IN     VARCHAR2,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_province                  IN     VARCHAR2,
    x_s_permt_county                    IN     VARCHAR2,
    x_s_permt_country                   IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_phone                           IN     VARCHAR2,
    x_p_person_id                       IN     NUMBER,
    x_p_ssn                             IN     VARCHAR2,
    x_p_last_name                       IN     VARCHAR2,
    x_p_first_name                      IN     VARCHAR2,
    x_p_middle_name                     IN     VARCHAR2,
    x_p_date_of_birth                   IN     DATE,
    x_p_citizenship_status              IN     VARCHAR2,
    x_p_alien_reg_num                   IN     VARCHAR2,
    x_p_license_num                     IN     VARCHAR2,
    x_p_license_state                   IN     VARCHAR2,
    x_p_permt_addr1                     IN     VARCHAR2,
    x_p_permt_addr2                     IN     VARCHAR2,
    x_p_permt_city                      IN     VARCHAR2,
    x_p_permt_state                     IN     VARCHAR2,
    x_p_permt_province                  IN     VARCHAR2,
    x_p_permt_county                    IN     VARCHAR2,
    x_p_permt_country                   IN     VARCHAR2,
    x_p_permt_zip                       IN     VARCHAR2,
    x_p_email_addr                      IN     VARCHAR2,
    x_p_phone                           IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_pnpp_id                           => x_pnpp_id,
      x_batch_seq_num                     => x_batch_seq_num,
      x_loan_id                           => x_loan_id,
      x_loan_number                       => x_loan_number,
      x_loan_amt_offered                  => x_loan_amt_offered,
      x_loan_amt_accepted                 => x_loan_amt_accepted,
      x_loan_per_begin_date               => x_loan_per_begin_date,
      x_loan_per_end_date                 => x_loan_per_end_date,
      x_person_id                         => x_person_id,
      x_s_ssn                             => x_s_ssn,
      x_s_first_name                      => x_s_first_name,
      x_s_last_name                       => x_s_last_name,
      x_s_middle_name                     => x_s_middle_name,
      x_s_date_of_birth                   => x_s_date_of_birth,
      x_s_citizenship_status              => x_s_citizenship_status,
      x_s_alien_reg_number                => x_s_alien_reg_number,
      x_s_license_num                     => x_s_license_num,
      x_s_license_state                   => x_s_license_state,
      x_s_permt_addr1                     => x_s_permt_addr1,
      x_s_permt_addr2                     => x_s_permt_addr2,
      x_s_permt_city                      => x_s_permt_city,
      x_s_permt_state                     => x_s_permt_state,
      x_s_permt_province                  => x_s_permt_province,
      x_s_permt_county                    => x_s_permt_county,
      x_s_permt_country                   => x_s_permt_country,
      x_s_permt_zip                       => x_s_permt_zip,
      x_s_email_addr                      => x_s_email_addr,
      x_s_phone                           => x_s_phone,
      x_p_person_id                       => x_p_person_id,
      x_p_ssn                             => x_p_ssn,
      x_p_last_name                       => x_p_last_name,
      x_p_first_name                      => x_p_first_name,
      x_p_middle_name                     => x_p_middle_name,
      x_p_date_of_birth                   => x_p_date_of_birth,
      x_p_citizenship_status              => x_p_citizenship_status,
      x_p_alien_reg_num                   => x_p_alien_reg_num,
      x_p_license_num                     => x_p_license_num,
      x_p_license_state                   => x_p_license_state,
      x_p_permt_addr1                     => x_p_permt_addr1,
      x_p_permt_addr2                     => x_p_permt_addr2,
      x_p_permt_city                      => x_p_permt_city,
      x_p_permt_state                     => x_p_permt_state,
      x_p_permt_province                  => x_p_permt_province,
      x_p_permt_county                    => x_p_permt_county,
      x_p_permt_country                   => x_p_permt_country,
      x_p_permt_zip                       => x_p_permt_zip,
      x_p_email_addr                      => x_p_email_addr,
      x_p_phone                           => x_p_phone,
      x_status                            => x_status,
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

    UPDATE igf_sl_dl_pnote_p_p_all
      SET
        batch_seq_num                     = new_references.batch_seq_num,
        loan_id                           = new_references.loan_id,
        loan_number                       = new_references.loan_number,
        loan_amt_offered                  = new_references.loan_amt_offered,
        loan_amt_accepted                 = new_references.loan_amt_accepted,
        loan_per_begin_date               = new_references.loan_per_begin_date,
        loan_per_end_date                 = new_references.loan_per_end_date,
        person_id                         = new_references.person_id,
        s_ssn                             = new_references.s_ssn,
        s_first_name                      = new_references.s_first_name,
        s_last_name                       = new_references.s_last_name,
        s_middle_name                     = new_references.s_middle_name,
        s_date_of_birth                   = new_references.s_date_of_birth,
        s_citizenship_status              = new_references.s_citizenship_status,
        s_alien_reg_number                = new_references.s_alien_reg_number,
        s_license_num                     = new_references.s_license_num,
        s_license_state                   = new_references.s_license_state,
        s_permt_addr1                     = new_references.s_permt_addr1,
        s_permt_addr2                     = new_references.s_permt_addr2,
        s_permt_city                      = new_references.s_permt_city,
        s_permt_state                     = new_references.s_permt_state,
        s_permt_province                  = new_references.s_permt_province,
        s_permt_county                    = new_references.s_permt_county,
        s_permt_country                   = new_references.s_permt_country,
        s_permt_zip                       = new_references.s_permt_zip,
        s_email_addr                      = new_references.s_email_addr,
        s_phone                           = new_references.s_phone,
        p_person_id                       = new_references.p_person_id,
        p_ssn                             = new_references.p_ssn,
        p_last_name                       = new_references.p_last_name,
        p_first_name                      = new_references.p_first_name,
        p_middle_name                     = new_references.p_middle_name,
        p_date_of_birth                   = new_references.p_date_of_birth,
        p_citizenship_status              = new_references.p_citizenship_status,
        p_alien_reg_num                   = new_references.p_alien_reg_num,
        p_license_num                     = new_references.p_license_num,
        p_license_state                   = new_references.p_license_state,
        p_permt_addr1                     = new_references.p_permt_addr1,
        p_permt_addr2                     = new_references.p_permt_addr2,
        p_permt_city                      = new_references.p_permt_city,
        p_permt_state                     = new_references.p_permt_state,
        p_permt_province                  = new_references.p_permt_province,
        p_permt_county                    = new_references.p_permt_county,
        p_permt_country                   = new_references.p_permt_country,
        p_permt_zip                       = new_references.p_permt_zip,
        p_email_addr                      = new_references.p_email_addr,
        p_phone                           = new_references.p_phone,
        status                            = new_references.status,
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
    x_pnpp_id                           IN OUT NOCOPY NUMBER,
    x_batch_seq_num                     IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_amt_offered                  IN     NUMBER,
    x_loan_amt_accepted                 IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_person_id                         IN     NUMBER,
    x_s_ssn                             IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_alien_reg_number                IN     VARCHAR2,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_province                  IN     VARCHAR2,
    x_s_permt_county                    IN     VARCHAR2,
    x_s_permt_country                   IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_phone                           IN     VARCHAR2,
    x_p_person_id                       IN     NUMBER,
    x_p_ssn                             IN     VARCHAR2,
    x_p_last_name                       IN     VARCHAR2,
    x_p_first_name                      IN     VARCHAR2,
    x_p_middle_name                     IN     VARCHAR2,
    x_p_date_of_birth                   IN     DATE,
    x_p_citizenship_status              IN     VARCHAR2,
    x_p_alien_reg_num                   IN     VARCHAR2,
    x_p_license_num                     IN     VARCHAR2,
    x_p_license_state                   IN     VARCHAR2,
    x_p_permt_addr1                     IN     VARCHAR2,
    x_p_permt_addr2                     IN     VARCHAR2,
    x_p_permt_city                      IN     VARCHAR2,
    x_p_permt_state                     IN     VARCHAR2,
    x_p_permt_province                  IN     VARCHAR2,
    x_p_permt_county                    IN     VARCHAR2,
    x_p_permt_country                   IN     VARCHAR2,
    x_p_permt_zip                       IN     VARCHAR2,
    x_p_email_addr                      IN     VARCHAR2,
    x_p_phone                           IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_dl_pnote_p_p_all
      WHERE    pnpp_id                           = x_pnpp_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_pnpp_id,
        x_batch_seq_num,
        x_loan_id,
        x_loan_number,
        x_loan_amt_offered,
        x_loan_amt_accepted,
        x_loan_per_begin_date,
        x_loan_per_end_date,
        x_person_id,
        x_s_ssn,
        x_s_first_name,
        x_s_last_name,
        x_s_middle_name,
        x_s_date_of_birth,
        x_s_citizenship_status,
        x_s_alien_reg_number,
        x_s_license_num,
        x_s_license_state,
        x_s_permt_addr1,
        x_s_permt_addr2,
        x_s_permt_city,
        x_s_permt_state,
        x_s_permt_province,
        x_s_permt_county,
        x_s_permt_country,
        x_s_permt_zip,
        x_s_email_addr,
        x_s_phone,
        x_p_person_id,
        x_p_ssn,
        x_p_last_name,
        x_p_first_name,
        x_p_middle_name,
        x_p_date_of_birth,
        x_p_citizenship_status,
        x_p_alien_reg_num,
        x_p_license_num,
        x_p_license_state,
        x_p_permt_addr1,
        x_p_permt_addr2,
        x_p_permt_city,
        x_p_permt_state,
        x_p_permt_province,
        x_p_permt_county,
        x_p_permt_country,
        x_p_permt_zip,
        x_p_email_addr,
        x_p_phone,
        x_status,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_pnpp_id,
      x_batch_seq_num,
      x_loan_id,
      x_loan_number,
      x_loan_amt_offered,
      x_loan_amt_accepted,
      x_loan_per_begin_date,
      x_loan_per_end_date,
      x_person_id,
      x_s_ssn,
      x_s_first_name,
      x_s_last_name,
      x_s_middle_name,
      x_s_date_of_birth,
      x_s_citizenship_status,
      x_s_alien_reg_number,
      x_s_license_num,
      x_s_license_state,
      x_s_permt_addr1,
      x_s_permt_addr2,
      x_s_permt_city,
      x_s_permt_state,
      x_s_permt_province,
      x_s_permt_county,
      x_s_permt_country,
      x_s_permt_zip,
      x_s_email_addr,
      x_s_phone,
      x_p_person_id,
      x_p_ssn,
      x_p_last_name,
      x_p_first_name,
      x_p_middle_name,
      x_p_date_of_birth,
      x_p_citizenship_status,
      x_p_alien_reg_num,
      x_p_license_num,
      x_p_license_state,
      x_p_permt_addr1,
      x_p_permt_addr2,
      x_p_permt_city,
      x_p_permt_state,
      x_p_permt_province,
      x_p_permt_county,
      x_p_permt_country,
      x_p_permt_zip,
      x_p_email_addr,
      x_p_phone,
      x_status,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
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

    DELETE FROM igf_sl_dl_pnote_p_p_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_dl_pnote_p_p_pkg;

/
