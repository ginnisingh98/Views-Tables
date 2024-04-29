--------------------------------------------------------
--  DDL for Package Body HR_KI_TIS_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_TIS_LOAD_API" as
/* $Header: hrkitisl.pkb 120.3 2008/02/26 14:03:53 avarri ship $ */
--
-- Package Variables
--
g_package  varchar2(31) := 'HR_KI_TIS_LOAD_API';
--
-- The below procedure inserts the row into HR_KI_TOPIC_INTEGRATIONS
--
procedure INSERT_ROW (
  X_ROWID                 in out nocopy VARCHAR2,
  X_TOPIC_INTEGRATIONS_ID in out nocopy NUMBER,
  X_TOPIC_ID              in NUMBER,
  X_INTEGRATION_ID        in NUMBER,
  X_PARAM_NAME1           in VARCHAR2,
  X_PARAM_VALUE1          in VARCHAR2,
  X_PARAM_NAME2           in VARCHAR2,
  X_PARAM_VALUE2          in VARCHAR2,
  X_PARAM_NAME3           in VARCHAR2,
  X_PARAM_VALUE3          in VARCHAR2,
  X_PARAM_NAME4           in VARCHAR2,
  X_PARAM_VALUE4          in VARCHAR2,
  X_PARAM_NAME5           in VARCHAR2,
  X_PARAM_VALUE5          in VARCHAR2,
  X_PARAM_NAME6           in VARCHAR2,
  X_PARAM_VALUE6          in VARCHAR2,
  X_PARAM_NAME7           in VARCHAR2,
  X_PARAM_VALUE7          in VARCHAR2,
  X_PARAM_NAME8           in VARCHAR2,
  X_PARAM_VALUE8          in VARCHAR2,
  X_PARAM_NAME9           in VARCHAR2,
  X_PARAM_VALUE9          in VARCHAR2,
  X_PARAM_NAME10          in VARCHAR2,
  X_PARAM_VALUE10         in VARCHAR2,
  X_CREATED_BY            in NUMBER,
  X_CREATION_DATE         in DATE,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER
) is
  L_LOCK_HANDLE             varchar2(500);
  L_RETURN_VALUE            number;
--
  cursor C is
    SELECT ROWID
      FROM HR_KI_TOPIC_INTEGRATIONS
     WHERE topic_integrations_id = x_topic_integrations_id;
--
begin
--
  DBMS_LOCK.ALLOCATE_UNIQUE
    (LOCKNAME     =>'HR_KI_TOPIC_INTEGRATIONS.'||X_TOPIC_INTEGRATIONS_ID
    ,LOCKHANDLE   => L_LOCK_HANDLE
    );
  L_RETURN_VALUE := DBMS_LOCK.REQUEST
                      (LOCKHANDLE         => L_LOCK_HANDLE
                      ,TIMEOUT            => 0
                      ,RELEASE_ON_COMMIT  => true);

  if L_RETURN_VALUE = 0  then
    select HR_KI_TOPIC_INTEGRATIONS_S.NEXTVAL into x_topic_integrations_id
    from sys.dual;
    --
    insert into HR_KI_TOPIC_INTEGRATIONS (
      TOPIC_INTEGRATIONS_ID,
      TOPIC_ID,
      INTEGRATION_ID,
      PARAM_NAME1,
      PARAM_VALUE1,
      PARAM_NAME2,
      PARAM_VALUE2,
      PARAM_NAME3,
      PARAM_VALUE3,
      PARAM_NAME4,
      PARAM_VALUE4,
      PARAM_NAME5,
      PARAM_VALUE5,
      PARAM_NAME6,
      PARAM_VALUE6,
      PARAM_NAME7,
      PARAM_VALUE7,
      PARAM_NAME8,
      PARAM_VALUE8,
      PARAM_NAME9,
      PARAM_VALUE9,
      PARAM_NAME10,
      PARAM_VALUE10,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER
    ) values (
      X_TOPIC_INTEGRATIONS_ID,
      X_TOPIC_ID,
      X_INTEGRATION_ID,
      X_PARAM_NAME1,
      X_PARAM_VALUE1,
      X_PARAM_NAME2,
      X_PARAM_VALUE2,
      X_PARAM_NAME3,
      X_PARAM_VALUE3,
      X_PARAM_NAME4,
      X_PARAM_VALUE4,
      X_PARAM_NAME5,
      X_PARAM_VALUE5,
      X_PARAM_NAME6,
      X_PARAM_VALUE6,
      X_PARAM_NAME7,
      X_PARAM_VALUE7,
      X_PARAM_NAME8,
      X_PARAM_VALUE8,
      X_PARAM_NAME9,
      X_PARAM_VALUE9,
      X_PARAM_NAME10,
      X_PARAM_VALUE10,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      1
    );
  end if;
