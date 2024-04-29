--------------------------------------------------------
--  DDL for Package Body IGS_EN_OR_UNIT_WLST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_OR_UNIT_WLST_PKG" AS
/* $Header: IGSEI33B.pls 115.10 2003/09/18 03:42:40 svanukur ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_en_or_unit_wlst_all%RowType;
  new_references igs_en_or_unit_wlst_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_wlst_id IN NUMBER DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_max_stud_per_wlst IN NUMBER DEFAULT NULL,
    x_smtanus_wlst_unit_enr_alwd IN VARCHAR2 DEFAULT NULL,
    x_asses_chrg_for_wlst_stud IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER  DEFAULT NULL,
    x_closed_flag IN VARCHAR2 DEFAULT 'N'
  ) AS

  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_OR_UNIT_WLST_ALL
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
    new_references.org_unit_wlst_id := x_org_unit_wlst_id;
    new_references.org_unit_cd := x_org_unit_cd;
    new_references.start_dt := x_start_dt;
    new_references.cal_type := x_cal_type;
    new_references.max_stud_per_wlst := x_max_stud_per_wlst;
    new_references.smtanus_wlst_unit_enr_alwd := x_smtanus_wlst_unit_enr_alwd;
    new_references.asses_chrg_for_wlst_stud := x_asses_chrg_for_wlst_stud;
    new_references.closed_flag := x_closed_flag;
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
    new_references.org_id := x_org_id ;
  END Set_Column_Values;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;

      ELSIF  UPPER(column_name) = 'ASSES_CHRG_FOR_WLST_STUD'  THEN
        new_references.asses_chrg_for_wlst_stud := column_value;
      ELSIF  UPPER(column_name) = 'SMTANUS_WLST_UNIT_ENR_ALWD'  THEN
        new_references.smtanus_wlst_unit_enr_alwd := column_value;
        NULL;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'ASSES_CHRG_FOR_WLST_STUD' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.asses_chrg_for_wlst_stud IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'SMTANUS_WLST_UNIT_ENR_ALWD' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.smtanus_wlst_unit_enr_alwd IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.cal_type
    		,new_references.org_unit_cd
    		,new_references.start_dt
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.org_unit_cd = new_references.org_unit_cd) AND
         (old_references.start_dt = new_references.start_dt)) OR
        ((new_references.org_unit_cd IS NULL) OR
         (new_references.start_dt IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Or_Unit_Pkg.Get_PK_For_Validation (
        		new_references.org_unit_cd,
         		 new_references.start_dt
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;


   IF (old_references.cal_type = new_references.cal_type)  OR
        (new_references.cal_type IS NULL)    THEN

      NULL;
    ELSIF NOT Igs_Ca_Type_Pkg.Get_PK_For_Validation (
        		new_references.cal_type
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_En_Orun_Wlst_Pri_Pkg.Get_FK_Igs_En_Or_Unit_Wlst (
      old_references.org_unit_wlst_id
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_org_unit_wlst_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_or_unit_wlst_all
      WHERE    org_unit_wlst_id = x_org_unit_wlst_id
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

  FUNCTION Get_UK_For_Validation (
    x_cal_type IN VARCHAR2,
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_or_unit_wlst_all
      WHERE    cal_type = x_cal_type
      AND      org_unit_cd = x_org_unit_cd
      AND      start_dt = x_start_dt 	and      ((l_rowid is null) or (rowid <> l_rowid))

      ;
    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK_For_Validation ;
  PROCEDURE Get_FK_Igs_Or_Unit (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) AS

  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_or_unit_wlst_all
      WHERE    org_unit_cd = x_org_unit_cd
      AND      start_dt = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_OUW_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Or_Unit;

  PROCEDURE Get_FK_Igs_Ca_Inst (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  svanukur       02-sep-2003   commenting since sequence_number is obsoleted
                               as part of waitlist enhancement build 3052426
                               and to avoid dependency on PSP build #3045007
  ***************************************************************/

   /* CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_or_unit_wlst_all
      WHERE    cal_type = x_cal_type
      AND      sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_OUW_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid; */
    BEGIN
    NULL;

  END Get_FK_Igs_Ca_Inst;

  PROCEDURE Get_FK_Igs_Ca_Type (
    x_cal_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  svanukur       02-sep-2003   created as part of waitlist enhancement build 3052426
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_or_unit_wlst_all
      WHERE    cal_type = x_cal_type ;


    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_OUW_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
   END Get_FK_Igs_Ca_Type;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_org_unit_wlst_id IN NUMBER ,
    x_org_unit_cd IN VARCHAR2 ,
    x_start_dt IN DATE ,
    x_cal_type IN VARCHAR2 ,
    x_max_stud_per_wlst IN NUMBER ,
    x_smtanus_wlst_unit_enr_alwd IN VARCHAR2 ,
    x_asses_chrg_for_wlst_stud IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_closed_flag IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_unit_wlst_id,
      x_org_unit_cd,
      x_start_dt,
      x_cal_type,
      x_max_stud_per_wlst,
      x_smtanus_wlst_unit_enr_alwd,
      x_asses_chrg_for_wlst_stud,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_closed_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.org_unit_wlst_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.

      IF Get_PK_For_Validation (
    		new_references.org_unit_wlst_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
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

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_UNIT_WLST_ID IN OUT NOCOPY NUMBER,
       x_ORG_UNIT_CD IN VARCHAR2,
       x_START_DT IN DATE,
       x_CAL_TYPE IN VARCHAR2,
       x_MAX_STUD_PER_WLST IN NUMBER,
       x_SMTANUS_WLST_UNIT_ENR_ALWD IN VARCHAR2,
       x_ASSES_CHRG_FOR_WLST_STUD IN VARCHAR2,
      X_MODE in VARCHAR2  ,
    x_org_id IN NUMBER ,
    x_closed_flag in VARCHAR2
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_EN_OR_UNIT_WLST_ALL
             where                 ORG_UNIT_WLST_ID= X_ORG_UNIT_WLST_ID
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
   SELECT IGS_EN_OR_UNIT_WLST_S.NEXTVAL
   INTO x_org_unit_wlst_id
   FROM dual;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_org_unit_wlst_id=>X_ORG_UNIT_WLST_ID,
 	       x_org_unit_cd=>X_ORG_UNIT_CD,
 	       x_start_dt=>X_START_DT,
 	       x_cal_type=>X_CAL_TYPE,
 	       x_max_stud_per_wlst=>X_MAX_STUD_PER_WLST,
 	       x_smtanus_wlst_unit_enr_alwd=>X_SMTANUS_WLST_UNIT_ENR_ALWD,
 	       x_asses_chrg_for_wlst_stud=>X_ASSES_CHRG_FOR_WLST_STUD,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_org_id => igs_ge_gen_003.get_org_id,
               x_closed_flag => X_CLOSED_FLAG);
     insert into IGS_EN_OR_UNIT_WLST_ALL (
		ORG_UNIT_WLST_ID
		,ORG_UNIT_CD
		,START_DT
		,CAL_TYPE
		,MAX_STUD_PER_WLST
		,SMTANUS_WLST_UNIT_ENR_ALWD
		,ASSES_CHRG_FOR_WLST_STUD
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN,
                 org_id,
                 closed_flag
        ) values  (
	        NEW_REFERENCES.ORG_UNIT_WLST_ID
	        ,NEW_REFERENCES.ORG_UNIT_CD
	        ,NEW_REFERENCES.START_DT
	        ,NEW_REFERENCES.CAL_TYPE
	        ,NEW_REFERENCES.MAX_STUD_PER_WLST
	        ,NEW_REFERENCES.SMTANUS_WLST_UNIT_ENR_ALWD
	        ,NEW_REFERENCES.ASSES_CHRG_FOR_WLST_STUD
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN,
                 NEW_REFERENCES.org_id ,
                 NEW_REFERENCES.closed_flag
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
       x_ORG_UNIT_WLST_ID IN NUMBER,
       x_ORG_UNIT_CD IN VARCHAR2,
       x_START_DT IN DATE,
       x_CAL_TYPE IN VARCHAR2,
       x_MAX_STUD_PER_WLST IN NUMBER,
       x_SMTANUS_WLST_UNIT_ENR_ALWD IN VARCHAR2,
       x_ASSES_CHRG_FOR_WLST_STUD IN VARCHAR2,
       x_closed_flag IN VARCHAR2) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      ORG_UNIT_CD
,      START_DT
,      CAL_TYPE
,      MAX_STUD_PER_WLST
,      SMTANUS_WLST_UNIT_ENR_ALWD
,      ASSES_CHRG_FOR_WLST_STUD
,     CLOSED_FLAG
    from IGS_EN_OR_UNIT_WLST_ALL
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
if ( (  tlinfo.ORG_UNIT_CD = X_ORG_UNIT_CD)
  AND (tlinfo.START_DT = X_START_DT)
  AND (tlinfo.CAL_TYPE = X_CAL_TYPE)
  AND ((tlinfo.MAX_STUD_PER_WLST = X_MAX_STUD_PER_WLST)
 	    OR ((tlinfo.MAX_STUD_PER_WLST is null)
		AND (X_MAX_STUD_PER_WLST is null)))
  AND (tlinfo.SMTANUS_WLST_UNIT_ENR_ALWD = X_SMTANUS_WLST_UNIT_ENR_ALWD)
  AND (tlinfo.ASSES_CHRG_FOR_WLST_STUD = X_ASSES_CHRG_FOR_WLST_STUD)
  AND (tlinfo.CLOSED_FLAG = X_CLOSED_FLAG)
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
       x_ORG_UNIT_WLST_ID IN NUMBER,
       x_ORG_UNIT_CD IN VARCHAR2,
       x_START_DT IN DATE,
       x_CAL_TYPE IN VARCHAR2,
       x_MAX_STUD_PER_WLST IN NUMBER,
       x_SMTANUS_WLST_UNIT_ENR_ALWD IN VARCHAR2,
       x_ASSES_CHRG_FOR_WLST_STUD IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
      x_closed_flag IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
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
 	       x_org_unit_wlst_id=>X_ORG_UNIT_WLST_ID,
 	       x_org_unit_cd=>X_ORG_UNIT_CD,
 	       x_start_dt=>X_START_DT,
 	       x_cal_type=>X_CAL_TYPE,
 	       x_max_stud_per_wlst=>X_MAX_STUD_PER_WLST,
 	       x_smtanus_wlst_unit_enr_alwd=>X_SMTANUS_WLST_UNIT_ENR_ALWD,
 	       x_asses_chrg_for_wlst_stud=>X_ASSES_CHRG_FOR_WLST_STUD,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_closed_flag => X_CLOSED_FLAG);
   update IGS_EN_OR_UNIT_WLST_ALL set
      ORG_UNIT_CD =  NEW_REFERENCES.ORG_UNIT_CD,
      START_DT =  NEW_REFERENCES.START_DT,
      CAL_TYPE =  NEW_REFERENCES.CAL_TYPE,
      MAX_STUD_PER_WLST =  NEW_REFERENCES.MAX_STUD_PER_WLST,
      SMTANUS_WLST_UNIT_ENR_ALWD =  NEW_REFERENCES.SMTANUS_WLST_UNIT_ENR_ALWD,
      ASSES_CHRG_FOR_WLST_STUD =  NEW_REFERENCES.ASSES_CHRG_FOR_WLST_STUD,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        CLOSED_FLAG = NEW_REFERENCES.CLOSED_FLAG
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
       x_ORG_UNIT_WLST_ID IN OUT NOCOPY NUMBER,
       x_ORG_UNIT_CD IN VARCHAR2,
       x_START_DT IN DATE,
       x_CAL_TYPE IN VARCHAR2,
       x_MAX_STUD_PER_WLST IN NUMBER,
       x_SMTANUS_WLST_UNIT_ENR_ALWD IN VARCHAR2,
       x_ASSES_CHRG_FOR_WLST_STUD IN VARCHAR2,
      X_MODE in VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_closed_flag IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_EN_OR_UNIT_WLST_ALL
             where     ORG_UNIT_WLST_ID= X_ORG_UNIT_WLST_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_ORG_UNIT_WLST_ID,
       X_ORG_UNIT_CD,
       X_START_DT,
       X_CAL_TYPE,
       X_MAX_STUD_PER_WLST,
       X_SMTANUS_WLST_UNIT_ENR_ALWD,
       X_ASSES_CHRG_FOR_WLST_STUD,
      X_MODE ,
    x_org_id,
    X_CLOSED_FLAG);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_ORG_UNIT_WLST_ID,
       X_ORG_UNIT_CD,
       X_START_DT,
       X_CAL_TYPE,
       X_MAX_STUD_PER_WLST,
       X_SMTANUS_WLST_UNIT_ENR_ALWD,
       X_ASSES_CHRG_FOR_WLST_STUD,
      X_MODE,
      X_CLOSED_FLAG);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
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
 delete from IGS_EN_OR_UNIT_WLST_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_en_or_unit_wlst_pkg;

/
