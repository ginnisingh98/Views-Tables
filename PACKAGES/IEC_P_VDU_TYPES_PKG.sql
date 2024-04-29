--------------------------------------------------------
--  DDL for Package IEC_P_VDU_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_P_VDU_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: IECVDUTS.pls 115.0.11582.2 2004/08/02 18:02:59 minwang noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VDU_TYPE_ID in NUMBER,
  X_VDU_TYPE_NAME in VARCHAR2,
	X_HARDWARE_LAYER in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure LOCK_ROW (
  X_VDU_TYPE_ID in NUMBER,
  X_VDU_TYPE_NAME in VARCHAR2,
	X_HARDWARE_LAYER in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  X_VDU_TYPE_ID in NUMBER,
  X_VDU_TYPE_NAME in VARCHAR2,
	X_HARDWARE_LAYER in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure DELETE_ROW (
  X_VDU_TYPE_ID in NUMBER
);

procedure LOAD_ROW (
  X_VDU_TYPE_ID in NUMBER,
  X_VDU_TYPE_NAME in VARCHAR2,
	X_HARDWARE_LAYER in VARCHAR2,
  X_OWNER in VARCHAR2
);

end IEC_P_VDU_TYPES_PKG;

 

/