--------------------------------------------------------
--  DDL for Package Body ASG_PUB_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_PUB_ITEM_PKG" as
/* $Header: asgpubib.pls 120.1 2005/08/12 02:54:54 saradhak noship $ */


--HISTORY
--   Sep 21, 2004  yazhang using oracle_id other than hardcoded name for owner columns
--   MAR 31, 2003  ytian updated update_row not to update creation_date.
--   MAR 13, 2003  ytian  added alter/force_release_verison
--   Feb 12, 2003 yazhang add detect_conflict and conflict_callout columns
-- DEC  03, 2002 ytian Modified the update_row not to update the customized objects
--   NOV 05, 2002  yazhang add APPLY_SYNCHRONOUS
--   AUG 30, 2002  ytian  Added two columns ACC_LAST/CURRENT_RELEASE_VERSION
--   AUG 05, 2002  ytian  added two clumns ACCESS_OWNER/NAME
--   JUL 11, 2002  ytian  modified insert_row
--   JUN 26, 2002  ytian  modified not to update STATUS.
--   JUN 03, 2002  ytian  Modified _ID to varchar2 type.
--   MAY 08, 2002  ytian  added  INQ_NAME, FORCE_COMPLETE_REFRESH,
--                               CALLOUT_PROCEDURE, INQ_OWNER
--   MAR 22  2002  ytian  Modified insert_row to insert last_release_version
--                        as 0, so it gets upgraded/created first time.
--   MAR 21  2002  ytian  modified update_row not to update
--                         last_release_version
--   MAR 12, 2002  ytian  added updatable, and disabled_dml columns
--   MAR 10, 2002  ytian  created.

procedure insert_row (
  x_ITEM_ID in VARCHAR2,
  x_NAME in VARCHAR2,
  x_PUB_NAME in VARCHAR2,
  x_BASE_OWNER in VARCHAR2,
  x_BASE_OBJECT_NAME in VARCHAR2,
  x_PRIMARY_KEY_COLUMN in VARCHAR2,
  x_CONFLICT_RULE  in VARCHAR2,
  x_RESTRICTING_PREDICATE in VARCHAR2,
  x_HIGH_PRIORITY in VARCHAR2,
  x_TABLE_WEIGHT in VARCHAR2,
  x_PUB_ID in VARCHAR2,
  x_STATUS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_ACC_LAST_RELEASE_VERSION in NUMBER,
  x_ACC_CURRENT_RELEASE_VERSION in NUMBER,
  x_PARENT_TABLE in VARCHAR2,
  x_PARENT_OWNER in VARCHAR2,
  x_ENABLED in VARCHAR2,
  x_UPDATABLE in VARCHAR2,
  x_DISABLED_DML in VARCHAR2,
  x_WHERE_CLAUSE in VARCHAR2,
  x_QUERY1 in VARCHAR2,
  x_QUERY2 in VARCHAR2,
  x_ONLINE_QUERY in VARCHAR2,
  x_INQ_NAME in VARCHAR2,
  x_INQ_OWNER in VARCHAR2,
  x_FORCE_COMPLETE_REFRESH in VARCHAR2,
  x_CALLOUT_PROCEDURE in VARCHAR2,
  x_ACCESS_OWNER  in VARCHAR2,
  x_ACCESS_NAME   in VARCHAR2,
  x_APPLY_SYNCHRONOUS in VARCHAR2,
  x_CALLOUT_PER_USER in VARCHAR2,
  x_COMPLETE_REFRESH_PUB_ITEMS in VARCHAR2,
  x_DETECT_CONFLICT in VARCHAR2,
  x_CONFLICT_CALLOUT in VARCHAR2,
  x_force_release_version  in NUMBER,
  x_alter_release_version  in NUMBER,
  x_QUERY_ACCESS_TABLE in varchar2,
  x_ACCESS_TABLE_PREDICATE_LIST in varchar2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_ENABLE_DOWNLOAD_EVENTS in varchar2)
IS
  l_base_owner varchar2(30);
  l_inq_owner varchar2(30);
  l_access_owner varchar2(30);

