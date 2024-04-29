--------------------------------------------------------
--  DDL for Package Body JTF_TASK_RECUR_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_RECUR_RULES_PKG" as
/* $Header: jtftkrrb.pls 115.16 2002/12/04 22:12:34 cjang ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RECURRENCE_RULE_ID in NUMBER,
  X_OCCURS_WHICH in NUMBER,
  X_DAY_OF_WEEK in NUMBER,
  X_DATE_OF_MONTH in NUMBER,
  X_OCCURS_MONTH in NUMBER,
  X_OCCURS_EVERY in NUMBER,
  X_OCCURS_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  X_OCCURS_UOM in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_sunday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_monday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_tuesday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_wednesday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_thursday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_friday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_saturday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_date_selected           IN       VARCHAR2 default null
  ) is
  cursor C is select ROWID from JTF_TASK_RECUR_RULES
    where RECURRENCE_RULE_ID = X_RECURRENCE_RULE_ID
    ;
begin
  insert into JTF_TASK_RECUR_RULES (
    RECURRENCE_RULE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OCCURS_WHICH,
    DAY_OF_WEEK,
    DATE_OF_MONTH,
    OCCURS_MONTH,
    OCCURS_UOM,
    OCCURS_EVERY,
    OCCURS_NUMBER,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
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
    OBJECT_VERSION_NUMBER,
    SUNDAY,
    MONDAY,
    TUESDAY,
    WEDNESDAY,
    THURSDAY,
    FRIDAY,
    SATURDAY,
    DATE_SELECTED
    ) values (
    X_RECURRENCE_RULE_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OCCURS_WHICH,
    X_DAY_OF_WEEK,
    X_DATE_OF_MONTH,
    X_OCCURS_MONTH,
    X_OCCURS_UOM,
    X_OCCURS_EVERY,
    X_OCCURS_NUMBER,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
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
    1,
    x_sunday,
    x_monday,
    x_tuesday,
    x_wednesday,
    x_thursday,
    x_friday,
    x_saturday,
    x_date_selected
    );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_RECURRENCE_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c1 is select
          OBJECT_VERSION_NUMBER
    from JTF_TASK_RECUR_RULES
    where RECURRENCE_RULE_ID = X_RECURRENCE_RULE_ID
    for update of RECURRENCE_RULE_ID nowait;
    tlinfo c1%rowtype ;
BEGIN
 open c1;
 fetch c1 into tlinfo;
      if (c1%notfound) then
            close c1;
		  fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
		  app_exception.raise_exception;
	 end if;
 close c1;

 if (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end LOCK_ROW;


procedure UPDATE_ROW (
  X_RECURRENCE_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OCCURS_WHICH in NUMBER,
  X_DAY_OF_WEEK in NUMBER,
  X_DATE_OF_MONTH in NUMBER,
  X_OCCURS_MONTH in NUMBER,
  X_OCCURS_EVERY in NUMBER,
  X_OCCURS_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  X_OCCURS_UOM in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_sunday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_monday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_tuesday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_wednesday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_thursday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_friday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_saturday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
  x_date_selected           IN       VARCHAR2 default null
  ) is
begin
  update JTF_TASK_RECUR_RULES set
    OCCURS_WHICH = X_OCCURS_WHICH,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER + 1,
    DAY_OF_WEEK = X_DAY_OF_WEEK,
    DATE_OF_MONTH = X_DATE_OF_MONTH,
    OCCURS_MONTH = X_OCCURS_MONTH,
    OCCURS_EVERY = X_OCCURS_EVERY,
    OCCURS_NUMBER = X_OCCURS_NUMBER,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
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
    OCCURS_UOM = X_OCCURS_UOM,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SUNDAY = X_SUNDAY,
    MONDAY = X_MONDAY,
    TUESDAY = X_TUESDAY,
    WEDNESDAY = X_WEDNESDAY,
    THURSDAY = X_THURSDAY,
    FRIDAY = X_FRIDAY,
    SATURDAY = X_SATURDAY,
    DATE_SELECTED = X_DATE_SELECTED
  where RECURRENCE_RULE_ID = X_RECURRENCE_RULE_ID
  and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER + 1 ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RECURRENCE_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
begin
  delete from JTF_TASK_RECUR_RULES
  where RECURRENCE_RULE_ID = X_RECURRENCE_RULE_ID
  and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end JTF_TASK_RECUR_RULES_PKG;

/
