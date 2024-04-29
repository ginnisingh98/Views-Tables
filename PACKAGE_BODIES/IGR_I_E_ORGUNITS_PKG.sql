--------------------------------------------------------
--  DDL for Package Body IGR_I_E_ORGUNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_E_ORGUNITS_PKG" AS
/* $Header: IGSRH10B.pls 120.0 2005/06/01 17:41:41 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igr_i_e_orgunits%ROWTYPE;
  new_references igr_i_e_orgunits%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ent_org_unit_id                   IN     NUMBER      DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_inquiry_type_id                   IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGR_I_E_ORGUNITS
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
    new_references.ent_org_unit_id                   := x_ent_org_unit_id;
    new_references.inquiry_type_id                 := x_inquiry_type_id;
    new_references.party_id                          := x_party_id;
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


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
	   new_references.party_id,
	   new_references.inquiry_type_id
	 )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  FUNCTION  Check_Party_Existence (
    x_party_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR hz_pk IS
      SELECT   party_id
      FROM     HZ_PARTIES
      WHERE    party_id = x_party_id;
    lv_hz_pk hz_pk%RowType;
  BEGIN
    Open hz_pk;
    Fetch hz_pk INTO lv_hz_pk;
  IF (hz_pk%FOUND) THEN
    Close hz_pk;
    Return (TRUE);
  ELSE
    Close hz_pk;
    Return (FALSE);
  END IF;
  END Check_Party_Existence;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.party_id = new_references.party_id)) OR
	((new_references.party_id IS NULL))) THEN
      NULL;
    ELSIF NOT Check_Party_Existence (
		new_references.party_id
	      ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.inquiry_type_id = new_references.inquiry_type_id)) OR
	((new_references.inquiry_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igr_i_inquiry_types_pkg.get_pk_for_validation (
		new_references.inquiry_type_id
	      ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_ent_org_unit_id                   IN     NUMBER ,
    x_closed_ind                        IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igr_i_e_orgunits
      WHERE    ent_org_unit_id = x_ent_org_unit_id AND
	       closed_ind = NVL(x_closed_ind,closed_ind)
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
    x_party_id                          IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_inquiry_type_id                 IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igr_i_e_orgunits
      WHERE    inquiry_type_id = x_inquiry_type_id
      AND      party_id = x_party_id
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      AND      closed_ind = NVL(x_closed_ind,closed_ind);

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


  PROCEDURE get_fk_igr_i_ent_stats (
    x_inquiry_type_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igr_i_e_orgunits
      WHERE   ((inquiry_type_id = x_inquiry_type_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_AIEOU_AIEST_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igr_i_ent_stats;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ent_org_unit_id                   IN     NUMBER      DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_inquiry_type_id                   IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
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
      x_ent_org_unit_id,
      x_party_id,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_inquiry_type_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
	     new_references.ent_org_unit_id
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
	     new_references.ent_org_unit_id
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
    x_ent_org_unit_id                   IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_inquiry_type_id                   IN     NUMBER DEFAULT NULL
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igr_i_e_orgunits
      WHERE    ent_org_unit_id                   = x_ent_org_unit_id;

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

    X_ENT_ORG_UNIT_ID := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ent_org_unit_id                   => x_ent_org_unit_id,
      x_party_id                          => x_party_id,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_inquiry_type_id                   => x_inquiry_type_id
    );

    INSERT INTO igr_i_e_orgunits (
      ent_org_unit_id,
      party_id,
      closed_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      inquiry_type_id
    ) VALUES (
      IGR_I_E_ORGUNITS_S.NEXTVAL,
      new_references.party_id,
      new_references.closed_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.inquiry_type_id
    )RETURNING ENT_ORG_UNIT_ID INTO X_ENT_ORG_UNIT_ID;

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
    x_ent_org_unit_id                   IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_inquiry_type_id                   IN     NUMBER DEFAULT NULL
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
	inquiry_type_id,
	party_id,
	closed_ind
      FROM  igr_i_e_orgunits
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
	(tlinfo.inquiry_type_id = x_inquiry_type_id)
	AND (tlinfo.party_id = x_party_id)
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
    x_ent_org_unit_id                   IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_inquiry_type_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
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
      x_ent_org_unit_id                   => x_ent_org_unit_id,
      x_party_id                          => x_party_id,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_inquiry_type_id                 => x_inquiry_type_id
    );

    UPDATE igr_i_e_orgunits
      SET
	inquiry_type_id                 = new_references.inquiry_type_id,
	party_id                          = new_references.party_id,
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
    x_ent_org_unit_id                   IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_inquiry_type_id                   IN     NUMBER DEFAULT NULL
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igr_i_e_orgunits
      WHERE    ent_org_unit_id                   = x_ent_org_unit_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
	x_rowid,
	x_ent_org_unit_id,
	x_party_id,
	x_closed_ind,
	x_mode,
	x_inquiry_type_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ent_org_unit_id,
      x_party_id,
      x_closed_ind,
      x_mode,
      x_inquiry_type_id
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
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

    DELETE FROM igr_i_e_orgunits
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igr_i_e_orgunits_pkg;

/
