--------------------------------------------------------
--  DDL for Package EGO_RULES_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_RULES_UTIL_PVT" AUTHID CURRENT_USER AS
 /* $Header: EGOVRUTS.pls 120.1 2007/04/21 11:24:42 ranigam noship $ */
 FUNCTION  Get_Comma_Separated_Bussentity(X_STR_ID Number) RETURN VARCHAR2;
 FUNCTION Get_Icc(X_ICC_ID NUMBER) RETURN VARCHAR2;
 FUNCTION Get_Comma_Separated_Rulegroups(X_STR_RULEID NUMBER) RETURN VARCHAR2;
 FUNCTION Get_Comma_Separated_Ruleattrs(X_STR_RULEID NUMBER)  RETURN VARCHAR2;
 FUNCTION Get_AttributeGroupsForRuleSet(X_STR_RULESETID NUMBER)  RETURN VARCHAR2;
 FUNCTION Get_AttributeForRuleSet(X_STR_RULESETID NUMBER)  RETURN VARCHAR2;
 FUNCTION Get_AssignedBusinessEnitites(X_STR_RULESETID NUMBER)  RETURN VARCHAR2;
 FUNCTION Get_BussentityForRulesets(X_STR_RULESETID NUMBER) RETURN VARCHAR2;
END Ego_Rules_Util_PVT ;

/
