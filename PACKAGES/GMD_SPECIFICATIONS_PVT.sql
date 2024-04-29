--------------------------------------------------------
--  DDL for Package GMD_SPECIFICATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPECIFICATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVSPCS.pls 120.0 2005/05/25 19:01:30 appldev noship $ */
PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_SPEC_ID IN OUT NOCOPY NUMBER,
  X_SPEC_NAME IN VARCHAR2,
  X_SPEC_VERS IN NUMBER,
  X_INVENTORY_ITEM_ID IN NUMBER,
  X_REVISION VARCHAR2,
  X_GRADE_CODE IN VARCHAR2,
  X_SPEC_STATUS IN NUMBER,
  X_OVERLAY_IND IN VARCHAR2,
  X_SPEC_TYPE IN VARCHAR2,
  X_BASE_SPEC_ID IN NUMBER,
  X_OWNER_ORGANIZATION_ID IN NUMBER,
  X_OWNER_ID IN NUMBER,
  X_SAMPLE_INV_TRANS_IND IN VARCHAR2,
  X_DELETE_MARK IN NUMBER,
  X_TEXT_CODE IN NUMBER,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  X_ATTRIBUTE20 IN VARCHAR2,
  X_ATTRIBUTE21 IN VARCHAR2,
  X_ATTRIBUTE22 IN VARCHAR2,
  X_ATTRIBUTE23 IN VARCHAR2,
  X_ATTRIBUTE24 IN VARCHAR2,
  X_ATTRIBUTE25 IN VARCHAR2,
  X_ATTRIBUTE26 IN VARCHAR2,
  X_ATTRIBUTE27 IN VARCHAR2,
  X_ATTRIBUTE28 IN VARCHAR2,
  X_ATTRIBUTE29 IN VARCHAR2,
  X_ATTRIBUTE30 IN VARCHAR2,
  X_SPEC_DESC IN VARCHAR2,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY IN NUMBER,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
);
PROCEDURE LOCK_ROW (
  X_SPEC_ID IN NUMBER,
  X_SPEC_NAME IN VARCHAR2,
  X_SPEC_VERS IN NUMBER,
  X_INVENTORY_ITEM_ID IN NUMBER,
  X_REVISION VARCHAR2,
  X_GRADE_CODE IN VARCHAR2,
  X_SPEC_STATUS IN NUMBER,
  X_OVERLAY_IND IN VARCHAR2,
  X_SPEC_TYPE IN VARCHAR2,
  X_BASE_SPEC_ID IN NUMBER,
  X_OWNER_ORGANIZATION_ID IN VARCHAR2,
  X_OWNER_ID IN NUMBER,
  X_SAMPLE_INV_TRANS_IND IN VARCHAR2,
  X_DELETE_MARK IN NUMBER,
  X_TEXT_CODE IN NUMBER,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  X_ATTRIBUTE20 IN VARCHAR2,
  X_ATTRIBUTE21 IN VARCHAR2,
  X_ATTRIBUTE22 IN VARCHAR2,
  X_ATTRIBUTE23 IN VARCHAR2,
  X_ATTRIBUTE24 IN VARCHAR2,
  X_ATTRIBUTE25 IN VARCHAR2,
  X_ATTRIBUTE26 IN VARCHAR2,
  X_ATTRIBUTE27 IN VARCHAR2,
  X_ATTRIBUTE28 IN VARCHAR2,
  X_ATTRIBUTE29 IN VARCHAR2,
  X_ATTRIBUTE30 IN VARCHAR2,
  X_SPEC_DESC IN VARCHAR2
);
PROCEDURE UPDATE_ROW (
  X_SPEC_ID IN NUMBER,
  X_SPEC_NAME IN VARCHAR2,
  X_SPEC_VERS IN NUMBER,
  X_INVENTORY_ITEM_ID IN NUMBER,
  X_REVISION VARCHAR2,
  X_GRADE_CODE IN VARCHAR2,
  X_SPEC_STATUS IN NUMBER,
  X_OVERLAY_IND IN VARCHAR2,
  X_SPEC_TYPE IN VARCHAR2,
  X_BASE_SPEC_ID IN NUMBER,
  X_OWNER_ORGANIZATION_ID IN VARCHAR2,
  X_OWNER_ID IN NUMBER,
  X_SAMPLE_INV_TRANS_IND IN VARCHAR2,
  X_DELETE_MARK IN NUMBER,
  X_TEXT_CODE IN NUMBER,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  X_ATTRIBUTE20 IN VARCHAR2,
  X_ATTRIBUTE21 IN VARCHAR2,
  X_ATTRIBUTE22 IN VARCHAR2,
  X_ATTRIBUTE23 IN VARCHAR2,
  X_ATTRIBUTE24 IN VARCHAR2,
  X_ATTRIBUTE25 IN VARCHAR2,
  X_ATTRIBUTE26 IN VARCHAR2,
  X_ATTRIBUTE27 IN VARCHAR2,
  X_ATTRIBUTE28 IN VARCHAR2,
  X_ATTRIBUTE29 IN VARCHAR2,
  X_ATTRIBUTE30 IN VARCHAR2,
  X_SPEC_DESC IN VARCHAR2,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
);

PROCEDURE ADD_LANGUAGE;

FUNCTION FETCH_ROW (
  p_specifications IN  gmd_specifications%ROWTYPE
, x_specifications OUT NOCOPY gmd_specifications%ROWTYPE
) RETURN BOOLEAN;

FUNCTION lock_row (
  p_spec_id   IN  NUMBER   DEFAULT NULL
, p_spec_name IN  VARCHAR2 DEFAULT NULL
, p_spec_vers IN  NUMBER   DEFAULT NULL
)
RETURN BOOLEAN;

FUNCTION mark_for_delete (
  p_spec_id   		IN  NUMBER   DEFAULT NULL
, p_spec_name 		IN  VARCHAR2 DEFAULT NULL
, p_spec_vers 		IN  NUMBER   DEFAULT NULL
, p_last_update_date 	IN  DATE     DEFAULT NULL
, p_last_updated_by 	IN  NUMBER   DEFAULT NULL
, p_last_update_login 	IN  NUMBER   DEFAULT NULL
)
RETURN BOOLEAN;

FUNCTION INSERT_ROW(
p_spec IN OUT NOCOPY GMD_SPECIFICATIONS%ROWTYPE
)
RETURN BOOLEAN;
END Gmd_Specifications_Pvt;

 

/