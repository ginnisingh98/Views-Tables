--------------------------------------------------------
--  DDL for Package Body IGR_I_PKG_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_PKG_ITEM_PKG" AS
/* $Header: IGSRH03B.pls 120.0 2005/06/01 16:02:39 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGR_I_PKG_ITEM%RowType;
  new_references IGR_I_PKG_ITEM%RowType;


  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_package_item_id IN NUMBER DEFAULT NULL,
    x_publish_ss_ind in VARCHAR2 DEFAULT NULL ,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGR_I_PKG_ITEM
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.package_item_id := x_package_item_id;
    new_references.publish_ss_ind := x_publish_ss_ind;
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

  END Set_Column_Values;



PROCEDURE check_constraints (
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 ) as

  BEGIN

    -- The following code checks for check constraints on the Columns.

    IF column_name is NULL THEN
        NULL;
    ELSIF  UPPER(column_name) = 'PACKAGE_ITEM_ID' THEN
        new_references.package_item_id  := column_value;
    ELSIF  UPPER(column_name) = 'PUBLISH_SS_IND' THEN
        new_references.publish_ss_ind  := column_value;
   END IF;


    IF ((UPPER (column_name) = 'PACKAGE_ITEM_ID') OR (column_name IS NULL)) THEN
      IF (new_references.package_item_id <> UPPER (new_references.package_item_id)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'PUBLISH_SS_IND') OR (column_name IS NULL)) THEN
      IF new_references.publish_ss_ind  NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


  END check_constraints;

  PROCEDURE check_parent_existance AS
  BEGIN
    DECLARE

     CURSOR c_ams_deliverables (p_package_item_id igr_i_pkg_item.package_item_id%TYPE) IS
           SELECT deliverable_id
	   FROM ams_deliverables_all_b
	   WHERE deliverable_id = p_package_item_id;
     l_deliverable_id AMS_DELIVERABLES_ALL_B.deliverable_id%TYPE;
    BEGIN

    IF (((old_references.package_item_id  = new_references.package_item_id)) OR
        ((new_references.package_item_id  IS NULL))) THEN
      NULL;
    ELSE
      OPEN c_ams_deliverables(new_references.package_item_id);
      FETCH c_ams_deliverables INTO l_deliverable_id;
      CLOSE c_ams_deliverables;
      IF  c_ams_deliverables%NOTFOUND THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
             IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
      END IF;
    END IF;
    END;
  END check_parent_existance;

 PROCEDURE Check_Child_Existance AS
 /*
  ||  Created By : adarsh.padegal@oracle.com
  ||  Created On : 06-MAR-2005
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
 	 igr_i_inquiry_types_pkg.get_fk_igr_i_pkg_item (old_references.package_item_id);
	 igr_i_pkgitm_assign_pkg.get_fk_igr_i_pkg_item (old_references.package_item_id);

  END Check_Child_Existance;

  FUNCTION get_pk_for_validation (
    x_package_item_id IN NUMBER DEFAULT NULL
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_PKG_ITEM
      WHERE    package_item_id = x_package_item_id;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN
       Close cur_rowid;
       Return(TRUE);
    ELSE
       Close cur_rowid;
       Return(FALSE);
    END IF;

  END get_pk_for_validation;

  PROCEDURE get_fk_ams_deliverable_all_b (
     x_package_item_id IN NUMBER DEFAULT NULL
    ) AS

    CURSOR cur_rowid IS
      SELECT  rowid
      FROM     IGR_I_PKG_ITEM
      WHERE   package_item_id = x_package_item_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_IN_EPI_AM_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END get_fk_ams_deliverable_all_b;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_package_item_id IN NUMBER DEFAULT NULL,
    x_publish_ss_ind in VARCHAR2 DEFAULT NULL ,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  BEGIN
    Set_Column_Values (
    p_action,
    x_rowid,
    x_package_item_id,
    x_publish_ss_ind,
    x_creation_date,
    x_created_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login
  ) ;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
        IF get_pk_for_validation(new_references.package_item_id) THEN
 		Fnd_message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
	        IGS_GE_MSG_STACK.ADD;
 		App_Exception.Raise_Exception;
	END IF;

	Check_Constraints;
   ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
       Check_Constraints;
       Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
    	IF  get_pk_for_validation (new_references.package_item_id) THEN
		          Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
		          IGS_GE_MSG_STACK.ADD;
		          App_Exception.Raise_Exception;
        END IF;
        check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
     		  check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
	 Check_Child_Existance;
    END IF;
  END Before_DML;

  PROCEDURE insert_row (
  x_rowid IN OUT NOCOPY VARCHAR2,
  x_package_item_id IN NUMBER DEFAULT NULL,
  x_publish_ss_ind  IN VARCHAR2 DEFAULT NULL,
  x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS
    CURSOR C IS
      SELECT rowid FROM IGR_I_PKG_ITEM
      WHERE package_item_id = x_package_item_id;
    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;
  begin
    x_last_update_date := SYSDATE;
    if(x_mode = 'I') then
      x_last_updated_by := 1;
      x_last_update_login := 0;
    elsif (x_mode = 'R') then
      x_last_updated_by := FND_GLOBAL.USER_ID;
      if x_last_updated_by is NULL then
        x_last_updated_by := -1;
      end if;
      x_last_update_login :=FND_GLOBAL.LOGIN_ID;
      if x_last_update_login is NULL then
        x_last_update_login := -1;
      end if;
   else
     FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
     IGS_GE_MSG_STACK.ADD;
     app_exception.raise_exception;
   end if;

  Before_DML(
    p_action=>'INSERT',
    x_rowid=>X_ROWID,
    x_publish_ss_ind => x_publish_ss_ind ,
    x_package_item_id => x_package_item_id,
    x_creation_date=>x_last_update_date,
    x_created_by=>x_last_updated_by,
    x_last_update_date=>x_last_update_date,
    x_last_updated_by=>x_last_updated_by,
    x_last_update_login=>x_last_update_login
   );
  insert into IGR_I_PKG_ITEM (
    package_item_id,
    publish_ss_ind,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) values (
    new_references.package_item_id,
    new_references.publish_ss_ind ,
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
      raise no_data_found;
    END IF;
    CLOSE c;
  END insert_row;


  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_package_item_id IN NUMBER DEFAULT NULL,
    x_publish_ss_ind IN VARCHAR2 DEFAULT NULL
  ) AS
  CURSOR c1 IS
      SELECT  package_item_id,
                     publish_ss_ind
      FROM     igr_i_pkg_item
      WHERE   rowid = x_rowid;
    tlinfo c1%rowtype;

BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    CLOSE c1;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;

  IF ( (tlinfo.PACKAGE_ITEM_ID = X_PACKAGE_ITEM_ID)
      AND  ((tlinfo.PUBLISH_SS_IND = X_PUBLISH_SS_IND)
           OR ((tlinfo.PUBLISH_SS_IND is null)
               AND (X_PUBLISH_SS_IND is null)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
  RETURN;
END lock_row;

PROCEDURE update_row (
 x_rowid IN VARCHAR2,
 x_package_item_id IN NUMBER DEFAULT NULL,
 x_publish_ss_ind  IN VARCHAR2 DEFAULT NULL,
 x_mode IN VARCHAR2 DEFAULT 'R'
) AS
    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;
BEGIN
  x_last_update_date := SYSDATE;
  IF(x_mode = 'I') THEN
    x_last_updated_by := 1;
    x_last_update_login := 0;
  ELSIF (x_mode = 'R') THEN
    x_last_updated_by := FND_GLOBAL.USER_ID;
    IF x_last_updated_by is NULL THEN
      x_last_updated_by := -1;
    END IF;
    x_last_update_login :=FND_GLOBAL.LOGIN_ID;
    IF x_last_update_login IS NULL THEN
      x_last_update_login := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;

  Before_DML(
    p_action=>'UPDATE',
    x_rowid=>X_ROWID,
    x_publish_ss_ind => X_PUBLISH_SS_IND ,
    x_package_item_id => X_PACKAGE_ITEM_ID,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  update IGR_I_PKG_ITEM set
    package_item_id = new_references.package_item_id,
    publish_ss_ind = new_references.publish_ss_ind,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login
  WHERE rowid = x_rowid  ;
    IF (sql%NOTFOUND) THEN
      raise no_data_found;
    END IF;
  END update_row;

 PROCEDURE add_row (
  x_rowid IN OUT NOCOPY VARCHAR2,
  x_package_item_id IN NUMBER DEFAULT NULL,
  x_publish_ss_ind  IN VARCHAR2 DEFAULT NULL,
  x_mode IN VARCHAR2 DEFAULT 'R'
) AS
  CURSOR c1 IS
     SELECT rowid FROM IGR_I_PKG_ITEM
     WHERE package_item_id = x_package_item_id;
BEGIN
  OPEN c1;
  FETCH c1 INTO x_rowid;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    insert_row (
     x_rowid,
     x_package_item_id,
     x_publish_ss_ind,
     x_mode);
    RETURN;
  END IF;
  CLOSE c1;
  update_row (
   x_rowid,
   x_package_item_id,
   x_publish_ss_ind,
   x_mode);
END add_row;

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  BEGIN
  before_dml(
    p_action => 'DELETE',
    x_rowid => x_rowid
    );
   DELETE FROM IGR_I_PKG_ITEM
   WHERE rowid = x_rowid;
   IF (sql%NOTFOUND) THEN
     raise no_data_found;
   END IF;

  END delete_row;


END IGR_I_PKG_ITEM_PKG;

/
