--------------------------------------------------------
--  DDL for Package CSP_PARTS_LOOPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PARTS_LOOPS_PKG" AUTHID CURRENT_USER as
/* $Header: csptplps.pls 115.5 2002/11/26 07:08:58 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PARTS_LOOPS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PARTS_LOOP_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_CALCULATION_RULE_ID    NUMBER,
          p_FORECAST_RULE_ID    NUMBER,
          p_PARTS_LOOP_NAME    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_DESCRIPTION    VARCHAR2);

PROCEDURE Update_Row(
          p_PARTS_LOOP_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_CALCULATION_RULE_ID    NUMBER,
          p_FORECAST_RULE_ID    NUMBER,
          p_PARTS_LOOP_NAME    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_DESCRIPTION    VARCHAR2);

PROCEDURE Lock_Row(
          p_PARTS_LOOP_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_CALCULATION_RULE_ID    NUMBER,
          p_FORECAST_RULE_ID    NUMBER,
          p_PARTS_LOOP_NAME    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_DESCRIPTION    VARCHAR2);

PROCEDURE Delete_Row(
    p_PARTS_LOOP_ID  NUMBER);

procedure add_language;

procedure translate_row
( p_parts_loop_id	in	number,
  p_description	in	varchar2,
  p_owner           in   varchar2);

procedure load_row
( p_parts_loop_id	in	number,
  p_description	in	varchar2,
  p_owner           in   varchar2);

End CSP_PARTS_LOOPS_PKG;

 

/
