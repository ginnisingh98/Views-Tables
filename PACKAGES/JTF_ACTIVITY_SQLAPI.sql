--------------------------------------------------------
--  DDL for Package JTF_ACTIVITY_SQLAPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ACTIVITY_SQLAPI" AUTHID CURRENT_USER AS
/* $Header: jtfactss.pls 120.2 2005/10/25 05:13:09 psanyal ship $ */

procedure deleteActivityType(activityname IN varchar2);

procedure subscribeActivityType(AppID IN number, CategoryName IN varchar2, ActivityName IN varchar2);

procedure unsubscribeActivityType(AppID IN number, CategoryName IN varchar2, ActivityName IN varchar2);

procedure setActivityPriority(appID IN number, categoryname IN varchar2, activityname IN varchar2, Priority IN number);

procedure setActivityStatus(appID IN NUMBER, categoryname IN varchar2, activityname IN varchar2, Status IN varchar2);

-- Insert a new Profile Owner object into JTF_ProfileProperties_B/TL
-- Return the primary key for the newly inserted object.

-- HELPER FUNCTIONS
FUNCTION getActivityNameID(
  activityname IN JTF_ACT_TYPES_TL.activity_name%TYPE)
 RETURN NUMBER;

FUNCTION getActivityAttributeNameID(
 ActivityName IN JTF_ACT_TYPES_TL.activity_name%TYPE,
 AttributeName IN JTF_ACT_TYPES_ATTRS_TL.attribute_name%TYPE)
RETURN NUMBER;

FUNCTION isActivityDefined(
  ActivityName IN jtf_act_types_tl.activity_name%TYPE)
RETURN NUMBER;

PROCEDURE addActivityType (
  p_ActivityName IN JTF_ACT_TYPES_TL.activity_name%TYPE,
  p_appID IN JTF_ACT_TYPES_TL.last_updated_by%TYPE,
  p_tableName IN JTF_ACT_TYPES_B.table_name%TYPE,
  p_Desc IN JTF_ACT_TYPES_TL.description%TYPE,
  p_PK OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_NameID OUT NOCOPY /* file.sql.39 change */ JTF_ACT_TYPES_B.activity_name_id%TYPE);

PROCEDURE addActivityAttribute (
  p_ActivityName IN JTF_ACT_TYPES_TL.activity_name%TYPE,
  p_appID IN JTF_ACT_TYPES_TL.last_updated_by%TYPE,
  p_AttributeName IN JTF_ACT_TYPES_ATTRS_TL.attribute_name%TYPE,
  p_ColumnName IN JTF_ACT_TYPES_ATTRS_B.column_name%TYPE);

-- Test debug procedure
PROCEDURE run;

end jtf_activity_sqlapi;

 

/
