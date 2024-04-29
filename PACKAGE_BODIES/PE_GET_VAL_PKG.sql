--------------------------------------------------------
--  DDL for Package Body PE_GET_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_GET_VAL_PKG" as
/* $Header: pepyppgr.pkb 120.2 2005/12/01 01:04:45 ggnanagu noship $ */
--
-- define private global vars
--
   g_grade_id      pay_grade_rules_f.grade_or_spinal_point_id%TYPE;
   g_rate_id       pay_grade_rules_f.rate_id%TYPE;
   g_change_date   DATE;
   g_min_val       pay_grade_rules_f.MINIMUM%TYPE;
   g_mid_val       pay_grade_rules_f.mid_value%TYPE;
   g_max_val       pay_grade_rules_f.maximum%TYPE;

--
--
-- define private global cursor
-- Cursor to get the min,max and mid value from pay_grade_rules_f
--
   CURSOR g_csr_get_grade_values
   IS
      SELECT g.MINIMUM, g.mid_value, g.maximum
        FROM pay_grade_rules_f g
       WHERE g.grade_or_spinal_point_id = g_grade_id
         AND g.rate_id = g_rate_id
         AND g_change_date BETWEEN g.effective_start_date AND g.effective_end_date;

--
-- Description
-- This procedure returns the the minmum, mid_value or maximum value
-- for a given grade.
-- This function is used in hrv_salary_proposal
--
   FUNCTION get_grade_value (
      p_grade_id      NUMBER,
      p_rate_id       NUMBER,
      p_change_date   DATE,
      p_which_value   VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      IF (   p_grade_id IS NULL
          OR p_rate_id IS NULL
          OR p_change_date IS NULL
          OR p_which_value IS NULL
         )
      THEN
         RETURN NULL;
      END IF;
      IF     g_grade_id = p_grade_id
         AND p_change_date = g_change_date
         AND g_rate_id = g_rate_id
      THEN
         --  No need to execute the Cursor
         NULL;
      ELSE
         -- set the global vars used by the cursor
         g_grade_id := p_grade_id;
         g_rate_id := p_rate_id;
         g_change_date := p_change_date;

         --execute the cursor
         OPEN g_csr_get_grade_values;

         FETCH g_csr_get_grade_values
          INTO g_min_val, g_mid_val, g_max_val;

         CLOSE g_csr_get_grade_values;
      END IF;
      IF p_which_value = 'MIN'
      THEN
         RETURN (g_min_val);
      ELSIF p_which_value = 'MID'
      THEN
         RETURN (g_mid_val);
      ELSIF p_which_value = 'MAX'
      THEN
         RETURN (g_max_val);
      ELSE
         RETURN (NULL);
      END IF;
   EXCEPTION
    WHEN OTHERS THEN
     -- close the g_csr_get_grade_values if its open
        IF g_csr_get_grade_values%ISOPEN THEN
          CLOSE g_csr_get_grade_values;
        END IF;
        -- set the g_min_val, g_mid_val, g_max_val global vars to NULL
        g_min_val := NULL;
        g_mid_val := NULL;
        g_max_val := NULL;
    -- as an exception occurred, return NULL
    RETURN(NULL);
   END get_grade_value;
--
END pe_get_val_pkg;

/