--
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
      close c;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'HR_KI_TOPIC_INTEGRATIONS.insert_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  close c;
--
end INSERT_ROW;
--
-- The below procure updates the existing row in HR_KI_TOPIC_INTEGRATIONS
--
procedure UPDATE_ROW
  (X_TOPIC_INTEGRATIONS_ID in NUMBER,
   X_TOPIC_ID              in NUMBER,
   X_INTEGRATION_ID        in NUMBER,
   X_PARAM_NAME1           in VARCHAR2,
   X_PARAM_VALUE1          in VARCHAR2,
   X_PARAM_NAME2           in VARCHAR2,
   X_PARAM_VALUE2          in VARCHAR2,
   X_PARAM_NAME3           in VARCHAR2,
   X_PARAM_VALUE3          in VARCHAR2,
   X_PARAM_NAME4           in VARCHAR2,
   X_PARAM_VALUE4          in VARCHAR2,
   X_PARAM_NAME5           in VARCHAR2,
   X_PARAM_VALUE5          in VARCHAR2,
   X_PARAM_NAME6           in VARCHAR2,
   X_PARAM_VALUE6          in VARCHAR2,
   X_PARAM_NAME7           in VARCHAR2,
   X_PARAM_VALUE7          in VARCHAR2,
   X_PARAM_NAME8           in VARCHAR2,
   X_PARAM_VALUE8          in VARCHAR2,
   X_PARAM_NAME9           in VARCHAR2,
   X_PARAM_VALUE9          in VARCHAR2,
   X_PARAM_NAME10          in VARCHAR2,
   X_PARAM_VALUE10         in VARCHAR2,
   X_CREATED_BY            in NUMBER,
   X_CREATION_DATE         in DATE,
   X_LAST_UPDATE_DATE      in DATE,
   X_LAST_UPDATED_BY       in NUMBER,
   X_LAST_UPDATE_LOGIN     in NUMBER,
   X_OBJECT_VERSION_NUMBER in NUMBER
   ) as
  L_LOCK_HANDLE             varchar2(500);
  L_RETURN_VALUE            number;
--
begin
  DBMS_LOCK.ALLOCATE_UNIQUE
    (LOCKNAME     =>'HR_KI_TOPIC_INTEGRATIONS.'||X_TOPIC_INTEGRATIONS_ID
    ,LOCKHANDLE   => L_LOCK_HANDLE
    );
  L_RETURN_VALUE := DBMS_LOCK.REQUEST
                      (LOCKHANDLE         => L_LOCK_HANDLE
                      ,TIMEOUT            => 0
                      ,RELEASE_ON_COMMIT  => true);
