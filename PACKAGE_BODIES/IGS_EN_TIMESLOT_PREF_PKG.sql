--------------------------------------------------------
--  DDL for Package Body IGS_EN_TIMESLOT_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_TIMESLOT_PREF_PKG" AS
/* $Header: IGSEI40B.pls 115.10 2003/02/24 11:02:51 npalanis ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_en_timeslot_pref%ROWTYPE;
  new_references igs_en_timeslot_pref%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_igs_en_timeslot_pref_id IN NUMBER DEFAULT NULL,
    x_igs_en_timeslot_prty_id IN NUMBER DEFAULT NULL,
    x_preference_order IN NUMBER DEFAULT NULL,
    x_preference_code IN VARCHAR2 DEFAULT NULL,
    x_preference_version IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL
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
      FROM     IGS_EN_TIMESLOT_PREF
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
    new_references.igs_en_timeslot_pref_id := x_igs_en_timeslot_pref_id;
    new_references.igs_en_timeslot_prty_id := x_igs_en_timeslot_prty_id;
    new_references.preference_order := x_preference_order;
    new_references.preference_code := x_preference_code;
    new_references.preference_version := x_preference_version;
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
    new_references.sequence_number := x_sequence_number;

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
    		new_references.igs_en_timeslot_prty_id
    		,new_references.preference_code
    		,new_references.preference_version
    		,new_references.sequence_number
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

    IF (((old_references.igs_en_timeslot_prty_id = new_references.igs_en_timeslot_prty_id)) OR
        ((new_references.igs_en_timeslot_prty_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_timeslot_prty_pkg.get_pk_for_validation (
        		new_references.igs_en_timeslot_prty_id
        )  THEN
	 fnd_message.set_name ('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
 	 app_exception.raise_exception;
    END IF;

  END check_parent_existance;

 FUNCTION get_pk_for_validation (
   x_igs_en_timeslot_pref_id IN NUMBER
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
      FROM     igs_en_timeslot_pref
      WHERE    igs_en_timeslot_pref_id = x_igs_en_timeslot_pref_id
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
   x_igs_en_timeslot_prty_id IN NUMBER,
    x_preference_code IN VARCHAR2,
    x_preference_version IN NUMBER,
    x_sequence_number IN NUMBER   ) RETURN BOOLEAN AS

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
      FROM     igs_en_timeslot_pref
      WHERE    igs_en_timeslot_prty_id = x_igs_en_timeslot_prty_id
      AND      preference_code = x_preference_code
      AND      ((preference_version IS NULL and x_preference_version IS NULL)
                OR preference_version = x_preference_version)
      AND      ((sequence_number IS NULL and x_sequence_number IS NULL)
                OR sequence_number = x_sequence_number)
      AND      ((l_rowid is null) or (rowid <> l_rowid))

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

 PROCEDURE get_fk_igs_en_timeslot_prty (
   x_igs_en_timeslot_prty_id IN NUMBER
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
      FROM     igs_en_timeslot_pref
      WHERE    igs_en_timeslot_prty_id = x_igs_en_timeslot_prty_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_CANNOT_DEL_PRIOR');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_timeslot_prty;

  PROCEDURE BeforeInsertUpdate(p_inserting BOOLEAN , p_updating BOOLEAN) AS
  p_message_name VARCHAR2(30);
  CURSOR grp_id_cur is select group_id from igs_pe_persid_group_all
  WHERE group_cd = new_references.preference_code;
  l_group_id igs_pe_persid_group_all.group_id%TYPE;
  BEGIN
   IF ( p_inserting = TRUE OR (p_updating = TRUE AND new_references.preference_code <> old_references.preference_code ) ) THEN
    OPEN grp_id_cur;
    FETCH grp_id_cur INTO l_group_id;
    CLOSE grp_id_cur;
    IF  NOT IGS_PE_PERSID_GROUP_PKG.val_persid_group(l_group_id,p_message_name) THEN
        Fnd_Message.Set_Name('IGS', p_message_name);
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
   END IF;
  END BeforeInsertUpdate;

 PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_igs_en_timeslot_pref_id IN NUMBER DEFAULT NULL,
    x_igs_en_timeslot_prty_id IN NUMBER DEFAULT NULL,
    x_preference_order IN NUMBER DEFAULT NULL,
    x_preference_code IN VARCHAR2 DEFAULT NULL,
    x_preference_version IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL
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
      x_igs_en_timeslot_pref_id,
      x_igs_en_timeslot_prty_id,
      x_preference_order,
      x_preference_code,
      x_preference_version,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_sequence_number
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
      BeforeInsertUpdate(TRUE,FALSE);
      IF get_pk_for_validation(
          new_references.igs_en_timeslot_pref_id)  THEN
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
      BeforeInsertUpdate(FALSE,TRUE);
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      BeforeInsertUpdate(TRUE,FALSE);
      IF get_pk_for_validation (
    		new_references.igs_en_timeslot_pref_id)  THEN
	       fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
          igs_ge_msg_stack.add;
	       app_exception.raise_exception;
	     END IF;
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      BeforeInsertUpdate(FALSE,TRUE);
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
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
       x_igs_en_timeslot_pref_id IN OUT NOCOPY NUMBER,
       x_igs_en_timeslot_prty_id IN NUMBER,
       x_preference_order IN NUMBER,
       x_preference_code IN VARCHAR2,
       x_preference_version IN NUMBER,
      x_mode IN VARCHAR2 DEFAULT 'R',
      x_sequence_number IN NUMBER
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 ayedubat        16,JUL 2002    Removed the default NULL value of the in parameter,x_sequence_number for the bug fix:2464172
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR c IS SELECT ROWID FROM igs_en_timeslot_pref
             WHERE                 igs_en_timeslot_pref_id= x_igs_en_timeslot_pref_id
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

     select igs_en_timeslot_pref_s.nextval into x_igs_en_timeslot_pref_id from dual;

   before_dml(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_igs_en_timeslot_pref_id=>x_igs_en_timeslot_pref_id,
 	       x_igs_en_timeslot_prty_id=>x_igs_en_timeslot_prty_id,
 	       x_preference_order=>x_preference_order,
 	       x_preference_code=>x_preference_code,
 	       x_preference_version=>x_preference_version,
	       x_creation_date=> x_last_update_date,
	       x_created_by=> x_last_updated_by,
	       x_last_update_date=> x_last_update_date,
	       x_last_updated_by=> x_last_updated_by,
	       x_last_update_login=> x_last_update_login,
               x_sequence_number=> x_sequence_number
              );
     INSERT INTO igs_en_timeslot_pref (
		igs_en_timeslot_pref_id
		,igs_en_timeslot_prty_id
		,preference_order
		,preference_code
		,preference_version
	        ,creation_date
		,created_by
		,last_update_date
		,last_updated_by
		,last_update_login
                ,sequence_number
        ) VALUES  (
	        new_references.igs_en_timeslot_pref_id
	        ,new_references.igs_en_timeslot_prty_id
	        ,new_references.preference_order
	        ,new_references.preference_code
	        ,new_references.preference_version
	        ,x_last_update_date
		,x_last_updated_by
		,x_last_update_date
		,x_last_updated_by
		,x_last_update_login
                ,x_sequence_number
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
  x_igs_en_timeslot_pref_id IN NUMBER,
  x_igs_en_timeslot_prty_id IN NUMBER,
  x_preference_order IN NUMBER,
  x_preference_code IN VARCHAR2,
  x_preference_version IN NUMBER,
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

   CURSOR c1 IS SELECT
      igs_en_timeslot_prty_id
,      preference_order
,      preference_code
,      preference_version
,      sequence_number
  FROM igs_en_timeslot_pref
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
if (  (tlinfo.IGS_EN_TIMESLOT_PRTY_ID = X_IGS_EN_TIMESLOT_PRTY_ID)
  AND (tlinfo.PREFERENCE_ORDER = X_PREFERENCE_ORDER)
  AND (tlinfo.PREFERENCE_CODE = X_PREFERENCE_CODE)
  AND ((tlinfo.PREFERENCE_VERSION = X_PREFERENCE_VERSION)
 	    OR ((tlinfo.PREFERENCE_VERSION is null)
		AND (X_PREFERENCE_VERSION is null)))
  AND ((tlinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
 	    OR ((tlinfo.SEQUENCE_NUMBER is null)
		AND (X_SEQUENCE_NUMBER is null)))
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
    x_IGS_EN_TIMESLOT_PREF_ID IN NUMBER,
    x_IGS_EN_TIMESLOT_PRTY_ID IN NUMBER,
    x_PREFERENCE_ORDER IN NUMBER,
    x_PREFERENCE_CODE IN VARCHAR2,
    x_PREFERENCE_VERSION IN NUMBER,
    x_mode IN VARCHAR2 DEFAULT 'R',
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
 	       x_igs_en_timeslot_pref_id=>X_IGS_EN_TIMESLOT_PREF_ID,
 	       x_igs_en_timeslot_prty_id=>X_IGS_EN_TIMESLOT_PRTY_ID,
 	       x_preference_order=>X_PREFERENCE_ORDER,
 	       x_preference_code=>X_PREFERENCE_CODE,
 	       x_preference_version=>X_PREFERENCE_VERSION,
	       x_creation_date=>x_last_update_date,
	       x_created_by=>x_last_updated_by,
	       x_last_update_date=>x_last_update_date,
	       x_last_updated_by=>x_last_updated_by,
	       x_last_update_login=>x_last_update_login,
               x_sequence_number=>x_sequence_number
             );
   UPDATE igs_en_timeslot_pref SET
      igs_en_timeslot_prty_id =  NEW_REFERENCES.igs_en_timeslot_prty_id,
      preference_order =  NEW_REFERENCES.preference_order,
      preference_code =  NEW_REFERENCES.preference_code,
      preference_version =  NEW_REFERENCES.preference_version,
	last_update_date = x_last_update_date,
	last_updated_by = x_last_updated_by,
	last_update_login = x_last_update_login,
        sequence_number = x_sequence_number
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
       x_igs_en_timeslot_pref_id IN OUT NOCOPY NUMBER,
       x_igs_en_timeslot_prty_id IN NUMBER,
       x_preference_order IN NUMBER,
       x_preference_code IN VARCHAR2,
       x_preference_version IN NUMBER,
      x_mode IN VARCHAR2 DEFAULT 'R',
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

    CURSOR c1 IS SELECT ROWID FROM igs_en_timeslot_pref
             WHERE     igs_en_timeslot_pref_id= x_igs_en_timeslot_pref_id
;
BEGIN
	OPEN c1;
		FETCH c1 INTO x_rowid;
	IF (c1%NOTFOUND) THEN
	CLOSE c1;
    insert_row (
      x_rowid,
       X_igs_en_timeslot_pref_id,
       X_igs_en_timeslot_prty_id,
       X_preference_order,
       X_preference_code,
       X_preference_version,
      x_mode,
      x_sequence_number
     );
     RETURN;
	END IF;
	   CLOSE c1;
update_row (
      x_rowid,
       x_igs_en_timeslot_pref_id,
       x_igs_en_timeslot_prty_id,
       x_preference_order,
       x_preference_code,
       x_preference_version,
      x_mode,
      x_sequence_number
      );
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
 DELETE FROM igs_en_timeslot_pref
 WHERE ROWID = x_rowid;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
after_dml (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
END delete_row;
END igs_en_timeslot_pref_pkg;

/
