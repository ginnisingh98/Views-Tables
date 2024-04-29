--------------------------------------------------------
--  DDL for Package Body IGR_I_INQUIRY_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_INQUIRY_TYPES_PKG" AS
/* $Header: IGSRH19B.pls 120.0 2005/06/02 04:04:27 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igr_i_inquiry_types%ROWTYPE;
  new_references igr_i_inquiry_types%ROWTYPE;


   FUNCTION get_uk_for_validation (
    x_inquiry_type_cd                   IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igr_i_inquiry_types
      WHERE    inquiry_type_cd = x_inquiry_type_cd
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

  END get_uk_for_validation;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Validates the Uniqueness of the inquiry_type_cd column
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
            new_references.inquiry_type_cd	     --Added for APC Inegration  Apadegal

         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;




   PROCEDURE Check_Child_Existance AS
 /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
 	 igr_i_e_testtyps_pkg.get_fk_igr_i_inquiry_types(old_references.inquiry_type_id);

  END Check_Child_Existance;



  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_inquiry_type_id                   IN     NUMBER,
    x_inquiry_type_cd                   IN     VARCHAR2,
    x_inquiry_type_desc                 IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_imp_source_type_id                IN     NUMBER,
    x_info_type_id                      IN     NUMBER,
    x_configurability_func_name         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igr_i_inquiry_types
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
    new_references.inquiry_type_id                   := x_inquiry_type_id;
    new_references.inquiry_type_cd                   := x_inquiry_type_cd;
    new_references.inquiry_type_desc                 := x_inquiry_type_desc;
    new_references.enabled_flag                      := x_enabled_flag;
    new_references.imp_source_type_id                := x_imp_source_type_id;
    new_references.info_type_id                      := x_info_type_id;
    new_references.configurability_func_name         := x_configurability_func_name;

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
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.imp_source_type_id = new_references.imp_source_type_id)) OR
        ((new_references.imp_source_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_src_types_pkg.get_pk_for_validation (
                new_references.imp_source_type_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.info_type_id = new_references.info_type_id)) OR
        ((new_references.info_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGR_I_PKG_ITEM_PKG.get_pk_for_validation (
                new_references.info_type_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_inquiry_type_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igr_i_inquiry_types
      WHERE    inquiry_type_id = x_inquiry_type_id
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


  PROCEDURE get_fk_igs_pe_src_types (
    x_source_type_id                    IN     NUMBER
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igr_i_inquiry_types
      WHERE   ((imp_source_type_id = x_source_type_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGR_INQSRC_INQTYP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_src_types;


  PROCEDURE get_fk_igr_i_pkg_item (
    x_package_item_id                     IN     NUMBER
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igr_i_inquiry_types
      WHERE   ((info_type_id =   x_package_item_id ));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGR_ITYP_INQTYP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igr_i_pkg_item;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_inquiry_type_id                   IN     NUMBER,
    x_inquiry_type_cd                   IN     VARCHAR2,
    x_inquiry_type_desc                 IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_imp_source_type_id                IN     NUMBER,
    x_info_type_id                      IN     NUMBER,
    x_configurability_func_name         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
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
      x_inquiry_type_id,
      x_inquiry_type_cd,
      x_inquiry_type_desc,
      x_enabled_flag,
      x_imp_source_type_id,
      x_info_type_id,
      x_configurability_func_name,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.inquiry_type_id
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
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.

      check_uniqueness;
      IF ( get_pk_for_validation (
             new_references.inquiry_type_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    -- code begin -- To call all procedures realted to Before delete - Apadegal- 7-March-2005
    ELSIF (p_action = 'DELETE') THEN
        Check_Child_Existance;
    -- code ended -Apadegal
    END IF;

  END before_dml;



  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inquiry_type_id                   IN OUT NOCOPY NUMBER,
    x_inquiry_type_cd                   IN     VARCHAR2,
    x_inquiry_type_desc                 IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_imp_source_type_id                IN     NUMBER,
    x_info_type_id                      IN     NUMBER,
    x_configurability_func_name         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
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
      fnd_message.set_token ('ROUTINE', 'IGR_I_INQUIRY_TYPES_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_inquiry_type_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_inquiry_type_id                   => x_inquiry_type_id,
      x_inquiry_type_cd                   => x_inquiry_type_cd,
      x_inquiry_type_desc                 => x_inquiry_type_desc,
      x_enabled_flag                      => x_enabled_flag,
      x_imp_source_type_id                => x_imp_source_type_id,
      x_info_type_id                      => x_info_type_id,
      x_configurability_func_name         => x_configurability_func_name,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igr_i_inquiry_types (
      inquiry_type_id,
      inquiry_type_cd,
      inquiry_type_desc,
      enabled_flag,
      imp_source_type_id,
      info_type_id,
      configurability_func_name,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igr_i_inquiry_types_s.NEXTVAL,
      new_references.inquiry_type_cd,
      new_references.inquiry_type_desc,
      new_references.enabled_flag,
      new_references.imp_source_type_id,
      new_references.info_type_id,
      new_references.configurability_func_name,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, inquiry_type_id INTO x_rowid, x_inquiry_type_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_inquiry_type_id                   IN     NUMBER,
    x_inquiry_type_cd                   IN     VARCHAR2,
    x_inquiry_type_desc                 IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_imp_source_type_id                IN     NUMBER,
    x_info_type_id                      IN     NUMBER,
    x_configurability_func_name         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        inquiry_type_cd,
        inquiry_type_desc,
        enabled_flag,
        imp_source_type_id,
        info_type_id,
        configurability_func_name
      FROM  igr_i_inquiry_types
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
        ((tlinfo.inquiry_type_cd = x_inquiry_type_cd) OR ((tlinfo.inquiry_type_cd IS NULL) AND (X_inquiry_type_cd IS NULL)))
        AND ((tlinfo.inquiry_type_desc = x_inquiry_type_desc) OR ((tlinfo.inquiry_type_desc IS NULL) AND (X_inquiry_type_desc IS NULL)))
        AND ((tlinfo.enabled_flag = x_enabled_flag) OR ((tlinfo.enabled_flag IS NULL) AND (X_enabled_flag IS NULL)))
        AND ((tlinfo.imp_source_type_id = x_imp_source_type_id) OR ((tlinfo.imp_source_type_id IS NULL) AND (X_imp_source_type_id IS NULL)))
        AND ((tlinfo.info_type_id = x_info_type_id) OR ((tlinfo.info_type_id IS NULL) AND (X_info_type_id IS NULL)))
        AND ((tlinfo.configurability_func_name = x_configurability_func_name) OR ((tlinfo.configurability_func_name IS NULL) AND (X_configurability_func_name IS NULL)))
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
    x_inquiry_type_id                   IN     NUMBER,
    x_inquiry_type_cd                   IN     VARCHAR2,
    x_inquiry_type_desc                 IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_imp_source_type_id                IN     NUMBER,
    x_info_type_id                      IN     NUMBER,
    x_configurability_func_name         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
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
      fnd_message.set_token ('ROUTINE', 'IGR_I_INQUIRY_TYPES_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_inquiry_type_id                   => x_inquiry_type_id,
      x_inquiry_type_cd                   => x_inquiry_type_cd,
      x_inquiry_type_desc                 => x_inquiry_type_desc,
      x_enabled_flag                      => x_enabled_flag,
      x_imp_source_type_id                => x_imp_source_type_id,
      x_info_type_id                      => x_info_type_id,
      x_configurability_func_name         => x_configurability_func_name,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igr_i_inquiry_types
      SET
        inquiry_type_cd                   = new_references.inquiry_type_cd,
        inquiry_type_desc                 = new_references.inquiry_type_desc,
        enabled_flag                      = new_references.enabled_flag,
        imp_source_type_id                = new_references.imp_source_type_id,
        info_type_id                      = new_references.info_type_id,
        configurability_func_name         = new_references.configurability_func_name,
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
    x_inquiry_type_id                   IN OUT NOCOPY NUMBER,
    x_inquiry_type_cd                   IN     VARCHAR2,
    x_inquiry_type_desc                 IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_imp_source_type_id                IN     NUMBER,
    x_info_type_id                      IN     NUMBER,
    x_configurability_func_name         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igr_i_inquiry_types
      WHERE    inquiry_type_id                   = x_inquiry_type_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_inquiry_type_id,
        x_inquiry_type_cd,
        x_inquiry_type_desc,
        x_enabled_flag,
        x_imp_source_type_id,
        x_info_type_id,
        x_configurability_func_name,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_inquiry_type_id,
      x_inquiry_type_cd,
      x_inquiry_type_desc,
      x_enabled_flag,
      x_imp_source_type_id,
      x_info_type_id,
      x_configurability_func_name,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
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

    DELETE FROM igr_i_inquiry_types
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igr_i_inquiry_types_pkg;

/