--
  if L_RETURN_VALUE = 0  then
    UPDATE HR_KI_TOPIC_INTEGRATIONS TIS
       SET tis.topic_id              = X_TOPIC_ID
          ,tis.integration_id        = X_INTEGRATION_ID
          ,tis.PARAM_NAME1           = X_PARAM_NAME1
          ,tis.PARAM_VALUE1          = X_PARAM_VALUE1
          ,tis.PARAM_NAME2           = X_PARAM_NAME2
          ,tis.PARAM_VALUE2          = X_PARAM_VALUE2
          ,tis.PARAM_NAME3           = X_PARAM_NAME3
          ,tis.PARAM_VALUE3          = X_PARAM_VALUE3
          ,tis.PARAM_NAME4           = X_PARAM_NAME4
          ,tis.PARAM_VALUE4          = X_PARAM_VALUE4
          ,tis.PARAM_NAME5           = X_PARAM_NAME5
          ,tis.PARAM_VALUE5          = X_PARAM_VALUE5
          ,tis.PARAM_NAME6           = X_PARAM_NAME6
          ,tis.PARAM_VALUE6          = X_PARAM_VALUE6
          ,tis.PARAM_NAME7           = X_PARAM_NAME7
          ,tis.PARAM_VALUE7          = X_PARAM_VALUE7
          ,tis.PARAM_NAME8           = X_PARAM_NAME8
          ,tis.PARAM_VALUE8          = X_PARAM_VALUE8
          ,tis.PARAM_NAME9           = X_PARAM_NAME9
          ,tis.PARAM_VALUE9          = X_PARAM_VALUE9
          ,tis.PARAM_NAME10          = X_PARAM_NAME10
          ,tis.PARAM_VALUE10         = X_PARAM_VALUE10
          ,tis.CREATED_BY            = X_CREATED_BY
          ,tis.CREATION_DATE         = X_CREATION_DATE
          ,tis.LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE
          ,tis.LAST_UPDATED_BY       = X_LAST_UPDATED_BY
          ,tis.LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN
          ,tis.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
     WHERE tis.TOPIC_INTEGRATIONS_ID = X_TOPIC_INTEGRATIONS_ID;
  end if;
end UPDATE_ROW;
--
-- This procedure validates the topic key and integration key.
--
procedure validate_keys
(
X_TOPIC_KEY        in VARCHAR2,
X_INTEGRATION_KEY  in VARCHAR2,
X_TOPIC_ID         in out nocopy number,
X_INTEGRATION_ID   in out nocopy number
)
is
--
  l_proc VARCHAR2(35) := 'HR_KI_TIS_LOAD_API.VALIDATE_KEYS';
--
  CURSOR C_VAL_TPC IS
        select topic_id
        from HR_KI_TOPICS
        where upper(topic_key) = upper(X_TOPIC_KEY);
--
  CURSOR C_VAL_INT IS
        select integration_id
        from HR_KI_INTEGRATIONS
        where upper(integration_key) = upper(X_INTEGRATION_KEY);
--
begin
   open C_VAL_TPC;
   fetch C_VAL_TPC into x_topic_id;
--
   If C_VAL_TPC%NOTFOUND then
      close C_VAL_TPC;
      fnd_message.set_name( 'PER','PER_449963_TIS_TOPIC_ID_ABSENT');
      fnd_message.raise_error;
   End If;
   close C_VAL_TPC;
--
   open C_VAL_INT;
   fetch C_VAL_INT into x_integration_id;
   If C_VAL_INT%NOTFOUND then
      close C_VAL_INT;
      fnd_message.set_name( 'PER','PER_449962_TIS_INT_ID_ABSENT');
      fnd_message.raise_error;
   End If;
   close C_VAL_INT;
end validate_keys;
--
--  The below procedure loads the topic integrations row into database.
--
procedure LOAD_ROW
  (
   X_TOPIC_KEY        in VARCHAR2,
   X_INTEGRATION_KEY  in VARCHAR2,
   X_PARAM_NAME1      in VARCHAR2,
   X_PARAM_VALUE1     in VARCHAR2,
   X_PARAM_NAME2      in VARCHAR2,
   X_PARAM_VALUE2     in VARCHAR2,
   X_PARAM_NAME3      in VARCHAR2,
   X_PARAM_VALUE3     in VARCHAR2,
   X_PARAM_NAME4      in VARCHAR2,
   X_PARAM_VALUE4     in VARCHAR2,
   X_PARAM_NAME5      in VARCHAR2,
   X_PARAM_VALUE5     in VARCHAR2,
   X_PARAM_NAME6      in VARCHAR2,
   X_PARAM_VALUE6     in VARCHAR2,
   X_PARAM_NAME7      in VARCHAR2,
   X_PARAM_VALUE7     in VARCHAR2,
   X_PARAM_NAME8      in VARCHAR2,
   X_PARAM_VALUE8     in VARCHAR2,
   X_PARAM_NAME9      in VARCHAR2,
   X_PARAM_VALUE9     in VARCHAR2,
   X_PARAM_NAME10     in VARCHAR2,
   X_PARAM_VALUE10    in VARCHAR2,
   X_LAST_UPDATE_DATE in VARCHAR2,
   X_CUSTOM_MODE      in VARCHAR2,
   X_OWNER            in VARCHAR2
   )
