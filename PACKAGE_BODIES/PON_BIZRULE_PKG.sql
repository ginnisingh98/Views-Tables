--------------------------------------------------------
--  DDL for Package Body PON_BIZRULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_BIZRULE_PKG" AS
/* $Header: PONBIZRB.pls 120.0 2005/06/01 14:15:03 appldev noship $ */

PROCEDURE add_rule(p_rule_id    NUMBER) IS

CURSOR documents IS
   SELECT doctype_id FROM pon_auc_doctypes;

BEGIN

   FOR doc IN documents LOOP
      INSERT INTO PON_AUC_DOCTYPE_RULES
	(BIZRULE_ID,
	 DOCTYPE_ID,
	 DISPLAY_FLAG,
	 REQUIRED_FLAG,
	 FIXED_VALUE,
	 DEFAULT_VALUE,
	 RESTRICTED_VALUES_FLAG,
	 VALIDITY_FLAG,
	 CREATED_BY,
	 CREATION_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_DATE
	 )
	VALUES
	(p_rule_id,
         doc.doctype_id,
	 'N',
	 'N',
	 NULL,
	 NULL,
	 'N',
	 'N',
	 1,
	 Sysdate,
	 1,
	 Sysdate
	 );
   END LOOP;
END add_rule;

PROCEDURE delete_rule(p_rule_id    NUMBER) IS

CURSOR documents IS
   SELECT doctype_id FROM pon_auc_doctypes;

BEGIN
   DELETE FROM pon_auc_doctype_rules  WHERE  bizrule_id = p_rule_id;
END delete_rule;


PROCEDURE edit_rule(p_rule_id    NUMBER) IS

CURSOR documents IS
SELECT d.doctype_id FROM pon_auc_doctypes d
  WHERE NOT EXISTS (select 'FOUND' from pon_auc_doctype_rules
		    where bizrule_id = p_rule_id AND doctype_id = d.doctype_id);

BEGIN

   FOR doc IN documents LOOP
      INSERT INTO PON_AUC_DOCTYPE_RULES
	(BIZRULE_ID,
	 DOCTYPE_ID,
	 DISPLAY_FLAG,
	 REQUIRED_FLAG,
	 FIXED_VALUE,
	 DEFAULT_VALUE,
	 RESTRICTED_VALUES_FLAG,
	 VALIDITY_FLAG,
	 CREATED_BY,
	 CREATION_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_DATE
	 )
	VALUES
	(p_rule_id,
         doc.doctype_id,
	 'N',
	 'N',
	 NULL,
	 NULL,
	 'N',
	 'N',
	 1,
	 Sysdate,
	 1,
	 Sysdate
	 );
   END LOOP;
END edit_rule;

END PON_BIZRULE_PKG;

/
