--------------------------------------------------------
--  DDL for Package Body IGW_ORG_MAPS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_ORG_MAPS_ALL_PKG" as
--$Header: igwstmpb.pls 115.4 2002/11/14 18:47:47 vmedikon ship $

  procedure insert_row (
         x_rowid		IN OUT NOCOPY  VARCHAR2
	,p_map_id	        NUMBER
	,p_organization_id	NUMBER
	,p_description		VARCHAR2
  	,p_start_date_active	DATE
  	,p_end_date_active	DATE) is

    cursor  c is
    select  rowid
    from    igw_org_maps_all
    where   map_id = p_map_id;

    l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date  DATE   := SYSDATE;
  begin

    insert into igw_org_maps_all(
	map_id
	,organization_id
	,description
  	,start_date_active
  	,end_date_active
	,last_update_date
	,last_updated_by
	,creation_date
	,created_by
	,last_update_login)
    values(
	p_map_id
	,p_organization_id
	,p_description
  	,p_start_date_active
  	,p_end_date_active
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
	,p_organization_id	NUMBER
	,p_description		VARCHAR2
  	,p_start_date_active	DATE
  	,p_end_date_active	DATE) is

    cursor c is
      select  	*
     from  	igw_org_maps_all
     where 	rowid = x_rowid
     for update of map_id nowait;

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

    if ( (tlinfo.map_id = p_map_id)
        AND (tlinfo.organization_id = p_organization_id)
        AND (tlinfo.description = p_description)
        AND (tlinfo.start_date_active = p_start_date_active)
        AND ((tlinfo.end_date_active = p_end_date_active)
           OR ((tlinfo.end_date_active is null)
               AND (p_end_date_active is null)))
   ) then
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
	,p_organization_id	NUMBER
	,p_description		VARCHAR2
  	,p_start_date_active	DATE
  	,p_end_date_active	DATE) is

    l_last_updated_by  	NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_last_update_date  DATE   := SYSDATE;
  begin

    update igw_org_maps_all
    set	   organization_id = p_organization_id
    ,	   description = p_description
    ,	   start_date_active = p_start_date_active
    ,	   end_date_active = p_end_date_active
    ,      last_update_date = l_last_update_date
    ,      last_updated_by = l_last_updated_by
    ,      last_update_login = l_last_update_login
    where  rowid  = x_rowid;

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end update_row;


  procedure delete_row (x_rowid	VARCHAR2) is
  begin

    delete from igw_org_maps_all
    where rowid = x_rowid;
    if (sql%notfound) then
      raise no_data_found;
    end if;

  end delete_row;

END IGW_ORG_MAPS_ALL_PKG;

/
