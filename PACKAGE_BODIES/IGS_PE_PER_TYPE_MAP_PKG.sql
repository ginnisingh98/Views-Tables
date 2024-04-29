--------------------------------------------------------
--  DDL for Package Body IGS_PE_PER_TYPE_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PER_TYPE_MAP_PKG" AS
/* $Header: IGSNIA4B.pls 120.1 2006/01/18 22:44:10 skpandey noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_per_type_map%ROWTYPE;
  new_references igs_pe_per_type_map%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_type_code                  IN     VARCHAR2,
    x_system_type                       IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 05-NOV-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_per_type_map
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
    new_references.person_type_code                  := x_person_type_code;
    new_references.system_type                       := x_system_type;
    new_references.per_person_type_id                := x_per_person_type_id;

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
  ||  Created By : prabhat.patel
  ||  Created On : 05-NOV-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR person_type_id_cur IS
	SELECT 'X'
	FROM   per_person_types
	WHERE  person_type_id = new_references.per_person_type_id;

    l_exists  VARCHAR2(1);
  BEGIN

    IF (((old_references.person_type_code = new_references.person_type_code)) OR
        ((new_references.person_type_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_types_pkg.get_pk_for_validation (
                        new_references.person_type_code
        )  THEN
         FND_MESSAGE.SET_NAME ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF (((old_references.per_person_type_id = new_references.per_person_type_id)) OR
        ((new_references.per_person_type_id IS NULL))) THEN
      NULL;
    ELSE
	  OPEN person_type_id_cur;
	  FETCH person_type_id_cur INTO l_exists;
	    IF person_type_id_cur%NOTFOUND THEN
		   CLOSE person_type_id_cur;
           FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
	  CLOSE person_type_id_cur;
	END IF;

    IF (((old_references.system_type = new_references.system_type)) OR
        ((new_references.system_type IS NULL))) THEN
      NULL;
    ELSE
	   IF NOT igs_lookups_view_pkg.get_pk_for_validation('SYSTEM_PERSON_TYPES',new_references.system_type) THEN
          FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
	END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_person_type_code                  IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 05-NOV-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_per_type_map
      WHERE    person_type_code = x_person_type_code
      AND      per_person_type_id = x_per_person_type_id
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
    x_person_type_code                  IN     VARCHAR2,
    x_system_type                       IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 05-NOV-2002
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
      x_person_type_code,
      x_system_type,
      x_per_person_type_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

      IF ( get_pk_for_validation(
             new_references.person_type_code,
             new_references.per_person_type_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

	  check_parent_existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.person_type_code,
             new_references.per_person_type_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

	  check_parent_existance;

    END IF;

  END before_dml;


  PROCEDURE afterinsert (
  x_system_type                  IN     VARCHAR2 )
  AS
 /*
  ||  Created By : ssawhney
  ||  Created On : 29nov
  ||  Purpose : Handles the After insert logic, we need to end date person type instances in OSS after the mapping is done.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR person_type_cur(cp_system_type igs_pe_person_types.system_type%TYPE) IS
    SELECT  ti.rowid,ti.*
    FROM	igs_pe_typ_instances_all ti,
		igs_pe_person_types pt,
		per_all_people_f ppf
    WHERE	ppf.party_id = ti.person_id AND
		ti.person_type_code = pt.person_type_code AND
		pt.system_type = cp_system_type AND
		(ti.end_date IS NULL OR (SYSDATE BETWEEN ti.start_date AND ti.end_date))
		;
--skpandey, Bug#4937960: Changed staff_exist cursor definition to optimize query
  CURSOR  staff_exist (cp_person_id HZ_PARTIES.PARTY_ID%TYPE) IS
    SELECT '1'
    FROM  igs_pe_typ_instances
    WHERE person_id = cp_person_id
    AND   system_type = 'STAFF'
    AND   (end_date IS NULL OR (SYSDATE BETWEEN start_date AND end_date));


  CURSOR ss_cur (cp_person_id HZ_PARTIES.PARTY_ID%TYPE) IS
    SELECT ti.rowid,ti.*
    FROM igs_pe_typ_instances_all ti,
	 igs_pe_person_types pt
    WHERE ti.person_type_code = pt.person_type_code AND
         pt.system_type = 'SS_ENROLL_STAFF' AND
	 ti.person_id = cp_person_id;

    exist_rec staff_exist%ROWTYPE;
    ss_rec    ss_cur%ROWTYPE;
    person_type_rec person_type_cur%ROWTYPE;
    l_staff  NUMBER := 0;

  BEGIN


  OPEN person_type_cur(x_system_type);
  LOOP
  FETCH person_type_cur into person_type_rec;
  EXIT WHEN person_type_cur%NOTFOUND;

  igs_pe_typ_instances_pkg.update_row
      	   (
	x_rowid                => person_type_rec.rowid,
	x_person_id            => person_type_rec.person_id,
	x_course_cd            => person_type_rec.course_cd,
	x_type_instance_id     => person_type_rec.type_instance_id,
	x_person_type_code     => person_type_rec.person_type_code,
	x_cc_version_number    => person_type_rec.cc_version_number,
	x_funnel_status        => person_type_rec.funnel_status,
	x_admission_appl_number=> person_type_rec.admission_appl_number,
	x_nominated_course_cd  => person_type_rec.nominated_course_cd,
	x_ncc_version_number   => person_type_rec.ncc_version_number,
	x_sequence_number      => person_type_rec.sequence_number,
	x_start_date           => person_type_rec.start_date,
	x_end_date             => TRUNC(sysdate),
	x_create_method        => person_type_rec.create_method,
	x_ended_by             => person_type_rec.ended_by,
	x_end_method           => 'END_MANUAL',
        x_emplmnt_category_code=> person_type_rec.emplmnt_category_code);

	 IF x_system_type ='STAFF' THEN
        -- if the system tye is now not a staff, then we need to validate and close the SS staff type instance IF present also.

	     OPEN staff_exist(person_type_rec.person_id);
	     FETCH staff_exist INTO exist_rec;
	     IF staff_exist%NOTFOUND THEN

		OPEN ss_cur (person_type_rec.person_id);

		-- there can be more than one mapping;
		LOOP

		FETCH ss_cur INTO ss_rec;
		EXIT WHEN ss_cur%NOTFOUND;

		igs_pe_typ_instances_pkg.update_row
      		(
		x_rowid                => ss_rec.rowid,
		x_person_id            => ss_rec.person_id,
		x_course_cd            => ss_rec.course_cd,
		x_type_instance_id     => ss_rec.type_instance_id,
		x_person_type_code     => ss_rec.person_type_code,
		x_cc_version_number    => ss_rec.cc_version_number,
		x_funnel_status        => ss_rec.funnel_status,
		x_admission_appl_number=> ss_rec.admission_appl_number,
		x_nominated_course_cd  => ss_rec.nominated_course_cd,
		x_ncc_version_number   => ss_rec.ncc_version_number,
		x_sequence_number      => ss_rec.sequence_number,
		x_start_date           => ss_rec.start_date,
		x_end_date             => TRUNC(sysdate),
		x_create_method        => ss_rec.create_method,
		x_ended_by             => ss_rec.ended_by,
		x_end_method           => 'END_MANUAL',
                x_emplmnt_category_code=> ss_rec.emplmnt_category_code);

		END LOOP;
                IF ss_cur%ISOPEN THEN
		   CLOSE ss_cur;
		END IF;

	     END IF;
             IF staff_exist%ISOPEN THEN
		   CLOSE staff_exist;
	     END IF;
	END IF; -- staff
  END LOOP;
  IF  person_type_cur%ISOPEN THEN
	CLOSE person_type_cur;
  END IF;

  END afterinsert;

 PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : ssawhney
  Date Created By : 2000/13/05
  Purpose : To validate the fields after doing the DML operation.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
    	afterinsert(new_references.system_type);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END after_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_type_code                  IN     VARCHAR2,
    x_system_type                       IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 05-NOV-2002
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_person_type_code                  => x_person_type_code,
      x_system_type                       => x_system_type,
      x_per_person_type_id                => x_per_person_type_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_pe_per_type_map (
      person_type_code,
      system_type,
      per_person_type_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.person_type_code,
      new_references.system_type,
      new_references.per_person_type_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;


  After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_type_code                  IN     VARCHAR2,
    x_system_type                       IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 05-NOV-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        system_type
      FROM  igs_pe_per_type_map
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
        (tlinfo.system_type = x_system_type)
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
    x_person_type_code                  IN     VARCHAR2,
    x_system_type                       IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 05-NOV-2002
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
      x_person_type_code                  => x_person_type_code,
      x_system_type                       => x_system_type,
      x_per_person_type_id                => x_per_person_type_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_pe_per_type_map
      SET
        system_type                       = new_references.system_type,
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
    x_person_type_code                  IN     VARCHAR2,
    x_system_type                       IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 05-NOV-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_per_type_map
      WHERE    person_type_code                  = x_person_type_code
      AND      per_person_type_id                = x_per_person_type_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_type_code,
        x_system_type,
        x_per_person_type_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_type_code,
      x_system_type,
      x_per_person_type_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 05-NOV-2002
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

    DELETE FROM igs_pe_per_type_map
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pe_per_type_map_pkg;

/
