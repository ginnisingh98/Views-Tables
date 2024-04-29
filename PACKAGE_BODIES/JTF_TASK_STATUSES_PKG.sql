--------------------------------------------------------
--  DDL for Package Body JTF_TASK_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_STATUSES_PKG" as
/* $Header: jtftkstb.pls 120.2.12010000.2 2009/03/26 11:27:05 anangupt ship $ */
procedure INSERT_ROW(
  X_ROWID in out NOCOPY VARCHAR2,
  X_TASK_STATUS_ID in NUMBER,
  X_CLOSED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SEEDED_FLAG in VARCHAR2,
  X_ASSIGNED_FLAG in VARCHAR2,
  X_WORKING_FLAG in VARCHAR2,
  X_APPROVED_FLAG in VARCHAR2,
  X_COMPLETED_FLAG in VARCHAR2,
  X_CANCELLED_FLAG in VARCHAR2,
  X_REJECTED_FLAG in VARCHAR2,
  X_ACCEPTED_FLAG in VARCHAR2,
  X_ON_HOLD_FLAG in VARCHAR2,
  X_SCHEDULABLE_FLAG in VARCHAR2,
  X_DELETE_ALLOWED_FLAG in VARCHAR2,
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
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
--  X_UPDATE in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_TASK_STATUS_FLAG in VARCHAR2,
  X_ASSIGNMENT_STATUS_FLAG in VARCHAR2,
  X_START_DATE_TYPE IN VARCHAR2,
  X_END_DATE_TYPE IN VARCHAR2,
  X_TRAVEL_FLAG IN VARCHAR2 DEFAULT NULL,
  X_PLANNED_FLAG IN VARCHAR2 DEFAULT NULL,
  X_ENFORCE_VALIDATION_FLAG IN VARCHAR2 DEFAULT NULL,
  X_VALIDATION_START_DATE IN DATE DEFAULT NULL,
  X_VALIDATION_END_DATE IN  DATE DEFAULT NULL
) is
  cursor C is select ROWID from JTF_TASK_STATUSES_B
    where TASK_STATUS_ID = X_TASK_STATUS_ID
    ;
