--------------------------------------------------------
--  DDL for Package HRI_EDW_DIM_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_EDW_DIM_PERSON" AUTHID CURRENT_USER AS
/* $Header: hriedpsn.pkh 120.0 2005/05/29 07:09:10 appldev noship $ */

FUNCTION get_nearest_parent(p_person_id  IN NUMBER)
                 RETURN NUMBER;

FUNCTION is_a_buyer (p_person_id IN NUMBER)
                RETURN VARCHAR2;

FUNCTION is_a_planner (p_person_id IN NUMBER)
             RETURN VARCHAR2;

FUNCTION is_a_sales_rep (p_person_id IN NUMBER)
                RETURN VARCHAR2;

END hri_edw_dim_person;

 

/
