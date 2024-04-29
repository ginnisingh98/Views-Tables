--------------------------------------------------------
--  DDL for Package Body MTL_ITEM_REVISIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_ITEM_REVISIONS_UTIL" AS
/* $Header: INVIRVUB.pls 120.1 2006/08/01 11:31:56 lparihar noship $ */


--Added for bug 5435229
Procedure copy_rev_UDA(p_organization_id   IN NUMBER
                      ,p_inventory_item_id IN NUMBER
                      ,p_revision_id       IN NUMBER
                      ,p_revision          IN VARCHAR2) IS

CURSOR c_get_effective_revision(cp_inventory_item_id NUMBER
                               ,cp_organization_id   NUMBER
                               ,cp_revision          VARCHAR2) IS
   SELECT  revision_id
     FROM  mtl_item_revisions_b
    WHERE  inventory_item_id = cp_inventory_item_id
      AND  organization_id   = cp_organization_id
      AND  revision          < cp_revision
      AND  implementation_date IS NOT NULL
      AND  effectivity_date  <= sysdate
      ORDER BY effectivity_date desc;

  l_source_revision_id      mtl_item_revisions_b.revision_id%TYPE;
  l_return_status           VARCHAR2(100);
  l_error_code              NUMBER;
  l_msg_count               NUMBER  ;
  l_msg_data                VARCHAR2(100);
  l_pk_item_pairs           EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_pk_item_rev_pairs_src   EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_pk_item_rev_pairs_dst   EGO_COL_NAME_VALUE_PAIR_ARRAY;

BEGIN
   OPEN  c_get_effective_revision(cp_inventory_item_id => p_inventory_item_id
                                  ,cp_organization_id  => p_organization_id
                                  ,cp_revision         => p_revision);
   FETCH c_get_effective_revision INTO l_source_revision_id;
   CLOSE c_get_effective_revision;

   IF l_source_revision_id IS NOT NULL THEN
      l_pk_item_pairs         :=EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                   EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', p_inventory_item_id)
                                  ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID',   p_organization_id));

      l_pk_item_rev_pairs_src :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'REVISION_ID' , l_source_revision_id));
      l_pk_item_rev_pairs_dst :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'REVISION_ID' , p_revision_id));
      EGO_USER_ATTRS_DATA_PVT.Copy_User_Attrs_Data(
                p_api_version                   => 1.0
               ,p_application_id                => 431
               ,p_object_name                   => 'EGO_ITEM'
               ,p_old_pk_col_value_pairs        => l_pk_item_pairs
               ,p_old_dtlevel_col_value_pairs   => l_pk_item_rev_pairs_src
               ,p_new_pk_col_value_pairs        => l_pk_item_pairs
               ,p_new_dtlevel_col_value_pairs   => l_pk_item_rev_pairs_dst
               ,x_return_status                 => l_return_status
               ,x_errorcode                     => l_error_code
               ,x_msg_count                     => l_msg_count
               ,x_msg_data                      => l_msg_data);

   END IF; --l_source_revision_id

   EXCEPTION
      WHEN OTHERS THEN
        NULL;
END copy_rev_UDA;

PROCEDURE INSERT_ROW(P_Item_Revision_Rec IN  MTL_ITEM_REVISIONS_B%ROWTYPE,
                     X_ROWID             OUT NOCOPY VARCHAR2) IS

