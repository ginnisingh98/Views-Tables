--------------------------------------------------------
--  DDL for Package Body IGF_AW_FSEOG_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_FSEOG_MATCH_PKG" AS
/* $Header: IGFWI41B.pls 115.7 2002/11/28 12:31:47 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_fseog_match_all%ROWTYPE;
  new_references igf_aw_fseog_match_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_match_order                       IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_FSEOG_MATCH_ALL
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
    new_references.fund_id                           := x_fund_id;
    new_references.match_order                       := x_match_order;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;

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
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.ci_cal_type,
           new_references.ci_sequence_number,
           new_references.match_order,
           new_references.org_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.ci_cal_type = new_references.ci_cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.ci_cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.ci_cal_type,
                new_references.ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_fund_id                           IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fseog_match_all
      WHERE    fund_id = x_fund_id
      AND      ci_cal_type = x_ci_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
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
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_match_order                       IN     NUMBER,
    x_org_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  vvutukur       18-feb-2002     modified check of org_id in cur_rowid cursor using new local variable l_org_id
  ||                                 and selected from igf_aw_fseog_match instead of igf_aw_fseog_match_all.bug:2222272
  ||  (reverse chronological order - newest change first)
  */

    l_org_id    igf_aw_fseog_match_all.org_id%TYPE    DEFAULT igf_aw_gen.get_org_id;

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fseog_match
      WHERE    ci_cal_type = x_ci_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      match_order = x_match_order
      AND      NVL(org_id,NVL(l_org_id,-99)) = NVL(l_org_id,-99)  --BUG:2222272
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


  PROCEDURE get_fk_igs_ca_inst_all (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fseog_match_all
      WHERE   ((ci_cal_type = x_cal_type) AND
               (ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_FMAT_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_match_order                       IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
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
      x_fund_id,
      x_match_order,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.fund_id,
             new_references.ci_cal_type,
             new_references.ci_sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
             new_references.fund_id,
             new_references.ci_cal_type,
             new_references.ci_sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
    x_fund_id                           IN     NUMBER,
    x_match_order                       IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_fseog_match_all
      WHERE    fund_id                           = x_fund_id
      AND      ci_cal_type                       = x_ci_cal_type
      AND      ci_sequence_number                = x_ci_sequence_number;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_fund_id                           => x_fund_id,
      x_match_order                       => x_match_order,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_fseog_match_all (
      fund_id,
      match_order,
      ci_cal_type,
      ci_sequence_number,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.fund_id,
      new_references.match_order,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
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
    x_fund_id                           IN     NUMBER,
    x_match_order                       IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        match_order
      FROM  igf_aw_fseog_match_all
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
        (tlinfo.match_order = x_match_order)
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
    x_fund_id                           IN     NUMBER,
    x_match_order                       IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
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
      x_fund_id                           => x_fund_id,
      x_match_order                       => x_match_order,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_aw_fseog_match_all
      SET
        match_order                       = new_references.match_order,
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
    x_fund_id                           IN     NUMBER,
    x_match_order                       IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_fseog_match_all
      WHERE    fund_id                           = x_fund_id
      AND      ci_cal_type                       = x_ci_cal_type
      AND      ci_sequence_number                = x_ci_sequence_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_fund_id,
        x_match_order,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_fund_id,
      x_match_order,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
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

    DELETE FROM igf_aw_fseog_match_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_fseog_match_pkg;

/
