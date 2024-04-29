--------------------------------------------------------
--  DDL for Package Body IGF_AP_INST_VER_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_INST_VER_ITEM_PKG" AS
/* $Header: IGFAI05B.pls 115.11 2003/10/17 05:40:58 rasahoo ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_ap_inst_ver_item_all%ROWTYPE;
  new_references igf_ap_inst_ver_item_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2 ,
    x_base_id                           IN     NUMBER   ,
    x_udf_vern_item_seq_num             IN     NUMBER   ,
    x_item_value                        IN     VARCHAR2 ,
    x_waive_flag                        IN     VARCHAR2 ,
    x_isir_map_col                      IN     VARCHAR2 ,
    x_incl_in_tolerance                 IN     VARCHAR2 ,
    x_legacy_record_flag                IN     VARCHAR2 ,
    x_use_blank_flag                    IN     VARCHAR2 ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 01-FEB-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_INST_VER_ITEM_ALL
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
    new_references.udf_vern_item_seq_num             := 1; -- This is hardcoded to 1 because this field is not made nullable.
    new_references.item_value                        := x_item_value;
    new_references.waive_flag                        := x_waive_flag;
    new_references.incl_in_tolerance                 := x_incl_in_tolerance;
    new_references.isir_map_col                      := x_isir_map_col;
    new_references.legacy_record_flag                := x_legacy_record_flag;
    new_references.use_blank_flag                    := x_use_blank_flag;

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
  ||  Created By : brajendr
  ||  Created On : 01-FEB-2001
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
    x_isir_map_col                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : brajendr
  ||  Created On : 01-FEB-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_inst_ver_item_all
      WHERE    isir_map_col = x_isir_map_col
      AND      base_id = x_base_id
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
  ||  Created By : brajendr
  ||  Created On : 01-FEB-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_inst_ver_item_all
      WHERE   ((base_id = x_base_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AP_VER_TAX_FA_DETAIL_FK');
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
    x_udf_vern_item_seq_num             IN     NUMBER,
    x_item_value                        IN     VARCHAR2,
    x_waive_flag                        IN     VARCHAR2,
    x_isir_map_col                      IN     VARCHAR2,
    x_incl_in_tolerance                 IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_use_blank_flag                    IN     VARCHAR2 ,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 01-FEB-2001
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
      x_udf_vern_item_seq_num,
      x_item_value,
      x_waive_flag,
      x_isir_map_col,
      x_incl_in_tolerance,
      x_legacy_record_flag,
      x_use_blank_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.isir_map_col,
             new_references.base_id
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
             new_references.isir_map_col,
             new_references.base_id
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
    x_udf_vern_item_seq_num             IN     NUMBER,
    x_item_value                        IN     VARCHAR2,
    x_waive_flag                        IN     VARCHAR2,
    x_isir_map_col                      IN     VARCHAR2,
    x_incl_in_tolerance                 IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_use_blank_flag                    IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 01-FEB-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_inst_ver_item_all
      WHERE    isir_map_col = x_isir_map_col
      AND      base_id = x_base_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

    l_org_id                     igf_ap_inst_ver_item_all.org_id%TYPE  DEFAULT igf_aw_gen.get_org_id;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_base_id                           => x_base_id,
      x_udf_vern_item_seq_num             => x_udf_vern_item_seq_num,
      x_item_value                        => x_item_value,
      x_waive_flag                        => x_waive_flag,
      x_incl_in_tolerance                 => x_incl_in_tolerance,
      x_isir_map_col                      => x_isir_map_col,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_use_blank_flag                    => x_use_blank_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_ap_inst_ver_item_all (
      base_id,
      udf_vern_item_seq_num,
      item_value,
      waive_flag,
      isir_map_col,
      incl_in_tolerance,
      legacy_record_flag,
      use_blank_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id
    ) VALUES (
      new_references.base_id,
      new_references.udf_vern_item_seq_num,
      new_references.item_value,
      new_references.waive_flag,
      new_references.isir_map_col,
      new_references.incl_in_tolerance,
      new_references.legacy_record_flag,
      new_references.use_blank_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
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
    x_base_id                           IN     NUMBER,
    x_udf_vern_item_seq_num             IN     NUMBER,
    x_item_value                        IN     VARCHAR2,
    x_waive_flag                        IN     VARCHAR2,
    x_isir_map_col                      IN     VARCHAR2,
    x_incl_in_tolerance                 IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_use_blank_flag                    IN     VARCHAR2

  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 01-FEB-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        item_value,
        waive_flag,
        isir_map_col,
        incl_in_tolerance,
        legacy_record_flag,
        use_blank_flag,
        org_id
      FROM  igf_ap_inst_ver_item_all
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
        ((tlinfo.item_value = x_item_value) OR ((tlinfo.item_value IS NULL) AND (X_item_value IS NULL)))
        AND ((tlinfo.waive_flag = x_waive_flag) OR ((tlinfo.waive_flag IS NULL) AND (X_waive_flag IS NULL)))
        AND ((tlinfo.isir_map_col = x_isir_map_col) OR ((tlinfo.isir_map_col IS NULL) AND (x_isir_map_col IS NULL)))
        AND ((tlinfo.incl_in_tolerance = x_incl_in_tolerance) OR ((tlinfo.incl_in_tolerance IS NULL) AND (x_incl_in_tolerance IS NULL)))
        AND ((tlinfo.legacy_record_flag = x_legacy_record_flag) OR ((tlinfo.legacy_record_flag IS NULL) AND (x_legacy_record_flag IS NULL)))
        AND ((tlinfo.use_blank_flag = x_use_blank_flag) OR ((tlinfo.use_blank_flag IS NULL) AND (x_use_blank_flag IS NULL)))
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
    x_udf_vern_item_seq_num             IN     NUMBER,
    x_item_value                        IN     VARCHAR2,
    x_waive_flag                        IN     VARCHAR2,
    x_isir_map_col                      IN     VARCHAR2,
    x_incl_in_tolerance                 IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_use_blank_flag                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 01-FEB-2001
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
      x_base_id                           => x_base_id,
      x_udf_vern_item_seq_num             => x_udf_vern_item_seq_num,
      x_item_value                        => x_item_value,
      x_waive_flag                        => x_waive_flag,
      x_isir_map_col                      => x_isir_map_col,
      x_incl_in_tolerance                 => x_incl_in_tolerance,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_use_blank_flag                    => x_use_blank_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_ap_inst_ver_item_all
      SET
        item_value                        = new_references.item_value,
        waive_flag                        = new_references.waive_flag,
        isir_map_col                      = new_references.isir_map_col,
        incl_in_tolerance                 = new_references.incl_in_tolerance,
        legacy_record_flag                = new_references.legacy_record_flag,
        use_blank_flag                    = new_references.use_blank_flag,
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
    x_base_id                           IN     NUMBER,
    x_udf_vern_item_seq_num             IN     NUMBER,
    x_item_value                        IN     VARCHAR2,
    x_waive_flag                        IN     VARCHAR2,
    x_isir_map_col                      IN     VARCHAR2,
    x_incl_in_tolerance                 IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_use_blank_flag                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 01-FEB-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_inst_ver_item_all
      WHERE    isir_map_col = x_isir_map_col
      AND      base_id = x_base_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_base_id,
        x_udf_vern_item_seq_num,
        x_item_value,
        x_waive_flag,
        x_isir_map_col,
        x_incl_in_tolerance,
        x_legacy_record_flag,
        x_use_blank_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_base_id,
      x_udf_vern_item_seq_num,
      x_item_value,
      x_waive_flag,
      x_isir_map_col,
      x_incl_in_tolerance,
      x_legacy_record_flag,
      x_use_blank_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 01-FEB-2001
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml(
      p_action                            => 'DELETE',
      x_rowid                             => x_rowid,
      x_base_id                           => NULL,
      x_udf_vern_item_seq_num             => NULL,
      x_item_value                        => NULL,
      x_waive_flag                        => NULL,
      x_isir_map_col                      => NULL,
      x_incl_in_tolerance                 => NULL,
      x_legacy_record_flag                => NULL,
      x_use_blank_flag                    => NULL,
      x_creation_date                     => NULL,
      x_created_by                        => NULL,
      x_last_update_date                  => NULL,
      x_last_updated_by                   => NULL,
      x_last_update_login                 => NULL
    );

    DELETE FROM igf_ap_inst_ver_item_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_inst_ver_item_pkg;

/
