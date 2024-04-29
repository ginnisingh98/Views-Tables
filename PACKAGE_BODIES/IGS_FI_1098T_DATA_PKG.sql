--------------------------------------------------------
--  DDL for Package Body IGS_FI_1098T_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_1098T_DATA_PKG" AS
/* $Header: IGSSIE8B.pls 120.0 2005/09/09 19:11:39 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_1098t_data%ROWTYPE;
  new_references igs_fi_1098t_data%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_stu_1098t_id                      IN     NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_extract_date                      IN     DATE,
    x_party_name                        IN     VARCHAR2,
    x_taxid                             IN     VARCHAR2,
    x_stu_name_control                  IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_refund_amt                        IN     NUMBER,
    x_half_time_flag                    IN     VARCHAR2,
    x_grad_flag                         IN     VARCHAR2,
    x_special_data_entry                IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_irs_filed_flag                    IN     VARCHAR2,
    x_correction_flag                   IN     VARCHAR2,
    x_correction_type_code              IN     VARCHAR2,
    x_stmnt_print_flag                  IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_payment_amt                       IN     NUMBER,
    x_billed_amt                        IN     NUMBER,
    x_adj_amt                           IN     NUMBER,
    x_fin_aid_amt                       IN     NUMBER,
    x_fin_aid_adj_amt                   IN     NUMBER,
    x_next_acad_flag                    IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 01-MAY-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_1098t_data
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
    new_references.object_version_number             := x_object_version_number;
    new_references.stu_1098t_id                      := x_stu_1098t_id;
    new_references.tax_year_name                     := x_tax_year_name;
    new_references.party_id                          := x_party_id;
    new_references.extract_date                      := x_extract_date;
    new_references.party_name                        := x_party_name;
    new_references.taxid                             := x_taxid;
    new_references.stu_name_control                  := x_stu_name_control;
    new_references.country                           := x_country;
    new_references.address1                          := x_address1;
    new_references.address2                          := x_address2;
    new_references.refund_amt                        := x_refund_amt;
    new_references.half_time_flag                    := x_half_time_flag;
    new_references.grad_flag                         := x_grad_flag;
    new_references.special_data_entry                := x_special_data_entry;
    new_references.status_code                       := x_status_code;
    new_references.error_code                        := x_error_code;
    new_references.file_name                         := x_file_name;
    new_references.irs_filed_flag                    := x_irs_filed_flag;
    new_references.correction_flag                   := x_correction_flag;
    new_references.correction_type_code              := x_correction_type_code;
    new_references.stmnt_print_flag                  := x_stmnt_print_flag;
    new_references.override_flag                     := x_override_flag;
    new_references.address3                          := x_address3;
    new_references.address4                          := x_address4;
    new_references.city                              := x_city;
    new_references.postal_code                       := x_postal_code;
    new_references.state                             := x_state;
    new_references.province                          := x_province;
    new_references.county                            := x_county;
    new_references.delivery_point_code               := x_delivery_point_code;
    new_references.payment_amt                       := x_payment_amt;
    new_references.billed_amt                        := x_billed_amt;
    new_references.adj_amt                           := x_adj_amt;
    new_references.fin_aid_amt                       := x_fin_aid_amt;
    new_references.fin_aid_adj_amt                   := x_fin_aid_adj_amt;
    new_references.next_acad_flag                    := x_next_acad_flag;
    new_references.batch_id                          := x_batch_id;

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
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 01-MAY-2005
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_hzp(cp_party_id        hz_parties.party_id%TYPE) IS
      SELECT 'x'
      FROM   hz_parties
      WHERE  party_id = cp_party_id;

    l_var      VARCHAR2(1);
  BEGIN

    IF (((old_references.batch_id = new_references.batch_id)) OR
        ((new_references.batch_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_1098t_batchs_pkg.get_pk_for_validation (
                new_references.batch_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.party_id = new_references.party_id)) OR
        ((new_references.party_id IS NULL))) THEN
      NULL;
    ELSE
      OPEN cur_hzp(new_references.party_id);
      FETCH cur_hzp INTO l_var;
      IF cur_hzp%NOTFOUND THEN
        CLOSE cur_hzp;
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      CLOSE cur_hzp;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 01-MAY-2005
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    null;
  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_stu_1098t_id                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 01-MAY-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_1098t_data
      WHERE    stu_1098t_id = x_stu_1098t_id
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
    x_object_version_number             IN     NUMBER,
    x_stu_1098t_id                      IN     NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_extract_date                      IN     DATE,
    x_party_name                        IN     VARCHAR2,
    x_taxid                             IN     VARCHAR2,
    x_stu_name_control                  IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_refund_amt                        IN     NUMBER,
    x_half_time_flag                    IN     VARCHAR2,
    x_grad_flag                         IN     VARCHAR2,
    x_special_data_entry                IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_irs_filed_flag                    IN     VARCHAR2,
    x_correction_flag                   IN     VARCHAR2,
    x_correction_type_code              IN     VARCHAR2,
    x_stmnt_print_flag                  IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_payment_amt                       IN     NUMBER,
    x_billed_amt                        IN     NUMBER,
    x_adj_amt                           IN     NUMBER,
    x_fin_aid_amt                       IN     NUMBER,
    x_fin_aid_adj_amt                   IN     NUMBER,
    x_next_acad_flag                    IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 01-MAY-2005
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
      x_object_version_number,
      x_stu_1098t_id,
      x_tax_year_name,
      x_party_id,
      x_extract_date,
      x_party_name,
      x_taxid,
      x_stu_name_control,
      x_country,
      x_address1,
      x_address2,
      x_refund_amt,
      x_half_time_flag,
      x_grad_flag,
      x_special_data_entry,
      x_status_code,
      x_error_code,
      x_file_name,
      x_irs_filed_flag,
      x_correction_flag,
      x_correction_type_code,
      x_stmnt_print_flag,
      x_override_flag,
      x_address3,
      x_address4,
      x_city,
      x_postal_code,
      x_state,
      x_province,
      x_county,
      x_delivery_point_code,
      x_payment_amt,
      x_billed_amt,
      x_adj_amt,
      x_fin_aid_amt,
      x_fin_aid_adj_amt,
      x_next_acad_flag,
      x_batch_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.stu_1098t_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.stu_1098t_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stu_1098t_id                      IN OUT NOCOPY NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_extract_date                      IN     DATE,
    x_party_name                        IN     VARCHAR2,
    x_taxid                             IN     VARCHAR2,
    x_stu_name_control                  IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_refund_amt                        IN     NUMBER,
    x_half_time_flag                    IN     VARCHAR2,
    x_grad_flag                         IN     VARCHAR2,
    x_special_data_entry                IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_irs_filed_flag                    IN     VARCHAR2,
    x_correction_flag                   IN     VARCHAR2,
    x_correction_type_code              IN     VARCHAR2,
    x_stmnt_print_flag                  IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_payment_amt                       IN     NUMBER,
    x_billed_amt                        IN     NUMBER,
    x_adj_amt                           IN     NUMBER,
    x_fin_aid_amt                       IN     NUMBER,
    x_fin_aid_adj_amt                   IN     NUMBER,
    x_next_acad_flag                    IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 01-MAY-2005
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_1098T_DATA_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_stu_1098t_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_object_version_number             => 1,
      x_stu_1098t_id                      => x_stu_1098t_id,
      x_tax_year_name                     => x_tax_year_name,
      x_party_id                          => x_party_id,
      x_extract_date                      => x_extract_date,
      x_party_name                        => x_party_name,
      x_taxid                             => x_taxid,
      x_stu_name_control                  => x_stu_name_control,
      x_country                           => x_country,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_refund_amt                        => x_refund_amt,
      x_half_time_flag                    => x_half_time_flag,
      x_grad_flag                         => x_grad_flag,
      x_special_data_entry                => x_special_data_entry,
      x_status_code                       => x_status_code,
      x_error_code                        => x_error_code,
      x_file_name                         => x_file_name,
      x_irs_filed_flag                    => x_irs_filed_flag,
      x_correction_flag                   => x_correction_flag,
      x_correction_type_code              => x_correction_type_code,
      x_stmnt_print_flag                  => x_stmnt_print_flag,
      x_override_flag                     => x_override_flag,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_city                              => x_city,
      x_postal_code                       => x_postal_code,
      x_state                             => x_state,
      x_province                          => x_province,
      x_county                            => x_county,
      x_delivery_point_code               => x_delivery_point_code,
      x_payment_amt                       => x_payment_amt,
      x_billed_amt                        => x_billed_amt,
      x_adj_amt                           => x_adj_amt,
      x_fin_aid_amt                       => x_fin_aid_amt,
      x_fin_aid_adj_amt                   => x_fin_aid_adj_amt,
      x_next_acad_flag                    => x_next_acad_flag,
      x_batch_id                          => x_batch_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_1098t_data (
      object_version_number,
      stu_1098t_id,
      tax_year_name,
      party_id,
      extract_date,
      party_name,
      taxid,
      stu_name_control,
      country,
      address1,
      address2,
      refund_amt,
      half_time_flag,
      grad_flag,
      special_data_entry,
      status_code,
      error_code,
      file_name,
      irs_filed_flag,
      correction_flag,
      correction_type_code,
      stmnt_print_flag,
      override_flag,
      address3,
      address4,
      city,
      postal_code,
      state,
      province,
      county,
      delivery_point_code,
      payment_amt,
      billed_amt,
      adj_amt,
      fin_aid_amt,
      fin_aid_adj_amt,
      next_acad_flag,
      batch_id,
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
      new_references.object_version_number,
      igs_fi_1098t_data_s.NEXTVAL,
      new_references.tax_year_name,
      new_references.party_id,
      new_references.extract_date,
      new_references.party_name,
      new_references.taxid,
      new_references.stu_name_control,
      new_references.country,
      new_references.address1,
      new_references.address2,
      new_references.refund_amt,
      new_references.half_time_flag,
      new_references.grad_flag,
      new_references.special_data_entry,
      new_references.status_code,
      new_references.error_code,
      new_references.file_name,
      new_references.irs_filed_flag,
      new_references.correction_flag,
      new_references.correction_type_code,
      new_references.stmnt_print_flag,
      new_references.override_flag,
      new_references.address3,
      new_references.address4,
      new_references.city,
      new_references.postal_code,
      new_references.state,
      new_references.province,
      new_references.county,
      new_references.delivery_point_code,
      new_references.payment_amt,
      new_references.billed_amt,
      new_references.adj_amt,
      new_references.fin_aid_amt,
      new_references.fin_aid_adj_amt,
      new_references.next_acad_flag,
      new_references.batch_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, stu_1098t_id INTO x_rowid, x_stu_1098t_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_stu_1098t_id                      IN     NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_extract_date                      IN     DATE,
    x_party_name                        IN     VARCHAR2,
    x_taxid                             IN     VARCHAR2,
    x_stu_name_control                  IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_refund_amt                        IN     NUMBER,
    x_half_time_flag                    IN     VARCHAR2,
    x_grad_flag                         IN     VARCHAR2,
    x_special_data_entry                IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_irs_filed_flag                    IN     VARCHAR2,
    x_correction_flag                   IN     VARCHAR2,
    x_correction_type_code              IN     VARCHAR2,
    x_stmnt_print_flag                  IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_payment_amt                       IN     NUMBER,
    x_billed_amt                        IN     NUMBER,
    x_adj_amt                           IN     NUMBER,
    x_fin_aid_amt                       IN     NUMBER,
    x_fin_aid_adj_amt                   IN     NUMBER,
    x_next_acad_flag                    IN     VARCHAR2,
    x_batch_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 01-MAY-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        object_version_number,
        tax_year_name,
        party_id,
        extract_date,
        party_name,
        taxid,
        stu_name_control,
        country,
        address1,
        address2,
        refund_amt,
        half_time_flag,
        grad_flag,
        special_data_entry,
        status_code,
        error_code,
        file_name,
        irs_filed_flag,
        correction_flag,
        correction_type_code,
        stmnt_print_flag,
        override_flag,
        address3,
        address4,
        city,
        postal_code,
        state,
        province,
        county,
        delivery_point_code,
        payment_amt,
        billed_amt,
        adj_amt,
        fin_aid_amt,
        fin_aid_adj_amt,
        next_acad_flag,
        batch_id
      FROM  igs_fi_1098t_data
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

    IF ((tlinfo.tax_year_name = x_tax_year_name)
        AND (tlinfo.party_id = x_party_id)
        AND (tlinfo.extract_date = x_extract_date)
        AND (tlinfo.party_name = x_party_name)
        AND (tlinfo.taxid = x_taxid)
        AND ((tlinfo.stu_name_control = x_stu_name_control) OR ((tlinfo.stu_name_control IS NULL) AND (X_stu_name_control IS NULL)))
        AND (tlinfo.country = x_country)
        AND ((tlinfo.address1 = x_address1) OR ((tlinfo.address1 IS NULL) AND (X_address1 IS NULL)))
        AND ((tlinfo.address2 = x_address2) OR ((tlinfo.address2 IS NULL) AND (X_address2 IS NULL)))
        AND (tlinfo.refund_amt = x_refund_amt)
        AND (tlinfo.half_time_flag = x_half_time_flag)
        AND (tlinfo.grad_flag = x_grad_flag)
        AND ((tlinfo.special_data_entry = x_special_data_entry) OR ((tlinfo.special_data_entry IS NULL) AND (X_special_data_entry IS NULL)))
        AND (tlinfo.status_code = x_status_code)
        AND ((tlinfo.error_code = x_error_code) OR ((tlinfo.error_code IS NULL) AND (X_error_code IS NULL)))
        AND ((tlinfo.file_name = x_file_name) OR ((tlinfo.file_name IS NULL) AND (X_file_name IS NULL)))
        AND (tlinfo.irs_filed_flag = x_irs_filed_flag)
        AND (tlinfo.correction_flag = x_correction_flag)
        AND ((tlinfo.correction_type_code = x_correction_type_code) OR ((tlinfo.correction_type_code IS NULL) AND (X_correction_type_code IS NULL)))
        AND (tlinfo.stmnt_print_flag = x_stmnt_print_flag)
        AND (tlinfo.override_flag = x_override_flag)
        AND ((tlinfo.address3 = x_address3) OR ((tlinfo.address3 IS NULL) AND (X_address3 IS NULL)))
        AND ((tlinfo.address4 = x_address4) OR ((tlinfo.address4 IS NULL) AND (X_address4 IS NULL)))
        AND (tlinfo.city = x_city)
        AND (tlinfo.postal_code = x_postal_code)
        AND (tlinfo.state = x_state)
        AND ((tlinfo.province = x_province) OR ((tlinfo.province IS NULL) AND (X_province IS NULL)))
        AND ((tlinfo.county = x_county) OR ((tlinfo.county IS NULL) AND (X_county IS NULL)))
        AND ((tlinfo.delivery_point_code = x_delivery_point_code) OR ((tlinfo.delivery_point_code IS NULL) AND (X_delivery_point_code IS NULL)))
        AND ((tlinfo.payment_amt = x_payment_amt) OR ((tlinfo.payment_amt IS NULL) AND (X_payment_amt IS NULL)))
        AND (tlinfo.billed_amt = x_billed_amt)
        AND (tlinfo.adj_amt = x_adj_amt)
        AND (tlinfo.fin_aid_amt = x_fin_aid_amt)
        AND (tlinfo.fin_aid_adj_amt = x_fin_aid_adj_amt)
        AND (tlinfo.next_acad_flag = x_next_acad_flag)
        AND ((tlinfo.batch_id = x_batch_id) OR ((tlinfo.batch_id IS NULL) AND (X_batch_id IS NULL)))
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
    x_stu_1098t_id                      IN     NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_extract_date                      IN     DATE,
    x_party_name                        IN     VARCHAR2,
    x_taxid                             IN     VARCHAR2,
    x_stu_name_control                  IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_refund_amt                        IN     NUMBER,
    x_half_time_flag                    IN     VARCHAR2,
    x_grad_flag                         IN     VARCHAR2,
    x_special_data_entry                IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_irs_filed_flag                    IN     VARCHAR2,
    x_correction_flag                   IN     VARCHAR2,
    x_correction_type_code              IN     VARCHAR2,
    x_stmnt_print_flag                  IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_payment_amt                       IN     NUMBER,
    x_billed_amt                        IN     NUMBER,
    x_adj_amt                           IN     NUMBER,
    x_fin_aid_amt                       IN     NUMBER,
    x_fin_aid_adj_amt                   IN     NUMBER,
    x_next_acad_flag                    IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 01-MAY-2005
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

    CURSOR cur_1098t_data(cp_rowid         varchar2) IS
      SELECT object_version_number
      FROM   igs_fi_1098t_data
      WHERE  rowid = cp_rowid
      FOR UPDATE NOWAIT;

    l_n_object_version_number           igs_fi_1098t_data.object_version_number%TYPE;

  BEGIN

    OPEN cur_1098t_data(x_rowid);
    FETCH cur_1098t_data INTO l_n_object_version_number;
    CLOSE cur_1098t_data;

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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_1098T_DATA_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    l_n_object_version_number := l_n_object_version_number + 1;



    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_object_version_number             => l_n_object_version_number,
      x_stu_1098t_id                      => x_stu_1098t_id,
      x_tax_year_name                     => x_tax_year_name,
      x_party_id                          => x_party_id,
      x_extract_date                      => x_extract_date,
      x_party_name                        => x_party_name,
      x_taxid                             => x_taxid,
      x_stu_name_control                  => x_stu_name_control,
      x_country                           => x_country,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_refund_amt                        => x_refund_amt,
      x_half_time_flag                    => x_half_time_flag,
      x_grad_flag                         => x_grad_flag,
      x_special_data_entry                => x_special_data_entry,
      x_status_code                       => x_status_code,
      x_error_code                        => x_error_code,
      x_file_name                         => x_file_name,
      x_irs_filed_flag                    => x_irs_filed_flag,
      x_correction_flag                   => x_correction_flag,
      x_correction_type_code              => x_correction_type_code,
      x_stmnt_print_flag                  => x_stmnt_print_flag,
      x_override_flag                     => x_override_flag,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_city                              => x_city,
      x_postal_code                       => x_postal_code,
      x_state                             => x_state,
      x_province                          => x_province,
      x_county                            => x_county,
      x_delivery_point_code               => x_delivery_point_code,
      x_payment_amt                       => x_payment_amt,
      x_billed_amt                        => x_billed_amt,
      x_adj_amt                           => x_adj_amt,
      x_fin_aid_amt                       => x_fin_aid_amt,
      x_fin_aid_adj_amt                   => x_fin_aid_adj_amt,
      x_next_acad_flag                    => x_next_acad_flag,
      x_batch_id                          => x_batch_id,
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

    UPDATE igs_fi_1098t_data
      SET
        object_version_number             = new_references.object_version_number,
        tax_year_name                     = new_references.tax_year_name,
        party_id                          = new_references.party_id,
        extract_date                      = new_references.extract_date,
        party_name                        = new_references.party_name,
        taxid                             = new_references.taxid,
        stu_name_control                  = new_references.stu_name_control,
        country                           = new_references.country,
        address1                          = new_references.address1,
        address2                          = new_references.address2,
        refund_amt                        = new_references.refund_amt,
        half_time_flag                    = new_references.half_time_flag,
        grad_flag                         = new_references.grad_flag,
        special_data_entry                = new_references.special_data_entry,
        status_code                       = new_references.status_code,
        error_code                        = new_references.error_code,
        file_name                         = new_references.file_name,
        irs_filed_flag                    = new_references.irs_filed_flag,
        correction_flag                   = new_references.correction_flag,
        correction_type_code              = new_references.correction_type_code,
        stmnt_print_flag                  = new_references.stmnt_print_flag,
        override_flag                     = new_references.override_flag,
        address3                          = new_references.address3,
        address4                          = new_references.address4,
        city                              = new_references.city,
        postal_code                       = new_references.postal_code,
        state                             = new_references.state,
        province                          = new_references.province,
        county                            = new_references.county,
        delivery_point_code               = new_references.delivery_point_code,
        payment_amt                       = new_references.payment_amt,
        billed_amt                        = new_references.billed_amt,
        adj_amt                           = new_references.adj_amt,
        fin_aid_amt                       = new_references.fin_aid_amt,
        fin_aid_adj_amt                   = new_references.fin_aid_adj_amt,
        next_acad_flag                    = new_references.next_acad_flag,
        batch_id                          = new_references.batch_id,
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
    x_stu_1098t_id                      IN OUT NOCOPY NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_extract_date                      IN     DATE,
    x_party_name                        IN     VARCHAR2,
    x_taxid                             IN     VARCHAR2,
    x_stu_name_control                  IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_refund_amt                        IN     NUMBER,
    x_half_time_flag                    IN     VARCHAR2,
    x_grad_flag                         IN     VARCHAR2,
    x_special_data_entry                IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_irs_filed_flag                    IN     VARCHAR2,
    x_correction_flag                   IN     VARCHAR2,
    x_correction_type_code              IN     VARCHAR2,
    x_stmnt_print_flag                  IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_payment_amt                       IN     NUMBER,
    x_billed_amt                        IN     NUMBER,
    x_adj_amt                           IN     NUMBER,
    x_fin_aid_amt                       IN     NUMBER,
    x_fin_aid_adj_amt                   IN     NUMBER,
    x_next_acad_flag                    IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 01-MAY-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_1098t_data
      WHERE    stu_1098t_id                      = x_stu_1098t_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_stu_1098t_id,
        x_tax_year_name,
        x_party_id,
        x_extract_date,
        x_party_name,
        x_taxid,
        x_stu_name_control,
        x_country,
        x_address1,
        x_address2,
        x_refund_amt,
        x_half_time_flag,
        x_grad_flag,
        x_special_data_entry,
        x_status_code,
        x_error_code,
        x_file_name,
        x_irs_filed_flag,
        x_correction_flag,
        x_correction_type_code,
        x_stmnt_print_flag,
        x_override_flag,
        x_address3,
        x_address4,
        x_city,
        x_postal_code,
        x_state,
        x_province,
        x_county,
        x_delivery_point_code,
        x_payment_amt,
        x_billed_amt,
        x_adj_amt,
        x_fin_aid_amt,
        x_fin_aid_adj_amt,
        x_next_acad_flag,
        x_batch_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_stu_1098t_id,
      x_tax_year_name,
      x_party_id,
      x_extract_date,
      x_party_name,
      x_taxid,
      x_stu_name_control,
      x_country,
      x_address1,
      x_address2,
      x_refund_amt,
      x_half_time_flag,
      x_grad_flag,
      x_special_data_entry,
      x_status_code,
      x_error_code,
      x_file_name,
      x_irs_filed_flag,
      x_correction_flag,
      x_correction_type_code,
      x_stmnt_print_flag,
      x_override_flag,
      x_address3,
      x_address4,
      x_city,
      x_postal_code,
      x_state,
      x_province,
      x_county,
      x_delivery_point_code,
      x_payment_amt,
      x_billed_amt,
      x_adj_amt,
      x_fin_aid_amt,
      x_fin_aid_adj_amt,
      x_next_acad_flag,
      x_batch_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 01-MAY-2005
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

    DELETE FROM igs_fi_1098t_data
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_1098t_data_pkg;

/
