--------------------------------------------------------
--  DDL for Package Body IGS_AD_APL_RVPF_RSL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APL_RVPF_RSL_PKG" AS
/* $Header: IGSAIF3B.pls 115.12 2003/12/09 11:08:06 akadam noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_apl_rvpf_rsl%ROWTYPE;
  new_references igs_ad_apl_rvpf_rsl%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_revprof_rtscale_id           IN     NUMBER      DEFAULT NULL,
    x_appl_rev_profile_id               IN     NUMBER      DEFAULT NULL,
    x_rating_type_id                    IN     NUMBER      DEFAULT NULL,
    x_rating_scale_id                   IN     NUMBER      DEFAULT NULL,
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
      FROM     igs_ad_apl_rvpf_rsl
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
    new_references.appl_revprof_rtscale_id           := x_appl_revprof_rtscale_id;
    new_references.appl_rev_profile_id               := x_appl_rev_profile_id;
    new_references.rating_type_id                    := x_rating_type_id;
    new_references.rating_scale_id                   := x_rating_scale_id;

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
  ||  Created By :
  ||  Created On : 28-NOV-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.appl_rev_profile_id,
           new_references.rating_type_id,
           new_references.rating_scale_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

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

    IF (((old_references.appl_rev_profile_id = new_references.appl_rev_profile_id)) OR
        ((new_references.appl_rev_profile_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_apl_rev_prf_pkg.get_pk_for_validation (
                new_references.appl_rev_profile_id ,
            'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.rating_type_id = new_references.rating_type_id)) OR
        ((new_references.rating_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_code_classes_pkg.get_uk2_for_validation (
                new_references.rating_type_id ,
                'RATING_TYPE',
            'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.rating_scale_id = new_references.rating_scale_id)) OR
        ((new_references.rating_scale_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_rating_scales_pkg.get_pk_for_validation (
                new_references.rating_scale_id ,
            'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


   -- This is added to allow a Rating Scale to an existing Rating Type for a particular
   --Application Review Profile only if the earlier Rating Scaled has expired.
   --the same is being called in the before_DML for insert and update
  PROCEDURE beforerowinsertupdate (
    x_appl_rev_profile_id IN NUMBER,
    x_rating_type_id IN NUMBER
  ) AS
    CURSOR c_rating_scale_closed(l_appl_rev_profile_id igs_ad_apl_rvpf_rsl.appl_rev_profile_id%TYPE,
    				 l_rating_type_id NUMBER) IS
      SELECT end_date FROM igs_ad_rating_scales rs,
      			   igs_ad_apl_rvpf_rsl ars,
      			   igs_ad_code_classes cc
      WHERE rs.rating_scale_id =  ars.rating_scale_id
      AND cc.code_id = ars.rating_type_id
      AND ars.rating_type_id = l_rating_type_id
      AND ars.appl_rev_profile_id=l_appl_rev_profile_id;

    lv_end_date igs_ad_rating_scales.end_date%TYPE;

  BEGIN
      OPEN c_rating_scale_closed(x_appl_rev_profile_id, x_rating_type_id);
      FETCH c_rating_scale_closed INTO lv_end_date;
      IF c_rating_scale_closed%NOTFOUND THEN
        null;
      ELSE
        IF lv_end_date IS NULL OR lv_end_date >= SYSDATE THEN
          fnd_message.set_name ('IGS', 'IGS_AD_RAT_SCALE_NOT_END');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
          RETURN;
	ELSE
	  null;
	END IF;
      END IF;
      CLOSE c_rating_scale_closed;
  END beforerowinsertupdate;


  FUNCTION get_pk_for_validation (
    x_appl_revprof_rtscale_id           IN     NUMBER
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
      FROM     igs_ad_apl_rvpf_rsl
      WHERE    appl_revprof_rtscale_id = x_appl_revprof_rtscale_id
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
    x_appl_rev_profile_id               IN     NUMBER,
    x_rating_type_id                    IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 28-NOV-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_apl_rvpf_rsl
      WHERE    appl_rev_profile_id = x_appl_rev_profile_id
      AND      rating_type_id = x_rating_type_id
      AND      rating_scale_id = x_rating_scale_id
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


  PROCEDURE get_fk_igs_ad_apl_rev_prf (
    x_appl_rev_profile_id               IN     NUMBER
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
      FROM     igs_ad_apl_rvpf_rsl
      WHERE   ((appl_rev_profile_id = x_appl_rev_profile_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_APRSCL_ADAPR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_apl_rev_prf;


  PROCEDURE get_fk_igs_ad_code_classes (
    x_code_id                           IN     NUMBER
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
      FROM     igs_ad_apl_rvpf_rsl
      WHERE   ((rating_type_id = x_code_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_APRSCL_ADCC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_code_classes;


  PROCEDURE get_fk_igs_ad_rating_scales (
    x_rating_scale_id                    IN     NUMBER
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
      FROM     igs_ad_rating_scales
      WHERE   ((rating_scale_id = x_rating_scale_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_APRSCL_ARS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_rating_scales;



  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_revprof_rtscale_id           IN     NUMBER      DEFAULT NULL,
    x_appl_rev_profile_id               IN     NUMBER      DEFAULT NULL,
    x_rating_type_id                    IN     NUMBER      DEFAULT NULL,
    x_rating_scale_id                   IN     NUMBER      DEFAULT NULL,
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
      x_appl_revprof_rtscale_id,
      x_appl_rev_profile_id,
      x_rating_type_id,
      x_rating_scale_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.appl_revprof_rtscale_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
      beforerowinsertupdate (
        x_appl_rev_profile_id,
        x_rating_type_id);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_uniqueness;
      beforerowinsertupdate (
        x_appl_rev_profile_id,
        x_rating_type_id);
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.appl_revprof_rtscale_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
     ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_revprof_rtscale_id           IN OUT NOCOPY NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_rating_type_id                    IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER,
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
      FROM     igs_ad_apl_rvpf_rsl
      WHERE    appl_revprof_rtscale_id           = x_appl_revprof_rtscale_id;

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

    x_appl_revprof_rtscale_id := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_appl_revprof_rtscale_id           => x_appl_revprof_rtscale_id,
      x_appl_rev_profile_id               => x_appl_rev_profile_id,
      x_rating_type_id                    => x_rating_type_id,
      x_rating_scale_id                   => x_rating_scale_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ad_apl_rvpf_rsl (
      appl_revprof_rtscale_id,
      appl_rev_profile_id,
      rating_type_id,
      rating_scale_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_ad_apl_rvpf_rsl_s.NEXTVAL,
      new_references.appl_rev_profile_id,
      new_references.rating_type_id,
      new_references.rating_scale_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    )RETURNING appl_revprof_rtscale_id INTO x_appl_revprof_rtscale_id;

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
    x_appl_revprof_rtscale_id           IN     NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_rating_type_id                    IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER
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
        appl_rev_profile_id,
        rating_type_id,
        rating_scale_id
      FROM  igs_ad_apl_rvpf_rsl
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
        (tlinfo.appl_rev_profile_id = x_appl_rev_profile_id)
        AND (tlinfo.rating_type_id = x_rating_type_id)
        AND (tlinfo.rating_scale_id = x_rating_scale_id)
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
    x_appl_revprof_rtscale_id           IN     NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_rating_type_id                    IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER,
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
      x_appl_revprof_rtscale_id           => x_appl_revprof_rtscale_id,
      x_appl_rev_profile_id               => x_appl_rev_profile_id,
      x_rating_type_id                    => x_rating_type_id,
      x_rating_scale_id                   => x_rating_scale_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ad_apl_rvpf_rsl
      SET
        appl_rev_profile_id               = new_references.appl_rev_profile_id,
        rating_type_id                    = new_references.rating_type_id,
        rating_scale_id                   = new_references.rating_scale_id,
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
    x_appl_revprof_rtscale_id           IN OUT NOCOPY NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_rating_type_id                    IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER,
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
      FROM     igs_ad_apl_rvpf_rsl
      WHERE    appl_revprof_rtscale_id           = x_appl_revprof_rtscale_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_appl_revprof_rtscale_id,
        x_appl_rev_profile_id,
        x_rating_type_id,
        x_rating_scale_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_appl_revprof_rtscale_id,
      x_appl_rev_profile_id,
      x_rating_type_id,
      x_rating_scale_id,
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

    DELETE FROM igs_ad_apl_rvpf_rsl
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_apl_rvpf_rsl_pkg;

/
