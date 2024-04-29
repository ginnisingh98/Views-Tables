--------------------------------------------------------
--  DDL for Package Body IGF_AP_ISIR_CORR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_ISIR_CORR_PKG" AS
/* $Header: IGFAI21B.pls 120.1 2005/10/28 05:41:00 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_ap_isir_corr_all%ROWTYPE;
  new_references igf_ap_isir_corr_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_isirc_id                          IN     NUMBER      DEFAULT NULL,
    x_isir_id                           IN     NUMBER      DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_sar_field_number                  IN     NUMBER      DEFAULT NULL,
    x_original_value                    IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_corrected_value                   IN     VARCHAR2    DEFAULT NULL,
    x_correction_status                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_ISIR_CORR_ALL
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
    new_references.isirc_id                          := x_isirc_id;
    new_references.isir_id                           := x_isir_id;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.sar_field_number                  := x_sar_field_number;
    new_references.original_value                    := x_original_value;
    new_references.batch_id                          := x_batch_id;
    new_references.corrected_value                   := x_corrected_value;
    new_references.correction_status                 := x_correction_status;

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
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.isir_id,
           new_references.sar_field_number,
           new_references.correction_status
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.isir_id = new_references.isir_id)) OR
        ((new_references.isir_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_isir_matched_pkg.get_pk_for_validation (
                new_references.isir_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.ci_cal_type = new_references.ci_cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.ci_cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.ci_cal_type,
                new_references.ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_isirc_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_isir_corr_all
      WHERE    isirc_id = x_isirc_id
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
    x_isir_id                           IN     NUMBER,
    x_sar_field_number                  IN     NUMBER,
    x_correction_status                 IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_isir_corr_all
      WHERE    isir_id = x_isir_id
      AND      ((sar_field_number = x_sar_field_number) OR (sar_field_number IS NULL AND x_sar_field_number IS NULL))
      AND      ((correction_status = x_correction_status) OR (correction_status IS NULL AND x_correction_status IS NULL))
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


  PROCEDURE get_fk_igf_ap_isir_matched (
    x_isir_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  museshad        28-Oct-2005     Bug 4690726
  ||                                  Added cursor c_non_ack_corr_count
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_isir_corr_all
      WHERE   ((isir_id = x_isir_id));

    lv_rowid cur_rowid%RowType;

    -- Get the number of corrections whose status is not 'ACKNOWLEDGED'
    -- If the number is 0, all of them can be deleted.
    -- Else, throw error.
    CURSOR c_non_ack_corr_count(cp_isir_id NUMBER) IS
      SELECT count(*) cnt
        FROM igf_ap_isir_corr_all
       WHERE isir_id = cp_isir_id
         AND correction_status <> 'ACKNOWLEDGED';

    l_non_ack_corr_count NUMBER;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      OPEN c_non_ack_corr_count(x_isir_id);
      FETCH c_non_ack_corr_count INTO l_non_ack_corr_count;
      CLOSE c_non_ack_corr_count;
      IF l_non_ack_corr_count <> 0 THEN
        fnd_message.set_name ('IGF', 'IGF_AP_ISIRC_ISIRM_FK');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
        RETURN;
      ELSE
        WHILE cur_rowid%FOUND LOOP
          igf_ap_isir_corr_pkg.delete_row(lv_rowid.rowid);
          FETCH cur_rowid INTO lv_rowid;
        END LOOP;
      END IF;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_isir_matched;


  PROCEDURE get_fk_igs_ca_inst_all (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_isir_corr_all
      WHERE   ((ci_cal_type = x_cal_type) AND
               (ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AP_ISIRC_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_isirc_id                          IN     NUMBER      DEFAULT NULL,
    x_isir_id                           IN     NUMBER      DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_sar_field_number                  IN     NUMBER      DEFAULT NULL,
    x_original_value                    IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_corrected_value                   IN     VARCHAR2    DEFAULT NULL,
    x_correction_status                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
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
      x_isirc_id,
      x_isir_id,
      x_ci_sequence_number,
      x_ci_cal_type,
      x_sar_field_number,
      x_original_value,
      x_batch_id,
      x_corrected_value,
      x_correction_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.isirc_id
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.isirc_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_isirc_id                          IN OUT NOCOPY NUMBER,
    x_isir_id                           IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_sar_field_number                  IN     NUMBER,
    x_original_value                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_corrected_value                   IN     VARCHAR2,
    x_correction_status                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_isir_corr_all
      WHERE    isirc_id                          = x_isirc_id;

    CURSOR cur_seq IS
      SELECT   igf_ap_isir_corr_s.nextval
      FROM     dual;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id  			 igf_ap_isir_corr_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

  BEGIN

    OPEN cur_seq;
      FETCH  cur_seq INTO x_isirc_id;
    CLOSE cur_seq;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_isirc_id                          => x_isirc_id,
      x_isir_id                           => x_isir_id,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_ci_cal_type                       => x_ci_cal_type,
      x_sar_field_number                  => x_sar_field_number,
      x_original_value                    => x_original_value,
      x_batch_id                          => x_batch_id,
      x_corrected_value                   => x_corrected_value,
      x_correction_status                 => x_correction_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_ap_isir_corr_all (
      isirc_id,
      isir_id,
      ci_sequence_number,
      ci_cal_type,
      sar_field_number,
      original_value,
      batch_id,
      corrected_value,
      correction_status,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id
    ) VALUES (
      new_references.isirc_id,
      new_references.isir_id,
      new_references.ci_sequence_number,
      new_references.ci_cal_type,
      new_references.sar_field_number,
      new_references.original_value,
      new_references.batch_id,
      new_references.corrected_value,
      new_references.correction_status,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      l_org_id
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
    x_isirc_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_sar_field_number                  IN     NUMBER,
    x_original_value                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_corrected_value                   IN     VARCHAR2,
    x_correction_status                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        isir_id,
        ci_sequence_number,
        ci_cal_type,
        sar_field_number,
        original_value,
        batch_id,
        corrected_value,
        correction_status,
        org_id
      FROM  igf_ap_isir_corr_all
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
        (tlinfo.isir_id = x_isir_id)
        AND ((tlinfo.ci_sequence_number = x_ci_sequence_number) OR ((tlinfo.ci_sequence_number IS NULL) AND (X_ci_sequence_number IS NULL)))
        AND ((tlinfo.ci_cal_type = x_ci_cal_type) OR ((tlinfo.ci_cal_type IS NULL) AND (X_ci_cal_type IS NULL)))
        AND ((tlinfo.sar_field_number = x_sar_field_number) OR ((tlinfo.sar_field_number IS NULL) AND (X_sar_field_number IS NULL)))
        AND ((tlinfo.original_value = x_original_value) OR ((tlinfo.original_value IS NULL) AND (X_original_value IS NULL)))
        AND ((tlinfo.batch_id = x_batch_id) OR ((tlinfo.batch_id IS NULL) AND (X_batch_id IS NULL)))
        AND ((tlinfo.corrected_value = x_corrected_value) OR ((tlinfo.corrected_value IS NULL) AND (X_corrected_value IS NULL)))
        AND ((tlinfo.correction_status = x_correction_status) OR ((tlinfo.correction_status IS NULL) AND (X_correction_status IS NULL)))
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
    x_isirc_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_sar_field_number                  IN     NUMBER,
    x_original_value                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_corrected_value                   IN     VARCHAR2,
    x_correction_status                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
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
      x_isirc_id                          => x_isirc_id,
      x_isir_id                           => x_isir_id,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_ci_cal_type                       => x_ci_cal_type,
      x_sar_field_number                  => x_sar_field_number,
      x_original_value                    => x_original_value,
      x_batch_id                          => x_batch_id,
      x_corrected_value                   => x_corrected_value,
      x_correction_status                 => x_correction_status,
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

    UPDATE igf_ap_isir_corr_all
      SET
        isir_id                           = new_references.isir_id,
        ci_sequence_number                = new_references.ci_sequence_number,
        ci_cal_type                       = new_references.ci_cal_type,
        sar_field_number                  = new_references.sar_field_number,
        original_value                    = new_references.original_value,
        batch_id                          = new_references.batch_id,
        corrected_value                   = new_references.corrected_value,
        correction_status                 = new_references.correction_status,
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
    x_isirc_id                          IN OUT NOCOPY NUMBER,
    x_isir_id                           IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_sar_field_number                  IN     NUMBER,
    x_original_value                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_corrected_value                   IN     VARCHAR2,
    x_correction_status                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_isir_corr_all
      WHERE    isirc_id                          = x_isirc_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_isirc_id,
        x_isir_id,
        x_ci_sequence_number,
        x_ci_cal_type,
        x_sar_field_number,
        x_original_value,
        x_batch_id,
        x_corrected_value,
        x_correction_status,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_isirc_id,
      x_isir_id,
      x_ci_sequence_number,
      x_ci_cal_type,
      x_sar_field_number,
      x_original_value,
      x_batch_id,
      x_corrected_value,
      x_correction_status,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kpadiyar
  ||  Created On : 11-DEC-2000
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

    DELETE FROM igf_ap_isir_corr_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_isir_corr_pkg;

/
