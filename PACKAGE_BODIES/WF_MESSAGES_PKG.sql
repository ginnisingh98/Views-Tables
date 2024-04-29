--------------------------------------------------------
--  DDL for Package Body WF_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_MESSAGES_PKG" as
/* $Header: wfmsgb.pls 120.1 2005/07/02 02:48:16 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_BODY in VARCHAR2,
  X_HTML_BODY in VARCHAR2
) is
  cursor C is select ROWID from WF_MESSAGES
    where TYPE = X_TYPE
    and NAME = X_NAME
    ;
begin
  insert into WF_MESSAGES (
    TYPE,
    NAME,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DEFAULT_PRIORITY,
    READ_ROLE,
    WRITE_ROLE
  ) values (
    X_TYPE,
    X_NAME,
    X_PROTECT_LEVEL,
    X_CUSTOM_LEVEL,
    X_DEFAULT_PRIORITY,
    X_READ_ROLE,
    X_WRITE_ROLE
  );

  insert into WF_MESSAGES_TL (
    TYPE,
    NAME,
    DISPLAY_NAME,
    SUBJECT,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    BODY,
    HTML_BODY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TYPE,
    X_NAME,
    X_DISPLAY_NAME,
    X_SUBJECT,
    X_PROTECT_LEVEL,
    X_CUSTOM_LEVEL,
    X_DESCRIPTION,
    X_BODY,
    X_HTML_BODY,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and not exists
    (select NULL
    from WF_MESSAGES_TL T
    where T.TYPE = X_TYPE
    and T.NAME = X_NAME
    and T.LANGUAGE = L.CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

exception
  when others then
    wf_core.context('Wf_Messages_Pkg', 'Insert_Row', x_type, x_name);
    raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_BODY in VARCHAR2,
  X_HTML_BODY in VARCHAR2
) is
  cursor c is select
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      DEFAULT_PRIORITY,
      READ_ROLE,
      WRITE_ROLE
    from WF_MESSAGES
    where TYPE = X_TYPE
    and NAME = X_NAME
    for update of TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      SUBJECT,
      BODY,
      HTML_BODY
    from WF_MESSAGES_TL
    where TYPE = X_TYPE
    and NAME = X_NAME
    and LANGUAGE = userenv('LANG')
    for update of TYPE nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c;
  if (    (recinfo.PROTECT_LEVEL = X_PROTECT_LEVEL)
      AND (recinfo.CUSTOM_LEVEL = X_CUSTOM_LEVEL)
      AND ((recinfo.DEFAULT_PRIORITY = X_DEFAULT_PRIORITY)
           OR ((recinfo.DEFAULT_PRIORITY is null) AND (X_DEFAULT_PRIORITY is null)))
      AND ((recinfo.READ_ROLE = X_READ_ROLE)
           OR ((recinfo.READ_ROLE is null) AND (X_READ_ROLE is null)))
      AND ((recinfo.WRITE_ROLE = X_WRITE_ROLE)
           OR ((recinfo.WRITE_ROLE is null) AND (X_WRITE_ROLE is null)))
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      AND (tlinfo.SUBJECT = X_SUBJECT)
      AND ((tlinfo.BODY = X_BODY)
           OR ((tlinfo.BODY is null) AND (X_BODY is null)))
      AND ((tlinfo.HTML_BODY = X_HTML_BODY)
           OR ((tlinfo.HTML_BODY is null) AND (X_HTML_BODY is null)))
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;
  return;

exception
  when others then
    wf_core.context('Wf_Messages_Pkg', 'Lock_Row', x_type, x_name);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_BODY in VARCHAR2,
  X_HTML_BODY in VARCHAR2
) is
begin
  update WF_MESSAGES set
    PROTECT_LEVEL = X_PROTECT_LEVEL,
    CUSTOM_LEVEL = X_CUSTOM_LEVEL,
    DEFAULT_PRIORITY = X_DEFAULT_PRIORITY,
    READ_ROLE = X_READ_ROLE,
    WRITE_ROLE = X_WRITE_ROLE
  where TYPE = X_TYPE
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WF_MESSAGES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    SUBJECT = X_SUBJECT,
    BODY = X_BODY,
    HTML_BODY = X_HTML_BODY,
    SOURCE_LANG = userenv('LANG')
  where TYPE = X_TYPE
  and NAME = X_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Messages_Pkg', 'Update_Row', x_type, x_name);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2
) is
begin
  delete from WF_MESSAGES_TL
  where TYPE = X_TYPE
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WF_MESSAGES
  where TYPE = X_TYPE
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Messages_Pkg', 'Delete_Row', x_type, x_name);
    raise;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from WF_MESSAGES_TL T
  where not exists
    (select NULL
    from WF_MESSAGES B
    where B.TYPE = T.TYPE
    and B.NAME = T.NAME
    );

  update WF_MESSAGES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION,
      SUBJECT,
      BODY,
      HTML_BODY
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION,
      B.SUBJECT,
      B.BODY,
      B.HTML_BODY
    from WF_MESSAGES_TL B
    where B.TYPE = T.TYPE
    and B.NAME = T.NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TYPE,
      T.NAME,
      T.LANGUAGE
  ) in (select
      SUBT.TYPE,
      SUBT.NAME,
      SUBT.LANGUAGE
    from WF_MESSAGES_TL SUBB, WF_MESSAGES_TL SUBT
    where SUBB.TYPE = SUBT.TYPE
    and SUBB.NAME = SUBT.NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.SUBJECT <> SUBT.SUBJECT
      or SUBB.BODY <> SUBT.BODY
      or (SUBB.BODY is null and SUBT.BODY is not null)
      or (SUBB.BODY is not null and SUBT.BODY is null)
      or SUBB.HTML_BODY <> SUBT.HTML_BODY
      or (SUBB.HTML_BODY is null and SUBT.HTML_BODY is not null)
      or (SUBB.HTML_BODY is not null and SUBT.HTML_BODY is null)
  ));
*/

  insert into WF_MESSAGES_TL (
    TYPE,
    NAME,
    DISPLAY_NAME,
    SUBJECT,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    BODY,
    HTML_BODY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TYPE,
    B.NAME,
    B.DISPLAY_NAME,
    B.SUBJECT,
    B.PROTECT_LEVEL,
    B.CUSTOM_LEVEL,
    B.DESCRIPTION,
    B.BODY,
    B.HTML_BODY,
    L.CODE,
    B.SOURCE_LANG
  from WF_MESSAGES_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and (B.TYPE,B.NAME ,L.CODE ) NOT IN
    (select  /*+ hash_aj index_ffs(T,WF_MESSAGES_TL_PK) */
       T.TYPE ,T.NAME ,T.LANGUAGE
            from  WF_MESSAGES_TL T);

end ADD_LANGUAGE;

end WF_MESSAGES_PKG;

/
