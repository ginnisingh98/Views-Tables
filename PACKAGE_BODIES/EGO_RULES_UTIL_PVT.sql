--------------------------------------------------------
--  DDL for Package Body EGO_RULES_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_RULES_UTIL_PVT" AS
/* $Header: EGOVRUTB.pls 120.3 2007/06/05 19:36:07 glomeli noship $ */
FUNCTION Get_Comma_Separated_Bussentity(X_STR_ID NUMBER) RETURN VARCHAR2 IS
	l_result VARCHAR2(2500);
	CURSOR l_cur_entries IS
	(
	SELECT e1.USER_DATA_LEVEL_NAME
	FROM ego_data_level_vl e1, EGO_INCLUDED_BUSINESSENTITIES e2
	WHERE e1.attr_group_type = 'EGO_ITEMMGMT_GROUP'
	AND  e1.enable_defaulting < > 'N'
	AND e1.DATA_LEVEL_NAME= e2.BUSINESS_ENTITY
	AND e2.RULESET_ID=X_STR_ID
	);
	 l_cur_var l_cur_entries%ROWTYPE;
	 BEGIN
	 OPEN l_cur_entries;
	 LOOP
		 FETCH l_cur_entries INTO l_cur_var;
		 EXIT WHEN l_cur_entries%NOTFOUND;
	  	IF l_result is null THEN
	  		l_result:=l_cur_var.USER_DATA_LEVEL_NAME;
		  ELSE
		  l_result:=l_result||', '||l_cur_var.USER_DATA_LEVEL_NAME;
		END IF;
	END LOOP;
	CLOSE l_cur_entries;
	 RETURN l_result;
END Get_Comma_Separated_Bussentity ;

FUNCTION Get_Icc(X_ICC_ID NUMBER) RETURN VARCHAR2
IS
l_result VARCHAR2(2500);
BEGIN
	IF X_ICC_ID is not null THEN
		SELECT  catalog_group INTO l_result  FROM ego_catalog_groups_v WHERE catalog_group_id = X_ICC_ID;
	END IF;
	RETURN l_result;
END Get_Icc;

FUNCTION Get_Comma_Separated_Rulegroups(X_STR_RULEID NUMBER) RETURN VARCHAR2 IS l_result VARCHAR2(2500);
CURSOR l_cur_entries IS
  (SELECT unique
    attr_group_name
  FROM
    ego_rule_attribute_usages
  WHERE
    rule_id = X_STR_RULEID);
l_cur_var l_cur_entries%ROWTYPE;
BEGIN

  OPEN l_cur_entries;
  LOOP
    FETCH l_cur_entries
    INTO l_cur_var;
    EXIT
  WHEN l_cur_entries%NOTFOUND;

  IF l_result IS NULL THEN
    l_result := l_cur_var.attr_group_name;
  ELSE
    l_result := l_result || ', ' || l_cur_var.attr_group_name;
  END IF;

END LOOP;

CLOSE l_cur_entries;
RETURN l_result;
END Get_Comma_Separated_Rulegroups;

 FUNCTION Get_Comma_Separated_Ruleattrs(X_STR_RULEID NUMBER) RETURN VARCHAR2 IS l_result VARCHAR2(2500);
CURSOR l_cur_entries IS
  (SELECT unique
    attribute
  FROM
    ego_rule_attribute_usages
  WHERE
    rule_id = X_STR_RULEID);
l_cur_var l_cur_entries%ROWTYPE;
BEGIN

  OPEN l_cur_entries;
  LOOP
    FETCH l_cur_entries
    INTO l_cur_var;
    EXIT WHEN l_cur_entries%NOTFOUND;

  IF l_result IS NULL THEN
    l_result := l_cur_var.attribute;
  ELSE
    l_result := l_result || ', ' || l_cur_var.attribute;
  END IF;

END LOOP;

CLOSE l_cur_entries;
RETURN l_result;
END Get_Comma_Separated_Ruleattrs;

FUNCTION Get_AttributeGroupsForRuleSet(X_STR_RULESETID NUMBER) RETURN VARCHAR2 IS l_result VARCHAR2(2500);
CURSOR l_cur_entries IS
  (SELECT unique
    attr_group_name Assignedtoattrgrp
  FROM
    ego_rule_attribute_usages
  WHERE
    rule_id IN (SELECT RULE_ID FROM EGO_USER_RULES_B WHERE RULESET_ID = X_STR_RULESETID));
