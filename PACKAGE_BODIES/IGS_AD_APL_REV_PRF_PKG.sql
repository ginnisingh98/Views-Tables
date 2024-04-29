--------------------------------------------------------
--  DDL for Package Body IGS_AD_APL_REV_PRF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APL_REV_PRF_PKG" AS
/* $Header: IGSAIF2B.pls 115.9 2003/10/30 13:17:39 akadam noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_apl_rev_prf_all%ROWTYPE;
  new_references igs_ad_apl_rev_prf_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_rev_profile_id               IN     NUMBER      DEFAULT NULL,
    x_review_profile_name               IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_min_evaluator                     IN     NUMBER      DEFAULT NULL,
    x_max_evaluator                     IN     NUMBER      DEFAULT NULL,
    x_prog_approval_required            IN     VARCHAR2    DEFAULT NULL,
    x_sequential_concurrent_ind         IN     VARCHAR2    DEFAULT NULL,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2    DEFAULT NULL,
    x_site_use_code                     IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
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
      FROM     igs_ad_apl_rev_prf_all
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
    new_references.appl_rev_profile_id               := x_appl_rev_profile_id;
    new_references.review_profile_name               := x_review_profile_name;
    new_references.start_date                        := TRUNC(x_start_date);
    new_references.end_date                          := TRUNC(x_end_date);
    new_references.min_evaluator                     := x_min_evaluator;
    new_references.max_evaluator                     := x_max_evaluator;
    new_references.prog_approval_required            := x_prog_approval_required;
    new_references.sequential_concurrent_ind         := x_sequential_concurrent_ind;
    new_references.appl_rev_profile_gr_cd            := x_appl_rev_profile_gr_cd;
    new_references.site_use_code                     := x_site_use_code;
    new_references.closed_ind                        := x_closed_ind;

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
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.review_profile_name
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

PROCEDURE get_fk_igs_lookups_val (
    x_appl_rev_profile_gr_cd               IN     NUMBER
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
      FROM     igs_ad_apl_rev_prf_all
      WHERE   ((appl_rev_profile_gr_cd = x_appl_rev_profile_gr_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_ADAPR_LVAL_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_lookups_val;



  PROCEDURE check_child_existance IS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_ad_apl_rprf_rgr_pkg.get_fk_igs_ad_apl_rev_prf (
      old_references.appl_rev_profile_id
    );

    igs_ad_apl_rvpf_rsl_pkg.get_fk_igs_ad_apl_rev_prf (
      old_references.appl_rev_profile_id
    );

    igs_ad_appl_arp_pkg.get_fk_igs_ad_apl_rev_prf (
      old_references.appl_rev_profile_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_appl_rev_profile_id               IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2
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
      FROM     igs_ad_apl_rev_prf_all
      WHERE    appl_rev_profile_id = x_appl_rev_profile_id AND
               closed_ind = NVL(x_closed_ind,closed_ind)
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
    x_review_profile_name               IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_apl_rev_prf
      WHERE    review_profile_name = x_review_profile_name
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      AND      closed_ind = NVL(x_closed_ind,closed_ind);

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
    x_appl_rev_profile_id               IN     NUMBER      DEFAULT NULL,
    x_review_profile_name               IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_min_evaluator                     IN     NUMBER      DEFAULT NULL,
    x_max_evaluator                     IN     NUMBER      DEFAULT NULL,
    x_prog_approval_required            IN     VARCHAR2    DEFAULT NULL,
    x_sequential_concurrent_ind         IN     VARCHAR2    DEFAULT NULL,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2    DEFAULT NULL,
    x_site_use_code                     IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
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
      x_appl_rev_profile_id,
      x_review_profile_name,
      x_start_date,
      x_end_date,
      x_min_evaluator,
      x_max_evaluator,
      x_prog_approval_required,
      x_sequential_concurrent_ind,
      x_appl_rev_profile_gr_cd,
      x_site_use_code,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.appl_rev_profile_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.appl_rev_profile_id
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
    x_appl_rev_profile_id               IN OUT NOCOPY NUMBER,
    x_review_profile_name               IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_min_evaluator                     IN     NUMBER,
    x_max_evaluator                     IN     NUMBER,
    x_prog_approval_required            IN     VARCHAR2,
    x_sequential_concurrent_ind         IN     VARCHAR2,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2,
    x_site_use_code                     IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
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
      FROM     igs_ad_apl_rev_prf_all
      WHERE    appl_rev_profile_id               = x_appl_rev_profile_id;

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

    new_references.org_id := igs_ge_gen_003.get_org_id;

    x_appl_rev_profile_id := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_appl_rev_profile_id               => x_appl_rev_profile_id,
      x_review_profile_name               => x_review_profile_name,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_min_evaluator                     => x_min_evaluator,
      x_max_evaluator                     => x_max_evaluator,
      x_prog_approval_required            => x_prog_approval_required,
      x_sequential_concurrent_ind         => x_sequential_concurrent_ind,
      x_appl_rev_profile_gr_cd            => x_appl_rev_profile_gr_cd,
      x_site_use_code                     => x_site_use_code,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ad_apl_rev_prf_all (
      appl_rev_profile_id,
      org_id,
      review_profile_name,
      start_date,
      end_date,
      min_evaluator,
      max_evaluator,
      prog_approval_required,
      sequential_concurrent_ind,
      appl_rev_profile_gr_cd,
      site_use_code,
      closed_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_ad_apl_rev_prf_s.NEXTVAL,
      new_references.org_id,
      new_references.review_profile_name,
      new_references.start_date,
      new_references.end_date,
      new_references.min_evaluator,
      new_references.max_evaluator,
      new_references.prog_approval_required,
      new_references.sequential_concurrent_ind,
      new_references.appl_rev_profile_gr_cd,
      new_references.site_use_code,
      new_references.closed_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    )RETURNING appl_rev_profile_id INTO x_appl_rev_profile_id;

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
    x_appl_rev_profile_id               IN     NUMBER,
    x_review_profile_name               IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_min_evaluator                     IN     NUMBER,
    x_max_evaluator                     IN     NUMBER,
    x_prog_approval_required            IN     VARCHAR2,
    x_sequential_concurrent_ind         IN     VARCHAR2,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2,
    x_site_use_code                     IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
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
        review_profile_name,
        start_date,
        end_date,
        min_evaluator,
        max_evaluator,
        prog_approval_required,
        sequential_concurrent_ind,
        appl_rev_profile_gr_cd,
        site_use_code,
        closed_ind
      FROM  igs_ad_apl_rev_prf_all
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
        (tlinfo.review_profile_name = x_review_profile_name)
        AND (TRUNC(tlinfo.start_date) = TRUNC(x_start_date))
        AND ((TRUNC(tlinfo.end_date) = TRUNC(x_end_date)) OR ((tlinfo.end_date IS NULL) AND (X_end_date IS NULL)))
        AND (tlinfo.min_evaluator = x_min_evaluator)
        AND ((tlinfo.max_evaluator = x_max_evaluator) OR ((tlinfo.max_evaluator IS NULL) AND (X_max_evaluator IS NULL)))
        AND (tlinfo.prog_approval_required = x_prog_approval_required)
        AND (tlinfo.sequential_concurrent_ind = x_sequential_concurrent_ind)
        AND (tlinfo.appl_rev_profile_gr_cd = x_appl_rev_profile_gr_cd)
        AND ((tlinfo.site_use_code = x_site_use_code) OR ((tlinfo.site_use_code IS NULL) AND (X_site_use_code IS NULL)))
        AND (tlinfo.closed_ind = x_closed_ind)
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
    x_appl_rev_profile_id               IN     NUMBER,
    x_review_profile_name               IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_min_evaluator                     IN     NUMBER,
    x_max_evaluator                     IN     NUMBER,
    x_prog_approval_required            IN     VARCHAR2,
    x_sequential_concurrent_ind         IN     VARCHAR2,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2,
    x_site_use_code                     IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
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
      x_appl_rev_profile_id               => x_appl_rev_profile_id,
      x_review_profile_name               => x_review_profile_name,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_min_evaluator                     => x_min_evaluator,
      x_max_evaluator                     => x_max_evaluator,
      x_prog_approval_required            => x_prog_approval_required,
      x_sequential_concurrent_ind         => x_sequential_concurrent_ind,
      x_appl_rev_profile_gr_cd            => x_appl_rev_profile_gr_cd,
      x_site_use_code                     => x_site_use_code,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ad_apl_rev_prf_all
      SET
        review_profile_name               = new_references.review_profile_name,
        start_date                        = new_references.start_date,
        end_date                          = new_references.end_date,
        min_evaluator                     = new_references.min_evaluator,
        max_evaluator                     = new_references.max_evaluator,
        prog_approval_required            = new_references.prog_approval_required,
        sequential_concurrent_ind         = new_references.sequential_concurrent_ind,
        appl_rev_profile_gr_cd            = new_references.appl_rev_profile_gr_cd,
        site_use_code                     = new_references.site_use_code,
        closed_ind                        = new_references.closed_ind,
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
    x_appl_rev_profile_id               IN OUT NOCOPY NUMBER,
    x_review_profile_name               IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_min_evaluator                     IN     NUMBER,
    x_max_evaluator                     IN     NUMBER,
    x_prog_approval_required            IN     VARCHAR2,
    x_sequential_concurrent_ind         IN     VARCHAR2,
    x_appl_rev_profile_gr_cd            IN     VARCHAR2,
    x_site_use_code                     IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
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
      FROM     igs_ad_apl_rev_prf_all
      WHERE    appl_rev_profile_id               = x_appl_rev_profile_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_appl_rev_profile_id,
        x_review_profile_name,
        x_start_date,
        x_end_date,
        x_min_evaluator,
        x_max_evaluator,
        x_prog_approval_required,
        x_sequential_concurrent_ind,
        x_appl_rev_profile_gr_cd,
        x_site_use_code,
        x_closed_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_appl_rev_profile_id,
      x_review_profile_name,
      x_start_date,
      x_end_date,
      x_min_evaluator,
      x_max_evaluator,
      x_prog_approval_required,
      x_sequential_concurrent_ind,
      x_appl_rev_profile_gr_cd,
      x_site_use_code,
      x_closed_ind,
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

    DELETE FROM igs_ad_apl_rev_prf_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_apl_rev_prf_pkg;

/
