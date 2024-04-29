--------------------------------------------------------
--  DDL for Package CSI_A_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_A_LOCATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: csitlocs.pls 115.7 2002/11/12 00:23:03 rmamidip noship $ */


PROCEDURE Insert_Row(
          px_ASSET_LOCATION_ID   IN OUT NOCOPY NUMBER,
          p_FA_LOCATION_ID    NUMBER,
          p_LOCATION_TABLE    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Update_Row(
          p_ASSET_LOCATION_ID    NUMBER,
          p_FA_LOCATION_ID    NUMBER,
          p_LOCATION_TABLE    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Lock_Row(
          p_ASSET_LOCATION_ID    NUMBER,
          p_FA_LOCATION_ID    NUMBER,
          p_LOCATION_TABLE    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_ASSET_LOCATION_ID  NUMBER);
End CSI_A_LOCATIONS_PKG;


 

/
