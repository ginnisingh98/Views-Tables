--------------------------------------------------------
--  DDL for Package Body IGW_EXP_CATEGORIES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_EXP_CATEGORIES_V_PKG" as
--$Header: igwstexb.pls 115.3 2002/03/28 19:14:00 pkm ship    $

   FUNCTION get_description_from_pa ( p_expenditure_category varchar2)
   RETURN varchar2 IS

      v_description     pa_expenditure_categories.description%TYPE;

   BEGIN

      SELECT description
      INTO v_description
      FROM pa_expenditure_categories
      WHERE expenditure_category = p_expenditure_category;

      RETURN v_description;

   EXCEPTION

      WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
      RETURN null;

   END get_description_from_pa;


   FUNCTION get_start_date_active_from_pa ( p_expenditure_category varchar2)
   RETURN varchar2 IS

      v_start_date_active    pa_expenditure_categories.start_date_active%TYPE;

   BEGIN

      SELECT start_date_active
      INTO v_start_date_active
      FROM pa_expenditure_categories
      WHERE expenditure_category = p_expenditure_category;

      RETURN v_start_date_active;

   EXCEPTION

      WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
      RETURN null;

   END get_start_date_active_from_pa;

   FUNCTION get_end_date_active_from_pa ( p_expenditure_category varchar2)
   RETURN varchar2 IS

      v_end_date_active    pa_expenditure_categories.end_date_active%TYPE;

   BEGIN

      SELECT end_date_active
      INTO v_end_date_active
      FROM pa_expenditure_categories
      WHERE expenditure_category = p_expenditure_category;

      RETURN v_end_date_active;

   EXCEPTION

      WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
      RETURN null;

   END get_end_date_active_from_pa;

END IGW_EXP_CATEGORIES_V_PKG;

/
