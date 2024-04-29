--------------------------------------------------------
--  DDL for Package Body JTF_ACTIVITY_SQLAPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ACTIVITY_SQLAPI" AS
/* $Header: jtfactsb.pls 120.2 2005/10/25 05:12:40 psanyal ship $ */


FUNCTION getActivityNameID(
 ActivityName IN JTF_ACT_TYPES_TL.activity_name%TYPE)
 RETURN NUMBER IS

v_Result NUMBER;

BEGIN

SELECT activity_name_id
INTO v_Result
FROM JTF_ACT_TYPES_TL
WHERE activity_name = ActivityName AND
      language = userenv('LANG');
RETURN v_Result;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
  RETURN 0;
 WHEN OTHERS THEN
  RETURN 0;

END getActivityNameID;

FUNCTION getActivityAttributeNameID(
 ActivityName IN JTF_ACT_TYPES_TL.activity_name%TYPE,
 AttributeName IN JTF_ACT_TYPES_ATTRS_TL.attribute_name%TYPE)
 RETURN NUMBER IS

v_Result NUMBER;
v_activity_name_id NUMBER;
BEGIN

v_activity_name_id := getActivityNameID(ActivityName);

SELECT b.attribute_name_id INTO v_Result
FROM JTF_ACT_TYPES_ATTRS_B b, JTF_ACT_TYPES_ATTRS_TL t
WHERE b.activity_name_id = v_activity_name_id
AND b.attribute_name_id = t.attribute_name_id
AND t.attribute_name = AttributeName
AND t.language = userenv('LANG');

RETURN v_Result;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN -1;
  WHEN OTHERS  THEN
    RETURN  -1;

END getActivityAttributeNameID;

FUNCTION isActivityDefined(
  ActivityName IN jtf_act_types_tl.activity_name%TYPE)
RETURN NUMBER IS

v_row NUMBER;
BEGIN

v_row := getActivityNameID(ActivityName);
if (v_row <0) then
return 0;
else
return v_row;
end if;
END isActivityDefined;


-- delete a row in jtf_activity_type_b table;

procedure deleteActivityType(activityname IN varchar2) AS
name_id  NUMBER;
i        binary_integer;

Cursor C is
   select t.activity_name_id from jtf_act_types_tl t where t.language=userenv('LANG') and t.activity_name =activityname;
begin

  open C;

  loop
   fetch C into name_id;
   Exit when C%NOTFOUND;
   delete from jtf_act_types_tl where activity_name_id = name_id;
   delete from jtf_act_types_b where activity_name_id = name_id;
   end loop;

   close c;
end deleteActivityType;

procedure subscribeActivityType(AppID IN number, CategoryName IN varchar2, ActivityName IN varchar2)
AS
v_activityname_id NUMBER;
v_act_app_cats_id NUMBER;
v_act_types_b_id NUMBER;
begin
   -- get the jtf_act_app_cats_id from jtf_act_app_cats_id table
  select jtf_act_app_cats_id into v_act_app_cats_id from jtf_act_app_cats
  	where application_id = AppID and category_name_code=CategoryName;

   -- get the activity name id
  v_activityname_id := getActivityNameID(ActivityName);

  select jtf_act_types_b_id into v_act_types_b_id from jtf_act_types_b
	where activity_name_id = v_activityname_id;

  insert into jtf_act_activity_cats
	(jtf_act_types_b_id, jtf_act_app_cats_id, priority, status_code,
	 created_by, creation_date, last_updated_by, last_update_date)
   values (v_act_types_b_id, v_act_app_cats_id, 1, 'ON',
	        AppID, sysdate, AppID, sysdate);

    end subscribeActivityType;

procedure unsubscribeActivityType(AppID IN NUMBER, CategoryName IN varchar2, ActivityName IN varchar2)
AS
v_activityname_id NUMBER;
v_act_app_cats_id NUMBER;
v_act_types_b_id NUMBER;
begin

   -- get the jtf_act_app_cats_id from jtf_act_app_cats_id table
  select jtf_act_app_cats_id into v_act_app_cats_id from jtf_act_app_cats
	where application_id = AppID and category_name_code=CategoryName;

   -- get the activity name id
  v_activityname_id := getActivityNameID(ActivityName);

  select jtf_act_types_b_id into v_act_types_b_id from jtf_act_types_b
	where activity_name_id = v_activityname_id;

  delete from jtf_act_activity_cats
	where jtf_act_app_cats_id = v_act_app_cats_id and
              jtf_act_types_b_id = v_act_types_b_id;
end unsubscribeActivityType;

procedure setActivityPriority(appID IN NUMBER, categoryname IN varchar2, activityname IN varchar2, Priority IN NUMBER)
AS

v_activityname_id NUMBER;
v_act_app_cats_id NUMBER;
v_act_types_b_id NUMBER;
begin
  -- get the jtf_act_app_cats_id from jtf_act_app_cats_id table
  select jtf_act_app_cats_id into v_act_app_cats_id from jtf_act_app_cats
	 where application_id = AppID and category_name_code=CategoryName;
  -- get the activity name id
  v_activityname_id := getActivityNameID(ActivityName);
  select jtf_act_types_b_id into v_act_types_b_id from jtf_act_types_b
	  where activity_name_id = v_activityname_id;

  update jtf_act_activity_cats set priority = Priority
	  where jtf_act_app_cats_id = v_act_app_cats_id and
              jtf_act_types_b_id = v_act_types_b_id;
