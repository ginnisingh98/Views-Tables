--------------------------------------------------------
--  DDL for Package Body IGF_AW_COA_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_COA_ITEMS_PKG" AS
/* $Header: IGFWI57B.pls 120.0 2005/06/01 13:39:34 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_coa_items%ROWTYPE;
  new_references igf_aw_coa_items%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_pell_coa_amount                   IN     NUMBER,
    x_alt_pell_amount                   IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2 ,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_lock_flag                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_aw_coa_items
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
    new_references.base_id                           := x_base_id;
    new_references.item_code                         := x_item_code;
    new_references.amount                            := x_amount;
    new_references.pell_coa_amount                   := x_pell_coa_amount;
    new_references.alt_pell_amount                   := x_alt_pell_amount;
    new_references.fixed_cost                        := x_fixed_cost;
    new_references.legacy_record_flag                := x_legacy_record_flag ;
    new_references.lock_flag                         := x_lock_flag;

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
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.base_id = new_references.base_id)) OR
        ((new_references.base_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_fa_base_rec_pkg.get_pk_for_validation (
                new_references.base_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.item_code = new_references.item_code)) OR
        ((new_references.item_code IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_item_pkg.get_pk_for_validation (
                new_references.item_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_aw_coa_itm_terms_pkg.get_fk_igf_aw_coa_items (
      old_references.base_id,
      old_references.item_code
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_coa_items
      WHERE    base_id = x_base_id
      AND      item_code = x_item_code
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


  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_coa_items
      WHERE   ((base_id = x_base_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_COAI_FABASE_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_fa_base_rec;


  PROCEDURE get_fk_igf_aw_item (
    x_item_code                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_coa_items
      WHERE   ((item_code = x_item_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_COAI_AWITEM_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_item;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_pell_coa_amount                   IN     NUMBER,
    x_alt_pell_amount                   IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
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
      x_base_id,
      x_item_code,
      x_amount,
      x_pell_coa_amount,
      x_alt_pell_amount,
      x_fixed_cost,
      x_legacy_record_flag ,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_lock_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.base_id,
             new_references.item_code
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.base_id,
             new_references.item_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_pell_coa_amount                   IN     NUMBER,
    x_alt_pell_amount                   IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_base_id                           => x_base_id,
      x_item_code                         => x_item_code,
      x_amount                            => x_amount,
      x_pell_coa_amount                   => x_pell_coa_amount,
      x_alt_pell_amount                   => x_alt_pell_amount,
      x_fixed_cost                        => x_fixed_cost,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_lock_flag                          => x_lock_flag
    );

    INSERT INTO igf_aw_coa_items (
      base_id,
      item_code,
      amount,
      pell_coa_amount,
      alt_pell_amount,
      fixed_cost,
      legacy_record_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      lock_flag
    ) VALUES (
      new_references.base_id,
      new_references.item_code,
      new_references.amount,
      new_references.pell_coa_amount,
      new_references.alt_pell_amount,
      new_references.fixed_cost,
      new_references.legacy_record_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.lock_flag
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_pell_coa_amount                   IN     NUMBER,
    x_alt_pell_amount                   IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        amount,
        pell_coa_amount,
        alt_pell_amount,
        fixed_cost,
        legacy_record_flag,
        lock_flag
      FROM  igf_aw_coa_items
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
        (tlinfo.amount = x_amount)
        AND ((tlinfo.pell_coa_amount = x_pell_coa_amount) OR ((tlinfo.pell_coa_amount IS NULL) AND (X_pell_coa_amount IS NULL)))
        AND ((tlinfo.alt_pell_amount = x_alt_pell_amount) OR ((tlinfo.alt_pell_amount IS NULL) AND (X_alt_pell_amount IS NULL)))
        AND ((tlinfo.fixed_cost = x_fixed_cost) OR ((tlinfo.fixed_cost IS NULL) AND (X_fixed_cost IS NULL)))
        AND ((tlinfo.legacy_record_flag = x_legacy_record_flag) OR ((tlinfo.legacy_record_flag IS NULL) AND (x_legacy_record_flag IS NULL)))
        AND ((tlinfo.lock_flag = x_lock_flag) OR ((tlinfo.lock_flag IS NULL) AND (x_lock_flag IS NULL)))

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
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_pell_coa_amount                   IN     NUMBER,
    x_alt_pell_amount                   IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_base_id                           => x_base_id,
      x_item_code                         => x_item_code,
      x_amount                            => x_amount,
      x_pell_coa_amount                   => x_pell_coa_amount,
      x_alt_pell_amount                   => x_alt_pell_amount,
      x_fixed_cost                        => x_fixed_cost,
      x_legacy_record_flag                => x_legacy_record_flag ,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_lock_flag                          => x_lock_flag
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igf_aw_coa_items
      SET
        amount                            = new_references.amount,
        pell_coa_amount                   = new_references.pell_coa_amount,
        alt_pell_amount                   = new_references.alt_pell_amount,
        fixed_cost                        = new_references.fixed_cost,
        legacy_record_flag                = new_references.legacy_record_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        lock_flag                          = new_references.lock_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_pell_coa_amount                   IN     NUMBER,
    x_alt_pell_amount                   IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_coa_items
      WHERE    base_id                           = x_base_id
      AND      item_code                         = x_item_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_base_id,
        x_item_code,
        x_amount,
        x_pell_coa_amount,
        x_alt_pell_amount,
        x_fixed_cost,
        x_legacy_record_flag,
        x_mode,
        x_lock_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_base_id,
      x_item_code,
      x_amount,
      x_pell_coa_amount,
      x_alt_pell_amount,
      x_fixed_cost,
      x_legacy_record_flag ,
      x_mode,
      x_lock_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
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

    DELETE FROM igf_aw_coa_items
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_coa_items_pkg;

/
