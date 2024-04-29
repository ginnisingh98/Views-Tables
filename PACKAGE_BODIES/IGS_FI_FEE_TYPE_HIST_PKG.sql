--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_TYPE_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_TYPE_HIST_PKG" AS
 /* $Header: IGSSI39B.pls 120.2 2006/06/09 06:45:04 sapanigr ship $*/
--added columns subaccount_id and fee_class w.r.t Bug 2175865
  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_TYPE_HIST_ALL%RowType;
  new_references IGS_FI_FEE_TYPE_HIST_ALL%RowType;

  -- shtatiko    30-MAY-2003   Enh# 2831582, Added new column designated_payment_flag.
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_fee_type IN VARCHAR2 ,
    x_hist_start_dt IN DATE ,
    x_hist_end_dt IN DATE ,
    x_hist_who IN VARCHAR2 ,
    x_s_fee_type IN VARCHAR2 ,
    x_s_fee_trigger_cat IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_optional_payment_ind IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    x_org_id in NUMBER ,
    x_fee_class      IN VARCHAR2 ,  --Bug 2175865
    x_designated_payment_flag IN VARCHAR2,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_TYPE_HIST_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;

    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.fee_type := x_fee_type;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.s_fee_type := x_s_fee_type;
    new_references.s_fee_trigger_cat := x_s_fee_trigger_cat;
    new_references.description := x_description;
    new_references.optional_payment_ind := x_optional_payment_ind;
    new_references.closed_ind := x_closed_ind;
    new_references.comments := x_comments;
    new_references.org_id := x_org_id;
    new_references.fee_class := x_fee_class;           --Bug 2175865
    new_references.designated_payment_flag := x_designated_payment_flag;

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
   Column_Name                IN        VARCHAR2        ,
   Column_Value         IN        VARCHAR2
   )AS