is
  l_proc                   VARCHAR2(31) := 'HR_KI_TIS_LOAD_API.LOAD_ROW';
  l_rowid                  rowid;
  l_created_by             HR_KI_TOPIC_INTEGRATIONS.created_by%TYPE         := 0;
  l_creation_date          HR_KI_TOPIC_INTEGRATIONS.creation_date%TYPE      := SYSDATE;
  l_last_update_date       HR_KI_TOPIC_INTEGRATIONS.last_update_date%TYPE   := SYSDATE;
  l_last_updated_by        HR_KI_TOPIC_INTEGRATIONS.last_updated_by%TYPE    := 0;
  l_last_update_login      HR_KI_TOPIC_INTEGRATIONS.last_update_login%TYPE  := 0;
  l_topic_integrations_id  HR_KI_TOPIC_INTEGRATIONS.topic_integrations_id%TYPE;
  l_object_version_number  HR_KI_TOPIC_INTEGRATIONS.object_version_number%TYPE;
  l_topic_id               HR_KI_TOPICS.topic_id%TYPE;
  l_integration_id         HR_KI_INTEGRATIONS.integration_id%TYPE;
  db_luby                  number;  -- entity owner in db
  db_ludate                date;    -- entity update date in db
--
  CURSOR C_APPL IS
    select tpi.topic_integrations_id,
           nvl(tpi.object_version_number,1)
      from hr_ki_topic_integrations tpi,
           hr_ki_topics top,
           hr_ki_integrations int
     where tpi.topic_id        = top.topic_id
       and tpi.integration_id  = int.integration_id
       and top.topic_key       = X_TOPIC_KEY
       and int.integration_key = X_INTEGRATION_KEY;
--
  X_CURRENT_OWNER              NUMBER;
  X_CURRENT_LAST_UPDATE_DATE   HR_KI_TOPIC_INTEGRATIONS.last_update_date%TYPE;
