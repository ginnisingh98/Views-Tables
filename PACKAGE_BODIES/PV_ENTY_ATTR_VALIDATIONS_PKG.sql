--------------------------------------------------------
--  DDL for Package Body PV_ENTY_ATTR_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTY_ATTR_VALIDATIONS_PKG" as
/* $Header: pvxtatvb.pls 115.1 2002/12/10 19:40:13 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ATTRIBUTE_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ENTY_ATTR_VALIDATIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtatvb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
		px_enty_attr_validation_id      IN OUT NOCOPY NUMBER,
		p_last_update_date		 DATE,
		p_last_updated_by		 NUMBER,
		p_creation_date			 DATE,
		p_created_by			 NUMBER,
		p_last_update_login		 NUMBER,
		px_object_version_number   IN OUT NOCOPY NUMBER,
		p_validation_date		   DATE,
		p_validated_by_resource_id        NUMBER,
		p_validation_document_id	         NUMBER,
		p_validation_note		 VARCHAR2)
 IS

	x_rowid    VARCHAR2(30);

BEGIN

   px_object_version_number := 1;

   INSERT INTO PV_ENTY_ATTR_VALIDATIONS (
     VALIDATION_ID,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     OBJECT_VERSION_NUMBER,
	 VALIDATION_DATE,
     VALIDATED_BY_RESOURCE_ID,
     VALIDATION_DOCUMENT_ID,
     VALIDATION_NOTE
   ) VALUES (
        DECODE( px_enty_attr_validation_id, Fnd_Api.g_miss_num, NULL, px_enty_attr_validation_id)
       ,DECODE( p_last_update_date, Fnd_Api.g_miss_date, NULL, p_last_update_date)
       ,DECODE( p_last_updated_by, Fnd_Api.g_miss_num, NULL, p_last_updated_by)
       ,DECODE( p_creation_date, Fnd_Api.g_miss_date, NULL, p_creation_date)
       ,DECODE( p_created_by, Fnd_Api.g_miss_num, NULL, p_created_by)
       ,DECODE( p_last_update_login, Fnd_Api.g_miss_num, NULL, p_last_update_login)
       ,DECODE( px_object_version_number, Fnd_Api.g_miss_num, NULL, px_object_version_number)
	   ,DECODE( p_validation_date, Fnd_Api.g_miss_date, NULL, p_validation_date)
       ,DECODE( p_validated_by_resource_id, Fnd_Api.g_miss_num, NULL, p_validated_by_resource_id)
       ,DECODE( p_validation_document_id, Fnd_Api.g_miss_num, NULL, p_validation_document_id)
       ,DECODE( p_validation_note, Fnd_Api.g_miss_char, NULL, p_validation_note)
       );

END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
			p_enty_attr_validation_id       NUMBER,
			p_last_update_date	      DATE,
			p_last_updated_by	      NUMBER,
			p_last_update_login	      NUMBER,
			p_object_version_number    NUMBER,
			p_validation_date		   DATE,
			p_validated_by_resource_id NUMBER,
			p_validation_document_id   NUMBER,
			p_validation_note	      VARCHAR2
          )

 IS

 BEGIN

    UPDATE PV_ENTY_ATTR_VALIDATIONS
    SET
             validation_id               = DECODE( p_enty_attr_validation_id, Fnd_Api.g_miss_num, validation_id, p_enty_attr_validation_id)
            ,last_update_date            = DECODE( p_last_update_date, Fnd_Api.g_miss_date, last_update_date, p_last_update_date)
            ,last_updated_by             = DECODE( p_last_updated_by, Fnd_Api.g_miss_num, last_updated_by, p_last_updated_by)
            ,last_update_login           = DECODE( p_last_update_login, Fnd_Api.g_miss_num, last_update_login, p_last_update_login)
            ,object_version_number       = DECODE( p_object_version_number, Fnd_Api.g_miss_num, object_version_number, p_object_version_number+1)
			,validation_date		   = DECODE( p_validation_date, Fnd_Api.g_miss_date, validation_date, p_validation_date)
			,validated_by_resource_id    = DECODE( p_validated_by_resource_id, Fnd_Api.g_miss_num, validated_by_resource_id, p_validated_by_resource_id)
			,validation_document_id      = DECODE( p_validation_document_id, Fnd_Api.g_miss_num, validation_document_id, p_validation_document_id)
			,validation_note		   = DECODE( p_validation_note, Fnd_Api.g_miss_char, validation_note, p_validation_note)

	WHERE VALIDATION_ID = P_ENTY_ATTR_VALIDATION_ID
	AND   object_version_number = p_object_version_number;

	IF (SQL%NOTFOUND) THEN
      RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

END Update_Row;

----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------
--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================

PROCEDURE Delete_Row(
		p_enty_attr_validation_id  NUMBER)

 IS

 BEGIN

   DELETE FROM PV_ENTY_ATTR_VALIDATIONS
     WHERE validation_id = p_enty_attr_validation_id;

   IF (SQL%NOTFOUND) THEN
     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

 END Delete_Row ;

----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------
--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================

PROCEDURE Lock_Row(
			p_enty_attr_validation_id       NUMBER,
			p_last_update_date	      DATE,
			p_last_updated_by	      NUMBER,
			p_creation_date	      DATE,
			p_created_by		      NUMBER,
			p_last_update_login	      NUMBER,
			p_object_version_number    NUMBER,
			p_validation_date		   DATE,
			p_validated_by_resource_id NUMBER,
			p_validation_document_id   NUMBER,
			p_validation_note	      VARCHAR2
			)

 IS

   CURSOR C IS
        SELECT *
         FROM PV_ENTY_ATTR_VALIDATIONS
        WHERE VALIDATION_ID =  p_enty_attr_validation_id
        FOR UPDATE OF VALIDATION_ID NOWAIT;

   Recinfo C%ROWTYPE;

 BEGIN

    OPEN c;

    FETCH c INTO Recinfo;
    IF (c%NOTFOUND) THEN
        CLOSE c;
        Fnd_Message.SET_NAME('FND', 'FORM_RECORD_DELETED');
        App_Exception.RAISE_EXCEPTION;
    END IF;

    CLOSE C;

    IF
    (
           (Recinfo.validation_id = p_enty_attr_validation_id )
       AND (( Recinfo.last_update_date = p_last_update_date) OR
	      (( Recinfo.last_update_date IS NULL ) AND ( p_last_update_date IS NULL )))

       AND (( Recinfo.last_updated_by = p_last_updated_by)  OR
              (( Recinfo.last_updated_by IS NULL ) AND (p_last_updated_by IS NULL )))

       AND (( Recinfo.creation_date = p_creation_date) OR
              (( Recinfo.creation_date IS NULL )   AND (p_creation_date IS NULL )))

       AND (( Recinfo.created_by = p_created_by) OR
              (( Recinfo.created_by IS NULL )  AND (  p_created_by IS NULL )))

       AND (( Recinfo.last_update_login = p_last_update_login) OR
              (( Recinfo.last_update_login IS NULL ) AND (  p_last_update_login IS NULL )))

       AND (( Recinfo.object_version_number = p_object_version_number) OR
              (( Recinfo.object_version_number IS NULL )  AND (  p_object_version_number IS NULL )))

	   AND (( Recinfo.validation_date = p_validation_date) OR
              (( Recinfo.validation_date IS NULL ) AND (  p_validation_date IS NULL )))

       AND (( Recinfo.validated_by_resource_id = p_validated_by_resource_id) OR
              (( Recinfo.validated_by_resource_id IS NULL )  AND (  p_validated_by_resource_id IS NULL )))

       AND (( Recinfo.validation_document_id = p_validation_document_id)  OR
              (( Recinfo.validation_document_id IS NULL ) AND (  p_validation_document_id IS NULL )))

       AND (( Recinfo.validation_note = p_validation_note) OR
              (( Recinfo.validation_note IS NULL ) AND (  p_validation_note IS NULL )))
    )


  THEN
       RETURN;

   ELSE
       Fnd_Message.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       App_Exception.RAISE_EXCEPTION;
   END IF;

END Lock_Row;


END PV_ENTY_ATTR_VALIDATIONS_PKG;

/