begin

   begin
     select oracle_username into l_base_owner
       from fnd_oracle_userid
      where oracle_id = X_BASE_OWNER;
   exception
     when others then
    l_base_owner := x_base_owner;
   end;
   begin
     select oracle_username into l_inq_owner
       from fnd_oracle_userid
      where oracle_id = X_INQ_OWNER;
   exception
     when others then
      l_inq_owner := x_inq_owner;
   end;
   begin
     select oracle_username into l_access_owner
       from fnd_oracle_userid
      where oracle_id = X_ACCESS_OWNER;
   exception
     when others then
      l_access_owner := x_access_owner;
   end;

  insert into ASG_PUB_ITEM (
    ITEM_ID,
    NAME,
    PUB_NAME,
    BASE_OWNER,
    BASE_OBJECT_NAME,
    PRIMARY_KEY_COLUMN,
    CONFLICT_RULE,
    RESTRICTING_PREDICATE,
    HIGH_PRIORITY,
    TABLE_WEIGHT,
    PUB_ID,
    STATUS,
    LAST_RELEASE_VERSION,
    CURRENT_RELEASE_VERSION,
    ACC_LAST_RELEASE_VERSION,
    ACC_CURRENT_RELEASE_VERSION,
    PARENT_TABLE,
    PARENT_OWNER,
    ENABLED,
    UPDATABLE,
    DISABLED_DML,
    WHERE_CLAUSE,
    QUERY1,
    QUERY2,
    ONLINE_QUERY,
    INQ_NAME,
    INQ_OWNER,
    FORCE_COMPLETE_REFRESH,
    CALLOUT_PROCEDURE,
    ACCESS_OWNER,
    ACCESS_NAME,
    APPLY_SYNCHRONOUS,
    CALLOUT_PER_USER,
    COMPLETE_REFRESH_PUB_ITEMS,
    DETECT_CONFLICT,
    CONFLICT_CALLOUT,
    force_release_version,
    alter_release_version ,
    QUERY_ACCESS_TABLE,
    ACCESS_TABLE_PREDICATE_LIST,
    ENABLE_DOWNLOAD_EVENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) values (
    x_item_id,
    decode(X_NAME,FND_API.G_MISS_CHAR, NULL, x_NAME),
    decode(X_PUB_NAME, FND_API.G_MISS_CHAR, NULL, x_PUB_NAME),
    decode(L_BASE_OWNER,FND_API.G_MISS_CHAR, NULL, L_BASE_OWNER),
    decode(X_BASE_OBJECT_NAME,FND_API.G_MISS_CHAR, NULL, x_BASE_OBJECT_NAME),
    decode(X_PRIMARY_KEY_COLUMN, FND_API.G_MISS_CHAR, NULL, x_PRIMARY_KEY_COLUMN),
    decode(X_CONFLICT_RULE,FND_API.G_MISS_CHAR, NULL, x_CONFLICT_RULE),
    decode(X_RESTRICTING_PREDICATE,FND_API.G_MISS_CHAR, NULL, x_RESTRICTING_PREDICATE),
    decode(X_HIGH_PRIORITY,FND_API.G_MISS_CHAR, NULL, x_HIGH_PRIORITY),
    decode(X_TABLE_WEIGHT,FND_API.G_MISS_CHAR, NULL, x_TABLE_WEIGHT),
    decode(X_PUB_ID,FND_API.G_MISS_CHAR, NULL, x_PUB_ID),
    'N',
    0,
    decode(x_CURRENT_release_version,FND_API.G_MISS_NUM, NULL, x_CURRENT_RELEASE_VERSION),
    0,
    decode(x_ACC_CURRENT_release_version, FND_API.G_MISS_NUM, NULL, x_ACC_CURRENT_RELEASE_VERSION),
    decode(X_PARENT_TABLE,FND_API.G_MISS_CHAR, NULL, x_PARENT_TABLE),
    decode(X_PARENT_OWNER,FND_API.G_MISS_CHAR, NULL, x_PARENT_OWNER),
    decode(x_enabled,FND_API.G_MISS_CHAR,NULL, x_ENABLED),
    decode(x_updatable,FND_API.G_MISS_CHAR,NULL, x_updatable),
    decode(x_disabled_dml,FND_API.G_MISS_CHAR,NULL, x_disabled_dml),
    decode(x_where_clause,FND_API.G_MISS_CHAR,NULL, x_where_clause),
    decode(x_query1,FND_API.G_MISS_CHAR,NULL, x_query1),
    decode(x_query2,FND_API.G_MISS_CHAR,NULL, x_query2),
    decode(x_online_query,FND_API.G_MISS_CHAR,NULL, x_online_query),
decode(x_inq_name,FND_API.G_MISS_CHAR,NULL, x_inq_name),
decode(L_inq_owner,FND_API.G_MISS_CHAR,NULL, L_inq_owner),
decode(x_force_complete_refresh,FND_API.G_MISS_CHAR,NULL, x_force_complete_refresh),
decode(x_callout_procedure,FND_API.G_MISS_CHAR,NULL, x_callout_procedure),
decode(l_access_owner, FND_API.G_MISS_CHAR, NULL, l_access_owner),
decode(x_access_name, FND_API.G_MISS_CHAR, NULL, x_access_name),
decode(x_APPLY_SYNCHRONOUS, FND_API.G_MISS_CHAR, NULL,x_APPLY_SYNCHRONOUS),
decode(x_CALLOUT_PER_USER, FND_API.G_MISS_CHAR, NULL,x_CALLOUT_PER_USER),
decode(x_COMPLETE_REFRESH_PUB_ITEMS, FND_API.G_MISS_CHAR, NULL,x_COMPLETE_REFRESH_PUB_ITEMS),
decode(x_DETECT_CONFLICT, FND_API.G_MISS_CHAR, NULL,x_DETECT_CONFLICT),
decode(x_CONFLICT_CALLOUT, FND_API.G_MISS_CHAR, NULL,x_CONFLICT_CALLOUT),
 decode(X_force_release_version,FND_API.G_MISS_NUM, NULL,x_force_release_version),
decode(X_alter_release_version,FND_API.G_MISS_NUM, NULL,x_alter_release_version),
decode(x_QUERY_ACCESS_TABLE, FND_API.G_MISS_CHAR, NULL,x_QUERY_ACCESS_TABLE),
decode(x_ACCESS_TABLE_PREDICATE_LIST, FND_API.G_MISS_CHAR, NULL,x_ACCESS_TABLE_PREDICATE_LIST),
    nvl(x_ENABLE_DOWNLOAD_EVENTS, 'N'),
    decode(X_CREATION_DATE,FND_API.G_MISS_DATE, NULL, x_creation_date),
    decode(X_CREATED_BY,FND_API.G_MISS_NUM, NULL,x_created_by),
    decode(X_LAST_UPDATE_DATE,FND_API.G_MISS_DATE, NULL, x_last_update_date),
    decode(X_LAST_UPDATED_BY,FND_API.G_MISS_NUM, NULL,x_last_updated_by)
  );

