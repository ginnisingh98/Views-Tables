--------------------------------------------------------
--  DDL for Package Body IGS_PS_USEC_OCUR_REF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_USEC_OCUR_REF_PKG" AS
/* $Header: IGSPI0XB.pls 120.1 2005/06/29 03:30:50 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_usec_ocur_ref%RowType;
  new_references igs_ps_usec_ocur_ref%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_sec_occur_reference_id IN NUMBER DEFAULT NULL,
    x_unit_section_occurrence_id IN NUMBER DEFAULT NULL,
    x_reference_code_type IN VARCHAR2 DEFAULT NULL,
    x_reference_code IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_reference_code_desc IN VARCHAR2 DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_USEC_OCUR_REF
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_sec_occur_reference_id := x_unit_sec_occur_reference_id;
    new_references.unit_section_occurrence_id := x_unit_section_occurrence_id;
    new_references.reference_code_type := x_reference_code_type;
    new_references.reference_code := x_reference_code;
    new_references.reference_code_desc := x_reference_code_desc;
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

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
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




  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   smvk           31-Jan-2003     Bug # 2532094. Added the foreign key checking with igs_ge_ref_cd.
  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR cur_reference_cd_chk(cp_reference_cd_type igs_ge_ref_cd_type_all.reference_cd_type%TYPE) IS
  SELECT 'X'
  FROM   igs_ge_ref_cd_type_all
  WHERE  restricted_flag='Y'
  AND    reference_cd_type=cp_reference_cd_type;
  l_var  VARCHAR2(1);

  BEGIN

    IF (((old_references.unit_section_occurrence_id = new_references.unit_section_occurrence_id)) OR
        ((new_references.unit_section_occurrence_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Usec_Occurs_Pkg.Get_PK_For_Validation (
        		new_references.unit_section_occurrence_id
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    OPEN cur_reference_cd_chk(new_references.reference_code_type);
    FETCH cur_reference_cd_chk INTO l_var;
    IF cur_reference_cd_chk%FOUND THEN

      IF (((old_references.reference_code_type = new_references.reference_code_type) AND
           (old_references.reference_code = new_references.reference_code)) OR
          ((new_references.reference_code_type IS NULL) OR
           (new_references.reference_code IS NULL))) THEN
  	 NULL;
      ELSIF NOT igs_ge_ref_cd_pkg.get_uk_for_validation (
                          new_references.reference_code_type,
                          new_references.reference_code
          )  THEN
    	   Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
           IGS_GE_MSG_STACK.ADD;
 	   App_Exception.Raise_Exception;
      END IF;
    END IF;
    CLOSE cur_reference_cd_chk;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_sec_occur_reference_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_ocur_ref
      WHERE    unit_sec_occur_reference_id = x_unit_sec_occur_reference_id
      FOR UPDATE NOWAIT;

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
  END Get_PK_For_Validation;

  PROCEDURE Get_FK_Igs_Ps_Usec_Occurs (
    x_unit_section_occurrence_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_ocur_ref
      WHERE    unit_section_occurrence_id = x_unit_section_occurrence_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_USOR_USO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Usec_Occurs;



   PROCEDURE get_fk_igs_ge_ref_cd_type (
    x_reference_code_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :sarakshi
  Date Created By :8-May-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_usec_ocur_ref
      WHERE    reference_code_type = x_reference_code_type;

    lv_rowid cur_rowid%ROWTYPE;

 BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_USOR_RCT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ge_ref_cd_type;


   PROCEDURE get_ufk_igs_ge_ref_cd (
    x_reference_code_type IN VARCHAR2,
    x_reference_code IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :sarakshi
  Date Created By :8-May-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_usec_ocur_ref
      WHERE    reference_code_type = x_reference_code_type
      AND      reference_code = x_reference_code ;

    lv_rowid cur_rowid%ROWTYPE;

 BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_USOR_RC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ge_ref_cd;


-- Function for getting the UK
-- If the record exists for the parameters passed, then it returns TRUE
-- Else it returns false
FUNCTION Get_Uk_For_Validation (
    x_reference_code_type      IN  VARCHAR2,
    x_reference_code          IN  VARCHAR2,
    x_Unit_section_Occurrence_Id  IN NUMBER
    ) RETURN BOOLEAN AS
  CURSOR cur_uor IS
    SELECT ROWID
    FROM   IGS_PS_USEC_OCUR_REF
    WHERE  reference_code_type = x_reference_code_type AND
           reference_code          = x_reference_code AND
           Unit_section_Occurrence_Id = x_Unit_section_Occurrence_Id AND
           (l_rowid IS NULL OR rowid <> l_rowid);
  lv_row_id     cur_uor%ROWTYPE;
 BEGIN

    OPEN cur_uor;
    FETCH cur_uor INTO lv_row_id;
    IF cur_uor%FOUND THEN
      CLOSE cur_uor;
      RETURN(TRUE);
    ELSE
      CLOSE cur_uor;
      RETURN(FALSE);
    END IF;

 END Get_Uk_For_Validation;

 -- Procedure for checking the uniqueness
PROCEDURE Check_Uniqueness AS
BEGIN
  IF Get_Uk_For_Validation(x_reference_code_type                 => new_references.reference_code_type,
                           x_reference_code          => new_references.reference_code,
                           x_Unit_section_Occurrence_Id => new_references.Unit_section_Occurrence_Id) THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END Check_Uniqueness;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_sec_occur_reference_id IN NUMBER DEFAULT NULL,
    x_unit_section_occurrence_id IN NUMBER DEFAULT NULL,
    x_reference_code_type IN VARCHAR2 DEFAULT NULL,
    x_reference_code IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_reference_code_desc IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_sec_occur_reference_id,
      x_unit_section_occurrence_id,
      x_reference_code_type,
      x_reference_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_reference_code_desc
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.unit_sec_occur_reference_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.unit_sec_occur_reference_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c_occurs(cp_unit_section_occurrence_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
    SELECT uso.unit_section_occurrence_id
    FROM igs_ps_usec_occurs_all uso
    WHERE (uso.schedule_status IS NOT NULL AND uso.schedule_status NOT IN ('PROCESSING','USER_UPDATE'))
    AND uso.no_set_day_ind ='N'
    AND uso.unit_section_occurrence_id=cp_unit_section_occurrence_id;

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      --Update the schedule status of the occurrence to USER_UPDATE if inserting a record
      FOR l_occurs_rec IN c_occurs(new_references.unit_section_occurrence_id) LOOP
        igs_ps_usec_schedule.update_occurrence_status(l_occurs_rec.unit_section_occurrence_id,'USER_UPDATE','N');
      END LOOP;

    ELSIF (p_action = 'UPDATE') THEN
      --Update the schedule status of the occurrence to USER_UPDATE if updating a record
      FOR l_occurs_rec IN c_occurs(new_references.unit_section_occurrence_id) LOOP
        igs_ps_usec_schedule.update_occurrence_status(l_occurs_rec.unit_section_occurrence_id,'USER_UPDATE','N');
      END LOOP;


    ELSIF (p_action = 'DELETE') THEN
      --Update the schedule status of the occurrence to USER_UPDATE if updating a record
      FOR l_occurs_rec IN c_occurs(old_references.unit_section_occurrence_id) LOOP
        igs_ps_usec_schedule.update_occurrence_status(l_occurs_rec.unit_section_occurrence_id,'USER_UPDATE','N');
      END LOOP;

    END IF;

    l_rowid:=NULL;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SEC_OCCUR_REFERENCE_ID IN OUT NOCOPY NUMBER,
       x_UNIT_SECTION_OCCURRENCE_ID IN NUMBER,
       x_REFERENCE_CODE_TYPE IN VARCHAR2,
       x_REFERENCE_CODE IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R'  ,
       x_reference_code_desc IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_USEC_OCUR_REF
             where                 UNIT_SEC_OCCUR_REFERENCE_ID= X_UNIT_SEC_OCCUR_REFERENCE_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE = 'R') then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   SELECT
     igs_ps_usec_occur_ref_s.nextval
   INTO
     X_UNIT_SEC_OCCUR_REFERENCE_ID
   FROM dual;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_unit_sec_occur_reference_id=>X_UNIT_SEC_OCCUR_REFERENCE_ID,
 	       x_unit_section_occurrence_id=>X_UNIT_SECTION_OCCURRENCE_ID,
 	       x_reference_code_type=>X_REFERENCE_CODE_TYPE,
 	       x_reference_code=>X_REFERENCE_CODE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_reference_code_desc=>x_reference_code_desc);
     insert into IGS_PS_USEC_OCUR_REF (
		UNIT_SEC_OCCUR_REFERENCE_ID
		,UNIT_SECTION_OCCURRENCE_ID
		,REFERENCE_CODE_TYPE
		,REFERENCE_CODE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
                ,REFERENCE_CODE_DESC
        ) values  (
	        NEW_REFERENCES.UNIT_SEC_OCCUR_REFERENCE_ID
	        ,NEW_REFERENCES.UNIT_SECTION_OCCURRENCE_ID
	        ,NEW_REFERENCES.REFERENCE_CODE_TYPE
	        ,NEW_REFERENCES.REFERENCE_CODE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
                ,X_REFERENCE_CODE_DESC
);
		open c;
		 fetch c into X_ROWID;
 		if (c%notfound) then
		close c;
 	     raise no_data_found;
		end if;
 		close c;
    After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
end INSERT_ROW;
 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SEC_OCCUR_REFERENCE_ID IN NUMBER,
       x_UNIT_SECTION_OCCURRENCE_ID IN NUMBER,
       x_REFERENCE_CODE_TYPE IN VARCHAR2,
       x_REFERENCE_CODE IN VARCHAR2  ,
       x_reference_code_desc IN VARCHAR2 DEFAULT NULL
) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      UNIT_SECTION_OCCURRENCE_ID
,      REFERENCE_CODE_TYPE
,      REFERENCE_CODE
,      REFERENCE_CODE_DESC
    from IGS_PS_USEC_OCUR_REF
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
if ( (  tlinfo.UNIT_SECTION_OCCURRENCE_ID = X_UNIT_SECTION_OCCURRENCE_ID)
  AND (tlinfo.REFERENCE_CODE_TYPE = X_REFERENCE_CODE_TYPE)
  AND (tlinfo.REFERENCE_CODE = X_REFERENCE_CODE)
  AND ((tlinfo.reference_code_desc= x_reference_code_desc)
           OR ((tlinfo.reference_code_desc IS NULL)
               AND (x_reference_code_desc IS NULL)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SEC_OCCUR_REFERENCE_ID IN NUMBER,
       x_UNIT_SECTION_OCCURRENCE_ID IN NUMBER,
       x_REFERENCE_CODE_TYPE IN VARCHAR2,
       x_REFERENCE_CODE IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R' ,
       x_reference_code_desc IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE = 'R') then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_unit_sec_occur_reference_id=>X_UNIT_SEC_OCCUR_REFERENCE_ID,
 	       x_unit_section_occurrence_id=>X_UNIT_SECTION_OCCURRENCE_ID,
 	       x_reference_code_type=>X_REFERENCE_CODE_TYPE,
 	       x_reference_code=>X_REFERENCE_CODE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_reference_code_desc=>x_reference_code_desc);
   update IGS_PS_USEC_OCUR_REF set
      UNIT_SECTION_OCCURRENCE_ID =  NEW_REFERENCES.UNIT_SECTION_OCCURRENCE_ID,
      REFERENCE_CODE_TYPE =  NEW_REFERENCES.REFERENCE_CODE_TYPE,
      REFERENCE_CODE =  NEW_REFERENCES.REFERENCE_CODE,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      REFERENCE_CODE_DESC = NEW_REFERENCES.REFERENCE_CODE_DESC
	  where ROWID = X_ROWID;
	if (sql%notfound) then
		raise no_data_found;
	end if;

 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SEC_OCCUR_REFERENCE_ID IN OUT NOCOPY NUMBER,
       x_UNIT_SECTION_OCCURRENCE_ID IN NUMBER,
       x_REFERENCE_CODE_TYPE IN VARCHAR2,
       x_REFERENCE_CODE IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R' ,
       x_reference_code_desc IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PS_USEC_OCUR_REF
             where     UNIT_SEC_OCCUR_REFERENCE_ID= X_UNIT_SEC_OCCUR_REFERENCE_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_UNIT_SEC_OCCUR_REFERENCE_ID,
       X_UNIT_SECTION_OCCURRENCE_ID,
       X_REFERENCE_CODE_TYPE,
       X_REFERENCE_CODE,
       X_MODE,
       X_REFERENCE_CODE_DESC );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_UNIT_SEC_OCCUR_REFERENCE_ID,
       X_UNIT_SECTION_OCCURRENCE_ID,
       X_REFERENCE_CODE_TYPE,
       X_REFERENCE_CODE,
       X_MODE,
       X_REFERENCE_CODE_DESC );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 delete from IGS_PS_USEC_OCUR_REF
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ps_usec_ocur_ref_pkg;

/
