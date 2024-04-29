--------------------------------------------------------
--  DDL for Package Body IGS_AD_INTERFACE_CTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_INTERFACE_CTL_PKG" AS
/* $Header: IGSAIA8B.pls 115.15 2003/12/09 12:45:08 pbondugu ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AD_INTERFACE_CTL%RowType;
  new_references IGS_AD_INTERFACE_CTL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_interface_run_id IN NUMBER,
    x_source_type_id IN NUMBER ,
    x_batch_id IN NUMBER ,
    x_match_set_id IN NUMBER ,
    x_status IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
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
  FROM     IGS_AD_INTERFACE_CTL
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
    new_references.interface_run_id := x_interface_run_id;
    new_references.source_type_id := x_source_type_id;
    new_references.batch_id := x_batch_id;
    new_references.match_set_id := x_match_set_id;

        IF x_status IS NOT NULL THEN
        new_references.status :=  x_status;
    ELSE
	    new_references.status :=  '2';
	END IF;


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
	  Column_Name IN VARCHAR2  ,
	  Column_Value IN VARCHAR2  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         14-MAY-2002     Bug No: 2373399
                                  Modified to check the Status value among 1,2,3,4 instead of E,P,C
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
    IF column_name IS NULL THEN
       NULL;
    ELSIF  UPPER(column_name) = 'STATUS'  THEN
      new_references.status := column_value;
      NULL;
    END IF;

    -- The following code checks for check constraints on the Columns.
    IF Upper(Column_Name) = 'STATUS' OR
       Column_Name IS NULL THEN
       IF NOT (new_references.status in ('1','2','3','4'))  THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
     END IF;

  END Check_Constraints;


  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  rrengara        4-oct-2002      Removed the checks for admission cateogry, all calendars, funnel status and person types
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.source_type_id = new_references.source_type_id)) OR
        ((new_references.source_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Src_Types_Pkg.Get_PK_For_Validation (
        		new_references.source_type_id
        )  THEN
      	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
       	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.match_set_id = new_references.match_set_id)) OR
        ((new_references.match_set_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Match_Sets_Pkg.Get_PK_For_Validation (
        		new_references.match_set_id
        )  THEN
      	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
       	 App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_Existance;


  FUNCTION Get_PK_For_Validation (
    x_interface_run_id IN NUMBER
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
    FROM     IGS_AD_INTERFACE_CTL
    WHERE    interface_run_id = x_interface_run_id
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





  PROCEDURE Get_FK_Igs_Pe_Src_Types (
    x_source_type_id IN NUMBER
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
      FROM     IGS_AD_INTERFACE_CTL
      WHERE    source_type_id = x_source_type_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AIC_PST_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Src_Types;


  PROCEDURE Get_FK_Igs_Pe_Match_Sets (
    x_match_set_id IN NUMBER
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
      FROM     IGS_AD_INTERFACE_CTL
      WHERE    match_set_id = x_match_set_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AIC_PMS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Match_Sets;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_interface_run_id IN NUMBER ,
    x_source_type_id IN NUMBER ,
    x_batch_id IN NUMBER ,
    x_match_set_id IN NUMBER ,
    x_status IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
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

    Set_Column_Values (
      p_action,
      x_rowid,
      x_interface_run_id,
      x_source_type_id,
      x_batch_id,
      x_match_set_id,
      x_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
      		new_references.interface_run_id)  THEN
	          Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
	     END IF;
       Check_Constraints;
       Check_Parent_Existance;
     ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       Null;
       Check_Constraints;
       Check_Parent_Existance;
     ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
       Null;
     ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.interface_run_id)  THEN
	        Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
          IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	    END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
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

  END After_DML;

  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_INTERFACE_RUN_ID IN OUT NOCOPY  NUMBER,
    x_SOURCE_TYPE_ID IN NUMBER,
    x_BATCH_ID IN NUMBER,
    x_MATCH_SET_ID IN NUMBER,
    x_STATUS IN VARCHAR2,
    X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  rrengara        4-OCT-2002      Passed null to admission category, calendar instance, person type and funnel status for the Build 2604395
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_INTERFACE_CTL
             where                 INTERFACE_RUN_ID= X_INTERFACE_RUN_ID;

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
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
      X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      if (X_REQUEST_ID =  -1) then
         X_REQUEST_ID := NULL;
         X_PROGRAM_ID := NULL;
         X_PROGRAM_APPLICATION_ID := NULL;
         X_PROGRAM_UPDATE_DATE := NULL;
      else
         X_PROGRAM_UPDATE_DATE := SYSDATE;
      end if;
    else
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    end if;

   X_INTERFACE_RUN_ID := -1;
   Before_DML(
      p_action=>'INSERT',
      x_rowid=>X_ROWID,
      x_interface_run_id=>X_INTERFACE_RUN_ID,
      x_source_type_id=>X_SOURCE_TYPE_ID,
      x_batch_id=>X_BATCH_ID,
      x_match_set_id=>X_MATCH_SET_ID,
      x_status=>X_STATUS,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN
    );

      INSERT INTO IGS_AD_INTERFACE_CTL (
        INTERFACE_RUN_ID
        ,SOURCE_TYPE_ID
        ,BATCH_ID
        ,MATCH_SET_ID
        ,STATUS
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,REQUEST_ID
        ,PROGRAM_ID
        ,PROGRAM_APPLICATION_ID
        ,PROGRAM_UPDATE_DATE
    ) values  (
         IGS_AD_INTERFACE_CTL_S.NEXTVAL
        ,NEW_REFERENCES.SOURCE_TYPE_ID
        ,NEW_REFERENCES.BATCH_ID
        ,NEW_REFERENCES.MATCH_SET_ID
        ,NEW_REFERENCES.STATUS
        ,X_LAST_UPDATE_DATE
        ,X_LAST_UPDATED_BY
        ,X_LAST_UPDATE_DATE
        ,X_LAST_UPDATED_BY
        ,X_LAST_UPDATE_LOGIN
        ,X_REQUEST_ID
        ,X_PROGRAM_ID
        ,X_PROGRAM_APPLICATION_ID
        ,X_PROGRAM_UPDATE_DATE
  )RETURNING INTERFACE_RUN_ID INTO X_INTERFACE_RUN_ID;

		OPEN c;
    FETCH c INTO X_ROWID;
 		IF (c%notfound) THEN
		CLOSE c;
 	     RAISE no_data_found;
		END IF;
 		CLOSE C;

    After_DML (
		  p_action => 'INSERT' ,
  		x_rowid => X_ROWID );
    end INSERT_ROW;

  procedure LOCK_ROW (
    X_ROWID in  VARCHAR2,
    x_INTERFACE_RUN_ID IN NUMBER,
    x_SOURCE_TYPE_ID IN NUMBER,
    x_BATCH_ID IN NUMBER,
    x_MATCH_SET_ID IN NUMBER,
    x_STATUS IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  rrengara        4-OCT-2002      Removed the references to columns admission cat, calendar instance values and person type and funnel status
  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR c1 IS SELECT
      SOURCE_TYPE_ID,
      BATCH_ID,
      MATCH_SET_ID,
      STATUS
   FROM IGS_AD_INTERFACE_CTL
   WHERE ROWID = X_ROWID
   for update nowait;

   tlinfo c1%rowtype;

  begin
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
       CLOSE c1;
       APP_EXCEPTION.RAISE_EXCEPTION;
       RETURN;
    END IF;
    CLOSE C1;

    IF ( (  tlinfo.SOURCE_TYPE_ID = X_SOURCE_TYPE_ID)
      AND (tlinfo.BATCH_ID = X_BATCH_ID)
      AND (tlinfo.MATCH_SET_ID = X_MATCH_SET_ID)
      AND ((tlinfo.STATUS = X_STATUS)
          OR ((tlinfo.STATUS is null)
              AND (X_STATUS is null)))
      ) THEN
          NULL;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
    RETURN;
 end LOCK_ROW;


  Procedure UPDATE_ROW (
    X_ROWID in  VARCHAR2,
    x_INTERFACE_RUN_ID IN NUMBER,
    x_SOURCE_TYPE_ID IN NUMBER,
    x_BATCH_ID IN NUMBER,
    x_MATCH_SET_ID IN NUMBER,
    x_STATUS IN VARCHAR2,
    X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   rrengara        4-OCT-2002      Passed null to admission category, calendar instance, person type and funnel status for the Build 2604395
  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
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
      x_interface_run_id=>X_INTERFACE_RUN_ID,
      x_source_type_id=>X_SOURCE_TYPE_ID,
      x_batch_id=>X_BATCH_ID,
      x_match_set_id=>X_MATCH_SET_ID,
      x_status=>X_STATUS,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN
    );

     if (X_MODE = 'R') then
        X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
        X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
        if (X_REQUEST_ID = -1) then
          X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
          X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
          X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
          X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
        else
          X_PROGRAM_UPDATE_DATE := SYSDATE;
        end if;
     end if;

   update IGS_AD_INTERFACE_CTL set
      SOURCE_TYPE_ID =  NEW_REFERENCES.SOURCE_TYPE_ID,
      BATCH_ID =  NEW_REFERENCES.BATCH_ID,
      MATCH_SET_ID =  NEW_REFERENCES.MATCH_SET_ID,
      STATUS =  NEW_REFERENCES.STATUS,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      REQUEST_ID = X_REQUEST_ID,
      PROGRAM_ID = X_PROGRAM_ID,
      PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
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
      x_INTERFACE_RUN_ID IN OUT NOCOPY NUMBER,
      x_SOURCE_TYPE_ID IN NUMBER,
      x_BATCH_ID IN NUMBER,
      x_MATCH_SET_ID IN NUMBER,
      x_STATUS IN VARCHAR2,
      X_MODE in VARCHAR2
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

    cursor c1 is select ROWID from IGS_AD_INTERFACE_CTL
             where     INTERFACE_RUN_ID= X_INTERFACE_RUN_ID;

  begin
	  open c1;
		fetch c1 into X_ROWID;
  	if (c1%notfound) then
	    close c1;
      INSERT_ROW (
         X_ROWID,
         X_INTERFACE_RUN_ID,
         X_SOURCE_TYPE_ID,
         X_BATCH_ID,
         X_MATCH_SET_ID,
         X_STATUS,
         X_MODE );
      return;
  	end if;
	    close c1;

      UPDATE_ROW (
         X_ROWID,
         X_INTERFACE_RUN_ID,
         X_SOURCE_TYPE_ID,
         X_BATCH_ID,
         X_MATCH_SET_ID,
         X_STATUS,
         X_MODE );

  end ADD_ROW;

  procedure DELETE_ROW (
    X_ROWID in VARCHAR2
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

  begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_AD_INTERFACE_CTL
  where ROWID = X_ROWID;
  if (sql%notfound) then
     raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

end DELETE_ROW;

END igs_ad_interface_ctl_pkg;

/
