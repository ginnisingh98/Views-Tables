--------------------------------------------------------
--  DDL for Package Body FND_SVC_COMP_REQUESTS_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SVC_COMP_REQUESTS_H_PKG" as
/* $Header: AFSVCHTB.pls 115.2 2002/12/27 20:41:30 ankung noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REQUEST_HISTORY_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_EVENT_NAME in VARCHAR2,
  X_REQUEST_STATUS in VARCHAR2,
  X_REQUESTED_BY_USER in VARCHAR2,
  X_COMPLETION_DATE in DATE,
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CONTAINER_NAME in VARCHAR2,
  X_EVENT_PARAMS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_SVC_COMP_REQUESTS_H
    where REQUEST_HISTORY_ID = X_REQUEST_HISTORY_ID
    ;
begin
  insert into FND_SVC_COMP_REQUESTS_H (
    REQUEST_HISTORY_ID,
    COMPONENT_ID,
    EVENT_NAME,
    REQUEST_STATUS,
    REQUESTED_BY_USER,
    COMPLETION_DATE,
    COMPONENT_NAME,
    COMPONENT_STATUS,
    COMPONENT_TYPE,
    CONTAINER_TYPE,
    CONTAINER_NAME,
    EVENT_PARAMS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_REQUEST_HISTORY_ID,
    X_COMPONENT_ID,
    X_EVENT_NAME,
    X_REQUEST_STATUS,
    X_REQUESTED_BY_USER,
    X_COMPLETION_DATE,
    X_COMPONENT_NAME,
    X_COMPONENT_STATUS,
    X_COMPONENT_TYPE,
    X_CONTAINER_TYPE,
    X_CONTAINER_NAME,
    X_EVENT_PARAMS,
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
    wf_core.context('FND_SVC_COMP_REQUESTS_H_PKG', 'Insert_Row', X_COMPONENT_ID, X_EVENT_NAME);
    raise;

end INSERT_ROW;

procedure LOCK_ROW (
  X_REQUEST_HISTORY_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_EVENT_NAME in VARCHAR2,
  X_REQUEST_STATUS in VARCHAR2,
  X_REQUESTED_BY_USER in VARCHAR2,
  X_COMPLETION_DATE in DATE,
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CONTAINER_NAME in VARCHAR2,
  X_EVENT_PARAMS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      COMPONENT_ID,
      EVENT_NAME,
      REQUEST_STATUS,
      REQUESTED_BY_USER,
      COMPLETION_DATE,
      COMPONENT_NAME,
      COMPONENT_STATUS,
      COMPONENT_TYPE,
      CONTAINER_TYPE,
      CONTAINER_NAME,
      EVENT_PARAMS,
      OBJECT_VERSION_NUMBER
    from FND_SVC_COMP_REQUESTS_H
    where REQUEST_HISTORY_ID = X_REQUEST_HISTORY_ID
    for update of REQUEST_HISTORY_ID nowait;

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
      AND (recinfo.REQUEST_STATUS = X_REQUEST_STATUS)
      AND (recinfo.REQUESTED_BY_USER = X_REQUESTED_BY_USER)
      AND (recinfo.COMPLETION_DATE = X_COMPLETION_DATE)
      AND (recinfo.COMPONENT_NAME = X_COMPONENT_NAME)
      AND (recinfo.COMPONENT_STATUS = X_COMPONENT_STATUS)
      AND (recinfo.COMPONENT_TYPE = X_COMPONENT_TYPE)
      AND (recinfo.CONTAINER_TYPE = X_CONTAINER_TYPE)
      AND (recinfo.CONTAINER_NAME = X_CONTAINER_NAME)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;

  return;

exception
  when others then
    wf_core.context('FND_SVC_COMP_REQUESTS_H_PKG', 'Lock_Row', X_REQUEST_HISTORY_ID);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_REQUEST_HISTORY_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_EVENT_NAME in VARCHAR2,
  X_REQUEST_STATUS in VARCHAR2,
  X_REQUESTED_BY_USER in VARCHAR2,
  X_COMPLETION_DATE in DATE,
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CONTAINER_NAME in VARCHAR2,
  X_EVENT_PARAMS in VARCHAR2,
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
    from FND_SVC_COMP_REQUESTS_H
    where REQUEST_HISTORY_ID = X_REQUEST_HISTORY_ID;

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
    from FND_SVC_COMP_REQUESTS_H
    where REQUEST_HISTORY_ID = X_REQUEST_HISTORY_ID
    for update;

    if (l_object_version_number = X_OBJECT_VERSION_NUMBER) then

        l_object_version_number := l_object_version_number + 1;
    else

      raise_application_error(-20002,
        wf_core.translate('SVC_RECORD_ALREADY_UPDATED'));

    end if;

  end if;

  update FND_SVC_COMP_REQUESTS_H set
    COMPONENT_ID = X_COMPONENT_ID,
    EVENT_NAME = X_EVENT_NAME,
    REQUEST_STATUS = X_REQUEST_STATUS,
    REQUESTED_BY_USER = X_REQUESTED_BY_USER,
    COMPLETION_DATE = X_COMPLETION_DATE,
    COMPONENT_NAME = X_COMPONENT_NAME,
    COMPONENT_STATUS = X_COMPONENT_STATUS,
    COMPONENT_TYPE = X_COMPONENT_TYPE,
    CONTAINER_TYPE = X_CONTAINER_TYPE,
    CONTAINER_NAME = X_CONTAINER_NAME,
    OBJECT_VERSION_NUMBER = l_object_version_number,
    EVENT_PARAMS = X_EVENT_PARAMS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where REQUEST_HISTORY_ID = X_REQUEST_HISTORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


exception
  when others then
    wf_core.context('FND_SVC_COMP_REQUESTS_H_PKG', 'Update_Row', X_REQUEST_HISTORY_ID);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REQUEST_HISTORY_ID in NUMBER
) is
begin
  delete from FND_SVC_COMP_REQUESTS_H
  where REQUEST_HISTORY_ID = X_REQUEST_HISTORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


exception
  when others then
    wf_core.context('FND_SVC_COMP_REQUESTS_H_PKG', 'Delete_Row', X_REQUEST_HISTORY_ID);
    raise;
end DELETE_ROW;

end FND_SVC_COMP_REQUESTS_H_PKG;

/
