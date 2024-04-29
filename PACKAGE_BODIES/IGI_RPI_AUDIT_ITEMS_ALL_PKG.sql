--------------------------------------------------------
--  DDL for Package Body IGI_RPI_AUDIT_ITEMS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_RPI_AUDIT_ITEMS_ALL_PKG" AS
/* $Header: igiraiab.pls 120.4.12000000.1 2007/08/31 05:52:29 mbremkum noship $ */

  l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;

  l_rowid VARCHAR2(25);
  old_references igi_rpi_audit_items_all%ROWTYPE;
  new_references igi_rpi_audit_items_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_effective_date            IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER ) AS
  /*
  ||  Created By : panaraya
  ||  Created On : 06-MAR-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGI_RPI_AUDIT_ITEMS_ALL
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

      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_audit_items_all_pkg.set_column_values.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.item_id                           := x_item_id;
    new_references.price                             := x_price;
    new_references.effective_date                    := x_effective_date;
    new_references.revised_effective_date            := x_revised_effective_date;
    new_references.revised_price                     := x_revised_price;
    new_references.run_id                            := x_run_id;
    new_references.org_id                            := x_org_id;

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


  PROCEDURE check_parent_existance(x_item_id in number) AS
  /*
  ||  Created By : panaraya
  ||  Created On : 06-MAR-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR c is select 'X' from igi_rpi_items_all where item_id=x_item_id;

 l c%rowtype;
  BEGIN
    open c;
    fetch c into l;

    IF (((old_references.item_id = new_references.item_id)) OR
        ((new_references.item_id IS NULL))) THEN
      NULL;
    ELSIF c%NOTFOUND
              THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');

      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_audit_items_all_pkg.check_parent_existence.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;



  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_effective_date            IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER ) AS
  /*
  ||  Created By : panaraya
  ||  Created On : 06-MAR-2002
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
      x_item_id,
      x_price,
      x_effective_date,
      x_revised_effective_date,
      x_revised_price,
      x_run_id,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      check_parent_existance(x_item_id);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance(x_item_id);
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	null;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_effective_date            IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : panaraya
  ||  Created On : 06-MAR-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_rpi_audit_items_all
      WHERE    item_id=x_item_id and run_id=x_run_id;

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

      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_audit_items_all_pkg.insert_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_item_id                           => x_item_id,
      x_price                             => x_price,
      x_effective_date                    => x_effective_date,
      x_revised_effective_date            => x_revised_effective_date,
      x_revised_price                     => x_revised_price,
      x_run_id                            => x_run_id,
      x_org_id                            => NVL (x_org_id,0),
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );
    INSERT INTO igi_rpi_audit_items_all (
      item_id,
      price,
      effective_date,
      revised_effective_date,
      revised_price,
      run_id,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.item_id,
      new_references.price,
      new_references.effective_date,
      new_references.revised_effective_date,
      new_references.revised_price,
      new_references.run_id,
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
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_effective_date            IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : panaraya
  ||  Created On : 06-MAR-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        item_id,
        price,
        effective_date,
        revised_effective_date,
        revised_price,
        run_id,
        org_id
      FROM  igi_rpi_audit_items_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');

      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_audit_items_all_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
null;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.item_id = x_item_id)
        AND (tlinfo.price = x_price)
        AND (tlinfo.effective_date = x_effective_date)
        AND ((tlinfo.revised_effective_date = x_revised_effective_date) OR ((tlinfo.revised_effective_date IS NULL) AND (X_revised_effective_date IS NULL)))
        AND ((tlinfo.revised_price = x_revised_price) OR ((tlinfo.revised_price IS NULL) AND (X_revised_price IS NULL)))
        AND ((tlinfo.run_id = x_run_id) OR ((tlinfo.run_id IS NULL) AND (X_run_id IS NULL)))
        AND ((tlinfo.org_id = x_org_id) OR ((tlinfo.org_id IS NULL) AND (X_org_id IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');

      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_audit_items_all_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (end)
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_effective_date            IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : panaraya
  ||  Created On : 06-MAR-2002
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

      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_audit_items_all_pkg.update_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_item_id                           => x_item_id,
      x_price                             => x_price,
      x_effective_date                    => x_effective_date,
      x_revised_effective_date            => x_revised_effective_date,
      x_revised_price                     => x_revised_price,
      x_run_id                            => x_run_id,
      x_org_id                            => NVL (x_org_id,0),
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_rpi_audit_items_all
      SET
        item_id                           = new_references.item_id,
        price                             = new_references.price,
        effective_date                    = new_references.effective_date,
        revised_effective_date            = new_references.revised_effective_date,
        revised_price                     = new_references.revised_price,
        run_id                            = new_references.run_id,
        org_id                            = new_references.org_id,
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
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_effective_date            IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : panaraya
  ||  Created On : 06-MAR-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_rpi_audit_items_all
      WHERE    item_id=x_item_id and run_id=x_run_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_item_id,
        x_price,
        x_effective_date,
        x_revised_effective_date,
        x_revised_price,
        x_run_id,
        x_org_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_item_id,
      x_price,
      x_effective_date,
      x_revised_effective_date,
      x_revised_price,
      x_run_id,
      x_org_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : panaraya
  ||  Created On : 06-MAR-2002
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

    DELETE FROM igi_rpi_audit_items_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_rpi_audit_items_all_pkg;

/
