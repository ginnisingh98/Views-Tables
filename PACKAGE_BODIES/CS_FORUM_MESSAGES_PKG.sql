--------------------------------------------------------
--  DDL for Package Body CS_FORUM_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_FORUM_MESSAGES_PKG" AS
/* $Header: csfmagb.pls 115.7 2002/11/25 05:47:33 allau noship $ */
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 | FILENAME: csfmagb.pls                                                |
 |                                                                      |
 | PURPOSE                                                              |
 |   Table handlers for forum messages.                                 |
 | ARGUMENTS                                                            |
 |                                                                      |
 | NOTES                                                                |
 |   Usage: start                                                       |
 | HISTORY                                                              |
 |   19-OCT-1999 A. WONG Created                                        |
 |   04-OCT-2002 KLOU (UNISRCH)                                         |
 |               1. Add new column composite_assoc_col in               |
 |                  cs_forum_messages_tl.                               |
 |   25-NOV-2002 ALLAU
 |               Remove default value for IN parameters due to GSCC
 |               restriction
 +======================================================================*/

procedure INSERT_ROW (
  X_MESSAGE_ID in NUMBER,
  X_MESSAGE_NUMBER in NUMBER,
  X_MESSAGE_TYPE in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_POSTED_DATE in DATE,
  X_POSTED_USER in NUMBER,
  X_DESCRIPTION in CLOB,
  X_ACTIVE_STATUS in VARCHAR2,
  X_DISTRIBUTION_TYPE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2 ,
  X_ATTRIBUTE4 in VARCHAR2 ,
  X_ATTRIBUTE5 in VARCHAR2 ,
  X_ATTRIBUTE6 in VARCHAR2 ,
  X_ATTRIBUTE7 in VARCHAR2 ,
  X_ATTRIBUTE8 in VARCHAR2 ,
  X_ATTRIBUTE9 in VARCHAR2 ,
  X_ATTRIBUTE10 in VARCHAR2 ,
  X_ATTRIBUTE11 in VARCHAR2 ,
  X_ATTRIBUTE12 in VARCHAR2 ,
  X_ATTRIBUTE13 in VARCHAR2 ,
  X_ATTRIBUTE14 in VARCHAR2 ,
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor C is select MESSAGE_ID from CS_FORUM_MESSAGES_B
    where MESSAGE_ID = X_MESSAGE_ID
    ;
begin
  insert into CS_FORUM_MESSAGES_B (
    MESSAGE_ID,
    MESSAGE_NUMBER,
    MESSAGE_TYPE,
    MESSAGE_NAME,
    POSTED_DATE,
    POSTED_USER,
    ACTIVE_STATUS,
    DISTRIBUTION_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
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
  ) values (
    X_MESSAGE_ID,
    X_MESSAGE_NUMBER,
    X_MESSAGE_TYPE,
    X_MESSAGE_NAME,
    X_POSTED_DATE,
    X_POSTED_USER,
    X_ACTIVE_STATUS,
    X_DISTRIBUTION_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
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

  insert into CS_FORUM_MESSAGES_TL (
    MESSAGE_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    COMPOSITE_ASSOC_COL   --UNISRCH
  ) select
    X_MESSAGE_ID,
    X_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    'a'
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_FORUM_MESSAGES_TL T
    where T.MESSAGE_ID = X_MESSAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
/*
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
*/
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_MESSAGE_ID in NUMBER,
  X_MESSAGE_NUMBER in NUMBER,
  X_MESSAGE_TYPE in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in CLOB,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 ,
  X_ATTRIBUTE1 in VARCHAR2 ,
  X_ATTRIBUTE2 in VARCHAR2 ,
  X_ATTRIBUTE3 in VARCHAR2 ,
  X_ATTRIBUTE4 in VARCHAR2 ,
  X_ATTRIBUTE5 in VARCHAR2 ,
  X_ATTRIBUTE6 in VARCHAR2 ,
  X_ATTRIBUTE7 in VARCHAR2 ,
  X_ATTRIBUTE8 in VARCHAR2 ,
  X_ATTRIBUTE9 in VARCHAR2 ,
  X_ATTRIBUTE10 in VARCHAR2 ,
  X_ATTRIBUTE11 in VARCHAR2 ,
  X_ATTRIBUTE12 in VARCHAR2 ,
  X_ATTRIBUTE13 in VARCHAR2 ,
  X_ATTRIBUTE14 in VARCHAR2 ,
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor c is select
      MESSAGE_ID,
      MESSAGE_NUMBER,
      MESSAGE_TYPE,
      MESSAGE_NAME,
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
    from CS_FORUM_MESSAGES_B
    where MESSAGE_ID = X_MESSAGE_ID
    for update of MESSAGE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_FORUM_MESSAGES_TL
    where MESSAGE_ID = X_MESSAGE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of MESSAGE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (
          ((recinfo.MESSAGE_ID = X_MESSAGE_ID)
           OR ((recinfo.MESSAGE_ID is null) AND (X_MESSAGE_ID is null)))
      AND ((recinfo.MESSAGE_NUMBER = X_MESSAGE_NUMBER)
           OR ((recinfo.MESSAGE_NUMBER is null) AND (X_MESSAGE_NUMBER is null)))
      AND ((recinfo.MESSAGE_NAME = X_MESSAGE_NAME)
           OR ((recinfo.MESSAGE_NAME is null) AND (X_MESSAGE_NAME is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
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
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((
               dbms_lob.compare(X_DESCRIPTION, tlinfo.DESCRIPTION,
                                dbms_lob.getlength(X_DESCRIPTION),1,1)=0 )
               --tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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

procedure UPDATE_ROW (
  X_MESSAGE_ID in NUMBER,
  X_MESSAGE_NUMBER in NUMBER,
  X_MESSAGE_TYPE in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_POSTED_DATE in DATE,
  X_POSTED_USER in NUMBER,
  X_DESCRIPTION in CLOB,
  X_ACTIVE_STATUS in VARCHAR2,
  X_DISTRIBUTION_TYPE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 ,
  X_ATTRIBUTE1 in VARCHAR2 ,
  X_ATTRIBUTE2 in VARCHAR2 ,
  X_ATTRIBUTE3 in VARCHAR2 ,
  X_ATTRIBUTE4 in VARCHAR2 ,
  X_ATTRIBUTE5 in VARCHAR2 ,
  X_ATTRIBUTE6 in VARCHAR2 ,
  X_ATTRIBUTE7 in VARCHAR2 ,
  X_ATTRIBUTE8 in VARCHAR2 ,
  X_ATTRIBUTE9 in VARCHAR2 ,
  X_ATTRIBUTE10 in VARCHAR2 ,
  X_ATTRIBUTE11 in VARCHAR2 ,
  X_ATTRIBUTE12 in VARCHAR2 ,
  X_ATTRIBUTE13 in VARCHAR2 ,
  X_ATTRIBUTE14 in VARCHAR2 ,
  X_ATTRIBUTE15 in VARCHAR2
) is
begin
  update CS_FORUM_MESSAGES_B set
    MESSAGE_TYPE = X_MESSAGE_TYPE,
    MESSAGE_NAME = X_MESSAGE_NAME,
    POSTED_DATE = X_POSTED_DATE,
    POSTED_USER = X_POSTED_USER,
    ACTIVE_STATUS = X_ACTIVE_STATUS,
    DISTRIBUTION_TYPE = X_DISTRIBUTION_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
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
    ATTRIBUTE15 = X_ATTRIBUTE15
  where MESSAGE_ID = X_MESSAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_FORUM_MESSAGES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG'),
    COMPOSITE_ASSOC_COL  = 'b'  --UNISRCH
  where MESSAGE_ID = X_MESSAGE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MESSAGE_ID in NUMBER
) is
begin
  delete from CS_FORUM_MESSAGES_TL
  where MESSAGE_ID = X_MESSAGE_ID;

/*
  if (sql%notfound) then
    raise no_data_found;
  end if;
*/

  delete from CS_FORUM_MESSAGES_B
  where MESSAGE_ID = X_MESSAGE_ID;

/*
  if (sql%notfound) then
    raise no_data_found;
  end if;
*/
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_FORUM_MESSAGES_TL T
  where not exists
    (select NULL
    from CS_FORUM_MESSAGES_B B
    where B.MESSAGE_ID = T.MESSAGE_ID
    );

  update CS_FORUM_MESSAGES_TL T set (
      NAME,
      DESCRIPTION,
      COMPOSITE_ASSOC_COL   --UNISRCH
    ) = (select
      B.NAME,
      B.DESCRIPTION,
      'a'
    from CS_FORUM_MESSAGES_TL B
    where B.MESSAGE_ID = T.MESSAGE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MESSAGE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MESSAGE_ID,
      SUBT.LANGUAGE
    from CS_FORUM_MESSAGES_TL SUBB, CS_FORUM_MESSAGES_TL SUBT
    where SUBB.MESSAGE_ID = SUBT.MESSAGE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or --SUBB.DESCRIPTION <> SUBT.DESCRIPTION
           dbms_lob.compare(SUBB.DESCRIPTION, SUBT.DESCRIPTION,
                    dbms_lob.getlength(SUBB.DESCRIPTION), 1, 1) <> 0
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_FORUM_MESSAGES_TL (
    MESSAGE_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    COMPOSITE_ASSOC_COL   --UNISRCH
  ) select
    B.MESSAGE_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    'a'
  from CS_FORUM_MESSAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_FORUM_MESSAGES_TL T
    where T.MESSAGE_ID = B.MESSAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW(
        X_MESSAGE_ID in number,
        x_name in varchar2,
        x_description in varchar2,
        x_owner in varchar2
        )
is
begin
    update cs_forum_messages_tl set
        description = x_description,
        name = x_name,
        LAST_UPDATE_DATE = sysdate,
        LAST_UPDATED_BY = decode(x_owner, 'SEED', 1, 0),
        LAST_UPDATE_LOGIN = 0,
        SOURCE_LANG = userenv('LANG'),
        COMPOSITE_ASSOC_COL  = 'b'  --UNISRCH
        where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
           and MESSAGE_ID = X_MESSAGE_ID;
end TRANSLATE_ROW;



procedure LOAD_ROW (
  X_MESSAGE_ID in NUMBER,
  X_MESSAGE_NUMBER in NUMBER,
  X_MESSAGE_TYPE in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_POSTED_DATE in DATE,
  X_POSTED_USER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ACTIVE_STATUS in VARCHAR2,
  X_DISTRIBUTION_TYPE in VARCHAR2,
  x_owner in varchar2

) is
    l_user_id number;
    l_clob CLOB := null;
    l_offset number;
    l_amt    number;

begin
    if (x_owner = 'SEED') then
           l_user_id := 1;
    else
           l_user_id := 0;
    end if;

    if( X_DESCRIPTION is not null)  then

     dbms_lob.createtemporary(l_clob, TRUE, DBMS_LOB.SESSION);
     l_offset := 1;
     l_amt := length(x_description);
     dbms_lob.write(l_clob, l_amt, l_offset, x_description);

     end if;

    CS_FORUM_MESSAGES_PKG.Update_Row(
            X_MESSAGE_ID => X_MESSAGE_ID,
            X_MESSAGE_NUMBER => X_MESSAGE_NUMBER,
            X_MESSAGE_TYPE => X_MESSAGE_TYPE,
            X_MESSAGE_NAME => X_MESSAGE_NAME,
            X_NAME => X_NAME,
            X_POSTED_DATE => X_POSTED_DATE,
            X_POSTED_USER => X_POSTED_USER,
            X_DESCRIPTION => l_clob,
            X_ACTIVE_STATUS => X_ACTIVE_STATUS,
            X_DISTRIBUTION_TYPE => X_DISTRIBUTION_TYPE,
    		X_Creation_Date => sysdate,
    		X_Created_By => l_user_id,
    		X_Last_Update_Date => sysdate,
    		X_Last_Updated_By => l_user_id,
    		X_Last_Update_Login => 0);

     exception
      when no_data_found then
        	CS_FORUM_MESSAGES_PKG.Insert_Row(
            X_MESSAGE_ID => X_MESSAGE_ID,
            X_MESSAGE_NUMBER => X_MESSAGE_NUMBER,
            X_MESSAGE_TYPE => X_MESSAGE_TYPE,
            X_MESSAGE_NAME => X_MESSAGE_NAME,
            X_NAME => X_NAME,
            X_POSTED_DATE => X_POSTED_DATE,
            X_POSTED_USER => X_POSTED_USER,
            X_DESCRIPTION => l_clob,
            X_ACTIVE_STATUS => X_ACTIVE_STATUS,
            X_DISTRIBUTION_TYPE => X_DISTRIBUTION_TYPE,
    		X_Creation_Date => sysdate,
    		X_Created_By => l_user_id,
    		X_Last_Update_Date => sysdate,
    		X_Last_Updated_By => l_user_id,
    		X_Last_Update_Login => 0);


    if(x_description is not null) then
       dbms_lob.freetemporary(l_clob);
    end if;

end LOAD_ROW;

end CS_FORUM_MESSAGES_PKG;

/
