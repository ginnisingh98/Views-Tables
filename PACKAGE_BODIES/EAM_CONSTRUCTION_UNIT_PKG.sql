--------------------------------------------------------
--  DDL for Package Body EAM_CONSTRUCTION_UNIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CONSTRUCTION_UNIT_PKG" as
/* $Header: EAMTCUB.pls 120.0.12010000.2 2008/11/13 12:20:58 dsingire noship $ */

PROCEDURE Insert_CU_Row(
      px_cu_id		  IN OUT      NOCOPY  NUMBER
     ,p_cu_name		  IN          VARCHAR2
     ,p_description	  IN          VARCHAR2
     ,p_organization_id	  IN          NUMBER
     ,p_cu_effective_from IN          DATE
     ,p_cu_effective_to   IN          DATE
     ,p_attribute_category  IN        VARCHAR2
     ,p_attribute1        IN          VARCHAR2
     ,p_attribute2        IN          VARCHAR2
     ,p_attribute3        IN          VARCHAR2
     ,p_attribute4        IN          VARCHAR2
     ,p_attribute5        IN          VARCHAR2
     ,p_attribute6        IN          VARCHAR2
     ,p_attribute7        IN          VARCHAR2
     ,p_attribute8        IN          VARCHAR2
     ,p_attribute9        IN          VARCHAR2
     ,p_attribute10       IN          VARCHAR2
     ,p_attribute11       IN          VARCHAR2
     ,p_attribute12       IN          VARCHAR2
     ,p_attribute13       IN          VARCHAR2
     ,p_attribute14       IN          VARCHAR2
     ,p_attribute15       IN          VARCHAR2
     ,p_creation_date     IN          DATE
     ,p_created_by        IN          NUMBER
     ,p_last_update_date  IN          DATE
     ,p_last_updated_by   IN          NUMBER
     ,p_last_update_login IN          NUMBER
      )  IS

  CURSOR C1 IS
	SELECT EAM_CONSTRUCTION_UNITS_S.nextval
	FROM   dual;
