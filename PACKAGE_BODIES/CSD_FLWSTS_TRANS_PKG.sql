--------------------------------------------------------
--  DDL for Package Body CSD_FLWSTS_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_FLWSTS_TRANS_PKG" as
/* $Header: csdtfltb.pls 120.1 2005/07/29 16:35:56 vkjain noship $ */

procedure INSERT_ROW (
  -- P_ROWID in out nocopy VARCHAR2,
  PX_FLWSTS_TRAN_ID in out nocopy NUMBER,
  P_REPAIR_TYPE_ID in NUMBER,
  P_FROM_FLOW_STATUS_ID in NUMBER,
  P_TO_FLOW_STATUS_ID in NUMBER,
  P_WF_ITEM_TYPE in VARCHAR2,
  P_WF_PROCESS_NAME in VARCHAR2,
  P_REASON_REQUIRED_FLAG in VARCHAR2,
  P_CAPTURE_ACTIVITY_FLAG in VARCHAR2,
  P_ALLOW_ALL_RESP_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_DESCRIPTION in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is

  P_ROWID ROWID;

  cursor C is select ROWID from CSD_FLWSTS_TRANS_B
    where FLWSTS_TRAN_ID = PX_FLWSTS_TRAN_ID
    ;

begin

  select CSD_FLWSTS_TRANS_S1.nextval
  into PX_FLWSTS_TRAN_ID
  from dual;

  insert into CSD_FLWSTS_TRANS_B (
    REPAIR_TYPE_ID,
    FROM_FLOW_STATUS_ID,
    TO_FLOW_STATUS_ID,
    WF_ITEM_TYPE,
    WF_PROCESS_NAME,
    REASON_REQUIRED_FLAG,
    CAPTURE_ACTIVITY_FLAG,
    ALLOW_ALL_RESP_FLAG,
    OBJECT_VERSION_NUMBER,
    FLWSTS_TRAN_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_REPAIR_TYPE_ID,
    P_FROM_FLOW_STATUS_ID,
    P_TO_FLOW_STATUS_ID,
    P_WF_ITEM_TYPE,
    P_WF_PROCESS_NAME,
    P_REASON_REQUIRED_FLAG,
    P_CAPTURE_ACTIVITY_FLAG,
    P_ALLOW_ALL_RESP_FLAG,
    P_OBJECT_VERSION_NUMBER,
    PX_FLWSTS_TRAN_ID,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  );

  insert into CSD_FLWSTS_TRANS_TL (
    FLWSTS_TRAN_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    PX_FLWSTS_TRAN_ID,
    P_DESCRIPTION,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CSD_FLWSTS_TRANS_TL T
    where T.FLWSTS_TRAN_ID = PX_FLWSTS_TRAN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  P_FLWSTS_TRAN_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
/*
  P_REPAIR_TYPE_ID in NUMBER,
  P_FROM_FLOW_STATUS_ID in NUMBER,
  P_TO_FLOW_STATUS_ID in NUMBER,
  P_WF_ITEM_TYPE in VARCHAR2,
  P_WF_PROCESS_NAME in VARCHAR2,
  P_REASON_REQUIRED_FLAG in VARCHAR2,
  P_CAPTURE_ACTIVITY_FLAG in VARCHAR2,
  P_ALLOW_ALL_RESP_FLAG in VARCHAR2,
  P_DESCRIPTION in VARCHAR2
*/
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from CSD_FLWSTS_TRANS_B
    where FLWSTS_TRAN_ID = P_FLWSTS_TRAN_ID
    for update of FLWSTS_TRAN_ID nowait;
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

  if (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

/*
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = P_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (P_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
*/

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  P_FLWSTS_TRAN_ID in NUMBER,
  P_REPAIR_TYPE_ID in NUMBER,
  P_FROM_FLOW_STATUS_ID in NUMBER,
  P_TO_FLOW_STATUS_ID in NUMBER,
  P_WF_ITEM_TYPE in VARCHAR2,
  P_WF_PROCESS_NAME in VARCHAR2,
  P_REASON_REQUIRED_FLAG in VARCHAR2,
  P_CAPTURE_ACTIVITY_FLAG in VARCHAR2,
  P_ALLOW_ALL_RESP_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_DESCRIPTION in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CSD_FLWSTS_TRANS_B set
    REPAIR_TYPE_ID = P_REPAIR_TYPE_ID,
    FROM_FLOW_STATUS_ID = P_FROM_FLOW_STATUS_ID,
    TO_FLOW_STATUS_ID = P_TO_FLOW_STATUS_ID,
    WF_ITEM_TYPE = P_WF_ITEM_TYPE,
    WF_PROCESS_NAME = P_WF_PROCESS_NAME,
    REASON_REQUIRED_FLAG = P_REASON_REQUIRED_FLAG,
    CAPTURE_ACTIVITY_FLAG = P_CAPTURE_ACTIVITY_FLAG,
    ALLOW_ALL_RESP_FLAG = P_ALLOW_ALL_RESP_FLAG,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where FLWSTS_TRAN_ID = P_FLWSTS_TRAN_ID AND
        OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CSD_FLWSTS_TRANS_TL set
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FLWSTS_TRAN_ID = P_FLWSTS_TRAN_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_FLWSTS_TRAN_ID in NUMBER
) is
begin
  delete from CSD_FLWSTS_TRANS_TL
  where FLWSTS_TRAN_ID = P_FLWSTS_TRAN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CSD_FLWSTS_TRANS_B
  where FLWSTS_TRAN_ID = P_FLWSTS_TRAN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CSD_FLWSTS_TRANS_TL T
  where not exists
    (select NULL
    from CSD_FLWSTS_TRANS_B B
    where B.FLWSTS_TRAN_ID = T.FLWSTS_TRAN_ID
    );

  update CSD_FLWSTS_TRANS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from CSD_FLWSTS_TRANS_TL B
    where B.FLWSTS_TRAN_ID = T.FLWSTS_TRAN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FLWSTS_TRAN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FLWSTS_TRAN_ID,
      SUBT.LANGUAGE
    from CSD_FLWSTS_TRANS_TL SUBB, CSD_FLWSTS_TRANS_TL SUBT
    where SUBB.FLWSTS_TRAN_ID = SUBT.FLWSTS_TRAN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSD_FLWSTS_TRANS_TL (
    FLWSTS_TRAN_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.FLWSTS_TRAN_ID,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSD_FLWSTS_TRANS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSD_FLWSTS_TRANS_TL T
    where T.FLWSTS_TRAN_ID = B.FLWSTS_TRAN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CSD_FLWSTS_TRANS_PKG;

/
