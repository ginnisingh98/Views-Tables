--------------------------------------------------------
--  DDL for Package Body ASG_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_PUB_PKG" as
/* $Header: asgppubb.pls 120.1 2005/08/12 02:53:07 saradhak noship $ */

-- HISTORY
-- AUG 21, 2003  ytian   Modified the update_row, need to update the entry
--                       for the custom publication as well.
-- JUL 16, 2003    ytian   Added ADDITIONAL_DEVICE_TYPE column.
-- MAR 31, 2003  ytian   modified update_row not to update creation_date.
-- Mar 11, 2003  yazhang add shared_by column
-- DEC  03, 2002 ytian Modified the update_row not to update the customized objects
-- NOV  05, 2002 yazhang add need_resourceid and custom
-- AUG  30, 2002 ytian added enable_synch.
-- JUN  26, 2002 ytian modified not to update STATUS when loading.
-- JUN  06  2002 ytian Modified device_type to varchar2.
-- JUN  03  2002 ytian added device_type parameter, changed _ID to varchar2.
-- MAR  22, 2002 ytian Modified insert_row  to insert last_release_version
--                     value = 0, make sure the object got upgraded.
-- MAR  21, 2002 ytian modified update_row not to update last_release_version
-- MAR. 11, 2002 ytian created.

procedure insert_row (
  x_PUB_ID in VARCHAR2,
  x_NAME in VARCHAR2,
  x_ENABLED in VARCHAR2,
  x_STATUS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_WRAPPER_NAME    in VARCHAR2,
  x_DEVICE_TYPE in VARCHAR2,
  x_ENABLE_SYNCH in VARCHAR2,
  x_NEED_RESOURCEID in VARCHAR2,
  x_CUSTOM  in VARCHAR2,
  x_SHARED_BY in VARCHAR2,
  x_ADDITIONAL_DEVICE_TYPE in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER) IS


begin


  insert into ASG_PUB (
    PUB_ID,
    NAME,
    ENABLED,
    STATUS,
    LAST_RELEASE_VERSION,
    CURRENT_RELEASE_VERSION,
    WRAPPER_NAME,
    DEVICE_TYPE,
    ENABLE_SYNCH,
    NEED_RESOURCEID,
    CUSTOM,
    SHARED_BY,
    ADDITIONAL_DEVICE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) values (
    x_pub_id,
    decode(X_NAME,FND_API.G_MISS_CHAR, NULL, x_NAME),
    decode(X_ENABLED, FND_API.G_MISS_CHAR, NULL, x_ENABLED),
    'N',
    0,
    decode(x_CURRENT_release_version,FND_API.G_MISS_NUM, NULL, x_CURRENT_RELEASE_VERSION),
    decode(X_WRAPPER_NAME,FND_API.G_MISS_CHAR, NULL, x_wrapper_name),
    x_device_Type,
    'Y',
    decode(X_NEED_RESOURCEID, FND_API.G_MISS_CHAR, NULL, x_NEED_RESOURCEID),
    decode(X_CUSTOM, FND_API.G_MISS_CHAR, NULL, x_CUSTOM),
    decode(X_SHARED_BY, FND_API.G_MISS_CHAR, NULL, x_SHARED_BY),
    decode(X_ADDITIONAL_DEVICE_TYPE, FND_API.G_MISS_CHAR, NULL, x_ADDITIONAL_DEVICE_TYPE),
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
   x_PUB_ID in VARCHAR2,
  x_NAME in VARCHAR2,
  x_ENABLED in VARCHAR2,
  x_STATUS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_WRAPPER_NAME    in VARCHAR2,
  x_DEVICE_TYPE in VARCHAR2,
  x_ENABLE_SYNCH in VARCHAR2,
  x_NEED_RESOURCEID in VARCHAR2,
  x_CUSTOM  in VARCHAR2,
  x_SHARED_BY in VARCHAR2,
  x_ADDITIONAL_DEVICE_TYPE in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER) IS

l_update_flag varchar2(1);

