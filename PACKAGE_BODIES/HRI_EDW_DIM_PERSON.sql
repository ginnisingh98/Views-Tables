--------------------------------------------------------
--  DDL for Package Body HRI_EDW_DIM_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_DIM_PERSON" AS
/* $Header: hriedpsn.pkb 120.0 2005/05/29 07:09:03 appldev noship $ */

/******************************************************************************/
/* get_nearest_parent returns the 15th level supervisor over the person who   */
/* is below the 16th level                                                    */
/******************************************************************************/
FUNCTION get_nearest_parent(p_person_id  IN NUMBER)
                 RETURN NUMBER IS

  l_parent_id      NUMBER;

  CURSOR parent_csr IS
  SELECT supv_person_id
  FROM hri_supv_hrchy_summary
  WHERE sub_person_id = p_person_id
  AND supv_level = 14;

BEGIN

  OPEN parent_csr;
  FETCH parent_csr INTO l_parent_id;
  CLOSE parent_csr;

  RETURN l_parent_id;

END get_nearest_parent;

/******************************************************************************/
/* is_a_buyer tests whether the given person also exists as a buyer           */
/******************************************************************************/
FUNCTION is_a_buyer (p_person_id IN NUMBER)
                RETURN VARCHAR2 IS

  l_temp NUMBER := NULL;  -- variable to hold buyer id if one exists

BEGIN

  SELECT agent_id INTO l_temp
  FROM po_agents
  WHERE agent_id = p_person_id
  AND rownum < 2;

  IF l_temp IS NULL THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;

EXCEPTION WHEN OTHERS THEN
  RETURN 'N';

END is_a_buyer;


/******************************************************************************/
/* is_a_planner tests whether the given person also exists as a planner       */
/******************************************************************************/
FUNCTION is_a_planner (p_person_id IN NUMBER)
             RETURN VARCHAR2 IS

  l_temp NUMBER := NULL;  -- variable to hold planner id if one exists

BEGIN

  SELECT employee_id INTO l_temp
  FROM mtl_planners
  WHERE employee_id = p_person_id
  AND rownum < 2;

  IF l_temp IS NULL THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;

EXCEPTION WHEN OTHERS THEN
  RETURN 'N';

END is_a_planner;


/******************************************************************************/
/* is_a_sales_rep tests whether the given person also exists as a sales rep   */
/******************************************************************************/
FUNCTION is_a_sales_rep (p_person_id IN NUMBER)
                RETURN VARCHAR2 IS

  l_temp NUMBER := NULL;  -- variable to hold sales rep id if one exists

BEGIN

  SELECT person_id INTO l_temp
  FROM ra_salesreps_all
  WHERE person_id = p_person_id
  AND rownum < 2;

  IF l_temp IS NULL THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;

EXCEPTION WHEN OTHERS THEN
  RETURN 'N';

END is_a_sales_rep;

END hri_edw_dim_person;

/
