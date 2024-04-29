--------------------------------------------------------
--  DDL for Package Body FND_FORM_CUSTOM_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FORM_CUSTOM_RULES_PKG" as
/* $Header: AFFRRULB.pls 120.4.12010000.2 2009/05/08 17:16:51 dbowles ship $ */

/*
** Last Delete Context:
**
** The Forms Personalization Loader (affrmcus.lct) uses a replace strategy
** for upload (delete then insert) rather than the ususal merge.  This is
** because the individual personalization rules do not have a portable unique
** key, and also for simplicity of operation.
**
** Since there can be multiple rules per target form/function/rule key
** combination, we must only delete the data for a particular context
** once during an upload session.
**
** Warning: requires all rules for a given context to be loaded from the same
** data file (LDT) and requires rules within the file to be grouped by context.
*/
g_last_delete_rule_key    VARCHAR2(30) := NULL;
g_last_delete_rule_type   VARCHAR2(30) := NULL;
g_last_delete_function    VARCHAR2(30) := NULL;
g_last_delete_form        VARCHAR2(30) := NULL;




/*
** DELETE_SET - Delete a set of Forms Personalization Rules
** (see AFFRRULS.pls for spec)
*/
PROCEDURE DELETE_SET(
              X_RULE_KEY      IN VARCHAR2,
              X_RULE_TYPE     IN VARCHAR2,
              X_FUNCTION_NAME IN VARCHAR2,
              X_FORM_NAME     IN VARCHAR2) IS


BEGIN
    /*
    ** Check if last delete context matches exactly
    **
    ** Note: A NULL RULE_KEY is considered a valid, distinct context value
    ** but the other values should not be null
    */
    if nvl(X_RULE_KEY, '*NULL*') = nvl(g_last_delete_rule_key, '*NULL*') and
        X_RULE_TYPE = g_last_delete_rule_type and
        ((X_RULE_TYPE = 'A' and X_FUNCTION_NAME = g_last_delete_function) or
	 (X_RULE_TYPE = 'F' and X_FORM_NAME = g_last_delete_form)) then
	/* delete for this context was already completed, just exit */
        return;
    end if;

    /*
    ** Delete Forms Personalizations for specified context
    */
    delete from fnd_form_custom_params
    where  action_id in
        (select action_id
         from   fnd_form_custom_actions a , fnd_form_custom_rules r
         where  a.rule_id = r.id
         and    nvl(r.rule_key, '*NULL*') = nvl(X_RULE_KEY,'*NULL*')
         and    ((X_RULE_TYPE = 'A' and r.rule_type = 'A' and r.function_name = X_FUNCTION_NAME) or
                 (X_RULE_TYPE = 'F' and r.rule_type = 'F' and r.form_name = X_FORM_NAME)));

    delete from fnd_form_custom_actions
    where  rule_id in
        (select id
         from   fnd_form_custom_rules r
         where  nvl(r.rule_key, '*NULL*') = nvl(X_RULE_KEY,'*NULL*')
         and    ((X_RULE_TYPE = 'A' and r.rule_type = 'A' and r.function_name = X_FUNCTION_NAME) or
                 (X_RULE_TYPE = 'F' and r.rule_type = 'F' and r.form_name = X_FORM_NAME)));

     delete from fnd_form_custom_scopes
     where  rule_id in
         (select id
          from   fnd_form_custom_rules r
          where  nvl(r.rule_key, '*NULL*') = nvl(X_RULE_KEY,'*NULL*')
          and    ((X_RULE_TYPE = 'A' and r.rule_type = 'A' and r.function_name = X_FUNCTION_NAME) or
                  (X_RULE_TYPE = 'F' and r.rule_type = 'F' and r.form_name = X_FORM_NAME)));

    delete from fnd_form_custom_rules r
    where  nvl(r.rule_key, '*NULL*') = nvl(X_RULE_KEY,'*NULL*')
    and    ((X_RULE_TYPE = 'A' and r.rule_type = 'A' and r.function_name = X_FUNCTION_NAME) or
            (X_RULE_TYPE = 'F' and r.rule_type = 'F' and  r.form_name = X_FORM_NAME));



    /*
    ** save last delete context
    */
    g_last_delete_rule_key   := X_RULE_KEY;
    g_last_delete_rule_type  := X_RULE_TYPE;
    g_last_delete_function   := X_FUNCTION_NAME;
    g_last_delete_form       := X_FORM_NAME;

END DELETE_SET;

END FND_FORM_CUSTOM_RULES_PKG;

/
