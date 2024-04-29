--------------------------------------------------------
--  DDL for Package Body IGW_BUSINESS_RULE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUSINESS_RULE_LINES_PKG" as
 /* $Header: igwstrlb.pls 115.3 2002/03/28 19:14:12 pkm ship    $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_RULE_ID in NUMBER,
  X_EXPRESSION_ID in NUMBER,
  X_EXPRESSION_SEQUENCE_NUMBER in NUMBER,
  X_EXPRESSION_TYPE in VARCHAR2,
  X_LBRACKETS in VARCHAR2,
  X_LVALUE in VARCHAR2,
  X_OPERATOR in VARCHAR2,
  X_RVALUE in VARCHAR2,
  X_RVALUE_ID in VARCHAR2,
  X_RBRACKETS in VARCHAR2,
  X_LOGICAL_OPERATOR in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from IGW_BUSINESS_RULE_LINES
      where RULE_ID = X_RULE_ID
      and EXPRESSION_ID = X_EXPRESSION_ID;
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
  insert into IGW_BUSINESS_RULE_LINES (
    RULE_ID,
    EXPRESSION_ID,
    EXPRESSION_SEQUENCE_NUMBER,
    EXPRESSION_TYPE,
    LBRACKETS,
    LVALUE,
    OPERATOR,
    RVALUE,
    RVALUE_ID,
    RBRACKETS,
    LOGICAL_OPERATOR,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RULE_ID,
    X_EXPRESSION_ID,
    X_EXPRESSION_SEQUENCE_NUMBER,
    X_EXPRESSION_TYPE,
    X_LBRACKETS,
    X_LVALUE,
    X_OPERATOR,
    X_RVALUE,
    X_RVALUE_ID,
    X_RBRACKETS,
    X_LOGICAL_OPERATOR,
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
  X_ROWID in VARCHAR2,
  X_RULE_ID in NUMBER,
  X_EXPRESSION_ID in NUMBER,
  X_EXPRESSION_SEQUENCE_NUMBER in NUMBER,
  X_EXPRESSION_TYPE in VARCHAR2,
  X_LBRACKETS in VARCHAR2,
  X_LVALUE in VARCHAR2,
  X_OPERATOR in VARCHAR2,
  X_RVALUE in VARCHAR2,
  X_RVALUE_ID in VARCHAR2,
  X_RBRACKETS in VARCHAR2,
  X_LOGICAL_OPERATOR in VARCHAR2
) is
  cursor c1 is select *
    from IGW_BUSINESS_RULE_LINES
    where ROWID = X_ROWID
    for update of RULE_ID nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if (
          (tlinfo.RULE_ID = X_RULE_ID)
      AND (tlinfo.EXPRESSION_ID = X_EXPRESSION_ID)
      AND (tlinfo.EXPRESSION_SEQUENCE_NUMBER = X_EXPRESSION_SEQUENCE_NUMBER)
      AND (tlinfo.EXPRESSION_TYPE = X_EXPRESSION_TYPE)
      AND ((tlinfo.LBRACKETS = X_LBRACKETS)
           OR ((tlinfo.LBRACKETS is null)
               AND (X_LBRACKETS is null)))
      AND (tlinfo.LVALUE = X_LVALUE)
      AND (tlinfo.OPERATOR = X_OPERATOR)
      AND (tlinfo.RVALUE = X_RVALUE)
      AND ((tlinfo.RVALUE_ID = X_RVALUE_ID)
           OR ((tlinfo.RVALUE_ID is null)
               AND (X_RVALUE_ID is null)))
      AND ((tlinfo.RBRACKETS = X_RBRACKETS)
           OR ((tlinfo.RBRACKETS is null)
               AND (X_RBRACKETS is null)))
      AND ((tlinfo.LOGICAL_OPERATOR = X_LOGICAL_OPERATOR)
           OR ((tlinfo.LOGICAL_OPERATOR is null)
               AND (X_LOGICAL_OPERATOR is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID  in  VARCHAR2,
  X_RULE_ID in NUMBER,
  X_EXPRESSION_ID in NUMBER,
  X_EXPRESSION_SEQUENCE_NUMBER in NUMBER,
  X_EXPRESSION_TYPE in VARCHAR2,
  X_LBRACKETS in VARCHAR2,
  X_LVALUE in VARCHAR2,
  X_OPERATOR in VARCHAR2,
  X_RVALUE in VARCHAR2,
  X_RVALUE_ID in VARCHAR2,
  X_RBRACKETS in VARCHAR2,
  X_LOGICAL_OPERATOR in VARCHAR2,
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
  update IGW_BUSINESS_RULE_LINES set
    RULE_ID = X_RULE_ID,
    EXPRESSION_ID = X_EXPRESSION_ID,
    EXPRESSION_SEQUENCE_NUMBER = X_EXPRESSION_SEQUENCE_NUMBER,
    EXPRESSION_TYPE = X_EXPRESSION_TYPE,
    LBRACKETS = X_LBRACKETS,
    LVALUE = X_LVALUE,
    OPERATOR = X_OPERATOR,
    RVALUE = X_RVALUE,
    RVALUE_ID = X_RVALUE_ID,
    RBRACKETS = X_RBRACKETS,
    LOGICAL_OPERATOR = X_LOGICAL_OPERATOR,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

/*procedure ADD_ROW (
  X_ROWID in out VARCHAR2,
  X_RULE_ID in NUMBER,
  X_EXPRESSION_ID in NUMBER,
  X_EXPRESSION_SEQUENCE_NUMBER in NUMBER,
  X_EXPRESSION_TYPE in VARCHAR2,
  X_LBRACKETS in VARCHAR2,
  X_LVALUE in VARCHAR2,
  X_OPERATOR in VARCHAR2,
  X_RVALUE in VARCHAR2,
  X_RVALUE_ID in VARCHAR2,
  X_RBRACKETS in VARCHAR2,
  X_LOGICAL_OPERATOR in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from IGW_BUSINESS_RULE_LINES
     where RULE_ID = X_RULE_ID
     and EXPRESSION_ID = X_EXPRESSION_ID
  ;
  dummy c1%rowtype;
begin
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_RULE_ID,
     X_EXPRESSION_ID,
     X_EXPRESSION_SEQUENCE_NUMBER,
     X_EXPRESSION_TYPE,
     X_LBRACKETS,
     X_LVALUE,
     X_OPERATOR,
     X_RVALUE,
     X_RVALUE_ID,
     X_RBRACKETS,
     X_LOGICAL_OPERATOR,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_RULE_ID,
   X_EXPRESSION_ID,
   X_EXPRESSION_SEQUENCE_NUMBER,
   X_EXPRESSION_TYPE,
   X_LBRACKETS,
   X_LVALUE,
   X_OPERATOR,
   X_RVALUE,
   X_RVALUE_ID,
   X_RBRACKETS,
   X_LOGICAL_OPERATOR,
   X_MODE);
end ADD_ROW; */

procedure DELETE_ROW (
   X_ROWID in VARCHAR2
) is
begin
  delete from IGW_BUSINESS_RULE_LINES
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGW_BUSINESS_RULE_LINES_PKG;

/
