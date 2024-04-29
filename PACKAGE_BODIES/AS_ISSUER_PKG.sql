--------------------------------------------------------
--  DDL for Package Body AS_ISSUER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_ISSUER_PKG" AS
/* $Header: asxifipb.pls 115.5 2002/11/06 00:41:30 appldev ship $ */
-- Start of Comments
-- Package name     : AS_ISSUER_PKG
G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'AS_ISSUER_PKG';
G_FILE_NAME 	CONSTANT VARCHAR2(12) 	:= 'asxtifib.pls';
PROCEDURE insert_row(      	p_row_id                IN OUT  VARCHAR2,
                    		p_party_id              IN      NUMBER,
                    		p_target_cap            IN      NUMBER,
                    		p_last_update_date      IN      DATE,
                   	 	p_last_updated_by       IN      NUMBER,
                    		p_creation_date         IN      DATE,
                    		p_created_by            IN      NUMBER,
                    		p_last_update_login     IN      NUMBER,
                    		p_attribute_category    IN      VARCHAR2,
                    		p_attribute1            IN      VARCHAR2,
                    		p_attribute2            IN      VARCHAR2,
                    		p_attribute3            IN      VARCHAR2,
                    		p_attribute4            IN      VARCHAR2,
                    		p_attribute5            IN      VARCHAR2,
                    		p_attribute6            IN      VARCHAR2,
                    		p_attribute7            IN      VARCHAR2,
                    		p_attribute8            IN      VARCHAR2,
                    		p_attribute9            IN      VARCHAR2,
                    		p_attribute10           IN      VARCHAR2,
                    		p_attribute11           IN      VARCHAR2,
                    		p_attribute12           IN      VARCHAR2,
                    		p_attribute13           IN      VARCHAR2,
                    		p_attribute14           IN      VARCHAR2,
                    		p_attribute15           IN      VARCHAR2) IS
		CURSOR C2 IS 	SELECT ROWID FROM as_issuer
    				WHERE party_id = p_party_id;
