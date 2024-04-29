--------------------------------------------------------
--  DDL for Package Body FND_SVC_COMP_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SVC_COMP_REQUESTS_PKG" as
/* $Header: AFSVCRTB.pls 115.4 2003/01/17 22:20:38 ankung noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_COMPONENT_REQUEST_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_EVENT_NAME in VARCHAR2,
  X_EVENT_DATE in DATE,
  X_REQUESTED_BY_USER in VARCHAR2,
  X_JOB_ID in NUMBER,
  X_EVENT_PARAMS in VARCHAR2,
  X_EVENT_FREQUENCY in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_SVC_COMP_REQUESTS
    where COMPONENT_REQUEST_ID = X_COMPONENT_REQUEST_ID
    ;
begin
  insert into FND_SVC_COMP_REQUESTS (
    COMPONENT_REQUEST_ID,
    COMPONENT_ID,
    EVENT_NAME,
    EVENT_DATE,
    REQUESTED_BY_USER,
    JOB_ID,
    EVENT_PARAMS,
    EVENT_FREQUENCY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_COMPONENT_REQUEST_ID,
    X_COMPONENT_ID,
    X_EVENT_NAME,
    X_EVENT_DATE,
    X_REQUESTED_BY_USER,
    X_JOB_ID,
    X_EVENT_PARAMS,
    X_EVENT_FREQUENCY,
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
    wf_core.context('FND_SVC_COMP_REQUESTS_PKG', 'Insert_Row', X_COMPONENT_ID, X_EVENT_NAME);
    raise;

end INSERT_ROW;

procedure LOCK_ROW (
  X_COMPONENT_REQUEST_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_EVENT_NAME in VARCHAR2,
  X_EVENT_DATE in DATE,
  X_REQUESTED_BY_USER in VARCHAR2,
  X_JOB_ID in NUMBER,
  X_EVENT_PARAMS in VARCHAR2,
  X_EVENT_FREQUENCY in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      COMPONENT_ID,
      EVENT_NAME,
      EVENT_DATE,
      REQUESTED_BY_USER,
      JOB_ID,
      EVENT_FREQUENCY,
      OBJECT_VERSION_NUMBER,
      EVENT_PARAMS
    from FND_SVC_COMP_REQUESTS
    where COMPONENT_REQUEST_ID = X_COMPONENT_REQUEST_ID
    for update of COMPONENT_REQUEST_ID nowait;

  recinfo c%rowtype;
begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c;

  if (    ((recinfo.EVENT_PARAMS = X_EVENT_PARAMS)
           OR ((recinfo.EVENT_PARAMS is null) AND (X_EVENT_PARAMS is null)))
      AND (recinfo.COMPONENT_ID = X_COMPONENT_ID)
      AND (recinfo.EVENT_NAME = X_EVENT_NAME)
      AND (recinfo.EVENT_DATE = X_EVENT_DATE)
      AND (recinfo.REQUESTED_BY_USER = X_REQUESTED_BY_USER)
      AND (recinfo.JOB_ID = X_JOB_ID)
      AND ((recinfo.EVENT_FREQUENCY = X_EVENT_FREQUENCY)
           OR ((recinfo.EVENT_FREQUENCY is null) AND (X_EVENT_FREQUENCY is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;

  return;

exception
  when others then
    wf_core.context('FND_SVC_COMP_REQUESTS_PKG', 'Lock_Row', X_COMPONENT_REQUEST_ID);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_COMPONENT_REQUEST_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_EVENT_NAME in VARCHAR2,
  X_EVENT_DATE in DATE,
  X_REQUESTED_BY_USER in VARCHAR2,
  X_JOB_ID in NUMBER,
  X_EVENT_PARAMS in VARCHAR2,
  X_EVENT_FREQUENCY in NUMBER,
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
    from FND_SVC_COMP_REQUESTS
    where COMPONENT_REQUEST_ID = X_COMPONENT_REQUEST_ID;

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
    from FND_SVC_COMP_REQUESTS
    where COMPONENT_REQUEST_ID = X_COMPONENT_REQUEST_ID
    for update;

    if (l_object_version_number = X_OBJECT_VERSION_NUMBER) then

        l_object_version_number := l_object_version_number + 1;
    else

      raise_application_error(-20002,
        wf_core.translate('SVC_RECORD_ALREADY_UPDATED'));

    end if;

  end if;

  update FND_SVC_COMP_REQUESTS set
    COMPONENT_ID = X_COMPONENT_ID,
    EVENT_NAME = X_EVENT_NAME,
    EVENT_DATE = X_EVENT_DATE,
    REQUESTED_BY_USER = X_REQUESTED_BY_USER,
    JOB_ID = X_JOB_ID,
    EVENT_PARAMS = X_EVENT_PARAMS,
    EVENT_FREQUENCY = X_EVENT_FREQUENCY,
    OBJECT_VERSION_NUMBER = l_object_version_number,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where COMPONENT_REQUEST_ID = X_COMPONENT_REQUEST_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('FND_SVC_COMP_REQUESTS_PKG', 'Update_Row', X_COMPONENT_REQUEST_ID);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COMPONENT_REQUEST_ID in NUMBER
) is
begin
  delete from FND_SVC_COMP_REQUESTS
  where COMPONENT_REQUEST_ID = X_COMPONENT_REQUEST_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('FND_SVC_COMP_REQUESTS_PKG', 'Delete_Row', X_COMPONENT_REQUEST_ID);
    raise;
end DELETE_ROW;


procedure LOAD_ROW (
  X_COMPONENT_NAME in VARCHAR2,
  X_EVENT_NAME in VARCHAR2,
  X_EVENT_DATE in DATE,
  X_REQUESTED_BY_USER in VARCHAR2,
  X_EVENT_PARAMS in VARCHAR2,
  X_EVENT_FREQUENCY in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
)
IS

begin
  declare
     user_id            number := 0;
     row_id             varchar2(64);

     l_component_request_id number;
     l_component_id         number;
     l_job_id               number;
     l_interval             varchar2(1996);

  begin

      if (X_OWNER = 'ORACLE') then
        user_id := 1;
      end if;

      SELECT component_id
      INTO l_component_id
      FROM fnd_svc_components
      WHERE component_name = X_COMPONENT_NAME;


      IF X_EVENT_FREQUENCY IS NOT NULL THEN
        l_interval := 'SYSDATE + (' || TO_CHAR(X_EVENT_FREQUENCY) || '/(24*60))';
      ELSE
        l_interval := null;
      END IF;

      BEGIN

        --
        -- NOTE: We don't expect users to ever define two events with exactly
        -- the same name, date, and frequency.  However, just in case they do,
        -- we're only selecting the first one we find here.
        --
        SELECT component_request_id, job_id
        INTO l_component_request_id, l_job_id
        FROM fnd_svc_comp_requests
        WHERE component_id = l_component_id
          AND rownum = 1
          AND event_name = X_EVENT_NAME
          AND event_date = X_EVENT_DATE
          AND ( (event_frequency is NULL AND X_EVENT_FREQUENCY IS NULL)
             OR (event_frequency = X_EVENT_FREQUENCY));


        FND_SVC_COMP_REQUESTS_PKG.UPDATE_ROW (
            X_COMPONENT_REQUEST_ID => l_component_request_id,
            X_COMPONENT_ID => l_component_id,
            X_EVENT_NAME => X_EVENT_NAME,
            X_EVENT_DATE => X_EVENT_DATE,
            X_REQUESTED_BY_USER => X_REQUESTED_BY_USER,
            X_JOB_ID => l_job_id,
            X_EVENT_PARAMS => X_EVENT_PARAMS,
            X_EVENT_FREQUENCY => X_EVENT_FREQUENCY,
            X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => user_id,
            X_LAST_UPDATE_LOGIN => 0);

        DBMS_JOB.CHANGE
        (
          job => l_job_id
        , what => null
        , next_date => X_EVENT_DATE
        , interval => l_interval
        );

      EXCEPTION
        WHEN No_Data_Found THEN

          SELECT fnd_svc_comp_requests_s.nextval
          INTO l_component_request_id
          FROM dual;

          DBMS_JOB.SUBMIT
          (
            job => l_job_id
          , what => 'FND_SVC_COMPONENT.EXECUTE_REQUEST (p_component_request_id => ' || TO_CHAR(l_component_request_id) || ');'
          , next_date => X_EVENT_DATE
          , interval => l_interval
          );

          FND_SVC_COMP_REQUESTS_PKG.INSERT_ROW (
              X_ROWID => row_id,
              X_COMPONENT_REQUEST_ID => l_component_request_id,
              X_COMPONENT_ID => l_component_id,
              X_EVENT_NAME => X_EVENT_NAME,
              X_EVENT_DATE => X_EVENT_DATE,
              X_REQUESTED_BY_USER => X_REQUESTED_BY_USER,
              X_JOB_ID => l_job_id,
              X_EVENT_PARAMS => X_EVENT_PARAMS,
              X_EVENT_FREQUENCY => X_EVENT_FREQUENCY,
              X_CREATED_BY => user_id,
              X_LAST_UPDATED_BY => user_id,
              X_LAST_UPDATE_LOGIN => 0);
      END;
  END;

end LOAD_ROW;


end FND_SVC_COMP_REQUESTS_PKG;

/
