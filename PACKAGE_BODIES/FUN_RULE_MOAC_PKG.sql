--------------------------------------------------------
--  DDL for Package Body FUN_RULE_MOAC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_MOAC_PKG" AS
/*$Header: FUNXTMRULEMOACB.pls 120.0 2006/01/10 12:18:31 ammishra noship $ */

/**
 * FUNCTION SET_MOAC_ACCESS_MODE
 *
 * DESCRIPTION
 *     If Access Mode is not 'S' then set to S and assign the passed org_id.
 *     Assumes a not null org_id to be passed from the calling module.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *      p_org_id      NUMBER
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-Jan-2006    Amulya Mishra      Created.
 *
 */

 /* The Algorithm goes like this
    If ORG_ID is not NULL
      if mo_init is not done
        error;
      else
        if l_old_access_mode <> 'S' AND l_old_org_id <> p_org_id
	  set the MOAC policy context.
      end;
    end;
 */

PROCEDURE SET_MOAC_ACCESS_MODE(p_org_id  IN NUMBER)
IS
 l_old_access_mode    VARCHAR2(1);
 l_old_org_id         NUMBER;
BEGIN

 l_old_access_mode := MO_GLOBAL.get_access_mode();
 l_old_org_id      := MO_GLOBAL.get_current_org_id();

 IF (MO_GLOBAL.IS_MO_INIT_DONE <> 'Y' ) THEN
     fnd_message.set_name('FUN', 'FUN_RULE_NO_MOAC_INIT');
     app_exception.raise_exception;
 ELSIF (l_old_access_mode <> 'S' AND l_old_org_id <> p_org_id) THEN
     MO_GLOBAL.SET_POLICY_CONTEXT('S',p_org_id);
 END IF;

 END SET_MOAC_ACCESS_MODE;


/**
 * FUNCTION SET_MOAC_POLICY_CONTEXT
 *
 * DESCRIPTION
 *     SETS THE POLICY CONTEXT BASED ON THE PASSED ACCESS MODE AND ORG ID PARAMETERS..
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *      p_old_access_mode VARCHAR2
 *      p_old_org_id      NUMBER
 *      p_org_id      NUMBER
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-Jan-2006    Amulya Mishra      Created.
 *
 */

PROCEDURE SET_MOAC_POLICY_CONTEXT(p_old_access_mode IN VARCHAR2,
                                  p_old_org_id  IN NUMBER  , p_org_id  IN NUMBER )

IS
 l_old_access_mode    VARCHAR2(1);
 l_old_org_id         NUMBER;

BEGIN

 IF (p_old_access_mode <> 'S' AND p_old_org_id <> p_org_id) THEN
   MO_GLOBAL.SET_POLICY_CONTEXT(p_old_access_mode ,p_old_org_id);
 END IF;

 END SET_MOAC_POLICY_CONTEXT;


END FUN_RULE_MOAC_PKG;

/