/*
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
*/

end insert_row;

procedure update_row (
  x_ITEM_ID in VARCHAR2,
  x_NAME in VARCHAR2,
  x_PUB_NAME in VARCHAR2,
  x_BASE_OWNER in VARCHAR2,
  x_BASE_OBJECT_NAME in VARCHAR2,
  x_PRIMARY_KEY_COLUMN in VARCHAR2,
  x_CONFLICT_RULE  in VARCHAR2,
  x_RESTRICTING_PREDICATE in VARCHAR2,
  x_HIGH_PRIORITY in VARCHAR2,
  x_TABLE_WEIGHT in VARCHAR2,
  x_PUB_ID in VARCHAR2,
   x_STATUS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_ACC_LAST_RELEASE_VERSION in NUMBER,
  x_ACC_CURRENT_RELEASE_VERSION in NUMBER,
  x_PARENT_TABLE in VARCHAR2,
  x_PARENT_OWNER in VARCHAR2,
  x_ENABLED in VARCHAR2,
  x_UPDATABLE in VARCHAR2,
  x_DISABLED_DML in VARCHAR2,
  x_WHERE_CLAUSE in VARCHAR2,
  x_QUERY1 in VARCHAR2,
  x_QUERY2 in VARCHAR2,
  x_ONLINE_QUERY in VARCHAR2,
  x_INQ_NAME in VARCHAR2,
  x_INQ_OWNER in VARCHAR2,
  x_FORCE_COMPLETE_REFRESH in VARCHAR2,
  x_CALLOUT_PROCEDURE in VARCHAR2,
  x_ACCESS_OWNER  in VARCHAR2,
  x_ACCESS_NAME   in VARCHAR2,
  x_APPLY_SYNCHRONOUS in VARCHAR2,
  x_CALLOUT_PER_USER in VARCHAR2,
  x_COMPLETE_REFRESH_PUB_ITEMS in VARCHAR2,
  x_DETECT_CONFLICT in VARCHAR2,
  x_CONFLICT_CALLOUT in VARCHAR2,
  x_force_release_version  in NUMBER,
  x_alter_release_version  in NUMBER,
  x_QUERY_ACCESS_TABLE in varchar2,
  x_ACCESS_TABLE_PREDICATE_LIST in varchar2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_ENABLE_DOWNLOAD_EVENTS in varchar2)  IS

  l_pub_name varchar2(30);
  l_custom_flag varchar2(1);
  l_base_owner varchar2(30);
  l_inq_owner varchar2(30);
  l_access_owner varchar2(30);

