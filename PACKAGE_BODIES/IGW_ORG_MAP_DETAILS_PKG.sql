--------------------------------------------------------
--  DDL for Package Body IGW_ORG_MAP_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_ORG_MAP_DETAILS_PKG" as
--$Header: igwstmdb.pls 115.4 2002/11/14 18:48:04 vmedikon ship $

  procedure insert_row (
         x_rowid		IN OUT NOCOPY  VARCHAR2
	,p_map_id	        NUMBER
        ,p_stop_id              NUMBER
        ,p_approver_type        VARCHAR2
        ,p_user_name            varchar2) is

    cursor  c is
    select  rowid
    from    igw_org_map_details
    where   map_id = p_map_id and
            stop_id = p_stop_id and
            user_name = p_user_name;

    l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date  DATE   := SYSDATE;
  begin

    insert into igw_org_map_details(
	map_id
       ,stop_id
       ,approver_type
       ,user_name
	,last_update_date
	,last_updated_by
	,creation_date
	,created_by
	,last_update_login)
    values(
	p_map_id
	,p_stop_id
	,p_approver_type
  	,p_user_name
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_date
	,l_last_updated_by
	,l_last_update_login);

    open c;
    fetch c into x_ROWID;
    if (c%notfound) then
      close c;
      raise no_data_found;
    end if;
    close c;
  end insert_row;


  procedure lock_row (
         x_rowid		VARCHAR2
	,p_map_id	        NUMBER
        ,p_stop_id              NUMBER
        ,p_approver_type        VARCHAR2
        ,p_user_name            VARCHAR2) is

    cursor c is
      select  	*
     from  	igw_org_map_details
     where 	rowid = x_rowid
     for update of map_id,stop_id,user_name nowait;

     tlinfo c%rowtype;
  begin
    open c;
    fetch c into tlinfo;
    if (c%notfound) then
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
      close c;
      return;
    end if;
    close c;

    if (    (tlinfo.map_id = p_map_id)
        AND (tlinfo.stop_id = p_stop_id)
        AND ((tlinfo.approver_type = p_approver_type)
          OR (  (tlinfo.approver_type is null)
            AND (p_approver_type is null)))
        AND (tlinfo.user_name = p_user_name)) then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
    return;
  end lock_row;

  procedure update_row (
         x_rowid		VARCHAR2
	,p_map_id	        NUMBER
        ,p_stop_id              NUMBER
        ,p_approver_type        VARCHAR2
        ,p_user_name            varchar2) is

    l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date  DATE   := SYSDATE;
  begin

    update igw_org_map_details
    set stop_id = p_stop_id
       ,approver_type = p_approver_type
       ,user_name = p_user_name
       ,last_update_date = l_last_update_date
       ,last_updated_by = l_last_updated_by
       ,last_update_login = l_last_update_login
    where  rowid  = x_rowid;

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end update_row;


  procedure delete_row (x_rowid	VARCHAR2) is
  begin

    delete from igw_org_map_details
    where rowid = x_rowid;
    if (sql%notfound) then
      raise no_data_found;
    end if;

  end delete_row;

END IGW_ORG_MAP_DETAILS_PKG;

/
