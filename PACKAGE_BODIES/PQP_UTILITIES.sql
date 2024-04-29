--------------------------------------------------------
--  DDL for Package Body PQP_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_UTILITIES" AS
/* $Header: pqputifn.pkb 120.19.12000000.2 2007/07/04 13:32:35 apmishra noship $ */
--
--
--
-- Debug Variables.
--
  g_package_name                VARCHAR2(31) := 'pqp_utilities.';

-- Hash Function Variable
  g_hash_key        NUMBER(15) :=  NULL;
  g_hash_base       NUMBER(15) :=  NULL;
  g_hash_size       NUMBER(15) :=  NULL;
  g_conflict_check  BOOLEAN ;
  PROCEDURE debug(p_trace_message IN VARCHAR2, p_trace_location IN NUMBER)
  IS
    l_padding                     VARCHAR2(12);
    l_max_message_length          NUMBER := 72;
    l_time                        NUMBER;
    l_trace_message               VARCHAR2(250);
  BEGIN
    IF p_trace_location IS NOT NULL
    THEN
      IF g_debug_entry_exits_only
      THEN
        IF NOT(
                  UPPER(LTRIM(p_trace_message)) LIKE 'ENTERING%'
               OR UPPER(LTRIM(p_trace_message)) LIKE 'LEAVING%'
              )
        THEN
          RETURN; -- its not an entry exit message, continue
        END IF;
      END IF;

      -- if control reaches here either all trace messages are allowed
      -- or it is an extry and exit message

      -- its important to do the timestamp check AFTER the entry-exit check
 /*BUG No: 6137713*/
     IF g_debug_timestamps
      THEN
        l_trace_message :=
                       SUBSTR(TO_CHAR(DBMS_UTILITY.get_time) || ':'
                       || p_trace_message,1,250);
      ELSE
        l_trace_message := SUBSTR(p_trace_message,1,250);
      END IF;

      hr_utility.set_location(l_trace_message, p_trace_location);
    ELSE
      IF NOT g_debug_entry_exits_only
      THEN
        hr_utility.TRACE(SUBSTR(p_trace_message, 1, 250));
      END IF;
    END IF;
  END debug;


-- This procedure is used to get configuration values
-- for a configuration type.
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_config_type_values >--------------------|
-- ----------------------------------------------------------------------------

PROCEDURE get_config_type_values(
   p_configuration_type   IN              VARCHAR2
  ,p_business_group_id    IN              NUMBER
  ,p_legislation_code     IN              VARCHAR2
  ,p_tab_config_values    OUT NOCOPY      t_config_values
)
IS
   --
   -- Cursor to fetch configuration values
   -- for a given configuration type, bg and leg code
   CURSOR csr_get_config_values(c_legislation_code VARCHAR2)
   IS
      SELECT pcv.configuration_value_id, pcv.pcv_information1
            ,pcv.pcv_information2, pcv.pcv_information3
            ,pcv.pcv_information4, pcv.pcv_information5
            ,pcv.pcv_information6, pcv.pcv_information7
            ,pcv.pcv_information8, pcv.pcv_information9
            ,pcv.pcv_information10, pcv.pcv_information11
            ,pcv.pcv_information12, pcv.pcv_information13
            ,pcv.pcv_information14, pcv.pcv_information15
            ,pcv.pcv_information16, pcv.pcv_information17
            ,pcv.pcv_information18, pcv.pcv_information19
            ,pcv.pcv_information20
        FROM pqp_configuration_values pcv, pqp_configuration_types pct
       WHERE pcv.pcv_information_category = pct.configuration_type
         AND pct.configuration_type = p_configuration_type
         AND (   (    pcv.business_group_id IS NOT NULL
                  AND pcv.business_group_id = p_business_group_id
                 )
              OR (    pcv.legislation_code IS NOT NULL
                  AND pcv.legislation_code = c_legislation_code
                  AND NOT EXISTS(
                         SELECT 1
                           FROM pqp_configuration_values pcv2
                          WHERE pcv2.pcv_information_category =
                                                  pcv.pcv_information_category
                            AND pcv2.configuration_value_id <>
                                                    pcv.configuration_value_id
                            AND pcv2.business_group_id = p_business_group_id
                            AND (   (    pct.multiple_occurences_flag = 'Y'
                                     AND (   (    pct.total_unique_columns = 1
                                              AND pcv2.pcv_information1 =
                                                          pcv.pcv_information1
                                             )
                                          OR (    pct.total_unique_columns = 2
                                              AND pcv2.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv2.pcv_information2 =
                                                          pcv.pcv_information2
                                             )
                                          OR (    pct.total_unique_columns = 3
                                              AND pcv2.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv2.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv2.pcv_information3 =
                                                          pcv.pcv_information3
                                             )
                                          OR (    pct.total_unique_columns = 4
                                              AND pcv2.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv2.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv2.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv2.pcv_information4 =
                                                          pcv.pcv_information4
                                             )
                                          OR (    pct.total_unique_columns = 5
                                              AND pcv2.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv2.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv2.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv2.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv2.pcv_information5 =
                                                          pcv.pcv_information5
                                             )
                                          OR (    pct.total_unique_columns = 6
                                              AND pcv2.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv2.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv2.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv2.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv2.pcv_information5 =
                                                          pcv.pcv_information5
                                              AND pcv2.pcv_information6 =
                                                          pcv.pcv_information6
                                             )
                                          OR (    pct.total_unique_columns = 7
                                              AND pcv2.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv2.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv2.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv2.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv2.pcv_information5 =
                                                          pcv.pcv_information5
                                              AND pcv2.pcv_information6 =
                                                          pcv.pcv_information6
                                              AND pcv2.pcv_information7 =
                                                          pcv.pcv_information7
                                             )
                                          OR (    pct.total_unique_columns = 8
                                              AND pcv2.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv2.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv2.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv2.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv2.pcv_information5 =
                                                          pcv.pcv_information5
                                              AND pcv2.pcv_information6 =
                                                          pcv.pcv_information6
                                              AND pcv2.pcv_information7 =
                                                          pcv.pcv_information7
                                              AND pcv2.pcv_information8 =
                                                          pcv.pcv_information8
                                             )
                                          OR (    pct.total_unique_columns = 9
                                              AND pcv2.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv2.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv2.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv2.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv2.pcv_information5 =
                                                          pcv.pcv_information5
                                              AND pcv2.pcv_information6 =
                                                          pcv.pcv_information6
                                              AND pcv2.pcv_information7 =
                                                          pcv.pcv_information7
                                              AND pcv2.pcv_information8 =
                                                          pcv.pcv_information8
                                              AND pcv2.pcv_information9 =
                                                          pcv.pcv_information9
                                             )
                                          OR (    pct.total_unique_columns =
                                                                            10
                                              AND pcv2.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv2.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv2.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv2.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv2.pcv_information5 =
                                                          pcv.pcv_information5
                                              AND pcv2.pcv_information6 =
                                                          pcv.pcv_information6
                                              AND pcv2.pcv_information7 =
                                                          pcv.pcv_information7
                                              AND pcv2.pcv_information8 =
                                                          pcv.pcv_information8
                                              AND pcv2.pcv_information9 =
                                                          pcv.pcv_information9
                                              AND pcv2.pcv_information10 =
                                                         pcv.pcv_information10
                                             )
                                         )
                                    )
                                 OR pct.multiple_occurences_flag = 'N'
                                ))
                 )
              OR (    pcv.business_group_id IS NULL
                  AND pcv.legislation_code IS NULL
                  AND NOT EXISTS(
                         SELECT 1
                           FROM pqp_configuration_values pcv3
                          WHERE pcv3.pcv_information_category =
                                                  pcv.pcv_information_category
                            AND pcv3.configuration_value_id <>
                                                    pcv.configuration_value_id
                            AND (   pcv3.business_group_id =
                                                           p_business_group_id
                                 OR pcv3.legislation_code = c_legislation_code
                                )
                            AND (   (    pct.multiple_occurences_flag = 'Y'
                                     AND (   (    pct.total_unique_columns = 1
                                              AND pcv3.pcv_information1 =
                                                          pcv.pcv_information1
                                             )
                                          OR (    pct.total_unique_columns = 2
                                              AND pcv3.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv3.pcv_information2 =
                                                          pcv.pcv_information2
                                             )
                                          OR (    pct.total_unique_columns = 3
                                              AND pcv3.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv3.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv3.pcv_information3 =
                                                          pcv.pcv_information3
                                             )
                                          OR (    pct.total_unique_columns = 4
                                              AND pcv3.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv3.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv3.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv3.pcv_information4 =
                                                          pcv.pcv_information4
                                             )
                                          OR (    pct.total_unique_columns = 5
                                              AND pcv3.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv3.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv3.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv3.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv3.pcv_information5 =
                                                          pcv.pcv_information5
                                             )
                                          OR (    pct.total_unique_columns = 6
                                              AND pcv3.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv3.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv3.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv3.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv3.pcv_information5 =
                                                          pcv.pcv_information5
                                              AND pcv3.pcv_information6 =
                                                          pcv.pcv_information6
                                             )
                                          OR (    pct.total_unique_columns = 7
                                              AND pcv3.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv3.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv3.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv3.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv3.pcv_information5 =
                                                          pcv.pcv_information5
                                              AND pcv3.pcv_information6 =
                                                          pcv.pcv_information6
                                              AND pcv3.pcv_information7 =
                                                          pcv.pcv_information7
                                             )
                                          OR (    pct.total_unique_columns = 8
                                              AND pcv3.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv3.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv3.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv3.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv3.pcv_information5 =
                                                          pcv.pcv_information5
                                              AND pcv3.pcv_information6 =
                                                          pcv.pcv_information6
                                              AND pcv3.pcv_information7 =
                                                          pcv.pcv_information7
                                              AND pcv3.pcv_information8 =
                                                          pcv.pcv_information8
                                             )
                                          OR (    pct.total_unique_columns = 9
                                              AND pcv3.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv3.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv3.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv3.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv3.pcv_information5 =
                                                          pcv.pcv_information5
                                              AND pcv3.pcv_information6 =
                                                          pcv.pcv_information6
                                              AND pcv3.pcv_information7 =
                                                          pcv.pcv_information7
                                              AND pcv3.pcv_information8 =
                                                          pcv.pcv_information8
                                              AND pcv3.pcv_information9 =
                                                          pcv.pcv_information9
                                             )
                                          OR (    pct.total_unique_columns =
                                                                            10
                                              AND pcv3.pcv_information1 =
                                                          pcv.pcv_information1
                                              AND pcv3.pcv_information2 =
                                                          pcv.pcv_information2
                                              AND pcv3.pcv_information3 =
                                                          pcv.pcv_information3
                                              AND pcv3.pcv_information4 =
                                                          pcv.pcv_information4
                                              AND pcv3.pcv_information5 =
                                                          pcv.pcv_information5
                                              AND pcv3.pcv_information6 =
                                                          pcv.pcv_information6
                                              AND pcv3.pcv_information7 =
                                                          pcv.pcv_information7
                                              AND pcv3.pcv_information8 =
                                                          pcv.pcv_information8
                                              AND pcv3.pcv_information9 =
                                                          pcv.pcv_information9
                                              AND pcv3.pcv_information10 =
                                                         pcv.pcv_information10
                                             )
                                         )
                                    )
                                 OR pct.multiple_occurences_flag = 'N'
                                ))
                 )
             )
         AND (   pct.legislation_code = c_legislation_code
              OR pct.legislation_code IS NULL
             );

   l_proc_name           VARCHAR2(80)
                                    := g_package_name || 'get_config_type_values';
   l_proc_step           PLS_INTEGER;
   l_legislation_code    per_business_groups_perf.legislation_code%TYPE;
   l_config_values_rec   csr_get_config_values%ROWTYPE;
   l_config_value_id     NUMBER;
   l_tab_config_values   t_config_values;
