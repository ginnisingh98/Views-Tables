--------------------------------------------------------
--  DDL for Package Body FND_CONCURRENT_QUEUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONCURRENT_QUEUES_PKG" as
/* $Header: AFCPDCQB.pls 120.2 2005/08/19 18:50:39 tkamiya ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_QUEUE_ID in NUMBER,
  X_RESOURCE_CONSUMER_GROUP in VARCHAR2,
  X_CONCURRENT_QUEUE_NAME in VARCHAR2,
  X_PROCESSOR_APPLICATION_ID in NUMBER,
  X_CONCURRENT_PROCESSOR_ID in NUMBER,
  X_MAX_PROCESSES in NUMBER,
  X_RUNNING_PROCESSES in NUMBER,
  X_CACHE_SIZE in NUMBER,
  X_MIN_PROCESSES in NUMBER,
  X_TARGET_PROCESSES in NUMBER,
  X_TARGET_NODE in VARCHAR2,
  X_TARGET_QUEUE in VARCHAR2,
  X_SLEEP_SECONDS in NUMBER,
  X_CONTROL_CODE in VARCHAR2,
  X_DIAGNOSTIC_LEVEL in VARCHAR2,
  X_MANAGER_TYPE in VARCHAR2,
  X_NODE_NAME in VARCHAR2,
  X_NODE_NAME2 in VARCHAR2,
  X_OS_QUEUE in VARCHAR2,
  X_OS_QUEUE2 in VARCHAR2,
  X_DATA_GROUP_ID in NUMBER,
  X_RESTART_TYPE in VARCHAR2,
  X_RESTART_INTERVAL in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USER_CONCURRENT_QUEUE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_CONCURRENT_QUEUES
    where APPLICATION_ID = X_APPLICATION_ID
    and CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID
    ;
begin
  insert into FND_CONCURRENT_QUEUES (
    RESOURCE_CONSUMER_GROUP,
    APPLICATION_ID,
    CONCURRENT_QUEUE_ID,
    CONCURRENT_QUEUE_NAME,
    PROCESSOR_APPLICATION_ID,
    CONCURRENT_PROCESSOR_ID,
    MAX_PROCESSES,
    RUNNING_PROCESSES,
    CACHE_SIZE,
    MIN_PROCESSES,
    TARGET_PROCESSES,
    TARGET_NODE,
    TARGET_QUEUE,
    SLEEP_SECONDS,
    CONTROL_CODE,
    DIAGNOSTIC_LEVEL,
    MANAGER_TYPE,
    NODE_NAME,
    NODE_NAME2,
    OS_QUEUE,
    OS_QUEUE2,
    DATA_GROUP_ID,
    RESTART_TYPE,
    RESTART_INTERVAL,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE,
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
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RESOURCE_CONSUMER_GROUP,
    X_APPLICATION_ID,
    X_CONCURRENT_QUEUE_ID,
    X_CONCURRENT_QUEUE_NAME,
    X_PROCESSOR_APPLICATION_ID,
    X_CONCURRENT_PROCESSOR_ID,
    X_MAX_PROCESSES,
    X_RUNNING_PROCESSES,
    X_CACHE_SIZE,
    X_MIN_PROCESSES,
    X_TARGET_PROCESSES,
    X_TARGET_NODE,
    X_TARGET_QUEUE,
    X_SLEEP_SECONDS,
    X_CONTROL_CODE,
    X_DIAGNOSTIC_LEVEL,
    X_MANAGER_TYPE,
    X_NODE_NAME,
    X_NODE_NAME2,
    X_OS_QUEUE,
    X_OS_QUEUE2,
    X_DATA_GROUP_ID,
    X_RESTART_TYPE,
    X_RESTART_INTERVAL,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE,
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
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_CONCURRENT_QUEUES_TL (
    USER_CONCURRENT_QUEUE_NAME,
    APPLICATION_ID,
    CONCURRENT_QUEUE_ID,
    CONCURRENT_QUEUE_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_USER_CONCURRENT_QUEUE_NAME,
    X_APPLICATION_ID,
    X_CONCURRENT_QUEUE_ID,
    X_CONCURRENT_QUEUE_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_CONCURRENT_QUEUES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID
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
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_QUEUE_ID in NUMBER,
  X_RESOURCE_CONSUMER_GROUP in VARCHAR2,
  X_CONCURRENT_QUEUE_NAME in VARCHAR2,
  X_PROCESSOR_APPLICATION_ID in NUMBER,
  X_CONCURRENT_PROCESSOR_ID in NUMBER,
  X_MAX_PROCESSES in NUMBER,
  X_RUNNING_PROCESSES in NUMBER,
  X_CACHE_SIZE in NUMBER,
  X_MIN_PROCESSES in NUMBER,
  X_TARGET_PROCESSES in NUMBER,
  X_TARGET_NODE in VARCHAR2,
  X_TARGET_QUEUE in VARCHAR2,
  X_SLEEP_SECONDS in NUMBER,
  X_CONTROL_CODE in VARCHAR2,
  X_DIAGNOSTIC_LEVEL in VARCHAR2,
  X_MANAGER_TYPE in VARCHAR2,
  X_NODE_NAME in VARCHAR2,
  X_NODE_NAME2 in VARCHAR2,
  X_OS_QUEUE in VARCHAR2,
  X_OS_QUEUE2 in VARCHAR2,
  X_DATA_GROUP_ID in NUMBER,
  X_RESTART_TYPE in VARCHAR2,
  X_RESTART_INTERVAL in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USER_CONCURRENT_QUEUE_NAME in VARCHAR2
) is
  cursor c is select
      RESOURCE_CONSUMER_GROUP,
      CONCURRENT_QUEUE_NAME,
      PROCESSOR_APPLICATION_ID,
      CONCURRENT_PROCESSOR_ID,
      MAX_PROCESSES,
      RUNNING_PROCESSES,
      CACHE_SIZE,
      MIN_PROCESSES,
      TARGET_PROCESSES,
      TARGET_NODE,
      TARGET_QUEUE,
      SLEEP_SECONDS,
      CONTROL_CODE,
      DIAGNOSTIC_LEVEL,
      MANAGER_TYPE,
      NODE_NAME,
      NODE_NAME2,
      OS_QUEUE,
      OS_QUEUE2,
      DATA_GROUP_ID,
      RESTART_TYPE,
      RESTART_INTERVAL,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE,
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
      ENABLED_FLAG
    from FND_CONCURRENT_QUEUES
    where APPLICATION_ID = X_APPLICATION_ID
    and CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      USER_CONCURRENT_QUEUE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_CONCURRENT_QUEUES_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.RESOURCE_CONSUMER_GROUP = X_RESOURCE_CONSUMER_GROUP)
           OR ((recinfo.RESOURCE_CONSUMER_GROUP is null) AND (X_RESOURCE_CONSUMER_GROUP is null)))
      AND (recinfo.CONCURRENT_QUEUE_NAME = X_CONCURRENT_QUEUE_NAME)
      AND (recinfo.PROCESSOR_APPLICATION_ID = X_PROCESSOR_APPLICATION_ID)
      AND (recinfo.CONCURRENT_PROCESSOR_ID = X_CONCURRENT_PROCESSOR_ID)
      AND (recinfo.MAX_PROCESSES = X_MAX_PROCESSES)
      AND (recinfo.RUNNING_PROCESSES = X_RUNNING_PROCESSES)
      AND ((recinfo.CACHE_SIZE = X_CACHE_SIZE)
           OR ((recinfo.CACHE_SIZE is null) AND (X_CACHE_SIZE is null)))
      AND ((recinfo.MIN_PROCESSES = X_MIN_PROCESSES)
           OR ((recinfo.MIN_PROCESSES is null) AND (X_MIN_PROCESSES is null)))
      AND ((recinfo.TARGET_PROCESSES = X_TARGET_PROCESSES)
           OR ((recinfo.TARGET_PROCESSES is null) AND (X_TARGET_PROCESSES is null)))
      AND ((recinfo.TARGET_NODE = X_TARGET_NODE)
           OR ((recinfo.TARGET_NODE is null) AND (X_TARGET_NODE is null)))
      AND ((recinfo.TARGET_QUEUE = X_TARGET_QUEUE)
           OR ((recinfo.TARGET_QUEUE is null) AND (X_TARGET_QUEUE is null)))
      AND ((recinfo.SLEEP_SECONDS = X_SLEEP_SECONDS)
           OR ((recinfo.SLEEP_SECONDS is null) AND (X_SLEEP_SECONDS is null)))
      AND ((recinfo.CONTROL_CODE = X_CONTROL_CODE)
           OR ((recinfo.CONTROL_CODE is null) AND (X_CONTROL_CODE is null)))
      AND ((recinfo.DIAGNOSTIC_LEVEL = X_DIAGNOSTIC_LEVEL)
           OR ((recinfo.DIAGNOSTIC_LEVEL is null) AND (X_DIAGNOSTIC_LEVEL is null)))
      AND ((recinfo.MANAGER_TYPE = X_MANAGER_TYPE)
           OR ((recinfo.MANAGER_TYPE is null) AND (X_MANAGER_TYPE is null)))
      AND ((recinfo.NODE_NAME = X_NODE_NAME)
           OR ((recinfo.NODE_NAME is null) AND (X_NODE_NAME is null)))
      AND ((recinfo.NODE_NAME2 = X_NODE_NAME2)
           OR ((recinfo.NODE_NAME2 is null) AND (X_NODE_NAME2 is null)))
      AND ((recinfo.OS_QUEUE = X_OS_QUEUE)
           OR ((recinfo.OS_QUEUE is null) AND (X_OS_QUEUE is null)))
      AND ((recinfo.OS_QUEUE2 = X_OS_QUEUE2)
           OR ((recinfo.OS_QUEUE2 is null) AND (X_OS_QUEUE2 is null)))
      AND ((recinfo.DATA_GROUP_ID = X_DATA_GROUP_ID)
           OR ((recinfo.DATA_GROUP_ID is null) AND (X_DATA_GROUP_ID is null)))
      AND ((recinfo.RESTART_TYPE = X_RESTART_TYPE)
           OR ((recinfo.RESTART_TYPE is null) AND (X_RESTART_TYPE is null)))
      AND ((recinfo.RESTART_INTERVAL = X_RESTART_INTERVAL)
           OR ((recinfo.RESTART_INTERVAL is null) AND (X_RESTART_INTERVAL is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE = X_ATTRIBUTE)
           OR ((recinfo.ATTRIBUTE is null) AND (X_ATTRIBUTE is null)))
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
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.USER_CONCURRENT_QUEUE_NAME = X_USER_CONCURRENT_QUEUE_NAME)
               OR ((tlinfo.USER_CONCURRENT_QUEUE_NAME is null) AND (X_USER_CONCURRENT_QUEUE_NAME is null)))
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
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_QUEUE_ID in NUMBER,
  X_RESOURCE_CONSUMER_GROUP in VARCHAR2,
  X_CONCURRENT_QUEUE_NAME in VARCHAR2,
  X_PROCESSOR_APPLICATION_ID in NUMBER,
  X_CONCURRENT_PROCESSOR_ID in NUMBER,
  X_MAX_PROCESSES in NUMBER,
  X_RUNNING_PROCESSES in NUMBER,
  X_CACHE_SIZE in NUMBER,
  X_MIN_PROCESSES in NUMBER,
  X_TARGET_PROCESSES in NUMBER,
  X_TARGET_NODE in VARCHAR2,
  X_TARGET_QUEUE in VARCHAR2,
  X_SLEEP_SECONDS in NUMBER,
  X_CONTROL_CODE in VARCHAR2,
  X_DIAGNOSTIC_LEVEL in VARCHAR2,
  X_MANAGER_TYPE in VARCHAR2,
  X_NODE_NAME in VARCHAR2,
  X_NODE_NAME2 in VARCHAR2,
  X_OS_QUEUE in VARCHAR2,
  X_OS_QUEUE2 in VARCHAR2,
  X_DATA_GROUP_ID in NUMBER,
  X_RESTART_TYPE in VARCHAR2,
  X_RESTART_INTERVAL in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USER_CONCURRENT_QUEUE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_CONCURRENT_QUEUES set
    RESOURCE_CONSUMER_GROUP = X_RESOURCE_CONSUMER_GROUP,
    CONCURRENT_QUEUE_NAME = X_CONCURRENT_QUEUE_NAME,
    PROCESSOR_APPLICATION_ID = X_PROCESSOR_APPLICATION_ID,
    CONCURRENT_PROCESSOR_ID = X_CONCURRENT_PROCESSOR_ID,
    MAX_PROCESSES = X_MAX_PROCESSES,
    RUNNING_PROCESSES = X_RUNNING_PROCESSES,
    CACHE_SIZE = X_CACHE_SIZE,
    MIN_PROCESSES = X_MIN_PROCESSES,
    TARGET_PROCESSES = X_TARGET_PROCESSES,
    TARGET_NODE = X_TARGET_NODE,
    TARGET_QUEUE = X_TARGET_QUEUE,
    SLEEP_SECONDS = X_SLEEP_SECONDS,
    CONTROL_CODE = X_CONTROL_CODE,
    DIAGNOSTIC_LEVEL = X_DIAGNOSTIC_LEVEL,
    MANAGER_TYPE = X_MANAGER_TYPE,
    NODE_NAME = X_NODE_NAME,
    NODE_NAME2 = X_NODE_NAME2,
    OS_QUEUE = X_OS_QUEUE,
    OS_QUEUE2 = X_OS_QUEUE2,
    DATA_GROUP_ID = X_DATA_GROUP_ID,
    RESTART_TYPE = X_RESTART_TYPE,
    RESTART_INTERVAL = X_RESTART_INTERVAL,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE = X_ATTRIBUTE,
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
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_CONCURRENT_QUEUES_TL set
    DESCRIPTION = X_DESCRIPTION,
    USER_CONCURRENT_QUEUE_NAME = X_USER_CONCURRENT_QUEUE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_QUEUE_ID in NUMBER
) is
begin
  delete from FND_CONCURRENT_QUEUES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_CONCURRENT_QUEUES
  where APPLICATION_ID = X_APPLICATION_ID
  and CONCURRENT_QUEUE_ID = X_CONCURRENT_QUEUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_CONCURRENT_QUEUES_TL T
  where not exists
    (select NULL
    from FND_CONCURRENT_QUEUES B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.CONCURRENT_QUEUE_ID = T.CONCURRENT_QUEUE_ID
    );

  update FND_CONCURRENT_QUEUES_TL T set (
      DESCRIPTION,
      USER_CONCURRENT_QUEUE_NAME
    ) = (select
      B.DESCRIPTION,
      B.USER_CONCURRENT_QUEUE_NAME
    from FND_CONCURRENT_QUEUES_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.CONCURRENT_QUEUE_ID = T.CONCURRENT_QUEUE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.CONCURRENT_QUEUE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.CONCURRENT_QUEUE_ID,
      SUBT.LANGUAGE
    from FND_CONCURRENT_QUEUES_TL SUBB, FND_CONCURRENT_QUEUES_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.CONCURRENT_QUEUE_ID = SUBT.CONCURRENT_QUEUE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.USER_CONCURRENT_QUEUE_NAME <> SUBT.USER_CONCURRENT_QUEUE_NAME
      or (SUBB.USER_CONCURRENT_QUEUE_NAME is null and SUBT.USER_CONCURRENT_QUEUE_NAME is not null)
      or (SUBB.USER_CONCURRENT_QUEUE_NAME is not null and SUBT.USER_CONCURRENT_QUEUE_NAME is null)
  ));

*/

  insert into FND_CONCURRENT_QUEUES_TL (
    USER_CONCURRENT_QUEUE_NAME,
    APPLICATION_ID,
    CONCURRENT_QUEUE_ID,
    CONCURRENT_QUEUE_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.USER_CONCURRENT_QUEUE_NAME,
    B.APPLICATION_ID,
    B.CONCURRENT_QUEUE_ID,
    B.CONCURRENT_QUEUE_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_CONCURRENT_QUEUES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_CONCURRENT_QUEUES_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.CONCURRENT_QUEUE_ID = B.CONCURRENT_QUEUE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_CONCURRENT_QUEUES_PKG;

/