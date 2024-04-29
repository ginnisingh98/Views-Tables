--------------------------------------------------------
--  DDL for Package AMS_CHANNELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CHANNELS_PKG" AUTHID CURRENT_USER AS
/* $Header: amslchas.pls 115.4 2002/11/16 00:41:38 dbiswas ship $ */

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_CHANNEL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_TYPE_CODE in VARCHAR2,
  X_ORDER_SEQUENCE in NUMBER,
  X_MANAGED_BY_PERSON_ID in NUMBER,
  X_OUTBOUND_FLAG in VARCHAR2,
  X_INBOUND_FLAG in VARCHAR2,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_RATING in VARCHAR2,
  X_PREFERRED_VENDOR_ID in NUMBER,
  X_PARTY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CHANNEL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_CHANNEL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_TYPE_CODE in VARCHAR2,
  X_ORDER_SEQUENCE in NUMBER,
  X_MANAGED_BY_PERSON_ID in NUMBER,
  X_OUTBOUND_FLAG in VARCHAR2,
  X_INBOUND_FLAG in VARCHAR2,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_RATING in VARCHAR2,
  X_PREFERRED_VENDOR_ID in NUMBER,
  X_PARTY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CHANNEL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_CHANNEL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_TYPE_CODE in VARCHAR2,
  X_ORDER_SEQUENCE in NUMBER,
  X_MANAGED_BY_PERSON_ID in NUMBER,
  X_OUTBOUND_FLAG in VARCHAR2,
  X_INBOUND_FLAG in VARCHAR2,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_RATING in VARCHAR2,
  X_PREFERRED_VENDOR_ID in NUMBER,
  X_PARTY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CHANNEL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_CHANNEL_ID in NUMBER
);
procedure ADD_LANGUAGE;


procedure TRANSLATE_ROW(
       x_channel_id    in NUMBER
     , x_channel_name  in VARCHAR2
     , x_description    in VARCHAR2
     , x_owner   in VARCHAR2
 ) ;

procedure  LOAD_ROW(
  x_channel_ID   IN NUMBER,
  x_channel_TYPE_CODE in VARCHAR2 DEFAULT NULL,
  X_INBOUND_FLAG in VARCHAR2 DEFAULT 'N',
  X_OUTBOUND_FLAG in VARCHAR2  DEFAULT 'Y',
  X_ORDER_SEQUENCE  in NUMBER,
  X_MANAGED_BY_PERSON_ID in NUMBER,
  X_ACTIVE_FROM_DATE in  DATE DEFAULT SYSDATE,
  X_ACTIVE_TO_DATE in    DATE DEFAULT NULL,
  X_RATING  in   VARCHAR2,
  X_PREFERRED_VENDOR_ID in NUMBER,
  X_PARTY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2  DEFAULT NULL ,
  X_ATTRIBUTE2 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2  DEFAULT NULL,
  x_channel_NAME in VARCHAR2  DEFAULT NULL,
  X_DESCRIPTION in VARCHAR2  DEFAULT NULL ,
  X_Owner              VARCHAR2
);
END AMS_CHANNELS_PKG;

 

/