--
BEGIN
   --
   IF g_debug
   THEN
      l_proc_step    := 10;
      DEBUG('Entering: ' || l_proc_name, l_proc_step);
   END IF;

   IF p_legislation_code IS NULL THEN
     IF p_business_group_id IS NOT NULL THEN
       -- Get legislation code
       l_legislation_code     :=
            pqp_utilities.pqp_get_legislation_code(p_business_group_id      => p_business_group_id);
     END IF;
   ELSE
     l_legislation_code := p_legislation_code;
   END IF;


   IF g_debug
   THEN
      l_proc_step    := 20;
      DEBUG('l_legislation_code: ' || l_legislation_code);
      DEBUG(l_proc_name, l_proc_step);
   END IF;

   -- Get configuration value for the configuration type
   OPEN csr_get_config_values(l_legislation_code);

   LOOP
      FETCH csr_get_config_values INTO l_config_values_rec;
      EXIT WHEN csr_get_config_values%NOTFOUND;
      -- Store the values in the collection
      l_config_value_id                                           :=
                                   l_config_values_rec.configuration_value_id;
      l_tab_config_values(l_config_value_id).pcv_information1     :=
                                         l_config_values_rec.pcv_information1;
      l_tab_config_values(l_config_value_id).pcv_information2     :=
                                         l_config_values_rec.pcv_information2;
      l_tab_config_values(l_config_value_id).pcv_information3     :=
                                         l_config_values_rec.pcv_information3;
      l_tab_config_values(l_config_value_id).pcv_information4     :=
                                         l_config_values_rec.pcv_information4;
      l_tab_config_values(l_config_value_id).pcv_information5     :=
                                         l_config_values_rec.pcv_information5;
      l_tab_config_values(l_config_value_id).pcv_information6     :=
                                         l_config_values_rec.pcv_information6;
      l_tab_config_values(l_config_value_id).pcv_information7     :=
                                         l_config_values_rec.pcv_information7;
      l_tab_config_values(l_config_value_id).pcv_information8     :=
                                         l_config_values_rec.pcv_information8;
      l_tab_config_values(l_config_value_id).pcv_information9     :=
                                         l_config_values_rec.pcv_information9;
      l_tab_config_values(l_config_value_id).pcv_information10    :=
                                        l_config_values_rec.pcv_information10;
      l_tab_config_values(l_config_value_id).pcv_information11    :=
                                        l_config_values_rec.pcv_information11;
      l_tab_config_values(l_config_value_id).pcv_information12    :=
                                        l_config_values_rec.pcv_information12;
      l_tab_config_values(l_config_value_id).pcv_information13    :=
                                        l_config_values_rec.pcv_information13;
      l_tab_config_values(l_config_value_id).pcv_information14    :=
                                        l_config_values_rec.pcv_information14;
      l_tab_config_values(l_config_value_id).pcv_information15    :=
                                        l_config_values_rec.pcv_information15;
      l_tab_config_values(l_config_value_id).pcv_information16    :=
                                        l_config_values_rec.pcv_information16;
      l_tab_config_values(l_config_value_id).pcv_information17    :=
                                        l_config_values_rec.pcv_information17;
      l_tab_config_values(l_config_value_id).pcv_information18    :=
                                        l_config_values_rec.pcv_information18;
      l_tab_config_values(l_config_value_id).pcv_information19    :=
                                        l_config_values_rec.pcv_information19;
      l_tab_config_values(l_config_value_id).pcv_information20    :=
                                        l_config_values_rec.pcv_information20;

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(   'l_config_values_rec.pcv_information1: '
               || l_config_values_rec.pcv_information1
              );
         DEBUG(   'l_config_values_rec.pcv_information2: '
               || l_config_values_rec.pcv_information2
              );
         DEBUG(   'l_config_values_rec.pcv_information3: '
               || l_config_values_rec.pcv_information3
              );
         DEBUG(   'l_config_values_rec.pcv_information4: '
               || l_config_values_rec.pcv_information4
              );
         DEBUG(   'l_config_values_rec.pcv_information5: '
               || l_config_values_rec.pcv_information5
              );
         DEBUG(   'l_config_values_rec.pcv_information6: '
               || l_config_values_rec.pcv_information6
              );
         DEBUG(   'l_config_values_rec.pcv_information7: '
               || l_config_values_rec.pcv_information7
              );
         DEBUG(   'l_config_values_rec.pcv_information8: '
               || l_config_values_rec.pcv_information8
              );
         DEBUG(   'l_config_values_rec.pcv_information9: '
               || l_config_values_rec.pcv_information9
              );
         DEBUG(   'l_config_values_rec.pcv_information10: '
               || l_config_values_rec.pcv_information10
              );
         DEBUG(   'l_config_values_rec.pcv_information11: '
               || l_config_values_rec.pcv_information11
              );
         DEBUG(   'l_config_values_rec.pcv_information12: '
               || l_config_values_rec.pcv_information12
              );
         DEBUG(   'l_config_values_rec.pcv_information13: '
               || l_config_values_rec.pcv_information13
              );
         DEBUG(   'l_config_values_rec.pcv_information14: '
               || l_config_values_rec.pcv_information14
              );
         DEBUG(   'l_config_values_rec.pcv_information15: '
               || l_config_values_rec.pcv_information15
              );
         DEBUG(   'l_config_values_rec.pcv_information16: '
               || l_config_values_rec.pcv_information16
              );
         DEBUG(   'l_config_values_rec.pcv_information17: '
               || l_config_values_rec.pcv_information17
              );
         DEBUG(   'l_config_values_rec.pcv_information18: '
               || l_config_values_rec.pcv_information18
              );
         DEBUG(   'l_config_values_rec.pcv_information19: '
               || l_config_values_rec.pcv_information19
              );
         DEBUG(   'l_config_values_rec.pcv_information20: '
               || l_config_values_rec.pcv_information20
              );
         DEBUG(l_proc_name, l_proc_step);
      END IF;
   END LOOP;

   CLOSE csr_get_config_values;
   p_tab_config_values    := l_tab_config_values;

   IF g_debug
   THEN
      l_proc_step    := 40;
      DEBUG('Leaving: ' || l_proc_name, l_proc_step);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      --clear_cache;

      IF SQLCODE <> hr_utility.hr_error_number
      THEN
         debug_others(l_proc_name, l_proc_step);

         IF g_debug
         THEN
            DEBUG('Leaving: ' || l_proc_name, -999);
         END IF;

         fnd_message.raise_error;
      ELSE
         RAISE;
      END IF;
END get_config_type_values;



--
--
--
  PROCEDURE debug(p_trace_number IN NUMBER)
  IS
  BEGIN
      debug(fnd_number.number_to_canonical(p_trace_number));
  END debug;

--
--
--
  PROCEDURE debug(p_trace_date IN DATE)
  IS
  BEGIN
      debug(fnd_date.date_to_canonical(p_trace_date));
  END debug;

--
--
--
  PROCEDURE debug_enter(
    p_proc_name                 IN       VARCHAR2 DEFAULT NULL
   ,p_trace_on                  IN       VARCHAR2 DEFAULT NULL
  )
  IS

  BEGIN

    g_nested_level := g_nested_level + 1;
    debug('Entering: ' || NVL(p_proc_name, g_package_name)
         ,g_nested_level * 100);

  END debug_enter;

--
--
--
  PROCEDURE debug_exit(p_proc_name IN VARCHAR2, p_trace_off IN VARCHAR2)
  IS
  BEGIN

    debug('Leaving: ' || NVL(p_proc_name, g_package_name)
         ,-g_nested_level * 100);
    g_nested_level := g_nested_level - 1;

  END debug_exit;

--
--
--
  PROCEDURE debug_others(
    p_proc_name                 IN       VARCHAR2
   ,p_proc_step                 IN       NUMBER DEFAULT NULL
  )
  IS
    l_message                     fnd_new_messages.MESSAGE_TEXT%TYPE;
  BEGIN

    IF g_debug
    THEN
      debug(p_proc_name, SQLCODE);
      debug(SQLERRM);
    END IF;

    l_message :=
          p_proc_name
       || '{'
       || fnd_number.number_to_canonical(p_proc_step)
       || '}: '
       || SUBSTRB(SQLERRM, 1, 2000);

    IF g_debug
    THEN
      debug(l_message);
    END IF;

    fnd_message.set_name('PQP', 'PQP_230661_OSP_DUMMY_MSG');
    fnd_message.set_token('TOKEN', l_message);

  END debug_others;

