--------------------------------------------------------
--  DDL for Package Body PAY_US_ARCHIVE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ARCHIVE_UTIL" AS
/* $Header: payusarchiveutil.pkb 120.0 2005/05/29 11:52:17 appldev noship $ */

   /*
    +=====================================================================+
    |              Copyright (c) 1997 Orcale Corporation                  |
    |                 Redwood Shores, California, USA                     |
    |                      All rights reserved.                           |
    +=====================================================================+
   Name        : payusarchiveutil.pkb
   Description : This package contains utilities to fetch archived values.

   Change List
   -----------

   Version Date      Author          Bug No.   Description of Change
   -------+---------+---------------+---------+--------------------------
   115.0   20-AUG-04  rsethupa       3393493   Created
   115.1   25-AUG-04  sodhingr                 Changed the logic which caches
                                               user_entity_id to always check
                                               if the user_entity_id is NULL
                                               if the user_entity_id is NULL
   115.2   01-SEP-04  sodhingr                 Added the debug messages and
                                               changed the data type of lv_return_value
                                               to ff_archive_item.value%type to avoid
                                               the pl/sql numeric error when getting
                                               the archive_date
   115.3   08-NOV-04  rsethupa       3180532   Added function get_ff_archive_value
   115.4   10-NOV-04  meshah                   removed function
                                               get_ff_archive_value and
                                               moved it to
                                               pay_us_reporting_utils_pkg
                                               for extract reasons.
   115.5   23-NOV-04  rsethupa       3180532   Changed cursor
                                               c_get_value_with_jc
                                               to check only for the first 2
					       characters of jurisdiction code
   ----------------------------------------------------------------------
   */

   /*********************************************************************
    Name        : get_archive_value

    Description : gets the archived value for a particular Action ID
                  (Assignment Action or Payroll Action). Jurisdiction
        code is optional.

    ********************************************************************/
   FUNCTION get_archive_value (
      p_action_id           NUMBER,
      p_user_entity_name    VARCHAR2,
      p_tax_unit_id         NUMBER,
      p_jurisdiction_code   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      CURSOR c_get_user_entity_name (cp_user_entity_name VARCHAR2)
      IS
         SELECT user_entity_id
           FROM ff_user_entities
          WHERE user_entity_name = cp_user_entity_name;

      CURSOR c_get_value (
         cp_user_entity_id   NUMBER,
         cp_action_id        NUMBER,
         cp_tax_unit_id      NUMBER,
         cp_tax_context_id   NUMBER
      )
      IS
         SELECT fai.VALUE
           FROM ff_archive_items fai, ff_archive_item_contexts fic
          WHERE fai.context1 = cp_action_id
            AND fai.user_entity_id = cp_user_entity_id
            AND fai.archive_item_id = fic.archive_item_id
            AND fic.context_id = cp_tax_context_id
            AND fic.CONTEXT = cp_tax_unit_id;

/* The following cursor is just like the c_state_item cursor in package
   pyusw2pg.pkb */
      CURSOR c_get_value_with_jc (
         cp_user_entity_id      NUMBER,
         cp_action_id           NUMBER,
         cp_tax_unit_id         NUMBER,
         cp_jurisdiction_code   VARCHAR2
      )
      IS
         SELECT fai.VALUE
           FROM ff_archive_item_contexts faic2,
                ff_archive_item_contexts faic1,
                ff_contexts fc2,
                ff_contexts fc1,
                ff_archive_items fai
          WHERE fai.user_entity_id = cp_user_entity_id
            AND fai.context1 = cp_action_id
            AND fc2.context_name = 'TAX_UNIT_ID'
            AND fc1.context_name = 'JURISDICTION_CODE'
            AND fai.archive_item_id = faic2.archive_item_id
            AND faic2.context_id = fc2.context_id
            AND faic2.CONTEXT = cp_tax_unit_id
            AND fai.archive_item_id = faic1.archive_item_id
            AND faic1.context_id = fc1.context_id
            AND substr(faic1.CONTEXT,1,2) = substr(cp_jurisdiction_code,1,2);

      lv_tax_context_id     NUMBER;
      lv_table_count        NUMBER;
      lv_user_entity_id     ff_user_entities.user_entity_id%TYPE;
      lv_user_entity_name   ff_user_entities.user_entity_name%TYPE;
      lv_return_value       ff_archive_items.value%TYPE;
   BEGIN
      lv_tax_context_id := -1;
      lv_table_count := 0;
      lv_user_entity_id := NULL;
      lv_tax_context_id := hr_us_w2_rep.get_context_id ('TAX_UNIT_ID');
      lv_return_value := NULL;

      IF ltr_user_entity_table.COUNT > 0
      THEN
         hr_utility.trace('User Entity table count > 0 '||ltr_user_entity_table.COUNT);
         FOR j IN ltr_user_entity_table.FIRST .. ltr_user_entity_table.LAST
         LOOP
            IF ltr_user_entity_table (j).user_entity_name =
                                                           p_user_entity_name
            THEN
               lv_user_entity_id := ltr_user_entity_table (j).user_entity_id;
               EXIT;
            END IF;
         END LOOP;
      /*Always check if the user_entity_id is NULL to get the user_entity_id if the it's not
        cached
        ELSIF ltr_user_entity_table.COUNT = 0 OR lv_user_entity_id = NULL
      */
      END IF;

      hr_utility.trace('User Entity table count '|| ltr_user_entity_table.COUNT);
      hr_utility.trace(' lv_user_entity_id '|| lv_user_entity_id);

      IF ltr_user_entity_table.COUNT = 0 OR lv_user_entity_id IS NULL THEN
         OPEN c_get_user_entity_name (p_user_entity_name);

         FETCH c_get_user_entity_name
          INTO lv_user_entity_id;

         CLOSE c_get_user_entity_name;

         lv_table_count := ltr_user_entity_table.COUNT;
         ltr_user_entity_table (lv_table_count).user_entity_name :=
                                                           p_user_entity_name;
         ltr_user_entity_table (lv_table_count).user_entity_id :=
                                                            lv_user_entity_id;
      END IF;

      hr_utility.trace(' lv_user_entity_id '|| lv_user_entity_id);
      hr_utility.trace(' p_action_id '|| p_action_id);
      hr_utility.trace(' p_tax_unit_id '|| p_tax_unit_id);
      hr_utility.trace(' lv_tax_context_id '|| lv_tax_context_id);

      IF p_jurisdiction_code IS NULL
      THEN
         hr_utility.trace(' Jurisdiction is NULL');
                  hr_utility.trace(' Jurisdiction is NULL, lv_user_entity_id '|| lv_user_entity_id);

         OPEN c_get_value (lv_user_entity_id,
                           p_action_id,
                           p_tax_unit_id,
                           lv_tax_context_id
                          );

         FETCH c_get_value
          INTO lv_return_value;

         hr_utility.trace(' lv_return_value '|| lv_return_value);

         CLOSE c_get_value;
      ELSE
         hr_utility.trace(' Jurisdiction is Not NULL, p_jurisdiction_code '||p_jurisdiction_code);
         OPEN c_get_value_with_jc (lv_user_entity_id,
                                   p_action_id,
                                   p_tax_unit_id,
                                   p_jurisdiction_code
                                  );

         FETCH c_get_value_with_jc
          INTO lv_return_value;

         CLOSE c_get_value_with_jc;
      END IF;

      RETURN lv_return_value;
   END get_archive_value;

END pay_us_archive_util;


/
