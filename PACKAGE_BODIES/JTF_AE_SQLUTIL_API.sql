--------------------------------------------------------
--  DDL for Package Body JTF_AE_SQLUTIL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AE_SQLUTIL_API" AS
/* $Header: jtfaeapb.pls 120.2 2005/10/25 05:13:26 psanyal ship $ */

-- Register a new profile for a base table
PROCEDURE registerProfile(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_BaseTable IN JTF_PROFILE_MAPPINGS_TL.baseTable%TYPE,
  p_AppID IN JTF_PROFILE_MAPPINGS_B.ownerID%TYPE,
  p_userID IN JTF_PROFILE_MAPPINGS_B.created_by%TYPE) IS

v_pKey NUMBER;

BEGIN

/* Step 1: First insert row in JTF_PROFILE_MAPPINGS_B table */
select jtf_profile_mappings_b_s1.nextVal
into v_pKey
from dual;

JTF_AE_PROFMAPS.INSERT_ROW(
X_PROFILE_MAPPINGS_ID => v_pKey,
X_SECURITY_GROUP_ID   => 0,
X_OWNERID             => p_AppID,
X_OBJECT_VERSION_NUMBER => 0,
X_BASETABLE => p_BaseTable,
X_PROFILENAME => p_ProfileName,
X_CREATION_DATE => sysdate,
X_CREATED_BY => p_userID,
X_LAST_UPDATE_DATE => sysdate,
X_LAST_UPDATED_BY => p_userID,
X_LAST_UPDATE_LOGIN => 0);


END registerProfile;

-- Register primary key
PROCEDURE registerPrimaryKey(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_ProfileProperties_B.last_updated_by%TYPE,
  p_propertyName IN JTF_ProfileProperties_TL.propertyName%TYPE,
  p_attrName IN JTF_ProfileProperties_B.attrName%TYPE,
  p_propDesc IN JTF_ProfileProperties_TL.prop_description%TYPE,
  p_userID IN JTF_ProfileProperties_B.created_by%TYPE ) IS

v_FKey number;
v_PKey number;

Begin

/* Step 1: Get the profile_mappings_id for p_profileName */
v_FKey := getProfileID( p_ProfileName );

/* Step 2: Get the nextVal for the primary key and object version */
select jtf_profileproperties_b_s1.NextVal
into v_Pkey
from dual;

/* Insert into JTF_PROFILEPRPOPERTIES tables */
JTF_AE_PROFPROPS.INSERT_ROW (
X_PROFILEPROPERTIES_ID => v_PKey,
X_PROFILE_MAPPINGS_ID  => v_FKey,
X_ATTRNAME             => p_attrName,
X_OWNER_APPLICATION_ID => p_appID,
X_ISPRIMARYKEY_FLAG_CODE => 'true',
X_OBJECT_VERSION_NUMBER  => 0,
X_SECURITY_GROUP_ID => 0,
X_PROPERTYNAME      => p_propertyName,
X_PROP_DESCRIPTION  => p_propDesc,
X_CREATION_DATE     => sysdate,
X_CREATED_BY => p_userID,
X_LAST_UPDATE_DATE => sysdate,
X_LAST_UPDATED_BY => p_userID,
X_LAST_UPDATE_LOGIN => 0);

End registerPrimaryKey;

-- Register Object_Version_Number

PROCEDURE registerObjectVersion(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_ProfileProperties_B.last_updated_by%TYPE,
  p_attrName IN JTF_ProfileProperties_B.attrName%TYPE,
  p_propDesc IN JTF_ProfileProperties_TL.prop_description%TYPE,
  p_userID IN JTF_ProfileProperties_B.created_by%TYPE ) IS

v_FKey number;
v_PKey number;
v_propertyName JTF_ProfileProperties_TL.propertyName%TYPE;

Begin

/* Step 1: Get the profile_mappings_id for p_profileName */
v_FKey := getProfileID( p_ProfileName );

v_propertyName := 'OBJECT_VERSION_NUMBER';

