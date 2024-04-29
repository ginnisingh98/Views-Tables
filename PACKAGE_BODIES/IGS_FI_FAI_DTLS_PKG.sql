--------------------------------------------------------
--  DDL for Package Body IGS_FI_FAI_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FAI_DTLS_PKG" AS
/* $Header: IGSSIF5B.pls 120.0 2005/09/09 17:48:33 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_fai_dtls%ROWTYPE;
  new_references igs_fi_fai_dtls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_fee_as_item_dtl_id                IN     NUMBER,
    x_fee_ass_item_id                   IN     NUMBER,
    x_fee_cat                           IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_attempt_status               IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_chg_elements                      IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 27-JUN-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_fai_dtls
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
    new_references.fee_as_item_dtl_id                := x_fee_as_item_dtl_id;
    new_references.fee_ass_item_id                   := x_fee_ass_item_id;
    new_references.fee_cat                           := x_fee_cat;
    new_references.course_cd                         := x_course_cd;
    new_references.crs_version_number                := x_crs_version_number;
    new_references.unit_attempt_status               := x_unit_attempt_status;
    new_references.org_unit_cd                       := x_org_unit_cd;
    new_references.class_standing                    := x_class_standing;
    new_references.location_cd                       := x_location_cd;
    new_references.uoo_id                            := x_uoo_id;
    new_references.unit_set_cd                       := x_unit_set_cd;
    new_references.us_version_number                 := x_us_version_number;
    new_references.chg_elements                      := x_chg_elements;

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
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 27-JUN-2005
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.fee_ass_item_id = new_references.fee_ass_item_id)) OR
        ((new_references.fee_ass_item_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_fee_as_items_pkg.get_pk_for_validation (
                new_references.fee_ass_item_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.us_version_number = new_references.us_version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.us_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_unit_set_pkg.get_pk_for_validation (
                new_references.unit_set_cd,
                new_references.us_version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (
                new_references.uoo_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_fee_as_item_dtl_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 27-JUN-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_fai_dtls
      WHERE    fee_as_item_dtl_id = x_fee_as_item_dtl_id
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
    x_fee_as_item_dtl_id                IN     NUMBER,
    x_fee_ass_item_id                   IN     NUMBER,
    x_fee_cat                           IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_attempt_status               IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_chg_elements                      IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 27-JUN-2005
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
      x_fee_as_item_dtl_id,
      x_fee_ass_item_id,
      x_fee_cat,
      x_course_cd,
      x_crs_version_number,
      x_unit_attempt_status,
      x_org_unit_cd,
      x_class_standing,
      x_location_cd,
      x_uoo_id,
      x_unit_set_cd,
      x_us_version_number,
      x_chg_elements,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.fee_as_item_dtl_id
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
             new_references.fee_as_item_dtl_id
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
    x_fee_as_item_dtl_id                IN OUT NOCOPY NUMBER,
    x_fee_ass_item_id                   IN     NUMBER,
    x_fee_cat                           IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_attempt_status               IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_chg_elements                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 27-JUN-2005
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_FAI_DTLS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_fee_as_item_dtl_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_fee_as_item_dtl_id                => x_fee_as_item_dtl_id,
      x_fee_ass_item_id                   => x_fee_ass_item_id,
      x_fee_cat                           => x_fee_cat,
      x_course_cd                         => x_course_cd,
      x_crs_version_number                => x_crs_version_number,
      x_unit_attempt_status               => x_unit_attempt_status,
      x_org_unit_cd                       => x_org_unit_cd,
      x_class_standing                    => x_class_standing,
      x_location_cd                       => x_location_cd,
      x_uoo_id                            => x_uoo_id,
      x_unit_set_cd                       => x_unit_set_cd,
      x_us_version_number                 => x_us_version_number,
      x_chg_elements                      => x_chg_elements,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_fai_dtls (
      fee_as_item_dtl_id,
      fee_ass_item_id,
      fee_cat,
      course_cd,
      crs_version_number,
      unit_attempt_status,
      org_unit_cd,
      class_standing,
      location_cd,
      uoo_id,
      unit_set_cd,
      us_version_number,
      chg_elements,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_fi_fai_dtls_s.NEXTVAL,
      new_references.fee_ass_item_id,
      new_references.fee_cat,
      new_references.course_cd,
      new_references.crs_version_number,
      new_references.unit_attempt_status,
      new_references.org_unit_cd,
      new_references.class_standing,
      new_references.location_cd,
      new_references.uoo_id,
      new_references.unit_set_cd,
      new_references.us_version_number,
      new_references.chg_elements,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, fee_as_item_dtl_id INTO x_rowid, x_fee_as_item_dtl_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fee_as_item_dtl_id                IN     NUMBER,
    x_fee_ass_item_id                   IN     NUMBER,
    x_fee_cat                           IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_attempt_status               IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_chg_elements                      IN     NUMBER
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 27-JUN-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        fee_ass_item_id,
        fee_cat,
        course_cd,
        crs_version_number,
        unit_attempt_status,
        org_unit_cd,
        class_standing,
        location_cd,
        uoo_id,
        unit_set_cd,
        us_version_number,
        chg_elements
      FROM  igs_fi_fai_dtls
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
        (tlinfo.fee_ass_item_id = x_fee_ass_item_id)
        AND (tlinfo.fee_cat = x_fee_cat)
        AND (tlinfo.course_cd = x_course_cd)
        AND (tlinfo.crs_version_number = x_crs_version_number)
        AND (tlinfo.unit_attempt_status = x_unit_attempt_status)
        AND ((tlinfo.org_unit_cd = x_org_unit_cd) OR ((tlinfo.org_unit_cd IS NULL) AND (X_org_unit_cd IS NULL)))
        AND ((tlinfo.class_standing = x_class_standing) OR ((tlinfo.class_standing IS NULL) AND (X_class_standing IS NULL)))
        AND (tlinfo.location_cd = x_location_cd)
        AND (tlinfo.uoo_id = x_uoo_id)
        AND ((tlinfo.unit_set_cd = x_unit_set_cd) OR ((tlinfo.unit_set_cd IS NULL) AND (X_unit_set_cd IS NULL)))
        AND ((tlinfo.us_version_number = x_us_version_number) OR ((tlinfo.us_version_number IS NULL) AND (X_us_version_number IS NULL)))
        AND ((tlinfo.chg_elements = x_chg_elements) OR ((tlinfo.chg_elements IS NULL) AND (X_chg_elements IS NULL)))
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
    x_fee_as_item_dtl_id                IN     NUMBER,
    x_fee_ass_item_id                   IN     NUMBER,
    x_fee_cat                           IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_attempt_status               IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_chg_elements                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 27-JUN-2005
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_FAI_DTLS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_fee_as_item_dtl_id                => x_fee_as_item_dtl_id,
      x_fee_ass_item_id                   => x_fee_ass_item_id,
      x_fee_cat                           => x_fee_cat,
      x_course_cd                         => x_course_cd,
      x_crs_version_number                => x_crs_version_number,
      x_unit_attempt_status               => x_unit_attempt_status,
      x_org_unit_cd                       => x_org_unit_cd,
      x_class_standing                    => x_class_standing,
      x_location_cd                       => x_location_cd,
      x_uoo_id                            => x_uoo_id,
      x_unit_set_cd                       => x_unit_set_cd,
      x_us_version_number                 => x_us_version_number,
      x_chg_elements                      => x_chg_elements,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_fi_fai_dtls
      SET
        fee_ass_item_id                   = new_references.fee_ass_item_id,
        fee_cat                           = new_references.fee_cat,
        course_cd                         = new_references.course_cd,
        crs_version_number                = new_references.crs_version_number,
        unit_attempt_status               = new_references.unit_attempt_status,
        org_unit_cd                       = new_references.org_unit_cd,
        class_standing                    = new_references.class_standing,
        location_cd                       = new_references.location_cd,
        uoo_id                            = new_references.uoo_id,
        unit_set_cd                       = new_references.unit_set_cd,
        us_version_number                 = new_references.us_version_number,
        chg_elements                      = new_references.chg_elements,
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
    x_fee_as_item_dtl_id                IN OUT NOCOPY NUMBER,
    x_fee_ass_item_id                   IN     NUMBER,
    x_fee_cat                           IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_attempt_status               IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_chg_elements                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 27-JUN-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_fai_dtls
      WHERE    fee_as_item_dtl_id                = x_fee_as_item_dtl_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_fee_as_item_dtl_id,
        x_fee_ass_item_id,
        x_fee_cat,
        x_course_cd,
        x_crs_version_number,
        x_unit_attempt_status,
        x_org_unit_cd,
        x_class_standing,
        x_location_cd,
        x_uoo_id,
        x_unit_set_cd,
        x_us_version_number,
        x_chg_elements,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_fee_as_item_dtl_id,
      x_fee_ass_item_id,
      x_fee_cat,
      x_course_cd,
      x_crs_version_number,
      x_unit_attempt_status,
      x_org_unit_cd,
      x_class_standing,
      x_location_cd,
      x_uoo_id,
      x_unit_set_cd,
      x_us_version_number,
      x_chg_elements,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 27-JUN-2005
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

    DELETE FROM igs_fi_fai_dtls
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_fai_dtls_pkg;

/
