--------------------------------------------------------
--  DDL for Package Body FND_LOOKUP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOOKUP_TYPES_PKG" as
/* $Header: AFLVMLTB.pls 120.2 2007/10/05 18:49:52 dggriffi ship $ */


X_LANG VARCHAR2(2);

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_LOOKUP_TYPES
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
    and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
    ;


begin
  insert into FND_LOOKUP_TYPES (
    APPLICATION_ID,
    LOOKUP_TYPE,
    CUSTOMIZATION_LEVEL,
    SECURITY_GROUP_ID,
    VIEW_APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_LOOKUP_TYPE,
    X_CUSTOMIZATION_LEVEL,
    X_SECURITY_GROUP_ID,
    X_VIEW_APPLICATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_LOOKUP_TYPES_TL (
    LOOKUP_TYPE,
    SECURITY_GROUP_ID,
    VIEW_APPLICATION_ID,
    MEANING,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LOOKUP_TYPE,
    X_SECURITY_GROUP_ID,
    X_VIEW_APPLICATION_ID,
    X_MEANING,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_LOOKUP_TYPES_TL T
    where T.LOOKUP_TYPE = X_LOOKUP_TYPE
    and T.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
    and T.VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;


  begin


  -- Calling WF_EVENT.RAISE per bug 3209508
  -- Business Events need to be raised with any insert to the fnd lookups
  -- Bug:6113227, added Lang Code parameter to key being used to raise the
  -- workflow event.

  select userenv('LANG')
  into X_LANG
  from dual;

  wf_event.raise(p_event_name => 'oracle.apps.fnd.lookup.type.insert',
                 p_event_key => X_LOOKUP_TYPE||':'||X_VIEW_APPLICATION_ID||
                                ':'||X_SECURITY_GROUP_ID||':'||X_LANG,
                 p_event_data => NULL,
                 p_parameters => NULL,
                 p_send_date => Sysdate);
  exception
    when others then
      null;
  end;

end INSERT_ROW;

/* Overloaded */
procedure TRANSLATE_ROW (
  X_LOOKUP_TYPE         in VARCHAR2,
  X_SECURITY_GROUP_ID   in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_OWNER               in VARCHAR2,
  X_MEANING             in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2) is
begin
  TRANSLATE_ROW (
    X_LOOKUP_TYPE         => X_LOOKUP_TYPE,
    X_SECURITY_GROUP_ID   => X_SECURITY_GROUP_ID,
    X_VIEW_APPLICATION_ID => X_VIEW_APPLICATION_ID,
    X_OWNER               => X_OWNER,
    X_MEANING             => X_MEANING,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_LAST_UPDATE_DATE    => null,
    X_CUSTOM_MODE         => null);
end TRANSLATE_ROW;

/* Overloaded */
procedure TRANSLATE_ROW (
  X_LOOKUP_TYPE         in VARCHAR2,
  X_SECURITY_GROUP_ID   in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_OWNER               in VARCHAR2,
  X_MEANING             in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2)
is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from fnd_lookup_types_tl
  where lookup_type       = X_LOOKUP_TYPE
  and security_group_id   = X_SECURITY_GROUP_ID
  and view_application_id = X_VIEW_APPLICATION_ID
  and language            = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update fnd_lookup_types_tl set
      meaning           = nvl(X_MEANING, meaning),
      description       = nvl(X_DESCRIPTION, description),
      last_update_date  = f_ludate,
      last_updated_by   = f_luby,
      last_update_login = 0,
      source_lang       = userenv('LANG')
    where lookup_type       = X_LOOKUP_TYPE
    and security_group_id   = X_SECURITY_GROUP_ID
    and view_application_id = X_VIEW_APPLICATION_ID
    and userenv('LANG') in (language, source_lang);

    begin
    -- Calling WF_EVENT.RAISE per bug 3209508
    -- Business Events need to be raised with any updates to the fnd lookups
    -- Bug:6113227, added Lang Code parameter to key being used to raise the
    -- workflow event.

    select userenv('LANG')
    into X_LANG
    from dual;

    wf_event.raise(p_event_name => 'oracle.apps.fnd.lookup.type.update',
                   p_event_key => X_LOOKUP_TYPE||':'||X_VIEW_APPLICATION_ID||
                                  ':'||X_SECURITY_GROUP_ID||':'||X_LANG,
                   p_event_data => NULL,
                   p_parameters => NULL,
                   p_send_date => Sysdate);
    exception
      when others then
        null;
    end;

  end if;
end TRANSLATE_ROW;

procedure LOCK_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      APPLICATION_ID,
      CUSTOMIZATION_LEVEL
    from FND_LOOKUP_TYPES
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
    and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
    for update of LOOKUP_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_LOOKUP_TYPES_TL
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
    and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LOOKUP_TYPE nowait;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MEANING = X_MEANING)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_LOOKUP_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is


begin
  update FND_LOOKUP_TYPES set
    APPLICATION_ID = X_APPLICATION_ID,
    CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
  and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_LOOKUP_TYPES_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
  and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

  begin
  -- Calling WF_EVENT.RAISE per bug 3209508
  -- Business Events need to be raised with any updates to the fnd lookups
  -- Bug:6113227, added Lang Code parameter to key being used to raise the
  -- workflow event.
  select userenv('LANG')
  into X_LANG
  from dual;

  wf_event.raise(p_event_name => 'oracle.apps.fnd.lookup.type.update',
                 p_event_key => X_LOOKUP_TYPE||':'||X_VIEW_APPLICATION_ID||
                                ':'||X_SECURITY_GROUP_ID||':'||X_LANG,
                 p_event_data => NULL,
                 p_parameters => NULL,
                 p_send_date => Sysdate);
  exception
    when others then
      null;
  end;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER
) is
begin
  delete from FND_LOOKUP_TYPES_TL
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
  and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_LOOKUP_TYPES
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
  and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  begin
  -- Calling WF_EVENT.RAISE per bug 3209508
  -- Business Events need to be raised with any insert to the fnd lookups
  -- Bug:6113227, added Lang Code parameter to key being used to raise the
  -- workflow event.

  select userenv('LANG')
  into X_LANG
  from dual;

  wf_event.raise(p_event_name => 'oracle.apps.fnd.lookup.type.delete',
                 p_event_key => X_LOOKUP_TYPE||':'||X_VIEW_APPLICATION_ID||
                                ':'||X_SECURITY_GROUP_ID||':'||X_LANG,
                 p_event_data => NULL,
                 p_parameters => NULL,
                 p_send_date => Sysdate);
  exception
    when others then
      null;
  end;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_LOOKUP_TYPES_TL T
  where not exists
    (select NULL
    from FND_LOOKUP_TYPES B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.SECURITY_GROUP_ID = T.SECURITY_GROUP_ID
    and B.VIEW_APPLICATION_ID = T.VIEW_APPLICATION_ID
    );

  update FND_LOOKUP_TYPES_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from FND_LOOKUP_TYPES_TL B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.SECURITY_GROUP_ID = T.SECURITY_GROUP_ID
    and B.VIEW_APPLICATION_ID = T.VIEW_APPLICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOOKUP_TYPE,
      T.SECURITY_GROUP_ID,
      T.VIEW_APPLICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LOOKUP_TYPE,
      SUBT.SECURITY_GROUP_ID,
      SUBT.VIEW_APPLICATION_ID,
      SUBT.LANGUAGE
    from FND_LOOKUP_TYPES_TL SUBB, FND_LOOKUP_TYPES_TL SUBT
    where SUBB.LOOKUP_TYPE = SUBT.LOOKUP_TYPE
    and SUBB.SECURITY_GROUP_ID = SUBT.SECURITY_GROUP_ID
    and SUBB.VIEW_APPLICATION_ID = SUBT.VIEW_APPLICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ))
  -- ***** BEGIN NEW CLAUSE FOR UPDATE *****
  and not exists
    (select null
    from FND_LOOKUP_TYPES_TL DUP
    where DUP.VIEW_APPLICATION_ID = T.VIEW_APPLICATION_ID
    and DUP.SECURITY_GROUP_ID = T.SECURITY_GROUP_ID
    and DUP.LANGUAGE = T.LANGUAGE
    and (DUP.MEANING) =
      (select
         B.MEANING
       from FND_LOOKUP_TYPES_TL B
       where B.LOOKUP_TYPE = T.LOOKUP_TYPE
       and B.SECURITY_GROUP_ID = T.SECURITY_GROUP_ID
       and B.VIEW_APPLICATION_ID = T.VIEW_APPLICATION_ID
       and B.LANGUAGE = T.SOURCE_LANG));
  -- ***** END NEW CLAUSE FOR UPDATE *****

  -- ***** NEW CODE FOR INSERT HERE *****
  loop
    update FND_LOOKUP_TYPES_TL set
      MEANING = '@'||MEANING
    where (
         MEANING,
         VIEW_APPLICATION_ID,
         SECURITY_GROUP_ID,
         LANGUAGE) in
      (select
         B.MEANING,
         B.VIEW_APPLICATION_ID,
         B.SECURITY_GROUP_ID,
         L.LANGUAGE_CODE
       from FND_LOOKUP_TYPES_TL B, FND_LANGUAGES L
       where L.INSTALLED_FLAG in ('I', 'B')
       and B.LANGUAGE = userenv('LANG')
       and not exists
         (select NULL
         from FND_LOOKUP_TYPES_TL T
         where T.LOOKUP_TYPE = B.LOOKUP_TYPE
         and T.SECURITY_GROUP_ID = B.SECURITY_GROUP_ID
         and T.VIEW_APPLICATION_ID = B.VIEW_APPLICATION_ID
         and T.LANGUAGE = L.LANGUAGE_CODE));

     exit when SQL%ROWCOUNT = 0;
   end loop;
  -- ***** END CODE FOR INSERT HERE *****
