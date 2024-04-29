--------------------------------------------------------
--  DDL for Package PA_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_LOCATIONS_PKG" AUTHID CURRENT_USER as
-- $Header: PALOCTLS.pls 120.1 2005/08/19 16:35:44 mwasowic noship $

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
);

end PA_LOCATIONS_PKG ;
 

/
