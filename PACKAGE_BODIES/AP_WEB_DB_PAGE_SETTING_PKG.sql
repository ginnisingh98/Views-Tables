--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_PAGE_SETTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_PAGE_SETTING_PKG" AS
/* $Header: apwcpgsb.pls 120.0 2006/09/06 16:37:45 qle noship $ */

--
--
-- Author: quan le
-- Purpose: To save the specified setting.
--
-- Input: p_userId IN NUMBER,
--        p_pageName IN VARCHAR2,
--        p_objectName IN VARCHAR2,
--        p_objectType IN VARCHAR2,
--        p_hideFlag IN VARCHAR2,
--        p_selectedTab IN VARCHAR2,
--        p_sortedColumn IN VARCHAR2,
--        p_sortOrderCode IN VARCHAR2
--
-- Output: N/A
--
PROCEDURE saveSetting(p_userId IN NUMBER,
                      p_pageName IN VARCHAR2,
                      p_objectName IN VARCHAR2,
                      p_objectTypeCode IN VARCHAR2,
                      p_hideFlag IN VARCHAR2,
                      p_selectedTab IN VARCHAR2,
                      p_sortedColumn IN VARCHAR2,
                      p_sortOrderCode IN VARCHAR2
) IS
PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR settingCursor IS
  SELECT *
  FROM   OIE_CURRENT_PAGE_SETTING
  WHERE  user_id = p_userId
     AND page_Name = p_pageName
     AND object_Name = p_objectName
     AND object_Type_code = p_objectTypeCode
  FOR UPDATE OF USER_ID NOWAIT;

  settingRec   settingCursor%rowtype;

BEGIN
  -- Update the setting if exists; otherwise, create a new record

  OPEN settingCursor;
  FETCH settingCursor INTO settingRec;

  IF settingCursor%NOTFOUND THEN
    -- create new record
      INSERT INTO OIE_CURRENT_PAGE_SETTING(
        USER_ID,
        PAGE_NAME,
        OBJECT_NAME,
        OBJECT_TYPE_CODE,
        HIDE_FLAG,
        SELECTED_TAB,
        SORTED_COLUMN,
        SORT_ORDER_CODE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY)
      VALUES (
        p_userId,
        p_pageName,
        p_objectName,
        p_objectTypeCode,
        p_hideFlag,
        p_selectedTab,
        p_sortedColumn,
        p_sortOrderCode,
        SYSDATE,
        nvl(fnd_global.user_id, -1),
        fnd_global.conc_login_id,
        SYSDATE,
        nvl(fnd_global.user_id, -1));

  ELSE
    -- update the current record
    UPDATE OIE_CURRENT_PAGE_SETTING
    SET hide_flag = p_hideFlag,
        selected_tab = p_selectedTab,
        sorted_column = p_sortedColumn,
        sort_order_code = p_sortOrderCode
    WHERE CURRENT OF settingCursor;

  END IF;

  CLOSE settingCursor;

  commit;

END saveSetting;

END AP_WEB_DB_PAGE_SETTING_PKG;

/
