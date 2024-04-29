--------------------------------------------------------
--  DDL for Package Body FND_LOOKUP_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOOKUP_VALUES_PKG" as
/* $Header: AFLVMLUB.pls 120.2 2007/10/09 15:14:49 dggriffi ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER default NULL,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_LOOKUP_CODE in VARCHAR2,
  X_TAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TERRITORY_CODE in VARCHAR2,
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
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  sgid NUMBER;
  X_LANG VARCHAR2(2);

  cursor C is select ROWID from FND_LOOKUP_VALUES
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and SECURITY_GROUP_ID = sgid
    and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
    and LOOKUP_CODE = X_LOOKUP_CODE
    and LANGUAGE = userenv('LANG');
begin
  -- Bug 2103124
  if (X_SECURITY_GROUP_ID is NULL) then
    sgid := FND_GLOBAL.SECURITY_GROUP_ID;
  else
    sgid := X_SECURITY_GROUP_ID;
  end if;

  insert into FND_LOOKUP_VALUES (
    TAG,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    LOOKUP_TYPE,
    LOOKUP_CODE,
    MEANING,
    DESCRIPTION,
    ENABLED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    SECURITY_GROUP_ID,
    VIEW_APPLICATION_ID,
    TERRITORY_CODE,
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
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TAG,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_LOOKUP_TYPE,
    X_LOOKUP_CODE,
    X_MEANING,
    X_DESCRIPTION,
    X_ENABLED_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    sgid,
    X_VIEW_APPLICATION_ID,
    X_TERRITORY_CODE,
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
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_LOOKUP_VALUES T
    where T.LOOKUP_TYPE = X_LOOKUP_TYPE
    and T.SECURITY_GROUP_ID = sgid
    and T.VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
    and T.LOOKUP_CODE = X_LOOKUP_CODE
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
  -- Business Events need to be raised with any updates to the fnd lookups
  -- Bug:6113227, added Lang Code parameter to key being used to raise the
  -- workflow event.

  select userenv('LANG')
  into X_LANG
  from dual;

  wf_event.raise(p_event_name => 'oracle.apps.fnd.lookup.code.insert',
                 p_event_key => X_LOOKUP_TYPE||':'||X_VIEW_APPLICATION_ID||
                 ':'||X_SECURITY_GROUP_ID||':'||X_LANG||':'||X_LOOKUP_CODE,
                 p_event_data => NULL,
                 p_parameters => NULL,
                 p_send_date => Sysdate);
  exception
    when others then
      null;
  end;
end INSERT_ROW;

procedure LOCK_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER default NULL,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_LOOKUP_CODE in VARCHAR2,
  X_TAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TERRITORY_CODE in VARCHAR2,
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
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  sgid NUMBER;
  cursor c1 is select
      TAG,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ENABLED_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      TERRITORY_CODE,
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
      MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_LOOKUP_VALUES
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and SECURITY_GROUP_ID = sgid
    and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
    and LOOKUP_CODE = X_LOOKUP_CODE
    for update of LOOKUP_TYPE nowait;

begin
  -- Bug 2103124
  if (X_SECURITY_GROUP_ID is NULL) then
    sgid := FND_GLOBAL.SECURITY_GROUP_ID;
  else
    sgid := X_SECURITY_GROUP_ID;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MEANING = X_MEANING)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.TAG = X_TAG)
               OR ((tlinfo.TAG is null) AND (X_TAG is null)))
          AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
          AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
          AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
          AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
          AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
          AND (tlinfo.ENABLED_FLAG = X_ENABLED_FLAG)
          AND ((tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
               OR ((tlinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
          AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((tlinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
          AND ((tlinfo.TERRITORY_CODE = X_TERRITORY_CODE)
               OR ((tlinfo.TERRITORY_CODE is null) AND (X_TERRITORY_CODE is null)))
          AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
          AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
               OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
          AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
          AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
          AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
          AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
               OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
          AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
               OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
          AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
               OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
          AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
               OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
          AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
               OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
          AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
               OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
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
  X_SECURITY_GROUP_ID in NUMBER default NULL,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_LOOKUP_CODE in VARCHAR2,
  X_TAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TERRITORY_CODE in VARCHAR2,
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
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  sgid NUMBER;
  X_LANG VARCHAR2(2);

begin
  -- Bug 2103124
  if (X_SECURITY_GROUP_ID is NULL) then
    sgid := FND_GLOBAL.SECURITY_GROUP_ID;
  else
    sgid := X_SECURITY_GROUP_ID;
  end if;

  -- Update "non-translated" values in all languages
  update FND_LOOKUP_VALUES set
    TAG = X_TAG,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ENABLED_FLAG = X_ENABLED_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    TERRITORY_CODE = X_TERRITORY_CODE,
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
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and SECURITY_GROUP_ID = sgid
  and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
  and LOOKUP_CODE = X_LOOKUP_CODE;

  -- Update "translated" values in current language
  update FND_LOOKUP_VALUES set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    SOURCE_LANG = userenv('LANG')
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and SECURITY_GROUP_ID = sgid
  and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
  and LOOKUP_CODE = X_LOOKUP_CODE
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

  wf_event.raise(p_event_name => 'oracle.apps.fnd.lookup.code.update',
                 p_event_key => X_LOOKUP_TYPE||':'||X_VIEW_APPLICATION_ID||
                 ':'||X_SECURITY_GROUP_ID||':'||X_LANG||':'||X_LOOKUP_CODE,
                 p_event_data => NULL,
                 p_parameters => NULL,
                 p_send_date => Sysdate);
  exception
    when others then
      null;
  end;
end UPDATE_ROW;

/* Overloaded */
procedure TRANSLATE_ROW (
  X_LOOKUP_TYPE         in VARCHAR2,
  X_SECURITY_GROUP_ID   in NUMBER default NULL,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_OWNER               in VARCHAR2,
  X_MEANING             in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_LOOKUP_CODE         in VARCHAR2
) is
begin
  TRANSLATE_ROW (
    X_LOOKUP_TYPE         => X_LOOKUP_TYPE,
    X_SECURITY_GROUP_ID   => X_SECURITY_GROUP_ID,
    X_VIEW_APPLICATION_ID => X_VIEW_APPLICATION_ID,
    X_OWNER               => X_OWNER,
    X_MEANING             => X_MEANING,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_LOOKUP_CODE         => X_LOOKUP_CODE,
    X_LAST_UPDATE_DATE    => null,
    X_CUSTOM_MODE         => null);
