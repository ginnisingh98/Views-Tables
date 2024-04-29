--------------------------------------------------------
--  DDL for Package Body IEC_O_ALG_EXPR_OP_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_O_ALG_EXPR_OP_DEFS_PKG" as
/* $Header: IECHEODB.pls 120.1 2005/07/20 13:22:58 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_EXPR_CODE in VARCHAR2,
  X_OPERATOR_VAR in VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2,
  X_INACTIVE_DATA_NAME in VARCHAR2,
  X_INACTIVE_DATA_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEC_O_ALG_EXPR_OP_DEFS
    where EXPR_CODE = X_EXPR_CODE and OPERATOR_CODE = X_OPERATOR_CODE and
	OPERATOR_VAR = X_OPERATOR_VAR;
begin
  insert into IEC_O_ALG_EXPR_OP_DEFS (
    EXPR_CODE,
    OPERATOR_VAR,
    OPERATOR_CODE,
    INACTIVE_DATA_NAME,
    INACTIVE_DATA_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN)
    values (
    X_EXPR_CODE,
    X_OPERATOR_VAR,
    X_OPERATOR_CODE,
    X_INACTIVE_DATA_NAME,
    X_INACTIVE_DATA_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
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
  X_EXPR_CODE in VARCHAR2,
  X_OPERATOR_VAR in VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2,
  X_INACTIVE_DATA_NAME in VARCHAR2,
  X_INACTIVE_DATA_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      INACTIVE_DATA_NAME,
      INACTIVE_DATA_FLAG,
      OBJECT_VERSION_NUMBER
    from IEC_O_ALG_EXPR_OP_DEFS
    where EXPR_CODE = X_EXPR_CODE and OPERATOR_CODE = X_OPERATOR_CODE and
	OPERATOR_VAR = X_OPERATOR_VAR
    for update of EXPR_CODE,OPERATOR_CODE,OPERATOR_VAR  nowait;
  recinfo c%rowtype;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.INACTIVE_DATA_FLAG = X_INACTIVE_DATA_FLAG)
      AND ((recinfo.INACTIVE_DATA_NAME = X_INACTIVE_DATA_NAME)
           OR ((recinfo.INACTIVE_DATA_NAME is null) AND (X_INACTIVE_DATA_NAME is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_EXPR_CODE in VARCHAR2,
  X_OPERATOR_VAR in VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2,
  X_INACTIVE_DATA_NAME in VARCHAR2,
  X_INACTIVE_DATA_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_O_ALG_EXPR_OP_DEFS
  set
  INACTIVE_DATA_NAME = X_INACTIVE_DATA_NAME,
  INACTIVE_DATA_FLAG = X_INACTIVE_DATA_FLAG,
  OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
  LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where EXPR_CODE = X_EXPR_CODE and OPERATOR_CODE = X_OPERATOR_CODE and
	OPERATOR_VAR = X_OPERATOR_VAR;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_EXPR_CODE in VARCHAR2,
  X_OPERATOR_VAR in VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2
) is
begin
  delete from IEC_O_ALG_EXPR_OP_DEFS
  where EXPR_CODE = X_EXPR_CODE and OPERATOR_CODE = X_OPERATOR_CODE and
	OPERATOR_VAR = X_OPERATOR_VAR;


  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_EXPR_CODE in VARCHAR2,
  X_OPERATOR_VAR in VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2,
  X_INACTIVE_DATA_NAME in VARCHAR2,
  X_INACTIVE_DATA_FLAG in VARCHAR2,
  X_OWNER in VARCHAR2
) is
  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);
begin


  USER_ID := fnd_load_util.owner_id(x_owner);

  UPDATE_ROW (X_EXPR_CODE, X_OPERATOR_VAR, X_OPERATOR_CODE, X_INACTIVE_DATA_NAME, X_INACTIVE_DATA_FLAG, 0, SYSDATE, USER_ID, 0);

exception
  when no_data_found then
    INSERT_ROW (ROW_ID, X_EXPR_CODE, X_OPERATOR_VAR, X_OPERATOR_CODE, X_INACTIVE_DATA_NAME, X_INACTIVE_DATA_FLAG, 0, SYSDATE, USER_ID, SYSDATE, USER_ID, 0);

end LOAD_ROW;

procedure LOAD_SEED_ROW (
  X_upload_mode	in VARCHAR2,
  X_EXPR_CODE in VARCHAR2,
  X_OPERATOR_VAR in VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2,
  X_INACTIVE_DATA_NAME in VARCHAR2,
  X_INACTIVE_DATA_FLAG in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin
           if(X_upload_mode='NLS') then
							NULL;
           else
             IEC_O_ALG_EXPR_OP_DEFS_PKG.LOAD_ROW (
               					X_EXPR_CODE,
               					X_OPERATOR_VAR,
               					X_OPERATOR_CODE,
               					X_INACTIVE_DATA_NAME,
               					X_INACTIVE_DATA_FLAG,
	       					X_OWNER);
           end if;

end LOAD_SEED_ROW;

end IEC_O_ALG_EXPR_OP_DEFS_PKG;

/
