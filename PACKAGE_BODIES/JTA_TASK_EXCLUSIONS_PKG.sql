--------------------------------------------------------
--  DDL for Package Body JTA_TASK_EXCLUSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_TASK_EXCLUSIONS_PKG" AS
/* $Header: jtavsemb.pls 115.5 2002/05/13 10:01:17 pkm ship   $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   jtavstmb.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is used to insert/update/delete sync task            |
 |                      mapping record.                                  |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date      Developer   Change                                          |
 |--------   ---------   ------------------------------------------------|
 | 3/13/02   SSALLAKA    created                                         |
 | 3/14/02   cjang       Modified Insert_Row                             |
 | 3/15/02   cjang       Modified Insert_Row                             |
 |                         to update last_update_date in the table       |
 |                                        jtf_task_recur_rules.          |
 | 4/03/02   cjang       Modified a cursor in Insert_Row                 |
 | 5/09/02   cjang       Added WHO parameters in Insert_Row and Update_Row
  ------------------------------------------------------------------------*/
PROCEDURE Insert_Row (
      p_task_exclusion_id        IN NUMBER,
      p_task_id                  IN NUMBER,
      p_recurrence_rule_id       IN NUMBER,
      p_exclusion_date           IN DATE,
      p_created_by               IN NUMBER DEFAULT NULL,
      p_creation_date            IN DATE   DEFAULT NULL,
      p_last_updated_by          IN NUMBER DEFAULT NULL,
      p_last_update_date         IN DATE   DEFAULT NULL,
      p_last_update_login        IN NUMBER DEFAULT NULL,
      p_security_group_id        IN NUMBER DEFAULT NULL
      )
      IS
      l_current_date DATE   := SYSDATE;
      l_user_id      NUMBER := fnd_global.user_id;
      l_login_id     NUMBER := fnd_global.login_id;

      CURSOR c_exclusion IS
      SELECT '1'
        FROM jta_task_exclusions
       WHERE task_id = p_task_id
         AND recurrence_rule_id = p_recurrence_rule_id;

      l_exists VARCHAR2(1);
BEGIN
      OPEN c_exclusion;
      FETCH c_exclusion INTO l_exists;
      IF c_exclusion%NOTFOUND
      THEN
          CLOSE c_exclusion;
          INSERT INTO jta_task_exclusions
            (
            TASK_EXCLUSION_ID,
            TASK_ID          ,
            RECURRENCE_RULE_ID,
            EXCLUSION_DATE    ,
            CREATED_BY        ,
            CREATION_DATE    ,
            LAST_UPDATED_BY  ,
            LAST_UPDATE_DATE  ,
            LAST_UPDATE_LOGIN ,
            SECURITY_GROUP_ID
            )
            VALUES
            (
            p_task_exclusion_id,
            p_task_id,
            p_recurrence_rule_id,
            p_exclusion_date,
            nvl(p_created_by, l_user_id),
            nvl(p_creation_date, l_current_date),
            nvl(p_last_updated_by, l_user_id),
            nvl(p_last_update_date, l_current_date),
            nvl(p_last_update_login, l_login_id),
            p_security_group_id
            );

          UPDATE jtf_task_recur_rules
             SET last_update_date = l_current_date
           WHERE recurrence_rule_id = p_recurrence_rule_id;
      ELSE
          CLOSE c_exclusion;
      END IF;
END Insert_Row;

PROCEDURE Update_Row (
      p_task_exclusion_id        IN NUMBER,
      p_task_id                  IN NUMBER,
      p_recurrence_rule_id       IN NUMBER,
      p_exclusion_date           IN DATE,
      p_last_updated_by          IN NUMBER DEFAULT NULL,
      p_last_update_date         IN DATE   DEFAULT NULL,
      p_last_update_login        IN NUMBER DEFAULT NULL
      )
      IS
      l_current_date DATE := SYSDATE;
      l_user_id NUMBER := fnd_global.user_id;
      l_login_id NUMBER := fnd_global.login_id;
      BEGIN

      UPDATE jta_task_exclusions
       SET  TASK_ID = p_task_id,
            RECURRENCE_RULE_ID = p_recurrence_rule_id,
            EXCLUSION_DATE = p_exclusion_date,
            LAST_UPDATED_BY  = nvl(p_last_updated_by, l_user_id),
            LAST_UPDATE_DATE  = nvl(p_last_update_date, l_current_date),
            LAST_UPDATE_LOGIN = nvl(p_last_update_login, l_login_id)
       WHERE TASK_EXCLUSION_ID = p_task_exclusion_id;
END Update_Row;

PROCEDURE Delete_Row (
      p_task_exclusion_id        IN NUMBER
    )
    IS
    BEGIN
   DELETE FROM jta_task_exclusions
    WHERE TASK_EXCLUSION_ID = p_task_exclusion_id;
END Delete_Row;

END JTA_TASK_EXCLUSIONS_PKG;

/
