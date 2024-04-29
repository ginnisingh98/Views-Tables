--------------------------------------------------------
--  DDL for Package Body HR_NAVIGATION_PATHS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NAVIGATION_PATHS_PKG" as
/* $Header: hrnvplct.pkb 120.0 2005/05/31 01:37:32 appldev noship $ */

procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_NAV_PATH_ID in NUMBER,
  X_FROM_NAV_NODE_USAGE_ID in NUMBER,
  X_TO_NAV_NODE_USAGE_ID in NUMBER,
  X_NAV_BUTTON_REQUIRED in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_OVERRIDE_LABEL in VARCHAR2,
  X_LANGUAGE_CODE in varchar2 default hr_api.userenv_lang
) is
l_language_code varchar2(3);
  cursor C is select ROWID from HR_NAVIGATION_PATHS
    where NAV_PATH_ID = X_NAV_PATH_ID
    ;
begin
-- Validate the language parameter. l_language_code should be passed
  -- instead of x_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := x_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  insert into HR_NAVIGATION_PATHS (
    NAV_PATH_ID,
    FROM_NAV_NODE_USAGE_ID,
    TO_NAV_NODE_USAGE_ID,
    NAV_BUTTON_REQUIRED,
    SEQUENCE,
    OVERRIDE_LABEL
    ) values (
    X_NAV_PATH_ID,
    X_FROM_NAV_NODE_USAGE_ID,
    X_TO_NAV_NODE_USAGE_ID,
    X_NAV_BUTTON_REQUIRED,
    X_SEQUENCE,
    X_OVERRIDE_LABEL
    );

INSERT INTO HR_NAVIGATION_PATHS_TL(
          nav_path_id,
          override_label,
          language,
          source_lang)
          select
          X_Nav_Path_Id,
     	  x_override_label,
          l.language_code,
          userenv('LANG')
          from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HR_NAVIGATION_PATHS_TL T
    where T.NAV_PATH_ID = X_NAV_PATH_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

         open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_NAV_PATH_ID in NUMBER,
  X_FROM_NAV_NODE_USAGE_ID in NUMBER,
  X_TO_NAV_NODE_USAGE_ID in NUMBER,
  X_NAV_BUTTON_REQUIRED in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_OVERRIDE_LABEL in VARCHAR2
) is
  cursor c1 is select
      FROM_NAV_NODE_USAGE_ID,
      TO_NAV_NODE_USAGE_ID,
      NAV_BUTTON_REQUIRED,
      SEQUENCE,
      OVERRIDE_LABEL
    from HR_NAVIGATION_PATHS
    where NAV_PATH_ID = X_NAV_PATH_ID
    for update of NAV_PATH_ID nowait;

     cursor CSR_HR_NAVIGATION_PATHS_TL is
    select OVERRIDE_LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HR_NAVIGATION_PATHS_TL TL
    where nav_path_id = x_nav_path_id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of nav_path_id nowait;

