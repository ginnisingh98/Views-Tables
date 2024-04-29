--------------------------------------------------------
--  DDL for Package Body IGS_EN_TIMESLOT_PRTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_TIMESLOT_PRTY_PKG" AS
/* $Header: IGSEI39B.pls 115.5 2002/11/28 23:41:46 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_en_timeslot_prty%ROWTYPE;
  new_references igs_en_timeslot_prty%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_igs_en_timeslot_prty_id IN NUMBER DEFAULT NULL,
    x_igs_en_timeslot_stup_id IN NUMBER DEFAULT NULL,
    x_priority_order IN NUMBER DEFAULT NULL,
    x_priority_value IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
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
      FROM     IGS_EN_TIMESLOT_PRTY
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
    new_references.igs_en_timeslot_prty_id := x_igs_en_timeslot_prty_id;
    new_references.igs_en_timeslot_stup_id := x_igs_en_timeslot_stup_id;
    new_references.priority_order := x_priority_order;
    new_references.priority_value := x_priority_value;
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
        NULL;
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
    		new_references.igs_en_timeslot_stup_id
    		,new_references.priority_value
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

    IF (((old_references.igs_en_timeslot_stup_id = new_references.igs_en_timeslot_stup_id)) OR
        ((new_references.igs_en_timeslot_stup_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_timeslot_stup_pkg.get_pk_for_validation (
        		new_references.igs_en_timeslot_stup_id
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

    igs_en_timeslot_pref_pkg.get_fk_igs_en_timeslot_prty (
      old_references.igs_en_timeslot_prty_id
      );

  END check_child_existance;

 FUNCTION get_pk_for_validation (
   x_igs_en_timeslot_prty_id IN NUMBER
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
      FROM     igs_en_timeslot_prty
      WHERE    igs_en_timeslot_prty_id = x_igs_en_timeslot_prty_id
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
   x_igs_en_timeslot_stup_id IN NUMBER,
    x_priority_value IN VARCHAR2
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
      FROM     igs_en_timeslot_prty
      WHERE    igs_en_timeslot_stup_id = x_igs_en_timeslot_stup_id
      AND      priority_value = x_priority_value 	and      ((l_rowid is null) or (rowid <> l_rowid))

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
 PROCEDURE get_fk_igs_en_timeslot_stup (
   x_igs_en_timeslot_stup_id IN NUMBER
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
      FROM     igs_en_timeslot_prty
      WHERE    igs_en_timeslot_stup_id = x_igs_en_timeslot_stup_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_ETPY_ETST_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_timeslot_stup;

 PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_igs_en_timeslot_prty_id IN NUMBER DEFAULT NULL,
    x_igs_en_timeslot_stup_id IN NUMBER DEFAULT NULL,
    x_priority_order IN NUMBER DEFAULT NULL,
    x_priority_value IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
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
      x_igs_en_timeslot_prty_id,
      x_igs_en_timeslot_stup_id,
      x_priority_order,
      x_priority_value,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
      IF get_pk_for_validation(
          new_references.igs_en_timeslot_prty_id)  THEN
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
    		new_references.igs_en_timeslot_prty_id)  THEN
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
       x_igs_en_timeslot_prty_id IN OUT NOCOPY NUMBER,
       x_igs_en_timeslot_stup_id IN NUMBER,
       x_priority_order IN NUMBER,
       x_priority_value IN VARCHAR2,
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

    CURSOR c IS SELECT ROWID FROM igs_en_timeslot_prty
             WHERE                 igs_en_timeslot_prty_id= x_igs_en_timeslot_prty_id
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

     select igs_en_timeslot_prty_s.nextval into x_igs_en_timeslot_prty_id from dual;

   before_dml(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_igs_en_timeslot_prty_id=>x_igs_en_timeslot_prty_id,
 	       x_igs_en_timeslot_stup_id=>x_igs_en_timeslot_stup_id,
 	       x_priority_order=>x_priority_order,
 	       x_priority_value=>x_priority_value,
	       x_creation_date=> x_last_update_date,
	       x_created_by=> x_last_updated_by,
	       x_last_update_date=> x_last_update_date,
	       x_last_updated_by=> x_last_updated_by,
	       x_last_update_login=> x_last_update_login);
     INSERT INTO igs_en_timeslot_prty (
		igs_en_timeslot_prty_id
		,igs_en_timeslot_stup_id
		,priority_order
		,priority_value
	        ,creation_date
		,created_by
		,last_update_date
		,last_updated_by
		,last_update_login
        ) VALUES  (
	        new_references.igs_en_timeslot_prty_id
	        ,new_references.igs_en_timeslot_stup_id
	        ,new_references.priority_order
	        ,new_references.priority_value
	        ,x_last_update_date
		,x_last_updated_by
		,x_last_update_date
		,x_last_updated_by
		,x_last_update_login
);
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
  x_igs_en_timeslot_prty_id IN NUMBER,
  x_igs_en_timeslot_stup_id IN NUMBER,
  x_priority_order IN NUMBER,
  x_priority_value IN VARCHAR2  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR c1 IS SELECT
      igs_en_timeslot_stup_id
,      priority_order
,      priority_value
    FROM igs_en_timeslot_prty
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
if ( (  tlinfo.IGS_EN_TIMESLOT_STUP_ID = X_IGS_EN_TIMESLOT_STUP_ID)
  AND (tlinfo.PRIORITY_ORDER = X_PRIORITY_ORDER)
  AND (tlinfo.PRIORITY_VALUE = X_PRIORITY_VALUE)
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
    x_IGS_EN_TIMESLOT_PRTY_ID IN NUMBER,
    x_IGS_EN_TIMESLOT_STUP_ID IN NUMBER,
    x_PRIORITY_ORDER IN NUMBER,
    x_PRIORITY_VALUE IN VARCHAR2,
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
 	       x_igs_en_timeslot_prty_id=>X_IGS_EN_TIMESLOT_PRTY_ID,
 	       x_igs_en_timeslot_stup_id=>X_IGS_EN_TIMESLOT_STUP_ID,
 	       x_priority_order=>X_PRIORITY_ORDER,
 	       x_priority_value=>X_PRIORITY_VALUE,
	       x_creation_date=>x_last_update_date,
	       x_created_by=>x_last_updated_by,
	       x_last_update_date=>x_last_update_date,
	       x_last_updated_by=>x_last_updated_by,
	       x_last_update_login=>x_last_update_login);
   UPDATE igs_en_timeslot_prty SET
      igs_en_timeslot_stup_id =  NEW_REFERENCES.igs_en_timeslot_stup_id,
      priority_order =  NEW_REFERENCES.priority_order,
      priority_value =  NEW_REFERENCES.priority_value,
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
       x_igs_en_timeslot_prty_id IN OUT NOCOPY NUMBER,
       x_igs_en_timeslot_stup_id IN NUMBER,
       x_priority_order IN NUMBER,
       x_priority_value IN VARCHAR2,
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

    CURSOR c1 IS SELECT ROWID FROM igs_en_timeslot_prty
             WHERE     igs_en_timeslot_prty_id= x_igs_en_timeslot_prty_id
;
BEGIN
	OPEN c1;
		FETCH c1 INTO x_rowid;
	IF (c1%NOTFOUND) THEN
	CLOSE c1;
    insert_row (
      x_rowid,
       X_igs_en_timeslot_prty_id,
       X_igs_en_timeslot_stup_id,
       X_priority_order,
       X_priority_value,
      x_mode );
     RETURN;
	END IF;
	   CLOSE c1;
update_row (
      x_rowid,
       x_igs_en_timeslot_prty_id,
       x_igs_en_timeslot_stup_id,
       x_priority_order,
       x_priority_value,
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
 DELETE FROM igs_en_timeslot_prty
 WHERE ROWID = x_rowid;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
after_dml (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
END delete_row;
END igs_en_timeslot_prty_pkg;

/
