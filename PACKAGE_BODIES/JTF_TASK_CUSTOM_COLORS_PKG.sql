--------------------------------------------------------
--  DDL for Package Body JTF_TASK_CUSTOM_COLORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_CUSTOM_COLORS_PKG" as
/* $Header: jtftkclb.pls 115.2 2002/12/04 02:27:56 sachoudh ship $ */
    procedure INSERT_ROW (
      X_ROWID in out nocopy VARCHAR2,
      X_RULE_ID in NUMBER,
      X_COLOR_DETERMINATION_PRIORITY in NUMBER,
      X_TYPE_ID in NUMBER,
      X_PRIORITY_ID in NUMBER,
      X_ASSIGNMENT_STATUS_ID in NUMBER,
      X_ESCALATED_TASK in VARCHAR2,
      X_ACTIVE_FLAG in VARCHAR2,
      X_BACKGROUND_COL_DEC in NUMBER,
      X_BACKGROUND_COL_RGB in VARCHAR2,
      X_CREATION_DATE in DATE,
      X_CREATED_BY in NUMBER,
      X_LAST_UPDATE_DATE in DATE,
      X_LAST_UPDATED_BY in NUMBER,
      X_LAST_UPDATE_LOGIN in NUMBER
    ) is
      cursor C is select ROWID from JTF_TASK_CUSTOM_COLORS
        where RULE_ID = X_RULE_ID
        ;
    begin
      insert into JTF_TASK_CUSTOM_COLORS (
        RULE_ID,
        OBJECT_VERSION_NUMBER,
        COLOR_DETERMINATION_PRIORITY,
        TYPE_ID,
        PRIORITY_ID,
        ASSIGNMENT_STATUS_ID,
        ESCALATED_TASK,
        BACKGROUND_COL_DEC,
        BACKGROUND_COL_RGB,
        ACTIVE_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
      ) values (
        X_RULE_ID,
        1,
        X_COLOR_DETERMINATION_PRIORITY,
        X_TYPE_ID,
        X_PRIORITY_ID,
        X_ASSIGNMENT_STATUS_ID,
        X_ESCALATED_TASK,
        X_BACKGROUND_COL_DEC,
        X_BACKGROUND_COL_RGB,
        X_ACTIVE_FLAG,
        X_CREATED_BY,
        X_CREATION_DATE,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_DATE,
        X_LAST_UPDATE_LOGIN
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
      X_RULE_ID in NUMBER,
      X_OBJECT_VERSION_NUMBER in NUMBER
    ) is
      cursor c1 is select
          OBJECT_VERSION_NUMBER
        from JTF_TASK_CUSTOM_COLORS
        where RULE_ID = X_RULE_ID
        for update of RULE_ID nowait;

      recinfo c1%rowtype;

      e_resource_busy exception;
      pragma exception_init(e_resource_busy, -54);

    begin
      open c1;
      fetch c1 into recinfo;

      if (c1%notfound) then
        close c1;
        fnd_message.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
        app_exception.raise_exception;
      end if;
      close c1;

      IF (recinfo.object_version_number <> x_object_version_number)
      THEN
        fnd_message.set_name ('JTF', 'JTF_API_RECORD_NOT_FOUND');
        fnd_msg_pub.add;
        app_exception.raise_exception;
      END IF;

    exception
      when e_resource_busy then
         fnd_message.set_name('FND', 'FND_LOCK_RECORD_ERROR');
         fnd_msg_pub.add;
         app_exception.raise_exception;
    end LOCK_ROW;

    procedure UPDATE_ROW (
      X_RULE_ID in NUMBER,
      X_OBJECT_VERSION_NUMBER in NUMBER,
      X_COLOR_DETERMINATION_PRIORITY in NUMBER,
      X_TYPE_ID in NUMBER,
      X_PRIORITY_ID in NUMBER,
      X_ASSIGNMENT_STATUS_ID in NUMBER,
      X_ESCALATED_TASK in VARCHAR2,
      X_ACTIVE_FLAG in VARCHAR2,
      X_BACKGROUND_COL_DEC in NUMBER,
      X_BACKGROUND_COL_RGB in VARCHAR2,
      X_LAST_UPDATE_DATE in DATE,
      X_LAST_UPDATED_BY in NUMBER,
      X_LAST_UPDATE_LOGIN in NUMBER
    ) is
    begin
      update JTF_TASK_CUSTOM_COLORS set
        OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
        COLOR_DETERMINATION_PRIORITY = X_COLOR_DETERMINATION_PRIORITY,
        TYPE_ID = X_TYPE_ID,
        PRIORITY_ID = X_PRIORITY_ID,
        ASSIGNMENT_STATUS_ID = X_ASSIGNMENT_STATUS_ID,
        ESCALATED_TASK = X_ESCALATED_TASK,
        ACTIVE_FLAG = X_ACTIVE_FLAG,
        BACKGROUND_COL_DEC = X_BACKGROUND_COL_DEC,
        BACKGROUND_COL_RGB = X_BACKGROUND_COL_RGB,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
      where RULE_ID = X_RULE_ID;

      if (sql%notfound) then
        raise no_data_found;
      end if;
    end UPDATE_ROW;

    procedure DELETE_ROW (
      X_RULE_ID in NUMBER
    ) is
    begin
      delete from JTF_TASK_CUSTOM_COLORS
      where RULE_ID = X_RULE_ID;

      if (sql%notfound) then
        raise no_data_found;
      end if;

    end DELETE_ROW;

end JTF_TASK_CUSTOM_COLORS_PKG;

/
