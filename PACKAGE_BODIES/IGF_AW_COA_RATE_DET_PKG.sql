--------------------------------------------------------
--  DDL for Package Body IGF_AW_COA_RATE_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_COA_RATE_DET_PKG" AS
/* $Header: IGFWI70B.pls 120.0 2005/06/01 14:36:38 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_coa_rate_det%ROWTYPE;
  new_references igf_aw_coa_rate_det%ROWTYPE;

  FUNCTION check_data(
                      p_ci_cal_type         igf_aw_coa_rate_det.ci_cal_type%TYPE,
                      p_ci_sequence_number  igf_aw_coa_rate_det.ci_sequence_number%TYPE,
                      p_item_code           igf_aw_coa_rate_det.item_code%TYPE
                    ) RETURN BOOLEAN AS
    CURSOR chk_data_uk ( cp_ci_cal_type         igf_aw_coa_rate_det.ci_cal_type%TYPE,
                         cp_ci_sequence_number  igf_aw_coa_rate_det.ci_sequence_number%TYPE,
                         cp_item_code           igf_aw_coa_rate_det.item_code%TYPE
                       ) IS
    SELECT ci_cal_type
      FROM igf_aw_coa_rate_det
     WHERE ci_cal_type         = cp_ci_cal_type
       AND ci_sequence_number  = cp_ci_sequence_number
       AND  item_code          = cp_item_code
     GROUP BY ci_cal_type, ci_sequence_number, item_code,
              pid_group_cd, org_unit_cd, program_type,
              program_location_cd, program_cd, class_standing,
              residency_status_code, housing_status_code,
              attendance_type, attendance_mode, ld_cal_type,ld_sequence_number
    HAVING COUNT(*) > 1 ;

    lv_data chk_data_uk%ROWTYPE;
  BEGIN
    OPEN chk_data_uk(p_ci_cal_type, p_ci_sequence_number, p_item_code);
    FETCH chk_data_uk INTO lv_data;
    IF chk_data_uk%FOUND THEN
      CLOSE chk_data_uk;
      RETURN TRUE;
    ELSE
      CLOSE chk_data_uk;
      RETURN FALSE;
    END IF;

    RETURN TRUE;
  END check_data;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER,
    x_pid_group_cd                      IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mult_factor_code                  IN     VARCHAR2,
    x_mult_amount_num                   IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 02-NOV-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_aw_coa_rate_det
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
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.item_code                         := x_item_code;
    new_references.rate_order_num                    := x_rate_order_num;
    new_references.pid_group_cd                      := x_pid_group_cd;
    new_references.org_unit_cd                       := x_org_unit_cd;
    new_references.program_type                      := x_program_type;
    new_references.program_location_cd               := x_program_location_cd;
    new_references.program_cd                        := x_program_cd;
    new_references.class_standing                    := x_class_standing;
    new_references.residency_status_code             := x_residency_status_code;
    new_references.housing_status_code               := x_housing_status_code;
    new_references.attendance_type                   := x_attendance_type;
    new_references.attendance_mode                   := x_attendance_mode;
    new_references.ld_cal_type                       := x_ld_cal_type;
    new_references.ld_sequence_number                := x_ld_sequence_number;
    new_references.mult_factor_code                  := x_mult_factor_code;
    new_references.mult_amount_num                   := x_mult_amount_num;

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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER,
    x_pid_group_cd                      IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mult_factor_code                  IN     VARCHAR2,
    x_mult_amount_num                   IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 02-NOV-2004
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    -- Get

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_item_code,
      x_rate_order_num,
      x_pid_group_cd,
      x_org_unit_cd,
      x_program_type,
      x_program_location_cd,
      x_program_cd,
      x_class_standing,
      x_residency_status_code,
      x_housing_status_code,
      x_attendance_type,
      x_attendance_mode,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_mult_factor_code,
      x_mult_amount_num,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( x_ci_cal_type, x_ci_sequence_number, x_item_code, x_rate_order_num)) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation ( x_ci_cal_type, x_ci_sequence_number, x_item_code, x_rate_order_num) ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  FUNCTION get_pk_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 08-OCT-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_coa_rate_det
      WHERE    ci_cal_type = x_ci_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      item_code = x_item_code
      AND      rate_order_num = x_rate_order_num
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


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER,
    x_pid_group_cd                      IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mult_factor_code                  IN     VARCHAR2,
    x_mult_amount_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 02-NOV-2004
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGF_AW_COA_RATE_DET_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_item_code                         => x_item_code,
      x_rate_order_num                    => x_rate_order_num,
      x_pid_group_cd                      => x_pid_group_cd,
      x_org_unit_cd                       => x_org_unit_cd,
      x_program_type                      => x_program_type,
      x_program_location_cd               => x_program_location_cd,
      x_program_cd                        => x_program_cd,
      x_class_standing                    => x_class_standing,
      x_residency_status_code             => x_residency_status_code,
      x_housing_status_code               => x_housing_status_code,
      x_attendance_type                   => x_attendance_type,
      x_attendance_mode                   => x_attendance_mode,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_mult_factor_code                  => x_mult_factor_code,
      x_mult_amount_num                   => x_mult_amount_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_coa_rate_det (
      ci_cal_type,
      ci_sequence_number,
      item_code,
      rate_order_num,
      pid_group_cd,
      org_unit_cd,
      program_type,
      program_location_cd,
      program_cd,
      class_standing,
      residency_status_code,
      housing_status_code,
      attendance_type,
      attendance_mode,
      ld_cal_type,
      ld_sequence_number,
      mult_factor_code,
      mult_amount_num,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.item_code,
      new_references.rate_order_num,
      new_references.pid_group_cd,
      new_references.org_unit_cd,
      new_references.program_type,
      new_references.program_location_cd,
      new_references.program_cd,
      new_references.class_standing,
      new_references.residency_status_code,
      new_references.housing_status_code,
      new_references.attendance_type,
      new_references.attendance_mode,
      new_references.ld_cal_type,
      new_references.ld_sequence_number,
      new_references.mult_factor_code,
      new_references.mult_amount_num,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

    IF check_data(new_references.ci_cal_type,
                  new_references.ci_sequence_number,
                  new_references.item_code
                 ) THEN
      fnd_message.set_name('IGF','IGF_AW_DUP_COA_RATE_DATA');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER,
    x_pid_group_cd                      IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mult_factor_code                  IN     VARCHAR2,
    x_mult_amount_num                   IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 02-NOV-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        ci_cal_type,
        ci_sequence_number,
        item_code,
        rate_order_num,
        pid_group_cd,
        org_unit_cd,
        program_type,
        program_location_cd,
        program_cd,
        class_standing,
        residency_status_code,
        housing_status_code,
        attendance_type,
        attendance_mode,
        ld_cal_type,
        ld_sequence_number,
        mult_factor_code,
        mult_amount_num
      FROM  igf_aw_coa_rate_det
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
        (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND (tlinfo.item_code = x_item_code)
        AND (tlinfo.rate_order_num = x_rate_order_num)
        AND ((tlinfo.pid_group_cd = x_pid_group_cd) OR ((tlinfo.pid_group_cd IS NULL) AND (X_pid_group_cd IS NULL)))
        AND ((tlinfo.org_unit_cd = x_org_unit_cd) OR ((tlinfo.org_unit_cd IS NULL) AND (X_org_unit_cd IS NULL)))
        AND ((tlinfo.program_type = x_program_type) OR ((tlinfo.program_type IS NULL) AND (X_program_type IS NULL)))
        AND ((tlinfo.program_location_cd = x_program_location_cd) OR ((tlinfo.program_location_cd IS NULL) AND (X_program_location_cd IS NULL)))
        AND ((tlinfo.program_cd = x_program_cd) OR ((tlinfo.program_cd IS NULL) AND (X_program_cd IS NULL)))
        AND ((tlinfo.class_standing = x_class_standing) OR ((tlinfo.class_standing IS NULL) AND (X_class_standing IS NULL)))
        AND ((tlinfo.residency_status_code = x_residency_status_code) OR ((tlinfo.residency_status_code IS NULL) AND (X_residency_status_code IS NULL)))
        AND ((tlinfo.housing_status_code = x_housing_status_code) OR ((tlinfo.housing_status_code IS NULL) AND (X_housing_status_code IS NULL)))
        AND ((tlinfo.attendance_type = x_attendance_type) OR ((tlinfo.attendance_type IS NULL) AND (X_attendance_type IS NULL)))
        AND ((tlinfo.attendance_mode = x_attendance_mode) OR ((tlinfo.attendance_mode IS NULL) AND (X_attendance_mode IS NULL)))
        AND ((tlinfo.ld_cal_type = x_ld_cal_type) OR ((tlinfo.ld_cal_type IS NULL) AND (X_ld_cal_type IS NULL)))
        AND ((tlinfo.ld_sequence_number = x_ld_sequence_number) OR ((tlinfo.ld_sequence_number IS NULL) AND (X_ld_sequence_number IS NULL)))
        AND (tlinfo.mult_factor_code = x_mult_factor_code)
        AND (tlinfo.mult_amount_num = x_mult_amount_num)
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
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER,
    x_pid_group_cd                      IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mult_factor_code                  IN     VARCHAR2,
    x_mult_amount_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 02-NOV-2004
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_COA_RATE_DET_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_item_code                         => x_item_code,
      x_rate_order_num                    => x_rate_order_num,
      x_pid_group_cd                      => x_pid_group_cd,
      x_org_unit_cd                       => x_org_unit_cd,
      x_program_type                      => x_program_type,
      x_program_location_cd               => x_program_location_cd,
      x_program_cd                        => x_program_cd,
      x_class_standing                    => x_class_standing,
      x_residency_status_code             => x_residency_status_code,
      x_housing_status_code               => x_housing_status_code,
      x_attendance_type                   => x_attendance_type,
      x_attendance_mode                   => x_attendance_mode,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_mult_factor_code                  => x_mult_factor_code,
      x_mult_amount_num                   => x_mult_amount_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_aw_coa_rate_det
      SET
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        item_code                         = new_references.item_code,
        rate_order_num                    = new_references.rate_order_num,
        pid_group_cd                      = new_references.pid_group_cd,
        org_unit_cd                       = new_references.org_unit_cd,
        program_type                      = new_references.program_type,
        program_location_cd               = new_references.program_location_cd,
        program_cd                        = new_references.program_cd,
        class_standing                    = new_references.class_standing,
        residency_status_code             = new_references.residency_status_code,
        housing_status_code               = new_references.housing_status_code,
        attendance_type                   = new_references.attendance_type,
        attendance_mode                   = new_references.attendance_mode,
        ld_cal_type                       = new_references.ld_cal_type,
        ld_sequence_number                = new_references.ld_sequence_number,
        mult_factor_code                  = new_references.mult_factor_code,
        mult_amount_num                   = new_references.mult_amount_num,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    IF check_data(new_references.ci_cal_type,
                  new_references.ci_sequence_number,
                  new_references.item_code
                 ) THEN
      fnd_message.set_name('IGF','IGF_AW_DUP_COA_RATE_DATA');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER,
    x_pid_group_cd                      IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mult_factor_code                  IN     VARCHAR2,
    x_mult_amount_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 02-NOV-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_coa_rate_det
      WHERE    ci_cal_type = x_ci_cal_type
        AND    ci_sequence_number = x_ci_sequence_number
        AND    item_code = x_item_code
        AND    rate_order_num = x_rate_order_num;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_item_code,
        x_rate_order_num,
        x_pid_group_cd,
        x_org_unit_cd,
        x_program_type,
        x_program_location_cd,
        x_program_cd,
        x_class_standing,
        x_residency_status_code,
        x_housing_status_code,
        x_attendance_type,
        x_attendance_mode,
        x_ld_cal_type,
        x_ld_sequence_number,
        x_mult_factor_code,
        x_mult_amount_num,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_item_code,
      x_rate_order_num,
      x_pid_group_cd,
      x_org_unit_cd,
      x_program_type,
      x_program_location_cd,
      x_program_cd,
      x_class_standing,
      x_residency_status_code,
      x_housing_status_code,
      x_attendance_type,
      x_attendance_mode,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_mult_factor_code,
      x_mult_amount_num,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 02-NOV-2004
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

    DELETE FROM igf_aw_coa_rate_det
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_coa_rate_det_pkg;

/
