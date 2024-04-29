--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PS_RULES_PKG" as
/* $Header: amstrulb.pls 120.0 2005/05/31 14:42:20 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PS_RULES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PS_RULES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstrulb.pls';


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
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          px_rule_id   IN OUT NOCOPY NUMBER,
          p_rulegroup_id    NUMBER,
          p_posting_id    NUMBER,
          p_strategy_id    NUMBER,
          p_exec_priority  NUMBER,
          p_bus_priority_code    VARCHAR2,
          p_bus_priority_disp_order    VARCHAR2,
          p_clausevalue1    VARCHAR2,
          p_clausevalue2    NUMBER,
          p_clausevalue3    VARCHAR2,
          p_clausevalue4    VARCHAR2,
          p_clausevalue5    NUMBER,
          p_clausevalue6    VARCHAR2,
          p_clausevalue7    VARCHAR2,
          p_clausevalue8    VARCHAR2,
          p_clausevalue9    VARCHAR2,
          p_clausevalue10    VARCHAR2,
          p_use_clause6      VARCHAR2,
          p_use_clause7      VARCHAR2,
          p_use_clause8      VARCHAR2,
          p_use_clause9      VARCHAR2,
          p_use_clause10     VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_IBA_PS_RULES(
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number,
           rule_id,
           rulegroup_id,
           posting_id,
           strategy_id,
	   exec_priority,
           bus_priority_code,
           bus_priority_disp_order,
           clausevalue1,
           clausevalue2,
           clausevalue3,
           clausevalue4,
           clausevalue5,
           clausevalue6,
           clausevalue7,
           clausevalue8,
           clausevalue9,
           clausevalue10,
	   use_clause6,
	   use_clause7,
	   use_clause8,
	   use_clause9,
	   use_clause10
   ) VALUES (
        DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
        DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
        DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
        DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
        DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
        DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
        DECODE( px_rule_id, FND_API.g_miss_num, NULL, px_rule_id),
        DECODE( p_rulegroup_id, FND_API.g_miss_num, NULL, p_rulegroup_id),
        DECODE( p_posting_id, FND_API.g_miss_num, NULL, p_posting_id),
        DECODE( p_strategy_id, FND_API.g_miss_num, NULL, p_strategy_id),
        DECODE( p_exec_priority, FND_API.g_miss_num, NULL, p_exec_priority),
        DECODE( p_bus_priority_code, FND_API.g_miss_char, NULL, p_bus_priority_code),
        DECODE( p_bus_priority_disp_order, FND_API.g_miss_char, NULL, p_bus_priority_disp_order),
        DECODE( p_clausevalue1, FND_API.g_miss_char, NULL, p_clausevalue1),
        DECODE( p_clausevalue2, FND_API.g_miss_num, NULL, p_clausevalue2),
        DECODE( p_clausevalue3, FND_API.g_miss_char, NULL, p_clausevalue3),
        DECODE( p_clausevalue4, FND_API.g_miss_char, NULL, p_clausevalue4),
        DECODE( p_clausevalue5, FND_API.g_miss_num, NULL, p_clausevalue5),
        DECODE( p_clausevalue6, FND_API.g_miss_char, NULL, p_clausevalue6),
        DECODE( p_clausevalue7, FND_API.g_miss_char, NULL, p_clausevalue7),
        DECODE( p_clausevalue8, FND_API.g_miss_char, NULL, p_clausevalue8),
        DECODE( p_clausevalue9, FND_API.g_miss_char, NULL, p_clausevalue9),
        DECODE( p_clausevalue10, FND_API.g_miss_char, NULL, p_clausevalue10),
        DECODE( p_use_clause6, FND_API.g_miss_char, NULL, p_use_clause6),
        DECODE( p_use_clause7, FND_API.g_miss_char, NULL, p_use_clause7),
        DECODE( p_use_clause8, FND_API.g_miss_char, NULL, p_use_clause8),
        DECODE( p_use_clause9, FND_API.g_miss_char, NULL, p_use_clause9),
        DECODE( p_use_clause10, FND_API.g_miss_char, NULL, p_use_clause10));

END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ======================================================
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
--  ======================================================
PROCEDURE Update_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_rule_id    NUMBER,
          p_rulegroup_id    NUMBER,
          p_posting_id    NUMBER,
          p_strategy_id    NUMBER,
          p_exec_priority  NUMBER,
          p_bus_priority_code    VARCHAR2,
          p_bus_priority_disp_order    VARCHAR2,
          p_clausevalue1    VARCHAR2,
          p_clausevalue2    NUMBER,
          p_clausevalue3    VARCHAR2,
          p_clausevalue4    VARCHAR2,
          p_clausevalue5    NUMBER,
          p_clausevalue6    VARCHAR2,
          p_clausevalue7    VARCHAR2,
          p_clausevalue8    VARCHAR2,
          p_clausevalue9    VARCHAR2,
          p_clausevalue10    VARCHAR2,
          p_use_clause6      VARCHAR2,
          p_use_clause7      VARCHAR2,
          p_use_clause8      VARCHAR2,
          p_use_clause9      VARCHAR2,
          p_use_clause10     VARCHAR2)
 IS
 BEGIN
    Update AMS_IBA_PS_RULES
    SET
       created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
       creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
       rule_id = DECODE( p_rule_id, FND_API.g_miss_num, rule_id, p_rule_id),
       rulegroup_id = DECODE( p_rulegroup_id, FND_API.g_miss_num, rulegroup_id, p_rulegroup_id),
       posting_id = DECODE( p_posting_id, FND_API.g_miss_num, posting_id, p_posting_id),
       strategy_id = DECODE( p_strategy_id, FND_API.g_miss_num, strategy_id, p_strategy_id),
       bus_priority_code = DECODE( p_bus_priority_code, FND_API.g_miss_char, bus_priority_code, p_bus_priority_code),
       bus_priority_disp_order = DECODE( p_bus_priority_disp_order, FND_API.g_miss_char, bus_priority_disp_order, p_bus_priority_disp_order),
       clausevalue1 = DECODE( p_clausevalue1, FND_API.g_miss_char, clausevalue1, p_clausevalue1),
       clausevalue2 = DECODE( p_clausevalue2, FND_API.g_miss_num, clausevalue2, p_clausevalue2),
       clausevalue3 = DECODE( p_clausevalue3, FND_API.g_miss_char, clausevalue3, p_clausevalue3),
       clausevalue4 = DECODE( p_clausevalue4, FND_API.g_miss_char, clausevalue4, p_clausevalue4),
       clausevalue5 = DECODE( p_clausevalue5, FND_API.g_miss_num, clausevalue5, p_clausevalue5),
       clausevalue6 = DECODE( p_clausevalue6, FND_API.g_miss_char, clausevalue6, p_clausevalue6),
       clausevalue7 = DECODE( p_clausevalue7, FND_API.g_miss_char, clausevalue7, p_clausevalue7),
       clausevalue8 = DECODE( p_clausevalue8, FND_API.g_miss_char, clausevalue8, p_clausevalue8),
       clausevalue9 = DECODE( p_clausevalue9, FND_API.g_miss_char, clausevalue9, p_clausevalue9),
       clausevalue10 = DECODE( p_clausevalue10, FND_API.g_miss_char, clausevalue10, p_clausevalue10),
       use_clause6 = DECODE( p_use_clause6, FND_API.g_miss_char, use_clause6, p_use_clause6),
       use_clause7 = DECODE( p_use_clause7, FND_API.g_miss_char, use_clause7, p_use_clause7),
       use_clause8 = DECODE( p_use_clause8, FND_API.g_miss_char, use_clause8, p_use_clause8),
       use_clause9 = DECODE( p_use_clause9, FND_API.g_miss_char, use_clause9, p_use_clause9),
       use_clause10 = DECODE( p_use_clause10, FND_API.g_miss_char, use_clause10, p_use_clause10)

   WHERE RULE_ID = p_RULE_ID
   AND object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;

----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ======================================================
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
--  ======================================================
PROCEDURE Delete_Row(
    p_RULE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_IBA_PS_RULES
    WHERE RULE_ID = p_RULE_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ======================================================
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
--  ======================================================
PROCEDURE Lock_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_rule_id    NUMBER,
          p_rulegroup_id    NUMBER,
          p_posting_id    NUMBER,
          p_strategy_id    NUMBER,
          p_bus_priority_code    VARCHAR2,
          p_bus_priority_disp_order    VARCHAR2,
          p_clausevalue1    VARCHAR2,
          p_clausevalue2    NUMBER,
          p_clausevalue3    VARCHAR2,
          p_clausevalue4    VARCHAR2,
          p_clausevalue5    NUMBER,
          p_clausevalue6    VARCHAR2,
          p_clausevalue7    VARCHAR2,
          p_clausevalue8    VARCHAR2,
          p_clausevalue9    VARCHAR2,
          p_clausevalue10    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IBA_PS_RULES
        WHERE RULE_ID =  p_RULE_ID
        FOR UPDATE of RULE_ID NOWAIT;
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
           (      Recinfo.created_by = p_created_by)
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.rule_id = p_rule_id)
            OR (    ( Recinfo.rule_id IS NULL )
                AND (  p_rule_id IS NULL )))
       AND (    ( Recinfo.rulegroup_id = p_rulegroup_id)
            OR (    ( Recinfo.rulegroup_id IS NULL )
                AND (  p_rulegroup_id IS NULL )))
       AND (    ( Recinfo.posting_id = p_posting_id)
            OR (    ( Recinfo.posting_id IS NULL )
                AND (  p_posting_id IS NULL )))
       AND (    ( Recinfo.strategy_id = p_strategy_id)
            OR (    ( Recinfo.strategy_id IS NULL )
                AND (  p_strategy_id IS NULL )))
       AND (    ( Recinfo.bus_priority_code = p_bus_priority_code)
            OR (    ( Recinfo.bus_priority_code IS NULL )
                AND (  p_bus_priority_code IS NULL )))
       AND (    ( Recinfo.bus_priority_disp_order = p_bus_priority_disp_order)
            OR (    ( Recinfo.bus_priority_disp_order IS NULL )
                AND (  p_bus_priority_disp_order IS NULL )))
       AND (    ( Recinfo.clausevalue1 = p_clausevalue1)
            OR (    ( Recinfo.clausevalue1 IS NULL )
                AND (  p_clausevalue1 IS NULL )))
       AND (    ( Recinfo.clausevalue2 = p_clausevalue2)
            OR (    ( Recinfo.clausevalue2 IS NULL )
                AND (  p_clausevalue2 IS NULL )))
       AND (    ( Recinfo.clausevalue3 = p_clausevalue3)
            OR (    ( Recinfo.clausevalue3 IS NULL )
                AND (  p_clausevalue3 IS NULL )))
       AND (    ( Recinfo.clausevalue4 = p_clausevalue4)
            OR (    ( Recinfo.clausevalue4 IS NULL )
                AND (  p_clausevalue4 IS NULL )))
       AND (    ( Recinfo.clausevalue5 = p_clausevalue5)
            OR (    ( Recinfo.clausevalue5 IS NULL )
                AND (  p_clausevalue5 IS NULL )))
       AND (    ( Recinfo.clausevalue6 = p_clausevalue6)
            OR (    ( Recinfo.clausevalue6 IS NULL )
                AND (  p_clausevalue6 IS NULL )))
       AND (    ( Recinfo.clausevalue7 = p_clausevalue7)
            OR (    ( Recinfo.clausevalue7 IS NULL )
                AND (  p_clausevalue7 IS NULL )))
       AND (    ( Recinfo.clausevalue8 = p_clausevalue8)
            OR (    ( Recinfo.clausevalue8 IS NULL )
                AND (  p_clausevalue8 IS NULL )))
       AND (    ( Recinfo.clausevalue9 = p_clausevalue9)
            OR (    ( Recinfo.clausevalue9 IS NULL )
                AND (  p_clausevalue9 IS NULL )))
       AND (    ( Recinfo.clausevalue10 = p_clausevalue10)
            OR (    ( Recinfo.clausevalue10 IS NULL )
                AND (  p_clausevalue10 IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_IBA_PS_RULES_PKG;

/
