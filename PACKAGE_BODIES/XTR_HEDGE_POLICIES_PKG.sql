--------------------------------------------------------
--  DDL for Package Body XTR_HEDGE_POLICIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_HEDGE_POLICIES_PKG" as
/* $Header: xtrhpolb.pls 120.4 2005/06/29 08:18:55 badiredd ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_HEDGE_POLICY_ID in NUMBER,
  X_SOURCE_TYPE_ID in NUMBER,
  X_CASHFLOW_FLAG in VARCHAR2,
  X_FAIRVALUE_FLAG in VARCHAR2,
  X_ECONOMIC_FLAG in VARCHAR2,  --Bug 3378028
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XTR_HEDGE_POLICIES
    where HEDGE_POLICY_ID = X_HEDGE_POLICY_ID;
begin
  insert into XTR_HEDGE_POLICIES (
    HEDGE_POLICY_ID,
    SOURCE_TYPE_ID,
    CASHFLOW_FLAG,
    FAIRVALUE_FLAG,
    ECONOMIC_FLAG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) VALUES (
    X_HEDGE_POLICY_ID,
    X_SOURCE_TYPE_ID,
    X_CASHFLOW_FLAG,
    X_FAIRVALUE_FLAG,
    X_ECONOMIC_FLAG,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_HEDGE_POLICY_ID in NUMBER,
  X_SOURCE_TYPE_ID in NUMBER,
  X_CASHFLOW_FLAG in VARCHAR2,
  X_FAIRVALUE_FLAG in VARCHAR2,
  X_ECONOMIC_FLAG in VARCHAR2  --Bug 3378028
) is
  cursor c1 is select
      SOURCE_TYPE_ID,
      CASHFLOW_FLAG,
      FAIRVALUE_FLAG,
      ECONOMIC_FLAG,
      HEDGE_POLICY_ID
    from XTR_HEDGE_POLICIES
    where HEDGE_POLICY_ID = X_HEDGE_POLICY_ID
    for update of HEDGE_POLICY_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.HEDGE_POLICY_ID = X_HEDGE_POLICY_ID)
          AND (tlinfo.SOURCE_TYPE_ID = X_SOURCE_TYPE_ID)
          AND ((tlinfo.CASHFLOW_FLAG = X_CASHFLOW_FLAG)
               OR ((tlinfo.CASHFLOW_FLAG is null) AND (X_CASHFLOW_FLAG is null)))
          AND ((tlinfo.FAIRVALUE_FLAG = X_FAIRVALUE_FLAG)
               OR ((tlinfo.FAIRVALUE_FLAG is null) AND (X_FAIRVALUE_FLAG is null)))
          AND ((tlinfo.ECONOMIC_FLAG = X_ECONOMIC_FLAG)
               OR ((tlinfo.ECONOMIC_FLAG is null) AND (X_ECONOMIC_FLAG is null)))
         ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_HEDGE_POLICY_ID in NUMBER,
  X_SOURCE_TYPE_ID in NUMBER,
  X_CASHFLOW_FLAG in VARCHAR2,
  X_FAIRVALUE_FLAG in VARCHAR2,
  X_ECONOMIC_FLAG in VARCHAR2,  --Bug 3378028
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XTR_HEDGE_POLICIES set
    SOURCE_TYPE_ID = X_SOURCE_TYPE_ID,
    CASHFLOW_FLAG = X_CASHFLOW_FLAG,
    FAIRVALUE_FLAG = X_FAIRVALUE_FLAG,
    ECONOMIC_FLAG = X_ECONOMIC_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where HEDGE_POLICY_ID = X_HEDGE_POLICY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_HEDGE_POLICY_ID in NUMBER
) is
begin
  delete from XTR_HEDGE_POLICIES
  where HEDGE_POLICY_ID = X_HEDGE_POLICY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;
end;

/
