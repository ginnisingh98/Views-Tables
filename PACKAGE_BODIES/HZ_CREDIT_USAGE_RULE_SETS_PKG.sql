--------------------------------------------------------
--  DDL for Package Body HZ_CREDIT_USAGE_RULE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CREDIT_USAGE_RULE_SETS_PKG" AS
/* $Header: ARHCRUSB.pls 115.10 2003/08/18 17:56:27 rajkrish ship $ */


---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--========================================================================
-- PROCEDURE : Insert_row                   PUBLIC
-- COMMENT   : Procedure inserts record into the table HZ_CREDIT_USAGE_RULE_SETS_B
--             and  HZ_CREDIT_USAGE_RULE_SETS_TL
--========================================================================
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CREDIT_USAGE_RULE_SET_ID in NUMBER,
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
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_GLOBAL_EXPOSURE_FLAG IN VARCHAR2
) is
  cursor C is select ROWID from HZ_CREDIT_USAGE_RULE_SETS_B
    where CREDIT_USAGE_RULE_SET_ID = X_CREDIT_USAGE_RULE_SET_ID
    ;
begin
  insert into HZ_CREDIT_USAGE_RULE_SETS_B (
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
    REQUEST_ID,
    CREDIT_USAGE_RULE_SET_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    GLOBAL_EXPOSURE_FLAG
  ) values (
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
    X_REQUEST_ID,
    X_CREDIT_USAGE_RULE_SET_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_GLOBAL_EXPOSURE_FLAG
  );

  insert into HZ_CREDIT_USAGE_RULE_SETS_TL (
    CREDIT_USAGE_RULE_SET_ID,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREDIT_USAGE_RULE_SET_ID,
    X_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HZ_CREDIT_USAGE_RULE_SETS_TL T
    where T.CREDIT_USAGE_RULE_SET_ID = X_CREDIT_USAGE_RULE_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Insert_row');
    END IF;
    RAISE;

 END Insert_row;

--========================================================================
-- PROCEDURE : Lock_row                     PUBLIC
-- PARAMETERS: p_credit_usage_rule_set_id   credit_usage_rule_set_id
--             p_rule_set_name              rule set name
--             p_last_update_date
-- COMMENT   : Procedure locks record in the table HZ_CREDIT_USAGE_RULE_SETS_B
--             and  HZ_CREDIT_USAGE_RULE_SETS_TL
--========================================================================
procedure LOCK_ROW (
  X_CREDIT_USAGE_RULE_SET_ID in NUMBER,
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
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2
) is
  cursor c is select
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
      REQUEST_ID
    from HZ_CREDIT_USAGE_RULE_SETS_B
    where CREDIT_USAGE_RULE_SET_ID = X_CREDIT_USAGE_RULE_SET_ID
    for update of CREDIT_USAGE_RULE_SET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HZ_CREDIT_USAGE_RULE_SETS_TL
    where CREDIT_USAGE_RULE_SET_ID = X_CREDIT_USAGE_RULE_SET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CREDIT_USAGE_RULE_SET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

--========================================================================
-- PROCEDURE : Update_row                   PUBLIC
-- COMMENT   : Procedure updates record in the table HZ_CREDIT_USAGE_RULE_SETS_B
--             and  HZ_CREDIT_USAGE_RULE_SETS_TL
--========================================================================
procedure UPDATE_ROW (
  X_CREDIT_USAGE_RULE_SET_ID in NUMBER,
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
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_GLOBAL_EXPOSURE_FLAG IN VARCHAR2
) is
begin
  update HZ_CREDIT_USAGE_RULE_SETS_B set
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
    REQUEST_ID = X_REQUEST_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    GLOBAL_EXPOSURE_FLAG = X_GLOBAL_EXPOSURE_FLAG
  where CREDIT_USAGE_RULE_SET_ID = X_CREDIT_USAGE_RULE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HZ_CREDIT_USAGE_RULE_SETS_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CREDIT_USAGE_RULE_SET_ID = X_CREDIT_USAGE_RULE_SET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Update_row');
    END IF;
  RAISE;

END Update_Row;

--========================================================================
-- PROCEDURE : Delete_row             		 PUBLIC
-- COMMENT   : Procedure deletes record from the
--           table HZ_CREDIT_USAGE_RULE_SETS_B
--             and  HZ_CREDIT_USAGE_RULE_SETS_TL
--========================================================================
procedure DELETE_ROW (
  X_CREDIT_USAGE_RULE_SET_ID in NUMBER
) is
begin
  delete from HZ_CREDIT_USAGE_RULE_SETS_TL
  where CREDIT_USAGE_RULE_SET_ID = X_CREDIT_USAGE_RULE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HZ_CREDIT_USAGE_RULE_SETS_B
  where CREDIT_USAGE_RULE_SET_ID = X_CREDIT_USAGE_RULE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- BUG 2056313
  -- Delete the attached records from the HZ_CREDIT_USAGES
  -- to prevent unwanted data that has no parent. This is important
  -- to enable the validations in the Assign Usages Rules form to
  -- function correctly.

  DELETE from HZ_credit_usages
  WHERE  credit_usage_rule_set_id = X_CREDIT_USAGE_RULE_SET_ID ;

  /*if (sql%notfound) then
    raise no_data_found;
  end if;
 */


EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Delete_row');
    END IF;
  RAISE;

END Delete_row;

--========================================================================
-- PROCEDURE : ADD_LANGUAGE            		 PUBLIC
--
-- COMMENT   : Procedure adds new language
--========================================================================
procedure ADD_LANGUAGE
is
begin
  delete from HZ_CREDIT_USAGE_RULE_SETS_TL T
  where not exists
    (select NULL
    from HZ_CREDIT_USAGE_RULE_SETS_B B
    where B.CREDIT_USAGE_RULE_SET_ID = T.CREDIT_USAGE_RULE_SET_ID
    );

  update HZ_CREDIT_USAGE_RULE_SETS_TL T set (
      NAME
    ) = (select
      B.NAME
    from HZ_CREDIT_USAGE_RULE_SETS_TL B
    where B.CREDIT_USAGE_RULE_SET_ID = T.CREDIT_USAGE_RULE_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CREDIT_USAGE_RULE_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CREDIT_USAGE_RULE_SET_ID,
      SUBT.LANGUAGE
    from HZ_CREDIT_USAGE_RULE_SETS_TL SUBB, HZ_CREDIT_USAGE_RULE_SETS_TL SUBT
    where SUBB.CREDIT_USAGE_RULE_SET_ID = SUBT.CREDIT_USAGE_RULE_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into HZ_CREDIT_USAGE_RULE_SETS_TL (
    CREDIT_USAGE_RULE_SET_ID,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREDIT_USAGE_RULE_SET_ID,
    B.NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HZ_CREDIT_USAGE_RULE_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HZ_CREDIT_USAGE_RULE_SETS_TL T
    where T.CREDIT_USAGE_RULE_SET_ID = B.CREDIT_USAGE_RULE_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END HZ_CREDIT_USAGE_RULE_SETS_PKG;

/
