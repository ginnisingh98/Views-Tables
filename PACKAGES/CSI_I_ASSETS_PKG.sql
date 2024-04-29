--------------------------------------------------------
--  DDL for Package CSI_I_ASSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_I_ASSETS_PKG" AUTHID CURRENT_USER as
/* $Header: csitinas.pls 120.2 2005/06/08 13:52:14 appldev  $ */

PROCEDURE Insert_Row(
          px_INSTANCE_ASSET_ID   IN OUT NOCOPY NUMBER,
          p_INSTANCE_ID    NUMBER,
          p_FA_ASSET_ID    NUMBER,
          p_FA_BOOK_TYPE_CODE    VARCHAR2,
          p_FA_LOCATION_ID    NUMBER,
          p_ASSET_QUANTITY    NUMBER,
          p_UPDATE_STATUS    VARCHAR2,
          P_FA_SYNC_FLAG    VARCHAR2,
          P_FA_MASS_ADDITION_ID    NUMBER,
          P_CREATION_COMPLETE_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE);

PROCEDURE Update_Row(
          p_INSTANCE_ASSET_ID    NUMBER,
          p_INSTANCE_ID    NUMBER,
          p_FA_ASSET_ID    NUMBER,
          p_FA_BOOK_TYPE_CODE    VARCHAR2,
          p_FA_LOCATION_ID    NUMBER,
          p_ASSET_QUANTITY    NUMBER,
          p_UPDATE_STATUS    VARCHAR2,
          P_FA_SYNC_FLAG   VARCHAR2,
          P_FA_MASS_ADDITION_ID    NUMBER,
          P_CREATION_COMPLETE_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE);

PROCEDURE Lock_Row(
          p_INSTANCE_ASSET_ID    NUMBER,
          p_INSTANCE_ID    NUMBER,
          p_FA_ASSET_ID    NUMBER,
          p_FA_BOOK_TYPE_CODE    VARCHAR2,
          p_FA_LOCATION_ID    NUMBER,
          p_ASSET_QUANTITY    NUMBER,
          p_UPDATE_STATUS    VARCHAR2,
          P_FA_SYNC_FLAG   VARCHAR2,
          P_FA_MASS_ADDITION_ID    NUMBER,
          P_CREATION_COMPLETE_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE);

PROCEDURE Delete_Row(
    p_INSTANCE_ASSET_ID  NUMBER);

End CSI_I_ASSETS_PKG;


 

/
