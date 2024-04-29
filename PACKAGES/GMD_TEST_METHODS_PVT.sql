--------------------------------------------------------
--  DDL for Package GMD_TEST_METHODS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_TEST_METHODS_PVT" AUTHID CURRENT_USER as
/* $Header: GMDVMTDS.pls 120.1 2006/06/16 11:15:17 rlnagara noship $ */

PROCEDURE TRANSLATE_ROW
  (
        X_TEST_METHOD_ID                IN NUMBER,
        X_TEST_METHOD_DESC              IN VARCHAR2,
        X_OWNER                         IN VARCHAR2
   );

PROCEDURE LOAD_ROW
  (
        X_TEST_METHOD_ID                   IN  NUMBER,
        X_TEST_METHOD_CODE                 IN  VARCHAR2,
        X_TEST_METHOD_DESC                 IN  VARCHAR2,
        X_TEST_QTY                         IN  NUMBER,
        X_TEST_QTY_UOM                     IN  VARCHAR2,
        X_DELETE_MARK                      IN NUMBER,
        X_DISPLAY_PRECISION                IN NUMBER,
        X_TEST_DURATION                    IN NUMBER,
        X_DAYS                             IN NUMBER,
        X_HOURS                            IN NUMBER,
        X_MINUTES                          IN NUMBER,
        X_SECONDS                          IN NUMBER,
        X_TEST_REPLICATE                   IN NUMBER,
        X_RESOURCES                        IN VARCHAR2,
        X_TEST_KIT_ORGANIZATION_ID         IN NUMBER,
        X_TEST_KIT_INV_ITEM_ID             IN NUMBER,
        X_TEXT_CODE                        IN NUMBER,
        X_ATTRIBUTE_CATEGORY               IN VARCHAR2,
        X_ATTRIBUTE1                       IN VARCHAR2,
        X_ATTRIBUTE2                       IN VARCHAR2,
        X_ATTRIBUTE3                       IN VARCHAR2,
        X_ATTRIBUTE4                       IN VARCHAR2,
        X_ATTRIBUTE5                       IN VARCHAR2,
        X_ATTRIBUTE6                       IN VARCHAR2,
        X_ATTRIBUTE7                       IN VARCHAR2,
        X_ATTRIBUTE8                       IN VARCHAR2,
        X_ATTRIBUTE9                       IN VARCHAR2,
        X_ATTRIBUTE10                      IN VARCHAR2,
        X_ATTRIBUTE11                      IN VARCHAR2,
        X_ATTRIBUTE12                      IN VARCHAR2,
        X_ATTRIBUTE13                      IN VARCHAR2,
        X_ATTRIBUTE14                      IN VARCHAR2,
        X_ATTRIBUTE15                      IN VARCHAR2,
        X_ATTRIBUTE16                      IN VARCHAR2,
        X_ATTRIBUTE17                      IN VARCHAR2,
        X_ATTRIBUTE18                      IN VARCHAR2,
        X_ATTRIBUTE19                      IN VARCHAR2,
        X_ATTRIBUTE20                      IN VARCHAR2,
        X_ATTRIBUTE21                      IN VARCHAR2,
        X_ATTRIBUTE22                      IN VARCHAR2,
        X_ATTRIBUTE23                      IN VARCHAR2,
        X_ATTRIBUTE24                      IN VARCHAR2,
        X_ATTRIBUTE25                      IN VARCHAR2,
        X_ATTRIBUTE26                      IN VARCHAR2,
        X_ATTRIBUTE27                      IN VARCHAR2,
        X_ATTRIBUTE28                      IN VARCHAR2,
        X_ATTRIBUTE29                      IN VARCHAR2,
        X_ATTRIBUTE30                      IN VARCHAR2,
        X_OWNER                            IN VARCHAR2
  );

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TEST_METHOD_ID in NUMBER,
  X_TEST_METHOD_CODE in VARCHAR2,
  X_TEST_QTY in NUMBER,
  X_TEST_QTY_UOM in VARCHAR2,
  X_DISPLAY_PRECISION in NUMBER,
  X_TEST_DURATION in NUMBER DEFAULT 0,
  X_DAYS in NUMBER  DEFAULT 0,
  X_HOURS in NUMBER DEFAULT 0,
  X_MINUTES in NUMBER DEFAULT 0,
  X_SECONDS in NUMBER DEFAULT 0,
  X_TEST_REPLICATE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_RESOURCES in VARCHAR2,
  X_TEST_KIT_ORGANIZATION_ID in NUMBER,
  X_TEST_KIT_INV_ITEM_ID in NUMBER,
  X_TEXT_CODE in NUMBER,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_TEST_METHOD_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_TEST_METHOD_ID in NUMBER,
  X_TEST_METHOD_CODE in VARCHAR2,
  X_TEST_QTY in NUMBER,
  X_TEST_QTY_UOM in VARCHAR2,
  X_DISPLAY_PRECISION in NUMBER,
  X_TEST_DURATION in NUMBER,
  X_DAYS  in NUMBER,
  X_HOURS in NUMBER,
  X_MINUTES in NUMBER,
  X_SECONDS in NUMBER,
  X_TEST_REPLICATE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_RESOURCES in VARCHAR2,
  X_TEST_KIT_ORGANIZATION_ID in NUMBER,
  X_TEST_KIT_INV_ITEM_ID in NUMBER,
  X_TEXT_CODE in NUMBER,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_TEST_METHOD_DESC in VARCHAR2
);

procedure UPDATE_ROW (
  X_TEST_METHOD_ID in NUMBER,
  X_TEST_METHOD_CODE in VARCHAR2,
  X_TEST_QTY in NUMBER,
  X_TEST_QTY_UOM in VARCHAR2,
  X_DISPLAY_PRECISION in NUMBER,
  X_TEST_DURATION in NUMBER,
  X_DAYS  in NUMBER,
  X_HOURS in NUMBER,
  X_MINUTES in NUMBER,
  X_SECONDS in NUMBER,
  X_TEST_REPLICATE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_RESOURCES in VARCHAR2,
  X_TEST_KIT_ORGANIZATION_ID in NUMBER,
  X_TEST_KIT_INV_ITEM_ID in NUMBER,
  X_TEXT_CODE in NUMBER,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_TEST_METHOD_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_TEST_METHOD_ID in NUMBER
);

procedure ADD_LANGUAGE;

function fetch_row (p_test_methods IN  gmd_test_methods%ROWTYPE,
		    x_test_methods OUT NOCOPY gmd_test_methods%ROWTYPE ) RETURN BOOLEAN;

end GMD_TEST_METHODS_PVT;

 

/