begin
  insert into JTF_TASK_STATUSES_B (
    TASK_STATUS_ID,
    CLOSED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    SEEDED_FLAG,
    ASSIGNED_FLAG,
    WORKING_FLAG,
    APPROVED_FLAG,
    COMPLETED_FLAG,
    CANCELLED_FLAG,
    REJECTED_FLAG,
    ACCEPTED_FLAG,
    ON_HOLD_FLAG,
    SCHEDULABLE_FLAG,
    DELETE_ALLOWED_FLAG,
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
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    USAGE,
    TASK_STATUS_FLAG,
    ASSIGNMENT_STATUS_FLAG,
    START_DATE_TYPE,
    END_DATE_TYPE,
    TRAVEL_FLAG,
    PLANNED_FLAG,
    ENFORCE_VALIDATION_FLAG,
    VALIDATION_START_DATE,
    VALIDATION_END_DATE
  ) values (
    X_TASK_STATUS_ID,
    X_CLOSED_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_SEEDED_FLAG,
    X_ASSIGNED_FLAG,
    X_WORKING_FLAG,
    X_APPROVED_FLAG,
    X_COMPLETED_FLAG,
    X_CANCELLED_FLAG,
    X_REJECTED_FLAG,
    X_ACCEPTED_FLAG,
    X_ON_HOLD_FLAG,
    X_SCHEDULABLE_FLAG,
    X_DELETE_ALLOWED_FLAG,
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
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1,
    X_USAGE,
    X_TASK_STATUS_FLAG,
    X_ASSIGNMENT_STATUS_FLAG,
    X_START_DATE_TYPE,
    X_END_DATE_TYPE,
    X_TRAVEL_FLAG,
    X_PLANNED_FLAG,
    X_ENFORCE_VALIDATION_FLAG,
    X_VALIDATION_START_DATE,
    X_VALIDATION_END_DATE
  );

  insert into JTF_TASK_STATUSES_TL (
    TASK_STATUS_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TASK_STATUS_ID,
    X_NAME,
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
    from JTF_TASK_STATUSES_TL T
    where T.TASK_STATUS_ID = X_TASK_STATUS_ID
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
  X_TASK_STATUS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
        OBJECT_VERSION_NUMBER
    from JTF_TASK_ALL_STATUSES_VL
    where TASK_STATUS_ID = X_TASK_STATUS_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of TASK_STATUS_ID nowait;
  recinfo c%rowtype;


begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_TASK_STATUS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CLOSED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SEEDED_FLAG in VARCHAR2,
  X_ASSIGNED_FLAG in VARCHAR2,
  X_WORKING_FLAG in VARCHAR2,
  X_APPROVED_FLAG in VARCHAR2,
  X_COMPLETED_FLAG in VARCHAR2,
  X_CANCELLED_FLAG in VARCHAR2,
  X_REJECTED_FLAG in VARCHAR2,
  X_ACCEPTED_FLAG in VARCHAR2,
  X_ON_HOLD_FLAG in VARCHAR2,
  X_SCHEDULABLE_FLAG in VARCHAR2,
  X_DELETE_ALLOWED_FLAG in VARCHAR2,
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
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_USAGE in varchar2,
  X_TASK_STATUS_FLAG in VARCHAR2,
  X_ASSIGNMENT_STATUS_FLAG in VARCHAR2,
  X_START_DATE_TYPE IN VARCHAR2 DEFAULT NULL,
  X_END_DATE_TYPE IN VARCHAR2 DEFAULT NULL,
  X_TRAVEL_FLAG IN VARCHAR2 DEFAULT NULL,
  X_PLANNED_FLAG IN VARCHAR2 DEFAULT NULL ,
  X_ENFORCE_VALIDATION_FLAG IN VARCHAR2 DEFAULT NULL ,
  X_VALIDATION_START_DATE IN DATE DEFAULT NULL ,
  X_VALIDATION_END_DATE IN DATE DEFAULT NULL
) is
begin
  update JTF_TASK_STATUSES_B set
    CLOSED_FLAG = X_CLOSED_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER + 1,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    SEEDED_FLAG = X_SEEDED_FLAG,
    ASSIGNED_FLAG = X_ASSIGNED_FLAG,
    WORKING_FLAG = X_WORKING_FLAG,
    APPROVED_FLAG = X_APPROVED_FLAG,
    COMPLETED_FLAG = X_COMPLETED_FLAG,
    CANCELLED_FLAG = X_CANCELLED_FLAG,
    REJECTED_FLAG = X_REJECTED_FLAG,
    ACCEPTED_FLAG = X_ACCEPTED_FLAG,
    ON_HOLD_FLAG = X_ON_HOLD_FLAG,
    SCHEDULABLE_FLAG = X_SCHEDULABLE_FLAG,
    DELETE_ALLOWED_FLAG = X_DELETE_ALLOWED_FLAG,
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
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    USAGE = X_USAGE,
    TASK_STATUS_FLAG =  X_TASK_STATUS_FLAG,
    ASSIGNMENT_STATUS_FLAG = X_ASSIGNMENT_STATUS_FLAG,
    START_DATE_TYPE = X_START_DATE_TYPE,
    END_DATE_TYPE = X_END_DATE_TYPE,
    TRAVEL_FLAG = X_TRAVEL_FLAG,
    PLANNED_FLAG = X_PLANNED_FLAG,
    ENFORCE_VALIDATION_FLAG = X_ENFORCE_VALIDATION_FLAG,
    VALIDATION_START_DATE = X_VALIDATION_START_DATE,
    VALIDATION_END_DATE = X_VALIDATION_END_DATE
  where TASK_STATUS_ID = X_TASK_STATUS_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- Added Index Hint on 30/05/2006 for bug# 5213367
  update /*+ INDEX(a JTF_TASK_STATUSES_TL_U1) */ JTF_TASK_STATUSES_TL a set
    a.NAME = X_NAME,
    a.DESCRIPTION = X_DESCRIPTION,
    a.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    a.LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    a.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    a.SOURCE_LANG = userenv('LANG')
  where a.TASK_STATUS_ID = X_TASK_STATUS_ID
  and userenv('LANG') in (a.LANGUAGE, a.SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TASK_STATUS_ID in NUMBER
) is
begin
  delete from JTF_TASK_STATUSES_TL
  where TASK_STATUS_ID = X_TASK_STATUS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_TASK_STATUSES_B
  where TASK_STATUS_ID = X_TASK_STATUS_ID  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin

 /* Solving Perf. Bug 3723927 */
     /* The following delete and update statements are commented out */
     /* as a quick workaround to fix the time-consuming table handler issue */

 /* delete from JTF_TASK_STATUSES_TL T
  where not exists
    (select NULL
    from JTF_TASK_STATUSES_B B
    where B.TASK_STATUS_ID = T.TASK_STATUS_ID
    );

  update JTF_TASK_STATUSES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from JTF_TASK_STATUSES_TL B
    where B.TASK_STATUS_ID = T.TASK_STATUS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TASK_STATUS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TASK_STATUS_ID,
      SUBT.LANGUAGE
    from JTF_TASK_STATUSES_TL SUBB, JTF_TASK_STATUSES_TL SUBT
    where SUBB.TASK_STATUS_ID = SUBT.TASK_STATUS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));  */

  insert into JTF_TASK_STATUSES_TL (
    TASK_STATUS_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ INDEX(b JTF_TASK_STATUSES_TL_U1) INDEX (l FND_LANGUAGES_N1) */ -- Added Index Hint on 30/05/2006 for bug# 5213367
    B.TASK_STATUS_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_TASK_STATUSES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_TASK_STATUSES_TL T
    where T.TASK_STATUS_ID = B.TASK_STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_TASK_STATUS_ID in varchar2,
  X_NAME in varchar2,
  X_DESCRIPTION in varchar2,
  X_OWNER in varchar2) is
