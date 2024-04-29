--------------------------------------------------------
--  DDL for Package BEN_FASTFORMULA_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_FASTFORMULA_CHECK" AUTHID CURRENT_USER AS
/* $Header: benffchk.pkh 120.0 2005/05/28 09:00:43 appldev noship $ */
/*============================================================================+
|                      Copyright (c) 1997 Oracle Corporation                  |
|                         Redwood Shores, California, USA                     |
|                            All rights reserved.                             |
|                          <<BEN_FASTFORMULA_CHECK (H)>>                     |
+=============================================================================+
 * Name:
 *   Fast_Formula_Check
 * Purpose:
 *   This package is used to check the existence of given formula_type_id
 *   and formula_id in ben tables.
 * History:
 *   Date        Who            Version  What?
 *   ----------- ------------   -------  ------------------------------------
 *   01-SEP-2004 swjain         115.0    Created.
 *   01-SEP-2004 swjain         115.1    No Changes.
 *   01-SEP-2004 swjain         115.2    No Changes.
 *   01-SEP-2004 swjain         115.3    p_effective_date and p_business_group_id
 *										 defaulted to null
 *   02-SEP-2004 swjain         115.4    p_legislation_cd parameter added for
 *										 future use
 * ===========================================================================
 */

--
-- ============================================================================
-- Function Name:<<chk_formula_exists_in_ben>>
-- Description:
-- Checks the existence of the given formula_id and formula_type_id in ben tables.
--.
-- ============================================================================
--
FUNCTION chk_formula_exists_in_ben(p_formula_id IN NUMBER,
                                   p_formula_type_id IN NUMBER,
								   p_effective_date IN DATE Default NULL,
								   p_business_group_id IN NUMBER Default NULL,
								   p_legislation_cd IN VARCHAR2 Default NULL
								   )
	                               RETURN BOOLEAN;
--
END Ben_FastFormula_Check;

 

/
