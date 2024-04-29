--------------------------------------------------------
--  DDL for Package Body IGS_AD_PRCS_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PRCS_CAT_PKG" AS
/* $Header: IGSAI09B.pls 115.14 2003/10/30 13:10:20 akadam ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_prcs_cat_all%RowType;
  new_references igs_ad_prcs_cat_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
		x_org_id IN NUMBER,
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_offer_response_offset IN NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    X_CLOSED_IND IN VARCHAR2
  ) AS

  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PRCS_CAT_ALL
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
		new_references.org_id := x_org_id;
    new_references.admission_cat := x_admission_cat;
    new_references.s_admission_process_type := x_s_admission_process_type;
    new_references.offer_response_offset := x_offer_response_offset;
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
    new_references.closed_ind := x_closed_ind;

  END Set_Column_Values;

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
	v_admission_cat	IGS_AD_PRCS_CAT_ALL.admission_cat%TYPE;
	v_message_name	varchar2(30);
  BEGIN
	-- Set the Admission Category value.
	IF p_deleting THEN
		v_admission_cat := old_references.admission_cat;
	ELSE
		v_admission_cat := new_references.admission_cat;
	END IF;
	-- Validate the admission category closed indicator.
	IF IGS_AD_VAL_ACCT.admp_val_ac_closed (
			v_admission_cat,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
  END BeforeRowInsertUpdateDelete1;



  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2,
		 Column_Value IN VARCHAR2) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'ADMISSION_CAT'  THEN
        new_references.admission_cat := column_value;
      ELSIF  UPPER(column_name) = 'S_ADMISSION_PROCESS_TYPE'  THEN
        new_references.s_admission_process_type := column_value;
      ELSIF upper(Column_name) = 'OFFER_RESPONSE_OFFSET' then
        new_references.offer_response_offset := IGS_GE_NUMBER.TO_NUM(column_value);

      END IF;



      IF  UPPER(Column_Name) = 'ADMISSION_CAT' OR
      		Column_Name IS NULL THEN
        IF new_references.ADMISSION_CAT <> UPPER(new_references.admission_cat) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF  UPPER(Column_Name) = 'S_ADMISSION_PROCESS_TYPE' OR
      		Column_Name IS NULL THEN
        IF new_references.S_ADMISSION_PROCESS_TYPE <> UPPER(new_references.s_admission_process_type) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF upper(column_name) = 'OFFER_RESPONSE_OFFSET' OR
     	column_name is null Then
     		IF new_references.offer_response_offset  < 1 OR
          		new_references.offer_response_offset > 99 Then
	    		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	    		IGS_GE_MSG_STACK.ADD;
          		App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.admission_cat = new_references.admission_cat)) OR
        ((new_references.admission_cat IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Cat_Pkg.Get_PK_For_Validation (
        		new_references.admission_cat ,
         'N')  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;


    IF (((old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
	IF  NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
         'ADMISSION_PROCESS_TYPE',
         new_references.s_admission_process_type
	) THEN
     		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     		IGS_GE_MSG_STACK.ADD;
     		App_Exception.Raise_Exception;
	 END IF;
    END IF;
  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  rghosh         04-oct-2002     added IGS_AD_SS_APPL_TYP_PKG.GET_FK_IGS_AD_PRCS_CA
				 since igs_ad_ss_appl_typ is a child of this table
				 as per bug 2599457
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
    IGS_AD_APPL_PKG.GET_FK_IGS_AD_PRCS_CAT (
      old_references.admission_cat,
      old_references.s_admission_process_type
      );

    IGS_AD_SS_APPL_TYP_PKG.GET_FK_IGS_AD_PRCS_CAT (
      old_references.admission_cat,
      old_references.s_admission_process_type
      );

    IGS_AD_PRD_AD_PRC_CA_PKG.GET_FK_IGS_AD_PRCS_CAT (
      old_references.admission_cat,
      old_references.s_admission_process_type
      );

    IGS_AD_PRCS_CAT_LTR_PKG.GET_FK_IGS_AD_PRCS_CAT (
      old_references.admission_cat,
      old_references.s_admission_process_type
      );

    IGS_AD_PRCS_CAT_STEP_PKG.GET_FK_IGS_AD_PRCS_CAT (
      old_references.admission_cat,
      old_references.s_admission_process_type
      );

    /**********Removed  by   RRENGARA
    Reason :  As a Part of Build Bug 2602096. Removed the call since this FK check is not needed.
    Igs_Ad_Interface_Ctl_Pkg.Get_FK_Igs_Ad_Prcs_Cat (
      old_references.admission_cat,
      old_references.s_admission_process_type
      );
    ***********************/

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_prcs_cat_all
      WHERE    admission_cat = x_admission_cat AND
               s_admission_process_type = x_s_admission_process_type AND
               closed_ind = NVL(x_closed_ind,closed_ind);

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

  PROCEDURE Get_FK_Igs_Ad_Cat (
    x_admission_cat IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRCS_CAT_ALL
      WHERE    admission_cat = x_admission_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APC_AC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Cat;


  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_admission_process_type IN VARCHAR2
    ) AS
 /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRCS_CAT_ALL
      WHERE    s_admission_process_type = x_s_admission_process_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APC_SAPT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
		x_ORG_ID IN NUMBER,
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_offer_response_offset IN NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_closed_ind IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
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
			x_org_id,
      x_admission_cat,
      x_s_admission_process_type,
      x_offer_response_offset,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_closed_ind
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      beforeRowInsertUpdateDelete1(p_inserting => TRUE);
	     IF Get_Pk_For_Validation(
    		new_references.admission_cat,
    		new_references.s_admission_process_type)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdateDelete1 (p_updating => TRUE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
     beforerowinsertupdatedelete1(p_deleting => TRUE);
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.admission_cat,
    		new_references.s_admission_process_type)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
  ) IS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
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

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
			x_ORG_ID IN NUMBER,
       x_ADMISSION_CAT IN VARCHAR2,
       x_S_ADMISSION_PROCESS_TYPE IN VARCHAR2,
       x_OFFER_RESPONSE_OFFSET IN NUMBER,
       X_MODE in VARCHAR2   ,
       x_closed_ind IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_PRCS_CAT_ALL
             where                 ADMISSION_CAT= X_ADMISSION_CAT
            and S_ADMISSION_PROCESS_TYPE = X_S_ADMISSION_PROCESS_TYPE
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
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
		x_org_id => igs_ge_gen_003.get_org_id,
 	       x_admission_cat=>X_ADMISSION_CAT,
 	       x_s_admission_process_type=>X_S_ADMISSION_PROCESS_TYPE,
 	       x_offer_response_offset=>X_OFFER_RESPONSE_OFFSET,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_closed_ind => x_closed_ind);
     insert into IGS_AD_PRCS_CAT_ALL (
		ORG_ID
		,ADMISSION_CAT
		,S_ADMISSION_PROCESS_TYPE
		,OFFER_RESPONSE_OFFSET
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CLOSED_IND
        ) values  (
					NEW_REFERENCES.ORG_ID
	        ,NEW_REFERENCES.ADMISSION_CAT
	        ,NEW_REFERENCES.S_ADMISSION_PROCESS_TYPE
	        ,NEW_REFERENCES.OFFER_RESPONSE_OFFSET
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,X_CLOSED_IND
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
       x_ADMISSION_CAT IN VARCHAR2,
       x_S_ADMISSION_PROCESS_TYPE IN VARCHAR2,
       x_OFFER_RESPONSE_OFFSET IN NUMBER,
       X_CLOSED_IND IN VARCHAR2
         ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      OFFER_RESPONSE_OFFSET,
      CLOSED_IND
    from IGS_AD_PRCS_CAT_ALL
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
if ( (  (tlinfo.OFFER_RESPONSE_OFFSET = X_OFFER_RESPONSE_OFFSET)
      OR (tlinfo.closed_ind = x_closed_ind )
 	    OR ((tlinfo.OFFER_RESPONSE_OFFSET is null)
		AND (X_OFFER_RESPONSE_OFFSET is null)))
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
       x_ADMISSION_CAT IN VARCHAR2,
       x_S_ADMISSION_PROCESS_TYPE IN VARCHAR2,
       x_OFFER_RESPONSE_OFFSET IN NUMBER,
      X_MODE in VARCHAR2   ,
      X_CLOSED_IND IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
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
 	       x_admission_cat=>X_ADMISSION_CAT,
 	       x_s_admission_process_type=>X_S_ADMISSION_PROCESS_TYPE,
 	       x_offer_response_offset=>X_OFFER_RESPONSE_OFFSET,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_closed_ind => x_closed_ind);
   update IGS_AD_PRCS_CAT_ALL set
      OFFER_RESPONSE_OFFSET =  NEW_REFERENCES.OFFER_RESPONSE_OFFSET,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	CLOSED_IND = X_CLOSED_IND
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
			x_org_id IN NUMBER,
       x_ADMISSION_CAT IN VARCHAR2,
       x_S_ADMISSION_PROCESS_TYPE IN VARCHAR2,
       x_OFFER_RESPONSE_OFFSET IN NUMBER,
      X_MODE in VARCHAR2 ,
      X_CLOSED_IND IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_PRCS_CAT_ALL
             where     ADMISSION_CAT= X_ADMISSION_CAT
            and S_ADMISSION_PROCESS_TYPE = X_S_ADMISSION_PROCESS_TYPE
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
			x_org_id,
       X_ADMISSION_CAT,
       X_S_ADMISSION_PROCESS_TYPE,
       X_OFFER_RESPONSE_OFFSET,
      X_MODE,
      X_CLOSED_IND);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_ADMISSION_CAT,
       X_S_ADMISSION_PROCESS_TYPE,
       X_OFFER_RESPONSE_OFFSET,
      X_MODE,
      X_CLOSED_IND);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-May-2000
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
 delete from IGS_AD_PRCS_CAT_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ad_prcs_cat_pkg;

/
