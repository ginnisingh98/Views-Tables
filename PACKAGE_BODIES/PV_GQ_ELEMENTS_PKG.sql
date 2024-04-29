--------------------------------------------------------
--  DDL for Package Body PV_GQ_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GQ_ELEMENTS_PKG" as
/* $Header: pvxtgqeb.pls 120.2 2006/07/27 19:05:34 saarumug noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Gq_Elements_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Gq_Elements_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtgqeb.pls';




--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_qsnr_element_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_used_by_entity_code    VARCHAR2,
          p_used_by_entity_id    NUMBER,
          p_qsnr_elmt_seq_num    NUMBER,
          p_qsnr_elmt_type    VARCHAR2,
          p_entity_attr_id    NUMBER,
          p_qsnr_elmt_page_num    NUMBER,
          p_is_required_flag    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_elmt_content    VARCHAR2
)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_ge_qsnr_elements_b(
           qsnr_element_id,
           object_version_number,
           arc_used_by_entity_code,
           used_by_entity_id,
           qsnr_elmt_seq_num,
           qsnr_elmt_type,
           entity_attr_id,
           qsnr_elmt_page_num,
           is_required_flag,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
   ) VALUES (
           DECODE( px_qsnr_element_id, FND_API.G_MISS_NUM, NULL, px_qsnr_element_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_arc_used_by_entity_code, FND_API.g_miss_char, NULL, p_arc_used_by_entity_code),
           DECODE( p_used_by_entity_id, FND_API.G_MISS_NUM, NULL, p_used_by_entity_id),
           DECODE( p_qsnr_elmt_seq_num, FND_API.G_MISS_NUM, NULL, p_qsnr_elmt_seq_num),
           DECODE( p_qsnr_elmt_type, FND_API.g_miss_char, NULL, p_qsnr_elmt_type),
           DECODE( p_entity_attr_id, FND_API.G_MISS_NUM, NULL, p_entity_attr_id),
           DECODE( p_qsnr_elmt_page_num, FND_API.G_MISS_NUM, NULL, p_qsnr_elmt_page_num),
           DECODE( p_is_required_flag, FND_API.g_miss_char, NULL, p_is_required_flag),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login));

   INSERT INTO pv_ge_qsnr_elements_tl(
           qsnr_element_id ,
           --object_version_number,
           language ,
           last_update_date ,
           last_updated_by ,
           creation_date ,
           created_by ,
           last_update_login ,
           source_lang ,
           elmt_content
)
SELECT
           DECODE( px_qsnr_element_id, FND_API.G_MISS_NUM, NULL, px_qsnr_element_id),
           --DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           l.language_code,
           DECODE( p_last_update_date, NULL, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, NULL, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, NULL, SYSDATE, p_creation_date),
           DECODE( p_created_by, NULL, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           USERENV('LANG'),
           DECODE( p_elmt_content, FND_API.G_MISS_CHAR, NULL, p_elmt_content)
   FROM fnd_languages l
   WHERE l.installed_flag IN ('I','B')
   AND   NOT EXISTS(SELECT NULL FROM pv_ge_qsnr_elements_tl t
                    WHERE t.qsnr_element_id = DECODE( px_qsnr_element_id, FND_API.G_MISS_NUM, NULL, px_qsnr_element_id)
                    AND   t.language = l.language_code);
END Insert_Row;




--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_qsnr_element_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_used_by_entity_code    VARCHAR2,
          p_used_by_entity_id    NUMBER,
          p_qsnr_elmt_seq_num    NUMBER,
          p_qsnr_elmt_type    VARCHAR2,
          p_entity_attr_id    NUMBER,
          p_qsnr_elmt_page_num    NUMBER,
          p_is_required_flag    VARCHAR2,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_elmt_content    VARCHAR2
)

 IS
 BEGIN
    Update pv_ge_qsnr_elements_b
    SET
              qsnr_element_id = DECODE( p_qsnr_element_id, null, qsnr_element_id, FND_API.G_MISS_NUM, null, p_qsnr_element_id),
            --object_version_number = object_version_number + 1 ,
              object_version_number = DECODE( px_object_version_number, NULL, object_version_number, FND_API.g_miss_num, NULL, px_object_version_number+1),
              arc_used_by_entity_code = DECODE( p_arc_used_by_entity_code, null, arc_used_by_entity_code, FND_API.g_miss_char, null, p_arc_used_by_entity_code),
              used_by_entity_id = DECODE( p_used_by_entity_id, null, used_by_entity_id, FND_API.G_MISS_NUM, null, p_used_by_entity_id),
              qsnr_elmt_seq_num = DECODE( p_qsnr_elmt_seq_num, null, qsnr_elmt_seq_num, FND_API.G_MISS_NUM, null, p_qsnr_elmt_seq_num),
              qsnr_elmt_type = DECODE( p_qsnr_elmt_type, null, qsnr_elmt_type, FND_API.g_miss_char, null, p_qsnr_elmt_type),
              entity_attr_id = DECODE( p_entity_attr_id, null, entity_attr_id, FND_API.G_MISS_NUM, null, p_entity_attr_id),
              qsnr_elmt_page_num = DECODE( p_qsnr_elmt_page_num, null, qsnr_elmt_page_num, FND_API.G_MISS_NUM, null, p_qsnr_elmt_page_num),
              is_required_flag = DECODE( p_is_required_flag, null, is_required_flag, FND_API.g_miss_char, null, p_is_required_flag),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE qsnr_element_id = p_qsnr_element_id
   AND   object_version_number = px_object_version_number;

   UPDATE pv_ge_qsnr_elements_tl
   set elmt_content = DECODE( p_elmt_content, null, elmt_content, FND_API.g_miss_char, null, p_elmt_content),
       last_update_date   = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
       last_updated_by   = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
       last_update_login   = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
       source_lang = USERENV('LANG')
   WHERE qsnr_element_id = p_qsnr_element_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   px_object_version_number := nvl(px_object_version_number,0) + 1;

END Update_Row;




--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_qsnr_element_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_ge_qsnr_elements_b
    WHERE qsnr_element_id = p_qsnr_element_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;





--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_qsnr_element_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_ge_qsnr_elements_b
        WHERE qsnr_element_id =  p_qsnr_element_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF qsnr_element_id NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN

   OPEN c;
   FETCH c INTO Recinfo;
   IF (c%NOTFOUND) THEN
      CLOSE c;
      AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c;
END Lock_Row;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           add_language
--   Type
--           Private
--   History
--
--   NOTE
--
-- End of Comments
-- ===============================================================



PROCEDURE Add_Language
IS
BEGIN
  -- changing by pukken as per performance team guidelines to fix performance issue
  -- as described in bug 3723612 (*** RTIKKU  03/24/05 12:46pm ***)
  INSERT /*+ append parallel(tt) */ INTO pv_ge_qsnr_elements_tl tt
  (
     qsnr_element_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     elmt_content,
     language,
     source_lang
  )
  SELECT /*+ parallel(v) parallel(t) use_nl(t)  */ v.*
  FROM
     (
         SELECT /*+ no_merge ordered parallel(b) */
         b.qsnr_element_id,
         b.creation_date,
         b.created_by,
         b.last_update_date,
         b.last_updated_by,
         b.last_update_login,
         b.elmt_content,
         l.language_code,
         b.source_lang
         FROM  pv_ge_qsnr_elements_tl B , FND_LANGUAGES L
         WHERE L.INSTALLED_FLAG IN ( 'I','B' ) AND B.LANGUAGE = USERENV ( 'LANG' )
     ) v
     , pv_ge_qsnr_elements_tl t
     WHERE t.qsnr_element_id(+) = v.qsnr_element_id
     AND t.language(+) = v.language_code
     AND t.qsnr_element_id IS NULL ;


