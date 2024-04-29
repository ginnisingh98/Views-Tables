--------------------------------------------------------
--  DDL for Package Body AMS_ACT_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACT_LISTS_PKG" as
/* $Header: amstalsb.pls 115.8 2003/05/08 20:55:55 jieli ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ACT_LISTS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_ACT_LISTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstalsb.pls';


----------------------------------------------------------
--  NAME
--  createInsertBody
--  PURPOSE
--  NOTES
--  HISTORY
----------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_act_list_header_id    IN OUT NOCOPY NUMBER,
          p_last_update_date              DATE,
          p_last_updated_by               NUMBER,
          p_creation_date                 DATE,
          p_created_by                    NUMBER,
          px_object_version_number IN OUT NOCOPY NUMBER,
          p_last_update_login             NUMBER,
          p_list_header_id                NUMBER,
          p_group_code                    varchar2,
          p_list_used_by_id               NUMBER,
          p_list_used_by                  VARCHAR2,
          p_list_act_type                 VARCHAR2,
	  p_list_action_type              VARCHAR2,
	  p_order_number                  NUMBER
          )

 IS
   x_rowid    VARCHAR2(30);
BEGIN
   px_object_version_number := 1;
   INSERT INTO AMS_ACT_LISTS(
           act_list_header_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           object_version_number,
           last_update_login,
           list_header_id,
           group_code,
           list_used_by_id,
           list_used_by,
           list_act_type,
	   list_action_type,
	   order_number
                             )
   VALUES (
    DECODE(px_act_list_header_id,FND_API.g_miss_num,NULL,px_act_list_header_id),
    DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
    DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
    DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
    DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
    DECODE( px_object_version_number,FND_API.g_miss_num,NULL,
                  px_object_version_number),
    DECODE( p_last_update_login,FND_API.g_miss_num,NULL, p_last_update_login),
    DECODE( p_list_header_id, FND_API.g_miss_num, NULL, p_list_header_id),
    DECODE( p_group_code, FND_API.g_miss_char, NULL, p_group_code),
    DECODE( p_list_used_by_id, FND_API.g_miss_num, NULL, p_list_used_by_id),
    DECODE( p_list_used_by, FND_API.g_miss_char, NULL, p_list_used_by),
    DECODE( p_list_act_type, FND_API.g_miss_char, NULL, p_list_act_type),
    DECODE( p_list_action_type, FND_API.g_miss_char, NULL, p_list_action_type),
    DECODE( p_order_number, FND_API.g_miss_num, NULL, p_order_number));
END Insert_Row;


--  ========================================================
--  NAME
--  createUpdateBody
--  PURPOSE
--  NOTES
--  HISTORY
--  ========================================================
PROCEDURE Update_Row(
          p_act_list_header_id       NUMBER,
          p_last_update_date         DATE,
          p_last_updated_by          NUMBER,
          p_creation_date            DATE,
          p_created_by               NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_login        NUMBER,
          p_list_header_id           NUMBER,
          p_group_code               VArchar2,
          p_list_used_by_id          NUMBER,
          p_list_used_by             VARCHAR2,
          p_list_act_type            VARCHAR2,
	  p_list_action_type         VARCHAR2,
	  p_order_number             NUMBER
          )
IS
BEGIN
    Update AMS_ACT_LISTS
    SET act_list_header_id = DECODE( p_act_list_header_id,
                                     FND_API.g_miss_num,
                                     act_list_header_id,
                                     p_act_list_header_id),
        last_update_date = DECODE( p_last_update_date,
                                   FND_API.g_miss_date,
                                   last_update_date,
                                   p_last_update_date),
        last_updated_by = DECODE( p_last_updated_by,
                                  FND_API.g_miss_num,
                                  last_updated_by,
                                  p_last_updated_by),
        creation_date =   DECODE( p_creation_date,
                                  FND_API.g_miss_date,
                                  creation_date,
                                  p_creation_date),
        created_by   = DECODE( p_created_by,
                               FND_API.g_miss_num,
                               created_by,
                               p_created_by),
        object_version_number = DECODE( p_object_version_number,
                                FND_API.g_miss_num,
                                object_version_number,
                                p_object_version_number),
        last_update_login = DECODE(
                                p_last_update_login,
                                FND_API.g_miss_num,
                                last_update_login,
                                p_last_update_login),
        list_header_id = DECODE( p_list_header_id,
                                FND_API.g_miss_num,
                                list_header_id,
                                p_list_header_id),
        group_code     = DECODE( p_group_code    ,
                                FND_API.g_miss_char,
                                group_code    ,
                                p_group_code    ),
        list_used_by_id = DECODE( p_list_used_by_id,
                                FND_API.g_miss_num,
                                list_used_by_id,
                                p_list_used_by_id),
        list_used_by = DECODE( p_list_used_by,
                                FND_API.g_miss_char,
                                list_used_by,
                                p_list_used_by),
        list_act_type  = DECODE( p_list_act_type ,
                                FND_API.g_miss_char,
                                list_act_type ,
                                p_list_act_type ),
        list_action_type  = DECODE( p_list_action_type ,
                                FND_API.g_miss_char,
                                list_action_type ,
                                p_list_action_type ),
        order_number = DECODE( p_order_number,
                                FND_API.g_miss_num,
                                order_number,
                                p_order_number)
   WHERE ACT_LIST_HEADER_ID = p_ACT_LIST_HEADER_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;

--  ========================================================
--  NAME
--  createDeleteBody
--  PURPOSE
--  NOTES
--  HISTORY
--  ========================================================
PROCEDURE Delete_Row(
    p_ACT_LIST_HEADER_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_ACT_LISTS
    WHERE ACT_LIST_HEADER_ID = p_ACT_LIST_HEADER_ID;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;


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
          p_act_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_login    NUMBER,
          p_list_header_id    NUMBER,
          p_group_code        VARCHAR2,
          p_list_used_by_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_act_type   VARCHAR2,
	  p_list_action_type   VARCHAR2,
	  p_order_number   NUMBER
          )

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_ACT_LISTS
        WHERE ACT_LIST_HEADER_ID =  p_ACT_LIST_HEADER_ID
        FOR UPDATE of ACT_LIST_HEADER_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.act_list_header_id = p_act_list_header_id)
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.list_header_id = p_list_header_id)
            OR (    ( Recinfo.list_header_id IS NULL )
                AND (  p_list_header_id IS NULL )))
       AND (    ( Recinfo.group_code = p_group_code)
            OR (    ( Recinfo.group_code IS NULL )
                AND (  p_group_code IS NULL )))
       AND (    ( Recinfo.list_used_by_id = p_list_used_by_id)
            OR (    ( Recinfo.list_used_by_id IS NULL )
                AND (  p_list_used_by_id IS NULL )))
       AND (    ( Recinfo.list_used_by = p_list_used_by)
            OR (    ( Recinfo.list_used_by IS NULL )
                AND (  p_list_used_by IS NULL )))
       AND (    ( Recinfo.list_act_type = p_list_act_type)
            OR (    ( Recinfo.list_act_type IS NULL )
                AND (  p_list_act_type IS NULL )))
       AND (    ( Recinfo.list_action_type = p_list_action_type)
            OR (    ( Recinfo.list_action_type IS NULL )
                AND (  p_list_action_type IS NULL )))
       AND (    ( Recinfo.order_number = p_order_number)
            OR (    ( Recinfo.order_number IS NULL )
                AND (  p_order_number IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_ACT_LISTS_PKG;

/
