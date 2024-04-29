--------------------------------------------------------
--  DDL for Package Body PER_RU_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RU_DATA_PUMP" AS
/* $Header: hrrudpmf.pkb 120.0 2005/05/31 02:35:02 appldev noship $ */
   FUNCTION get_employer_id (
      p_employer_name       IN   VARCHAR2,
      p_business_group_id   IN   NUMBER,
      p_effective_date      IN   DATE,
      p_language_code       IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      l_employer_id     NUMBER;
      l_language_code   VARCHAR2 (2);
   BEGIN
      SELECT NVL (p_language_code, 'US')
        INTO l_language_code
        FROM DUAL;

      l_employer_id :=
         hr_pump_get.get_organization_id (p_employer_name,
                                          p_business_group_id,
                                          p_effective_date,
                                          l_language_code
                                         );
      RETURN TO_CHAR (l_employer_id);
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_data_pump.fail ('get_employer_id',
                            SQLERRM,
                            p_employer_name,
                            p_business_group_id,
                            p_effective_date,
                            l_language_code
                           );
         RAISE;
   END get_employer_id;
END per_ru_data_pump;

/