END ADD_LANGUAGE;

-- ===========================================================================
-- THIS SECTION HAS BEEN ADDED TO SUPPORT THE CALL FROM JAV OA TL ENTITY IMPL.
-- IN OA  THE OBJECT VERSION NUMBER IS HANDLED IN THE MIDDLE TIER WHEREAS IN THIS
-- TABLE HANDLER THE OBJECT VERSION NUMBER IS CHANGED IN THE PL/SQL PACKAGE.
-- SO THIS TABLE HANDLER CANNOT BE USED IN THE FORM THAT IT IS IN.
--
-- INSTEAD OF CREATING A NEW TABLE HANDLER THE PRODUCURES INSERT_ROW, UPDATE_ROW,
-- LOCK_ROW AND DELETE_ROW WILL BE OVERRIDDEN. A NEW SET OF SIGNATURES WILL BE
-- ADDED THAT ARE CONSISTANT WITH THE OA STANDARD FOR TABLE HANDLER IMPLEMENTATION
--
-- Bug 5400481
-- ======================================================================
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_QSNR_ELEMENT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_USED_BY_ENTITY_CODE in VARCHAR2,
  X_USED_BY_ENTITY_ID in NUMBER,
  X_QSNR_ELMT_SEQ_NUM in NUMBER,
  X_QSNR_ELMT_TYPE in VARCHAR2,
  X_ENTITY_ATTR_ID in NUMBER,
  X_QSNR_ELMT_PAGE_NUM in NUMBER,
  X_IS_REQUIRED_FLAG in VARCHAR2,
  X_ELMT_CONTENT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PV_GE_QSNR_ELEMENTS_B
    where QSNR_ELEMENT_ID = X_QSNR_ELEMENT_ID
    ;
