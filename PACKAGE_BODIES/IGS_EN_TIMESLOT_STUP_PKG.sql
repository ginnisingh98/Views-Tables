--------------------------------------------------------
--  DDL for Package Body IGS_EN_TIMESLOT_STUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_TIMESLOT_STUP_PKG" AS
/* $Header: IGSEI38B.pls 115.6 2003/01/31 09:30:36 nbehera ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_en_timeslot_stup%ROWTYPE;
  new_references igs_en_timeslot_stup%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_student_type IN VARCHAR2 DEFAULT NULL,
    x_assign_randomly IN VARCHAR2 DEFAULT NULL,
    x_surname_alphabet IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_igs_en_timeslot_stup_id IN NUMBER DEFAULT NULL,
    x_program_type_group_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_TIMESLOT_STUP
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.sequence_number := x_sequence_number;
    new_references.student_type := x_student_type;
    new_references.assign_randomly := x_assign_randomly;
    new_references.surname_alphabet := x_surname_alphabet;
    new_references.cal_type := x_cal_type;
    new_references.igs_en_timeslot_stup_id := x_igs_en_timeslot_stup_id;
    new_references.program_type_group_cd := x_program_type_group_cd;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
    new_references.org_id := x_org_id;

  END set_column_values;

 PROCEDURE check_constraints (
   column_name IN VARCHAR2  DEFAULT NULL,
   column_value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'ASSIGN_RANDOMLY'  THEN
        new_references.assign_randomly := column_value;
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF UPPER(column_name) = 'ASSIGN_RANDOMLY' OR
      	column_name IS NULL THEN
        IF NOT (new_references.assign_randomly IN ('Y','N'))  THEN
           fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
      igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;
      END IF;


  END check_constraints;

 PROCEDURE check_uniqueness AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
  IF get_uk_for_validation (
    		new_references.program_type_group_cd
    		,new_references.cal_type
    		,new_references.sequence_number
    		,new_references.student_type
    		) THEN
 		fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
			app_exception.raise_exception;
    		END IF;
 END check_uniqueness ;
  PROCEDURE check_parent_existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
        		new_references.cal_type,
         		 new_references.sequence_number
        )  THEN
	 fnd_message.set_name ('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
 	 app_exception.raise_exception;
    END IF;

    IF (((old_references.program_type_group_cd = new_references.program_type_group_cd)) OR
        ((new_references.program_type_group_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_type_grp_pkg.get_pk_for_validation (
        		new_references.program_type_group_cd
        )  THEN
	 fnd_message.set_name ('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
 	 app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE check_child_existance IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    igs_en_timeslot_prty_pkg.get_fk_igs_en_timeslot_stup (
      old_references.igs_en_timeslot_stup_id
      );

  END check_child_existance;

 FUNCTION get_pk_for_validation (
   x_igs_en_timeslot_stup_id IN NUMBER
   ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_timeslot_stup
      WHERE    igs_en_timeslot_stup_id = x_igs_en_timeslot_stup_id
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
   x_program_type_group_cd IN VARCHAR2,
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_student_type IN VARCHAR2
   ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_timeslot_stup
      WHERE    program_type_group_cd = x_program_type_group_cd
      AND      cal_type = x_cal_type
      AND      sequence_number = x_sequence_number
      AND      student_type = x_student_type 	and      ((l_rowid is null) or (rowid <> l_rowid))

      ;
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
 PROCEDURE get_fk_igs_ca_inst (
   x_cal_type IN VARCHAR2,
   x_sequence_number IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_timeslot_stup
      WHERE    cal_type = x_cal_type
      AND      sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;

 PROCEDURE get_fk_igs_ps_type_grp (
   x_course_type_group_cd IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_timeslot_stup
      WHERE    program_type_group_cd = x_course_type_group_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_type_grp;

 PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_student_type IN VARCHAR2 DEFAULT NULL,
    x_assign_randomly IN VARCHAR2 DEFAULT NULL,
    x_surname_alphabet IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_igs_en_timeslot_stup_id IN NUMBER DEFAULT NULL,
    x_program_type_group_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL

  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_sequence_number,
      x_student_type,
      x_assign_randomly,
      x_surname_alphabet,
      x_cal_type,
      x_igs_en_timeslot_stup_id,
      x_program_type_group_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
      IF get_pk_for_validation(
          new_references.igs_en_timeslot_stup_id)  THEN
	    fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
            igs_ge_msg_stack.add;
	    app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
 check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF get_pk_for_validation (
    		new_references.igs_en_timeslot_stup_id)  THEN
	       fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
          igs_ge_msg_stack.add;
	       app_exception.raise_exception;
	     END IF;
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;

 PROCEDURE after_dml (
    p_action IN VARCHAR2,
   x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END after_dml;

 PROCEDURE insert_row (
      x_rowid IN OUT NOCOPY VARCHAR2,
       x_sequence_number IN NUMBER,
       x_student_type IN VARCHAR2,
       x_assign_randomly IN VARCHAR2,
       x_surname_alphabet IN VARCHAR2,
       x_cal_type IN VARCHAR2,
       x_igs_en_timeslot_stup_id IN OUT NOCOPY NUMBER,
       x_program_type_group_cd IN VARCHAR2,
       x_mode IN VARCHAR2 DEFAULT 'R'  ,
       X_ORG_ID in NUMBER

  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  pradhakr	23-Jul-2002	Assigned igs_ge_gen_003.get_org_id to x_org_id in
				before dml as part of bug# 2457599
  ***************************************************************/

    CURSOR c IS SELECT ROWID FROM igs_en_timeslot_stup
             WHERE                 igs_en_timeslot_stup_id= x_igs_en_timeslot_stup_id