end TRANSLATE_ROW;

/* Overloaded */
procedure TRANSLATE_ROW (
  X_LOOKUP_TYPE         in VARCHAR2,
  X_SECURITY_GROUP_ID   in NUMBER default NULL,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_OWNER               in VARCHAR2,
  X_MEANING             in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_LOOKUP_CODE         in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2
) is
  sgid      NUMBER;  -- security group id, added for Bug 2103124
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  X_LANG VARCHAR2(2); -- LANG CODE for Cache Key parameter

begin
  -- Bug 2103124
  if (X_SECURITY_GROUP_ID is NULL) then
    sgid := FND_GLOBAL.SECURITY_GROUP_ID;
  else
    sgid := X_SECURITY_GROUP_ID;
  end if;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from fnd_lookup_values
  where LOOKUP_TYPE       = X_LOOKUP_TYPE
  and SECURITY_GROUP_ID   = sgid
  and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
  and LOOKUP_CODE         = X_LOOKUP_CODE
  and LANGUAGE            = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update FND_LOOKUP_VALUES set
      MEANING           = nvl(X_MEANING, meaning),
      DESCRIPTION       = nvl(X_DESCRIPTION, description),
      LAST_UPDATE_DATE  = f_ludate,
      LAST_UPDATED_BY   = f_luby,
      LAST_UPDATE_LOGIN = 0,
      SOURCE_LANG       = userenv('LANG')
    where LOOKUP_TYPE       = X_LOOKUP_TYPE
    and SECURITY_GROUP_ID   = sgid
    and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
    and LOOKUP_CODE         = X_LOOKUP_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    begin
    -- Calling WF_EVENT.RAISE per bug 3209508
    -- Business Events need to be raised with any updates to the fnd lookups
    -- Bug:6113227, added Lang Code parameter to key being used to raise the
    -- workflow event.

    select userenv('LANG')
    into X_LANG
    from dual;

    wf_event.raise(p_event_name => 'oracle.apps.fnd.lookup.code.update',
                   p_event_key => X_LOOKUP_TYPE||':'||X_VIEW_APPLICATION_ID||
                   ':'||X_SECURITY_GROUP_ID||':'||X_LANG||':'||X_LOOKUP_CODE,
                   p_event_data => NULL,
                   p_parameters => NULL,
                   p_send_date => Sysdate);
    exception
      when others then
        null;
    end;

  end if;
