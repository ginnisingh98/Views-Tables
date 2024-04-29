--------------------------------------------------------
--  DDL for Package Body IGR_I_A_PKGITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_A_PKGITM_PKG" as
/* $Header: IGSRH18B.pls 120.0 2005/06/01 13:25:52 appldev noship $ */


 l_rowid VARCHAR2(25);
  old_references IGR_I_A_PKGITM%RowType;
  new_references IGR_I_A_PKGITM%RowType;
PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_enquiry_appl_number IN NUMBER DEFAULT NULL,
    x_PACKAGE_ITEM_ID IN NUMBER DEFAULT NULL,
    x_mailed_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_donot_mail_ind IN VARCHAR2 DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGR_I_A_PKGITM
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.enquiry_appl_number := x_enquiry_appl_number;
    new_references.PACKAGE_ITEM_ID:= x_PACKAGE_ITEM_ID;
    new_references.mailed_dt := TRUNC(x_mailed_dt);
    new_references.donot_mail_ind := x_donot_mail_ind;
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

 PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
    CURSOR c_deceased(cp_party_id igs_pe_hz_parties.party_id%TYPE) IS
     SELECT deceased_ind
     FROM igs_pe_hz_parties
     WHERE party_id = cp_party_id;
   v_deceased_ind igs_pe_hz_parties.deceased_ind%TYPE;
   v_message_name  varchar2(30);
  BEGIN
    -- Fetch the Deceased Indicator
    IF p_inserting OR p_updating THEN
          OPEN c_deceased(new_references.person_id);
      FETCH c_deceased INTO v_deceased_ind;
      CLOSE c_deceased;
        ELSIF p_deleting THEN
          OPEN c_deceased(old_references.person_id);
      FETCH c_deceased INTO v_deceased_ind;
      CLOSE c_deceased;
    END IF;
        -- Validate that inserts/updates/deletes are allowed if a person is deceased
        -- Validate that the person is not deceased
        IF v_deceased_ind = 'Y' THEN
           Fnd_Message.Set_Name('IGS', 'IGS_IN_DEC_NO_INQ');
       IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
    END IF;
    -- Validate that the item mailed date is not prior to the enquiry date.
    IF p_inserting OR
       (p_updating AND
       (new_references.mailed_dt <> NVL(TRUNC(old_references.mailed_dt), new_references.mailed_dt - 1 ))) THEN
        IF IGR_VAL_EAPMPI.admp_val_eapmpi_dt(new_references.person_id,
                        new_references.enquiry_appl_number,
                        new_references.mailed_dt,
                        v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
             IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
        END IF;
    END IF;


  END BeforeRowInsertUpdateDelete1;

PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.enquiry_appl_number = new_references.enquiry_appl_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.enquiry_appl_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGR_I_APPL_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.enquiry_appl_number
        ))THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENQ_APPL'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.PACKAGE_ITEM_ID = new_references.PACKAGE_ITEM_ID)) OR
        ((new_references.PACKAGE_ITEM_ID IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGR_I_PKG_ITEM_PKG.Get_PK_For_Validation (
        new_references.PACKAGE_ITEM_ID
        ))THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENQ_PACKAGE_ITEM'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

PROCEDURE Check_Constraints (
Column_Name IN  VARCHAR2    DEFAULT NULL,
Column_Value    IN  VARCHAR2    DEFAULT NULL
    ) as
BEGIN
      IF  column_name is null then
         NULL;
      ELSIF upper(Column_name) = 'PACKAGE_ITEM_ID' then
         new_references.PACKAGE_ITEM_ID:= column_value;
      ELSIF upper(Column_name) = 'DONOT_MAIL_IND' then
         new_references.PACKAGE_ITEM_ID:= column_value;
      END IF;
     IF upper(column_name) = 'PACKAGE_ITEM_ID' OR
        column_name is null Then
        IF new_references.PACKAGE_ITEM_ID <> UPPER(new_references.PACKAGE_ITEM_ID) Then
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENQ_PACKAGE_ITEM'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'DONOT_MAIL_IND' OR
        column_name is null Then
        IF new_references.donot_mail_ind IS NOT NULL THEN
          IF new_references.donot_mail_ind NOT IN ('Y','N') THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_MAIL_INF'));
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
          END IF;
        END IF;
     END IF;

END Check_Constraints;


  FUNCTION   Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_enquiry_appl_number IN NUMBER,
    x_PACKAGE_ITEM_ID IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_A_PKGITM
      WHERE    person_id = x_person_id
      AND      enquiry_appl_number = x_enquiry_appl_number
      AND      PACKAGE_ITEM_ID = x_PACKAGE_ITEM_ID
      FOR UPDATE NOWAIT;

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

  PROCEDURE GET_FK_IGR_I_APPL (
    x_person_id IN NUMBER,
    x_enquiry_appl_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_A_PKGITM
      WHERE    person_id = x_person_id
      AND      enquiry_appl_number = x_enquiry_appl_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_IN_EAPMPI_EAP_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGR_I_APPL;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_enquiry_appl_number IN NUMBER DEFAULT NULL,
    x_PACKAGE_ITEM_ID IN NUMBER DEFAULT NULL,
    x_mailed_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_donot_mail_ind IN VARCHAR2 DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_enquiry_appl_number,
      x_PACKAGE_ITEM_ID,
      x_mailed_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_donot_mail_ind
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
IF  Get_PK_For_Validation (
             new_references.person_id ,
             new_references.enquiry_appl_number,
             new_references.PACKAGE_ITEM_ID

                         ) THEN
    Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
END IF;

      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
IF  Get_PK_For_Validation (
             new_references.person_id ,
             new_references.enquiry_appl_number,
             new_references.PACKAGE_ITEM_ID

                         ) THEN
    Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
END IF;
            Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
            Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    END IF;
  END Before_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_PACKAGE_ITEM_ID in NUMBER,
  X_MAILED_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_DONOT_MAIL_IND IN VARCHAR2 DEFAULT NULL,
  X_ACTION IN VARCHAR2,
  X_ret_status     OUT NOCOPY VARCHAR2,
  X_msg_data       OUT NOCOPY VARCHAR2,
  X_msg_count      OUT NOCOPY NUMBER
  ) as
    cursor C is select ROWID from IGR_I_A_PKGITM
      where PERSON_ID = X_PERSON_ID
      and ENQUIRY_APPL_NUMBER = X_ENQUIRY_APPL_NUMBER
      and PACKAGE_ITEM_ID = X_PACKAGE_ITEM_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;

    CURSOR cur_sales_lead_id (p_person_id igr_i_appl_v.person_id%TYPE,
                              p_enquiry_appl_number igr_i_appl_v.enquiry_appl_number%TYPE ) IS
    SELECT sales_lead_id
    FROM   igr_i_appl_v
    WHERE  person_id = p_person_id
    AND    enquiry_appl_number = p_enquiry_appl_number ;

    p_sales_lead_id    igr_i_appl_v.sales_lead_id%TYPE;

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
  if (X_REQUEST_ID = -1) then
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

   Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_enquiry_appl_number=>X_ENQUIRY_APPL_NUMBER,
  x_PACKAGE_ITEM_ID=>X_PACKAGE_ITEM_ID,
  x_mailed_dt=>X_MAILED_DT,
  x_person_id=>X_PERSON_ID,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_donot_mail_ind=>X_DONOT_MAIL_IND
  );
  insert into IGR_I_A_PKGITM (
    PERSON_ID,
    ENQUIRY_APPL_NUMBER,
    PACKAGE_ITEM_ID,
    MAILED_DT,
    DONOT_MAIL_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ENQUIRY_APPL_NUMBER,
    NEW_REFERENCES.PACKAGE_ITEM_ID,
    NEW_REFERENCES.MAILED_DT,
    NEW_REFERENCES.DONOT_MAIL_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  OPEN  cur_sales_lead_id(NEW_REFERENCES.PERSON_ID,  NEW_REFERENCES.ENQUIRY_APPL_NUMBER);
  FETCH cur_sales_lead_id INTO p_sales_lead_id   ;
  CLOSE cur_sales_lead_id;

  Igr_in_jtf_interactions_pkg.start_int_and_act (     p_doc_ref	=>  'AMS_DELV',
                         p_person_id      =>  NEW_REFERENCES.PERSON_ID,
             p_sales_lead_id  =>  p_sales_lead_id,
                         p_item_id    =>  NEW_REFERENCES.PACKAGE_ITEM_ID,
             p_doc_id         =>  NEW_REFERENCES.PACKAGE_ITEM_ID,
                         p_action         =>  X_ACTION ,
                         p_action_item    => 'PACKAGE_ITEM',
                     p_ret_status     =>  x_ret_status,
             p_msg_data       =>  x_msg_count,
                     p_msg_count      =>  x_msg_count);


 end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_PACKAGE_ITEM_ID in NUMBER,
  X_MAILED_DT in DATE,
  X_DONOT_MAIL_IND IN VARCHAR2 DEFAULT NULL
) as
  cursor c1 is select
      MAILED_DT,DONOT_MAIL_IND
    from IGR_I_A_PKGITM
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

      if ( ((TRUNC(tlinfo.MAILED_DT) = TRUNC(X_MAILED_DT)) OR ((tlinfo.MAILED_DT is null) AND (X_MAILED_DT is null))) AND
           ((tlinfo.DONOT_MAIL_IND = X_DONOT_MAIL_IND) OR ((tlinfo.DONOT_MAIL_IND is null) AND (X_DONOT_MAIL_IND is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_PACKAGE_ITEM_ID in NUMBER,
  X_MAILED_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_DONOT_MAIL_IND IN VARCHAR2 DEFAULT NULL,
  X_ACTION IN VARCHAR2,
  X_ret_status     OUT NOCOPY VARCHAR2,
  X_msg_data       OUT NOCOPY VARCHAR2,
  X_msg_count      OUT NOCOPY NUMBER

  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
    CURSOR cur_sales_lead_id (p_person_id igr_i_appl_v.person_id%TYPE,
                              p_enquiry_appl_number igr_i_appl_v.enquiry_appl_number%TYPE ) IS
    SELECT sales_lead_id
    FROM   igr_i_appl_v
    WHERE  person_id = p_person_id
    AND    enquiry_appl_number = p_enquiry_appl_number ;

    p_sales_lead_id    igr_i_appl_v.sales_lead_id%TYPE;

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
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
    if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID :=
                OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE :=
                  OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
end if;

   Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_enquiry_appl_number=>X_ENQUIRY_APPL_NUMBER,
  x_PACKAGE_ITEM_ID=>X_PACKAGE_ITEM_ID,
  x_mailed_dt=>X_MAILED_DT,
  x_person_id=>X_PERSON_ID,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_donot_mail_ind=>X_DONOT_MAIL_IND
  );

  update IGR_I_A_PKGITM set
    MAILED_DT = NEW_REFERENCES.MAILED_DT,
    DONOT_MAIL_IND = NEW_REFERENCES.DONOT_MAIL_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  OPEN  cur_sales_lead_id(NEW_REFERENCES.PERSON_ID,  NEW_REFERENCES.ENQUIRY_APPL_NUMBER);
  FETCH cur_sales_lead_id INTO p_sales_lead_id   ;
  CLOSE cur_sales_lead_id;

  Igr_in_jtf_interactions_pkg.start_int_and_act (     p_doc_ref	=>  'AMS_DELV',
                         p_person_id      =>  NEW_REFERENCES.PERSON_ID,
             p_sales_lead_id  =>  p_sales_lead_id,
                         p_item_id    =>  NEW_REFERENCES.PACKAGE_ITEM_ID,
             p_doc_id         =>  NEW_REFERENCES.PACKAGE_ITEM_ID,
                         p_action         =>  X_ACTION ,
                         p_action_item    => 'PACKAGE_ITEM',
                     p_ret_status     =>  x_ret_status,
             p_msg_data       =>  x_msg_count,
                     p_msg_count      =>  x_msg_count);

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_PACKAGE_ITEM_ID in NUMBER,
  X_MAILED_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_DONOT_MAIL_IND IN VARCHAR2 DEFAULT NULL,
  X_ACTION IN VARCHAR2,
  X_ret_status     OUT NOCOPY VARCHAR2,
  X_msg_data       OUT NOCOPY VARCHAR2,
  X_msg_count      OUT NOCOPY NUMBER

  ) as
  cursor c1 is select rowid from IGR_I_A_PKGITM
     where PERSON_ID = X_PERSON_ID
     and ENQUIRY_APPL_NUMBER = X_ENQUIRY_APPL_NUMBER
     and PACKAGE_ITEM_ID = X_PACKAGE_ITEM_ID
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_ENQUIRY_APPL_NUMBER,
     X_PACKAGE_ITEM_ID,
     X_MAILED_DT,
     X_MODE,
     X_DONOT_MAIL_IND,
     X_ACTION ,
     X_ret_status  ,
     X_msg_data     ,
     X_msg_count    );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ENQUIRY_APPL_NUMBER,
   X_PACKAGE_ITEM_ID,
   X_MAILED_DT,
   X_MODE,
   X_DONOT_MAIL_IND,
   X_ACTION,
   X_ret_status ,
   X_msg_data    ,
   X_msg_count     );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
  Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGR_I_A_PKGITM
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGR_I_A_PKGITM_PKG;

/
