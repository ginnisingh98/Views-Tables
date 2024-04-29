--------------------------------------------------------
--  DDL for Package Body IGS_EN_NSTD_USEC_DL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_NSTD_USEC_DL_PKG" AS
/* $Header: IGSEI47B.pls 115.6 2002/11/28 23:43:52 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_nstd_usec_dl%ROWTYPE;
  new_references igs_en_nstd_usec_dl%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_nstd_usec_dl_id                   IN     NUMBER      DEFAULT NULL,
    x_non_std_usec_dls_id               IN     NUMBER      DEFAULT NULL,
    x_function_name                     IN     VARCHAR2    DEFAULT NULL,
    x_definition_code                   IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_code                     IN     VARCHAR2    DEFAULT NULL,
    x_formula_method                    IN     VARCHAR2    DEFAULT NULL,
    x_round_method                      IN     VARCHAR2    DEFAULT NULL,
    x_offset_dt_code                    IN     VARCHAR2    DEFAULT NULL,
    x_offset_duration                   IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_enr_dl_date                       IN     DATE        DEFAULT NULL,
    x_enr_dl_total_days                 IN     NUMBER      DEFAULT NULL,
    x_enr_dl_offset_days                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_NSTD_USEC_DL
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
    new_references.nstd_usec_dl_id                   := x_nstd_usec_dl_id;
    new_references.non_std_usec_dls_id               := x_non_std_usec_dls_id;
    new_references.function_name                     := x_function_name;
    new_references.definition_code                   := x_definition_code;
    new_references.org_unit_code                     := x_org_unit_code;
    new_references.formula_method                    := x_formula_method;
    new_references.round_method                      := x_round_method;
    new_references.offset_dt_code                    := x_offset_dt_code;
    new_references.offset_duration                   := x_offset_duration;
    new_references.uoo_id                            := x_uoo_id;
    new_references.enr_dl_date                       := x_enr_dl_date;
    new_references.enr_dl_total_days                 := x_enr_dl_total_days;
    new_references.enr_dl_offset_days                := x_enr_dl_offset_days;

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
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.function_name,
           new_references.uoo_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ofr_opt_pkg.get_uk_For_validation (
                new_references.uoo_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.non_std_usec_dls_id = new_references.non_std_usec_dls_id)) OR
        ((new_references.non_std_usec_dls_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_nsu_dlstp_pkg.get_pk_for_validation (
                new_references.non_std_usec_dls_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_nstd_usec_dl_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_nstd_usec_dl
      WHERE    nstd_usec_dl_id = x_nstd_usec_dl_id
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
    x_function_name                     IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_nstd_usec_dl
      WHERE    ((function_name = x_function_name) OR (function_name IS NULL AND x_function_name IS NULL))
      AND      uoo_id = x_uoo_id
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


  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_nstd_usec_dl
      WHERE   ((uoo_id = x_uoo_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_NSDL_UOO_UFK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ps_unit_ofr_opt;


  PROCEDURE get_fk_igs_en_nsu_dlstp_all (
    x_non_std_usec_dls_id               IN     NUMBER
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_nstd_usec_dl
      WHERE   ((non_std_usec_dls_id = x_non_std_usec_dls_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_NSDL_NSUD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_nsu_dlstp_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_nstd_usec_dl_id                   IN     NUMBER      DEFAULT NULL,
    x_non_std_usec_dls_id               IN     NUMBER      DEFAULT NULL,
    x_function_name                     IN     VARCHAR2    DEFAULT NULL,
    x_definition_code                   IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_code                     IN     VARCHAR2    DEFAULT NULL,
    x_formula_method                    IN     VARCHAR2    DEFAULT NULL,
    x_round_method                      IN     VARCHAR2    DEFAULT NULL,
    x_offset_dt_code                    IN     VARCHAR2    DEFAULT NULL,
    x_offset_duration                   IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_enr_dl_date                       IN     DATE        DEFAULT NULL,
    x_enr_dl_total_days                 IN     NUMBER      DEFAULT NULL,
    x_enr_dl_offset_days                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
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
      x_nstd_usec_dl_id,
      x_non_std_usec_dls_id,
      x_function_name,
      x_definition_code,
      x_org_unit_code,
      x_formula_method,
      x_round_method,
      x_offset_dt_code,
      x_offset_duration,
      x_uoo_id,
      x_enr_dl_date,
      x_enr_dl_total_days,
      x_enr_dl_offset_days,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.nstd_usec_dl_id
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
             new_references.nstd_usec_dl_id
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
    x_nstd_usec_dl_id                   IN OUT NOCOPY NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_function_name                     IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_enr_dl_date                       IN     DATE,
    x_enr_dl_total_days                 IN     NUMBER,
    x_enr_dl_offset_days                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_en_nstd_usec_dl
      WHERE    nstd_usec_dl_id                   = x_nstd_usec_dl_id;

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igs_en_nstd_usec_dl_s.NEXTVAL
    INTO      x_nstd_usec_dl_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_nstd_usec_dl_id                   => x_nstd_usec_dl_id,
      x_non_std_usec_dls_id               => x_non_std_usec_dls_id,
      x_function_name                     => x_function_name,
      x_definition_code                   => x_definition_code,
      x_org_unit_code                     => x_org_unit_code,
      x_formula_method                    => x_formula_method,
      x_round_method                      => x_round_method,
      x_offset_dt_code                    => x_offset_dt_code,
      x_offset_duration                   => x_offset_duration,
      x_uoo_id                            => x_uoo_id,
      x_enr_dl_date                       => x_enr_dl_date,
      x_enr_dl_total_days                 => x_enr_dl_total_days,
      x_enr_dl_offset_days                => x_enr_dl_offset_days,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_nstd_usec_dl (
      nstd_usec_dl_id,
      non_std_usec_dls_id,
      function_name,
      definition_code,
      org_unit_code,
      formula_method,
      round_method,
      offset_dt_code,
      offset_duration,
      uoo_id,
      enr_dl_date,
      enr_dl_total_days,
      enr_dl_offset_days,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.nstd_usec_dl_id,
      new_references.non_std_usec_dls_id,
      new_references.function_name,
      new_references.definition_code,
      new_references.org_unit_code,
      new_references.formula_method,
      new_references.round_method,
      new_references.offset_dt_code,
      new_references.offset_duration,
      new_references.uoo_id,
      new_references.enr_dl_date,
      new_references.enr_dl_total_days,
      new_references.enr_dl_offset_days,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
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
    x_nstd_usec_dl_id                   IN     NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_function_name                     IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_enr_dl_date                       IN     DATE,
    x_enr_dl_total_days                 IN     NUMBER,
    x_enr_dl_offset_days                IN     NUMBER
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        non_std_usec_dls_id,
        function_name,
        definition_code,
        org_unit_code,
        formula_method,
        round_method,
        offset_dt_code,
        offset_duration,
        uoo_id,
        enr_dl_date,
        enr_dl_total_days,
        enr_dl_offset_days
      FROM  igs_en_nstd_usec_dl
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
        ((tlinfo.non_std_usec_dls_id = x_non_std_usec_dls_id) OR ((tlinfo.non_std_usec_dls_id IS NULL) AND (X_non_std_usec_dls_id IS NULL)))
        AND ((tlinfo.function_name = x_function_name) OR ((tlinfo.function_name IS NULL) AND (X_function_name IS NULL)))
        AND ((tlinfo.definition_code = x_definition_code) OR ((tlinfo.definition_code IS NULL) AND (X_definition_code IS NULL)))
        AND ((tlinfo.org_unit_code = x_org_unit_code) OR ((tlinfo.org_unit_code IS NULL) AND (X_org_unit_code IS NULL)))
        AND ((tlinfo.formula_method = x_formula_method) OR ((tlinfo.formula_method IS NULL) AND (X_formula_method IS NULL)))
        AND ((tlinfo.round_method = x_round_method) OR ((tlinfo.round_method IS NULL) AND (X_round_method IS NULL)))
        AND ((tlinfo.offset_dt_code = x_offset_dt_code) OR ((tlinfo.offset_dt_code IS NULL) AND (X_offset_dt_code IS NULL)))
        AND ((tlinfo.offset_duration = x_offset_duration) OR ((tlinfo.offset_duration IS NULL) AND (X_offset_duration IS NULL)))
        AND (tlinfo.uoo_id = x_uoo_id)
        AND (tlinfo.enr_dl_date = x_enr_dl_date)
        AND ((tlinfo.enr_dl_total_days = x_enr_dl_total_days) OR ((tlinfo.enr_dl_total_days IS NULL) AND (X_enr_dl_total_days IS NULL)))
        AND ((tlinfo.enr_dl_offset_days = x_enr_dl_offset_days) OR ((tlinfo.enr_dl_offset_days IS NULL) AND (X_enr_dl_offset_days IS NULL)))
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
    x_nstd_usec_dl_id                   IN     NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_function_name                     IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_enr_dl_date                       IN     DATE,
    x_enr_dl_total_days                 IN     NUMBER,
    x_enr_dl_offset_days                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_nstd_usec_dl_id                   => x_nstd_usec_dl_id,
      x_non_std_usec_dls_id               => x_non_std_usec_dls_id,
      x_function_name                     => x_function_name,
      x_definition_code                   => x_definition_code,
      x_org_unit_code                     => x_org_unit_code,
      x_formula_method                    => x_formula_method,
      x_round_method                      => x_round_method,
      x_offset_dt_code                    => x_offset_dt_code,
      x_offset_duration                   => x_offset_duration,
      x_uoo_id                            => x_uoo_id,
      x_enr_dl_date                       => x_enr_dl_date,
      x_enr_dl_total_days                 => x_enr_dl_total_days,
      x_enr_dl_offset_days                => x_enr_dl_offset_days,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_nstd_usec_dl
      SET
        non_std_usec_dls_id               = new_references.non_std_usec_dls_id,
        function_name                     = new_references.function_name,
        definition_code                   = new_references.definition_code,
        org_unit_code                     = new_references.org_unit_code,
        formula_method                    = new_references.formula_method,
        round_method                      = new_references.round_method,
        offset_dt_code                    = new_references.offset_dt_code,
        offset_duration                   = new_references.offset_duration,
        uoo_id                            = new_references.uoo_id,
        enr_dl_date                       = new_references.enr_dl_date,
        enr_dl_total_days                 = new_references.enr_dl_total_days,
        enr_dl_offset_days                = new_references.enr_dl_offset_days,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_nstd_usec_dl_id                   IN OUT NOCOPY NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_function_name                     IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_enr_dl_date                       IN     DATE,
    x_enr_dl_total_days                 IN     NUMBER,
    x_enr_dl_offset_days                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_nstd_usec_dl
      WHERE    nstd_usec_dl_id                   = x_nstd_usec_dl_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_nstd_usec_dl_id,
        x_non_std_usec_dls_id,
        x_function_name,
        x_definition_code,
        x_org_unit_code,
        x_formula_method,
        x_round_method,
        x_offset_dt_code,
        x_offset_duration,
        x_uoo_id,
        x_enr_dl_date,
        x_enr_dl_total_days,
        x_enr_dl_offset_days,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_nstd_usec_dl_id,
      x_non_std_usec_dls_id,
      x_function_name,
      x_definition_code,
      x_org_unit_code,
      x_formula_method,
      x_round_method,
      x_offset_dt_code,
      x_offset_duration,
      x_uoo_id,
      x_enr_dl_date,
      x_enr_dl_total_days,
      x_enr_dl_offset_days,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
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

    DELETE FROM igs_en_nstd_usec_dl
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_nstd_usec_dl_pkg;

/
