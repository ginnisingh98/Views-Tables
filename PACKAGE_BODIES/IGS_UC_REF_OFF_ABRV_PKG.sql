--------------------------------------------------------
--  DDL for Package Body IGS_UC_REF_OFF_ABRV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_REF_OFF_ABRV_PKG" AS
/* $Header: IGSXI30B.pls 120.1 2005/07/31 20:35:43 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_ref_off_abrv%ROWTYPE;
  new_references igs_uc_ref_off_abrv%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_abbrev_code                       IN     VARCHAR2,
    x_uv_updater                        IN     VARCHAR2,
    x_abbrev_text                       IN     VARCHAR2,
    x_letter_format                     IN     VARCHAR2,
    x_summary_char                      IN     VARCHAR2,
    x_uncond                            IN     VARCHAR2,
    x_withdrawal                        IN     VARCHAR2,
    x_release                           IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)

  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_REF_OFF_ABRV
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
    new_references.abbrev_code                       := x_abbrev_code;
    new_references.uv_updater                        := x_uv_updater;
    new_references.abbrev_text                       := x_abbrev_text;
    new_references.letter_format                     := x_letter_format;
    new_references.summary_char                      := x_summary_char;
    new_references.uncond                            := x_uncond;
    new_references.withdrawal                        := x_withdrawal;
    new_references.release                           := x_release;
    new_references.imported                          := x_imported;
    new_references.sent_to_ucas                      := x_sent_to_ucas;
    new_references.deleted                           := x_deleted;
    new_references.tariff                            := x_tariff;

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

  PROCEDURE check_child_existance IS
  /*
  ||  Created By : rbezawad
  ||  Created On : 17-DEC-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_uc_cond_details_pkg.get_fk_igs_uc_ref_off_abrv (
      old_references.abbrev_code
    );

  END check_child_existance;

  FUNCTION get_pk_for_validation (
    x_abbrev_code                       IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_ref_off_abrv
      WHERE    abbrev_code = x_abbrev_code ;

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
    x_abbrev_code                       IN     VARCHAR2,
    x_uv_updater                        IN     VARCHAR2,
    x_abbrev_text                       IN     VARCHAR2,
    x_letter_format                     IN     VARCHAR2,
    x_summary_char                      IN     VARCHAR2,
    x_uncond                            IN     VARCHAR2,
    x_withdrawal                        IN     VARCHAR2,
    x_release                           IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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
      x_abbrev_code,
      x_uv_updater,
      x_abbrev_text,
      x_letter_format,
      x_summary_char,
      x_uncond,
      x_withdrawal,
      x_release,
      x_imported,
      x_sent_to_ucas,
      x_deleted,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_tariff
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.abbrev_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.abbrev_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_abbrev_code                       IN     VARCHAR2,
    x_uv_updater                        IN     VARCHAR2,
    x_abbrev_text                       IN     VARCHAR2,
    x_letter_format                     IN     VARCHAR2,
    x_summary_char                      IN     VARCHAR2 ,
    x_uncond                            IN     VARCHAR2,
    x_withdrawal                        IN     VARCHAR2,
    x_release                           IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||   svenkata 16-Jul-2002  Modified logic added as part of 2335790 bug as NVL(summary_char, 'N') for bug# 2451774
  ||   smaddali 30-apr-2002 added NVL(summary_char, ' ') in insert dml for bug# 2335790
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_ref_off_abrv
      WHERE    abbrev_code                       = x_abbrev_code;

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

/*    SELECT    igs_uc_ref_off_abrv_s.NEXTVAL
    INTO      x_abbrev_code
    FROM      dual;
*/
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_abbrev_code                       => x_abbrev_code,
      x_uv_updater                        => x_uv_updater,
      x_abbrev_text                       => x_abbrev_text,
      x_letter_format                     => x_letter_format,
      x_summary_char                      => x_summary_char,
      x_uncond                            => x_uncond,
      x_withdrawal                        => x_withdrawal,
      x_release                           => x_release,
      x_imported                          => x_imported,
      x_sent_to_ucas                      => x_sent_to_ucas,
      x_deleted                           => x_deleted,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_tariff                            => x_tariff
    );

    INSERT INTO igs_uc_ref_off_abrv (
      abbrev_code,
      uv_updater,
      abbrev_text,
      letter_format,
      summary_char,
      uncond,
      withdrawal,
      release,
      imported,
      sent_to_ucas,
      deleted,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      tariff
    ) VALUES (
      new_references.abbrev_code,
      new_references.uv_updater,
      new_references.abbrev_text,
      new_references.letter_format,
      NVL(new_references.summary_char,'N'),
      new_references.uncond,
      new_references.withdrawal,
      new_references.release,
      new_references.imported,
      new_references.sent_to_ucas,
      new_references.deleted,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.tariff
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
    x_abbrev_code                       IN     VARCHAR2,
    x_uv_updater                        IN     VARCHAR2,
    x_abbrev_text                       IN     VARCHAR2,
    x_letter_format                     IN     VARCHAR2,
    x_summary_char                      IN     VARCHAR2 ,
    x_uncond                            IN     VARCHAR2,
    x_withdrawal                        IN     VARCHAR2,
    x_release                           IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || svenkata 16-Jul-2002 Removed added NVL(,' ') for summary_char field for bug# 2451774
  || smaddali added NVL(,' ') for summary_char field for bug# 2335790
  || Nishikant     18SEP2002      summary_char column made as NULLable from NOT NULL. Enh Bug#2574566.
  */
    CURSOR c1 IS
      SELECT
        uv_updater,
        abbrev_text,
        letter_format,
        summary_char,
        uncond,
        withdrawal,
        release,
        imported,
        sent_to_ucas,
        deleted,
        tariff
      FROM  igs_uc_ref_off_abrv
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
        ((tlinfo.uv_updater = x_uv_updater) OR ((tlinfo.uv_updater IS NULL) AND (X_uv_updater IS NULL)))
        AND ((tlinfo.abbrev_text = x_abbrev_text) OR ((tlinfo.abbrev_text IS NULL) AND (X_abbrev_text IS NULL)))
        AND ((tlinfo.letter_format = x_letter_format) OR ((tlinfo.letter_format IS NULL) AND (x_letter_format IS NULL)))
    -- The below condition is modified since the summary_char column is modified from NOT NULL to NULLable. Enh Bug#2574566.
        AND ((tlinfo.summary_char = x_summary_char) OR ((tlinfo.summary_char IS NULL) AND (x_summary_char IS NULL)))
        AND (tlinfo.uncond = x_uncond)
        AND (tlinfo.withdrawal = x_withdrawal)
        AND (tlinfo.release = x_release)
        AND (tlinfo.imported = x_imported)
        AND (tlinfo.sent_to_ucas = x_sent_to_ucas)
        AND (tlinfo.deleted = x_deleted)
        AND ((tlinfo.tariff = x_tariff) OR ((tlinfo.tariff IS NULL) AND (x_tariff IS NULL)))
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
    x_abbrev_code                       IN     VARCHAR2,
    x_uv_updater                        IN     VARCHAR2,
    x_abbrev_text                       IN     VARCHAR2,
    x_letter_format                     IN     VARCHAR2,
    x_summary_char                      IN     VARCHAR2 ,
    x_uncond                            IN     VARCHAR2,
    x_withdrawal                        IN     VARCHAR2,
    x_release                           IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || svenkata 16-Jul-2002 Modified logic added as part of 2335790 bug as NVL(summary_char, 'N') for bug# 2451774
  || smaddali  30-apr-2002 added NVL(, ' ' ) for column summary_char for bug#2335790
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
      x_abbrev_code                       => x_abbrev_code,
      x_uv_updater                        => x_uv_updater,
      x_abbrev_text                       => x_abbrev_text,
      x_letter_format                     => x_letter_format,
      x_summary_char                      => x_summary_char,
      x_uncond                            => x_uncond,
      x_withdrawal                        => x_withdrawal,
      x_release                           => x_release,
      x_imported                          => x_imported,
      x_sent_to_ucas                      => x_sent_to_ucas,
      x_deleted                           => x_deleted,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_tariff                            => x_tariff
    );

    UPDATE igs_uc_ref_off_abrv
      SET
        uv_updater                        = new_references.uv_updater,
        abbrev_text                       = new_references.abbrev_text,
        letter_format                     = new_references.letter_format,
        summary_char                      = NVL(new_references.summary_char,'N'),
        uncond                            = new_references.uncond,
        withdrawal                        = new_references.withdrawal,
        release                           = new_references.release,
        imported                          = new_references.imported,
        sent_to_ucas                      = new_references.sent_to_ucas,
        deleted                           = new_references.deleted,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        tariff                            = new_references.tariff
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_abbrev_code                       IN     VARCHAR2,
    x_uv_updater                        IN     VARCHAR2,
    x_abbrev_text                       IN     VARCHAR2,
    x_letter_format                     IN     VARCHAR2,
    x_summary_char                      IN     VARCHAR2 ,
    x_uncond                            IN     VARCHAR2,
    x_withdrawal                        IN     VARCHAR2,
    x_release                           IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)

  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_ref_off_abrv
      WHERE    abbrev_code                       = x_abbrev_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_abbrev_code,
        x_uv_updater,
        x_abbrev_text,
        x_letter_format,
        x_summary_char,
        x_uncond,
        x_withdrawal,
        x_release,
        x_imported,
        x_sent_to_ucas,
        x_deleted,
        x_mode,
        x_tariff
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_abbrev_code,
      x_uv_updater,
      x_abbrev_text,
      x_letter_format,
      x_summary_char,
      x_uncond,
      x_withdrawal,
      x_release,
      x_imported,
      x_sent_to_ucas,
      x_deleted,
      x_mode,
      x_tariff
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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

    DELETE FROM igs_uc_ref_off_abrv
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_ref_off_abrv_pkg;

/