begin
   select pub_name into l_pub_name
   from asg_pub_item
   where item_id = x_item_id;

   BEGIN
     select nvl(custom, 'N') into l_custom_flag
     from asg_pub
     where pub_id = l_pub_name;
   EXCEPTION
     when no_data_found then
       l_custom_flag := 'N';
   END;

  if (l_custom_flag = 'N' ) THEN
   begin
     select oracle_username into l_base_owner
       from fnd_oracle_userid
      where oracle_id = X_BASE_OWNER;
   exception
     when others then
    l_base_owner := x_base_owner;
   end;
   begin
     select oracle_username into l_inq_owner
       from fnd_oracle_userid
      where oracle_id = X_INQ_OWNER;
   exception
     when others then
      l_inq_owner := x_inq_owner;
   end;
   begin
     select oracle_username into l_access_owner
       from fnd_oracle_userid
      where oracle_id = X_ACCESS_OWNER;
   exception
     when others then
      l_access_owner := x_access_owner;
   end;

   update asg_pub_item set
      ITEM_ID = X_ITEM_ID,
    NAME = X_NAME,
    PUB_NAME = x_pub_Name,
    BASE_OWNER = L_BASE_OWNER,
    BASE_OBJECT_NAME = X_BASE_OBJECT_NAME,
    PRIMARY_KEY_COLUMN = X_PRIMARY_KEY_COLUMN,
    CONFLICT_RULE = X_CONFLICT_RULE,
    RESTRICTING_PREDICATE = X_RESTRICTING_PREDICATE,
    HIGH_PRIORITY = X_HIGH_PRIORITY,
    TABLE_WEIGHT = X_TABLE_WEIGHT,
    PUB_ID = X_PUB_ID,
--    STATUS = X_STATUS,
--    LAST_RELEASE_VERSION = X_LAST_RELEASE_VERSION,
    CURRENT_RELEASE_VERSION = X_CURRENT_RELEASE_VERSION,
    ACC_CURRENT_RELEASE_VERSION = x_ACC_CURRENT_RELEASE_VERSION,
    ENABLED = X_ENABLED,
    UPDATABLE = X_UPDATABLE,
    DISABLED_DML = X_DISABLED_DML,
    WHERE_CLAUSE = X_WHERE_CLAUSE,
    QUERY1 = x_query1,
    QUERY2 = x_query2,
    ONLINE_QUERY = X_ONLINE_QUERY,
    INQ_NAME = x_inq_name,
    INQ_OWNER = L_inq_owner,
    FORCE_COMPLETE_REFRESH = x_FORCE_COMPLETE_REFRESH,
    CALLOUT_PROCEDURE = x_CALLOUT_PROCEDURE,
    ACCESS_OWNER = l_ACCESS_OWNER,
    ACCESS_NAME = x_ACCESS_NAME,
    APPLY_SYNCHRONOUS = x_APPLY_SYNCHRONOUS,
    CALLOUT_PER_USER = x_CALLOUT_PER_USER,
    COMPLETE_REFRESH_PUB_ITEMS = x_COMPLETE_REFRESH_PUB_ITEMS,
    DETECT_CONFLICT = x_DETECT_CONFLICT,
    CONFLICT_CALLOUT = x_CONFLICT_CALLOUT,
    force_release_version        = x_FORCE_RELEASE_VERSION,
    alter_release_version        = x_ALTER_RELEASE_VERSION,
    QUERY_ACCESS_TABLE = x_QUERY_ACCESS_TABLE,
    ACCESS_TABLE_PREDICATE_LIST = x_ACCESS_TABLE_PREDICATE_LIST,
    ENABLE_DOWNLOAD_EVENTS = nvl(x_ENABLE_DOWNLOAD_EVENTS, 'N'),
    -- CREATION_DATE = X_CREATION_DATE,
    -- CREATED_BY = X_CREATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY
   where ITEM_ID = X_ITEM_ID;
  end if;

   if (sql%notfound) then

    raise no_data_found;
  end if;
END UPDATE_ROW;