/* Step 2: Get the nextVal for the primary key and object version */
select jtf_profileproperties_b_s1.NextVal
into v_Pkey
from dual;

/* Insert into JTF_PROFILEPRPOPERTIES tables */
JTF_AE_PROFPROPS.INSERT_ROW (
X_PROFILEPROPERTIES_ID => v_PKey,
X_PROFILE_MAPPINGS_ID  => v_FKey,
X_ATTRNAME             => p_attrName,
X_OWNER_APPLICATION_ID => p_appID,
X_ISPRIMARYKEY_FLAG_CODE => 'true',
X_OBJECT_VERSION_NUMBER  => 0,
X_SECURITY_GROUP_ID => 0,
X_PROPERTYNAME      => v_propertyName,
X_PROP_DESCRIPTION  => p_propDesc,
X_CREATION_DATE     => sysdate,
X_CREATED_BY => p_userID,
X_LAST_UPDATE_DATE => sysdate,
X_LAST_UPDATED_BY => p_userID,
X_LAST_UPDATE_LOGIN => 0);

End registerObjectVersion;



-- Insert a new Profile Owner object into JTF_ProfileProperties_B/TL
-- Return the primary key for the newly inserted object.
PROCEDURE addAttribute (
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_ProfileProperties_B.last_updated_by%TYPE,
  p_OwnerID  IN JTF_ProfileProperties_B.owner_application_id%TYPE,
  p_propertyName IN JTF_ProfileProperties_TL.propertyName%TYPE,
  p_propDesc IN JTF_ProfileProperties_TL.prop_description%TYPE,
  p_isBase IN NUMBER,
  p_userID IN JTF_ProfileProperties_B.created_by%TYPE,
  p_PK OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_OID OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_ATTR OUT NOCOPY /* file.sql.39 change */ JTF_ProfileProperties_B.attrname%TYPE) IS

v_FKey NUMBER;
BEGIN

/* Step 1: Get the profile_mappings_id for p_profileName */
v_FKey := getProfileID( p_ProfileName );

/* Step 2: Determine the attrName for new property */
p_ATTR := getAttrName( v_FKey, p_appID, p_isBase );

/* Step 3: Get the nextVal for the primary key and object version */
select jtf_profileproperties_b_s1.NextVal
into p_PK
from dual;

p_OID := 0;

/* Insert into JTF_PROFILEPRPOPERTIES tables */
JTF_AE_PROFPROPS.INSERT_ROW (
X_PROFILEPROPERTIES_ID => p_pK,
X_PROFILE_MAPPINGS_ID  => v_FKey,
X_ATTRNAME             => p_ATTR,
X_OWNER_APPLICATION_ID => p_OwnerID,
X_ISPRIMARYKEY_FLAG_CODE => 'false',
X_OBJECT_VERSION_NUMBER  => p_OID,
X_SECURITY_GROUP_ID => 0,
X_PROPERTYNAME      => p_propertyName,
X_PROP_DESCRIPTION  => p_propDesc,
X_CREATION_DATE     => sysdate,
X_CREATED_BY => p_userID,
X_LAST_UPDATE_DATE => sysdate,
X_LAST_UPDATED_BY => p_userID,
X_LAST_UPDATE_LOGIN => 0);

END addAttribute;

