--------------------------------------------------------
--  DDL for Package EAM_DIRECT_ITEMS_PKG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_DIRECT_ITEMS_PKG_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVDIPS.pls 120.1 2005/09/22 23:13:27 grajan noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVDIPS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_DIRECT_ITEMS_PKG_PVT
--
--  NOTES
--
--  HISTORY
--
--  01-OCT-2003    Basanth Roy     Initial Creation
***************************************************************************/


        PROCEDURE Insert_Row
        ( X_DESCRIPTION                   IN VARCHAR2        ,
          X_DIRECT_ITEM_TYPE              IN NUMBER          ,
          X_PURCHASING_CATEGORY_ID        IN NUMBER          ,
          X_DIRECT_ITEM_SEQUENCE_ID       IN OUT NOCOPY NUMBER,		-- Fix for Bug 3745360
          X_INVENTORY_ITEM_ID             IN NUMBER          ,
          X_OPERATION_SEQ_NUM             IN NUMBER          ,
          X_DEPARTMENT_ID                 IN NUMBER          ,
          X_WIP_ENTITY_ID                 IN NUMBER          ,
          X_ORGANIZATION_ID               IN NUMBER          ,
          X_SUGGESTED_VENDOR_NAME         IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_ID           IN NUMBER          ,
          X_SUGGESTED_VENDOR_SITE         IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_SITE_ID      IN NUMBER          ,
          X_SUGGESTED_VENDOR_CONTACT      IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_CONTACT_ID   IN NUMBER          ,
          X_SUGGESTED_VENDOR_PHONE        IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_ITEM_NUM     IN VARCHAR2        ,
          X_UNIT_PRICE                    IN NUMBER          ,
          X_AUTO_REQUEST_MATERIAL         IN VARCHAR2        ,
          X_REQUIRED_QUANTITY             IN NUMBER          ,
          X_UOM                           IN VARCHAR2        ,
          X_NEED_BY_DATE                  IN DATE            ,
          X_ATTRIBUTE_CATEGORY            IN VARCHAR2        ,
          X_ATTRIBUTE1                    IN VARCHAR2        ,
          X_ATTRIBUTE2                    IN VARCHAR2        ,
          X_ATTRIBUTE3                    IN VARCHAR2        ,
          X_ATTRIBUTE4                    IN VARCHAR2        ,
          X_ATTRIBUTE5                    IN VARCHAR2        ,
          X_ATTRIBUTE6                    IN VARCHAR2        ,
          X_ATTRIBUTE7                    IN VARCHAR2        ,
          X_ATTRIBUTE8                    IN VARCHAR2        ,
          X_ATTRIBUTE9                    IN VARCHAR2        ,
          X_ATTRIBUTE10                   IN VARCHAR2        ,
          X_ATTRIBUTE11                   IN VARCHAR2        ,
          X_ATTRIBUTE12                   IN VARCHAR2        ,
          X_ATTRIBUTE13                   IN VARCHAR2        ,
          X_ATTRIBUTE14                   IN VARCHAR2        ,
          X_ATTRIBUTE15                   IN VARCHAR2        ,
          X_PROGRAM_APPLICATION_ID        IN NUMBER          ,
          X_PROGRAM_ID                    IN NUMBER          ,
          X_PROGRAM_UPDATE_DATE           IN DATE            ,
          X_REQUEST_ID                    IN NUMBER          ,
          x_return_Status                 OUT NOCOPY VARCHAR2,
          x_material_shortage_flag        OUT NOCOPY VARCHAR2,
          x_material_shortage_check_date  OUT NOCOPY DATE
         );


        PROCEDURE Delete_Row
        ( X_DIRECT_ITEM_TYPE                IN NUMBER,
          X_DIRECT_ITEM_SEQUENCE_ID         IN NUMBER,
          X_INVENTORY_ITEM_ID               IN NUMBER,
          X_OPERATION_SEQ_NUM               IN NUMBER,
          X_WIP_ENTITY_ID                   IN NUMBER,
          X_ORGANIZATION_ID                 IN NUMBER,
          x_return_Status                   OUT NOCOPY VARCHAR2,
          x_material_shortage_flag        OUT NOCOPY VARCHAR2,
          x_material_shortage_check_date  OUT NOCOPY DATE
         );

        PROCEDURE Update_Row
        ( X_DESCRIPTION                   IN VARCHAR2        ,
          X_DIRECT_ITEM_TYPE              IN NUMBER          ,
          X_PURCHASING_CATEGORY_ID        IN NUMBER          ,
          X_DIRECT_ITEM_SEQUENCE_ID       IN NUMBER          ,
          X_INVENTORY_ITEM_ID             IN NUMBER          ,
          X_OPERATION_SEQ_NUM             IN NUMBER          ,
          X_DEPARTMENT_ID                 IN NUMBER          ,
          X_WIP_ENTITY_ID                 IN NUMBER          ,
          X_ORGANIZATION_ID               IN NUMBER          ,
          X_SUGGESTED_VENDOR_NAME         IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_ID           IN NUMBER          ,
          X_SUGGESTED_VENDOR_SITE         IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_SITE_ID      IN NUMBER          ,
          X_SUGGESTED_VENDOR_CONTACT      IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_CONTACT_ID   IN NUMBER          ,
          X_SUGGESTED_VENDOR_PHONE        IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_ITEM_NUM     IN VARCHAR2        ,
          X_UNIT_PRICE                    IN NUMBER          ,
          X_AUTO_REQUEST_MATERIAL         IN VARCHAR2        ,
          X_REQUIRED_QUANTITY             IN NUMBER          ,
          X_UOM                           IN VARCHAR2        ,
          X_NEED_BY_DATE                  IN DATE            ,
          X_ATTRIBUTE_CATEGORY            IN VARCHAR2        ,
          X_ATTRIBUTE1                    IN VARCHAR2        ,
          X_ATTRIBUTE2                    IN VARCHAR2        ,
          X_ATTRIBUTE3                    IN VARCHAR2        ,
          X_ATTRIBUTE4                    IN VARCHAR2        ,
          X_ATTRIBUTE5                    IN VARCHAR2        ,
          X_ATTRIBUTE6                    IN VARCHAR2        ,
          X_ATTRIBUTE7                    IN VARCHAR2        ,
          X_ATTRIBUTE8                    IN VARCHAR2        ,
          X_ATTRIBUTE9                    IN VARCHAR2        ,
          X_ATTRIBUTE10                   IN VARCHAR2        ,
          X_ATTRIBUTE11                   IN VARCHAR2        ,
          X_ATTRIBUTE12                   IN VARCHAR2        ,
          X_ATTRIBUTE13                   IN VARCHAR2        ,
          X_ATTRIBUTE14                   IN VARCHAR2        ,
          X_ATTRIBUTE15                   IN VARCHAR2        ,
          X_PROGRAM_APPLICATION_ID        IN NUMBER          ,
          X_PROGRAM_ID                    IN NUMBER          ,
          X_PROGRAM_UPDATE_DATE           IN DATE            ,
          X_REQUEST_ID                    IN NUMBER          ,
          x_return_Status                 OUT NOCOPY VARCHAR2,
          x_material_shortage_flag        OUT NOCOPY VARCHAR2,
          x_material_shortage_check_date  OUT NOCOPY DATE
        );

  --Fix for 3352406.Added the following procedure to show the messages from the api
        PROCEDURE show_mesg;



END EAM_DIRECT_ITEMS_PKG_PVT;

 

/
