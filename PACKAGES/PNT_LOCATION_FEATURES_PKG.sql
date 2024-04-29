--------------------------------------------------------
--  DDL for Package PNT_LOCATION_FEATURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNT_LOCATION_FEATURES_PKG" AUTHID CURRENT_USER AS
/* $Header: PNTFEATS.pls 115.11 2002/11/14 20:25:06 stripath ship $ */

-------------------------------------------------------------------------
-- PROCEDURE insert_row
-- HISTORY:
-- 09-JUL-02  ftanudja  o added parameter x_org_id for shared serv enh.
-------------------------------------------------------------------------

PROCEDURE insert_row (
				 x_rowid                   IN OUT NOCOPY VARCHAR2
                                ,x_org_id                  IN     NUMBER DEFAULT NULL
				,x_LOCATION_FEATURE_ID     IN OUT NOCOPY NUMBER
				,x_LAST_UPDATE_DATE               DATE
				,x_LAST_UPDATED_BY                NUMBER
				,x_CREATION_DATE                  DATE
				,x_CREATED_BY                     NUMBER
				,x_LAST_UPDATE_LOGIN              NUMBER
				,x_LOCATION_ID                    NUMBER
				,x_LOCATION_FEATURE_LOOKUP_CODE   VARCHAR2
				,x_DESCRIPTION                    VARCHAR2
				,x_QUANTITY                       NUMBER
				,x_FEATURE_SIZE                   NUMBER
				,x_UOM_CODE                       VARCHAR2
				,x_CONDITION_LOOKUP_CODE          VARCHAR2
				,x_ATTRIBUTE_CATEGORY             VARCHAR2
				,x_ATTRIBUTE1                     VARCHAR2
				,x_ATTRIBUTE2                     VARCHAR2
				,x_ATTRIBUTE3                     VARCHAR2
				,x_ATTRIBUTE4                     VARCHAR2
				,x_ATTRIBUTE5                     VARCHAR2
				,x_ATTRIBUTE6                     VARCHAR2
				,x_ATTRIBUTE7                     VARCHAR2
				,x_ATTRIBUTE8                     VARCHAR2
				,x_ATTRIBUTE9                     VARCHAR2
				,x_ATTRIBUTE10                    VARCHAR2
				,x_ATTRIBUTE11                    VARCHAR2
				,x_ATTRIBUTE12                    VARCHAR2
				,x_ATTRIBUTE13                    VARCHAR2
				,x_ATTRIBUTE14                    VARCHAR2
				,x_ATTRIBUTE15                    VARCHAR2
				 );

PROCEDURE UPDATE_ROW (
				 x_rowid                          VARCHAR2
				,x_LOCATION_FEATURE_ID            NUMBER
				,x_LAST_UPDATE_DATE               DATE
				,x_LAST_UPDATED_BY                NUMBER
				,x_CREATION_DATE                  DATE
				,x_CREATED_BY                     NUMBER
				,x_LAST_UPDATE_LOGIN              NUMBER
				,x_LOCATION_ID                    NUMBER
				,x_LOCATION_FEATURE_LOOKUP_CODE   VARCHAR2
				,x_DESCRIPTION                    VARCHAR2
				,x_QUANTITY                       NUMBER
				,x_FEATURE_SIZE                   NUMBER
				,x_UOM_CODE                       VARCHAR2
				,x_CONDITION_LOOKUP_CODE          VARCHAR2
				,x_ATTRIBUTE_CATEGORY             VARCHAR2
				,x_ATTRIBUTE1                     VARCHAR2
				,x_ATTRIBUTE2                     VARCHAR2
				,x_ATTRIBUTE3                     VARCHAR2
				,x_ATTRIBUTE4                     VARCHAR2
				,x_ATTRIBUTE5                     VARCHAR2
				,x_ATTRIBUTE6                     VARCHAR2
				,x_ATTRIBUTE7                     VARCHAR2
				,x_ATTRIBUTE8                     VARCHAR2
				,x_ATTRIBUTE9                     VARCHAR2
				,x_ATTRIBUTE10                    VARCHAR2
				,x_ATTRIBUTE11                    VARCHAR2
				,x_ATTRIBUTE12                    VARCHAR2
				,x_ATTRIBUTE13                    VARCHAR2
				,x_ATTRIBUTE14                    VARCHAR2
				,x_ATTRIBUTE15                    VARCHAR2
                     );

PROCEDURE lock_row   (
				 x_rowid                          VARCHAR2
				,x_LOCATION_FEATURE_ID            NUMBER
				,x_LOCATION_ID                    NUMBER
				,x_LOCATION_FEATURE_LOOKUP_CODE   VARCHAR2
				,x_DESCRIPTION                    VARCHAR2
				,x_QUANTITY                       NUMBER
				,x_FEATURE_SIZE                   NUMBER
				,x_UOM_CODE                       VARCHAR2
				,x_CONDITION_LOOKUP_CODE          VARCHAR2
				,x_ATTRIBUTE_CATEGORY             VARCHAR2
				,x_ATTRIBUTE1                     VARCHAR2
				,x_ATTRIBUTE2                     VARCHAR2
				,x_ATTRIBUTE3                     VARCHAR2
				,x_ATTRIBUTE4                     VARCHAR2
				,x_ATTRIBUTE5                     VARCHAR2
				,x_ATTRIBUTE6                     VARCHAR2
				,x_ATTRIBUTE7                     VARCHAR2
				,x_ATTRIBUTE8                     VARCHAR2
				,x_ATTRIBUTE9                     VARCHAR2
				,x_ATTRIBUTE10                    VARCHAR2
				,x_ATTRIBUTE11                    VARCHAR2
				,x_ATTRIBUTE12                    VARCHAR2
				,x_ATTRIBUTE13                    VARCHAR2
				,x_ATTRIBUTE14                    VARCHAR2
				,x_ATTRIBUTE15                    VARCHAR2
                     );
PROCEDURE delete_row   (
				x_LOCATION_FEATURE_ID            NUMBER
						);
END PNT_LOCATION_FEATURES_PKG;

 

/
