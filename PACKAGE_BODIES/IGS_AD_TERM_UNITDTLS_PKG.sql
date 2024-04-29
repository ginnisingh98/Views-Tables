--------------------------------------------------------
--  DDL for Package Body IGS_AD_TERM_UNITDTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_TERM_UNITDTLS_PKG" AS
/* $Header: IGSAI84B.pls 120.2 2005/10/01 21:47:44 appldev ship $ */
  PROCEDURE update_term_tab(x_term_id IN NUMBER);
  l_rowid VARCHAR2(25);
  old_references igs_ad_term_unitdtls%RowType;
  new_references igs_ad_term_unitdtls%RowType;


  PROCEDURE Check_Status
  AS
  /*************************************************************
  Created By : jchin
  Date Created By : 29-Sep-2005
  Purpose : Check if associated academic record is INACTIVE and throw
   an error if it is
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR check_status(cp_term_details_id IN NUMBER) IS
    SELECT DISTINCT 1
    FROM igs_ad_acad_history_v hist, igs_ad_transcript_v trans, igs_ad_term_details_v term
    WHERE hist.education_id = trans.education_id
    AND trans.transcript_id = term.transcript_id
    AND term.term_details_id = cp_term_details_id
    AND hist.status = 'I';

  l_temp NUMBER;

  BEGIN

    l_temp := null;

    OPEN check_status(new_references.term_details_id);
    FETCH check_status INTO l_temp;
    CLOSE check_status;

    IF l_temp IS NOT NULL THEN

      Fnd_message.Set_Name('IGS', 'IGS_AD_INACTIVE_ACAD_HIST');
      IGS_GE_MSG_STACK.ADD;
      app_exception.Raise_Exception;

    END IF;

  END Check_Status;


  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_details_id IN NUMBER DEFAULT NULL,
    x_term_details_id IN NUMBER DEFAULT NULL,
    x_unit IN VARCHAR2 DEFAULT NULL,
    x_unit_difficulty IN NUMBER DEFAULT NULL,
    x_unit_name IN VARCHAR2 DEFAULT NULL,
    x_cp_attempted IN NUMBER DEFAULT NULL,
    x_cp_earned IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_unit_grade_points IN NUMBER DEFAULT NULL,
    x_deg_aud_detail_id  IN NUMBER DEFAULT NULL,
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
      FROM     IGS_AD_TERM_UNITDTLS
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
    new_references.unit_details_id := x_unit_details_id;
    new_references.term_details_id := x_term_details_id;
    new_references.unit := x_unit;
    new_references.unit_difficulty := x_unit_difficulty;
    new_references.unit_name := x_unit_name;
    new_references.cp_attempted := x_cp_attempted;
    new_references.cp_earned := x_cp_earned;
    new_references.grade := x_grade;
    new_references.unit_grade_points := x_unit_grade_points;
    new_references.deg_aud_detail_id := x_deg_aud_detail_id;
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
  rboddu          10-DEC-2002     modified for bug 2623180
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'CP_ATTEMPTED'  THEN
        new_references.cp_attempted := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'CP_EARNED'  THEN
        new_references.cp_earned := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'UNIT_GRADE_POINTS'  THEN
        new_references.unit_grade_points := IGS_GE_NUMBER.TO_NUM(column_value);
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.

    -- Bug: 2623180. changed >0 to >=0 in the following credit point comparison checks
      IF Upper(Column_Name) = 'CP_ATTEMPTED' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.cp_attempted >= 0)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CP_ATTEMPTED'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'CP_EARNED' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.cp_earned >= 0)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CP_EARNED'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'UNIT_GRADE_POINTS' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.unit_grade_points >= 0)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_GRADE_POINT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;
  END Check_Constraints;



  PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
   Begin
  	IF Get_Uk_for_Validation(
  	  new_references.term_details_id,
  	  new_references.unit
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

    IF (((old_references.unit_difficulty = new_references.unit_difficulty)) OR
        ((new_references.unit_difficulty IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_uk2_For_Validation (
        		new_references.unit_difficulty ,
                        'UNIT_DIFFICULTY',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_UNIT_DIFFICULTY'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.term_details_id = new_references.term_details_id)) OR
        ((new_references.term_details_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Term_Details_Pkg.Get_PK_For_Validation (
        		new_references.term_details_id
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TERM_DETAILS'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_details_id IN NUMBER
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
      FROM     igs_ad_term_unitdtls
      WHERE    unit_details_id = x_unit_details_id
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
    x_term_details_id IN NUMBER,
    x_unit IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_term_unitdtls
      WHERE    unit = x_unit
        AND	term_details_id = x_term_details_id and      ((l_rowid is null) or (rowid <> l_rowid))

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

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
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
      FROM     igs_ad_term_unitdtls
      WHERE    unit_difficulty = x_code_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATUD_ACDC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Code_Classes;

  PROCEDURE Get_FK_Igs_Ad_Term_Details (
    x_term_details_id IN NUMBER
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
      FROM     igs_ad_term_unitdtls
      WHERE    term_details_id = x_term_details_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATUD_ATD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Term_Details;

  PROCEDURE Check_Child_Existance AS
  BEGIN
    -- Next part of code has been added as per bug# 2401170
    -- Start of new code.
    IGS_AV_STND_UNIT_PKG.GET_FK_IGS_AD_TERM_UNITDTLS (
      old_references.unit_details_id
      );
    IGS_AV_STND_UNIT_LVL_PKG.GET_FK_IGS_AD_TERM_UNITDTLS (
      old_references.unit_details_id
      );
    -- End of new code. Bug# 2401170
  END Check_Child_Existance;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_details_id IN NUMBER DEFAULT NULL,
    x_term_details_id IN NUMBER DEFAULT NULL,
    x_unit IN VARCHAR2 DEFAULT NULL,
    x_unit_difficulty IN NUMBER DEFAULT NULL,
    x_unit_name IN VARCHAR2 DEFAULT NULL,
    x_cp_attempted IN NUMBER DEFAULT NULL,
    x_cp_earned IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_unit_grade_points IN NUMBER DEFAULT NULL,
    x_deg_aud_detail_id IN NUMBER DEFAULT NULL,
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
      x_unit_details_id,
      x_term_details_id,
      x_unit,
      x_unit_difficulty,
      x_unit_name,
      x_cp_attempted,
      x_cp_earned,
      x_grade,
      x_unit_grade_points,
      x_deg_aud_detail_id,
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
    		new_references.unit_details_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Uniqueness;
      Check_Parent_Existance;
      Check_Status;  --jchin Bug 4629226
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Uniqueness;
      Check_Parent_Existance;
      Check_Status;  --jchin Bug 4629226
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;


    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.unit_details_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;

    END IF;

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
      update_term_tab( x_term_id => NEW_REFERENCES.TERM_DETAILS_ID );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      update_term_tab( x_term_id => NEW_REFERENCES.TERM_DETAILS_ID );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      update_term_tab( x_term_id => OLD_REFERENCES.TERM_DETAILS_ID );
    END IF;

  l_rowid:=NULL;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_DETAILS_ID IN OUT NOCOPY NUMBER,
       x_TERM_DETAILS_ID IN NUMBER,
       x_UNIT IN VARCHAR2,
       x_UNIT_DIFFICULTY IN NUMBER,
       x_UNIT_NAME IN VARCHAR2,
       x_CP_ATTEMPTED IN NUMBER,
       x_CP_EARNED IN NUMBER,
       x_GRADE IN VARCHAR2,
       x_UNIT_GRADE_POINTS IN NUMBER,
       x_DEG_AUD_DETAIL_ID IN NUMBER DEFAULT NULL,
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

    cursor C is select ROWID from IGS_AD_TERM_UNITDTLS
             where                 UNIT_DETAILS_ID= X_UNIT_DETAILS_ID
;
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
    elsif (X_MODE IN ('R', 'S')) then
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

   X_UNIT_DETAILS_ID := -1;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_unit_details_id=>X_UNIT_DETAILS_ID,
 	       x_term_details_id=>X_TERM_DETAILS_ID,
 	       x_unit=>X_UNIT,
 	       x_unit_difficulty=>X_UNIT_DIFFICULTY,
 	       x_unit_name=>X_UNIT_NAME,
 	       x_cp_attempted=>X_CP_ATTEMPTED,
 	       x_cp_earned=>X_CP_EARNED,
 	       x_grade=>X_GRADE,
 	       x_unit_grade_points=>X_UNIT_GRADE_POINTS,
	       x_deg_aud_detail_id => X_DEG_AUD_DETAIL_ID,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);

      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_TERM_UNITDTLS (
		UNIT_DETAILS_ID
		,TERM_DETAILS_ID
		,UNIT
		,UNIT_DIFFICULTY
		,UNIT_NAME
		,CP_ATTEMPTED
		,CP_EARNED
		,GRADE
		,UNIT_GRADE_POINTS
		,DEG_AUD_DETAIL_ID
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
	         IGS_AD_TERM_UNITDTLS_S.NEXTVAL
	        ,NEW_REFERENCES.TERM_DETAILS_ID
	        ,NEW_REFERENCES.UNIT
	        ,NEW_REFERENCES.UNIT_DIFFICULTY
	        ,NEW_REFERENCES.UNIT_NAME
	        ,NEW_REFERENCES.CP_ATTEMPTED
	        ,NEW_REFERENCES.CP_EARNED
	        ,NEW_REFERENCES.GRADE
	        ,NEW_REFERENCES.UNIT_GRADE_POINTS
		,NEW_REFERENCES.DEG_AUD_DETAIL_ID
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,X_REQUEST_ID
		,X_PROGRAM_ID
		,X_PROGRAM_APPLICATION_ID
		,X_PROGRAM_UPDATE_DATE
)RETURNING UNIT_DETAILS_ID INTO X_UNIT_DETAILS_ID ;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

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
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end INSERT_ROW;
 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_DETAILS_ID IN NUMBER,
       x_TERM_DETAILS_ID IN NUMBER,
       x_UNIT IN VARCHAR2,
       x_UNIT_DIFFICULTY IN NUMBER,
       x_UNIT_NAME IN VARCHAR2,
       x_CP_ATTEMPTED IN NUMBER,
       x_CP_EARNED IN NUMBER,
       x_GRADE IN VARCHAR2,
       x_UNIT_GRADE_POINTS IN NUMBER,
       x_DEG_AUD_DETAIL_ID IN NUMBER DEFAULT NULL) AS
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
      TERM_DETAILS_ID
,      UNIT
,      UNIT_DIFFICULTY
,      UNIT_NAME
,      CP_ATTEMPTED
,      CP_EARNED
,      GRADE
,      UNIT_GRADE_POINTS
,      DEG_AUD_DETAIL_ID
    from IGS_AD_TERM_UNITDTLS
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
if ( (  tlinfo.TERM_DETAILS_ID = X_TERM_DETAILS_ID)
  AND (tlinfo.UNIT = X_UNIT)
  AND (tlinfo.UNIT_DIFFICULTY = X_UNIT_DIFFICULTY)
  AND (tlinfo.UNIT_NAME = X_UNIT_NAME)
  AND ((tlinfo.CP_ATTEMPTED = X_CP_ATTEMPTED)
 	    OR ((tlinfo.CP_ATTEMPTED is null)
		AND (X_CP_ATTEMPTED is null)))
  AND ((tlinfo.CP_EARNED = X_CP_EARNED)
 	    OR ((tlinfo.CP_EARNED is null)
		AND (X_CP_EARNED is null)))
  AND ((tlinfo.GRADE = X_GRADE)
 	    OR ((tlinfo.GRADE is null)
		AND (X_GRADE is null)))
  AND ((tlinfo.UNIT_GRADE_POINTS = X_UNIT_GRADE_POINTS)
 	    OR ((tlinfo.UNIT_GRADE_POINTS is null)
		AND (X_UNIT_GRADE_POINTS is null)))
  AND ((tlinfo.DEG_AUD_DETAIL_ID = X_DEG_AUD_DETAIL_ID)
 	    OR ((tlinfo.DEG_AUD_DETAIL_ID is null)
		AND (X_DEG_AUD_DETAIL_ID is null)))
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
       x_UNIT_DETAILS_ID IN NUMBER,
       x_TERM_DETAILS_ID IN NUMBER,
       x_UNIT IN VARCHAR2,
       x_UNIT_DIFFICULTY IN NUMBER,
       x_UNIT_NAME IN VARCHAR2,
       x_CP_ATTEMPTED IN NUMBER,
       x_CP_EARNED IN NUMBER,
       x_GRADE IN VARCHAR2,
       x_UNIT_GRADE_POINTS IN NUMBER,
       x_DEG_AUD_DETAIL_ID IN NUMBER DEFAULT NULL,
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
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
 begin
    X_LAST_UPDATE_DATE := SYSDATE;
    if(X_MODE = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (X_MODE IN ('R', 'S')) then
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
 	       x_unit_details_id=>X_UNIT_DETAILS_ID,
 	       x_term_details_id=>X_TERM_DETAILS_ID,
 	       x_unit=>X_UNIT,
 	       x_unit_difficulty=>X_UNIT_DIFFICULTY,
 	       x_unit_name=>X_UNIT_NAME,
 	       x_cp_attempted=>X_CP_ATTEMPTED,
 	       x_cp_earned=>X_CP_EARNED,
 	       x_grade=>X_GRADE,
 	       x_unit_grade_points=>X_UNIT_GRADE_POINTS,
      	       x_deg_aud_detail_id => X_DEG_AUD_DETAIL_ID,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);

    if (X_MODE IN ('R', 'S')) then
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

    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE IGS_AD_TERM_UNITDTLS SET
      TERM_DETAILS_ID	 =  NEW_REFERENCES.TERM_DETAILS_ID,
      UNIT		 =  NEW_REFERENCES.UNIT,
      UNIT_DIFFICULTY	 =  NEW_REFERENCES.UNIT_DIFFICULTY,
      UNIT_NAME		 =  NEW_REFERENCES.UNIT_NAME,
      CP_ATTEMPTED	 =  NEW_REFERENCES.CP_ATTEMPTED,
      CP_EARNED		 =  NEW_REFERENCES.CP_EARNED,
      GRADE		 =  NEW_REFERENCES.GRADE,
      UNIT_GRADE_POINTS  =  NEW_REFERENCES.UNIT_GRADE_POINTS,
      DEG_AUD_DETAIL_ID = NEW_REFERENCES.DEG_AUD_DETAIL_ID,
      LAST_UPDATE_DATE	 = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY	 = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN  = X_LAST_UPDATE_LOGIN,
      REQUEST_ID	 = X_REQUEST_ID,
      PROGRAM_ID	 = X_PROGRAM_ID,
      PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
	  where ROWID = X_ROWID;
	if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
	end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_DETAILS_ID IN OUT NOCOPY NUMBER,
       x_TERM_DETAILS_ID IN NUMBER,
       x_UNIT IN VARCHAR2,
       x_UNIT_DIFFICULTY IN NUMBER,
       x_UNIT_NAME IN VARCHAR2,
       x_CP_ATTEMPTED IN NUMBER,
       x_CP_EARNED IN NUMBER,
       x_GRADE IN VARCHAR2,
       x_UNIT_GRADE_POINTS IN NUMBER,
       x_DEG_AUD_DETAIL_ID IN NUMBER DEFAULT NULL,
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

    cursor c1 is select ROWID from IGS_AD_TERM_UNITDTLS
             where     UNIT_DETAILS_ID= X_UNIT_DETAILS_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_UNIT_DETAILS_ID,
       X_TERM_DETAILS_ID,
       X_UNIT,
       X_UNIT_DIFFICULTY,
       X_UNIT_NAME,
       X_CP_ATTEMPTED,
       X_CP_EARNED,
       X_GRADE,
       X_UNIT_GRADE_POINTS,
       X_DEG_AUD_DETAIL_ID,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_UNIT_DETAILS_ID,
       X_TERM_DETAILS_ID,
       X_UNIT,
       X_UNIT_DIFFICULTY,
       X_UNIT_NAME,
       X_CP_ATTEMPTED,
       X_CP_EARNED,
       X_GRADE,
       X_UNIT_GRADE_POINTS,
       X_DEG_AUD_DETAIL_ID,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
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
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_AD_TERM_UNITDTLS
 where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;

PROCEDURE update_term_tab(x_term_id IN NUMBER)
AS
  /*************************************************************
  Created By : TRAY
  Date Created By : 18-JUN-2003
  Purpose : For updating term details table, build 2864699
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  akadam          31-jul-2003     Bug No:3003149 the calculation in for loop was not checking NULL values
  (reverse chronological order - newest change first)
  ***************************************************************/
 CURSOR c_get_data IS
 SELECT SUM(NVL(cp_attempted,0)) tcpa, SUM(NVL(cp_earned,0)) tcpe,SUM(NVL(unit_grade_points,0)) tugp
 FROM igs_ad_term_unitdtls
 WHERE term_details_id = x_term_id
 GROUP BY term_details_id;

  l_cp_attempted_total igs_ad_term_details.total_cp_attempted%TYPE;
  l_cp_earned_total igs_ad_term_details.total_cp_earned%TYPE;
  l_unit_grade_points_total igs_ad_term_details.total_unit_gp%TYPE;

 BEGIN

  OPEN c_get_data;
  FETCH c_get_data INTO l_cp_attempted_total,l_cp_earned_total,l_unit_grade_points_total;
  CLOSE c_get_data;

  UPDATE igs_ad_term_details SET total_cp_attempted=l_cp_attempted_total
                                 ,total_cp_earned=l_cp_earned_total
                                 ,total_unit_gp=l_unit_grade_points_total
                              WHERE term_details_id = x_term_id ;
 END update_term_tab;




END igs_ad_term_unitdtls_pkg;

/
