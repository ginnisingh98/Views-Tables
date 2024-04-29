--------------------------------------------------------
--  DDL for Package Body ASG_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_RESP_PKG" as
/* $Header: asgrespb.pls 120.1 2005/08/12 02:57:16 saradhak noship $ */

-- HISTORY
-- JUN  03  2002   ytian changed _ID pk type to varchar2.
-- MAR. 11, 2002 ytian created.

procedure insert_row (
  x_PUB_ID in VARCHAR2,
  x_RESPONSIBILITY_ID in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER) IS


begin


  insert into ASG_PUB_RESPONSIBILITY (
    PUB_ID,
    RESPONSIBILITY_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) values (
    x_pub_id,
    decode(x_RESPONSIBILITY_ID,FND_API.G_MISS_NUM, NULL, x_RESPONSIBILITY_ID),
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
  x_RESPONSIBILITY_ID in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER) IS
begin
   update asg_pub_RESPONSIBILITY set
    PUB_ID = X_PUB_ID,
    RESPONSIBILITY_ID = x_RESPONSIBILITY_ID,
    CREATION_DATE = X_CREATION_DATE,
    CREATED_BY = X_CREATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY
   where PUB_ID = X_PUB_ID
       and responsibility_id = x_RESPONSIBILITY_ID;

   if (sql%notfound) then
    raise no_data_found;
  end if;
END UPDATE_ROW;


procedure load_row (
   x_PUB_ID in VARCHAR2,
  x_RESPONSIBILITY_ID in NUMBER,
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

  asg_resp_pkg.UPDATE_ROW (
    X_PUB_ID       		   => x_PUB_ID,
    X_RESPONSIBILITY_ID            => x_RESPONSIBILITY_ID,
    X_CREATION_DATE                => X_CREATION_DATE,
    X_CREATED_BY                   => X_CREATED_BY,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id);

EXCEPTION
  WHEN NO_DATA_FOUND THEN

  asg_resp_pkg.insert_row (
    X_PUB_ID       		   => x_PUB_ID,
    x_RESPONSIBILITY_ID            => x_RESPONSIBILITY_Id,
    X_CREATION_DATE                => sysdate,
    X_CREATED_BY                   => l_user_id,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id);

END load_row;

END ASG_RESP_PKG;

/