procedure load_row (
  x_ITEM_ID in VARCHAR2,
  x_NAME in VARCHAR2,
  x_PUB_NAME in VARCHAR2,
  x_BASE_OWNER in VARCHAR2,
  x_BASE_OBJECT_NAME in VARCHAR2,
  x_PRIMARY_KEY_COLUMN in VARCHAR2,
  x_CONFLICT_RULE  in VARCHAR2,
  x_RESTRICTING_PREDICATE in VARCHAR2,
  x_HIGH_PRIORITY in VARCHAR2,
  x_TABLE_WEIGHT in VARCHAR2,
  x_PUB_ID in VARCHAR2,
   x_STATUS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_ACC_LAST_RELEASE_VERSION in NUMBER,
  x_ACC_CURRENT_RELEASE_VERSION in NUMBER,
  x_PARENT_TABLE in VARCHAR2,
  x_PARENT_OWNER in VARCHAR2,
  x_ENABLED in VARCHAR2,
  x_UPDATABLE in VARCHAR2,
  x_DISABLED_DML in VARCHAR2,
  x_WHERE_CLAUSE in VARCHAR2,
  x_QUERY1 in VARCHAR2,
  x_QUERY2 in VARCHAR2,
  x_ONLINE_QUERY in VARCHAR2,
  x_INQ_NAME in VARCHAR2,
  x_INQ_OWNER in VARCHAR2,
  x_FORCE_COMPLETE_REFRESH in VARCHAR2,
  x_CALLOUT_PROCEDURE in VARCHAR2,
  x_ACCESS_OWNER  in VARCHAR2,
  x_ACCESS_NAME   in VARCHAR2,
  x_APPLY_SYNCHRONOUS in VARCHAR2,
  x_CALLOUT_PER_USER in VARCHAR2,
  x_COMPLETE_REFRESH_PUB_ITEMS in VARCHAR2,
  x_DETECT_CONFLICT in VARCHAR2,
  x_CONFLICT_CALLOUT in VARCHAR2,
  x_force_release_version  in NUMBER,
  x_alter_release_version  in NUMBER,
  x_QUERY_ACCESS_TABLE in varchar2,
  x_ACCESS_TABLE_PREDICATE_LIST in varchar2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  p_owner in VARCHAR2,
  x_ENABLE_DOWNLOAD_EVENTS in varchar2)  IS

    l_user_id      number := 0;

BEGIN


  if (p_owner = 'SEED') then
    l_user_id := 1;
  end if;

  asg_pub_item_pkg.UPDATE_ROW (
    X_ITEM_ID       		   => x_ITEM_ID,
    X_NAME	                   => x_NAME,
    X_PUB_NAME                     => x_PUB_NAME,
    X_BASE_OWNER                   => x_BASE_OWNER,
    X_BASE_OBJECT_NAME             => x_BASE_OBJECT_NAME,
    X_PRIMARY_KEY_COLUMN           => x_PRIMARY_KEY_COLUMN,
    X_CONFLICT_RULE                => x_CONFLICT_RULE,
    X_RESTRICTING_PREDICATE       => x_RESTRICTING_PREDICATE,
    X_HIGH_PRIORITY                => x_HIGH_PRIORITY,
    X_TABLE_WEIGHT                 => x_TABLE_WEIGHT,
    x_PUB_ID                       => x_PUB_ID,
    X_STATUS			   => x_STATUS,
    X_LAST_RELEASE_VERSION         => x_last_release_version,
    X_CURRENT_RELEASE_VERSION      => x_current_release_version,
    X_ACC_LAST_RELEASE_VERSION         => x_acc_last_release_version,
    X_ACC_CURRENT_RELEASE_VERSION      => x_acc_current_release_version,
    X_PARENT_TABLE                 => x_parent_table,
    X_PARENT_OWNER                 => x_parent_owner,
    X_ENABLED                      => x_enabled,
    X_UPDATABLE                    => x_updatable,
    X_DISABLED_DML                 => x_disabled_dml,
    X_WHERE_CLAUSE                 => x_where_clause,
    x_QUERY1                       =>x_query1,
    x_QUERY2 			  => x_query2,
    x_ONLINE_QUERY 		   => x_online_query,
    x_INQ_NAME			   => x_INQ_NAME,
    x_INQ_OWNER			   => x_INQ_OWNER,
    x_FORCE_COMPLETE_REFRESH       => x_FORCE_COMPLETE_REFRESH,
    x_CALLOUT_PROCEDURE   	   => x_CALLOUT_PROCEDURE,
    x_ACCESS_OWNER                 => x_access_owner,
    x_access_name                  => x_access_name,
    x_APPLY_SYNCHRONOUS            => x_APPLY_SYNCHRONOUS,
    x_CALLOUT_PER_USER             => x_CALLOUT_PER_USER,
    x_COMPLETE_REFRESH_PUB_ITEMS   => x_COMPLETE_REFRESH_PUB_ITEMS,
    x_DETECT_CONFLICT              => x_DETECT_CONFLICT,
    x_CONFLICT_CALLOUT             => x_CONFLICT_CALLOUT,
    x_force_release_version        => x_FORCE_RELEASE_VERSION,
    x_alter_release_version        => x_ALTER_RELEASE_VERSION,
    x_QUERY_ACCESS_TABLE           => x_QUERY_ACCESS_TABLE,
    x_ACCESS_TABLE_PREDICATE_LIST  => x_ACCESS_TABLE_PREDICATE_LIST,
    x_ENABLE_DOWNLOAD_EVENTS       => x_ENABLE_DOWNLOAD_EVENTS,
     X_CREATION_DATE                => X_CREATION_DATE,
    X_CREATED_BY                   => X_CREATED_BY,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id);