l_user_id                 NUMBER := 0;
   BEGIN
      IF x_owner = 'SEED'
      THEN
         l_user_id := 1;
      END IF;

  -- Added Index Hint on 30/05/2006 for bug# 5213367
  update /*+ INDEX(a JTF_TASK_STATUSES_TL_U1) */ jtf_task_statuses_tl a set
    a.NAME= nvl(X_NAME, a.name) ,
    a.DESCRIPTION= nvl(X_DESCRIPTION, a.description),
    a.LAST_UPDATE_DATE = sysdate,
    a.LAST_UPDATE_LOGIN = 0,
    a.SOURCE_LANG = userenv('LANG'),
    a.LAST_UPDATED_BY = l_user_id
  where a.task_status_id = X_task_status_id
  and userenv('LANG') in (a.LANGUAGE, a.SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_TASK_STATUS_ID in NUMBER,
  X_CLOSED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SEEDED_FLAG in VARCHAR2,
  X_ASSIGNED_FLAG in VARCHAR2,
  X_WORKING_FLAG in VARCHAR2,
  X_APPROVED_FLAG in VARCHAR2,
  X_COMPLETED_FLAG in VARCHAR2,
  X_CANCELLED_FLAG in VARCHAR2,
  X_REJECTED_FLAG in VARCHAR2,
  X_ACCEPTED_FLAG in VARCHAR2,
  X_ON_HOLD_FLAG in VARCHAR2,
  X_SCHEDULABLE_FLAG in VARCHAR2,
  X_DELETE_ALLOWED_FLAG in VARCHAR2,
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
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_TASK_STATUS_FLAG in VARCHAR2,
  X_ASSIGNMENT_STATUS_FLAG in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_START_DATE_TYPE IN VARCHAR2,
  X_END_DATE_TYPE IN VARCHAR2,
  X_TRAVEL_FLAG IN VARCHAR2 DEFAULT NULL,
  X_PLANNED_FLAG IN VARCHAR2 DEFAULT NULL
  ) is