BEGIN

   INSERT INTO MTL_ITEM_REVISIONS_B (
    REVISION_ID,
    REVISION_LABEL,
    REVISION_REASON,
    LIFECYCLE_ID,
    CURRENT_PHASE_ID,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    REVISION,
    CHANGE_NOTICE,
    ECN_INITIATION_DATE,
    IMPLEMENTATION_DATE,
    IMPLEMENTED_SERIAL_NUMBER,
    EFFECTIVITY_DATE,
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
    REVISED_ITEM_SEQUENCE_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
   ) VALUES (
    P_Item_Revision_Rec.REVISION_ID,
    P_Item_Revision_Rec.REVISION_LABEL,
    P_Item_Revision_Rec.REVISION_REASON,
    P_Item_Revision_Rec.LIFECYCLE_ID,
    P_Item_Revision_Rec.CURRENT_PHASE_ID,
    P_Item_Revision_Rec.INVENTORY_ITEM_ID,
    P_Item_Revision_Rec.ORGANIZATION_ID,
    P_Item_Revision_Rec.REVISION,
    P_Item_Revision_Rec.CHANGE_NOTICE,
    P_Item_Revision_Rec.ECN_INITIATION_DATE,
    P_Item_Revision_Rec.IMPLEMENTATION_DATE,
    P_Item_Revision_Rec.IMPLEMENTED_SERIAL_NUMBER,
    P_Item_Revision_Rec.EFFECTIVITY_DATE,
    P_Item_Revision_Rec.ATTRIBUTE_CATEGORY,
    P_Item_Revision_Rec.ATTRIBUTE1,
    P_Item_Revision_Rec.ATTRIBUTE2,
    P_Item_Revision_Rec.ATTRIBUTE3,
    P_Item_Revision_Rec.ATTRIBUTE4,
    P_Item_Revision_Rec.ATTRIBUTE5,
    P_Item_Revision_Rec.ATTRIBUTE6,
    P_Item_Revision_Rec.ATTRIBUTE7,
    P_Item_Revision_Rec.ATTRIBUTE8,
    P_Item_Revision_Rec.ATTRIBUTE9,
    P_Item_Revision_Rec.ATTRIBUTE10,
    P_Item_Revision_Rec.ATTRIBUTE11,
    P_Item_Revision_Rec.ATTRIBUTE12,
    P_Item_Revision_Rec.ATTRIBUTE13,
    P_Item_Revision_Rec.ATTRIBUTE14,
    P_Item_Revision_Rec.ATTRIBUTE15,
    P_Item_Revision_Rec.REQUEST_ID,
    P_Item_Revision_Rec.REVISED_ITEM_SEQUENCE_ID,
    NVL(P_Item_Revision_Rec.OBJECT_VERSION_NUMBER,1),
    P_Item_Revision_Rec.CREATION_DATE,
    P_Item_Revision_Rec.CREATED_BY,
    P_Item_Revision_Rec.LAST_UPDATE_DATE,
    P_Item_Revision_Rec.LAST_UPDATED_BY,
    P_Item_Revision_Rec.LAST_UPDATE_LOGIN
   ) RETURNING ROWID INTO X_ROWID;

   INSERT INTO MTL_ITEM_REVISIONS_TL (
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    REVISION_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
   ) SELECT P_Item_Revision_Rec.INVENTORY_ITEM_ID,
	    P_Item_Revision_Rec.ORGANIZATION_ID,
            P_Item_Revision_Rec.REVISION_ID,
	    P_Item_Revision_Rec.DESCRIPTION,
	    P_Item_Revision_Rec.CREATION_DATE,
	    P_Item_Revision_Rec.CREATED_BY,
	    P_Item_Revision_Rec.LAST_UPDATE_DATE,
	    P_Item_Revision_Rec.LAST_UPDATED_BY,
	    P_Item_Revision_Rec.LAST_UPDATE_LOGIN,
	    L.LANGUAGE_CODE,
	    USERENV('LANG')
     FROM FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG in ('I', 'B')
     AND NOT EXISTS (SELECT NULL
		     FROM MTL_ITEM_REVISIONS_TL T
		     WHERE T.INVENTORY_ITEM_ID = P_Item_Revision_Rec.INVENTORY_ITEM_ID
		     AND T.ORGANIZATION_ID = P_Item_Revision_Rec.ORGANIZATION_ID
		     AND T.REVISION_ID = P_Item_Revision_Rec.REVISION_ID
		     AND T.LANGUAGE = L.LANGUAGE_CODE);

 -- Bug 5435229
 -- Copy revision UDA
 copy_rev_UDA(p_organization_id   => p_Item_Revision_rec.organization_id
             ,p_inventory_item_id => p_Item_Revision_rec.inventory_item_id
             ,p_revision_id       => p_Item_Revision_rec.revision_id
             ,p_revision          => p_Item_Revision_rec.revision);

-- R12: Business Event Enhancement : Raise Event if Revision got Created successfully
     BEGIN
       INV_ITEM_EVENTS_PVT.Raise_Events(
           p_event_name        => 'EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT'
          ,p_dml_type          => 'CREATE'
          ,p_inventory_item_id => p_Item_Revision_rec.Inventory_Item_Id
          ,p_organization_id   => p_Item_Revision_rec.Organization_Id
          ,p_revision_id       => p_Item_Revision_rec.revision_id);
       EXCEPTION
          WHEN OTHERS THEN
             NULL;
     END;