l_cur_var l_cur_entries%ROWTYPE;
BEGIN

  OPEN l_cur_entries;
  LOOP
    FETCH l_cur_entries
    INTO l_cur_var;
    EXIT
  WHEN l_cur_entries%NOTFOUND;

  IF l_result IS NULL THEN
    l_result := l_cur_var.Assignedtoattrgrp;
  ELSE
    l_result := l_result || ', ' || l_cur_var.Assignedtoattrgrp;
  END IF;

END LOOP;

CLOSE l_cur_entries;
RETURN l_result;
END Get_AttributeGroupsForRuleSet;


FUNCTION Get_AttributeForRuleSet(X_STR_RULESETID NUMBER) RETURN VARCHAR2 IS l_result VARCHAR2(2500);
CURSOR l_cur_entries IS
  (SELECT unique
    ATTRIBUTE
  FROM
    ego_rule_attribute_usages
  WHERE
    rule_id IN (SELECT RULE_ID FROM EGO_USER_RULES_B WHERE RULESET_ID = X_STR_RULESETID));
l_cur_var l_cur_entries%ROWTYPE;
BEGIN

  OPEN l_cur_entries;
  LOOP
    FETCH l_cur_entries
    INTO l_cur_var;
    EXIT
  WHEN l_cur_entries%NOTFOUND;

  IF l_result IS NULL THEN
    l_result := l_cur_var.ATTRIBUTE;
  ELSE
    l_result := l_result || ', ' || l_cur_var.ATTRIBUTE;
  END IF;

END LOOP;

CLOSE l_cur_entries;
RETURN l_result;
END Get_AttributeForRuleSet;

FUNCTION Get_AssignedBusinessEnitites(X_STR_RULESETID NUMBER) RETURN VARCHAR2 IS l_result VARCHAR2(2500);
CURSOR l_cur_entries IS
  (
	SELECT
		e1.USER_DATA_LEVEL_NAME as Assignedtobusentity
	FROM
		ego_data_level_vl e1,
		EGO_RULE_ASSIGNMENTS e2
	WHERE
		e1.attr_group_type = 'EGO_ITEMMGMT_GROUP'
	AND
		e1.enable_defaulting < > 'N'
	AND
		e1.DATA_LEVEL_NAME= e2.BUSINESS_ENTITY
	AND
		e2.RULESET_ID = X_STR_RULESETID
	);
l_cur_var l_cur_entries%ROWTYPE;
BEGIN

  OPEN l_cur_entries;
  LOOP
    FETCH l_cur_entries
    INTO l_cur_var;
    EXIT
  WHEN l_cur_entries%NOTFOUND;

  IF l_result IS NULL THEN
    l_result := l_cur_var.Assignedtobusentity;
  ELSE
    l_result := l_result || ', ' || l_cur_var.Assignedtobusentity;
  END IF;

END LOOP;

CLOSE l_cur_entries;
RETURN l_result;
END Get_AssignedBusinessEnitites;

FUNCTION Get_BussentityForRulesets(X_STR_RULESETID NUMBER) RETURN VARCHAR2 IS
	l_result VARCHAR2(2500);
	CURSOR l_cur_entries IS
	(
		SELECT
			e1.USER_DATA_LEVEL_NAME as usingbusentity
		FROM
			ego_data_level_vl e1,
			EGO_INCLUDED_BUSINESSENTITIES e2
		WHERE
			e1.attr_group_type = 'EGO_ITEMMGMT_GROUP'
		AND
			e1.enable_defaulting < > 'N'
		AND
			e1.DATA_LEVEL_NAME = e2.BUSINESS_ENTITY
		AND
			e2.RULESET_ID = X_STR_RULESETID
	);
	 l_cur_var l_cur_entries%ROWTYPE;
	 BEGIN
	 OPEN l_cur_entries;
	 LOOP
		 FETCH l_cur_entries INTO l_cur_var;
		 EXIT WHEN l_cur_entries%NOTFOUND;
	  	IF l_result is null THEN
	  		l_result:=l_cur_var.usingbusentity;
		  ELSE
		  l_result:=l_result||', '||l_cur_var.usingbusentity;
		END IF;
	END LOOP;
	CLOSE l_cur_entries;
	 RETURN l_result;
END Get_BussentityForRulesets ;


END Ego_Rules_Util_PVT;

/
