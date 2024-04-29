--------------------------------------------------------
--  DDL for Package Body GMS_INSTALLMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_INSTALLMENTS_PKG" as
-- $Header: gmsawinb.pls 120.1 2005/07/26 14:20:45 appldev ship $
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INSTALLMENT_ID in NUMBER,
  X_INSTALLMENT_NUM in VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CLOSE_DATE in DATE,
  X_DIRECT_COST in NUMBER,
  X_INDIRECT_COST in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_BILLABLE_FLAG in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_ISSUE_DATE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from GMS_INSTALLMENTS
      where INSTALLMENT_ID = X_INSTALLMENT_ID;
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
    app_exception.raise_exception;
  end if;
  insert into GMS_INSTALLMENTS (
    INSTALLMENT_ID,
    INSTALLMENT_NUM,
    AWARD_ID,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CLOSE_DATE,
    DIRECT_COST,
    INDIRECT_COST,
    ACTIVE_FLAG,
    BILLABLE_FLAG,
    TYPE,
    ISSUE_DATE,
    DESCRIPTION,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_INSTALLMENT_ID,
    X_INSTALLMENT_NUM,
    X_AWARD_ID,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CLOSE_DATE,
    X_DIRECT_COST,
    X_INDIRECT_COST,
    X_ACTIVE_FLAG,
    X_BILLABLE_FLAG,
    X_TYPE,
    X_ISSUE_DATE,
    X_DESCRIPTION,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
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

procedure LOCK_ROW (
  X_INSTALLMENT_ID in NUMBER,
  X_INSTALLMENT_NUM in VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CLOSE_DATE in DATE,
  X_DIRECT_COST in NUMBER,
  X_INDIRECT_COST in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_BILLABLE_FLAG in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_ISSUE_DATE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor c1 is select
      INSTALLMENT_NUM,
      AWARD_ID,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      CLOSE_DATE,
      DIRECT_COST,
      INDIRECT_COST,
      ACTIVE_FLAG,
      BILLABLE_FLAG,
      TYPE,
      ISSUE_DATE,
      DESCRIPTION,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    from GMS_INSTALLMENTS
    where INSTALLMENT_ID = X_INSTALLMENT_ID
    for update of INSTALLMENT_ID nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

      if ( ((tlinfo.INSTALLMENT_NUM = X_INSTALLMENT_NUM)
           OR ((tlinfo.INSTALLMENT_NUM is null)
               AND (X_INSTALLMENT_NUM is null)))
      AND ((tlinfo.AWARD_ID = X_AWARD_ID)
           OR ((tlinfo.AWARD_ID is null)
               AND (X_AWARD_ID is null)))
      AND ((tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((tlinfo.START_DATE_ACTIVE is null)
               AND (X_START_DATE_ACTIVE is null)))
      AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((tlinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
      AND ((tlinfo.CLOSE_DATE = X_CLOSE_DATE)
           OR ((tlinfo.CLOSE_DATE is null)
               AND (X_CLOSE_DATE is null)))
      AND ((tlinfo.DIRECT_COST = X_DIRECT_COST)
           OR ((tlinfo.DIRECT_COST is null)
               AND (X_DIRECT_COST is null)))
      AND ((tlinfo.INDIRECT_COST = X_INDIRECT_COST)
           OR ((tlinfo.INDIRECT_COST is null)
               AND (X_INDIRECT_COST is null)))
      AND ((tlinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
           OR ((tlinfo.ACTIVE_FLAG is null)
               AND (X_ACTIVE_FLAG is null)))
      AND ((tlinfo.BILLABLE_FLAG = X_BILLABLE_FLAG)
           OR ((tlinfo.BILLABLE_FLAG is null)
               AND (X_BILLABLE_FLAG is null)))
      AND ((tlinfo.TYPE = X_TYPE)
           OR ((tlinfo.TYPE is null)
               AND (X_TYPE is null)))
      AND ((tlinfo.ISSUE_DATE = X_ISSUE_DATE)
           OR ((tlinfo.ISSUE_DATE is null)
               AND (X_ISSUE_DATE is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
      AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 is null)
               AND (X_ATTRIBUTE11 is null)))
      AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 is null)
               AND (X_ATTRIBUTE12 is null)))
      AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 is null)
               AND (X_ATTRIBUTE13 is null)))
      AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 is null)
               AND (X_ATTRIBUTE14 is null)))
      AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 is null)
               AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_INSTALLMENT_ID in NUMBER,
  X_INSTALLMENT_NUM in VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CLOSE_DATE in DATE,
  X_DIRECT_COST in NUMBER,
  X_INDIRECT_COST in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_BILLABLE_FLAG in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_ISSUE_DATE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
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
    app_exception.raise_exception;
  end if;
  update GMS_INSTALLMENTS set
    INSTALLMENT_NUM = X_INSTALLMENT_NUM,
    AWARD_ID = X_AWARD_ID,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    CLOSE_DATE = X_CLOSE_DATE,
    DIRECT_COST = X_DIRECT_COST,
    INDIRECT_COST = X_INDIRECT_COST,
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    BILLABLE_FLAG = X_BILLABLE_FLAG,
    TYPE = X_TYPE,
    ISSUE_DATE = X_ISSUE_DATE,
    DESCRIPTION = X_DESCRIPTION,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INSTALLMENT_ID = X_INSTALLMENT_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INSTALLMENT_ID in NUMBER,
  X_INSTALLMENT_NUM in VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CLOSE_DATE in DATE,
  X_DIRECT_COST in NUMBER,
  X_INDIRECT_COST in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_BILLABLE_FLAG in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_ISSUE_DATE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from GMS_INSTALLMENTS
     where INSTALLMENT_ID = X_INSTALLMENT_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_INSTALLMENT_ID,
     X_INSTALLMENT_NUM,
     X_AWARD_ID,
     X_START_DATE_ACTIVE,
     X_END_DATE_ACTIVE,
     X_CLOSE_DATE,
     X_DIRECT_COST,
     X_INDIRECT_COST,
     X_ACTIVE_FLAG,
     X_BILLABLE_FLAG,
     X_TYPE,
     X_ISSUE_DATE,
     X_DESCRIPTION,
     X_ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1,
     X_ATTRIBUTE2,
     X_ATTRIBUTE3,
     X_ATTRIBUTE4,
     X_ATTRIBUTE5,
     X_ATTRIBUTE6,
     X_ATTRIBUTE7,
     X_ATTRIBUTE8,
     X_ATTRIBUTE9,
     X_ATTRIBUTE10,
     X_ATTRIBUTE11,
     X_ATTRIBUTE12,
     X_ATTRIBUTE13,
     X_ATTRIBUTE14,
     X_ATTRIBUTE15,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_INSTALLMENT_ID,
   X_INSTALLMENT_NUM,
   X_AWARD_ID,
   X_START_DATE_ACTIVE,
   X_END_DATE_ACTIVE,
   X_CLOSE_DATE,
   X_DIRECT_COST,
   X_INDIRECT_COST,
   X_ACTIVE_FLAG,
   X_BILLABLE_FLAG,
   X_TYPE,
   X_ISSUE_DATE,
   X_DESCRIPTION,
   X_ATTRIBUTE_CATEGORY,
   X_ATTRIBUTE1,
   X_ATTRIBUTE2,
   X_ATTRIBUTE3,
   X_ATTRIBUTE4,
   X_ATTRIBUTE5,
   X_ATTRIBUTE6,
   X_ATTRIBUTE7,
   X_ATTRIBUTE8,
   X_ATTRIBUTE9,
   X_ATTRIBUTE10,
   X_ATTRIBUTE11,
   X_ATTRIBUTE12,
   X_ATTRIBUTE13,
   X_ATTRIBUTE14,
   X_ATTRIBUTE15,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_INSTALLMENT_ID in NUMBER
) is
begin
  delete from GMS_INSTALLMENTS
  where INSTALLMENT_ID = X_INSTALLMENT_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

-- Bug 2719057 : Added following Function, this function is used to
-- derive the order by clause for installment_num in Award Form
-- If the installment_num is numeric then the function will return
-- the installment_num by converting it to number, if the installment_num
-- is character then the function will return NULL
-- In the Award form the installments will have following order clause
-- Order by start_date_active,
-- and then :
-- a.If all the Installments are Numeric then it will be displayed in numeric
--   order
-- b.If all the Installments are in Character then it will be displayed in
--   character order
-- c.If the Installments are a combination of Numeric and Characters then it
--   will be displayed by numeric order first and then by character

-- The above logic is incorporated In Award Form by using
-- order by start_date_active,
-- gms_installments_pkg.installment_order(installment_num),installment_num

FUNCTION installment_order(p_installment_num VARCHAR2) RETURN NUMBER IS
     l_numeric_installment  NUMBER;
BEGIN
     l_numeric_installment := to_number(p_installment_num);
     RETURN l_numeric_installment ;
EXCEPTION
   WHEN VALUE_ERROR THEN
       RETURN NULL;
END installment_order;

end GMS_INSTALLMENTS_PKG;

/