--R12: Business Event Enhancement : Raise Event if Revision got Created successfully
END INSERT_ROW;

PROCEDURE LOCK_ROW (P_Item_Revision_Rec IN  MTL_ITEM_REVISIONS_B%ROWTYPE) IS

   CURSOR c_get_item_revision IS
     SELECT
      REVISION_LABEL,
      REVISION_REASON,
      LIFECYCLE_ID,
      CURRENT_PHASE_ID,
      REVISION,
      CHANGE_NOTICE,
      ECN_INITIATION_DATE,
      IMPLEMENTATION_DATE,
      IMPLEMENTED_SERIAL_NUMBER,
      EFFECTIVITY_DATE,
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
      REVISED_ITEM_SEQUENCE_ID,
      OBJECT_VERSION_NUMBER
     FROM MTL_ITEM_REVISIONS_B
     WHERE INVENTORY_ITEM_ID = P_Item_Revision_Rec.INVENTORY_ITEM_ID
     AND   ORGANIZATION_ID   = P_Item_Revision_Rec.ORGANIZATION_ID
     AND   REVISION_ID       = P_Item_Revision_Rec.REVISION_ID
     FOR UPDATE OF INVENTORY_ITEM_ID NOWAIT;

    CURSOR c_get_revision_desc IS
      SELECT
       DESCRIPTION,
       DECODE(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
      FROM MTL_ITEM_REVISIONS_TL
      WHERE INVENTORY_ITEM_ID = P_Item_Revision_Rec.INVENTORY_ITEM_ID
      AND   ORGANIZATION_ID   = P_Item_Revision_Rec.ORGANIZATION_ID
      AND   REVISION_ID       = P_Item_Revision_Rec.REVISION_ID
      AND   USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
      FOR UPDATE OF INVENTORY_ITEM_ID NOWAIT;

   recinfo c_get_item_revision%rowtype;
BEGIN

   OPEN  c_get_item_revision;
   FETCH c_get_item_revision INTO recinfo;
   IF (c_get_item_revision%notfound) THEN
      CLOSE c_get_item_revision;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      Raise FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE c_get_item_revision;

   IF ((recinfo.REVISION = P_Item_Revision_Rec.REVISION)
      AND (recinfo.REVISION_LABEL = P_Item_Revision_Rec.REVISION_LABEL)--Bug: 3017253
      AND ((recinfo.CHANGE_NOTICE = P_Item_Revision_Rec.CHANGE_NOTICE)
           OR ((recinfo.CHANGE_NOTICE is null) AND (P_Item_Revision_Rec.CHANGE_NOTICE is null)))
      AND ((TRUNC(recinfo.ECN_INITIATION_DATE) = TRUNC(P_Item_Revision_Rec.ECN_INITIATION_DATE))
           OR ((recinfo.ECN_INITIATION_DATE is null) AND (P_Item_Revision_Rec.ECN_INITIATION_DATE is null)))
      AND ((TRUNC(recinfo.IMPLEMENTATION_DATE) = TRUNC(P_Item_Revision_Rec.IMPLEMENTATION_DATE))
           OR ((recinfo.IMPLEMENTATION_DATE is null) AND (P_Item_Revision_Rec.IMPLEMENTATION_DATE is null)))
      AND (TRUNC(recinfo.EFFECTIVITY_DATE) = TRUNC(P_Item_Revision_Rec.EFFECTIVITY_DATE))
      AND ((recinfo.ATTRIBUTE_CATEGORY = P_Item_Revision_Rec.ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (P_Item_Revision_Rec.ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = P_Item_Revision_Rec.ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (P_Item_Revision_Rec.ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = P_Item_Revision_Rec.ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (P_Item_Revision_Rec.ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = P_Item_Revision_Rec.ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (P_Item_Revision_Rec.ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = P_Item_Revision_Rec.ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (P_Item_Revision_Rec.ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = P_Item_Revision_Rec.ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (P_Item_Revision_Rec.ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = P_Item_Revision_Rec.ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (P_Item_Revision_Rec.ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = P_Item_Revision_Rec.ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (P_Item_Revision_Rec.ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = P_Item_Revision_Rec.ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (P_Item_Revision_Rec.ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = P_Item_Revision_Rec.ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (P_Item_Revision_Rec.ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = P_Item_Revision_Rec.ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (P_Item_Revision_Rec.ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = P_Item_Revision_Rec.ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (P_Item_Revision_Rec.ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = P_Item_Revision_Rec.ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (P_Item_Revision_Rec.ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = P_Item_Revision_Rec.ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (P_Item_Revision_Rec.ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = P_Item_Revision_Rec.ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (P_Item_Revision_Rec.ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = P_Item_Revision_Rec.ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (P_Item_Revision_Rec.ATTRIBUTE15 is null))))
   THEN
      NULL;
   ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      Raise FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   FOR tlinfo IN c_get_revision_desc
   LOOP
      IF (tlinfo.BASELANG = 'Y') THEN
         IF (((tlinfo.DESCRIPTION = P_Item_Revision_Rec.DESCRIPTION)
             OR ((tlinfo.DESCRIPTION is null) AND (P_Item_Revision_Rec.DESCRIPTION is null))))
	 THEN
            NULL;
         ELSE
            fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
            Raise FND_API.g_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
   END LOOP;

EXCEPTION
   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
      IF ( c_get_item_revision%ISOPEN ) THEN
        CLOSE c_get_item_revision;
      END IF;
      IF ( c_get_revision_desc%ISOPEN ) THEN
        CLOSE c_get_revision_desc;
      END IF;
      app_exception.raise_exception;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (P_Item_Revision_Rec IN  MTL_ITEM_REVISIONS_B%ROWTYPE) IS

BEGIN
   UPDATE MTL_ITEM_REVISIONS_B
   SET
    REVISION		= P_Item_Revision_Rec.REVISION,
    REVISION_LABEL	= P_Item_Revision_Rec.REVISION_LABEL,--Bug: 3017253
    CHANGE_NOTICE	= P_Item_Revision_Rec.CHANGE_NOTICE,
    ECN_INITIATION_DATE = P_Item_Revision_Rec.ECN_INITIATION_DATE,
    IMPLEMENTATION_DATE = P_Item_Revision_Rec.IMPLEMENTATION_DATE,
    EFFECTIVITY_DATE	= DECODE(TRUNC(P_Item_Revision_Rec.EFFECTIVITY_DATE),TRUNC(EFFECTIVITY_DATE),EFFECTIVITY_DATE,TRUNC(SYSDATE),SYSDATE,P_Item_Revision_Rec.EFFECTIVITY_DATE),
    ATTRIBUTE_CATEGORY	= P_Item_Revision_Rec.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1		= P_Item_Revision_Rec.ATTRIBUTE1,
    ATTRIBUTE2		= P_Item_Revision_Rec.ATTRIBUTE2,
    ATTRIBUTE3		= P_Item_Revision_Rec.ATTRIBUTE3,
    ATTRIBUTE4		= P_Item_Revision_Rec.ATTRIBUTE4,
    ATTRIBUTE5		= P_Item_Revision_Rec.ATTRIBUTE5,
    ATTRIBUTE6		= P_Item_Revision_Rec.ATTRIBUTE6,
    ATTRIBUTE7		= P_Item_Revision_Rec.ATTRIBUTE7,
    ATTRIBUTE8		= P_Item_Revision_Rec.ATTRIBUTE8,
    ATTRIBUTE9		= P_Item_Revision_Rec.ATTRIBUTE9,
    ATTRIBUTE10		= P_Item_Revision_Rec.ATTRIBUTE10,
    ATTRIBUTE11		= P_Item_Revision_Rec.ATTRIBUTE11,
    ATTRIBUTE12		= P_Item_Revision_Rec.ATTRIBUTE12,
    ATTRIBUTE13		= P_Item_Revision_Rec.ATTRIBUTE13,
    ATTRIBUTE14		= P_Item_Revision_Rec.ATTRIBUTE14,
    ATTRIBUTE15		= P_Item_Revision_Rec.ATTRIBUTE15,
    LAST_UPDATE_DATE	= P_Item_Revision_Rec.LAST_UPDATE_DATE,
    LAST_UPDATED_BY	= P_Item_Revision_Rec.LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN	= P_Item_Revision_Rec.LAST_UPDATE_LOGIN,
/* Bug 4224512 : Incrementing OBJECT_VERSION_NUMBER each time revision is updated - Anmurali*/
    OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1
    WHERE INVENTORY_ITEM_ID = P_Item_Revision_Rec.INVENTORY_ITEM_ID
   AND   ORGANIZATION_ID   = P_Item_Revision_Rec.ORGANIZATION_ID
   AND   REVISION_ID	   = P_Item_Revision_Rec.REVISION_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   UPDATE MTL_ITEM_REVISIONS_TL set
    DESCRIPTION       = P_Item_Revision_Rec.DESCRIPTION,
    LAST_UPDATE_DATE  = P_Item_Revision_Rec.LAST_UPDATE_DATE,
    LAST_UPDATED_BY   = P_Item_Revision_Rec.LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_Item_Revision_Rec.LAST_UPDATE_LOGIN,
    SOURCE_LANG       = USERENV('LANG')
   WHERE INVENTORY_ITEM_ID = P_Item_Revision_Rec.INVENTORY_ITEM_ID
   AND   ORGANIZATION_ID   = P_Item_Revision_Rec.ORGANIZATION_ID
   AND   REVISION_ID       = P_Item_Revision_Rec.REVISION_ID
   AND  USERENV('LANG')   IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

--R12: Business Event Enhancement : Raise Event if Revision got Updated successfully
   BEGIN
     INV_ITEM_EVENTS_PVT.Raise_Events(
         p_event_name        => 'EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT'
        ,p_dml_type          => 'UPDATE'
        ,p_inventory_item_id => p_Item_Revision_rec.Inventory_Item_Id
        ,p_organization_id   => p_Item_Revision_rec.Organization_Id
        ,p_revision_id       => p_Item_Revision_rec.revision_id);
     EXCEPTION
        WHEN OTHERS THEN
           NULL;
   END;
--R12: Business Event Enhancement : Raise Event if Revision got Updated successfully

END UPDATE_ROW;

PROCEDURE ADD_LANGUAGE IS
BEGIN

-- Comment out as part of SQL Repositry fix. Bug: 4256727

/*   DELETE FROM MTL_ITEM_REVISIONS_TL T
   WHERE NOT EXISTS(SELECT NULL
		    FROM MTL_ITEM_REVISIONS_B B
		    WHERE B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
		    AND   B.ORGANIZATION_ID   = T.ORGANIZATION_ID
		    AND   B.REVISION_ID       = T.REVISION_ID);

   UPDATE MTL_ITEM_REVISIONS_TL T
   SET (DESCRIPTION) = (SELECT B.DESCRIPTION
			FROM   MTL_ITEM_REVISIONS_TL B
			WHERE  B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
			AND    B.ORGANIZATION_ID   = T.ORGANIZATION_ID
			AND    B.REVISION_ID       = T.REVISION_ID
		        AND    B.LANGUAGE          = T.SOURCE_LANG)
   WHERE (T.INVENTORY_ITEM_ID,
          T.ORGANIZATION_ID,
          T.REVISION_ID,
          T.LANGUAGE) IN (SELECT SUBT.INVENTORY_ITEM_ID,
				 SUBT.ORGANIZATION_ID,
			         SUBT.REVISION_ID,
				 SUBT.LANGUAGE
			  FROM   MTL_ITEM_REVISIONS_TL SUBB,
				 MTL_ITEM_REVISIONS_TL SUBT
			  WHERE  SUBB.INVENTORY_ITEM_ID = SUBT.INVENTORY_ITEM_ID
			  AND    SUBB.ORGANIZATION_ID = SUBT.ORGANIZATION_ID
			  AND    SUBB.REVISION_ID = SUBT.REVISION_ID
			  AND    SUBB.LANGUAGE = SUBT.SOURCE_LANG
			  AND   (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
				or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
				or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)));
*/
   INSERT INTO MTL_ITEM_REVISIONS_TL (
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    REVISION_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
   ) SELECT B.INVENTORY_ITEM_ID,
	    B.ORGANIZATION_ID,
	    B.REVISION_ID,
	    B.DESCRIPTION,
	    B.CREATION_DATE,
	    B.CREATED_BY,
	    B.LAST_UPDATE_DATE,
	    B.LAST_UPDATED_BY,
	    B.LAST_UPDATE_LOGIN,
	    L.LANGUAGE_CODE,
	    B.SOURCE_LANG
     FROM  MTL_ITEM_REVISIONS_TL B,
           FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG IN ('I', 'B')
     AND   B.LANGUAGE = USERENV('LANG')
     AND  NOT EXISTS (SELECT NULL
		      FROM MTL_ITEM_REVISIONS_TL T
		      WHERE T.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
		      AND T.ORGANIZATION_ID     = B.ORGANIZATION_ID
		      AND T.REVISION_ID         = B.REVISION_ID
		      AND T.LANGUAGE            = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end MTL_ITEM_REVISIONS_UTIL;

/
