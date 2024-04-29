--------------------------------------------------------
--  DDL for Package Body IGF_AW_CIT_LD_OVRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_CIT_LD_OVRD_PKG" AS
/* $Header: IGFWI52B.pls 115.2 2002/11/28 11:24:01 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_cit_ld_ovrd_all%ROWTYPE;
  new_references igf_aw_cit_ld_ovrd_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cldo_id                           IN     NUMBER,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct                          IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_CIT_LD_OVRD_ALL
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
    new_references.cldo_id                           := x_cldo_id;
    new_references.coa_code                          := x_coa_code;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.item_code                         := x_item_code;
    new_references.ld_cal_type                       := x_ld_cal_type;
    new_references.ld_sequence_number                := x_ld_sequence_number;
    new_references.ld_perct                          := x_ld_perct;

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
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.coa_code = new_references.coa_code) AND
         (old_references.ci_cal_type = new_references.ci_cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number) AND
         (old_references.item_code = new_references.item_code)) OR
        ((new_references.coa_code IS NULL) OR
         (new_references.ci_cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL) OR
         (new_references.item_code IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_coa_grp_item_pkg.get_pk_for_validation (
                new_references.coa_code,
                new_references.ci_cal_type,
                new_references.ci_sequence_number,
                new_references.item_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;



  FUNCTION get_pk_for_validation (
    x_cldo_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_cit_ld_ovrd_all
      WHERE    cldo_id = x_cldo_id
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


  PROCEDURE get_fk_igf_aw_coa_grp_item (
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_cit_ld_ovrd_all
      WHERE   ((ci_cal_type = x_ci_cal_type) AND
               (ci_sequence_number = x_ci_sequence_number) AND
               (coa_code = x_coa_code) AND
               (item_code = x_item_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_CLDO_COAGI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_coa_grp_item;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cldo_id                           IN     NUMBER,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct                          IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
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
      x_cldo_id,
      x_coa_code,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_item_code,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_ld_perct,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.cldo_id
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
             new_references.cldo_id
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
    x_cldo_id                           IN OUT NOCOPY NUMBER,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct                          IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_cit_ld_ovrd_all
      WHERE    cldo_id                           = x_cldo_id;

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

    SELECT    igf_aw_cit_ld_ovrd_s.NEXTVAL
    INTO      x_cldo_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_cldo_id                           => x_cldo_id,
      x_coa_code                          => x_coa_code,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_item_code                         => x_item_code,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_ld_perct                          => x_ld_perct,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_cit_ld_ovrd_all (
      cldo_id,
      coa_code,
      ci_cal_type,
      ci_sequence_number,
      item_code,
      ld_cal_type,
      ld_sequence_number,
      ld_perct,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.cldo_id,
      new_references.coa_code,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.item_code,
      new_references.ld_cal_type,
      new_references.ld_sequence_number,
      new_references.ld_perct,
      new_references.org_id,
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
    x_cldo_id                           IN     NUMBER,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct                          IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        coa_code,
        ci_cal_type,
        ci_sequence_number,
        item_code,
        ld_cal_type,
        ld_sequence_number,
        ld_perct
      FROM  igf_aw_cit_ld_ovrd_all
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
        (tlinfo.coa_code = x_coa_code)
        AND (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND (tlinfo.item_code = x_item_code)
        AND (tlinfo.ld_cal_type = x_ld_cal_type)
        AND (tlinfo.ld_sequence_number = x_ld_sequence_number)
        AND (tlinfo.ld_perct = x_ld_perct)
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
    x_cldo_id                           IN     NUMBER,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct                          IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
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
      x_cldo_id                           => x_cldo_id,
      x_coa_code                          => x_coa_code,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_item_code                         => x_item_code,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_ld_perct                          => x_ld_perct,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_aw_cit_ld_ovrd_all
      SET
        coa_code                          = new_references.coa_code,
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        item_code                         = new_references.item_code,
        ld_cal_type                       = new_references.ld_cal_type,
        ld_sequence_number                = new_references.ld_sequence_number,
        ld_perct                          = new_references.ld_perct,
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
    x_cldo_id                           IN OUT NOCOPY NUMBER,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct                          IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_cit_ld_ovrd_all
      WHERE    cldo_id                           = x_cldo_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_cldo_id,
        x_coa_code,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_item_code,
        x_ld_cal_type,
        x_ld_sequence_number,
        x_ld_perct,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_cldo_id,
      x_coa_code,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_item_code,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_ld_perct,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
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

    DELETE FROM igf_aw_cit_ld_ovrd_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_cit_ld_ovrd_pkg;

/
