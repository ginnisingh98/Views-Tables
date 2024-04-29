--------------------------------------------------------
--  DDL for Package Body JTF_IH_ACT_ACT_ITMS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_ACT_ACT_ITMS_SEED_PKG" as
/* $Header: JTFIHAAB.pls 120.2 2005/07/08 07:50:47 nchouras ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_ACTION_ITEM_ID in NUMBER,
  X_DEFAULT_WRAP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
  ) is
  cursor C is select ROWID from JTF_IH_ACTION_ACTION_ITEMS
    where ACTION_ID = X_ACTION_ID
    AND ACTION_ITEM_ID = X_ACTION_ITEM_ID
    ;
begin
  insert into JTF_IH_ACTION_ACTION_ITEMS (
    ACTION_ID,
    ACTION_ITEM_ID,
    DEFAULT_WRAP_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ACTION_ID,
    X_ACTION_ITEM_ID,
    X_DEFAULT_WRAP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
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
  X_ACTION_ID in NUMBER,
  X_ACTION_ITEM_ID in NUMBER,
  X_DEFAULT_WRAP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from JTF_IH_ACTION_ACTION_ITEMS
    where ACTION_ID = X_ACTION_ID AND ACTION_ITEM_ID = X_ACTION_ITEM_ID
    for update of ACTION_ID, ACTION_ITEM_ID nowait;
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
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

  /* RDD - Bug 3772863 - Need to insure that the new default wrap_id is applyed to an existing row */
procedure UPDATE_ROW (
  X_ACTION_ID in NUMBER,
  X_ACTION_ITEM_ID in NUMBER,
  X_DEFAULT_WRAP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  -- RDD - Bug 3772863 - Cursoe to get the existing value.  If it is not null, then use in place of passed ID
  cursor C is select DEFAULT_WRAP_ID,LAST_UPDATED_BY
     from JTF_IH_ACTION_ACTION_ITEMS
     where ACTION_ID = X_ACTION_ID AND
           ACTION_ITEM_ID = X_ACTION_ITEM_ID;
  l_default_wrap_id NUMBER;
  l_last_updated_by NUMBER;

begin
 -- RDD - Bug 3772863 - Get the rows current default ID
  open c;
  fetch c into l_default_wrap_id, l_last_updated_by;

 -- RDD - Bug 3772863 - If the row was not found, then don't do the update.
  if (c%notfound) then
    raise no_data_found;
  end if;

  -- RDD - Bug 3772863 - determine if the value on the row is null or empty, then set to what is in the loader
  if ((l_default_wrap_id is null) or (TRIM(l_default_wrap_id) = '')) then
     -- set the default to what is passed
     l_default_wrap_id := X_DEFAULT_WRAP_ID;
  else
     -- RDD Bug 3772863 - If the value is not null or empty and has not been changed
     -- via the IH admin in the instance, then set to new seeded value from loader
     if (l_last_updated_by = X_LAST_UPDATED_BY) then
        l_default_wrap_id := X_DEFAULT_WRAP_ID;
     end if;
  end if;


  update JTF_IH_ACTION_ACTION_ITEMS set
    DEFAULT_WRAP_ID = l_default_wrap_id,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ACTION_ID = X_ACTION_ID
    AND ACTION_ITEM_ID = X_ACTION_ITEM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACTION_ID in NUMBER,
  X_ACTION_ITEM_ID in NUMBER
) is
begin
  delete from JTF_IH_ACTION_ACTION_ITEMS
  where ACTION_ID = X_ACTION_ID AND ACTION_ITEM_ID = X_ACTION_ITEM_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
  X_ACTION_ID in NUMBER,
  X_ACTION_ITEM_ID in NUMBER,
  X_DEFAULT_WRAP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER IN VARCHAR2
) IS
	l_user_id	           NUMBER := 0;
    	l_login_id       	   NUMBER := 0;
	l_row_id			ROWID;
  	l_action_id 		NUMBER;
    l_action_item_id    NUMBER;
    l_default_wrap_id   NUMBER;
  	l_object_version_number NUMBER;
	l_creation_date		DATE;
	l_created_by		NUMBER;
begin
	if (x_owner = 'SEED') then
	    --l_user_id := 1;
	    l_login_id := 0;
        else
            --l_user_id := fnd_global.user_id;
	    l_login_id := fnd_global.login_id;
	end if;

        l_user_id := fnd_load_util.owner_id(x_owner);
  	l_action_id := X_ACTION_ID;
  	l_action_item_id := X_ACTION_ITEM_ID;
        l_default_wrap_id := X_DEFAULT_WRAP_ID;

    IF X_OBJECT_VERSION_NUMBER IS NULL THEN
  	     l_object_version_number := 1;
    ELSE
        l_object_version_number := X_OBJECT_VERSION_NUMBER;
    END IF;

	UPDATE_ROW(
  			X_ACTION_ID => l_action_id,
  			X_ACTION_ITEM_ID => l_action_item_id,
            X_DEFAULT_WRAP_ID => l_default_wrap_id,
			X_OBJECT_VERSION_NUMBER => l_object_version_number,
  			X_LAST_UPDATE_DATE => SYSDATE,
  			X_LAST_UPDATED_BY =>  l_user_id,
  			X_LAST_UPDATE_LOGIN => l_login_id);
	EXCEPTION
		when no_data_found then
			INSERT_ROW(
			l_row_id,
  			X_ACTION_ID => l_action_id,
  			X_ACTION_ITEM_ID => l_action_item_id,
            X_DEFAULT_WRAP_ID => l_default_wrap_id,
  			X_OBJECT_VERSION_NUMBER => l_object_version_number,
			X_CREATION_DATE => SYSDATE,
			X_CREATED_BY => l_user_id,
  			X_LAST_UPDATE_DATE => sysdate,
  			X_LAST_UPDATED_BY => l_user_id,
  			X_LAST_UPDATE_LOGIN => l_login_id);
end LOAD_ROW;

procedure LOAD_SEED_ROW (
  X_ACTION_ID in NUMBER,
  X_ACTION_ITEM_ID in NUMBER,
  X_DEFAULT_WRAP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER IN VARCHAR2,
  X_UPLOAD_MODE IN VARCHAR2
) IS
BEGIN
	JTF_IH_ACT_ACT_ITMS_SEED_PKG.LOAD_ROW (
                        X_ACTION_ID,
                        X_ACTION_ITEM_ID,
                        X_DEFAULT_WRAP_ID,
                        X_OBJECT_VERSION_NUMBER,
                        X_OWNER);
END LOAD_SEED_ROW;

end JTF_IH_ACT_ACT_ITMS_SEED_PKG;

/
