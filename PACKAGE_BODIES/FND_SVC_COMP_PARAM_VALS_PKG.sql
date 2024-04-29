--------------------------------------------------------
--  DDL for Package Body FND_SVC_COMP_PARAM_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SVC_COMP_PARAM_VALS_PKG" as
/* $Header: AFSVCVTB.pls 115.6 2002/12/27 20:33:49 ankung noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_COMPONENT_PARAMETER_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_PARAMETER_ID in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_SVC_COMP_PARAM_VALS
    where COMPONENT_PARAMETER_ID = X_COMPONENT_PARAMETER_ID
    ;
begin
  insert into FND_SVC_COMP_PARAM_VALS (
    COMPONENT_PARAMETER_ID,
    COMPONENT_ID,
    PARAMETER_ID,
    PARAMETER_VALUE,
    CUSTOMIZATION_LEVEL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values
  (
    X_COMPONENT_PARAMETER_ID,
    X_COMPONENT_ID,
    X_PARAMETER_ID,
    X_PARAMETER_VALUE,
    X_CUSTOMIZATION_LEVEL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

exception
  when others then
    wf_core.context('FND_SVC_COMP_PARAM_VALS_PKG', 'Insert_Row', X_COMPONENT_PARAMETER_ID);
    raise;
end INSERT_ROW;


procedure LOCK_ROW (
  X_COMPONENT_PARAMETER_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_PARAMETER_ID in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      COMPONENT_ID,
      PARAMETER_ID,
      PARAMETER_VALUE,
      CUSTOMIZATION_LEVEL,
      OBJECT_VERSION_NUMBER
    from FND_SVC_COMP_PARAM_VALS
    where COMPONENT_PARAMETER_ID = X_COMPONENT_PARAMETER_ID
    for update of COMPONENT_PARAMETER_ID nowait;

  recinfo c%rowtype;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c;

  if (    ((recinfo.PARAMETER_VALUE = X_PARAMETER_VALUE)
            OR ((recinfo.PARAMETER_VALUE is null) AND (X_PARAMETER_VALUE is null)))
    AND (recinfo.COMPONENT_ID = X_COMPONENT_ID)
    AND (recinfo.PARAMETER_ID = X_PARAMETER_ID)
    AND (recinfo.CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL)
    AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;

  return;

exception
  when others then
    wf_core.context('FND_SVC_COMP_PARAM_VALS_PKG', 'Lock_Row', X_COMPONENT_PARAMETER_ID);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_COMPONENT_PARAMETER_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_PARAMETER_ID in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  l_object_version_number NUMBER;
begin

  --
  -- Perform OVN checks
  --
  if X_OBJECT_VERSION_NUMBER = -1 then

    --
    -- Allow update.  Increment the database's OVN by 1
    --
    select OBJECT_VERSION_NUMBER
    into l_object_version_number
    from FND_SVC_COMP_PARAM_VALS
    where COMPONENT_PARAMETER_ID = X_COMPONENT_PARAMETER_ID;

    l_object_version_number := l_object_version_number + 1;

  else

    --
    -- Lock the row.  Allow update only if the database's OVN equals the one
    -- passed in.
    --
    -- If update is allowed, increment the database's OVN by 1.
    -- Otherwise, raise an error.
    --

    select OBJECT_VERSION_NUMBER
    into l_object_version_number
    from FND_SVC_COMP_PARAM_VALS
    where COMPONENT_PARAMETER_ID = X_COMPONENT_PARAMETER_ID
    for update;

    if (l_object_version_number = X_OBJECT_VERSION_NUMBER) then

        l_object_version_number := l_object_version_number + 1;
    else

      raise_application_error(-20002,
        wf_core.translate('SVC_RECORD_ALREADY_UPDATED'));

    end if;

  end if;

  --
  -- If CORE customization level
  --
  if X_CUSTOMIZATION_LEVEL = 'C' then

    --
    -- If loader is calling this:
    -- It can update everything
    --
    if WF_EVENTS_PKG.g_Mode = 'UPGRADE' then

      update FND_SVC_COMP_PARAM_VALS set
        COMPONENT_ID = X_COMPONENT_ID,
        PARAMETER_ID = X_PARAMETER_ID,
        PARAMETER_VALUE = X_PARAMETER_VALUE,
        CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL,
        OBJECT_VERSION_NUMBER = l_object_version_number,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
      where COMPONENT_PARAMETER_ID = X_COMPONENT_PARAMETER_ID;

      if (sql%notfound) then
        raise no_data_found;
      end if;

    --
    -- If user is calling this:
    -- It can NOT update anything
    --
    else
      null;
    end if;

  --
  -- If LIMIT customization level
  --
  elsif X_CUSTOMIZATION_LEVEL = 'L' then

    --
    -- If loader is calling this
    -- It can update everything EXCEPT
      -- > parameter_value
    if WF_EVENTS_PKG.g_Mode = 'UPGRADE' then

      update FND_SVC_COMP_PARAM_VALS set
        COMPONENT_ID = X_COMPONENT_ID,
        PARAMETER_ID = X_PARAMETER_ID,
        -- PARAMETER_VALUE = X_PARAMETER_VALUE, // limit column
        CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL,
        OBJECT_VERSION_NUMBER = l_object_version_number,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
      where COMPONENT_PARAMETER_ID = X_COMPONENT_PARAMETER_ID;

      if (sql%notfound) then
        raise no_data_found;
      end if;

    --
    -- If user is calling this:
    -- It can update ONLY
    -- > startup_mode
    -- > max_idle_time
    else

      update FND_SVC_COMP_PARAM_VALS set
        PARAMETER_VALUE = X_PARAMETER_VALUE,
        OBJECT_VERSION_NUMBER = l_object_version_number,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
      where COMPONENT_PARAMETER_ID = X_COMPONENT_PARAMETER_ID;

      if (sql%notfound) then
        raise no_data_found;
      end if;

    end if;

  --
  -- If USER customization level
  --
  elsif X_CUSTOMIZATION_LEVEL = 'U' then
    --
    -- If loader is calling this
    -- It can NOT update anything
    --
    if WF_EVENTS_PKG.g_Mode = 'UPGRADE' then
      null;

    --
    -- If user is calling this:
    -- It can update everything
    --
    else

      update FND_SVC_COMP_PARAM_VALS set
        COMPONENT_ID = X_COMPONENT_ID,
        PARAMETER_ID = X_PARAMETER_ID,
        PARAMETER_VALUE = X_PARAMETER_VALUE,
        CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL,
        OBJECT_VERSION_NUMBER = l_object_version_number,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
      where COMPONENT_PARAMETER_ID = X_COMPONENT_PARAMETER_ID;

      if (sql%notfound) then
        raise no_data_found;
      end if;
    end if;
  end if;

exception
  when others then
    wf_core.context('FND_SVC_COMP_PARAM_VALS_PKG', 'Update_Row', X_COMPONENT_PARAMETER_ID);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COMPONENT_PARAMETER_ID in NUMBER
) is
l_customization_level varchar2(1);
begin

  select CUSTOMIZATION_LEVEL
  into l_customization_level
  from FND_SVC_COMP_PARAM_VALS
  where COMPONENT_PARAMETER_ID = X_COMPONENT_PARAMETER_ID;

  if l_customization_level = 'U' then

    delete from FND_SVC_COMP_PARAM_VALS
    where COMPONENT_PARAMETER_ID = X_COMPONENT_PARAMETER_ID;

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end if;
exception
  when others then
    wf_core.context('FND_SVC_COMP_PARAM_VALS_PKG', 'Delete_Row', X_COMPONENT_PARAMETER_ID);
    raise;

end DELETE_ROW;

procedure LOAD_ROW (
  X_COMPONENT_NAME in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_PARAMETER_VALUE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
)
IS

begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);

     l_component_parameter_id number;
     l_parameter_id           number;
     l_component_id           number;
     l_component_type         fnd_svc_components.component_type%TYPE;
  begin

      if (X_OWNER = 'ORACLE') then
        user_id := 1;
      end if;

      SELECT component_id, component_type
      INTO l_component_id, l_component_type
      FROM fnd_svc_components
      WHERE component_name = X_COMPONENT_NAME;

      SELECT parameter_id
      INTO l_parameter_id
      FROM fnd_svc_comp_params_b
      WHERE parameter_name = X_PARAMETER_NAME
        AND component_type = l_component_type;

      BEGIN

        SELECT component_parameter_id
        INTO l_component_parameter_id
        FROM fnd_svc_comp_param_vals
        WHERE component_id = l_component_id
        AND parameter_id = l_parameter_id;

        FND_SVC_COMP_PARAM_VALS_PKG.UPDATE_ROW (
            X_COMPONENT_PARAMETER_ID => l_component_parameter_id,
            X_COMPONENT_ID => l_component_id,
            X_PARAMETER_ID => l_parameter_id,
            X_PARAMETER_VALUE => X_PARAMETER_VALUE,
            X_CUSTOMIZATION_LEVEL => X_CUSTOMIZATION_LEVEL,
            X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => user_id,
            X_LAST_UPDATE_LOGIN => 0);

      EXCEPTION
        WHEN No_Data_Found THEN
          SELECT fnd_svc_comp_param_vals_s.nextval
          INTO l_component_parameter_id
          FROM dual;

          FND_SVC_COMP_PARAM_VALS_PKG.INSERT_ROW (
              X_ROWID => row_id,
              X_COMPONENT_PARAMETER_ID => l_component_parameter_id,
              X_COMPONENT_ID => l_component_id,
              X_PARAMETER_ID => l_parameter_id,
              X_PARAMETER_VALUE => X_PARAMETER_VALUE,
              X_CUSTOMIZATION_LEVEL => X_CUSTOMIZATION_LEVEL,
              X_CREATION_DATE => sysdate,
              X_CREATED_BY => user_id,
              X_LAST_UPDATE_DATE => sysdate,
              X_LAST_UPDATED_BY => user_id,
              X_LAST_UPDATE_LOGIN => 0);
      END;
  END;
end LOAD_ROW;


end FND_SVC_COMP_PARAM_VALS_PKG;

/
