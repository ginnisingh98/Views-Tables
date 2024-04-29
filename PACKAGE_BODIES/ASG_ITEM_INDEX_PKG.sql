--------------------------------------------------------
--  DDL for Package Body ASG_ITEM_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_ITEM_INDEX_PKG" as
/* $Header: asgpindb.pls 120.1 2005/08/12 02:51:47 saradhak noship $ */

-- HISTORY
-- DEC  03, 2002 ytian Modified the update_row not to update the customized object.
-- JUN  03, 2002 ytian modified _ID type to varchar2.
-- MAY  01, 2002 ytian created.

procedure insert_row (
  x_INDEX_ID in VARCHAR2,
  x_ITEM_ID  in VARCHAR2,
  x_INDEX_NAME in VARCHAR2,
  x_ENABLED  in VARCHAR2,
  x_PMOD     in VARCHAR2,
  x_INDEX_COLUMNS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER) IS


begin

  insert into ASG_PUB_ITEM_INDEX (
    INDEX_ID,
    ITEM_ID,
    INDEX_NAME,
    ENABLED,
    STATUS,
    PMOD,
    INDEX_COLUMNS,
    LAST_RELEASE_VERSION,
    CURRENT_RELEASE_VERSION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) values (
    x_index_id,
    decode(X_ITEM_ID,FND_API.G_MISS_CHAR, NULL, x_ITEM_ID),
    decode(X_INDEX_NAME, FND_API.G_MISS_CHAR, NULL, X_INDEX_NAME),
    decode(X_ENABLED, FND_API.G_MISS_CHAR, NULL, x_ENABLED),
   'N',
    decode(X_PMOD, FND_API.G_MISS_CHAR, NULL, X_PMOD),
     x_INDEX_COLUMNS,
--    decode(X_INDEX_COLUMNS,FND_API.G_MISS_CHAR, NULL, x_INDEX_COLUMNS),
    0,
    decode(x_CURRENT_release_version,FND_API.G_MISS_NUM, NULL, x_CURRENT_RELEASE_VERSION),
    decode(X_CREATION_DATE,FND_API.G_MISS_DATE, NULL, x_creation_date),
    decode(X_CREATED_BY,FND_API.G_MISS_NUM, NULL,x_created_by),
    decode(X_LAST_UPDATE_DATE,FND_API.G_MISS_DATE, NULL, x_last_update_date),
    decode(X_LAST_UPDATED_BY,FND_API.G_MISS_NUM, NULL,x_last_updated_by)
  );


end insert_row;

procedure update_row (
  x_INDEX_ID in VARCHAR2,
  x_ITEM_ID  in VARCHAR2,
  x_INDEX_NAME in VARCHAR2,
  x_ENABLED  in VARCHAR2,
  x_PMOD     in VARCHAR2,
  x_INDEX_COLUMNS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER) IS

l_custom_flag varchar2(1) ;
l_item_id varchar2(30);

begin

   select item_id into l_item_id
   from asg_pub_item_index
   where index_id = x_index_id;

   BEGIN
     select nvl(p.custom,'N')
     into l_custom_flag
     from asg_pub p, asg_pub_item i
     where p.pub_id = i.pub_name
     and i.item_id = l_ITEM_ID;
   EXCEPTION
    when no_data_found then
     l_custom_flag := 'N';
   END;

  IF (l_custom_flag <>'Y') THEN
   update asg_pub_item_index set
    INDEX_ID = X_INDEX_ID,
    ITEM_ID = X_ITEM_ID,
    INDEX_NAME = X_INDEX_NAME,
    ENABLED = X_ENABLED,
    PMOD = X_PMOD,
    INDEX_COLUMNS = X_INDEX_COLUMNS,
--    LAST_RELEASE_VERSION = X_LAST_RELEASE_VERSION,
    CURRENT_RELEASE_VERSION = X_CURRENT_RELEASE_VERSION,
    CREATION_DATE = X_CREATION_DATE,
    CREATED_BY = X_CREATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY
   where INDEX_ID = X_INDEX_ID;
END IF;

   if (sql%notfound) then
    raise no_data_found;
  end if;
END UPDATE_ROW;


procedure load_row (
  x_INDEX_ID in VARCHAR2,
  x_ITEM_ID  in VARCHAR2,
  x_INDEX_NAME in VARCHAR2,
  x_ENABLED  in VARCHAR2,
  x_PMOD     in VARCHAR2,
  x_INDEX_COLUMNS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
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

  asg_item_index_pkg.UPDATE_ROW (
    X_INDEX_ID       		   => x_INDEX_ID,
    X_ITEM_ID                      => x_ITEM_ID,
    X_INDEX_NAME	           => x_INDEX_NAME,
    X_ENABLED                      => x_ENABLED,
    X_PMOD			   => x_PMOD,
    X_INDEX_COLUMNS			   => x_INDEX_COLUMNS,
    X_LAST_RELEASE_VERSION         => x_LAST_release_version,
    X_CURRENT_RELEASE_VERSION      => x_CURRENT_release_version,
    X_CREATION_DATE                => X_CREATION_DATE,
    X_CREATED_BY                   => X_CREATED_BY,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id);

EXCEPTION
  WHEN NO_DATA_FOUND THEN

  asg_item_index_pkg.insert_row (
    X_INDEX_ID       		   => x_INDEX_ID,
    X_ITEM_ID                      => x_ITEM_ID,
    X_INDEX_NAME	           => x_INDEX_NAME,
    X_ENABLED                      => x_ENABLED,
    X_PMOD			   => x_PMOD,
    X_INDEX_COLUMNS			   => x_INDEX_COLUMNS,
    X_LAST_RELEASE_VERSION         => x_LAST_release_version,
    X_CURRENT_RELEASE_VERSION      => x_CURRENT_release_version,
    X_CREATION_DATE                => sysdate,
    X_CREATED_BY                   => l_user_id,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id);

END load_row;

END ASG_ITEM_INDEX_PKG;

/
