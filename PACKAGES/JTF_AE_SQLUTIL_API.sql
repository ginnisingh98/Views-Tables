--------------------------------------------------------
--  DDL for Package JTF_AE_SQLUTIL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AE_SQLUTIL_API" AUTHID CURRENT_USER AS
/* $Header: jtfaeaps.pls 120.2 2005/10/25 05:13:50 psanyal ship $ */

-- Register a new profile for a base table
PROCEDURE registerProfile(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_BaseTable IN JTF_PROFILE_MAPPINGS_TL.baseTable%TYPE,
  p_AppID IN JTF_PROFILE_MAPPINGS_B.ownerID%TYPE,
  p_userID IN JTF_PROFILE_MAPPINGS_B.created_by%TYPE);

-- Register primary key
PROCEDURE registerPrimaryKey(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_ProfileProperties_B.last_updated_by%TYPE,
  p_propertyName IN JTF_ProfileProperties_TL.propertyName%TYPE,
  p_attrName IN JTF_ProfileProperties_B.attrName%TYPE,
  p_propDesc IN JTF_ProfileProperties_TL.prop_description%TYPE,
  p_userID IN JTF_ProfileProperties_B.created_by%TYPE );

-- Register Object Version
PROCEDURE registerObjectVersion(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_ProfileProperties_B.last_updated_by%TYPE,
  p_attrName IN JTF_ProfileProperties_B.attrName%TYPE,
  p_propDesc IN JTF_ProfileProperties_TL.prop_description%TYPE,
  p_userID IN JTF_ProfileProperties_B.created_by%TYPE );

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
  p_ATTR OUT NOCOPY /* file.sql.39 change */ JTF_ProfileProperties_B.attrname%TYPE);

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
  p_SPID OUT NOCOPY /* file.sql.39 change */ NUMBER);

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
  p_SPID OUT NOCOPY /* file.sql.39 change */ NUMBER);

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
  p_Count OUT NOCOPY /* file.sql.39 change */ NUMBER);

-- Add a new rule for instance specific attributes to JTF_PROFILE_RULES_B/TL
-- Return the PROFILE_RULE_ID generated.
PROCEDURE addRule(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_PROFILE_RULES_B.last_updated_by%TYPE,
  p_propertyName IN JTF_ProfileProperties_TL.propertyName%TYPE,
  p_baseValue IN JTF_PROFILE_RULES_TL.base_property_value%TYPE,
  p_rule IN JTF_Profile_Rules_B.rule%TYPE,
  p_userID IN JTF_Profile_Rules_B.created_by%TYPE,
  p_ruleID OUT NOCOPY /* file.sql.39 change */ JTF_PROFILE_Rules_B.profile_rules_id%TYPE);


-- HELPER FUNCTIONS
FUNCTION getProfileID(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE)
 RETURN NUMBER;

FUNCTION getAttrName (
  p_profile_mappings_id IN NUMBER,
  p_appID IN NUMBER,
  p_isBase IN NUMBER )
  RETURN VARCHAR2;

PROCEDURE getAppProfileID(
  p_ProfileName IN JTF_PROFILE_MAPPINGS_TL.profileName%TYPE,
  p_appID IN JTF_SUBSCRIBED_PROFILES.application_id%TYPE,
  p_PMAPID OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_SUBID OUT NOCOPY /* file.sql.39 change */ NUMBER);

-- Test debug procedure
PROCEDURE run;


END JTF_AE_SQLUtil_API;

 

/
