--------------------------------------------------------
--  DDL for Package Body HR_KI_HNM_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_HNM_LOAD_API" as
/* $Header: hrkihnml.pkb 120.1 2006/06/27 15:59:48 avarri noship $ */
--
-- Package Variables
--
g_package  varchar2(31) := 'HR_KI_HNM_LOAD_API';
--

procedure INSERT_ROW (
  X_ROWID                   in out nocopy VARCHAR2,
  X_hierarchy_node_map_id   in out nocopy NUMBER,
  X_TOPIC_ID                in NUMBER,
  X_HIERARCHY_ID            in NUMBER,
  X_USER_INTERFACE_ID       in number,
  X_CREATED_BY              in NUMBER,
  X_CREATION_DATE           in DATE,
  X_LAST_UPDATE_DATE        in DATE,
  X_LAST_UPDATED_BY         in NUMBER,
  X_LAST_UPDATE_LOGIN       in NUMBER

) is

  cursor C is select ROWID from HR_KI_HIERARCHY_NODE_MAPS
    where hierarchy_node_map_id = x_hierarchy_node_map_id;

begin

select HR_KI_HIERARCHY_NODE_MAPS_S.NEXTVAL into x_hierarchy_node_map_id from sys.dual;

  insert into HR_KI_HIERARCHY_NODE_MAPS (
    hierarchy_node_map_id,
    TOPIC_ID,
    HIERARCHY_ID,
    USER_INTERFACE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_hierarchy_node_map_id,
    X_TOPIC_ID,
    X_HIERARCHY_ID,
    X_USER_INTERFACE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
      close c;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'HR_KI_HIERARCHY_NODE_MAPS.insert_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  close c;


end INSERT_ROW;

procedure validate_keys
(
 X_TOPIC_KEY          VARCHAR2
,X_HIERARCHY_KEY      VARCHAR2
,X_USER_INTERFACE_KEY VARCHAR2
,X_TOPIC_ID           in out nocopy number
,X_HIERARCHY_ID       in out nocopy number
,X_USER_INTERFACE_ID  in out nocopy number

)
is

  l_proc VARCHAR2(35) := 'HR_KI_HNM_LOAD_API.VALIDATE_KEYS';

  CURSOR C_VAL_TPC IS
        select topic_id
        from HR_KI_TOPICS
        where upper(topic_key) = upper(X_TOPIC_KEY);

  CURSOR C_VAL_HI IS
        select HIERARCHY_ID
        from HR_KI_HIERARCHIES
        where upper(HIERARCHY_KEY) = upper(X_HIERARCHY_KEY);

  CURSOR C_VAL_UI IS
        select USER_INTERFACE_ID
        from HR_KI_USER_INTERFACES
        where upper(USER_INTERFACE_KEY) = upper(X_USER_INTERFACE_KEY);
begin

   if X_TOPIC_KEY is not null then
           open C_VAL_TPC;
           fetch C_VAL_TPC into X_TOPIC_ID;

           If C_VAL_TPC%NOTFOUND then
              close C_VAL_TPC;
              fnd_message.set_name( 'PER','PER_449923_HNM_TPCPRNT_ABSNT');
              fnd_message.raise_error;
           End If;

           close C_VAL_TPC;
   end if;


   if X_HIERARCHY_KEY is not null then
           open C_VAL_HI;
           fetch C_VAL_HI into X_HIERARCHY_ID;

           If C_VAL_HI%NOTFOUND then
              close C_VAL_HI;
              fnd_message.set_name( 'PER','PER_449922_HNM_HRCPRNT_ABSNT');
              fnd_message.raise_error;
           End If;

           close C_VAL_HI;
   end if;

   if X_USER_INTERFACE_KEY is not null then
           open C_VAL_UI;
           fetch C_VAL_UI into X_USER_INTERFACE_ID;

           If C_VAL_UI%NOTFOUND then
              close C_VAL_UI;
              fnd_message.set_name( 'PER','PER_449924_HNM_INTPRNT_ABSNT');
              fnd_message.raise_error;
           End If;

           close C_VAL_UI;
   end if;

end validate_keys;

procedure LOAD_ROW
  (
   X_HIERARCHY_KEY      in VARCHAR2,
   X_TOPIC_KEY          in VARCHAR2,
   X_USER_INTERFACE_KEY in VARCHAR2,
   X_LAST_UPDATE_DATE   in VARCHAR2,
   X_CUSTOM_MODE        in VARCHAR2,
   X_OWNER              in VARCHAR2
   )
is
  l_proc               VARCHAR2(31) := 'HR_KI_HNM_LOAD_API.LOAD_ROW';
  l_rowid              rowid;
  l_created_by         HR_KI_HIERARCHY_NODE_MAPS.created_by%TYPE             := 0;
  l_creation_date      HR_KI_HIERARCHY_NODE_MAPS.creation_date%TYPE          := SYSDATE;
  l_last_update_date   HR_KI_HIERARCHY_NODE_MAPS.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by    HR_KI_HIERARCHY_NODE_MAPS.last_updated_by%TYPE         := 0;
  l_last_update_login  HR_KI_HIERARCHY_NODE_MAPS.last_update_login%TYPE       := 0;
  l_hierarchy_node_map_id       HR_KI_HIERARCHY_NODE_MAPS.hierarchy_node_map_id%TYPE;


  l_topic_id HR_KI_TOPICS.topic_id%TYPE;
  l_hierarchy_id HR_KI_HIERARCHIES.hierarchy_id%TYPE;
  l_user_interface_id HR_KI_USER_INTERFACES.user_interface_id%TYPE;

  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

  CURSOR C_APPL IS
  select nm.hierarchy_node_map_id
        from hr_ki_hierarchy_node_maps nm,
        hr_ki_hierarchies h,
        hr_ki_topics top
   where nm.hierarchy_id = h.hierarchy_id
     and nm.topic_id = top.topic_id
     and
          top.topic_key = x_topic_key
     and
     h.hierarchy_key = x_hierarchy_key

   union
   select nm.hierarchy_node_map_id
        from hr_ki_hierarchy_node_maps nm,
        hr_ki_topics top,
        hr_ki_user_interfaces ui
   where nm.topic_id = top.topic_id
     and nm.user_interface_id = ui.user_interface_id
     and top.topic_key = x_topic_key
               and ui.user_interface_key =x_user_interface_key

   union
   select nm.hierarchy_node_map_id
   from hr_ki_hierarchy_node_maps nm,
        hr_ki_user_interfaces ui,
        hr_ki_hierarchies hi
   where nm.hierarchy_id = hi.hierarchy_id
     and nm.user_interface_id = ui.user_interface_id
               and ui.user_interface_key = x_user_interface_key
               and hi.hierarchy_key = x_hierarchy_key;

  begin
  --
  -- added for 5354277
     hr_general.g_data_migrator_mode := 'Y';
  --
  --validate keys
  validate_keys(
   X_TOPIC_KEY            => X_TOPIC_KEY
  ,X_HIERARCHY_KEY        => X_HIERARCHY_KEY
  ,X_USER_INTERFACE_KEY   => X_USER_INTERFACE_KEY
  ,X_TOPIC_ID             => l_topic_id
  ,X_HIERARCHY_ID         => l_hierarchy_id
  ,X_USER_INTERFACE_ID    => l_user_interface_id
  );

  -- Translate owner to file_last_updated_by
  l_last_updated_by := fnd_load_util.owner_id(X_OWNER);
  l_created_by := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  l_last_update_date := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD hh24:mi:ss'), sysdate);


  -- Update or insert row as appropriate

  OPEN C_APPL;
  FETCH C_APPL INTO l_hierarchy_node_map_id;


  if C_APPL%notfound then
  close C_APPL;
      INSERT_ROW
        (
         X_ROWID                    => l_rowid
        ,X_HIERARCHY_NODE_MAP_ID    => l_hierarchy_node_map_id
        ,X_TOPIC_ID                 => l_topic_id
        ,X_HIERARCHY_ID             => l_hierarchy_id
        ,X_USER_INTERFACE_ID        => l_user_interface_id
        ,X_CREATED_BY               => l_created_by
        ,X_CREATION_DATE            => l_creation_date
        ,X_LAST_UPDATE_DATE         => l_last_update_date
        ,X_LAST_UPDATED_BY          => l_last_updated_by
        ,X_LAST_UPDATE_LOGIN        => l_last_update_login
        );


  else
  close C_APPL;
  --we can not provide update functionality.
  --This is since we can not determine the correct row to be updated by
  --using data in the ldt files

  --Hence we will be updating the table by inserting a new row.
  --Customer needs to delete the row by running some sql script.

  end if;

--
end LOAD_ROW;

END HR_KI_HNM_LOAD_API;

/