-- Insert a new ProfilePropertyDescriptor into JTF_Profile_Metadata_B/TL
-- Return the primary key for the newly inserted object.
PROCEDURE addAttribute (
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_Profile_Metadata_B.last_updated_by%TYPE,
  p_PropertyName IN JTF_ProfileProperties_TL.propertyName%TYPE,
  p_pID IN JTF_Profile_Metadata_B.profileproperties_ID%TYPE,
  p_rID IN JTF_Profile_Metadata_B.profile_rules_ID%TYPE,
  p_disabledCode IN JTF_Profile_Metadata_B.disabled_flag_code%TYPE,
  p_mandatoryCode IN JTF_Profile_Metadata_B.mandatory_flag_code%TYPE,
  p_javaTypeCode IN JTF_Profile_Metadata_B.java_datatype_code%TYPE,
  p_default IN JTF_Profile_Metadata_TL.default_value%TYPE,
  p_userID IN JTF_Profile_Metadata_B.created_by%TYPE,
  p_PK OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_OID OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_SPID OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

v_pMapID NUMBER;
v_pPID NUMBER;

BEGIN

/* Step 1: Get the profile_mappings_id  subscribed_profile_id */
getAppProfileID( p_ProfileName, p_appID, v_pMapID, p_SPID );

/* Step 2: If p_pID is null or -1 then determine it */
if p_PID = NULL OR p_PID = -1 then
 select profileproperties_id
 into v_pPID
 from jtf_profileproperties_tl t
 where t.propertyname = p_PropertyName AND t.language = userenv('LANG');
else
 v_pPID := p_PID;
end if;

/* Step 3: Get the nextVal for the primary key */
select jtf_profile_metadata_b_s1.NextVal
into p_PK
from dual;

p_OID := 0;

/* Insert into JTF_PROFILE_METADATA tables */
JTF_AE_METADATA.INSERT_ROW (
X_PROFILE_METADATA_ID => p_PK,
X_SECURITY_GROUP_ID   => 0,
X_SUBSCRIBED_PROFILES_ID => p_SPID,
X_PROFILEPROPERTIES_ID   => v_pPID,
X_PROFILE_RULES_ID       => p_rID,
X_DISABLED_FLAG_CODE     => p_disabledCode,
X_MANDATORY_FLAG_CODE    => p_mandatoryCode,
X_JAVA_DATATYPE_CODE     => p_javaTypeCode,
X_OBJECT_VERSION_NUMBER  => p_OID,
X_DEFAULT_VALUE          => p_default,
X_SQL_VALIDATION         => null,
X_CREATION_DATE     => sysdate,
X_CREATED_BY => p_userID,
X_LAST_UPDATE_DATE => sysdate,
X_LAST_UPDATED_BY => p_userID,
X_LAST_UPDATE_LOGIN => 0);

END addAttribute;

-- Add an instance specific attribute. If the rule associated
-- with the attribute is not registered yet, first register the rule.

PROCEDURE addAttribute (
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_Profile_Metadata_B.last_updated_by%TYPE,
  p_disabledCode IN JTF_Profile_Metadata_B.disabled_flag_code%TYPE,
  p_mandatoryCode IN JTF_Profile_Metadata_B.mandatory_flag_code%TYPE,
  p_javaTypeCode IN JTF_Profile_Metadata_B.java_datatype_code%TYPE,
  p_default IN JTF_Profile_Metadata_TL.default_value%TYPE,
  p_extPropertyName IN JTF_PROFILEPROPERTIES_TL.propertyName%TYPE,
  p_basePropertyName IN JTF_PROFILEPROPERTIES_TL.propertyName%TYPE,
  p_basePropertyVal IN JTF_PROFILE_RULES_TL.base_property_value%TYPE,
  p_rule IN JTF_Profile_Rules_B.rule%TYPE,
  p_userID IN JTF_Profile_Rules_B.created_by%TYPE,
  p_PK OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_OID OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_SPID OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

v_pMapID NUMBER;
v_ruleID NUMBER;
v_PK NUMBER;
v_OID NUMBER;
v_attr JTF_ProfileProperties_B.attrname%TYPE;

BEGIN

/* Check to see if the rule is registered */
addRule( p_ProfileName, p_appID, p_basePropertyName,
                    p_basePropertyVal, p_rule, p_userID, v_ruleID);

/* Add this new instance specific property to profileproperties */
addAttribute(p_ProfileName, p_appID, p_appID, p_extPropertyName,
             'Instance specific property', 1, p_userID, v_PK, v_OID, v_attr);

/* Add the new attribute's app specific metadata */
addAttribute( p_ProfileName, p_appID, p_extPropertyName,
              v_PK, v_ruleID, p_disabledCode,
              p_mandatoryCode, p_javaTypeCode, p_default, p_userID,
              p_PK, p_OID, p_SPID );


END addAttribute;

-- Modify an existing base or instance specific attribute
PROCEDURE modifyAttribute (
  p_appID IN JTF_Profile_Metadata_B.last_updated_by%TYPE,
  p_Key IN JTF_Profile_Metadata_B.profile_metadata_id%TYPE,
  p_disabledCode IN JTF_Profile_Metadata_B.disabled_flag_code%TYPE,
  p_mandatoryCode IN JTF_Profile_Metadata_B.mandatory_flag_code%TYPE,
  p_javaTypeCode IN JTF_Profile_Metadata_B.java_datatype_code%TYPE,
  p_default IN JTF_Profile_Metadata_TL.default_value%TYPE,
  p_version IN JTF_Profile_Metadata_B.object_version_number%TYPE,
  p_userID IN JTF_Profile_Metadata_B.created_by%TYPE,
  p_Count OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

BEGIN

/* Modify the _B table first */

UPDATE JTF_PROFILE_METADATA_B
SET disabled_flag_code = p_disabledCode,
    mandatory_flag_code = p_mandatoryCode,
    java_datatype_code = p_javaTypeCode,
    last_update_date = SYSDATE,
    last_updated_by = p_userID,
    object_version_number = p_version + 1
WHERE profile_metadata_id = p_Key AND object_version_number = p_version;

/* Check if update successful? */
p_Count := SQL%ROWCOUNT;

if p_Count = 0 then
  return;
end if;

/* Update successful, so modify _TL table */
UPDATE JTF_PROFILE_METADATA_TL
SET default_value = p_default,
    last_update_date = SYSDATE,
    last_updated_by = p_userID
WHERE profile_metadata_id = p_Key;

END modifyAttribute;


-- If new rule then add rule for instance specific attribute
-- Return the PROFILE_RULE_ID of the newly registered rule.
PROCEDURE addRule(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_PROFILE_RULES_B.last_updated_by%TYPE,
  p_propertyName IN JTF_ProfileProperties_TL.propertyName%TYPE,
  p_baseValue IN JTF_PROFILE_RULES_TL.base_property_value%TYPE,
  p_rule IN JTF_Profile_Rules_B.rule%TYPE,
  p_userID IN JTF_Profile_Rules_B.created_by%TYPE,
  p_ruleID OUT NOCOPY /* file.sql.39 change */ JTF_Profile_Rules_B.profile_rules_id%TYPE) IS

v_Result NUMBER;
v_pMapID NUMBER;
v_pSubProfID NUMBER;
v_pMetaID NUMBER;

CURSOR c_Rules IS
  SELECT b.profile_rules_id
  FROM JTF_Profile_Rules_B b, JTF_Profile_Rules_TL t
  WHERE b.profile_metadata_id = v_pMetaID AND
        b.profile_rules_id = t.profile_rules_id and
        t.base_property_value = p_baseValue and t.language = userenv('LANG');

BEGIN

/* Step 1: Get the profile_mappings_id and subscribed_profile_id */
getAppProfileID( p_ProfileName, p_appID, v_pMapID, v_pSubProfID );

/* Step 2: Determine the profile_metadata_id */
SELECT a.profile_metadata_id
INTO v_pMetaID
FROM JTF_Profile_Metadata_B a, JTF_ProfileProperties_B b,
     JTF_ProfileProperties_TL t
WHERE a.subscribed_profiles_id = v_pSubProfID
      AND a.profileproperties_id = b.profileproperties_id
      AND b.profile_mappings_id = v_pMapID
      AND b.profileproperties_id = t.profileproperties_id
      AND t.propertyName = p_propertyName AND t.language = userenv('LANG');

/* Step 3: Check to see if the rule is already registered */
OPEN c_Rules;

FETCH c_Rules INTO v_Result;

if c_Rules%FOUND THEN
  CLOSE c_Rules;
  p_ruleID := v_Result;

  RETURN;
end if;

CLOSE c_Rules;

/* Step 4: Rule NOT Registered .. Add the new rule */
select jtf_profile_rules_b_s1.NextVal
into v_Result
from dual;

      JTF_AE_PROFRULES.INSERT_ROW (
        X_PROFILE_RULES_ID       => v_Result,
        X_SECURITY_GROUP_ID      => 0,
        X_PROFILE_METADATA_ID    => v_pMetaID,
        X_RULE                   => p_rule,
        X_OBJECT_VERSION_NUMBER  => 0,
        X_BASE_PROPERTY_VALUE    => p_baseValue,
        X_CREATION_DATE          => sysdate,
        X_CREATED_BY             => p_userID,
        X_LAST_UPDATE_DATE       => sysdate,
        X_LAST_UPDATED_BY        => p_userID,
        X_LAST_UPDATE_LOGIN      => 0
      );

/* Return the result */
p_ruleID := v_Result;

END addRule;


-- HELPER FUNCTIONS

FUNCTION getProfileID(
 p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE)
 RETURN NUMBER IS

v_Result NUMBER;

BEGIN

SELECT profile_mappings_id
INTO v_Result
FROM JTF_PROFILE_MAPPINGS_TL t
WHERE t.profileName = p_profileName AND
      t.language = userenv('LANG');

RETURN v_Result;

END getProfileID;

FUNCTION getAttrName (
  p_profile_mappings_id IN NUMBER,
  p_appID IN NUMBER,
  p_isBase in NUMBER )
  RETURN VARCHAR2 IS

v_Result JTF_ProfileProperties_B.attrname%TYPE;
v_tmp1 JTF_ProfileProperties_B.attrname%TYPE;
v_tmp2 JTF_ProfileProperties_B.attrname%TYPE;
v_index NUMBER;

BEGIN

if p_isBase = 0 THEN
 v_tmp1 := 'ATTR_';
 v_tmp2 := 'ATTR_%';
else
 v_tmp1 := 'EXT_';
 v_tmp2 := 'EXT_%';

END IF;

SELECT MAX(TO_NUMBER(LTRIM(ATTRNAME,v_tmp1)))
INTO v_index
FROM JTF_ProfileProperties_B
WHERE profile_mappings_id = p_profile_mappings_id
AND attrname LIKE v_tmp2;

if v_index >= 0 then
  v_index := v_index + 1;
else
  v_index := 0;
END IF;

v_Result := v_tmp1 || v_index;

return v_Result;

END getAttrName;

PROCEDURE getAppProfileID(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_SUBSCRIBED_PROFILES.application_id%TYPE,
  p_PMAPID OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_SUBID OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

BEGIN

SELECT s.profile_mappings_id,s.subscribed_profiles_id
INTO p_PMAPID, p_SUBID
FROM JTF_SUBSCRIBED_PROFILES s, JTF_PROFILE_MAPPINGS_TL t
WHERE s.application_id = p_appID
AND s.profile_mappings_id = t.profile_mappings_id
AND t.profileName = p_ProfileName AND t.language = userenv('LANG');

END getAppProfileID;

procedure run is
v_PK NUMBER;
v_OID NUMBER;
v_ATTR VARCHAR2(50);

begin

addAttribute('AR_USERPROFILE', 222, 'false', 'false', 'String', null, 'EXT_testAttribute0__0', 'testAttribute0', 'falluda', 'AR_USERPROFILE::222::testAttribute0::falluda', 1,v_PK, v_OID, v_ATTR);

/* Simply call addAttribute with dummy input
addAttribute('foo', 2, 2, 'fooo', 'dummy property', 0, 1,v_PK, v_OID, v_ATTR);
*/

/*
DBMS_OUTPUT.ENABLE(1000000);

DBMS_OUTPUT.PUT_LINE('Value of primary key is: ' || v_PK);
DBMS_OUTPUT.PUT_LINE('Value of object version number is: ' || v_OID);
DBMS_OUTPUT.PUT_LINE('Value of attr name is: ' || v_ATTR);
*/

end run;

END JTF_AE_SQLUtil_API;

/
