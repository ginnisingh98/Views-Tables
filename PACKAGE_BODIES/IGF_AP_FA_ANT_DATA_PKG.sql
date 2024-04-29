--------------------------------------------------------
--  DDL for Package Body IGF_AP_FA_ANT_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_FA_ANT_DATA_PKG" AS
/* $Header: IGFAI76B.pls 120.0 2005/06/01 13:09:32 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_ap_fa_ant_data%ROWTYPE;
  new_references igf_ap_fa_ant_data%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_months_enrolled_num               IN     NUMBER,
    x_credit_points_num                 IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : ridas
  ||  Created On : 17-OCT-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_ap_fa_ant_data
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
    new_references.base_id                           := x_base_id;
    new_references.ld_cal_type                       := x_ld_cal_type;
    new_references.ld_sequence_number                := x_ld_sequence_number;
    new_references.org_unit_cd                       := x_org_unit_cd ;
    new_references.program_type                      := x_program_type;
    new_references.program_location_cd               := x_program_location_cd;
    new_references.program_cd                        := x_program_cd;
    new_references.class_standing                    := x_class_standing;
    new_references.residency_status_code             := x_residency_status_code;
    new_references.housing_status_code               := x_housing_status_code;
    new_references.attendance_type                   := x_attendance_type;
    new_references.attendance_mode                   := x_attendance_mode;
    new_references.months_enrolled_num               := x_months_enrolled_num;
    new_references.credit_points_num                 := x_credit_points_num;

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
  ||  Created By : ridas
  ||  Created On : 17-OCT-2004
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.base_id = new_references.base_id)) OR
        ((new_references.base_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_fa_base_rec_pkg.get_pk_for_validation (
                new_references.base_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ridas
  ||  Created On : 17-OCT-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_fa_ant_data
      WHERE    base_id = x_base_id
      AND      ld_cal_type = x_ld_cal_type
      AND      ld_sequence_number = x_ld_sequence_number
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


  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : ridas
  ||  Created On : 17-OCT-2004
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_fa_ant_data
      WHERE   ((base_id = x_base_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_fa_base_rec;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_months_enrolled_num               IN     NUMBER,
    x_credit_points_num                 IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : ridas
  ||  Created On : 17-OCT-2004
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
      x_base_id,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_org_unit_cd ,
      x_program_type,
      x_program_location_cd,
      x_program_cd,
      x_class_standing,
      x_residency_status_code,
      x_housing_status_code,
      x_attendance_type,
      x_attendance_mode,
      x_months_enrolled_num,
      x_credit_points_num,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.base_id,
             new_references.ld_cal_type,
             new_references.ld_sequence_number
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
             new_references.base_id,
             new_references.ld_cal_type,
             new_references.ld_sequence_number
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
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_months_enrolled_num               IN     NUMBER,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ridas
  ||  Created On : 17-OCT-2004
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
      fnd_message.set_token ('ROUTINE', 'IGF_AP_FA_ANT_DATA_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_base_id                           => x_base_id,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_org_unit_cd                       => x_org_unit_cd ,
      x_program_type                      => x_program_type,
      x_program_location_cd               => x_program_location_cd,
      x_program_cd                        => x_program_cd,
      x_class_standing                    => x_class_standing,
      x_residency_status_code             => x_residency_status_code,
      x_housing_status_code               => x_housing_status_code,
      x_attendance_type                   => x_attendance_type,
      x_attendance_mode                   => x_attendance_mode,
      x_months_enrolled_num               => x_months_enrolled_num,
      x_credit_points_num                 => x_credit_points_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_ap_fa_ant_data (
      base_id,
      ld_cal_type,
      ld_sequence_number,
      org_unit_cd ,
      program_type,
      program_location_cd,
      program_cd,
      class_standing,
      residency_status_code,
      housing_status_code,
      attendance_type,
      attendance_mode,
      months_enrolled_num,
      credit_points_num,
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
      new_references.base_id,
      new_references.ld_cal_type,
      new_references.ld_sequence_number,
      new_references.org_unit_cd ,
      new_references.program_type,
      new_references.program_location_cd,
      new_references.program_cd,
      new_references.class_standing,
      new_references.residency_status_code,
      new_references.housing_status_code,
      new_references.attendance_type,
      new_references.attendance_mode,
      new_references.months_enrolled_num,
      new_references.credit_points_num,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_months_enrolled_num               IN     NUMBER,
    x_credit_points_num                 IN     NUMBER
  ) AS
  /*
  ||  Created By : ridas
  ||  Created On : 17-OCT-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        org_unit_cd ,
        program_type,
        program_location_cd,
        program_cd,
        class_standing,
        residency_status_code,
        housing_status_code,
        attendance_type,
        attendance_mode,
        months_enrolled_num,
        credit_points_num
      FROM  igf_ap_fa_ant_data
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
        ((tlinfo.org_unit_cd  = x_org_unit_cd ) OR ((tlinfo.org_unit_cd  IS NULL) AND (X_org_unit_cd  IS NULL)))
        AND ((tlinfo.program_type = x_program_type) OR ((tlinfo.program_type IS NULL) AND (X_program_type IS NULL)))
        AND ((tlinfo.program_location_cd = x_program_location_cd) OR ((tlinfo.program_location_cd IS NULL) AND (X_program_location_cd IS NULL)))
        AND ((tlinfo.program_cd = x_program_cd) OR ((tlinfo.program_cd IS NULL) AND (X_program_cd IS NULL)))
        AND ((tlinfo.class_standing = x_class_standing) OR ((tlinfo.class_standing IS NULL) AND (X_class_standing IS NULL)))
        AND ((tlinfo.residency_status_code = x_residency_status_code) OR ((tlinfo.residency_status_code IS NULL) AND (X_residency_status_code IS NULL)))
        AND ((tlinfo.housing_status_code = x_housing_status_code) OR ((tlinfo.housing_status_code IS NULL) AND (X_housing_status_code IS NULL)))
        AND ((tlinfo.attendance_type = x_attendance_type) OR ((tlinfo.attendance_type IS NULL) AND (X_attendance_type IS NULL)))
        AND ((tlinfo.attendance_mode = x_attendance_mode) OR ((tlinfo.attendance_mode IS NULL) AND (X_attendance_mode IS NULL)))
        AND ((tlinfo.months_enrolled_num = x_months_enrolled_num) OR ((tlinfo.months_enrolled_num IS NULL) AND (X_months_enrolled_num IS NULL)))
        AND ((tlinfo.credit_points_num = x_credit_points_num) OR ((tlinfo.credit_points_num IS NULL) AND (X_credit_points_num IS NULL)))
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
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_months_enrolled_num               IN     NUMBER,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ridas
  ||  Created On : 17-OCT-2004
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
      fnd_message.set_token ('ROUTINE', 'IGF_AP_FA_ANT_DATA_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_base_id                           => x_base_id,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_org_unit_cd                       => x_org_unit_cd ,
      x_program_type                      => x_program_type,
      x_program_location_cd               => x_program_location_cd,
      x_program_cd                        => x_program_cd,
      x_class_standing                    => x_class_standing,
      x_residency_status_code             => x_residency_status_code,
      x_housing_status_code               => x_housing_status_code,
      x_attendance_type                   => x_attendance_type,
      x_attendance_mode                   => x_attendance_mode,
      x_months_enrolled_num               => x_months_enrolled_num,
      x_credit_points_num                 => x_credit_points_num,
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

    UPDATE igf_ap_fa_ant_data
      SET
        org_unit_cd                       = new_references.org_unit_cd ,
        program_type                      = new_references.program_type,
        program_location_cd               = new_references.program_location_cd,
        program_cd                        = new_references.program_cd,
        class_standing                    = new_references.class_standing,
        residency_status_code             = new_references.residency_status_code,
        housing_status_code               = new_references.housing_status_code,
        attendance_type                   = new_references.attendance_type,
        attendance_mode                   = new_references.attendance_mode,
        months_enrolled_num               = new_references.months_enrolled_num,
        credit_points_num                 = new_references.credit_points_num,
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
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_months_enrolled_num               IN     NUMBER,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ridas
  ||  Created On : 17-OCT-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_fa_ant_data
      WHERE    base_id                           = x_base_id
      AND      ld_cal_type                       = x_ld_cal_type
      AND      ld_sequence_number                = x_ld_sequence_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_base_id,
        x_ld_cal_type,
        x_ld_sequence_number,
        x_org_unit_cd ,
        x_program_type,
        x_program_location_cd,
        x_program_cd,
        x_class_standing,
        x_residency_status_code,
        x_housing_status_code,
        x_attendance_type,
        x_attendance_mode,
        x_months_enrolled_num,
        x_credit_points_num,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_base_id,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_org_unit_cd ,
      x_program_type,
      x_program_location_cd,
      x_program_cd,
      x_class_standing,
      x_residency_status_code,
      x_housing_status_code,
      x_attendance_type,
      x_attendance_mode,
      x_months_enrolled_num,
      x_credit_points_num,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : ridas
  ||  Created On : 17-OCT-2004
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

    DELETE FROM igf_ap_fa_ant_data
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_fa_ant_data_pkg;

/
