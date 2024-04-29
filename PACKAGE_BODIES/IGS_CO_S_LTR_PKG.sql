--------------------------------------------------------
--  DDL for Package Body IGS_CO_S_LTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_S_LTR_PKG" AS
/* $Header: IGSLI16B.pls 115.8 2002/11/29 01:06:22 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_co_s_ltr%ROWTYPE;
  new_references igs_co_s_ltr%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_s_letter_reference_type           IN     VARCHAR2    DEFAULT NULL,
    x_s_letter_object                   IN     VARCHAR2    DEFAULT NULL,
    x_template_filename                 IN     VARCHAR2    DEFAULT NULL,
    x_letter_title                      IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CO_S_LTR
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
    new_references.correspondence_type               := x_correspondence_type;
    new_references.letter_reference_number           := x_letter_reference_number;
    new_references.description                       := x_description;
    new_references.s_letter_reference_type           := x_s_letter_reference_type;
    new_references.s_letter_object                   := x_s_letter_object;
    new_references.template_filename                 := x_template_filename;
    new_references.letter_title                      := x_letter_title;
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


  PROCEDURE check_constraints (
    column_name    IN     VARCHAR2    DEFAULT NULL,
    column_value   IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the Check Constraint logic for the the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER(column_name) = 'CLOSED_IND') THEN
      new_references.closed_ind := column_value;
    END IF;

    IF (UPPER(column_name) = 'CLOSED_IND' OR column_name IS NULL) THEN
      IF NOT (new_references.closed_ind IN ('Y', 'N'))  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;

   PROCEDURE GET_FK_IGS_LOOKUPS_VIEW_LETOBJ(
    x_s_letter_object IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CO_S_LTR
      WHERE    s_letter_object = x_s_letter_object ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_DA_LKUP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW_LETOBJ;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW_LETREF (
    x_s_letter_reference_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CO_S_LTR
      WHERE    s_letter_reference_type = x_s_letter_reference_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_DA_LKUP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW_LETREF;

  -- Trigger description :-
  -- "OSS_TST".trg_slet_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_CO_S_LTR
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	IF p_inserting THEN
		-- Validate Correspondence Type closed.
		IF  igs_ad_val_aal.corp_val_cort_closed(
					new_references.correspondence_type,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
		-- Validate Correspondence Type is system generated.
		IF  IGS_CO_VAL_SLET.corp_val_cort_sysgen(
					new_references.correspondence_type,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate System Letter Object closed.
	IF p_inserting OR
	    (p_updating AND
	     new_references.s_letter_object <> old_references.s_letter_object) THEN
		IF  IGS_CO_VAL_SLET.corp_val_slo_closed(
					new_references.s_letter_object,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;



  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.correspondence_type = new_references.correspondence_type)) OR
        ((new_references.correspondence_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_co_type_pkg.get_pk_for_validation (
                new_references.correspondence_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_co_ltr_param_pkg.get_fk_igs_co_s_ltr (
      old_references.correspondence_type,
      old_references.letter_reference_number
    );

    igs_co_ltr_rpt_grp_pkg.get_fk_igs_co_s_ltr (
      old_references.correspondence_type,
      old_references.letter_reference_number
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_s_ltr
      WHERE    correspondence_type = x_correspondence_type
      AND      letter_reference_number = x_letter_reference_number
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


  PROCEDURE get_fk_igs_co_type (
    x_correspondence_type               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_s_ltr
      WHERE   ((correspondence_type = x_correspondence_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_CO_CORT_SLET_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_co_type;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_s_letter_reference_type           IN     VARCHAR2    DEFAULT NULL,
    x_s_letter_object                   IN     VARCHAR2    DEFAULT NULL,
    x_template_filename                 IN     VARCHAR2    DEFAULT NULL,
    x_letter_title                      IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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
      x_correspondence_type,
      x_letter_reference_number,
      x_description,
      x_s_letter_reference_type,
      x_s_letter_object,
      x_template_filename,
      x_letter_title,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
        BeforeRowInsertUpdate1 ( p_inserting => TRUE );

      IF ( get_pk_for_validation(
             new_references.correspondence_type,
             new_references.letter_reference_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.correspondence_type,
             new_references.letter_reference_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_s_letter_reference_type           IN     VARCHAR2,
    x_s_letter_object                   IN     VARCHAR2,
    x_template_filename                 IN     VARCHAR2,
    x_letter_title                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_co_s_ltr
      WHERE    correspondence_type               = x_correspondence_type
      AND      letter_reference_number           = x_letter_reference_number;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_correspondence_type               => x_correspondence_type,
      x_letter_reference_number           => x_letter_reference_number,
      x_description                       => x_description,
      x_s_letter_reference_type           => x_s_letter_reference_type,
      x_s_letter_object                   => x_s_letter_object,
      x_template_filename                 => x_template_filename,
      x_letter_title                      => x_letter_title,
      x_closed_ind                        => NVL (x_closed_ind,'N' ),
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_co_s_ltr (
      correspondence_type,
      letter_reference_number,
      description,
      s_letter_reference_type,
      s_letter_object,
      template_filename,
      letter_title,
      closed_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.correspondence_type,
      new_references.letter_reference_number,
      new_references.description,
      new_references.s_letter_reference_type,
      new_references.s_letter_object,
      new_references.template_filename,
      new_references.letter_title,
      new_references.closed_ind,
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
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_s_letter_reference_type           IN     VARCHAR2,
    x_s_letter_object                   IN     VARCHAR2,
    x_template_filename                 IN     VARCHAR2,
    x_letter_title                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        description,
        s_letter_reference_type,
        s_letter_object,
        template_filename,
        letter_title,
        closed_ind
      FROM  igs_co_s_ltr
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
        (tlinfo.description = x_description)
        AND (tlinfo.s_letter_reference_type = x_s_letter_reference_type)
        AND (tlinfo.s_letter_object = x_s_letter_object)
        AND ((tlinfo.template_filename = x_template_filename) OR ((tlinfo.template_filename IS NULL) AND (X_template_filename IS NULL)))
        AND (tlinfo.letter_title = x_letter_title)
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
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_s_letter_reference_type           IN     VARCHAR2,
    x_s_letter_object                   IN     VARCHAR2,
    x_template_filename                 IN     VARCHAR2,
    x_letter_title                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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
      x_correspondence_type               => x_correspondence_type,
      x_letter_reference_number           => x_letter_reference_number,
      x_description                       => x_description,
      x_s_letter_reference_type           => x_s_letter_reference_type,
      x_s_letter_object                   => x_s_letter_object,
      x_template_filename                 => x_template_filename,
      x_letter_title                      => x_letter_title,
      x_closed_ind                        => NVL (x_closed_ind,'N' ),
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_co_s_ltr
      SET
        description                       = new_references.description,
        s_letter_reference_type           = new_references.s_letter_reference_type,
        s_letter_object                   = new_references.s_letter_object,
        template_filename                 = new_references.template_filename,
        letter_title                      = new_references.letter_title,
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
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_s_letter_reference_type           IN     VARCHAR2,
    x_s_letter_object                   IN     VARCHAR2,
    x_template_filename                 IN     VARCHAR2,
    x_letter_title                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_co_s_ltr
      WHERE    correspondence_type               = x_correspondence_type
      AND      letter_reference_number           = x_letter_reference_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_correspondence_type,
        x_letter_reference_number,
        x_description,
        x_s_letter_reference_type,
        x_s_letter_object,
        x_template_filename,
        x_letter_title,
        x_closed_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_correspondence_type,
      x_letter_reference_number,
      x_description,
      x_s_letter_reference_type,
      x_s_letter_object,
      x_template_filename,
      x_letter_title,
      x_closed_ind,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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

    DELETE FROM igs_co_s_ltr
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_co_s_ltr_pkg;

/
