--------------------------------------------------------
--  DDL for Package Body IGS_AD_UP_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_UP_HEADER_PKG" AS
/* $Header: IGSAI92B.pls 115.12 2003/10/30 13:24:44 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_up_header%RowType;
  new_references igs_ad_up_header%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_max_score IN NUMBER DEFAULT NULL,
    x_up_header_id IN NUMBER DEFAULT NULL,
    x_admission_test_type IN VARCHAR2 DEFAULT NULL,
    x_test_segment_id IN NUMBER DEFAULT NULL,
    x_definition_level IN VARCHAR2 DEFAULT NULL,
    x_min_score IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_UP_HEADER
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
    new_references.max_score := x_max_score;
    new_references.up_header_id := x_up_header_id;
    new_references.admission_test_type := x_admission_test_type;
    new_references.test_segment_id := x_test_segment_id;
    new_references.definition_level := x_definition_level;
    new_references.min_score := x_min_score;
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
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'MIN_SCORE'  THEN
        new_references.min_score := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'MAX_SCORE'  THEN
        new_references.max_score := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'DEFINITION_LEVEL'  THEN
        new_references.definition_level := column_value;
        NULL;
      END IF;

     -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'MIN_SCORE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.min_score >= 0)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_MIN_NOT_LT_0');
      	     IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'MIN_SCORE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.min_score <= new_references.max_score)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_MIN_NOT_GT_MAX');
      	     IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'MAX_SCORE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.max_score >= new_references.min_score)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_MAX_NOT_LT_MIN');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'DEFINITION_LEVEL' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.definition_level IN ('T','S'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
             IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;


  PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By : vdixit
  Date Created On : 11-Oct-2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
   Begin
     	IF Get_Uk_For_Validation (
    		new_references.admission_test_type,
		new_references.test_segment_id
    		) THEN
 	  Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	  IGS_GE_MSG_STACK.ADD;
	  app_exception.raise_exception;
    	END IF;
   END Check_Uniqueness ;



  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.admission_test_type = new_references.admission_test_type)) OR
        ((new_references.admission_test_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Test_Type_Pkg.Get_PK_For_Validation (
        		new_references.admission_test_type,
            'N'
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.test_segment_id = new_references.test_segment_id)) OR
        ((new_references.test_segment_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Test_Segments_Pkg.Get_PK_For_Validation (
        		new_references.test_segment_id ,
            'N'
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ad_Up_Detail_Pkg.Get_FK_Igs_Ad_Up_Header (
      old_references.up_header_id
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_up_header_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_up_header
      WHERE    up_header_id = x_up_header_id
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
    x_admission_test_type IN VARCHAR2,
    x_test_segment_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : vdixit
  Date Created On : 11-Oct-2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  rrengara        22-mar-2002     1.  Added parameter x_test_segment_id to the procedure   Bug fix for 2269985
                                  2.  Added check for uniquness on Admission test type and segment if the test_segment_id is not null Bug fix for 2269985
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_up_header
      WHERE    admission_test_type = x_admission_test_type
       and      ((l_rowid is null) or (rowid <> l_rowid));

    CURSOR test_type_seg_cur IS
     SELECT rowid
       FROM igs_ad_up_header
       WHERE admission_test_type = x_admission_test_type AND
             test_segment_id = x_test_segment_id AND
	     ((l_rowid is null) or (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;
    test_type_seg_rec test_type_seg_cur%ROWTYPE;
  BEGIN


  IF  x_test_segment_id IS NULL THEN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  ELSE
    open test_type_seg_cur;
    Fetch test_type_seg_cur INTO test_type_seg_rec;
    IF (test_type_seg_cur%FOUND) THEN
      Close test_type_seg_cur;
        return (true);
        ELSE
       close test_type_seg_cur;
      return(false);
    END IF;
  END IF;
  END Get_UK_For_Validation ;


  PROCEDURE Get_FK_Igs_Ad_Test_Type (
    x_admission_test_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_up_header
      WHERE    admission_test_type = x_admission_test_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AUH_ADMTT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Test_Type;

  PROCEDURE Get_FK_Igs_Ad_Test_Segments (
    x_test_segment_id IN NUMBER
    ) AS

 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_up_header
      WHERE    test_segment_id = x_test_segment_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AUH_ATS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Test_Segments;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_max_score IN NUMBER DEFAULT NULL,
    x_up_header_id IN NUMBER DEFAULT NULL,
    x_admission_test_type IN VARCHAR2 DEFAULT NULL,
    x_test_segment_id IN NUMBER DEFAULT NULL,
    x_definition_level IN VARCHAR2 DEFAULT NULL,
    x_min_score IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
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
      x_max_score,
      x_up_header_id,
      x_admission_test_type,
      x_test_segment_id,
      x_definition_level,
      x_min_score,
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
    		new_references.up_header_id)  THEN
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

      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.up_header_id)  THEN
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
      Check_Child_Existance;
    END IF;
  l_rowid := NULL;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
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
   l_rowid := NULL;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MAX_SCORE IN NUMBER,
       x_UP_HEADER_ID IN OUT NOCOPY NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_DEFINITION_LEVEL IN VARCHAR2,
       x_MIN_SCORE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_UP_HEADER
             where                 UP_HEADER_ID= X_UP_HEADER_ID
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

   X_UP_HEADER_ID := -1;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_max_score=>X_MAX_SCORE,
 	       x_up_header_id=>X_UP_HEADER_ID,
 	       x_admission_test_type=>X_ADMISSION_TEST_TYPE,
 	       x_test_segment_id=>X_TEST_SEGMENT_ID,
 	       x_definition_level=>X_DEFINITION_LEVEL,
 	       x_min_score=>X_MIN_SCORE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_AD_UP_HEADER (
		MAX_SCORE
		,UP_HEADER_ID
		,ADMISSION_TEST_TYPE
		,TEST_SEGMENT_ID
		,DEFINITION_LEVEL
		,MIN_SCORE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.MAX_SCORE
	        ,IGS_AD_UP_HEADER_S.NEXTVAL
	        ,NEW_REFERENCES.ADMISSION_TEST_TYPE
	        ,NEW_REFERENCES.TEST_SEGMENT_ID
	        ,NEW_REFERENCES.DEFINITION_LEVEL
	        ,NEW_REFERENCES.MIN_SCORE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
)RETURNING UP_HEADER_ID INTO X_UP_HEADER_ID ;
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
       x_MAX_SCORE IN NUMBER,
       x_UP_HEADER_ID IN NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_DEFINITION_LEVEL IN VARCHAR2,
       x_MIN_SCORE IN NUMBER  ) AS
  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      MAX_SCORE
,      ADMISSION_TEST_TYPE
,      TEST_SEGMENT_ID
,      DEFINITION_LEVEL
,      MIN_SCORE
    from IGS_AD_UP_HEADER
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
if ( (  tlinfo.MAX_SCORE = X_MAX_SCORE)
  AND (tlinfo.ADMISSION_TEST_TYPE = X_ADMISSION_TEST_TYPE)
  AND (tlinfo.TEST_SEGMENT_ID = X_TEST_SEGMENT_ID OR tlinfo.TEST_SEGMENT_ID IS NULL)
  AND (tlinfo.DEFINITION_LEVEL = X_DEFINITION_LEVEL)
  AND (tlinfo.MIN_SCORE = X_MIN_SCORE)
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
       x_MAX_SCORE IN NUMBER,
       x_UP_HEADER_ID IN NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_DEFINITION_LEVEL IN VARCHAR2,
       x_MIN_SCORE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
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
 	       x_max_score=>X_MAX_SCORE,
 	       x_up_header_id=>X_UP_HEADER_ID,
 	       x_admission_test_type=>X_ADMISSION_TEST_TYPE,
 	       x_test_segment_id=>X_TEST_SEGMENT_ID,
 	       x_definition_level=>X_DEFINITION_LEVEL,
 	       x_min_score=>X_MIN_SCORE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_AD_UP_HEADER set
      MAX_SCORE =  NEW_REFERENCES.MAX_SCORE,
      ADMISSION_TEST_TYPE =  NEW_REFERENCES.ADMISSION_TEST_TYPE,
      TEST_SEGMENT_ID =  NEW_REFERENCES.TEST_SEGMENT_ID,
      DEFINITION_LEVEL =  NEW_REFERENCES.DEFINITION_LEVEL,
      MIN_SCORE =  NEW_REFERENCES.MIN_SCORE,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
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
       x_MAX_SCORE IN NUMBER,
       x_UP_HEADER_ID IN OUT NOCOPY NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_DEFINITION_LEVEL IN VARCHAR2,
       x_MIN_SCORE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_UP_HEADER
             where     UP_HEADER_ID= X_UP_HEADER_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_MAX_SCORE,
       X_UP_HEADER_ID,
       X_ADMISSION_TEST_TYPE,
       X_TEST_SEGMENT_ID,
       X_DEFINITION_LEVEL,
       X_MIN_SCORE,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_MAX_SCORE,
       X_UP_HEADER_ID,
       X_ADMISSION_TEST_TYPE,
       X_TEST_SEGMENT_ID,
       X_DEFINITION_LEVEL,
       X_MIN_SCORE,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
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
 delete from IGS_AD_UP_HEADER
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ad_up_header_pkg;

/
