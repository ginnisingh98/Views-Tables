--------------------------------------------------------
--  DDL for Package Body PSP_PAYROLL_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PAYROLL_INTERFACE_PKG" as
 /* $Header: PSPPIN2B.pls 115.9 2003/07/30 14:50:23 tbalacha ship $ */
 -- This file has been checked out NOCOPY and checked in to ensure that the CTRL M
 -- problem that causes file formatting to get garbled up does not exist
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PAYROLL_INTERFACE_ID in NUMBER,
  X_BATCH_NAME in VARCHAR2,
  X_PAYROLL_ID in NUMBER,
  X_PAYROLL_PERIOD_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_PAY_AMOUNT in NUMBER,
  X_EARNED_DATE in DATE,
  X_CHECK_DATE in DATE,
  X_EFFECTIVE_DATE in DATE,
  X_PAYROLL_SOURCE_CODE in VARCHAR2,
  X_FTE in NUMBER,
  X_REASON_CODE in VARCHAR2,
  X_SUB_LINE_START_DATE in DATE,
  X_SUB_LINE_END_DATE in DATE,
  X_DAILY_RATE in NUMBER,
  X_SALARY_USED in NUMBER,
  X_DR_CR_FLAG in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_ERROR_CODE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_GL_POSTING_OVERRIDE_DATE in DATE,
  X_GMS_POSTING_OVERRIDE_DATE in DATE,
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
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID   in NUMBER,
  X_CURRENCY_CODE     in VARCHAR2
  ) is
    cursor C is select ROWID from PSP_PAYROLL_INTERFACE
      where PAYROLL_INTERFACE_ID = X_PAYROLL_INTERFACE_ID
      and BATCH_NAME = X_BATCH_NAME;
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
  insert into PSP_PAYROLL_INTERFACE (
    PAYROLL_INTERFACE_ID,
    PAYROLL_ID,
    PAYROLL_PERIOD_ID,
    PERSON_ID,
    ASSIGNMENT_ID,
    ELEMENT_TYPE_ID,
    PAY_AMOUNT,
    EARNED_DATE,
    CHECK_DATE,
    EFFECTIVE_DATE,
    GL_POSTING_OVERRIDE_DATE,
    GMS_POSTING_OVERRIDE_DATE,
    PAYROLL_SOURCE_CODE,
    FTE,
    REASON_CODE,
    SUB_LINE_START_DATE,
    SUB_LINE_END_DATE,
    DAILY_RATE,
    SALARY_USED,
    DR_CR_FLAG,
    STATUS_CODE,
    BATCH_NAME,
    ERROR_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
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
    BUSINESS_GROUP_ID ,
    SET_OF_BOOKS_ID,
    CURRENCY_CODE
  ) values (
    X_PAYROLL_INTERFACE_ID,
    X_PAYROLL_ID,
    X_PAYROLL_PERIOD_ID,
    X_PERSON_ID,
    X_ASSIGNMENT_ID,
    X_ELEMENT_TYPE_ID,
    X_PAY_AMOUNT,
    X_EARNED_DATE,
    X_CHECK_DATE,
    X_EFFECTIVE_DATE,
    X_GL_POSTING_OVERRIDE_DATE,
    X_GMS_POSTING_OVERRIDE_DATE,
    X_PAYROLL_SOURCE_CODE,
    X_FTE,
    X_REASON_CODE,
    X_SUB_LINE_START_DATE,
    X_SUB_LINE_END_DATE,
    X_DAILY_RATE,
    X_SALARY_USED,
    X_DR_CR_FLAG,
    X_STATUS_CODE,
    X_BATCH_NAME,
    X_ERROR_CODE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
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
    X_BUSINESS_GROUP_ID ,
    X_SET_OF_BOOKS_ID,
    X_CURRENCY_CODE
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
  X_PAYROLL_INTERFACE_ID in NUMBER,
  X_BATCH_NAME in VARCHAR2,
  X_PAYROLL_ID in NUMBER,
  X_PAYROLL_PERIOD_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_PAY_AMOUNT in NUMBER,
  X_EARNED_DATE in DATE,
  X_CHECK_DATE in DATE,
  X_EFFECTIVE_DATE in DATE,
  X_PAYROLL_SOURCE_CODE in VARCHAR2,
  X_FTE in NUMBER,
  X_REASON_CODE in VARCHAR2,
  X_SUB_LINE_START_DATE in DATE,
  X_SUB_LINE_END_DATE in DATE,
  X_DAILY_RATE in NUMBER,
  X_SALARY_USED in NUMBER,
  X_DR_CR_FLAG in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_ERROR_CODE in VARCHAR2,
  X_GL_POSTING_OVERRIDE_DATE in DATE,
  X_GMS_POSTING_OVERRIDE_DATE in DATE,
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
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID   in NUMBER
) is
  cursor c1 is select
      PAYROLL_ID,
      PAYROLL_PERIOD_ID,
      PERSON_ID,
      ASSIGNMENT_ID,
      ELEMENT_TYPE_ID,
      PAY_AMOUNT,
      EARNED_DATE,
      CHECK_DATE,
      EFFECTIVE_DATE,
      GL_POSTING_OVERRIDE_DATE,
      GMS_POSTING_OVERRIDE_DATE,
      PAYROLL_SOURCE_CODE,
      FTE,
      REASON_CODE,
      SUB_LINE_START_DATE,
      SUB_LINE_END_DATE,
      DAILY_RATE,
      SALARY_USED,
      DR_CR_FLAG,
      STATUS_CODE,
      ERROR_CODE,
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
      BUSINESS_GROUP_ID ,
      SET_OF_BOOKS_ID

    from PSP_PAYROLL_INTERFACE
    where PAYROLL_INTERFACE_ID = X_PAYROLL_INTERFACE_ID
    and BATCH_NAME = X_BATCH_NAME
    and BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID
    and SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID
    for update of PAYROLL_INTERFACE_ID nowait;
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

  if ( (tlinfo.PAYROLL_ID = X_PAYROLL_ID)
      AND (tlinfo.PAYROLL_PERIOD_ID = X_PAYROLL_PERIOD_ID)
      AND (tlinfo.PERSON_ID = X_PERSON_ID)
      AND (tlinfo.ASSIGNMENT_ID = X_ASSIGNMENT_ID)
      AND (tlinfo.ELEMENT_TYPE_ID = X_ELEMENT_TYPE_ID)
      AND (tlinfo.PAY_AMOUNT = X_PAY_AMOUNT)
      AND ((tlinfo.EARNED_DATE = X_EARNED_DATE)
           OR ((tlinfo.EARNED_DATE is null)
               AND (X_EARNED_DATE is null)))
      AND ((tlinfo.CHECK_DATE = X_CHECK_DATE)
           OR ((tlinfo.CHECK_DATE is null)
               AND (X_CHECK_DATE is null)))
      AND (tlinfo.EFFECTIVE_DATE = X_EFFECTIVE_DATE)
      AND (tlinfo.PAYROLL_SOURCE_CODE = X_PAYROLL_SOURCE_CODE)
      AND ((tlinfo.FTE = X_FTE)
           OR ((tlinfo.FTE is null)
               AND (X_FTE is null)))
      AND ((tlinfo.REASON_CODE = X_REASON_CODE)
           OR ((tlinfo.REASON_CODE is null)
               AND (X_REASON_CODE is null)))
      AND (tlinfo.SUB_LINE_START_DATE = X_SUB_LINE_START_DATE)
      AND (tlinfo.SUB_LINE_END_DATE = X_SUB_LINE_END_DATE)
      AND (tlinfo.DAILY_RATE = X_DAILY_RATE)
      AND (tlinfo.SALARY_USED = X_SALARY_USED)
      AND (tlinfo.DR_CR_FLAG = X_DR_CR_FLAG)
      AND (tlinfo.STATUS_CODE = X_STATUS_CODE)
      AND ((tlinfo.ERROR_CODE = X_ERROR_CODE)
           OR ((tlinfo.ERROR_CODE is null)
               AND (X_ERROR_CODE is null)))
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
  X_PAYROLL_INTERFACE_ID in NUMBER,
  X_BATCH_NAME in VARCHAR2,
  X_PAYROLL_ID in NUMBER,
  X_PAYROLL_PERIOD_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_PAY_AMOUNT in NUMBER,
  X_EARNED_DATE in DATE,
  X_CHECK_DATE in DATE,
  X_EFFECTIVE_DATE in DATE,
  X_PAYROLL_SOURCE_CODE in VARCHAR2,
  X_FTE in NUMBER,
  X_REASON_CODE in VARCHAR2,
  X_SUB_LINE_START_DATE in DATE,
  X_SUB_LINE_END_DATE in DATE,
  X_DAILY_RATE in NUMBER,
  X_SALARY_USED in NUMBER,
  X_DR_CR_FLAG in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_ERROR_CODE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_GL_POSTING_OVERRIDE_DATE in DATE,
  X_GMS_POSTING_OVERRIDE_DATE in DATE,
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
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID   in NUMBER,
  X_CURRENCY_CODE     in VARCHAR2
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
  update PSP_PAYROLL_INTERFACE set
    PAYROLL_ID = X_PAYROLL_ID,
    PAYROLL_PERIOD_ID = X_PAYROLL_PERIOD_ID,
    PERSON_ID = X_PERSON_ID,
    ASSIGNMENT_ID = X_ASSIGNMENT_ID,
    ELEMENT_TYPE_ID = X_ELEMENT_TYPE_ID,
    PAY_AMOUNT = X_PAY_AMOUNT,
    EARNED_DATE = X_EARNED_DATE,
    CHECK_DATE = X_CHECK_DATE,
    EFFECTIVE_DATE = X_EFFECTIVE_DATE,
    GL_POSTING_OVERRIDE_DATE = X_GL_POSTING_OVERRIDE_DATE,
    GMS_POSTING_OVERRIDE_DATE = X_GMS_POSTING_OVERRIDE_DATE,
    PAYROLL_SOURCE_CODE = X_PAYROLL_SOURCE_CODE,
    FTE = X_FTE,
    REASON_CODE = X_REASON_CODE,
    SUB_LINE_START_DATE = X_SUB_LINE_START_DATE,
    SUB_LINE_END_DATE = X_SUB_LINE_END_DATE,
    DAILY_RATE = X_DAILY_RATE,
    SALARY_USED = X_SALARY_USED,
    DR_CR_FLAG = X_DR_CR_FLAG,
    STATUS_CODE = X_STATUS_CODE,
    ERROR_CODE = X_ERROR_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
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
    BUSINESS_GROUP_ID =  X_BUSINESS_GROUP_ID ,
    SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID   ,
    CURRENCY_CODE  = X_CURRENCY_CODE
  where PAYROLL_INTERFACE_ID = X_PAYROLL_INTERFACE_ID
  and BATCH_NAME = X_BATCH_NAME
  and BUSINESS_GROUP_ID =  X_BUSINESS_GROUP_ID
  and SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PAYROLL_INTERFACE_ID in NUMBER,
  X_BATCH_NAME in VARCHAR2,
  X_PAYROLL_ID in NUMBER,
  X_PAYROLL_PERIOD_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ASSIGNMENT_ID in NUMBER,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_PAY_AMOUNT in NUMBER,
  X_EARNED_DATE in DATE,
  X_CHECK_DATE in DATE,
  X_EFFECTIVE_DATE in DATE,
  X_PAYROLL_SOURCE_CODE in VARCHAR2,
  X_FTE in NUMBER,
  X_REASON_CODE in VARCHAR2,
  X_SUB_LINE_START_DATE in DATE,
  X_SUB_LINE_END_DATE in DATE,
  X_DAILY_RATE in NUMBER,
  X_SALARY_USED in NUMBER,
  X_DR_CR_FLAG in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_ERROR_CODE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_GL_POSTING_OVERRIDE_DATE in DATE,
  X_GMS_POSTING_OVERRIDE_DATE in DATE,
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
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID   in NUMBER,
  X_CURRENCY_CODE     in VARCHAR2
  ) is
  cursor c1 is select rowid from PSP_PAYROLL_INTERFACE
     where PAYROLL_INTERFACE_ID = X_PAYROLL_INTERFACE_ID
     and BATCH_NAME = X_BATCH_NAME
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PAYROLL_INTERFACE_ID,
     X_BATCH_NAME,
     X_PAYROLL_ID,
     X_PAYROLL_PERIOD_ID,
     X_PERSON_ID,
     X_ASSIGNMENT_ID,
     X_ELEMENT_TYPE_ID,
     X_PAY_AMOUNT,
     X_EARNED_DATE,
     X_CHECK_DATE,
     X_EFFECTIVE_DATE,
     X_PAYROLL_SOURCE_CODE,
     X_FTE,
     X_REASON_CODE,
     X_SUB_LINE_START_DATE,
     X_SUB_LINE_END_DATE,
     X_DAILY_RATE,
     X_SALARY_USED,
     X_DR_CR_FLAG,
     X_STATUS_CODE,
     X_ERROR_CODE,
     X_MODE,
     X_GL_POSTING_OVERRIDE_DATE,
     X_GMS_POSTING_OVERRIDE_DATE,
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
     X_BUSINESS_GROUP_ID ,
     X_SET_OF_BOOKS_ID  ,
     X_CURRENCY_CODE
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_PAYROLL_INTERFACE_ID,
   X_BATCH_NAME,
   X_PAYROLL_ID,
   X_PAYROLL_PERIOD_ID,
   X_PERSON_ID,
   X_ASSIGNMENT_ID,
   X_ELEMENT_TYPE_ID,
   X_PAY_AMOUNT,
   X_EARNED_DATE,
   X_CHECK_DATE,
   X_EFFECTIVE_DATE,
   X_PAYROLL_SOURCE_CODE,
   X_FTE,
   X_REASON_CODE,
   X_SUB_LINE_START_DATE,
   X_SUB_LINE_END_DATE,
   X_DAILY_RATE,
   X_SALARY_USED,
   X_DR_CR_FLAG,
   X_STATUS_CODE,
   X_ERROR_CODE,
   X_MODE,
   X_GL_POSTING_OVERRIDE_DATE,
   X_GMS_POSTING_OVERRIDE_DATE,
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
   X_BUSINESS_GROUP_ID ,
   X_SET_OF_BOOKS_ID   ,
   X_CURRENCY_CODE
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_PAYROLL_INTERFACE_ID in NUMBER,
  X_BATCH_NAME in VARCHAR2,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID   in NUMBER
) is
begin
  delete from PSP_PAYROLL_INTERFACE
  where PAYROLL_INTERFACE_ID = X_PAYROLL_INTERFACE_ID
  and BATCH_NAME = X_BATCH_NAME;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PSP_PAYROLL_INTERFACE_PKG;

/