;
     x_last_update_date DATE ;
     x_last_updated_by NUMBER ;
     x_last_update_login NUMBER ;
 BEGIN
     x_last_update_date := SYSDATE;
      IF(x_mode = 'I') THEN
        x_last_updated_by := 1;
        x_last_update_login := 0;
         ELSIF (x_mode = 'R') THEN
               x_last_updated_by := fnd_global.user_id;
            IF x_last_updated_by IS NULL then
                x_last_updated_by := -1;
            END IF;
            x_last_update_login := fnd_global.login_id;
         IF x_last_update_login IS NULL THEN
            x_last_update_login := -1;
         END IF;
       ELSE
         fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
       end if;

     select igs_en_timeslot_stup_s.nextval into x_igs_en_timeslot_stup_id from dual;

   before_dml(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_sequence_number=>x_sequence_number,
 	       x_student_type=>x_student_type,
 	       x_assign_randomly=>x_assign_randomly,
 	       x_surname_alphabet=>x_surname_alphabet,
 	       x_cal_type=>x_cal_type,
 	       x_igs_en_timeslot_stup_id=>x_igs_en_timeslot_stup_id,
 	       x_program_type_group_cd=>x_program_type_group_cd,
	       x_creation_date=> x_last_update_date,
	       x_created_by=> x_last_updated_by,
	       x_last_update_date=> x_last_update_date,
	       x_last_updated_by=> x_last_updated_by,
	       x_last_update_login=> x_last_update_login,
               x_org_id => igs_ge_gen_003.get_org_id );
     INSERT INTO igs_en_timeslot_stup (
		sequence_number
		,student_type
		,assign_randomly
		,surname_alphabet
		,cal_type
		,igs_en_timeslot_stup_id
		,program_type_group_cd
	        ,creation_date
		,created_by
		,last_update_date
		,last_updated_by
		,last_update_login
	      ,ORG_ID
        ) VALUES  (
	        new_references.sequence_number
	        ,new_references.student_type
	        ,new_references.assign_randomly
	        ,new_references.surname_alphabet
	        ,new_references.cal_type
	        ,new_references.igs_en_timeslot_stup_id
	        ,new_references.program_type_group_cd
	        ,x_last_update_date
		,x_last_updated_by
		,x_last_update_date
		,x_last_updated_by
		,x_last_update_login
 		,NEW_REFERENCES.ORG_ID );
		OPEN c;
		 FETCH c INTO x_rowid;
 		IF (c%NOTFOUND) THEN
		CLOSE c;
 	     RAISE NO_DATA_FOUND;
		END IF;
 		CLOSE c;
    after_dml (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
END insert_row;
 PROCEDURE lock_row (
  x_rowid IN VARCHAR2,
  x_sequence_number IN NUMBER,
  x_student_type IN VARCHAR2,
  x_assign_randomly IN VARCHAR2,
  x_surname_alphabet IN VARCHAR2,
  x_cal_type IN VARCHAR2,
  x_igs_en_timeslot_stup_id IN NUMBER,
  x_program_type_group_cd IN VARCHAR2  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Nishikant       31JAN03         SURNAME_ALPHABET changed to nullable - Bug#2455364
  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR c1 IS SELECT
      sequence_number
,      student_type
,      assign_randomly
,      surname_alphabet
,      cal_type
,      program_type_group_cd
    FROM igs_en_timeslot_stup
    WHERE ROWID = x_rowid
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
if ( (  tlinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
  AND (tlinfo.STUDENT_TYPE = X_STUDENT_TYPE)
  AND (tlinfo.ASSIGN_RANDOMLY = X_ASSIGN_RANDOMLY)
  AND ((tlinfo.SURNAME_ALPHABET = X_SURNAME_ALPHABET)
       OR ((tlinfo.SURNAME_ALPHABET IS NULL)
           AND (X_SURNAME_ALPHABET IS NULL)))
  AND (tlinfo.CAL_TYPE = X_CAL_TYPE)
  AND (tlinfo.PROGRAM_TYPE_GROUP_CD = X_PROGRAM_TYPE_GROUP_CD)
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
    x_rowid IN  VARCHAR2,
    x_SEQUENCE_NUMBER IN NUMBER,
    x_STUDENT_TYPE IN VARCHAR2,
    x_ASSIGN_RANDOMLY IN VARCHAR2,
    x_SURNAME_ALPHABET IN VARCHAR2,
    x_CAL_TYPE IN VARCHAR2,
    x_IGS_EN_TIMESLOT_STUP_ID IN NUMBER,
    x_PROGRAM_TYPE_GROUP_CD IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     x_last_update_date DATE ;
     x_last_updated_by NUMBER ;
     x_last_update_login NUMBER ;
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
         IF x_last_update_login IS NULL THEN
            x_last_update_login := -1;
          END IF;
       ELSE
        fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
          app_exception.raise_exception;
       END IF;
   before_dml(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_sequence_number=>X_SEQUENCE_NUMBER,
 	       x_student_type=>X_STUDENT_TYPE,
 	       x_assign_randomly=>X_ASSIGN_RANDOMLY,
 	       x_surname_alphabet=>X_SURNAME_ALPHABET,
 	       x_cal_type=>X_CAL_TYPE,
 	       x_igs_en_timeslot_stup_id=>X_IGS_EN_TIMESLOT_STUP_ID,
 	       x_program_type_group_cd=>X_PROGRAM_TYPE_GROUP_CD,
	       x_creation_date=>x_last_update_date,
	       x_created_by=>x_last_updated_by,
	       x_last_update_date=>x_last_update_date,
	       x_last_updated_by=>x_last_updated_by,
	       x_last_update_login=>x_last_update_login);
   UPDATE igs_en_timeslot_stup SET
      sequence_number =  NEW_REFERENCES.sequence_number,
      student_type =  NEW_REFERENCES.student_type,
      assign_randomly =  NEW_REFERENCES.assign_randomly,
      surname_alphabet =  NEW_REFERENCES.surname_alphabet,
      cal_type =  NEW_REFERENCES.cal_type,
      program_type_group_cd =  NEW_REFERENCES.program_type_group_cd,
	last_update_date = x_last_update_date,
	last_updated_by = x_last_updated_by,
	last_update_login = x_last_update_login
	  WHERE ROWID = x_rowid;
	IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	END IF;

 after_dml (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
END update_row;
 PROCEDURE add_row (
      x_rowid IN OUT NOCOPY VARCHAR2,
       x_sequence_number IN NUMBER,
       x_student_type IN VARCHAR2,
       x_assign_randomly IN VARCHAR2,
       x_surname_alphabet IN VARCHAR2,
       x_cal_type IN VARCHAR2,
       x_igs_en_timeslot_stup_id IN OUT NOCOPY NUMBER,
       x_program_type_group_cd IN VARCHAR2,
       x_mode IN VARCHAR2 DEFAULT 'R'  ,
	 X_ORG_ID in NUMBER
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR c1 IS SELECT ROWID FROM igs_en_timeslot_stup
             WHERE     igs_en_timeslot_stup_id= x_igs_en_timeslot_stup_id
;
BEGIN
	OPEN c1;
		FETCH c1 INTO x_rowid;
	IF (c1%NOTFOUND) THEN
	CLOSE c1;
    insert_row (
      x_rowid,
       X_sequence_number,
       X_student_type,
       X_assign_randomly,
       X_surname_alphabet,
       X_cal_type,
       X_igs_en_timeslot_stup_id,
       X_program_type_group_cd,
       x_mode ,
       X_ORG_ID);

     RETURN;
	END IF;
	   CLOSE c1;
update_row (
      x_rowid,
       x_sequence_number,
       x_student_type,
       x_assign_randomly,
       x_surname_alphabet,
       x_cal_type,
       x_igs_en_timeslot_stup_id,
       x_program_type_group_cd,
       x_mode );
END add_row;
PROCEDURE delete_row (
  x_rowid IN VARCHAR2
) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

BEGIN
before_dml (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 DELETE FROM igs_en_timeslot_stup
 WHERE ROWID = x_rowid;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
after_dml (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
END delete_row;
END igs_en_timeslot_stup_pkg;

/
