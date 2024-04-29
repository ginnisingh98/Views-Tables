--------------------------------------------------------
--  DDL for Package Body IGS_AD_RVGR_INC_EXC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_RVGR_INC_EXC_PKG" AS
/* $Header: IGSAIF5B.pls 115.7 2003/01/23 04:46:37 knag noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_rvgr_inc_exc%ROWTYPE;
  new_references igs_ad_rvgr_inc_exc%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_revgr_incl_excl_id                IN     NUMBER      DEFAULT NULL,
    x_appl_revprof_revgr_id             IN     NUMBER      DEFAULT NULL,
    x_incl_excl_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_start_value                       IN     VARCHAR2    DEFAULT NULL,
    x_end_value                         IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_postal_incl_excl_ind              IN     VARCHAR2    DEFAULT NULL,
    x_postal_start_value                IN     VARCHAR2    DEFAULT NULL,
    x_postal_end_value                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ad_rvgr_inc_exc
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
    new_references.revgr_incl_excl_id                := x_revgr_incl_excl_id;
    new_references.appl_revprof_revgr_id             := x_appl_revprof_revgr_id;
    new_references.incl_excl_ind                     := x_incl_excl_ind;
    new_references.start_value                       := x_start_value;
    new_references.end_value                         := x_end_value;
    new_references.version_number                    := x_version_number;
    new_references.country                           := x_country;
    new_references.postal_incl_excl_ind              := x_postal_incl_excl_ind;
    new_references.postal_start_value                := x_postal_start_value;
    new_references.postal_end_value                  := x_postal_end_value;

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
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.appl_revprof_revgr_id = new_references.appl_revprof_revgr_id)) OR
        ((new_references.appl_revprof_revgr_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_apl_rprf_rgr_pkg.get_pk_for_validation (
                new_references.appl_revprof_revgr_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_revgr_incl_excl_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_rvgr_inc_exc
      WHERE    revgr_incl_excl_id = x_revgr_incl_excl_id
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


  PROCEDURE get_fk_igs_ad_apl_rprf_rgr (
    x_appl_revprof_revgr_id             IN     NUMBER
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_rvgr_inc_exc
      WHERE   ((appl_revprof_revgr_id = x_appl_revprof_revgr_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_RGINX_APRRGR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_apl_rprf_rgr;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_revgr_incl_excl_id                IN     NUMBER      DEFAULT NULL,
    x_appl_revprof_revgr_id             IN     NUMBER      DEFAULT NULL,
    x_incl_excl_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_start_value                       IN     VARCHAR2    DEFAULT NULL,
    x_end_value                         IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_postal_incl_excl_ind              IN     VARCHAR2    DEFAULT NULL,
    x_postal_start_value                IN     VARCHAR2    DEFAULT NULL,
    x_postal_end_value                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
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
      x_revgr_incl_excl_id,
      x_appl_revprof_revgr_id,
      x_incl_excl_ind,
      x_start_value,
      x_end_value,
      x_version_number,
      x_country,
      x_postal_incl_excl_ind,
      x_postal_start_value,
      x_postal_end_value,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.revgr_incl_excl_id
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
             new_references.revgr_incl_excl_id
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
    x_revgr_incl_excl_id                IN OUT NOCOPY NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_incl_excl_ind                     IN     VARCHAR2,
    x_start_value                       IN     VARCHAR2,
    x_end_value                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_country                           IN     VARCHAR2,
    x_postal_incl_excl_ind              IN     VARCHAR2,
    x_postal_start_value                IN     VARCHAR2,
    x_postal_end_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_rvgr_inc_exc
      WHERE    revgr_incl_excl_id                = x_revgr_incl_excl_id;

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

    x_revgr_incl_excl_id := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_revgr_incl_excl_id                => x_revgr_incl_excl_id,
      x_appl_revprof_revgr_id             => x_appl_revprof_revgr_id,
      x_incl_excl_ind                     => x_incl_excl_ind,
      x_start_value                       => x_start_value,
      x_end_value                         => x_end_value,
      x_version_number                    => x_version_number,
      x_country                           => x_country,
      x_postal_incl_excl_ind              => x_postal_incl_excl_ind,
      x_postal_start_value                => x_postal_start_value,
      x_postal_end_value                  => x_postal_end_value,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ad_rvgr_inc_exc (
      revgr_incl_excl_id,
      appl_revprof_revgr_id,
      incl_excl_ind,
      start_value,
      end_value,
      version_number,
      country,
      postal_incl_excl_ind,
      postal_start_value,
      postal_end_value,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      IGS_AD_RVGR_INC_EXC_S.NEXTVAL,
      new_references.appl_revprof_revgr_id,
      new_references.incl_excl_ind,
      new_references.start_value,
      new_references.end_value,
      new_references.version_number,
      new_references.country,
      new_references.postal_incl_excl_ind,
      new_references.postal_start_value,
      new_references.postal_end_value,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING revgr_incl_excl_id INTO x_revgr_incl_excl_id;

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
    x_revgr_incl_excl_id                IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_incl_excl_ind                     IN     VARCHAR2,
    x_start_value                       IN     VARCHAR2,
    x_end_value                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_country                           IN     VARCHAR2,
    x_postal_incl_excl_ind              IN     VARCHAR2,
    x_postal_start_value                IN     VARCHAR2,
    x_postal_end_value                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        appl_revprof_revgr_id,
        incl_excl_ind,
        start_value,
        end_value,
        version_number,
        country,
        postal_incl_excl_ind,
        postal_start_value,
        postal_end_value
      FROM  igs_ad_rvgr_inc_exc
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
        (tlinfo.appl_revprof_revgr_id = x_appl_revprof_revgr_id)
        AND ((tlinfo.incl_excl_ind = x_incl_excl_ind) OR ((tlinfo.incl_excl_ind IS NULL) AND (X_incl_excl_ind IS NULL)))
        AND ((tlinfo.start_value = x_start_value) OR ((tlinfo.start_value IS NULL) AND (X_start_value IS NULL)))
        AND ((tlinfo.end_value = x_end_value) OR ((tlinfo.end_value IS NULL) AND (X_end_value IS NULL)))
        AND ((tlinfo.version_number = x_version_number) OR ((tlinfo.version_number IS NULL) AND (X_version_number IS NULL)))
        AND ((tlinfo.country = x_country) OR ((tlinfo.country IS NULL) AND (X_country IS NULL)))
        AND ((tlinfo.postal_incl_excl_ind = x_postal_incl_excl_ind) OR ((tlinfo.postal_incl_excl_ind IS NULL) AND (X_postal_incl_excl_ind IS NULL)))
        AND ((tlinfo.postal_start_value = x_postal_start_value) OR ((tlinfo.postal_start_value IS NULL) AND (X_postal_start_value IS NULL)))
        AND ((tlinfo.postal_end_value = x_postal_end_value) OR ((tlinfo.postal_end_value IS NULL) AND (X_postal_end_value IS NULL)))
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
    x_revgr_incl_excl_id                IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_incl_excl_ind                     IN     VARCHAR2,
    x_start_value                       IN     VARCHAR2,
    x_end_value                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_country                           IN     VARCHAR2,
    x_postal_incl_excl_ind              IN     VARCHAR2,
    x_postal_start_value                IN     VARCHAR2,
    x_postal_end_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
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
      x_revgr_incl_excl_id                => x_revgr_incl_excl_id,
      x_appl_revprof_revgr_id             => x_appl_revprof_revgr_id,
      x_incl_excl_ind                     => x_incl_excl_ind,
      x_start_value                       => x_start_value,
      x_end_value                         => x_end_value,
      x_version_number                    => x_version_number,
      x_country                           => x_country,
      x_postal_incl_excl_ind              => x_postal_incl_excl_ind,
      x_postal_start_value                => x_postal_start_value,
      x_postal_end_value                  => x_postal_end_value,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ad_rvgr_inc_exc
      SET
        appl_revprof_revgr_id             = new_references.appl_revprof_revgr_id,
        incl_excl_ind                     = new_references.incl_excl_ind,
        start_value                       = new_references.start_value,
        end_value                         = new_references.end_value,
        version_number                    = new_references.version_number,
        country                           = new_references.country,
        postal_incl_excl_ind              = new_references.postal_incl_excl_ind,
        postal_start_value                = new_references.postal_start_value,
        postal_end_value                  = new_references.postal_end_value,
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
    x_revgr_incl_excl_id                IN OUT NOCOPY NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_incl_excl_ind                     IN     VARCHAR2,
    x_start_value                       IN     VARCHAR2,
    x_end_value                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_country                           IN     VARCHAR2,
    x_postal_incl_excl_ind              IN     VARCHAR2,
    x_postal_start_value                IN     VARCHAR2,
    x_postal_end_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_rvgr_inc_exc
      WHERE    revgr_incl_excl_id                = x_revgr_incl_excl_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_revgr_incl_excl_id,
        x_appl_revprof_revgr_id,
        x_incl_excl_ind,
        x_start_value,
        x_end_value,
        x_version_number,
        x_country,
        x_postal_incl_excl_ind,
        x_postal_start_value,
        x_postal_end_value,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_revgr_incl_excl_id,
      x_appl_revprof_revgr_id,
      x_incl_excl_ind,
      x_start_value,
      x_end_value,
      x_version_number,
      x_country,
      x_postal_incl_excl_ind,
      x_postal_start_value,
      x_postal_end_value,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
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

    DELETE FROM igs_ad_rvgr_inc_exc
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_rvgr_inc_exc_pkg;

/
