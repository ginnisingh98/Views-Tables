--------------------------------------------------------
--  DDL for Package Body IGS_PE_HZ_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_HZ_REL_PKG" AS
/* $Header: IGSNIB1B.pls 120.2 2005/07/08 01:28:18 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_hz_rel%ROWTYPE;
  new_references igs_pe_hz_rel%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2,
    x_primary                           IN     VARCHAR2,
    x_secondary                         IN     VARCHAR2,
    x_joint_salutation                  IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_rep_faculty                       IN     VARCHAR2,
    x_rep_staff                         IN     VARCHAR2,
    x_rep_student                       IN     VARCHAR2,
    x_rep_alumni                        IN     VARCHAR2,
    x_emergency_contact_flag            IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_hz_rel
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
    new_references.relationship_id                   := x_relationship_id;
    new_references.directional_flag                  := x_directional_flag;
    new_references.primary                           := x_primary;
    new_references.secondary                         := x_secondary;
    new_references.joint_salutation                  := x_joint_salutation;
    new_references.next_to_kin                       := x_next_to_kin;
    new_references.rep_faculty                       := x_rep_faculty;
    new_references.rep_staff                         := x_rep_staff;
    new_references.rep_student                       := x_rep_student;
    new_references.rep_alumni                        := x_rep_alumni;
    new_references.emergency_contact_flag            := x_emergency_contact_flag;
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

 PROCEDURE AfterRowInsertUpdate(
    p_rowid     IN ROWID,
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN
    ) as
  ------------------------------------------------------------------------------------------
  --Created by  : kpadiyar
  --Date created: 10-JAN-2003
  --
  --Purpose: To form the Joint Salutation.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --asbala      15-JAN-2004   3349171: Incorrect usage of fnd_lookup_values view
  ----------------------------------------------------------------------------------------------
     --
     -- cursor to get the surname, prefix, given_names of member
     --
     CURSOR check_update IS
            SELECT d.subject_id
            FROM   igs_pe_hz_rel a , hz_relationships d
            WHERE  a.rowid = p_rowid
            AND    (NVL(a.primary,'N') = 'Y' OR NVL(a.secondary,'N') = 'Y')
            AND    d.relationship_id = a.relationship_id
            AND    a.directional_flag = d.directional_flag;


     CURSOR c_member_detail1(p_person_id NUMBER)  IS
            SELECT a.rowid,
                   b.person_last_name surname,
                   b.person_first_name given_names,
              b.person_pre_name_adjunct prefix
            FROM   igs_pe_hz_rel a ,hz_parties b , hz_relationships c
            WHERE  a.relationship_id = c.relationship_id
            AND    c.subject_id = p_person_id
            AND    c.object_id = b.party_id
            AND    c.directional_flag = a.directional_flag
            AND    NVL(a.primary,'N') = 'Y'
            AND    rownum = 1;

     CURSOR c_member_detail2(p_person_id NUMBER)  IS
            SELECT a.rowid,
                   b.person_last_name surname,
                   b.person_first_name given_names,
              b.person_pre_name_adjunct prefix
            FROM   igs_pe_hz_rel a ,hz_parties b , hz_relationships c
            WHERE  a.relationship_id = c.relationship_id
            AND    c.subject_id = p_person_id
            AND    c.object_id = b.party_id
            AND    c.directional_flag = a.directional_flag
            AND    NVL(a.secondary,'N') = 'Y'
            AND    rownum = 1;

     CURSOR c_prefix_desc (p_prefix VARCHAR2,
			   p_lookup_type fnd_lookup_values.lookup_type%TYPE,
			   p_view_application_id fnd_lookup_values.view_application_id%TYPE,
			   p_security_group_id fnd_lookup_values.security_group_id%TYPE)  IS
            SELECT meaning
            FROM   fnd_lookup_values
            WHERE  lookup_type = p_lookup_type
            AND    view_application_id = p_view_application_id
	    AND    language = USERENV('LANG')
	    AND    security_group_id = p_security_group_id
            AND    lookup_code  = p_prefix
            AND    enabled_flag = 'Y';

     l_member_id1 hz_relationships.object_id%TYPE;
     l_member_id2 hz_relationships.object_id%TYPE;
     rec_prime_member_detail    c_member_detail1%ROWTYPE;
     rec_sec_member_detail      c_member_detail2%ROWTYPE;
     lv_joint_salutation VARCHAR2(750);
     lv_update VARCHAR2(1);
     lv_update_joint_sal VARCHAR2(1);
     l_check_update check_update%ROWTYPE;
  BEGIN
  lv_update := 'N';
  lv_update_joint_sal := 'N';
  IF p_inserting OR p_updating THEN
    IF p_updating THEN
     OPEN check_update;
     FETCH check_update INTO l_check_update;
     IF check_update%FOUND THEN

       IF new_references.primary = 'Y' THEN
          IF  ( NVL(old_references.joint_salutation,'N') <> NVL(new_references.joint_salutation,'N'))  THEN
           --
           -- fetch secondary member details
           --
              OPEN c_member_detail2 (l_check_update.subject_id);
              FETCH c_member_detail2 INTO rec_sec_member_detail;
    	      IF rec_sec_member_detail.prefix IS NOT NULL THEN
                 OPEN c_prefix_desc (rec_sec_member_detail.prefix, 'CONTACT_TITLE',222,0);
	         FETCH c_prefix_desc INTO rec_sec_member_detail.prefix;
	         CLOSE c_prefix_desc;
              END IF;
   	      CLOSE c_member_detail2;

                    UPDATE igs_pe_hz_rel
		      SET
			joint_salutation = new_references.joint_salutation
		      WHERE rowid =rec_sec_member_detail.rowid;


          END IF;
       ELSIF new_references.secondary = 'Y' THEN
          IF  ( NVL(old_references.joint_salutation,'N') <> NVL(new_references.joint_salutation,'N'))  THEN
      	      -- fetch primary member details
              --
                OPEN c_member_detail1 (l_check_update.subject_id);
                FETCH c_member_detail1 INTO rec_prime_member_detail;
	        IF rec_prime_member_detail.prefix IS NOT NULL THEN
                   OPEN c_prefix_desc (rec_prime_member_detail.prefix, 'CONTACT_TITLE',222,0);
	           FETCH c_prefix_desc INTO rec_prime_member_detail.prefix;
      	           CLOSE c_prefix_desc;
       	        END IF;
                CLOSE c_member_detail1;

                      UPDATE igs_pe_hz_rel
		      SET
			joint_salutation = new_references.joint_salutation
		      WHERE rowid = rec_prime_member_detail.rowid;

          END IF;
       END IF;
     END IF;
     CLOSE check_update;
    END IF;
     IF p_updating THEN

	  /* Set the joint salutation to null if the member is changed from not being a primary or secondary */
           IF ( NVL(new_references.primary,'N') = 'N' and (NVL(new_references.primary,'N') <> NVL(old_references.primary,'N')) ) OR
              ( NVL(new_references.secondary,'N') = 'N' and (NVL(new_references.secondary,'N') <> NVL(old_references.secondary,'N')) ) THEN
		    UPDATE igs_pe_hz_rel
		    SET    joint_salutation = NULL
		    WHERE rowid = p_rowid;

	   END IF;

       OPEN check_update;
         FETCH check_update INTO l_check_update;
	 IF check_update%FOUND THEN
		  IF
		     ( NVL(old_references.primary,'N') <> NVL(new_references.primary,'N')) OR
		     ( NVL(old_references.secondary,'N') <> NVL(new_references.secondary,'N'))
		      THEN

                       lv_update := 'Y';

		  END IF;
	 ELSE
               lv_update := 'N';

	 END IF;
       CLOSE check_update;
     ELSE
       OPEN check_update;
         FETCH check_update INTO l_check_update;
		 IF check_update%FOUND THEN
		     lv_update := 'Y';

		 ELSE
		     lv_update := 'N';

		 END IF;
       CLOSE check_update;
     END IF;
   IF lv_update = 'Y'  THEN

	-- fetch primary member details
        --
        OPEN c_member_detail1 (l_check_update.subject_id);
        FETCH c_member_detail1 INTO rec_prime_member_detail;
	  IF rec_prime_member_detail.prefix IS NOT NULL THEN
            OPEN c_prefix_desc (rec_prime_member_detail.prefix, 'CONTACT_TITLE',222,0);
	     FETCH c_prefix_desc INTO rec_prime_member_detail.prefix;
	    CLOSE c_prefix_desc;
	  END IF;
        CLOSE c_member_detail1;
        --
        -- fetch secondary member details
        --
        OPEN c_member_detail2 (l_check_update.subject_id);
        FETCH c_member_detail2 INTO rec_sec_member_detail;
	  IF rec_sec_member_detail.prefix IS NOT NULL THEN
            OPEN c_prefix_desc (rec_sec_member_detail.prefix, 'CONTACT_TITLE',222,0);
	     FETCH c_prefix_desc INTO rec_sec_member_detail.prefix;
	    CLOSE c_prefix_desc;
	  END IF;
	CLOSE c_member_detail2;

        --
        -- prepare the joint salutation
        --
	FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_AND');

		IF rec_prime_member_detail.surname = rec_sec_member_detail.surname THEN
		   IF rec_prime_member_detail.prefix IS NULL AND rec_sec_member_detail.prefix IS NOT NULL THEN
		      lv_joint_salutation := rec_sec_member_detail.prefix||' '||rec_prime_member_detail.given_names||' '||rec_prime_member_detail.surname;

		   ELSIF rec_prime_member_detail.prefix IS NULL AND rec_sec_member_detail.prefix IS NULL THEN
		      lv_joint_salutation := rec_prime_member_detail.given_names||' '||rec_prime_member_detail.surname;

		   ELSIF rec_prime_member_detail.prefix IS NOT NULL AND rec_sec_member_detail.prefix IS NULL THEN
		      lv_joint_salutation := rec_prime_member_detail.prefix||' '||rec_prime_member_detail.given_names||' '||rec_prime_member_detail.surname;

		   ELSE
    		      lv_joint_salutation := rec_prime_member_detail.prefix||' '||FND_MESSAGE.GET||' '||rec_sec_member_detail.prefix||' '||rec_prime_member_detail.given_names||' '||rec_prime_member_detail.surname;
		   END IF;
		ELSE
                  IF ( (rec_prime_member_detail.prefix IS NULL) AND (rec_prime_member_detail.given_names IS NULL) AND (rec_prime_member_detail.surname IS NULL) ) THEN
		   lv_joint_salutation := rec_sec_member_detail.prefix||' '||rec_sec_member_detail.given_names||' '||rec_sec_member_detail.surname;
                  ELSE
		   lv_joint_salutation := rec_prime_member_detail.prefix||' '||rec_prime_member_detail.given_names||' '||
			rec_prime_member_detail.surname||' '||FND_MESSAGE.GET||' '||rec_sec_member_detail.prefix||' '||
			rec_sec_member_detail.given_names||' '||rec_sec_member_detail.surname;
		  END IF;
		END IF;

                    UPDATE igs_pe_hz_rel
		      SET
			joint_salutation = trim(lv_joint_salutation)
		      WHERE rowid in (rec_prime_member_detail.rowid,rec_sec_member_detail.rowid);

    END IF;
  END IF;

  END AfterRowInsertUpdate;

  PROCEDURE before_row_insert_update AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF new_references.primary = 'Y' AND new_references.secondary = 'Y' THEN
           fnd_message.set_name('IGS', 'IGS_AD_NOT_BOTH_PRIM_SEC');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
     END IF;
  END before_row_insert_update;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  CURSOR rel_pk IS
  SELECT 'Y' FROM HZ_RELATIONSHIPS
  WHERE relationship_id = new_references.relationship_id AND
        directional_flag = new_references.directional_flag;

  l_var VARCHAR2(1);
  BEGIN

    IF (((old_references.relationship_id = new_references.relationship_id) AND
         (old_references.directional_flag = new_references.directional_flag)) OR
        ((new_references.relationship_id IS NULL) OR
         (new_references.directional_flag IS NULL))) THEN
      NULL;
    ELSE
      OPEN rel_pk;
      FETCH rel_pk INTO l_var;
      IF rel_pk%NOTFOUND THEN
        CLOSE rel_pk;
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      CLOSE rel_pk;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_hz_rel
      WHERE    relationship_id = x_relationship_id
      AND      directional_flag = x_directional_flag
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
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2,
    x_primary                           IN     VARCHAR2,
    x_secondary                         IN     VARCHAR2,
    x_joint_salutation                  IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_rep_faculty                       IN     VARCHAR2,
    x_rep_staff                         IN     VARCHAR2,
    x_rep_student                       IN     VARCHAR2,
    x_rep_alumni                        IN     VARCHAR2,
    x_emergency_contact_flag            IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
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
      x_relationship_id,
      x_directional_flag,
      x_primary,
      x_secondary,
      x_joint_salutation,
      x_next_to_kin,
      x_rep_faculty,
      x_rep_staff,
      x_rep_student,
      x_rep_alumni,
      x_emergency_contact_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.relationship_id,
             new_references.directional_flag
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      before_row_insert_update;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      before_row_insert_update;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.relationship_id,
             new_references.directional_flag
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      before_row_insert_update;
  ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      before_row_insert_update;
    END IF;

  END before_dml;

  PROCEDURE after_dml(p_action IN VARCHAR2,
                      x_rowid IN VARCHAR2
                      ) AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate(
          p_rowid     => l_rowid,
          p_inserting => TRUE,
          p_updating  => FALSE,
          p_deleting  => FALSE
         );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate(
          p_rowid     => l_rowid,
		  p_inserting => FALSE,
          p_updating  => TRUE,
          p_deleting  => FALSE
                  );
   END IF;

  END after_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2,
    x_primary                           IN     VARCHAR2,
    x_secondary                         IN     VARCHAR2,
    x_joint_salutation                  IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_rep_faculty                       IN     VARCHAR2,
    x_rep_staff                         IN     VARCHAR2,
    x_rep_student                       IN     VARCHAR2,
    x_rep_alumni                        IN     VARCHAR2,
    x_emergency_contact_flag            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_directional_flag           igs_pe_hz_rel.directional_flag%TYPE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      fnd_message.set_token ('ROUTINE', 'IGS_PE_HZ_REL_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_relationship_id                   => x_relationship_id,
      x_directional_flag                  => x_directional_flag,
      x_primary                           => x_primary,
      x_secondary                         => x_secondary,
      x_joint_salutation                  => x_joint_salutation,
      x_next_to_kin                       => x_next_to_kin,
      x_rep_faculty                       => x_rep_faculty,
      x_rep_staff                         => x_rep_staff,
      x_rep_student                       => x_rep_student,
      x_rep_alumni                        => x_rep_alumni,
      x_emergency_contact_flag            => x_emergency_contact_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_hz_rel (
      relationship_id,
      directional_flag,
      primary,
      secondary,
      joint_salutation,
      next_to_kin,
      rep_faculty,
      rep_staff,
      rep_student,
      rep_alumni,
      emergency_contact_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.relationship_id,
      new_references.directional_flag,
      new_references.primary,
      new_references.secondary,
      new_references.joint_salutation,
      new_references.next_to_kin,
      new_references.rep_faculty,
      new_references.rep_staff,
      new_references.rep_student,
      new_references.rep_alumni,
      new_references.emergency_contact_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    IF new_references.directional_flag = 'F' THEN
       l_directional_flag := 'B';
    ELSIF new_references.directional_flag = 'B' THEN
       l_directional_flag := 'F';
    END IF;

    INSERT INTO igs_pe_hz_rel (
      relationship_id,
      directional_flag,
      primary,
      secondary,
      next_to_kin,
      rep_faculty,
      rep_staff,
      rep_student,
      rep_alumni,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.relationship_id,
      l_directional_flag,
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


     after_dml(p_action => 'INSERT',x_rowid => x_rowid);


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2,
    x_primary                           IN     VARCHAR2,
    x_secondary                         IN     VARCHAR2,
    x_joint_salutation                  IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_rep_faculty                       IN     VARCHAR2,
    x_rep_staff                         IN     VARCHAR2,
    x_rep_student                       IN     VARCHAR2,
    x_rep_alumni                        IN     VARCHAR2,
    x_emergency_contact_flag            IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        primary,
        secondary,
        joint_salutation,
        next_to_kin,
        rep_faculty,
        rep_staff,
        rep_student,
        rep_alumni,
	emergency_contact_flag
      FROM  igs_pe_hz_rel
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
        ((tlinfo.primary = x_primary) OR ((tlinfo.primary IS NULL) AND (X_primary IS NULL)))
        AND ((tlinfo.secondary = x_secondary) OR ((tlinfo.secondary IS NULL) AND (X_secondary IS NULL)))
        AND ((tlinfo.joint_salutation = x_joint_salutation) OR ((tlinfo.joint_salutation IS NULL) AND (X_joint_salutation IS NULL)))
        AND ((tlinfo.next_to_kin = x_next_to_kin) OR ((tlinfo.next_to_kin IS NULL) AND (X_next_to_kin IS NULL)))
        AND ((tlinfo.rep_faculty = x_rep_faculty) OR ((tlinfo.rep_faculty IS NULL) AND (X_rep_faculty IS NULL)))
        AND ((tlinfo.rep_staff = x_rep_staff) OR ((tlinfo.rep_staff IS NULL) AND (X_rep_staff IS NULL)))
        AND ((tlinfo.rep_student = x_rep_student) OR ((tlinfo.rep_student IS NULL) AND (X_rep_student IS NULL)))
        AND ((tlinfo.rep_alumni = x_rep_alumni) OR ((tlinfo.rep_alumni IS NULL) AND (X_rep_alumni IS NULL)))
	AND ((tlinfo.emergency_contact_flag = x_emergency_contact_flag) OR ((tlinfo.emergency_contact_flag IS NULL) AND (X_emergency_contact_flag IS NULL)))
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
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2,
    x_primary                           IN     VARCHAR2,
    x_secondary                         IN     VARCHAR2,
    x_joint_salutation                  IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_rep_faculty                       IN     VARCHAR2,
    x_rep_staff                         IN     VARCHAR2,
    x_rep_student                       IN     VARCHAR2,
    x_rep_alumni                        IN     VARCHAR2,
    x_emergency_contact_flag            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
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
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      fnd_message.set_token ('ROUTINE', 'IGS_PE_HZ_REL_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_relationship_id                   => x_relationship_id,
      x_directional_flag                  => x_directional_flag,
      x_primary                           => x_primary,
      x_secondary                         => x_secondary,
      x_joint_salutation                  => x_joint_salutation,
      x_next_to_kin                       => x_next_to_kin,
      x_rep_faculty                       => x_rep_faculty,
      x_rep_staff                         => x_rep_staff,
      x_rep_student                       => x_rep_student,
      x_rep_alumni                        => x_rep_alumni,
      x_emergency_contact_flag            => x_emergency_contact_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );


     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 --if the passed emergency contact flag is not null then update the database value. Else don't update emergency Contact value.
 IF new_references.emergency_contact_flag is NOT NULL THEN
   UPDATE igs_pe_hz_rel
      SET
        primary                           = new_references.primary,
        secondary                         = new_references.secondary,
        joint_salutation                  = new_references.joint_salutation,
        next_to_kin                       = new_references.next_to_kin,
        rep_faculty                       = new_references.rep_faculty,
        rep_staff                         = new_references.rep_staff,
        rep_student                       = new_references.rep_student,
        rep_alumni                        = new_references.rep_alumni,
        emergency_contact_flag		  = new_references.emergency_contact_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;
ELSE
     UPDATE igs_pe_hz_rel
      SET
        primary                           = new_references.primary,
        secondary                         = new_references.secondary,
        joint_salutation                  = new_references.joint_salutation,
        next_to_kin                       = new_references.next_to_kin,
        rep_faculty                       = new_references.rep_faculty,
        rep_staff                         = new_references.rep_staff,
        rep_student                       = new_references.rep_student,
        rep_alumni                        = new_references.rep_alumni,
        emergency_contact_flag		  = old_references.emergency_contact_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;
END IF;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


     after_dml(p_action => 'UPDATE', x_rowid => x_rowid);


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2,
    x_primary                           IN     VARCHAR2,
    x_secondary                         IN     VARCHAR2,
    x_joint_salutation                  IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_rep_faculty                       IN     VARCHAR2,
    x_rep_staff                         IN     VARCHAR2,
    x_rep_student                       IN     VARCHAR2,
    x_rep_alumni                        IN     VARCHAR2,
    x_emergency_contact_flag            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_hz_rel
      WHERE    relationship_id                   = x_relationship_id
      AND      directional_flag                  = x_directional_flag;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_relationship_id,
        x_directional_flag,
        x_primary,
        x_secondary,
        x_joint_salutation,
        x_next_to_kin,
        x_rep_faculty,
        x_rep_staff,
        x_rep_student,
        x_rep_alumni,
        x_emergency_contact_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_relationship_id,
      x_directional_flag,
      x_primary,
      x_secondary,
      x_joint_salutation,
      x_next_to_kin,
      x_rep_faculty,
      x_rep_staff,
      x_rep_student,
      x_rep_alumni,
      x_emergency_contact_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-APR-2003
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_pe_hz_rel
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  END delete_row;


END igs_pe_hz_rel_pkg;

/
