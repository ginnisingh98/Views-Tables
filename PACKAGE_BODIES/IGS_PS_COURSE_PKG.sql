--------------------------------------------------------
--  DDL for Package Body IGS_PS_COURSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_COURSE_PKG" AS
  /* $Header: IGSPI03B.pls 115.7 2003/04/16 05:42:12 smanglm ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_PS_COURSE%RowType;
  new_references IGS_PS_COURSE%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_course_cd IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smvk         02-Sep-2002        Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
  ||                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  ----------------------------------------------------------------------------*/


    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_COURSE
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
    new_references.course_cd := x_course_cd;
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
	 Column_Name	IN VARCHAR2,
	 Column_Value 	IN VARCHAR2
	 )
	 AS
	 BEGIN

	IF column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.course_cd := column_value;
     END IF;
    IF upper(column_name) = 'COURSE_CD' OR
    column_name is null Then
   IF ( new_references.course_cd <> UPPER(new_references.course_cd) ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

  END Check_Constraints;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_PS_APPL_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_PE_ALTERNATV_EXT_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_PS_FEE_TRG_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_PS_RU_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_PS_VER_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_FI_FEE_AS_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_AS_NON_ENR_STDOT_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_PE_COURSE_EXCL_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_PR_OU_PS_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_EN_STDNT_PS_ATT_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    IGS_PR_STDNT_PR_PS_PKG.GET_FK_IGS_PS_COURSE (
      old_references.course_cd
      );

    igs_da_cnfg_req_typ_pkg.get_fk_igs_ps_course (
           x_course_cd   => old_references.course_cd
       );

    igs_da_req_wif_pkg.get_fk_igs_ps_course (
          x_course_cd => old_references.course_cd
       );
    igs_da_req_stdnts_pkg.get_fk_igs_ps_course (
          x_course_cd   => old_references.course_cd
       );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2
    )
  RETURN BOOLEAN AS
  /***************************************************************************************
   Change History
   WHO          WHEN            WHAT
   shtatiko     18-FEB-2003     Enh# 2797116, Removed FOR UPDATE NOWAIT clause is removed
                                from the cursor, cur_rowid.
  ***************************************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_COURSE
      WHERE    course_cd = x_course_cd;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (TRUE);
    ELSE
	Close cur_rowid;
      Return (FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_course_cd IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_course_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation ( new_references.course_cd ) THEN
	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	   IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF  Get_PK_For_Validation (new_references.course_cd ) THEN
	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
	Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_PS_COURSE
      where COURSE_CD = X_COURSE_CD;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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

Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  insert into IGS_PS_COURSE (
    COURSE_CD,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

After_DML (
	p_action => 'INSERT',
	x_rowid => X_ROWID
);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2
) AS
  cursor c1 is select ROWID
    from IGS_PS_COURSE
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  return;
end LOCK_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

Before_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);

  delete from IGS_PS_COURSE
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);

end DELETE_ROW;

end IGS_PS_COURSE_PKG;

/