--
  begin
  --
  -- added for 5354277
     hr_general.g_data_migrator_mode := 'Y';
  --
  -- validate parent_hierarchy_key
  --
  validate_keys(
   X_TOPIC_KEY       => X_TOPIC_KEY
  ,X_INTEGRATION_KEY => X_INTEGRATION_KEY
  ,X_TOPIC_ID        => l_topic_id
  ,X_INTEGRATION_ID  => l_integration_id
  );
  -- Translate owner to file_last_updated_by
  l_last_updated_by := fnd_load_util.owner_id(X_OWNER);
  l_created_by      := fnd_load_util.owner_id(X_OWNER);
  -- Translate char last_update_date to date
  l_last_update_date := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD hh24:mi:ss'), sysdate);
  --
  -- Update or insert row as appropriate
  --
  OPEN  C_APPL;
  FETCH C_APPL INTO l_topic_integrations_id,l_object_version_number;
  --
  if C_APPL%notfound then
     close C_APPL;
  -- Row does not exists in the database.
     INSERT_ROW
      (X_ROWID                  => l_rowid
      ,X_TOPIC_INTEGRATIONS_ID  => l_topic_integrations_id
      ,X_TOPIC_ID               => l_topic_id
      ,X_INTEGRATION_ID         => l_integration_id
      ,X_PARAM_NAME1            => X_PARAM_NAME1
      ,X_PARAM_VALUE1           => X_PARAM_VALUE1
      ,X_PARAM_NAME2            => X_PARAM_NAME2
      ,X_PARAM_VALUE2           => X_PARAM_VALUE2
      ,X_PARAM_NAME3            => X_PARAM_NAME3
      ,X_PARAM_VALUE3           => X_PARAM_VALUE3
      ,X_PARAM_NAME4            => X_PARAM_NAME4
      ,X_PARAM_VALUE4           => X_PARAM_VALUE4
      ,X_PARAM_NAME5            => X_PARAM_NAME5
      ,X_PARAM_VALUE5           => X_PARAM_VALUE5
      ,X_PARAM_NAME6            => X_PARAM_NAME6
      ,X_PARAM_VALUE6           => X_PARAM_VALUE6
      ,X_PARAM_NAME7            => X_PARAM_NAME7
      ,X_PARAM_VALUE7           => X_PARAM_VALUE7
      ,X_PARAM_NAME8            => X_PARAM_NAME8
      ,X_PARAM_VALUE8           => X_PARAM_VALUE8
      ,X_PARAM_NAME9            => X_PARAM_NAME9
      ,X_PARAM_VALUE9           => X_PARAM_VALUE9
      ,X_PARAM_NAME10           => X_PARAM_NAME10
      ,X_PARAM_VALUE10          => X_PARAM_VALUE10
      ,X_CREATED_BY             => l_created_by
      ,X_CREATION_DATE          => l_creation_date
      ,X_LAST_UPDATE_DATE       => l_last_update_date
      ,X_LAST_UPDATED_BY        => l_last_updated_by
      ,X_LAST_UPDATE_LOGIN      => l_last_update_login
      );
  else
  close C_APPL;
    SELECT tis.LAST_UPDATED_BY,
           tis.LAST_UPDATE_DATE
      INTO X_CURRENT_OWNER,
           X_CURRENT_LAST_UPDATE_DATE
      FROM HR_KI_TOPIC_INTEGRATIONS tis
     WHERE tis.topic_id = l_topic_id
       AND tis.integration_id = l_integration_id;
    --
    if (FND_LOAD_UTIL.UPLOAD_TEST
         (P_FILE_ID              => l_last_updated_by
         ,P_FILE_LUD             => l_last_update_date
         ,P_DB_ID                => X_CURRENT_OWNER
         ,P_DB_LUD               => to_date(X_CURRENT_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
         ,P_CUSTOM_MODE          => X_CUSTOM_MODE
         )
       ) then
      UPDATE_ROW
      (X_TOPIC_INTEGRATIONS_ID  => l_topic_integrations_id
      ,X_TOPIC_ID               => l_topic_id
      ,X_INTEGRATION_ID         => l_integration_id
      ,X_PARAM_NAME1            => X_PARAM_NAME1
      ,X_PARAM_VALUE1           => X_PARAM_VALUE1
      ,X_PARAM_NAME2            => X_PARAM_NAME2
      ,X_PARAM_VALUE2           => X_PARAM_VALUE2
      ,X_PARAM_NAME3            => X_PARAM_NAME3
      ,X_PARAM_VALUE3           => X_PARAM_VALUE3
      ,X_PARAM_NAME4            => X_PARAM_NAME4
      ,X_PARAM_VALUE4           => X_PARAM_VALUE4
      ,X_PARAM_NAME5            => X_PARAM_NAME5
      ,X_PARAM_VALUE5           => X_PARAM_VALUE5
      ,X_PARAM_NAME6            => X_PARAM_NAME6
      ,X_PARAM_VALUE6           => X_PARAM_VALUE6
      ,X_PARAM_NAME7            => X_PARAM_NAME7
      ,X_PARAM_VALUE7           => X_PARAM_VALUE7
      ,X_PARAM_NAME8            => X_PARAM_NAME8
      ,X_PARAM_VALUE8           => X_PARAM_VALUE8
      ,X_PARAM_NAME9            => X_PARAM_NAME9
      ,X_PARAM_VALUE9           => X_PARAM_VALUE9
      ,X_PARAM_NAME10           => X_PARAM_NAME10
      ,X_PARAM_VALUE10          => X_PARAM_VALUE10
      ,X_CREATED_BY             => l_created_by
      ,X_CREATION_DATE          => l_creation_date
      ,X_LAST_UPDATE_DATE       => l_last_update_date
      ,X_LAST_UPDATED_BY        => l_last_updated_by
      ,X_LAST_UPDATE_LOGIN      => l_last_update_login
      ,X_OBJECT_VERSION_NUMBER  => l_object_version_number + 1
      );
    end if;
  end if;
--
end LOAD_ROW;
END HR_KI_TIS_LOAD_API;

/