--
--
--
-- get_col_value Funciton returns the value of the column ( passed as
-- input parameter ) in the table ( input parameter) for a
-- given Key column and its value. Depending upon the data type
-- of the column the value will be converted and returned in
-- varchar2. A Out parameter message is returned whenever there
-- is a error

  FUNCTION get_col_value(
    p_col_nam                   IN       VARCHAR2
   , -- Col Value to be found
    p_key_val                   IN       NUMBER
   , -- Value of the Key Column
    p_table                     IN       VARCHAR2
   , -- Table Name
    p_key_col                   IN       VARCHAR2
   , -- The Key Column Name
    p_where                     IN       VARCHAR2
   , -- Where Clause in addition if any
    p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_data_type                   fnd_columns.column_type%TYPE;
    l_val                         VARCHAR2(250);
    l_date                        DATE;
    l_num                         NUMBER;
    l_message                     VARCHAR2(250);
    l_proc_name                   VARCHAR2(61)
                                         := g_package_name || 'get_col_value';
    l_select                      VARCHAR2(1000);

    TYPE ref_csr_typ IS REF CURSOR;

    c_column                      ref_csr_typ;
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    p_error_code := 0;
    IF g_debug THEN
      debug(p_col_nam);
      debug(p_key_val);
      debug(p_table);
      debug(p_key_col);
      debug(p_where);
      debug(l_proc_name, 10);
    END IF;
-- Get the Data type of the Column and convert into varchar2
    l_data_type :=
      get_data_type(
        p_col_nam =>                    p_col_nam
       ,p_tab_nam =>                    p_table
       ,p_error_code =>                 p_error_code
       ,p_message =>                    l_message
      );

    IF l_message IS NOT NULL
    THEN
      IF g_debug THEN
        debug(l_proc_name, 30);
      END IF;
      p_message := l_message;
      p_error_code := -1;
      RETURN NULL;
    END IF;

    --
    IF g_debug THEN
      debug(l_proc_name, 40);
    END IF;
    IF g_debug THEN
      debug(' Key Col:' || p_key_col || ' Value : ' || p_key_val);
    END IF;
    --
    l_select :=
          'SELECT '
       || p_col_nam
       || ' FROM '
       || p_table
       || ' WHERE '
       || p_key_col
       || ' = '
       || p_key_val
       || p_where;
    IF g_debug THEN
       debug(l_select);
    END IF;
    OPEN c_column FOR    'SELECT '
                      || p_col_nam
                      || ' FROM '
                      || p_table
                      || ' WHERE '
                      || p_key_col
                      || ' = '
                      || p_key_val
                      || p_where;

    IF l_data_type = 'V'
    THEN
      IF g_debug THEN
        debug(l_proc_name, 40);
      END IF;
      FETCH c_column INTO l_val;
    ELSIF l_data_type = 'D'
    THEN
      IF g_debug THEN
        debug(l_proc_name, 50);
      END IF;
      FETCH c_column INTO l_date;
      l_val := fnd_date.date_to_canonical(l_date);
    ELSIF l_data_type = 'N'
    THEN
      IF g_debug THEN
        debug(l_proc_name, 60);
      END IF;
      FETCH c_column INTO l_num;
      l_val := fnd_number.number_to_canonical(l_num);
    END IF;

    CLOSE c_column;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;
  EXCEPTION
    --
    WHEN NO_DATA_FOUND
    THEN
      IF g_debug THEN
        debug(' No Data Found');
        debug_exit(l_proc_name);
      END IF;
      fnd_message.set_name('PQP', 'PQP_230585_INV_ABS_ID');
      fnd_message.set_token('P_KEY_VAL', p_key_col);
      p_message := fnd_message.get();
      p_error_code := -1;
      RETURN NULL;
-- Added by tmehra for nocopy changes Feb'03

    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      fnd_message.set_name('PQP', 'PQP_230585_INV_ABS_ID');
      fnd_message.set_token('P_KEY_VAL', p_key_col);
      p_message := fnd_message.get();
      p_error_code := -1;
      RETURN NULL;
  --
  END get_col_value;

-- get_data_type function returns the data type of the column name
-- passed as input parameter by fetching it from fnd tables. any
-- errors will be returned in out parameter p_message

  FUNCTION get_data_type(
    p_col_nam                   IN       VARCHAR2
   ,p_tab_nam                   IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_data_type                   fnd_columns.column_type%TYPE;
    l_proc_name                   VARCHAR2(61)
                                         := g_package_name || 'get_data_type';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    p_error_code := 0;
    OPEN csr_data_type(p_tab_nam => p_tab_nam, p_col_nam => p_col_nam);
    FETCH csr_data_type INTO l_data_type;

    IF csr_data_type%NOTFOUND
    THEN
      fnd_message.set_name('PQP', 'PQP_230595_INV_COL_NAME');
      fnd_message.set_token('P_COL_NAME', p_col_nam);
      p_message := fnd_message.get();
      p_error_code := -1;
    END IF;

    CLOSE csr_data_type;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_data_type;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      fnd_message.set_name('PQP', 'PQP_230595_INV_COL_NAME');
      fnd_message.set_token('P_COL_NAME', p_col_nam);
      p_message := fnd_message.get();
      p_error_code := -1;
      RETURN NULL;
  END get_data_type;

-- get_ddf_value function returns the value of the Developers flex filed.
-- The flex filed name, Context,flex filed title are input
-- paramters to identify the flex field.
-- Depending upon the Key Column and its Value the segment value
-- will be identified and returned.

  FUNCTION get_ddf_value(
    p_flex_name                 IN       VARCHAR2
   ,p_flex_context              IN       VARCHAR2
   ,p_flex_field_title          IN       VARCHAR2
   ,p_key_col                   IN       VARCHAR2
   ,p_key_val                   IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_eff_date_req              IN       VARCHAR2
   ,p_business_group_id         IN       NUMBER
   ,p_bus_group_id_req          IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_col_name                    VARCHAR2(30);
    l_val                         VARCHAR2(250);
    l_message                     VARCHAR2(250);
    l_tabname                     VARCHAR2(30);
    l_where                       VARCHAR2(1000);
    l_proc_name                   VARCHAR2(61)
                                         := g_package_name || 'get_ddf_value';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;

    IF g_debug THEN
      debug(p_flex_name);
      debug(p_flex_context);
      debug(p_flex_field_title);
      debug(p_key_col);
      debug(p_key_val);
      debug(p_effective_date);
      debug(p_eff_date_req);
      debug(p_business_group_id);
      debug(p_bus_group_id_req);
    END IF;

    p_error_code := 0;
    -- Get the Column name the field stored in table
    IF g_debug THEN
      debug(l_proc_name, 10);
    END IF;
    l_col_name :=
      pqp_utilities.get_segment_name(
        p_flex_name =>                  p_flex_name
       ,p_flex_field_title =>           p_flex_field_title
       ,p_flex_context =>               p_flex_context
       ,p_tab_nam =>                    l_tabname
       ,p_error_code =>                 p_error_code
       ,p_message =>                    l_message
      );
    IF g_debug THEN
      debug(l_proc_name, 20);
    END IF;

    --
    IF l_message IS NOT NULL
    THEN
      IF g_debug THEN
        debug(l_proc_name, 30);
      END IF;
      p_message := l_message;
      p_error_code := -1;
      RETURN NULL;
    END IF;

    IF g_debug THEN
      debug(l_proc_name, 40);
    END IF;

--
-- If Effective Date Validation is required then Construct the where clause
--
    IF p_eff_date_req = 'Y'
    THEN
      IF g_debug THEN
        debug(l_proc_name, 50);
      END IF;
      l_where :=
            ' AND TO_DATE('''
         || TO_CHAR(p_effective_date, 'DD-MM-YYYY')
         || ''',''DD-MM-YYYY'')'
         || ' BETWEEN effective_start_date
                  AND effective_end_date ';
    END IF;

--
-- If Business Group Validation is required then Construct the where clause
--
    IF p_bus_group_id_req = 'Y'
    THEN
      IF g_debug THEN
        debug(l_proc_name, 60);
      END IF;
      l_where :=
            l_where
         || ' AND ( business_group_id = '
         || TO_CHAR(p_business_group_id)
         || ') ';
    END IF;

    IF g_debug THEN
      debug(l_where);
    END IF;
-- Get the Value of the segment for the given key col and its value.
    IF g_debug THEN
      debug(l_proc_name, 70);
    END IF;
    l_val :=
      pqp_utilities.get_col_value(
        p_col_nam =>                    l_col_name
       ,p_key_val =>                    p_key_val
       ,p_table =>                      l_tabname
       ,p_key_col =>                    p_key_col
       ,p_where =>                      l_where
       ,p_error_code =>                 p_error_code
       ,p_message =>                    l_message
      );
    IF g_debug THEN
      debug(l_proc_name, 30);
    END IF;

    --
    IF l_message IS NOT NULL
    THEN
      IF g_debug THEN
        debug(l_proc_name, 40);
      END IF;
      p_message := l_message;
      p_error_code := -1;
    END IF;

    --
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_message := SQLERRM;
      p_error_code := -1;
      RETURN NULL;
  END get_ddf_value;

-- get_df_value function returns value of the Descriptive Flex Filed.
-- This function identifies the Context based on key column
-- and its value and inturn passes those values to get_ddf_value
-- and gets the segment value. In case of EITs flex context is
-- passed as a parameter.
  FUNCTION get_df_value(
    p_flex_name                 IN       VARCHAR2
   ,p_flex_context              IN       VARCHAR2
   ,p_flex_field_title          IN       VARCHAR2
   ,p_key_col                   IN       VARCHAR2
   ,p_key_val                   IN       VARCHAR2
   ,p_tab_name                  IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_eff_date_req              IN       VARCHAR2
   ,p_business_group_id         IN       NUMBER
   ,p_bus_group_id_req          IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_context                     VARCHAR2(30);
    l_val                         VARCHAR2(250);

    TYPE context_ref_csr_typ IS REF CURSOR;

    c_context                     context_ref_csr_typ;
    l_proc_name                   VARCHAR2(61)
                                          := g_package_name || 'get_df_value';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    p_error_code := 0;

    IF p_flex_context IS NULL
    THEN
      IF g_debug THEN
        debug(l_proc_name, 10);
      END IF;
      OPEN c_context FOR    'SELECT attribute_category FROM '
                         || p_tab_name
                         || ' WHERE '
                         || p_key_col
                         || '='
                         || p_key_val;
      FETCH c_context INTO l_context;
      CLOSE c_context;
      IF g_debug THEN
        debug(l_proc_name, 20);
      END IF;

      IF l_context IS NULL
      THEN
        IF g_debug THEN
          debug(l_proc_name, 30);
        END IF;
        fnd_message.set_name('PQP', 'PQP_230596_NO_FLEX_DATA');
        fnd_message.set_token('FLEX_NAME', p_flex_name);
        p_message := fnd_message.get();
        p_error_code := -1;
        RETURN NULL;
      END IF;
    ELSE
      IF g_debug THEN
        debug(l_proc_name, 40);
      END IF;
      l_context := p_flex_context;
    END IF;

-- Call get_ddf_value to get the value of the segment.
    IF g_debug THEN
      debug(l_proc_name, 50);
    END IF;
    l_val :=
      pqp_utilities.get_ddf_value(
        p_flex_name =>                  p_flex_name
       ,p_flex_context =>               l_context
       ,p_flex_field_title =>           p_flex_field_title
       ,p_key_col =>                    p_key_col
       ,p_key_val =>                    p_key_val
       ,p_effective_date =>             p_effective_date
       ,p_eff_date_req =>               p_eff_date_req
       ,p_business_group_id =>          p_business_group_id
       ,p_bus_group_id_req =>           p_bus_group_id_req
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );
    IF g_debug THEN
      debug(l_val);
    END IF;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_message := SQLERRM;
      p_error_code := -1;
      RETURN NULL;
  END get_df_value;

-- get_segment_name function returns the column Name the flex
--  filed is mapped to.
  FUNCTION get_segment_name(
    p_flex_name                 IN       VARCHAR2
   ,p_flex_field_title          IN       VARCHAR2
   ,p_flex_context              IN       VARCHAR2
   ,p_tab_nam                   OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_col_name                    VARCHAR2(30);
    l_proc_name                   VARCHAR2(61)
                                      := g_package_name || 'get_segment_name';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    p_error_code := 0;
    --
    OPEN csr_seg_name(
          p_flex_name =>                  p_flex_name
         ,p_flex_context =>               p_flex_context
         ,p_flex_field_title =>           p_flex_field_title
                     );
    FETCH csr_seg_name INTO l_col_name;

    --
    IF csr_seg_name%NOTFOUND
    THEN
      fnd_message.set_name('PQP', 'PQP_230597_INV_SEG_NAME');
      fnd_message.set_token('FLEX_TITLE', p_flex_field_title);
      p_message := fnd_message.get();
      p_error_code := -1;
      CLOSE csr_seg_name;
      IF g_debug THEN
        debug(l_proc_name || p_message);
      END IF;
      RETURN NULL;
    END IF;

    --
    CLOSE csr_seg_name;
    --
    --
    OPEN csr_tab_name(p_flex_name => p_flex_name);
    FETCH csr_tab_name INTO p_tab_nam;
    CLOSE csr_tab_name;
    --
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_col_name;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_message := SQLERRM;
      p_error_code := -1;
      RETURN NULL;
  END get_segment_name;

-- Function to get Concatenated String from the View

  FUNCTION pqp_get_concat_value(
    p_key_col                   IN       VARCHAR2
   ,p_key_val                   IN       VARCHAR2
   ,p_tab_name                  IN       VARCHAR2
   ,p_view_name                 IN       VARCHAR2
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    TYPE rowid_ref_csr_typ IS REF CURSOR;

    c_rowid                       rowid_ref_csr_typ;
    c_view                        rowid_ref_csr_typ;
    l_rowid                       VARCHAR2(30);
    l_concat_string               VARCHAR2(2000);
    l_proc_name                   VARCHAR2(61)
                                  := g_package_name || 'pqp_get_concat_value';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    OPEN c_rowid FOR    ' SELECT rowid FROM '
                     || p_tab_name
                     || ' WHERE '
                     || p_key_col
                     || ' = '
                     || p_key_val;
    FETCH c_rowid INTO l_rowid;
    CLOSE c_rowid;
    OPEN c_view FOR    ' SELECT concatenated_segments
         FROM '
                    || p_view_name
                    || ' WHERE row_id = '
                    || ''''
                    || l_rowid
                    || '''';
    FETCH c_view INTO l_concat_string;
    CLOSE c_view;
    IF g_debug THEN
      debug(l_concat_string);
    END IF;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_concat_string;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_message := SQLERRM;
      RETURN NULL;
  END pqp_get_concat_value;

-- If Multiple occurances is allowed in EIT then the below function
-- is called which returns the Row Count
  FUNCTION pqp_get_extra_element_mult(
    p_flex_name                 IN       VARCHAR2
   , -- Extra Element Info DDF
    p_segment_name              IN       VARCHAR2
   , -- segment name
    p_flex_context              IN       VARCHAR2
   , -- information_type
    p_element_type_id           IN       NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_col_name                    VARCHAR2(30);
    l_tab_name                    VARCHAR2(30);
    l_rowcount                    NUMBER;
    l_col_value                   VARCHAR2(250);
    l_error_code                  NUMBER;

    TYPE col_value_ref_csr_typ IS REF CURSOR;

    c_value                       col_value_ref_csr_typ;
    l_proc_name                   VARCHAR2(61)
                            := g_package_name || 'pqp_get_extra_element_mult';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    l_col_name :=
      pqp_utilities.get_segment_name(
        p_flex_name =>                  p_flex_name
       ,p_flex_field_title =>           p_segment_name
       ,p_flex_context =>               p_flex_context
       ,p_tab_nam =>                    l_tab_name
       ,p_error_code =>                 l_error_code
       ,p_message =>                    p_message
      );

    IF p_message IS NOT NULL
    THEN
      RETURN 0;
    END IF;

    OPEN c_value FOR    ' SELECT '
                     || l_col_name
                     || ' FROM
                     pay_element_type_extra_info WHERE
                     information_type ='
                     || ''''
                     || p_flex_context
                     || ''''
                     || ' AND element_type_id ='
                     || p_element_type_id;

    LOOP
      FETCH c_value INTO l_col_value;
      EXIT WHEN c_value%NOTFOUND;
    END LOOP;

    l_rowcount := c_value%ROWCOUNT;
    CLOSE c_value;
    IF g_debug THEN
      debug(l_rowcount);
    END IF;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_rowcount;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_message := SQLERRM;
      RETURN 0;
  END pqp_get_extra_element_mult;

-- pqp_get_extra_element_info Returns the value of the Element EIT
-- ( Extra Element Info DDF).
-- Retunrs -1 if any error,0 if successful and rowcount in case of
-- multiple occurances flag true
  FUNCTION pqp_get_extra_element_info(
    p_element_type_id           IN       NUMBER
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_mult_occ_flag               VARCHAR2(30);
    l_rowcount                    NUMBER;
    l_error_code                  fnd_new_messages.message_number%TYPE;

    l_element_type_extra_info_id
           pay_element_type_extra_info.element_type_extra_info_id%TYPE ;

    CURSOR csr_get_extra_info_id
      (p_element_type_id NUMBER
      ,p_information_type VARCHAR2
      ) IS
    SELECT element_type_extra_info_id
      FROM pay_element_type_extra_info
     WHERE element_type_id  = p_element_type_id
       AND information_type = p_information_type;

    l_proc_name                   VARCHAR2(61)
                            := g_package_name || 'pqp_get_extra_element_info';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    OPEN csr_mult_occur(p_information_type => p_information_type);
    FETCH csr_mult_occur INTO l_mult_occ_flag;

    --
    IF csr_mult_occur%NOTFOUND
    THEN
      IF g_debug THEN
        debug(l_proc_name,15);
      END IF;
      p_error_msg :=
                    fnd_message.get_string('PQP', 'PQP_230602_INV_INFO_TYPE');
      CLOSE csr_mult_occur;
      RETURN -1;
    END IF;

    --
    CLOSE csr_mult_occur;

    IF g_debug THEN
      debug(l_proc_name,20);
    END IF;

    --
    IF l_mult_occ_flag = 'N'
    THEN

       -- Added for Multiple Contexts for Same element
      OPEN csr_get_extra_info_id
        (p_element_type_id => p_element_type_id,
        p_information_type => p_information_type);
      FETCH csr_get_extra_info_id INTO l_element_type_extra_info_id;
      CLOSE csr_get_extra_info_id;

      p_value :=
        pqp_utilities.get_ddf_value(
          p_flex_name =>                  'Extra Element Info DDF'
         ,p_flex_context =>               p_information_type
         ,p_flex_field_title =>           p_segment_name
         ,p_key_col =>                    'ELEMENT_TYPE_EXTRA_INFO_ID'
         ,p_key_val =>                    l_element_type_extra_info_id
         ,p_effective_date =>             NULL
         ,p_eff_date_req =>               'N'
         ,p_business_group_id =>          NULL
         ,p_bus_group_id_req =>           'N'
         ,p_error_code =>                 l_error_code
         ,p_message =>                    p_error_msg
        );

      IF LENGTH(p_value) > 250
      THEN
        p_value := SUBSTR(p_value, 1, 250);
        p_truncated_yes_no := 'Y';
      ELSE
        p_truncated_yes_no := 'N';
      END IF;

      IF g_debug THEN
        debug(p_error_msg);
        debug_exit(l_proc_name);
      END IF;

      --
      --
      IF p_error_msg IS NOT NULL
      THEN
        RETURN -1;
      ELSE
        RETURN 0;
      END IF;
    --
    ELSE
      --
      l_rowcount :=
        pqp_utilities.pqp_get_extra_element_mult(
          p_flex_name =>                  'Extra Element Info DDF'
         ,p_segment_name =>               p_segment_name
         ,p_flex_context =>               p_information_type
         ,p_element_type_id =>            p_element_type_id
         ,p_message =>                    p_error_msg
        );
      IF g_debug THEN
        debug_exit(l_proc_name);
      END IF;
      RETURN l_rowcount;
    --
    END IF;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_error_msg := SQLERRM;
      p_value := NULL;
      p_truncated_yes_no := NULL;
      RETURN -1;
  --
  END pqp_get_extra_element_info;

-- pqp_get_extra_element_info_det Returns the value of segment
-- passed as input to the Descriptive Flex Field Extra Element Info
-- Details DF
  FUNCTION pqp_get_extra_element_info_det(
    p_element_type_id           IN       NUMBER
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_mult_occ_flag               VARCHAR2(1);
    l_rowcount                    NUMBER;
    l_proc_name                   VARCHAR2(61)
                        := g_package_name || 'pqp_get_extra_element_info_det';
    l_error_code                  NUMBER;
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    --
    OPEN csr_mult_occur(p_information_type => p_information_type);
    IF g_debug THEN
      debug(l_proc_name, 10);
    END IF;
    FETCH csr_mult_occur INTO l_mult_occ_flag;

    IF csr_mult_occur%NOTFOUND
    THEN
      p_error_msg :=
                    fnd_message.get_string('PQP', 'PQP_230602_INV_INFO_TYPE');
      CLOSE csr_mult_occur;
      RETURN -1;
    END IF;

    CLOSE csr_mult_occur;

    --

    IF l_mult_occ_flag = 'N'
    THEN                              --single occurance. treat as a simple DF
         --
      IF g_debug THEN
        debug(l_proc_name, 20);
      END IF;
      p_value :=
        pqp_utilities.get_df_value(
          p_flex_name =>                  'Extra Element Info Details DF'
         ,p_flex_context =>               'PQP_LEG_CODE'
         , --p_information_type,
          p_flex_field_title =>           p_segment_name
         ,p_key_col =>                    'ELEMENT_TYPE_ID'
         ,p_key_val =>                    p_element_type_id
         ,p_tab_name =>                   'PAY_ELEMENT_TYPE_EXTRA_INFO'
         ,p_effective_date =>             NULL
         ,p_eff_date_req =>               'N'
         ,p_business_group_id =>          NULL
         ,p_bus_group_id_req =>           'N'
         ,p_error_code =>                 l_error_code
         ,p_message =>                    p_error_msg
        );

      IF LENGTH(p_value) > 250
      THEN
        p_value := SUBSTR(p_value, 1, 250);
        p_truncated_yes_no := 'Y';
      ELSE
        p_truncated_yes_no := 'N';
      END IF;

      --
      IF g_debug THEN
        debug_exit(l_proc_name);
      END IF;

      IF p_error_msg IS NOT NULL
      THEN
        IF g_debug THEN
          debug(p_error_msg);
        END IF;
        RETURN -1;
      ELSE
        RETURN 0;
      END IF;
     --
    --
    ELSE     -- multiple occurances call the function to get Rowcount.
         --
      IF g_debug THEN
        debug(l_proc_name, 30);
      END IF;
      l_rowcount :=
        pqp_utilities.pqp_get_extra_element_mult(
          p_flex_name =>                  'Extra Element Info Details DF'
         ,p_segment_name =>               p_segment_name
         ,p_flex_context =>               p_information_type
         ,p_element_type_id =>            p_element_type_id
         ,p_message =>                    p_error_msg
        );

      --

      IF p_error_msg IS NOT NULL
      THEN
        IF g_debug THEN
          debug(p_error_msg);
        END IF;
        IF g_debug THEN
          debug_exit(l_proc_name);
        END IF;
        RETURN -1;
      ELSE
        IF g_debug THEN
          debug(l_rowcount);
        END IF;
        IF g_debug THEN
         debug_exit(l_proc_name);
        END IF;
        RETURN l_rowcount;
      END IF;
      --
    --
    END IF;
  --
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_error_msg := SQLERRM;
      p_value := NULL;
      p_truncated_yes_no := NULL;
      RETURN -1;
  END pqp_get_extra_element_info_det;

-- Function to get Element type id for a given Element Name
  FUNCTION pqp_get_element_type_id(
    p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_element_type_name         IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_element_type_id             pay_element_types_f.element_type_id%TYPE;
    l_proc_name                   VARCHAR2(61)
                               := g_package_name || 'pqp_get_element_type_id';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    p_error_code := 0;
    --
    OPEN csr_element_type(
          p_element_type_name =>          p_element_type_name
         ,p_effective_date =>             p_effective_date
         ,p_business_group_id =>          p_business_group_id
         ,p_legislation_code =>           p_legislation_code
                         );
    FETCH csr_element_type INTO l_element_type_id;

    IF csr_element_type%NOTFOUND
    THEN
      p_message := fnd_message.get_string('PQP', 'PQP_230601_INV_ELE_NAME');
      p_error_code := -1;
    END IF;

    CLOSE csr_element_type;
    --
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_element_type_id;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_message := SQLERRM;
      p_error_code := -1;
      RETURN NULL;
  END pqp_get_element_type_id;

-- function to get segment value for a given element name. function is
-- same as pqp_get_extra_element_info but takes input element name
  FUNCTION pqp_get_element_extra_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_element_type_name         IN       VARCHAR2
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_element_type_id             pay_element_types_f.element_type_id%TYPE;
    l_retval                      NUMBER;
    l_error_code                  NUMBER;
    l_proc_name                   VARCHAR2(61)
                            := g_package_name || 'pqp_get_element_extra_info';
    l_legislation_code            per_business_groups.legislation_code%TYPE;
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    IF g_debug THEN
      debug(l_proc_name, 10);
    END IF;
    l_legislation_code :=
      pqp_utilities.pqp_get_legislation_code(p_business_group_id => p_business_group_id);
    IF g_debug THEN
      debug('l_legislation_code:' || l_legislation_code);
    END IF;
    IF g_debug THEN
      debug('p_element_type_name:' || p_element_type_name);
    END IF;
    l_element_type_id :=
      pqp_utilities.pqp_get_element_type_id(
        p_business_group_id =>          p_business_group_id
       ,p_legislation_code =>           l_legislation_code
       ,p_effective_date =>             p_effective_date
       ,p_element_type_name =>          p_element_type_name
       ,p_error_code =>                 l_error_code
       ,p_message =>                    p_error_msg
      );

    IF p_error_msg IS NOT NULL
    THEN
      RETURN -1;
    END IF;

    IF g_debug THEN
      debug('l_element_type_id:' || l_element_type_id);
    END IF;
    l_retval :=
      pqp_get_extra_element_info(
        p_element_type_id =>            l_element_type_id
       ,p_information_type =>           p_information_type
       ,p_segment_name =>               p_segment_name
       ,p_value =>                      p_value
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_msg =>                  p_error_msg
      );
    IF g_debug THEN
      debug(l_retval);
    END IF;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_error_msg := SQLERRM;
      p_value := NULL;
      p_truncated_yes_no := NULL;
      RETURN -1;
  END pqp_get_element_extra_info;

-- function to get segment value for a given element name. function is
-- same as pqp_get_extra_element_info_det but takes input element name
  FUNCTION pqp_get_element_extra_info_det(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_element_type_name         IN       VARCHAR2
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_element_type_id             pay_element_types_f.element_type_id%TYPE;
    l_retval                      NUMBER;
    l_proc_name                   VARCHAR2(61)
                        := g_package_name || 'pqp_get_element_extra_info_det';
    l_legislation_code            per_business_groups.legislation_code%TYPE;
    l_error_code                  NUMBER;
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    --
    IF g_debug THEN
      debug(l_proc_name, 10);
    END IF;
    l_legislation_code :=
      pqp_utilities.pqp_get_legislation_code(p_business_group_id => p_business_group_id);
    IF g_debug THEN
      debug(' Legislation Code :' || l_legislation_code, 20);
    END IF;
    --
    debug(' pqp_utilities.pqp_get_element_type_id ' || p_element_type_name
     ,30);
    l_element_type_id :=
      pqp_utilities.pqp_get_element_type_id(
        p_business_group_id =>          p_business_group_id
       ,p_legislation_code =>           l_legislation_code
       ,p_effective_date =>             p_effective_date
       ,p_element_type_name =>          p_element_type_name
       ,p_error_code =>                 l_error_code
       ,p_message =>                    p_error_msg
      );
    IF g_debug THEN
      debug(' The Element type Id is ' || l_element_type_id, 40);
    END IF;
    IF g_debug THEN
      debug(' Calling pqp_utilities.pqp_get_extra_element_info_det');
    END IF;
    l_retval :=
      pqp_get_extra_element_info_det(
        p_element_type_id =>            l_element_type_id
       ,p_information_type =>           p_information_type
       ,p_segment_name =>               p_segment_name
       ,p_value =>                      p_value
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_msg =>                  p_error_msg
      );
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_error_msg := SQLERRM;
      p_value := NULL;
      p_truncated_yes_no := NULL;
      RETURN -1;
  END pqp_get_element_extra_info_det;

-- This function is to get the value of a column from User Defined Tables.
-- Calls type1 function and handles the exceptions and returns.If any
-- errors retunrs -1 and if success returns 0

FUNCTION pqp_gb_get_table_value(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_table_name                IN       VARCHAR2
   ,p_column_name               IN       VARCHAR2
   ,p_row_name                  IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   , --Value
    p_error_msg                 OUT NOCOPY VARCHAR2
   ,p_refresh_cache             IN         VARCHAR2   DEFAULT 'N'
  ) -- Error if any
    RETURN NUMBER
  IS
    l_proc_name                   VARCHAR2(61)
                                := g_package_name || 'pqp_gb_get_table_value';
    l_col_in_cache            BOOLEAN:= FALSE;
    l_table_in_cache           BOOLEAN:= FALSE;
    l_err_msg                   VARCHAR2(100);
    i NUMBER ;
    j NUMBER ;
  BEGIN
    --
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id',p_business_group_id );
      debug('p_effective_date'||p_effective_date );
      debug('p_table_name'||p_table_name );
      debug('p_column_name'||p_column_name );
      debug('p_row_name'||p_row_name );
      debug('p_refresh_cache'||p_refresh_cache );

    END IF;

    --

j := g_cached_tbls.FIRST ;

   WHILE j IS NOT NULL LOOP
	IF g_cached_tbls(j).table_name = p_table_name
	   AND g_cached_tbls(j).column_name = p_column_name
	THEN
           IF g_debug THEN
             debug(l_proc_name,5);
           END IF;

           IF p_refresh_cache = 'Y' THEN
              debug(l_proc_name,15);
	      g_cached_tbls.DELETE(j);
              l_col_in_cache := FALSE;
	         delete_udt_value
	         (p_table_name => p_table_name
		 ,p_column_name => p_column_name
		 ,p_error_msg  => l_err_msg
                );
            ELSE
              l_col_in_cache := TRUE;
	    END IF;
            EXIT;
        END IF;
	j := g_cached_tbls.NEXT(j);
    END LOOP;


    IF NOT l_col_in_cache
    THEN
      IF g_debug THEN
        debug(l_proc_name, 20);
      END IF;
      pqp_utilities.get_udt_data
       (p_business_group_id =>          p_business_group_id
       ,p_udt_name =>                   p_table_name
       ,p_effective_date =>             p_effective_date
       ,p_column_name  =>               p_column_name
       ,p_error_msg =>                  p_error_msg
       );

       i := g_cached_tbls.COUNT + 1;
       g_cached_tbls(i).table_name  := p_table_name ;
       g_cached_tbls(i).column_name := p_column_name ;
    END IF;

    --
    IF g_debug THEN
      debug(l_proc_name, 30);
    END IF;

    p_value :=
      pqp_utilities.get_udt_value(
        p_table_name =>                 p_table_name
       ,p_column_name =>                p_column_name
       ,p_row_name =>                   p_row_name
       ,p_effective_date =>             p_effective_date
       ,p_business_group_id =>          p_business_group_id
      );
--
--    p_value := hruserdt.get_table_value
--                        (p_bus_group_id   => p_business_group_id,
--                         p_table_name     => p_table_name,
--                         p_col_name       => p_column_name,
--                         p_row_value      => p_row_name,
--                         p_effective_date => p_effective_date ) ;
--
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN 0;
  --
  EXCEPTION
    --
    WHEN OTHERS
    THEN
      p_error_msg := SQLERRM;
      IF g_debug THEN
        debug_exit(l_proc_name || ' ' || ' When Others ');
      END IF;
-- Added by tmehra for nocopy changes
      p_value := NULL;
      RETURN -1;
  --
  END pqp_gb_get_table_value;

---------------

 PROCEDURE delete_udt_value(
    p_table_name    IN         VARCHAR2
   ,p_column_name   IN         VARCHAR2 DEFAULT 'ALL'
   ,p_error_msg     OUT NOCOPY VARCHAR2
   )
  IS
    l_proc_name       VARCHAR2(60)
                           := g_package_name || 'delete_udt_data';
    i NUMBER;
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_table_name' || p_table_name);
    END IF;

    i := g_udt_rec.FIRST ;

    WHILE i IS NOT NULL LOOP

       IF     ((g_udt_rec(i).table_name = p_table_name AND g_udt_rec(i).column_name = p_column_name ) OR
                   (g_udt_rec(i).table_name = p_table_name AND p_column_name ='ALL'))
        THEN
          IF g_debug THEN
            debug('------------------------------------------------------');
            debug('|'||g_udt_rec(i).table_name||'|'||
	    g_udt_rec(i).column_name ||'|'||g_udt_rec(i).row_name ||'|'||
	    g_udt_rec(i).row_high_range||'|'||g_udt_rec(i).start_date ||'|'||
	    g_udt_rec(i).end_date||'|'||g_udt_rec(i).matrix_value ||'|') ;
          END IF;
          g_udt_rec.DELETE(i);
       END IF ;
	i := g_udt_rec.NEXT(i);
    END LOOP ;


    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;

   EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_error_msg := SQLERRM;
      RAISE;
   END delete_udt_value;

-- Function get_table_value_id  gets the value of a column from
-- User Defined Tables.First Table Name is fetched and passed to
-- pqp_gb_get_table_value to get the Value.
  FUNCTION pqp_gb_get_table_value_id(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_row_name                  IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_name                   VARCHAR2(61)
                             := g_package_name || 'pqp_gb_get_table_value_id';
    l_table_name                  pay_user_tables.user_table_name%TYPE;
    l_retval                      NUMBER;
  BEGIN
    --
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    --
    OPEN csr_table_id(p_table_id => p_table_id);
    FETCH csr_table_id INTO l_table_name;
    CLOSE csr_table_id;
     --
    --
    l_retval :=
      pqp_utilities.pqp_gb_get_table_value(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_table_name =>                 l_table_name
       ,p_column_name =>                p_column_name
       ,p_row_name =>                   p_row_name
       ,p_value =>                      p_value
       ,p_error_msg =>                  p_error_msg
      );
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_error_msg := SQLERRM;
      p_value := NULL;
      RETURN NULL;
  END pqp_gb_get_table_value_id;

-- pqp_get_legislation_code Returns the legislation code for a
-- Business Group Id.
  FUNCTION pqp_get_legislation_code(p_business_group_id IN NUMBER)
    RETURN VARCHAR2
  IS
    l_proc_name                   VARCHAR2(61)
                              := g_package_name || 'pqp_get_legislation_code';
    l_legislation_code            VARCHAR2(30);
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    --
    OPEN csr_leg_code(p_business_group_id => p_business_group_id);
    FETCH csr_leg_code INTO l_legislation_code;
    CLOSE csr_leg_code;
    --
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_legislation_code;
  END pqp_get_legislation_code;

-- get_udt_data Caches the Values of UDT.
PROCEDURE get_udt_data(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_udt_name                  IN       VARCHAR2
   ,p_column_name               IN       VARCHAR2 DEFAULT 'ALL'
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
  IS
    CURSOR csr_get_table_id(p_udt_name IN VARCHAR2)
    IS
      SELECT tbls.user_table_id
      FROM   pay_user_tables tbls
      WHERE  tbls.user_table_name = p_udt_name
      AND    (
                 (business_group_id IS NULL AND legislation_code IS NULL)
              OR (legislation_code IS NOT NULL AND legislation_code = 'GB')
              OR (
                      business_group_id IS NOT NULL
                  AND business_group_id = p_business_group_id
                 )
             );

      CURSOR csr_get_col_name(p_user_table_id IN NUMBER
                            ,p_user_column_name IN VARCHAR2)
      IS
      SELECT   user_column_id
              ,user_column_name
      FROM     pay_user_columns
      WHERE    user_table_id    = p_user_table_id
      AND      user_column_name like p_user_column_name
      AND      (
                   (business_group_id IS NULL AND legislation_code IS NULL)
                OR (legislation_code IS NOT NULL AND legislation_code = 'GB')
                OR (
                        business_group_id IS NOT NULL
                    AND business_group_id = p_business_group_id
                   )
               )
      ORDER BY user_column_id;

    CURSOR csr_get_row_name(
      p_user_table_id             IN       NUMBER
     ,p_effective_date            IN       DATE
    )
    IS
      SELECT   user_row_id
              ,row_low_range_or_name
              ,row_high_range
      FROM     pay_user_rows_f
      WHERE    user_table_id = p_user_table_id
      AND      TRUNC(p_effective_date) BETWEEN effective_start_date
                                           AND effective_end_date
      AND      (
                   (business_group_id IS NULL AND legislation_code IS NULL)
                OR (legislation_code IS NOT NULL AND legislation_code = 'GB')
                OR (
                        business_group_id IS NOT NULL
                    AND business_group_id = p_business_group_id
                   )
               )
      ORDER BY display_sequence;

    CURSOR csr_get_matrix_value(
      p_user_column_id            IN       NUMBER
     ,p_user_row_id               IN       NUMBER
    )
    IS
      SELECT VALUE
            ,effective_start_date
            ,effective_end_date
      FROM   pay_user_column_instances_f
      WHERE  user_column_id = p_user_column_id
      AND    user_row_id = p_user_row_id
      AND    (
                 (business_group_id IS NULL AND legislation_code IS NULL)
              OR (legislation_code IS NOT NULL AND legislation_code = 'GB')
              OR (
                      business_group_id IS NOT NULL
                  AND business_group_id = p_business_group_id
                 )
             );

    l_user_column_name            pay_user_columns.user_column_name%TYPE;
    l_user_row_name               pay_user_rows_f.row_low_range_or_name%TYPE;
    l_matrix_value                pay_user_column_instances_f.VALUE%TYPE;
    l_user_table_id               pay_user_tables.user_table_id%TYPE;
    l_user_column_id              pay_user_columns.user_column_id%TYPE;
    l_user_row_id                 pay_user_rows_f.user_row_id%TYPE;
    l_idx                         NUMBER;
    l_proc_name                   VARCHAR2(60)
                                           := g_package_name || 'get_udt_data';
    l_row_high_range              pay_user_rows_f.row_high_range%TYPE;
    l_column_name                 VARCHAR2(240);
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_column_name '||p_column_name);
    END IF;
    OPEN csr_get_table_id(p_udt_name => p_udt_name);
    FETCH csr_get_table_id INTO l_user_table_id;
    CLOSE csr_get_table_id;

    IF g_udt_rec.EXISTS(1)
    THEN
      IF g_debug THEN
        debug(l_proc_name, 10);
      END IF;
      l_idx := g_udt_rec.LAST + 1;
    ELSE
      IF g_debug THEN
        debug(l_proc_name, 30);
      END IF;
      l_idx := 1;
    END IF;

    IF p_column_name = 'ALL' THEN
       l_column_name :='%';
    ELSE
       l_column_name :=p_column_name;
    END IF;

    FOR i IN csr_get_col_name(p_user_table_id => l_user_table_id
                              ,p_user_column_name => l_column_name )
    LOOP
      l_user_column_id := i.user_column_id;
      l_user_column_name := i.user_column_name;

      FOR j IN csr_get_row_name(
                p_user_table_id =>              l_user_table_id
               ,p_effective_date =>             p_effective_date
              )
      LOOP
        l_user_row_id := j.user_row_id;
        l_user_row_name := j.row_low_range_or_name;
        l_row_high_range := j.row_high_range;

        FOR k IN csr_get_matrix_value(
                  p_user_column_id =>             l_user_column_id
                 ,p_user_row_id =>                l_user_row_id
                )
        LOOP
          g_udt_rec(l_idx).table_name := p_udt_name; -- comment
          g_udt_rec(l_idx).column_name := l_user_column_name;
          g_udt_rec(l_idx).row_name := l_user_row_name;
          g_udt_rec(l_idx).row_high_range := l_row_high_range;
          g_udt_rec(l_idx).matrix_value := k.VALUE;
          g_udt_rec(l_idx).start_date := TRUNC(k.effective_start_date);
          g_udt_rec(l_idx).end_date := TRUNC(k.effective_end_date);
          IF g_debug THEN
            debug('------------------------------------------------------');
            debug('|'||g_udt_rec(l_idx).table_name||'|'||
	    g_udt_rec(l_idx).column_name ||'|'||g_udt_rec(l_idx).row_name ||'|'||
	    g_udt_rec(l_idx).row_high_range||'|'||g_udt_rec(l_idx).start_date ||'|'||
	    g_udt_rec(l_idx).end_date||'|'||g_udt_rec(l_idx).matrix_value ||'|') ;
          END IF;
          l_idx := l_idx + 1;
          l_matrix_value := NULL;
        END LOOP;

        l_user_row_name := NULL;
      END LOOP;
    END LOOP;

    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_error_msg := SQLERRM;
      RAISE;
  END get_udt_data;

-- get_udt_value gets the value from the cache ( the values are cached in
-- procedure get_udt_data) depending upon whether its Match or Range.
  FUNCTION get_udt_value(
    p_table_name                IN       VARCHAR2
   ,p_column_name               IN       VARCHAR2
   ,p_row_name                  IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_business_group_id         IN       NUMBER
  )
    RETURN VARCHAR2
  IS
    CURSOR csr_get_range_match(p_table_name IN VARCHAR2)
    IS
      SELECT udt.range_or_match
      FROM   pay_user_tables udt
      WHERE  user_table_name = p_table_name;

    l_range_match                 csr_get_range_match%ROWTYPE;
    l_return_value                pay_user_column_instances_f.VALUE%TYPE;
    l_proc_name                   VARCHAR2(70)
                                          := g_package_name || 'get_udt_value';
   i NUMBER;
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    OPEN csr_get_range_match(p_table_name => p_table_name);
    FETCH csr_get_range_match INTO l_range_match;
    CLOSE csr_get_range_match;

    -- Check the value in the cached PL/SQL record table for the given
    -- effective date

     i := g_udt_rec.FIRST ;

    WHILE i IS NOT NULL LOOP
      IF     l_range_match.range_or_match = 'R'
         AND g_udt_rec(i).table_name = p_table_name
         AND g_udt_rec(i).column_name = p_column_name
         AND (
              fnd_number.canonical_to_number(p_row_name)
                BETWEEN fnd_number.canonical_to_number(g_udt_rec(i).row_name)
                    AND fnd_number.canonical_to_number(g_udt_rec(i).row_high_range)
             )
         AND (
              p_effective_date BETWEEN g_udt_rec(i).start_date
                                   AND g_udt_rec(i).end_date
             )
      THEN
        l_return_value := g_udt_rec(i).matrix_value;
        EXIT;
      ELSE
        IF     l_range_match.range_or_match = 'M'
           AND g_udt_rec(i).table_name = p_table_name
           AND g_udt_rec(i).column_name = p_column_name
           AND (
                p_effective_date BETWEEN g_udt_rec(i).start_date
                                     AND g_udt_rec(i).end_date
               )
           AND p_row_name = g_udt_rec(i).row_name
        THEN
          l_return_value := g_udt_rec(i).matrix_value;
          EXIT;
        END IF;
      END IF;
	i := g_udt_rec.NEXT(i);
    END LOOP;

    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_return_value;
  END get_udt_value;


-- Function to Set Trace on. This is a wrapper around hr_utility.trace_on
-- Procedure.
  FUNCTION set_trace_on(
    p_trace_destination         IN       VARCHAR2
   ,p_trace_coverage            IN       VARCHAR2
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
  BEGIN
    hr_utility.trace_on(
      trace_mode =>                   p_trace_coverage
     ,session_identifier =>           p_trace_destination
    );
    RETURN 0;
  EXCEPTION
    WHEN OTHERS
    THEN
      p_error_message := SQLERRM;
      RETURN -1;
  END set_trace_on;

-- Function to Start Trace and Pipe Name will be Concurrent Request Id.
  FUNCTION set_request_trace_on(p_error_message OUT NOCOPY VARCHAR2)
    RETURN NUMBER
  IS
  BEGIN
    hr_utility.trace_on(trace_mode => 'F', session_identifier => 'REQID');
    RETURN 0;
  EXCEPTION
    WHEN OTHERS
    THEN
      p_error_message := SQLERRM;
      RETURN -1;
  END set_request_trace_on;

-- Function to Set Trace off. A Wrapper for hr_utility.trace_off.
  FUNCTION set_trace_off(p_error_message OUT NOCOPY VARCHAR2)
    RETURN NUMBER
  IS
    l_trace_status                NUMBER := 0;
  BEGIN
    hr_utility.trace_off;
    RETURN l_trace_status;
  EXCEPTION
    WHEN OTHERS
    THEN
      p_error_message := SQLERRM;
      RETURN -1;
  END set_trace_off;

-- function returns the values of the look up code which is the column name
-- related to the prompt defined in lookup
  FUNCTION get_lookup_code(
    p_lookup_type               IN       VARCHAR2
   ,p_lookup_meaning            IN       VARCHAR2
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_lookup_code                 fnd_lookup_values_vl.lookup_code%TYPE;
    l_proc_name                   VARCHAR2(61)
                                       := g_package_name || 'get_lookup_code';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    OPEN csr_lookup_code(
          p_lookup_type =>                p_lookup_type
         ,p_lookup_meaning =>             p_lookup_meaning
                        );
    FETCH csr_lookup_code INTO l_lookup_code;

    --
    IF csr_lookup_code%NOTFOUND
    THEN
      fnd_message.set_name('PQP', 'PQP_230598_INV_TITLE');
      fnd_message.set_token('LKUP_MEANING', p_lookup_meaning);
      p_message := fnd_message.get();
    END IF;

    --
    CLOSE csr_lookup_code;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_lookup_code;
-- Added by tmehra for nocopy changes Feb'03

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_message := SQLERRM;
      RETURN NULL;
  END get_lookup_code;

--delete_formula
-- function to delete a given formula completly
-- It will delete the compiled information
-- and drop all the assocciated packages also.
-- This function has been made by merging the code
-- from the template del_formulas and drop_formula_packages
-- procedures.
  PROCEDURE delete_formula(
    p_formula_id                IN       NUMBER
   ,p_drop_compiled_info        IN       BOOLEAN
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
  IS
    CURSOR csr_package_names
    IS
      SELECT object_name
      FROM   user_objects
      WHERE  object_name LIKE 'FFP' || TO_CHAR(p_formula_id) || '_%'
      AND    object_type = 'PACKAGE';

    l_package_name                user_objects.object_name%TYPE;
    l_proc_name                   VARCHAR2(61)
                                         := g_package_name || 'delete_formula';
    l_formula_rowid               ROWID;
    l_return_code                 NUMBER := 0;
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    p_error_code := 0;
    p_error_message := NULL;

    SELECT ROWID
    INTO   l_formula_rowid
    FROM   ff_formulas_f
    WHERE  formula_id = p_formula_id;

    IF g_debug THEN
      debug(l_proc_name, 20);
    END IF;

    --
    -- Delete the compiled information and usages table rows before the
    -- formula row.
    --
    DELETE FROM ff_compiled_info_f
    WHERE       formula_id = p_formula_id;

    IF g_debug THEN
      debug(l_proc_name, 30);
    END IF;

    --
    DELETE FROM ff_fdi_usages_f
    WHERE       formula_id = p_formula_id;

    IF g_debug THEN
      debug(l_proc_name, 40);
    END IF;
    --
    ff_formulas_f_pkg.delete_row(
      x_rowid =>                      l_formula_rowid
     ,x_formula_id =>                 p_formula_id
     ,x_dt_delete_mode =>             'ZAP'
     ,x_validation_start_date =>      hr_api.g_sot
     ,x_validation_end_date =>        hr_api.g_eot
    );
    IF g_debug THEN
      debug(l_proc_name, 50);
    END IF;

    --
    IF p_drop_compiled_info
    THEN
      IF g_debug THEN
        debug(l_proc_name, 60);
      END IF;
      OPEN csr_package_names;

      LOOP
        IF g_debug THEN
          debug(l_proc_name, 65);
        END IF;
        FETCH csr_package_names INTO l_package_name;
        EXIT WHEN csr_package_names%NOTFOUND;
        --
        -- Drop the package.
        --
        IF g_debug THEN
          debug(l_proc_name, 70);
        END IF;
        EXECUTE IMMEDIATE 'DROP PACKAGE ' || l_package_name;
        IF g_debug THEN
          debug(l_proc_name, 75);
        END IF;
      END LOOP;

      CLOSE csr_package_names;
      IF g_debug THEN
        debug(l_proc_name, 80);
      END IF;
    END IF;

    IF g_debug THEN
      debug(l_proc_name, 90);
    END IF;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(SQLCODE);
      END IF;
      IF g_debug THEN
        debug(SQLERRM);
      END IF;
      IF g_debug THEN
        debug(l_proc_name, -10);
      END IF;
      IF g_debug THEN
        debug_exit(l_proc_name);
      END IF;
      p_error_code := SQLCODE;
      p_error_message := SQLERRM;
      RAISE;
  END delete_formula;

------------------get_event_group_id--------------------
  FUNCTION get_event_group_id(
    p_business_group_id         IN       NUMBER
   ,p_event_group_name          IN       VARCHAR2
  )
    RETURN NUMBER
  IS
    l_event_group_details         csr_event_group_details%ROWTYPE;
    l_proc_name                   VARCHAR2(70)
                                    := g_package_name || 'get_event_group_id';
  BEGIN -- get_event_group_id
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    OPEN csr_event_group_details(p_event_group_name, p_business_group_id);
    FETCH csr_event_group_details INTO l_event_group_details;
    CLOSE csr_event_group_details;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_event_group_details.event_group_id;
  --
  END;
     -- get_event_group_id
--

------------------get_events--------------------
-- This overloaded get_events procedure has only 1 OUT parameters

  FUNCTION get_events(
    p_assignment_id             IN       NUMBER
   ,p_element_entry_id          IN       NUMBER DEFAULT NULL
   ,p_assignment_action_id      IN       NUMBER DEFAULT NULL
   ,p_business_group_id         IN       NUMBER
   ,p_process_mode              IN       VARCHAR2
        DEFAULT 'ENTRY_EFFECTIVE_DATE'
   ,p_event_group_name          IN       VARCHAR2
   ,p_start_date                IN       DATE
   ,p_end_date                  IN       DATE
   ,t_event_details             OUT NOCOPY pqp_utilities.t_event_details_table_type
  )
    RETURN NUMBER
  IS
    l_proration_dates             pay_interpreter_pkg.t_proration_dates_table_type;
    l_proration_changes           pay_interpreter_pkg.t_proration_type_table_type;
    l_detail_tab                  pay_interpreter_pkg.t_detailed_output_table_type;
    l_pro_type_tab                pay_interpreter_pkg.t_proration_type_table_type;
    l_event_details               pqp_utilities.t_event_details_table_type;
    l_event_group_id              pay_event_groups.event_group_id%TYPE;
    l_dt_event_found              VARCHAR2(20) := 'N'; -- Default NOTFOUND
    l_itr                         NUMBER;
    l_proc_name                   VARCHAR2(61)
                                            := g_package_name || 'get_events';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    l_event_group_id :=
      pqp_utilities.get_event_group_id(
        p_event_group_name =>           p_event_group_name
       ,p_business_group_id =>          p_business_group_id
      );
    IF g_debug THEN
      debug('Event Group Id :' || TO_CHAR(NVL(l_event_group_id, -999)));
    END IF;
    IF g_debug THEN
      debug(l_proc_name, 10);
    END IF;
    pay_interpreter_pkg.entry_affected(
      p_element_entry_id =>           p_element_entry_id
     ,p_assignment_action_id =>       p_assignment_action_id
     ,p_assignment_id =>              p_assignment_id
     ,p_mode =>                       NULL
     ,p_process =>                    NULL
     ,p_event_group_id =>             l_event_group_id
     ,p_process_mode =>               p_process_mode
     ,p_start_date =>                 p_start_date
     ,p_end_date =>                   p_end_date
     -- Passing the BG ID explicitly. else pay_interpreter_pkg uses the cached BGID
     ,p_business_group_id =>          p_business_group_id
     ,t_detailed_output =>            l_detail_tab -- OUT
     ,t_proration_dates =>            l_proration_dates -- OUT
     ,t_proration_change_type =>      l_proration_changes -- OUT
     ,t_proration_type =>             l_pro_type_tab -- OUT
    );
    IF g_debug THEN
      debug(l_proc_name, 20);
    END IF;

    IF (
        l_proration_dates.COUNT > 0 AND -- making sure we have an entry in both the plsql talbes
                                        l_proration_changes.COUNT > 0
       )
    THEN
      debug(
           'Found '
        || TO_CHAR(l_proration_dates.COUNT)
        || ' event(s) for Event Group :'
        || p_event_group_name
       ,30
      );
      -- This loop will merge event dates and event types
      -- into a single plsql table
      l_itr := l_proration_dates.FIRST;

      WHILE l_itr <= l_proration_dates.LAST
      LOOP -- through change proration dates
        debug(
             l_itr
          || '> Date :'
          || TO_CHAR(l_proration_dates(l_itr), 'DD/MM/YYYY')
          || ' Change :'
          || l_proration_changes(l_itr)
         ,40
        );
        l_event_details(l_itr).event_date := l_proration_dates(l_itr);
        l_event_details(l_itr).update_type := l_proration_changes(l_itr);
        l_itr := l_proration_dates.NEXT(l_itr);
      END LOOP;           -- through change proration dates
                --

      IF g_debug THEN
        debug(l_proc_name, 50);
      END IF;
    --
    END IF; -- (l_proration_dates.COUNT > 0

    t_event_details.DELETE;
    t_event_details := l_event_details;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN t_event_details.COUNT;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(' Others in ');
        debug_exit(l_proc_name);
      END IF;
      t_event_details.DELETE;
      RAISE;
  END get_events;


------------------get_events--------------------
-- This overloaded get_events procedure has 2 OUT parameters

  FUNCTION get_events(
    p_assignment_id             IN       NUMBER
   ,p_element_entry_id          IN       NUMBER DEFAULT NULL
   ,p_assignment_action_id      IN       NUMBER DEFAULT NULL
   ,p_business_group_id         IN       NUMBER
   ,p_process_mode              IN       VARCHAR2 DEFAULT 'ENTRY_EFFECTIVE_DATE'
   ,p_event_group_name          IN       VARCHAR2
   ,p_start_date                IN       DATE
   ,p_end_date                  IN       DATE
   ,t_proration_dates          OUT NOCOPY pay_interpreter_pkg.t_proration_dates_table_type
   ,t_proration_change_type    OUT NOCOPY pay_interpreter_pkg.t_proration_type_table_type
  )
    RETURN NUMBER
  IS
    l_proration_dates             pay_interpreter_pkg.t_proration_dates_table_type;
    l_proration_changes           pay_interpreter_pkg.t_proration_type_table_type;
    l_detail_tab                  pay_interpreter_pkg.t_detailed_output_table_type;
    l_pro_type_tab                pay_interpreter_pkg.t_proration_type_table_type;
    l_event_details               pqp_utilities.t_event_details_table_type;
    l_event_group_id              pay_event_groups.event_group_id%TYPE;
    l_dt_event_found              VARCHAR2(20) := 'N'; -- Default NOTFOUND
    l_itr                         NUMBER;
    l_proc_name                   VARCHAR2(61)
                                            := g_package_name || 'get_events';
  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    l_event_group_id :=
      pqp_utilities.get_event_group_id(
        p_event_group_name =>           p_event_group_name
       ,p_business_group_id =>          p_business_group_id
      );
    IF g_debug THEN
      debug('Event Group Id :' || TO_CHAR(NVL(l_event_group_id, -999)));
    END IF;
    IF g_debug THEN
      debug(l_proc_name, 10);
    END IF;
    pay_interpreter_pkg.entry_affected(
      p_element_entry_id =>           p_element_entry_id
     ,p_assignment_action_id =>       p_assignment_action_id
     ,p_assignment_id =>              p_assignment_id
     ,p_mode =>                       NULL
     ,p_process =>                    NULL
     ,p_event_group_id =>             l_event_group_id
     ,p_process_mode =>               p_process_mode
     ,p_start_date =>                 p_start_date
     ,p_end_date =>                   p_end_date
     -- Passing the BG ID explicitly. else pay_interpreter_pkg uses the cached BGID
     ,p_business_group_id =>          p_business_group_id
     ,t_detailed_output =>            l_detail_tab -- OUT
     ,t_proration_dates =>            l_proration_dates -- OUT
     ,t_proration_change_type =>      l_proration_changes -- OUT
     ,t_proration_type =>             l_pro_type_tab -- OUT
    );
    IF g_debug THEN
      debug(l_proc_name, 20);
    END IF;

    t_proration_dates.DELETE;
    t_proration_change_type.DELETE;

    t_proration_dates := l_proration_dates;
    t_proration_change_type := l_proration_changes;

    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN t_proration_dates.COUNT;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(' Others in ');
        debug_exit(l_proc_name);
      END IF;
      t_proration_dates.DELETE;
      t_proration_change_type.DELETE;
      RAISE;
  END get_events;

--
--
--
  PROCEDURE check_error_code(
    p_error_code                IN       fnd_new_messages.message_number%TYPE
   ,p_error_message             IN       fnd_new_messages.MESSAGE_TEXT%TYPE
        DEFAULT NULL
  )
  IS
    l_proc_name                   VARCHAR2(61):=
      g_package_name || 'check_error_code';

  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_error_code:' ||fnd_number.number_to_canonical(p_error_code));
      debug('p_error_message:'||p_error_message);
    END IF;

    IF p_error_code < 0
    THEN

        --IF p_error_code <> hr_utility.hr_error_number
        --THEN
          fnd_message.set_name('PQP', 'PQP_230661_OSP_DUMMY_MSG');
          fnd_message.set_token('TOKEN', p_error_message);
          fnd_message.raise_error;
        --ELSE
        --  RAISE hr_application_error;
          -- error is an application error , ie 20001 hence continue
          -- defined in header.
        --END IF;

    END IF;

    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;

  END check_error_code;

--
--
--
  FUNCTION pqp_fnd_message_set_token(
    token                       IN      VARCHAR2
   ,value                       IN      VARCHAR2
   ,translate                   IN      VARCHAR2 DEFAULT 'N'
   ) RETURN NUMBER IS

   l_translate  BOOLEAN := FALSE;

  BEGIN -- pqp_fnd_message_set_token

    IF translate = 'Y' THEN
      l_translate :=  TRUE;
    END IF;

    fnd_message.set_token
      (token    => token
      ,value    => value
      ,translate => l_translate
      );

    RETURN 0;
    --
  END; -- pqp_fnd_message_set_token

--
--
--
  FUNCTION pqp_fnd_message_set_name(
    application                 IN      VARCHAR2
   ,name                        IN      VARCHAR2
   ) RETURN NUMBER IS
  BEGIN -- pqp_fnd_message_set_name

    fnd_message.set_name
      (application      => application
      ,name             => name
      );

    RETURN 0;
    --
  END; -- pqp_fnd_message_set_name
--
--



-- get_round_value takes a number to be rounded,a factor to be rounded to
-- type of rouding (UP,DOWN,NEAREST,ROUNDTO,NOROUND) as parameters .It returns the number rounded
-- of to the upper or lower rounding factor.
-- if the value for p_rounding_type is not UPPER then it is treated
-- as LOWER
-- Eg. 4.7,0.15,UP would be rounded to 4.75
-- Eg. 4.7,0.15,DOWN would be rounded to 4.60
-- Eg. 4.9,0.5,DOWN would be rounded to 4.5
-- Eg. 4.5000000000000002,0.5,UP would be rounded to 5
-- Eg. 4.91,.15,UP would be rounded to 5
-- Eg. 4.91,.11,UP would be rounded to 4.99
-- Eg. 4.91,.11,DOWN would be rounded to 4.88
-- Eg. 4.91,.11,NEAREST would be rounded to 4.88
-- Eg. 4.91,2,ROUNDTO would be rounded to 4.91
-- Eg. 4.9156,2,ROUNDTO would be rounded to 4.92
-- To Round it to a whole number pass the base value as 1.

FUNCTION round_value_up_down(
    p_value_to_round IN NUMBER
   ,p_base_value     IN NUMBER
   ,p_rounding_type  IN VARCHAR2
  )
  RETURN NUMBER
IS
    l_retval       NUMBER;
    l_lower        NUMBER;
    l_upper        NUMBER;
    l_decimal_part NUMBER;
    l_proc_name    VARCHAR2(61) := g_package_name || 'round_value_up_down';

    BEGIN

    g_debug := hr_utility.debug_enabled;

          IF g_debug THEN
              debug_enter(l_proc_name);
	      debug('p_value_to_round:'||p_value_to_round);
	      debug('p_base_value:'||p_base_value);
	      debug('p_rounding_type:'||p_rounding_type);
          END IF;

     l_retval := p_value_to_round;
      ---if rounding factor is 0 or rounding type is NOROUND then
      ---return the number as it is
      IF p_base_value <> 0 AND p_rounding_type <> 'NOROUND' THEN
            --- Get the decimal part of the number
            l_decimal_part := l_retval - FLOOR(l_retval);
            l_lower:=FLOOR(l_decimal_part/p_base_value);
            l_upper:=l_lower+1;
            l_lower:=p_base_value*l_lower;
            l_upper:=p_base_value*l_upper;

		  IF g_debug THEN
                     debug('Decimal Part '||l_decimal_part );
                     debug('Lower Rounding Factor '||l_lower);
                     debug('Upper Rounding Factor '||l_upper);
                  END IF;

    --Condition when the input number is already rounded or is an integer
          IF NOT ((FLOOR(l_decimal_part/p_base_value)=
	            (l_decimal_part/p_base_value))
                     OR (l_decimal_part=0)) THEN

                IF p_rounding_type = 'UP' THEN --Round UP
                        l_retval := FLOOR(l_retval) + l_upper;
                ELSIF p_rounding_type='DOWN' THEN --Round Down
                        l_retval := FLOOR(l_retval) + l_lower;
                ELSIF p_rounding_type='NEAREST' THEN --To Nearest

                    IF (p_value_to_round-(FLOOR(l_retval) + l_lower)) >=
                       ((FLOOR(l_retval) + l_upper)-p_value_to_round) THEN
                        l_retval := FLOOR(l_retval) + l_upper;
                    ELSE
                        l_retval := FLOOR(l_retval) + l_lower;
                    END IF;

               ELSIF p_rounding_type='ROUNDTO' THEN --Simple Round
                        l_retval := ROUND(l_retval,p_base_value);
               END IF ;

           END IF;--Not already rounded

	   -- Condition when rounding off exceeds
           --  the nearest integer value
           IF l_retval > (FLOOR( p_value_to_round + 1 )) THEN
                l_retval := FLOOR( p_value_to_round + 1 );
           END IF;
       END IF; -- IF p_base_value <> 0 AND p_rounding_type <> 'NOROUND

    RETURN l_retval ;

END round_value_up_down ;
--
--
-- This funcaion is used to fecth the values for the rounding off factors from
-- the PQP_CONFIGURATION_VALUES table.These values are used to round off the
-- absences days  and entitlments remaining days.
FUNCTION pqp_get_config_value(
   p_business_group_id     IN NUMBER
  ,p_legislation_code     IN VARCHAR2
  ,p_column_name          IN VARCHAR2
  ,p_information_category IN VARCHAR2
  ) RETURN VARCHAR2 IS

--Local variable declaration
    l_column_value         VARCHAR(50);
    TYPE ref_csr_typ  IS   REF CURSOR;
    c_column_cursor        ref_csr_typ;
    l_temp_str             VARCHAR2(1000);
BEGIN

  l_temp_str := 'SELECT '|| p_column_name ||'
                 FROM  pqp_configuration_values
                 WHERE  ((business_group_id = ' ||p_business_group_id ||'
                 AND  legislation_code IS NULL )
                 OR  (business_group_id IS NULL
                 AND  legislation_code =
		 '||''''||p_legislation_code ||''''||')
                 OR (business_group_id IS NULL
                 AND legislation_code IS NULL))
                 AND  PCV_INFORMATION_CATEGORY =
		 '|| ''''||p_information_category ||''''||'
                 ' ;

 OPEN c_column_cursor FOR l_temp_str;
 FETCH c_column_cursor INTO l_column_value;
 CLOSE c_column_cursor;

    -- Assign default values to avoid erroring of absence processing in case
    -- no rows are present in pqp_configuration_values for the information
    -- category PQP_GB_OSP_OMP_ROUND.

/*    IF (l_column_value IS NULL) AND (p_column_name='PCV_INFORMATION1' OR p_column_name='PCV_INFORMATION3') THEN
            l_column_value:='DOWN';
    END IF;

    IF (l_column_value IS NULL) AND (p_column_name='PCV_INFORMATION2' OR p_column_name='PCV_INFORMATION4') THEN
            l_column_value:='0.25';
    END IF;
*/

RETURN l_column_value;
END pqp_get_config_value;


------------------pqp_get_ele_type_extra_info_id
-- added by   : vimittal
-- added date : 10-Feb-2005
-- purpose    : The function returns the element type extra information id
--              for the passed element type id and information type.
-- Return -1 in case of Error and 0 in case of Success

  FUNCTION pqp_get_ele_type_extra_info_id(
     p_element_type_id             IN         NUMBER
    ,p_information_type            IN         VARCHAR2
    ,p_element_type_extra_info_id  OUT NOCOPY NUMBER
    ,p_error_msg                   OUT NOCOPY VARCHAR2

  )
    RETURN NUMBER
  IS
  -- this cusrsor fetches the
  -- element_type_extra_info_id
  -- for the element Type_id passed
  CURSOR csr_get_ele_type_extra_info_id
  IS
    SELECT pei.element_type_extra_info_id
    FROM   pay_element_type_extra_info pei
    WHERE  pei.information_type   = p_information_type
      AND  pei.element_type_id    = p_element_type_id;


    l_element_type_extra_info_id  pay_element_type_extra_info.element_type_extra_info_id%TYPE;
    l_retval                      NUMBER := 0 ;
    l_proc_name                   VARCHAR2(61)
                        := g_package_name || 'pqp_get_ele_type_extra_info_id';

  BEGIN
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;

    OPEN csr_get_ele_type_extra_info_id;
    FETCH csr_get_ele_type_extra_info_id INTO l_element_type_extra_info_id ;

    IF csr_get_ele_type_extra_info_id%NOTFOUND THEN
        --
      IF g_debug THEN
        debug(l_proc_name, 10);
      END IF;
      l_element_type_extra_info_id := NULL ;
      l_retval := -1 ;
    END IF;
    CLOSE csr_get_ele_type_extra_info_id ;

    IF g_debug THEN
      debug('l_element_type_extra_info_id: '||to_char(l_element_type_extra_info_id),20);
    END IF;

    p_element_type_extra_info_id := l_element_type_extra_info_id;

    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;

  EXCEPTION
    WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_error_msg := SQLERRM;
      p_element_type_extra_info_id := NULL;
      RETURN -1;
  END pqp_get_ele_type_extra_info_id;


--
---------------------------chk_cached_udt_bucket-------------------------------
FUNCTION chk_cached_udt_bucket (p_refresh_cache  IN VARCHAR2
                                ,p_business_group IN NUMBER
				,p_table_name     IN VARCHAR2
			        ,p_error_msg      OUT NOCOPY VARCHAR2
			      )
RETURN BOOLEAN
IS
l_table_in_cache            BOOLEAN:= FALSE;
l_proc_name                   VARCHAR2(70)
                                          := g_package_name || 'chk_cached_udt_bucket';
l_err_msg                   VARCHAR2(100);


BEGIN

IF g_debug THEN
  debug_enter(l_proc_name);

END IF;

IF g_cached_udt.EXISTS(g_hash_key) THEN
  IF    ( (  g_cached_udt(g_hash_key).business_group_id = p_business_group
         AND g_cached_udt(g_hash_key).table_name = p_table_name  )
         OR (g_cached_udt(g_hash_key).table_name = p_table_name ))
  THEN

    IF p_refresh_cache = 'Y' THEN
      debug(l_proc_name,15);
      l_table_in_cache := FALSE;
      delete_udt_value --have a look at this procedure as well
      (p_table_name => p_table_name
      ,p_error_msg  => l_err_msg
      );
    ELSE
      IF g_debug  THEN
        debug('Table is found in the hash bucket');
      END IF;
	l_table_in_cache := TRUE;
    END IF;

  END IF;
END IF;


RETURN l_table_in_cache;

EXCEPTION
 WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_error_msg := SQLERRM;


END  chk_cached_udt_bucket;

--
-------------------------set_hash_parameters------------------------
PROCEDURE set_hash_parameters
 (p_hash_base       IN  BINARY_INTEGER
 ,p_hash_size       IN  BINARY_INTEGER
 ,p_conflict_check  IN  BOOLEAN DEFAULT FALSE
 )
IS
BEGIN
 g_hash_base      := p_hash_base;
 g_hash_size      := p_hash_size;
 g_conflict_check := p_conflict_check;
END set_hash_parameters;
------------------------get_hash_key------------------------------------
FUNCTION get_hash_key
  (p_string         IN  VARCHAR2
  ,p_error_msg      OUT NOCOPY VARCHAR2
  ,p_refresh_cache  IN VARCHAR2
  ,p_business_group_id IN NUMBER
  ) RETURN BINARY_INTEGER
IS
  l_hash_key                    BINARY_INTEGER;
  l_proc_name                   VARCHAR2(70)
                                          := g_package_name || 'get_hash_key';
  l_already_cached              BOOLEAN ;
BEGIN
  l_hash_key := DBMS_UTILITY.GET_HASH_VALUE(p_string, g_hash_base, g_hash_size);
  IF g_conflict_check THEN
    IF g_hash_keys.EXISTS(l_hash_key) THEN
      -- conflict raise an exception
      IF g_hash_keys(l_hash_key).hash_string <> p_string THEN
       -- it's a conflict situation
          RAISE TOO_MANY_ROWS;
      END IF;
    ELSE
        g_hash_keys(l_hash_key).hash_string := p_string;
    END IF;
  END IF;
 RETURN l_hash_key;
 EXCEPTION
 --
   WHEN OTHERS
    THEN
      IF g_debug THEN
        debug(l_proc_name||':Others Exception:');
        debug(SQLCODE);
        debug(SQLERRM);
        debug_exit(l_proc_name);
      END IF;
      p_error_msg := SQLERRM;
      RETURN -1;

END get_hash_key;
------------------------------reset_hash_keys----------------------------
PROCEDURE reset_hash_keys
IS
BEGIN
  g_hash_keys.DELETE;
END reset_hash_keys;
------------------------------set_hash_conflict_check_off----------------

PROCEDURE set_hash_conflict_check_off
IS
BEGIN
  reset_hash_keys;
  g_conflict_check := FALSE;
END set_hash_conflict_check_off;
-------------------set_hash_conflict_check_on-------------------------
PROCEDURE set_hash_conflict_check_on
IS
BEGIN
  reset_hash_keys;
  g_conflict_check := TRUE;
END set_hash_conflict_check_on;
---------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
  -- |-------------------------< get_kflex_value >-----------------------------|
  --  Description: This procedure is to fetch the Key Flexfiled Value.
  --              This will return all segment values for the row specified by the
  --                  key_column_name and key_column_value
  -- ----------------------------------------------------------------------------
  PROCEDURE get_kflex_value
      (p_entity_name                IN VARCHAR2 -- name of the table holding the values
      ,p_key_column_name            IN VARCHAR2 -- Key Column Name
      ,p_key_column_value           IN VARCHAR2 -- Key Column Value
      ,p_segment_column_values      OUT NOCOPY r_all_segment_values
      )
  IS
  l_proc varchar2(72) := g_package_name||'.get_kflex_value';
  -- Type Declarations
      TYPE base_table_ref_csr_typ IS REF CURSOR;

    -- Variable Declarations
      c_base_table        base_table_ref_csr_typ;

      l_query               VARCHAR2(4000); -- Dynamically constructed query

  BEGIN
    hr_utility.set_location('Entering '||l_proc,10);
    IF (p_entity_name is not null) AND
       (p_key_column_name is not null) AND
       (p_key_column_value is not null) THEN

          l_query :=
            'SELECT SEGMENT1';
          FOR i IN 1..30
          LOOP
               l_query := l_query||',SEGMENT'||i;
          END LOOP;

          l_query := l_query||
                      ' FROM   '||p_entity_name||' '||
                      'WHERE  '||p_key_column_name||' = '||p_key_column_value;
          hr_utility.trace('l_query: '||l_query);
          hr_utility.trace('Before opening dynamic query');

          OPEN c_base_table FOR l_query;
          FETCH c_base_table INTO p_segment_column_values;
          CLOSE c_base_table;
          hr_utility.trace('After precessing dynamic query');
    END IF; -- IF (p_entity_name is not null) AND..
    hr_utility.set_location('Leaving '||l_proc,10);
  END get_kflex_value;
  ---
  -- ----------------------------------------------------------------------------
  -- |-------------------------< get_kflex_value >-----------------------------|
  --  Description: This is to fetch the Configuration values.
  --              This will return the value of the column specified.
  -- ----------------------------------------------------------------------------
  PROCEDURE get_kflex_value
      (p_entity_name                IN VARCHAR2 -- name of the table holding the values
      ,p_key_column_name            IN VARCHAR2 -- Key Column Name
      ,p_key_column_value           IN VARCHAR2 -- Key Column Value
      ,p_segment_column_name        IN VARCHAR2
      ,p_segment_column_value       OUT NOCOPY VARCHAR2
      )
  IS
  l_proc varchar2(72) := g_package_name||'.get_config_value';
  -- Type Declarations
      TYPE base_table_ref_csr_typ IS REF CURSOR;

    -- Variable Declarations
      c_base_table        base_table_ref_csr_typ;

      l_query               VARCHAR2(4000); -- Dynamically constructed query
  BEGIN
      hr_utility.set_location('Entering '||l_proc,10);
      l_query := 'SELECT '|| p_segment_column_name ||'
                       FROM  '|| p_entity_name ||'
                       WHERE  '||p_key_column_name||' = '|| p_key_column_value;

       OPEN c_base_table FOR l_query;
       FETCH c_base_table INTO p_segment_column_value;
       CLOSE c_base_table;

      hr_utility.set_location('Leaving '||l_proc,10);
  END get_kflex_value;
  --
    /*---------------------------------------------------------------/
    /--Description: This is a wrapper procedure on pay_interpreter_pkg.entries_affected
    --                  pay_interpreter_pkg.entry_affected.
    --              Depending upon the elements entries on the assignment
    --                which are of type of elements which are attached to
    --                the element set which are attached to the event group
    --                 usages, this procedure calls entries_affected or entry_affected
    --                 and returns the table of events for the event group during the
    --                  date range specified
    */
    PROCEDURE entries_affected
                      (p_assignment_id          IN  NUMBER DEFAULT NULL
                      ,p_event_group_id         IN  NUMBER DEFAULT NULL
                      ,p_mode                   IN  VARCHAR2 DEFAULT NULL
                      ,p_start_date             IN  DATE  DEFAULT hr_api.g_sot
                      ,p_end_date               IN  DATE  DEFAULT hr_api.g_eot
                      ,p_business_group_id      IN  NUMBER
                      ,p_detailed_output        OUT NOCOPY  pay_interpreter_pkg.t_detailed_output_table_type
                      ,p_process_mode           IN  VARCHAR2 DEFAULT 'ENTRY_CREATION_DATE'
                      )
    IS
          TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

          TYPE r_element_entries IS RECORD
                (
                element_entry_id    t_number
                ,datetracked_event_id t_number
                );

          l_proc                VARCHAR2(70)  :=  g_package_name||'.entries_effected';
          l_datetrack_ee_tab    r_element_entries;
          l_count               NUMBER := 0;
          l_global_env          pay_interpreter_pkg.t_global_env_rec;
          l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
          l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;
          l_pro_type_tab        pay_interpreter_pkg.t_proration_type_table_type;
          l_eg_has_ee_tab       VARCHAR2(1);


          CURSOR csr_chk_eg_for_ee_tab
          IS
              SELECT 'Y'
              FROM pay_datetracked_events pde
                  ,pay_dated_tables pdt
              WHERE event_group_id = p_event_group_id
              AND pde.dated_table_id = pdt.dated_table_id
              AND (pdt.table_name = 'PAY_ELEMENT_ENTRIES_F'
                   OR
                   pdt.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
                  )
              AND ROWNUM < 2;

          FUNCTION get_element_entries_for_eg
                      (p_event_group_id           IN      NUMBER
                      ,p_assignment_id            IN      NUMBER
                      ,p_start_date               IN      DATE
                      ,p_end_date                 IN      DATE
                      ,p_element_entries_tab     OUT NOCOPY  r_element_entries
                      ) RETURN NUMBER -- number of element entries in the out param table
          IS
              l_proc  VARCHAR2(70)  :=  g_package_name||'.get_element_entries_for_eg';
              l_purge_dte_id        NUMBER;
              l_purge_ee_ids        t_number;
              l_next                NUMBER;
              l_element_entries_tab r_element_entries;
              l_element_set_ids_tab t_number;
              l_index               NUMBER;
              l_match_exists        VARCHAR2(10);

              CURSOR csr_get_element_set (p_event_group_id IN NUMBER)
              IS
              SELECT element_set_id
                FROM pay_event_group_usages
               WHERE event_group_id = p_event_group_id;

              CURSOR csr_element_entries
                      (p_element_set_id   IN      NUMBER
                      ,p_event_group_id   IN      NUMBER
                      ,p_assignment_id    IN      NUMBER
                      ,p_start_date       IN      DATE
                      ,p_end_date         IN      DATE
                      )
              IS
                  SELECT  distinct pee.element_entry_id
                         ,pde.datetracked_event_id
                  FROM  pay_element_set_members pes
                       ,pay_element_entries_f pee
                       ,pay_datetracked_events pde
                  WHERE pes.element_set_id = p_element_set_id
                  AND pee.element_type_id = pes.element_type_id
                  AND pee.assignment_id = p_assignment_id
                  AND pde.event_group_id = p_event_group_id
                  AND (
                       p_start_date BETWEEN pee.effective_start_date AND pee.effective_end_date
                       OR
                       p_end_date BETWEEN pee.effective_start_date AND pee.effective_end_date
                       OR
                       pee.effective_start_date BETWEEN p_start_date AND p_end_date
                       OR
                       pee.effective_end_date BETWEEN p_start_date AND p_end_date
                      );

              -- this is used to check for any datetracked events for purge events on
              --  element entries in the event group.
              CURSOR csr_get_purge_events_on_eg
              IS
                  SELECT datetracked_event_id
                  FROM pay_datetracked_events pde
                      ,pay_dated_tables pdt
                  WHERE event_group_id = p_event_group_id
                  AND pde.dated_table_id = pdt.dated_table_id
                  AND pde.update_type = 'P'
                  AND pdt.table_name = 'PAY_ELEMENT_ENTRIES_F';


              -- this is used to fetch the element entry ids of the
              --  puged element entries.
              -- the element tntry ids are fetched by comparing the
              --   element type id in the element set attached to the
              --   event group and the element type id stored in the
              --   column 'NOTED_VALUE' of pay_process_events fro purged
              --   element entry events.
              CURSOR csr_get_purged_ee_ids (p_element_set_id IN NUMBER)
              IS
                  SELECT  distinct ppe.surrogate_key
                  FROM  pay_element_set_members pes
                       ,pay_process_events ppe
                       ,pay_event_updates peu
                  WHERE pes.element_set_id = p_element_set_id
                  AND ppe.assignment_id    = p_assignment_id
                  AND ppe.noted_value      = pes.element_type_id
                  AND peu.event_update_id = ppe.event_update_id
                  AND peu.event_type = 'ZAP'
                  AND ppe.effective_date BETWEEN p_start_date AND p_end_date;


        BEGIN
              hr_utility.trace('Entering: '||l_proc);
              hr_utility.trace('Entered get_element_entries_for_eg: EG_Id:'||to_char(p_event_group_id));
              hr_utility.trace('Assignment Id:'||to_char(p_assignment_id));
              hr_utility.trace('Start Date:'||to_char(p_start_date, 'DD/MM/YYYY'));
              hr_utility.trace('End Date:'||to_char(p_end_date, 'DD/MM/YYYY'));

              p_element_entries_tab.element_entry_id.DELETE;
              p_element_entries_tab.datetracked_event_id.DELETE;

              -- check for the purge datetracked events on element entries
              --  in the event group and include them in the p_element_entires_tab collection
              OPEN csr_get_purge_events_on_eg;
              FETCH csr_get_purge_events_on_eg INTO l_purge_dte_id;

              OPEN csr_get_element_set (p_event_group_id => p_event_group_id);
              FETCH csr_get_element_set BULK COLLECT INTO l_element_set_ids_tab;
              CLOSE csr_get_element_set;
              hr_utility.trace('Count:'||to_char(l_element_set_ids_tab.COUNT));
              FOR i IN 1..l_element_set_ids_tab.COUNT LOOP
                OPEN csr_element_entries
                               (p_element_set_id   => l_element_set_ids_tab(i)
                               ,p_event_group_id   => p_event_group_id
                               ,p_assignment_id    => p_assignment_id
                               ,p_start_date       => p_start_date
                               ,p_end_date         => p_end_date
                             );
                FETCH csr_element_entries BULK COLLECT INTO l_element_entries_tab;
                CLOSE csr_element_entries;
                hr_utility.trace('Count:'||to_char(l_element_entries_tab.element_entry_id.COUNT));


                IF csr_get_purge_events_on_eg%FOUND THEN
                   -- if there are purge events in the event group
                   hr_utility.trace('There are puge events on element entries table in the eg.');
                   OPEN csr_get_purged_ee_ids(l_element_set_ids_tab(i));
                   FETCH csr_get_purged_ee_ids BULK COLLECT INTO l_purge_ee_ids;
                   CLOSE csr_get_purged_ee_ids;

                   hr_utility.trace('Fill the values in the element entries collection.');
                   FOR i IN 1..l_purge_ee_ids.COUNT
                   LOOP
                       hr_utility.trace('l_purge_ee_ids(i): '||l_purge_ee_ids(i));
                       -- bug fix 5368066. nvl is added for this bug fix.
                       l_next  :=  nvl(l_element_entries_tab.element_entry_id.LAST,0) + 1;
                       l_element_entries_tab.element_entry_id(l_next)  :=  fnd_number.canonical_to_number(l_purge_ee_ids(i));
                       l_element_entries_tab.datetracked_event_id(l_next)  :=  l_purge_dte_id;
                   END LOOP;
                END IF;

                FOR i IN 1..l_element_entries_tab.element_entry_id.COUNT LOOP
                  IF p_element_entries_tab.element_entry_id.COUNT = 0 THEN
                    p_element_entries_tab := l_element_entries_tab;
                    EXIT;
                  ELSE -- count is non zero
                    l_index := p_element_entries_tab.element_entry_id.LAST;
                    l_match_exists := 'N';
                    FOR j IN 1..p_element_entries_tab.element_entry_id.COUNT LOOP
                      IF p_element_entries_tab.element_entry_id(j) = l_element_entries_tab.element_entry_id(i) AND
                         p_element_entries_tab.datetracked_event_id(j) = l_element_entries_tab.datetracked_event_id(i)
                      THEN
                        -- Combination exist so do nothing
                        l_match_exists := 'Y';
                        EXIT;
                      END IF; -- End if of match exists check ...
                    END LOOP; -- j loop
                    IF l_match_exists = 'N' THEN
                       -- store the information
                       l_index := l_index + 1;
                       p_element_entries_tab.element_entry_id(l_index) := l_element_entries_tab.element_entry_id(i);
                       p_element_entries_tab.datetracked_event_id(l_index) := l_element_entries_tab.datetracked_event_id(i);
                    END IF; -- End if of match does not exist ...
                  END IF; -- End if of return collection count is zero check ...
                END LOOP; -- i loop

              END LOOP; -- element set loop ...
              CLOSE csr_get_purge_events_on_eg;
              hr_utility.trace('Count:'||to_char(p_element_entries_tab.element_entry_id.COUNT));

              hr_utility.trace('Leaving: '||l_proc);
              RETURN p_element_entries_tab.element_entry_id.COUNT;

        EXCEPTION
           WHEN OTHERS THEN
              -- NOCOPY
              p_element_entries_tab.element_entry_id.DELETE;
              p_element_entries_tab.datetracked_event_id.DELETE;
              RAISE;
        END get_element_entries_for_eg;
        ---------
    BEGIN --entries_effected
        hr_utility.trace('Entering: '||l_proc);
        hr_utility.trace('Get the element entries for the assignment id');

        -- Bugfix 4739067: Performance enhancement
        --   Checking if the event group has element entries or
        --   element entry values table before trying to fetch events
        --   If the EG does not have EE tables, we use the entry_affected call
        OPEN csr_chk_eg_for_ee_tab;
        FETCH csr_chk_eg_for_ee_tab INTO l_eg_has_ee_tab;
        CLOSE csr_chk_eg_for_ee_tab;

        IF l_eg_has_ee_tab = 'Y' THEN
          l_count   :=  get_element_entries_for_eg
                          (p_event_group_id          =>   p_event_group_id
                          ,p_assignment_id           =>   p_assignment_id
                          ,p_start_date              =>   p_start_date
                          ,p_end_date                =>   p_end_date
                          ,p_element_entries_tab     =>   l_datetrack_ee_tab
                          );
        ELSE
          l_count := 0;
        END IF;

        -----
        -- This line can be removed after fix from pay for missing events on mix of calls to
        --    entry_affected and entries_affected - kkarri
        pay_interpreter_pkg.t_distinct_tab   :=  pay_interpreter_pkg.glo_monitored_events;
        -----
        IF l_count > 0 THEN
            hr_utility.trace('Our procedure');
            hr_utility.trace('Setup the global area');
            pay_interpreter_pkg.initialise_global(l_global_env);
            pay_interpreter_pkg.event_group_tables
                                    (p_event_group_id =>  p_event_group_id
                                     ,p_distinct_tab  =>  pay_interpreter_pkg.glo_monitored_events
                                    );
            --The start and end pointers can be just for the event group.
            --    So, commenting out these lines. - kkarri
            /*l_global_env.monitor_start_ptr    := 1;
            l_global_env.monitor_end_ptr      := pay_interpreter_pkg.glo_monitored_events.count;*/
            l_global_env.monitor_start_ptr
                    := pay_interpreter_pkg.t_proration_group_tab(p_event_group_id).range_start;
            l_global_env.monitor_end_ptr
                    := pay_interpreter_pkg.t_proration_group_tab(p_event_group_id).range_end;
            ---
            l_global_env.datetrack_ee_tab_use := TRUE;
            l_global_env.validate_run_actions := FALSE;

            FOR i IN l_datetrack_ee_tab.element_entry_id.FIRST..l_datetrack_ee_tab.element_entry_id.LAST
            LOOP
                hr_utility.trace('----------------------------------');
                hr_utility.trace('i: '||i);
                hr_utility.trace('datetracked_event_id: '||l_datetrack_ee_tab.datetracked_event_id(i));
                hr_utility.trace('element_entry_id: '||l_datetrack_ee_tab.element_entry_id(i));
                pay_interpreter_pkg.add_datetrack_event_to_entry
                         (p_datetracked_evt_id  =>   l_datetrack_ee_tab.datetracked_event_id(i)
                          ,p_element_entry_id   =>   l_datetrack_ee_tab.element_entry_id(i)
                          ,p_global_env         =>   l_global_env
                          );
            END LOOP;
            hr_utility.trace('Entered all the dte_id X ee_ids');

            BEGIN
            --call entries_effected
            pay_interpreter_pkg.entries_affected
                                  (p_assignment_id         =>   p_assignment_id
                                  ,p_mode                  =>   p_mode
                                  ,p_start_date            =>   p_start_date
                                  ,p_end_date              =>   p_end_date
                                  ,p_business_group_id     =>   p_business_group_id
                                  ,p_global_env            =>   l_global_env
                                  ,t_detailed_output       =>   p_detailed_output
                                  ,p_process_mode          =>   p_process_mode
                                  );
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    hr_utility.trace('No payroll run for the assignment');
                    hr_utility.set_message(8303,'BEN_94629_NO_ASG_ACTION_ID');
                    hr_utility.raise_error;
            END;
            -- reset l_global_env
            pay_interpreter_pkg.clear_dt_event_for_entry
              (p_global_env         => l_global_env);
        ELSE
            hr_utility.trace('Normal call to entries_effected');
            --call entry_affected
            pay_interpreter_pkg.entry_affected(
                             p_element_entry_id      => NULL
                            ,p_assignment_action_id  => NULL
                            ,p_assignment_id         => p_assignment_id
                            ,p_mode                  => p_mode
                            ,p_process               => NULL -- 'U' --
                            ,p_event_group_id        => p_event_group_id
                            ,p_process_mode          => p_process_mode
                            ,p_start_date            => p_start_date
                            ,p_end_date              => p_end_date
                            ,t_detailed_output       => p_detailed_output  -- OUT
                            ,t_proration_dates       => l_proration_dates  -- OUT
                            ,t_proration_change_type => l_proration_changes  -- OUT
                            ,t_proration_type        => l_pro_type_tab -- OUT
                            );
        END IF;
        hr_utility.trace('Leaving: '||l_proc);
    END entries_affected;
--
END pqp_utilities;

/