begin
  insert into PV_GE_QSNR_ELEMENTS_B (
    QSNR_ELEMENT_ID,
    OBJECT_VERSION_NUMBER,
    ARC_USED_BY_ENTITY_CODE,
    USED_BY_ENTITY_ID,
    QSNR_ELMT_SEQ_NUM,
    QSNR_ELMT_TYPE,
    ENTITY_ATTR_ID,
    QSNR_ELMT_PAGE_NUM,
    IS_REQUIRED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_QSNR_ELEMENT_ID,
    X_OBJECT_VERSION_NUMBER,
    X_ARC_USED_BY_ENTITY_CODE,
    X_USED_BY_ENTITY_ID,
    X_QSNR_ELMT_SEQ_NUM,
    X_QSNR_ELMT_TYPE,
    X_ENTITY_ATTR_ID,
    X_QSNR_ELMT_PAGE_NUM,
    X_IS_REQUIRED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PV_GE_QSNR_ELEMENTS_TL (
    QSNR_ELEMENT_ID,
    ELMT_CONTENT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_QSNR_ELEMENT_ID,
    X_ELMT_CONTENT,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PV_GE_QSNR_ELEMENTS_TL T
    where T.QSNR_ELEMENT_ID = X_QSNR_ELEMENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_QSNR_ELEMENT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_USED_BY_ENTITY_CODE in VARCHAR2,
  X_USED_BY_ENTITY_ID in NUMBER,
  X_QSNR_ELMT_SEQ_NUM in NUMBER,
  X_QSNR_ELMT_TYPE in VARCHAR2,
  X_ENTITY_ATTR_ID in NUMBER,
  X_QSNR_ELMT_PAGE_NUM in NUMBER,
  X_IS_REQUIRED_FLAG in VARCHAR2,
  X_ELMT_CONTENT in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ARC_USED_BY_ENTITY_CODE,
      USED_BY_ENTITY_ID,
      QSNR_ELMT_SEQ_NUM,
      QSNR_ELMT_TYPE,
      ENTITY_ATTR_ID,
      QSNR_ELMT_PAGE_NUM,
      IS_REQUIRED_FLAG
    from PV_GE_QSNR_ELEMENTS_B
    where QSNR_ELEMENT_ID = X_QSNR_ELEMENT_ID
    for update of QSNR_ELEMENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ELMT_CONTENT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PV_GE_QSNR_ELEMENTS_TL
    where QSNR_ELEMENT_ID = X_QSNR_ELEMENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of QSNR_ELEMENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.ARC_USED_BY_ENTITY_CODE = X_ARC_USED_BY_ENTITY_CODE)
      AND (recinfo.USED_BY_ENTITY_ID = X_USED_BY_ENTITY_ID)
      AND (recinfo.QSNR_ELMT_SEQ_NUM = X_QSNR_ELMT_SEQ_NUM)
      AND (recinfo.QSNR_ELMT_TYPE = X_QSNR_ELMT_TYPE)
      AND ((recinfo.ENTITY_ATTR_ID = X_ENTITY_ATTR_ID)
           OR ((recinfo.ENTITY_ATTR_ID is null) AND (X_ENTITY_ATTR_ID is null)))
      AND (recinfo.QSNR_ELMT_PAGE_NUM = X_QSNR_ELMT_PAGE_NUM)
      AND (recinfo.IS_REQUIRED_FLAG = X_IS_REQUIRED_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.ELMT_CONTENT = X_ELMT_CONTENT)
               OR ((tlinfo.ELMT_CONTENT is null) AND (X_ELMT_CONTENT is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_QSNR_ELEMENT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_USED_BY_ENTITY_CODE in VARCHAR2,
  X_USED_BY_ENTITY_ID in NUMBER,
  X_QSNR_ELMT_SEQ_NUM in NUMBER,
  X_QSNR_ELMT_TYPE in VARCHAR2,
  X_ENTITY_ATTR_ID in NUMBER,
  X_QSNR_ELMT_PAGE_NUM in NUMBER,
  X_IS_REQUIRED_FLAG in VARCHAR2,
  X_ELMT_CONTENT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PV_GE_QSNR_ELEMENTS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ARC_USED_BY_ENTITY_CODE = X_ARC_USED_BY_ENTITY_CODE,
    USED_BY_ENTITY_ID = X_USED_BY_ENTITY_ID,
    QSNR_ELMT_SEQ_NUM = X_QSNR_ELMT_SEQ_NUM,
    QSNR_ELMT_TYPE = X_QSNR_ELMT_TYPE,
    ENTITY_ATTR_ID = X_ENTITY_ATTR_ID,
    QSNR_ELMT_PAGE_NUM = X_QSNR_ELMT_PAGE_NUM,
    IS_REQUIRED_FLAG = X_IS_REQUIRED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where QSNR_ELEMENT_ID = X_QSNR_ELEMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PV_GE_QSNR_ELEMENTS_TL set
    ELMT_CONTENT = X_ELMT_CONTENT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where QSNR_ELEMENT_ID = X_QSNR_ELEMENT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QSNR_ELEMENT_ID in NUMBER
) is
begin
  delete from PV_GE_QSNR_ELEMENTS_TL
  where QSNR_ELEMENT_ID = X_QSNR_ELEMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PV_GE_QSNR_ELEMENTS_B
  where QSNR_ELEMENT_ID = X_QSNR_ELEMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;



END PV_Gq_Elements_PKG;

/