*/

  insert into FND_LOOKUP_TYPES_TL (
    LOOKUP_TYPE,
    SECURITY_GROUP_ID,
    VIEW_APPLICATION_ID,
    MEANING,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LOOKUP_TYPE,
    B.SECURITY_GROUP_ID,
    B.VIEW_APPLICATION_ID,
    B.MEANING,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_LOOKUP_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_LOOKUP_TYPES_TL T
    where T.LOOKUP_TYPE = B.LOOKUP_TYPE
    and T.SECURITY_GROUP_ID = B.SECURITY_GROUP_ID
    and T.VIEW_APPLICATION_ID = B.VIEW_APPLICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_VIEW_APPSNAME               IN VARCHAR2,
  X_LOOKUP_TYPE 		IN VARCHAR2,
  X_APPLICATION_SHORT_NAME      IN VARCHAR2,
  X_CUSTOMIZATION_LEVEL         IN VARCHAR2,
  X_OWNER                       IN VARCHAR2,
  X_LAST_UPDATE_DATE            IN VARCHAR2,
  X_MEANING                     IN VARCHAR2,
  X_DESCRIPTION                 IN VARCHAR2,
  X_SECURITY_GROUP              IN VARCHAR2,
  X_CUSTOM_MODE                 IN VARCHAR2)
