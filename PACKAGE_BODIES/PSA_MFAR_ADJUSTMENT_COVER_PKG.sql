--------------------------------------------------------
--  DDL for Package Body PSA_MFAR_ADJUSTMENT_COVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MFAR_ADJUSTMENT_COVER_PKG" AS
/* $Header: PSAMFAHB.pls 115.2 2000/10/09 18:44:27 pkm ship      $ */

PROCEDURE INSERT_ROW (	X_ROWID 			IN OUT VARCHAR2,
			X_ADJUSTMENT_ID 		IN NUMBER,
			X_CUST_TRX_LINE_GL_DIST_ID 	IN NUMBER,
			X_MF_ADJUSTMENT_CCID 		IN NUMBER,
			X_AMOUNT 			IN NUMBER,
			X_PERCENT 			IN NUMBER,
			X_PREV_CUST_TRX_LINE_ID 	IN NUMBER,
			X_COMMENTS			IN VARCHAR2,
			X_MODE 				IN VARCHAR2 DEFAULT 'R'	) IS

    Cursor C Is Select 	ROWID
    		  From 	PSA_MF_ADJ_DIST_ALL
		  Where ADJUSTMENT_ID = X_ADJUSTMENT_ID
      		  And 	CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID;

    X_LAST_UPDATE_DATE 	DATE;
    X_LAST_UPDATED_BY 	NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;

BEGIN

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

  Insert into PSA_MF_ADJ_DIST_ALL( ADJUSTMENT_ID,
				   CUST_TRX_LINE_GL_DIST_ID,
				   MF_ADJUSTMENT_CCID,
				   AMOUNT,
				   PERCENT,
				   PREV_CUST_TRX_LINE_ID,
				   COMMENTS,
				   CREATION_DATE,
				   CREATED_BY,
				   LAST_UPDATE_DATE,
				   LAST_UPDATED_BY,
				   LAST_UPDATE_LOGIN ) Values
				 ( X_ADJUSTMENT_ID,
				   X_CUST_TRX_LINE_GL_DIST_ID,
				   X_MF_ADJUSTMENT_CCID,
				   X_AMOUNT,
				   X_PERCENT,
				   X_PREV_CUST_TRX_LINE_ID,
				   X_COMMENTS,
				   X_LAST_UPDATE_DATE,
				   X_LAST_UPDATED_BY,
				   X_LAST_UPDATE_DATE,
				   X_LAST_UPDATED_BY,
				   X_LAST_UPDATE_LOGIN );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END INSERT_ROW;

PROCEDURE LOCK_ROW( X_ADJUSTMENT_ID 		IN NUMBER,
		    X_CUST_TRX_LINE_GL_DIST_ID 	IN NUMBER,
		    X_MF_ADJUSTMENT_CCID 	IN NUMBER,
		    X_AMOUNT 			IN NUMBER,
		    X_PERCENT 			IN NUMBER,
		    X_PREV_CUST_TRX_LINE_ID 	IN NUMBER,
		    X_COMMENTS			IN VARCHAR2 ) IS

	CURSOR c1 IS Select  MF_ADJUSTMENT_CCID,
			     AMOUNT,
			     PERCENT,
			     PREV_CUST_TRX_LINE_ID,
			     COMMENTS
		       From  PSA_MF_ADJ_DIST_ALL
		       Where ADJUSTMENT_ID = X_ADJUSTMENT_ID
		       And   CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID
		       FOR UPDATE OF  ADJUSTMENT_ID NOWAIT;

  tlinfo c1%rowtype;

