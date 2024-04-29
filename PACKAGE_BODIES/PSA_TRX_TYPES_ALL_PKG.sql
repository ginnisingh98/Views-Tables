--------------------------------------------------------
--  DDL for Package Body PSA_TRX_TYPES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_TRX_TYPES_ALL_PKG" AS
/* $Header: PSAMFTTB.pls 120.5 2006/09/13 13:57:31 agovil ship $ */

--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFTTB.PSA_TRX_TYPES_ALL_PKG.';
--===========================FND_LOG.END=======================================

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PSA_TRX_TYPE_ID in NUMBER,
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
  X_MODE in VARCHAR2
  ) is
    cursor C is select ROWID from PSA_TRX_TYPES_ALL
      where PSA_TRX_TYPE_ID = X_PSA_TRX_TYPE_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;

  CURSOR c_check_dup(l_trx_type_id NUMBER) IS
  SELECT 'Exist'
  FROM psa_trx_types_all
  WHERE psa_trx_type_id = l_trx_type_id;
  l_exist VARCHAR2(60);
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

  OPEN c_check_dup(X_PSA_TRX_TYPE_ID);
  FETCH c_check_dup INTO l_exist;

  IF (c_check_dup%FOUND) THEN
    IF (c_check_dup%ISOPEN) THEN
      CLOSE c_check_dup;
    END IF;

    Fnd_Message.Set_Name('PSA', 'PSA_TRX_TYPE_DUP');
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
    -- ========================= FND LOG ===========================
    app_exception.raise_exception;
  END IF;

  IF (c_check_dup%ISOPEN) THEN
    CLOSE c_check_dup;
  END IF;

  insert into PSA_TRX_TYPES_ALL (
    PSA_TRX_TYPE_ID,
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
    X_PSA_TRX_TYPE_ID,
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
  X_PSA_TRX_TYPE_ID in NUMBER,
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
    from PSA_TRX_TYPES_ALL
    where PSA_TRX_TYPE_ID = X_PSA_TRX_TYPE_ID
    for update of PSA_TRX_TYPE_ID nowait;
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

      if ( ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
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
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
    -- ========================= FND LOG ===========================
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_PSA_TRX_TYPE_ID in NUMBER,
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
  update PSA_TRX_TYPES_ALL set
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
  where PSA_TRX_TYPE_ID = X_PSA_TRX_TYPE_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PSA_TRX_TYPE_ID in NUMBER
) is
cursor c2 is
select distinct 1
from RA_CUSTOMER_TRX_ALL a
where a.cust_trx_type_id = X_PSA_TRX_TYPE_ID ;
num number;
x number;
-- ========================= FND LOG ===========================
l_full_path VARCHAR2(100) := g_path || 'DELETE_ROW';
-- ========================= FND LOG ===========================

begin
   open c2;
  fetch c2 into num;
   if (c2%notfound) then
  delete from PSA_TRX_TYPES_ALL
  where PSA_TRX_TYPE_ID = X_PSA_TRX_TYPE_ID;

  else

    FND_MESSAGE.SET_NAME('PSA','PSA_TRX_TYPE_DEL');
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
    -- ========================= FND LOG ===========================
    app_exception.raise_exception;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  end if;
  close c2;
 end DELETE_ROW;

end PSA_TRX_TYPES_ALL_PKG;

/
