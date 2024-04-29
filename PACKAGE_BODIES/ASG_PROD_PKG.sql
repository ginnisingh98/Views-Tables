--------------------------------------------------------
--  DDL for Package Body ASG_PROD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_PROD_PKG" as
/*$Header: asgprodb.pls 120.1 2005/08/12 02:53:42 saradhak noship $*/

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
  x_PROD_TOP in VARCHAR2,
  x_RUN_ORDER in NUMBER,
  x_INI_FILE in VARCHAR2,
  x_ZIP_FILE in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION in NUMBER) IS

begin


  insert into ASG_PROD_INFO(
    PROD_TOP,
    RUN_ORDER,
    INI_FILE,
    ZIP_FILE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    RELEASE_VERSION
  ) values (
    decode(X_PROD_TOP, FND_API.G_MISS_CHAR, NULL, x_PROD_TOP),
    decode(X_RUN_ORDER,FND_API.G_MISS_NUM, NULL, x_RUN_ORDER),
    decode(X_INI_FILE, FND_API.G_MISS_CHAR, NULL, x_INI_FILE),
    decode(X_ZIP_FILE, FND_API.G_MISS_CHAR, NULL, x_ZIP_FILE),
    decode(X_CREATION_DATE,FND_API.G_MISS_DATE, NULL, x_creation_date),
    decode(X_CREATED_BY,FND_API.G_MISS_NUM, NULL,x_created_by),
    decode(X_LAST_UPDATE_DATE,FND_API.G_MISS_DATE, NULL, x_last_update_date),
    decode(X_LAST_UPDATED_BY,FND_API.G_MISS_NUM, NULL,x_last_updated_by),
    decode(X_RELEASE_VERSION, FND_API.G_MISS_NUM, NULL, x_release_version)
  );

end insert_row;


procedure update_row (
  x_PROD_TOP in VARCHAR2,
  x_RUN_ORDER in NUMBER,
  x_INI_FILE in VARCHAR2,
  x_ZIP_FILE in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION in NUMBER) IS

x_count number;

begin

   IF (x_RELEASE_VERSION IS NOT NULL ) THEN
     update asg_PROD_INFO set
      RUN_ORDER = X_RUN_ORDER,
      PROD_TOP = x_PROD_TOP,
      INI_FILE = X_INI_FILE,
      ZIP_FILE = x_ZIP_FILE,
      CREATION_DATE = X_CREATION_DATE,
      CREATED_BY = X_CREATED_BY,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      RELEASE_VERSION = X_RELEASE_VERSION
     where PROD_TOP = X_PROD_TOP
     and nvl(RELEASE_VERSION,-1) <> x_RELEASE_VERSION;



     if (sql%notfound) then
        begin
          select count(*) into x_count from asg_prod_info
          where PROD_TOP = X_PROD_TOP;

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
          select count(*) into x_count from asg_prod_info
          where PROD_TOP = X_PROD_TOP;

          if (x_count = 0) then
             raise no_data_found;
           end if;
     end;
  END IF;
END UPDATE_ROW;


procedure load_row (
  x_PROD_TOP in VARCHAR2,
  x_RUN_ORDER in NUMBER,
  x_INI_FILE in VARCHAR2,
  x_ZIP_FILE in VARCHAR2,
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

  asg_prod_pkg.UPDATE_ROW (
    X_PROD_TOP                     => x_PROD_TOP,
    X_RUN_ORDER                    => x_RUN_ORDER,
    X_INI_FILE                     => x_INI_FILE,
    X_ZIP_FILE                     => x_ZIP_FILE,
    X_CREATION_DATE                => X_CREATION_DATE,
    X_CREATED_BY                   => X_CREATED_BY,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id,
    x_RELEASE_VERSION              => X_RELEASE_VERSION);

EXCEPTION
  WHEN NO_DATA_FOUND THEN

  asg_prod_pkg.insert_row (
    X_PROD_TOP                     => x_PROD_TOP,
    X_RUN_ORDER                    => x_RUN_ORDER,
    X_INI_FILE                     => x_INI_FILE,
    X_ZIP_FILE                     => x_ZIP_FILE,
    X_CREATION_DATE                => X_CREATION_DATE,
    X_CREATED_BY                   => X_CREATED_BY,
    X_LAST_UPDATE_DATE             => sysdate,
    X_LAST_UPDATED_BY              => l_user_id,
    x_RELEASE_VERSION              => X_RELEASE_VERSION);

END load_row;

END ASG_PROD_PKG;

/