begin
  for tlinfo in c1 loop
      if (
          (tlinfo.FROM_NAV_NODE_USAGE_ID = X_FROM_NAV_NODE_USAGE_ID)
          AND (tlinfo.TO_NAV_NODE_USAGE_ID = X_TO_NAV_NODE_USAGE_ID)
          AND (tlinfo.NAV_BUTTON_REQUIRED = X_NAV_BUTTON_REQUIRED)
          AND (tlinfo.SEQUENCE = X_SEQUENCE)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;

  for tlinf in CSR_HR_NAVIGATION_PATHS_TL loop
    if (tlinf.BASELANG = 'Y') then
      if (    ((tlinf.OVERRIDE_LABEL = X_OVERRIDE_LABEL)
             OR ((tlinf.OVERRIDE_LABEL is null) AND (X_OVERRIDE_LABEL is null)))
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
  X_NAV_PATH_ID in NUMBER,
  X_FROM_NAV_NODE_USAGE_ID in NUMBER,
  X_TO_NAV_NODE_USAGE_ID in NUMBER,
  X_NAV_BUTTON_REQUIRED in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_OVERRIDE_LABEL in VARCHAR2,
  X_LANGUAGE_CODE in varchar2 default hr_api.userenv_lang
) is
l_language_code varchar2(3);
begin
-- Validate the language parameter. l_language_code should be passed
  -- instead of x_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := x_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  update HR_NAVIGATION_PATHS set
    FROM_NAV_NODE_USAGE_ID = X_FROM_NAV_NODE_USAGE_ID,
    TO_NAV_NODE_USAGE_ID = X_TO_NAV_NODE_USAGE_ID,
    NAV_BUTTON_REQUIRED = X_NAV_BUTTON_REQUIRED,
    SEQUENCE = X_SEQUENCE,
    OVERRIDE_LABEL = X_OVERRIDE_LABEL
  where NAV_PATH_ID = X_NAV_PATH_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

    update HR_NAVIGATION_PATHS_TL
    set
    OVERRIDE_LABEL = X_OVERRIDE_LABEL,
    SOURCE_LANG = userenv('LANG')
  where NAV_PATH_ID = X_NAV_PATH_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_NAV_PATH_ID in NUMBER
) is
begin

  delete from HR_NAVIGATION_PATHS_TL
  where NAV_PATH_ID = X_NAV_PATH_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HR_NAVIGATION_PATHS
  where NAV_PATH_ID = X_NAV_PATH_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HR_NAVIGATION_PATHS_TL T
  where not exists
    (select NULL
    from HR_NAVIGATION_PATHS B
    where B.NAV_PATH_ID = T.NAV_PATH_ID
    );

  update HR_NAVIGATION_PATHS_TL T set (
      OVERRIDE_LABEL
    ) = (select
      B.OVERRIDE_LABEL
    from HR_NAVIGATION_PATHS_TL B
    where B.NAV_PATH_ID = T.NAV_PATH_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.NAV_PATH_ID,
      T.LANGUAGE
  ) in (select
      SUBT.NAV_PATH_ID,
      SUBT.LANGUAGE
    from HR_NAVIGATION_PATHS_TL SUBB, HR_NAVIGATION_PATHS_TL SUBT
    where SUBB.NAV_PATH_ID = SUBT.NAV_PATH_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.OVERRIDE_LABEL <> SUBT.OVERRIDE_LABEL
      or (SUBB.OVERRIDE_LABEL is null and SUBT.OVERRIDE_LABEL is not null)
      or (SUBB.OVERRIDE_LABEL is not null and SUBT.OVERRIDE_LABEL is null)
  ));

  insert into HR_NAVIGATION_PATHS_TL (
    NAV_PATH_ID,
    OVERRIDE_LABEL,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.NAV_PATH_ID,
    B.OVERRIDE_LABEL,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HR_NAVIGATION_PATHS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HR_NAVIGATION_PATHS_TL T
    where T.NAV_PATH_ID = B.NAV_PATH_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW(
  X_WORKFLOW_NAME in VARCHAR2,
  X_NODE_NAME_FROM in VARCHAR2,
  X_NODE_NAME_TO in VARCHAR2,
  X_NAV_BUTTON_REQUIRED in VARCHAR2,
  X_SEQUENCE in VARCHAR2,
  X_OVERRIDE_LABEL in VARCHAR2,
  X_NVP_FLAG in VARCHAR2
) is
X_WORKFLOW_ID NUMBER;
X_FROM_NAV_NODE_ID NUMBER;
X_TO_NAV_NODE_ID NUMBER;
X_NAV_PATH_ID NUMBER;
X_ROWID VARCHAR2(30);
X_FROM_NAV_NODE_USAGE_ID NUMBER;
X_TO_NAV_NODE_USAGE_ID NUMBER;
l_flag varchar2(1) := 'Y';
begin

-- Note that for navigation paths, the upload will fail if either
-- of the nav_node_usage_id's have not been extracted in the download or are
-- not already present on the remote site.  This can happen because a
-- navigation node usage can exist across taskflows and therefore need not
-- be extracted for a particular taskflow.  However, to ensure that
-- this does not stop the data upload on the remote site, the uploader
-- traps and surpresses any error raised because of this.  Since the
-- downloader downloads for the occurrence of navigation node usage in both
-- from and to nav_node_usage_id columns, the relevant records will get
-- populated when the other navigation node usage is being loaded.
-- x_nav_flag is used to raise an application error if no data is
-- found when 'to' navigation node usages are being handled.  The l_flag
-- is used to surpress errors when 'from' navigtion node usages are being
-- handled.


  if hr_workflows_pkg.g_load_taskflow <> 'N' then
    l_flag := 'Y';

    select WORKFLOW_ID
    into X_WORKFLOW_ID
    from HR_WORKFLOWS
    where WORKFLOW_NAME = X_WORKFLOW_NAME;

    begin

      select NAV_NODE_ID
      into X_FROM_NAV_NODE_ID
      from HR_NAVIGATION_NODES
      where NAME = X_NODE_NAME_FROM;

      select NAV_NODE_USAGE_ID
      into X_FROM_NAV_NODE_USAGE_ID
      from HR_NAVIGATION_NODE_USAGES
      where WORKFLOW_ID = X_WORKFLOW_ID
      and NAV_NODE_ID = X_FROM_NAV_NODE_ID;

    exception
      when no_data_found then
        if x_nvp_flag = 'FROM' then
          raise;
        else
          l_flag := 'N';
        end if;
    end;

    begin

      select NAV_NODE_ID
      into X_TO_NAV_NODE_ID
      from HR_NAVIGATION_NODES
      where NAME = X_NODE_NAME_TO;

      select NAV_NODE_USAGE_ID
      into X_TO_NAV_NODE_USAGE_ID
      from HR_NAVIGATION_NODE_USAGES
      where WORKFLOW_ID = X_WORKFLOW_ID
      and NAV_NODE_ID = X_TO_NAV_NODE_ID;

    exception
      when no_data_found then
        if x_nvp_flag = 'TO' then
          raise;
        else
          l_flag := 'N';
        end if;
    end;

    if l_flag = 'Y' then
      begin
        select NAV_PATH_ID
        into X_NAV_PATH_ID
        from HR_NAVIGATION_PATHS
        where FROM_NAV_NODE_USAGE_ID = X_FROM_NAV_NODE_USAGE_ID
        and TO_NAV_NODE_USAGE_ID = X_TO_NAV_NODE_USAGE_ID;
      exception
          when no_data_found then
            select HR_NAVIGATION_PATHS_S.NEXTVAL
            into X_NAV_PATH_ID
            from dual;
      end;

      begin
        UPDATE_ROW(
          X_NAV_PATH_ID,
          X_FROM_NAV_NODE_USAGE_ID,
          X_TO_NAV_NODE_USAGE_ID,
          X_NAV_BUTTON_REQUIRED,
          X_SEQUENCE,
          X_OVERRIDE_LABEL
        );
      exception
          when no_data_found then
            INSERT_ROW(
              X_ROWID,
              X_NAV_PATH_ID,
              X_FROM_NAV_NODE_USAGE_ID,
              X_TO_NAV_NODE_USAGE_ID,
              X_NAV_BUTTON_REQUIRED,
              X_SEQUENCE,
              X_OVERRIDE_LABEL
            );
      end;

    end if;

  end if;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_WORKFLOW_NAME in VARCHAR2,
  X_NODE_NAME_FROM in VARCHAR2,
  X_NODE_NAME_TO in VARCHAR2,
  X_OVERRIDE_LABEL in VARCHAR2,
  X_NVP_LABEL in VARCHAR2
) is
X_WORKFLOW_ID NUMBER;
X_FROM_NAV_NODE_ID NUMBER;
X_TO_NAV_NODE_ID NUMBER;
X_NAV_PATH_ID NUMBER;
X_ROWID VARCHAR2(30);
X_FROM_NAV_NODE_USAGE_ID NUMBER;
X_TO_NAV_NODE_USAGE_ID NUMBER;
l_flag varchar2(1) := 'Y';
x_nvp_flag varchar2(30) := x_nvp_label;
begin


 l_flag := 'Y';

    select WORKFLOW_ID
    into X_WORKFLOW_ID
    from HR_WORKFLOWS
    where WORKFLOW_NAME = X_WORKFLOW_NAME;

    begin

      select NAV_NODE_ID
      into X_FROM_NAV_NODE_ID
      from HR_NAVIGATION_NODES
      where NAME = X_NODE_NAME_FROM;

      select NAV_NODE_USAGE_ID
      into X_FROM_NAV_NODE_USAGE_ID
      from HR_NAVIGATION_NODE_USAGES
      where WORKFLOW_ID = X_WORKFLOW_ID
      and NAV_NODE_ID = X_FROM_NAV_NODE_ID;

    exception
      when no_data_found then
        if x_nvp_flag = 'FROM' then
          raise;
        else
          l_flag := 'N';
        end if;
    end;

    begin

      select NAV_NODE_ID
      into X_TO_NAV_NODE_ID
      from HR_NAVIGATION_NODES
      where NAME = X_NODE_NAME_TO;

      select NAV_NODE_USAGE_ID
      into X_TO_NAV_NODE_USAGE_ID
      from HR_NAVIGATION_NODE_USAGES
      where WORKFLOW_ID = X_WORKFLOW_ID
      and NAV_NODE_ID = X_TO_NAV_NODE_ID;

    exception
      when no_data_found then
        if x_nvp_flag = 'TO' then
          raise;
        else
          l_flag := 'N';
        end if;
    end;

    if l_flag = 'Y' then

      begin
        select NAV_PATH_ID
        into X_NAV_PATH_ID
        from HR_NAVIGATION_PATHS
        where FROM_NAV_NODE_USAGE_ID = X_FROM_NAV_NODE_USAGE_ID
        and TO_NAV_NODE_USAGE_ID = X_TO_NAV_NODE_USAGE_ID;
      exception
          when no_data_found then
            select HR_NAVIGATION_PATHS_S.NEXTVAL
            into X_NAV_PATH_ID
            from dual;
      end;

  begin
  update HR_NAVIGATION_PATHS_TL
  set    OVERRIDE_LABEL = X_OVERRIDE_LABEL,
         SOURCE_LANG = userenv('LANG')
  where  userenv('LANG') in (LANGUAGE,SOURCE_LANG)
  and    nav_path_id = x_nav_path_id;
      end;

    end if;
 -- Fix for Bug 4109347 starts here. Added exception block.
 exception
      when no_data_found then
        null;
      when others then
        raise;
  -- Fix for bug 4109347 ends here.
end TRANSLATE_ROW;

end HR_NAVIGATION_PATHS_PKG;

/
