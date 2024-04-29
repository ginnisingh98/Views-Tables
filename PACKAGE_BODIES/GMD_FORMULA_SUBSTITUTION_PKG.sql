--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_SUBSTITUTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_SUBSTITUTION_PKG" as
/* $Header: GMDFRSBB.pls 120.0 2005/05/25 18:33:19 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FORMULA_SUBSTITUTION_ID in NUMBER,
  X_SUBSTITUTION_ID in NUMBER,
  X_FORMULA_ID in NUMBER,
  X_ASSOCIATED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_FORMULA_SUBSTITUTION
    where FORMULA_SUBSTITUTION_ID = X_FORMULA_SUBSTITUTION_ID
    ;
begin
  insert into GMD_FORMULA_SUBSTITUTION (
    FORMULA_SUBSTITUTION_ID,
    SUBSTITUTION_ID,
    FORMULA_ID,
    ASSOCIATED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FORMULA_SUBSTITUTION_ID,
    X_SUBSTITUTION_ID,
    X_FORMULA_ID,
    X_ASSOCIATED_FLAG,
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
  X_FORMULA_SUBSTITUTION_ID in NUMBER,
  X_SUBSTITUTION_ID in NUMBER,
  X_FORMULA_ID in NUMBER,
  X_ASSOCIATED_FLAG in VARCHAR2
) is
  cursor c is select
      SUBSTITUTION_ID,
      FORMULA_ID,
      ASSOCIATED_FLAG
    from GMD_FORMULA_SUBSTITUTION
    where FORMULA_SUBSTITUTION_ID = X_FORMULA_SUBSTITUTION_ID
    for update of FORMULA_SUBSTITUTION_ID nowait;
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
  if (    (recinfo.SUBSTITUTION_ID = X_SUBSTITUTION_ID)
      AND (recinfo.FORMULA_ID = X_FORMULA_ID)
      AND ((recinfo.ASSOCIATED_FLAG = X_ASSOCIATED_FLAG)
           OR ((recinfo.ASSOCIATED_FLAG is null) AND (X_ASSOCIATED_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_FORMULA_SUBSTITUTION_ID in NUMBER,
  X_SUBSTITUTION_ID in NUMBER,
  X_FORMULA_ID in NUMBER,
  X_ASSOCIATED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_FORMULA_SUBSTITUTION set
    SUBSTITUTION_ID = X_SUBSTITUTION_ID,
    FORMULA_ID = X_FORMULA_ID,
    ASSOCIATED_FLAG = X_ASSOCIATED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FORMULA_SUBSTITUTION_ID = X_FORMULA_SUBSTITUTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_FORMULA_SUBSTITUTION_ID in NUMBER
) is
begin

  delete from GMD_FORMULA_SUBSTITUTION
  where FORMULA_SUBSTITUTION_ID = X_FORMULA_SUBSTITUTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end GMD_FORMULA_SUBSTITUTION_PKG;

/
