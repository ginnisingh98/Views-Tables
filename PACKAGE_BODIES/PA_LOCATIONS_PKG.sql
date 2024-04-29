--------------------------------------------------------
--  DDL for Package Body PA_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_LOCATIONS_PKG" as
-- $Header: PALOCTLB.pls 120.1 2005/08/19 16:35:40 mwasowic noship $
procedure INSERT_ROW (
  p_CITY                     in VARCHAR2,
  p_REGION                   in VARCHAR2,
  p_COUNTRY_CODE             in VARCHAR2,
  p_CREATION_DATE            in DATE,
  p_CREATED_BY               in NUMBER,
  p_LAST_UPDATE_DATE         in DATE,
  p_LAST_UPDATED_BY          in NUMBER,
  p_LAST_UPDATE_LOGIN        in NUMBER,
  X_ROWID                    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_LOCATION_ID              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
) is

  cursor C is select ROWID from PA_LOCATIONS
    where LOCATION_ID = X_LOCATION_ID ;
begin

   /* Bug 4092701 - Commented the prm_licensed check   */
/*  IF PA_INSTALL.IS_PRM_LICENSED = 'Y' THEN */

    if (x_location_id is null ) THEN

        SELECT pa_locations_s.nextval
          INTO x_location_id
          FROM sys.dual;

    end if;

    insert into PA_LOCATIONS (
      LOCATION_ID,
      CITY,
      REGION,
      COUNTRY_CODE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
    ) select
       x_LOCATION_ID,
       p_CITY,
       p_REGION,
       p_COUNTRY_CODE,
       p_CREATION_DATE,
       p_CREATED_BY,
       p_LAST_UPDATE_DATE,
       p_LAST_UPDATED_BY,
       p_LAST_UPDATE_LOGIN
    from sys.dual
    where not exists
     (select NULL
      from PA_LOCATIONS L
      where L.LOCATION_ID = X_LOCATION_ID );

    open c;
    fetch c into X_ROWID;
    if (c%notfound) then
      close c;
      raise no_data_found;
    end if;
    close c;

/*  END IF; */

exception
  when others then
     RAISE ;

end INSERT_ROW;

end PA_LOCATIONS_PKG ;

/