exception
  when no_data_found then
    null;
end TRANSLATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER default NULL,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_LOOKUP_CODE in VARCHAR2
) is
  sgid NUMBER;
  X_LANG VARCHAR2(2);
begin
  -- Bug 2103124
  if (X_SECURITY_GROUP_ID is NULL) then
    sgid := FND_GLOBAL.SECURITY_GROUP_ID;
  else
    sgid := X_SECURITY_GROUP_ID;
  end if;

  delete from FND_LOOKUP_VALUES
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and SECURITY_GROUP_ID = sgid
  and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
  and LOOKUP_CODE = X_LOOKUP_CODE;

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

  wf_event.raise(p_event_name => 'oracle.apps.fnd.lookup.code.delete',
                 p_event_key => X_LOOKUP_TYPE||':'||X_VIEW_APPLICATION_ID||
                 ':'||X_SECURITY_GROUP_ID||':'||X_LANG||':'||X_LOOKUP_CODE,
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
/* The following update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  update FND_LOOKUP_VALUES T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from FND_LOOKUP_VALUES B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.SECURITY_GROUP_ID = T.SECURITY_GROUP_ID
    and B.VIEW_APPLICATION_ID = T.VIEW_APPLICATION_ID
    and B.LOOKUP_CODE = T.LOOKUP_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOOKUP_TYPE,
      T.SECURITY_GROUP_ID,
      T.VIEW_APPLICATION_ID,
      T.LOOKUP_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.LOOKUP_TYPE,
      SUBT.SECURITY_GROUP_ID,
      SUBT.VIEW_APPLICATION_ID,
      SUBT.LOOKUP_CODE,
      SUBT.LANGUAGE
    from FND_LOOKUP_VALUES SUBB, FND_LOOKUP_VALUES SUBT
    where SUBB.LOOKUP_TYPE = SUBT.LOOKUP_TYPE
    and SUBB.SECURITY_GROUP_ID = SUBT.SECURITY_GROUP_ID
    and SUBB.VIEW_APPLICATION_ID = SUBT.VIEW_APPLICATION_ID
    and SUBB.LOOKUP_CODE = SUBT.LOOKUP_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ))
  -- ***** BEGIN NEW CLAUSE FOR UPDATE *****
  and not exists
    (select null
    from FND_LOOKUP_VALUES DUP
    where DUP.LOOKUP_TYPE = T.LOOKUP_TYPE
    and DUP.VIEW_APPLICATION_ID = T.VIEW_APPLICATION_ID
    and DUP.SECURITY_GROUP_ID = T.SECURITY_GROUP_ID
    and DUP.LANGUAGE = T.LANGUAGE
    and (DUP.MEANING) =
      (select
         B.MEANING
       from FND_LOOKUP_VALUES B
       where B.LOOKUP_TYPE = T.LOOKUP_TYPE
       and B.SECURITY_GROUP_ID = T.SECURITY_GROUP_ID
       and B.VIEW_APPLICATION_ID = T.VIEW_APPLICATION_ID
       and B.LOOKUP_CODE = T.LOOKUP_CODE
       and B.LANGUAGE = T.SOURCE_LANG));
  -- ***** END NEW CLAUSE FOR UPDATE *****

  -- ***** NEW CODE FOR INSERT HERE *****
  loop
    update FND_LOOKUP_VALUES set
      MEANING = '@'||MEANING
    where (
         LOOKUP_TYPE,
         VIEW_APPLICATION_ID,
	 MEANING,
	 SECURITY_GROUP_ID,
         LANGUAGE) in
      (select
         B.LOOKUP_TYPE,
         B.VIEW_APPLICATION_ID,
	 B.MEANING,
	 B.SECURITY_GROUP_ID,
         L.LANGUAGE_CODE
       from FND_LOOKUP_VALUES B, FND_LANGUAGES L
       where L.INSTALLED_FLAG in ('I', 'B')
       and B.LANGUAGE = userenv('LANG')
       and not exists
         (select NULL
          from FND_LOOKUP_VALUES T
          where T.LOOKUP_TYPE = B.LOOKUP_TYPE
          and T.SECURITY_GROUP_ID = B.SECURITY_GROUP_ID
          and T.VIEW_APPLICATION_ID = B.VIEW_APPLICATION_ID
          and T.LOOKUP_CODE = B.LOOKUP_CODE
          and T.LANGUAGE = L.LANGUAGE_CODE));

     exit when SQL%ROWCOUNT = 0;
   end loop;
  -- ***** END CODE FOR INSERT HERE *****
*/

  insert into FND_LOOKUP_VALUES (
    TAG,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    LOOKUP_TYPE,
    LOOKUP_CODE,
    MEANING,
    DESCRIPTION,
    ENABLED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    SECURITY_GROUP_ID,
    VIEW_APPLICATION_ID,
    TERRITORY_CODE,
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
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TAG,
    B.ATTRIBUTE_CATEGORY,
    B.ATTRIBUTE1,
    B.ATTRIBUTE2,
    B.ATTRIBUTE3,
    B.ATTRIBUTE4,
    B.LOOKUP_TYPE,
    B.LOOKUP_CODE,
    B.MEANING,
    B.DESCRIPTION,
    B.ENABLED_FLAG,
    B.START_DATE_ACTIVE,
    B.END_DATE_ACTIVE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.SECURITY_GROUP_ID,
    B.VIEW_APPLICATION_ID,
    B.TERRITORY_CODE,
    B.ATTRIBUTE5,
    B.ATTRIBUTE6,
    B.ATTRIBUTE7,
    B.ATTRIBUTE8,
    B.ATTRIBUTE9,
    B.ATTRIBUTE10,
    B.ATTRIBUTE11,
    B.ATTRIBUTE12,
    B.ATTRIBUTE13,
    B.ATTRIBUTE14,
    B.ATTRIBUTE15,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_LOOKUP_VALUES B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_LOOKUP_VALUES T
    where T.LOOKUP_TYPE = B.LOOKUP_TYPE
    and T.SECURITY_GROUP_ID = B.SECURITY_GROUP_ID
    and T.VIEW_APPLICATION_ID = B.VIEW_APPLICATION_ID
    and T.LOOKUP_CODE = B.LOOKUP_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

procedure Load_Row (
  x_lookup_type           in varchar2,
  x_view_appsname         in varchar2,
  x_lookup_code           in varchar2,
  x_enabled_flag          in varchar2,
  x_start_date_active     in varchar2,
  x_end_date_active       in varchar2,
  x_territory_code        in varchar2,
  x_tag                   in varchar2,
  x_attribute_category    in varchar2,
  x_attribute1            in varchar2,
  x_attribute2            in varchar2,
  x_attribute3            in varchar2,
  x_attribute4            in varchar2,
  x_attribute5            in varchar2,
  x_attribute6            in varchar2,
  x_attribute7            in varchar2,
  x_attribute8            in varchar2,
  x_attribute9            in varchar2,
  x_attribute10           in varchar2,
  x_attribute11           in varchar2,
  x_attribute12           in varchar2,
  x_attribute13           in varchar2,
  x_attribute14           in varchar2,
  x_attribute15           in varchar2,
  x_last_update_date      in varchar2,
  x_owner                 in varchar2,
  x_meaning               in varchar2,
  x_description           in varchar2,
  x_security_group        in varchar2,
  x_custom_mode           in varchar2)
is
  view_appid number;
  user_id number;
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

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  for secgrp in secgrp_curs loop
    -- check the db last update fields for each record in the cursor
    begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from fnd_lookup_values_vl
    where LOOKUP_TYPE       = X_LOOKUP_TYPE
    and SECURITY_GROUP_ID   = secgrp.security_group_id
    and VIEW_APPLICATION_ID = view_appid
    and LOOKUP_CODE         = X_LOOKUP_CODE;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
      Fnd_Lookup_Values_Pkg.Update_Row (
        X_LOOKUP_TYPE           => x_lookup_type,
        X_SECURITY_GROUP_ID     => secgrp.security_group_id,
        X_VIEW_APPLICATION_ID   => view_appid,
        X_LOOKUP_CODE           => x_lookup_code,
        X_TAG                   => x_tag,
        X_ATTRIBUTE_CATEGORY    => x_attribute_category,
        X_ATTRIBUTE1            => x_attribute1,
        X_ATTRIBUTE2            => x_attribute2,
        X_ATTRIBUTE3            => x_attribute3,
        X_ATTRIBUTE4            => x_attribute4,
        X_ENABLED_FLAG          => x_enabled_flag,
        X_START_DATE_ACTIVE     => to_date(x_start_date_active,
                                            'YYYY/MM/DD'),
        X_END_DATE_ACTIVE       => to_date(x_end_date_active,
                                            'YYYY/MM/DD'),
        X_TERRITORY_CODE        => x_territory_code,
        X_ATTRIBUTE5            => x_attribute5,
        X_ATTRIBUTE6            => x_attribute6,
        X_ATTRIBUTE7            => x_attribute7,
        X_ATTRIBUTE8            => x_attribute8,
        X_ATTRIBUTE9            => x_attribute9,
        X_ATTRIBUTE10           => x_attribute10,
        X_ATTRIBUTE11           => x_attribute11,
        X_ATTRIBUTE12           => x_attribute12,
        X_ATTRIBUTE13           => x_attribute13,
        X_ATTRIBUTE14           => x_attribute14,
        X_ATTRIBUTE15           => x_attribute15,
        X_MEANING               => x_meaning,
        X_DESCRIPTION           => x_description,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0);
    end if;

    exception
      when no_data_found then
        Fnd_Lookup_Values_Pkg.Insert_Row(
          X_ROWID               => row_id,
          X_LOOKUP_TYPE         => x_lookup_type,
          X_SECURITY_GROUP_ID   => secgrp.security_group_id,
          X_VIEW_APPLICATION_ID => view_appid,
          X_LOOKUP_CODE         => x_lookup_code,
          X_TAG                 => x_tag,
          X_ATTRIBUTE_CATEGORY  => x_attribute_category,
          X_ATTRIBUTE1          => x_attribute1,
          X_ATTRIBUTE2          => x_attribute2,
          X_ATTRIBUTE3          => x_attribute3,
          X_ATTRIBUTE4          => x_attribute4,
          X_ENABLED_FLAG        => x_enabled_flag,
          X_START_DATE_ACTIVE   => to_date(x_start_date_active,
                                            'YYYY/MM/DD'),
          X_END_DATE_ACTIVE     => to_date(x_end_date_active,
                                            'YYYY/MM/DD'),
          X_TERRITORY_CODE      => x_territory_code,
          X_ATTRIBUTE5          => x_attribute5,
          X_ATTRIBUTE6          => x_attribute6,
          X_ATTRIBUTE7          => x_attribute7,
          X_ATTRIBUTE8          => x_attribute8,
          X_ATTRIBUTE9          => x_attribute9,
          X_ATTRIBUTE10         => x_attribute10,
          X_ATTRIBUTE11         => x_attribute11,
          X_ATTRIBUTE12         => x_attribute12,
          X_ATTRIBUTE13         => x_attribute13,
          X_ATTRIBUTE14         => x_attribute14,
          X_ATTRIBUTE15         => x_attribute15,
          X_MEANING             => x_meaning,
          X_DESCRIPTION         => x_description,
          X_CREATION_DATE       => f_ludate,
          X_CREATED_BY          => f_luby,
          X_LAST_UPDATE_DATE    => f_ludate,
          X_LAST_UPDATED_BY     => f_luby,
          X_LAST_UPDATE_LOGIN   => 0);
    end;
  end loop;

end Load_Row;

end FND_LOOKUP_VALUES_PKG;

/