BEGIN
		INSERT INTO AS_ISSUER 	(party_id,
						target_cap,
						last_update_date,
          					last_updated_by ,
          					creation_date,
          					created_by,
          					last_update_login,
						attribute_category ,
          					attribute1 ,
          					attribute2 ,
          					attribute3 ,
          					attribute4,
         					attribute5,
          					attribute6 ,
          					attribute7,
         					attribute8 ,
          					attribute9,
          					attribute10,
          					attribute11,
          					attribute12,
          					attribute13,
          					attribute14 ,
          					attribute15 ) VALUES
						(DECODE(p_party_id, FND_API.G_MISS_NUM, NULL, p_party_id),
						DECODE(p_target_cap, FND_API.G_MISS_NUM, NULL, p_target_cap),
						DECODE(p_last_update_date, FND_API.G_MISS_DATE, TO_DATE(NULL), p_last_update_date),
        					DECODE(p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by),
        					DECODE(p_creation_date, FND_API.G_MISS_DATE, TO_DATE(NULL), p_creation_date),
       					DECODE(p_created_by, FND_API.G_MISS_NUM, NULL, p_created_by),
        					DECODE(p_last_update_login, FND_API.G_MISS_NUM, NULL, p_last_update_login),
						DECODE(p_attribute_category, FND_API.G_MISS_CHAR, NULL, p_attribute_category),
        					DECODE(p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1),
        					DECODE(p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2),
        					DECODE(p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3),
        					DECODE(p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4),
        					DECODE(p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5),
        					DECODE(p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6),
        					DECODE(p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7),
        					DECODE(p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8),
        					DECODE(p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9),
        					DECODE(p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
        					DECODE(p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
        					DECODE(p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
        					DECODE(p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
        					DECODE(p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
        					DECODE(p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15));

		OPEN c2;
  			FETCH c2 INTO p_row_id;
  			IF (c2%NOTFOUND) THEN
    				CLOSE c2;
    				RAISE no_data_found;
  			END IF;
  		CLOSE c2;
END INSERT_ROW;
PROCEDURE update_row (	p_party_id  			IN NUMBER,
			p_target_cap			IN NUMBER,
			p_last_update_date    		IN DATE,
          		p_last_updated_by    		IN NUMBER,
          		p_creation_date    		IN DATE,
          		p_created_by    		IN NUMBER,
          		p_last_update_login    		IN NUMBER,
			p_attribute_category    	IN VARCHAR2,
          		p_attribute1    		IN VARCHAR2,
          		p_attribute2    		IN VARCHAR2,
          		p_attribute3    		IN VARCHAR2,
          		p_attribute4    		IN VARCHAR2,
         		p_attribute5    		IN VARCHAR2,
          		p_attribute6    		IN VARCHAR2,
          		p_attribute7    		IN VARCHAR2,
         		p_attribute8    		IN VARCHAR2,
          		p_attribute9    		IN VARCHAR2,
          		p_attribute10   		IN VARCHAR2,
          		p_attribute11    		IN VARCHAR2,
          		p_attribute12   		IN VARCHAR2,
          		p_attribute13    		IN VARCHAR2,
          		p_attribute14    		IN VARCHAR2,
          		p_attribute15    		IN VARCHAR2) IS
BEGIN
 			 UPDATE AS_ISSUER SET
				TARGET_CAP			=	DECODE(P_TARGET_CAP, FND_API.G_MISS_NUM, TARGET_CAP, P_TARGET_CAP),
    				ATTRIBUTE1 		= 	DECODE(P_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, P_ATTRIBUTE1),
    				ATTRIBUTE2 		= 	DECODE(P_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, P_ATTRIBUTE2),
    				ATTRIBUTE3 		= 	DECODE(P_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, P_ATTRIBUTE3),
    				ATTRIBUTE4 		= 	DECODE(P_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, P_ATTRIBUTE4),
   				ATTRIBUTE5 		= 	DECODE(P_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, P_ATTRIBUTE5),
    				ATTRIBUTE6 		= 	DECODE(P_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, P_ATTRIBUTE6),
    				ATTRIBUTE7 		= 	DECODE(P_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, P_ATTRIBUTE7),
   				ATTRIBUTE8		= 	DECODE(P_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, P_ATTRIBUTE8),
    				ATTRIBUTE9 		= 	DECODE(P_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, P_ATTRIBUTE9),
    				ATTRIBUTE10 		= 	DECODE(P_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, P_ATTRIBUTE10),
    				ATTRIBUTE11 		= 	DECODE(P_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, P_ATTRIBUTE11),
   				ATTRIBUTE12 		= 	DECODE(P_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, P_ATTRIBUTE12),
    				ATTRIBUTE13 		= 	DECODE(P_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, P_ATTRIBUTE13),
    				ATTRIBUTE14 		= 	DECODE(P_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, P_ATTRIBUTE14),
    				ATTRIBUTE15 		= 	DECODE(P_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, P_ATTRIBUTE15),
    				ATTRIBUTE_CATEGORY 	= 	DECODE(P_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, P_ATTRIBUTE_CATEGORY),
    				LAST_UPDATE_DATE		= DECODE(P_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, P_LAST_UPDATE_DATE),
        			LAST_UPDATED_BY		= DECODE(P_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, P_LAST_UPDATED_BY),
        			CREATION_DATE		= DECODE(P_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, P_CREATION_DATE),
        			CREATED_BY			= DECODE(P_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, P_CREATED_BY),
        			LAST_UPDATE_LOGIN		= DECODE(P_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, P_LAST_UPDATE_LOGIN)

  				WHERE PARTY_ID 			= 	P_PARTY_ID ;
  		IF 	(SQL%NOTFOUND) THEN
    			RAISE NO_DATA_FOUND;
  		END IF;
  	IF 	(SQL%NOTFOUND) THEN
    		RAISE no_data_found;
  	END IF;
END UPDATE_ROW;
PROCEDURE DELETE_ROW   (p_party_id 		IN 	NUMBER	) IS
		BEGIN
  				DELETE 	FROM AS_ISSUER
  				WHERE 	PARTY_ID = P_PARTY_ID ;
  			IF 	(SQL%NOTFOUND) THEN
    				RAISE no_data_found;
  			END IF;
		END DELETE_ROW;
END AS_ISSUER_PKG;

/
