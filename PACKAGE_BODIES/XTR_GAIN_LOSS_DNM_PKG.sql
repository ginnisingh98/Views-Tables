--------------------------------------------------------
--  DDL for Package Body XTR_GAIN_LOSS_DNM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_GAIN_LOSS_DNM_PKG" as
/* $Header: xtrgldpb.pls 120.3 2005/06/29 08:14:47 badiredd ship $ */

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_GAIN_LOSS_DNM_ID in NUMBER,
  X_BATCH_ID in NUMBER,
  X_COMPANY_CODE in VARCHAR2,
  X_DEAL_NUMBER in NUMBER,
  X_TRANSACTION_NUMBER in NUMBER,
  X_DATE_TYPE in VARCHAR2,
  X_AMOUNT in NUMBER,
  X_AMOUNT_TYPE in VARCHAR2,
  X_ACTION in VARCHAR2,
  X_CURRENCY in VARCHAR2,
  X_JOURNAL_DATE in DATE,
  X_REVAL_EFF_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XTR_GAIN_LOSS_DNM
    where GAIN_LOSS_DNM_ID = X_GAIN_LOSS_DNM_ID
    ;
begin
  insert into XTR_GAIN_LOSS_DNM (
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    COMPANY_CODE,
    DEAL_NUMBER,
    TRANSACTION_NUMBER,
    DATE_TYPE,
    AMOUNT,
    AMOUNT_TYPE,
    ACTION,
    CURRENCY,
    JOURNAL_DATE,
    CREATION_DATE,
    CREATED_BY,
    GAIN_LOSS_DNM_ID,
    BATCH_ID,
    REVAL_EFF_FLAG
  ) VALUES
  ( X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_COMPANY_CODE,
    X_DEAL_NUMBER,
    X_TRANSACTION_NUMBER,
    X_DATE_TYPE,
    X_AMOUNT,
    X_AMOUNT_TYPE,
    X_ACTION,
    X_CURRENCY,
    X_JOURNAL_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_GAIN_LOSS_DNM_ID,
    X_BATCH_ID,
    X_REVAL_EFF_FLAG);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_GAIN_LOSS_DNM_ID in NUMBER,
  X_BATCH_ID in NUMBER,
  X_COMPANY_CODE in VARCHAR2,
  X_DEAL_NUMBER in NUMBER,
  X_TRANSACTION_NUMBER in NUMBER,
  X_DATE_TYPE in VARCHAR2,
  X_AMOUNT in NUMBER,
  X_AMOUNT_TYPE in VARCHAR2,
  X_ACTION in VARCHAR2,
  X_CURRENCY in VARCHAR2,
  X_JOURNAL_DATE in DATE,
  X_REVAL_EFF_FLAG in VARCHAR2
) is
  cursor c1 is select
      COMPANY_CODE,
      DEAL_NUMBER,
      TRANSACTION_NUMBER,
      DATE_TYPE,
      AMOUNT,
      AMOUNT_TYPE,
      ACTION,
      CURRENCY,
      JOURNAL_DATE,
      BATCH_ID,
      REVAL_EFF_FLAG
    from XTR_GAIN_LOSS_DNM
    where GAIN_LOSS_DNM_ID = X_GAIN_LOSS_DNM_ID
    for update of GAIN_LOSS_DNM_ID nowait;
begin
  for tlinfo in c1 loop
      if (    ((tlinfo.BATCH_ID = X_BATCH_ID)
               OR ((tlinfo.BATCH_ID is null) AND (X_BATCH_ID is null)))
          AND ((tlinfo.COMPANY_CODE = X_COMPANY_CODE)
               OR ((tlinfo.COMPANY_CODE is null) AND (X_COMPANY_CODE is null)))
          AND ((tlinfo.DEAL_NUMBER = X_DEAL_NUMBER)
               OR ((tlinfo.DEAL_NUMBER is null) AND (X_DEAL_NUMBER is null)))
          AND ((tlinfo.TRANSACTION_NUMBER = X_TRANSACTION_NUMBER)
               OR ((tlinfo.TRANSACTION_NUMBER is null) AND (X_TRANSACTION_NUMBER is null)))
          AND ((tlinfo.DATE_TYPE = X_DATE_TYPE)
               OR ((tlinfo.DATE_TYPE is null) AND (X_DATE_TYPE is null)))
          AND ((tlinfo.AMOUNT = X_AMOUNT)
               OR ((tlinfo.AMOUNT is null) AND (X_AMOUNT is null)))
          AND ((tlinfo.AMOUNT_TYPE = X_AMOUNT_TYPE)
               OR ((tlinfo.AMOUNT_TYPE is null) AND (X_AMOUNT_TYPE is null)))
          AND ((tlinfo.ACTION = X_ACTION)
               OR ((tlinfo.ACTION is null) AND (X_ACTION is null)))
          AND ((tlinfo.CURRENCY = X_CURRENCY)
               OR ((tlinfo.CURRENCY is null) AND (X_CURRENCY is null)))
          AND ((tlinfo.JOURNAL_DATE = X_JOURNAL_DATE)
               OR ((tlinfo.JOURNAL_DATE is null) AND (X_JOURNAL_DATE is null)))
          AND ((tlinfo.REVAL_EFF_FLAG = X_REVAL_EFF_FLAG)
               OR ((tlinfo.REVAL_EFF_FLAG is null) AND (X_REVAL_EFF_FLAG is null)))
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
  X_GAIN_LOSS_DNM_ID in NUMBER,
  X_BATCH_ID in NUMBER,
  X_COMPANY_CODE in VARCHAR2,
  X_DEAL_NUMBER in NUMBER,
  X_TRANSACTION_NUMBER in NUMBER,
  X_DATE_TYPE in VARCHAR2,
  X_AMOUNT in NUMBER,
  X_AMOUNT_TYPE in VARCHAR2,
  X_ACTION in VARCHAR2,
  X_CURRENCY in VARCHAR2,
  X_JOURNAL_DATE in DATE,
  X_REVAL_EFF_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XTR_GAIN_LOSS_DNM set
    COMPANY_CODE = X_COMPANY_CODE,
    DEAL_NUMBER = X_DEAL_NUMBER,
    TRANSACTION_NUMBER = X_TRANSACTION_NUMBER,
    DATE_TYPE = X_DATE_TYPE,
    AMOUNT = X_AMOUNT,
    AMOUNT_TYPE = X_AMOUNT_TYPE,
    ACTION = X_ACTION,
    CURRENCY = X_CURRENCY,
    JOURNAL_DATE = X_JOURNAL_DATE,
    BATCH_ID = X_BATCH_ID,
    REVAL_EFF_FLAG = X_REVAL_EFF_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where GAIN_LOSS_DNM_ID = X_GAIN_LOSS_DNM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GAIN_LOSS_DNM_ID in NUMBER
) is
begin
  delete from XTR_GAIN_LOSS_DNM
  where GAIN_LOSS_DNM_ID = X_GAIN_LOSS_DNM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end XTR_GAIN_LOSS_DNM_PKG;

/
