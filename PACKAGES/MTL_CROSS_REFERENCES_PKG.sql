--------------------------------------------------------
--  DDL for Package MTL_CROSS_REFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CROSS_REFERENCES_PKG" AUTHID CURRENT_USER AS
/* $Header: INVIDXRS.pls 120.0 2005/06/22 23:04:45 lparihar noship $ */

   PROCEDURE INSERT_ROW (
         P_SOURCE_SYSTEM_ID       IN NUMBER
        ,P_START_DATE_ACTIVE      IN DATE
        ,P_END_DATE_ACTIVE        IN DATE
        ,P_OBJECT_VERSION_NUMBER  IN NUMBER
        ,P_UOM_CODE               IN VARCHAR2
        ,P_REVISION_ID            IN NUMBER
        ,P_EPC_GTIN_SERIAL        IN NUMBER
        ,P_INVENTORY_ITEM_ID      IN NUMBER
        ,P_ORGANIZATION_ID        IN NUMBER
        ,P_CROSS_REFERENCE_TYPE   IN VARCHAR2
        ,P_CROSS_REFERENCE        IN VARCHAR2
        ,P_ORG_INDEPENDENT_FLAG   IN VARCHAR2
        ,P_REQUEST_ID             IN NUMBER
        ,P_ATTRIBUTE1             IN VARCHAR2
        ,P_ATTRIBUTE2             IN VARCHAR2
        ,P_ATTRIBUTE3             IN VARCHAR2
        ,P_ATTRIBUTE4             IN VARCHAR2
        ,P_ATTRIBUTE5             IN VARCHAR2
        ,P_ATTRIBUTE6             IN VARCHAR2
        ,P_ATTRIBUTE7             IN VARCHAR2
        ,P_ATTRIBUTE8             IN VARCHAR2
        ,P_ATTRIBUTE9             IN VARCHAR2
        ,P_ATTRIBUTE10            IN VARCHAR2
        ,P_ATTRIBUTE11            IN VARCHAR2
        ,P_ATTRIBUTE12            IN VARCHAR2
        ,P_ATTRIBUTE13            IN VARCHAR2
        ,P_ATTRIBUTE14            IN VARCHAR2
        ,P_ATTRIBUTE15            IN VARCHAR2
        ,P_ATTRIBUTE_CATEGORY     IN VARCHAR2
        ,P_DESCRIPTION            IN VARCHAR2
        ,P_CREATION_DATE          IN DATE
        ,P_CREATED_BY             IN NUMBER
        ,P_LAST_UPDATE_DATE       IN DATE
        ,P_LAST_UPDATED_BY        IN NUMBER
        ,P_LAST_UPDATE_LOGIN      IN NUMBER
        ,P_PROGRAM_APPLICATION_ID IN NUMBER
        ,P_PROGRAM_ID             IN NUMBER
        ,P_PROGRAM_UPDATE_DATE    IN DATE
        ,X_CROSS_REFERENCE_ID     OUT NOCOPY NUMBER);


   PROCEDURE LOCK_ROW (
         P_CROSS_REFERENCE_ID     IN NUMBER
        ,P_SOURCE_SYSTEM_ID       IN NUMBER
        ,P_START_DATE_ACTIVE      IN DATE
        ,P_END_DATE_ACTIVE        IN DATE
        ,P_OBJECT_VERSION_NUMBER  IN NUMBER
        ,P_UOM_CODE               IN VARCHAR2
        ,P_REVISION_ID            IN NUMBER
        ,P_EPC_GTIN_SERIAL        IN NUMBER
        ,P_INVENTORY_ITEM_ID      IN NUMBER
        ,P_ORGANIZATION_ID        IN NUMBER
        ,P_CROSS_REFERENCE_TYPE   IN VARCHAR2
        ,P_CROSS_REFERENCE        IN VARCHAR2
        ,P_ORG_INDEPENDENT_FLAG   IN VARCHAR2
        ,P_ATTRIBUTE1             IN VARCHAR2
        ,P_ATTRIBUTE2             IN VARCHAR2
        ,P_ATTRIBUTE3             IN VARCHAR2
        ,P_ATTRIBUTE4             IN VARCHAR2
        ,P_ATTRIBUTE5             IN VARCHAR2
        ,P_ATTRIBUTE6             IN VARCHAR2
        ,P_ATTRIBUTE7             IN VARCHAR2
        ,P_ATTRIBUTE8             IN VARCHAR2
        ,P_ATTRIBUTE9             IN VARCHAR2
        ,P_ATTRIBUTE10            IN VARCHAR2
        ,P_ATTRIBUTE11            IN VARCHAR2
        ,P_ATTRIBUTE12            IN VARCHAR2
        ,P_ATTRIBUTE13            IN VARCHAR2
        ,P_ATTRIBUTE14            IN VARCHAR2
        ,P_ATTRIBUTE15            IN VARCHAR2
        ,P_ATTRIBUTE_CATEGORY     IN VARCHAR2
        ,P_DESCRIPTION            IN VARCHAR2);

   PROCEDURE UPDATE_ROW (
         P_CROSS_REFERENCE_ID     IN NUMBER
        ,P_SOURCE_SYSTEM_ID       IN NUMBER
        ,P_START_DATE_ACTIVE      IN DATE
        ,P_END_DATE_ACTIVE        IN DATE
        ,P_UOM_CODE               IN VARCHAR2
        ,P_REVISION_ID            IN NUMBER
        ,P_EPC_GTIN_SERIAL        IN NUMBER
        ,P_INVENTORY_ITEM_ID      IN NUMBER
        ,P_ORGANIZATION_ID        IN NUMBER
        ,P_CROSS_REFERENCE_TYPE   IN VARCHAR2
        ,P_CROSS_REFERENCE        IN VARCHAR2
        ,P_ORG_INDEPENDENT_FLAG   IN VARCHAR2
        ,P_REQUEST_ID             IN NUMBER
        ,P_ATTRIBUTE1             IN VARCHAR2
        ,P_ATTRIBUTE2             IN VARCHAR2
        ,P_ATTRIBUTE3             IN VARCHAR2
        ,P_ATTRIBUTE4             IN VARCHAR2
        ,P_ATTRIBUTE5             IN VARCHAR2
        ,P_ATTRIBUTE6             IN VARCHAR2
        ,P_ATTRIBUTE7             IN VARCHAR2
        ,P_ATTRIBUTE8             IN VARCHAR2
        ,P_ATTRIBUTE9             IN VARCHAR2
        ,P_ATTRIBUTE10            IN VARCHAR2
        ,P_ATTRIBUTE11            IN VARCHAR2
        ,P_ATTRIBUTE12            IN VARCHAR2
        ,P_ATTRIBUTE13            IN VARCHAR2
        ,P_ATTRIBUTE14            IN VARCHAR2
        ,P_ATTRIBUTE15            IN VARCHAR2
        ,P_ATTRIBUTE_CATEGORY     IN VARCHAR2
        ,P_DESCRIPTION            IN VARCHAR2
        ,P_LAST_UPDATE_DATE       IN DATE
        ,P_LAST_UPDATED_BY        IN NUMBER
        ,P_LAST_UPDATE_LOGIN      IN NUMBER
        ,X_OBJECT_VERSION_NUMBER  OUT NOCOPY NUMBER);

   PROCEDURE DELETE_ROW (P_CROSS_REFERENCE_ID IN NUMBER);

   PROCEDURE ADD_LANGUAGE;

END MTL_CROSS_REFERENCES_PKG;

 

/
