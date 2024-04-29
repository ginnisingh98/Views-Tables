--------------------------------------------------------
--  DDL for Package Body IGS_PS_USEC_LIM_WLST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_USEC_LIM_WLST_PKG" AS
/* $Header: IGSPI1LB.pls 120.2 2005/07/04 05:46:01 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_usec_lim_wlst%RowType;
  new_references igs_ps_usec_lim_wlst%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_section_limit_wlst_id IN NUMBER ,
    x_uoo_id IN NUMBER ,
    x_enrollment_expected IN NUMBER ,
    x_enrollment_minimum IN NUMBER ,
    x_enrollment_maximum IN NUMBER ,
    x_advance_maximum IN NUMBER ,
    x_waitlist_allowed IN VARCHAR2 ,
    x_max_students_per_waitlist IN NUMBER ,
    x_override_enrollment_max IN NUMBER ,
    x_max_auditors_allowed IN NUMBER,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur     31-Oct-2002    Enh#2636716.Added new column max_auditors_allowed.
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_USEC_LIM_WLST
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
    new_references.unit_section_limit_waitlist_id := x_unit_section_limit_wlst_id;
    new_references.uoo_id := x_uoo_id;
    new_references.enrollment_expected := x_enrollment_expected;
    new_references.enrollment_minimum := x_enrollment_minimum;
    new_references.enrollment_maximum := x_enrollment_maximum;
    new_references.advance_maximum := x_advance_maximum;
    new_references.waitlist_allowed := x_waitlist_allowed;
    new_references.max_students_per_waitlist := x_max_students_per_waitlist;
    new_references.override_enrollment_max := x_override_enrollment_max ;
    new_references.max_auditors_allowed := x_max_auditors_allowed;

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
                 Column_Value IN VARCHAR2   ) AS
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

 PROCEDURE Check_Uniqueness AS
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
                IF Get_Uk_For_Validation (
                new_references.uoo_id
                ) THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
                        app_exception.raise_exception;
                END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
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

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Unit_Ofr_Opt_Pkg.Get_UK_For_Validation (
                        new_references.uoo_id
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_section_limit_wlst_id IN NUMBER
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
      FROM     igs_ps_usec_lim_wlst
      WHERE    unit_section_limit_waitlist_id = x_unit_section_limit_wlst_id
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
    x_uoo_id IN NUMBER
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
      FROM     igs_ps_usec_lim_wlst
      WHERE    uoo_id = x_uoo_id        and      ((l_rowid is null) or (rowid <> l_rowid))

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
  PROCEDURE Get_UFK_Igs_Ps_Unit_Ofr_Opt (
    x_uoo_id IN NUMBER
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
      FROM     igs_ps_usec_lim_wlst
      WHERE    uoo_id = x_uoo_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_USLW_UOO_UFK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_UFK_Igs_Ps_Unit_Ofr_Opt;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_section_limit_wlst_id IN NUMBER ,
    x_uoo_id IN NUMBER ,
    x_enrollment_expected IN NUMBER ,
    x_enrollment_minimum IN NUMBER ,
    x_enrollment_maximum IN NUMBER ,
    x_advance_maximum IN NUMBER ,
    x_waitlist_allowed IN VARCHAR2 ,
    x_max_students_per_waitlist IN NUMBER ,
    x_override_enrollment_max IN NUMBER ,
    x_max_auditors_allowed IN NUMBER,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur     31-Oct-2002    Enh#2636716.Added new column max_auditors_allowed.
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_section_limit_wlst_id,
      x_uoo_id,
      x_enrollment_expected,
      x_enrollment_minimum,
      x_enrollment_maximum,
      x_advance_maximum,
      x_waitlist_allowed,
      x_max_students_per_waitlist,
      x_override_enrollment_max,
      x_max_auditors_allowed,
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
                new_references.unit_section_limit_waitlist_id)  THEN
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
                new_references.unit_section_limit_waitlist_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
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
  sarakshi    05-May-2005         Bug#4349740, added the after dml update/insert  logic
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_unit_limit(cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
    SELECT enrollment_maximum,enrollment_expected,override_enrollment_max
    FROM   igs_ps_unit_ver_all uv,
           igs_ps_unit_ofr_opt_all uoo
    WHERE  uv.unit_cd=uoo.unit_cd
    AND    uv.version_number=uoo.version_number
    AND    uoo.uoo_id=cp_uoo_id;
    l_c_unit cur_unit_limit%ROWTYPE;

    l_message_name VARCHAR2(30);
    l_request_id   NUMBER;
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      OPEN cur_unit_limit(new_references.uoo_id);
      FETCH cur_unit_limit INTO l_c_unit;
      CLOSE cur_unit_limit;

      IF   (
       NVL(new_references.enrollment_maximum,-999) <>  NVL(l_c_unit.enrollment_maximum,-999) OR
       NVL(new_references.enrollment_expected,-999) <> NVL(l_c_unit.enrollment_expected,-999) OR
       NVL(new_references.override_enrollment_max,-999) <> NVL(l_c_unit.override_enrollment_max,-999)
      ) THEN

        IF igs_ps_usec_schedule.prgp_upd_usec_dtls(
                                                   p_uoo_id=>new_references.uoo_id,
                                                   p_max_enrollments =>NVL(l_c_unit.enrollment_maximum,-999) ,
                                                   p_override_enrollment_max => NVL(l_c_unit.override_enrollment_max,-999),
                                                   p_enrollment_expected => NVL(l_c_unit.enrollment_expected,-999),
                                                   p_request_id =>l_request_id,
                                                   p_message_name=>l_message_name
                                                  ) = FALSE THEN


          FND_MESSAGE.SET_NAME( 'IGS', 'l_message_name');
          IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
        END IF;
      END IF;
    ELSIF (p_action = 'UPDATE') THEN

      IF   (
       NVL(new_references.enrollment_maximum,-999) <>  NVL(old_references.enrollment_maximum,-999) OR
       NVL(new_references.enrollment_expected,-999) <> NVL(old_references.enrollment_expected,-999) OR
       NVL(new_references.override_enrollment_max,-999) <> NVL(old_references.override_enrollment_max,-999)
      ) THEN


        IF igs_ps_usec_schedule.prgp_upd_usec_dtls(
                                                   p_uoo_id=>new_references.uoo_id,
                                                   p_max_enrollments =>NVL(old_references.enrollment_maximum,-999) ,
                                                   p_override_enrollment_max => NVL(old_references.override_enrollment_max,-999),
                                                   p_enrollment_expected => NVL(old_references.enrollment_expected,-999),
                                                   p_request_id =>l_request_id,
                                                   p_message_name=>l_message_name
                                                  ) = FALSE THEN


          FND_MESSAGE.SET_NAME( 'IGS', 'l_message_name');
          IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
        END IF;
      END IF;


    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      OPEN cur_unit_limit(old_references.uoo_id);
      FETCH cur_unit_limit INTO l_c_unit;
      CLOSE cur_unit_limit;

      IF   (
       NVL(old_references.enrollment_maximum,-999) <>  NVL(l_c_unit.enrollment_maximum,-999) OR
       NVL(old_references.enrollment_expected,-999) <> NVL(l_c_unit.enrollment_expected,-999) OR
       NVL(old_references.override_enrollment_max,-999) <> NVL(l_c_unit.override_enrollment_max,-999)
      ) THEN


        IF igs_ps_usec_schedule.prgp_upd_usec_dtls(
                                                   p_uoo_id=>old_references.uoo_id,
                                                   p_max_enrollments =>NVL(l_c_unit.enrollment_maximum,-999) ,
                                                   p_override_enrollment_max => NVL(l_c_unit.override_enrollment_max,-999),
                                                   p_enrollment_expected => NVL(l_c_unit.enrollment_expected,-999),
                                                   p_request_id =>l_request_id,
                                                   p_message_name=>l_message_name
                                                  ) = FALSE THEN


          FND_MESSAGE.SET_NAME( 'IGS', 'l_message_name');
          IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
        END IF;
      END IF;

    END IF;

  l_rowid:=NULL;
  END After_DML;

 procedure INSERT_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       X_UNIT_SECTION_LIMIT_WLST_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_ENROLLMENT_EXPECTED IN NUMBER,
       x_ENROLLMENT_MINIMUM IN NUMBER,
       x_ENROLLMENT_MAXIMUM IN NUMBER,
       x_ADVANCE_MAXIMUM IN NUMBER,
       x_WAITLIST_ALLOWED IN VARCHAR2,
       x_MAX_STUDENTS_PER_WAITLIST IN NUMBER,
       X_OVERRIDE_ENROLLMENT_MAX IN NUMBER,
       X_MAX_AUDITORS_ALLOWED IN NUMBER,
       X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 (reverse chronological order - newest change first)
 vvutukur     31-Oct-2002    Enh#2636716.Added new column max_auditors_allowed.
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_USEC_LIM_WLST
             where                 UNIT_SECTION_LIMIT_WAITLIST_ID= x_unit_section_limit_wlst_id
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
     igs_ps_usec_lim_wlst_s.nextval
   INTO
     x_unit_section_limit_wlst_id
   FROM dual;
   Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
               x_unit_section_limit_wlst_id=>x_unit_section_limit_wlst_id,
               x_uoo_id=>X_UOO_ID,
               x_enrollment_expected=>X_ENROLLMENT_EXPECTED,
               x_enrollment_minimum=>X_ENROLLMENT_MINIMUM,
               x_enrollment_maximum=>X_ENROLLMENT_MAXIMUM,
               x_advance_maximum=>X_ADVANCE_MAXIMUM,
               x_waitlist_allowed=>X_WAITLIST_ALLOWED,
               x_max_students_per_waitlist=>X_MAX_STUDENTS_PER_WAITLIST,
               x_override_enrollment_max => X_OVERRIDE_ENROLLMENT_MAX,
               x_max_auditors_allowed    => X_MAX_AUDITORS_ALLOWED,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_PS_USEC_LIM_WLST (
                UNIT_SECTION_LIMIT_WAITLIST_ID
                ,UOO_ID
                ,ENROLLMENT_EXPECTED
                ,ENROLLMENT_MINIMUM
                ,ENROLLMENT_MAXIMUM
                ,ADVANCE_MAXIMUM
                ,WAITLIST_ALLOWED
                ,MAX_STUDENTS_PER_WAITLIST
                ,OVERRIDE_ENROLLMENT_MAX
                ,MAX_AUDITORS_ALLOWED
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
        ) values  (
                NEW_REFERENCES.UNIT_SECTION_LIMIT_WAITLIST_ID
                ,NEW_REFERENCES.UOO_ID
                ,NEW_REFERENCES.ENROLLMENT_EXPECTED
                ,NEW_REFERENCES.ENROLLMENT_MINIMUM
                ,NEW_REFERENCES.ENROLLMENT_MAXIMUM
                ,NEW_REFERENCES.ADVANCE_MAXIMUM
                ,NEW_REFERENCES.WAITLIST_ALLOWED
                ,NEW_REFERENCES.MAX_STUDENTS_PER_WAITLIST
                ,NEW_REFERENCES.OVERRIDE_ENROLLMENT_MAX
                ,NEW_REFERENCES.MAX_AUDITORS_ALLOWED
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
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
       x_rowid                      IN  VARCHAR2,
       x_unit_section_limit_wlst_id IN NUMBER,
       x_uoo_id                     IN NUMBER,
       x_enrollment_expected        IN NUMBER,
       x_enrollment_minimum         IN NUMBER,
       x_enrollment_maximum         IN NUMBER,
       x_advance_maximum            IN NUMBER,
       x_waitlist_allowed           IN VARCHAR2,
       x_max_students_per_waitlist  IN NUMBER ,
       x_override_enrollment_max    IN NUMBER,
       x_max_auditors_allowed       IN NUMBER ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 (reverse chronological order - newest change first)
  vvutukur     31-Oct-2002    Enh#2636716.Added new column max_auditors_allowed.
  ***************************************************************/

   CURSOR c1 IS
   SELECT uoo_id,
          enrollment_expected,
          enrollment_minimum,
          enrollment_maximum,
          advance_maximum,
          waitlist_allowed,
          max_students_per_waitlist,
          override_enrollment_max,
          max_auditors_allowed
   FROM   igs_ps_usec_lim_wlst
   WHERE  rowid = x_rowid
   FOR UPDATE NOWAIT;
   tlinfo c1%ROWTYPE;
BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    CLOSE c1;
    APP_EXCEPTION.RAISE_EXCEPTION;
    RETURN;
  END IF;
  CLOSE c1;
IF ( (  tlinfo.uoo_id = x_uoo_id)
  AND ((tlinfo.enrollment_expected = x_enrollment_expected)
            OR ((tlinfo.enrollment_expected IS NULL)
                AND (x_enrollment_expected IS NULL)))
  AND ((tlinfo.enrollment_minimum = x_enrollment_minimum)
            OR ((tlinfo.enrollment_minimum IS NULL)
                AND (x_enrollment_minimum IS NULL)))
  AND ((tlinfo.enrollment_maximum = x_enrollment_maximum)
            OR ((tlinfo.enrollment_maximum IS NULL)
                AND (x_enrollment_maximum IS NULL)))
  AND ((tlinfo.advance_maximum = x_advance_maximum)
            OR ((tlinfo.advance_maximum IS NULL)
                AND (x_advance_maximum IS NULL)))
  AND (tlinfo.waitlist_allowed = x_waitlist_allowed)
  AND (tlinfo.max_students_per_waitlist = x_max_students_per_waitlist)
  AND ((tlinfo.override_enrollment_max = x_override_enrollment_max)
            OR ((tlinfo.override_enrollment_max IS NULL)
                 AND (X_override_enrollment_max IS NULL)))
  AND ((tlinfo.max_auditors_allowed = x_max_auditors_allowed)
            OR ((tlinfo.max_auditors_allowed IS NULL)
                 AND (x_max_auditors_allowed IS NULL)))
  ) THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  RETURN;
