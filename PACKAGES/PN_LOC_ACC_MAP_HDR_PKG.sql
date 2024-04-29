--------------------------------------------------------
--  DDL for Package PN_LOC_ACC_MAP_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_LOC_ACC_MAP_HDR_PKG" AUTHID CURRENT_USER AS
  --$Header: PNACCMPS.pls 115.1 2003/07/11 14:40:53 atuppad noship $

-- PROCEDURE : INSERT_ROW
PROCEDURE insert_row (
x_LOC_ACC_MAP_HDR_ID                IN OUT NOCOPY        NUMBER,
x_MAPPING_NAME                      IN                   VARCHAR2,
x_last_update_date                  IN                   DATE,
x_last_updated_by                   IN                   NUMBER,
x_creation_date                     IN                   DATE,
x_created_by                        IN                   NUMBER,
x_last_update_login                 IN                   NUMBER,
x_attribute_category 	            IN                   VARCHAR2,
x_attribute1		            IN	           	 VARCHAR2,
x_attribute2		            IN		         VARCHAR2,
x_attribute3		            IN		         VARCHAR2,
x_attribute4		            IN		         VARCHAR2,
x_attribute5		            IN		         VARCHAR2,
x_attribute6		            IN		         VARCHAR2,
x_attribute7		            IN		         VARCHAR2,
x_attribute8		            IN		         VARCHAR2,
x_attribute9		            IN		         VARCHAR2,
x_attribute10		            IN		         VARCHAR2,
x_attribute11		            IN		         VARCHAR2,
x_attribute12		            IN		         VARCHAR2,
x_attribute13		            IN		         VARCHAR2,
x_attribute14		            IN		         VARCHAR2,
x_attribute15		            IN		         VARCHAR2,
x_ORG_ID		            IN                   NUMBER  default NULL
);

-- PROCEDURE : UPDATE_ROW
PROCEDURE update_row (
x_LOC_ACC_MAP_HDR_ID                IN                   NUMBER,
x_MAPPING_NAME                      IN                   VARCHAR2,
x_last_update_date                  IN                   DATE,
x_last_updated_by                   IN                   NUMBER,
x_last_update_login                 IN                   NUMBER,
x_attribute_category 	            IN                   VARCHAR2,
x_attribute1		            IN	           	 VARCHAR2,
x_attribute2		            IN		         VARCHAR2,
x_attribute3		            IN		         VARCHAR2,
x_attribute4		            IN		         VARCHAR2,
x_attribute5		            IN		         VARCHAR2,
x_attribute6		            IN		         VARCHAR2,
x_attribute7		            IN		         VARCHAR2,
x_attribute8		            IN		         VARCHAR2,
x_attribute9		            IN		         VARCHAR2,
x_attribute10		            IN		         VARCHAR2,
x_attribute11		            IN		         VARCHAR2,
x_attribute12		            IN		         VARCHAR2,
x_attribute13		            IN		         VARCHAR2,
x_attribute14		            IN		         VARCHAR2,
x_attribute15		            IN		         VARCHAR2
);

-- PROCEDURE : LOCK_ROW
PROCEDURE lock_row (
x_LOC_ACC_MAP_HDR_ID                IN                   NUMBER,
x_MAPPING_NAME                      IN                   VARCHAR2,
x_attribute_category 	            IN                   VARCHAR2,
x_attribute1		            IN	       	         VARCHAR2,
x_attribute2		            IN		         VARCHAR2,
x_attribute3		            IN		         VARCHAR2,
x_attribute4		            IN		         VARCHAR2,
x_attribute5		            IN		         VARCHAR2,
x_attribute6		            IN		         VARCHAR2,
x_attribute7		            IN		         VARCHAR2,
x_attribute8		            IN		         VARCHAR2,
x_attribute9		            IN		         VARCHAR2,
x_attribute10		            IN		         VARCHAR2,
x_attribute11		            IN		         VARCHAR2,
x_attribute12		            IN		         VARCHAR2,
x_attribute13		            IN		         VARCHAR2,
x_attribute14		            IN		         VARCHAR2,
x_attribute15		            IN		         VARCHAR2
);

-- PROCEDURE : DELETE_ROW
PROCEDURE delete_row (
	x_LOC_ACC_MAP_HDR_ID	   IN    NUMBER
);

END PN_LOC_ACC_MAP_HDR_PKG;

 

/
