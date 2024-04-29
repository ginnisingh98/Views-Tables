--------------------------------------------------------
--  DDL for Package Body PSA_MFAR_RECEIPTS_COVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MFAR_RECEIPTS_COVER_PKG" as
/* $Header: PSAMFRHB.pls 120.7 2006/09/13 13:42:25 agovil ship $ */
--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFRHB.psa_mfar_receipts_cover_pkg.';
--===========================FND_LOG.END=======================================

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RECEIVABLE_APPLICATION_ID in NUMBER,
  X_CUST_TRX_LINE_GL_DIST_ID in NUMBER,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_MF_CASH_CCID in NUMBER,
  X_AMOUNT in NUMBER,
  X_PERCENT in NUMBER,
  X_DISCOUNT_CCID in NUMBER,
  X_UE_DISCOUNT_CCID in NUMBER,
  X_DISCOUNT_AMOUNT in NUMBER,
  X_UE_DISCOUNT_AMOUNT in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REFERENCE4 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE5 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE2 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE1 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE3 IN VARCHAR2 DEFAULT NULL,
  X_REVERSAL_CCID IN NUMBER DEFAULT NULL,
  X_MODE in VARCHAR2
  ) is
    cursor C is select ROWID from PSA_MF_RCT_DIST_ALL
      where RECEIVABLE_APPLICATION_ID = X_RECEIVABLE_APPLICATION_ID
      and CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    -- ========================= FND LOG ===========================
    l_full_path VARCHAR2(100) := g_path || 'INSERT_ROW';
    -- ========================= FND LOG ===========================
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
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
    -- ========================= FND LOG ===========================
    app_exception.raise_exception;
  end if;
  insert into PSA_MF_RCT_DIST_ALL (
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE_CATEGORY,
    RECEIVABLE_APPLICATION_ID,
    CUST_TRX_LINE_GL_DIST_ID,
    MF_CASH_CCID,
    AMOUNT,
    PERCENT,
    DISCOUNT_CCID,
    UE_DISCOUNT_CCID,
    DISCOUNT_AMOUNT,
    UE_DISCOUNT_AMOUNT,
    COMMENTS,
    POSTING_CONTROL_ID,
    ATTRIBUTE1,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    REFERENCE4,
    REFERENCE5,
    REFERENCE2,
    REFERENCE1,
    REFERENCE3,
    REVERSAL_CCID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE_CATEGORY,
    X_RECEIVABLE_APPLICATION_ID,
    X_CUST_TRX_LINE_GL_DIST_ID,
    X_MF_CASH_CCID,
    X_AMOUNT,
    X_PERCENT,
    X_DISCOUNT_CCID,
    X_UE_DISCOUNT_CCID,
    X_DISCOUNT_AMOUNT,
    X_UE_DISCOUNT_AMOUNT,
    X_COMMENTS,
    X_POSTING_CONTROL_ID,
    X_ATTRIBUTE1,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_REFERENCE4,
    X_REFERENCE5,
    X_REFERENCE2,
    X_REFERENCE1,
    X_REFERENCE3,
    X_REVERSAL_CCID,
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
  X_RECEIVABLE_APPLICATION_ID in NUMBER,
  X_CUST_TRX_LINE_GL_DIST_ID in NUMBER,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_MF_CASH_CCID in NUMBER,
  X_AMOUNT in NUMBER,
  X_PERCENT in NUMBER,
  X_DISCOUNT_CCID in NUMBER,
  X_UE_DISCOUNT_CCID in NUMBER,
  X_DISCOUNT_AMOUNT in NUMBER,
  X_UE_DISCOUNT_AMOUNT in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REFERENCE4 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE5 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE2 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE1 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE3 IN VARCHAR2 DEFAULT NULL,
  X_REVERSAL_CCID IN NUMBER DEFAULT NULL

) is
  cursor c1 is select
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE_CATEGORY,
      MF_CASH_CCID,
      AMOUNT,
      PERCENT,
      DISCOUNT_CCID,
      UE_DISCOUNT_CCID,
      DISCOUNT_AMOUNT,
      UE_DISCOUNT_AMOUNT,
      COMMENTS,
      POSTING_CONTROL_ID,
      ATTRIBUTE1,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
    REFERENCE4,
    REFERENCE5,
    REFERENCE2,
    REFERENCE1,
    REFERENCE3,
    REVERSAL_CCID
    from PSA_MF_RCT_DIST_ALL
    where RECEIVABLE_APPLICATION_ID = X_RECEIVABLE_APPLICATION_ID
    and CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID
    and reference1 = x_reference1
    for update of RECEIVABLE_APPLICATION_ID nowait;
  tlinfo c1%rowtype;
  -- ========================= FND LOG ===========================
  l_full_path VARCHAR2(100) := g_path || 'LOCK_ROW';
  -- ========================= FND LOG ===========================
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
    -- ========================= FND LOG ===========================
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

      if ( ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
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
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.MF_CASH_CCID = X_MF_CASH_CCID)
           OR ((tlinfo.MF_CASH_CCID is null)
               AND (X_MF_CASH_CCID is null)))
      AND ((tlinfo.AMOUNT = X_AMOUNT)
           OR ((tlinfo.AMOUNT is null)
               AND (X_AMOUNT is null)))
      AND ((tlinfo.PERCENT = X_PERCENT)
           OR ((tlinfo.PERCENT is null)
               AND (X_PERCENT is null)))
      AND ((tlinfo.DISCOUNT_CCID = X_DISCOUNT_CCID)
           OR ((tlinfo.DISCOUNT_CCID is null)
               AND (X_DISCOUNT_CCID is null)))
      AND ((tlinfo.UE_DISCOUNT_CCID = X_UE_DISCOUNT_CCID)
           OR ((tlinfo.UE_DISCOUNT_CCID is null)
               AND (X_UE_DISCOUNT_CCID is null)))
      AND ((tlinfo.DISCOUNT_AMOUNT = X_DISCOUNT_AMOUNT)
           OR ((tlinfo.DISCOUNT_AMOUNT is null)
               AND (X_DISCOUNT_AMOUNT is null)))
      AND ((tlinfo.UE_DISCOUNT_AMOUNT = X_UE_DISCOUNT_AMOUNT)
           OR ((tlinfo.UE_DISCOUNT_AMOUNT is null)
               AND (X_UE_DISCOUNT_AMOUNT is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
      AND ((tlinfo.POSTING_CONTROL_ID = X_POSTING_CONTROL_ID)
           OR ((tlinfo.POSTING_CONTROL_ID is null)
               AND (X_POSTING_CONTROL_ID is null)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
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
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
    -- ========================= FND LOG ===========================
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_RECEIVABLE_APPLICATION_ID in NUMBER,
  X_CUST_TRX_LINE_GL_DIST_ID in NUMBER,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_MF_CASH_CCID in NUMBER,
  X_AMOUNT in NUMBER,
  X_PERCENT in NUMBER,
  X_DISCOUNT_CCID in NUMBER,
  X_UE_DISCOUNT_CCID in NUMBER,
  X_DISCOUNT_AMOUNT in NUMBER,
  X_UE_DISCOUNT_AMOUNT in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REFERENCE4 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE5 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE2 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE1 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE3 IN VARCHAR2 DEFAULT NULL,
  X_REVERSAL_CCID IN NUMBER DEFAULT NULL,
  X_MODE in VARCHAR2
  ) is
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    -- ========================= FND LOG ===========================
    l_full_path VARCHAR2(100) := g_path || 'UPDATE_ROW';
    -- ========================= FND LOG ===========================
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
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
    -- ========================= FND LOG ===========================
    app_exception.raise_exception;
  end if;
  update PSA_MF_RCT_DIST_ALL set
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    MF_CASH_CCID = X_MF_CASH_CCID,
    AMOUNT = X_AMOUNT,
    PERCENT = X_PERCENT,
    DISCOUNT_CCID = X_DISCOUNT_CCID,
    UE_DISCOUNT_CCID = X_UE_DISCOUNT_CCID,
    DISCOUNT_AMOUNT = X_DISCOUNT_AMOUNT,
    UE_DISCOUNT_AMOUNT = X_UE_DISCOUNT_AMOUNT,
    COMMENTS = X_COMMENTS,
    POSTING_CONTROL_ID = X_POSTING_CONTROL_ID,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    REFERENCE4  = X_REFERENCE4,
    REFERENCE5  = X_REFERENCE5,
    REFERENCE2  = X_REFERENCE2,
    REFERENCE1  = X_REFERENCE1,
    REFERENCE3  = X_REFERENCE3,
    REVERSAL_CCID = X_REVERSAL_CCID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RECEIVABLE_APPLICATION_ID = X_RECEIVABLE_APPLICATION_ID
  and CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID
  and reference1 = x_reference1
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RECEIVABLE_APPLICATION_ID in NUMBER,
  X_CUST_TRX_LINE_GL_DIST_ID in NUMBER,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_MF_CASH_CCID in NUMBER,
  X_AMOUNT in NUMBER,
  X_PERCENT in NUMBER,
  X_DISCOUNT_CCID in NUMBER,
  X_UE_DISCOUNT_CCID in NUMBER,
  X_DISCOUNT_AMOUNT in NUMBER,
  X_UE_DISCOUNT_AMOUNT in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REFERENCE4 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE5 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE2 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE1 IN VARCHAR2 DEFAULT NULL,
  X_REFERENCE3 IN VARCHAR2 DEFAULT NULL,
  X_REVERSAL_CCID IN NUMBER DEFAULT NULL,
  X_MODE in VARCHAR2
  ) is
  cursor c1 is select rowid from PSA_MF_RCT_DIST_ALL
     where RECEIVABLE_APPLICATION_ID = X_RECEIVABLE_APPLICATION_ID
     and CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_RECEIVABLE_APPLICATION_ID,
     X_CUST_TRX_LINE_GL_DIST_ID,
     X_ATTRIBUTE2,
     X_ATTRIBUTE3,
     X_ATTRIBUTE4,
     X_ATTRIBUTE5,
     X_ATTRIBUTE6,
     X_ATTRIBUTE7,
     X_ATTRIBUTE8,
     X_ATTRIBUTE9,
     X_ATTRIBUTE_CATEGORY,
     X_MF_CASH_CCID,
     X_AMOUNT,
     X_PERCENT,
     X_DISCOUNT_CCID,
     X_UE_DISCOUNT_CCID,
     X_DISCOUNT_AMOUNT,
     X_UE_DISCOUNT_AMOUNT,
     X_COMMENTS,
     X_POSTING_CONTROL_ID,
     X_ATTRIBUTE1,
     X_ATTRIBUTE10,
     X_ATTRIBUTE11,
     X_ATTRIBUTE12,
     X_ATTRIBUTE13,
     X_ATTRIBUTE14,
     X_ATTRIBUTE15,
     X_REFERENCE4,
     X_REFERENCE5,
     X_REFERENCE2,
     X_REFERENCE1,
     X_REFERENCE3,
     X_REVERSAL_CCID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_RECEIVABLE_APPLICATION_ID,
   X_CUST_TRX_LINE_GL_DIST_ID,
   X_ATTRIBUTE2,
   X_ATTRIBUTE3,
   X_ATTRIBUTE4,
   X_ATTRIBUTE5,
   X_ATTRIBUTE6,
   X_ATTRIBUTE7,
   X_ATTRIBUTE8,
   X_ATTRIBUTE9,
   X_ATTRIBUTE_CATEGORY,
   X_MF_CASH_CCID,
   X_AMOUNT,
   X_PERCENT,
   X_DISCOUNT_CCID,
   X_UE_DISCOUNT_CCID,
   X_DISCOUNT_AMOUNT,
   X_UE_DISCOUNT_AMOUNT,
   X_COMMENTS,
   X_POSTING_CONTROL_ID,
   X_ATTRIBUTE1,
   X_ATTRIBUTE10,
   X_ATTRIBUTE11,
   X_ATTRIBUTE12,
   X_ATTRIBUTE13,
   X_ATTRIBUTE14,
   X_ATTRIBUTE15,
   X_REFERENCE4,
   X_REFERENCE5,
   X_REFERENCE2,
   X_REFERENCE1,
   X_REFERENCE3,
   X_REVERSAL_CCID,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_RECEIVABLE_APPLICATION_ID in NUMBER,
  X_CUST_TRX_LINE_GL_DIST_ID in NUMBER
) is
begin
  delete from PSA_MF_RCT_DIST_ALL
  where RECEIVABLE_APPLICATION_ID = X_RECEIVABLE_APPLICATION_ID
  and CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PSA_MFAR_RECEIPTS_COVER_PKG;

/