/*-----------------------------------------------------------------------------
  CHANGE HISTORY:
  WHO        WHEN           WHAT
  pmarada     28-jul-2005   Enh 3392095, added waiver_adj to the system fee type validation
  uudayapr    15-oct-2003   Enh#3117341. Audit and Special Fees Build added AUDIT,SPECIAL also
                            in the list of valid values for system fee types and system fee Trigger
                            category.
  vvutukur    06-Sep-2003   Enh#3045007.Payment Plans Build. Added PAY_PLAN also in the list
                           of valid system fee types.
 vvutukur    18-may-2002    removed upper check on fee_type column.bug#2344826.
  smvk             01-Mar-2002    Added three more System Fee Types w.r.t. Bug # 2144600
  vvutukur   21-feb-2002    removed check for the column "comments" as it allows
                            both and mixed case.Done for bug:2107967
 -------------------------------------------------------------------------------*/

   BEGIN
    IF Column_Name is NULL THEN
                NULL;
        ELSIF upper(Column_Name) = 'S_FEE_TYPE' then
                new_references.s_fee_type := Column_Value;
        ELSIF upper(Column_Name) = 'OPTIONAL_PAYMENT_IND' then
                new_references.optional_payment_ind := Column_Value;
        ELSIF upper(Column_Name) = 'CLOSED_IND' then
                new_references.closed_ind := Column_Value;
        ELSIF upper(Column_Name) = 'DESCRIPTION' then
                new_references.description:= Column_Value;
        ELSIF upper(Column_Name) = 'S_FEE_TRIGGER_CAT' then
                new_references.s_fee_trigger_cat := Column_Value;
   END IF;
        --Added AUDIT AND SPECAIAL ALSO A VALID LIST of S_FEE_TYPE
          IF upper(Column_Name) = 'S_FEE_TYPE' OR
                                column_name is NULL THEN
                              IF new_references.s_fee_type <> 'HECS' AND
                                 new_references.s_fee_type <> 'TUITION' AND
                                 new_references.s_fee_type <> 'OTHER' AND
                                 new_references.s_fee_type <> 'LATE' AND
                                 new_references.s_fee_type <> 'INTEREST' AND
                                 new_references.s_fee_type  <> 'TUTNFEE'  AND
                                 new_references.s_fee_type <> 'SPONSOR' AND
                                 new_references.s_fee_type  <> 'ANCILLARY' AND  -- added w.r.t. Bug # 2144600
                                 new_references.s_fee_type  <> 'EXTERNAL' AND   -- added w.r.t. Bug # 2144600
                                 new_references.s_fee_type <> 'REFUND'  AND          -- added w.r.t. Bug # 2144600
                                 new_references.s_fee_type <> 'AID_ADJ' AND
                                 new_references.s_fee_type <> 'PAY_PLAN' AND
                                 new_references.s_fee_type <> 'AUDIT' AND
                                 new_references.s_fee_type <> 'SPECIAL' AND
                                 new_references.s_fee_type <> 'WAIVER_ADJ' THEN
                                     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                     IGS_GE_MSG_STACK.ADD;
                                     App_Exception.Raise_Exception;
                              END IF;
          END IF;
    IF upper(Column_Name) = 'OPTIONAL_PAYMENT_IND' OR         column_name is NULL THEN
      IF new_references.optional_payment_ind <> 'Y' AND
         new_references.optional_payment_ind <> 'N' THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
                 App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF upper(Column_Name) = 'CLOSED_IND' OR         column_name is NULL THEN
      IF new_references.closed_ind <> 'Y' AND
         new_references.closed_ind <> 'N' THEN
           Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
      END IF;
    END IF;
    -- Added audit and special
    IF upper(Column_Name) = 'S_FEE_TRIGGER_CAT' OR
       column_name is NULL THEN
         IF new_references.S_FEE_TRIGGER_CAT <> 'INSTITUTN' AND
                new_references.S_FEE_TRIGGER_CAT <> 'COURSE' AND
                new_references.S_FEE_TRIGGER_CAT <> 'UNIT' AND
                new_references.S_FEE_TRIGGER_CAT <> 'COMPOSITE' AND
                new_references.S_FEE_TRIGGER_CAT <> 'UNITSET' AND
                new_references.S_FEE_TRIGGER_CAT <> 'AUDIT' AND
                new_references.S_FEE_TRIGGER_CAT <> 'SPECIAL' THEN
                  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
             END IF;
    END IF;
   END Check_Constraints;

--created procedure as part of Bug 2175865
PROCEDURE check_parent_existance AS

  BEGIN
    --  Check for parent existance of fee class
    IF ((old_references.fee_class = new_references.fee_class)
        OR (new_references.fee_class IS NULL)) THEN
      NULL;
    ELSE
      IF NOT igs_lookups_view_pkg.get_pk_for_validation('FEE_CLASS',
                                          new_references.fee_class) THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