begin

   select nvl(custom, 'N')
   into l_update_flag
   from asg_pub
   where pub_id = x_pub_id;

 if (l_update_flag = 'N' ) then
   update asg_pub set
    PUB_ID = X_PUB_ID,
    NAME = X_NAME,
    ENABLED = X_ENABLED,
--    STATUS = X_STATUS,
--    LAST_RELEASE_VERSION = X_LAST_RELEASE_VERSION,
    CURRENT_RELEASE_VERSION = X_CURRENT_RELEASE_VERSION,
    WRAPPER_NAME = X_WRAPPER_NAME,
    DEVICE_TYPE = X_DEVICE_TYPE,
    NEED_RESOURCEID = X_NEED_RESOURCEID,
    CUSTOM = X_CUSTOM,
    SHARED_BY = X_SHARED_BY,
    ADDITIONAL_DEVICE_TYPE = X_ADDITIONAL_DEVICE_TYPE,
--    CREATION_DATE = X_CREATION_DATE,
--    CREATED_BY = X_CREATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY
  where PUB_ID = X_PUB_ID;
else
   update asg_pub set
       ADDITIONAL_DEVICE_TYPE = X_ADDITIONAL_DEVICE_TYPE
   where PUB_ID = X_PUB_ID;
  end if;

   if (sql%notfound) then
    raise no_data_found;
  end if;
END UPDATE_ROW;


procedure load_row (
   x_PUB_ID in VARCHAR2,
  x_NAME in VARCHAR2,
  x_ENABLED in VARCHAR2,
  x_STATUS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_WRAPPER_NAME    in VARCHAR2,
  x_DEVICE_TYPE  in VARCHAR2,
  x_ENABLE_SYNCH in VARCHAR2,
  x_NEED_RESOURCEID in VARCHAR2,
  x_CUSTOM  in VARCHAR2,
  x_SHARED_BY in VARCHAR2,
  x_ADDITIONAL_DEVICE_TYPE in VARCHAR2,
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

  asg_pub_pkg.UPDATE_ROW (
    X_PUB_ID       		   => x_PUB_ID,
    X_NAME	                   => x_NAME,
    X_ENABLED                      => x_ENABLED,
    X_STATUS			   => x_STATUS,
    X_LAST_RELEASE_VERSION         => x_LAST_release_version,
    X_CURRENT_RELEASE_VERSION      => x_CURRENT_release_version,
    X_WRAPPER_NAME                 => X_WRAPPER_NAME,
    x_DEVICE_TYPE		   => x_DEVICE_TYPE,
    x_ENABLE_SYNCH                 => x_ENABLE_SYNCH,
    x_NEED_RESOURCEID              => x_NEED_RESOURCEID,
    x_CUSTOM                       => x_CUSTOM,
    x_SHARED_BY                    => x_SHARED_BY,
    x_ADDITIONAL_DEVICE_TYPE       => x_ADDITIONAL_DEVICE_TYPE,
    X_CREATION_DATE                => X_CREATION_DATE,
    X_CREATED_BY                   => X_CREATED_BY,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id);

EXCEPTION
  WHEN NO_DATA_FOUND THEN

  asg_pub_pkg.insert_row (
    X_PUB_ID       		   => x_PUB_ID,
    X_NAME	                   => x_NAME,
    X_ENABLED                      => x_ENABLED,
    X_STATUS			   => x_STATUS,
    X_LAST_RELEASE_VERSION         => x_LAST_release_version,
    X_CURRENT_RELEASE_VERSION      => x_CURRENT_release_version,
    X_WRAPPER_NAME                 => X_WRAPPER_NAME,
    x_DEVICE_TYPE		   => x_DEVICE_TYPE,
    x_ENABLE_SYNCH                 => x_ENABLE_SYNCH,
    x_NEED_RESOURCEID              => x_NEED_RESOURCEID,
    x_CUSTOM                       => x_CUSTOM,
    x_SHARED_BY                    => x_SHARED_BY,
    x_ADDITIONAL_DEVICE_TYPE       => x_ADDITIONAL_DEVICE_TYPE,
    X_CREATION_DATE                => sysdate,
    X_CREATED_BY                   => l_user_id,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id);

END load_row;

END ASG_PUB_PKG;

/
