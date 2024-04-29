--------------------------------------------------------
--  DDL for Package Body ASG_CONFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_CONFIG_PKG" as
/* $Header: asgpconb.pls 120.1 2005/08/12 02:48:54 saradhak noship $ */

-- HISTORY
-- OCT  29, 2003 ytian Modified the update_row to handle the entries
--                     without release_version.
-- SEP. 15, 2003 ytian Modified update_row to update the values only
--                     if the LDT has a different RELEASE_VERSION than
--                     the row in the database.
-- SEP. 09, 2002 ytian Updated update_row to not update the value for
--                     parameter DISABLED_SYNCH_MESSAGE.
-- AUG. 30, 2002 ytian created.

procedure insert_row (
  x_NAME in VARCHAR2,
  x_VALUE in VARCHAR2,
  x_DESCRIPTION  in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION  in NUMBER) IS


begin


  insert into ASG_CONFIG (
    NAME,
    VALUE,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    RELEASE_VERSION
  ) values (
    decode(X_NAME,FND_API.G_MISS_CHAR, NULL, x_NAME),
    decode(X_VALUE, FND_API.G_MISS_CHAR, NULL, x_VALUE),
    decode(X_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, x_DESCRIPTION),
    decode(X_CREATION_DATE,FND_API.G_MISS_DATE, NULL, x_creation_date),
    decode(X_CREATED_BY,FND_API.G_MISS_NUM, NULL,x_created_by),
    decode(X_LAST_UPDATE_DATE,FND_API.G_MISS_DATE, NULL, x_last_update_date),
    decode(X_LAST_UPDATED_BY,FND_API.G_MISS_NUM, NULL,x_last_updated_by),
    decode(X_RELEASE_VERSION, FND_API.G_MISS_NUM, NULL, x_release_version)
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
 x_NAME in VARCHAR2,
  x_VALUE in VARCHAR2,
  x_DESCRIPTION  in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER) IS

x_count number;

begin
     update asg_config set
      NAME = X_NAME,
      VALUE = x_VALUE,
      DESCRIPTION = X_DESCRIPTION,
      CREATION_DATE = X_CREATION_DATE,
      CREATED_BY = X_CREATED_BY,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY
     where NAME = X_NAME;

     if (sql%notfound) then
             raise no_data_found;
     end if;

END UPDATE_ROW;


procedure update_row (
 x_NAME in VARCHAR2,
  x_VALUE in VARCHAR2,
  x_DESCRIPTION  in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION in NUMBER) IS
x_count number;
begin


   IF (x_RELEASE_VERSION IS NOT NULL ) THEN
     update asg_config set
      NAME = X_NAME,
      VALUE = x_VALUE,
      DESCRIPTION = X_DESCRIPTION,
      CREATION_DATE = X_CREATION_DATE,
      CREATED_BY = X_CREATED_BY,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      RELEASE_VERSION = X_RELEASE_VERSION
     where NAME = X_NAME
     and nvl(RELEASE_VERSION,-1) <> x_RELEASE_VERSION;



     if (sql%notfound) then
        begin
          select count(*) into x_count from asg_config
          where name = X_NAME;

          if (x_count = 0) then
             raise no_data_found;
           end if;
         end;

     end if;
  ELSE
    /* if the release-version not set, and if the record is not
       existing, we should raise and then insert_row will catch
      and insert it then. */
     begin
          select count(*) into x_count from asg_config
          where name = X_NAME;

          if (x_count = 0) then
             raise no_data_found;
           end if;
     end;
  END IF;
END UPDATE_ROW;


procedure load_row (
 x_NAME in VARCHAR2,
  x_VALUE in VARCHAR2,
  x_DESCRIPTION  in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  p_owner in VARCHAR2)  IS

    l_user_id      number := 0;
BEGIN


  if (p_owner = 'SEED') then
    l_user_id := 1;
  end if;

  asg_config_pkg.UPDATE_ROW (
    X_NAME                         => x_NAME,
    X_VALUE                        => x_VALUE,
    X_DESCRIPTION                  => x_DESCRIPTION,
    X_CREATION_DATE                => X_CREATION_DATE,
    X_CREATED_BY                   => X_CREATED_BY,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     raise no_data_found;

END load_row;



procedure load_row (
 x_NAME in VARCHAR2,
  x_VALUE in VARCHAR2,
  x_DESCRIPTION  in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION in NUMBER,
  p_owner in VARCHAR2)  IS

    l_user_id      number := 0;

BEGIN


  if (p_owner = 'SEED') then
    l_user_id := 1;
  end if;

  asg_config_pkg.UPDATE_ROW (
    X_NAME	                   => x_NAME,
    X_VALUE	                   => x_VALUE,
    X_DESCRIPTION  	           => x_DESCRIPTION,
    X_CREATION_DATE                => X_CREATION_DATE,
    X_CREATED_BY                   => X_CREATED_BY,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id,
    x_RELEASE_VERSION              => X_RELEASE_VERSION);

EXCEPTION
  WHEN NO_DATA_FOUND THEN

  asg_config_pkg.insert_row (
    X_NAME	                   => x_NAME,
    X_VALUE                       => x_VALUE,
    X_DESCRIPTION	           => x_DESCRIPTION,
    X_CREATION_DATE                => sysdate,
    X_CREATED_BY                   => l_user_id,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id,
    X_RELEASE_VERSION              => X_RELEASE_VERSION);

END load_row;

END ASG_CONFIG_PKG;

/