BEGIN
   IF (px_cu_id IS NULL) OR (px_cu_id = FND_API.G_MISS_NUM) then
      OPEN C1;
      FETCH C1 INTO px_cu_id;
      CLOSE C1;
   END IF;

  INSERT INTO EAM_CONSTRUCTION_UNITS(
      CU_ID,
      CU_NAME,
      DESCRIPTION,
      ORGANIZATION_ID,
      CU_EFFECTIVE_FROM,
      CU_EFFECTIVE_TO,
      ATTRIBUTE_CATEGORY,
		  ATTRIBUTE1,
		  ATTRIBUTE2,
		  ATTRIBUTE3,
		  ATTRIBUTE4,
		  ATTRIBUTE5,
		  ATTRIBUTE6,
		  ATTRIBUTE7,
		  ATTRIBUTE8,
		  ATTRIBUTE9,
		  ATTRIBUTE10,
		  ATTRIBUTE11,
		  ATTRIBUTE12,
		  ATTRIBUTE13,
		  ATTRIBUTE14,
		  ATTRIBUTE15,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
      )
   VALUES(
      decode( px_cu_id, FND_API.G_MISS_NUM, NULL, px_cu_id),
      decode( p_cu_name, FND_API.G_MISS_CHAR, NULL, p_cu_name),
      decode( p_description, FND_API.G_MISS_CHAR, NULL, p_description),
      decode( p_organization_id, FND_API.G_MISS_NUM, NULL, p_organization_id),
      decode( p_cu_effective_from, fnd_api.g_miss_date, to_date(NULL), p_cu_effective_from),
      decode( p_cu_effective_to, fnd_api.g_miss_date, to_date(NULL), p_cu_effective_to),
      decode( p_attribute_category, FND_API.G_MISS_CHAR, NULL, p_attribute_category),
      decode( p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1),
      decode( p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2),
      decode( p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3),
      decode( p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4),
      decode( p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5),
      decode( p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6),
      decode( p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7),
      decode( p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8),
      decode( p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9),
      decode( p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
      decode( p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
      decode( p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
      decode( p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
      decode( p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
      decode( p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15),
      decode( p_creation_date, fnd_api.g_miss_date, to_date(NULL), p_creation_date),
      decode( p_created_by, FND_API.G_MISS_NUM, NULL, p_created_by),
      decode( p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date),
      decode( p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by),
      decode( p_last_update_login, FND_API.G_MISS_NUM, NULL, p_last_update_login)
      );

End Insert_CU_Row;


PROCEDURE Update_CU_Row(
      p_cu_id		  IN          NUMBER
     ,p_cu_name		  IN          VARCHAR2
     ,p_description	  IN          VARCHAR2
     ,p_organization_id	  IN          NUMBER
     ,p_cu_effective_from IN          DATE
     ,p_cu_effective_to   IN          DATE
     ,p_attribute_category  IN        VARCHAR2
     ,p_attribute1        IN          VARCHAR2
     ,p_attribute2        IN          VARCHAR2
     ,p_attribute3        IN          VARCHAR2
     ,p_attribute4        IN          VARCHAR2
     ,p_attribute5        IN          VARCHAR2
     ,p_attribute6        IN          VARCHAR2
     ,p_attribute7        IN          VARCHAR2
     ,p_attribute8        IN          VARCHAR2
     ,p_attribute9        IN          VARCHAR2
     ,p_attribute10       IN          VARCHAR2
     ,p_attribute11       IN          VARCHAR2
     ,p_attribute12       IN          VARCHAR2
     ,p_attribute13       IN          VARCHAR2
     ,p_attribute14       IN          VARCHAR2
     ,p_attribute15       IN          VARCHAR2
     ,p_last_update_date  IN          DATE
     ,p_last_updated_by   IN          NUMBER
     ,p_last_update_login IN          NUMBER
      )  IS

 BEGIN

    UPDATE EAM_CONSTRUCTION_UNITS
     SET
	  CU_NAME		= decode( p_cu_name, FND_API.G_MISS_CHAR, NULL, p_cu_name),
	  DESCRIPTION	= decode( p_description, FND_API.G_MISS_CHAR, NULL, p_description),
	  ORGANIZATION_ID	= decode( p_organization_id, FND_API.G_MISS_NUM, NULL, p_organization_id),
	  CU_EFFECTIVE_FROM = decode( p_cu_effective_from, fnd_api.g_miss_date, to_date(NULL), p_cu_effective_from),
	  CU_EFFECTIVE_TO	= decode( p_cu_effective_to, fnd_api.g_miss_date, to_date(NULL), p_cu_effective_to),
    ATTRIBUTE_CATEGORY	= decode( p_attribute_category, FND_API.G_MISS_CHAR, NULL, p_attribute_category),
	  ATTRIBUTE1	= decode( p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1),
	  ATTRIBUTE2	= decode( p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2),
	  ATTRIBUTE3	= decode( p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3),
	  ATTRIBUTE4	= decode( p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4),
	  ATTRIBUTE5	= decode( p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5),
	  ATTRIBUTE6	= decode( p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6),
	  ATTRIBUTE7	= decode( p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7),
	  ATTRIBUTE8	= decode( p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8),
	  ATTRIBUTE9	= decode( p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9),
	  ATTRIBUTE10	= decode( p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
	  ATTRIBUTE11	= decode( p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
	  ATTRIBUTE12	= decode( p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
	  ATTRIBUTE13	= decode( p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
	  ATTRIBUTE14	= decode( p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
	  ATTRIBUTE15	= decode( p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15),
	  LAST_UPDATE_DATE  = decode( p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date),
	  LAST_UPDATED_BY	= decode( p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by),
  	LAST_UPDATE_LOGIN = decode( p_last_update_login, FND_API.G_MISS_NUM, NULL, p_last_update_login)
      WHERE CU_ID = p_cu_id;

     If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
     End If;

END Update_CU_Row;


PROCEDURE Insert_CU_Activity_Row(
      px_cu_detail_id		    IN OUT      NOCOPY  NUMBER
     ,p_cu_id			    IN    NUMBER
     ,p_acct_class_code		    IN    VARCHAR2
     ,p_activity_id		    IN    NUMBER
     ,p_cu_activity_qty		    IN    NUMBER
     ,p_cu_activity_effective_from  IN    DATE
     ,p_cu_activity_effective_to    IN    DATE
     ,p_creation_date               IN    DATE
     ,p_created_by                  IN    NUMBER
     ,p_last_update_date            IN    DATE
     ,p_last_updated_by             IN    NUMBER
     ,p_last_update_login           IN    NUMBER
      )  IS

    CURSOR C2 IS
	SELECT EAM_CONSTRUCTION_UNIT_DTLS_S.nextval
	FROM   dual;
 BEGIN

  IF (px_cu_detail_id IS NULL) OR (px_cu_detail_id = FND_API.G_MISS_NUM) then
      OPEN C2;
      FETCH C2 INTO px_cu_detail_id;
      CLOSE C2;
  END IF;

  INSERT INTO EAM_CONSTRUCTION_UNIT_DETAILS(
      CU_DETAIL_ID,
      CU_ID,
      ACCT_CLASS_CODE,
      ACTIVITY_ID,
      CU_ACTIVITY_QTY,
      CU_ACTIVITY_EFFECTIVE_FROM,
      CU_ACTIVITY_EFFECTIVE_TO,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
      )
   VALUES(
      decode( px_cu_detail_id, FND_API.G_MISS_NUM, NULL, px_cu_detail_id),
      decode( p_cu_id, FND_API.G_MISS_NUM, NULL, p_cu_id),
      decode( p_acct_class_code, FND_API.G_MISS_CHAR, NULL, p_acct_class_code),
      decode( p_activity_id, FND_API.G_MISS_NUM, NULL, p_activity_id),
      decode( p_cu_activity_qty, FND_API.G_MISS_NUM, NULL, p_cu_activity_qty),
      decode( p_cu_activity_effective_from, fnd_api.g_miss_date, to_date(NULL), p_cu_activity_effective_from),
      decode( p_cu_activity_effective_to, fnd_api.g_miss_date, to_date(NULL), p_cu_activity_effective_to),
      decode( p_creation_date, fnd_api.g_miss_date, to_date(NULL), p_creation_date),
      decode( p_created_by, FND_API.G_MISS_NUM, NULL, p_created_by),
      decode( p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date),
      decode( p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by),
      decode( p_last_update_login, FND_API.G_MISS_NUM, NULL, p_last_update_login)
      );
End Insert_CU_Activity_Row;

PROCEDURE Update_CU_Activity_Row(
      p_cu_detail_id		    IN    NUMBER
     ,p_cu_id			    IN    NUMBER
     ,p_acct_class_code		    IN    VARCHAR2
     ,p_activity_id		    IN    NUMBER
     ,p_cu_activity_qty		    IN    NUMBER
     ,p_cu_activity_effective_from  IN    DATE
     ,p_cu_activity_effective_to    IN    DATE
     ,p_last_update_date            IN    DATE
     ,p_last_updated_by             IN    NUMBER
     ,p_last_update_login           IN    NUMBER
      )  IS

 BEGIN

     UPDATE EAM_CONSTRUCTION_UNIT_DETAILS
     SET
	CU_ID			= decode( p_cu_id, FND_API.G_MISS_NUM, NULL, p_cu_id),
	ACCT_CLASS_CODE		= decode( p_acct_class_code, FND_API.G_MISS_CHAR, NULL, p_acct_class_code),
	ACTIVITY_ID		= decode( p_activity_id, FND_API.G_MISS_NUM, NULL, p_activity_id),
	CU_ACTIVITY_QTY		= decode( p_cu_activity_qty, FND_API.G_MISS_NUM, NULL, p_cu_activity_qty),
	CU_ACTIVITY_EFFECTIVE_FROM = decode( p_cu_activity_effective_from,
					fnd_api.g_miss_date, to_date(NULL), p_cu_activity_effective_from),
	CU_ACTIVITY_EFFECTIVE_TO   = decode( p_cu_activity_effective_to,
					fnd_api.g_miss_date, to_date(NULL), p_cu_activity_effective_to),
	LAST_UPDATE_DATE    	= decode( p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date),
	LAST_UPDATED_BY       	= decode( p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by),
	LAST_UPDATE_LOGIN       = decode( p_last_update_login, FND_API.G_MISS_NUM, NULL, p_last_update_login)
    WHERE CU_DETAIL_ID = p_cu_detail_id;

     If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
     End If;

 END Update_CU_Activity_Row;


End EAM_CONSTRUCTION_UNIT_PKG;

/
