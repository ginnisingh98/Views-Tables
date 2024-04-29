--------------------------------------------------------
--  DDL for Package PN_NOTE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_NOTE_HEADERS_PKG" AUTHID CURRENT_USER AS
/* $Header: PNTNOTHS.pls 115.8 2004/05/26 06:59:44 abanerje ship $ */
------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------
procedure INSERT_ROW
                (
                        X_ROWID                         IN OUT NOCOPY VARCHAR2,
                        X_NOTE_HEADER_ID                IN OUT NOCOPY NUMBER,
                        X_LEASE_ID                      IN            NUMBER,
                        X_NOTE_TYPE_LOOKUP_CODE         IN            VARCHAR2,
                        X_NOTE_DATE                     IN            DATE,
                        X_CREATION_DATE                 IN            DATE,
                        X_CREATED_BY                    IN            NUMBER,
                        X_LAST_UPDATE_DATE              IN            DATE,
                        X_LAST_UPDATED_BY               IN            NUMBER,
                        X_LAST_UPDATE_LOGIN             IN            NUMBER,
                        X_ATTRIBUTE_CATEGORY            IN            VARCHAR2, --3626177
 			X_ATTRIBUTE1          		IN  	      VARCHAR2,
 			X_ATTRIBUTE2          		IN  	      VARCHAR2,
 			X_ATTRIBUTE3          		IN  	      VARCHAR2,
 			X_ATTRIBUTE4          		IN  	      VARCHAR2,
 			X_ATTRIBUTE5          		IN  	      VARCHAR2,
 			X_ATTRIBUTE6          		IN  	      VARCHAR2,
 			X_ATTRIBUTE7          		IN  	      VARCHAR2,
 			X_ATTRIBUTE8          		IN  	      VARCHAR2,
 			X_ATTRIBUTE9          		IN  	      VARCHAR2,
 			X_ATTRIBUTE10         		IN  	      VARCHAR2,
 			X_ATTRIBUTE11         		IN  	      VARCHAR2,
 			X_ATTRIBUTE12         		IN  	      VARCHAR2,
 			X_ATTRIBUTE13         		IN  	      VARCHAR2,
 			X_ATTRIBUTE14         		IN  	      VARCHAR2,
 			X_ATTRIBUTE15         		IN  	      VARCHAR2
                );

------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------
procedure LOCK_ROW
                (
                        X_NOTE_HEADER_ID                IN            NUMBER,
                        X_LEASE_ID                      IN            NUMBER,
                        X_NOTE_DATE                     IN            DATE,
                        X_NOTE_TYPE_LOOKUP_CODE         IN            VARCHAR2,
			X_ATTRIBUTE_CATEGORY            IN            VARCHAR2,  --3626177
 			X_ATTRIBUTE1          		IN  	      VARCHAR2,
 			X_ATTRIBUTE2          		IN  	      VARCHAR2,
 			X_ATTRIBUTE3          		IN  	      VARCHAR2,
 			X_ATTRIBUTE4          		IN  	      VARCHAR2,
 			X_ATTRIBUTE5          		IN  	      VARCHAR2,
 			X_ATTRIBUTE6          		IN  	      VARCHAR2,
 			X_ATTRIBUTE7          		IN  	      VARCHAR2,
 			X_ATTRIBUTE8          		IN  	      VARCHAR2,
 			X_ATTRIBUTE9          		IN  	      VARCHAR2,
 			X_ATTRIBUTE10         		IN  	      VARCHAR2,
 			X_ATTRIBUTE11         		IN  	      VARCHAR2,
 			X_ATTRIBUTE12         		IN  	      VARCHAR2,
 			X_ATTRIBUTE13         		IN  	      VARCHAR2,
 			X_ATTRIBUTE14         		IN  	      VARCHAR2,
 			X_ATTRIBUTE15         		IN  	      VARCHAR2
                );

------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------
procedure UPDATE_ROW
                (
                        X_NOTE_HEADER_ID                IN            NUMBER,
                        X_LEASE_ID                      IN 	      NUMBER,
                        X_NOTE_TYPE_LOOKUP_CODE         IN 	      VARCHAR2,
                        X_NOTE_DATE                     IN 	      DATE,
                        X_LAST_UPDATE_DATE              IN 	      DATE,
                        X_LAST_UPDATED_BY               IN 	      NUMBER,
                        X_LAST_UPDATE_LOGIN             IN 	      NUMBER,
			X_ATTRIBUTE_CATEGORY            IN            VARCHAR2, --3626177
 			X_ATTRIBUTE1          		IN  	      VARCHAR2,
 			X_ATTRIBUTE2          		IN  	      VARCHAR2,
 			X_ATTRIBUTE3          		IN  	      VARCHAR2,
 			X_ATTRIBUTE4          		IN  	      VARCHAR2,
 			X_ATTRIBUTE5          		IN  	      VARCHAR2,
 			X_ATTRIBUTE6          		IN  	      VARCHAR2,
 			X_ATTRIBUTE7          		IN  	      VARCHAR2,
 			X_ATTRIBUTE8          		IN  	      VARCHAR2,
 			X_ATTRIBUTE9          		IN  	      VARCHAR2,
 			X_ATTRIBUTE10         		IN  	      VARCHAR2,
 			X_ATTRIBUTE11         		IN  	      VARCHAR2,
 			X_ATTRIBUTE12         		IN  	      VARCHAR2,
 			X_ATTRIBUTE13         		IN  	      VARCHAR2,
 			X_ATTRIBUTE14         		IN  	      VARCHAR2,
 			X_ATTRIBUTE15         		IN  	      VARCHAR2
                );

------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
------------------------------------------------------------------
procedure DELETE_ROW
                (
                        X_NOTE_HEADER_ID         in NUMBER
                );
END PN_NOTE_HEADERS_PKG;

 

/
