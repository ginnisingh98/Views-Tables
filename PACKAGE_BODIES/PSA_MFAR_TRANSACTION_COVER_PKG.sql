--------------------------------------------------------
--  DDL for Package Body PSA_MFAR_TRANSACTION_COVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MFAR_TRANSACTION_COVER_PKG" AS
/* $Header: PSAMFTHB.pls 120.5 2006/09/13 13:54:50 agovil ship $ */

--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFTHB.PSA_MFAR_TRANSACTION_COVER_PKG.';
--===========================FND_LOG.END=======================================

PROCEDURE INSERT_ROW (	X_ROWID 			IN OUT NOCOPY VARCHAR2,
			X_CUST_TRX_LINE_GL_DIST_ID 	IN NUMBER,
			X_RECEIVABLES_CCID 		IN NUMBER,
			X_PREV_MF_RECEIVABLES_CCID	IN NUMBER,
			X_ATTRIBUTE_CATEGORY            IN VARCHAR2,
			X_ATTRIBUTE1			IN VARCHAR2,
			X_ATTRIBUTE2			IN VARCHAR2,
			X_ATTRIBUTE3			IN VARCHAR2,
			X_ATTRIBUTE4			IN VARCHAR2,
			X_ATTRIBUTE5			IN VARCHAR2,
			X_ATTRIBUTE6			IN VARCHAR2,
			X_ATTRIBUTE7			IN VARCHAR2,
			X_ATTRIBUTE8			IN VARCHAR2,
			X_ATTRIBUTE9			IN VARCHAR2,
			X_ATTRIBUTE10			IN VARCHAR2,
			X_ATTRIBUTE11			IN VARCHAR2,
			X_ATTRIBUTE12			IN VARCHAR2,
			X_ATTRIBUTE13			IN VARCHAR2,
			X_ATTRIBUTE14			IN VARCHAR2,
			X_ATTRIBUTE15			IN VARCHAR2,
			X_MODE 				IN VARCHAR2
         ) IS

    cursor C is select ROWID from PSA_MF_TRX_DIST_ALL
      where CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID;

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

  insert into PSA_MF_TRX_DIST_ALL( CUST_TRX_LINE_GL_DIST_ID,
				   MF_RECEIVABLES_CCID,
				   CREATION_DATE,
				   CREATED_BY,
				   LAST_UPDATE_DATE,
				   LAST_UPDATED_BY,
				   LAST_UPDATE_LOGIN,
				   PREV_MF_RECEIVABLES_CCID,
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
				 ) values
				 ( X_CUST_TRX_LINE_GL_DIST_ID,
				   X_RECEIVABLES_CCID,
				   X_LAST_UPDATE_DATE,
				   X_LAST_UPDATED_BY,
				   X_LAST_UPDATE_DATE,
    				   X_LAST_UPDATED_BY,
				   X_LAST_UPDATE_LOGIN,
				   X_PREV_MF_RECEIVABLES_CCID,
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
				   X_ATTRIBUTE15
				 );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END INSERT_ROW;

PROCEDURE  LOCK_ROW ( 	X_CUST_TRX_LINE_GL_DIST_ID 	IN NUMBER,
			X_RECEIVABLES_CCID 		IN NUMBER) IS

  cursor c1 is select
      MF_RECEIVABLES_CCID
    from PSA_MF_TRX_DIST_ALL
    where CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID
    for update of CUST_TRX_LINE_GL_DIST_ID nowait;

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

  if ( (tlinfo.MF_RECEIVABLES_CCID = X_RECEIVABLES_CCID)
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

PROCEDURE UPDATE_ROW (  X_CUST_TRX_LINE_GL_DIST_ID 	in NUMBER,
			X_RECEIVABLES_CCID 		in NUMBER,
			X_PREV_MF_RECEIVABLES_CCID	IN NUMBER,
			X_ATTRIBUTE_CATEGORY            IN VARCHAR2,
			X_ATTRIBUTE1			IN VARCHAR2,
			X_ATTRIBUTE2			IN VARCHAR2,
			X_ATTRIBUTE3			IN VARCHAR2,
			X_ATTRIBUTE4			IN VARCHAR2,
			X_ATTRIBUTE5			IN VARCHAR2,
			X_ATTRIBUTE6			IN VARCHAR2,
			X_ATTRIBUTE7			IN VARCHAR2,
			X_ATTRIBUTE8			IN VARCHAR2,
			X_ATTRIBUTE9			IN VARCHAR2,
			X_ATTRIBUTE10			IN VARCHAR2,
			X_ATTRIBUTE11			IN VARCHAR2,
			X_ATTRIBUTE12			IN VARCHAR2,
			X_ATTRIBUTE13			IN VARCHAR2,
			X_ATTRIBUTE14			IN VARCHAR2,
			X_ATTRIBUTE15			IN VARCHAR2,
			X_MODE 				in VARCHAR2) is

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

  update PSA_MF_TRX_DIST_ALL set
    MF_RECEIVABLES_CCID 	 = X_RECEIVABLES_CCID,
    LAST_UPDATE_DATE 		 = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY 		 = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 		 = X_LAST_UPDATE_LOGIN,
    PREV_MF_RECEIVABLES_CCID     = X_PREV_MF_RECEIVABLES_CCID,
    ATTRIBUTE_CATEGORY 		= X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 			= X_ATTRIBUTE1,
    ATTRIBUTE2 			= X_ATTRIBUTE2,
    ATTRIBUTE3 			= X_ATTRIBUTE3,
    ATTRIBUTE4 			= X_ATTRIBUTE4,
    ATTRIBUTE5 			= X_ATTRIBUTE5,
    ATTRIBUTE6 			= X_ATTRIBUTE6,
    ATTRIBUTE7 			= X_ATTRIBUTE7,
    ATTRIBUTE8 			= X_ATTRIBUTE8,
    ATTRIBUTE9 			= X_ATTRIBUTE9,
    ATTRIBUTE10 		= X_ATTRIBUTE10,
    ATTRIBUTE11 		= X_ATTRIBUTE11,
    ATTRIBUTE12 		= X_ATTRIBUTE12,
    ATTRIBUTE13 		= X_ATTRIBUTE13,
    ATTRIBUTE14 		= X_ATTRIBUTE14,
    ATTRIBUTE15			= X_ATTRIBUTE15
  where CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

PROCEDURE  DELETE_ROW (X_CUST_TRX_LINE_GL_DIST_ID IN NUMBER ) is
begin
  delete from PSA_MF_TRX_DIST_ALL
  where CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
END DELETE_ROW;

end PSA_MFAR_TRANSACTION_COVER_PKG;

/
