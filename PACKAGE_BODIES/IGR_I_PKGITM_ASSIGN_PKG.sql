--------------------------------------------------------
--  DDL for Package Body IGR_I_PKGITM_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_PKGITM_ASSIGN_PKG" AS
/* $Header: IGSRH20B.pls 120.0 2005/06/01 21:48:34 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGR_I_PKGITM_ASSIGN%ROWTYPE;
  new_references IGR_I_PKGITM_ASSIGN%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_pkg_item_assign_id                IN     NUMBER,
    x_product_category_id               IN     NUMBER,
    x_product_category_set_id           IN     NUMBER,
    x_package_item_id                   IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle..com
  ||  Created On : 13-MAR-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGR_I_PKGITM_ASSIGN
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
    new_references.pkg_item_assign_id                := x_pkg_item_assign_id;
    new_references.product_category_id               := x_product_category_id;
    new_references.product_category_set_id           := x_product_category_set_id;
    new_references.package_item_id                   := x_package_item_id;
    new_references.enabled_flag                      := x_enabled_flag;

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


   FUNCTION get_uk_for_validation (
    x_product_category_id                       IN     NUMBER,
    x_package_item_id          	                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : apadegal
  ||  Created On : 13-Mar-2005
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_PKGITM_ASSIGN
      WHERE    package_item_id = x_package_item_id
      AND      product_category_id = x_product_category_id
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

   PROCEDURE check_uniqueness AS
  /*
  ||  Created By : apadegal
  ||  Created On : 13-Mar-2005
  ||  Purpose : Handles the unique contraint logic.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.product_category_id,
	   new_references.package_item_id
          )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  FUNCTION check_parent_mtl_cat  (
    x_product_category_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : apadegal
  ||  Created On : 13-MAR-2005
  ||  Purpose : As get_pk_for_validation is not available in
  ||             mtl_categories_pkg package
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur IS
      SELECT   CATEGORY_ID
      FROM     MTL_CATEGORIES_B
      WHERE    CATEGORY_ID  = x_product_category_id
      FOR UPDATE NOWAIT;

    lv_category_id cur%RowType;

  BEGIN

    OPEN cur;
    FETCH cur INTO lv_category_id;
    IF (cur%FOUND) THEN
      CLOSE cur;
      RETURN(TRUE);
    ELSE
      CLOSE cur;
      RETURN(FALSE);
    END IF;

  END check_parent_mtl_cat;

  FUNCTION check_parent_mtl_cat_sets   (
    x_product_category_set_id               IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : apadegal
  ||  Created On : 13-MAR-2005
  ||  Purpose : As get_pk_for_validation is not available in
  ||            mtl_category_sets_pkg package
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur IS
      SELECT   category_set_id
      FROM     MTL_CATEGORY_SETS_B
      WHERE    category_set_id   = x_product_category_set_id
      FOR UPDATE NOWAIT;

    lv_category_set_id cur%RowType;

  BEGIN

    OPEN cur;
    FETCH cur INTO lv_category_set_id;
    IF (cur%FOUND) THEN
      CLOSE cur;
      RETURN(TRUE);
    ELSE
      CLOSE cur;
      RETURN(FALSE);
    END IF;

  END check_parent_mtl_cat_sets;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : adarsh.padegal@oracle..com
  ||  Created On : 13-MAR-2005
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.package_item_id = new_references.package_item_id)) OR
        ((new_references.package_item_id IS NULL))) THEN
      NULL;
    ELSIF NOT igr_i_pkg_item_pkg.get_pk_for_validation (
                new_references.package_item_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.product_category_id = new_references.product_category_id)) OR
        ((new_references.product_category_id IS NULL))) THEN
      NULL;
    ELSIF NOT check_parent_mtl_cat (
                new_references.product_category_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;


    IF (((old_references.product_category_set_id = new_references.product_category_set_id)) OR
        ((new_references.product_category_set_id IS NULL))) THEN
      NULL;
    ELSIF NOT check_parent_mtl_cat_sets (
                new_references.product_category_set_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_pkg_item_assign_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : adarsh.padegal@oracle..com
  ||  Created On : 13-MAR-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_PKGITM_ASSIGN
      WHERE    pkg_item_assign_id = x_pkg_item_assign_id
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


  PROCEDURE get_fk_igr_i_pkg_item (
    x_package_item_id                   IN     NUMBER
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle..com
  ||  Created On : 13-MAR-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_PKGITM_ASSIGN
      WHERE   ((package_item_id = x_package_item_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', ' IGR_PITM_PASITM_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igr_i_pkg_item;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_pkg_item_assign_id                IN     NUMBER,
    x_product_category_id               IN     NUMBER,
    x_product_category_set_id           IN     NUMBER,
    x_package_item_id                   IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle..com
  ||  Created On : 13-MAR-2005
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
      x_pkg_item_assign_id,
      x_product_category_id,
      x_product_category_set_id,
      x_package_item_id,
      x_enabled_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.pkg_item_assign_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.pkg_item_assign_id
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
    x_pkg_item_assign_id                IN OUT NOCOPY NUMBER,
    x_product_category_id               IN     NUMBER,
    x_product_category_set_id           IN     NUMBER,
    x_package_item_id                   IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle..com
  ||  Created On : 13-MAR-2005
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
      fnd_message.set_token ('ROUTINE', 'IGR_I_PKGITM_ASSIGN_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_pkg_item_assign_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_pkg_item_assign_id                => x_pkg_item_assign_id,
      x_product_category_id               => x_product_category_id,
      x_product_category_set_id           => x_product_category_set_id,
      x_package_item_id                   => x_package_item_id,
      x_enabled_flag                      => x_enabled_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO IGR_I_PKGITM_ASSIGN (
      pkg_item_assign_id,
      product_category_id,
      product_category_set_id,
      package_item_id,
      enabled_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      IGR_I_PKGITM_ASSIGN_S.NEXTVAL,
      new_references.product_category_id,
      new_references.product_category_set_id,
      new_references.package_item_id,
      new_references.enabled_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, pkg_item_assign_id INTO x_rowid, x_pkg_item_assign_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_pkg_item_assign_id                IN     NUMBER,
    x_product_category_id               IN     NUMBER,
    x_product_category_set_id           IN     NUMBER,
    x_package_item_id                   IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle..com
  ||  Created On : 13-MAR-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        product_category_id,
        product_category_set_id,
        package_item_id,
        enabled_flag
      FROM  IGR_I_PKGITM_ASSIGN
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
        (tlinfo.product_category_id = x_product_category_id)
        AND (tlinfo.product_category_set_id = x_product_category_set_id)
        AND (tlinfo.package_item_id = x_package_item_id)
        AND (tlinfo.enabled_flag = x_enabled_flag)
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
    x_pkg_item_assign_id                IN     NUMBER,
    x_product_category_id               IN     NUMBER,
    x_product_category_set_id           IN     NUMBER,
    x_package_item_id                   IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle..com
  ||  Created On : 13-MAR-2005
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
      fnd_message.set_token ('ROUTINE', 'IGR_I_PKGITM_ASSIGN_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_pkg_item_assign_id                => x_pkg_item_assign_id,
      x_product_category_id               => x_product_category_id,
      x_product_category_set_id           => x_product_category_set_id,
      x_package_item_id                   => x_package_item_id,
      x_enabled_flag                      => x_enabled_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE IGR_I_PKGITM_ASSIGN
      SET
        product_category_id               = new_references.product_category_id,
        product_category_set_id           = new_references.product_category_set_id,
        package_item_id                   = new_references.package_item_id,
        enabled_flag                      = new_references.enabled_flag,
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
    x_pkg_item_assign_id                IN OUT NOCOPY NUMBER,
    x_product_category_id               IN     NUMBER,
    x_product_category_set_id           IN     NUMBER,
    x_package_item_id                   IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle..com
  ||  Created On : 13-MAR-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     IGR_I_PKGITM_ASSIGN
      WHERE    pkg_item_assign_id                = x_pkg_item_assign_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_pkg_item_assign_id,
        x_product_category_id,
        x_product_category_set_id,
        x_package_item_id,
        x_enabled_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_pkg_item_assign_id,
      x_product_category_id,
      x_product_category_set_id,
      x_package_item_id,
      x_enabled_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : adarsh.padegal@oracle..com
  ||  Created On : 13-MAR-2005
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

    DELETE FROM IGR_I_PKGITM_ASSIGN
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;



END IGR_I_PKGITM_ASSIGN_PKG;

/
