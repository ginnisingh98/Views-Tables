--------------------------------------------------------
--  DDL for Package FUN_RULE_MOAC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_MOAC_PKG" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULEMOACS.pls 120.0 2006/01/10 12:18:23 ammishra noship $ */

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * FUNCTION SET_MOAC_ACCESS_MODE
 *
 * DESCRIPTION
 *     If Access Mode is not 'S' then set to S and assign the passed org_id.
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

PROCEDURE SET_MOAC_ACCESS_MODE(p_org_id  IN NUMBER);


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
 *      p_access_mode NUMBER
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
                                  p_old_org_id  IN NUMBER  , p_org_id  IN NUMBER  );

END FUN_RULE_MOAC_PKG;

 

/
