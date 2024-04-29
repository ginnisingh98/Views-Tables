--------------------------------------------------------
--  DDL for Package Body AS_ISSUE_RELATIONSHIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_ISSUE_RELATIONSHIP_PKG" AS
/* $Header: asxifirb.pls 115.5 2002/11/06 00:41:41 appldev ship $ */
-- Start of Comments
-- Package name     : AS_ISSUE_RELATIONSHIP_PKG
G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'AS_ISSUE_RELATIONSHIP_PKG';
G_FILE_NAME 	CONSTANT VARCHAR2(12) 	:= 'asxifirb.pls';
PROCEDURE insert_row(	p_row_id		IN OUT	VARCHAR2,
			p_issue_relationship_id IN OUT	NUMBER,
			p_issue_relationship_type IN	VARCHAR2,
			p_subject_id		IN	NUMBER,
			p_object_id 	 	IN      NUMBER,
			p_start_date_active	IN      DATE,
			p_end_date_active	IN      DATE,
			p_directional_flag	IN      VARCHAR2,
			p_last_update_date    	IN	DATE,
          		p_last_updated_by    	IN	NUMBER,
          		p_creation_date    	IN	DATE,
          		p_created_by    	IN	NUMBER,
          		p_last_update_login    	IN	NUMBER,
			p_attribute_category    IN	VARCHAR2,
          		p_attribute1    	IN	VARCHAR2,
          		p_attribute2    	IN	VARCHAR2,
          		p_attribute3    	IN	VARCHAR2,
          		p_attribute4    	IN	VARCHAR2,
         		p_attribute5    	IN	VARCHAR2,
          		p_attribute6    	IN	VARCHAR2,
          		p_attribute7    	IN	VARCHAR2,
         		p_attribute8    	IN	VARCHAR2,
          		p_attribute9    	IN	VARCHAR2,
          		p_attribute10   	IN	VARCHAR2,
          		p_attribute11    	IN	VARCHAR2,
          		p_attribute12   	IN	VARCHAR2,
          		p_attribute13    	IN	VARCHAR2,
          		p_attribute14    	IN	VARCHAR2,
          		p_attribute15    	IN	VARCHAR2)	IS
   		CURSOR C1 IS 	SELECT AS_ISSUE_RELATIONSHIPS_S.nextval FROM sys.dual;
		CURSOR C2 IS 	SELECT ROWID FROM as_issue_relationships
    				WHERE issue_relationship_id = p_issue_relationship_id;
BEGIN
   IF (p_issue_relationship_id IS NULL) OR (p_issue_relationship_id = FND_API.G_MISS_NUM) THEN
       		OPEN C1;
       			FETCH C1 INTO p_issue_relationship_id;
       		CLOSE C1;
   END IF;
	INSERT INTO AS_ISSUE_RELATIONSHIPS (	issue_relationship_id ,
						subject_id,
						object_id,
						issue_relationship_type,
						directional_flag,
						start_date_active,
						end_date_active,
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
						(DECODE(p_issue_relationship_id, FND_API.G_MISS_NUM, NULL, p_issue_relationship_id),
						DECODE(p_subject_id, FND_API.G_MISS_NUM, NULL, p_subject_id),
						DECODE(p_object_id, FND_API.G_MISS_NUM, NULL, p_object_id),
						DECODE(p_issue_relationship_type, FND_API.G_MISS_CHAR, NULL, p_issue_relationship_type),
						DECODE(p_directional_flag, FND_API.G_MISS_CHAR, NULL, p_directional_flag),
						DECODE(p_start_date_active, FND_API.G_MISS_DATE, NULL, p_start_date_active),
						DECODE(p_end_date_active, FND_API.G_MISS_DATE, NULL, p_end_date_active),
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

PROCEDURE update_row (  p_issue_relationship_id  IN     NUMBER,
			p_issue_relationship_type IN	VARCHAR2,
			p_subject_id		IN	NUMBER,
			p_object_id		IN 	NUMBER,
			p_start_date_active	IN 	DATE,
			p_end_date_active	IN 	DATE,
			p_directional_flag	IN	VARCHAR2,
			p_last_update_date      IN	DATE,
          		p_last_updated_by    	IN	NUMBER,
          		p_creation_date    	IN	DATE,
          		p_created_by    	IN	NUMBER,
          		p_last_update_login     IN	NUMBER,
			p_attribute_category    IN 	VARCHAR2,
          		p_attribute1    	IN	VARCHAR2,
          		p_attribute2    	IN	VARCHAR2,
          		p_attribute3    	IN	VARCHAR2,
          		p_attribute4    	IN	VARCHAR2,
         		p_attribute5    	IN	VARCHAR2,
          		p_attribute6    	IN	VARCHAR2,
          		p_attribute7    	IN	VARCHAR2,
         		p_attribute8    	IN	VARCHAR2,
          		p_attribute9    	IN	VARCHAR2,
          		p_attribute10   	IN	VARCHAR2,
          		p_attribute11    	IN	VARCHAR2,
          		p_attribute12   	IN	VARCHAR2,
          		p_attribute13    	IN	VARCHAR2,
          		p_attribute14    	IN	VARCHAR2,
          		p_attribute15    	IN	VARCHAR2)	IS
BEGIN
 			 UPDATE AS_ISSUE_RELATIONSHIPS SET
    				SUBJECT_ID			=	DECODE(p_subject_id, FND_API.G_MISS_NUM, SUBJECT_ID, p_subject_id),
				OBJECT_ID			=	DECODE(p_object_id, FND_API.G_MISS_NUM, OBJECT_ID, p_object_id),
				ISSUE_RELATIONSHIP_TYPE	=	DECODE(p_issue_relationship_type, FND_API.G_MISS_CHAR, ISSUE_RELATIONSHIP_TYPE, p_issue_relationship_type),
				DIRECTIONAL_FLAG		=	DECODE(p_directional_flag, FND_API.G_MISS_CHAR, DIRECTIONAL_FLAG, p_directional_flag),
				START_DATE_ACTIVE		=	DECODE(p_start_date_active, FND_API.G_MISS_DATE, START_DATE_ACTIVE, p_start_date_active),
				END_DATE_ACTIVE		=	DECODE(p_end_date_active, FND_API.G_MISS_DATE, END_DATE_ACTIVE, p_end_date_active),
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

  				WHERE ISSUE_RELATIONSHIP_ID 	= 	P_ISSUE_RELATIONSHIP_ID ;
  		IF 	(SQL%NOTFOUND) THEN
    			RAISE NO_DATA_FOUND;
  		END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ROW   (p_issue_relationship_id 	IN NUMBER ) IS
		BEGIN
  				DELETE FROM AS_ISSUE_RELATIONSHIPS
  				WHERE ISSUE_RELATIONSHIP_ID = P_ISSUE_RELATIONSHIP_ID;
  			IF 	(SQL%NOTFOUND) THEN
    				RAISE NO_DATA_FOUND;
  			END IF;
		END DELETE_ROW;
END AS_ISSUE_RELATIONSHIP_PKG;

/
