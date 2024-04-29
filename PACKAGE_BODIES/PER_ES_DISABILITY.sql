--------------------------------------------------------
--  DDL for Package Body PER_ES_DISABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ES_DISABILITY" AS
/* $Header: peesdisp.pkb 120.1 2006/09/15 09:30:57 mgettins noship $ */
PROCEDURE check_es_disability(p_category  VARCHAR2
                              ,p_degree   NUMBER) IS
--
BEGIN
--
/*    IF  p_degree IS NOT NULL THEN
        IF  p_category='ES_DIS_LT_33_PERC' THEN
            IF  NOT (p_degree <33 and p_degree > 0) THEN
                hr_utility.set_message(800,'HR_ES_INVALID_DIS_DEGREE');
                hr_utility.raise_error;
            END IF;
        ELSIF p_category='ES_DIS_BTW_33_65_PERC' THEN
            IF NOT (p_degree >=33 and p_degree <=65 ) THEN
                hr_utility.set_message(800,'HR_ES_INVALID_DIS_DEGREE');
                hr_utility.raise_error;
           END IF;
        ELSIF p_category='ES_DIS_GT_65_PERC' THEN
            IF  (p_degree <=65) THEN
                hr_utility.set_message(800,'HR_ES_INVALID_DIS_DEGREE');
                hr_utility.raise_error;
            END IF;
        END IF;
   END IF;*/
   null;
END check_es_disability;
--
PROCEDURE create_es_disability(p_category VARCHAR2
                              ,p_degree   NUMBER) IS
--
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
    --
    --  per_es_disability.check_es_disability(p_category => p_category
    --                                       ,p_degree   => p_degree);
    null;
    --
  END IF;
  --
END create_es_disability;
--
PROCEDURE update_es_disability(p_category VARCHAR2
                              ,p_degree   NUMBER) IS
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
     --per_es_disability.check_es_disability(p_category => p_category
     --                                      ,p_degree   => p_degree);
     null;
     --
  END IF;
  --
END update_es_disability;
--
END per_es_disability;

/