EXCEPTION
  WHEN NO_DATA_FOUND THEN

  asg_pub_item_pkg.insert_row (
   X_ITEM_ID       		   => x_ITEM_ID,
    X_NAME	                   => x_NAME,
    X_PUB_NAME                     => x_PUB_NAME,
    X_BASE_OWNER                   => x_BASE_OWNER,
    X_BASE_OBJECT_NAME             => x_BASE_OBJECT_NAME,
    X_PRIMARY_KEY_COLUMN           => x_PRIMARY_KEY_COLUMN,
    X_CONFLICT_RULE                => x_CONFLICT_RULE,
    X_RESTRICTING_PREDICATE       => x_RESTRICTING_PREDICATE,
    X_HIGH_PRIORITY                => x_HIGH_PRIORITY,
    X_TABLE_WEIGHT                 => x_TABLE_WEIGHT,
    x_PUB_ID                       => x_PUB_ID,
    X_STATUS			   => x_STATUS,
    X_LAST_RELEASE_VERSION         => x_last_release_version,
    X_CURRENT_RELEASE_VERSION      => x_current_release_version,
    X_ACC_LAST_RELEASE_VERSION         => x_acc_last_release_version,
    X_ACC_CURRENT_RELEASE_VERSION      => x_acc_current_release_version,
    X_PARENT_TABLE                 => x_parent_table,
    X_PARENT_OWNER                 => x_parent_owner,
    X_ENABLED                      => x_enabled,
    X_UPDATABLE                    => x_updatable,
    X_DISABLED_DML                 => x_disabled_dml,
    X_WHERE_CLAUSE                 => x_where_clause,
    x_QUERY1                       =>x_query1,
    x_QUERY2 			  => x_query2,
    x_ONLINE_QUERY 		   => x_online_query,
    x_INQ_NAME			   => x_INQ_NAME,
    x_INQ_OWNER			   => x_INQ_OWNER,
    x_FORCE_COMPLETE_REFRESH       => x_FORCE_COMPLETE_REFRESH,
    x_CALLOUT_PROCEDURE   	   => x_CALLOUT_PROCEDURE,
    x_access_owner                 => x_access_owner,
    x_access_name                  => x_access_name,
    x_APPLY_SYNCHRONOUS            => x_APPLY_SYNCHRONOUS,
    x_CALLOUT_PER_USER             => x_CALLOUT_PER_USER,
    x_COMPLETE_REFRESH_PUB_ITEMS   => x_COMPLETE_REFRESH_PUB_ITEMS,
    x_DETECT_CONFLICT              => x_DETECT_CONFLICT,
    x_CONFLICT_CALLOUT             => x_CONFLICT_CALLOUT,
    x_force_release_version        => x_FORCE_RELEASE_VERSION,
    x_alter_release_version        => x_ALTER_RELEASE_VERSION,
    x_QUERY_ACCESS_TABLE           => x_QUERY_ACCESS_TABLE,
    x_ACCESS_TABLE_PREDICATE_LIST  => x_ACCESS_TABLE_PREDICATE_LIST,
    x_ENABLE_DOWNLOAD_EVENTS       => x_ENABLE_DOWNLOAD_EVENTS,
    X_CREATION_DATE                => sysdate,
    X_CREATED_BY                   => l_user_id,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id);

END load_row;

END ASG_PUB_ITEM_PKG;

/
