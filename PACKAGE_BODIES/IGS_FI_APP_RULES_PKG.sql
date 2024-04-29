--------------------------------------------------------
--  DDL for Package Body IGS_FI_APP_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_APP_RULES_PKG" AS
/* $Header: IGSSI90B.pls 120.4 2005/10/10 23:19:28 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_app_rules%ROWTYPE;
  new_references igs_fi_app_rules%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_rule_id                      IN     NUMBER      DEFAULT NULL,
    x_appl_hierarchy_id                 IN     NUMBER      DEFAULT NULL,
    x_rule_sequence                     IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_rule_type                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_APP_RULES
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
    new_references.appl_rule_id                      := x_appl_rule_id;
    new_references.appl_hierarchy_id                 := x_appl_hierarchy_id;
    new_references.rule_sequence                     := x_rule_sequence;
    new_references.fee_type                          := x_fee_type;
    new_references.enabled_flag                      := x_enabled_flag;
    new_references.rule_type                         := x_rule_type;


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

  PROCEDURE chk_unique_fee(x_appl_hierarchy_id      IN NUMBER,
                           x_rule_type              IN VARCHAR2,
	                   x_fee_type               IN VARCHAR2,
			   x_enabled_flag           IN VARCHAR2) AS
  /*
  ||  Created By : AGAIROLA
  ||  Created On : 10-Oct-2005
  ||  Purpose : Checks for Uniqueness of Fee Type and Rule Type.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_app(cp_appl_hier_id                 IN NUMBER,
                   cp_rule_type                    IN VARCHAR2,
		   cp_fee_type                     IN VARCHAR2) IS
      SELECT 'x'
      FROM   igs_fi_app_rules
      WHERE  appl_hierarchy_id = cp_appl_hier_id
      AND    rule_type         = cp_rule_type
      AND    fee_type          = cp_fee_type
      AND    enabled_flag      = 'Y';

    l_v_var    VARCHAR2(1);
    l_b_bool   BOOLEAN;
  BEGIN
    l_b_bool := FALSE;
    IF x_enabled_flag = 'Y' THEN
      IF x_rule_type = 'ADDITION' THEN
        OPEN cur_app(x_appl_hierarchy_id,
                     'ALLOW',
	             x_fee_type);
        FETCH cur_app INTO l_v_var;
        IF cur_app%FOUND THEN
          l_b_bool := TRUE;
        END IF;
        CLOSE cur_app;
      ELSE
        OPEN cur_app(x_appl_hierarchy_id,
                     'ADDITION',
	             x_fee_type);
        FETCH cur_app INTO l_v_var;
        IF cur_app%FOUND THEN
          l_b_bool := TRUE;
        END IF;
        CLOSE cur_app;
      END IF;
    END IF;

    IF l_b_bool THEN
      fnd_message.set_name ( 'IGS', 'IGS_FI_AHR_FTYP_CANT_ENABLE' );
      fnd_message.set_token('FEE_TYPE',x_fee_type);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END chk_unique_fee;

  FUNCTION unique_rule_seq (
    x_appl_hierarchy_id                      IN     NUMBER,
    x_rule_type                              IN     VARCHAR2,
    x_rule_sequence                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : JBEGUM
  ||  Created On : 8-FEB-2002
  ||  Purpose : Added as part of Enh bug#2191470 .This function ensures unique rule sequence number across
  ||            the two tab pages of the application Hierarchy form
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     30-dec-2002    Bug#2725955.Modified cursor cur_rule to add check for rowid also.
  */
    CURSOR cur_rule IS
      SELECT   rowid
      FROM     igs_fi_app_rules
      WHERE    appl_hierarchy_id = x_appl_hierarchy_id
      AND      rule_type = x_rule_type
      AND      rule_sequence = x_rule_sequence
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    l_rule cur_rule%ROWTYPE;

  BEGIN

    OPEN cur_rule;
    FETCH cur_rule INTO l_rule;
    IF (cur_rule%FOUND) THEN
        CLOSE cur_rule;
        RETURN (TRUE);
    ELSE
       CLOSE cur_rule;
       RETURN(FALSE);
    END IF;

  END unique_rule_seq;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  jbegum          8-Feb-02        Added call to local function unique_rule_seq
  ||                                  As part of Enh Bug # 2191470
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.appl_hierarchy_id,
           new_references.fee_type,
           new_references.rule_type
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

    END IF;

    IF ( unique_rule_seq (new_references.appl_hierarchy_id,
                          new_references.rule_type,
	                  new_references.rule_sequence
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_FI_UNQ_RULE_SEQ');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.appl_hierarchy_id = new_references.appl_hierarchy_id)) OR
        ((new_references.appl_hierarchy_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_a_hierarchies_pkg.get_pk_for_validation (
                new_references.appl_hierarchy_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.rule_type = new_references.rule_type)) OR
        ((new_references.rule_type IS NULL))) THEN
      NULL;
    ELSE
	IF  NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
	  'IGS_FI_RULE_TYPE',
           new_references.rule_type
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_appl_rule_id                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_app_rules
      WHERE    appl_rule_id = x_appl_rule_id
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
    x_appl_hierarchy_id                      IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_rule_type                         IN   VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  agairola        06-Oct-2005     For bug 4212082
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_app_rules
      WHERE    appl_hierarchy_id = x_appl_hierarchy_id
      AND      fee_type = x_fee_type
      AND      rule_type = x_rule_type
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

  PROCEDURE get_fk_igs_fi_a_hierarchies (
    x_appl_hierarchy_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_app_rules
      WHERE   ((appl_hierarchy_id = x_appl_hierarchy_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_HRRL_APHR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_a_hierarchies;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_rule_id                      IN     NUMBER      DEFAULT NULL,
    x_appl_hierarchy_id                 IN     NUMBER      DEFAULT NULL,
    x_rule_sequence                     IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_rule_type                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||   smadathi    18-FEB-2003     Bug 2473845. Added logic to re initialize l_rowid to null.
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_appl_rule_id,
      x_appl_hierarchy_id,
      x_rule_sequence,
      x_fee_type,
      x_enabled_flag,
      x_rule_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.appl_rule_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
      chk_unique_fee(x_appl_hierarchy_id,
                     x_rule_type,
		     x_fee_type,
		     x_enabled_flag);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
      chk_unique_fee(x_appl_hierarchy_id,
                     x_rule_type,
		     x_fee_type,
		     x_enabled_flag);
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.appl_rule_id
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
    l_rowid := NULL;
  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_rule_id                      IN OUT NOCOPY NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_rule_sequence                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_rule_type				IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_app_rules
      WHERE    appl_rule_id                      = x_appl_rule_id;

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

    SELECT    igs_fi_app_rules_s.NEXTVAL
    INTO      x_appl_rule_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_appl_rule_id                      => x_appl_rule_id,
      x_appl_hierarchy_id                 => x_appl_hierarchy_id,
      x_rule_sequence                     => x_rule_sequence,
      x_fee_type                          => x_fee_type,
      x_enabled_flag                      => x_enabled_flag,
      x_rule_type                         => x_rule_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_app_rules (
      appl_rule_id,
      appl_hierarchy_id,
      rule_sequence,
      fee_type,
      enabled_flag,
      rule_type,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.appl_rule_id,
      new_references.appl_hierarchy_id,
      new_references.rule_sequence,
      new_references.fee_type,
      new_references.enabled_flag,
      new_references.rule_type,
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
    x_appl_rule_id                      IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_rule_sequence                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_rule_type				IN     VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        appl_hierarchy_id,
        rule_sequence,
        fee_type,
        enabled_flag,
	rule_type
      FROM  igs_fi_app_rules
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
        (tlinfo.appl_hierarchy_id = x_appl_hierarchy_id)
        AND (tlinfo.rule_sequence = x_rule_sequence)
        AND (tlinfo.fee_type = x_fee_type)
        AND (tlinfo.enabled_flag = x_enabled_flag)
        AND (tlinfo.rule_type = x_rule_type)
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
    x_appl_rule_id                      IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_rule_sequence                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_rule_type				IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
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
      x_appl_rule_id                      => x_appl_rule_id,
      x_appl_hierarchy_id                 => x_appl_hierarchy_id,
      x_rule_sequence                     => x_rule_sequence,
      x_fee_type                          => x_fee_type,
      x_enabled_flag                      => x_enabled_flag,
      x_rule_type                         => x_rule_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_fi_app_rules
      SET
        appl_hierarchy_id                 = new_references.appl_hierarchy_id,
        rule_sequence                     = new_references.rule_sequence,
        fee_type                          = new_references.fee_type,
        enabled_flag                      = new_references.enabled_flag,
	rule_type			  = new_references.rule_type,
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
    x_appl_rule_id                      IN OUT NOCOPY NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_rule_sequence                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_rule_type                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_app_rules
      WHERE    appl_rule_id                      = x_appl_rule_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_appl_rule_id,
        x_appl_hierarchy_id,
        x_rule_sequence,
        x_fee_type,
        x_enabled_flag,
        x_rule_type,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_appl_rule_id,
      x_appl_hierarchy_id,
      x_rule_sequence,
      x_fee_type,
      x_enabled_flag,
      x_rule_type,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
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

    DELETE FROM igs_fi_app_rules
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_app_rules_pkg;

/
