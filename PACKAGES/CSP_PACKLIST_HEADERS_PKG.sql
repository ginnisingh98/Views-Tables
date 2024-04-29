--------------------------------------------------------
--  DDL for Package CSP_PACKLIST_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PACKLIST_HEADERS_PKG" AUTHID CURRENT_USER as
/* $Header: cspttahs.pls 115.4 2002/12/12 20:31:42 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PACKLIST_HEADERS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PACKLIST_HEADER_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_NUMBER    VARCHAR2,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_PACKLIST_STATUS    VARCHAR2,
          p_DATE_CREATED    DATE,
          p_DATE_PACKED    DATE,
          p_DATE_SHIPPED    DATE,
          p_DATE_RECEIVED    DATE,
          p_CARRIER    VARCHAR2,
          p_SHIPMENT_METHOD    VARCHAR2,
          p_WAYBILL    VARCHAR2,
          p_COMMENTS    VARCHAR2,
          p_LOCATION_ID	NUMBER,
          p_PARTY_SITE_ID NUMBER DEFAULT NULL,
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
          p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Update_Row(
          p_PACKLIST_HEADER_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_NUMBER    VARCHAR2,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_PACKLIST_STATUS    VARCHAR2,
          p_DATE_CREATED    DATE,
          p_DATE_PACKED    DATE,
          p_DATE_SHIPPED    DATE,
          p_DATE_RECEIVED    DATE,
          p_CARRIER    VARCHAR2,
          p_SHIPMENT_METHOD    VARCHAR2,
          p_WAYBILL    VARCHAR2,
          p_COMMENTS    VARCHAR2,
          p_LOCATION_ID	NUMBER,
          p_PARTY_SITE_ID NUMBER DEFAULT NULL,
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
          p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Lock_Row(
          p_PACKLIST_HEADER_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_NUMBER    VARCHAR2,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_PACKLIST_STATUS    VARCHAR2,
          p_DATE_CREATED    DATE,
          p_DATE_PACKED    DATE,
          p_DATE_SHIPPED    DATE,
          p_DATE_RECEIVED    DATE,
          p_CARRIER    VARCHAR2,
          p_SHIPMENT_METHOD    VARCHAR2,
          p_WAYBILL    VARCHAR2,
          p_COMMENTS    VARCHAR2,
          p_LOCATION_ID	NUMBER,
          p_PARTY_SITE_ID NUMBER DEFAULT NULL,
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
          p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Delete_Row(
    p_PACKLIST_HEADER_ID  NUMBER);
End CSP_PACKLIST_HEADERS_PKG;

 

/
