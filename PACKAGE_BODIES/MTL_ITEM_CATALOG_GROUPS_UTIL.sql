--------------------------------------------------------
--  DDL for Package Body MTL_ITEM_CATALOG_GROUPS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_ITEM_CATALOG_GROUPS_UTIL" as
/* $Header: INVICGUB.pls 120.1 2006/01/19 04:16:12 swshukla noship $ */

PROCEDURE INSERT_ROW (P_Catalog_Group_Rec IN  MTL_ITEM_CATALOG_GROUPS%ROWTYPE
                     ,X_ROWID             OUT NOCOPY ROWID) IS

   l_return_status VARCHAR2(1);   --Bug 4639946
BEGIN

   INSERT INTO MTL_ITEM_CATALOG_GROUPS_B (
    PARENT_CATALOG_GROUP_ID,
    ITEM_CREATION_ALLOWED_FLAG,
    ITEM_CATALOG_GROUP_ID,
    INACTIVE_DATE,
    SUMMARY_FLAG,
    ENABLED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT11,
    SEGMENT12,
    SEGMENT13,
    SEGMENT14,
    SEGMENT15,
    SEGMENT16,
    SEGMENT17,
    SEGMENT18,
    SEGMENT19,
    SEGMENT20,
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
    REQUEST_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
   ) VALUES (
    P_Catalog_Group_Rec.PARENT_CATALOG_GROUP_ID,
    NVL(P_Catalog_Group_Rec.ITEM_CREATION_ALLOWED_FLAG,'Y'),
    P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID,
    P_Catalog_Group_Rec.INACTIVE_DATE,
    P_Catalog_Group_Rec.SUMMARY_FLAG,
    P_Catalog_Group_Rec.ENABLED_FLAG,
    P_Catalog_Group_Rec.START_DATE_ACTIVE,
    P_Catalog_Group_Rec.END_DATE_ACTIVE,
    P_Catalog_Group_Rec.SEGMENT1,
    P_Catalog_Group_Rec.SEGMENT2,
    P_Catalog_Group_Rec.SEGMENT3,
    P_Catalog_Group_Rec.SEGMENT4,
    P_Catalog_Group_Rec.SEGMENT5,
    P_Catalog_Group_Rec.SEGMENT6,
    P_Catalog_Group_Rec.SEGMENT7,
    P_Catalog_Group_Rec.SEGMENT8,
    P_Catalog_Group_Rec.SEGMENT9,
    P_Catalog_Group_Rec.SEGMENT10,
    P_Catalog_Group_Rec.SEGMENT11,
    P_Catalog_Group_Rec.SEGMENT12,
    P_Catalog_Group_Rec.SEGMENT13,
    P_Catalog_Group_Rec.SEGMENT14,
    P_Catalog_Group_Rec.SEGMENT15,
    P_Catalog_Group_Rec.SEGMENT16,
    P_Catalog_Group_Rec.SEGMENT17,
    P_Catalog_Group_Rec.SEGMENT18,
    P_Catalog_Group_Rec.SEGMENT19,
    P_Catalog_Group_Rec.SEGMENT20,
    P_Catalog_Group_Rec.ATTRIBUTE_CATEGORY,
    P_Catalog_Group_Rec.ATTRIBUTE1,
    P_Catalog_Group_Rec.ATTRIBUTE2,
    P_Catalog_Group_Rec.ATTRIBUTE3,
    P_Catalog_Group_Rec.ATTRIBUTE4,
    P_Catalog_Group_Rec.ATTRIBUTE5,
    P_Catalog_Group_Rec.ATTRIBUTE6,
    P_Catalog_Group_Rec.ATTRIBUTE7,
    P_Catalog_Group_Rec.ATTRIBUTE8,
    P_Catalog_Group_Rec.ATTRIBUTE9,
    P_Catalog_Group_Rec.ATTRIBUTE10,
    P_Catalog_Group_Rec.ATTRIBUTE11,
    P_Catalog_Group_Rec.ATTRIBUTE12,
    P_Catalog_Group_Rec.ATTRIBUTE13,
    P_Catalog_Group_Rec.ATTRIBUTE14,
    P_Catalog_Group_Rec.ATTRIBUTE15,
    P_Catalog_Group_Rec.REQUEST_ID,
    P_Catalog_Group_Rec.CREATION_DATE,
    P_Catalog_Group_Rec.CREATED_BY,
    P_Catalog_Group_Rec.LAST_UPDATE_DATE,
    P_Catalog_Group_Rec.LAST_UPDATED_BY,
    P_Catalog_Group_Rec.LAST_UPDATE_LOGIN
   ) RETURNING ROWID INTO X_ROWID;

   INSERT INTO MTL_ITEM_CATALOG_GROUPS_TL (
    ITEM_CATALOG_GROUP_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
   ) SELECT
      P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID,
      P_Catalog_Group_Rec.DESCRIPTION,
      P_Catalog_Group_Rec.CREATION_DATE,
      P_Catalog_Group_Rec.CREATED_BY,
      P_Catalog_Group_Rec.LAST_UPDATE_DATE,
      P_Catalog_Group_Rec.LAST_UPDATED_BY,
      P_Catalog_Group_Rec.LAST_UPDATE_LOGIN,
      L.LANGUAGE_CODE,
      USERENV('LANG')
     FROM FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG in ('I', 'B')
     AND NOT EXISTS   (SELECT  NULL
                       FROM MTL_ITEM_CATALOG_GROUPS_TL T
                       WHERE T.ITEM_CATALOG_GROUP_ID = P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID
                       AND   T.LANGUAGE = L.LANGUAGE_CODE);

   --Bug: 4639946
   EXECUTE IMMEDIATE
   'Begin                                                                 '||
   'EGO_BROWSE_PVT.Sync_ICG_Denorm_Hier_Table (                           '||
   '  p_catalog_group_id => :P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID    '||
   ' ,p_old_parent_id    => NULL                                          '||
   ' ,x_return_status    => :l_return_status);                            '||
   'EXCEPTION                                                             '||
   '   When OTHERS Then                                                   '||
   '      null;                                                           '||
   'End;                                                                  '
   USING IN P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID,
         OUT l_return_status;

