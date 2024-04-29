--------------------------------------------------------
--  DDL for Package FND_FORM_CUSTOM_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FORM_CUSTOM_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: AFFRRULS.pls 120.2.12010000.2 2009/05/08 17:15:51 dbowles ship $ */

/*
** DELETE_SET - Delete a set of forms personalizations
**
** Deletes a set of forms personalization rules in preparation for
** for upload of replacement data.  Rule set is specified by two filters:
**
**   - X_RULE_KEY
**       <key> - limits deletes to rules tagged with specified rule key
**       NULL  - limits deletes to untagged rules (no rule key)
**   - X_RULE_TYPE
**       'A' - limits deletes to specified X_FUNCTION_NAME function
**       'F' - limits deletes to specified X_FORM_NAME form
**
** Notes:
**   A Forms Personalization can belong to the customer or be shipped from
**   Oracle.  All personalizations shipped from Oracle must be tagged
**   with a Rule Key.  Customers should not use Rule Keys, to avoid
**   conflicting with Oracle delivered rules.  See the loader config
**   file ($FND_TOP/pach/115/import/affrmcus.lct) for a detailed
**   explanation of loader procedures.
*/
PROCEDURE  DELETE_SET(
               X_RULE_KEY        IN VARCHAR2,
               X_RULE_TYPE       IN VARCHAR2,
               X_FUNCTION_NAME   IN VARCHAR2,
	             X_FORM_NAME       IN VARCHAR2);

END FND_FORM_CUSTOM_RULES_PKG;

/
