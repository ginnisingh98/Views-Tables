--------------------------------------------------------
--  DDL for Package Body IGS_EN_REP_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_REP_PROCESS_PKG" AS
/* $Header: IGSEI60B.pls 115.5 2002/11/28 23:47:01 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_rep_process%ROWTYPE;
  new_references igs_en_rep_process%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_repeat_process_id                 IN     NUMBER      DEFAULT NULL,
    x_org_unit_id                       IN     NUMBER      DEFAULT NULL,
    x_include_adv_standing_units        IN     VARCHAR2    DEFAULT NULL,
    x_max_repeats_for_credit            IN     NUMBER      DEFAULT NULL,
    x_max_repeats_for_funding           IN     NUMBER      DEFAULT NULL,
    x_use_most_recent_unit_attempt      IN     VARCHAR2    DEFAULT NULL,
    x_use_best_grade_attempt            IN     VARCHAR2    DEFAULT NULL,
    x_external_formula                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_REP_PROCESS
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
    new_references.repeat_process_id                 := x_repeat_process_id;
    new_references.org_unit_id                       := x_org_unit_id;
    new_references.include_adv_standing_units        := x_include_adv_standing_units;
    new_references.max_repeats_for_credit            := x_max_repeats_for_credit;
    new_references.max_repeats_for_funding           := x_max_repeats_for_funding;
    new_references.use_most_recent_unit_attempt      := x_use_most_recent_unit_attempt;
    new_references.use_best_grade_attempt            := x_use_best_grade_attempt;
    new_references.external_formula                  := x_external_formula;

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
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.org_unit_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_igs_pe_hz_party IS
    SELECT rowid
    FROM igs_pe_hz_parties
    WHERE party_id = new_references.org_unit_id ;

    pehz_rowid  varchar2(25);

  BEGIN

    IF (((old_references.org_unit_id = new_references.org_unit_id)) OR
        ((new_references.org_unit_id IS NULL))) THEN
      NULL;
    ELSE
       OPEN  cur_igs_pe_hz_party;
       FETCH  cur_igs_pe_hz_party  INTO pehz_rowid ;
       IF cur_igs_pe_hz_party%NOTFOUND THEN
          CLOSE cur_igs_pe_hz_party;
          fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
       END IF;
       CLOSE cur_igs_pe_hz_party;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_repeat_process_id                 IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_rep_process
      WHERE    repeat_process_id = x_repeat_process_id
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
    x_org_unit_id                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant       22MAY2002       Bug#2383216. Left parenthesis and right parenthesis was
  ||                                  missing in the where clause of the cursor.
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_rep_process
      WHERE    ((org_unit_id = x_org_unit_id)  -- The extreme left parenthesis was missing earlier, Added by Nishikant, Bug#2383216
               OR ( org_unit_id IS NULL  AND  x_org_unit_id IS NULL))  -- The extreme right parenthesis was missing earlier, Added by Nishikant, Bug#2383216
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));
      -- also check if the null record (i.e record with organization unit cd as null) exists.
      -- only one record with org_unit_id NULL should exist

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
    x_repeat_process_id                 IN     NUMBER      DEFAULT NULL,
    x_org_unit_id                       IN     NUMBER      DEFAULT NULL,
    x_include_adv_standing_units        IN     VARCHAR2    DEFAULT NULL,
    x_max_repeats_for_credit            IN     NUMBER      DEFAULT NULL,
    x_max_repeats_for_funding           IN     NUMBER      DEFAULT NULL,
    x_use_most_recent_unit_attempt      IN     VARCHAR2    DEFAULT NULL,
    x_use_best_grade_attempt            IN     VARCHAR2    DEFAULT NULL,
    x_external_formula                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
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
      x_repeat_process_id,
      x_org_unit_id,
      x_include_adv_standing_units,
      x_max_repeats_for_credit,
      x_max_repeats_for_funding,
      x_use_most_recent_unit_attempt,
      x_use_best_grade_attempt,
      x_external_formula,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.repeat_process_id
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.repeat_process_id
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
    x_repeat_process_id                 IN OUT NOCOPY NUMBER,
    x_org_unit_id                       IN     NUMBER,
    x_include_adv_standing_units        IN     VARCHAR2,
    x_max_repeats_for_credit            IN     NUMBER,
    x_max_repeats_for_funding           IN     NUMBER,
    x_use_most_recent_unit_attempt      IN     VARCHAR2,
    x_use_best_grade_attempt            IN     VARCHAR2,
    x_external_formula                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_en_rep_process
      WHERE    repeat_process_id                 = x_repeat_process_id;

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

    SELECT    igs_en_rep_process_s.NEXTVAL
    INTO      x_repeat_process_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_repeat_process_id                 => x_repeat_process_id,
      x_org_unit_id                       => x_org_unit_id,
      x_include_adv_standing_units        => x_include_adv_standing_units,
      x_max_repeats_for_credit            => x_max_repeats_for_credit,
      x_max_repeats_for_funding           => x_max_repeats_for_funding,
      x_use_most_recent_unit_attempt      => x_use_most_recent_unit_attempt,
      x_use_best_grade_attempt            => x_use_best_grade_attempt,
      x_external_formula                  => x_external_formula,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_rep_process (
      repeat_process_id,
      org_unit_id,
      include_adv_standing_units,
      max_repeats_for_credit,
      max_repeats_for_funding,
      use_most_recent_unit_attempt,
      use_best_grade_attempt,
      external_formula,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.repeat_process_id,
      new_references.org_unit_id,
      new_references.include_adv_standing_units,
      new_references.max_repeats_for_credit,
      new_references.max_repeats_for_funding,
      new_references.use_most_recent_unit_attempt,
      new_references.use_best_grade_attempt,
      new_references.external_formula,
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
    x_repeat_process_id                 IN     NUMBER,
    x_org_unit_id                       IN     NUMBER,
    x_include_adv_standing_units        IN     VARCHAR2,
    x_max_repeats_for_credit            IN     NUMBER,
    x_max_repeats_for_funding           IN     NUMBER,
    x_use_most_recent_unit_attempt      IN     VARCHAR2,
    x_use_best_grade_attempt            IN     VARCHAR2,
    x_external_formula                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        org_unit_id,
        include_adv_standing_units,
        max_repeats_for_credit,
        max_repeats_for_funding,
        use_most_recent_unit_attempt,
        use_best_grade_attempt,
        external_formula
      FROM  igs_en_rep_process
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
        ((tlinfo.org_unit_id = x_org_unit_id) OR ((tlinfo.org_unit_id IS NULL) AND (X_org_unit_id IS NULL)))
        AND (tlinfo.include_adv_standing_units = x_include_adv_standing_units)
        AND ((tlinfo.max_repeats_for_credit = x_max_repeats_for_credit) OR ((tlinfo.max_repeats_for_credit IS NULL) AND (X_max_repeats_for_credit IS NULL)))
        AND ((tlinfo.max_repeats_for_funding = x_max_repeats_for_funding) OR ((tlinfo.max_repeats_for_funding IS NULL) AND (X_max_repeats_for_funding IS NULL)))
        AND (tlinfo.use_most_recent_unit_attempt = x_use_most_recent_unit_attempt)
        AND (tlinfo.use_best_grade_attempt = x_use_best_grade_attempt)
        AND (tlinfo.external_formula = x_external_formula)
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
    x_repeat_process_id                 IN     NUMBER,
    x_org_unit_id                       IN     NUMBER,
    x_include_adv_standing_units        IN     VARCHAR2,
    x_max_repeats_for_credit            IN     NUMBER,
    x_max_repeats_for_funding           IN     NUMBER,
    x_use_most_recent_unit_attempt      IN     VARCHAR2,
    x_use_best_grade_attempt            IN     VARCHAR2,
    x_external_formula                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
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
      x_repeat_process_id                 => x_repeat_process_id,
      x_org_unit_id                       => x_org_unit_id,
      x_include_adv_standing_units        => x_include_adv_standing_units,
      x_max_repeats_for_credit            => x_max_repeats_for_credit,
      x_max_repeats_for_funding           => x_max_repeats_for_funding,
      x_use_most_recent_unit_attempt      => x_use_most_recent_unit_attempt,
      x_use_best_grade_attempt            => x_use_best_grade_attempt,
      x_external_formula                  => x_external_formula,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_rep_process
      SET
        org_unit_id                       = new_references.org_unit_id,
        include_adv_standing_units        = new_references.include_adv_standing_units,
        max_repeats_for_credit            = new_references.max_repeats_for_credit,
        max_repeats_for_funding           = new_references.max_repeats_for_funding,
        use_most_recent_unit_attempt      = new_references.use_most_recent_unit_attempt,
        use_best_grade_attempt            = new_references.use_best_grade_attempt,
        external_formula                  = new_references.external_formula,
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
    x_repeat_process_id                 IN OUT NOCOPY NUMBER,
    x_org_unit_id                       IN     NUMBER,
    x_include_adv_standing_units        IN     VARCHAR2,
    x_max_repeats_for_credit            IN     NUMBER,
    x_max_repeats_for_funding           IN     NUMBER,
    x_use_most_recent_unit_attempt      IN     VARCHAR2,
    x_use_best_grade_attempt            IN     VARCHAR2,
    x_external_formula                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_rep_process
      WHERE    repeat_process_id                 = x_repeat_process_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_repeat_process_id,
        x_org_unit_id,
        x_include_adv_standing_units,
        x_max_repeats_for_credit,
        x_max_repeats_for_funding,
        x_use_most_recent_unit_attempt,
        x_use_best_grade_attempt,
        x_external_formula,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_repeat_process_id,
      x_org_unit_id,
      x_include_adv_standing_units,
      x_max_repeats_for_credit,
      x_max_repeats_for_funding,
      x_use_most_recent_unit_attempt,
      x_use_best_grade_attempt,
      x_external_formula,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 22-NOV-2001
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

    DELETE FROM igs_en_rep_process
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_rep_process_pkg;

/
