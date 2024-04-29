--------------------------------------------------------
--  DDL for Package Body PSA_MF_MISC_DIST_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MF_MISC_DIST_ALL_PKG" as
 /* $Header: PSAMFMTB.pls 120.6 2006/09/13 13:34:22 agovil ship $ */
--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFMTB.PSA_MF_MISC_DIST_ALL_PKG.';
--===========================FND_LOG.END=======================================

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MISC_MF_CASH_DIST_ID in NUMBER,
  X_MISC_CASH_DISTRIBUTION_ID in NUMBER,
  X_DISTRIBUTION_CCID in NUMBER,
  X_CASH_CCID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_GL_DATE in DATE,
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
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in DATE,
  X_REFERENCE3 in DATE,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  x_reversal_ccid IN NUMBER,
  X_MODE in VARCHAR2
  ) is
    cursor C is select ROWID from PSA_MF_MISC_DIST_ALL
      where MISC_MF_CASH_DIST_ID = X_MISC_MF_CASH_DIST_ID;
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
  insert into PSA_MF_MISC_DIST_ALL (
    MISC_MF_CASH_DIST_ID,
    MISC_CASH_DISTRIBUTION_ID,
    DISTRIBUTION_CCID,
    CASH_CCID,
    COMMENTS,
    POSTING_CONTROL_ID,
    GL_DATE,
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
    REFERENCE1,
    REFERENCE2,
    REFERENCE3,
    REFERENCE4,
    REFERENCE5,
    reversal_ccid,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MISC_MF_CASH_DIST_ID,
    X_MISC_CASH_DISTRIBUTION_ID,
    X_DISTRIBUTION_CCID,
    X_CASH_CCID,
    X_COMMENTS,
    X_POSTING_CONTROL_ID,
    X_GL_DATE,
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
    X_REFERENCE1,
    X_REFERENCE2,
    X_REFERENCE3,
    X_REFERENCE4,
    X_REFERENCE5,
    x_reversal_ccid,
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
  X_MISC_MF_CASH_DIST_ID in NUMBER,
  X_MISC_CASH_DISTRIBUTION_ID in NUMBER,
  X_DISTRIBUTION_CCID in NUMBER,
  X_CASH_CCID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_GL_DATE in DATE,
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
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in DATE,
  X_REFERENCE3 in DATE,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  x_reversal_ccid IN number
  ) is
  cursor c1 is select
      MISC_CASH_DISTRIBUTION_ID,
      DISTRIBUTION_CCID,
      CASH_CCID,
      COMMENTS,
      POSTING_CONTROL_ID,
      GL_DATE,
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
      REFERENCE1,
      REFERENCE2,
      REFERENCE3,
      REFERENCE4,
      reference5,
      reversal_ccid
    from PSA_MF_MISC_DIST_ALL
    where MISC_MF_CASH_DIST_ID = x_misc_mf_cash_dist_id
    AND reference1 = x_reference1
    for update of MISC_MF_CASH_DIST_ID nowait;
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

  if ( (tlinfo.MISC_CASH_DISTRIBUTION_ID = X_MISC_CASH_DISTRIBUTION_ID)
      AND (tlinfo.DISTRIBUTION_CCID = X_DISTRIBUTION_CCID)
      AND ((tlinfo.CASH_CCID = X_CASH_CCID)
           OR ((tlinfo.CASH_CCID is null)
               AND (X_CASH_CCID is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
      AND ((tlinfo.POSTING_CONTROL_ID = X_POSTING_CONTROL_ID)
           OR ((tlinfo.POSTING_CONTROL_ID is null)
               AND (X_POSTING_CONTROL_ID is null)))
      AND ((tlinfo.GL_DATE = X_GL_DATE)
           OR ((tlinfo.GL_DATE is null)
               AND (X_GL_DATE is null)))
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
      AND ((tlinfo.REFERENCE1 = X_REFERENCE1)
           OR ((tlinfo.REFERENCE1 is null)
               AND (X_REFERENCE1 is null)))
      AND ((tlinfo.REFERENCE2 = X_REFERENCE2)
           OR ((tlinfo.REFERENCE2 is null)
               AND (X_REFERENCE2 is null)))
      AND ((tlinfo.REFERENCE3 = X_REFERENCE3)
           OR ((tlinfo.REFERENCE3 is null)
               AND (X_REFERENCE3 is null)))
      AND ((tlinfo.REFERENCE4 = X_REFERENCE4)
           OR ((tlinfo.REFERENCE4 is null)
               AND (X_REFERENCE4 is null)))
      AND ((tlinfo.REFERENCE5 = X_REFERENCE5)
           OR ((tlinfo.REFERENCE5 is null)
               AND (X_REFERENCE5 is null)))
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
  X_MISC_MF_CASH_DIST_ID in NUMBER,
  X_MISC_CASH_DISTRIBUTION_ID in NUMBER,
  X_DISTRIBUTION_CCID in NUMBER,
  X_CASH_CCID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_GL_DATE in DATE,
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
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in DATE,
  X_REFERENCE3 in DATE,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  x_reversal_ccid IN NUMBER,
  X_MODE in VARCHAR2
  ) is
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    -- ========================= FND LOG ===========================
    l_full_path VARCHAR2(100) := g_path || 'UPDATE_ROW';
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
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
    -- ========================= FND LOG ===========================
    app_exception.raise_exception;
  end if;
  update PSA_MF_MISC_DIST_ALL set
    MISC_CASH_DISTRIBUTION_ID = X_MISC_CASH_DISTRIBUTION_ID,
    DISTRIBUTION_CCID = X_DISTRIBUTION_CCID,
    CASH_CCID = X_CASH_CCID,
    COMMENTS = X_COMMENTS,
    POSTING_CONTROL_ID = X_POSTING_CONTROL_ID,
    GL_DATE = X_GL_DATE,
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
    REFERENCE1 = X_REFERENCE1,
    REFERENCE2 = X_REFERENCE2,
    REFERENCE3 = X_REFERENCE3,
    REFERENCE4 = X_REFERENCE4,
    REFERENCE5 = X_REFERENCE5,
    reversal_ccid = x_reversal_ccid,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    where MISC_MF_CASH_DIST_ID = x_misc_mf_cash_dist_id
    AND Nvl(reference1,'CLEARED') = X_REFERENCE1
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MISC_MF_CASH_DIST_ID in NUMBER,
  X_MISC_CASH_DISTRIBUTION_ID in NUMBER,
  X_DISTRIBUTION_CCID in NUMBER,
  X_CASH_CCID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_GL_DATE in DATE,
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
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in DATE,
  X_REFERENCE3 in DATE,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  x_reversal_ccid IN NUMBER,
  X_MODE in VARCHAR2
  ) is
  cursor c1 is select rowid from PSA_MF_MISC_DIST_ALL
     where MISC_MF_CASH_DIST_ID = X_MISC_MF_CASH_DIST_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_MISC_MF_CASH_DIST_ID,
     X_MISC_CASH_DISTRIBUTION_ID,
     X_DISTRIBUTION_CCID,
     X_CASH_CCID,
     X_COMMENTS,
     X_POSTING_CONTROL_ID,
     X_GL_DATE,
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
     X_REFERENCE1,
     X_REFERENCE2,
     X_REFERENCE3,
     X_REFERENCE4,
     X_REFERENCE5,
     x_reversal_ccid,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_MISC_MF_CASH_DIST_ID,
   X_MISC_CASH_DISTRIBUTION_ID,
   X_DISTRIBUTION_CCID,
   X_CASH_CCID,
   X_COMMENTS,
   X_POSTING_CONTROL_ID,
   X_GL_DATE,
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
   X_REFERENCE1,
   X_REFERENCE2,
   X_REFERENCE3,
   X_REFERENCE4,
   X_REFERENCE5,
   X_REVERSAL_CCID,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
		      X_MISC_MF_CASH_DIST_ID in NUMBER,
		      x_reference1 IN varchar2

) is
begin
  delete from PSA_MF_MISC_DIST_ALL
    where MISC_MF_CASH_DIST_ID = x_misc_mf_cash_dist_id AND
    Nvl(reference5,'CLEARED') = x_reference1;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PSA_MF_MISC_DIST_ALL_PKG;

/
