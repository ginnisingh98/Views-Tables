--------------------------------------------------------
--  DDL for Package Body FND_SVC_COMPONENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SVC_COMPONENTS_PKG" as
/* $Header: AFSVCMTB.pls 115.5 2002/12/27 20:20:10 ankung noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_COMPONENT_ID in NUMBER,
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_STARTUP_MODE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_QUEUE_ID in NUMBER,
  X_STANDALONE_CONTAINER_NAME in VARCHAR2,
  X_INBOUND_AGENT_NAME in VARCHAR2,
  X_OUTBOUND_AGENT_NAME in VARCHAR2,
  X_CORRELATION_ID in VARCHAR2,
  X_MAX_IDLE_TIME in NUMBER,
  X_COMPONENT_STATUS_INFO in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_SVC_COMPONENTS
    where COMPONENT_ID = X_COMPONENT_ID
    ;
begin
  insert into FND_SVC_COMPONENTS (
    COMPONENT_ID,
    COMPONENT_NAME,
    COMPONENT_STATUS,
    COMPONENT_TYPE,
    STARTUP_MODE,
    CONTAINER_TYPE,
    CUSTOMIZATION_LEVEL,
    APPLICATION_ID,
    CONCURRENT_QUEUE_ID,
    STANDALONE_CONTAINER_NAME,
    INBOUND_AGENT_NAME,
    OUTBOUND_AGENT_NAME,
    CORRELATION_ID,
    MAX_IDLE_TIME,
    COMPONENT_STATUS_INFO,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_COMPONENT_ID,
    X_COMPONENT_NAME,
    X_COMPONENT_STATUS,
    X_COMPONENT_TYPE,
    X_STARTUP_MODE,
    X_CONTAINER_TYPE,
    X_CUSTOMIZATION_LEVEL,
    X_APPLICATION_ID,
    X_CONCURRENT_QUEUE_ID,
    X_STANDALONE_CONTAINER_NAME,
    X_INBOUND_AGENT_NAME,
    X_OUTBOUND_AGENT_NAME,
    X_CORRELATION_ID,
    X_MAX_IDLE_TIME,
    X_COMPONENT_STATUS_INFO,
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
    wf_core.context('FND_SVC_COMPONENTS_PKG', 'Insert_Row', X_COMPONENT_ID, X_COMPONENT_NAME);
    raise;

end INSERT_ROW;

procedure LOCK_ROW (
  X_COMPONENT_ID in NUMBER,
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_STARTUP_MODE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_QUEUE_ID in NUMBER,
  X_STANDALONE_CONTAINER_NAME in VARCHAR2,
  X_INBOUND_AGENT_NAME in VARCHAR2,
  X_OUTBOUND_AGENT_NAME in VARCHAR2,
  X_CORRELATION_ID in VARCHAR2,
  X_MAX_IDLE_TIME in NUMBER,
  X_COMPONENT_STATUS_INFO in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      COMPONENT_NAME,
      COMPONENT_STATUS,
      COMPONENT_TYPE,
      STARTUP_MODE,
      CONTAINER_TYPE,
      CUSTOMIZATION_LEVEL,
      APPLICATION_ID,
      CONCURRENT_QUEUE_ID,
      STANDALONE_CONTAINER_NAME,
      INBOUND_AGENT_NAME,
      OUTBOUND_AGENT_NAME,
      CORRELATION_ID,
      MAX_IDLE_TIME,
      COMPONENT_STATUS_INFO,
      OBJECT_VERSION_NUMBER
    from FND_SVC_COMPONENTS
    where COMPONENT_ID = X_COMPONENT_ID
    for update of COMPONENT_ID nowait;

  recinfo c%rowtype;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c;

  if (    (recinfo.COMPONENT_NAME = X_COMPONENT_NAME)
      AND (recinfo.COMPONENT_STATUS = X_COMPONENT_STATUS)
      AND (recinfo.COMPONENT_TYPE = X_COMPONENT_TYPE)
      AND (recinfo.STARTUP_MODE = X_STARTUP_MODE)
      AND (recinfo.CONTAINER_TYPE = X_CONTAINER_TYPE)
      AND (recinfo.CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL)
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND ((recinfo.CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID)
           OR ((recinfo.CONCURRENT_QUEUE_ID is null) AND (X_CONCURRENT_QUEUE_ID is null)))
      AND ((recinfo.STANDALONE_CONTAINER_NAME = X_STANDALONE_CONTAINER_NAME)
           OR ((recinfo.STANDALONE_CONTAINER_NAME is null) AND (X_STANDALONE_CONTAINER_NAME is null)))
      AND ((recinfo.INBOUND_AGENT_NAME = X_INBOUND_AGENT_NAME)
           OR ((recinfo.INBOUND_AGENT_NAME is null) AND (X_INBOUND_AGENT_NAME is null)))
      AND ((recinfo.OUTBOUND_AGENT_NAME = X_OUTBOUND_AGENT_NAME)
           OR ((recinfo.OUTBOUND_AGENT_NAME is null) AND (X_OUTBOUND_AGENT_NAME is null)))
      AND ((recinfo.CORRELATION_ID = X_CORRELATION_ID)
           OR ((recinfo.CORRELATION_ID is null) AND (X_CORRELATION_ID is null)))
      AND ((recinfo.MAX_IDLE_TIME = X_MAX_IDLE_TIME)
           OR ((recinfo.MAX_IDLE_TIME is null) AND (X_MAX_IDLE_TIME is null)))
      AND ((recinfo.COMPONENT_STATUS_INFO = X_COMPONENT_STATUS_INFO)
           OR ((recinfo.COMPONENT_STATUS_INFO is null) AND (X_COMPONENT_STATUS_INFO is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;

  return;

exception
  when others then
    wf_core.context('FND_SVC_COMPONENTS_PKG', 'Lock_Row', X_COMPONENT_ID, X_COMPONENT_NAME);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_COMPONENT_ID in NUMBER,
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_STARTUP_MODE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_QUEUE_ID in NUMBER,
  X_STANDALONE_CONTAINER_NAME in VARCHAR2,
  X_INBOUND_AGENT_NAME in VARCHAR2,
  X_OUTBOUND_AGENT_NAME in VARCHAR2,
  X_CORRELATION_ID in VARCHAR2,
  X_MAX_IDLE_TIME in NUMBER,
  X_COMPONENT_STATUS_INFO in VARCHAR2,
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
    from FND_SVC_COMPONENTS
    where COMPONENT_ID = X_COMPONENT_ID;

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
    from FND_SVC_COMPONENTS
    where COMPONENT_ID = X_COMPONENT_ID
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

      update FND_SVC_COMPONENTS set
        COMPONENT_NAME = X_COMPONENT_NAME,
        -- COMPONENT_STATUS = X_COMPONENT_STATUS, // run-time data
        COMPONENT_TYPE = X_COMPONENT_TYPE,
        STARTUP_MODE = X_STARTUP_MODE,
        CONTAINER_TYPE = X_CONTAINER_TYPE,
        CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL,
        APPLICATION_ID = X_APPLICATION_ID,
        CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID,
        STANDALONE_CONTAINER_NAME = X_STANDALONE_CONTAINER_NAME,
        INBOUND_AGENT_NAME = X_INBOUND_AGENT_NAME,
        OUTBOUND_AGENT_NAME = X_OUTBOUND_AGENT_NAME,
        CORRELATION_ID = X_CORRELATION_ID,
        MAX_IDLE_TIME = X_MAX_IDLE_TIME,
        -- COMPONENT_STATUS_INFO = X_COMPONENT_STATUS_INFO, // run-time data
        OBJECT_VERSION_NUMBER = l_object_version_number,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
      where COMPONENT_ID = X_COMPONENT_ID;

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
      -- > startup_mode
      -- > max_idle_time
    if WF_EVENTS_PKG.g_Mode = 'UPGRADE' then

      update FND_SVC_COMPONENTS set
        COMPONENT_NAME = X_COMPONENT_NAME,
        -- COMPONENT_STATUS = X_COMPONENT_STATUS, // run-time data
        COMPONENT_TYPE = X_COMPONENT_TYPE,
        -- STARTUP_MODE = X_STARTUP_MODE, // limit data
        CONTAINER_TYPE = X_CONTAINER_TYPE,
        CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL,
        APPLICATION_ID = X_APPLICATION_ID,
        CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID,
        STANDALONE_CONTAINER_NAME = X_STANDALONE_CONTAINER_NAME,
        INBOUND_AGENT_NAME = X_INBOUND_AGENT_NAME,
        OUTBOUND_AGENT_NAME = X_OUTBOUND_AGENT_NAME,
        CORRELATION_ID = X_CORRELATION_ID,
        -- MAX_IDLE_TIME = X_MAX_IDLE_TIME, // limit data
        -- COMPONENT_STATUS_INFO = X_COMPONENT_STATUS_INFO, // run-time data
        OBJECT_VERSION_NUMBER = l_object_version_number,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
      where COMPONENT_ID = X_COMPONENT_ID;

      if (sql%notfound) then
        raise no_data_found;
      end if;

    --
    -- If user is calling this:
    -- It can update ONLY
    -- > startup_mode
    -- > max_idle_time
    else

      update FND_SVC_COMPONENTS set
        STARTUP_MODE = X_STARTUP_MODE,
        MAX_IDLE_TIME = X_MAX_IDLE_TIME,
        OBJECT_VERSION_NUMBER = l_object_version_number,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
      where COMPONENT_ID = X_COMPONENT_ID;

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

      update FND_SVC_COMPONENTS set
        COMPONENT_NAME = X_COMPONENT_NAME,
        -- COMPONENT_STATUS = X_COMPONENT_STATUS, // run-time data
        COMPONENT_TYPE = X_COMPONENT_TYPE,
        STARTUP_MODE = X_STARTUP_MODE,
        CONTAINER_TYPE = X_CONTAINER_TYPE,
        CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL,
        APPLICATION_ID = X_APPLICATION_ID,
        CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID,
        STANDALONE_CONTAINER_NAME = X_STANDALONE_CONTAINER_NAME,
        INBOUND_AGENT_NAME = X_INBOUND_AGENT_NAME,
        OUTBOUND_AGENT_NAME = X_OUTBOUND_AGENT_NAME,
        CORRELATION_ID = X_CORRELATION_ID,
        MAX_IDLE_TIME = X_MAX_IDLE_TIME,
        -- COMPONENT_STATUS_INFO = X_COMPONENT_STATUS_INFO, // run-time data
        OBJECT_VERSION_NUMBER = l_object_version_number,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
      where COMPONENT_ID = X_COMPONENT_ID;

      if (sql%notfound) then
        raise no_data_found;
      end if;
    end if;
  end if;
exception
  when others then
    wf_core.context('FND_SVC_COMPONENTS_PKG', 'Update_Row', X_COMPONENT_ID, X_COMPONENT_NAME);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COMPONENT_ID in NUMBER
) is

l_customization_level varchar2(1);
begin

  select CUSTOMIZATION_LEVEL
  into l_customization_level
  from FND_SVC_COMPONENTS
  where COMPONENT_ID = X_COMPONENT_ID;

  if l_customization_level = 'U' then

    delete from FND_SVC_COMPONENTS
    where COMPONENT_ID = X_COMPONENT_ID;

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end if;
exception
  when others then
    wf_core.context('FND_SVC_COMP_PARAM_VALS_PKG', 'Delete_Row', X_COMPONENT_ID);
    raise;

end DELETE_ROW;


procedure LOAD_ROW (
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_STARTUP_MODE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CONCURRENT_QUEUE_NAME in VARCHAR2,
  X_STANDALONE_CONTAINER_NAME in VARCHAR2,
  X_INBOUND_AGENT_NAME in VARCHAR2,
  X_OUTBOUND_AGENT_NAME in VARCHAR2,
  X_CORRELATION_ID in VARCHAR2,
  X_MAX_IDLE_TIME in NUMBER,
  X_COMPONENT_STATUS_INFO in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
)
IS

begin

  declare
     user_id              number := 0;
     row_id               varchar2(64);

    l_component_id        NUMBER := 0;

    l_concurrent_queue_id fnd_concurrent_queues.concurrent_queue_id%TYPE;
    l_application_id      fnd_application.application_id%TYPE;

  begin

    if (X_OWNER = 'ORACLE') then
      user_id := 1;
    end if;


    IF (X_CONCURRENT_QUEUE_NAME IS NOT NULL) THEN
        SELECT concurrent_queue_id
        INTO l_concurrent_queue_id
        FROM fnd_concurrent_queues
        WHERE concurrent_queue_name = X_CONCURRENT_QUEUE_NAME;

        IF (X_APPLICATION_SHORT_NAME IS NOT NULL) THEN
            SELECT application_id
            INTO l_application_id
            FROM fnd_application
            WHERE application_short_name = X_APPLICATION_SHORT_NAME;
        END IF;

    ELSE
        l_concurrent_queue_id := NULL;
        l_application_id := NULL;
    END IF;

    BEGIN
        SELECT component_id
        INTO l_component_id
        FROM fnd_svc_components
        WHERE component_name = X_COMPONENT_NAME;

        FND_SVC_COMPONENTS_PKG.UPDATE_ROW (
            X_COMPONENT_ID => l_component_id,
            X_COMPONENT_NAME => X_COMPONENT_NAME,
            X_COMPONENT_STATUS => X_COMPONENT_STATUS,
            X_COMPONENT_TYPE => X_COMPONENT_TYPE,
            X_STARTUP_MODE => X_STARTUP_MODE,
            X_CONTAINER_TYPE => X_CONTAINER_TYPE,
            X_CUSTOMIZATION_LEVEL => X_CUSTOMIZATION_LEVEL,
            X_APPLICATION_ID => l_application_id,
            X_CONCURRENT_QUEUE_ID => l_concurrent_queue_id,
            X_STANDALONE_CONTAINER_NAME => X_STANDALONE_CONTAINER_NAME,
            X_INBOUND_AGENT_NAME => X_INBOUND_AGENT_NAME,
            X_OUTBOUND_AGENT_NAME => X_OUTBOUND_AGENT_NAME,
            X_CORRELATION_ID => X_CORRELATION_ID,
            X_MAX_IDLE_TIME => X_MAX_IDLE_TIME,
            X_COMPONENT_STATUS_INFO => X_COMPONENT_STATUS_INFO,
            X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => user_id,
            X_LAST_UPDATE_LOGIN => 0);

    EXCEPTION
        WHEN No_Data_Found THEN
            SELECT fnd_svc_components_s.nextval
            INTO l_component_id
            FROM dual;

            FND_SVC_COMPONENTS_PKG.INSERT_ROW (
            X_ROWID => row_id,
            X_COMPONENT_ID => l_component_id,
            X_COMPONENT_NAME => X_COMPONENT_NAME,
            X_COMPONENT_STATUS => X_COMPONENT_STATUS,
            X_COMPONENT_TYPE => X_COMPONENT_TYPE,
            X_STARTUP_MODE => X_STARTUP_MODE,
            X_CONTAINER_TYPE => X_CONTAINER_TYPE,
            X_CUSTOMIZATION_LEVEL => X_CUSTOMIZATION_LEVEL,
            X_APPLICATION_ID => l_application_id,
            X_CONCURRENT_QUEUE_ID => l_concurrent_queue_id,
            X_STANDALONE_CONTAINER_NAME => X_STANDALONE_CONTAINER_NAME,
            X_INBOUND_AGENT_NAME => X_INBOUND_AGENT_NAME,
            X_OUTBOUND_AGENT_NAME => X_OUTBOUND_AGENT_NAME,
            X_CORRELATION_ID => X_CORRELATION_ID,
            X_MAX_IDLE_TIME => X_MAX_IDLE_TIME,
            X_COMPONENT_STATUS_INFO => X_COMPONENT_STATUS_INFO,
            X_CREATION_DATE => sysdate,
            X_CREATED_BY => user_id,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => user_id,
            X_LAST_UPDATE_LOGIN => 0);
    END;
  end;
end LOAD_ROW;


end FND_SVC_COMPONENTS_PKG;

/