END check_parent_existance;


  FUNCTION Get_PK_For_Validation (
    x_fee_type IN VARCHAR2,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_TYPE_HIST_ALL
      WHERE    fee_type = x_fee_type
      AND      hist_start_dt = x_hist_start_dt
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

-- shtatiko    30-MAY-2003   Enh# 2831582, Added new column designated_payment_flag.
--added columns subaccount_id and fee_class w.r.t Bug 2175865
 PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 ,
    x_fee_type IN VARCHAR2 ,
    x_hist_start_dt IN DATE ,
    x_hist_end_dt IN DATE ,
    x_hist_who IN VARCHAR2 ,
    x_s_fee_type IN VARCHAR2 ,
    x_s_fee_trigger_cat IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_optional_payment_ind IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    x_org_id in NUMBER ,
    x_fee_class      IN VARCHAR2 ,  --Bug 2175865
    x_designated_payment_flag IN VARCHAR2,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_type,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_s_fee_type,
      x_s_fee_trigger_cat,
      x_description,
      x_optional_payment_ind,
      x_closed_ind,
      x_comments,
      x_org_id,
      x_fee_class,      --for Bug 2175865
      x_designated_payment_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

          IF Get_PK_For_Validation ( new_references.fee_type,
                                       new_references.hist_start_dt) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
          END IF;
      Check_Constraints;
      check_parent_existance;  --for Bug 2175865
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      check_parent_existance;  --for Bug 2175865
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
     -- Call all the procedures related to Before Insert.
          IF Get_PK_For_Validation ( new_references.fee_type,
                                       new_references.hist_start_dt) THEN
           Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
          END IF;
         Check_Constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
        Check_Constraints;
   END IF;

  END Before_DML;

-- shtatiko    30-MAY-2003   Enh# 2831582, Added new column designated_payment_flag.
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_S_FEE_TYPE in VARCHAR2,
  X_S_FEE_TRIGGER_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OPTIONAL_PAYMENT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 ,
  X_FEE_CLASS      IN VARCHAR2, --Bug 2175865
  x_designated_payment_flag IN VARCHAR2
  ) AS
  /*-----------------------------------------------------------------------------
  CHANGE HISTORY:
  WHO        WHEN           WHAT
  sapanigr  09-Mar-2006   Bug 3296531. Removed NVL clause in call to Before_DML for
                          columns S_FEE_TYPE, S_FEE_TRIGGER_CAT and OPTIONAL_PAYMENT_IND
 -------------------------------------------------------------------------------*/
    cursor C is select ROWID from IGS_FI_FEE_TYPE_HIST_ALL
      where FEE_TYPE = X_FEE_TYPE
      and HIST_START_DT = X_HIST_START_DT;
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


 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_closed_ind=>X_CLOSED_IND,
  x_comments=>X_COMMENTS,
  x_description=>X_DESCRIPTION,
  x_fee_type=>X_FEE_TYPE,
  x_hist_end_dt=>X_HIST_END_DT,
  x_hist_start_dt=>X_HIST_START_DT,
  x_hist_who=>X_HIST_WHO,
  x_optional_payment_ind=>X_OPTIONAL_PAYMENT_IND,
  x_s_fee_trigger_cat=>X_S_FEE_TRIGGER_CAT,
  x_s_fee_type=>X_S_FEE_TYPE,
  x_org_id => igs_ge_gen_003.get_org_id,
  x_fee_class =>X_FEE_CLASS,            --for bug 2175865
  x_designated_payment_flag => x_designated_payment_flag,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
);

  insert into IGS_FI_FEE_TYPE_HIST_ALL (
    FEE_TYPE,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    S_FEE_TYPE,
    S_FEE_TRIGGER_CAT,
    DESCRIPTION,
    OPTIONAL_PAYMENT_IND,
    CLOSED_IND,
    COMMENTS,
    ORG_ID,
    FEE_CLASS,     --for Bug 2175865
    designated_payment_flag,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.S_FEE_TYPE,
    NEW_REFERENCES.S_FEE_TRIGGER_CAT,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.OPTIONAL_PAYMENT_IND,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.FEE_CLASS,     --for Bug 2175865
    new_references.designated_payment_flag,
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

end INSERT_ROW;

-- shtatiko    30-MAY-2003   Enh# 2831582, Added new column designated_payment_flag.
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_S_FEE_TYPE in VARCHAR2,
  X_S_FEE_TRIGGER_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OPTIONAL_PAYMENT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_FEE_CLASS in VARCHAR2,   --for Bug 2175865
  x_designated_payment_flag IN VARCHAR2
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      S_FEE_TYPE,
      S_FEE_TRIGGER_CAT,
      DESCRIPTION,
      OPTIONAL_PAYMENT_IND,
      CLOSED_IND,
      COMMENTS,
      FEE_CLASS,        --for Bug 2175865
      designated_payment_flag
    from IGS_FI_FEE_TYPE_HIST_ALL
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

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.S_FEE_TYPE = X_S_FEE_TYPE)
           OR ((tlinfo.S_FEE_TYPE is null)
               AND (X_S_FEE_TYPE is null)))
      AND ((tlinfo.S_FEE_TRIGGER_CAT = X_S_FEE_TRIGGER_CAT)
           OR ((tlinfo.S_FEE_TRIGGER_CAT is null)
               AND (X_S_FEE_TRIGGER_CAT is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.OPTIONAL_PAYMENT_IND = X_OPTIONAL_PAYMENT_IND)
           OR ((tlinfo.OPTIONAL_PAYMENT_IND is null)
               AND (X_OPTIONAL_PAYMENT_IND is null)))
      AND ((tlinfo.CLOSED_IND = X_CLOSED_IND)
           OR ((tlinfo.CLOSED_IND is null)
               AND (X_CLOSED_IND is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
      --for Bug 2175865
      AND ( (tlinfo.FEE_CLASS = X_FEE_CLASS) OR
            ((tlinfo.FEE_CLASS IS NULL) AND (X_FEE_CLASS IS NULL)))
      AND ( (tlinfo.designated_payment_flag = x_designated_payment_flag) OR
            ((tlinfo.designated_payment_flag IS NULL) AND (x_designated_payment_flag IS NULL)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

-- shtatiko    30-MAY-2003   Enh# 2831582, Added new column designated_payment_flag.
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_S_FEE_TYPE in VARCHAR2,
  X_S_FEE_TRIGGER_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OPTIONAL_PAYMENT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_FEE_CLASS in VARCHAR2,   --FOR BUG 2175865
  x_designated_payment_flag IN VARCHAR2
  ) AS
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
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;



 Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_closed_ind=>X_CLOSED_IND,
  x_comments=>X_COMMENTS,
  x_description=>X_DESCRIPTION,
  x_fee_type=>X_FEE_TYPE,
  x_hist_end_dt=>X_HIST_END_DT,
  x_hist_start_dt=>X_HIST_START_DT,
  x_fee_class =>X_FEE_CLASS,           --for Bug 2175865
  x_hist_who=>X_HIST_WHO,
  x_optional_payment_ind=>X_OPTIONAL_PAYMENT_IND,
  x_s_fee_trigger_cat=>X_S_FEE_TRIGGER_CAT,
  x_s_fee_type=>X_S_FEE_TYPE,
  x_designated_payment_flag => x_designated_payment_flag,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
);


  update IGS_FI_FEE_TYPE_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    S_FEE_TYPE = NEW_REFERENCES.S_FEE_TYPE,
    S_FEE_TRIGGER_CAT = NEW_REFERENCES.S_FEE_TRIGGER_CAT,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    OPTIONAL_PAYMENT_IND = NEW_REFERENCES.OPTIONAL_PAYMENT_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    FEE_CLASS = NEW_REFERENCES.FEE_CLASS,          --for Bug 2175865
    designated_payment_flag = new_references.designated_payment_flag,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

-- shtatiko    30-MAY-2003   Enh# 2831582, Added new column designated_payment_flag.
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_S_FEE_TYPE in VARCHAR2,
  X_S_FEE_TRIGGER_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OPTIONAL_PAYMENT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 ,
  X_FEE_CLASS in VARCHAR2,   --for bug 2175865
  x_designated_payment_flag IN VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_FI_FEE_TYPE_HIST_ALL
     where FEE_TYPE = X_FEE_TYPE
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_TYPE,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_S_FEE_TYPE,
     X_S_FEE_TRIGGER_CAT,
     X_DESCRIPTION,
     X_OPTIONAL_PAYMENT_IND,
     X_CLOSED_IND,
     X_COMMENTS,
     X_ORG_ID,
     X_MODE,
     X_FEE_CLASS,      --for Bug 2175865
     x_designated_payment_flag);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_TYPE,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_S_FEE_TYPE,
   X_S_FEE_TRIGGER_CAT,
   X_DESCRIPTION,
   X_OPTIONAL_PAYMENT_IND,
   X_CLOSED_IND,
   X_COMMENTS,
   X_MODE,
   X_FEE_CLASS,      --for Bug 2175865
   x_designated_payment_flag);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
  Before_DML (
   p_action => 'DELETE',
   x_rowid => X_ROWID
     );
  delete from IGS_FI_FEE_TYPE_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_FI_FEE_TYPE_HIST_PKG;

/
