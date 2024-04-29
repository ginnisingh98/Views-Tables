--------------------------------------------------------
--  DDL for Package Body GMD_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_PARAMETERS_PKG" AS
/* $Header: GMDPARMB.pls 120.1 2005/06/02 23:10:01 appldev  $ */

  l_rowid VARCHAR2(25);
  old_references gmd_parameters%ROWTYPE;
  new_references gmd_parameters%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_parameter_id                      IN     NUMBER,
    x_orgn_code                         IN     VARCHAR2,
    x_recipe_status                     IN     VARCHAR2,
    x_validity_rule_status              IN     VARCHAR2,
    x_formula_status                    IN     VARCHAR2,
    x_routing_status                    IN     VARCHAR2,
    x_operation_status                  IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-JAN-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     gmd_parameters
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
      FND_MSG_PUB.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.parameter_id                      := x_parameter_id;
    new_references.orgn_code                         := x_orgn_code;
    new_references.recipe_status                     := x_recipe_status;
    new_references.validity_rule_status              := x_validity_rule_status;
    new_references.formula_status                    := x_formula_status;
    new_references.routing_status                    := x_routing_status;
    new_references.operation_status                  := x_operation_status;

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


  FUNCTION get_pk_for_validation (
    x_parameter_id                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 19-JAN-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     gmd_parameters
      WHERE    parameter_id = x_parameter_id
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
    x_parameter_id                      IN     NUMBER,
    x_orgn_code                         IN     VARCHAR2,
    x_recipe_status                     IN     VARCHAR2,
    x_validity_rule_status              IN     VARCHAR2,
    x_formula_status                    IN     VARCHAR2,
    x_routing_status                    IN     VARCHAR2,
    x_operation_status                  IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-JAN-2004
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
      x_parameter_id,
      x_orgn_code,
      x_recipe_status,
      x_validity_rule_status,
      x_formula_status,
      x_routing_status,
      x_operation_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.parameter_id
           )
         ) THEN
        fnd_message.set_name('GMD','LM_RECORD_EXISTS');
        fnd_msg_pub.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.parameter_id
           )
         ) THEN
        fnd_message.set_name('GMD','LM_RECORD_EXISTS');
        fnd_msg_pub.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_parameter_id                      IN OUT NOCOPY NUMBER,
    x_orgn_code                         IN     VARCHAR2,
    x_recipe_status                     IN     VARCHAR2,
    x_validity_rule_status              IN     VARCHAR2,
    x_formula_status                    IN     VARCHAR2,
    x_routing_status                    IN     VARCHAR2,
    x_operation_status                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-JAN-2004
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
      FND_MSG_PUB.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_parameter_id                      => x_parameter_id,
      x_orgn_code                         => x_orgn_code,
      x_recipe_status                     => x_recipe_status,
      x_validity_rule_status              => x_validity_rule_status,
      x_formula_status                    => x_formula_status,
      x_routing_status                    => x_routing_status,
      x_operation_status                  => x_operation_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );
    INSERT INTO gmd_parameters (
      parameter_id,
      orgn_code,
      recipe_status,
      validity_rule_status,
      formula_status,
      routing_status,
      operation_status,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      GMD_parameter_id_s.NEXTVAL,
      new_references.orgn_code,
      new_references.recipe_status,
      new_references.validity_rule_status,
      new_references.formula_status,
      new_references.routing_status,
      new_references.operation_status,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, parameter_id INTO x_rowid, x_parameter_id;
  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_parameter_id                      IN     NUMBER,
    x_orgn_code                         IN     VARCHAR2,
    x_recipe_status                     IN     VARCHAR2,
    x_validity_rule_status              IN     VARCHAR2,
    x_formula_status                    IN     VARCHAR2,
    x_routing_status                    IN     VARCHAR2,
    x_operation_status                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-JAN-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        orgn_code,
        recipe_status,
        validity_rule_status,
        formula_status,
        routing_status,
        operation_status
      FROM  gmd_parameters
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      FND_MSG_PUB.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        ((tlinfo.orgn_code = x_orgn_code) OR ((tlinfo.orgn_code IS NULL) AND (X_orgn_code IS NULL)))
        AND ((tlinfo.recipe_status = x_recipe_status) OR ((tlinfo.recipe_status IS NULL) AND (X_recipe_status IS NULL)))
        AND ((tlinfo.validity_rule_status = x_validity_rule_status) OR ((tlinfo.validity_rule_status IS NULL) AND (X_validity_rule_status IS NULL)))
        AND ((tlinfo.formula_status = x_formula_status) OR ((tlinfo.formula_status IS NULL) AND (X_formula_status IS NULL)))
        AND ((tlinfo.routing_status = x_routing_status) OR ((tlinfo.routing_status IS NULL) AND (X_routing_status IS NULL)))
        AND ((tlinfo.operation_status = x_operation_status) OR ((tlinfo.operation_status IS NULL) AND (X_operation_status IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      FND_MSG_PUB.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_parameter_id                      IN     NUMBER,
    x_orgn_code                         IN     VARCHAR2,
    x_recipe_status                     IN     VARCHAR2,
    x_validity_rule_status              IN     VARCHAR2,
    x_formula_status                    IN     VARCHAR2,
    x_routing_status                    IN     VARCHAR2,
    x_operation_status                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-JAN-2004
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
      FND_MSG_PUB.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_parameter_id                      => x_parameter_id,
      x_orgn_code                         => x_orgn_code,
      x_recipe_status                     => x_recipe_status,
      x_validity_rule_status              => x_validity_rule_status,
      x_formula_status                    => x_formula_status,
      x_routing_status                    => x_routing_status,
      x_operation_status                  => x_operation_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE gmd_parameters
      SET
        orgn_code                         = new_references.orgn_code,
        recipe_status                     = new_references.recipe_status,
        validity_rule_status              = new_references.validity_rule_status,
        formula_status                    = new_references.formula_status,
        routing_status                    = new_references.routing_status,
        operation_status                  = new_references.operation_status,
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
    x_parameter_id                      IN OUT NOCOPY NUMBER,
    x_orgn_code                         IN     VARCHAR2,
    x_recipe_status                     IN     VARCHAR2,
    x_validity_rule_status              IN     VARCHAR2,
    x_formula_status                    IN     VARCHAR2,
    x_routing_status                    IN     VARCHAR2,
    x_operation_status                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-JAN-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     gmd_parameters
      WHERE    parameter_id                      = x_parameter_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_parameter_id,
        x_orgn_code,
        x_recipe_status,
        x_validity_rule_status,
        x_formula_status,
        x_routing_status,
        x_operation_status,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_parameter_id,
      x_orgn_code,
      x_recipe_status,
      x_validity_rule_status,
      x_formula_status,
      x_routing_status,
      x_operation_status,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-JAN-2004
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

    DELETE FROM gmd_parameters
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END gmd_parameters_pkg;

/