BEGIN
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.MF_ADJUSTMENT_CCID = X_MF_ADJUSTMENT_CCID)
      AND (tlinfo.AMOUNT = X_AMOUNT)
      AND (tlinfo.PERCENT = X_PERCENT)
      AND ((tlinfo.PREV_CUST_TRX_LINE_ID = X_PREV_CUST_TRX_LINE_ID)
           OR ((tlinfo.PREV_CUST_TRX_LINE_ID is null)
               AND (X_PREV_CUST_TRX_LINE_ID is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
    ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
END LOCK_ROW;

PROCEDURE UPDATE_ROW ( X_ADJUSTMENT_ID 			IN NUMBER,
		       X_CUST_TRX_LINE_GL_DIST_ID 	IN NUMBER,
		       X_MF_ADJUSTMENT_CCID 		IN NUMBER,
		       X_AMOUNT 			IN NUMBER,
		       X_PERCENT 			IN NUMBER,
		       X_PREV_CUST_TRX_LINE_ID 		IN NUMBER,
		       X_COMMENTS			IN VARCHAR2,
		       X_MODE 				IN VARCHAR2 DEFAULT 'R' ) is

    X_LAST_UPDATE_DATE 	DATE;
    X_LAST_UPDATED_BY 	NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;

BEGIN
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

  UPDATE PSA_MF_ADJ_DIST_ALL set
		MF_ADJUSTMENT_CCID 	= X_MF_ADJUSTMENT_CCID,
		AMOUNT 			= X_AMOUNT,
		PERCENT 		= X_PERCENT,
		PREV_CUST_TRX_LINE_ID 	= X_PREV_CUST_TRX_LINE_ID,
		LAST_UPDATE_DATE 	= X_LAST_UPDATE_DATE,
		LAST_UPDATED_BY 	= X_LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN 	= X_LAST_UPDATE_LOGIN,
		COMMENTS		= X_COMMENTS
  WHERE ADJUSTMENT_ID = X_ADJUSTMENT_ID
  and 	CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
END UPDATE_ROW;

PROCEDURE ADD_ROW ( X_ROWID 			IN OUT VARCHAR2,
		    X_ADJUSTMENT_ID 		IN NUMBER,
		    X_CUST_TRX_LINE_GL_DIST_ID 	IN NUMBER,
		    X_MF_ADJUSTMENT_CCID 	IN NUMBER,
		    X_AMOUNT 			IN NUMBER,
		    X_PERCENT 			IN NUMBER,
		    X_PREV_CUST_TRX_LINE_ID 	IN NUMBER,
		    X_COMMENTS			IN VARCHAR2,
		    X_MODE 			IN VARCHAR2 default 'R') IS

  cursor c1 is select 	rowid
  		 from 	PSA_MF_ADJ_DIST_ALL
		where 	ADJUSTMENT_ID 		 = X_ADJUSTMENT_ID
		and 	CUST_TRX_LINE_GL_DIST_ID = X_CUST_TRX_LINE_GL_DIST_ID;

  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW ( X_ROWID,
		 X_ADJUSTMENT_ID,
		 X_CUST_TRX_LINE_GL_DIST_ID,
		 X_MF_ADJUSTMENT_CCID,
		 X_AMOUNT,
		 X_PERCENT,
		 X_PREV_CUST_TRX_LINE_ID,
		 X_COMMENTS,
		 X_MODE );
    return;
  end if;
  close c1;

  UPDATE_ROW (  X_ADJUSTMENT_ID,
		X_CUST_TRX_LINE_GL_DIST_ID,
		X_MF_ADJUSTMENT_CCID,
		X_AMOUNT,
		X_PERCENT,
		X_PREV_CUST_TRX_LINE_ID,
		X_COMMENTS,
		X_MODE );
END ADD_ROW;

PROCEDURE DELETE_ROW (  X_ADJUSTMENT_ID 		IN NUMBER,
			X_CUST_TRX_LINE_GL_DIST_ID 	IN NUMBER ) IS
BEGIN

  DELETE FROM PSA_MF_ADJ_DIST_ALL
  WHERE  ADJUSTMENT_ID 			= X_ADJUSTMENT_ID
  AND	 CUST_TRX_LINE_GL_DIST_ID 	= X_CUST_TRX_LINE_GL_DIST_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
END DELETE_ROW;

END PSA_MFAR_ADJUSTMENT_COVER_PKG;

/
