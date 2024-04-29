--------------------------------------------------------
--  DDL for Package Body IGS_AD_TERM_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_TERM_DETAILS_PKG" AS
/* $Header: IGSAI83B.pls 120.2 2005/10/01 21:47:34 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_term_details%RowType;
  new_references igs_ad_term_details%RowType;

  PROCEDURE Check_Status AS
  /*************************************************************
  Created By : jchin
  Date Created By : 2005/09/29
  Purpose : To check whether the associated academic record is
   INACTIVE and if so, throw an error
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR check_status(cp_transcript_id IN NUMBER) IS
    SELECT DISTINCT 1
    FROM igs_ad_acad_history_v hist, igs_ad_transcript_v trans
    WHERE hist.education_id = trans.education_id
    AND trans.transcript_id = cp_transcript_id
    AND hist.status = 'I';

  l_temp NUMBER;

  BEGIN

    l_temp := null;

    OPEN check_status(new_references.transcript_id);
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
    x_term_details_id IN NUMBER DEFAULT NULL,
    x_transcript_id IN NUMBER DEFAULT NULL,
    x_term IN VARCHAR2 DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_total_cp_attempted IN NUMBER DEFAULT NULL,
    x_total_cp_earned IN NUMBER DEFAULT NULL,
    x_total_unit_gp IN NUMBER DEFAULT NULL,
    x_total_gpa_units IN NUMBER DEFAULT NULL,
    x_gpa IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_TERM_DETAILS
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
    new_references.term_details_id := x_term_details_id;
    new_references.transcript_id := x_transcript_id;
    new_references.term := x_term;
    new_references.start_date := TRUNC(x_start_date);
    new_references.end_date := TRUNC(x_end_date);
    new_references.total_cp_attempted := x_total_cp_attempted;
    new_references.total_cp_earned := x_total_cp_earned;
    new_references.total_unit_gp := x_total_unit_gp;
    new_references.total_gpa_units := x_total_gpa_units;
    new_references.gpa := x_gpa;
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
  Created By : knaraset.in
  Date Created By : 2000/05/16
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'TOTAL_CP_EARNED'  THEN
        new_references.total_cp_earned := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'TOTAL_GPA_UNITS'  THEN
        new_references.total_gpa_units := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'TOTAL_UNIT_GP'  THEN
        new_references.total_unit_gp := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'START_DATE'  THEN
        new_references.start_date := IGS_GE_DATE.IGSDATE(column_value);
      ELSIF  UPPER(column_name) = 'END_DATE'  THEN
        new_references.end_date := IGS_GE_DATE.IGSDATE(column_value);
      ELSIF  UPPER(column_name) = 'TOTAL_CP_ATTEMPTED'  THEN
        new_references.total_cp_attempted := IGS_GE_NUMBER.TO_NUM(column_value);
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'TOTAL_CP_EARNED' OR
        Column_Name IS NULL THEN
        IF NOT (new_references.total_cp_earned  >=0)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TOTAL_CP_EARNED'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'TOTAL_GPA_UNITS' OR
        Column_Name IS NULL THEN
        IF NOT (new_references.total_gpa_units  >=0)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TOTAL_GPA_UNITS'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'TOTAL_UNIT_GP' OR
        Column_Name IS NULL THEN
        IF NOT (new_references.total_unit_gp >= 0)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TOTAL_UNIT_GP'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'END_DATE' OR
        Column_Name IS NULL THEN
        IF ( NOT (new_references.end_date > new_references.start_date)  OR new_references.start_date >  SYSDATE ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_AD_ST_DT_ED_DT');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'TOTAL_CP_ATTEMPTED' OR
        Column_Name IS NULL THEN
        IF NOT (new_references.total_cp_attempted  >=0)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TOTAL_CP_ATTEMPTED'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.transcript_id = new_references.transcript_id)) OR
        ((new_references.transcript_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Transcript_Pkg.Get_PK_For_Validation (
                        new_references.transcript_id
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TRANSCRIPT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ad_Term_Unitdtls_Pkg.Get_FK_Igs_Ad_Term_Details (
      old_references.term_details_id
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_term_details_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_term_details
      WHERE    term_details_id = x_term_details_id
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

  PROCEDURE Get_FK_Igs_Ad_Transcript (
    x_transcript_id IN NUMBER
    ) AS

 /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_term_details
      WHERE    transcript_id = x_transcript_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATD_ATRN_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Transcript;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_term_details_id IN NUMBER DEFAULT NULL,
    x_transcript_id IN NUMBER DEFAULT NULL,
    x_term IN VARCHAR2 DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_total_cp_attempted IN NUMBER DEFAULT NULL,
    x_total_cp_earned IN NUMBER DEFAULT NULL,
    x_total_unit_gp IN NUMBER DEFAULT NULL,
    x_total_gpa_units IN NUMBER DEFAULT NULL,
    x_gpa IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
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
      x_term_details_id,
      x_transcript_id,
      x_term,
      x_start_date,
      x_end_date,
      x_total_cp_attempted,
      x_total_cp_earned,
      x_total_unit_gp,
      x_total_gpa_units,
      x_gpa,
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
                new_references.term_details_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Constraints;
      Check_Parent_Existance;
      Check_Status;  --jchin Bug 4629226
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Parent_Existance;
      Check_Status;  --jchin Bug 4629226
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
                new_references.term_details_id)  THEN
        Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
  Created By : knaraset.in
  Date Created By : 2000/05/16
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

  l_rowid:=NULL;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TERM_DETAILS_ID IN OUT NOCOPY NUMBER,
       x_TRANSCRIPT_ID IN NUMBER,
       x_TERM IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_TOTAL_CP_ATTEMPTED IN NUMBER,
       x_TOTAL_CP_EARNED IN NUMBER,
       x_TOTAL_UNIT_GP IN NUMBER,
       x_TOTAL_GPA_UNITS IN NUMBER,
       x_GPA IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
 /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_TERM_DETAILS
             where                 TERM_DETAILS_ID= X_TERM_DETAILS_ID
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

   X_TERM_DETAILS_ID := -1;
   Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
               x_term_details_id=>X_TERM_DETAILS_ID,
               x_transcript_id=>X_TRANSCRIPT_ID,
               x_term=>X_TERM,
               x_start_date=>X_START_DATE,
               x_end_date=>X_END_DATE,
               x_total_cp_attempted=>X_TOTAL_CP_ATTEMPTED,
               x_total_cp_earned=>X_TOTAL_CP_EARNED,
               x_total_unit_gp=>X_TOTAL_UNIT_GP,
               x_total_gpa_units=>X_TOTAL_GPA_UNITS,
               x_gpa=>X_GPA,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN);
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_TERM_DETAILS (
                TERM_DETAILS_ID
                ,TRANSCRIPT_ID
                ,TERM
                ,START_DATE
                ,END_DATE
                ,TOTAL_CP_ATTEMPTED
                ,TOTAL_CP_EARNED
                ,TOTAL_UNIT_GP
                ,TOTAL_GPA_UNITS
                ,GPA
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
                 IGS_AD_TERM_DETAILS_S.NEXTVAL
                ,NEW_REFERENCES.TRANSCRIPT_ID
                ,NEW_REFERENCES.TERM
                ,NEW_REFERENCES.START_DATE
                ,NEW_REFERENCES.END_DATE
                ,NEW_REFERENCES.TOTAL_CP_ATTEMPTED
                ,NEW_REFERENCES.TOTAL_CP_EARNED
                ,NEW_REFERENCES.TOTAL_UNIT_GP
                ,NEW_REFERENCES.TOTAL_GPA_UNITS
                ,NEW_REFERENCES.GPA
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
                ,X_REQUEST_ID
                ,X_PROGRAM_ID
                ,X_PROGRAM_APPLICATION_ID
                ,X_PROGRAM_UPDATE_DATE
)RETURNING TERM_DETAILS_ID INTO X_TERM_DETAILS_ID;
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
       x_TERM_DETAILS_ID IN NUMBER,
       x_TRANSCRIPT_ID IN NUMBER,
       x_TERM IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_TOTAL_CP_ATTEMPTED IN NUMBER,
       x_TOTAL_CP_EARNED IN NUMBER,
       x_TOTAL_UNIT_GP IN NUMBER,
       x_TOTAL_GPA_UNITS IN NUMBER,
       x_GPA IN VARCHAR2  ) AS
 /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      TRANSCRIPT_ID
,      TERM
,      START_DATE
,      END_DATE
,      TOTAL_CP_ATTEMPTED
,      TOTAL_CP_EARNED
,      TOTAL_UNIT_GP
,      TOTAL_GPA_UNITS
,      GPA
    from IGS_AD_TERM_DETAILS
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
if ( (  tlinfo.TRANSCRIPT_ID = X_TRANSCRIPT_ID)
  AND (tlinfo.TERM = X_TERM)
  AND (TRUNC(tlinfo.START_DATE) = TRUNC(X_START_DATE))
  AND (TRUNC(tlinfo.END_DATE) = TRUNC(X_END_DATE))
  AND ((tlinfo.TOTAL_CP_ATTEMPTED = X_TOTAL_CP_ATTEMPTED)
            OR ((tlinfo.TOTAL_CP_ATTEMPTED is null)
                AND (X_TOTAL_CP_ATTEMPTED is null)))
  AND ((tlinfo.TOTAL_CP_EARNED = X_TOTAL_CP_EARNED)
            OR ((tlinfo.TOTAL_CP_EARNED is null)
                AND (X_TOTAL_CP_EARNED is null)))
  AND ((tlinfo.TOTAL_UNIT_GP = X_TOTAL_UNIT_GP)
            OR ((tlinfo.TOTAL_UNIT_GP is null)
                AND (X_TOTAL_UNIT_GP is null)))
  AND ((tlinfo.TOTAL_GPA_UNITS = X_TOTAL_GPA_UNITS)
            OR ((tlinfo.TOTAL_GPA_UNITS is null)
                AND (X_TOTAL_GPA_UNITS is null)))
  AND ((tlinfo.GPA = X_GPA)
            OR ((tlinfo.GPA is null)
                AND (X_GPA is null)))
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
       x_TERM_DETAILS_ID IN NUMBER,
       x_TRANSCRIPT_ID IN NUMBER,
       x_TERM IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_TOTAL_CP_ATTEMPTED IN NUMBER,
       x_TOTAL_CP_EARNED IN NUMBER,
       x_TOTAL_UNIT_GP IN NUMBER,
       x_TOTAL_GPA_UNITS IN NUMBER,
       x_GPA IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
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
               x_term_details_id=>X_TERM_DETAILS_ID,
               x_transcript_id=>X_TRANSCRIPT_ID,
               x_term=>X_TERM,
               x_start_date=>X_START_DATE,
               x_end_date=>X_END_DATE,
               x_total_cp_attempted=>X_TOTAL_CP_ATTEMPTED,
               x_total_cp_earned=>X_TOTAL_CP_EARNED,
               x_total_unit_gp=>X_TOTAL_UNIT_GP,
               x_total_gpa_units=>X_TOTAL_GPA_UNITS,
               x_gpa=>X_GPA,
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
 update IGS_AD_TERM_DETAILS set
      TRANSCRIPT_ID =  NEW_REFERENCES.TRANSCRIPT_ID,
      TERM =  NEW_REFERENCES.TERM,
      START_DATE =  NEW_REFERENCES.START_DATE,
      END_DATE =  NEW_REFERENCES.END_DATE,
      TOTAL_CP_ATTEMPTED =  NEW_REFERENCES.TOTAL_CP_ATTEMPTED,
      TOTAL_CP_EARNED =  NEW_REFERENCES.TOTAL_CP_EARNED,
      TOTAL_UNIT_GP =  NEW_REFERENCES.TOTAL_UNIT_GP,
      TOTAL_GPA_UNITS =  NEW_REFERENCES.TOTAL_GPA_UNITS,
      GPA =  NEW_REFERENCES.GPA,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
,       REQUEST_ID = X_REQUEST_ID,
        PROGRAM_ID = X_PROGRAM_ID,
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
       x_TERM_DETAILS_ID IN OUT NOCOPY NUMBER,
       x_TRANSCRIPT_ID IN NUMBER,
       x_TERM IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_TOTAL_CP_ATTEMPTED IN NUMBER,
       x_TOTAL_CP_EARNED IN NUMBER,
       x_TOTAL_UNIT_GP IN NUMBER,
       x_TOTAL_GPA_UNITS IN NUMBER,
       x_GPA IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
 /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_TERM_DETAILS
             where     TERM_DETAILS_ID= X_TERM_DETAILS_ID
;
begin
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    INSERT_ROW (
      X_ROWID,
       X_TERM_DETAILS_ID,
       X_TRANSCRIPT_ID,
       X_TERM,
       X_START_DATE,
       X_END_DATE,
       X_TOTAL_CP_ATTEMPTED,
       X_TOTAL_CP_EARNED,
       X_TOTAL_UNIT_GP,
       X_TOTAL_GPA_UNITS,
       X_GPA,
      X_MODE );
     return;
        end if;
           close c1;
UPDATE_ROW (
      X_ROWID,
       X_TERM_DETAILS_ID,
       X_TRANSCRIPT_ID,
       X_TERM,
       X_START_DATE,
       X_END_DATE,
       X_TOTAL_CP_ATTEMPTED,
       X_TOTAL_CP_EARNED,
       X_TOTAL_UNIT_GP,
       X_TOTAL_GPA_UNITS,
       X_GPA,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
  /*************************************************************
  Created By : knaraset.in
  Date Created By : 2000/05/16
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
 delete from IGS_AD_TERM_DETAILS
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
END igs_ad_term_details_pkg;

/
