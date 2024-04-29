--------------------------------------------------------
--  DDL for Package Body PN_SET_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_SET_TYPES_PKG" As
  -- $Header: PNTSTTYB.pls 115.14 2004/04/09 21:49:07 ftanudja ship $

procedure INSERT_ROW (
                       X_ROWID             in out NOCOPY VARCHAR2,
                       X_SET_ID            in out NOCOPY NUMBER,
                       X_SET_NAME          in VARCHAR2,
                       X_DESCRIPTION       in VARCHAR2,
                       X_CREATION_DATE     in DATE,
                       X_CREATED_BY        in NUMBER,
                       X_LAST_UPDATE_DATE  in DATE,
                       X_LAST_UPDATED_BY   in NUMBER,
                       X_LAST_UPDATE_LOGIN in NUMBER
                     ) IS

  cursor C is
  select ROWID
  from   PN_SET_TYPES
  where  SET_ID   = X_SET_ID
  and    LANGUAGE = userenv('LANG');

begin

  IF X_SET_ID is null then

    select PN_SET_TYPES_s.nextval
    into   X_SET_ID
    from   dual;

  END IF;

  insert into PN_SET_TYPES (
                             SET_ID,
                             LAST_UPDATE_DATE,
                             LAST_UPDATED_BY,
                             CREATION_DATE,
                             CREATED_BY,
                             LAST_UPDATE_LOGIN,
                             SET_NAME,
                             DESCRIPTION,
                             LANGUAGE,
                             SOURCE_LANG
                           )
                     select
                             X_SET_ID,
                             X_LAST_UPDATE_DATE,
                             X_LAST_UPDATED_BY,
                             X_CREATION_DATE,
                             X_CREATED_BY,
                             X_LAST_UPDATE_LOGIN,
                             X_SET_NAME,
                             X_DESCRIPTION,
                             L.LANGUAGE_CODE,
                             userenv('LANG')
                     from    FND_LANGUAGES L
                     where   L.INSTALLED_FLAG in ('I', 'B')
                     and     not exists (
                                          select NULL
                                          from   PN_SET_TYPES T
                                          where  T.SET_ID   = X_SET_ID
                                          and    T.LANGUAGE = L.LANGUAGE_CODE
                                        );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW   (
                       X_SET_ID            in NUMBER,
                       X_SET_NAME          in VARCHAR2,
                       X_DESCRIPTION       in VARCHAR2
                     ) IS
  cursor c1 is
  select *
  from   PN_SET_TYPES
  where  SET_ID   = X_SET_ID
  and    LANGUAGE = userenv('LANG')
  for    update of SET_ID nowait;

  tlinfo c1%rowtype;

begin

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.SET_NAME = X_SET_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;

end LOCK_ROW;

procedure UPDATE_ROW (
                       X_SET_ID            in NUMBER,
                       X_SET_NAME          in VARCHAR2,
                       X_DESCRIPTION       in VARCHAR2,
                       X_LAST_UPDATE_DATE  in DATE,
                       X_LAST_UPDATED_BY   in NUMBER,
                       X_LAST_UPDATE_LOGIN in NUMBER
                     ) IS
begin

  update PN_SET_TYPES
  set
        SET_NAME          = X_SET_NAME,
        DESCRIPTION       = X_DESCRIPTION,
        LAST_UPDATE_DATE  = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY   = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        SOURCE_LANG       = userenv('LANG')
  where SET_ID            = X_SET_ID
  and   userenv('LANG')  in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
                       X_SET_ID in NUMBER
                     ) is
begin

  delete from PN_SET_TYPES
  where SET_ID = X_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

--------------------------------------------------------------------------
-- PROCEDURE: add_language
-- HISTORY
-- 08-APR-04 ftanudja o Replace userenv('lang') w/ b.source_lang. #3537691.
--------------------------------------------------------------------------

procedure ADD_LANGUAGE is
begin

  update PN_SET_TYPES T
  set (
        SET_NAME,
        DESCRIPTION
      ) = (
            select B.SET_NAME,
                   B.DESCRIPTION
            from   PN_SET_TYPES B
            where  B.SET_ID   = T.SET_ID
            and    B.LANGUAGE = T.SOURCE_LANG
          )
  where (
          T.SET_ID,
          T.LANGUAGE
        ) in (
               select SUBT.SET_ID,
                      SUBT.LANGUAGE
               from   PN_SET_TYPES SUBB,
                      PN_SET_TYPES SUBT
               where  SUBB.SET_ID = SUBT.SET_ID
               and SUBB.LANGUAGE  = SUBT.SOURCE_LANG
               and (SUBB.SET_NAME    <> SUBT.SET_NAME          or
                    SUBB.DESCRIPTION <> SUBT.DESCRIPTION       or
                    (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null) or
                    (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
                   )
             );

  insert into PN_SET_TYPES (
                             SET_ID,
                             LAST_UPDATE_DATE,
                             LAST_UPDATED_BY,
                             CREATION_DATE,
                             CREATED_BY,
                             LAST_UPDATE_LOGIN,
                             SET_NAME,
                             DESCRIPTION,
                             LANGUAGE,
                             SOURCE_LANG
                           )
                    select
                             B.SET_ID,
                             B.LAST_UPDATE_DATE,
                             B.LAST_UPDATED_BY,
                             B.CREATION_DATE,
                             B.CREATED_BY,
                             B.LAST_UPDATE_LOGIN,
                             B.SET_NAME,
                             B.DESCRIPTION,
                             L.LANGUAGE_CODE,
                             B.SOURCE_LANG
                    from     PN_SET_TYPES   B,
                             FND_LANGUAGES  L
                    where    L.INSTALLED_FLAG in ('I', 'B')
                    and      B.LANGUAGE        = userenv('LANG')
                    and      not exists        (
                                                 select NULL
                                                 from   PN_SET_TYPES T
                                                 where  T.SET_ID   = B.SET_ID
                                                 and    T.LANGUAGE = L.LANGUAGE_CODE
                                               );
end ADD_LANGUAGE;

end PN_SET_TYPES_PKG;

/