end setActivityPriority;

procedure setActivityStatus(appID IN NUMBER, categoryname IN varchar2, activityname IN varchar2, Status IN varchar2)
AS

v_activityname_id NUMBER;
v_act_app_cats_id NUMBER;
v_act_types_b_id NUMBER;
begin
  -- get the jtf_act_app_cats_id from jtf_act_app_cats_id table
 select jtf_act_app_cats_id into v_act_app_cats_id from jtf_act_app_cats
	where application_id = AppID and category_name_code=CategoryName;

  -- get the activity name id
   v_activityname_id := getActivityNameID(ActivityName);
 select jtf_act_types_b_id into v_act_types_b_id from jtf_act_types_b
	where activity_name_id = v_activityname_id;

 update jtf_act_activity_cats set status_code = Status
  	where jtf_act_app_cats_id = v_act_app_cats_id and
              jtf_act_types_b_id = v_act_types_b_id;

end setActivityStatus;


-- These APIs help insert rows in _B and _T tables

PROCEDURE addActivityType (
  p_ActivityName IN JTF_ACT_TYPES_TL.activity_name%TYPE,
  p_appID IN JTF_ACT_TYPES_TL.last_updated_by%TYPE,
  p_tableName IN JTF_ACT_TYPES_B.table_name%TYPE,
  p_Desc IN JTF_ACT_TYPES_TL.description%TYPE,
  p_PK OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_NameID OUT NOCOPY /* file.sql.39 change */ JTF_ACT_TYPES_B.activity_name_id%TYPE)
AS
v_FKey NUMBER;
v_row NUMBER;
begin
 -- first check whether the activity name is already defined
IF (isActivityDefined(p_ActivityName) = 0 ) THEN

 -- First do an insert into JTF_ACT_TYPES_B table
 -- activity_name_id is the same as primary key
INSERT INTO JTF_ACT_TYPES_B
 ( table_name, created_by, creation_date, last_updated_by, last_update_date)
  VALUES (p_tableName, p_appID, SYSDATE, p_appID, SYSDATE);

select jtf_act_types_b_s.currval into p_PK from dual;

 -- Finally insert the translatable columns into JTF_ProfileProperties_TL
INSERT INTO JTF_ACT_TYPES_TL
( activity_name_id, activity_name, act_description,  language,
  created_by, creation_date, last_updated_by, last_update_date)
VALUES (p_PK, p_ActivityName, p_Desc, userenv('LANG'),
        p_appID, SYSDATE, p_appID, SYSDATE);
p_NameID := p_PK;
END IF;

END addActivityType;

PROCEDURE addActivityAttribute (
  p_ActivityName IN JTF_ACT_TYPES_TL.activity_name%TYPE,
  p_appID IN JTF_ACT_TYPES_TL.last_updated_by%TYPE,
  p_AttributeName IN JTF_ACT_TYPES_ATTRS_TL.attribute_name%TYPE,
  p_ColumnName IN JTF_ACT_TYPES_ATTRS_B.column_name%TYPE)
AS
v_activity_name_id NUMBER;
v_attribute_name_id NUMBER;
begin

 -- first check whether the activity name is already defined
IF (isActivityDefined(p_ActivityName) > 0 ) THEN

 v_activity_name_id := getActivityNameID(p_ActivityName);
 -- First do an insert into JTF_ACT_TYPES_ATTRS_B table
 -- activity_name_id is the same as primary key
INSERT INTO JTF_ACT_TYPES_ATTRS_B
 ( activity_name_id, column_name, created_by, creation_date, last_updated_by, last_update_date)
  VALUES (v_activity_name_id, p_ColumnName, p_appID, SYSDATE, p_appID, SYSDATE);

SELECT  attribute_name_id INTO  v_attribute_name_id
FROM jtf_act_types_attrs_b
WHERE activity_name_id = v_activity_name_id
     and column_name = p_ColumnName;

 -- Finally insert the translatable columns into JTF_ProfileProperties_TL
INSERT INTO JTF_ACT_TYPES_ATTRS_TL
( attribute_name_id, attribute_name, language,
  created_by, creation_date, last_updated_by, last_update_date)
VALUES (v_attribute_name_id, p_AttributeName, userenv('LANG'),
        p_appID, SYSDATE, p_appID, SYSDATE);
END IF;

END addActivityAttribute;



procedure run is
v_PK NUMBER;
v_NameID NUMBER;
v_AttrID NUMBER;
v_ATTR VARCHAR2(50);
begin
-- Simply call addAttribute with dummy input
--v_PK := isActivityDefined('foo');
v_PK := getActivityNameID('Customer_DisputeBill2');
--addActivityType('foo', 10, 'foo','this is a sample activity type', v_PK, v_NameID);
--addActivityAttribute('Customer_DisputeBill', 10, 'billid', 'column1');
--deleteActivityType('foo3' );
unsubscribeActivityType(690, 'Bill Management', 'Customer_DisputeBill2');
--DBMS_OUTPUT.ENABLE(1000000);
--DBMS_OUTPUT.PUT_LINE('This is the output' );
--DBMS_OUTPUT.PUT_LINE('Value of primary key is: ' || v_PK);
--DBMS_OUTPUT.PUT_LINE('Value of name id  is: ' || v_NameID);
end run;

end jtf_activity_sqlapi;

/
