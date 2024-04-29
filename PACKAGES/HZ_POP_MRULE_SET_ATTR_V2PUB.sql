--------------------------------------------------------
--  DDL for Package HZ_POP_MRULE_SET_ATTR_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_POP_MRULE_SET_ATTR_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARHMSARS.pls 120.0 2005/05/25 21:08:38 achung noship $ */

/**
 * PROCEDURE POP_MRULE_SET_ATTRIBUTES
 *
 * DESCRIPTION
 *     This procedure populates all the primary and secondary attributes
 *     of a condition match rule into the set.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_mrule_set_id                 Match rule set id.
 *   IN/OUT:
 *   p_mrule_set_id  IN NUMBER
 *   p_cond_mrule_id IN NUMBER
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *
 *
 */
 PROCEDURE pop_mrule_set_attributes(p_mrule_set_id IN NUMBER);

END HZ_POP_MRULE_SET_ATTR_V2PUB;


 

/