END LOCK_ROW;

 PROCEDURE UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_unit_section_limit_wlst_id IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_ENROLLMENT_EXPECTED IN NUMBER,
       x_ENROLLMENT_MINIMUM IN NUMBER,
       x_ENROLLMENT_MAXIMUM IN NUMBER,
       x_ADVANCE_MAXIMUM IN NUMBER,
       x_WAITLIST_ALLOWED IN VARCHAR2,
       x_MAX_STUDENTS_PER_WAITLIST IN NUMBER,
       X_OVERRIDE_ENROLLMENT_MAX IN NUMBER,
       x_max_auditors_allowed IN NUMBER,
       X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 (reverse chronological order - newest change first)
  vvutukur     31-Oct-2002    Enh#2636716.Added new column max_auditors_allowed.
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
               p_action                     =>'UPDATE',
               x_rowid                      =>X_ROWID,
               x_unit_section_limit_wlst_id =>x_unit_section_limit_wlst_id,
               x_uoo_id                     =>X_UOO_ID,
               x_enrollment_expected        =>X_ENROLLMENT_EXPECTED,
               x_enrollment_minimum         =>X_ENROLLMENT_MINIMUM,
               x_enrollment_maximum         =>X_ENROLLMENT_MAXIMUM,
               x_advance_maximum            =>X_ADVANCE_MAXIMUM,
               x_waitlist_allowed           =>X_WAITLIST_ALLOWED,
               x_max_students_per_waitlist  =>X_MAX_STUDENTS_PER_WAITLIST,
               x_override_enrollment_max    =>x_override_enrollment_max,
               x_max_auditors_allowed       =>x_max_auditors_allowed,
               x_creation_date              =>X_LAST_UPDATE_DATE,
               x_created_by                 =>X_LAST_UPDATED_BY,
               x_last_update_date           =>X_LAST_UPDATE_DATE,
               x_last_updated_by            =>X_LAST_UPDATED_BY,
               x_last_update_login          =>X_LAST_UPDATE_LOGIN);
   update IGS_PS_USEC_LIM_WLST set
      UOO_ID =  NEW_REFERENCES.UOO_ID,
      ENROLLMENT_EXPECTED =  NEW_REFERENCES.ENROLLMENT_EXPECTED,
      ENROLLMENT_MINIMUM =  NEW_REFERENCES.ENROLLMENT_MINIMUM,
      ENROLLMENT_MAXIMUM =  NEW_REFERENCES.ENROLLMENT_MAXIMUM,
      ADVANCE_MAXIMUM =  NEW_REFERENCES.ADVANCE_MAXIMUM,
      WAITLIST_ALLOWED =  NEW_REFERENCES.WAITLIST_ALLOWED,
      MAX_STUDENTS_PER_WAITLIST =  NEW_REFERENCES.MAX_STUDENTS_PER_WAITLIST,
      OVERRIDE_ENROLLMENT_MAX = NEW_REFERENCES.OVERRIDE_ENROLLMENT_MAX,
      max_auditors_allowed    = new_references.max_auditors_allowed,
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
END UPDATE_ROW;

 PROCEDURE ADD_ROW (
       x_rowid IN OUT NOCOPY VARCHAR2,
       x_unit_section_limit_wlst_id IN OUT NOCOPY NUMBER,
       x_uoo_id IN NUMBER,
       x_enrollment_expected IN NUMBER,
       x_enrollment_minimum IN NUMBER,
       x_enrollment_maximum IN NUMBER,
       x_advance_maximum IN NUMBER,
       x_waitlist_allowed IN VARCHAR2,
       x_max_students_per_waitlist IN NUMBER,
       x_override_enrollment_max IN NUMBER,
       x_max_auditors_allowed IN NUMBER,
       x_mode IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 (reverse chronological order - newest change first)
 vvutukur     31-Oct-2002    Enh#2636716.Added new column max_auditors_allowed.
  ***************************************************************/

    CURSOR c1 IS
    SELECT rowid
    FROM igs_ps_usec_lim_wlst
    WHERE unit_section_limit_waitlist_id = x_unit_section_limit_wlst_id;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_rowid;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    INSERT_ROW (
       x_rowid,
       x_unit_section_limit_wlst_id,
       x_uoo_id,
       x_enrollment_expected,
       x_enrollment_minimum,
       x_enrollment_maximum,
       x_advance_maximum,
       x_waitlist_allowed,
       x_max_students_per_waitlist,
       x_override_enrollment_max,
       x_max_auditors_allowed,
       x_mode );
     RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
       x_rowid,
       x_unit_section_limit_wlst_id,
       x_uoo_id,
       x_enrollment_expected,
       x_enrollment_minimum,
       x_enrollment_maximum,
       x_advance_maximum,
       x_waitlist_allowed,
       x_max_students_per_waitlist,
       x_override_enrollment_max,
       x_max_auditors_allowed,
       x_mode );
END ADD_ROW;

PROCEDURE DELETE_ROW (
  x_rowid IN VARCHAR2
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
  Before_DML (
              p_action => 'DELETE',
              x_rowid => X_ROWID
              );
  DELETE FROM igs_ps_usec_lim_wlst
  WHERE rowid = x_rowid;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  After_DML (
            p_action => 'DELETE',
            x_rowid => X_ROWID
           );
END DELETE_ROW;
END igs_ps_usec_lim_wlst_pkg;

/
