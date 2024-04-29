--------------------------------------------------------
--  DDL for Package Body IGS_AD_APPL_PGMAPPRV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APPL_PGMAPPRV_PKG" AS
/* $Header: IGSAIA5B.pls 120.5 2005/10/03 08:23:00 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_appl_pgmapprv%RowType;
  new_references igs_ad_appl_pgmapprv%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_appl_pgmapprv_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_pgm_approver_id IN NUMBER DEFAULT NULL,
    x_assign_type IN VARCHAR2 DEFAULT NULL,
    x_assign_date IN DATE DEFAULT NULL,
    x_program_approval_date IN DATE DEFAULT NULL,
    x_program_approval_status IN VARCHAR2 DEFAULT NULL,
    x_approval_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
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
      FROM     IGS_AD_APPL_PGMAPPRV
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
    new_references.appl_pgmapprv_id := x_appl_pgmapprv_id;
    new_references.person_id := x_person_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.nominated_course_cd := x_nominated_course_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.pgm_approver_id := x_pgm_approver_id;
    new_references.assign_type := x_assign_type;
    new_references.assign_date := TRUNC(x_assign_date);
    new_references.program_approval_date := TRUNC(x_program_approval_date);
    new_references.program_approval_status := x_program_approval_status;
    new_references.approval_notes := x_approval_notes;
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
      ELSIF  UPPER(column_name) = 'ASSIGN_TYPE'  THEN
        new_references.assign_type := column_value;
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'ASSIGN_TYPE' OR
        Column_Name IS NULL THEN
        IF NOT (new_references.assign_type IN ('M','A'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
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
                IF Get_Uk_For_Validation (
                new_references.pgm_approver_id
                ,new_references.sequence_number
                ,new_references.admission_appl_number
                ,new_references.nominated_course_cd
                ,new_references.person_id
                ) THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
                        app_exception.raise_exception;
                END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
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

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number) AND
         (old_references.nominated_course_cd = new_references.nominated_course_cd) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL) OR
         (new_references.nominated_course_cd IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Ps_Appl_Inst_Pkg.Get_PK_For_Validation (
                        new_references.person_id,
                         new_references.admission_appl_number,
                         new_references.nominated_course_cd,
                         new_references.sequence_number
        )  THEN
         Fnd_Message.Set_Name ('FND','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM_APPL'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
   END IF;
   IF (((old_references.Program_Approval_Status = new_references.Program_Approval_Status)) OR
        ((new_references.Program_Approval_Status IS NULL))) THEN
      NULL;
   ELSIF NOT Igs_lookups_view_pkg.get_pk_for_validation(
                        'PROGRAM_APPROVAL_STATUS',
                         new_references.Program_Approval_Status) THEN
                 Fnd_Message.Set_Name ('FND','IGS_GE_PK_UK_NOT_FOUND');
--Message changed by ravishar
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PGM_APPROVAL_STATUS'));
                IGS_GE_MSG_STACK.ADD;
                 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.pgm_approver_id = new_references.pgm_approver_id)) OR
        ((new_references.pgm_approver_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation (
                        new_references.pgm_approver_id
        )  THEN
             Fnd_Message.Set_Name ('FND','IGS_GE_PK_UK_NOT_FOUND');
--Message changed by ravishar
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PGM_APPROVER'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_appl_pgmapprv_id IN NUMBER
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
      FROM     igs_ad_appl_pgmapprv
      WHERE    appl_pgmapprv_id = x_appl_pgmapprv_id
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
    x_pgm_approver_id IN NUMBER,
    x_sequence_number IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_person_id IN NUMBER
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
      FROM     igs_ad_appl_pgmapprv
      WHERE    pgm_approver_id = x_pgm_approver_id
      AND      sequence_number = x_sequence_number
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
      AND      person_id = x_person_id  and      ((l_rowid is null) or (rowid <> l_rowid))

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
  PROCEDURE Get_FK_Igs_Ad_Ps_Appl_Inst (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
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

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_appl_pgmapprv
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
      AND      sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAPGM_ACAI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Ps_Appl_Inst;

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
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
      FROM     igs_ad_appl_pgmapprv
      WHERE    pgm_approver_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAPGM_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;

    PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_appl_pgmapprv_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_pgm_approver_id IN NUMBER DEFAULT NULL,
    x_assign_type IN VARCHAR2 DEFAULT NULL,
    x_assign_date IN DATE DEFAULT NULL,
    x_program_approval_date IN DATE DEFAULT NULL,
    x_program_approval_status IN VARCHAR2 DEFAULT NULL,
    x_approval_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
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
      x_appl_pgmapprv_id,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_pgm_approver_id,
      x_assign_type,
      x_assign_date,
      x_program_approval_date,
      x_program_approval_status,
      x_approval_notes,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    igs_ad_gen_002.check_adm_appl_inst_stat(
      nvl(x_person_id,old_references.person_id),
      nvl(x_admission_appl_number,old_references.admission_appl_number),
      nvl(x_nominated_course_cd,old_references.nominated_course_cd),
      nvl(x_sequence_number,old_references.sequence_number)
      );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
             IF Get_Pk_For_Validation(
                new_references.appl_pgmapprv_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
                new_references.appl_pgmapprv_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Uniqueness;
      Check_Constraints;
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

  l_rowid:=NULL;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_APPL_PGMAPPRV_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PGM_APPROVER_ID IN NUMBER,
       x_ASSIGN_TYPE IN VARCHAR2,
       x_ASSIGN_DATE IN DATE,
       x_PROGRAM_APPROVAL_DATE IN DATE,
       x_PROGRAM_APPROVAL_STATUS IN VARCHAR2,
       x_APPROVAL_NOTES IN VARCHAR2,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  RAVISHAR        Feb,25 2005     Removed the default value of X_MODE parameter from
                                  body of this package for bug 4163319
				  GSCC standard says that default value should be
				  present only in specification
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_APPL_PGMAPPRV
             where                 APPL_PGMAPPRV_ID= X_APPL_PGMAPPRV_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;

     l_mode  VARCHAR2(1);
 begin
   l_mode := NVL(X_MODE , 'R');
    X_LAST_UPDATE_DATE := SYSDATE;
    if(l_mode = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (l_mode IN ('R','S')) then
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

   X_APPL_PGMAPPRV_ID := -1;
   Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
               x_appl_pgmapprv_id=>X_APPL_PGMAPPRV_ID,
               x_person_id=>X_PERSON_ID,
               x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
               x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
               x_sequence_number=>X_SEQUENCE_NUMBER,
               x_pgm_approver_id=>X_PGM_APPROVER_ID,
               x_assign_type=>X_ASSIGN_TYPE,
               x_assign_date=>X_ASSIGN_DATE,
               x_program_approval_date=>X_PROGRAM_APPROVAL_DATE,
               x_program_approval_status=>X_PROGRAM_APPROVAL_STATUS,
               x_approval_notes=>X_APPROVAL_NOTES,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN);
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;

 insert into IGS_AD_APPL_PGMAPPRV (
                APPL_PGMAPPRV_ID
                ,PERSON_ID
                ,ADMISSION_APPL_NUMBER
                ,NOMINATED_COURSE_CD
                ,SEQUENCE_NUMBER
                ,PGM_APPROVER_ID
                ,ASSIGN_TYPE
                ,ASSIGN_DATE
                ,PROGRAM_APPROVAL_DATE
                ,PROGRAM_APPROVAL_STATUS
                ,APPROVAL_NOTES
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
                 IGS_AD_APPL_PGMAPPRV_S.NEXTVAL
                ,NEW_REFERENCES.PERSON_ID
                ,NEW_REFERENCES.ADMISSION_APPL_NUMBER
                ,NEW_REFERENCES.NOMINATED_COURSE_CD
                ,NEW_REFERENCES.SEQUENCE_NUMBER
                ,NEW_REFERENCES.PGM_APPROVER_ID
                ,NEW_REFERENCES.ASSIGN_TYPE
                ,NEW_REFERENCES.ASSIGN_DATE
                ,NEW_REFERENCES.PROGRAM_APPROVAL_DATE
                ,NEW_REFERENCES.PROGRAM_APPROVAL_STATUS
                ,NEW_REFERENCES.APPROVAL_NOTES
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
                ,X_REQUEST_ID
                ,X_PROGRAM_ID
                ,X_PROGRAM_APPLICATION_ID
                ,X_PROGRAM_UPDATE_DATE
)RETURNING APPL_PGMAPPRV_ID INTO X_APPL_PGMAPPRV_ID;
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

NULL;
EXCEPTION
  WHEN OTHERS THEN
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;

end INSERT_ROW;
 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_APPL_PGMAPPRV_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PGM_APPROVER_ID IN NUMBER,
       x_ASSIGN_TYPE IN VARCHAR2,
       x_ASSIGN_DATE IN DATE,
       x_PROGRAM_APPROVAL_DATE IN DATE,
       x_PROGRAM_APPROVAL_STATUS IN VARCHAR2,
       x_APPROVAL_NOTES IN VARCHAR2  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  rgangara       23-Oct-2001     Added code to allow Program_approval_date, program_aproval_status being NULL.
                                 Since these are Nullabel columns in the Table.
                                 Also in the comparison of Assign Date, the TRUNC has been added so that the time
                                 part is not compared because the table column has time stored and the input parameter
                                 just sends in the date without Time part.
                                 Bug No: 2048513
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      PERSON_ID
,      ADMISSION_APPL_NUMBER
,      NOMINATED_COURSE_CD
,      SEQUENCE_NUMBER
,      PGM_APPROVER_ID
,      ASSIGN_TYPE
,      ASSIGN_DATE
,      PROGRAM_APPROVAL_DATE
,      PROGRAM_APPROVAL_STATUS
,      APPROVAL_NOTES
    from IGS_AD_APPL_PGMAPPRV
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
if ( (  tlinfo.PERSON_ID = X_PERSON_ID)
  AND (tlinfo.ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER)
  AND (tlinfo.NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD)
  AND (tlinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
  AND (tlinfo.PGM_APPROVER_ID = X_PGM_APPROVER_ID)
  AND (tlinfo.ASSIGN_TYPE = X_ASSIGN_TYPE)
  AND (TRUNC(tlinfo.ASSIGN_DATE) = TRUNC(X_ASSIGN_DATE))
  AND (TRUNC(tlinfo.PROGRAM_APPROVAL_DATE) = TRUNC(X_PROGRAM_APPROVAL_DATE))
      OR ((tlinfo.program_approval_date IS NULL)
          AND (x_program_approval_date IS NULL))
  AND (tlinfo.PROGRAM_APPROVAL_STATUS = X_PROGRAM_APPROVAL_STATUS)
      OR  ((tlinfo.program_approval_status IS NULL)
          AND (x_program_approval_status IS NULL))
  AND ((tlinfo.APPROVAL_NOTES = X_APPROVAL_NOTES)
            OR ((tlinfo.APPROVAL_NOTES is null)
                AND (X_APPROVAL_NOTES is null)))
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
       x_APPL_PGMAPPRV_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PGM_APPROVER_ID IN NUMBER,
       x_ASSIGN_TYPE IN VARCHAR2,
       x_ASSIGN_DATE IN DATE,
       x_PROGRAM_APPROVAL_DATE IN DATE,
       x_PROGRAM_APPROVAL_STATUS IN VARCHAR2,
       x_APPROVAL_NOTES IN VARCHAR2,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  RAVISHAR        Feb,25 2005     Removed the default value of X_MODE parameter from
                                  body of this package for bug 4163319
  				  GSCC standard says that default value should be
				  present only in specification
(reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;

     l_mode    VARCHAR2(1);
 begin
    l_mode := NVL(X_MODE,'R');
    X_LAST_UPDATE_DATE := SYSDATE;
    if(l_mode = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (l_mode IN ('R','S')) then
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
               x_appl_pgmapprv_id=>X_APPL_PGMAPPRV_ID,
               x_person_id=>X_PERSON_ID,
               x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
               x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
               x_sequence_number=>X_SEQUENCE_NUMBER,
               x_pgm_approver_id=>X_PGM_APPROVER_ID,
               x_assign_type=>X_ASSIGN_TYPE,
               x_assign_date=>X_ASSIGN_DATE,
               x_program_approval_date=>X_PROGRAM_APPROVAL_DATE,
               x_program_approval_status=>X_PROGRAM_APPROVAL_STATUS,
               x_approval_notes=>X_APPROVAL_NOTES,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN);

    if (l_mode IN ('R','S')) then
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
 update IGS_AD_APPL_PGMAPPRV set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      ADMISSION_APPL_NUMBER =  NEW_REFERENCES.ADMISSION_APPL_NUMBER,
      NOMINATED_COURSE_CD =  NEW_REFERENCES.NOMINATED_COURSE_CD,
      SEQUENCE_NUMBER =  NEW_REFERENCES.SEQUENCE_NUMBER,
      PGM_APPROVER_ID =  NEW_REFERENCES.PGM_APPROVER_ID,
      ASSIGN_TYPE =  NEW_REFERENCES.ASSIGN_TYPE,
      ASSIGN_DATE =  NEW_REFERENCES.ASSIGN_DATE,
      PROGRAM_APPROVAL_DATE =  NEW_REFERENCES.PROGRAM_APPROVAL_DATE,
      PROGRAM_APPROVAL_STATUS =  NEW_REFERENCES.PROGRAM_APPROVAL_STATUS,
      APPROVAL_NOTES =  NEW_REFERENCES.APPROVAL_NOTES,
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
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_APPL_PGMAPPRV_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PGM_APPROVER_ID IN NUMBER,
       x_ASSIGN_TYPE IN VARCHAR2,
       x_ASSIGN_DATE IN DATE,
       x_PROGRAM_APPROVAL_DATE IN DATE,
       x_PROGRAM_APPROVAL_STATUS IN VARCHAR2,
       x_APPROVAL_NOTES IN VARCHAR2,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  RAVISHAR        Feb,25 2005     Removed the default value of X_MODE parameter from
                                  body of this package for bug 4163319
  				  GSCC standard says that default value should be
				  present only in specification
(reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_APPL_PGMAPPRV
             where     APPL_PGMAPPRV_ID= X_APPL_PGMAPPRV_ID
;

 l_mode VARCHAR2(1);
begin
   l_mode := NVL(X_MODE,'R');
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    INSERT_ROW (
      X_ROWID,
       X_APPL_PGMAPPRV_ID,
       X_PERSON_ID,
       X_ADMISSION_APPL_NUMBER,
       X_NOMINATED_COURSE_CD,
       X_SEQUENCE_NUMBER,
       X_PGM_APPROVER_ID,
       X_ASSIGN_TYPE,
       X_ASSIGN_DATE,
       X_PROGRAM_APPROVAL_DATE,
       X_PROGRAM_APPROVAL_STATUS,
       X_APPROVAL_NOTES,
      l_mode );
     return;
        end if;
           close c1;
UPDATE_ROW (
      X_ROWID,
       X_APPL_PGMAPPRV_ID,
       X_PERSON_ID,
       X_ADMISSION_APPL_NUMBER,
       X_NOMINATED_COURSE_CD,
       X_SEQUENCE_NUMBER,
       X_PGM_APPROVER_ID,
       X_ASSIGN_TYPE,
       X_ASSIGN_DATE,
       X_PROGRAM_APPROVAL_DATE,
       X_PROGRAM_APPROVAL_STATUS,
       X_APPROVAL_NOTES,
      l_mode );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
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
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_AD_APPL_PGMAPPRV
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
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end DELETE_ROW;
END igs_ad_appl_pgmapprv_pkg;

/