END INSERT_ROW;

PROCEDURE LOCK_ROW (P_Catalog_Group_Rec IN  MTL_ITEM_CATALOG_GROUPS%ROWTYPE) IS

   CURSOR c_get_item_catalog IS
     SELECT
      PARENT_CATALOG_GROUP_ID,
      ITEM_CREATION_ALLOWED_FLAG,
      INACTIVE_DATE,
      SUMMARY_FLAG,
      ENABLED_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      SEGMENT8,
      SEGMENT9,
      SEGMENT10,
      SEGMENT11,
      SEGMENT12,
      SEGMENT13,
      SEGMENT14,
      SEGMENT15,
      SEGMENT16,
      SEGMENT17,
      SEGMENT18,
      SEGMENT19,
      SEGMENT20,
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
      REQUEST_ID
     FROM MTL_ITEM_CATALOG_GROUPS_B
     WHERE ITEM_CATALOG_GROUP_ID = P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID
     FOR UPDATE OF ITEM_CATALOG_GROUP_ID NOWAIT;


   CURSOR c_get_description_rec IS
     SELECT
      DESCRIPTION,
      DECODE(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
     FROM MTL_ITEM_CATALOG_GROUPS_TL
     WHERE ITEM_CATALOG_GROUP_ID = P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID
     AND userenv('LANG')         IN (LANGUAGE, SOURCE_LANG)
     FOR UPDATE OF ITEM_CATALOG_GROUP_ID NOWAIT;

   recinfo c_get_item_catalog%rowtype;

BEGIN

   OPEN  c_get_item_catalog;
   FETCH c_get_item_catalog INTO recinfo;
   IF (c_get_item_catalog%NOTFOUND) THEN
      CLOSE c_get_item_catalog;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      Raise FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE c_get_item_catalog;

   IF (((recinfo.INACTIVE_DATE = P_Catalog_Group_Rec.INACTIVE_DATE)
           OR ((recinfo.INACTIVE_DATE is null) AND (P_Catalog_Group_Rec.INACTIVE_DATE is null)))
      AND (recinfo.SUMMARY_FLAG = P_Catalog_Group_Rec.SUMMARY_FLAG)
      AND (recinfo.ENABLED_FLAG = P_Catalog_Group_Rec.ENABLED_FLAG)
      AND ((recinfo.START_DATE_ACTIVE = P_Catalog_Group_Rec.START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (P_Catalog_Group_Rec.START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = P_Catalog_Group_Rec.END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (P_Catalog_Group_Rec.END_DATE_ACTIVE is null)))
      AND ((recinfo.SEGMENT1 = P_Catalog_Group_Rec.SEGMENT1)
           OR ((recinfo.SEGMENT1 is null) AND (P_Catalog_Group_Rec.SEGMENT1 is null)))
      AND ((recinfo.SEGMENT2 = P_Catalog_Group_Rec.SEGMENT2)
           OR ((recinfo.SEGMENT2 is null) AND (P_Catalog_Group_Rec.SEGMENT2 is null)))
      AND ((recinfo.SEGMENT3 = P_Catalog_Group_Rec.SEGMENT3)
           OR ((recinfo.SEGMENT3 is null) AND (P_Catalog_Group_Rec.SEGMENT3 is null)))
      AND ((recinfo.SEGMENT4 = P_Catalog_Group_Rec.SEGMENT4)
           OR ((recinfo.SEGMENT4 is null) AND (P_Catalog_Group_Rec.SEGMENT4 is null)))
      AND ((recinfo.SEGMENT5 = P_Catalog_Group_Rec.SEGMENT5)
           OR ((recinfo.SEGMENT5 is null) AND (P_Catalog_Group_Rec.SEGMENT5 is null)))
      AND ((recinfo.SEGMENT6 = P_Catalog_Group_Rec.SEGMENT6)
           OR ((recinfo.SEGMENT6 is null) AND (P_Catalog_Group_Rec.SEGMENT6 is null)))
      AND ((recinfo.SEGMENT7 = P_Catalog_Group_Rec.SEGMENT7)
           OR ((recinfo.SEGMENT7 is null) AND (P_Catalog_Group_Rec.SEGMENT7 is null)))
      AND ((recinfo.SEGMENT8 = P_Catalog_Group_Rec.SEGMENT8)
           OR ((recinfo.SEGMENT8 is null) AND (P_Catalog_Group_Rec.SEGMENT8 is null)))
      AND ((recinfo.SEGMENT9 = P_Catalog_Group_Rec.SEGMENT9)
           OR ((recinfo.SEGMENT9 is null) AND (P_Catalog_Group_Rec.SEGMENT9 is null)))
      AND ((recinfo.SEGMENT10 = P_Catalog_Group_Rec.SEGMENT10)
           OR ((recinfo.SEGMENT10 is null) AND (P_Catalog_Group_Rec.SEGMENT10 is null)))
      AND ((recinfo.SEGMENT11 = P_Catalog_Group_Rec.SEGMENT11)
           OR ((recinfo.SEGMENT11 is null) AND (P_Catalog_Group_Rec.SEGMENT11 is null)))
      AND ((recinfo.SEGMENT12 = P_Catalog_Group_Rec.SEGMENT12)
           OR ((recinfo.SEGMENT12 is null) AND (P_Catalog_Group_Rec.SEGMENT12 is null)))
      AND ((recinfo.SEGMENT13 = P_Catalog_Group_Rec.SEGMENT13)
           OR ((recinfo.SEGMENT13 is null) AND (P_Catalog_Group_Rec.SEGMENT13 is null)))
      AND ((recinfo.SEGMENT14 = P_Catalog_Group_Rec.SEGMENT14)
           OR ((recinfo.SEGMENT14 is null) AND (P_Catalog_Group_Rec.SEGMENT14 is null)))
      AND ((recinfo.SEGMENT15 = P_Catalog_Group_Rec.SEGMENT15)
           OR ((recinfo.SEGMENT15 is null) AND (P_Catalog_Group_Rec.SEGMENT15 is null)))
      AND ((recinfo.SEGMENT16 = P_Catalog_Group_Rec.SEGMENT16)
           OR ((recinfo.SEGMENT16 is null) AND (P_Catalog_Group_Rec.SEGMENT16 is null)))
      AND ((recinfo.SEGMENT17 = P_Catalog_Group_Rec.SEGMENT17)
           OR ((recinfo.SEGMENT17 is null) AND (P_Catalog_Group_Rec.SEGMENT17 is null)))
      AND ((recinfo.SEGMENT18 = P_Catalog_Group_Rec.SEGMENT18)
           OR ((recinfo.SEGMENT18 is null) AND (P_Catalog_Group_Rec.SEGMENT18 is null)))
      AND ((recinfo.SEGMENT19 = P_Catalog_Group_Rec.SEGMENT19)
           OR ((recinfo.SEGMENT19 is null) AND (P_Catalog_Group_Rec.SEGMENT19 is null)))
      AND ((recinfo.SEGMENT20 = P_Catalog_Group_Rec.SEGMENT20)
           OR ((recinfo.SEGMENT20 is null) AND (P_Catalog_Group_Rec.SEGMENT20 is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = P_Catalog_Group_Rec.ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (P_Catalog_Group_Rec.ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = P_Catalog_Group_Rec.ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = P_Catalog_Group_Rec.ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = P_Catalog_Group_Rec.ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = P_Catalog_Group_Rec.ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = P_Catalog_Group_Rec.ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = P_Catalog_Group_Rec.ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = P_Catalog_Group_Rec.ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = P_Catalog_Group_Rec.ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = P_Catalog_Group_Rec.ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = P_Catalog_Group_Rec.ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = P_Catalog_Group_Rec.ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = P_Catalog_Group_Rec.ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = P_Catalog_Group_Rec.ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = P_Catalog_Group_Rec.ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = P_Catalog_Group_Rec.ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (P_Catalog_Group_Rec.ATTRIBUTE15 is null))))
   THEN
      NULL;
   ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      Raise FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   FOR tlinfo IN c_get_description_rec LOOP
      IF (tlinfo.BASELANG = 'Y') THEN
         IF (((tlinfo.DESCRIPTION = P_Catalog_Group_Rec.DESCRIPTION)
             OR ((tlinfo.DESCRIPTION is null) AND (P_Catalog_Group_Rec.DESCRIPTION is null)))) THEN
            NULL;
         ELSE
            fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
            Raise FND_API.g_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
   END LOOP;

EXCEPTION

   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
      IF ( c_get_item_catalog%ISOPEN ) THEN
        CLOSE c_get_item_catalog;
      END IF;
      IF ( c_get_description_rec%ISOPEN ) THEN
        CLOSE c_get_description_rec;
      END IF;
      app_exception.raise_exception;

END LOCK_ROW;

PROCEDURE UPDATE_ROW (P_Catalog_Group_Rec IN  MTL_ITEM_CATALOG_GROUPS%ROWTYPE) IS

   l_old_parent_id  NUMBER;       --Bug: 4639946
   l_return_status VARCHAR2(1);   --Bug: 4639946
BEGIN

   --Bug: 4639946
   Select PARENT_CATALOG_GROUP_ID into l_old_parent_id
   From MTL_ITEM_CATALOG_GROUPS_B
   WHERE ITEM_CATALOG_GROUP_ID  = P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID;

   IF (SQL%NOTFOUND) THEN
     RAISE no_data_found;
   END IF;

   UPDATE MTL_ITEM_CATALOG_GROUPS_B
   SET
    PARENT_CATALOG_GROUP_ID     = P_Catalog_Group_Rec.PARENT_CATALOG_GROUP_ID,
    ITEM_CREATION_ALLOWED_FLAG  = NVL(P_Catalog_Group_Rec.ITEM_CREATION_ALLOWED_FLAG,ITEM_CREATION_ALLOWED_FLAG),
    INACTIVE_DATE               = P_Catalog_Group_Rec.INACTIVE_DATE,
    SUMMARY_FLAG                = P_Catalog_Group_Rec.SUMMARY_FLAG,
    ENABLED_FLAG		= P_Catalog_Group_Rec.ENABLED_FLAG,
    START_DATE_ACTIVE		= P_Catalog_Group_Rec.START_DATE_ACTIVE,
    END_DATE_ACTIVE		= P_Catalog_Group_Rec.END_DATE_ACTIVE,
    SEGMENT1			= P_Catalog_Group_Rec.SEGMENT1,
    SEGMENT2			= P_Catalog_Group_Rec.SEGMENT2,
    SEGMENT3			= P_Catalog_Group_Rec.SEGMENT3,
    SEGMENT4			= P_Catalog_Group_Rec.SEGMENT4,
    SEGMENT5			= P_Catalog_Group_Rec.SEGMENT5,
    SEGMENT6			= P_Catalog_Group_Rec.SEGMENT6,
    SEGMENT7			= P_Catalog_Group_Rec.SEGMENT7,
    SEGMENT8			= P_Catalog_Group_Rec.SEGMENT8,
    SEGMENT9			= P_Catalog_Group_Rec.SEGMENT9,
    SEGMENT10			= P_Catalog_Group_Rec.SEGMENT10,
    SEGMENT11			= P_Catalog_Group_Rec.SEGMENT11,
    SEGMENT12			= P_Catalog_Group_Rec.SEGMENT12,
    SEGMENT13			= P_Catalog_Group_Rec.SEGMENT13,
    SEGMENT14			= P_Catalog_Group_Rec.SEGMENT14,
    SEGMENT15			= P_Catalog_Group_Rec.SEGMENT15,
    SEGMENT16			= P_Catalog_Group_Rec.SEGMENT16,
    SEGMENT17			= P_Catalog_Group_Rec.SEGMENT17,
    SEGMENT18			= P_Catalog_Group_Rec.SEGMENT18,
    SEGMENT19			= P_Catalog_Group_Rec.SEGMENT19,
    SEGMENT20			= P_Catalog_Group_Rec.SEGMENT20,
    ATTRIBUTE_CATEGORY		= P_Catalog_Group_Rec.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1			= P_Catalog_Group_Rec.ATTRIBUTE1,
    ATTRIBUTE2			= P_Catalog_Group_Rec.ATTRIBUTE2,
    ATTRIBUTE3			= P_Catalog_Group_Rec.ATTRIBUTE3,
    ATTRIBUTE4			= P_Catalog_Group_Rec.ATTRIBUTE4,
    ATTRIBUTE5			= P_Catalog_Group_Rec.ATTRIBUTE5,
    ATTRIBUTE6			= P_Catalog_Group_Rec.ATTRIBUTE6,
    ATTRIBUTE7			= P_Catalog_Group_Rec.ATTRIBUTE7,
    ATTRIBUTE8			= P_Catalog_Group_Rec.ATTRIBUTE8,
    ATTRIBUTE9			= P_Catalog_Group_Rec.ATTRIBUTE9,
    ATTRIBUTE10			= P_Catalog_Group_Rec.ATTRIBUTE10,
    ATTRIBUTE11			= P_Catalog_Group_Rec.ATTRIBUTE11,
    ATTRIBUTE12			= P_Catalog_Group_Rec.ATTRIBUTE12,
    ATTRIBUTE13			= P_Catalog_Group_Rec.ATTRIBUTE13,
    ATTRIBUTE14			= P_Catalog_Group_Rec.ATTRIBUTE14,
    ATTRIBUTE15			= P_Catalog_Group_Rec.ATTRIBUTE15,
    REQUEST_ID			= P_Catalog_Group_Rec.REQUEST_ID,
    LAST_UPDATE_DATE		= P_Catalog_Group_Rec.LAST_UPDATE_DATE,
    LAST_UPDATED_BY		= P_Catalog_Group_Rec.LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN		= P_Catalog_Group_Rec.LAST_UPDATE_LOGIN
   WHERE ITEM_CATALOG_GROUP_ID  = P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
   END IF;


   UPDATE MTL_ITEM_CATALOG_GROUPS_TL
   SET
    DESCRIPTION		= P_Catalog_Group_Rec.DESCRIPTION,
    LAST_UPDATE_DATE	= P_Catalog_Group_Rec.LAST_UPDATE_DATE,
    LAST_UPDATED_BY	= P_Catalog_Group_Rec.LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN	= P_Catalog_Group_Rec.LAST_UPDATE_LOGIN,
    SOURCE_LANG		= USERENV('LANG')
   WHERE ITEM_CATALOG_GROUP_ID = P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID
   AND   USERENV('LANG')       IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
   END IF;

   --Bug: 4639946
   EXECUTE IMMEDIATE
   'Begin                                                                 '||
   'EGO_BROWSE_PVT.Sync_ICG_Denorm_Hier_Table (                           '||
   '  p_catalog_group_id => :P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID    '||
   ' ,p_old_parent_id    => :l_old_parent_id                              '||
   ' ,x_return_status    => :l_return_status);                            '||
   'EXCEPTION                                                             '||
   '   When OTHERS Then                                                   '||
   '      null;                                                           '||
   'End;                                                                  '
   USING IN P_Catalog_Group_Rec.ITEM_CATALOG_GROUP_ID,
         IN l_old_parent_id,
	 OUT l_return_status;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (X_ITEM_CATALOG_GROUP_ID IN MTL_ITEM_CATALOG_GROUPS.ITEM_CATALOG_GROUP_ID%TYPE)
IS
BEGIN

   DELETE FROM MTL_ITEM_CATALOG_GROUPS_TL
   WHERE  ITEM_CATALOG_GROUP_ID = X_ITEM_CATALOG_GROUP_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
   END IF;

   DELETE FROM MTL_ITEM_CATALOG_GROUPS_B
   WHERE  ITEM_CATALOG_GROUP_ID = X_ITEM_CATALOG_GROUP_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
   END IF;

END DELETE_ROW;

PROCEDURE ADD_LANGUAGE IS
BEGIN

   DELETE FROM MTL_ITEM_CATALOG_GROUPS_TL T
   WHERE NOT EXISTS (SELECT NULL
		     FROM   MTL_ITEM_CATALOG_GROUPS_B B
		     WHERE  B.ITEM_CATALOG_GROUP_ID = T.ITEM_CATALOG_GROUP_ID);

   UPDATE MTL_ITEM_CATALOG_GROUPS_TL T
   SET (DESCRIPTION) = (SELECT B.DESCRIPTION
		        FROM   MTL_ITEM_CATALOG_GROUPS_TL B
			WHERE  B.ITEM_CATALOG_GROUP_ID = T.ITEM_CATALOG_GROUP_ID
			AND    B.LANGUAGE = T.SOURCE_LANG)
   WHERE ( T.ITEM_CATALOG_GROUP_ID,T.LANGUAGE)
     IN (SELECT	SUBT.ITEM_CATALOG_GROUP_ID,
	        SUBT.LANGUAGE
	 FROM   MTL_ITEM_CATALOG_GROUPS_TL SUBB,
		MTL_ITEM_CATALOG_GROUPS_TL SUBT
	 WHERE  SUBB.ITEM_CATALOG_GROUP_ID = SUBT.ITEM_CATALOG_GROUP_ID
	 AND    SUBB.LANGUAGE = SUBT.SOURCE_LANG
	 AND   (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
            or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
            or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)));

   INSERT INTO MTL_ITEM_CATALOG_GROUPS_TL (
    ITEM_CATALOG_GROUP_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
   ) SELECT
    B.ITEM_CATALOG_GROUP_ID,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
   FROM MTL_ITEM_CATALOG_GROUPS_TL B,
	FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG in ('I', 'B')
   AND   B.LANGUAGE = userenv('LANG')
   AND NOT EXISTS  (SELECT NULL
		    FROM MTL_ITEM_CATALOG_GROUPS_TL T
		    WHERE T.ITEM_CATALOG_GROUP_ID = B.ITEM_CATALOG_GROUP_ID
		    AND   T.LANGUAGE = L.LANGUAGE_CODE);

END ADD_LANGUAGE;

END MTL_ITEM_CATALOG_GROUPS_UTIL;

/