l_user_id                 NUMBER := 0;
      l_task_status_id            NUMBER;
      l_rowid                   ROWID;
      l_object_version_number   NUMBER;
   BEGIN

      IF x_owner = 'SEED'
      THEN
         l_user_id := 1;
      END IF;


      SELECT task_status_id, object_version_number
        INTO l_task_status_id, l_object_version_number
        FROM jtf_task_all_statuses_vl
       WHERE task_status_id = x_task_status_id;



 	update JTF_TASK_STATUSES_B set
   	 CLOSED_FLAG = X_CLOSED_FLAG,
         OBJECT_VERSION_NUMBER =  l_object_version_number + 1,
         START_DATE_ACTIVE = X_START_DATE_ACTIVE,
         END_DATE_ACTIVE = X_END_DATE_ACTIVE,
         SEEDED_FLAG = X_SEEDED_FLAG,
         ASSIGNED_FLAG = X_ASSIGNED_FLAG,
         WORKING_FLAG = X_WORKING_FLAG,
         APPROVED_FLAG = X_APPROVED_FLAG,
         COMPLETED_FLAG = X_COMPLETED_FLAG,
         CANCELLED_FLAG = X_CANCELLED_FLAG,
         REJECTED_FLAG = X_REJECTED_FLAG,
         ACCEPTED_FLAG = X_ACCEPTED_FLAG,
         ON_HOLD_FLAG = X_ON_HOLD_FLAG,
         SCHEDULABLE_FLAG = X_SCHEDULABLE_FLAG,
         DELETE_ALLOWED_FLAG = X_DELETE_ALLOWED_FLAG,
         LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = l_user_id,
         LAST_UPDATE_LOGIN = 0,
         USAGE = X_USAGE,
         TASK_STATUS_FLAG =  X_TASK_STATUS_FLAG,
         ASSIGNMENT_STATUS_FLAG = X_ASSIGNMENT_STATUS_FLAG,
         START_DATE_TYPE = X_START_DATE_TYPE,
         END_DATE_TYPE = X_END_DATE_TYPE,
         TRAVEL_FLAG = X_TRAVEL_FLAG,
         PLANNED_FLAG = X_PLANNED_FLAG
        where TASK_STATUS_ID = l_task_status_id ;

    -- Added Index Hint on 30/05/2006 for bug# 5213367
    update /*+ INDEX(a JTF_TASK_STATUSES_TL_U1) */ JTF_TASK_STATUSES_TL a set
       a.NAME = X_NAME,
       a.DESCRIPTION = X_DESCRIPTION,
       a.LAST_UPDATE_DATE = sysdate,
       a.LAST_UPDATED_BY = l_user_id,
       a.LAST_UPDATE_LOGIN = 0,
       a.SOURCE_LANG = userenv('LANG')
       where a.TASK_STATUS_ID = l_task_status_id
       and userenv('LANG') in (a.LANGUAGE, a.SOURCE_LANG);



exception
when no_data_found then

    jtf_task_statuses_pkg.insert_row (
        x_rowid => l_rowid ,
            x_task_status_id => x_task_status_id,
            x_closed_flag => x_closed_flag,
        x_start_date_active => x_start_date_active,
            x_end_date_active => x_end_date_active,
            x_seeded_flag => x_seeded_flag,
            x_assigned_flag => x_assigned_flag,
            x_working_flag => x_working_flag,
            x_approved_flag => x_approved_flag,
            x_completed_flag => x_completed_flag,
            x_cancelled_flag => x_cancelled_flag,
            x_rejected_flag => x_rejected_flag,
            x_accepted_flag => x_accepted_flag,
            x_on_hold_flag => x_on_hold_flag,
            x_schedulable_flag => x_schedulable_flag,
            x_delete_allowed_flag => x_delete_allowed_flag,
            x_task_status_flag =>  x_task_status_flag,
            x_assignment_status_flag =>  x_assignment_status_flag,
            x_usage => x_usage,
            x_attribute1 => x_attribute1,
            x_attribute2 => x_attribute2,
            x_attribute3 => x_attribute3,
            x_attribute4 => x_attribute4,
            x_attribute5 => x_attribute5,
            x_attribute6 => x_attribute6,
            x_attribute7 => x_attribute7,
            x_attribute8 => x_attribute8,
            x_attribute9 => x_attribute9,
            x_attribute10 => x_attribute10,
            x_attribute11 => x_attribute11,
            x_attribute12 => x_attribute12,
            x_attribute13 => x_attribute13,
            x_attribute14 => x_attribute14,
            x_attribute15 => x_attribute15,
            x_attribute_category => x_attribute_category,
            x_name => x_name,
            x_description => x_description,
            x_last_update_date => SYSDATE,
            x_last_updated_by => l_user_id,
            x_last_update_login => 0,
            x_creation_date => SYSDATE,
            x_created_by => l_user_id,
            x_start_date_type => x_start_date_type,
            x_end_date_type => x_end_date_type,
            x_travel_flag => x_travel_flag,
            x_planned_flag => x_planned_flag
         );

end ;

end JTF_TASK_STATUSES_PKG;

/
