--------------------------------------------------------
--  DDL for Package CSP_CARRIER_DELIVERY_TIMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_CARRIER_DELIVERY_TIMES_PKG" AUTHID CURRENT_USER AS
/* $Header: csptcdts.pls 120.0.12010000.4 2012/03/22 22:19:32 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_SCH_INT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

   G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptcdts.pls';
PROCEDURE Insert_Row(
          px_RELATION_SHIP_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_SHIPPING_METHODE    VARCHAR2,
          p_LEAD_TIME    NUMBER,
          p_LEAD_TIME_UOM    VARCHAR2,
          p_DELIVERY_TIME    DATE,
          p_CUTOFF_TIME    DATE,
          p_TIMEZONE_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_SAFTEY_ZONE    NUMBER,
          p_DISTANCE    NUMBER,
          p_DISTANCE_UOM    VARCHAR2);

PROCEDURE Update_Row(
          p_RELATION_SHIP_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_SHIPPING_METHODE    VARCHAR2,
          p_LEAD_TIME    NUMBER,
          p_LEAD_TIME_UOM    VARCHAR2,
          p_DELIVERY_TIME    DATE,
          p_CUTOFF_TIME    DATE,
          p_TIMEZONE_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_SAFTEY_ZONE    NUMBER,
          p_DISTANCE    NUMBER,
          p_DISTANCE_UOM    VARCHAR2);

PROCEDURE Lock_Row(
          p_RELATION_SHIP_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_SHIPPING_METHODE    VARCHAR2,
          p_LEAD_TIME    NUMBER,
          p_LEAD_TIME_UOM    VARCHAR2,
          p_DELIVERY_TIME    DATE,
          p_CUTOFF_TIME    DATE,
          p_TIMEZONE_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_SAFTEY_ZONE    NUMBER,
          p_DISTANCE    NUMBER,
          p_DISTANCE_UOM    VARCHAR2);

PROCEDURE Delete_Row(
    p_RELATION_SHIP_ID  NUMBER);
End CSP_CARRIER_DELIVERY_TIMES_PKG;

/
