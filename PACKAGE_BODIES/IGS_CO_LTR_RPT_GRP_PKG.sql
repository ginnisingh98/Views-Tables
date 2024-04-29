--------------------------------------------------------
--  DDL for Package Body IGS_CO_LTR_RPT_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_LTR_RPT_GRP_PKG" AS
/* $Header: IGSLI13B.pls 115.11 2002/11/29 01:05:33 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_co_ltr_rpt_grp_all%ROWTYPE;
  new_references igs_co_ltr_rpt_grp_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_letter_repeating_group_cd         IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_sup_repeating_group_cd            IN     VARCHAR2    DEFAULT NULL,
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
      FROM     IGS_CO_LTR_RPT_GRP_ALL
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
    new_references.org_id                            := x_org_id;
    new_references.correspondence_type               := x_correspondence_type;
    new_references.letter_reference_number           := x_letter_reference_number;
    new_references.letter_repeating_group_cd         := x_letter_repeating_group_cd;
    new_references.description                       := x_description;
    new_references.sup_repeating_group_cd            := x_sup_repeating_group_cd;

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

  PROCEDURE BeforeRowInsert1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
  BEGIN
	IF p_inserting THEN
		-- Validate System Letter closed.
		IF  igs_ad_val_apcl.corp_val_slet_closed(
					new_references.correspondence_type,
					new_references.letter_reference_number,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsert1;


  PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 	) AS
  Begin
 		IF  column_name is null then
     			NULL;
 		ELSIF upper(Column_name) = 'CORRESPONDENCE_TYPE' then
     			new_references.correspondence_type:= column_value;
  		ELSIF upper(Column_name) = 'LETTER_REPEATING_GROUP_CD' then
     			new_references.letter_repeating_group_cd:= column_value;
		ELSIF upper(Column_name) = 'SUP_LETTER_REPEATING_GROUP_CD' then
     			new_references.sup_repeating_group_cd:= column_value;
		END IF;

		IF upper(column_name) = 'CORRESPONDENCE_TYPE' OR
     		column_name is null Then
     			IF new_references.correspondence_type <> UPPER(new_references.correspondence_type) Then
       				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       				IGS_GE_MSG_STACK.ADD;
       				App_Exception.Raise_Exception;
			END IF;
		END IF;

		IF upper(column_name) = 'LETTER_REPEATING_GROUP_CD' OR
     		column_name is null Then
     			IF new_references.letter_repeating_group_cd <> UPPER(new_references.letter_repeating_group_cd) Then
       				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       				IGS_GE_MSG_STACK.ADD;
       				App_Exception.Raise_Exception;
			END IF;
		END IF;

		IF upper(column_name) = 'SUP_LETTER_REPEATING_GROUP_CD' OR
     		column_name is null Then
     			IF new_references.sup_repeating_group_cd <>
			UPPER(new_references.sup_repeating_group_cd) Then
       				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       				IGS_GE_MSG_STACK.ADD;
       				App_Exception.Raise_Exception;
			END IF;
		END IF;	END Check_Constraints;


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

    IF (((old_references.correspondence_type = new_references.correspondence_type) AND
         (old_references.letter_reference_number = new_references.letter_reference_number) AND
         (old_references.sup_repeating_group_cd = new_references.sup_repeating_group_cd)) OR
        ((new_references.correspondence_type IS NULL) OR
         (new_references.letter_reference_number IS NULL) OR
         (new_references.sup_repeating_group_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_co_ltr_rpt_grp_pkg.get_pk_for_validation (
                new_references.correspondence_type,
                new_references.letter_reference_number,
                new_references.sup_repeating_group_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.correspondence_type = new_references.correspondence_type) AND
         (old_references.letter_reference_number = new_references.letter_reference_number)) OR
        ((new_references.correspondence_type IS NULL) OR
         (new_references.letter_reference_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_co_s_ltr_pkg.get_pk_for_validation (
                new_references.correspondence_type,
                new_references.letter_reference_number
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

    igs_co_ltr_pr_rpt_gr_pkg.get_fk_igs_co_ltr_rpt_grp (
      old_references.correspondence_type,
      old_references.letter_reference_number,
      old_references.letter_repeating_group_cd
    );

    igs_co_ltr_rpt_grp_pkg.get_fk_igs_co_ltr_rpt_grp (
      old_references.correspondence_type,
      old_references.letter_reference_number,
      old_references.letter_repeating_group_cd
    );

    igs_co_s_perlt_rptgp_pkg.get_fk_igs_co_ltr_rpt_grp (
      old_references.correspondence_type,
      old_references.letter_reference_number,
      old_references.letter_repeating_group_cd
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2
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
      FROM     igs_co_ltr_rpt_grp_all
      WHERE    correspondence_type = x_correspondence_type
      AND      letter_reference_number = x_letter_reference_number
      AND      letter_repeating_group_cd = x_letter_repeating_group_cd
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


  PROCEDURE get_fk_igs_co_ltr_rpt_grp (
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2
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
      FROM     igs_co_ltr_rpt_grp_all
      WHERE   ((correspondence_type = x_correspondence_type) AND
               (letter_reference_number = x_letter_reference_number) AND
               (sup_repeating_group_cd = x_letter_repeating_group_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_co_ltr_rpt_grp;


  PROCEDURE get_fk_igs_co_s_ltr (
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER
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
      FROM     igs_co_ltr_rpt_grp_all
      WHERE   ((correspondence_type = x_correspondence_type) AND
               (letter_reference_number = x_letter_reference_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_co_s_ltr;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_letter_repeating_group_cd         IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_sup_repeating_group_cd            IN     VARCHAR2    DEFAULT NULL,
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
      x_org_id,
      x_correspondence_type,
      x_letter_reference_number,
      x_letter_repeating_group_cd,
      x_description,
      x_sup_repeating_group_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
    BeforeRowInsert1 ( p_inserting => TRUE );

      IF ( get_pk_for_validation(
             new_references.correspondence_type,
             new_references.letter_reference_number,
             new_references.letter_repeating_group_cd
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
       Check_Constraints;
       check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Constraints;
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.correspondence_type,
             new_references.letter_reference_number,
             new_references.letter_repeating_group_cd
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
     Check_Constraints;

    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Constraints;
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_sup_repeating_group_cd            IN     VARCHAR2,
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
      FROM     igs_co_ltr_rpt_grp_all
      WHERE    correspondence_type               = x_correspondence_type
      AND      letter_reference_number           = x_letter_reference_number
      AND      letter_repeating_group_cd         = x_letter_repeating_group_cd;

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
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_correspondence_type               => x_correspondence_type,
      x_letter_reference_number           => x_letter_reference_number,
      x_letter_repeating_group_cd         => x_letter_repeating_group_cd,
      x_description                       => x_description,
      x_sup_repeating_group_cd            => x_sup_repeating_group_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_co_ltr_rpt_grp_all (
      org_id,
      correspondence_type,
      letter_reference_number,
      letter_repeating_group_cd,
      description,
      sup_repeating_group_cd,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.org_id,
      new_references.correspondence_type,
      new_references.letter_reference_number,
      new_references.letter_repeating_group_cd,
      new_references.description,
      new_references.sup_repeating_group_cd,
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
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_sup_repeating_group_cd            IN     VARCHAR2
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
        sup_repeating_group_cd
      FROM  igs_co_ltr_rpt_grp_all
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
        AND ((tlinfo.sup_repeating_group_cd = x_sup_repeating_group_cd) OR ((tlinfo.sup_repeating_group_cd IS NULL) AND (X_sup_repeating_group_cd IS NULL)))
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
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_sup_repeating_group_cd            IN     VARCHAR2,
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
      x_letter_repeating_group_cd         => x_letter_repeating_group_cd,
      x_description                       => x_description,
      x_sup_repeating_group_cd            => x_sup_repeating_group_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_co_ltr_rpt_grp_all
      SET
        description                       = new_references.description,
        sup_repeating_group_cd            = new_references.sup_repeating_group_cd,
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
    x_org_id                            IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_sup_repeating_group_cd            IN     VARCHAR2,
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
      FROM     igs_co_ltr_rpt_grp_all
      WHERE    correspondence_type               = x_correspondence_type
      AND      letter_reference_number           = x_letter_reference_number
      AND      letter_repeating_group_cd         = x_letter_repeating_group_cd;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_org_id,
        x_correspondence_type,
        x_letter_reference_number,
        x_letter_repeating_group_cd,
        x_description,
        x_sup_repeating_group_cd,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_correspondence_type,
      x_letter_reference_number,
      x_letter_repeating_group_cd,
      x_description,
      x_sup_repeating_group_cd,
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

    DELETE FROM igs_co_ltr_rpt_grp_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_co_ltr_rpt_grp_pkg;

/
