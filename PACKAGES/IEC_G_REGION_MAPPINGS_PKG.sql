--------------------------------------------------------
--  DDL for Package IEC_G_REGION_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_G_REGION_MAPPINGS_PKG" AUTHID CURRENT_USER as
/* $Header: IECRGNMS.pls 120.1 2005/07/19 13:07:13 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
	X_REGION_ID in NUMBER,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure LOCK_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
	X_REGION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
	X_REGION_ID in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure DELETE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2
);

procedure LOAD_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
  X_REGION_ID in NUMBER,
  X_OWNER in VARCHAR2
);

procedure LOAD_SEED_ROW (
  X_upload_mode	in VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
  X_REGION_ID in NUMBER,
  X_OWNER in VARCHAR2
);

procedure TRANSLATE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_PHONE_AREA_CODE in VARCHAR2,
	X_REGION_ID in NUMBER,
  X_OWNER in VARCHAR2
);

end IEC_G_REGION_MAPPINGS_PKG;

 

/