is
  secgrp_id number;
  view_appid number;
  owner_appid number;
  row_id varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

  cursor secgrp_curs is
    select SG.SECURITY_GROUP_ID
    from FND_LOOKUP_TYPES LT, FND_SECURITY_GROUPS SG
    where LT.LOOKUP_TYPE = x_lookup_type
    and LT.VIEW_APPLICATION_ID = view_appid
    and LT.SECURITY_GROUP_ID = SG.SECURITY_GROUP_ID
    and SG.SECURITY_GROUP_KEY like nvl(x_security_group, 'STANDARD');

begin

  select APPLICATION_ID
  into view_appid
  from FND_APPLICATION
  where APPLICATION_SHORT_NAME = x_view_appsname;

  select APPLICATION_ID
  into owner_appid
  from FND_APPLICATION
  where APPLICATION_SHORT_NAME = x_application_short_name;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  open secgrp_curs;
  fetch secgrp_curs into secgrp_id;

  if (secgrp_curs%notfound) then
    -- No matching rows in any security group.
    -- Insert a single row in requested security group
    select SECURITY_GROUP_ID
    into secgrp_id
    from FND_SECURITY_GROUPS
    where SECURITY_GROUP_KEY = nvl(x_security_group, 'STANDARD');

    Fnd_Lookup_Types_Pkg.Insert_Row(
      x_rowid               => row_id,
      x_lookup_type         => x_lookup_type,
      x_security_group_id   => secgrp_id,
      x_view_application_id => view_appid,
      x_application_id      => owner_appid,
      x_customization_level => x_customization_level,
      x_meaning             => x_meaning,
      x_description         => x_description,
      x_creation_date       => f_ludate,
      x_created_by          => f_luby,
      x_last_update_date    => f_ludate,
      x_last_updated_by     => f_luby,
      x_last_update_login   => 0);
  else
    loop
      select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      from FND_LOOKUP_TYPES_VL
      where LOOKUP_TYPE = x_lookup_type
      and SECURITY_GROUP_ID = secgrp_id
      and VIEW_APPLICATION_ID = view_appid;

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                    db_ludate, X_CUSTOM_MODE)) then
        -- Update row in all matching security groups.
        Fnd_Lookup_Types_Pkg.Update_Row(
          x_lookup_type         => x_lookup_type,
          x_security_group_id   => secgrp_id,
          x_view_application_id => view_appid,
          x_application_id      => owner_appid,
          x_customization_level => x_customization_level,
          x_meaning             => x_meaning,
          x_description         => x_description,
          x_last_update_date    => f_ludate,
          x_last_updated_by     => f_luby,
          x_last_update_login   => 0);
      end if;

      fetch secgrp_curs into secgrp_id;
      exit when secgrp_curs%notfound;
    end loop;
  end if;

  close secgrp_curs;

end LOAD_ROW;

end FND_LOOKUP_TYPES_PKG;

/
