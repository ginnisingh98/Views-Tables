--------------------------------------------------------
--  DDL for Package Body PSA_IMPLEMENTATION_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_IMPLEMENTATION_ALL_PKG" as
 /* $Header: PSAIMPLB.pls 120.5 2006/09/13 12:05:59 agovil ship $ */

--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAIMPLB.PSA_IMPLEMENTATION_ALL_PKG.';
--===========================FND_LOG.END=======================================

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PSA_FEATURE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_ALLOCATION_METHOD in VARCHAR2,
  X_MAPPING_REQUIRED in VARCHAR2,
  X_PROGRAM_INSTALLED in VARCHAR2,
  X_MODE in VARCHAR2
  ) is
    cursor C is select ROWID from PSA_IMPLEMENTATION_ALL
      where PSA_FEATURE = X_PSA_FEATURE
      and ORG_ID = X_ORG_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    l_rowid NUMBER;
    -- ======================== FND LOG ======================
    l_full_path VARCHAR2(100) := g_path || 'INSERT_ROW';
    -- ======================== FND LOG ======================
begin

  l_rowid := X_ROWID;

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
  insert into PSA_IMPLEMENTATION_ALL (
    PSA_FEATURE,
    STATUS,
    ORG_ID,
    ALLOCATION_METHOD,
    MAPPING_REQUIRED,
    PROGRAM_INSTALLED,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PSA_FEATURE,
    X_STATUS,
    X_ORG_ID,
    X_ALLOCATION_METHOD,
    X_MAPPING_REQUIRED,
    X_PROGRAM_INSTALLED,
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

exception
  when others then
    X_ROWID := l_rowid;
    raise;

end INSERT_ROW;

procedure LOCK_ROW (
  X_PSA_FEATURE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_ALLOCATION_METHOD in VARCHAR2,
  X_MAPPING_REQUIRED in VARCHAR2,
  X_PROGRAM_INSTALLED in VARCHAR2
) is
  cursor c1 is select
      STATUS,
      ALLOCATION_METHOD,
      MAPPING_REQUIRED,
      PROGRAM_INSTALLED
    from PSA_IMPLEMENTATION_ALL
    where PSA_FEATURE = X_PSA_FEATURE
    and ORG_ID = X_ORG_ID
    for update of PSA_FEATURE nowait;
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

      if ( ((tlinfo.STATUS = X_STATUS)
           OR ((tlinfo.STATUS is null)
               AND (X_STATUS is null)))
      AND ((tlinfo.ALLOCATION_METHOD = X_ALLOCATION_METHOD)
           OR ((tlinfo.ALLOCATION_METHOD is null)
               AND (X_ALLOCATION_METHOD is null)))
      AND ((tlinfo.MAPPING_REQUIRED = X_MAPPING_REQUIRED)
           OR ((tlinfo.MAPPING_REQUIRED is null)
               AND (X_MAPPING_REQUIRED is null)))
      AND ((tlinfo.PROGRAM_INSTALLED = X_PROGRAM_INSTALLED)
           OR ((tlinfo.PROGRAM_INSTALLED is null)
               AND (X_PROGRAM_INSTALLED is null)))
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
  X_PSA_FEATURE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_ALLOCATION_METHOD in VARCHAR2,
  X_MAPPING_REQUIRED in VARCHAR2,
  X_PROGRAM_INSTALLED in VARCHAR2,
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
  update PSA_IMPLEMENTATION_ALL set
    STATUS = X_STATUS,
    ALLOCATION_METHOD = X_ALLOCATION_METHOD,
    MAPPING_REQUIRED = X_MAPPING_REQUIRED,
    PROGRAM_INSTALLED = X_PROGRAM_INSTALLED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PSA_FEATURE = X_PSA_FEATURE
  and ORG_ID = X_ORG_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PSA_FEATURE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_ALLOCATION_METHOD in VARCHAR2,
  X_MAPPING_REQUIRED in VARCHAR2,
  X_PROGRAM_INSTALLED in VARCHAR2,
  X_MODE in VARCHAR2
  ) is
  cursor c1 is select rowid from PSA_IMPLEMENTATION_ALL
     where PSA_FEATURE = X_PSA_FEATURE
     and ORG_ID = X_ORG_ID
  ;
  dummy c1%rowtype;
  l_rowid NUMBER;
begin
  l_rowid := X_ROWID;
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PSA_FEATURE,
     X_ORG_ID,
     X_STATUS,
     X_ALLOCATION_METHOD,
     X_MAPPING_REQUIRED,
     X_PROGRAM_INSTALLED,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_PSA_FEATURE,
   X_ORG_ID,
   X_STATUS,
   X_ALLOCATION_METHOD,
   X_MAPPING_REQUIRED,
   X_PROGRAM_INSTALLED,
   X_MODE);

exception
  when others then
    X_ROWID := l_rowid;
    raise;
end ADD_ROW;

procedure DELETE_ROW (
  X_PSA_FEATURE in VARCHAR2,
  X_ORG_ID in NUMBER
) is
begin
  delete from PSA_IMPLEMENTATION_ALL
  where PSA_FEATURE = X_PSA_FEATURE
  and ORG_ID = X_ORG_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PSA_IMPLEMENTATION_ALL_PKG;

/
