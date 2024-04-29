--------------------------------------------------------
--  DDL for Package Body IGS_EN_NSD_DLSTP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_NSD_DLSTP_PKG" AS
/* $Header: IGSEI46B.pls 120.1 2005/09/19 23:45:18 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_nsd_dlstp_all%ROWTYPE;
  new_references igs_en_nsd_dlstp_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_non_std_disc_dl_stp_id            IN     NUMBER      DEFAULT NULL,
    x_administrative_unit_status        IN     VARCHAR2    DEFAULT NULL,
    x_definition_code                   IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_code                     IN     VARCHAR2    DEFAULT NULL,
    x_formula_method                    IN     VARCHAR2    DEFAULT NULL,
    x_round_method                      IN     VARCHAR2    DEFAULT NULL,
    x_offset_dt_code                    IN     VARCHAR2    DEFAULT NULL,
    x_offset_duration                   IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_incl_wkend_duration_flag          IN     VARCHAR2    DEFAULT NULL
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
      FROM     IGS_EN_NSD_DLSTP_ALL
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
    new_references.non_std_disc_dl_stp_id            := x_non_std_disc_dl_stp_id;
    new_references.administrative_unit_status        := x_administrative_unit_status;
    new_references.definition_code                   := x_definition_code;
    new_references.org_unit_code                     := x_org_unit_code;
    new_references.formula_method                    := x_formula_method;
    new_references.round_method                      := x_round_method;
    new_references.offset_dt_code                    := x_offset_dt_code;
    new_references.offset_duration                   := x_offset_duration;
    new_references.incl_wkend_duration_flag          := x_incl_wkend_duration_flag;

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
           new_references.administrative_unit_status,
           new_references.definition_code,
           new_references.org_unit_code
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_parent_existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)

  Nishikant       09DEC2002       Bug#2688542. For the field org_unit_cd
                                  the foreign key check was done in this
                                  procedure itself. Now its modified for
                                  consistency to make a call to the function
                                  igs_or_unit_pkg.get_pk_for_str_validation.
  ***************************************************************/

  BEGIN

    IF (((old_references.org_unit_code = new_references.org_unit_code)) OR
        ((new_references.org_unit_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_or_unit_pkg.get_pk_for_str_validation (
                  new_references.org_unit_code
                ) THEN
        fnd_message.set_name ('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
    END IF;

    IF (((old_references.administrative_unit_status = new_references.administrative_unit_status)) OR
        ((new_references.administrative_unit_status IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_adm_unit_stat_pkg.get_pk_for_validation (
                new_references.administrative_unit_status,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE check_child_existance IS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_en_disc_dl_cons_pkg.get_fk_igs_en_nsd_dlstp_all (
      old_references.non_std_disc_dl_stp_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_non_std_disc_dl_stp_id            IN     NUMBER
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
      FROM     igs_en_nsd_dlstp_all
      WHERE    non_std_disc_dl_stp_id = x_non_std_disc_dl_stp_id
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
    x_administrative_unit_status        IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2
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
  --
  --svenkata - The cursor definition has been changed to SELECT from the table igs_en_nsd_dlstp_all and not view igs_en_nsd_dlstp as it was
  -- done earlier . The column org_unit_code has been checked for NULL values also to avoid Uniue index validtion failure on inserting a
  -- duplicate record .Bug # 2272521.
  --
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_nsd_dlstp_all
      WHERE    administrative_unit_status = x_administrative_unit_status
      AND      definition_code = x_definition_code
      AND      ( org_unit_code  IS NULL OR org_unit_code = x_org_unit_code )
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

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_non_std_disc_dl_stp_id            IN     NUMBER      DEFAULT NULL,
    x_administrative_unit_status        IN     VARCHAR2    DEFAULT NULL,
    x_definition_code                   IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_code                     IN     VARCHAR2    DEFAULT NULL,
    x_formula_method                    IN     VARCHAR2    DEFAULT NULL,
    x_round_method                      IN     VARCHAR2    DEFAULT NULL,
    x_offset_dt_code                    IN     VARCHAR2    DEFAULT NULL,
    x_offset_duration                   IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_incl_wkend_duration_flag          IN     VARCHAR2    DEFAULT NULL
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
      x_non_std_disc_dl_stp_id,
      x_administrative_unit_status,
      x_definition_code,
      x_org_unit_code,
      x_formula_method,
      x_round_method,
      x_offset_dt_code,
      x_offset_duration,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_incl_wkend_duration_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.non_std_disc_dl_stp_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.non_std_disc_dl_stp_id
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
    x_non_std_disc_dl_stp_id            IN OUT NOCOPY NUMBER,
    x_administrative_unit_status        IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_incl_wkend_duration_flag          IN     VARCHAR2
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
      FROM     igs_en_nsd_dlstp_all
      WHERE    non_std_disc_dl_stp_id            = x_non_std_disc_dl_stp_id;

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

    SELECT    igs_en_nsd_dlstp_all_s.NEXTVAL
    INTO      x_non_std_disc_dl_stp_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_non_std_disc_dl_stp_id            => x_non_std_disc_dl_stp_id,
      x_administrative_unit_status        => x_administrative_unit_status,
      x_definition_code                   => x_definition_code,
      x_org_unit_code                     => x_org_unit_code,
      x_formula_method                    => x_formula_method,
      x_round_method                      => x_round_method,
      x_offset_dt_code                    => x_offset_dt_code,
      x_offset_duration                   => x_offset_duration,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_incl_wkend_duration_flag          => x_incl_wkend_duration_flag
    );


    INSERT INTO igs_en_nsd_dlstp_all (
      non_std_disc_dl_stp_id,
      administrative_unit_status,
      definition_code,
      org_unit_code,
      formula_method,
      round_method,
      offset_dt_code,
      offset_duration,
      org_id,
      incl_wkend_duration_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.non_std_disc_dl_stp_id,
      new_references.administrative_unit_status,
      new_references.definition_code,
      new_references.org_unit_code,
      new_references.formula_method,
      new_references.round_method,
      new_references.offset_dt_code,
      new_references.offset_duration,
      new_references.org_id,
      new_references.incl_wkend_duration_flag,
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
    x_non_std_disc_dl_stp_id            IN     NUMBER,
    x_administrative_unit_status        IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_incl_wkend_duration_flag          IN     VARCHAR2
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
        administrative_unit_status,
        definition_code,
        org_unit_code,
        formula_method,
        round_method,
        offset_dt_code,
        offset_duration,
        incl_wkend_duration_flag
      FROM  igs_en_nsd_dlstp_all
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
        (tlinfo.administrative_unit_status = x_administrative_unit_status)
        AND (tlinfo.definition_code = x_definition_code)
        AND ((tlinfo.org_unit_code = x_org_unit_code)  OR ((tlinfo.org_unit_code IS NULL) AND (X_org_unit_code IS NULL)))
        AND (tlinfo.formula_method = x_formula_method)
        AND (tlinfo.round_method = x_round_method)
        AND (tlinfo.offset_dt_code = x_offset_dt_code)
        AND (tlinfo.offset_duration = x_offset_duration)
        AND (tlinfo.incl_wkend_duration_flag = x_incl_wkend_duration_flag)
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
    x_non_std_disc_dl_stp_id            IN     NUMBER,
    x_administrative_unit_status        IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_incl_wkend_duration_flag          IN     VARCHAR2
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
      x_non_std_disc_dl_stp_id            => x_non_std_disc_dl_stp_id,
      x_administrative_unit_status        => x_administrative_unit_status,
      x_definition_code                   => x_definition_code,
      x_org_unit_code                     => x_org_unit_code,
      x_formula_method                    => x_formula_method,
      x_round_method                      => x_round_method,
      x_offset_dt_code                    => x_offset_dt_code,
      x_offset_duration                   => x_offset_duration,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_incl_wkend_duration_flag          => x_incl_wkend_duration_flag
    );

    UPDATE igs_en_nsd_dlstp_all
      SET
        administrative_unit_status        = new_references.administrative_unit_status,
        definition_code                   = new_references.definition_code,
        org_unit_code                     = new_references.org_unit_code,
        formula_method                    = new_references.formula_method,
        round_method                      = new_references.round_method,
        offset_dt_code                    = new_references.offset_dt_code,
        offset_duration                   = new_references.offset_duration,
	incl_wkend_duration_flag          = new_references.incl_wkend_duration_flag,
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
    x_non_std_disc_dl_stp_id            IN OUT NOCOPY NUMBER,
    x_administrative_unit_status        IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_incl_wkend_duration_flag          IN     VARCHAR2
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
      FROM     igs_en_nsd_dlstp_all
      WHERE    non_std_disc_dl_stp_id            = x_non_std_disc_dl_stp_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_non_std_disc_dl_stp_id,
        x_administrative_unit_status,
        x_definition_code,
        x_org_unit_code,
        x_formula_method,
        x_round_method,
        x_offset_dt_code,
        x_offset_duration,
        x_mode,
        x_incl_wkend_duration_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_non_std_disc_dl_stp_id,
      x_administrative_unit_status,
      x_definition_code,
      x_org_unit_code,
      x_formula_method,
      x_round_method,
      x_offset_dt_code,
      x_offset_duration,
      x_mode,
      x_incl_wkend_duration_flag
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

    DELETE FROM igs_en_nsd_dlstp_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_nsd_dlstp_pkg;

/
